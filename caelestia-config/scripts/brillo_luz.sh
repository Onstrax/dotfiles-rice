#!/usr/bin/env bash
set -euo pipefail

# Control de iluminación con Home Assistant
# Credenciales almacenadas fuera del repositorio.

TOKEN_FILE="$HOME/.config/homeassistant-rice/token"
ENTITY="light.juanes"
URL="http://localhost:8123/api/services/light/turn_on"

if [[ ! -r "$TOKEN_FILE" ]]; then
    echo "No se puede leer el token privado de Home Assistant" >&2
    exit 1
fi

# Atajos Ctrl + Shift + 1...9 y 0
# Porcentajes acordes con los comentarios originales.
case "${1:-}" in
    1) BRILLO=0 ;;
    2) BRILLO=1 ;;
    3) BRILLO=20 ;;
    4) BRILLO=30 ;;
    5) BRILLO=40 ;;
    6) BRILLO=50 ;;
    7) BRILLO=60 ;;
    8) BRILLO=70 ;;
    9) BRILLO=80 ;;
    0) BRILLO=100 ;;
    *)
        echo "Uso: brillo_luz.sh [0-9]" >&2
        exit 2
        ;;
esac

# El nivel 1 significa apagar por completo.
if [[ "${1:-}" == "1" ]]; then
    URL="http://localhost:8123/api/services/light/turn_off"
fi

IFS= read -r TOKEN < "$TOKEN_FILE"

if [[ -z "$TOKEN" ]]; then
    echo "El token está vacío" >&2
    exit 1
fi

if [[ "${1:-}" == "1" ]]; then
    PAYLOAD="$(jq -nc --arg entity_id "$ENTITY" \
        '{entity_id: $entity_id}')"
else
    PAYLOAD="$(jq -nc \
        --arg entity_id "$ENTITY" \
        --argjson brightness "$BRILLO" \
        '{entity_id: $entity_id, brightness_pct: $brightness}')"
fi

# El token se entrega por stdin, no como argumento
# visible directamente en la línea de comandos de curl.
printf 'header = "Authorization: Bearer %s"\n' "$TOKEN" |
    curl --config - \
        --silent --show-error --fail-with-body \
        --connect-timeout 3 \
        --max-time 10 \
        --request POST \
        --url "$URL" \
        --header "Content-Type: application/json" \
        --data "$PAYLOAD"
