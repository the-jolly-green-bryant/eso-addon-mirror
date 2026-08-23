local Addon = LarvalTearMod
local M = Addon.Modules.SkillRespecPlanner
local SHARED_UTIL = Addon.Common.Util

local function BuildAllTargets(activeRestorePlan)
    local targets = {}
    local targetIndexByProgression = {}
    local operations = type(activeRestorePlan) == "table" and activeRestorePlan.operations or nil
    for _, bucket in ipairs({ "purchases", "morphs" }) do
        for _, operation in ipairs(type(operations) == "table" and operations[bucket] or {}) do
            local progressionId = tonumber(type(operation) == "table" and operation.progressionId or nil)
            local targetAbilityId = tonumber(type(operation) == "table" and operation.targetAbilityId or nil)
            if progressionId ~= nil and targetAbilityId ~= nil then
                progressionId = math.floor(progressionId)
                targetAbilityId = math.floor(targetAbilityId)
                local target = {
                    hotbarCategory = tonumber(operation.hotbarCategory),
                    slotIndex = tonumber(operation.slotIndex),
                    targetAbilityId = targetAbilityId,
                    progressionId = progressionId,
                    targetMorphSlot = operation.targetMorphSlot,
                    source = operation.source,
                    transformKind = operation.transformKind,
                    executionOrder = #targets + 1,
                }
                local existingIndex = targetIndexByProgression[progressionId]
                if existingIndex ~= nil then
                    target.executionOrder = targets[existingIndex].executionOrder
                    targets[existingIndex] = target
                else
                    targets[#targets + 1] = target
                    targetIndexByProgression[progressionId] = #targets
                end
            end
        end
    end
    return targets
end

function M:ResolveRouteBSkillConfig(config)
    local plan = config and config._pipelinePlan or nil
    if type(plan) == "table" and type(plan.configs) == "table" and type(plan.configs.skills) == "table" then
        return plan.configs.skills
    end

    if type(config) == "table" and type(config.skills) == "table" then
        return config.skills
    end

    return nil
end

function M:AnalyzeRouteBSkillTarget(target, options)
    local entry = {
        targetAbilityId = target and (target.targetAbilityId or target.abilityId) or nil,
        hotbarCategory = target and target.hotbarCategory or nil,
        slotIndex = target and (target.slotIndex or target.slot) or nil,
        slotActionType = target and target.slotActionType or nil,
        craftedAbilityId = target and target.craftedAbilityId or nil,
        scriptIds = target and target.scriptIds or nil,
        source = target and target.source or nil,
        transformKind = target and target.transformKind or nil,
        executionOrder = target and target.executionOrder or nil,
        fallbackCraftedAbilityId = nil,
        craftedResolveSource = nil,
        purchased = false,
        committedPurchased = false,
        effectivePurchasedForPlanning = false,
        active = false,
        slottable = false,
        ready = false,
        needsPurchase = false,
        needsMorph = false,
        unresolved = false,
        nonSlottable = false,
        reason = nil,
        finalBucket = nil,
        readyForRestoreBlockedBy = nil,
        purchasedValueSource = nil,
        committedPurchasedValueSource = nil,
        effectivePurchasedValueSource = nil,
        pendingPurchaseSupported = false,
        pendingPurchaseObserved = nil,
        pendingPurchaseValueSource = nil,
        pendingMorphReadable = false,
        pendingMorphSlot = nil,
        pendingMorphObserved = false,
        pendingMorphValueSource = nil,
        allocatorAvailable = false,
        progressionDataAvailable = false,
        skillDataAvailable = false,
        skillLineId = nil,
        skillLineActiveValueSource = nil,
        effectiveSkillLineActiveForPlanning = false,
        currentEffectiveAbilityValueSource = nil,
        currentMorphSlotValueSource = nil,
        effectiveMorphSlotForPlanning = nil,
        effectiveMorphSlotValueSource = nil,
    }

    local function Finalize(bucket, blockedBy)
        entry.finalBucket = bucket
        entry.readyForRestoreBlockedBy = blockedBy
        return entry, bucket
    end

    if entry.targetAbilityId == nil then
        entry.unresolved = true
        entry.reason = "invalid_target_ability_id"
        return Finalize("unresolvedTargets", "invalid_target")
    end

    if entry.targetAbilityId <= 0 then
        entry.ready = true
        entry.reason = "empty_target_slot"
        return Finalize("readyTargets", nil)
    end

    local resolved = SHARED_UTIL:ResolveActiveSkillTargetState(target)

    entry.progressionDataAvailable = type(resolved.progressionData) == "table"
    entry.skillDataAvailable = type(resolved.skillData) == "table"
    entry.progressionId = resolved.progressionId
    entry.targetMorphSlot = resolved.targetMorphSlot
    entry.slotActionType = resolved.slotActionType
    entry.craftedAbilityId = resolved.craftedAbilityId
    entry.scriptIds = resolved.scriptIds
    entry.fallbackCraftedAbilityId = resolved.fallbackCraftedAbilityId
    entry.craftedResolveSource = resolved.craftedResolveSource
    entry.active = resolved.isActiveSkill == true
    entry.isPassive = resolved.isPassiveSkill == true
    entry.isCraftedAbility = resolved.isCraftedAbility == true
    entry.skillLineId = resolved.skillLineId
    entry.skillLineActive = resolved.skillLineActive == true
    entry.effectiveSkillLineActiveForPlanning = resolved.effectiveSkillLineActiveForPlanning == true
    entry.skillLineActiveValueSource = "shared_util"
    entry.isPlayerClassSkillLine = resolved.isPlayerClassSkillLine == true
    entry.committedPurchased = resolved.committedPurchased == true
    entry.committedPurchasedValueSource = "shared_util"
    entry.slottable = resolved.isActiveSkill == true
        and resolved.isPassiveSkill ~= true
        and resolved.isCraftedAbility ~= true
        and resolved.skillLineActive == true
    entry.allocatorAvailable = type(resolved.allocator) == "table"
    entry.pendingPurchaseSupported = entry.allocatorAvailable
    entry.pendingPurchaseObserved = resolved.pendingPurchaseObserved == true
    entry.pendingPurchaseValueSource = "shared_util"
    entry.effectivePurchasedForPlanning = resolved.effectivePurchasedForPlanning == true
    entry.effectivePurchasedValueSource = "shared_util"
    entry.purchased = entry.effectivePurchasedForPlanning
    entry.purchasedValueSource = "shared_util"
    entry.currentEffectiveAbilityId = resolved.currentEffectiveAbilityId
    entry.currentEffectiveAbilityValueSource = "shared_util"
    entry.currentMorphSlot = resolved.currentMorphSlot
    entry.currentMorphSlotValueSource = "shared_util"
    entry.pendingMorphReadable = entry.allocatorAvailable
    entry.pendingMorphSlot = resolved.pendingMorphSlot
    entry.pendingMorphObserved = resolved.pendingMorphObserved == true
    entry.pendingMorphValueSource = "shared_util"
    entry.effectiveMorphSlotForPlanning = resolved.effectiveMorphSlotForPlanning
    entry.effectiveMorphSlotValueSource = "shared_util"
    entry.sameMorphSlotForPlanning = resolved.sameMorphSlotForPlanning == true
    entry.requiresPurchase = resolved.requiresPurchase == true
    entry.requiresMorph = resolved.requiresMorph == true

    if resolved.nonSlottable == true then
        entry.nonSlottable = true
        entry.reason = resolved.reason
        return Finalize("nonSlottableTargets", resolved.reason)
    end

    if resolved.requiresPurchase == true then
        entry.needsPurchase = true
        entry.reason = resolved.reason
        return Finalize("purchaseTargets", "purchaseTargets")
    end

    if resolved.unresolved == true then
        entry.unresolved = true
        entry.reason = resolved.reason
        return Finalize("unresolvedTargets", resolved.reason)
    end

    if resolved.ready == true then
        entry.ready = true
        entry.reason = resolved.reason
        return Finalize("readyTargets", nil)
    end

    entry.needsMorph = resolved.requiresMorph == true
    entry.reason = resolved.reason
    return Finalize("morphTargets", "morphTargets")
end

function M:CountUniqueProgressions(targets)
    if type(targets) ~= "table" then
        return 0
    end

    local seen = {}
    local count = 0
    for _, target in ipairs(targets) do
        if type(target) == "table" then
            local key = tostring(target.progressionId or target.targetAbilityId or "nil")
            if not seen[key] then
                seen[key] = true
                count = count + 1
            end
        end
    end
    return count
end

function M:BuildRouteBSkillTargetPlan(config)
    local skillConfig = self:ResolveRouteBSkillConfig(config)
    local pipelinePlan = type(config) == "table" and config._pipelinePlan or nil
    local activeRestorePlan = type(pipelinePlan) == "table"
        and type(pipelinePlan.configs) == "table"
        and type(pipelinePlan.configs.skillRespec) == "table"
        and pipelinePlan.configs.skillRespec.activeRestorePlan
        or nil
    local targets = BuildAllTargets(activeRestorePlan)
    local subclassDiff = type(pipelinePlan) == "table" and type(pipelinePlan.diagnostics) == "table"
        and pipelinePlan.diagnostics.subclassDiff
        or nil
    local subclassOps = type(subclassDiff) == "table" and type(subclassDiff.orderedOperations) == "table"
        and subclassDiff.orderedOperations
        or {}
    local plan = {
        plannerVersion = 1,
        totalTargets = #targets,
        subclassOps = subclassOps,
        readyTargets = {},
        purchaseTargets = {},
        morphTargets = {},
        unresolvedTargets = {},
        nonSlottableTargets = {},
        diagnostics = {
            source = "route_b_skill_target_planner",
            normalizedTargetCount = #targets,
            subclassOpCount = #subclassOps,
            rawSlotsCount = type(skillConfig) == "table" and type(skillConfig.slots) == "table" and #skillConfig.slots or 0,
        },
    }

    for _, target in ipairs(targets) do
        local entry, bucket = self:AnalyzeRouteBSkillTarget(target)
        if type(plan[bucket]) == "table" then
            plan[bucket][#plan[bucket] + 1] = entry
        end
    end

    local sourcePriority = {
        slot = 1,
        transform = 2,
        active_exact = 3,
        clear_unused = 3,
    }
    local function SortExecutionTargets(left, right)
        local leftPriority = sourcePriority[left.source] or 99
        local rightPriority = sourcePriority[right.source] or 99
        if leftPriority ~= rightPriority then
            return leftPriority < rightPriority
        end
        return (left.executionOrder or 0) < (right.executionOrder or 0)
    end
    table.sort(plan.purchaseTargets, SortExecutionTargets)
    table.sort(plan.morphTargets, SortExecutionTargets)

    plan.readySlots = plan.readyTargets

    plan.diagnostics.readyCount = #plan.readyTargets
    plan.diagnostics.purchaseCount = #plan.purchaseTargets
    plan.diagnostics.purchaseUniqueProgressions = self:CountUniqueProgressions(plan.purchaseTargets)
    plan.diagnostics.morphCount = #plan.morphTargets
    plan.diagnostics.morphUniqueProgressions = self:CountUniqueProgressions(plan.morphTargets)
    plan.diagnostics.unresolvedCount = #plan.unresolvedTargets
    plan.diagnostics.nonSlottableCount = #plan.nonSlottableTargets
    plan.diagnostics.morphOnlyRouteB = plan.diagnostics.subclassOpCount == 0
        and plan.diagnostics.purchaseCount == 0
        and plan.diagnostics.morphCount > 0
    plan.diagnostics.routeBReason = plan.diagnostics.subclassOpCount > 0 and "subclass_ops_present"
        or plan.diagnostics.purchaseCount > 0 and "purchase_targets_present"
        or plan.diagnostics.morphCount > 0 and "morph_targets_present"
        or "restore_only_ready"
    plan.diagnostics.emptyInput = #targets == 0
    plan.readyForRestore = #targets > 0
        and #plan.purchaseTargets == 0
        and #plan.morphTargets == 0
        and #plan.unresolvedTargets == 0

    return plan
end
