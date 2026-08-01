-- Read-only input construction for the authoritative Skill Point Evaluator.
-- This module never performs mutations.
local Addon = LarvalTearMod
local Provider = Addon.Modules.SkillPointInputProvider
local Util = Addon.Common.Util
local LTM_ATTRIBUTE_SNAPSHOT = Addon.Modules.AttributeSnapshot
local LTM_PIPELINE_CONTEXT = Addon.Modules.PipelineContext
local LTM_PIPELINE_PLANNER = Addon.Modules.PipelinePlanner
local LTM_ROLE_STATE = Addon.Modules.RoleState
local LTM_SKILL_SNAPSHOT_AUDIT = Addon.Modules.SkillSnapshotAudit
local LTM_SUBCLASS_SNAPSHOT = Addon.Modules.SubclassSnapshot

local function AppendError(result, reason)
    if type(reason) ~= "string" or reason == "" then
        return
    end
    result.errors[#result.errors + 1] = reason
end

local function SetCurrentState(context, currentState, key, value)
    currentState[key] = value
    if type(LTM_PIPELINE_CONTEXT) == "table"
        and type(LTM_PIPELINE_CONTEXT.SetCurrentState) == "function" then
        LTM_PIPELINE_CONTEXT:SetCurrentState(context, key, value)
    end
end

local function CaptureSkillSnapshot(result)
    if type(LTM_SKILL_SNAPSHOT_AUDIT) ~= "table"
        or type(LTM_SKILL_SNAPSHOT_AUDIT.CaptureCurrentSnapshot) ~= "function" then
        AppendError(result, "skill_snapshot_audit_unavailable")
        return nil
    end

    local ok, snapshot, err = pcall(
        LTM_SKILL_SNAPSHOT_AUDIT.CaptureCurrentSnapshot,
        LTM_SKILL_SNAPSHOT_AUDIT
    )
    if not ok or type(snapshot) ~= "table" then
        AppendError(result, err or snapshot or "skill_snapshot_capture_failed")
        return nil
    end
    return snapshot
end

local function BuildCurrentState(context, result)
    local currentState = {}

    if type(LTM_SUBCLASS_SNAPSHOT) == "table"
        and type(LTM_SUBCLASS_SNAPSHOT.CaptureCurrentSubclassState) == "function" then
        SetCurrentState(
            context,
            currentState,
            "subclass",
            LTM_SUBCLASS_SNAPSHOT:CaptureCurrentSubclassState(context)
        )
    else
        AppendError(result, "subclass_snapshot_unavailable")
    end

    if type(LTM_ATTRIBUTE_SNAPSHOT) == "table"
        and type(LTM_ATTRIBUTE_SNAPSHOT.CaptureCurrentAttributeState) == "function" then
        SetCurrentState(
            context,
            currentState,
            "attributes",
            LTM_ATTRIBUTE_SNAPSHOT:CaptureCurrentAttributeState(context)
        )
    end

    if type(LTM_ROLE_STATE) == "table"
        and type(LTM_ROLE_STATE.CaptureCurrentRoleState) == "function" then
        SetCurrentState(context, currentState, "role", LTM_ROLE_STATE:CaptureCurrentRoleState())
    end

    return currentState
end

local function BuildActiveTargetStates(build, result)
    if type(Util) ~= "table"
        or type(Util.NormalizeSlotTargets) ~= "function"
        or type(Util.ResolveActiveSkillTargetState) ~= "function" then
        AppendError(result, "active_target_state_provider_unavailable")
        return nil
    end

    local states = {}
    local targets = Util:NormalizeSlotTargets(type(build) == "table" and build.skills or nil)
    for targetIndex, target in ipairs(targets) do
        local resolved = Util:ResolveActiveSkillTargetState(target)
        states[targetIndex] = type(resolved) == "table" and resolved or {
            targetAbilityId = type(target) == "table"
                and tonumber(target.targetAbilityId or target.abilityId)
                or nil,
            unresolved = true,
            reason = "active_target_state_unavailable",
        }
    end
    return states
end

local function CreatePlanningContext(build, options)
    options = type(options) == "table" and options or {}
    local runOptions = {
        source = options.source or "skill_point_input_provider",
        partialScope = options.partialScope,
        preflightMode = options.preflightMode,
        skillPhaseMode = options.skillPhaseMode,
        skillPhaseReason = options.skillPhaseReason,
        spSaver = options.spSaver,
        forceChampionRespec = options.forceChampionRespec == true,
    }
    return type(LTM_PIPELINE_CONTEXT) == "table"
        and type(LTM_PIPELINE_CONTEXT.Create) == "function"
        and LTM_PIPELINE_CONTEXT:Create(build, runOptions)
        or { targetBuild = build, runOptions = runOptions }
end

local function BuildPlanFromCapturedInputs(inputs, build, options)
    if type(inputs) ~= "table" or type(inputs.currentState) ~= "table" then
        return nil, "captured_current_state_unavailable"
    end
    if type(LTM_PIPELINE_PLANNER) ~= "table"
        or type(LTM_PIPELINE_PLANNER.BuildPipelinePlan) ~= "function" then
        return nil, "pipeline_planner_unavailable"
    end

    local context = CreatePlanningContext(build, options)
    for key, value in pairs(inputs.currentState) do
        if type(LTM_PIPELINE_CONTEXT) == "table"
            and type(LTM_PIPELINE_CONTEXT.SetCurrentState) == "function" then
            LTM_PIPELINE_CONTEXT:SetCurrentState(context, key, value)
        end
    end
    context.skillPointActiveTargetStates = inputs.activeTargetStates
    return LTM_PIPELINE_PLANNER:BuildPipelinePlan(context, inputs.currentState, build), nil
end

function Provider:BuildPlanFromCapturedInputs(inputs, build, options)
    return BuildPlanFromCapturedInputs(inputs, build, options)
end

function Provider:Build(build, options)
    options = type(options) == "table" and options or {}
    local result = {
        ok = false,
        build = build,
        snapshot = nil,
        plan = nil,
        currentState = nil,
        activeTargetStates = nil,
        passiveAnalysis = nil,
        errors = {},
    }

    if type(build) ~= "table" then
        AppendError(result, "build_missing")
        return result
    end

    result.snapshot = CaptureSkillSnapshot(result)
    local context = CreatePlanningContext(build, options)
    local currentState = BuildCurrentState(context, result)
    result.currentState = currentState
    result.activeTargetStates = BuildActiveTargetStates(build, result)
    context.skillPointActiveTargetStates = result.activeTargetStates

    local plan, planErr = BuildPlanFromCapturedInputs(result, build, options)
    result.plan = plan
    if type(planErr) == "string" then
        AppendError(result, planErr)
    end

    local diagnostics = type(result.plan) == "table" and result.plan.diagnostics or nil
    result.passiveAnalysis = type(diagnostics) == "table" and diagnostics.passiveAnalysis or nil
    if type(result.plan) ~= "table" then
        AppendError(result, "pipeline_plan_unavailable")
    end
    if type(result.passiveAnalysis) ~= "table" then
        AppendError(result, "passive_analysis_unavailable")
    end

    result.ok = #result.errors == 0
    return result
end
