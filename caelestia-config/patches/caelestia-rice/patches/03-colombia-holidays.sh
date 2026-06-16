#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/rice-patch-lib.sh"

require_caelestia_repo

log "Aplicando festivos de Colombia..."
copy_payload_file "services/ColombiaHolidays.qml"
copy_payload_file "modules/dashboard/dash/Calendar.qml"

log "Festivos de Colombia aplicados."
