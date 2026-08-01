LibChatMenuButton = LibChatMenuButton or {}
LibChatMenuButton.chatButtons = {}
LibChatMenuButton.iconWidth = 30
LibChatMenuButton.iconHeight = 30
LibChatMenuButton.horizontalOffset = 0
LibChatMenuButton.submenuIndex = 5
LibChatMenuButton.expand = nil
LibChatMenuButton.menuOpened = false
LibChatMenuButton.override = {}

MenuButton = MenuButton or {}

local function uuid()
	return string.gsub('xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx', "[xy]", function (cur)
		local tmp = (cur == 'x') and math.random(0, 0xf) or math.random(8, 0xf)
		return string.format('%x', tmp)
	end)
end

local function round(num)
    if num >= 0 then num = math.floor(num + 0.5) else num = math.ceil(num - 0.5) end
    return num
end

function MenuButton.new(self, name, tooltip, imagePath, func)
	if imagePath == nil then imagePath = "LibChatMenuButton/error.dds" end
	local imagePathHover = ""
	local imagePathDisabled = ""
	local imagePathPressed = ""
	local imagePathDisabledPressed = ""
	if type(imagePath) == "table" then
		imagePathDisabledPressed = imagePath[5] or ""
		imagePathDisabled = imagePath[4] or ""
		imagePathPressed = imagePath[3] or ""
		imagePathHover = imagePath[2] or ""
		imagePath = imagePath[1] or "LibChatMenuButton/error.dds"
	end

	local id = uuid()

	if tooltip == nil then tooltip = "" end
	if func == nil then func = function() d("Clicked "..id.."!") end end

	local menuButton = {
		id = id,
		name = name,
		imagePath = imagePath,
		imagePathHover = imagePathHover,
		imagePathDisabled = imagePathDisabled,
		imagePathPressed = imagePathPressed,
		imagePathDisabledPressed = imagePathDisabledPressed,
		tooltip = tooltip,
		func = func,
		isVisible = false,
		index = -1,
		ui = nil,
		isEnabled = true
	}

	setmetatable(menuButton, self)
	self.__index = self
	return menuButton
end

function MenuButton.init(self)
	self.ui = WINDOW_MANAGER:CreateControl(self.id, ZO_ChatWindow, CT_BUTTON)
	self.ui:SetMouseEnabled(true)
	self.ui:SetDrawLayer(2)
	self.ui:SetMovable(false)
	self.isVisible = true
	LibChatMenuButton.updateWithIndexes()
	return self
end

function MenuButton.update(self)
	self.ui:ClearAnchors()
	if self.index > LibChatMenuButton.submenuIndex then
		local submenuIndex = self.index - LibChatMenuButton.submenuIndex
		self.ui:SetAnchor(TOPRIGHT, ZO_ChatWindow, TOPRIGHT, submenuIndex * -(LibChatMenuButton.iconWidth + 6) - (LibChatMenuButton.horizontalOffset + 10), LibChatMenuButton.iconHeight + 12)
		if LibChatMenuButton.menuOpened == false then
			self.ui:SetHidden(true)
		else
			self.ui:SetHidden(false)
		end
	else
		self.ui:SetAnchor(TOPRIGHT, ZO_ChatWindow, TOPRIGHT, self.index * -(LibChatMenuButton.iconWidth + 6) - (LibChatMenuButton.horizontalOffset + 10), 6)
	end
	self.ui:SetNormalTexture(self.imagePath)
	if self.imagePathHover ~= "" then
		self.ui:SetMouseOverTexture(self.imagePathHover)
	else
		self.ui:SetMouseOverTexture(self.imagePath)
	end
	if self.imagePathPressed ~= "" then
		self.ui:SetPressedTexture(self.imagePathPressed)
	else
		self.ui:SetPressedTexture(self.imagePath)
	end
	if self.imagePathDisabled ~= "" then
		self.ui:SetDisabledTexture(self.imagePathDisabled)
	else
		self.ui:SetDisabledTexture(self.imagePath)
	end
	if self.imagePathDisabledPressed ~= "" then
		self.ui:SetDisabledPressedTexture(self.imagePathDisabledPressed)
	else
		self.ui:SetDisabledPressedTexture(self.imagePath)
	end
	self.ui:SetDimensions(LibChatMenuButton.iconWidth, LibChatMenuButton.iconHeight)
	if self.overrideF1 then
		self.ui:SetHandler("OnMouseUp", self.overrideF1)
	else
		self.ui:SetHandler("OnMouseUp", function(...)
			if self.isEnabled == false then return end
			self.func(...)
		end)
	end
	if self.overrideF2 then
		self.ui:SetHandler("OnMouseEnter", self.overrideF2)
	else
		self.ui:SetHandler("OnMouseEnter", function(control)
			local ttip = self.tooltip
			if type(ttip) == "function" then
				ttip = ttip()
			end
			if ttip ~= "" then
				ZO_Tooltips_ShowTextTooltip(control, RIGHT, ttip)
			end
			if self.isEnabled == false then return end
			if self.imagePathHover == "" then
				self.ui:SetAlpha(.5)
			end
		end)
	end
	if self.overrideF3 then
		self.ui:SetHandler("OnMouseExit", self.overrideF3)
	else
		self.ui:SetHandler("OnMouseExit", function()
			ZO_Tooltips_HideTextTooltip()
			self.ui:SetAlpha(1)
			if self.isEnabled == false then return end
		end)
	end
	return self
end

function MenuButton.overrideFunctions(self, overrideOnMouseUp, overrideOnMouseEnter, overrideOnMouseExit)
	self.overrideF1 = overrideOnMouseUp
	self.overrideF2 = overrideOnMouseEnter
	self.overrideF3 = overrideOnMouseExit
	return self
end

function MenuButton.edit(self, values)
	if values == nil then return self end
	if type(values) ~= "table" then return self end
	for param, value in pairs(values) do
		if self[param] ~= nil then 
			self[param] = value
		end
	end
	LibChatMenuButton.updateWithIndexes()
	return self
end

function MenuButton.show(self)
	if self.index > LibChatMenuButton.submenuIndex and LibChatMenuButton.menuOpened == false then
		return self 
	end
	self.ui:SetHidden(false)
	self.isVisible = true
	LibChatMenuButton.updateWithIndexes()
	return self
end

function MenuButton.hide(self)
	self.ui:SetHidden(true)
	self.isVisible = false
	LibChatMenuButton.updateWithIndexes()
	return self
end

function MenuButton.enable(self)
	self.isEnabled = true
	self.ui:SetDesaturation(0) 
	return self
end

function MenuButton.disable(self)
	self.isEnabled = false
	if self.imagePathDisabled == "" then
		self.ui:SetDesaturation(1)
	end
	return self
end

function LibChatMenuButton.addChatButton(name, imagePath, tooltip, func)
	name = string.match(name, "!?!?!?[a-zA-Z]+[0-9]?")
	if name == nil then 
		error("[LibChatMenuButton] name is invalid! Syntax: !?!?!?[a-zA-Z]+[0-9]?")
	end
	local button = MenuButton:new(name, tooltip, imagePath, func)
	table.insert(LibChatMenuButton.chatButtons, {name = name, button = button})
	if #LibChatMenuButton.chatButtons > LibChatMenuButton.submenuIndex then 
		LibChatMenuButton.ownMenuButton()
	end
	button:init()
	return button
end

function LibChatMenuButton.measureChatWindow()
	local chatWindowFreeSpace = ZO_ChatWindow:GetWidth() / 3
	local numIndexes = chatWindowFreeSpace / (LibChatMenuButton.iconWidth + 6)
	LibChatMenuButton.submenuIndex = round(numIndexes)
end

function LibChatMenuButton.ownMenuButton()
	if LibChatMenuButton.expand ~= nil then return end
	local button = MenuButton:new("!!!!!!LCMBexpand", nil, "esoui/art/buttons/large_downarrow_up.dds", LibChatMenuButton.openSubMenu)
	table.insert(LibChatMenuButton.chatButtons, {name = "!!!!!!LCMBexpand", button = button})
	button:init()
	LibChatMenuButton.expand = button
end

function LibChatMenuButton.openSubMenu()
	if LibChatMenuButton.expand == nil then return end
	LibChatMenuButton.expand:edit({
		["imagePath"] = "esoui/art/buttons/large_uparrow_up.dds",
		["func"] = LibChatMenuButton.closeSubMenu
	})
	LibChatMenuButton.menuOpened = true
	LibChatMenuButton.updateWithIndexes()
end

function LibChatMenuButton.closeSubMenu()
	if LibChatMenuButton.expand == nil then return end
	LibChatMenuButton.expand:edit({
		["imagePath"] = "esoui/art/buttons/large_downarrow_up.dds",
		["func"] = LibChatMenuButton.openSubMenu
	})
	LibChatMenuButton.menuOpened = false
	LibChatMenuButton.updateWithIndexes()
end

function LibChatMenuButton.updateWithIndexes()
	table.sort(LibChatMenuButton.chatButtons, function(a,b)
		return a.name < b.name
	end)
	local index = 1
	for _, data in ipairs(LibChatMenuButton.chatButtons) do
		if data.button.isVisible == true then
			data.button.index = index
			index = index + 1
		end
	end
	for _, data in ipairs(LibChatMenuButton.chatButtons) do
		if data.button.isVisible == true then
			data.button:update()
		end
	end
end

local function start()
	LibChatMenuButton.measureChatWindow()
	LibChatMenuButton.updateWithIndexes()
	local onResizeFunc = ZO_ChatWindow:GetHandler("OnResizeStop")
	ZO_ChatWindow:SetHandler("OnResizeStop", function(control)
		LibChatMenuButton.measureChatWindow()
		LibChatMenuButton.updateWithIndexes()
		if onResizeFunc ~= nil then
			onResizeFunc(control)
		end
	end)
	for _, override in pairs(LibChatMenuButton.override) do
		override()
	end
	EVENT_MANAGER:UnregisterForEvent("LibChatMenuButton", EVENT_PLAYER_ACTIVATED)
end

EVENT_MANAGER:RegisterForEvent("LibChatMenuButton", EVENT_PLAYER_ACTIVATED, start)