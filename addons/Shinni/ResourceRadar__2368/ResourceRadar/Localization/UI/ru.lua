
local Localization = {
	--[[
	description = "The ResourceRadar Add-On displays nearby harvest nodes on the map, compass and highlights them in the 3D world.",
	
	map = "Map pins",
	displayNodesOnMap = "Display nodes on the map",
	mapPinSize = "Size of the map pins",
	
	compass = "Compass pins",
	displayNodesOnCompass = "Display nodes on the compass",
	compassPinSize = "Size of the compass pins",
	
	worldPins = "Floating Markers",
	displayNodesInWorld = "Display floating markers in the 3D world",
	worldPinsDescription = "The settings you choose here will affect all floating markers. The style (color/icon) can not be set for each resource type individually.",
	worldPinSize = "Size of the floating markers",
	worldPinPulse = "Pulse animation for floating markers",
	worldPinTexture = "Floating marker icon",
	
	pinTexture = "Compass/map pin icon",
	pinColor = "Compass/map pin color",
	pinTypeOptions = "Resource types",
	removeOnDetection = "Remove compass/map pin, when detected",
	removeOnDetectionTooltip = "The compass/map pin will be removed, when it is detected to be of this resource type.",
	
	pinType1 = "Smithing and Jewelry",
	pinType2 = "Clothing",
	pinType3 = "Woodworking",
	pinType4 = "Runestones",
	pinType5 = "Mushrooms",
	pinType6 = "Herbs/Flowers",
	pinType7 = "Water herbs",
	pinType8 = "Solvents",
	pinType100 = "Unknown",
	]]
}

-- if a string is not available, then use the english default
local metaTable = {
	__index = function(tbl, key)
		return ResourceRadar.localizationDefault[key]
	end
}
setmetatable(Localization, metaTable)

ResourceRadar:RegisterModule("localization", Localization)
