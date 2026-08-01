local C = Conductor
local SRC = SupportRotationCallouts
C.TimelineEngine = C.TimelineEngine or {}
SRC.TimelineEngine = C.TimelineEngine
local Timeline = C.TimelineEngine

local function NowMs()
    return GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
end

local function Copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, item in pairs(value) do result[key] = Copy(item) end
    return result
end

local function Normalize(value)
    if SRC.NormalizeAccountName then return SRC:NormalizeAccountName(value or "") end
    return string.lower(tostring(value or ""))
end

local function LocalRole()
    local personal = C.PersonalSession and C.PersonalSession:GetActive()
    local role = personal and personal.role or (SRC.saved and SRC.saved.displayRole) or "lead"
    role = string.lower(tostring(role or "lead"))
    if role == "tank" or role == "healer" then return "support" end
    if role == "damage" or role == "dps" or role == "damage dealer" then return "dd" end
    return role
end

local function AudienceAllows(event)
    if type(event.audiences) ~= "table" or #event.audiences == 0 then return true end
    local role = LocalRole()
    local account = Normalize(GetDisplayName and GetDisplayName() or "")
    for _, audience in ipairs(event.audiences) do
        local value = string.lower(tostring(audience or ""))
        if value == "all" or value == role then return true end
        if value == "trial_lead" and role == "lead" then return true end
        if value == "damage_dealer" and role == "dd" then return true end
        if value == "assigned" and Normalize(event.assignedAccount) == account then return true end
    end
    return false
end


local function EventContextValid(event)
    if not C.LiveSession then return true end
    if not C.LiveSession:IsContextCurrent(event.sessionGeneration or 0, event.rosterFingerprint or "") then return false end
    -- Provider identity is optional. A missing or non-Conductor provider may
    -- reduce attribution, but it must never remove the encounter instruction.
    -- The Timeline remains useful by calling the effect or action itself.
    return true
end

local LABELS = {
    WARHORN = "Horn",
    HORN = "Horn",
    COLOSSUS = "Colossus",
    BARRIER = "Barrier",
    MAJOR_SLAYER = "Slayer",
    SLAYER = "Slayer",
    PILLAGER = "Pillager",
    NAZARAY = "Nazaray",
    BURN = "DPS BURN",
    EXECUTE = "Execute",
    RECOVERY = "Recovery",
    PORTAL = "Portal",
    STACK = "Stack",
    SPREAD = "Spread",
    HOLD_DPS = "Hold DPS",
    HOLD = "Hold",
    CONTROLLED_PUSH = "Controlled Push",
    SPAMMABLES_ONLY = "Spammables Only",
    PREPARE_BURN = "Prepare Burn",
    FULL_BURN = "Full Burn",
    DAMAGE_ULTIMATES = "DPS Ultimates",
    POWERFUL_ASSAULT = "Powerful Assault",
    MAJOR_BRITTLE = "Major Brittle",
    MINOR_BRITTLE = "Minor Brittle",
    RESUME = "Resume",
    TRASH_ULTIMATE = "Trash Ult",
    BOSS_ULTIMATE = "Boss Ult",
}

function Timeline:NormalizeLabel(value)
    local key = string.upper(tostring(value or "")):gsub("[^A-Z0-9]+", "_")
    return LABELS[key] or tostring(value or "Event")
end

function Timeline:Initialize()
    self.events = self.events or {}
    self.byId = self.byId or {}
    self.sequence = self.sequence or 0
    self.running = false
    self.preview = false
    self.originMs = 0
    self:RegisterEventBus()
    self:RegisterCombatEvents()
    self.updateName = (SRC.name or "Conductor") .. "TimelineAuthority"
    if EVENT_MANAGER and EVENT_MANAGER.RegisterForUpdate then
        EVENT_MANAGER:RegisterForUpdate(self.updateName, 100, function() Timeline:UpdateAuthority() end)
    end
    self.initialized = true
end

function Timeline:RegisterEventBus()
    if not C.EventBus then return end
    C.EventBus:Subscribe("PERSONAL_TIMELINE_INITIALIZED", self, function(payload)
        self:LoadPersonalTimeline(payload and payload.subscriptions or {})
    end)
    C.EventBus:Subscribe("PERSONAL_SESSION_CLEARED", self, function() self:Clear("personal session cleared") end)
    C.EventBus:Subscribe("RAID_SESSION_ARCHIVED", self, function() self:Clear("raid session archived") end)
    C.EventBus:Subscribe("ENCOUNTER_MODE_CHANGED", self, function(payload)
        local mode = payload and payload.mode
        if mode == "BOSS" or mode == "TRASH" then self:Start("encounter mode") end
    end)
    C.EventBus:Subscribe("ENCOUNTER_STATE_CHANGED", self, function(payload)
        local state = payload and (payload.state or payload.nextState)
        -- Encounter actors can disappear during portals, split phases, transitions,
        -- and invulnerability. Keep the Timeline alive for the lifetime of combat;
        -- only stop after the raid has actually left combat.
        if (state == "COMPLETE" or state == "INACTIVE") and not SRC.inCombat and not SRC.bossEncounterActive then
            self:Stop("encounter complete")
        end
    end)
end

function Timeline:RegisterCombatEvents()
    if not EVENT_MANAGER or not EVENT_COMBAT_EVENT then return end
    local eventName = (SRC.name or "Conductor") .. "TimelineCombat"
    EVENT_MANAGER:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, function(_, result, _, abilityName, _, _, sourceName, _, _, _, _, _, _, _, sourceUnitId, _, abilityId)
        if result ~= ACTION_RESULT_BEGIN and result ~= ACTION_RESULT_EFFECT_GAINED and result ~= ACTION_RESULT_EFFECT_GAINED_DURATION then return end
        if SRC.CombatContextEngine and not SRC.CombatContextEngine:CanTrackGroupCombatSource(sourceName, sourceUnitId) then return end
        self:ObserveAbility(abilityId, abilityName, sourceName)
    end)
end

function Timeline:Start(reason)
    if self.running then return end
    self.running = true
    self.originMs = NowMs()
    if C.EventBus then C.EventBus:Publish("TIMELINE_STARTED", { reason=reason, originMs=self.originMs }) end
end

function Timeline:Stop(reason)
    self.running = false
    if C.EventBus then C.EventBus:Publish("TIMELINE_STOPPED", { reason=reason }) end
end

function Timeline:Clear(reason)
    self.events = {}
    self.byId = {}
    self.sequence = 0
    self.preview = false
    self:Stop(reason)
    if C.EventBus then C.EventBus:Publish("TIMELINE_CLEARED", { reason=reason }) end
end

function Timeline:AddEvent(data)
    data = Copy(data or {})
    self.sequence = self.sequence + 1
    data.id = data.id or ("TL-" .. tostring(self.sequence))
    data.label = self:NormalizeLabel(data.label or data.key or data.responsibilityKey)
    data.key = string.upper(tostring(data.key or data.responsibilityKey or data.label)):gsub("[^A-Z0-9]+", "_")
    data.targetMs = tonumber(data.targetMs) or (NowMs() + math.floor((tonumber(data.offsetSeconds) or 0) * 1000))
    data.status = data.status or "PENDING"
    data.lane = data.lane or "RAID"
    data.sessionGeneration = C.RuntimeContext and C.RuntimeContext:GetGeneration() or (C.LiveSession and C.LiveSession:GetGeneration() or 0)
    data.rosterFingerprint = C.RuntimeContext and C.RuntimeContext:GetFingerprint() or (C.LiveSession and C.LiveSession:GetFingerprint() or "")
    data.sessionId = (C.RaidSession and C.RaidSession:GetActive() or {}).sessionId
    if EventContextValid(data) then
        self.events[#self.events + 1] = data
        self.byId[data.id] = data
        table.sort(self.events, function(a,b) return (a.targetMs or 0) < (b.targetMs or 0) end)
        if C.EventBus then C.EventBus:Publish("TIMELINE_EVENT_ADDED", { event=data }) end
    end
    return data.id
end

function Timeline:LoadPersonalTimeline(subscriptions)
    self.events = {}
    self.byId = {}
    local cursor = 5
    for _, subscription in ipairs(subscriptions or {}) do
        if subscription.enabled ~= false then
            self:AddEvent({
                key = subscription.key,
                label = subscription.label or subscription.key,
                offsetSeconds = tonumber(subscription.offsetSeconds) or cursor,
                lane = subscription.lane or "PERSONAL",
                assignedAccount = subscription.assignedAccount,
            })
            cursor = cursor + 8
        end
    end
end

function Timeline:FindPending(key, account)
    local normalizedKey = string.upper(tostring(key or "")):gsub("[^A-Z0-9]+", "_")
    local normalizedAccount = Normalize(account)
    local best, bestDistance
    local now = NowMs()
    for _, event in ipairs(self.events) do
        if event.status == "PENDING" and event.key == normalizedKey then
            local eventAccount = Normalize(event.assignedAccount)
            if normalizedAccount == "" or eventAccount == "" or eventAccount == normalizedAccount then
                local distance = math.abs((event.targetMs or now) - now)
                if not bestDistance or distance < bestDistance then best, bestDistance = event, distance end
            end
        end
    end
    return best
end

function Timeline:MarkExecuted(eventOrId, actualMs, sourceAccount)
    local event = type(eventOrId) == "table" and eventOrId or self.byId[eventOrId]
    if not event or event.status ~= "PENDING" then return false end
    actualMs = tonumber(actualMs) or NowMs()
    event.actualMs = actualMs
    event.deltaSeconds = (actualMs - (event.targetMs or actualMs)) / 1000
    local difference = math.abs(event.deltaSeconds)
    if difference <= 1.0 then event.accuracy = "GREEN"
    elseif difference <= 3.0 then event.accuracy = "YELLOW"
    else event.accuracy = "RED" end
    event.status = "EXECUTED"
    event.sourceAccount = Normalize(sourceAccount)
    if C.EventBus then C.EventBus:Publish("TIMELINE_EVENT_EXECUTED", { event=event }) end
    return true
end

function Timeline:ObserveAbility(abilityId, abilityName, sourceName)
    local key = nil
    if SRC.Warhorn and SRC.Warhorn.ABILITY_IDS and SRC.Warhorn.ABILITY_IDS[abilityId] then key = "WARHORN"
    elseif SRC.Barrier and SRC.Barrier.ABILITY_IDS and SRC.Barrier.ABILITY_IDS[abilityId] then key = "BARRIER"
    elseif SRC.Colossus and SRC.Colossus.ABILITY_IDS and SRC.Colossus.ABILITY_IDS[abilityId] then key = "COLOSSUS"
    elseif SRC.MajorSlayer and abilityId == SRC.MajorSlayer.EFFECT_ID then key = "MAJOR_SLAYER" end
    if not key then return end
    local event = self:FindPending(key, sourceName)
    if event then self:MarkExecuted(event, NowMs(), sourceName) end
end



local RAID_INSTRUCTION_KEYS = {
    BURN=true, FULL_BURN=true, EXECUTE=true, HOLD=true, HOLD_DPS=true,
    CONTROLLED_PUSH=true, SPAMMABLES_ONLY=true, PREPARE_BURN=true,
    RECOVERY=true, RESUME=true, PORTAL=true, STACK=true, SPREAD=true,
    DAMAGE_ULTIMATES=true, TRASH_ULTIMATE=true, BOSS_ULTIMATE=true,
}

function Timeline:DispatchCallout(event, stage)
    if not event or not SRC.Display or SRC.saved.calloutsEnabled == false then return end
    local label = tostring(event.label or self:NormalizeLabel(event.key))
    local account = tostring(event.assignedAccount or "")
    local localAccount = Normalize(GetDisplayName and GetDisplayName() or "")
    local assignedLocal = account ~= "" and Normalize(account) == localAccount
    local suffix = stage == "NOW" and "NOW" or "NEXT"
    local holdMs = stage == "NOW" and (SRC.saved.calloutHoldMs or 1200) or 1100

    -- Trial Lead callouts always survive missing ownership. When no provider is
    -- known, the effect/action itself is still announced instead of failing.
    if account ~= "" then
        SRC.Display:ShowRaidCallout(account, label, suffix, holdMs)
    else
        SRC.Display:ShowRaidCallout("", label, suffix, holdMs)
    end

    -- Personal delivery is added only when this client owns the step. The raid
    -- instruction is never dependent on personal delivery succeeding.
    if assignedLocal and SRC.Display.SetPersonal then
        SRC.Display:SetPersonal(account, stage == "NOW" and "YOUR TURN" or "YOU ARE NEXT", label, suffix, stage == "NOW", event.key)
    end

    -- Shared raid/DD instructions use the same Timeline event and therefore
    -- cannot drift from Trial Lead callouts.
    if RAID_INSTRUCTION_KEYS[event.key] and SRC.Display.ShowSharedMessage then
        SRC.Display:ShowSharedMessage(label .. " " .. suffix, holdMs, stage == "NOW" and "gold" or "white")
    end
end

function Timeline:UpdateAuthority()
    if not self.initialized or not self.running then return end
    local now = NowMs()
    for _, event in ipairs(self.events or {}) do
        if event.status == "PENDING" and EventContextValid(event) and AudienceAllows(event) then
            local delta = (event.targetMs or now) - now
            local leadMs = math.max(750, math.floor((tonumber(event.leadTimeSeconds) or 3) * 1000))
            if not event.prepareCalloutSent and delta <= leadMs and delta > 350 then
                event.prepareCalloutSent = true
                self:DispatchCallout(event, "NEXT")
                if C.EventBus then C.EventBus:Publish("TIMELINE_CALLOUT_PREPARE", {event=event}) end
            end
            if not event.nowCalloutSent and delta <= 350 and delta >= -900 then
                event.nowCalloutSent = true
                self:DispatchCallout(event, "NOW")
                if C.EventBus then C.EventBus:Publish("TIMELINE_CALLOUT_NOW", {event=event}) end
            end
        end
    end
end

function Timeline:GetPreparationEvents()
    local now = NowMs()
    local events = {}
    local supportReady, supportTotal, ddReady, ddTotal = 0, 0, 0, 0
    local session = C.RaidSession and C.RaidSession:GetActive() or nil

    local function Readiness(account)
        if not SRC.GroupStats or not SRC.GroupStats.GetAnyUltimateReadiness then return nil end
        return SRC.GroupStats:GetAnyUltimateReadiness(account)
    end

    for _, player in ipairs(session and session.players or {}) do
        local role = string.upper(tostring(player.combatRole or player.role or ""))
        local info = Readiness(player.accountName)
        local ready = info and info.state == SRC.GroupStats.READY
        if role == "TANK" or role == "HEALER" or role == "SUPPORT" then
            supportTotal = supportTotal + 1
            if ready then supportReady = supportReady + 1 end
        elseif role == "DD" or role == "DAMAGE" or role == "DPS" then
            ddTotal = ddTotal + 1
            if ready then ddReady = ddReady + 1 end
        end
    end

    if supportTotal == 0 and SRC.TrashRotation then
        local team = SRC.TrashRotation:FindNextEnabledTeam(SRC.TrashRotation.currentTeam or SRC.saved.trashCurrentTeam or 1)
        for _, account in ipairs(team and SRC.TrashRotation:GetTeamAccounts(team) or {}) do
            supportTotal = supportTotal + 1
            local info = Readiness(account)
            if info and info.state == SRC.GroupStats.READY then supportReady = supportReady + 1 end
        end
    end

    local supportText = supportTotal > 0 and string.format("%d/%d READY", supportReady, supportTotal) or "WAITING FOR ROSTER"
    local ddText = ddTotal > 0 and string.format("%d/%d READY", ddReady, ddTotal) or "ROSTER READINESS"
    events[1] = { id="PREP-SUPPORT", key="SUPPORT_READY", label="Supports", targetMs=now-5500, lane="SUPPORT", status="PENDING", displayAssignedText=supportText, accuracy=(supportTotal > 0 and supportReady == supportTotal) and "GREEN" or "YELLOW" }
    events[2] = { id="PREP-PULL", key="WAITING_FOR_PULL", label="Waiting for Pull", targetMs=now, lane="RAID", status="PENDING", accuracy="WHITE" }
    events[3] = { id="PREP-DD", key="DPS_READY", label="DPS", targetMs=now+5500, lane="RAID", status="PENDING", displayAssignedText=ddText, accuracy=(ddTotal > 0 and ddReady == ddTotal) and "GREEN" or "YELLOW" }
    return events
end

function Timeline:GetDisplayEvents(pastSeconds, futureSeconds)
    if not SRC.inCombat and not self.preview then
        return self:GetPreparationEvents(), "PREPARATION"
    end
    local mode = SRC.EncounterEngine and SRC.EncounterEngine.mode or nil
    return self:GetVisibleEvents(pastSeconds, futureSeconds), mode == "TRASH" and "TRASH" or "BOSS"
end

function Timeline:GetVisibleEvents(pastSeconds, futureSeconds)
    local now = NowMs()
    local pastMs = (tonumber(pastSeconds) or 12) * 1000
    local futureMs = (tonumber(futureSeconds) or 24) * 1000
    local visible = {}
    for _, event in ipairs(self.events) do
        if not EventContextValid(event) then
            event.status = "CANCELLED"
        else
        local delta = (event.targetMs or now) - now
        if AudienceAllows(event) and delta >= -pastMs and delta <= futureMs then
            if event.status == "PENDING" and delta < -3000 then
                event.status = "MISSED"
                event.accuracy = "RED"
                event.deltaSeconds = -delta / 1000
            end
            visible[#visible + 1] = event
        end
        end
    end
    return visible
end

function Timeline:Preview()
    self:Clear("preview")
    self.preview = true
    self:Start("preview")

    local now = NowMs()
    -- Events are spaced far enough apart to remain readable on the actual
    -- Timeline track. Later events enter from the right as earlier events pass
    -- through NOW, demonstrating the real right-to-left flow.
    local sequence = {
        { key="WARHORN", label="Warhorn", delay=4000, lane="SUPPORT", role="lead" },
        { key="MAJOR_SLAYER", label="Major Slayer", delay=10500, lane="SUPPORT", role="support" },
        { key="COLOSSUS", label="Colossus", delay=17000, lane="SUPPORT", role="support" },
        { key="MAJOR_BRITTLE", label="Major Brittle", delay=23500, lane="SUPPORT", role="support" },
        { key="EXECUTE", label="Execute", delay=30000, lane="RAID", role="dd" },
    }

    local ids = {}
    for index, item in ipairs(sequence) do
        ids[index] = self:AddEvent({
            key=item.key,
            label=item.label,
            targetMs=now + item.delay,
            lane=item.lane,
            assignedAccount=item.role == "support" and GetDisplayName() or nil,
            displayAssignedText=item.role == "support" and "SUPPORT" or "",
        })
        zo_callLater(function()
            if not Timeline.preview then return end
            Timeline:MarkExecuted(ids[index], now + item.delay)
            if SRC.Display then
                if item.role == "lead" and SRC.Display.PreviewLeadCallout then
                    SRC.Display:PreviewLeadCallout()
                elseif item.role == "support" and SRC.Display.PreviewPersonal then
                    SRC.Display:PreviewPersonal()
                elseif item.role == "dd" and SRC.Display.PreviewDamageDealerDashboard then
                    SRC.Display:PreviewDamageDealerDashboard()
                end
            end
        end, item.delay)
    end

    zo_callLater(function()
        if Timeline.preview then
            Timeline.preview = false
            Timeline:Stop("preview complete")
        end
    end, 34000)
end
