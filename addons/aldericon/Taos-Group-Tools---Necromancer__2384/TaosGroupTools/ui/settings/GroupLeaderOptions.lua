--[[
	Addon: Taos Group Tools
	Author: TProg Taonnor
	Created by @Taonnor
]]--

--[[
	Local variables
]]--
local _settingsHandler = TGT_SettingsHandler

local _lamPanel = nil
local _choosenIconTexture = nil

--[[
	Table GroupLeaderOptions
]]--
TGT_GroupLeaderOptions = {}
TGT_GroupLeaderOptions.__index = TGT_GroupLeaderOptions

--[[
	===============
    PRIVATE METHODS
    ===============
]]--

--[[
	SetupLAMIcon Setups the LAM icon control "TGT_ChoosenIcon"
]]--
local function SetupLAMIcon(control)
    if (control == _lamPanel) then
        if (_choosenIconTexture == nil) then
            _choosenIconTexture = WINDOW_MANAGER:CreateControl(nil, TGT_ChoosenIcon, CT_TEXTURE)
            _choosenIconTexture:ClearAnchors()
            _choosenIconTexture:SetAnchor(RIGHT, TGT_ChoosenIcon.dropdown:GetControl(), LEFT, -48, -2)
            _choosenIconTexture:SetTexture(_settingsHandler.Icons[_settingsHandler.SavedVariables.Icon].path)
            _choosenIconTexture:SetDimensions(48, 48)
        end

		CALLBACK_MANAGER:UnregisterCallback("LAM-PanelControlsCreated", SetupLAMIcon)
    end
end

--[[
	Creates options
]]--
local function CreateOptions()
    -- Add icon choises
    local iconChoises = {}
    for key, val in pairs(_settingsHandler.Icons) do
        table.insert(iconChoises, val.name)
    end
    
    -- Add font choises
    local fontChoises = {}
    for key, val in pairs(_settingsHandler.CompassFonts) do
        table.insert(fontChoises, val.name)
    end

    local optionsData = {
        -- Submenu Group Leader Options
        {   type            = "submenu",
			name            = GetString(TGT_OPTIONS_GROUP_LEADER_HEADER),
            controls = {
                -- Submenu header
                {   type = "header",
                    name = GetString(TGT_OPTIONS_GROUP_LEADER_CROWN), },
                -- Leader icon active
                {   type        = "checkbox",
			        name        = GetString(TGT_OPTIONS_ICONS_ACTIVE_LABEL),
			        tooltip     = GetString(TGT_OPTIONS_ICONS_ACTIVE_TOOLTIP),
			        getFunc = 
                       function() 
                           return _settingsHandler.SavedVariables.IsLeaderIconActive
                       end,
			        setFunc = 
                       function(value) 
                           _settingsHandler.SetIsLeaderIconActiveSettings(value)
			           end,
			        default     = TGT_DEFAULTS.IsLeaderIconActive,
		        },
                -- Icon size
                {   type = "slider",
                    name = GetString(TGT_OPTIONS_SIZE_LABEL),
			        tooltip = GetString(TGT_OPTIONS_SIZE_TOOLTIP),
                    min = 32,
                    max = 256,
                    getFunc = 
                        function() 
                            return _settingsHandler.SavedVariables.IconSize
                        end,
                    setFunc = 
                        function(value)
                            _settingsHandler.SetIconSizeSettings(value)
                        end,
                    default = TGT_DEFAULTS.IconSize,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsLeaderIconActive == false
                       end,
                },
                -- Icon type
                {   type = "dropdown",
			        name = GetString(TGT_OPTIONS_ICONS_LABEL),
			        tooltip = GetString(TGT_OPTIONS_ICONS_TOOLTIP),
                    choices = iconChoises,
			        getFunc = 
                       function() 
                           return _settingsHandler.Icons[_settingsHandler.SavedVariables.Icon].name
                       end,
			        setFunc = 
                       function(value) 
                           for index, icon in ipairs(_settingsHandler.Icons) do
                              if (icon.name == value) then
                                 _settingsHandler.SetIconSettings(index)
                                 _choosenIconTexture:SetTexture(icon.path)
                                 break
                              end
                           end
			           end,
			        default = _settingsHandler.Icons[TGT_DEFAULTS.Icon],
                    reference = "TGT_ChoosenIcon",
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsLeaderIconActive == false
                       end,
		        },
                -- Submenu header
                {   type = "header",
                    name = GetString(TGT_OPTIONS_GROUP_LEADER_ARROW), },
                -- Leader arrow active
                {   type        = "checkbox",
			        name        = GetString(TGT_OPTIONS_ARROW_ACTIVE_LABEL),
			        tooltip     = GetString(TGT_OPTIONS_ARROW_ACTIVE_TOOLTIP),
			        getFunc = 
                       function() 
                           return _settingsHandler.SavedVariables.IsLeaderArrowActive
                       end,
			        setFunc = 
                       function(value) 
                           _settingsHandler.SetIsLeaderArrowActiveSettings(value)
			           end,
			        default     = TGT_DEFAULTS.IsLeaderArrowActive,
		        },
                -- Arrow color
                TGT_SettingsWindow.GetNewColorpicker(
                    GROUP_LEADER,
                    "ArrowColor",
                    GetString(TGT_OPTIONS_ARROW_COLOR_LABEL), 
                    GetString(TGT_OPTIONS_ARROW_COLOR_TOOLTIP), 
                    function() return _settingsHandler.SavedVariables.IsLeaderArrowActive == false end),
                -- Circle distance
                {   type        = "slider", 
                    name        = GetString(TGT_OPTIONS_CIRCLE_DISTANCE_LABEL),
                    tooltip     = GetString(TGT_OPTIONS_CIRCLE_DISTANCE_TOOLTIP),
                    min         = 0, 
                    max         = 256, 
                    step        = 1,
                    getFunc = 
                        function() 
                            return _settingsHandler.SavedVariables.CircleDistance 
                        end, 
                    setFunc = 
                        function(value) 
                            _settingsHandler.SetCircleDistanceSettings(value) 
                        end, 
                    default     = TGT_DEFAULTS.CircleDistance,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsLeaderArrowActive == false
                       end,
                },
                -- Leader arrow distance active
                {   type        = "checkbox",
			        name        = GetString(TGT_OPTIONS_ARROW_DISTANCE_LABEL),
			        tooltip     = GetString(TGT_OPTIONS_ARROW_DISTANCE_TOOLTIP),
			        getFunc = 
                       function() 
                           return _settingsHandler.SavedVariables.LeaderArrowDistance
                       end,
			        setFunc = 
                       function(value) 
                           _settingsHandler.SetLeaderArrowDistanceSettings(value)
			           end,
			        default     = TGT_DEFAULTS.LeaderArrowDistance,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsLeaderArrowActive == false
                       end,
		        },
                -- Min distance
                {   type        = "slider", 
                    name        = GetString(TGT_OPTIONS_MIN_DISTANCE_LABEL),
                    tooltip     = GetString(TGT_OPTIONS_MIN_DISTANCE_TOOLTIP),
                    min         = 0, 
                    max         = 256, 
                    step        = 1,
                    getFunc = 
                        function() 
                            return _settingsHandler.SavedVariables.MinDistance 
                        end, 
                    setFunc = 
                        function(value) 
                            _settingsHandler.SetMinDistanceSettings(value) 
                        end, 
                    default     = TGT_DEFAULTS.MinDistance,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsLeaderArrowActive == false
                       end,
                },
                -- Max distance
                {   type        = "slider", 
                    name        = GetString(TGT_OPTIONS_MAX_DISTANCE_LABEL),
                    tooltip     = GetString(TGT_OPTIONS_MAX_DISTANCE_TOOLTIP),
                    min         = 0, 
                    max         = 256, 
                    step        = 1,
                    getFunc = 
                        function() 
                            return _settingsHandler.SavedVariables.MaxDistance 
                        end, 
                    setFunc = 
                        function(value) 
                            _settingsHandler.SetMaxDistanceSettings(value) 
                        end, 
                    default     = TGT_DEFAULTS.MaxDistance,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsLeaderArrowActive == false
                       end,
                },
                -- Submenu header
                {   type = "header",
                    name = GetString(TGT_OPTIONS_GROUP_LEADER_COMPASS), },
                -- Leader compass active
                {   type        = "checkbox",
			        name        = GetString(TGT_OPTIONS_COMPASS_ACTIVE_LABEL),
			        tooltip     = GetString(TGT_OPTIONS_COMPASS_ACTIVE_TOOLTIP),
			        getFunc = 
                       function() 
                           return _settingsHandler.SavedVariables.IsCustomizedCompassActive
                       end,
			        setFunc = 
                       function(value) 
                           _settingsHandler.SetIsCustomizedCompassActiveSettings(value)
			           end,
			        default     = TGT_DEFAULTS.IsCustomizedCompassActive,
		        },
                -- Default compass hidden
                {   type        = "checkbox",
			        name        = GetString(TGT_OPTIONS_ZOS_COMPASS_ACTIVE_LABEL),
			        tooltip     = GetString(TGT_OPTIONS_ZOS_COMPASS_ACTIVE_TOOLTIP),
			        getFunc = 
                       function() 
                           return _settingsHandler.SavedVariables.HideStandardCompass
                       end,
			        setFunc = 
                       function(value) 
                           _settingsHandler.SetHideStandardCompassSettings(value)
			           end,
			        default     = TGT_DEFAULTS.HideStandardCompass,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsCustomizedCompassActive == false
                       end,
		        },
                -- Compass color
                TGT_SettingsWindow.GetNewColorpicker(
                    GROUP_LEADER,
                    "CompassColor",
                    GetString(TGT_OPTIONS_COMPASS_COLOR_LABEL), 
                    GetString(TGT_OPTIONS_COMPASS_COLOR_TOOLTIP), 
                    function() return _settingsHandler.SavedVariables.IsCustomizedCompassActive == false end),
                -- Radius
                {   type        = "slider", 
                    name        = GetString(TGT_OPTIONS_COMPASS_RADIUS_LABEL),
                    tooltip     = GetString(TGT_OPTIONS_COMPASS_RADIUS_TOOLTIP),
                    min         = 64, 
                    max         = 512, 
                    step        = 1,
                    getFunc = 
                        function() 
                            return _settingsHandler.SavedVariables.CompassRadius 
                        end, 
                    setFunc = 
                        function(value) 
                            _settingsHandler.SetCompassRadiusSettings(value) 
                        end, 
                    default     = TGT_DEFAULTS.CompassRadius,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsCustomizedCompassActive == false
                       end,
                },
                -- Font
                {   type = "dropdown",
			        name = GetString(TGT_OPTIONS_COMPASS_FONTS_LABEL),
			        tooltip = GetString(TGT_OPTIONS_COMPASS_FONTS_TOOLTIP),
                    choices = fontChoises,
			        getFunc = 
                       function() 
                           return _settingsHandler.CompassFonts[_settingsHandler.SavedVariables.CompassFont].name
                       end,
			        setFunc = 
                       function(value) 
                           for index, icon in ipairs(_settingsHandler.CompassFonts) do
                              if (icon.name == value) then
                                 _settingsHandler.SetCompassFontSettings(index)
                                 break
                              end
                           end
			           end,
			        default = _settingsHandler.CompassFonts[TGT_DEFAULTS.CompassFont],
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsCustomizedCompassActive == false
                       end,
		        },
                -- Font Size
                {   type        = "slider", 
                    name        = GetString(TGT_OPTIONS_COMPASS_FONT_SIZE_LABEL),
                    tooltip     = GetString(TGT_OPTIONS_COMPASS_FONT_SIZE_TOOLTIP),
                    min         = 12, 
                    max         = 32, 
                    step        = 1,
                    getFunc = 
                        function() 
                            return _settingsHandler.SavedVariables.CompassFontSize 
                        end, 
                    setFunc = 
                        function(value) 
                            _settingsHandler.SetCompassFontSizeSettings(value)
                        end, 
                    default     = TGT_DEFAULTS.CompassFontSize,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsCustomizedCompassActive == false
                       end,
                },
                -- Flat compass
                {   type        = "checkbox",
			        name        = GetString(TGT_OPTIONS_COMPASS_FLAT_LABEL),
			        tooltip     = GetString(TGT_OPTIONS_COMPASS_FLAT_TOOLTIP),
			        getFunc = 
                       function() 
                           return _settingsHandler.SavedVariables.FlatCompass
                       end,
			        setFunc = 
                       function(value) 
                           _settingsHandler.SetCompassFlatCompassSettings(value)
			           end,
			        default     = TGT_DEFAULTS.FlatCompass,
                    disabled = 
                        function() 
                           return _settingsHandler.SavedVariables.IsCustomizedCompassActive == false
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
	SetLamPanel sets lamPanel to create icon callback
]]--
function TGT_GroupLeaderOptions.SetLamPanel(lamPanel)
    _lamPanel = lamPanel
end

--[[
	GetOptions creates settings and returns
]]--
function TGT_GroupLeaderOptions.GetOptions(options, lamPanel)
    local optionsData = CreateOptions()

    -- Register to callback for creating preview icon
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", SetupLAMIcon)
        
    -- Add options
    for i = 1 , #optionsData do 
        table.insert(options, optionsData[i])
    end
end