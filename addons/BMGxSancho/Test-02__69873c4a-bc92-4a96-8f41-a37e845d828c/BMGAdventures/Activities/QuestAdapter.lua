local BA = BMGAdventures
BA.QuestAdapter = BA.QuestAdapter or {}

function BA.QuestAdapter:Initialize()
    EVENT_MANAGER:RegisterForEvent(BA.name.."Quest", EVENT_QUEST_COMPLETE, function(_, questName, level, previousExperience, currentExperience, championPoints, questType, zoneDisplayType)
        BA.ActivityRouter:Publish({
            activityType="QUEST_COMPLETE",
            subject={activityId=questName, name=questName},
            result={quantity=1},
            evidence={detectionClass="NATIVE_RESULT", source="EVENT_QUEST_COMPLETE"},
        })
    end)
end
