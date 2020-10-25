import QtQuick 2.12
import QtQuick.Layouts 1.11
import SortFilterProxyModel 0.2
import QtMultimedia 5.9
import QtGraphicalEffects 1.12
import "Lists"
import "utils.js" as Utils

FocusScope {
    id: root

    FontLoader { id: titleFont; source: "assets/fonts/HelveticaNowText-Bold.ttf" }
    FontLoader { id: subtitleFont; source: "assets/fonts/HelveticaNowText-Light.ttf" }
    FontLoader { id: bodyFont; source: "assets/fonts/HelveticaNowText-Regular.ttf" }
    
    ListLastPlayed  { id: listRecent; max: 10 }
    ListAllGames    { id: listSearch; searchTerm: searchtext }
    
    property int currentCollection: api.memory.has('Last Collection') ? api.memory.get('Last Collection') : -1
    property int nextCollection: api.memory.has('Last Collection') ? api.memory.get('Last Collection') : -1
    property var currentGame
    property string searchtext

    onNextCollectionChanged: { changeCollection() }
    
    function changeCollection() {
        if (nextCollection != currentCollection) {
            currentCollection = nextCollection;
            searchtext = ""
            gameBar.currentIndex = 1;
        }
    }

    // Launch the current game
    function launchGame(game) {
        api.memory.set('Last Collection', currentCollection);
        if (game != null)
            game.launch();
        else
            currentGame.launch();
    }

    // Theme settings
    property var theme: {
        return {
            main:       "#ffffff",
            secondary:  "#202a44",
            accent:     "#f00980",
            highlight:  "#e3d810",
            text:       "#fff",
            button:     "#f00980"
        }
    }

    // State settings
    states: [
        State {
            name: "explore";
        },
        State {
            name: "allgames";
        },
        State {
            name: "topgames";
        },
        State {
            name: "gamedetails";
        },
        State {
            name: "settings";
        }
    ]

    property var lastState: []
    property var currentView: gameDetails
    property var nextView: gameDetails
    property string nextState: "gamedetails"
    property bool collectionMenuOpen
    
    onNextStateChanged: { changeState() }

    property int currentScreenID: 0
    onCurrentScreenIDChanged: {
        switch(currentScreenID) {
            case -1:
                explore();
                break;
            case -3:
                allgames();
                break;
            case -2:
                topgames();
                break;
            default:
                gamedetails();
        }
        changeState();
    }

    function changeState() {
        if (nextState != root.state) {
            lastState.push(root.state);
            root.state = nextState;
            currentView = nextView;
            resetLists();
        }
    }

    function explore() {
        nextView = exploreScreen;
        nextState = "explore";
        exploreScreen.menu.opacity = 0;
        exploreScreen.intro.restart();
    }

    function allgames() {
        nextView = gameGrid;
        nextState = "allgames";
        gameGrid.menu.opacity = 0;
        gameGrid.intro.restart();
    }

    function topgames() {
        nextView = gameGrid;
        nextState = "topgames";
        gameGrid.menu.opacity = 0;
        gameGrid.intro.restart();
    }

    function gamedetails() {
        nextView = gameDetails;
        nextState = "gamedetails";
    }

    function search() {
        nextView = searchGrid;
        nextState = "search";
    }

    function navigationMenu() {
        gameDetails.menu.currentIndex = 0;
        gameBar.focus = true;
    }

    function mainView() {
        currentView.focus = true;
    }

    function resetLists() {
        gameGrid.menu.currentIndex = 0;
        //collectionView.menu.currentIndex = 0;
    }

    Component.onCompleted: {
        currentCollection = api.memory.has('Last Collection') ? api.memory.get('Last Collection') : -1
        api.memory.unset('Last Collection');
    }

    // List specific input
    Keys.onPressed: {
        // Open collections menu
        if (api.keys.isFilters(event) && !event.isAutoRepeat) {
            event.accepted = true;
        }

        // Cycle collection forward
        if (api.keys.isNextPage(event) && !event.isAutoRepeat) {
            event.accepted = true;
            sfxToggle.play();
            navigationMenu();
            if (currentCollection < api.collections.count-1) {
                nextCollection++;
            } else {
                nextCollection = -1;
            }
        }

        // Cycle collection back
        if (api.keys.isPrevPage(event) && !event.isAutoRepeat) {
            event.accepted = true;
            sfxToggle.play();
            navigationMenu();
            if (currentCollection == -1) {
                nextCollection = api.collections.count-1;
            } else{ 
                nextCollection--;
            }
        }
    }

    // Background
    Item {
    id: background
        
        anchors.fill: parent

        property string bgImage1
        property string bgImage2
        property bool firstBG: true
        
        property var bgData: currentGame
        property string bgSource: bgData ? Utils.fanArt(bgData) || bgData.assets.screenshots[0] : ""
        onBgSourceChanged: { if (bgSource != "") swapImage(bgSource) }

        states: [
            State { // this will fade in gameBG2 and fade out gameBG1
                name: "fadeInRect2"
                PropertyChanges { target: gameBG1; opacity: 0}
                PropertyChanges { target: gameBG2; opacity: 1}
            },
            State   { // this will fade in gameBG1 and fade out gameBG2
                name:"fadeOutRect2"
                PropertyChanges { target: gameBG1;opacity:1}
                PropertyChanges { target: gameBG2;opacity:0}
            }
        ]

        transitions: [
            Transition {
                NumberAnimation { property: "opacity"; easing.type: Easing.InOutQuad; duration: 300  }
            }
        ]

        function swapImage(newSource) {
            if (firstBG) {
                // Go to second image
                if (newSource)
                    bgImage2 = newSource

                firstBG = false
                } else {
                // Go to first image
                if (newSource)
                    bgImage1 = newSource

                firstBG = true
            }
            background.state = background.state == "fadeInRect2" ? "fadeOutRect2" : "fadeInRect2"
        }

        Image {
        id: gameBG1

            anchors.fill: parent
            source: background.bgImage1
            fillMode: Image.PreserveAspectCrop
            sourceSize: Qt.size(parent.width, parent.height)
            smooth: true
            asynchronous: true
            visible: currentScreenID >= 0
        }

        Image {
        id: gameBG2

            anchors.fill: parent
            source: background.bgImage2
            fillMode: Image.PreserveAspectCrop
            sourceSize: Qt.size(parent.width, parent.height)
            smooth: true
            asynchronous: true
            visible: currentScreenID >= 0
        }

        Image {
        id: blurBG

            anchors.fill: parent
            source: "assets/images/blurbg.png"
            sourceSize: Qt.size(parent.width, parent.height)
            opacity: 0.9
        }
    }

    // Collection bar
    Item {
    id: collectionList

        width: parent.width
        height: vpx(90)
        opacity: gameBar.active ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 50 } }

        // Build the collections list but with "All Games" as starting element
        ListModel {
        id: collectionsModel

            ListElement { name: "All Games"; shortName: "allgames"; games: "0" }

            Component.onCompleted: {
                for(var i=0; i<api.collections.count; i++) {
                    append(createListElement(i));
                }
            }
            
            function createListElement(i) {
                return {
                    name:       api.collections.get(i).name,
                    shortName:  api.collections.get(i).shortName,
                    games:      api.collections.get(i).games.count.toString()
                }
            }
        }
        
        // Collections
        ListView {
        id: collectionNav

            anchors {
                left: parent.left; leftMargin: vpx(75)
                right: searchButton.left; rightMargin: vpx(150)
                top: parent.top; bottom: parent.bottom
            }
            
            orientation: ListView.Horizontal
            preferredHighlightBegin: vpx(0)
            preferredHighlightEnd: vpx(0)
            highlightRangeMode: ListView.StrictlyEnforceRange
            snapMode: ListView.SnapOneItem 
            highlightMoveDuration: 100
            currentIndex: currentCollection+1
            clip: true
            interactive: false
            model: collectionsModel
            delegate: 
                Text {
                    property bool selected: ListView.isCurrentItem
                    text:name
                    color: "white"
                    font.family: selected ? titleFont.name : subtitleFont.name
                    font.pixelSize: vpx(24)
                    width: implicitWidth + vpx(35)
                    height: collectionNav.height
                    verticalAlignment: Text.AlignVCenter
                }

            visible: false
        }

        Rectangle {
        id: navMask

            anchors.fill: collectionNav
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.9; color: "white" }
                GradientStop { position: 1.0; color: "transparent" }
            }
            visible: false
        }

        OpacityMask {
            anchors.fill: collectionNav
            source: collectionNav
            maskSource: navMask
        }

        // Navigation
        Image {
        id: searchButton

            width: vpx(25)
            height: width
            source: "assets/images/Search.png"
            sourceSize: Qt.size(parent.width, parent.height)
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            smooth: true
            anchors {
                verticalCenter: parent.verticalCenter
                right: settingsButton.left; rightMargin: vpx(50)
            }
        }

        Image {
        id: settingsButton

            width: vpx(25)
            height: width
            source: "assets/images/Settings.png"
            sourceSize: Qt.size(parent.width, parent.height)
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            smooth: true
            anchors {
                verticalCenter: parent.verticalCenter
                right: sysTime.left; rightMargin: vpx(50)
            }
        }
        

        Text {
        id: sysTime

            function set() {
                sysTime.text = Qt.formatTime(new Date(), "hh:mm")
            }

            Timer {
                id: textTimer
                interval: 60000 // Run the timer every minute
                repeat: true
                running: true
                triggeredOnStart: true
                onTriggered: sysTime.set()
            }

            anchors {
                top: parent.top; bottom: parent.bottom
                right: parent.right; rightMargin: vpx(75)
            }
            color: "white"
            font.pixelSize: vpx(24)
            font.family: subtitleFont.name
            horizontalAlignment: Text.Right
            verticalAlignment: Text.AlignVCenter
        }
    }

    // Game bar
    GameBar {
    id: gameBar

        width: parent.width
        height: focus ? vpx(125) : vpx(15)
        Behavior on height { NumberAnimation { duration: 200; 
            easing.type: Easing.OutCubic;
            easing.amplitude: 2.0;
            easing.period: 1.5 
            }
        }
        anchors {
            top: collectionList.bottom
        }
        focus: true
        active: focus
        //list.model: listRecent.games
        onExitNav: mainView();
        
        Component.onCompleted: currentIndex = 1;
        
    }


    // Game details
    GameDetails {
    id: gameDetails

        anchors {
            top: gameBar.bottom;
            bottom: parent.bottom;
            left: parent.left; right: parent.right
        }
        width: root.width
        gameData: currentGame
        onExit: { gameBar.focus = true; } 
        visible: false
    }

    Rectangle {
    id: detailsMask

        anchors.fill: gameDetails
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.1; color: "white" }
        }
        visible: false
    }

    OpacityMask {
    id: detailsOpacityMask
    
        anchors.fill: gameDetails
        source: gameDetails
        maskSource: detailsMask
        visible: root.state == "gamedetails"
    }

    GameGrid {
    id: gameGrid

        anchors {
            top: gameBar.bottom;
            bottom: parent.bottom
        }
        width: root.width
        currentState: root.state
        onExit: { gameBar.focus = true; } 
        visible: false
    }

    OpacityMask {
    id: gridOpacityMask

        anchors.fill: gameGrid
        source: gameGrid
        maskSource: detailsMask
        visible: root.state == "allgames" || root.state == "topgames"
    }

    ExploreGames {
    id: exploreScreen

        anchors {
            top: gameBar.bottom;
            bottom: parent.bottom
        }
        width: root.width
        onExit: { gameBar.focus = true; } 
        visible: false
    }

    OpacityMask {
    id: exploreOpacityMask

        anchors.fill: gameGrid
        source: exploreScreen
        maskSource: detailsMask
        visible: root.state == "explore"
    }

    ///////////////////
    // SOUND EFFECTS //
    ///////////////////
    SoundEffect {
        id: sfxNav
        source: "assets/sfx/navigation.wav"
        volume: 1.0
    }

    SoundEffect {
        id: sfxBack
        source: "assets/sfx/back.wav"
        volume: 1.0
    }

    SoundEffect {
        id: sfxAccept
        source: "assets/sfx/accept.wav"
    }

    SoundEffect {
        id: sfxToggle
        source: "assets/sfx/toggle.wav"
    }

}