local Addon = LarvalTearMod
local Log = Addon.Common.Log
local QuickslotApply = Addon.Modules.QuickslotApply
local QuickslotGate = Addon.Modules.QuickslotGate
local QuickslotSnapshot = Addon.Modules.QuickslotSnapshot

local APPLY_DELAY_MS = 300
local FINAL_VERIFY_DELAY_MS = 300

local function DebugSummary(...)
    if type(Log) == "table" and type(Log.LogDebugSummary) == "function" then
        Log.LogDebugSummary(...)
    end
end

local function BuildOperationList(profile)
    local resolvedSlots = QuickslotSnapshot:ResolveProfile(profile)
    local operations = {}
    local skippedMissing = 0
    local skippedUnsupported = 0
    local ignoredEmpty = 0

    for _, entry in ipairs(resolvedSlots or {}) do
        if QuickslotSnapshot:IsItemEntry(entry) then
            if entry.missing == true then
                skippedMissing = skippedMissing + 1
            else
                operations[#operations + 1] = {
                    operationType = "item",
                    slotIndex = entry.slotIndex,
                    bagId = entry.bagId,
                    bagSlotIndex = entry.bagSlotIndex,
                    target = entry,
                }
            end
        elseif QuickslotSnapshot:IsSimpleActionEntry(entry) then
            if type(entry.boundId) == "number" and entry.boundId > 0 then
                operations[#operations + 1] = {
                    operationType = "simple",
                    slotIndex = entry.slotIndex,
                    actionType = entry.actionType,
                    actionId = entry.boundId,
                    target = entry,
                }
            else
                skippedUnsupported = skippedUnsupported + 1
            end
        elseif QuickslotSnapshot:IsEmptyEntry(entry) then
            ignoredEmpty = ignoredEmpty + 1
        else
            skippedUnsupported = skippedUnsupported + 1
        end
    end

    return operations, resolvedSlots, {
        skippedMissing = skippedMissing,
        skippedUnsupported = skippedUnsupported,
        ignoredEmpty = ignoredEmpty,
    }
end

local function FinishWithCallback(callback, result)
    if type(callback) == "function" then
        callback(result)
    end
end

function QuickslotApply:ApplyProfile(profile, callback)
    if type(profile) ~= "table" then
        FinishWithCallback(callback, { status = "failed", reason = "quickslot_profile_invalid" })
        return false, "quickslot_profile_invalid"
    end

    local gateOk, gateErr = QuickslotGate:CanApply()
    if not gateOk then
        FinishWithCallback(callback, { status = "failed", reason = gateErr })
        return false, gateErr
    end

    if type(CallSecureProtected) ~= "function" then
        FinishWithCallback(callback, { status = "failed", reason = "call_secure_protected_missing" })
        return false, "call_secure_protected_missing"
    end

    local hotbarCategory = QuickslotSnapshot:GetQuickslotCategory()
    if type(hotbarCategory) ~= "number" then
        FinishWithCallback(callback, { status = "failed", reason = "quickslot_category_missing" })
        return false, "quickslot_category_missing"
    end

    local operations, resolvedSlots, summary = BuildOperationList(profile)
    self.running = true
    self.currentProfileId = profile.id

    DebugSummary(
        "QuickSlot apply started",
        "profileId=" .. tostring(profile.id),
        "operations=" .. tostring(#operations),
        "missing=" .. tostring(summary.skippedMissing),
        "unsupported=" .. tostring(summary.skippedUnsupported)
    )

    local result = {
        status = "failed",
        profileId = profile.id,
        profileName = profile.displayName or profile.name,
        applied = 0,
        failed = 0,
        skippedMissing = summary.skippedMissing,
        skippedUnsupported = summary.skippedUnsupported,
        ignoredEmpty = summary.ignoredEmpty,
        errors = {},
    }

    local function finish()
        local finalSnapshot, snapshotErr = QuickslotSnapshot:CaptureCurrent()
        if type(finalSnapshot) ~= "table" then
            result.reason = snapshotErr or "quickslot_final_snapshot_failed"
            self.running = false
            self.currentProfileId = nil
            FinishWithCallback(callback, result)
            return
        end

        local verify = QuickslotSnapshot:CompareCurrentToProfile(profile, finalSnapshot, resolvedSlots)
        result.verify = verify
        if result.failed > 0 or verify.mismatched > 0 then
            result.status = "failed"
            result.reason = "quickslot_verify_failed"
        elseif result.skippedMissing > 0 or result.skippedUnsupported > 0 then
            result.status = "partial_success"
        else
            result.status = "full_success"
        end

        DebugSummary(
            "QuickSlot apply finished",
            "profileId=" .. tostring(profile.id),
            "status=" .. tostring(result.status),
            "applied=" .. tostring(result.applied),
            "failed=" .. tostring(result.failed),
            "verifyMismatched=" .. tostring(verify.mismatched),
            "skippedMissing=" .. tostring(result.skippedMissing)
        )

        self.running = false
        self.currentProfileId = nil
        FinishWithCallback(callback, result)
    end

    local function runOperation(index)
        if index > #operations then
            if type(zo_callLater) == "function" then
                zo_callLater(finish, FINAL_VERIFY_DELAY_MS)
            else
                finish()
            end
            return
        end

        local operation = operations[index]
        local ok, callResult
        if operation.operationType == "item" then
            ok, callResult = pcall(
                CallSecureProtected,
                "SelectSlotItem",
                operation.bagId,
                operation.bagSlotIndex,
                operation.slotIndex,
                hotbarCategory
            )
        elseif operation.operationType == "simple" then
            ok, callResult = pcall(
                CallSecureProtected,
                "SelectSlotSimpleAction",
                operation.actionType,
                operation.actionId,
                operation.slotIndex,
                hotbarCategory
            )
        else
            ok, callResult = false, "quickslot_operation_type_invalid"
        end

        if ok and callResult ~= false then
            result.applied = result.applied + 1
        else
            result.failed = result.failed + 1
            result.errors[#result.errors + 1] = {
                slotIndex = operation.slotIndex,
                reason = tostring(callResult),
            }
        end

        if type(zo_callLater) == "function" then
            zo_callLater(function()
                runOperation(index + 1)
            end, APPLY_DELAY_MS)
        else
            runOperation(index + 1)
        end
    end

    runOperation(1)
    return true, "deferred"
end
