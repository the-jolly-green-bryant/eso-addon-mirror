-- AA_Profiler.lua
-- CPU budget profiler for ESO. Intercepts all addon event/update callbacks
-- during the first 3000ms after load and reports timing data via /aap.
-- Frame-level diagnostics (Update 2) available via /aapframes.
--
-- LOAD ORDER: The "AA_" prefix ensures this addon sorts first alphabetically
-- and loads before all other addons. Hooks are installed immediately at file
-- load time — before any other addon can register its callbacks.

-- =============================================================================
-- Global state table
-- =============================================================================

AA_Profiler = {
    data      = {},   -- [addonName] = { {time=ms, dur=ms}, ... }
    active    = false,
    startTime = 0,
    -- UI handles (populated lazily on first /aap)
    window       = nil,
    rowLabels    = nil,
    statusLabel  = nil,
    -- Scroll state
    scrollOffset = 0,
    lastResults  = {},

    -- -------------------------------------------------------------------------
    -- Update 2: Frame-level diagnostics
    -- -------------------------------------------------------------------------
    seq        = 0,        -- global monotonic sequence counter (every callback)
    frameLog   = {},       -- [frameTime] = { frameTime, totalEvents, firstSeq, lastSeq, perAddon={} }
    frameOrder = {},       -- array of frameTime keys in insertion order

    -- Error-handler probe results
    errorMarks            = {},   -- { {seq, frameTime, message, isBudgetError}, ... }
    errorCaptureAvailable = false,

    -- Frame view UI handles (populated lazily on first /aapframes)
    frameWindow       = nil,
    frameRowLabels    = nil,
    frameStatusLabel  = nil,
    frameScrollOffset = 0,
    frameDisplayLines = {},  -- flat list of {text, color={r,g,b,a}} for rendering
    frameScene        = nil,
}

local ROW_HEIGHT = 40

-- =============================================================================
-- Data recording
-- =============================================================================

function AA_Profiler.Record(addonName, duration)
    if not AA_Profiler.active then return end

    -- Increment global sequence counter
    AA_Profiler.seq = AA_Profiler.seq + 1
    local seq       = AA_Profiler.seq
    local frameTime = GetGameTimeMilliseconds()

    -- Existing per-addon aggregation (unchanged)
    if not AA_Profiler.data[addonName] then
        AA_Profiler.data[addonName] = {}
    end
    local buffer = AA_Profiler.data[addonName]
    buffer[#buffer + 1] = { time = frameTime, dur = duration }

    -- New: frame bucketing
    local frame = AA_Profiler.frameLog[frameTime]
    if not frame then
        frame = {
            frameTime   = frameTime,
            totalEvents = 0,
            firstSeq    = seq,
            lastSeq     = seq,
            perAddon    = {},
        }
        AA_Profiler.frameLog[frameTime] = frame
        AA_Profiler.frameOrder[#AA_Profiler.frameOrder + 1] = frameTime
    end
    frame.totalEvents = frame.totalEvents + 1
    frame.lastSeq     = seq
    frame.perAddon[addonName] = (frame.perAddon[addonName] or 0) + 1
end

-- =============================================================================
-- Aggregation
-- =============================================================================

function AA_Profiler.Aggregate()
    local results = {}
    for addonName, samples in pairs(AA_Profiler.data) do
        local totalMs = 0
        local calls   = #samples
        local worst   = 0
        for _, s in ipairs(samples) do
            totalMs = totalMs + s.dur
            if s.dur > worst then worst = s.dur end
        end
        local avg = calls > 0 and (totalMs / calls) or 0
        results[#results + 1] = {
            name  = addonName,
            calls = calls,
            avg   = avg,
            worst = worst,
            total = totalMs,
        }
    end
    -- Sort by total ms descending
    table.sort(results, function(a, b) return a.total > b.total end)
    return results
end

-- =============================================================================
-- Frame-log trimming (called when profiling ends)
-- =============================================================================

function AA_Profiler.TrimFrameLog()
    -- If errors were caught, keep only the 100 frames before (and including)
    -- the first error mark. If no errors, keep everything.
    if #AA_Profiler.errorMarks == 0 then return end

    local errorFrameTime = AA_Profiler.errorMarks[1].frameTime

    -- Find the last frameOrder index whose frameTime <= errorFrameTime
    local cutoffIdx = 0
    for i, ft in ipairs(AA_Profiler.frameOrder) do
        if ft <= errorFrameTime then
            cutoffIdx = i
        else
            break
        end
    end

    if cutoffIdx == 0 then return end  -- error fired before any frames were recorded

    -- Keep at most 100 frames up to and including cutoffIdx
    local startIdx = math.max(1, cutoffIdx - 99)
    local newOrder = {}
    for i = startIdx, cutoffIdx do
        newOrder[#newOrder + 1] = AA_Profiler.frameOrder[i]
    end

    -- Remove entries from frameLog that are no longer in newOrder
    local keep = {}
    for _, ft in ipairs(newOrder) do keep[ft] = true end
    for ft in pairs(AA_Profiler.frameLog) do
        if not keep[ft] then AA_Profiler.frameLog[ft] = nil end
    end

    AA_Profiler.frameOrder = newOrder
end

-- =============================================================================
-- UI — Main results window (created lazily on first /aap invocation)
-- =============================================================================

local SCENE_NAME = "AA_ProfilerScene"

function AA_Profiler.CreateWindow()
    if AA_Profiler.window then return end

    local titleFont = "$(GAMEPAD_BOLD_FONT)|44|soft-shadow-thick"
    local rowFont   = "$(GAMEPAD_MEDIUM_FONT)|32|soft-shadow-thin"
    local hintFont  = "$(GAMEPAD_MEDIUM_FONT)|24|soft-shadow-thin"

    -- ---- Main window --------------------------------------------------------
    local window = CreateTopLevelWindow("AA_ProfilerWindow")
    window:SetDimensions(1200, 760)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetMovable(true)
    window:SetMouseEnabled(false)
    window:SetClampedToScreen(true)
    window:SetHidden(true)

    -- ---- Background ---------------------------------------------------------
    local bg = CreateControl("AA_ProfilerWindowBg", window, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.04, 0.04, 0.10, 0.96)
    bg:SetEdgeColor(0.35, 0.35, 0.60, 1.0)

    -- ---- Title label --------------------------------------------------------
    local title = CreateControl("AA_ProfilerWindowTitle", window, CT_LABEL)
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 14, 10)
    title:SetFont(titleFont)
    title:SetText("AA Profiler — CPU Budget Results")
    title:SetColor(1.0, 0.80, 0.0, 1.0)

    -- ---- Close hint (top-right) ---------------------------------------------
    local hint = CreateControl("AA_ProfilerWindowHint", window, CT_LABEL)
    hint:SetAnchor(TOPRIGHT, window, TOPRIGHT, -14, 14)
    hint:SetFont(hintFont)
    hint:SetText("[B / /aap to close]")
    hint:SetColor(0.65, 0.65, 0.65, 1.0)

    -- ---- Status line (shows "in progress" or "complete") --------------------
    local status = CreateControl("AA_ProfilerWindowStatus", window, CT_LABEL)
    status:SetAnchor(TOPLEFT, window, TOPLEFT, 14, 66)
    status:SetFont(hintFont)
    status:SetText("")
    status:SetColor(0.88, 0.88, 0.88, 1.0)
    AA_Profiler.statusLabel = status

    -- ---- Column header ------------------------------------------------------
    local colHeader = CreateControl("AA_ProfilerWindowColHeader", window, CT_LABEL)
    colHeader:SetAnchor(TOPLEFT, window, TOPLEFT, 14, 100)
    colHeader:SetFont(rowFont)
    colHeader:SetColor(0.55, 0.88, 1.0, 1.0)
    colHeader:SetText(string.format("%-40s %8s %9s %10s %10s",
        "Addon", "Calls", "Avg ms", "Worst ms", "Total ms"))

    -- ---- Thin divider line --------------------------------------------------
    local divider = CreateControl("AA_ProfilerWindowDivider", window, CT_TEXTURE)
    divider:SetAnchor(TOPLEFT,  window, TOPLEFT,  12, 142)
    divider:SetAnchor(TOPRIGHT, window, TOPRIGHT, -12, 142)
    divider:SetHeight(1)
    divider:SetColor(0.35, 0.35, 0.60, 1.0)

    -- ---- Row labels ---------------------------------------------------------
    local rowPanel = CreateControl("AA_ProfilerRowPanel", window, CT_CONTROL)
    rowPanel:SetAnchor(TOPLEFT,     window, TOPLEFT,     12,  150)
    rowPanel:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -12, -12)

    local rowLabels = {}
    local maxRows = 13  -- floor((760 - 218 - 12) / 40)
    for idx = 1, maxRows do
        local lbl = CreateControl("AA_ProfilerRowLabel" .. idx, rowPanel, CT_LABEL)
        lbl:SetAnchor(TOPLEFT, rowPanel, TOPLEFT, 0, (idx - 1) * ROW_HEIGHT)
        lbl:SetFont(rowFont)
        lbl:SetColor(0.90, 0.90, 0.90, 1.0)
        lbl:SetText("")
        rowLabels[idx] = lbl
    end

    AA_Profiler.rowLabels = rowLabels
    AA_Profiler.window    = window

    -- ---- Scene --------------------------------------------------------------
    local scene = ZO_Scene:New(SCENE_NAME, SCENE_MANAGER)
    scene:AddFragment(ZO_FadeSceneFragment:New(window))
    AA_Profiler.scene = scene

    scene:RegisterCallback("StateChange", function(_, newState)
        if newState == SCENE_SHOWING then
            if SetGameCameraUIMode then SetGameCameraUIMode(true) end
            AA_Profiler.PopulateList()
        elseif newState == SCENE_SHOWN then
            KEYBIND_STRIP:AddKeybindButtonGroup(AA_Profiler.closeKeybinds)
            DIRECTIONAL_INPUT:Activate(AA_Profiler, AA_Profiler.window)
        elseif newState == SCENE_HIDING then
            KEYBIND_STRIP:RemoveKeybindButtonGroup(AA_Profiler.closeKeybinds)
            DIRECTIONAL_INPUT:Deactivate(AA_Profiler)
            if SetGameCameraUIMode then SetGameCameraUIMode(false) end
        end
    end)
end

-- Render the visible slice of lastResults starting at scrollOffset
function AA_Profiler.RenderRows()
    local rowLabels = AA_Profiler.rowLabels
    local results   = AA_Profiler.lastResults
    local offset    = AA_Profiler.scrollOffset
    local maxRows   = #rowLabels
    local total     = #results

    for idx = 1, maxRows do
        local r = results[offset + idx]
        if r then
            local line = string.format("%-40s %8d %9.1f %10d %10d",
                r.name, r.calls, r.avg, r.worst, r.total)
            rowLabels[idx]:SetText(line)
            if offset + idx == 1 and r.total > 0 then
                rowLabels[idx]:SetColor(1.0, 0.45, 0.25, 1.0)
            else
                rowLabels[idx]:SetColor(0.90, 0.90, 0.90, 1.0)
            end
        else
            rowLabels[idx]:SetText("")
            rowLabels[idx]:SetColor(0.90, 0.90, 0.90, 1.0)
        end
    end

    if total > maxRows then
        local last = math.min(offset + maxRows, total)
        AA_Profiler.statusLabel:SetText(string.format(
            "Profiling complete (3 s window). Showing %d\226\128\147%d of %d  (\226\134\149 right stick to scroll)",
            offset + 1, last, total))
    end
end

-- Rebuild the list contents from current data
function AA_Profiler.PopulateList()
    local rowLabels = AA_Profiler.rowLabels
    AA_Profiler.scrollOffset = 0

    for _, lbl in ipairs(rowLabels) do
        lbl:SetText("")
        lbl:SetColor(0.90, 0.90, 0.90, 1.0)
    end

    -- If still within the profiling window, say so and bail
    if AA_Profiler.active then
        local elapsed   = GetGameTimeMilliseconds() - AA_Profiler.startTime
        local remaining = math.max(0, 3000 - elapsed)
        AA_Profiler.statusLabel:SetText(string.format(
            "Profiling in progress... (%.0f ms elapsed, %.0f ms remaining)",
            elapsed, remaining))
        return
    end

    local results = AA_Profiler.Aggregate()
    AA_Profiler.lastResults = results

    if #results == 0 then
        AA_Profiler.statusLabel:SetText(
            "Profiling complete (3 s window). Sorted by total ms — highest first.")
        rowLabels[1]:SetText("  No callbacks were recorded during the profiling window.")
        return
    end

    if #results <= #rowLabels then
        AA_Profiler.statusLabel:SetText(
            "Profiling complete (3 s window). Sorted by total ms — highest first.")
    end
    AA_Profiler.RenderRows()
end

-- Gamepad keybind: B / Circle closes the window
AA_Profiler.closeKeybinds = {
    alignment = KEYBIND_STRIP_ALIGN_LEFT,
    {
        name     = "Back",
        keybind  = "UI_SHORTCUT_NEGATIVE",
        callback = function() AA_Profiler.ToggleWindow() end,
    },
}

-- Toggle the profiler window; refresh data each time it opens
function AA_Profiler.ToggleWindow()
    if not IsInGamepadPreferredMode() then
        CHAT_ROUTER:AddSystemMessage("|cFFCC44AA Profiler|r requires gamepad/controller UI mode.")
        return
    end
    AA_Profiler.CreateWindow()
    local state = AA_Profiler.scene:GetState()
    if state == SCENE_SHOWN or state == SCENE_SHOWING then
        SCENE_MANAGER:Hide(SCENE_NAME)
    else
        SCENE_MANAGER:Show(SCENE_NAME)
    end
end

-- =============================================================================
-- UI — Frame diagnostics window (created lazily on first /aapframes)
-- =============================================================================

local FRAME_SCENE_NAME = "AA_ProfilerFrameScene"

function AA_Profiler.CreateFrameWindow()
    if AA_Profiler.frameWindow then return end

    local titleFont = "$(GAMEPAD_BOLD_FONT)|44|soft-shadow-thick"
    local rowFont   = "$(GAMEPAD_MEDIUM_FONT)|28|soft-shadow-thin"
    local hintFont  = "$(GAMEPAD_MEDIUM_FONT)|24|soft-shadow-thin"

    -- ---- Frame window -------------------------------------------------------
    local window = CreateTopLevelWindow("AA_ProfilerFrameWindow")
    window:SetDimensions(1400, 760)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetMovable(true)
    window:SetMouseEnabled(false)
    window:SetClampedToScreen(true)
    window:SetHidden(true)

    -- ---- Background ---------------------------------------------------------
    local bg = CreateControl("AA_ProfilerFrameWindowBg", window, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.04, 0.04, 0.10, 0.96)
    bg:SetEdgeColor(0.35, 0.35, 0.60, 1.0)

    -- ---- Title label --------------------------------------------------------
    local title = CreateControl("AA_ProfilerFrameWindowTitle", window, CT_LABEL)
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 14, 10)
    title:SetFont(titleFont)
    title:SetText("AA Profiler — Frame Diagnostics")
    title:SetColor(1.0, 0.80, 0.0, 1.0)

    -- ---- Close hint (top-right) ---------------------------------------------
    local hint = CreateControl("AA_ProfilerFrameWindowHint", window, CT_LABEL)
    hint:SetAnchor(TOPRIGHT, window, TOPRIGHT, -14, 14)
    hint:SetFont(hintFont)
    hint:SetText("[B / /aapframes to close]")
    hint:SetColor(0.65, 0.65, 0.65, 1.0)

    -- ---- Status / summary line ----------------------------------------------
    local status = CreateControl("AA_ProfilerFrameWindowStatus", window, CT_LABEL)
    status:SetAnchor(TOPLEFT, window, TOPLEFT, 14, 66)
    status:SetFont(hintFont)
    status:SetText("")
    status:SetColor(0.88, 0.88, 0.88, 1.0)
    AA_Profiler.frameStatusLabel = status

    -- ---- Thin divider line --------------------------------------------------
    local divider = CreateControl("AA_ProfilerFrameWindowDivider", window, CT_TEXTURE)
    divider:SetAnchor(TOPLEFT,  window, TOPLEFT,  12, 100)
    divider:SetAnchor(TOPRIGHT, window, TOPRIGHT, -12, 100)
    divider:SetHeight(1)
    divider:SetColor(0.35, 0.35, 0.60, 1.0)

    -- ---- Row labels ---------------------------------------------------------
    local rowPanel = CreateControl("AA_ProfilerFrameRowPanel", window, CT_CONTROL)
    rowPanel:SetAnchor(TOPLEFT,     window, TOPLEFT,     12,  110)
    rowPanel:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -12, -12)

    local rowLabels = {}
    local maxRows = 15  -- floor((760 - 110 - 12) / 40)
    for idx = 1, maxRows do
        local lbl = CreateControl("AA_ProfilerFrameRowLabel" .. idx, rowPanel, CT_LABEL)
        lbl:SetAnchor(TOPLEFT, rowPanel, TOPLEFT, 0, (idx - 1) * ROW_HEIGHT)
        lbl:SetFont(rowFont)
        lbl:SetColor(0.90, 0.90, 0.90, 1.0)
        lbl:SetText("")
        rowLabels[idx] = lbl
    end

    AA_Profiler.frameRowLabels = rowLabels
    AA_Profiler.frameWindow    = window

    -- ---- Scene --------------------------------------------------------------
    local scene = ZO_Scene:New(FRAME_SCENE_NAME, SCENE_MANAGER)
    scene:AddFragment(ZO_FadeSceneFragment:New(window))
    AA_Profiler.frameScene = scene

    scene:RegisterCallback("StateChange", function(_, newState)
        if newState == SCENE_SHOWING then
            if SetGameCameraUIMode then SetGameCameraUIMode(true) end
            AA_Profiler.PopulateFrameList()
        elseif newState == SCENE_SHOWN then
            KEYBIND_STRIP:AddKeybindButtonGroup(AA_Profiler.frameCloseKeybinds)
            DIRECTIONAL_INPUT:Activate(AA_Profiler, AA_Profiler.frameWindow)
        elseif newState == SCENE_HIDING then
            KEYBIND_STRIP:RemoveKeybindButtonGroup(AA_Profiler.frameCloseKeybinds)
            DIRECTIONAL_INPUT:Deactivate(AA_Profiler)
            if SetGameCameraUIMode then SetGameCameraUIMode(false) end
        end
    end)
end

-- Render the visible slice of frameDisplayLines starting at frameScrollOffset
function AA_Profiler.RenderFrameRows()
    local rowLabels = AA_Profiler.frameRowLabels
    local lines     = AA_Profiler.frameDisplayLines
    local offset    = AA_Profiler.frameScrollOffset
    local maxRows   = #rowLabels

    for idx = 1, maxRows do
        local line = lines[offset + idx]
        if line then
            rowLabels[idx]:SetText(line.text)
            local c = line.color
            rowLabels[idx]:SetColor(c[1], c[2], c[3], c[4])
        else
            rowLabels[idx]:SetText("")
            rowLabels[idx]:SetColor(0.90, 0.90, 0.90, 1.0)
        end
    end
end

-- Build the flat display-line list from current frame data.
-- Returns peakTotal, peakFrameTime (the single frame with the most events).
function AA_Profiler.BuildFrameDisplayLines()
    local lines    = {}
    local frameLog = AA_Profiler.frameLog
    local errorMarks = AA_Profiler.errorMarks

    -- Index errorMarks by frameTime for O(1) lookup
    local errorByFrame = {}
    for _, mark in ipairs(errorMarks) do
        if not errorByFrame[mark.frameTime] then
            errorByFrame[mark.frameTime] = mark
        end
    end

    -- Set of frameTime values in frameOrder (for orphan-error detection)
    local frameOrderSet = {}
    for _, ft in ipairs(AA_Profiler.frameOrder) do frameOrderSet[ft] = true end

    -- Find peak frame and compute median for spike highlighting
    local peakTotal     = 0
    local peakFrameTime = nil
    local totals        = {}
    for _, ft in ipairs(AA_Profiler.frameOrder) do
        local f = frameLog[ft]
        if f then
            totals[#totals + 1] = f.totalEvents
            if f.totalEvents > peakTotal then
                peakTotal     = f.totalEvents
                peakFrameTime = ft
            end
        end
    end
    table.sort(totals)
    local median = 0
    if #totals > 0 then
        median = totals[math.max(1, math.floor(#totals / 2))]
    end
    local spikeThreshold = median * 3

    -- Build a merged, chronologically-sorted item list (frames + orphan errors)
    local allItems = {}
    for _, ft in ipairs(AA_Profiler.frameOrder) do
        local f = frameLog[ft]
        if f then
            allItems[#allItems + 1] = {
                ft      = ft,
                kind    = "frame",
                frame   = f,
                errMark = errorByFrame[ft],
            }
        end
    end
    -- Orphan error marks: error fired in a frame with no recorded addon callbacks
    for _, mark in ipairs(errorMarks) do
        if not frameOrderSet[mark.frameTime] then
            allItems[#allItems + 1] = { ft = mark.frameTime, kind = "orphan", mark = mark }
        end
    end
    table.sort(allItems, function(a, b) return a.ft < b.ft end)

    -- Render to flat line list
    -- ⚠ = \226\154\160  (U+26A0, UTF-8 in decimal escapes)
    local WARN = "\226\154\160"

    for _, item in ipairs(allItems) do
        if item.kind == "frame" then
            local f       = item.frame
            local isError = item.errMark ~= nil
            local isSpike = spikeThreshold > 0 and f.totalEvents > spikeThreshold

            -- Frame header line
            local headerText
            if isError then
                headerText = string.format(
                    "Frame @ %dms   Events: %d   %s ERROR FRAME",
                    item.ft, f.totalEvents, WARN)
            else
                headerText = string.format(
                    "Frame @ %dms   Events: %d",
                    item.ft, f.totalEvents)
            end

            local headerColor
            if isError then
                headerColor = { 1.0, 0.25, 0.25, 1.0 }   -- red
            elseif isSpike then
                headerColor = { 1.0, 0.75, 0.25, 1.0 }   -- orange
            else
                headerColor = { 0.55, 0.88, 1.0, 1.0 }   -- blue header
            end
            lines[#lines + 1] = { text = headerText, color = headerColor }

            -- Per-addon sub-rows: top 5 by count, descending
            local addonList = {}
            for name, count in pairs(f.perAddon) do
                addonList[#addonList + 1] = { name = name, count = count }
            end
            table.sort(addonList, function(a, b) return a.count > b.count end)
            local limit = math.min(5, #addonList)
            for i = 1, limit do
                local e = addonList[i]
                lines[#lines + 1] = {
                    text  = string.format("    %s: %d", e.name, e.count),
                    color = { 0.90, 0.90, 0.90, 1.0 },
                }
            end

        elseif item.kind == "orphan" then
            local mark  = item.mark
            local label = mark.isBudgetError
                and (WARN .. " CPU BUDGET ERROR (no matching frame events)")
                or  (WARN .. " ERROR (no matching frame events)")
            lines[#lines + 1] = {
                text  = string.format("%s @ %dms", label, item.ft),
                color = { 1.0, 0.25, 0.25, 1.0 },
            }
            if mark.message and mark.message ~= "" then
                lines[#lines + 1] = {
                    text  = "    " .. tostring(mark.message):sub(1, 120),
                    color = { 1.0, 0.55, 0.55, 1.0 },
                }
            end
        end
    end

    AA_Profiler.frameDisplayLines = lines
    return peakTotal, peakFrameTime
end

-- Rebuild the frame list contents from current data
function AA_Profiler.PopulateFrameList()
    local rowLabels = AA_Profiler.frameRowLabels
    AA_Profiler.frameScrollOffset = 0

    for _, lbl in ipairs(rowLabels) do
        lbl:SetText("")
        lbl:SetColor(0.90, 0.90, 0.90, 1.0)
    end

    -- If still collecting, show progress and bail
    if AA_Profiler.active then
        local elapsed   = GetGameTimeMilliseconds() - AA_Profiler.startTime
        local remaining = math.max(0, 3000 - elapsed)
        AA_Profiler.frameStatusLabel:SetText(string.format(
            "Profiling in progress... (%.0f ms elapsed, %.0f ms remaining)",
            elapsed, remaining))
        return
    end

    local peakTotal, peakFrameTime = AA_Profiler.BuildFrameDisplayLines()
    local lines      = AA_Profiler.frameDisplayLines
    local frameCount = #AA_Profiler.frameOrder
    local errorCount = #AA_Profiler.errorMarks

    -- Error capture status string
    local errStr
    if AA_Profiler.errorCaptureAvailable then
        if errorCount > 0 then
            errStr = string.format("captured %d error(s)", errorCount)
        else
            errStr = "no errors captured"
        end
    else
        errStr = "error capture: unavailable"
    end

    -- Peak frame summary
    local peakStr = ""
    if peakFrameTime then
        local peakFrame = AA_Profiler.frameLog[peakFrameTime]
        -- Find the dominant addon in the peak frame
        local domName, domCount = "", 0
        for name, count in pairs(peakFrame.perAddon) do
            if count > domCount then domCount = count; domName = name end
        end
        peakStr = string.format("  |  Peak @ %dms: %d events (%s: %d)",
            peakFrameTime, peakTotal, domName, domCount)
    end

    AA_Profiler.frameStatusLabel:SetText(string.format(
        "Frames: %d  |  %s%s  (\226\134\149 right stick to scroll)",
        frameCount, errStr, peakStr))

    if #lines == 0 then
        rowLabels[1]:SetText("  No frame data recorded during the profiling window.")
        return
    end

    AA_Profiler.RenderFrameRows()
end

-- Gamepad keybind: B / Circle closes the frame window
AA_Profiler.frameCloseKeybinds = {
    alignment = KEYBIND_STRIP_ALIGN_LEFT,
    {
        name     = "Back",
        keybind  = "UI_SHORTCUT_NEGATIVE",
        callback = function() AA_Profiler.ToggleFrameWindow() end,
    },
}

-- Toggle the frame diagnostics window
function AA_Profiler.ToggleFrameWindow()
    if not IsInGamepadPreferredMode() then
        CHAT_ROUTER:AddSystemMessage("|cFFCC44AA Profiler|r requires gamepad/controller UI mode.")
        return
    end
    AA_Profiler.CreateFrameWindow()
    local state = AA_Profiler.frameScene:GetState()
    if state == SCENE_SHOWN or state == SCENE_SHOWING then
        SCENE_MANAGER:Hide(FRAME_SCENE_NAME)
    else
        SCENE_MANAGER:Show(FRAME_SCENE_NAME)
    end
end

-- =============================================================================
-- Right-stick scrolling — shared handler for both windows
-- =============================================================================

local scrollCooldownEnd  = 0
local SCROLL_COOLDOWN_MS = 150

function AA_Profiler:UpdateDirectionalInput()
    local usingMain  = self.window      and not self.window:IsHidden()
    local usingFrame = self.frameWindow and not self.frameWindow:IsHidden()

    if not usingMain and not usingFrame then return end

    local _, y = DIRECTIONAL_INPUT:GetXY(ZO_DI_RIGHT_STICK)
    if math.abs(y) > 0.3 then
        local now = GetGameTimeMilliseconds()
        if now >= scrollCooldownEnd then
            -- positive Y = stick pushed up = scroll toward top (lower offset)
            local delta = y > 0 and -1 or 1

            if usingMain then
                local maxOffset = math.max(0, #self.lastResults - #self.rowLabels)
                local newOffset = math.max(0, math.min(self.scrollOffset + delta, maxOffset))
                if newOffset ~= self.scrollOffset then
                    self.scrollOffset = newOffset
                    scrollCooldownEnd = now + SCROLL_COOLDOWN_MS
                    AA_Profiler.RenderRows()
                end
            elseif usingFrame then
                local maxOffset = math.max(0, #self.frameDisplayLines - #self.frameRowLabels)
                local newOffset = math.max(0, math.min(self.frameScrollOffset + delta, maxOffset))
                if newOffset ~= self.frameScrollOffset then
                    self.frameScrollOffset = newOffset
                    scrollCooldownEnd = now + SCROLL_COOLDOWN_MS
                    AA_Profiler.RenderFrameRows()
                end
            end
        end
    end
end

-- =============================================================================
-- HOOKS — installed here, at the top level of the file, before any other
-- addon has a chance to call RegisterForEvent or RegisterForUpdate.
--
-- The wrappers are always in place; they only record data while
-- AA_Profiler.active == true (the 3-second profiling window).
-- =============================================================================

local original_RegisterForEvent = EVENT_MANAGER.RegisterForEvent
EVENT_MANAGER.RegisterForEvent = function(self, addonName, eventCode, callback)
    local wrapped = function(...)
        if not AA_Profiler.active then
            return callback(...)
        end
        local start   = GetGameTimeMilliseconds()
        callback(...)
        local elapsed = GetGameTimeMilliseconds() - start
        AA_Profiler.Record(addonName, elapsed)
    end
    return original_RegisterForEvent(self, addonName, eventCode, wrapped)
end

local original_RegisterForUpdate = EVENT_MANAGER.RegisterForUpdate
EVENT_MANAGER.RegisterForUpdate = function(self, addonName, interval, callback)
    local wrapped = function(...)
        if not AA_Profiler.active then
            return callback(...)
        end
        local start   = GetGameTimeMilliseconds()
        callback(...)
        local elapsed = GetGameTimeMilliseconds() - start
        AA_Profiler.Record(addonName, elapsed)
    end
    return original_RegisterForUpdate(self, addonName, interval, wrapped)
end

-- =============================================================================
-- ERROR HANDLER PROBE
-- Try to intercept ESO's error path so we can correlate errors with frames.
-- Uses a pcall guard so a failed probe never blocks addon load.
-- =============================================================================

do
    local installed = false

    -- Attempt: EVENT_UNHANDLED_ERROR (ESO-specific event, if available)
    if not installed then
        local ok = pcall(function()
            if EVENT_UNHANDLED_ERROR then
                original_RegisterForEvent(
                    EVENT_MANAGER, "AA_Profiler", EVENT_UNHANDLED_ERROR,
                    function(_, message)
                        -- Defensive inner pcall: the probe must never throw
                        pcall(function()
                            local msg       = tostring(message or "")
                            local isBudget  = msg:find("CPU time budget") ~= nil
                            AA_Profiler.errorMarks[#AA_Profiler.errorMarks + 1] = {
                                seq           = AA_Profiler.seq,
                                frameTime     = GetGameTimeMilliseconds(),
                                message       = msg,
                                isBudgetError = isBudget,
                            }
                        end)
                    end
                )
                installed = true
            end
        end)
        if ok and installed then
            AA_Profiler.errorCaptureAvailable = true
        end
    end

    -- Additional attempts could be added here if EVENT_UNHANDLED_ERROR is
    -- not available on all ESO platforms. For now, if the above failed,
    -- errorCaptureAvailable remains false and the frame view surfaces that.
end

-- =============================================================================
-- START PROFILING — activate immediately at file-load time
-- =============================================================================

AA_Profiler.active    = true
AA_Profiler.startTime = GetGameTimeMilliseconds()

zo_callLater(function()
    AA_Profiler.active = false
    AA_Profiler.TrimFrameLog()
    CHAT_ROUTER:AddSystemMessage(
        "Addon profiling complete (3 s). Type /aap for results, /aapframes for frame diagnostics.")
end, 3000)

-- =============================================================================
-- SLASH COMMANDS
-- =============================================================================

SLASH_COMMANDS["/aap"] = function()
    AA_Profiler.ToggleWindow()
end

SLASH_COMMANDS["/profiler"] = function()
    AA_Profiler.ToggleWindow()
end

SLASH_COMMANDS["/aapframes"] = function()
    AA_Profiler.ToggleFrameWindow()
end
