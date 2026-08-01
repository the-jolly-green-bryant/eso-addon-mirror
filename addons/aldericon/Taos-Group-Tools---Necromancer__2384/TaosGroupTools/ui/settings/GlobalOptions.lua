--[[
	Addon: Taos Group Tools
	Author: TProg Taonnor
	Created by @Taonnor
]]--

--[[
	Local variables
]]--
local _settingsHandler = TGT_SettingsHandler

--[[
	Table GlobalOptions
]]--
TGT_GlobalOptions = {}
TGT_GlobalOptions.__index = TGT_GlobalOptions

--[[
	===============
    PRIVATE METHODS
    ===============
]]--

--[[
	Creates options
]]--
local function CreateOptions()
	local soundChoices = {
        [1] = GetString(TGT_OPTIONS_NO_SOUND_LABEL),
        [2] = "DUEL_ACCEPTED",
        [3] = "ABILITY_ULTIMATE_READY",
        [4] = "ACHIEVEMENT_AWARDED",
        [5] = "DUEL_BOUNDARY_WARNING",
        [6] = "BATTLEGROUND_CAPTURE_FLAG_TAKEN_OWN_TEAM",
        [7] = "CHAMPION_POINT_GAINED",
        [8] = "DUEL_WON",
        [9] = "GENERAL_ALERT_ERROR",
        [10] = "LEVEL_UP",
    }

    local optionsData = {
        -- Options Header
        {   type = "header",
			name = GetString(TGT_OPTIONS_HEADER),
            width = "full"
		},
        -- Reset settings
        {   type = "button",
			name = GetString(TGT_OPTIONS_RESET_LABEL),
			tooltip = GetString(TGT_OPTIONS_RESET_TOOLTIP),
			func = 
                function() 
                    for id, value in pairs(TGT_DEFAULTS) do
                        TGT_SettingsHandler.SavedVariables[id] = value
                    end

                    ReloadUI()
                end,
            width = "half",
            warning = string.format("|cff0000%s", GetString(TGT_OPTIONS_RELOAD_UI_WARNING)),
		},
        -- Sending data
        {   type = "checkbox",
			name = GetString(TGT_OPTIONS_SENDING_LABEL),
			tooltip = GetString(TGT_OPTIONS_SENDING_TOOLTIP),
			getFunc = 
                function() 
                    return _settingsHandler.SavedVariables.IsSendingDataActive
                end,
			setFunc = 
                function(value) 
                    _settingsHandler.SetSendingDataSettings(value)
			    end,
			default = TGT_DEFAULTS.IsSendingDataActive
		},
        -- Controls Movable
        {   type = "checkbox",
			name = GetString(TGT_OPTIONS_DRAG_LABEL),
			tooltip = GetString(TGT_OPTIONS_DRAG_TOOLTIP),
			getFunc = 
                function() 
                    return _settingsHandler.SavedVariables.Movable
                end,
			setFunc = 
                function(value) 
                    _settingsHandler.SetMovableSettings(value)
			    end,
			default = TGT_DEFAULTS.Movable
		},
        -- Show account names
        {   type = "checkbox",
			name = GetString(TGT_OPTIONS_SHOW_ACCOUNT_LABEL),
			tooltip = GetString(TGT_OPTIONS_SHOW_ACCOUNT_TOOLTIP),
			getFunc = 
                function() 
                    return _settingsHandler.SavedVariables.AccountNames
                end,
			setFunc = 
                function(value) 
                    _settingsHandler.SavedVariables.AccountNames = value
			    end,
			default = TGT_DEFAULTS.AccountNames
		},
        -- Sounds on ready
        {   type        = "dropdown",
			name        = GetString(TGT_OPTIONS_SOUND_READY_LABEL),
			tooltip     = GetString(TGT_OPTIONS_SOUND_READY_TOOLTIP),
            choices     = soundChoices,
			getFunc = 
                function() 
                    return soundChoices[_settingsHandler.SavedVariables.SoundOnReady[1]]
                end,
			setFunc = 
				function(value) 
                    for index, name in ipairs(soundChoices) do
                        if (name == value) then
                            if (index > 1) then PlaySound(SOUNDS[value]) end
                            _settingsHandler.SetSoundOnReadySettings(index, value)
                            break
                        end
                    end
				end,
			default     = soundChoices[TGT_DEFAULTS.SoundOnReady[1]]
		},
        -- Sound on thrown
        {   type        = "dropdown",
			name        = GetString(TGT_OPTIONS_SOUND_THROWN_LABEL),
			tooltip     = GetString(TGT_OPTIONS_SOUND_THROWN_TOOLTIP),
            choices     = soundChoices,
			getFunc = 
                function() 
                    return soundChoices[_settingsHandler.SavedVariables.SoundOnThrown[1]]
                end,
			setFunc = 
				function(value) 
                    for index, name in ipairs(soundChoices) do
                        if (name == value) then
                            if (index > 1) then PlaySound(SOUNDS[value]) end
                            _settingsHandler.SetSoundOnThrownSettings(index, value)
                            break
                        end
                    end
				end,
			default     = soundChoices[TGT_DEFAULTS.SoundOnThrown[1]]
		},
    }

    return optionsData
end

--[[
	==============
    PUBLIC METHODS
    ==============
]]--

--[[
	GetOptions creates settings and returns
]]--
function TGT_GlobalOptions.GetOptions(options)
    local optionsData = CreateOptions()
    
    -- Add options
    for i = 1 , #optionsData do 
        table.insert(options, optionsData[i])
    end
end