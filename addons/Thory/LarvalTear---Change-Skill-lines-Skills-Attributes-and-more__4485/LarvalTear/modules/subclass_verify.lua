local Addon = LarvalTearMod
local LTM_SUBCLASS_VERIFY = Addon.Modules.SubclassVerify
local SHARED_UTIL = Addon.Common.Util
local LTM_SUBCLASS_SNAPSHOT = Addon.Modules.SubclassSnapshot

function LTM_SUBCLASS_VERIFY:VerifySubclassState(context, targetState)
    if type(targetState) == "table" and type(targetState._verifyOptions) == "table" then
        local options = targetState._verifyOptions
    end

    if type(targetState) ~= "table" then
        return {
            ok = false,
            matched = false,
            matches = false,
            reason = "target_state_missing",
            currentState = nil,
            targetState = targetState,
            currentSkillLineIds = {},
            targetSkillLineIds = {},
            currentSignature = nil,
            targetSignature = nil,
            mismatches = {},
            diagnostics = {
                verificationImplemented = true,
            },
        }
    end

    local latestState = LTM_SUBCLASS_SNAPSHOT:CaptureCurrentSubclassState(context)

    if latestState == nil then
        return {
            ok = false,
            matched = false,
            matches = false,
            reason = "snapshot_capture_failed",
            currentState = latestState,
            targetState = targetState,
            currentSkillLineIds = {},
            targetSkillLineIds = {},
            currentSignature = nil,
            targetSignature = nil,
            mismatches = {},
            diagnostics = {
                verificationImplemented = true,
            },
        }
    end

    local currentIds = SHARED_UTIL:NormalizeLineIdList(latestState and latestState.activeSkillLineIds or nil)
    local targetIds = SHARED_UTIL:NormalizeLineIdList(targetState and targetState.targetSkillLineIds or nil)
    local targetSignature = SHARED_UTIL:BuildLineIdSignature(targetIds)
    if targetSignature == "" then
        targetSignature = nil
    end

    if targetSignature == nil then
        return {
            ok = false,
            matched = false,
            matches = false,
            reason = "target_signature_missing",
            currentState = latestState,
            targetState = targetState,
            currentSkillLineIds = currentIds,
            targetSkillLineIds = targetIds,
            currentSignature = nil,
            targetSignature = targetSignature,
            mismatches = {},
            diagnostics = {
                verificationImplemented = true,
            },
        }
    end

    local currentSignature = SHARED_UTIL:BuildLineIdSignature(currentIds)
    if currentSignature == "" then
        currentSignature = nil
    end

    if currentSignature == nil then
        return {
            ok = false,
            matched = false,
            matches = false,
            reason = "current_signature_missing",
            currentState = latestState,
            targetState = targetState,
            currentSkillLineIds = currentIds,
            targetSkillLineIds = targetIds,
            currentSignature = currentSignature,
            targetSignature = targetSignature,
            mismatches = {},
            diagnostics = {
                verificationImplemented = true,
            },
        }
    end

    local currentSet = SHARED_UTIL:BuildLineIdSet(currentIds)
    local targetSet = SHARED_UTIL:BuildLineIdSet(targetIds)
    local mismatches = {}

    for _, lineId in ipairs(targetIds) do
        if not currentSet[lineId] then
            mismatches[#mismatches + 1] = {
                kind = "missing_active_target_line",
                skillLineId = lineId,
            }
        end
    end

    for _, lineId in ipairs(currentIds) do
        if not targetSet[lineId] then
            mismatches[#mismatches + 1] = {
                kind = "unexpected_active_line",
                skillLineId = lineId,
            }
        end
    end

    local matched = currentSignature == targetSignature and #mismatches == 0
    local reason = matched and "" or "signature_mismatch"

    return {
        ok = true,
        matched = matched,
        matches = matched,
        reason = reason,
        currentState = latestState,
        targetState = targetState,
        currentSkillLineIds = currentIds,
        targetSkillLineIds = targetIds,
        currentSignature = currentSignature,
        targetSignature = targetSignature,
        mismatches = mismatches,
        diagnostics = {
            verificationImplemented = true,
        },
    }
end
