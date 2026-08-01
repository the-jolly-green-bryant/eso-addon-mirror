local HARDCORE = HARDCORE

local ID = "NeedOfBlood"
local NS = "HARDCORE_NeedOfBlood"

local KILL_INTERVAL_MS = 10 * 60 * 1000
local WARNING_MS = 60 * 1000
local GRACE_MS = 20 * 1000
local TICK_MS = 1000
local OLD_DEFAULT_HUD_X = 980
local OLD_DEFAULT_HUD_Y = 710
local DEFAULT_HUD_X = 1340
local DEFAULT_HUD_Y = 710
local ICON_NEED_OF_BLOOD = "/esoui/art/lfg/lfg_dps_up_64.dds"
local FRAME_TEXTURE = "/esoui/art/actionbar/abilityframe64_up.dds"
local GLOW_TEXTURE = "/esoui/art/actionbar/abilityframe64_glow.dds"

local PLAYER_KILL_SOURCE_TYPES = {
    [COMBAT_UNIT_TYPE_PLAYER] = true,
    [COMBAT_UNIT_TYPE_PLAYER_PET] = true,
    [COMBAT_UNIT_TYPE_PLAYER_COMPANION] = true
}

local KILL_ACTION_RESULTS = {
    [ACTION_RESULT_DIED_XP] = true,
    [ACTION_RESULT_KILLING_BLOW] = true
}

local KILL_PROGRESS_REASONS = {
    [PROGRESS_REASON_KILL] = true,
    [PROGRESS_REASON_BOSS_KILL] = true,
    [PROGRESS_REASON_DRAGON_KILL] = true,
    [PROGRESS_REASON_OVERLAND_BOSS_KILL] = true
}

local Rule = {
    id = ID,
    title = "Need of Blood: kill during the demand",
    icon = ICON_NEED_OF_BLOOD,
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
    if not HARDCORE.needOfBloodSaved then
        HARDCORE.needOfBloodSaved = ZO_SavedVars:NewCharacterIdSettings("HARDCORE_NEED_OF_BLOOD_SV", 1, nil, {
            intervalRemainingMs = KILL_INTERVAL_MS,
            graceRemainingMs = GRACE_MS,
            demandActive = false,
            warnedDue = false,
            lastUpdateS = 0,
            hud = {
                x = DEFAULT_HUD_X,
                y = DEFAULT_HUD_Y,
                unlocked = false,
                showLabels = true
            }
        }, GetWorldName())
    end

    local sv = HARDCORE.needOfBloodSaved
    sv.intervalRemainingMs = zo_clamp(tonumber(sv.intervalRemainingMs) or KILL_INTERVAL_MS, 0, KILL_INTERVAL_MS)
    sv.graceRemainingMs = zo_clamp(tonumber(sv.graceRemainingMs) or GRACE_MS, 0, GRACE_MS)
    sv.demandActive = sv.demandActive == true
    sv.warnedDue = sv.warnedDue == true
    sv.lastUpdateS = tonumber(sv.lastUpdateS) or 0
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

local function GetRemainingMs()
    local sv = GetSV()
    return sv.demandActive and sv.graceRemainingMs or sv.intervalRemainingMs
end

local function GetCurrentWindowMs()
    return GetSV().demandActive and GRACE_MS or KILL_INTERVAL_MS
end

local function MarkUpdated(sv)
    sv = sv or GetSV()
    sv.lastUpdateS = GetTimeStamp()
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
    hudTLW = wm:CreateTopLevelWindow("HARDCORE_NeedOfBloodHUD")
    hudTLW:SetDimensions(214, 70)
    hudTLW:SetDrawTier(DT_HIGH)
    hudTLW:SetDrawLayer(DL_OVERLAY)
    hudTLW:SetDrawLevel(9204)
    hudTLW:SetMouseEnabled(false)
    hudTLW:SetMovable(false)
    hudTLW:SetClampedToScreen(true)
    hudTLW:SetHidden(true)

    local bg = wm:CreateControl(nil, hudTLW, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.032, 0.010, 0.016, 0.86)
    bg:SetEdgeTexture("/esoui/art/chatwindow/chat_bg_edge.dds", 32, 4, 4)
    bg:SetEdgeColor(0.74, 0.08, 0.18, 0.78)

    local glow = wm:CreateControl(nil, hudTLW, CT_TEXTURE)
    glow:SetAnchor(LEFT, hudTLW, LEFT, 5, 0)
    glow:SetDimensions(58, 58)
    glow:SetTexture(GLOW_TEXTURE)
    glow:SetColor(1, 0.08, 0.22, 1)
    glow:SetAlpha(0.24)
    glow:SetBlendMode(TEX_BLEND_MODE_ADD)

    iconControl = wm:CreateControl(nil, hudTLW, CT_TEXTURE)
    iconControl:SetAnchor(LEFT, hudTLW, LEFT, 8, 0)
    iconControl:SetDimensions(46, 46)
    iconControl:SetTexture(ICON_NEED_OF_BLOOD)
    iconControl:SetColor(1, 0.48, 0.56, 1)

    local frame = wm:CreateControl(nil, hudTLW, CT_TEXTURE)
    frame:SetAnchor(CENTER, iconControl, CENTER, 0, 0)
    frame:SetDimensions(56, 56)
    frame:SetTexture(FRAME_TEXTURE)
    frame:SetColor(1, 0.64, 0.70, 0.92)

    pulseControl = wm:CreateControl(nil, hudTLW, CT_TEXTURE)
    pulseControl:SetAnchor(CENTER, iconControl, CENTER, 0, 0)
    pulseControl:SetDimensions(62, 62)
    pulseControl:SetTexture("/esoui/art/quest/texthighlight.dds")
    pulseControl:SetColor(1, 0.05, 0.16, 1)
    pulseControl:SetAlpha(0)
    pulseControl:SetBlendMode(TEX_BLEND_MODE_ADD)

    titleLabel = wm:CreateControl(nil, hudTLW, CT_LABEL)
    titleLabel:SetAnchor(TOPLEFT, hudTLW, TOPLEFT, 65, 7)
    titleLabel:SetDimensions(140, 16)
    titleLabel:SetFont("$(BOLD_FONT)|13|soft-shadow-thin")
    titleLabel:SetColor(1, 0.58, 0.66, 0.98)
    titleLabel:SetText("BLOOD")

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
    statusLabel:SetColor(1, 0.62, 0.70, 0.96)

    progressBg = wm:CreateControl(nil, hudTLW, CT_BACKDROP)
    progressBg:SetAnchor(TOPLEFT, statusLabel, BOTTOMLEFT, 0, 5)
    progressBg:SetDimensions(134, 8)
    progressBg:SetCenterColor(0, 0, 0, 0.55)
    progressBg:SetEdgeColor(0.44, 0.08, 0.14, 0.72)

    progressFill = wm:CreateControl(nil, progressBg, CT_BACKDROP)
    progressFill:SetAnchor(LEFT, progressBg, LEFT, 0, 0)
    progressFill:SetDimensions(134, 8)
    progressFill:SetCenterColor(0.92, 0.05, 0.18, 0.95)
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
    aIn:SetDuration(300)
    local aOut = pulseTimeline:InsertAnimation(ANIMATION_ALPHA, pulseControl, 300)
    aOut:SetAlphaValues(0.58, 0.12)
    aOut:SetDuration(300)
    pulseTimeline:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY)

    ApplyHudPosition()
end

local function UpdateHud()
    EnsureHud()

    local sv = GetSV()
    local remainingMs = GetRemainingMs()
    local remainingPct = zo_clamp(remainingMs / GetCurrentWindowMs(), 0, 1)
    local fillWidth = zo_max(1, zo_round(134 * remainingPct))
    local inGrace = sv.demandActive == true

    titleLabel:SetHidden(not (sv.hud.showLabels == true))
    timeLabel:SetText(FormatClock(remainingMs))
    statusLabel:SetText(inGrace and "Kill now" or "Blood demand")
    progressFill:SetDimensions(fillWidth, 8)

    local urgent = inGrace or remainingMs <= WARNING_MS
    if urgent then
        timeLabel:SetColor(1, 0.18, 0.18, 1)
        progressFill:SetCenterColor(1, 0.02, 0.08, 0.96)
        if pulseTimeline and not pulseTimeline:IsPlaying() then
            pulseTimeline:PlayFromStart()
        end
        pulseControl:SetHidden(false)
    else
        timeLabel:SetColor(1, 0.96, 0.80, 1)
        progressFill:SetCenterColor(0.92, 0.05, 0.18, 0.95)
        if pulseTimeline and pulseTimeline:IsPlaying() then
            pulseTimeline:Stop()
        end
        pulseControl:SetAlpha(0)
        pulseControl:SetHidden(true)
    end

    UpdateLockState()
    UpdateVisibility()
end

local function ResetCycle(sv)
    sv = sv or GetSV()
    sv.intervalRemainingMs = KILL_INTERVAL_MS
    sv.graceRemainingMs = GRACE_MS
    sv.demandActive = false
    sv.warnedDue = false
    MarkUpdated(sv)
    UpdateHud()
end

local function StartGraceWindow(sv, overflowMs)
    sv = sv or GetSV()
    sv.intervalRemainingMs = 0
    sv.graceRemainingMs = zo_clamp(GRACE_MS - (tonumber(overflowMs) or 0), 0, GRACE_MS)
    sv.demandActive = true
    sv.warnedDue = true
    MarkUpdated(sv)
    Alert("HARDCORE: Need of Blood. Kill within 20 seconds.", SOUNDS.DUEL_START)
    UpdateHud()
end

local function FailForBloodNeed()
    if HARDCORE and HARDCORE.FailChallenge then
        HARDCORE.FailChallenge("HARDCORE: Challenge failed. You did not kill during the blood demand.")
    end
end

local function CheckBloodNeed()
    local sv = GetSV()
    if not (Rule.active and IsHardcoreActive()) or IsDead() then
        MarkUpdated(sv)
        UpdateHud()
        return
    end

    if sv.lastUpdateS <= 0 then
        MarkUpdated(sv)
        UpdateHud()
        return
    end

    local nowS = GetTimeStamp()
    local elapsedS = zo_max(0, GetDiffBetweenTimeStamps(nowS, sv.lastUpdateS))
    if elapsedS <= 0 then
        UpdateHud()
        return
    end
    sv.lastUpdateS = nowS

    local elapsedMs = elapsedS * 1000
    if sv.demandActive then
        sv.graceRemainingMs = zo_clamp(sv.graceRemainingMs - elapsedMs, 0, GRACE_MS)
        if sv.graceRemainingMs <= 0 then
            FailForBloodNeed()
        end
        UpdateHud()
        return
    end

    if elapsedMs >= sv.intervalRemainingMs then
        local overflowMs = elapsedMs - sv.intervalRemainingMs
        StartGraceWindow(sv, overflowMs)
        if sv.graceRemainingMs <= 0 then
            FailForBloodNeed()
        end
    else
        sv.intervalRemainingMs = zo_clamp(sv.intervalRemainingMs - elapsedMs, 0, KILL_INTERVAL_MS)
    end

    if not sv.demandActive and sv.intervalRemainingMs <= WARNING_MS and not sv.warnedDue then
        sv.warnedDue = true
        Alert("HARDCORE: Need of Blood soon. A kill will be demanded in one minute.", SOUNDS.DUEL_START)
    end
    UpdateHud()
end

local function IsBloodDemandActive()
    return GetSV().demandActive == true
end

local function SatisfyBloodDemand()
    ResetCycle()
    Alert("HARDCORE: Blood demand satisfied.", SOUNDS.QUEST_ACCEPTED)
end

local function IsPlayerKill(result, sourceType, targetType)
    if not KILL_ACTION_RESULTS[result] then
        return false
    end
    if not PLAYER_KILL_SOURCE_TYPES[sourceType] then
        return false
    end
    if targetType == COMBAT_UNIT_TYPE_TARGET_DUMMY then
        return false
    end
    return true
end

local function OnCombatEvent(_, result, isError, _abilityName, _abilityGraphic, _abilityActionSlotType, _sourceName,
    sourceType, _targetName, targetType)
    if not (Rule.active and IsHardcoreActive()) or isError then
        return
    end
    if not IsPlayerKill(result, sourceType, targetType) then
        return
    end

    CheckBloodNeed()
    if not (Rule.active and IsHardcoreActive()) then
        return
    end

    if IsBloodDemandActive() then
        SatisfyBloodDemand()
    end
end

local function OnExperienceGain(_, reason)
    if not (Rule.active and IsHardcoreActive()) then
        return
    end
    if not KILL_PROGRESS_REASONS[reason] then
        return
    end

    CheckBloodNeed()
    if not (Rule.active and IsHardcoreActive()) then
        return
    end

    if IsBloodDemandActive() then
        SatisfyBloodDemand()
    end
end

local function RegisterEvents()
    EVENT_MANAGER:UnregisterForUpdate(NS .. "_TICK")
    EVENT_MANAGER:UnregisterForEvent(NS .. "_COMBAT", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_XP", EVENT_EXPERIENCE_GAIN)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_ACTIVATED", EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_RESIZE", EVENT_SCREEN_RESIZED)

    EVENT_MANAGER:RegisterForUpdate(NS .. "_TICK", TICK_MS, CheckBloodNeed)
    EVENT_MANAGER:RegisterForEvent(NS .. "_COMBAT", EVENT_COMBAT_EVENT, OnCombatEvent)
    EVENT_MANAGER:RegisterForEvent(NS .. "_XP", EVENT_EXPERIENCE_GAIN, OnExperienceGain)
    EVENT_MANAGER:RegisterForEvent(NS .. "_ACTIVATED", EVENT_PLAYER_ACTIVATED, function()
        CheckBloodNeed()
    end)
    EVENT_MANAGER:RegisterForEvent(NS .. "_RESIZE", EVENT_SCREEN_RESIZED, ApplyHudPosition)
end

local function UnregisterEvents()
    EVENT_MANAGER:UnregisterForUpdate(NS .. "_TICK")
    EVENT_MANAGER:UnregisterForEvent(NS .. "_COMBAT", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_XP", EVENT_EXPERIENCE_GAIN)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_ACTIVATED", EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_RESIZE", EVENT_SCREEN_RESIZED)
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
    local sv = GetSV()
    if sv.lastUpdateS <= 0 then
        MarkUpdated(sv)
    end
    CheckBloodNeed()
end

function Rule:OnDisable()
    self.active = false
    UnregisterEvents()
    ResetCycle()
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

function Rule:ResetTimer()
    ResetCycle()
end

function HARDCORE.DebugNeedOfBloodStatus()
    local sv = GetSV()
    d("Need of Blood active=" .. tostring(Rule.active) ..
        " demand=" .. tostring(sv.demandActive) ..
        " interval=" .. FormatClock(sv.intervalRemainingMs) ..
        " grace=" .. FormatClock(sv.graceRemainingMs) ..
        " warned=" .. tostring(sv.warnedDue) ..
        " hud=(" .. tostring(sv.hud.x) .. "," .. tostring(sv.hud.y) .. ")" ..
        " unlocked=" .. tostring(sv.hud.unlocked))
end

function HARDCORE.DebugNeedOfBloodCommand(action)
    action = action or "help"
    local sv = GetSV()

    if action == "help" then
        d("Need of Blood debug:")
        d("/hc debug blood status")
        d("/hc debug blood due")
        d("/hc debug blood satisfy")
        d("/hc debug blood reset")
        d("/hc debug blood hud")
        return
    end

    if action == "status" then
        HARDCORE.DebugNeedOfBloodStatus()
        return
    end

    if action == "due" then
        StartGraceWindow(sv, 0)
        HARDCORE.DebugNeedOfBloodStatus()
        return
    end

    if action == "satisfy" then
        if sv.demandActive then
            SatisfyBloodDemand()
            d("Need of Blood: demand satisfied by debug command.")
        else
            d("Need of Blood: no active demand to satisfy.")
        end
        HARDCORE.DebugNeedOfBloodStatus()
        return
    end

    if action == "reset" then
        Rule:ResetTimer()
        d("Need of Blood: timer reset.")
        return
    end

    if action == "hud" then
        EnsureHud()
        UpdateHud()
        if hudTLW then
            hudTLW:SetHidden(false)
        end
        d("Need of Blood: HUD forced visible until the next scene/update refresh.")
        return
    end

    d("Unknown Need of Blood debug action: " .. tostring(action))
end

function HARDCORE.GetNeedOfBloodSV()
    return GetSV()
end

function HARDCORE.RefreshNeedOfBloodOptions()
    if Rule.RefreshOptions then
        Rule:RefreshOptions()
    end
end

function HARDCORE.ResetNeedOfBloodHudPosition()
    Rule:ResetHudPosition()
end

function HARDCORE.ResetNeedOfBloodTimer()
    Rule:ResetTimer()
end

HARDCORE.RuleManager:RegisterRule(Rule)
