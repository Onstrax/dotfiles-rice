#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/rice-patch-lib.sh"

require_caelestia_repo

log "Aplicando RunCat..."
copy_payload_file "modules/bar/components/RunCat.qml"
copy_payload_file "services/SystemUsage.qml"
patch_bar_for_runcat
patch_shell_json "runcat"

log "RunCat aplicado."
