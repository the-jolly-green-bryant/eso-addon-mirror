-- Common Works — HUD widgets
--
-- Frames outside the tracker: alerts, drain bars, mount sprint icon and light attack line.
-- UI.lua owns the panel, widget registry and shared CreateSolidBar (also used by ready checks).
-- Loads after UI.lua creates CW.UI.

CommonWorksUI = CommonWorksUI or {}
local CW = CommonWorksUI

local UI = CW.UI
local WM = WINDOW_MANAGER
local EM = EVENT_MANAGER

-- Native art is 64x64; 100% draws pixel-for-pixel, while the default is 50%.
local MOUNT_SPRINT_ICON = "EsoUI/Art/Icons/mapkey/mapkey_stables.dds"
local MOUNT_SPRINT_ICON_BASE = 64

-- The slider only offers 14-72; a hand-edited SavedVars file does not.
--- @param prefix string  settings-key prefix, e.g. "healthAlert"
--- @return number
local function WidgetFontSize(prefix)
    return zo_clamp(CW.SavedVars[prefix .. "FontSize"], 14, 72)
end

--- @param prefix string
--- @return string  an ESO font token: face|size|style
local function WidgetFont(prefix)
    UI.RefreshFontChoices()
    local face = UI.FONTS[CW.SavedVars[prefix .. "FontFace"]]
        or UI.FONTS[CW.defaults[prefix .. "FontFace"]]
    return string.format("%s|%d|soft-shadow-thick", face, WidgetFontSize(prefix))
end

-- Size for the longest phrase at this font size, plus soft-shadow padding.
--- @param prefix string
--- @param minWidth number
--- @param widthPerPt number
--- @param padding number
--- @return number width, number height
local function WidgetSize(prefix, minWidth, widthPerPt, padding)
    local size = WidgetFontSize(prefix)
    return math.max(minWidth, size * widthPerPt), size + padding
end

-- Trim text; blank uses the default. Pass directly to SetText:
-- string.format would interpret a literal "%".
--- @param key string  SavedVars key
--- @return string
local function WidgetText(key)
    local text = zo_strtrim(CW.SavedVars[key])
    if text == "" then text = CW.defaults[key] end
    return text
end

-- Raised above the settings window by UI.SetAboveMenus.
UI.widgetWindows = {}

-- Overlay TLC; clamp only while dragging to avoid snapping near screen edges.
-- Save the drop position in posKey.
--- @param name string
--- @param drawLevel integer
--- @param posKey string
local function CreateWidgetWindow(name, drawLevel, posKey)
    local frame = WM:CreateTopLevelWindow(name)
    UI.widgetWindows[#UI.widgetWindows + 1] = frame
    frame:SetClampedToScreen(false)
    frame:SetDrawLayer(DL_OVERLAY)
    frame:SetDrawLevel(drawLevel)
    frame:SetMouseEnabled(false)
    frame:SetMovable(false)
    frame:SetHidden(true)
    frame:SetHandler("OnMoveStart", function(self) self:SetClampedToScreen(true) end)
    frame:SetHandler("OnMoveStop", function(self)
        UI.SaveWidgetPosition(self, posKey)
        self:SetClampedToScreen(false)
    end)
    return frame
end

local function CreateWidgetLabel(name, frame)
    local label = WM:CreateControl(name, frame, CT_LABEL)
    label:SetAnchor(CENTER, frame, CENTER, 0, 0)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetDrawLevel(3)
    return label
end

-- Returns whether placement needs a stand-in because nothing live is showing.
--- @param frame table
--- @param enabled boolean
--- @param showing boolean
--- @param placing boolean
--- @return boolean  true while placing with nothing live to show
local function ApplyWidgetVisibility(frame, enabled, showing, placing)
    showing = enabled == true and showing == true
    placing = enabled == true and placing == true and UI.SettingsPanelOpen()
    frame:SetHidden(not (showing or placing))
    frame:SetMouseEnabled(placing)
    frame:SetMovable(placing)
    frame:SetAlpha((showing or placing) and 1 or 0)
    return placing and not showing
end

-- Timed alerts
-- One pending hide per showing flag; a later show cancels it.
local hideCalls = {}

local function HideNow(field, applyVisibility)
    if hideCalls[field] then zo_removeCallLater(hideCalls[field]) end
    UI[field] = false
    applyVisibility()
end

local function ShowFor(field, ms, applyVisibility)
    if hideCalls[field] then zo_removeCallLater(hideCalls[field]) end
    UI[field] = true
    applyVisibility()
    hideCalls[field] = zo_callLater(function() HideNow(field, applyVisibility) end, ms)
end

-- Bars and underlines
-- Anchor under the label so font padding cannot widen the gap below the glyphs.
local BAR_GAP = 2
local BAR_TRACK_ALPHA = 0.25

local function LabelWidth(label)
    return zo_round(label:GetTextWidth())
end

local function AnchorUnderLabel(control, label)
    control:ClearAnchors()
    control:SetAnchor(TOP, label, CENTER, 0, label:GetFontHeight() * 0.5 + BAR_GAP)
end

local function ApplyBarColors(track, fill, c, height)
    track:SetCenterColor(c[1], c[2], c[3], (c[4] or 1) * BAR_TRACK_ALPHA)
    fill:SetHeight(height)
    fill:SetCenterColor(unpack(c))
end

-- Frame and centered label at the saved position. Caller sets text, style and visibility.
--- @param control string
--- @param posKey string
--- @param drawLevel integer
--- @return table frame, table label
local function BuildLabelWidget(control, posKey, drawLevel)
    local frame = CreateWidgetWindow(control, drawLevel, posKey)
    local label = CreateWidgetLabel(control .. "Label", frame)
    UI.ApplyWidgetPosition(frame, posKey)
    return frame, label
end

-- Size for the longest phrase and paint the label; return dimensions for flash overlays.
--- @param color table?  nil for the widgets that paint their own
--- @return number width, number height
local function ApplyLabelStyle(frame, label, prefix, minWidth, widthPerPt, padding, color)
    local w, h = WidgetSize(prefix, minWidth, widthPerPt, padding)
    frame:SetDimensions(w, h)
    label:SetDimensions(w, h)
    label:SetFont(WidgetFont(prefix))
    if color then label:SetColor(unpack(color)) end
    return w, h
end

-- ===== MOUNT SPRINT ICON =====
-- Lit while toggle-sprint is draining stamina.
-- Sized as a percentage of MOUNT_SPRINT_ICON_BASE, not raw pixels: 100% is the
-- texture's native 64px.
--- @return number  percent of MOUNT_SPRINT_ICON_BASE
function UI.MountSprintIconScale()
    return zo_clamp(CW.SavedVars.mountSprintIconScale, 10, 100)
end

local function DeadlineActive(deadline)
    return deadline ~= nil and deadline > GetGameTimeMilliseconds()
end

local tintPreviewCall
local function CancelTintPreview()
    if tintPreviewCall then zo_removeCallLater(tintPreviewCall) end
    UI.mountSprintIconTintPreviewUntil = nil
end

function UI.ApplyMountSprintIconSize()
    local size = zo_round(MOUNT_SPRINT_ICON_BASE * UI.MountSprintIconScale() / 100)
    UI.mountSprintIcon:SetDimensions(size, size)
    UI.mountSprintIconTexture:SetDimensions(size, size)
end

-- Gray unless sprint drains stamina; settings shows the tint while placing or previewing.
function UI.ApplyMountSprintIconVisualState()
    local draining = CW.MountedToggleSprintActive() and CW.MountSprintStaminaDraining()
    local placing = UI.mountSprintIconPlacement == true
    local preview = DeadlineActive(UI.mountSprintIconTintPreviewUntil)
    local tex = UI.mountSprintIconTexture

    if draining or placing or preview then
        tex:SetDesaturation(0)
        tex:SetColor(unpack(CW.SavedVars.mountSprintIconTint))
        UI.mountSprintIcon:SetAlpha(1.00)
    else
        tex:SetDesaturation(1)
        tex:SetColor(0.62, 0.62, 0.62, 1)
        UI.mountSprintIcon:SetAlpha(0.50)
    end
end

-- Custom visibility clears the tint preview's deadline on expiry.
-- Draggable whenever visible, allowing a grab when gameplay gains a cursor.
function UI.ApplyMountSprintIconVisibility()
    local enabled = CW.SavedVars.showMountSprintIcon
    -- Keep the placement flag: it belongs to the settings tab, so re-enabling shows the icon again.
    if not enabled then CancelTintPreview() end
    local active = enabled and CW.MountedToggleSprintActive()
    local placing = enabled and UI.mountSprintIconPlacement == true
    local preview = enabled and DeadlineActive(UI.mountSprintIconTintPreviewUntil)

    if UI.mountSprintIconTintPreviewUntil and not preview then UI.mountSprintIconTintPreviewUntil = nil end
    local shown = active or placing or preview
    UI.mountSprintIcon:SetHidden(not shown)
    UI.mountSprintIcon:SetMouseEnabled(shown)
    UI.mountSprintIcon:SetMovable(shown)
    UI.ApplyMountSprintIconVisualState()
end

function UI.PreviewMountSprintIconTint()
    CancelTintPreview()
    UI.mountSprintIconTintPreviewUntil = GetGameTimeMilliseconds() + 1500
    UI.ApplyMountSprintIconVisibility()
    tintPreviewCall = zo_callLater(function()
        UI.mountSprintIconTintPreviewUntil = nil
        UI.ApplyMountSprintIconVisibility()
    end, 1500)
end

-- Show for placement without mounting; panel OnHide and the gameplay callback clear the flag.
--- @param on boolean
function UI.SetMountSprintIconPlacementMode(on)
    UI.mountSprintIconPlacement = on == true
    UI.ApplyMountSprintIconVisibility()
end
CW.RegisterHudWidget(UI.SetMountSprintIconPlacementMode, UI.ApplyMountSprintIconVisibility, "qol")

function UI.BuildMountSprintIcon()
    if UI.mountSprintIcon then return end

    -- Do not re-arm placement on drop: gameplay drags would leave the icon stuck visible.
    local icon = CreateWidgetWindow("CW_MountSprintIcon", 2, "mountSprintIconPosition")
    UI.mountSprintIcon = icon

    local tex = WM:CreateControl("CW_MountSprintIconTexture", icon, CT_TEXTURE)
    tex:SetTexture(MOUNT_SPRINT_ICON)
    tex:SetAnchor(CENTER, icon, CENTER, 0, 0)
    tex:SetDrawLevel(2)
    UI.mountSprintIconTexture = tex

    UI.ApplyMountSprintIconSize()
    UI.ApplyWidgetPosition(icon, "mountSprintIconPosition")
    UI.ApplyMountSprintIconVisibility()
end

-- ===== OFF BALANCE TRACKER =====
-- Text-width underline in the label's color, draining from the right.
-- Only height is configurable; 0 removes it.
local OFF_BALANCE_BAR_TIMER = "CW_OffBalanceBarTick"
local OFF_BALANCE_BAR_TICK_MS = 50

--- @return number  px; 0 removes the bar
function UI.OffBalanceBarHeight()
    return zo_clamp(CW.SavedVars.offBalanceBarHeight, 0, 20)
end

local function SetOffBalanceBarProgress(progress)
    UI.offBalanceBarProgress = zo_clamp(progress or 1, 0, 1)
    local width = UI.offBalanceBarWidth * UI.offBalanceBarProgress
    UI.offBalanceBarFill:SetHidden(width < 1)
    if width >= 1 then UI.offBalanceBarFill:SetWidth(width) end
end

local function StopOffBalanceBarTicking()
    if not UI.offBalanceBarTicking then return end
    EM:UnregisterForUpdate(OFF_BALANCE_BAR_TIMER)
    UI.offBalanceBarTicking = false
end

local function OffBalanceBarTick()
    local endAt, duration = UI.offBalanceBarEnd, UI.offBalanceBarDuration
    if not (endAt and duration and duration > 0) then
        SetOffBalanceBarProgress(1)
        StopOffBalanceBarTicking()
        return
    end
    -- GetUnitBuffInfo's end time is in game-time seconds.
    local remaining = endAt - GetGameTimeSeconds()
    SetOffBalanceBarProgress(remaining / duration)
    -- Backstop if the buff's FADED event never arrives.
    if remaining <= 0 then StopOffBalanceBarTicking() end
end

-- Missing or zero-length window: keep a full, unticked bar to mean "no timer".
local function SetOffBalanceBarWindow(timeStarted, timeEnding)
    local duration = timeEnding and timeEnding - timeStarted or 0

    if not (CW.offBalanceActive == true and duration > 0) then
        UI.offBalanceBarEnd, UI.offBalanceBarDuration = nil, nil
        StopOffBalanceBarTicking()
        SetOffBalanceBarProgress(1)
        return
    end

    UI.offBalanceBarEnd, UI.offBalanceBarDuration = timeEnding, duration
    if not UI.offBalanceBarTicking then
        UI.offBalanceBarTicking = true
        EM:RegisterForUpdate(OFF_BALANCE_BAR_TIMER, OFF_BALANCE_BAR_TICK_MS, OffBalanceBarTick)
    end
    OffBalanceBarTick()
end

local function ApplyOffBalanceBarStyle()
    local height = UI.OffBalanceBarHeight()
    local c = CW.SavedVars.offBalanceColor
    -- Measure after setting the font; underline the text width.
    local width = LabelWidth(UI.offBalanceLabel)
    UI.offBalanceBarWidth = width

    UI.offBalanceBarTrack:SetHidden(height <= 0 or width <= 0)
    UI.offBalanceBarTrack:SetDimensions(width, height)
    ApplyBarColors(UI.offBalanceBarTrack, UI.offBalanceBarFill, c, height)
    AnchorUnderLabel(UI.offBalanceBarTrack, UI.offBalanceLabel)

    SetOffBalanceBarProgress(UI.offBalanceBarProgress)
end

function UI.ApplyOffBalanceTrackerStyle()
    local c = CW.SavedVars.offBalanceColor
    local w, h = ApplyLabelStyle(UI.offBalanceTracker, UI.offBalanceLabel, "offBalance", 220, 11, 22, c)
    UI.offBalanceFlash:SetDimensions(w, h)
    UI.offBalanceFlash:SetCenterColor(c[1], c[2], c[3], 1)
    UI.offBalanceFlash:SetEdgeColor(c[1], c[2], c[3], 0)
    UI.offBalanceFlash:SetAlpha(0)
    ApplyOffBalanceBarStyle()
end

function UI.ApplyOffBalanceTrackerVisibility()
    ApplyWidgetVisibility(UI.offBalanceTracker,
        CW.SavedVars.showOffBalanceTracker,
        CW.offBalanceActive == true,
        UI.offBalanceTrackerPlacement == true)
end

function UI.ResetOffBalanceFlash()
    UI.offBalanceFlashTimeline:Stop()
    UI.offBalanceFlash:SetAlpha(0)
end

function UI.PlayOffBalanceFlash()
    if not CW.SavedVars.offBalanceFlash then return end
    UI.ResetOffBalanceFlash()
    UI.offBalanceFlashTimeline:PlayFromStart()
end

--- @param on boolean
function UI.SetOffBalanceTrackerPlacementMode(on)
    UI.offBalanceTrackerPlacement = on == true
    UI.ApplyOffBalanceTrackerVisibility()
end
CW.RegisterHudWidget(UI.SetOffBalanceTrackerPlacementMode, UI.ApplyOffBalanceTrackerVisibility, "alerts")

--- @param active boolean
--- @param timeStarted number?  game-time seconds
--- @param timeEnding number?
function UI.SetOffBalanceTrackerActive(active, timeStarted, timeEnding)
    local wasActive = CW.offBalanceActive == true
    CW.offBalanceActive = active == true
    SetOffBalanceBarWindow(timeStarted, timeEnding)
    UI.ApplyOffBalanceTrackerVisibility()
    if CW.offBalanceActive and not wasActive then
        UI.PlayOffBalanceFlash()
    elseif not CW.offBalanceActive then
        UI.ResetOffBalanceFlash()
    end
end

function UI.BuildOffBalanceTracker()
    if UI.offBalanceTracker then return end

    local tracker = CreateWidgetWindow("CW_OffBalanceTracker", 3, "offBalancePosition")
    UI.offBalanceTracker = tracker

    local flash = WM:CreateControlFromVirtual("CW_OffBalanceFlash", tracker, "ZO_DefaultBackdrop")
    flash:ClearAnchors()
    flash:SetCenterColor(1, 1, 1, 1)
    flash:SetEdgeColor(1, 1, 1, 0)
    flash:SetAnchor(TOPLEFT, tracker, TOPLEFT, 0, 0)
    flash:SetAnchor(BOTTOMRIGHT, tracker, BOTTOMRIGHT, 0, 0)
    flash:SetAlpha(0)
    flash:SetDrawLevel(1)
    UI.offBalanceFlash = flash

    local label = CreateWidgetLabel("CW_OffBalanceTrackerLabel", tracker)
    label:SetText("OFF BALANCE")
    UI.offBalanceLabel = label

    -- Track first, fill over it, both anchored left so the fill drains rightwards.
    UI.offBalanceBarTrack = UI.CreateSolidBar("CW_OffBalanceBarTrack", tracker, 4)
    UI.offBalanceBarFill = UI.CreateSolidBar("CW_OffBalanceBarFill", UI.offBalanceBarTrack, 5)
    UI.offBalanceBarFill:SetAnchor(TOPLEFT, UI.offBalanceBarTrack, TOPLEFT, 0, 0)

    local tl = ANIMATION_MANAGER:CreateTimeline()
    local fadeIn = tl:InsertAnimation(ANIMATION_ALPHA, flash, 0)
    fadeIn:SetAlphaValues(0, 1)
    fadeIn:SetDuration(250)
    local fadeOut = tl:InsertAnimation(ANIMATION_ALPHA, flash, 250)
    fadeOut:SetAlphaValues(1, 0)
    fadeOut:SetDuration(250)
    UI.offBalanceFlashTimeline = tl

    UI.ApplyOffBalanceTrackerStyle()
    UI.ApplyWidgetPosition(tracker, "offBalancePosition")
    UI.ApplyOffBalanceTrackerVisibility()
end

-- ===== HEALTH ALERT =====
-- Transient HUD label; see CW.FireHealthAlert in Alerts.lua.

function UI.ApplyHealthAlertStyle()
    ApplyLabelStyle(UI.healthAlert, UI.healthAlertLabel, "healthAlert", 220, 11, 22,
        CW.SavedVars.healthAlertColor)
end

-- Live-updates the label while the settings editbox is typed into.
function UI.ApplyHealthAlertText()
    UI.healthAlertLabel:SetText(WidgetText("healthAlertText"))
end

function UI.ApplyHealthAlertVisibility()
    -- While placing, show the configured text so there is something to aim at.
    if ApplyWidgetVisibility(UI.healthAlert,
        CW.SavedVars.healthAlertEnabled,
        UI.healthAlertShowing == true,
        UI.healthAlertPlacement == true) then
        UI.ApplyHealthAlertText()
    end
end

--- @param on boolean
function UI.SetHealthAlertPlacementMode(on)
    UI.healthAlertPlacement = on == true
    UI.ApplyHealthAlertVisibility()
end
CW.RegisterHudWidget(UI.SetHealthAlertPlacementMode, UI.ApplyHealthAlertVisibility, "alerts")

function UI.HideHealthAlert()
    HideNow("healthAlertShowing", UI.ApplyHealthAlertVisibility)
end

function UI.ShowHealthAlert()
    local duration = CW.SavedVars.healthAlertDuration
    if duration <= 0 then return end   -- sound only

    UI.ApplyHealthAlertText()
    ShowFor("healthAlertShowing", duration, UI.ApplyHealthAlertVisibility)
end

function UI.BuildHealthAlert()
    if UI.healthAlert then return end

    UI.healthAlert, UI.healthAlertLabel = BuildLabelWidget("CW_HealthAlert", "healthAlertPosition", 3)
    UI.ApplyHealthAlertText()

    UI.ApplyHealthAlertStyle()
    UI.ApplyHealthAlertVisibility()
end

-- ===== INCOMING DAMAGE ALERT =====
-- See CW.UpdateIncomingAlertTracking.
-- Underlined like off balance; flickers while visible, including placement.
local INCOMING_UNDERLINE_H  = 6     -- px; thick enough to read without looking at it
local INCOMING_FLASH_TIMER  = CW.name .. "IncomingAlertFlash"
local INCOMING_FLASH_MS     = 150   -- on/off half-period

local function IncomingFlashTick()
    local rule = UI.incomingAlertUnderline
    rule:SetAlpha(rule:GetAlpha() > 0 and 0 or 1)
end

-- Registered only while the frame is visible, so a hidden alert costs nothing.
local function SetIncomingFlashing(on)
    if UI.incomingAlertFlashing == on then return end
    UI.incomingAlertFlashing = on
    UI.incomingAlertUnderline:SetAlpha(1)
    if on then
        EM:RegisterForUpdate(INCOMING_FLASH_TIMER, INCOMING_FLASH_MS, IncomingFlashTick)
    else
        EM:UnregisterForUpdate(INCOMING_FLASH_TIMER)
    end
end

-- Sized to the rendered text, not the frame: the rule underlines the words, icon and all.
local function ApplyIncomingUnderline()
    local rule = UI.incomingAlertUnderline
    local width = LabelWidth(UI.incomingAlertLabel)
    rule:SetHidden(width <= 0)
    rule:SetDimensions(width, INCOMING_UNDERLINE_H)
    rule:SetCenterColor(unpack(CW.SavedVars.incomingAlertUnderlineColor))
    AnchorUnderLabel(rule, UI.incomingAlertLabel)
end

-- Alerts.lua owns the clock because each hit refreshes the window.
function UI.ApplyIncomingAlertStyle()
    -- "THE UNBLINKING EYE" with its icon is about the longest this frame holds.
    ApplyLabelStyle(UI.incomingAlert, UI.incomingAlertLabel, "incomingAlert", 260, 15, 34,
        CW.SavedVars.incomingAlertColor)
    UI.ApplyIncomingAlertText()
end

-- ESO's inline-icon "100%" size matches font height without a separate control.
function UI.ApplyIncomingAlertText()
    local text, icon = UI.incomingAlertText, UI.incomingAlertIcon
    if not text then text, icon = CW.IncomingAlertPreview() end
    if icon ~= "" then text = zo_iconFormat(icon, "100%", "100%") .. " " .. text end
    UI.incomingAlertLabel:SetText(text)
    ApplyIncomingUnderline()
end

function UI.ApplyIncomingAlertVisibility()
    ApplyWidgetVisibility(UI.incomingAlert,
        CW.SavedVars.incomingAlertEnabled,
        UI.incomingAlertText ~= nil,
        UI.incomingAlertPlacement == true)
    SetIncomingFlashing(not UI.incomingAlert:IsHidden())
end

--- @param on boolean
function UI.SetIncomingAlertPlacementMode(on)
    UI.incomingAlertPlacement = on == true
    -- While placing, the preview gives something to aim at.
    if UI.incomingAlertPlacement then UI.ApplyIncomingAlertText() end
    UI.ApplyIncomingAlertVisibility()
end
CW.RegisterHudWidget(UI.SetIncomingAlertPlacementMode, UI.ApplyIncomingAlertVisibility, "pvp")

-- Alerts.lua calls on hit and expiry. nil hides the alert;
-- retain the last text/icon for placement.
--- @param text string?
--- @param icon string?
function UI.UpdateIncomingAlert(text, icon)
    UI.incomingAlertText = text
    UI.incomingAlertIcon = icon
    UI.ApplyIncomingAlertText()
    UI.ApplyIncomingAlertVisibility()
end

function UI.BuildIncomingAlert()
    if UI.incomingAlert then return end

    local alert = CreateWidgetWindow("CW_IncomingAlert", 3, "incomingAlertPosition")
    UI.incomingAlert = alert

    UI.incomingAlertLabel = CreateWidgetLabel("CW_IncomingAlertLabel", alert)
    UI.incomingAlertUnderline = UI.CreateSolidBar("CW_IncomingAlertUnderline", alert, 4)

    UI.ApplyIncomingAlertStyle()
    UI.ApplyWidgetPosition(alert, "incomingAlertPosition")
    UI.ApplyIncomingAlertVisibility()
end

-- ===== CC IMMUNITY BAR =====
-- See CW.UpdateCcImmunityTracking in Alerts.lua.
-- Alerts.lua drives the label and right-draining rule. Use frame width so the
-- countdown's changing text width cannot resize the rule every tenth of a second.

-- The driving track selects its configured color.
local function CcImmunityColor()
    return CW.SavedVars[UI.ccImmunityHard == false and "ccImmunitySoftColor" or "ccImmunityColor"]
end

local function ApplyCcBar(track, fill, c, width, height, progress)
    track:SetDimensions(width, height)
    ApplyBarColors(track, fill, c, height)
    local filled = width * zo_clamp(progress, 0, 1)
    fill:SetHidden(filled < 1)
    if filled >= 1 then fill:SetWidth(filled) end
end

local function ApplyCcImmunityBar()
    local track = UI.ccImmunityBarTrack
    local height = zo_clamp(CW.SavedVars.ccImmunityBarHeight, 0, 20)
    local width = UI.ccImmunity:GetWidth()
    local c = CcImmunityColor()

    track:SetHidden(height <= 0)
    AnchorUnderLabel(track, UI.ccImmunityLabel)
    ApplyCcBar(track, UI.ccImmunityBarFill, c, width, height, UI.ccImmunityProgress or 1)
    UI.ccImmunityLabel:SetColor(unpack(c))

    -- Soft immunity still running under hard gets its own bar, since the label names only hard.
    local soft = UI.ccImmunitySoftProgress or 0
    UI.ccImmunitySoftTrack:SetHidden(height <= 0 or soft <= 0)
    if soft > 0 then
        ApplyCcBar(UI.ccImmunitySoftTrack, UI.ccImmunitySoftFill, CW.SavedVars.ccImmunitySoftColor,
            width, height, soft)
    end
end

function UI.ApplyCcImmunityText()
    local text = WidgetText(UI.ccImmunityHard == false and "ccImmunitySoftText" or "ccImmunityText")
    local remaining = UI.ccImmunityRemaining or 0
    if CW.SavedVars.ccImmunityShowSeconds and remaining > 0 then
        text = string.format("%s  %.1f", text, remaining)
    end
    UI.ccImmunityLabel:SetText(text)
    ApplyCcImmunityBar()
end

function UI.ApplyCcImmunityStyle()
    -- No colour here: ApplyCcImmunityBar paints the label from whichever track is driving.
    ApplyLabelStyle(UI.ccImmunity, UI.ccImmunityLabel, "ccImmunity", 220, 11, 22)
    UI.ApplyCcImmunityText()
end

function UI.ApplyCcImmunityVisibility()
    -- While placing, show a full bar and the configured text to aim at.
    if ApplyWidgetVisibility(UI.ccImmunity,
        CW.SavedVars.ccImmunityEnabled,
        (UI.ccImmunityRemaining or 0) > 0,
        UI.ccImmunityPlacement == true) then
        UI.ccImmunityProgress, UI.ccImmunityHard, UI.ccImmunitySoftProgress = 1, true, 1
        UI.ApplyCcImmunityText()
    end
end

--- @param on boolean
function UI.SetCcImmunityPlacementMode(on)
    UI.ccImmunityPlacement = on == true
    UI.ApplyCcImmunityVisibility()
end
CW.RegisterHudWidget(UI.SetCcImmunityPlacementMode, UI.ApplyCcImmunityVisibility, "pvp")

-- Called by Alerts.lua on every immunity gained and on its 100ms drain tick.
--- @param progress number  0-1
--- @param remaining number  seconds
--- @param hard boolean  false selects the soft-CC text and colour
--- @param softProgress number  0-1, soft immunity running under hard; 0 hides its bar
function UI.UpdateCcImmunity(progress, remaining, hard, softProgress)
    UI.ccImmunityProgress = progress
    UI.ccImmunityRemaining = remaining
    UI.ccImmunityHard = hard == true
    UI.ccImmunitySoftProgress = softProgress
    UI.ApplyCcImmunityText()
    UI.ApplyCcImmunityVisibility()
end

function UI.BuildCcImmunity()
    if UI.ccImmunity then return end

    local frame = CreateWidgetWindow("CW_CcImmunity", 3, "ccImmunityPosition")
    UI.ccImmunity = frame
    UI.ccImmunityLabel = CreateWidgetLabel("CW_CcImmunityLabel", frame)

    -- Track first, fill over it anchored left so it drains rightwards.
    UI.ccImmunityBarTrack = UI.CreateSolidBar("CW_CcImmunityBarTrack", frame, 4)
    UI.ccImmunityBarFill = UI.CreateSolidBar("CW_CcImmunityBarFill", UI.ccImmunityBarTrack, 5)
    UI.ccImmunityBarFill:SetAnchor(TOPLEFT, UI.ccImmunityBarTrack, TOPLEFT, 0, 0)
    UI.ccImmunitySoftTrack = UI.CreateSolidBar("CW_CcImmunitySoftTrack", frame, 4)
    UI.ccImmunitySoftTrack:SetAnchor(TOP, UI.ccImmunityBarTrack, BOTTOM, 0, BAR_GAP)
    UI.ccImmunitySoftFill = UI.CreateSolidBar("CW_CcImmunitySoftFill", UI.ccImmunitySoftTrack, 5)
    UI.ccImmunitySoftFill:SetAnchor(TOPLEFT, UI.ccImmunitySoftTrack, TOPLEFT, 0, 0)

    UI.ApplyCcImmunityStyle()
    UI.ApplyWidgetPosition(frame, "ccImmunityPosition")
    UI.ApplyCcImmunityVisibility()
end

-- ===== EXPIRE REMINDER =====
-- See CW.UpdateExpireReminderTracking in Alerts.lua, which supplies the row each tick.
-- Pooled ability icons with optional countdowns appear as watched buffs expire.

local EXPIRE_SLOT_GAP = 6
local expireSlots = {}

-- Per-entry scale multiplies the shared size.
local function ExpireIconSize(scale)
    return zo_round(zo_clamp(CW.SavedVars.expireReminderIconSize, 16, 128) * scale)
end

local function ExpireSlot(i)
    local slot = expireSlots[i]
    if slot then return slot end

    local icon = WM:CreateControl("CW_ExpireReminderIcon" .. i, UI.expireReminder, CT_TEXTURE)
    icon:SetDrawLevel(3)

    local label = WM:CreateControl("CW_ExpireReminderLabel" .. i, UI.expireReminder, CT_LABEL)
    label:SetAnchor(TOP, icon, BOTTOM, 0, 4)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetColor(1, 1, 1, 1)
    label:SetDrawLevel(3)
    label:SetFont(WidgetFont("expireReminder"))

    slot = { icon = icon, label = label }
    expireSlots[i] = slot
    return slot
end

-- Center the row so its saved position stays fixed as reminders come and go.
local function LayoutExpireRow(items)
    local total = 0
    for i, item in ipairs(items) do
        total = total + ExpireIconSize(item.scale) + (i > 1 and EXPIRE_SLOT_GAP or 0)
    end

    local x = -total / 2
    for i, item in ipairs(items) do
        local slot, size = ExpireSlot(i), ExpireIconSize(item.scale)
        slot.icon:SetDimensions(size, size)
        slot.icon:ClearAnchors()
        slot.icon:SetAnchor(TOP, UI.expireReminder, TOP, x + size / 2, 0)
        slot.icon:SetHidden(item.icon == nil)
        if item.icon then slot.icon:SetTexture(item.icon) end
        slot.icon:SetAlpha(item.dim and 0.15 or 1)
        slot.label:SetText(item.remaining and string.format("%.1f", item.remaining) or "")
        x = x + size + EXPIRE_SLOT_GAP
    end

    for i = #items + 1, #expireSlots do
        expireSlots[i].icon:SetHidden(true)
        expireSlots[i].label:SetText("")
    end
end

function UI.ApplyExpireReminderStyle()
    for _, slot in ipairs(expireSlots) do slot.label:SetFont(WidgetFont("expireReminder")) end
    -- The frame is the drag target only: it stays one icon wide whatever the row does.
    local size = ExpireIconSize(1)
    UI.expireReminder:SetDimensions(size, size + WidgetFontSize("expireReminder") + 4)
end

function UI.ApplyExpireReminderVisibility()
    local enabled = CW.SavedVars.gcdAlertEnabled
    if ApplyWidgetVisibility(UI.expireReminder, enabled, UI.expireReminderLive == true,
        UI.expireReminderPlacement == true) then
        LayoutExpireRow({ { icon = "EsoUI/Art/Icons/icon_missing.dds", remaining = 3, scale = 1 } })
    end
end

-- The whole row, in watch-list order. An empty list takes it off screen.
--- @param items table  { icon = string?, remaining = number?, scale = number, dim = boolean }
function UI.ShowExpireReminders(items)
    UI.expireReminderLive = #items > 0
    if UI.expireReminderLive then LayoutExpireRow(items) end
    UI.ApplyExpireReminderVisibility()
end

--- @param on boolean
function UI.SetExpireReminderPlacementMode(on)
    UI.expireReminderPlacement = on == true
    UI.ApplyExpireReminderVisibility()
end
CW.RegisterHudWidget(UI.SetExpireReminderPlacementMode, UI.ApplyExpireReminderVisibility, "gcdAlerts")

function UI.BuildExpireReminder()
    if UI.expireReminder then return end

    UI.expireReminder = CreateWidgetWindow("CW_ExpireReminder", 3, "expireReminderPosition")
    UI.ApplyExpireReminderStyle()
    UI.ApplyWidgetPosition(UI.expireReminder, "expireReminderPosition")
    UI.ApplyExpireReminderVisibility()
end

-- ===== NEGATE WARNING =====
-- See CW.UpdateNegateAlertTracking in Alerts.lua.
-- A plain label like the health alert, held up by the effect rather than a duration.
-- The timer is a backstop: the field can drop you outside its radius without ever
-- reporting the effect faded.

function UI.ApplyNegateAlertStyle()
    ApplyLabelStyle(UI.negateAlert, UI.negateAlertLabel, "negateAlert", 220, 11, 22,
        CW.SavedVars.negateAlertColor)
end

function UI.ApplyNegateAlertText()
    UI.negateAlertLabel:SetText(WidgetText("negateAlertText"))
end

function UI.ApplyNegateAlertVisibility()
    if ApplyWidgetVisibility(UI.negateAlert,
        CW.SavedVars.negateAlertEnabled,
        UI.negateAlertShowing == true,
        UI.negateAlertPlacement == true) then
        UI.ApplyNegateAlertText()
    end
end

--- @param on boolean
function UI.SetNegateAlertPlacementMode(on)
    UI.negateAlertPlacement = on == true
    UI.ApplyNegateAlertVisibility()
end
CW.RegisterHudWidget(UI.SetNegateAlertPlacementMode, UI.ApplyNegateAlertVisibility, "pvp")

function UI.HideNegateAlert()
    HideNow("negateAlertShowing", UI.ApplyNegateAlertVisibility)
end

-- Return true only on first show, so reapplication does not repeat the sound.
--- @return boolean  true when this call put the warning up, which is when to sound it
function UI.ShowNegateAlert()
    if UI.negateAlertShowing then return false end

    UI.ApplyNegateAlertText()
    ShowFor("negateAlertShowing", CW.SavedVars.negateAlertDuration, UI.ApplyNegateAlertVisibility)
    return true
end

function UI.BuildNegateAlert()
    if UI.negateAlert then return end

    UI.negateAlert, UI.negateAlertLabel = BuildLabelWidget("CW_NegateAlert", "negateAlertPosition", 3)
    UI.ApplyNegateAlertText()

    UI.ApplyNegateAlertStyle()
    UI.ApplyNegateAlertVisibility()
end

-- ===== POISON BAR ALERT =====
-- See CW.RefreshLarvalTearBuild in LarvalTear.lua.
-- Caller supplies the poison's bar name; show for two seconds.
local POISON_ALERT_MS = 2000

function UI.ApplyPoisonAlertStyle()
    ApplyLabelStyle(UI.poisonAlert, UI.poisonAlertLabel, "ltPoisonAlert", 260, 12, 22,
        CW.SavedVars.ltPoisonAlertColor)
end

function UI.ApplyPoisonAlertVisibility()
    if ApplyWidgetVisibility(UI.poisonAlert,
        CW.SavedVars.ltPoisonAlert,
        UI.poisonAlertShowing == true,
        UI.poisonAlertPlacement == true) then
        UI.poisonAlertLabel:SetText(CW.L.LT_POISON_FRONT)   -- stand-in to aim at
    end
end

--- @param on boolean
function UI.SetPoisonAlertPlacementMode(on)
    UI.poisonAlertPlacement = on == true
    UI.ApplyPoisonAlertVisibility()
end
CW.RegisterHudWidget(UI.SetPoisonAlertPlacementMode, UI.ApplyPoisonAlertVisibility, "qol")

--- @param text string
function UI.ShowPoisonAlert(text)
    UI.poisonAlertLabel:SetText(text)
    ShowFor("poisonAlertShowing", POISON_ALERT_MS, UI.ApplyPoisonAlertVisibility)
end

function UI.BuildPoisonAlert()
    if UI.poisonAlert then return end

    UI.poisonAlert, UI.poisonAlertLabel = BuildLabelWidget("CW_PoisonAlert", "ltPoisonAlertPosition", 3)

    UI.ApplyPoisonAlertStyle()
    UI.ApplyPoisonAlertVisibility()
end

-- ===== LIGHT ATTACK TRACKER PANEL =====
-- See LightAttack.lua.
-- Visible throughout the fight; resize on each cast to fit the tally and metrics
-- selected by LightAttack.lua.
local LA_STATS_PADDING = 8

-- Colour in fast, out slow, one grow across the pair.
local LA_FLASH_IN_MS = 90
local LA_FLASH_OUT_MS = 260

-- Center-only anchoring measures the unwrapped line; resize after text or font changes.
local function ResizeLaStats()
    local w = math.ceil(UI.laStatsLabel:GetTextWidth()) + LA_STATS_PADDING
    local h = math.ceil(UI.laStatsLabel:GetTextHeight()) + LA_STATS_PADDING
    UI.laStats:SetDimensions(w, h)
    UI.laStatsFlash:SetDimensions(w, h)
end

function UI.ApplyLaStatsStyle()
    UI.laStatsLabel:SetFont(WidgetFont("laStats"))
    UI.laStatsLabel:SetColor(unpack(CW.SavedVars.laStatsColor))
    UI.laStatsFlash:SetCenterColor(unpack(CW.SavedVars.laStatsFlashColor))
    UI.laStatsFlashGrow:SetScaleValues(1, 1 + CW.SavedVars.laStatsFlashGrow / 100)
    ResizeLaStats()   -- after the font: the measured width depends on it
end

-- Restart each clean weave's flash so a fast rotation pulses.
function UI.FlashLaStats()
    if CW.SavedVars.laStatsFlash then
        UI.laStatsFlashTimeline:PlayFromStart()
    end
end

-- text is built from the player's own tally, so it goes straight to SetText and
-- never through string.format.
--- @param text string
function UI.SetLaStatsText(text)
    UI.laStatsLabel:SetText(text)
    ResizeLaStats()
end

--- @param showing boolean?  nil re-evaluates without changing the flag
function UI.ApplyLaStatsVisibility(showing)
    if showing ~= nil then UI.laStatsShowing = showing == true end
    if ApplyWidgetVisibility(UI.laStats,
        CW.SavedVars.laStats,
        UI.laStatsShowing == true and CW.inGameplay,
        UI.laStatsPlacement == true) then
        -- Every metric switched off leaves nothing to grab while dragging.
        local text = CW.LaStatsText()
        UI.SetLaStatsText(text ~= "" and text or CW.L.LA_STATS)
    end
end

--- @param on boolean
function UI.SetLaStatsPlacementMode(on)
    UI.laStatsPlacement = on == true
    UI.ApplyLaStatsVisibility()
end
CW.RegisterHudWidget(UI.SetLaStatsPlacementMode, UI.ApplyLaStatsVisibility, "la")

function UI.BuildLaStats()
    if UI.laStats then return end

    local panel = CreateWidgetWindow("CW_LaStats", 3, "laStatsPosition")
    UI.laStats = panel

    -- Grow a separate control to keep the text still. Use CreateSolidBar:
    -- ZO_DefaultBackdrop's dark center art and 16px insets flash a black rectangle.
    local flash = UI.CreateSolidBar("CW_LaStatsFlash", panel, 1)
    flash:SetAnchor(CENTER, panel, CENTER, 0, 0)
    flash:SetAlpha(0)
    UI.laStatsFlash = flash

    local tl = ANIMATION_MANAGER:CreateTimeline()
    local fadeIn = tl:InsertAnimation(ANIMATION_ALPHA, flash, 0)
    fadeIn:SetAlphaValues(0, 1)
    fadeIn:SetDuration(LA_FLASH_IN_MS)
    local fadeOut = tl:InsertAnimation(ANIMATION_ALPHA, flash, LA_FLASH_IN_MS)
    fadeOut:SetAlphaValues(1, 0)
    fadeOut:SetDuration(LA_FLASH_OUT_MS)
    -- Grow both flashes once with ease-out; fade without shrinking.
    local grow = tl:InsertAnimation(ANIMATION_SCALE, flash, 0)
    grow:SetDuration(LA_FLASH_IN_MS + LA_FLASH_OUT_MS)
    grow:SetEasingFunction(ZO_EaseOutQuadratic)
    UI.laStatsFlashGrow = grow
    UI.laStatsFlashTimeline = tl

    UI.laStatsLabel = CreateWidgetLabel("CW_LaStatsLabel", panel)

    UI.ApplyLaStatsStyle()
    UI.ApplyWidgetPosition(panel, "laStatsPosition")
    UI.ApplyLaStatsVisibility()
end

-- ===== GCD-READY ALERT =====
-- See CW.FireGcdAlert in Alerts.lua.
-- Timed label with text supplied per watched ability.

-- Placement fallback until an ability fires; UI.gcdAlertColor holds the last color.
local function GcdAlertColor()
    if UI.gcdAlertColor then return UI.gcdAlertColor end
    local entry = CW.GcdAlertStore()[CW.gcdAlertEditIndex or 1]
    if entry then return CW.GcdAlertColor(entry, nil) end
    return CW.defaults.gcdAlertColor
end

-- Grow to the single-line label's unwrapped GetTextWidth:
-- ability names with ON/OFF suffixes can exceed the fixed box.
local function ResizeGcdAlertToText()
    local minW, h = WidgetSize("gcdAlert", 220, 11, 22)
    -- Slack on each side: soft-shadow-thick draws outside the glyphs.
    local w = math.max(minW, math.ceil(UI.gcdAlertLabel:GetTextWidth()) + 24)
    UI.gcdAlert:SetDimensions(w, h)
    UI.gcdAlertLabel:SetDimensions(w, h)
end

-- Preview the first watched ability before any fires.
-- Even an entry with blank text needs a drag target.
local function GcdAlertPlacementText()
    local entry = CW.GcdAlertStore()[CW.gcdAlertEditIndex or 1]
    local text = entry and CW.GcdAlertText(entry) or ""
    return text ~= "" and text or "GCD READY"
end

function UI.ApplyGcdAlertStyle()
    UI.gcdAlertLabel:SetFont(WidgetFont("gcdAlert"))
    UI.gcdAlertLabel:SetColor(unpack(GcdAlertColor()))
    -- After the font, not before: the measured width depends on it.
    ResizeGcdAlertToText()
end

function UI.ApplyGcdAlertVisibility()
    if ApplyWidgetVisibility(UI.gcdAlert,
        CW.SavedVars.gcdAlertEnabled,
        UI.gcdAlertShowing == true,
        UI.gcdAlertPlacement == true) then
        UI.gcdAlertLabel:SetText(GcdAlertPlacementText())
        UI.gcdAlertLabel:SetColor(unpack(GcdAlertColor()))
        ResizeGcdAlertToText()
    end
end

--- @param on boolean
function UI.SetGcdAlertPlacementMode(on)
    UI.gcdAlertPlacement = on == true
    -- Drop the last-fired colour so the preview tracks the entry being edited.
    UI.gcdAlertColor = nil
    UI.ApplyGcdAlertStyle()
    UI.ApplyGcdAlertVisibility()
end
CW.RegisterHudWidget(UI.SetGcdAlertPlacementMode, UI.ApplyGcdAlertVisibility, "gcdAlerts")

function UI.HideGcdAlert()
    HideNow("gcdAlertShowing", UI.ApplyGcdAlertVisibility)
end

-- CW.GcdAlertText supplies user text; pass straight to SetText, not string.format.
-- Zero duration or empty text means sound only.
--- @param text string  resolved by CW.GcdAlertText; "" means sound only
--- @param duration number  ms; 0 means sound only
--- @param color table  {r,g,b,a}
function UI.ShowGcdAlert(text, duration, color)
    if duration <= 0 or text == "" then return end

    UI.gcdAlertColor = color
    UI.gcdAlertLabel:SetColor(unpack(color))
    UI.gcdAlertLabel:SetText(text)
    ResizeGcdAlertToText()
    ShowFor("gcdAlertShowing", duration, UI.ApplyGcdAlertVisibility)
end

function UI.BuildGcdAlert()
    if UI.gcdAlert then return end

    UI.gcdAlert, UI.gcdAlertLabel = BuildLabelWidget("CW_GcdAlert", "gcdAlertPosition", 3)
    -- Single line, so ResizeGcdAlertToText measures the unwrapped width.
    UI.gcdAlertLabel:SetMaxLineCount(1)

    UI.ApplyGcdAlertStyle()
    UI.ApplyGcdAlertVisibility()
end
