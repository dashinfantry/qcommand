import QtQuick 2.0
import Sailfish.Silica 1.0
import '../src'

Page {
    property string result

    Connections {
        target: cengine
        onOutput: {
           result = data
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height

        Column {
            id: content
            width: parent.width

            PageHeader {
                title: qsTr('output')
            }

            TextArea {
                width: parent.width
                text: result
                readOnly: true
            }
        }

        VerticalScrollDecorator {
        }
    }
}
