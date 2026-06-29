#!/bin/bash
# Comprobar si la máquina está registrada en el perfil actual usando las mayúsculas correctas
if ! VBoxManage list vms | grep -q '"Windows"'; then
    VBoxManage registervm "/opt/virtualbox_vms/Windows/Windows.vbox" 2>/dev/null
fi

# Iniciar la máquina virtual
VBoxManage startvm "Windows" --type gui