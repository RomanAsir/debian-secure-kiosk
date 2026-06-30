# INFRAESTRUCTURA DE KIOSCO DIGITAL HARDENED (DEBIAN 12 / XFCE)

Este repositorio contiene la configuración real, verificada y auditada para el despliegue de una terminal pública automatizada y securizada a nivel de Kernel y Bootloader, adaptada específicamente para entornos de acceso público en bibliotecas.

## 🛡️ Componentes Clave

* **Seguridad de Arranque (GRUB):** Blindaje del gestor de arranque mediante credenciales PBKDF2 (SHA512) para solicitar contraseña de administrador antes de escribir código o modificar parámetros en modo recuperación.
* **Hardening de Kernel (MAC):** Confinamiento estricto de procesos mediante perfiles de AppArmor aplicados a los scripts de inicio, bloqueando de raíz el uso de terminales físicas o shells secundarias (`bash`, `dash`, `xterm`) para mitigar escapes del entorno.
* **Segregación de Usuarios (3 Perfiles Críticos):**
  * `root`: Superusuario global que custodia los automatismos de seguridad.
  * `instalaciones`: Cuenta técnica de administración ordinaria con privilegios `sudo` y contraseña obligatoria.
  * `biblioteca`: Usuario público sin privilegios administrativos y con inicio de sesión automático (`Autologin`) sin contraseña.
* **Efimeridad y Persistencia Selectiva:** Todo el entorno de trabajo del usuario público se destruye por completo en cada cierre de sesión (purga absoluta de datos residuales, descargas e historial). Se preserva única y exclusivamente una carpeta aislada de Guardado Permanente enlazada lógicamente en el escritorio.
* **Sesión Volátil de Chromium:** Autoarranque del navegador forzado en modo incógnito, maximizado, con políticas Enterprise aplicadas y sin persistencia de credenciales o estados en internet al salir.
* **Doble Vía de Acceso a Windows (VirtualBox CLI):** Ejecución flexible de la máquina virtual invitada a pantalla completa mediante dos métodos manuales:
  * **Desde el Escritorio:** Mediante un acceso directo auto-regenerado dinámicamente en el entorno XFCE del usuario `biblioteca`.
  * **Desde el Menú de Selección (Sin sesión iniciada):** Directamente desde la pantalla de bienvenida de LightDM, seleccionando la sesión X11 pura (`windows-vm`) que inicializa el hipervisor de forma dedicada sin cargar el escritorio de Linux.
* **Inclusión Universal Automatizada:** Integración de la suite asistencial nativa (`Orca` para lectura de voz, `Onboard` para teclado en pantalla, lupa `Magnus` y herramientas ofimáticas) en el arranque global XDG.

---

## 📂 Estructura del Repositorio

El proyecto se organiza en las siguientes capas de configuración estructural:

```text
debian-kiosk-hardening/
├── accessibility/
│   ├── onboard-autostart.desktop      # Lanzador global para el teclado en pantalla
│   └── orca-autostart.desktop         # Lanzador global para el lector de voz Orca
├── apparmor/
│   └── usr.local.bin.iniciar_chromium.sh  # Perfil de confinamiento de seguridad para Chromium
├── chromium/
│   └── kiosk_policy.json              # Directivas Enterprise para securizar el navegador (bloqueos)
├── grub/
│   └── 40_custom                      # Reglas y credenciales cifradas PBKDF2 para el bootloader
├── lightdm/
│   └── lightdm.conf                   # Reglas de autologin y hooks de limpieza (Pre/Post sesión)
├── scripts/
│   ├── iniciar_chromium.sh            # Orquestador del modo quiosco web (Modo Incógnito)
│   ├── lanzar_windows_shared.sh       # Despliegue e inicio de la MV Windows mediante VBoxManage
│   ├── limpiar_quiosco.sh             # Script de desinfección profunda y auto-reparación de accesos
│   └── sesion_directa_windows.sh      # Wrapper para mantener viva la sesión gráfica pura de la MV
└── windows_session/
    └── windows-vm.desktop             # Definición de la sesión X11 pura para el selector de LightDM


🚀 Instrucciones de Despliegue
⚠️ Nota: Estos comandos sirven para replicar el entorno completo desde cero en una instalación limpia de Debian o para el despliegue automatizado en nuevas terminales.

1. Instalación de Scripts y Permisos de Ejecución
Copia todos los automatismos a la ruta de ejecutables del sistema y asígnales los permisos obligatorios de ejecución:


sudo cp scripts/*.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/iniciar_chromium.sh
sudo chmod +x /usr/local/bin/lanzar_windows_shared.sh
sudo chmod +x /usr/local/bin/limpiar_quiosco.sh
sudo chmod +x /usr/local/bin/sesion_directa_windows.sh

2. Configuración del Gestor de Sesiones (LightDM)
Aplica las directivas para habilitar el autologin del perfil público y los hooks que ejecutan la limpieza total antes y después de cada sesión:

sudo cp lightdm/lightdm.conf /etc/lightdm/lightdm.conf

3. Implementación de los Accesos a Windows (Selector X11)
El acceso directo del escritorio ahora es auto-generado por el script de limpieza. Solo necesitas registrar el método de lanzamiento independiente en la pantalla de login:

# Registrar la sesión X11 pura en el menú global de LightDM
sudo cp windows_session/windows-vm.desktop /usr/share/xsessions/

4. Matriz de Persistencia Aislada (Carpeta Permanente)
Crea el único punto del sistema inmune a la desinfección y enlázalo en el escritorio del usuario público:

sudo mkdir -p /opt/datos_permanentes
sudo chown -R biblioteca:biblioteca /opt/datos_permanentes
sudo chmod 775 /opt/datos_permanentes

# Crear el enlace simbólico dinámico
mkdir -p /home/biblioteca/Escritorio
ln -sf /opt/datos_permanentes /home/biblioteca/Escritorio/Guardado_Permanente
sudo chown -R biblioteca:biblioteca /home/biblioteca/Escritorio

5. Blindaje del Gestor de Arranque (GRUB)
Aplica las restricciones de superusuario para bloquear la edición de líneas de comandos en el arranque:

sudo cp grub/40_custom /etc/grub.d/40_custom
sudo chmod +x /etc/grub.d/40_custom
sudo update-grub

6. Configuración de Seguridad (AppArmor y UFW)
Carga el perfil de confinamiento del navegador en el Kernel para impedir la ejecución lateral de terminales y activa el cortafuegos denegando todo tráfico entrante:

sudo cp apparmor/usr.local.bin.iniciar_chromium.sh /etc/apparmor.d/
sudo systemctl reload apparmor
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable

7. Directivas de Chromium y Arranque Asistencial (XDG)
Despliega las políticas Enterprise de navegación restrictiva y los lanzadores automáticos de accesibilidad:

sudo mkdir -p /etc/chromium/policies/managed/
sudo cp chromium/kiosk_policy.json /etc/chromium/policies/managed/kiosk_policy.json
sudo cp accessibility/*.desktop /etc/xdg/autostart/

🔍 Instrucciones de Levantamiento y Verificación
Utiliza los siguientes comandos para auditar el correcto funcionamiento de los servicios o forzar su ejecución en fase de pruebas:

 Verificar el Confinamiento de Seguridad (AppArmor)
Comprueba que el perfil del Kernel está interceptando correctamente el proceso y bloqueando los escapes a terminales de comandos:

sudo apparmor_status | grep iniciar_chromium

Verificación Manual del Script de Desinfección
Fuerza la ejecución del script de limpieza para comprobar el vaciado completo del directorio $HOME y la correcta regeneración del enlace permanente y los iconos del catálogo:

sudo /usr/local/bin/limpiar_quiosco.sh

Lanzamiento Desatendido de la MV Windows (CLI)
Prueba el comportamiento de inicialización directa y registro automático en VirtualBox de la máquina virtualizada:

/usr/local/bin/lanzar_windows_shared.sh

Monitoreo Activo de Procesos
Audita en tiempo real que los componentes críticos autorizados se ejecutan de manera correcta en el espacio de usuario:

ps aux | grep -E "chromium|onboard|orca|VBoxHeadless|VirtualBox"