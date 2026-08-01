local LAM = LibAddonMenu2
local LMP = LibMediaProvider

Recount.SettingsMenu = {
	name = "Recount_SettingsMenu",
}

function Recount.SettingsMenu.Initialize()
	local panelData = {
		type = "panel",
		name = Recount.name,
		displayName = Recount.name.." Settings",
		author = "lwndow, Ferather, Shadow-Fighter, and others",
		version = "0.7.6",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	LAM:RegisterAddonPanel(Recount.SettingsMenu.name, panelData)

	Recount.SettingsMenu:Setup()
end

function Recount.SettingsMenu:SetColor( setting, r, g, b, a )
	Recount.settings[setting].r = r
	Recount.settings[setting].g = g
	Recount.settings[setting].b = b
	Recount.settings[setting].a = a
	Recount.FitUIElements()
end

function Recount.SettingsMenu:GetFont()
    local str = '%s|%d'
    if ( Recount.settings.progressBarFontOutline ~= 'none' ) then
        str = str .. '|%s'
    end

    return string.format( str, LMP:Fetch( 'font', Recount.settings.progressBarFontFace ), Recount.settings.progressBarFontSize, Recount.settings.progressBarFontOutline )
end

function Recount.SettingsMenu:Setup()
	local optionsData = {
		{
			type = "header",
			name = "Version "  .. Recount.versionString,
			width = "full",
		},
		{
			type = "checkbox",
			name = "Use Account-Wide Settings",
			tooltip = "Recount will use the same settings for all characters, reloads UI on click",
			getFunc = function() return RecountSettings.Default[GetDisplayName()]['$AccountWide'].useAccountWide end,
			setFunc = function( value ) RecountSettings.Default[GetDisplayName()]['$AccountWide'].useAccountWide = value ReloadUI() end,
			default = Recount.settings.useAccountWide,
		},
		{
			type = "checkbox",
			name = "Disable All Auto Show/Hide",
			tooltip = "Recount UI does not auto toggle itself, but only through command shortcuts",
			getFunc = function() return Recount.settings.onlyUseKey end,
			setFunc = function( value ) Recount.settings.onlyUseKey = value end,
			default = Recount.settingsDefaults.onlyUseKey,
		},
		{
			type = "checkbox",
			name = "Minimize In Combat",
			tooltip = "Minimize the main window while in combat",
			getFunc = function() return Recount.settings.minimizeDuringCombat end,
			setFunc = function( value ) Recount.settings.minimizeDuringCombat = value end,
			default = Recount.settingsDefaults.minimizeDuringCombat,
		},
		{
			type = "checkbox",
			name = "Hide While Out Of Combat",
			tooltip = "Hide the main window while out of combat",
			getFunc = function() return Recount.settings.hideOutOfCombat end,
			setFunc = function( value ) Recount.settings.hideOutOfCombat = value Recount.settings.wndMain.isVisible = not Recount.settings.wndMain.isVisible end,
			default = Recount.settingsDefaults.hideOutOfCombat,
		},
		{
			type = "slider",
			name = "OOC Hide Delay",
			tooltip = "Adjust the time the main window will be hidden when out of combat",
			min = 1,
			max = 30,
			step = 1,
			getFunc = function() return Recount.settings.hideOutOfCombatDelayInSeconds end,
			setFunc = function( value ) Recount.settings.hideOutOfCombatDelayInSeconds = value end,
			default = Recount.settingsDefaults.hideOutOfCombatDelayInSeconds,
		},
		{
			type = "checkbox",
			name = "Autoswitch Mode",
			tooltip = "Autoswitch between log mode and damage overview after combat",
			getFunc = function() return Recount.settings.autoSwitchMode end,
			setFunc = function( value ) Recount.settings.autoSwitchMode = value end,
			default = Recount.settingsDefaults.autoSwitchMode,
		},
		{
			type = "checkbox",
			name = "Suspend Data Collection While Hidden",
			tooltip = "Do not continue to collect data while the main window is hidden",
			getFunc = function() return Recount.settings.suspendDataCollectionWhileHidden end,
			setFunc = function( value ) Recount.settings.suspendDataCollectionWhileHidden = value end,
			default = Recount.settingsDefaults.suspendDataCollectionWhileHidden,
		},
		{
			type = "checkbox",
			name = "Count Deflected Damage",
			tooltip = "Count deflected (parried, immune, reflected) damage as normal damage done",
			getFunc = function() return Recount.settings.countDeflectedDmg end,
			setFunc = function( value ) Recount.settings.countDeflectedDmg = value end,
			default = Recount.settingsDefaults.countDeflectedDmg,
		},
		{
			type = "checkbox",
			name = "Show Skills Details",
			tooltip = "Show hit number and critical strike statistics in the skill bar",
			getFunc = function() return Recount.settings.showSkillDetails end,
			setFunc = function( value ) Recount.settings.showSkillDetails = value end,
			default = Recount.settingsDefaults.showSkillDetails,
		},
		{
			type = "slider",
			name = "Damage Bar Height",
			tooltip = "Height of the damage bars",
			min = 10,
			max = 40,
			step = 1,
			getFunc = function() return Recount.settings.progressBarHeight end,
			setFunc = function( value ) Recount.settings.progressBarHeight = value Recount.FitUIElements() end,
			default = Recount.settingsDefaults.progressBarHeight,
		},
		{
			type = "fontblock",
			name = "Damage Bar Font",
			tooltip = "Damage bar font (color is currently ignored)",
			getFace = function() return Recount.settings.progressBarFontFace end,
			getSize = function() return Recount.settings.progressBarFontSize end,
			getOutline = function() return Recount.settings.progressBarFontOutline end,
			getColor = function() return Recount.settings.progressBarFontColor.r, Recount.settings.progressBarFontColor.g, Recount.settings.progressBarFontColor.b, Recount.settings.progressBarFontColor.a end,
			setFace = function( value ) Recount.settings.progressBarFontFace = value Recount.FitUIElements() end,
			setSize = function( value ) Recount.settings.progressBarFontSize = value Recount.FitUIElements() end,
			setOutline = function( value ) Recount.settings.progressBarFontOutline = value Recount.FitUIElements() end,
			setColor = function( r, g, b, a ) Recount.SettingsMenu:SetColor( 'progressBarFontColor', r, g, b, a ); Recount.FitUIElements() end,
			default = {
				face = Recount.settingsDefaults.progressBarFontFace,
				size = Recount.settingsDefaults.progressBarFontSize,
				outline = Recount.settingsDefaults.progressBarFontOutline,
				color = Recount.settingsDefaults.progressBarFontColor,
			},
		},
		{
			type = "colorpicker",
			name = "Damage Bar Color",
			tooltip = "Damage bar color",
			getFunc = function() return Recount.settings.progressBarColor.r, Recount.settings.progressBarColor.g, Recount.settings.progressBarColor.b, Recount.settings.progressBarColor.a end,
			setFunc = function( r, g, b, a ) Recount.SettingsMenu:SetColor( 'progressBarColor', r, g, b, a ) end,
			default = {r = Recount.settingsDefaults.progressBarColor.r, g = Recount.settingsDefaults.progressBarColor.g, b = Recount.settingsDefaults.progressBarColor.b, a = Recount.settingsDefaults.progressBarColor.a},
		},
		{
			type = "editbox",
			name = "Periodic Tick Tag",
			tooltip = "How periodic ticks are shown in the combat log",
			getFunc = function() return Recount.settings.dotTag end,
			setFunc = function( value ) Recount.settings.dotTag = value end,
			isMultiline = false,
			default = Recount.settingsDefaults.dotTag,
		},
		{
			type = "editbox",
			name = "Critical Strike Tag",
			tooltip = "How critical strikes are shown in the combat log",
			getFunc = function() return Recount.settings.critTag end,
			setFunc = function( value ) Recount.settings.critTag = value end,
			isMultiline = false,
			default = Recount.settingsDefaults.critTag,
		},
		{
			type = "editbox",
			name = "Ignore Damage Logging",
			tooltip = "Damage below or equal to this value will not show up in the log, but will count as DPS",
			getFunc = function() return Recount.settings.minDPSLogValue end,
			setFunc = function( value ) Recount.settings.minDPSLogValue = tonumber(value) or 0 end,
			isMultiline = false,
			default = Recount.settingsDefaults.minDPSLogValue,
		},
		{
			type = "editbox",
			name = "Ignore Healing Logging",
			tooltip = "Heals below or equal to this value will not show up in the log, but will count as HPS",
			getFunc = function() return Recount.settings.minHPSLogValue end,
			setFunc = function( value ) Recount.settings.minHPSLogValue = tonumber(value) or 0 end,
			isMultiline = false,
			default = Recount.settingsDefaults.minHPSLogValue,
		},
		{
			type = "editbox",
			name = "Ignore Damage Done",
			tooltip = "Damage below or equal to this value will not be tracked or logged",
			getFunc = function() return Recount.settings.damageIgnore end,
			setFunc = function( value ) Recount.settings.damageIgnore = tonumber(value) or 0 end,
			isMultiline = false,
			default = Recount.settingsDefaults.damageIgnore,
		},
		{
			type = "editbox",
			name = "Ignore Healing Done",
			tooltip = "Healing below or equal to this value will not be tracked or logged",
			getFunc = function() return Recount.settings.healIgnore end,
			setFunc = function( value ) Recount.settings.healIgnore = tonumber(value) or 0 end,
			isMultiline = false,
			default = Recount.settingsDefaults.healIgnore,
		},
	}

	LAM:RegisterOptionControls(Recount.SettingsMenu.name, optionsData)
end
