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
	Table GroupInviteOptions
]]--
TGT_GroupInviteOptions = {}
TGT_GroupInviteOptions.__index = TGT_GroupInviteOptions

--[[
	===============
    PRIVATE METHODS
    ===============
]]--

--[[
	Creates options
]]--
local function CreateOptions()
    local optionsData = {
        -- Submenu Group Invite Options
        {   type            = "submenu",
			name            = GetString(TGT_OPTIONS_GROUP_INVITE_HEADER),
            controls = {
                -- Enable/Disable Group Invite
                {   type = "checkbox",
			        name = GetString(TGT_OPTIONS_GROUP_INVITE_LABEL),
			        tooltip = GetString(TGT_OPTIONS_GROUP_INVITE_TOOLTIP),
			        getFunc = 
                       function() 
                           return _settingsHandler.SavedVariables.IsGroupInviteEnabled
                       end,
			        setFunc = 
                       function(value) 
                           _settingsHandler.SetIsGroupInviteEnabledSettings(value)
			           end,
			        default = TGT_DEFAULTS.IsGroupInviteEnabled,
		        },
                -- Maximum group size
                {   type = "slider",
                    name = GetString(TGT_OPTIONS_GROUP_SIZE_LABEL),
			        tooltip = GetString(TGT_OPTIONS_GROUP_SIZE_TOOLTIP),
                    min = 2,
                    max = 24,
                    getFunc = 
                        function() 
                            return _settingsHandler.SavedVariables.MaxGroupSize
                        end,
                    setFunc = 
                        function(value)
                            _settingsHandler.SetMaxGroupSizeSettings(value)
                        end,
                    default = TGT_DEFAULTS.MaxGroupSize,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsGroupInviteEnabled == false
                       end,
                },
                -- Auto kick
                {   type        = "checkbox",
			        name        = GetString(TGT_OPTIONS_AUTOKICK_LABEL),
			        tooltip     = GetString(TGT_OPTIONS_AUTOKICK_TOOLTIP),
			        getFunc = 
                       function() 
                           return _settingsHandler.SavedVariables.AutoKick
                       end,
			        setFunc = 
                       function(value) 
                           _settingsHandler.SetAutoKick(value)
			           end,
			        default     = TGT_DEFAULTS.AutoKick,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsGroupInviteEnabled == false
                       end,
		        },
                -- Auto kick timeout
                {   type = "slider",
                    name = GetString(TGT_OPTIONS_AK_TIMEOUT_LABEL),
			        tooltip = GetString(TGT_OPTIONS_AK_TIMEOUT_TOOLTIP),
                    min = 5,
                    max = 300,
                    getFunc = 
                        function() 
                            return _settingsHandler.SavedVariables.AutoKickTimeout
                        end,
                    setFunc = 
                        function(value)
                            _settingsHandler.SetAutoKickTimeoutSettings(value)
                        end,
                    default = TGT_DEFAULTS.AutoKickTimeout,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsGroupInviteEnabled == false
                       end,
                },
            },
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
function TGT_GroupInviteOptions.GetOptions(options)
    local optionsData = CreateOptions()
    
    -- Add options
    for i = 1 , #optionsData do 
        table.insert(options, optionsData[i])
    end
end