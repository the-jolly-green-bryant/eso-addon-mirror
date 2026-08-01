local Addon = EBPixartLiveStats

Addon.Session = Addon.Session or {}

local Session = Addon.Session
local UPDATE_INTERVAL_MS = 500

local currentSession = {
    active = false,
    sessionStartAt = 0,
    lastDamageAt = 0,
    lastHealingAt = 0,
    lastRelevantActivityAt = 0,
}

local function GetNow()
    return tonumber(GetFrameTimeMilliseconds and GetFrameTimeMilliseconds()) or 0
end

local function CloneHealBreakdownEntries(entries)
    local snapshotEntries = {}

    for _, entry in ipairs(entries or {}) do
        if (tonumber(entry.totalHeal) or 0) > 0 then
            snapshotEntries[#snapshotEntries + 1] = {
                abilityId = entry.abilityId,
                displayName = entry.displayName,
                iconTexture = entry.icon,
                total = tonumber(entry.totalHeal) or 0,
            }
        end
    end

    return snapshotEntries
end

function Session:ResetCurrentState()
    currentSession.active = false
    currentSession.sessionStartAt = 0
    currentSession.lastDamageAt = 0
    currentSession.lastHealingAt = 0
    currentSession.lastRelevantActivityAt = 0
end

function Session:Initialize()
    self:ResetCurrentState()

    EVENT_MANAGER:UnregisterForUpdate(Addon.sessionEventNamespace)
    EVENT_MANAGER:RegisterForUpdate(Addon.sessionEventNamespace, UPDATE_INTERVAL_MS, function()
        self:CheckAutoReset()
    end)
end

function Session:HandlePlayerActivated()
    self:ResetCurrentState()
end

function Session:IsActive()
    return currentSession.active == true
end

function Session:HasRelevantActivity()
    return self:IsActive() and (tonumber(currentSession.lastRelevantActivityAt) or 0) > 0
end

function Session:GetAutoResetDelayMs()
    local delaySeconds = tonumber(Addon.sv and Addon.sv.autoResetDelaySeconds) or tonumber(Addon.defaults.autoResetDelaySeconds) or 10
    return zo_clamp(delaySeconds, 5, 60) * 1000
end

function Session:MarkRelevantActivity(kind)
    local now = GetNow()

    if currentSession.active ~= true then
        currentSession.active = true
        currentSession.sessionStartAt = now
    elseif (tonumber(currentSession.sessionStartAt) or 0) <= 0 then
        currentSession.sessionStartAt = now
    end

    currentSession.lastRelevantActivityAt = now

    if kind == "damage" then
        currentSession.lastDamageAt = now
    elseif kind == "healing" then
        currentSession.lastHealingAt = now
    end
end

function Session:NotifyDamageActivity()
    self:MarkRelevantActivity("damage")
end

function Session:NotifyHealingActivity()
    self:MarkRelevantActivity("healing")
end

function Session:BuildSnapshot(resetReason)
    if not self:HasRelevantActivity() then
        return nil
    end

    local totals = (Addon.Combat and Addon.Combat.GetCurrentTotals and Addon.Combat:GetCurrentTotals()) or {}
    local rawBreakdown = (Addon.Combat and Addon.Combat.GetHealingBreakdown and Addon.Combat:GetHealingBreakdown()) or { entries = {} }
    local totalDamage = tonumber(totals.totalDamage) or 0
    local totalHealing = tonumber(totals.sessionHealingTotal or totals.totalHealing) or 0
    local hadDamage = totalDamage > 0
    local hadHealing = totalHealing > 0

    if not hadDamage and not hadHealing then
        return nil
    end

    local startedAt = tonumber(currentSession.sessionStartAt) or 0
    local endedAt = tonumber(currentSession.lastRelevantActivityAt) or GetNow()
    local durationMs = zo_max(endedAt - startedAt, 0)
    local dpsExact = 0

    if hadDamage and Addon.sv and Addon.sv.stats then
        local combatStartAt = tonumber(Addon.sv.stats.combatStartAt) or 0
        local combatEndAt = tonumber(Addon.sv.stats.lastCombatEndAt) or endedAt
        local combatDurationMs = combatEndAt - combatStartAt

        if combatStartAt > 0 and combatDurationMs > 0 then
            dpsExact = totalDamage / zo_max(combatDurationMs / 1000, 0.001)
        end
    end

    local sessionType = "damage_and_heal"
    if hadDamage and not hadHealing then
        sessionType = "damage_only"
    elseif hadHealing and not hadDamage then
        sessionType = "heal_only"
    end

    return {
        startedAt = startedAt,
        endedAt = endedAt,
        durationMs = durationMs,
        totalDamage = totalDamage,
        totalHealing = totalHealing,
        dpsExact = dpsExact,
        hadDamage = hadDamage,
        hadHealing = hadHealing,
        resetReason = resetReason or "auto_timeout",
        sessionType = sessionType,
        healBreakdown = CloneHealBreakdownEntries(rawBreakdown.entries),
    }
end

function Session:SaveSnapshot(snapshot)
    if not snapshot or not Addon.sv then
        return
    end

    Addon.sv.lastSessionSnapshot = snapshot
end

function Session:CreateSnapshot(resetReason)
    local snapshot = self:BuildSnapshot(resetReason)
    if snapshot then
        self:SaveSnapshot(snapshot)
    end

    return snapshot
end

function Session:ResetSessionState()
    if Addon.Combat and Addon.Combat.ResetTrackedSessionData then
        Addon.Combat:ResetTrackedSessionData()
    end

    self:ResetCurrentState()

    if Addon.RefreshUI then
        Addon:RefreshUI()
    end
end

function Session:PerformAutoReset()
    self:CreateSnapshot("auto_timeout")
    self:ResetSessionState()
end

function Session:ManualResetNow()
    local snapshot = self:CreateSnapshot("manual_reset")
    self:ResetSessionState()

    if snapshot then
        Addon:Print("Session snapshot saved and reset.")
    else
        Addon:Print("Session reset.")
    end
end

function Session:CheckAutoReset()
    if not Addon.sv or Addon.sv.autoResetEnabled ~= true then
        return
    end

    if not self:HasRelevantActivity() then
        return
    end

    local totals = Addon.Combat and Addon.Combat.GetCurrentTotals and Addon.Combat:GetCurrentTotals() or nil
    if totals and totals.inCombat == true then
        return
    end

    local inactivityMs = GetNow() - (tonumber(currentSession.lastRelevantActivityAt) or 0)
    if inactivityMs < self:GetAutoResetDelayMs() then
        return
    end

    self:PerformAutoReset()
end
