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
	Table GroupDpsHpsOptions
]]--
TGT_GroupDpsHpsOptions = {}
TGT_GroupDpsHpsOptions.__index = TGT_GroupDpsHpsOptions

--[[
	===============
    PRIVATE METHODS
    ===============
]]--

--[[
	Creates options
]]--
local function CreateOptions()
    local styleChoices = {
        [1] = GetString(TGT_OPTIONS_DPSHPS_STYLE_SIMPLE),
        [2] = GetString(TGT_OPTIONS_DPSHPS_STYLE_BAR),
    }
    
    local partChoices = {
        [1] = GetString(TGT_OPTIONS_DPSHPS_PART_ALL),
        [2] = GetString(TGT_OPTIONS_DPSHPS_PART_DPS),
        [3] = GetString(TGT_OPTIONS_DPSHPS_PART_HPS),
    }
    
	local optionsData = {
        -- Submenu Group Dps/Hps Options
        {   type            = "submenu",
			name            = GetString(TGT_OPTIONS_GROUP_DPSHPS_HEADER),
            controls = {
                -- Enable/Disable Group HPS/DPS
                {   type = "checkbox",
			        name = GetString(TGT_OPTIONS_GROUP_DPSHPS_LABEL),
			        tooltip = GetString(TGT_OPTIONS_GROUP_DPSHPS_TOOLTIP),
			        getFunc = 
                       function() 
                           return _settingsHandler.SavedVariables.IsGroupHpsDpsEnabled
                       end,
			        setFunc = 
                       function(value) 
                           _settingsHandler.SetIsGroupHpsDpsEnabledSettings(value)
			           end,
			        default = TGT_DEFAULTS.IsGroupHpsDpsEnabled,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsSendingDataActive == false
                       end,
		        },
                -- Only AvA visible
                {   type        = "checkbox",
			        name        = GetString(TGT_OPTIONS_ONLY_AVA_LABEL),
			        tooltip     = GetString(TGT_OPTIONS_ONLY_AVA_TOOLTIP),
			        getFunc = 
                       function() 
                           return _settingsHandler.SavedVariables.OnlyAva[GROUP_STATS]
                       end,
			        setFunc = 
                       function(value) 
                           _settingsHandler.SetOnlyAvaSettings(GROUP_STATS, value)
			           end,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsSendingDataActive == false or _settingsHandler.SavedVariables.IsGroupHpsDpsEnabled == false
                       end,
			        default     = TGT_DEFAULTS.OnlyAva[GROUP_STATS]
		        },
                -- Style
                {   type        = "dropdown",
			        name        = GetString(TGT_OPTIONS_STYLE_LABEL),
			        tooltip     = GetString(TGT_OPTIONS_DPSHPS_STYLE_TOOLTIP),
                    choices     = styleChoices,
			        getFunc = 
                       function() 
                           return styleChoices[_settingsHandler.SavedVariables.Style[GROUP_STATS]]
                       end,
			        setFunc = 
                       function(value) 
                           for index, name in ipairs(styleChoices) do
                              if (name == value) then
                                 _settingsHandler.SetStyleSettings(GROUP_STATS, index)
                                 break
                              end
                           end
			           end,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsSendingDataActive == false or _settingsHandler.SavedVariables.IsGroupHpsDpsEnabled == false
                       end,
			        default     = styleChoices[TGT_DEFAULTS.Style[GROUP_STATS]]
		        },
                -- Visible Offset
                {   type        = "slider", 
                    name        = GetString(TGT_OPTIONS_VISIBLE_OFF_LABEL),
                    tooltip     = GetString(TGT_OPTIONS_VISIBLE_OFF_TOOLTIP),
                    min         = 2, 
                    max         = 24, 
                    step        = 1, 
                    getFunc = 
                        function() 
                            return _settingsHandler.SavedVariables.VisibleOffset[GROUP_STATS]
                        end, 
                    setFunc = 
                        function(value) 
                            _settingsHandler.SetVisibleOffsetSettings(GROUP_STATS, value) 
                        end, 
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsSendingDataActive == false or _settingsHandler.SavedVariables.IsGroupHpsDpsEnabled == false
                       end,
                    default     = TGT_DEFAULTS.VisibleOffset[GROUP_STATS],
                },
                -- Visible Parts
                {   type        = "dropdown",
			        name        = GetString(TGT_OPTIONS_DPSHPS_PART_ALL_LABEL),
			        tooltip     = GetString(TGT_OPTIONS_DPSHPS_PART_ALL_TOOLTIP),
                    choices     = partChoices,
			        getFunc = 
                       function() 
                           return partChoices[_settingsHandler.SavedVariables.DpsHpsVisibleOption]
                       end,
			        setFunc = 
                       function(value) 
                           for index, name in ipairs(partChoices) do
                              if (name == value) then
                                 _settingsHandler.SetDpsHpsVisibleOptionSettings(index)
                                 break
                              end
                           end
			           end,
			        default     = partChoices[TGT_DEFAULTS.DpsHpsVisibleOption],
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsSendingDataActive == false or _settingsHandler.SavedVariables.IsGroupHpsDpsEnabled == false
                       end,
		        },
                -- Group DpsHps Bar color
                TGT_SettingsWindow.GetNewColorpicker(
                    GROUP_STATS,
                    "GroupHpsDpsBarColor",
                    GetString(TGT_OPTIONS_GROUP_DPSHPS_COLOR_LABEL), 
                    GetString(TGT_OPTIONS_GROUP_DPSHPS_COLOR_TOOLTIP), 
                    function() return _settingsHandler.SavedVariables.IsSendingDataActive == false or 
                                      _settingsHandler.SavedVariables.IsGroupHpsDpsEnabled == false or
                                      _settingsHandler.SavedVariables.Style[GROUP_STATS] == 1 end),
                -- Show bar gloss
                {   type        = "checkbox",
			        name        = GetString(TGT_OPTIONS_GROUP_DPSHPS_BAR_GLOSS_LABEL),
			        tooltip     = GetString(TGT_OPTIONS_GROUP_DPSHPS_BAR_GLOSS_TOOLTIP),
			        getFunc = 
                       function() 
                           return _settingsHandler.SavedVariables.ShowBarGloss
                       end,
			        setFunc = 
                       function(value) 
                           _settingsHandler.SavedVariables.ShowBarGloss = value
			           end,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsSendingDataActive == false or _settingsHandler.SavedVariables.IsGroupHpsDpsEnabled == false
                       end,
			        default     = TGT_DEFAULTS.ShowBarGloss
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
function TGT_GroupDpsHpsOptions.GetOptions(options)
    local optionsData = CreateOptions()
    
    -- Add options
    for i = 1 , #optionsData do 
        table.insert(options, optionsData[i])
    end
end