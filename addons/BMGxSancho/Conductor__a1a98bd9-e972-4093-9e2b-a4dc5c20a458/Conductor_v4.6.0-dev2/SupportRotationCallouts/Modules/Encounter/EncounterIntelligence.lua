local SRC = SupportRotationCallouts
SRC.EncounterIntelligence = SRC.EncounterIntelligence or {}
local EI = SRC.EncounterIntelligence

EI.STATE_IDLE = "IDLE"
EI.STATE_TRASH = "TRASH"
EI.STATE_HOLD = "HOLD"
EI.STATE_READY = "READY"
EI.STATE_COUNTDOWN = "COUNTDOWN"
EI.STATE_SEQUENCE = "SEQUENCE"
EI.STATE_RECOVERY = "RECOVERY"

local function Now() return GetGameTimeSeconds() end
local function Normalize(value) return zo_strlower(zo_strtrim(zo_strformat("<<1>>", value or ""))) end

function EI:Initialize()
    self.state = self.STATE_IDLE
    self.trial = nil
    self.zoneName = ""
    self.bossName = ""
    self.rule = nil
    self.encounterStartedAt = nil
    self.lastBurnAt = nil
    self.nextBurnAt = nil
    self.blockedUntil = nil
    self.sequenceToken = 0
    self.challengeBannerDetected = false
    self:RefreshZone()

    EVENT_MANAGER:RegisterForUpdate(SRC.name .. "EncounterIntelligence", 250, function() EI:Update() end)
    if EVENT_OBJECTIVE_UPDATED then
        EVENT_MANAGER:RegisterForEvent(SRC.name .. "EncounterObjective", EVENT_OBJECTIVE_UPDATED, function(...)
            EI:OnObjectiveUpdated(...)
        end)
    end
end

function EI:RefreshZone()
    self.trial, self.zoneName = SRC.TrialRegistry:GetCurrentTrial()
    self.challengeBannerDetected = false
    if SRC.Diagnostics then
        SRC.Diagnostics:AddFields("ENCOUNTER_INTELLIGENCE", "Zone evaluated", {
            zone = self.zoneName,
            trial = self.trial and self.trial.code or "NONE",
        })
    end
end

function EI:GetDifficulty()
    local active = SRC.Profiles and SRC.Profiles:GetActive() or nil
    local configured = active and active.difficulty or SRC.saved.profileDraftDifficulty or "veteran"
    if configured == "hardmode" or self.challengeBannerDetected then return "hardmode" end

    -- The group leader selects Normal or Veteran before entry. Use the live
    -- instance difficulty when the API is available, then fall back to the
    -- active Raid Setup for compatibility across console API revisions.
    if GetCurrentZoneDungeonDifficulty then
        local liveDifficulty = GetCurrentZoneDungeonDifficulty()
        if DUNGEON_DIFFICULTY_NORMAL and liveDifficulty == DUNGEON_DIFFICULTY_NORMAL then return "normal" end
        if DUNGEON_DIFFICULTY_VETERAN and liveDifficulty == DUNGEON_DIFFICULTY_VETERAN then return "veteran" end
    end
    if IsVeteranDifficulty and IsVeteranDifficulty() then return "veteran" end
    return configured == "normal" and "normal" or "veteran"
end

function EI:OnObjectiveUpdated(...)
    if not self.trial or SRC.inCombat then return end
    local difficulty = self:GetDifficulty()
    if difficulty == "hardmode" then
        self.challengeBannerDetected = true
        if SRC.Diagnostics then
            SRC.Diagnostics:AddFields("ENCOUNTER_INTELLIGENCE", "Challenge objective update observed", {
                zone = self.zoneName,
                selectedDifficulty = difficulty,
            })
        end
    end
end

function EI:GetActiveBossName()
    for index = 1, 12 do
        local tag = "boss" .. tostring(index)
        if DoesUnitExist(tag) and not IsUnitDead(tag) then
            local name = zo_strtrim(zo_strformat("<<1>>", GetUnitName(tag) or ""))
            if name ~= "" then return name end
        end
    end
    return ""
end

function EI:OnBossEncounterStarted()
    if SRC.TrashRotation and SRC.TrashRotation.CancelForBoss then SRC.TrashRotation:CancelForBoss() end
    if SRC.saved.encounterIntelligenceEnabled ~= true or not self.trial then return end
    self.bossName = self:GetActiveBossName()
    self.rule = SRC.TrialRegistry:GetBossRule(self.trial, self.bossName, self:GetDifficulty())
    self.encounterStartedAt = Now()
    self.lastBurnAt = nil
    self.nextBurnAt = self.encounterStartedAt + (tonumber(self.rule.openingDelay) or 5)
    self.blockedUntil = nil
    self.state = self.STATE_READY
    self:LogDecision("Boss encounter started", "READY")
end

function EI:OnBossEncounterEnded(reason)
    self.sequenceToken = self.sequenceToken + 1
    self.state = self.STATE_IDLE
    self.bossName = ""
    self.rule = nil
    self.encounterStartedAt = nil
    self.nextBurnAt = nil
    self.blockedUntil = nil
    self:LogDecision("Boss encounter ended", tostring(reason or "unknown"))
end

function EI:OnCombatStateChanged(inCombat)
    if SRC.EncounterEngine then
        if SRC.EncounterEngine:IsTrashActive() then
            self.state = self.STATE_TRASH
        elseif not inCombat and not SRC.bossEncounterActive then
            self.state = self.STATE_IDLE
        end
        return
    end

    -- Legacy fallback retained for packages that load Encounter Intelligence
    -- without the v3.2 Encounter Engine.
    if not self.trial or SRC.saved.encounterIntelligenceEnabled ~= true then return end
    if inCombat then
        zo_callLater(function()
            if SRC.inCombat and not SRC.bossEncounterActive and SRC.TrashRotation then
                EI.state = EI.STATE_TRASH
                SRC.TrashRotation:OnTrashCombatStarted()
            end
        end, 600)
    elseif SRC.TrashRotation then
        SRC.TrashRotation:OnCombatEnded()
        if not SRC.bossEncounterActive then self.state = self.STATE_IDLE end
    end
end

function EI:ObserveMechanic(key, durationSeconds, blocksBurn)
    if not self.trial or not SRC.bossEncounterActive then return end
    if blocksBurn then
        local duration = zo_max(0, tonumber(durationSeconds) or 0)
        self.blockedUntil = zo_max(self.blockedUntil or 0, Now() + duration)
        self.state = self.STATE_HOLD
        if SRC.Display and SRC.Display.ShowSharedMessage then
            SRC.Display:ShowSharedMessage("HOLD ULTIMATES", 1800, "red")
        end
    end
    self:LogDecision("Mechanic observed", key or "UNKNOWN")
end

function EI:IsSequenceReady()
    return SRC.bossEncounterActive and SRC.inCombat and not (SRC.TrashRotation and SRC.TrashRotation.active) and self.trial ~= nil and self.rule ~= nil
end

function EI:GetSafeWindowSeconds()
    if self.blockedUntil and self.blockedUntil > Now() then return 0 end
    local cycle = tonumber(self.rule and self.rule.cycleSeconds) or 40
    if not self.lastBurnAt then return zo_max(12, cycle) end
    local elapsed = Now() - self.lastBurnAt
    return elapsed >= cycle and zo_max(12, cycle) or 0
end

function EI:ShouldStartBurn()
    if self.rule and self.rule.validationOnly == true then return false end
    if not self:IsSequenceReady() then return false end
    if self.state == self.STATE_COUNTDOWN or self.state == self.STATE_SEQUENCE then return false end
    if self.blockedUntil and self.blockedUntil > Now() then return false end
    if self.nextBurnAt and Now() < self.nextBurnAt then return false end
    local minimum = tonumber(SRC.saved.encounterMinimumBurnWindow) or tonumber(self.rule.minimumWindow) or 12
    return self:GetSafeWindowSeconds() >= minimum
end

function EI:LogDecision(message, decision)
    if not SRC.Diagnostics then return end
    SRC.Diagnostics:AddFields("ENCOUNTER_INTELLIGENCE", message, {
        trial = self.trial and self.trial.code or "NONE",
        zone = self.zoneName,
        boss = self.bossName,
        difficulty = self:GetDifficulty(),
        state = self.state,
        decision = decision,
        safeWindow = self.rule and self:GetSafeWindowSeconds() or 0,
        challengeBanner = self.challengeBannerDetected,
    })
end

function EI:CallStep(message, delayMs, token)
    zo_callLater(function()
        if EI.sequenceToken ~= token or not SRC.bossEncounterActive then return end
        SRC.Display:ShowSharedMessage(message, 1100, message == "DAMAGE ULTIMATES NOW" and "red" or "gold")
        EI:LogDecision("Burn sequence step", message)
    end, delayMs)
end

function EI:StartBurnSequence()
    self.state = self.STATE_COUNTDOWN
    self.sequenceToken = self.sequenceToken + 1
    local token = self.sequenceToken
    self:LogDecision("Burn sequence started", "BURN")

    local timeline = SRC.TimelineEngine
    local timelineStartMs = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
    if timeline then
        timeline:Start("burn sequence")
        timeline:AddEvent({ key="BURN", label="DPS BURN", targetMs=timelineStartMs + 5000, lane="RAID", audiences={"all"} })
    end

    for count = 5, 1, -1 do
        local elapsed = (5 - count) * 1000
        self:CallStep("BURN WINDOW IN " .. tostring(count), elapsed, token)
    end

    local cursor = 5000
    local function AddStep(enabled, message, delay, timelineKey, lane, audiences)
        if not enabled then return end
        EI:CallStep(message, cursor, token)
        if timeline then
            timeline:AddEvent({
                key = timelineKey or message,
                label = timelineKey or message,
                targetMs = timelineStartMs + cursor,
                lane = lane or "SUPPORT",
                audiences = audiences or { "trial_lead", "support" },
            })
        end
        cursor = cursor + (delay or 900)
    end

    AddStep(SRC.saved.majorSlayerEnabled == true, "SLAYERS", 1000, "MAJOR_SLAYER", "SUPPORT")
    AddStep(SRC.saved.warhornEnabled == true, "WARHORN", 850, "WARHORN", "SUPPORT")
    AddStep(SRC.saved.colossusEnabled == true, "COLOSSUS", 850, "COLOSSUS", "SUPPORT")
    cursor = cursor + 500
    AddStep(true, "DAMAGE ULTIMATES NOW", 1800, "BURN", "RAID", { "trial_lead", "dd" })
    AddStep(SRC.saved.pillagerEnabled == true, "PILLAGER", 1200, "PILLAGER", "SUPPORT")
    if SRC.saved.nazarayEnabled == true then AddStep(true, "WAIT FOR NAZ EXTEND", 900, "NAZARAY", "SUPPORT") end

    zo_callLater(function()
        if EI.sequenceToken ~= token then return end
        EI.state = EI.STATE_RECOVERY
        EI.lastBurnAt = Now()
        local cycle = tonumber(EI.rule and EI.rule.cycleSeconds) or tonumber(SRC.saved.encounterDefaultCycleSeconds) or 40
        EI.nextBurnAt = EI.lastBurnAt + cycle
        EI:LogDecision("Burn sequence completed", "RECOVERY")
        zo_callLater(function()
            if EI.sequenceToken == token and SRC.bossEncounterActive then EI.state = EI.STATE_READY end
        end, 2000)
    end, cursor + 200)
end

function EI:Update()
    -- v3.5: EncounterSequenceEngine is the authoritative producer for burn
    -- packages and Timeline events. Encounter Intelligence continues to feed
    -- encounter observations, but must not create a second parallel sequence.
    if SRC.EncounterSequenceEngine and SRC.EncounterSequenceEngine.state ~= SRC.EncounterSequenceEngine.STATE.IDLE then return end
    if SRC.saved.encounterIntelligenceEnabled ~= true then return end
    if not self.trial then return end

    if self.blockedUntil and self.blockedUntil > Now() then
        if self.state ~= self.STATE_HOLD then
            self.state = self.STATE_HOLD
            SRC.Display:ShowSharedMessage("HOLD ULTIMATES", 1500, "red")
            self:LogDecision("Burn held", "HOLD")
        end
        return
    elseif self.state == self.STATE_HOLD then
        self.blockedUntil = nil
        self.state = self.STATE_READY
        self.nextBurnAt = Now() + 1
    end

    if self:ShouldStartBurn() then self:StartBurnSequence() end
end
