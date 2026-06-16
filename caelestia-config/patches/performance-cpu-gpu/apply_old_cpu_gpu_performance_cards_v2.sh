#!/usr/bin/env bash
set -euo pipefail

QS_DIR="$HOME/.config/quickshell/caelestia"
PERF="$QS_DIR/modules/dashboard/Performance.qml"
PATCH_DIR="$HOME/.config/caelestia/patches/performance-cpu-gpu"
BACKUP_ROOT="$HOME/backups-rice"
TS="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$BACKUP_ROOT/performance-old-cpu-gpu-v2-$TS"

echo "== Apply old-style CPU/GPU cards only - v2 =="
echo

if [[ ! -d "$QS_DIR" || ! -f "$QS_DIR/shell.qml" ]]; then
  echo "ERROR: no existe una config válida en $QS_DIR"
  exit 1
fi

if [[ ! -f "$PERF" ]]; then
  echo "ERROR: no existe $PERF"
  exit 1
fi

mkdir -p "$BACKUP_DIR/modules/dashboard" "$PATCH_DIR"
cp -a "$PERF" "$BACKUP_DIR/modules/dashboard/Performance.qml"

cd "$QS_DIR"

python - <<'PY'
from pathlib import Path
import re

path = Path.home() / ".config/quickshell/caelestia/modules/dashboard/Performance.qml"
text = path.read_text()

# Quitar restos de intentos anteriores si existen.
text = re.sub(
    r'\n    component OldCardHeader: RowLayout \{.*?\n    component WrappedLoader: Loader \{',
    '\n    component WrappedLoader: Loader {',
    text,
    flags=re.S,
)

# Insertar helper de temperatura si no existe.
if "function displayTemp(" not in text:
    needle = """Item {
    id: root

"""
    insert = """Item {
    id: root

    function displayTemp(temp: real): string {
        return `${Math.ceil(GlobalConfig.services.useFahrenheitPerformance ? temp * 1.8 + 32 : temp)}°${GlobalConfig.services.useFahrenheitPerformance ? "F" : "C"}`;
    }

"""
    if needle not in text:
        raise SystemExit("No encontré el bloque inicial Item/id root para insertar displayTemp().")
    text = text.replace(needle, insert, 1)

# Bloques posibles: versión nueva original o versión parcheada anterior.
old_new_block = """            RowLayout {
                spacing: Tokens.spacing.medium
                visible: cpuCard.active || gpuCard.active

                WrappedLoader {
                    id: cpuCard

                    active: Config.dashboard.performance.showCpu

                    sourceComponent: HeroCard {
                        icon: "memory"
                        label: qsTr("CPU")
                        subLabel: Cpu.name
                        usage: Cpu.percentage
                        temperature: Cpu.temperature
                        accent: Colours.palette.m3primary

                        ServiceRef {
                            service: Cpu
                        }
                    }
                }

                WrappedLoader {
                    id: gpuCard

                    active: Config.dashboard.performance.showGpu && Gpu.type !== Gpu.None

                    sourceComponent: HeroCard {
                        icon: "desktop_windows"
                        label: qsTr("GPU")
                        subLabel: Gpu.name
                        usage: Gpu.percentage
                        temperature: Gpu.temperature
                        accent: Colours.palette.m3secondary

                        ServiceRef {
                            service: Gpu
                        }
                    }
                }
            }

"""

old_patch_block = """            RowLayout {
                spacing: Tokens.spacing.medium
                visible: cpuCard.active || gpuCard.active

                WrappedLoader {
                    id: cpuCard

                    active: Config.dashboard.performance.showCpu

                    sourceComponent: OldHeroCard {
                        icon: "memory"
                        title: Cpu.name ? `CPU - ${Cpu.name}` : qsTr("CPU")
                        mainValue: `${Math.round(Cpu.percentage * 100)}%`
                        mainLabel: qsTr("Usage")
                        secondaryValue: root.displayTemp(Cpu.temperature)
                        secondaryLabel: qsTr("Temp")
                        usage: Cpu.percentage
                        temperature: Cpu.temperature
                        accentColor: Colours.palette.m3primary

                        ServiceRef {
                            service: Cpu
                        }
                    }
                }

                WrappedLoader {
                    id: gpuCard

                    active: Config.dashboard.performance.showGpu && Gpu.type !== Gpu.None

                    sourceComponent: OldHeroCard {
                        icon: "desktop_windows"
                        title: Gpu.name ? `GPU - ${Gpu.name}` : qsTr("GPU")
                        mainValue: `${Math.round(Gpu.percentage * 100)}%`
                        mainLabel: qsTr("Usage")
                        secondaryValue: root.displayTemp(Gpu.temperature)
                        secondaryLabel: qsTr("Temp")
                        usage: Gpu.percentage
                        temperature: Gpu.temperature
                        accentColor: Colours.palette.m3secondary

                        ServiceRef {
                            service: Gpu
                        }
                    }
                }
            }

"""

new_block = """            RowLayout {
                spacing: Tokens.spacing.medium
                visible: Config.dashboard.performance.showCpu || (Config.dashboard.performance.showGpu && Gpu.type !== Gpu.None)

                OldCpuGpuCard {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 360
                    visible: Config.dashboard.performance.showCpu

                    icon: "memory"
                    title: Cpu.name ? `CPU - ${Cpu.name}` : qsTr("CPU")
                    mainValue: `${Math.round(Cpu.percentage * 100)}%`
                    mainLabel: qsTr("Usage")
                    secondaryValue: root.displayTemp(Cpu.temperature)
                    secondaryLabel: qsTr("Temp")
                    usage: Cpu.percentage
                    temperature: Cpu.temperature
                    accentColor: Colours.palette.m3primary

                    ServiceRef {
                        service: Cpu
                    }
                }

                OldCpuGpuCard {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 360
                    visible: Config.dashboard.performance.showGpu && Gpu.type !== Gpu.None

                    icon: "desktop_windows"
                    title: Gpu.name ? `GPU - ${Gpu.name}` : qsTr("GPU")
                    mainValue: `${Math.round(Gpu.percentage * 100)}%`
                    mainLabel: qsTr("Usage")
                    secondaryValue: root.displayTemp(Gpu.temperature)
                    secondaryLabel: qsTr("Temp")
                    usage: Gpu.percentage
                    temperature: Gpu.temperature
                    accentColor: Colours.palette.m3secondary

                    ServiceRef {
                        service: Gpu
                    }
                }
            }

"""

if old_new_block in text:
    text = text.replace(old_new_block, new_block, 1)
elif old_patch_block in text:
    text = text.replace(old_patch_block, new_block, 1)
elif "OldCpuGpuCard" in text:
    print("El bloque OldCpuGpuCard ya parece estar aplicado.")
else:
    raise SystemExit("No encontré el bloque CPU/GPU esperado. No modifiqué Performance.qml.")

# Insertar componente robusto sin dependencias antiguas.
if "component OldCpuGpuCard" not in text:
    marker = """    component WrappedLoader: Loader {
"""
    component = """    component OldCpuGpuCard: StyledRect {
        id: heroCard

        property string icon
        property string title
        property string mainValue
        property string mainLabel
        property string secondaryValue
        property string secondaryLabel
        property real usage: 0
        property real temperature: 0
        property color accentColor: Colours.palette.m3primary
        readonly property real maxTemp: 100
        readonly property real tempProgress: Math.min(1, Math.max(0, temperature / maxTemp))
        property real animatedUsage: 0
        property real animatedTemp: 0

        implicitHeight: 150
        color: Colours.tPalette.m3surfaceContainer
        radius: Tokens.rounding.large
        clip: true

        Component.onCompleted: {
            animatedUsage = usage;
            animatedTemp = tempProgress;
        }

        onUsageChanged: animatedUsage = usage
        onTempProgressChanged: animatedTemp = tempProgress

        StyledRect {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            implicitWidth: parent.width * heroCard.animatedUsage
            color: Qt.alpha(heroCard.accentColor, 0.15)
        }

        RowLayout {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: Tokens.padding.large
            anchors.topMargin: Math.round(Tokens.padding.large * 1.2)
            width: parent.width - anchors.leftMargin - usageColumn.anchors.rightMargin - usageLabel.width - Tokens.spacing.large
            spacing: Tokens.spacing.small

            MaterialIcon {
                text: heroCard.icon
                fill: 1
                color: heroCard.accentColor
                fontStyle: Tokens.font.icon.medium
            }

            StyledText {
                Layout.fillWidth: true
                text: heroCard.title
                font: Tokens.font.body.medium
                color: Colours.palette.m3onSurface
                elide: Text.ElideRight
            }
        }

        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: Math.round(Tokens.padding.large * 1.2)
            anchors.bottomMargin: Math.round(Tokens.padding.large * 1.3)
            spacing: Tokens.spacing.small

            Row {
                spacing: Tokens.spacing.small

                StyledText {
                    text: heroCard.secondaryValue
                    font: Tokens.font.body.builders.medium.weight(Font.Medium).build()
                    color: Colours.palette.m3onSurface
                }

                StyledText {
                    text: heroCard.secondaryLabel
                    font: Tokens.font.body.small
                    color: Colours.palette.m3onSurfaceVariant
                    anchors.baseline: parent.children[0].baseline
                }
            }

            StyledRect {
                implicitWidth: parent.width * 0.5
                implicitHeight: 6
                radius: Tokens.rounding.full
                color: Qt.alpha(heroCard.accentColor, 0.2)

                StyledRect {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    implicitWidth: parent.width * heroCard.animatedTemp
                    radius: Tokens.rounding.full
                    color: heroCard.accentColor
                }
            }
        }

        Column {
            id: usageColumn

            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Tokens.padding.large
            anchors.rightMargin: 32
            spacing: 0

            StyledText {
                id: usageLabel

                anchors.right: parent.right
                text: heroCard.mainLabel
                font: Tokens.font.body.medium
                color: Colours.palette.m3onSurfaceVariant
            }

            StyledText {
                anchors.right: parent.right
                text: heroCard.mainValue
                font: Tokens.font.body.builders.extraLarge.weight(Font.Medium).build()
                color: heroCard.accentColor
            }
        }

        Behavior on animatedUsage {
            Anim {
                type: Anim.StandardLarge
            }
        }

        Behavior on animatedTemp {
            Anim {
                type: Anim.StandardLarge
            }
        }
    }

"""
    if marker not in text:
        raise SystemExit("No encontré component WrappedLoader para insertar OldCpuGpuCard.")
    text = text.replace(marker, component + marker, 1)

path.write_text(text)
PY

cat > "$PATCH_DIR/restore_new_cpu_gpu_performance.sh" <<'EOF'
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
EOF

chmod +x "$PATCH_DIR/restore_new_cpu_gpu_performance.sh"

echo
echo "Parche aplicado solo sobre CPU/GPU dentro de:"
echo "  $PERF"
echo
echo "Backup:"
echo "  $BACKUP_DIR"
echo
echo "Restaurador nuevo instalado en:"
echo "  $PATCH_DIR/restore_new_cpu_gpu_performance.sh"
echo
echo "Reinicia Caelestia:"
echo "  qs -c caelestia kill 2>/dev/null; or true"
echo "  pkill -x qs 2>/dev/null; or true"
echo "  sleep 1"
echo "  caelestia shell -d"
echo
echo "Si queda bien:"
echo "  cd $QS_DIR"
echo "  git add modules/dashboard/Performance.qml"
echo "  git commit -m \"style: use old cpu gpu performance cards\""
echo
echo "Si algo falla:"
echo "  cp -a $BACKUP_DIR/modules/dashboard/Performance.qml $PERF"
