
local NAME = 'AltAttributes'
local SV_VER = 7

local defaults = {
    width = 360,
    gamepadHeight = 96,
    keyboardHeight = 32,
    gamepadOffsetY = -80,
    keyboardOffsetY = -50,
    barGap = 5,
    healthX = 0,
    healthY = 0,
    magickaX = 0,
    magickaY = 0,
    staminaX = 0,
    staminaY = 0,
    scale = 1.0,
    alpha = 1.0,
    fontSize = 28,
    fontBold = false,
    valueTextY = 0,
    textMode = "current_percent",
    showPercent = true,
    percentDisplayMode = "edge",
    showShield = true,
    showHealingAbsorption = true,
    shieldValueFormat = "exact",
    healingAbsorptionValueFormat = "exact",
    absolutePositionV2 = false,
    positionBindingFixV3 = false,
    showFrame = true,
    showBackground = true,
    visibilityMode = "always",
    useCustomColors = false,
    barShape = "alternative",
    healthColor = {0.70, 0.08, 0.08, 1},
    magickaColor = {0.08, 0.30, 0.85, 1},
    staminaColor = {0.08, 0.65, 0.36, 1},
    shieldColor = {1.00, 0.49, 0.13, 0.65},
}

local saved
local refreshLayout
local refreshVisibility

local function GetAttributeFont(size)
    local fontToken = (saved and saved.fontBold) and '$(GAMEPAD_BOLD_FONT)' or '$(GAMEPAD_LIGHT_FONT)'
    return fontToken .. '|' .. tostring(zo_round(size)) .. '|soft-shadow-thick'
end

local function FormatExactNumber(value)
    return ZO_CommaDelimitNumber(zo_round(value or 0))
end

local function FormatEffectNumber(value, mode)
    value = math.abs(tonumber(value) or 0)
    if mode == "abbreviated" then
        return ZO_AbbreviateAndLocalizeNumber(value, NUMBER_ABBREVIATION_PRECISION_TENTHS, false)
    end
    return FormatExactNumber(value)
end

local function GetResourceColor(powerType)
    if not saved then return nil end
    if powerType == COMBAT_MECHANIC_FLAGS_HEALTH then return saved.healthColor end
    if powerType == COMBAT_MECHANIC_FLAGS_MAGICKA then return saved.magickaColor end
    if powerType == COMBAT_MECHANIC_FLAGS_STAMINA then return saved.staminaColor end
end

-- Basegame style uses ESO's real player attribute controls. This guarantees
-- the exact current Gamepad frame, border, end caps and platform textures
-- instead of approximating them with pieces of the Alternative template.
local function IsNativeBasegameStyle()
    return saved and saved.barShape == "basegame"
end

local function SetNativeAttributeBarsHidden(hidden)
    if ZO_PlayerAttributeHealth then ZO_PlayerAttributeHealth:SetHidden(hidden) end
    if ZO_PlayerAttributeMagicka then ZO_PlayerAttributeMagicka:SetHidden(hidden) end
    if ZO_PlayerAttributeStamina then ZO_PlayerAttributeStamina:SetHidden(hidden) end
end

-- Native ESO attribute controls include their own amount/percentage labels.
-- AltAttributes already renders the configurable resource text as an overlay,
-- so native labels are always suppressed in Basegame style to avoid duplicates.
local function HideNativeLabelsRecursive(control)
    if not control then return end
    local childCount = control:GetNumChildren() or 0
    for i = 1, childCount do
        local child = control:GetChild(i)
        if child then
            if child:GetType() == CT_LABEL then
                child:SetHidden(true)
            else
                HideNativeLabelsRecursive(child)
            end
        end
    end
end

local function LockNativeBarWidth(control, width)
    if not control or not width then return end

    -- ESO recalculates attribute-frame geometry when max stats change (food,
    -- buffs, debuffs, etc.). Hard min/max constraints prevent those updates
    -- from growing the frame beyond the user-selected AltAttributes width.
    control:SetDimensionConstraints(width, 0, width, 1000)
    control:SetWidth(width)

    local bg = GetControl(control, "BgContainer")
    if bg then
        bg:SetWidth(width)
        local left = GetControl(bg, "BgLeft")
        local center = GetControl(bg, "BgCenter")
        local right = GetControl(bg, "BgRight")
        local leftWidth = left and left:GetWidth() or 16
        local rightWidth = right and right:GetWidth() or 16
        if center then center:SetWidth(zo_max(1, width - leftWidth - rightWidth)) end
    end

    HideNativeLabelsRecursive(control)
end

local function EnforceNativeBarWidths()
    if not IsNativeBasegameStyle() or not saved then return end
    LockNativeBarWidth(ZO_PlayerAttributeHealth, saved.width)
    LockNativeBarWidth(ZO_PlayerAttributeMagicka, saved.width)
    LockNativeBarWidth(ZO_PlayerAttributeStamina, saved.width)
end


local function getWidth()
    return zo_clamp(GuiRoot:GetWidth() * .25, 300, 600)
end
-------------------------------------
--Base bar--
-------------------------------------
local StandardBar = ZO_Object:Subclass()
function StandardBar:New(...)
    local bar = ZO_Object.New(self)
    bar:Initialize(...)
    return bar
end

function StandardBar:Initialize(unitTag, powerType, topLevelCtrl)
    self.unitTag = unitTag
    self.powerType = powerType
    self.control = CreateControlFromVirtual("ALTATTR_Frame"..unitTag..powerType, topLevelCtrl, "ALTATTR_Bar")
    self.control:SetHidden(true)
    self.attrText = GetControl(self.control, "Text")
    self.attrTextPercent = GetControl(self.control, "Percent")
    self.attrBar = GetControl(self.control, "Bar")

    ZO_StatusBar_SetGradientColor(self.attrBar, ZO_POWER_BAR_GRADIENT_COLORS[powerType])

    local function PowerUpdateHandlerFunction(unitTag, powerPoolIndex, powerType, powerPool, powerPoolMax)
        self:OnPowerUpdate(powerPool, powerPoolMax, false)
    end
    local powerUpdateEventHandler = ZO_MostRecentPowerUpdateHandler:New("ALTATTR_Bar"..unitTag..powerType, PowerUpdateHandlerFunction)
    powerUpdateEventHandler:AddFilterForEvent(REGISTER_FILTER_POWER_TYPE, powerType)
    powerUpdateEventHandler:AddFilterForEvent(REGISTER_FILTER_UNIT_TAG, unitTag)
    --self.control:RegisterForEvent(EVENT_PLAYER_ACTIVATED, function() self:UpdateWidth() end)
    --self.control:RegisterForEvent(EVENT_SCREEN_RESIZED, function() self:UpdateWidth() end)
    self.control:RegisterForEvent(EVENT_PLAYER_ALIVE, function() self:Refresh() end)

    self:Refresh(true)
end

function StandardBar:Refresh(force)
    if force then
        self:ApplyStyle()
    end

    local power, maxPower = GetUnitPower(self.unitTag, self.powerType)
    self:OnPowerUpdate(power, maxPower, force)
end

function StandardBar:FormatPercent(health, maxHealth)
    local percent = 0
    local percentText
    if maxHealth ~= 0 then
        percent = (health / maxHealth) * 100
    end
    if percent < 10 then
        percentText = ZO_CommaDelimitDecimalNumber(zo_roundToNearest(percent, .1))
        percentText = ZO_FastFormatDecimalNumber(percentText)
    else
        percentText = zo_round(percent)
    end

    return percentText..'%'
end

function StandardBar:OnPowerUpdate(health, maxHealth, force)
    ZO_StatusBar_SmoothTransition(self.attrBar, health, maxHealth, force)

    self:UpdateResourceNumbers(health, maxHealth)
end

function StandardBar:UpdateResourceNumbers(health, maxHealth)
    local mode = saved and saved.textMode or "current_percent"
    local percent = self:FormatPercent(health, maxHealth)
    local current = FormatExactNumber(health)
    local maximum = FormatExactNumber(maxHealth)
    local percentMode = (saved and saved.percentDisplayMode) or ((saved and saved.showPercent) and "edge" or "off")

    if mode == "none" then
        self.attrText:SetText("")
    elseif mode == "current" then
        self.attrText:SetText(current)
    elseif mode == "current_max" then
        self.attrText:SetText(string.format("%s / %s", current, maximum))
    elseif mode == "current_max_percent" then
        self.attrText:SetText(string.format("%s / %s (%s)", current, maximum, percent))
    elseif mode == "abbreviated" then
        self.attrText:SetText(ZO_AbbreviateAndLocalizeNumber(health, NUMBER_ABBREVIATION_PRECISION_TENTHS, false))
    else
        self.attrText:SetText(current)
    end

    -- "On Edge" deliberately keeps the original Alternative Attribute Bars
    -- percentage-label behavior unchanged. "After Value" is appended after
    -- the complete value string (including shield/healing absorption below).
    self.attrTextPercent:SetHidden(percentMode ~= "edge" or mode == "current_max_percent" or mode == "none")
    self.attrTextPercent:SetText(percent)

    if percentMode == "after_value" and mode ~= "current_max_percent" and mode ~= "none" then
        self.attrText:SetText(string.format("%s (%s)", self.attrText:GetText(), percent))
    end
end

function StandardBar:ApplyStyle()
    local basegame = saved and saved.barShape == "basegame"

    -- Apply the container template FIRST. Applying it last can restore the
    -- virtual ALTATTR child templates and overwrite the selected ESO end caps.
    ApplyTemplateToControl(self.control, ZO_GetPlatformTemplate("ALTATTR_Bar"))
    ApplyTemplateToControl(self.attrBar, ZO_GetPlatformTemplate("ZO_PlayerAttributeStatusBar"))

    -- Stamina / standard direction: ESO Basegame = normal framed outer end cap.
    -- Alternative Attribute Bars = arrow-shaped outer end cap.
    ApplyTemplateToControl(self.control:GetNamedChild("FrameLeft"), ZO_GetPlatformTemplate("ZO_PlayerAttributeFrameLeft"))
    ApplyTemplateToControl(self.control:GetNamedChild("FrameRight"), ZO_GetPlatformTemplate(basegame and "ZO_PlayerAttributeFrameRight" or "ZO_PlayerAttributeFrameRightArrow"))
    ApplyTemplateToControl(self.control:GetNamedChild("FrameCenter"), ZO_GetPlatformTemplate("ZO_PlayerAttributeFrameCenter"))

    ApplyTemplateToControl(self.control:GetNamedChild("BgContainerBgLeft"), ZO_GetPlatformTemplate("ZO_PlayerAttributeBgLeft"))
    ApplyTemplateToControl(self.control:GetNamedChild("BgContainerBgRight"), ZO_GetPlatformTemplate(basegame and "ZO_PlayerAttributeBgRight" or "ZO_PlayerAttributeBgRightArrow"))
    ApplyTemplateToControl(self.control:GetNamedChild("BgContainerBgCenter"), ZO_GetPlatformTemplate("ZO_PlayerAttributeBgCenter"))
end

function StandardBar:SetWidth(value)
    self.control:SetWidth(value)
end

function StandardBar:SetHeight(value)
    local prevHeight = self.attrBar:GetHeight()
    if prevHeight ~= value then
        local mod = value / prevHeight
        local frameLeft = GetControl(self.control, "FrameLeft")
        local frameRight = GetControl(self.control, "FrameRight")
        local bgLeft = GetControl(self.control, "BgContainerBgLeft")
        local bgRight = GetControl(self.control, "BgContainerBgRight")
        frameLeft:SetWidth(zo_round(frameLeft:GetWidth() * mod) - 3)
        frameRight:SetWidth(zo_round(frameRight:GetWidth() * mod) - 3)
        bgLeft:SetWidth(zo_round(bgLeft:GetWidth() * mod) - 3)
        bgRight:SetWidth(zo_round(bgRight:GetWidth() * mod) - 3)

        self.control:SetHeight(value)
        self.attrBar:SetHeight(value)

        frameLeft:SetHeight(value)
        frameRight:SetHeight(value)
        bgLeft:SetHeight(value)
        bgRight:SetHeight(value)
        GetControl(self.control, "FrameCenter"):SetHeight(value)
        GetControl(self.control, "BgContainerBgCenter"):SetHeight(value)

        local fontMod = IsInGamepadPreferredMode() and 1 / 3 or 2 / 3
        local font = GetAttributeFont(value * fontMod)
        self.attrText:SetFont(font)
        self.attrTextPercent:SetFont(font)
    end
end

function StandardBar:ApplyCustomAppearance()
    if not saved then return end
    self.control:SetScale(saved.scale)
    self.control:SetAlpha(saved.alpha)

    if saved.useCustomColors then
        local color = GetResourceColor(self.powerType)
        if color then self.attrBar:SetColor(color[1], color[2], color[3], color[4] or 1) end
    else
        -- Restore ESO's native resource gradient colors.
        ZO_StatusBar_SetGradientColor(self.attrBar, ZO_POWER_BAR_GRADIENT_COLORS[self.powerType])
    end

    local nativeBasegame = IsNativeBasegameStyle()
    -- In native Basegame mode the real ESO control supplies every visual piece.
    -- Keep this add-on control only as the independent positioning/text overlay.
    self.attrBar:SetHidden(nativeBasegame)
    local frameNames = {"FrameLeft", "FrameRight", "FrameCenter"}
    for _, name in ipairs(frameNames) do GetControl(self.control, name):SetHidden(nativeBasegame or not saved.showFrame) end
    local bgNames = {"BgContainerBgLeft", "BgContainerBgRight", "BgContainerBgCenter"}
    for _, name in ipairs(bgNames) do GetControl(self.control, name):SetHidden(nativeBasegame or not saved.showBackground) end

    local font = GetAttributeFont(saved.fontSize)
    self.attrText:SetFont(font)
    self.attrTextPercent:SetFont(font)

    -- Optional vertical offset for the complete main value text. This moves
    -- the resource value and anything appended to it (shield/healing
    -- absorption and After Value percent) together. The On Edge percent
    -- label intentionally keeps its original Alternative Attributes position.
    self.attrText:ClearAnchors()
    local baseTextY = IsInGamepadPreferredMode() and 2 or -1
    self.attrText:SetAnchor(CENTER, self.control, CENTER, 0, baseTextY + (saved.valueTextY or 0))

    self:Refresh(false)
end

function StandardBar:Show()
    self.control:SetHidden(false)
end

function StandardBar:Hide()
    self.control:SetHidden(true)
end
-------------------------------------
--Reversed bar--
-------------------------------------
local ReversedBar = StandardBar:Subclass()
function ReversedBar:New(...)
    return StandardBar.New(self, ...)
end

function ReversedBar:ApplyStyle()
    local basegame = saved and saved.barShape == "basegame"

    ApplyTemplateToControl(self.control, ZO_GetPlatformTemplate("ALTATTR_BarReversed"))
    ApplyTemplateToControl(self.attrBar, ZO_GetPlatformTemplate("ZO_PlayerAttributeStatusBar"))

    -- Magicka / reversed direction mirrors Stamina. Basegame uses ESO's
    -- complete normal frame; Alternative uses the arrow-shaped outer end.
    ApplyTemplateToControl(self.control:GetNamedChild("FrameLeft"), ZO_GetPlatformTemplate(basegame and "ZO_PlayerAttributeFrameLeft" or "ZO_PlayerAttributeFrameLeftArrow"))
    ApplyTemplateToControl(self.control:GetNamedChild("FrameRight"), ZO_GetPlatformTemplate("ZO_PlayerAttributeFrameRight"))
    ApplyTemplateToControl(self.control:GetNamedChild("FrameCenter"), ZO_GetPlatformTemplate("ZO_PlayerAttributeFrameCenter"))

    ApplyTemplateToControl(self.control:GetNamedChild("BgContainerBgLeft"), ZO_GetPlatformTemplate(basegame and "ZO_PlayerAttributeBgLeft" or "ZO_PlayerAttributeBgLeftArrow"))
    ApplyTemplateToControl(self.control:GetNamedChild("BgContainerBgRight"), ZO_GetPlatformTemplate("ZO_PlayerAttributeBgRight"))
    ApplyTemplateToControl(self.control:GetNamedChild("BgContainerBgCenter"), ZO_GetPlatformTemplate("ZO_PlayerAttributeBgCenter"))
end
-------------------------------------
--HP shielded bar --
-------------------------------------
local ShieldedBar = StandardBar:Subclass()
function ShieldedBar:New(...)
    return StandardBar.New(self, ...)
end

function ShieldedBar:Initialize(unitTag, powerType, topLevelCtrl)
    self.curShield = 0
    self.curTrauma = 0
    self.curHP = 0
    self.maxHP = 0

    StandardBar.Initialize(self, unitTag, powerType, topLevelCtrl)

    self.shieldBar = CreateControlFromVirtual("ALTATTR_Shield"..unitTag..powerType, self.attrBar, "ALTATTR_ShieldBar")
    local c = (saved and saved.shieldColor) or {1, 0.49, 0.13, 0.65}
    self.shieldBar:SetColor(c[1], c[2], c[3], c[4] or 0.65)
    self.shieldBar:SetHeight(self.control:GetHeight())
    self:OnUpdateShield(0, true)

    -- Initialize healing absorption (ESO calls this visual "Trauma").
    -- GetUnitAttributeVisualizerEffectInfo can return nil when no effect is active.
    local initialTrauma = GetUnitAttributeVisualizerEffectInfo(
        unitTag, ATTRIBUTE_VISUAL_TRAUMA, STAT_MITIGATION, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH
    )
    self.curTrauma = math.abs(tonumber(initialTrauma) or 0)

    local function onVisualPower(_, unitTag, unitAttributeVisual, statType, attributeType, powerType, oldValue, newValue, oldMaxValue, newMaxValue)
        local value = oldMaxValue == nil and oldValue or newValue
        if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
            self:OnUpdateShield(value, false)
        elseif unitAttributeVisual == ATTRIBUTE_VISUAL_TRAUMA then
            self:OnUpdateTrauma(value, false)
        end
    end

    local function onVisualPowerRemoved(_, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
        if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
            self:OnUpdateShield(0, false)
        elseif unitAttributeVisual == ATTRIBUTE_VISUAL_TRAUMA then
            self:OnUpdateTrauma(0, false)
        end
    end

    topLevelCtrl:RegisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, onVisualPower)
    topLevelCtrl:AddFilterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, REGISTER_FILTER_UNIT_TAG, unitTag)
    topLevelCtrl:RegisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, onVisualPower)
    topLevelCtrl:AddFilterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, REGISTER_FILTER_UNIT_TAG, unitTag)
    topLevelCtrl:RegisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, onVisualPowerRemoved)
    topLevelCtrl:AddFilterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, REGISTER_FILTER_UNIT_TAG, unitTag)
end

function ShieldedBar:OnPowerUpdate(health, maxHealth, force)
    self.curHP = health
    self.maxHP = maxHealth
    ZO_StatusBar_SmoothTransition(self.attrBar, health, maxHealth, force)
    self:UpdateResourceNumbers(self.curHP, self.maxHP, self.curShield, self.curTrauma)
end

function ShieldedBar:OnUpdateShield(shield, force)
    self.curShield = shield
    self.shieldBar:SetHidden(saved and not saved.showShield)
    ZO_StatusBar_SmoothTransition(self.shieldBar, (saved and saved.showShield) and shield or 0, self.maxHP, force)
    self:UpdateResourceNumbers(self.curHP, self.maxHP, self.curShield, self.curTrauma)
end

function ShieldedBar:OnUpdateTrauma(trauma, force)
    self.curTrauma = math.abs(tonumber(trauma) or 0)
    self:UpdateResourceNumbers(self.curHP, self.maxHP, self.curShield, self.curTrauma)
end

function ShieldedBar:UpdateResourceNumbers(health, maxHealth, shield, trauma)
    StandardBar.UpdateResourceNumbers(self, health, maxHealth)
    if not saved or saved.textMode == "none" then return end

    local percentMode = saved.percentDisplayMode or (saved.showPercent and "edge" or "off")
    local percent = self:FormatPercent(health, maxHealth)
    local base = self.attrText:GetText()
    -- StandardBar already appends After Value. Remove it temporarily so the
    -- shield/healing-absorption value can be inserted before the percentage.
    if percentMode == "after_value" and saved.textMode ~= "current_max_percent" then
        local suffix = string.format(" (%s)", percent)
        if string.sub(base, -string.len(suffix)) == suffix then
            base = string.sub(base, 1, string.len(base) - string.len(suffix))
        end
    end

    local traumaValue = math.abs(tonumber(trauma) or 0)
    local shieldValue = math.abs(tonumber(shield) or 0)

    -- Healing absorption has priority over a damage shield when both are active.
    -- Keep spaces on both sides of + / - and do not wrap the effect in brackets.
    if saved.showHealingAbsorption and traumaValue > 0 then
        base = string.format("%s - %s", base, FormatEffectNumber(traumaValue, saved.healingAbsorptionValueFormat))
    elseif saved.showShield and shieldValue > 0 then
        base = string.format("%s + %s", base, FormatEffectNumber(shieldValue, saved.shieldValueFormat))
    end

    if percentMode == "after_value" and saved.textMode ~= "current_max_percent" then
        base = string.format("%s (%s)", base, percent)
    end
    self.attrText:SetText(base)
end

function ShieldedBar:ApplyCustomAppearance()
    StandardBar.ApplyCustomAppearance(self)
    if self.shieldBar and saved then
        local c = saved.shieldColor
        self.shieldBar:SetColor(c[1], c[2], c[3], c[4] or 0.65)
        self.shieldBar:SetHidden(IsNativeBasegameStyle() or not saved.showShield)
    end
end

function ShieldedBar:ApplyStyle()
    StandardBar.ApplyStyle(self)
    if self.shieldBar then
        ApplyTemplateToControl(self.shieldBar, ZO_GetPlatformTemplate("ZO_PlayerAttributeStatusBar"))
    end
end

function ShieldedBar:SetHeight(value)
    StandardBar.SetHeight(self, value)
    if self.shieldBar then
        if self.shieldBar:GetHeight() ~= value then
            self.shieldBar:SetHeight(value)
        end
    end
end
-------------------------------------
-- --
-------------------------------------

ALTATTR_FakeGloss = ZO_Object:Subclass()
function ALTATTR_FakeGloss:New()
    return ZO_Object.New(self)
end
function ALTATTR_FakeGloss:SetMinMax() end
function ALTATTR_FakeGloss:SetValue() end

function AltAttributes_Initialize(topLevelCtrl)

    local function OnAddOnLoaded(_, addonName)
        if addonName == NAME then

            local function updateDefaultAttributeBars()
                -- Alternative mode replaces ESO's controls. Basegame mode deliberately
                -- shows the real controls so the frame/border is pixel-identical to ESO.
                SetNativeAttributeBarsHidden(not IsNativeBasegameStyle())
            end

            -- Initialize settings first. 1.3 created the bars before SavedVariables
            -- existed; a later layout refresh could therefore abort initialization.
            saved = ZO_SavedVars:NewAccountWide("AltAttributesSavedVariables", SV_VER, nil, defaults)

            -- 2.4: convert the old offset-based coordinates once into absolute
            -- coordinates relative to the AltAttributes container. This preserves
            -- the existing on-screen layout while preventing reloads from
            -- re-applying hidden left/right base offsets.
            if not saved.absolutePositionV2 then
                local halfW = saved.width / 2
                saved.healthX = saved.healthX
                saved.healthY = -36 + saved.healthY
                saved.magickaX = -(halfW + saved.barGap) + saved.magickaX
                saved.magickaY = (saved.gamepadHeight - 80) + saved.magickaY
                saved.staminaX = (halfW + saved.barGap) + saved.staminaX
                saved.staminaY = (saved.gamepadHeight - 80) + saved.staminaY
                saved.absolutePositionV2 = true
            end

            -- 2.4.1: 2.4 could persist the lower resource coordinates against the
            -- opposite native container after a reload. Correct those existing 2.4
            -- SavedVariables once, then keep Magicka and Stamina permanently bound
            -- to their own coordinates. No position-based reassignment is used.
            if not saved.positionBindingFixV3 then
                saved.magickaX, saved.staminaX = saved.staminaX, saved.magickaX
                saved.magickaY, saved.staminaY = saved.staminaY, saved.magickaY
                saved.positionBindingFixV3 = true
            end

            updateDefaultAttributeBars()

            altBarHP = ShieldedBar:New("player", COMBAT_MECHANIC_FLAGS_HEALTH, topLevelCtrl)
            altBarHP:Show()

            altBarMP = ReversedBar:New("player", COMBAT_MECHANIC_FLAGS_MAGICKA, topLevelCtrl)
            altBarMP:Show()

            altBarSP = StandardBar:New("player", COMBAT_MECHANIC_FLAGS_STAMINA, topLevelCtrl)
            altBarSP:Show()

            local function rePosition()
                topLevelCtrl:ClearAnchors()
                if IsInGamepadPreferredMode() then
                    topLevelCtrl:SetAnchor(BOTTOM, ZO_ActionBar1, TOP, 0, saved.gamepadOffsetY)
                else
                    topLevelCtrl:SetAnchor(BOTTOM, ZO_ActionBar1, TOP, 0, saved.keyboardOffsetY)
                end
            end

            local function rePositionDefaultBars()
                ZO_PlayerAttributeSiegeHealth:ClearAnchors()
                ZO_PlayerAttributeWerewolf:ClearAnchors()
                ZO_PlayerAttributeMountStamina:ClearAnchors()
                if IsInGamepadPreferredMode() then
                    ZO_PlayerAttributeSiegeHealth:SetAnchor(TOPLEFT, altBarHP.control, BOTTOMLEFT, 0, -25)
                    ZO_PlayerAttributeWerewolf:SetAnchor(TOPRIGHT, altBarMP.control, BOTTOMRIGHT, 0, -25)
                    ZO_PlayerAttributeMountStamina:SetAnchor(TOPLEFT, altBarSP.control, BOTTOMLEFT, 0, -25)
                else
                    ZO_PlayerAttributeSiegeHealth:SetAnchor(TOPLEFT, altBarHP.control, BOTTOMLEFT, 0, -1)
                    ZO_PlayerAttributeWerewolf:SetAnchor(TOPRIGHT, altBarMP.control, BOTTOMRIGHT, 0, -1)
                    ZO_PlayerAttributeMountStamina:SetAnchor(TOPLEFT, altBarSP.control, BOTTOMLEFT, 0, -1)
                end

            end

            local function applyStyles()
                local bars = {altBarHP, altBarMP, altBarSP}
                for _, bar in pairs(bars) do
                    bar:ApplyStyle()
                    bar:SetWidth(saved.width)
                    bar:SetHeight(IsInGamepadPreferredMode() and saved.gamepadHeight or saved.keyboardHeight)
                    bar:ApplyCustomAppearance()
                end
                altBarHP.control:ClearAnchors()
                altBarMP.control:ClearAnchors()
                altBarSP.control:ClearAnchors()
                -- Absolute independent coordinates. No hidden Magicka/Stamina
                -- left/right base offset is added here, so /reloadui restores the
                -- exact same positions the user configured.
                altBarHP.control:SetAnchor(TOP, topLevelCtrl, TOP, saved.healthX, saved.healthY)
                altBarMP.control:SetAnchor(TOP, topLevelCtrl, TOP, saved.magickaX, saved.magickaY)
                altBarSP.control:SetAnchor(TOP, topLevelCtrl, TOP, saved.staminaX, saved.staminaY)
                -- Native ESO style: move the actual ESO controls to exactly the same
                -- independent anchors as our overlays. Their own child textures keep the
                -- genuine Gamepad border/end-cap geometry from the current game build.
                if IsNativeBasegameStyle() then
                    -- 2.4.2: Explicit permanent one-to-one native container binding.
                    -- Health, Magicka and Stamina each follow only their own overlay;
                    -- no resource can inherit another resource's saved position.
                    local native = {
                        { ctrl = ZO_PlayerAttributeHealth,  overlay = altBarHP.control },
                        { ctrl = ZO_PlayerAttributeMagicka, overlay = altBarMP.control },
                        { ctrl = ZO_PlayerAttributeStamina, overlay = altBarSP.control },
                    }
                    for _, binding in ipairs(native) do
                        local ctrl, overlay = binding.ctrl, binding.overlay
                        if ctrl and overlay then
                            ctrl:ClearAnchors()
                            ctrl:SetAnchor(CENTER, overlay, CENTER, 0, 0)
                            LockNativeBarWidth(ctrl, saved.width)
                            ctrl:SetScale(saved.scale)
                            ctrl:SetAlpha(saved.alpha)
                        end
                    end
                end
                updateDefaultAttributeBars()
                if not Azurah then
                    rePosition()
                end
                rePositionDefaultBars()
            end

            -- 2.7: ESO's Gamepad HUD manager may re-anchor the three native
            -- attribute controls after addon initialization (including after /reloadui).
            -- Keep the genuine Basegame controls, but re-assert our one-to-one anchors
            -- after ESO has had a chance to perform its own layout pass.
            local function lockNativeAttributeAnchors()
                if not IsNativeBasegameStyle() then return end
                local native = {
                    { ctrl = ZO_PlayerAttributeHealth,  overlay = altBarHP and altBarHP.control },
                    { ctrl = ZO_PlayerAttributeMagicka, overlay = altBarMP and altBarMP.control },
                    { ctrl = ZO_PlayerAttributeStamina, overlay = altBarSP and altBarSP.control },
                }
                for _, binding in ipairs(native) do
                    local ctrl, overlay = binding.ctrl, binding.overlay
                    if ctrl and overlay then
                        ctrl:ClearAnchors()
                        ctrl:SetAnchor(CENTER, overlay, CENTER, 0, 0)
                        LockNativeBarWidth(ctrl, saved.width)
                        ctrl:SetScale(saved.scale)
                        ctrl:SetAlpha(saved.alpha)
                        ctrl:SetHidden(false)
                    end
                end
            end

            local function queueNativeAnchorLock()
                zo_callLater(lockNativeAttributeAnchors, 0)
                zo_callLater(lockNativeAttributeAnchors, 100)
                zo_callLater(lockNativeAttributeAnchors, 500)
                zo_callLater(lockNativeAttributeAnchors, 1500)
            end

            refreshLayout = function()
                applyStyles()
                if Azurah then
                    -- Azurah owns the outer AltAttributes container position when installed.
                else
                    rePosition()
                end
                queueNativeAnchorLock()
            end

            -- A lightweight guard catches later Gamepad HUD layout passes without
            -- replacing or cloning any Basegame frame.
            EVENT_MANAGER:RegisterForUpdate(NAME .. "NativeAnchorLock", 500, lockNativeAttributeAnchors)
            queueNativeAnchorLock()

            local function UpdateVisibility()
                local mode = saved.visibilityMode
                local inCombat = IsUnitInCombat("player")
                local function shouldShow(bar)
                    if mode == "combat" then return inCombat end
                    if mode == "dynamic" then
                        local cur, maxv = GetUnitPower("player", bar.powerType)
                        return inCombat or (maxv > 0 and cur < maxv)
                    end
                    return true
                end
                local showHP = shouldShow(altBarHP)
                local showMP = shouldShow(altBarMP)
                local showSP = shouldShow(altBarSP)
                altBarHP.control:SetHidden(not showHP)
                altBarMP.control:SetHidden(not showMP)
                altBarSP.control:SetHidden(not showSP)
                if IsNativeBasegameStyle() then
                    if ZO_PlayerAttributeHealth then ZO_PlayerAttributeHealth:SetHidden(not showHP) end
                    if ZO_PlayerAttributeMagicka then ZO_PlayerAttributeMagicka:SetHidden(not showMP) end
                    if ZO_PlayerAttributeStamina then ZO_PlayerAttributeStamina:SetHidden(not showSP) end
                end
            end
            refreshVisibility = UpdateVisibility
            EVENT_MANAGER:RegisterForEvent(NAME .. "Combat", EVENT_PLAYER_COMBAT_STATE, UpdateVisibility)
            EVENT_MANAGER:RegisterForEvent(NAME .. "VisibilityPower", EVENT_POWER_UPDATE, UpdateVisibility)
            EVENT_MANAGER:AddFilterForEvent(NAME .. "VisibilityPower", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")

            -- Width guard adapted from NormalAttributeFrames_CONSOLE_1.0.0.
            -- The base game can rewrite the native frame width after maximum
            -- resource changes. Reassert only width/background sizing; anchors
            -- and the user's independent X/Y positions are never touched here.
            EVENT_MANAGER:RegisterForEvent(NAME .. "NativeWidthStats", EVENT_STATS_UPDATED, EnforceNativeBarWidths)
            EVENT_MANAGER:RegisterForEvent(NAME .. "NativeWidthPower", EVENT_POWER_UPDATE, function(_, unitTag)
                if unitTag == "player" then EnforceNativeBarWidths() end
            end)
            EVENT_MANAGER:AddFilterForEvent(NAME .. "NativeWidthPower", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
            EVENT_MANAGER:RegisterForEvent(NAME .. "NativeWidthActivated", EVENT_PLAYER_ACTIVATED, EnforceNativeBarWidths)

            local widthGuard = WINDOW_MANAGER:CreateControl(NAME .. "_NativeWidthGuard", GuiRoot, CT_CONTROL)
            widthGuard:SetHandler("OnUpdate", function(control, elapsed)
                control._elapsed = (control._elapsed or 0) + elapsed
                if control._elapsed >= 0.03 then
                    control._elapsed = 0
                    EnforceNativeBarWidths()
                end
            end)
            zo_callLater(EnforceNativeBarWidths, 250)
            zo_callLater(EnforceNativeBarWidths, 1000)

            local function RegisterSettings()
                local LAM = LibAddonMenu2
                if not LAM then
                    d("[AltAttributes] Bars loaded. LibAddonMenu-2.0 is not loaded, so only the settings panel is unavailable.")
                    return
                end

                local panelData = {
                    type = "panel",
                    name = "Alternative Attribute Bars",
                    displayName = "Alternative Attribute Bars",
                    author = "BulDeZir / Console port",
                    version = "2.0-console-fixed-native-bars",
                    registerForRefresh = true,
                    registerForDefaults = true,
                }

                LAM:RegisterAddonPanel("AltAttributesOptions", panelData)

                local function relayout()
                    if refreshLayout then refreshLayout() end
                end

                local textChoices = {"Exact current", "Current / Max", "Current / Max + Percent", "Abbreviated", "None"}
                local textValues = {"current_percent", "current_max", "current_max_percent", "abbreviated", "none"}
                local visibilityChoices = {"Always", "Combat only", "Dynamic (combat or resource not full)"}
                local visibilityValues = {"always", "combat", "dynamic"}
                local shapeChoices = {"ESO Basegame (full frame)", "Alternative Attribute Bars"}
                local shapeValues = {"basegame", "alternative"}
                local function getColor(key) local c=saved[key]; return c[1],c[2],c[3],c[4] end
                local function setColor(key,r,g,b,a) saved[key]={r,g,b,a}; relayout() end

                local options = {
                    { type="description", text="Full Console/Gamepad customization. Health, Magicka and Stamina use absolute independent X/Y positions that persist exactly across UI reloads." },
                    { type="header", name="Size and layout" },
                    { type="slider", name="Bar width", min=240,max=700,step=10,getFunc=function() return saved.width end,setFunc=function(v) saved.width=v; relayout() end,default=defaults.width,width="full" },
                    { type="slider", name="Gamepad bar height", min=40,max=160,step=2,getFunc=function() return saved.gamepadHeight end,setFunc=function(v) saved.gamepadHeight=v; relayout() end,default=defaults.gamepadHeight,width="full" },
                    { type="slider", name="Overall scale", min=0.5,max=2.0,step=0.05,getFunc=function() return saved.scale end,setFunc=function(v) saved.scale=v; relayout() end,default=defaults.scale,width="full" },
                    { type="slider", name="Gamepad container Y", min=-300,max=200,step=5,getFunc=function() return saved.gamepadOffsetY end,setFunc=function(v) saved.gamepadOffsetY=v; relayout() end,default=defaults.gamepadOffsetY,width="full" },
                    { type="header", name="Independent X / Y positions" },
                    { type="header", name="Health" },
                    { type="slider", name="X position", tooltip="-1 = Left | +1 = Right", min=-1000,max=1000,step=1,getFunc=function() return saved.healthX end,setFunc=function(v) saved.healthX=v; relayout() end,default=defaults.healthX,width="full" },
                    { type="slider", name="Y position", tooltip="-1 = Up | +1 = Down", min=-600,max=600,step=1,getFunc=function() return saved.healthY end,setFunc=function(v) saved.healthY=v; relayout() end,default=defaults.healthY,width="full" },
                    { type="header", name="Magicka" },
                    { type="slider", name="X position", tooltip="-1 = Left | +1 = Right", min=-1000,max=1000,step=1,getFunc=function() return saved.magickaX end,setFunc=function(v) saved.magickaX=v; relayout() end,default=defaults.magickaX,width="full" },
                    { type="slider", name="Y position", tooltip="-1 = Up | +1 = Down", min=-600,max=600,step=1,getFunc=function() return saved.magickaY end,setFunc=function(v) saved.magickaY=v; relayout() end,default=defaults.magickaY,width="full" },
                    { type="header", name="Stamina" },
                    { type="slider", name="X position", tooltip="-1 = Left | +1 = Right", min=-1000,max=1000,step=1,getFunc=function() return saved.staminaX end,setFunc=function(v) saved.staminaX=v; relayout() end,default=defaults.staminaX,width="full" },
                    { type="slider", name="Y position", tooltip="-1 = Up | +1 = Down", min=-600,max=600,step=1,getFunc=function() return saved.staminaY end,setFunc=function(v) saved.staminaY=v; relayout() end,default=defaults.staminaY,width="full" },
                    { type="header", name="Resource text" },
                    { type="dropdown", name="Value display", choices=textChoices, choicesValues=textValues, getFunc=function() return saved.textMode end, setFunc=function(v) saved.textMode=v; relayout() end, default=defaults.textMode, width="full" },
                    { type="dropdown", name="Percent display", choices={"Off", "On Edge", "After Value"}, choicesValues={"off", "edge", "after_value"}, getFunc=function() return saved.percentDisplayMode or (saved.showPercent and "edge" or "off") end, setFunc=function(v) saved.percentDisplayMode=v; saved.showPercent=(v ~= "off"); relayout() end, default=defaults.percentDisplayMode, width="full", tooltip="On Edge keeps the original Alternative Attribute Bars percentage placement. After Value places the percentage after the complete value, including shield or healing absorption." },
                    { type="slider", name="Value text Y position", tooltip="-1 = Up | +1 = Down. Moves the value and appended shield/healing absorption/After Value percent together. On Edge percent is unchanged.", min=-100,max=100,step=1,getFunc=function() return saved.valueTextY or 0 end,setFunc=function(v) saved.valueTextY=v; relayout() end,default=defaults.valueTextY,width="full" },
                    { type="slider", name="Font size", min=14,max=48,step=1,getFunc=function() return saved.fontSize end,setFunc=function(v) saved.fontSize=v; relayout() end,default=defaults.fontSize,width="full" },
                    { type="checkbox", name="Bold font", getFunc=function() return saved.fontBold end,setFunc=function(v) saved.fontBold=v; relayout() end,default=defaults.fontBold,width="full", tooltip="Off: ESO Gamepad Light font. On: ESO Gamepad Bold font. Font size scaling remains unchanged." },
                    { type="description", text="Health can show the shield as: current health + current shield. Values update from ESO's live power events." },
                    { type="header", name="Colors and appearance" },
                    { type="dropdown", name="Bar style / frame", choices=shapeChoices, choicesValues=shapeValues, getFunc=function() return saved.barShape end, setFunc=function(v) saved.barShape=v; relayout() end, default=defaults.barShape, width="full", tooltip="ESO Basegame uses ESO's actual native player attribute controls, including the original Gamepad border and end caps. Alternative Attribute Bars uses the add-on arrow-end style." },
                    { type="checkbox", name="Use custom resource colors", getFunc=function() return saved.useCustomColors end,setFunc=function(v) saved.useCustomColors=v; relayout() end,default=defaults.useCustomColors,width="full", tooltip="Off: use ESO's native Health, Magicka and Stamina colors. On: custom colors apply to Alternative Attribute Bars; native Basegame style keeps ESO's own rendering." },
                    { type="colorpicker", name="Health color", getFunc=function() return getColor("healthColor") end,setFunc=function(...) setColor("healthColor",...) end,disabled=function() return not saved.useCustomColors end,default=defaults.healthColor,width="full" },
                    { type="colorpicker", name="Magicka color", getFunc=function() return getColor("magickaColor") end,setFunc=function(...) setColor("magickaColor",...) end,disabled=function() return not saved.useCustomColors end,default=defaults.magickaColor,width="full" },
                    { type="colorpicker", name="Stamina color", getFunc=function() return getColor("staminaColor") end,setFunc=function(...) setColor("staminaColor",...) end,disabled=function() return not saved.useCustomColors end,default=defaults.staminaColor,width="full" },
                    { type="colorpicker", name="Shield color", getFunc=function() return getColor("shieldColor") end,setFunc=function(...) setColor("shieldColor",...) end,default=defaults.shieldColor,width="full" },
                    { type="slider", name="Transparency", min=0.15,max=1.0,step=0.05,getFunc=function() return saved.alpha end,setFunc=function(v) saved.alpha=v; relayout() end,default=defaults.alpha,width="full" },
                    { type="checkbox", name="Show shield", getFunc=function() return saved.showShield end,setFunc=function(v) saved.showShield=v; relayout() end,default=defaults.showShield,width="full" },
                    { type="dropdown", name="Shield value format", choices={"Exact", "Abbreviated"}, choicesValues={"exact", "abbreviated"}, getFunc=function() return saved.shieldValueFormat end, setFunc=function(v) saved.shieldValueFormat=v; relayout() end, default=defaults.shieldValueFormat, disabled=function() return not saved.showShield end, width="full" },
                    { type="checkbox", name="Show healing absorption", getFunc=function() return saved.showHealingAbsorption end,setFunc=function(v) saved.showHealingAbsorption=v; relayout() end,default=defaults.showHealingAbsorption,width="full", tooltip="Show healing absorption on Health as (-value). When enabled, healing absorption has priority over a shield." },
                    { type="dropdown", name="Healing absorption value format", choices={"Exact", "Abbreviated"}, choicesValues={"exact", "abbreviated"}, getFunc=function() return saved.healingAbsorptionValueFormat end, setFunc=function(v) saved.healingAbsorptionValueFormat=v; relayout() end, default=defaults.healingAbsorptionValueFormat, disabled=function() return not saved.showHealingAbsorption end, width="full" },
                    { type="checkbox", name="Show frame", getFunc=function() return saved.showFrame end,setFunc=function(v) saved.showFrame=v; relayout() end,default=defaults.showFrame,width="full" },
                    { type="checkbox", name="Show background", getFunc=function() return saved.showBackground end,setFunc=function(v) saved.showBackground=v; relayout() end,default=defaults.showBackground,width="full" },
                    { type="header", name="Visibility" },
                    { type="dropdown", name="Bar visibility", choices=visibilityChoices, choicesValues=visibilityValues,getFunc=function() return saved.visibilityMode end,setFunc=function(v) saved.visibilityMode=v; UpdateVisibility() end,default=defaults.visibilityMode,width="full" },
                    { type="header", name="Reset" },
                    { type="button", name="Reset all settings", func=function() for k,v in pairs(defaults) do if type(v)=="table" then saved[k]={unpack(v)} else saved[k]=v end end; relayout(); UpdateVisibility() end,width="half" },
                }

                LAM:RegisterOptionControls("AltAttributesOptions", options)
            end

            RegisterSettings()
            topLevelCtrl:RegisterForEvent(EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, refreshLayout)
            refreshLayout()
            UpdateVisibility()

            local fragment = ZO_SimpleSceneFragment:New(topLevelCtrl)
            HUD_SCENE:AddFragment(fragment)
            HUD_UI_SCENE:AddFragment(fragment)
            SIEGE_BAR_SCENE:AddFragment(fragment)
            SIEGE_BAR_UI_SCENE:AddFragment(fragment)

            if Azurah then
                Azurah.uiFrames.keyboard['ALTATTR_Container'] = {1, 'Alternative Attributes Bars'}
                Azurah.uiFrames.gamepad['ALTATTR_Container'] = {1, 'Alternative Attributes Bars'}
            end

            EVENT_MANAGER:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)
        end
    end

    EVENT_MANAGER:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
end