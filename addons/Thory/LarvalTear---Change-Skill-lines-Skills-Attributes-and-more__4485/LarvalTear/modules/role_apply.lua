local Addon = LarvalTearMod
local Log = Addon.Common.Log
local LTM_ROLE_APPLY = Addon.Modules.RoleApply
local LTM_ROLE_STATE = Addon.Modules.RoleState
local LTM_PIPELINE_CONTEXT = Addon.Modules.PipelineContext

local ROLE_APPLY_E_CONFIG_INVALID = "ROLE_APPLY_E_CONFIG_INVALID"
local ROLE_APPLY_E_UPDATE_UNAVAILABLE = "ROLE_APPLY_E_UPDATE_UNAVAILABLE"
local ROLE_APPLY_E_UPDATE_NOT_ALLOWED = "ROLE_APPLY_E_UPDATE_NOT_ALLOWED"
local ROLE_APPLY_E_UPDATE_FAILED = "ROLE_APPLY_E_UPDATE_FAILED"
local ROLE_APPLY_E_VERIFY_FAILED = "ROLE_APPLY_E_VERIFY_FAILED"

local function LogSummary(...)
    Log.LogDebugSummary(...)
end

function LTM_ROLE_APPLY:GetLastResult()
    return self.lastResult
end

function LTM_ROLE_APPLY:SetLastResult(ok, reason, details)
    self.lastResult = {
        ok = ok == true,
        details = {
            phase = "role_apply",
            reason = reason,
            summary = details,
            mutatingAction = ok == true and reason == nil and "role_update" or nil,
        },
    }
end

function LTM_ROLE_APPLY:RecordPartialSuccess(context, reason, summary)
    if type(context) ~= "table" then
        return
    end

    return LTM_PIPELINE_CONTEXT:RecordDomainResult(context, {
        domain = "Role",
        sourcePhase = "Role",
        severity = "partial",
        resultCode = reason,
        reasons = {
            reason,
        },
        residualSummary = summary,
    })
end

function LTM_ROLE_APPLY:FinishPartial(context, reason, summary)
    self:SetLastResult(true, reason, summary)
    self:RecordPartialSuccess(context, reason, summary)
    LogSummary(
        "Role apply partial",
        "reason=" .. tostring(reason),
        "currentRole=" .. tostring(type(summary) == "table" and summary.currentRole or nil),
        "targetRole=" .. tostring(type(summary) == "table" and summary.targetRole or nil)
    )
    return true
end

function LTM_ROLE_APPLY:Run(config)
    self.lastResult = nil

    if type(config) ~= "table" then
        self:SetLastResult(false, "config_invalid", nil)
        return false, ROLE_APPLY_E_CONFIG_INVALID
    end

    local context = config._pipelineContext
    local targetRole = LTM_ROLE_STATE:NormalizeRoleState(config)
    if targetRole == nil then
        self:SetLastResult(true, "target_missing", nil)
        LogSummary("Role apply skipped", "reason=target_missing")
        return true
    end

    local currentRole = LTM_ROLE_STATE:CaptureCurrentRoleState()
    local summary = {
        currentRole = type(currentRole) == "table" and currentRole.selectedRole or nil,
        currentRoleKey = type(currentRole) == "table" and currentRole.roleKey or nil,
        targetRole = targetRole.selectedRole,
        targetRoleKey = targetRole.roleKey,
    }

    if type(currentRole) == "table" and currentRole.selectedRole == targetRole.selectedRole then
        self:SetLastResult(true, "already_applied", summary)
        LogSummary("Role apply skipped", "reason=already_applied", "role=" .. tostring(targetRole.roleKey))
        return true
    end

    if type(UpdateSelectedLFGRole) ~= "function" then
        return self:FinishPartial(context, ROLE_APPLY_E_UPDATE_UNAVAILABLE, summary)
    end

    if type(CanUpdateSelectedLFGRole) == "function" then
        local canOk, canUpdate = pcall(CanUpdateSelectedLFGRole)
        if not canOk or canUpdate ~= true then
            return self:FinishPartial(context, ROLE_APPLY_E_UPDATE_NOT_ALLOWED, summary)
        end
    end

    local updateOk = pcall(UpdateSelectedLFGRole, targetRole.selectedRole)
    if not updateOk then
        return self:FinishPartial(context, ROLE_APPLY_E_UPDATE_FAILED, summary)
    end

    local verifiedRole = LTM_ROLE_STATE:CaptureCurrentRoleState()
    summary.currentRole = type(verifiedRole) == "table" and verifiedRole.selectedRole or summary.currentRole
    summary.currentRoleKey = type(verifiedRole) == "table" and verifiedRole.roleKey or summary.currentRoleKey

    if type(verifiedRole) ~= "table" or verifiedRole.selectedRole ~= targetRole.selectedRole then
        return self:FinishPartial(context, ROLE_APPLY_E_VERIFY_FAILED, summary)
    end

    self:SetLastResult(true, nil, summary)
    LogSummary("Role apply finished", "role=" .. tostring(targetRole.roleKey))
    return true
end
