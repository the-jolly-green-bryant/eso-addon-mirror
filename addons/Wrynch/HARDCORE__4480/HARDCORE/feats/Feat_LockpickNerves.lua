local HARDCORE = HARDCORE

local ID = "LockpickNerves"
local NS = "HARDCORE_LockpickNerves"

local WINDOW_MS = 10 * 1000
local MAX_STRIKES = 3
local TICK_MS = 1000

local ICON_LOCKPICK = "/esoui/art/lockpicking/lock_pick.dds"
local FRAME_TEXTURE = "/esoui/art/actionbar/abilityframe64_up.dds"
local GLOW_TEXTURE = "/esoui/art/actionbar/abilityframe64_glow.dds"
local OLD_DEFAULT_HUD_X = 760
local OLD_DEFAULT_HUD_Y = 710
local DEFAULT_HUD_X = 1120
local DEFAULT_HUD_Y = 710

local Rule = {
    id = ID,
    title = "Lockpick Nerves: failed lockpicks build panic",
    icon = ICON_LOCKPICK,
    defaultEnabled = false
}

Rule.active = false
Rule._installedScenes = false

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
    if not HARDCORE.lockpickNervesSaved then
        HARDCORE.lockpickNervesSaved = ZO_SavedVars:NewCharacterIdSettings("HARDCORE_LOCKPICK_NERVES_SV", 1, nil, {
            strikes = {},
            hud = {
                x = DEFAULT_HUD_X,
                y = DEFAULT_HUD_Y,
                unlocked = false,
                showLabels = true
            },
            warnedSecondStrike = false
        }, GetWorldName())
    end

    local sv = HARDCORE.lockpickNervesSaved
    sv.strikes = type(sv.strikes) == "table" and sv.strikes or {}
    sv.hud = sv.hud or {}
    if sv.hud.x == OLD_DEFAULT_HUD_X and sv.hud.y == OLD_DEFAULT_HUD_Y then
        sv.hud.x = DEFAULT_HUD_X
        sv.hud.y = DEFAULT_HUD_Y
    end
    if sv.hud.x == nil then sv.hud.x = DEFAULT_HUD_X end
    if sv.hud.y == nil then sv.hud.y = DEFAULT_HUD_Y end
    if sv.hud.unlocked == nil then sv.hud.unlocked = false end
    if sv.hud.showLabels == nil then sv.hud.showLabels = true end
    sv.warnedSecondStrike = sv.warnedSecondStrike == true
    return sv
end

local function IsHardcoreActive()
    return HARDCORE and HARDCORE.saved and HARDCORE.saved.isActive
end

local function IsOnHud()
    return SCENE_MANAGER and (SCENE_MANAGER:IsShowing("hud") or SCENE_MANAGER:IsShowing("hudui") or SCENE_MANAGER:IsShowing("gamepad_hud"))
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

local function PruneStrikes(sv, now)
    sv = sv or GetSV()
    now = now or GetFrameTimeMilliseconds()

    local kept = {}
    for _, strikeMs in ipairs(sv.strikes or {}) do
        strikeMs = tonumber(strikeMs)
        if strikeMs and now - strikeMs < WINDOW_MS then
            kept[#kept + 1] = strikeMs
        end
    end
    sv.strikes = kept
    if #kept < 2 then
        sv.warnedSecondStrike = false
    end
    return kept
end

local function GetNextStrikeExpiryMs(sv, now)
    sv = sv or GetSV()
    now = now or GetFrameTimeMilliseconds()
    local oldest
    for _, strikeMs in ipairs(sv.strikes or {}) do
        strikeMs = tonumber(strikeMs)
        if strikeMs and (not oldest or strikeMs < oldest) then
            oldest = strikeMs
        end
    end
    if not oldest then
        return 0
    end
    return zo_max(0, WINDOW_MS - (now - oldest))
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
    hudTLW = wm:CreateTopLevelWindow("HARDCORE_LockpickNervesHUD")
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
    bg:SetCenterColor(0.030, 0.022, 0.018, 0.84)
    bg:SetEdgeTexture("/esoui/art/chatwindow/chat_bg_edge.dds", 32, 4, 4)
    bg:SetEdgeColor(0.72, 0.34, 0.14, 0.72)

    local glow = wm:CreateControl(nil, hudTLW, CT_TEXTURE)
    glow:SetAnchor(LEFT, hudTLW, LEFT, 5, 0)
    glow:SetDimensions(58, 58)
    glow:SetTexture(GLOW_TEXTURE)
    glow:SetColor(0.95, 0.42, 0.12, 1)
    glow:SetAlpha(0.22)
    glow:SetBlendMode(TEX_BLEND_MODE_ADD)

    iconControl = wm:CreateControl(nil, hudTLW, CT_TEXTURE)
    iconControl:SetAnchor(LEFT, hudTLW, LEFT, 8, 0)
    iconControl:SetDimensions(46, 46)
    iconControl:SetTexture(ICON_LOCKPICK)
    iconControl:SetColor(1, 0.86, 0.66, 1)

    local frame = wm:CreateControl(nil, hudTLW, CT_TEXTURE)
    frame:SetAnchor(CENTER, iconControl, CENTER, 0, 0)
    frame:SetDimensions(56, 56)
    frame:SetTexture(FRAME_TEXTURE)
    frame:SetColor(1, 0.80, 0.46, 0.92)

    pulseControl = wm:CreateControl(nil, hudTLW, CT_TEXTURE)
    pulseControl:SetAnchor(CENTER, iconControl, CENTER, 0, 0)
    pulseControl:SetDimensions(62, 62)
    pulseControl:SetTexture("/esoui/art/quest/texthighlight.dds")
    pulseControl:SetColor(1, 0.20, 0.08, 1)
    pulseControl:SetAlpha(0)
    pulseControl:SetBlendMode(TEX_BLEND_MODE_ADD)

    titleLabel = wm:CreateControl(nil, hudTLW, CT_LABEL)
    titleLabel:SetAnchor(TOPLEFT, hudTLW, TOPLEFT, 65, 7)
    titleLabel:SetDimensions(140, 16)
    titleLabel:SetFont("$(BOLD_FONT)|13|soft-shadow-thin")
    titleLabel:SetColor(1, 0.86, 0.62, 0.98)
    titleLabel:SetText("LOCKPICK")

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
    statusLabel:SetColor(0.88, 0.82, 0.74, 0.96)

    progressBg = wm:CreateControl(nil, hudTLW, CT_BACKDROP)
    progressBg:SetAnchor(TOPLEFT, statusLabel, BOTTOMLEFT, 0, 5)
    progressBg:SetDimensions(134, 8)
    progressBg:SetCenterColor(0, 0, 0, 0.55)
    progressBg:SetEdgeColor(0.38, 0.18, 0.10, 0.72)

    progressFill = wm:CreateControl(nil, progressBg, CT_BACKDROP)
    progressFill:SetAnchor(LEFT, progressBg, LEFT, 0, 0)
    progressFill:SetDimensions(1, 8)
    progressFill:SetCenterColor(0.95, 0.36, 0.10, 0.92)
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
    local now = GetFrameTimeMilliseconds()
    local strikes = PruneStrikes(sv, now)
    local count = #strikes
    local pct = zo_clamp(count / MAX_STRIKES, 0, 1)

    progressFill:SetDimensions(zo_max(1, zo_round(134 * pct)), 8)
    titleLabel:SetHidden(not (sv.hud.showLabels == true))
    statusLabel:SetText(tostring(count) .. "/" .. tostring(MAX_STRIKES) .. " nerves")

    if count <= 0 then
        timeLabel:SetText("Calm")
        timeLabel:SetColor(0.88, 1, 0.72, 1)
        statusLabel:SetColor(0.88, 0.82, 0.74, 0.96)
        progressFill:SetCenterColor(0.95, 0.66, 0.18, 0.80)
        iconControl:SetColor(1, 0.86, 0.66, 1)
    else
        timeLabel:SetText(FormatClock(GetNextStrikeExpiryMs(sv, now)))
        if count >= MAX_STRIKES - 1 then
            timeLabel:SetColor(1, 0.28, 0.16, 1)
            statusLabel:SetColor(1, 0.58, 0.42, 1)
            progressFill:SetCenterColor(1, 0.18, 0.08, 0.95)
            iconControl:SetColor(1, 0.62, 0.44, 1)
        else
            timeLabel:SetColor(1, 0.92, 0.64, 1)
            statusLabel:SetColor(0.96, 0.78, 0.58, 1)
            progressFill:SetCenterColor(0.95, 0.42, 0.12, 0.92)
            iconControl:SetColor(1, 0.78, 0.56, 1)
        end
    end

    local critical = count >= MAX_STRIKES - 1
    pulseControl:SetHidden(not critical)
    if critical then
        if pulseTimeline and not pulseTimeline:IsPlaying() then
            pulseTimeline:PlayFromStart()
        end
    elseif pulseTimeline and pulseTimeline:IsPlaying() then
        pulseTimeline:Stop()
        pulseControl:SetAlpha(0)
    end

    UpdateLockState()
    UpdateVisibility()
end

local function ResetStrikes()
    local sv = GetSV()
    sv.strikes = {}
    sv.warnedSecondStrike = false
    UpdateHud()
end

local function FailForNerves()
    if HARDCORE and HARDCORE.FailChallenge then
        HARDCORE.FailChallenge("HARDCORE: Challenge failed. Your lockpick nerves broke.")
    end
end

local function AddStrike(label, force)
    if not (force or (Rule.active and IsHardcoreActive())) then
        return
    end
    local sv = GetSV()
    local now = GetFrameTimeMilliseconds()
    local strikes = PruneStrikes(sv, now)
    strikes[#strikes + 1] = now
    sv.strikes = strikes

    if #strikes >= MAX_STRIKES then
        Alert("HARDCORE: Lockpick Nerves broke.", SOUNDS.LOCKPICKING_BREAK or SOUNDS.NEGATIVE_CLICK)
        FailForNerves()
        return
    end

    if #strikes >= MAX_STRIKES - 1 and not sv.warnedSecondStrike then
        sv.warnedSecondStrike = true
        Alert("HARDCORE: One more lockpick mistake will end the challenge.", SOUNDS.DUEL_START)
    else
        Alert("HARDCORE: " .. label .. " shook your nerves.", SOUNDS.LOCKPICKING_FAILED or SOUNDS.NEGATIVE_CLICK)
    end
    UpdateHud()
end

local function RemoveStrikeOnSuccess(force)
    if not (force or (Rule.active and IsHardcoreActive())) then
        return
    end
    local sv = GetSV()
    local strikes = PruneStrikes(sv, GetFrameTimeMilliseconds())
    if #strikes > 0 then
        table.remove(strikes, 1)
        sv.strikes = strikes
        if #strikes < MAX_STRIKES - 1 then
            sv.warnedSecondStrike = false
        end
        Alert("HARDCORE: Steady hands. Lockpick nerves eased.", SOUNDS.LOCKPICKING_UNLOCKED or SOUNDS.QUEST_ACCEPTED)
    end
    UpdateHud()
end

local function RegisterUpdateLoop()
    EVENT_MANAGER:UnregisterForUpdate(NS .. "_TICK")
    if Rule.active then
        EVENT_MANAGER:RegisterForUpdate(NS .. "_TICK", TICK_MS, UpdateHud)
    end
end

local function RegisterEvents()
    EVENT_MANAGER:UnregisterForEvent(NS .. "_FAILED", EVENT_LOCKPICK_FAILED)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_BROKE", EVENT_LOCKPICK_BROKE)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_SUCCESS", EVENT_LOCKPICK_SUCCESS)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_ACTIVATED", EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_RESIZE", EVENT_SCREEN_RESIZED)

    EVENT_MANAGER:RegisterForEvent(NS .. "_FAILED", EVENT_LOCKPICK_FAILED, function()
        AddStrike("A failed lockpick")
    end)
    EVENT_MANAGER:RegisterForEvent(NS .. "_BROKE", EVENT_LOCKPICK_BROKE, function()
        AddStrike("A broken lockpick")
    end)
    EVENT_MANAGER:RegisterForEvent(NS .. "_SUCCESS", EVENT_LOCKPICK_SUCCESS, RemoveStrikeOnSuccess)
    EVENT_MANAGER:RegisterForEvent(NS .. "_ACTIVATED", EVENT_PLAYER_ACTIVATED, function()
        if Rule.active then
            UpdateHud()
        end
    end)
    EVENT_MANAGER:RegisterForEvent(NS .. "_RESIZE", EVENT_SCREEN_RESIZED, ApplyHudPosition)
end

local function UnregisterEvents()
    EVENT_MANAGER:UnregisterForEvent(NS .. "_FAILED", EVENT_LOCKPICK_FAILED)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_BROKE", EVENT_LOCKPICK_BROKE)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_SUCCESS", EVENT_LOCKPICK_SUCCESS)
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

function Rule:ResetStrikes()
    ResetStrikes()
end

function Rule:ResetHudPosition()
    local sv = GetSV()
    sv.hud.x = DEFAULT_HUD_X
    sv.hud.y = DEFAULT_HUD_Y
    ApplyHudPosition()
    UpdateHud()
end

function HARDCORE.GetLockpickNervesSV()
    return GetSV()
end

function HARDCORE.RefreshLockpickNervesOptions()
    if Rule.RefreshOptions then
        Rule:RefreshOptions()
    end
end

function HARDCORE.ResetLockpickNervesStrikes()
    Rule:ResetStrikes()
end

function HARDCORE.ResetLockpickNervesHudPosition()
    Rule:ResetHudPosition()
end

function HARDCORE.DebugLockpickNervesStatus()
    local sv = GetSV()
    local now = GetFrameTimeMilliseconds()
    local strikes = PruneStrikes(sv, now)
    d("Lockpick Nerves active=" .. tostring(Rule.active) ..
        " strikes=" .. tostring(#strikes) .. "/" .. tostring(MAX_STRIKES) ..
        " nextExpiry=" .. FormatClock(GetNextStrikeExpiryMs(sv, now)) ..
        " hud=(" .. tostring(sv.hud.x) .. "," .. tostring(sv.hud.y) .. ")" ..
        " unlocked=" .. tostring(sv.hud.unlocked))
end

function HARDCORE.DebugLockpickNervesCommand(action)
    action = action or "help"

    if action == "help" then
        d("Lockpick Nerves debug:")
        d("/hc debug lockpick status")
        d("/hc debug lockpick fail")
        d("/hc debug lockpick break")
        d("/hc debug lockpick success")
        d("/hc debug lockpick reset")
        d("/hc debug lockpick hud")
        return
    end

    if action == "status" then
        HARDCORE.DebugLockpickNervesStatus()
        return
    end

    if action == "fail" then
        AddStrike("A failed lockpick", true)
        HARDCORE.DebugLockpickNervesStatus()
        return
    end

    if action == "break" then
        AddStrike("A broken lockpick", true)
        HARDCORE.DebugLockpickNervesStatus()
        return
    end

    if action == "success" then
        RemoveStrikeOnSuccess(true)
        HARDCORE.DebugLockpickNervesStatus()
        return
    end

    if action == "reset" then
        Rule:ResetStrikes()
        d("Lockpick Nerves: strikes reset.")
        return
    end

    if action == "hud" then
        EnsureHud()
        UpdateHud()
        if hudTLW then
            hudTLW:SetHidden(false)
        end
        d("Lockpick Nerves: HUD forced visible until the next scene/update refresh.")
        return
    end

    d("Unknown Lockpick Nerves debug action: " .. tostring(action))
end

HARDCORE.RuleManager:RegisterRule(Rule)
