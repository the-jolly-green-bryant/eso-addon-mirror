local BA = BMGAdventures
BA.TrialAdapter = BA.TrialAdapter or {}

local function normalizeTrialName(name)
    local n = zo_strupper(name or "")
    if string.find(n, "ROCKGROVE", 1, true) then return "ROCKGROVE" end
    if string.find(n, "DREADSAIL", 1, true) then return "DREADSAIL_REEF" end
    if string.find(n, "ASYLUM", 1, true) then return "ASYLUM_SANCTORIUM" end
    return name or "UNKNOWN_TRIAL"
end

function BA.TrialAdapter:Initialize()
    EVENT_MANAGER:RegisterForEvent(BA.name.."Trial", EVENT_RAID_TRIAL_COMPLETE, function(_, trialName, score, totalTime)
        BA.ActivityRouter:Publish({
            activityType="TRIAL_CLEAR",
            subject={activityId=normalizeTrialName(trialName), name=trialName},
            result={quantity=1, score=score, duration=totalTime},
            evidence={detectionClass="NATIVE_RESULT", source="EVENT_RAID_TRIAL_COMPLETE"},
        })
        BA.ActivityRouter:Publish({
            activityType="TRIAL_SCORE_EVENT",
            subject={activityId=normalizeTrialName(trialName)},
            result={quantity=1, score=score},
            evidence={detectionClass="NATIVE_RESULT", source="EVENT_RAID_TRIAL_COMPLETE"},
        })
    end)
end
