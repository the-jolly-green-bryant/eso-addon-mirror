
local Settings, Detection, CallbackManager, Events
local MapPins = {}
ResourceRadar:RegisterModule("mapPins", MapPins)

local function ZO_WorldMap_AddCustomPin(pinType, pinTypeAddCallback, pinTypeOnResizeCallback, pinLayoutData, pinTooltipCreator)
    ZO_WorldMap_GetPinManager():AddCustomPin(pinType, pinTypeAddCallback, pinTypeOnResizeCallback, pinLayoutData, pinTooltipCreator)
end

local function ZO_WorldMap_SetCustomPinEnabled(pinType, enabled)
    ZO_WorldMap_GetPinManager():SetCustomPinEnabled(pinType, enabled)
end

local function ZO_WorldMap_IsCustomPinEnabled(pinType)
    ZO_WorldMap_GetPinManager():IsCustomPinEnabled(pinType)
end

local function ZO_WorldMap_ResetCustomPinsOfType(pinTypeString)
    ZO_WorldMap_GetPinManager():RemovePins(pinTypeString)
end

local function ZO_WorldMap_RefreshCustomPinsOfType(pinType)
    ZO_WorldMap_GetPinManager():RefreshCustomPins(pinType)
end


function MapPins:Initialize()
	Settings = ResourceRadar.settings
	CallbackManager = LibNodeDetection.callbackManager
	Events = LibNodeDetection.events
	PinTypes = LibNodeDetection.pinTypes
	Detection = LibNodeDetection.detection
	
	self.tints = {}
	for _, pinTypeId in pairs(PinTypes.ALL_PINTYPES) do
		self.tints[pinTypeId] = ZO_ColorDef:New(unpack(Settings.pinColors[pinTypeId]))
	end
	
	self.textureFunction = function(mapPin)
		local pinType, pinTag = mapPin:GetPinTypeAndTag()
		return Settings.pinTextures[pinTag.pinTypeId]
	end
	
	self.tintFunction = function(mapPin)
		local pinType, pinTag = mapPin:GetPinTypeAndTag()
		return self.tints[pinTag.pinTypeId]
	end
	
	self.pinTypeCallback = function(pinManager)
		ZO_WorldMap_ResetCustomPinsOfType("MAP_PIN_TYPE_RESOURCE_NODE")
		local zoneId = GetZoneId(GetUnitZoneIndex("player"))
		for _, compassPin in pairs(Detection.knownPositionCompassPins) do
			if not Settings.removeOnDetection[compassPin.pinTypeId] then
				pinManager:CreatePin(MAP_PIN_TYPE_RESOURCE_NODE, compassPin, 
					GetNormalizedWorldPosition(zoneId, compassPin.worldX * 100, 0, compassPin.worldY * 100))
			end
		end
	end
	
	self.layout = {
		level = 20,
		size = Settings.mapPinSize,
		texture = self.textureFunction,
		tint = self.tintFunction,
	}
	
	local resizeCallback = nil
	ZO_WorldMap_AddCustomPin("MAP_PIN_TYPE_RESOURCE_NODE", 
					self.pinTypeCallback, resizeCallback, self.layout)
	ZO_WorldMap_SetCustomPinEnabled(MAP_PIN_TYPE_RESOURCE_NODE, Settings.displayNodesOnMap)
	
	CallbackManager:RegisterCallback(Events.HARVEST_NODE_PINTYPE_UPDATED, function(event, compassPin)
		local pinManager = ZO_WorldMap_GetPinManager()
		if not Settings.displayNodesOnMap then return end
		if Settings.removeOnDetection[compassPin.pinTypeId] then
			pinManager:RemovePins("MAP_PIN_TYPE_RESOURCE_NODE", MAP_PIN_TYPE_RESOURCE_NODE, compassPin)
		else
			local pin = pinManager:FindPin("MAP_PIN_TYPE_RESOURCE_NODE", MAP_PIN_TYPE_RESOURCE_NODE, compassPin)
			if pin then
				pin:SetData(MAP_PIN_TYPE_RESOURCE_NODE, compassPin)
			end
		end
	end)
	
	CallbackManager:RegisterCallback(Events.HARVEST_NODE_HIDDEN, function(event, compassPin)
		local pinManager = ZO_WorldMap_GetPinManager()
		pinManager:RemovePins("MAP_PIN_TYPE_RESOURCE_NODE", MAP_PIN_TYPE_RESOURCE_NODE, compassPin)
	end)
	
	CallbackManager:RegisterCallback(Events.HARVEST_NODE_LOCATION_UPDATED, function(event, compassPin)
		if not Settings.displayNodesOnMap then return end
		if Settings.removeOnDetection[compassPin.pinTypeId] then return end
		local pinManager = ZO_WorldMap_GetPinManager()
		local zoneId = GetZoneId(GetUnitZoneIndex("player"))
		pinManager:CreatePin(MAP_PIN_TYPE_RESOURCE_NODE, compassPin, 
			GetNormalizedWorldPosition(zoneId, compassPin.worldX * 100, 0, compassPin.worldY * 100))
	end)
	
	local simpleRefresh = {
		pinTextures = true,
		removeOnDetection = true
	}
	
	Settings:RegisterCallback(function(setting, ...)
		if simpleRefresh[setting] then
			ZO_WorldMap_RefreshCustomPinsOfType(MAP_PIN_TYPE_RESOURCE_NODE)
		elseif setting == "displayNodesOnMap" then
			ZO_WorldMap_SetCustomPinEnabled(MAP_PIN_TYPE_RESOURCE_NODE, Settings.displayNodesOnMap)
			ZO_WorldMap_RefreshCustomPinsOfType(MAP_PIN_TYPE_RESOURCE_NODE)
		elseif setting == "pinColors" then
			local pinTypeId = ...
			self.tints[pinTypeId] = ZO_ColorDef:New(unpack(Settings.pinColors[pinTypeId]))
			ZO_WorldMap_RefreshCustomPinsOfType(MAP_PIN_TYPE_RESOURCE_NODE)
		elseif setting == "mapPinSize" then
			self.layout.size = ...
			ZO_WorldMap_RefreshCustomPinsOfType(MAP_PIN_TYPE_RESOURCE_NODE)
		end
	end)
end

