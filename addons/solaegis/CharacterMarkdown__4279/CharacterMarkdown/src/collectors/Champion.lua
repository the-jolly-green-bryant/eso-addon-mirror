-- CharacterMarkdown - Champion Points Data Collector
-- Extracted from Progression.lua, refactored to use API layer

local CM = CharacterMarkdown
local string_format = string.format

-- =====================================================
-- CHAMPION POINTS CONSTANTS
-- =====================================================

local CP_CONSTANTS = {
    MIN_CP_FOR_SYSTEM = 10,
    CP_THRESHOLD_HIGH = 1200,
    CP_THRESHOLD_MEDIUM = 900,
    MAX_CP_PER_DISCIPLINE = 660,
}

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

-- Get discipline info (emoji and display name) by ID
local function GetDisciplineInfo(disciplineId)
    local DisciplineType = CM.constants.DisciplineType
    local emoji, displayName

    if disciplineId == 1 then
        emoji = "⚔️"
        displayName = DisciplineType.WARFARE
    elseif disciplineId == 2 then
        emoji = "💪"
        displayName = DisciplineType.FITNESS
    elseif disciplineId == 3 then
        emoji = "⚒️"
        displayName = DisciplineType.CRAFT
    else
        emoji = "⚔️"
        displayName = "Unknown"
    end

    return emoji, displayName
end

-- Get discipline type constant safely
local function GetDisciplineTypeConstant(disciplineId)
    local constSuccess, constValue = false, nil

    if disciplineId == 1 then
        constSuccess, constValue = pcall(function()
            return CHAMPION_DISCIPLINE_TYPE_COMBAT
        end)
        return (constSuccess and constValue) and constValue or 1
    elseif disciplineId == 2 then
        constSuccess, constValue = pcall(function()
            return CHAMPION_DISCIPLINE_TYPE_CONDITIONING
        end)
        return (constSuccess and constValue) and constValue or 2
    elseif disciplineId == 3 then
        constSuccess, constValue = pcall(function()
            return CHAMPION_DISCIPLINE_TYPE_WORLD
        end)
        return (constSuccess and constValue) and constValue or 3
    end

    return disciplineId -- Fallback to ID itself
end

-- Get spent points in discipline (tries multiple methods, returns first success)
local function GetDisciplineSpentPoints(disciplineId, disciplineTypeConstant)
    local methods = {
        function()
            return GetNumSpentChampionPoints(disciplineTypeConstant)
        end,
        function()
            return GetChampionPointsInDiscipline(disciplineTypeConstant)
        end,
        function()
            return GetNumSpentChampionPoints(disciplineId)
        end,
        function()
            return GetChampionPointsInDiscipline(disciplineId)
        end,
    }

    for _, method in ipairs(methods) do
        local success, value = pcall(method)
        if success and value and value > 0 then
            return value
        end
    end

    return 0
end

-- =====================================================
-- CHAMPION POINTS
-- =====================================================

local function CollectChampionPointData()
    -- Use API layer granular functions (composition moved to collector level)
    local cpPoints = CM.api.champion.GetPoints()
    local numDisciplines = CM.SafeCall(GetNumChampionDisciplines) or 3

    local data = {
        total = 0,
        spent = 0,
        available = 0,
        disciplines = {},
        enlightenment = nil, -- Will be populated from API
        pendingPoints = 0, -- Uncommitted changes
        analysis = {
            slottableSkills = 0,
            passiveSkills = 0,
            maxSlottablePerDiscipline = 0,
            investmentLevel = "low",
        },
    }

    -- Get total CP earned (account-wide) from API
    data.total = cpPoints.total or 0
    data.available = cpPoints.unspent

    -- Get enlightenment info (API 101049+)
    if CM.api.champion.GetEnlightenmentInfo then
        data.enlightenment = CM.api.champion.GetEnlightenmentInfo()
    end

    -- Get pending (uncommitted) CP changes
    if CM.api.champion.GetPendingPoints then
        data.pendingPoints = CM.api.champion.GetPendingPoints()
    end

    if data.total < CP_CONSTANTS.MIN_CP_FOR_SYSTEM then
        return data
    end

    -- Determine slottable limits based on total CP
    if data.total >= CP_CONSTANTS.CP_THRESHOLD_MEDIUM then
        data.analysis.maxSlottablePerDiscipline = 4
    else
        data.analysis.maxSlottablePerDiscipline = 3
    end

    -- Calculate CP Caps per discipline (Rotation: Green/Craft -> Blue/Warfare -> Red/Fitness)
    local basePerDiscipline = math.floor(data.total / 3)
    local remainder = data.total % 3

    local caps = {
        [3] = basePerDiscipline + (remainder >= 1 and 1 or 0), -- Craft (Green)
        [1] = basePerDiscipline + (remainder >= 2 and 1 or 0), -- Warfare (Blue)
        [2] = basePerDiscipline, -- Fitness (Red)
    }

    -- Process disciplines from API
    local success, allocations = pcall(function()
        local disciplines = {}
        local totalSpent = 0
        local slottableCount = 0
        local passiveCount = 0

        -- Get disciplines from API
        for i = 1, numDisciplines do
            local apiDiscipline = CM.api.champion.GetDisciplineInfo(i)
            if apiDiscipline then
                local disciplineId = apiDiscipline.id
                local disciplineName = apiDiscipline.name or "Unknown"
                local emoji, displayName = GetDisciplineInfo(disciplineId)
                local disciplineTypeConstant = GetDisciplineTypeConstant(disciplineId)

                -- Get assigned points (API value - often unreliable/lagging)
                local apiAssigned = apiDiscipline.spent or 0
                if apiAssigned == 0 then
                    apiAssigned = GetDisciplineSpentPoints(disciplineId, disciplineTypeConstant)
                end

                -- Determine Cap for this discipline
                local disciplineCap = caps[disciplineId] or basePerDiscipline

                local disciplineData = {
                    id = disciplineId,
                    name = displayName,
                    emoji = emoji,
                    skills = {},
                    allStars = {},
                    assigned = apiAssigned, -- Keep API value for reference
                    cap = disciplineCap, -- Calculated Cap
                    spent = 0, -- Will be calculated from skills
                    available = 0, -- Will be calculated (Cap - Spent)
                    total = 0, -- Legacy: Will be set to Spent
                    slottable = 0,
                    passive = 0,
                    slottableSkills = {},
                    passiveSkills = {},
                }

                -- Process skills from API
                local disciplineSkills = CM.api.champion.GetDisciplineSkills(i)
                if disciplineSkills then
                    for _, apiSkill in ipairs(disciplineSkills) do
                        local pointsSpent = apiSkill.points or 0
                        local skillName = apiSkill.name or "Unknown"
                        local skillId = apiSkill.id
                        local isSlottable = apiSkill.isSlottable or false
                        local skillType = isSlottable and "slottable" or "passive"

                        -- Add to allStars
                        table.insert(disciplineData.allStars, {
                            name = skillName,
                            points = pointsSpent,
                            maxPoints = apiSkill.max or 0,
                            skillId = skillId,
                        })

                        if pointsSpent > 0 then
                            if isSlottable then
                                slottableCount = slottableCount + 1
                                disciplineData.slottable = disciplineData.slottable + pointsSpent
                                table.insert(disciplineData.slottableSkills, {
                                    name = skillName,
                                    points = pointsSpent,
                                    skillId = skillId,
                                })
                            else
                                passiveCount = passiveCount + 1
                                disciplineData.passive = disciplineData.passive + pointsSpent
                                table.insert(disciplineData.passiveSkills, {
                                    name = skillName,
                                    points = pointsSpent,
                                    skillId = skillId,
                                })
                            end

                            table.insert(disciplineData.skills, {
                                name = skillName,
                                points = pointsSpent,
                                type = skillType,
                                isSlottable = isSlottable,
                                skillId = skillId,
                            })
                        end
                    end
                end

                -- Calculate discipline total (Spent) from skills
                local calculatedSpent = disciplineData.slottable + disciplineData.passive

                -- Update discipline data with calculated values
                disciplineData.spent = calculatedSpent
                disciplineData.total = calculatedSpent -- Legacy compatibility
                disciplineData.available = math.max(0, disciplineData.cap - calculatedSpent)

                totalSpent = totalSpent + calculatedSpent

                table.insert(disciplines, disciplineData)
            end
        end

        -- Calculate investment level
        local investmentLevel = "low"
        if data.total >= 1500 then
            investmentLevel = "very-high"
        elseif data.total >= CP_CONSTANTS.CP_THRESHOLD_HIGH then
            investmentLevel = "high"
        elseif data.total >= 800 then
            investmentLevel = "medium-high"
        elseif data.total >= 400 then
            investmentLevel = "medium"
        end

        -- Calculate discipline balance metrics
        local disciplineTotals = {}
        local maxDisciplineTotal = 0
        local minDisciplineTotal = math.huge

        for _, disc in ipairs(disciplines) do
            local total = disc.total or 0
            disciplineTotals[disc.name] = total
            if total > maxDisciplineTotal then
                maxDisciplineTotal = total
            end
            if total < minDisciplineTotal then
                minDisciplineTotal = total
            end
        end

        local disciplineBalance = "balanced"
        local balanceVariance = maxDisciplineTotal - minDisciplineTotal
        if balanceVariance > 200 then
            disciplineBalance = "unbalanced"
        elseif balanceVariance > 100 then
            disciplineBalance = "moderate"
        end

        -- Investment recommendations
        local recommendations = {}
        if data.total < CP_CONSTANTS.MIN_CP_FOR_SYSTEM then
            table.insert(recommendations, "Continue earning CP to unlock the Champion Point system (10 CP required)")
        end

        if disciplineBalance == "unbalanced" then
            table.insert(
                recommendations,
                "Consider balancing CP investment across disciplines for better overall performance"
            )
        end

        if slottableCount < data.analysis.maxSlottablePerDiscipline * 3 then
            table.insert(recommendations, "Consider investing in more slottable skills for increased build flexibility")
        end

        return {
            disciplines = disciplines,
            totalSpent = totalSpent,
            slottableCount = slottableCount,
            passiveCount = passiveCount,
            investmentLevel = investmentLevel,
            disciplineBalance = disciplineBalance,
            balanceVariance = balanceVariance,
            recommendations = recommendations,
        }
    end)

    if success and allocations then
        data.spent = allocations.totalSpent
        data.disciplines = allocations.disciplines
        data.analysis.slottableSkills = allocations.slottableCount
        data.analysis.passiveSkills = allocations.passiveCount
        data.analysis.investmentLevel = allocations.investmentLevel
        data.analysis.disciplineBalance = allocations.disciplineBalance
        data.analysis.balanceVariance = allocations.balanceVariance
        data.analysis.recommendations = allocations.recommendations or {}

        -- Recalculate available if needed
        if data.available == nil or data.available < 0 then
            data.available = data.total - data.spent
        end

        -- Add recommendation for unspent CP if available
        if data.available > 50 then
            table.insert(
                data.analysis.recommendations,
                string.format("You have %d unspent CP available - consider allocating them", data.available)
            )
        end
    else
        -- Fallback: use API data directly
        data.spent = cpPoints.spent or 0
        if data.available == nil then
            data.available = data.total - data.spent
        end
    end

    return data
end

CM.collectors.CollectChampionPointData = CollectChampionPointData

CM.DebugPrint("COLLECTOR", "Champion collector module loaded")
