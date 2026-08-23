local Addon = LarvalTearMod
local M = Addon.Modules.SkillRespecVerify
local SHARED_UTIL = Addon.Common.Util
local LTM_SUBCLASS_VERIFY = Addon.Modules.SubclassVerify
local LTM_TRANSFORM_SKILLS = Addon.Modules.TransformSkills

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

function M:VerifyTransformSnapshotsPostCommit(context)
    if type(context) ~= "table" then
        return nil
    end
    if type(context.transformPostCommitVerify) == "table" then
        return context.transformPostCommitVerify
    end
    if context.postMutationVerifySucceeded ~= true then
        return nil
    end

    local transformPlan = context.transformPlan
    if type(transformPlan) ~= "table"
        or transformPlan.hasTarget ~= true
        or type(context.activeRestorePlan) == "table"
            and context.activeRestorePlan.neutralized == true then
        return nil
    end

    local transformSnapshots = transformPlan.appliedSnapshots
    local transformVerify = LTM_TRANSFORM_SKILLS:VerifySnapshots(
        transformSnapshots,
        context.pipelineContext,
        {
            expectedMissingProgressionSet = type(context.expectedMissingActiveTargets) == "table"
                and {
                    purchases = context.expectedMissingActiveTargets.purchaseByProgression,
                    morphs = context.expectedMissingActiveTargets.morphByProgression,
                }
                or nil,
        }
    )
    context.transformPostCommitVerify = transformVerify
    return transformVerify
end
