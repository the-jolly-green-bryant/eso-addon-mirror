-- cChat.lua
-- Main addon logic and chat message formatting

-- Reference held by value — ZOS mutates the underlying table in place
-- (e.g. when guild channels activate), so a cached reference is fine.
local ChannelInfo = ZO_ChatSystem_GetChannelInfo()

local function CreateChannelLink(channelInfo)
    if channelInfo and channelInfo.channelLinkable then
        local channelName = GetChannelName(channelInfo.id)
        return ZO_LinkHandler_CreateChannelLink(channelName)
    end
    return nil
end

-- chathandlers.lua holds this as a module-local; re-implement verbatim.
local function GetCustomerServiceIcon(isCustomerServiceAccount)
    if isCustomerServiceAccount then
        return "|t16:16:EsoUI/Art/ChatWindow/csIcon.dds|t"
    end
    return ""
end

local function ResolveFormat(formatField)
    if type(formatField) == "function" then
        return formatField()
    end
    return GetString(formatField)
end

-- Mirrors ESO's built-in EVENT_CHAT_MESSAGE_CHANNEL formatter
-- (esoui/ingame/chatsystem/chathandlers.lua:43), then prepends our timestamp.
-- Must return: formattedText, saveTarget, fromDisplayName, text, narrationText.
-- fromDisplayName is REQUIRED for clickable @-name interactivity. Narration is
-- left as ESO produces it (nil unless channelInfo.narrationFormat exists) so
-- screen readers don't hear the timestamp on every message.
local function FormatChatMessage(messageType, fromName, text, isFromCustomerService, fromDisplayName)
    if not cChat.settings then return nil end

    local channelInfo = ChannelInfo[messageType]
    if not channelInfo or not channelInfo.format then
        return nil
    end

    local channelLink = CreateChannelLink(channelInfo)

    local userFacingName
    if not IsDecoratedDisplayName(fromName) and fromDisplayName and fromDisplayName ~= "" then
        -- ZO_ShouldPreferUserId() returns true if user prefers @AccountName over character name
        userFacingName = ZO_ShouldPreferUserId() and fromDisplayName or fromName
    else
        userFacingName = fromName
    end
    -- SI_CHAT_MESSAGE_PLAYER_FORMATTER strips gender markers (^Mx, ^Fx)
    userFacingName = zo_strformat(SI_CHAT_MESSAGE_PLAYER_FORMATTER, userFacingName)
    local fromLink = channelInfo.playerLinkable and ZO_LinkHandler_CreatePlayerLink(userFacingName) or userFacingName

    if channelInfo.formatMessage then
        text = zo_strformat(SI_CHAT_MESSAGE_FORMATTER, text)
    end

    local channelInfoFormat = ResolveFormat(channelInfo.format)
    local channelInfoNarrationFormat = channelInfo.narrationFormat and ResolveFormat(channelInfo.narrationFormat)

    local formattedText
    local formattedNarrationText
    if channelLink then
        formattedText = string.format(channelInfoFormat, channelLink, fromLink, text)
        if channelInfoNarrationFormat then
            formattedNarrationText = string.format(channelInfoNarrationFormat, channelLink, fromLink, text)
        end
    elseif channelInfo.supportCSIcon then
        local csIcon = GetCustomerServiceIcon(isFromCustomerService)
        formattedText = string.format(channelInfoFormat, csIcon, fromLink, text)
        if channelInfoNarrationFormat then
            formattedNarrationText = string.format(channelInfoNarrationFormat, csIcon, fromLink, text)
        end
    else
        formattedText = string.format(channelInfoFormat, fromLink, text)
        if channelInfoNarrationFormat then
            formattedNarrationText = string.format(channelInfoNarrationFormat, fromLink, text)
        end
    end

    if cChat.settings.showTimestamps then
        formattedText = cChat.Timestamps.CreateForDisplay(cChat.settings.use24HourFormat) .. formattedText
    end

    -- Store with category so color is preserved on restore, plus the metadata
    -- ZO_ChatMenu_Gamepad:AddMessage needs to make restored entries interactive
    -- (fromDisplayName → Whisper/Invite keybind; rawMessageText → link extraction
    -- for Travel-to / item tooltips; targetChannel → social-option context).
    if cChat.settings.enableHistory then
        local category = GetChannelCategoryFromChannel(messageType)
        cChat.History.StoreMessage(formattedText, category, channelInfo.saveTarget, fromDisplayName, text, formattedNarrationText)
    end

    return formattedText, channelInfo.saveTarget, fromDisplayName, text, formattedNarrationText
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= cChat.name then return end
    EVENT_MANAGER:UnregisterForEvent(cChat.name, EVENT_ADD_ON_LOADED)

    cChat.settings = ZO_SavedVars:NewAccountWide(
        cChat.savedvar,
        cChat.sv_version,
        nil,
        cChat.defaults
    )

    cChat.history = cChat.History.Initialize(
        ZO_SavedVars:NewAccountWide(
            cChat.history_savedvar,
            cChat.sv_version,
            nil,
            {}
        )
    )

    CHAT_ROUTER:RegisterMessageFormatter(EVENT_CHAT_MESSAGE_CHANNEL, FormatChatMessage)

    if LibAddonMenu2 then
        cChat.InitializeSettings()
    else
        d("[cChat] LibAddonMenu-2.0 not found - settings UI unavailable")
    end
end

local function OnPlayerActivated(_)
    EVENT_MANAGER:UnregisterForEvent(cChat.name, EVENT_PLAYER_ACTIVATED)
    -- 2s delay lets all chat containers finish initializing; on console
    -- the "initial" flag of EVENT_PLAYER_ACTIVATED isn't reliable.
    zo_callLater(function()
        cChat.History.Restore()
    end, 2000)
end

EVENT_MANAGER:RegisterForEvent(cChat.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent(cChat.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

SLASH_COMMANDS["/cchat"] = function(args)
    if args == "clear" then
        cChat.History.Clear()
        d("cChat: History cleared")
    elseif args == "count" then
        local count = cChat.History.GetCount()
        d("cChat: " .. count .. " messages in history")
    elseif args == "toggle" then
        cChat.settings.showTimestamps = not cChat.settings.showTimestamps
        d("cChat: Timestamps " .. (cChat.settings.showTimestamps and "enabled" or "disabled"))
    else
        d("cChat v" .. cChat.version)
        d("Commands:")
        d("  /cchat clear - Clear history")
        d("  /cchat count - Show message count")
        d("  /cchat toggle - Toggle timestamps")
    end
end
