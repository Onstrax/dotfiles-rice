#!/bin/bash
# $1 es la clase de la ventana, $2 es el nombre del lanzador
if hyprctl clients | grep -q "class: $1"; then
    hyprctl dispatch focuswindow class:"$1"
else
    gtk-launch "$2"
fi
