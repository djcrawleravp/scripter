#!/bin/bash

# 1. Importar la librería (asegúrate de que ambos archivos estén en la misma carpeta)
source ./printimir.sh

echo "Iniciando configuración del servidor..."
echo "----------------------------------------"

# --- MÉTODO 1: La forma automática (Recomendada para comandos simples) ---
# run_step "Mensaje si falla" comando_a_ejecutar

run_step "Falló al actualizar repositorios" sudo apt-get update -y
run_step "Falló al instalar paquetes básicos" sudo apt-get install -y curl git jq htop


# --- MÉTODO 2: La forma manual (Para procesos complejos de varias líneas) ---

print_wait

# Aquí puedes poner lógica compleja, bucles, o cosas que no son un solo comando
sleep 6 # Simulando un proceso largo
if [ -x "$(command -v curl)" ]; then
    wait_stop
    print_done "Curl está listo y verificado"
else
    wait_stop
    print_error "Curl no se instaló correctamente"
    exit 1
fi

echo "----------------------------------------"
echo "¡Todo chalinga, proceso terminado!"