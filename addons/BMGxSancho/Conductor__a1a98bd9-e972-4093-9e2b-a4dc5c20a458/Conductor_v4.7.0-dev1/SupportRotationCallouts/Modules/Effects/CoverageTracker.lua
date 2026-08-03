local SRC = SupportRotationCallouts
SRC.CoverageTracker = SRC.CoverageTracker or {}
local Tracker = SRC.CoverageTracker

local EVENT_NAME = SRC.name .. "UniversalCoverageEffects"
local UPDATE_NAME = SRC.name .. "UniversalCoverageUpdate"

local function NormalizeText(value)
    return zo_strlower(zo_strtrim(zo_strformat("<<1>>", tostring(value or ""))))
end

local function GroupTargetCount()
    local size = tonumber(GetGroupSize()) or 0
    return math.max(1, size)
end

local function ResolveAccount(unitTag, unitName)
    if unitTag and unitTag ~= "" and DoesUnitExist(unitTag) then
        local account = SRC:NormalizeAccountName(GetUnitDisplayName(unitTag) or "")
        if account ~= "" then return account end
    end
    if SRC.Roster and SRC.Roster.GetAccountFromCharacter then
        local account = SRC.Roster:GetAccountFromCharacter(unitName)
        if account and account ~= "" then return SRC:NormalizeAccountName(account) end
    end
    return ""
end

local function TargetKey(unitTag, unitId, unitName)
    local account = ResolveAccount(unitTag, unitName)
    if account ~= "" then return account, account end
    if unitId and unitId ~= 0 then return "unit:" .. tostring(unitId), unitName end
    local name = NormalizeText(unitName)
    if name ~= "" then return "name:" .. name, unitName end
    return nil, nil
end

function Tracker:BuildDefinitions()
    self.effects = {}
    self.names = {}

    if not Conductor or not Conductor.Registry then return end
    for _, effect in ipairs(Conductor.Registry:GetAll("EFFECTS") or {}) do
        -- Major Slayer has a specialist runtime module because it also owns
        -- coordinated provider assignments. Avoid two competing runtime paths.
        if (effect.effectType == "BUFF" or effect.effectType == "DEBUFF") and effect.key ~= "MAJOR_SLAYER" then
            local definition = {
                key = effect.key,
                label = effect.name or effect.key,
                effectType = effect.effectType,
                dashboardMode = effect.dashboardMode or "COUNT",
                showMissingPlayers = effect.showMissingPlayers == true,
                missingPlayerWindow = tonumber(effect.missingPlayerWindow) or 0,
            }
            self.effects[definition.key] = definition
            self.names[NormalizeText(definition.label)] = definition.key
        end
    end
end

function Tracker:IsEnabled(key)
    return Conductor
        and Conductor.TrackingConfiguration
        and Conductor.TrackingConfiguration:IsEffectEnabled(key) == true
end

function Tracker:GetDefinitionByName(effectName)
    local key = self.names and self.names[NormalizeText(effectName)] or nil
    return key, key and self.effects[key] or nil
end

function Tracker:ClearEffect(key)
    self.active[key] = {}
    self.lastAbilityIds[key] = nil
    self.missingVisibleUntil[key] = nil
    if SRC.Display then SRC.Display:ClearBuffDebuffState(key) end
end

function Tracker:OnEffectChanged(changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    local key, definition = self:GetDefinitionByName(effectName)
    if not definition or not self:IsEnabled(key) then return end

    if SRC.CombatContextEngine then
        local allowed, reason = SRC.CombatContextEngine:CanTrackEffect(definition, unitTag, unitId, unitName)
        if not allowed then
            if SRC.Diagnostics and SRC.Diagnostics.AddFields and changeType ~= EFFECT_RESULT_FADED then
                SRC.Diagnostics:AddFields("EFFECT_CONTEXT", "Ignored effect outside active context", {
                    key = key,
                    effectName = effectName,
                    effectType = definition.effectType,
                    unitTag = unitTag,
                    unitName = unitName,
                    unitId = unitId,
                    reason = reason,
                })
            end
            return
        end
    end

    local targetKey, displayTarget = TargetKey(unitTag, unitId, unitName)
    if not targetKey then return end

    self.active[key] = self.active[key] or {}
    local now = GetGameTimeSeconds()
    if changeType == EFFECT_RESULT_FADED or not endTime or endTime <= now then
        self.active[key][targetKey] = nil
    else
        local hadActiveCoverage = false
        for _, data in pairs(self.active[key]) do
            if data.endTime and data.endTime > now then
                hadActiveCoverage = true
                break
            end
        end
        local prior = self.active[key][targetKey]
        local duration = math.max(0, (tonumber(endTime) or 0) - (tonumber(beginTime) or 0))
        if duration <= 0 and prior then duration = tonumber(prior.duration) or 0 end
        self.active[key][targetKey] = {
            endTime = endTime,
            beginTime = beginTime,
            duration = duration,
            unitTag = unitTag,
            unitName = displayTarget or unitName,
            account = ResolveAccount(unitTag, unitName),
            abilityId = abilityId,
            sourceType = sourceType,
        }
        if definition.showMissingPlayers and not hadActiveCoverage then
            self.missingVisibleUntil[key] = now + math.max(0, definition.missingPlayerWindow)
        end
        if abilityId and abilityId ~= 0 and self.lastAbilityIds[key] ~= abilityId then
            self.lastAbilityIds[key] = abilityId
            if SRC.Diagnostics and SRC.Diagnostics.AddFields then
                SRC.Diagnostics:AddFields("EFFECT_DISCOVERY", "Dashboard effect identified", {
                    key = key,
                    effectName = effectName,
                    abilityId = abilityId,
                    target = displayTarget or unitName,
                })
            end
        end
    end
    self:RefreshEffect(key)
end

function Tracker:RefreshEffect(key)
    local definition = self.effects and self.effects[key] or nil
    if not definition then return end
    if not self:IsEnabled(key) then self:ClearEffect(key); return end

    local now = GetGameTimeSeconds()
    local active = self.active[key] or {}
    for targetKey, data in pairs(active) do
        if not data.endTime or data.endTime <= now then active[targetKey] = nil end
    end

    local coverage = SRC.EffectUtilities:GetCoverageSnapshot(active, now)
    local remaining = coverage.remaining
    local targetName = nil
    for _, data in pairs(active) do
        if data.endTime == coverage.maxEnd then
            targetName = data.account ~= "" and data.account or data.unitName
            break
        end
    end

    if definition.dashboardMode == "TIMER" then
        local timerPercent = 0
        if remaining > 0 then
            if coverage.maxDuration > 0 then
                timerPercent = zo_clamp((remaining / coverage.maxDuration) * 100, 0, 100)
            else
                timerPercent = 100
            end
        end
        local showCoverage = definition.effectType == "BUFF"
        SRC.Display:UpdateBuffDebuffState(key, {
            label = definition.label,
            account = targetName or (definition.effectType == "DEBUFF" and "NO TARGET" or "NO PLAYER"),
            statusText = remaining > 0 and string.format("%.1f", remaining) or "DOWN",
            remaining = remaining > 0 and remaining or nil,
            active = remaining > 0,
            percent = timerPercent,
            showCoverage = showCoverage,
            covered = showCoverage and coverage.covered or nil,
            target = showCoverage and coverage.target or nil,
            missingPlayers = showCoverage and definition.showMissingPlayers
                and self.missingVisibleUntil[key] and now <= self.missingVisibleUntil[key]
                and coverage.missingPlayers or nil,
            showMissingPlayers = definition.showMissingPlayers
                and self.missingVisibleUntil[key] and now <= self.missingVisibleUntil[key] or false,
        })
        return
    end

    local full = coverage.covered >= coverage.target and remaining > 0
    SRC.Display:UpdateBuffDebuffState(key, {
        label = definition.label,
        account = tostring(coverage.covered) .. "/" .. tostring(coverage.target) .. " COVERED",
        statusText = remaining > 0 and string.format("%.1f", remaining) or "DOWN",
        remaining = remaining > 0 and remaining or nil,
        active = full,
        percent = coverage.target > 0 and math.floor((coverage.covered / coverage.target) * 100 + 0.5) or 0,
        showCoverage = true,
        covered = coverage.covered,
        target = coverage.target,
        missingPlayers = definition.showMissingPlayers
            and self.missingVisibleUntil[key] and now <= self.missingVisibleUntil[key]
            and coverage.missingPlayers or nil,
        showMissingPlayers = definition.showMissingPlayers
            and self.missingVisibleUntil[key] and now <= self.missingVisibleUntil[key] or false,
    })
end


function Tracker:OnCombatContextChanged(previousMode, nextMode)
    if previousMode == nextMode then return end
    for key, definition in pairs(self.effects or {}) do
        if definition.effectType == "DEBUFF" then
            self:ClearEffect(key)
        end
    end
end

function Tracker:RefreshAll()
    if not SRC.saved or SRC.saved.enabled ~= true then return end
    if not self.effects then self:BuildDefinitions() end
    for key in pairs(self.effects or {}) do self:RefreshEffect(key) end
end

function Tracker:Initialize()
    if self.initialized then return end
    self.initialized = true
    self.active = {}
    self.lastAbilityIds = {}
    self.missingVisibleUntil = {}
    self:BuildDefinitions()
    for key in pairs(self.effects or {}) do self.active[key] = {} end

    EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_EFFECT_CHANGED, function(_, ...)
        Tracker:OnEffectChanged(...)
    end)
    EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, 1000, function() Tracker:RefreshAll() end)
    if SRC.Diagnostics and SRC.Diagnostics.AddFields then
        local count = 0
        for _ in pairs(self.effects or {}) do count = count + 1 end
        SRC.Diagnostics:AddFields("EFFECT_ENGINE", "Universal dashboard effect tracker registered", { effects = count })
    end
end
