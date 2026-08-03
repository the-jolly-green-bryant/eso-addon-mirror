local C = Conductor
local SRC = SupportRotationCallouts
SRC.AsylumSanctorium = SRC.AsylumSanctorium or {}
C.AsylumSanctorium = SRC.AsylumSanctorium
local AS = SRC.AsylumSanctorium

local function NowMs() return GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0 end
local function Normalize(value) return zo_strlower(zo_strtrim(zo_strformat("<<1>>", value or ""))) end
local function IsProtectorName(value) return Normalize(value):find("ordinated protector", 1, true) ~= nil end
local function IsLlothisName(value) return Normalize(value):find("saint llothis", 1, true) ~= nil end
local function IsFelmsName(value) return Normalize(value):find("saint felms", 1, true) ~= nil end
local function IsDeathResult(result)
    return (ACTION_RESULT_DIED and result == ACTION_RESULT_DIED)
        or (ACTION_RESULT_DIED_XP and result == ACTION_RESULT_DIED_XP)
end

function AS:IsActive()
    local observer = SRC.EncounterObservationEngine
    return observer and observer.active and observer.profile and observer.profile.id == "ENCOUNTER_AS_OLMS"
end

function AS:PublishSignal(key, label, options)
    if not self:IsActive() then return end
    options = options or {}
    local payload = {
        key=key, label=label, durationSeconds=options.durationSeconds or 0,
        blocksBurn=options.blocksBurn == true, sourceConfidence=options.confidence or "reference_addon",
        detectedAtMs=NowMs(), sourceName=options.sourceName, targetName=options.targetName,
    }
    if SRC.EncounterSequenceEngine then SRC.EncounterSequenceEngine:ObserveTrigger("SIGNAL", key, payload) end
    if options.state and SRC.EncounterStateEngine then SRC.EncounterStateEngine:SetState(options.state, "vAS+2 " .. key) end
    if C.EventBus then
        C.EventBus:Publish("ENCOUNTER_SIGNAL_OBSERVED", payload)
        if payload.blocksBurn then C.EventBus:Publish("ENCOUNTER_MECHANIC_OBSERVED", payload) end
    end
end

function AS:AddTimelineEvent(id, key, label, targetMs, priority)
    if not C.TimelineEngine then return end
    C.TimelineEngine:AddEvent({
        id=id, key=key, label=label, targetMs=targetMs, lane="MECHANIC",
        audiences={"all","raid_aware"}, isMechanic=true, priority=priority or 30,
    })
end

function AS:OnProtectorSpawn(unitId, sourceName, targetName)
    local now = NowMs()
    if self.primaryProtectorActive then
        if unitId ~= 0 and unitId ~= self.primaryProtectorUnitId and now - (self.lastPenaltyAtMs or 0) > 3000 then
            self.lastPenaltyAtMs = now
            self:PublishSignal("PENALTY_PROTECTOR", "PENALTY PROTECTOR - BURN ADDS", {blocksBurn=true, durationSeconds=8})
        end
        return
    end
    self.primaryProtectorActive = true
    self.primaryProtectorUnitId = unitId or 0
    self.primaryProtectorSpawnAtMs = now
    self:PublishSignal("PROTECTOR_ACTIVE", "ORDINATED PROTECTOR - NO ULTIMATES", {blocksBurn=true, durationSeconds=90, state="MECHANIC", sourceName=sourceName, targetName=targetName})
    self:AddTimelineEvent("AS-PROTECTOR-75-"..now, "PROTECTOR_URGENT", "PROTECTOR URGENT", now + 75000, 40)
    self:AddTimelineEvent("AS-PROTECTOR-85-"..now, "PENALTY_SOON", "PENALTY PROTECTOR IN 5", now + 85000, 40)
    self:AddTimelineEvent("AS-PROTECTOR-90-"..now, "PENALTY_PROTECTOR", "PENALTY PROTECTOR", now + 90000, 40)
end

function AS:ClearProtectorInterrupt()
    local engine = SRC.EncounterSequenceEngine
    if not engine or type(engine.interruptStack) ~= "table" then return end
    local remaining = {}
    for _, interrupt in ipairs(engine.interruptStack) do
        if interrupt.key ~= "PROTECTOR_ACTIVE" then remaining[#remaining + 1] = interrupt end
    end
    engine.interruptStack = remaining
    if engine.state == engine.STATE.INTERRUPTED and #remaining == 0 then engine:Resume("Ordinated Protector destroyed") end
end

function AS:OnProtectorDeath(unitId)
    if not self.primaryProtectorActive then return end
    if self.primaryProtectorUnitId ~= 0 and unitId ~= 0 and unitId ~= self.primaryProtectorUnitId then return end
    local now = NowMs()
    self.primaryProtectorActive = false
    self.primaryProtectorUnitId = 0
    self.primaryProtectorSpawnAtMs = nil
    self:ClearProtectorInterrupt()
    self:PublishSignal("PROTECTOR_DEAD", "OLMS VULNERABLE - SHORT BURN", {durationSeconds=10, state="RECOVERY"})
    self:AddTimelineEvent("AS-NEXT-PROTECTOR-"..now, "NEXT_PROTECTOR", "NEXT PROTECTOR", now + 10000, 30)
end

function AS:OnCombatEvent(_, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    if not self:IsActive() then return end
    local now = NowMs()
    local normalizedAbility = Normalize(abilityName)
    if IsProtectorName(sourceName) or IsProtectorName(targetName)
        or normalizedAbility == "oppressive bolts"
        or normalizedAbility == "soul-stained corruption"
        or normalizedAbility == "soul stained corruption"
        or normalizedAbility == "storm the heavens"
        or normalizedAbility == "gusts of steam"
        or normalizedAbility == "trial by fire"
        or normalizedAbility == "teleport strike" then
        if SRC.Diagnostics and SRC.Diagnostics.AddFields then
            SRC.Diagnostics:AddFields("ENCOUNTER", "VAS2_EVENT", {
                abilityId=abilityId, abilityName=abilityName, result=result,
                source=sourceName, target=targetName, sourceUnitId=sourceUnitId, targetUnitId=targetUnitId,
            })
        end
    end
    if IsLlothisName(sourceName) and not self.llothisSeen then
        self.llothisSeen = true
        self:PublishSignal("LLOTHIS_ACTIVE", "LLOTHIS ACTIVE - WAIT FOR STACK", {durationSeconds=5})
    end
    if IsFelmsName(sourceName) and not self.felmsSeen then
        self.felmsSeen = true
        self:PublishSignal("FELMS_ACTIVE", "FELMS ACTIVE - WAIT FOR FULL STACK", {durationSeconds=5})
    end
    local protectorSource = IsProtectorName(sourceName)
    local protectorTarget = IsProtectorName(targetName)
    if protectorSource or protectorTarget then
        local unitId = protectorSource and tonumber(sourceUnitId or 0) or tonumber(targetUnitId or 0)
        if IsDeathResult(result) then
            self:OnProtectorDeath(unitId)
        elseif now - (self.lastProtectorEventAtMs or 0) > 2500 or (unitId ~= 0 and unitId ~= self.primaryProtectorUnitId) then
            self.lastProtectorEventAtMs = now
            self:OnProtectorSpawn(unitId, sourceName, targetName)
        end
    end
end

function AS:Reset()
    self.primaryProtectorActive=false
    self.primaryProtectorUnitId=0
    self.primaryProtectorSpawnAtMs=nil
    self.lastProtectorEventAtMs=0
    self.lastPenaltyAtMs=0
    self.llothisSeen=false
    self.felmsSeen=false
end

function AS:Initialize()
    self:Reset()
    local name=(SRC.name or "Conductor") .. "AsylumSanctorium"
    EVENT_MANAGER:RegisterForEvent(name, EVENT_COMBAT_EVENT, function(...) AS:OnCombatEvent(...) end)
    if C.EventBus then
        C.EventBus:Subscribe("ENCOUNTER_STARTED", self, function(payload)
            if payload and payload.profile and payload.profile.id == "ENCOUNTER_AS_OLMS" then AS:Reset() end
        end)
        C.EventBus:Subscribe("ENCOUNTER_ENDED", self, function() AS:Reset() end)
        C.EventBus:Subscribe("SEQUENCE_RESET", self, function() if not SRC.bossEncounterActive then AS:Reset() end end)
    end
end
