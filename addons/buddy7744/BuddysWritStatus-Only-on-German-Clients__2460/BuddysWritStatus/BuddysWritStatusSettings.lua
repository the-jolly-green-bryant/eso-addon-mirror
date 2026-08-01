---------------------------------------------------------------------------------------------------------
-- S E T T I N G S
---------------------------------------------------------------------------------------------------------
function BuddysWritStatusAddon:CreateSettingsWindow()
	local LAM2 = LibStub("LibAddonMenu-2.0")
	local panelData =
	{
		type                = "panel",
		name                = self.Name,
		displayName 		= "Buddys Writ Status",
		author				= "Buddy7744, Original Author |c28b712PhaeroX|r",
		version             = self.Version,
		registerForRefresh  = true,
		registerForDefaults = true
	}

	LAM2:RegisterAddonPanel(self.Name, panelData)
	local optionsData =
	{
		{
			type = "checkbox",
			name = "Interface",
			getFunc = function() return self.savedVariables.showing end,
			setFunc = function(value) self.savedVariables.showing = value ; BuddysWritStatusAddon:UpdateWritStatus() end,
			width = "full"
		},
		{
			type = "colorpicker",
			name = "Ausstehend",
			tooltip = "Die Farbe für offene Quests",
			getFunc = function() return self.savedVariables.fontColor.r, self.savedVariables.fontColor.g, self.savedVariables.fontColor.b end,
			setFunc = function(r,g,b,a) self.savedVariables.fontColor = { ["r"] = r, ["g"] = g, ["b"] = b }; BuddysWritStatusAddon:UpdateWritStatus() end,
			default = { r = 1, g = 0, b = 0 }
		},
		{
			type = "colorpicker",
			name = "Erledigt",
			tooltip = "Die Farbe für erledigte Quests",
			getFunc = function() return self.savedVariables.doneColor.r, self.savedVariables.doneColor.g, self.savedVariables.doneColor.b end,
			setFunc = function(r,g,b,a) self.savedVariables.doneColor = { ["r"] = r, ["g"] = g, ["b"] = b }; BuddysWritStatusAddon:UpdateWritStatus() end,	
			default = { r = 0, g = 1, b = 0 }
		  
		},
		{
			type = "slider",
			name = "Größe",
			min = 0, max = 2, step = 0.05,
			getFunc = function() return self.savedVariables.fontScale end,
			setFunc = function(value) self.savedVariables.fontScale = value; BuddysWritStatusAddon:UpdateWritStatus() end,
			disabled = function() return false end,
			width = "full",
			default = 1
		},
		{
			type = "slider",
			name = "Hintergrund Transparenz",
			min = 0, max = 1, step = 0.1,
			getFunc = function() return self.savedVariables.transparency end,
			setFunc = function(value) self.savedVariables.transparency = value; BuddysWritStatusAddon:UpdateWritStatus() end,
			width = "full",
			default = 0
		},
	}

  LAM2:RegisterOptionControls(self.Name, optionsData)
end

function BuddysWritStatusAddon:CheckDefaultSettingsAreApplied()
	if (self.savedVariables.debug == nil) then
		self.savedVariables.debug = self.DefaultSettings.debug;
	end
	if (self.savedVariables.left == nil) then
		self.savedVariables.left = self.DefaultSettings.left
	end
	if (self.savedVariables.top == nil) then
		self.savedVariables.top = self.DefaultSettings.top
	end
	if (self.savedVariables.fontColor == nil) then
		self.savedVariables.fontColor = self.DefaultSettings.fontColor
	end
	if (self.savedVariables.doneColor == nil) then
		self.savedVariables.doneColor = self.DefaultSettings.doneColor
	end
	if (self.savedVariables.fontScale == nil) then
		self.savedVariables.fontScale = self.DefaultSettings.fontScale
	end
	if (self.savedVariables.transparency == nil) then
		self.savedVariables.transparency = self.DefaultSettings.transparency
	end
	if (self.savedVariables.showing == nil) then
		self.savedVariables.showing = self.DefaultSettings.showing
	end
	if (self.savedVariables.showWritStatus == nil) then
		self.savedVariables.showWritStatus = self.DefaultSettings.showWritStatus
	end
	if (self.savedVariables.showWritStatusCondensed == nil) then
		self.savedVariables.showWritStatusCondensed = self.DefaultSettings.showWritStatusCondensed
	end
end