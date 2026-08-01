local addon = {
	name = "AdvancedGrassToggle",
	displayName = "|c136d15Advanced|r |c138510Grass|r |c41980aToggle|r",
	version = "1.1.0",
	author = "Valve",
	accountWide = true,
	updateByAGT = false,
	activeSV = nil,
	defaults = {
		grassEnabled = 1,
		grassQuality = 4,
		characterSettings = {}
	}
}

function addon.ProcessGrassChange(settingSystemType, settingId, settingValue)
	if (settingSystemType ~= SETTING_TYPE_GRAPHICS or settingId ~= GRAPHICS_SETTING_CLUTTER_2D_QUALITY) then return end
	if not addon.updateByAGT then
		if tonumber(settingValue) > 0 then
			addon.activeSV.grassQuality = tonumber(settingValue)
		end
		addon.activeSV.grassEnabled = math.min(1, tonumber(settingValue))
	else
		addon.updateByAGT = false
	end
end

local function OnAddonLoaded(event, name)
	if name ~= addon.name then return end
	EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)
	addon:Initialise()
end

function addon:Initialise()
	if not LibAddonMenu2 then return end
	local LAM2 = LibAddonMenu2
	self.av = ZO_SavedVars:NewAccountWide(self.name .. "_dat", 1, nil, self.defaults)
	self.activeCharacterId = GetCurrentCharacterId()
	if self.av.characterSettings[self.activeCharacterId] then
		self.accountWide = false
		self.cv = ZO_SavedVars:NewCharacterIdSettings(self.name .. "_dat", 1, nil, self.defaults)
	end

	local panelData = {
		type = "panel",
		name = self.name,
		displayName = self.displayName,
		author = self.author,
		version = self.version,
		registerForRefresh = true,
		registerForDefaults = true,
		website = "https://www.esoui.com/downloads/info3577-AdvancedGrassToggle.html"
	}
	LAM2:RegisterAddonPanel(self.name, panelData)
	-- Set saved variables reference to account wide or character specific depending on what's enabled
	self.activeSV = self.accountWide and self.av or self.cv
	local optionsTable = {}
	optionsTable[#optionsTable+1] = {
		type = "header",
		name = GetString(SI_AGT_DESC_HEADER)
	}
	optionsTable[#optionsTable+1] = {
		type = "description",
		text = GetString(SI_AGT_ADDON_DESC)
	}
	optionsTable[#optionsTable+1] = {
		type = "header",
		name = GetString(SI_AGT_SAVE_SETTINGS)
	}
	optionsTable[#optionsTable+1] = {
		type = "checkbox",
		name = GetString(SI_AGT_ACCOUNT_WIDE_SETTINGS),
		tooltip = GetString(SI_AGT_ACCOUNT_WIDE_SETTINGS_TOOLTIP),
		getFunc = function() return self.accountWide end,
		setFunc = function() self:SwitchSavedVariables() end
	}
	optionsTable[#optionsTable+1] = {
		type = "header",
		name = GetString(SI_AGT_SETTINGS)
	}
	optionsTable[#optionsTable+1] =
	{
		type = "description",
		text = GetString(SI_AGT_GRASS_QUALITY_DESC),
	}
	optionsTable[#optionsTable+1] = {
		type = "slider",
		name = GetString(SI_AGT_GRASS_QUALITY_SETTING),
		tooltip = GetString(SI_AGT_GRASS_QUALITY_SETTING_TOOLTIP),
		min = 1,
		max = 8,
		getFunc = function() return self.activeSV.grassQuality end,
		setFunc = function(value) addon.LoadGrassQuality(value) end,
		default = self.defaults.grassQuality
	}
	optionsTable[#optionsTable+1] = {
		type = "checkbox",
		name = GetString(SI_AGT_GRASS_ENABLED_SETTING),
		tooltip = GetString(SI_AGT_GRASS_ENABLED_SETTING_TOOLTIP),
		getFunc = function() return self.activeSV.grassEnabled == 1 end,
		setFunc = function() addon.ToggleGrass() end
	}
	LAM2:RegisterOptionControls(self.name, optionsTable)
	-- The interface setting changed doesn't trigger for non-interface settings i.e. grass
	-- so let's hook into the SetSetting function to update the saved variables on setting change
	ZO_PreHook(_G, "SetSetting", addon.ProcessGrassChange)
	addon.LoadGrassQuality(self.activeSV.grassQuality)
end

function addon:SwitchSavedVariables()
	if self.accountWide then
		self.av.characterSettings[self.activeCharacterId] = true
		self.cv = self.cv or ZO_SavedVars:NewCharacterIdSettings(self.name .. "_dat", 1, nil, self.defaults)
	else
		self.av.characterSettings[self.activeCharacterId] = nil
	end
	self.accountWide = not self.accountWide
	self.activeSV = self.accountWide and self.av or self.cv
	addon.LoadGrassQuality(self.activeSV.grassQuality)
end

function addon.LoadGrassQuality(quality)
	if not quality or not tonumber(quality) or tonumber(quality) < 1 then return end
	addon.updateByAGT = true
	addon.activeSV.grassQuality = math.min(quality, 8)
	-- Don't allow stupidly high quality values as the game will allow it and then crash if someone enters something stupid
	SetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_CLUTTER_2D_QUALITY, addon.activeSV.grassEnabled == 1 and addon.activeSV.grassQuality or 0)
end

function addon.ToggleGrass()
	addon.updateByAGT = true
	addon.activeSV.grassEnabled = addon.activeSV.grassEnabled == 0 and 1 or 0
	SetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_CLUTTER_2D_QUALITY, addon.activeSV.grassEnabled == 1 and addon.activeSV.grassQuality or 0)
end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)

ADVANCED_GRASS_TOGGLE = addon

SLASH_COMMANDS["/grass"] = addon.ToggleGrass
SLASH_COMMANDS["/grassquality"] = addon.LoadGrassQuality