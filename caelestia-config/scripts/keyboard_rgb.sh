#!/usr/bin/env bash
set -euo pipefail
umask 077

# ==========================================
# Control persistente del teclado RGB MSI
# ==========================================

MODEL="ge63"

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/msi-rgb"
STATE_FILE="$STATE_DIR/state"
LOCK_FILE="$STATE_DIR/lock"

mkdir -p "$STATE_DIR"
chmod 700 "$STATE_DIR"

# Evitar modificaciones simultáneas del estado
exec 9>"$LOCK_FILE"
flock -x 9

# Identificar el arranque actual
BOOT_ID="$(cat /proc/sys/kernel/random/boot_id)"

# Estado inicial:
# -1 = ningún efecto elegido todavía
# off = iluminación apagada
INDEX=-1
POWER="off"
SAVED_BOOT=""

if [[ -f "$STATE_FILE" ]]; then
    read -r INDEX POWER SAVED_BOOT < "$STATE_FILE" || true
fi

# Validar el estado almacenado
if ! [[ "$INDEX" =~ ^-?[0-9]+$ ]] ||
   (( INDEX < -1 || INDEX > 4 )); then
    INDEX=-1
fi

if [[ "$POWER" != "on" && "$POWER" != "off" ]]; then
    POWER="off"
fi

MODE="${1:-next}"

save_state() {
    local tmp
    tmp="$(mktemp "$STATE_DIR/state.XXXXXX")"
    printf '%s %s %s\n' "$INDEX" "$POWER" "$BOOT_ID" > "$tmp"
    mv -f "$tmp" "$STATE_FILE"
}

case "$MODE" in
    off)
        # F7: apagar sin olvidar el último efecto
        msi-perkeyrgb --model "$MODEL" -s 000000

        POWER="off"
        save_state

        echo "RGB apagado. Último efecto conservado: $INDEX"
        exit 0
        ;;

    next)
        # Primera ejecución: comenzar con Chakra
        if (( INDEX == -1 )); then
            INDEX=0

        # Si estaba apagado, restaurar el último efecto
        elif [[ "$POWER" == "off" ]]; then
            :

        # Después de reiniciar, restaurar en lugar
        # de saltar al siguiente efecto
        elif [[ "$SAVED_BOOT" != "$BOOT_ID" ]]; then
            :

        # Si ya estaba encendido, avanzar
        else
            INDEX=$(( (INDEX + 1) % 5 ))
        fi
        ;;

    *)
        echo "Uso: $0 [next|off]" >&2
        exit 2
        ;;
esac

# Aplicar efecto seleccionado
case "$INDEX" in
    0)
        NAME="Chakra"
        msi-perkeyrgb --model "$MODEL" -p chakra
        ;;
    1)
        NAME="Disco"
        msi-perkeyrgb --model "$MODEL" -p disco
        ;;
    2)
        NAME="Aqua"
        msi-perkeyrgb --model "$MODEL" -p aqua
        ;;
    3)
        NAME="Blanco hielo"
        msi-perkeyrgb --model "$MODEL" -s e0feff
        ;;
    4)
        NAME="Gris"
        msi-perkeyrgb --model "$MODEL" -s 818484
        ;;
esac

# Guardar únicamente después de aplicar el efecto
POWER="on"
save_state

echo "RGB activo: $NAME (índice $INDEX)"
