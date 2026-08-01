local HARDCORE = HARDCORE

local ID = "NoSwimming"
local NS = "HARDCORE_NoSwimming"

local SWIM_LIMIT_MS = 15 * 1000
local TICK_MS = 250
local OLD_DEFAULT_HUD_X = 760
local OLD_DEFAULT_HUD_Y = 710
local DEFAULT_HUD_X = 1120
local DEFAULT_HUD_Y = 710
local ICON_NO_SWIMMING = "/esoui/art/inventory/inventory_tabicon_craftbag_fishing_up.dds"
local FRAME_TEXTURE = "/esoui/art/actionbar/abilityframe64_up.dds"
local GLOW_TEXTURE = "/esoui/art/actionbar/abilityframe64_glow.dds"

local Rule = {
    id = ID,
    title = "No Swimming: water is deadly",
    icon = ICON_NO_SWIMMING,
    defaultEnabled = false
}

Rule.active = false
Rule._installedScenes = false
Rule._startedMs = 0
Rule._warned = false

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
    if not HARDCORE.noSwimmingSaved then
        HARDCORE.noSwimmingSaved = ZO_SavedVars:NewCharacterIdSettings("HARDCORE_NO_SWIMMING_SV", 1, nil, {
            startedAtS = 0,
            warned = false,
            hud = {
                x = DEFAULT_HUD_X,
                y = DEFAULT_HUD_Y,
                unlocked = false,
                showLabels = true
            }
        }, GetWorldName())
    end

    local sv = HARDCORE.noSwimmingSaved
    sv.startedAtS = tonumber(sv.startedAtS) or 0
    sv.warned = sv.warned == true
    sv.hud = sv.hud or {}
    if sv.hud.x == OLD_DEFAULT_HUD_X and sv.hud.y == OLD_DEFAULT_HUD_Y then
        sv.hud.x = DEFAULT_HUD_X
        sv.hud.y = DEFAULT_HUD_Y
    end
    if sv.hud.x == nil then sv.hud.x = DEFAULT_HUD_X end
    if sv.hud.y == nil then sv.hud.y = DEFAULT_HUD_Y end
    if sv.hud.unlocked == nil then sv.hud.unlocked = false end
    if sv.hud.showLabels == nil then sv.hud.showLabels = true end
    return sv
end

local function IsHardcoreActive()
    return HARDCORE and HARDCORE.saved and HARDCORE.saved.isActive
end

local function IsDead()
    return IsUnitDead and IsUnitDead("player")
end

local function IsSwimming()
    return IsUnitSwimming and IsUnitSwimming("player")
end

local function IsOnHud()
    return SCENE_MANAGER and (SCENE_MANAGER:IsShowing("hud") or SCENE_MANAGER:IsShowing("hudui") or SCENE_MANAGER:IsShowing("gamepad_hud"))
end

local function FormatClock(ms)
    local seconds = zo_ceil(zo_max(0, tonumber(ms) or 0) / 1000)
    local minutes = zo_floor(seconds / 60)
    seconds = seconds % 60
    return string.format("%d:%02d", minutes, seconds)
end

local function Alert(text, sound)
    HARDCORE.ShowAlertNoSuppression(UI_ALERT_CATEGORY_ALERT, sound or SOUNDS.NEGATIVE_CLICK, text)
end

local function GetPersistedElapsedMs(sv)
    sv = sv or GetSV()
    if sv.startedAtS <= 0 then
        return 0
    end
    return zo_max(0, GetDiffBetweenTimeStamps(GetTimeStamp(), sv.startedAtS) * 1000)
end

local function EnsureRuntimeStartFromSaved(sv)
    sv = sv or GetSV()
    if Rule._startedMs <= 0 and sv.startedAtS > 0 then
        Rule._startedMs = GetFrameTimeMilliseconds() - zo_clamp(GetPersistedElapsedMs(sv), 0, SWIM_LIMIT_MS)
        Rule._warned = sv.warned == true
    end
end

local function GetRemainingMs()
    EnsureRuntimeStartFromSaved()
    if Rule._startedMs <= 0 then
        return SWIM_LIMIT_MS
    end
    return zo_clamp(SWIM_LIMIT_MS - (GetFrameTimeMilliseconds() - Rule._startedMs), 0, SWIM_LIMIT_MS)
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
        local shouldShow = Rule.active and IsOnHud() and (IsSwimming() or sv.hud.unlocked == true)
        hudTLW:SetHidden(not shouldShow)
    end
end

local function EnsureHud()
    if hudTLW then
        return
    end

    local wm = WINDOW_MANAGER
    hudTLW = wm:CreateTopLevelWindow("HARDCORE_NoSwimmingHUD")
    hudTLW:SetDimensions(214, 70)
    hudTLW:SetDrawTier(DT_HIGH)
    hudTLW:SetDrawLayer(DL_OVERLAY)
    hudTLW:SetDrawLevel(9203)
    hudTLW:SetMouseEnabled(false)
    hudTLW:SetMovable(false)
    hudTLW:SetClampedToScreen(true)
    hudTLW:SetHidden(true)

    local bg = wm:CreateControl(nil, hudTLW, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.035, 0.012, 0.012, 0.86)
    bg:SetEdgeTexture("/esoui/art/chatwindow/chat_bg_edge.dds", 32, 4, 4)
    bg:SetEdgeColor(0.72, 0.14, 0.10, 0.76)

    local glow = wm:CreateControl(nil, hudTLW, CT_TEXTURE)
    glow:SetAnchor(LEFT, hudTLW, LEFT, 5, 0)
    glow:SetDimensions(58, 58)
    glow:SetTexture(GLOW_TEXTURE)
    glow:SetColor(0.92, 0.18, 0.12, 1)
    glow:SetAlpha(0.24)
    glow:SetBlendMode(TEX_BLEND_MODE_ADD)

    iconControl = wm:CreateControl(nil, hudTLW, CT_TEXTURE)
    iconControl:SetAnchor(LEFT, hudTLW, LEFT, 8, 0)
    iconControl:SetDimensions(46, 46)
    iconControl:SetTexture(ICON_NO_SWIMMING)
    iconControl:SetColor(1, 0.66, 0.56, 1)

    local frame = wm:CreateControl(nil, hudTLW, CT_TEXTURE)
    frame:SetAnchor(CENTER, iconControl, CENTER, 0, 0)
    frame:SetDimensions(56, 56)
    frame:SetTexture(FRAME_TEXTURE)
    frame:SetColor(1, 0.76, 0.66, 0.92)

    pulseControl = wm:CreateControl(nil, hudTLW, CT_TEXTURE)
    pulseControl:SetAnchor(CENTER, iconControl, CENTER, 0, 0)
    pulseControl:SetDimensions(62, 62)
    pulseControl:SetTexture("/esoui/art/quest/texthighlight.dds")
    pulseControl:SetColor(1, 0.12, 0.08, 1)
    pulseControl:SetAlpha(0)
    pulseControl:SetBlendMode(TEX_BLEND_MODE_ADD)

    titleLabel = wm:CreateControl(nil, hudTLW, CT_LABEL)
    titleLabel:SetAnchor(TOPLEFT, hudTLW, TOPLEFT, 65, 7)
    titleLabel:SetDimensions(140, 16)
    titleLabel:SetFont("$(BOLD_FONT)|13|soft-shadow-thin")
    titleLabel:SetColor(1, 0.70, 0.62, 0.98)
    titleLabel:SetText("WATER")

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
    statusLabel:SetColor(1, 0.70, 0.62, 0.96)

    progressBg = wm:CreateControl(nil, hudTLW, CT_BACKDROP)
    progressBg:SetAnchor(TOPLEFT, statusLabel, BOTTOMLEFT, 0, 5)
    progressBg:SetDimensions(134, 8)
    progressBg:SetCenterColor(0, 0, 0, 0.55)
    progressBg:SetEdgeColor(0.42, 0.12, 0.10, 0.72)

    progressFill = wm:CreateControl(nil, progressBg, CT_BACKDROP)
    progressFill:SetAnchor(LEFT, progressBg, LEFT, 0, 0)
    progressFill:SetDimensions(134, 8)
    progressFill:SetCenterColor(1, 0.20, 0.12, 0.95)
    progressFill:SetEdgeColor(0, 0, 0, 0)

    hudTLW:SetHandler("OnMoveStop", function()
        local sv = GetSV()
        sv.hud.x = zo_round(hudTLW:GetLeft())
        sv.hud.y = zo_round(hudTLW:GetTop())
        ApplyHudPosition()
    end)

    pulseTimeline = ANIMATION_MANAGER:CreateTimeline()
    local aIn = pulseTimeline:InsertAnimation(ANIMATION_ALPHA, pulseControl, 0)
    aIn:SetAlphaValues(0.12, 0.58)
    aIn:SetDuration(250)
    local aOut = pulseTimeline:InsertAnimation(ANIMATION_ALPHA, pulseControl, 250)
    aOut:SetAlphaValues(0.58, 0.12)
    aOut:SetDuration(250)
    pulseTimeline:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY)

    ApplyHudPosition()
end

local function UpdateHud()
    EnsureHud()

    local sv = GetSV()
    local remainingMs = GetRemainingMs()
    local remainingPct = zo_clamp(remainingMs / SWIM_LIMIT_MS, 0, 1)
    local fillWidth = zo_max(1, zo_round(134 * remainingPct))

    titleLabel:SetHidden(not (sv.hud.showLabels == true))
    timeLabel:SetText(FormatClock(remainingMs))
    statusLabel:SetText(IsSwimming() and "Leave the water" or "Dry")
    progressFill:SetDimensions(fillWidth, 8)

    local urgent = remainingMs <= 5 * 1000 and IsSwimming()
    if urgent then
        timeLabel:SetColor(1, 0.22, 0.16, 1)
        progressFill:SetCenterColor(1, 0.08, 0.04, 0.95)
        if pulseTimeline and not pulseTimeline:IsPlaying() then
            pulseTimeline:PlayFromStart()
        end
        pulseControl:SetHidden(false)
    else
        timeLabel:SetColor(1, 0.96, 0.80, 1)
        progressFill:SetCenterColor(1, 0.20, 0.12, 0.95)
        if pulseTimeline and pulseTimeline:IsPlaying() then
            pulseTimeline:Stop()
        end
        pulseControl:SetAlpha(0)
        pulseControl:SetHidden(true)
    end

    UpdateLockState()
    UpdateVisibility()
end

local function FailForSwimming()
    if HARDCORE and HARDCORE.FailChallenge then
        HARDCORE.FailChallenge("HARDCORE: Challenge failed. You stayed in the water too long.")
    end
end

local function StopTimer()
    EVENT_MANAGER:UnregisterForUpdate(NS .. "_TICK")
    Rule._startedMs = 0
    Rule._warned = false
    local sv = GetSV()
    sv.startedAtS = 0
    sv.warned = false
    UpdateHud()
end

local function CheckSwimming()
    if not (Rule.active and IsHardcoreActive()) or IsDead() then
        StopTimer()
        return
    end

    if not IsSwimming() then
        StopTimer()
        return
    end

    local now = GetFrameTimeMilliseconds()
    local sv = GetSV()
    if Rule._startedMs <= 0 and sv.startedAtS <= 0 then
        Rule._startedMs = now
        sv.startedAtS = GetTimeStamp()
        sv.warned = false
    else
        EnsureRuntimeStartFromSaved(sv)
    end

    local elapsed = now - Rule._startedMs
    if elapsed >= SWIM_LIMIT_MS then
        FailForSwimming()
    elseif elapsed >= 10 * 1000 and not Rule._warned then
        Rule._warned = true
        sv.warned = true
        Alert("HARDCORE: Leave the water now.", SOUNDS.DUEL_START)
    end
    UpdateHud()
end

local function StartTimer()
    if not (Rule.active and IsHardcoreActive()) then
        return
    end
    local sv = GetSV()
    if Rule._startedMs > 0 or sv.startedAtS > 0 then
        EnsureRuntimeStartFromSaved(sv)
        EVENT_MANAGER:UnregisterForUpdate(NS .. "_TICK")
        EVENT_MANAGER:RegisterForUpdate(NS .. "_TICK", TICK_MS, CheckSwimming)
        CheckSwimming()
        return
    end
    Rule._startedMs = GetFrameTimeMilliseconds()
    Rule._warned = false
    sv.startedAtS = GetTimeStamp()
    sv.warned = false
    Alert("HARDCORE: Water is forbidden. You have 15 seconds.", SOUNDS.DUEL_START)
    UpdateHud()
    EVENT_MANAGER:UnregisterForUpdate(NS .. "_TICK")
    EVENT_MANAGER:RegisterForUpdate(NS .. "_TICK", TICK_MS, CheckSwimming)
end

local function RegisterEvents()
    EVENT_MANAGER:UnregisterForEvent(NS .. "_SWIM", EVENT_PLAYER_SWIMMING)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_NOSWIM", EVENT_PLAYER_NOT_SWIMMING)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_ACTIVATED", EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_RESIZE", EVENT_SCREEN_RESIZED)

    EVENT_MANAGER:RegisterForEvent(NS .. "_SWIM", EVENT_PLAYER_SWIMMING, StartTimer)
    EVENT_MANAGER:RegisterForEvent(NS .. "_NOSWIM", EVENT_PLAYER_NOT_SWIMMING, StopTimer)
    EVENT_MANAGER:RegisterForEvent(NS .. "_ACTIVATED", EVENT_PLAYER_ACTIVATED, function()
        if IsSwimming() then
            StartTimer()
        else
            UpdateHud()
        end
    end)
    EVENT_MANAGER:RegisterForEvent(NS .. "_RESIZE", EVENT_SCREEN_RESIZED, ApplyHudPosition)
end

local function UnregisterEvents()
    EVENT_MANAGER:UnregisterForEvent(NS .. "_SWIM", EVENT_PLAYER_SWIMMING)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_NOSWIM", EVENT_PLAYER_NOT_SWIMMING)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_ACTIVATED", EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_RESIZE", EVENT_SCREEN_RESIZED)
    StopTimer()
end

local function HookScenes()
    if Rule._installedScenes or not SCENE_MANAGER then
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
    EnsureHud()
    HookScenes()
    RegisterEvents()
    if IsSwimming() then
        StartTimer()
    else
        UpdateHud()
    end
end

function Rule:OnDisable()
    self.active = false
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

function Rule:ResetHudPosition()
    local sv = GetSV()
    sv.hud.x = DEFAULT_HUD_X
    sv.hud.y = DEFAULT_HUD_Y
    ApplyHudPosition()
    UpdateHud()
end

function HARDCORE.GetNoSwimmingSV()
    return GetSV()
end

function HARDCORE.RefreshNoSwimmingOptions()
    if Rule.RefreshOptions then
        Rule:RefreshOptions()
    end
end

function HARDCORE.ResetNoSwimmingHudPosition()
    Rule:ResetHudPosition()
end

HARDCORE.RuleManager:RegisterRule(Rule)
