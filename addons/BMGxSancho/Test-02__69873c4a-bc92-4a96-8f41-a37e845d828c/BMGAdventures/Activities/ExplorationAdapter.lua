local BA = BMGAdventures
BA.ExplorationAdapter = BA.ExplorationAdapter or {}

function BA.ExplorationAdapter:Initialize()
    EVENT_MANAGER:RegisterForEvent(BA.name.."POI", EVENT_POI_DISCOVERED, function(_, zoneIndex, poiIndex)
        BA.ActivityRouter:Publish({
            activityType="POI_DISCOVERED",
            subject={activityId=tostring(zoneIndex)..":"..tostring(poiIndex), zoneIndex=zoneIndex, poiIndex=poiIndex},
            result={quantity=1},
            evidence={detectionClass="NATIVE_RESULT", source="EVENT_POI_DISCOVERED"},
        })
    end)
    if EVENT_TRACKED_ZONE_STORY_ACTIVITY_COMPLETED then
        EVENT_MANAGER:RegisterForEvent(BA.name.."ZoneStory", EVENT_TRACKED_ZONE_STORY_ACTIVITY_COMPLETED, function(_, zoneId, zoneCompletionType, activityId)
            BA.ActivityRouter:Publish({activityType="ZONE_STORY_COMPLETE", subject={activityId=tostring(activityId), zoneId=zoneId}, result={quantity=1}, evidence={detectionClass="NATIVE_RESULT", source="EVENT_TRACKED_ZONE_STORY_ACTIVITY_COMPLETED"}})
        end)
    end
end
