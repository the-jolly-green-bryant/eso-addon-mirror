local Addon = LarvalTearMod
local Log = Addon.Common.Log
local LTM_SKILL_APPLY = Addon.Modules.SkillApply
local LTM_PIPELINE_CONTEXT = Addon.Modules.PipelineContext
local LTM_SKILL_RESTORE = Addon.Modules.SkillRestore
local LTM_SKILL_RESPEC_APPLY = Addon.Modules.SkillRespecApply

local function CreateSuccessResult(details)
    return {
        ok = true,
        details = details,
    }
end

local function CreateSkippedResult(reason, details)
    details = type(details) == "table" and details or {}
    details.status = "skipped"
    details.reason = reason
    details.intentional = true
    return {
        ok = true,
        skipped = true,
        code = reason,
        details = details,
    }
end

local function BuildActionBarRestoreConfig(config)
    local restoreConfig = {}
    for key, value in pairs(config or {}) do
        restoreConfig[key] = value
    end
    restoreConfig.subclassChanges = nil
    restoreConfig.morphChanges = nil
    return restoreConfig
end

local function RunActionBarRestore(config, pipelineContext)
    local routeBCompleted = LTM_PIPELINE_CONTEXT:GetRuntimeFlag(
        pipelineContext,
        "routeBCompleted"
    ) == true
    local methodName = routeBCompleted and "RunRestoreOnly" or "Run"
    local method = LTM_SKILL_RESTORE[methodName]

    return method(LTM_SKILL_RESTORE, BuildActionBarRestoreConfig(config))
end

function LTM_SKILL_APPLY:GetLastResult()
    return self.lastResult
end

function LTM_SKILL_APPLY:SetLastResult(result, pipelineContext)
    self.lastResult = result
    LTM_PIPELINE_CONTEXT:SetPhaseResult(pipelineContext, "Skills", result)
end

function LTM_SKILL_APPLY:Log(...)
    Log.LogDebugSummary("Skill apply routing summary", ...)
end

function LTM_SKILL_APPLY:ResolveRoute(config)
    local plan = config._pipelinePlan

    local pipelineContext = type(config) == "table" and config._pipelineContext or nil
    local priorSkillRespecCommitted = LTM_PIPELINE_CONTEXT:GetRuntimeFlag(
        pipelineContext,
        "priorSkillRespecCommitted"
    ) == true
    if plan.route == "B"
        and plan.needsSubclassChange == true
        and plan.needsPurchaseChange ~= true
        and plan.needsMorphChange ~= true
        and priorSkillRespecCommitted then
        self:Log("route override A priorSkillRespecCommitted=true")
        return "A"
    end

    return plan.route
end

function LTM_SKILL_APPLY:Run(config)
    local pipelineContext = type(config) == "table" and config._pipelineContext or nil
    self:SetLastResult(nil, pipelineContext)

    if type(config) == "table" and config.mode == "skip_due_to_insufficient_points" then
        local reason = type(config.reason) == "string" and config.reason or "insufficient_points_preflight"
        local actionBarRestoreResult = nil
        local actionBarRestoreError = nil
        if reason == "skill_settings_skip_all" then
            local restoreOk, restoreErr = RunActionBarRestore(config, pipelineContext)
            if restoreOk == true then
                actionBarRestoreResult = LTM_SKILL_RESTORE:GetLastResult()
            else
                actionBarRestoreError = restoreErr or "action_bar_restore_failed"
            end
        end
        if reason == "skill_settings_skip_all"
            and config.skillSettingsSkipNormalSkillChanges == true then
            LTM_PIPELINE_CONTEXT:RecordSkillSettingsSkip(
                pipelineContext,
                "normal_skill_changes",
                reason
            )
        end
        self:Log("skill phase skipped reason=" .. tostring(reason))
        self:SetLastResult(CreateSkippedResult(reason, {
            mode = config.mode,
            sourcePhase = "Skills",
            actionBarRestoreResult = actionBarRestoreResult,
            actionBarRestoreError = actionBarRestoreError,
        }), pipelineContext)
        return true
    end

    local routeBCompleted = LTM_PIPELINE_CONTEXT:GetRuntimeFlag(
        pipelineContext,
        "routeBCompleted"
    ) == true
    if routeBCompleted then
        Log.Debug("Skill apply called route=restore_only")
        local ok, err = LTM_SKILL_RESTORE:RunRestoreOnly(config)
        if ok == true then
            local restoreResult = LTM_SKILL_RESTORE:GetLastResult()
            self:SetLastResult(CreateSuccessResult({
                status = "restore_only",
                sourcePhase = "Skills",
                actionBarRestoreResult = restoreResult,
            }), pipelineContext)
        end
        return ok, err
    end

    local route = self:ResolveRoute(config)

    local plan = type(config) == "table" and config._pipelinePlan or nil

    Log.Debug("Skill apply called route=" .. tostring(route))
    if type(plan) == "table" and type(plan.phases) == "table" then
        self:Log(
            "route=" .. tostring(route),
            "needsSubclassChange=" .. tostring(plan.needsSubclassChange == true),
            "needsPurchaseChange=" .. tostring(plan.needsPurchaseChange == true),
            "needsMorphChange=" .. tostring(plan.needsMorphChange == true),
            "needsAttributeChange=" .. tostring(plan.needsAttributeChange == true),
            "phases=" .. table.concat(plan.phases, ",")
        )
    end

    -- Route A is restore-only. It must not perform respec, morph, subclass,
    -- or purchase work.
    if route == "A" then
        local ok, err = LTM_SKILL_RESTORE:Run(config)
        if ok == true then
            local restoreResult = LTM_SKILL_RESTORE:GetLastResult()
            self:SetLastResult(CreateSuccessResult({
                status = "route_a",
                sourcePhase = "Skills",
                actionBarRestoreResult = restoreResult,
            }), pipelineContext)
        end
        return ok, err
    end

    if route == "B" then
        -- Route B owns all respec-backed skill mutations:
        -- subclass pending, morph pending, and future purchase pending.
        -- It should converge on a single commit, verify that result, then
        -- hand off to restore-only work equivalent to route A.
        local ok, err = LTM_SKILL_RESPEC_APPLY:Run(config)
        if ok == true then
            local result = LTM_SKILL_RESPEC_APPLY:GetLastResult()
            if type(result) == "table" then
                self:SetLastResult(result, pipelineContext)
            end
        end
        return ok, err
    end

    self:Log("unsupported route", route)
    return false, "unsupported_skill_route"
end
