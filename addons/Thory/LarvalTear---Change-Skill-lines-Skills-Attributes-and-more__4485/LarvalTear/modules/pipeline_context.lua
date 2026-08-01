local Addon = LarvalTearMod
local LTM_PIPELINE_CONTEXT = Addon.Modules.PipelineContext
local LTM_SHARED_UTIL = Addon.Common.Util
local CRYPT_CANON_SPECIAL_ULTIMATE_ID = 195031

function LTM_SHARED_UTIL:NormalizeNumber(value)
    local numberValue = tonumber(value)
    if numberValue == nil then
        return nil
    end

    return math.floor(numberValue)
end

function LTM_SHARED_UTIL:BuildSlotKey(hotbarCategory, slotIndex)
    return tostring(hotbarCategory) .. ":" .. tostring(slotIndex)
end

function LTM_SHARED_UTIL:NormalizeScriptIds(scriptIds)
    if type(scriptIds) ~= "table" then
        return nil
    end

    local normalized = {}
    local hasValue = false
    for index = 1, 3 do
        local scriptId = self:NormalizeNumber(scriptIds[index])
        if scriptId ~= nil and scriptId > 0 then
            normalized[index] = scriptId
            hasValue = true
        else
            normalized[index] = 0
        end
    end

    if hasValue then
        return normalized
    end

    return nil
end

function LTM_SHARED_UTIL:AppendNormalizedSlotTarget(targets, seenKeys, hotbarCategory, slotIndex, abilityId, extra)
    hotbarCategory = self:NormalizeNumber(hotbarCategory)
    slotIndex = self:NormalizeNumber(slotIndex)
    abilityId = self:NormalizeNumber(abilityId)
    if hotbarCategory == nil or slotIndex == nil or abilityId == nil then
        return
    end

    local key = self:BuildSlotKey(hotbarCategory, slotIndex)
    if seenKeys[key] then
        return
    end

    seenKeys[key] = true
    local target = {
        hotbarCategory = hotbarCategory,
        slotIndex = slotIndex,
        abilityId = abilityId,
    }
    if type(extra) == "table" then
        local slotActionType = self:NormalizeNumber(extra.slotActionType)
        if slotActionType ~= nil then
            target.slotActionType = slotActionType
        end

        local craftedAbilityId = self:NormalizeNumber(extra.craftedAbilityId)
        if craftedAbilityId ~= nil and craftedAbilityId > 0 then
            target.craftedAbilityId = craftedAbilityId
        end

        local scriptIds = self:NormalizeScriptIds(extra.scriptIds)
        if scriptIds ~= nil then
            target.scriptIds = scriptIds
        end
    end

    targets[#targets + 1] = target
end

local function ResolveCraftedAbilityIdFromAbilityId(abilityId)
    abilityId = LTM_SHARED_UTIL:NormalizeNumber(abilityId)
    if abilityId == nil or abilityId <= 0 or type(GetAbilityCraftedAbilityId) ~= "function" then
        return nil
    end

    local ok, craftedAbilityId = pcall(GetAbilityCraftedAbilityId, abilityId)
    if not ok then
        return nil
    end

    craftedAbilityId = LTM_SHARED_UTIL:NormalizeNumber(craftedAbilityId)
    if craftedAbilityId ~= nil and craftedAbilityId > 0 then
        return craftedAbilityId
    end

    return nil
end

function LTM_SHARED_UTIL:ResolveCraftedAbilityTarget(target, skillData)
    local targetAbilityId = self:NormalizeNumber(type(target) == "table" and (target.targetAbilityId or target.abilityId) or nil)
    local slotActionType = self:NormalizeNumber(type(target) == "table" and target.slotActionType or nil)
    local savedCraftedAbilityId = self:NormalizeNumber(type(target) == "table" and target.craftedAbilityId or nil)
    local craftedAbilityActionType = ACTION_TYPE_CRAFTED_ABILITY or 3

    if slotActionType == craftedAbilityActionType then
        local fallbackCraftedAbilityId = nil
        if savedCraftedAbilityId == nil or savedCraftedAbilityId <= 0 then
            fallbackCraftedAbilityId = ResolveCraftedAbilityIdFromAbilityId(targetAbilityId)
        end
        return {
            isCrafted = true,
            craftedAbilityId = savedCraftedAbilityId ~= nil and savedCraftedAbilityId > 0
                and savedCraftedAbilityId
                or fallbackCraftedAbilityId,
            source = "saved_slot_action_type",
            fallbackCraftedAbilityId = fallbackCraftedAbilityId,
        }
    end

    if savedCraftedAbilityId ~= nil and savedCraftedAbilityId > 0 then
        return {
            isCrafted = true,
            craftedAbilityId = savedCraftedAbilityId,
            source = "saved_crafted_ability_id",
            fallbackCraftedAbilityId = nil,
        }
    end

    local fallbackCraftedAbilityId = ResolveCraftedAbilityIdFromAbilityId(targetAbilityId)
    if fallbackCraftedAbilityId ~= nil and fallbackCraftedAbilityId > 0 then
        return {
            isCrafted = true,
            craftedAbilityId = fallbackCraftedAbilityId,
            source = "ability_api_fallback",
            fallbackCraftedAbilityId = fallbackCraftedAbilityId,
        }
    end

    if type(skillData) == "table"
        and type(skillData.IsCraftedAbility) == "function"
        and skillData:IsCraftedAbility() == true then
        return {
            isCrafted = true,
            craftedAbilityId = nil,
            source = "skill_data",
            fallbackCraftedAbilityId = fallbackCraftedAbilityId,
        }
    end

    return {
        isCrafted = false,
        craftedAbilityId = nil,
        source = "none",
        fallbackCraftedAbilityId = fallbackCraftedAbilityId,
    }
end

local function ResolveSkillLineIdFromSkillData(skillData, skillLineData)
    if type(skillData) == "table" and type(skillData.GetSkillLineId) == "function" then
        local skillLineId = skillData:GetSkillLineId()
        if type(skillLineId) == "number" and skillLineId > 0 then
            return skillLineId, "skillData.GetSkillLineId"
        end
    end

    if type(skillLineData) == "table" and type(skillLineData.GetId) == "function" then
        local skillLineId = skillLineData:GetId()
        if type(skillLineId) == "number" and skillLineId > 0 then
            return skillLineId, "skillLineData.GetId"
        end
    end

    if type(skillLineData) == "table" and type(skillLineData.GetSkillLineId) == "function" then
        local skillLineId = skillLineData:GetSkillLineId()
        if type(skillLineId) == "number" and skillLineId > 0 then
            return skillLineId, "skillLineData.GetSkillLineId"
        end
    end

    return nil, "unresolved"
end

function LTM_SHARED_UTIL:ResolveActiveSkillTargetState(target, options)
    local resolved = {
        hotbarCategory = self:NormalizeNumber(type(target) == "table" and target.hotbarCategory or nil),
        slotIndex = self:NormalizeNumber(type(target) == "table" and (target.slotIndex or target.slot) or nil),
        targetAbilityId = self:NormalizeNumber(type(target) == "table" and (target.targetAbilityId or target.abilityId) or nil),
        slotActionType = self:NormalizeNumber(type(target) == "table" and target.slotActionType or nil),
        craftedAbilityId = self:NormalizeNumber(type(target) == "table" and target.craftedAbilityId or nil),
        scriptIds = type(target) == "table" and target.scriptIds or nil,
        progressionId = nil,
        targetMorphSlot = nil,
        currentMorphSlot = nil,
        pendingMorphSlot = nil,
        effectiveMorphSlotForPlanning = nil,
        currentEffectiveAbilityId = nil,
        skillLineId = nil,
        isActiveSkill = false,
        isPassiveSkill = false,
        isCraftedAbility = false,
        isClassSkillLine = false,
        skillLineActive = false,
        isPlayerClassSkillLine = false,
        skillPointCostMultiplier = nil,
        committedPurchased = false,
        pendingPurchaseObserved = false,
        effectivePurchasedForPlanning = false,
        pendingMorphObserved = false,
        requiresPurchase = false,
        requiresMorph = false,
        ready = false,
        unresolved = false,
        nonSlottable = false,
        sameMorphSlotForPlanning = false,
        effectiveSkillLineActiveForPlanning = false,
        reason = nil,
        progressionData = nil,
        skillData = nil,
        skillLineData = nil,
        skillLineIdSource = nil,
        allocator = nil,
    }

    if resolved.targetAbilityId == nil then
        resolved.unresolved = true
        resolved.reason = "invalid_target_ability_id"
        return resolved
    end

    if resolved.targetAbilityId <= 0 then
        resolved.ready = true
        resolved.reason = "empty_target_slot"
        return resolved
    end

    if resolved.targetAbilityId == CRYPT_CANON_SPECIAL_ULTIMATE_ID then
        resolved.unresolved = true
        resolved.reason = "cryptcanon_special_ultimate_requires_overwrite"
        return resolved
    end

    local craftedInfo = self:ResolveCraftedAbilityTarget(resolved)
    resolved.fallbackCraftedAbilityId = craftedInfo.fallbackCraftedAbilityId
    resolved.craftedResolveSource = craftedInfo.source
    if craftedInfo.isCrafted == true then
        resolved.craftedAbilityId = craftedInfo.craftedAbilityId or resolved.craftedAbilityId
        resolved.nonSlottable = true
        resolved.isCraftedAbility = true
        resolved.reason = "crafted_ability_not_supported"
        return resolved
    end

    if type(SKILLS_DATA_MANAGER) ~= "table"
        or type(SKILLS_DATA_MANAGER.GetProgressionDataByAbilityId) ~= "function" then
        resolved.unresolved = true
        resolved.reason = "skills_data_manager_unavailable"
        return resolved
    end

    local progressionData = SKILLS_DATA_MANAGER:GetProgressionDataByAbilityId(resolved.targetAbilityId)
    if type(progressionData) ~= "table" then
        resolved.unresolved = true
        resolved.reason = "unknown_target_ability"
        return resolved
    end
    resolved.progressionData = progressionData

    local skillData = type(progressionData.GetSkillData) == "function" and progressionData:GetSkillData() or nil
    if type(skillData) ~= "table" then
        resolved.unresolved = true
        resolved.reason = "skill_data_unavailable"
        return resolved
    end
    resolved.skillData = skillData

    resolved.progressionId = type(skillData.GetProgressionId) == "function" and skillData:GetProgressionId() or nil
    resolved.targetMorphSlot = type(progressionData.GetMorphSlot) == "function" and progressionData:GetMorphSlot() or nil
    resolved.isActiveSkill = type(skillData.IsActive) == "function" and skillData:IsActive() or false
    resolved.isPassiveSkill = type(skillData.IsPassive) == "function" and skillData:IsPassive() or false
    resolved.isCraftedAbility = type(skillData.IsCraftedAbility) == "function" and skillData:IsCraftedAbility() or false
    if resolved.isCraftedAbility == true then
        resolved.craftedResolveSource = "skill_data"
    end

    if not resolved.isActiveSkill then
        resolved.nonSlottable = true
        resolved.reason = "target_is_not_active_skill"
        return resolved
    end

    if resolved.isPassiveSkill then
        resolved.nonSlottable = true
        resolved.reason = "passive_not_supported"
        return resolved
    end

    if resolved.isCraftedAbility then
        resolved.nonSlottable = true
        resolved.reason = "crafted_ability_not_supported"
        return resolved
    end

    local skillLineData = type(skillData.GetSkillLineData) == "function" and skillData:GetSkillLineData() or nil
    if type(skillLineData) ~= "table" then
        resolved.unresolved = true
        resolved.reason = "skill_line_data_unavailable"
        return resolved
    end
    resolved.skillLineData = skillLineData
    resolved.skillLineId, resolved.skillLineIdSource = ResolveSkillLineIdFromSkillData(skillData, skillLineData)

    resolved.isClassSkillLine = type(skillLineData.IsClassSkillLine) == "function"
        and skillLineData:IsClassSkillLine() == true
        or false
    resolved.skillLineActive = type(skillLineData.IsActive) == "function" and skillLineData:IsActive() or false
    resolved.effectiveSkillLineActiveForPlanning = resolved.skillLineActive
    resolved.isPlayerClassSkillLine = type(skillLineData.IsPlayerClassSkillLine) == "function"
        and skillLineData:IsPlayerClassSkillLine()
        or false
    if type(skillData.GetSkillPointCostMultiplier) == "function" then
        local ok, multiplier = pcall(skillData.GetSkillPointCostMultiplier, skillData)
        multiplier = ok and tonumber(multiplier) or nil
        if multiplier ~= nil and multiplier > 0 and math.floor(multiplier) == multiplier then
            resolved.skillPointCostMultiplier = multiplier
        end
    end
    resolved.committedPurchased = type(skillData.IsPurchased) == "function" and skillData:IsPurchased() or false

    local allocator = type(skillData.GetPointAllocator) == "function" and skillData:GetPointAllocator() or nil
    resolved.allocator = allocator
    if type(allocator) == "table" and type(allocator.IsPurchasedChangePending) == "function" then
        resolved.pendingPurchaseObserved = allocator:IsPurchasedChangePending() == true
    end
    resolved.effectivePurchasedForPlanning = resolved.committedPurchased or resolved.pendingPurchaseObserved

    if not resolved.effectivePurchasedForPlanning then
        resolved.requiresPurchase = true
        resolved.reason = "skill_not_purchased"
        return resolved
    end

    if not resolved.effectiveSkillLineActiveForPlanning then
        resolved.unresolved = true
        resolved.reason = "skill_line_not_active"
        return resolved
    end

    local currentProgressionData = type(skillData.GetPointAllocatorProgressionData) == "function"
        and skillData:GetPointAllocatorProgressionData()
        or nil
    if type(currentProgressionData) ~= "table" then
        resolved.unresolved = true
        resolved.reason = "current_progression_unavailable"
        return resolved
    end

    resolved.currentEffectiveAbilityId = type(currentProgressionData.GetEffectiveAbilityId) == "function"
        and currentProgressionData:GetEffectiveAbilityId(resolved.hotbarCategory)
        or nil
    resolved.currentMorphSlot = type(skillData.GetCurrentMorphSlot) == "function" and skillData:GetCurrentMorphSlot() or nil

    if type(allocator) == "table" and type(allocator.GetMorphSlot) == "function" then
        resolved.pendingMorphSlot = allocator:GetMorphSlot()
    end

    resolved.pendingMorphObserved = resolved.targetMorphSlot ~= nil
        and resolved.pendingMorphSlot ~= nil
        and resolved.pendingMorphSlot == resolved.targetMorphSlot

    if resolved.pendingMorphObserved then
        resolved.effectiveMorphSlotForPlanning = resolved.pendingMorphSlot
    else
        resolved.effectiveMorphSlotForPlanning = resolved.currentMorphSlot
    end

    resolved.sameMorphSlotForPlanning = resolved.targetMorphSlot ~= nil
        and resolved.effectiveMorphSlotForPlanning ~= nil
        and resolved.effectiveMorphSlotForPlanning == resolved.targetMorphSlot

    if resolved.currentEffectiveAbilityId == resolved.targetAbilityId
        or resolved.pendingMorphObserved then
        resolved.ready = true
        if resolved.pendingMorphObserved then
            resolved.reason = "pending_morph_ready"
        else
            resolved.reason = "already_ready"
        end
        return resolved
    end

    resolved.requiresMorph = true
    if resolved.targetMorphSlot ~= nil
        and resolved.effectiveMorphSlotForPlanning ~= nil
        and resolved.effectiveMorphSlotForPlanning ~= resolved.targetMorphSlot then
        resolved.reason = "target_morph_differs_from_current"
    else
        resolved.reason = "target_effective_ability_not_current"
    end

    return resolved
end

function LTM_SHARED_UTIL:NormalizeLineIdList(lineIds)
    local normalized = {}
    local seen = {}

    if type(lineIds) ~= "table" then
        return normalized
    end

    for _, rawValue in ipairs(lineIds) do
        local lineId = self:NormalizeNumber(rawValue)
        if lineId ~= nil and not seen[lineId] then
            seen[lineId] = true
            normalized[#normalized + 1] = lineId
        end
    end

    table.sort(normalized)
    return normalized
end

function LTM_SHARED_UTIL:BuildLineIdSet(lineIds)
    local set = {}
    for _, lineId in ipairs(lineIds or {}) do
        set[lineId] = true
    end
    return set
end

function LTM_SHARED_UTIL:BuildLineIdSignature(lineIds)
    local normalized = self:NormalizeLineIdList(lineIds)
    return table.concat(normalized, ",")
end

local function CloneTableShallow(source)
    -- Shallow copy only: nested build sections such as skills, equipment,
    -- and subclass remain shared with the source build. Use this only for
    -- top-level replacement, not for mutating nested tables.
    local clone = {}
    for key, value in pairs(source or {}) do
        clone[key] = value
    end
    return clone
end

local function CloneRunOptions(options)
    if type(options.spSaver) ~= "table" then
        return options
    end

    local cloned = CloneTableShallow(options)
    cloned.spSaver = CloneTableShallow(options.spSaver)
    return cloned
end

local function AppendUniqueString(target, seen, value)
    if type(value) ~= "string" or value == "" or seen[value] then
        return
    end

    seen[value] = true
    target[#target + 1] = value
end

local function AppendResidualSummary(entry, residualSummary)
    if type(residualSummary) ~= "table" then
        return
    end

    entry.residualSummaries = entry.residualSummaries or {}
    for _, existing in ipairs(entry.residualSummaries) do
        if existing == residualSummary then
            return
        end
    end

    entry.residualSummaries[#entry.residualSummaries + 1] = residualSummary
    if type(entry.residualSummary) ~= "table" then
        entry.residualSummary = residualSummary
        return
    end

    local merged = CloneTableShallow(entry.residualSummary)
    for key, value in pairs(residualSummary) do
        merged[key] = value
    end
    entry.residualSummary = merged
end

local function RefreshPartialSuccessCompatibilityView(context)
    context.partialSuccessResult = nil
    for _, entry in ipairs(context.domainResults or {}) do
        if entry.severity == "partial" then
            context.partialSuccessResult = {
                sourcePhase = entry.sourcePhase,
                resultCode = entry.resultCode,
                reasons = entry.reasons,
                residualSummary = entry.residualSummary,
            }
            return
        end
    end
end

local SP_SAVER_TARGET_NORMAL_SKILLS = "normal_skill_changes"
local SP_SAVER_TARGET_NORMAL_PASSIVES = "normal_passive_changes"

local function ResolveSpSaverPolicy(context)
    local runOptions = type(context) == "table" and context.runOptions or nil
    return type(runOptions) == "table" and type(runOptions.spSaver) == "table"
        and runOptions.spSaver
        or nil
end

local function ResolveSpSaverReason(policy, target)
    if type(policy) ~= "table" then
        return nil
    end

    if target == SP_SAVER_TARGET_NORMAL_SKILLS then
        return policy.activeAction == "skip_skill_changes"
            and "sp_saver_skip_skill_changes"
            or nil
    end

    if target ~= SP_SAVER_TARGET_NORMAL_PASSIVES then
        return nil
    end

    if policy.activeAction == "skip_skill_changes" then
        return "sp_saver_skip_skill_changes"
    end
    if policy.passiveAction ~= "skip_passive_changes" then
        return nil
    end
    if policy.passiveMode == "all_or_nothing" then
        return "sp_saver_passive_all_or_nothing_skipped"
    end
    if policy.passiveMode == "preserve_current" then
        return "sp_saver_passive_preserve_current_skipped"
    end

    return nil
end

local function ResolveCharacterId()
    if type(GetCurrentCharacterId) == "function" then
        local ok, characterId = pcall(GetCurrentCharacterId)
        if ok then
            return characterId
        end
    end

    return nil
end

local function ResolveBaseClassId()
    if type(GetUnitClassId) == "function" then
        local ok, classId = pcall(GetUnitClassId, "player")
        if ok then
            return classId
        end
    end

    return nil
end

function LTM_PIPELINE_CONTEXT:Create(build, options)
    options = type(options) == "table" and options or {}
    local runOptions = CloneRunOptions(options)
    return {
        characterId = ResolveCharacterId(),
        baseClassId = ResolveBaseClassId(),
        targetBuild = build,
        currentState = {},
        runtime = {},
        phaseResults = {},
        domainResults = {},
        _domainResultIndexByDomain = {},
        _domainResultReasonSets = {},
        resolvedPlan = nil,
        cancelRequested = false,
        cancelReason = nil,
        cancelRequestedAtPhase = nil,
        partialScope = runOptions.partialScope,
        preflightMode = runOptions.preflightMode,
        onPhaseUpdate = type(runOptions.onPhaseUpdate) == "function" and runOptions.onPhaseUpdate or nil,
        onStatusUpdate = type(runOptions.onStatusUpdate) == "function" and runOptions.onStatusUpdate or nil,
        runOptions = runOptions,
    }
end

function LTM_PIPELINE_CONTEXT:RecordDomainResult(context, result)
    if type(context) ~= "table" or type(result) ~= "table" then
        return nil
    end

    local domain = result.domain or result.sourcePhase
    if type(domain) ~= "string" or domain == "" then
        return nil
    end

    context.domainResults = type(context.domainResults) == "table" and context.domainResults or {}
    context._domainResultIndexByDomain = type(context._domainResultIndexByDomain) == "table"
        and context._domainResultIndexByDomain
        or {}
    context._domainResultReasonSets = type(context._domainResultReasonSets) == "table"
        and context._domainResultReasonSets
        or {}

    local entryIndex = context._domainResultIndexByDomain[domain]
    local entry = entryIndex ~= nil and context.domainResults[entryIndex] or nil
    if type(entry) ~= "table" then
        entry = {
            domain = domain,
            sourcePhase = type(result.sourcePhase) == "string" and result.sourcePhase or domain,
            severity = result.severity == "failure" and "failure" or "partial",
            resultCode = result.resultCode,
            reasons = {},
            residualSummary = nil,
            residualSummaries = {},
        }
        context.domainResults[#context.domainResults + 1] = entry
        context._domainResultIndexByDomain[domain] = #context.domainResults
        context._domainResultReasonSets[domain] = {}
    elseif entry.severity ~= "failure" and result.severity == "failure" then
        entry.severity = "failure"
    end

    if (type(entry.sourcePhase) ~= "string" or entry.sourcePhase == "")
        and type(result.sourcePhase) == "string" then
        entry.sourcePhase = result.sourcePhase
    end
    if (type(entry.resultCode) ~= "string" or entry.resultCode == "")
        and type(result.resultCode) == "string" then
        entry.resultCode = result.resultCode
    end

    local reasonSet = context._domainResultReasonSets[domain]
    for _, reason in ipairs(type(result.reasons) == "table" and result.reasons or {}) do
        AppendUniqueString(entry.reasons, reasonSet, reason)
    end
    AppendResidualSummary(entry, result.residualSummary)
    RefreshPartialSuccessCompatibilityView(context)
    return entry
end

function LTM_PIPELINE_CONTEXT:GetDomainResults(context)
    if type(context) ~= "table" or type(context.domainResults) ~= "table" then
        return {}
    end

    return context.domainResults
end

function LTM_PIPELINE_CONTEXT:SetPhaseResult(context, phaseName, result)
    if type(context) ~= "table" or type(phaseName) ~= "string" then
        return nil
    end

    context.phaseResults = context.phaseResults or {}
    context.phaseResults[phaseName] = result
    return result
end

function LTM_PIPELINE_CONTEXT:GetPhaseResult(context, phaseName)
    if type(context) ~= "table" or type(phaseName) ~= "string" then
        return nil
    end

    return type(context.phaseResults) == "table" and context.phaseResults[phaseName] or nil
end

function LTM_PIPELINE_CONTEXT:GetRuntime(context)
    if type(context) ~= "table" then
        return nil
    end

    context.runtime = context.runtime or {}
    return context.runtime
end

function LTM_PIPELINE_CONTEXT:SetRuntimeFlag(context, key, value)
    if type(context) ~= "table" or type(key) ~= "string" then
        return nil
    end

    local runtime = self:GetRuntime(context)
    runtime[key] = value
    return value
end

function LTM_PIPELINE_CONTEXT:GetRuntimeFlag(context, key)
    if type(context) ~= "table" or type(key) ~= "string" then
        return nil
    end

    local runtime = self:GetRuntime(context)
    return runtime[key]
end

function LTM_PIPELINE_CONTEXT:GetSpSaverSkipReason(context, target)
    return ResolveSpSaverReason(ResolveSpSaverPolicy(context), target)
end

function LTM_PIPELINE_CONTEXT:RecordSpSaverExpectedSkip(context, target)
    if type(context) ~= "table"
        or (target ~= SP_SAVER_TARGET_NORMAL_SKILLS and target ~= SP_SAVER_TARGET_NORMAL_PASSIVES) then
        return false
    end

    context.spSaverExpected = type(context.spSaverExpected) == "table" and context.spSaverExpected or {
        skippedTargets = {},
    }
    context.spSaverExpected.skippedTargets[target] = true
    return true
end

function LTM_PIPELINE_CONTEXT:GetSpSaverExpectedSummary(context)
    local expected = type(context) == "table" and context.spSaverExpected or nil
    if type(expected) ~= "table" then
        return nil
    end

    return {
        skippedTargets = CloneTableShallow(expected.skippedTargets),
    }
end

function LTM_PIPELINE_CONTEXT:RecordSpSaverSkip(context, target, reason)
    if type(context) ~= "table"
        or (target ~= SP_SAVER_TARGET_NORMAL_SKILLS and target ~= SP_SAVER_TARGET_NORMAL_PASSIVES) then
        return false
    end

    local resolvedReason = reason or self:GetSpSaverSkipReason(context, target)
    if type(resolvedReason) ~= "string" or resolvedReason == "" then
        return false
    end

    local runtime = type(context.spSaverRuntime) == "table" and context.spSaverRuntime or {
        skippedTargets = {},
        reasons = {},
        reasonSet = {},
    }
    context.spSaverRuntime = runtime
    runtime.skippedTargets[target] = true
    if runtime.reasonSet[resolvedReason] ~= true then
        runtime.reasonSet[resolvedReason] = true
        runtime.reasons[#runtime.reasons + 1] = resolvedReason
    end
    return true
end

function LTM_PIPELINE_CONTEXT:GetSpSaverRuntimeSummary(context)
    local runtime = type(context) == "table" and context.spSaverRuntime or nil
    if type(runtime) ~= "table" then
        return nil
    end

    local skippedTargets = CloneTableShallow(runtime.skippedTargets)
    local reasons = {}
    for index, reason in ipairs(runtime.reasons or {}) do
        reasons[index] = reason
    end
    return {
        skippedTargets = skippedTargets,
        reasons = reasons,
    }
end

function LTM_PIPELINE_CONTEXT:GetTargetSubclassState(context)
    if type(context) ~= "table" then
        return nil
    end

    return context.targetBuild and context.targetBuild.subclass or nil
end

function LTM_PIPELINE_CONTEXT:GetCurrentSubclassState(context)
    if type(context) ~= "table" then
        return nil
    end

    return self:GetCurrentState(context, "subclass")
end

function LTM_PIPELINE_CONTEXT:SetCurrentState(context, key, value)
    if type(context) ~= "table" or type(key) ~= "string" then
        return nil
    end

    context.currentState = context.currentState or {}
    context.currentState[key] = value
    return value
end

function LTM_PIPELINE_CONTEXT:GetCurrentState(context, key)
    if type(context) ~= "table" or type(key) ~= "string" then
        return nil
    end

    return context.currentState and context.currentState[key] or nil
end

function LTM_PIPELINE_CONTEXT:SetResolvedPlan(context, plan)
    if type(context) ~= "table" then
        return nil
    end

    context.resolvedPlan = plan
    return plan
end

function LTM_PIPELINE_CONTEXT:GetResolvedPlan(context)
    if type(context) ~= "table" then
        return nil
    end

    return context.resolvedPlan
end

function LTM_PIPELINE_CONTEXT:GetPartialScope(context)
    if type(context) ~= "table" then
        return nil
    end

    return context.partialScope
end

function LTM_PIPELINE_CONTEXT:GetPreflightMode(context)
    if type(context) ~= "table" then
        return nil
    end

    return context.preflightMode
end
