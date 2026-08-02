local SRC = SupportRotationCallouts
SRC.EncounterStateEngine = SRC.EncounterStateEngine or {}
local State = SRC.EncounterStateEngine

State.STATE_INACTIVE = "INACTIVE"
State.STATE_OPENING = "OPENING"
State.STATE_ACTIVE = "ACTIVE"
State.STATE_MECHANIC = "MECHANIC"
State.STATE_BURN = "BURN"
State.STATE_RECOVERY = "RECOVERY"
State.STATE_TRANSITION = "TRANSITION"
State.STATE_FINAL_BURN = "FINAL_BURN"
State.STATE_COMPLETE = "COMPLETE"

local function NowMs()
    return GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
end

local function Copy(source)
    local result = {}
    for key, value in pairs(source or {}) do result[key] = value end
    return result
end

local function ProfileNumber(profile, key, fallback)
    local value = profile and tonumber(profile[key]) or nil
    return value or fallback
end

function State:Initialize()
    self.state = self.STATE_INACTIVE
    self.previousState = nil
    self.reason = "initialized"
    self.changedAtMs = NowMs()
    self.encounterStartedAtMs = nil
    self.mechanicUntilMs = nil
    self.mechanicKey = nil
    self.profile = nil
    self.bossUnavailableSinceMs = nil
    self.recoveryUntilMs = nil
    self.combatEndedAtMs = nil
    self.revision = 0

    EVENT_MANAGER:RegisterForUpdate(SRC.name .. "EncounterStateEngine", 250, function()
        State:Update()
    end)
end

function State:Reset(reason)
    self.encounterStartedAtMs = nil
    self.mechanicUntilMs = nil
    self.mechanicKey = nil
    self.profile = nil
    self.bossUnavailableSinceMs = nil
    self.recoveryUntilMs = nil
    self.combatEndedAtMs = nil
    self:SetState(self.STATE_INACTIVE, reason or "reset", true)
end

function State:SetState(nextState, reason, force)
    if not force and self.state == nextState then return false end
    local oldState = self.state
    self.previousState = oldState
    self.state = nextState
    self.reason = tostring(reason or "unspecified")
    self.changedAtMs = NowMs()
    self.revision = (tonumber(self.revision) or 0) + 1

    local payload = self:GetSnapshot()
    if SRC.EventBus then SRC.EventBus:Publish("ENCOUNTER_STATE_CHANGED", payload) end
    if SRC.Diagnostics then
        SRC.Diagnostics:AddFields("ENCOUNTER_STATE", "State transition", {
            from = oldState or "NONE",
            to = nextState,
            reason = self.reason,
            revision = self.revision,
            profile = self.profile and self.profile.id or "NONE",
        })
    end

    -- Validation callouts exercise the DD callout surface without introducing
    -- recommendation or burn strategy. They are profile-controlled and only
    -- announce observed encounter states.
    if self.profile and self.profile.validationCallouts == true and SRC.Display and SRC.Display.ShowSharedMessage then
        local messages = {
            OPENING = { "ENCOUNTER OPENING", "gold", 1800 },
            MECHANIC = { "HOLD ULTIMATES - MECHANIC", "red", 1800 },
            TRANSITION = { "HOLD ULTIMATES - TRANSITION", "red", 1800 },
            RECOVERY = { "BOSS RETURNED - RECOVERY", "gold", 1800 },
            COMPLETE = { "ENCOUNTER COMPLETE", "green", 1800 },
        }
        local entry = messages[nextState]
        if entry then SRC.Display:ShowSharedMessage(entry[1], entry[3] or 1800, entry[2]) end
    end
    return true
end

function State:OnBossStarted(profile)
    self.profile = profile
    self.encounterStartedAtMs = NowMs()
    self.mechanicUntilMs = nil
    self.mechanicKey = nil
    self.bossUnavailableSinceMs = nil
    self.recoveryUntilMs = nil
    self.combatEndedAtMs = nil
    self:SetState(self.STATE_OPENING, "boss encounter started", true)
end

function State:OnBossAvailabilityChanged(available)
    if available == false then
        if not self.bossUnavailableSinceMs then self.bossUnavailableSinceMs = NowMs() end
        return
    end

    local wasUnavailable = self.bossUnavailableSinceMs ~= nil
    self.bossUnavailableSinceMs = nil
    if wasUnavailable or self.state == self.STATE_TRANSITION then
        local recoveryMs = ProfileNumber(self.profile, "recoveryDurationMs", 1500)
        self.recoveryUntilMs = NowMs() + recoveryMs
        self:SetState(self.STATE_RECOVERY, "boss returned")
    end
end

function State:OnMechanicObserved(key, durationSeconds, blocksBurn)
    self.mechanicKey = tostring(key or "UNKNOWN")
    local durationMs = zo_max(0, tonumber(durationSeconds) or 0) * 1000
    self.mechanicUntilMs = durationMs > 0 and (NowMs() + durationMs) or nil
    self:SetState(self.STATE_MECHANIC, blocksBurn and "blocking mechanic observed" or "mechanic observed")
end

function State:OnCombatStateChanged(inCombat)
    if inCombat then
        self.combatEndedAtMs = nil
    elseif self.state ~= self.STATE_INACTIVE and self.state ~= self.STATE_COMPLETE then
        self.combatEndedAtMs = NowMs()
    end
end

function State:OnBossEnded(reason)
    self.mechanicUntilMs = nil
    self.mechanicKey = nil
    self.bossUnavailableSinceMs = nil
    self.recoveryUntilMs = nil
    self.combatEndedAtMs = nil
    self:SetState(self.STATE_COMPLETE, reason or "boss encounter ended", true)
end

function State:Update()
    if not SRC.saved or SRC.saved.enabled ~= true then return end
    local now = NowMs()
    if self.bossUnavailableSinceMs and self.state ~= self.STATE_TRANSITION then
        local debounceMs = ProfileNumber(self.profile, "availabilityDebounceMs", 750)
        if now - self.bossUnavailableSinceMs >= debounceMs then
            self:SetState(self.STATE_TRANSITION, "boss unavailable")
        end
    end

    if self.state == self.STATE_OPENING and self.encounterStartedAtMs then
        local openingMs = ProfileNumber(self.profile, "openingDurationMs", 8000)
        if now - self.encounterStartedAtMs >= openingMs then
            self:SetState(self.STATE_ACTIVE, "opening observed")
        end
    elseif self.state == self.STATE_MECHANIC and self.mechanicUntilMs and now >= self.mechanicUntilMs then
        self.mechanicUntilMs = nil
        self.mechanicKey = nil
        self.recoveryUntilMs = now + ProfileNumber(self.profile, "recoveryDurationMs", 1500)
        self:SetState(self.STATE_RECOVERY, "mechanic duration completed")
    elseif self.state == self.STATE_RECOVERY and self.recoveryUntilMs and now >= self.recoveryUntilMs then
        self.recoveryUntilMs = nil
        self:SetState(self.STATE_ACTIVE, "recovery completed")
    elseif self.state == self.STATE_COMPLETE and now - (self.changedAtMs or 0) >= 1500 then
        self:Reset("completion published")
    end

    if self.combatEndedAtMs and self.state ~= self.STATE_COMPLETE and self.state ~= self.STATE_INACTIVE then
        local resetMs = ProfileNumber(self.profile, "combatEndResetMs", 1200)
        if now - self.combatEndedAtMs >= resetMs then
            self:Reset("combat ended")
        end
    end
end

function State:GetSnapshot()
    return {
        state = self.state,
        previousState = self.previousState,
        reason = self.reason,
        changedAtMs = self.changedAtMs,
        encounterStartedAtMs = self.encounterStartedAtMs,
        mechanicKey = self.mechanicKey,
        mechanicUntilMs = self.mechanicUntilMs,
        recoveryUntilMs = self.recoveryUntilMs,
        bossUnavailableSinceMs = self.bossUnavailableSinceMs,
        profileId = self.profile and self.profile.id or nil,
        profileVersion = self.profile and self.profile.profileVersion or nil,
        revision = self.revision,
    }
end

function State:GetExecutionContext(encounterSnapshot)
    local context = Copy(encounterSnapshot)
    local state = self:GetSnapshot()
    context.encounterState = state.state
    context.previousEncounterState = state.previousState
    context.stateReason = state.reason
    context.stateChangedAtMs = state.changedAtMs
    context.mechanicKey = state.mechanicKey
    context.stateRevision = state.revision
    context.encounterProfileId = state.profileId
    context.encounterProfileVersion = state.profileVersion
    return context
end
