#!/usr/bin/env bash
set -euo pipefail

PATCH_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PAYLOAD_DIR="$PATCH_ROOT/payload"
QS_DIR="${QS_DIR:-$HOME/.config/quickshell/caelestia}"
SYSTEM_QS_DIR="${SYSTEM_QS_DIR:-/etc/xdg/quickshell/caelestia}"
CAELESTIA_CONFIG_DIR="${CAELESTIA_CONFIG_DIR:-$HOME/.config/caelestia}"
SHELL_JSON="$CAELESTIA_CONFIG_DIR/shell.json"
BACKUP_ROOT="${BACKUP_ROOT:-$HOME/backups-rice/rice-patches}"

if [[ -z "${PATCH_RUN_ID:-}" ]]; then
  PATCH_RUN_ID="$(date +%Y%m%d-%H%M%S)"
fi

BACKUP_DIR="$BACKUP_ROOT/$PATCH_RUN_ID"
mkdir -p "$BACKUP_DIR"

log() {
  printf '%s\n' "$*"
}

warn() {
  printf 'WARN: %s\n' "$*" >&2
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

require_caelestia_repo() {
  [[ -d "$QS_DIR" && -f "$QS_DIR/shell.qml" ]] || die "No existe una config valida de Caelestia en $QS_DIR"
}

require_payload() {
  local rel="$1"
  [[ -e "$PAYLOAD_DIR/$rel" ]] || die "Falta payload: $PAYLOAD_DIR/$rel"
}

backup_path() {
  local path="$1"
  local base
  local rel

  if [[ "$path" == "$QS_DIR/"* ]]; then
    rel="${path#$QS_DIR/}"
    base="$BACKUP_DIR/quickshell-caelestia"
  elif [[ "$path" == "$CAELESTIA_CONFIG_DIR/"* ]]; then
    rel="${path#$CAELESTIA_CONFIG_DIR/}"
    base="$BACKUP_DIR/caelestia-config"
  else
    rel="${path#/}"
    base="$BACKUP_DIR/absolute"
  fi

  if [[ -e "$path" || -L "$path" ]]; then
    mkdir -p "$base/$(dirname "$rel")"
    if [[ ! -e "$base/$rel" && ! -L "$base/$rel" ]]; then
      cp -a "$path" "$base/$rel"
    fi
  fi
}

copy_payload_file() {
  local rel="$1"
  local target="$QS_DIR/$rel"

  require_payload "$rel"
  backup_path "$target"
  mkdir -p "$(dirname "$target")"
  cp -a "$PAYLOAD_DIR/$rel" "$target"
}

make_executable() {
  local rel="$1"
  chmod +x "$QS_DIR/$rel"
}

ensure_shell_json() {
  [[ -f "$SHELL_JSON" ]] || die "No existe $SHELL_JSON"
}

patch_shell_json() {
  ensure_shell_json
  backup_path "$SHELL_JSON"

  python - "$SHELL_JSON" "$1" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
patch_name = sys.argv[2]
data = json.loads(path.read_text())

if patch_name == "runcat":
    entries = data.setdefault("bar", {}).setdefault("entries", [])
    entries[:] = [entry for entry in entries if entry.get("id") != "runcat"]
    item = {"enabled": True, "id": "runcat"}

    inserted = False
    for i, entry in enumerate(entries):
        if entry.get("id") == "logo":
            entries.insert(i + 1, item)
            inserted = True
            break

    if not inserted:
        for i, entry in enumerate(entries):
            if entry.get("id") == "workspaces":
                entries.insert(i, item)
                inserted = True
                break

    if not inserted:
        entries.insert(0, item)

elif patch_name == "clock":
    data.setdefault("services", {})
    data["services"]["useTwelveHourClock"] = False

else:
    raise SystemExit(f"Unknown shell.json patch: {patch_name}")

path.write_text(json.dumps(data, indent=4, ensure_ascii=False) + "\n")
PY
}

patch_bar_for_runcat() {
  local target="$QS_DIR/modules/bar/Bar.qml"
  backup_path "$target"

  python - "$target" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text()

if 'roleValue: "runcat"' in text:
    raise SystemExit(0)

needle = '''            DelegateChoice {
                roleValue: "workspaces"
'''

insert = '''            DelegateChoice {
                roleValue: "runcat"
                delegate: WrappedLoader {
                    visible: !root.fullscreen
                    sourceComponent: RunCat {}
                }
            }
'''

if needle not in text:
    raise SystemExit("No encontre el bloque DelegateChoice de workspaces para insertar RunCat.")

text = text.replace(needle, insert + needle, 1)
path.write_text(text)
PY
}

patch_dashboard_content_for_timer() {
  local target="$QS_DIR/modules/dashboard/Content.qml"
  backup_path "$target"

  python - "$target" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text()

if "timerComponent" not in text:
    weather_tab = '''            {
                component: weatherComponent,
                iconName: "cloud",
                text: qsTr("Weather"),
'''
    timer_tab = '''            {
                component: timerComponent,
                iconName: "timer",
                text: qsTr("Timer"),
                enabled: true
            },
'''
    if weather_tab not in text:
        raise SystemExit("No encontre el bloque Weather en dashboardTabs para insertar Timer.")
    text = text.replace(weather_tab, timer_tab + weather_tab, 1)

if "id: timerComponent" not in text:
    weather_component = '''            Component {
                id: weatherComponent

                WeatherTab {}
            }
'''
    timer_component = '''            Component {
                id: timerComponent

                TimerTab {}
            }

'''
    if weather_component not in text:
        raise SystemExit("No encontre el Component de WeatherTab para insertar TimerTab.")
    text = text.replace(weather_component, timer_component + weather_component, 1)

path.write_text(text)
PY
}
