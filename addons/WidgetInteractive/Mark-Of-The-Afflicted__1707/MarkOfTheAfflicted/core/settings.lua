-- Libraries -------------------------------------------------------------------
local LAM = LibAddonMenu2

-- Variables -------------------------------------------------------------------
MotA_Settings = {}

-- Settings menu ---------------------------------------------------------------
function MotA_Settings:CreateMenu(parent)
	-- Register panel
	local panelData = {
		type                = "panel",
		name                = GetString(MOTA_TITLE),
		displayName         = GetString(MOTA_TITLE),
		author              = "Widgit Labs",
		version             = MOTA_VERSION,
		slashCommand        = "/mota_settings",
		registerForRefresh  = true,
		registerForDefaults = true,
		website             = MOTA_WEBSITE
	}
	LAM:RegisterAddonPanel("MotA_Settings", panelData)

	-- Load ZO_NORMAL_TEXT to set defaults
	local norm = ZO_NORMAL_TEXT

	-- Define options
	local optionsData = {
		{
			type     = "submenu",
			name     = GetString(MOTA_GENERAL_TITLE),
			controls = {
				{
					type    = "checkbox",
					name    = GetString(MOTA_ACCOUNT_WIDE),
					tooltip = GetString(MOTA_ACCOUNT_WIDE_TIP),
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
					name = GetString(MOTA_MODULES_HEADER)
				},
				{
					type = "description",
					text = GetString(MOTA_MODULES_DESCRIPTION)
				},
				{
					type    = "checkbox",
					name    = GetString(MOTA_ENABLE_TIMERS),
					tooltip = GetString(MOTA_ENABEL_TIMERS_TIP),
					default = true,
					getFunc = function() return parent.savedVariables.enable.timers end,
					setFunc = function(enable) parent.savedVariables.enable.timers = enable end
				},
				{
					type    = "button",
					name    = GetString(MOTA_RELOAD_UI),
					tooltip = GetString(MOTA_RELOAD_UI_TIP),
					func    = function() ReloadUI("ingame") end
				}
			},
		},
		{
			type     = "submenu",
			name     = GetString(MOTA_TIMERS_TITLE),
			controls = {
				{
					type    = "checkbox",
					name    = GetString(MOTA_TIMERS_SHOW_ALL),
					tooltip = GetString(MOTA_TIMERS_SHOW_ALL_TIP),
					warning = GetString(MOTA_RELOAD_WARNING),
					default = false,
					getFunc = function() return parent.savedVariables.timers.showAll end,
					setFunc = function(showAll) parent.savedVariables.timers.showAll = showAll
						ReloadUI("ingame")
					end
				},
				{
					type    = "checkbox",
					name    = GetString(MOTA_TIMERS_HIDE_IN_COMBAT),
					tooltip = GetString(MOTA_TIMERS_HIDE_IN_COMBAT_TIP),
					default = true,
					getFunc = function() return parent.savedVariables.timers.hideInCombat end,
					setFunc = function(hideInCombat) parent.savedVariables.timers.hideInCombat = hideInCombat
						MotA_Timers:ApplySettings()
					end
				},
				{
					type          = "dropdown",
					name          = GetString(MOTA_TIMERS_NOTIFICATIONS),
					tooltip       = GetString(MOTA_TIMERS_NOTIFICATIONS_TIP),
					choices       = {GetString(MOTA_OPTION_NONE), GetString(MOTA_OPTION_CHAT), GetString(MOTA_OPTION_ANNOUNCEMENT)},
					choicesValues = {"none", "chat", "announcement"},
					default       = "none",
					getFunc       = function() return parent.savedVariables.timers.notifications end,
					setFunc       = function(notifications) parent.savedVariables.timers.notifications                              = notifications end
				},
				{
					type    = "dropdown",
					name    = GetString(MOTA_TIMERS_NOTIFICATION_SOUND),
					tooltip = GetString(MOTA_TIMERS_NOTIFICATION_SOUND_TIP),
					choices = MotA_Sounds:GetSoundChoices(parent),
					default = "Smithing_Finish_Research",
					getFunc = function() return parent.savedVariables.timers.notificationSound end,
					setFunc = function(sound) parent.savedVariables.timers.notificationSound = sound end
				},
				{
					type    = "button",
					name    = GetString(MOTA_TIMERS_NOTIFICATION_SOUND_TEST),
					tooltip = GetString(MOTA_TIMERS_NOTIFICATION_SOUND_TEST_TIP),
					func    = function() PlaySound(parent.savedVariables.timers.notificationSound) end
				},
				{
					type = "header",
					name = GetString(MOTA_TIMERS_LABEL_HEADER)
				},
				{
					type          = "dropdown",
					name          = GetString(MOTA_TIMERS_LABEL_FONT),
					tooltip       = GetString(MOTA_TIMERS_LABEL_FONT_TIP),
					choices       = MotA_Fonts:GetFontChoices(true),
					choicesValues = MotA_Fonts:GetFontChoices(),
					default       = "BOLD_FONT",
					getFunc       = function() return parent.savedVariables.timers.labelFont end,
					setFunc       = function(labelFont) parent.savedVariables.timers.labelFont = labelFont
						MotA_Timers:ApplySettings()
					end
				},
				{
					type          = "dropdown",
					name          = GetString(MOTA_TIMERS_LABEL_OUTLINE),
					tooltip       = GetString(MOTA_TIMERS_LABEL_OUTLINE_TIP),
					choices       = MotA_Fonts:GetOutlineChoices(true),
					choicesValues = MotA_Fonts:GetOutlineChoices(),
					default       = "soft-shadow-thick",
					getFunc       = function() return parent.savedVariables.timers.labelOutline end,
					setFunc       = function(labelOutline) parent.savedVariables.timers.labelOutline = labelOutline
						MotA_Timers:ApplySettings()
					end
				},
				{
					type     = "slider",
					name     = GetString(MOTA_TIMERS_LABEL_SIZE),
					tooltip  = GetString(MOTA_TIMERS_LABEL_SIZE_TIP),
					default  = 16,
					min      = 10,
					max      = 24,
					step     = 1,
					decimals = 0,
					getFunc  = function() return parent.savedVariables.timers.labelSize end,
					setFunc  = function(labelSize) parent.savedVariables.timers.labelSize = labelSize
						MotA_Timers:ApplySettings()
					end
				},
				{
					type    = "colorpicker",
					name    = GetString(MOTA_TIMERS_LABEL_COLOR),
					tooltip = GetString(MOTA_TIMERS_LABEL_COLOR_TIP),
					default = {r=norm.r, g=norm.g, b=norm.b, a=norm.a},
					getFunc = function() return unpack(parent.savedVariables.timers.labelColor) end,
					setFunc = function(r,g,b,a) parent.savedVariables.timers.labelColor = {r, g, b, a}
						MotA_Timers:ApplySettings()
					end
				},
				{
					type          = "dropdown",
					name          = GetString(MOTA_TIMERS_TIME_FONT),
					tooltip       = GetString(MOTA_TIMERS_TIME_FONT_TIP),
					choices       = MotA_Fonts:GetFontChoices(true),
					choicesValues = MotA_Fonts:GetFontChoices(),
					default       = "MEDIUM_FONT",
					getFunc       = function() return parent.savedVariables.timers.timeFont end,
					setFunc       = function(timeFont) parent.savedVariables.timers.timeFont    = timeFont
						MotA_Timers:ApplySettings()
					end
				},
				{
					type          = "dropdown",
					name          = GetString(MOTA_TIMERS_TIME_OUTLINE),
					tooltip       = GetString(MOTA_TIMERS_TIME_OUTLINE_TIP),
					choices       = MotA_Fonts:GetOutlineChoices(true),
					choicesValues = MotA_Fonts:GetOutlineChoices(),
					default       = "thick-outline",
					getFunc       = function() return parent.savedVariables.timers.timeOutline end,
					setFunc       = function(timeOutline) parent.savedVariables.timers.timeOutline = timeOutline
						MotA_Timers:ApplySettings()
					end
				},
				{
					type     = "slider",
					name     = GetString(MOTA_TIMERS_TIME_SIZE),
					tooltip  = GetString(MOTA_TIMERS_TIME_SIZE_TIP),
					default  = 14,
					min      = 10,
					max      = 24,
					step     = 1,
					decimals = 0,
					getFunc  = function() return parent.savedVariables.timers.timeSize end,
					setFunc  = function(timeSize) parent.savedVariables.timers.timeSize = timeSize
						MotA_Timers:ApplySettings()
					end
				},
				{
					type    = "colorpicker",
					name    = GetString(MOTA_TIMERS_TIME_COLOR),
					tooltip = GetString(MOTA_TIMERS_TIME_COLOR_TIP),
					default = {r=1, g=1, b=1, a=1},
					getFunc = function() return unpack(parent.savedVariables.timers.timeColor) end,
					setFunc = function(r,g,b,a) parent.savedVariables.timers.timeColor = {r, g, b, a}
						MotA_Timers:ApplySettings()
					end
				},
				{
					type          = "dropdown",
					name          = GetString(MOTA_TIMERS_LABEL_ALIGNMENT),
					tooltip       = GetString(MOTA_TIMERS_LABEL_ALIGNMENT_TIP),
					choices       = {GetString(MOTA_OPTION_LEFT), GetString(MOTA_OPTION_RIGHT)},
					choicesValues = {"left", "right"},
					default       = "left",
					getFunc       = function() return parent.savedVariables.timers.labelAlignment end,
					setFunc       = function(labelAlignment) parent.savedVariables.timers.labelAlignment = labelAlignment
						MotA_Timers:RearrangeBars()
					end
				},
				{
					type = "header",
					name = GetString(MOTA_TIMERS_BAR_COLORS_HEADER)
				},
				{
					type    = "colorpicker",
					name    = GetString(MOTA_TIMERS_WW_BACKGROUND_COLOR),
					tooltip = GetString(MOTA_TIMERS_WW_BACKGROUND_COLOR_TIP),
					default = {r=0.529, g=1, b=1, a=1},
					getFunc = function() return unpack(parent.savedVariables.timers.wwBackgroundColor) end,
					setFunc = function(r,g,b,a) parent.savedVariables.timers.wwBackgroundColor = {r, g, b, a}
						MotA_Timers:ApplySettings()
					end
				},
				{
					type    = "colorpicker",
					name    = GetString(MOTA_TIMERS_WW_GLOSS_COLOR),
					tooltip = GetString(MOTA_TIMERS_WW_GLOSS_COLOR_TIP),
					default = {r=1, g=1, b=1, a=1},
					getFunc = function() return unpack(parent.savedVariables.timers.wwGlossColor) end,
					setFunc = function(r,g,b,a) parent.savedVariables.timers.wwGlossColor = {r, g, b, a}
						MotA_Timers:ApplySettings()
					end
				},
				{
					type    = "colorpicker",
					name    = GetString(MOTA_TIMERS_VA_BACKGROUND_COLOR),
					tooltip = GetString(MOTA_TIMERS_VA_BACKGROUND_COLOR_TIP),
					default = {r=0.529, g=1, b=1, a=1},
					getFunc = function() return unpack(parent.savedVariables.timers.vaBackgroundColor) end,
					setFunc = function(r,g,b,a) parent.savedVariables.timers.vaBackgroundColor = {r, g, b, a}
						MotA_Timers:ApplySettings()
					end
				},
				{
					type    = "colorpicker",
					name    = GetString(MOTA_TIMERS_VA_GLOSS_COLOR),
					tooltip = GetString(MOTA_TIMERS_VA_GLOSS_COLOR_TIP),
					default = {r=1, g=1, b=1, a=1},
					getFunc = function() return unpack(parent.savedVariables.timers.vaGlossColor) end,
					setFunc = function(r,g,b,a) parent.savedVariables.timers.vaGlossColor = {r, g, b, a}
						MotA_Timers:ApplySettings()
					end
				},
				{
					type = "header",
					name = GetString(MOTA_TIMERS_DISPLAY_HEADER)
				},
				{
					type          = "dropdown",
					name          = GetString(MOTA_TIMERS_TIMER_ACTION),
					tooltip       = GetString(MOTA_TIMERS_TIMER_ACTION_TIP),
					warning       = GetString(MOTA_RELOAD_WARNING),
					choices       = {GetString(MOTA_OPTION_FILL), GetString(MOTA_OPTION_DRAIN)},
					choicesValues = {"fill", "drain"},
					default       = "fill",
					getFunc       = function() return parent.savedVariables.timers.timerAction end,
					setFunc       = function(timerAction) parent.savedVariables.timers.timerAction = timerAction
						ReloadUI("ingame")
					end
				},
				{
					type    = "checkbox",
					name    = GetString(MOTA_TIMERS_LOCK_UI),
					tooltip = GetString(MOTA_TIMERS_LOCK_UI_TIP),
					default = true,
					getFunc = function() return parent.savedVariables.timers.lockUI end,
					setFunc = function(lockUI) parent.savedVariables.timers.lockUI = lockUI
						MotA_Timers:ApplySettings()
					end
				},
				{
					type     = "slider",
					name     = GetString(MOTA_TIMERS_SCALE),
					tooltip  = GetString(MOTA_TIMERS_SCALE_TIP),
					default  = 0.7,
					min      = 0.5,
					max      = 1,
					step     = 0.1,
					decimals = 1,
					getFunc  = function() return parent.savedVariables.timers.scale end,
					setFunc  = function(scale) parent.savedVariables.timers.scale = scale
						MotA_BiteTimersContainer:SetScale(scale)
					end
				},
				{
					type    = "slider",
					name    = GetString(MOTA_TIMERS_SPACING),
					tooltip = GetString(MOTA_TIMERS_SPACING_TIP),
					default = 50,
					min     = 30,
					max     = 70,
					step    = 1,
					getFunc = function() return parent.savedVariables.timers.spacing end,
					setFunc = function(spacing) parent.savedVariables.timers.spacing = spacing
						MotA_Timers:RearrangeBars()
					end
				}
			}
		}
	}
	LAM:RegisterOptionControls("MotA_Settings", optionsData)
end
