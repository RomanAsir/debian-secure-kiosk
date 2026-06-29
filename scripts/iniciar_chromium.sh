#!/bin/bash
if [ "$USER" = "biblioteca" ]; then
    sleep 2
    # Forzar módulos de accesibilidad
    export GTK_MODULES=gail:atk-bridge
    export QT_ACCESSIBILITY=1

    # Arranca una sola vez y de forma normal (permitiendo cerrar la ventana)
    chromium --start-maximized --incognito --no-first-run --disable-restore-session-state --force-renderer-accessibility https://google.com
fi