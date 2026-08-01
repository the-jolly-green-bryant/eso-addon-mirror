local Addon = LarvalTearMod
local LTM_SUBCLASS_APPLY = Addon.Modules.SubclassApply
local LTM_PIPELINE_CONTEXT = Addon.Modules.PipelineContext
local LTM_SKILL_RESPEC_APPLY = Addon.Modules.SkillRespecApply
local LTM_SUBCLASS_SNAPSHOT = Addon.Modules.SubclassSnapshot
local SUBCLASS_APPLY_NOT_IMPLEMENTED = "SUBCLASS_APPLY_E_NOT_IMPLEMENTED"

function LTM_SUBCLASS_APPLY:Run(config)
    local context = config and config._pipelineContext or nil
    local targetState = nil

    if type(LTM_PIPELINE_CONTEXT) == "table" and type(LTM_PIPELINE_CONTEXT.GetTargetSubclassState) == "function" then
        targetState = LTM_PIPELINE_CONTEXT:GetTargetSubclassState(context)
    else
        targetState = config
    end

    local currentState = nil
    if type(LTM_PIPELINE_CONTEXT) == "table" and type(LTM_PIPELINE_CONTEXT.GetCurrentSubclassState) == "function" then
        currentState = LTM_PIPELINE_CONTEXT:GetCurrentSubclassState(context)
    end
    if currentState == nil
        and type(LTM_SUBCLASS_SNAPSHOT) == "table"
        and type(LTM_SUBCLASS_SNAPSHOT.CaptureCurrentSubclassState) == "function" then
        currentState = LTM_SUBCLASS_SNAPSHOT:CaptureCurrentSubclassState(context)
    end

    if type(LTM_PIPELINE_CONTEXT) == "table" and type(LTM_PIPELINE_CONTEXT.SetCurrentState) == "function" then
        LTM_PIPELINE_CONTEXT:SetCurrentState(context, "subclass", currentState)
    end

    if type(LTM_SKILL_RESPEC_APPLY) ~= "table"
        or type(LTM_SKILL_RESPEC_APPLY.RunRouteBSubclassOnly) ~= "function" then
        self.lastResult = {
            ok = false,
            details = {
                reason = "route_b_subclass_delegate_unavailable",
                code = SUBCLASS_APPLY_NOT_IMPLEMENTED,
            },
        }
        return false, SUBCLASS_APPLY_NOT_IMPLEMENTED
    end

    local plan = nil
    local planErr = nil
    if type(LTM_SKILL_RESPEC_APPLY.ResolveSubclassPlan) == "function" then
        plan, planErr = LTM_SKILL_RESPEC_APPLY:ResolveSubclassPlan(config)
    end
    if plan == nil then
        self.lastResult = {
            ok = false,
            details = {
                reason = planErr or "subclass_plan_missing",
                targetState = targetState,
                currentState = currentState,
            },
        }
        return false, planErr or "subclass_plan_missing"
    end

    local skillTargetPlan = nil
    if type(LTM_SKILL_RESPEC_APPLY.BuildRouteBSkillTargetPlan) == "function" then
        skillTargetPlan = LTM_SKILL_RESPEC_APPLY:BuildRouteBSkillTargetPlan(config)
    end

    local runOk, runErr = LTM_SKILL_RESPEC_APPLY:RunRouteBSubclassOnly(config)
    local delegateResult = type(LTM_SKILL_RESPEC_APPLY.GetLastResult) == "function"
        and LTM_SKILL_RESPEC_APPLY:GetLastResult()
        or nil

    self.lastResult = {
        ok = runOk == true,
        details = {
            delegatedTo = "skill_respec_apply.route_b_subclass_only",
            targetState = targetState,
            currentState = currentState,
            plan = plan,
            skillTargetPlan = skillTargetPlan,
            delegateResult = delegateResult,
            delegateErr = runErr,
        },
    }

    return runOk, runErr
end

function LTM_SUBCLASS_APPLY:GetLastResult()
    if type(LTM_SKILL_RESPEC_APPLY) == "table" and type(LTM_SKILL_RESPEC_APPLY.GetLastResult) == "function" then
        local delegateResult = LTM_SKILL_RESPEC_APPLY:GetLastResult()
        if delegateResult ~= nil then
            return delegateResult
        end
    end

    return self.lastResult
end
