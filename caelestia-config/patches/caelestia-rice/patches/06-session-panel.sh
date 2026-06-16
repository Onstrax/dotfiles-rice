#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/rice-patch-lib.sh"

require_caelestia_repo

log "Aplicando botones y comandos del session panel..."
copy_payload_file "modules/session/Content.qml"

log "Session panel aplicado."
