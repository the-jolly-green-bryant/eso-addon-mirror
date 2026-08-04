local SRC = SupportRotationCallouts
SRC.NazarayModule = SRC.NazarayModule or {}
local M = SRC.NazarayModule
local EVENT_NAME = SRC.name .. "NazarayEffects"

local function AccountAt(index)
    local account = SRC:NormalizeAccountName(SRC.saved.nazarayRotation[index] or "")
    if Conductor and Conductor.LiveSession then
        local resolved = Conductor.LiveSession:ResolveAccount(account, "NAZARAY")
        return resolved or ""
    end
    return account
end

local function AnyUltimateInfo(account)
    if SRC.GroupStats and SRC.GroupStats.GetAnyUltimateReadiness then
        return SRC.GroupStats:GetAnyUltimateReadiness(account)
    end
    return { state = SRC.GroupStats.UNKNOWN, percent = nil }
end

function M:GetAssignedPlayer()
    local count = zo_clamp(tonumber(SRC.saved.nazarayRotationCount) or 1, 1, 4)
    local first = ""
    for i = 1, count do
        local account = SRC:NormalizeAccountName(AccountAt(i))
        if account ~= "" then
            if first == "" then first = account end
            local info = AnyUltimateInfo(account)
            if info.state == SRC.GroupStats.READY then return account, info end
        end
    end
    if first ~= "" then return first, AnyUltimateInfo(first) end
    return "", { state = SRC.GroupStats.UNKNOWN }
end

function M:UpdateDashboard(remaining, urgent)
    if not SRC.saved.nazarayEnabled then
        SRC.Display:ClearModuleState("NAZARAY")
        return
    end
    local account, info = self:GetAssignedPlayer()
    local status
    if remaining and remaining > 0 then
        status = string.format("%.1f", remaining)
    elseif info.state == SRC.GroupStats.READY then
        status = "READY"
    elseif info.percent then
        status = tostring(info.percent) .. "%"
    else
        status = "WAIT"
    end
    SRC.Display:UpdateModuleState("NAZARAY", {
        label = "NAZ EXTEND",
        account = account,
        statusText = status,
        remaining = remaining,
        urgent = urgent == true,
        state = info.state,
        percent = info.percent,
        localAssigned = SRC:NormalizeAccountName(account) == SRC:NormalizeAccountName(GetDisplayName()),
    })
end

function M:OnTick(data, now)
    if not SRC.saved.nazarayEnabled then
        SRC.Display:ClearModuleState("NAZARAY")
        SRC.SupportEffectEngine:RemoveEffect("MAJOR_VULNERABILITY", data.unitId)
        return
    end
    local remaining = (data.endTime or 0) - now
    if remaining <= 0 then return end
    local urgent = remaining <= (SRC.Nazaray.WARNING_SECONDS or 2.0)
    if urgent or not self.lastDashboardAt or now - self.lastDashboardAt >= 0.5 then
        self.lastDashboardAt = now
        self:UpdateDashboard(urgent and remaining or nil, urgent)
    end
end

function M:OnEffectChanged(changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    if not SRC.saved.nazarayEnabled then
        SRC.Display:ClearModuleState("NAZARAY")
        return
    end
    local validHostileTarget = false
    if SRC.CombatContextEngine then
        validHostileTarget = SRC.CombatContextEngine:CanTrackHostileEffect(unitTag, unitId, unitName)
    else
        validHostileTarget = SRC:IsBossTarget(unitName, unitTag)
    end
    if abilityId == SRC.Nazaray.MAJOR_VULNERABILITY_ID and endTime and endTime > GetGameTimeSeconds() and validHostileTarget then
        local previous = SRC.SupportEffectEngine:GetEffect("MAJOR_VULNERABILITY", unitId)
        local previousEnd = previous and previous.endTime or nil
        local data = previous or { key = "MAJOR_VULNERABILITY", unitId = unitId, unitName = unitName }
        data.beginTime = beginTime
        data.endTime = endTime
        data.onTick = function(effectData, now) M:OnTick(effectData, now) end
        SRC.SupportEffectEngine:TrackEffect("MAJOR_VULNERABILITY", unitId, data)
        if previousEnd and endTime - previousEnd > 1.0 then
            SRC.Diagnostics:AddFields("NAZARAY", "Tracked debuff extended", { unitName = unitName, oldEnd = previousEnd, newEnd = endTime, deltaSeconds = endTime - previousEnd })
        end
    elseif abilityId == SRC.Nazaray.EFFECT_ID and changeType ~= EFFECT_RESULT_FADED and validHostileTarget then
        local account = self:GetAssignedPlayer()
        SRC.Diagnostics:AddFields("NAZARAY", "Nazaray proc confirmed", { abilityId = abilityId, unitName = unitName, unitId = unitId, endTime = endTime })
        SRC.Display:ShowModuleConfirmation("NAZARAY", account, "NAZ EXTEND", 1100)
        self:UpdateDashboard(nil, false)
    end
end

function M:HardReset(reason)
    self.lastDashboardAt = nil
    if SRC.Display then SRC.Display:ClearModuleState("NAZARAY") end
    if SRC.Diagnostics then SRC.Diagnostics:Add("NAZARAY", "Hard reset: " .. tostring(reason or "unspecified")) end
end

function M:Initialize()
    EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_EFFECT_CHANGED, function(_, ...) M:OnEffectChanged(...) end)
    self:UpdateDashboard(nil, false)
    SRC.Diagnostics:Add("NAZARAY", "Nazaray module registered")
end
