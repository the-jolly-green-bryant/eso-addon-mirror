AUI.Settings.Questtracker = {}

local LAM = LibStub("LibAddonMenu-2.0")
local LMP = LibStub("LibMediaProvider-1.0")

local isLoaded = false
local isPreviewShowing = false

AUI_QUESTTRACKER_WIDTH_MIN_SIZE = 250
AUI_QUESTTRACKER_WIDTH_MAX_SIZE = 600
AUI_QUESTTRACKER_MAX_HEIGHT_MIN_SIZE = 151
AUI_QUESTTRACKER_MAX_HEIGHT_MAX_SIZE = 800
AUI_QUESTTRACKER_MIN_FONT_SIZE = 15
AUI_QUESTTRACKER_MAX_FONT_SIZE = 36

local function GetDefaultSettings()
	local lang = GetCVar("Language.2")
	local defaultTimePrecisionTwelfeHour = true

	if lang == "de" or lang == "fr" then
		defaultTimePrecisionTwelfeHour = false
	end

	local defaultSettings =
	{
		enable = true,
		width = 278,
		maxHeight= 698, 
		anchor = 
		{
			point = 9,
			relativePoint = 0,
			offsetX = 0,
			offsetY = 300
		},
		lock_window = false,
		showBackground = false,
		showTime = true,
		useTimePrecisionTwelfeHour = defaultTimePrecisionTwelfeHour,
		isExpandedConditions = false,
		expandMode = 0,
		font_size = 18,
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
			getFunc = function() return AUI.MainSettings.modul_questtacker_account_wide end,
			setFunc = function(value)
				AUI.MainSettings.modul_questtacker_account_wide = value
				ReloadUI()
			end,
			default = true,
			width = "full",
			warning = AUI.L10n.GetString("reloadui_warning_tooltip"),
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("lock_window"),
			tooltip = AUI.L10n.GetString("lock_window_tooltip"),
			getFunc = function() return AUI.Settings.Questtracker.lock_window end,
			setFunc = function(value)
				AUI.Settings.Questtracker.lock_window = value
			end,
			default = GetDefaultSettings().lock_window,
			width = "full",
		},				
		{
			type = "checkbox",
			name = AUI.L10n.GetString("preview"),
			tooltip = AUI.L10n.GetString("preview_tooltip"),
			getFunc = function() return isPreviewShowing end,
			setFunc = function(value)
				if value == true then
					AUI.Questtracker.Show()
				else
					AUI.Questtracker.Hide()
				end
				
				isPreviewShowing = value
			end,
			default = isPreviewShowing,
			width = "full",
		},				
	}
	
	return optionsTable
end

local function GetQuestBoxOptions()
	local optionsTable = {
		{
			type = "header",
			name = AUI_TXT_COLOR_HEADER:Colorize(AUI.L10n.GetString("quest_tracker_module_name"))
		},
		{
			type = "slider",
			name = AUI.L10n.GetString("width"),
			tooltip = AUI.L10n.GetString("width_tooltip"),
			min = AUI_QUESTTRACKER_WIDTH_MIN_SIZE,
			max = AUI_QUESTTRACKER_WIDTH_MAX_SIZE,
			step = 1,
			getFunc = function() return AUI.Settings.Questtracker.width end,
			setFunc = function(value) 
				AUI.Settings.Questtracker.width = value						
				AUI.Questtracker.UpdateUI()
			end,
			default = GetDefaultSettings().width,
			width = "half",			
		},	
		{
			type = "slider",
			name = AUI.L10n.GetString("max_height"),
			tooltip = AUI.L10n.GetString("max_height_tooltip"),
			min = AUI_QUESTTRACKER_MAX_HEIGHT_MIN_SIZE,
			max = AUI_QUESTTRACKER_MAX_HEIGHT_MAX_SIZE,
			step = 1,
			getFunc = function() return AUI.Settings.Questtracker.maxHeight end,
			setFunc = function(value) 
				AUI.Settings.Questtracker.maxHeight = value
				AUI.Questtracker.UpdateUI()
			end,
			default = GetDefaultSettings().maxHeight,
			width = "half",			
		},	
		{
			type = "slider",
			name = AUI.L10n.GetString("font_size"),
			name = AUI.L10n.GetString("font_size_tooltip"),
			min = AUI_QUESTTRACKER_MIN_FONT_SIZE,
			max = AUI_QUESTTRACKER_MAX_FONT_SIZE,
			step = 1,
			getFunc = function() return AUI.Settings.Questtracker.font_size end,
			setFunc = function(value) 
				AUI.Settings.Questtracker.font_size = value
				AUI.Questtracker.UpdateUI()
			end,
			default = GetDefaultSettings().font_size,
			width = "full",
		},				
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_background"),
			getFunc = function() return AUI.Settings.Questtracker.showBackground end,
			setFunc = function(value)
				AUI.Settings.Questtracker.showBackground = value
				AUI.Questtracker.UpdateUI()
			end,
			default = GetDefaultSettings().showBackground,
			width = "full",
		},	
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_time"),
			getFunc = function() return AUI.Settings.Questtracker.showTime end,
			setFunc = function(value)
				AUI.Settings.Questtracker.showTime = value
				AUI.Questtracker.UpdateUI()
			end,
			default = GetDefaultSettings().showTime,
			width = "full",
		},	
		{
			type = "checkbox",
			name = AUI.L10n.GetString("time_precision_twelfe_hour"),
			getFunc = function() return AUI.Settings.Questtracker.useTimePrecisionTwelfeHour end,
			setFunc = function(value)
				AUI.Settings.Questtracker.useTimePrecisionTwelfeHour = value
				AUI.Questtracker.UpdateUI()
			end,
			default = GetDefaultSettings().useTimePrecisionTwelfeHour,
			width = "full",
		},			
	}
	
	return optionsTable
end

function AUI.Questtracker.CreateMenu()
	local optionsTable = {}

	local generalTextOptions = GetGeneralBoxOptions()
	for i = 1 , #generalTextOptions do 
		table.insert(optionsTable, generalTextOptions[i]) 
	end		
	
	local questtrackerTextOptions = GetQuestBoxOptions()
	for i = 1 , #questtrackerTextOptions do 
		table.insert(optionsTable, questtrackerTextOptions[i]) 
	end		
	
	LAM:RegisterOptionControls("AUI_Menu_Quests", optionsTable)
end

local function LoadSettings()
	if AUI.MainSettings.modul_questtacker_account_wide then
		AUI.Settings.Questtracker = ZO_SavedVars:NewAccountWide("AUI_Quests", 1, nil, GetDefaultSettings())
	else
		AUI.Settings.Questtracker = ZO_SavedVars:New("AUI_Quests", 1, nil, GetDefaultSettings())
	end	
end

function AUI.Questtracker.SetMenuData()
	if isLoaded then
		return
	end
	
	local panelData =
	{
		type = "panel",
		name = AUI_MAIN_NAME .. " (" .. AUI.L10n.GetString("quest_tracker_module_name") .. ")",
		displayName = "|cFFFFB0" .. AUI_MAIN_NAME .. " (" .. AUI.L10n.GetString("quest_tracker_module_name") .. ")",
		author = AUI_TXT_COLOR_AUTHOR:Colorize(AUI_QUESTTRACKER_AUTHOR),
		version = AUI_TXT_COLOR_VERSION:Colorize(AUI_QUESTTRACKER_VERSION),
		slashCommand = "/auiquesttracker",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	
	LoadSettings()
	AUI.Questtracker.CreateMenu()
	
	LAM:RegisterAddonPanel("AUI_Menu_Quests", panelData)
	
	isLoaded = true
end
