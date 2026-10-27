# Sistema Experto de Diagnóstico Automotriz

**Instituto Politécnico Nacional · Escuela Superior de Cómputo (ESCOM)**
**Unidad de aprendizaje:** Paradigmas de Programación
**Paradigma:** Programación lógica · **Lenguaje:** SWI-Prolog

**Aplicación publicada:** https://sistema-experto-automotriz.onrender.com

> Herramienta de orientación educativa. No sustituye la revisión de un mecánico profesional.

---

## Descripción

El usuario marca los síntomas que nota en su auto (clics al arrancar, temperatura elevada, pedal de freno blando, etc.) y el motor de inferencia en Prolog determina:

- las **causas posibles**, una por solución (backtracking);
- el **grado de certeza** de cada causa: *posible* con un síntoma, *probable* con dos o más;
- la **clasificación del caso**: `urgente`, `mas_informacion`, `revision_pronta`, `revision_normal` o `sin_coincidencias`;
- la **pieza y el sistema** afectados y la **verificación recomendada**;
- los **síntomas por confirmar** para reforzar cada causa.

La base de conocimientos (`diagnostico_automotriz.pl`) tiene 86 hechos en 6 predicados y 19 cláusulas de reglas, y cubre 16 síntomas, 7 sistemas del vehículo y 13 causas.

---

## Arquitectura

```
Navegador ──HTTPS──▶ static/index.html ──JSON──▶ main.py (FastAPI) ──swipl -g──▶ diagnostico_automotriz.pl
    ▲                                                   │                                  │
    └────────────── tarjetas de resultado ◀── JSON ─────┴────────── json_write_dict ◀──────┘
                        (todo dentro de un contenedor Docker desplegado en Render)
```

1. **Frontend** (`static/index.html`): HTML, CSS y JavaScript sin frameworks. Carga la lista de síntomas desde la API y muestra los resultados con su explicación.
2. **API** (`main.py`): FastAPI. Valida que cada síntoma exista como hecho `sintoma/2`, arma un objetivo controlado y ejecuta `swipl` como subproceso (límite de 5 s). Nunca ejecuta código enviado por el usuario.
3. **Motor de inferencia** (`diagnostico_automotriz.pl`): SWI-Prolog. Todas las conclusiones salen de sus hechos y reglas; Prolog escribe el resultado en JSON con `json_write_dict/2`.

### API

| Método | Ruta | Entrada | Salida |
|---|---|---|---|
| GET | `/api/sintomas` | — | `[{ "id", "sistema" }]` tomado de `sintoma/2` |
| POST | `/api/diagnosticar` | `{ "sintomas": ["temperatura_elevada", ...] }` | `status`, `clasificacion`, `sintomas_evaluados`, `diagnosticos[]` |

---

## Ejecución local

**Requisitos:** SWI-Prolog (con `swipl` en el PATH), Python 3.11+ y Git.

```bash
git clone https://github.com/JuanJimenezIA/sistema-experto-automotriz.git
cd sistema-experto-automotriz
pip install -r requirements.txt
uvicorn main:app --reload
```

Abrir http://localhost:8000.

Para consultar solo el motor lógico:

```bash
swipl diagnostico_automotriz.pl
```

### Con Docker

```bash
docker build -t sistema-experto .
docker run -p 8000:8000 sistema-experto
```

---

## Despliegue en Render

1. Crear un **Web Service** en Render conectado a este repositorio, con entorno **Docker**.
2. Render construye la imagen con el `Dockerfile`: parte de `python:3.11-slim`, instala `swi-prolog`, instala las dependencias de Python y copia `diagnostico_automotriz.pl`, `main.py` y `static/`.
3. El contenedor arranca con `uvicorn main:app --host 0.0.0.0 --port 8000`.
4. Cada `git push` a `main` genera un nuevo despliegue automático (o se lanza con *Manual Deploy*).

El plan gratuito suspende el servicio cuando no tiene tráfico, así que la primera carga puede tardar entre 30 y 50 segundos.

---

## Ejemplos de consultas y resultados

En la consola de SWI-Prolog:

```prolog
?- diagnosticar([clicks_al_intentar_arrancar, luces_tablero_debiles], C, U, Cert).
C = alternador_defectuoso, U = media, Cert = posible ;
C = bateria_descargada,    U = media, Cert = probable ;
C = bateria_deteriorada,   U = media, Cert = posible.

?- clasificar_caso([chirrido_o_ruido_metalico_frenar, testigo_aceite_rojo_encendido], X).
X = urgente.

?- clasificar_caso([temperatura_elevada], X).
X = mas_informacion.

?- verificar_estado_sistema(frenos, S, C).
S = pedal_freno_blando_o_se_hunde,    C = fuga_liquido_frenos ;
S = chirrido_o_ruido_metalico_frenar, C = pastillas_desgastadas ;
S = vibracion_pedal_al_frenar,        C = discos_freno_danados.

?- diagnosticar([ruido_en_la_puerta], C, U, Cert).
false.
```

Vía API:

```bash
curl -X POST https://sistema-experto-automotriz.onrender.com/api/diagnosticar \
  -H "Content-Type: application/json" \
  -d '{"sintomas": ["temperatura_elevada", "humo_blanco_persistente"]}'
```

```json
{
  "status": "exito",
  "clasificacion": "revision_pronta",
  "sintomas_evaluados": ["humo_blanco_persistente", "temperatura_elevada"],
  "total_soluciones": 3,
  "diagnosticos": [
    {
      "causa": "junta_culata_danada",
      "componente": "junta_de_culata",
      "sistema": "motor_interno",
      "urgencia": "alta",
      "certeza": "probable",
      "verificacion": "Prueba de compresion y revisar si hay aceite en el refrigerante.",
      "apoyo": ["humo_blanco_persistente", "temperatura_elevada"],
      "por_confirmar": ["necesidad_frecuente_rellenar_refrigerante"]
    }
  ]
}
```

(Se muestra una de las 3 causas; las otras son `fuga_refrigerante` y `ventilador_radiador_no_funciona`, ambas *posibles*.)

El archivo `diagnostico_automotriz.pl` documenta al final 12 consultas de prueba con el resultado esperado y el obtenido.

---

## Estructura

```
├── diagnostico_automotriz.pl   # Base de conocimientos y reglas (Prolog)
├── main.py                     # API FastAPI que consulta a Prolog
├── static/index.html           # Interfaz web
├── Dockerfile                  # Imagen con SWI-Prolog + Python
├── requirements.txt
└── .gitignore
```

---

## Declaración de uso de IA

Se usó **Claude Code (Anthropic)** para la interfaz web, la integración frontend-backend (`main.py`), el `Dockerfile` y el despliegue en Render, la ejecución de pruebas y la redacción de la documentación. Claude Code no escribió, completó ni corrigió el archivo `diagnostico_automotriz.pl`.

Base de conocimientos (`diagnostico_automotriz.pl`): _[completar con honestidad cómo se elaboró y si se usó alguna herramienta de IA]_.
