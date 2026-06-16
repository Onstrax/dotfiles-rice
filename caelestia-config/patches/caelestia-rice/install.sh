#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="${DEST_DIR:-$HOME/dotfiles-rice/caelestia-config/patches/caelestia-rice}"

if [[ ! -d "$HOME/dotfiles-rice" ]]; then
  echo "ERROR: no existe ~/dotfiles-rice."
  echo "Crea o sincroniza ese repo antes de instalar el sistema de parches."
  exit 1
fi

mkdir -p "$(dirname "$DEST_DIR")"

if [[ -e "$DEST_DIR" || -L "$DEST_DIR" ]]; then
  BACKUP_DIR="$HOME/backups-rice/patch-system-before-install-$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$BACKUP_DIR"
  cp -a "$DEST_DIR" "$BACKUP_DIR/caelestia-rice"
  echo "Backup del sistema anterior:"
  echo "  $BACKUP_DIR/caelestia-rice"
fi

rsync -a --delete "$SRC_DIR/" "$DEST_DIR/"

find "$DEST_DIR" -type f -name "*.sh" -exec chmod +x {} +

echo "Sistema de parches instalado en:"
echo "  $DEST_DIR"
echo
echo "Para usarlo despues de una actualizacion:"
echo "  $DEST_DIR/apply-rice-patches.sh"
echo
echo "Para guardar la instalacion en dotfiles-rice:"
echo "  cd ~/dotfiles-rice"
echo "  git status"
echo "  git add caelestia-config/patches/caelestia-rice"
echo "  git commit -m \"chore: add caelestia rice patch system\""
echo "  git push"
