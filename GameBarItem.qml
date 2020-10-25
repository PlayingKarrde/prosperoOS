import QtQuick 2.12
import QtGraphicalEffects 1.12
import "utils.js" as Utils

Item {
id: gameItem
    
    property bool isSelected
    property bool isActive
    property var gameData

    height: width
    opacity: isActive || isSelected ? 1 : 0

    ItemOutline {
    id: outline 

        width: {
            if (isSelected && isActive)
                return vpx(125);
            else if (isSelected && !isActive)
                return vpx(65);
            else
                return vpx(85);
        }
        height: width
        Behavior on width { NumberAnimation { duration: 50 } }
        radius: isActive ? vpx(22) : vpx(10)
        show: isSelected && isActive
    }

    Rectangle {
    id: imageBG

        anchors.fill: imageMask
        radius: imageMask.radius
        color: "black"
        opacity: 0.7
        visible: gameData ? !gameData.assets.screenshots[0] : false
    }

    Image {
    id: screenshot

        anchors.fill: imageMask
        source: gameData ? gameData.assets.screenshots[0] || "" : ""
        fillMode: Image.PreserveAspectCrop
        sourceSize: Qt.size(vpx(125), vpx(125))
        smooth: true
        asynchronous: true
        visible: false

        Image {
        id: gameLogo

            anchors.fill: parent
            anchors.margins: vpx(5)
            source: gameData ? Utils.logo(gameData) || "" : ""
            sourceSize: Qt.size(vpx(125), vpx(125))
            fillMode: Image.PreserveAspectFit
            smooth: true
            asynchronous: true
        }
    }

    Rectangle {
    id: imageMask

        anchors.fill: outline
        anchors.margins: vpx(4)
        radius: outline.radius - anchors.margins
        visible: false
    }

    OpacityMask {
        anchors.fill: imageMask
        source: screenshot
        maskSource: imageMask
    }

    Text {
    id: gameName

        x: isActive ? vpx(130) : vpx(80)
        y: isActive ? vpx(85) : vpx(20)
        text: title
        font.family: subtitleFont.name
        font.pixelSize: vpx(20)
        color: "white"
        opacity: isSelected ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 50 } }
    }
}