pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    anchors.top: parent.top
    anchors.bottom: parent.bottom
    implicitWidth: Tokens.sizes.dashboard.dateTimeWidth

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        StyledText {
            Layout.bottomMargin: -(font.pointSize * 0.38)
            Layout.alignment: Qt.AlignHCenter
            text: Time.hourStr
            color: Colours.palette.m3primary
            font.pointSize: 30
            font.family: Tokens.font.family.clock
            font.weight: 650
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: "••"
            color: Colours.palette.m3tertiary
            font.pointSize: 22
            font.family: Tokens.font.family.clock
            font.weight: 650
        }

        StyledText {
            Layout.topMargin: -(font.pointSize * 0.38)
            Layout.bottomMargin: -(font.pointSize * 0.24)
            Layout.alignment: Qt.AlignHCenter
            text: Time.minuteStr
            color: Colours.palette.m3secondary
            font.pointSize: 30
            font.family: Tokens.font.family.clock
            font.weight: 650
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: "•"
            color: Colours.palette.m3tertiary
            font.pointSize: 15
            font.family: Tokens.font.family.clock
            font.weight: 650
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: -2
            Layout.preferredWidth: secondsText.implicitWidth + 18
            Layout.minimumWidth: secondsText.implicitWidth + 18
            Layout.maximumWidth: secondsText.implicitWidth + 18
            Layout.preferredHeight: secondsText.implicitHeight + 5
            Layout.minimumHeight: secondsText.implicitHeight + 5
            Layout.maximumHeight: secondsText.implicitHeight + 5

            radius: height / 2
            color: Colours.palette.m3tertiary

            StyledText {
                id: secondsText

                anchors.centerIn: parent
                text: Time.format("ss")
                color: Colours.palette.m3onTertiary
                font.pointSize: 12
                font.family: Tokens.font.family.clock
                font.weight: 450
            }
        }

        Loader {
            asynchronous: true
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Tokens.spacing.small

            active: GlobalConfig.services.useTwelveHourClock
            visible: active

            sourceComponent: StyledText {
                text: Time.amPmStr
                color: Colours.palette.m3primary
                font.pointSize: Tokens.font.size.small
                font.family: Tokens.font.family.clock
                font.weight: 650
            }
        }
    }
}
