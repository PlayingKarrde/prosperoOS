import QtQuick 2.12
import QtQuick.Layouts 1.11
import SortFilterProxyModel 0.2
import QtMultimedia 5.9
import QtQml.Models 2.10
import QtGraphicalEffects 1.12
import "Lists"
import "utils.js" as Utils

FocusScope {
    id: root


    signal exitNav
    
    property alias currentIndex: gameNav.currentIndex
    property alias list: gameNav
    property bool active

    // Build the games list but with extra menu options at the start and end
    ListModel {
    id: gamesListModel

        property var activeCollection:  currentCollection!=-1 ? api.collections.get(currentCollection).games : api.allGames

        Component.onCompleted: {
            clear();
            buildList();
        }

        onActiveCollectionChanged: {
            clear();
            buildList();
        }

        function buildList() {
            activeCollection.toVarArray().map(g => g.lastPlayed).sort((a, b) => a > b);
            var gamesCounter = activeCollection.count > 10 ? 10 : activeCollection.count;
            append({
                "name":         "Explore", 
                "idx":          -1, 
                "icon":         "assets/images/navigation/Explore.png",
                "background":   ""
            })
            for(var i=0; i<gamesCounter; i++) {
                
                append(createListElement(i));
            }/*
            append({
                "name":         "Top Games", 
                "idx":          -2,
                "icon":         "assets/images/navigation/Top Rated.png",
                "background":   ""
            })//*/
            append({
                "name":         "All Games", 
                "idx":          -3,
                "icon":         "assets/images/navigation/All Games.png",
                "background":   ""
            })
        }
        
        function createListElement(i) {
            return {
                name:       activeCollection.get(i).title,
                idx:        i,
                icon:       activeCollection.get(i).assets.logo,
                background: activeCollection.get(i).assets.screenshots[0]
            }
        }
    }

    ListView {
    id: gameNav

        x: active ? vpx(125) : vpx(40)
        y: active ? vpx(0) : vpx(-50)

        Behavior on x { NumberAnimation { duration: 200; 
            easing.type: Easing.OutCubic;
            easing.amplitude: 2.0;
            easing.period: 1.5 
            }
        }
        Behavior on y { NumberAnimation { duration: 200; 
            easing.type: Easing.OutCubic;
            easing.amplitude: 2.0;
            easing.period: 1.5 
            }
        }

        width: parent.width

        Keys.onLeftPressed: {
            if (currentIndex > 0) {
                sfxNav.play();
                decrementCurrentIndex();
            }
        }
        Keys.onRightPressed: {
            if (currentIndex < count-1) {
                sfxNav.play();
                incrementCurrentIndex();
            }
        }

        focus: true
        onFocusChanged: {
            if (!focus)
                positionViewAtIndex = 0;
        }

        //Component.onCompleted: currentIndex = 1;

        orientation: ListView.Horizontal
        displayMarginBeginning: vpx(150)
        displayMarginEnd: vpx(150)
        preferredHighlightBegin: vpx(0)
        preferredHighlightEnd: vpx(0)
        highlightRangeMode: ListView.StrictlyEnforceRange
        snapMode: ListView.SnapOneItem 
        highlightMoveDuration: 100
        clip: false
        model: !searchtext ? gamesListModel : listSearch.games
        delegate: gameBarDelegate
            
    }
    
    Keys.onDownPressed: { 
        sfxAccept.play(); 
        exitNav(); 
    }

    Keys.onPressed: {                    
        // Accept
        if (api.keys.isAccept(event) && !event.isAutoRepeat) {
            event.accepted = true;
            sfxAccept.play();
            exitNav();
        }
    }

    Component {
    id: gameBarDelegate

        Item {
        id: gameItem
            
            property bool selected: ListView.isCurrentItem
            property var gameData: searchtext ? modelData : listRecent.currentGame(idx)
            property bool isGame: idx >= 0

            onGameDataChanged: { if (selected) updateData() }
            onSelectedChanged: { if (selected) updateData() }

            function updateData() {
                currentGame = gameData;
                currentScreenID = idx;
            }

            width: outline.width
            height: width
            opacity: active || selected ? 1 : 0

            // Highlight outline
            ItemOutline {
            id: outline 

                width: {
                    if (selected && active)
                        return vpx(125);
                    else if (selected && !active)
                        return vpx(65);
                    else
                        return vpx(85);
                }
                height: width
                Behavior on width { NumberAnimation { duration: 50 } }
                radius: active ? vpx(22) : vpx(10)
                show: selected && active
                z: 10
            }

            // Black bg
            Rectangle {
            id: imageBG

                anchors.fill: imageMask
                radius: imageMask.radius
                color: "black"
                opacity: 0.7
                visible: gameData ? !gameData.assets.screenshots[0] : true
            }

            Image {
            id: screenshot

                anchors.fill: imageMask
                source: gameData ? gameData.assets.screenshots[0] || gameData.assets.boxFront || "" : background
                fillMode: Image.PreserveAspectCrop
                sourceSize: Qt.size(vpx(125), vpx(125))
                smooth: true
                asynchronous: true
                visible: false

                Image {
                id: gameLogo

                    anchors.fill: parent
                    anchors.margins: isGame ? vpx(5) : vpx(20)
                    source: gameData ? Utils.logo(gameData) || "" : icon
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

                x: active ? vpx(130) : vpx(80)
                y: active ? vpx(85) : vpx(20)
                text: idx > -1 ? gameData.title : name
                font.family: subtitleFont.name
                font.pixelSize: vpx(20)
                color: "white"
                opacity: selected ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 50 } }
            }
        }
    }
}