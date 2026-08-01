AUI.Settings.Templates = {}

local function GetDefaultSettings()
	local defaultSettings =
	{
		Attributes = 
		{
			["Player"] = "AUI", 
			["Target"] = "AUI", 
			["Group"] = "AUI_Tactical", 
			["Raid"] = "AUI_Tactical", 
			["Boss"] = "AUI_Tactical",
			["Companion"] = "AUI_Tactical"
		},
		
		["Buffs"] = "AUI_Tactical"
	}
	
	return defaultSettings
end

function AUI.LoadTemplateSettings()
	if AUI.Settings.MainMenu.modul_unit_frames_account_wide then
		AUI.Settings.Templates = ZO_SavedVars:NewAccountWide("AUI_Templates", 10, nil, GetDefaultSettings())
	else
		AUI.Settings.Templates = ZO_SavedVars:New("AUI_Templates", 10, nil, GetDefaultSettings())
	end	
end