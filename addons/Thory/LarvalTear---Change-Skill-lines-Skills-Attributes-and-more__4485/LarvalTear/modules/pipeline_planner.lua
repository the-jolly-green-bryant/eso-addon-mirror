local Addon = LarvalTearMod
local Log = Addon.Common.Log
local LTM_ATTRIBUTE_SNAPSHOT = Addon.Modules.AttributeSnapshot
local LTM_ACTIVE_SKILL_RESTORE = Addon.Modules.ActiveSkillRestore
local LTM_BUILD_STORE = Addon.Modules.BuildStore
local LTM_PIPELINE_PLANNER = Addon.Modules.PipelinePlanner
local LTM_PIPELINE_CONTEXT = Addon.Modules.PipelineContext
local LTM_PASSIVE_SNAPSHOT_APPLY = Addon.Modules.PassiveSnapshotApply
local LTM_ROLE_STATE = Addon.Modules.RoleState
local LTM_SUBCLASS_PLANNER = Addon.Modules.SubclassPlanner
local LTM_TRANSFORM_SKILLS = Addon.Modules.TransformSkills

local SHARED_UTIL = Addon.Common.Util

local function HasEntries(value)
    return type(value) == "table" and next(value) ~= nil
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
    if currentMastery == nil then
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

function LTM_PIPELINE_PLANNER:ResolveSubclassDiff(context, currentState, targetBuild)
    local targetSubclass = targetBuild and targetBuild.subclass or nil
    local subclassState = LTM_PIPELINE_CONTEXT:GetCurrentSubclassState(context)

    if subclassState == nil and type(currentState) == "table" then
        subclassState = currentState.subclass
    end

    local plan = LTM_SUBCLASS_PLANNER:BuildSubclassPlan(context, subclassState, targetSubclass)
    return {
        ok = plan.ok,
        hasDiff = plan.hasDiff == true,
        activate = plan.activate or {},
        deactivate = plan.deactivate or {},
        orderedOperations = plan.orderedOperations or {},
        currentSkillLineIds = plan.currentSkillLineIds or {},
        targetSkillLineIds = plan.targetSkillLineIds or {},
        diagnostics = plan.diagnostics,
        immutable = plan.immutable,
        reason = plan.reason,
    }
end

function LTM_PIPELINE_PLANNER:ResolveAttributeDiff(currentState, targetBuild)
    local currentAttributes = type(currentState) == "table" and currentState.attributes or nil
    local targetAttributes = targetBuild and targetBuild.attributes or nil
    local normalizedTarget = nil
    local normalizeErr = nil

    if targetAttributes ~= nil then
        normalizedTarget, normalizeErr = LTM_ATTRIBUTE_SNAPSHOT:NormalizeTargetAttributeState(targetAttributes)
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

    return LTM_ROLE_STATE:ResolveRoleDiff(currentRole, targetRole)
end

function LTM_PIPELINE_PLANNER:BuildPipelinePlan(context, currentState, targetBuild)
    targetBuild = targetBuild or {}
    local partialScope = LTM_PIPELINE_CONTEXT:GetPartialScope(context)
    local allowSubclass = partialScope == nil or partialScope == "class_skills"
    local allowClassSkills = partialScope == nil or partialScope == "class_skills"
    local allowAttributes = partialScope == nil or partialScope == "attributes"
    local allowEquipment = partialScope == nil or partialScope == "equipment"
    local allowChampion = partialScope == nil or partialScope == "champion_points"
    local preflightMode = LTM_PIPELINE_CONTEXT:GetPreflightMode(context)
    local skillPhaseMode = type(context) == "table"
        and type(context.runOptions) == "table"
        and context.runOptions.skillPhaseMode
        or nil
    local skillPhaseReason = type(context) == "table"
        and type(context.runOptions) == "table"
        and context.runOptions.skillPhaseReason
        or nil
    local skillSettingsSkillSkipReason = LTM_PIPELINE_CONTEXT:GetSkillSettingsSkipReason(
        context,
        "normal_skill_changes"
    )
    local skillSettingsPassiveSkipReason = LTM_PIPELINE_CONTEXT:GetSkillSettingsSkipReason(
        context,
        "normal_passive_changes"
    )
    local skipSkillsForSkillSettings = skillSettingsSkillSkipReason ~= nil
    local skipTransformForSkillPhase = skipSkillsForSkillSettings
        or skillPhaseMode == "skip_due_to_insufficient_points"
        or preflightMode == "subclass_only"
    local skillConfig = CloneConfig(targetBuild.skills or {})
    local activeTargetStates = type(context) == "table" and context.skillPointActiveTargetStates or nil
    local suppliedTransformPlan = type(context) == "table"
        and type(context.runOptions) == "table"
        and context.runOptions.transformPlan
        or nil
    local analyzedTransformPlan = suppliedTransformPlan
    if type(analyzedTransformPlan) ~= "table" then
        analyzedTransformPlan = LTM_TRANSFORM_SKILLS:BuildPlan(
            targetBuild.transforms,
            skillConfig,
            activeTargetStates
        )
    end
    if targetBuild.transforms ~= nil and type(suppliedTransformPlan) ~= "table" then
        LTM_TRANSFORM_SKILLS:LogPlan(analyzedTransformPlan)
    end
    local transformPlan = analyzedTransformPlan
    if not skipTransformForSkillPhase then
        LTM_TRANSFORM_SKILLS:RecordPlanResiduals(context, analyzedTransformPlan)
    end
    local skillSettings = LTM_PIPELINE_CONTEXT:GetSkillSettings(context)
    local passiveRestore = skillSettings.passiveRestore
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
    local suppliedActiveRestorePlan = type(context) == "table"
        and type(context.runOptions) == "table"
        and context.runOptions.activeRestorePlan
        or nil
    local analyzedActiveRestorePlan = suppliedActiveRestorePlan
    if type(analyzedActiveRestorePlan) ~= "table" then
        analyzedActiveRestorePlan = LTM_ACTIVE_SKILL_RESTORE:BuildPlan({
            mode = skillSettings.activeRestore,
            activeSnapshot = targetBuild.activeSnapshot,
            skillConfig = skillConfig,
            activeTargetStates = activeTargetStates,
            auditSnapshot = type(context) == "table" and context.skillPointSnapshot or nil,
            subclassDiff = subclassDiff,
            transformPlan = analyzedTransformPlan,
            transformOwnerSkillLineIds = type(context) == "table"
                and context.skillPointTransformOwnerSkillLineIds
                or nil,
            cryptCanonActive = type(context) == "table" and context.skillPointCryptCanonActive or nil,
        })
    end
    local activeRestorePlan = LTM_ACTIVE_SKILL_RESTORE:ApplyShortageDecision(
        analyzedActiveRestorePlan,
        skipTransformForSkillPhase and { activeAction = "skip_all" } or skillSettings
    )
    local analyzedSkillDiff = analyzedActiveRestorePlan.slotPlan
    local skillDiff = activeRestorePlan.slotPlan
    local attributeDiff = self:ResolveAttributeDiff(currentState, targetBuild)
    local roleDiff = self:ResolveRoleDiff(currentState, targetBuild)
    local classMasteryDiff = self:ResolveClassMasteryDiff(currentState, targetBuild)
    local needsSubclassChange = subclassDiff.hasDiff == true
    local inferredSubclassRequirement = type(targetBuild.subclass) == "table"
        and analyzedSkillDiff.requiresSubclassActivation == true
    if not needsSubclassChange and inferredSubclassRequirement then
        needsSubclassChange = true
    end
    local analyzedNeedsPurchaseChange = analyzedSkillDiff.hasPurchaseDiff == true
    local analyzedNeedsMorphChange = analyzedSkillDiff.hasMorphDiff == true
    local analyzedTransformInvalid = analyzedTransformPlan.ok ~= true
    local analyzedNeedsTransformChange = LTM_ACTIVE_SKILL_RESTORE:HasOperationsFromSources(
        analyzedActiveRestorePlan,
        { transform = true }
    ) or analyzedTransformInvalid
    local analyzedNeedsActiveRestore = analyzedActiveRestorePlan.mode == "clear_unused"
        or LTM_ACTIVE_SKILL_RESTORE:HasOperationsFromSources(
            analyzedActiveRestorePlan,
            { active_exact = true, clear_unused = true }
        )
    local needsActiveRestore = (activeRestorePlan.mode == "clear_unused"
        and activeRestorePlan.neutralized ~= true)
        or LTM_ACTIVE_SKILL_RESTORE:HasOperationsFromSources(
            activeRestorePlan,
            { active_exact = true, clear_unused = true }
        )
    local needsPurchaseChange = skillDiff.hasPurchaseDiff == true
    local needsMorphChange = skillDiff.hasMorphDiff == true
    local needsTransformChange = (activeRestorePlan.neutralized ~= true and analyzedTransformInvalid)
        or LTM_ACTIVE_SKILL_RESTORE:HasOperationsFromSources(
            activeRestorePlan,
            { transform = true }
        )
    local passiveAnalysis = LTM_PASSIVE_SNAPSHOT_APPLY:AnalyzeBuild(targetBuild, {
        source = "pipeline_planner",
        passiveRestore = passiveRestore,
    })
    local analyzedNeedsPassiveRespec = type(passiveAnalysis) == "table"
        and passiveAnalysis.requiresRespecForPassive == true
    local analyzedNeedsPassivePurchase = type(passiveAnalysis) == "table" and passiveAnalysis.hasPurchase == true
    local analyzedNeedsPassiveOption = type(passiveAnalysis) == "table" and passiveAnalysis.needsPassiveOption == true
    local analyzedNeedsExactPassiveApply = type(passiveAnalysis) == "table"
        and passiveAnalysis.needsExactPassiveApply == true
    local skipPassiveForSkillSettings = skillSettingsPassiveSkipReason ~= nil
    local needsPassiveRespec = skipPassiveForSkillSettings ~= true and analyzedNeedsPassiveRespec
    local needsPassivePurchase = skipPassiveForSkillSettings ~= true and analyzedNeedsPassivePurchase
    local needsPassiveOption = skipPassiveForSkillSettings ~= true and analyzedNeedsPassiveOption
    local needsExactPassiveApply = skipPassiveForSkillSettings ~= true and analyzedNeedsExactPassiveApply
    local needsClassMasteryReduction = classMasteryDiff.requiresRespec == true
    local analyzedNeedsRespec = needsSubclassChange
        or analyzedNeedsPurchaseChange
        or analyzedNeedsMorphChange
        or analyzedNeedsTransformChange
        or analyzedActiveRestorePlan.requiresRouteB == true
        or analyzedNeedsPassiveRespec
        or needsClassMasteryReduction
    local needsRespec = needsSubclassChange
        or needsPurchaseChange
        or needsMorphChange
        or needsTransformChange
        or activeRestorePlan.requiresRouteB == true
        or needsPassiveRespec
        or needsClassMasteryReduction
    local needsEquipmentChange = targetBuild.equipment ~= nil
    local needsRoleChange = partialScope == nil and roleDiff.hasDiff == true
    local needsAttributeChange = attributeDiff.hasDiff == true
    local needsChampionChange = targetBuild.championPoints ~= nil
    local needsSlotRestore = targetBuild.skills ~= nil
    local targetSkillLineIds = SHARED_UTIL:NormalizeLineIdList(
        type(targetBuild.subclass) == "table" and targetBuild.subclass.targetSkillLineIds or nil
    )
    local analyzedNeedsStandalonePassiveAutoFill = passiveRestore == "class_purchase_all"
        and #targetSkillLineIds > 0
        and analyzedNeedsPassiveRespec ~= true
        and needsSubclassChange ~= true
        and analyzedNeedsPurchaseChange ~= true
        and analyzedNeedsMorphChange ~= true
        and analyzedNeedsTransformChange ~= true
        and analyzedNeedsActiveRestore ~= true
    local needsStandalonePassiveAutoFill = skipPassiveForSkillSettings ~= true
        and analyzedNeedsStandalonePassiveAutoFill
    local exactPassiveRestore = passiveRestore == "class_exact" or passiveRestore == "all_exact"
    local autoFillPassiveRestore = passiveRestore == "class_purchase_all"
    local analyzedNeedsStandaloneExactPassive = exactPassiveRestore
        and analyzedNeedsExactPassiveApply
        and analyzedNeedsStandalonePassiveAutoFill ~= true
        and analyzedNeedsPassiveRespec ~= true
        and analyzedNeedsRespec ~= true
    local analyzedNeedsStandalonePassiveChanges = analyzedNeedsStandalonePassiveAutoFill
        and analyzedNeedsPassiveOption
    local analyzedNeedsRouteBPassive = analyzedNeedsRespec
        and ((exactPassiveRestore and analyzedNeedsExactPassiveApply)
            or (autoFillPassiveRestore and analyzedNeedsPassiveOption))
    local skillSettingsAppliesToSkillScope = partialScope == nil or partialScope == "class_skills"
    local hasSkippedSkillChanges = skillSettingsAppliesToSkillScope
        and skipSkillsForSkillSettings
        and (analyzedNeedsPurchaseChange
            or analyzedNeedsMorphChange
            or analyzedNeedsTransformChange
            or analyzedActiveRestorePlan.hasDiff == true)
    local hasSkippedPassiveChanges = skillSettingsAppliesToSkillScope
        and skipPassiveForSkillSettings
        and (analyzedNeedsRouteBPassive
            or analyzedNeedsStandalonePassiveChanges
            or analyzedNeedsStandaloneExactPassive)
    local hasUnscheduledStandalonePassiveSkip = skillSettingsAppliesToSkillScope
        and skipPassiveForSkillSettings
        and (analyzedNeedsStandalonePassiveChanges or analyzedNeedsStandaloneExactPassive)
    if hasSkippedSkillChanges then
        LTM_PIPELINE_CONTEXT:RecordSkillSettingsExpectedSkip(context, "normal_skill_changes")
    end
    if hasSkippedSkillChanges then
        skillConfig.skillSettingsSkipNormalSkillChanges = true
    end
    if hasSkippedPassiveChanges then
        LTM_PIPELINE_CONTEXT:RecordSkillSettingsExpectedSkip(context, "normal_passive_changes")
    end
    if hasUnscheduledStandalonePassiveSkip then
        LTM_PIPELINE_CONTEXT:RecordSkillSettingsSkip(
            context,
            "normal_passive_changes",
            skillSettingsPassiveSkipReason
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
    if allowClassSkills and needsActiveRestore then
        activityCommitReasons[#activityCommitReasons + 1] = "active_restore"
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
    if needsClassMasteryReduction == true then
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
    local needsSkillSettingsRouteBPreparation = skipSkillsForSkillSettings and route == "B"

    if allowEquipment and needsEquipmentChange then
        phases[#phases + 1] = "equipment_apply"
    end
    if needsRoleChange then
        phases[#phases + 1] = "role_apply"
    end
    if allowSubclass and (needsSubclassChange or needsSkillSettingsRouteBPreparation) then
        phases[#phases + 1] = "subclass_apply"
    end
    if allowClassSkills
        and (targetBuild.skills ~= nil
            or needsRespec == true
            or skipSkillsForInsufficientPoints == true
            or skipSkillsForSkillSettings == true) then
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
        or skipSkillsForSkillSettings then
        skillConfig.mode = "skip_due_to_insufficient_points"
        skillConfig.reason = skillSettingsSkillSkipReason
            or skillPhaseReason
            or "insufficient_points_preflight"
        Log.LogDebugSummary(
            "Planner skill phase mode=skip_due_to_insufficient_points",
            "preflightMode=" .. tostring(preflightMode),
            "reason=" .. tostring(skillConfig.reason)
        )
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
                passiveRestore = passiveRestore,
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
                    "active_reduction",
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
                activeRestorePlan = activeRestorePlan,
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
            analyzedNeedsActiveRestore = analyzedNeedsActiveRestore == true,
            analyzedTransformInvalid = analyzedTransformInvalid == true,
            transformPlan = transformPlan,
            analyzedTransformPlan = analyzedTransformPlan,
            activeRestorePlan = activeRestorePlan,
            analyzedActiveRestorePlan = analyzedActiveRestorePlan,
            attributeDiff = attributeDiff,
            roleDiff = roleDiff,
            inferredSubclassRequirement = inferredSubclassRequirement == true,
            passiveRestore = passiveRestore,
            passiveAnalysis = passiveAnalysis,
            skillSettingsPassiveSkipReason = skillSettingsPassiveSkipReason,
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
            plannerVersion = 3,
        },
    }
end
