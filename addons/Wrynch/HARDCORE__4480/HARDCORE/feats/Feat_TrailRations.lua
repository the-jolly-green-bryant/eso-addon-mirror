local HARDCORE = HARDCORE

local ID = "TrailRations"
local NS = "HARDCORE_TrailRations"

local DEFAULT_HUNGER_DRAIN_MINUTES = 90
local DEFAULT_THIRST_DRAIN_MINUTES = 45
local DEFAULT_EMOTE_REFILL_AMOUNT = 20
local DEFAULT_EMOTE_START_DELAY_MS = 0
local TICK_MS = 5000
local EMOTE_REFILL_TICK_MS = 250
local EAT_ANIMATION_MS = 3000
local DRINK_ANIMATION_MS = 2500
local EAT_IDLE_MS = 6500
local DRINK_IDLE_MS = 15000
local WARNING_LOW = 35
local WARNING_CRITICAL = 15
local MAX_DARKEN_ALPHA = 0.82
local VIGNETTE_START = 65

local ICON_FOOD = "/esoui/art/tradinghouse/gamepad/gp_tradinghouse_materials_provisioning_food.dds"
local ICON_DRINK = "/esoui/art/tradinghouse/gamepad/gp_tradinghouse_materials_provisioning_drink.dds"
local EDGE_TEXTURE = "/esoui/art/miscellaneous/centerscreen_announceEdge.dds"
local METER_FRAME_TEXTURE = "/esoui/art/actionbar/abilityframe64_up.dds"
local METER_GLOW_TEXTURE = "/esoui/art/actionbar/abilityframe64_glow.dds"
local OLD_DEFAULT_HUD_X = 360
local OLD_DEFAULT_HUD_Y = 710
local DEFAULT_HUD_X = 720
local DEFAULT_HUD_Y = 710
local SQUARE_HUD_WIDTH = 116
local SQUARE_HUD_HEIGHT = 76
local BAR_HUD_WIDTH = 116
local BAR_HUD_HEIGHT = 60
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
    title = "Trail Rations: hunger and thirst survival meters",
    icon = ICON_FOOD,
    defaultEnabled = false
}

Rule.active = false
Rule._installed = false
Rule._lastConsumedType = nil
Rule._lastConsumedMs = 0
Rule._slotTypeCache = {}
Rule._emoteHookTargets = {}
Rule._emoteRefill = nil

local function GetSV()
    HARDCORE = HARDCORE or {}
    if not HARDCORE.trailRationsSaved then
        HARDCORE.trailRationsSaved = ZO_SavedVars:NewCharacterIdSettings("HARDCORE_TRAIL_RATIONS_SV", 1, nil, {
            hunger = 100,
            thirst = 100,
            lastUpdateMs = 0,
            hud = {
                x = DEFAULT_HUD_X,
                y = DEFAULT_HUD_Y,
                unlocked = false,
                showLabels = true,
                vignette = true,
                displayStyle = HUD_STYLE_SQUARE,
                scale = DEFAULT_HUD_SCALE
            },
            settings = {
                hungerDrainMinutes = DEFAULT_HUNGER_DRAIN_MINUTES,
                thirstDrainMinutes = DEFAULT_THIRST_DRAIN_MINUTES,
                useEmotes = false,
                eatRefillAmount = DEFAULT_EMOTE_REFILL_AMOUNT,
                drinkRefillAmount = DEFAULT_EMOTE_REFILL_AMOUNT,
                eatStartDelayMs = DEFAULT_EMOTE_START_DELAY_MS,
                drinkStartDelayMs = DEFAULT_EMOTE_START_DELAY_MS
            },
            warnings = {
                hungerLow = false,
                hungerCritical = false,
                hungerEmpty = false,
                thirstLow = false,
                thirstCritical = false,
                thirstEmpty = false
            }
        }, GetWorldName())
    end

    local sv = HARDCORE.trailRationsSaved
    sv.hunger = tonumber(sv.hunger) or 100
    sv.thirst = tonumber(sv.thirst) or 100
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
    sv.hud.vignette = true
    sv.settings = sv.settings or {}
    sv.settings.hungerDrainMinutes = zo_clamp(tonumber(sv.settings.hungerDrainMinutes) or DEFAULT_HUNGER_DRAIN_MINUTES, 5, 240)
    sv.settings.thirstDrainMinutes = zo_clamp(tonumber(sv.settings.thirstDrainMinutes) or DEFAULT_THIRST_DRAIN_MINUTES, 5, 240)
    sv.settings.useEmotes = sv.settings.useEmotes == true
    sv.settings.eatRefillAmount = zo_clamp(tonumber(sv.settings.eatRefillAmount) or DEFAULT_EMOTE_REFILL_AMOUNT, 1, 100)
    sv.settings.drinkRefillAmount = zo_clamp(tonumber(sv.settings.drinkRefillAmount) or DEFAULT_EMOTE_REFILL_AMOUNT, 1, 100)
    sv.settings.eatStartDelayMs = zo_clamp(tonumber(sv.settings.eatStartDelayMs) or DEFAULT_EMOTE_START_DELAY_MS, 0, 5000)
    sv.settings.drinkStartDelayMs = zo_clamp(tonumber(sv.settings.drinkStartDelayMs) or DEFAULT_EMOTE_START_DELAY_MS, 0, 5000)
    sv.warnings = sv.warnings or {}
    return sv
end

local function GetDrainDurationMs(settingName, fallbackMinutes)
    local sv = GetSV()
    local minutes = tonumber(sv.settings and sv.settings[settingName]) or fallbackMinutes
    return zo_max(1, minutes) * 60 * 1000
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

local function ResetWarningFlagsForMeter(sv, meter)
    sv.warnings[meter .. "Low"] = false
    sv.warnings[meter .. "Critical"] = false
    sv.warnings[meter .. "Empty"] = false
end

local function Alert(text, sound)
    HARDCORE.ShowAlertNoSuppression(UI_ALERT_CATEGORY_ALERT, sound or SOUNDS.NEGATIVE_CLICK, text)
end

local function CheckWarnings()
    local sv = GetSV()

    local function CheckMeter(key, label)
        local value = ClampMeter(sv[key])
        if value <= 0 and not sv.warnings[key .. "Empty"] then
            sv.warnings[key .. "Empty"] = true
            Alert("HARDCORE: " .. label .. " is spent.", SOUNDS.NEGATIVE_CLICK)
        elseif value <= WARNING_CRITICAL and not sv.warnings[key .. "Critical"] then
            sv.warnings[key .. "Critical"] = true
            Alert("HARDCORE: " .. label .. " is critical.", SOUNDS.DUEL_START)
        elseif value <= WARNING_LOW and not sv.warnings[key .. "Low"] then
            sv.warnings[key .. "Low"] = true
            Alert("HARDCORE: " .. label .. " is running low.", SOUNDS.QUEST_ACCEPTED)
        end
    end

    CheckMeter("hunger", "Hunger")
    CheckMeter("thirst", "Thirst")
end

local hudTLW
local hudBg
local hungerMeter
local thirstMeter
local currentHorizontalBars
local currentHudScale
local pulseTimeline

local overlayTLW
local darkMask
local edgeVignette

local function EnsureOverlay()
    if overlayTLW then
        return
    end

    local wm = WINDOW_MANAGER
    overlayTLW = wm:CreateTopLevelWindow("HARDCORE_TrailRationsOverlay")
    overlayTLW:SetAnchorFill(GuiRoot)
    overlayTLW:SetDrawTier(DT_HIGH)
    overlayTLW:SetDrawLayer(DL_OVERLAY)
    overlayTLW:SetDrawLevel(9998)
    overlayTLW:SetClampedToScreen(true)
    overlayTLW:SetMouseEnabled(false)
    overlayTLW:SetHidden(true)

    darkMask = wm:CreateControl(nil, overlayTLW, CT_BACKDROP)
    darkMask:SetAnchorFill()
    darkMask:SetCenterColor(0, 0, 0, 1)
    darkMask:SetEdgeColor(0, 0, 0, 0)
    darkMask:SetAlpha(0)

    edgeVignette = wm:CreateControl(nil, overlayTLW, CT_TEXTURE)
    edgeVignette:SetAnchorFill()
    edgeVignette:SetTexture(EDGE_TEXTURE)
    edgeVignette:SetBlendMode(TEX_BLEND_MODE_ALPHA)
    edgeVignette:SetAlpha(0)
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

local function CreateMeter(parent, name, iconTexture, colorR, colorG, colorB, x)
    local wm = WINDOW_MANAGER
    local meter = wm:CreateControl(name, parent, CT_CONTROL)
    meter:SetAnchor(LEFT, parent, LEFT, x, 0)
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

local function ApplyMeterLayout(meter, horizontalBars, squareX, barY)
    meter.control:ClearAnchors()
    if horizontalBars then
        meter.control:SetAnchor(TOPLEFT, hudTLW, TOPLEFT, 5, barY)
        meter.control:SetDimensions(BAR_METER_WIDTH, BAR_METER_HEIGHT)
        SetControlsHidden(meter.squareControls, true)
        meter.barControl:SetHidden(false)
    else
        meter.control:SetAnchor(LEFT, hudTLW, LEFT, squareX, 0)
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
        hudBg:SetDimensions(114, 52)
        ApplyMeterLayout(thirstMeter, true, 2, 4)
        ApplyMeterLayout(hungerMeter, true, 60, 30)
    else
        hudTLW:SetDimensions(SQUARE_HUD_WIDTH, SQUARE_HUD_HEIGHT)
        hudBg:ClearAnchors()
        hudBg:SetAnchor(TOP, hudTLW, TOP, 0, 4)
        hudBg:SetDimensions(114, 54)
        ApplyMeterLayout(thirstMeter, false, 2, 4)
        ApplyMeterLayout(hungerMeter, false, 60, 26)
    end

    ApplyHudPosition()
end

local function UpdateMeter(meter, value, critical, criticalR, criticalG, criticalB, showLabels, horizontalBars)
    local text = tostring(zo_round(value))
    if horizontalBars then
        local fillWidth = zo_max(1, zo_round(BAR_FILL_WIDTH * (value / 100)))
        meter.barFill:SetHidden(value <= 0)
        meter.barFill:SetDimensions(fillWidth, BAR_FILL_HEIGHT)
        meter.barValue:SetText(text)
        meter.barLabel:SetHidden(not showLabels)
        meter.barPulse:SetHidden(not critical)
        if critical then
            meter.barValue:SetColor(criticalR, criticalG, criticalB, 1)
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
        meter.squareValue:SetColor(criticalR, criticalG, criticalB, 1)
    else
        meter.squareValue:SetColor(1, 0.96, 0.82, 0.96)
    end
end

local function EnsureHud()
    if hudTLW then
        return
    end

    local wm = WINDOW_MANAGER
    hudTLW = wm:CreateTopLevelWindow("HARDCORE_TrailRationsHUD")
    hudTLW:SetDimensions(SQUARE_HUD_WIDTH, SQUARE_HUD_HEIGHT)
    hudTLW:SetDrawTier(DT_HIGH)
    hudTLW:SetDrawLayer(DL_OVERLAY)
    hudTLW:SetDrawLevel(9200)
    hudTLW:SetMouseEnabled(false)
    hudTLW:SetMovable(false)
    hudTLW:SetClampedToScreen(true)
    hudTLW:SetHidden(true)

    hudBg = wm:CreateControl(nil, hudTLW, CT_TEXTURE)
    hudBg:SetAnchor(TOP, hudTLW, TOP, 0, 4)
    hudBg:SetDimensions(114, 54)
    hudBg:SetTexture("/esoui/art/actionbar/backrow_abilityframe_overlay.dds")
    hudBg:SetColor(0.025, 0.020, 0.014, 0.46)
    hudBg:SetAlpha(0.42)

    thirstMeter = CreateMeter(hudTLW, "HARDCORE_TrailRationsThirst", ICON_DRINK, 0.08, 0.72, 1.0, 2)
    hungerMeter = CreateMeter(hudTLW, "HARDCORE_TrailRationsHunger", ICON_FOOD, 0.95, 0.68, 0.18, 60)
    thirstMeter.squareLabel:SetText("WATER")
    thirstMeter.barLabel:SetText("WATER")
    hungerMeter.squareLabel:SetText("FOOD")
    hungerMeter.barLabel:SetText("FOOD")

    hudTLW:SetHandler("OnMoveStop", function()
        local sv = GetSV()
        sv.hud.x = zo_round(hudTLW:GetLeft())
        sv.hud.y = zo_round(hudTLW:GetTop())
        ApplyHudPosition()
    end)

    pulseTimeline = ANIMATION_MANAGER:CreateTimeline()
    AddPulseAnimations(thirstMeter.squarePulse)
    AddPulseAnimations(thirstMeter.barPulse)
    AddPulseAnimations(hungerMeter.squarePulse)
    AddPulseAnimations(hungerMeter.barPulse)
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
    local show = Rule.active and IsOnHud()
    if hudTLW then
        hudTLW:SetHidden(not show)
    end
    if overlayTLW then
        overlayTLW:SetHidden(not show)
    end
end

local function UpdateOverlay()
    EnsureOverlay()
    local sv = GetSV()
    if not (Rule.active and IsOnHud()) then
        overlayTLW:SetHidden(true)
        darkMask:SetAlpha(0)
        edgeVignette:SetAlpha(0)
        return
    end

    local hunger = ClampMeter(sv.hunger)
    local thirst = ClampMeter(sv.thirst)
    local lowest = math.min(hunger, thirst)
    local t = zo_clamp((VIGNETTE_START - lowest) / VIGNETTE_START, 0, 1)
    local alpha = math.pow(t, 1.05) * MAX_DARKEN_ALPHA

    overlayTLW:SetHidden(alpha <= 0.001)
    darkMask:SetAlpha(alpha * 0.86)
    edgeVignette:SetAlpha(alpha * 0.92)
    if thirst <= hunger then
        edgeVignette:SetColor(0.55, 0.82, 1.0, 1)
    else
        edgeVignette:SetColor(0.90, 0.55, 0.24, 1)
    end
end

local function UpdateHud()
    EnsureHud()
    local sv = GetSV()
    local hunger = ClampMeter(sv.hunger)
    local thirst = ClampMeter(sv.thirst)
    local horizontalBars = sv.hud.displayStyle == HUD_STYLE_HORIZONTAL

    ApplyHudLayout(horizontalBars)
    ApplyHudScale(sv.hud.scale)

    local showLabels = sv.hud.showLabels == true
    local hungerCritical = hunger <= WARNING_CRITICAL
    local thirstCritical = thirst <= WARNING_CRITICAL
    UpdateMeter(hungerMeter, hunger, hungerCritical, 1, 0.48, 0.28, showLabels, horizontalBars)
    UpdateMeter(thirstMeter, thirst, thirstCritical, 0.62, 0.92, 1, showLabels, horizontalBars)

    if hungerCritical or thirstCritical then
        if pulseTimeline and not pulseTimeline:IsPlaying() then
            pulseTimeline:PlayFromStart()
        end
    elseif pulseTimeline and pulseTimeline:IsPlaying() then
        pulseTimeline:Stop()
        ResetPulseAlpha(hungerMeter)
        ResetPulseAlpha(thirstMeter)
    end

    UpdateLockState()
    UpdateVisibility()
    UpdateOverlay()
end

local function AddMeterValue(meter, amount)
    if not Rule.active then
        return false
    end

    local sv = GetSV()
    local current = ClampMeter(sv[meter])
    if current >= 100 then
        return false
    end

    sv[meter] = ClampMeter(current + (tonumber(amount) or 0))
    if sv[meter] > current then
        ResetWarningFlagsForMeter(sv, meter)
        sv.lastUpdateMs = GetFrameTimeMilliseconds()
        UpdateHud()
        return true
    end

    return false
end

local function RefillFromConsumable(itemType)
    if GetSV().settings.useEmotes then
        return
    end

    local meter
    local label
    if itemType == ITEMTYPE_FOOD then
        meter = "hunger"
        label = "Hunger"
    elseif itemType == ITEMTYPE_DRINK then
        meter = "thirst"
        label = "Thirst"
    else
        return
    end

    local sv = GetSV()
    sv[meter] = 100
    ResetWarningFlagsForMeter(sv, meter)
    sv.lastUpdateMs = GetFrameTimeMilliseconds()
    UpdateHud()
    Alert("HARDCORE: " .. label .. " restored.", SOUNDS.INVENTORY_ITEM_APPLY_CHARGE)
end

local function StopEmoteRefill()
    Rule._emoteRefill = nil
    EVENT_MANAGER:UnregisterForUpdate(NS .. "_EMOTE_REFILL")
end

local function GetActiveElapsedMs(startElapsedMs, endElapsedMs, startDelayMs, activeMs, repeatMs)
    startElapsedMs = zo_max(0, startElapsedMs - startDelayMs)
    endElapsedMs = endElapsedMs - startDelayMs
    if endElapsedMs <= startElapsedMs then
        return 0
    end

    local total = 0
    local windowStart = math.floor(startElapsedMs / repeatMs) * repeatMs
    while windowStart < endElapsedMs do
        local startOverlap = zo_max(startElapsedMs, windowStart)
        local endOverlap = zo_min(endElapsedMs, windowStart + activeMs)
        if endOverlap > startOverlap then
            total = total + (endOverlap - startOverlap)
        end
        windowStart = windowStart + repeatMs
    end
    return total
end

local function UpdateEmoteRefill()
    local session = Rule._emoteRefill
    if not (session and Rule.active and HARDCORE and HARDCORE.saved and HARDCORE.saved.isActive) then
        StopEmoteRefill()
        return
    end

    local sv = GetSV()
    if not sv.settings.useEmotes or IsDead() or (IsPlayerMoving and IsPlayerMoving()) then
        StopEmoteRefill()
        return
    end

    local now = GetFrameTimeMilliseconds()
    local activeElapsedMs = GetActiveElapsedMs(session.lastElapsedMs, now - session.startedMs, session.startDelayMs,
        session.activeMs, session.repeatMs)
    session.lastElapsedMs = now - session.startedMs
    if activeElapsedMs <= 0 then
        return
    end

    AddMeterValue(session.meter, (session.amount * activeElapsedMs) / session.activeMs)
end

local function StartEmoteRefill(meter)
    if not (Rule.active and HARDCORE and HARDCORE.saved and HARDCORE.saved.isActive) then
        return
    end

    local sv = GetSV()
    if not sv.settings.useEmotes then
        return
    end

    local amount
    local repeatMs
    local startDelayMs
    local activeMs
    if meter == "hunger" then
        amount = sv.settings.eatRefillAmount
        startDelayMs = sv.settings.eatStartDelayMs
        activeMs = EAT_ANIMATION_MS
        repeatMs = EAT_ANIMATION_MS + EAT_IDLE_MS
    elseif meter == "thirst" then
        amount = sv.settings.drinkRefillAmount
        startDelayMs = sv.settings.drinkStartDelayMs
        activeMs = DRINK_ANIMATION_MS
        repeatMs = DRINK_ANIMATION_MS + DRINK_IDLE_MS
    else
        return
    end

    Rule._emoteRefill = {
        meter = meter,
        amount = amount,
        startDelayMs = startDelayMs,
        activeMs = activeMs,
        repeatMs = repeatMs,
        startedMs = GetFrameTimeMilliseconds(),
        lastElapsedMs = 0
    }

    EVENT_MANAGER:UnregisterForUpdate(NS .. "_EMOTE_REFILL")
    EVENT_MANAGER:RegisterForUpdate(NS .. "_EMOTE_REFILL", EMOTE_REFILL_TICK_MS, UpdateEmoteRefill)
end

local function CaptureItemTypeFromBag(bagId, slotIndex)
    if not (bagId and slotIndex and GetItemType) then
        return
    end
    local itemType = GetItemType(bagId, slotIndex)
    if itemType == ITEMTYPE_FOOD or itemType == ITEMTYPE_DRINK then
        Rule._lastConsumedType = itemType
        Rule._lastConsumedMs = GetFrameTimeMilliseconds()
    end
end

local function CacheItemTypeFromBag(bagId, slotIndex)
    if not (bagId and slotIndex and GetItemType) then
        return nil
    end

    local itemType = GetItemType(bagId, slotIndex)
    Rule._slotTypeCache[bagId] = Rule._slotTypeCache[bagId] or {}
    if itemType == ITEMTYPE_FOOD or itemType == ITEMTYPE_DRINK then
        Rule._slotTypeCache[bagId][slotIndex] = itemType
        return itemType
    end
    return nil
end

local function GetCachedItemType(bagId, slotIndex)
    local bagCache = Rule._slotTypeCache[bagId]
    return bagCache and bagCache[slotIndex]
end

local function RefreshInventoryCache()
    if not GetBagSize then
        return
    end

    Rule._slotTypeCache[BAG_BACKPACK] = {}
    local numSlots = GetBagSize(BAG_BACKPACK) or 0
    for slotIndex = 0, numSlots - 1 do
        CacheItemTypeFromBag(BAG_BACKPACK, slotIndex)
    end
end

local function HandleInventorySlotUpdate(_, bagId, slotIndex, _isNewItem, _itemSoundCategory, _inventoryUpdateReason, stackCountChange)
    if not Rule.active then
        return
    end

    local itemType = GetCachedItemType(bagId, slotIndex) or CacheItemTypeFromBag(bagId, slotIndex)
    if stackCountChange and stackCountChange < 0 and (itemType == ITEMTYPE_FOOD or itemType == ITEMTYPE_DRINK) then
        RefillFromConsumable(itemType)
    end
end

local function TryRefillFromCapturedUse()
    if not Rule.active then
        return
    end
    if Rule._lastConsumedType and GetFrameTimeMilliseconds() - Rule._lastConsumedMs <= 2000 then
        RefillFromConsumable(Rule._lastConsumedType)
        Rule._lastConsumedType = nil
        Rule._lastConsumedMs = 0
    end
end

local function TryRefillFromCapturedUseLater()
    zo_callLater(TryRefillFromCapturedUse, 250)
    zo_callLater(TryRefillFromCapturedUse, 1000)
end

local function InstallEmoteCommandHook(command, meter)
    local commandFunc = SLASH_COMMANDS and SLASH_COMMANDS[command]
    if not commandFunc or Rule._emoteHookTargets[command] == commandFunc then
        return
    end

    ZO_PreHook(SLASH_COMMANDS, command, function()
        StartEmoteRefill(meter)
        return false
    end)
    Rule._emoteHookTargets[command] = SLASH_COMMANDS[command]
end

local function InstallEmoteCommandHooks()
    if not ZO_PreHook then
        return
    end

    InstallEmoteCommandHook("/eat", "hunger")
    InstallEmoteCommandHook("/drink", "thirst")
end

local function AdvanceMeters()
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

    if not (HARDCORE and HARDCORE.saved and HARDCORE.saved.isActive) or IsDead() then
        UpdateHud()
        return
    end

    sv.hunger = ClampMeter(sv.hunger -
        ((elapsed / GetDrainDurationMs("hungerDrainMinutes", DEFAULT_HUNGER_DRAIN_MINUTES)) * 100))
    sv.thirst = ClampMeter(sv.thirst -
        ((elapsed / GetDrainDurationMs("thirstDrainMinutes", DEFAULT_THIRST_DRAIN_MINUTES)) * 100))

    CheckWarnings()
    UpdateHud()
end

local function RegisterUpdateLoop()
    EVENT_MANAGER:UnregisterForUpdate(NS .. "_TICK")
    if Rule.active then
        EVENT_MANAGER:RegisterForUpdate(NS .. "_TICK", TICK_MS, AdvanceMeters)
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
    EnsureOverlay()
    HookScenes()
    InstallEmoteCommandHooks()

    if PLAYER_EMOTE_MANAGER and PLAYER_EMOTE_MANAGER.RegisterCallback and not Rule._emoteCallbackRegistered then
        PLAYER_EMOTE_MANAGER:RegisterCallback("EmoteSlashCommandsUpdated", InstallEmoteCommandHooks)
        Rule._emoteCallbackRegistered = true
    end

    if ZO_PreHook then
        ZO_PreHook("ZO_InventorySlot_InitiateConfirmUseItem", function(inventorySlot)
            if inventorySlot then
                CaptureItemTypeFromBag(inventorySlot.bagId or inventorySlot.bag, inventorySlot.slotIndex or inventorySlot.index)
                TryRefillFromCapturedUseLater()
            end
        end)
    end
    EVENT_MANAGER:RegisterForEvent(NS .. "_INV", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, HandleInventorySlotUpdate)
    EVENT_MANAGER:AddFilterForEvent(NS .. "_INV", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
    EVENT_MANAGER:RegisterForEvent(NS .. "_EFFECT", EVENT_EFFECT_CHANGED, function(_, changeType, _effectSlot, _effectName, unitTag)
        if not Rule.active then
            return
        end
        if unitTag == "player" and (changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED or changeType == EFFECT_RESULT_FULL_REFRESH) then
            TryRefillFromCapturedUse()
            UpdateHud()
        end
    end)
    EVENT_MANAGER:AddFilterForEvent(NS .. "_EFFECT", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
    EVENT_MANAGER:RegisterForEvent(NS .. "_EFFECTS_FULL", EVENT_EFFECTS_FULL_UPDATE, function()
        if not Rule.active then
            return
        end
        TryRefillFromCapturedUse()
        UpdateHud()
    end)
    EVENT_MANAGER:RegisterForEvent(NS .. "_ACTIVATED", EVENT_PLAYER_ACTIVATED, function()
        if not Rule.active then
            return
        end
        StopEmoteRefill()
        GetSV().lastUpdateMs = GetFrameTimeMilliseconds()
        UpdateHud()
    end)
    EVENT_MANAGER:RegisterForEvent(NS .. "_RESIZE", EVENT_SCREEN_RESIZED, function()
        if overlayTLW then
            overlayTLW:ClearAnchors()
            overlayTLW:SetAnchorFill(GuiRoot)
        end
        ApplyHudPosition()
    end)
    EVENT_MANAGER:RegisterForEvent(NS .. "_EMOTE_FAILED", EVENT_PLAYER_EMOTE_FAILED_PLAY, StopEmoteRefill)
    EVENT_MANAGER:RegisterForEvent(NS .. "_COMBAT", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        if inCombat then
            StopEmoteRefill()
        end
    end)
    EVENT_MANAGER:RegisterForEvent(NS .. "_MOUNTED", EVENT_MOUNTED_STATE_CHANGED, function(_, mounted)
        if mounted then
            StopEmoteRefill()
        end
    end)
    EVENT_MANAGER:RegisterForEvent(NS .. "_ACTION", EVENT_ACTION_SLOT_ABILITY_USED, StopEmoteRefill)

    Rule._installed = true
end

function Rule:OnEnable()
    self.active = true
    local sv = GetSV()
    sv.lastUpdateMs = GetFrameTimeMilliseconds()
    Install()
    RefreshInventoryCache()
    RegisterUpdateLoop()
    UpdateHud()
end

function Rule:OnDisable()
    self.active = false
    EVENT_MANAGER:UnregisterForUpdate(NS .. "_TICK")
    StopEmoteRefill()

    if pulseTimeline and pulseTimeline:IsPlaying() then
        pulseTimeline:Stop()
    end
    if hudTLW then
        hudTLW:SetHidden(true)
        hudTLW:SetMouseEnabled(false)
        hudTLW:SetMovable(false)
    end
    if overlayTLW then
        overlayTLW:SetHidden(true)
    end
    if darkMask then
        darkMask:SetAlpha(0)
    end
    if edgeVignette then
        edgeVignette:SetAlpha(0)
    end
end

function Rule:RefreshOptions()
    if not GetSV().settings.useEmotes then
        StopEmoteRefill()
    end
    UpdateHud()
end

function Rule:ResetMeters()
    local sv = GetSV()
    sv.hunger = 100
    sv.thirst = 100
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

function HARDCORE.GetTrailRationsSV()
    return GetSV()
end

function HARDCORE.RefreshTrailRationsOptions()
    if Rule.RefreshOptions then
        Rule:RefreshOptions()
    end
end

function HARDCORE.ResetTrailRationsMeters()
    Rule:ResetMeters()
end

function HARDCORE.ResetTrailRationsHudPosition()
    Rule:ResetHudPosition()
end

function HARDCORE.DebugTrailRationsStatus()
    local sv = GetSV()
    d("Trail Rations active=" .. tostring(Rule.active) ..
        " hunger=" .. tostring(zo_round(ClampMeter(sv.hunger))) ..
        " thirst=" .. tostring(zo_round(ClampMeter(sv.thirst))) ..
        " hud=(" .. tostring(sv.hud.x) .. "," .. tostring(sv.hud.y) .. ")" ..
        " unlocked=" .. tostring(sv.hud.unlocked))
end

function HARDCORE.DebugTrailRationsCommand(action, arg1, arg2)
    action = action or "help"
    local sv = GetSV()

    if action == "help" then
        d("Trail Rations debug:")
        d("/hc debug rations full")
        d("/hc debug rations empty")
        d("/hc debug rations set <hunger> <thirst>")
        d("/hc debug rations decay <minutes>")
        d("/hc debug rations hud")
        return
    end

    if action == "full" then
        Rule:ResetMeters()
        d("Trail Rations: meters set to full.")
        return
    end

    if action == "empty" then
        sv.hunger = 0
        sv.thirst = 0
        sv.lastUpdateMs = GetFrameTimeMilliseconds()
        CheckWarnings()
        UpdateHud()
        d("Trail Rations: meters emptied.")
        return
    end

    if action == "set" then
        local hunger = tonumber(arg1)
        local thirst = tonumber(arg2)
        if not hunger or not thirst then
            d("Usage: /hc debug rations set <hunger> <thirst>")
            return
        end
        sv.hunger = ClampMeter(hunger)
        sv.thirst = ClampMeter(thirst)
        sv.lastUpdateMs = GetFrameTimeMilliseconds()
        CheckWarnings()
        UpdateHud()
        d("Trail Rations: hunger=" .. tostring(zo_round(sv.hunger)) .. " thirst=" .. tostring(zo_round(sv.thirst)))
        return
    end

    if action == "decay" then
        local minutes = tonumber(arg1)
        if not minutes then
            d("Usage: /hc debug rations decay <minutes>")
            return
        end
        sv.hunger = ClampMeter(sv.hunger -
            ((minutes * 60 * 1000 / GetDrainDurationMs("hungerDrainMinutes", DEFAULT_HUNGER_DRAIN_MINUTES)) * 100))
        sv.thirst = ClampMeter(sv.thirst -
            ((minutes * 60 * 1000 / GetDrainDurationMs("thirstDrainMinutes", DEFAULT_THIRST_DRAIN_MINUTES)) * 100))
        sv.lastUpdateMs = GetFrameTimeMilliseconds()
        CheckWarnings()
        UpdateHud()
        d("Trail Rations: decayed by " .. tostring(minutes) .. " minutes.")
        HARDCORE.DebugTrailRationsStatus()
        return
    end

    if action == "hud" then
        EnsureHud()
        UpdateHud()
        if hudTLW then
            hudTLW:SetHidden(false)
        end
        d("Trail Rations: HUD forced visible until the next scene/update refresh.")
        return
    end

    d("Unknown Trail Rations debug action: " .. tostring(action))
end

HARDCORE.RuleManager:RegisterRule(Rule)
