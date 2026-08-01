GuildPlannerPro_Skills = {
    ClassSkillLineMap = {
        [1] = { 35, 36, 37 }, -- Dragonknight
        [2] = { 41, 42, 43 }, -- Sorcerer
        [3] = { 38, 39, 40 }, -- Nightblade
        [4] = { 22, 27, 28 }, -- Templar
        [5] = { 127, 128, 129 }, -- Warden
        [6] = { 131, 132, 133 }, -- Necromancer
        [7] = { 218, 219, 220 }, -- Arcanist
    },
}

function GuildPlannerPro_Skills:MapChampionPoints()
    local champion = {
        Disciplines = {},
    }
    if IsChampionSystemUnlocked() then
        local numChampionDiscliplines = GetNumChampionDisciplines()
        for disciplineIndex = 1, numChampionDiscliplines do
            local disciplineId = GetChampionDisciplineId(disciplineIndex)
            local skills = {}
            local numSkills = GetNumChampionDisciplineSkills(disciplineIndex)
            for skillIndex = 1, numSkills do
                local skillId = GetChampionSkillId(disciplineIndex, skillIndex)
                local normalizedX, normalizedY = GetChampionSkillPosition(skillId)
                local normalizedOffsetX, normalizedOffsetY = GetChampionClusterRootOffset(skillId)
                local maxPoints = GetChampionSkillMaxPoints(skillId)
                local jumpPoints = { GetChampionSkillJumpPoints(skillId) }

                local bonusSteps, prevBonusText, currBonusText = nil, '', ''
                if #jumpPoints > 2 then
                    bonusSteps = {}
                    for bonusPoint = 1, maxPoints do
                        currBonusText = GetChampionSkillCurrentBonusText(skillId, bonusPoint)
                        if currBonusText and currBonusText ~= prevBonusText then
                            bonusSteps[bonusPoint] = currBonusText
                        end
                        prevBonusText = currBonusText
                    end
                end

                local nodeUnlocksAtXPoints = 0
                for bonusPoint = 1, maxPoints do
                    local wouldNodeBeUnlocked = WouldChampionSkillNodeBeUnlocked(skillId, bonusPoint)
                    if wouldNodeBeUnlocked and nodeUnlocksAtXPoints == 0 then
                        nodeUnlocksAtXPoints = bonusPoint
                    end
                end

                skills[skillIndex] = {
                    Id = skillId,
                    Name = GetChampionSkillName(skillId),
                    Description = GetChampionSkillDescription(skillId, 0),
                    Type = GetChampionSkillType(skillId),
                    MaxPoints = maxPoints,
                    NodeUnlocksAtXPoints = nodeUnlocksAtXPoints,
                    BonusSteps = bonusSteps,
                    ChampionAbilityId = GetChampionAbilityId(skillId),
                    LinkedSkillIds = { GetChampionSkillLinkIds(skillId) },
                    JumpPoints = jumpPoints,
                    IsRootNode = IsChampionSkillRootNode(skillId),
                    IsClusterRoot = IsChampionSkillClusterRoot(skillId),
                    ClusterName = GetChampionClusterName(skillId),
                    ClusterBackground = GetChampionClusterBackgroundTexture(skillId),
                    ClusterSkillIds = { GetChampionClusterSkillIds(skillId) },
                    PositionX = normalizedX,
                    PositionY = normalizedY,
                    ClusterRootOffsetX = normalizedOffsetX,
                    ClusterRootOffsetY = normalizedOffsetY,
                }
            end

            champion["Disciplines"][disciplineIndex] = {
                Id = disciplineId,
                Name = GetChampionDisciplineName(disciplineId),
                Type = GetChampionDisciplineType(disciplineId),
                ZoomedOutBg = GetChampionDisciplineZoomedOutBackground(disciplineId),
                ZoomedInBg = GetChampionDisciplineZoomedInBackground(disciplineId),
                Skills = skills,
            }
        end
    end

    return champion
end

function GuildPlannerPro_Skills:ExportChampionPoints()
    local champion = {
        Disciplines = {},
    }
    if IsChampionSystemUnlocked() then
        local numChampionDiscliplines = GetNumChampionDisciplines()
        for disciplineIndex = 1, numChampionDiscliplines do
            local disciplineId = GetChampionDisciplineId(disciplineIndex)
            local skills = {}
            local numSkills = GetNumChampionDisciplineSkills(disciplineIndex)
            for skillIndex = 1, numSkills do
                local skillId = GetChampionSkillId(disciplineIndex, skillIndex)
                local pointsSpent = GetNumPointsSpentOnChampionSkill(skillId)
                table.insert(skills, {
                    SkillId = skillId,
                    SkillIndex = skillIndex,
                    CurrentBonusText = GetChampionSkillCurrentBonusText(skillId, pointsSpent),
                    PointsSpent = pointsSpent,
                    MaxPossiblePoints = GetMaxPossiblePointsInChampionSkill(skillIndex),
                })
            end

            table.insert(champion["Disciplines"], {
                DisciplineId = disciplineId,
                DisciplineIndex = disciplineIndex,
                PointsSpent = GetNumSpentChampionPoints(disciplineId),
                PointsUnspent = GetNumUnspentChampionPoints(disciplineId),
                Skills = skills,
            })
        end
    end

    return champion
end

function GuildPlannerPro_Skills:GetActiveSkillFacts(abilityId)
    local channeled, durationValue = GetAbilityCastInfo(abilityId, MAX_RANKS_PER_ABILITY)
    local _, maxRangeCm = GetAbilityRange(abilityId, MAX_RANKS_PER_ABILITY)
    local _, mechanicFlags, isCostChargedPerTick = GetAbilityBaseCostInfo(abilityId, MAX_RANKS_PER_ABILITY)

    local baseCost
    local mechanic = GetNextAbilityMechanicFlag(abilityId)
    while mechanic do
        local cost = GetAbilityCost(abilityId, mechanic, MAX_RANKS_PER_ABILITY)
        if cost ~= 0 then
            baseCost = baseCost or {}
            table.insert(baseCost or {}, {
                Value = cost,
                Mechanic = GuildPlannerPro_Const.CombatMechanicFlags[mechanic],
                IsCostChargedPerTick = isCostChargedPerTick,
            })
        end
        mechanic = GetNextAbilityMechanicFlag(abilityId, mechanic)
    end

    return {
        CastInfo = {
            IsChanneled = channeled,
            DurationValue = durationValue,
        },
        Radius = GetAbilityRadius(abilityId, MAX_RANKS_PER_ABILITY),
        Range = maxRangeCm,
        AngleDistance = GetAbilityAngleDistance(abilityId),
        DurationToggled = IsAbilityDurationToggled(abilityId),
        DurationMs = GetAbilityDuration(abilityId, MAX_RANKS_PER_ABILITY),
        Cooldown = GetAbilityCooldown(abilityId),
        Target = GetAbilityTargetDescription(abilityId, MAX_RANKS_PER_ABILITY),
        BaseCost = baseCost,
        FrequencyMs = GetAbilityFrequencyMS(abilityId),
        CostPerTick = GetAbilityCostPerTick(abilityId, mechanicFlags, MAX_RANKS_PER_ABILITY),
    }
end

function GuildPlannerPro_Skills:CollectSkillAliasIds()
    local result = {}
    local dataMap = SKILLS_DATA_MANAGER.abilityIdToProgressionDataMap
    for aliasId, skill in pairs(dataMap) do
        local abilityId = skill.abilityId
        if aliasId ~= abilityId then
            if result[abilityId] == nil then
                result[abilityId] = {}
            end
            table.insert(result[abilityId], aliasId)
        end
    end

    return result
end

function GuildPlannerPro_Skills:MapSkillLines()
    local result = {}
    if not AreSkillsInitialized() then
        GuildPlannerPro_Utils:PrintMessage("Skills not initialized yet.")

        return
    end

    local skillTypeObjectPool = SKILLS_DATA_MANAGER.skillTypeObjectPool
    local skillTypes = skillTypeObjectPool:GetActiveObjects()
    for skillType, skillTypeData in ipairs(skillTypes) do
        local orderedSkillLines = skillTypeData.orderedSkillLines
        for _, skillLineData in ipairs(orderedSkillLines) do
            local skillLineName = skillLineData:GetName();
            if skillLineName:sub(1, 10) ~= "Vengeance " then
                result[skillLineData.id] = {
                    Id = skillLineData.id,
                    Name = skillLineName,
                    FormattedName = skillLineData:GetFormattedName(),
                    Index = skillLineData:GetSkillLineIndex(),
                    UnlockText = skillLineData:GetUnlockText(),
                    IsWerewolf = skillLineData:IsWerewolf(),
                    NumSkills = skillLineData:GetNumSkills(),
                    TypeData = {
                        Id = skillType,
                        Name = skillTypeData:GetName(),
                    },
                    Skills = {},
                }
                if skillType == SKILL_TYPE_CLASS then
                    result[skillLineData.id].TypeData.ClassId = skillLineData:GetClassId()
                    result[skillLineData.id].TypeData.ClassName = skillLineData:GetClassName()
                    result[skillLineData.id].TypeData.IsClassMastery = skillLineData.isClassMastery
                end

                local activeSkillsPool = skillLineData.activeSkillMetaPool:GetActiveObjects()
                for _, skillData in pairs(activeSkillsPool) do
                    local skillIndex = skillData.skillIndex
                    result[skillLineData.id].Skills[skillIndex] = {
                        Index = skillIndex,
                        LineRankNeededToPurchase = skillData.lineRankNeededToPurchase,
                        HeaderText = skillData:GetHeaderText(),
                        IsUltimate = skillData:IsUltimate(),
                        IsPassive = false,
                        IsCrafted = false,
                        ProgressionMap = {},
                    }

                    for _, skillProgression in pairs(skillData.skillProgressions) do
                        local _skill = {}
                        local abilityId = skillProgression.abilityId
                        local progressionKey = skillProgression.skillProgressionKey
                        local isTankRoleAbility, isHealerRoleAbility, isDamageRoleAbility = GetAbilityRoles(abilityId)
                        _skill = {
                            Id = abilityId,
                            CurrentChainedAbilityId = GetCurrentChainedAbility(abilityId),
                            Name = skillProgression.name,
                            Icon = skillProgression.icon,
                            Link = GetAbilityLink(abilityId, LINK_STYLE_BRACKETS),
                            NewEffectLine = GetAbilityNewEffectLines(abilityId),
                            UpgradeLines = GetAbilityUpgradeLines(abilityId),
                            ProgressionKey = progressionKey,
                            DescriptionHeader = GetAbilityDescriptionHeader(abilityId),
                            DescriptionBody = GetAbilityDescription(abilityId, MAX_RANKS_PER_ABILITY, "player"),
                            IsBase = skillProgression:IsBase(),
                            IsMorph = skillProgression:IsMorph(),
                            NumSkillStyles = skillProgression:GetNumSkillStyles(),
                            Roles = {
                                IsTankRoleAbility = isTankRoleAbility,
                                IsHealerRoleAbility = isHealerRoleAbility,
                                IsDamageRoleAbility = isDamageRoleAbility,
                            },
                            Facts = self:GetActiveSkillFacts(abilityId),
                        }
                        if skillProgression:IsMorph() then
                            _skill.MorphSlot = skillProgression:GetMorphSlot()
                            local siblingMorphData = skillProgression:GetSiblingMorphData()
                            _skill.SiblingMorphAbilityId = siblingMorphData.abilityId
                        end

                        result[skillLineData.id].Skills[skillIndex].ProgressionMap[progressionKey] = _skill
                    end
                end

                local passiveSkillsPool = skillLineData.passiveSkillMetaPool:GetActiveObjects()
                for _, skillData in pairs(passiveSkillsPool) do
                    local skillIndex = skillData.skillIndex
                    result[skillLineData.id].Skills[skillIndex] = {
                        Index = skillIndex,
                        LineRankNeededToPurchase = skillData.lineRankNeededToPurchase,
                        HeaderText = skillData:GetHeaderText(),
                        IsUltimate = false,
                        IsPassive = true,
                        IsCrafted = false,
                        NumRanks = skillData:GetNumRanks(),
                        ProgressionMap = {},
                    }

                    for _, skillProgression in pairs(skillData.skillProgressions) do
                        local _skill = {}
                        local abilityId = skillProgression.abilityId
                        local progressionKey = skillProgression.skillProgressionKey
                        _skill = {
                            Id = abilityId,
                            Name = skillProgression.name,
                            Rank = skillProgression:GetRank(),
                            LineRankNeededToUnlock = skillProgression:GetLineRankNeededToUnlock(),
                            Icon = skillProgression.icon,
                            Link = GetAbilityLink(abilityId, LINK_STYLE_BRACKETS),
                            ProgressionKey = progressionKey,
                            DescriptionHeader = GetAbilityDescriptionHeader(abilityId),
                            DescriptionBody = GetAbilityDescription(abilityId, skillProgression:GetRank(), ""),
                        }

                        result[skillLineData.id].Skills[skillIndex].ProgressionMap[progressionKey] = _skill
                    end
                end

                local craftedSkillsPool = skillLineData.craftedActiveSkillMetaPool:GetActiveObjects()
                for _, skillData in pairs(craftedSkillsPool) do
                    local craftedAbilityId = skillData:GetCraftedAbilityId()
                    local skillIndex = skillData.skillIndex
                    local progressionData = skillData:GetProgressionData()
                    result[skillLineData.id].Skills[skillIndex] = {
                        Id = GetCraftedAbilityRepresentativeAbilityId(craftedAbilityId),
                        CraftedAbilityId = craftedAbilityId,
                        Index = skillIndex,
                        Name = GetCraftedAbilityDisplayName(craftedAbilityId),
                        Description = GetCraftedAbilityDescription(craftedAbilityId),
                        AcquireHint = GetCraftedAbilityAcquireHint(craftedAbilityId),
                        Icon = progressionData.icon,
                        GrimoireIcon = GetCraftedAbilityIcon(craftedAbilityId),
                        LineRankNeededToPurchase = skillData.lineRankNeededToPurchase,
                        HeaderText = skillData:GetHeaderText(),
                        IsUltimate = skillData:IsUltimate(),
                        IsPassive = skillData:IsPassive(),
                        IsCrafted = true,
                    }
                end
            end
        end
    end

    return result
end

function GuildPlannerPro_Skills:MapScribables()
    local bySlotMap = {}
    local numCraftedAbilities = GetNumCraftedAbilities();
    for i = 1, numCraftedAbilities do
        bySlotMap[i] = {}
        local craftedAbilityId = GetCraftedAbilityIdAtIndex(i)
        for j = SCRIBING_SLOT_ITERATION_BEGIN, SCRIBING_SLOT_ITERATION_END do
            bySlotMap[i][j] = {}
            local numScripts = GetNumScriptsInSlotForCraftedAbility(craftedAbilityId, j)
            for k = 1, numScripts do
                local scriptDefId = GetScriptIdAtSlotIndexForCraftedAbility(craftedAbilityId, j, k)
                table.insert(bySlotMap[i][j], {
                    CraftedAbilityId = craftedAbilityId,
                    CraftedAbilityName = GetCraftedAbilityDisplayName(craftedAbilityId),
                    ScribingSlot = j,
                    ScriptId = scriptDefId,
                    ScriptIndex = k,
                    ScriptName = GetCraftedAbilityScriptDisplayName(scriptDefId),
                    ScriptGeneralDescription = GetCraftedAbilityScriptGeneralDescription(scriptDefId),
                    ScriptDescription = GetCraftedAbilityScriptDescription(craftedAbilityId, scriptDefId),
                    ScriptIcon = GetCraftedAbilityScriptIcon(scriptDefId),
                    ScriptAcquireHint = GetCraftedAbilityScriptAcquireHint(scriptDefId),
                })
            end
        end
    end

    local linksToIdsMap = {}
    local idsToLinksMap = {}
    for craftedAbilityId, slotData in pairs(bySlotMap) do
        for _, focusScript in pairs(slotData[SCRIBING_SLOT_PRIMARY]) do
            for _, signatureScript in pairs(slotData[SCRIBING_SLOT_SECONDARY]) do
                for _, affixScript in pairs(slotData[SCRIBING_SLOT_TERTIARY]) do
                    if IsScribableScriptCombinationForCraftedAbility(craftedAbilityId, focusScript["ScriptId"], signatureScript["ScriptId"], affixScript["ScriptId"]) then
                        SetCraftedAbilityScriptSelectionOverride(craftedAbilityId, focusScript["ScriptId"], signatureScript["ScriptId"], affixScript["ScriptId"]);
                        local representativeAbilityId = GetCraftedAbilityRepresentativeAbilityId(craftedAbilityId);
                        local link = "|H1:crafted_ability:" .. craftedAbilityId .. ":" .. focusScript["ScriptId"] .. ":" .. signatureScript["ScriptId"] .. ":" .. affixScript["ScriptId"] .. "|h|h"
                        linksToIdsMap[link] = representativeAbilityId
                        if idsToLinksMap[representativeAbilityId] == nil then
                            idsToLinksMap[representativeAbilityId] = {}
                        end
                        table.insert(idsToLinksMap[representativeAbilityId], link)
                        ResetCraftedAbilityScriptSelectionOverride()
                    end
                end
            end
        end
    end

    return {
        BySlotMap = bySlotMap,
        LinksToIdsMap = linksToIdsMap,
        IdsToLinksMap = idsToLinksMap,
    }
end

function GuildPlannerPro_Skills:ExportCharacterSkillLines()
    local skillLines = {}
    local abilityIdToProgressionDataMap = SKILLS_DATA_MANAGER.abilityIdToProgressionDataMap
    for _, skill in pairs(abilityIdToProgressionDataMap) do
        local abilityId = skill.abilityId
        local skillData = skill.skillData
        if skillData.isPurchased then
            local skillProgressions = skillData.skillProgressions
            if skillProgressions then
                local skillProgression = skillProgressions[skillData:GetCurrentSkillProgressionKey()]
                if abilityId == skillProgression.abilityId and not skillLines[abilityId] then
                    skillLines[abilityId] = {
                        Id = abilityId,
                        DetailedName = skill:GetDetailedName(),
                        FormattedName = skill:GetFormattedNameWithRank(),
                    }
                end
            elseif skillData:IsCraftedAbility() then
                local craftedAbilityId = GetAbilityCraftedAbilityId(abilityId)
                local primaryScriptId, secondaryScriptId, tertiaryScriptId = GetCraftedAbilityActiveScriptIds(skillData.craftedAbilityId)
                skillLines[abilityId] = {
                    Id = abilityId,
                    DetailedName = skill.name,
                    Link = GetCraftedAbilityLink(craftedAbilityId, primaryScriptId, secondaryScriptId, tertiaryScriptId, LINK_STYLE_BRACKETS),
                    Facts = GuildPlannerPro_Skills:GetActiveSkillFacts(abilityId),
                }
            end
        end
    end

    return skillLines
end

function GuildPlannerPro_Skills:ExportCharacterHotbars()
    local hotbars = {}

    local hotBarsToExport = { HOTBAR_CATEGORY_PRIMARY, HOTBAR_CATEGORY_BACKUP, HOTBAR_CATEGORY_CHAMPION }
    if GetPlayerCurseType() == CURSE_TYPE_WEREWOLF then
        table.insert(hotBarsToExport, HOTBAR_CATEGORY_WEREWOLF)
    end

    local abilityIdToProgressionDataMap = SKILLS_DATA_MANAGER.abilityIdToProgressionDataMap
    for _, hotBarCategory in ipairs(hotBarsToExport) do
        hotbars[hotBarCategory] = {}
        local startActionSlotIndex, endActionSlotIndex
        if hotBarCategory ~= HOTBAR_CATEGORY_CHAMPION then
            startActionSlotIndex, endActionSlotIndex = GetAssignableAbilityBarStartAndEndSlots()
        else
            startActionSlotIndex, endActionSlotIndex = GetAssignableChampionBarStartAndEndSlots()
        end
        for slotIndex = startActionSlotIndex, endActionSlotIndex do
            if IsSlotUsed(slotIndex, hotBarCategory) then
                local slotType = GetSlotType(slotIndex, hotBarCategory)
                hotbars[hotBarCategory][slotIndex] = {
                    SlotIndex = slotIndex,
                    Type = slotType,
                }
                local boundId = GetSlotBoundId(slotIndex, hotBarCategory)
                if slotType == ACTION_TYPE_ABILITY then
                    local skill = abilityIdToProgressionDataMap[boundId]
                    hotbars[hotBarCategory][slotIndex]["BoundId"] = skill.abilityId
                    hotbars[hotBarCategory][slotIndex]["Name"] = skill:GetDetailedName()
                elseif slotType == ACTION_TYPE_CRAFTED_ABILITY then
                    local abilityId = GetAbilityIdForCraftedAbilityId(boundId)
                    local skill = abilityIdToProgressionDataMap[abilityId]
                    local primaryScriptId, secondaryScriptId, tertiaryScriptId = GetCraftedAbilityActiveScriptIds(boundId)
                    hotbars[hotBarCategory][slotIndex]["BoundId"] = skill.abilityId
                    hotbars[hotBarCategory][slotIndex]["Name"] = skill:GetDetailedName()
                    hotbars[hotBarCategory][slotIndex]["Link"] = GetCraftedAbilityLink(boundId, primaryScriptId, secondaryScriptId, tertiaryScriptId, LINK_STYLE_BRACKETS)
                    hotbars[hotBarCategory][slotIndex]["Facts"] = GuildPlannerPro_Skills:GetActiveSkillFacts(skill.abilityId)
                elseif slotType == ACTION_TYPE_CHAMPION_SKILL then
                    hotbars[hotBarCategory][slotIndex]["BoundId"] = boundId
                    hotbars[hotBarCategory][slotIndex]["Name"] = GetChampionSkillName(boundId)
                end
            end
        end
    end

    return hotbars
end
