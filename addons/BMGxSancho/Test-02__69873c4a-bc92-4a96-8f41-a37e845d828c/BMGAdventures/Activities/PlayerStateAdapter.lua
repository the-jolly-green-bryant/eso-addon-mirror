local BA = BMGAdventures
BA.PlayerStateAdapter = BA.PlayerStateAdapter or {}
function BA.PlayerStateAdapter:Initialize()
    EVENT_MANAGER:RegisterForEvent(BA.name.."Death", EVENT_PLAYER_DEAD, function()
        BA.ActivityRouter:Publish({activityType="PLAYER_DEATH", result={quantity=1}, evidence={detectionClass="NATIVE_RESULT", source="EVENT_PLAYER_DEAD"}})
    end)
end
