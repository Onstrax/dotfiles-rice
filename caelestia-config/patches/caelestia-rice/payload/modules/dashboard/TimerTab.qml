import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    implicitWidth: 840
    implicitHeight: layout.implicitHeight

    readonly property int durationMinutes: Math.floor(TimerState.timerDurationSeconds / 60)
    readonly property int durationSeconds: TimerState.timerDurationSeconds % 60

    function setDurationParts(minutes: int, seconds: int): void {
        TimerState.setTimerDuration(Math.max(1, minutes * 60 + seconds));
    }

    ColumnLayout {
        id: layout

        anchors.fill: parent
        spacing: Tokens.spacing.normal

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Tokens.padding.normal
            Layout.rightMargin: Tokens.padding.normal
            spacing: Tokens.spacing.normal

            MaterialIcon {
                text: "timer"
                color: Colours.palette.m3primary
                fill: 1
                fontStyle: Tokens.font.icon.large
            }

            ColumnLayout {
                spacing: 0

                StyledText {
                    text: qsTr("Timer")
                    color: Colours.palette.m3onSurface
                    font: Tokens.font.body.builders.large.weight(Font.Bold).build()
                }

                StyledText {
                    text: qsTr("Stopwatch and countdown tools")
                    color: Colours.palette.m3onSurfaceVariant
                    font: Tokens.font.body.medium
                }
            }

            Item {
                Layout.fillWidth: true
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Tokens.padding.normal
            Layout.rightMargin: Tokens.padding.normal
            spacing: Tokens.spacing.normal

            TimeCard {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                cardTitle: qsTr("Stopwatch")
                cardSubtitle: TimerState.stopwatchRunning ? qsTr("Running") : qsTr("Paused")
                cardIcon: "timer"
                accent: Colours.palette.m3primary
                timeText: TimerState.formatMs(TimerState.stopwatchDisplayMs)

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 90

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: Tokens.spacing.small

                        PillButton {
                            label: TimerState.stopwatchRunning ? qsTr("Pause") : qsTr("Start")
                            iconName: TimerState.stopwatchRunning ? "pause" : "play_arrow"
                            accent: Colours.palette.m3primary
                            primary: true
                            onClicked: TimerState.toggleStopwatch()
                        }

                        PillButton {
                            label: qsTr("Reset")
                            iconName: "restart_alt"
                            accent: Colours.palette.m3secondary
                            onClicked: TimerState.resetStopwatch()
                        }
                    }
                }
            }

            TimeCard {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                cardTitle: qsTr("Countdown")
                cardSubtitle: TimerState.timerFinished
                    ? qsTr("Finished")
                    : (TimerState.timerRunning ? qsTr("Running") : qsTr("Ready"))
                cardIcon: TimerState.timerFinished ? "notifications_active" : "hourglass_top"
                accent: TimerState.timerFinished ? Colours.palette.m3error : Colours.palette.m3tertiary
                timeText: TimerState.formatSeconds(TimerState.timerDisplaySeconds)

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 90
                    spacing: Tokens.spacing.extraSmall

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("")
                        color: Colours.palette.m3onSurfaceVariant
                        font: Tokens.font.body.medium
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 72

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: Tokens.spacing.normal

                            RowLayout {
                                spacing: Tokens.spacing.small
                                Layout.alignment: Qt.AlignVCenter
                                enabled: !TimerState.timerRunning
                                opacity: enabled ? 1 : 0.5

                                NumberStepper {
                                    label: qsTr("min")
                                    value: root.durationMinutes
                                    from: 0
                                    to: 180
                                    accent: Colours.palette.m3tertiary
                                    enabled: !TimerState.timerRunning
                                    onRequested: value => root.setDurationParts(value, root.durationSeconds)
                                }

                                StyledText {
                                    Layout.alignment: Qt.AlignVCenter
                                    text: ":"
                                    color: Colours.palette.m3tertiary
                                    font.pointSize: 24
                                    font.family: Tokens.font.family.clock
                                    font.weight: 700
                                }

                                NumberStepper {
                                    label: qsTr("sec")
                                    value: root.durationSeconds
                                    from: 0
                                    to: 59
                                    accent: Colours.palette.m3tertiary
                                    enabled: !TimerState.timerRunning
                                    onRequested: value => root.setDurationParts(root.durationMinutes, value)
                                }
                            }

                            ColumnLayout {
                                Layout.alignment: Qt.AlignVCenter
                                spacing: Tokens.spacing.small

                                PillButton {
                                    label: TimerState.timerRunning ? qsTr("Pause") : qsTr("Start")
                                    iconName: TimerState.timerRunning ? "pause" : "play_arrow"
                                    accent: TimerState.timerFinished ? Colours.palette.m3error : Colours.palette.m3tertiary
                                    primary: true
                                    onClicked: TimerState.toggleTimer()
                                }

                                PillButton {
                                    label: qsTr("Reset")
                                    iconName: "restart_alt"
                                    accent: Colours.palette.m3secondary
                                    onClicked: TimerState.resetTimer()
                                }
                            }
                        }
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        visible: TimerState.timerFinished
                        text: qsTr("Time is up")
                        color: Colours.palette.m3error
                        font: Tokens.font.body.builders.small.weight(Font.Bold).build()
                    }
                }
            }
        }
    }

    component TimeCard: StyledRect {
        id: card

        property string cardTitle
        property string cardSubtitle
        property string cardIcon
        property string timeText
        property color accent

        default property alias cardContent: contentArea.data

        Layout.preferredHeight: 310
        radius: Tokens.rounding.xl
        color: Colours.tPalette.m3surfaceContainer
        border.width: 1
        border.color: Qt.alpha(card.accent, 0.22)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Tokens.padding.large
            spacing: Tokens.spacing.small

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                spacing: Tokens.spacing.small

                StyledRect {
                    implicitWidth: 42
                    implicitHeight: 42
                    radius: Tokens.rounding.full
                    color: Qt.alpha(card.accent, 0.22)

                    MaterialIcon {
                        anchors.centerIn: parent
                        text: card.cardIcon
                        color: card.accent
                        fill: 1
                        fontStyle: Tokens.font.icon.large
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    StyledText {
                        text: card.cardTitle
                        color: Colours.palette.m3onSurface
                        font: Tokens.font.body.builders.medium.weight(Font.Bold).build()
                    }

                    StyledText {
                        text: card.cardSubtitle
                        color: card.accent
                        font: Tokens.font.body.builders.small.weight(Font.Bold).build()
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 116

                StyledText {
                    anchors.centerIn: parent
                    text: card.timeText
                    color: card.accent
                    font.pointSize: 42
                    font.family: Tokens.font.family.clock
                    font.weight: 700
                }
            }

            ColumnLayout {
                id: contentArea

                Layout.fillWidth: true
                Layout.preferredHeight: 96
                spacing: Tokens.spacing.small
            }
        }
    }

    component NumberStepper: StyledRect {
        id: stepper

        signal requested(int value)

        property string label
        property int value: 0
        property int from: 0
        property int to: 59
        property color accent

        function two(n: int): string {
            return n < 10 ? "0" + n : "" + n;
        }

        implicitWidth: 98
        implicitHeight: 80
        radius: Tokens.rounding.large
        color: Qt.alpha(stepper.accent, 0.12)
        opacity: enabled ? 1 : 0.45
        border.width: 1
        border.color: Qt.alpha(stepper.accent, 0.30)

        RowLayout {
            anchors.centerIn: parent
            spacing: Tokens.spacing.extraSmall

            ColumnLayout {
                spacing: -2

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: stepper.two(stepper.value)
                    color: stepper.accent
                    font.pointSize: 22
                    font.family: Tokens.font.family.clock
                    font.weight: 700
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: stepper.label
                    color: Colours.palette.m3onSurfaceVariant
                    font: Tokens.font.body.small
                }
            }

            ColumnLayout {
                spacing: 0

                IconTap {
                    iconName: "keyboard_arrow_up"
                    accent: stepper.accent
                    enabled: stepper.enabled && stepper.value < stepper.to
                    onClicked: stepper.requested(Math.min(stepper.to, stepper.value + 1))
                }

                IconTap {
                    iconName: "keyboard_arrow_down"
                    accent: stepper.accent
                    enabled: stepper.enabled && stepper.value > stepper.from
                    onClicked: stepper.requested(Math.max(stepper.from, stepper.value - 1))
                }
            }
        }
    }

    component IconTap: StyledRect {
        id: tap

        signal clicked

        property string iconName
        property color accent

        implicitWidth: 24
        implicitHeight: 22
        radius: Tokens.rounding.full
        color: hover.hovered ? Qt.alpha(tap.accent, 0.22) : "transparent"
        opacity: enabled ? 1 : 0.35

        MaterialIcon {
            anchors.centerIn: parent
            text: tap.iconName
            color: tap.accent
            fontStyle: Tokens.font.icon.small
        }

        HoverHandler {
            id: hover
        }

        TapHandler {
            onTapped: tap.clicked()
        }
    }

    component PillButton: StyledRect {
        id: button

        signal clicked

        property string label
        property string iconName
        property color accent
        property bool primary: false

        implicitWidth: buttonRow.implicitWidth + Tokens.padding.large * 2
        implicitHeight: 38
        radius: Tokens.rounding.full
        color: primary ? button.accent : "transparent"
        border.width: primary ? 0 : 1
        border.color: Qt.alpha(button.accent, hover.hovered ? 0.75 : 0.42)

        RowLayout {
            id: buttonRow

            anchors.centerIn: parent
            spacing: Tokens.spacing.extraSmall

            MaterialIcon {
                text: button.iconName
                color: button.primary ? Colours.palette.m3onPrimary : button.accent
                fill: button.primary ? 1 : 0
                fontStyle: Tokens.font.icon.small
            }

            StyledText {
                text: button.label
                color: button.primary ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface
                font: Tokens.font.body.builders.small.weight(Font.Bold).build()
            }
        }

        HoverHandler {
            id: hover
        }

        TapHandler {
            onTapped: button.clicked()
        }
    }
}
