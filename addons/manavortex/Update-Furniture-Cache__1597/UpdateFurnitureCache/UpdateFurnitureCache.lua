local function refreshItemCache()
	SHARED_FURNITURE:CreateOrUpdateItemCache(BAG_BACKPACK)
	SHARED_FURNITURE:CreateOrUpdateItemCache(BAG_BANK)
end


function UpdateFurnitureCache_Init(eventCode, addonName)
	if addonName ~= "UpdateFurnitureCache" then return end
	
	EVENT_MANAGER:RegisterForEvent("UpdateFurnitureCache", EVENT_HOUSING_EDITOR_MODE_CHANGED, 	refreshItemCache)
	EVENT_MANAGER:RegisterForEvent("UpdateFurnitureCache", EVENT_HOUSING_FURNITURE_PLACED, 		refreshItemCache)	
	refreshItemCache()
	EVENT_MANAGER:UnregisterForEvent("UpdateFurnitureCache", EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent("UpdateFurnitureCache", EVENT_ADD_ON_LOADED, UpdateFurnitureCache_Init)