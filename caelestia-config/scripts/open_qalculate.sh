#!/usr/bin/env bash
set -euo pipefail

# ==========================================
# Qalculate: ventanas escalonadas
# ==========================================

# Desplazamiento por ventana, en píxeles
STEP=35

# Máximo de niveles de desplazamiento
MAX_STEPS=4

# Evitar aperturas simultáneas que calculen
# el mismo número de ventanas.
LOCK_FILE="${XDG_RUNTIME_DIR:-/tmp}/qalculate-cascade-${UID}.lock"

exec 9>"$LOCK_FILE"
flock -x 9

# Capturar las direcciones de las calculadoras actuales
BEFORE="$(
    hyprctl clients -j |
    jq -c '
        [
            .[]
            | select((.class // "") | test("qalculate"; "i"))
            | .address
        ]
    '
)"

COUNT="$(jq 'length' <<< "$BEFORE")"

# Calcular desplazamiento, con límite
LEVEL=$(( COUNT < MAX_STEPS ? COUNT : MAX_STEPS ))
OFFSET=$(( LEVEL * STEP ))

# Lanzar una instancia nueva
qalculate-gtk --new-instance 9>&- </dev/null >/dev/null 2>&1 &

# Esperar a que aparezca una dirección nueva
ADDRESS=""

for (( attempt=0; attempt<50; attempt++ )); do
    AFTER="$(hyprctl clients -j)"

    ADDRESS="$(
        jq -nr \
            --argjson before "$BEFORE" \
            --argjson after "$AFTER" '
            [
                $after[]
                | select((.class // "") | test("qalculate"; "i"))
                | select(.address as $a | ($before | index($a) | not))
                | .address
            ][0] // empty
        '
    )"

    if [[ -n "$ADDRESS" ]]; then
        break
    fi

    sleep 0.1
done

if [[ -z "$ADDRESS" ]]; then
    echo "No se detectó la nueva ventana de Qalculate" >&2
    exit 1
fi

# La regla personal ya coloca Qalculate en el centro.
# Solo desplazamos la nueva ventana, sin mover las demás.
if (( OFFSET > 0 )); then
    hyprctl dispatch \
        "hl.dsp.window.move({ window = 'address:${ADDRESS}', x = ${OFFSET}, y = ${OFFSET}, relative = true })"
fi
