AUI.Settings.Actionbar = {}

local g_LAM = LibAddonMenu2
local g_isInit = false
local g_isPreviewShowing = false
local g_changedEnabled = false

local g_quickslotsMin = 0
local g_quickslotsMax = 8

local g_quick_slots_enabled = false
local g_ability_cooldowns_enabled = false
local g_ultimate_slots_enabled = false

local function GetDefaultSettings()	
	local defaultSettings = 
	{
		ability_cooldowns_enabled = true,	
		quick_slots_enabled = true,	
		ultimate_slots_enabled = true,	

		keyboard_quickslot_count = 4,
		gamepad_quickslot_count = 0,
		allow_over_100_percent = false,
		show_ultimate_percent = true,
		show_background = true,		
		useCompanionDefaultPos = false,	
	
		["ability_cooldowns"] = 
		{		
			["Forground"] = 
			{
				show_remaining_time = true,
				show_cooldown_frame = true,
				remaining_time_percent_color = AUI.Color.ConvertHexToRGBA("#00c609"),
				remaining_time_low_percent_color = AUI.Color.ConvertHexToRGBA("#ff0000"),		
				stack_count_color = AUI.Color.ConvertHexToRGBA("#ffd800"),				
				threshold_remaining_time_percent = 20,					
			},
			["Background"] = 
			{
				show_remaining_time = true,
				show_cooldown_frame = false,
				show_animated_icons = true,
				remaining_time_percent_color = AUI.Color.ConvertHexToRGBA("#00c609"),
				remaining_time_low_percent_color = AUI.Color.ConvertHexToRGBA("#ff0000"),
				stack_count_color = AUI.Color.ConvertHexToRGBA("#ffd800"),	
				threshold_remaining_time_percent = 20				
			}					
		}
	}
	
	return defaultSettings
end

local function AcceptEnabledSettings()
	AUI.Settings.Actionbar.ability_cooldowns_enabled = g_ability_cooldowns_enabled
	AUI.Settings.Actionbar.quick_slots_enabled = g_quick_slots_enabled
	AUI.Settings.Actionbar.ultimate_slots_enabled = g_ultimate_slots_enabled

	ReloadUI()
end

function GetGeneralOptions()
	local optionsData = 
	{	
		{
			type = "header",
			name = AUI_TXT_COLOR_HEADER:Colorize(AUI.L10n.GetString("general"))
		},	
		{
			type = "checkbox",
			name = AUI.L10n.GetString("acount_wide"),
			tooltip = AUI.L10n.GetString("acount_wide_tooltip"),
			getFunc = function() return AUI.Settings.MainMenu.modul_action_bar_account_wide end,
			setFunc = function(value)
				if value ~= nil then
					if value ~= AUI.Settings.MainMenu.modul_action_bar_account_wide then
						AUI.Settings.MainMenu.modul_action_bar_account_wide = value
						ReloadUI()
					else
						AUI.Settings.MainMenu.modul_action_bar_account_wide = value
					end
				end
			end,
			default = true,
			width = "full",
			warning = AUI.L10n.GetString("reloadui_warning_tooltip"),
		},		
		{
			type = "checkbox",
			name = AUI.L10n.GetString("preview"),
			tooltip = AUI.L10n.GetString("preview_tooltip"),
			getFunc = function() return g_isPreviewShowing end,
			setFunc = function(value)
				if value ~= nil then
					if value then
						AUI.Actionbar.ShowPreview()
					else
						AUI.Actionbar.HidePreview()
					end
					
					g_isPreviewShowing = value
				end
			end,
			default = g_isPreviewShowing,
			width = "full",
			warning = AUI.L10n.GetString("preview_warning"),			
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_background"),
			tooltip = AUI.L10n.GetString("show_keybind_bg_tooltip"),
			getFunc = function() return AUI.Settings.Actionbar.show_background end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.Actionbar.show_background = value
					AUI.Actionbar.UpdateUI()
				end
			end,
			default = GetDefaultSettings().show_background,
			width = "full",
		},			
		{		
			type = "submenu",
			name = AUI_TXT_COLOR_SUBMENU:Colorize(AUI.L10n.GetString("display")),
			controls = 
			{					
				{
					type = "checkbox",
					name = AUI.L10n.GetString("quick_slots"),
					getFunc = function() return g_quick_slots_enabled end,
					setFunc = function(value)
						if value ~= nil then
							g_quick_slots_enabled = value
							g_changedEnabled = true
						end
					end,
					default = GetDefaultSettings().quick_slots_enabled,
					width = "full",
					warning = AUI.L10n.GetString("reloadui_manual_warning_tooltip"),
				},		
				{
					type = "checkbox",
					name = AUI.L10n.GetString("ability_cooldowns"),
					getFunc = function() return g_ability_cooldowns_enabled end,
					setFunc = function(value)
						if value ~= nil then
							g_ability_cooldowns_enabled = value
							g_changedEnabled = true
						end
					end,
					default = GetDefaultSettings().ability_cooldowns_enabled,
					width = "full",
					warning = AUI.L10n.GetString("reloadui_manual_warning_tooltip"),
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("ultimate"),
					getFunc = function() return g_ultimate_slots_enabled end,
					setFunc = function(value)
						if value ~= nil then
							g_ultimate_slots_enabled = value
							g_changedEnabled = true
						end
					end,
					default = GetDefaultSettings().quick_slots_enabled,
					width = "full",
					warning = AUI.L10n.GetString("reloadui_manual_warning_tooltip"),
				},		
				{
					type = "button",
					name = AUI.L10n.GetString("accept_settings"),
					tooltip = AUI.L10n.GetString("accept_settings_tooltip"),
					func = function() AcceptEnabledSettings() end,
					disabled = function() return not g_changedEnabled end,
				},		
			}
		}
	}
	
	return optionsData
end

function GetActionSlotOptions()
	local optionsData = 
	{		
		{		
			type = "submenu",
			name = AUI_TXT_COLOR_SUBMENU:Colorize(AUI.L10n.GetString("ability_cooldowns")),
			controls = 
			{	
				{
					type = "header",
					name = AUI_TXT_COLOR_HEADER:Colorize(AUI.L10n.GetString("foreground"))
				},				
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_remaining_time"),
					tooltip = AUI.L10n.GetString("show_remaining_time_tooltip"),
					getFunc = function() return AUI.Settings.Actionbar.ability_cooldowns.Forground.show_remaining_time end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.Actionbar.ability_cooldowns.Forground.show_remaining_time = value
							AUI.Actionbar.AbilityButtons.UpdateUI()
							AUI.Actionbar.AbilityButtons.UpdateGameSettings()
						end
					end,
					default = GetDefaultSettings().ability_cooldowns.Forground.show_remaining_time,
					width = "full",
					warning = AUI.L10n.GetString("remaining_time_info"),
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_cooldown_frame"),
					tooltip = AUI.L10n.GetString("show_cooldown_frame_tooltip"),
					getFunc = function() return AUI.Settings.Actionbar.ability_cooldowns.Forground.show_cooldown_frame end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.Actionbar.ability_cooldowns.Forground.show_cooldown_frame = value
							AUI.Actionbar.AbilityButtons.UpdateUI()
							AUI.Actionbar.AbilityButtons.UpdateGameSettings()
						end
					end,
					default = GetDefaultSettings().ability_cooldowns.Forground.show_cooldown_frame,
					width = "full",
					warning = AUI.L10n.GetString("remaining_time_info"),
				},								
				{
					type = "colorpicker",
					name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("remaining_time"),
					getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Actionbar.ability_cooldowns.Forground.remaining_time_percent_color):UnpackRGBA() end,
					setFunc = function(r,g,b,a) 
						AUI.Settings.Actionbar.ability_cooldowns.Forground.remaining_time_percent_color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
						AUI.Actionbar.AbilityButtons.UpdateUI()
					  end,
					default = GetDefaultSettings().ability_cooldowns.Forground.remaining_time_percent_color,
					width = "full",
				},	
				{
					type = "colorpicker",
					name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("remaining_time") .. " (" .. AUI.L10n.GetString("low") .. ")",
					getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Actionbar.ability_cooldowns.Forground.remaining_time_low_percent_color):UnpackRGBA() end,
					setFunc = function(r,g,b,a) 
						AUI.Settings.Actionbar.ability_cooldowns.Forground.remaining_time_low_percent_color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
						AUI.Actionbar.AbilityButtons.UpdateUI()
					  end,
					default = GetDefaultSettings().ability_cooldowns.Forground.remaining_time_low_percent_color,
					width = "full",
				},
				{
					type = "colorpicker",
					name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("stack_count"),
					getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Actionbar.ability_cooldowns.Forground.stack_count_color):UnpackRGBA() end,
					setFunc = function(r,g,b,a) 
						AUI.Settings.Actionbar.ability_cooldowns.Forground.stack_count_color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
						AUI.Actionbar.AbilityButtons.UpdateUI()
					  end,
					default = GetDefaultSettings().ability_cooldowns.Forground.stack_count_color,
					width = "full",
				},				
				{
					type = "slider",
					name = AUI.L10n.GetString("threshold_percent") .. " (" .. AUI.L10n.GetString("color") .. ")",
					tooltip = AUI.L10n.GetString("threshold_colorize_tooltip"),
					min = 1,
					max = 100,
					step = 1,
					getFunc = function() return AUI.Settings.Actionbar.ability_cooldowns.Forground.threshold_remaining_time_percent end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.Actionbar.ability_cooldowns.Forground.threshold_remaining_time_percent = value
							AUI.Actionbar.AbilityButtons.UpdateUI()
						end
					end,
					default = GetDefaultSettings().ability_cooldowns.Forground.threshold_remaining_time_percent,
					width = "full",
				},						
				{
					type = "header",
					name = AUI_TXT_COLOR_HEADER:Colorize(AUI.L10n.GetString("background"))
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_remaining_time"),
					tooltip = AUI.L10n.GetString("show_remaining_time_tooltip"),
					getFunc = function() return AUI.Settings.Actionbar.ability_cooldowns.Background.show_remaining_time end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.Actionbar.ability_cooldowns.Background.show_remaining_time = value
							AUI.Actionbar.AbilityButtons.UpdateUI()
							AUI.Actionbar.AbilityButtons.UpdateGameSettings()
						end
					end,
					default = GetDefaultSettings().ability_cooldowns.Background.show_remaining_time,
					width = "full",
				},				
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_cooldown_frame"),
					tooltip = AUI.L10n.GetString("show_cooldown_frame_tooltip"),
					getFunc = function() return AUI.Settings.Actionbar.ability_cooldowns.Background.show_cooldown_frame end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.Actionbar.ability_cooldowns.Background.show_cooldown_frame = value
							AUI.Actionbar.AbilityButtons.UpdateUI()
						end
					end,
					default = GetDefaultSettings().ability_cooldowns.Background.show_cooldown_frame,
					width = "full",
				},					
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_animated_icons"),
					tooltip = AUI.L10n.GetString("show_threshold_animated_icons_tooltip"),
					getFunc = function() return AUI.Settings.Actionbar.ability_cooldowns.Background.show_animated_icons end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.Actionbar.ability_cooldowns.Background.show_animated_icons = value
							AUI.Actionbar.AbilityButtons.UpdateUI()
						end
					end,
					default = GetDefaultSettings().ability_cooldowns.Background.show_animated_icons,
					width = "full",
				},					
				{
					type = "colorpicker",
					name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("remaining_time"),
					getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Actionbar.ability_cooldowns.Background.remaining_time_percent_color):UnpackRGBA() end,
					setFunc = function(r,g,b,a) 
						AUI.Settings.Actionbar.ability_cooldowns.Background.remaining_time_percent_color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
						AUI.Actionbar.AbilityButtons.UpdateUI()
					  end,
					default = GetDefaultSettings().ability_cooldowns.Background.remaining_time_percent_color,
					width = "full",
				},	
				{
					type = "colorpicker",
					name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("remaining_time") .. " (" .. AUI.L10n.GetString("low") .. ")",
					getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Actionbar.ability_cooldowns.Background.remaining_time_low_percent_color):UnpackRGBA() end,
					setFunc = function(r,g,b,a) 
						AUI.Settings.Actionbar.ability_cooldowns.Background.remaining_time_low_percent_color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
						AUI.Actionbar.AbilityButtons.UpdateUI()
					  end,
					default = GetDefaultSettings().ability_cooldowns.Background.remaining_time_low_percent_color,
					width = "full",
				},
				{
					type = "colorpicker",
					name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("stack_count"),
					getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Actionbar.ability_cooldowns.Background.stack_count_color):UnpackRGBA() end,
					setFunc = function(r,g,b,a) 
						AUI.Settings.Actionbar.ability_cooldowns.Background.stack_count_color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
						AUI.Actionbar.AbilityButtons.UpdateUI()
					  end,
					default = GetDefaultSettings().ability_cooldowns.Background.stack_count_color,
					width = "full",
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("threshold_percent") .. " (" .. AUI.L10n.GetString("color") .. ")",
					tooltip = AUI.L10n.GetString("threshold_colorize_tooltip"),
					min = 1,
					max = 100,
					step = 1,
					getFunc = function() return AUI.Settings.Actionbar.ability_cooldowns.Background.threshold_remaining_time_percent end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.Actionbar.ability_cooldowns.Background.threshold_remaining_time_percent = value
							AUI.Actionbar.AbilityButtons.UpdateUI()
						end
					end,
					default = GetDefaultSettings().ability_cooldowns.Background.threshold_remaining_time_percent,
					width = "full",
				}															
			}
		}
	}
	
	return optionsData
end

function GetCompanionUltiOptions()
	local optionsData = 
	{		
		{		
			type = "submenu",
			name = AUI_TXT_COLOR_SUBMENU:Colorize(AUI.L10n.GetString("ultimate")),
			controls = 
			{	
				{
					type = "header",
					name = AUI_TXT_COLOR_HEADER:Colorize(AUI.L10n.GetString("player"))
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_text"),
					tooltip = AUI.L10n.GetString("show_text_tooltip"),
					getFunc = function() return AUI.Settings.Actionbar.show_ultimate_percent end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.Actionbar.show_ultimate_percent = value
							
							if value then
								AUI.Actionbar.DisableDefaultUltiTextSetting()
							end

							AUI.Actionbar.UltimateButtons.UpdateUI()
						end
					end,
					default = GetDefaultSettings().show_ultimate_percent,
					width = "full",
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("allow_more_than_100%"),
					tooltip = AUI.L10n.GetString("allow_more_than_100%_tooltip"),
					getFunc = function() return AUI.Settings.Actionbar.allow_over_100_percent end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.Actionbar.allow_over_100_percent = value
							AUI.Actionbar.UltimateButtons.UpdateUI()
						end
					end,
					default = GetDefaultSettings().allow_over_100_percent,
					width = "full",
				},			
				{
					type = "header",
					name = AUI_TXT_COLOR_HEADER:Colorize(AUI.L10n.GetString("companion"))
				},				
				{
					type = "checkbox",
					name = AUI.L10n.GetString("use_default_position"),
					tooltip = AUI.L10n.GetString("use_default_position_tooltip"),
					getFunc = function() return AUI.Settings.Actionbar.useCompanionDefaultPos end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.Actionbar.useCompanionDefaultPos = value
							AUI.Actionbar.UpdateUI()
						end
					end,
					default = GetDefaultSettings().useCompanionDefaultPos,
					width = "full",
				}				
			}
		}
	}
	
	return optionsData
end

function GetQuickSlotOptions()
	local optionsData = 
	{		
		{		
			type = "submenu",
			name = AUI_TXT_COLOR_SUBMENU:Colorize(AUI.L10n.GetString("quick_slots")),
			controls = 
			{			
				{
					type = "slider",
					name = AUI.L10n.GetString("slot_count") .. " (" .. AUI.L10n.GetString("keyboard") .. ")",
					tooltip = AUI.L10n.GetString("slot_count_tooltip"),
					min = g_quickslotsMin,
					max = g_quickslotsMax,
					step = 1,
					getFunc = function() return AUI.Settings.Actionbar.keyboard_quickslot_count end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.Actionbar.keyboard_quickslot_count = value
							AUI.Actionbar.QuickButtons.UpdateUI()
							AUI.Actionbar.UltimateButtons.UpdateUI()
						end
					end,
					default = GetDefaultSettings().keyboard_quickslot_count,
					width = "full",
				},
				{
					type = "slider",
					name = AUI.L10n.GetString("slot_count") .. " (" .. AUI.L10n.GetString("gamepad") .. ")",
					tooltip = AUI.L10n.GetString("slot_count_tooltip"),
					min = g_quickslotsMin,
					max = g_quickslotsMax,
					step = 1,
					getFunc = function() return AUI.Settings.Actionbar.gamepad_quickslot_count end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.Actionbar.gamepad_quickslot_count = value
							AUI.Actionbar.QuickButtons.UpdateUI()
							AUI.Actionbar.UltimateButtons.UpdateUI()
						end
					end,
					default = GetDefaultSettings().gamepad_quickslot_count,
					width = "full",
				},				
			}
		}
	}
	
	return optionsData
end

function AUI.Actionbar.LoadSettings()
	if g_isInit then
		return
	end
		
	g_isInit = true	

	if AUI.Settings.MainMenu.modul_action_bar_account_wide then
		AUI.Settings.Actionbar = ZO_SavedVars:NewAccountWide("AUI_Skillbar", 11, nil, GetDefaultSettings())
	else
		AUI.Settings.Actionbar = ZO_SavedVars:New("AUI_Skillbar", 11, nil, GetDefaultSettings())
	end	
	
	g_ability_cooldowns_enabled = AUI.Settings.Actionbar.ability_cooldowns_enabled	
	g_quick_slots_enabled = AUI.Settings.Actionbar.quick_slots_enabled
	g_ultimate_slots_enabled = AUI.Settings.Actionbar.ultimate_slots_enabled
	
	local options = GetGeneralOptions()
	
	if g_quick_slots_enabled then
		local quickSlotOptions = GetQuickSlotOptions()
		for i = 1, #quickSlotOptions do 
			table.insert(options, quickSlotOptions[i]) 
		end		
	end	
	
	if g_ability_cooldowns_enabled then
		local actionSlotOptions = GetActionSlotOptions()
		for i = 1, #actionSlotOptions do 
			table.insert(options, actionSlotOptions[i]) 
		end	
	end

	if g_ultimate_slots_enabled then
		local companionUltiSlotOptions = GetCompanionUltiOptions()
		for i = 1, #companionUltiSlotOptions do 
			table.insert(options, companionUltiSlotOptions[i]) 
		end	
	end	

	local panelData = 
	{
		type = "panel",
		name = AUI_MAIN_NAME .. " (" .. AUI.L10n.GetString("actionbar_module_name") .. ")",
		displayName = "|cFFFFB0" .. AUI_MAIN_NAME .. " (" .. AUI.L10n.GetString("actionbar_module_name") .. ")",
		author = AUI_TXT_COLOR_AUTHOR:Colorize(AUI_ACTIONBAR_AUTHOR),
		version = AUI_TXT_COLOR_VERSION:Colorize(AUI_ACTIONBAR_VERSION),
		slashCommand = "/auitarget",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	
	g_LAM:RegisterAddonPanel("AUI_Menu_Skillbar", panelData)
	g_LAM:RegisterOptionControls("AUI_Menu_Skillbar", options)
end
