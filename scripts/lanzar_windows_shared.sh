#!/bin/bash
# =====================================================================
# Nombre: lanzar_windows_shared.sh
# Descripción: Inicializador seguro y auto-reparable de la VM Windows
# =====================================================================

# Comprobar si la máquina está registrada en el perfil actual
if ! /usr/bin/VBoxManage list vms | grep -q '"Windows"'; then
    /usr/bin/VBoxManage registervm "/opt/virtualbox_vms/Windows/Windows.vbox" 2>/dev/null
fi

# Iniciar la máquina virtual en modo interfaz gráfica dedicado
/usr/bin/VBoxManage startvm "Windows" --type gui
