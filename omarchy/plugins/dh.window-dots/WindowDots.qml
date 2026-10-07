import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

// One copy per bar: a dot per window on the workspace visible on this bar's
// monitor, the focused window filled. Hidden on an empty workspace.
BarWidget {
  id: root
  moduleName: "dh.window-dots"

  readonly property var hostScreen: root.QsWindow && root.QsWindow.window ? root.QsWindow.window.screen : null
  readonly property var hostMonitor: hostScreen ? Hyprland.monitorFor(hostScreen) : null
  readonly property var hostWorkspace: hostMonitor ? hostMonitor.activeWorkspace : null

  readonly property var windows: hostWorkspace ? hostWorkspace.toplevels.values : []
  readonly property var focused: Hyprland.activeToplevel

  visible: windows.length > 0
  implicitWidth: visible ? row.implicitWidth + Style.spacing.controlPaddingX : 0
  implicitHeight: barSize

  Row {
    id: row
    anchors.centerIn: parent
    spacing: 4

    Repeater {
      model: root.windows

      Text {
        required property var modelData
        readonly property bool isFocused: !!root.focused && root.focused.address === modelData.address

        text: isFocused ? "●" : "○"
        color: root.bar ? root.bar.barForeground : Color.foreground
        font.family: root.bar ? root.bar.fontFamily : Style.font.family
        font.pixelSize: Style.font.body

        MouseArea {
          anchors.fill: parent
          onClicked: if (modelData.wayland) modelData.wayland.activate()
        }
      }
    }
  }
}
