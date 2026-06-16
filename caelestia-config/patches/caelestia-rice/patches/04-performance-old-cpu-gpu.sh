#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/rice-patch-lib.sh"

require_caelestia_repo

log "Aplicando CPU/GPU old-style en Performance..."
copy_payload_file "modules/dashboard/Performance.qml"

log "Performance CPU/GPU old-style aplicado."
