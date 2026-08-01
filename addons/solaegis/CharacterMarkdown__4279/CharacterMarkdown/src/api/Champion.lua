-- CharacterMarkdown - API Layer - Champion
-- Abstraction for champion points, disciplines, and stars

local CM = CharacterMarkdown
CM.api = CM.api or {}
CM.api.champion = {}

local api = CM.api.champion

-- =====================================================
-- GRANULAR GETTERS
-- =====================================================

function api.GetPoints()
    local total = CM.SafeCall(GetPlayerChampionPointsEarned) or 0
    local unspentFromAPI = CM.SafeCall(GetUnitChampionPoints, "player") or 0

    -- Debug: Log what the API returns
    CM.DebugPrint("CP_API", string.format("GetPlayerChampionPointsEarned: %d", total))
    CM.DebugPrint("CP_API", string.format("GetUnitChampionPoints: %d", unspentFromAPI))

    -- Calculate spent from disciplines instead of using API value
    -- We'll calculate unspent as (total - spent) in the collector
    return {
        total = total,
        unspent = nil, -- Don't use API value, calculate in collector
        spent = 0, -- Will be calculated in collector from disciplines
    }
end

function api.GetDisciplineInfo(disciplineIndex)
    local disciplineId = CM.SafeCall(GetChampionDisciplineId, disciplineIndex)
    if not disciplineId then
        return nil
    end

    local name = CM.SafeCall(GetChampionDisciplineName, disciplineId)

    -- Try to get the discipline data object (ZO_ChampionDisciplineData)
    local disciplineData = nil
    local savedPointsTotal = 0

    -- Attempt to access CHAMPION_DATA_MANAGER if available
    -- NOTE: Disabled ZO_ChampionDisciplineData usage as it appears to return incorrect values
    -- (data shifting between disciplines) when accessed by ID in this context.
    -- Falling back to native API GetChampionPointsInDiscipline which is reliable.
    local success, manager = pcall(function()
        -- return CHAMPION_DATA_MANAGER -- Disabled for now
        return nil
    end)

    if success and manager and manager.GetChampionDisciplineData then
        -- Get the discipline data object
        local discData = manager:GetChampionDisciplineData(disciplineId)
        if discData and discData.GetNumSavedPointsTotal then
            -- This is the proper way to get assigned points
            savedPointsTotal = discData:GetNumSavedPointsTotal() or 0
            CM.DebugPrint(
                "CP_API",
                string.format("Discipline %s: GetNumSavedPointsTotal=%d", name or "Unknown", savedPointsTotal)
            )
        end
    end

    -- Fallback to old method if the new one didn't work
    if savedPointsTotal == 0 then
        -- Try old API methods
        savedPointsTotal = CM.SafeCall(GetNumSpentChampionPoints, disciplineId) or 0
        CM.DebugPrint(
            "CP_API",
            string.format(
                "Discipline %s: Fallback GetNumSpentChampionPoints=%d",
                name or "Unknown",
                savedPointsTotal
            )
        )
    end

    -- Get unspent points for this discipline
    local unspent = CM.SafeCall(GetNumUnspentChampionPoints, disciplineId) or 0
    CM.DebugPrint(
        "CP_API",
        string.format("Discipline %s: GetNumUnspentChampionPoints=%d", name or "Unknown", unspent)
    )

    return {
        id = disciplineId,
        name = name or "Unknown",
        spent = savedPointsTotal,
        unspent = unspent,
    }
end

function api.GetDisciplineSkills(disciplineIndex)
    local numSkills = CM.SafeCall(GetNumChampionDisciplineSkills, disciplineIndex) or 0
    local skills = {}

    for i = 1, numSkills do
        local skillId = CM.SafeCall(GetChampionSkillId, disciplineIndex, i)
        if skillId then
            local points = CM.SafeCall(GetNumPointsSpentOnChampionSkill, skillId) or 0
            local name = CM.SafeCall(GetChampionSkillName, skillId)
            local maxPoints = CM.SafeCall(GetChampionSkillMaxPoints, skillId) or 0

            -- Determine if slottable
            -- CHAMPION_SKILL_TYPE_NORMAL = 0 (Passive)
            -- Others are slottable
            local skillType = CM.SafeCall(GetChampionSkillType, skillId)
            local isSlottable = (skillType ~= 0 and skillType ~= CHAMPION_SKILL_TYPE_NORMAL)

            table.insert(skills, {
                id = skillId,
                name = name or "Unknown",
                points = points,
                max = maxPoints,
                isSlottable = isSlottable,
            })
        end
    end

    return skills
end

-- Composition functions moved to collector level

-- =====================================================
-- ENLIGHTENMENT TRACKING (API 101049+)
-- =====================================================

function api.GetEnlightenmentInfo()
    -- Check if enlightenment is available for this character
    local isEnlightened = CM.SafeCall(IsEnlightenedAvailableForCharacter) or false

    -- Get remaining enlightenment pool (XP bonus remaining)
    local poolRemaining = CM.SafeCall(GetEnlightenedPool) or 0

    CM.DebugPrint(
        "CP_API",
        string.format(
            "Enlightenment: active=%s, pool=%d",
            tostring(isEnlightened),
            poolRemaining
        )
    )

    return {
        isEnlightened = isEnlightened,
        poolRemaining = poolRemaining,
        timeUntilChange = nil,
        timeFormatted = nil,
    }
end

-- Get pending (uncommitted) champion point changes
function api.GetPendingPoints()
    return 0
end

CM.DebugPrint("API", "Champion API module loaded")
