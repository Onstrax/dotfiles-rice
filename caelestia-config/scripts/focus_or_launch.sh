#!/usr/bin/env bash

# Uso:
# focus_or_launch.sh 'regex_de_clase' comando [argumentos...]

set -euo pipefail

if (( $# < 2 )); then
    echo "Uso: $0 REGEX_CLASE COMANDO [ARGUMENTOS...]" >&2
    exit 2
fi

class_pattern="$1"
shift

# Buscar una ventana existente por su clase.
address="$(
    hyprctl clients -j |
    jq -r --arg pattern "$class_pattern" '
        [
            .[]
            | select((.class // "") | test($pattern))
            | .address
        ][0] // empty
    '
)"

if [[ -n "$address" ]]; then
    # Enfocar la ventana existente.
    # Hyprland se encarga de cambiar al workspace correspondiente.
    hyprctl dispatch \
        "hl.dsp.focus({ window = 'address:${address}' })"
else
    # Abrir una nueva instancia.
    # Las reglas de workspace deciden su ubicación.
    exec "$@"
fi
