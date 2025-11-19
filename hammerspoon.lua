hs.hotkey.bind({ "cmd" }, "e", function()
	local currentScreen = hs.mouse.getCurrentScreen()
	local nextScreen = currentScreen:next()
	local nextFrame = nextScreen:frame()

	local centerPos = {
		x = nextFrame.x + nextFrame.w / 2,
		y = nextFrame.y + nextFrame.h / 2,
	}

	hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, centerPos):post()
	hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, centerPos):post()
end)

hs.hotkey.bind({ "cmd" }, "n", function()
	local currentScreen = hs.mouse.getCurrentScreen()
	local nextScreen = currentScreen:previous()
	local nextFrame = nextScreen:frame()

	local centerPos = {
		x = nextFrame.x + nextFrame.w / 2,
		y = nextFrame.y + nextFrame.h / 2,
	}

	hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, centerPos):post()
	hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, centerPos):post()
end)

hs.hotkey.bind({ "cmd" }, "b", function()
	hs.application.launchOrFocus("Brave Browser")
end)

hs.hotkey.bind({ "cmd" }, "a", function()
	hs.application.launchOrFocus("Neovide")
end)

hs.hotkey.bind({ "cmd" }, "return", function()
	hs.application.launchOrFocus("WezTerm")
end)

hs.hotkey.bind({ "shift", "cmd" }, "f", function()
	local win = hs.window.focusedWindow()
	if win then
		win:toggleFullScreen()
	end
end)

local lastFrame = nil

hs.hotkey.bind({ "cmd" }, "f", function()
	local win = hs.window.focusedWindow()
	if not win then
		return
	end

	if lastFrame then
		win:setFrame(lastFrame)
		lastFrame = nil
	else
		lastFrame = win:frame()
		win:maximize()
	end
end)

local function reloadConfig(files)
	for _, file in pairs(files) do
		if file:sub(-4) == ".lua" then
			hs.reload()
			return
		end
	end
end

hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config Loaded")

hs.hotkey.bind({ "cmd" }, "o", function()
	local win = hs.window.focusedWindow()
	if not win then
		return
	end

	-- Get all visible windows in current Space
	local allWins = hs.window.visibleWindows()
	local idx = 1

	-- Find current window's index
	for i, w in ipairs(allWins) do
		if w:id() == win:id() then
			idx = i
			break
		end
	end

	-- Focus the next window (wrap around)
	local nextIdx = idx + 1

	if nextIdx > #allWins then
		nextIdx = 1
	end

	allWins[nextIdx]:focus()
	allWins[nextIdx]:raise()
end)
