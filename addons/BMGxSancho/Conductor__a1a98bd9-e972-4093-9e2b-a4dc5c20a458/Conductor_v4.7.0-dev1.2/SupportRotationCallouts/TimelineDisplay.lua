local SRC = SupportRotationCallouts
local C = Conductor
SRC.TimelineDisplay = SRC.TimelineDisplay or {}
local Display = SRC.TimelineDisplay
local WM = WINDOW_MANAGER

local LIMITS = {
    MIN_WIDTH = 600,
    MAX_WIDTH = 1050,
    MIN_HEIGHT = 95,
    MAX_HEIGHT = 175,
    MIN_SCALE = 0.80,
    MAX_SCALE = 1.00,
    EDGE_PADDING = 14,
    HEADER_HEIGHT = 32,
}

local COLORS = {
    WHITE = {0.96,0.95,0.91,1},
    GREEN = {0.35,1,0.4,1},
    YELLOW = {1,0.82,0.1,1},
    RED = {1,0.22,0.18,1},
    MUTED = {0.66,0.68,0.72,1},
    GOLD = {0.95,0.73,0.22,1},
    PANEL = {0.012,0.016,0.024,0.90},
    PANEL_EDGE = {0.78,0.58,0.16,0.70},
    TRACK = {0.74,0.56,0.20,0.35},
}

local IMPORTANT_LABELS = {
    ["DPS BURN"]=true, EXECUTE=true, PORTAL=true, RECOVERY=true,
    STACK=true, SPREAD=true, ["HOLD DPS"]=true, RESUME=true,
}

local function Clamp(value, low, high)
    return zo_clamp(tonumber(value) or low, low, high)
end

local function MakeLabel(parent, font)
    local label = WM:CreateControl(nil, parent, CT_LABEL)
    label:SetFont(font or "$(BOLD_FONT)|18|outline")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetColor(unpack(COLORS.WHITE))
    return label
end

local function LaneY(height, lane)
    -- The first public Timeline uses one consistent execution lane. The event
    -- label and optional player attribution are already vertically stacked,
    -- so separate RAID / SUPPORT / MECHANIC baselines create visual drift and
    -- can push the event tick through the header at short panel heights.
    local top = LIMITS.HEADER_HEIGHT + 4
    local usable = math.max(46, height - top - 10)
    return top + zo_round(usable * 0.35)
end


local NODE_WIDTH = 156
local NODE_HALF_WIDTH = NODE_WIDTH / 2
local NODE_HEIGHT = 42
local ROW_GAP = 2
local COLLISION_GAP = 12
local COLLISION_DISTANCE = NODE_WIDTH + COLLISION_GAP

local function EventPriority(event, now)
    local label = string.upper(tostring(event.label or event.key or ""))
    local priority = tonumber(event.priority) or 0
    if event.isRecommendation == true or event.recommendation == true then priority = priority + 500 end
    if event.isMechanic == true or event.lane == "MECHANIC" then priority = priority + 400 end
    if IMPORTANT_LABELS[label] then priority = priority + 350 end
    if event.personalHighlight == true then priority = priority + 300 end
    if tostring(event.displayAssignedText or "") == "YOU" then priority = priority + 300 end
    if event.status == "PENDING" then priority = priority + 100 end
    local delta = math.abs((tonumber(event.targetMs) or now) - now)
    priority = priority + math.max(0, 90 - math.floor(delta / 250))
    return priority
end

local function DuplicateKey(event)
    local key = string.upper(tostring(event.key or event.label or "")):gsub("[^A-Z0-9]+", "_")
    local owner = string.lower(tostring(event.assignedAccount or event.displayAssignedText or ""))
    return key .. "|" .. owner
end

local function CopyEvent(event)
    local copy = {}
    for key, value in pairs(event or {}) do copy[key] = value end
    return copy
end

function Display:GetAvailableRows()
    local usable = math.max(NODE_HEIGHT, self.height - LIMITS.HEADER_HEIGHT - 8)
    return math.max(1, math.min(3, math.floor((usable + ROW_GAP) / (NODE_HEIGHT + ROW_GAP))))
end

function Display:BuildCollisionSafeLayout(events, now, leftBound, rightBound)
    local current, nextEvent
    local currentDistance, nextDistance
    for _, source in ipairs(events or {}) do
        local event = CopyEvent(source)
        local delta = (tonumber(event.targetMs) or now) - now
        local priority = EventPriority(event, now)
        if delta <= 900 and delta >= -2200 then
            local distance = math.abs(delta) - (priority * 2)
            if currentDistance == nil or distance < currentDistance then
                current, currentDistance = event, distance
            end
        elseif delta > 900 then
            local distance = delta - (priority * 2)
            if nextDistance == nil or distance < nextDistance then
                nextEvent, nextDistance = event, distance
            end
        end
    end

    local layout = {}
    if current then
        current.id = "TL-DISPLAY-NOW"
        current._x = self.width * 0.50
        current._row = 1
        current.displayAssignedText = tostring(current.displayAssignedText or current.assignedAccount or "")
        if current.displayAssignedText == "UNKNOWN" or current.displayAssignedText == "SIMULTANEOUS" then current.displayAssignedText = "" end
        layout[#layout + 1] = current
    end
    if nextEvent then
        nextEvent.id = "TL-DISPLAY-NEXT"
        nextEvent._x = self.width * 0.76
        nextEvent._row = 1
        nextEvent.displayAssignedText = tostring(nextEvent.displayAssignedText or nextEvent.assignedAccount or "")
        if nextEvent.displayAssignedText == "UNKNOWN" or nextEvent.displayAssignedText == "SIMULTANEOUS" then nextEvent.displayAssignedText = "" end
        layout[#layout + 1] = nextEvent
    end
    return layout
end

function Display:GetDimensions()
    local width = Clamp(SRC.saved.timelineWidth or LIMITS.MAX_WIDTH, LIMITS.MIN_WIDTH, LIMITS.MAX_WIDTH)
    local height = Clamp(SRC.saved.timelineHeight or LIMITS.MAX_HEIGHT, LIMITS.MIN_HEIGHT, LIMITS.MAX_HEIGHT)
    return width, height
end

function Display:ClampPosition(width, height, scale)
    local rootWidth = GuiRoot:GetWidth() or 1920
    local rootHeight = GuiRoot:GetHeight() or 1080
    local halfWidth = (width * scale) / 2
    local halfHeight = (height * scale) / 2
    local margin = 8
    local maxX = math.max(0, (rootWidth / 2) - halfWidth - margin)
    local maxY = math.max(0, (rootHeight / 2) - halfHeight - margin)
    SRC.saved.timelineOffsetX = Clamp(SRC.saved.timelineOffsetX or 0, -maxX, maxX)
    SRC.saved.timelineOffsetY = Clamp(SRC.saved.timelineOffsetY or 260, -maxY, maxY)
end

function Display:Initialize()
    local width, height = self:GetDimensions()
    local scale = Clamp(SRC.saved.timelineScale or 1, LIMITS.MIN_SCALE, LIMITS.MAX_SCALE)

    local window = WM:CreateTopLevelWindow("ConductorPersonalTimeline")
    window:SetDimensions(width, height)
    self:ClampPosition(width, height, scale)
    window:SetAnchor(CENTER, GuiRoot, CENTER, SRC.saved.timelineOffsetX or 0, SRC.saved.timelineOffsetY or 260)
    window:SetScale(scale)
    window:SetMouseEnabled(SRC.saved.windowsLocked ~= true)
    window:SetMovable(SRC.saved.windowsLocked ~= true)
    window:SetClampedToScreen(true)
    window:SetHidden(true)
    window:SetHandler("OnMoveStop", function(control)
        if not SRC.saved then return end
        local centerX = (GuiRoot:GetWidth() or 1920) / 2
        local centerY = (GuiRoot:GetHeight() or 1080) / 2
        SRC.saved.timelineOffsetX = control:GetLeft() + (control:GetWidth() * (control:GetScale() or 1) / 2) - centerX
        SRC.saved.timelineOffsetY = control:GetTop() + (control:GetHeight() * (control:GetScale() or 1) / 2) - centerY
    end)

    local background = WM:CreateControl(nil, window, CT_BACKDROP)
    background:SetAnchorFill()
    background:SetCenterColor(COLORS.PANEL[1], COLORS.PANEL[2], COLORS.PANEL[3], SRC.saved.timelineBackgroundOpacity or COLORS.PANEL[4])
    background:SetEdgeColor(unpack(COLORS.PANEL_EDGE))
    background:SetEdgeTexture(nil, 2, 2, 2)

    local headerLine = WM:CreateControl(nil, window, CT_TEXTURE)
    headerLine:SetAnchor(TOPLEFT, window, TOPLEFT, LIMITS.EDGE_PADDING, LIMITS.HEADER_HEIGHT)
    headerLine:SetAnchor(TOPRIGHT, window, TOPRIGHT, -LIMITS.EDGE_PADDING, LIMITS.HEADER_HEIGHT)
    headerLine:SetHeight(2)
    headerLine:SetColor(unpack(COLORS.GOLD))

    local title = MakeLabel(window, "$(BOLD_FONT)|18|outline")
    title:SetAnchor(TOPLEFT, window, TOPLEFT, LIMITS.EDGE_PADDING, 5)
    title:SetText("TIMELINE")
    title:SetColor(unpack(COLORS.GOLD))

    local past = MakeLabel(window, "$(MEDIUM_FONT)|14|outline")
    past:SetAnchor(TOPLEFT, window, TOPLEFT, 112, 7)
    past:SetText("PAST")
    past:SetColor(unpack(COLORS.MUTED))

    local future = MakeLabel(window, "$(MEDIUM_FONT)|14|outline")
    future:SetAnchor(TOPRIGHT, window, TOPRIGHT, -LIMITS.EDGE_PADDING, 7)
    future:SetText("FUTURE")
    future:SetColor(unpack(COLORS.MUTED))

    local center = WM:CreateControl(nil, window, CT_TEXTURE)
    center:SetAnchor(TOP, window, TOP, 0, LIMITS.HEADER_HEIGHT + 4)
    center:SetDimensions(4, height - LIMITS.HEADER_HEIGHT - 12)
    center:SetColor(unpack(COLORS.GOLD))

    local now = MakeLabel(window, "$(BOLD_FONT)|16|outline")
    now:SetAnchor(BOTTOM, center, TOP, 0, -2)
    now:SetText("NOW")
    now:SetColor(unpack(COLORS.GOLD))

    self.window = window
    if C.WindowController then C.WindowController:Register("TIMELINE", window) end
    self.title = title
    self.past = past
    self.future = future
    self.background = background
    self.headerLine = headerLine
    self.center = center
    self.now = now
    self.nodes = {}
    self.pool = {}
    self.width = width
    self.height = height
    self.pixelsPerSecond = width / 40

    EVENT_MANAGER:RegisterForUpdate("ConductorTimelineDisplayUpdate", 200, function() self:Update() end)
    if C.EventBus then
        C.EventBus:Subscribe("TIMELINE_CLEARED", self, function() self:ReleaseAll() end)
    end
end

function Display:Acquire(event)
    local node = table.remove(self.pool)
    if not node then
        node = WM:CreateControl(nil, self.window, CT_CONTROL)
        node:SetDimensions(NODE_WIDTH, NODE_HEIGHT)
        node.label = MakeLabel(node, "$(BOLD_FONT)|18|outline")
        node.label:SetAnchor(TOPLEFT, node, TOPLEFT, 0, 0)
        node.label:SetAnchor(TOPRIGHT, node, TOPRIGHT, 0, 0)
        node.label:SetHeight(25)
        -- Personal ownership is rendered as a real yellow outline around the
        -- word YOU. Eight offset copies form the outline while the foreground
        -- text remains free to use the event's white/green/yellow/red timing
        -- color. This is more reliable on gamepad than stacking one duplicate
        -- label directly behind the foreground text.
        node.personalOutline = {}
        local outlineOffsets = {
            {-2, 0}, {2, 0}, {0, -2}, {0, 2},
            {-2, -2}, {-2, 2}, {2, -2}, {2, 2},
        }
        for index, offset in ipairs(outlineOffsets) do
            local outline = MakeLabel(node, "$(BOLD_FONT)|16|outline")
            outline:SetAnchor(TOPLEFT, node.label, BOTTOMLEFT, offset[1], -1 + offset[2])
            outline:SetAnchor(TOPRIGHT, node.label, BOTTOMRIGHT, offset[1], -1 + offset[2])
            outline:SetHeight(18)
            outline:SetColor(COLORS.GOLD[1], COLORS.GOLD[2], COLORS.GOLD[3], 1)
            outline:SetHidden(true)
            node.personalOutline[index] = outline
        end
        node.detail = MakeLabel(node, "$(BOLD_FONT)|16|outline")
        node.detail:SetAnchor(TOPLEFT, node.label, BOTTOMLEFT, 0, -1)
        node.detail:SetAnchor(TOPRIGHT, node.label, BOTTOMRIGHT, 0, -1)
        node.detail:SetHeight(18)
        node.detail:SetColor(unpack(COLORS.WHITE))
        node.tick = WM:CreateControl(nil, node, CT_TEXTURE)
        node.tick:SetAnchor(BOTTOM, node, TOP, 0, 0)
        node.tick:SetDimensions(3, 11)
        node.tick:SetColor(unpack(COLORS.WHITE))
    end
    node.eventId = event.id
    node:SetHidden(false)
    self.nodes[event.id] = node
    return node
end

function Display:Release(id)
    local node = self.nodes[id]
    if not node then return end
    node:SetHidden(true)
    node:ClearAnchors()
    self.nodes[id] = nil
    self.pool[#self.pool + 1] = node
end

function Display:ReleaseAll()
    local ids = {}
    for id in pairs(self.nodes) do ids[#ids+1] = id end
    for _, id in ipairs(ids) do self:Release(id) end
end

function Display:ApplySettings()
    if not self.window then return end
    local width, height = self:GetDimensions()
    local scale = Clamp(SRC.saved.timelineScale or 1, LIMITS.MIN_SCALE, LIMITS.MAX_SCALE)
    SRC.saved.timelineWidth = width
    SRC.saved.timelineHeight = height
    SRC.saved.timelineScale = scale
    self:ClampPosition(width, height, scale)

    self.width = width
    self.height = height
    self.pixelsPerSecond = width / 40
    self.window:SetDimensions(width, height)
    self.window:SetScale(scale)
    self.window:ClearAnchors()
    self.window:SetAnchor(CENTER, GuiRoot, CENTER, SRC.saved.timelineOffsetX or 0, SRC.saved.timelineOffsetY or 260)
    self.center:SetDimensions(4, height - LIMITS.HEADER_HEIGHT - 12)
end

function Display:Update()
    if not self.window or not C.TimelineEngine then return end
    if not SRC.saved or SRC.saved.enabled ~= true then
        self.window:SetHidden(true)
        self:ReleaseAll()
        return
    end
    local enabled = SRC.saved.timelineEnabled ~= false
    local visibility = SRC.saved.dashboardVisibility or "combat"
    local preparation = not SRC.inCombat and not C.TimelineEngine.preview
    local active = C.TimelineEngine.running or C.TimelineEngine.preview or SRC.inCombat == true or SRC.bossEncounterActive == true or (preparation and visibility == "always")
    local visibleByMode = C.TimelineEngine.preview or visibility == "always" or (visibility == "combat" and SRC.inCombat == true)
    self.window:SetHidden(not enabled or not active or not visibleByMode)
    if self.window:IsHidden() then return end

    local events, displayMode = C.TimelineEngine:GetDisplayEvents(18, 22)
    if self.title then
        self.title:SetText(displayMode == "PREPARATION" and "READINESS" or (displayMode == "TRASH" and "TRASH ROTATION" or "TIMELINE"))
    end
    local isPreparation = displayMode == "PREPARATION"
    if self.past then self.past:SetHidden(isPreparation) end
    if self.future then self.future:SetHidden(isPreparation) end
    if self.center then self.center:SetHidden(isPreparation) end
    if self.now then
        self.now:SetHidden(false)
        self.now:SetText(isPreparation and "PULL" or "NOW")
    end
    local keep = {}
    local now = GetGameTimeMilliseconds()
    local leftBound = LIMITS.EDGE_PADDING + NODE_HALF_WIDTH
    local rightBound = self.width - LIMITS.EDGE_PADDING - NODE_HALF_WIDTH
    local layout

    if C.TimelineEngine.preview then
        -- Preview is an instructional animation, not a collision test. Keep
        -- every scripted event on the real timeline track at its own time-based
        -- position. Never replace preview events with MORE / SIMULTANEOUS.
        layout = {}
        local centerX = self.width / 2
        for _, source in ipairs(events or {}) do
            local event = CopyEvent(source)
            event._x = centerX + (((event.targetMs or now) - now) / 1000) * self.pixelsPerSecond
            if event._x >= leftBound and event._x <= rightBound then
                event._row = 1
                layout[#layout + 1] = event
            end
        end
    elseif isPreparation then
        -- Readiness is a static status board, not a scrolling event stream.
        -- Keep the three preparation records at fixed positions and bypass
        -- deduplication, clustering, and SIMULTANEOUS summaries entirely.
        local fixedX = {
            ["PREP-SUPPORT"] = self.width * 0.28,
            ["PREP-PULL"] = self.width * 0.50,
            ["PREP-DD"] = self.width * 0.72,
        }
        layout = {}
        for _, source in ipairs(events or {}) do
            local event = CopyEvent(source)
            event._x = fixedX[event.id] or (self.width * 0.50)
            event._row = 1
            layout[#layout + 1] = event
        end
    else
        layout = self:BuildCollisionSafeLayout(events, now, leftBound, rightBound)
    end

    for _, event in ipairs(layout) do
        keep[event.id] = true
        local node = self.nodes[event.id] or self:Acquire(event)
        local x = event._x or (self.width / 2)
        node:SetHidden(false)
        local row = tonumber(event._row) or 1
        local y = LIMITS.HEADER_HEIGHT + 4 + ((row - 1) * (NODE_HEIGHT + ROW_GAP))
        y = Clamp(y, LIMITS.HEADER_HEIGHT + 3, math.max(LIMITS.HEADER_HEIGHT + 3, self.height - NODE_HEIGHT - 4))
        node:ClearAnchors()
        node:SetAnchor(TOPLEFT, self.window, TOPLEFT, x - NODE_HALF_WIDTH, y)
            local label = tostring(event.label or "Event")
            node.label:SetText(label)
            node.label:SetFont(IMPORTANT_LABELS[string.upper(label)] and "$(BOLD_FONT)|20|outline" or "$(BOLD_FONT)|18|outline")
            local isMechanic = event.lane == "MECHANIC" or event.isMechanic == true
            local color = isMechanic and COLORS.WHITE or (COLORS[event.accuracy or "WHITE"] or COLORS.WHITE)
            node.label:SetColor(unpack(color))
            node.tick:SetColor(unpack(color))

            local account = tostring(event.assignedAccount or "")
            local localAccount = SRC.NormalizeAccountName and SRC:NormalizeAccountName(GetDisplayName and GetDisplayName() or "") or string.lower(tostring(GetDisplayName and GetDisplayName() or ""))
            local assigned = SRC.NormalizeAccountName and SRC:NormalizeAccountName(account) or string.lower(account)
            local role = string.lower(tostring(SRC.saved.displayRole or "lead"))
            local isPersonal = assigned ~= "" and assigned == localAccount and role ~= "lead"
            local detail = tostring(event.displayAssignedText or "")
            if detail == "" and account ~= "" then
                detail = isPersonal and "YOU" or account
            end

            local highlightPersonal = (event.personalHighlight == true or isPersonal) and detail == "YOU"
            node.detail:SetText(detail)
            node.detail:SetHidden(detail == "")
            node.detail:SetColor(unpack(highlightPersonal and color or COLORS.WHITE))

        for _, outline in ipairs(node.personalOutline or {}) do
            outline:SetText(detail)
            outline:SetHidden(not highlightPersonal)
        end
    end

    local stale = {}
    for id in pairs(self.nodes) do if not keep[id] then stale[#stale+1] = id end end
    for _, id in ipairs(stale) do self:Release(id) end
end

function Display:Preview()
    if C.TimelineEngine then C.TimelineEngine:Preview() end
end
