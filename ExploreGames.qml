import QtQuick 2.12
import QtGraphicalEffects 1.0
import QtQml.Models 2.10
import QtMultimedia 5.9
import "Lists"
import "utils.js" as Utils
import "qrc:/qmlutils" as PegasusUtils

FocusScope {
id: root
    
    // Pull in our custom lists and define
    ListAllGames    { id: listNone;         max: 0 }
    ListAllGames    { id: listAllGames;     max: 15 }
    ListPublisher   { id: listPublisher;    max: 15 }
    ListTopGames    { id: listTopGames;     max: 15 }
    ListLastPlayed  { id: listLastPlayed;   max: 30 }
    ListFavorites   { id: listFavorites; }

    property alias menu: mainList
    property alias intro: introAnim
    property bool allGamesView: currentCollection == -1
    property var collectionData: !allGamesView ? api.collections.get(currentCollection) : null

    signal exit

    SequentialAnimation {
    id: introAnim

        running: true
        NumberAnimation { target: mainList; property: "opacity"; to: 0; duration: 100 }
        PauseAnimation  { duration: 400 }
        ParallelAnimation {
            NumberAnimation { target: mainList; property: "opacity"; from: 0; to: 1; duration: 400;
                easing.type: Easing.OutCubic;
                easing.amplitude: 2.0;
                easing.period: 1.5 
            }
            NumberAnimation { target: mainList; property: "y"; from: 50; to: 0; duration: 400;
                easing.type: Easing.OutCubic;
                easing.amplitude: 2.0;
                easing.period: 1.5 
            }
        }
    }

    ObjectModel {
    id: mainModel

        HorizontalList {
        id: favouriteList

            property bool selected: ListView.isCurrentItem && root.focus
            property var currentList
            property bool emptyList: listFavorites.games.count == 0 
            collectionData: emptyList ? listLastPlayed.games : listFavorites.games

            height: vpx(300)

            title: emptyList ? "Last played" : "Favorites"

            focus: selected
            anchors { left: parent.left; right: parent.right }
        }

        HorizontalList {
        id: topList

            property bool selected: ListView.isCurrentItem && root.focus
            property var currentList
            collectionData: listTopGames.games

            height: vpx(300)

            title: "Recommended"

            focus: selected
            anchors { left: parent.left; right: parent.right }
        }
    }

    ListView {
    id: mainList
        
        width: parent.width;
        height: parent.height;
        header: headerComponent
        model: mainModel
        focus: root.focus
        currentIndex: -1
        onFocusChanged: {
            if (focus)
                currentIndex = 0
        }

        anchors {
            left: parent.left; leftMargin: vpx(125)
            right: parent.right; rightMargin: vpx(125)
        }

        preferredHighlightBegin: vpx(50)
        preferredHighlightEnd: parent.height - vpx(100)
        //highlightRangeMode: ListView.ApplyRange
        //snapMode: ListView.SnapOneItem 
        highlightMoveDuration: 100

        Keys.onUpPressed: { 
            if (currentIndex == 0) {
                sfxBack.play();
                exit();
            } else {
                sfxNav.play(); 
                decrementCurrentIndex();
            }
        }
        Keys.onDownPressed: { sfxNav.play(); incrementCurrentIndex() }

        Component {
        id: headerComponent

            Item {
                width: mainList.width
                height: vpx(300)

                Image {
                id: collectionLogo

                    property string logoName: currentCollection != -1 ? Utils.processPlatformName(api.collections.get(currentCollection).shortName) : "allgames"
                    source: "assets/images/logos/" + logoName + ".png"
                    sourceSize: Qt.size(collectionLogo.width, collectionLogo.height)
                    width: vpx(300)
                    anchors { 
                        top: parent.top
                        bottom: parent.bottom; bottomMargin: vpx(50)
                        left: parent.left;
                    }
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    smooth: true
                    verticalAlignment: Image.AlignBottom
                }
            }
        }
    }
}