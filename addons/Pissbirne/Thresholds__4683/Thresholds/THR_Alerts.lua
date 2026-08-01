---------------------------------------------------------------------------
-- Thresholds - alert output (prominent on-screen text + sound)
---------------------------------------------------------------------------

local THR = Thresholds

local ALERT_WIDTH = 600
local MAX_ALERTS = 4              -- visible-at-once cap
local STACK_SPACING = 4           -- px between stacked shared-position alerts
local POOL_TIMER_PREFIX = "Thresholds_AlertTimer" -- + slot index
local SHARED_KEY = "shared"       -- posKey of alerts without a custom position
local SOUND_REPEAT_TIMER = "Thresholds_SoundRepeat"
local SOUND_REPEAT_INTERVAL = 250 -- ms between repeated plays
local EXAMPLE_TEXT = "Boss Name  70%"

-- Drag/positioning proxy: shows the unlock example and the per-alert
-- positioning drag target. Never displays real alerts (the pool does).
local alertControl, alertLabel, alertBG
local positionCallback = nil -- active while dragging a per-alert position

-- Display-only alert pool (created lazily up to MAX_ALERTS, reused).
local pool = {}
local alertSeq = 0 -- monotonic; ordering for eviction and stacking
local exampleSlot, exampleSeq -- pooled example replaces itself
local ReflowSharedStack -- forward declaration

-- Curated selection of reliable SOUNDS keys for the settings dropdown.
THR.SOUND_CHOICES = {
    "ABILITY_ULTIMATE_READY",
    "ACHIEVEMENT_AWARDED",
    "BATTLEGROUND_COUNTDOWN_FINISH",
    "CHAMPION_POINTS_COMMITTED",
    "DUEL_START",
    "DUEL_WON",
    "GROUP_JOIN",
    "MAIL_SENT",
    "NEW_NOTIFICATION",
    "OBJECTIVE_COMPLETED",
    "QUEST_COMPLETED",
    "SCRIPTED_WORLD_EVENT_INVITED",
}

-- "DUEL_START" -> "Duel Start"
function THR.GetSoundDisplayName(soundKey)
    local pretty = string.gsub(string.lower(soundKey), "_", " ")
    return string.gsub(pretty, "(%a)([%a]*)", function(first, rest)
        return string.upper(first) .. rest
    end)
end

function THR.FormatPercentValue(value)
    if value % 1 == 0 then
        return tostring(math.floor(value))
    end
    return string.format("%.1f", value)
end

-- Plays soundKey (default: the global alert sound) repeatCount times
-- (default 1) spaced SOUND_REPEAT_INTERVAL apart. A newer call cancels a
-- pending repeat chain so overlapping alerts never stack into noise.
function THR.PlayAlertSound(soundKey, repeatCount)
    local sound = SOUNDS[soundKey or THR.SV.alerts.soundName]
    if not sound then return end

    EVENT_MANAGER:UnregisterForUpdate(SOUND_REPEAT_TIMER)
    PlaySound(sound)

    local remaining = (repeatCount or 1) - 1
    if remaining > 0 then
        EVENT_MANAGER:RegisterForUpdate(SOUND_REPEAT_TIMER, SOUND_REPEAT_INTERVAL, function()
            PlaySound(sound)
            remaining = remaining - 1
            if remaining <= 0 then
                EVENT_MANAGER:UnregisterForUpdate(SOUND_REPEAT_TIMER)
            end
        end)
    end
end

---------------------------------------------------------------------------
-- PROMINENT ALERT CONTROL
---------------------------------------------------------------------------
function THR.CreateAlertDisplay()
    local wm = WINDOW_MANAGER
    local SV = THR.SV

    alertControl = wm:CreateTopLevelWindow("Thresholds_AlertFrame")
    alertControl:SetClampedToScreen(true)
    alertControl:SetMovable(not SV.frame.locked)
    alertControl:SetMouseEnabled(not SV.frame.locked)
    alertControl:SetHandler("OnMoveStop", function()
        local centerX, centerY = alertControl:GetCenter()
        local x = centerX - GuiRoot:GetWidth() / 2
        local y = centerY
        if positionCallback then
            positionCallback(x, y)
        else
            SV.alerts.textX = x
            SV.alerts.textY = y
            THR.ApplyAlertPosition()
        end
    end)
    alertControl:SetHidden(true)

    -- Drag target, only visible while unlocked.
    alertBG = wm:CreateControl("Thresholds_AlertBG", alertControl, CT_BACKDROP)
    alertBG:SetAnchorFill(alertControl)
    alertBG:SetCenterColor(0, 0, 0, 0.45)
    alertBG:SetEdgeTexture("", 1, 1, 2, 0)
    alertBG:SetEdgeColor(0, 0, 0, 0.7)
    alertBG:SetHidden(SV.frame.locked)

    alertLabel = wm:CreateControl("Thresholds_AlertLabel", alertControl, CT_LABEL)
    alertLabel:SetAnchor(CENTER, alertControl, CENTER, 0, 0)
    alertLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    alertLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    alertLabel:SetColor(1, 1, 1, 1)
    alertLabel:SetDrawTier(DT_HIGH)

    THR.UpdateAlertFont()
    THR.ApplyAlertPosition()
end

function THR.UpdateAlertFont()
    if not alertControl then return end
    local size = THR.SV.alerts.textFontSize
    alertLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", size))
    alertControl:SetDimensions(ALERT_WIDTH, size + 16)
end

-- Anchors the alert control; nil coordinates fall back to the saved default
-- position (or upper-center when nothing was ever saved).
local function ApplyAnchor(x, y)
    local SV = THR.SV.alerts
    alertControl:ClearAnchors()
    alertControl:SetAnchor(CENTER, GuiRoot, TOP,
        x or SV.textX or 0,
        y or SV.textY or 280)
end

function THR.ApplyAlertPosition()
    if not alertControl then return end
    ApplyAnchor(nil, nil)
    ReflowSharedStack() -- a moved shared anchor moves the live stack too
end

function THR.ResetAlertPosition()
    THR.SV.alerts.textX = nil
    THR.SV.alerts.textY = nil
    THR.ApplyAlertPosition()
end

-- heightPad: 16 for the proxy (comfortable drag target), 4 for pooled
-- controls (tight box so stacked alerts sit ~STACK_SPACING apart).
local function StyleControl(control, label, text, style, heightPad)
    local size = style.fontSize or THR.SV.alerts.textFontSize
    label:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", size))
    control:SetDimensions(ALERT_WIDTH, size + heightPad)
    local color = style.color
    if color then
        label:SetColor(color[1], color[2], color[3], 1)
    else
        label:SetColor(1, 1, 1, 1)
    end
    label:SetText(text)
end

-- Persistent proxy example while frames are unlocked; no timer ever.
local function ShowUnlockExample()
    StyleControl(alertControl, alertLabel, EXAMPLE_TEXT, {}, 16)
    ApplyAnchor(nil, nil)
    alertControl:SetHidden(false)
end

---------------------------------------------------------------------------
-- POOLED ALERTS
---------------------------------------------------------------------------
local function AcquireSlotControl(index)
    local wm = WINDOW_MANAGER
    local control = wm:CreateTopLevelWindow("Thresholds_AlertPooled" .. index)
    control:SetClampedToScreen(true)
    control:SetHidden(true)

    local label = wm:CreateControl("Thresholds_AlertPooledLabel" .. index, control, CT_LABEL)
    label:SetAnchor(CENTER, control, CENTER, 0, 0)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetColor(1, 1, 1, 1)
    label:SetDrawTier(DT_HIGH)

    return {
        control = control,
        label = label,
        timerName = POOL_TIMER_PREFIX .. index,
        inUse = false,
        posKey = nil,
        seq = 0,
    }
end

local function FreeSlot(slot)
    EVENT_MANAGER:UnregisterForUpdate(slot.timerName)
    slot.control:SetHidden(true)
    slot.inUse = false
end

local function HideAllPooledAlerts()
    for i = 1, #pool do
        FreeSlot(pool[i])
    end
end

-- Re-anchors all shared-position alerts: newest at the shared anchor (or
-- hanging below the unlock example so the drag target stays unobscured),
-- older ones chained below. TOP/BOTTOM anchors are center-aligned, so
-- mixed font sizes stack cleanly.
ReflowSharedStack = function()
    local shared = {}
    for i = 1, #pool do
        if pool[i].inUse and pool[i].posKey == SHARED_KEY then
            shared[#shared + 1] = pool[i]
        end
    end
    table.sort(shared, function(a, b) return a.seq > b.seq end)
    for i = 1, #shared do
        local control = shared[i].control
        control:ClearAnchors()
        if i > 1 then
            control:SetAnchor(TOP, shared[i - 1].control, BOTTOM, 0, STACK_SPACING)
        elseif alertControl and not alertControl:IsHidden() and not positionCallback then
            control:SetAnchor(TOP, alertControl, BOTTOM, 0, STACK_SPACING)
        else
            local SV = THR.SV.alerts
            control:SetAnchor(CENTER, GuiRoot, TOP, SV.textX or 0, SV.textY or 280)
        end
    end
end

-- Shows an alert in a pooled control (up to MAX_ALERTS at once). Alerts at
-- the same custom position replace each other (timer restarts); alerts at
-- the shared position stack vertically. When the pool is full, the oldest
-- visible alert is evicted. style is optional: { color = {r,g,b},
-- fontSize = n, duration = n, x = n, y = n }; missing fields fall back to
-- the global alert settings. Returns the slot used (internal).
-- Note: a custom position numerically equal to the shared default is a
-- different posKey and can overlap the stack head; accepted limitation.
function THR.ShowProminentAlert(text, style)
    if not alertControl then return end
    if positionCallback then return end -- positioning mode owns the screen
    style = style or {}

    local posKey = SHARED_KEY
    if style.x and style.y then
        posKey = style.x .. ":" .. style.y
    end

    -- Slot selection: replace same custom position -> free slot -> grow
    -- pool -> evict the oldest visible alert (smallest seq, any kind).
    local slot
    if posKey ~= SHARED_KEY then
        for i = 1, #pool do
            if pool[i].inUse and pool[i].posKey == posKey then
                slot = pool[i]
                break
            end
        end
    end
    if not slot then
        for i = 1, #pool do
            if not pool[i].inUse then
                slot = pool[i]
                break
            end
        end
    end
    if not slot and #pool < MAX_ALERTS then
        slot = AcquireSlotControl(#pool + 1)
        pool[#pool + 1] = slot
    end
    if not slot then
        for i = 1, #pool do
            if not slot or pool[i].seq < slot.seq then
                slot = pool[i]
            end
        end
    end

    -- Re-registering an existing update name is a silent no-op, so the old
    -- timer MUST be unregistered before the slot is reused - otherwise it
    -- keeps running and hides the new alert early.
    EVENT_MANAGER:UnregisterForUpdate(slot.timerName)

    StyleControl(slot.control, slot.label, text, style, 4)
    alertSeq = alertSeq + 1
    slot.posKey = posKey
    slot.seq = alertSeq
    slot.inUse = true
    if posKey ~= SHARED_KEY then
        slot.control:ClearAnchors()
        slot.control:SetAnchor(CENTER, GuiRoot, TOP, style.x, style.y)
    end
    slot.control:SetHidden(false)

    local duration = style.duration or THR.SV.alerts.textDuration
    EVENT_MANAGER:RegisterForUpdate(slot.timerName, duration * 1000, function()
        EVENT_MANAGER:UnregisterForUpdate(slot.timerName)
        FreeSlot(slot)
        ReflowSharedStack()
    end)

    ReflowSharedStack()
    return slot
end

---------------------------------------------------------------------------
-- PER-ALERT POSITIONING MODE
---------------------------------------------------------------------------
-- Shows the alert as a drag target; every drop calls onMoved(x, y) so the
-- editor can capture the coordinates. While active, regular alerts are
-- suppressed. Ended by EndAlertPositioning, a lock toggle or panel close.
function THR.BeginAlertPositioning(text, style, onMoved)
    if not alertControl then return end
    style = style or {}
    positionCallback = onMoved
    HideAllPooledAlerts() -- the drag target is the only alert text on screen
    StyleControl(alertControl, alertLabel, text, style, 16)
    ApplyAnchor(style.x, style.y)
    alertControl:SetHidden(false)
    alertControl:SetMovable(true)
    alertControl:SetMouseEnabled(true)
    alertBG:SetHidden(false)
end

function THR.EndAlertPositioning()
    if not positionCallback then return end
    positionCallback = nil
    local locked = THR.SV.frame.locked
    alertControl:SetMovable(not locked)
    alertControl:SetMouseEnabled(not locked)
    alertBG:SetHidden(locked)
    THR.ApplyAlertPosition()
    if locked then
        alertControl:SetHidden(true)
    else
        ShowUnlockExample()
    end
    ReflowSharedStack()
end

function THR.IsAlertPositioning()
    return positionCallback ~= nil
end

-- While unlocked the example text stays visible as a drag target. Pooled
-- alerts are untouched by lock toggles; they run out their own timers.
function THR.SetAlertLocked(locked)
    if not alertControl then return end
    positionCallback = nil -- a lock toggle always ends per-alert positioning
    alertControl:SetMovable(not locked)
    alertControl:SetMouseEnabled(not locked)
    alertBG:SetHidden(locked)
    if locked then
        alertControl:SetHidden(true)
    else
        ShowUnlockExample()
    end
    ReflowSharedStack() -- stack head swaps between proxy and shared anchor
end

function THR.ShowExampleAlert()
    if not alertControl then return end
    if positionCallback then return end
    if not THR.SV.frame.locked then
        -- The persistent unlock example is showing; restyle it in place
        -- instead of stacking a second example under it.
        ShowUnlockExample()
        ReflowSharedStack()
        return
    end
    -- Timed pooled example that replaces itself (unlike real shared alerts,
    -- which stack) so slider dragging never piles up identical examples.
    if exampleSlot and exampleSlot.inUse and exampleSlot.seq == exampleSeq then
        FreeSlot(exampleSlot)
    end
    exampleSlot = THR.ShowProminentAlert(EXAMPLE_TEXT)
    exampleSeq = exampleSlot and exampleSlot.seq or nil
end

---------------------------------------------------------------------------
-- ALERT DISPATCH
---------------------------------------------------------------------------
function THR.BuildDefaultAlertText(subjectName, thresholdValue)
    return string.format("%s  %s%%", subjectName, THR.FormatPercentValue(thresholdValue))
end

-- entry is a normalized threshold entry (THR.GetThresholdsFor): value plus
-- optional per-alert overrides. Missing fields inherit the global alert
-- settings; the master toggles stay kill-switches, per-alert noText/noSound
-- only subtract.
function THR.FireAlert(subjectName, entry)
    local SV = THR.SV
    if SV.alerts.text and not entry.noText then
        local text = entry.text
        if not text or text == "" then
            text = THR.BuildDefaultAlertText(subjectName, entry.value)
        end
        THR.ShowProminentAlert(text, {
            color = entry.color,
            fontSize = entry.fontSize,
            duration = entry.duration,
            x = entry.x,
            y = entry.y,
        })
    end
    if SV.alerts.sound and not entry.noSound then
        THR.PlayAlertSound(entry.sound, entry.soundRepeat)
    end
end
