local ADDON_NAME = "GroupResources"
GroupResources = {}

local nextEventHandleIndex = 1

local function RegisterForEvent(event, callback)
	local eventHandleName = ADDON_NAME .. nextEventHandleIndex
	EVENT_MANAGER:RegisterForEvent(eventHandleName, event, callback)
	nextEventHandleIndex = nextEventHandleIndex + 1
	return eventHandleName
end

local function UnregisterForEvent(event, name)
	EVENT_MANAGER:UnregisterForEvent(name, event)
end

local function WrapFunction(object, functionName, wrapper)
	if(type(object) == "string") then
		wrapper = functionName
		functionName = object
		object = _G
	end
	local originalFunction = object[functionName]
	object[functionName] = function(...) return wrapper(originalFunction, ...) end
end

local function OnAddonLoaded(callback)
	local eventHandle = ""
	eventHandle = RegisterForEvent(EVENT_ADD_ON_LOADED, function(event, name)
		if(name ~= ADDON_NAME) then return end
		callback()
		UnregisterForEvent(event, name)
	end)
end

-- ---------------------------------------------------------------

local defaultData = {
	version = 3,
	staminaFirst = false,
	hideResourceBarsToggle = true,
	hideResourceBarsTimeout = 120,
	keyboardBarDimensions = {
		groupFrameBarWidth = 150,
		groupFrameBarHeight = 6,
		raidFrameBarWidth = 114,
		raidFrameBarHeight = 6,
	},
	gamepadBarDimensions = {
		groupFrameBarWidth = 160,
		groupFrameBarHeight = 5,
		raidFrameBarWidth = 173,
		raidFrameBarHeight = 6,
	},
	colors = {
		[COMBAT_MECHANIC_FLAGS_MAGICKA] = {
			gradientStart = {GetInterfaceColor(INTERFACE_COLOR_TYPE_POWER_START, COMBAT_MECHANIC_FLAGS_MAGICKA)},
			gradientEnd = {GetInterfaceColor(INTERFACE_COLOR_TYPE_POWER_END, COMBAT_MECHANIC_FLAGS_MAGICKA)},
		},
		[COMBAT_MECHANIC_FLAGS_STAMINA] = {
			gradientStart = {GetInterfaceColor(INTERFACE_COLOR_TYPE_POWER_START, COMBAT_MECHANIC_FLAGS_STAMINA)},
			gradientEnd = {GetInterfaceColor(INTERFACE_COLOR_TYPE_POWER_END, COMBAT_MECHANIC_FLAGS_STAMINA)},
		},
	},
}

local barStylesDirty, barColorsDirty = false, false

local function CreateSettingsDialog(saveData)
	local LAM = LibAddonMenu2

	local panelData = {
		type = "panel",
		name = "GroupResources",
		author = "sirinsidiator",
		version = "0.10.0",
		registerForRefresh = true,
		registerForDefaults = true
	}
	local panel = LAM:RegisterAddonPanel("GroupResourcesOptions", panelData)

	local optionsData = {}
	local function AddTitle(title)
		optionsData[#optionsData + 1] = {
			type = "header",
			name = title,
		}
	end

	local function AddCheckbox(saveData, defaultData, propertyName, label, tooltip, warning, disabled, isHalf, callback)
		optionsData[#optionsData + 1] = {
			type = "checkbox",
			name = label,
			tooltip = tooltip,
			width = isHalf and "half" or nil,
			getFunc = function() return saveData[propertyName] end,
			setFunc = function(value)
				saveData[propertyName] = value
				if(callback) then callback(saveData, value) end
			end,
			warning = warning,
			disabled = disabled,
			default = defaultData[propertyName]
		}
	end

	local function AddSlider(saveData, defaultData, propertyName, min, max, label, tooltip, warning, disabled, isHalf, callback)
		optionsData[#optionsData + 1] = {
			type = "slider",
			name = label,
			tooltip = tooltip,
			width = isHalf and "half" or nil,
			min = min,
			max = max,
			getFunc = function() return saveData[propertyName] end,
			setFunc = function(value)
				saveData[propertyName] = value
				if(callback) then callback(saveData, value) end
			end,
			warning = warning,
			disabled = disabled,
			default = defaultData[propertyName]
		}
	end

	local function AddColorPicker(saveData, defaultData, propertyName, label, tooltip, warning, disabled, isHalf, callback)
		optionsData[#optionsData + 1] = {
			type = "colorpicker",
			name = label,
			tooltip = tooltip,
			width = isHalf and "half" or nil,
			getFunc = function() return unpack(saveData[propertyName]) end,
			setFunc = function(r, g, b, a)
				saveData[propertyName] = {r, g, b, a}
				if(callback) then callback(saveData, r, g, b, a) end
			end,
			warning = warning,
			disabled = disabled,
			default = ZO_ColorDef:New(unpack(defaultData[propertyName]))
		}
	end

	local function SetBarStylesDirty()
		barStylesDirty = true
	end

	local function SetBarColorsDirty()
		barColorsDirty = true
	end

	AddTitle("General")
	AddCheckbox(saveData, defaultData, "staminaFirst", "Stamina First", "Show the Stamina bar above the Magicka Bar. Default is Magicka before Stamina", nil, nil, nil, SetBarStylesDirty)
	AddCheckbox(saveData, defaultData, "hideResourceBarsToggle", "Hide Resource Bars", "Turn off to always show the resource bars for group members that have the addon installed. Leaving this on is useful because you do not know if a player has disabled sending data and otherwise the bars would never disappear.")
	AddSlider(saveData, defaultData, "hideResourceBarsTimeout", 5, 600, "Hide Resource Bars Timeout", "Hides the Magicka and Stamina bar of a group member x seconds after the last received update.", nil, function() return not saveData.hideResourceBarsToggle end)
	AddTitle("Bar Colors")
	AddColorPicker(saveData.colors[COMBAT_MECHANIC_FLAGS_MAGICKA], defaultData.colors[COMBAT_MECHANIC_FLAGS_MAGICKA], "gradientStart", "Magicka Gradient Start", "Start color for the gradient of the Magicka bar.", nil, nil, true, SetBarColorsDirty)
	AddColorPicker(saveData.colors[COMBAT_MECHANIC_FLAGS_MAGICKA], defaultData.colors[COMBAT_MECHANIC_FLAGS_MAGICKA], "gradientEnd", "Magicka Gradient End", "End color for the gradient of the Magicka bar.", nil, nil, true, SetBarColorsDirty)
	AddColorPicker(saveData.colors[COMBAT_MECHANIC_FLAGS_STAMINA], defaultData.colors[COMBAT_MECHANIC_FLAGS_STAMINA], "gradientStart", "Stamina Gradient Start", "Start color for the gradient of the Stamina bar.", nil, nil, true, SetBarColorsDirty)
	AddColorPicker(saveData.colors[COMBAT_MECHANIC_FLAGS_STAMINA], defaultData.colors[COMBAT_MECHANIC_FLAGS_STAMINA], "gradientEnd", "Stamina Gradient End", "End color for the gradient of the Stamina bar.", nil, nil, true, SetBarColorsDirty)
	AddTitle("Keyboard Dimensions")
	AddSlider(saveData.keyboardBarDimensions, defaultData.keyboardBarDimensions, "groupFrameBarWidth", 1, 170, "Group Bar Width", "Controls the width of the Magicka and Stamina bar in small groups in the keyboard UI.", nil, nil, true, SetBarStylesDirty)
	AddSlider(saveData.keyboardBarDimensions, defaultData.keyboardBarDimensions, "groupFrameBarHeight", 1, 15, "Group Bar Height", "Controls the height of the Magicka and Stamina bar in small groups in the keyboard UI.", nil, nil, true, SetBarStylesDirty)
	AddSlider(saveData.keyboardBarDimensions, defaultData.keyboardBarDimensions, "raidFrameBarWidth", 1, 114, "Raid Bar Width", "Controls the width of the Magicka and Stamina bar in large groups in the keyboard UI.", nil, nil, true, SetBarStylesDirty)
	AddSlider(saveData.keyboardBarDimensions, defaultData.keyboardBarDimensions, "raidFrameBarHeight", 1, 15, "Raid Bar Height", "Controls the height of the Magicka and Stamina bar in large in the keyboard UI.", nil, nil, true, SetBarStylesDirty)
	AddTitle("Gamepad Dimensions")
	AddSlider(saveData.gamepadBarDimensions, defaultData.gamepadBarDimensions, "groupFrameBarWidth", 1, 160, "Group Bar Width", "Controls the width of the Magicka and Stamina bar in small groups in the gamepad UI.", nil, nil, true, SetBarStylesDirty)
	AddSlider(saveData.gamepadBarDimensions, defaultData.gamepadBarDimensions, "groupFrameBarHeight", 1, 15, "Group Bar Height", "Controls the height of the Magicka and Stamina bar in small groups in the gamepad UI.", nil, nil, true, SetBarStylesDirty)
	AddSlider(saveData.gamepadBarDimensions, defaultData.gamepadBarDimensions, "raidFrameBarWidth", 1, 173, "Raid Bar Width", "Controls the width of the Magicka and Stamina bar in large groups in the gamepad UI.", nil, nil, true, SetBarStylesDirty)
	AddSlider(saveData.gamepadBarDimensions, defaultData.gamepadBarDimensions, "raidFrameBarHeight", 1, 15, "Raid Bar Height", "Controls the height of the Magicka and Stamina bar in large in the gamepad UI.", nil, nil, true, SetBarStylesDirty)

	LAM:RegisterOptionControls("GroupResourcesOptions", optionsData)
end

OnAddonLoaded(function()
	local REDUCED_RAID_HEALTH_BAR_HEIGHT = 0
	local DEFAULT_RAID_HEALTH_BAR_HEIGHT_KEYBOARD = 39
	local DEFAULT_RAID_HEALTH_BAR_HEIGHT_GAMEPAD = 38
	local GROUP_FRAME_ANCHOR_OFFSETS = {}
	local RAID_FRAME_ANCHOR_OFFSETS = {}

	local MAGICKA_INDEX = 1
	local STAMINA_INDEX = 3
	local FORCE_INIT = true
	local DONT_COLOR = false

	local GROUP_FRAME_STYLE = "ZO_GroupUnitFrame"
	local RAID_FRAME_STYLE = "ZO_RaidUnitFrame"

	GroupResources_Data = GroupResources_Data or {}
	local saveData = GroupResources_Data[GetDisplayName()] or ZO_DeepTableCopy(defaultData)

    if saveData.version == 1 then
        local OLD_POWERTYPE_MAGICKA_VALUE = 0
        local OLD_POWERTYPE_STAMINA_VALUE = 6
        saveData.colors[COMBAT_MECHANIC_FLAGS_MAGICKA] = saveData.colors[OLD_POWERTYPE_MAGICKA_VALUE]
        saveData.colors[COMBAT_MECHANIC_FLAGS_STAMINA] = saveData.colors[OLD_POWERTYPE_STAMINA_VALUE]
        saveData.colors[OLD_POWERTYPE_MAGICKA_VALUE] = nil
        saveData.colors[OLD_POWERTYPE_STAMINA_VALUE] = nil
        saveData.version = 2
    end

	if saveData.version == 2 then
		saveData.keyboardBarDimensions.raidFrameBarWidth = defaultData.keyboardBarDimensions.raidFrameBarWidth
		saveData.version = 3
	end

	GroupResources_Data[GetDisplayName()] = saveData

	CreateSettingsDialog(saveData)

	local BAR_TEMPLATE = {
		keyboard = {
			[GROUP_FRAME_STYLE] = {
				offsetX = 36,
				offsetY = 52,
				templateName = "ZO_GroupUnitFrameStatus",
			},
			[RAID_FRAME_STYLE] = {
				offsetX = 2,
				offsetY = 41,
				templateName = "ZO_UnitFrameStatus",
			}
		},
		gamepad = {
			[GROUP_FRAME_STYLE] = {
				offsetX = 0,
				offsetY = 53,
				templateName = "ZO_GroupUnitFrameStatus",
			},
			[RAID_FRAME_STYLE] = {
				offsetX = 1,
				offsetY = 39,
				templateName = "ZO_UnitFrameStatus",
			}
		}
	}

	local function GetPlatformDimensions(saveData)
		return IsInGamepadPreferredMode() and saveData.gamepadBarDimensions or saveData.keyboardBarDimensions
	end

	local function GetPlatformDefaultHealthBarHeight()
		return IsInGamepadPreferredMode() and DEFAULT_RAID_HEALTH_BAR_HEIGHT_GAMEPAD or DEFAULT_RAID_HEALTH_BAR_HEIGHT_KEYBOARD
	end

	local function GetPlatformBarTemplate(style)
		local barStyles = IsInGamepadPreferredMode() and BAR_TEMPLATE.gamepad or BAR_TEMPLATE.keyboard
		return barStyles[style]
	end

	local function SetGradientColor(statusBar, startColor, endColor)
		local startR, startG, startB, startA = unpack(startColor)
		local endR, endG, endB, endA = unpack(endColor)
		statusBar:SetGradientColors(startR, startG, startB, startA, endR, endG, endB, endA)
	end

	local function SetCustomColor(self, barType)
		local colors = saveData.colors[barType] or defaultData.colors[barType]

		for i = 1, #self.barControls do
			local control = self.barControls[i]
			SetGradientColor(control, colors.gradientStart, colors.gradientEnd)
		end
	end

	local function ApplyResourceBarStyle(frame, bar, style, powerType)
		local dimension = GetPlatformDimensions(saveData)
		local barStyle = GetPlatformBarTemplate(style)
		local secondResource = saveData.staminaFirst and COMBAT_MECHANIC_FLAGS_MAGICKA or COMBAT_MECHANIC_FLAGS_STAMINA
		local templateName, offsetX, offsetY = barStyle.templateName, barStyle.offsetX, barStyle.offsetY
		local width, height
		if(style == GROUP_FRAME_STYLE) then
			width, height = dimension.groupFrameBarWidth, dimension.groupFrameBarHeight
			if(powerType == secondResource) then
				offsetY = offsetY + height
			end
		elseif(style == RAID_FRAME_STYLE) then
			width, height = dimension.raidFrameBarWidth, dimension.raidFrameBarHeight
			offsetY = offsetY - height
			REDUCED_RAID_HEALTH_BAR_HEIGHT = GetPlatformDefaultHealthBarHeight() - 2 * height
			if(powerType ~= secondResource) then
				offsetY = offsetY - height
			end
		else
			return
		end

		ApplyTemplateToControl(bar, ZO_GetPlatformTemplate(templateName))
		bar:SetDimensions(width, height)
		bar:ClearAnchors()
		bar:SetAnchor(TOPLEFT, frame, TOPLEFT, offsetX, offsetY)
	end

	local function SetBarEnabled(bar, enabled)
		if(not bar) then return end
		bar.disabled = not enabled
		if(not bar.wouldBeHidden) then
			bar:Hide(bar.disabled)
		end
	end

	local function SetBarHidden(bar, hidden)
		if(not bar) then return end
		bar.wouldBeHidden = hidden
		if(not bar.disabled) then
			bar:Hide(hidden)
		end
	end

	local function RefreshHealthBarHeight(frame, enabled)
		if(frame.style ~= RAID_FRAME_STYLE) then return end
		-- reduce health bar height to get a black background for the resource bars
		local height = enabled and REDUCED_RAID_HEALTH_BAR_HEIGHT or GetPlatformDefaultHealthBarHeight()
		for i, control in ipairs(frame.healthBar.barControls) do
			control:SetHeight(height)
		end
	end

	local function SetupCustomPowerBar(self, index, powerType)
		if(self.powerBars[index] == nil) then
			self.powerBars[index] = ZO_UnitFrameBar:New(self.frame:GetName().."PowerBar"..index, self.frame, self.barTextMode, self.style, COMBAT_MECHANIC_FLAGS_HEALTH)
			self:AddFadeComponent("PowerBar"..index, DONT_COLOR)
			local currentBar = self.powerBars[index]
			SetCustomColor(currentBar, powerType)
			currentBar.wouldBeHidden = false
			SetBarEnabled(currentBar, false)
			ApplyResourceBarStyle(self.frame, currentBar.barControls[1], self.style, powerType)
			self.resourceBars[powerType] = currentBar
		end
	end

	local function SetupCustomPowerBarsIfNeeded(self)
		SetupCustomPowerBar(self, MAGICKA_INDEX, COMBAT_MECHANIC_FLAGS_MAGICKA)
		SetupCustomPowerBar(self, STAMINA_INDEX, COMBAT_MECHANIC_FLAGS_STAMINA)
	end

	local function UpdateCustomPowerBar(self, index, powerType, cur, max, forceInit)
		SetupCustomPowerBarsIfNeeded(self)

		local currentBar = self.powerBars[index]
		if(currentBar ~= nil) then
			currentBar:Update(powerType, cur, max, forceInit)
			SetBarHidden(currentBar, IsUnitDead(self.unitTag) or powerType == COMBAT_MECHANIC_FLAGS_INVALID)
		end
	end

	SecurePostHook(ZO_UnitFrameObject, "SetBarsHidden", function(self, hidden)
		if(self.style == GROUP_FRAME_STYLE) then
			SetBarHidden(self.resourceBars[COMBAT_MECHANIC_FLAGS_MAGICKA], hidden)
			SetBarHidden(self.resourceBars[COMBAT_MECHANIC_FLAGS_STAMINA], hidden)
		end
	end)

	SecurePostHook(ZO_UnitFrameObject, "ApplyVisualStyle", function(self)
		if(self.style == GROUP_FRAME_STYLE or self.style == RAID_FRAME_STYLE) then
			if(self.powerBars[MAGICKA_INDEX]) then
				ApplyResourceBarStyle(self.frame, self.powerBars[MAGICKA_INDEX].barControls[1], self.style, COMBAT_MECHANIC_FLAGS_MAGICKA)
				RefreshHealthBarHeight(self, not self.powerBars[MAGICKA_INDEX].barControls[1].disabled) -- only need this once, because both bars disappear together
			end
			if(self.powerBars[STAMINA_INDEX]) then
				ApplyResourceBarStyle(self.frame, self.powerBars[STAMINA_INDEX].barControls[1], self.style, COMBAT_MECHANIC_FLAGS_STAMINA)
			end
		end
	end)

	SecurePostHook(ZO_UnitFrameObject, "Initialize", function(self)
		if(self.style == GROUP_FRAME_STYLE or self.style == RAID_FRAME_STYLE) then
			UpdateCustomPowerBar(self, MAGICKA_INDEX, COMBAT_MECHANIC_FLAGS_MAGICKA, 1, 1, FORCE_INIT)
			UpdateCustomPowerBar(self, STAMINA_INDEX, COMBAT_MECHANIC_FLAGS_STAMINA, 1, 1, FORCE_INIT)
		end
	end)

	local function SetUnitFrameResourceBarsEnabled(frame, enabled)
		if(not frame) then return end -- frames do not appear to get initialized while the player is using a menu
		SetBarEnabled(frame.resourceBars[COMBAT_MECHANIC_FLAGS_MAGICKA], enabled)
		SetBarEnabled(frame.resourceBars[COMBAT_MECHANIC_FLAGS_STAMINA], enabled)
		RefreshHealthBarHeight(frame, enabled)
	end

	local function RefreshBarStyles()
		for i = 1, GetGroupSize() do
			local frame = ZO_UnitFrames_GetUnitFrame(GetGroupUnitTagByIndex(i))
			frame:ApplyVisualStyle()
		end
		barStylesDirty = false
	end

	local function RefreshBarColors()
		for i = 1, GetGroupSize() do
			local frame = ZO_UnitFrames_GetUnitFrame(GetGroupUnitTagByIndex(i))
			if(frame.resourceBars[COMBAT_MECHANIC_FLAGS_MAGICKA]) then SetCustomColor(frame.resourceBars[COMBAT_MECHANIC_FLAGS_MAGICKA], COMBAT_MECHANIC_FLAGS_MAGICKA) end
			if(frame.resourceBars[COMBAT_MECHANIC_FLAGS_STAMINA]) then SetCustomColor(frame.resourceBars[COMBAT_MECHANIC_FLAGS_STAMINA], COMBAT_MECHANIC_FLAGS_STAMINA) end
		end
		barColorsDirty = false
	end

    local logger = LibDebugLogger(ADDON_NAME)
	SLASH_COMMANDS["/grtest"] = function(command) -- TODO remove
		if(command == "enable") then
			for i = 1, GetGroupSize() do
				local frame = ZO_UnitFrames_GetUnitFrame(GetGroupUnitTagByIndex(i))
				SetUnitFrameResourceBarsEnabled(frame, true)
			end
			logger:Debug("Enabled resource bars")
	elseif(command == "disable") then
		for i = 1, GetGroupSize() do
			local frame = ZO_UnitFrames_GetUnitFrame(GetGroupUnitTagByIndex(i))
			SetUnitFrameResourceBarsEnabled(frame, false)
		end
		logger:Debug("Disable resource bars")
	elseif(command == "style") then
		RefreshBarStyles()
		RefreshBarColors()
		logger:Debug("Refreshed resource bar styles")
	else
		logger:Debug("Unknown command '%s'", tostring(command))
	end
	end

	local GroupResources = LibGroupBroadcast:GetHandlerApi("GroupResources")

	local lastUpdateTime = {}
	GroupResources:RegisterForStaminaChanges(function(unitTag, unitName, current, maximum, percentage)
		local frame = ZO_UnitFrames_GetUnitFrame(unitTag)
		UpdateCustomPowerBar(frame, STAMINA_INDEX, COMBAT_MECHANIC_FLAGS_STAMINA, current, maximum)
		SetUnitFrameResourceBarsEnabled(frame, true)
		lastUpdateTime[unitTag] = GetTimeStamp()
	end)

	GroupResources:RegisterForMagickaChanges(function(unitTag, unitName, current, maximum, percentage)
		local frame = ZO_UnitFrames_GetUnitFrame(unitTag)
		UpdateCustomPowerBar(frame, MAGICKA_INDEX, COMBAT_MECHANIC_FLAGS_MAGICKA, current, maximum)
		SetUnitFrameResourceBarsEnabled(frame, true)
		lastUpdateTime[unitTag] = GetTimeStamp()
	end)

	local function OnUpdate()
		if(not IsUnitGrouped("player")) then return end
		if(barStylesDirty) then RefreshBarStyles() end
		if(barColorsDirty) then RefreshBarColors() end

		local now = GetTimeStamp()
		for i = 1, GetGroupSize() do
			local unitTag = GetGroupUnitTagByIndex(i)
			local lastUpdateTime = lastUpdateTime[unitTag] or 0
			if(saveData.hideResourceBarsToggle and now - lastUpdateTime > saveData.hideResourceBarsTimeout) then
				local frame = ZO_UnitFrames_GetUnitFrame(unitTag)
				SetUnitFrameResourceBarsEnabled(frame, false)
			end
		end
	end

	local active = false

	local function Activate()
		if(not active and IsUnitGrouped("player")) then
			EVENT_MANAGER:RegisterForUpdate(ADDON_NAME, 1000, OnUpdate)
			active = true
		end
	end

	local function Deactivate()
		if(active and not IsUnitGrouped("player")) then
			EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME)
			active = false
		end
	end

	RegisterForEvent(EVENT_UNIT_CREATED, Activate)
	RegisterForEvent(EVENT_UNIT_DESTROYED, Deactivate)
	Activate()
end)
