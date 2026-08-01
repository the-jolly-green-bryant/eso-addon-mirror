local C = Conductor
local SRC = SupportRotationCallouts
SRC.EncounterObservationEngine = SRC.EncounterObservationEngine or {}
C.EncounterObservationEngine = SRC.EncounterObservationEngine
local Observer = SRC.EncounterObservationEngine

local function NowMs()
    return GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
end

local function Key(value)
    return string.upper(tostring(value or "")):gsub("[^A-Z0-9]+", "_")
end

local function Normalize(value)
    return zo_strlower(zo_strtrim(zo_strformat("<<1>>", value or "")))
end

local function Copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, item in pairs(value) do result[key] = Copy(item) end
    return result
end

local function BossHealthPercent(unitTag)
    if not unitTag or not DoesUnitExist(unitTag) then return nil end
    local current, maximum = GetUnitPower(unitTag, POWERTYPE_HEALTH)
    current = tonumber(current)
    maximum = tonumber(maximum)
    if not current or not maximum or maximum <= 0 then return nil end
    return (current / maximum) * 100
end

function Observer:Initialize()
    self.active = false
    self.profile = nil
    self.lastHealth = {}
    self.firedHealthSignals = {}
    self.firedCombatSignals = {}
    self.lastBossAvailable = nil
    self.observationRevision = 0

    local prefix = (SRC.name or "Conductor") .. "EncounterObserver"
    EVENT_MANAGER:RegisterForEvent(prefix, EVENT_COMBAT_EVENT, function(...)
        Observer:OnCombatEvent(...)
    end)
    EVENT_MANAGER:RegisterForUpdate(prefix, 250, function()
        Observer:Update()
    end)

    if C.EventBus then
        C.EventBus:Subscribe("ENCOUNTER_STARTED", self, function(payload)
            Observer:Start(payload and payload.profile)
        end)
        C.EventBus:Subscribe("ENCOUNTER_ENDED", self, function(payload)
            Observer:Reset(payload and payload.reason or "encounter ended")
        end)
        C.EventBus:Subscribe("SEQUENCE_RESET", self, function(payload)
            if not SRC.bossEncounterActive then Observer:Reset(payload and payload.reason or "sequence reset") end
        end)
    end
end

function Observer:Start(profile)
    self.active = profile ~= nil
    self.profile = profile
    self.lastHealth = {}
    self.firedHealthSignals = {}
    self.firedCombatSignals = {}
    self.lastBossAvailable = nil
    self.observationRevision = self.observationRevision + 1
    self:Publish("ENCOUNTER_OBSERVER_STARTED", { profileId=profile and profile.id })
end

function Observer:Reset(reason)
    self.active = false
    self.profile = nil
    self.lastHealth = {}
    self.firedHealthSignals = {}
    self.firedCombatSignals = {}
    self.lastBossAvailable = nil
    self.observationRevision = self.observationRevision + 1
    self:Publish("ENCOUNTER_OBSERVER_RESET", { reason=reason })
end

function Observer:Publish(eventName, payload)
    payload = payload or {}
    payload.revision = self.observationRevision
    if C.EventBus then C.EventBus:Publish(eventName, payload) end
end

function Observer:GetSignals(signalType)
    local profile = self.profile or {}
    local signals = profile.observationSignals or profile.signals or {}
    return signals[signalType] or {}
end

function Observer:EmitSignal(signal, payload)
    if type(signal) ~= "table" then return false end
    local key = Key(signal.key or signal.id or signal.label)
    if key == "" then return false end

    local eventPayload = Copy(payload)
    eventPayload.key = key
    eventPayload.label = signal.label or key
    eventPayload.durationSeconds = tonumber(signal.durationSeconds) or 0
    eventPayload.blocksBurn = signal.blocksBurn == true
    eventPayload.phase = signal.phase
    eventPayload.sourceConfidence = signal.confidence or "live_observation"
    eventPayload.detectedAtMs = NowMs()

    if SRC.EncounterSequenceEngine then
        SRC.EncounterSequenceEngine:ObserveTrigger(signal.triggerType or "MECHANIC", key, eventPayload)
    end
    if SRC.EncounterStateEngine and signal.state then
        SRC.EncounterStateEngine:SetState(signal.state, "observed " .. key)
    elseif SRC.EncounterStateEngine and eventPayload.blocksBurn then
        SRC.EncounterStateEngine:OnMechanicObserved(key, eventPayload.durationSeconds, true)
    end
    self:Publish("ENCOUNTER_SIGNAL_OBSERVED", eventPayload)

    if eventPayload.blocksBurn and C.EventBus then
        C.EventBus:Publish("ENCOUNTER_MECHANIC_OBSERVED", eventPayload)
    end
    return true
end

function Observer:UpdateBossAvailability()
    local available = false
    for index = 1, 12 do
        local tag = "boss" .. tostring(index)
        if DoesUnitExist(tag) and not IsUnitDead(tag) then
            available = true
            break
        end
    end
    if self.lastBossAvailable == nil then
        self.lastBossAvailable = available
        return
    end
    if available ~= self.lastBossAvailable then
        self.lastBossAvailable = available
        if SRC.EncounterStateEngine then SRC.EncounterStateEngine:OnBossAvailabilityChanged(available) end
        if SRC.EncounterSequenceEngine then
            SRC.EncounterSequenceEngine:ObserveTrigger("BOSS_AVAILABILITY", available and "AVAILABLE" or "UNAVAILABLE", { available=available })
        end
        self:Publish("ENCOUNTER_BOSS_AVAILABILITY_CHANGED", { available=available })
    end
end

function Observer:UpdateHealthSignals()
    local signals = self:GetSignals("health")
    if #signals == 0 then return end
    for index = 1, 12 do
        local tag = "boss" .. tostring(index)
        local health = BossHealthPercent(tag)
        if health then
            local previous = self.lastHealth[tag] or 100
            self.lastHealth[tag] = health
            for _, signal in ipairs(signals) do
                local threshold = tonumber(signal.percent or signal.value)
                local id = tostring(signal.id or signal.key or threshold) .. ":" .. tag
                if threshold and not self.firedHealthSignals[id] and previous > threshold and health <= threshold then
                    self.firedHealthSignals[id] = true
                    self:EmitSignal(signal, {
                        triggerType="BOSS_HEALTH",
                        unitTag=tag,
                        previousHealth=previous,
                        health=health,
                        threshold=threshold,
                    })
                end
            end
        end
    end
end

function Observer:MatchesCombatSignal(signal, abilityName, abilityId, result)
    if signal.abilityId and tonumber(signal.abilityId) == tonumber(abilityId) then return true end
    if type(signal.abilityIds) == "table" then
        for _, id in ipairs(signal.abilityIds) do
            if tonumber(id) == tonumber(abilityId) then return true end
        end
    end
    local normalizedName = Normalize(abilityName)
    if signal.abilityName and normalizedName == Normalize(signal.abilityName) then return true end
    if type(signal.abilityNames) == "table" then
        for _, name in ipairs(signal.abilityNames) do
            if normalizedName == Normalize(name) then return true end
        end
    end
    if signal.result and tonumber(signal.result) ~= tonumber(result) then return false end
    return false
end

function Observer:OnCombatEvent(_, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    if not self.active or not SRC.bossEncounterActive then return end
    for _, signal in ipairs(self:GetSignals("combat")) do
        local unique = tostring(signal.id or signal.key or abilityId)
        if (signal.repeatable == true or not self.firedCombatSignals[unique]) and self:MatchesCombatSignal(signal, abilityName, abilityId, result) then
            if signal.repeatable ~= true then self.firedCombatSignals[unique] = true end
            self:EmitSignal(signal, {
                triggerType="ABILITY_CAST",
                abilityId=abilityId,
                abilityName=abilityName,
                result=result,
                sourceName=sourceName,
                targetName=targetName,
                sourceUnitId=sourceUnitId,
                targetUnitId=targetUnitId,
            })
        end
    end
end

function Observer:Update()
    if not self.active or not SRC.bossEncounterActive then return end
    self:UpdateBossAvailability()
    self:UpdateHealthSignals()
end

function Observer:GetSnapshot()
    local observedHealth = {}
    for tag, health in pairs(self.lastHealth) do observedHealth[tag] = health end
    return {
        active = self.active,
        profileId = self.profile and self.profile.id or nil,
        bossAvailable = self.lastBossAvailable,
        bossHealth = observedHealth,
        healthSignalCount = (function() local n=0 for _ in pairs(self.firedHealthSignals) do n=n+1 end return n end)(),
        combatSignalCount = (function() local n=0 for _ in pairs(self.firedCombatSignals) do n=n+1 end return n end)(),
        revision = self.observationRevision,
    }
end
