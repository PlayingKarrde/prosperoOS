import QtQuick 2.3
import QtQuick.Layouts 1.11
import "Lists"

FocusScope {
id: root

    property var collectionData: api.collections.get(0).games
    property int itemWidth: vpx(250)
    property int itemHeight: itemWidth*0.6
    property alias currentIndex: collectionList.currentIndex
    property alias savedIndex: collectionList.savedIndex
    property alias title: collectiontitle.text
    property alias model: collectionList.model
    property alias delegate: collectionList.delegate
    property alias collectionList: collectionList
    property var search

    signal activate(int activeIndex)
    signal activateSelected
    signal listHighlighted

    Text {
    id: collectiontitle

        text: collectionData.name
        font.family: subtitleFont.name
        font.pixelSize: vpx(20)
        font.bold: true
        color: theme.text
        opacity: root.focus ? 1 : 0.5
        anchors { left: parent.left; top: parent.top; topMargin: vpx(5) }
        height: vpx(50)
    }

    ListView {
    id: collectionList

        focus: root.focus
        anchors {
            top: collectiontitle.bottom; topMargin: vpx(10)
            left: parent.left; 
            right: parent.right;
            bottom: parent.bottom
        }
        spacing: vpx(5)
        orientation: ListView.Horizontal
        preferredHighlightBegin: vpx(0)
        preferredHighlightEnd: parent.width
        highlightRangeMode: ListView.ApplyRange
        snapMode: ListView.SnapOneItem 
        highlightMoveDuration: 100
        displayMarginEnd: itemWidth*2
        
        property int savedIndex: 0
        onFocusChanged: {
            if (focus)
                currentIndex = savedIndex;
            else {
                savedIndex = currentIndex;
                currentIndex = -1;
            }
                
        }

        currentIndex: focus ? savedIndex : -1
        Component.onCompleted: positionViewAtIndex(savedIndex, ListView.Visible)

        model: collectionData
        delegate: GridItem {
            selected: ListView.isCurrentItem && collectionList.focus
            gameData: modelData
            radius: vpx(2)

            // List specific input
            Keys.onPressed: {                
                // Back
                if (api.keys.isCancel(event) && !event.isAutoRepeat) {
                    event.accepted = true;
                    sfxBack.play();
                    navigationMenu();
                }

                // Favorites
                if (api.keys.isDetails(event) && !event.isAutoRepeat) {
                    event.accepted = true;
                    sfxToggle.play();
                    modelData.favorite = !modelData.favorite;
                }
            }
        }

        Keys.onLeftPressed: {
            if (currentIndex != 0) { 
                sfxNav.play(); 
                collectionList.decrementCurrentIndex();
            }
        }
        Keys.onRightPressed: { 
            if (currentIndex < count-1) {
                sfxNav.play(); 
                collectionList.incrementCurrentIndex();
            }
        }
    }

    GridItem {
        selected: root.focus
        visible: collectionList.count == 0
        radius: vpx(2)
        anchors { top: collectiontitle.bottom; topMargin: vpx(10) }
    }

}