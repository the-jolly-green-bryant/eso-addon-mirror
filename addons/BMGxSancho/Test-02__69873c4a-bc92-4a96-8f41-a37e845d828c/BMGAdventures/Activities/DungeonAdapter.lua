local BA = BMGAdventures
BA.DungeonAdapter = BA.DungeonAdapter or {}

local function serializeArgs(...)
    local values = {...}
    local out = {}
    for i = 1, #values do out[#out+1] = tostring(values[i]) end
    return table.concat(out, "|")
end

function BA.DungeonAdapter:Initialize()
    -- Dev2 deliberately records native Activity Finder completion without converting
    -- it into DUNGEON_CLEAR yet. We want real console evidence from queued and manual
    -- entry flows before this adapter becomes progression-authoritative.
    if EVENT_ACTIVITY_FINDER_ACTIVITY_COMPLETE then
        EVENT_MANAGER:RegisterForEvent(BA.name .. "DungeonActivityComplete", EVENT_ACTIVITY_FINDER_ACTIVITY_COMPLETE, function(_, ...)
            BA.Diagnostics:Count("dungeonNativeCompletions")
            BA.Diagnostics:Record("DUNGEON_NATIVE_COMPLETE", serializeArgs(...))
        end)
    end

    EVENT_MANAGER:RegisterForEvent(BA.name .. "DungeonPlayerActivated", EVENT_PLAYER_ACTIVATED, function()
        local zoneName = GetUnitZone and GetUnitZone("player") or ""
        local difficulty = ZO_GetEffectiveDungeonDifficulty and ZO_GetEffectiveDungeonDifficulty() or 0
        BA.Diagnostics:Record("DUNGEON_CONTEXT", tostring(zoneName) .. "|difficulty=" .. tostring(difficulty))
    end)
end
