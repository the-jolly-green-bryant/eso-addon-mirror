local SRC = SupportRotationCallouts
SRC.MajorSlayerModule = SRC.MajorSlayerModule or {}
local M = SRC.MajorSlayerModule
local EVENT_NAME = SRC.name .. "MajorSlayerEffects"

local function AddProviderNames(names, enabledKey, countKey, rotationKey)
    if not SRC.saved[enabledKey] then return end
    local count = math.min(2, math.max(1, SRC.saved[countKey] or 1))
    for position = 1, count do
        local account = SRC:NormalizeAccountName((SRC.saved[rotationKey] or {})[position] or "")
        if Conductor and Conductor.LiveSession then
            account = Conductor.LiveSession:ResolveAccount(account, "MAJOR_SLAYER") or ""
        end
        if account ~= "" then names[#names + 1] = account end
    end
end

function M:GetSimultaneousProviderNames()
    local names = {}
    AddProviderNames(names, "warMachineEnabled", "warMachineRotationCount", "warMachineRotation")
    AddProviderNames(names, "masterArchitectEnabled", "masterArchitectRotationCount", "masterArchitectRotation")
    -- The execution callout is intentionally limited to two names. The
    -- dashboard still confirms actual Major Slayer coverage for the group.
    while #names > 2 do table.remove(names) end
    return names
end

function M:GetNextProviderNames()
    local names = self:GetSimultaneousProviderNames()
    if #names > 0 then return table.concat(names, "|") end

    if SRC.saved.roaringOpportunistEnabled then
        local account = SRC:NormalizeAccountName((SRC.saved.roaringOpportunistRotation or {})[1] or "")
        if Conductor and Conductor.LiveSession then
            account = Conductor.LiveSession:ResolveAccount(account, "MAJOR_SLAYER") or ""
        end
        if account ~= "" then return account end
    end
    return "WAITING"
end

local function GetCoverageTarget()
    local size = tonumber(GetGroupSize()) or 0
    return math.max(1, size)
end

local function GetCoverageKey(unitTag, unitId, unitName)
    if unitTag and unitTag ~= "" and DoesUnitExist(unitTag) then
        local displayName = SRC:NormalizeAccountName(GetUnitDisplayName(unitTag) or "")
        if displayName ~= "" then return displayName end
    end
    if unitId and unitId ~= 0 then return "unit:" .. tostring(unitId) end
    return "name:" .. zo_strlower(zo_strtrim(unitName or "unknown"))
end

function M:RefreshDashboard()
    if not SRC.saved or SRC.saved.enabled ~= true then return end
    if not SRC.saved.majorSlayerEnabled then
        self.coverage = {}
        self.activeUntil = nil
        SRC.Display:ClearModuleState("SLAYER")
        if SRC.Display.ClearBuffDebuffState then SRC.Display:ClearBuffDebuffState("SLAYER_BUFF") end
        return
    end

    local now = GetGameTimeSeconds()
    for key, data in pairs(self.coverage or {}) do
        local endTime = type(data) == "table" and tonumber(data.endTime) or tonumber(data)
        if not endTime or endTime <= now then self.coverage[key] = nil end
    end
    local coverage = SRC.EffectUtilities:GetCoverageSnapshot(self.coverage, now)
    local covered = coverage.covered
    local target = coverage.target
    local remaining = coverage.remaining
    local active = covered > 0 and remaining > 0
    local account = self:GetNextProviderNames()
    local statusText = "WAIT"
    local followingStatusText = nil

    if active then
        account = tostring(covered) .. "/" .. tostring(target) .. " COVERED"
        statusText = string.format("%.1f", remaining)
        if covered >= target then
            followingStatusText = "FULL COVERAGE"
        elseif SRC.saved.roaringOpportunistEnabled and SRC.saved.roaringOpportunistAutomaticCoverage ~= false then
            followingStatusText = "HEAVY 2 NEEDED"
        end
    elseif SRC.saved.roaringOpportunistEnabled then
        followingStatusText = target <= 6 and "1 HEAVY" or "2 HEAVIES"
    end

    if SRC.Display and SRC.Display.UpdateBuffDebuffState then
        local timerPercent = 0
        if remaining > 0 and coverage.maxDuration > 0 then
            timerPercent = zo_clamp((remaining / coverage.maxDuration) * 100, 0, 100)
        end
        local showMissingPlayers = self.missingVisibleUntil and now <= self.missingVisibleUntil
        SRC.Display:UpdateBuffDebuffState("SLAYER_BUFF", {
            label = "MAJOR SLAYER",
            account = tostring(covered) .. "/" .. tostring(target),
            statusText = remaining > 0 and string.format("%.1fs", remaining) or "DOWN",
            remaining = remaining > 0 and remaining or nil,
            active = covered > 0 and remaining > 0,
            percent = timerPercent,
            showCoverage = true,
            covered = covered,
            target = target,
            missingPlayers = showMissingPlayers and coverage.missingPlayers or nil,
            showMissingPlayers = showMissingPlayers,
        })
    end

    local signature = table.concat({ tostring(covered), tostring(target), active and "1" or "0", account, followingStatusText or "" }, "|")
    if signature ~= self.lastDashboardSignature or active then
        self.lastDashboardSignature = signature
        SRC.Display:UpdateModuleState("SLAYER", {
            label = "SLAYER",
            account = account,
            statusText = statusText,
            remaining = active and remaining or nil,
            active = active,
            followingAccount = SRC.saved.roaringOpportunistEnabled and "ROJO COVERAGE" or nil,
            followingStatusText = followingStatusText,
            localAssigned = not active and SRC:NormalizeAccountName(account) == SRC:NormalizeAccountName(GetDisplayName()),
        })
    end
end

function M:ScheduleRefresh()
    self.refreshToken = (self.refreshToken or 0) + 1
    local token = self.refreshToken
    zo_callLater(function()
        if M.refreshToken == token then M:RefreshDashboard() end
    end, 350)
end

function M:OnEffectChanged(changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    if not SRC.saved.majorSlayerEnabled or abilityId ~= SRC.MajorSlayer.EFFECT_ID then return end
    if SRC.CombatContextEngine then
        local allowed = SRC.CombatContextEngine:CanTrackPlayerBuff(unitTag, unitId, unitName)
        if not allowed then return end
    end
    self.coverage = self.coverage or {}
    local key = GetCoverageKey(unitTag, unitId, unitName)
    local now = GetGameTimeSeconds()
    if changeType == EFFECT_RESULT_FADED or not endTime or endTime <= now then
        self.coverage[key] = nil
    else
        local hadActiveCoverage = false
        for _, data in pairs(self.coverage) do
            local existingEnd = type(data) == "table" and tonumber(data.endTime) or tonumber(data)
            if existingEnd and existingEnd > now then
                hadActiveCoverage = true
                break
            end
        end
        local duration = math.max(0, (tonumber(endTime) or 0) - (tonumber(beginTime) or 0))
        if duration <= 0 then duration = tonumber(self.lastDuration) or 0 end
        if duration > 0 then self.lastDuration = duration end
        self.coverage[key] = {
            endTime = endTime,
            beginTime = beginTime,
            duration = duration,
            account = string.sub(key, 1, 1) == "@" and key or nil,
            unitTag = unitTag,
            unitName = unitName,
        }
        if not hadActiveCoverage then
            local effect = Conductor and Conductor.Registry and Conductor.Registry:Get("EFFECTS", "MAJOR_SLAYER") or nil
            local window = effect and tonumber(effect.missingPlayerWindow) or 5
            self.missingVisibleUntil = now + math.max(0, window)
        end
        SRC.Diagnostics:AddFields("SLAYER", "Major Slayer observed", {
            coverageKey = key,
            unitTag = unitTag,
            unitName = unitName,
            unitId = unitId,
            endTime = endTime,
            remaining = endTime - GetGameTimeSeconds(),
        })
    end
    self:ScheduleRefresh()
end


function M:OnCombatContextChanged(previousMode, nextMode)
    -- Major Slayer is a player buff and remains visible outside combat.
    -- Only prune recipients that are no longer part of the local group.
    if not SRC.CombatContextEngine then return end
    for key, data in pairs(self.coverage or {}) do
        if not SRC.CombatContextEngine:IsGroupedPlayer(data.unitTag, nil, data.unitName) then
            self.coverage[key] = nil
        end
    end
    self:RefreshDashboard()
end

function M:HardReset(reason)
    self.coverage = {}
    self.activeUntil = nil
    self.missingVisibleUntil = nil
    self.lastDashboardSignature = nil
    if SRC.Display then
        SRC.Display:ClearModuleState("SLAYER")
        if SRC.Display.ClearBuffDebuffState then SRC.Display:ClearBuffDebuffState("SLAYER_BUFF") end
    end
    if SRC.Diagnostics then SRC.Diagnostics:Add("SLAYER", "Hard reset: " .. tostring(reason or "unspecified")) end
end

function M:Initialize()
    self.coverage = {}
    self.lastDashboardSignature = nil
    self.refreshToken = 0
    self.missingVisibleUntil = nil
    self.lastDuration = nil
    EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_EFFECT_CHANGED, function(_, ...) M:OnEffectChanged(...) end)
    EVENT_MANAGER:RegisterForUpdate(SRC.name .. "MajorSlayerUpdate", 500, function() M:RefreshDashboard() end)
    self:RefreshDashboard()
    SRC.Diagnostics:Add("SLAYER", "Slayer coordination and coverage module registered")
end
