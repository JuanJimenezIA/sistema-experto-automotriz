FROM python:3.11-slim

# Instalar SWI-Prolog oficial del sistema
RUN apt-get update && \
    apt-get install -y swi-prolog && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copiar e instalar dependencias de Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar el archivo de Prolog, la API y la carpeta estática
COPY prueba.pl .
COPY main.py .
COPY static ./static

# Puerto expuesto por el contenedor
EXPOSE 8000

# Comando de arranque para producción
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]