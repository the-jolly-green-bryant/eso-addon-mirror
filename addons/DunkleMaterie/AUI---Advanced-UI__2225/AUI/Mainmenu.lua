AUI.MainMenu = {}
AUI.MainSettings = {}

local isLoaded = false

local LAM = LibStub("LibAddonMenu-2.0")

local changed = false

local modul_minimap_enabled = true
local modul_attribute_enabled = true
local modul_combat_stats_enabled = true
local modul_actionBar_enabled = true
local modul_buffs_enabled = true
local modul_actionBarUseAzurah = false
local hasAzurah = false

local function GetDefaultSettings()
	local defaultSettings =
	{		
		modul_minimap_account_wide = true,
		modul_attributes_account_wide = true,
		modul_combat_account_wide = true,
		modul_actionBar_account_wide = true,	
		modul_buffs_account_wide = true,	
		modul_questtacker_account_wide = true,
		modul_FrameMover_account_wide = true,
		modul_minimap_enabled = true,
		modul_attribute_enabled = true,	
		modul_combat_stats_enabled = true,	
		modul_actionBar_enabled = true,	
		modul_actionBarUseAzurah = false, 
		modul_buffs_enabled = true,
		modul_questtracker_enabled = true,
		modul_FrameMover_enabled = true,
		show_start_message = true,
	}

	return defaultSettings
end

local function AcceptSettings()
	AUI.MainSettings.modul_minimap_enabled = modul_minimap_enabled
	AUI.MainSettings.modul_attribute_enabled = modul_attribute_enabled
	AUI.MainSettings.modul_combat_stats_enabled = modul_combat_stats_enabled
	AUI.MainSettings.modul_actionBar_enabled = modul_actionBar_enabled
	AUI.MainSettings.modul_actionBarUseAzurah = modul_actionBarUseAzurah
	AUI.MainSettings.modul_buffs_enabled = modul_buffs_enabled
	AUI.MainSettings.modul_questtracker_enabled = modul_questtracker_enabled
	AUI.MainSettings.modul_FrameMover_enabled = modul_FrameMover_enabled
	
	ReloadUI()
end

local function CreateOptionTable(isAzurahLoaded)
  hasAzurah = isAzurahLoaded
	local optionsTable = {	
		{
			type = "header",
			name = AUI_TXT_COLOR_HEADER:Colorize(AUI.L10n.GetString("general"))
		},		
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_start_message"),
			getFunc = function() return AUI.MainSettings.show_start_message end,
			setFunc = function(value)
						AUI.MainSettings.show_start_message = value
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
			getFunc = function() return modul_minimap_enabled end,
			setFunc = function(value)
						modul_minimap_enabled = value
						changed = true	
			end,
			default = GetDefaultSettings().modul_minimap_enabled,
			width = "full",
			warning = AUI.L10n.GetString("reloadui_manual_warning_tooltip"),
		},		
		{
			type = "checkbox",
			name = AUI.L10n.GetString("attributes_module_name"),
			getFunc = function() return modul_attribute_enabled end,
			setFunc = function(value)
						modul_attribute_enabled  = value
						changed = true						
			end,
			default = GetDefaultSettings().modul_attribute_enabled,
			width = "full",
			warning = AUI.L10n.GetString("reloadui_manual_warning_tooltip"),
		},				
		{
			type = "checkbox",
			name = AUI.L10n.GetString("combat_module_name"),
			getFunc = function() return modul_combat_stats_enabled end,
			setFunc = function(value)
						modul_combat_stats_enabled = value	
						changed = true	
			end,
			default = GetDefaultSettings().modul_combat_stats_enabled,
			width = "full",
			warning = AUI.L10n.GetString("reloadui_manual_warning_tooltip"),
		},			
		{
			type = "checkbox",
			name = AUI.L10n.GetString("actionbar_module_name"),
			getFunc = function() return modul_actionBar_enabled and not (modul_actionBarUseAzurah and isAzurahLoaded) end,
			setFunc = function(value)
						modul_actionBar_enabled = value
						changed = true	
			end,
			disabled = function() return modul_actionBarUseAzurah and isAzurahLoaded end,
			default = GetDefaultSettings().modul_actionBar_enabled,
			width = "full",
			warning = AUI.L10n.GetString("reloadui_manual_warning_tooltip"),
		},	
    {
      type = "checkbox",
      name = AUI.L10n.GetString("actionbar_module_use_azurah"),
      getFunc = function() return modul_actionBarUseAzurah and isAzurahLoaded end,
      setFunc = function(value)
            modul_actionBarUseAzurah = value
            if(value == true) then
                modul_actionBar_enabled = false
            else
                modul_actionBar_enabled = true
            end 
            changed = true  
      end,
      disabled = function() return not isAzurahLoaded end,
      default = GetDefaultSettings().modul_actionBarUseAzurah,
      width = "full",
      warning = AUI.L10n.GetString("reloadui_manual_warning_tooltip"),
    },  
		{
			type = "checkbox",
			name = AUI.L10n.GetString("buffs_module_name"),
			getFunc = function() return modul_buffs_enabled end,
			setFunc = function(value)
						modul_buffs_enabled = value
						changed = true	
			end,
			default = GetDefaultSettings().modul_buffs_enabled,
			width = "full",
			warning = AUI.L10n.GetString("reloadui_manual_warning_tooltip"),
		},	
		{
			type = "checkbox",
			name = AUI.L10n.GetString("quest_tracker_module_name"),
			getFunc = function() return modul_questtracker_enabled end,
			setFunc = function(value)
						modul_questtracker_enabled = value
						changed = true	
			end,
			default = GetDefaultSettings().modul_questtracker_enabled,
			width = "full",
			warning = AUI.L10n.GetString("reloadui_manual_warning_tooltip"),
		},		
		{
			type = "checkbox",
			name = AUI.L10n.GetString("frame_mover_module_name"),
			getFunc = function() return modul_FrameMover_enabled end,
			setFunc = function(value)
						modul_FrameMover_enabled = value
						changed = true	
			end,
			default = GetDefaultSettings().modul_FrameMover_enabled,
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
			disabled = function() return not changed end,
        },		
	}

	LAM:RegisterOptionControls("AUI_MainMenu", optionsTable)
end

local function LoadSettings()
	AUI.MainSettings = ZO_SavedVars:NewAccountWide("AUI_Main", 2, nil, GetDefaultSettings())
	
	modul_minimap_enabled = AUI.MainSettings.modul_minimap_enabled
	modul_attribute_enabled = AUI.MainSettings.modul_attribute_enabled
	modul_combat_stats_enabled = AUI.MainSettings.modul_combat_stats_enabled
	modul_actionBar_enabled = AUI.MainSettings.modul_actionBar_enabled
	modul_actionBarUseAzurah = false
	if AUI.MainSettings.modul_actionBarUseAzurah ~= nil then
	   modul_actionBarUseAzurah = AUI.MainSettings.modul_actionBarUseAzurah
	end
	-- We need to reset the flags in case of azurah has been uninstalled
	if modul_actionBarUseAzurah and not hasAzurah then
	   modul_actionBarUseAzurah = false
	end
	modul_buffs_enabled = AUI.MainSettings.modul_buffs_enabled
	modul_questtracker_enabled = AUI.MainSettings.modul_questtracker_enabled
	modul_FrameMover_enabled = AUI.MainSettings.modul_FrameMover_enabled 
end

function AUI.MainMenu.SetMenuData(hasAzurah)
	if isLoaded then
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
	CreateOptionTable(hasAzurah)
	
	LAM:RegisterAddonPanel("AUI_MainMenu", panelData)
	
	isLoaded = true
end
