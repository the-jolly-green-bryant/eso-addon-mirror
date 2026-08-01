local Addon = LarvalTearMod
local M = Addon.Modules.SkillRespecVerify
local SHARED_UTIL = Addon.Common.Util
local LTM_SUBCLASS_VERIFY = Addon.Modules.SubclassVerify

local function CloneVerifyTargetState(targetState)
    local verifyTargetState = {}
    for key, value in pairs(targetState or {}) do
        verifyTargetState[key] = value
    end

    verifyTargetState._verifyOptions = {
        logPrefix = "Skill respec Route B verify",
        silent = true,
    }

    return verifyTargetState
end

local function ResolveMatched(verifyResult, currentSignature, targetSignature)
    local matched = verifyResult.matched
    if matched == nil then
        matched = verifyResult.matches
    end
    if matched == nil then
        matched = currentSignature ~= nil and targetSignature ~= nil and currentSignature == targetSignature
    end
    return matched == true
end

function M:CollectRouteBVerifySnapshot(context)
    if type(LTM_SUBCLASS_VERIFY) ~= "table"
        or type(LTM_SUBCLASS_VERIFY.VerifySubclassState) ~= "function" then
        return nil, "subclass_verify_module_unavailable"
    end

    local verifyTargetState = CloneVerifyTargetState(context and context.targetState or nil)
    local verifyCallOk, verifyResult = pcall(function()
        return LTM_SUBCLASS_VERIFY:VerifySubclassState(context and context.pipelineContext or nil, verifyTargetState)
    end)

    if not verifyCallOk then
        return nil, "subclass_verify_call_failed", verifyResult
    end

    if type(verifyResult) ~= "table" then
        return nil, "subclass_verify_unavailable"
    end

    local currentSkillLineIds = SHARED_UTIL:NormalizeLineIdList(verifyResult.currentSkillLineIds)
    local targetSkillLineIds = SHARED_UTIL:NormalizeLineIdList(verifyResult.targetSkillLineIds)
    local currentSignature = verifyResult.currentSignature or SHARED_UTIL:BuildLineIdSignature(currentSkillLineIds)
    local targetSignature = verifyResult.targetSignature or SHARED_UTIL:BuildLineIdSignature(targetSkillLineIds)
    local matched = ResolveMatched(verifyResult, currentSignature, targetSignature)

    return {
        currentState = verifyResult.currentState,
        currentSkillLineIds = currentSkillLineIds,
        targetSkillLineIds = targetSkillLineIds,
        currentSignature = currentSignature,
        targetSignature = targetSignature,
        matched = matched,
        matches = matched,
        ok = verifyResult.ok == true,
        reason = verifyResult.reason,
        verifyResult = verifyResult,
    }
end
