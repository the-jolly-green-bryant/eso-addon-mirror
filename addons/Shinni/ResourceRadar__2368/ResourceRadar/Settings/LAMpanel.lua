
local Settings, Localization, Textures, PinTypes
local LAMpanel = {}
ResourceRadar:RegisterModule("LAMpanel", LAMpanel)

function LAMpanel:Initialize()
	Settings = ResourceRadar.settings
	Localization = ResourceRadar.localization
	Textures = ResourceRadar.textures
	PinTypes = LibNodeDetection.pinTypes
	
	local displayVersion = self:RetrieveDisplayVersion()
	-- first LAM stuff, at the end of this function we will also create
	-- a custom checkbox in the map's filter menu for the heat map
	local panelData = {
		type = "panel",
		name = "ResourceRadar",
		displayName = ZO_HIGHLIGHT_TEXT:Colorize("ResourceRadar"),
		author = "Shinni",
		version = displayVersion,
		registerForRefresh = true,
		--registerForDefaults = true,
		--website = "http://www.esoui.com/downloads/infoXYZ", todo replace XYZ with esoui id
	}

	local optionsTable = setmetatable({}, { __index = table })
	
	optionsTable:insert({
		type = "description",
		title = nil,
		text = Localization.description,
		width = "full",
	})
	
	-- TODO 
	--[[
	optionsTable:insert({
		type = "checkbox",
		name = Localization.useAccountWide,
		--getFunc = function() return Settings.displayNodesOnMap end,
		--setFunc = function(value) Settings.displayNodesOnMap = value end,
		default = false,
	})
	--]]
	
	local submenuTable = setmetatable({}, { __index = table })
	optionsTable:insert({
		type = "submenu",
		name = Localization.map,
		controls = submenuTable,
	})
	
	submenuTable:insert({
		type = "checkbox",
		name = Localization.displayNodesOnMap,
		getFunc = function() return Settings.displayNodesOnMap end,
		setFunc = function(value) Settings.displayNodesOnMap = value end,
		default = Settings.defaultSettings.displayNodesOnMap,
	})
	
	submenuTable:insert({
		type = "slider",
		name = Localization.mapPinSize,
		min = 8,
		max = 32,
		getFunc = function() return Settings.mapPinSize end,
		setFunc = function(value) Settings.mapPinSize = value end,
		default = Settings.defaultSettings.mapPinSize,
	})
	
	local submenuTable = setmetatable({}, { __index = table })
	optionsTable:insert({
		type = "submenu",
		name = Localization.compass,
		controls = submenuTable,
	})
	
	submenuTable:insert({
		type = "checkbox",
		name = Localization.displayNodesOnCompass,
		getFunc = function() return Settings.displayNodesOnCompass end,
		setFunc = function(value) Settings.displayNodesOnCompass = value end,
		default = Settings.defaultSettings.displayNodesOnCompass,
	})
	
	submenuTable:insert({
		type = "slider",
		name = Localization.compassPinSize,
		min = 8,
		max = 40,
		getFunc = function() return Settings.compassPinSize end,
		setFunc = function(value) Settings.compassPinSize = value end,
		default = Settings.defaultSettings.compassPinSize,
	})
	
	local submenuTable = setmetatable({}, { __index = table })
	optionsTable:insert({
		type = "submenu",
		name = Localization.worldPins,
		controls = submenuTable,
	})
	
	submenuTable:insert({
		type = "description",
		title = nil,
		text = Localization.worldPinsDescription,
		width = "full",
	})
	
	submenuTable:insert({
		type = "checkbox",
		name = Localization.displayNodesInWorld,
		getFunc = function() return Settings.displayNodesInWorld end,
		setFunc = function(value) Settings.displayNodesInWorld = value end,
		default = Settings.defaultSettings.displayNodesInWorld,
		requiresReload = true,
	})
	
	submenuTable:insert({
		type = "slider",
		name = Localization.worldPinSize,
		min = 16,
		max = 256,
		getFunc = function() return Settings.worldPinSize end,
		setFunc = function(value) Settings.worldPinSize = value end,
		default = Settings.defaultSettings.worldPinSize,
	})
	
	submenuTable:insert({
		type = "checkbox",
		name = Localization.worldPinPulse,
		getFunc = function() return Settings.worldPinPulse end,
		setFunc = function(value) Settings.worldPinPulse = value end,
		default = Settings.defaultSettings.worldPinPulse,
	})
	
	submenuTable:insert({
		type = "iconpicker",
		name = Localization.worldPinTexture,
		getFunc = function()
			return Settings.worldPinTexture
		end,
		setFunc = function(texture)
			Settings.worldPinTexture = texture
		end,
		choices = Textures.worldPinTextures,
		default = Settings.defaultSettings.worldPinTexture,
		requiresReload = true,
	})
	
	--local submenuTable = setmetatable({}, { __index = table })
	optionsTable:insert({
		type = "header",
		name = Localization.pinTypeOptions,
		--controls = submenuTable,
	})
	
	for _, pinTypeId in ipairs( PinTypes.ALL_PINTYPES ) do
		optionsTable:insert({
			type = "header",
			name = Localization["pinType" .. pinTypeId]
		})
		optionsTable:insert(self:CreateColorPicker(pinTypeId))
		optionsTable:insert(self:CreateIconPicker(pinTypeId))
		if pinTypeId ~= PinTypes.UNKNOWN then
			optionsTable:insert(self:CreateRemoveCheckbox(pinTypeId))
		end
	end
	
	LAMpanel.optionsPanel = LibAddonMenu2:RegisterAddonPanel("ResourceRadarControl", panelData)
	LibAddonMenu2:RegisterOptionControls("ResourceRadarControl", optionsTable)

end

function LAMpanel:CreateRemoveCheckbox(pinTypeId)
	local filter = {
		type = "checkbox",
		name = Localization.removeOnDetection,
		getFunc = function()
			return Settings.removeOnDetection[pinTypeId]
		end,
		setFunc = function(shouldRemove)
			Settings.removeOnDetection[pinTypeId] = shouldRemove
		end,
		tooltip = Localization.removeOnDetectionTooltip,
		default = Settings.defaultSettings.removeOnDetection[pinTypeId],
		width = "full",
	}
	return filter
end

function LAMpanel:CreateIconPicker(pinTypeId)
	local filter = {
		type = "iconpicker",
		name = Localization.pinTexture,
		getFunc = function()
			return Settings.pinTextures[pinTypeId]
		end,
		setFunc = function(texture)
			Settings.pinTextures[pinTypeId] = texture
		end,
		choices = Textures.pinTypeTextures[pinTypeId],
		default = Settings.defaultSettings.pinTextures[pinTypeId],
		width = "half",
	}
	return filter
end

function LAMpanel:CreateColorPicker(pinTypeId)
	local colorPicker = {
		type = "colorpicker",
		name = Localization.pinColor,
		getFunc = function()
			return unpack(Settings.pinColors[pinTypeId])
		end,
		setFunc = function(r, g, b)
			Settings.pinColors[pinTypeId] = {r, g, b, 1}
		end,
		default = Settings.defaultSettings.pinColors[pinTypeId],
		width = "half",
	}
	return colorPicker
end

function LAMpanel:RetrieveDisplayVersion()
	local displayVersion = "1.0.0"
	local AddOnManager = GetAddOnManager()
	if AddOnManager.GetAddOnVersion then -- api version 25 doesn't have that method
		for addonIndex = 1, AddOnManager:GetNumAddOns() do
			local name = AddOnManager:GetAddOnInfo(addonIndex)
			if name == "ResourceRadar" then
				local versionInt = AddOnManager:GetAddOnVersion(addonIndex)
				local rev = versionInt % 100
				local version = zo_floor(versionInt / 100) % 100
				local major = zo_floor(versionInt / 10000) % 100
				displayVersion = string.format("%d.%d.%d", major, version, rev)
			end
		end
	end
	return displayVersion
end
