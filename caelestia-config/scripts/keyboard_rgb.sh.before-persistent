#!/bin/bash

# Archivo temporal para guardar el estado actual
STATE_FILE="/tmp/msi_rgb_state"

# Si el archivo no existe, empezar en 0
if [ ! -f "$STATE_FILE" ]; then
    echo 0 > "$STATE_FILE"
fi

STATE=$(cat "$STATE_FILE")

case $STATE in
    0)
        msi-perkeyrgb --model ge63 -p chakra
        echo 1 > "$STATE_FILE"
        ;;
    1)
        msi-perkeyrgb --model ge63 -p disco
        echo 2 > "$STATE_FILE"
        ;;
    2)
        msi-perkeyrgb --model ge63 -p aqua
        echo 3 > "$STATE_FILE"
        ;;
    3)
        msi-perkeyrgb --model ge63 -s e0feff
        echo 4 > "$STATE_FILE"
        ;;
    4)
        msi-perkeyrgb --model ge63 -s 818484
        echo 0 > "$STATE_FILE"
        ;;
esac
