local Addon = LarvalTearMod
local M = Addon.Modules.ActiveSkillRestore
local Util = Addon.Common.Util

local MODE_REQUIRED_ONLY = "required_only"
local MODE_EXACT = "exact"
local MODE_CLEAR_UNUSED = "clear_unused"
local BASE_MORPH_SLOT = type(MORPH_SLOT_BASE) == "number" and MORPH_SLOT_BASE or 0

local function NormalizePositiveInteger(value)
    value = tonumber(value)
    if value == nil or value <= 0 or math.floor(value) ~= value then
        return nil
    end
    return math.floor(value)
end

local function NormalizeNonNegativeInteger(value)
    value = tonumber(value)
    if value == nil or value < 0 or math.floor(value) ~= value then
        return nil
    end
    return math.floor(value)
end

local function CloneShallow(source)
    local clone = {}
    for key, value in pairs(type(source) == "table" and source or {}) do
        clone[key] = value
    end
    return clone
end

local function AppendReason(plan, reason)
    if type(reason) ~= "string" or reason == "" or plan.reasonSet[reason] == true then
        return
    end
    plan.reasonSet[reason] = true
    plan.reasons[#plan.reasons + 1] = reason
    if plan.blockReason == nil then
        plan.blockReason = reason
    end
    plan.ok = false
end

local function ResolveMultiplier(value)
    local multiplier = NormalizePositiveInteger(
        type(value) == "table" and (value.skillPointCostMultiplier or value.costMultiplier) or nil
    )
    if multiplier ~= nil then
        return multiplier
    end
    local isClassSkillLine = type(value) == "table" and value.isClassSkillLine == true
    local isPlayerClassSkillLine = type(value) == "table" and value.isPlayerClassSkillLine == true
    if isClassSkillLine then
        return isPlayerClassSkillLine and 1 or 2
    end
    return 1
end

local function BuildLineSet(values)
    local set = {}
    for _, value in ipairs(type(values) == "table" and values or {}) do
        local skillLineId = NormalizePositiveInteger(value)
        if skillLineId ~= nil then
            set[skillLineId] = true
        end
    end
    return set
end

local function BuildSnapshotIndexes(snapshot)
    local lineById = {}
    local activeByProgression = {}
    for _, lineEntry in ipairs(type(snapshot) == "table" and snapshot.lines or {}) do
        local skillLineId = NormalizePositiveInteger(lineEntry.skillLineId)
        if skillLineId ~= nil then
            lineById[skillLineId] = lineEntry
            for _, skillEntry in ipairs(type(lineEntry.skills) == "table" and lineEntry.skills or {}) do
                local progressionId = NormalizePositiveInteger(skillEntry.progressionId)
                if progressionId ~= nil and skillEntry.kind == "active" then
                    activeByProgression[progressionId] = { line = lineEntry, skill = skillEntry }
                end
            end
        end
    end
    return lineById, activeByProgression
end

local function IsCraftedState(state)
    return type(state) == "table"
        and (state.isCraftedAbility == true
            or NormalizePositiveInteger(state.craftedAbilityId) ~= nil
            or NormalizePositiveInteger(state.craftSkillId) ~= nil)
end

local function ResolveRestoreDomainExclusion(state, skillLineId, transformLines, subclassLines, lineEntry)
    if subclassLines[skillLineId] == true then
        return "subclass"
    end
    if transformLines[skillLineId] == true then
        return "transform"
    end
    if type(state) == "table" and state.isClassMastery == true
        or type(lineEntry) == "table" and lineEntry.isClassMastery == true then
        return "class_mastery"
    end
    if IsCraftedState(state) then
        return "crafted"
    end
    return nil
end

local function BuildEmptyOperations()
    return { reductions = {}, purchases = {}, morphs = {} }
end

local function BuildOperation(state, source, action, cost)
    return {
        source = source,
        action = action,
        progressionId = NormalizePositiveInteger(state.progressionId),
        skillLineId = NormalizePositiveInteger(state.skillLineId),
        targetAbilityId = NormalizePositiveInteger(state.targetAbilityId or state.abilityId),
        targetMorphSlot = NormalizeNonNegativeInteger(state.targetMorphSlot),
        currentMorphSlot = NormalizeNonNegativeInteger(state.currentMorphSlot),
        hotbarCategory = NormalizeNonNegativeInteger(state.hotbarCategory),
        slotIndex = NormalizeNonNegativeInteger(state.slotIndex),
        transformKind = type(state.transformKind) == "string" and state.transformKind or nil,
        cost = NormalizeNonNegativeInteger(cost) or 0,
    }
end

local function AppendOperation(plan, sourceOperations, bucket, operation)
    if type(operation) ~= "table" or operation.progressionId == nil then
        AppendReason(plan, "active_operation_progression_unavailable")
        return
    end
    if type(sourceOperations) == "table" then
        sourceOperations[bucket][#sourceOperations[bucket] + 1] = operation
    end
    plan.operations[bucket][#plan.operations[bucket] + 1] = operation
end

local function AppendTargetOperations(plan, sourceOperations, state, source)
    local multiplier = ResolveMultiplier(state)
    local targetMorphSlot = NormalizeNonNegativeInteger(state.targetMorphSlot) or BASE_MORPH_SLOT
    local currentMorphSlot = NormalizeNonNegativeInteger(state.currentMorphSlot) or BASE_MORPH_SLOT
    local targetIsMorphed = targetMorphSlot ~= BASE_MORPH_SLOT
    local currentIsMorphed = currentMorphSlot ~= BASE_MORPH_SLOT
    if state.requiresPurchase == true then
        AppendOperation(plan, sourceOperations, "purchases", BuildOperation(state, source, "purchase", multiplier))
        if targetIsMorphed then
            AppendOperation(plan, sourceOperations, "morphs", BuildOperation(state, source, "morph", multiplier))
        end
    elseif state.requiresMorph == true then
        if currentIsMorphed and not targetIsMorphed then
            local reduction = BuildOperation(state, source, "unmorph", 0)
            reduction.refund = multiplier
            AppendOperation(plan, sourceOperations, "reductions", reduction)
        end
        if targetIsMorphed then
            local morphCost = currentIsMorphed and 0 or multiplier
            AppendOperation(plan, sourceOperations, "morphs", BuildOperation(state, source, "morph", morphCost))
        end
    end
end

local function AppendCurrentClear(plan, sourceOperations, source, currentEntry, transformKind)
    local skillEntry = currentEntry.skill
    local lineEntry = currentEntry.line
    local operation = BuildOperation({
        progressionId = skillEntry.progressionId,
        skillLineId = lineEntry.skillLineId,
        currentMorphSlot = skillEntry.currentMorphSlot,
        transformKind = transformKind,
    }, source, "clear", 0)
    -- GetNumPointsAllocated already includes the SkillLine multiplier.
    operation.refund = NormalizeNonNegativeInteger(skillEntry.pointsAllocated) or 0
    AppendOperation(plan, sourceOperations, "reductions", operation)
end

local function BuildSlotPlan(plan, options, lineById, slotProgressions)
    local operations = BuildEmptyOperations()
    local targets = Util:NormalizeSlotTargets(type(options.skillConfig) == "table" and options.skillConfig or nil)
    local states = type(options.activeTargetStates) == "table" and options.activeTargetStates or {}
    local seenProgressions = {}
    local requiresSubclassActivation = false
    for targetIndex, target in ipairs(targets) do
        local state = states[targetIndex]
        if type(state) ~= "table" then
            state = Util:ResolveActiveSkillTargetState(target)
        end
        local targetAbilityId = NormalizeNonNegativeInteger(type(state) == "table" and state.targetAbilityId or nil)
        if targetAbilityId == nil then
            AppendReason(plan, "slot_active_target_state_unavailable")
        elseif targetAbilityId > 0 then
            local progressionId = NormalizePositiveInteger(state.progressionId)
            local skillLineId = NormalizePositiveInteger(state.skillLineId)
            local lineEntry = skillLineId ~= nil and lineById[skillLineId] or nil
            local excluded = IsCraftedState(state)
                or type(state) == "table" and state.isClassMastery == true
                or type(lineEntry) == "table" and lineEntry.isClassMastery == true
            if progressionId ~= nil then
                slotProgressions[progressionId] = true
            end
            if not excluded then
                if progressionId == nil or state.unresolved == true or state.nonSlottable == true then
                    AppendReason(plan, "slot_active_target_invalid:" .. tostring(state.reason or targetAbilityId))
                elseif state.ready ~= true and state.requiresPurchase ~= true and state.requiresMorph ~= true then
                    AppendReason(plan, "slot_active_target_state_inconsistent:" .. tostring(targetAbilityId))
                elseif seenProgressions[progressionId] ~= true then
                    seenProgressions[progressionId] = true
                    AppendTargetOperations(plan, operations, state, "slot")
                    if state.reason == "skill_line_not_active" and state.isPlayerClassSkillLine == true then
                        requiresSubclassActivation = true
                    end
                end
            end
        end
    end
    return {
        hasPurchaseDiff = #operations.purchases > 0,
        hasMorphDiff = #operations.morphs > 0 or #operations.reductions > 0,
        inferredMorphChanges = operations.morphs,
        requiresSubclassActivation = requiresSubclassActivation,
    }
end

local function AppendTransformOperations(plan, options, activeByProgression, slotProgressions)
    local transformPlan = type(options.transformPlan) == "table" and options.transformPlan or {}
    if transformPlan.ok ~= true then
        AppendReason(plan, "transform_target_invalid:" .. tostring(transformPlan.blockReason or "unknown"))
        return
    end
    for _, target in ipairs(type(transformPlan.targets) == "table" and transformPlan.targets or {}) do
        local progressionId = NormalizePositiveInteger(target.progressionId)
        if progressionId ~= nil and slotProgressions[progressionId] ~= true then
            local currentEntry = activeByProgression[progressionId]
            local currentSkill = type(currentEntry) == "table" and currentEntry.skill or nil
            local state = CloneShallow(target)
            state.targetAbilityId = target.targetAbilityId or target.abilityId
            state.currentMorphSlot = NormalizeNonNegativeInteger(target.currentMorphSlot)
                or NormalizeNonNegativeInteger(type(currentSkill) == "table" and currentSkill.currentMorphSlot or nil)
                or BASE_MORPH_SLOT
            state.costMultiplier = target.costMultiplier
                or (type(currentSkill) == "table" and currentSkill.costMultiplier or nil)
            local currentPurchased = type(target.currentPurchased) == "boolean"
                and target.currentPurchased
                or type(currentSkill) == "table" and currentSkill.purchased == true
            state.requiresPurchase = currentPurchased ~= true
            state.requiresMorph = currentPurchased == true
                and state.currentMorphSlot ~= (NormalizeNonNegativeInteger(state.targetMorphSlot) or BASE_MORPH_SLOT)
            AppendTargetOperations(plan, nil, state, "transform")
        end
    end
    for _, reduction in ipairs(type(transformPlan.reductions) == "table" and transformPlan.reductions or {}) do
        local progressionId = NormalizePositiveInteger(reduction.progressionId)
        if progressionId ~= nil and slotProgressions[progressionId] ~= true then
            local currentEntry = activeByProgression[progressionId]
            if reduction.action ~= "clear" or type(currentEntry) ~= "table" then
                AppendReason(plan, "transform_reduction_cost_unavailable:" .. tostring(progressionId))
            else
                AppendCurrentClear(plan, nil, "transform", currentEntry, reduction.transformKind)
            end
        end
    end
end

local function ParseAbilityIds(activeSnapshot)
    if type(activeSnapshot) ~= "table" or type(activeSnapshot.a) ~= "string" then
        return nil, "active_snapshot_missing"
    end
    local abilityIds = {}
    if activeSnapshot.a == "" then
        return abilityIds, nil
    end
    for token in string.gmatch(activeSnapshot.a, "[^,]+") do
        local abilityId = NormalizePositiveInteger(token)
        if abilityId == nil then
            return nil, "active_snapshot_ability_invalid"
        end
        abilityIds[#abilityIds + 1] = abilityId
    end
    return abilityIds, nil
end

local function AppendRestoreOperations(
    plan,
    options,
    transformLines,
    subclassLines,
    lineById,
    activeByProgression,
    slotProgressions
)
    if plan.mode == MODE_REQUIRED_ONLY then
        return
    end
    local targetByProgression = {}
    if plan.mode == MODE_EXACT then
        local abilityIds, snapshotErr = ParseAbilityIds(options.activeSnapshot)
        if abilityIds == nil then
            AppendReason(plan, snapshotErr)
            return
        end
        for _, abilityId in ipairs(abilityIds) do
            local state = Util:ResolveActiveSkillTargetState({ abilityId = abilityId })
            local progressionId = NormalizePositiveInteger(type(state) == "table" and state.progressionId or nil)
            local skillLineId = NormalizePositiveInteger(type(state) == "table" and state.skillLineId or nil)
            local lineEntry = skillLineId ~= nil and lineById[skillLineId] or nil
            local excludedOwner = ResolveRestoreDomainExclusion(
                state,
                skillLineId,
                transformLines,
                subclassLines,
                lineEntry
            )
            if type(state) ~= "table" or progressionId == nil then
                AppendReason(plan, "active_exact_target_invalid:" .. tostring(abilityId))
            elseif slotProgressions[progressionId] == true then
                -- Build Card slot target is the canonical mutation source.
            elseif excludedOwner == nil then
                if state.unresolved == true or state.nonSlottable == true then
                    AppendReason(plan, "active_exact_target_invalid:" .. tostring(abilityId))
                elseif state.ready ~= true and state.requiresPurchase ~= true and state.requiresMorph ~= true then
                    AppendReason(plan, "active_exact_target_state_inconsistent:" .. tostring(abilityId))
                elseif targetByProgression[progressionId] ~= nil
                    and targetByProgression[progressionId].targetMorphSlot ~= state.targetMorphSlot then
                    AppendReason(plan, "active_exact_target_conflict:" .. tostring(progressionId))
                elseif targetByProgression[progressionId] == nil then
                    targetByProgression[progressionId] = state
                    AppendTargetOperations(plan, nil, state, "active_exact")
                end
            end
        end
    end
    for progressionId, currentEntry in pairs(activeByProgression) do
        local skillEntry = currentEntry.skill
        local lineEntry = currentEntry.line
        local skillLineId = NormalizePositiveInteger(lineEntry.skillLineId)
        local excludedOwner = ResolveRestoreDomainExclusion(
            skillEntry,
            skillLineId,
            transformLines,
            subclassLines,
            lineEntry
        )
        local retained = slotProgressions[progressionId] == true
            or plan.mode == MODE_EXACT and targetByProgression[progressionId] ~= nil
        local cryptCanonUltimateExcluded = plan.mode == MODE_CLEAR_UNUSED
            and options.cryptCanonActive == true
            and skillEntry.isUltimate == true
        if not retained
            and excludedOwner == nil
            and skillEntry.isAutoGrant ~= true
            and not cryptCanonUltimateExcluded
            and skillEntry.purchased == true then
            local source = plan.mode == MODE_EXACT and "active_exact" or "clear_unused"
            AppendCurrentClear(plan, nil, source, currentEntry)
        end
    end
end

local function FinalizeCosts(plan)
    plan.activeRequired = 0
    plan.activeRefund = 0
    for _, operation in ipairs(plan.operations.purchases) do
        plan.activeRequired = plan.activeRequired + (NormalizeNonNegativeInteger(operation.cost) or 0)
    end
    for _, operation in ipairs(plan.operations.morphs) do
        plan.activeRequired = plan.activeRequired + (NormalizeNonNegativeInteger(operation.cost) or 0)
    end
    for _, operation in ipairs(plan.operations.reductions) do
        plan.activeRefund = plan.activeRefund + (NormalizeNonNegativeInteger(operation.refund) or 0)
    end
end

function M:BuildPlan(options)
    options = type(options) == "table" and options or {}
    local mode = options.mode
    local plan = {
        mode = mode,
        ok = true,
        blockReason = nil,
        reasons = {},
        reasonSet = {},
        operations = { reductions = {}, purchases = {}, morphs = {} },
        activeRefund = 0,
        activeRequired = 0,
        hasDiff = false,
        requiresRouteB = false,
        neutralized = false,
    }
    if mode ~= MODE_REQUIRED_ONLY and mode ~= MODE_EXACT and mode ~= MODE_CLEAR_UNUSED then
        AppendReason(plan, "active_restore_mode_invalid:" .. tostring(mode))
    end
    local transformLines = type(options.transformOwnerSkillLineIds) == "table"
        and options.transformOwnerSkillLineIds
        or nil
    if transformLines == nil then
        local resolvedLines, resolveErr = Addon.Modules.TransformSkills:ResolveLiveOwnerSkillLineSet()
        if type(resolvedLines) ~= "table" then
            AppendReason(plan, resolveErr or "transform_live_owner_resolution_failed")
            transformLines = {}
        else
            transformLines = resolvedLines
        end
    end
    if mode == MODE_CLEAR_UNUSED and type(options.cryptCanonActive) ~= "boolean" then
        AppendReason(plan, "crypt_canon_state_unavailable")
    end
    if (mode == MODE_EXACT or mode == MODE_CLEAR_UNUSED) and type(options.auditSnapshot) ~= "table" then
        AppendReason(plan, "active_audit_snapshot_unavailable")
    end
    local subclassLines = BuildLineSet(
        type(options.subclassDiff) == "table" and options.subclassDiff.deactivate or nil
    )
    local lineById, activeByProgression = BuildSnapshotIndexes(options.auditSnapshot)
    local slotProgressions = {}
    plan.slotPlan = BuildSlotPlan(plan, options, lineById, slotProgressions)
    AppendTransformOperations(plan, options, activeByProgression, slotProgressions)
    AppendRestoreOperations(
        plan,
        options,
        transformLines,
        subclassLines,
        lineById,
        activeByProgression,
        slotProgressions
    )
    FinalizeCosts(plan)
    plan.hasDiff = #plan.operations.reductions > 0
        or #plan.operations.purchases > 0
        or #plan.operations.morphs > 0
    plan.requiresRouteB = mode == MODE_CLEAR_UNUSED or plan.hasDiff
    plan.reasonSet = nil
    return plan
end

function M:ApplyShortageDecision(plan, decision)
    if type(plan) ~= "table" or type(decision) ~= "table" or decision.activeAction ~= "skip_all" then
        return plan
    end
    local neutralized = CloneShallow(plan)
    neutralized.slotPlan = {
        hasPurchaseDiff = false,
        hasMorphDiff = false,
        inferredMorphChanges = {},
        requiresSubclassActivation = false,
    }
    neutralized.operations = { reductions = {}, purchases = {}, morphs = {} }
    neutralized.activeRefund = 0
    neutralized.activeRequired = 0
    neutralized.hasDiff = false
    neutralized.requiresRouteB = false
    neutralized.neutralized = true
    neutralized.ok = true
    neutralized.blockReason = nil
    neutralized.reasons = {}
    return neutralized
end

function M:HasOperationsFromSources(plan, sources)
    if type(plan) ~= "table" or type(plan.operations) ~= "table" or type(sources) ~= "table" then
        return false
    end
    for _, bucket in ipairs({ "reductions", "purchases", "morphs" }) do
        for _, operation in ipairs(type(plan.operations[bucket]) == "table" and plan.operations[bucket] or {}) do
            if sources[operation.source] == true then
                return true
            end
        end
    end
    return false
end

local function ResolveReductionAllocator(operation)
    if type(SKILLS_DATA_MANAGER) ~= "table"
        or type(SKILLS_DATA_MANAGER.GetSkillDataByProgressionId) ~= "function" then
        return nil, "active_reduction_skill_resolver_unavailable"
    end
    local skillData = SKILLS_DATA_MANAGER:GetSkillDataByProgressionId(operation.progressionId)
    local skillLineId = NormalizePositiveInteger(Util:SafeCallMethod(skillData, "GetSkillLineId"))
    if skillLineId == nil then
        local skillLineData = Util:SafeCallMethod(skillData, "GetSkillLineData")
        skillLineId = NormalizePositiveInteger(Util:SafeCallMethod(skillLineData, "GetId"))
    end
    if type(skillData) ~= "table"
        or skillLineId ~= operation.skillLineId
        or Util:SafeCallMethod(skillData, "IsActive") ~= true
        or Util:SafeCallMethod(skillData, "IsPassive") == true
        or Util:SafeCallMethod(skillData, "IsCraftedAbility") == true then
        return nil, "active_reduction_skill_unavailable:" .. tostring(operation.progressionId)
    end
    local allocator = Util:SafeCallMethod(skillData, "GetPointAllocator")
    local methodName = operation.action == "unmorph" and "Unmorph"
        or operation.action == "clear" and "Clear"
        or nil
    if methodName == nil
        or type(allocator) ~= "table"
        or type(allocator[methodName]) ~= "function"
        or type(allocator.Revert) ~= "function" then
        return nil, "active_reduction_allocator_unavailable:" .. tostring(operation.progressionId)
    end
    return { allocator = allocator, methodName = methodName, operation = operation }
end

local function RevertAllocator(allocator)
    if type(allocator) ~= "table" or type(allocator.Revert) ~= "function" then
        return false, "revert_unavailable"
    end
    local ok, err = pcall(allocator.Revert, allocator)
    if not ok then
        return false, tostring(err)
    end
    return true
end

function M:ExecutePendingReductions(plan, context)
    if type(plan) ~= "table" or plan.ok ~= true or type(plan.operations) ~= "table" then
        return false, type(plan) == "table" and plan.blockReason or "active_restore_plan_missing"
    end
    local reductions = type(plan.operations.reductions) == "table" and plan.operations.reductions or {}
    if #reductions == 0 then
        return true
    end
    local manager = SKILLS_AND_ACTION_BAR_MANAGER
    if type(manager) ~= "table"
        or type(manager.DoesSkillPointAllocationModeAllowClear) ~= "function"
        or manager:DoesSkillPointAllocationModeAllowClear() ~= true then
        return false, "active_reduction_allocation_mode_disallows_clear"
    end
    local resolved = {}
    for _, operation in ipairs(reductions) do
        local entry, resolveErr = ResolveReductionAllocator(operation)
        if entry == nil then
            return false, resolveErr
        end
        resolved[#resolved + 1] = entry
    end
    local executed = {}
    for _, entry in ipairs(resolved) do
        if Util:SafeCallMethod(entry.allocator, entry.methodName) ~= true then
            local revertError = nil
            local reverted, revertErr = RevertAllocator(entry.allocator)
            if not reverted then
                revertError = revertErr
            end
            for index = #executed, 1, -1 do
                local previousReverted, previousRevertErr = RevertAllocator(executed[index].allocator)
                if not previousReverted and revertError == nil then
                    revertError = previousRevertErr
                end
            end
            if revertError ~= nil then
                return false, "active_reduction_revert_error:" .. tostring(revertError)
            end
            return false, "active_" .. tostring(entry.operation.action) .. "_failed:"
                .. tostring(entry.operation.progressionId)
        end
        executed[#executed + 1] = entry
    end
    context.modifiedAllocators = context.modifiedAllocators or {}
    for _, entry in ipairs(executed) do
        context.modifiedAllocators[#context.modifiedAllocators + 1] = entry.allocator
    end
    return true
end

function M:VerifyCommittedReductions(plan)
    local mismatches = {}
    for _, operation in ipairs(plan.operations.reductions) do
        local skillData = SKILLS_DATA_MANAGER:GetSkillDataByProgressionId(operation.progressionId)
        local mismatched = operation.action == "clear"
            and Util:SafeCallMethod(skillData, "IsPurchased") ~= false
            or operation.action == "unmorph"
                and Util:SafeCallMethod(skillData, "GetCurrentMorphSlot") ~= BASE_MORPH_SLOT
        if mismatched then
            mismatches[#mismatches + 1] = {
                action = operation.action,
                progressionId = operation.progressionId,
                source = operation.source,
            }
        end
    end
    return {
        ok = #mismatches == 0,
        mismatchCount = #mismatches,
        mismatches = mismatches,
    }
end
