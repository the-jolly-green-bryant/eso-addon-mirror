local orgGetFastTravelNodeInfo = GetFastTravelNodeInfo

function GetFastTravelNodeInfo(nodeIndex)
	local known, name, normalizedX, normalizedY, icon, glowIcon, poiType, isShownInCurrentMap, linkedCollectibleIsLocked = orgGetFastTravelNodeInfo(nodeIndex)

	if name then
		name = name:gsub("TradingPost", "Trading Post")
	end

	return known, name, normalizedX, normalizedY, icon, glowIcon, poiType, isShownInCurrentMap, linkedCollectibleIsLocked
end


local orgGetGameCameraInteractableActionInfo = GetGameCameraInteractableActionInfo

function GetGameCameraInteractableActionInfo()
	local action, interactableName, interactionBlocked, isOwned, additionalInteractInfo, context, contextLink, isCriminalInteract = orgGetGameCameraInteractableActionInfo()

	if interactableName then
		interactableName = interactableName:gsub("TradingPost", "Trading Post")
	end

	return action, interactableName, interactionBlocked, isOwned, additionalInteractInfo, context, contextLink, isCriminalInteract
end


local eventHandlers = ZO_AlertText_GetHandlers()
local orgEventZoneChangedHandler = eventHandlers[EVENT_ZONE_CHANGED]

eventHandlers[EVENT_ZONE_CHANGED] = function(zoneName, subzoneName)
	if subzoneName then
		subzoneName = subzoneName:gsub("TradingPost", "Trading Post")
	end

	return orgEventZoneChangedHandler(zoneName, subzoneName)
end