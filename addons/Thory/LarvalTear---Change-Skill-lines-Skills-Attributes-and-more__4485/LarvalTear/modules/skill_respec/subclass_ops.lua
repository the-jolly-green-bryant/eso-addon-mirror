local Addon = LarvalTearMod
local M = Addon.Modules.SkillRespecSubclassOps
local logging = Addon.Modules.SkillRespecLogging

function M:ResolveSkillLineData(apply, skillLineId)
    if type(SKILLS_DATA_MANAGER) ~= "table"
        or type(SKILLS_DATA_MANAGER.GetSkillLineDataById) ~= "function" then
        return nil, "skills_data_manager_unavailable"
    end

    local skillLineData = SKILLS_DATA_MANAGER:GetSkillLineDataById(skillLineId)
    if skillLineData == nil then
        return nil, "skill_line_data_missing"
    end

    return skillLineData
end

function M:ApplyPendingOperation(apply, context, operation)
    local skillLineId = operation and operation.skillLineId or nil
    if skillLineId == nil then
        return false, "skill_line_id_missing"
    end

    local skillLineData, skillLineErr = self:ResolveSkillLineData(apply, skillLineId)
    if skillLineData == nil then
        return false, skillLineErr
    end

    if operation.op == "deactivate" then
        if skillLineData.CanDeactivateForRespec ~= nil and not skillLineData:CanDeactivateForRespec() then
            return false, "cannot_deactivate_for_respec"
        end

        if skillLineData.DeactivateForRespec == nil then
            return false, "deactivate_for_respec_unavailable"
        end

        skillLineData:DeactivateForRespec(true)
        local pending = skillLineData.IsPendingDeactivation ~= nil and skillLineData:IsPendingDeactivation() or false
        if not pending then
            return false, "deactivate_pending_failed"
        end

        return true
    end

    if operation.op == "activate" then
        if skillLineData.CanActivateForRespec ~= nil and not skillLineData:CanActivateForRespec() then
            return false, "cannot_activate_for_respec"
        end

        if skillLineData.ActivateForRespec == nil then
            return false, "activate_for_respec_unavailable"
        end

        skillLineData:ActivateForRespec(true)
        local pending = skillLineData.IsPendingActivation ~= nil and skillLineData:IsPendingActivation() or false
        if not pending then
            return false, "activate_pending_failed"
        end

        context.pendingActivatedSkillLinesById = context.pendingActivatedSkillLinesById or {}
        context.pendingActivatedSkillLinesById[skillLineId] = skillLineData

        return true
    end

    return false, "unsupported_subclass_operation"
end

function M:ExecutePendingOperations(apply, context)
    local orderedOperations = context.plan and context.plan.orderedOperations or nil
    if type(orderedOperations) ~= "table" or #orderedOperations == 0 then
        return true
    end

    logging.Log(
        "Route B pending op summary",
        "count=" .. tostring(#orderedOperations),
        "orderedOperations=" .. logging.FormatOrderedOperations(orderedOperations)
    )

    for _, operation in ipairs(orderedOperations) do
        local opOk, opErr = self:ApplyPendingOperation(apply, context, operation)
        if not opOk then
            return false, opErr, operation
        end
    end

    local pendingChanges = type(SKILLS_AND_ACTION_BAR_MANAGER) == "table"
        and SKILLS_AND_ACTION_BAR_MANAGER.HasAnyPendingChanges
        and SKILLS_AND_ACTION_BAR_MANAGER:HasAnyPendingChanges()
        or nil
    if pendingChanges ~= true then
        return false, "subclass_pending_changes_missing"
    end

    return true
end
