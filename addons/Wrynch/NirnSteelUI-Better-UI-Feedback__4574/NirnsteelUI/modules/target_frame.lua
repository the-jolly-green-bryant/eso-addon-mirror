local ADDON_NAME = "NirnsteelUI"
local EVENT_NAMESPACE = ADDON_NAME .. "_TargetFrame"
local STOCK_HIDE_REASON = ADDON_NAME .. "_TargetFrame"
local UNIT_TAG = "reticleover"
local PLAYER_UNIT_TAG = "reticleoverplayer"
local RECONCILE_NAMESPACE = EVENT_NAMESPACE .. "_Reconcile"

Nirnsteel_UI = Nirnsteel_UI or {}
local Nirnsteel_UI = Nirnsteel_UI
local BarVisuals = Nirnsteel_UI.BarVisuals
local LevelVisuals = Nirnsteel_UI.LevelVisuals
local TargetFrame = {}
Nirnsteel_UI.TargetFrame = TargetFrame

local HEALTH_POWER_TYPE = COMBAT_MECHANIC_FLAGS_HEALTH
local DEFAULT_POSITION = { x = 0, y = 88 }
local MIN_FEEDBACK_DELTA_RATIO = 0.015
local MIN_FEEDBACK_INTERVAL_MS = 140
local LOW_HEALTH_RATIO = 0.35
local EXECUTE_ICON_SIZE = 18
local IDENTITY_ROW_MIN_HEIGHT = 24
local IDENTITY_ICON_SIZE = 18
local CLASS_ICON_SIZE = 18
local CHAMPION_ICON_SIZE = 14
local CLASS_NAME_GAP = 6
local NAME_LEVEL_GAP = 8
local LEVEL_RANK_GAP = 6
local IDENTITY_ICON_VERTICAL_OFFSET = -2
local LEVEL_BADGE_VERTICAL_OFFSET = -1
local HEADER_BAR_GAP = 4
local MARKER_BAR_GAP = 2
local DEFAULT_EXECUTE_ICON_KEY = "crossedWeapons"
local TARGET_REFRESH_DELAYS_MS = { 40, 120, 250, 500 }
local TARGET_RECONCILE_INTERVAL_MS = 100
local TARGET_MISSING_GRACE_MS = 150
local TARGET_RECOVERY_DELAY_MS = 500
local TARGET_ERROR_LOG_INTERVAL_MS = 5000

local function GetClassTexture(classId)
    classId = tonumber(classId) or 0
    if classId <= 0 then
        return nil
    end

    local texture
    if ZO_GetPlatformClassIcon then
        texture = ZO_GetPlatformClassIcon(classId)
    end
    if (not texture or texture == "") and ZO_GetClassIcon then
        texture = ZO_GetClassIcon(classId)
    end
    if (not texture or texture == "") and GetClassIndexById and GetClassInfo then
        local classIndex = GetClassIndexById(classId)
        if classIndex then
            local _, _, _, _, _, _, keyboardIcon, gamepadIcon = GetClassInfo(classIndex)
            if IsInGamepadPreferredMode and IsInGamepadPreferredMode() then
                texture = gamepadIcon or keyboardIcon
            else
                texture = keyboardIcon or gamepadIcon
            end
        end
    end
    if (not texture or texture == "") and GetClassIcon then
        texture = GetClassIcon(classId)
    end
    return texture ~= "" and texture or nil
end

local EXECUTE_ICON_TEXTURES =
{
    crossedWeapons = "EsoUI/Art/LFG/LFG_roleIcon_dps.dds",
    battlefield = "EsoUI/Art/Icons/poi/poi_battlefield_incomplete.dds",
    groupBoss = "EsoUI/Art/Icons/poi/poi_groupboss_incomplete.dds",
    nightblade = function() return GetClassTexture(3) end,
    dragonknight = function() return GetClassTexture(1) end,
    targetMarker = function()
        return ZO_GetPlatformTargetMarkerIcon and ZO_GetPlatformTargetMarkerIcon(1) or nil
    end,
}

local DEFAULT_SETTINGS =
{
    enabled = true,
    unlocked = false,
    scale = 100,
    width = 300,
    barHeight = 25,
    opacity = 100,
    glossEnabled = true,
    barPatternEnabled = true,
    barPatternKey = "Molten",
    barPatternOpacity = 6,
    barPatternScale = 228,
    feedbackEnabled = true,
    feedbackIntensity = 95,
    lossTrailEnabled = false,
    gainPulseEnabled = true,
    spendPulseEnabled = true,
    fullResourcePulseEnabled = true,
    shieldPulseEnabled = true,
    lowResourceGlowEnabled = true,
    borderWidth = 0,
    cornerSize = 2,
    innerShadowAlpha = 60,
    outerShadowAlpha = 100,
    textFontKey = "gameSmall",
    nameTextSize = 20,
    healthTextSize = 18,
    textOutline = "thick-outline",
    textOpacity = 100,
    textInset = 6,
    textVerticalOffset = 3,
    textColor = { r = 0.96, g = 0.92, b = 0.82 },
    healthTextFormat = "numberAndPercent",
    healthTextPosition = "sides",
    shieldOverlayEnabled = true,
    shieldTextMode = "healthAndShield",
    shieldFillOpacity = 70,
    shieldFillColor = { r = 0.95, g = 0.60, b = 0.33 },
    shieldGlowEnabled = true,
    shieldGlowOpacity = 65,
    shieldGlowColor = { r = 0.95, g = 0.66, b = 0.56 },
    npcColorMode = "static",
    playerColorMode = "static",
    staticColor = { r = 0.78, g = 0.06, b = 0.08 },
    fullHealthColor = { r = 1.00, g = 1.00, b = 1.00 },
    lowHealthColor = { r = 0.58, g = 0.015, b = 0.025 },
    showClass = true,
    showLevel = true,
    showLevelStyle = true,
    showVeterancyIcon = false,
    showExecuteIcon = true,
    executeIconStyle = DEFAULT_EXECUTE_ICON_KEY,
    executeThreshold = 18,
    executePosition = "center",
    classColors =
    {
        [1] = { r = 0.85, g = 0.47, b = 0.17 },
        [2] = { r = 0.54, g = 0.39, b = 0.84 },
        [3] = { r = 0.70, g = 0.23, b = 0.28 },
        [4] = { r = 0.26, g = 0.66, b = 0.54 },
        [5] = { r = 0.40, g = 0.54, b = 0.66 },
        [6] = { r = 0.88, g = 0.75, b = 0.33 },
        [117] = { r = 0.25, g = 0.72, b = 0.47 },
    },
    unknownClassColor = { r = 0.54, g = 0.59, b = 0.66 },
}

local function Clamp(value, minimum, maximum)
    value = tonumber(value) or minimum
    return math.min(math.max(value, minimum), maximum)
end

local function CopyColor(color, fallback)
    color = color or fallback or {}
    return
    {
        r = tonumber(color.r or color[1]) or tonumber(fallback and fallback.r) or 1,
        g = tonumber(color.g or color[2]) or tonumber(fallback and fallback.g) or 1,
        b = tonumber(color.b or color[3]) or tonumber(fallback and fallback.b) or 1,
        a = tonumber(color.a or color[4]) or tonumber(fallback and fallback.a) or 1,
    }
end

local function InterpolateColor(startColor, endColor, progress)
    progress = Clamp(progress, 0, 1)
    return
    {
        r = startColor.r + ((endColor.r - startColor.r) * progress),
        g = startColor.g + ((endColor.g - startColor.g) * progress),
        b = startColor.b + ((endColor.b - startColor.b) * progress),
        a = 1,
    }
end

local function GetSettings()
    if Nirnsteel_UI.Settings and Nirnsteel_UI.Settings.GetTargetFrame then
        return Nirnsteel_UI.Settings:GetTargetFrame()
    end
    return DEFAULT_SETTINGS
end

local function GetSetting(key)
    local settings = GetSettings()
    if settings and settings[key] ~= nil then
        return settings[key]
    end
    return DEFAULT_SETTINGS[key]
end

local function GetExecuteIconTexture()
    local texture = EXECUTE_ICON_TEXTURES[GetSetting("executeIconStyle") or DEFAULT_EXECUTE_ICON_KEY]
    if type(texture) == "function" then
        texture = texture()
    end
    if not texture or texture == "" then
        texture = EXECUTE_ICON_TEXTURES[DEFAULT_EXECUTE_ICON_KEY]
    end
    return texture
end

local function IsEnabled()
    return GetSetting("enabled") ~= false
end

local function IsUnlocked()
    return IsEnabled() and GetSetting("unlocked") == true
end

local function IsHudSceneShowing()
    local hudShowing = HUD_SCENE and HUD_SCENE.IsShowing and HUD_SCENE:IsShowing()
    local hudUiShowing = HUD_UI_SCENE and HUD_UI_SCENE.IsShowing and HUD_UI_SCENE:IsShowing()
    if HUD_SCENE or HUD_UI_SCENE then
        if hudShowing or hudUiShowing then
            return true
        end
        return IsGameCameraActive and IsGameCameraActive()
            and (not IsGameCameraUIModeActive or not IsGameCameraUIModeActive())
    end
    return not IsGameCameraActive or IsGameCameraActive()
end

local function GetModeKey()
    return IsInGamepadPreferredMode and IsInGamepadPreferredMode() and "gamepad" or "keyboard"
end

local function GetPosition()
    if Nirnsteel_UI.Settings and Nirnsteel_UI.Settings.GetTargetFramePosition then
        return Nirnsteel_UI.Settings:GetTargetFramePosition(GetModeKey())
    end
    return DEFAULT_POSITION
end

local function BuildFont(sizeKey)
    local face = BarVisuals.Fonts[GetSetting("textFontKey")] or BarVisuals.Fonts.gameSmall
    local size = Clamp(GetSetting(sizeKey), 8, 36)
    local outline = GetSetting("textOutline")
    return outline == "none" and string.format("%s|%d", face, size)
        or string.format("%s|%d|%s", face, size, outline or "thick-outline")
end

local function SafeUnitCall(callback, unitTag, ...)
    if not callback or not unitTag then
        return nil
    end
    local ok, first, second, third = pcall(callback, unitTag, ...)
    if not ok then
        return nil
    end
    return first, second, third
end

local function FormatPlayerName(unitTag)
    local name = SafeUnitCall(ZO_GetPrimaryPlayerNameFromUnitTag, unitTag) or ""
    if name == "" then
        name = SafeUnitCall(GetUnitDisplayName, unitTag) or ""
    end
    if name == "" then
        name = SafeUnitCall(GetUnitName, unitTag) or SafeUnitCall(GetRawUnitName, unitTag)
    end
    return name or ""
end

local function EstimateNameWidth(text)
    text = tostring(text or "")
    text = string.gsub(text, "|c%x%x%x%x%x%x", "")
    text = string.gsub(text, "|r", "")
    text = string.gsub(text, "|t.-|t", "")
    local characterCount = zo_strlen and zo_strlen(text) or string.len(text)
    local fontSize = Clamp(GetSetting("nameTextSize"), 10, 36)
    return math.max(math.ceil(characterCount * fontSize * 0.66) + 10, 72)
end

local function GetIntrinsicNameWidth(label, text)
    local width = label.GetStringWidth and tonumber(label:GetStringWidth(text or "")) or 0
    if width <= 0 then
        width = EstimateNameWidth(text)
    end
    return math.max(math.ceil(width) + 4, 40)
end

local function FormatNumber(value)
    value = math.max(tonumber(value) or 0, 0)
    if ZO_AbbreviateAndLocalizeNumber then
        return ZO_AbbreviateAndLocalizeNumber(value, NUMBER_ABBREVIATION_PRECISION_TENTHS, USE_LOWERCASE_NUMBER_SUFFIXES)
    end
    return tostring(zo_round(value))
end

local function FormatPercent(current, maximum)
    local percent = maximum > 0 and zo_round((current / maximum) * 100) or 0
    return string.format("%d%%", Clamp(percent, 0, 100))
end

local function DoesTargetUnitExist(unitTag)
    return SafeUnitCall(DoesUnitExist, unitTag) == true
end

local function NormalizeUnitName(name)
    name = tostring(name or "")
    if zo_strformat then
        name = zo_strformat("<<1>>", name)
    end
    if LocaleAwareToLower then
        return LocaleAwareToLower(name)
    end
    return string.lower(name)
end

local function CompareUnitTags(firstTag, secondTag)
    if AreUnitsEqual then
        local ok, equal = pcall(AreUnitsEqual, firstTag, secondTag)
        if ok and equal then
            return true, false
        end
    end
    local function CollectNames(unitTag)
        local names = {}
        local function AddName(name)
            if name and name ~= "" then
                names[#names + 1] = name
            end
        end
        AddName(SafeUnitCall(GetRawUnitName, unitTag))
        AddName(SafeUnitCall(GetUnitName, unitTag))
        AddName(SafeUnitCall(GetUnitDisplayName, unitTag))
        return names
    end
    local firstNames = CollectNames(firstTag)
    local secondNames = CollectNames(secondTag)
    for firstIndex = 1, #firstNames do
        local firstName = firstNames[firstIndex]
        if firstName and firstName ~= "" then
            for secondIndex = 1, #secondNames do
                local secondName = secondNames[secondIndex]
                if secondName and secondName ~= ""
                    and NormalizeUnitName(firstName) == NormalizeUnitName(secondName) then
                    return true, false
                end
            end
        end
    end
    local identityKnown = #firstNames > 0 and #secondNames > 0
    return false, identityKnown
end

local function GetStringUnitValue(getter, preferredTag, fallbackTag)
    local value = SafeUnitCall(getter, preferredTag)
    if (value == nil or value == "") and fallbackTag then
        value = SafeUnitCall(getter, fallbackTag)
    end
    return value or ""
end

local function GetPositiveUnitValue(getter, preferredTag, fallbackTag)
    local value = tonumber((SafeUnitCall(getter, preferredTag))) or 0
    if value <= 0 and fallbackTag then
        value = tonumber((SafeUnitCall(getter, fallbackTag))) or 0
    end
    return math.max(value, 0)
end

local function GetBooleanUnitValue(getter, preferredTag, fallbackTag)
    local value = SafeUnitCall(getter, preferredTag) == true
    if not value and fallbackTag then
        value = SafeUnitCall(getter, fallbackTag) == true
    end
    return value
end

local function GetPlayerName(preferredTag, fallbackTag)
    local name = FormatPlayerName(preferredTag)
    if (not name or name == "") and fallbackTag then
        name = FormatPlayerName(fallbackTag)
    end
    return name or ""
end

local function GetTargetPower(preferredTag, fallbackTag)
    local current, maximum = SafeUnitCall(GetUnitPower, preferredTag, HEALTH_POWER_TYPE)
    if (tonumber(maximum) or 0) <= 0 and fallbackTag then
        current, maximum = SafeUnitCall(GetUnitPower, fallbackTag, HEALTH_POWER_TYPE)
    end
    return math.max(tonumber(current) or 0, 0), math.max(tonumber(maximum) or 0, 0)
end

local function GetTargetMarker(preferredTag, fallbackTag)
    local marker = SafeUnitCall(GetUnitTargetMarkerType, preferredTag) or TARGET_MARKER_TYPE_NONE
    if marker == TARGET_MARKER_TYPE_NONE and fallbackTag then
        marker = SafeUnitCall(GetUnitTargetMarkerType, fallbackTag) or TARGET_MARKER_TYPE_NONE
    end
    return marker
end

local function GetUnitAllianceValue(preferredTag, fallbackTag)
    local alliance = SafeUnitCall(GetUnitAlliance, preferredTag) or ALLIANCE_NONE
    if alliance == ALLIANCE_NONE and fallbackTag then
        alliance = SafeUnitCall(GetUnitAlliance, fallbackTag) or ALLIANCE_NONE
    end
    return alliance
end

local function GetTargetShield(unitTag, fallbackTag)
    if not GetUnitAttributeVisualizerEffectInfo then
        return 0
    end
    local value = SafeUnitCall(
        GetUnitAttributeVisualizerEffectInfo, unitTag, ATTRIBUTE_VISUAL_POWER_SHIELDING,
        STAT_MITIGATION, ATTRIBUTE_HEALTH, HEALTH_POWER_TYPE)
    if (tonumber(value) or 0) <= 0 and fallbackTag then
        value = SafeUnitCall(
            GetUnitAttributeVisualizerEffectInfo, fallbackTag, ATTRIBUTE_VISUAL_POWER_SHIELDING,
            STAT_MITIGATION, ATTRIBUTE_HEALTH, HEALTH_POWER_TYPE)
    end
    return math.max(tonumber(value) or 0, 0)
end

local function ResolvePlayerMetadataTags(primaryExists, playerExists)
    local primaryIsPlayer = primaryExists and SafeUnitCall(IsUnitPlayer, UNIT_TAG) == true
    if primaryExists and playerExists then
        local tagsMatch, identityKnown = CompareUnitTags(UNIT_TAG, PLAYER_UNIT_TAG)
        if tagsMatch then
            return PLAYER_UNIT_TAG, UNIT_TAG, true
        elseif primaryIsPlayer and not identityKnown then
            return UNIT_TAG, PLAYER_UNIT_TAG, true
        end
    end
    if primaryExists then
        return UNIT_TAG, nil, primaryIsPlayer
    end
    return PLAYER_UNIT_TAG, nil, true
end

local function GetChampionData(preferredTag, fallbackTag)
    local champion = GetBooleanUnitValue(IsUnitChampion, preferredTag, fallbackTag)
    if not champion then
        return false, 0
    end
    local points = GetPositiveUnitValue(GetUnitEffectiveChampionPoints, preferredTag, fallbackTag)
    if points <= 0 then
        points = GetPositiveUnitValue(GetUnitChampionPoints, preferredTag, fallbackTag)
    end
    return true, points
end

local function GetPlayerClassData(preferredTag, fallbackTag)
    local classId = GetPositiveUnitValue(GetUnitClassId, preferredTag, fallbackTag)
    local className = GetStringUnitValue(GetUnitClass, preferredTag, fallbackTag)
    return classId, className
end

local function GetUnitLevelValue(preferredTag, fallbackTag)
    local level = GetPositiveUnitValue(GetUnitLevel, preferredTag, fallbackTag)
    if level <= 0 then
        level = GetPositiveUnitValue(GetUnitEffectiveLevel, preferredTag, fallbackTag)
    end
    return level
end

local function IsPlayerTargetTagAvailable()
    return DoesTargetUnitExist(PLAYER_UNIT_TAG)
end

local function ReadTargetData()
    local primaryExists = DoesTargetUnitExist(UNIT_TAG)
    local playerExists = IsPlayerTargetTagAvailable()
    if not primaryExists and not playerExists then
        return nil
    end

    local unitTag = primaryExists and UNIT_TAG or PLAYER_UNIT_TAG
    local metadataUnitTag, fallbackMetadataUnitTag, isPlayer = ResolvePlayerMetadataTags(primaryExists, playerExists)
    if not primaryExists then
        isPlayer = true
    end
    local resourceFallbackTag = metadataUnitTag ~= unitTag and metadataUnitTag or fallbackMetadataUnitTag
    local current, maximum = GetTargetPower(unitTag, resourceFallbackTag)
    local champion, championPoints = GetChampionData(metadataUnitTag, fallbackMetadataUnitTag)
    local classId, className = 0, ""
    if isPlayer then
        classId, className = GetPlayerClassData(metadataUnitTag, fallbackMetadataUnitTag)
    end
    local level = GetUnitLevelValue(metadataUnitTag, fallbackMetadataUnitTag)
    local marker = GetTargetMarker(unitTag, resourceFallbackTag)
    local name = isPlayer and GetPlayerName(metadataUnitTag, fallbackMetadataUnitTag)
        or GetStringUnitValue(GetUnitName, metadataUnitTag, fallbackMetadataUnitTag)
    if name == "" then
        name = GetStringUnitValue(GetRawUnitName, metadataUnitTag, fallbackMetadataUnitTag)
    end
    return
    {
        unitTag = unitTag,
        metadataUnitTag = metadataUnitTag,
        fallbackMetadataUnitTag = fallbackMetadataUnitTag,
        name = name,
        isPlayer = isPlayer,
        classId = classId,
        className = className or "",
        classIcon = isPlayer and GetClassTexture(classId) or nil,
        level = math.max(tonumber(level) or 0, 0),
        champion = champion,
        championPoints = championPoints,
        current = math.max(tonumber(current) or 0, 0),
        maximum = math.max(tonumber(maximum) or 0, 0),
        shield = GetTargetShield(unitTag, resourceFallbackTag),
        dead = GetBooleanUnitValue(IsUnitDead, unitTag, resourceFallbackTag),
        attackable = GetBooleanUnitValue(IsUnitAttackable, unitTag, resourceFallbackTag),
        alliance = GetUnitAllianceValue(metadataUnitTag, fallbackMetadataUnitTag),
        marker = marker,
    }
end

local function GetTargetFingerprint(data)
    if not data then
        return nil
    end
    return table.concat(
    {
        tostring(data.unitTag), tostring(data.metadataUnitTag), tostring(data.name), tostring(data.isPlayer),
        tostring(data.classId), tostring(data.classIcon), tostring(data.level),
        tostring(data.champion), tostring(data.championPoints), tostring(data.current), tostring(data.maximum),
        tostring(data.shield), tostring(data.dead), tostring(data.attackable), tostring(data.alliance),
        tostring(data.marker),
    }, "\31")
end

local function GetPreviewData(player)
    if player == false then
        return
        {
            name = "The Precursor", isPlayer = false, classId = 0, className = "",
            level = 50, champion = false, championPoints = 0, current = 321800, maximum = 400000,
            shield = 0, dead = false, attackable = true, alliance = ALLIANCE_NONE,
            marker = TARGET_MARKER_TYPE_NONE, previewReaction = { r = 0.92, g = 0.17, b = 0.14 },
        }
    end
    return
    {
        name = "@NirnsteelPreview", isPlayer = true, classId = 2, className = "Sorcerer",
        level = 50, champion = true, championPoints = 2850,
        current = 64000, maximum = 420000, shield = 72000, dead = false, attackable = true,
        alliance = ALLIANCE_ALDMERI_DOMINION, marker = 3, previewVeterancy = true,
    }
end

local function GetTargetColor(data)
    if not data.isPlayer then
        if GetSetting("npcColorMode") == "reaction" then
            if data.previewReaction then
                return CopyColor(data.previewReaction)
            end
            if GetUnitReactionColor then
                local r, g, b = GetUnitReactionColor(data.unitTag or UNIT_TAG)
                if r then
                    return { r = r, g = g, b = b, a = 1 }
                end
            end
        end
        return CopyColor(GetSetting("staticColor"), DEFAULT_SETTINGS.staticColor)
    end

    local mode = GetSetting("playerColorMode")
    if mode == "class" then
        local classColors = GetSetting("classColors") or DEFAULT_SETTINGS.classColors
        return CopyColor(classColors[data.classId], GetSetting("unknownClassColor"))
    elseif mode == "health" then
        local ratio = data.maximum > 0 and data.current / data.maximum or 1
        return InterpolateColor(
            CopyColor(GetSetting("lowHealthColor"), DEFAULT_SETTINGS.lowHealthColor),
            CopyColor(GetSetting("fullHealthColor"), DEFAULT_SETTINGS.fullHealthColor),
            ratio)
    end
    return CopyColor(GetSetting("staticColor"), DEFAULT_SETTINGS.staticColor)
end

local function GetAllianceIcon(data)
    if not data.isPlayer then
        return nil, nil
    end
    local unitTag = data.metadataUnitTag or data.unitTag or UNIT_TAG
    if data.previewVeterancy then
        local icon = GetAvARankIcon and GetAvARankIcon(20)
        return icon or "EsoUI/Art/AvA/ava_allianceIcon_aldmeri.dds", { r = 0.91, g = 0.80, b = 0.28 }
    end
    if IsVeterancySeasonActive and IsInVeterancyProgressionZone and GetUnitVeterancyRank
        and IsVeterancySeasonActive() and IsInVeterancyProgressionZone() then
        local rank = tonumber((GetUnitVeterancyRank(unitTag))) or 0
        if rank > 0 and ZO_VeterancyRankData and ZO_VeterancyRankData.New then
            if ZO_VETERANCY_MANAGER and ZO_VETERANCY_MANAGER.GetNumRanks then
                rank = math.min(rank, ZO_VETERANCY_MANAGER:GetNumRanks())
            end
            local ok, rankData = pcall(function() return ZO_VeterancyRankData:New(rank) end)
            if ok and rankData and rankData.GetIcon then
                return rankData:GetIcon(), { r = 1, g = 1, b = 1 }
            end
        end
    end
    if GetUnitAvARank and GetAvARankIcon then
        local rank = tonumber((GetUnitAvARank(unitTag))) or 0
        local color = { r = 1, g = 1, b = 1 }
        if GetAllianceColor and data.alliance and data.alliance ~= ALLIANCE_NONE then
            local allianceColor = GetAllianceColor(data.alliance)
            if allianceColor and allianceColor.UnpackRGB then
                color.r, color.g, color.b = allianceColor:UnpackRGB()
            end
        end
        return GetAvARankIcon(rank), color
    end
    return nil, nil
end

local function CreateCenteredLabel(parent)
    local label = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetModifyTextType(MODIFY_TEXT_TYPE_NONE)
    label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    label:SetMaxLineCount(1)
    return label
end

function TargetFrame:GetRoot()
    if self.rootReady and self.root then
        return self.root
    end
    local root = self.root or WINDOW_MANAGER:CreateTopLevelWindow("Nirnsteel_UI_TargetFrameRoot")
    self.root = root
    root:SetDimensions(DEFAULT_SETTINGS.width, 55)
    root:SetClampedToScreen(true)
    root:SetMouseEnabled(false)
    root:SetDrawTier(DT_HIGH)
    root:SetHidden(true)

    self.identity = self.identity or WINDOW_MANAGER:CreateControl(nil, root, CT_CONTROL)
    self.identityContent = self.identityContent or WINDOW_MANAGER:CreateControl(nil, self.identity, CT_CONTROL)
    self.nameLabel = self.nameLabel or CreateCenteredLabel(self.identityContent)
    if not self.levelBadge then
        self.levelBadge = LevelVisuals:Create(self.identityContent,
        {
            height = 22,
            minimumWidth = 36,
            maximumWidth = 86,
            horizontalPadding = 6,
            font = "$(BOLD_FONT)|16|thick-outline",
            glowFont = "$(BOLD_FONT)|17|soft-shadow-thick",
            showChampionIcon = true,
            championIconSize = CHAMPION_ICON_SIZE,
            championIconGap = 3,
        })
    end
    self.targetMarker = self.targetMarker or WINDOW_MANAGER:CreateControl(nil, root, CT_TEXTURE)
    self.targetMarker:SetDimensions(IDENTITY_ICON_SIZE, IDENTITY_ICON_SIZE)
    self.targetMarker:SetDrawLayer(DL_OVERLAY)
    self.targetMarker:SetDrawLevel(8)
    self.targetMarker:SetHidden(true)
    self.classIcon = self.classIcon or WINDOW_MANAGER:CreateControl(nil, self.identityContent, CT_TEXTURE)
    self.classIcon:SetDimensions(CLASS_ICON_SIZE, CLASS_ICON_SIZE)
    self.classIcon:SetHidden(true)
    self.rankIcon = self.rankIcon or WINDOW_MANAGER:CreateControl(nil, self.identityContent, CT_TEXTURE)
    self.rankIcon:SetDimensions(IDENTITY_ICON_SIZE, IDENTITY_ICON_SIZE)

    self.health = self.health or BarVisuals:Create(root, nil, { withShield = true })
    BarVisuals:SetAlignment(self.health, BAR_ALIGNMENT_NORMAL)

    self.executeIcon = self.executeIcon or WINDOW_MANAGER:CreateControl(nil, self.health, CT_TEXTURE)
    self.executeIcon:SetDimensions(EXECUTE_ICON_SIZE, EXECUTE_ICON_SIZE)
    self.executeIcon:SetTexture(GetExecuteIconTexture())
    self.executeIcon:SetColor(1, 0.34, 0.18, 0.96)
    self.executeIcon:SetDrawLayer(DL_OVERLAY)
    self.executeIcon:SetDrawLevel(9)
    self.executeIcon:SetHidden(true)

    self.rootReady = true
    return root
end

function TargetFrame:GetMover()
    if self.moverReady and self.mover then
        return self.mover
    end
    local mover = self.mover or WINDOW_MANAGER:CreateTopLevelWindow("Nirnsteel_UI_TargetFrameMover")
    self.mover = mover
    mover:SetDimensions(DEFAULT_SETTINGS.width, 55)
    mover:SetClampedToScreen(true)
    mover:SetMouseEnabled(true)
    mover:SetMovable(false)
    mover:SetDrawTier(DT_HIGH)
    mover:SetDrawLayer(DL_OVERLAY)
    mover:SetHidden(true)
    local backdrop = self.moverBackdrop or WINDOW_MANAGER:CreateControl(nil, mover, CT_BACKDROP)
    self.moverBackdrop = backdrop
    backdrop:SetAnchorFill(mover)
    backdrop:SetCenterColor(0.02, 0.02, 0.025, 0.30)
    backdrop:SetEdgeColor(0.88, 0.72, 0.24, 0.90)
    backdrop:SetEdgeTexture("EsoUI/Art/Miscellaneous/Gamepad/edgeframeGamepadBorder_thin.dds", 128, 16, 2, 0)
    local label = self.moverLabel or CreateCenteredLabel(mover)
    self.moverLabel = label
    label:ClearAnchors()
    label:SetAnchor(TOP, mover, TOP, 0, 2)
    label:SetFont("ZoFontGameBold")
    label:SetText("Nirnsteel Target Frame")
    label:SetColor(0.95, 0.86, 0.35, 1)
    mover:SetHandler("OnMouseDown", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            control:SetMovable(true)
            control:StartMoving()
        end
    end)
    mover:SetHandler("OnMouseUp", function(control, button)
        if button ~= MOUSE_BUTTON_INDEX_LEFT then
            return
        end
        control:StopMovingOrResizing()
        control:SetMovable(false)
        local x = zo_round(control:GetLeft() + (control:GetWidth() * 0.5) - (GuiRoot:GetWidth() * 0.5))
        local y = zo_round(control:GetTop())
        if Nirnsteel_UI.Settings and Nirnsteel_UI.Settings.SetTargetFramePosition then
            Nirnsteel_UI.Settings:SetTargetFramePosition(x, y, true)
        end
        self:ApplyPosition()
    end)
    self.moverReady = true
    return mover
end

function TargetFrame:ApplyPosition()
    local position = GetPosition() or DEFAULT_POSITION
    local root = self:GetRoot()
    root:ClearAnchors()
    root:SetAnchor(TOP, GuiRoot, TOP, tonumber(position.x) or 0, tonumber(position.y) or DEFAULT_POSITION.y)
    local mover = self:GetMover()
    mover:ClearAnchors()
    mover:SetAnchor(TOP, GuiRoot, TOP, tonumber(position.x) or 0, tonumber(position.y) or DEFAULT_POSITION.y)
end

function TargetFrame:ApplyLayout(data)
    local root = self:GetRoot()
    local width = Clamp(GetSetting("width"), 180, 700)
    local barHeight = Clamp(GetSetting("barHeight"), 10, 48)
    local scale = Clamp(GetSetting("scale"), 70, 160) / 100
    local identityHeight = math.max(
        IDENTITY_ROW_MIN_HEIGHT,
        Clamp(GetSetting("nameTextSize"), 10, 36) + 4,
        self.levelBadge and self.levelBadge.height or 22)
    local totalHeight = identityHeight + HEADER_BAR_GAP + barHeight

    root:SetScale(scale)
    root:SetDimensions(width, totalHeight)
    self.identity:ClearAnchors()
    self.identity:SetAnchor(TOPLEFT, root, TOPLEFT, 0, 0)
    self.identity:SetDimensions(width, identityHeight)
    self.health:ClearAnchors()
    self.health:SetAnchor(TOPLEFT, root, TOPLEFT, 0, identityHeight + HEADER_BAR_GAP)
    local mover = self:GetMover()
    mover:SetScale(scale)
    mover:SetDimensions(width, totalHeight)
    self:ApplyPosition()
    return width, barHeight
end

function TargetFrame:ApplyStyle(width, barHeight, color)
    local textColor = CopyColor(GetSetting("textColor"), DEFAULT_SETTINGS.textColor)
    local intensity = Clamp(GetSetting("feedbackIntensity"), 0, 140) / 100
    BarVisuals:ApplyStyle(self.health,
    {
        width = width,
        height = barHeight,
        alpha = Clamp(GetSetting("opacity"), 10, 100) / 100,
        borderWidth = Clamp(GetSetting("borderWidth"), 0, 8),
        cornerSize = Clamp(GetSetting("cornerSize"), 0, 12),
        innerShadowAlpha = Clamp(GetSetting("innerShadowAlpha"), 0, 100) / 100,
        outerShadowAlpha = Clamp(GetSetting("outerShadowAlpha"), 0, 100) / 100,
        textureInfo = BarVisuals.Textures.genericTall,
        trackColor = { r = 0.01, g = 0.01, b = 0.01, a = 0.62 },
        fillStartColor = color,
        fillEndColor = color,
        glossEnabled = GetSetting("glossEnabled") ~= false,
        glossOpacity = 0.13,
        patternEnabled = GetSetting("barPatternEnabled") == true,
        patternTexture = BarVisuals.Patterns[GetSetting("barPatternKey")] or BarVisuals.Patterns.smoke,
        patternOpacity = Clamp(GetSetting("barPatternOpacity"), 0, 100) / 100,
        patternScale = Clamp(GetSetting("barPatternScale"), 24, 512),
        lossTrailEnabled = GetSetting("lossTrailEnabled") == true,
        lossTrailColor = { r = 1.00, g = 0.70, b = 0.24, a = 0.78 },
        shieldEnabled = GetSetting("shieldOverlayEnabled") ~= false,
        shieldFillColor = GetSetting("shieldFillColor"),
        shieldFillOpacity = Clamp(GetSetting("shieldFillOpacity"), 0, 100) / 100,
        shieldGlowEnabled = GetSetting("shieldGlowEnabled") ~= false,
        shieldGlowColor = GetSetting("shieldGlowColor"),
        shieldGlowOpacity = Clamp(GetSetting("shieldGlowOpacity"), 0, 100) / 100,
        shieldUseOuterDimensions = true,
        font = BuildFont("healthTextSize"),
        textColor = textColor,
        textOpacity = Clamp(GetSetting("textOpacity"), 10, 100) / 100,
        textInset = Clamp(GetSetting("textInset"), 0, 28),
        textVerticalOffset = Clamp(GetSetting("textVerticalOffset"), -8, 8),
        alignment = BAR_ALIGNMENT_NORMAL,
        lowGlowEnabled = GetSetting("feedbackEnabled") == true and GetSetting("lowResourceGlowEnabled") ~= false,
        lowGlowThreshold = LOW_HEALTH_RATIO,
        lowGlowColor = GetSetting("lowHealthColor"),
        feedbackIntensity = intensity,
    })
    local textAlpha = Clamp(GetSetting("textOpacity"), 10, 100) / 100
    self.nameLabel:SetFont(BuildFont("nameTextSize"))
    self.nameLabel:SetColor(textColor.r, textColor.g, textColor.b, textAlpha)
end

function TargetFrame:UpdateIdentity(data)
    self.nameLabel:SetText(data.name or "")
    self.nameLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    local hasLevel
    if data.champion then
        hasLevel = (tonumber(data.championPoints) or 0) > 0
    else
        hasLevel = (tonumber(data.level) or 0) > 0
    end
    local levelWidth, tierIndex = LevelVisuals:Apply(self.levelBadge, data,
    {
        shown = GetSetting("showLevel") ~= false and hasLevel,
        styled = GetSetting("showLevelStyle") ~= false,
        playOnTierUpgrade = self.sameIdentity == true,
        previousTier = self.levelTier,
    })
    local markerVisible = data.marker and data.marker ~= TARGET_MARKER_TYPE_NONE
    self.targetMarker:SetHidden(not markerVisible)
    if markerVisible and ZO_GetPlatformTargetMarkerIcon then
        self.targetMarker:SetTexture(ZO_GetPlatformTargetMarkerIcon(data.marker))
    end
    self.targetMarker:ClearAnchors()
    self.targetMarker:SetAnchor(BOTTOMRIGHT, self.health, TOPLEFT, -MARKER_BAR_GAP, -MARKER_BAR_GAP)
    local classTexture = data.classIcon
    if (not classTexture or classTexture == "") and data.isPlayer then
        classTexture = GetClassTexture(data.classId)
        data.classIcon = classTexture
    end
    local classVisible = data.isPlayer and GetSetting("showClass") ~= false and classTexture ~= nil
        and classTexture ~= ""
    self.classIcon:SetHidden(not classVisible)
    if classVisible then
        self.classIcon:SetTexture(classTexture)
        self.classIcon:SetColor(1, 1, 1, Clamp(GetSetting("textOpacity"), 10, 100) / 100)
    end
    local icon, iconColor
    if GetSetting("showVeterancyIcon") == true then
        icon, iconColor = GetAllianceIcon(data)
    end
    self.rankIcon:SetHidden(not icon)
    if icon then
        self.rankIcon:SetTexture(icon)
        self.rankIcon:SetColor(iconColor.r, iconColor.g, iconColor.b, 1)
    end

    local frameWidth = Clamp(GetSetting("width"), 180, 700)
    local levelVisible = levelWidth > 0
    local fixedWidth = (classVisible and CLASS_ICON_SIZE or 0)
        + (levelWidth > 0 and levelWidth or 0)
        + (icon and IDENTITY_ICON_SIZE or 0)
    local gapWidth = (classVisible and CLASS_NAME_GAP or 0)
        + (levelVisible and NAME_LEVEL_GAP or 0)
        + (icon and (levelVisible and LEVEL_RANK_GAP or NAME_LEVEL_GAP) or 0)
    local availableNameWidth = math.max(frameWidth - fixedWidth - gapWidth, 1)
    local nameWidth = math.min(GetIntrinsicNameWidth(self.nameLabel, data.name), availableNameWidth)
    local totalWidth = fixedWidth + nameWidth + gapWidth
    self.identityContent:ClearAnchors()
    self.identityContent:SetAnchor(CENTER, self.identity, CENTER, 0, 0)
    self.identityContent:SetDimensions(totalWidth, self.identity:GetHeight())
    self.classIcon:ClearAnchors()
    self.nameLabel:ClearAnchors()
    self.levelBadge.control:ClearAnchors()
    self.rankIcon:ClearAnchors()
    local x = 0
    if classVisible then
        self.classIcon:SetAnchor(LEFT, self.identityContent, LEFT, x, IDENTITY_ICON_VERTICAL_OFFSET)
        x = x + CLASS_ICON_SIZE + CLASS_NAME_GAP
    end
    self.nameLabel:SetAnchor(LEFT, self.identityContent, LEFT, x, 0)
    self.nameLabel:SetDimensions(nameWidth, self.identity:GetHeight())
    x = x + nameWidth
    if levelVisible then
        x = x + NAME_LEVEL_GAP
        self.levelBadge.control:SetAnchor(LEFT, self.identityContent, LEFT, x, LEVEL_BADGE_VERTICAL_OFFSET)
        x = x + levelWidth
    end
    if icon then
        x = x + (levelVisible and LEVEL_RANK_GAP or NAME_LEVEL_GAP)
        self.rankIcon:SetAnchor(LEFT, self.identityContent, LEFT, x, IDENTITY_ICON_VERTICAL_OFFSET)
    end
    self.levelTier = tierIndex
end

function TargetFrame:UpdateText(data)
    local format = GetSetting("healthTextFormat") or "numberAndPercent"
    local position = GetSetting("healthTextPosition") or "sides"
    local shieldMode = GetSetting("shieldTextMode") or "healthAndShield"
    local numberText = FormatNumber(data.current)
    if data.shield > 0 and shieldMode == "healthAndShield" then
        numberText = string.format("%s + %s", numberText, FormatNumber(data.shield))
    elseif shieldMode == "shieldOnly" then
        numberText = data.shield > 0 and FormatNumber(data.shield) or ""
    end
    local percentText = FormatPercent(data.current, data.maximum)
    self.health.leftLabel:SetHidden(true)
    self.health.centerLabel:SetHidden(true)
    self.health.rightLabel:SetHidden(true)
    if format == "none" then
        return
    end

    if format == "numberAndPercent" and position == "sides" then
        self.health.leftLabel:SetText(numberText)
        self.health.rightLabel:SetText(percentText)
        self.health.leftLabel:SetHidden(numberText == "")
        self.health.rightLabel:SetHidden(false)
        return
    end

    local text
    if format == "number" then
        text = numberText
        if position == "sides" then
            position = "left"
        end
    elseif format == "percent" then
        text = percentText
        if position == "sides" then
            position = "right"
        end
    else
        text = numberText ~= "" and string.format("%s  %s", numberText, percentText) or percentText
    end

    local label
    if position == "left" then
        label = self.health.leftLabel
    elseif position == "right" then
        label = self.health.rightLabel
    else
        label = self.health.centerLabel
    end
    label:SetText(text)
    label:SetHidden(text == "")
end

function TargetFrame:UpdateExecute(data)
    local ratio = data.maximum > 0 and data.current / data.maximum or 1
    local show = GetSetting("showExecuteIcon") ~= false and not data.dead and data.current > 0
        and data.attackable and ratio <= (Clamp(GetSetting("executeThreshold"), 18, 33) / 100)
    self.executeIcon:SetTexture(GetExecuteIconTexture())
    self.executeIcon:SetHidden(not show)
    if not show then
        return
    end
    local position = GetSetting("executePosition") or "center"
    self.executeIcon:ClearAnchors()
    if position == "left" then
        self.executeIcon:SetAnchor(LEFT, self.health, LEFT, Clamp(GetSetting("textInset"), 0, 28), 0)
        if not self.health.leftLabel:IsHidden() then
            self.health.leftLabel:ClearAnchors()
            self.health.leftLabel:SetAnchor(LEFT, self.health, LEFT, Clamp(GetSetting("textInset"), 0, 28) + EXECUTE_ICON_SIZE + 3,
                Clamp(GetSetting("textVerticalOffset"), -8, 8))
        end
    elseif position == "right" then
        self.executeIcon:SetAnchor(RIGHT, self.health, RIGHT, -Clamp(GetSetting("textInset"), 0, 28), 0)
        if not self.health.rightLabel:IsHidden() then
            self.health.rightLabel:ClearAnchors()
            self.health.rightLabel:SetAnchor(RIGHT, self.health, RIGHT, -(Clamp(GetSetting("textInset"), 0, 28) + EXECUTE_ICON_SIZE + 3),
                Clamp(GetSetting("textVerticalOffset"), -8, 8))
        end
    else
        if not self.health.centerLabel:IsHidden() then
            local centerText = self.health.centerLabel.GetText and self.health.centerLabel:GetText() or ""
            local textWidth = self.health.centerLabel.GetStringWidth
                and self.health.centerLabel:GetStringWidth(centerText)
                or self.health.centerLabel:GetTextWidth()
            textWidth = math.max(tonumber(textWidth) or 0, 1)
            local gap = 4
            local groupWidth = EXECUTE_ICON_SIZE + gap + textWidth
            local iconOffset = (-groupWidth * 0.5) + (EXECUTE_ICON_SIZE * 0.5)
            local textOffset = (-groupWidth * 0.5) + EXECUTE_ICON_SIZE + gap + (textWidth * 0.5)
            self.executeIcon:SetAnchor(CENTER, self.health, CENTER, iconOffset, 0)
            self.health.centerLabel:ClearAnchors()
            self.health.centerLabel:SetAnchor(CENTER, self.health, CENTER, textOffset,
                Clamp(GetSetting("textVerticalOffset"), -8, 8))
        else
            self.executeIcon:SetAnchor(CENTER, self.health, CENTER, 0, 0)
        end
    end
end

function TargetFrame:ResetTargetState()
    self.previousHealth = nil
    self.previousMaximum = nil
    self.previousShield = nil
    self.previousDead = nil
    self.levelTier = nil
    self.sameIdentity = false
    self.targetIdentity = nil
    self.currentFingerprint = nil
    if self.health then
        BarVisuals:HideFeedback(self.health)
        BarVisuals:StopLossTrail(self.health, 0, 0)
        BarVisuals:SetShield(self.health, 0, 0, false)
    end
    if self.executeIcon then
        self.executeIcon:SetHidden(true)
    end
    if self.levelBadge then
        LevelVisuals:Stop(self.levelBadge)
    end
end

function TargetFrame:UpdateFeedback(data, instant)
    local previous = self.previousHealth
    local previousMaximum = self.previousMaximum
    local previousShield = self.previousShield or 0
    local previousDead = self.previousDead
    local now = GetFrameTimeMilliseconds()
    local intensity = Clamp(GetSetting("feedbackIntensity"), 0, 140) / 100
    local enabled = not instant and GetSetting("feedbackEnabled") == true and intensity > 0
    local meaningful = data.maximum > 0 and previous ~= nil
        and math.abs(data.current - previous) / data.maximum >= MIN_FEEDBACK_DELTA_RATIO
        and now - (self.lastFeedbackMS or 0) >= MIN_FEEDBACK_INTERVAL_MS
    if enabled and meaningful and data.current > previous and GetSetting("gainPulseEnabled") ~= false then
        BarVisuals:PlayFeedback(self.health, "gain", { r = 0.56, g = 1.00, b = 0.60 }, intensity)
        self.lastFeedbackMS = now
    elseif enabled and meaningful and data.current < previous and GetSetting("spendPulseEnabled") ~= false then
        BarVisuals:PlayFeedback(self.health, "spend", { r = 1.00, g = 0.22, b = 0.18 }, intensity)
        self.lastFeedbackMS = now
    end
    if enabled and previousMaximum and previous < previousMaximum and data.current >= data.maximum
        and GetSetting("fullResourcePulseEnabled") ~= false then
        BarVisuals:PlayFeedback(self.health, "full", { r = 1.00, g = 0.92, b = 0.42 }, intensity)
    end
    if enabled and data.shield > previousShield and GetSetting("shieldPulseEnabled") ~= false then
        BarVisuals:PlayFeedback(self.health, "shield", GetSetting("shieldGlowColor"), intensity)
    end
    if enabled and previousDead ~= nil and previousDead ~= data.dead then
        BarVisuals:PlayFeedback(self.health, data.dead and "death" or "revive",
            data.dead and { r = 0.95, g = 0.10, b = 0.10 } or { r = 0.42, g = 1.00, b = 0.58 }, intensity)
    end
end

function TargetFrame:ApplyTargetData(data, instant)
    self.currentData = data
    if not data then
        self:ResetTargetState()
        self.lastLiveData = nil
        self.currentFingerprint = nil
        self.missingTargetSinceMS = nil
        self:GetRoot():SetHidden(true)
        self:GetMover():SetHidden(true)
        self:UpdateScheduler()
        return false
    end

    self.missingTargetSinceMS = nil
    local identity = string.format("%s:%s", tostring(data.name), tostring(data.isPlayer))
    if identity ~= self.targetIdentity then
        self:ResetTargetState()
        self.targetIdentity = identity
        -- Target swaps must never inherit or start a health transition. Some
        -- lifecycle paths arrive through power updates before the dedicated
        -- reticle event, so enforce the snap here at the identity boundary.
        instant = true
    else
        self.sameIdentity = true
    end
    local width, barHeight = self:ApplyLayout(data)
    local color = GetTargetColor(data)
    self:ApplyStyle(width, barHeight, color)
    self:UpdateIdentity(data)
    self:UpdateFeedback(data, instant)
    BarVisuals:SetValue(self.health, data.current, data.maximum, not instant,
        not instant and GetSetting("lossTrailEnabled") == true)
    BarVisuals:SetShield(self.health, data.shield, data.maximum, not instant)
    self:UpdateText(data)
    self:UpdateExecute(data)
    self.previousHealth = data.current
    self.previousMaximum = data.maximum
    self.previousShield = data.shield
    self.previousDead = data.dead
    self.currentFingerprint = GetTargetFingerprint(data)
    self:UpdateVisibility()
    return true
end

function TargetFrame:RefreshTarget(instant, retainOnMissing)
    local data
    if self.settingsPreviewActive or self.debugPreviewMode then
        data = GetPreviewData(self.debugPreviewMode ~= "npc")
    elseif IsUnlocked() then
        local liveData = ReadTargetData()
        if liveData then
            self.lastLiveData = liveData
        end
        data = liveData or self.lastLiveData or GetPreviewData(true)
    else
        data = ReadTargetData()
        if data then
            self.lastLiveData = data
        end
    end
    if not data and retainOnMissing and self.currentData then
        self.missingTargetSinceMS = self.missingTargetSinceMS or GetFrameTimeMilliseconds()
        return false
    end
    return self:ApplyTargetData(data, instant)
end

function TargetFrame:ReconcileTarget()
    if not IsEnabled() or self.initialized ~= true or self.settingsPreviewActive or self.debugPreviewMode
        or IsUnlocked() then
        self.missingTargetSinceMS = nil
        return
    end

    local data = ReadTargetData()
    if data then
        self.missingTargetSinceMS = nil
        local fingerprint = GetTargetFingerprint(data)
        if not self.currentData or fingerprint ~= self.currentFingerprint then
            local identity = string.format("%s:%s", tostring(data.name), tostring(data.isPlayer))
            self:ApplyTargetData(data, not self.currentData or identity ~= self.targetIdentity)
        elseif self.root and self.root:IsHidden() and IsHudSceneShowing() then
            self:UpdateVisibility()
        end
        return
    end

    if not self.currentData then
        self.missingTargetSinceMS = nil
        return
    end
    local now = GetFrameTimeMilliseconds()
    self.missingTargetSinceMS = self.missingTargetSinceMS or now
    if now - self.missingTargetSinceMS >= TARGET_MISSING_GRACE_MS then
        self:ApplyTargetData(nil, true)
    end
end

function TargetFrame:HandleRuntimeFailure(context, errorMessage)
    local now = GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or 0
    self.runtimeRecoveryActive = true
    self.runtimeRecoveryAfterMS = now + TARGET_RECOVERY_DELAY_MS
    self.currentData = nil
    self.lastLiveData = nil
    self.currentFingerprint = nil
    self.missingTargetSinceMS = nil
    pcall(function() self:ResetTargetState() end)
    if self.root then
        self.root:SetHidden(true)
        self.root:SetHandler("OnUpdate", nil)
    end
    if self.mover then self.mover:SetHidden(true) end
    self:SetStockFrameHidden(false)
    if d and (not self.lastRuntimeErrorLogMS or now - self.lastRuntimeErrorLogMS >= TARGET_ERROR_LOG_INTERVAL_MS) then
        self.lastRuntimeErrorLogMS = now
        d(string.format("Nirnsteel UI Target Frame %s: %s", tostring(context or "update"), tostring(errorMessage)))
    end
end

function TargetFrame:RunGuarded(context, callback)
    local ok, errorMessage = pcall(callback)
    if not ok then
        self:HandleRuntimeFailure(context, errorMessage)
    end
    return ok
end

function TargetFrame:SetReconciliationEnabled(enabled)
    if EVENT_MANAGER.UnregisterForUpdate then
        EVENT_MANAGER:UnregisterForUpdate(RECONCILE_NAMESPACE)
    end
    self.reconciliationEnabled = nil
    self.runtimeRecoveryActive = nil
    self.runtimeRecoveryAfterMS = nil
    if not enabled or not EVENT_MANAGER.RegisterForUpdate then
        return
    end
    self.reconciliationEnabled = true
    EVENT_MANAGER:RegisterForUpdate(RECONCILE_NAMESPACE, TARGET_RECONCILE_INTERVAL_MS, function()
        local now = GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or 0
        if self.runtimeRecoveryActive and now < (self.runtimeRecoveryAfterMS or 0) then
            return
        end
        local recovering = self.runtimeRecoveryActive == true
        self:RunGuarded("reconciliation", function()
            self:ReconcileTarget()
            if recovering and self.currentData then
                self.runtimeRecoveryActive = nil
                self.runtimeRecoveryAfterMS = nil
                self:SetStockFrameHidden(true)
                self:UpdateVisibility()
            end
        end)
    end)
end

function TargetFrame:SetStockFrameHidden(hidden)
    hidden = hidden == true and self.runtimeRecoveryActive ~= true
    if UNIT_FRAMES and UNIT_FRAMES.SetFrameHiddenForReason then
        if hidden and UNIT_FRAMES.GetFrame and not UNIT_FRAMES:GetFrame(UNIT_TAG) then
            self.stockFrameHidden = false
            self.stockHideRetryCount = (self.stockHideRetryCount or 0) + 1
            if self.stockHideRetryCount <= 20 and not self.stockHideRetryPending then
                self.stockHideRetryPending = true
                local retryToken = (self.stockHideRetryToken or 0) + 1
                self.stockHideRetryToken = retryToken
                zo_callLater(function()
                    if self.stockHideRetryToken ~= retryToken then
                        return
                    end
                    self.stockHideRetryPending = false
                    if IsEnabled() and self.initialized == true then
                        self:SetStockFrameHidden(true)
                    end
                end, 250)
            end
            return
        end
        local ok = pcall(function()
            UNIT_FRAMES:SetFrameHiddenForReason(UNIT_TAG, STOCK_HIDE_REASON, hidden)
        end)
        self.stockFrameHidden = ok and hidden or false
        if ok and hidden then
            self.stockHideRetryCount = 0
            self.stockHideRetryPending = false
        elseif not hidden then
            self.stockHideRetryToken = (self.stockHideRetryToken or 0) + 1
            self.stockHideRetryCount = 0
            self.stockHideRetryPending = false
        end
    elseif not hidden then
        self.stockFrameHidden = false
    end
end

function TargetFrame:UpdateScheduler()
    local root = self:GetRoot()
    local active = not root:IsHidden() and self.levelBadge and (self.levelBadge.shimmerIntensity or 0) > 0
        and GetSetting("showLevelStyle") ~= false
    if not active then
        root:SetHandler("OnUpdate", nil)
        return
    end
    self.lastLevelShimmerMS = self.lastLevelShimmerMS
        or (GetFrameTimeMilliseconds() - LevelVisuals.SHIMMER_CADENCE_MS + 700)
    root:SetHandler("OnUpdate", function()
        local now = GetFrameTimeMilliseconds()
        if now - (self.lastLevelShimmerMS or 0) >= LevelVisuals.SHIMMER_CADENCE_MS then
            self.lastLevelShimmerMS = now
            LevelVisuals:Play(self.levelBadge)
        end
    end)
end

function TargetFrame:UpdateVisibility()
    local preview = self.settingsPreviewActive or self.debugPreviewMode
    local hasData = self.currentData ~= nil
    local show = IsEnabled() and hasData and (preview or IsUnlocked() or IsHudSceneShowing())
    self:GetRoot():SetHidden(not show)
    self:GetMover():SetHidden(not show or not IsUnlocked())
    self:SetStockFrameHidden(IsEnabled() and self.initialized == true and self.runtimeRecoveryActive ~= true)
    self:UpdateScheduler()
end

function TargetFrame:SetUnlocked(unlocked)
    unlocked = unlocked == true
    if self.mover then
        self.mover:StopMovingOrResizing()
        self.mover:SetMovable(false)
        if not unlocked then
            self.mover:SetHidden(true)
        end
    end
    if not unlocked then
        self.lastLiveData = nil
    end
    self:ResetTargetState()
    self:RefreshTarget(true)
end

function TargetFrame:SetSettingsPreviewActive(active)
    self.settingsPreviewActive = active == true or nil
    if active then
        self.debugPreviewMode = nil
    end
    self:ResetTargetState()
    self:RefreshTarget(true)
end

function TargetFrame:SetDebugPreviewMode(mode)
    self.settingsPreviewActive = nil
    self.debugPreviewMode = mode == "player" and "player" or mode == "npc" and "npc" or nil
    self:ResetTargetState()
    self:RefreshTarget(true)
end

function TargetFrame:ReplayPreviewEffects()
    if not self.currentData then
        self:SetDebugPreviewMode("player")
    end
    BarVisuals:PlayFeedback(self.health, "spend", { r = 1.00, g = 0.20, b = 0.14 }, 0.85)
    zo_callLater(function()
        if self.health then
            BarVisuals:PlayFeedback(self.health, "shield", GetSetting("shieldGlowColor"), 0.85)
            LevelVisuals:Play(self.levelBadge)
        end
    end, 450)
end

function TargetFrame:ResetPosition()
    if Nirnsteel_UI.Settings and Nirnsteel_UI.Settings.ResetTargetFramePosition then
        Nirnsteel_UI.Settings:ResetTargetFramePosition()
    end
    self:ApplyPosition()
end

local function RegisterOptionalEvent(namespace, eventCode, handler)
    if eventCode then
        EVENT_MANAGER:RegisterForEvent(namespace, eventCode, function(...)
            local arguments = { ... }
            local argumentCount = select("#", ...)
            TargetFrame:RunGuarded(namespace, function()
                handler(unpack(arguments, 1, argumentCount))
            end)
        end)
    end
end

function TargetFrame:RefreshChangedTarget(resetState)
    self.targetRefreshToken = (self.targetRefreshToken or 0) + 1
    local refreshToken = self.targetRefreshToken
    if resetState ~= false then
        self:ResetTargetState()
    end
    self:RefreshTarget(true, true)
    for index = 1, #TARGET_REFRESH_DELAYS_MS do
        local delayMS = TARGET_REFRESH_DELAYS_MS[index]
        zo_callLater(function()
            if self.targetRefreshToken == refreshToken and IsEnabled() then
                self:RunGuarded("delayed target refresh", function() self:RefreshTarget(true, true) end)
            end
        end, delayMS)
    end
end

function TargetFrame:QueueTargetReadinessRefresh()
    if self.readinessRefreshPending then
        return
    end
    self.readinessRefreshPending = true
    zo_callLater(function()
        self.readinessRefreshPending = nil
        if IsEnabled() then
            self:RunGuarded("player target readiness", function() self:RefreshTarget(true, true) end)
        end
    end, 25)
end

local function IsObservedTargetTag(unitTag)
    return unitTag == UNIT_TAG or unitTag == PLAYER_UNIT_TAG
end

function TargetFrame:RegisterEvents()
    if self.eventsRegistered then
        return
    end
    RegisterOptionalEvent(EVENT_NAMESPACE .. "_Reticle", EVENT_RETICLE_TARGET_CHANGED, function()
        self:RefreshChangedTarget()
    end)
    RegisterOptionalEvent(EVENT_NAMESPACE .. "_ReticlePlayer", EVENT_RETICLE_TARGET_PLAYER_CHANGED, function()
        self:QueueTargetReadinessRefresh()
    end)
    RegisterOptionalEvent(EVENT_NAMESPACE .. "_ReticleCompanion", EVENT_RETICLE_TARGET_COMPANION_CHANGED, function()
        self:QueueTargetReadinessRefresh()
    end)
    RegisterOptionalEvent(EVENT_NAMESPACE .. "_UnitCreated", EVENT_UNIT_CREATED, function(_, unitTag)
        if IsObservedTargetTag(unitTag) then
            self:QueueTargetReadinessRefresh()
        end
    end)
    RegisterOptionalEvent(EVENT_NAMESPACE .. "_UnitDestroyed", EVENT_UNIT_DESTROYED, function(_, unitTag)
        if IsObservedTargetTag(unitTag) then
            self:QueueTargetReadinessRefresh()
        end
    end)
    RegisterOptionalEvent(EVENT_NAMESPACE .. "_CharacterName", EVENT_UNIT_CHARACTER_NAME_CHANGED, function(_, unitTag)
        if IsObservedTargetTag(unitTag) then
            self:QueueTargetReadinessRefresh()
        end
    end)
    RegisterOptionalEvent(EVENT_NAMESPACE .. "_Power", EVENT_POWER_UPDATE, function(_, unitTag, _, powerType)
        if IsObservedTargetTag(unitTag) and powerType == HEALTH_POWER_TYPE then self:RefreshTarget(false, true) end
    end)
    RegisterOptionalEvent(EVENT_NAMESPACE .. "_Disposition", EVENT_DISPOSITION_UPDATE, function(_, unitTag)
        if IsObservedTargetTag(unitTag) then self:RefreshTarget(true, true) end
    end)
    RegisterOptionalEvent(EVENT_NAMESPACE .. "_Level", EVENT_LEVEL_UPDATE, function(_, unitTag)
        if IsObservedTargetTag(unitTag) then self:RefreshTarget(true, true) end
    end)
    RegisterOptionalEvent(EVENT_NAMESPACE .. "_Champion", EVENT_CHAMPION_POINT_UPDATE, function(_, unitTag)
        if IsObservedTargetTag(unitTag) then self:RefreshTarget(true, true) end
    end)
    RegisterOptionalEvent(EVENT_NAMESPACE .. "_Death", EVENT_UNIT_DEATH_STATE_CHANGED, function(_, unitTag)
        if IsObservedTargetTag(unitTag) then self:RefreshTarget(false, true) end
    end)
    RegisterOptionalEvent(EVENT_NAMESPACE .. "_ShieldAdded", EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, function(_, unitTag, visualType)
        if IsObservedTargetTag(unitTag) and visualType == ATTRIBUTE_VISUAL_POWER_SHIELDING then self:RefreshTarget(false, true) end
    end)
    RegisterOptionalEvent(EVENT_NAMESPACE .. "_ShieldUpdated", EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, function(_, unitTag, visualType)
        if IsObservedTargetTag(unitTag) and visualType == ATTRIBUTE_VISUAL_POWER_SHIELDING then self:RefreshTarget(false, true) end
    end)
    RegisterOptionalEvent(EVENT_NAMESPACE .. "_ShieldRemoved", EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, function(_, unitTag, visualType)
        if IsObservedTargetTag(unitTag) and visualType == ATTRIBUTE_VISUAL_POWER_SHIELDING then self:RefreshTarget(false, true) end
    end)
    RegisterOptionalEvent(EVENT_NAMESPACE .. "_Marker", EVENT_TARGET_MARKER_UPDATE, function() self:RefreshTarget(true, true) end)
    RegisterOptionalEvent(EVENT_NAMESPACE .. "_Rank", EVENT_RANK_POINT_UPDATE, function(_, unitTag)
        if IsObservedTargetTag(unitTag) then self:RefreshTarget(true, true) end
    end)
    RegisterOptionalEvent(EVENT_NAMESPACE .. "_Activated", EVENT_PLAYER_ACTIVATED, function() self:RefreshChangedTarget() end)
    RegisterOptionalEvent(EVENT_NAMESPACE .. "_Interface", EVENT_INTERFACE_SETTING_CHANGED, function()
        self:QueueTargetReadinessRefresh()
    end)
    RegisterOptionalEvent(EVENT_NAMESPACE .. "_CameraUI", EVENT_GAME_CAMERA_UI_MODE_CHANGED, function()
        self:QueueTargetReadinessRefresh()
    end)
    RegisterOptionalEvent(EVENT_NAMESPACE .. "_ReticleHidden", EVENT_RETICLE_HIDDEN_UPDATE, function()
        self:QueueTargetReadinessRefresh()
    end)
    RegisterOptionalEvent(EVENT_NAMESPACE .. "_Screen", EVENT_SCREEN_RESIZED, function() self:ApplyPosition() end)
    RegisterOptionalEvent(EVENT_NAMESPACE .. "_Gamepad", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function()
        self:QueueTargetReadinessRefresh()
    end)
    if CALLBACK_MANAGER then
        CALLBACK_MANAGER:RegisterCallback("TargetFrameCreated", function()
            self:SetStockFrameHidden(IsEnabled() and self.initialized == true)
        end)
        CALLBACK_MANAGER:RegisterCallback("UnitFramesCreated", function()
            self:SetStockFrameHidden(IsEnabled() and self.initialized == true)
        end)
    end
    if HUD_SCENE then
        HUD_SCENE:RegisterCallback("StateChange", function() self:UpdateVisibility() end)
    end
    if HUD_UI_SCENE then
        HUD_UI_SCENE:RegisterCallback("StateChange", function() self:UpdateVisibility() end)
    end
    self.eventsRegistered = true
end

function TargetFrame:RefreshSettings()
    self:RegisterEvents()
    if not IsEnabled() then
        self.targetRefreshToken = (self.targetRefreshToken or 0) + 1
        self:SetReconciliationEnabled(false)
        if self.root then
            self.root:SetHidden(true)
            self.root:SetHandler("OnUpdate", nil)
        end
        if self.mover then self.mover:SetHidden(true) end
        self:SetStockFrameHidden(false)
        return
    end
    local ok, errorMessage = pcall(function()
        self:GetRoot()
        self:RefreshTarget(true)
    end)
    if ok then
        self.initialized = true
        self:SetReconciliationEnabled(true)
        self:SetStockFrameHidden(true)
        self:UpdateVisibility()
    else
        self.initialized = false
        self:SetReconciliationEnabled(false)
        self:SetStockFrameHidden(false)
        if self.root then self.root:SetHidden(true) end
        d(string.format("Nirnsteel UI Target Frame: %s", tostring(errorMessage)))
    end
end

local DEBUG_COMMANDS =
{
    ["/nstarget"] = function(argument)
        argument = string.lower(tostring(argument or ""))
        if argument == "player" or argument == "npc" then
            TargetFrame:SetDebugPreviewMode(argument)
        else
            TargetFrame:SetDebugPreviewMode(nil)
        end
    end,
    ["/nstargetfx"] = function() TargetFrame:ReplayPreviewEffects() end,
}

local function RegisterDebugCommands()
    local enabled = Nirnsteel_UI.Settings and Nirnsteel_UI.Settings:IsDebugModeEnabled()
    for command, handler in pairs(DEBUG_COMMANDS) do
        SLASH_COMMANDS[command] = enabled and handler or nil
    end
end

function TargetFrame:RefreshDebugCommands()
    RegisterDebugCommands()
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_Loaded", EVENT_ADD_ON_LOADED)
    TargetFrame:RefreshSettings()
    RegisterDebugCommands()
    zo_callLater(function() TargetFrame:RefreshSettings() end, 1000)
end

EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_Loaded", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
