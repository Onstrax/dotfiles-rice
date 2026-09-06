#!/bin/bash

# Comprobamos si hay alguna ventana con la clase "obsidian"
if hyprctl clients | grep -q "class: md.obsidian.Obsidian"
then
    # Si ya está abierto, viajamos al workspace 5
    hyprctl dispatch workspace 5
else
    # Si no está abierto, lo lanzamos en el workspace 5 de forma silent
    hyprctl dispatch exec "[workspace 5 silent]" "obsidian"
fi
