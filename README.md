# INFRAESTRUCTURA DE KIOSCO DIGITAL HARDENED (DEBIAN 12 / XFCE)

Este repositorio contiene la configuración real, verificada y auditada para el despliegue de una terminal pública automatizada y securizada a nivel de Kernel y Bootloader.

## 🛠️ Componentes Clave

* **Seguridad de Arranque (GRUB):** Blindaje del gestor de arranque mediante credenciales PBKDF2 (SHA512) para evitar la inyección de parámetros y accesos no autorizados en modo recuperación.
* **Hardening de Kernel (MAC):** Confinamiento estricto de procesos mediante perfiles de AppArmor aplicados a los scripts de inicio, bloqueando de raíz el uso de terminales físicas o shells secundarias (`bash`, `dash`, `xterm`) para mitigar escapes del entorno.
* **Gestión de Sesiones (LightDM):** Autologin restringido con scripts de auto-reparación (hooks) que purgan el espacio de trabajo del usuario en cada inicio y cierre de sesión.
* **Sesión Volátil Limpia:** Automatización del navegador Chromium forzado en modo incógnito, maximizado y sin persistencia de estados de sesión previa para garantizar la privacidad absoluta entre usuarios concurrentes.
* **Interoperabilidad Híbrida (VirtualBox CLI):** Despliegue de una sesión X11 nativa y dedicada para inicializar instancias virtuales Windows a pantalla completa sin cargar el escritorio subyacente de Linux.
* **Inclusión Universal Automatizada:** Integración de la suite asistencial nativa (`Orca` y `Onboard`) directamente en el arranque global XDG.

---

## 📁 Estructura del Repositorio

El proyecto se organiza en las siguientes capas de configuración estructural:

```text
debian-kiosk-hardening/
├── accessibility/
│   ├── onboard-autostart.desktop      # Lanzador global para el teclado en pantalla
│   └── orca-autostart.desktop         # Lanzador global para el lector de voz Orca
├── apparmor/
│   └── usr.local.bin.iniciar_chromium.sh  # Perfil de confinamiento de seguridad
├── chromium/
│   └── policies.json                  # Directivas Enterprise para securizar el navegador (bloqueos)
├── grub/
│   └── 40_custom                      # Reglas y credenciales cifradas PBKDF2 para el bootloader
├── lightdm/
│   └── lightdm.conf                   # Reglas de autologin y hooks de limpieza
├── scripts/
│   ├── iniciar_chromium.sh            # Orquestador del modo quiosco web
│   ├── lanzar_windows_shared.sh       # Despliegue e inicio de la MV Windows mediante VBoxManage
│   ├── limpiar_quiosco.sh             # Script de desinfección y auto-reparación de accesos
│   └── sesion_directa_windows.sh      # Wrapper para mantener viva la sesión gráfica de la MV
└── windows_session/
    ├── windows                        # Perfil de inyección en AccountsService
    └── windows-vm.desktop             # Definición de la sesión X11 pura

🚀 Instrucciones de Despliegue en la MV
💡 Nota: Estos comandos sirven para replicar el entorno completo desde cero en una instalación limpia de Debian o para el despliegue automatizado en nuevas terminales.

1. Instalación de Scripts y Permisos de Ejecución
Copia todos los automatismos a la ruta de ejecutables del sistema y asígnales los permisos obligatorios:

sudo cp scripts/*.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/iniciar_chromium.sh
sudo chmod +x /usr/local/bin/lanzar_windows_shared.sh
sudo chmod +x /usr/local/bin/limpiar_quiosco.sh
sudo chmod +x /usr/local/bin/sesion_directa_windows.sh

2. Configuración del Gestor de Sesiones (LightDM)
Aplica la configuración para habilitar el autologin del perfil público y los hooks de desinfección:

sudo cp lightdm/lightdm.conf /etc/lightdm/lightdm.conf

3. Despliegue de la Sesión X11 Dedicada para Windows
Registra la sesión personalizada y fírmala al usuario técnico de virtualización:

sudo cp windows_session/windows-vm.desktop /usr/share/xsessions/
sudo mkdir -p /var/lib/AccountsService/users/
sudo cp windows_session/windows /var/lib/AccountsService/users/
sudo systemctl restart accounts-daemon

4. Blindaje del Gestor de Arranque (GRUB)
Aplica las restricciones de superusuario para bloquear la edición del menú de arranque:


sudo cp grub/40_custom /etc/grub.d/40_custom
sudo chmod +x /etc/grub.d/40_custom
sudo update-grub

5. Implementación de Seguridad con AppArmor y UFW
Aplica el perfil de confinamiento del navegador y activa el cortafuegos local denegando el tráfico entrante:

sudo cp apparmor/usr.local.bin.iniciar_chromium.sh /etc/apparmor.d/
sudo systemctl reload apparmor
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable

6. Políticas de Chromium e inicio automático (XDG)
Despliega las restricciones de navegación y los lanzadores de accesibilidad:

sudo mkdir -p /etc/chromium/policies/managed/
sudo cp chromium/policies.json /etc/chromium/policies/managed/policies.json
sudo cp accessibility/*.desktop /etc/xdg/autostart/


🔄 Instrucciones de Levantamiento y Verificación
Una vez realizado el despliegue, utiliza los siguientes comandos para verificar el correcto levantamiento de los servicios o forzar su ejecución manual:

1. Verificar el Confinamiento de Seguridad (AppArmor)
Para comprobar que el perfil de AppArmor se ha cargado correctamente en el Kernel y está protegiendo activamente el script de Chromium:

sudo apparmor_status | grep iniciar_chromium

2. Levantamiento Manual del Entorno Quiosco (Chromium)
Si necesitas realizar pruebas de carga gráfica o levantar el navegador de forma manual bajo las variables de accesibilidad inyectadas:

/usr/local/bin/iniciar_chromium.sh

3. Levantamiento y Registro Forzado de la MV Windows
Si la máquina virtual anidada de Windows no arranca automáticamente o deseas verificar su inicialización desatendida desde la CLI de VirtualBox:

/usr/local/bin/lanzar_windows_shared.sh

4. Monitoreo de Procesos en Ejecución
Para auditar en caliente que toda la infraestructura del quiosco (Navegador, Teclado, Lector de voz y VirtualBox) se encuentra levantada en la sesión actual:

ps aux | grep -E "chromium|onboard|orca|VBoxHeadless|VirtualBox"