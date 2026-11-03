#!/usr/bin/env bash
set -euo pipefail

# ==========================================
# Rotar favoritos de Home Assistant
# ==========================================

ENTITY="light.juanes"
CONTAINER="homeassistant"

TOKEN_FILE="$HOME/.config/homeassistant-rice/token"
URL="http://localhost:8123/api/services/light/turn_on"

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/homeassistant-rice"
STATE_FILE="$STATE_DIR/color-index"
LOCK_FILE="$STATE_DIR/color.lock"

mkdir -p "$STATE_DIR"
chmod 700 "$STATE_DIR"

# Evitar pulsaciones simultáneas
exec 9>"$LOCK_FILE"
flock -x 9

if [[ ! -r "$TOKEN_FILE" ]]; then
    echo "No se encontró el token privado" >&2
    exit 1
fi

# Leer los favoritos actuales de Home Assistant
FAVORITES="$(
    docker exec "$CONTAINER" \
        cat /config/.storage/core.entity_registry |
    jq -c --arg entity "$ENTITY" '
        [
            .data.entities[]
            | select(.entity_id == $entity)
            | .options.light.favorite_colors // []
        ][0] // []
    '
)"

COUNT="$(jq -r 'length' <<< "$FAVORITES")"

if (( COUNT == 0 )); then
    echo "No se encontraron favoritos para $ENTITY" >&2
    exit 1
fi

# Leer índice anterior
INDEX=-1

if [[ -f "$STATE_FILE" ]]; then
    read -r INDEX < "$STATE_FILE" || INDEX=-1
fi

if ! [[ "$INDEX" =~ ^-?[0-9]+$ ]] ||
   (( INDEX < -1 || INDEX >= COUNT )); then
    INDEX=-1
fi

# Avanzar circularmente
NEXT=$(( (INDEX + 1) % COUNT ))

# Construir petición con los valores reales
# del favorito seleccionado.
PAYLOAD="$(
    jq -nc \
        --arg entity "$ENTITY" \
        --argjson index "$NEXT" \
        --argjson favorites "$FAVORITES" '
        ($favorites[$index]
            | {
                rgb_color,
                hs_color,
                xy_color,
                color_temp_kelvin,
                brightness_pct,
                brightness
              }
            | with_entries(select(.value != null))
        ) + {entity_id: $entity}
    '
)"

# Leer credencial privada
IFS= read -r TOKEN < "$TOKEN_FILE"

if [[ -z "$TOKEN" ]]; then
    echo "Token vacío" >&2
    exit 1
fi

# Aplicar el favorito
printf 'header = "Authorization: Bearer %s"\n' "$TOKEN" |
    curl --config - \
        --silent --show-error --fail-with-body \
        --output /dev/null \
        --connect-timeout 3 \
        --max-time 10 \
        --request POST \
        --url "$URL" \
        --header "Content-Type: application/json" \
        --data "$PAYLOAD"

# Guardar índice solo después de una petición exitosa
printf '%s\n' "$NEXT" > "$STATE_FILE"

echo "Favorito aplicado: $NEXT de $((COUNT - 1))"
