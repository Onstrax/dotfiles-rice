import "performance"
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import Caelestia.Config
import Caelestia.Services
import qs.components
import qs.services

Item {
    id: root

    function displayTemp(temp: real): string {
        return `${Math.ceil(GlobalConfig.services.useFahrenheitPerformance ? temp * 1.8 + 32 : temp)}°${GlobalConfig.services.useFahrenheitPerformance ? "F" : "C"}`;
    }

    implicitWidth: placeholder.active ? Tokens.sizes.dashboard.perfPlaceholderWidth : content.implicitWidth
    implicitHeight: placeholder.active ? placeholder.implicitHeight + Tokens.padding.extraLarge * 2 : content.implicitHeight

    Loader {
        id: placeholder

        anchors.centerIn: parent
        active: !Config.dashboard.performance.showCpu && !(Config.dashboard.performance.showGpu && Gpu.type !== Gpu.None) && !Config.dashboard.performance.showMemory && !Config.dashboard.performance.showStorage && !Config.dashboard.performance.showNetwork && !(UPower.displayDevice.isLaptopBattery && Config.dashboard.performance.showBattery)
        asynchronous: true

        sourceComponent: ColumnLayout {
            spacing: Tokens.spacing.medium

            MaterialIcon {
                Layout.alignment: Qt.AlignHCenter
                text: "tune"
                fontStyle: Tokens.font.icon.builders.extraLarge.scale(2).build()
                color: Colours.palette.m3onSurfaceVariant
            }

            StyledText {
                Layout.topMargin: -Tokens.spacing.small
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("No widgets enabled")
                font: Tokens.font.title.large
                color: Colours.palette.m3onSurface
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Enable widgets in the dashboard settings")
                font: Tokens.font.body.small
                color: Colours.palette.m3onSurfaceVariant
            }
        }
    }

    RowLayout {
        id: content

        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Tokens.spacing.medium
        visible: !placeholder.active

        ColumnLayout {
            id: mainColumn

            Layout.fillWidth: true
            spacing: Tokens.spacing.medium

            RowLayout {
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

            RowLayout {
                spacing: Tokens.spacing.medium
                visible: storageCard.active || networkCard.active || memoryCard.active

                WrappedLoader {
                    id: storageCard

                    active: Config.dashboard.performance.showStorage
                    sourceComponent: StorageCard {}
                }

                WrappedLoader {
                    id: networkCard

                    active: Config.dashboard.performance.showNetwork
                    sourceComponent: NetworkCard {}
                }

                WrappedLoader {
                    id: memoryCard

                    active: Config.dashboard.performance.showMemory
                    sourceComponent: MemoryCard {}
                }
            }
        }

        WrappedLoader {
            Layout.fillWidth: false
            active: UPower.displayDevice.isLaptopBattery && Config.dashboard.performance.showBattery
            sourceComponent: BatteryTank {}
        }
    }

    component OldCpuGpuCard: StyledClippingRect {
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

    component WrappedLoader: Loader {
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: active
    }
}
