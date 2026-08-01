local Addon = LarvalTearMod
local LTM_APPLY_COOLDOWN_GATE = Addon.Modules.ApplyCooldownGate
local SHARED_UTIL = Addon.Common.Util

local RESPEC_SHARED_COOLDOWN_MS = 10000

local function NormalizeGateKind(kind)
    if kind == "skill" or kind == "attribute" then
        return "respec_shared"
    end

    return nil
end

function LTM_APPLY_COOLDOWN_GATE:RecordMutation(kind, atMs)
    local gateKey = NormalizeGateKind(kind)
    if gateKey == nil then
        return false
    end

    self.state = self.state or {}
    self.state[gateKey] = type(atMs) == "number" and atMs or SHARED_UTIL:GetFrameTimeMillisecondsSafe()
    return true
end

function LTM_APPLY_COOLDOWN_GATE:GetRemainingDelayMs(kind, nowMs)
    local gateKey = NormalizeGateKind(kind)
    if gateKey == nil then
        return 0
    end

    local state = self.state or {}
    local lastMutationAt = state[gateKey]
    if type(lastMutationAt) ~= "number" then
        return 0
    end

    local currentTimeMs = type(nowMs) == "number" and nowMs or SHARED_UTIL:GetFrameTimeMillisecondsSafe()
    local remainingMs = RESPEC_SHARED_COOLDOWN_MS - (currentTimeMs - lastMutationAt)
    if remainingMs <= 0 then
        return 0
    end

    return remainingMs
end
