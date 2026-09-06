local BA = BMGAdventures
BA.AchievementAdapter = BA.AchievementAdapter or {}

function BA.AchievementAdapter:Initialize()
    EVENT_MANAGER:RegisterForEvent(BA.name.."Achievement", EVENT_ACHIEVEMENT_AWARDED, function(_, name, points, id, link)
        BA.ActivityRouter:Publish({
            activityType="ACHIEVEMENT_COMPLETE",
            subject={activityId=tostring(id), achievementId=id, name=name},
            result={quantity=1, points=points},
            evidence={detectionClass="NATIVE_RESULT", source="EVENT_ACHIEVEMENT_AWARDED", nativeIds={id}},
        })
    end)
end
