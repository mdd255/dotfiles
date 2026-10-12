import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

// One copy per bar: an application icon per window on the workspace visible on
// this bar's monitor, the focused window highlighted. Hidden on an empty
// workspace.
BarWidget {
  id: root
  moduleName: "dh.active-window"

  readonly property var hostScreen: root.QsWindow && root.QsWindow.window ? root.QsWindow.window.screen : null
  readonly property var hostMonitor: hostScreen ? Hyprland.monitorFor(hostScreen) : null
  readonly property var hostWorkspace: hostMonitor ? hostMonitor.activeWorkspace : null

  readonly property var windows: hostWorkspace ? hostWorkspace.toplevels.values : []
  readonly property var focused: Hyprland.activeToplevel
  // This bar's monitor holds keyboard focus.
  readonly property bool monitorFocused: !!hostMonitor && hostMonitor === Hyprland.focusedMonitor

  readonly property string defaultIcon: String(setting("defaultIcon", "󰣆"))

  // Optional `rewrite` setting: { "<name>": "<icon>" }. Keys are compared
  // case-insensitively, first against the application id (class), then against
  // the window title for apps that share a generic class (Quickshell windows
  // all report "org.quickshell"), e.g. { "kitty": "", "Omamail": "" }.
  // Windows with no entry get `defaultIcon`.
  function iconFor(win) {
    var toplevel = win ? win.wayland : null
    if (!toplevel) return defaultIcon
    var rules = setting("rewrite", ({}))
    var candidates = [toplevel.appId, toplevel.title]
    for (var i = 0; i < candidates.length; i++) {
      var value = String(candidates[i] || "").toLowerCase()
      if (!value) continue
      for (var name in rules) {
        if (name.toLowerCase() === value) return String(rules[name])
      }
    }
    return defaultIcon
  }

  visible: windows.length > 0 && !vertical
  implicitWidth: visible ? row.implicitWidth + Style.spacing.controlPaddingX * 2 : 0
  implicitHeight: barSize

  Behavior on implicitWidth {
    NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
  }

  Row {
    id: row
    anchors.centerIn: parent
    spacing: Style.space(6)

    Repeater {
      model: root.windows

      Text {
        id: icon
        required property var modelData
        readonly property bool isFocused: !!root.focused && root.focused.address === modelData.address

        textFormat: Text.PlainText
        text: root.iconFor(modelData)
        color: !isFocused ? "#808080"
          : root.monitorFocused ? (root.bar ? root.bar.urgent : Color.urgent)
          : (root.bar ? root.bar.barForeground : Color.foreground)
        font.family: root.bar ? root.bar.fontFamily : Style.font.family
        font.pixelSize: Style.font.body

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
          cursorShape: Qt.PointingHandCursor

          onClicked: function(mouse) {
            if (!icon.modelData.wayland) return
            if (mouse.button === Qt.LeftButton) icon.modelData.wayland.activate()
            else icon.modelData.wayland.close()
          }
          onEntered: if (root.bar) root.bar.showTooltip(root, icon.modelData.wayland ? (icon.modelData.wayland.title || icon.modelData.wayland.appId) : "")
          onExited: if (root.bar) root.bar.hideTooltip(root)
        }
      }
    }
  }
}
