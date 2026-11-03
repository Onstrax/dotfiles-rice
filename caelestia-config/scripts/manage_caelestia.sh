#!/usr/bin/env bash
set -euo pipefail

LAUNCHER="$HOME/.local/bin/start-caelestia.fish"

stop_shell() {
    if qs -c caelestia kill; then
        echo "Caelestia detenida."
    else
        echo "No se encontró una instancia activa de Caelestia." >&2
    fi
}

start_shell() {
    if [[ ! -x "$LAUNCHER" ]]; then
        echo "ERROR: No se encontró el lanzador: $LAUNCHER" >&2
        return 1
    fi

    "$LAUNCHER"
}

case "${1:-}" in
    stop)
        stop_shell
        ;;
    start)
        start_shell
        ;;
    restart)
        if [[ ! -x "$LAUNCHER" ]]; then
            echo "ERROR: Lanzador no disponible. Se cancela el reinicio." >&2
            exit 1
        fi

        qs -c caelestia kill

        # Dar tiempo a que Quickshell cierre la instancia.
        sleep 1

        start_shell
        ;;
    *)
        echo "Uso: $0 {start|stop|restart}" >&2
        exit 2
        ;;
esac
