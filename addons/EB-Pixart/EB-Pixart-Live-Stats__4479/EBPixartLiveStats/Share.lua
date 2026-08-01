local Addon = EBPixartLiveStats

Addon.Share = Addon.Share or {}

local Share = Addon.Share
local MAX_HEAL_ENTRIES = 5

local function FormatNumber(value)
    local amount = tonumber(value) or 0

    if ZO_CommaDelimitNumber then
        return ZO_CommaDelimitNumber(zo_floor(amount + 0.5))
    end

    return tostring(zo_floor(amount + 0.5))
end

local function FormatDurationMs(durationMs)
    local seconds = zo_max(0, tonumber(durationMs) or 0) / 1000
    return string.format("%.1fs", seconds)
end

local function FormatDps(value)
    local amount = zo_max(0, tonumber(value) or 0)

    if amount < 1000 then
        return tostring(zo_floor(amount + 0.5))
    end

    if amount < 1000000 then
        local displayValue = amount / 1000
        if displayValue >= 100 then
            return string.format("%.0fK", displayValue)
        end

        return string.format("%.1fK", displayValue):gsub("%.0K$", "K")
    end

    local displayValue = amount / 1000000
    return string.format("%.1fM", displayValue):gsub("%.0M$", "M")
end

local function SendShareText(text)
    if not text or text == "" then
        return false
    end

    if type(StartChatInput) == "function" then
        StartChatInput(text)
        return true
    end

    d(text)
    return true
end

function Share:Initialize()
end

function Share:HasMeaningfulSnapshot(snapshot)
    if not snapshot then
        return false
    end

    return (tonumber(snapshot.totalDamage) or 0) > 0 or (tonumber(snapshot.totalHealing) or 0) > 0
end

function Share:BuildSessionSummary(snapshot)
    if not self:HasMeaningfulSnapshot(snapshot) then
        return nil
    end

    return string.format(
        "[EBPixart] Session %s | DPS %s | Degats %s | Heal %s",
        FormatDurationMs(snapshot.durationMs),
        FormatDps(snapshot.dpsExact),
        FormatNumber(snapshot.totalDamage),
        FormatNumber(snapshot.totalHealing)
    )
end

function Share:BuildHealSummary(entries)
    local segments = {}

    for index, entry in ipairs(entries or {}) do
        if index > MAX_HEAL_ENTRIES then
            break
        end

        local total = tonumber(entry.total or entry.totalHeal) or 0
        if total > 0 then
            segments[#segments + 1] = string.format("%s %s", tostring(entry.displayName or "Unknown"), FormatNumber(total))
        end
    end

    if #segments == 0 then
        return nil
    end

    return "[EBPixart][Heal] " .. table.concat(segments, " | ")
end

function Share:GetCurrentSessionSnapshot()
    if not Addon.Session or not Addon.Session.BuildSnapshot then
        return nil
    end

    return Addon.Session:BuildSnapshot("share_current")
end

function Share:GetCurrentHealEntries()
    if Addon.Combat and Addon.Combat.GetHealingBreakdown then
        local breakdown = Addon.Combat:GetHealingBreakdown()
        local entries = {}

        for _, entry in ipairs(breakdown.entries or {}) do
            entries[#entries + 1] = {
                abilityId = entry.abilityId,
                displayName = entry.displayName,
                iconTexture = entry.icon,
                total = entry.totalHeal,
            }
        end

        return entries
    end

    return {}
end

function Share:ShareCurrentSessionSummary()
    local snapshot = self:GetCurrentSessionSnapshot()
    local text = self:BuildSessionSummary(snapshot)

    if not text then
        Addon:Print("No current session data to share.")
        return
    end

    SendShareText(text)
end

function Share:ShareLastSnapshotSummary()
    local snapshot = Addon.sv and Addon.sv.lastSessionSnapshot or nil
    local text = self:BuildSessionSummary(snapshot)

    if not text then
        Addon:Print("No saved session snapshot to share.")
        return
    end

    SendShareText(text)
end

function Share:ShareCurrentHealSummary()
    local entries = self:GetCurrentHealEntries()
    local text = self:BuildHealSummary(entries)

    if not text then
        Addon:Print("No current heal breakdown to share.")
        return
    end

    SendShareText(text)
end

function Share:ShareLastSnapshotHealSummary()
    local snapshot = Addon.sv and Addon.sv.lastSessionSnapshot or nil
    local text = self:BuildHealSummary(snapshot and snapshot.healBreakdown or nil)

    if not text then
        Addon:Print("No saved heal breakdown to share.")
        return
    end

    SendShareText(text)
end
