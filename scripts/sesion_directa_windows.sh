#!/bin/bash
# =====================================================================
# Nombre: sesion_directa_windows.sh
# Descripción: Wrapper que mantiene viva la sesión de LightDM con la VM
# =====================================================================

# 1. Ejecuta el cargador de la máquina virtual con ruta absoluta
/usr/local/bin/lanzar_windows_shared.sh 

# 2. Bucle de control: Mantiene la sesión ocupada mientras la ventana esté abierta
while pgrep -f "VirtualBoxVM --startvm Windows" > /dev/null; do 
    sleep 2 [cite: 127]
done 

exit 0
