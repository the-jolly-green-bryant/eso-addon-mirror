local function NoriwenBombs(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType,
    sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId,
    abilityId, overflow)
    if abilityId == 224515 then
        d("Hit by bomb!!! Wipeeee!")
    end
end

local function Initialize()
    EVENT_MANAGER:RegisterForEvent("LSAchievTrackerPlayerActivated", EVENT_PLAYER_ACTIVATED, function() 	
        if (GetZoneId(GetUnitZoneIndex("player")) == 1497) then
            EVENT_MANAGER:RegisterForEvent("LSAchievTrackerBombs", EVENT_COMBAT_EVENT, NoriwenBombs)
		else
            EVENT_MANAGER:UnregisterForEvent("LSAchievTrackerBombs");
	    end
    end)
    --EVENT_MANAGER:AddFilterForEvent("LSAchievTrackerBombs", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 224515)
end
local function OnAddOnLoaded(event, addonName)
	if addonName == "LSAchievTracker" then
		EVENT_MANAGER:UnregisterForEvent("LSAchievTracker", EVENT_ADD_ON_LOADED)
		Initialize()
	end
end

EVENT_MANAGER:RegisterForEvent("LSAchievTracker", EVENT_ADD_ON_LOADED, OnAddOnLoaded)