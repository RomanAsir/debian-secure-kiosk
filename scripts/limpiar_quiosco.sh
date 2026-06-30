#!/bin/bash
# =====================================================================
# Nombre: limpiar_quiosco.sh
# Descripción: Hook de desinfección total y regeneración de entorno
# =====================================================================

USUARIO_KIOSCO="biblioteca"
HOME_KIOSCO="/home/$USUARIO_KIOSCO"

if [ "$EUID" -ne 0 ]; then
  echo "[-] Este script debe ejecutarse como root"
  exit 1
fi

echo "[*] Iniciando desinfección del entorno del quiosco..."

# 1. Matar procesos residuales del usuario público
pkill -u "$USUARIO_KIOSCO" 2>/dev/null
sleep 1

# 2. PURGA: Vaciado del espacio de trabajo preservando la estructura base
find "$HOME_KIOSCO" -mindepth 1 -maxdepth 1 ! -name 'Escritorio' -exec rm -rf {} +
find "$HOME_KIOSCO/Escritorio" -mindepth 1 -maxdepth 1 ! -name 'Guardado_Permanente' -exec rm -rf {} +

# 3. AUTO-REPARACIÓN: Reconstrucción del enlace permanente si fue alterado
if [ ! -L "$HOME_KIOSCO/Escritorio/Guardado_Permanente" ]; then
    rm -f "$HOME_KIOSCO/Escritorio/Guardado_Permanente"
    ln -sf /opt/datos_permanentes "$HOME_KIOSCO/Escritorio/Guardado_Permanente"
fi

# 4. INYECCIÓN DE ACCESOS DIRECTOS (Regeneración post-purga)
echo "[*] Restaurando accesos directos de aplicaciones..."
cp /usr/share/applications/libreoffice-startcenter.desktop "$HOME_KIOSCO/Escritorio/Ofimatica.desktop" 2>/dev/null
cp /usr/share/applications/magnus.desktop "$HOME_KIOSCO/Escritorio/Lupa.desktop" 2>/dev/null
cp /usr/share/applications/onboard.desktop "$HOME_KIOSCO/Escritorio/Teclado_Pantalla.desktop" 2>/dev/null

# Crear el acceso a la máquina virtual al vuelo
cat << 'EOF' > "$HOME_KIOSCO/Escritorio/windows-virtual.desktop"
[Desktop Entry]
Name=Windows VM
Comment=Lanzador de Máquina Virtual Windows
Exec=/usr/local/bin/lanzar_windows_shared.sh
Icon=virtualbox
Terminal=false
Type=Application
EOF

# 5. RESTAURACIÓN DE PERMISOS Y CONFIANZA XFCE
# Asignar propiedad correcta de todo el HOME
chown -R "$USUARIO_KIOSCO:$USUARIO_KIOSCO" "$HOME_KIOSCO"

# Hacer los archivos ejecutables
chmod +x "$HOME_KIOSCO"/Escritorio/*.desktop 2>/dev/null

# Forzar la firma de confianza para que el escritorio XFCE los muestre sin advertencias
for app in "$HOME_KIOSCO"/Escritorio/*.desktop; do
    sudo -u "$USUARIO_KIOSCO" gio set "$app" metadata::trusted true 2>/dev/null
done

echo "[+] Entorno desinfectado y restaurado con éxito."
exit 0
