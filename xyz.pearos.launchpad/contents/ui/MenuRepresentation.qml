/***************************************************************************
 *   Copyright (C) 2014 by Weng Xuetian <wengxt@gmail.com>
 *   Copyright (C) 2013-2017 by Eike Hein <hein@kde.org>                   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.private.kicker 0.1 as Kicker

import org.kde.kquickcontrolsaddons 2.0
import org.kde.kwindowsystem 1.0
import org.kde.plasma.private.shell 2.0

import "../code/tools.js" as Tools
import QtQuick.Window 2.0
import QtQuick.Controls.Styles 1.4


Kicker.DashboardWindow {
    
    id: root

    property int iconSize:    plasmoid.configuration.iconSize
    property int spaceWidth:  plasmoid.configuration.spaceWidth
    property int spaceHeight: plasmoid.configuration.spaceHeight
    property int cellSizeWidth: spaceWidth + iconSize + theme.mSize(theme.defaultFont).height
                                + (2 * units.smallSpacing)
                                + (2 * Math.max(highlightItemSvg.margins.top + highlightItemSvg.margins.bottom,
                                                highlightItemSvg.margins.left + highlightItemSvg.margins.right))

    property int cellSizeHeight: spaceHeight + iconSize + theme.mSize(theme.defaultFont).height
                                 + (2 * units.smallSpacing)
                                 + (2 * Math.max(highlightItemSvg.margins.top + highlightItemSvg.margins.bottom,
                                                 highlightItemSvg.margins.left + highlightItemSvg.margins.right))


    property bool searching: (searchField.text != "")

    keyEventProxy: searchField
    backgroundColor: "transparent"

    property bool linkUseCustomSizeGrid: plasmoid.configuration.useCustomSizeGrid
    property int gridNumCols:  plasmoid.configuration.useCustomSizeGrid ? plasmoid.configuration.numberColumns : Math.floor(width  * 0.85  / cellSizeWidth) // TODO: set from settings
    property int gridNumRows:  plasmoid.configuration.useCustomSizeGrid ? plasmoid.configuration.numberRows : Math.floor(height * 0.8  /  cellSizeHeight)  // TODO: set from settings
    property int widthScreen:  gridNumCols * cellSizeWidth
    property int heightScreen: gridNumRows * cellSizeHeight




    function colorWithAlpha(color, alpha) {
        return Qt.rgba(color.r, color.g, color.b, alpha)
    }

    onKeyEscapePressed: {
        if (searching) {
            searchField.text = ""
        } else {
            root.toggle();
        }
    }

    onVisibleChanged: {
        animationSearch.start()

        reset();
        rootModel.pageSize = gridNumCols*gridNumRows
        pageList.currentIndex = 1;
    }

    onSearchingChanged: {
        if (searching) {
            pageList.model = runnerModel;
            paginationBar.model = runnerModel;
        } else {
            reset();
        }
    }

    function reset() {
        if (!searching) {
            pageList.model = rootModel.modelForRow(0);
            paginationBar.model = rootModel.modelForRow(0);
        }
        searchField.text = "";
        pageListScrollArea.focus = true;
        pageList.currentIndex = 1;
    }



        Image {
            id: mybackground
            visible: plasmoid.configuration.backgroundImageCheckBox
            anchors.fill: parent;
            source: plasmoid.configuration.backgroundImage
            fillMode: Image.PreserveAspectCrop;
        }

    mainItem:
        Rectangle{

        anchors.fill: parent
        color: 'transparent'
        }
        MouseArea {

            id: mainItemRoot
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            LayoutMirroring.enabled: Qt.application.layoutDirection == Qt.RightToLeft
            LayoutMirroring.childrenInherit: true
            focus: true

            ScaleAnimator{
                id: animationSearch
                from: 1.1
                to: 1
                target: mainItemRoot
            }

            onClicked: {
                root.toggle();
            }

                    Rectangle{
            anchors.fill: parent
            color: colorWithAlpha(Qt.rgba(0, 0, 0, 1), plasmoid.configuration.dimming / 100)
        }

            PlasmaExtras.Heading {
                id: dummyHeading
                visible: true
                width: 0
                level: 5
            }

            TextMetrics {
                id: headingMetrics
               font: dummyHeading.font
            }

            ActionMenu {
                id: actionMenu
                onActionClicked: visualParent.actionTriggered(actionId, actionArgument)
                onClosed: {
                    if (pageList.currentItem) {
                        pageList.currentItem.itemGrid.currentIndex = -1;
                    }
                }
            }

            Rectangle{
                anchors.horizontalCenter: searchField.horizontalCenter
                //y: searchField.y + searchField.height
                y: searchField.y
                width: searchField.width
                height: searchField.height
                border.width: 1
                border.color: Qt.rgba(255,255,255, 0.3)
                color: "transparent"
                radius: searchField.height*0.2
                z: 2
            }

            PlasmaComponents.TextField {
                id: searchField
                z: 1
                anchors.top: parent.top
                anchors.topMargin: units.iconSizes.large
                anchors.horizontalCenter: parent.horizontalCenter
                width: units.gridUnit * 18
                height: units.gridUnit * 2
                font.pointSize: units.gridUnit * 0.9
                focus: true                //placeholderText: i18n("<font color='"+ Qt.rgba(255,255,255, 0.3) +"'>Search</font>")
                placeholderText: i18n("<font color='"+ colorWithAlpha(Qt.rgba(255,255,255, 1), plasmoid.configuration.searchopacity / 100) +"'>Search</font>")
                //textColor: Qt.rgba(255,255,255, 1)
                opacity: 0.3
                clearButtonShown: flase
                horizontalAlignment: TextInput.AlignHCenter
                onTextChanged: {
                    runnerModel.query = text;
                }

                        onFocusChanged: {
            if (focus) {
                // FIXME: Cleanup arbitration between rootList/runnerCols here and in Keys.
                if (rootList.visible) {
                    rootList.currentIndex = -1;
                }

                if (runnerColumns.visible) {
                    runnerColumnsRepeater.itemAt(0).currentIndex = -1;
                }
            }
        }

        function clear() {
                text = "";
            }

        PlasmaComponents.ToolButton {
            id: cancelSearchButton

            anchors {
                right: searchField.right
                rightMargin: 1
                verticalCenter: searchField.verticalCenter
            }

            //width: units.iconSizes.medium

            width:  searchField.height - 0.5
            height: width

            visible: (searchField.text != "")

            iconName:  Qt.resolvedUrl("assets/clear.svg")
            flat: true

            onClicked: searchField.clear();

            Keys.onPressed: {
                if (event.key === Qt.Key_Tab) {
                    event.accepted = true;

                    if (runnerModel.count) {
                        mainColumn.tryActivate(0, 0);
                    } else {
                        systemFavoritesGrid.tryActivate(0, 0);
                    }
                } else if (event.key === Qt.Key_Backtab) {
                    event.accepted = true;

                    if (tabBar.visible) {
                        tabBar.focus = true;
                    } else if (globalFavoritesGrid.enabled) {
                        globalFavoritesGrid.tryActivate(0, 0);
                    } else {
                        systemFavoritesGrid.tryActivate(0, 0);
                    }
                }
            }
        }

              style: TextFieldStyle {
                    textColor: colorWithAlpha(Qt.rgba(255,255,255, 1), plasmoid.configuration.searchopacity / 100)
                    background: Rectangle {
                        radius: height*0.2
                        color: colorWithAlpha(Qt.rgba(255,255,255, 1), plasmoid.configuration.searchopacity / 100)
                    }
                }
                Keys.onPressed: {
                    if (event.key == Qt.Key_Down) {
                        event.accepted = true;
                        pageList.currentItem.itemGrid.tryActivate(0, 0);
                    } else if (event.key == Qt.Key_Right) {
                        if (cursorPosition == length) {
                            event.accepted = true;

                            if (pageList.currentItem.itemGrid.currentIndex == -1) {
                                pageList.currentItem.itemGrid.tryActivate(0, 0);
                            } else {
                                pageList.currentItem.itemGrid.tryActivate(0, 1);
                            }
                        }
                    } else if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter) {
                        if (text != "" && pageList.currentItem.itemGrid.count > 0) {
                            event.accepted = true;
                            pageList.currentItem.itemGrid.tryActivate(0, 0);
                            pageList.currentItem.itemGrid.model.trigger(0, "", null);
                            root.toggle();
                        }
                    } else if (event.key == Qt.Key_Tab) {
                        event.accepted = true;
                        //systemFavoritesGrid.tryActivate(0, 0);
                    } else if (event.key == Qt.Key_Backtab) {
                        event.accepted = true;

                        if (!searching) {
                            pageList.currentIndex = 1;
                            filterList.forceActiveFocus();
                        } else {
                            //systemFavoritesGrid.tryActivate(0, 1);
                        }
                    }
                }

                function backspace() {
                    if (!root.visible) {
                        return;
                    }
                    focus = true;
                    text = text.slice(0, -1);

                }

                function appendText(newText) {
                    if (!root.visible) {
                        return;
                    }
                    focus = true;
                    text = text + newText;
                }
            }
               Image {
            id: searchIcon
            visible: true
            width:  searchField.height - 2
            height: width
            source: Qt.resolvedUrl("assets/search32.svg");
            anchors {
                    left: searchField.left
                    leftMargin: 10
                    verticalCenter: searchField.verticalCenter
                }

        }


            Rectangle{
                width:   widthScreen
                height:  heightScreen
                color: "transparent"
                anchors {
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: parent.horizontalCenter
                }
                PlasmaExtras.ScrollArea {
                    id: pageListScrollArea
                    width: parent.width
                    height: parent.height
                    focus: true;
                    frameVisible: false;
                    horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
                    verticalScrollBarPolicy: Qt.ScrollBarAlwaysOff

                    ListView {
                        id: pageList
                        anchors.fill: parent
                        snapMode: ListView.SnapOneItem
                        orientation: Qt.Horizontal
                         onCurrentIndexChanged: {
                    if (!plasmoid.configuration.animateScroll) {
                    positionViewAtIndex(currentIndex, ListView.Contain);
                            }
                        }
                        onCurrentItemChanged: {
                            if (!currentItem) {
                                return;
                            }
                            currentItem.itemGrid.focus = true;
                        }
                        onModelChanged: {
                            if(searching)  {
                                currentIndex = 0;
                            }
                            else{
                                currentIndex = 1;
                            }
                        }
                    	onMovingChanged: {
                        if (!moving) {
                            var pos = mapToItem(contentItem, width / 2, height / 2);
                            currentIndex = indexAt(pos.x, pos.y);
                        highlightMoveDuration: (700 - plasmoid.configuration.animateScrollSpeed)

                        function cycle() {
                            enabled = false;
                            enabled = true;
                        }

                        function activateNextPrev(next) {
                            if (next) {
                                var newIndex = pageList.currentIndex + 1;

                                if (newIndex < pageList.count) {
                                    pageList.currentIndex = newIndex;
                                }

                            } else {
                                var newIndex = pageList.currentIndex - 1;

                                if (newIndex >= 1) {
                                    pageList.currentIndex = newIndex;
                                }

                            }
                        }

                        delegate: Item {

                            width:   gridNumCols * cellSizeWidth
                            height:  gridNumRows * cellSizeHeight

                            property Item itemGrid: gridView

                            ItemGridView {
                                id: gridView

                                visible: model.count > 0
                                anchors.fill: parent

                                cellWidth:  cellSizeWidth
                                cellHeight: cellSizeHeight

                                horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
                                verticalScrollBarPolicy: Qt.ScrollBarAlwaysOff

                                dragEnabled: (index == 0)

                                model: searching ? runnerModel.modelForRow(index) : rootModel.modelForRow(0).modelForRow(index)
                                onCurrentIndexChanged: {
                                    if (currentIndex != -1 && !searching) {
                                        pageListScrollArea.focus = true;
                                        focus = true;
                                    }
                                    //if(!visible && (currentIndex + 1) < pageList.count ){
                                    //    currentIndex = currentIndex + 1
                                    //}
                                }

                                onCountChanged: {
                                    if (searching && index == 0) {
                                        currentIndex = 0;
                                    }
                                }

                                onKeyNavUp: {
                                    currentIndex = -1;
                                    searchField.focus = true;
                                }

                                onKeyNavDown: {

                                }
                                onKeyNavRight: {
                                    var newIndex = pageList.currentIndex + 1;
                                    if (newIndex < pageList.count) {
                                        pageList.currentIndex = newIndex;
                                        pageList.currentItem.itemGrid.tryActivate(0, 0);
                                    }
                                }

                                onKeyNavLeft: {
                                    var newIndex = pageList.currentIndex - 1;
                                    if (newIndex > 0) {
                                        pageList.currentIndex = newIndex;
                                        pageList.currentItem.itemGrid.tryActivate(0, 0);
                                    }
                                }
                            }

                            Kicker.WheelInterceptor {
                                anchors.fill: parent
                                z: 1

                                property int wheelDelta: 0

                                function scrollByWheel(wheelDelta, eventDelta) {
                                    // magic number 120 for common "one click"
                                    // See: http://qt-project.org/doc/qt-5/qml-qtquick-wheelevent.html#angleDelta-prop
                                    wheelDelta += eventDelta;

                                    var increment = 0;

                                    while (wheelDelta >= 120) {
                                        wheelDelta -= 120;
                                        increment++;
                                    }

                                    while (wheelDelta <= -120) {
                                        wheelDelta += 120;
                                        increment--;
                                    }

                                    while (increment != 0) {
                                        pageList.activateNextPrev(increment < 0);
                                        increment += (increment < 0) ? 1 : -1;
                                    }

                                    return wheelDelta;
                                }

                                onWheelMoved: {
                                    wheelDelta = scrollByWheel(wheelDelta, delta.x);
                                    wheelDelta = scrollByWheel(wheelDelta, delta.y);
                                }
                            }
                        }
                    }
                }

            }
            ListView {
                id: paginationBar

                anchors {
                    bottom: parent.bottom
                    bottomMargin: units.largeSpacing
                    horizontalCenter: parent.horizontalCenter
                }
                width: model.count * units.iconSizes.smallMedium
                height:  units.largeSpacing * 3
                orientation: Qt.Horizontal

                delegate: Item {
                    width: units.iconSizes.small
                    height: width

                    Rectangle {
                        id: pageDelegate
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            verticalCenter: parent.verticalCenter
                            margins: 10
                        }
                        width: parent.width  * 0.75
                        height: width

                        property bool isCurrent: (pageList.currentIndex == index)

                        radius: width / 2
                        color: Qt.rgba(255,255,255, 1)
                        visible: (index != 0)
                        opacity: 0.5
                        Behavior on width { SmoothedAnimation { duration: units.longDuration; velocity: 0.01 } }
                        Behavior on opacity { SmoothedAnimation { duration: units.longDuration; velocity: 0.01 } }

                        states: [
                            State {
                                when: pageDelegate.isCurrent
                                PropertyChanges { target: pageDelegate; width: parent.width - (units.smallSpacing * 0.75) }
                                PropertyChanges { target: pageDelegate; opacity: 1 }
                            }
                        ]
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: pageList.currentIndex = index;

                        property int wheelDelta: 0

                        function scrollByWheel(wheelDelta, eventDelta) {
                            // magic number 120 for common "one click"
                            // See: http://qt-project.org/doc/qt-5/qml-qtquick-wheelevent.html#angleDelta-prop
                            wheelDelta += eventDelta;

                            var increment = 0;

                            while (wheelDelta >= 50) {
                                wheelDelta -= 50;
                                increment++;
                            }

                            while (wheelDelta <= -50) {
                                wheelDelta += 50;
                                increment--;
                            }

                            while (increment != 0) {
                                pageList.activateNextPrev(increment < 0);
                                increment += (increment < 0) ? 1 : -1;
                            }

                            return wheelDelta;
                        }

                        onWheel: {
                            wheelDelta = scrollByWheel(wheelDelta, wheel.angleDelta.y,wheel.angleDelta.x);
                        }
                    }
                }
            }

            Keys.onPressed: {
                if (event.key == Qt.Key_Escape) {
                    event.accepted = true;

                    if (searching) {
                        reset();
                    } else {
                        root.toggle();
                    }

                    return;
                }

                if (searchField.focus) {
                    return;
                }

                if (event.key == Qt.Key_Backspace) {
                    event.accepted = true;
                    searchField.backspace();
                } else if (event.key == Qt.Key_Tab || event.key == Qt.Key_Backtab) {
                    if (pageListScrollArea.focus == true && pageList.currentItem.itemGrid.currentIndex == -1) {
                        event.accepted = true;
                        pageList.currentItem.itemGrid.tryActivate(0, 0);
                    }
                } else if (event.text != "") {
                    event.accepted = true;
                    searchField.appendText(event.text);
                }
            }






    Component.onCompleted: {
        rootModel.pageSize = gridNumCols*gridNumRows
        pageList.model = rootModel.modelForRow(0);
        paginationBar.model = rootModel.modelForRow(0);
        searchField.text = "";
        pageListScrollArea.focus = true;
        pageList.currentIndex = 1;
        kicker.reset.connect(reset);

    }
 }
}
