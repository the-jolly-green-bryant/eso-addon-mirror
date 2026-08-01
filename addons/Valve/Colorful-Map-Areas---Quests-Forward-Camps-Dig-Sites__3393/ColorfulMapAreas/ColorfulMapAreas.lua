local addon = {
	name = "ColorfulMapAreas",
	displayName = "|cff5050Colorful |c50ff50Map |c5050ffAreas|r",
	version = "1.2.0",
	author = "Valve",
	accountWide = true,
	activeSV = nil,
	defaults = {
		trackedAreaColor = {r = 0.5, g = 0.8, b = 0.8},
		areaColor = {r = 1, g = 1, b = 1},
		useTrackedDigSiteQuality = false,
		trackedDigSiteColor = {r = 1, g = 1, b = 1},
		digSiteColor = {r = 0.5, g = 0.8, b = 0.8},
		digSiteBorderColor = {r = 0.1765, g = 1, b = 0.9725},
		digSiteDrawLevel = 6,
		questAreaDrawLevel = 6,
		characterSettings = {}
	}
}

local function OnAddonLoaded(_, name)
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
		website = "https://www.esoui.com/downloads/info3393-ColorfulMapAreas.html"
	}
	LAM2:RegisterAddonPanel(self.name, panelData)

	-- Set saved variables reference to account wide or character specific depending on what's enabled
	self.activeSV = self.accountWide and self.av or self.cv
	local optionsTable = {}
	optionsTable[#optionsTable+1] = {
			type = "header",
			name = GetString(SI_CMA_DESC_HEADER)
	}
	optionsTable[#optionsTable+1] = {
		type = "description",
		text = GetString(SI_CMA_ADDON_DESC)
	}
	optionsTable[#optionsTable+1] = {
		type = "header",
		name = GetString(SI_CMA_SAVE_SETTINGS)
	}
	optionsTable[#optionsTable+1] = {
		type = "checkbox",
		name = GetString(SI_CMA_ACCOUNT_WIDE_SETTINGS),
		tooltip = GetString(SI_CMA_ACCOUNT_WIDE_SETTINGS_TOOLTIP),
		getFunc = function() return self.accountWide end,
		setFunc = function() self:SwitchSavedVariables() end
	}
	optionsTable[#optionsTable+1] = {
		type = "header",
		name = GetString(SI_CMA_AREA_HEADER)
	}
	optionsTable[#optionsTable+1] = {
		type = "colorpicker",
		name = GetString(SI_CMA_TRACKED_AREA_COLOR),
		tooltip = GetString(SI_CMA_TRACKED_AREA_COLOR_TOOLTIP),
		getFunc = function() return self:GetColorValues(self.activeSV.trackedAreaColor) end,
		setFunc = function(r, g, b)
			self:SetColor(self.activeSV.trackedAreaColor, r, g, b)
			self:SetTrackedAreaColor(self.activeSV.trackedAreaColor)
		end,
		width = "full",
		default = self.defaults.trackedAreaColor
	}
	optionsTable[#optionsTable+1] = {
		type = "colorpicker",
		name = GetString(SI_CMA_GENERIC_AREA_COLOR),
		tooltip = GetString(SI_CMA_GENERIC_AREA_COLOR_TOOLTIP),
		getFunc = function() return self:GetColorValues(self.activeSV.areaColor) end,
		setFunc = function(r, g, b)
			self:SetColor(self.activeSV.areaColor, r, g, b)
			self:SetAreaColor(self.activeSV.areaColor)
		end,
		width = "full",
		default = self.defaults.areaColor
	}
	optionsTable[#optionsTable+1] = {
		type = "slider",
		name = GetString(SI_CMA_QUEST_AREA_LEVEL),
		tooltip = GetString(SI_CMA_QUEST_AREA_LEVEL_TOOLTIP),
		min = 1,
		max = 170,
		getFunc = function() return self.activeSV.questAreaDrawLevel end,
		setFunc = function(value) self.activeSV.questAreaDrawLevel = value end,
		width = "full",
		default = self.defaults.questAreaDrawLevel
	}
	optionsTable[#optionsTable+1] = {
		type = "header",
		name = GetString(SI_CMA_DIG_SITE_HEADER)
	}
	optionsTable[#optionsTable+1] = {
		type = "checkbox",
		name = GetString(SI_CMA_USE_TRACKED_DIGSITE_QUALITY),
		tooltip = GetString(SI_CMA_USE_TRACKED_DIGSITE_QUALITY_TOOLTIP),
		getFunc = function() return self.activeSV.useTrackedDigSiteQuality end,
		setFunc = function(value)
			self.activeSV.useTrackedDigSiteQuality = value
			if self.activeSV.useTrackedDigSiteQuality then
				self:SetTrackedDigSiteQualityColor(GetTrackedAntiquityId())
			else
				self:SetTrackedDigSiteColor(self.activeSV.trackedDigSiteColor)
			end
		end,
		default = self.defaults.useTrackedDigSiteQuality
	}
	optionsTable[#optionsTable+1] = {
		type = "colorpicker",
		name = GetString(SI_CMA_TRACKED_DIG_SITE_COLOR),
		tooltip = GetString(SI_CMA_TRACKED_DIG_SITE_COLOR_TOOLTIP),
		getFunc = function() return self:GetColorValues(self.activeSV.trackedDigSiteColor) end,
		setFunc = function(r, g, b)
			self:SetColor(self.activeSV.trackedDigSiteColor, r, g, b)
			self:SetTrackedDigSiteColor(self.activeSV.trackedDigSiteColor)
		end,
		disabled = function() return self.activeSV.useTrackedDigSiteQuality end,
		width = "full",
		default = self.defaults.trackedDigSiteColor
	}
	optionsTable[#optionsTable+1] = {
		type = "colorpicker",
		name = GetString(SI_CMA_DIG_SITE_COLOR),
		tooltip = GetString(SI_CMA_DIG_SITE_COLOR_TOOLTIP),
		getFunc = function() return self:GetColorValues(self.activeSV.digSiteColor) end,
		setFunc = function(r, g, b)
			self:SetColor(self.activeSV.digSiteColor, r, g, b)
			self:SetDigSiteColor(self.activeSV.digSiteColor)
		end,
		width = "full",
		default = self.defaults.digSiteColor
	}
	optionsTable[#optionsTable+1] = {
		type = "colorpicker",
		name = GetString(SI_CMA_DIG_SITE_BORDER_COLOR),
		tooltip = GetString(SI_CMA_DIG_SITE_BORDER_COLOR_TOOLTIP),
		getFunc = function() return self:GetColorValues(self.activeSV.digSiteBorderColor) end,
		setFunc = function(r, g, b) 
			self:SetColor(self.activeSV.digSiteBorderColor, r, g, b)
			self:SetDigSiteBorderColor(self.activeSV.digSiteBorderColor)
		end,
		width = "full",
		default = self.defaults.digSiteBorderColor
	}
	optionsTable[#optionsTable+1] = {
		type = "slider",
		name = GetString(SI_CMA_DIG_SITE_AREA_LEVEL),
		tooltip = GetString(SI_CMA_DIG_SITE_AREA_LEVEL_TOOLTIP),
		min = 1,
		max = 170,
		getFunc = function() return self.activeSV.digSiteDrawLevel end,
		setFunc = function(value) self.activeSV.digSiteDrawLevel = value end,
		width = "full",
		default = self.defaults.digSiteDrawLevel
	}
	LAM2:RegisterOptionControls(self.name, optionsTable)

	self:LoadAllAreaColours()
	self:SetupHooks()
end

function addon:LoadAllAreaColours()
	self:SetTrackedAreaColor(self.activeSV.trackedAreaColor)
	self:SetAreaColor(self.activeSV.areaColor)
	if not self.activeSV.useTrackedDigSiteQuality then
		self:SetTrackedDigSiteColor(self.activeSV.trackedDigSiteColor)
	else
		self:SetTrackedDigSiteQualityColor(GetTrackedAntiquityId())
	end
	self:SetDigSiteColor(self.activeSV.digSiteColor)
	self:SetDigSiteBorderColor(self.activeSV.digSiteBorderColor)
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
	self:LoadAllAreaColours()
end

function addon:SetTrackedAreaColor(color)
	if not color then return end
	ZO_MAP_PIN_ASSISTED_COLOR.r = color.r
	ZO_MAP_PIN_ASSISTED_COLOR.g = color.g
	ZO_MAP_PIN_ASSISTED_COLOR.b = color.b
end

function addon:SetAreaColor(color)
	if not color then return end
	ZO_MAP_PIN_NORMAL_COLOR.r = color.r
	ZO_MAP_PIN_NORMAL_COLOR.g = color.g
	ZO_MAP_PIN_NORMAL_COLOR.b = color.b
end

function addon:SetDigSiteColor(color)
	if not color then return end
	ZO_MAP_PIN_DIG_SITE_COLOR.r = color.r
	ZO_MAP_PIN_DIG_SITE_COLOR.g = color.g
	ZO_MAP_PIN_DIG_SITE_COLOR.b = color.b
end

function addon:SetTrackedDigSiteQualityColor(antiquityId)
	local quality = GetAntiquityQuality(antiquityId)
	local color = GetAntiquityQualityColor(quality)
	self:SetTrackedDigSiteColor(color)
end

function addon:SetupHooks()
	ZO_PreHook("SetTrackedAntiquityId", function(antiquityId)
		if self.activeSV.useTrackedDigSiteQuality then
			self:SetTrackedDigSiteQualityColor(antiquityId)
		end
	end)
	ZO_PreHook(ZO_WorldMapManager, "RefreshAllAntiquityDigSites", function()
		if self.activeSV.useTrackedDigSiteQuality then
			self:SetTrackedDigSiteQualityColor(GetTrackedAntiquityId())
		end
	end)
	SecurePostHook(ZO_MapPin, "UpdateSize", function(self)
		-- Other pin draw levels are defined in ZO_MapPin.PIN_DATA
		-- These are pins are defaulted to a value of 6
		if self.polygonBlob then -- Antiquities
			self.polygonBlob:SetDrawLevel(addon.activeSV.digSiteDrawLevel)
		elseif self.pinBlob then -- All other area pins
			self.pinBlob:SetDrawLevel(addon.activeSV.questAreaDrawLevel)
		end
	end)
end

function addon:SetTrackedDigSiteColor(color)
	if not color then return end
	ZO_MAP_PIN_TRACKED_DIG_SITE_COLOR.r = color.r
	ZO_MAP_PIN_TRACKED_DIG_SITE_COLOR.g = color.g
	ZO_MAP_PIN_TRACKED_DIG_SITE_COLOR.b = color.b
end

function addon:SetDigSiteBorderColor(color)
	if not color then return end
	ZO_MAP_PIN_DIG_SITE_BORDER_COLOR.r = color.r
	ZO_MAP_PIN_DIG_SITE_BORDER_COLOR.g = color.g
	ZO_MAP_PIN_DIG_SITE_BORDER_COLOR.b = color.b
end

function addon:GetColorValues(color)
	if not color then return end
	return color.r, color.g, color.b
end

function addon:SetColor(color, r, g, b)
	if not (r and g and b) then return end
	color.r = r
	color.g = g
	color.b = b
end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)

COLORFUL_PIN_AREAS = addon