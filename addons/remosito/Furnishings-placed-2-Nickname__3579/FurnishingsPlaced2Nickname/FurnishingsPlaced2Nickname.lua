local Addon = {}
Addon.Name = "FurnishingsPlaced2Nickname"
Addon.DisplayName = "FurnishingsPlaced2Nickname"
Addon.Author = "remosito"
Addon.Version = "37.0"




local function onHousingEditorChanged()
	
	local hid = GetCurrentZoneHouseId()
	local newnickname = GetNumHouseFurnishingsPlaced(HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_ITEM) .. "/" .. GetHouseFurnishingPlacementLimit(hid, HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_ITEM) .. ";"
	newnickname = newnickname .. GetNumHouseFurnishingsPlaced(HOUSING_FURNISHING_LIMIT_TYPE_HIGH_IMPACT_ITEM) .. ";"
	newnickname = newnickname .. GetNumHouseFurnishingsPlaced(HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_COLLECTIBLE) .. ";"
	newnickname = newnickname .. GetNumHouseFurnishingsPlaced(HOUSING_FURNISHING_LIMIT_TYPE_HIGH_IMPACT_COLLECTIBLE)
	RenameCollectible(GetCollectibleIdForHouse(hid), newnickname)	
end


local function onLoad(eventCode, name)
	
	if name ~= Addon.Name then return end
	EVENT_MANAGER:RegisterForEvent(Addon.Name, EVENT_HOUSING_EDITOR_MODE_CHANGED, onHousingEditorChanged)
	EVENT_MANAGER:UnregisterForEvent(Addon.Name, EVENT_ADD_ON_LOADED)
end


EVENT_MANAGER:RegisterForEvent(Addon.Name, EVENT_ADD_ON_LOADED, onLoad)