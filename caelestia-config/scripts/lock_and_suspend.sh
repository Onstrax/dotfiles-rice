#!/usr/bin/env bash
set -euo pipefail

# Si ya está bloqueado, no necesitamos volver a bloquear.
state="$(caelestia shell lock isLocked 2>/dev/null || true)"

if [[ "$state" != "true" ]]; then
    caelestia shell lock lock
fi

# Esperar a que Caelestia confirme el bloqueo.
for _ in {1..30}; do
    state="$(caelestia shell lock isLocked 2>/dev/null || true)"

    if [[ "$state" == "true" ]]; then
        systemctl suspend
        exit $?
    fi

    sleep 0.1
done

echo "No se confirmó el bloqueo de Caelestia. Suspensión cancelada." >&2
exit 1
