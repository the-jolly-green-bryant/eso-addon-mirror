-- ============================================================================
-- TEMPORARY DEVELOPMENT TOOL
--
-- Encounter validation for vDSR HM / vRG HM development.
-- Not intended for public release. Remove before Release Candidate unless
-- future debugging requires it.
-- ============================================================================

local SRC = SupportRotationCallouts
SRC.TemporaryEncounterDebug = SRC.TemporaryEncounterDebug or {}
local Debug = SRC.TemporaryEncounterDebug
local WM = WINDOW_MANAGER

Debug.MAX_EVENTS = 7
Debug.UPDATE_MS = 250

local function NowMs()
    return GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
end

local function FormatClock(ms)
    ms = tonumber(ms) or 0
    local totalSeconds = zo_floor(ms / 1000)
    local minutes = zo_floor(totalSeconds / 60) % 60
    local seconds = totalSeconds % 60
    local tenths = zo_floor((ms % 1000) / 100)
    return string.format("%02d:%02d.%d", minutes, seconds, tenths)
end

local function Join(values, separator)
    local result = {}
    for _, value in ipairs(values or {}) do
        if value and value ~= "" then result[#result + 1] = tostring(value) end
    end
    return table.concat(result, separator or ", ")
end

local function ClampDimensions(width, height)
    return zo_clamp(tonumber(width) or 450, 340, 760), zo_clamp(tonumber(height) or 270, 210, 560)
end

function Debug:AddEvent(category, text)
    if SRC.saved.temporaryEncounterDebugEnabled ~= true then return end
    self.events = self.events or {}
    self.events[#self.events + 1] = {
        at = NowMs(),
        category = tostring(category or "STATE"),
        text = tostring(text or ""),
    }
    while #self.events > self.MAX_EVENTS do table.remove(self.events, 1) end
    self:Refresh()
end

function Debug:SavePosition()
    if not self.window or not SRC.saved then return end
    local left = self.window:GetLeft() or 0
    local top = self.window:GetTop() or 0
    SRC.saved.temporaryEncounterDebugOffsetX = left
    SRC.saved.temporaryEncounterDebugOffsetY = top
    SRC.saved.temporaryEncounterDebugPositionSaved = true
end

function Debug:SaveDimensions()
    if not self.window or not SRC.saved then return end
    local width, height = ClampDimensions(self.window:GetWidth(), self.window:GetHeight())
    self.window:SetDimensions(width, height)
    SRC.saved.temporaryEncounterDebugWidth = width
    SRC.saved.temporaryEncounterDebugHeight = height
end

function Debug:CreateWindow()
    local width, height = ClampDimensions(SRC.saved.temporaryEncounterDebugWidth, SRC.saved.temporaryEncounterDebugHeight)
    local window = WM:CreateTopLevelWindow("ConductorTemporaryEncounterDebug")
    window:SetDimensions(width, height)
    if SRC.saved.temporaryEncounterDebugPositionSaved == true then
        window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, tonumber(SRC.saved.temporaryEncounterDebugOffsetX) or 30, tonumber(SRC.saved.temporaryEncounterDebugOffsetY) or 0)
    else
        window:SetAnchor(BOTTOMLEFT, GuiRoot, BOTTOMLEFT, 30, -40)
    end
    window:SetClampedToScreen(true)
    window:SetMouseEnabled(true)
    window:SetMovable(true)
    window:SetHidden(SRC.saved.temporaryEncounterDebugEnabled ~= true)
    window:SetHandler("OnMoveStop", function() Debug:SavePosition() end)
    window:SetHandler("OnResizeStop", function() Debug:SaveDimensions() end)

    local bg = WM:CreateControl(nil, window, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0, 0, 0, 0.78)
    bg:SetEdgeColor(0.85, 0.68, 0.20, 0.55)
    bg:SetEdgeTexture(nil, 2, 2, 2)

    local title = WM:CreateControl(nil, window, CT_LABEL)
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 10, 7)
    title:SetAnchor(TOPRIGHT, window, TOPRIGHT, -34, 7)
    title:SetFont("$(BOLD_FONT)|16|outline")
    title:SetText("CONDUCTOR DECISION DEBUG")

    local state = WM:CreateControl(nil, window, CT_LABEL)
    state:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 6)
    state:SetAnchor(TOPRIGHT, window, TOPRIGHT, -10, 31)
    state:SetFont("$(CHAT_FONT)|14|outline")
    state:SetVerticalAlignment(TEXT_ALIGN_TOP)
    state:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

    local divider = WM:CreateControl(nil, window, CT_TEXTURE)
    divider:SetAnchor(TOPLEFT, state, BOTTOMLEFT, 0, 6)
    divider:SetAnchor(TOPRIGHT, state, BOTTOMRIGHT, 0, 6)
    divider:SetHeight(1)
    divider:SetColor(1, 1, 1, 0.22)

    local events = WM:CreateControl(nil, window, CT_LABEL)
    events:SetAnchor(TOPLEFT, divider, BOTTOMLEFT, 0, 7)
    events:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -10, -10)
    events:SetFont("$(CHAT_FONT)|13|outline")
    events:SetVerticalAlignment(TEXT_ALIGN_TOP)
    events:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

    local resize = WM:CreateControl(nil, window, CT_TEXTURE)
    resize:SetDimensions(24, 24)
    resize:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -2, -2)
    resize:SetTexture("EsoUI/Art/Buttons/resize_handle.dds")
    resize:SetMouseEnabled(true)
    resize:SetHandler("OnMouseDown", function()
        if window.StartSizing and SIZING_BOTTOMRIGHT then window:StartSizing(SIZING_BOTTOMRIGHT) end
    end)
    resize:SetHandler("OnMouseUp", function()
        if window.StopMovingOrResizing then window:StopMovingOrResizing() end
        Debug:SaveDimensions()
    end)

    self.window = window
    self.stateLabel = state
    self.eventsLabel = events
end

function Debug:ResetPosition()
    if not self.window or not SRC.saved then return end
    self.window:ClearAnchors()
    self.window:SetAnchor(BOTTOMLEFT, GuiRoot, BOTTOMLEFT, 30, -40)
    SRC.saved.temporaryEncounterDebugPositionSaved = false
    SRC.saved.temporaryEncounterDebugOffsetX = 30
    SRC.saved.temporaryEncounterDebugOffsetY = 0
end

function Debug:SetEnabled(enabled)
    SRC.saved.temporaryEncounterDebugEnabled = enabled == true
    if self.window then self.window:SetHidden(not SRC.saved.temporaryEncounterDebugEnabled) end
    if enabled then
        self:AddEvent("INFO", "Temporary validation window enabled")
    end
end

function Debug:OnModeChanged(snapshot)
    self:AddEvent("STATE", string.format("Mode %s -> %s (%s)", tostring(snapshot.previousMode or "NONE"), tostring(snapshot.mode or "UNKNOWN"), tostring(snapshot.reason or "")))
end

function Debug:OnAvailabilityChanged(snapshot)
    self:AddEvent("STATE", snapshot.bossAvailable and "Boss unit available" or "Boss unit unavailable")
end

function Debug:OnMechanic(payload)
    self:AddEvent("MECH", string.format("%s%s", tostring(payload.key or "Mechanic"), payload.blocksBurn and " [HOLD]" or ""))
end

function Debug:UpdateObservation()
    if SRC.saved.temporaryEncounterDebugEnabled ~= true or not SRC.EncounterEngine then return end
    local snapshot = SRC.EncounterEngine:GetSnapshot()
    local signature = table.concat({
        tostring(snapshot.mode), tostring(snapshot.encounterId), tostring(snapshot.bossAvailable),
        tostring(snapshot.bossCount), tostring(snapshot.healthBand), Join(snapshot.bossNames, "|")
    }, ":")

    if self.lastSignature ~= signature then
        if self.lastEncounterId ~= snapshot.encounterId and snapshot.encounterId then
            self:AddEvent("BOSS", tostring(snapshot.encounterLabel or snapshot.bossName or snapshot.encounterId))
        end
        if self.lastBossCount ~= nil and self.lastBossCount ~= snapshot.bossCount then
            self:AddEvent("STATE", string.format("Living boss units: %d", tonumber(snapshot.bossCount) or 0))
        end
        if self.lastHealthBand ~= nil and snapshot.healthBand ~= nil and self.lastHealthBand ~= snapshot.healthBand then
            self:AddEvent("HP", string.format("Lowest boss entered %d-%d%% band", snapshot.healthBand, zo_min(100, snapshot.healthBand + 9)))
        end
        self.lastSignature = signature
        self.lastEncounterId = snapshot.encounterId
        self.lastBossCount = snapshot.bossCount
        self.lastHealthBand = snapshot.healthBand
    end
    self.snapshot = snapshot
    self:Refresh()
end

function Debug:Refresh()
    if not self.window or SRC.saved.temporaryEncounterDebugEnabled ~= true then return end
    local snapshot = self.snapshot or (SRC.EncounterEngine and SRC.EncounterEngine:GetSnapshot()) or {}
    local sequence = SRC.EncounterSequenceEngine and SRC.EncounterSequenceEngine:GetSnapshot() or {}
    local observer = SRC.EncounterObservationEngine and SRC.EncounterObservationEngine:GetSnapshot() or {}
    local encounter = snapshot.encounterLabel or snapshot.bossName or "No active boss"
    local trial = snapshot.trialCode or "NO TRIAL"
    local difficulty = string.upper(tostring(snapshot.difficulty or "unknown"))
    local health = snapshot.lowestBossHealth and string.format("%.1f%%", snapshot.lowestBossHealth) or "--"
    local intelligenceState = SRC.EncounterIntelligence and SRC.EncounterIntelligence.state or "IDLE"
    local profile = SRC.EncounterSequenceEngine and SRC.EncounterSequenceEngine.profile or nil
    local strategy = profile and (profile.selectedStrategy or profile.defaultStrategy) or "automatic"
    local confidence = profile and (profile.researchConfidence or profile.confidence) or "provisional"
    local currentStep = SRC.EncounterSequenceEngine and SRC.EncounterSequenceEngine.steps and SRC.EncounterSequenceEngine.steps[SRC.EncounterSequenceEngine.cursor] or nil
    local nextStep = SRC.EncounterSequenceEngine and SRC.EncounterSequenceEngine.steps and SRC.EncounterSequenceEngine.steps[(SRC.EncounterSequenceEngine.cursor or 1) + 1] or nil
    local interrupt = SRC.EncounterSequenceEngine and SRC.EncounterSequenceEngine.interruptStack and SRC.EncounterSequenceEngine.interruptStack[1] or nil

    local waitingFor = "--"
    if currentStep then
        local trigger = currentStep.trigger
        local triggerType = type(trigger) == "table" and trigger.type or trigger
        triggerType = tostring(triggerType or "TIMER")
        if type(trigger) == "table" and (trigger.percent or trigger.value) then
            waitingFor = string.format("%s %s%%", triggerType, tostring(trigger.percent or trigger.value))
        elseif currentStep.status == "WAITING" then
            waitingFor = triggerType
        else
            waitingFor = tostring(currentStep.status or "--")
        end
    end

    self.stateLabel:SetText(string.format(
        "%s %s | %s | HP %s\n%s\nState: %s / %s | Strategy: %s\nNow: %s | Next: %s\nWaiting: %s | Interrupt: %s | Confidence: %s",
        trial, difficulty, snapshot.validationOnly and "VALIDATION" or "LIVE", health,
        encounter,
        tostring(snapshot.mode or "INACTIVE"), tostring(intelligenceState), tostring(strategy),
        currentStep and tostring(currentStep.label or currentStep.key) or "--",
        nextStep and tostring(nextStep.label or nextStep.key) or "--",
        waitingFor,
        interrupt and tostring(interrupt.label or interrupt.key) or "NONE",
        tostring(confidence)
    ))

    local lines = {}
    for _, entry in ipairs(self.events or {}) do
        lines[#lines + 1] = string.format("%s %-5s %s", FormatClock(entry.at), string.sub(entry.category, 1, 5), entry.text)
    end
    if #lines == 0 then lines[1] = "Waiting for encounter decisions..." end
    self.eventsLabel:SetText(table.concat(lines, "\n"))
end

function Debug:Initialize()
    self.events = {}
    self:CreateWindow()
    if SRC.EventBus then
        SRC.EventBus:Subscribe("ENCOUNTER_MODE_CHANGED", self, function(payload) Debug:OnModeChanged(payload) end)
        SRC.EventBus:Subscribe("ENCOUNTER_BOSS_AVAILABILITY_CHANGED", self, function(payload) Debug:OnAvailabilityChanged(payload) end)
        SRC.EventBus:Subscribe("ENCOUNTER_MECHANIC_OBSERVED", self, function(payload) Debug:OnMechanic(payload) end)
    end
    EVENT_MANAGER:RegisterForUpdate(SRC.name .. "TemporaryEncounterDebug", self.UPDATE_MS, function() Debug:UpdateObservation() end)
    self:AddEvent("INFO", "Temporary vDSR/vRG validation active")
end
