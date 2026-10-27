# Sistema Experto de Diagnóstico Automotriz

**Instituto Politécnico Nacional**  
**Escuela Superior de Cómputo (ESCOM)**  
**Unidad de Aprendizaje:** Paradigmas de Programación  
**Paradigma:** Programación Lógica | **Lenguaje:** SWI-Prolog  

---

## 🌐 Aplicación en Producción
La aplicación se encuentra desplegada y disponible públicamente en Internet:
* **URL:** [https://sistema-experto-automotriz.onrender.com](https://sistema-experto-automotriz.onrender.com)

---

## 📋 Descripción del Proyecto
Sistema experto basado en programación declarativa que atiende la problemática cotidiana de identificación preliminar de fallas automotrices. A partir de síntomas reportados por el conductor (en subsistemas eléctrico, de frenos y motor), el motor de inferencia evalúa reglas lógicas para determinar la causa raíz, la gravedad de la avería, la pieza involucrada y las acciones correctivas sugeridas.

---

## 🏗️ Arquitectura Técnica
El sistema implementa una arquitectura desacoplada en tres capas contenidas en un contenedor Docker:
1. **Frontend:** Interfaz web desarrollada con HTML5, Tailwind CSS y JavaScript asíncrono para el envío y recepción de datos.
2. **Servicio Web / API:** Backend en Python utilizando FastAPI, encargado de validar las entradas, formular las consultas lógicas a Prolog y estructurar las respuestas en formato JSON.
3. **Motor de Inferencia:** SWI-Prolog ejecutando la base de conocimientos (`diagnostico_automotriz.pl`), aplicando unificación, variables lógicas y retroceso (backtracking) para resolver múltiples conclusiones simultáneas.

---

## 💻 Instrucciones de Instalación y Ejecución Local

### Prerrequisitos
* SWI-Prolog instalado y disponible en el `PATH` del sistema.
* Python 3.11+.
* Git.

### Pasos para ejecución local
1. Clonar el repositorio:
   ```bash
   git clone [https://github.com/JuanJimenezIA/sistema-experto-automotriz.git](https://github.com/JuanJimenezIA/sistema-experto-automotriz.git)
   cd sistema-experto-automotriz