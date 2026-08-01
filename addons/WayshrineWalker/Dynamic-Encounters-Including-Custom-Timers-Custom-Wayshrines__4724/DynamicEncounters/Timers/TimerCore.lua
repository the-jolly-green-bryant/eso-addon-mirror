--[[----------------------------------------------------------------------
    Dynamic Encounters : Custom Timer Core
    Wall-clock countdown engine + SavedVariables persistence (v2).
    running -> endEpoch = GetTimeStamp()+remaining (persists across logout)
    stopped -> remaining = seconds left
----------------------------------------------------------------------]]--

DynamicEncounters.Timers = DynamicEncounters.Timers or {}
local T = DynamicEncounters.Timers
local HE = DynamicEncounters

T.SIZE_SMALL  = 1
T.SIZE_MEDIUM = 2
T.SIZE_LARGE  = 3

T.SIZE_DIMS = {
    [T.SIZE_SMALL]  = { w = 200, h = 60  },
    [T.SIZE_MEDIUM] = { w = 300, h = 90  },
    [T.SIZE_LARGE]  = { w = 400, h = 120 },
}

T.STATE_STOPPED = "stopped"
T.STATE_RUNNING = "running"

local SV_VERSION = 2

T.defaults = {
    timerSettings = {
        version         = SV_VERSION,
        nextId          = 1,
        globalLock      = false,
        defaultSize     = T.SIZE_MEDIUM,
        defaultDuration = 300,
        list            = {},
    },
}

local function ts()
    if not HE.sv then return nil end
    if not HE.sv.timerSettings then HE.sv.timerSettings = {} end
    if not HE.sv.timerSettings.list then HE.sv.timerSettings.list = {} end
    return HE.sv.timerSettings
end

local function NewTimerObject(id, label, duration, size)
    duration = tonumber(duration) or T.defaults.timerSettings.defaultDuration
    if duration < 1 then duration = 1 end
    return {
        id              = id,
        label           = label or ("Timer " .. id),
        duration        = duration,
        remaining       = duration,
        state           = T.STATE_STOPPED,
        endEpoch        = nil,
        expired         = false,
        locked          = false,
        size            = size or T.SIZE_MEDIUM,
        left            = nil,
        top             = nil,
        wayshrineNodeId = nil,
        wayshrineZoneId = nil,
        favoriteSize    = nil,
    }
end

function T.Initialize()
    HE.sv.timerSettings = HE.sv.timerSettings or {}
    local s = ts()
    s.version         = s.version         or 1
    s.nextId          = s.nextId          or 1
    s.globalLock      = s.globalLock      or false
    s.defaultSize     = s.defaultSize     or T.SIZE_MEDIUM
    s.defaultDuration = s.defaultDuration or 300
    s.list            = s.list            or {}

    if s.version < 2 then
        local now = GetTimeStamp()
        for _, t in pairs(s.list) do
            if t.state == T.STATE_RUNNING then
                local base = tonumber(t.remaining) or tonumber(t.duration) or s.defaultDuration
                t.endEpoch = now + math.max(0, math.floor(base))
            end
            t.targetEndTime = nil
            t.locked   = t.locked or false
            t.expired  = false
        end
        s.version = 2
    end

    for _, t in pairs(s.list) do
        t.locked  = t.locked or false
        t.expired = t.expired or false
    end

    -- No auto-created default timer; users create timers via the T button
end

function T.CreateTimer(label, duration, size)
    local id = ts().nextId
    ts().nextId = id + 1
    local timer = NewTimerObject(id, label, duration, size or ts().defaultSize)
    -- Spawn below the main DE panel, cascading so stacked timers are
    -- clearly separated. Panel is ~280px tall when expanded (header +
    -- 3 rows + step + disclaimer + padding).
    -- Use active timer count, NOT nextId, so deleted timers don't leave gaps.
    local screenWidth  = GuiRoot:GetWidth()
    local screenHeight = GuiRoot:GetHeight()
    -- Spawn relative to the main DE panel position (where the user put it)
    local baseLeft = (HE.sv and HE.sv.left) or (screenWidth - 360)
    local baseTop  = (HE.sv and HE.sv.top)  or 260
    -- Account for panel state: minimized panel is ~30px, expanded ~280px
    local panelH = (HE.sv and HE.sv.minimized) and 36 or 280
    local count = 0
    for _ in pairs(ts().list) do count = count + 1 end
    -- Cascade: offset each subsequent timer so they don't stack exactly
    local offsetX = (count % 3) * 20
    local offsetY = math.floor(count / 3) * 100
    timer.left = baseLeft + offsetX
    timer.top  = baseTop + panelH + 16 + offsetY
    -- Clamp to visible screen area (leave room for timer widget + margin)
    local timerW = 300  -- medium width
    local timerH = 90   -- medium height
    timer.left = math.max(10, math.min(timer.left, screenWidth - timerW - 10))
    timer.top  = math.max(10, math.min(timer.top, screenHeight - timerH - 10))
    ts().list[id] = timer
    if T.UI_OnTimerCreated then T.UI_OnTimerCreated(timer) end
    return id
end

function T.DeleteTimer(id, force)
    local timer = ts().list[id]
    if not timer then return end
    timer.state = T.STATE_STOPPED
    timer.endEpoch = nil
    if T.UI_OnTimerDeleted then T.UI_OnTimerDeleted(timer) end
    if T.OnEncounterCloneDeleted then T.OnEncounterCloneDeleted(id) end
    ts().list[id] = nil
end

function T.StartTimer(id)
    local timer = ts().list[id]
    if not timer or timer.state == T.STATE_RUNNING then return end
    if (timer.remaining or 0) <= 0 then timer.remaining = timer.duration end
    timer.state   = T.STATE_RUNNING
    timer.expired = false
    timer.endEpoch = GetTimeStamp() + math.max(1, math.floor(timer.remaining))
end

function T.StopTimer(id)
    local timer = ts().list[id]
    if not timer or timer.state ~= T.STATE_RUNNING then return end
    timer.remaining = math.max(0, (timer.endEpoch or 0) - GetTimeStamp())
    timer.state    = T.STATE_STOPPED
    timer.endEpoch = nil
end

function T.ToggleTimer(id)
    local timer = ts().list[id]
    if not timer then return end
    if timer.state == T.STATE_RUNNING then T.StopTimer(id) else T.StartTimer(id) end
end

function T.ToggleAllTimers()
    for id, timer in pairs(ts().list) do
        if timer.state == T.STATE_RUNNING then T.StopTimer(id) else T.StartTimer(id) end
    end
end

-- B2: linked timers never expire via timer lifecycle; sync owns them
function T.ExpireTimer(id)
    local timer = ts().list[id]
    if not timer then return end
    timer.state     = T.STATE_STOPPED
    timer.remaining = 0
    timer.endEpoch  = nil
    timer.expired   = true
    if T.UI_OnTimerExpired then T.UI_OnTimerExpired(timer) end
end

function T.GetRemaining(id)
    local timer = ts().list[id]
    if not timer then return 0 end
    if timer.state == T.STATE_RUNNING then
        return math.max(0, (timer.endEpoch or 0) - GetTimeStamp())
    end
    return timer.remaining or 0
end

function T.SetLabel(id, label)
    local timer = ts().list[id]
    if not timer then return end
    timer.label = label
    if T.UI_OnTimerLabelChanged then T.UI_OnTimerLabelChanged(timer) end
end

function T.SetDuration(id, seconds)
    local timer = ts().list[id]
    if not timer then return end
    seconds = tonumber(seconds)
    if not seconds or seconds < 1 then return end
    timer.duration = seconds
    if timer.state == T.STATE_STOPPED then
        timer.remaining = seconds
        timer.expired   = false
    elseif timer.state == T.STATE_RUNNING then
        timer.endEpoch = GetTimeStamp() + seconds
    end
end

function T.SetSize(id, sizeEnum)
    local timer = ts().list[id]
    if not timer then return end
    if not T.SIZE_DIMS[sizeEnum] then return end
    timer.size = sizeEnum
    if T.UI_OnTimerResized then T.UI_OnTimerResized(timer) end
end

function T.SetFavoriteSize(id, sizeEnum)
    local timer = ts().list[id]
    if not timer then return end
    timer.favoriteSize = sizeEnum
end

function T.ResetToFavoriteSize(id)
    local timer = ts().list[id]
    if not timer or not timer.favoriteSize then return end
    T.SetSize(id, timer.favoriteSize)
end

function T.SetPosition(id, left, top)
    local timer = ts().list[id]
    if not timer then return end
    timer.left = left
    timer.top  = top
end

function T.ResetPosition(id)
    local baseLeft = (HE.sv and HE.sv.left) or (GuiRoot:GetWidth() - 360)
    local baseTop  = (HE.sv and HE.sv.top)  or 260
    T.SetPosition(id, baseLeft + ((id - 1) % 5) * 20,
                       baseTop + 120 + math.floor((id - 1) / 5) * 20)
    if T.UI_OnTimerMoved then T.UI_OnTimerMoved(ts().list[id]) end
end

function T.SetWayshrine(id, nodeId, zoneId)
    local timer = ts().list[id]
    if not timer then return end
    timer.wayshrineNodeId = nodeId or nil
    timer.wayshrineZoneId = zoneId or nil
    if T.UI_OnWayshrineChanged then T.UI_OnWayshrineChanged(timer) end
end

-- Shared travel helper: used by both the header WS button (DynamicEncountersUI)
-- and custom timer WS buttons (TimerUI).  Checks combat, verifies the node is
-- discovered, then shows the travel confirmation dialog.
function T.TravelToWayshrine(nodeIndex)
    if not nodeIndex then return end
    if IsUnitInCombat("player") then
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, "Cannot travel while in combat")
        return
    end
    local known = GetFastTravelNodeInfo(nodeIndex)
    if not known then
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, "Wayshrine not discovered")
        return
    end
    if T.UI_EnsureTravelDialog then T.UI_EnsureTravelDialog() end
    ZO_Dialogs_ShowDialog("DYNAMICENCOUNTERS_TRAVEL_CONFIRM", { nodeIndex = nodeIndex })
end

function T.SetLocked(id, locked)
    local timer = ts().list[id]
    if not timer then return end
    timer.locked = locked and true or false
end

function T.ToggleLocked(id)
    local timer = ts().list[id]
    if not timer then return end
    timer.locked = not timer.locked
    return timer.locked
end

function T.IsLocked(id)
    if ts().globalLock then return true end
    local timer = ts().list[id]
    return (timer and timer.locked) or false
end

function T.GetGlobalLock() return ts().globalLock end
function T.SetGlobalLock(locked) ts().globalLock = locked and true or false end
function T.GetAllTimers() local s = ts() return (s and s.list) or {} end
function T.GetTimer(id) local s = ts() return s and s.list and s.list[id] or nil end

-- "60"->60min, "90s"->90sec, "45m"->45min, "1:30"->90min. Returns seconds or nil.
function T.ParseDuration(text)
    if not text then return nil end
    text = tostring(text):gsub("^%s+", ""):gsub("%s+$", "")
    if text == "" then return nil end
    local a, b = text:match("^(%d+):(%d+)$")
    if a and b then
        local secs = tonumber(a) * 60 + tonumber(b)
        if secs >= 1 then return secs end
        return nil
    end
    local num, suf = text:match("^(%d+)([smhSMH])$")
    if num and suf then
        num = tonumber(num); suf = suf:lower()
        if suf == "s" then return num end
        if suf == "m" then return num * 60 end
        if suf == "h" then return num * 3600 end
    end
    local n = tonumber(text)
    if n and n >= 1 then return math.floor(n) * 60 end
    return nil
end


-- -------------------------------------------------------------------
-- TrackEncounter is defined in EncounterTracker.lua, which has the full
-- implementation with prediction support, duplicate prevention, and
-- pre-set zone wayshrine assignment. This file (TimerCore.lua) loads
-- BEFORE EncounterTracker.lua, so the real definition always wins.
-- Do NOT re-define TrackEncounter here — it would shadow the complete
-- version and lose prediction/duplicate-prevention features.
-- -------------------------------------------------------------------
