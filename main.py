import os
import json
import subprocess
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
PL_PATH = os.path.join(BASE_DIR, "prueba.pl").replace("\\", "/")

class DiagnosticoRequest(BaseModel):
    sintomas: List[str]

SINTOMAS_VALIDOS = {
    "no_da_marcha", "luces_debiles", "chasquido_al_arrancar",
    "pedal_esponjoso", "chillido_al_frenar", "distancia_frenado_larga",
    "liquido_frenos_bajo", "humo_azul", "humo_blanco_denso",
    "temperatura_alta", "ventilador_no_enciende"
}

@app.post("/api/diagnosticar")
def diagnosticar(data: DiagnosticoRequest):
    sintomas_limpios = [s for s in data.sintomas if s in SINTOMAS_VALIDOS]
    print(f"\n[INFO] Síntomas recibidos: {sintomas_limpios}")

    if not sintomas_limpios:
        return {
            "status": "insuficiente",
            "mensaje": "No se seleccionaron síntomas válidos o los datos son insuficientes.",
            "diagnosticos": []
        }

    # 1. Inyectamos assertz para cada síntoma
    asserts = ", ".join([f"assertz(sintoma_presente({s}))" for s in sintomas_limpios])
    
    # 2. Prolog formatea cada elemento entre comillas: "falla"|"sistema"|"pieza"|"urgencia"|"solucion"
    # y separa las soluciones con comas, entregando un JSON limpio y directo.
    prolog_query = (
        f"{asserts}, "
        f"findall(json(F, Sis, P, N, Sol), diagnostico_completo(F, Sis, P, N, Sol), Lista), "
        f"retractall(sintoma_presente(_)), "
        f"write('RESULTADO:['), "
        f"forall(member(json(F, Sis, P, N, Sol), Lista), ("
        f"  format('{{\"falla\":\"~w\",\"sistema\":\"~w\",\"pieza\":\"~w\",\"urgencia\":\"~w\",\"recomendacion\":\"~w\"}},', [F, Sis, P, N, Sol])"
        f")), "
        f"write(']'), nl, halt."
    )

    try:
        process = subprocess.run(
            ["swipl", "-q", "-s", PL_PATH, "-g", prolog_query],
            capture_output=True,
            text=True,
            timeout=5
        )
    except Exception as e:
        print(f"[ERROR SUBPROCESS] {e}")
        raise HTTPException(status_code=500, detail=str(e))

    salida = process.stdout
    print("--- [DEBUG] SALIDA FORMATEADA ---")
    print(salida)

    if "RESULTADO:[" not in salida:
        return {
            "status": "sin_coincidencias",
            "mensaje": "El motor de inferencia evaluó las reglas pero no halló fallas coincidentes.",
            "diagnosticos": []
        }

    # 3. Parseo seguro de la lista JSON
    try:
        raw_json = salida.split("RESULTADO:")[1].strip()
        # Eliminar la última coma sobrante generada por forall: ",]" -> "]"
        raw_json = raw_json.replace(",]", "]")
        
        resultados = json.loads(raw_json)
        print(f"[ÉXITO] Diagnósticos parseados correctamente: {len(resultados)}")

        return {
            "status": "exito" if resultados else "sin_coincidencias",
            "total_soluciones": len(resultados),
            "diagnosticos": resultados
        }

    except Exception as err:
        print(f"[ERROR PARSEO] {err}")
        return {
            "status": "error_parseo",
            "mensaje": "Error al interpretar la respuesta inferida por Prolog.",
            "diagnosticos": []
        }

# Servir static
app.mount("/", StaticFiles(directory="static", html=True), name="static")