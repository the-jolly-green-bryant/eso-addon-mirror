NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local PlayerInfo = {}

local NAMESPACE = "NQOL_UI_PlayerInfo"
local APPLY_DELAY_MS = 50
local FONT_SIZE_MIN = 12
local FONT_SIZE_MAX = 48
local SEPARATION_MIN = 0
local SEPARATION_MAX = 800
local BACKGROUND_OPACITY_MIN = 0
local BACKGROUND_OPACITY_MAX = 100
local PADDING = 8
local VERTICAL_PADDING = 8
local ITEM_GAP = 8
local CP_ICON_GAP = 2
local XP_BAR_GAP = 2
local XP_BAR_INSET = 2
local XP_BAR_MIN_HEIGHT = 16
local XP_BAR_BOTTOM_PADDING = 4
local ENLIGHTENMENT_BAR_HEIGHT = 4
local ENLIGHTENMENT_PREVIEW_PROGRESS = 0.65
local ENLIGHTENMENT_POOL_MAX_XP = 4800000
local XP_BAR_TEXTURE = "EsoUI/Art/Miscellaneous/white.dds"
local DEFAULT_SCREEN_WIDTH = 1920
local DEFAULT_SCREEN_HEIGHT = 1080
local PLACEMENT_OFF = "off"
local LEFT_SIDE = "L"
local RIGHT_SIDE = "R"
local GAMEPLAY_SCENES = { hud = true, hudui = true, siegeBar = true }
local CHAMPION_ICON = "EsoUI/Art/Champion/champion_icon.dds"

local FIELD_DEFINITIONS = {
    { key = "playerId", label = NQOL.L("features.uiplayer_info.player_id_23cf3e1") },
    { key = "characterName", label = NQOL.L("features.uiplayer_info.character_name_c0a090d") },
    { key = "championPoints", label = NQOL.L("features.uiplayer_info.cp_f19057b") },
    { key = "className", label = NQOL.L("features.uiplayer_info.class_name_59d7bbe") },
    { key = "classIcon", label = NQOL.L("features.uiplayer_info.class_icon_81088d7"), icon = true },
}
NQOL.Lexicon.RegisterRefreshCallback(function()
    FIELD_DEFINITIONS[1].label = NQOL.L("features.uiplayer_info.player_id_23cf3e1")
    FIELD_DEFINITIONS[2].label = NQOL.L("features.uiplayer_info.character_name_c0a090d")
    FIELD_DEFINITIONS[3].label = NQOL.L("features.uiplayer_info.cp_f19057b")
    FIELD_DEFINITIONS[4].label = NQOL.L("features.uiplayer_info.class_name_59d7bbe")
    FIELD_DEFINITIONS[5].label = NQOL.L("features.uiplayer_info.class_icon_81088d7")
end)

local PLACEMENT_CHOICES = {
    PLACEMENT_OFF,
    "L1",
    "L2",
    "L3",
    "L4",
    "L5",
    "R1",
    "R2",
    "R3",
    "R4",
    "R5",
}

local PLACEMENT_CHOICE_NAMES = {
    NQOL.L("common.off"),
    "L1",
    "L2",
    "L3",
    "L4",
    "L5",
    "R1",
    "R2",
    "R3",
    "R4",
    "R5",
}
NQOL.Lexicon.RegisterRefreshCallback(function() PLACEMENT_CHOICE_NAMES[1] = NQOL.L("common.off") end)

local VALID_PLACEMENTS = {}
for _, value in ipairs(PLACEMENT_CHOICES) do
    VALID_PLACEMENTS[value] = true
end

local defaults = {
    ui = {
        playerInfo = {
            enabled = false,
            showInSettings = true,
            horizontalPosition = 50,
            verticalPosition = 8,
            separation = 160,
            font = NQOL.Util.GetDefaultFont(),
            fontSize = 20,
            textColor = { r = 1, g = 1, b = 1, a = 1 },
            championPointsColor = { r = 1, g = 1, b = 1, a = 1 },
            cpIconColor = { r = 1, g = 1, b = 1, a = 1 },
            iconColor = { r = 1, g = 1, b = 1, a = 1 },
            backgroundOpacity = 90,
            xpBar = false,
            xpBarBackgroundOpacity = 100,
            xpBarFont = NQOL.Util.GetDefaultFont(),
            xpBarFontSize = 12,
            xpBarTextColor = { r = 1, g = 1, b = 1, a = 1 },
            enlightenmentBar = false,
            enlightenmentBarColor = { r = 0.86, g = 0.72, b = 0.28, a = 1 },
            fields = {
                playerId = PLACEMENT_OFF,
                characterName = "L2",
                championPoints = "R1",
                className = PLACEMENT_OFF,
                classIcon = "L1",
            },
        },
    },
}

local savedVariables
local initialized = false
local settingsPanelVisible = false
local applyQueued = false
local eventsRegistered = false
local sceneCallbackInstalled = false
local hud
local measureLabel
local fontString
local fontKey
local xpFontString
local xpFontKey
local labelControls = {}
local textureControls = {}

local Clamp = NQOL.Util.Clamp
local Round = NQOL.Util.Round

local function NormalizeColor(settings, defaultSettings, key)
    if type(settings[key]) ~= "table" then
        settings[key] = {}
    end

    local color = settings[key]
    local defaultColor = defaultSettings[key]
    color.r = Clamp(tonumber(color.r) or defaultColor.r, 0, 1)
    color.g = Clamp(tonumber(color.g) or defaultColor.g, 0, 1)
    color.b = Clamp(tonumber(color.b) or defaultColor.b, 0, 1)
    color.a = Clamp(tonumber(color.a) or defaultColor.a, 0, 1)
end

local function GetSettings()
    local uiSettings = NQOL.Settings.GetSection(savedVariables, defaults, "ui")
    local settings = NQOL.Settings.EnsureTable(uiSettings, "playerInfo")
    local defaultSettings = defaults.ui.playerInfo

    NQOL.Settings.Boolean(settings, defaultSettings, "enabled")
    NQOL.Settings.Boolean(settings, defaultSettings, "showInSettings")
    NQOL.Settings.Boolean(settings, defaultSettings, "xpBar")
    NQOL.Settings.Boolean(settings, defaultSettings, "enlightenmentBar")
    NQOL.Settings.ClampedNumber(settings, defaultSettings, "horizontalPosition", 0, 100)
    NQOL.Settings.ClampedNumber(settings, defaultSettings, "verticalPosition", 0, 100)
    NQOL.Settings.ClampedNumber(settings, defaultSettings, "separation", SEPARATION_MIN, SEPARATION_MAX, true)
    NQOL.Settings.ClampedNumber(settings, defaultSettings, "fontSize", FONT_SIZE_MIN, FONT_SIZE_MAX, true)
    NQOL.Settings.ClampedNumber(settings, defaultSettings, "backgroundOpacity", BACKGROUND_OPACITY_MIN, BACKGROUND_OPACITY_MAX, true)
    NQOL.Settings.ClampedNumber(settings, defaultSettings, "xpBarBackgroundOpacity", BACKGROUND_OPACITY_MIN, BACKGROUND_OPACITY_MAX, true)
    NQOL.Settings.ClampedNumber(settings, defaultSettings, "xpBarFontSize", FONT_SIZE_MIN, FONT_SIZE_MAX, true)
    settings.width = nil
    settings.height = nil
    settings.backgroundColor = nil
    settings.xpBarColor = nil
    settings.enlightenmentBarBackgroundOpacity = nil

    if not NQOL.Util.IsFontChoice(settings.font) then
        settings.font = defaultSettings.font
    end

    if not NQOL.Util.IsFontChoice(settings.xpBarFont) then
        settings.xpBarFont = defaultSettings.xpBarFont
    end

    NormalizeColor(settings, defaultSettings, "textColor")
    NormalizeColor(settings, defaultSettings, "championPointsColor")
    NormalizeColor(settings, defaultSettings, "cpIconColor")
    NormalizeColor(settings, defaultSettings, "iconColor")
    NormalizeColor(settings, defaultSettings, "xpBarTextColor")
    NormalizeColor(settings, defaultSettings, "enlightenmentBarColor")

    local fields = NQOL.Settings.EnsureTable(settings, "fields")
    for _, field in ipairs(FIELD_DEFINITIONS) do
        if not VALID_PLACEMENTS[fields[field.key]] then
            fields[field.key] = defaultSettings.fields[field.key]
        end
    end

    return settings
end

local function GetScreenWidth()
    if GuiRoot and GuiRoot.GetWidth then
        return math.floor(GuiRoot:GetWidth())
    end

    return DEFAULT_SCREEN_WIDTH
end

local function GetScreenHeight()
    if GuiRoot and GuiRoot.GetHeight then
        return math.floor(GuiRoot:GetHeight())
    end

    return DEFAULT_SCREEN_HEIGHT
end

local function IsNonEmptyString(value)
    return type(value) == "string" and value ~= ""
end

local function HasEnabledField()
    local fields = GetSettings().fields
    for _, field in ipairs(FIELD_DEFINITIONS) do
        if fields[field.key] ~= PLACEMENT_OFF then
            return true
        end
    end

    return false
end

local function GetCurrentSceneName()
    if not SCENE_MANAGER then
        return nil
    end

    if SCENE_MANAGER.GetCurrentSceneName then
        return SCENE_MANAGER:GetCurrentSceneName()
    end

    if SCENE_MANAGER.GetCurrentScene then
        local scene = SCENE_MANAGER:GetCurrentScene()
        if scene and scene.GetName then
            return scene:GetName()
        end
    end

    return nil
end

local function IsGameplaySceneShowing()
    if not SCENE_MANAGER then
        return true
    end

    return GAMEPLAY_SCENES[GetCurrentSceneName()] == true
end

local function ShouldShowHud()
    local settings = GetSettings()

    if not HasEnabledField() then
        return false
    end

    if settingsPanelVisible then
        return settings.showInSettings == true
    end

    if settings.enabled ~= true then
        return false
    end

    return IsGameplaySceneShowing()
end

local function GetHud()
    if hud or not WINDOW_MANAGER or not GuiRoot then
        return hud
    end

    hud = WINDOW_MANAGER:CreateTopLevelWindow("NQOL_UI_PlayerInfoHud")
    hud:SetHidden(true)
    hud:SetMouseEnabled(false)
    hud:SetClampedToScreen(true)
    hud:SetDrawLayer(DL_OVERLAY)
    hud:SetDrawTier(DT_LOW)
    hud:SetDrawLevel(1)

    local backdrop = WINDOW_MANAGER:CreateControl(nil, hud, CT_BACKDROP)
    backdrop:SetEdgeColor(0, 0, 0, 0)
    backdrop:SetEdgeTexture("", 1, 1, 0, 0)
    backdrop:SetMouseEnabled(false)
    hud.backdrop = backdrop

    local xpTrack = WINDOW_MANAGER:CreateControl(nil, hud, CT_BACKDROP)
    xpTrack:SetCenterColor(0, 0, 0, 0.95)
    xpTrack:SetEdgeColor(0.86, 0.72, 0.28, 0.95)
    xpTrack:SetEdgeTexture(XP_BAR_TEXTURE, 1, 1, 1)
    xpTrack:SetMouseEnabled(false)
    xpTrack:SetDrawLevel(2)
    xpTrack:SetHidden(true)
    hud.xpTrack = xpTrack

    local xpStatus = WINDOW_MANAGER:CreateControl(nil, xpTrack, CT_STATUSBAR)
    xpStatus:SetTexture(XP_BAR_TEXTURE)
    xpStatus:SetMinMax(0, 1)
    xpStatus:SetValue(0)
    xpStatus:SetDrawLevel(3)
    hud.xpStatus = xpStatus

    local xpLabel = WINDOW_MANAGER:CreateControl(nil, xpTrack, CT_LABEL)
    xpLabel:SetAnchorFill(xpTrack)
    xpLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    xpLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    xpLabel:SetColor(1, 1, 1, 1)
    xpLabel:SetMouseEnabled(false)
    xpLabel:SetDrawLevel(4)
    hud.xpLabel = xpLabel

    local enlightenmentTrack = WINDOW_MANAGER:CreateControl(nil, hud, CT_BACKDROP)
    enlightenmentTrack:SetCenterColor(0, 0, 0, 0.95)
    enlightenmentTrack:SetEdgeColor(0, 0, 0, 0)
    enlightenmentTrack:SetEdgeTexture("", 1, 1, 0, 0)
    enlightenmentTrack:SetMouseEnabled(false)
    enlightenmentTrack:SetDrawLevel(2)
    enlightenmentTrack:SetHidden(true)
    hud.enlightenmentTrack = enlightenmentTrack

    local enlightenmentFill = WINDOW_MANAGER:CreateControl(nil, enlightenmentTrack, CT_BACKDROP)
    enlightenmentFill:SetEdgeColor(0, 0, 0, 0)
    enlightenmentFill:SetEdgeTexture("", 1, 1, 0, 0)
    enlightenmentFill:SetDrawLevel(3)
    enlightenmentFill:SetHidden(true)
    hud.enlightenmentFill = enlightenmentFill

    return hud
end

local function GetFont()
    local settings = GetSettings()
    local key = tostring(settings.font) .. ":" .. tostring(settings.fontSize)
    if fontString and fontKey == key then
        return fontString
    end

    fontKey = key
    fontString = NQOL.Util.CreateFontString(settings.font, settings.fontSize, "ZoFontGamepad18")
    return fontString
end

local function GetXpBarHeight(settings)
    return math.max(XP_BAR_MIN_HEIGHT, settings.xpBarFontSize + 4)
end

local function GetXpFont(settings)
    local key = tostring(settings.xpBarFont) .. ":" .. tostring(settings.xpBarFontSize)
    if xpFontString and xpFontKey == key then
        return xpFontString
    end

    xpFontKey = key
    xpFontString = NQOL.Util.CreateFontString(settings.xpBarFont, settings.xpBarFontSize, "ZoFontGamepad18")
    return xpFontString
end

local function GetLabelControl(index)
    local control = labelControls[index]
    if control or not hud or not WINDOW_MANAGER then
        return control
    end

    control = WINDOW_MANAGER:CreateControl(nil, hud, CT_LABEL)
    control:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    control:SetMouseEnabled(false)
    labelControls[index] = control
    return control
end

local function GetMeasureLabel()
    if measureLabel or not WINDOW_MANAGER or not GuiRoot then
        return measureLabel
    end

    measureLabel = WINDOW_MANAGER:CreateControl("NQOL_UI_PlayerInfoMeasureLabel", GuiRoot, CT_LABEL)
    measureLabel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, -4096, -4096)
    measureLabel:SetMouseEnabled(false)
    measureLabel:SetHidden(false)
    measureLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    if measureLabel.SetDimensionConstraints and AUTO_SIZE then
        measureLabel:SetDimensionConstraints(AUTO_SIZE, AUTO_SIZE, AUTO_SIZE, AUTO_SIZE)
    end

    return measureLabel
end

local function GetTextureControl(index)
    local control = textureControls[index]
    if control or not hud or not WINDOW_MANAGER then
        return control
    end

    control = WINDOW_MANAGER:CreateControl(nil, hud, CT_TEXTURE)
    control:SetMouseEnabled(false)
    textureControls[index] = control
    return control
end

local function HideUnusedControls(firstUnusedLabel, firstUnusedTexture)
    for index = firstUnusedLabel, #labelControls do
        labelControls[index]:SetHidden(true)
    end

    for index = firstUnusedTexture, #textureControls do
        textureControls[index]:SetHidden(true)
    end
end

local function GetClassIcon()
    local classId = GetUnitClassId and GetUnitClassId("player") or nil
    if classId and ZO_GetGamepadClassIcon then
        local icon = ZO_GetGamepadClassIcon(classId)
        if IsNonEmptyString(icon) then
            return icon
        end
    end

    if classId and ZO_GetClassIcon then
        local icon = ZO_GetClassIcon(classId)
        if IsNonEmptyString(icon) then
            return icon
        end
    end

    return nil
end

local function GetChampionOrLevelText()
    local championPoints = GetUnitChampionPoints and tonumber(GetUnitChampionPoints("player")) or 0
    local canGainChampionPoints = CanUnitGainChampionPoints and CanUnitGainChampionPoints("player") == true

    if canGainChampionPoints and championPoints > 0 then
        return tostring(championPoints), CHAMPION_ICON
    end

    local level = GetUnitLevel and tonumber(GetUnitLevel("player")) or 0
    return "L" .. tostring(level), nil
end

local function GetFieldValue(field)
    if field.key == "playerId" then
        return GetDisplayName and GetDisplayName() or ""
    elseif field.key == "characterName" then
        return GetUnitName and GetUnitName("player") or ""
    elseif field.key == "championPoints" then
        return GetChampionOrLevelText()
    elseif field.key == "className" then
        local className = GetUnitClass and GetUnitClass("player") or ""
        if IsNonEmptyString(className) then
            return className
        end

        local classId = GetUnitClassId and GetUnitClassId("player") or nil
        if classId and GetClassName then
            return GetClassName(GENDER_MALE, classId) or ""
        end
    elseif field.key == "classIcon" then
        return GetClassIcon()
    end

    return ""
end

local function GetPlacementParts(value)
    if type(value) ~= "string" or value == PLACEMENT_OFF then
        return nil, nil
    end

    local side = string.sub(value, 1, 1)
    local slot = tonumber(string.sub(value, 2))
    if (side == LEFT_SIDE or side == RIGHT_SIDE) and slot and slot >= 1 and slot <= 5 then
        return side, slot
    end

    return nil, nil
end

local function BuildRenderItems(side)
    local items = {}
    local fields = GetSettings().fields

    for index, field in ipairs(FIELD_DEFINITIONS) do
        local placementSide, slot = GetPlacementParts(fields[field.key])
        if placementSide == side then
            local value, iconTexture = GetFieldValue(field)
            if IsNonEmptyString(value) then
                items[#items + 1] = {
                    field = field,
                    value = value,
                    iconTexture = iconTexture,
                    slot = slot,
                    order = index,
                }
            end
        end
    end

    table.sort(items, function(left, right)
        if left.slot ~= right.slot then
            return left.slot < right.slot
        end

        return left.order < right.order
    end)

    return items
end

local function MeasureLabel(label, text, font)
    label:SetFont(font)
    label:SetText(text)

    local textWidth = label.GetTextWidth and label:GetTextWidth() or 0

    return math.max(tonumber(textWidth) or 0, 1)
end

local function GetIconSize(settings)
    return settings.fontSize + 4
end

local function GetRowHeight(settings)
    return math.ceil(math.max(settings.fontSize + VERTICAL_PADDING, GetIconSize(settings) + 4))
end

local function GetHudHeight(settings)
    local height = GetRowHeight(settings)
    if settings.xpBar then
        height = height + XP_BAR_GAP + GetXpBarHeight(settings) + XP_BAR_BOTTOM_PADDING
        if settings.enlightenmentBar then
            height = height + ENLIGHTENMENT_BAR_HEIGHT
        end
    end

    return height
end

local function MeasureItem(item, font, settings)
    if item.field.icon then
        return GetIconSize(settings)
    end

    local label = GetMeasureLabel()
    if not label then
        return 1
    end

    local width = MeasureLabel(label, tostring(item.value or ""), font)
    if item.iconTexture then
        width = width + CP_ICON_GAP + GetIconSize(settings)
    end

    return width
end

local function MeasureItems(items, font, settings)
    local width = 0
    for index, item in ipairs(items) do
        if index > 1 then
            width = width + ITEM_GAP
        end
        width = width + MeasureItem(item, font, settings)
    end

    return width
end

local function RenderLabel(item, x, fromRight, labelIndex, font, settings, height, gap)
    local label = GetLabelControl(labelIndex)
    if not label then
        return x, labelIndex
    end

    gap = gap or ITEM_GAP
    local text = tostring(item.value or "")
    local width = MeasureLabel(GetMeasureLabel() or label, text, font)

    label:ClearAnchors()
    label:SetFont(font)
    label:SetText(text)
    label:SetDimensions(width, height)
    local color = item.field.key == "championPoints" and settings.championPointsColor or settings.textColor
    label:SetColor(color.r, color.g, color.b, color.a)
    label:SetHorizontalAlignment(fromRight and TEXT_ALIGN_RIGHT or TEXT_ALIGN_LEFT)
    if fromRight then
        x = x - width
    end
    label:SetAnchor(TOPLEFT, hud, TOPLEFT, x, 0)
    label:SetHidden(false)

    if fromRight then
        return x - gap, labelIndex + 1
    end

    return x + width + gap, labelIndex + 1
end

local function RenderIcon(item, x, fromRight, textureIndex, settings, height, gap)
    local texture = GetTextureControl(textureIndex)
    if not texture then
        return x, textureIndex
    end

    gap = gap or ITEM_GAP
    local size = GetIconSize(settings)
    local y = (height - size) * 0.5
    local color = item.iconTexture and settings.cpIconColor or settings.iconColor

    texture:ClearAnchors()
    texture:SetDimensions(size, size)
    texture:SetTexture(item.iconTexture or item.value)
    texture:SetColor(color.r, color.g, color.b, color.a)
    if fromRight then
        x = x - size
    end
    texture:SetAnchor(TOPLEFT, hud, TOPLEFT, x, y)
    texture:SetHidden(false)

    if fromRight then
        return x - gap, textureIndex + 1
    end

    return x + size + gap, textureIndex + 1
end

local function RenderItems(items, x, fromRight, labelIndex, textureIndex, font, settings, height)
    for _, item in ipairs(items) do
        if item.field.icon then
            x, textureIndex = RenderIcon(item, x, fromRight, textureIndex, settings, height)
        elseif item.iconTexture and fromRight then
            x, labelIndex = RenderLabel(item, x, true, labelIndex, font, settings, height, CP_ICON_GAP)
            x, textureIndex = RenderIcon(item, x, true, textureIndex, settings, height)
        elseif item.iconTexture then
            x, textureIndex = RenderIcon(item, x, false, textureIndex, settings, height, CP_ICON_GAP)
            x, labelIndex = RenderLabel(item, x, false, labelIndex, font, settings, height)
        else
            x, labelIndex = RenderLabel(item, x, fromRight, labelIndex, font, settings, height)
        end
    end

    return labelIndex, textureIndex
end

local function GetXpProgress()
    local currentXp
    local totalXp

    if CanUnitGainChampionPoints("player") then
        local championPoints = GetPlayerChampionPointsEarned()
        currentXp = GetPlayerChampionXP()
        totalXp = GetNumChampionXPInChampionPoint(championPoints)
    else
        local level = GetUnitLevel("player")
        currentXp = GetUnitXP("player")
        totalXp = GetNumExperiencePointsInLevel(level)
    end

    if not totalXp or totalXp <= 0 then
        return 1, 1, GetString(SI_EXPERIENCE_LIMIT_REACHED)
    end

    currentXp = Clamp(tonumber(currentXp) or 0, 0, totalXp)
    local percentage = math.floor(currentXp / totalXp * 100)
    local text = zo_strformat(
        SI_EXPERIENCE_CURRENT_MAX_PERCENT,
        ZO_CommaDelimitNumber(currentXp),
        ZO_CommaDelimitNumber(totalXp),
        percentage
    )
    return currentXp, totalXp, text
end

local function GetEnlightenmentProgress()
    if not IsEnlightenedAvailableForCharacter
        or not IsEnlightenedAvailableForCharacter()
        or not GetEnlightenedPool
        or not GetEnlightenedMultiplier
    then
        return 0, ENLIGHTENMENT_POOL_MAX_XP
    end

    local pool = tonumber(GetEnlightenedPool()) or 0
    local multiplier = tonumber(GetEnlightenedMultiplier()) or 0
    local remainingXp = pool * (multiplier + 1)
    return Clamp(remainingXp, 0, ENLIGHTENMENT_POOL_MAX_XP), ENLIGHTENMENT_POOL_MAX_XP
end

local function RenderEnlightenmentBar(width, y, settings)
    if not settings.enlightenmentBar then
        hud.enlightenmentTrack:SetHidden(true)
        return
    end

    local remainingXp, maximum = GetEnlightenmentProgress()
    if settingsPanelVisible and remainingXp <= 0 then
        remainingXp = maximum * ENLIGHTENMENT_PREVIEW_PROGRESS
    end

    local color = settings.enlightenmentBarColor
    hud.enlightenmentTrack:ClearAnchors()
    hud.enlightenmentTrack:SetAnchor(TOPLEFT, hud, TOPLEFT, 0, y)
    hud.enlightenmentTrack:SetDimensions(width, ENLIGHTENMENT_BAR_HEIGHT)
    hud.enlightenmentTrack:SetCenterColor(0, 0, 0, 0.95)
    hud.enlightenmentTrack:SetHidden(false)

    local progress = Clamp(remainingXp / maximum, 0, 1)
    local fillWidth = math.floor(width * progress + 0.5)
    if remainingXp > 0 then
        fillWidth = math.max(fillWidth, 1)
    end

    hud.enlightenmentFill:ClearAnchors()
    hud.enlightenmentFill:SetAnchor(TOPLEFT, hud.enlightenmentTrack, TOPLEFT, 0, 0)
    hud.enlightenmentFill:SetDimensions(fillWidth, ENLIGHTENMENT_BAR_HEIGHT)
    hud.enlightenmentFill:SetCenterColor(color.r, color.g, color.b, color.a)
    hud.enlightenmentFill:SetHidden(fillWidth <= 0)
end

local function RenderXpBar(width, rowHeight, settings)
    if not settings.xpBar then
        hud.xpTrack:SetHidden(true)
        hud.enlightenmentTrack:SetHidden(true)
        return
    end

    local barHeight = GetXpBarHeight(settings)
    local currentXp, totalXp, text = GetXpProgress()
    local y = rowHeight + XP_BAR_GAP
    local enlightenmentHeight = settings.enlightenmentBar and ENLIGHTENMENT_BAR_HEIGHT or 0

    RenderEnlightenmentBar(width, y, settings)

    hud.xpTrack:ClearAnchors()
    hud.xpTrack:SetAnchor(TOPLEFT, hud, TOPLEFT, 0, y + enlightenmentHeight)
    hud.xpTrack:SetDimensions(width, barHeight)
    hud.xpTrack:SetCenterColor(0, 0, 0, settings.xpBarBackgroundOpacity * 0.0095)
    hud.xpTrack:SetHidden(false)

    hud.xpStatus:ClearAnchors()
    hud.xpStatus:SetAnchor(TOPLEFT, hud.xpTrack, TOPLEFT, XP_BAR_INSET, XP_BAR_INSET)
    hud.xpStatus:SetAnchor(BOTTOMRIGHT, hud.xpTrack, BOTTOMRIGHT, -XP_BAR_INSET, -XP_BAR_INSET)
    hud.xpStatus:SetColor(0.08, 0.72, 0.82, 1)
    hud.xpStatus:SetMinMax(0, totalXp)
    hud.xpStatus:SetValue(currentXp)

    hud.xpLabel:SetFont(GetXpFont(settings))
    hud.xpLabel:SetText(text)
    hud.xpLabel:SetColor(settings.xpBarTextColor.r, settings.xpBarTextColor.g, settings.xpBarTextColor.b, settings.xpBarTextColor.a)
end

local function ApplyHud()
    if not ShouldShowHud() then
        if hud then
            hud:SetHidden(true)
            HideUnusedControls(1, 1)
        end
        return
    end

    local control = GetHud()
    if not control then
        return
    end

    local settings = GetSettings()
    local font = GetFont()
    local leftItems = BuildRenderItems(LEFT_SIDE)
    local rightItems = BuildRenderItems(RIGHT_SIDE)
    local leftWidth = MeasureItems(leftItems, font, settings)
    local rightWidth = MeasureItems(rightItems, font, settings)
    local separation = leftWidth > 0 and rightWidth > 0 and settings.separation or 0
    local width = math.ceil(PADDING * 2 + leftWidth + separation + rightWidth)
    local rowHeight = GetRowHeight(settings)
    local height = GetHudHeight(settings)
    local x = math.max(GetScreenWidth() - width, 0) * settings.horizontalPosition * 0.01
    local y = math.max(GetScreenHeight() - height, 0) * settings.verticalPosition * 0.01

    control:ClearAnchors()
    control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
    control:SetDimensions(width, height)
    control.backdrop:ClearAnchors()
    control.backdrop:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
    control.backdrop:SetDimensions(width, rowHeight)
    control.backdrop:SetCenterColor(0, 0, 0, settings.backgroundOpacity * 0.01)
    control:SetHidden(false)

    local labelIndex = 1
    local textureIndex = 1
    labelIndex, textureIndex = RenderItems(leftItems, PADDING, false, labelIndex, textureIndex, font, settings, rowHeight)
    labelIndex, textureIndex = RenderItems(rightItems, width - PADDING, true, labelIndex, textureIndex, font, settings, rowHeight)
    HideUnusedControls(labelIndex, textureIndex)
    RenderXpBar(width, rowHeight, settings)
end

local function QueueApply()
    if applyQueued then
        return
    end

    if not zo_callLater then
        ApplyHud()
        return
    end

    applyQueued = true
    zo_callLater(function()
        applyQueued = false
        ApplyHud()
    end, APPLY_DELAY_MS)
end

local function RegisterRefreshEvents()
    if eventsRegistered or not EVENT_MANAGER then
        return
    end

    eventsRegistered = true
    EVENT_MANAGER:RegisterForEvent(NAMESPACE, EVENT_PLAYER_ACTIVATED, function()
        QueueApply()
    end)

    if EVENT_LEVEL_UPDATE then
        EVENT_MANAGER:RegisterForEvent(NAMESPACE, EVENT_LEVEL_UPDATE, function(_, unitTag)
            if unitTag == "player" then
                QueueApply()
            end
        end)
        if REGISTER_FILTER_UNIT_TAG then
            EVENT_MANAGER:AddFilterForEvent(NAMESPACE, EVENT_LEVEL_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
        end
    end

    if EVENT_EXPERIENCE_UPDATE then
        EVENT_MANAGER:RegisterForEvent(NAMESPACE, EVENT_EXPERIENCE_UPDATE, function(_, unitTag)
            if unitTag == "player" and GetSettings().xpBar then
                QueueApply()
            end
        end)
        if REGISTER_FILTER_UNIT_TAG then
            EVENT_MANAGER:AddFilterForEvent(NAMESPACE, EVENT_EXPERIENCE_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
        end
    end

    if EVENT_CHAMPION_XP_UPDATE then
        EVENT_MANAGER:RegisterForEvent(NAMESPACE, EVENT_CHAMPION_XP_UPDATE, function()
            if GetSettings().xpBar then
                QueueApply()
            end
        end)
    end

    if EVENT_ENLIGHTENED_STATE_GAINED then
        EVENT_MANAGER:RegisterForEvent(NAMESPACE, EVENT_ENLIGHTENED_STATE_GAINED, function()
            local settings = GetSettings()
            if settings.xpBar and settings.enlightenmentBar then
                QueueApply()
            end
        end)
    end

    if EVENT_ENLIGHTENED_STATE_LOST then
        EVENT_MANAGER:RegisterForEvent(NAMESPACE, EVENT_ENLIGHTENED_STATE_LOST, function()
            local settings = GetSettings()
            if settings.xpBar and settings.enlightenmentBar then
                QueueApply()
            end
        end)
    end

    if EVENT_CHAMPION_POINT_UPDATE then
        EVENT_MANAGER:RegisterForEvent(NAMESPACE, EVENT_CHAMPION_POINT_UPDATE, function(_, unitTag)
            if unitTag == "player" then
                QueueApply()
            end
        end)
        if REGISTER_FILTER_UNIT_TAG then
            EVENT_MANAGER:AddFilterForEvent(NAMESPACE, EVENT_CHAMPION_POINT_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
        end
    end

    if not sceneCallbackInstalled and SCENE_MANAGER and SCENE_MANAGER.RegisterCallback then
        sceneCallbackInstalled = true
        SCENE_MANAGER:RegisterCallback("SceneStateChanged", QueueApply)
    end
end

local function UnregisterRefreshEvents()
    if eventsRegistered and EVENT_MANAGER then
        EVENT_MANAGER:UnregisterForEvent(NAMESPACE, EVENT_PLAYER_ACTIVATED)
        if EVENT_LEVEL_UPDATE then
            EVENT_MANAGER:UnregisterForEvent(NAMESPACE, EVENT_LEVEL_UPDATE)
        end
        if EVENT_EXPERIENCE_UPDATE then
            EVENT_MANAGER:UnregisterForEvent(NAMESPACE, EVENT_EXPERIENCE_UPDATE)
        end
        if EVENT_CHAMPION_XP_UPDATE then
            EVENT_MANAGER:UnregisterForEvent(NAMESPACE, EVENT_CHAMPION_XP_UPDATE)
        end
        if EVENT_ENLIGHTENED_STATE_GAINED then
            EVENT_MANAGER:UnregisterForEvent(NAMESPACE, EVENT_ENLIGHTENED_STATE_GAINED)
        end
        if EVENT_ENLIGHTENED_STATE_LOST then
            EVENT_MANAGER:UnregisterForEvent(NAMESPACE, EVENT_ENLIGHTENED_STATE_LOST)
        end
        if EVENT_CHAMPION_POINT_UPDATE then
            EVENT_MANAGER:UnregisterForEvent(NAMESPACE, EVENT_CHAMPION_POINT_UPDATE)
        end
        eventsRegistered = false
    end

    if sceneCallbackInstalled
        and SCENE_MANAGER
        and SCENE_MANAGER.UnregisterCallback
    then
        SCENE_MANAGER:UnregisterCallback("SceneStateChanged", QueueApply)
        sceneCallbackInstalled = false
    end
end

local function ShouldRun()
    if not HasEnabledField() then
        return false
    end

    local settings = GetSettings()
    return settings.enabled == true
        or (settingsPanelVisible and settings.showInSettings == true)
end

local function UpdateRuntime()
    if ShouldRun() then
        RegisterRefreshEvents()
        QueueApply()
        return
    end

    UnregisterRefreshEvents()
    if hud then
        hud:SetHidden(true)
        HideUnusedControls(1, 1)
    end
end

function PlayerInfo.InitializeSavedVariables()
    savedVariables = NQOL.Settings.NewAccountWide(defaults)
    GetSettings()
end

function PlayerInfo.Initialize()
    if initialized then
        return
    end

    initialized = true
    UpdateRuntime()
end

function PlayerInfo.SetSettingsPanelVisible(visible)
    settingsPanelVisible = visible == true
    UpdateRuntime()
end

function PlayerInfo.GetEnabled() return GetSettings().enabled end
function PlayerInfo.SetEnabled(value) GetSettings().enabled = value == true; UpdateRuntime() end
function PlayerInfo.GetEnabledDefault() return defaults.ui.playerInfo.enabled end
function PlayerInfo.GetShowInSettings() return GetSettings().showInSettings end
function PlayerInfo.SetShowInSettings(value) GetSettings().showInSettings = value == true; UpdateRuntime() end
function PlayerInfo.GetXpBar() return GetSettings().xpBar end
function PlayerInfo.SetXpBar(value) GetSettings().xpBar = value == true; QueueApply() end
function PlayerInfo.GetXpBarDefault() return defaults.ui.playerInfo.xpBar end
function PlayerInfo.GetXpBarFont() return GetSettings().xpBarFont end
function PlayerInfo.SetXpBarFont(value) if not NQOL.Util.IsFontChoice(value) then value = defaults.ui.playerInfo.xpBarFont end; GetSettings().xpBarFont = value; xpFontString = nil; QueueApply() end
function PlayerInfo.GetXpBarFontSize() return GetSettings().xpBarFontSize end
function PlayerInfo.SetXpBarFontSize(value) GetSettings().xpBarFontSize = Clamp(Round(value), FONT_SIZE_MIN, FONT_SIZE_MAX); xpFontString = nil; QueueApply() end
function PlayerInfo.GetHorizontalPosition() return GetSettings().horizontalPosition end
function PlayerInfo.SetHorizontalPosition(value) GetSettings().horizontalPosition = Clamp(value, 0, 100); QueueApply() end
function PlayerInfo.GetVerticalPosition() return GetSettings().verticalPosition end
function PlayerInfo.SetVerticalPosition(value) GetSettings().verticalPosition = Clamp(value, 0, 100); QueueApply() end
function PlayerInfo.GetSeparation() return GetSettings().separation end
function PlayerInfo.SetSeparation(value) GetSettings().separation = Clamp(Round(value), SEPARATION_MIN, SEPARATION_MAX); QueueApply() end
function PlayerInfo.GetFont() return GetSettings().font end
function PlayerInfo.SetFont(value) if not NQOL.Util.IsFontChoice(value) then value = defaults.ui.playerInfo.font end; GetSettings().font = value; fontString = nil; QueueApply() end
function PlayerInfo.GetFontSize() return GetSettings().fontSize end
function PlayerInfo.SetFontSize(value) GetSettings().fontSize = Clamp(Round(value), FONT_SIZE_MIN, FONT_SIZE_MAX); fontString = nil; QueueApply() end

function PlayerInfo.GetTextColor()
    local color = GetSettings().textColor
    return color.r, color.g, color.b, color.a
end

function PlayerInfo.SetTextColor(red, green, blue, alpha)
    local color = GetSettings().textColor
    color.r = Clamp(red, 0, 1)
    color.g = Clamp(green, 0, 1)
    color.b = Clamp(blue, 0, 1)
    color.a = Clamp(alpha, 0, 1)
    QueueApply()
end

function PlayerInfo.GetChampionPointsColor()
    local color = GetSettings().championPointsColor
    return color.r, color.g, color.b, color.a
end

function PlayerInfo.SetChampionPointsColor(red, green, blue, alpha)
    local color = GetSettings().championPointsColor
    color.r = Clamp(red, 0, 1)
    color.g = Clamp(green, 0, 1)
    color.b = Clamp(blue, 0, 1)
    color.a = Clamp(alpha, 0, 1)
    QueueApply()
end

function PlayerInfo.GetCpIconColor()
    local color = GetSettings().cpIconColor
    return color.r, color.g, color.b, color.a
end

function PlayerInfo.SetCpIconColor(red, green, blue, alpha)
    local color = GetSettings().cpIconColor
    color.r = Clamp(red, 0, 1)
    color.g = Clamp(green, 0, 1)
    color.b = Clamp(blue, 0, 1)
    color.a = Clamp(alpha, 0, 1)
    QueueApply()
end

function PlayerInfo.GetIconColor()
    local color = GetSettings().iconColor
    return color.r, color.g, color.b, color.a
end

function PlayerInfo.SetIconColor(red, green, blue, alpha)
    local color = GetSettings().iconColor
    color.r = Clamp(red, 0, 1)
    color.g = Clamp(green, 0, 1)
    color.b = Clamp(blue, 0, 1)
    color.a = Clamp(alpha, 0, 1)
    QueueApply()
end

function PlayerInfo.GetXpBarTextColor()
    local color = GetSettings().xpBarTextColor
    return color.r, color.g, color.b, color.a
end

function PlayerInfo.SetXpBarTextColor(red, green, blue, alpha)
    local color = GetSettings().xpBarTextColor
    color.r = Clamp(red, 0, 1)
    color.g = Clamp(green, 0, 1)
    color.b = Clamp(blue, 0, 1)
    color.a = Clamp(alpha, 0, 1)
    QueueApply()
end

function PlayerInfo.GetXpBarBackgroundOpacity() return GetSettings().xpBarBackgroundOpacity end
function PlayerInfo.SetXpBarBackgroundOpacity(value) GetSettings().xpBarBackgroundOpacity = Clamp(Round(value), BACKGROUND_OPACITY_MIN, BACKGROUND_OPACITY_MAX); QueueApply() end

function PlayerInfo.GetEnlightenmentBar() return GetSettings().enlightenmentBar end
function PlayerInfo.SetEnlightenmentBar(value) GetSettings().enlightenmentBar = value == true; QueueApply() end
function PlayerInfo.GetEnlightenmentBarDefault() return defaults.ui.playerInfo.enlightenmentBar end

function PlayerInfo.GetEnlightenmentBarColor()
    local color = GetSettings().enlightenmentBarColor
    return color.r, color.g, color.b, color.a
end

function PlayerInfo.SetEnlightenmentBarColor(red, green, blue, alpha)
    local color = GetSettings().enlightenmentBarColor
    color.r = Clamp(red, 0, 1)
    color.g = Clamp(green, 0, 1)
    color.b = Clamp(blue, 0, 1)
    color.a = Clamp(alpha, 0, 1)
    QueueApply()
end

function PlayerInfo.GetBackgroundOpacity() return GetSettings().backgroundOpacity end
function PlayerInfo.SetBackgroundOpacity(value) GetSettings().backgroundOpacity = Clamp(Round(value), BACKGROUND_OPACITY_MIN, BACKGROUND_OPACITY_MAX); QueueApply() end
function PlayerInfo.GetFieldPlacement(fieldKey) return GetSettings().fields[fieldKey] or PLACEMENT_OFF end
function PlayerInfo.SetFieldPlacement(fieldKey, value) if not VALID_PLACEMENTS[value] then value = PLACEMENT_OFF end; GetSettings().fields[fieldKey] = value; UpdateRuntime() end
function PlayerInfo.GetPlacementChoices() return PLACEMENT_CHOICES end
function PlayerInfo.GetPlacementChoiceNames() return PLACEMENT_CHOICE_NAMES end
function PlayerInfo.GetFontChoices() return NQOL.Util.GetFontChoices() end
function PlayerInfo.GetFontChoiceNames() return NQOL.Util.GetFontChoiceNames() end
function PlayerInfo.GetSeparationMin() return SEPARATION_MIN end
function PlayerInfo.GetSeparationMax() return SEPARATION_MAX end
function PlayerInfo.GetFontSizeMin() return FONT_SIZE_MIN end
function PlayerInfo.GetFontSizeMax() return FONT_SIZE_MAX end
function PlayerInfo.GetBackgroundOpacityMin() return BACKGROUND_OPACITY_MIN end
function PlayerInfo.GetBackgroundOpacityMax() return BACKGROUND_OPACITY_MAX end
function PlayerInfo.GetBarBackgroundOpacityMin() return BACKGROUND_OPACITY_MIN end
function PlayerInfo.GetBarBackgroundOpacityMax() return BACKGROUND_OPACITY_MAX end
function PlayerInfo.GetXpBarFontSizeMin() return FONT_SIZE_MIN end
function PlayerInfo.GetXpBarFontSizeMax() return FONT_SIZE_MAX end

function PlayerInfo.GetEnabledLabel() return NQOL.L("features.ui_player_info.enabled_label") end
function PlayerInfo.GetEnabledTooltip() return NQOL.L("features.ui_player_info.enabled_tooltip") end
function PlayerInfo.GetShowInSettingsLabel() return NQOL.L("features.ui_player_info.show_in_settings_label") end
function PlayerInfo.GetShowInSettingsTooltip() return NQOL.L("features.ui_player_info.show_in_settings_tooltip") end
function PlayerInfo.GetXpBarLabel() return NQOL.L("features.ui_player_info.xp_bar_label") end
function PlayerInfo.GetXpBarTooltip() return NQOL.L("features.ui_player_info.xp_bar_tooltip") end
function PlayerInfo.GetXpBarBackgroundOpacityLabel() return NQOL.L("features.ui_player_info.xp_bar_background_opacity_label") end
function PlayerInfo.GetXpBarBackgroundOpacityTooltip() return NQOL.L("features.ui_player_info.xp_bar_background_opacity_tooltip") end
function PlayerInfo.GetXpBarFontLabel() return NQOL.L("features.ui_player_info.xp_bar_font_label") end
function PlayerInfo.GetXpBarFontTooltip() return NQOL.L("features.ui_player_info.xp_bar_font_tooltip") end
function PlayerInfo.GetXpBarFontSizeLabel() return NQOL.L("features.ui_player_info.xp_bar_font_size_label") end
function PlayerInfo.GetXpBarFontSizeTooltip() return NQOL.L("features.ui_player_info.xp_bar_font_size_tooltip") end
function PlayerInfo.GetXpBarTextColorLabel() return NQOL.L("features.ui_player_info.xp_bar_text_color_label") end
function PlayerInfo.GetXpBarTextColorTooltip() return NQOL.L("features.ui_player_info.xp_bar_text_color_tooltip") end
function PlayerInfo.GetEnlightenmentBarLabel() return NQOL.L("features.ui_player_info.enabled_label") end
function PlayerInfo.GetEnlightenmentBarTooltip() return NQOL.L("features.ui_player_info.enlightenment_bar_tooltip") end
function PlayerInfo.GetEnlightenmentBarColorLabel() return NQOL.L("features.ui_player_info.enlightenment_bar_color_label") end
function PlayerInfo.GetEnlightenmentBarColorTooltip() return NQOL.L("features.ui_player_info.enlightenment_bar_color_tooltip") end
function PlayerInfo.GetHorizontalPositionLabel() return NQOL.L("features.ui_player_info.horizontal_position_label") end
function PlayerInfo.GetHorizontalPositionTooltip() return NQOL.L("features.ui_player_info.horizontal_position_tooltip") end
function PlayerInfo.GetVerticalPositionLabel() return NQOL.L("features.ui_player_info.vertical_position_label") end
function PlayerInfo.GetVerticalPositionTooltip() return NQOL.L("features.ui_player_info.vertical_position_tooltip") end
function PlayerInfo.GetSeparationLabel() return NQOL.L("features.ui_player_info.separation_label") end
function PlayerInfo.GetSeparationTooltip() return NQOL.L("features.ui_player_info.separation_tooltip") end
function PlayerInfo.GetFontLabel() return NQOL.L("features.ui_player_info.font_label") end
function PlayerInfo.GetFontTooltip() return NQOL.L("features.ui_player_info.font_tooltip") end
function PlayerInfo.GetFontSizeLabel() return NQOL.L("features.ui_player_info.font_size_label") end
function PlayerInfo.GetFontSizeTooltip() return NQOL.L("features.ui_player_info.font_size_tooltip") end
function PlayerInfo.GetTextColorLabel() return NQOL.L("features.ui_player_info.text_color_label") end
function PlayerInfo.GetTextColorTooltip() return NQOL.L("features.ui_player_info.text_color_tooltip") end
function PlayerInfo.GetChampionPointsColorLabel() return NQOL.L("features.ui_player_info.champion_points_color_label") end
function PlayerInfo.GetChampionPointsColorTooltip() return NQOL.L("features.ui_player_info.champion_points_color_tooltip") end
function PlayerInfo.GetCpIconColorLabel() return NQOL.L("features.ui_player_info.cp_icon_color_label") end
function PlayerInfo.GetCpIconColorTooltip() return NQOL.L("features.ui_player_info.cp_icon_color_tooltip") end
function PlayerInfo.GetIconColorLabel() return NQOL.L("features.ui_player_info.icon_color_label") end
function PlayerInfo.GetIconColorTooltip() return NQOL.L("features.ui_player_info.icon_color_tooltip") end
function PlayerInfo.GetBackgroundOpacityLabel() return NQOL.L("features.ui_player_info.background_opacity_label") end
function PlayerInfo.GetBackgroundOpacityTooltip() return NQOL.L("features.ui_player_info.background_opacity_tooltip") end

function PlayerInfo.GetFieldLabel(fieldKey)
    for _, field in ipairs(FIELD_DEFINITIONS) do
        if field.key == fieldKey then
            return field.label
        end
    end

    return fieldKey
end

function PlayerInfo.GetFieldTooltip()
    return NQOL.L("features.ui_player_info.field_tooltip")
end

NQOL.Features.UIPlayerInfo = PlayerInfo
