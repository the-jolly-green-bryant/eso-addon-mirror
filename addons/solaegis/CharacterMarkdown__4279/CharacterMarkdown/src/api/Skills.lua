-- CharacterMarkdown - API Layer - Skills
-- Abstraction for abilities, skill lines, and points

local CM = CharacterMarkdown
CM.api = CM.api or {}
CM.api.skills = {}

local api = CM.api.skills

-- =====================================================
-- CACHING
-- =====================================================

local _skillCache = {
    types = nil,
    lines = {}, -- Cache by skillType index
}

-- =====================================================
-- ACTION BAR SLOT INDICES
-- =====================================================
-- ESO globals ACTION_BAR_*_SLOT_INDEX are 0-based. GetSlotBoundId and related
-- APIs expect 1-based indices (client code always uses CONSTANT + 1).

function api.GetUltimateActionBarSlotIndex()
    return (ACTION_BAR_ULTIMATE_SLOT_INDEX or 7) + 1 -- → 8
end

function api.GetFirstNormalActionBarSlotIndex()
    return (ACTION_BAR_FIRST_NORMAL_SLOT_INDEX or 2) + 1 -- → 3
end

---Detect active class skill lines and which are subclassed (foreign classId).
---@return table {native=table, subclassed=table, hasSubclassing=bool, summary=string}
function api.GetSubclassConfiguration()
    local result = {
        native = {},
        subclassed = {},
        hasSubclassing = false,
        summary = "None (native class lines)",
    }

    local playerClassId = CM.SafeCall(GetUnitClassId, "player")
    if not playerClassId or playerClassId == 0 then
        return result
    end

    local skillTypeClass = SKILL_TYPE_CLASS or 1
    local genderId = CM.SafeCall(GetUnitGender, "player") or GENDER_MALE
    local classNames = CM.constants and CM.constants.CLASS_NAMES
    local numLines = CM.SafeCall(GetNumSkillLines, skillTypeClass) or 0

    for skillLineIndex = 1, numLines do
        local success, rank, _, isActive, isDiscovered =
            CM.SafeCallMulti(GetSkillLineDynamicInfo, skillTypeClass, skillLineIndex)
        if success and isActive and isDiscovered then
            local skillLineId = CM.SafeCall(GetSkillLineId, skillTypeClass, skillLineIndex)
            local name = skillLineId and CM.SafeCall(GetSkillLineNameById, skillLineId) or nil
            local lineClassId = CM.SafeCall(GetSkillLineClassId, skillTypeClass, skillLineIndex)

            if name and name ~= "" then
                local entry = {
                    name = name,
                    rank = rank or 0,
                    id = skillLineId,
                    classId = lineClassId,
                }

                if lineClassId and lineClassId ~= 0 and lineClassId ~= playerClassId then
                    local sourceClass = CM.SafeCall(GetClassName, genderId, lineClassId)
                    if (not sourceClass or sourceClass == "") and classNames and classNames[lineClassId] then
                        sourceClass = classNames[lineClassId]
                    end
                    if sourceClass and sourceClass ~= "" then
                        sourceClass = zo_strformat("<<1>>", sourceClass)
                    end
                    entry.sourceClass = sourceClass or "Unknown"
                    table.insert(result.subclassed, entry)
                else
                    table.insert(result.native, entry)
                end
            end
        end
    end

    result.hasSubclassing = #result.subclassed > 0
    if result.hasSubclassing then
        local parts = {}
        for _, line in ipairs(result.subclassed) do
            if line.sourceClass and line.sourceClass ~= "Unknown" then
                table.insert(parts, string.format("%s (%s)", line.name, line.sourceClass))
            else
                table.insert(parts, line.name)
            end
        end
        result.summary = table.concat(parts, ", ")
    elseif #result.native > 0 then
        local parts = {}
        for _, line in ipairs(result.native) do
            table.insert(parts, line.name)
        end
        result.summary = "None — " .. table.concat(parts, " / ")
    end

    return result
end

function api.IsUltimateActionBarSlot(slotIndex)
    return slotIndex == api.GetUltimateActionBarSlotIndex()
end

-- =====================================================
-- GRANULAR GETTERS
-- =====================================================

function api.GetSkillPoints()
    local unspent = CM.SafeCall(GetAvailableSkillPoints) or 0

    return {
        total = nil, -- No reliable total-skill-points API in current ESO client
        unspent = unspent,
        used = nil,
    }
end

function api.GetSlotAbility(slotIndex, hotbarCategory)
    -- Returns info about ability in a specific bar slot
    local slotType = CM.SafeCall(GetSlotType, slotIndex, hotbarCategory)
    local abilityId = CM.SafeCall(GetSlotBoundId, slotIndex, hotbarCategory)

    if not abilityId or abilityId == 0 then
        return nil
    end

    local name, icon
    local isUltimate = api.IsUltimateActionBarSlot(slotIndex)

    if slotType == ACTION_TYPE_CRAFTED_ABILITY then
        name = CM.SafeCall(GetCraftedAbilityDisplayName, abilityId)
        icon = CM.SafeCall(GetCraftedAbilityIcon, abilityId)
    else
        name = CM.SafeCall(GetAbilityName, abilityId, "player")
        icon = CM.SafeCall(GetAbilityIcon, abilityId)
    end

    return {
        id = abilityId,
        name = name or "Unknown",
        icon = icon,
        isUltimate = isUltimate,
        slotType = slotType,
    }
end

function api.GetActionBar(hotbarCategory)
    local bar = {}
    -- ESO 0-based: ACTION_BAR_FIRST_NORMAL_SLOT_INDEX=2, ACTION_BAR_ULTIMATE_SLOT_INDEX=7.
    -- GetSlotBoundId uses 1-based: slots 3-7 normal abilities, slot 8 ultimate.
    -- Slots 1/2 are light/heavy attack helpers.

    local firstNormal = api.GetFirstNormalActionBarSlotIndex()
    local ultimateSlot = api.GetUltimateActionBarSlotIndex()

    for i = firstNormal, ultimateSlot do
        local ability = api.GetSlotAbility(i, hotbarCategory)
        if ability then
            table.insert(bar, ability)
        else
            table.insert(bar, { id = 0, name = "Empty" })
        end
    end
    return bar
end

function api.GetSkillTypes()
    -- Return cached if available
    if _skillCache.types then
        return _skillCache.types
    end

    local numSkillTypes = CM.SafeCall(GetNumSkillTypes) or 0
    local types = {}

    local skillTypeNames = CM.Constants.SKILL_TYPE_NAMES

    -- Force iteration of known skill types (1-9) to ensure we get them even if GetNumSkillTypes fails
    local maxSkillType = 9
    local apiNumTypes = CM.SafeCall(GetNumSkillTypes) or 0
    if apiNumTypes > maxSkillType then
        maxSkillType = apiNumTypes
    end

    for skillType = 1, maxSkillType do
        local typeName = skillTypeNames[skillType]
        -- Try to get localized name if possible, otherwise fallback to English
        if not typeName then
            typeName = CM.SafeCall(GetString, "SI_SKILLTYPE", skillType)
        end

        -- If we have a name (either hardcoded or from API), add it
        if typeName and typeName ~= "" then
            table.insert(types, {
                index = skillType,
                name = typeName,
            })
        end
    end

    -- Cache the result
    _skillCache.types = types
    -- CM.Warn("GetSkillTypes found " .. tostring(numSkillTypes) .. " types")
    return types
end

function api.GetSkillLinesByType(skillType)
    if not skillType then
        return {}
    end

    -- Return cached if available
    if _skillCache.lines[skillType] then
        return _skillCache.lines[skillType]
    end

    local numSkillLines = CM.SafeCall(GetNumSkillLines, skillType) or 0
    local lines = {}

    for skillLineIndex = 1, numSkillLines do
        local success, rank, _, _, discovered =
            CM.SafeCallMulti(GetSkillLineDynamicInfo, skillType, skillLineIndex)
        local skillLineId = CM.SafeCall(GetSkillLineId, skillType, skillLineIndex)
        local name = skillLineId and CM.SafeCall(GetSkillLineNameById, skillLineId) or nil
        if success and name and discovered then
            table.insert(lines, {
                index = skillLineIndex,
                name = name,
                rank = rank or 0,
                id = skillLineId,
            })
        end
    end

    -- Cache the result
    _skillCache.lines[skillType] = lines
    -- CM.Warn("GetSkillLinesByType(" .. tostring(skillType) .. ") found " .. tostring(numSkillLines) .. " lines")
    return lines
end

function api.GetSkillLines()
    -- Use cached data from GetSkillLinesByType if available, otherwise fetch all
    local skillTypes = api.GetSkillTypes()
    local lines = {}

    for _, skillType in ipairs(skillTypes) do
        local typeLines = api.GetSkillLinesByType(skillType.index)
        for _, line in ipairs(typeLines) do
            -- Get XP info for full skill lines (not cached in GetSkillLinesByType)
            local success_xp, lastXP, nextXP, currentXP =
                CM.SafeCallMulti(GetSkillLineXPInfo, skillType.index, line.index)

            if not success_xp then
                CM.Warn("GetSkillLineXPInfo failed for " .. line.name)
                lastXP = 0
                nextXP = 0
                currentXP = 0
            end

            table.insert(lines, {
                type = skillType.index,
                index = line.index,
                name = line.name,
                rank = line.rank,
                xp = { current = currentXP, min = lastXP, max = nextXP },
            })
        end
    end

    return lines
end

function api.GetSkillAbilitiesWithMorphs(skillType, skillLineIndex)
    if not skillType or not skillLineIndex then
        return {}
    end

    local numAbilities = CM.SafeCall(GetNumSkillAbilities, skillType, skillLineIndex) or 0
    local abilities = {}

    for abilityIndex = 1, numAbilities do
        local success, abilityName, icon, earnedRank, passive, ultimate, purchased, progressionIndex, rankIndex =
            CM.SafeCallMulti(GetSkillAbilityInfo, skillType, skillLineIndex, abilityIndex)

        if success and abilityName and not passive and progressionIndex then
            -- Get progression info
            local success_prog, progName, currentMorph, currentRank =
                CM.SafeCallMulti(GetAbilityProgressionInfo, progressionIndex)

            if progName then
                -- Get XP info to check if at morph level
                local success_xp, lastXP, nextXP, currXP, atMorph =
                    CM.SafeCallMulti(GetAbilityProgressionXPInfo, progressionIndex)

                local ability = {
                    name = abilityName,
                    earnedRank = earnedRank or 0,
                    purchased = purchased or false,
                    ultimate = ultimate or false,
                    progressionIndex = progressionIndex,
                    currentMorph = currentMorph or 0,
                    currentRank = currentRank or 0,
                    atMorphChoice = (atMorph == true) or false,
                    morphs = {},
                }

                -- Get morph options
                -- Morph 1 (upper morph)
                local morph1Id = CM.SafeCall(GetAbilityProgressionAbilityId, progressionIndex, 1, 1)
                if morph1Id and morph1Id > 0 then
                    local morph1Name = CM.SafeCall(GetAbilityName, morph1Id, "player")
                    if morph1Name and morph1Name ~= "" then
                        table.insert(ability.morphs, {
                            name = morph1Name,
                            morphSlot = 1,
                            abilityId = morph1Id,
                            selected = (currentMorph == 1),
                        })
                    end
                end

                -- Morph 2 (lower morph)
                local morph2Id = CM.SafeCall(GetAbilityProgressionAbilityId, progressionIndex, 2, 1)
                if morph2Id and morph2Id > 0 then
                    local morph2Name = CM.SafeCall(GetAbilityName, morph2Id, "player")
                    if morph2Name and morph2Name ~= "" then
                        table.insert(ability.morphs, {
                            name = morph2Name,
                            morphSlot = 2,
                            abilityId = morph2Id,
                            selected = (currentMorph == 2),
                        })
                    end
                end

                -- Only include if it has morphs
                if #ability.morphs > 0 then
                    table.insert(abilities, ability)
                end
            end
        end
    end

    return abilities
end

function api.GetSkillPassives(skillType, skillLineIndex)
    if not skillType or not skillLineIndex then
        return {}
    end

    local numAbilities = CM.SafeCall(GetNumSkillAbilities, skillType, skillLineIndex) or 0
    local passives = {}

    for abilityIndex = 1, numAbilities do
        local success, abilityName, icon, earnedRank, passive, ultimate, purchased, progressionIndex, rankIndex =
            CM.SafeCallMulti(GetSkillAbilityInfo, skillType, skillLineIndex, abilityIndex)

        if success and abilityName and passive then
            local currentRank = 0
            local maxRank = 0

            -- For passives, we need to check if they are purchased and their rank
            if purchased then
                local successUpgrade, currentRank, maxRank =
                    CM.SafeCallMulti(GetSkillAbilityUpgradeInfo, skillType, skillLineIndex, abilityIndex)
                currentRank = (successUpgrade and currentRank) or 0
            end

            -- Get max rank for the passive
            -- There isn't a direct API for max rank of a passive, but usually it's 2 or 3.
            -- We can try to deduce it or just report current rank.
            -- Actually GetSkillAbilityUpgradeInfo returns current level.
            -- GetSkillAbilityNextUpgradeInfo might help?

            -- Let's just store what we have.
            -- We can get the link using the abilityId if we can find it.
            -- GetSkillAbilityId(skillType, skillLineIndex, abilityIndex, recursive)
            local abilityId = CM.SafeCall(GetSkillAbilityId, skillType, skillLineIndex, abilityIndex, false)

            table.insert(passives, {
                name = abilityName,
                rank = currentRank,
                purchased = purchased,
                abilityId = abilityId,
                icon = icon,
            })
        elseif passive and (not abilityName or type(abilityName) ~= "string") then
            -- Debug: Log when we get invalid ability names
            CM.DebugPrint(
                "SKILLS_API",
                string.format(
                    "GetSkillPassives: Invalid abilityName (type=%s, value=%s) for skillType=%d, skillLineIndex=%d, abilityIndex=%d",
                    type(abilityName),
                    tostring(abilityName),
                    skillType,
                    skillLineIndex,
                    abilityIndex
                )
            )
        end
    end

    return passives
end

function api.ClearCache()
    _skillCache = {
        types = nil,
        lines = {},
    }
end

-- Composition functions moved to collector level

-- Internal function to generate morph data (used by GetInfo)
-- playerClass: Optional parameter - should be passed from collector level
--             Defaults to "Unknown" if not provided (for backward compatibility)
function api._GetMorphsData(playerClass)
    playerClass = playerClass or "Unknown"

    -- Class skill line mapping for filtering
    local classSkillLines = CM.Constants.CLASS_SKILL_LINES
    local invalidSkillTypes = CM.Constants.INVALID_SKILL_TYPES
    local invalidSkillLines = CM.Constants.INVALID_SKILL_LINES
    local skillTypeEmojis = CM.Constants.SKILL_TYPE_EMOJIS

    local processedProgressions = {}
    local skillTypes = api.GetSkillTypes()
    local data = {}

    for _, skillType in ipairs(skillTypes) do
        if not invalidSkillTypes[skillType.name] then
            local skillLines = api.GetSkillLinesByType(skillType.index)
            local emoji = skillTypeEmojis[skillType.name] or "📜"
            local filteredLines = {}

            for _, skillLine in ipairs(skillLines) do
                if not invalidSkillLines[skillLine.name] then
                    -- Filter class skills for other classes
                    local isClassSkill = (skillType.name == "Class")
                    local isPlayerClass = true

                    if isClassSkill then
                        -- Class skills returned by GetSkillLinesByType are always the player's class skills
                        -- because you cannot discover other classes' skill lines.
                        isPlayerClass = true
                    end

                    if isPlayerClass then
                        local abilities = api.GetSkillAbilitiesWithMorphs(skillType.index, skillLine.index)

                        -- Filter out already processed progressions
                        local filteredAbilities = {}
                        for _, ability in ipairs(abilities) do
                            if not processedProgressions[ability.progressionIndex] then
                                processedProgressions[ability.progressionIndex] = true
                                table.insert(filteredAbilities, ability)
                            end
                        end

                        if #filteredAbilities > 0 then
                            table.insert(filteredLines, {
                                name = skillLine.name,
                                rank = skillLine.rank,
                                abilities = filteredAbilities,
                            })
                        end
                    end
                end
            end

            if #filteredLines > 0 then
                table.insert(data, {
                    name = skillType.name,
                    emoji = emoji,
                    skillLines = filteredLines,
                })
            end
        end
    end

    return data
end
