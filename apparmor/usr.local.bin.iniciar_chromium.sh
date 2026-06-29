#include <tunables/global>

/usr/local/bin/iniciar_chromium.sh {
  #include <abstractions/base>
  #include <abstractions/bash>

  /usr/local/bin/iniciar_chromium.sh r,
  /bin/bash ix,
  /usr/bin/chromium Ux,
  /usr/bin/chromium-browser Ux,

  # Denegar explícitamente cualquier intento de abrir terminales reales desde aquí
  deny /usr/bin/xfce4-terminal x,
  deny /usr/bin/gnome-terminal x,
  deny /usr/bin/xterm x,
  deny /bin/dash x,
}