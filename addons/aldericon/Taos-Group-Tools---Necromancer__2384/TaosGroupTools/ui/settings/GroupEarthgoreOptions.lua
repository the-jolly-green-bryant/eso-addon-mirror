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
	Table GroupEarthgoreOptions
]]--
TGT_GroupEarthgoreOptions = {}
TGT_GroupEarthgoreOptions.__index = TGT_GroupEarthgoreOptions

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
        -- Submenu Group Earthgore Options
        {   type            = "submenu",
			name            = GetString(TGT_OPTIONS_GROUP_EARTHGORE_HEADER),
            controls = {
                -- Enable/Disable Group Earthgore
                {   type = "checkbox",
			        name = GetString(TGT_OPTIONS_GROUP_EARTHGORE_LABEL),
			        tooltip = GetString(TGT_OPTIONS_GROUP_EARTHGORE_TOOLTIP),
			        getFunc = 
                       function() 
                           return _settingsHandler.SavedVariables.IsGroupEarthgoreEnabled
                       end,
			        setFunc = 
                       function(value) 
                           _settingsHandler.SetIsGroupEarthgoreEnabledSettings(value)
			           end,
			        default = TGT_DEFAULTS.IsGroupEarthgoreEnabled,
		        },
                -- Enable/Disable Group Earthgore Header
                {   type = "checkbox",
			        name = GetString(TGT_OPTIONS_GROUP_EARTHGORE_HEADER_LABEL),
			        tooltip = GetString(TGT_OPTIONS_GROUP_EARTHGORE_HEADER_TOOLTIP),
			        getFunc = 
                       function() 
                           return _settingsHandler.SavedVariables.IsGroupEarthgoreHeaderVisible
                       end,
			        setFunc = 
                       function(value) 
                           _settingsHandler.SetIsGroupEarthgoreHeaderVisible(value)
			           end,
			        default = TGT_DEFAULTS.IsGroupEarthgoreHeaderVisible,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsGroupEarthgoreEnabled == false
                       end,
		        },
                -- Group Earthgore Bar Width
                {   type = "slider",
                    name = GetString(TGT_OPTIONS_GROUP_EARTHGORE_WIDTH_LABEL),
			        tooltip = GetString(TGT_OPTIONS_GROUP_EARTHGORE_WIDTH_TOOLTIP),
                    min = 100,
                    max = 200,
                    getFunc = 
                        function() 
                            return _settingsHandler.SavedVariables.GroupEarthgoreSize.Width
                        end,
                    setFunc = 
                        function(value)
                            _settingsHandler.SetGroupEarthgoreSize(value, _settingsHandler.SavedVariables.GroupEarthgoreSize.Height)
                        end,
                    default = TGT_DEFAULTS.GroupEarthgoreSize.Width,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsGroupEarthgoreEnabled == false
                       end,
                },
                -- Group Earthgore Bar Height
                {   type = "slider",
                    name = GetString(TGT_OPTIONS_GROUP_EARTHGORE_HEIGHT_LABEL),
			        tooltip = GetString(TGT_OPTIONS_GROUP_EARTHGORE_HEIGHT_TOOLTIP),
                    min = 20,
                    max = 40,
                    getFunc = 
                        function() 
                            return _settingsHandler.SavedVariables.GroupEarthgoreSize.Height
                        end,
                    setFunc = 
                        function(value)
                            _settingsHandler.SetGroupEarthgoreSize(_settingsHandler.SavedVariables.GroupEarthgoreSize.Width, value)
                        end,
                    default = TGT_DEFAULTS.GroupEarthgoreSize.Height,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsGroupEarthgoreEnabled == false
                       end,
                },
                -- Group Earthgore Bar color
                TGT_SettingsWindow.GetNewColorpicker(
                    GROUP_EARTHGORE,
                    "GroupEarthgoreColor",
                    GetString(TGT_OPTIONS_GROUP_EARTHGORE_COLOR_LABEL), 
                    GetString(TGT_OPTIONS_GROUP_EARTHGORE_COLOR_TOOLTIP), 
                    function() return _settingsHandler.SavedVariables.IsGroupEarthgoreEnabled == false end),
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
function TGT_GroupEarthgoreOptions.GetOptions(options)
    local optionsData = CreateOptions()
    
    -- Add options
    for i = 1 , #optionsData do 
        table.insert(options, optionsData[i])
    end
end