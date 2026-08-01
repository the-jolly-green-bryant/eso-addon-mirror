NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local ChatFeature = {}

local DEFAULT_TIMESTAMP_FORMAT = "HH:mm"
local DEFAULT_MISSING_ITEM_WHISPER_MESSAGE = NQOL.L("features.chat.annotate_missing_items_whisper_message_default")
local EVENT_NAMESPACE = "NQOL_Chat"
local SAVED_MESSAGES_NONE = 0
local SAVED_MESSAGES_10 = 10
local SAVED_MESSAGES_25 = 25
local SAVED_MESSAGES_50 = 50
local RESTORED_MESSAGE_RED = 0.62
local RESTORED_MESSAGE_GREEN = 0.61
local RESTORED_MESSAGE_BLUE = 0.52
local HUD_WIDTH_MIN = 160
local HUD_WIDTH_MAX = 1920
local HUD_HEIGHT_MIN = 100
local HUD_HEIGHT_MAX = 1080
local HUD_DEFAULT_WIDTH = 490
local HUD_DEFAULT_HEIGHT = 280
local HUD_APPLY_DELAY_MS = 50
local MAX_GUILD_CHAT_COLORS = 5
local CHAT_LINK_PATTERN = "|H.-|h.-|h"
local MISSING_ITEM_ICON_DEFAULT_SIZE = 22
local MISSING_ITEM_ICON_SCALE = 32 / 22
local MISSING_ITEM_ICON_TEXTURE = "EsoUI/Art/Miscellaneous/Gamepad/gp_icon_locked32.dds"
local DEFAULT_GUILD_COLORS = {
    { r = 0.96, g = 0.78, b = 0.36, a = 1 },
    { r = 0.45, g = 0.84, b = 1.00, a = 1 },
    { r = 0.62, g = 0.93, b = 0.48, a = 1 },
    { r = 0.93, g = 0.58, b = 1.00, a = 1 },
    { r = 1.00, g = 0.60, b = 0.48, a = 1 },
}
local SAVED_MESSAGE_LIMITS = {
    [SAVED_MESSAGES_NONE] = 0,
    [SAVED_MESSAGES_10] = 10,
    [SAVED_MESSAGES_25] = 25,
    [SAVED_MESSAGES_50] = 50,
}
local SAVED_MESSAGE_CHOICES = {
    SAVED_MESSAGES_NONE,
    SAVED_MESSAGES_10,
    SAVED_MESSAGES_25,
    SAVED_MESSAGES_50,
}
local SAVED_MESSAGE_CHOICE_NAMES = NQOL.Lexicon.LocalizedList({
    "common.none",
    { "features.chat.last_messages", 10 },
    { "features.chat.last_messages", 25 },
    { "features.chat.last_messages", 50 },
})
local Unpack = unpack or table.unpack

local defaults = {
    chat = {
        addTimestamp = false,
        timestampFormat = DEFAULT_TIMESTAMP_FORMAT,
        savedMessages = SAVED_MESSAGES_NONE,
        messageHistory = {},
        keepHudOpen = false,
        hudHorizontalPosition = 100,
        hudVerticalPosition = 100,
        hudWidth = HUD_DEFAULT_WIDTH,
        hudHeight = HUD_DEFAULT_HEIGHT,
        removeBackground = false,
        filterGuildAds = false,
        filterPlusMessages = false,
        filterWttWts = false,
        filterFriendStatus = false,
        annotateMissingItems = {
            enabled = false,
            whisperMessage = DEFAULT_MISSING_ITEM_WHISPER_MESSAGE,
        },
        whisperColor = { r = 0.74, g = 0.64, b = 1.00, a = 1 },
        guildMessageColors = {
            enabled = false,
            colorsByGuildId = {},
            officerColorsByGuildId = {},
        },
    },
}

local savedVariables
local initialized = false
local messageHookInstalled = false
local channelHookInstalled = false
local routerHookInstalled = false
local originalAddMessage
local originalRegisterMessageFormatter
local hookAttempts = 0
local hudHookAttempts = 0
local restoringHistory = false
local historyRestored = false
local hudHookInstalled = false
local hudApplyQueued = false
local chatSettingsPanelVisible = false
local guildColorEventsRegistered = false
local originalGamepadChatMinimize
local originalGamepadChatMaximize
local originalGamepadChatHideWhenDeactivated
local formattingChatChannelMessage = false
local wrappedRouterFormatters = {}

local Clamp = NQOL.Util.Clamp
local Round = NQOL.Util.Round

local function CopyColor(color)
    return {
        r = Clamp(tonumber(color and color.r) or 1, 0, 1),
        g = Clamp(tonumber(color and color.g) or 1, 0, 1),
        b = Clamp(tonumber(color and color.b) or 1, 0, 1),
        a = Clamp(tonumber(color and color.a) or 1, 0, 1),
    }
end

local function GetSettings()
    local settings = NQOL.Settings.GetSection(savedVariables, defaults, "chat")
    local defaultSettings = defaults.chat

    NQOL.Settings.Default(settings, defaultSettings, "addTimestamp")

    if settings.timestampFormat == nil or settings.timestampFormat == "" then
        settings.timestampFormat = defaultSettings.timestampFormat
    end

    if SAVED_MESSAGE_LIMITS[settings.savedMessages] == nil then
        settings.savedMessages = defaultSettings.savedMessages
    end

    NQOL.Settings.EnsureTable(settings, "messageHistory")

    NQOL.Settings.Boolean(settings, defaultSettings, "keepHudOpen")
    NQOL.Settings.ClampedNumber(settings, defaultSettings, "hudHorizontalPosition", 0, 100)
    NQOL.Settings.ClampedNumber(settings, defaultSettings, "hudVerticalPosition", 0, 100)
    NQOL.Settings.ClampedNumber(settings, defaultSettings, "hudWidth", HUD_WIDTH_MIN, HUD_WIDTH_MAX, true)
    NQOL.Settings.ClampedNumber(settings, defaultSettings, "hudHeight", HUD_HEIGHT_MIN, HUD_HEIGHT_MAX, true)
    NQOL.Settings.Boolean(settings, defaultSettings, "removeBackground")
    NQOL.Settings.Boolean(settings, defaultSettings, "filterGuildAds")
    NQOL.Settings.Boolean(settings, defaultSettings, "filterPlusMessages")
    NQOL.Settings.Boolean(settings, defaultSettings, "filterWttWts")
    NQOL.Settings.Boolean(settings, defaultSettings, "filterFriendStatus")
    local annotateMissingItems = NQOL.Settings.EnsureTable(settings, "annotateMissingItems")
    NQOL.Settings.Boolean(annotateMissingItems, defaultSettings.annotateMissingItems, "enabled")
    NQOL.Settings.Default(annotateMissingItems, defaultSettings.annotateMissingItems, "whisperMessage")
    if type(annotateMissingItems.whisperMessage) ~= "string" or annotateMissingItems.whisperMessage == "" then
        annotateMissingItems.whisperMessage = defaultSettings.annotateMissingItems.whisperMessage
    end
    local whisperColor = settings.whisperColor
    if type(whisperColor) ~= "table" then
        settings.whisperColor = CopyColor(defaultSettings.whisperColor)
    else
        settings.whisperColor = CopyColor(whisperColor)
    end
    local guildMessageColors = NQOL.Settings.EnsureTable(settings, "guildMessageColors")
    NQOL.Settings.Boolean(guildMessageColors, defaultSettings.guildMessageColors, "enabled")
    NQOL.Settings.EnsureTable(guildMessageColors, "colorsByGuildId")
    NQOL.Settings.EnsureTable(guildMessageColors, "officerColorsByGuildId")

    return settings
end

local function IsMissingCollectible(itemLink)
    if not GetItemLinkContainerCollectibleId then
        return false
    end

    local collectibleId = GetItemLinkContainerCollectibleId(itemLink)
    if not collectibleId or collectibleId <= 0 then
        return false
    end

    local isOwned
    if IsCollectibleOwnedByDefId then
        isOwned = IsCollectibleOwnedByDefId(collectibleId)
    elseif IsCollectibleUnlocked then
        isOwned = IsCollectibleUnlocked(collectibleId)
    else
        return false
    end

    if isOwned then
        return false
    end

    if GetCollectibleCategoryType
        and CanCombinationFragmentBeUnlocked
        and COLLECTIBLE_CATEGORY_TYPE_COMBINATION_FRAGMENT
        and GetCollectibleCategoryType(collectibleId) == COLLECTIBLE_CATEGORY_TYPE_COMBINATION_FRAGMENT
        and not CanCombinationFragmentBeUnlocked(collectibleId)
    then
        return false
    end

    return true
end

local function IsMissingItemLink(itemLink)
    if not GetItemLinkItemType then
        return false
    end

    local itemType = GetItemLinkItemType(itemLink)
    if itemType == ITEMTYPE_RECIPE and IsItemLinkRecipeKnown then
        return not IsItemLinkRecipeKnown(itemLink)
    end

    if itemType == ITEMTYPE_RACIAL_STYLE_MOTIF and IsItemLinkBookKnown then
        return not IsItemLinkBookKnown(itemLink)
    end

    if IsItemLinkSetCollectionPiece
        and GetItemLinkItemId
        and IsItemSetCollectionPieceUnlocked
        and IsItemLinkSetCollectionPiece(itemLink)
    then
        local itemId = GetItemLinkItemId(itemLink)
        return itemId and itemId > 0 and not IsItemSetCollectionPieceUnlocked(itemId)
    end

    return IsMissingCollectible(itemLink)
end

local function GetMissingItemIcon()
    local chatFontSize = GetChatFontSize and tonumber(GetChatFontSize()) or MISSING_ITEM_ICON_DEFAULT_SIZE
    local iconSize = chatFontSize * MISSING_ITEM_ICON_SCALE
    iconSize = math.max(1, math.floor(iconSize + 0.5))
    return string.format("|t%d:%d:%s|t", iconSize, iconSize, MISSING_ITEM_ICON_TEXTURE)
end

local function AnnotateMissingItemLinks(message, useNarrationMarker)
    if not GetSettings().annotateMissingItems.enabled or type(message) ~= "string" or message == "" then
        return message
    end

    local marker = useNarrationMarker and NQOL.L("features.chat.annotate_missing_items_narration") or GetMissingItemIcon()
    return string.gsub(message, CHAT_LINK_PATTERN, function(link)
        if GetLinkType and GetLinkType(link) == LINK_TYPE_ITEM and IsMissingItemLink(link) then
            return link .. " " .. marker
        end

        return link
    end)
end

local function GetGuildIdForIndex(guildIndex)
    if type(guildIndex) ~= "number" or guildIndex < 1 or guildIndex > MAX_GUILD_CHAT_COLORS or not GetGuildId then
        return nil
    end

    local numGuilds = GetNumGuilds and GetNumGuilds() or 0
    if guildIndex > numGuilds then
        return nil
    end

    local guildId = GetGuildId(guildIndex)
    if guildId == nil or guildId == 0 then
        return nil
    end

    return guildId
end

local function GetGuildNameForIndex(guildIndex)
    local guildId = GetGuildIdForIndex(guildIndex)
    if guildId and GetGuildName then
        local guildName = GetGuildName(guildId)
        if guildName and guildName ~= "" then
            return guildName
        end
    end

    return NQOL.L("features.chat.guild_slot", tostring(guildIndex))
end

local function GetGuildIndexForMessageType(messageType)
    if CHAT_CHANNEL_GUILD_1 and (messageType == CHAT_CHANNEL_GUILD_1 or messageType == CHAT_CHANNEL_OFFICER_1) then
        return 1
    elseif CHAT_CHANNEL_GUILD_2 and (messageType == CHAT_CHANNEL_GUILD_2 or messageType == CHAT_CHANNEL_OFFICER_2) then
        return 2
    elseif CHAT_CHANNEL_GUILD_3 and (messageType == CHAT_CHANNEL_GUILD_3 or messageType == CHAT_CHANNEL_OFFICER_3) then
        return 3
    elseif CHAT_CHANNEL_GUILD_4 and (messageType == CHAT_CHANNEL_GUILD_4 or messageType == CHAT_CHANNEL_OFFICER_4) then
        return 4
    elseif CHAT_CHANNEL_GUILD_5 and (messageType == CHAT_CHANNEL_GUILD_5 or messageType == CHAT_CHANNEL_OFFICER_5) then
        return 5
    end

    return nil
end

local function IsOfficerMessageType(messageType)
    return (CHAT_CHANNEL_OFFICER_1 and messageType == CHAT_CHANNEL_OFFICER_1)
        or (CHAT_CHANNEL_OFFICER_2 and messageType == CHAT_CHANNEL_OFFICER_2)
        or (CHAT_CHANNEL_OFFICER_3 and messageType == CHAT_CHANNEL_OFFICER_3)
        or (CHAT_CHANNEL_OFFICER_4 and messageType == CHAT_CHANNEL_OFFICER_4)
        or (CHAT_CHANNEL_OFFICER_5 and messageType == CHAT_CHANNEL_OFFICER_5)
end

local function GetGuildColorTable(guildIndex)
    local guildId = GetGuildIdForIndex(guildIndex)
    local colorsByGuildId = GetSettings().guildMessageColors.colorsByGuildId

    if guildId then
        local savedColor = colorsByGuildId[tostring(guildId)]
        if type(savedColor) == "table" then
            colorsByGuildId[tostring(guildId)] = CopyColor(savedColor)
            return colorsByGuildId[tostring(guildId)]
        end
    end

    return DEFAULT_GUILD_COLORS[guildIndex] or DEFAULT_GUILD_COLORS[1]
end

local function GetOfficerColorTable(guildIndex)
    local guildId = GetGuildIdForIndex(guildIndex)
    local officerColorsByGuildId = GetSettings().guildMessageColors.officerColorsByGuildId

    if guildId then
        local savedColor = officerColorsByGuildId[tostring(guildId)]
        if type(savedColor) == "table" then
            officerColorsByGuildId[tostring(guildId)] = CopyColor(savedColor)
            return officerColorsByGuildId[tostring(guildId)]
        end
    end

    return GetGuildColorTable(guildIndex)
end

local function GetColorTag(color)
    local red = Round(Clamp(color.r, 0, 1) * 255)
    local green = Round(Clamp(color.g, 0, 1) * 255)
    local blue = Round(Clamp(color.b, 0, 1) * 255)
    return string.format("|c%02X%02X%02X", red, green, blue)
end

local function GetColorDef(color)
    if ZO_ColorDef and color then
        return ZO_ColorDef:New(color.r, color.g, color.b, color.a or 1)
    end

    return nil
end

local function GetGamepadChatControl()
    if not GAMEPAD_CHAT_SYSTEM or not GAMEPAD_CHAT_SYSTEM.primaryContainer then
        return nil
    end

    return GAMEPAD_CHAT_SYSTEM.primaryContainer.control
end

local function ShouldPreviewHud()
    return chatSettingsPanelVisible == true
end

local function IsGameHudShowing()
    return HUD_FRAGMENT and HUD_FRAGMENT.IsShowing and HUD_FRAGMENT:IsShowing()
end

local function ShouldForceHudOpen()
    return ShouldPreviewHud() or (GetSettings().keepHudOpen == true and IsGameHudShowing())
end

local function ShouldPersistHudOpen()
    return GetSettings().keepHudOpen == true
end

local function EnableNativeHud()
    if GAMEPAD_CHAT_SYSTEM and GAMEPAD_CHAT_SYSTEM.SetHUDEnabled then
        GAMEPAD_CHAT_SYSTEM:SetHUDEnabled(true)
    end
end

local function GetGamepadChatBackgroundControl()
    if GAMEPAD_CHAT_SYSTEM and GAMEPAD_CHAT_SYSTEM.control and GAMEPAD_CHAT_SYSTEM.control.GetNamedChild then
        return GAMEPAD_CHAT_SYSTEM.control:GetNamedChild("Bg")
    end

    if ZO_GamepadTextChatBg then
        return ZO_GamepadTextChatBg
    end

    return nil
end

local function ApplyHudBackground()
    local background = GetGamepadChatBackgroundControl()
    if background and background.SetHidden then
        background:SetHidden(GetSettings().removeBackground == true)
    end
end

local function ApplyGamepadChatExtents(width, height)
    if not GAMEPAD_CHAT_SYSTEM then
        return nil
    end

    if GAMEPAD_CHAT_SYSTEM.SetContainerExtents then
        GAMEPAD_CHAT_SYSTEM:SetContainerExtents(HUD_WIDTH_MIN, width, HUD_HEIGHT_MIN, height)
    end

    local container = GAMEPAD_CHAT_SYSTEM.primaryContainer
    if container and container.control and container.control.SetDimensionConstraints then
        container.control:SetDimensionConstraints(HUD_WIDTH_MIN, HUD_HEIGHT_MIN, width, height)
    end

    return container
end

local function ApplyHudLayout()
    hudApplyQueued = false

    local control = GetGamepadChatControl()
    if not control or not GuiRoot then
        return
    end

    local settings = GetSettings()
    local rootWidth, rootHeight = GuiRoot:GetDimensions()
    local width = Clamp(settings.hudWidth, HUD_WIDTH_MIN, HUD_WIDTH_MAX)
    local height = Clamp(settings.hudHeight, HUD_HEIGHT_MIN, HUD_HEIGHT_MAX)
    local availableWidth = math.max(rootWidth - width, 0)
    local availableHeight = math.max(rootHeight - height, 0)
    local left = Round(availableWidth * settings.hudHorizontalPosition / 100)
    local top = Round(availableHeight * settings.hudVerticalPosition / 100)
    local rightOffset = left + width - rootWidth
    local bottomOffset = top + height - rootHeight

    local container = ApplyGamepadChatExtents(width, height)
    control:SetDimensions(width, height)
    control:ClearAnchors()
    control:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, rightOffset, bottomOffset)

    if ShouldForceHudOpen() then
        if ShouldPersistHudOpen() then
            EnableNativeHud()
        end

        if GAMEPAD_CHAT_SYSTEM and GAMEPAD_CHAT_SYSTEM.Maximize then
            GAMEPAD_CHAT_SYSTEM:Maximize()
        end

        if control.SetHidden then
            control:SetHidden(false)
        end

        if container and container.windowContainer then
            container.windowContainer:SetHidden(false)
        end
    end

    if container then
        if container.PerformLayout then
            container:PerformLayout()
        end

        if container.SyncScrollToBuffer then
            container:SyncScrollToBuffer()
        end
    end

    ApplyHudBackground()
end

local function QueueApplyHudLayout()
    if hudApplyQueued then
        return
    end

    hudApplyQueued = true
    if zo_callLater then
        zo_callLater(ApplyHudLayout, HUD_APPLY_DELAY_MS)
    else
        ApplyHudLayout()
    end
end

local function InstallGamepadChatHudHook()
    if hudHookInstalled then
        return
    end

    if not GAMEPAD_CHAT_SYSTEM or type(GAMEPAD_CHAT_SYSTEM.Minimize) ~= "function" then
        hudHookAttempts = hudHookAttempts + 1
        if hudHookAttempts < 10 and zo_callLater then
            zo_callLater(InstallGamepadChatHudHook, 1000)
        end
        return
    end

    originalGamepadChatMinimize = GAMEPAD_CHAT_SYSTEM.Minimize
    GAMEPAD_CHAT_SYSTEM.Minimize = function(self, ...)
        if ShouldForceHudOpen() then
            if self.CloseTextEntry then
                local KEEP_TEXT_ENTERED = true
                self:CloseTextEntry(KEEP_TEXT_ENTERED)
            end

            if self.Maximize then
                self:Maximize()
            end

            QueueApplyHudLayout()
            return
        end

        return originalGamepadChatMinimize(self, ...)
    end

    if type(GAMEPAD_CHAT_SYSTEM.Maximize) == "function" then
        originalGamepadChatMaximize = GAMEPAD_CHAT_SYSTEM.Maximize
        GAMEPAD_CHAT_SYSTEM.Maximize = function(self, ...)
            local result = originalGamepadChatMaximize(self, ...)
            ApplyHudBackground()
            return result
        end
    end

    if type(GAMEPAD_CHAT_SYSTEM.HideWhenDeactivated) == "function" then
        originalGamepadChatHideWhenDeactivated = GAMEPAD_CHAT_SYSTEM.HideWhenDeactivated
        GAMEPAD_CHAT_SYSTEM.HideWhenDeactivated = function(self, ...)
            local result = originalGamepadChatHideWhenDeactivated(self, ...)
            ApplyHudBackground()
            return result
        end
    end

    if SecurePostHook and type(GAMEPAD_CHAT_SYSTEM.RefreshVisibility) == "function" then
        SecurePostHook(GAMEPAD_CHAT_SYSTEM, "RefreshVisibility", QueueApplyHudLayout)
    end

    hudHookInstalled = true
    hudHookAttempts = 0
    QueueApplyHudLayout()
end

local function RefreshHud()
    InstallGamepadChatHudHook()

    if ShouldPersistHudOpen() then
        EnableNativeHud()
    elseif GAMEPAD_CHAT_SYSTEM and GAMEPAD_CHAT_SYSTEM.RefreshVisibility then
        GAMEPAD_CHAT_SYSTEM:RefreshVisibility()
    end

    QueueApplyHudLayout()
end

local function GetSavedMessageLimit()
    return SAVED_MESSAGE_LIMITS[GetSettings().savedMessages] or 0
end

local function ClearMessageHistory()
    GetSettings().messageHistory = {}
end

local function TrimMessageHistory()
    local settings = GetSettings()
    local limit = GetSavedMessageLimit()

    if limit <= 0 then
        settings.messageHistory = {}
        return
    end

    while #settings.messageHistory > limit do
        table.remove(settings.messageHistory, 1)
    end
end

local function RecordMessage(message, metadata)
    local settings = GetSettings()
    local limit = GetSavedMessageLimit()

    if restoringHistory or limit <= 0 or type(message) ~= "string" or message == "" then
        return
    end

    local record = { message = message }
    if type(metadata) == "table" then
        record.category = metadata.category
        record.messageType = metadata.messageType
        record.targetChannel = metadata.targetChannel
        record.fromDisplayName = metadata.fromDisplayName
        record.rawMessageText = metadata.rawMessageText
        record.narrationMessage = metadata.narrationMessage
    end

    settings.messageHistory[#settings.messageHistory + 1] = record
    TrimMessageHistory()
end

local function GetTimeParts()
    if GetTimeStamp and os and os.date then
        local time = os.date("*t", GetTimeStamp())
        if time then
            return time.hour or 0, time.min or 0, time.sec or 0
        end
    end

    if os and os.date then
        local time = os.date("*t")
        if time then
            return time.hour or 0, time.min or 0, time.sec or 0
        end
    end

    if GetTimeString then
        local timeString = GetTimeString()
        local hour, minute, second = string.match(timeString or "", "^(%d%d?):(%d%d):?(%d*)")
        return tonumber(hour) or 0, tonumber(minute) or 0, tonumber(second) or 0
    end

    return 0, 0, 0
end

local function FormatTimestamp(format)
    local hour, minute, second = GetTimeParts()
    local timestamp = format or DEFAULT_TIMESTAMP_FORMAT

    timestamp = string.gsub(timestamp, "HH", string.format("%02d", hour))
    timestamp = string.gsub(timestamp, "H", tostring(hour))
    timestamp = string.gsub(timestamp, "mm", string.format("%02d", minute))
    timestamp = string.gsub(timestamp, "m", tostring(minute))
    timestamp = string.gsub(timestamp, "ss", string.format("%02d", second))
    timestamp = string.gsub(timestamp, "s", tostring(second))

    return timestamp
end

local function HasTimestamp(message)
    return type(message) == "string" and string.match(message, "^|c%x%x%x%x%x%x%[%d%d?:%d%d")
end

local function AddTimestamp(message)
    if restoringHistory or not ChatFeature.GetAddTimestamp() or message == nil or HasTimestamp(message) then
        return message
    end

    return string.format("|c999999[%s]|r %s", FormatTimestamp(ChatFeature.GetTimestampFormat()), tostring(message))
end

function ChatFeature.AddTimestamp(message)
    return AddTimestamp(message)
end

local StripChatMarkup = NQOL.Util.StripChatMarkup

local function NormalizeSenderName(name)
    local text = StripChatMarkup(name)

    if zo_strformat and SI_CHAT_MESSAGE_PLAYER_FORMATTER then
        text = zo_strformat(SI_CHAT_MESSAGE_PLAYER_FORMATTER, text)
    end

    return string.lower(text)
end

local function IsOwnChatMessage(fromName, fromDisplayName)
    local senderName = type(fromName) == "string" and fromName or ""
    local senderDisplayName = type(fromDisplayName) == "string" and fromDisplayName or ""

    if senderName == "" and senderDisplayName == "" then
        return false
    end

    local playerName = GetUnitName and GetUnitName("player") or ""
    local playerDisplayName = GetUnitDisplayName and GetUnitDisplayName("player") or ""
    local normalizedSenderName = NormalizeSenderName(senderName)
    local normalizedSenderDisplayName = NormalizeSenderName(senderDisplayName)

    if playerName ~= "" and normalizedSenderName == NormalizeSenderName(playerName) then
        return true
    end

    if playerDisplayName ~= "" then
        local normalizedPlayerDisplayName = NormalizeSenderName(playerDisplayName)
        return normalizedSenderName == normalizedPlayerDisplayName or normalizedSenderDisplayName == normalizedPlayerDisplayName
    end

    return false
end

function ChatFeature.IsOwnChatMessage(fromName, fromDisplayName)
    return IsOwnChatMessage(fromName, fromDisplayName)
end

local function IsOwnChatChannelMessage(messageType, fromName, fromDisplayName)
    return (CHAT_CHANNEL_WHISPER_SENT and messageType == CHAT_CHANNEL_WHISPER_SENT)
        or IsOwnChatMessage(fromName, fromDisplayName)
end

local function ShouldFilterMessage(message, rawText)
    if restoringHistory then
        return false
    end

    local settings = GetSettings()
    local messageText = type(message) == "string" and message or ""
    local rawMessageText = type(rawText) == "string" and rawText or ""

    if messageText == "" and rawMessageText == "" then
        return false
    end

    if settings.filterGuildAds and (string.find(messageText, "|H.-:guild:.-|h") or string.find(rawMessageText, "|H.-:guild:.-|h")) then
        return true
    end

    local text = StripChatMarkup(rawMessageText ~= "" and rawMessageText or messageText)

    if settings.filterPlusMessages and string.match(text, "^%s*%+") then
        return true
    end

    if settings.filterWttWts then
        local upperText = string.upper(text)
        if string.find(upperText, "WTT", 1, true) or string.find(upperText, "WTS", 1, true) or string.find(upperText, "WTB", 1, true) then
            return true
        end
    end

    return false
end

local function GetGuildMessageColor(messageType)
    local settings = GetSettings()
    if settings.guildMessageColors.enabled ~= true then
        return nil
    end

    local guildIndex = GetGuildIndexForMessageType(messageType)
    if not guildIndex then
        return nil
    end

    local guildId = GetGuildIdForIndex(guildIndex)
    if not guildId then
        return nil
    end

    if IsOfficerMessageType(messageType) then
        return GetOfficerColorTable(guildIndex)
    end

    return GetGuildColorTable(guildIndex)
end

local function ColorizeGuildMessage(messageType, message)
    if type(message) ~= "string" or message == "" then
        return message
    end

    local color = GetGuildMessageColor(messageType)
    if not color then
        return message
    end

    return GetColorTag(color) .. message .. "|r"
end

local function GetWhisperMessageColor(messageType)
    if not CHAT_CHANNEL_WHISPER or not CHAT_CHANNEL_WHISPER_SENT or (messageType ~= CHAT_CHANNEL_WHISPER and messageType ~= CHAT_CHANNEL_WHISPER_SENT) then
        return nil
    end

    return GetSettings().whisperColor
end

local function ColorizeWhisperMessage(messageType, message)
    if type(message) ~= "string" or message == "" then
        return message
    end

    local color = GetWhisperMessageColor(messageType)
    if not color then
        return message
    end

    return GetColorTag(color) .. message .. "|r"
end

local function ColorizeChatChannelMessage(messageType, message)
    return ColorizeWhisperMessage(messageType, ColorizeGuildMessage(messageType, message))
end

local function GetChatChannelOverrideColorDef(messageType)
    return GetColorDef(GetGuildMessageColor(messageType) or GetWhisperMessageColor(messageType))
end

local function FormatChatChannelMessage(messageType, message)
    local timestampedMessage = AddTimestamp(message)
    local timestampPrefix, messageText = string.match(timestampedMessage or "", "^(|c999999%[[^%]]+%]|r%s+)(.*)$")

    if timestampPrefix and messageText then
        return timestampPrefix .. ColorizeChatChannelMessage(messageType, messageText)
    end

    return ColorizeChatChannelMessage(messageType, timestampedMessage)
end

local function RefreshGuildColorOptions()
    if NQOL.GamepadOptions and NQOL.GamepadOptions.PanelIds and NQOL.GamepadOptions.PanelIds.CHAT_GUILD_COLORS and GAMEPAD_OPTIONS and GAMEPAD_OPTIONS.currentCategory == NQOL.GamepadOptions.PanelIds.CHAT_GUILD_COLORS then
        NQOL.GamepadOptions.RefreshCurrentOptionsList()
    end
end

local function CleanMissingGuildColors()
    local guildMessageColors = GetSettings().guildMessageColors
    local colorsByGuildId = guildMessageColors.colorsByGuildId
    local officerColorsByGuildId = guildMessageColors.officerColorsByGuildId
    local currentGuildIds = {}
    local numGuilds = GetNumGuilds and GetNumGuilds() or 0

    for guildIndex = 1, math.min(numGuilds, MAX_GUILD_CHAT_COLORS) do
        local guildId = GetGuildIdForIndex(guildIndex)
        if guildId then
            currentGuildIds[tostring(guildId)] = true
        end
    end

    for guildId in pairs(colorsByGuildId) do
        if not currentGuildIds[tostring(guildId)] then
            colorsByGuildId[guildId] = nil
        end
    end

    for guildId in pairs(officerColorsByGuildId) do
        if not currentGuildIds[tostring(guildId)] then
            officerColorsByGuildId[guildId] = nil
        end
    end
end

local function RegisterGuildColorEvents()
    if guildColorEventsRegistered or not EVENT_MANAGER then
        return
    end

    guildColorEventsRegistered = true
    if EVENT_GUILD_DATA_LOADED then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_GuildColorsDataLoaded", EVENT_GUILD_DATA_LOADED, RefreshGuildColorOptions)
    end
    if EVENT_GUILD_SELF_JOINED_GUILD then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_GuildColorsJoined", EVENT_GUILD_SELF_JOINED_GUILD, RefreshGuildColorOptions)
    end
    if EVENT_GUILD_SELF_LEFT_GUILD then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_GuildColorsLeft", EVENT_GUILD_SELF_LEFT_GUILD, RefreshGuildColorOptions)
    end
    if EVENT_GUILD_MEMBER_RANK_CHANGED then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_GuildColorsRankChanged", EVENT_GUILD_MEMBER_RANK_CHANGED, RefreshGuildColorOptions)
    end
    if EVENT_PLAYER_ACTIVATED then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_GuildColorsActivated", EVENT_PLAYER_ACTIVATED, RefreshGuildColorOptions)
    end
end

local function UnregisterGuildColorEvents()
    if not guildColorEventsRegistered or not EVENT_MANAGER then
        return
    end

    guildColorEventsRegistered = false
    if EVENT_GUILD_DATA_LOADED then
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_GuildColorsDataLoaded", EVENT_GUILD_DATA_LOADED)
    end
    if EVENT_GUILD_SELF_JOINED_GUILD then
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_GuildColorsJoined", EVENT_GUILD_SELF_JOINED_GUILD)
    end
    if EVENT_GUILD_SELF_LEFT_GUILD then
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_GuildColorsLeft", EVENT_GUILD_SELF_LEFT_GUILD)
    end
    if EVENT_GUILD_MEMBER_RANK_CHANGED then
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_GuildColorsRankChanged", EVENT_GUILD_MEMBER_RANK_CHANGED)
    end
    if EVENT_PLAYER_ACTIVATED then
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_GuildColorsActivated", EVENT_PLAYER_ACTIVATED)
    end
end

local function InstallRouterHook()
    if routerHookInstalled then
        return
    end

    if not CHAT_ROUTER or not CHAT_ROUTER.FormatAndAddChatMessage or not ZO_PreHook then
        return
    end

    ZO_PreHook(CHAT_ROUTER, "FormatAndAddChatMessage", function(_, eventKey, ...)
        if eventKey == EVENT_FRIEND_PLAYER_STATUS_CHANGED and GetSettings().filterFriendStatus then
            return true
        end

        if eventKey ~= EVENT_CHAT_MESSAGE_CHANNEL then
            return false
        end

        local messageType = select(1, ...)
        local fromName = select(2, ...)
        local rawText = select(3, ...)
        local fromDisplayName = select(5, ...)

        if NQOL.Features and NQOL.Features.Grouping and NQOL.Features.Grouping.HandleChatMessage then
            NQOL.Features.Grouping.HandleChatMessage(messageType, fromName, rawText, fromDisplayName)
        end

        if IsOwnChatChannelMessage(messageType, fromName, fromDisplayName) then
            return false
        end

        return ShouldFilterMessage(nil, rawText)
    end)

    routerHookInstalled = true
end

local function GetRestoredMessageColor()
    if ZO_ColorDef then
        return ZO_ColorDef:New(RESTORED_MESSAGE_RED, RESTORED_MESSAGE_GREEN, RESTORED_MESSAGE_BLUE)
    end

    return nil
end

local function StripChatColorMarkup(message)
    local text = tostring(message or "")
    text = string.gsub(text, "|c%x%x%x%x%x%x%x%x", "")
    text = string.gsub(text, "|c%x%x%x%x%x%x", "")
    return string.gsub(text, "|r", "")
end

local function GetRestoredRecord(historyEntry)
    if type(historyEntry) == "string" then
        return { message = historyEntry }
    end

    if type(historyEntry) == "table" and type(historyEntry.message) == "string" then
        return historyEntry
    end

    return nil
end

local function ExtractRestoredItemLinks(message)
    local itemLinks = {}
    for link in string.gmatch(message or "", CHAT_LINK_PATTERN) do
        if GetLinkType and GetLinkType(link) == LINK_TYPE_ITEM then
            itemLinks[#itemLinks + 1] = link
        end
    end

    return #itemLinks > 0 and table.concat(itemLinks, " ") or nil
end

local function ExtractRestoredDisplayName(message)
    if not GetLinkType or not DISPLAY_NAME_LINK_TYPE or not ZO_LinkHandler_ParseLinkData then
        return nil
    end

    for link in string.gmatch(message or "", CHAT_LINK_PATTERN) do
        if GetLinkType(link) == DISPLAY_NAME_LINK_TYPE then
            local displayName = ZO_LinkHandler_ParseLinkData(link)
            if displayName and displayName ~= "" and DecorateDisplayName then
                displayName = DecorateDisplayName(displayName)
            end
            return displayName
        end
    end

    return nil
end

local function IsOwnRestoredMessage(record)
    if CHAT_CHANNEL_WHISPER_SENT and record.messageType == CHAT_CHANNEL_WHISPER_SENT then
        return true
    end

    if CHAT_CATEGORY_WHISPER_OUTGOING and record.category == CHAT_CATEGORY_WHISPER_OUTGOING then
        return true
    end

    local fromDisplayName = record.fromDisplayName or ExtractRestoredDisplayName(record.message)
    return IsOwnChatMessage("", fromDisplayName)
end

local function GetRestoredDisplayMessage(record)
    local message = record.message
    if not IsOwnRestoredMessage(record) then
        message = AnnotateMissingItemLinks(message)
    end

    return StripChatColorMarkup(message)
end

local function AddRestoredMessageToContainer(container, record)
    if not container or not container.windows or not container.AddMessageToWindow then
        return
    end

    local category = record.category or CHAT_CATEGORY_SYSTEM or 0
    local text = GetRestoredDisplayMessage(record)

    for _, window in ipairs(container.windows) do
        container:AddMessageToWindow(window, text, RESTORED_MESSAGE_RED, RESTORED_MESSAGE_GREEN, RESTORED_MESSAGE_BLUE, category)
    end
end

local function AddRestoredMessageToGamepadMenu(record)
    if CHAT_MENU_GAMEPAD and CHAT_MENU_GAMEPAD.AddMessage then
        local rawMessageText = record.rawMessageText or ExtractRestoredItemLinks(record.message)
        local fromDisplayName = record.fromDisplayName or ExtractRestoredDisplayName(record.message)
        local narrationMessage = record.narrationMessage
        if narrationMessage and not IsOwnRestoredMessage(record) then
            narrationMessage = AnnotateMissingItemLinks(narrationMessage, true)
        end
        CHAT_MENU_GAMEPAD:AddMessage(
            GetRestoredDisplayMessage(record),
            record.category or CHAT_CATEGORY_SYSTEM or 0,
            record.targetChannel,
            fromDisplayName,
            rawMessageText,
            narrationMessage,
            GetRestoredMessageColor()
        )
    end
end

local function AddRestoredMessage(historyEntry)
    local record = GetRestoredRecord(historyEntry)
    if not record then
        return
    end

    if CHAT_SYSTEM and CHAT_SYSTEM.containers then
        for _, container in ipairs(CHAT_SYSTEM.containers) do
            AddRestoredMessageToContainer(container, record)
        end
    else
        originalAddMessage(CHAT_SYSTEM, GetRestoredDisplayMessage(record))
    end

    AddRestoredMessageToGamepadMenu(record)
end

local function RestoreMessageHistory()
    if historyRestored or restoringHistory or not CHAT_SYSTEM or not originalAddMessage then
        return
    end

    historyRestored = true

    local history = GetSettings().messageHistory
    if type(history) ~= "table" or #history == 0 then
        return
    end

    restoringHistory = true
    for _, historyEntry in ipairs(history) do
        AddRestoredMessage(historyEntry)
    end
    restoringHistory = false
end

local function InstallMessageHook()
    if messageHookInstalled then
        return
    end

    if not CHAT_SYSTEM or not CHAT_SYSTEM.AddMessage then
        return
    end

    originalAddMessage = CHAT_SYSTEM.AddMessage
    CHAT_SYSTEM.AddMessage = function(self, message, ...)
        if formattingChatChannelMessage then
            return originalAddMessage(self, message, ...)
        end

        if ShouldFilterMessage(message) then
            return
        end

        return originalAddMessage(self, AddTimestamp(message), ...)
    end

    messageHookInstalled = true
end

local function InstallChannelHook()
    if channelHookInstalled then
        return
    end

    if not CHAT_ROUTER or not CHAT_ROUTER.GetRegisteredMessageFormatters or not CHAT_ROUTER.RegisterMessageFormatter then
        return
    end

    local messageFormatters = CHAT_ROUTER:GetRegisteredMessageFormatters()
    if type(messageFormatters) ~= "table" then
        return
    end

    local function WrapFormatter(eventKey, formatter)
        if type(formatter) ~= "function" or wrappedRouterFormatters[formatter] then
            return formatter
        end

        local wrappedFormatter = function(...)
            formattingChatChannelMessage = true
            local results = { formatter(...) }
            formattingChatChannelMessage = false

            if results[1] == nil then
                return Unpack(results)
            end

            if eventKey == EVENT_CHAT_MESSAGE_CHANNEL then
                local fromName = select(2, ...)
                local rawText = select(3, ...)
                local fromDisplayName = select(5, ...)
                local messageType = select(1, ...)
                local isOwnMessage = IsOwnChatChannelMessage(messageType, fromName, fromDisplayName)

                if not isOwnMessage and ShouldFilterMessage(results[1], rawText) then
                    return
                end

                results[1] = FormatChatChannelMessage(messageType, results[1])
                results[6] = GetChatChannelOverrideColorDef(messageType) or results[6]
                RecordMessage(results[1], {
                    category = GetChannelCategoryFromChannel and GetChannelCategoryFromChannel(messageType) or nil,
                    messageType = messageType,
                    targetChannel = results[2],
                    fromDisplayName = results[3] or fromDisplayName,
                    rawMessageText = results[4] or rawText,
                    narrationMessage = results[5],
                })
                if not isOwnMessage then
                    results[1] = AnnotateMissingItemLinks(results[1])
                    results[5] = AnnotateMissingItemLinks(results[5], true)
                end
            else
                if ShouldFilterMessage(results[1]) then
                    return
                end

                results[1] = AddTimestamp(results[1])
            end

            return Unpack(results)
        end

        wrappedRouterFormatters[wrappedFormatter] = true
        return wrappedFormatter
    end

    for eventKey, formatter in pairs(messageFormatters) do
        messageFormatters[eventKey] = WrapFormatter(eventKey, formatter)
    end

    originalRegisterMessageFormatter = CHAT_ROUTER.RegisterMessageFormatter
    CHAT_ROUTER.RegisterMessageFormatter = function(self, eventKey, formatter, ...)
        return originalRegisterMessageFormatter(self, eventKey, WrapFormatter(eventKey, formatter), ...)
    end

    channelHookInstalled = true
end

local function InstallChatHooks()
    InstallRouterHook()
    InstallMessageHook()
    InstallChannelHook()

    if not routerHookInstalled or not messageHookInstalled or not channelHookInstalled then
        hookAttempts = hookAttempts + 1
        if hookAttempts < 10 and zo_callLater then
            zo_callLater(InstallChatHooks, 1000)
        end
        return
    end

    hookAttempts = 0
    if zo_callLater then
        zo_callLater(RestoreMessageHistory, 1000)
    else
        RestoreMessageHistory()
    end
end

function ChatFeature.InitializeSavedVariables()
    savedVariables = NQOL.Settings.NewAccountWide(defaults, "$InstallationWide")
    GetSettings()
end

function ChatFeature.Initialize()
    if initialized then
        return
    end

    initialized = true
    InstallChatHooks()
    RefreshHud()
end

function ChatFeature.GetAddTimestamp()
    if not savedVariables then
        return defaults.chat.addTimestamp
    end

    return GetSettings().addTimestamp
end

function ChatFeature.SetAddTimestamp(value)
    GetSettings().addTimestamp = value == true
end

function ChatFeature.GetSavedMessages()
    if not savedVariables then
        return defaults.chat.savedMessages
    end

    return GetSettings().savedMessages
end

function ChatFeature.SetSavedMessages(value)
    local settings = GetSettings()

    if SAVED_MESSAGE_LIMITS[value] == nil then
        value = defaults.chat.savedMessages
    end

    settings.savedMessages = value

    if GetSavedMessageLimit() <= 0 then
        ClearMessageHistory()
    else
        TrimMessageHistory()
    end
end

function ChatFeature.GetTimestampFormat()
    if not savedVariables then
        return defaults.chat.timestampFormat
    end

    return GetSettings().timestampFormat
end

function ChatFeature.SetSettingsPanelVisible(visible, panelId)
    chatSettingsPanelVisible = visible == true

    if NQOL.GamepadOptions and NQOL.GamepadOptions.PanelIds and panelId == NQOL.GamepadOptions.PanelIds.CHAT_GUILD_COLORS then
        CleanMissingGuildColors()
        RegisterGuildColorEvents()
    else
        UnregisterGuildColorEvents()
    end

    RefreshHud()
end

function ChatFeature.GetKeepHudOpen()
    return GetSettings().keepHudOpen
end

function ChatFeature.SetKeepHudOpen(value)
    GetSettings().keepHudOpen = value == true
    RefreshHud()
end

function ChatFeature.GetHudHorizontalPosition()
    return GetSettings().hudHorizontalPosition
end

function ChatFeature.SetHudHorizontalPosition(value)
    GetSettings().hudHorizontalPosition = Clamp(value, 0, 100)
    RefreshHud()
end

function ChatFeature.GetHudVerticalPosition()
    return GetSettings().hudVerticalPosition
end

function ChatFeature.SetHudVerticalPosition(value)
    GetSettings().hudVerticalPosition = Clamp(value, 0, 100)
    RefreshHud()
end

function ChatFeature.GetHudWidth()
    return GetSettings().hudWidth
end

function ChatFeature.SetHudWidth(value)
    GetSettings().hudWidth = Clamp(Round(value), HUD_WIDTH_MIN, HUD_WIDTH_MAX)
    RefreshHud()
end

function ChatFeature.GetHudHeight()
    return GetSettings().hudHeight
end

function ChatFeature.SetHudHeight(value)
    GetSettings().hudHeight = Clamp(Round(value), HUD_HEIGHT_MIN, HUD_HEIGHT_MAX)
    RefreshHud()
end

function ChatFeature.GetRemoveBackground()
    return GetSettings().removeBackground
end

function ChatFeature.SetRemoveBackground(value)
    GetSettings().removeBackground = value == true
    ApplyHudBackground()
end

function ChatFeature.GetFilterGuildAds()
    return GetSettings().filterGuildAds
end

function ChatFeature.SetFilterGuildAds(value)
    GetSettings().filterGuildAds = value == true
end

function ChatFeature.GetFilterPlusMessages()
    return GetSettings().filterPlusMessages
end

function ChatFeature.SetFilterPlusMessages(value)
    GetSettings().filterPlusMessages = value == true
end

function ChatFeature.GetFilterWttWts()
    return GetSettings().filterWttWts
end

function ChatFeature.SetFilterWttWts(value)
    GetSettings().filterWttWts = value == true
end

function ChatFeature.GetFilterFriendStatus()
    return GetSettings().filterFriendStatus
end

function ChatFeature.SetFilterFriendStatus(value)
    GetSettings().filterFriendStatus = value == true
end

function ChatFeature.GetAnnotateMissingItemsEnabled()
    return GetSettings().annotateMissingItems.enabled
end

function ChatFeature.SetAnnotateMissingItemsEnabled(value)
    GetSettings().annotateMissingItems.enabled = value == true
end

function ChatFeature.GetAnnotateMissingItemsEnabledDefault()
    return defaults.chat.annotateMissingItems.enabled
end

function ChatFeature.GetAnnotateMissingItemsWhisperMessage()
    return GetSettings().annotateMissingItems.whisperMessage
end

function ChatFeature.SetAnnotateMissingItemsWhisperMessage(value)
    if type(value) ~= "string" or value == "" then
        value = defaults.chat.annotateMissingItems.whisperMessage
    end

    GetSettings().annotateMissingItems.whisperMessage = value
end

function ChatFeature.GetAnnotateMissingItemsWhisperMessageDefault()
    return defaults.chat.annotateMissingItems.whisperMessage
end

function ChatFeature.IsMissingItemLink(itemLink)
    return IsMissingItemLink(itemLink)
end

function ChatFeature.GetWhisperColor()
    local color = GetSettings().whisperColor
    return color.r, color.g, color.b, color.a or 1
end

function ChatFeature.SetWhisperColor(red, green, blue, alpha)
    GetSettings().whisperColor = CopyColor({
        r = red,
        g = green,
        b = blue,
        a = alpha or 1,
    })
end

function ChatFeature.GetGuildColorsEnabled()
    return GetSettings().guildMessageColors.enabled
end

function ChatFeature.SetGuildColorsEnabled(value)
    GetSettings().guildMessageColors.enabled = value == true
end

function ChatFeature.GetGuildColor(guildIndex)
    local color = GetGuildColorTable(guildIndex)
    return color.r, color.g, color.b, color.a or 1
end

function ChatFeature.SetGuildColor(guildIndex, red, green, blue, alpha)
    local guildId = GetGuildIdForIndex(guildIndex)
    if not guildId then
        return
    end

    GetSettings().guildMessageColors.colorsByGuildId[tostring(guildId)] = CopyColor({
        r = red,
        g = green,
        b = blue,
        a = alpha or 1,
    })
end

function ChatFeature.GetOfficerColor(guildIndex)
    local color = GetOfficerColorTable(guildIndex)
    return color.r, color.g, color.b, color.a or 1
end

function ChatFeature.SetOfficerColor(guildIndex, red, green, blue, alpha)
    local guildId = GetGuildIdForIndex(guildIndex)
    if not guildId then
        return
    end

    GetSettings().guildMessageColors.officerColorsByGuildId[tostring(guildId)] = CopyColor({
        r = red,
        g = green,
        b = blue,
        a = alpha or 1,
    })
end

function ChatFeature.HasGuildColorSlot(guildIndex)
    return GetGuildIdForIndex(guildIndex) ~= nil
end

function ChatFeature.CleanMissingGuildColors()
    CleanMissingGuildColors()
end

function ChatFeature.GetHudWidthMin()
    return HUD_WIDTH_MIN
end

function ChatFeature.GetHudWidthMax()
    return HUD_WIDTH_MAX
end

function ChatFeature.GetHudHeightMin()
    return HUD_HEIGHT_MIN
end

function ChatFeature.GetHudHeightMax()
    return HUD_HEIGHT_MAX
end

function ChatFeature.GetAddTimestampLabel()
    return NQOL.L("features.chat.add_timestamp_label")
end

function ChatFeature.GetAddTimestampTooltip()
    return NQOL.L("features.chat.timestamp_tooltip", DEFAULT_TIMESTAMP_FORMAT)
end

function ChatFeature.GetSavedMessagesChoices()
    return SAVED_MESSAGE_CHOICES
end

function ChatFeature.GetSavedMessagesChoiceNames()
    return SAVED_MESSAGE_CHOICE_NAMES
end

function ChatFeature.GetSavedMessagesLabel()
    return NQOL.L("features.chat.saved_messages_label")
end

function ChatFeature.GetSavedMessagesTooltip()
    return NQOL.L("features.chat.saved_messages_tooltip")
end

function ChatFeature.GetKeepHudOpenLabel()
    return NQOL.L("features.chat.keep_hud_open_label")
end

function ChatFeature.GetKeepHudOpenTooltip()
    return NQOL.L("features.chat.keep_hud_open_tooltip")
end

function ChatFeature.GetHudHorizontalPositionLabel()
    return NQOL.L("features.chat.hud_horizontal_position_label")
end

function ChatFeature.GetHudHorizontalPositionTooltip()
    return NQOL.L("features.chat.hud_horizontal_position_tooltip")
end

function ChatFeature.GetHudVerticalPositionLabel()
    return NQOL.L("features.chat.hud_vertical_position_label")
end

function ChatFeature.GetHudVerticalPositionTooltip()
    return NQOL.L("features.chat.hud_vertical_position_tooltip")
end

function ChatFeature.GetHudWidthLabel()
    return NQOL.L("features.chat.hud_width_label")
end

function ChatFeature.GetHudWidthTooltip()
    return NQOL.L("features.chat.hud_width_tooltip")
end

function ChatFeature.GetHudHeightLabel()
    return NQOL.L("features.chat.hud_height_label")
end

function ChatFeature.GetHudHeightTooltip()
    return NQOL.L("features.chat.hud_height_tooltip")
end

function ChatFeature.GetRemoveBackgroundLabel()
    return NQOL.L("features.chat.remove_background_label")
end

function ChatFeature.GetRemoveBackgroundTooltip()
    return NQOL.L("features.chat.remove_background_tooltip")
end

function ChatFeature.GetFilterGuildAdsLabel()
    return NQOL.L("features.chat.filter_guild_ads_label")
end

function ChatFeature.GetFilterGuildAdsTooltip()
    return NQOL.L("features.chat.filter_guild_ads_tooltip")
end

function ChatFeature.GetFilterPlusMessagesLabel()
    return NQOL.L("features.chat.filter_plus_messages_label")
end

function ChatFeature.GetFilterPlusMessagesTooltip()
    return NQOL.L("features.chat.filter_plus_messages_tooltip")
end

function ChatFeature.GetFilterWttWtsLabel()
    return NQOL.L("features.chat.filter_wtt_wts_label")
end

function ChatFeature.GetFilterWttWtsTooltip()
    return NQOL.L("features.chat.filter_wtt_wts_tooltip")
end

function ChatFeature.GetFilterFriendStatusLabel()
    return NQOL.L("features.chat.filter_friend_status_label")
end

function ChatFeature.GetFilterFriendStatusTooltip()
    return NQOL.L("features.chat.filter_friend_status_tooltip")
end

function ChatFeature.GetAnnotateMissingItemsEnabledLabel()
    return NQOL.L("features.chat.annotate_missing_items_enabled_label")
end

function ChatFeature.GetAnnotateMissingItemsEnabledTooltip()
    return NQOL.L("features.chat.annotate_missing_items_enabled_tooltip")
end

function ChatFeature.GetAnnotateMissingItemsWhisperMessageLabel()
    return NQOL.L("features.chat.annotate_missing_items_whisper_message_label", ChatFeature.GetAnnotateMissingItemsWhisperMessage())
end

function ChatFeature.GetAnnotateMissingItemsWhisperMessageTooltip()
    return NQOL.L("features.chat.annotate_missing_items_whisper_message_tooltip")
end

function ChatFeature.GetWhisperColorLabel()
    return NQOL.L("features.chat.whisper_color_label")
end

function ChatFeature.GetWhisperColorTooltip()
    return NQOL.L("features.chat.whisper_color_tooltip")
end

function ChatFeature.GetGuildColorsEntryLabel()
    return NQOL.L("features.chat.guild_colors_entry_label")
end

function ChatFeature.GetGuildColorsEntryTooltip()
    return NQOL.L("features.chat.guild_colors_entry_tooltip")
end

function ChatFeature.GetGuildColorsEnabledLabel()
    return NQOL.L("features.chat.guild_colors_enabled_label")
end

function ChatFeature.GetGuildColorsEnabledTooltip()
    return NQOL.L("features.chat.guild_colors_enabled_tooltip")
end

function ChatFeature.GetGuildColorLabel(guildIndex)
    if GetGuildIdForIndex(guildIndex) then
        return GetGuildNameForIndex(guildIndex)
    end

    return NQOL.L("features.chat.guild_not_joined", tostring(guildIndex))
end

function ChatFeature.GetGuildColorTooltip()
    return NQOL.L("features.chat.guild_color_tooltip")
end

function ChatFeature.GetOfficerColorLabel(guildIndex)
    return ChatFeature.GetGuildColorLabel(guildIndex)
end

function ChatFeature.GetOfficerColorTooltip()
    return NQOL.L("features.chat.officer_color_tooltip")
end

NQOL.Features.Chat = ChatFeature
