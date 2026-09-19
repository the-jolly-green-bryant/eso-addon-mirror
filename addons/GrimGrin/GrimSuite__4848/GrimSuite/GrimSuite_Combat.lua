local GS = GrimSuite
GS.Combat = GS.Combat or {}
local Combat = GS.Combat

---------------------------------------------------------------------
-- GrimSuite Combat
--
-- Scope for v0.0.24Dev:
--   * Simple GCD metronome
--   * Simplified WeaveDelays
--
-- Deliberately NOT porting:
--   * Combat Metronome resource display
--   * Stack Tracker
--   * Full Light Attack Tracker
--   * CM collectibles/items/synergies
--   * WeaveDelays skill images
---------------------------------------------------------------------

local FONT = "EsoUI/Common/Fonts/Univers57.slug|16|soft-shadow-thick"
local SMALL_FONT = "EsoUI/Common/Fonts/Univers57.slug|14|soft-shadow-thick"
local BORDER = { 0.65, 0.65, 0.65, 0.75 }
local DARK_BORDER = { 0.02, 0.02, 0.02, 0.95 }

Combat.gcdEnd = 0
Combat.gcdStart = 0
Combat.gcdDuration = 1000
Combat.inCombat = false
Combat.layoutUnlocked = false

Combat.weave = {
    actions = {},
    max = 10,
    pendingLA = nil,
    previousSkillEnd = nil,
    averageSum = 0,
    averageCount = 0,
    averagePending = {},
    averageMax = 25,
    laTimeout = 1000,
    laGraceMs = 75,
    lastLAConfirmed = nil,
    previousSkillAt = nil,
}

local function MakeBackdrop(name, parent)
    local c = WINDOW_MANAGER:CreateControl(name, parent, CT_BACKDROP)
    c:SetCenterColor(1, 1, 1, 1)
    c:SetEdgeColor(1, 1, 1, 0)
    return c
end

local function SetCleanBorder(control, r, g, b, a)
    if not control then return end
    control:SetEdgeColor(r or BORDER[1], g or BORDER[2], b or BORDER[3], a or BORDER[4])
end

local function SetHidden(c, hidden)
    if c then c:SetHidden(hidden) end
end

---------------------------------------------------------------------
-- Layout helpers
---------------------------------------------------------------------

local function CenterControl(control, horizontal, vertical, xKey, yKey)
    if not control then return end
    local screenW = GuiRoot:GetWidth()
    local screenH = GuiRoot:GetHeight()

    if horizontal then
        GS.Saved[xKey] = math.floor((screenW - control:GetWidth()) * 0.5 + 0.5)
    end
    if vertical then
        GS.Saved[yKey] = math.floor((screenH - control:GetHeight()) * 0.5 + 0.5)
    end

    Combat:ApplyLayout()
end

local function EnableMouseDrag(control, isUnlocked)
    if not control then return end

    -- Use ESO's native TopLevelWindow dragging. This is intentionally kept
    -- simple: this was the mechanism used by the original working prototype.
    -- The settings toggle only enables/disables mouse input; the frame remains
    -- movable so ESO can handle the drag natively.
    control:SetMouseEnabled(isUnlocked)
    control:SetMovable(true)
    control:SetClampedToScreen(true)
end

local function DisableAttributeChildMouse(control)
    if not control then return end
    control:SetMouseEnabled(false)
    local childCount = control.GetNumChildren and control:GetNumChildren() or 0
    for i = 1, childCount do
        local child = control:GetChild(i)
        if child then
            DisableAttributeChildMouse(child)
        end
    end
end

local function EnableAttributeDrag(control, isUnlocked)
    if not control then return end
    control:SetMouseEnabled(isUnlocked == true)
    control:SetMovable(isUnlocked == true)
    control:SetClampedToScreen(true)
end

local function MakeMouseTransparent(control)
    if control and control.SetMouseEnabled then
        control:SetMouseEnabled(false)
    end
end

-- ESO can rebuild/reconfigure HUD controls when scenes change (entering a
-- house is a good example).  GrimSuite's combat widgets are deliberately
-- absolute GuiRoot-positioned controls, so scene changes should never be
-- allowed to leave them at a transient scene position.  Re-apply the saved
-- coordinates after the scene transition has finished.
local function ScheduleLayoutRepair()
    if not Combat.initialized then return end

    EM:UnregisterForUpdate(GS.name .. "_CombatLayoutRepair")
    EM:RegisterForUpdate(GS.name .. "_CombatLayoutRepair", 16, function()
        EM:UnregisterForUpdate(GS.name .. "_CombatLayoutRepair")
        Combat:ApplyLayout()

        -- Some HUD fragments finish their own anchoring one frame later.
        -- Give ESO a little time to finish, then assert our saved layout again.
        zo_callLater(function()
            if Combat.initialized then
                Combat:ApplyLayout()
            end
        end, 150)
    end)
end


---------------------------------------------------------------------
-- GrimSuite Attribute Bars
--
-- First-pass integration of AltAttributes' player resource bars.
-- These bars intentionally have NO relationship to the action bar.
-- Positioning / dragging / settings will be handled separately.
---------------------------------------------------------------------

GSAttributeFakeGloss = ZO_Object:Subclass()

function GSAttributeFakeGloss:New()
    return ZO_Object.New(self)
end

function GSAttributeFakeGloss:SetMinMax() end
function GSAttributeFakeGloss:SetValue() end

local GSAttributeBar = ZO_Object:Subclass()

function GSAttributeBar:New(...)
    local bar = ZO_Object.New(self)
    bar:Initialize(...)
    return bar
end

function GSAttributeBar:Initialize(unitTag, powerType, topLevelCtrl, reversed)
    self.unitTag = unitTag
    self.powerType = powerType
    self.reversed = reversed == true

    local template = self.reversed and "GS_AttributeBarReversed" or "GS_AttributeBar"
    self.control = CreateControlFromVirtual(
        "GrimSuiteAttribute_" .. powerType,
        topLevelCtrl,
        template
    )

    self.control:SetHidden(true)
    self.attrText = self.control:GetNamedChild("Text")
    self.attrTextPercent = self.control:GetNamedChild("Percent")
    self.attrBar = self.control:GetNamedChild("Bar")

    ZO_StatusBar_SetGradientColor(
        self.attrBar,
        ZO_POWER_BAR_GRADIENT_COLORS[powerType]
    )

    local function OnPowerUpdate(unitTag, powerPoolIndex, updatedPowerType, powerPool, powerPoolMax)
        self:OnPowerUpdate(powerPool, powerPoolMax, false)
    end

    local handler = ZO_MostRecentPowerUpdateHandler:New(
        "GrimSuiteAttribute_" .. powerType,
        OnPowerUpdate
    )
    handler:AddFilterForEvent(REGISTER_FILTER_POWER_TYPE, powerType)
    handler:AddFilterForEvent(REGISTER_FILTER_UNIT_TAG, unitTag)
    self.powerHandler = handler

    self.control:RegisterForEvent(EVENT_PLAYER_ALIVE, function()
        self:Refresh()
    end)

    self:Refresh(true)
end

function GSAttributeBar:Refresh(force)
    if force then
        self:ApplyStyle()
    end

    local power, maxPower = GetUnitPower(self.unitTag, self.powerType)
    self:OnPowerUpdate(power, maxPower, force)
end

function GSAttributeBar:FormatPercent(value, maxValue)
    local percent = 0
    if maxValue ~= 0 then
        percent = (value / maxValue) * 100
    end

    local percentText
    if percent < 10 then
        percentText = ZO_CommaDelimitDecimalNumber(zo_roundToNearest(percent, .1))
        percentText = ZO_FastFormatDecimalNumber(percentText)
    else
        percentText = zo_round(percent)
    end

    return percentText .. "%"
end

function GSAttributeBar:OnPowerUpdate(power, maxPower, force)
    ZO_StatusBar_SmoothTransition(self.attrBar, power, maxPower, force)
    self:UpdateResourceNumbers(power, maxPower)
end

function GSAttributeBar:UpdateResourceNumbers(power, maxPower)
    self.attrText:SetText(
        ZO_AbbreviateAndLocalizeNumber(
            power,
            NUMBER_ABBREVIATION_PRECISION_TENTHS,
            false
        )
    )
    self.attrTextPercent:SetText(self:FormatPercent(power, maxPower))
end

function GSAttributeBar:ApplyStyle()
    local frameLeft = self.reversed and "ZO_PlayerAttributeFrameLeftArrow" or "ZO_PlayerAttributeFrameLeft"
    local frameRight = self.reversed and "ZO_PlayerAttributeFrameRight" or "ZO_PlayerAttributeFrameRightArrow"
    local bgLeft = self.reversed and "ZO_PlayerAttributeBgLeftArrow" or "ZO_PlayerAttributeBgLeft"
    local bgRight = self.reversed and "ZO_PlayerAttributeBgRight" or "ZO_PlayerAttributeBgRightArrow"

    ApplyTemplateToControl(
        self.control:GetNamedChild("FrameLeft"),
        ZO_GetPlatformTemplate(frameLeft)
    )
    ApplyTemplateToControl(
        self.control:GetNamedChild("FrameRight"),
        ZO_GetPlatformTemplate(frameRight)
    )
    ApplyTemplateToControl(
        self.control:GetNamedChild("FrameCenter"),
        ZO_GetPlatformTemplate("ZO_PlayerAttributeFrameCenter")
    )

    ApplyTemplateToControl(
        self.control:GetNamedChild("BgContainerBgLeft"),
        ZO_GetPlatformTemplate(bgLeft)
    )
    ApplyTemplateToControl(
        self.control:GetNamedChild("BgContainerBgRight"),
        ZO_GetPlatformTemplate(bgRight)
    )
    ApplyTemplateToControl(
        self.control:GetNamedChild("BgContainerBgCenter"),
        ZO_GetPlatformTemplate("ZO_PlayerAttributeBgCenter")
    )

    -- Status bars already inherit ZO_PlayerAttributeStatusBar in XML.
    -- Leave that template in place rather than applying it again at runtime.
end

function GSAttributeBar:SetWidth(value)
    self.control:SetWidth(value)
end

function GSAttributeBar:SetHeight(value)
    local prevHeight = self.attrBar:GetHeight()
    if prevHeight ~= value then
        local mod = value / prevHeight

        local frameLeft = self.control:GetNamedChild("FrameLeft")
        local frameRight = self.control:GetNamedChild("FrameRight")
        local bgLeft = self.control:GetNamedChild("BgContainerBgLeft")
        local bgRight = self.control:GetNamedChild("BgContainerBgRight")

        frameLeft:SetWidth(zo_round(frameLeft:GetWidth() * mod) - 3)
        frameRight:SetWidth(zo_round(frameRight:GetWidth() * mod) - 3)
        bgLeft:SetWidth(zo_round(bgLeft:GetWidth() * mod) - 3)
        bgRight:SetWidth(zo_round(bgRight:GetWidth() * mod) - 3)

        self.control:SetHeight(value)
        -- The frame is the full control height; the fill itself is inset inside it.
        -- Its height is governed by the XML anchors below.

        frameLeft:SetHeight(value)
        frameRight:SetHeight(value)
        bgLeft:SetHeight(value)
        bgRight:SetHeight(value)
        self.control:GetNamedChild("FrameCenter"):SetHeight(value)
        self.control:GetNamedChild("BgContainerBgCenter"):SetHeight(value)

        local fontMod = IsInGamepadPreferredMode() and 1 / 3 or 2 / 3
        local font = "$(GAMEPAD_LIGHT_FONT)|" .. zo_round(value * fontMod) .. "|soft-shadow-thick"
        self.attrText:SetFont(font)
        self.attrTextPercent:SetFont(font)
    end
end

function GSAttributeBar:Show()
    self.control:SetHidden(false)
end

function GSAttributeBar:Hide()
    self.control:SetHidden(true)
end

local GSAttributeHealthBar = GSAttributeBar:Subclass()

function GSAttributeHealthBar:New(...)
    return GSAttributeBar.New(self, ...)
end

function GSAttributeHealthBar:Initialize(unitTag, powerType, topLevelCtrl)
    self.curShield = 0
    self.curHP = 0
    self.maxHP = 0

    GSAttributeBar.Initialize(self, unitTag, powerType, topLevelCtrl, false)

    self.shieldBar = CreateControlFromVirtual(
        "GrimSuiteAttributeShield_" .. powerType,
        self.attrBar,
        "GS_AttributeShieldBar"
    )

    self.shieldBar:SetColor(1, 0.49, 0.13, 0.50)
    self.shieldBar:ClearAnchors()
    self.shieldBar:SetAnchor(TOPLEFT, self.attrBar, TOPLEFT, 0, 5)
    self.shieldBar:SetAnchor(BOTTOMRIGHT, self.attrBar, BOTTOMRIGHT, 0, -5)
    self:OnUpdateShield(0, true)

    local function OnVisualPower(_, unitTag, unitAttributeVisual, statType, attributeType, powerType, oldValue, newValue, oldMaxValue, newMaxValue)
        local value = oldMaxValue == nil and oldValue or newValue
        if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
            self:OnUpdateShield(value, false)
        end
    end

    local function OnVisualPowerRemoved(_, unitTag, unitAttributeVisual)
        if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
            self:OnUpdateShield(0, false)
        end
    end

    topLevelCtrl:RegisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, OnVisualPower)
    topLevelCtrl:AddFilterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, REGISTER_FILTER_UNIT_TAG, unitTag)

    topLevelCtrl:RegisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, OnVisualPower)
    topLevelCtrl:AddFilterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, REGISTER_FILTER_UNIT_TAG, unitTag)

    topLevelCtrl:RegisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, OnVisualPowerRemoved)
    topLevelCtrl:AddFilterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, REGISTER_FILTER_UNIT_TAG, unitTag)
end

function GSAttributeHealthBar:OnPowerUpdate(health, maxHealth, force)
    self.curHP = health
    self.maxHP = maxHealth

    ZO_StatusBar_SmoothTransition(self.attrBar, health, maxHealth, force)
    self:UpdateResourceNumbers(self.curHP, self.maxHP, self.curShield)
end

function GSAttributeHealthBar:OnUpdateShield(shield, force)
    self.curShield = shield
    ZO_StatusBar_SmoothTransition(self.shieldBar, shield, self.maxHP, force)
    self:UpdateResourceNumbers(self.curHP, self.maxHP, self.curShield)
end

function GSAttributeHealthBar:UpdateResourceNumbers(health, maxHealth, shield)
    if shield and shield > 0 then
        self.attrText:SetText(string.format(
            "%s [%s]",
            ZO_AbbreviateAndLocalizeNumber(
                health,
                NUMBER_ABBREVIATION_PRECISION_LARGEST_UNIT,
                false
            ),
            ZO_AbbreviateAndLocalizeNumber(
                shield,
                NUMBER_ABBREVIATION_PRECISION_LARGEST_UNIT,
                false
            )
        ))
        self.attrTextPercent:SetText(self:FormatPercent(health, maxHealth))
    else
        GSAttributeBar.UpdateResourceNumbers(self, health, maxHealth)
    end
end

function GSAttributeHealthBar:ApplyStyle()
    GSAttributeBar.ApplyStyle(self)
end

function GSAttributeHealthBar:SetHeight(value)
    GSAttributeBar.SetHeight(self, value)
    if self.shieldBar then
        self.shieldBar:ClearAnchors()
        self.shieldBar:SetAnchor(TOPLEFT, self.attrBar, TOPLEFT, 0, 5)
        self.shieldBar:SetAnchor(BOTTOMRIGHT, self.attrBar, BOTTOMRIGHT, 0, -5)
    end
end

function Combat:CreateAttributes()
    if self.attributesInitialized then return end

    local container = GetControl("GrimSuiteAttributes")
    if not container then return end

    -- Hide the game's own resource bars. The GrimSuite copies are
    -- deliberately independent from ZO_ActionBar1.
    ZO_PlayerAttributeHealth:SetHidden(true)
    ZO_PlayerAttributeMagicka:SetHidden(true)
    ZO_PlayerAttributeStamina:SetHidden(true)

    local height = IsInGamepadPreferredMode() and 96 or 32
    local width = 360

    self.attributeHealth = GSAttributeHealthBar:New(
        "player",
        POWERTYPE_HEALTH,
        container
    )
    self.attributeMagicka = GSAttributeBar:New(
        "player",
        POWERTYPE_MAGICKA,
        container,
        true
    )
    self.attributeStamina = GSAttributeBar:New(
        "player",
        POWERTYPE_STAMINA,
        container,
        false
    )

    for _, bar in ipairs({
        self.attributeHealth,
        self.attributeMagicka,
        self.attributeStamina,
    }) do
        bar:ApplyStyle()
        bar:SetWidth(width)
        bar:SetHeight(height)
        bar:Show()
        DisableAttributeChildMouse(bar.control)
    end

    -- The attribute bars are their own independent movable group.
    -- They are deliberately NOT anchored to ZO_ActionBar1.
    self.attributesInitialized = true
    self:LayoutAttributes()

    container:SetMouseEnabled(false)
    container:SetMovable(false)
    container:SetClampedToScreen(true)

    container:SetHandler("OnMouseDown", function(c, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and Combat.layoutUnlocked then
            c:StartMoving()
        end
    end)

    container:SetHandler("OnMoveStop", function(c)
        if not Combat.layoutUnlocked then return end

        local centerX, centerY = GuiRoot:GetWidth() * 0.5, GuiRoot:GetHeight() * 0.5
        local cX, cY = c:GetCenter()

        GS.Saved.attributesX = math.floor((cX - centerX) + 0.5)
        GS.Saved.attributesY = math.floor((cY - centerY) + 0.5)

        self:ApplyLayout()
    end)

    container:RegisterForEvent(
        EVENT_GAMEPAD_PREFERRED_MODE_CHANGED,
        function()
            self:LayoutAttributes()
            self:ApplyLayout()
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        GS.name .. "_AttributesActivated",
        EVENT_PLAYER_ACTIVATED,
        function()
            ZO_PlayerAttributeHealth:SetHidden(true)
            ZO_PlayerAttributeMagicka:SetHidden(true)
            ZO_PlayerAttributeStamina:SetHidden(true)

            self.attributeHealth:Refresh(true)
            self.attributeMagicka:Refresh(true)
            self.attributeStamina:Refresh(true)
            self:LayoutAttributes()
            self:ApplyLayout()
        end
    )

    EnableAttributeDrag(container, self.layoutUnlocked)
end

function Combat:LayoutAttributes()
    local container = GetControl("GrimSuiteAttributes")
    if not container or not self.attributeHealth then return end

    container:SetDimensions(500, 120)

    local gap = IsInGamepadPreferredMode() and 12 or 6

    self.attributeHealth.control:ClearAnchors()
    self.attributeHealth.control:SetAnchor(TOP, container, TOP, 0, 0)

    self.attributeMagicka.control:ClearAnchors()
    self.attributeMagicka.control:SetAnchor(TOPRIGHT, self.attributeHealth.control, BOTTOM, -5, gap)

    self.attributeStamina.control:ClearAnchors()
    self.attributeStamina.control:SetAnchor(TOPLEFT, self.attributeHealth.control, BOTTOM, 5, gap)
end


---------------------------------------------------------------------
-- GCD Metronome
---------------------------------------------------------------------

function Combat:CreateGCD()
    local frame = WINDOW_MANAGER:CreateTopLevelWindow("GrimSuiteGCD")
    frame:SetDimensions(GS.Saved.gcdWidth, GS.Saved.gcdHeight)
    frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, GS.Saved.gcdX, GS.Saved.gcdY)
    frame:SetHandler("OnMoveStop", function(c)
        GS.Saved.gcdX = math.floor(c:GetLeft() + 0.5)
        GS.Saved.gcdY = math.floor(c:GetTop() + 0.5)
    end)
    local shadow = MakeBackdrop("GrimSuiteGCD_Shadow", frame)
    shadow:SetAnchorFill(frame)
    shadow:SetCenterColor(0, 0, 0, 0.35)
    shadow:SetEdgeColor(DARK_BORDER[1], DARK_BORDER[2], DARK_BORDER[3], DARK_BORDER[4])

    local bg = MakeBackdrop("GrimSuiteGCD_BG", frame)
    bg:SetAnchor(TOPLEFT, frame, TOPLEFT, 1, 1)
    bg:SetDimensions(math.max(1, GS.Saved.gcdWidth - 2), math.max(1, GS.Saved.gcdHeight - 2))
    bg:SetCenterColor(0.035, 0.035, 0.035, 0.88)
    SetCleanBorder(bg)

    local bar = MakeBackdrop("GrimSuiteGCD_Bar", frame)
    bar:SetAnchor(TOPLEFT, bg, TOPLEFT, 1, 1)
    bar:SetDimensions(math.max(1, GS.Saved.gcdWidth - 4), math.max(1, GS.Saved.gcdHeight - 4))
    bar:SetCenterColor(0.10, 0.10, 0.10, 0.90)
    bar:SetEdgeColor(0.20, 0.20, 0.20, 0.65)

    -- Moving GCD progress fill, matching the Combat Metronome concept:
    -- the inner bar changes width as the GCD counts down while the outer
    -- frame remains fixed.
    local progress = MakeBackdrop("GrimSuiteGCD_Progress", frame)
    progress:SetAnchor(TOPLEFT, frame, TOPLEFT, 2, 2)
    progress:SetDimensions(0, math.max(1, GS.Saved.gcdHeight - 4))
    progress:SetCenterColor(0.98, 0.82, 0.08, 0.98)
    progress:SetEdgeColor(1.00, 0.92, 0.35, 0.30)

    -- Live latency window stays on the LEFT and is layered above the yellow
    -- progress fill so the latency buffer remains visible.
    local ping = MakeBackdrop("GrimSuiteGCD_Ping", frame)
    ping:SetAnchor(TOPLEFT, frame, TOPLEFT, 2, 2)
    ping:SetDimensions(0, math.max(1, GS.Saved.gcdHeight - 4))
    ping:SetCenterColor(0.82, 0.07, 0.07, 0.95)
    ping:SetEdgeColor(1.00, 0.30, 0.30, 0.25)

    local label = WINDOW_MANAGER:CreateControl("GrimSuiteGCD_Time", frame, CT_LABEL)
    label:SetFont(SMALL_FONT)
    label:SetAnchor(CENTER, frame, CENTER, 0, 0)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetText("")

    MakeMouseTransparent(bg)
    MakeMouseTransparent(bar)
    MakeMouseTransparent(progress)
    MakeMouseTransparent(ping)
    MakeMouseTransparent(label)

    self.gcdFrame = frame
    self.gcdBar = bar
    self.gcdPing = ping
    self.gcdProgress = progress
    self.gcdLabel = label
    self.gcdIdle = nil

    -- Anchor the outer GCD bar once; its size is updated only when layout changes.
    self.gcdBar:SetAnchorFill(self.gcdFrame)

    EnableMouseDrag(frame, self.layoutUnlocked)

    frame:SetHidden(false)
end

function Combat:StartGCD(duration)
    duration = tonumber(duration) or 1000
    if duration < 1 then duration = 1 end

    local now = GetFrameTimeMilliseconds()
    self.gcdStart = now
    self.gcdDuration = duration
    self.gcdEnd = now + duration
end

function Combat:UpdateGCD()
    if not self.gcdFrame then return end

    if not GS.Saved.showGCD then
        self.gcdFrame:SetHidden(true)
        return
    end

    self.gcdFrame:SetHidden(false)

    local now = GetFrameTimeMilliseconds()
    local remaining = self.gcdEnd > 0 and (self.gcdEnd - now) or 0
    if remaining < 0 then remaining = 0 end

    local width = self.gcdFrame:GetWidth()
    local height = self.gcdFrame:GetHeight()

    -- Combat Metronome-style moving inner progress bar: it starts full and
    -- shrinks as the GCD counts down.
    local gcdProgress = 0
    if remaining > 0 and self.gcdDuration > 0 then
        gcdProgress = math.max(0, math.min(1, remaining / self.gcdDuration))
    end
    local innerWidth = math.max(1, width - 4)
    local innerHeight = math.max(1, height - 4)
    local progressWidth = math.floor(gcdProgress * innerWidth)
    self.gcdProgress:SetDimensions(progressWidth, innerHeight)

    -- Live latency zone on the LEFT. Keep it above the yellow progress fill
    -- so the latency buffer remains visible throughout the countdown.
    local pingMs = 0
    if remaining > 0 then
        pingMs = math.max(0, math.min(GetLatency(), self.gcdDuration))
    end
    local pingWidth = math.floor((pingMs / math.max(1, self.gcdDuration)) * innerWidth)
    self.gcdPing:SetDimensions(pingWidth, innerHeight)

    local idle = remaining <= 0
    if idle ~= self.gcdIdle then
        self.gcdIdle = idle
        if idle then
            self.gcdLabel:SetText("READY")
        else
            self.gcdLabel:SetText(string.format("%.2f", remaining / 1000))
        end
    elseif not idle then
        -- The countdown itself is animated, so only the numeric text changes.
        self.gcdLabel:SetText(string.format("%.2f", remaining / 1000))
    end
end

---------------------------------------------------------------------
-- Simplified WeaveDelays
---------------------------------------------------------------------

local function Clamp(v, lo, hi)
    return math.max(lo, math.min(v, hi))
end

local function DelayColor(delay)
    if delay < 20 then
        return 0.35, 0.80, 1.00, 1
    elseif delay <= 50 then
        return 0.15, 0.85, 0.20, 1
    elseif delay <= 100 then
        return 0.75, 0.85, 0.15, 1
    elseif delay <= 200 then
        return 0.95, 0.55, 0.10, 1
    else
        return 0.90, 0.12, 0.10, 1
    end
end

function Combat:CreateWeaveBar()
    local frame = WINDOW_MANAGER:CreateTopLevelWindow("GrimSuiteWeave")
    frame:SetDimensions(GS.Saved.weaveWidth, GS.Saved.weaveHeight)
    frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, GS.Saved.weaveX, GS.Saved.weaveY)
    frame:SetHandler("OnMoveStop", function(c)
        GS.Saved.weaveX = math.floor(c:GetLeft() + 0.5)
        GS.Saved.weaveY = math.floor(c:GetTop() + 0.5)
    end)
    -- Keep the average as its own top-level window so it can be dragged
    -- independently without the weave bar underneath intercepting the mouse.
    local averageFrame = WINDOW_MANAGER:CreateTopLevelWindow("GrimSuiteWeave_Avg")
    averageFrame:SetDimensions(110, 22)
    averageFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
        GS.Saved.weaveX + GS.Saved.weaveAverageX,
        GS.Saved.weaveY + GS.Saved.weaveAverageY)
    averageFrame:SetMouseEnabled(self.layoutUnlocked)
    averageFrame:SetMovable(self.layoutUnlocked)
    averageFrame:SetHidden(not self.layoutUnlocked)
    averageFrame:SetHandler("OnMouseDown", function(c, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and Combat.layoutUnlocked then
            c:StartMoving()
        end
    end)
    averageFrame:SetHandler("OnMoveStop", function(c)
        if not Combat.layoutUnlocked then return end
        GS.Saved.weaveAverageX = math.floor(c:GetLeft() - frame:GetLeft() + 0.5)
        GS.Saved.weaveAverageY = math.floor(c:GetTop() - frame:GetTop() + 0.5)
        Combat:ApplyLayout()
    end)

    -- CT_LABEL is the text control; the top-level window above is the
    -- draggable hitbox.  Keeping them separate avoids calling label-only
    -- methods on a top-level window.
    -- Average is intentionally text-only: no backdrop or border.
    local label = WINDOW_MANAGER:CreateControl("GrimSuiteWeave_AvgLabel", averageFrame, CT_LABEL)
    label:SetAnchorFill(averageFrame)
    label:SetFont(SMALL_FONT)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetText("")
    label:SetMouseEnabled(false)

    local shadow = MakeBackdrop("GrimSuiteWeave_Shadow", frame)
    shadow:SetAnchorFill(frame)
    shadow:SetCenterColor(0, 0, 0, 0.35)
    shadow:SetEdgeColor(DARK_BORDER[1], DARK_BORDER[2], DARK_BORDER[3], DARK_BORDER[4])

    local bar = MakeBackdrop("GrimSuiteWeave_BG", frame)
    bar:SetAnchor(TOPLEFT, frame, TOPLEFT, 1, 1)
    bar:SetDimensions(math.max(1, GS.Saved.weaveWidth - 2), math.max(1, GS.Saved.weaveHeight - 2))
    bar:SetCenterColor(0.035, 0.035, 0.035, 0.88)
    SetCleanBorder(bar)

    self.weaveFrame = frame
    self.weaveAverageFrame = averageFrame
    self.weaveAverage = label
    MakeMouseTransparent(bar)

    self.weaveBar = bar
    self.weaveSlots = {}
    EnableMouseDrag(frame, self.layoutUnlocked)

    local barWidth = math.max(1, GS.Saved.weaveWidth - 4)
    local barHeight = GS.Saved.weaveHeight
    local slotW = barWidth / self.weave.max
    local slotH = math.max(4, barHeight - 6)
    for i = 1, self.weave.max do
        local slot = MakeBackdrop("GrimSuiteWeave_Slot"..i, frame)
        slot:SetDimensions(math.max(1, slotW - 2), slotH)
        slot:SetAnchor(BOTTOMLEFT, bar, BOTTOMLEFT, 1 + (i-1)*slotW, -1)
        slot:SetCenterColor(0.08, 0.08, 0.08, 0.75)
        slot:SetEdgeColor(0.18, 0.18, 0.18, 0.90)
        self.weaveSlots[i] = slot
        MakeMouseTransparent(slot)

        -- Fixed LA-status marker, inspired by WeaveDelays but intentionally
        -- static: it never slides or changes size. Green = confirmed LA,
        -- red = no confirmed LA for this skill interval.
        local la = MakeBackdrop("GrimSuiteWeave_LA"..i, slot)
        la:SetAnchor(LEFT, slot, LEFT, 0, 0)
        la:SetDimensions(math.min(8, math.max(4, math.floor(slotW * 0.20))), math.max(1, slotH - 2))
        la:SetCenterColor(0.15, 0.85, 0.20, 1)
        la:SetEdgeColor(0.60, 1.00, 0.65, 0.30)
        MakeMouseTransparent(la)
        self.weaveSlots[i].la = la
    end

    frame:SetHidden(false)
end

function Combat:AddWeave(delay, laMissed, windowStart, windowEnd)
    delay = Clamp(tonumber(delay) or 1000, 1, 950)

    table.insert(self.weave.actions, {
        delay = delay,
        laMissed = laMissed == true,
        windowStart = windowStart,
        windowEnd = windowEnd,
    })
    if #self.weave.actions > self.weave.max then
        table.remove(self.weave.actions, 1)
    end

    -- Keep a true rolling average over the most recent 25 skill delays.
    table.insert(self.weave.averagePending, delay)
    self.weave.averageSum = self.weave.averageSum + delay
    if #self.weave.averagePending > self.weave.averageMax then
        self.weave.averageSum = self.weave.averageSum - table.remove(self.weave.averagePending, 1)
    end
    self.weave.averageCount = #self.weave.averagePending

    self:UpdateWeave()
end

function Combat:UpdateWeave()
    if not self.weaveFrame then return end

    if not GS.Saved.showWeave then
        self.weaveFrame:SetHidden(true)
        if self.weaveAverageFrame then self.weaveAverageFrame:SetHidden(true) end
        return
    end

    self.weaveFrame:SetHidden(false)
    if self.weaveAverageFrame then self.weaveAverageFrame:SetHidden(false) end

    for i = 1, self.weave.max do
        local slot = self.weaveSlots[i]
        local entry = self.weave.actions[#self.weave.actions - self.weave.max + i]
        local delay = entry and entry.delay

        if delay then
            local r,g,b,a = DelayColor(delay)
            slot:SetCenterColor(r,g,b,a)
            slot:SetEdgeColor(math.min(1, r * 0.55), math.min(1, g * 0.55), math.min(1, b * 0.55), 0.95)
            if slot.la then
                if entry.laMissed then
                    slot.la:SetCenterColor(0.90, 0.12, 0.10, 1)
                else
                    slot.la:SetCenterColor(0.15, 0.85, 0.20, 1)
                end
            end
        else
            slot:SetCenterColor(0.08,0.08,0.08,0.70)
            slot:SetEdgeColor(0.18, 0.18, 0.18, 0.90)
            if slot.la then
                slot.la:SetCenterColor(0.15, 0.15, 0.15, 0.5)
            end
        end
    end

    if self.weave.averageCount > 0 then
        self.weaveAverage:SetText(string.format("avg %.0f ms", self.weave.averageSum / self.weave.averageCount))
    else
        self.weaveAverage:SetText("")
    end
end

---------------------------------------------------------------------
-- Action / combat events
---------------------------------------------------------------------

function Combat:OnCombatState(_, inCombat)
    self.inCombat = inCombat == true
    if not self.inCombat then
        self:UpdateWeave()
    else
        self:UpdateWeave()
    end
end

function Combat:OnSlotUsed(_, slotId)
    -- Slot 1 is the light attack button. We do not count the button press
    -- itself as a successful LA; OnCombatEvent confirms that the LA actually
    -- produced a combat result.
    if slotId == 1 then
        return
    end

    if slotId < 3 then return end

    local now = GetFrameTimeMilliseconds()

    -- First prototype uses the standard ESO 1s GCD baseline.
    -- Cast/channel time is included when it exceeds the GCD.
    local boundId = GetSlotBoundId(slotId)
    local _, castTime, channelTime = GetAbilityCastInfo(boundId)
    local duration = math.max(1000, (castTime or 0) + (channelTime or 0))

    if self.weave.previousSkillEnd then
        local delay = now - self.weave.previousSkillEnd

        -- Queued skills can be registered a few milliseconds before our
        -- calculated GCD/cast end. Do not turn that into a fake 1 ms weave.
        if delay < 0 then
            delay = 0
        end

        -- Every skill-to-skill interval is recorded. LA compliance is a
        -- separate binary flag: did a confirmed LA occur during this interval?
        local intervalStart = self.weave.previousSkillAt
        local laMissed = true
        if self.weave.lastLAConfirmed
            and intervalStart
            and self.weave.lastLAConfirmed > intervalStart
            and self.weave.lastLAConfirmed <= now then
            laMissed = false
        end

        -- Store the interval bounds so a ranged LA whose combat event arrives
        -- shortly after the next skill can retroactively confirm this entry.
        self:AddWeave(delay, laMissed, intervalStart, now)

        -- This LA confirmation has now been consumed by this skill interval.
        self.weave.lastLAConfirmed = nil
    end

    self.weave.previousSkillAt = now
    self.weave.previousSkillEnd = now + duration

    self:StartGCD(duration)
end

function Combat:OnCombatEvent(_, result, _, _, _, actionSlotType, sourceName)
    if not self.inCombat then return end
    if sourceName ~= GetRawUnitName("player") then return end

    if actionSlotType == ACTION_SLOT_TYPE_LIGHT_ATTACK then
        if result == ACTION_RESULT_DAMAGE
        or result == ACTION_RESULT_CRITICAL_DAMAGE
        or result == ACTION_RESULT_HEAL
        or result == ACTION_RESULT_CRITICAL_HEAL
        or result == ACTION_RESULT_BLOCKED
        or result == ACTION_RESULT_DODGED
        or result == ACTION_RESULT_ABSORBED then

            local laTime = GetFrameTimeMilliseconds()
            local actions = self.weave.actions

            -- Ranged LA damage can arrive after the next skill is already
            -- pressed. If it falls inside the grace window of a recent
            -- interval, correct that history entry instead of counting it
            -- as a miss.
            for i = #actions, 1, -1 do
                local entry = actions[i]
                if entry.windowStart and entry.windowEnd then
                    if laTime > entry.windowStart
                        and laTime <= entry.windowEnd + self.weave.laGraceMs then
                        if entry.laMissed then
                            entry.laMissed = false
                            self:UpdateWeave()
                        end
                        return
                    elseif laTime > entry.windowEnd + self.weave.laGraceMs then
                        break
                    end
                end
            end

            -- If the LA arrived before the next skill, hold it for the
            -- current interval. OnSlotUsed() consumes it on the next skill.
            if self.weave.previousSkillAt and laTime > self.weave.previousSkillAt then
                self.weave.lastLAConfirmed = laTime
            end
        end
    end
end

function Combat:Update()
    -- GCD is continuously animated; weave history is event-driven.
    self:UpdateGCD()
end

function Combat:ApplyLayout()
    if self.gcdFrame then
        self.gcdFrame:SetDimensions(GS.Saved.gcdWidth, GS.Saved.gcdHeight)
        self.gcdFrame:ClearAnchors()
        self.gcdFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, GS.Saved.gcdX, GS.Saved.gcdY)
        if self.gcdFrame and self.gcdProgress then
            self.gcdProgress:SetHeight(math.max(1, GS.Saved.gcdHeight - 4))
        end
        if self.gcdPing then
            self.gcdPing:SetHeight(math.max(1, GS.Saved.gcdHeight - 4))
        end
        if self.gcdFrame and self.gcdBar then
            self.gcdBar:SetDimensions(math.max(1, GS.Saved.gcdWidth - 4), math.max(1, GS.Saved.gcdHeight - 4))
        end
    end

    if self.weaveFrame then
        self.weaveFrame:SetDimensions(GS.Saved.weaveWidth, GS.Saved.weaveHeight)
        self.weaveFrame:ClearAnchors()
        self.weaveFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, GS.Saved.weaveX, GS.Saved.weaveY)
        if self.weaveAverageFrame then
            self.weaveAverageFrame:ClearAnchors()
            self.weaveAverageFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
                GS.Saved.weaveX + GS.Saved.weaveAverageX,
                GS.Saved.weaveY + GS.Saved.weaveAverageY)
            self.weaveAverageFrame:SetMouseEnabled(self.layoutUnlocked)
            self.weaveAverageFrame:SetMovable(self.layoutUnlocked)
            self.weaveAverageFrame:SetHidden(not self.layoutUnlocked)
        end

        local bar = self.weaveBar
        if bar then
            local barHeight = GS.Saved.weaveHeight
            bar:SetDimensions(math.max(1, GS.Saved.weaveWidth - 2), math.max(1, barHeight - 2))
            local innerWidth = math.max(1, GS.Saved.weaveWidth - 4)
            local slotW = innerWidth / self.weave.max
            local slotH = math.max(4, barHeight - 6)
            for i = 1, self.weave.max do
                local slot = self.weaveSlots[i]
                slot:SetDimensions(math.max(1, slotW - 2), slotH)
                slot:ClearAnchors()
                slot:SetAnchor(BOTTOMLEFT, bar, BOTTOMLEFT, 1 + (i-1)*slotW, -1)
                if slot.la then
                    slot.la:SetDimensions(math.min(8, math.max(4, math.floor(slotW * 0.20))), math.max(1, slotH - 2))
                end
            end
        end
    end

    if self.attributesInitialized then
        local attributes = GetControl("GrimSuiteAttributes")
        if attributes then
            attributes:ClearAnchors()
            attributes:SetAnchor(
                CENTER,
                GuiRoot,
                CENTER,
                GS.Saved.attributesX or 0,
                GS.Saved.attributesY or 0
            )
            EnableAttributeDrag(attributes, self.layoutUnlocked)
        end
    end
end

function Combat:CreateSettings()
    local LAM = LibAddonMenu2
    if not LAM and LibStub then
        LAM = LibStub("LibAddonMenu-2.0", true)
    end
    if not LAM then
        d("GrimSuite: LibAddonMenu-2.0 not available; settings unavailable.")
        return
    end

    local panelName = "GrimSuiteSettings"
    LAM:RegisterAddonPanel(panelName, {
        type = "panel",
        name = "GrimSuite",
        displayName = "GrimSuite",
        author = "GrimGrin",
        version = GS.version,
        registerForRefresh = true,
        registerForDefaults = true,
    })

    LAM:RegisterOptionControls(panelName, {
        { type="header", name="UI Layout", width="full" },
        { type="description", text="Unlock the bars to drag them with your mouse. Lock them again when finished.", width="full" },
        { type="checkbox", name="Unlock UI For Mouse Dragging", getFunc=function() return self.layoutUnlocked end, setFunc=function(v) self.layoutUnlocked=v == true; EnableMouseDrag(self.gcdFrame, self.layoutUnlocked); EnableMouseDrag(self.weaveFrame, self.layoutUnlocked); EnableAttributeDrag(GetControl("GrimSuiteAttributes"), self.layoutUnlocked); if self.weaveAverageFrame then self.weaveAverageFrame:SetMouseEnabled(self.layoutUnlocked); self.weaveAverageFrame:SetMovable(self.layoutUnlocked) end; self:ApplyLayout() end, default=false },

        { type="header", name="Player Attribute Bars", width="full" },
        { type="description", text="Move the Health, Magicka, and Stamina pyramid independently of the action bar.", width="full" },
        { type="slider", name="Horizontal Position (X)", min=-1920, max=1920, step=1, getFunc=function() return GS.Saved.attributesX or 0 end, setFunc=function(v) GS.Saved.attributesX=v; self:ApplyLayout() end, default=GS.SV.attributesX, width="full" },
        { type="slider", name="Vertical Position (Y)", min=-1080, max=1080, step=1, getFunc=function() return GS.Saved.attributesY or 0 end, setFunc=function(v) GS.Saved.attributesY=v; self:ApplyLayout() end, default=GS.SV.attributesY, width="full" },
        { type="button", name="Center Horizontally", func=function()
            local attributes = GetControl("GrimSuiteAttributes")
            if attributes then
                local y = GS.Saved.attributesY or 0
                GS.Saved.attributesX = 0
                attributes:ClearAnchors()
                attributes:SetAnchor(CENTER, GuiRoot, CENTER, 0, y)
                self:ApplyLayout()
            end
        end, width="half" },

        { type="header", name="GCD Metronome", width="full" },
        { type="checkbox", name="Show GCD Metronome", getFunc=function() return GS.Saved.showGCD end, setFunc=function(v) GS.Saved.showGCD=v; self:UpdateGCD() end, default=GS.SV.showGCD },
        { type="slider", name="Horizontal Position (X)", min=0, max=3840, step=1, getFunc=function() return GS.Saved.gcdX end, setFunc=function(v) GS.Saved.gcdX=v; self:ApplyLayout() end, default=GS.SV.gcdX, width="full" },
        { type="slider", name="Vertical Position (Y)", min=0, max=2160, step=1, getFunc=function() return GS.Saved.gcdY end, setFunc=function(v) GS.Saved.gcdY=v; self:ApplyLayout() end, default=GS.SV.gcdY, width="full" },
        { type="button", name="Center Horizontally", func=function() CenterControl(self.gcdFrame, true, false, "gcdX", "gcdY") end, width="half" },
        { type="button", name="Center Vertically", func=function() CenterControl(self.gcdFrame, false, true, "gcdX", "gcdY") end, width="half" },
        { type="slider", name="Horizontal Size (Width)", min=100, max=1000, step=1, getFunc=function() return GS.Saved.gcdWidth end, setFunc=function(v) GS.Saved.gcdWidth=v; self:ApplyLayout() end, default=GS.SV.gcdWidth, width="full" },
        { type="slider", name="Vertical Size (Height)", min=8, max=80, step=1, getFunc=function() return GS.Saved.gcdHeight end, setFunc=function(v) GS.Saved.gcdHeight=v; self:ApplyLayout() end, default=GS.SV.gcdHeight, width="full" },

        { type="header", name="Skill Delay History", width="full" },
        { type="checkbox", name="Show Skill Delay History", getFunc=function() return GS.Saved.showWeave end, setFunc=function(v) GS.Saved.showWeave=v; self:UpdateWeave() end, default=GS.SV.showWeave },
        { type="slider", name="Horizontal Position (X)", min=0, max=3840, step=1, getFunc=function() return GS.Saved.weaveX end, setFunc=function(v) GS.Saved.weaveX=v; self:ApplyLayout() end, default=GS.SV.weaveX, width="full" },
        { type="slider", name="Vertical Position (Y)", min=0, max=2160, step=1, getFunc=function() return GS.Saved.weaveY end, setFunc=function(v) GS.Saved.weaveY=v; self:ApplyLayout() end, default=GS.SV.weaveY, width="full" },
        { type="button", name="Center Horizontally", func=function() CenterControl(self.weaveFrame, true, false, "weaveX", "weaveY") end, width="half" },
        { type="button", name="Center Vertically", func=function() CenterControl(self.weaveFrame, false, true, "weaveX", "weaveY") end, width="half" },
        { type="slider", name="Horizontal Size (Width)", min=100, max=1000, step=1, getFunc=function() return GS.Saved.weaveWidth end, setFunc=function(v) GS.Saved.weaveWidth=v; self:ApplyLayout() end, default=GS.SV.weaveWidth, width="full" },
        { type="slider", name="Vertical Size (Height)", min=20, max=100, step=1, getFunc=function() return GS.Saved.weaveHeight end, setFunc=function(v) GS.Saved.weaveHeight=v; self:ApplyLayout() end, default=GS.SV.weaveHeight, width="full" },
        { type="header", name="Average Display", width="full" },
        { type="description", text="Move the 25-action average independently from the delay history bar.", width="full" },
        { type="slider", name="Average Horizontal Position", min=-200, max=1000, step=1, getFunc=function() return GS.Saved.weaveAverageX end, setFunc=function(v) GS.Saved.weaveAverageX=v; self:ApplyLayout() end, default=GS.SV.weaveAverageX, width="full" },
        { type="slider", name="Average Vertical Position", min=-200, max=500, step=1, getFunc=function() return GS.Saved.weaveAverageY end, setFunc=function(v) GS.Saved.weaveAverageY=v; self:ApplyLayout() end, default=GS.SV.weaveAverageY, width="full" },
    })
end

function Combat:Initialize()
    self:CreateAttributes()
    self:CreateGCD()
    self:CreateWeaveBar()
    self:CreateSettings()

    EVENT_MANAGER:RegisterForEvent(GS.name .. "_CombatState", EVENT_PLAYER_COMBAT_STATE, function(...)
        self:OnCombatState(...)
    end)

    -- Hide GrimSuite's custom HUD widgets whenever ESO enters a menu scene.
    -- They are HUD-only: ESC, inventory, map, skills, character sheet, etc.
    -- On returning to the gameplay HUD, restore them and re-assert their
    -- saved positions.
    if SCENE_MANAGER then
        SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(scene, oldState, newState)
            if newState ~= SCENE_SHOWING and newState ~= SCENE_SHOWN then
                return
            end

            local hudScene = (scene == HUD_SCENE or scene == HUD_UI_SCENE)

            if GS.ActionBar and GS.ActionBar.SetHUDVisible then
                GS.ActionBar:SetHUDVisible(hudScene)
            end

            if self.gcdFrame then
                self.gcdFrame:SetHidden(not hudScene)
            end

            if self.weaveFrame then
                self.weaveFrame:SetHidden(not hudScene or not GS.Saved.showWeave)
            end

            if self.weaveAverageFrame then
                self.weaveAverageFrame:SetHidden(not hudScene or not GS.Saved.showWeave)
            end

            local attributes = GetControl("GrimSuiteAttributes")
            if attributes then
                attributes:SetHidden(not hudScene)
            end

            if hudScene then
                if self.gcdFrame then
                    self.gcdFrame:SetHidden(not GS.Saved.showGCD)
                end
                ScheduleLayoutRepair()
            end
        end)
    end

    -- Player activation is also a native UI rebuild point.  Repair after ESO
    -- has finished constructing the HUD rather than relying on /reloadui.
    EVENT_MANAGER:RegisterForEvent(GS.name .. "_CombatActivated", EVENT_PLAYER_ACTIVATED, function()
        zo_callLater(function()
            if self.initialized then
                self:ApplyLayout()
            end
        end, 100)
    end)

    EVENT_MANAGER:RegisterForEvent(GS.name .. "_SlotUsed", EVENT_ACTION_SLOT_ABILITY_USED, function(...)
        self:OnSlotUsed(...)
    end)

    EVENT_MANAGER:RegisterForEvent(GS.name .. "_CombatEvent", EVENT_COMBAT_EVENT, function(...)
        self:OnCombatEvent(...)
    end)
    EVENT_MANAGER:AddFilterForEvent(
        GS.name .. "_CombatEvent",
        EVENT_COMBAT_EVENT,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,
        COMBAT_UNIT_TYPE_PLAYER
    )

    EVENT_MANAGER:RegisterForUpdate(GS.name .. "_Update", 1000 / 60, function()
        self:Update()
    end)

    SLASH_COMMANDS["/grimsuite"] = function(cmd)
        cmd = string.lower(cmd or "")
        if cmd == "gcd" then
            GS.Saved.showGCD = not GS.Saved.showGCD
            d("GrimSuite GCD: " .. tostring(GS.Saved.showGCD))
        elseif cmd == "weave" then
            GS.Saved.showWeave = not GS.Saved.showWeave
            d("GrimSuite WeaveDelays: " .. tostring(GS.Saved.showWeave))
        elseif cmd == "attrs" then
            self.layoutUnlocked = not self.layoutUnlocked
            EnableMouseDrag(self.gcdFrame, self.layoutUnlocked)
            EnableMouseDrag(self.weaveFrame, self.layoutUnlocked)
            EnableAttributeDrag(GetControl("GrimSuiteAttributes"), self.layoutUnlocked)
            if self.weaveAverageFrame then
                self.weaveAverageFrame:SetMouseEnabled(self.layoutUnlocked)
                self.weaveAverageFrame:SetMovable(self.layoutUnlocked)
                self.weaveAverageFrame:SetHidden(not self.layoutUnlocked)
            end
            d("GrimSuite UI dragging: " .. tostring(self.layoutUnlocked))
        elseif cmd == "reset" then
            self.weave.actions = {}
            self.weave.pendingLA = nil
            self.weave.previousSkillAt = nil
            self.weave.previousSkillEnd = nil
            self.weave.lastLAConfirmed = nil
            self.gcdIdle = nil
            self.weave.averageSum = 0
            self.weave.averageCount = 0
            self.weave.averagePending = {}
            self:UpdateWeave()
        else
            d("/grimsuite gcd - toggle GCD metronome")
            d("/grimsuite weave - toggle WeaveDelays")
            d("/grimsuite attrs - toggle UI dragging")
            d("/grimsuite reset - clear weave history")
        end
    end

    self:Update()
    d("GrimSuite Combat 0.0.24Dev loaded: GCD + skill delay + static LA status + layout menu")
end
