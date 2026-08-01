NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local Fishing = {}

local EVENT_NAMESPACE = "NQOL_Fishing"
local REEL_UPDATE_NAMESPACE = EVENT_NAMESPACE .. "_Reel"
local TRACKER_UPDATE_NAMESPACE = EVENT_NAMESPACE .. "_Tracker"
local TRACKER_LAYOUT_UPDATE_NAMESPACE = EVENT_NAMESPACE .. "_TrackerLayout"
local ICON_TEXTURE = "/esoui/art/icons/crafting_fishing_merringar.dds"
local ICON_SIZE = 420
local NOTIFY_DELAY_MS = 250
local NOTIFY_TIMEOUT_MS = 3000
local SOUND_REPEAT_INTERVAL_MS = 650
local TRACKER_DRAW_LEVEL = 215
local TRACKER_FALLBACK_WIDTH = 120
local TRACKER_PADDING = 8
local TRACKER_ROW_GAP = 4
local TRACKER_ICON_GAP = 4
local TRACKER_HORIZONTAL_ITEM_GAP = 12
local TRACKER_TEXT_WIDTH_PADDING = 6
local TRACKER_STATUS_ICON_SCALE = 1.15
local TRACKER_DONE_ICON = "EsoUI/Art/Miscellaneous/check_icon_32.dds"
local TRACKER_NOT_DONE_ICON = "EsoUI/Art/Buttons/decline_up.dds"
local TRACKER_FONT_SIZE_MIN = 12
local TRACKER_FONT_SIZE_MAX = 30
local TRACKER_BACKGROUND_OPACITY_MIN = 0
local TRACKER_BACKGROUND_OPACITY_MAX = 100
local TRACKER_MODE_OFF = "off"
local TRACKER_MODE_ON = "on"
local TRACKER_MODE_AUTO = "auto"
local TRACKER_ORIENTATION_VERTICAL = "vertical"
local TRACKER_ORIENTATION_HORIZONTAL = "horizontal"

local TRACKER_MODE_OPTIONS = {
    { key = TRACKER_MODE_ON, name = NQOL.L("features.fishing.mode_on") },
    { key = TRACKER_MODE_OFF, name = NQOL.L("features.fishing.mode_off") },
    { key = TRACKER_MODE_AUTO, name = NQOL.L("features.fishing.mode_auto") },
}
NQOL.Lexicon.RegisterRefreshCallback(function()
    TRACKER_MODE_OPTIONS[1].name = NQOL.L("features.fishing.mode_on")
    TRACKER_MODE_OPTIONS[2].name = NQOL.L("features.fishing.mode_off")
    TRACKER_MODE_OPTIONS[3].name = NQOL.L("features.fishing.mode_auto")
end)

local VALID_TRACKER_MODES = {
    [TRACKER_MODE_ON] = true,
    [TRACKER_MODE_OFF] = true,
    [TRACKER_MODE_AUTO] = true,
}

local TRACKER_ORIENTATION_OPTIONS = {
    { key = TRACKER_ORIENTATION_VERTICAL, name = NQOL.L("features.fishing.orientation_vertical") },
    { key = TRACKER_ORIENTATION_HORIZONTAL, name = NQOL.L("features.fishing.orientation_horizontal") },
}
NQOL.Lexicon.RegisterRefreshCallback(function()
    TRACKER_ORIENTATION_OPTIONS[1].name = NQOL.L("features.fishing.orientation_vertical")
    TRACKER_ORIENTATION_OPTIONS[2].name = NQOL.L("features.fishing.orientation_horizontal")
end)

local VALID_TRACKER_ORIENTATIONS = {
    [TRACKER_ORIENTATION_VERTICAL] = true,
    [TRACKER_ORIENTATION_HORIZONTAL] = true,
}

local BAIT_BY_LURE_INDEX = {
    [2] = "guts",
    [3] = "crawlers",
    [4] = "insectParts",
    [5] = "worms",
    [6] = "shad",
    [7] = "chub",
    [8] = "minnow",
    [9] = "fishRoe",
}

local BAIT_WATER_TYPES = {
    crawlers = "foul",
    fishRoe = "foul",
    insectParts = "river",
    shad = "river",
    guts = "lake",
    minnow = "lake",
    worms = "saltwater",
    chub = "saltwater",
}

local BAIT_PRIORITY_BY_WATER_TYPE = {
    foul = { "fishRoe", "crawlers" },
    river = { "shad", "insectParts" },
    lake = { "minnow", "guts" },
    saltwater = { "chub", "worms" },
}

local WATER_TYPE_LABELS = {
    foul = "Foul",
    river = "River",
    lake = "Lake",
    saltwater = "Saltwater",
}

local WATER_TYPE_ORDER = { "foul", "river", "lake", "saltwater" }

local FISHING_ACHIEVEMENT_BY_ZONE_ID = {
    [3] = { 471 },
    [19] = { 472 },
    [20] = { 473 },
    [41] = { 477 },
    [57] = { 478 },
    [58] = { 486 },
    [92] = { 475 },
    [101] = { 480 },
    [103] = { 481 },
    [104] = { 474 },
    [108] = { 485 },
    [117] = { 479 },
    [181] = { 489 },
    [280] = { 493 },
    [281] = { 493 },
    [347] = { 490 },
    [381] = { 483 },
    [382] = { 487 },
    [383] = { 484 },
    [534] = { 491 },
    [535] = { 491 },
    [537] = { 492 },
    [584] = { 1186 },
    [684] = { 1340, 1339 },
    [726] = { 2295 },
    [816] = { 1351 },
    [823] = { 1431 },
    [849] = { 1882 },
    [888] = { 916 },
    [980] = { 2027 },
    [981] = { 2027 },
    [1011] = { 2191 },
    [1027] = { 2240 },
    [1072] = { 2295 },
    [1086] = { 2412 },
    [1133] = { 2566 },
    [1160] = { 2655 },
    [1207] = { 2861 },
    [1261] = { 2981 },
    [1286] = { 3144 },
    [1318] = { 3269 },
    [1383] = { 3500 },
    [1413] = { 3636 },
    [1414] = { 3636 },
    [1443] = { 3948 },
    [1502] = { 4460, 4404 },
}

local BAIT_KEYWORDS_BY_ICON = {
    crawlers = { "crawler" },
    fishRoe = { "roe" },
    insectParts = { "insect" },
    shad = { "shad" },
    guts = { "gut" },
    minnow = { "minnow" },
    worms = { "worm" },
    chub = { "chub" },
}

-- Exact game-returned fishing hole names observed in console addon reference data.
-- ESOUI does not expose official string IDs for these names, and GetFishingWaterType()
-- is not in the official API documentation, so first-time matching has to use the
-- localized interactable name the game returns.
local LOCALIZED_FISHING_HOLE_NAMES = {
    foul = {
        "Foul Fishing Hole",
        "Foul Abyssal Fishing Hole",
        "Oily Fishing Hole",
        "Fischgrund (Brackwasser)^m",
        "abgründiger Fischgrund (Brackwasser)^m",
        "Fischgrund (Ölwasser)^m",
        "lugar de pesca de agua sucia^m",
        "lugar de pesca abisal de agua sucia^m",
        "lugar de pesca aceitoso^m",
        "trou de pêche sale^m",
        "trou de pêche sale abyssal",
        "trou de pêche huileux^m",
        "汚水の釣り穴",
        "深淵の汚水の釣り穴",
        "油の釣り穴",
        "Место для рыбалки в сточной воде",
        "Место для рыбалки в сточной воде (бездонное море)",
        "Место для рыбалки (маслянистая вода)",
        "脏水钓鱼点",
        "污秽深渊钓鱼点",
        "油污钓鱼点",
    },
    river = {
        "River Fishing Hole",
        "Fischgrund (Flusswasser)^m",
        "lugar de pesca de río^m",
        "trou de pêche de rivière^m",
        "川の釣り穴",
        "Место для рыбалки на реке",
        "河流钓鱼点",
    },
    lake = {
        "Lake Fishing Hole",
        "Fischgrund (Seewasser)^m",
        "lugar de pesca de lago^m",
        "trou de pêche lacustre^m",
        "湖の釣り穴",
        "Место для рыбалки на озере",
        "湖泊钓鱼点",
    },
    saltwater = {
        "Saltwater Fishing Hole",
        "Mystic Fishing Hole",
        "Fischgrund (Salzwasser)^m",
        "Fischgrund (Mythenwasser)^m",
        "lugar de pesca de agua salada^m",
        "lugar de pesca místico^m",
        "trou de pêche d'eau de mer^m",
        "trou de pêche mystique^m",
        "塩水の釣り穴",
        "秘術の釣り穴",
        "Место для рыбалки на море",
        "Место для рыбалки (мистическая вода)",
        "咸水钓鱼点",
        "神秘商人钓鱼点",
    },
}

local defaults = {
    fishing = {
        autoSelectBait = false,
        reportBaitSwitch = false,
        reelNotification = false,
        reelNotificationSound = NQOL.Util.GetAlertSoundDefault(),
        tracker = {
            mode = TRACKER_MODE_OFF,
            orientation = TRACKER_ORIENTATION_VERTICAL,
            showInSettings = true,
            horizontalPosition = 78,
            verticalPosition = 48,
            font = NQOL.Util.GetDefaultFont(),
            fontSize = 24,
            backgroundOpacity = 90,
        },
    },
}

local savedVariables
local initialized = false
local fishing = false
local currentBaitCount = 0
local fishingInteractableName
local lastAction
local reelWindow
local reelTexture
local reelTimeline
local trackerWindow
local trackerTitle
local trackerMeasureLabel
local trackerRows = {}
local trackerRegistered = false
local trackerSettingsPanelVisible = false
local trackerReticleOverFishingHole = false
local trackerFontStringCache = {}
local trackerLayoutRetryQueued = false

local Clamp = NQOL.Util.Clamp
local Round = NQOL.Util.Round

local function GetSettings()
    local settings = NQOL.Settings.GetSection(savedVariables, defaults, "fishing")
    local trackerDefaults = defaults.fishing.tracker

    NQOL.Settings.Boolean(settings, defaults.fishing, "autoSelectBait")
    NQOL.Settings.Boolean(settings, defaults.fishing, "reportBaitSwitch")
    NQOL.Settings.Boolean(settings, defaults.fishing, "reelNotification")
    NQOL.Settings.Choice(settings, defaults.fishing, "reelNotificationSound", NQOL.Util.GetAlertSoundValidValues())

    if type(settings.tracker) ~= "table" then
        settings.tracker = {}
    end

    if type(settings.tracker.enabled) == "boolean" and settings.tracker.mode == nil then
        settings.tracker.mode = settings.tracker.enabled and TRACKER_MODE_ON or TRACKER_MODE_OFF
        settings.tracker.enabled = nil
    end
    NQOL.Settings.Choice(settings.tracker, trackerDefaults, "mode", VALID_TRACKER_MODES)
    NQOL.Settings.Choice(settings.tracker, trackerDefaults, "orientation", VALID_TRACKER_ORIENTATIONS)
    NQOL.Settings.Boolean(settings.tracker, trackerDefaults, "showInSettings")
    NQOL.Settings.ClampedNumber(settings.tracker, trackerDefaults, "horizontalPosition", 0, 100)
    NQOL.Settings.ClampedNumber(settings.tracker, trackerDefaults, "verticalPosition", 0, 100)
    if not NQOL.Util.IsFontChoice(settings.tracker.font) then
        settings.tracker.font = trackerDefaults.font
    end
    NQOL.Settings.ClampedNumber(settings.tracker, trackerDefaults, "fontSize", TRACKER_FONT_SIZE_MIN, TRACKER_FONT_SIZE_MAX, true)
    NQOL.Settings.ClampedNumber(settings.tracker, trackerDefaults, "backgroundOpacity", TRACKER_BACKGROUND_OPACITY_MIN, TRACKER_BACKGROUND_OPACITY_MAX, true)

    return settings
end

local function IsEnabled()
    return GetSettings().reelNotification == true
end

local function IsAutoSelectBaitEnabled()
    return GetSettings().autoSelectBait == true
end

local function IsReportBaitSwitchEnabled()
    return GetSettings().reportBaitSwitch == true
end

local function IsFishingTrackerEnabled()
    local mode = GetSettings().tracker.mode
    return mode == TRACKER_MODE_ON or (mode == TRACKER_MODE_AUTO and trackerReticleOverFishingHole == true)
end

local function IsFishingTrackerSettingsPreviewActive()
    if not trackerSettingsPanelVisible or GetSettings().tracker.showInSettings ~= true then
        return false
    end

    local gamepadOptions = NQOL.GamepadOptions
    if not gamepadOptions or not GAMEPAD_OPTIONS or GAMEPAD_OPTIONS.currentCategory ~= gamepadOptions.FISHING_TRACKER_PANEL_ID then
        return false
    end

    if not SCENE_MANAGER then
        return true
    end

    local panelScene = SCENE_MANAGER:GetScene("gamepad_options_panel")
    if not panelScene then
        return true
    end

    return (panelScene.IsShowing and panelScene:IsShowing()) or (panelScene.IsShowingBaseScene and panelScene:IsShowingBaseScene())
end

local function StringContains(value, needle)
    return type(value) == "string" and string.find(value, needle, 1, true) ~= nil
end

local function NormalizeGameText(value)
    if type(value) ~= "string" or value == "" then
        return nil
    end

    local formatted = zo_strformat and zo_strformat("<<z:1>>", value) or value
    return string.lower(formatted)
end

local function GetWaterTypeFromInteractableName(interactableName)
    local normalizedName = NormalizeGameText(interactableName)
    if not normalizedName then
        return nil
    end

    for waterType, names in pairs(LOCALIZED_FISHING_HOLE_NAMES) do
        for _, name in ipairs(names) do
            local normalizedKnownName = NormalizeGameText(name)
            if normalizedKnownName and StringContains(normalizedName, normalizedKnownName) then
                return waterType
            end
        end
    end

    return nil
end

local function GetBaitKeyFromIcon(icon)
    if type(icon) ~= "string" or icon == "" then
        return nil
    end

    local loweredIcon = string.lower(icon)
    for baitKey, keywords in pairs(BAIT_KEYWORDS_BY_ICON) do
        for _, keyword in ipairs(keywords) do
            if StringContains(loweredIcon, keyword) then
                return baitKey
            end
        end
    end

    return nil
end

local function GetBaitKey(lureIndex)
    if type(GetFishingLureInfo) ~= "function" or type(lureIndex) ~= "number" or lureIndex <= 0 then
        return nil
    end

    local _, icon = GetFishingLureInfo(lureIndex)
    return GetBaitKeyFromIcon(icon) or BAIT_BY_LURE_INDEX[lureIndex]
end

local function ShowAutoSelectBaitAnnouncement(baitName, waterType)
    if not IsReportBaitSwitchEnabled() or not baitName or baitName == "" or not waterType or not CENTER_SCREEN_ANNOUNCE or not CENTER_SCREEN_ANNOUNCE.CreateMessageParams then
        return
    end

    local text = NQOL.L("features.fishing.switch_bait", baitName, WATER_TYPE_LABELS[waterType] or waterType)
    local sound = SOUNDS and SOUNDS.NONE or nil
    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_MAJOR_TEXT or CSA_CATEGORY_LARGE_TEXT, sound)
    messageParams:SetText(text)

    if messageParams.SetCSAType and CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT then
        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT)
    end

    if CENTER_SCREEN_ANNOUNCE.AddMessageWithParams then
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
    elseif CENTER_SCREEN_ANNOUNCE.DisplayMessage then
        CENTER_SCREEN_ANNOUNCE:DisplayMessage(messageParams)
    end
end

local function SelectBestBaitForWaterType(waterType)
    if type(GetNumFishingLures) ~= "function" or type(GetFishingLure) ~= "function" or type(GetFishingLureInfo) ~= "function" or type(SetFishingLure) ~= "function" then
        return false
    end

    local priority = BAIT_PRIORITY_BY_WATER_TYPE[waterType]
    if not priority then
        return false
    end

    local currentLure = GetFishingLure()
    if currentLure and currentLure > 0 then
        local _, _, stackCount = GetFishingLureInfo(currentLure)
        local currentBaitKey = GetBaitKey(currentLure)
        if stackCount and stackCount > 0 and currentBaitKey and BAIT_WATER_TYPES[currentBaitKey] == waterType then
            return true
        end
    end

    for _, desiredBaitKey in ipairs(priority) do
        for lureIndex = 1, GetNumFishingLures() do
            local baitName, _, stackCount = GetFishingLureInfo(lureIndex)
            if stackCount and stackCount > 0 and GetBaitKey(lureIndex) == desiredBaitKey then
                SetFishingLure(lureIndex)
                ShowAutoSelectBaitAnnouncement(baitName, waterType)
                return true
            end
        end
    end

    return false
end

local function AutoSelectBait(interactableName)
    if not IsAutoSelectBaitEnabled() or type(interactableName) ~= "string" or interactableName == "" then
        return
    end

    local waterType = GetWaterTypeFromInteractableName(interactableName)
    if waterType then
        SelectBestBaitForWaterType(waterType)
    end
end

local function CountCurrentBait()
    if type(GetFishingLure) ~= "function" or type(GetFishingLureInfo) ~= "function" then
        return 0
    end

    local lure = GetFishingLure()
    if lure and lure > 0 then
        return select(3, GetFishingLureInfo(lure)) or 0
    end

    return 0
end

local function StopNotification()
    if reelTimeline then
        reelTimeline:SetHandler("OnStop", nil)
        reelTimeline:Stop()
        reelTimeline:SetHandler("OnStop", StopNotification)
    end

    if reelWindow then
        reelWindow:SetAlpha(0)
        reelWindow:SetHidden(true)
    end

    EVENT_MANAGER:UnregisterForUpdate(REEL_UPDATE_NAMESPACE)
    EVENT_MANAGER:UnregisterForUpdate(REEL_UPDATE_NAMESPACE .. "_Sound")
end

local function GetSelectedSound()
    return NQOL.Util.ResolveAlertSound(GetSettings().reelNotificationSound)
        or NQOL.Util.ResolveAlertSound(NQOL.Util.GetAlertSoundDefault())
        or (SOUNDS and (SOUNDS.POSITIVE_CLICK or SOUNDS.DEFAULT_CLICK))
end

local function PlaySelectedSound()
    if PlaySound then
        local sound = GetSelectedSound()
        if sound then
            PlaySound(sound)
        end
    end
end

local function EnsureNotificationControl()
    if reelWindow then
        return
    end

    local wm = GetWindowManager()
    reelWindow = wm:CreateTopLevelWindow("NQOLFishingReelNotification")
    reelWindow:SetDimensions(ICON_SIZE, ICON_SIZE)
    reelWindow:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    reelWindow:SetDrawTier(DT_HIGH)
    reelWindow:SetDrawLayer(DL_OVERLAY)
    reelWindow:SetDrawLevel(200)
    reelWindow:SetMouseEnabled(false)
    reelWindow:SetHidden(true)
    reelWindow:SetAlpha(0)

    reelTexture = wm:CreateControl("$(parent)Icon", reelWindow, CT_TEXTURE)
    reelTexture:SetAnchorFill(reelWindow)
    reelTexture:SetTexture(ICON_TEXTURE)
    reelTexture:SetBlendMode(TEX_BLEND_MODE_ALPHA)

    local animationManager = GetAnimationManager()
    reelTimeline = animationManager:CreateTimeline()

    local fadeIn = reelTimeline:InsertAnimation(ANIMATION_ALPHA, reelWindow, 0)
    fadeIn:SetDuration(180)
    fadeIn:SetAlphaValues(0, 1)

    local scale = reelTimeline:InsertAnimation(ANIMATION_SCALE, reelWindow, 0)
    scale:SetDuration(700)
    scale:SetScaleValues(0.45, 1.45)
    scale:SetEasingFunction(ZO_EaseOutQuadratic)

    local fadeOut = reelTimeline:InsertAnimation(ANIMATION_ALPHA, reelWindow, 700)
    fadeOut:SetDuration(500)
    fadeOut:SetAlphaValues(1, 0)

    reelTimeline:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, 2)
    reelTimeline:SetHandler("OnStop", StopNotification)
end

local function PlayNotification()
    EVENT_MANAGER:UnregisterForUpdate(REEL_UPDATE_NAMESPACE)
    if not IsEnabled() then
        return
    end

    EnsureNotificationControl()
    reelWindow:ClearAnchors()
    reelWindow:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    reelWindow:SetScale(0.45)
    reelWindow:SetAlpha(0)
    reelWindow:SetHidden(false)
    reelTimeline:PlayFromStart()

    PlaySelectedSound()
    EVENT_MANAGER:RegisterForUpdate(REEL_UPDATE_NAMESPACE .. "_Sound", SOUND_REPEAT_INTERVAL_MS, PlaySelectedSound)

    EVENT_MANAGER:RegisterForUpdate(REEL_UPDATE_NAMESPACE, NOTIFY_TIMEOUT_MS, StopNotification)
end

local function GetCurrentFishingAchievements()
    local candidates = {}
    local function AddCandidate(zoneId)
        if zoneId and zoneId ~= 0 then
            table.insert(candidates, zoneId)
        end
    end

    if type(GetUnitZoneIndex) == "function" and type(GetZoneId) == "function" then
        AddCandidate(GetZoneId(GetUnitZoneIndex("player")))
    end

    if type(GetCurrentMapZoneIndex) == "function" and type(GetZoneId) == "function" then
        AddCandidate(GetZoneId(GetCurrentMapZoneIndex()))
    end

    if type(GetMapContentZoneId) == "function" then
        AddCandidate(GetMapContentZoneId())
    end

    local seen = {}
    local index = 1
    while candidates[index] do
        local zoneId = candidates[index]
        index = index + 1

        if not seen[zoneId] then
            seen[zoneId] = true
            local achievements = FISHING_ACHIEVEMENT_BY_ZONE_ID[zoneId]
            if achievements then
                return achievements
            end

            local parentZoneId = type(GetParentZoneId) == "function" and GetParentZoneId(zoneId) or nil
            local storyZoneId = type(GetZoneStoryZoneIdForZoneId) == "function" and GetZoneStoryZoneIdForZoneId(zoneId) or nil
            AddCandidate(parentZoneId)
            AddCandidate(storyZoneId)
        end
    end

    return nil
end

local function GetFishingTrackerStatus()
    local achievements = GetCurrentFishingAchievements()
    if not achievements then
        return nil
    end

    local status = {}
    local allAchievementsComplete = type(GetAchievementInfo) == "function" and #achievements > 0
    for _, achievementId in ipairs(achievements) do
        if allAchievementsComplete and select(5, GetAchievementInfo(achievementId)) ~= true then
            allAchievementsComplete = false
        end
    end

    if allAchievementsComplete then
        for _, waterType in ipairs(WATER_TYPE_ORDER) do
            status[waterType] = { done = true }
        end

        return status
    end

    return nil
end

local function ShouldShowFishingTracker()
    return IsFishingTrackerEnabled() or IsFishingTrackerSettingsPreviewActive()
end

local function ShouldRegisterFishingTrackerRefreshEvents()
    local trackerSettings = GetSettings().tracker
    return trackerSettings.mode ~= TRACKER_MODE_OFF or IsFishingTrackerSettingsPreviewActive()
end

local function MoveControlAbove(targetControl)
    if not targetControl then
        return
    end

    if targetControl.SetDrawLayer and DL_OVERLAY then
        targetControl:SetDrawLayer(DL_OVERLAY)
    end

    if targetControl.SetDrawTier and DT_HIGH then
        targetControl:SetDrawTier(DT_HIGH)
    end

    if targetControl.SetDrawLevel then
        targetControl:SetDrawLevel(TRACKER_DRAW_LEVEL)
    end
end

local function ResolveTrackerFont(sizeOffset)
    local trackerSettings = GetSettings().tracker
    local size = Clamp((tonumber(trackerSettings.fontSize) or defaults.fishing.tracker.fontSize) + (sizeOffset or 0), TRACKER_FONT_SIZE_MIN, TRACKER_FONT_SIZE_MAX + 8)
    local key = tostring(trackerSettings.font) .. ":" .. tostring(size)
    if not trackerFontStringCache[key] then
        trackerFontStringCache[key] = NQOL.Util.CreateFontString(trackerSettings.font, size, "ZoFontGamepad18")
    end

    return trackerFontStringCache[key]
end

local function GetTrackerFontSize(sizeOffset)
    return Clamp((tonumber(GetSettings().tracker.fontSize) or defaults.fishing.tracker.fontSize) + (sizeOffset or 0), TRACKER_FONT_SIZE_MIN, TRACKER_FONT_SIZE_MAX + 8)
end

local function GetTrackerLineHeight(sizeOffset)
    return GetTrackerFontSize(sizeOffset) + 6
end

local function GetTrackerStatusIconSize()
    return Round(GetTrackerFontSize(0) * TRACKER_STATUS_ICON_SCALE)
end

local function GetTrackerRowHeight()
    return math.max(GetTrackerLineHeight(0), GetTrackerStatusIconSize())
end

local function GetMeasuredTrackerTextWidth(control, text, sizeOffset)
    local font = ResolveTrackerFont(sizeOffset)
    local height = GetTrackerLineHeight(sizeOffset)
    local function Measure(label)
        if not label then
            return nil
        end

        label:SetFont(font)
        label:SetText(text or "")
        label:SetDimensions(4096, height)

        local width = label.GetTextDimensions and label:GetTextDimensions() or 0
        if width and width > 0 then
            return width + TRACKER_TEXT_WIDTH_PADDING
        end

        width = label.GetTextWidth and label:GetTextWidth() or 0
        if width and width > 0 then
            return width + TRACKER_TEXT_WIDTH_PADDING
        end

        return nil
    end

    return Measure(control) or Measure(trackerMeasureLabel)
end

local function GetTrackerTextWidth(control, text, sizeOffset)
    local width = GetMeasuredTrackerTextWidth(control, text, sizeOffset)
    if width then
        return width
    end

    trackerWindow.needsLayoutRetry = true
    return 0
end

local function IsFishingTrackerHorizontal()
    return GetSettings().tracker.orientation == TRACKER_ORIENTATION_HORIZONTAL
end

local function GetTrackerHudHeight()
    local rowCount = IsFishingTrackerHorizontal() and 1 or #WATER_TYPE_ORDER
    return TRACKER_PADDING + GetTrackerLineHeight(4) + TRACKER_ROW_GAP + (rowCount * GetTrackerRowHeight()) + ((rowCount - 1) * TRACKER_ROW_GAP) + TRACKER_PADDING
end

local function GetTrackerHudWidth()
    return trackerWindow and trackerWindow.contentWidth or TRACKER_FALLBACK_WIDTH
end

local function ApplyFishingTrackerPosition()
    if not trackerWindow or not GuiRoot then
        return
    end

    local trackerSettings = GetSettings().tracker
    local rootWidth = GuiRoot.GetWidth and GuiRoot:GetWidth() or 1920
    local rootHeight = GuiRoot.GetHeight and GuiRoot:GetHeight() or 1080
    local x = (rootWidth - GetTrackerHudWidth()) * (Clamp(trackerSettings.horizontalPosition, 0, 100) / 100)
    local y = (rootHeight - GetTrackerHudHeight()) * (Clamp(trackerSettings.verticalPosition, 0, 100) / 100)

    trackerWindow:ClearAnchors()
    trackerWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, Round(x), Round(y))
end

local function EnsureFishingTrackerControl()
    if trackerWindow then
        return
    end

    local wm = GetWindowManager()
    trackerWindow = wm:CreateTopLevelWindow("NQOLFishingTracker")
    trackerWindow.contentWidth = TRACKER_FALLBACK_WIDTH
    trackerWindow:SetDimensions(GetTrackerHudWidth(), GetTrackerHudHeight())
    trackerWindow:SetMouseEnabled(false)
    trackerWindow:SetHidden(true)
    MoveControlAbove(trackerWindow)

    local backdrop = wm:CreateControl("$(parent)Backdrop", trackerWindow, CT_BACKDROP)
    trackerWindow.background = backdrop
    backdrop:SetAnchor(TOPLEFT, trackerWindow, TOPLEFT, 0, 0)
    backdrop:SetDimensions(GetTrackerHudWidth(), GetTrackerHudHeight())
    backdrop:SetCenterColor(0, 0, 0, GetSettings().tracker.backgroundOpacity / 100)
    backdrop:SetEdgeColor(0, 0, 0, 0)

    trackerTitle = wm:CreateControl("$(parent)Title", trackerWindow, CT_LABEL)
    trackerTitle:SetAnchor(TOPLEFT, trackerWindow, TOPLEFT, TRACKER_PADDING, TRACKER_PADDING)
    trackerTitle:SetColor(1, 0.9, 0.65, 1)
    trackerTitle:SetText(NQOL.L("features.fishing.fishing_tracker_d082c00"))

    trackerMeasureLabel = wm:CreateControl("NQOLFishingTrackerMeasureLabel", GuiRoot, CT_LABEL)
    trackerMeasureLabel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, -4096, -4096)
    trackerMeasureLabel:SetDimensions(4096, GetTrackerLineHeight(0))
    trackerMeasureLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    trackerMeasureLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    local previous = trackerTitle
    for index, waterType in ipairs(WATER_TYPE_ORDER) do
        local row = wm:CreateControl("$(parent)Row" .. index, trackerWindow, CT_CONTROL)

        local statusIcon = wm:CreateControl("$(parent)StatusIcon", row, CT_TEXTURE)
        statusIcon:SetBlendMode(TEX_BLEND_MODE_ALPHA)

        local label = wm:CreateControl("$(parent)Label", row, CT_LABEL)
        label:SetColor(0.92, 0.92, 0.86, 1)
        label:SetText(WATER_TYPE_LABELS[waterType])

        trackerRows[waterType] = { row = row, statusIcon = statusIcon, label = label }
        previous = row
    end

end

local function ApplyFishingTrackerLayout()
    if not trackerWindow then
        return
    end

    local rowHeight = GetTrackerRowHeight()
    local iconSize = math.min(GetTrackerStatusIconSize(), rowHeight)
    local horizontal = IsFishingTrackerHorizontal()
    trackerWindow.needsLayoutRetry = false

    trackerTitle:SetFont(ResolveTrackerFont(4))
    trackerTitle:SetDimensions(2000, GetTrackerLineHeight(4))
    local contentWidth = GetTrackerTextWidth(trackerTitle, NQOL.L("features.fishing.fishing_tracker_d082c00"), 4) + (TRACKER_PADDING * 2)
    local horizontalRowsWidth = TRACKER_PADDING
    for index, waterType in ipairs(WATER_TYPE_ORDER) do
        local controls = trackerRows[waterType]
        controls.label:SetFont(ResolveTrackerFont(0))
        controls.label:SetDimensions(1000, rowHeight)
        local labelWidth = GetTrackerTextWidth(controls.label, WATER_TYPE_LABELS[waterType], 0)
        local rowWidth = TRACKER_PADDING + iconSize + TRACKER_ICON_GAP + labelWidth + TRACKER_PADDING
        if horizontal then
            horizontalRowsWidth = horizontalRowsWidth + iconSize + TRACKER_ICON_GAP + labelWidth
            if index < #WATER_TYPE_ORDER then
                horizontalRowsWidth = horizontalRowsWidth + TRACKER_HORIZONTAL_ITEM_GAP
            end
        else
            contentWidth = math.max(contentWidth, rowWidth)
        end
    end

    if horizontal then
        contentWidth = math.max(contentWidth, horizontalRowsWidth + TRACKER_PADDING)
    end

    trackerWindow.contentWidth = math.max(TRACKER_FALLBACK_WIDTH, Round(contentWidth))
    trackerWindow:SetDimensions(GetTrackerHudWidth(), GetTrackerHudHeight())
    if trackerWindow.background then
        trackerWindow.background:ClearAnchors()
        trackerWindow.background:SetDimensions(GetTrackerHudWidth(), GetTrackerHudHeight())
        trackerWindow.background:SetAnchor(TOPLEFT, trackerWindow, TOPLEFT, 0, 0)
        trackerWindow.background:SetCenterColor(0, 0, 0, GetSettings().tracker.backgroundOpacity / 100)
        trackerWindow.background:SetEdgeColor(0, 0, 0, 0)
    end

    trackerTitle:ClearAnchors()
    trackerTitle:SetDimensions(GetTrackerHudWidth() - (TRACKER_PADDING * 2), GetTrackerLineHeight(4))
    trackerTitle:SetAnchor(TOPLEFT, trackerWindow, TOPLEFT, TRACKER_PADDING, TRACKER_PADDING)

    local previous = trackerTitle
    local rowLeft = TRACKER_PADDING
    for index, waterType in ipairs(WATER_TYPE_ORDER) do
        local controls = trackerRows[waterType]
        local labelWidth = GetTrackerTextWidth(controls.label, WATER_TYPE_LABELS[waterType], 0)
        local rowWidth = iconSize + TRACKER_ICON_GAP + labelWidth
        controls.row:ClearAnchors()
        if horizontal then
            controls.row:SetDimensions(rowWidth, rowHeight)
            controls.row:SetAnchor(TOPLEFT, trackerWindow, TOPLEFT, rowLeft, TRACKER_PADDING + GetTrackerLineHeight(4) + TRACKER_ROW_GAP)
            rowLeft = rowLeft + rowWidth + TRACKER_HORIZONTAL_ITEM_GAP
        else
            controls.row:SetDimensions(GetTrackerHudWidth() - (TRACKER_PADDING * 2), rowHeight)
            controls.row:SetAnchor(TOPLEFT, previous, BOTTOMLEFT, 0, index == 1 and TRACKER_ROW_GAP or TRACKER_ROW_GAP)
        end
        controls.statusIcon:ClearAnchors()
        controls.statusIcon:SetDimensions(iconSize, iconSize)
        controls.statusIcon:SetAnchor(LEFT, controls.row, LEFT, 0, 0)
        controls.label:ClearAnchors()
        controls.label:SetDimensions(horizontal and labelWidth or GetTrackerHudWidth() - (TRACKER_PADDING * 2) - iconSize - TRACKER_ICON_GAP, rowHeight)
        controls.label:SetAnchor(LEFT, controls.statusIcon, RIGHT, TRACKER_ICON_GAP, 0)
        previous = controls.row
    end

    ApplyFishingTrackerPosition()
end

local function QueueFishingTrackerLayoutRetry()
    if trackerLayoutRetryQueued or not trackerWindow or not trackerWindow.needsLayoutRetry then
        return
    end

    trackerLayoutRetryQueued = true
    EVENT_MANAGER:UnregisterForUpdate(TRACKER_LAYOUT_UPDATE_NAMESPACE)
    EVENT_MANAGER:RegisterForUpdate(TRACKER_LAYOUT_UPDATE_NAMESPACE, 50, function()
        trackerLayoutRetryQueued = false
        EVENT_MANAGER:UnregisterForUpdate(TRACKER_LAYOUT_UPDATE_NAMESPACE)
        if trackerWindow and not trackerWindow:IsHidden() then
            ApplyFishingTrackerLayout()
        end
    end)
end

local function SetTrackerStatusIcon(controls, done)
    controls.statusIcon:SetTexture(done and TRACKER_DONE_ICON or TRACKER_NOT_DONE_ICON)
    if done then
        controls.statusIcon:SetColor(0.45, 1, 0.52, 1)
    else
        controls.statusIcon:SetColor(1, 0.22, 0.2, 1)
    end
end

local function RefreshFishingTracker()
    if not ShouldShowFishingTracker() then
        if trackerWindow then
            trackerWindow:SetHidden(true)
        end
        EVENT_MANAGER:UnregisterForUpdate(TRACKER_LAYOUT_UPDATE_NAMESPACE)
        trackerLayoutRetryQueued = false
        return
    end

    EnsureFishingTrackerControl()
    trackerWindow:SetHidden(false)
    ApplyFishingTrackerLayout()
    QueueFishingTrackerLayoutRetry()

    local status = GetFishingTrackerStatus()
    if not status then
        for _, waterType in ipairs(WATER_TYPE_ORDER) do
            local controls = trackerRows[waterType]
            controls.row:SetHidden(false)
            SetTrackerStatusIcon(controls, false)
        end
        return
    end

    for _, waterType in ipairs(WATER_TYPE_ORDER) do
        local entry = status[waterType]
        local controls = trackerRows[waterType]
        controls.row:SetHidden(entry == nil)
        if entry then
            SetTrackerStatusIcon(controls, entry.done == true)
        end
    end
end

local function QueueFishingTrackerRefresh()
    EVENT_MANAGER:UnregisterForUpdate(TRACKER_UPDATE_NAMESPACE)
    EVENT_MANAGER:RegisterForUpdate(TRACKER_UPDATE_NAMESPACE, 500, function()
        EVENT_MANAGER:UnregisterForUpdate(TRACKER_UPDATE_NAMESPACE)
        RefreshFishingTracker()
    end)
end

local function SetFishingTrackerReticleOverFishingHole(overFishingHole)
    overFishingHole = overFishingHole == true
    if trackerReticleOverFishingHole == overFishingHole then
        return
    end

    trackerReticleOverFishingHole = overFishingHole
    if GetSettings().tracker.mode == TRACKER_MODE_AUTO then
        RefreshFishingTracker()
    end
end

local function SetFishingTrackerEventsRegistered(registered)
    if trackerRegistered == registered then
        return
    end

    trackerRegistered = registered
    if registered then
        if EVENT_PLAYER_ACTIVATED then
            EVENT_MANAGER:RegisterForEvent(TRACKER_UPDATE_NAMESPACE, EVENT_PLAYER_ACTIVATED, QueueFishingTrackerRefresh)
        end
        if EVENT_ZONE_CHANGED then
            EVENT_MANAGER:RegisterForEvent(TRACKER_UPDATE_NAMESPACE, EVENT_ZONE_CHANGED, QueueFishingTrackerRefresh)
        end
        if EVENT_ACHIEVEMENT_UPDATED then
            EVENT_MANAGER:RegisterForEvent(TRACKER_UPDATE_NAMESPACE, EVENT_ACHIEVEMENT_UPDATED, QueueFishingTrackerRefresh)
        end
        if EVENT_ACHIEVEMENT_AWARDED then
            EVENT_MANAGER:RegisterForEvent(TRACKER_UPDATE_NAMESPACE, EVENT_ACHIEVEMENT_AWARDED, QueueFishingTrackerRefresh)
        end
        if EVENT_SCREEN_RESIZED then
            EVENT_MANAGER:RegisterForEvent(TRACKER_UPDATE_NAMESPACE, EVENT_SCREEN_RESIZED, ApplyFishingTrackerPosition)
        end
    else
        if EVENT_PLAYER_ACTIVATED then
            EVENT_MANAGER:UnregisterForEvent(TRACKER_UPDATE_NAMESPACE, EVENT_PLAYER_ACTIVATED)
        end
        if EVENT_ZONE_CHANGED then
            EVENT_MANAGER:UnregisterForEvent(TRACKER_UPDATE_NAMESPACE, EVENT_ZONE_CHANGED)
        end
        if EVENT_ACHIEVEMENT_UPDATED then
            EVENT_MANAGER:UnregisterForEvent(TRACKER_UPDATE_NAMESPACE, EVENT_ACHIEVEMENT_UPDATED)
        end
        if EVENT_ACHIEVEMENT_AWARDED then
            EVENT_MANAGER:UnregisterForEvent(TRACKER_UPDATE_NAMESPACE, EVENT_ACHIEVEMENT_AWARDED)
        end
        if EVENT_SCREEN_RESIZED then
            EVENT_MANAGER:UnregisterForEvent(TRACKER_UPDATE_NAMESPACE, EVENT_SCREEN_RESIZED)
        end
        EVENT_MANAGER:UnregisterForUpdate(TRACKER_UPDATE_NAMESPACE)
        EVENT_MANAGER:UnregisterForUpdate(TRACKER_LAYOUT_UPDATE_NAMESPACE)
        trackerLayoutRetryQueued = false
    end
end

local function RefreshFishingTrackerRegistrations()
    SetFishingTrackerEventsRegistered(ShouldRegisterFishingTrackerRefreshEvents())
end

local function OnSlotUpdate(_, bagId, _, isNew)
    if not fishing or isNew or (bagId ~= BAG_BACKPACK and bagId ~= BAG_VIRTUAL) then
        return
    end

    local count = CountCurrentBait()
    if currentBaitCount - count == 1 then
        EVENT_MANAGER:RegisterForUpdate(REEL_UPDATE_NAMESPACE, NOTIFY_DELAY_MS, PlayNotification)
    end

    currentBaitCount = count
end

local function StopFishing()
    if not fishing then
        return
    end

    fishing = false
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_LOOT_RECEIVED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_LOOT_CLOSED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    StopNotification()
end

local function StartFishing()
    local lure = type(GetFishingLure) == "function" and GetFishingLure() or nil
    if type(lure) ~= "number" or lure <= 0 then
        StopFishing()
        return
    end

    StopNotification()
    currentBaitCount = CountCurrentBait()
    fishing = true

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_LOOT_RECEIVED, StopNotification)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_LOOT_CLOSED, StopFishing)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnSlotUpdate)
end

local function IsCurrentInteractionFishingNode()
    if type(GetGameCameraInteractableActionInfo) ~= "function" then
        return false
    end

    local _, _, _, _, additionalInfo = GetGameCameraInteractableActionInfo()
    return additionalInfo == ADDITIONAL_INTERACT_INFO_FISHING_NODE
end

local function OnInteractionShown()
    if type(GetGameCameraInteractableActionInfo) ~= "function" then
        return false
    end

    local action, interactableName, _, _, additionalInfo = GetGameCameraInteractableActionInfo()
    local isFishingNode = additionalInfo == ADDITIONAL_INTERACT_INFO_FISHING_NODE
    SetFishingTrackerReticleOverFishingHole(isFishingNode)

    if lastAction == action then
        return false
    end

    lastAction = action

    if isFishingNode then
        fishingInteractableName = interactableName
        AutoSelectBait(interactableName)
        StopFishing()
    elseif interactableName == fishingInteractableName then
        StartFishing()
    else
        StopFishing()
    end

    return false
end

local function OnInteractionHidden()
    if type(GetGameCameraInteractableActionInfo) ~= "function" then
        return false
    end

    local _, interactableName = GetGameCameraInteractableActionInfo()
    lastAction = nil
    SetFishingTrackerReticleOverFishingHole(false)

    if interactableName == fishingInteractableName then
        StartFishing()
    else
        StopFishing()
    end

    return false
end

local function HookInteraction()
    if not RETICLE or not RETICLE.interact or not ZO_PreHookHandler then
        return
    end

    ZO_PreHookHandler(RETICLE.interact, "OnEffectivelyShown", OnInteractionShown)
    ZO_PreHookHandler(RETICLE.interact, "OnHide", OnInteractionHidden)
end

function Fishing.InitializeSavedVariables()
    savedVariables = NQOL.Settings.NewAccountWide(defaults)
    GetSettings()
end

function Fishing.Initialize()
    if initialized then
        return
    end

    initialized = true
    HookInteraction()
    RefreshFishingTrackerRegistrations()
    QueueFishingTrackerRefresh()
end

function Fishing.GetAutoSelectBait()
    return IsAutoSelectBaitEnabled()
end

function Fishing.GetAutoSelectBaitDefault()
    return defaults.fishing.autoSelectBait
end

function Fishing.SetAutoSelectBait(value)
    GetSettings().autoSelectBait = value == true
end

function Fishing.GetAutoSelectBaitLabel()
    return NQOL.L("features.fishing.auto_select_bait_label")
end

function Fishing.GetAutoSelectBaitTooltip()
    return NQOL.L("features.fishing.auto_select_bait_tooltip")
end

function Fishing.GetReportBaitSwitch()
    return IsReportBaitSwitchEnabled()
end

function Fishing.GetReportBaitSwitchDefault()
    return defaults.fishing.reportBaitSwitch
end

function Fishing.SetReportBaitSwitch(value)
    GetSettings().reportBaitSwitch = value == true
end

function Fishing.GetReportBaitSwitchLabel()
    return NQOL.L("features.fishing.report_bait_switch_label")
end

function Fishing.GetReportBaitSwitchTooltip()
    return NQOL.L("features.fishing.report_bait_switch_tooltip")
end

function Fishing.GetFishingTracker()
    return GetSettings().tracker.mode
end

function Fishing.GetFishingTrackerDefault()
    return defaults.fishing.tracker.mode
end

function Fishing.SetFishingTracker(value)
    if not VALID_TRACKER_MODES[value] then
        value = defaults.fishing.tracker.mode
    end

    GetSettings().tracker.mode = value
    RefreshFishingTrackerRegistrations()
    if value == TRACKER_MODE_AUTO then
        SetFishingTrackerReticleOverFishingHole(IsCurrentInteractionFishingNode())
    else
        SetFishingTrackerReticleOverFishingHole(false)
    end
    RefreshFishingTracker()
end

function Fishing.GetFishingTrackerChoices()
    local choices = {}
    for index, option in ipairs(TRACKER_MODE_OPTIONS) do
        choices[index] = option.key
    end
    return choices
end

function Fishing.GetFishingTrackerChoiceNames()
    local names = {}
    for index, option in ipairs(TRACKER_MODE_OPTIONS) do
        names[index] = option.name
    end
    return names
end

function Fishing.GetFishingTrackerLabel()
    return NQOL.L("features.fishing.fishing_tracker_label")
end

function Fishing.GetFishingTrackerTooltip()
    return NQOL.L("features.fishing.fishing_tracker_tooltip")
end

function Fishing.GetFishingTrackerOrientation()
    return GetSettings().tracker.orientation
end

function Fishing.GetFishingTrackerOrientationDefault()
    return defaults.fishing.tracker.orientation
end

function Fishing.SetFishingTrackerOrientation(value)
    if not VALID_TRACKER_ORIENTATIONS[value] then
        value = defaults.fishing.tracker.orientation
    end

    GetSettings().tracker.orientation = value
    RefreshFishingTracker()
end

function Fishing.GetFishingTrackerOrientationChoices()
    local choices = {}
    for index, option in ipairs(TRACKER_ORIENTATION_OPTIONS) do
        choices[index] = option.key
    end
    return choices
end

function Fishing.GetFishingTrackerOrientationChoiceNames()
    local names = {}
    for index, option in ipairs(TRACKER_ORIENTATION_OPTIONS) do
        names[index] = option.name
    end
    return names
end

function Fishing.GetFishingTrackerOrientationLabel()
    return NQOL.L("features.fishing.fishing_tracker_orientation_label")
end

function Fishing.GetFishingTrackerOrientationTooltip()
    return NQOL.L("features.fishing.fishing_tracker_orientation_tooltip")
end

function Fishing.SetSettingsPanelVisible(value)
    trackerSettingsPanelVisible = value == true
    RefreshFishingTrackerRegistrations()
    RefreshFishingTracker()
end

function Fishing.GetFishingTrackerShowInSettings()
    return GetSettings().tracker.showInSettings == true
end

function Fishing.SetFishingTrackerShowInSettings(value)
    GetSettings().tracker.showInSettings = value == true
    RefreshFishingTrackerRegistrations()
    RefreshFishingTracker()
end

function Fishing.GetFishingTrackerShowInSettingsLabel()
    return NQOL.L("features.fishing.fishing_tracker_show_in_settings_label")
end

function Fishing.GetFishingTrackerShowInSettingsTooltip()
    return NQOL.L("features.fishing.fishing_tracker_show_in_settings_tooltip")
end

function Fishing.GetFishingTrackerHorizontalPosition()
    return GetSettings().tracker.horizontalPosition
end

function Fishing.SetFishingTrackerHorizontalPosition(value)
    GetSettings().tracker.horizontalPosition = Clamp(value, 0, 100)
    ApplyFishingTrackerPosition()
end

function Fishing.GetFishingTrackerHorizontalPositionLabel()
    return NQOL.L("features.fishing.fishing_tracker_horizontal_position_label")
end

function Fishing.GetFishingTrackerHorizontalPositionTooltip()
    return NQOL.L("features.fishing.fishing_tracker_horizontal_position_tooltip")
end

function Fishing.GetFishingTrackerVerticalPosition()
    return GetSettings().tracker.verticalPosition
end

function Fishing.SetFishingTrackerVerticalPosition(value)
    GetSettings().tracker.verticalPosition = Clamp(value, 0, 100)
    ApplyFishingTrackerPosition()
end

function Fishing.GetFishingTrackerVerticalPositionLabel()
    return NQOL.L("features.fishing.fishing_tracker_vertical_position_label")
end

function Fishing.GetFishingTrackerVerticalPositionTooltip()
    return NQOL.L("features.fishing.fishing_tracker_vertical_position_tooltip")
end

function Fishing.GetFishingTrackerFontChoices()
    return NQOL.Util.GetFontChoices()
end

function Fishing.GetFishingTrackerFontChoiceNames()
    return NQOL.Util.GetFontChoiceNames()
end

function Fishing.GetFishingTrackerFont()
    return GetSettings().tracker.font
end

function Fishing.SetFishingTrackerFont(value)
    if not NQOL.Util.IsFontChoice(value) then
        value = NQOL.Util.GetDefaultFont()
    end
    GetSettings().tracker.font = value
    RefreshFishingTracker()
end

function Fishing.GetFishingTrackerFontLabel()
    return NQOL.L("features.fishing.fishing_tracker_font_label")
end

function Fishing.GetFishingTrackerFontTooltip()
    return NQOL.L("features.fishing.fishing_tracker_font_tooltip")
end

function Fishing.GetFishingTrackerFontSize()
    return GetSettings().tracker.fontSize
end

function Fishing.SetFishingTrackerFontSize(value)
    GetSettings().tracker.fontSize = Clamp(Round(value), TRACKER_FONT_SIZE_MIN, TRACKER_FONT_SIZE_MAX)
    RefreshFishingTracker()
end

function Fishing.GetFishingTrackerFontSizeMin()
    return TRACKER_FONT_SIZE_MIN
end

function Fishing.GetFishingTrackerFontSizeMax()
    return TRACKER_FONT_SIZE_MAX
end

function Fishing.GetFishingTrackerFontSizeLabel()
    return NQOL.L("features.fishing.fishing_tracker_font_size_label")
end

function Fishing.GetFishingTrackerFontSizeTooltip()
    return NQOL.L("features.fishing.fishing_tracker_font_size_tooltip")
end

function Fishing.GetFishingTrackerBackgroundOpacity()
    return GetSettings().tracker.backgroundOpacity
end

function Fishing.SetFishingTrackerBackgroundOpacity(value)
    GetSettings().tracker.backgroundOpacity = Clamp(Round(value), TRACKER_BACKGROUND_OPACITY_MIN, TRACKER_BACKGROUND_OPACITY_MAX)
    RefreshFishingTracker()
end

function Fishing.GetFishingTrackerBackgroundOpacityMin()
    return TRACKER_BACKGROUND_OPACITY_MIN
end

function Fishing.GetFishingTrackerBackgroundOpacityMax()
    return TRACKER_BACKGROUND_OPACITY_MAX
end

function Fishing.GetFishingTrackerBackgroundOpacityLabel()
    return NQOL.L("features.fishing.fishing_tracker_background_opacity_label")
end

function Fishing.GetFishingTrackerBackgroundOpacityTooltip()
    return NQOL.L("features.fishing.fishing_tracker_background_opacity_tooltip")
end

function Fishing.GetReelNotification()
    return IsEnabled()
end

function Fishing.GetReelNotificationDefault()
    return defaults.fishing.reelNotification
end

function Fishing.SetReelNotification(value)
    GetSettings().reelNotification = value == true
    if not IsEnabled() then
        StopNotification()
    end
end

function Fishing.GetReelNotificationLabel()
    return NQOL.L("features.fishing.reel_notification_label")
end

function Fishing.GetReelNotificationTooltip()
    return NQOL.L("features.fishing.reel_notification_tooltip")
end

function Fishing.GetReelNotificationSound()
    return GetSettings().reelNotificationSound
end

function Fishing.GetReelNotificationSoundDefault()
    return defaults.fishing.reelNotificationSound
end

function Fishing.SetReelNotificationSound(value)
    if NQOL.Util.IsAlertSoundChoice(value) then
        if GetSettings().reelNotificationSound == value then
            return
        end

        GetSettings().reelNotificationSound = value
        PlaySelectedSound()
    end
end

function Fishing.GetReelNotificationSoundChoices()
    return NQOL.Util.GetAlertSoundChoices()
end

function Fishing.GetReelNotificationSoundChoiceNames()
    return NQOL.Util.GetAlertSoundChoiceNames()
end

function Fishing.GetReelNotificationSoundLabel()
    return NQOL.L("features.fishing.reel_notification_sound_label")
end

function Fishing.GetReelNotificationSoundTooltip()
    return NQOL.L("features.fishing.reel_notification_sound_tooltip")
end

NQOL.Features.Fishing = Fishing
