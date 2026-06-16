#!/bin/bash

TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiI0MTExYTJjMTRkNjc0NjZhYjIxMjYzN2U0MDA2N2NjYyIsImlhdCI6MTc2OTk5OTkyMCwiZXhwIjoyMDg1MzU5OTIwfQ.c-IpZdi5JlkQ2G0hYG8PakMLQiMSgSaf39DfXPV-XXo"
ENTITY="light.juanes"
URL="http://localhost:8123/api/services/light/turn_on"

# Recibir el número del 0 al 9
INPUT=$1

# Lógica de conversión
case $INPUT in
    1) BRILLO=0 ;;   # 1%
    2) BRILLO=1 ;;  # 10%
    3) BRILLO=10 ;;  # 20%
    4) BRILLO=20 ;;  # 30%
    5) BRILLO=30 ;;  # 40%
    6) BRILLO=40 ;;  # 50%
    7) BRILLO=50 ;;  # 60%
    8) BRILLO=65 ;;  # 70%
    9) BRILLO=80 ;;  # 80%
    0) BRILLO=100 ;; # 100%
    *) exit 1 ;;      # Otros números no hacen nada
esac

# Enviar comando a Home Assistant
curl -X POST "$URL" \
     -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type: application/json" \
     -d "{\"entity_id\": \"$ENTITY\", \"brightness_pct\": $BRILLO}"