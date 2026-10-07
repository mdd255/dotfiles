import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

// One copy per bar: a solid dot when the monitor this bar is on has focus,
// an empty circle otherwise.
BarWidget {
  id: root
  moduleName: "dh.focus-dot"

  readonly property var hostScreen: root.QsWindow && root.QsWindow.window ? root.QsWindow.window.screen : null
  readonly property bool focused: !!hostScreen && !!Hyprland.focusedMonitor && Hyprland.focusedMonitor.name === hostScreen.name

  implicitWidth: dot.implicitWidth + Style.spacing.controlPaddingX * 2
  implicitHeight: barSize

  Text {
    id: dot
    anchors.centerIn: parent
    text: root.focused ? "●" : "○"
    color: root.bar ? root.bar.barForeground : Color.foreground
    font.family: root.bar ? root.bar.fontFamily : Style.font.family
    font.pixelSize: Style.font.body
  }
}
