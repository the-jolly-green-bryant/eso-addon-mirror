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
	Table GroupPurgeOptions
]]--
TGT_GroupPurgeOptions = {}
TGT_GroupPurgeOptions.__index = TGT_GroupPurgeOptions

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
        -- Submenu Group Purge Options
        {   type            = "submenu",
			name            = GetString(TGT_OPTIONS_GROUP_PURGE_HEADER),
            controls = {
                -- Enable/Disable Group Purge
                {   type = "checkbox",
			        name = GetString(TGT_OPTIONS_GROUP_PURGE_LABEL),
			        tooltip = GetString(TGT_OPTIONS_GROUP_PURGE_TOOLTIP),
			        getFunc = 
                       function() 
                           return _settingsHandler.SavedVariables.IsGroupPurgeEnabled
                       end,
			        setFunc = 
                       function(value) 
                           _settingsHandler.SetIsGroupPurgeEnabledSettings(value)
			           end,
			        default = TGT_DEFAULTS.IsGroupPurgeEnabled,
		        },
                -- Enable/Disable Group Purge Header
                {   type = "checkbox",
			        name = GetString(TGT_OPTIONS_GROUP_PURGE_HEADER_LABEL),
			        tooltip = GetString(TGT_OPTIONS_GROUP_PURGE_HEADER_TOOLTIP),
			        getFunc = 
                       function() 
                           return _settingsHandler.SavedVariables.IsGroupPurgeHeaderVisible
                       end,
			        setFunc = 
                       function(value) 
                           _settingsHandler.SetIsGroupPurgeHeaderVisible(value)
			           end,
			        default = TGT_DEFAULTS.IsGroupPurgeHeaderVisible,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsGroupPurgeEnabled == false
                       end,
		        },
                -- Group Purge Bar Width
                {   type = "slider",
                    name = GetString(TGT_OPTIONS_GROUP_PURGE_WIDTH_LABEL),
			        tooltip = GetString(TGT_OPTIONS_GROUP_PURGE_WIDTH_TOOLTIP),
                    min = 100,
                    max = 200,
                    getFunc = 
                        function() 
                            return _settingsHandler.SavedVariables.GroupPurgeSize.Width
                        end,
                    setFunc = 
                        function(value)
                            _settingsHandler.SetGroupPurgeSize(value, _settingsHandler.SavedVariables.GroupPurgeSize.Height)
                        end,
                    default = TGT_DEFAULTS.GroupPurgeSize.Width,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsGroupPurgeEnabled == false
                       end,
                },
                -- Group Purge Bar Height
                {   type = "slider",
                    name = GetString(TGT_OPTIONS_GROUP_PURGE_HEIGHT_LABEL),
			        tooltip = GetString(TGT_OPTIONS_GROUP_PURGE_HEIGHT_TOOLTIP),
                    min = 20,
                    max = 40,
                    getFunc = 
                        function() 
                            return _settingsHandler.SavedVariables.GroupPurgeSize.Height
                        end,
                    setFunc = 
                        function(value)
                            _settingsHandler.SetGroupPurgeSize(_settingsHandler.SavedVariables.GroupPurgeSize.Width, value)
                        end,
                    default = TGT_DEFAULTS.GroupPurgeSize.Height,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsGroupPurgeEnabled == false
                       end,
                },
                -- Group Purge Bar color
                TGT_SettingsWindow.GetNewColorpicker(
                    GROUP_PURGE,
                    "GroupPurgeColor",
                    GetString(TGT_OPTIONS_GROUP_PURGE_COLOR_LABEL), 
                    GetString(TGT_OPTIONS_GROUP_PURGE_COLOR_TOOLTIP), 
                    function() return _settingsHandler.SavedVariables.IsGroupPurgeEnabled == false end),
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
function TGT_GroupPurgeOptions.GetOptions(options)
    local optionsData = CreateOptions()
    
    -- Add options
    for i = 1 , #optionsData do 
        table.insert(options, optionsData[i])
    end
end