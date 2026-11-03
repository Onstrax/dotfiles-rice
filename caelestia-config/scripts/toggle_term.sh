#!/usr/bin/env bash
set -euo pipefail

# Terminal scratchpad personal
# Clase: scratchpad
# Workspace: special:term

exists="$(
    hyprctl clients -j |
    jq -r '[.[] | select(.class == "scratchpad")] | length'
)"

if [[ "$exists" -gt 0 ]]; then
    # Mostrar u ocultar la terminal existente
    hyprctl dispatch 'hl.dsp.workspace.toggle_special("term")'
else
    # Mostrar el workspace especial
    hyprctl dispatch 'hl.dsp.workspace.toggle_special("term")'

    # Abrir una terminal nueva
    hyprctl dispatch 'hl.dsp.exec_cmd("foot --app-id=scratchpad fish")'
fi
