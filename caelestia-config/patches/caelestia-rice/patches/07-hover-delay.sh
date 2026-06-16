#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/rice-patch-lib.sh"

require_caelestia_repo

log "Aplicando delay de hover para dashboard, launcher y utilities..."
copy_payload_file "modules/drawers/Interactions.qml"

log "Delay de hover aplicado."
