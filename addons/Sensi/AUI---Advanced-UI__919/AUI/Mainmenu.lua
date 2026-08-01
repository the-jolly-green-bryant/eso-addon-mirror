AUI.MainMenu = {}
AUI.Settings.MainMenu = {}

local g_lam = LibAddonMenu2
local g_isInit = false
local g_changedEnabled = false
local g_modul_minimap_enabled = true
local g_modul_unit_frames_enabled = true
local g_modul_combat_stats_enabled = true
local g_modul_action_bar_enabled = true
local g_modul_buffs_enabled = true
local g_modul_quest_tracker_enabled = false
local g_modul_frame_mover_enabled = false

local function ConvertOptionsFromOlderVersion()
	if AUI.Settings.MainMenu.converted315 then
		return
	end

	if AUI.Settings.MainMenu.modul_attributes_account_wide ~= nil then
		AUI.Settings.MainMenu.modul_unit_frames_account_wide = AUI.Settings.MainMenu.modul_attributes_account_wide
	end	

	if AUI.Settings.MainMenu.modul_actionBar_account_wide ~= nil then
		AUI.Settings.MainMenu.modul_action_bar_account_wide = AUI.Settings.MainMenu.modul_actionBar_account_wide
	end
	
	if AUI.Settings.MainMenu.modul_questtacker_account_wide ~= nil then
		AUI.Settings.MainMenu.modul_quest_tacker_account_wide = AUI.Settings.MainMenu.modul_questtacker_account_wide
	end	
	
	if AUI.Settings.MainMenu.modul_FrameMover_account_wide ~= nil then
		AUI.Settings.MainMenu.modul_frame_mover_account_wide = AUI.Settings.MainMenu.modul_FrameMover_account_wide
	end		

	if AUI.Settings.MainMenu.modul_attribute_enabled ~= nil then
		AUI.Settings.MainMenu.modul_unit_frames_enabled = AUI.Settings.MainMenu.modul_attribute_enabled
	end	

	if AUI.Settings.MainMenu.modul_actionBar_enabled ~= nil then
		AUI.Settings.MainMenu.modul_action_bar_enabled = AUI.Settings.MainMenu.modul_actionBar_enabled
	end
	
	if AUI.Settings.MainMenu.modul_questtracker_enabled ~= nil then
		AUI.Settings.MainMenu.modul_quest_tracker_enabled = AUI.Settings.MainMenu.modul_questtracker_enabled
	end	
	
	if AUI.Settings.MainMenu.modul_FrameMover_enabled ~= nil then
		AUI.Settings.MainMenu.modul_frame_mover_enabled = AUI.Settings.MainMenu.modul_FrameMover_enabled
	end	

	AUI.Settings.MainMenu.converted315 = true
end

local function GetDefaultSettings()
	local defaultSettings =
	{		
		modul_minimap_account_wide = true,
		modul_unit_frames_account_wide = true,
		modul_combat_account_wide = true,
		modul_action_bar_account_wide = true,	
		modul_buffs_account_wide = true,	
		modul_quest_tacker_account_wide = true,
		modul_frame_mover_account_wide = true,
		modul_minimap_enabled = true,
		modul_unit_frames_enabled = true,	
		modul_combat_stats_enabled = true,	
		modul_action_bar_enabled = true,	
		modul_buffs_enabled = true,
		modul_quest_tracker_enabled = true,
		modul_frame_mover_enabled = true,
		show_start_message = true,
	}

	return defaultSettings
end

local function AcceptSettings()
	AUI.Settings.MainMenu.modul_minimap_enabled = g_modul_minimap_enabled
	AUI.Settings.MainMenu.modul_unit_frames_enabled = g_modul_unit_frames_enabled
	AUI.Settings.MainMenu.modul_combat_stats_enabled = g_modul_combat_stats_enabled
	AUI.Settings.MainMenu.modul_action_bar_enabled = g_modul_action_bar_enabled
	AUI.Settings.MainMenu.modul_buffs_enabled = g_modul_buffs_enabled
	AUI.Settings.MainMenu.modul_quest_tracker_enabled = g_modul_quest_tracker_enabled
	AUI.Settings.MainMenu.modul_frame_mover_enabled = g_modul_frame_mover_enabled
	
	ReloadUI()
end

local function GetOptions()
	local optionsTable = {	
		{
			type = "header",
			name = AUI_TXT_COLOR_HEADER:Colorize(AUI.L10n.GetString("general"))
		},		
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_start_message"),
			getFunc = function() return AUI.Settings.MainMenu.show_start_message end,
			setFunc = function(value)
						AUI.Settings.MainMenu.show_start_message = value
			end,
			default = GetDefaultSettings().show_start_message,
			width = "full",
		},	
		{
			type = "header",
			name = AUI_TXT_COLOR_HEADER:Colorize(AUI.L10n.GetString("module_management"))
		},	
		{
			type = "checkbox",
			name = AUI.L10n.GetString("minimap_module_name"),
			getFunc = function() return g_modul_minimap_enabled end,
			setFunc = function(value)
						g_modul_minimap_enabled = value
						g_changedEnabled = true	
			end,
			default = GetDefaultSettings().modul_minimap_enabled,
			width = "full",
			warning = AUI.L10n.GetString("reloadui_manual_warning_tooltip"),
		},		
		{
			type = "checkbox",
			name = AUI.L10n.GetString("attributes_module_name"),
			getFunc = function() return g_modul_unit_frames_enabled end,
			setFunc = function(value)
						g_modul_unit_frames_enabled  = value
						g_changedEnabled = true						
			end,
			default = GetDefaultSettings().modul_unit_frames_enabled,
			width = "full",
			warning = AUI.L10n.GetString("reloadui_manual_warning_tooltip"),
		},				
		{
			type = "checkbox",
			name = AUI.L10n.GetString("combat_module_name"),
			getFunc = function() return g_modul_combat_stats_enabled end,
			setFunc = function(value)
						g_modul_combat_stats_enabled = value	
						g_changedEnabled = true	
			end,
			default = GetDefaultSettings().modul_combat_stats_enabled,
			width = "full",
			warning = AUI.L10n.GetString("reloadui_manual_warning_tooltip"),
		},			
		{
			type = "checkbox",
			name = AUI.L10n.GetString("actionbar_module_name"),
			getFunc = function() return g_modul_action_bar_enabled end,
			setFunc = function(value)
						g_modul_action_bar_enabled = value
						g_changedEnabled = true	
			end,
			default = GetDefaultSettings().modul_action_bar_enabled,
			width = "full",
			warning = AUI.L10n.GetString("reloadui_manual_warning_tooltip"),
		},	
		{
			type = "checkbox",
			name = AUI.L10n.GetString("buffs_module_name"),
			getFunc = function() return g_modul_buffs_enabled end,
			setFunc = function(value)
						g_modul_buffs_enabled = value
						g_changedEnabled = true	
			end,
			default = GetDefaultSettings().modul_buffs_enabled,
			width = "full",
			warning = AUI.L10n.GetString("reloadui_manual_warning_tooltip"),
		},	
		{
			type = "checkbox",
			name = AUI.L10n.GetString("quest_tracker_module_name"),
			getFunc = function() return g_modul_quest_tracker_enabled end,
			setFunc = function(value)
						g_modul_quest_tracker_enabled = value
						g_changedEnabled = true	
			end,
			default = GetDefaultSettings().modul_quest_tracker_enabled,
			width = "full",
			warning = AUI.L10n.GetString("reloadui_manual_warning_tooltip"),
		},		
		{
			type = "checkbox",
			name = AUI.L10n.GetString("frame_mover_module_name"),
			getFunc = function() return g_modul_frame_mover_enabled end,
			setFunc = function(value)
						g_modul_frame_mover_enabled = value
						g_changedEnabled = true	
			end,
			default = GetDefaultSettings().modul_frame_mover_enabled,
			width = "full",
			warning = AUI.L10n.GetString("reloadui_manual_warning_tooltip"),
		},			
		{
			type = "header",
		},		
        {
            type = "button",
            name = AUI.L10n.GetString("accept_settings"),
            func = function() AcceptSettings() end,
			disabled = function() return not g_changedEnabled end,
        },		
	}
	
	return optionsTable
end

local function LoadSettings()
	AUI.Settings.MainMenu = ZO_SavedVars:NewAccountWide("AUI_Main", 1, nil, GetDefaultSettings())
	
	g_modul_minimap_enabled = AUI.Settings.MainMenu.modul_minimap_enabled
	g_modul_unit_frames_enabled = AUI.Settings.MainMenu.modul_unit_frames_enabled
	g_modul_combat_stats_enabled = AUI.Settings.MainMenu.modul_combat_stats_enabled
	g_modul_action_bar_enabled = AUI.Settings.MainMenu.modul_action_bar_enabled
	g_modul_buffs_enabled = AUI.Settings.MainMenu.modul_buffs_enabled
	g_modul_quest_tracker_enabled = AUI.Settings.MainMenu.modul_quest_tracker_enabled
	g_modul_frame_mover_enabled = AUI.Settings.MainMenu.modul_frame_mover_enabled 
end

function AUI.MainMenu.SetMenuData()
	if g_isInit then
		return
	end	
	
	local panelData = {
		type = "panel",
		name = AUI_MAIN_NAME .. " (" .. AUI.L10n.GetString("module_management") .. ")",
		displayName = "|cFFFFB0" .. AUI_MAIN_NAME .. " (" .. AUI.L10n.GetString("module_management") .. ")",
		author = AUI_TXT_COLOR_AUTHOR:Colorize(AUI_MAIN_AUTHOR),
		version = AUI_TXT_COLOR_VERSION:Colorize(AUI_MAIN_VERSION),
		slashCommand = "/aui",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	
	LoadSettings()
	ConvertOptionsFromOlderVersion()
	
	g_lam:RegisterOptionControls("AUI_MainMenu", GetOptions())
	g_lam:RegisterAddonPanel("AUI_MainMenu", panelData)
	
	g_isInit = true
end
