local HARDCORE = HARDCORE

local ID = "RoadWeariness"
local NS = "HARDCORE_RoadWeariness"

local DEFAULT_FATIGUE_DRAIN_MINUTES = 90
local DEFAULT_RESTORE_SECONDS = 60
local DEFAULT_STAMINA_DRAIN_MULTIPLIER = 18
local DEFAULT_ACTION_DRAIN = 0.35
local DEFAULT_COMBAT_DRAIN = 0.20
local DEFAULT_WEAPON_LOCK_THRESHOLD = 20
local DEFAULT_NPC_LOCK_THRESHOLD = 10
local TICK_MS = 1000
local WARNING_LOW = 35
local WARNING_CRITICAL = 15

local ICON_FATIGUE = "/esoui/art/ava/ava_rankicon64_prefect.dds"
local METER_FRAME_TEXTURE = "/esoui/art/actionbar/abilityframe64_up.dds"
local METER_GLOW_TEXTURE = "/esoui/art/actionbar/abilityframe64_glow.dds"
local OLD_DEFAULT_HUD_X = 478
local OLD_DEFAULT_HUD_Y = 710
local DEFAULT_HUD_X = 838
local DEFAULT_HUD_Y = 710
local SQUARE_HUD_WIDTH = 58
local SQUARE_HUD_HEIGHT = 76
local BAR_HUD_WIDTH = 116
local BAR_HUD_HEIGHT = 36
local BAR_METER_WIDTH = 108
local BAR_METER_HEIGHT = 24
local BAR_ICON_SIZE = 16
local BAR_FILL_WIDTH = 78
local BAR_FILL_HEIGHT = 6
local HUD_STYLE_SQUARE = "square"
local HUD_STYLE_HORIZONTAL = "horizontal"
local DEFAULT_HUD_SCALE = 1
local MIN_HUD_SCALE = 0.60
local MAX_HUD_SCALE = 1.50

local Rule = {
    id = ID,
    title = "Road Weariness: fatigue from exertion and battle",
    icon = ICON_FATIGUE,
    defaultEnabled = false
}

Rule.active = false
Rule._installed = false
Rule._lastStamina = nil
Rule._lastCombatDrainMs = 0
Rule._resting = false

local hudTLW
local hudBg
local fatigueMeter
local currentHorizontalBars
local currentHudScale
local pulseTimeline

local function GetSV()
    HARDCORE = HARDCORE or {}
    if not HARDCORE.roadWearinessSaved then
        HARDCORE.roadWearinessSaved = ZO_SavedVars:NewCharacterIdSettings("HARDCORE_ROAD_WEARINESS_SV", 1, nil, {
            fatigue = 100,
            lastUpdateMs = 0,
            hud = {
                x = DEFAULT_HUD_X,
                y = DEFAULT_HUD_Y,
                unlocked = false,
                showLabels = true,
                displayStyle = HUD_STYLE_SQUARE,
                scale = DEFAULT_HUD_SCALE
            },
            settings = {
                fatigueDrainMinutes = DEFAULT_FATIGUE_DRAIN_MINUTES,
                restoreSeconds = DEFAULT_RESTORE_SECONDS,
                staminaDrainMultiplier = DEFAULT_STAMINA_DRAIN_MULTIPLIER,
                actionDrain = DEFAULT_ACTION_DRAIN,
                combatDrain = DEFAULT_COMBAT_DRAIN,
                weaponLockThreshold = DEFAULT_WEAPON_LOCK_THRESHOLD,
                npcLockThreshold = DEFAULT_NPC_LOCK_THRESHOLD
            },
            warnings = {
                low = false,
                critical = false,
                empty = false,
                weapons = false,
                npcs = false
            }
        }, GetWorldName())
    end

    local sv = HARDCORE.roadWearinessSaved
    sv.fatigue = tonumber(sv.fatigue) or 100
    sv.lastUpdateMs = tonumber(sv.lastUpdateMs) or 0
    sv.hud = sv.hud or {}
    if sv.hud.x == OLD_DEFAULT_HUD_X and sv.hud.y == OLD_DEFAULT_HUD_Y then
        sv.hud.x = DEFAULT_HUD_X
        sv.hud.y = DEFAULT_HUD_Y
    end
    if sv.hud.x == nil then sv.hud.x = DEFAULT_HUD_X end
    if sv.hud.y == nil then sv.hud.y = DEFAULT_HUD_Y end
    if sv.hud.unlocked == nil then sv.hud.unlocked = false end
    if sv.hud.showLabels == nil then sv.hud.showLabels = true end
    if sv.hud.displayStyle ~= HUD_STYLE_HORIZONTAL and sv.hud.displayStyle ~= HUD_STYLE_SQUARE then
        sv.hud.displayStyle = sv.hud.horizontalBars == true and HUD_STYLE_HORIZONTAL or HUD_STYLE_SQUARE
    end
    sv.hud.horizontalBars = nil
    sv.hud.scale = zo_clamp(tonumber(sv.hud.scale) or DEFAULT_HUD_SCALE, MIN_HUD_SCALE, MAX_HUD_SCALE)
    sv.settings = sv.settings or {}
    sv.settings.fatigueDrainMinutes = zo_clamp(tonumber(sv.settings.fatigueDrainMinutes) or DEFAULT_FATIGUE_DRAIN_MINUTES, 10, 300)
    if sv.settings.restoreSeconds == nil then
        sv.settings.restoreSeconds = tonumber(sv.settings.restoreMinutes) or DEFAULT_RESTORE_SECONDS
    end
    sv.settings.restoreMinutes = nil
    sv.settings.restoreSeconds = zo_clamp(tonumber(sv.settings.restoreSeconds) or DEFAULT_RESTORE_SECONDS, 5, 180)
    sv.settings.staminaDrainMultiplier = zo_clamp(tonumber(sv.settings.staminaDrainMultiplier) or DEFAULT_STAMINA_DRAIN_MULTIPLIER, 0, 50)
    sv.settings.actionDrain = zo_clamp(tonumber(sv.settings.actionDrain) or DEFAULT_ACTION_DRAIN, 0, 2)
    sv.settings.combatDrain = zo_clamp(tonumber(sv.settings.combatDrain) or DEFAULT_COMBAT_DRAIN, 0, 2)
    sv.settings.weaponLockThreshold = zo_clamp(tonumber(sv.settings.weaponLockThreshold) or DEFAULT_WEAPON_LOCK_THRESHOLD, 0, 100)
    sv.settings.npcLockThreshold = zo_clamp(tonumber(sv.settings.npcLockThreshold) or DEFAULT_NPC_LOCK_THRESHOLD, 0, 100)
    sv.warnings = sv.warnings or {}
    return sv
end

local function GetMinutesDurationMs(minutes, fallbackMinutes)
    minutes = tonumber(minutes) or fallbackMinutes
    return zo_max(1, minutes) * 60 * 1000
end

local function GetSecondsDurationMs(seconds, fallbackSeconds)
    seconds = tonumber(seconds) or fallbackSeconds
    return zo_max(1, seconds) * 1000
end

local function IsOnHud()
    return SCENE_MANAGER and (SCENE_MANAGER:IsShowing("hud") or SCENE_MANAGER:IsShowing("hudui") or SCENE_MANAGER:IsShowing("gamepad_hud"))
end

local function IsDead()
    return IsUnitDead and IsUnitDead("player")
end

local function ClampMeter(value)
    return zo_clamp(tonumber(value) or 0, 0, 100)
end

local function Alert(text, sound)
    HARDCORE.ShowAlertNoSuppression(UI_ALERT_CATEGORY_ALERT, sound or SOUNDS.NEGATIVE_CLICK, text)
end

local function IsHardcoreActive()
    return HARDCORE and HARDCORE.saved and HARDCORE.saved.isActive
end

local function ResetWarningFlags()
    local sv = GetSV()
    sv.warnings.low = false
    sv.warnings.critical = false
    sv.warnings.empty = false
    sv.warnings.weapons = false
    sv.warnings.npcs = false
end

local function IsRestingInteraction()
    if IsInteracting and IsPlayerInteractingWithObject and GetInteractionType then
        return IsInteracting() and IsPlayerInteractingWithObject() and GetInteractionType() == INTERACTION_FURNITURE
    end
    return false
end

local function StartResting(reason)
    if not Rule.active then
        return
    end
    Rule._resting = true
    if reason then
        Alert("HARDCORE: Resting. Weariness is recovering.", SOUNDS.QUEST_OBJECTIVE_STARTED)
    end
end

local function StopResting()
    Rule._resting = false
end

local REST_SLASHES = {
    ["/sit"] = true,
    ["/sleep"] = true,
    ["/liedown"] = true,
    ["/sleeping"] = true
}

local function IsRestEmoteSlash(slashName)
    slashName = string.lower(tostring(slashName or ""))
    for slash in string.gmatch(slashName, "%S+") do
        if REST_SLASHES[slash] == true then
            return true
        end
    end
    return false
end

local function ApplyHudPosition()
    if not hudTLW then
        return
    end
    local sv = GetSV()
    local rootW = GuiRoot and GuiRoot.GetWidth and GuiRoot:GetWidth() or 0
    local rootH = GuiRoot and GuiRoot.GetHeight and GuiRoot:GetHeight() or 0
    local scale = zo_clamp(tonumber(sv.hud.scale) or DEFAULT_HUD_SCALE, MIN_HUD_SCALE, MAX_HUD_SCALE)
    local hudW = (hudTLW.GetWidth and hudTLW:GetWidth() or SQUARE_HUD_WIDTH) * scale
    local hudH = (hudTLW.GetHeight and hudTLW:GetHeight() or SQUARE_HUD_HEIGHT) * scale
    if rootW > 0 then
        sv.hud.x = zo_clamp(tonumber(sv.hud.x) or DEFAULT_HUD_X, 0, zo_max(0, rootW - hudW))
    end
    if rootH > 0 then
        sv.hud.y = zo_clamp(tonumber(sv.hud.y) or DEFAULT_HUD_Y, 0, zo_max(0, rootH - hudH))
    end
    hudTLW:ClearAnchors()
    hudTLW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.hud.x, sv.hud.y)
end

local function ApplyHudScale(scale)
    if not hudTLW then
        return
    end
    scale = zo_clamp(tonumber(scale) or DEFAULT_HUD_SCALE, MIN_HUD_SCALE, MAX_HUD_SCALE)
    if currentHudScale == scale then
        return
    end
    currentHudScale = scale
    hudTLW:SetScale(scale)
    ApplyHudPosition()
end

local function SetControlsHidden(controls, hidden)
    for _, control in ipairs(controls) do
        control:SetHidden(hidden)
    end
end

local function CreateMeter(parent, name, iconTexture, colorR, colorG, colorB)
    local wm = WINDOW_MANAGER
    local meter = wm:CreateControl(name, parent, CT_CONTROL)
    meter:SetAnchor(LEFT, parent, LEFT, 2, 0)
    meter:SetDimensions(54, 74)

    local glow = wm:CreateControl(nil, meter, CT_TEXTURE)
    glow:SetAnchor(TOP, meter, TOP, 0, 1)
    glow:SetDimensions(54, 54)
    glow:SetTexture(METER_GLOW_TEXTURE)
    glow:SetColor(colorR, colorG, colorB, 1)
    glow:SetAlpha(0.20)
    glow:SetBlendMode(TEX_BLEND_MODE_ADD)

    local bg = wm:CreateControl(nil, meter, CT_BACKDROP)
    bg:SetAnchor(TOP, meter, TOP, 0, 2)
    bg:SetDimensions(50, 50)
    bg:SetCenterColor(0.01, 0.012, 0.012, 0.94)
    bg:SetEdgeColor(0, 0, 0, 0)

    local fill = wm:CreateControl(nil, meter, CT_BACKDROP)
    fill:SetAnchor(TOP, meter, TOP, 0, 2)
    fill:SetDimensions(48, 48)
    fill:SetCenterColor(colorR, colorG, colorB, 0.90)
    fill:SetEdgeColor(0, 0, 0, 0)
    fill:SetAlpha(0.62)

    local shade = wm:CreateControl(nil, meter, CT_BACKDROP)
    shade:SetAnchor(TOP, meter, TOP, 0, 2)
    shade:SetDimensions(48, 48)
    shade:SetCenterColor(0, 0, 0, 1)
    shade:SetEdgeColor(0, 0, 0, 0)
    shade:SetAlpha(0)

    local pulse = wm:CreateControl(nil, meter, CT_TEXTURE)
    pulse:SetAnchor(TOP, meter, TOP, 0, 2)
    pulse:SetDimensions(50, 50)
    pulse:SetTexture("/esoui/art/quest/texthighlight.dds")
    pulse:SetColor(colorR, colorG, colorB, 1)
    pulse:SetAlpha(0)
    pulse:SetBlendMode(TEX_BLEND_MODE_ADD)

    local icon = wm:CreateControl(nil, meter, CT_TEXTURE)
    icon:SetAnchor(TOP, meter, TOP, 0, 12)
    icon:SetDimensions(27, 27)
    icon:SetTexture(iconTexture)
    icon:SetColor(0.95, 0.98, 0.96, 1)

    local frame = wm:CreateControl(nil, meter, CT_TEXTURE)
    frame:SetAnchor(TOP, meter, TOP, 0, 0)
    frame:SetDimensions(54, 54)
    frame:SetTexture(METER_FRAME_TEXTURE)
    frame:SetColor(0.94, 0.82, 0.48, 0.96)

    local value = wm:CreateControl(nil, meter, CT_LABEL)
    value:SetAnchor(TOP, meter, TOP, 0, 38)
    value:SetDimensions(34, 13)
    value:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    value:SetFont("$(BOLD_FONT)|11|soft-shadow-thick")
    value:SetColor(1, 0.96, 0.82, 0.96)

    local label = wm:CreateControl(nil, meter, CT_LABEL)
    label:SetAnchor(TOP, meter, TOP, 0, 58)
    label:SetDimensions(54, 13)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetFont("$(MEDIUM_FONT)|10|soft-shadow-thin")
    label:SetColor(0.82, 0.78, 0.66, 0.92)
    label:SetText("REST")

    local bar = wm:CreateControl(nil, meter, CT_CONTROL)
    bar:SetAnchor(TOPLEFT, meter, TOPLEFT, 0, 0)
    bar:SetDimensions(BAR_METER_WIDTH, BAR_METER_HEIGHT)
    bar:SetHidden(true)

    local barRowBg = wm:CreateControl(nil, bar, CT_BACKDROP)
    barRowBg:SetAnchor(TOPLEFT, bar, TOPLEFT, 0, 0)
    barRowBg:SetDimensions(BAR_METER_WIDTH, BAR_METER_HEIGHT)
    barRowBg:SetCenterColor(0.015, 0.012, 0.010, 0.86)
    barRowBg:SetEdgeColor(0.42, 0.34, 0.20, 0.55)

    local barIcon = wm:CreateControl(nil, bar, CT_TEXTURE)
    barIcon:SetAnchor(TOPLEFT, bar, TOPLEFT, 5, 4)
    barIcon:SetDimensions(BAR_ICON_SIZE, BAR_ICON_SIZE)
    barIcon:SetTexture(iconTexture)
    barIcon:SetColor(0.95, 0.98, 0.96, 1)

    local barLabel = wm:CreateControl(nil, bar, CT_LABEL)
    barLabel:SetAnchor(TOPLEFT, bar, TOPLEFT, 25, 2)
    barLabel:SetDimensions(50, 13)
    barLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    barLabel:SetFont("$(MEDIUM_FONT)|10|soft-shadow-thin")
    barLabel:SetColor(0.82, 0.78, 0.66, 0.92)
    barLabel:SetText("REST")

    local barValue = wm:CreateControl(nil, bar, CT_LABEL)
    barValue:SetAnchor(TOPRIGHT, bar, TOPRIGHT, -4, 2)
    barValue:SetDimensions(24, 13)
    barValue:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    barValue:SetFont("$(BOLD_FONT)|11|soft-shadow-thick")
    barValue:SetColor(1, 0.96, 0.82, 0.96)

    local barBg = wm:CreateControl(nil, bar, CT_BACKDROP)
    barBg:SetAnchor(TOPLEFT, bar, TOPLEFT, 25, 15)
    barBg:SetDimensions(BAR_FILL_WIDTH, BAR_FILL_HEIGHT)
    barBg:SetCenterColor(0.01, 0.012, 0.012, 0.94)
    barBg:SetEdgeColor(0.20, 0.16, 0.10, 0.65)

    local barFill = wm:CreateControl(nil, barBg, CT_BACKDROP)
    barFill:SetAnchor(LEFT, barBg, LEFT, 0, 0)
    barFill:SetDimensions(1, BAR_FILL_HEIGHT)
    barFill:SetCenterColor(colorR, colorG, colorB, 0.90)
    barFill:SetEdgeColor(0, 0, 0, 0)
    barFill:SetAlpha(0.72)

    local barPulse = wm:CreateControl(nil, barBg, CT_TEXTURE)
    barPulse:SetAnchor(CENTER, barBg, CENTER, 0, 0)
    barPulse:SetDimensions(BAR_FILL_WIDTH + 6, BAR_FILL_HEIGHT + 8)
    barPulse:SetTexture("/esoui/art/quest/texthighlight.dds")
    barPulse:SetColor(colorR, colorG, colorB, 1)
    barPulse:SetAlpha(0)
    barPulse:SetBlendMode(TEX_BLEND_MODE_ADD)
    barPulse:SetHidden(true)

    return {
        control = meter,
        squareControls = { glow, bg, fill, shade, pulse, icon, frame, value, label },
        squareFill = fill,
        squareValue = value,
        squareLabel = label,
        squarePulse = pulse,
        squareShade = shade,
        barControl = bar,
        barFill = barFill,
        barValue = barValue,
        barLabel = barLabel,
        barPulse = barPulse
    }
end

local function AddPulseAnimations(pulse)
    local aIn = pulseTimeline:InsertAnimation(ANIMATION_ALPHA, pulse, 0)
    aIn:SetAlphaValues(0.05, 0.38)
    aIn:SetDuration(450)
    local aOut = pulseTimeline:InsertAnimation(ANIMATION_ALPHA, pulse, 450)
    aOut:SetAlphaValues(0.38, 0.05)
    aOut:SetDuration(450)
end

local function ResetPulseAlpha(meter)
    meter.squarePulse:SetAlpha(0)
    meter.barPulse:SetAlpha(0)
end

local function ApplyMeterLayout(meter, horizontalBars)
    meter.control:ClearAnchors()
    if horizontalBars then
        meter.control:SetAnchor(TOPLEFT, hudTLW, TOPLEFT, 5, 5)
        meter.control:SetDimensions(BAR_METER_WIDTH, BAR_METER_HEIGHT)
        SetControlsHidden(meter.squareControls, true)
        meter.barControl:SetHidden(false)
    else
        meter.control:SetAnchor(LEFT, hudTLW, LEFT, 2, 0)
        meter.control:SetDimensions(54, 74)
        SetControlsHidden(meter.squareControls, false)
        meter.barControl:SetHidden(true)
    end
end

local function ApplyHudLayout(horizontalBars)
    if currentHorizontalBars == horizontalBars then
        return
    end
    currentHorizontalBars = horizontalBars

    if horizontalBars then
        hudTLW:SetDimensions(BAR_HUD_WIDTH, BAR_HUD_HEIGHT)
        hudBg:ClearAnchors()
        hudBg:SetAnchor(TOPLEFT, hudTLW, TOPLEFT, 1, 4)
        hudBg:SetDimensions(114, 28)
    else
        hudTLW:SetDimensions(SQUARE_HUD_WIDTH, SQUARE_HUD_HEIGHT)
        hudBg:ClearAnchors()
        hudBg:SetAnchor(TOP, hudTLW, TOP, 0, 4)
        hudBg:SetDimensions(58, 54)
    end

    ApplyMeterLayout(fatigueMeter, horizontalBars)
    ApplyHudPosition()
end

local function UpdateMeter(meter, value, critical, showLabels, horizontalBars)
    local text = tostring(zo_round(value))
    if horizontalBars then
        local fillWidth = zo_max(1, zo_round(BAR_FILL_WIDTH * (value / 100)))
        meter.barFill:SetHidden(value <= 0)
        meter.barFill:SetDimensions(fillWidth, BAR_FILL_HEIGHT)
        meter.barValue:SetText(text)
        meter.barLabel:SetHidden(not showLabels)
        meter.barPulse:SetHidden(not critical)
        if critical then
            meter.barValue:SetColor(0.86, 0.64, 1, 1)
        else
            meter.barValue:SetColor(1, 0.96, 0.82, 0.96)
        end
        return
    end

    meter.squareFill:SetAlpha(0.07 + (value / 100) * 0.48)
    meter.squareShade:SetAlpha(0.18 + ((1 - (value / 100)) * 0.78))
    meter.squareValue:SetText(text)
    meter.squareLabel:SetHidden(not showLabels)
    meter.squarePulse:SetHidden(not critical)
    if critical then
        meter.squareValue:SetColor(0.86, 0.64, 1, 1)
    else
        meter.squareValue:SetColor(1, 0.96, 0.82, 0.96)
    end
end

local function EnsureHud()
    if hudTLW then
        return
    end

    local wm = WINDOW_MANAGER
    hudTLW = wm:CreateTopLevelWindow("HARDCORE_RoadWearinessHUD")
    hudTLW:SetDimensions(SQUARE_HUD_WIDTH, SQUARE_HUD_HEIGHT)
    hudTLW:SetDrawTier(DT_HIGH)
    hudTLW:SetDrawLayer(DL_OVERLAY)
    hudTLW:SetDrawLevel(9201)
    hudTLW:SetMouseEnabled(false)
    hudTLW:SetMovable(false)
    hudTLW:SetClampedToScreen(true)
    hudTLW:SetHidden(true)

    hudBg = wm:CreateControl(nil, hudTLW, CT_TEXTURE)
    hudBg:SetAnchor(TOP, hudTLW, TOP, 0, 4)
    hudBg:SetDimensions(58, 54)
    hudBg:SetTexture("/esoui/art/actionbar/backrow_abilityframe_overlay.dds")
    hudBg:SetColor(0.025, 0.020, 0.014, 0.46)
    hudBg:SetAlpha(0.42)

    fatigueMeter = CreateMeter(hudTLW, "HARDCORE_RoadWearinessFatigue", ICON_FATIGUE, 0.72, 0.60, 0.92)

    hudTLW:SetHandler("OnMoveStop", function()
        local sv = GetSV()
        sv.hud.x = zo_round(hudTLW:GetLeft())
        sv.hud.y = zo_round(hudTLW:GetTop())
        ApplyHudPosition()
    end)

    pulseTimeline = ANIMATION_MANAGER:CreateTimeline()
    AddPulseAnimations(fatigueMeter.squarePulse)
    AddPulseAnimations(fatigueMeter.barPulse)
    pulseTimeline:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY)

    ApplyHudPosition()
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
        hudTLW:SetHidden(not (Rule.active and IsOnHud()))
    end
end

local function CheckWarnings()
    local sv = GetSV()
    local fatigue = ClampMeter(sv.fatigue)
    if fatigue <= 0 and not sv.warnings.empty then
        sv.warnings.empty = true
        Alert("HARDCORE: You are exhausted.", SOUNDS.NEGATIVE_CLICK)
    elseif fatigue <= WARNING_CRITICAL and not sv.warnings.critical then
        sv.warnings.critical = true
        Alert("HARDCORE: Weariness is critical.", SOUNDS.DUEL_START)
    elseif fatigue <= WARNING_LOW and not sv.warnings.low then
        sv.warnings.low = true
        Alert("HARDCORE: Weariness is setting in.", SOUNDS.QUEST_ACCEPTED)
    end
end

local function UpdateHud()
    EnsureHud()
    local sv = GetSV()
    local fatigue = ClampMeter(sv.fatigue)
    local horizontalBars = sv.hud.displayStyle == HUD_STYLE_HORIZONTAL
    local critical = fatigue <= WARNING_CRITICAL

    ApplyHudLayout(horizontalBars)
    ApplyHudScale(sv.hud.scale)
    UpdateMeter(fatigueMeter, fatigue, critical, sv.hud.showLabels == true, horizontalBars)
    if critical then
        if pulseTimeline and not pulseTimeline:IsPlaying() then
            pulseTimeline:PlayFromStart()
        end
    elseif pulseTimeline and pulseTimeline:IsPlaying() then
        pulseTimeline:Stop()
        ResetPulseAlpha(fatigueMeter)
    end

    UpdateLockState()
    UpdateVisibility()
end

local function ChangeFatigue(delta)
    if not Rule.active or delta == 0 then
        return
    end
    local sv = GetSV()
    local old = ClampMeter(sv.fatigue)
    sv.fatigue = ClampMeter(old + delta)
    if sv.fatigue > WARNING_LOW then
        ResetWarningFlags()
    end
    CheckWarnings()
    UpdateHud()
end

local WEAPON_SLOTS = {
    EQUIP_SLOT_MAIN_HAND,
    EQUIP_SLOT_OFF_HAND,
    EQUIP_SLOT_BACKUP_MAIN,
    EQUIP_SLOT_BACKUP_OFF
}

local function EnforceWeaponFatigue()
    if not Rule.active or IsDead() or (IsUnitInCombat and IsUnitInCombat("player")) then
        return
    end
    local sv = GetSV()
    if ClampMeter(sv.fatigue) > sv.settings.weaponLockThreshold then
        sv.warnings.weapons = false
        return
    end

    local removedAny = false
    for _, equipSlot in ipairs(WEAPON_SLOTS) do
        local hasItem, _icon, _heldSlot, _heldNow, locked = GetWornItemInfo(BAG_WORN, equipSlot)
        if hasItem and not locked then
            RequestUnequipItem(BAG_WORN, equipSlot)
            removedAny = true
        end
    end
    if removedAny and not sv.warnings.weapons then
        sv.warnings.weapons = true
        Alert("HARDCORE: Too weary to keep weapons equipped. Rest first.", SOUNDS.NEGATIVE_CLICK)
    end
end

local function IsNpcLocked()
    local sv = GetSV()
    return Rule.active and IsHardcoreActive() and ClampMeter(sv.fatigue) <= sv.settings.npcLockThreshold
end

local function EndNpcInteraction()
    if EndInteraction then
        EndInteraction(INTERACTION_CONVERSATION)
        EndInteraction(INTERACTION_QUEST)
    end
    if SCENE_MANAGER then
        if SCENE_MANAGER:GetScene("interact") then
            SCENE_MANAGER:Hide("interact")
        end
        if SCENE_MANAGER:GetScene("gamepadInteract") then
            SCENE_MANAGER:Hide("gamepadInteract")
        end
    end
end

local function EnforceNpcFatigue(forceNpcInteraction)
    local sv = GetSV()
    if not IsNpcLocked() then
        sv.warnings.npcs = false
        return
    end

    local interactionType = GetInteractionType and GetInteractionType() or nil
    local isNpcInteraction = forceNpcInteraction or interactionType == INTERACTION_CONVERSATION or interactionType == INTERACTION_QUEST

    if isNpcInteraction then
        EndNpcInteraction()
        if not sv.warnings.npcs then
            sv.warnings.npcs = true
            Alert("HARDCORE: Too exhausted to speak with anyone. Rest first.", SOUNDS.NEGATIVE_CLICK)
        end
    end
end

local function AdvanceFatigue()
    if not Rule.active then
        return
    end

    local sv = GetSV()
    local now = GetFrameTimeMilliseconds()
    if sv.lastUpdateMs <= 0 then
        sv.lastUpdateMs = now
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

    if Rule._resting and ((IsPlayerMoving and IsPlayerMoving()) or (IsUnitInCombat and IsUnitInCombat("player"))) then
        StopResting()
    end

    local resting = Rule._resting or IsRestingInteraction()
    local delta = 0
    local settings = sv.settings
    if resting then
        delta = (elapsed / GetSecondsDurationMs(settings.restoreSeconds, DEFAULT_RESTORE_SECONDS)) * 100
    else
        delta = -((elapsed / GetMinutesDurationMs(settings.fatigueDrainMinutes, DEFAULT_FATIGUE_DRAIN_MINUTES)) * 100)
        if IsPlayerMoving and IsPlayerMoving() and GetUnitPower then
            local stamina, maxStamina = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_STAMINA)
            if Rule._lastStamina and stamina and maxStamina and maxStamina > 0 and stamina < Rule._lastStamina then
                delta = delta - (((Rule._lastStamina - stamina) / maxStamina) * settings.staminaDrainMultiplier)
            end
            Rule._lastStamina = stamina
        end
    end

    ChangeFatigue(delta)
    EnforceWeaponFatigue()
    EnforceNpcFatigue()
end

local function OnInventoryChange(_, bagId, slotIndex)
    if not Rule.active or bagId ~= BAG_WORN then
        return
    end
    for _, equipSlot in ipairs(WEAPON_SLOTS) do
        if slotIndex == equipSlot then
            zo_callLater(EnforceWeaponFatigue, 50)
            return
        end
    end
end

local function OnNpcInteraction()
    if Rule.active then
        zo_callLater(function() EnforceNpcFatigue(true) end, 1)
    end
end

local function RegisterUpdateLoops()
    EVENT_MANAGER:UnregisterForUpdate(NS .. "_TICK")
    if Rule.active then
        EVENT_MANAGER:RegisterForUpdate(NS .. "_TICK", TICK_MS, AdvanceFatigue)
    end
end

local function HookScenes()
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
end

local function Install()
    if Rule._installed then
        return
    end

    EnsureHud()
    HookScenes()

    if ZO_PreHook and PlayEmoteByIndex then
        ZO_PreHook("PlayEmoteByIndex", function(emoteIndex)
            if not Rule.active then
                return
            end
            local slashName = GetEmoteSlashNameByIndex and GetEmoteSlashNameByIndex(emoteIndex)
            if IsRestEmoteSlash(slashName) then
                StartResting(true)
            end
        end)
    end

    EVENT_MANAGER:RegisterForEvent(NS .. "_ACTION", EVENT_ACTION_SLOT_ABILITY_USED, function()
        if Rule.active and IsHardcoreActive() then
            StopResting()
            ChangeFatigue(-GetSV().settings.actionDrain)
        end
    end)
    EVENT_MANAGER:RegisterForEvent(NS .. "_COMBAT", EVENT_COMBAT_EVENT, function(_, result, isError, _abilityName, _abilityGraphic, _abilityActionSlotType, _sourceName, sourceType)
        if not Rule.active or isError or sourceType ~= COMBAT_UNIT_TYPE_PLAYER then
            return
        end
        if result == ACTION_RESULT_DAMAGE or result == ACTION_RESULT_CRITICAL_DAMAGE or result == ACTION_RESULT_BLOCKED_DAMAGE or result == ACTION_RESULT_DAMAGE_SHIELDED then
            local now = GetFrameTimeMilliseconds()
            if now - Rule._lastCombatDrainMs >= 650 then
                Rule._lastCombatDrainMs = now
                StopResting()
                ChangeFatigue(-GetSV().settings.combatDrain)
            end
        end
    end)
    EVENT_MANAGER:RegisterForEvent(NS .. "_INTERACTION_END", EVENT_INTERACTION_ENDED, function(_, interactType)
        if interactType == INTERACTION_FURNITURE then
            StopResting()
        end
    end)
    EVENT_MANAGER:RegisterForEvent(NS .. "_CHATTER_BEGIN", EVENT_CHATTER_BEGIN, OnNpcInteraction)
    EVENT_MANAGER:RegisterForEvent(NS .. "_CONVERSATION", EVENT_CONVERSATION_UPDATED, OnNpcInteraction)
    EVENT_MANAGER:RegisterForEvent(NS .. "_QUEST_OFFERED", EVENT_QUEST_OFFERED, OnNpcInteraction)
    EVENT_MANAGER:RegisterForEvent(NS .. "_QUEST_COMPLETE", EVENT_QUEST_COMPLETE_DIALOG, OnNpcInteraction)
    EVENT_MANAGER:RegisterForEvent(NS .. "_INV", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventoryChange)
    EVENT_MANAGER:AddFilterForEvent(NS .. "_INV", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
    EVENT_MANAGER:RegisterForEvent(NS .. "_ACTIVATED", EVENT_PLAYER_ACTIVATED, function()
        if not Rule.active then
            return
        end
        GetSV().lastUpdateMs = GetFrameTimeMilliseconds()
        Rule._lastStamina = nil
        UpdateHud()
    end)
    EVENT_MANAGER:RegisterForEvent(NS .. "_RESIZE", EVENT_SCREEN_RESIZED, ApplyHudPosition)

    Rule._installed = true
end

function Rule:OnEnable()
    self.active = true
    local sv = GetSV()
    sv.lastUpdateMs = GetFrameTimeMilliseconds()
    Install()
    RegisterUpdateLoops()
    UpdateHud()
end

function Rule:OnDisable()
    self.active = false
    EVENT_MANAGER:UnregisterForUpdate(NS .. "_TICK")
    StopResting()
    if pulseTimeline and pulseTimeline:IsPlaying() then
        pulseTimeline:Stop()
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

function Rule:ResetMeter()
    local sv = GetSV()
    sv.fatigue = 100
    sv.lastUpdateMs = GetFrameTimeMilliseconds()
    sv.warnings = {}
    UpdateHud()
end

function Rule:ResetHudPosition()
    local sv = GetSV()
    sv.hud.x = DEFAULT_HUD_X
    sv.hud.y = DEFAULT_HUD_Y
    ApplyHudPosition()
    UpdateHud()
end

function HARDCORE.GetRoadWearinessSV()
    return GetSV()
end

function HARDCORE.RefreshRoadWearinessOptions()
    Rule:RefreshOptions()
end

function HARDCORE.ResetRoadWearinessMeter()
    Rule:ResetMeter()
end

function HARDCORE.ResetRoadWearinessHudPosition()
    Rule:ResetHudPosition()
end

function HARDCORE.DebugRoadWearinessStatus()
    local sv = GetSV()
    d("Road Weariness active=" .. tostring(Rule.active) ..
        " fatigue=" .. tostring(zo_round(ClampMeter(sv.fatigue))) ..
        " resting=" .. tostring(Rule._resting) ..
        " hud=(" .. tostring(sv.hud.x) .. "," .. tostring(sv.hud.y) .. ")" ..
        " unlocked=" .. tostring(sv.hud.unlocked))
end

function HARDCORE.DebugRoadWearinessCommand(action, arg1)
    action = action or "help"
    local sv = GetSV()

    if action == "help" then
        d("Road Weariness debug:")
        d("/hc debug weariness full")
        d("/hc debug weariness empty")
        d("/hc debug weariness set <fatigue>")
        d("/hc debug weariness rest")
        d("/hc debug weariness stop")
        d("/hc debug weariness hud")
        return
    end

    if action == "full" then
        Rule:ResetMeter()
        d("Road Weariness: fatigue set to full.")
        return
    end

    if action == "empty" then
        sv.fatigue = 0
        sv.lastUpdateMs = GetFrameTimeMilliseconds()
        CheckWarnings()
        EnforceWeaponFatigue()
        EnforceNpcFatigue()
        UpdateHud()
        d("Road Weariness: fatigue emptied.")
        return
    end

    if action == "set" then
        local fatigue = tonumber(arg1)
        if not fatigue then
            d("Usage: /hc debug weariness set <fatigue>")
            return
        end
        sv.fatigue = ClampMeter(fatigue)
        sv.lastUpdateMs = GetFrameTimeMilliseconds()
        CheckWarnings()
        EnforceWeaponFatigue()
        EnforceNpcFatigue()
        UpdateHud()
        d("Road Weariness: fatigue=" .. tostring(zo_round(sv.fatigue)))
        return
    end

    if action == "rest" then
        StartResting(true)
        d("Road Weariness: forced rest started.")
        return
    end

    if action == "stop" then
        StopResting()
        d("Road Weariness: forced rest stopped.")
        return
    end

    if action == "hud" then
        EnsureHud()
        UpdateHud()
        if hudTLW then
            hudTLW:SetHidden(false)
        end
        d("Road Weariness: HUD forced visible until the next scene/update refresh.")
        return
    end

    d("Unknown Road Weariness debug action: " .. tostring(action))
end

HARDCORE.RuleManager:RegisterRule(Rule)
