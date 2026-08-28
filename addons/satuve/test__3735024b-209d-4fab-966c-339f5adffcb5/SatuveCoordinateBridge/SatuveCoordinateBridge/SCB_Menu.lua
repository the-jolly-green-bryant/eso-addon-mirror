local SCB = SatuveCoordinateBridge

SCB.Menu = SCB.Menu or {}
local Menu = SCB.Menu

local function CreateLabel(name, parent, width, height, anchor, offsetX, offsetY, font)
	local label = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
	label:SetDimensions(width, height)
	label:SetAnchor(anchor, parent, anchor, offsetX, offsetY)
	label:SetFont(font or "$(MEDIUM_FONT)|18|outline")
	label:SetColor(1, 1, 1, 1)
	label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	return label
end

local function CreateButton(name, parent, x, y, width, text, callback)
	local button = WINDOW_MANAGER:CreateControl(name, parent, CT_BUTTON)
	button:SetDimensions(width, 34)
	button:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
	local background = WINDOW_MANAGER:CreateControl(name .. "Background", button, CT_BACKDROP)
	background:SetAnchorFill(button)
	background:SetCenterColor(0.12, 0.12, 0.12, 0.96)
	background:SetEdgeColor(0.75, 0.68, 0.25, 1)
	local label = CreateLabel(name .. "Label", button, width, 34, CENTER, 0, 0)
	label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	button.label = label
	button:SetText(text)
	label:SetText(text)
	button:SetHandler("OnClicked", callback)
	return button
end

function Menu:Create()
	if self.Window then return end
	local window = WINDOW_MANAGER:CreateTopLevelWindow("SatuveCoordinateBridgeMenu")
	window:SetDimensions(520, 410)
	window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
	window:SetMouseEnabled(true)
	window:SetMovable(true)
	window:SetClampedToScreen(true)
	window:SetDrawTier(DT_HIGH)
	if DL_OVERLAY then window:SetDrawLayer(DL_OVERLAY) end
	window:SetHidden(true)

	local background = WINDOW_MANAGER:CreateControl("SatuveCoordinateBridgeMenuBackground", window, CT_BACKDROP)
	background:SetAnchorFill(window)
	background:SetCenterColor(0.02, 0.02, 0.02, 0.96)
	background:SetEdgeColor(0.75, 0.68, 0.25, 1)

	local title = CreateLabel("SatuveCoordinateBridgeMenuTitle", window, 480, 42, TOP, 0, 12, "$(BOLD_FONT)|26|outline")
	title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	title:SetText("SATUVE COORDINATE BRIDGE")

	self.ValueLabels = {}
	local rowNames = {"Enabled", "Position X", "Position Y", "Cell Size", "Update Interval", "Debug Text"}
	for row, rowName in ipairs(rowNames) do
		local y = 62 + (row - 1) * 44
		local nameLabel = CreateLabel("SatuveCoordinateBridgeMenuName" .. row, window, 210, 34, TOPLEFT, 24, y)
		nameLabel:SetText(rowName)
		local valueLabel = CreateLabel("SatuveCoordinateBridgeMenuValue" .. row, window, 120, 34, TOPLEFT, 238, y)
		valueLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
		self.ValueLabels[row] = valueLabel
	end

	CreateButton("SatuveCoordinateBridgeEnabledButton", window, 370, 62, 120, "Toggle", function()
		SCB.SV.enabled = not SCB.SV.enabled
		SCB.Core:ApplySettings()
		Menu:Refresh()
	end)
	CreateButton("SatuveCoordinateBridgeXMinus", window, 370, 106, 55, "-", function() SCB.SV.offsetX = SCB.SV.offsetX - 10 SCB.Display:ApplySettings() Menu:Refresh() end)
	CreateButton("SatuveCoordinateBridgeXPlus", window, 435, 106, 55, "+", function() SCB.SV.offsetX = SCB.SV.offsetX + 10 SCB.Display:ApplySettings() Menu:Refresh() end)
	CreateButton("SatuveCoordinateBridgeYMinus", window, 370, 150, 55, "-", function() SCB.SV.offsetY = SCB.SV.offsetY - 10 SCB.Display:ApplySettings() Menu:Refresh() end)
	CreateButton("SatuveCoordinateBridgeYPlus", window, 435, 150, 55, "+", function() SCB.SV.offsetY = SCB.SV.offsetY + 10 SCB.Display:ApplySettings() Menu:Refresh() end)
	CreateButton("SatuveCoordinateBridgeSizeMinus", window, 370, 194, 55, "-", function() SCB.SV.cellSize = SCB.Clamp(SCB.SV.cellSize - 1, 3, 12) SCB.Display:ApplySettings() Menu:Refresh() end)
	CreateButton("SatuveCoordinateBridgeSizePlus", window, 435, 194, 55, "+", function() SCB.SV.cellSize = SCB.Clamp(SCB.SV.cellSize + 1, 3, 12) SCB.Display:ApplySettings() Menu:Refresh() end)
	CreateButton("SatuveCoordinateBridgeRateButton", window, 370, 238, 120, "Cycle", function()
		SCB.SV.updateMs = SCB.SV.updateMs == 25 and 50 or (SCB.SV.updateMs == 50 and 100 or 25)
		SCB.Core:ApplySettings()
		Menu:Refresh()
	end)
	CreateButton("SatuveCoordinateBridgeDebugButton", window, 370, 282, 120, "Toggle", function()
		SCB.SV.showDebugText = not SCB.SV.showDebugText
		SCB.Display:ApplySettings()
		Menu:Refresh()
	end)
	CreateButton("SatuveCoordinateBridgeTestButton", window, 24, 340, 220, "Run encoder self-test", function()
		local ok, crc = SCB.Encoder:SelfTest()
		SCB.Print((ok and "self-test passed" or "SELF-TEST FAILED") .. string.format("; CRC=%04X", crc or 0))
	end)
	CreateButton("SatuveCoordinateBridgeCloseButton", window, 276, 340, 214, "Close", function() window:SetHidden(true) end)

	self.Window = window
	self:Refresh()
end

function Menu:Refresh()
	if not self.Window or not SCB.SV then return end
	self.ValueLabels[1]:SetText(SCB.SV.enabled and "ON" or "OFF")
	self.ValueLabels[2]:SetText(tostring(SCB.SV.offsetX))
	self.ValueLabels[3]:SetText(tostring(SCB.SV.offsetY))
	self.ValueLabels[4]:SetText(tostring(SCB.SV.cellSize) .. " px")
	self.ValueLabels[5]:SetText(tostring(SCB.SV.updateMs) .. " ms")
	self.ValueLabels[6]:SetText(SCB.SV.showDebugText and "ON" or "OFF")
end

function Menu:Toggle()
	self:Create()
	self:Refresh()
	self.Window:SetHidden(not self.Window:IsHidden())
end

local function ParseOnOff(value)
	value = string.lower(tostring(value or ""))
	if value == "on" or value == "1" or value == "true" then return true end
	if value == "off" or value == "0" or value == "false" then return false end
	return nil
end

function Menu:HandleSlash(text)
	local command, argument = tostring(text or ""):match("^(%S*)%s*(.-)%s*$")
	command = string.lower(command or "")
	if command == "" or command == "menu" then self:Toggle() return end
	if command == "on" then SCB.SV.enabled = true SCB.Core:ApplySettings() return end
	if command == "off" then SCB.SV.enabled = false SCB.Core:ApplySettings() return end
	if command == "x" and tonumber(argument) then SCB.SV.offsetX = tonumber(argument) SCB.Display:ApplySettings() return end
	if command == "y" and tonumber(argument) then SCB.SV.offsetY = tonumber(argument) SCB.Display:ApplySettings() return end
	if command == "size" and tonumber(argument) then SCB.SV.cellSize = SCB.Clamp(tonumber(argument), 3, 12) SCB.Display:ApplySettings() return end
	if command == "rate" and (tonumber(argument) == 25 or tonumber(argument) == 50 or tonumber(argument) == 100) then SCB.SV.updateMs = tonumber(argument) SCB.Core:ApplySettings() return end
	if command == "debug" then
		local value = ParseOnOff(argument)
		if value ~= nil then SCB.SV.showDebugText = value SCB.Display:ApplySettings() return end
	end
	if command == "test" then
		local ok, crc = SCB.Encoder:SelfTest()
		SCB.Print((ok and "self-test passed" or "SELF-TEST FAILED") .. string.format("; CRC=%04X", crc or 0))
		return
	end
	SCB.Print("Commands: /scb menu | on | off | x <px> | y <px> | size <3-12> | rate <25|50|100> | debug <on|off> | test")
end

function Menu:Initialize()
	self:Create()
	SLASH_COMMANDS["/scb"] = function(text) Menu:HandleSlash(text) end
end
