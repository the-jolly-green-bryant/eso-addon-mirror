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
	Table GroupSpeedOptions
]]--
TGT_GroupSpeedOptions = {}
TGT_GroupSpeedOptions.__index = TGT_GroupSpeedOptions

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
        -- Submenu Group Speed Options
        {   type            = "submenu",
			name            = GetString(TGT_OPTIONS_GROUP_SPEED_HEADER),
            controls = {
                -- Enable/Disable Group Speed
                {   type = "checkbox",
			        name = GetString(TGT_OPTIONS_GROUP_SPEED_LABEL),
			        tooltip = GetString(TGT_OPTIONS_GROUP_SPEED_TOOLTIP),
			        getFunc = 
                       function() 
                           return _settingsHandler.SavedVariables.IsGroupSpeedEnabled
                       end,
			        setFunc = 
                       function(value) 
                           _settingsHandler.SetIsGroupSpeedEnabledSettings(value)
			           end,
			        default = TGT_DEFAULTS.IsGroupSpeedEnabled,
		        },
                -- Enable/Disable Group Speed Header
                {   type = "checkbox",
			        name = GetString(TGT_OPTIONS_GROUP_SPEED_HEADER_LABEL),
			        tooltip = GetString(TGT_OPTIONS_GROUP_SPEED_HEADER_TOOLTIP),
			        getFunc = 
                       function() 
                           return _settingsHandler.SavedVariables.IsGroupSpeedHeaderVisible
                       end,
			        setFunc = 
                       function(value) 
                           _settingsHandler.SetIsGroupSpeedHeaderVisible(value)
			           end,
			        default = TGT_DEFAULTS.IsGroupSpeedHeaderVisible,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsGroupSpeedEnabled == false
                       end,
		        },
                -- Group Speed Bar Width
                {   type = "slider",
                    name = GetString(TGT_OPTIONS_GROUP_SPEED_WIDTH_LABEL),
			        tooltip = GetString(TGT_OPTIONS_GROUP_SPEED_WIDTH_TOOLTIP),
                    min = 100,
                    max = 200,
                    getFunc = 
                        function() 
                            return _settingsHandler.SavedVariables.GroupSpeedSize.Width
                        end,
                    setFunc = 
                        function(value)
                            _settingsHandler.SetGroupSpeedSize(value, _settingsHandler.SavedVariables.GroupSpeedSize.Height)
                        end,
                    default = TGT_DEFAULTS.GroupSpeedSize.Width,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsGroupSpeedEnabled == false
                       end,
                },
                -- Group Speed Bar Height
                {   type = "slider",
                    name = GetString(TGT_OPTIONS_GROUP_SPEED_HEIGHT_LABEL),
			        tooltip = GetString(TGT_OPTIONS_GROUP_SPEED_HEIGHT_TOOLTIP),
                    min = 20,
                    max = 40,
                    getFunc = 
                        function() 
                            return _settingsHandler.SavedVariables.GroupSpeedSize.Height
                        end,
                    setFunc = 
                        function(value)
                            _settingsHandler.SetGroupSpeedSize(_settingsHandler.SavedVariables.GroupSpeedSize.Width, value)
                        end,
                    default = TGT_DEFAULTS.GroupSpeedSize.Height,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsGroupSpeedEnabled == false
                       end,
                },
                -- Group Speed Bar color
                TGT_SettingsWindow.GetNewColorpicker(
                    GROUP_SPEED,
                    "GroupSpeedColor",
                    GetString(TGT_OPTIONS_GROUP_SPEED_COLOR_LABEL), 
                    GetString(TGT_OPTIONS_GROUP_SPEED_COLOR_TOOLTIP), 
                    function() return _settingsHandler.SavedVariables.IsGroupSpeedEnabled == false end),
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
function TGT_GroupSpeedOptions.GetOptions(options)
    local optionsData = CreateOptions()
    
    -- Add options
    for i = 1 , #optionsData do 
        table.insert(options, optionsData[i])
    end
end