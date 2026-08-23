local Addon = LarvalTearMod
local LTM_APPLY_PRECHECK_DECISION = Addon.Modules.ApplyPrecheckDecision
local LTM_APPLY_PRECHECK_GATE = Addon.Modules.ApplyPrecheckGate
local LTM_SKILL_POINT_INPUT_PROVIDER = Addon.Modules.SkillPointInputProvider
local LTM_SKILL_POINT_EVALUATOR = Addon.Modules.SkillPointEvaluator
local SkillSettings = Addon.Common.SkillSettings

local M = LTM_APPLY_PRECHECK_DECISION

local function CloneRequest(request)
    if type(request) ~= "table" then
        return {}
    end

    local cloned = {}
    for key, value in pairs(request) do
        cloned[key] = value
    end
    return cloned
end

local function BuildRoute(request)
    return {
        partialScope = request.partialScope,
        preflightMode = request.preflightMode,
    }
end

local function BuildInputs(build, request, planOptions)
    local ok, inputs = pcall(LTM_SKILL_POINT_INPUT_PROVIDER.Build, LTM_SKILL_POINT_INPUT_PROVIDER, build, {
        source = "apply_precheck_decision",
        partialScope = request.partialScope,
        preflightMode = type(planOptions) == "table" and planOptions.preflightMode or request.preflightMode,
        skillPhaseMode = type(planOptions) == "table" and planOptions.skillPhaseMode or nil,
        skillPhaseReason = type(planOptions) == "table" and planOptions.skillPhaseReason or nil,
        skillSettings = type(planOptions) == "table" and planOptions.skillSettings or nil,
        activeRestorePlan = type(planOptions) == "table" and planOptions.activeRestorePlan or nil,
        transformPlan = type(planOptions) == "table" and planOptions.transformPlan or nil,
        forceChampionRespec = request.forceChampionRespec == true,
    })
    if not ok then
        return nil, tostring(inputs)
    end
    return inputs, nil
end

local function BuildPlanFromCapturedInputs(build, request, inputs, planOptions)
    local ok, plan, err = pcall(
        LTM_SKILL_POINT_INPUT_PROVIDER.BuildPlanFromCapturedInputs,
        LTM_SKILL_POINT_INPUT_PROVIDER,
        inputs,
        build,
        {
            source = "apply_precheck_decision_resolved",
            partialScope = request.partialScope,
            preflightMode = type(planOptions) == "table" and planOptions.preflightMode or request.preflightMode,
            skillPhaseMode = type(planOptions) == "table" and planOptions.skillPhaseMode or nil,
            skillPhaseReason = type(planOptions) == "table" and planOptions.skillPhaseReason or nil,
            skillSettings = type(planOptions) == "table" and planOptions.skillSettings or nil,
            activeRestorePlan = type(planOptions) == "table" and planOptions.activeRestorePlan or nil,
            transformPlan = type(planOptions) == "table" and planOptions.transformPlan or nil,
            forceChampionRespec = request.forceChampionRespec == true,
        }
    )
    if not ok then
        return nil, tostring(plan)
    end
    return plan, err
end

local function BuildSkillPointPlan(build, inputs)
    local ok, skillPointPlan = pcall(
        LTM_SKILL_POINT_EVALUATOR.BuildPlan,
        LTM_SKILL_POINT_EVALUATOR,
        build,
        {
            plan = inputs.plan,
            snapshot = inputs.snapshot,
            passiveAnalysis = inputs.passiveAnalysis,
        }
    )
    if not ok then
        return nil, tostring(skillPointPlan)
    end
    return skillPointPlan, nil
end

function M:Evaluate(request, build, options)
    local normalizedRequest = CloneRequest(request)
    local result = {
        action = "run_now",
        route = BuildRoute(normalizedRequest),
        diagnostics = {
            source = normalizedRequest.source,
        },
    }
    local interactive = type(options) == "table" and options.interactive == true or false
    local acceptedPrecheck = type(options) == "table" and options.acceptedPrecheck or nil

    if type(build) ~= "table" then
        result.action = "skip"
        result.error = "build_not_found"
        return result
    end

    local acceptedRoute = type(acceptedPrecheck) == "table" and acceptedPrecheck.route or nil
    local acceptedDiagnostics = type(acceptedPrecheck) == "table" and acceptedPrecheck.diagnostics or nil
    local acceptedSkillPointPlan = type(acceptedDiagnostics) == "table"
        and acceptedDiagnostics.skillPointPlan
        or nil
    local acceptedPipelinePlan = type(acceptedDiagnostics) == "table"
        and acceptedDiagnostics.pipelinePlan
        or nil
    local acceptedActiveRestorePlan = type(acceptedPipelinePlan) == "table"
        and type(acceptedPipelinePlan.diagnostics) == "table"
        and acceptedPipelinePlan.diagnostics.analyzedActiveRestorePlan
        or nil
    local acceptedTransformPlan = type(acceptedPipelinePlan) == "table"
        and type(acceptedPipelinePlan.diagnostics) == "table"
        and acceptedPipelinePlan.diagnostics.analyzedTransformPlan
        or nil
    local acceptedSkillSettings = type(acceptedPrecheck) == "table" and acceptedPrecheck.skillSettings or nil
    local effectiveSkillSettings = type(acceptedSkillSettings) == "table"
        and acceptedSkillSettings
        or Addon:ResolveEffectiveSkillSettings(build)
    local planOptions = {
        preflightMode = type(acceptedRoute) == "table" and acceptedRoute.preflightMode or normalizedRequest.preflightMode,
        skillPhaseMode = type(acceptedRoute) == "table" and acceptedRoute.skillPhaseMode or nil,
        skillPhaseReason = type(acceptedRoute) == "table" and acceptedRoute.skillPhaseReason or nil,
        skillSettings = effectiveSkillSettings,
        activeRestorePlan = acceptedActiveRestorePlan,
        transformPlan = acceptedTransformPlan,
    }
    if planOptions.skillPhaseMode == "skip_due_to_insufficient_points" then
        planOptions.preflightMode = "subclass_only"
    end

    local inputs, inputsErr = BuildInputs(build, normalizedRequest, planOptions)
    result.diagnostics.skillPointInputs = inputs
    result.diagnostics.skillPointInputsError = inputsErr
    result.diagnostics.passiveAnalysis = type(inputs) == "table" and inputs.passiveAnalysis or nil

    local skillScope = normalizedRequest.preflightMode == "subclass_only"
        or normalizedRequest.partialScope == nil
        or normalizedRequest.partialScope == "class_skills"
    local skillPointPlan = acceptedSkillPointPlan
    local skillPointPlanErr = nil
    if type(acceptedRoute) == "table" then
        result.route = CloneRequest(acceptedRoute)
        result.skillSettings = effectiveSkillSettings
    elseif skillScope and normalizedRequest.preflightMode ~= "subclass_only"
        and (type(inputs) ~= "table" or inputs.ok ~= true) then
        local inputErrors = type(inputs) == "table" and inputs.errors or nil
        skillPointPlan = {
            expectedResult = "invalid",
            reasons = type(inputErrors) == "table" and inputErrors or {
                inputsErr or "skill_point_inputs_invalid",
            },
        }
    elseif skillScope and normalizedRequest.preflightMode ~= "subclass_only" then
        skillPointPlan, skillPointPlanErr = BuildSkillPointPlan(build, inputs)
    end
    result.diagnostics.skillPointPlan = skillPointPlan
    result.diagnostics.skillPointPlanError = skillPointPlanErr
    if type(acceptedRoute) ~= "table"
        and skillScope
        and normalizedRequest.preflightMode ~= "subclass_only" then
        result.skillSettings = SkillSettings:ResolveShortage(effectiveSkillSettings, skillPointPlan)
    elseif result.skillSettings == nil then
        result.skillSettings = effectiveSkillSettings
    end

    if skillScope and normalizedRequest.preflightMode ~= "subclass_only"
        and (type(skillPointPlan) ~= "table" or skillPointPlan.expectedResult == "invalid") then
        local reasons = type(skillPointPlan) == "table" and skillPointPlan.reasons or nil
        result.action = "block"
        result.error = "skill_point_evaluator_invalid"
        result.invalidReason = type(reasons) == "table" and reasons[1]
            or skillPointPlanErr
            or inputsErr
            or "skill_point_plan_unavailable"
        return result
    end

    if type(skillPointPlan) == "table"
        and skillPointPlan.expectedResult == "skill_phase_skip"
        and type(result.skillSettings) == "table"
        and result.skillSettings.activeAction == "skip_all" then
        result.route.skillPhaseMode = "skip_due_to_insufficient_points"
        result.route.skillPhaseReason = "insufficient_points_preflight"
        planOptions.preflightMode = "subclass_only"
        planOptions.skillPhaseMode = result.route.skillPhaseMode
        planOptions.skillPhaseReason = result.route.skillPhaseReason
    end
    planOptions.skillSettings = result.skillSettings
    if type(planOptions.activeRestorePlan) ~= "table" then
        planOptions.activeRestorePlan = type(inputs) == "table"
            and type(inputs.plan) == "table"
            and type(inputs.plan.diagnostics) == "table"
            and inputs.plan.diagnostics.analyzedActiveRestorePlan
            or nil
    end
    if type(planOptions.transformPlan) ~= "table" then
        planOptions.transformPlan = type(inputs) == "table"
            and type(inputs.plan) == "table"
            and type(inputs.plan.diagnostics) == "table"
            and inputs.plan.diagnostics.analyzedTransformPlan
            or nil
    end

    local pipelinePlan = type(inputs) == "table" and inputs.plan or nil
    local pipelinePlanErr = nil
    local needsResolvedPlanRebuild = type(acceptedPrecheck) ~= "table"
        and (planOptions.skillSettings ~= nil or planOptions.skillPhaseMode ~= nil)
    if type(inputs) == "table" and needsResolvedPlanRebuild then
        local resolvedPipelinePlan = nil
        resolvedPipelinePlan, pipelinePlanErr = BuildPlanFromCapturedInputs(
            build,
            normalizedRequest,
            inputs,
            planOptions
        )
        if type(resolvedPipelinePlan) == "table" then
            pipelinePlan = resolvedPipelinePlan
        end
    end
    result.diagnostics.pipelinePlan = pipelinePlan
    result.diagnostics.pipelinePlanError = pipelinePlanErr

    local gateResult = LTM_APPLY_PRECHECK_GATE:Evaluate(normalizedRequest, pipelinePlan)
    result.diagnostics.activityGate = gateResult.diagnostics
    if gateResult.action ~= "run_now" then
        result.action = gateResult.action
        result.error = gateResult.error
        result.activityRestrictionType = gateResult.diagnostics.activityRestrictionType
        return result
    end

    local popupRecommended = type(skillPointPlan) == "table"
        and (skillPointPlan.expectedResult == "skill_phase_skip"
            or skillPointPlan.expectedResult == "passive_partial")

    if interactive and popupRecommended then
        result.action = "show_point_shortage_dialog"
    end

    return result
end
