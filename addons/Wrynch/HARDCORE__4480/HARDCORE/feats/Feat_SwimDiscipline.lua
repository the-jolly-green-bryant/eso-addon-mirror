local HARDCORE = HARDCORE

local ID = "SwimDiscipline"
local NS = "HARDCORE_SwimDiscipline"

local INTERVAL_MS = 15 * 60 * 1000
local REQUIRED_SWIM_MS = 10 * 1000
local GRACE_MS = 20 * 1000
local TICK_MS = 1000

local ICON_SWIM = "/esoui/art/inventory/inventory_tabicon_craftbag_fishing_up.dds"
local FRAME_TEXTURE = "/esoui/art/actionbar/abilityframe64_up.dds"
local GLOW_TEXTURE = "/esoui/art/actionbar/abilityframe64_glow.dds"
local OLD_DEFAULT_HUD_X = 540
local OLD_DEFAULT_HUD_Y = 710
local DEFAULT_HUD_X = 900
local DEFAULT_HUD_Y = 710

local Rule = {
    id = ID,
    title = "Mandatory Bath Time: periodic water survival check",
    icon = ICON_SWIM,
    defaultEnabled = false
}

Rule.active = false
Rule._installedScenes = false
Rule._isSwimming = false

local hudTLW
local iconControl
local titleLabel
local statusLabel
local timeLabel
local progressBg
local progressFill
local pulseControl
local pulseTimeline

local function GetSV()
    HARDCORE = HARDCORE or {}
    if not HARDCORE.swimDisciplineSaved then
        HARDCORE.swimDisciplineSaved = ZO_SavedVars:NewCharacterIdSettings("HARDCORE_SWIM_DISCIPLINE_SV", 1, nil, {
            intervalRemainingMs = INTERVAL_MS,
            swimProgressMs = 0,
            graceRemainingMs = GRACE_MS,
            graceActive = false,
            hud = {
                x = DEFAULT_HUD_X,
                y = DEFAULT_HUD_Y,
                unlocked = false,
                showLabels = true
            },
            warnedDue = false,
            warnedGrace = false
        }, GetWorldName())
    end

    local sv = HARDCORE.swimDisciplineSaved
    sv.intervalRemainingMs = zo_clamp(tonumber(sv.intervalRemainingMs) or INTERVAL_MS, 0, INTERVAL_MS)
    sv.swimProgressMs = zo_clamp(tonumber(sv.swimProgressMs) or 0, 0, REQUIRED_SWIM_MS)
    sv.graceRemainingMs = zo_clamp(tonumber(sv.graceRemainingMs) or GRACE_MS, 0, GRACE_MS)
    sv.graceActive = sv.graceActive == true
    sv.hud = sv.hud or {}
    if sv.hud.x == OLD_DEFAULT_HUD_X and sv.hud.y == OLD_DEFAULT_HUD_Y then
        sv.hud.x = DEFAULT_HUD_X
        sv.hud.y = DEFAULT_HUD_Y
    end
    if sv.hud.x == nil then sv.hud.x = DEFAULT_HUD_X end
    if sv.hud.y == nil then sv.hud.y = DEFAULT_HUD_Y end
    if sv.hud.unlocked == nil then sv.hud.unlocked = false end
    if sv.hud.showLabels == nil then sv.hud.showLabels = true end
    sv.warnedDue = sv.warnedDue == true
    sv.warnedGrace = sv.warnedGrace == true
    return sv
end

local function IsHardcoreActive()
    return HARDCORE and HARDCORE.saved and HARDCORE.saved.isActive
end

local function IsDead()
    return IsUnitDead and IsUnitDead("player")
end

local function IsOnHud()
    return SCENE_MANAGER and (SCENE_MANAGER:IsShowing("hud") or SCENE_MANAGER:IsShowing("hudui") or SCENE_MANAGER:IsShowing("gamepad_hud"))
end

local function IsSwimming()
    return IsUnitSwimming and IsUnitSwimming("player") == true
end

local function Alert(text, sound)
    HARDCORE.ShowAlertNoSuppression(UI_ALERT_CATEGORY_ALERT, sound or SOUNDS.NEGATIVE_CLICK, text)
end

local function FormatClock(ms)
    local seconds = zo_ceil(zo_max(0, tonumber(ms) or 0) / 1000)
    local minutes = zo_floor(seconds / 60)
    seconds = seconds % 60
    return string.format("%d:%02d", minutes, seconds)
end

local function ResetCycle(sv)
    sv = sv or GetSV()
    sv.intervalRemainingMs = INTERVAL_MS
    sv.swimProgressMs = 0
    sv.graceRemainingMs = GRACE_MS
    sv.graceActive = false
    sv.warnedDue = false
    sv.warnedGrace = false
end

local function ApplyHudPosition()
    if not hudTLW then
        return
    end
    local sv = GetSV()
    local rootW = GuiRoot and GuiRoot.GetWidth and GuiRoot:GetWidth() or 0
    local rootH = GuiRoot and GuiRoot.GetHeight and GuiRoot:GetHeight() or 0
    local hudW = hudTLW.GetWidth and hudTLW:GetWidth() or 214
    local hudH = hudTLW.GetHeight and hudTLW:GetHeight() or 70
    if rootW > 0 then
        sv.hud.x = zo_clamp(tonumber(sv.hud.x) or DEFAULT_HUD_X, 0, zo_max(0, rootW - hudW))
    end
    if rootH > 0 then
        sv.hud.y = zo_clamp(tonumber(sv.hud.y) or DEFAULT_HUD_Y, 0, zo_max(0, rootH - hudH))
    end
    hudTLW:ClearAnchors()
    hudTLW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.hud.x, sv.hud.y)
end

local function UpdateLockState()
    if not hudTLW then
        return
    end
    local unlocked = GetSV().hud.unlocked == true
    hudTLW:SetMouseEnabled(unlocked)
    hudTLW:SetMovable(unlocked)
end

local function UpdateVisibility()
    if hudTLW then
        local sv = GetSV()
        hudTLW:SetHidden(not (Rule.active and (IsOnHud() or sv.hud.unlocked == true)))
    end
end

local function EnsureHud()
    if hudTLW then
        return
    end

    local wm = WINDOW_MANAGER
    hudTLW = wm:CreateTopLevelWindow("HARDCORE_SwimDisciplineHUD")
    hudTLW:SetDimensions(214, 70)
    hudTLW:SetDrawTier(DT_HIGH)
    hudTLW:SetDrawLayer(DL_OVERLAY)
    hudTLW:SetDrawLevel(9202)
    hudTLW:SetMouseEnabled(false)
    hudTLW:SetMovable(false)
    hudTLW:SetClampedToScreen(true)
    hudTLW:SetHidden(true)

    local bg = wm:CreateControl(nil, hudTLW, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.015, 0.025, 0.032, 0.84)
    bg:SetEdgeTexture("/esoui/art/chatwindow/chat_bg_edge.dds", 32, 4, 4)
    bg:SetEdgeColor(0.15, 0.55, 0.72, 0.72)

    local glow = wm:CreateControl(nil, hudTLW, CT_TEXTURE)
    glow:SetAnchor(LEFT, hudTLW, LEFT, 5, 0)
    glow:SetDimensions(58, 58)
    glow:SetTexture(GLOW_TEXTURE)
    glow:SetColor(0.20, 0.72, 0.92, 1)
    glow:SetAlpha(0.22)
    glow:SetBlendMode(TEX_BLEND_MODE_ADD)

    iconControl = wm:CreateControl(nil, hudTLW, CT_TEXTURE)
    iconControl:SetAnchor(LEFT, hudTLW, LEFT, 8, 0)
    iconControl:SetDimensions(46, 46)
    iconControl:SetTexture(ICON_SWIM)
    iconControl:SetColor(0.80, 0.96, 1, 1)

    local frame = wm:CreateControl(nil, hudTLW, CT_TEXTURE)
    frame:SetAnchor(CENTER, iconControl, CENTER, 0, 0)
    frame:SetDimensions(56, 56)
    frame:SetTexture(FRAME_TEXTURE)
    frame:SetColor(0.82, 0.92, 1, 0.92)

    pulseControl = wm:CreateControl(nil, hudTLW, CT_TEXTURE)
    pulseControl:SetAnchor(CENTER, iconControl, CENTER, 0, 0)
    pulseControl:SetDimensions(62, 62)
    pulseControl:SetTexture("/esoui/art/quest/texthighlight.dds")
    pulseControl:SetColor(1, 0.15, 0.10, 1)
    pulseControl:SetAlpha(0)
    pulseControl:SetBlendMode(TEX_BLEND_MODE_ADD)

    titleLabel = wm:CreateControl(nil, hudTLW, CT_LABEL)
    titleLabel:SetAnchor(TOPLEFT, hudTLW, TOPLEFT, 65, 7)
    titleLabel:SetDimensions(140, 16)
    titleLabel:SetFont("$(BOLD_FONT)|13|soft-shadow-thin")
    titleLabel:SetColor(0.82, 0.96, 1, 0.98)
    titleLabel:SetText("BATH")

    timeLabel = wm:CreateControl(nil, hudTLW, CT_LABEL)
    timeLabel:SetAnchor(TOPRIGHT, hudTLW, TOPRIGHT, -9, 7)
    timeLabel:SetDimensions(66, 16)
    timeLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    timeLabel:SetFont("$(BOLD_FONT)|14|soft-shadow-thick")
    timeLabel:SetColor(1, 0.96, 0.80, 1)

    statusLabel = wm:CreateControl(nil, hudTLW, CT_LABEL)
    statusLabel:SetAnchor(TOPLEFT, titleLabel, BOTTOMLEFT, 0, 3)
    statusLabel:SetDimensions(140, 18)
    statusLabel:SetFont("$(MEDIUM_FONT)|12|soft-shadow-thin")
    statusLabel:SetColor(0.78, 0.86, 0.88, 0.96)

    progressBg = wm:CreateControl(nil, hudTLW, CT_BACKDROP)
    progressBg:SetAnchor(TOPLEFT, statusLabel, BOTTOMLEFT, 0, 5)
    progressBg:SetDimensions(134, 8)
    progressBg:SetCenterColor(0, 0, 0, 0.55)
    progressBg:SetEdgeColor(0.12, 0.32, 0.42, 0.72)

    progressFill = wm:CreateControl(nil, progressBg, CT_BACKDROP)
    progressFill:SetAnchor(LEFT, progressBg, LEFT, 0, 0)
    progressFill:SetDimensions(1, 8)
    progressFill:SetCenterColor(0.16, 0.72, 0.95, 0.92)
    progressFill:SetEdgeColor(0, 0, 0, 0)

    hudTLW:SetHandler("OnMoveStop", function()
        local sv = GetSV()
        sv.hud.x = zo_round(hudTLW:GetLeft())
        sv.hud.y = zo_round(hudTLW:GetTop())
        ApplyHudPosition()
    end)

    pulseTimeline = ANIMATION_MANAGER:CreateTimeline()
    local aIn = pulseTimeline:InsertAnimation(ANIMATION_ALPHA, pulseControl, 0)
    aIn:SetAlphaValues(0.10, 0.55)
    aIn:SetDuration(300)
    local aOut = pulseTimeline:InsertAnimation(ANIMATION_ALPHA, pulseControl, 300)
    aOut:SetAlphaValues(0.55, 0.10)
    aOut:SetDuration(300)
    pulseTimeline:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY)

    ApplyHudPosition()
end

local function UpdateHud()
    EnsureHud()
    local sv = GetSV()
    local swimming = Rule._isSwimming or IsSwimming()
    local progressPct = zo_clamp(sv.swimProgressMs / REQUIRED_SWIM_MS, 0, 1)
    local fillWidth = zo_max(1, zo_round(134 * progressPct))

    progressFill:SetDimensions(fillWidth, 8)
    titleLabel:SetHidden(not (sv.hud.showLabels == true))

    if sv.graceActive then
        timeLabel:SetText(FormatClock(sv.graceRemainingMs))
        timeLabel:SetColor(1, 0.26, 0.18, 1)
        statusLabel:SetText("Bathe now " .. tostring(zo_floor(sv.swimProgressMs / 1000)) .. "/10s")
        statusLabel:SetColor(1, 0.58, 0.46, 1)
        progressFill:SetCenterColor(1, 0.20, 0.12, 0.95)
        iconControl:SetColor(1, 0.70, 0.62, 1)
        pulseControl:SetHidden(false)
        if pulseTimeline and not pulseTimeline:IsPlaying() then
            pulseTimeline:PlayFromStart()
        end
    else
        timeLabel:SetText(FormatClock(sv.intervalRemainingMs))
        timeLabel:SetColor(1, 0.96, 0.80, 1)
        if swimming then
            statusLabel:SetText("Bathing " .. tostring(zo_floor(sv.swimProgressMs / 1000)) .. "/10s")
        else
            statusLabel:SetText("Bath due")
        end
        statusLabel:SetColor(0.78, 0.86, 0.88, 0.96)
        progressFill:SetCenterColor(0.16, 0.72, 0.95, 0.92)
        iconControl:SetColor(0.80, 0.96, 1, 1)
        if pulseTimeline and pulseTimeline:IsPlaying() then
            pulseTimeline:Stop()
        end
        pulseControl:SetAlpha(0)
        pulseControl:SetHidden(true)
    end

    UpdateLockState()
    UpdateVisibility()
end

local function CompleteSwimRequirement(sv)
    ResetCycle(sv)
    Alert("HARDCORE: Bath requirement complete.", SOUNDS.QUEST_ACCEPTED)
    UpdateHud()
end

local function StartGrace(sv)
    if sv.graceActive then
        return
    end
    sv.graceActive = true
    sv.graceRemainingMs = GRACE_MS
    sv.warnedGrace = true
    Alert("HARDCORE: Bath time. Challenge fails in 20 seconds.", SOUNDS.DUEL_START)
end

local function FailForMissedSwim()
    if HARDCORE and HARDCORE.FailChallenge then
        HARDCORE.FailChallenge("HARDCORE: Challenge failed. You skipped bath time.")
    end
end

local function AdvanceSwimDiscipline()
    if not Rule.active then
        return
    end

    local sv = GetSV()
    local now = GetFrameTimeMilliseconds()
    if not sv.lastUpdateMs or sv.lastUpdateMs <= 0 then
        sv.lastUpdateMs = now
        UpdateHud()
        return
    end

    local elapsed = now - sv.lastUpdateMs
    if elapsed <= 0 then
        return
    end
    sv.lastUpdateMs = now

    if not IsHardcoreActive() or IsDead() then
        UpdateHud()
        return
    end

    Rule._isSwimming = IsSwimming()
    if Rule._isSwimming then
        sv.swimProgressMs = zo_clamp(sv.swimProgressMs + elapsed, 0, REQUIRED_SWIM_MS)
        if sv.swimProgressMs >= REQUIRED_SWIM_MS then
            CompleteSwimRequirement(sv)
            return
        end
    end

    if sv.graceActive then
        sv.graceRemainingMs = zo_clamp(sv.graceRemainingMs - elapsed, 0, GRACE_MS)
        if sv.graceRemainingMs <= 0 then
            FailForMissedSwim()
            return
        end
    else
        sv.intervalRemainingMs = zo_clamp(sv.intervalRemainingMs - elapsed, 0, INTERVAL_MS)
        if sv.intervalRemainingMs <= 0 then
            StartGrace(sv)
        elseif sv.intervalRemainingMs <= 60 * 1000 and not sv.warnedDue then
            sv.warnedDue = true
            Alert("HARDCORE: Bath time is due in one minute.", SOUNDS.QUEST_OBJECTIVE_STARTED)
        end
    end

    UpdateHud()
end

local function RegisterUpdateLoop()
    EVENT_MANAGER:UnregisterForUpdate(NS .. "_TICK")
    if Rule.active then
        EVENT_MANAGER:RegisterForUpdate(NS .. "_TICK", TICK_MS, AdvanceSwimDiscipline)
    end
end

local function OnSwimmingStateChanged(isSwimming)
    if not Rule.active then
        return
    end
    Rule._isSwimming = isSwimming == true or IsSwimming()
    UpdateHud()
end

local function RegisterEvents()
    EVENT_MANAGER:UnregisterForEvent(NS .. "_SWIM", EVENT_PLAYER_SWIMMING)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_NOSWIM", EVENT_PLAYER_NOT_SWIMMING)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_ACTIVATED", EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_RESIZE", EVENT_SCREEN_RESIZED)

    EVENT_MANAGER:RegisterForEvent(NS .. "_SWIM", EVENT_PLAYER_SWIMMING, function()
        OnSwimmingStateChanged(true)
    end)
    EVENT_MANAGER:RegisterForEvent(NS .. "_NOSWIM", EVENT_PLAYER_NOT_SWIMMING, function()
        OnSwimmingStateChanged(false)
    end)
    EVENT_MANAGER:RegisterForEvent(NS .. "_ACTIVATED", EVENT_PLAYER_ACTIVATED, function()
        if not Rule.active then
            return
        end
        local sv = GetSV()
        sv.lastUpdateMs = GetFrameTimeMilliseconds()
        Rule._isSwimming = IsSwimming()
        UpdateHud()
    end)
    EVENT_MANAGER:RegisterForEvent(NS .. "_RESIZE", EVENT_SCREEN_RESIZED, ApplyHudPosition)
end

local function UnregisterEvents()
    EVENT_MANAGER:UnregisterForEvent(NS .. "_SWIM", EVENT_PLAYER_SWIMMING)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_NOSWIM", EVENT_PLAYER_NOT_SWIMMING)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_ACTIVATED", EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_RESIZE", EVENT_SCREEN_RESIZED)
end

local function HookScenes()
    if Rule._installedScenes then
        return
    end

    local function SetupScene(sceneName)
        local scene = SCENE_MANAGER and SCENE_MANAGER:GetScene(sceneName)
        if not scene then
            return
        end
        scene:RegisterCallback("StateChange", function(_, newState)
            if not Rule.active then
                return
            end
            if newState == SCENE_SHOWING then
                UpdateHud()
            elseif newState == SCENE_HIDING or newState == SCENE_HIDDEN then
                UpdateVisibility()
            end
        end)
    end
    SetupScene("hud")
    SetupScene("hudui")
    SetupScene("gamepad_hud")

    Rule._installedScenes = true
end

function Rule:OnEnable()
    self.active = true
    local sv = GetSV()
    sv.lastUpdateMs = GetFrameTimeMilliseconds()
    self._isSwimming = IsSwimming()
    EnsureHud()
    HookScenes()
    RegisterEvents()
    RegisterUpdateLoop()
    UpdateHud()
end

function Rule:OnDisable()
    self.active = false
    EVENT_MANAGER:UnregisterForUpdate(NS .. "_TICK")
    UnregisterEvents()
    if pulseTimeline and pulseTimeline:IsPlaying() then
        pulseTimeline:Stop()
    end
    if pulseControl then
        pulseControl:SetAlpha(0)
    end
    if hudTLW then
        hudTLW:SetHidden(true)
        hudTLW:SetMouseEnabled(false)
        hudTLW:SetMovable(false)
    end
end

function Rule:RefreshOptions()
    UpdateHud()
end

function Rule:ResetTimer()
    local sv = GetSV()
    ResetCycle(sv)
    sv.lastUpdateMs = GetFrameTimeMilliseconds()
    UpdateHud()
end

function Rule:ResetHudPosition()
    local sv = GetSV()
    sv.hud.x = DEFAULT_HUD_X
    sv.hud.y = DEFAULT_HUD_Y
    ApplyHudPosition()
    UpdateHud()
end

function HARDCORE.GetSwimDisciplineSV()
    return GetSV()
end

function HARDCORE.RefreshSwimDisciplineOptions()
    if Rule.RefreshOptions then
        Rule:RefreshOptions()
    end
end

function HARDCORE.ResetSwimDisciplineTimer()
    Rule:ResetTimer()
end

function HARDCORE.ResetSwimDisciplineHudPosition()
    Rule:ResetHudPosition()
end

function HARDCORE.DebugSwimDisciplineStatus()
    local sv = GetSV()
    d("Mandatory Bath Time active=" .. tostring(Rule.active) ..
        " bathing=" .. tostring(Rule._isSwimming or IsSwimming()) ..
        " interval=" .. FormatClock(sv.intervalRemainingMs) ..
        " progress=" .. tostring(zo_floor(sv.swimProgressMs / 1000)) .. "/10s" ..
        " grace=" .. tostring(sv.graceActive) ..
        " graceRemaining=" .. FormatClock(sv.graceRemainingMs) ..
        " hud=(" .. tostring(sv.hud.x) .. "," .. tostring(sv.hud.y) .. ")" ..
        " unlocked=" .. tostring(sv.hud.unlocked))
end

function HARDCORE.DebugSwimDisciplineCommand(action, arg1)
    action = action or "help"
    local sv = GetSV()

    if action == "help" then
        d("Mandatory Bath Time debug:")
        d("/hc debug bath status")
        d("/hc debug bath due")
        d("/hc debug bath progress <seconds>")
        d("/hc debug bath reset")
        d("/hc debug bath hud")
        return
    end

    if action == "status" then
        HARDCORE.DebugSwimDisciplineStatus()
        return
    end

    if action == "due" then
        sv.intervalRemainingMs = 0
        sv.graceActive = true
        sv.graceRemainingMs = GRACE_MS
        sv.lastUpdateMs = GetFrameTimeMilliseconds()
        Alert("HARDCORE: Bath grace countdown started.", SOUNDS.DUEL_START)
        UpdateHud()
        HARDCORE.DebugSwimDisciplineStatus()
        return
    end

    if action == "progress" then
        local seconds = tonumber(arg1)
        if not seconds then
            d("Usage: /hc debug bath progress <seconds>")
            return
        end
        sv.swimProgressMs = zo_clamp(seconds * 1000, 0, REQUIRED_SWIM_MS)
        sv.lastUpdateMs = GetFrameTimeMilliseconds()
        if sv.swimProgressMs >= REQUIRED_SWIM_MS then
            CompleteSwimRequirement(sv)
        else
            UpdateHud()
        end
        HARDCORE.DebugSwimDisciplineStatus()
        return
    end

    if action == "reset" then
        Rule:ResetTimer()
        d("Mandatory Bath Time: timer and bath progress reset.")
        return
    end

    if action == "hud" then
        EnsureHud()
        UpdateHud()
        if hudTLW then
            hudTLW:SetHidden(false)
        end
        d("Mandatory Bath Time: HUD forced visible until the next scene/update refresh.")
        return
    end

    d("Unknown Mandatory Bath Time debug action: " .. tostring(action))
end

HARDCORE.RuleManager:RegisterRule(Rule)
