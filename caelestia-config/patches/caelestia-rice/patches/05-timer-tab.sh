#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/rice-patch-lib.sh"

require_caelestia_repo

log "Aplicando Timer tab completo..."
copy_payload_file "modules/dashboard/TimerTab.qml"
copy_payload_file "services/TimerState.qml"
copy_payload_file "scripts/timer_finished.sh"
make_executable "scripts/timer_finished.sh"
patch_dashboard_content_for_timer

log "Timer tab aplicado."
