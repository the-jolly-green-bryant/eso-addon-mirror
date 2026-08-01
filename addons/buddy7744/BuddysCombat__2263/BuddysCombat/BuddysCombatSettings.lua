function BuddysCombat:CreateSettingsWindow()


local LAM2 = LibStub("LibAddonMenu-2.0")
local panelData =
{
	type                = "panel",
	name                = "Buddys Combat",
	displayName         = "|c26C52B Buddys|r Combat",
	author              = "Buddy7744",
	version 			= self.version,
	registerForRefresh  = true,
	registerForDefaults = true
}
LAM2:RegisterAddonPanel("BuddysCombatPanel", panelData)
 local optionsData =
{
	{
		type = "checkbox",
		name = "Activate to move",
		warning = "You need to deativate manually.",
		getFunc = function() return self.savedVariables.showing end,
		setFunc = function(value) self.savedVariables.showing = value ; BuddysCombat:HideCombatMessage() end,
		width = "full"
	},
	{
		type = "editbox",
		name = "Fight text",
		getFunc = function() return self.savedVariables.text end,
		setFunc = function(value) self.savedVariables.text = value BuddysCombat:SetText() end,
	},
	{
		type = "slider",
		name = "Fight frame size",
		min = 0, max = 2, step = 0.05,
		getFunc = function() return self.savedVariables.fontScale end,
		setFunc = function(value) self.savedVariables.fontScale = value; BuddysCombat:SetFont() end,
		width = "full"
	},
	{
		type = "colorpicker",
		name = "Color of the fight text",
		getFunc = function() return self.savedVariables.fontColor.r, self.savedVariables.fontColor.g, self.savedVariables.fontColor.b end,
		setFunc = function(r,g,b,a) self.savedVariables.fontColor = { ["r"] = r, ["g"] = g, ["b"] = b }; BuddysCombat:SetColor() end,
	},
	
}
	LAM2:RegisterOptionControls("BuddysCombatPanel", optionsData)
end


function BuddysCombat:CheckDefaultSettingsAreApplied()
	if (self.savedVariables.fontColor == nil) then
		self.savedVariables.fontColor = self.DefaultSettings.fontColor;
	end
	if (self.savedVariables.doneColor == nil) then
		self.savedVariables.doneColor = self.DefaultSettings.doneColor;
	end
	if (self.savedVariables.fontScale == nil) then
		self.savedVariables.fontScale = self.DefaultSettings.fontScale;
	end
	if (self.savedVariables.transparency == nil) then
		self.savedVariables.transparency = self.DefaultSettings.transparency;
	end
	if (self.savedVariables.showing == nil) then 
		self.savedVariables.showing = self.DefaultSettings.showing;
	end
	if (self.savedVariables.text == nil) then 
		self.savedVariables.text = self.DefaultSettings.text;
	end
end