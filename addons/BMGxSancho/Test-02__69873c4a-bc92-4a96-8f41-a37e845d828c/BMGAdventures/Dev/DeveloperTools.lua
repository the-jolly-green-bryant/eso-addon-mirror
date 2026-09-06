local BA = BMGAdventures
BA.DeveloperTools = BA.DeveloperTools or {}

function BA.DeveloperTools:Initialize() end

function BA.DeveloperTools:Simulate(activityType, subjectId, quantity)
    BA.ActivityRouter:Publish({
        activityType=activityType,
        eventId="DEV:"..tostring(GetTimeStamp and GetTimeStamp() or 0)..":"..tostring(math.random(1000000)),
        subject={activityId=subjectId},
        result={quantity=quantity or 1},
        evidence={detectionClass=BA.Constants.DEV_EVIDENCE, source="DEVELOPER_TOOLS"},
    })
end

function BA.DeveloperTools:Stress(count)
    count = tonumber(count) or 1000
    local types = {"QUEST_COMPLETE","POI_DISCOVERED","CRAFT_COMPLETE","BG_KILL","TRIAL_CLEAR","DUNGEON_CLEAR"}
    for i=1,count do
        local t = types[((i-1) % #types)+1]
        self:Simulate(t, t=="TRIAL_CLEAR" and "ROCKGROVE" or (t=="DUNGEON_CLEAR" and "DEV_DUNGEON" or tostring(i)), 1)
    end
end

function BA.DeveloperTools:GetMetricsString()
    local m = BA.Diagnostics.metrics
    return string.format("Events %d | Candidates %d | Avg %.2f | Max %d | Transactions %d | Duplicate Blocks %d | Unlocks %d",
        m.normalizedEvents or 0, m.challengeCandidates or 0, BA.Diagnostics:GetAverageCandidates(), m.maxCandidates or 0,
        m.transactions or 0, m.duplicateCompletionsBlocked or 0, m.unlocksGranted or 0)
end

function BA.DeveloperTools:GetRecentDiagnostics(limit)
    limit = limit or 12
    local rows = {}
    local events = BA.Diagnostics.events or {}
    local first = math.max(1, #events - limit + 1)
    for i=first,#events do
        local e = events[i]
        rows[#rows+1] = tostring(e.kind) .. ": " .. tostring(e.detail)
    end
    return table.concat(rows, "\n")
end

function BA.DeveloperTools:GetNativeValidationSummary()
    local m = BA.Diagnostics.metrics or {}
    local rows = {
        "Live native adapters active:",
        "Achievements / Quests / POI / PvP / Craft / Research / Lore / Scored Trials",
        "",
        string.format("Dungeon native completions observed: %d", m.dungeonNativeCompletions or 0),
        string.format("World Event callbacks observed: %d", m.worldEventCallbacks or 0),
        string.format("Collections completed: %d", m.collectionsCompleted or 0),
        "",
        "Dungeon and World Event completion remain diagnostic-only until live evidence is validated.",
    }
    return table.concat(rows, "\n")
end
