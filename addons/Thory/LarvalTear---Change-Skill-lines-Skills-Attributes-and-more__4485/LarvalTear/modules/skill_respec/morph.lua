local Addon = LarvalTearMod
local M = Addon.Modules.SkillRespecMorph
local Util = Addon.Common.Util
local BASE_MORPH_SLOT = MORPH_SLOT_BASE or 0

local function CreateSummary()
    return {
        attemptedCount = 0,
        morphedCount = 0,
        skippedInsufficientPointsCount = 0,
        expectedMissingTargets = {},
        hardFailure = false,
        hardFailureReason = nil,
        hardFailureTarget = nil,
    }
end

local function NormalizeOptionalBool(value)
    if value == nil then
        return nil
    end

    return value == true
end

local function ResolveSkillLineId(skillData)
    local skillLineId = Util:SafeCallMethod(skillData, "GetSkillLineId")
    if type(skillLineId) == "number" and skillLineId > 0 then
        return skillLineId
    end

    local skillLineData = Util:SafeCallMethod(skillData, "GetSkillLineData")
    skillLineId = Util:SafeCallMethod(skillLineData, "GetId")
    if type(skillLineId) == "number" and skillLineId > 0 then
        return skillLineId
    end

    skillLineId = Util:SafeCallMethod(skillLineData, "GetSkillLineId")
    if type(skillLineId) == "number" and skillLineId > 0 then
        return skillLineId
    end

    return nil
end

function M:ResolveTarget(apply, target)
    if type(SKILLS_DATA_MANAGER) ~= "table" then
        return nil, "skills_data_manager_unavailable"
    end

    if target.targetAbilityId == nil or target.targetAbilityId <= 0 then
        return nil, "invalid_target_ability_id"
    end

    local progressionData = Util:SafeCallMethod(SKILLS_DATA_MANAGER, "GetProgressionDataByAbilityId", target.targetAbilityId)
    if progressionData == nil then
        return nil, "unknown_target_ability"
    end

    local skillData = Util:SafeCallMethod(progressionData, "GetSkillData")
    if skillData == nil then
        return nil, "skill_data_unavailable"
    end

    if Util:SafeCallMethod(skillData, "IsActive") ~= true then
        return nil, "target_is_not_active_skill"
    end

    if Util:SafeCallMethod(skillData, "IsPassive") == true then
        return nil, "passive_not_supported"
    end

    if Util:SafeCallMethod(skillData, "IsCraftedAbility") == true then
        return nil, "crafted_ability_not_supported"
    end

    local targetMorphSlot = Util:SafeCallMethod(progressionData, "GetMorphSlot")
    local progressionId = Util:SafeCallMethod(skillData, "GetProgressionId")
    if targetMorphSlot == nil or progressionId == nil then
        return nil, "morph_identity_unavailable"
    end

    return {
        index = target.index,
        targetAbilityId = target.targetAbilityId,
        hotbarCategory = target.hotbarCategory,
        slotIndex = target.slotIndex,
        progressionData = progressionData,
        skillData = skillData,
        allocator = Util:SafeCallMethod(skillData, "GetPointAllocator"),
        progressionId = progressionId,
        skillLineId = ResolveSkillLineId(skillData),
        targetMorphSlot = targetMorphSlot,
        source = target.source,
        transformKind = target.transformKind,
    }
end

local function IsInsufficientSkillPointsForMorph(resolvedTarget)
    local allocator = type(resolvedTarget) == "table" and resolvedTarget.allocator or nil
    local skillData = type(resolvedTarget) == "table" and resolvedTarget.skillData or nil
    if type(allocator) ~= "table"
        or type(allocator.GetSkillProgressionKey) ~= "function"
        or type(allocator.HasEnoughAvailableSkillPointsForSingleTransaction) ~= "function"
        or type(allocator.IsPurchased) ~= "function"
        or type(skillData) ~= "table"
        or type(skillData.IsAtMorph) ~= "function" then
        return false
    end

    return Util:SafeCallMethod(allocator, "IsPurchased") == true
        and Util:SafeCallMethod(skillData, "IsAtMorph") == true
        and Util:SafeCallMethod(allocator, "GetSkillProgressionKey") == BASE_MORPH_SLOT
        and Util:SafeCallMethod(
            allocator,
            "HasEnoughAvailableSkillPointsForSingleTransaction"
        ) == false
end

function M:AuditTargets(apply, context, skillTargetPlan)
    local morphTargets = type(skillTargetPlan) == "table" and skillTargetPlan.morphTargets or nil
    if type(morphTargets) ~= "table" or #morphTargets == 0 then
        context.morphTargetAuditEntries = {}
        context.morphProgressionAuditEntries = {}
        context.normalizedMorphTargets = {}
        context.morphNormalizationSummary = {
            progressionCount = 0,
            conflictCount = 0,
            resolvedCount = 0,
            droppedCount = 0,
        }
        return
    end

    context.morphTargetAuditEntries = {}
    context.morphProgressionAuditEntries = {}
    context.normalizedMorphTargets = {}
    context.morphNormalizationSummary = {
        progressionCount = 0,
        conflictCount = 0,
        resolvedCount = 0,
        droppedCount = 0,
    }

    local groupedByProgression = {}
    local progressionOrder = {}
    for _, target in ipairs(morphTargets) do
        local resolvedTarget, resolveErr = self:ResolveTarget(apply, target)
        local progressionKey = tostring(target.progressionId or target.targetAbilityId or "nil")
        local group = groupedByProgression[progressionKey]
        if group == nil then
            group = {
                progressionId = target.progressionId,
                targetAbilityIds = {},
                targetMorphSlots = {},
                uniqueTargetMorphSlots = {},
                targetMorphSlotValues = {},
                targetEntries = {},
                currentMorphSlot = target.currentMorphSlot,
                currentEffectiveAbilityId = target.currentEffectiveAbilityId,
                allocatorAvailable = false,
                skillDataAvailable = false,
                progressionDataAvailable = false,
                selectedMorphSlot = nil,
                selected = false,
                hasConflict = false,
                conflictReason = nil,
                skipReason = nil,
                canMorph = nil,
                hasEnoughPoints = nil,
            }
            groupedByProgression[progressionKey] = group
            progressionOrder[#progressionOrder + 1] = progressionKey
        end

        group.targetAbilityIds[#group.targetAbilityIds + 1] = target.targetAbilityId
        group.targetMorphSlots[#group.targetMorphSlots + 1] = target.targetMorphSlot

        local morphSlotKey = tostring(target.targetMorphSlot)
        if not group.uniqueTargetMorphSlots[morphSlotKey] then
            group.uniqueTargetMorphSlots[morphSlotKey] = true
            group.targetMorphSlotValues[#group.targetMorphSlotValues + 1] = target.targetMorphSlot
        end

        local targetAudit = {
            targetAbilityId = target.targetAbilityId,
            progressionId = target.progressionId,
            targetMorphSlot = target.targetMorphSlot,
            hotbarCategory = target.hotbarCategory,
            slotIndex = target.slotIndex,
            selected = false,
            canMorph = nil,
            hasEnoughPoints = nil,
            skipReason = nil,
            hasConflict = false,
            selectedMorphSlot = nil,
            deduped = false,
            currentMorphSlot = target.currentMorphSlot,
            currentEffectiveAbilityId = target.currentEffectiveAbilityId,
            allocatorAvailable = false,
            skillDataAvailable = false,
            progressionDataAvailable = false,
            conflictReason = nil,
            targetAbilityIds = group.targetAbilityIds,
            targetMorphSlots = group.targetMorphSlots,
        }

        if resolvedTarget == nil then
            targetAudit.skipReason = resolveErr
            group.skipReason = group.skipReason or resolveErr
        else
            group.progressionId = resolvedTarget.progressionId or group.progressionId
            group.allocatorAvailable = resolvedTarget.allocator ~= nil
            group.skillDataAvailable = resolvedTarget.skillData ~= nil
            group.progressionDataAvailable = resolvedTarget.progressionData ~= nil
            group.currentMorphSlot = Util:SafeCallMethod(resolvedTarget.skillData, "GetCurrentMorphSlot")
                or group.currentMorphSlot

            local currentProgressionData = Util:SafeCallMethod(resolvedTarget.skillData, "GetPointAllocatorProgressionData")
            if currentProgressionData ~= nil then
                group.currentEffectiveAbilityId = Util:SafeCallMethod(
                    currentProgressionData,
                    "GetEffectiveAbilityId",
                    resolvedTarget.hotbarCategory
                )
            end

            targetAudit.allocatorAvailable = group.allocatorAvailable
            targetAudit.skillDataAvailable = group.skillDataAvailable
            targetAudit.progressionDataAvailable = group.progressionDataAvailable
            targetAudit.currentMorphSlot = group.currentMorphSlot
            targetAudit.currentEffectiveAbilityId = group.currentEffectiveAbilityId
        end

        group.targetEntries[#group.targetEntries + 1] = {
            target = target,
            audit = targetAudit,
            resolvedTarget = resolvedTarget,
        }
        context.morphTargetAuditEntries[#context.morphTargetAuditEntries + 1] = targetAudit
    end

    for _, progressionKey in ipairs(progressionOrder) do
        local group = groupedByProgression[progressionKey]
        local uniqueCount = #group.targetMorphSlotValues
        local selectedEntry = nil
        local normalizationDroppedCount = 0
        local normalizationResolvedConflict = false
        context.morphNormalizationSummary.progressionCount = context.morphNormalizationSummary.progressionCount + 1

        if uniqueCount == 1 then
            group.selectedMorphSlot = group.targetMorphSlotValues[1]
        else
            group.hasConflict = true
            group.conflictReason = "multiple_target_morph_slots_for_progression"
            context.morphNormalizationSummary.conflictCount = context.morphNormalizationSummary.conflictCount + 1

            for _, targetEntry in ipairs(group.targetEntries) do
                if targetEntry.resolvedTarget ~= nil then
                    selectedEntry = targetEntry
                    break
                end
            end

            if selectedEntry ~= nil then
                group.selectedMorphSlot = selectedEntry.resolvedTarget.targetMorphSlot
                normalizationDroppedCount = #group.targetEntries - 1
                normalizationResolvedConflict = true
                group.hasConflict = false
                group.conflictReason = nil
                group.skipReason = nil
            else
                group.skipReason = group.skipReason or group.conflictReason
                normalizationDroppedCount = #group.targetEntries
            end
        end

        if group.hasConflict ~= true and group.skipReason == nil then
            if selectedEntry == nil then
                selectedEntry = group.targetEntries[1]
            end
            if selectedEntry ~= nil and selectedEntry.resolvedTarget ~= nil then
                local allocator = selectedEntry.resolvedTarget.allocator
                if allocator == nil then
                    group.skipReason = "allocator_unavailable"
                elseif allocator.CanMorph == nil then
                    group.skipReason = "can_morph_unavailable"
                else
                    group.canMorph = Util:SafeCallMethod(allocator, "CanMorph")
                    if type(allocator.HasEnoughAvailableSkillPointsForSingleTransaction) == "function" then
                        group.hasEnoughPoints = Util:SafeCallMethod(
                            allocator,
                            "HasEnoughAvailableSkillPointsForSingleTransaction"
                        ) == true
                    end
                    if group.canMorph ~= true then
                        group.skipReason = "cannot_morph_selected_slot"
                    end
                    group.selected = true
                    context.normalizedMorphTargets[#context.normalizedMorphTargets + 1] = {
                        progressionId = selectedEntry.resolvedTarget.progressionId,
                        targetMorphSlot = group.selectedMorphSlot,
                        abilityId = selectedEntry.resolvedTarget.targetAbilityId,
                        hotbarCategory = selectedEntry.resolvedTarget.hotbarCategory,
                        slotIndex = selectedEntry.resolvedTarget.slotIndex,
                        source = selectedEntry.resolvedTarget.source,
                        transformKind = selectedEntry.resolvedTarget.transformKind,
                    }
                    context.morphNormalizationSummary.resolvedCount = context.morphNormalizationSummary.resolvedCount + 1
                end
            else
                group.skipReason = group.skipReason or "resolved_target_missing"
            end
        end

        if group.selected ~= true then
            if uniqueCount == 1 then
                normalizationDroppedCount = #group.targetEntries
            end
            context.morphNormalizationSummary.droppedCount = context.morphNormalizationSummary.droppedCount + normalizationDroppedCount
        elseif normalizationResolvedConflict == true then
            context.morphNormalizationSummary.droppedCount = context.morphNormalizationSummary.droppedCount + normalizationDroppedCount
        end

        group.normalizationDroppedCount = normalizationDroppedCount

        local progressionAudit = {
            progressionId = group.progressionId,
            targetAbilityIds = group.targetAbilityIds,
            targetMorphSlots = group.targetMorphSlots,
            targetMorphSlotUniqueCount = uniqueCount,
            hasConflict = group.hasConflict == true,
            conflictReason = group.conflictReason,
            selectedMorphSlot = group.selectedMorphSlot,
            selected = group.selected == true,
            canMorph = group.canMorph,
            hasEnoughPoints = group.hasEnoughPoints,
            skipReason = group.skipReason,
            normalizationResolvedConflict = normalizationResolvedConflict == true,
            normalizationDroppedCount = normalizationDroppedCount,
            currentMorphSlot = group.currentMorphSlot,
            currentEffectiveAbilityId = group.currentEffectiveAbilityId,
            allocatorAvailable = group.allocatorAvailable == true,
            skillDataAvailable = group.skillDataAvailable == true,
            progressionDataAvailable = group.progressionDataAvailable == true,
        }
        context.morphProgressionAuditEntries[#context.morphProgressionAuditEntries + 1] = progressionAudit
        local selectedTargetLogged = false
        for _, targetEntry in ipairs(group.targetEntries) do
            local targetAudit = targetEntry.audit
            targetAudit.progressionId = group.progressionId
            targetAudit.targetAbilityIds = group.targetAbilityIds
            targetAudit.targetMorphSlots = group.targetMorphSlots
            targetAudit.targetMorphSlotUniqueCount = uniqueCount
            targetAudit.hasConflict = group.hasConflict == true
            targetAudit.conflictReason = group.conflictReason
            targetAudit.selectedMorphSlot = group.selectedMorphSlot
            targetAudit.canMorph = group.canMorph
            targetAudit.hasEnoughPoints = group.hasEnoughPoints
            targetAudit.currentMorphSlot = group.currentMorphSlot
            targetAudit.currentEffectiveAbilityId = group.currentEffectiveAbilityId
            targetAudit.allocatorAvailable = group.allocatorAvailable == true
            targetAudit.skillDataAvailable = group.skillDataAvailable == true
            targetAudit.progressionDataAvailable = group.progressionDataAvailable == true
            targetAudit.normalizationResolvedConflict = normalizationResolvedConflict == true
            targetAudit.normalizationDroppedCount = normalizationDroppedCount

            if group.hasConflict == true then
                targetAudit.skipReason = targetAudit.skipReason or group.conflictReason
            elseif group.selected ~= true then
                targetAudit.skipReason = targetAudit.skipReason or group.skipReason
            elseif not selectedTargetLogged and targetAudit.targetMorphSlot == group.selectedMorphSlot then
                targetAudit.selected = true
                selectedTargetLogged = true
            else
                targetAudit.deduped = true
                targetAudit.skipReason = targetAudit.skipReason or "duplicate_progression_deduped"
            end
        end
    end

    apply:LogRouteBMorphTargetAuditSummary(context)
end

function M:ExecutePending(apply, context)
    local normalizedTargets = type(context) == "table" and context.normalizedMorphTargets or nil
    local progressionEntries = type(context) == "table" and context.morphProgressionAuditEntries or nil
    if type(normalizedTargets) ~= "table" or #normalizedTargets == 0 then
        local emptySummary = CreateSummary()
        context.morphOutcomeSummary = emptySummary
        return true, nil, emptySummary
    end
    local progressionById = {}
    for _, entry in ipairs(progressionEntries or {}) do
        progressionById[tostring(entry.progressionId)] = entry
    end

    context.morphSelectedProgressionKeys = {}
    local summary = CreateSummary()
    for _, target in ipairs(normalizedTargets) do
        summary.attemptedCount = summary.attemptedCount + 1
        local progressionKey = tostring(target.progressionId or target.abilityId)
        local progressionAudit = progressionById[progressionKey] or {}
        local resolvedTarget, resolveErr = self:ResolveTarget(apply, {
            targetAbilityId = target.abilityId,
            hotbarCategory = target.hotbarCategory,
            slotIndex = target.slotIndex,
            source = target.source,
            transformKind = target.transformKind,
        })
        local allocator = resolvedTarget and resolvedTarget.allocator or nil
        local skipReason = nil

        if resolvedTarget == nil then
            summary.hardFailure = true
            summary.hardFailureReason = resolveErr
            summary.hardFailureTarget = target
            context.morphOutcomeSummary = summary
            return false, resolveErr, summary
        end

        if progressionAudit.selected ~= true then
            skipReason = progressionAudit.skipReason or "normalized_target_not_selected"
        elseif progressionAudit.hasConflict == true then
            skipReason = progressionAudit.conflictReason or "morph_conflict_present"
        elseif target.targetMorphSlot == nil then
            skipReason = "selected_morph_slot_missing"
        elseif allocator == nil then
            skipReason = "allocator_unavailable"
        elseif allocator.Morph == nil then
            skipReason = "allocator_morph_unavailable"
        end

        if skipReason ~= nil then
            summary.hardFailure = true
            summary.hardFailureReason = skipReason
            summary.hardFailureTarget = target
            context.morphOutcomeSummary = summary
            return false, skipReason, summary
        end

        local canMorph = NormalizeOptionalBool(Util:SafeCallMethod(allocator, "CanMorph"))
        if canMorph ~= true then
            if IsInsufficientSkillPointsForMorph(resolvedTarget)
                and type(apply.IsActivePriorityShortagePolicy) == "function"
                and apply:IsActivePriorityShortagePolicy(context) then
                summary.skippedInsufficientPointsCount = summary.skippedInsufficientPointsCount + 1
                summary.expectedMissingTargets[#summary.expectedMissingTargets + 1] = {
                    progressionId = resolvedTarget.progressionId,
                    targetAbilityId = resolvedTarget.targetAbilityId,
                    targetMorphSlot = target.targetMorphSlot,
                    source = resolvedTarget.source,
                    owner = resolvedTarget.source,
                    transformKind = resolvedTarget.transformKind,
                    shortageReason = "insufficient_skill_points",
                }
                progressionAudit.outcome = "skipped_insufficient_points"
            else
                skipReason = progressionAudit.skipReason or "cannot_morph_selected_slot"
                summary.hardFailure = true
                summary.hardFailureReason = skipReason
                summary.hardFailureTarget = target
                context.morphOutcomeSummary = summary
                return false, skipReason, summary
            end
        else

            local morphResult = Util:SafeCallMethod(allocator, "Morph", target.targetMorphSlot)
            local morphOk = morphResult == true
            if not morphOk then
                skipReason = "morph_pending_failed"
            end

            if morphOk then
                summary.morphedCount = summary.morphedCount + 1
                context.modifiedAllocators = context.modifiedAllocators or {}
                context.modifiedAllocators[#context.modifiedAllocators + 1] = allocator
                context.morphSelectedProgressionKeys[progressionKey] = true
                progressionAudit.outcome = "morphed"
            end

            if not morphOk then
                summary.hardFailure = true
                summary.hardFailureReason = skipReason
                summary.hardFailureTarget = target
                context.morphOutcomeSummary = summary
                return false, skipReason, summary
            end
        end
    end

    local pendingChanges = NormalizeOptionalBool(Util:SafeCallMethod(SKILLS_AND_ACTION_BAR_MANAGER, "HasAnyPendingChanges"))
    if summary.morphedCount > 0 and pendingChanges ~= true then
        summary.hardFailure = true
        summary.hardFailureReason = "morph_pending_changes_missing"
        context.morphOutcomeSummary = summary
        return false, "morph_pending_changes_missing", summary
    end

    context.morphOutcomeSummary = summary
    return true, nil, summary
end
