NQOL = NQOL or {}

local Util = {}

local DEFAULT_FONT = "EsoUI/Common/Fonts/FTN57.slug"
local FONT_CHOICES = {
    "EsoUI/Common/Fonts/FTN47.slug",
    DEFAULT_FONT,
    "EsoUI/Common/Fonts/FTN87.slug",
    "EsoUI/Common/Fonts/Univers67.slug",
    "EsoUI/Common/Fonts/Univers57.slug",
    "EsoUI/Common/Fonts/ProseAntiquePSMT.slug",
    "EsoUI/Common/Fonts/Handwritten_Bold.slug",
}
local FONT_CHOICE_NAMES = NQOL.Lexicon.LocalizedList({
    "common.font.gamepad_light",
    "common.font.gamepad_medium",
    "common.font.gamepad_bold",
    "common.font.keyboard_bold",
    "common.font.keyboard_medium",
    "common.font.antique",
    "common.font.handwritten",
})
local LOCALE_FONT_OVERRIDES = {
    ru = {
        default = "EsoUI/Common/Fonts/Univers57Cyrillic-Condensed.slug",
        ["EsoUI/Common/Fonts/FTN87.slug"] = "EsoUI/Common/Fonts/Univers67Cyrillic-CondensedBold.slug",
        ["EsoUI/Common/Fonts/Univers67.slug"] = "EsoUI/Common/Fonts/Univers67Cyrillic-CondensedBold.slug",
        ["EsoUI/Common/Fonts/ProseAntiquePSMT.slug"] = "EsoUI/Common/Fonts/ProseAntiquePSMTCyrillic.slug",
        ["EsoUI/Common/Fonts/Handwritten_Bold.slug"] = "EsoUI/Common/Fonts/HandwrittenCyrillic_Bold.slug",
    },
    jp = {
        default = "EsoUI/Common/Fonts/ESO_FWNTLGUDC70-DB.slug",
        ["EsoUI/Common/Fonts/ProseAntiquePSMT.slug"] = "EsoUI/Common/Fonts/ESO_KafuPenji-M.slug",
        ["EsoUI/Common/Fonts/Handwritten_Bold.slug"] = "EsoUI/Common/Fonts/ESO_KafuPenji-M.slug",
    },
    zh = {
        default = "EsoUI/Common/Fonts/MYingHeiPRC-W5.slug",
        ["EsoUI/Common/Fonts/ProseAntiquePSMT.slug"] = "EsoUI/Common/Fonts/MYoyoPRC-Medium.slug",
        ["EsoUI/Common/Fonts/Handwritten_Bold.slug"] = "EsoUI/Common/Fonts/MYoyoPRC-Medium.slug",
    },
}
local VALID_FONTS = {}
for _, font in ipairs(FONT_CHOICES) do
    VALID_FONTS[font] = true
end

local ALERT_SOUND_OPTIONS = {
    { key = "abilityReady", labelKey = "features.fishing.sound_ability_ready", sound = "ABILITY_READY" },
    { key = "achievementAwarded", labelKey = "features.fishing.sound_achievement_awarded", sound = "ACHIEVEMENT_AWARDED" },
    { key = "alertError", labelKey = "features.fishing.sound_alert_error", sound = "GENERAL_ALERT_ERROR" },
    { key = "championCommitted", labelKey = "features.fishing.sound_champion_committed", sound = "CHAMPION_POINTS_COMMITTED" },
    { key = "collectibleUnlocked", labelKey = "features.fishing.sound_collectible_unlocked", sound = "COLLECTIBLE_UNLOCKED" },
    { key = "duelAccepted", labelKey = "features.fishing.sound_duel_accepted", sound = "DUEL_ACCEPTED" },
    { key = "duelStart", labelKey = "features.fishing.sound_duel_start", sound = "DUEL_START" },
    { key = "justiceBonus", labelKey = "features.fishing.sound_justice_bonus", sound = "JUSTICE_PICKPOCKET_BONUS" },
    { key = "levelUp", labelKey = "features.fishing.sound_level_up", sound = "LEVEL_UP" },
    { key = "mapPing", labelKey = "features.fishing.sound_map_ping", sound = "MAP_PING" },
    { key = "newNotification", labelKey = "features.fishing.sound_new_notification", sound = "NEW_NOTIFICATION" },
    { key = "objectiveDiscovered", labelKey = "features.fishing.sound_objective_discovered", sound = "OBJECTIVE_DISCOVERED" },
    { key = "positiveClick", labelKey = "features.fishing.sound_positive_click", sound = "POSITIVE_CLICK" },
    { key = "questComplete", labelKey = "features.fishing.sound_quest_complete", sound = "QUEST_COMPLETED" },
    { key = "telVarGained", labelKey = "features.fishing.sound_telvar_gained", sound = "TELVAR_GAINED" },
    { key = "trialCompleted", labelKey = "features.fishing.sound_trial_completed", sound = "RAID_TRIAL_COMPLETED" },
    { key = "ultimateReady", labelKey = "features.fishing.sound_ultimate_ready", sound = "ABILITY_ULTIMATE_READY" },
}
local VALID_ALERT_SOUND_KEYS = {}
for _, option in ipairs(ALERT_SOUND_OPTIONS) do VALID_ALERT_SOUND_KEYS[option.key] = true end

local championXpCumulative
local championXpCumulativeCount = 0
local championXpCumulativeTotal = 0

function Util.Clamp(value, minValue, maxValue)
    value = tonumber(value) or minValue

    if zo_clamp then
        return zo_clamp(value, minValue, maxValue)
    end

    if value < minValue then
        return minValue
    end

    if value > maxValue then
        return maxValue
    end

    return value
end

function Util.Round(value)
    value = tonumber(value) or 0

    if zo_round then
        return zo_round(value)
    end

    return math.floor(value + 0.5)
end

function Util.IsNonEmptyString(value)
    return type(value) == "string" and value ~= ""
end

function Util.StripChatMarkup(value)
    local text = tostring(value or "")

    text = string.gsub(text, "|H.-|h(.-)|h", "%1")
    text = string.gsub(text, "|c%x%x%x%x%x%x%x%x", "")
    text = string.gsub(text, "|c%x%x%x%x%x%x", "")
    text = string.gsub(text, "|r", "")

    return text
end

function Util.FormatNumber(value)
    if ZO_CommaDelimitNumber then
        return ZO_CommaDelimitNumber(value)
    end

    return tostring(value)
end

function Util.GetChampionXpRequirement(destinationChampionPoint)
    destinationChampionPoint = math.floor(tonumber(destinationChampionPoint) or 0)

    if GetNumChampionXPInChampionPoint and destinationChampionPoint > 0 then
        return tonumber(GetNumChampionXPInChampionPoint(destinationChampionPoint - 1)) or 0
    end

    return 0
end

function Util.GetChampionXpRequirementSum(firstDestinationChampionPoint, lastDestinationChampionPoint)
    firstDestinationChampionPoint = math.max(math.floor(tonumber(firstDestinationChampionPoint) or 0), 1)
    lastDestinationChampionPoint = math.floor(tonumber(lastDestinationChampionPoint) or 0)

    if lastDestinationChampionPoint < firstDestinationChampionPoint then
        return 0
    end

    if lastDestinationChampionPoint > championXpCumulativeCount then
        championXpCumulative = championXpCumulative or {}
        for destinationChampionPoint = championXpCumulativeCount + 1, lastDestinationChampionPoint do
            championXpCumulativeTotal = championXpCumulativeTotal + Util.GetChampionXpRequirement(destinationChampionPoint)
            championXpCumulative[destinationChampionPoint] = championXpCumulativeTotal
        end
        championXpCumulativeCount = lastDestinationChampionPoint
    end

    return (championXpCumulative[lastDestinationChampionPoint] or 0)
        - (championXpCumulative[firstDestinationChampionPoint - 1] or 0)
end

function Util.GetLanguage()
    return NQOL.Lexicon and NQOL.Lexicon.GetLanguage() or "en"
end

function Util.Lower(value)
    local text = tostring(value or "")
    return zo_strlower and zo_strlower(text) or string.lower(text)
end

function Util.GetAlertSoundDefault()
    return "duelStart"
end

function Util.GetAlertSoundValidValues()
    return VALID_ALERT_SOUND_KEYS
end

function Util.IsAlertSoundChoice(value)
    return VALID_ALERT_SOUND_KEYS[value] == true
end

function Util.GetAlertSoundChoices()
    local choices = {}
    for index, option in ipairs(ALERT_SOUND_OPTIONS) do choices[index] = option.key end
    return choices
end

function Util.GetAlertSoundChoiceNames()
    local names = {}
    for index, option in ipairs(ALERT_SOUND_OPTIONS) do names[index] = NQOL.L(option.labelKey) end
    return names
end

function Util.ResolveAlertSound(value)
    if not SOUNDS then return nil end
    for _, option in ipairs(ALERT_SOUND_OPTIONS) do
        if option.key == value then return SOUNDS[option.sound] end
    end
    return nil
end

function Util.PlayAlertSound(value)
    if not PlaySound then return end
    local sound = Util.ResolveAlertSound(value)
        or Util.ResolveAlertSound(Util.GetAlertSoundDefault())
        or (SOUNDS and (SOUNDS.ABILITY_READY or SOUNDS.DISPLAY_ANNOUNCEMENT or SOUNDS.NEW_NOTIFICATION))
    if sound then PlaySound(sound) end
end

function Util.Upper(value)
    local text = tostring(value or "")
    return zo_strupper and zo_strupper(text) or string.upper(text)
end

function Util.GetConsolePlatform()
    local serviceType = GetPlatformServiceType and GetPlatformServiceType() or nil
    if serviceType == PLATFORM_SERVICE_TYPE_XBL then
        return "XBOX"
    end

    if serviceType == PLATFORM_SERVICE_TYPE_PSN then
        return "PS"
    end

    if serviceType == PLATFORM_SERVICE_TYPE_ZOS
        or serviceType == PLATFORM_SERVICE_TYPE_STEAM
        or serviceType == PLATFORM_SERVICE_TYPE_EPIC
        or serviceType == PLATFORM_SERVICE_TYPE_DMM then
        return "PC"
    end

    return "?"
end

function Util.GetMegaserverName()
    if GetWorldName then
        local worldName = GetWorldName()
        if Util.IsNonEmptyString(worldName) then
            return worldName
        end
    end

    return NQOL.L("common.unknown_value")
end

function Util.GetDefaultFont()
    return DEFAULT_FONT
end

function Util.GetFontChoices()
    return FONT_CHOICES
end

function Util.GetFontChoiceNames()
    return FONT_CHOICE_NAMES
end

function Util.IsFontChoice(value)
    return VALID_FONTS[value] == true
end

function Util.ResolveFont(font)
    local localeFonts = LOCALE_FONT_OVERRIDES[Util.GetLanguage()]
    return localeFonts and (localeFonts[font] or localeFonts.default) or font
end

function Util.CreateFontString(font, size, fallbackFont)
    if ZO_CreateFontString then
        local fontStyle = FONT_STYLE_SOFT_SHADOW_THIN or FONT_STYLE_SHADOW or 1
        return ZO_CreateFontString(Util.ResolveFont(font), size, fontStyle)
    end

    return fallbackFont or "ZoFontGamepad34"
end

local function SetContentTextureLoadingState(textureControl, loading)
    if not textureControl then return end

    textureControl:SetHidden(true)
    local loadingControl = textureControl.nqolLoadingControl
    if loadingControl then
        loadingControl:SetHidden(true)
    end
    local loadedFrame = textureControl.nqolLoadedFrame
    if loadedFrame then
        loadedFrame:SetHidden(true)
    end
end

local function OnContentTextureLoaded(textureControl)
    if not textureControl or not textureControl.nqolRequestedTexturePath then return end
    if textureControl.IsTextureLoaded and not textureControl:IsTextureLoaded() then return end

    textureControl:SetHidden(false)
    local loadingControl = textureControl.nqolLoadingControl
    if loadingControl then
        loadingControl:SetHidden(true)
    end
    local loadedFrame = textureControl.nqolLoadedFrame
    if loadedFrame then
        loadedFrame:SetHidden(false)
    end
end

local CONTENT_TEXTURE_DELAY_MS = 180
local CONTENT_TEXTURE_UPDATE_INTERVAL_MS = 50
local CONTENT_TEXTURE_UPDATE_NAMESPACE = "NQOL_ContentTextureLoader"
local pendingContentTextures = setmetatable({}, { __mode = "k" })
local contentTextureUpdateRunning = false

local function GetContentTextureTimeMilliseconds()
    if GetFrameTimeMilliseconds then return GetFrameTimeMilliseconds() end
    if GetGameTimeMilliseconds then return GetGameTimeMilliseconds() end
    return 0
end

local function StopContentTextureUpdate()
    if not contentTextureUpdateRunning then return end
    if EVENT_MANAGER and EVENT_MANAGER.UnregisterForUpdate then
        EVENT_MANAGER:UnregisterForUpdate(CONTENT_TEXTURE_UPDATE_NAMESPACE)
    end
    contentTextureUpdateRunning = false
end

local function ProcessPendingContentTextures()
    local now = GetContentTextureTimeMilliseconds()
    local hasPendingTexture = false

    for textureControl in pairs(pendingContentTextures) do
        local texturePath = textureControl.nqolRequestedTexturePath
        local loadAt = textureControl.nqolContentTextureLoadAt
        if not texturePath or not loadAt then
            pendingContentTextures[textureControl] = nil
        elseif now >= loadAt then
            pendingContentTextures[textureControl] = nil
            textureControl.nqolContentTextureLoadAt = nil
            textureControl:SetTexture(texturePath)
            if not textureControl.IsTextureLoaded or textureControl:IsTextureLoaded() then
                OnContentTextureLoaded(textureControl)
            end
        else
            hasPendingTexture = true
        end
    end

    if not hasPendingTexture and not next(pendingContentTextures) then
        StopContentTextureUpdate()
    end
end

local function StartContentTextureUpdate()
    if contentTextureUpdateRunning then return end
    if not EVENT_MANAGER or not EVENT_MANAGER.RegisterForUpdate then
        for textureControl in pairs(pendingContentTextures) do
            textureControl.nqolContentTextureLoadAt = 0
        end
        ProcessPendingContentTextures()
        return
    end

    contentTextureUpdateRunning = true
    EVENT_MANAGER:RegisterForUpdate(CONTENT_TEXTURE_UPDATE_NAMESPACE, CONTENT_TEXTURE_UPDATE_INTERVAL_MS, ProcessPendingContentTextures)
end

function Util.ConfigureContentTexture(textureControl, loadingControl, loadedFrame)
    if not textureControl then return end

    textureControl.nqolLoadingControl = loadingControl
    textureControl.nqolLoadedFrame = loadedFrame
    textureControl:SetHidden(true)
    if loadingControl then
        loadingControl:SetHidden(true)
    end
    if loadedFrame then
        loadedFrame:SetHidden(true)
    end
    if textureControl.SetTextureReleaseOption and RELEASE_TEXTURE_AT_ZERO_REFERENCES then
        textureControl:SetTextureReleaseOption(RELEASE_TEXTURE_AT_ZERO_REFERENCES)
    end
    if textureControl.SetHandler then
        textureControl:SetHandler("OnTextureLoaded", OnContentTextureLoaded)
    end
end

function Util.ReleaseContentTexture(textureControl)
    if not textureControl then return end

    pendingContentTextures[textureControl] = nil
    textureControl.nqolRequestedTexturePath = nil
    textureControl.nqolContentTextureLoadAt = nil
    textureControl:SetTexture(nil)
    SetContentTextureLoadingState(textureControl, false)
    if not next(pendingContentTextures) then StopContentTextureUpdate() end
end

function Util.LoadContentTexture(textureControl, texturePath)
    if not textureControl or not Util.IsNonEmptyString(texturePath) then
        Util.ReleaseContentTexture(textureControl)
        return false
    end

    textureControl.nqolRequestedTexturePath = nil
    textureControl.nqolContentTextureLoadAt = nil
    textureControl:SetTexture(nil)
    SetContentTextureLoadingState(textureControl, true)
    textureControl.nqolRequestedTexturePath = texturePath
    textureControl.nqolContentTextureLoadAt = GetContentTextureTimeMilliseconds() + CONTENT_TEXTURE_DELAY_MS
    pendingContentTextures[textureControl] = true
    StartContentTextureUpdate()
    return true
end

NQOL.Util = Util
