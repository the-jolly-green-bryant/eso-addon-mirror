-- Libraries -------------------------------------------------------------------
local LAM = LibAddonMenu2

-- Variables -------------------------------------------------------------------
Scholar_Settings = {}

-- Settings menu ---------------------------------------------------------------
function Scholar_Settings:CreateMenu(parent)
	-- Register panel
	local panelData = {
		type                = "panel",
		name                = GetString(SCHOLAR_TITLE),
		displayName         = GetString(SCHOLAR_TITLE),
		author              = "Widgit Labs",
		version             = SCHOLAR_VERSION,
		slashCommand        = "/scholar_settings",
		registerForRefresh  = true,
		registerForDefaults = true,
		website             = SCHOLAR_WEBSITE
	}
	LAM:RegisterAddonPanel("Scholar_Settings", panelData)

	-- Load ZO_NORMAL_TEXT to set defaults
	local norm = ZO_NORMAL_TEXT

	-- Define options
	local optionsData = {
		{
			type     = "submenu",
			name     = GetString(SCHOLAR_GENERAL_TITLE),
			controls = {
				{
					type    = "checkbox",
					name    = GetString(SCHOLAR_ACCOUNT_WIDE),
					tooltip = GetString(SCHOLAR_ACCOUNT_WIDE_TIP),
					default = true,
					getFunc = function() return parent.savedAccount.accountWide end,
					setFunc = function(bValue)
						parent.savedAccount.accountWide = bValue
						if not bValue then
							local sDisplayName = GetDisplayName()
							local sUnitName    = GetUnitName("player")
						end
						parent:SwapSavedVars(bValue)
					end
				},
				{
					type = "header",
					name = GetString(SCHOLAR_MODULES_HEADER)
				},
				{
					type = "description",
					text = GetString(SCHOLAR_MODULES_DESCRIPTION)
				},
				{
					type    = "checkbox",
					name    = GetString(SCHOLAR_ENABLE_TIMERS),
					tooltip = GetString(SCHOLAR_ENABEL_TIMERS_TIP),
					default = true,
					getFunc = function() return parent.savedVariables.enable.timers end,
					setFunc = function(enable) parent.savedVariables.enable.timers = enable end
				},
				{
					type    = "checkbox",
					name    = GetString(SCHOLAR_ENABLE_STABLE_TIMER),
					tooltip = GetString(SCHOLAR_ENABLE_STABLE_TIMER_TIP),
					default = false,
					getFunc = function() return parent.savedVariables.enable.stableTimer end,
					setFunc = function(enable) parent.savedVariables.enable.stableTimer = enable end
				},
				{
					type    = "button",
					name    = GetString(SCHOLAR_RELOAD_UI),
					tooltip = GetString(SCHOLAR_RELOAD_UI_TIP),
					func    = function() ReloadUI("ingame") end
				}
			}
		},
		{
			type     = "submenu",
			name     = GetString(SCHOLAR_TIMERS_TITLE),
			controls = {
				{
					type    = "checkbox",
					name    = GetString(SCHOLAR_TIMERS_HIDE_IN_COMBAT),
					tooltip = GetString(SCHOLAR_TIMERS_HIDE_IN_COMBAT_TIP),
					default = true,
					getFunc = function() return parent.savedVariables.timers.hideInCombat end,
					setFunc = function(hideInCombat)
						parent.savedVariables.timers.hideInCombat = hideInCombat
						Scholar_Timers:ApplySettings()
					end
				},
				{
					type    = "checkbox",
					name    = GetString(SCHOLAR_TIMERS_AUTOCLEAR),
					tooltip = GetString(SCHOLAR_TIMERS_AUTOCLEAR_TIP),
					default = false,
					getFunc = function() return parent.savedVariables.timers.autoClear end,
					setFunc = function(autoClear)
						parent.savedVariables.timers.autoClear = autoClear
						Scholar_Timers:ApplySettings()
					end
				},
				{
					type          = "dropdown",
					name          = GetString(SCHOLAR_TIMERS_NOTIFICATIONS),
					tooltip       = GetString(SCHOLAR_TIMERS_NOTIFICATIONS_TIP),
					choices       = { GetString(SCHOLAR_OPTION_NONE), GetString(SCHOLAR_OPTION_CHAT),
						GetString(SCHOLAR_OPTION_ANNOUNCEMENT) },
					choicesValues = { "none", "chat", "announcement" },
					default       = "none",
					getFunc       = function() return parent.savedVariables.timers.notifications end,
					setFunc       = function(notifications) parent.savedVariables.timers.notifications = notifications end
				},
				{
					type    = "dropdown",
					name    = GetString(SCHOLAR_TIMERS_NOTIFICATION_SOUND),
					tooltip = GetString(SCHOLAR_TIMERS_NOTIFICATION_SOUND_TIP),
					choices = Scholar_Sounds:GetSoundChoices(parent),
					default = "Smithing_Finish_Research",
					getFunc = function() return parent.savedVariables.timers.notificationSound end,
					setFunc = function(sound) parent.savedVariables.timers.notificationSound = sound end
				},
				{
					type    = "button",
					name    = GetString(SCHOLAR_TIMERS_NOTIFICATION_SOUND_TEST),
					tooltip = GetString(SCHOLAR_TIMERS_NOTIFICATION_SOUND_TEST_TIP),
					func    = function() PlaySound(parent.savedVariables.timers.notificationSound) end
				},
				{
					type = "header",
					name = GetString(SCHOLAR_TIMERS_LABEL_HEADER)
				},
				{
					type    = "checkbox",
					name    = GetString(SCHOLAR_TIMERS_USE_ABBR),
					tooltip = GetString(SCHOLAR_TIMERS_USE_ABBR_TIP),
					default = false,
					getFunc = function() return parent.savedVariables.timers.useAbbr end,
					setFunc = function(useAbbr)
						parent.savedVariables.timers.useAbbr = useAbbr
						Scholar_Timers:ApplySettings()
					end
				},
				{
					type          = "dropdown",
					name          = GetString(SCHOLAR_TIMERS_TYPE),
					tooltip       = GetString(SCHOLAR_TIMERS_TYPE_TIP),
					choices       = { GetString(SCHOLAR_TIMERS_TYPE_TIME),
						GetString(SCHOLAR_TIMERS_TYPE_PERCENT_REMAINING), GetString(SCHOLAR_TIMERS_TYPE_PERCENT_COMPLETE) },
					choicesValues = { "time_remaining", "percent_remaining", "percent_complete" },
					default       = "time_remaining",
					getFunc       = function() return parent.savedVariables.timers.type end,
					setFunc       = function(type)
						parent.savedVariables.timers.type = type
						Scholar_Timers:ApplySettings()
					end
				},
				{
					type          = "dropdown",
					name          = GetString(SCHOLAR_TIMERS_LABEL_FONT),
					tooltip       = GetString(SCHOLAR_TIMERS_LABEL_FONT_TIP),
					choices       = Scholar_Fonts:GetFontChoices(true),
					choicesValues = Scholar_Fonts:GetFontChoices(),
					default       = "BOLD_FONT",
					getFunc       = function() return parent.savedVariables.timers.labelFont end,
					setFunc       = function(labelFont)
						parent.savedVariables.timers.labelFont = labelFont
						Scholar_Timers:ApplySettings()
					end
				},
				{
					type          = "dropdown",
					name          = GetString(SCHOLAR_TIMERS_LABEL_OUTLINE),
					tooltip       = GetString(SCHOLAR_TIMERS_LABEL_OUTLINE_TIP),
					choices       = Scholar_Fonts:GetOutlineChoices(true),
					choicesValues = Scholar_Fonts:GetOutlineChoices(),
					default       = "soft-shadow-thick",
					getFunc       = function() return parent.savedVariables.timers.labelOutline end,
					setFunc       = function(labelOutline)
						parent.savedVariables.timers.labelOutline = labelOutline
						Scholar_Timers:ApplySettings()
					end
				},
				{
					type     = "slider",
					name     = GetString(SCHOLAR_TIMERS_LABEL_SIZE),
					tooltip  = GetString(SCHOLAR_TIMERS_LABEL_SIZE_TIP),
					default  = 16,
					min      = 10,
					max      = 24,
					step     = 1,
					decimals = 0,
					getFunc  = function() return parent.savedVariables.timers.labelSize end,
					setFunc  = function(labelSize)
						parent.savedVariables.timers.labelSize = labelSize
						Scholar_Timers:ApplySettings()
					end
				},
				{
					type    = "colorpicker",
					name    = GetString(SCHOLAR_TIMERS_LABEL_COLOR),
					tooltip = GetString(SCHOLAR_TIMERS_LABEL_COLOR_TIP),
					default = { r = norm.r, g = norm.g, b = norm.b, a = norm.a },
					getFunc = function() return unpack(parent.savedVariables.timers.labelColor) end,
					setFunc = function(r, g, b, a)
						parent.savedVariables.timers.labelColor = { r, g, b, a }
						Scholar_Timers:ApplySettings()
					end
				},
				{
					type          = "dropdown",
					name          = GetString(SCHOLAR_TIMERS_TIME_FONT),
					tooltip       = GetString(SCHOLAR_TIMERS_TIME_FONT_TIP),
					choices       = Scholar_Fonts:GetFontChoices(true),
					choicesValues = Scholar_Fonts:GetFontChoices(),
					default       = "MEDIUM_FONT",
					getFunc       = function() return parent.savedVariables.timers.timeFont end,
					setFunc       = function(timeFont)
						parent.savedVariables.timers.timeFont = timeFont
						Scholar_Timers:ApplySettings()
					end
				},
				{
					type          = "dropdown",
					name          = GetString(SCHOLAR_TIMERS_TIME_OUTLINE),
					tooltip       = GetString(SCHOLAR_TIMERS_TIME_OUTLINE_TIP),
					choices       = Scholar_Fonts:GetOutlineChoices(true),
					choicesValues = Scholar_Fonts:GetOutlineChoices(),
					default       = "thick-outline",
					getFunc       = function() return parent.savedVariables.timers.timeOutline end,
					setFunc       = function(timeOutline)
						parent.savedVariables.timers.timeOutline = timeOutline
						Scholar_Timers:ApplySettings()
					end
				},
				{
					type     = "slider",
					name     = GetString(SCHOLAR_TIMERS_TIME_SIZE),
					tooltip  = GetString(SCHOLAR_TIMERS_TIME_SIZE_TIP),
					default  = 14,
					min      = 10,
					max      = 24,
					step     = 1,
					decimals = 0,
					getFunc  = function() return parent.savedVariables.timers.timeSize end,
					setFunc  = function(timeSize)
						parent.savedVariables.timers.timeSize = timeSize
						Scholar_Timers:ApplySettings()
					end
				},
				{
					type    = "colorpicker",
					name    = GetString(SCHOLAR_TIMERS_TIME_COLOR),
					tooltip = GetString(SCHOLAR_TIMERS_TIME_COLOR_TIP),
					default = { r = 1, g = 1, b = 1, a = 1 },
					getFunc = function() return unpack(parent.savedVariables.timers.timeColor) end,
					setFunc = function(r, g, b, a)
						parent.savedVariables.timers.timeColor = { r, g, b, a }
						Scholar_Timers:ApplySettings()
					end
				},
				{
					type          = "dropdown",
					name          = GetString(SCHOLAR_TIMERS_LABEL_ALIGNMENT),
					tooltip       = GetString(SCHOLAR_TIMERS_LABEL_ALIGNMENT_TIP),
					choices       = { GetString(SCHOLAR_OPTION_RIGHT), GetString(SCHOLAR_OPTION_LEFT) },
					choicesValues = { "right", "left" },
					default       = "right",
					getFunc       = function() return parent.savedVariables.timers.labelAlignment end,
					setFunc       = function(labelAlignment)
						parent.savedVariables.timers.labelAlignment = labelAlignment
						Scholar_Timers:RearrangeBars()
					end
				},
				{
					type = "header",
					name = GetString(SCHOLAR_TIMERS_BAR_COLORS_HEADER)
				},
				{
					type    = "colorpicker",
					name    = GetString(SCHOLAR_TIMERS_CL_BACKGROUND_COLOR),
					tooltip = GetString(SCHOLAR_TIMERS_CL_BACKGROUND_COLOR_TIP),
					default = { r = 0.529, g = 1, b = 1, a = 1 },
					getFunc = function() return unpack(parent.savedVariables.timers.clBackgroundColor) end,
					setFunc = function(r, g, b, a)
						parent.savedVariables.timers.clBackgroundColor = { r, g, b, a }
						Scholar_Timers:ApplySettings()
					end
				},
				{
					type    = "colorpicker",
					name    = GetString(SCHOLAR_TIMERS_CL_GLOSS_COLOR),
					tooltip = GetString(SCHOLAR_TIMERS_CL_GLOSS_COLOR_TIP),
					default = { r = 1, g = 1, b = 1, a = 1 },
					getFunc = function() return unpack(parent.savedVariables.timers.clGlossColor) end,
					setFunc = function(r, g, b, a)
						parent.savedVariables.timers.clGlossColor = { r, g, b, a }
						Scholar_Timers:ApplySettings()
					end
				},
				{
					type    = "colorpicker",
					name    = GetString(SCHOLAR_TIMERS_SM_BACKGROUND_COLOR),
					tooltip = GetString(SCHOLAR_TIMERS_SM_BACKGROUND_COLOR_TIP),
					default = { r = 0.529, g = 1, b = 1, a = 1 },
					getFunc = function() return unpack(parent.savedVariables.timers.smBackgroundColor) end,
					setFunc = function(r, g, b, a)
						parent.savedVariables.timers.smBackgroundColor = { r, g, b, a }
						Scholar_Timers:ApplySettings()
					end
				},
				{
					type    = "colorpicker",
					name    = GetString(SCHOLAR_TIMERS_SM_GLOSS_COLOR),
					tooltip = GetString(SCHOLAR_TIMERS_SM_GLOSS_COLOR_TIP),
					default = { r = 1, g = 1, b = 1, a = 1 },
					getFunc = function() return unpack(parent.savedVariables.timers.smGlossColor) end,
					setFunc = function(r, g, b, a)
						parent.savedVariables.timers.smGlossColor = { r, g, b, a }
						Scholar_Timers:ApplySettings()
					end
				},
				{
					type    = "colorpicker",
					name    = GetString(SCHOLAR_TIMERS_WW_BACKGROUND_COLOR),
					tooltip = GetString(SCHOLAR_TIMERS_WW_BACKGROUND_COLOR_TIP),
					default = { r = 0.529, g = 1, b = 1, a = 1 },
					getFunc = function() return unpack(parent.savedVariables.timers.wwBackgroundColor) end,
					setFunc = function(r, g, b, a)
						parent.savedVariables.timers.wwBackgroundColor = { r, g, b, a }
						Scholar_Timers:ApplySettings()
					end
				},
				{
					type    = "colorpicker",
					name    = GetString(SCHOLAR_TIMERS_WW_GLOSS_COLOR),
					tooltip = GetString(SCHOLAR_TIMERS_WW_GLOSS_COLOR_TIP),
					default = { r = 1, g = 1, b = 1, a = 1 },
					getFunc = function() return unpack(parent.savedVariables.timers.wwGlossColor) end,
					setFunc = function(r, g, b, a)
						parent.savedVariables.timers.wwGlossColor = { r, g, b, a }
						Scholar_Timers:ApplySettings()
					end
				},
				{
					type    = "colorpicker",
					name    = GetString(SCHOLAR_TIMERS_JC_BACKGROUND_COLOR),
					tooltip = GetString(SCHOLAR_TIMERS_JC_BACKGROUND_COLOR_TIP),
					default = { r = 0.529, g = 1, b = 1, a = 1 },
					getFunc = function() return unpack(parent.savedVariables.timers.jcBackgroundColor) end,
					setFunc = function(r, g, b, a)
						parent.savedVariables.timers.jcBackgroundColor = { r, g, b, a }
						Scholar_Timers:ApplySettings()
					end
				},
				{
					type    = "colorpicker",
					name    = GetString(SCHOLAR_TIMERS_JC_GLOSS_COLOR),
					tooltip = GetString(SCHOLAR_TIMERS_JC_GLOSS_COLOR_TIP),
					default = { r = 1, g = 1, b = 1, a = 1 },
					getFunc = function() return unpack(parent.savedVariables.timers.jcGlossColor) end,
					setFunc = function(r, g, b, a)
						parent.savedVariables.timers.jcGlossColor = { r, g, b, a }
						Scholar_Timers:ApplySettings()
					end
				},
				{
					type = "header",
					name = GetString(SCHOLAR_TIMERS_DISPLAY_HEADER)
				},
				{
					type          = "dropdown",
					name          = GetString(SCHOLAR_TIMERS_TIMER_ACTION),
					tooltip       = GetString(SCHOLAR_TIMERS_TIMER_ACTION_TIP),
					warning       = GetString(SCHOLAR_RELOAD_WARNING),
					choices       = { GetString(SCHOLAR_OPTION_FILL), GetString(SCHOLAR_OPTION_DRAIN) },
					choicesValues = { "fill", "drain" },
					default       = "fill",
					getFunc       = function() return parent.savedVariables.timers.timerAction end,
					setFunc       = function(timerAction)
						parent.savedVariables.timers.timerAction = timerAction
						ReloadUI("ingame")
					end
				},
				{
					type          = "dropdown",
					name          = GetString(SCHOLAR_TIMERS_SORT),
					tooltip       = GetString(SCHOLAR_TIMERS_SORT_TIP),
					warning       = GetString(SCHOLAR_RELOAD_WARNING),
					choices       = { GetString(SCHOLAR_OPTION_DESCENDING), GetString(SCHOLAR_OPTION_ASCENDING) },
					choicesValues = { "desc", "asc" },
					default       = "desc",
					getFunc       = function() return parent.savedVariables.timers.sort end,
					setFunc       = function(sort)
						parent.savedVariables.timers.sort = sort
						ReloadUI("ingame")
					end
				},
				{
					type    = "checkbox",
					name    = GetString(SCHOLAR_TIMERS_LOCK_UI),
					tooltip = GetString(SCHOLAR_TIMERS_LOCK_UI_TIP),
					default = true,
					getFunc = function() return parent.savedVariables.timers.lockUI end,
					setFunc = function(lockUI)
						parent.savedVariables.timers.lockUI = lockUI
						Scholar_Timers:ApplySettings()
					end
				},
				{
					type     = "slider",
					name     = GetString(SCHOLAR_TIMERS_SCALE),
					tooltip  = GetString(SCHOLAR_TIMERS_SCALE_TIP),
					default  = 0.7,
					min      = 0.5,
					max      = 1,
					step     = 0.1,
					decimals = 1,
					getFunc  = function() return parent.savedVariables.timers.scale end,
					setFunc  = function(scale)
						parent.savedVariables.timers.scale = scale
						Scholar_ResearchTimersContainer:SetScale(scale)
					end
				},
				{
					type    = "slider",
					name    = GetString(SCHOLAR_TIMERS_SPACING),
					tooltip = GetString(SCHOLAR_TIMERS_SPACING_TIP),
					default = 50,
					min     = 30,
					max     = 70,
					step    = 1,
					getFunc = function() return parent.savedVariables.timers.spacing end,
					setFunc = function(spacing)
						parent.savedVariables.timers.spacing = spacing
						Scholar_Timers:RearrangeBars()
					end
				}
			}
		},
		{
			type     = "submenu",
			name     = GetString(SCHOLAR_STABLE_TIMER_TITLE),
			controls = {
				{
					type = "description",
					text = GetString(SCHOLAR_STABLE_TIMER_DESCRIPTION)
				},
				{
					type    = "colorpicker",
					name    = GetString(SCHOLAR_STABLE_TIMER_BACKGROUND_COLOR),
					tooltip = GetString(SCHOLAR_STABLE_TIMER_BACKGROUND_COLOR_TIP),
					default = { r = 0.533, g = 6, b = 1, a = 1 },
					getFunc = function() return unpack(parent.savedVariables.timers.stableBackgroundColor) end,
					setFunc = function(r, g, b, a)
						parent.savedVariables.timers.stableBackgroundColor = { r, g, b, a }
						Scholar_Timers:ApplySettings()
					end
				},
				{
					type    = "colorpicker",
					name    = GetString(SCHOLAR_STABLE_TIMER_GLOSS_COLOR),
					tooltip = GetString(SCHOLAR_STABLE_TIMER_GLOSS_COLOR_TIP),
					default = { r = 1, g = 1, b = 1, a = 1 },
					getFunc = function() return unpack(parent.savedVariables.timers.stableGlossColor) end,
					setFunc = function(r, g, b, a)
						parent.savedVariables.timers.stableGlossColor = { r, g, b, a }
						Scholar_Timers:ApplySettings()
					end
				},
			}
		}
	}
	LAM:RegisterOptionControls("Scholar_Settings", optionsData)
end
