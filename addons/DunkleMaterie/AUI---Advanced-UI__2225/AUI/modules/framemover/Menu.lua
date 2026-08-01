AUI.Settings.FrameMover = {}

local LAM = LibStub("LibAddonMenu-2.0")

local isLoaded = false

local function GetDefaultSettings()
	local defaultSettings =
	{
		enable = true,	
	}
	
	return defaultSettings
end

local function GetGeneralBoxOptions()
	local optionsTable = {
		{
			type = "header",
			name = AUI_TXT_COLOR_HEADER:Colorize(AUI.L10n.GetString("general"))
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("acount_wide"),
			tooltip = AUI.L10n.GetString("acount_wide_tooltip"),
			getFunc = function() return AUI.MainSettings.modul_FrameMover_account_wide end,
			setFunc = function(value)
						AUI.MainSettings.modul_FrameMover_account_wide = value
						ReloadUI()
			end,
			default = true,
			width = "full",
			warning = AUI.L10n.GetString("reloadui_warning_tooltip"),
		},	
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_windows"),
			getFunc = function() return AUI.FrameMover.IsPreviewShowing() end,
			setFunc = function(value)
						AUI.FrameMover.ShowPreview(value)							
			end,
			default = AUI.FrameMover.IsPreviewShowing(),
			width = "full",
		},		
		{
			type = "header",
		},				
		{
			type = "button",
			name = AUI.L10n.GetString("reset_to_default_position"),
			tooltip = AUI.L10n.GetString("reset_to_default_position_tooltip"),
			func = function() AUI.FrameMover.SetToDefaultPosition() end,
		},		
	}
	
	return optionsTable
end

local function CreateMenu()
	local optionsTable = {}

	local generalTextOptions = GetGeneralBoxOptions()
	for i = 1 , #generalTextOptions do 
		table.insert(optionsTable, generalTextOptions[i]) 
	end		

	LAM:RegisterOptionControls("AUI_Menu_FrameMover", optionsTable)
end

local function LoadSettings()
	if AUI.MainSettings.modul_FrameMover_account_wide then
		AUI.Settings.FrameMover = ZO_SavedVars:NewAccountWide("AUI_Control_Mover", 3, nil, GetDefaultSettings())
	else
		AUI.Settings.FrameMover = ZO_SavedVars:New("AUI_Control_Mover", 23, nil, GetDefaultSettings())
	end	
end

function AUI.FrameMover.SetMenuData()
	if isLoaded then
		return
	end
	
	local panelData = {
		type = "panel",
		name = AUI_MAIN_NAME .. " (" .. AUI.L10n.GetString("frame_mover_module_name") .. ")",
		displayName = "|cFFFFB0" .. AUI_MAIN_NAME .. " (" .. AUI.L10n.GetString("frame_mover_module_name") .. ")",
		author = AUI_TXT_COLOR_AUTHOR:Colorize(AUI_FrameMover_AUTHOR),
		version = AUI_TXT_COLOR_VERSION:Colorize(AUI_FrameMover_VERSION),
		slashCommand = "/auiframemover",
		registerForRefresh = true,
		registerForDefaults = true,
	}

	LoadSettings()
	CreateMenu()
	
	LAM:RegisterAddonPanel("AUI_Menu_FrameMover", panelData)
	
	isLoaded = true
end
