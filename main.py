import os
import json
import subprocess
from functools import lru_cache
from typing import List
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel

app = FastAPI(title="Sistema Experto Automotriz - ESCOM")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Ruta absoluta al archivo de Prolog
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
PL_PATH = os.path.join(BASE_DIR, "diagnostico_automotriz.pl").replace("\\", "/")

class DiagnosticoRequest(BaseModel):
    sintomas: List[str]


def ejecutar_prolog(goal: str) -> dict:
    """Carga la base de conocimientos, ejecuta un objetivo que imprime JSON y lo regresa como dict."""
    envuelto = (
        f"use_module(library(http/json)), "
        f"catch(({goal}), E, (print_message(error, E), halt(1))), halt."
    )
    try:
        process = subprocess.run(
            ["swipl", "-q", "-s", PL_PATH, "-g", envuelto],
            capture_output=True,
            text=True,
            timeout=5,
        )
    except Exception as e:
        print(f"[ERROR SUBPROCESS] {e}")
        raise HTTPException(status_code=500, detail="No se pudo ejecutar el motor Prolog.")

    if process.returncode != 0:
        print(f"[ERROR PROLOG] {process.stderr}")
        raise HTTPException(status_code=500, detail="El motor Prolog reportó un error.")

    return json.loads(process.stdout)


@lru_cache(maxsize=1)
def catalogo_sintomas() -> tuple:
    # Los síntomas válidos se leen directamente de los hechos sintoma/2
    datos = ejecutar_prolog(
        "findall(_{id:S, sistema:Sis}, sintoma(S, Sis), L), "
        "json_write_dict(current_output, L)"
    )
    return tuple((d["id"], d["sistema"]) for d in datos)


@app.get("/api/sintomas")
def listar_sintomas():
    return [{"id": s, "sistema": sis} for s, sis in catalogo_sintomas()]


@app.post("/api/diagnosticar")
def diagnosticar(data: DiagnosticoRequest):
    validos = {s for s, _ in catalogo_sintomas()}
    # Solo se aceptan átomos que existan como hechos sintoma/2 (nunca código arbitrario)
    sintomas_limpios = sorted({s for s in data.sintomas if s in validos})
    descartados = [s for s in data.sintomas if s not in validos]
    print(f"\n[INFO] Síntomas recibidos: {sintomas_limpios} | descartados: {descartados}")

    if not sintomas_limpios:
        return {
            "status": "insuficiente",
            "clasificacion": "mas_informacion",
            "mensaje": "Selecciona al menos un síntoma para poder hacer el diagnóstico.",
            "diagnosticos": [],
        }

    lista = "[" + ",".join(sintomas_limpios) + "]"

    # clasificar_caso/2 da la prioridad general; diagnostico_completo/6 da cada causa por backtracking.
    # Para la explicación se agregan certeza/3, los síntomas que apoyan la causa y sintomas_por_confirmar/3.
    goal = (
        f"Ss = {lista}, "
        f"clasificar_caso(Ss, Clase), "
        f"findall(_{{causa:C, componente:Comp, sistema:Sis, urgencia:U, certeza:Cert, "
        f"verificacion:V, apoyo:Ap, por_confirmar:F}}, "
        f"(diagnostico_completo(Ss, C, Comp, Sis, U, V), "
        f" certeza(Ss, C, Cert), "
        f" findall(S, (member(S, Ss), rel_sintoma_causa(S, C)), Ap0), sort(Ap0, Ap), "
        f" sintomas_por_confirmar(Ss, C, F)), L), "
        f"json_write_dict(current_output, _{{clasificacion:Clase, diagnosticos:L}})"
    )

    try:
        resultado = ejecutar_prolog(goal)
    except HTTPException:
        raise
    except Exception as err:
        print(f"[ERROR PARSEO] {err}")
        return {
            "status": "error_parseo",
            "mensaje": "Error al interpretar la respuesta inferida por Prolog.",
            "diagnosticos": [],
        }

    diagnosticos = resultado["diagnosticos"]
    print(f"[ÉXITO] Clasificación: {resultado['clasificacion']} | causas: {len(diagnosticos)}")

    return {
        "status": "exito" if diagnosticos else "sin_coincidencias",
        "clasificacion": resultado["clasificacion"],
        "sintomas_evaluados": sintomas_limpios,
        "total_soluciones": len(diagnosticos),
        "diagnosticos": diagnosticos,
    }

# Servir static
app.mount("/", StaticFiles(directory="static", html=True), name="static")
