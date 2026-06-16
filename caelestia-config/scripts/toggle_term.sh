#!/bin/bash

# Buscamos una ventana de foot que tenga el app-id "scratchpad"
if hyprctl clients | grep -q "class: scratchpad"
then
    # Si existe esa ventana específica, alternamos el espacio
    hyprctl dispatch togglespecialworkspace term
else
    # Si no existe, la creamos con el id "scratchpad"
    hyprctl dispatch exec "[workspace special:term]" "foot --app-id=scratchpad fish"
fi
