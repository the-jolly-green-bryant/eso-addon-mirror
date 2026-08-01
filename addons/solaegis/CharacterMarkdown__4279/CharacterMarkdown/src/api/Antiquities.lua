-- CharacterMarkdown - API Layer - Antiquities
-- Abstraction for antiquity sets, leads, and scrying progress

local CM = CharacterMarkdown
CM.api = CM.api or {}
CM.api.antiquities = {}

local api = CM.api.antiquities

-- =====================================================
-- CACHING
-- =====================================================

local _antiquityCache = {}

-- =====================================================
-- GRANULAR GETTERS
-- =====================================================

function api.GetSetInfo(setId)
    if not setId then
        return nil
    end

    local name = CM.SafeCall(GetAntiquitySetName, setId) or "Unknown Set"
    local icon = CM.SafeCall(GetAntiquitySetIcon, setId) or ""
    local numAntiquities = CM.SafeCall(GetNumAntiquitySetAntiquities, setId) or 0

    return {
        id = setId,
        name = name,
        icon = icon,
        numAntiquities = numAntiquities,
    }
end

function api.GetAntiquityInfo(antiquityId)
    if not antiquityId then
        return nil
    end

    if _antiquityCache[antiquityId] then
        return _antiquityCache[antiquityId]
    end

    local name = CM.SafeCall(GetAntiquityName, antiquityId) or "Unknown"
    local quality = CM.SafeCall(GetAntiquityQuality, antiquityId) or ANTIQUITY_QUALITY_WHITE
    local hasLead = CM.SafeCall(DoesAntiquityHaveLead, antiquityId) or false
    local isRepeatable = CM.SafeCall(IsAntiquityRepeatable, antiquityId) or false
    local numRecovered = CM.SafeCall(GetNumAntiquitiesRecovered, antiquityId) or 0
    local numAchieved = CM.SafeCall(GetNumGoalsAchievedForAntiquity, antiquityId) or 0
    local numGoals = CM.SafeCall(GetTotalNumGoalsForAntiquity, antiquityId) or 0

    local isDiscovered = numRecovered > 0
    local isCompleted = numGoals > 0 and numAchieved >= numGoals
    local isInProgress = hasLead and (not isCompleted or isRepeatable)

    local result = {
        id = antiquityId,
        name = name,
        quality = quality,
        hasLead = hasLead,
        isDiscovered = isDiscovered,
        isCompleted = isCompleted,
        isRepeatable = isRepeatable,
        isInProgress = isInProgress,
        numRecovered = numRecovered,
        numAchieved = numAchieved,
        numGoals = numGoals,
    }

    _antiquityCache[antiquityId] = result
    return result
end

function api.GetInProgressAntiquities()
    local inProgress = {}
    local numInProgress = CM.SafeCall(GetNumInProgressAntiquities) or 0

    for index = 1, numInProgress do
        local antiquityId = CM.SafeCall(GetInProgressAntiquityId, index)
        if antiquityId then
            local info = api.GetAntiquityInfo(antiquityId)
            if info then
                table.insert(inProgress, info)
            end
        end
    end

    return inProgress
end

function api.ClearCache()
    _antiquityCache = {}
end

function api.GetSets()
    if not GetNextAntiquityId then
        return {}
    end

    local setsById = {}
    local antiquityId = CM.SafeCall(GetNextAntiquityId, nil)

    while antiquityId do
        local setId = CM.SafeCall(GetAntiquitySetId, antiquityId)
        if setId then
            if not setsById[setId] then
                local setInfo = api.GetSetInfo(setId)
                if setInfo then
                    setInfo.antiquities = {}
                    setsById[setId] = setInfo
                end
            end

            local antiquityInfo = api.GetAntiquityInfo(antiquityId)
            if antiquityInfo and setsById[setId] then
                table.insert(setsById[setId].antiquities, antiquityInfo)
            end
        end

        antiquityId = CM.SafeCall(GetNextAntiquityId, antiquityId)
    end

    local sets = {}
    for _, setInfo in pairs(setsById) do
        table.insert(sets, setInfo)
    end

    table.sort(sets, function(a, b)
        return (a.name or "") < (b.name or "")
    end)

    return sets
end

CM.DebugPrint("API", "Antiquities API module loaded")
