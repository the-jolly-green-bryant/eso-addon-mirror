CadenceCoach = {}
CadenceCoach.name = "CadenceCoach"
CadenceCoach.version = "0.1.2"
CadenceCoach.initialized = false

CadenceCoach.defaults = {
    enabled = true,
    visualEnabled = true,
    audioEnabled = true,
    repositionMode = false,

    x = 500,
    y = 300,

    width = 320,
    height = 70,

    cycleMs = 1000,
    safetyDelayMs = 25,
    updateIntervalMs = 10,

    pattern = "skill", -- "skill" or "lightstack"

    cueFlashMs = 300,
}

CadenceCoach.state = {
    inCombat = false,
    armed = false,
    running = false,
    cycleStart = 0,
    lastCueIndex = nil,
    nextEventIndex = 1,
    nextEventTime = 0,
    cellFlashUntil = {},
}

CadenceCoach.patterns = {
    skill = {
        length = 1000,
        events = {
            { t = 0,   kind = "skill", label = "S" },
            { t = 850, kind = "light", label = "L" },
        },
        timeline = {
            { kind = "skill", label = "S" },
            { kind = "empty", label = ""  },
            { kind = "empty", label = ""  },
            { kind = "light", label = "L" },
        }
    },

    lightstack = {
        length = 1000,
        events = {
            { t = 0,   kind = "skill", label = "S" },
        },
        timeline = {
            { kind = "skill", label = "S" },
            { kind = "empty", label = "" },
            { kind = "empty", label = "" },
            { kind = "empty", label = "" },
        }
    }
}

function CadenceCoach:GetPattern()
    return self.patterns[self.sv.pattern] or self.patterns.skill
end

function CadenceCoach:Debug(msg)
    -- d("[CadenceCoach] " .. tostring(msg))
end

function CadenceCoach:ClampToScreen(x, y)
    local screenW, screenH = GuiRoot:GetDimensions()
    local w = self.sv.width
    local h = self.sv.height

    local maxX = math.max(0, screenW - w)
    local maxY = math.max(0, screenH - h)

    if x < 0 then x = 0 end
    if y < 0 then y = 0 end
    if x > maxX then x = maxX end
    if y > maxY then y = maxY end

    return x, y
end

function CadenceCoach:ApplyAnchor()
    local x, y = self:ClampToScreen(self.sv.x, self.sv.y)
    self.sv.x = x
    self.sv.y = y

    self.window:ClearAnchors()
    self.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

function CadenceCoach:StopCycle()
    self.state.running = false
    self.state.nextEventIndex = 1
    self.state.nextEventTime = 0
    self.state.lastCueIndex = nil
    self.state.cellFlashUntil = {}
end

function CadenceCoach:ResetState()
    self:StopCycle()
    self.state.armed = self.state.inCombat
    self.state.cycleStart = 0
    self:UpdateVisualsIdle()
end

function CadenceCoach:EnterCombat()
    self.state.inCombat = true
    self.state.armed = true
    self:StopCycle()
    self.state.cycleStart = 0
    self:UpdateVisualsArmed()
end

function CadenceCoach:ExitCombat()
    self.state.inCombat = false
    self:ResetState()
    self.window:SetHidden(not self.sv.visualEnabled)
end

function CadenceCoach:StartCycle()
    if self.state.running then
        return
    end

    local pattern = self:GetPattern()
    local now = GetFrameTimeMilliseconds()

    self.state.running = true
    self.state.armed = false
    self.state.cycleStart = now
    self.state.lastCueIndex = nil
    self.state.nextEventIndex = 1
    self.state.nextEventTime = now + pattern.events[1].t + self.sv.safetyDelayMs
end

function CadenceCoach:IsLikelyLightAttack(result, actionSlotType, abilityId, sourceName, targetName, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityName)
    if abilityName == nil then return false end
    local lowerName = zo_strlower(tostring(abilityName))

    if string.find(lowerName, "light attack", 1, true) then
        return true
    end

    return false
end

function CadenceCoach:PlayCueSound(kind)
    if not self.sv.audioEnabled then return end
    PlaySound(SOUNDS.DEFAULT_CLICK)
end

function CadenceCoach:GetCueColor(kind, isActive)
    if isActive then
        if kind == "skill" then
            return 0.95, 0.80, 0.25, 1.0
        elseif kind == "light" then
            return 0.35, 0.85, 1.00, 1.0
        else
            return 0.85, 0.85, 0.85, 1.0
        end
    end

    if kind == "skill" then
        return 0.35, 0.28, 0.08, 0.85
    elseif kind == "light" then
        return 0.10, 0.28, 0.34, 0.85
    else
        return 0.10, 0.10, 0.10, 0.75
    end
end

function CadenceCoach:BuildUI()
    local wm = WINDOW_MANAGER

    self.window = wm:CreateTopLevelWindow(self.name .. "Window")
    self.window:SetDimensions(self.sv.width, self.sv.height)
    self.window:SetClampedToScreen(true)
    self.window:SetMouseEnabled(true)
    self.window:SetMovable(true)
    self.window:SetHidden(false)

    self.bg = wm:CreateControl(nil, self.window, CT_BACKDROP)
    self.bg:SetAnchorFill()
    self.bg:SetCenterColor(0.02, 0.02, 0.02, 0.75)
    self.bg:SetEdgeColor(0.6, 0.6, 0.6, 0.45)
    self.bg:SetEdgeTexture(nil, 1, 1, 2, 0)

    self.title = wm:CreateControl(nil, self.window, CT_LABEL)
    self.title:SetAnchor(TOPLEFT, self.window, TOPLEFT, 10, 6)
    self.title:SetFont("ZoFontWinH5")
    self.title:SetText("CadenceCoach")

    self.status = wm:CreateControl(nil, self.window, CT_LABEL)
    self.status:SetAnchor(TOPRIGHT, self.window, TOPRIGHT, -10, 6)
    self.status:SetFont("ZoFontGameSmall")
    self.status:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    self.status:SetText("IDLE")

    self.lane = wm:CreateControl(nil, self.window, CT_CONTROL)
    self.lane:SetAnchor(TOPLEFT, self.window, TOPLEFT, 10, 26)
    self.lane:SetDimensions(self.sv.width - 20, 34)

    self.cells = {}
    self.cellLabels = {}

    local pattern = self:GetPattern()
    local count = #pattern.timeline
    local spacing = 6
    local totalSpacing = spacing * (count - 1)
    local cellW = math.floor((self.lane:GetWidth() - totalSpacing) / count)
    local cellH = 34

    for i = 1, count do
        local cell = wm:CreateControl(nil, self.lane, CT_BACKDROP)
        cell:SetDimensions(cellW, cellH)

        if i == 1 then
            cell:SetAnchor(LEFT, self.lane, LEFT, 0, 0)
        else
            cell:SetAnchor(LEFT, self.cells[i - 1], RIGHT, spacing, 0)
        end

        cell:SetCenterColor(0.08, 0.08, 0.08, 0.80)
        cell:SetEdgeColor(0.25, 0.25, 0.25, 0.8)
        cell:SetEdgeTexture(nil, 1, 1, 1, 0)

        local label = wm:CreateControl(nil, cell, CT_LABEL)
        label:SetAnchor(CENTER, cell, CENTER, 0, 0)
        label:SetFont("ZoFontWinH3")
        label:SetText(pattern.timeline[i].label or "")

        self.cells[i] = cell
        self.cellLabels[i] = label
    end

    self.dragHint = wm:CreateControl(nil, self.window, CT_LABEL)
    self.dragHint:SetAnchor(BOTTOMRIGHT, self.window, BOTTOMRIGHT, -8, -4)
    self.dragHint:SetFont("ZoFontGameSmall")
    self.dragHint:SetText("LOCKED")

    self.window:SetHandler("OnMoveStop", function(control)
        local left = control:GetLeft()
        local top = control:GetTop()
        if left and top then
            self.sv.x, self.sv.y = self:ClampToScreen(left, top)
            self:ApplyAnchor()
        end
    end)

    self.window:SetHandler("OnMouseDown", function(control, button)
        if not self.sv.repositionMode then return end
        if button == MOUSE_BUTTON_INDEX_LEFT then
            control:StartMoving()
        end
    end)

    self.window:SetHandler("OnMouseUp", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            control:StopMovingOrResizing()
            local left = control:GetLeft()
            local top = control:GetTop()
            if left and top then
                self.sv.x, self.sv.y = self:ClampToScreen(left, top)
                self:ApplyAnchor()
            end
        end
    end)

    self:ApplyAnchor()
    self:RefreshPatternVisuals()
    self:RefreshRepositionMode()
    self:UpdateVisualsIdle()
end

function CadenceCoach:GetTimelineIndexForTime(eventTime)
    local pattern = self:GetPattern()
    local count = #pattern.timeline
    local stepMs = pattern.length / count

    local index = math.floor((eventTime / stepMs) + 0.5) + 1

    if index < 1 then index = 1 end
    if index > count then index = count end

    return index
end

function CadenceCoach:RefreshPatternVisuals()
    if not self.window then return end

    local pattern = self:GetPattern()

    for i = 1, #self.cells do
        local entry = pattern.timeline[i]
        if entry then
            self.cellLabels[i]:SetText(entry.label or "")
            local r, g, b, a = self:GetCueColor(entry.kind, false)
            self.cells[i]:SetCenterColor(r, g, b, a)
        else
            self.cellLabels[i]:SetText("")
            self.cells[i]:SetCenterColor(0.08, 0.08, 0.08, 0.65)
        end
    end
end

function CadenceCoach:RebuildLane()
    if not self.window or not self.lane then return end

    if self.cells then
        for i = 1, #self.cells do
            if self.cells[i] then
                self.cells[i]:SetHidden(true)
            end
        end
    end

    self.cells = {}
    self.cellLabels = {}

    local pattern = self:GetPattern()
    local count = #pattern.timeline
    local spacing = 6
    local totalSpacing = spacing * (count - 1)
    local laneWidth = self.sv.width - 20
    local cellW = math.floor((laneWidth - totalSpacing) / count)
    local cellH = 34

    self.lane:SetDimensions(laneWidth, 34)

    for i = 1, count do
        local cell = WINDOW_MANAGER:CreateControl(nil, self.lane, CT_BACKDROP)
        cell:SetDimensions(cellW, cellH)

        if i == 1 then
            cell:SetAnchor(LEFT, self.lane, LEFT, 0, 0)
        else
            cell:SetAnchor(LEFT, self.cells[i - 1], RIGHT, spacing, 0)
        end

        cell:SetCenterColor(0.08, 0.08, 0.08, 0.80)
        cell:SetEdgeColor(0.25, 0.25, 0.25, 0.8)
        cell:SetEdgeTexture(nil, 1, 1, 1, 0)

        local label = WINDOW_MANAGER:CreateControl(nil, cell, CT_LABEL)
        label:SetAnchor(CENTER, cell, CENTER, 0, 0)
        label:SetFont("ZoFontWinH3")
        label:SetText(pattern.timeline[i].label or "")

        self.cells[i] = cell
        self.cellLabels[i] = label
    end

    self:RefreshPatternVisuals()
end

function CadenceCoach:ApplyWindowSize()
    if not self.window then return end
    self.window:SetDimensions(self.sv.width, self.sv.height)
    self.lane:SetDimensions(self.sv.width - 20, 34)
    self:ApplyAnchor()
    self:RebuildLane()
end

function CadenceCoach:SetPattern(patternName)
    if not self.patterns[patternName] then return end
    self:StopCycle()
    self.sv.pattern = patternName
    self.state.armed = self.state.inCombat
    self:RebuildLane()
    if self.state.inCombat then
        self:UpdateVisualsArmed()
    else
        self:UpdateVisualsIdle()
    end
end

function CadenceCoach:RefreshRepositionMode()
    if not self.window then return end

    self.window:SetMovable(self.sv.repositionMode)
    self.window:SetMouseEnabled(self.sv.repositionMode)

    if self.sv.repositionMode then
        self.dragHint:SetText("DRAG")
        self.bg:SetEdgeColor(0.95, 0.70, 0.20, 0.9)
    else
        self.dragHint:SetText("LOCKED")
        self.bg:SetEdgeColor(0.6, 0.6, 0.6, 0.45)
    end
end

function CadenceCoach:UpdateVisualsIdle()
    if not self.sv.visualEnabled or not self.window then return end
    self.status:SetText("IDLE")
    self:RefreshPatternVisuals()
end

function CadenceCoach:UpdateVisualsArmed()
    if not self.sv.visualEnabled or not self.window then return end
    self.status:SetText("ARMED")
    self:RefreshPatternVisuals()
end

function CadenceCoach:ClearHighlights()
    local pattern = self:GetPattern()
    for i = 1, #pattern.timeline do
        local entry = pattern.timeline[i]
        local r, g, b, a = self:GetCueColor(entry.kind, false)
        self.cells[i]:SetCenterColor(r, g, b, a)
    end
end


function CadenceCoach:PulseCell(index)
    if not self.sv.visualEnabled then return end
    if not self.cells or not self.cells[index] then return end

    local now = GetFrameTimeMilliseconds()
    self.state.cellFlashUntil[index] = now + self.sv.cueFlashMs

    self:RefreshCellVisuals()
end

function CadenceCoach:RefreshCellVisuals()
    if not self.sv.visualEnabled or not self.cells then return end

    local pattern = self:GetPattern()
    local now = GetFrameTimeMilliseconds()

    for i = 1, #pattern.timeline do
        local entry = pattern.timeline[i]
        local activeUntil = self.state.cellFlashUntil[i] or 0
        local isActive = activeUntil > now

        local r, g, b, a = self:GetCueColor(entry.kind, isActive)
        self.cells[i]:SetCenterColor(r, g, b, a)
    end
end

function CadenceCoach:FireCue(eventIndex)
    local pattern = self:GetPattern()
    local event = pattern.events[eventIndex]
    if not event then return end

    self.state.lastCueIndex = eventIndex

    local timelineIndex = self:GetTimelineIndexForTime(event.t)

    self:PulseCell(timelineIndex)
    self.status:SetText(zo_strupper(event.kind))
    self:PlayCueSound(event.kind)
end

function CadenceCoach:Update()
    if not self.sv.enabled then return end
    if not self.state.running then return end
    if self.state.nextEventTime <= 0 then return end

    local pattern = self:GetPattern()
    local now = GetFrameTimeMilliseconds()
    local firedCount = 0
    local maxCatchUp = 4

    while now >= self.state.nextEventTime and firedCount < maxCatchUp do
        local eventIndex = self.state.nextEventIndex
        local event = pattern.events[eventIndex]
        if not event then
            self:StopCycle()
            return
        end

        self:FireCue(eventIndex)

        eventIndex = eventIndex + 1

        if eventIndex > #pattern.events then
            eventIndex = 1
            local cycleLength = pattern.length
            local nextBaseTime = self.state.nextEventTime - event.t + cycleLength
            self.state.nextEventTime = nextBaseTime + pattern.events[eventIndex].t
        else
            local delta = pattern.events[eventIndex].t - event.t
            self.state.nextEventTime = self.state.nextEventTime + delta
        end

        self.state.nextEventIndex = eventIndex
        firedCount = firedCount + 1
    end
    self:RefreshCellVisuals()
end

function CadenceCoach:OnCombatState(_, inCombat)
    if inCombat then
        self:EnterCombat()
    else
        self:ExitCombat()
    end
end

function CadenceCoach:OnCombatEvent(eventCode,
    result, isError, abilityName, abilityGraphic, abilityActionSlotType,
    sourceName, sourceType, targetName, targetType, hitValue, powerType,
    damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)

    if not self.sv.enabled then return end
    if not self.state.inCombat then return end
    if self.state.running then return end
    if not self.state.armed then return end

    if self:IsLikelyLightAttack(result, abilityActionSlotType, abilityId, sourceName, targetName, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityName) then
        self:StartCycle()
    end
end

function CadenceCoach:SlashCommand(text)
    text = zo_strlower(zo_strtrim(text or ""))

    if text == "unlock" then
        self.sv.repositionMode = true
        self:RefreshRepositionMode()
        d("CadenceCoach: reposition mode enabled.")
        return
    elseif text == "lock" then
        self.sv.repositionMode = false
        self:RefreshRepositionMode()
        d("CadenceCoach: reposition mode disabled.")
        return
    elseif text == "skill" then
        self:SetPattern("skill")
        d("CadenceCoach: pattern set to skill.")
        return
    elseif text == "light" or text == "lightstack" then
        self:SetPattern("lightstack")
        d("CadenceCoach: pattern set to lightstack.")
        return
    elseif text == "audio" then
        self.sv.audioEnabled = not self.sv.audioEnabled
        d("CadenceCoach: audio " .. (self.sv.audioEnabled and "enabled" or "disabled") .. ".")
        return
    elseif text == "visual" then
        self.sv.visualEnabled = not self.sv.visualEnabled
        self.window:SetHidden(not self.sv.visualEnabled)
        d("CadenceCoach: visual " .. (self.sv.visualEnabled and "enabled" or "disabled") .. ".")
        return
    elseif text == "on" then
        self.sv.enabled = true
        d("CadenceCoach: enabled.")
        return
    elseif text == "off" then
        self.sv.enabled = false
        self:StopCycle()
        self:UpdateVisualsIdle()
        d("CadenceCoach: disabled.")
        return
    end

    d("/cadence unlock  - move the window")
    d("/cadence lock    - lock the window")
    d("/cadence skill   - use skill pattern")
    d("/cadence light   - use lightstack pattern")
    d("/cadence audio   - toggle audio")
    d("/cadence visual  - toggle visual")
    d("/cadence on      - enable addon")
    d("/cadence off     - disable addon")
end

local function CreateSettings()
    if not LibHarvensAddonSettings or not CadenceCoach or not CadenceCoach.sv then return end
    local LHAS = LibHarvensAddonSettings

    local settings = LHAS:AddAddon("CadenceCoach", {
        allowDefaults = true,
        allowRefresh = true,
    })
    if not settings then return end

    settings:AddSetting({
        type = LHAS.ST_CHECKBOX,
        label = "Enable CadenceCoach",
        getFunction = function() return CadenceCoach.sv.enabled end,
        setFunction = function(v)
            CadenceCoach.sv.enabled = v
            if not v then
                CadenceCoach:StopCycle()
                CadenceCoach:UpdateVisualsIdle()
            end
        end,
        default = true,
    })

    settings:AddSetting({
        type = LHAS.ST_CHECKBOX,
        label = "Show Visual Cue",
        getFunction = function() return CadenceCoach.sv.visualEnabled end,
        setFunction = function(v)
            CadenceCoach.sv.visualEnabled = v
            if CadenceCoach.window then
                CadenceCoach.window:SetHidden(not v)
            end
        end,
        default = true,
    })

    settings:AddSetting({
        type = LHAS.ST_CHECKBOX,
        label = "Enable Audio Cue",
        getFunction = function() return CadenceCoach.sv.audioEnabled end,
        setFunction = function(v)
            CadenceCoach.sv.audioEnabled = v
        end,
        default = true,
    })

    settings:AddSetting({ type = LHAS.ST_SECTION, label = "Cadence Mode" })

    settings:AddSetting({
        type = LHAS.ST_DROPDOWN,
        label = "Pattern",
        items = {
            { name = "WEAVE", data = "skill" },
            { name = "STEADY SKILL", data = "lightstack" },
        },
        getFunction = function()
            local p = CadenceCoach.sv.pattern or "skill"
            if p == "lightstack" then
                return "STEADY SKILL"
            end
            return "WEAVE"
        end,
        setFunction = function(_, _, item)
            CadenceCoach:SetPattern(item.data or "skill")
        end,
        default = "WEAVE",
    })

    settings:AddSetting({
        type = LHAS.ST_SLIDER,
        label = "Safety Delay",
        tooltip = "Trailing delay so cues never lead your input.",
        getFunction = function() return CadenceCoach.sv.safetyDelayMs end,
        setFunction = function(v)
            CadenceCoach.sv.safetyDelayMs = v
        end,
        default = 25,
        min = 0, max = 150, step = 5,
        unit = "ms",
        format = "%d",
    })

    settings:AddSetting({
        type = LHAS.ST_SLIDER,
        label = "Cue Flash Duration",
        getFunction = function() return CadenceCoach.sv.cueFlashMs end,
        setFunction = function(v)
            CadenceCoach.sv.cueFlashMs = v
        end,
        default = 300,
        min = 50, max = 500, step = 10,
        unit = "ms",
        format = "%d",
    })

    settings:AddSetting({ type = LHAS.ST_SECTION, label = "Window Position" })

    settings:AddSetting({
        type = LHAS.ST_SLIDER,
        label = "Window X",
        tooltip = "Distance from top-left of screen.",
        getFunction = function() return CadenceCoach.sv.x end,
        setFunction = function(v)
            CadenceCoach.sv.x = v
            CadenceCoach:ApplyAnchor()
        end,
        default = 500,
        min = 0, max = 3000, step = 10,
        unit = "px",
        format = "%d",
    })

    settings:AddSetting({
        type = LHAS.ST_SLIDER,
        label = "Window Y",
        tooltip = "Distance from top-left of screen.",
        getFunction = function() return CadenceCoach.sv.y end,
        setFunction = function(v)
            CadenceCoach.sv.y = v
            CadenceCoach:ApplyAnchor()
        end,
        default = 300,
        min = 0, max = 3000, step = 10,
        unit = "px",
        format = "%d",
    })

    settings:AddSetting({
        type = LHAS.ST_SLIDER,
        label = "Window Width",
        getFunction = function() return CadenceCoach.sv.width end,
        setFunction = function(v)
            CadenceCoach.sv.width = v
            CadenceCoach:ApplyWindowSize()
        end,
        default = 320,
        min = 180, max = 800, step = 10,
        unit = "px",
        format = "%d",
    })

    settings:AddSetting({
        type = LHAS.ST_SLIDER,
        label = "Window Height",
        getFunction = function() return CadenceCoach.sv.height end,
        setFunction = function(v)
            CadenceCoach.sv.height = v
            CadenceCoach:ApplyWindowSize()
        end,
        default = 70,
        min = 50, max = 160, step = 5,
        unit = "px",
        format = "%d",
    })

    settings:AddSetting({ type = LHAS.ST_SECTION, label = "Info" })

    ----------------------------------------------------------
    -- Signature
    ----------------------------------------------------------
    settings:AddSetting({
        type = LHAS.ST_LABEL,
        label = "|cFFD700Built on tea, toast and ADHD – tested live on PS5.|r\n" ..
                "|cB427D3Su|c546D6Aga|c889764Co|cDA34CDma|r",
    })
end

function CadenceCoach:Initialize()
    if self.initialized then
        return
    end
    self.initialized = true

    self.sv = ZO_SavedVars:NewAccountWide("CadenceCoachSavedVars", 1, nil, self.defaults)

    self:BuildUI()
    CreateSettings()

    SLASH_COMMANDS["/cadence"] = function(text)
        self:SlashCommand(text)
    end

    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE)
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForUpdate(self.name .. "_Update")

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, function(...)
        self:OnCombatState(...)
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_COMBAT_EVENT, function(...)
        self:OnCombatEvent(...)
    end)

    EVENT_MANAGER:AddFilterForEvent(self.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    EVENT_MANAGER:RegisterForUpdate(self.name .. "_Update", self.sv.updateIntervalMs, function()
        self:Update()
    end)

    self.window:SetHidden(not self.sv.visualEnabled)

    if IsUnitInCombat("player") then
        self:EnterCombat()
    else
        self:ExitCombat()
    end

    self:Debug("Initialized")
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= CadenceCoach.name then return end
    EVENT_MANAGER:UnregisterForEvent(CadenceCoach.name, EVENT_ADD_ON_LOADED)
    CadenceCoach:Initialize()
end

EVENT_MANAGER:RegisterForEvent(CadenceCoach.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)