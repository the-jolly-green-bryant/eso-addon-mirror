SetCollectionMarker = SetCollectionMarker or {}
local SCM = SetCollectionMarker
SCM.Chat = SCM.Chat or {}

local REQUEST_LINK_TYPE = "SCMreq"
local requestLinks = {}

---------------------------------------------------------------------
-- Should be called from settings whenever the style is updated
---------------------------------------------------------------------
function SCM.Chat.UpdateIconString()
    SCM.Chat.iconString = string.format("|c%02x%02x%02x|t%d:%d:%s:inheritcolor|t|r",
        SCM.savedOptions.chatIconColor[1] * 255,
        SCM.savedOptions.chatIconColor[2] * 255,
        SCM.savedOptions.chatIconColor[3] * 255,
        SCM.savedOptions.chatIconSize,
        SCM.savedOptions.chatIconSize,
        SCM.iconTexture)
end

---------------------------------------------------------------------
-- Add the icon(s) to the message
-- Returns:
--     - formatted text
--     - index for requestLinks
---------------------------------------------------------------------
local function ParseItemLinks(message, location, fromDisplayName, messageType)
    if (not message) then
        return nil, nil
    end

    -- Use a table to make sure the links are unique, for gsub later
    local itemsString = ""
    local withIcons = {}
    local count = 0

    -- Non-greedy matches. normally it would just be numbers... but Group Loot Notifier inserts :by:<name> at the end for some reason...
    for itemLink in string.gmatch(message, "(|H%d:item:.-|h|h)") do
        if (SCM.ShouldShowIcon(itemLink)) then
            -- things to be subbed for
            if (location == SCM.LOCATION_BEFORE) then
                withIcons[itemLink] = SCM.Chat.iconString .. itemLink
            elseif (location == SCM.LOCATION_AFTER) then
                withIcons[itemLink] = itemLink .. SCM.Chat.iconString
            end
            itemsString = itemsString .. itemLink
            count = count + 1
        end
    end

    -- No item links
    if (count == 0) then
        return message, nil
    end

    local requestKey
    if (fromDisplayName and fromDisplayName ~= GetUnitDisplayName("player") and messageType ~= CHAT_CHANNEL_WHISPER_SENT) then
    -- |H1:item:74181:364:50:0:0:0:0:0:0:0:0:0:0:0:0:41:0:0:0:0:0|h|h
        requestKey = #requestLinks + 1
        requestLinks[requestKey] = {name = fromDisplayName, items = itemsString, channel = messageType}
    end

    -- For the single-icon options, just put it in the Location
    if (location == SCM.LOCATION_BEGINNING) then
        return SCM.Chat.iconString .. message, requestKey
    elseif (location == SCM.LOCATION_END) then
        return message .. SCM.Chat.iconString, requestKey
    end

    -- For each-icon option, substitute in the strings
    for link, withIcon in pairs(withIcons) do
        message = string.gsub(message, link, withIcon)
    end
    return message, requestKey
end

---------------------------------------------------------------------
-- Request link click handling
---------------------------------------------------------------------
local function OnLinkClicked(_, _, _, _, linkType, requestKey)
    if (linkType == REQUEST_LINK_TYPE) then
        local requestData = requestLinks[tonumber(requestKey)]
        if (SCM.savedOptions.requestInWhisper or requestData.channel == CHAT_CHANNEL_WHISPER) then
            StartChatInput(SCM.savedOptions.requestPrefix .. requestData.items, CHAT_CHANNEL_WHISPER, requestData.name)
        else
            -- Use the same channel as the original chat message if setting is off
            StartChatInput(SCM.savedOptions.requestPrefix .. requestData.items, requestData.channel)
        end
        return true
    end
end

---------------------------------------------------------------------
-- After player is activated, do some chat things
---------------------------------------------------------------------
local function SetupChatHooks()
    if (SCM.logger) then SCM.logger:Debug("Adding chat hooks") end
    -----------------------------
    -- Set up system message hook
    local function AddIconToSystem(origMessage)
        if (not SCM.savedOptions.chatSystemShow) then
            return origMessage
        end
        return ParseItemLinks(origMessage, SCM.savedOptions.chatSystemLocation)
    end
    local previousFormatter = CHAT_ROUTER:GetRegisteredMessageFormatters()["AddSystemMessage"]
    if (previousFormatter) then
        CHAT_ROUTER:RegisterMessageFormatter("AddSystemMessage", function(...)
            return AddIconToSystem(previousFormatter(...))
        end)
    else
        CHAT_ROUTER:RegisterMessageFormatter("AddSystemMessage", AddIconToSystem)
    end

    --------------------------
    -- Set up normal chat hook
    local function AddIconToMessage(messageType, fromName, text, isFromCustomerService, fromDisplayName)
        local formattedText = text
        local requestKey
        if (SCM.savedOptions.chatMessageShow) then
            formattedText, requestKey = ParseItemLinks(text, SCM.savedOptions.chatMessageLocation, fromDisplayName, messageType)
        end
        if (requestKey and SCM.savedOptions.showRequestLink) then
            -- Add a [Req] button if there are items we need
            formattedText = string.format("|c%02x%02x%02x|H0:%s:%d|h[Req]|h|r%s",
                SCM.savedOptions.chatIconColor[1] * 255,
                SCM.savedOptions.chatIconColor[2] * 255,
                SCM.savedOptions.chatIconColor[3] * 255,
                REQUEST_LINK_TYPE,
                requestKey,
                formattedText)
        end

        local channelInfo = ZO_ChatSystem_GetChannelInfo()[messageType]
        if (not channelInfo or not channelInfo.format) then
            return
        end

        return formattedText, channelInfo.saveTarget
    end
    local oldFormatter = CHAT_ROUTER:GetRegisteredMessageFormatters()[EVENT_CHAT_MESSAGE_CHANNEL]
    if (oldFormatter) then
        CHAT_ROUTER:RegisterMessageFormatter(EVENT_CHAT_MESSAGE_CHANNEL, function(messageType, fromName, text, isFromCustomerService, fromDisplayName)
            local oldText = oldFormatter(messageType, fromName, text, isFromCustomerService, fromDisplayName)
            return AddIconToMessage(messageType, fromName, oldText, isFromCustomerService, fromDisplayName)
        end)
    else
        CHAT_ROUTER:RegisterMessageFormatter(EVENT_CHAT_MESSAGE_CHANNEL, AddIconToMessage)
    end

    LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, OnLinkClicked)

    -- No longer need this
    EVENT_MANAGER:UnregisterForEvent(SCM.name .. "Activated", EVENT_PLAYER_ACTIVATED)
end

function SCM.Chat.OnPlayerActivated()
    if (pChat or rChat) then
        -- Delay initialization by half a second to allow pChat to do pChat.InitializeChatHandlers
        -- Unfortunately pChat doesn't seem to fire any event or set a public variable that I can
        -- check, so 500ms is just a hacky shot in the dark. Same hack for rChat.
        EVENT_MANAGER:RegisterForUpdate(SCM.name .. "DelayedActivated", 500,
            function()
                EVENT_MANAGER:UnregisterForUpdate(SCM.name .. "DelayedActivated")
                SetupChatHooks()
            end)
    else
        SetupChatHooks()
    end
end
