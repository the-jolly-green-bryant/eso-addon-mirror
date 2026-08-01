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
	Table GroupUltimateOptions
]]--
TGT_GroupUltimateOptions = {}
TGT_GroupUltimateOptions.__index = TGT_GroupUltimateOptions

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
        [1] = GetString(TGT_OPTIONS_STYLE_SIMPLE),
        [2] = GetString(TGT_OPTIONS_STYLE_SWIM),
        [3] = GetString(TGT_OPTIONS_STYLE_SHORT_SWIM),
    }

    local buffTrackerChoises = TGT_SettingsWindow.GetBuffTrackerChoises()
    
	local optionsData = {
        -- Submenu Group Ultimate Options
        {   type            = "submenu",
			name            = GetString(TGT_OPTIONS_GROUP_ULTIMATE_HEADER),
            controls = {
                -- Enable/Disable Group Ultimate
                {   type = "checkbox",
			        name = GetString(TGT_OPTIONS_GROUP_ULTIMATE_LABEL),
			        tooltip = GetString(TGT_OPTIONS_GROUP_ULTIMATE_TOOLTIP),
			        getFunc = 
                       function() 
                           return _settingsHandler.SavedVariables.IsGroupUltimateEnabled
                       end,
			        setFunc = 
                       function(value) 
                           _settingsHandler.SetIsGroupUltimateEnabledSettings(value)
			           end,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsSendingDataActive == false
                       end,
			        default = TGT_DEFAULTS.IsGroupUltimateEnabled
		        },
                -- Only AvA visible
                {   type        = "checkbox",
			        name        = GetString(TGT_OPTIONS_ONLY_AVA_LABEL),
			        tooltip     = GetString(TGT_OPTIONS_ONLY_AVA_TOOLTIP),
			        getFunc = 
                       function() 
                           return _settingsHandler.SavedVariables.OnlyAva[GROUP_ULTIMATE]
                       end,
			        setFunc = 
                       function(value) 
                           _settingsHandler.SetOnlyAvaSettings(GROUP_ULTIMATE, value)
			           end,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsSendingDataActive == false or _settingsHandler.SavedVariables.IsGroupUltimateEnabled == false
                       end,
			        default     = TGT_DEFAULTS.OnlyAva[GROUP_ULTIMATE]
		        },
                -- Sorting active
                {   type        = "checkbox",
			        name        = GetString(TGT_OPTIONS_USE_SORTING_LABEL),
			        tooltip     = GetString(TGT_OPTIONS_USE_SORTING_TOOLTIP),
			        getFunc = 
                       function() 
                           return _settingsHandler.SavedVariables.IsSortingActive
                       end,
			        setFunc = 
                       function(value) 
                           _settingsHandler.SetIsSortingActiveSettings(value)
			           end,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsSendingDataActive == false or _settingsHandler.SavedVariables.IsGroupUltimateEnabled == false
                       end,
			        default     = TGT_DEFAULTS.IsSortingActive
		        },
                -- InCombat active
                {   type        = "checkbox",
			        name        = GetString(TGT_OPTIONS_USE_INCOMBAT_LABEL),
			        tooltip     = GetString(TGT_OPTIONS_USE_INCOMBAT_TOOLTIP),
			        getFunc = 
                       function() 
                           return _settingsHandler.SavedVariables.CombatActive[GROUP_ULTIMATE]
                       end,
			        setFunc = 
                       function(value) 
                           _settingsHandler.SetCombatActiveSettings(GROUP_ULTIMATE, value)
			           end,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsSendingDataActive == false or _settingsHandler.SavedVariables.IsGroupUltimateEnabled == false
                       end,
			        default     = TGT_DEFAULTS.CombatActive[GROUP_ULTIMATE]
		        },
                -- Style
                {   type        = "dropdown",
			        name        = GetString(TGT_OPTIONS_STYLE_LABEL),
			        tooltip     = GetString(TGT_OPTIONS_STYLE_TOOLTIP),
                    choices     = styleChoices,
			        getFunc = 
                       function() 
                           return styleChoices[_settingsHandler.SavedVariables.Style[GROUP_ULTIMATE]]
                       end,
			        setFunc = 
                       function(value) 
                           for index, name in ipairs(styleChoices) do
                              if (name == value) then
                                 _settingsHandler.SetStyleSettings(GROUP_ULTIMATE, index)
                                 break
                              end
                           end
			           end,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsSendingDataActive == false or _settingsHandler.SavedVariables.IsGroupUltimateEnabled == false
                       end,
			        default     = styleChoices[TGT_DEFAULTS.Style[GROUP_ULTIMATE]]
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
                            return _settingsHandler.SavedVariables.VisibleOffset[GROUP_ULTIMATE]
                        end, 
                    setFunc = 
                        function(value) 
                            _settingsHandler.SetVisibleOffsetSettings(GROUP_ULTIMATE, value) 
                        end, 
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsSendingDataActive == false or _settingsHandler.SavedVariables.IsGroupUltimateEnabled == false
                       end,
                    default     = TGT_DEFAULTS.VisibleOffset[GROUP_ULTIMATE],
                },
                -- Visible Swimlanes
                {   type        = "slider", 
                    name        = GetString(TGT_OPTIONS_SWIMLANES_LABEL),
                    tooltip     = GetString(TGT_OPTIONS_SWIMLANES_TOOLTIP),
                    min         = 1, 
                    max         = 12, 
                    step        = 1, 
                    getFunc = 
                        function() 
                            return _settingsHandler.SavedVariables.Swimlanes 
                        end, 
                    setFunc = 
                        function(value) 
                            _settingsHandler.SetSwimlanesSettings(value) 
                        end, 
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsSendingDataActive == false or _settingsHandler.SavedVariables.IsGroupUltimateEnabled == false
                       end,
                    default     = TGT_DEFAULTS.Swimlanes,
                },
                -- Scaling Swimlanes
                {   type        = "slider", 
                    name        = GetString(TGT_OPTIONS_SCALE_LABEL),
                    tooltip     = GetString(TGT_OPTIONS_SWIMLANE_SCALE_TOOLTIP),
                    min         = 0.1, 
                    max         = 2.0, 
                    step        = 0.1, 
                    decimals    = 1,
                    getFunc = 
                        function() 
                            return _settingsHandler.SavedVariables.Scale[GROUP_ULTIMATE]
                        end, 
                    setFunc = 
                        function(value) 
                            _settingsHandler.SetScaleSettings(GROUP_ULTIMATE, value) 
                        end, 
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsSendingDataActive == false or _settingsHandler.SavedVariables.IsGroupUltimateEnabled == false
                       end,
                    default     = TGT_DEFAULTS.Scale[GROUP_ULTIMATE],
                },
                -- Progress ultimate color
                TGT_SettingsWindow.GetNewColorpicker(
                    GROUP_ULTIMATE,
                    "UltimateProgrColor",
                    GetString(TGT_OPTIONS_PROGR_ULTI_COLOR_LABEL), 
                    GetString(TGT_OPTIONS_PROGR_ULTI_COLOR_TOOLTIP), 
                    function() return _settingsHandler.SavedVariables.IsSendingDataActive == false or _settingsHandler.SavedVariables.IsGroupUltimateEnabled == false end),
                -- Ready ultimate color
                TGT_SettingsWindow.GetNewColorpicker(
                    GROUP_ULTIMATE,
                    "UltimateReadyColor",
                    GetString(TGT_OPTIONS_READY_ULTI_COLOR_LABEL), 
                    GetString(TGT_OPTIONS_READY_ULTI_COLOR_TOOLTIP), 
                    function() return _settingsHandler.SavedVariables.IsSendingDataActive == false or _settingsHandler.SavedVariables.IsGroupUltimateEnabled == false end),
                -- Submenu header
                {   type = "header",
                    name = GetString(TGT_OPTIONS_GROUP_RESOURCES_HEADER), },
                -- Enable/Disable Group Resources
                {   type = "checkbox",
			        name = GetString(TGT_OPTIONS_GROUP_RESOURCES_LABEL),
			        tooltip = GetString(TGT_OPTIONS_GROUP_RESOURCES_TOOLTIP),
			        getFunc = 
                        function() 
                            return _settingsHandler.SavedVariables.IsGroupResourcesEnabled
                        end,
			        setFunc = 
                        function(value) 
                            _settingsHandler.SetIsGroupResourcesEnabledSettings(value)
			            end,
			        default = TGT_DEFAULTS.IsGroupResourcesEnabled,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsSendingDataActive == false or _settingsHandler.SavedVariables.IsGroupUltimateEnabled == false
                       end,
		        },
                -- Progress stamina color
                TGT_SettingsWindow.GetNewColorpicker(
                    GROUP_ULTIMATE,
                    "StaminaProgrColor",
                    GetString(TGT_OPTIONS_PROGR_STAM_COLOR_LABEL), 
                    GetString(TGT_OPTIONS_PROGR_STAM_COLOR_TOOLTIP), 
                    function() return _settingsHandler.SavedVariables.IsSendingDataActive == false or _settingsHandler.SavedVariables.IsGroupUltimateEnabled == false end),
                -- Ready stamina color
                TGT_SettingsWindow.GetNewColorpicker(
                    GROUP_ULTIMATE,
                    "StaminaReadyColor",
                    GetString(TGT_OPTIONS_READY_STAM_COLOR_LABEL), 
                    GetString(TGT_OPTIONS_READY_STAM_COLOR_TOOLTIP), 
                    function() return _settingsHandler.SavedVariables.IsSendingDataActive == false or _settingsHandler.SavedVariables.IsGroupUltimateEnabled == false end),
                -- Progress magicka color
                TGT_SettingsWindow.GetNewColorpicker(
                    GROUP_ULTIMATE,
                    "MagickaProgrColor",
                    GetString(TGT_OPTIONS_PROGR_MAGK_COLOR_LABEL), 
                    GetString(TGT_OPTIONS_PROGR_MAGK_COLOR_TOOLTIP), 
                    function() return _settingsHandler.SavedVariables.IsSendingDataActive == false or _settingsHandler.SavedVariables.IsGroupUltimateEnabled == false end),
                -- Ready magicka color
                TGT_SettingsWindow.GetNewColorpicker(
                    GROUP_ULTIMATE,
                    "MagickaReadyColor",
                    GetString(TGT_OPTIONS_READY_MAGK_COLOR_LABEL), 
                    GetString(TGT_OPTIONS_READY_MAGK_COLOR_TOOLTIP), 
                    function() return _settingsHandler.SavedVariables.IsSendingDataActive == false or _settingsHandler.SavedVariables.IsGroupUltimateEnabled == false end),
                -- Submenu header
                {   type = "header",
                    name = GetString(TGT_OPTIONS_GROUP_BUFFS_HEADER), },
                -- Enable/Disable Group Buffs
                {   type = "checkbox",
			        name = GetString(TGT_OPTIONS_GROUP_BUFFS_LABEL),
			        tooltip = GetString(TGT_OPTIONS_GROUP_BUFFS_TOOLTIP),
			        getFunc = 
                       function() 
                           return _settingsHandler.SavedVariables.IsGroupBuffsEnabled
                       end,
			        setFunc = 
                       function(value) 
                           _settingsHandler.SetIsGroupBuffsEnabledSettings(value)
			           end,
			        default = TGT_DEFAULTS.IsGroupBuffsEnabled,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsSendingDataActive == false or _settingsHandler.SavedVariables.IsGroupUltimateEnabled == false
                       end,
                    warning = GetString(TGT_OPTIONS_GROUP_BUFFS_WARNING)
		        },
                -- Ability1
                {   type        = "dropdown",
			        name        = GetString(TGT_OPTIONS_TRACKED_BUFF_1_LABEL),
			        tooltip     = GetString(TGT_OPTIONS_TRACKED_BUFF_1_TOOLTIP),
                    choices     = buffTrackerChoises,
			        getFunc = 
                       function() 
                           return buffTrackerChoises[TGT_SettingsWindow.GetBuffIndex(_settingsHandler.SavedVariables.TrackedBuffs[GROUP_ULTIMATE].TrackedBuff1AbilityId)]
                       end,
			        setFunc = 
                       function(value) 
                           for index, choise in ipairs(buffTrackerChoises) do
                              if (choise == value) then
                                 _settingsHandler.SetTrackedBuff1AbilityIdSettings(GROUP_ULTIMATE, TGT_SettingsWindow.GetBuffId(index))
                                 break
                              end
                           end
			           end,
			        default     = buffTrackerChoises[TGT_SettingsWindow.GetBuffIndex(TGT_DEFAULTS.TrackedBuffs[GROUP_ULTIMATE].TrackedBuff1AbilityId)],
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsSendingDataActive == false or _settingsHandler.SavedVariables.IsGroupUltimateEnabled == false
                       end,
		        },
                -- Ability2
                {   type        = "dropdown",
			        name        = GetString(TGT_OPTIONS_TRACKED_BUFF_2_LABEL),
			        tooltip     = GetString(TGT_OPTIONS_TRACKED_BUFF_2_TOOLTIP),
                    choices     = buffTrackerChoises,
			        getFunc = 
                       function() 
                           return buffTrackerChoises[TGT_SettingsWindow.GetBuffIndex(_settingsHandler.SavedVariables.TrackedBuffs[GROUP_ULTIMATE].TrackedBuff2AbilityId)]
                       end,
			        setFunc = 
                       function(value) 
                           for index, choise in ipairs(buffTrackerChoises) do
                              if (choise == value) then
                                 _settingsHandler.SetTrackedBuff2AbilityIdSettings(GROUP_ULTIMATE, TGT_SettingsWindow.GetBuffId(index))
                                 break
                              end
                           end
			           end,
			        default     = buffTrackerChoises[TGT_SettingsWindow.GetBuffIndex(TGT_DEFAULTS.TrackedBuffs[GROUP_ULTIMATE].TrackedBuff2AbilityId)],
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsSendingDataActive == false or _settingsHandler.SavedVariables.IsGroupUltimateEnabled == false
                       end,
		        },
                -- Ability3
                {   type        = "dropdown",
			        name        = GetString(TGT_OPTIONS_TRACKED_BUFF_3_LABEL),
			        tooltip     = GetString(TGT_OPTIONS_TRACKED_BUFF_3_TOOLTIP),
                    choices     = buffTrackerChoises,
			        getFunc = 
                       function() 
                           return buffTrackerChoises[TGT_SettingsWindow.GetBuffIndex(_settingsHandler.SavedVariables.TrackedBuffs[GROUP_ULTIMATE].TrackedBuff3AbilityId)]
                       end,
			        setFunc = 
                       function(value) 
                           for index, choise in ipairs(buffTrackerChoises) do
                              if (choise == value) then
                                 _settingsHandler.SetTrackedBuff3AbilityIdSettings(GROUP_ULTIMATE, TGT_SettingsWindow.GetBuffId(index))
                                 break
                              end
                           end
			           end,
			        default     = buffTrackerChoises[TGT_SettingsWindow.GetBuffIndex(TGT_DEFAULTS.TrackedBuffs[GROUP_ULTIMATE].TrackedBuff3AbilityId)],
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsSendingDataActive == false or _settingsHandler.SavedVariables.IsGroupUltimateEnabled == false
                       end,
		        },
                -- Ability4
                {   type        = "dropdown",
			        name        = GetString(TGT_OPTIONS_TRACKED_BUFF_4_LABEL),
			        tooltip     = GetString(TGT_OPTIONS_TRACKED_BUFF_4_TOOLTIP),
                    choices     = buffTrackerChoises,
			        getFunc = 
                       function() 
                           return buffTrackerChoises[TGT_SettingsWindow.GetBuffIndex(_settingsHandler.SavedVariables.TrackedBuffs[GROUP_ULTIMATE].TrackedBuff4AbilityId)]
                       end,
			        setFunc = 
                       function(value) 
                           for index, choise in ipairs(buffTrackerChoises) do
                              if (choise == value) then
                                 _settingsHandler.SetTrackedBuff4AbilityIdSettings(GROUP_ULTIMATE, TGT_SettingsWindow.GetBuffId(index))
                                 break
                              end
                           end
			           end,
			        default     = buffTrackerChoises[TGT_SettingsWindow.GetBuffIndex(TGT_DEFAULTS.TrackedBuffs[GROUP_ULTIMATE].TrackedBuff4AbilityId)],
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsSendingDataActive == false or _settingsHandler.SavedVariables.IsGroupUltimateEnabled == false
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
function TGT_GroupUltimateOptions.GetOptions(options)
    local optionsData = CreateOptions()
    
    -- Add options
    for i = 1 , #optionsData do 
        table.insert(options, optionsData[i])
    end
end