#!/usr/bin/env bash
set -euo pipefail

PATCH_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATCH_RUN_ID="${PATCH_RUN_ID:-$(date +%Y%m%d-%H%M%S)}"
export QS_DIR="${QS_DIR:-$HOME/.config/quickshell/caelestia}"
export BACKUP_ROOT="${BACKUP_ROOT:-$HOME/backups-rice/rice-patches}"

ask() {
  local label="$1"
  local script="$2"
  local answer

  printf '\n%s\n' "------------------------------------------------------------"
  printf '%s\n' "$label"
  printf '%s' "Aplicar este parche? [s/N]: "
  read -r answer

  case "${answer,,}" in
    s|si|sí|y|yes)
      bash "$PATCH_ROOT/$script"
      ;;
    *)
      printf '%s\n' "Saltado."
      ;;
  esac
}

echo "== Caelestia rice patch runner =="
echo
echo "Config objetivo:"
echo "  $QS_DIR"
echo
echo "Backups de esta corrida:"
echo "  $BACKUP_ROOT/$PATCH_RUN_ID"
echo
echo "Tip: despues de aplicar parches, reinicia Caelestia y guarda en Git si todo quedo bien."

ask "1/7 RunCat en la barra izquierda" "patches/01-runcat.sh"
ask "2/7 Reloj 24h + segundero en dashboard" "patches/02-clock-seconds.sh"
ask "3/7 Festivos de Colombia en calendario" "patches/03-colombia-holidays.sh"
ask "4/7 CPU/GPU old-style en Performance" "patches/04-performance-old-cpu-gpu.sh"
ask "5/7 Timer tab completo" "patches/05-timer-tab.sh"
ask "6/7 Session panel buttons y comandos" "patches/06-session-panel.sh"
ask "7/7 Delay de hover en dashboard/launcher/utilities" "patches/07-hover-delay.sh"

echo
echo "Listo. Reinicia Caelestia con:"
echo "  qs -c caelestia kill 2>/dev/null; or true"
echo "  pkill -x qs 2>/dev/null; or true"
echo "  sleep 1"
echo "  caelestia shell -d"
echo
echo "Si todo queda bien:"
echo "  cd $QS_DIR"
echo "  git status"
echo "  git add ."
echo "  git commit -m \"chore: reapply selected rice patches\""
echo "  git push"
echo
echo "Backups:"
echo "  $BACKUP_ROOT/$PATCH_RUN_ID"
