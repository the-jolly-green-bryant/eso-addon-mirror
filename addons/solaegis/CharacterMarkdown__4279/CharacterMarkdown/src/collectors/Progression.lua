-- CharacterMarkdown - Progression Data Collector
-- Composition logic moved from API layer

local CM = CharacterMarkdown

-- =====================================================
-- PROGRESSION DATA
-- =====================================================

local function CollectProgressionData()
    -- Use API layer granular functions (composition at collector level)
    local skillPoints = CM.api.skills.GetSkillPoints()
    local attributes = CM.api.combat.GetAttributes()
    local achievementPoints = CM.api.achievements.GetPoints()
    local championPoints = CM.api.champion.GetPoints()
    local buffData = CM.api.combat.GetBuffs()
    local enlightenment = CM.api.progression.GetEnlightenment()

    local progression = {}

    -- Skill points from API
    progression.skillPoints = skillPoints.unspent or 0
    progression.unspentSkillPoints = progression.skillPoints
    progression.totalSkillPoints = skillPoints.total or 0

    -- Attribute points from API
    progression.attributePoints = attributes.unspent or 0
    progression.unspentAttributePoints = progression.attributePoints

    -- Achievement points from API
    progression.achievementPoints = achievementPoints.earned or 0
    progression.totalAchievements = achievementPoints.total or 0
    progression.achievementPercent = progression.totalAchievements > 0
            and math.floor((progression.achievementPoints / progression.totalAchievements) * 100)
        or 0

    -- Available Champion Points (unspent) from API
    progression.availableChampionPoints = championPoints.unspent or 0

    -- Vampire/Werewolf status from API
    if buffData.special then
        progression.isVampire = buffData.special.isVampire or false
        progression.isWerewolf = buffData.special.isWerewolf or false
        progression.vampireStage = buffData.special.vampireStage or 0
        progression.werewolfStage = buffData.special.werewolfStage or 0
    else
        progression.isVampire = false
        progression.isWerewolf = false
        progression.vampireStage = 0
        progression.werewolfStage = 0
    end

    -- Enlightenment from API
    local pool = enlightenment.current or 0
    local cap = enlightenment.max or 0
    progression.enlightenment = {
        current = pool,
        max = cap,
        percent = (cap > 0) and math.floor((pool / cap) * 100) or 0,
        efficiency = cap > 0 and math.floor((pool / cap) * 100) or 0, -- Same as percent, but named for clarity
        remaining = cap - pool,
    }

    -- Add computed progression rate metrics
    -- These are rough estimates based on available data
    progression.metrics = {
        skillPointEfficiency = progression.totalSkillPoints > 0 and math.floor(
            (progression.skillPoints / progression.totalSkillPoints) * 100
        ) or 0,
        achievementProgress = progression.achievementPercent,
        enlightenmentProgress = progression.enlightenment.percent,
    }

    return progression
end

CM.collectors.CollectProgressionData = CollectProgressionData

-- =====================================================
-- RIDING SKILLS
-- =====================================================

local function CollectRidingSkillsData()
    -- Use API layer granular functions (composition at collector level)
    local riding = CM.api.progression.GetRidingSkills()
    local maxedOut = (riding.maxCapacity > 0 and riding.capacity >= riding.maxCapacity)
        and (riding.maxStamina > 0 and riding.stamina >= riding.maxStamina)
        and (riding.maxSpeed > 0 and riding.speed >= riding.maxSpeed)
    riding.maxedOut = maxedOut
    return riding
end

CM.collectors.CollectRidingSkillsData = CollectRidingSkillsData

CM.DebugPrint("COLLECTOR", "Progression collector module loaded")
