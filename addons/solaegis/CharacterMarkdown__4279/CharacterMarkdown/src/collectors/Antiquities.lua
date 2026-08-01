-- CharacterMarkdown - Antiquities Data Collector
-- Composition logic moved from API layer

local CM = CharacterMarkdown

local function CollectAntiquitiesData()
    local sets = CM.api.antiquities.GetSets()

    local data = {
        sets = sets or {},
        summary = {
            totalAntiquities = 0,
            discoveredAntiquities = 0,
            activeLeads = 0,
            completedAntiquities = 0,
            totalSets = 0,
            completedSets = 0,
        },
        activeLeads = {},
    }

    local activeLeadsMap = {}

    for _, set in ipairs(data.sets) do
        set.discoveredAntiquities = 0
        set.completedAntiquities = 0

        for _, antiquity in ipairs(set.antiquities or {}) do
            data.summary.totalAntiquities = data.summary.totalAntiquities + 1

            if antiquity.isDiscovered then
                data.summary.discoveredAntiquities = data.summary.discoveredAntiquities + 1
                set.discoveredAntiquities = set.discoveredAntiquities + 1
            end

            if antiquity.isCompleted then
                data.summary.completedAntiquities = data.summary.completedAntiquities + 1
                set.completedAntiquities = set.completedAntiquities + 1
            end

            if antiquity.isInProgress or antiquity.hasLead then
                activeLeadsMap[antiquity.id] = antiquity
            end
        end

        if set.completedAntiquities == set.numAntiquities and set.numAntiquities > 0 then
            data.summary.completedSets = data.summary.completedSets + 1
        end
    end

    local inProgress = CM.api.antiquities.GetInProgressAntiquities()
    for _, antiquity in ipairs(inProgress) do
        activeLeadsMap[antiquity.id] = antiquity
    end

    local activeLeads = {}
    for _, antiquity in pairs(activeLeadsMap) do
        table.insert(activeLeads, antiquity)
    end

    data.summary.activeLeads = #activeLeads
    data.summary.totalSets = #data.sets

    data.summary.discoveryPercent = data.summary.totalAntiquities > 0
            and math.floor((data.summary.discoveredAntiquities / data.summary.totalAntiquities) * 100)
        or 0
    data.summary.completionPercent = data.summary.totalAntiquities > 0
            and math.floor((data.summary.completedAntiquities / data.summary.totalAntiquities) * 100)
        or 0
    data.summary.setCompletionPercent = data.summary.totalSets > 0
            and math.floor((data.summary.completedSets / data.summary.totalSets) * 100)
        or 0

    table.sort(activeLeads, function(a, b)
        return (a.quality or 0) > (b.quality or 0)
    end)

    data.activeLeads = activeLeads

    return data
end

CM.collectors.CollectAntiquitiesData = CollectAntiquitiesData

CM.DebugPrint("COLLECTOR", "Antiquities collector module loaded")
