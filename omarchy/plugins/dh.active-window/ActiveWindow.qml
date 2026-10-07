import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.active-window"


  // Per-monitor: show the focused window of the workspace visible on the
  // monitor this bar is drawn on, not the globally focused window.
  readonly property var hostScreen: root.QsWindow && root.QsWindow.window ? root.QsWindow.window.screen : null
  readonly property var hostMonitor: hostScreen ? Hyprland.monitorFor(hostScreen) : null
  readonly property var hostWorkspace: hostMonitor ? hostMonitor.activeWorkspace : null

  // workspace id -> address of the window last focused on it. Hyprland only
  // reports the one globally focused window, and focusHistoryID in
  // lastIpcObject goes stale, so each bar remembers what was focused on its
  // own workspace and keeps showing that after focus moves to another monitor.
  property var lastFocused: ({})

  function noteFocus() {
    var focused = Hyprland.activeToplevel
    var ws = hostWorkspace
    if (!focused || !ws || !focused.workspace || focused.workspace.id !== ws.id) return
    if (lastFocused[ws.id] === focused.address) return
    var next = {}
    for (var key in lastFocused) next[key] = lastFocused[key]
    next[ws.id] = focused.address
    lastFocused = next
  }

  Connections {
    target: Hyprland
    function onActiveToplevelChanged() { root.noteFocus() }
  }
  onHostWorkspaceChanged: noteFocus()
  Component.onCompleted: noteFocus()

  // The globally focused window if it is on this monitor's workspace, else
  // the one last focused there, else any window there.
  readonly property var shown: {
    var ws = hostWorkspace
    if (!ws) return null
    var focused = Hyprland.activeToplevel
    if (focused && focused.workspace && focused.workspace.id === ws.id) return focused
    var windows = ws.toplevels.values
    for (var i = 0; i < windows.length; i++) {
      if (windows[i].address === lastFocused[ws.id]) return windows[i]
    }
    return windows.length > 0 ? windows[0] : null
  }

  readonly property var toplevel: shown ? shown.wayland : null
  readonly property string appId: toplevel ? toplevel.appId : ""
  readonly property string rawTitle: toplevel ? (toplevel.title || toplevel.appId) : ""

  // Optional `rewrite` setting: { "<regex>": "<label>" }. A rule applies when
  // its regex fully matches the app id or the title, e.g.
  // { "kitty": "Term", ".*Brave": "Brave" }. The first match wins.
  readonly property string title: {
    var rules = setting("rewrite", ({}))
    for (var pattern in rules) {
      try {
        var re = new RegExp("^(?:" + pattern + ")$")
        if (re.test(appId) || re.test(rawTitle)) return String(rules[pattern])
      } catch (e) {
        // Invalid regex in the config: skip that rule.
      }
    }
    return rawTitle
  }
  readonly property int maxLabelWidth: Number(setting("maxWidth", 280))

  visible: title !== "" && !vertical
  implicitWidth: visible ? Math.min(maxLabelWidth, labelText.implicitWidth) + Style.spacing.controlPaddingX * 2 : 0
  implicitHeight: barSize

  Behavior on implicitWidth {
    NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
  }

  Item {
    anchors.fill: parent
    anchors.leftMargin: Style.space(8)
    anchors.rightMargin: Style.space(8)
    clip: true

    Text {
      id: labelText
      textFormat: Text.PlainText
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: parent.left
      width: parent.width
      text: root.title
      color: root.bar ? root.bar.barForeground : Color.foreground
      font.family: root.bar ? root.bar.fontFamily : Style.font.family
      font.pixelSize: Style.font.body
      elide: Text.ElideRight
      opacity: 0.85
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
    cursorShape: Qt.PointingHandCursor

    onClicked: function(mouse) {
      if (!root.toplevel) return
      if (mouse.button === Qt.MiddleButton) {
        root.toplevel.close()
      } else if (mouse.button === Qt.RightButton) {
        root.toplevel.close()
      } else {
        root.toplevel.activate()
      }
    }
    onEntered: if (root.bar) root.bar.showTooltip(root, root.title)
    onExited: if (root.bar) root.bar.hideTooltip(root)
  }
}
