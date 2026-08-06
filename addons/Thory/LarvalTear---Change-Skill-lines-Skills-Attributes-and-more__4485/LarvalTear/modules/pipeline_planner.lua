local Addon = LarvalTearMod
local Log = Addon.Common.Log
local LTM_ATTRIBUTE_SNAPSHOT = Addon.Modules.AttributeSnapshot
local LTM_BUILD_STORE = Addon.Modules.BuildStore
local LTM_PIPELINE_PLANNER = Addon.Modules.PipelinePlanner
local LTM_PIPELINE_CONTEXT = Addon.Modules.PipelineContext
local LTM_PASSIVE_SNAPSHOT_APPLY = Addon.Modules.PassiveSnapshotApply
local LTM_ROLE_STATE = Addon.Modules.RoleState
local LTM_SUBCLASS_PLANNER = Addon.Modules.SubclassPlanner
local LTM_BUILD_CODEC = Addon.Modules.BuildCodec
local LTM_TRANSFORM_SKILLS = Addon.Modules.TransformSkills

local SHARED_UTIL = Addon.Common.Util

local function HasEntries(value)
    return type(value) == "table" and next(value) ~= nil
end

local function NormalizeTargets(skillConfig)
    return SHARED_UTIL:NormalizeSlotTargets(skillConfig)
end

local function CloneConfig(config)
    -- Shallow copy only: nested tables such as morphChanges remain shared.
    -- Current planner flow reads nested data without mutating it; switch to a
    -- deep copy or another owner before editing nested config in the future.
    local cloned = {}
    for key, value in pairs(config or {}) do
        cloned[key] = value
    end
    return cloned
end

local function CloneCollection(collection)
    local cloned = {}
    for key, value in pairs(type(collection) == "table" and collection or {}) do
        cloned[key] = value
    end
    return cloned
end

local function CloneTransformPlan(plan)
    local cloned = CloneConfig(plan)
    -- Skip and execution-time partial handling mutate these collections. Keep
    -- the analyzed diagnostics immutable when the runtime plan diverges.
    cloned.residuals = CloneCollection(plan.residuals)
    cloned.residualSet = CloneCollection(plan.residualSet)
    cloned.skippedKinds = CloneCollection(plan.skippedKinds)
    return cloned
end

local function SeparateDeferredTransformSlots(skillConfig, transformPlan)
    local progressionKinds = type(transformPlan) == "table"
        and transformPlan.deferredProgressionKinds
        or nil
    local unpurchasedProgressions = type(transformPlan) == "table"
        and transformPlan.deferredUnpurchasedProgressions
        or nil
    if type(progressionKinds) ~= "table" or next(progressionKinds) == nil then
        return
    end

    local restoreTargets = {}
    local deferredSlots = {}
    for _, target in ipairs(NormalizeTargets(skillConfig)) do
        local resolved = SHARED_UTIL:ResolveActiveSkillTargetState(target)
        local progressionId = type(resolved) == "table"
            and tonumber(resolved.progressionId)
            or nil
        progressionId = progressionId ~= nil and math.floor(progressionId) or nil
        local transformKind = progressionId ~= nil and progressionKinds[progressionId] or nil
        if type(transformKind) == "string" then
            deferredSlots[#deferredSlots + 1] = {
                hotbarCategory = target.hotbarCategory,
                slotIndex = target.slotIndex,
                progressionId = progressionId,
                savedAbilityId = target.abilityId,
                transformKind = transformKind,
                targetPurchased = type(unpurchasedProgressions) ~= "table"
                    or unpurchasedProgressions[progressionId] ~= true,
            }
        else
            restoreTargets[#restoreTargets + 1] = target
        end
    end

    if #deferredSlots > 0 then
        skillConfig.slots = restoreTargets
        skillConfig.hotbars = nil
        for _, hotbarCategory in ipairs(SHARED_UTIL.HOTBAR_CATEGORIES or { 0, 1 }) do
            skillConfig[hotbarCategory] = nil
        end
        skillConfig.skills = nil
        skillConfig.deferredTransformSlots = deferredSlots
    end
end

local function NormalizeClassMasteryPurchasedAbilities(purchasedAbilities)
    local normalized = {}
    if type(purchasedAbilities) ~= "table" then
        return normalized
    end

    for abilityId, rank in pairs(purchasedAbilities) do
        local normalizedAbilityId = tonumber(abilityId)
        local normalizedRank = tonumber(rank)
        if normalizedAbilityId ~= nil and normalizedAbilityId > 0
            and normalizedRank ~= nil and normalizedRank > 0 then
            normalized[math.floor(normalizedAbilityId)] = math.floor(normalizedRank)
        end
    end

    return normalized
end

local function CountMapEntries(entries)
    local count = 0
    for _ in pairs(entries or {}) do
        count = count + 1
    end
    return count
end

function LTM_PIPELINE_PLANNER:ResolveClassMasteryDiff(currentState, targetBuild)
    local targetMastery = type(targetBuild) == "table" and targetBuild.classMastery or nil
    if type(targetMastery) ~= "table" then
        return {
            hasDiff = false,
            requiresRespec = false,
            reason = "target_missing",
            reductions = {},
        }
    end

    local targetSkillLineId = tonumber(targetMastery.targetSkillLineId)
    if targetSkillLineId == nil or targetSkillLineId <= 0 then
        return {
            hasDiff = false,
            requiresRespec = false,
            reason = "target_line_missing",
            reductions = {},
        }
    end
    targetSkillLineId = math.floor(targetSkillLineId)

    local currentMastery = type(currentState) == "table" and currentState.classMastery or nil
    if currentMastery == nil
        and type(LTM_BUILD_STORE) == "table"
        and type(LTM_BUILD_STORE.CaptureCurrentClassMasteryForBuild) == "function" then
        currentMastery = LTM_BUILD_STORE:CaptureCurrentClassMasteryForBuild()
    end

    if type(currentMastery) ~= "table" then
        return {
            hasDiff = CountMapEntries(NormalizeClassMasteryPurchasedAbilities(targetMastery.purchasedAbilities)) > 0,
            requiresRespec = false,
            reason = "current_missing_or_empty",
            current = nil,
            target = targetMastery,
            reductions = {},
        }
    end

    local currentSkillLineId = tonumber(currentMastery.targetSkillLineId)
    currentSkillLineId = currentSkillLineId ~= nil and math.floor(currentSkillLineId) or nil
    local currentPurchases = NormalizeClassMasteryPurchasedAbilities(currentMastery.purchasedAbilities)
    local targetPurchases = NormalizeClassMasteryPurchasedAbilities(targetMastery.purchasedAbilities)
    local reductions = {}
    local additions = {}
    local reasons = {}
    local hasSkillLineDiff = currentSkillLineId ~= nil
        and currentSkillLineId > 0
        and currentSkillLineId ~= targetSkillLineId

    if hasSkillLineDiff then
        for abilityId, currentRank in pairs(currentPurchases) do
            reductions[#reductions + 1] = {
                skillLineId = currentSkillLineId,
                abilityId = abilityId,
                currentRank = currentRank,
                targetRank = 0,
                reason = "line_switch_requires_refund",
            }
        end
        if #reductions > 0 then
            reasons[#reasons + 1] = "line_switch_requires_refund"
        end
    else
        for abilityId, currentRank in pairs(currentPurchases) do
            local targetRank = targetPurchases[abilityId] or 0
            if currentRank > targetRank then
                reductions[#reductions + 1] = {
                    skillLineId = currentSkillLineId,
                    abilityId = abilityId,
                    currentRank = currentRank,
                    targetRank = targetRank,
                    reason = targetRank > 0 and "rank_reduce_required" or "target_ability_absent",
                }
                reasons[#reasons + 1] = targetRank > 0 and "rank_reduce_required" or "target_ability_absent"
            end
        end
    end

    local hasAdditionDiff = false
    if currentSkillLineId == targetSkillLineId then
        for abilityId, targetRank in pairs(targetPurchases) do
            local currentRank = currentPurchases[abilityId] or 0
            if currentRank < targetRank then
                hasAdditionDiff = true
                additions[#additions + 1] = {
                    skillLineId = targetSkillLineId,
                    abilityId = abilityId,
                    currentRank = currentRank,
                    targetRank = targetRank,
                    reason = "rank_increase_required",
                }
            end
        end
    elseif CountMapEntries(targetPurchases) > 0 then
        hasAdditionDiff = true
        for abilityId, targetRank in pairs(targetPurchases) do
            additions[#additions + 1] = {
                skillLineId = targetSkillLineId,
                abilityId = abilityId,
                currentRank = 0,
                targetRank = targetRank,
                reason = "target_line_purchase_required",
            }
        end
    end

    local reason = #reductions > 0 and table.concat(reasons, ",")
        or (hasSkillLineDiff and "target_line_changed")
        or (hasAdditionDiff and "additions_only")
        or "matched"
    if type(Log.LogDebugSummary) == "function" then
        Log.LogDebugSummary(
            "Planner Class Mastery diff",
            "requiresRespec=" .. tostring(#reductions > 0),
            "reason=" .. tostring(reason),
            "currentLine=" .. tostring(currentSkillLineId),
            "targetLine=" .. tostring(targetSkillLineId),
            "currentPurchases=" .. tostring(CountMapEntries(currentPurchases)),
            "targetPurchases=" .. tostring(CountMapEntries(targetPurchases)),
            "reductions=" .. tostring(#reductions),
            "additions=" .. tostring(#additions),
            "lineChanged=" .. tostring(hasSkillLineDiff),
            "additionsOnly=" .. tostring(hasAdditionDiff and #reductions == 0)
        )
    end

    return {
        hasDiff = hasSkillLineDiff or #reductions > 0 or hasAdditionDiff == true,
        requiresRespec = #reductions > 0,
        reason = reason,
        current = currentMastery,
        target = targetMastery,
        reductions = reductions,
        additions = additions,
        currentSkillLineId = currentSkillLineId,
        targetSkillLineId = targetSkillLineId,
    }
end

function LTM_PIPELINE_PLANNER:AnalyzeSkillTarget(target, resolved)
    if type(resolved) ~= "table" then
        if type(SHARED_UTIL) ~= "table"
            or type(SHARED_UTIL.ResolveActiveSkillTargetState) ~= "function" then
            return nil
        end
        resolved = SHARED_UTIL:ResolveActiveSkillTargetState(target)
    end
    if type(resolved) ~= "table" then
        return nil
    end

    if resolved.targetAbilityId == nil or resolved.targetAbilityId <= 0 then
        return nil
    end

    return {
        targetAbilityId = resolved.targetAbilityId,
        hotbarCategory = resolved.hotbarCategory,
        slotIndex = resolved.slotIndex,
        progressionId = resolved.progressionId,
        skillLineId = resolved.skillLineId,
        targetMorphSlot = resolved.targetMorphSlot,
        currentMorphSlot = resolved.currentMorphSlot,
        currentEffectiveAbilityId = resolved.currentEffectiveAbilityId,
        skillLineActive = resolved.skillLineActive,
        isPlayerClassSkillLine = resolved.isPlayerClassSkillLine,
        requiresPurchaseChange = resolved.requiresPurchase == true,
        requiresMorphChange = resolved.requiresMorph == true,
        unresolved = resolved.unresolved == true,
        reason = resolved.reason,
    }
end

function LTM_PIPELINE_PLANNER:ResolveSubclassDiff(context, currentState, targetBuild)
    local targetSubclass = targetBuild and targetBuild.subclass or nil
    local subclassState = nil

    if type(LTM_PIPELINE_CONTEXT) == "table" and type(LTM_PIPELINE_CONTEXT.GetCurrentSubclassState) == "function" then
        subclassState = LTM_PIPELINE_CONTEXT:GetCurrentSubclassState(context)
    end

    if subclassState == nil and type(currentState) == "table" then
        subclassState = currentState.subclass
    end

    if type(LTM_SUBCLASS_PLANNER) == "table"
        and type(LTM_SUBCLASS_PLANNER.BuildSubclassPlan) == "function" then
        local plan = LTM_SUBCLASS_PLANNER:BuildSubclassPlan(context, subclassState, targetSubclass)
        if type(plan) == "table" then
            return {
                ok = plan.ok,
                hasDiff = plan.hasDiff == true,
                activate = plan.activate or {},
                deactivate = plan.deactivate or {},
                orderedOperations = plan.orderedOperations or {},
                currentSkillLineIds = plan.currentSkillLineIds or {},
                targetSkillLineIds = plan.targetSkillLineIds or {},
                source = "subclass_planner",
                implemented = true,
                diagnostics = plan.diagnostics,
                immutable = plan.immutable,
                reason = plan.reason,
            }
        end
    end

    return {
        ok = true,
        hasDiff = HasEntries(targetSubclass and targetSubclass.targetSkillLineIds),
        activate = {},
        deactivate = {},
        orderedOperations = {},
        currentSkillLineIds = {},
        targetSkillLineIds = targetSubclass and targetSubclass.targetSkillLineIds or {},
        source = "target_stub",
        implemented = false,
    }
end

function LTM_PIPELINE_PLANNER:ResolveSkillDiff(skillConfig, activeTargetStates)
    skillConfig = skillConfig or {}

    if HasEntries(skillConfig.morphChanges) then
        return {
            hasMorphDiff = true,
            inferredMorphChanges = skillConfig.morphChanges,
            source = "explicit_morph_changes",
            reasons = {},
            requiresSubclassActivation = false,
        }
    end

    local targets = NormalizeTargets(skillConfig)
    local inferredMorphChanges = {}
    local inferredPurchaseTargets = {}
    local seenProgressionIds = {}
    local seenPurchaseProgressionIds = {}
    local reasons = {}
    local requiresSubclassActivation = false

    for targetIndex, target in ipairs(targets) do
        local analysis = self:AnalyzeSkillTarget(
            target,
            type(activeTargetStates) == "table" and activeTargetStates[targetIndex] or nil
        )
        local overriddenByTransform = analysis ~= nil
            and analysis.progressionId ~= nil
            and type(skillConfig.transformOwnedProgressions) == "table"
            and skillConfig.transformOwnedProgressions[analysis.progressionId] == true
        if not overriddenByTransform
            and analysis ~= nil
            and (analysis.requiresPurchaseChange or analysis.requiresMorphChange) then
            if analysis.reason == "skill_line_not_active" and analysis.isPlayerClassSkillLine == true then
                requiresSubclassActivation = true
            end
            local progressionKey = tostring(analysis.progressionId)
            reasons[#reasons + 1] = string.format(
                "slot=%s:%s reason=%s target=%s current=%s currentMorph=%s targetMorph=%s lineActive=%s",
                tostring(target.hotbarCategory),
                tostring(target.slotIndex),
                tostring(analysis.reason),
                tostring(analysis.targetAbilityId),
                tostring(analysis.currentEffectiveAbilityId),
                tostring(analysis.currentMorphSlot),
                tostring(analysis.targetMorphSlot),
                tostring(analysis.skillLineActive)
            )

            if analysis.requiresMorphChange == true
                and analysis.progressionId ~= nil
                and not seenProgressionIds[progressionKey] then
                seenProgressionIds[progressionKey] = true
                inferredMorphChanges[#inferredMorphChanges + 1] = {
                    targetAbilityId = analysis.targetAbilityId,
                    hotbarCategory = analysis.hotbarCategory,
                    slotIndex = analysis.slotIndex,
                }
            end

            if analysis.requiresPurchaseChange == true
                and analysis.progressionId ~= nil
                and not seenPurchaseProgressionIds[progressionKey] then
                seenPurchaseProgressionIds[progressionKey] = true
                inferredPurchaseTargets[#inferredPurchaseTargets + 1] = {
                    targetAbilityId = analysis.targetAbilityId,
                    hotbarCategory = analysis.hotbarCategory,
                    slotIndex = analysis.slotIndex,
                }
            end
        end
    end

    return {
        hasPurchaseDiff = #inferredPurchaseTargets > 0,
        hasMorphDiff = #inferredMorphChanges > 0,
        inferredPurchaseTargets = inferredPurchaseTargets,
        inferredMorphChanges = inferredMorphChanges,
        source = (#inferredPurchaseTargets > 0 or #inferredMorphChanges > 0)
            and "inferred_from_target_state"
            or "no_purchase_or_morph_diff",
        reasons = reasons,
        requiresSubclassActivation = requiresSubclassActivation,
    }
end

function LTM_PIPELINE_PLANNER:ResolveAttributeDiff(currentState, targetBuild)
    local currentAttributes = type(currentState) == "table" and currentState.attributes or nil
    local targetAttributes = targetBuild and targetBuild.attributes or nil
    local normalizedTarget = nil
    local normalizeErr = nil

    if targetAttributes ~= nil and type(LTM_ATTRIBUTE_SNAPSHOT) == "table"
        and type(LTM_ATTRIBUTE_SNAPSHOT.NormalizeTargetAttributeState) == "function" then
        normalizedTarget, normalizeErr = LTM_ATTRIBUTE_SNAPSHOT:NormalizeTargetAttributeState(targetAttributes)
    elseif type(targetAttributes) == "table" then
        normalizedTarget = targetAttributes
    end

    local hasDiff = false
    if targetAttributes ~= nil and normalizedTarget == nil and normalizeErr ~= nil then
        hasDiff = true
    elseif normalizedTarget ~= nil and type(currentAttributes) == "table" then
        hasDiff = currentAttributes.health ~= normalizedTarget.health
            or currentAttributes.magicka ~= normalizedTarget.magicka
            or currentAttributes.stamina ~= normalizedTarget.stamina
    end

    return {
        hasDiff = hasDiff,
        current = currentAttributes,
        target = normalizedTarget,
        source = targetAttributes == nil and "target_missing" or "committed_vs_target_compare",
        normalizeError = normalizeErr,
    }
end

function LTM_PIPELINE_PLANNER:ResolveRoleDiff(currentState, targetBuild)
    local currentRole = type(currentState) == "table" and currentState.role or nil
    local targetRole = type(targetBuild) == "table" and targetBuild.role or nil

    if type(LTM_ROLE_STATE) == "table" and type(LTM_ROLE_STATE.ResolveRoleDiff) == "function" then
        return LTM_ROLE_STATE:ResolveRoleDiff(currentRole, targetRole)
    end

    return {
        hasDiff = false,
        current = nil,
        target = nil,
        source = "role_state_unavailable",
    }
end

function LTM_PIPELINE_PLANNER:BuildPipelinePlan(context, currentState, targetBuild)
    targetBuild = targetBuild or {}
    local partialScope = type(LTM_PIPELINE_CONTEXT) == "table"
        and type(LTM_PIPELINE_CONTEXT.GetPartialScope) == "function"
        and LTM_PIPELINE_CONTEXT:GetPartialScope(context)
        or nil
    local allowSubclass = partialScope == nil or partialScope == "class_skills"
    local allowClassSkills = partialScope == nil or partialScope == "class_skills"
    local allowAttributes = partialScope == nil or partialScope == "attributes"
    local allowEquipment = partialScope == nil or partialScope == "equipment"
    local allowChampion = partialScope == nil or partialScope == "champion_points"
    local preflightMode = type(LTM_PIPELINE_CONTEXT) == "table"
        and type(LTM_PIPELINE_CONTEXT.GetPreflightMode) == "function"
        and LTM_PIPELINE_CONTEXT:GetPreflightMode(context)
        or nil
    local skillPhaseMode = type(context) == "table"
        and type(context.runOptions) == "table"
        and context.runOptions.skillPhaseMode
        or nil
    local skillPhaseReason = type(context) == "table"
        and type(context.runOptions) == "table"
        and context.runOptions.skillPhaseReason
        or nil
    local spSaverSkillSkipReason = type(LTM_PIPELINE_CONTEXT) == "table"
        and type(LTM_PIPELINE_CONTEXT.GetSpSaverSkipReason) == "function"
        and LTM_PIPELINE_CONTEXT:GetSpSaverSkipReason(context, "normal_skill_changes")
        or nil
    local spSaverPassiveSkipReason = type(LTM_PIPELINE_CONTEXT) == "table"
        and type(LTM_PIPELINE_CONTEXT.GetSpSaverSkipReason) == "function"
        and LTM_PIPELINE_CONTEXT:GetSpSaverSkipReason(context, "normal_passive_changes")
        or nil
    local skipSkillsForSpSaver = spSaverSkillSkipReason ~= nil
    local skipTransformForSkillPhase = skipSkillsForSpSaver
        or skillPhaseMode == "skip_due_to_insufficient_points"
        or preflightMode == "subclass_only"
    local skillConfig = CloneConfig(targetBuild.skills or {})
    local analyzedTransformPlan = LTM_TRANSFORM_SKILLS:BuildPlan(targetBuild.transforms, skillConfig)
    if targetBuild.transforms ~= nil then
        LTM_TRANSFORM_SKILLS:LogPlan(analyzedTransformPlan)
    end
    local transformPlan = analyzedTransformPlan
    if skipTransformForSkillPhase then
        transformPlan = CloneTransformPlan(analyzedTransformPlan)
        LTM_TRANSFORM_SKILLS:SkipPlanOperations(
            transformPlan,
            context,
            skillConfig
        )
        transformPlan.skippedBySpSaver = skipSkillsForSpSaver == true
    else
        LTM_TRANSFORM_SKILLS:RecordPlanResiduals(context, analyzedTransformPlan)
    end
    skillConfig.transformTargets = transformPlan.targets
    skillConfig.transformOwnedProgressions = transformPlan.transformOwnedProgressions
    SeparateDeferredTransformSlots(skillConfig, transformPlan)
    local passivePolicy = LTM_BUILD_CODEC:NormalizePassivePolicy(type(targetBuild) == "table" and targetBuild.passivePolicy or nil)
    local championPointsConfig = nil
    local championOptions = nil
    if type(targetBuild.championPoints) == "table" then
        championPointsConfig = CloneConfig(targetBuild.championPoints)
        championOptions = {
            forceChampionRespec = type(context) == "table"
                and type(context.runOptions) == "table"
                and context.runOptions.forceChampionRespec == true,
        }
    end
    local subclassDiff = self:ResolveSubclassDiff(context, currentState, targetBuild)
    local activeTargetStates = type(context) == "table" and context.skillPointActiveTargetStates or nil
    if type(skillConfig.deferredTransformSlots) == "table"
        and #skillConfig.deferredTransformSlots > 0 then
        -- The evaluator states are indexed against the pre-separation slot
        -- sequence. Deferred Transform slots change that sequence, so reusing
        -- the old indexes would associate states with the wrong targets.
        activeTargetStates = nil
    end
    local skillDiff = self:ResolveSkillDiff(skillConfig, activeTargetStates)
    local attributeDiff = self:ResolveAttributeDiff(currentState, targetBuild)
    local roleDiff = self:ResolveRoleDiff(currentState, targetBuild)
    local classMasteryDiff = self:ResolveClassMasteryDiff(currentState, targetBuild)
    local needsSubclassChange = subclassDiff.hasDiff == true
    local inferredSubclassRequirement = type(targetBuild.subclass) == "table"
        and skillDiff.requiresSubclassActivation == true
    if not needsSubclassChange and inferredSubclassRequirement then
        needsSubclassChange = true
    end
    local analyzedNeedsPurchaseChange = skillDiff.hasPurchaseDiff == true
    local analyzedNeedsMorphChange = skillDiff.hasMorphDiff == true
    local analyzedTransformInvalid = analyzedTransformPlan.ok ~= true
    local analyzedNeedsTransformChange = analyzedTransformPlan.hasDiff == true
        or analyzedTransformInvalid
    local needsPurchaseChange = skipSkillsForSpSaver ~= true and analyzedNeedsPurchaseChange
    local needsMorphChange = skipSkillsForSpSaver ~= true and analyzedNeedsMorphChange
    local needsTransformChange = skipTransformForSkillPhase ~= true and analyzedNeedsTransformChange
    local passiveAnalysis = type(LTM_PASSIVE_SNAPSHOT_APPLY) == "table"
        and type(LTM_PASSIVE_SNAPSHOT_APPLY.AnalyzeBuild) == "function"
        and LTM_PASSIVE_SNAPSHOT_APPLY:AnalyzeBuild(targetBuild, {
            source = "pipeline_planner",
        })
        or nil
    local analyzedNeedsPassiveRespec = type(passiveAnalysis) == "table"
        and passiveAnalysis.requiresRespecForPassive == true
    local analyzedNeedsPassivePurchase = type(passiveAnalysis) == "table" and passiveAnalysis.hasPurchase == true
    local analyzedNeedsPassiveOption = type(passiveAnalysis) == "table" and passiveAnalysis.needsPassiveOption == true
    local analyzedNeedsExactPassiveApply = type(passiveAnalysis) == "table"
        and passiveAnalysis.needsExactPassiveApply == true
    local skipPassiveForSpSaver = spSaverPassiveSkipReason ~= nil
    local needsPassiveRespec = skipPassiveForSpSaver ~= true and analyzedNeedsPassiveRespec
    local needsPassivePurchase = skipPassiveForSpSaver ~= true and analyzedNeedsPassivePurchase
    local needsPassiveOption = skipPassiveForSpSaver ~= true and analyzedNeedsPassiveOption
    local needsExactPassiveApply = skipPassiveForSpSaver ~= true and analyzedNeedsExactPassiveApply
    local needsClassMasteryReduction = classMasteryDiff.requiresRespec == true
    local analyzedNeedsRespec = needsSubclassChange
        or analyzedNeedsPurchaseChange
        or analyzedNeedsMorphChange
        or analyzedNeedsTransformChange
        or analyzedNeedsPassiveRespec
        or needsClassMasteryReduction
    local needsRespec = needsSubclassChange
        or needsPurchaseChange
        or needsMorphChange
        or needsTransformChange
        or needsPassiveRespec
        or needsClassMasteryReduction
    local needsEquipmentChange = targetBuild.equipment ~= nil
    local needsRoleChange = partialScope == nil and roleDiff.hasDiff == true
    local needsAttributeChange = attributeDiff.hasDiff == true
    local needsChampionChange = targetBuild.championPoints ~= nil
    local needsSlotRestore = targetBuild.skills ~= nil or targetBuild.actionbar ~= nil
    local targetSkillLineIds = type(SHARED_UTIL) == "table"
        and type(SHARED_UTIL.NormalizeLineIdList) == "function"
        and SHARED_UTIL:NormalizeLineIdList(
            type(targetBuild.subclass) == "table" and targetBuild.subclass.targetSkillLineIds or nil
        )
        or {}
    local analyzedNeedsStandalonePassiveAutoFill = passivePolicy == "class_all_purchase"
        and #targetSkillLineIds > 0
        and analyzedNeedsPassiveRespec ~= true
        and needsSubclassChange ~= true
        and analyzedNeedsPurchaseChange ~= true
        and analyzedNeedsMorphChange ~= true
        and analyzedNeedsTransformChange ~= true
    local needsStandalonePassiveAutoFill = skipPassiveForSpSaver ~= true
        and analyzedNeedsStandalonePassiveAutoFill
    local exactPassivePolicy = passivePolicy == "class_only" or passivePolicy == "all"
    local autoFillPassivePolicy = passivePolicy == "class_all_purchase"
    local analyzedNeedsStandaloneExactPassive = exactPassivePolicy
        and analyzedNeedsExactPassiveApply
        and analyzedNeedsStandalonePassiveAutoFill ~= true
        and analyzedNeedsPassiveRespec ~= true
        and analyzedNeedsRespec ~= true
    local analyzedNeedsStandalonePassiveChanges = analyzedNeedsStandalonePassiveAutoFill
        and analyzedNeedsPassiveOption
    local analyzedNeedsRouteBPassive = analyzedNeedsRespec
        and ((exactPassivePolicy and analyzedNeedsExactPassiveApply)
            or (autoFillPassivePolicy and analyzedNeedsPassiveOption))
    local spSaverAppliesToSkillScope = partialScope == nil or partialScope == "class_skills"
    local hasSkippedSkillChanges = spSaverAppliesToSkillScope
        and skipSkillsForSpSaver
        and (analyzedNeedsPurchaseChange or analyzedNeedsMorphChange or analyzedNeedsTransformChange)
    local hasSkippedPassiveChanges = spSaverAppliesToSkillScope
        and skipPassiveForSpSaver
        and (analyzedNeedsRouteBPassive
            or analyzedNeedsStandalonePassiveChanges
            or analyzedNeedsStandaloneExactPassive)
    if hasSkippedSkillChanges
        and type(LTM_PIPELINE_CONTEXT) == "table"
        and type(LTM_PIPELINE_CONTEXT.RecordSpSaverExpectedSkip) == "function" then
        LTM_PIPELINE_CONTEXT:RecordSpSaverExpectedSkip(context, "normal_skill_changes")
    end
    if hasSkippedSkillChanges then
        skillConfig.spSaverSkipNormalSkillChanges = true
    end
    if hasSkippedPassiveChanges
        and type(LTM_PIPELINE_CONTEXT) == "table"
        and type(LTM_PIPELINE_CONTEXT.RecordSpSaverExpectedSkip) == "function" then
        LTM_PIPELINE_CONTEXT:RecordSpSaverExpectedSkip(context, "normal_passive_changes")
    end
    if hasSkippedPassiveChanges
        and type(LTM_PIPELINE_CONTEXT) == "table"
        and type(LTM_PIPELINE_CONTEXT.RecordSpSaverSkip) == "function" then
        LTM_PIPELINE_CONTEXT:RecordSpSaverSkip(
            context,
            "normal_passive_changes",
            spSaverPassiveSkipReason
        )
    end
    local classMastery = type(targetBuild.classMastery) == "table" and targetBuild.classMastery or nil
    local needsClassMasteryApply = classMasteryDiff.hasDiff == true
    local activityCommitReasons = {}
    if allowSubclass and needsSubclassChange then
        activityCommitReasons[#activityCommitReasons + 1] = "subclass_change"
    end
    if allowClassSkills and needsMorphChange then
        activityCommitReasons[#activityCommitReasons + 1] = "morph_change"
    end
    if allowClassSkills and needsTransformChange then
        activityCommitReasons[#activityCommitReasons + 1] = "transform_change"
    end
    if allowClassSkills and needsPassiveRespec then
        activityCommitReasons[#activityCommitReasons + 1] = "passive_respec"
    end
    if allowClassSkills and needsClassMasteryReduction then
        activityCommitReasons[#activityCommitReasons + 1] = "class_mastery_reduction"
    end
    if allowAttributes and needsAttributeChange then
        activityCommitReasons[#activityCommitReasons + 1] = "attribute_change"
    end
    local requiresActivityRestrictedCommit = #activityCommitReasons > 0

    -- External pipeline routes are intentionally reduced to two responsibilities:
    -- A = restore-only path with no respec work.
    -- B = any path that requires skill respec state, including morph-only changes.
    local route = needsRespec and "B" or "A"
    if needsClassMasteryReduction == true and type(Log.LogDebugSummary) == "function" then
        Log.LogDebugSummary(
            "Planner route B reason",
            "reason=class_mastery_reduction",
            "diffReason=" .. tostring(classMasteryDiff.reason),
            "reductions=" .. tostring(#(classMasteryDiff.reductions or {}))
        )
    end

    -- Internal morph handling is still reused under route B.
    if needsMorphChange and not HasEntries(skillConfig.morphChanges) and #skillDiff.inferredMorphChanges > 0 then
        skillConfig.morphChanges = skillDiff.inferredMorphChanges
    end

    local phases = {}
    local skipSkillsForInsufficientPoints = skillPhaseMode == "skip_due_to_insufficient_points"
    local needsSpSaverRouteBPreparation = skipSkillsForSpSaver and route == "B"

    if allowEquipment and needsEquipmentChange then
        phases[#phases + 1] = "equipment_apply"
    end
    if needsRoleChange then
        phases[#phases + 1] = "role_apply"
    end
    if allowSubclass and (needsSubclassChange or needsSpSaverRouteBPreparation) then
        phases[#phases + 1] = "subclass_apply"
    end
    if allowClassSkills
        and (targetBuild.skills ~= nil
            or needsRespec == true
            or skipSkillsForInsufficientPoints == true
            or skipSkillsForSpSaver == true) then
        phases[#phases + 1] = "skill_apply"
    end
    if allowClassSkills and needsStandalonePassiveAutoFill and skipSkillsForInsufficientPoints ~= true then
        phases[#phases + 1] = "skill_passive_apply"
    end
    if allowClassSkills
        and needsExactPassiveApply
        and needsStandalonePassiveAutoFill ~= true
        and needsPassiveRespec ~= true
        and needsRespec ~= true
        and skipSkillsForInsufficientPoints ~= true then
        phases[#phases + 1] = "skill_passive_apply"
    end
    if allowClassSkills
        and needsClassMasteryApply
        and needsClassMasteryReduction ~= true then
        phases[#phases + 1] = "class_mastery_apply"
    end
    if allowAttributes and needsAttributeChange then
        phases[#phases + 1] = "attribute_apply"
    end
    if allowChampion and needsChampionChange then
        phases[#phases + 1] = "champion_apply"
    end
    phases[#phases + 1] = "finalize"

    if preflightMode == "subclass_only"
        or skillPhaseMode == "skip_due_to_insufficient_points"
        or skipSkillsForSpSaver then
        skillConfig.mode = "skip_due_to_insufficient_points"
        skillConfig.reason = spSaverSkillSkipReason
            or skillPhaseReason
            or "insufficient_points_preflight"
        if type(Log.LogDebugSummary) == "function" then
            Log.LogDebugSummary(
                "Planner skill phase mode=skip_due_to_insufficient_points",
                "preflightMode=" .. tostring(preflightMode),
                "reason=" .. tostring(skillConfig.reason)
            )
        end
    end

    return {
        ok = true,
        route = route,
        needsRespec = needsRespec,
        needsEquipmentChange = needsEquipmentChange,
        needsRoleChange = needsRoleChange,
        needsSubclassChange = needsSubclassChange,
        needsPurchaseChange = needsPurchaseChange,
        needsMorphChange = needsMorphChange,
        needsTransformChange = needsTransformChange,
        needsStandalonePassiveAutoFill = needsStandalonePassiveAutoFill,
        needsClassMasteryApply = needsClassMasteryApply,
        needsClassMasteryReduction = needsClassMasteryReduction,
        needsAttributeChange = needsAttributeChange,
        needsChampionChange = needsChampionChange,
        needsSlotRestore = needsSlotRestore,
        requiresActivityRestrictedCommit = requiresActivityRestrictedCommit,
        activityCommitReasons = activityCommitReasons,
        phases = phases,
        configs = {
            equipment = {
                equipment = targetBuild.equipment,
                outfit = targetBuild.outfit,
            },
            role = type(roleDiff.target) == "table" and roleDiff.target or nil,
            subclass = targetBuild.subclass,
            skills = skillConfig,
            skillPassive = {
                mode = needsStandalonePassiveAutoFill and "standalone_auto_fill"
                    or (needsExactPassiveApply and "exact_restore" or "disabled"),
                passivePolicy = passivePolicy,
                targetSkillLineIds = targetSkillLineIds,
                analysis = passiveAnalysis,
                needsExactPassiveApply = needsExactPassiveApply == true,
                requiresRespecForPassive = needsPassiveRespec == true,
            },
            classMastery = needsClassMasteryApply and classMastery or nil,
            skillRespec = {
                route = route,
                -- Diagnostic metadata only. The actual Route B execution order
                -- is defined by skill_respec_apply.lua, not by this array.
                phasePlan = {
                    "subclass_pending",
                    "transform_reduction",
                    "class_mastery_reduce",
                    "class_mastery_purchase",
                    "purchase",
                    "morph",
                    "passive",
                    "commit",
                    "verify",
                    "completion",
                    "restore_handoff",
                },
                classMasteryReduction = classMasteryDiff,
                transformPlan = transformPlan,
                routeAVariant = "restore_only",
                contractVersion = 1,
            },
            attributes = targetBuild.attributes,
            championPoints = championPointsConfig ~= nil and {
                championPoints = championPointsConfig,
                options = championOptions or {},
            } or nil,
        },
        diagnostics = {
            subclassDiff = subclassDiff,
            skillDiff = skillDiff,
            analyzedNeedsPurchaseChange = analyzedNeedsPurchaseChange == true,
            analyzedNeedsMorphChange = analyzedNeedsMorphChange == true,
            analyzedNeedsTransformChange = analyzedNeedsTransformChange == true,
            analyzedTransformInvalid = analyzedTransformInvalid == true,
            transformPlan = transformPlan,
            analyzedTransformPlan = analyzedTransformPlan,
            attributeDiff = attributeDiff,
            roleDiff = roleDiff,
            inferredSubclassRequirement = inferredSubclassRequirement == true,
            passivePolicy = passivePolicy,
            passiveAnalysis = passiveAnalysis,
            spSaverPassiveSkipReason = spSaverPassiveSkipReason,
            hasSkippedSkillChanges = hasSkippedSkillChanges == true,
            hasSkippedPassiveChanges = hasSkippedPassiveChanges == true,
            analyzedNeedsPassiveRespec = analyzedNeedsPassiveRespec == true,
            analyzedNeedsPassivePurchase = analyzedNeedsPassivePurchase == true,
            analyzedNeedsExactPassiveApply = analyzedNeedsExactPassiveApply == true,
            analyzedNeedsStandalonePassiveAutoFill = analyzedNeedsStandalonePassiveAutoFill == true,
            analyzedNeedsStandalonePassiveChanges = analyzedNeedsStandalonePassiveChanges == true,
            analyzedNeedsStandaloneExactPassive = analyzedNeedsStandaloneExactPassive == true,
            analyzedNeedsRouteBPassive = analyzedNeedsRouteBPassive == true,
            needsPassiveOption = needsPassiveOption == true,
            needsPassivePurchase = needsPassivePurchase == true,
            needsPassiveRespec = needsPassiveRespec == true,
            needsExactPassiveApply = needsExactPassiveApply == true,
            targetSkillLineIds = targetSkillLineIds,
            needsStandalonePassiveAutoFill = needsStandalonePassiveAutoFill == true,
            needsClassMasteryApply = needsClassMasteryApply == true,
            needsClassMasteryReduction = needsClassMasteryReduction == true,
            classMasteryDiff = classMasteryDiff,
            partialScope = partialScope,
            preflightMode = preflightMode,
            championTargetPresent = needsChampionChange == true,
            routeModel = "A_or_B_external_routes",
            plannerVersion = 2,
        },
    }
end
