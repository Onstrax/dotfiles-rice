#!/usr/bin/env bash
set -euo pipefail

QS_DIR="$HOME/.config/quickshell/caelestia"
SRC="/etc/xdg/quickshell/caelestia/modules/dashboard/Performance.qml"
DEST="$QS_DIR/modules/dashboard/Performance.qml"
BACKUP_DIR="$HOME/backups-rice/performance-new-cpu-gpu-restore-$(date +%Y%m%d-%H%M%S)"

if [[ ! -f "$SRC" ]]; then
  echo "ERROR: no existe $SRC"
  exit 1
fi

mkdir -p "$BACKUP_DIR/modules/dashboard"
cp -a "$DEST" "$BACKUP_DIR/modules/dashboard/Performance.qml"
cp -a "$SRC" "$DEST"

echo "Performance.qml restaurado desde /etc."
echo "Backup: $BACKUP_DIR"
