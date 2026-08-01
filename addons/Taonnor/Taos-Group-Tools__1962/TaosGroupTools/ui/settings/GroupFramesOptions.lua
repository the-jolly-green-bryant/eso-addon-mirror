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
	Table GroupFramesOptions
]]--
TGT_GroupFramesOptions = {}
TGT_GroupFramesOptions.__index = TGT_GroupFramesOptions

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
        [1] = GetString(TGT_OPTIONS_FRAMES_STYLE_NORMAL),
        [2] = GetString(TGT_OPTIONS_FRAMES_STYLE_SMALL),
        [3] = GetString(TGT_OPTIONS_FRAMES_STYLE_TINY),
    }

    local formatChoices = {
        [1] = GetString(TGT_OPTIONS_HEALTHBAR_FORMAT_NONE),
        [2] = GetString(TGT_OPTIONS_HEALTHBAR_FORMAT_ABS),
        [3] = GetString(TGT_OPTIONS_HEALTHBAR_FORMAT_ABS_SHORT),
        [4] = GetString(TGT_OPTIONS_HEALTHBAR_FORMAT_PERCENT),
    }
    
    local buffTrackerChoises = TGT_SettingsWindow.GetBuffTrackerChoises()
    
    local optionsData = {
        -- Submenu Group Frames Options
        {   type            = "submenu",
			name            = GetString(TGT_OPTIONS_GROUP_FRAMES_HEADER),
            controls = {
                -- Enable/Disable Group Frames
                {   type = "checkbox",
			        name = GetString(TGT_OPTIONS_GROUP_FRAMES_LABEL),
			        tooltip = GetString(TGT_OPTIONS_GROUP_FRAMES_TOOLTIP),
			        getFunc = 
                       function() 
                           return _settingsHandler.SavedVariables.IsGroupFramesEnabled
                       end,
			        setFunc = 
                       function(value) 
                           _settingsHandler.SetIsGroupFramesEnabledSettings(value)
			           end,
			        default = TGT_DEFAULTS.IsGroupFramesEnabled
		        },
                -- Enable/Disable ZOS Group Frames
                {   type = "checkbox",
			        name = GetString(TGT_OPTIONS_HIDE_ZOS_GROUP_FRAMES_LABEL),
			        tooltip = GetString(TGT_OPTIONS_HIDE_ZOS_GROUP_FRAMES_TOOLTIP),
			        getFunc = 
                       function() 
                           return _settingsHandler.SavedVariables.HideZosGroupFrames
                       end,
			        setFunc = 
                       function(value) 
                           _settingsHandler.SavedVariables.HideZosGroupFrames = value
                           _settingsHandler.OnGroupFramesSettingsChanged()
			           end,
                    requiresReload = true,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsGroupFramesEnabled == false
                       end,
			        default = TGT_DEFAULTS.IsGroupFramesEnabled
		        },
                -- InCombat active
                {   type        = "checkbox",
			        name        = GetString(TGT_OPTIONS_USE_INCOMBAT_LABEL),
			        tooltip     = GetString(TGT_OPTIONS_FRAMES_INCOMBAT_TOOLTIP),
			        getFunc = 
                       function() 
                           return _settingsHandler.SavedVariables.CombatActive[GROUP_FRAMES]
                       end,
			        setFunc = 
                       function(value) 
                           _settingsHandler.SetCombatActiveSettings(GROUP_FRAMES, value)
			           end,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsGroupFramesEnabled == false
                       end,
			        default     = TGT_DEFAULTS.CombatActive[GROUP_FRAMES]
		        },
                -- Scaling
                {   type        = "slider", 
                    name        = GetString(TGT_OPTIONS_SCALE_LABEL),
                    tooltip     = GetString(TGT_OPTIONS_FRAMES_SCALE_TOOLTIP),
                    min         = 0.1, 
                    max         = 2.0, 
                    step        = 0.1, 
                    decimals    = 1,
                    getFunc = 
                        function() 
                            return _settingsHandler.SavedVariables.Scale[GROUP_FRAMES]
                        end, 
                    setFunc = 
                        function(value) 
                            _settingsHandler.SetScaleSettings(GROUP_FRAMES, value) 
                        end, 
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsGroupFramesEnabled == false
                       end,
                    default     = TGT_DEFAULTS.Scale[GROUP_FRAMES],
                },
                -- Style
                {   type        = "dropdown",
			        name        = GetString(TGT_OPTIONS_FRAMES_STYLE_LABEL),
			        tooltip     = GetString(TGT_OPTIONS_FRAMES_STYLE_TOOLTIP),
                    choices     = styleChoices,
			        getFunc = 
                       function() 
                           return styleChoices[_settingsHandler.SavedVariables.Style[GROUP_FRAMES]]
                       end,
			        setFunc = 
                       function(value) 
                           for index, name in ipairs(styleChoices) do
                              if (name == value) then
                                 _settingsHandler.SetStyleSettings(GROUP_FRAMES, index)
                                 break
                              end
                           end
			           end,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsSendingDataActive == false or _settingsHandler.SavedVariables.IsGroupFramesEnabled == false
                       end,
			        default     = styleChoices[TGT_DEFAULTS.Style[GROUP_FRAMES]]
		        },
                -- Show Ultimate instead of Health
                {   type = "checkbox",
			        name = GetString(TGT_OPTIONS_SHOW_ULTIMATE_LABEL),
			        tooltip = GetString(TGT_OPTIONS_SHOW_ULTIMATE_TOOLTIP),
			        getFunc = 
                       function() 
                           return _settingsHandler.SavedVariables.ShowUltimateInsteadHaelth
                       end,
			        setFunc = 
                       function(value) 
                           _settingsHandler.SavedVariables.ShowUltimateInsteadHaelth = value
                           _settingsHandler.OnGroupFramesSettingsChanged()
			           end,
			        default = TGT_DEFAULTS.ShowUltimateInsteadHaelth,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsGroupFramesEnabled == false
                       end,
		        },
                -- Group Frames Bar Width
                {   type = "slider",
                    name = GetString(TGT_OPTIONS_FRAMES_WIDTH_LABEL),
			        tooltip = GetString(TGT_OPTIONS_FRAMES_WIDTH_TOOLTIP),
                    min = 140,
                    max = 240,
                    getFunc = 
                        function() 
                            return _settingsHandler.SavedVariables.GroupFramesBarWidth
                        end,
                    setFunc = 
                        function(value)
                            _settingsHandler.SavedVariables.GroupFramesBarWidth = value
                            _settingsHandler.OnGroupFramesSettingsChanged()
                        end,
                    default = TGT_DEFAULTS.GroupFramesBarWidth,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsSendingDataActive == false or _settingsHandler.SavedVariables.IsGroupFramesEnabled == false
                       end,
                },
                -- Enable/Disable Food Buff
                {   type = "checkbox",
			        name = GetString(TGT_OPTIONS_SHOW_FOOD_BUFF_LABEL),
			        tooltip = GetString(TGT_OPTIONS_SHOW_FOOD_BUFF_TOOLTIP),
			        getFunc = 
                       function() 
                           return _settingsHandler.SavedVariables.ShowFoodBuff
                       end,
			        setFunc = 
                       function(value) 
                           _settingsHandler.SavedVariables.ShowFoodBuff = value
                           _settingsHandler.OnGroupFramesSettingsChanged()
			           end,
			        default = TGT_DEFAULTS.ShowFoodBuff,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsGroupFramesEnabled == false or _settingsHandler.SavedVariables.Style[GROUP_FRAMES] == 3
                       end,
		        },
                -- HP Formats
                {   type        = "dropdown",
			        name        = GetString(TGT_OPTIONS_HEALTHBAR_FORMAT_LABEL),
			        tooltip     = GetString(TGT_OPTIONS_HEALTHBAR_FORMAT_TOOLTIP),
                    choices     = formatChoices,
			        getFunc = 
                       function() 
                           return formatChoices[_settingsHandler.SavedVariables.HealthBarFormat]
                       end,
			        setFunc = 
                       function(value) 
                           for index, name in ipairs(formatChoices) do
                              if (name == value) then
                                _settingsHandler.SavedVariables.HealthBarFormat = index
                                _settingsHandler.OnGroupFramesSettingsChanged()
                                break
                              end
                           end
			           end,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsGroupFramesEnabled == false or
                                  _settingsHandler.SavedVariables.ShowUltimateInsteadHaelth == true
                        end,
			        default     = formatChoices[TGT_DEFAULTS.HealthBarFormat]
		        },
                -- Shield color
                TGT_SettingsWindow.GetNewColorpicker(
                    GROUP_FRAMES,
                    "ShieldColor",
                    GetString(TGT_OPTIONS_SHIELD_COLOR_LABEL), 
                    GetString(TGT_OPTIONS_SHIELD_COLOR_TOOLTIP), 
                    function() return _settingsHandler.SavedVariables.IsGroupFramesEnabled == false or
                                      _settingsHandler.SavedVariables.ShowUltimateInsteadHaelth == true end),
                -- Progress health color
                TGT_SettingsWindow.GetNewColorpicker(
                    GROUP_FRAMES,
                    "HealthProgrColor",
                    GetString(TGT_OPTIONS_PROGR_HEALTH_COLOR_LABEL), 
                    GetString(TGT_OPTIONS_PROGR_HEALTH_COLOR_TOOLTIP), 
                    function() return _settingsHandler.SavedVariables.IsGroupFramesEnabled == false or
                                      _settingsHandler.SavedVariables.ShowUltimateInsteadHaelth == true end),
                -- Ready health color
                TGT_SettingsWindow.GetNewColorpicker(
                    GROUP_FRAMES,
                    "HealthReadyColor",
                    GetString(TGT_OPTIONS_READY_HEALTH_COLOR_LABEL), 
                    GetString(TGT_OPTIONS_READY_HEALTH_COLOR_TOOLTIP), 
                    function() return _settingsHandler.SavedVariables.IsGroupFramesEnabled == false or
                                      _settingsHandler.SavedVariables.ShowUltimateInsteadHaelth == true end),
                -- Progress ultimate color
                TGT_SettingsWindow.GetNewColorpicker(
                    GROUP_FRAMES,
                    "UltimateProgrColor",
                    GetString(TGT_OPTIONS_PROGR_ULTI_COLOR_LABEL), 
                    GetString(TGT_OPTIONS_PROGR_ULTI_COLOR_TOOLTIP), 
                    function() return _settingsHandler.SavedVariables.IsSendingDataActive == false or 
                                      _settingsHandler.SavedVariables.IsGroupFramesEnabled == false or
                                      _settingsHandler.SavedVariables.ShowUltimateInsteadHaelth == false end),
                -- Ready ultimate color
                TGT_SettingsWindow.GetNewColorpicker(
                    GROUP_FRAMES,
                    "UltimateReadyColor",
                    GetString(TGT_OPTIONS_READY_ULTI_COLOR_LABEL), 
                    GetString(TGT_OPTIONS_READY_ULTI_COLOR_TOOLTIP), 
                    function() return _settingsHandler.SavedVariables.IsSendingDataActive == false or 
                                      _settingsHandler.SavedVariables.IsGroupFramesEnabled == false or
                                      _settingsHandler.SavedVariables.ShowUltimateInsteadHaelth == false end),
                -- Progress stamina color
                TGT_SettingsWindow.GetNewColorpicker(
                    GROUP_FRAMES,
                    "StaminaProgrColor",
                    GetString(TGT_OPTIONS_PROGR_STAM_COLOR_LABEL), 
                    GetString(TGT_OPTIONS_PROGR_STAM_COLOR_TOOLTIP), 
                    function() return _settingsHandler.SavedVariables.IsGroupFramesEnabled == false or _settingsHandler.SavedVariables.Style[GROUP_FRAMES] ~= 1 end),
                -- Ready stamina color
                TGT_SettingsWindow.GetNewColorpicker(
                    GROUP_FRAMES,
                    "StaminaReadyColor",
                    GetString(TGT_OPTIONS_READY_STAM_COLOR_LABEL), 
                    GetString(TGT_OPTIONS_READY_STAM_COLOR_TOOLTIP), 
                    function() return _settingsHandler.SavedVariables.IsGroupFramesEnabled == false or _settingsHandler.SavedVariables.Style[GROUP_FRAMES] ~= 1 end),
                -- Progress magicka color
                TGT_SettingsWindow.GetNewColorpicker(
                    GROUP_FRAMES,
                    "MagickaProgrColor",
                    GetString(TGT_OPTIONS_PROGR_MAGK_COLOR_LABEL), 
                    GetString(TGT_OPTIONS_PROGR_MAGK_COLOR_TOOLTIP), 
                    function() return _settingsHandler.SavedVariables.IsGroupFramesEnabled == false or _settingsHandler.SavedVariables.Style[GROUP_FRAMES] ~= 1 end),
                -- Ready magicka color
                TGT_SettingsWindow.GetNewColorpicker(
                    GROUP_FRAMES,
                    "MagickaReadyColor",
                    GetString(TGT_OPTIONS_READY_MAGK_COLOR_LABEL), 
                    GetString(TGT_OPTIONS_READY_MAGK_COLOR_TOOLTIP), 
                    function() return _settingsHandler.SavedVariables.IsGroupFramesEnabled == false or _settingsHandler.SavedVariables.Style[GROUP_FRAMES] ~= 1 end),
                -- Submenu header
                {   type = "header",
                    name = GetString(TGT_OPTIONS_GROUP_BUFFS_HEADER), },
                -- Ability1
                {   type        = "dropdown",
			        name        = GetString(TGT_OPTIONS_TRACKED_BUFF_1_LABEL),
			        tooltip     = GetString(TGT_OPTIONS_TRACKED_BUFF_1_TOOLTIP),
                    choices     = buffTrackerChoises,
			        getFunc = 
                       function() 
                           return buffTrackerChoises[TGT_SettingsWindow.GetBuffIndex(_settingsHandler.SavedVariables.TrackedBuffs[GROUP_FRAMES].TrackedBuff1AbilityId)]
                       end,
			        setFunc = 
                       function(value) 
                           for index, choise in ipairs(buffTrackerChoises) do
                              if (choise == value) then
                                 _settingsHandler.SetTrackedBuff1AbilityIdSettings(GROUP_FRAMES, TGT_SettingsWindow.GetBuffId(index))
                                 break
                              end
                           end
			           end,
			        default     = buffTrackerChoises[TGT_SettingsWindow.GetBuffIndex(TGT_DEFAULTS.TrackedBuffs[GROUP_FRAMES].TrackedBuff1AbilityId)],
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsGroupFramesEnabled == false or _settingsHandler.SavedVariables.Style[GROUP_FRAMES] ~= 1
                        end,
		        },
                -- Ability2
                {   type        = "dropdown",
			        name        = GetString(TGT_OPTIONS_TRACKED_BUFF_2_LABEL),
			        tooltip     = GetString(TGT_OPTIONS_TRACKED_BUFF_2_TOOLTIP),
                    choices     = buffTrackerChoises,
			        getFunc = 
                       function() 
                           return buffTrackerChoises[TGT_SettingsWindow.GetBuffIndex(_settingsHandler.SavedVariables.TrackedBuffs[GROUP_FRAMES].TrackedBuff2AbilityId)]
                       end,
			        setFunc = 
                       function(value) 
                           for index, choise in ipairs(buffTrackerChoises) do
                              if (choise == value) then
                                 _settingsHandler.SetTrackedBuff2AbilityIdSettings(GROUP_FRAMES, TGT_SettingsWindow.GetBuffId(index))
                                 break
                              end
                           end
			           end,
			        default     = buffTrackerChoises[TGT_SettingsWindow.GetBuffIndex(TGT_DEFAULTS.TrackedBuffs[GROUP_FRAMES].TrackedBuff2AbilityId)],
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsGroupFramesEnabled == false or _settingsHandler.SavedVariables.Style[GROUP_FRAMES] ~= 1
                        end,
		        },
                -- Ability3
                {   type        = "dropdown",
			        name        = GetString(TGT_OPTIONS_TRACKED_BUFF_3_LABEL),
			        tooltip     = GetString(TGT_OPTIONS_TRACKED_BUFF_3_TOOLTIP),
                    choices     = buffTrackerChoises,
			        getFunc = 
                       function() 
                           return buffTrackerChoises[TGT_SettingsWindow.GetBuffIndex(_settingsHandler.SavedVariables.TrackedBuffs[GROUP_FRAMES].TrackedBuff3AbilityId)]
                       end,
			        setFunc = 
                       function(value) 
                           for index, choise in ipairs(buffTrackerChoises) do
                              if (choise == value) then
                                 _settingsHandler.SetTrackedBuff3AbilityIdSettings(GROUP_FRAMES, TGT_SettingsWindow.GetBuffId(index))
                                 break
                              end
                           end
			           end,
			        default     = buffTrackerChoises[TGT_SettingsWindow.GetBuffIndex(TGT_DEFAULTS.TrackedBuffs[GROUP_FRAMES].TrackedBuff3AbilityId)],
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsGroupFramesEnabled == false or _settingsHandler.SavedVariables.Style[GROUP_FRAMES] ~= 1
                        end,
		        },
                -- Ability4
                {   type        = "dropdown",
			        name        = GetString(TGT_OPTIONS_TRACKED_BUFF_4_LABEL),
			        tooltip     = GetString(TGT_OPTIONS_TRACKED_BUFF_4_TOOLTIP),
                    choices     = buffTrackerChoises,
			        getFunc = 
                       function() 
                           return buffTrackerChoises[TGT_SettingsWindow.GetBuffIndex(_settingsHandler.SavedVariables.TrackedBuffs[GROUP_FRAMES].TrackedBuff4AbilityId)]
                       end,
			        setFunc = 
                       function(value) 
                           for index, choise in ipairs(buffTrackerChoises) do
                              if (choise == value) then
                                 _settingsHandler.SetTrackedBuff4AbilityIdSettings(GROUP_FRAMES, TGT_SettingsWindow.GetBuffId(index))
                                 break
                              end
                           end
			           end,
			        default     = buffTrackerChoises[TGT_SettingsWindow.GetBuffIndex(TGT_DEFAULTS.TrackedBuffs[GROUP_FRAMES].TrackedBuff4AbilityId)],
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsGroupFramesEnabled == false or _settingsHandler.SavedVariables.Style[GROUP_FRAMES] ~= 1
                        end,
		        },
                -- Submenu header
                {   type = "header",
                    name = GetString(TGT_OPTIONS_SUB_GROUPS_HEADER), },
                -- Sub Group 1 Name
                {   type        = "editbox",
			        name        = GetString(TGT_OPTIONS_SUB_GROUP_1_LABEL),
			        tooltip     = GetString(TGT_OPTIONS_SUB_GROUP_TOOLTIP),
			        getFunc = 
                       function() 
                           return _settingsHandler.SavedVariables.GroupFrameGroups.SubGroup1.Name
                       end,
			        setFunc = 
                       function(value)
                            _settingsHandler.SetSubGroupName("SubGroup1", value)
			           end,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsGroupFramesEnabled == false
                        end,
			        default     = formatChoices[TGT_DEFAULTS.GroupFrameGroups.SubGroup1.Name]
		        },
                -- Sub Group 2 Name
                {   type        = "editbox",
			        name        = GetString(TGT_OPTIONS_SUB_GROUP_2_LABEL),
			        tooltip     = GetString(TGT_OPTIONS_SUB_GROUP_TOOLTIP),
			        getFunc = 
                       function() 
                           return _settingsHandler.SavedVariables.GroupFrameGroups.SubGroup2.Name
                       end,
			        setFunc = 
                       function(value)
                            _settingsHandler.SetSubGroupName("SubGroup2", value)
			           end,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsGroupFramesEnabled == false
                        end,
			        default     = formatChoices[TGT_DEFAULTS.GroupFrameGroups.SubGroup2.Name]
		        },
                -- Sub Group 3 Name
                {   type        = "editbox",
			        name        = GetString(TGT_OPTIONS_SUB_GROUP_3_LABEL),
			        tooltip     = GetString(TGT_OPTIONS_SUB_GROUP_TOOLTIP),
			        getFunc = 
                       function() 
                           return _settingsHandler.SavedVariables.GroupFrameGroups.SubGroup3.Name
                       end,
			        setFunc = 
                       function(value)
                            _settingsHandler.SetSubGroupName("SubGroup3", value)
			           end,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsGroupFramesEnabled == false
                        end,
			        default     = formatChoices[TGT_DEFAULTS.GroupFrameGroups.SubGroup3.Name]
		        },
                -- Sub Group 4 Name
                {   type        = "editbox",
			        name        = GetString(TGT_OPTIONS_SUB_GROUP_4_LABEL),
			        tooltip     = GetString(TGT_OPTIONS_SUB_GROUP_TOOLTIP),
			        getFunc = 
                       function() 
                           return _settingsHandler.SavedVariables.GroupFrameGroups.SubGroup4.Name
                       end,
			        setFunc = 
                       function(value)
                            _settingsHandler.SetSubGroupName("SubGroup4", value)
			           end,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsGroupFramesEnabled == false
                        end,
			        default     = formatChoices[TGT_DEFAULTS.GroupFrameGroups.SubGroup4.Name]
		        },
                -- Sub Group 5 Name
                {   type        = "editbox",
			        name        = GetString(TGT_OPTIONS_SUB_GROUP_5_LABEL),
			        tooltip     = GetString(TGT_OPTIONS_SUB_GROUP_TOOLTIP),
			        getFunc = 
                       function() 
                           return _settingsHandler.SavedVariables.GroupFrameGroups.SubGroup5.Name
                       end,
			        setFunc = 
                       function(value)
                            _settingsHandler.SetSubGroupName("SubGroup5", value)
			           end,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsGroupFramesEnabled == false
                        end,
			        default     = formatChoices[TGT_DEFAULTS.GroupFrameGroups.SubGroup5.Name]
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
function TGT_GroupFramesOptions.GetOptions(options)
    local optionsData = CreateOptions()
    
    -- Add options
    for i = 1 , #optionsData do 
        table.insert(options, optionsData[i])
    end
end