local HARDCORE = HARDCORE

local ID = "TrailRations"
local NS = "HARDCORE_TrailRations"

local HUNGER_DRAIN_MS = 90 * 60 * 1000
local THIRST_DRAIN_MS = 45 * 60 * 1000
local TICK_MS = 5000
local WARNING_LOW = 35
local WARNING_CRITICAL = 15
local MAX_DARKEN_ALPHA = 0.82
local VIGNETTE_START = 65

local ICON_FOOD = "/esoui/art/tradinghouse/gamepad/gp_tradinghouse_materials_provisioning_food.dds"
local ICON_DRINK = "/esoui/art/tradinghouse/gamepad/gp_tradinghouse_materials_provisioning_drink.dds"
local EDGE_TEXTURE = "/esoui/art/miscellaneous/centerscreen_announceEdge.dds"
local METER_FRAME_TEXTURE = "/esoui/art/actionbar/abilityframe64_up.dds"
local METER_GLOW_TEXTURE = "/esoui/art/actionbar/abilityframe64_glow.dds"

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

local function GetSV()
    HARDCORE = HARDCORE or {}
    if not HARDCORE.trailRationsSaved then
        HARDCORE.trailRationsSaved = ZO_SavedVars:NewCharacterIdSettings("HARDCORE_TRAIL_RATIONS_SV", 1, nil, {
            hunger = 100,
            thirst = 100,
            lastUpdateMs = 0,
            hud = {
                x = 360,
                y = 710,
                unlocked = false,
                showLabels = true,
                vignette = true
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
    if sv.hud.x == nil then sv.hud.x = 360 end
    if sv.hud.y == nil then sv.hud.y = 710 end
    if sv.hud.unlocked == nil then sv.hud.unlocked = false end
    if sv.hud.showLabels == nil then sv.hud.showLabels = true end
    sv.hud.vignette = true
    sv.warnings = sv.warnings or {}
    return sv
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
    ZO_AlertNoSuppression(UI_ALERT_CATEGORY_ALERT, sound or SOUNDS.NEGATIVE_CLICK, text)
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
local hungerFill
local thirstFill
local hungerValue
local thirstValue
local hungerLabel
local thirstLabel
local hungerPulse
local thirstPulse
local hungerShade
local thirstShade
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
    edgeVignette:SetBlendMode(TEX_BLEND_COLOR_ALPHA)
    edgeVignette:SetAlpha(0)
end

local function ApplyHudPosition()
    if not hudTLW then
        return
    end
    local sv = GetSV()
    hudTLW:ClearAnchors()
    hudTLW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.hud.x, sv.hud.y)
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
    glow:SetBlendMode(TEX_BLEND_ADD)

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
    pulse:SetBlendMode(TEX_BLEND_ADD)

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

    return fill, value, label, pulse, shade
end

local function EnsureHud()
    if hudTLW then
        return
    end

    local wm = WINDOW_MANAGER
    hudTLW = wm:CreateTopLevelWindow("HARDCORE_TrailRationsHUD")
    hudTLW:SetDimensions(116, 76)
    hudTLW:SetDrawTier(DT_HIGH)
    hudTLW:SetDrawLayer(DL_OVERLAY)
    hudTLW:SetDrawLevel(9200)
    hudTLW:SetMouseEnabled(false)
    hudTLW:SetMovable(false)
    hudTLW:SetClampedToScreen(true)
    hudTLW:SetHidden(true)

    local bg = wm:CreateControl(nil, hudTLW, CT_TEXTURE)
    bg:SetAnchor(TOP, hudTLW, TOP, 0, 4)
    bg:SetDimensions(114, 54)
    bg:SetTexture("/esoui/art/actionbar/backrow_abilityframe_overlay.dds")
    bg:SetColor(0.025, 0.020, 0.014, 0.46)
    bg:SetAlpha(0.42)

    thirstFill, thirstValue, thirstLabel, thirstPulse, thirstShade = CreateMeter(hudTLW, "HARDCORE_TrailRationsThirst", ICON_DRINK, 0.08, 0.72, 1.0, 2)
    hungerFill, hungerValue, hungerLabel, hungerPulse, hungerShade = CreateMeter(hudTLW, "HARDCORE_TrailRationsHunger", ICON_FOOD, 0.95, 0.68, 0.18, 60)
    thirstLabel:SetText("WATER")
    hungerLabel:SetText("FOOD")

    hudTLW:SetHandler("OnMoveStop", function()
        local sv = GetSV()
        sv.hud.x = zo_round(hudTLW:GetLeft())
        sv.hud.y = zo_round(hudTLW:GetTop())
        ApplyHudPosition()
    end)

    pulseTimeline = ANIMATION_MANAGER:CreateTimeline()
    local aIn1 = pulseTimeline:InsertAnimation(ANIMATION_ALPHA, thirstPulse, 0)
    aIn1:SetAlphaValues(0.05, 0.38)
    aIn1:SetDuration(450)
    local aOut1 = pulseTimeline:InsertAnimation(ANIMATION_ALPHA, thirstPulse, 450)
    aOut1:SetAlphaValues(0.38, 0.05)
    aOut1:SetDuration(450)
    local aIn2 = pulseTimeline:InsertAnimation(ANIMATION_ALPHA, hungerPulse, 0)
    aIn2:SetAlphaValues(0.05, 0.38)
    aIn2:SetDuration(450)
    local aOut2 = pulseTimeline:InsertAnimation(ANIMATION_ALPHA, hungerPulse, 450)
    aOut2:SetAlphaValues(0.38, 0.05)
    aOut2:SetDuration(450)
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

    hungerFill:SetAlpha(0.07 + (hunger / 100) * 0.48)
    thirstFill:SetAlpha(0.07 + (thirst / 100) * 0.48)
    if hungerShade then
        hungerShade:SetAlpha(0.18 + ((1 - (hunger / 100)) * 0.78))
    end
    if thirstShade then
        thirstShade:SetAlpha(0.18 + ((1 - (thirst / 100)) * 0.78))
    end
    hungerValue:SetText(tostring(zo_round(hunger)))
    thirstValue:SetText(tostring(zo_round(thirst)))

    if hunger <= WARNING_CRITICAL then
        hungerValue:SetColor(1, 0.48, 0.28, 1)
    else
        hungerValue:SetColor(1, 0.96, 0.82, 0.96)
    end
    if thirst <= WARNING_CRITICAL then
        thirstValue:SetColor(0.62, 0.92, 1, 1)
    else
        thirstValue:SetColor(1, 0.96, 0.82, 0.96)
    end

    local showLabels = sv.hud.showLabels == true
    hungerLabel:SetHidden(not showLabels)
    thirstLabel:SetHidden(not showLabels)

    local hungerCritical = hunger <= WARNING_CRITICAL
    local thirstCritical = thirst <= WARNING_CRITICAL
    hungerPulse:SetHidden(not hungerCritical)
    thirstPulse:SetHidden(not thirstCritical)

    if hungerCritical or thirstCritical then
        if pulseTimeline and not pulseTimeline:IsPlaying() then
            pulseTimeline:PlayFromStart()
        end
    elseif pulseTimeline and pulseTimeline:IsPlaying() then
        pulseTimeline:Stop()
        hungerPulse:SetAlpha(0)
        thirstPulse:SetAlpha(0)
    end

    UpdateLockState()
    UpdateVisibility()
    UpdateOverlay()
end

local function Refill(itemType)
    if not Rule.active then
        return
    end

    local sv = GetSV()
    if itemType == ITEMTYPE_FOOD then
        sv.hunger = 100
        ResetWarningFlagsForMeter(sv, "hunger")
        Alert("HARDCORE: Hunger restored.", SOUNDS.INVENTORY_ITEM_APPLY_CHARGE)
    elseif itemType == ITEMTYPE_DRINK then
        sv.thirst = 100
        ResetWarningFlagsForMeter(sv, "thirst")
        Alert("HARDCORE: Thirst restored.", SOUNDS.INVENTORY_ITEM_APPLY_CHARGE)
    else
        return
    end

    sv.lastUpdateMs = GetFrameTimeMilliseconds()
    UpdateHud()
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
        Refill(itemType)
    end
end

local function TryRefillFromCapturedUse()
    if not Rule.active then
        return
    end
    if Rule._lastConsumedType and GetFrameTimeMilliseconds() - Rule._lastConsumedMs <= 2000 then
        Refill(Rule._lastConsumedType)
        Rule._lastConsumedType = nil
        Rule._lastConsumedMs = 0
    end
end

local function TryRefillFromCapturedUseLater()
    zo_callLater(TryRefillFromCapturedUse, 250)
    zo_callLater(TryRefillFromCapturedUse, 1000)
end

local function TryRefillFromActionSlot(actionSlotIndex)
    if not Rule.active then
        return
    end
    if not actionSlotIndex then
        return
    end

    local link = nil
    if GetSlotItemLink then
        link = GetSlotItemLink(actionSlotIndex, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
        if not link or link == "" then
            link = GetSlotItemLink(actionSlotIndex)
        end
    end

    if link and link ~= "" and GetItemLinkItemType then
        local itemType = GetItemLinkItemType(link)
        Refill(itemType)
    end
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

    sv.hunger = ClampMeter(sv.hunger - ((elapsed / HUNGER_DRAIN_MS) * 100))
    sv.thirst = ClampMeter(sv.thirst - ((elapsed / THIRST_DRAIN_MS) * 100))

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

    if ZO_PreHook then
        ZO_PreHook("ZO_InventorySlot_InitiateConfirmUseItem", function(inventorySlot)
            if inventorySlot then
                CaptureItemTypeFromBag(inventorySlot.bagId or inventorySlot.bag, inventorySlot.slotIndex or inventorySlot.index)
                TryRefillFromCapturedUseLater()
            end
        end)
    end
    EVENT_MANAGER:RegisterForEvent(NS .. "_QUICKSLOT", EVENT_ACTION_SLOT_ABILITY_USED, function(_, actionSlotIndex)
        TryRefillFromActionSlot(actionSlotIndex)
    end)
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
    sv.hud.x = 360
    sv.hud.y = 710
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
        sv.hunger = ClampMeter(sv.hunger - ((minutes * 60 * 1000 / HUNGER_DRAIN_MS) * 100))
        sv.thirst = ClampMeter(sv.thirst - ((minutes * 60 * 1000 / THIRST_DRAIN_MS) * 100))
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
