-- Authoritative Normal Skill Point precheck calculation. This module never
-- creates or runs mutations.
local Addon = LarvalTearMod
local SkillPointEvaluator = Addon.Modules.SkillPointEvaluator

local POLICY_NONE = "none"
local POLICY_CLASS_ALL_PURCHASE = "class_all_purchase"
local POLICY_CLASS_ONLY = "class_only"
local POLICY_ALL = "all"
local BASE_MORPH_SLOT = type(MORPH_SLOT_BASE) == "number" and MORPH_SLOT_BASE or 0
local CRAFTED_ABILITY_ACTION_TYPE = type(ACTION_TYPE_CRAFTED_ABILITY) == "number"
    and ACTION_TYPE_CRAFTED_ABILITY
    or 3

local function AppendWarning(warnings, warningSet, warning)
    if type(warning) ~= "string" or warning == "" or warningSet[warning] == true then
        return
    end

    warningSet[warning] = true
    warnings[#warnings + 1] = warning
end

local function NormalizeNonNegativeInteger(value)
    value = tonumber(value)
    if value == nil or value < 0 or math.floor(value) ~= value then
        return nil
    end
    return value
end

local function BuildInvalidPlan(route, policy, availableBefore, warnings)
    route = route or "invalid"
    policy = policy or "invalid"
    availableBefore = availableBefore or 0
    return {
        route = route,
        policy = policy,
        availableBefore = availableBefore,
        subclassRefund = 0,
        activeRefund = 0,
        activeRequired = 0,
        activeFeasible = false,
        availableAfterActive = availableBefore,
        passiveRefund = 0,
        passiveRequested = 0,
        passiveSpendLimit = 0,
        passiveFullyFeasible = false,
        shortage = 0,
        expectedResult = "invalid",
        reasons = warnings,
    }
end

local function IsSupportedPolicy(policy)
    return policy == POLICY_NONE
        or policy == POLICY_CLASS_ALL_PURCHASE
        or policy == POLICY_CLASS_ONLY
        or policy == POLICY_ALL
end

local function BuildSnapshotIndexes(snapshot)
    local lineById = {}
    local skillByKey = {}

    for _, lineEntry in ipairs(type(snapshot) == "table" and snapshot.lines or {}) do
        local skillLineId = NormalizeNonNegativeInteger(lineEntry.skillLineId)
        if skillLineId ~= nil and skillLineId > 0 then
            lineById[skillLineId] = lineEntry
            for _, skillEntry in ipairs(type(lineEntry.skills) == "table" and lineEntry.skills or {}) do
                local skillIndex = NormalizeNonNegativeInteger(skillEntry.skillIndex)
                if skillIndex ~= nil and skillIndex > 0 then
                    skillByKey[tostring(skillLineId) .. ":" .. tostring(skillIndex)] = skillEntry
                end
            end
        end
    end

    return lineById, skillByKey
end

local function BuildClassMasteryLineSet(build, lineById)
    local lineSet = {}
    local classMastery = type(build) == "table" and build.classMastery or nil
    local targetSkillLineId = NormalizeNonNegativeInteger(
        type(classMastery) == "table" and classMastery.targetSkillLineId or nil
    )
    if targetSkillLineId ~= nil and targetSkillLineId > 0 then
        lineSet[targetSkillLineId] = true
    end

    for skillLineId, lineEntry in pairs(lineById) do
        if type(lineEntry) == "table" and lineEntry.isClassMastery == true then
            lineSet[skillLineId] = true
        end
    end

    return lineSet
end

local function ResolveActiveMultiplier(resolved)
    local isClassSkillLine = type(resolved) == "table"
        and (resolved.isClassSkillLine == true or resolved.isPlayerClassSkillLine == true)
        or false
    if isClassSkillLine then
        return resolved.isPlayerClassSkillLine == true and 1 or 2
    end

    return 1
end

local function IsCraftedTarget(resolved)
    if type(resolved) ~= "table" then
        return false
    end

    return resolved.isCraftedAbility == true
        or (NormalizeNonNegativeInteger(resolved.craftedAbilityId) or 0) > 0
        or (NormalizeNonNegativeInteger(resolved.craftSkillId) or 0) > 0
        or NormalizeNonNegativeInteger(resolved.slotActionType) == CRAFTED_ABILITY_ACTION_TYPE
end

local function EvaluateActiveTargets(route, activeTargetStates, warnings, warningSet)
    local required = 0
    local refund = 0
    local invalid = false
    local seenProgressions = {}

    for _, resolved in ipairs(type(activeTargetStates) == "table" and activeTargetStates or {}) do
        local targetAbilityId = NormalizeNonNegativeInteger(
            type(resolved) == "table" and resolved.targetAbilityId or nil
        )
        if type(resolved) ~= "table" then
            invalid = true
            AppendWarning(warnings, warningSet, "active_target_state_unavailable")
        elseif resolved.excludedByTransformOwner == true then
            -- Transform snapshot owns purchase/morph state for this progression.
        elseif IsCraftedTarget(resolved) then
            -- Crafted/Scribing targets use a separate point lane.
        elseif targetAbilityId == nil then
            invalid = true
            AppendWarning(warnings, warningSet, "active_target_ability_invalid")
        elseif targetAbilityId > 0 then
            local progressionId = NormalizeNonNegativeInteger(resolved.progressionId)
            local progressionKey = progressionId ~= nil and progressionId > 0
                and tostring(progressionId)
                or nil

            if resolved.unresolved == true or resolved.nonSlottable == true then
                invalid = true
                AppendWarning(
                    warnings,
                    warningSet,
                    "active_target_invalid:" .. tostring(resolved.reason or targetAbilityId)
                )
            elseif progressionKey == nil then
                invalid = true
                AppendWarning(warnings, warningSet, "active_progression_unavailable:" .. tostring(targetAbilityId))
            elseif seenProgressions[progressionKey] ~= true then
                seenProgressions[progressionKey] = true
                local multiplier = ResolveActiveMultiplier(resolved)
                if resolved.requiresPurchase == true then
                    required = required + multiplier
                end

                local targetMorphSlot = NormalizeNonNegativeInteger(resolved.targetMorphSlot)
                local currentMorphSlot = NormalizeNonNegativeInteger(resolved.currentMorphSlot)
                local targetIsMorphed = targetMorphSlot ~= nil and targetMorphSlot ~= BASE_MORPH_SLOT
                local currentIsMorphed = currentMorphSlot ~= nil and currentMorphSlot ~= BASE_MORPH_SLOT

                if resolved.requiresPurchase == true and targetIsMorphed then
                    required = required + multiplier
                elseif resolved.requiresMorph == true and targetIsMorphed and not currentIsMorphed then
                    required = required + multiplier
                elseif resolved.requiresMorph == true and targetIsMorphed and currentIsMorphed then
                    if route == "B" then
                        required = required + multiplier
                        refund = refund + multiplier
                    else
                        invalid = true
                        AppendWarning(
                            warnings,
                            warningSet,
                            "active_morph_reduction_route_b_only:" .. tostring(targetAbilityId)
                        )
                    end
                elseif resolved.requiresMorph == true and not targetIsMorphed and currentIsMorphed then
                    if route == "B" then
                        refund = refund + multiplier
                    else
                        invalid = true
                        AppendWarning(
                            warnings,
                            warningSet,
                            "active_morph_reduction_route_b_only:" .. tostring(targetAbilityId)
                        )
                    end
                elseif resolved.ready ~= true
                    and resolved.requiresPurchase ~= true
                    and resolved.requiresMorph ~= true then
                    invalid = true
                    AppendWarning(warnings, warningSet, "active_target_state_inconsistent:" .. tostring(targetAbilityId))
                end
            end
        end
    end

    return required, refund, invalid
end

local function ResolveSubclassRefund(route, plan, lineById, masteryLineSet, warnings, warningSet)
    if route ~= "B" then
        return 0
    end

    local subclassDiff = type(plan) == "table" and type(plan.diagnostics) == "table"
        and plan.diagnostics.subclassDiff
        or nil
    local refund = 0

    for _, rawSkillLineId in ipairs(type(subclassDiff) == "table" and subclassDiff.deactivate or {}) do
        local skillLineId = NormalizeNonNegativeInteger(rawSkillLineId)
        local lineEntry = skillLineId ~= nil and lineById[skillLineId] or nil
        if skillLineId == nil or skillLineId <= 0 then
            AppendWarning(warnings, warningSet, "subclass_refund_line_id_invalid")
        elseif masteryLineSet[skillLineId] == true then
            AppendWarning(warnings, warningSet, "class_mastery_subclass_refund_excluded:" .. tostring(skillLineId))
        elseif type(lineEntry) ~= "table" then
            AppendWarning(warnings, warningSet, "subclass_refund_line_unavailable:" .. tostring(skillLineId))
        else
            local linePoints = NormalizeNonNegativeInteger(lineEntry.linePointsAllocated)
            if linePoints == nil then
                AppendWarning(warnings, warningSet, "subclass_refund_points_invalid:" .. tostring(skillLineId))
            else
                refund = refund + linePoints
            end
        end
    end

    return refund
end


local function ResolveTargetMainClassLineId(plan)
    local subclassDiff = type(plan) == "table" and type(plan.diagnostics) == "table"
        and plan.diagnostics.subclassDiff
        or nil
    local diagnostics = type(subclassDiff) == "table" and subclassDiff.diagnostics or nil
    return NormalizeNonNegativeInteger(
        type(diagnostics) == "table" and diagnostics.targetMainClassLineId or nil
    )
end

local function BuildActivatedLineSet(plan)
    local activatedLineSet = {}
    local subclassDiff = type(plan) == "table" and type(plan.diagnostics) == "table"
        and plan.diagnostics.subclassDiff
        or nil
    for _, rawSkillLineId in ipairs(type(subclassDiff) == "table" and subclassDiff.activate or {}) do
        local skillLineId = NormalizeNonNegativeInteger(rawSkillLineId)
        if skillLineId ~= nil and skillLineId > 0 then
            activatedLineSet[skillLineId] = true
        end
    end
    return activatedLineSet
end

local function ResolvePassiveMultiplier(entry, lineById, skillByKey, targetMainClassLineId)
    local multiplier = NormalizeNonNegativeInteger(type(entry) == "table" and entry.costMultiplier or nil)
    if multiplier ~= nil and multiplier > 0 then
        return multiplier
    end

    local skillLineId = NormalizeNonNegativeInteger(type(entry) == "table" and entry.skillLineId or nil)
    local skillIndex = NormalizeNonNegativeInteger(type(entry) == "table" and entry.skillIndex or nil)
    local key = skillLineId ~= nil and skillIndex ~= nil
        and tostring(skillLineId) .. ":" .. tostring(skillIndex)
        or nil
    local skillEntry = key ~= nil and skillByKey[key] or nil
    multiplier = NormalizeNonNegativeInteger(type(skillEntry) == "table" and skillEntry.costMultiplier or nil)
    if multiplier ~= nil and multiplier > 0 then
        return multiplier
    end

    local lineEntry = skillLineId ~= nil and lineById[skillLineId] or nil
    if type(lineEntry) == "table" and lineEntry.isClassSkillLine == true then
        return lineEntry.isPlayerClassSkillLine == true and 1 or 2
    end
    if type(entry) == "table" and entry.isClassSkillLine == true then
        return entry.isPlayerClassSkillLine == true and 1 or 2
    end
    if type(entry) == "table" and entry.targetClassLine == true then
        return skillLineId == targetMainClassLineId and 1 or 2
    end

    return 1
end

local function EvaluatePassive(policy, route, passiveAnalysis, lineById, skillByKey, masteryLineSet, plan, warnings, warningSet)
    if policy == POLICY_NONE then
        return 0, 0, false, false
    end

    if type(passiveAnalysis) ~= "table" or passiveAnalysis.ok ~= true then
        AppendWarning(
            warnings,
            warningSet,
            "passive_analysis_invalid:" .. tostring(
                type(passiveAnalysis) == "table" and passiveAnalysis.blockReason or "unavailable"
            )
        )
        return 0, 0, true, false
    end

    local requested = 0
    local refund = 0
    local invalid = false
    local unreachable = false
    local targetMainClassLineId = ResolveTargetMainClassLineId(plan)
    local activatedLineSet = BuildActivatedLineSet(plan)

    local function AppendRequestedCost(entry)
        local skillLineId = NormalizeNonNegativeInteger(type(entry) == "table" and entry.skillLineId or nil)
        local missingRank = NormalizeNonNegativeInteger(type(entry) == "table" and entry.missingRank or nil)
        if missingRank == nil and type(entry) == "table" and entry.classification == "defer" then
            local savedRank = NormalizeNonNegativeInteger(entry.savedRank)
            local minimumRank = NormalizeNonNegativeInteger(entry.minimumRank) or 0
            missingRank = savedRank ~= nil and math.max(0, savedRank - minimumRank) or nil
        end

        if skillLineId == nil or missingRank == nil then
            invalid = true
            AppendWarning(warnings, warningSet, "passive_purchase_cost_unavailable")
            return
        end

        requested = requested + (missingRank * ResolvePassiveMultiplier(
            entry,
            lineById,
            skillByKey,
            targetMainClassLineId
        ))
    end

    for _, entry in ipairs(type(passiveAnalysis.targetEntries) == "table" and passiveAnalysis.targetEntries or {}) do
        local skillLineId = NormalizeNonNegativeInteger(type(entry) == "table" and entry.skillLineId or nil)
        local classification = type(entry) == "table" and entry.classification or nil

        if (type(entry) == "table" and entry.isClassMastery == true)
            or (skillLineId ~= nil and masteryLineSet[skillLineId] == true) then
            AppendWarning(warnings, warningSet, "class_mastery_passive_excluded:" .. tostring(skillLineId))
        elseif classification == "purchase" then
            AppendRequestedCost(entry)
        elseif classification == "defer" then
            if route == "B" and skillLineId ~= nil and activatedLineSet[skillLineId] == true then
                AppendRequestedCost(entry)
            else
                invalid = true
                AppendWarning(warnings, warningSet, "passive_deferred_target_not_activated:" .. tostring(skillLineId))
            end
        elseif classification == "reduction" then
            local excessRank = NormalizeNonNegativeInteger(entry.excessRank)
            if skillLineId == nil or excessRank == nil then
                invalid = true
                AppendWarning(warnings, warningSet, "passive_refund_unavailable")
            elseif route == "B" then
                refund = refund + (excessRank * ResolvePassiveMultiplier(
                    entry,
                    lineById,
                    skillByKey,
                    targetMainClassLineId
                ))
            else
                unreachable = true
                AppendWarning(warnings, warningSet, "passive_reduction_refund_route_b_only")
            end
        elseif classification == "unavailable"
            and type(entry) == "table"
            and entry.reason == "target_class_line_inactive"
            and type(entry.shadowDeferredTargets) == "table"
            and entry.shadowDeferredTargetsResolved == true
            and route == "B"
            and skillLineId ~= nil
            and activatedLineSet[skillLineId] == true then
            for _, deferredTarget in ipairs(entry.shadowDeferredTargets) do
                if type(deferredTarget) == "table" and deferredTarget.isClassMastery ~= true then
                    AppendRequestedCost(deferredTarget)
                end
            end
        elseif classification == "invalid" or classification == "unresolved" or classification == "unavailable" then
            invalid = true
            AppendWarning(
                warnings,
                warningSet,
                "passive_target_invalid:" .. tostring(type(entry) == "table" and entry.reason or classification)
            )
        end
    end

    return refund, requested, invalid, unreachable
end

function SkillPointEvaluator:BuildPlan(build, options)
    options = type(options) == "table" and options or {}
    local plan = options.plan
    local snapshot = options.snapshot
    local passiveAnalysis = options.passiveAnalysis
    local route = type(plan) == "table" and plan.route or nil
    local policy = type(passiveAnalysis) == "table" and passiveAnalysis.policy or options.policy
    local availableBefore = NormalizeNonNegativeInteger(
        type(snapshot) == "table" and snapshot.availablePoints or nil
    )
    local warnings = {}
    local warningSet = {}

    if type(build) ~= "table" then
        AppendWarning(warnings, warningSet, "build_missing")
    end
    if route ~= "A" and route ~= "B" then
        AppendWarning(warnings, warningSet, "route_invalid:" .. tostring(route))
    end
    if not IsSupportedPolicy(policy) then
        AppendWarning(warnings, warningSet, "passive_policy_invalid:" .. tostring(policy))
    end
    if availableBefore == nil then
        AppendWarning(warnings, warningSet, "available_points_invalid")
    end
    if type(options.activeTargetStates) ~= "table" then
        AppendWarning(warnings, warningSet, "active_target_states_invalid")
    end
    if #warnings > 0 then
        return BuildInvalidPlan(route, policy, availableBefore, warnings)
    end

    local lineById, skillByKey = BuildSnapshotIndexes(snapshot)
    local masteryLineSet = BuildClassMasteryLineSet(build, lineById)
    local subclassRefund = ResolveSubclassRefund(
        route,
        plan,
        lineById,
        masteryLineSet,
        warnings,
        warningSet
    )
    local transformPlan = type(plan) == "table"
        and type(plan.configs) == "table"
        and type(plan.configs.skillRespec) == "table"
        and plan.configs.skillRespec.transformPlan
        or nil
    local activeTargetStates = options.activeTargetStates
    if type(transformPlan) == "table"
        and (transformPlan.skippedBySpSaver == true or transformPlan.skippedBySkillPhase == true) then
        activeTargetStates = {}
        for _, targetState in ipairs(options.activeTargetStates) do
            if type(targetState) ~= "table" or targetState.transformKind == nil then
                activeTargetStates[#activeTargetStates + 1] = targetState
            end
        end
    end
    local activeRequired, activeRefund, activeInvalid = EvaluateActiveTargets(
        route,
        activeTargetStates,
        warnings,
        warningSet
    )
    if type(transformPlan) == "table" then
        activeRefund = activeRefund + (NormalizeNonNegativeInteger(transformPlan.activeRefund) or 0)
        if transformPlan.ok ~= true then
            activeInvalid = true
            AppendWarning(
                warnings,
                warningSet,
                "transform_target_invalid:" .. tostring(transformPlan.blockReason or "unknown")
            )
        end
    end
    local passiveRefund, passiveRequested, passiveInvalid, passiveUnreachable = EvaluatePassive(
        policy,
        route,
        passiveAnalysis,
        lineById,
        skillByKey,
        masteryLineSet,
        plan,
        warnings,
        warningSet
    )
    local availableForActive = availableBefore + subclassRefund + activeRefund
    local availableAfterActive = availableForActive - activeRequired
    local activeFeasible = availableAfterActive >= 0
    local passiveAvailable = activeFeasible and math.max(0, availableAfterActive + passiveRefund) or 0
    local passiveSpendLimit = math.min(passiveRequested, passiveAvailable)
    local passiveFullyFeasible = activeFeasible
        and passiveSpendLimit >= passiveRequested
        and passiveUnreachable ~= true
    local expectedResult = "full_success"
    local shortage = 0

    if activeInvalid or passiveInvalid then
        expectedResult = "invalid"
        activeFeasible = false
        passiveFullyFeasible = false
        passiveSpendLimit = 0
    elseif not activeFeasible then
        expectedResult = "skill_phase_skip"
        passiveFullyFeasible = false
        passiveSpendLimit = 0
        shortage = math.max(0, activeRequired - availableForActive)
    elseif not passiveFullyFeasible then
        expectedResult = "passive_partial"
        shortage = math.max(0, passiveRequested - passiveSpendLimit)
    end

    return {
        route = route,
        policy = policy,
        availableBefore = availableBefore,
        subclassRefund = subclassRefund,
        activeRefund = activeRefund,
        activeRequired = activeRequired,
        activeFeasible = activeFeasible,
        availableAfterActive = availableAfterActive,
        passiveRefund = passiveRefund,
        passiveRequested = passiveRequested,
        passiveSpendLimit = passiveSpendLimit,
        passiveFullyFeasible = passiveFullyFeasible,
        shortage = shortage,
        expectedResult = expectedResult,
        reasons = warnings,
    }
end
