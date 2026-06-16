#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/rice-patch-lib.sh"

require_caelestia_repo

log "Aplicando reloj 24h + segundero..."
copy_payload_file "modules/dashboard/dash/DateTime.qml"
patch_shell_json "clock"

log "Reloj 24h + segundero aplicado."
