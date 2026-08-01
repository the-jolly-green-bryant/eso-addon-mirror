AUI.Settings.Actionbar = {}

local SKILLBAR_MENU_MIN_SLOTS = 0
local SKILLBAR_MENU_MAX_SLOTS = 8

local LAM = LibStub("LibAddonMenu-2.0")

local isLoaded = false
local isPreviewShowing = false

local function GetDefaultSettings()
	local defaultSettings =
	{		
		keyboard_quickslot_count = 5,
		gamepad_quickslot_count = 0,
		show_ability_proc_effect = true,
		show_ultimate_info = true,
		allow_over_100_percent = false,
		play_proc_sound = true,
	}

	return defaultSettings
end

local function CreateOptionTable()
	local optionsTable = 
	{	
		{
			type = "header",
			name = AUI_TXT_COLOR_HEADER:Colorize(AUI.L10n.GetString("general"))
		},	
		{
			type = "checkbox",
			name = AUI.L10n.GetString("acount_wide"),
			tooltip = AUI.L10n.GetString("acount_wide_tooltip"),
			getFunc = function() return AUI.MainSettings.modul_actionBar_account_wide end,
			setFunc = function(value)
				AUI.MainSettings.modul_actionBar_account_wide = value
				ReloadUI()
			end,
			default = true,
			width = "full",
			warning = AUI.L10n.GetString("reloadui_warning_tooltip"),
		},		
		{
			type = "checkbox",
			name = AUI.L10n.GetString("preview"),
			tooltip = AUI.L10n.GetString("preview_tooltip"),
			getFunc = function() return isPreviewShowing end,
			setFunc = function(value)
				if value then
					AUI.Actionbar.Lock()
				else
					AUI.Actionbar.Unlock()
				end
				
				isPreviewShowing = value
			end,
			default = isPreviewShowing,
			width = "full",
			warning = AUI.L10n.GetString("preview_warning"),			
		},
		{		
			type = "submenu",
			name = AUI_TXT_COLOR_SUBMENU:Colorize(AUI.L10n.GetString("action_slots")),
			controls = 
			{
				{
					type = "header",
					name = AUI.L10n.GetString("ability_procs")
				},			
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_ability_proc_effect"),
					tooltip = AUI.L10n.GetString("show_ability_proc_effect_tooltip"),
					getFunc = function() return AUI.Settings.Actionbar.show_ability_proc_effect end,
					setFunc = function(value)
						AUI.Settings.Actionbar.show_ability_proc_effect = value
					end,
					default = GetDefaultSettings().show_ability_proc_effect,
					width = "full",
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("play_sound"),
					tooltip = AUI.L10n.GetString("play_sound_tooltip"),
					getFunc = function() return AUI.Settings.Actionbar.play_proc_sound end,
					setFunc = function(value)
						AUI.Settings.Actionbar.play_proc_sound = value
					end,
					default = GetDefaultSettings().play_proc_sound,
					width = "full",
				},				
			}
		},
		{		
			type = "submenu",
			name = AUI_TXT_COLOR_SUBMENU:Colorize(AUI.L10n.GetString("quick_slots")),
			controls = 
			{			
				{
					type = "slider",
					name = AUI.L10n.GetString("slot_count") .. " (" .. AUI.L10n.GetString("keyboard") .. ")",
					tooltip = AUI.L10n.GetString("slot_count_tooltip"),
					min = SKILLBAR_MENU_MIN_SLOTS,
					max = SKILLBAR_MENU_MAX_SLOTS,
					step = 1,
					getFunc = function() return AUI.Settings.Actionbar.keyboard_quickslot_count end,
					setFunc = function(value) 
						AUI.Settings.Actionbar.keyboard_quickslot_count = value
						AUI.Actionbar.UpdateUI()	
					end,
					default = GetDefaultSettings().keyboard_quickslot_count,
					width = "full",
				},
				{
					type = "slider",
					name = AUI.L10n.GetString("slot_count") .. " (" .. AUI.L10n.GetString("gamepad") .. ")",
					tooltip = AUI.L10n.GetString("slot_count_tooltip"),
					min = SKILLBAR_MENU_MIN_SLOTS,
					max = SKILLBAR_MENU_MAX_SLOTS,
					step = 1,
					getFunc = function() return AUI.Settings.Actionbar.gamepad_quickslot_count end,
					setFunc = function(value) 
						AUI.Settings.Actionbar.gamepad_quickslot_count = value
						AUI.Actionbar.UpdateUI()	
					end,
					default = GetDefaultSettings().gamepad_quickslot_count,
					width = "full",
				},				
			}
		},		
		{		
			type = "submenu",
			name = AUI_TXT_COLOR_SUBMENU:Colorize(AUI.L10n.GetString("ultimate")),
			controls = 
			{					
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_text"),
					tooltip = AUI.L10n.GetString("show_text_tooltip"),
					getFunc = function() return AUI.Settings.Actionbar.show_ultimate_info end,
					setFunc = function(value)
						AUI.Settings.Actionbar.show_ultimate_info = value
						AUI.Actionbar.UpdateUI()
					end,
					default = GetDefaultSettings().show_ultimate_info,
					width = "full",
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("allow_more_than_100%"),
					tooltip = AUI.L10n.GetString("allow_more_than_100%_tooltip"),
					getFunc = function() return AUI.Settings.Actionbar.allow_over_100_percent end,
					setFunc = function(value)
						AUI.Settings.Actionbar.allow_over_100_percent = value
						AUI.Actionbar.UpdateUI()
					end,
					default = GetDefaultSettings().allow_over_100_percent,
					width = "full",
				},
			}
		},
	}

	LAM:RegisterOptionControls("AUI_Menu_Skillbar", optionsTable)
end

local function LoadSettings()
	if AUI.MainSettings.modul_actionBar_account_wide then
		AUI.Settings.Actionbar = ZO_SavedVars:NewAccountWide("AUI_Skillbar", 4, nil, GetDefaultSettings())
	else
		AUI.Settings.Actionbar = ZO_SavedVars:New("AUI_Skillbar", 4, nil, GetDefaultSettings())
	end		
end

function AUI.Actionbar.SetMenuData()
	if isLoaded then
		return
	end

	local panelData = 
	{
		type = "panel",
		name = AUI_MAIN_NAME .. " (" .. AUI.L10n.GetString("actionbar_module_name") .. ")",
		displayName = "|cFFFFB0" .. AUI_MAIN_NAME .. " (" .. AUI.L10n.GetString("actionbar_module_name") .. ")",
		author = AUI_TXT_COLOR_AUTHOR:Colorize(AUI_ACTIONBAR_AUTHOR),
		version = AUI_TXT_COLOR_VERSION:Colorize(AUI_ACTIONBAR_VERSION),
		slashCommand = "/auitarget",
		registerForRefresh = false,
		registerForDefaults = true,
	}
	
	LoadSettings()
	CreateOptionTable()
	
	LAM:RegisterAddonPanel("AUI_Menu_Skillbar", panelData)
	
	isLoaded = true
end
