local arr = AssistRapidRiding
local tinsert = table.insert

function arr.SettingsLoad()
	arr.soundChoices = {}
	for k,v in pairs(SOUNDS) do
		tinsert(arr.soundChoices, k)
	end
	table.sort(arr.soundChoices)
	arr.savedVarsDefaults = {
		switchSlot = 5,
		reswitchAhead = 3,
		soundEnabled = false,
		soundIndex = 28,
		debugLevel = 0,
		accountWide = true,
		hotkeyOnly = false,
	}
	arr.savedVars = ZO_SavedVars:NewAccountWide( arr.savedVarsName, arr.savedVarsVersion, nil, arr.savedVarsDefaults )
	arr.characterSavedVars = ZO_SavedVars:New( arr.savedVarsName, arr.savedVarsVersion, nil, arr.savedVarsDefaults )
end

function arr.SettingsMenu()
	local LAM2 = LibStub("LibAddonMenu-2.0")
	if LAM2 == nil then return end
	local panelData = {
		type = 'panel',
		name = "Assist Rapid Riding",
		displayName = "ARR Settings",
		author = "Cloudor",
		version = arr.version,
		--website = "http://www.esoui.com/downloads/info1536-ActionDurationReminder.html",
		slashCommand = "/arrset",
		registerForRefresh = true,
		registerForDefaults = true,
		debugLevel = 0,
	}
	local optionsData = {
		--
		{
			type = "checkbox",
			name = "Account Wide Settings",
			getFunc = function() return arr.savedVars.accountWide end,
			setFunc = function(value) arr.savedVars.accountWide = value end,
			width = "full",
			default = arr.savedVarsDefaults.accountWide,
		},
		--
        {
            type = "checkbox",
            name = "Hotkey Only",
            getFunc = function() return arr.SettingsVarGet('hotkeyOnly') end,
            setFunc = function(value) arr.SettingsVarSet('hotkeyOnly', value) end,
            width = "full",
            default = arr.savedVarsDefaults.hotkeyOnly,
        },
		--
		{
			type = "slider",
			name = "Switch Action In Slot",
			--tooltip = "",
			min = 1, max = 5, step = 1,
			getFunc = function() return arr.SettingsVarGet('switchSlot') end,
			setFunc = function(value) arr.SettingsVarSet('switchSlot', value) end,
			width = "full",
			default = arr.savedVarsDefaults.switchSlot,
		},
		--
		{
			type = "slider",
			name = "Seconds Switch Again Before Timeout",
			--tooltip = "",
			min = 0, max = 5, step = 1,
			getFunc = function() return arr.SettingsVarGet('reswitchAhead') end,
			setFunc = function(value) arr.SettingsVarSet('reswitchAhead', value) end,
			width = "full",
			default = arr.savedVarsDefaults.reswitchAhead,
		},
		--
		{
			type = "checkbox",
			name = "Sound Enabled",
			getFunc = function() return arr.SettingsVarGet('soundEnabled') end,
			setFunc = function(value) arr.SettingsVarSet('soundEnabled', value) end,
			width = "full",
			default = arr.savedVarsDefaults.soundEnabled,
		},
		--
		{
			type = "slider",
			name = "Sound Index",
			--tooltip = "",
			min = 1, max = #arr.soundChoices, step = 1,
			getFunc = function() return arr.SettingsVarGet('soundIndex') end,
			setFunc = function(value) arr.SettingsVarSet('soundIndex', value); PlaySound(SOUNDS[arr.soundChoices[arr.SettingsVarGet('soundIndex')]]) end,
			width = "full",
			disabled = function() return not arr.SettingsVarGet('soundEnabled') end,
			default = arr.savedVarsDefaults.soundIndex,
		},
		--
		{
			type = "slider",
			name = "Debug Level",
			--tooltip = "",
			min = 0, max = 1, step = 1,
			getFunc = function() return arr.SettingsVarGet('debugLevel') end,
			setFunc = function(value) arr.SettingsVarSet('debugLevel', value) end,
			width = "full",
			default = arr.savedVarsDefaults.debugLevel,
		},
	}
	LAM2:RegisterAddonPanel('ARRAddonOptions', panelData)
	LAM2:RegisterOptionControls('ARRAddonOptions', optionsData)
end

function arr.SettingsVarGet(key)
	return arr.savedVars.accountWide and arr.savedVars[key] or arr.characterSavedVars[key]
end

function arr.SettingsVarSet(key, value)
	if arr.savedVars.accountWide then 
		arr.savedVars[key] = value
	else
		arr.characterSavedVars[key] = value
	end
end