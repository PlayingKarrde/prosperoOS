import QtQuick 2.12
import QtGraphicalEffects 1.12

FocusScope {
id: root

    property bool selected
    property bool highlighted
    property var gameData
    property bool isFave: gameData ? gameData.favorite : false
    property alias radius: mask.radius

    signal activated

    // List specific input
    Keys.onPressed: {
        // Accept
        if (api.keys.isAccept(event) && !event.isAutoRepeat) {
            event.accepted = true;
            sfxAccept.play();
            launchGame(gameData);
            activated();
        }

        // Favorite
        if (api.keys.isFilters(event) && !event.isAutoRepeat) {
            event.accepted = true;
            sfxToggle.play();
            gameData.favorite = !gameData.favorite
        }
    }

    width: vpx(250)
    height: vpx(400)

    function steamAppID (gameData) {
        var str = gameData.assets.boxFront.split("header");
        return str[0];
    }

    function steamLogo(gameData) {
        return steamAppID(gameData) + "/logo.png"
    }

    function steamHero(gameData) {
        return steamAppID(gameData) + "library_hero.jpg"
    }

    function steamHeader(gameData) {
        return steamAppID(gameData) + "/header.jpg.jpg"
    }

    function fanArt(data) {
    if (data != null) {
        if (data.assets.boxFront.includes("header.jpg")) 
            return steamHero(data);
        else {
            if (data.assets.background != "")
                return data.assets.background;
            else if (data.assets.screenshots[0])
                return data.assets.screenshots[0];
        }
    }
    return "";
    }

    function logo(data) {
    if (data != null) {
        if (data.assets.boxFront.includes("header.jpg")) 
            return steamLogo(data);
        else {
            if (data.assets.logo != "")
                return data.assets.logo;
            }
        }
        return "";
    }

    
    Item {
    id: screenshotContainer

        width: outline.width
        height: outline.height
        scale: {
            if (selected)
                return 1;
            else if (highlighted) 
                return 0.97;
            else
                return 0.95;
        }

        Behavior on scale { NumberAnimation { duration: 50 } }

        Rectangle {
        id: highlightBorder

            width: screenshot.width + vpx(6)
            height: screenshot.height + vpx(6)
            color: "#ffffff"
            opacity: highlighted ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 50 } }
            radius: vpx(18)
            anchors.centerIn: screenshot
            visible: false
        }

        ItemOutline {
        id: outline 

            anchors.fill: screenshot
            radius: mask.radius - anchors.margins
            show: selected
            z: 15
        }
        
        /*Rectangle {
        id: innerBorder

            width: screenshot.width + vpx(6)
            height: screenshot.height + vpx(6)
            opacity: selected ? 1 : 0
            radius: vpx(18)
            anchors.centerIn: screenshot

            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#f34225" }
                GradientStop { position: 1.0; color: "#bb2960" }
            }
        }//*/

        Image {
        id: screenshot

            width: root.width
            height: width/1.6666
            //property var screenshotImage: (gameData && (gameData.collections.get(0).shortName === "retropie" || gameData.collections.get(0).shortName === "android")) ? gameData.assets.boxFront : (gameData.collections.get(0).shortName === "steam") ? fanArt(gameData) : gameData.assets.screenshots[0]
            source: gameData ? gameData.assets.screenshots[0] || "" : ""
            fillMode: Image.PreserveAspectCrop
            sourceSize: Qt.size(parent.width, parent.height)
            smooth: true
            asynchronous: true
            visible: false
        }
        
        
        Rectangle {
        id: mask

            anchors.fill: screenshot
            radius: vpx(15)
            visible: false
        }

        OpacityMask {
            anchors.fill: screenshot
            source: screenshot
            maskSource: mask
        }

        Rectangle {
        id: container

            width: screenshot.width
            height: screenshot.height
            radius: mask.radius
            color: "black"
            opacity: 0.7
            border.width: 1
            border.color: "#333333"
            visible: screenshot.paintedWidth < 1
        }

        Loader {
            anchors.fill: screenshot
            anchors.centerIn: screenshot
            sourceComponent: gameData /*&& !gameData.assets.screenshots[0]//*/ ? logo : undefined
        }
        
        Component {
        id: logo

            Image {
                anchors.fill: parent
                anchors.centerIn: parent
                anchors.margins: vpx(30)
                property var logoImage: {
                    if (gameData != null) {
                        if (gameData.collections.get(0).shortName === "retropie")
                            return gameData.assets.boxFront;
                        else if (gameData.collections.get(0).shortName === "steam")
                            return root.logo(gameData);
                        else 
                            return gameData.assets.logo;
                    } else {
                        return ""
                    }

                }
                /*gameData ? 
                    (gameData.collections.get(0).shortName === "retropie") ? 
                        gameData.assets.boxFront : 
                    (gameData.collections.get(0).shortName === "steam") ? 
                        logo(gameData) : 
                    gameData.assets.logo : 
                ""*/

                source: gameData ? logoImage || "" : ""
                sourceSize: Qt.size(parent.width, parent.height)
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                smooth: true
                z: 10
            }
        }
        
        Rectangle {
        id: favIcon

            width: vpx(26)
            height: width
            radius: width/2
            visible: isFave

            anchors {
                right: parent.right; rightMargin: vpx(15)
                top: parent.top; topMargin: vpx(10)
            }
            color: "black"
            opacity: 0.5
        }

        Image {
        id: star

            anchors.fill: favIcon
            anchors.margins: vpx(5)
            source: "assets/images/navigation/Favorites.png"
            sourceSize: Qt.size(favIcon.width, favIcon.height)
            smooth: true
            asynchronous: true
            fillMode: Image.PreserveAspectFit
            visible: false
        }

        ColorOverlay {
            anchors.fill: star
            source: star
            color: theme.highlight
            visible: isFave
        }

        // Mouse/touch functionality
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: { highlighted = true }
            onExited: { highlighted = false }
            onClicked: {
                launchGame(gameData);
                activated();
            }
        }
    }

    Text {
    id: gameTitle

        text: gameData ? gameData.title : "Nothing here"
        color: theme.text
        //scale: selected ? 1.1 : 1
        opacity: selected ? 1 : 0.5
        Behavior on opacity { NumberAnimation { duration: 50 } }
        font.pixelSize: vpx(18)
        font.family: subtitleFont.name
        font.bold: true
        elide: Text.ElideRight
        wrapMode: Text.WordWrap
        lineHeight: 0.8
        horizontalAlignment: Text.AlignHCenter
        anchors {
            top: screenshotContainer.bottom; topMargin: vpx(20);
            left: screenshotContainer.left; leftMargin: vpx(10);
            right: screenshotContainer.right; rightMargin: vpx(10)
        }
    }
    
}