local Addon = LarvalTearMod
local LTM_APPLY_PRECHECK_DECISION = Addon.Modules.ApplyPrecheckDecision
local LTM_APPLY_PRECHECK_GATE = Addon.Modules.ApplyPrecheckGate
local LTM_SKILL_POINT_INPUT_PROVIDER = Addon.Modules.SkillPointInputProvider
local LTM_SKILL_POINT_EVALUATOR = Addon.Modules.SkillPointEvaluator
local LTM_SP_SAVER_POLICY_RESOLVER = Addon.Modules.SpSaverPolicyResolver

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
    if type(LTM_SKILL_POINT_INPUT_PROVIDER) ~= "table"
        or type(LTM_SKILL_POINT_INPUT_PROVIDER.Build) ~= "function" then
        return nil, "skill_point_input_provider_unavailable"
    end

    local ok, inputs = pcall(LTM_SKILL_POINT_INPUT_PROVIDER.Build, LTM_SKILL_POINT_INPUT_PROVIDER, build, {
        source = "apply_precheck_decision",
        partialScope = request.partialScope,
        preflightMode = type(planOptions) == "table" and planOptions.preflightMode or request.preflightMode,
        skillPhaseMode = type(planOptions) == "table" and planOptions.skillPhaseMode or nil,
        skillPhaseReason = type(planOptions) == "table" and planOptions.skillPhaseReason or nil,
        spSaver = type(planOptions) == "table" and planOptions.spSaver or nil,
        forceChampionRespec = request.forceChampionRespec == true,
    })
    if not ok then
        return nil, tostring(inputs)
    end
    return inputs, nil
end

local function BuildPlanFromCapturedInputs(build, request, inputs, planOptions)
    if type(LTM_SKILL_POINT_INPUT_PROVIDER) ~= "table"
        or type(LTM_SKILL_POINT_INPUT_PROVIDER.BuildPlanFromCapturedInputs) ~= "function" then
        return nil, "captured_pipeline_plan_provider_unavailable"
    end

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
            spSaver = type(planOptions) == "table" and planOptions.spSaver or nil,
            forceChampionRespec = request.forceChampionRespec == true,
        }
    )
    if not ok then
        return nil, tostring(plan)
    end
    return plan, err
end

local function BuildSkillPointPlan(build, inputs)
    if type(LTM_SKILL_POINT_EVALUATOR) ~= "table"
        or type(LTM_SKILL_POINT_EVALUATOR.BuildPlan) ~= "function" then
        return nil, "skill_point_evaluator_unavailable"
    end

    local ok, skillPointPlan = pcall(
        LTM_SKILL_POINT_EVALUATOR.BuildPlan,
        LTM_SKILL_POINT_EVALUATOR,
        build,
        {
            plan = inputs.plan,
            snapshot = inputs.snapshot,
            passiveAnalysis = inputs.passiveAnalysis,
            activeTargetStates = inputs.activeTargetStates,
        }
    )
    if not ok then
        return nil, tostring(skillPointPlan)
    end
    return skillPointPlan, nil
end

local function ResolveSpSaverPolicy(build, skillPointPlan)
    local commonSettings = type(Addon.GetSpSaverSettings) == "function"
        and Addon:GetSpSaverSettings()
        or nil
    local buildSettings = type(build) == "table" and build.spSaver or nil
    return LTM_SP_SAVER_POLICY_RESOLVER:Resolve(commonSettings, buildSettings, skillPointPlan)
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
    local acceptedSpSaver = type(acceptedPrecheck) == "table" and acceptedPrecheck.spSaver or nil
    local planOptions = {
        preflightMode = type(acceptedRoute) == "table" and acceptedRoute.preflightMode or normalizedRequest.preflightMode,
        skillPhaseMode = type(acceptedRoute) == "table" and acceptedRoute.skillPhaseMode or nil,
        skillPhaseReason = type(acceptedRoute) == "table" and acceptedRoute.skillPhaseReason or nil,
        spSaver = acceptedSpSaver,
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
        result.spSaver = type(acceptedSpSaver) == "table" and CloneRequest(acceptedSpSaver) or nil
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
    if result.spSaver == nil and skillScope and normalizedRequest.preflightMode ~= "subclass_only" then
        result.spSaver = ResolveSpSaverPolicy(build, skillPointPlan)
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

    if type(skillPointPlan) == "table" and skillPointPlan.expectedResult == "skill_phase_skip" then
        result.route.skillPhaseMode = "skip_due_to_insufficient_points"
        result.route.skillPhaseReason = "insufficient_points_preflight"
        planOptions.preflightMode = "subclass_only"
        planOptions.skillPhaseMode = result.route.skillPhaseMode
        planOptions.skillPhaseReason = result.route.skillPhaseReason
    end
    planOptions.spSaver = result.spSaver

    local pipelinePlan = type(inputs) == "table" and inputs.plan or nil
    local pipelinePlanErr = nil
    local needsResolvedPlanRebuild = type(acceptedPrecheck) ~= "table"
        and (planOptions.spSaver ~= nil or planOptions.skillPhaseMode ~= nil)
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

    local gateResult = type(LTM_APPLY_PRECHECK_GATE) == "table"
        and type(LTM_APPLY_PRECHECK_GATE.Evaluate) == "function"
        and LTM_APPLY_PRECHECK_GATE:Evaluate(normalizedRequest, pipelinePlan)
        or nil
    result.diagnostics.activityGate = type(gateResult) == "table" and gateResult.diagnostics or nil
    if type(gateResult) == "table" and gateResult.action ~= "run_now" then
        result.action = gateResult.action
        result.error = gateResult.error
        result.activityRestrictionType = type(gateResult.diagnostics) == "table"
            and gateResult.diagnostics.activityRestrictionType
            or nil
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
