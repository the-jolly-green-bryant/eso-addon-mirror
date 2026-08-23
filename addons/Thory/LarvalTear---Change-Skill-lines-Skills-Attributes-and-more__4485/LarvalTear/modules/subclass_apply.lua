local Addon = LarvalTearMod
local LTM_SUBCLASS_APPLY = Addon.Modules.SubclassApply
local LTM_PIPELINE_CONTEXT = Addon.Modules.PipelineContext
local LTM_SKILL_RESPEC_APPLY = Addon.Modules.SkillRespecApply
local LTM_SUBCLASS_SNAPSHOT = Addon.Modules.SubclassSnapshot

function LTM_SUBCLASS_APPLY:Run(config)
    local context = config and config._pipelineContext or nil
    local targetState = LTM_PIPELINE_CONTEXT:GetTargetSubclassState(context)

    local currentState = LTM_PIPELINE_CONTEXT:GetCurrentSubclassState(context)
    if currentState == nil then
        currentState = LTM_SUBCLASS_SNAPSHOT:CaptureCurrentSubclassState(context)
    end

    LTM_PIPELINE_CONTEXT:SetCurrentState(context, "subclass", currentState)

    local plan, planErr = LTM_SKILL_RESPEC_APPLY:ResolveSubclassPlan(config)
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

    local skillTargetPlan = LTM_SKILL_RESPEC_APPLY:BuildRouteBSkillTargetPlan(config)

    local runOk, runErr = LTM_SKILL_RESPEC_APPLY:RunRouteBSubclassOnly(config)
    local delegateResult = LTM_SKILL_RESPEC_APPLY:GetLastResult()

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
    local delegateResult = LTM_SKILL_RESPEC_APPLY:GetLastResult()
    if delegateResult ~= nil then
        return delegateResult
    end

    return self.lastResult
end
