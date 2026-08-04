-- CharacterMarkdown - Skills Data Collector
-- Composition logic moved from API layer

local CM = CharacterMarkdown

-- =====================================================
-- SKILL BARS
-- =====================================================

local function CollectSkillBarData()
    -- Use API layer granular functions (composition at collector level)
    local skillPoints = CM.api.skills.GetSkillPoints()
    local firstNormal = CM.api.skills.GetFirstNormalActionBarSlotIndex()
    local ultimateSlot = CM.api.skills.GetUltimateActionBarSlotIndex()

    local bars = {}

    local barConfigs = {
        { id = 0, name = CM.Constants.BAR_NAMES.PRIMARY, hotbarCategory = HOTBAR_CATEGORY_PRIMARY },
        { id = 1, name = CM.Constants.BAR_NAMES.BACKUP, hotbarCategory = HOTBAR_CATEGORY_BACKUP },
    }

    for _, config in ipairs(barConfigs) do
        local bar = {
            id = config.id,
            name = config.name,
            abilities = {},
        }

        -- Regular ability slots (3-7): five entries, including empties
        local displayIndex = 0
        for slotIndex = firstNormal, ultimateSlot - 1 do
            displayIndex = displayIndex + 1
            local ability = CM.api.skills.GetSlotAbility(slotIndex, config.hotbarCategory)
            if ability and ability.id and ability.id > 0 then
                table.insert(bar.abilities, {
                    index = displayIndex,
                    slot = slotIndex,
                    name = ability.name or "Unknown",
                    id = ability.id,
                    isUltimate = false,
                    isCrafted = ability.isCrafted or false,
                    scripts = ability.scripts,
                })
            else
                table.insert(bar.abilities, {
                    index = displayIndex,
                    slot = slotIndex,
                    name = "[Empty Slot]",
                    id = nil,
                    isUltimate = false,
                })
            end
        end

        -- Ultimate slot (8)
        local ultAbility = CM.api.skills.GetSlotAbility(ultimateSlot, config.hotbarCategory)
        if ultAbility and ultAbility.id and ultAbility.id > 0 then
            bar.ultimate = ultAbility.name or "Empty"
            bar.ultimateId = ultAbility.id
            bar.ultimateIsCrafted = ultAbility.isCrafted or false
            bar.ultimateScripts = ultAbility.scripts
        end

        table.insert(bars, bar)
    end

    local data = {
        bars = bars,
        points = skillPoints,
        activeWeaponPair = CM.api.skills.GetActiveWeaponPair and CM.api.skills.GetActiveWeaponPair() or nil,
        subclassingAccess = CM.api.skills.GetSubclassingAccess and CM.api.skills.GetSubclassingAccess() or nil,
    }

    -- Add computed fields
    local totalAbilities = 0
    local ultimateCount = 0
    for _, bar in ipairs(bars) do
        if bar.abilities then
            for _, ability in ipairs(bar.abilities) do
                totalAbilities = totalAbilities + 1
                if ability.isUltimate then
                    ultimateCount = ultimateCount + 1
                end
            end
        end
    end

    data.summary = {
        totalAbilities = totalAbilities,
        ultimateCount = ultimateCount,
        regularAbilities = totalAbilities - ultimateCount,
    }

    return data
end

CM.collectors.CollectSkillBarData = CollectSkillBarData

-- =====================================================
-- SKILL PROGRESSION
-- =====================================================

local function CollectSkillProgressionData()
    -- Use API layer granular functions (composition at collector level)
    local skillLines = CM.api.skills.GetSkillLines()

    local data = {
        lines = skillLines,
        summary = {
            totalLines = 0,
            totalSkills = 0,
            totalMorphs = 0,
            totalPassives = 0,
            maxedCount = 0,
            inProgressCount = 0,
            earlyProgressCount = 0,
            completionPercent = 0,
        },
    }

    -- Helper to check if a line is maxed
    -- Logic: If nextXP is 0, it usually means max rank.
    -- Also check common max ranks (50 for most, 10 for guilds/world, etc)
    local function IsMaxed(line)
        if line.xp and line.xp.max == 0 then
            return true
        end
        -- Fallback for when XP info might be weird but rank is clearly high
        if line.rank == 50 then
            return true
        end
        -- Guilds/World often max at 10
        if (line.rank == 10) and (line.xp.max == 0 or line.xp.current >= line.xp.max) then
            return true
        end
        return false
    end

    -- Calculate summary statistics and categorize
    if skillLines then
        data.summary.totalLines = #skillLines

        local loopCount = 0
        for _, line in ipairs(skillLines) do
            loopCount = loopCount + 1
            -- Calculate progress percent for the line
            local current = line.xp.current or 0
            local min = line.xp.min or 0
            local max = line.xp.max or 0
            local progress = 0

            if max > 0 and max > min then
                progress = math.floor(((current - min) / (max - min)) * 100)
            elseif IsMaxed(line) then
                progress = 100
            end
            line.progress = progress

            -- Add status field instead of separate arrays
            if IsMaxed(line) then
                line.status = "maxed"
                -- Fetch passives for maxed lines
                line.passives = CM.api.skills.GetSkillPassives(line.type, line.index)
                data.summary.maxedCount = data.summary.maxedCount + 1
            elseif line.rank > 1 or progress > 0 then
                line.status = "in_progress"
                -- Fetch passives for in-progress lines too
                line.passives = CM.api.skills.GetSkillPassives(line.type, line.index)
                data.summary.inProgressCount = data.summary.inProgressCount + 1
            else
                line.status = "early"
                data.summary.earlyProgressCount = data.summary.earlyProgressCount + 1
            end

            -- Let's fetch abilities for counting
            local abilities = CM.api.skills.GetSkillAbilitiesWithMorphs(line.type, line.index)
            for _, skill in ipairs(abilities) do
                data.summary.totalSkills = data.summary.totalSkills + 1
                if skill.morphs then
                    data.summary.totalMorphs = data.summary.totalMorphs + #skill.morphs
                end
            end

            -- Count passives (reuse cached passives when already fetched)
            local passives = line.passives or CM.api.skills.GetSkillPassives(line.type, line.index)
            data.summary.totalPassives = data.summary.totalPassives + #passives
        end

        -- Calculate overall completion
        if data.summary.totalLines > 0 then
            data.summary.completionPercent = math.floor((data.summary.maxedCount / data.summary.totalLines) * 100)
        end
    end

    return data
end

CM.collectors.CollectSkillProgressionData = CollectSkillProgressionData

-- =====================================================
-- SKILL MORPHS
-- =====================================================

local function CollectSkillMorphsData()
    -- Use API layer for skill morphs data
    -- Get player class from Character API to pass to Skills API
    local characterInfo = CM.api.character.GetClass()
    local playerClass = characterInfo and characterInfo.name or "Unknown"

    -- Use internal API function for morphs (composition at collector level)
    local morphsData = CM.api.skills._GetMorphsData(playerClass) or {}

    -- Add computed fields for morph analysis
    local totalMorphs = 0
    local chosenMorphs = 0
    local availableMorphs = 0

    for _, skillType in ipairs(morphsData) do
        if skillType.skillLines then
            for _, line in ipairs(skillType.skillLines) do
                if line.abilities then
                    for _, ability in ipairs(line.abilities) do
                        totalMorphs = totalMorphs + 1
                        -- Check if a morph is chosen (currentMorph > 0)
                        if ability.currentMorph and ability.currentMorph > 0 then
                            chosenMorphs = chosenMorphs + 1
                        else
                            availableMorphs = availableMorphs + 1
                        end
                    end
                end
            end
        end
    end

    local data = {
        class = playerClass,
        skillTypes = morphsData,
        summary = {
            totalMorphs = totalMorphs,
            chosenMorphs = chosenMorphs,
            availableMorphs = availableMorphs,
            completionPercent = totalMorphs > 0 and math.floor((chosenMorphs / totalMorphs) * 100) or 0,
        },
    }

    -- Debug output
    if CM.DebugPrint then
        CM.DebugPrint("SKILL_MORPHS", string.format("Collected %d skill types with morphs", #morphsData))
    end

    return data
end

CM.collectors.CollectSkillMorphsData = CollectSkillMorphsData

CM.DebugPrint("COLLECTOR", "Skills collector module loaded")
