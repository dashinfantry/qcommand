import QtQuick 2.0
import Sailfish.Silica 1.0
import '../src'

CoverBackground {
    id: cover

    property ApplicationWindow app
    property Database database
    property CommandEngine engine
    property int rowid
    property string name
    property string command
    property bool has_output
    property string cover_group
    property bool is_interactive
    property string visibleName

    Label {
        id: header
        x: Theme.horizontalPageMargin
        y: Theme.horizontalPageMargin
        font.pixelSize: Theme.fontSizeLarge
        text: 'qCommand'
        color: Theme.highlightColor
    }

    Label {
        x: Theme.horizontalPageMargin
        y: header.height + Theme.fontSizeLarge + Theme.paddingLarge
        width: parent.width - Theme.horizontalPageMargin * 2
        height: parent.height - header.height - Theme.fontSizeLarge - Theme.paddingLarge - cover.coverActionArea.height
        wrapMode: Label.Wrap
        truncationMode: TruncationMode.Elide
        text: visibleName
    }

    CoverActionList {
        enabled: rowid

        CoverAction {
            iconSource: 'image://theme/icon-cover-play'
            onTriggered: {
                if (has_output) {
                    var resultPage = pageStack.find(function(page) {
                        return page.objectName === 'result'
                    })
                    if (resultPage) {
                        pageStack.pop(resultPage, true);
                        pageStack.pop(null, true)
                    }
                    pageStack.push(Qt.resolvedUrl('../pages/ResultPage.qml'), {name: name}, true)
                    app.activate()
                }
                if (is_interactive) {
                    engine.execInteractive(command)
                } else {
                    engine.exec(command, has_output)
                }
                next()
            }
        }

        CoverAction {
            iconSource: 'image://theme/icon-cover-next-song'
            onTriggered: {
                nextGroup()
            }
        }
    }

    function set(item) {
        if (!item.cover_group) {
            return;
        }
        if (item.rowid) {
            rowid = item.rowid
        }
        name = item.name || ''
        command = item.command || ''
        has_output = item.has_output || false
        cover_group = item.cover_group
        is_interactive = item.is_interactive
        visibleName = cover_group + '\n' + name.substr(cover_group.length).trim()
    }

    function next() {
        database.readNext(cover, set, nextGroup)
    }

    function nextGroup() {
        database.readNextGroup(cover, set)
    }

    Component.onCompleted: {
        database.edited.connect(function(item, data) {
            if (item.rowid === rowid) {
                set(data)
            }
        })
        database.removed.connect(function(item) {
            if (item.rowid === rowid) {
                next()
            }
        })
        database.added.connect(function(item) {
            if (!rowid) {
                set(item)
            }
        })
    }
}


