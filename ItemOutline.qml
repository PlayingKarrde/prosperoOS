import QtQuick 2.0
import QtGraphicalEffects 1.12

Rectangle {
id: root

    property bool show

    anchors.margins: vpx(-4)
    radius: height/2
    opacity: show ? 0.8 : 0
    //Behavior on opacity { NumberAnimation { duration: 50 } }

    border.width: vpx(2)
    border.color: "white"
    color: "transparent"

    SequentialAnimation {
    id: animateOpacity

        loops: Animation.Infinite
        running: root.show

        NumberAnimation {
            target: root
            property: "opacity"
            from: 0.8; to: 0.3
            easing.type: Easing.InCubic; duration: 2000
        }
        NumberAnimation {
            target: root
            property: "opacity"
            to: 0.8
            easing.type: Easing.OutCubic; duration: 3000
        }
        PauseAnimation { duration: 100 }
    }

    /*Rectangle {
    id: imageMask

        anchors.fill: parent
        anchors.margins: vpx(4)
        radius: outline.radius - anchors.margins
        visible: false
    }

    Item {
    id: gradient

        anchors.fill: imageMask
        anchors.margins: vpx(4)
        
        RadialGradient {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.5; color: "white" }
            }
        }
        visible: false
    }

    OpacityMask {
    id: gradmask

        anchors.fill: imageMask
        source: gradient
        maskSource: imageMask
        visible: false
    }

    Image {
    id: highlightgrad 

        width: imageMask.width
        height: imageMask.height*2
        source: "assets/images/highlightgradient.png"
        //transform: Rotation { origin.x: width/2; origin.y: height/2; angle: 45}
        visible: false
    }

    SequentialAnimation {
    id: animatePos

        loops: Animation.Infinite
        running: root.show

        NumberAnimation {
            target: gradientmask
            property: "opacity"
            from: 0; to: 1
            easing.type: Easing.InCubic; duration: 3000
        }
        NumberAnimation {
            target: gradientmask
            property: "opacity"
            from: 1; to: 0
            easing.type: Easing.OutCubic; duration: 5000
        }
        PauseAnimation { duration: 100 }
    }

    OpacityMask {
    id: gradientmask

        anchors.fill: imageMask
        source: highlightgrad
        maskSource: gradmask
        opacity: 0
    }//*/
}