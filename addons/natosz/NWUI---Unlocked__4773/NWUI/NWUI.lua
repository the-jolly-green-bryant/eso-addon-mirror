local ADDON_NAME = "NWUI"
local PLAYER_UNIT_TAG = "player"

NWUI = NWUI or {}
local addon = NWUI

addon.name = ADDON_NAME
addon.initialized = false

local ASSET_PATH = "NWUI/assets/"
local TEXTURES =
{
    slotFrame = ASSET_PATH .. "slot_frame.dds",
    slotFrameEmpty = ASSET_PATH .. "slot_frame_empty.dds",
    keybindBox = ASSET_PATH .. "keybind_box.dds",
    barBg = ASSET_PATH .. "bar_bg.dds",
    healthOverlay = ASSET_PATH .. "health_bar_overlay.dds",
    resourceOverlay = ASSET_PATH .. "resource_bar_overlay.dds",
    levelBadgeRegular = ASSET_PATH .. "level_badge_regular.dds",
    levelBadgeChampion = ASSET_PATH .. "level_badge_champion.dds",
    weaponDualWield = ASSET_PATH .. "weapon_dual_wield.dds",
    weaponSword = ASSET_PATH .. "weapon_sword.dds",
    weaponTwoHanded = ASSET_PATH .. "weapon_two_handed.dds",
    weaponBow = ASSET_PATH .. "weapon_bow.dds",
    weaponStaff = ASSET_PATH .. "weapon_staff.dds",
    weaponShield = ASSET_PATH .. "weapon_shield.dds",
    ultimateFrame = ASSET_PATH .. "ultimate_frame.dds",
    ultimateShimmer = ASSET_PATH .. "ultimate_shimmer.dds",
}

local MAGICKA_BAR_COLOR = { 0.14, 0.48, 0.56, 0.54 }
local STAMINA_BAR_COLOR = { 0.70, 0.52, 0.17, 0.54 }
local HEALTH_FULL_COLOR = { 0.78, 0.76, 0.68, 0.62 }
local HEALTH_DAMAGED_COLOR = { 0.58, 0.05, 0.035, 0.68 }
local POWER_LOSS_COLOR = { 0.92, 0.90, 0.82, 0.58 }
local SHIELD_BAR_COLOR = { 0.20, 0.70, 0.90, 0.70 }

local RESOURCE_BARS =
{
    {
        key = "magicka",
        powerType = COMBAT_MECHANIC_FLAGS_MAGICKA,
        label = "MP",
        color = MAGICKA_BAR_COLOR,
    },
    {
        key = "stamina",
        powerType = COMBAT_MECHANIC_FLAGS_STAMINA,
        label = "ST",
        color = STAMINA_BAR_COLOR,
    },
    {
        key = "health",
        powerType = COMBAT_MECHANIC_FLAGS_HEALTH,
        label = "HP",
        color = HEALTH_FULL_COLOR,
    },
}

local SKILL_SLOT_INDEXES =
{
    ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1,
    ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 2,
    ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 3,
    ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 4,
    ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 5,
    ACTION_BAR_ULTIMATE_SLOT_INDEX + 1,
}

local ULTIMATE_SLOT_INDEX = ACTION_BAR_ULTIMATE_SLOT_INDEX + 1
local QUICK_SLOT_COUNT = 4
local SLOT_SIZE = 40
local SLOT_GAP = 5
local ACTIVE_ULTIMATE_SLOT_SIZE = 58
local BACKBAR_SLOT_SIZE = 28
local BACKBAR_SLOT_GAP = 4
local WEAPON_SLOT_SIZE = 28
local ACTIVE_WEAPON_SLOT_SIZE = SLOT_SIZE
local KEYBIND_LABEL_HEIGHT = 14
local KEYBIND_LABEL_GAP = 2
local SLOT_CONTROL_HEIGHT = SLOT_SIZE + KEYBIND_LABEL_GAP + KEYBIND_LABEL_HEIGHT
local ACTIVE_ULTIMATE_SLOT_CONTROL_HEIGHT = ACTIVE_ULTIMATE_SLOT_SIZE + KEYBIND_LABEL_GAP + KEYBIND_LABEL_HEIGHT
local BACKBAR_TO_ACTIVE_GAP = 5
local QUICK_SLOT_PANEL_WIDTH = (SLOT_SIZE * QUICK_SLOT_COUNT) + (SLOT_GAP * (QUICK_SLOT_COUNT - 1))
local SKILL_ROW_OFFSET_X = ACTIVE_WEAPON_SLOT_SIZE + SLOT_GAP
local SKILL_ROW_WIDTH = (SLOT_SIZE * (#SKILL_SLOT_INDEXES - 1)) + ACTIVE_ULTIMATE_SLOT_SIZE + (SLOT_GAP * (#SKILL_SLOT_INDEXES - 1))
local SKILL_PANEL_WIDTH = SKILL_ROW_OFFSET_X + SKILL_ROW_WIDTH
local BACKBAR_ROW_WIDTH = (BACKBAR_SLOT_SIZE * #SKILL_SLOT_INDEXES) + (BACKBAR_SLOT_GAP * (#SKILL_SLOT_INDEXES - 1))
local BACKBAR_ROW_OFFSET_X = SKILL_ROW_OFFSET_X + math.floor((SKILL_ROW_WIDTH - BACKBAR_ROW_WIDTH) / 2)
local BACKBAR_WEAPON_OFFSET_X = BACKBAR_ROW_OFFSET_X - BACKBAR_SLOT_GAP - WEAPON_SLOT_SIZE
local ACTIVE_ROW_OFFSET_Y = BACKBAR_SLOT_SIZE + BACKBAR_TO_ACTIVE_GAP
local SKILL_PANEL_HEIGHT = ACTIVE_ROW_OFFSET_Y + math.max(SLOT_CONTROL_HEIGHT, ACTIVE_ULTIMATE_SLOT_CONTROL_HEIGHT)
local POWER_BAR_WIDTH = 320
local THIN_POWER_BAR_HEIGHT = 14
local HEALTH_BAR_HEIGHT = 24
local EXPERIENCE_BAR_HEIGHT = 5
local LEVEL_BADGE_REGULAR_WIDTH = 46
local LEVEL_BADGE_REGULAR_HEIGHT = 24
local LEVEL_BADGE_CHAMPION_WIDTH = 70
local LEVEL_BADGE_CHAMPION_HEIGHT = 30
local LEVEL_BADGE_TEXT_OFFSET_Y = -1
local SAVED_VARIABLES_NAME = "NWUI_SavedVariables"
local SAVED_VARIABLES_VERSION = 15
local SAVED_VARIABLES_NAMESPACE = "Settings"
local SETTINGS_PANEL_ID = ADDON_NAME .. "Settings"

local SCALE_MIN = 0.20
local SCALE_MAX = 3.00
local ALPHA_MIN = 0.00
local ALPHA_MAX = 1.00
local BAR_WIDTH_MIN = 100
local BAR_WIDTH_MAX = 1000
local THIN_BAR_HEIGHT_MIN = 4
local THIN_BAR_HEIGHT_MAX = 80
local HEALTH_BAR_HEIGHT_MIN = 8
local HEALTH_BAR_HEIGHT_MAX = 120
local EXPERIENCE_BAR_HEIGHT_MIN = 2
local EXPERIENCE_BAR_HEIGHT_MAX = 50

local DEFAULT_SETTINGS =
{
    unlockUI = false,
    scaleAll = 1,
    consumablesScale = 1,
    skillsScale = 1,
    healthScale = 1,
    magickaScale = 1,
    staminaScale = 1,
    experienceScale = 1,

    consumablesAlpha = 1,
    skillsAlpha = 1,
    healthAlpha = 1,
    magickaAlpha = 1,
    staminaAlpha = 1,
    experienceAlpha = 1,

    hideConsumables = false,
    hideSkills = false,
    hideHealth = false,
    hideMagicka = false,
    hideStamina = false,
    hideExperience = false,

    showHealthText = true,
    healthTextFormat = "value",
    healthFontSize = 20,

    showStaminaText = false,
    staminaTextFormat = "value",
    staminaFontSize = 14,

    showMagickaText = false,
    magickaTextFormat = "value",
    magickaFontSize = 14,

    healthWidth = POWER_BAR_WIDTH,
    healthHeight = HEALTH_BAR_HEIGHT,
    magickaWidth = POWER_BAR_WIDTH,
    magickaHeight = THIN_POWER_BAR_HEIGHT,
    staminaWidth = POWER_BAR_WIDTH,
    staminaHeight = THIN_POWER_BAR_HEIGHT,
    experienceWidth = POWER_BAR_WIDTH,
    experienceHeight = EXPERIENCE_BAR_HEIGHT,

    showUltimateShimmer = true,

    pos_health_x = -9999,
    pos_health_y = -9999,
    pos_magicka_x = -9999,
    pos_magicka_y = -9999,
    pos_stamina_x = -9999,
    pos_stamina_y = -9999,
    pos_experience_x = -9999,
    pos_experience_y = -9999,
    pos_skills_x = -9999,
    pos_skills_y = -9999,
    pos_quickslots_x = -9999,
    pos_quickslots_y = -9999,
}

local HIDE_UNBOUND = false
local NO_LEADING_EDGE = false
local SLOT_BORDER_COLOR = { 0.44, 0.39, 0.30, 0.58 }
local DEFAULT_SLOT_ICON_INSET = 2
local ULTIMATE_SLOT_ICON_INSET_RATIO = 0.10
local BAR_BACKGROUND_TEXTURE_ALPHA = 0.62
local BAR_OVERLAY_ALPHA = 0.42
local POWER_BAR_ANIMATION_MS = 180
local POWER_LOSS_HOLD_MS = 160
local POWER_LOSS_ANIMATION_MS = 620
local ULTIMATE_READY_PULSE_SPEED = 0.007
local ULTIMATE_READY_MIN_ALPHA = 0.62
local ULTIMATE_READY_ALPHA_RANGE = 0.38
local ULTIMATE_READY_GLOW_MIN_ALPHA = 0.18
local ULTIMATE_READY_GLOW_ALPHA_RANGE = 0.34
local ULTIMATE_READY_SHIMMER_CYCLE_MS = 1150
local ULTIMATE_READY_SHIMMER_U_WIDTH = 0.25
local ULTIMATE_READY_SHIMMER_U_TRAVEL = 1 - ULTIMATE_READY_SHIMMER_U_WIDTH

local ONE_HANDED_WEAPON_TYPES =
{
    [WEAPONTYPE_AXE] = true,
    [WEAPONTYPE_HAMMER] = true,
    [WEAPONTYPE_SWORD] = true,
    [WEAPONTYPE_DAGGER] = true,
}

local TWO_HANDED_WEAPON_TYPES =
{
    [WEAPONTYPE_TWO_HANDED_AXE] = true,
    [WEAPONTYPE_TWO_HANDED_HAMMER] = true,
    [WEAPONTYPE_TWO_HANDED_SWORD] = true,
}

local STAFF_WEAPON_TYPES =
{
    [WEAPONTYPE_FIRE_STAFF] = true,
    [WEAPONTYPE_FROST_STAFF] = true,
    [WEAPONTYPE_LIGHTNING_STAFF] = true,
    [WEAPONTYPE_HEALING_STAFF] = true,
}

local function FormatNumber(value)
    value = tonumber(value) or 0
    local text = tostring(math.floor(value))
    local formatted = text
    local replacements

    while true do
        formatted, replacements = formatted:gsub("^(-?%d+)(%d%d%d)", "%1 %2")
        if replacements == 0 then
            break
        end
    end

    return formatted
end

local function SetBackdropColor(control, r, g, b, a)
    control:SetCenterColor(r, g, b, a)
    control:SetEdgeColor(r, g, b, a)
end

local function CreateInsetBackdrop(name, parent, inset, centerColor, borderColor)
    local border = CreateControl(name .. "Border", parent, CT_BACKDROP)
    border:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
    border:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, 0, 0)
    SetBackdropColor(border, borderColor[1], borderColor[2], borderColor[3], borderColor[4])

    local center = CreateControl(name .. "Center", parent, CT_BACKDROP)
    center:SetAnchor(TOPLEFT, parent, TOPLEFT, inset, inset)
    center:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, -inset, -inset)
    SetBackdropColor(center, centerColor[1], centerColor[2], centerColor[3], centerColor[4])

    return border, center
end

local function CreateLabel(name, parent, font, color)
    local label = CreateControl(name, parent, CT_LABEL)
    label:SetFont(font)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    if color then
        label:SetColor(color[1], color[2], color[3], color[4])
    else
        label:SetColor(0.92, 0.90, 0.84, 1)
    end

    return label
end

local function ClampNumber(value, minimumValue, maximumValue, defaultValue)
    value = tonumber(value)
    if value == nil then
        value = defaultValue
    end

    if value < minimumValue then
        return minimumValue
    elseif value > maximumValue then
        return maximumValue
    end

    return value
end

local function ClampInteger(value, minimumValue, maximumValue, defaultValue)
    return math.floor(ClampNumber(value, minimumValue, maximumValue, defaultValue) + 0.5)
end

function addon:SaveControlPosition(control, posKey)
    if not control or not self.savedVars then return end

    local left = control:GetLeft()
    local top = control:GetTop()

    if left and top then
        self.savedVars["pos_" .. posKey .. "_x"] = left
        self.savedVars["pos_" .. posKey .. "_y"] = top
    end
end

function addon:ApplyControlPosition(control, posKey, defaultAnchorData)
    if not control or not self.savedVars then return end

    local x = self.savedVars["pos_" .. posKey .. "_x"]
    local y = self.savedVars["pos_" .. posKey .. "_y"]

    control:ClearAnchors()
    if x and y and x ~= -9999 and y ~= -9999 then
        control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
    elseif defaultAnchorData then
        control:SetAnchor(defaultAnchorData.point, GuiRoot, defaultAnchorData.relPoint, defaultAnchorData.x, defaultAnchorData.y)
    end
end

function addon:MakeControlMovable(control, posKey)
    if not control then return end

    control:SetMouseEnabled(false)
    control:SetClampedToScreen(true)

    local overlay = CreateControl(control:GetName() .. "DragOverlay", control, CT_BACKDROP)
    overlay:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
    overlay:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, 0, 0)
    SetBackdropColor(overlay, 1, 0, 0, 0.25)
    overlay:SetDrawLevel(99)
    overlay:SetHidden(true)
    control.dragOverlay = overlay

    control:SetHandler("OnMouseDown", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and addon:GetSettingValue("unlockUI") then
            self:SetMovable(true)
            self:StartMoving()
        end
    end)

    control:SetHandler("OnMouseUp", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:StopMovingOrResizing()
            self:SetMovable(false)
        end
    end)

    control:SetHandler("OnMoveStop", function(self)
        self:SetMovable(false)
        addon:SaveControlPosition(self, posKey)
    end)
end

function addon:GetSettingValue(key)
    local settings = self.savedVars
    if settings and settings[key] ~= nil then
        return settings[key]
    end

    return DEFAULT_SETTINGS[key]
end

function addon:SetSettingValue(key, value)
    if self.savedVars then
        self.savedVars[key] = value
    end

    self:ApplySettings()
end

local function CreateBar(name, parent, width, height, color, overlayTexture, lossColor, isHealth)
    local container = CreateTopLevelWindow(name)
    container:SetDimensions(width, height)
    container:SetDrawTier(DT_HIGH)
    container:SetDrawLayer(DL_OVERLAY)
    container:SetDrawLevel(1)

    local border, background = CreateInsetBackdrop(name .. "Background", container, 1, { 0, 0, 0, 0.48 }, { 0.42, 0.38, 0.30, 0.46 })

    local backgroundTexture = CreateControl(name .. "BackgroundTexture", container, CT_TEXTURE)
    backgroundTexture:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
    backgroundTexture:SetAnchor(BOTTOMRIGHT, container, BOTTOMRIGHT, 0, 0)
    backgroundTexture:SetTexture(TEXTURES.barBg)
    backgroundTexture:SetDrawLevel(0)
    backgroundTexture:SetAlpha(BAR_BACKGROUND_TEXTURE_ALPHA)

    local lossBar
    if lossColor then
        lossBar = CreateControl(name .. "LossFill", container, CT_STATUSBAR)
        lossBar:SetAnchor(TOPLEFT, container, TOPLEFT, 1, 1)
        lossBar:SetAnchor(BOTTOMRIGHT, container, BOTTOMRIGHT, -1, -1)
        lossBar:SetDrawLevel(1)
        lossBar:SetMinMax(0, 1)
        lossBar:SetValue(0)
        lossBar:SetColor(lossColor[1], lossColor[2], lossColor[3], lossColor[4])
        lossBar:SetHidden(true)
    end

    local bar = CreateControl(name .. "Fill", container, CT_STATUSBAR)
    bar:SetAnchor(TOPLEFT, container, TOPLEFT, 1, 1)
    bar:SetAnchor(BOTTOMRIGHT, container, BOTTOMRIGHT, -1, -1)
    bar:SetDrawLevel(lossBar and 2 or 1)
    bar:SetMinMax(0, 1)
    bar:SetValue(0)
    bar:SetColor(color[1], color[2], color[3], color[4])

    local shieldBar
    if isHealth then
        shieldBar = CreateControl(name .. "ShieldFill", container, CT_STATUSBAR)
        shieldBar:SetAnchor(TOPLEFT, container, TOPLEFT, 1, 1)
        shieldBar:SetAnchor(BOTTOMRIGHT, container, BOTTOMRIGHT, -1, -1)
        shieldBar:SetDrawLevel(3)
        shieldBar:SetMinMax(0, 1)
        shieldBar:SetValue(0)
        shieldBar:SetColor(SHIELD_BAR_COLOR[1], SHIELD_BAR_COLOR[2], SHIELD_BAR_COLOR[3], SHIELD_BAR_COLOR[4])
        shieldBar:SetHidden(true)
    end

    local overlay = CreateControl(name .. "Overlay", container, CT_TEXTURE)
    overlay:SetAnchor(TOPLEFT, container, TOPLEFT, 1, 1)
    overlay:SetAnchor(BOTTOMRIGHT, container, BOTTOMRIGHT, -1, -1)
    overlay:SetDrawLevel(isHealth and 4 or (lossBar and 3 or 2))
    overlay:SetAlpha(BAR_OVERLAY_ALPHA)
    overlay:SetHidden(overlayTexture == nil)
    if overlayTexture then
        overlay:SetTexture(overlayTexture)
    end

    container.border = border
    container.background = background
    container.backgroundTexture = backgroundTexture
    container.lossBar = lossBar
    container.bar = bar
    container.shieldBar = shieldBar
    container.overlay = overlay

    return container
end

local function SetBarValue(barControl, current, maxValue)
    current = tonumber(current) or 0
    maxValue = tonumber(maxValue) or 0

    if maxValue <= 0 then
        barControl:SetMinMax(0, 1)
        barControl:SetValue(0)
        return
    end

    if current < 0 then
        current = 0
    elseif current > maxValue then
        current = maxValue
    end

    barControl:SetMinMax(0, maxValue)
    barControl:SetValue(current)
end

local function SetStatusBarColor(barControl, color)
    barControl:SetColor(color[1], color[2], color[3], color[4])
end

local function StopPowerValueAnimation(barControl)
    if barControl.powerValueAnimating then
        barControl.powerValueAnimating = false
        barControl:SetHandler("OnUpdate", nil, "PowerValueAnimation")
    end
end

local function UpdatePowerValueFrame(barControl)
    local maxValue = barControl.powerValueMaxValue or 0
    local targetValue = barControl.powerValueTargetValue or 0

    if maxValue <= 0 then
        barControl.powerValueDisplayValue = nil
        SetBarValue(barControl.bar, 0, 1)
        StopPowerValueAnimation(barControl)
        return
    end

    local progress = (GetFrameTimeMilliseconds() - (barControl.powerValueStartTime or 0)) / POWER_BAR_ANIMATION_MS
    if progress < 0 then
        progress = 0
    elseif progress > 1 then
        progress = 1
    end

    local startValue = barControl.powerValueStartValue or targetValue
    local value = startValue + ((targetValue - startValue) * progress)
    barControl.powerValueDisplayValue = value
    SetBarValue(barControl.bar, value, maxValue)

    if progress >= 1 then
        barControl.powerValueDisplayValue = targetValue
        SetBarValue(barControl.bar, targetValue, maxValue)
        StopPowerValueAnimation(barControl)
    end
end

local function SetAnimatedBarValue(barControl, current, maxValue)
    local currentValue = tonumber(current) or 0
    local maximumValue = tonumber(maxValue) or 0

    if maximumValue <= 0 then
        barControl.powerValueDisplayValue = nil
        barControl.powerValueMaxValue = nil
        SetBarValue(barControl.bar, 0, 1)
        StopPowerValueAnimation(barControl)
        return
    end

    if currentValue < 0 then
        currentValue = 0
    elseif currentValue > maximumValue then
        currentValue = maximumValue
    end

    local displayValue = barControl.powerValueDisplayValue
    local maxChanged = barControl.powerValueMaxValue ~= nil and barControl.powerValueMaxValue ~= maximumValue
    if displayValue == nil or maxChanged then
        barControl.powerValueDisplayValue = currentValue
        barControl.powerValueMaxValue = maximumValue
        SetBarValue(barControl.bar, currentValue, maximumValue)
        StopPowerValueAnimation(barControl)
        return
    end

    if displayValue == currentValue then
        barControl.powerValueMaxValue = maximumValue
        SetBarValue(barControl.bar, currentValue, maximumValue)
        StopPowerValueAnimation(barControl)
        return
    end

    barControl.powerValueStartValue = displayValue
    barControl.powerValueTargetValue = currentValue
    barControl.powerValueMaxValue = maximumValue
    barControl.powerValueStartTime = GetFrameTimeMilliseconds()

    if not barControl.powerValueAnimating then
        barControl.powerValueAnimating = true
        barControl:SetHandler("OnUpdate", UpdatePowerValueFrame, "PowerValueAnimation")
    end
end

local function StopPowerLossAnimation(barControl)
    if barControl.powerLossAnimating then
        barControl.powerLossAnimating = false
        barControl:SetHandler("OnUpdate", nil, "PowerLossAnimation")
    end
end

local function UpdatePowerLossFrame(barControl)
    local lossBar = barControl.lossBar
    local maxValue = barControl.powerLossMaxValue or 0
    local targetValue = barControl.powerLossTargetValue or 0

    if not lossBar or maxValue <= 0 then
        StopPowerLossAnimation(barControl)
        if lossBar then
            lossBar:SetHidden(true)
        end
        return
    end

    local now = GetFrameTimeMilliseconds()
    local startTime = barControl.powerLossStartTime or now
    if now < startTime then
        return
    end

    local progress = (now - startTime) / POWER_LOSS_ANIMATION_MS
    if progress < 0 then
        progress = 0
    elseif progress > 1 then
        progress = 1
    end

    local startValue = barControl.powerLossStartValue or targetValue
    local value = startValue + ((targetValue - startValue) * progress)
    if value < targetValue then
        value = targetValue
    end

    barControl.powerLossDisplayValue = value
    SetBarValue(lossBar, value, maxValue)

    if progress >= 1 then
        barControl.powerLossDisplayValue = targetValue
        SetBarValue(lossBar, targetValue, maxValue)
        lossBar:SetHidden(true)
        StopPowerLossAnimation(barControl)
    end
end

local function StartPowerLossAnimation(barControl)
    if barControl.powerLossAnimating then
        return
    end

    barControl.powerLossAnimating = true
    barControl:SetHandler("OnUpdate", UpdatePowerLossFrame, "PowerLossAnimation")
end

local function UpdatePowerBarVisuals(barControl, current, maxValue)
    local currentValue = tonumber(current) or 0
    local maximumValue = tonumber(maxValue) or 0

    if currentValue < 0 then
        currentValue = 0
    elseif maximumValue > 0 and currentValue > maximumValue then
        currentValue = maximumValue
    end

    if barControl.damagedColor then
        local fillColor = maximumValue > 0 and currentValue < maximumValue and barControl.damagedColor or barControl.defaultColor
        SetStatusBarColor(barControl.bar, fillColor)
    end

    local lossBar = barControl.lossBar
    if not lossBar then
        return
    end

    if maximumValue <= 0 then
        barControl.lastPowerValue = nil
        barControl.lastPowerMaxValue = nil
        barControl.powerLossDisplayValue = nil
        lossBar:SetHidden(true)
        StopPowerLossAnimation(barControl)
        return
    end

    local previousValue = barControl.lastPowerValue
    local maxChanged = barControl.lastPowerMaxValue ~= nil and barControl.lastPowerMaxValue ~= maximumValue

    if previousValue == nil or maxChanged then
        barControl.powerLossDisplayValue = currentValue
        SetBarValue(lossBar, currentValue, maximumValue)
        lossBar:SetHidden(true)
        StopPowerLossAnimation(barControl)
    elseif currentValue < previousValue then
        local startValue = barControl.powerLossDisplayValue or previousValue
        if previousValue > startValue then
            startValue = previousValue
        end
        if currentValue > startValue then
            startValue = currentValue
        end

        barControl.powerLossDisplayValue = startValue
        barControl.powerLossStartValue = startValue
        barControl.powerLossTargetValue = currentValue
        barControl.powerLossMaxValue = maximumValue
        barControl.powerLossStartTime = GetFrameTimeMilliseconds() + POWER_LOSS_HOLD_MS

        SetBarValue(lossBar, startValue, maximumValue)
        lossBar:SetHidden(false)
        StartPowerLossAnimation(barControl)
    elseif currentValue > previousValue then
        barControl.powerLossDisplayValue = currentValue
        SetBarValue(lossBar, currentValue, maximumValue)
        lossBar:SetHidden(true)
        StopPowerLossAnimation(barControl)
    end

    barControl.lastPowerValue = currentValue
    barControl.lastPowerMaxValue = maximumValue
end

local function GetInactiveHotbarCategory(activeHotbarCategory)
    if activeHotbarCategory == HOTBAR_CATEGORY_PRIMARY then
        return HOTBAR_CATEGORY_BACKUP
    elseif activeHotbarCategory == HOTBAR_CATEGORY_BACKUP then
        return HOTBAR_CATEGORY_PRIMARY
    end

    return nil
end

local function GetMainHandEquipSlotForHotbar(hotbarCategory)
    if hotbarCategory == HOTBAR_CATEGORY_BACKUP then
        return EQUIP_SLOT_BACKUP_MAIN
    elseif hotbarCategory == HOTBAR_CATEGORY_PRIMARY then
        return EQUIP_SLOT_MAIN_HAND
    end

    return nil
end

local function GetOffHandEquipSlotForHotbar(hotbarCategory)
    if hotbarCategory == HOTBAR_CATEGORY_BACKUP then
        return EQUIP_SLOT_BACKUP_OFF
    elseif hotbarCategory == HOTBAR_CATEGORY_PRIMARY then
        return EQUIP_SLOT_OFF_HAND
    end

    return nil
end

local function IsOneHandedWeaponType(weaponType)
    return weaponType and ONE_HANDED_WEAPON_TYPES[weaponType] == true
end

local function IsTwoHandedWeaponType(weaponType)
    return weaponType and TWO_HANDED_WEAPON_TYPES[weaponType] == true
end

local function IsStaffWeaponType(weaponType)
    return weaponType and STAFF_WEAPON_TYPES[weaponType] == true
end

local function GetWeaponTypeForEquipSlot(equipSlot)
    if not equipSlot then
        return nil
    end

    local slotHasItem = GetWornItemInfo(BAG_WORN, equipSlot)
    if not slotHasItem then
        return nil
    end

    return GetItemWeaponType(BAG_WORN, equipSlot)
end

local function GetWeaponIconTextureForHotbar(hotbarCategory)
    local mainHandSlot = GetMainHandEquipSlotForHotbar(hotbarCategory)
    local offHandSlot = GetOffHandEquipSlotForHotbar(hotbarCategory)
    local mainHandWeaponType = GetWeaponTypeForEquipSlot(mainHandSlot)
    local offHandWeaponType = GetWeaponTypeForEquipSlot(offHandSlot)

    if IsOneHandedWeaponType(mainHandWeaponType) and IsOneHandedWeaponType(offHandWeaponType) then
        return TEXTURES.weaponDualWield
    end

    if offHandWeaponType == WEAPONTYPE_SHIELD then
        return TEXTURES.weaponShield
    end

    if mainHandWeaponType == WEAPONTYPE_BOW or offHandWeaponType == WEAPONTYPE_BOW then
        return TEXTURES.weaponBow
    end

    if IsStaffWeaponType(mainHandWeaponType) or IsStaffWeaponType(offHandWeaponType) then
        return TEXTURES.weaponStaff
    end

    if IsTwoHandedWeaponType(mainHandWeaponType) or IsTwoHandedWeaponType(offHandWeaponType) then
        return TEXTURES.weaponTwoHanded
    end

    if IsOneHandedWeaponType(mainHandWeaponType) or IsOneHandedWeaponType(offHandWeaponType) then
        return TEXTURES.weaponSword
    end

    return nil
end

function addon:CreateSlot(name, parent, size, keybindActionName, gamepadActionName, showKeybind)
    if showKeybind == nil then
        showKeybind = true
    end

    local slot = CreateControl(name, parent, CT_CONTROL)
    slot:SetDimensions(size, showKeybind and (size + KEYBIND_LABEL_GAP + KEYBIND_LABEL_HEIGHT) or size)

    local frame = CreateControl(name .. "Frame", slot, CT_CONTROL)
    frame:SetDimensions(size, size)
    frame:SetAnchor(TOP, slot, TOP, 0, 0)
    local border, background = CreateInsetBackdrop(name .. "FrameBackdrop", frame, 1, { 0.02, 0.02, 0.02, 0.68 }, SLOT_BORDER_COLOR)

    local frameTexture = CreateControl(name .. "FrameTexture", frame, CT_TEXTURE)
    frameTexture:SetAnchor(TOPLEFT, frame, TOPLEFT, 0, 0)
    frameTexture:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, 0, 0)
    frameTexture:SetTexture(TEXTURES.slotFrame)
    frameTexture:SetDrawLevel(0)

    local ultimateGlowTexture = CreateControl(name .. "UltimateGlowTexture", frame, CT_TEXTURE)
    ultimateGlowTexture:SetAnchor(TOPLEFT, frame, TOPLEFT, -4, -4)
    ultimateGlowTexture:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, 4, 4)
    ultimateGlowTexture:SetTexture(TEXTURES.ultimateFrame)
    ultimateGlowTexture:SetDrawLevel(5)
    ultimateGlowTexture:SetColor(1, 0.82, 0.34, 1)
    ultimateGlowTexture:SetAlpha(0)
    ultimateGlowTexture:SetHidden(true)

    local ultimateFrameTexture = CreateControl(name .. "UltimateFrameTexture", frame, CT_TEXTURE)
    ultimateFrameTexture:SetAnchor(TOPLEFT, frame, TOPLEFT, 0, 0)
    ultimateFrameTexture:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, 0, 0)
    ultimateFrameTexture:SetTexture(TEXTURES.ultimateFrame)
    ultimateFrameTexture:SetDrawLevel(6)
    ultimateFrameTexture:SetHidden(true)

    local iconClip = CreateControl(name .. "IconClip", frame, CT_CONTROL)
    iconClip:SetAnchor(TOPLEFT, frame, TOPLEFT, DEFAULT_SLOT_ICON_INSET, DEFAULT_SLOT_ICON_INSET)
    iconClip:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, -DEFAULT_SLOT_ICON_INSET, -DEFAULT_SLOT_ICON_INSET)

    local icon = CreateControl(name .. "Icon", iconClip, CT_TEXTURE)
    icon:SetAnchor(TOPLEFT, iconClip, TOPLEFT, 0, 0)
    icon:SetAnchor(BOTTOMRIGHT, iconClip, BOTTOMRIGHT, 0, 0)
    icon:SetDrawLevel(1)
    icon:SetHidden(true)

    local unusableOverlay = CreateControl(name .. "UnusableOverlay", iconClip, CT_BACKDROP)
    unusableOverlay:SetAnchor(TOPLEFT, icon, TOPLEFT, 0, 0)
    unusableOverlay:SetAnchor(BOTTOMRIGHT, icon, BOTTOMRIGHT, 0, 0)
    unusableOverlay:SetDrawLevel(5)
    SetBackdropColor(unusableOverlay, 0, 0, 0, 0.34)
    unusableOverlay:SetHidden(true)

    local ultimateMask = CreateControl(name .. "UltimateMask", iconClip, CT_BACKDROP)
    ultimateMask:SetAnchor(TOPLEFT, icon, TOPLEFT, 0, 0)
    ultimateMask:SetAnchor(TOPRIGHT, icon, TOPRIGHT, 0, 0)
    ultimateMask:SetHeight(size - 4)
    ultimateMask:SetDrawLevel(2)
    SetBackdropColor(ultimateMask, 0, 0, 0, 0.62)
    ultimateMask:SetHidden(true)

    local ultimateReady = CreateControl(name .. "UltimateReady", iconClip, CT_BACKDROP)
    ultimateReady:SetAnchor(TOPLEFT, icon, TOPLEFT, 0, 0)
    ultimateReady:SetAnchor(BOTTOMRIGHT, icon, BOTTOMRIGHT, 0, 0)
    ultimateReady:SetDrawLevel(3)
    SetBackdropColor(ultimateReady, 0.95, 0.68, 0.18, 0.30)
    ultimateReady:SetHidden(true)

    local ultimateShimmerTexture = CreateControl(name .. "UltimateShimmerTexture", frame, CT_TEXTURE)
    ultimateShimmerTexture:SetAnchor(TOPLEFT, frame, TOPLEFT, 0, 0)
    ultimateShimmerTexture:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, 0, 0)
    ultimateShimmerTexture:SetTexture(TEXTURES.ultimateShimmer)
    ultimateShimmerTexture:SetTextureCoords(0, ULTIMATE_READY_SHIMMER_U_WIDTH, 0, 1)
    ultimateShimmerTexture:SetDrawLevel(7)
    ultimateShimmerTexture:SetAlpha(0)
    ultimateShimmerTexture:SetHidden(true)

    local active = CreateControl(name .. "Active", frame, CT_BACKDROP)
    active:SetAnchor(TOPLEFT, frame, TOPLEFT, 1, 1)
    active:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, -1, -1)
    SetBackdropColor(active, 0.86, 0.58, 0.16, 0.16)
    active:SetHidden(true)

    local cooldown = CreateControl(name .. "Cooldown", iconClip, CT_COOLDOWN)
    cooldown:SetAnchor(TOPLEFT, icon, TOPLEFT, 0, 0)
    cooldown:SetAnchor(BOTTOMRIGHT, icon, BOTTOMRIGHT, 0, 0)
    cooldown:SetFillColor(0, 0, 0, 0.70)
    cooldown:SetHidden(true)

    local count = CreateLabel(name .. "Count", frame, "ZoFontGameSmall", { 1, 1, 1, 1 })
    count:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, -2, -1)
    count:SetDimensions(size - 5, 14)
    count:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    count:SetHidden(true)

    if showKeybind then
        local keybindFrame = CreateControl(name .. "KeybindFrame", slot, CT_CONTROL)
        keybindFrame:SetDimensions(size, KEYBIND_LABEL_HEIGHT)
        keybindFrame:SetAnchor(TOP, frame, BOTTOM, 0, KEYBIND_LABEL_GAP)

        local keybindBackground = CreateControl(name .. "KeybindBackground", keybindFrame, CT_TEXTURE)
        keybindBackground:SetAnchor(TOPLEFT, keybindFrame, TOPLEFT, 0, 0)
        keybindBackground:SetAnchor(BOTTOMRIGHT, keybindFrame, BOTTOMRIGHT, 0, 0)
        keybindBackground:SetTexture(TEXTURES.keybindBox)

        local keybind = CreateLabel(name .. "Keybind", keybindFrame, "ZoFontGameSmall", { 0.86, 0.84, 0.78, 1 })
        keybind:SetAnchor(TOPLEFT, keybindFrame, TOPLEFT, 0, 0)
        keybind:SetAnchor(BOTTOMRIGHT, keybindFrame, BOTTOMRIGHT, 0, 0)

        if keybindActionName then
            ZO_Keybindings_RegisterLabelForBindingUpdate(keybind, keybindActionName, HIDE_UNBOUND, gamepadActionName)
        end

        slot.keybindFrame = keybindFrame
        slot.keybindBackground = keybindBackground
        slot.keybind = keybind
    end

    slot.frame = frame
    slot.border = border
    slot.background = background
    slot.frameTexture = frameTexture
    slot.ultimateGlowTexture = ultimateGlowTexture
    slot.ultimateFrameTexture = ultimateFrameTexture
    slot.ultimateShimmerTexture = ultimateShimmerTexture
    slot.active = active
    slot.iconClip = iconClip
    slot.icon = icon
    slot.slotSize = size
    slot.iconSize = size - (DEFAULT_SLOT_ICON_INSET * 2)
    slot.unusableOverlay = unusableOverlay
    slot.ultimateMask = ultimateMask
    slot.ultimateReady = ultimateReady
    slot.cooldown = cooldown
    slot.count = count

    return slot
end

function addon:CreateWeaponIcon(name, parent, size)
    local slot = CreateControl(name, parent, CT_CONTROL)
    slot:SetDimensions(size, size)

    local frame = CreateControl(name .. "Frame", slot, CT_CONTROL)
    frame:SetAnchor(TOPLEFT, slot, TOPLEFT, 0, 0)
    frame:SetAnchor(BOTTOMRIGHT, slot, BOTTOMRIGHT, 0, 0)
    local border, background = CreateInsetBackdrop(name .. "FrameBackdrop", frame, 1, { 0.02, 0.02, 0.02, 0.68 }, SLOT_BORDER_COLOR)

    local frameTexture = CreateControl(name .. "FrameTexture", frame, CT_TEXTURE)
    frameTexture:SetAnchor(TOPLEFT, frame, TOPLEFT, 0, 0)
    frameTexture:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, 0, 0)
    frameTexture:SetTexture(TEXTURES.slotFrameEmpty)
    frameTexture:SetDrawLevel(0)

    local icon = CreateControl(name .. "Icon", frame, CT_TEXTURE)
    icon:SetAnchor(TOPLEFT, frame, TOPLEFT, 2, 2)
    icon:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, -2, -2)
    icon:SetDrawLevel(1)
    icon:SetHidden(true)

    slot.frame = frame
    slot.border = border
    slot.background = background
    slot.frameTexture = frameTexture
    slot.icon = icon

    return slot
end

local function SetSlotUltimateFrameEnabled(slot, enabled)
    if not slot or not slot.ultimateFrameTexture or slot.ultimateFrameEnabled == enabled then
        return
    end

    slot.ultimateFrameEnabled = enabled

    slot.border:SetHidden(enabled)
    slot.background:SetHidden(enabled)
    slot.frameTexture:SetHidden(enabled)
    slot.ultimateFrameTexture:SetHidden(not enabled)
    if not enabled then
        if slot.ultimateGlowTexture then
            slot.ultimateGlowTexture:SetHidden(true)
            slot.ultimateGlowTexture:SetAlpha(0)
        end

        if slot.ultimateShimmerTexture then
            slot.ultimateShimmerTexture:SetHidden(true)
            slot.ultimateShimmerTexture:SetAlpha(0)
        end
    end

    local iconInset = DEFAULT_SLOT_ICON_INSET
    if enabled then
        iconInset = math.max(DEFAULT_SLOT_ICON_INSET, math.floor((slot.slotSize or SLOT_SIZE) * ULTIMATE_SLOT_ICON_INSET_RATIO))
    end

    slot.iconClip:ClearAnchors()
    slot.iconClip:SetAnchor(TOPLEFT, slot.frame, TOPLEFT, iconInset, iconInset)
    slot.iconClip:SetAnchor(BOTTOMRIGHT, slot.frame, BOTTOMRIGHT, -iconInset, -iconInset)

    slot.cooldown:ClearAnchors()
    slot.cooldown:SetAnchor(TOPLEFT, slot.icon, TOPLEFT, 0, 0)
    slot.cooldown:SetAnchor(BOTTOMRIGHT, slot.icon, BOTTOMRIGHT, 0, 0)

    slot.iconSize = (slot.slotSize or SLOT_SIZE) - (iconInset * 2)
end

function addon:CreateControls()
    self.powerBars = {}
    self.skillSlots = {}
    self.backbarSlots = {}
    self.weaponIcons = {}
    self.quickSlots = {}

    for index, data in ipairs(RESOURCE_BARS) do
        local isHealthBar = data.powerType == COMBAT_MECHANIC_FLAGS_HEALTH
        local overlayTexture = isHealthBar and TEXTURES.healthOverlay or TEXTURES.resourceOverlay
        local bar = CreateBar(ADDON_NAME .. "Power" .. index, GuiRoot, POWER_BAR_WIDTH, THIN_POWER_BAR_HEIGHT, data.color, overlayTexture, POWER_LOSS_COLOR, isHealthBar)
        bar.defaultColor = data.color

        if isHealthBar then
            bar.damagedColor = HEALTH_DAMAGED_COLOR
        end

        local textColor = isHealthBar and { 0.88, 0.86, 0.78, 0.92 } or { 0.86, 0.84, 0.78, 0.90 }
        
        local text = CreateLabel(ADDON_NAME .. "Power" .. index .. "Text", bar, "$(BOLD_FONT)|16|outline", textColor)
        text:SetAnchor(CENTER, bar, CENTER, 0, 0)
        text:SetDimensions(POWER_BAR_WIDTH - 8, THIN_POWER_BAR_HEIGHT)
        text:SetDrawLevel(4)
        
        bar.valueText = text
        self.powerBars[data.powerType] = bar
        self:MakeControlMovable(bar, data.key)
    end

    local xp = CreateBar(ADDON_NAME .. "Experience", GuiRoot, POWER_BAR_WIDTH, EXPERIENCE_BAR_HEIGHT, { 0.74, 0.56, 0.17, 0.50 }, TEXTURES.resourceOverlay)
    xp:SetDrawLevel(3)
    self.experienceBar = xp

    local xpText = CreateLabel(ADDON_NAME .. "ExperienceText", xp, "ZoFontGameSmall", { 0.93, 0.82, 0.48, 1 })
    xpText:SetAnchor(CENTER, xp, CENTER, 0, 0)
    xpText:SetDimensions(POWER_BAR_WIDTH - 8, KEYBIND_LABEL_HEIGHT)
    xpText:SetHidden(true)
    self.experienceText = xpText

    local levelBadge = CreateControl(ADDON_NAME .. "LevelBadge", xp, CT_CONTROL)
    levelBadge:SetDimensions(LEVEL_BADGE_REGULAR_WIDTH, LEVEL_BADGE_REGULAR_HEIGHT)
    levelBadge:SetAnchor(TOP, xp, BOTTOM, 0, 2)
    levelBadge:SetDrawLevel(1)

    local levelBadgeTexture = CreateControl(ADDON_NAME .. "LevelBadgeTexture", levelBadge, CT_TEXTURE)
    levelBadgeTexture:SetAnchor(TOPLEFT, levelBadge, TOPLEFT, 0, 0)
    levelBadgeTexture:SetAnchor(BOTTOMRIGHT, levelBadge, BOTTOMRIGHT, 0, 0)
    levelBadgeTexture:SetTexture(TEXTURES.levelBadgeRegular)
    levelBadgeTexture:SetDrawLevel(0)
    self.levelBadge = levelBadge
    self.levelBadgeTexture = levelBadgeTexture

    local levelText = CreateLabel(ADDON_NAME .. "LevelText", levelBadge, "ZoFontGameSmall", { 0.92, 0.90, 0.84, 1 })
    levelText:SetAnchor(TOPLEFT, levelBadge, TOPLEFT, 0, LEVEL_BADGE_TEXT_OFFSET_Y)
    levelText:SetAnchor(BOTTOMRIGHT, levelBadge, BOTTOMRIGHT, 0, LEVEL_BADGE_TEXT_OFFSET_Y)
    levelText:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    levelText:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    levelText:SetDrawLevel(1)
    self.levelText = levelText

    self:MakeControlMovable(xp, "experience")

    local quickSlots = CreateTopLevelWindow(ADDON_NAME .. "QuickSlots")
    quickSlots:SetDimensions(QUICK_SLOT_PANEL_WIDTH, SLOT_CONTROL_HEIGHT)
    quickSlots:SetDrawTier(DT_HIGH)
    quickSlots:SetDrawLayer(DL_OVERLAY)
    quickSlots:SetDrawLevel(1)
    self.quickSlotContainer = quickSlots

    for index = 1, QUICK_SLOT_COUNT do
        local slot = self:CreateSlot(ADDON_NAME .. "QuickSlot" .. index, quickSlots, SLOT_SIZE, "ACTION_BUTTON_9", "GAMEPAD_ACTION_BUTTON_9")
        slot.slotIndex = index
        slot.hotbarCategory = HOTBAR_CATEGORY_QUICKSLOT_WHEEL
        slot:SetAnchor(TOPLEFT, quickSlots, TOPLEFT, (index - 1) * (SLOT_SIZE + SLOT_GAP), 0)
        self.quickSlots[index] = slot
    end
    self:MakeControlMovable(quickSlots, "quickslots")

    local skillSlots = CreateTopLevelWindow(ADDON_NAME .. "SkillSlots")
    skillSlots:SetDimensions(SKILL_PANEL_WIDTH, SKILL_PANEL_HEIGHT)
    skillSlots:SetDrawTier(DT_HIGH)
    skillSlots:SetDrawLayer(DL_OVERLAY)
    skillSlots:SetDrawLevel(1)
    self.skillSlotContainer = skillSlots

    local backbar = CreateControl(ADDON_NAME .. "BackbarSlots", skillSlots, CT_CONTROL)
    backbar:SetDimensions(SKILL_PANEL_WIDTH, BACKBAR_SLOT_SIZE)
    backbar:SetAnchor(TOPLEFT, skillSlots, TOPLEFT, 0, 0)
    self.backbarContainer = backbar

    local weaponIcon = self:CreateWeaponIcon(ADDON_NAME .. "BackbarWeaponIcon", backbar, WEAPON_SLOT_SIZE)
    weaponIcon:SetAnchor(LEFT, backbar, LEFT, BACKBAR_WEAPON_OFFSET_X, 0)
    self.backbarWeaponIcon = weaponIcon
    self.weaponIcons.backbar = weaponIcon

    for index, slotIndex in ipairs(SKILL_SLOT_INDEXES) do
        local slot = self:CreateSlot(ADDON_NAME .. "BackbarSlot" .. index, backbar, BACKBAR_SLOT_SIZE, nil, nil, false)
        slot.slotIndex = slotIndex
        slot.hotbarCategory = nil
        slot.requiresHotbarCategory = true
        slot:SetAnchor(LEFT, backbar, LEFT, BACKBAR_ROW_OFFSET_X + ((index - 1) * (BACKBAR_SLOT_SIZE + BACKBAR_SLOT_GAP)), 0)
        self.backbarSlots[index] = slot
    end

    local activeWeaponIcon = self:CreateWeaponIcon(ADDON_NAME .. "ActiveWeaponIcon", skillSlots, ACTIVE_WEAPON_SLOT_SIZE)
    activeWeaponIcon:SetAnchor(TOPLEFT, skillSlots, TOPLEFT, 0, ACTIVE_ROW_OFFSET_Y)
    self.activeWeaponIcon = activeWeaponIcon
    self.weaponIcons.active = activeWeaponIcon

    for index, slotIndex in ipairs(SKILL_SLOT_INDEXES) do
        local actionName = "ACTION_BUTTON_" .. slotIndex
        local gamepadActionName = "GAMEPAD_ACTION_BUTTON_" .. slotIndex
        local slotSize = slotIndex == ULTIMATE_SLOT_INDEX and ACTIVE_ULTIMATE_SLOT_SIZE or SLOT_SIZE
        local slot = self:CreateSlot(ADDON_NAME .. "SkillSlot" .. index, skillSlots, slotSize, actionName, gamepadActionName)
        slot.slotIndex = slotIndex
        slot.hotbarCategory = nil
        slot:SetAnchor(TOPLEFT, skillSlots, TOPLEFT, SKILL_ROW_OFFSET_X + ((index - 1) * (SLOT_SIZE + SLOT_GAP)), ACTIVE_ROW_OFFSET_Y)
        self.skillSlots[index] = slot
    end
    self:MakeControlMovable(skillSlots, "skills")
end

function addon:InitializeSavedVars()
    self.savedVars = ZO_SavedVars:NewAccountWide(SAVED_VARIABLES_NAME, SAVED_VARIABLES_VERSION, SAVED_VARIABLES_NAMESPACE, DEFAULT_SETTINGS)
    
    local keys = { "health", "magicka", "stamina", "experience", "skills", "quickslots" }
    for _, k in ipairs(keys) do
        if self.savedVars["pos_" .. k .. "_x"] == nil then
            self.savedVars["pos_" .. k .. "_x"] = -9999
            self.savedVars["pos_" .. k .. "_y"] = -9999
        end
    end
end

function addon:ResetPositions()
    if not self.savedVars then return end
    
    local keys = { "health", "magicka", "stamina", "experience", "skills", "quickslots" }
    for _, k in ipairs(keys) do
        self.savedVars["pos_" .. k .. "_x"] = -9999
        self.savedVars["pos_" .. k .. "_y"] = -9999
    end

    self:ApplyPositions(true)
end

function addon:ApplyPositions(forceDefaults)
    local screenWidth, screenHeight = GuiRoot:GetDimensions()
    local cx = screenWidth / 2
    local cy = screenHeight / 2

    local defaults = {
        magicka = { point = TOPLEFT, relPoint = TOPLEFT, x = cx - (POWER_BAR_WIDTH / 2), y = cy + 140 },
        stamina = { point = TOPLEFT, relPoint = TOPLEFT, x = cx - (POWER_BAR_WIDTH / 2), y = cy + 160 },
        health = { point = TOPLEFT, relPoint = TOPLEFT, x = cx - (POWER_BAR_WIDTH / 2), y = cy + 190 },
        experience = { point = TOPLEFT, relPoint = TOPLEFT, x = cx - (POWER_BAR_WIDTH / 2), y = cy + 225 },
        skills = { point = TOPLEFT, relPoint = TOPLEFT, x = cx + 180, y = cy + 170 },
        quickslots = { point = TOPLEFT, relPoint = TOPLEFT, x = cx - 360, y = cy + 180 },
    }

    for _, data in ipairs(RESOURCE_BARS) do
        local bar = self.powerBars[data.powerType]
        self:ApplyControlPosition(bar, data.key, defaults[data.key])
    end

    self:ApplyControlPosition(self.experienceBar, "experience", defaults.experience)
    self:ApplyControlPosition(self.quickSlotContainer, "quickslots", defaults.quickslots)
    self:ApplyControlPosition(self.skillSlotContainer, "skills", defaults.skills)
end

function addon:ApplyFonts()
    if not self.powerBars then return end

    local fontTemplate = "$(BOLD_FONT)|%d|outline"

    local healthBar = self.powerBars[COMBAT_MECHANIC_FLAGS_HEALTH]
    if healthBar and healthBar.valueText then
        healthBar.valueText:SetFont(string.format(fontTemplate, self:GetSettingValue("healthFontSize")))
    end

    local magickaBar = self.powerBars[COMBAT_MECHANIC_FLAGS_MAGICKA]
    if magickaBar and magickaBar.valueText then
        magickaBar.valueText:SetFont(string.format(fontTemplate, self:GetSettingValue("magickaFontSize")))
    end

    local staminaBar = self.powerBars[COMBAT_MECHANIC_FLAGS_STAMINA]
    if staminaBar and staminaBar.valueText then
        staminaBar.valueText:SetFont(string.format(fontTemplate, self:GetSettingValue("staminaFontSize")))
    end
end

function addon:ApplyBarLayout()
    local healthWidth = ClampInteger(self:GetSettingValue("healthWidth"), BAR_WIDTH_MIN, BAR_WIDTH_MAX, POWER_BAR_WIDTH)
    local healthHeight = ClampInteger(self:GetSettingValue("healthHeight"), HEALTH_BAR_HEIGHT_MIN, HEALTH_BAR_HEIGHT_MAX, HEALTH_BAR_HEIGHT)
    local magickaWidth = ClampInteger(self:GetSettingValue("magickaWidth"), BAR_WIDTH_MIN, BAR_WIDTH_MAX, POWER_BAR_WIDTH)
    local magickaHeight = ClampInteger(self:GetSettingValue("magickaHeight"), THIN_BAR_HEIGHT_MIN, THIN_BAR_HEIGHT_MAX, THIN_POWER_BAR_HEIGHT)
    local staminaWidth = ClampInteger(self:GetSettingValue("staminaWidth"), BAR_WIDTH_MIN, BAR_WIDTH_MAX, POWER_BAR_WIDTH)
    local staminaHeight = ClampInteger(self:GetSettingValue("staminaHeight"), THIN_BAR_HEIGHT_MIN, THIN_BAR_HEIGHT_MAX, THIN_POWER_BAR_HEIGHT)
    local xpWidth = ClampInteger(self:GetSettingValue("experienceWidth"), BAR_WIDTH_MIN, BAR_WIDTH_MAX, POWER_BAR_WIDTH)
    local xpHeight = ClampInteger(self:GetSettingValue("experienceHeight"), EXPERIENCE_BAR_HEIGHT_MIN, EXPERIENCE_BAR_HEIGHT_MAX, EXPERIENCE_BAR_HEIGHT)

    local healthBar = self.powerBars[COMBAT_MECHANIC_FLAGS_HEALTH]
    if healthBar then
        healthBar:SetDimensions(healthWidth, healthHeight)
        if healthBar.valueText then healthBar.valueText:SetDimensions(healthWidth - 8, healthHeight) end
    end

    local magickaBar = self.powerBars[COMBAT_MECHANIC_FLAGS_MAGICKA]
    if magickaBar then
        magickaBar:SetDimensions(magickaWidth, magickaHeight)
        if magickaBar.valueText then magickaBar.valueText:SetDimensions(magickaWidth - 8, magickaHeight) end
    end

    local staminaBar = self.powerBars[COMBAT_MECHANIC_FLAGS_STAMINA]
    if staminaBar then
        staminaBar:SetDimensions(staminaWidth, staminaHeight)
        if staminaBar.valueText then staminaBar.valueText:SetDimensions(staminaWidth - 8, staminaHeight) end
    end

    if self.experienceBar then
        self.experienceBar:SetDimensions(xpWidth, xpHeight)
    end
end

function addon:ApplyResourceNumberVisibility()
    if not self.powerBars then return end

    local healthBar = self.powerBars[COMBAT_MECHANIC_FLAGS_HEALTH]
    if healthBar and healthBar.valueText then
        healthBar.valueText:SetHidden(not self:GetSettingValue("showHealthText"))
    end

    local magickaBar = self.powerBars[COMBAT_MECHANIC_FLAGS_MAGICKA]
    if magickaBar and magickaBar.valueText then
        magickaBar.valueText:SetHidden(not self:GetSettingValue("showMagickaText"))
    end

    local staminaBar = self.powerBars[COMBAT_MECHANIC_FLAGS_STAMINA]
    if staminaBar and staminaBar.valueText then
        staminaBar.valueText:SetHidden(not self:GetSettingValue("showStaminaText"))
    end
end

function addon:ApplyUltimateShimmerSetting()
    if self:GetSettingValue("showUltimateShimmer") then return end

    if self.skillSlots then
        for _, slot in ipairs(self.skillSlots) do
            if slot.ultimateShimmerTexture then
                slot.ultimateShimmerTexture:SetHidden(true)
                slot.ultimateShimmerTexture:SetAlpha(0)
            end
        end
    end

    if self.backbarSlots then
        for _, slot in ipairs(self.backbarSlots) do
            if slot.ultimateShimmerTexture then
                slot.ultimateShimmerTexture:SetHidden(true)
                slot.ultimateShimmerTexture:SetAlpha(0)
            end
        end
    end
end

function addon:ApplyUnlockState()
    local unlocked = self:GetSettingValue("unlockUI") == true

    local controlsToUnlock = {
        self.experienceBar,
        self.quickSlotContainer,
        self.skillSlotContainer
    }

    for _, data in ipairs(RESOURCE_BARS) do
        table.insert(controlsToUnlock, self.powerBars[data.powerType])
    end

    for _, ctrl in ipairs(controlsToUnlock) do
        if ctrl then
            ctrl:SetMouseEnabled(unlocked)
            if ctrl.dragOverlay then
                ctrl.dragOverlay:SetHidden(not unlocked)
            end
        end
    end
end

function addon:ApplySettings()
    local masterScale = ClampNumber(self:GetSettingValue("scaleAll"), SCALE_MIN, SCALE_MAX, DEFAULT_SETTINGS.scaleAll)

    if self.quickSlotContainer then
        local quickScale = ClampNumber(self:GetSettingValue("consumablesScale"), SCALE_MIN, SCALE_MAX, DEFAULT_SETTINGS.consumablesScale)
        self.quickSlotContainer:SetScale(quickScale * masterScale)
        self.quickSlotContainer:SetAlpha(ClampNumber(self:GetSettingValue("consumablesAlpha"), ALPHA_MIN, ALPHA_MAX, DEFAULT_SETTINGS.consumablesAlpha))
    end

    if self.skillSlotContainer then
        local skScale = ClampNumber(self:GetSettingValue("skillsScale"), SCALE_MIN, SCALE_MAX, DEFAULT_SETTINGS.skillsScale)
        self.skillSlotContainer:SetScale(skScale * masterScale)
        self.skillSlotContainer:SetAlpha(ClampNumber(self:GetSettingValue("skillsAlpha"), ALPHA_MIN, ALPHA_MAX, DEFAULT_SETTINGS.skillsAlpha))
    end

    if self.powerBars[COMBAT_MECHANIC_FLAGS_HEALTH] then
        local hpScale = ClampNumber(self:GetSettingValue("healthScale"), SCALE_MIN, SCALE_MAX, DEFAULT_SETTINGS.healthScale)
        self.powerBars[COMBAT_MECHANIC_FLAGS_HEALTH]:SetScale(hpScale * masterScale)
        self.powerBars[COMBAT_MECHANIC_FLAGS_HEALTH]:SetAlpha(ClampNumber(self:GetSettingValue("healthAlpha"), ALPHA_MIN, ALPHA_MAX, DEFAULT_SETTINGS.healthAlpha))
    end

    if self.powerBars[COMBAT_MECHANIC_FLAGS_MAGICKA] then
        local mpScale = ClampNumber(self:GetSettingValue("magickaScale"), SCALE_MIN, SCALE_MAX, DEFAULT_SETTINGS.magickaScale)
        self.powerBars[COMBAT_MECHANIC_FLAGS_MAGICKA]:SetScale(mpScale * masterScale)
        self.powerBars[COMBAT_MECHANIC_FLAGS_MAGICKA]:SetAlpha(ClampNumber(self:GetSettingValue("magickaAlpha"), ALPHA_MIN, ALPHA_MAX, DEFAULT_SETTINGS.magickaAlpha))
    end

    if self.powerBars[COMBAT_MECHANIC_FLAGS_STAMINA] then
        local stScale = ClampNumber(self:GetSettingValue("staminaScale"), SCALE_MIN, SCALE_MAX, DEFAULT_SETTINGS.staminaScale)
        self.powerBars[COMBAT_MECHANIC_FLAGS_STAMINA]:SetScale(stScale * masterScale)
        self.powerBars[COMBAT_MECHANIC_FLAGS_STAMINA]:SetAlpha(ClampNumber(self:GetSettingValue("staminaAlpha"), ALPHA_MIN, ALPHA_MAX, DEFAULT_SETTINGS.staminaAlpha))
    end

    if self.experienceBar then
        local xpScale = ClampNumber(self:GetSettingValue("experienceScale"), SCALE_MIN, SCALE_MAX, DEFAULT_SETTINGS.experienceScale)
        self.experienceBar:SetScale(xpScale * masterScale)
        self.experienceBar:SetAlpha(ClampNumber(self:GetSettingValue("experienceAlpha"), ALPHA_MIN, ALPHA_MAX, DEFAULT_SETTINGS.experienceAlpha))
    end

    self:ApplyFonts()
    self:ApplyBarLayout()
    self:ApplyUnlockState()
    self:ApplyResourceNumberVisibility()
    self:ApplyUltimateShimmerSetting()
    self:UpdateVisibility()
end

function addon:GetTotalDamageShield()
    local value = GetUnitAttributeVisualizerEffectInfo(PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH)
    return tonumber(value) or 0
end

function addon:UpdateShields()
    local healthBar = self.powerBars and self.powerBars[COMBAT_MECHANIC_FLAGS_HEALTH]
    if not healthBar or not healthBar.shieldBar then return end

    local currentShield = self:GetTotalDamageShield()
    local currentHp, maxHp = GetUnitPower(PLAYER_UNIT_TAG, COMBAT_MECHANIC_FLAGS_HEALTH)
    currentHp = currentHp or 0
    maxHp = maxHp or 1

    local formatMode = self:GetSettingValue("healthTextFormat")
    local isPercent = (formatMode == "percent")

    if currentShield > 0 then
        healthBar.shieldBar:SetHidden(false)
        healthBar.shieldBar:SetMinMax(0, maxHp)
        healthBar.shieldBar:SetValue(math.min(currentShield, maxHp))
        if healthBar.valueText then
            if isPercent then
                local pctHp = math.floor((currentHp / maxHp) * 100)
                local pctShield = math.floor((currentShield / maxHp) * 100)
                healthBar.valueText:SetText(pctHp .. "% |c66e0ff+ [" .. pctShield .. "%]|r")
            else
                healthBar.valueText:SetText(FormatNumber(currentHp) .. " |c66e0ff+ [" .. FormatNumber(currentShield) .. "]|r")
            end
        end
    else
        healthBar.shieldBar:SetHidden(true)
        if healthBar.valueText then
            if isPercent then
                local pctHp = math.floor((currentHp / maxHp) * 100)
                healthBar.valueText:SetText(pctHp .. "%")
            else
                healthBar.valueText:SetText(FormatNumber(currentHp))
            end
        end
    end
end

function addon:UpdatePower(powerType, current, maxValue)
    local bar = self.powerBars and self.powerBars[powerType]
    if not bar then return end

    if current == nil or maxValue == nil then
        current, maxValue = GetUnitPower(PLAYER_UNIT_TAG, powerType)
    end

    SetAnimatedBarValue(bar, current, maxValue)
    UpdatePowerBarVisuals(bar, current, maxValue)

    if powerType == COMBAT_MECHANIC_FLAGS_HEALTH then
        self:UpdateShields()
    elseif bar.valueText then
        local key = (powerType == COMBAT_MECHANIC_FLAGS_MAGICKA) and "magicka" or "stamina"
        local formatMode = self:GetSettingValue(key .. "TextFormat")
        
        if formatMode == "percent" then
            local maxVal = maxValue or 1
            if maxVal <= 0 then maxVal = 1 end
            local pct = math.floor(((current or 0) / maxVal) * 100)
            bar.valueText:SetText(pct .. "%")
        else
            bar.valueText:SetText(FormatNumber(current))
        end
    end
end

function addon:UpdateAllPowers()
    for _, data in ipairs(RESOURCE_BARS) do
        self:UpdatePower(data.powerType)
    end
end

function addon:UpdateExperience()
    local current
    local maxValue
    local levelLabel
    local isChampion = IsUnitChampion(PLAYER_UNIT_TAG)

    if isChampion then
        current = GetPlayerChampionXP() or 0
        local championPoints = GetPlayerChampionPointsEarned() or 0
        maxValue = GetNumChampionXPInChampionPoint(championPoints)
        levelLabel = FormatNumber(championPoints)
    else
        current = GetUnitXP(PLAYER_UNIT_TAG) or 0
        maxValue = GetUnitXPMax(PLAYER_UNIT_TAG)
        levelLabel = tostring(GetUnitLevel(PLAYER_UNIT_TAG))
    end

    if maxValue and maxValue > 0 then
        SetBarValue(self.experienceBar.bar, current, maxValue)
    else
        self.experienceBar.bar:SetMinMax(0, 1)
        self.experienceBar.bar:SetValue(1)
    end

    if self.levelBadgeIsChampion ~= isChampion then
        self.levelBadgeIsChampion = isChampion

        if isChampion then
            self.levelBadge:SetDimensions(LEVEL_BADGE_CHAMPION_WIDTH, LEVEL_BADGE_CHAMPION_HEIGHT)
            self.levelBadgeTexture:SetTexture(TEXTURES.levelBadgeChampion)
        else
            self.levelBadge:SetDimensions(LEVEL_BADGE_REGULAR_WIDTH, LEVEL_BADGE_REGULAR_HEIGHT)
            self.levelBadgeTexture:SetTexture(TEXTURES.levelBadgeRegular)
        end
    end

    self.levelText:SetText(levelLabel)
end

function addon:UpdateHotbarCategories()
    local activeHotbarCategory = GetActiveHotbarCategory()
    local backbarHotbarCategory = GetInactiveHotbarCategory(activeHotbarCategory)

    self.activeHotbarCategory = activeHotbarCategory
    self.backbarHotbarCategory = backbarHotbarCategory

    for _, slot in ipairs(self.skillSlots) do
        slot.hotbarCategory = activeHotbarCategory
        slot:SetHidden(false)
    end

    local showBackbar = backbarHotbarCategory ~= nil
    if self.backbarContainer then
        self.backbarContainer:SetHidden(not showBackbar)
    end

    for _, slot in ipairs(self.backbarSlots) do
        slot.hotbarCategory = backbarHotbarCategory
        slot:SetHidden(not showBackbar)
    end
end

function addon:UpdateWeaponIcon(weaponIcon, hotbarCategory)
    if not weaponIcon then return end

    local texture = GetWeaponIconTextureForHotbar(hotbarCategory)

    weaponIcon:SetHidden(hotbarCategory == nil)
    weaponIcon.icon:SetHidden(true)

    if texture then
        if weaponIcon.frameTexture then
            weaponIcon.frameTexture:SetTexture(TEXTURES.slotFrame)
        end
        weaponIcon.icon:SetTexture(texture)
        weaponIcon.icon:SetHidden(false)
    elseif weaponIcon.frameTexture then
        weaponIcon.frameTexture:SetTexture(TEXTURES.slotFrameEmpty)
    end
end

function addon:UpdateWeaponIcons()
    self:UpdateWeaponIcon(self.activeWeaponIcon, self.activeHotbarCategory)
    self:UpdateWeaponIcon(self.backbarWeaponIcon, self.backbarHotbarCategory)
end

function addon:UpdateSlotUsableState(slot, slotType, hasSlot)
    if not slot or not slot.icon then return end

    if slot.hotbarCategory == nil then
        slot.icon:SetDesaturation(0)
        slot.icon:SetColor(1, 1, 1, 1)
        if slot.unusableOverlay then
            slot.unusableOverlay:SetHidden(true)
        end
        return
    end

    slotType = slotType or GetSlotType(slot.slotIndex, slot.hotbarCategory)
    if hasSlot == nil then
        hasSlot = slotType ~= ACTION_TYPE_NOTHING
    end

    local isUnusable = hasSlot and
        slot.hotbarCategory ~= HOTBAR_CATEGORY_QUICKSLOT_WHEEL and
        ActionSlotHasNonCostStateFailure(slot.slotIndex, slot.hotbarCategory)

    if slot.isUltimateSlot and hasSlot then
        if slot.unusableOverlay then
            slot.unusableOverlay:SetHidden(not isUnusable)
        end
        return
    end

    if isUnusable then
        slot.icon:SetDesaturation(1)
        slot.icon:SetColor(0.58, 0.58, 0.58, 0.78)
    else
        slot.icon:SetDesaturation(0)
        slot.icon:SetColor(1, 1, 1, 1)
    end

    if slot.unusableOverlay then
        slot.unusableOverlay:SetHidden(not isUnusable)
    end
end

function addon:StartUltimateReadyPulse(slot)
    if slot.ultimateReadyPulsing then return end

    slot.ultimateReadyPulsing = true
    slot.frame:SetHandler("OnUpdate", function()
        local frameTime = GetFrameTimeMilliseconds()
        local pulse = (math.sin(frameTime * ULTIMATE_READY_PULSE_SPEED) + 1) * 0.5
        local alpha = ULTIMATE_READY_MIN_ALPHA + (ULTIMATE_READY_ALPHA_RANGE * pulse)
        slot.ultimateReady:SetAlpha(alpha)

        if slot.ultimateGlowTexture then
            slot.ultimateGlowTexture:SetHidden(false)
            slot.ultimateGlowTexture:SetAlpha(ULTIMATE_READY_GLOW_MIN_ALPHA + (ULTIMATE_READY_GLOW_ALPHA_RANGE * pulse))
        end

        if slot.ultimateFrameTexture then
            slot.ultimateFrameTexture:SetAlpha(0.92 + (0.08 * pulse))
            slot.ultimateFrameTexture:SetColor(1, 0.90 + (0.10 * pulse), 0.62 + (0.18 * pulse), 1)
        end

        if slot.ultimateShimmerTexture and addon:GetSettingValue("showUltimateShimmer") then
            local shimmerProgress = (frameTime % ULTIMATE_READY_SHIMMER_CYCLE_MS) / ULTIMATE_READY_SHIMMER_CYCLE_MS
            local shimmerLeft = ULTIMATE_READY_SHIMMER_U_TRAVEL * shimmerProgress
            slot.ultimateShimmerTexture:SetTextureCoords(shimmerLeft, shimmerLeft + ULTIMATE_READY_SHIMMER_U_WIDTH, 0, 1)
            slot.ultimateShimmerTexture:SetHidden(false)
            slot.ultimateShimmerTexture:SetAlpha(0.42 + (0.28 * pulse))
        elseif slot.ultimateShimmerTexture then
            slot.ultimateShimmerTexture:SetHidden(true)
            slot.ultimateShimmerTexture:SetAlpha(0)
        end

        if slot.border then
            SetBackdropColor(slot.border, 0.62, 0.46, 0.18, 0.50 + (0.34 * pulse))
        end
    end, "UltimateReadyPulse")
end

function addon:StopUltimateReadyPulse(slot)
    if slot.ultimateReadyPulsing then
        slot.ultimateReadyPulsing = false
        slot.frame:SetHandler("OnUpdate", nil, "UltimateReadyPulse")
    end

    if slot.ultimateReady then
        slot.ultimateReady:SetAlpha(1)
    end

    if slot.ultimateGlowTexture then
        slot.ultimateGlowTexture:SetHidden(true)
        slot.ultimateGlowTexture:SetAlpha(0)
    end

    if slot.ultimateFrameTexture then
        slot.ultimateFrameTexture:SetAlpha(1)
        slot.ultimateFrameTexture:SetColor(1, 1, 1, 1)
    end

    if slot.ultimateShimmerTexture then
        slot.ultimateShimmerTexture:SetHidden(true)
        slot.ultimateShimmerTexture:SetAlpha(0)
        slot.ultimateShimmerTexture:SetTextureCoords(0, ULTIMATE_READY_SHIMMER_U_WIDTH, 0, 1)
    end

    if slot.border then
        SetBackdropColor(slot.border, SLOT_BORDER_COLOR[1], SLOT_BORDER_COLOR[2], SLOT_BORDER_COLOR[3], SLOT_BORDER_COLOR[4])
    end
end

function addon:UpdateUltimateProgress(slot, hasSlot)
    if not slot or not slot.ultimateMask or not slot.ultimateReady then return end

    local hotbarCategory = slot.hotbarCategory
    local isUltimateSlot = slot.slotIndex == ULTIMATE_SLOT_INDEX and
        hotbarCategory ~= nil and
        IsActiveAbilityHotBarCategory(hotbarCategory)

    if hasSlot == nil and isUltimateSlot then
        hasSlot = GetSlotType(slot.slotIndex, hotbarCategory) ~= ACTION_TYPE_NOTHING
    end

    slot.isUltimateSlot = isUltimateSlot

    if not isUltimateSlot or not hasSlot then
        slot.ultimateMask:SetHidden(true)
        slot.ultimateReady:SetHidden(true)
        self:StopUltimateReadyPulse(slot)
        if isUltimateSlot then
            slot.icon:SetDesaturation(0)
            slot.icon:SetColor(1, 1, 1, 1)
        end
        return
    end

    local ultimateCost = GetSlotAbilityCost(ULTIMATE_SLOT_INDEX, COMBAT_MECHANIC_FLAGS_ULTIMATE, hotbarCategory)
    if not ultimateCost or ultimateCost <= 0 then
        slot.ultimateMask:SetHidden(true)
        slot.ultimateReady:SetHidden(true)
        self:StopUltimateReadyPulse(slot)
        slot.icon:SetDesaturation(0)
        slot.icon:SetColor(1, 1, 1, 1)
        return
    end

    local ultimatePower = GetUnitPower(PLAYER_UNIT_TAG, COMBAT_MECHANIC_FLAGS_ULTIMATE) or 0
    local progress = ultimatePower / ultimateCost
    if progress < 0 then
        progress = 0
    elseif progress > 1 then
        progress = 1
    end

    if progress >= 1 then
        slot.icon:SetDesaturation(0)
        slot.icon:SetColor(1, 1, 1, 1)
    else
        slot.icon:SetDesaturation(1)
        slot.icon:SetColor(0.42 + (0.46 * progress), 0.42 + (0.46 * progress), 0.42 + (0.46 * progress), 0.58 + (0.34 * progress))
    end

    local unfilledHeight = math.floor(slot.iconSize * (1 - progress))
    if unfilledHeight > 0 then
        slot.ultimateMask:SetHeight(unfilledHeight)
        slot.ultimateMask:SetHidden(false)
    else
        slot.ultimateMask:SetHidden(true)
    end

    if progress >= 1 then
        slot.ultimateReady:SetHidden(false)
        self:StartUltimateReadyPulse(slot)
    else
        slot.ultimateReady:SetHidden(true)
        self:StopUltimateReadyPulse(slot)
    end
end

function addon:UpdateUltimateMeters()
    for _, slot in ipairs(self.skillSlots) do
        self:UpdateUltimateProgress(slot)
    end

    for _, slot in ipairs(self.backbarSlots) do
        self:UpdateUltimateProgress(slot)
    end
end

function addon:UpdateActionSlotStates()
    for _, slot in ipairs(self.skillSlots) do
        self:UpdateSlotUsableState(slot)
    end

    for _, slot in ipairs(self.backbarSlots) do
        self:UpdateSlotUsableState(slot)
    end
end

function addon:UpdateSlot(slot)
    local hotbarCategory = slot.hotbarCategory
    local slotIndex = slot.slotIndex
    local useUltimateFrame = slotIndex == ULTIMATE_SLOT_INDEX and
        hotbarCategory ~= nil and
        IsActiveAbilityHotBarCategory(hotbarCategory)

    SetSlotUltimateFrameEnabled(slot, useUltimateFrame)

    if slot.requiresHotbarCategory and hotbarCategory == nil then
        slot.icon:SetHidden(true)
        slot.count:SetHidden(true)
        slot.active:SetHidden(true)
        slot.cooldown:SetHidden(true)
        if slot.frameTexture then
            slot.frameTexture:SetTexture(TEXTURES.slotFrameEmpty)
        end
        self:UpdateSlotUsableState(slot, ACTION_TYPE_NOTHING, false)
        self:UpdateUltimateProgress(slot, false)
        return
    end

    local slotType = GetSlotType(slotIndex, hotbarCategory)
    local hasSlot = slotType ~= ACTION_TYPE_NOTHING

    slot.icon:SetHidden(true)
    slot.count:SetHidden(true)
    if slot.frameTexture then
        slot.frameTexture:SetTexture(hasSlot and TEXTURES.slotFrame or TEXTURES.slotFrameEmpty)
    end

    if hasSlot then
        local texture = GetSlotTexture(slotIndex, hotbarCategory)
        if texture and texture ~= "" then
            slot.icon:SetTexture(texture)
            slot.icon:SetHidden(false)
        end

        if hotbarCategory == HOTBAR_CATEGORY_QUICKSLOT_WHEEL then
            local count = GetSlotItemCount(slotIndex, hotbarCategory)
            if count and count > 1 then
                slot.count:SetText(FormatNumber(count))
                slot.count:SetHidden(false)
            end
        end
    end

    self:UpdateSlotUsableState(slot, slotType, hasSlot)
    self:UpdateUltimateProgress(slot, hasSlot)

    if hotbarCategory == HOTBAR_CATEGORY_QUICKSLOT_WHEEL then
        local isCurrentQuickslot = slotIndex == GetCurrentQuickslot()
        slot.active:SetHidden(not isCurrentQuickslot)

        if slot.keybindFrame then
            slot.keybindFrame:SetHidden(not isCurrentQuickslot)
        end
    else
        slot.active:SetHidden(true)
    end

    self:UpdateSlotCooldown(slot)
end

function addon:UpdateSlotCooldown(slot)
    if slot.requiresHotbarCategory and slot.hotbarCategory == nil then
        slot.cooldown:SetHidden(true)
        return
    end

    local remain, duration = GetSlotCooldownInfo(slot.slotIndex, slot.hotbarCategory)

    if duration and duration > 0 and remain and remain > 0 then
        slot.cooldown:SetHidden(false)
        slot.cooldown:StartCooldown(remain, duration, CD_TYPE_RADIAL, nil, NO_LEADING_EDGE)
    else
        slot.cooldown:SetHidden(true)
    end
end

function addon:UpdateActionSlots()
    self:UpdateHotbarCategories()

    for _, slot in ipairs(self.skillSlots) do
        self:UpdateSlot(slot)
    end

    for _, slot in ipairs(self.backbarSlots) do
        self:UpdateSlot(slot)
    end

    self:UpdateWeaponIcons()

    for _, slot in ipairs(self.quickSlots) do
        self:UpdateSlot(slot)
    end
end

function addon:UpdateQuickSlots()
    for _, slot in ipairs(self.quickSlots) do
        self:UpdateSlot(slot)
    end
end

function addon:UpdateCooldowns()
    for _, slot in ipairs(self.skillSlots) do
        self:UpdateSlotCooldown(slot)
    end

    for _, slot in ipairs(self.backbarSlots) do
        self:UpdateSlotCooldown(slot)
    end

    for _, slot in ipairs(self.quickSlots) do
        self:UpdateSlotCooldown(slot)
    end
end

function addon:UpdateEquipmentDisplay()
    self:UpdateHotbarCategories()
    self:UpdateWeaponIcons()
end

function addon:UpdateVisibility()
    local isCameraUI = IsGameCameraUIModeActive() and not self:GetSettingValue("unlockUI")

    if self.experienceBar then 
        self.experienceBar:SetHidden(isCameraUI or self:GetSettingValue("hideExperience")) 
    end
    if self.quickSlotContainer then 
        self.quickSlotContainer:SetHidden(isCameraUI or self:GetSettingValue("hideConsumables")) 
    end
    if self.skillSlotContainer then 
        self.skillSlotContainer:SetHidden(isCameraUI or self:GetSettingValue("hideSkills")) 
    end

    local hideHealth = self:GetSettingValue("hideHealth")
    local hideMagicka = self:GetSettingValue("hideMagicka")
    local hideStamina = self:GetSettingValue("hideStamina")

    if self.powerBars[COMBAT_MECHANIC_FLAGS_HEALTH] then
        self.powerBars[COMBAT_MECHANIC_FLAGS_HEALTH]:SetHidden(isCameraUI or hideHealth)
    end
    if self.powerBars[COMBAT_MECHANIC_FLAGS_MAGICKA] then
        self.powerBars[COMBAT_MECHANIC_FLAGS_MAGICKA]:SetHidden(isCameraUI or hideMagicka)
    end
    if self.powerBars[COMBAT_MECHANIC_FLAGS_STAMINA] then
        self.powerBars[COMBAT_MECHANIC_FLAGS_STAMINA]:SetHidden(isCameraUI or hideStamina)
    end
end

function addon:RefreshAll()
    self:UpdateAllPowers()
    self:UpdateExperience()
    self:UpdateActionSlots()
    self:UpdateVisibility()
end

function addon:RegisterSettingsPanel()
    if self.settingsPanelRegistered then return end

    local LAM = LibAddonMenu2
    if not LAM then return end

    local function GetSetting(key)
        return function()
            return addon:GetSettingValue(key)
        end
    end

    local function SetSetting(key)
        return function(value)
            addon:SetSettingValue(key, value)
        end
    end

    local panelData =
    {
        type = "panel",
        name = "New World UI",
        displayName = "New World UI",
        author = "Wrynch",
        version = "15",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsTable =
    {
        {
            type = "header",
            name = "Layout & Master Controls",
            width = "full",
        },
        {
            type = "checkbox",
            name = "EDIT",
            tooltip = "Ativa o modo de edicao para arrastar cada elemento livremente pela tela.",
            getFunc = GetSetting("unlockUI"),
            setFunc = SetSetting("unlockUI"),
            default = DEFAULT_SETTINGS.unlockUI,
            width = "full",
        },
        {
            type = "button",
            name = "Reset Positions",
            tooltip = "Restaura todos os elementos para suas posicoes padrao.",
            func = function()
                addon:ResetPositions()
            end,
            width = "full",
        },
        {
            type = "slider",
            name = "Scale All Together",
            tooltip = "Escala todos os elementos simultaneamente.",
            min = SCALE_MIN, max = SCALE_MAX, step = 0.01, decimals = 2,
            getFunc = GetSetting("scaleAll"), setFunc = SetSetting("scaleAll"),
            default = DEFAULT_SETTINGS.scaleAll, width = "full",
        },
        
        -- HEALTH SECTION
        {
            type = "header",
            name = "Health Bar",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Hide / Disable Health Bar",
            getFunc = GetSetting("hideHealth"), setFunc = SetSetting("hideHealth"),
            default = DEFAULT_SETTINGS.hideHealth, width = "full",
        },
        {
            type = "checkbox",
            name = "Show Health Numbers",
            tooltip = "Mostra os valores numericos no centro da barra.",
            getFunc = GetSetting("showHealthText"),
            setFunc = function(value)
                addon:SetSettingValue("showHealthText", value)
                addon:ApplyResourceNumberVisibility()
            end,
            default = DEFAULT_SETTINGS.showHealthText,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Health Number Format",
            tooltip = "Altera o estilo do texto entre valor total e porcentagem.",
            choices = { "Full Value", "Percentage" },
            choicesValues = { "value", "percent" },
            getFunc = GetSetting("healthTextFormat"),
            setFunc = function(value)
                addon:SetSettingValue("healthTextFormat", value)
                addon:UpdateAllPowers()
            end,
            disabled = function() return not addon:GetSettingValue("showHealthText") end,
            default = DEFAULT_SETTINGS.healthTextFormat,
            width = "full",
        },
        {
            type = "slider",
            name = "Health Font Size",
            tooltip = "Tamanho do numero da barra de Vida.",
            min = 8, max = 48, step = 1,
            getFunc = GetSetting("healthFontSize"),
            setFunc = function(value)
                addon:SetSettingValue("healthFontSize", value)
                addon:ApplyFonts()
            end,
            disabled = function() return not addon:GetSettingValue("showHealthText") end,
            default = DEFAULT_SETTINGS.healthFontSize,
            width = "full",
        },
        {
            type = "slider",
            name = "Health Scale",
            min = SCALE_MIN, max = SCALE_MAX, step = 0.01, decimals = 2,
            getFunc = GetSetting("healthScale"), setFunc = SetSetting("healthScale"),
            default = DEFAULT_SETTINGS.healthScale, width = "half",
        },
        {
            type = "slider",
            name = "Health Opacity (Alpha)",
            min = ALPHA_MIN, max = ALPHA_MAX, step = 0.01, decimals = 2,
            getFunc = GetSetting("healthAlpha"), setFunc = SetSetting("healthAlpha"),
            default = DEFAULT_SETTINGS.healthAlpha, width = "half",
        },
        {
            type = "slider",
            name = "Health Width",
            min = BAR_WIDTH_MIN, max = BAR_WIDTH_MAX, step = 1,
            getFunc = GetSetting("healthWidth"), setFunc = SetSetting("healthWidth"),
            default = DEFAULT_SETTINGS.healthWidth, width = "half",
        },
        {
            type = "slider",
            name = "Health Height",
            min = HEALTH_BAR_HEIGHT_MIN, max = HEALTH_BAR_HEIGHT_MAX, step = 1,
            getFunc = GetSetting("healthHeight"), setFunc = SetSetting("healthHeight"),
            default = DEFAULT_SETTINGS.healthHeight, width = "half",
        },

        -- STAMINA SECTION
        {
            type = "header",
            name = "Stamina Bar",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Hide / Disable Stamina Bar",
            getFunc = GetSetting("hideStamina"), setFunc = SetSetting("hideStamina"),
            default = DEFAULT_SETTINGS.hideStamina, width = "full",
        },
        {
            type = "checkbox",
            name = "Show Stamina Numbers",
            tooltip = "Mostra os valores numericos no centro da barra.",
            getFunc = GetSetting("showStaminaText"),
            setFunc = function(value)
                addon:SetSettingValue("showStaminaText", value)
                addon:ApplyResourceNumberVisibility()
            end,
            default = DEFAULT_SETTINGS.showStaminaText,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Stamina Number Format",
            tooltip = "Altera o estilo do texto entre valor total e porcentagem.",
            choices = { "Full Value", "Percentage" },
            choicesValues = { "value", "percent" },
            getFunc = GetSetting("staminaTextFormat"),
            setFunc = function(value)
                addon:SetSettingValue("staminaTextFormat", value)
                addon:UpdateAllPowers()
            end,
            disabled = function() return not addon:GetSettingValue("showStaminaText") end,
            default = DEFAULT_SETTINGS.staminaTextFormat,
            width = "full",
        },
        {
            type = "slider",
            name = "Stamina Font Size",
            tooltip = "Tamanho do numero da barra de Stamina.",
            min = 8, max = 48, step = 1,
            getFunc = GetSetting("staminaFontSize"),
            setFunc = function(value)
                addon:SetSettingValue("staminaFontSize", value)
                addon:ApplyFonts()
            end,
            disabled = function() return not addon:GetSettingValue("showStaminaText") end,
            default = DEFAULT_SETTINGS.staminaFontSize,
            width = "full",
        },
        {
            type = "slider",
            name = "Stamina Scale",
            min = SCALE_MIN, max = SCALE_MAX, step = 0.01, decimals = 2,
            getFunc = GetSetting("staminaScale"), setFunc = SetSetting("staminaScale"),
            default = DEFAULT_SETTINGS.staminaScale, width = "half",
        },
        {
            type = "slider",
            name = "Stamina Opacity (Alpha)",
            min = ALPHA_MIN, max = ALPHA_MAX, step = 0.01, decimals = 2,
            getFunc = GetSetting("staminaAlpha"), setFunc = SetSetting("staminaAlpha"),
            default = DEFAULT_SETTINGS.staminaAlpha, width = "half",
        },
        {
            type = "slider",
            name = "Stamina Width",
            min = BAR_WIDTH_MIN, max = BAR_WIDTH_MAX, step = 1,
            getFunc = GetSetting("staminaWidth"), setFunc = SetSetting("staminaWidth"),
            default = DEFAULT_SETTINGS.staminaWidth, width = "half",
        },
        {
            type = "slider",
            name = "Stamina Height",
            min = THIN_BAR_HEIGHT_MIN, max = THIN_BAR_HEIGHT_MAX, step = 1,
            getFunc = GetSetting("staminaHeight"), setFunc = SetSetting("staminaHeight"),
            default = DEFAULT_SETTINGS.staminaHeight, width = "half",
        },

        -- MAGICKA SECTION
        {
            type = "header",
            name = "Magicka Bar",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Hide / Disable Magicka Bar",
            getFunc = GetSetting("hideMagicka"), setFunc = SetSetting("hideMagicka"),
            default = DEFAULT_SETTINGS.hideMagicka, width = "full",
        },
        {
            type = "checkbox",
            name = "Show Magicka Numbers",
            tooltip = "Mostra os valores numericos no centro da barra.",
            getFunc = GetSetting("showMagickaText"),
            setFunc = function(value)
                addon:SetSettingValue("showMagickaText", value)
                addon:ApplyResourceNumberVisibility()
            end,
            default = DEFAULT_SETTINGS.showMagickaText,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Magicka Number Format",
            tooltip = "Altera o estilo do texto entre valor total e porcentagem.",
            choices = { "Full Value", "Percentage" },
            choicesValues = { "value", "percent" },
            getFunc = GetSetting("magickaTextFormat"),
            setFunc = function(value)
                addon:SetSettingValue("magickaTextFormat", value)
                addon:UpdateAllPowers()
            end,
            disabled = function() return not addon:GetSettingValue("showMagickaText") end,
            default = DEFAULT_SETTINGS.magickaTextFormat,
            width = "full",
        },
        {
            type = "slider",
            name = "Magicka Font Size",
            tooltip = "Tamanho do numero da barra de Magicka.",
            min = 8, max = 48, step = 1,
            getFunc = GetSetting("magickaFontSize"),
            setFunc = function(value)
                addon:SetSettingValue("magickaFontSize", value)
                addon:ApplyFonts()
            end,
            disabled = function() return not addon:GetSettingValue("showMagickaText") end,
            default = DEFAULT_SETTINGS.magickaFontSize,
            width = "full",
        },
        {
            type = "slider",
            name = "Magicka Scale",
            min = SCALE_MIN, max = SCALE_MAX, step = 0.01, decimals = 2,
            getFunc = GetSetting("magickaScale"), setFunc = SetSetting("magickaScale"),
            default = DEFAULT_SETTINGS.magickaScale, width = "half",
        },
        {
            type = "slider",
            name = "Magicka Opacity (Alpha)",
            min = ALPHA_MIN, max = ALPHA_MAX, step = 0.01, decimals = 2,
            getFunc = GetSetting("magickaAlpha"), setFunc = SetSetting("magickaAlpha"),
            default = DEFAULT_SETTINGS.magickaAlpha, width = "half",
        },
        {
            type = "slider",
            name = "Magicka Width",
            min = BAR_WIDTH_MIN, max = BAR_WIDTH_MAX, step = 1,
            getFunc = GetSetting("magickaWidth"), setFunc = SetSetting("magickaWidth"),
            default = DEFAULT_SETTINGS.magickaWidth, width = "half",
        },
        {
            type = "slider",
            name = "Magicka Height",
            min = THIN_BAR_HEIGHT_MIN, max = THIN_BAR_HEIGHT_MAX, step = 1,
            getFunc = GetSetting("magickaHeight"), setFunc = SetSetting("magickaHeight"),
            default = DEFAULT_SETTINGS.magickaHeight, width = "half",
        },

        -- EXPERIENCE SECTION
        {
            type = "header",
            name = "Experience Bar",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Hide / Disable Experience Bar",
            getFunc = GetSetting("hideExperience"), setFunc = SetSetting("hideExperience"),
            default = DEFAULT_SETTINGS.hideExperience, width = "full",
        },
        {
            type = "slider",
            name = "XP Scale",
            min = SCALE_MIN, max = SCALE_MAX, step = 0.01, decimals = 2,
            getFunc = GetSetting("experienceScale"), setFunc = SetSetting("experienceScale"),
            default = DEFAULT_SETTINGS.experienceScale, width = "half",
        },
        {
            type = "slider",
            name = "XP Opacity (Alpha)",
            min = ALPHA_MIN, max = ALPHA_MAX, step = 0.01, decimals = 2,
            getFunc = GetSetting("experienceAlpha"), setFunc = SetSetting("experienceAlpha"),
            default = DEFAULT_SETTINGS.experienceAlpha, width = "half",
        },
        {
            type = "slider",
            name = "XP Width",
            min = BAR_WIDTH_MIN, max = BAR_WIDTH_MAX, step = 1,
            getFunc = GetSetting("experienceWidth"), setFunc = SetSetting("experienceWidth"),
            default = DEFAULT_SETTINGS.experienceWidth, width = "half",
        },
        {
            type = "slider",
            name = "XP Height",
            min = EXPERIENCE_BAR_HEIGHT_MIN, max = EXPERIENCE_BAR_HEIGHT_MAX, step = 1,
            getFunc = GetSetting("experienceHeight"), setFunc = SetSetting("experienceHeight"),
            default = DEFAULT_SETTINGS.experienceHeight, width = "half",
        },

        -- SKILLS SECTION
        {
            type = "header",
            name = "Skills & Weapons",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Hide / Disable Skills & Weapons",
            getFunc = GetSetting("hideSkills"), setFunc = SetSetting("hideSkills"),
            default = DEFAULT_SETTINGS.hideSkills, width = "full",
        },
        {
            type = "slider",
            name = "Skills UI Scale",
            min = SCALE_MIN, max = SCALE_MAX, step = 0.01, decimals = 2,
            getFunc = GetSetting("skillsScale"), setFunc = SetSetting("skillsScale"),
            default = DEFAULT_SETTINGS.skillsScale, width = "half",
        },
        {
            type = "slider",
            name = "Skills Opacity (Alpha)",
            min = ALPHA_MIN, max = ALPHA_MAX, step = 0.01, decimals = 2,
            getFunc = GetSetting("skillsAlpha"), setFunc = SetSetting("skillsAlpha"),
            default = DEFAULT_SETTINGS.skillsAlpha, width = "half",
        },
        {
            type = "checkbox",
            name = "Show Ultimate Shimmer",
            tooltip = "Mostra o efeito de brilho em movimento quando a ultimate estiver pronta.",
            getFunc = GetSetting("showUltimateShimmer"),
            setFunc = SetSetting("showUltimateShimmer"),
            default = DEFAULT_SETTINGS.showUltimateShimmer,
            width = "full",
        },

        -- CONSUMABLES SECTION
        {
            type = "header",
            name = "Consumables (Quickslots)",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Hide / Disable Consumables",
            getFunc = GetSetting("hideConsumables"), setFunc = SetSetting("hideConsumables"),
            default = DEFAULT_SETTINGS.hideConsumables, width = "full",
        },
        {
            type = "slider",
            name = "Consumables Scale",
            min = SCALE_MIN, max = SCALE_MAX, step = 0.01, decimals = 2,
            getFunc = GetSetting("consumablesScale"), setFunc = SetSetting("consumablesScale"),
            default = DEFAULT_SETTINGS.consumablesScale, width = "half",
        },
        {
            type = "slider",
            name = "Consumables Opacity (Alpha)",
            min = ALPHA_MIN, max = ALPHA_MAX, step = 0.01, decimals = 2,
            getFunc = GetSetting("consumablesAlpha"), setFunc = SetSetting("consumablesAlpha"),
            default = DEFAULT_SETTINGS.consumablesAlpha, width = "half",
        },
    }

    LAM:RegisterAddonPanel(SETTINGS_PANEL_ID, panelData)
    LAM:RegisterOptionControls(SETTINGS_PANEL_ID, optionsTable)

    self.settingsPanelRegistered = true
end

local function OnVisualUpdate(_, unitTag, visualType)
    if unitTag == PLAYER_UNIT_TAG and visualType == ATTRIBUTE_VISUAL_POWER_SHIELDING then
        addon:UpdateShields()
    end
end

local function OnPowerUpdate(_, unitTag, _, powerType, current, maxValue)
    if unitTag == PLAYER_UNIT_TAG then
        addon:UpdatePower(powerType, current, maxValue)
    end
end

local function RegisterPowerEvent(eventName, powerType)
    EVENT_MANAGER:RegisterForEvent(eventName, EVENT_POWER_UPDATE, OnPowerUpdate)
    EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, PLAYER_UNIT_TAG, REGISTER_FILTER_POWER_TYPE, powerType)
end

function addon:RegisterEvents()
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, function()
        addon:ApplyPositions()
        addon:RefreshAll()
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "ShieldAdded", EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, OnVisualUpdate)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "ShieldUpdated", EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, OnVisualUpdate)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "ShieldRemoved", EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, OnVisualUpdate)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "Experience", EVENT_EXPERIENCE_UPDATE, function()
        addon:UpdateExperience()
    end)
    EVENT_MANAGER:AddFilterForEvent(ADDON_NAME .. "Experience", EVENT_EXPERIENCE_UPDATE, REGISTER_FILTER_UNIT_TAG, PLAYER_UNIT_TAG)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "Level", EVENT_LEVEL_UPDATE, function()
        addon:UpdateExperience()
    end)
    EVENT_MANAGER:AddFilterForEvent(ADDON_NAME .. "Level", EVENT_LEVEL_UPDATE, REGISTER_FILTER_UNIT_TAG, PLAYER_UNIT_TAG)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "Champion", EVENT_CHAMPION_POINT_UPDATE, function()
        addon:UpdateExperience()
    end)
    EVENT_MANAGER:AddFilterForEvent(ADDON_NAME .. "Champion", EVENT_CHAMPION_POINT_UPDATE, REGISTER_FILTER_UNIT_TAG, PLAYER_UNIT_TAG)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "HotbarSlot", EVENT_HOTBAR_SLOT_UPDATED, function()
        addon:UpdateActionSlots()
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "HotbarSlotState", EVENT_HOTBAR_SLOT_STATE_UPDATED, function()
        addon:UpdateActionSlots()
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "ActiveHotbar", EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, function()
        addon:UpdateActionSlots()
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "AllHotbars", EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, function()
        addon:UpdateActionSlots()
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "WeaponPair", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function()
        addon:UpdateActionSlots()
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "Cooldowns", EVENT_ACTION_UPDATE_COOLDOWNS, function()
        addon:UpdateCooldowns()
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "UltimatePower", EVENT_POWER_UPDATE, function()
        addon:UpdateUltimateMeters()
    end)
    EVENT_MANAGER:AddFilterForEvent(ADDON_NAME .. "UltimatePower", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, PLAYER_UNIT_TAG, REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_ULTIMATE)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "UltimateCost", EVENT_ULTIMATE_ABILITY_COST_CHANGED, function()
        addon:UpdateUltimateMeters()
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "ReticleTarget", EVENT_RETICLE_TARGET_CHANGED, function()
        addon:UpdateActionSlotStates()
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "Quickslot", EVENT_ACTIVE_QUICKSLOT_CHANGED, function()
        addon:UpdateQuickSlots()
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "InventoryFull", EVENT_INVENTORY_FULL_UPDATE, function()
        addon:UpdateQuickSlots()
        addon:UpdateEquipmentDisplay()
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "InventorySingle", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(_, bagId)
        addon:UpdateQuickSlots()
        if bagId == BAG_WORN then
            addon:UpdateEquipmentDisplay()
        end
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "CameraMode", EVENT_GAME_CAMERA_UI_MODE_CHANGED, function()
        addon:UpdateVisibility()
    end)

    for _, data in ipairs(RESOURCE_BARS) do
        RegisterPowerEvent(ADDON_NAME .. data.key .. "Power", data.powerType)
    end
end

function addon:Initialize()
    if self.initialized then return end

    self.initialized = true
    self:InitializeSavedVars()
    self:CreateControls()
    self:ApplySettings()
    self:ApplyPositions()
    self:RegisterSettingsPanel()
    self:RegisterEvents()
    self:RefreshAll()
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    addon:Initialize()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)