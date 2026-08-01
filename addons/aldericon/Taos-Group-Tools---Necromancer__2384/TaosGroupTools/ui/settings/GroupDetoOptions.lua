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
	Table GroupDetoOptions
]]--
TGT_GroupDetoOptions = {}
TGT_GroupDetoOptions.__index = TGT_GroupDetoOptions

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
        -- Submenu Group Deto Options
        {   type            = "submenu",
			name            = GetString(TGT_OPTIONS_GROUP_DETO_HEADER),
            controls = {
                -- Enable/Disable Group Deto
                {   type = "checkbox",
			        name = GetString(TGT_OPTIONS_GROUP_DETO_LABEL),
			        tooltip = GetString(TGT_OPTIONS_GROUP_DETO_TOOLTIP),
			        getFunc = 
                       function() 
                           return _settingsHandler.SavedVariables.IsGroupDetoEnabled
                       end,
			        setFunc = 
                       function(value) 
                           _settingsHandler.SetIsGroupDetoEnabledSettings(value)
			           end,
			        default = TGT_DEFAULTS.IsGroupDetoEnabled,
		        },
                -- Enable/Disable Group Deto Header
                {   type = "checkbox",
			        name = GetString(TGT_OPTIONS_GROUP_DETO_HEADER_LABEL),
			        tooltip = GetString(TGT_OPTIONS_GROUP_DETO_HEADER_TOOLTIP),
			        getFunc = 
                       function() 
                           return _settingsHandler.SavedVariables.IsGroupDetoHeaderVisible
                       end,
			        setFunc = 
                       function(value) 
                           _settingsHandler.SetIsGroupDetoHeaderVisible(value)
			           end,
			        default = TGT_DEFAULTS.IsGroupDetoHeaderVisible,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsGroupDetoEnabled == false
                       end,
		        },
                -- Group Deto Bar Width
                {   type = "slider",
                    name = GetString(TGT_OPTIONS_GROUP_DETO_WIDTH_LABEL),
			        tooltip = GetString(TGT_OPTIONS_GROUP_DETO_WIDTH_TOOLTIP),
                    min = 100,
                    max = 200,
                    getFunc = 
                        function() 
                            return _settingsHandler.SavedVariables.GroupDetoSize.Width
                        end,
                    setFunc = 
                        function(value)
                            _settingsHandler.SetGroupDetoSize(value, _settingsHandler.SavedVariables.GroupDetoSize.Height)
                        end,
                    default = TGT_DEFAULTS.GroupDetoSize.Width,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsGroupDetoEnabled == false
                       end,
                },
                -- Group Deto Bar Height
                {   type = "slider",
                    name = GetString(TGT_OPTIONS_GROUP_DETO_HEIGHT_LABEL),
			        tooltip = GetString(TGT_OPTIONS_GROUP_DETO_HEIGHT_TOOLTIP),
                    min = 20,
                    max = 40,
                    getFunc = 
                        function() 
                            return _settingsHandler.SavedVariables.GroupDetoSize.Height
                        end,
                    setFunc = 
                        function(value)
                            _settingsHandler.SetGroupDetoSize(_settingsHandler.SavedVariables.GroupDetoSize.Width, value)
                        end,
                    default = TGT_DEFAULTS.GroupDetoSize.Height,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsGroupDetoEnabled == false
                       end,
                },
                -- Group Deto Bar color
                TGT_SettingsWindow.GetNewColorpicker(
                    GROUP_DETONATION,
                    "GroupDetoColor",
                    GetString(TGT_OPTIONS_GROUP_DETO_COLOR_LABEL), 
                    GetString(TGT_OPTIONS_GROUP_DETO_COLOR_TOOLTIP), 
                    function() return _settingsHandler.SavedVariables.IsGroupDetoEnabled == false end),
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
function TGT_GroupDetoOptions.GetOptions(options)
    local optionsData = CreateOptions()
    
    -- Add options
    for i = 1 , #optionsData do 
        table.insert(options, optionsData[i])
    end
end