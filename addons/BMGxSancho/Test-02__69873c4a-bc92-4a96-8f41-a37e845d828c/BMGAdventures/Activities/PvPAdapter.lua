local BA = BMGAdventures
BA.PvPAdapter = BA.PvPAdapter or {}

function BA.PvPAdapter:Initialize()
    EVENT_MANAGER:RegisterForEvent(BA.name.."BGKill", EVENT_BATTLEGROUND_KILL, function(_, killedChar, killedDisplay, killedTeam, killingChar, killingDisplay, killingTeam, killType, abilityId)
        local me = GetDisplayName and GetDisplayName() or ""
        if killingDisplay == me then
            BA.ActivityRouter:Publish({activityType="BG_KILL", subject={activityId=killedDisplay}, result={quantity=1}, evidence={detectionClass="NATIVE_RESULT", source="EVENT_BATTLEGROUND_KILL"}})
        end
    end)
    EVENT_MANAGER:RegisterForEvent(BA.name.."BGMedal", EVENT_MEDAL_AWARDED, function(_, medalId, name, iconFilename, value)
        BA.ActivityRouter:Publish({activityType="BG_MEDAL", subject={activityId=tostring(medalId), name=name}, result={quantity=1, value=value}, evidence={detectionClass="NATIVE_RESULT", source="EVENT_MEDAL_AWARDED", nativeIds={medalId}}})
    end)
    EVENT_MANAGER:RegisterForEvent(BA.name.."AP", EVENT_ALLIANCE_POINT_UPDATE, function(_, alliancePoints, playSound, difference, reason, reasonSupplementaryInfo)
        if difference and difference > 0 then
            BA.ActivityRouter:Publish({activityType="AP_GAIN", result={quantity=1, amount=difference}, evidence={detectionClass="NATIVE_RESULT", source="EVENT_ALLIANCE_POINT_UPDATE"}})
            BA.ActivityRouter:Publish({activityType="AP_GAIN_AMOUNT", result={quantity=difference, amount=difference}, evidence={detectionClass="NATIVE_RESULT", source="EVENT_ALLIANCE_POINT_UPDATE"}})
        end
    end)
end
