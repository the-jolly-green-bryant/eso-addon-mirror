local CPR2 = ChampionPointRespecV2 or {}
local LAM = LibAddonMenu2

CPR2.settings = {}

CPR2.settings["panelData"] = 
{
	type = "panel",
	name = "Champion Point Respec",
	author = "iRogue32",
	version = "2.1.0",
	slashCommand = "/cprsettings"
	
}

CPR2.settings["optionsData"] = 
{
	[1] = {
		type = "checkbox",
		name = "Display Gold Cost Warning",
		getFunc = function() return CPR2.savedVariables["displayWarning"] end,
		setFunc = function(value) CPR2.savedVariables["displayWarning"] = value end,
		width = "full"
	},
	[2] = {
		type = "checkbox",
		name = "Open UI with CP Window",
		getFunc = function() return CPR2.savedVariables["openUIWithCPWindow"] end,
		setFunc = function(value) CPR2.savedVariables["openUIWithCPWindow"] = value end,
		width = "full",
		requiresReload = true
	}
}

function CPR2.InitializeAddonSettingsPanel()
	LAM:RegisterAddonPanel(CPR2.name.."AddonSettings", CPR2.settings["panelData"])
	LAM:RegisterOptionControls(CPR2.name.."AddonSettings", CPR2.settings["optionsData"])
end