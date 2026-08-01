AUI.Settings.Templates = {}

local defaultTemplateSettings =
{
	attributes = "AUI",
	bufss = 	 "AUI"
}

function AUI.LoadTemplateSettings()
	if AUI.MainSettings.modul_attributes_account_wide then
		AUI.Settings.Template = ZO_SavedVars:NewAccountWide("AUI_Templates", 1, nil, defaultTemplateSettings)
	else
		AUI.Settings.Template = ZO_SavedVars:New("AUI_Templates", 1, nil, defaultTemplateSettings)
	end		
end