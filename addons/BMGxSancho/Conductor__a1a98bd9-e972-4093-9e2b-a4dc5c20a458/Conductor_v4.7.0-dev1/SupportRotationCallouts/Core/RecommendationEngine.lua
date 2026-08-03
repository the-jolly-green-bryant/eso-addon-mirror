local C = Conductor
local SRC = SupportRotationCallouts
C.RecommendationEngine = C.RecommendationEngine or {}
local Engine = C.RecommendationEngine

local function NowMs()
    return GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
end

local function Key(value)
    return string.upper(tostring(value or "")):gsub("[^A-Z0-9]+", "_")
end

local function Copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, item in pairs(value) do result[key] = Copy(item) end
    return result
end

local function IsLead()
    return SRC.saved and SRC.saved.displayRole == "lead"
end

local function Chat(text)
    if not IsLead() or not SRC.saved or SRC.saved.recommendationChatEnabled == false then return end
    if CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then
        CHAT_SYSTEM:AddMessage("|cFFD447Conductor|r " .. tostring(text))
    elseif d then
        d("Conductor " .. tostring(text))
    end
end

local LABELS = {
    HOLD_BURN = "HOLD BURN",
    RESUME_BURN = "RESUME BURN",
    USE_BACKUP = "USE BACKUP",
    RECOVER = "RECOVER",
    REAPPLY = "REAPPLY",
}

function Engine:BuildRecommendations(setup, players)
    local validation = C.AssignmentEngine:Validate(setup, players)
    local output = {}
    for _, responsibility in ipairs(validation.missing) do
        local alternatives = C.KnowledgeBase and C.KnowledgeBase:GetProvidersForEffect(responsibility.effectKey) or {}
        output[#output + 1] = { type="MISSING_REQUIRED", responsibility=responsibility, alternatives=alternatives }
    end
    for _, responsibility in ipairs(validation.recommended) do
        output[#output + 1] = {
            type="MISSING_RECOMMENDED", responsibility=responsibility,
            alternatives=C.KnowledgeBase and C.KnowledgeBase:GetProvidersForEffect(responsibility.effectKey) or {},
        }
    end
    return output, validation
end

function Engine:CanEmit(key, cooldownMs)
    key = Key(key)
    local now = NowMs()
    local previous = tonumber(self.cooldowns[key]) or 0
    if now - previous < (tonumber(cooldownMs) or 5000) then return false end
    self.cooldowns[key] = now
    return true
end

function Engine:Emit(data)
    if not SRC.saved or SRC.saved.recommendationEnabled == false then return nil end
    data = Copy(data or {})
    data.key = Key(data.key or data.type or "RECOMMENDATION")
    if not self:CanEmit(data.cooldownKey or data.key, data.cooldownMs) then return nil end
    data.label = data.label or LABELS[data.key] or data.key:gsub("_", " ")
    data.reason = tostring(data.reason or "")
    data.severity = Key(data.severity or "ADVISORY")
    data.createdAtMs = NowMs()
    data.expiresAtMs = data.createdAtMs + (tonumber(data.durationMs) or 5000)
    data.audiences = data.audiences or { "trial_lead", "support" }
    self.active[data.key] = data
    self.history[#self.history + 1] = data
    while #self.history > 40 do table.remove(self.history, 1) end

    if C.TimelineEngine and SRC.inCombat then
        data.timelineEventId = C.TimelineEngine:AddEvent({
            key=data.key,
            label=data.label,
            targetMs=data.createdAtMs + 100,
            lane=data.lane or "MECHANIC",
            audiences=data.audiences,
            assignedAccount=data.assignedAccount,
            displayAssignedText=data.displayAssignedText,
            isMechanic=true,
            recommendation=true,
            reason=data.reason,
            priority=data.severity == "CRITICAL" and 400 or (data.severity == "HIGH" and 300 or 200),
        })
    end
    if C.EventBus then C.EventBus:Publish("RAID_RECOMMENDATION_CREATED", { recommendation=data }) end
    return data
end

function Engine:Clear(key, reason)
    key = Key(key)
    local recommendation = self.active[key]
    if not recommendation then return false end
    self.active[key] = nil
    if C.EventBus then C.EventBus:Publish("RAID_RECOMMENDATION_CLEARED", { recommendation=recommendation, reason=reason }) end
    return true
end

function Engine:OnSequenceMissed(payload)
    local step = payload and payload.step
    if not step then return end
    local label = tostring(step.label or step.key or "support action")
    local assigned = tostring(step.assignedAccount or "")
    self:Emit({
        key="USE_BACKUP_" .. Key(step.key),
        label="USE BACKUP",
        reason=label .. " was not observed on time",
        severity="HIGH",
        cooldownMs=8000,
        assignedAccount=assigned,
        displayAssignedText=assigned ~= "" and assigned or nil,
        audiences={ "trial_lead", "support" },
    })
end

function Engine:OnInterrupted(payload)
    local interrupt = payload and payload.interrupt or {}
    self:Emit({
        key="HOLD_BURN",
        label="HOLD BURN",
        reason=interrupt.label or interrupt.reason or "Encounter recovery active",
        severity="CRITICAL",
        cooldownMs=3000,
        durationMs=7000,
        audiences={ "all" },
    })
end

function Engine:OnResumed(payload)
    self:Clear("HOLD_BURN", "sequence resumed")
    self:Emit({
        key="RESUME_BURN",
        label="RESUME BURN",
        reason=payload and payload.reason or "Encounter sequence recovered",
        severity="HIGH",
        cooldownMs=3000,
        durationMs=4500,
        audiences={ "all" },
    })
end

function Engine:OnRaidState(payload)
    local state = Key(payload and payload.state)
    if state == "RECOVERY" then
        self:OnInterrupted({ interrupt={ reason=payload and payload.reason or "Raid recovery" } })
    elseif state == "STABLE" and self.lastRaidState == "RECOVERY" then
        self:OnResumed({ reason="Raid stabilized" })
    end
    self.lastRaidState = state
end

function Engine:BuildPostPullFocus(report)
    if not report then return {} end
    local focus = {}
    local rotation = report.rotation or {}
    if rotation.health and rotation.health < 80 then
        focus[#focus + 1] = string.format("Rotation execution %d%% (%d missed)", rotation.health, rotation.missed or 0)
    end
    if report.synchronization and report.synchronization.score and report.synchronization.score < 80 then
        focus[#focus + 1] = string.format("Support synchronization %d%%", report.synchronization.score)
    end
    if report.burn and report.burn.score and report.burn.score < 80 then
        focus[#focus + 1] = string.format("Burn-window alignment %d%%", report.burn.score)
    end
    for _, effect in ipairs(report.effects or {}) do
        if #focus >= 4 then break end
        if effect.health and effect.health < 75 then
            focus[#focus + 1] = string.format("%s %d%% health", effect.name or effect.key, effect.health)
        end
    end
    return focus
end

function Engine:OnPostPull(payload)
    local report = payload and payload.report
    if not report then return end
    report.recommendations = self:BuildPostPullFocus(report)
    if IsLead() and SRC.saved and SRC.saved.recommendationChatEnabled ~= false and #report.recommendations > 0 then
        Chat("Next Pull Focus:")
        for index, text in ipairs(report.recommendations) do Chat(string.format("%d. %s", index, text)) end
    end
end

function Engine:MonitorBurnCoverage(now)
    if not SRC.inCombat or not SRC.PostPullAnalytics or SRC.PostPullAnalytics.raidState ~= "BURN" then
        self.missingSince = {}
        return
    end
    local tracker = SRC.CoverageTracker
    if not tracker or not tracker.effects then return end
    local required = { "MAJOR_FORCE", "MAJOR_SLAYER", "MAJOR_VULNERABILITY", "CRUSHER", "MAJOR_BRITTLE" }
    local nowSeconds = GetGameTimeSeconds and GetGameTimeSeconds() or 0
    for _, effectKey in ipairs(required) do
        local definition = tracker.effects[effectKey]
        if definition and tracker:IsEnabled(effectKey) then
            local active = false
            for _, data in pairs(tracker.active[effectKey] or {}) do
                if data.endTime and data.endTime > nowSeconds then active = true break end
            end
            if active then
                self.missingSince[effectKey] = nil
                self:Clear("REAPPLY_" .. effectKey, "effect restored")
            else
                self.missingSince[effectKey] = self.missingSince[effectKey] or now
                if now - self.missingSince[effectKey] >= 1500 then
                    self:Emit({
                        key="REAPPLY_" .. effectKey,
                        label="REAPPLY " .. tostring(definition.label or effectKey),
                        reason="Key burn effect is not currently observed",
                        severity="HIGH",
                        cooldownMs=7000,
                        durationMs=4500,
                        audiences={ "trial_lead", "support" },
                    })
                end
            end
        end
    end
end

function Engine:Update()
    if not SRC.saved or SRC.saved.enabled ~= true then return end
    if SRC.saved.recommendationEnabled == false then return end
    if not SRC.inCombat and next(self.active or {}) == nil then return end
    local now = NowMs()
    self:MonitorBurnCoverage(now)
    for key, recommendation in pairs(self.active) do
        if now >= (recommendation.expiresAtMs or now) then self:Clear(key, "expired") end
    end
end

function Engine:GetSnapshot()
    local active = {}
    for _, recommendation in pairs(self.active or {}) do active[#active + 1] = Copy(recommendation) end
    table.sort(active, function(a,b) return (a.createdAtMs or 0) > (b.createdAtMs or 0) end)
    return { active=active, history=Copy(self.history or {}), lastRaidState=self.lastRaidState }
end

function Engine:Initialize()
    if self.initialized then return end
    self.initialized = true
    self.active = {}
    self.history = {}
    self.cooldowns = {}
    self.missingSince = {}
    self.lastRaidState = "PREPARING"
    if EVENT_MANAGER then
        EVENT_MANAGER:RegisterForUpdate((SRC.name or "Conductor") .. "RecommendationEngine", 1000, function() Engine:Update() end)
    end
    if C.EventBus then
        C.EventBus:Subscribe("SEQUENCE_STEP_MISSED", self, function(payload) Engine:OnSequenceMissed(payload) end)
        C.EventBus:Subscribe("SEQUENCE_INTERRUPTED", self, function(payload) Engine:OnInterrupted(payload) end)
        C.EventBus:Subscribe("SEQUENCE_RESUMED", self, function(payload) Engine:OnResumed(payload) end)
        C.EventBus:Subscribe("RAID_STATE_CHANGED", self, function(payload) Engine:OnRaidState(payload) end)
        C.EventBus:Subscribe("POST_PULL_REPORT_READY", self, function(payload) Engine:OnPostPull(payload) end)
        C.EventBus:Subscribe("SEQUENCE_RESET", self, function() Engine.active = {} end)
    end
end
