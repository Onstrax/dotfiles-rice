#!/usr/bin/env bash

# Obsidian: enfocar si existe; abrir en workspace 5 si no.

address="$(
    hyprctl clients -j |
    jq -r '
        [.[] |
        select(
            (.class // "" | ascii_downcase | contains("obsidian"))
        )] | first | .address // empty
    '
)"

if [[ -n "$address" ]]; then
    # Enfocar la ventana existente, aunque esté en otro workspace
    hyprctl dispatch "hl.dsp.focus({ window = 'address:${address}' })"
else
    # Cambiar al workspace 5
    hyprctl dispatch 'hl.dsp.focus({ workspace = "5" })'

    # Iniciar Obsidian con la nueva API
    hyprctl dispatch 'hl.dsp.exec_cmd("obsidian")'
fi
