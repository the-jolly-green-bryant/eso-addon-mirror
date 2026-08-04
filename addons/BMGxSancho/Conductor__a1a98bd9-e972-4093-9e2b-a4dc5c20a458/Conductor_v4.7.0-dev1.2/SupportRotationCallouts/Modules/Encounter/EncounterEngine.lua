local SRC = SupportRotationCallouts
SRC.EncounterEngine = SRC.EncounterEngine or {}
local Engine = SRC.EncounterEngine

Engine.MODE_INACTIVE = "INACTIVE"
Engine.MODE_TRANSITION = "TRANSITION"
Engine.MODE_TRASH = "TRASH"
Engine.MODE_BOSS = "BOSS"

local function NowMs()
    return GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
end

local function GetBossObservation()
    local names = {}
    local living = 0
    local lowestPercent = nil
    local highestPercent = nil
    for index = 1, 12 do
        local tag = "boss" .. tostring(index)
        if DoesUnitExist(tag) and not IsUnitDead(tag) then
            local name = zo_strtrim(zo_strformat("<<1>>", GetUnitName(tag) or ""))
            if name ~= "" then names[#names + 1] = name end
            living = living + 1
            if GetUnitPower and POWERTYPE_HEALTH then
                local current, maximum = GetUnitPower(tag, POWERTYPE_HEALTH)
                if maximum and maximum > 0 then
                    local percent = zo_clamp((current / maximum) * 100, 0, 100)
                    lowestPercent = lowestPercent and zo_min(lowestPercent, percent) or percent
                    highestPercent = highestPercent and zo_max(highestPercent, percent) or percent
                end
            end
        end
    end
    table.sort(names)
    local band = lowestPercent and (zo_floor(lowestPercent / 10) * 10) or nil
    return names, living, lowestPercent, highestPercent, band
end

function Engine:Initialize()
    self.mode = self.MODE_INACTIVE
    self.previousMode = nil
    self.transitionReason = "INITIALIZED"
    self.revision = 0
    self.context = {
        zoneName = "",
        trial = nil,
        encounter = nil,
        bossName = "",
        difficulty = "veteran",
        startedAtMs = nil,
        bossAvailable = false,
    }
    if SRC.EncounterStateEngine and SRC.EncounterStateEngine.Initialize then
        SRC.EncounterStateEngine:Initialize()
    end
    self:RefreshZone("initialize")
    self:PublishSnapshot("initialized")
end

function Engine:RefreshZone(reason)
    local zoneName = GetUnitZone and GetUnitZone("player") or ""
    local trial = SRC.EncounterProfiles and SRC.EncounterProfiles:GetTrial(zoneName) or nil
    self.context.zoneName = zo_strtrim(zo_strformat("<<1>>", zoneName or ""))
    self.context.trial = trial
    self.context.encounter = nil
    self.context.bossName = ""
    self.context.bossAvailable = false
    self.context.startedAtMs = nil
    if SRC.EncounterIntelligence and SRC.EncounterIntelligence.RefreshZone then
        SRC.EncounterIntelligence:RefreshZone()
    end
    if SRC.EncounterStateEngine then SRC.EncounterStateEngine:Reset(reason or "zone refreshed") end
    self:Transition(self.MODE_INACTIVE, reason or "zone refreshed", true)
end

function Engine:GetDifficulty()
    if SRC.EncounterIntelligence and SRC.EncounterIntelligence.GetDifficulty then
        return SRC.EncounterIntelligence:GetDifficulty()
    end
    return "veteran"
end

function Engine:GetBossName()
    if SRC.EncounterIntelligence and SRC.EncounterIntelligence.GetActiveBossName then
        return SRC.EncounterIntelligence:GetActiveBossName()
    end
    return ""
end

function Engine:Transition(nextMode, reason, force)
    if not force and self.mode == nextMode then return false end
    local oldMode = self.mode
    self.previousMode = oldMode
    self.mode = nextMode
    self.transitionReason = tostring(reason or "unspecified")
    self.revision = (tonumber(self.revision) or 0) + 1

    if SRC.Diagnostics then
        SRC.Diagnostics:AddFields("ENCOUNTER_ENGINE", "Mode transition", {
            from = oldMode or "NONE",
            to = nextMode,
            reason = self.transitionReason,
            revision = self.revision,
            trial = self.context.trial and self.context.trial.code or "NONE",
            encounter = self.context.encounter and self.context.encounter.id or "NONE",
        })
    end

    if Conductor and Conductor.RuntimeContext then
        Conductor.RuntimeContext:SetMode(nextMode, self.transitionReason)
        Conductor.RuntimeContext:Patch("encounter", {
            id=self.context.encounter and self.context.encounter.id or nil,
            state=(SRC.EncounterStateEngine and SRC.EncounterStateEngine.state) or nextMode,
            boss=self.context.bossName,
            difficulty=self.context.difficulty,
        }, self.transitionReason)
    end
    if SRC.EventBus then
        SRC.EventBus:Publish("ENCOUNTER_MODE_CHANGED", self:GetSnapshot())
    end
    return true
end

function Engine:EnterTransition(reason)
    self:Transition(self.MODE_TRANSITION, reason)
end

function Engine:EnterTrash(reason)
    if SRC.bossEncounterActive then return false end
    self.context.encounter = nil
    self.context.bossName = ""
    self.context.bossAvailable = false
    self.context.startedAtMs = NowMs()
    self:Transition(self.MODE_TRASH, reason or "trash combat")
    if SRC.TrashRotation then SRC.TrashRotation:OnTrashCombatStarted() end
    return true
end

function Engine:EnterBoss(reason)
    self:EnterTransition("boss detected")
    if SRC.TrashRotation then SRC.TrashRotation:CancelForBoss() end

    local bossName = self:GetBossName()
    local difficulty = self:GetDifficulty()
    local encounter = SRC.EncounterProfiles and SRC.EncounterProfiles:GetEncounter(self.context.trial, bossName, difficulty) or nil
    self.context.bossName = bossName
    self.context.difficulty = difficulty
    self.context.encounter = encounter
    self.context.startedAtMs = NowMs()
    self.context.bossAvailable = true

    self:Transition(self.MODE_BOSS, reason or "boss encounter started")
    if SRC.EncounterStateEngine then SRC.EncounterStateEngine:OnBossStarted(encounter) end
    if SRC.EncounterSequenceEngine then SRC.EncounterSequenceEngine:Start(encounter, reason or "boss encounter started") end
    if SRC.EncounterObservationEngine then SRC.EncounterObservationEngine:Start(encounter) end
    if SRC.EncounterIntelligence then SRC.EncounterIntelligence:OnBossEncounterStarted() end
    return true
end

function Engine:SetBossAvailable(available, reason)
    if self.mode ~= self.MODE_BOSS then return end
    self.context.bossAvailable = available == true
    if SRC.EncounterStateEngine then SRC.EncounterStateEngine:OnBossAvailabilityChanged(self.context.bossAvailable) end
    self.revision = (tonumber(self.revision) or 0) + 1
    if SRC.EventBus then
        SRC.EventBus:Publish("ENCOUNTER_BOSS_AVAILABILITY_CHANGED", self:GetSnapshot())
    end
    if SRC.Diagnostics then
        SRC.Diagnostics:AddFields("ENCOUNTER_ENGINE", "Boss availability changed", {
            available = self.context.bossAvailable,
            reason = tostring(reason or "unspecified"),
            boss = self.context.bossName,
        })
    end
end

function Engine:ExitBoss(reason)
    if self.mode ~= self.MODE_BOSS and self.mode ~= self.MODE_TRANSITION then return false end
    self:EnterTransition(reason or "boss ending")
    if SRC.EncounterStateEngine then SRC.EncounterStateEngine:OnBossEnded(reason) end
    if SRC.EncounterSequenceEngine then SRC.EncounterSequenceEngine:Reset(reason or "boss encounter ended") end
    if SRC.EncounterObservationEngine then SRC.EncounterObservationEngine:Reset(reason or "boss encounter ended") end
    if SRC.EncounterIntelligence then SRC.EncounterIntelligence:OnBossEncounterEnded(reason) end
    self.context.encounter = nil
    self.context.bossName = ""
    self.context.bossAvailable = false
    self.context.startedAtMs = nil
    self:Transition(self.MODE_INACTIVE, reason or "boss ended")
    return true
end

function Engine:OnCombatStateChanged(inCombat)
    if SRC.EncounterStateEngine and SRC.EncounterStateEngine.OnCombatStateChanged then
        SRC.EncounterStateEngine:OnCombatStateChanged(inCombat)
    end
    if not self.context.trial or SRC.saved.encounterIntelligenceEnabled ~= true then
        if not inCombat and SRC.TrashRotation then SRC.TrashRotation:OnCombatEnded() end
        return
    end

    if inCombat then
        zo_callLater(function()
            if SRC.inCombat and not SRC.bossEncounterActive and Engine.mode ~= Engine.MODE_BOSS then
                Engine:EnterTrash("non-boss combat")
            end
        end, 600)
    else
        if self.mode == self.MODE_TRASH and SRC.TrashRotation then SRC.TrashRotation:OnCombatEnded() end
        if not SRC.bossEncounterActive then self:Transition(self.MODE_INACTIVE, "combat ended") end
    end

    if SRC.EncounterIntelligence then SRC.EncounterIntelligence:OnCombatStateChanged(inCombat) end
end

function Engine:ObserveMechanic(key, durationSeconds, blocksBurn)
    if self.mode ~= self.MODE_BOSS then return false end
    if SRC.EncounterStateEngine then
        SRC.EncounterStateEngine:OnMechanicObserved(key, durationSeconds, blocksBurn)
    end
    if SRC.EventBus then
        SRC.EventBus:Publish("ENCOUNTER_MECHANIC_OBSERVED", {
            key = key,
            durationSeconds = durationSeconds,
            blocksBurn = blocksBurn == true,
            encounter = self.context.encounter,
            revision = self.revision,
        })
    end
    if SRC.EncounterIntelligence then
        SRC.EncounterIntelligence:ObserveMechanic(key, durationSeconds, blocksBurn)
    end
    return true
end

function Engine:GetObjective()
    local active = SRC.Profiles and SRC.Profiles.GetActive and SRC.Profiles:GetActive() or nil
    local objective = active and (active.objective or active.raidObjective) or nil
    objective = objective or (SRC.saved and SRC.saved.profileDraftObjective) or "learning_veteran"
    return tostring(objective)
end

function Engine:GetExecutionContext()
    local snapshot = self:GetSnapshot()
    if SRC.EncounterStateEngine and SRC.EncounterStateEngine.GetExecutionContext then
        return SRC.EncounterStateEngine:GetExecutionContext(snapshot)
    end
    return snapshot
end

function Engine:GetSnapshot()
    local bossNames, bossCount, lowestBossHealth, highestBossHealth, healthBand = GetBossObservation()
    return {
        mode = self.mode,
        previousMode = self.previousMode,
        reason = self.transitionReason,
        revision = self.revision,
        zoneName = self.context.zoneName,
        trialId = self.context.trial and self.context.trial.id or nil,
        trialCode = self.context.trial and self.context.trial.code or nil,
        encounterId = self.context.encounter and self.context.encounter.id or nil,
        encounterLabel = self.context.encounter and self.context.encounter.label or nil,
        bossName = self.context.bossName,
        difficulty = self.context.difficulty,
        bossAvailable = self.context.bossAvailable,
        startedAtMs = self.context.startedAtMs,
        bossNames = bossNames,
        bossCount = bossCount,
        lowestBossHealth = lowestBossHealth,
        highestBossHealth = highestBossHealth,
        healthBand = healthBand,
        objective = self:GetObjective(),
        encounterState = SRC.EncounterStateEngine and SRC.EncounterStateEngine.state or "INACTIVE",
        stateRevision = SRC.EncounterStateEngine and SRC.EncounterStateEngine.revision or 0,
        validationOnly = self.context.encounter and self.context.encounter.validationOnly == true or false,
    }
end

function Engine:PublishSnapshot(reason)
    if SRC.EventBus then
        local snapshot = self:GetSnapshot()
        snapshot.publishReason = reason
        SRC.EventBus:Publish("ENCOUNTER_SNAPSHOT", snapshot)
    end
end

function Engine:IsTrashActive()
    return self.mode == self.MODE_TRASH
end

function Engine:IsBossActive()
    return self.mode == self.MODE_BOSS
end
