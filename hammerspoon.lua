local apps = {
	b = "Brave Browser",
	["return"] = "WezTerm",
	w = "Neovide",
}

for key, app in pairs(apps) do
	hs.hotkey.bind({ "cmd" }, key, function()
		hs.execute("open -n -a '" .. app .. "'")
	end)
end

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

local lastFrame = nil

hs.hotkey.bind({ "cmd" }, "space", function()
	local win = hs.window.focusedWindow()

	if win then
		win:toggleFullScreen()
	end
end)

hs.hotkey.bind({ "cmd", "shift" }, "space", function()
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

hs.hotkey.bind({ "cmd" }, "r", hs.reload)

hs.pathwatcher.new(os.getenv("HOME") .. "/.config/dotfiles/hammerspoon.lua", reloadConfig):start()
hs.alert.show("Config loaded successfully")

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

	-- Focus the next non-Finder window (wrap around)
	for step = 1, #allWins - 1 do
		local nextWin = allWins[(idx + step - 1) % #allWins + 1]
		local app = nextWin:application()

		if not app or app:name() ~= "Finder" then
			nextWin:focus()
			nextWin:raise()
			return
		end
	end
end)
