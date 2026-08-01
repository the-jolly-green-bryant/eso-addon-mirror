local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")

RandomMount = {}

RandomMount.name = 'RandomMount'
RandomMount.version = 2 -- This should probably only be updated for major updates.

RandomMount.Default = {
	logMount = true,
	freq = GetString(RM_FREQ_ON_LOGIN),
}

function RandomMount.OnAddOnLoaded(event, addonName)
	if addonName == RandomMount.name then
		RandomMount:Initialize()
	end
end

function RandomMount:Initialize()
	RandomMount.savedVariables = ZO_SavedVars:New("RandomMountVars", RandomMount.version, nil, RandomMount.Default)
	RandomMount.CreateSettingsWindow()

	if (RandomMount.savedVariables.freq ~= GetString(RM_FREQ_NEVER)) then
		EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, self.TriggerRandomMount)
	end

	SLASH_COMMANDS["/randommount"] = function()
		RandomMount.PickRandomMount()
	end

	EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
end

function RandomMount.CreateSettingsWindow()
	local sv = RandomMount.savedVariables

	local settingsWindowData = {
		type = "panel",
		name = "Random Mount",
		displayName = "Random Mount",
		author = "joshfong",
		version = "1.0.1",
		registerForRefresh = false,
		registerForDefaults = false,
	}

	local settingsOptionPanel = LAM2:RegisterAddonPanel("RandomMount_Settings", settingsWindowData)

	local checkLabel = GetString(RM_CHAT_DISPLAY_LABEL)
	local checkTooltip = GetString(RM_CHAT_DISPLAY_TOOLTIP)
	local freqLabel = GetString(RM_FREQ_LABEL)
	local freqTooltip = GetString(RM_FREQ_TOOLTIP)
	local freqOnLogin = GetString(RM_FREQ_ON_LOGIN)
	local freqOnLoadScreen = GetString(RM_FREQ_ON_LOAD_SCREEN)
	local freqNever = GetString(RM_FREQ_NEVER)
	local freqWarning = GetString(RM_FREQ_WARNING)
	local reloadUILabel = GetString(RM_RELOAD_UI_LABEL)

	local settingsOptionsData = {
		[1] = {
			type = "checkbox",
			name = checkLabel,
			tooltip = checkTooltip,
			default = true,
			getFunc = function() return sv.logMount end,
			setFunc = function(newValue) sv.logMount = newValue end,
		},
		[2] = {
			type = "dropdown",
			name = freqLabel,
			tooltip = freqTooltip,
			choices = {freqOnLogin, freqOnLoadScreen, freqNever},
			getFunc = function() return sv.freq end,
			setFunc = function(newValue) sv.freq = newValue end,
			warning = freqWarning,
		},
		[3] = {
			type = "button",
			name = reloadUILabel,
			func = function() ReloadUI() end,
			width = "half",
		}
	}

	LAM2:RegisterOptionControls("RandomMount_Settings", settingsOptionsData)
end

function RandomMount.TriggerRandomMount(eventCode, initial)
	sv = RandomMount.savedVariables


	if (sv.freq == GetString(RM_FREQ_ON_LOGIN)) then
		EVENT_MANAGER:UnregisterForEvent(RandomMount.name, eventCode)
	end
	RandomMount.PickRandomMount()
end

function RandomMount.PickRandomMount()
	sv = RandomMount.savedVariables

	-- Mounts
	-- Top-level index: 8
	-- Category ID: 2

	topLevel = 8
	mountsId = 2

	whichMount = math.random(1000)
	mountId = GetCollectibleIdFromType(mountsId, whichMount)
	link = GetCollectibleLink(mountId, 1)

	canBeUsed = IsCollectibleUsable(mountId)
	inUse = IsCollectibleActive(mountId)

	if (canBeUsed and inUse == false) then
		UseCollectible(mountId)

		if (sv.logMount == true) then
			local logText = GetString(RM_MOUNT_CHAT_LOG)

			CHAT_SYSTEM.containers[1].windows[1].buffer:AddMessage(logText .. link)
		end
	else
		RandomMount.PickRandomMount()
	end
end

EVENT_MANAGER:RegisterForEvent(RandomMount.name, EVENT_ADD_ON_LOADED, RandomMount.OnAddOnLoaded)
