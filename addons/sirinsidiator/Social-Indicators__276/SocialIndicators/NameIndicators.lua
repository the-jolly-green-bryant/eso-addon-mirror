local ICON_SIZE = "80%"
local FRIEND_ICON_TEXTURE = "esoui/art/tutorial/gamepad/gp_overview_friends.dds"
local IGNORED_ICON_TEXTURE = "SocialIndicators/images/target_ignored.dds"
local GROUP_LEADER_ICON_TEXTURE = "esoui/art/icons/mapkey/mapkey_groupleader.dds"
local GROUP_MEMBER_ICON_TEXTURE = "esoui/art/icons/mapkey/mapkey_groupmember.dds"
local GUILD_ICON_TEXTURE = "SocialIndicators/images/guild.dds"
local BLANK_TEXTURE = "SocialIndicators/images/blank.dds"
local BLANK_ICON = zo_iconFormat(BLANK_TEXTURE, "-" .. ICON_SIZE, ICON_SIZE)
local LINK_INDICATORS_DISABLED = -1
local LINK_INDICATORS_AUTO = 0
local DETAIL_LINK_TYPE = "sidPlayerDetails"

local IsSelf = SocialIndicators.IsSelf
local SafeIsFriend = SocialIndicators.SafeIsFriend
local GetPreferredGuildMemberIndexFromCharacterOrDisplayName = SocialIndicators.GetPreferredGuildMemberIndexFromCharacterOrDisplayName
local TogglePlayerDetailTooltip = SocialIndicators.TogglePlayerDetailTooltip

local initialized = false
local settings = nil
local currentChannel = LINK_INDICATORS_AUTO
local db

local function GetIconFormat(texture, color)
    local icon = zo_iconFormatInheritColor(texture, ICON_SIZE, ICON_SIZE)
    return ("|c%s%s|r"):format(color:ToHex(), icon)
end

local function GetMultiLayerIconFormat(bgtexture, bgcolor, fgtexture, fgcolor)
    local bgicon = bgtexture and GetIconFormat(bgtexture, bgcolor)
    local fgicon = fgtexture and GetIconFormat(fgtexture, fgcolor)
    if(bgicon and fgicon) then
        return ("%s%s%s"):format(bgicon, BLANK_ICON, fgicon)
    elseif(bgtexture) then
        return GetIconFormat(bgtexture, bgcolor)
    elseif(fgtexture) then
        return GetIconFormat(fgtexture, fgcolor)
    end
    return ""
end

local channelToGuildIndex = {}
for i = CHAT_CHANNEL_GUILD_1, CHAT_CHANNEL_OFFICER_5 do
    channelToGuildIndex[i] = ((i - CHAT_CHANNEL_GUILD_1) % 5) + 1
end

local function GetGuildIdFromChatChannel(channel)
    if(channel >= CHAT_CHANNEL_GUILD_1 and channel <= CHAT_CHANNEL_OFFICER_5) then
        return GetGuildId(channelToGuildIndex[channel])
    end
    return nil
end

local colorCache = {}

local function GetColorFromChannel(channel)
    if(not colorCache[channel]) then
        colorCache[channel] = ZO_ColorDef:New(CHAT_SYSTEM:GetCategoryColorFromChannel(channel))
    end
    return colorCache[channel]
end

local function GetColorFromHex(color)
    if(not colorCache[color]) then
        colorCache[color] = ZO_ColorDef:New(color)
    end
    return colorCache[color]
end

local function GetGuildColor(guildId)
    local index = 1
    for i = 1, GetNumGuilds() do
        if(GetGuildId(i) == guildId) then index = i break end
    end
    local channel = index - 1 + CHAT_CHANNEL_GUILD_1
    if(pChat_GetChannelColors) then
        local senderColor, messageColor = pChat_GetChannelColors(channel)
        if(messageColor and messageColor ~= "") then
            return GetColorFromHex(messageColor:sub(3, 8))
        end
    end
    return GetColorFromChannel(channel)
end

local function GetGuildRankIcon(player, guildId)
    local rank = player.guildRank[guildId]
    if(rank) then
        return GetFinalGuildRankTextureSmall(guildId, rank)
    end
    return nil
end

local function GetNameIndicators(name, channel)
    local player, character = db:GetPlayerAndCharacterFromCharacterOrDisplayName(name)
    if(not player or not character) then return "", "" end
    local i1fg, i1bg, i2fg, i2bg
    local allianceColor = character:GetAllianceColor()
    local guildColor

    if(settings.showFriendIndicator and player:IsFriend()) then
        i1bg = FRIEND_ICON_TEXTURE
    elseif(settings.showIgnoreIndicator and player:IsIgnored()) then
        i1bg = IGNORED_ICON_TEXTURE
    end

    if(settings.showGroupIndicators and character:IsGrouped()) then
        local isGroupChannel = (channel == CHAT_CHANNEL_PARTY)
        local isGroupLeader = character:IsGroupLeader()
        if(isGroupChannel) then
            if(isGroupLeader and settings.showGroupLeaderInGroupChat) then
                i1fg = GROUP_LEADER_ICON_TEXTURE
            end
        else
            i1fg = isGroupLeader and GROUP_LEADER_ICON_TEXTURE or GROUP_MEMBER_ICON_TEXTURE
        end
    end

    if(settings.showGuildIndicators and player:IsGuildMate()) then
        local guildId = GetGuildIdFromChatChannel(channel)
        local isGuildChannel = (guildId ~= nil)
        if(isGuildChannel and settings.showGuildRankInGuildChannels) then
            i2fg = GetGuildRankIcon(player, guildId)
        elseif(not isGuildChannel and settings.showGuildIndicatorsOutsideGuildChannels) then
            guildId = GetPreferredGuildMemberIndexFromCharacterOrDisplayName(name)
            if(guildId) then
                i2bg = GUILD_ICON_TEXTURE
                guildColor = GetGuildColor(guildId)
                if(settings.showGuildRankOutsideGuildChannels) then
                    i2fg = GetGuildRankIcon(player, guildId)
                end
            end
        end
    end

    local indicator1 = GetMultiLayerIconFormat(i1bg, allianceColor, i1fg, allianceColor) -- friend/ignore/group
    local indicator2 = GetMultiLayerIconFormat(i2bg, guildColor, i2fg, allianceColor) -- guild/guildrank
    return indicator1, indicator2
end

local function HandleDetailLink(link, button, control, color, linkType, displayName)
    if(linkType == DETAIL_LINK_TYPE) then
        if(button == MOUSE_BUTTON_INDEX_LEFT) then
            TogglePlayerDetailTooltip(displayName)
        end
        return true
    end
end

local function InitializePlayerStatusMessageWorkaround()
    local loggonMessage = GetString(SI_FRIENDS_LIST_FRIEND_CHARACTER_LOGGED_ON):gsub("<<2>>", "<<2>><<3>>") -- workaround for a bug in zo_strformat where the icons for the character links would break when passed together with the link
    local loggoffMessage = GetString(SI_FRIENDS_LIST_FRIEND_CHARACTER_LOGGED_OFF):gsub("<<2>>", "<<2>><<3>>")
    local handlers = ZO_ChatSystem_GetEventHandlers()

    SocialIndicators.WrapFunction(handlers, EVENT_FRIEND_PLAYER_STATUS_CHANGED, function(originalHandler, displayName, characterName, oldStatus, newStatus)
        -- we temporarily disable indicators to avoid making them for every link and create them only once if we need them
        local oldChannel = currentChannel
        currentChannel = LINK_INDICATORS_DISABLED

        local formattedEventText, targetChannel, fromDisplayName, rawMessageText = originalHandler(displayName, characterName, oldStatus, newStatus)
        if(formattedEventText and settings.showIndicatorsOnAllLinks) then
            local indicator1, indicator2 = GetNameIndicators(displayName, LINK_INDICATORS_AUTO)
            local function ReplaceLink(link)
                return string.format("%s%s%s", indicator1, indicator2, link)
            end
            formattedEventText = formattedEventText:gsub("(|H1:display:.-|h.-|h)", ReplaceLink)
            formattedEventText = formattedEventText:gsub("(|H1:character:.-|h.-|h)", ReplaceLink)
        end

        currentChannel = oldChannel
        return formattedEventText, targetChannel, fromDisplayName, rawMessageText
    end)
end

local function GetNextPChatColor(channel)
    if(pChat_GetChannelColors) then
        local senderColor, messageColor = pChat_GetChannelColors(currentChannel)
        if(senderColor and senderColor ~= "") then
            return senderColor
        elseif(messageColor and messageColor ~= "") then
            return messageColor
        end
    end
end

local function InitNameIndicators()
    if(initialized) then return end
    db = SocialIndicators.db
    settings = SocialIndicators_Settings.nameIndicators

    local function SetCurrentChatChannel(messageType)
        if(settings.showIndicatorsInChat) then
            currentChannel = messageType
        else
            currentChannel = LINK_INDICATORS_DISABLED
        end
    end
    local function UnsetCurrentChatChannel()
        currentChannel = settings.showIndicatorsOnAllLinks and LINK_INDICATORS_AUTO or LINK_INDICATORS_DISABLED
    end

    local onChatEvent = CHAT_SYSTEM.OnChatEvent
    CHAT_SYSTEM.OnChatEvent = function(self, event, ...)
        if(event == EVENT_CHAT_MESSAGE_CHANNEL) then
            SetCurrentChatChannel(...)
            onChatEvent(self, event, ...)
            UnsetCurrentChatChannel()
        else
            onChatEvent(self, event, ...)
        end
    end

    local originalCreateLink = ZO_LinkHandler_CreateLink
    ZO_LinkHandler_CreateLink = function(text, color, linkType, rawName, ...)
        local link = originalCreateLink(text, color, linkType, rawName, ...)
        if((linkType == DISPLAY_NAME_LINK_TYPE or linkType == CHARACTER_LINK_TYPE) and currentChannel > LINK_INDICATORS_DISABLED) then
            if(linkType == DISPLAY_NAME_LINK_TYPE and not IsDecoratedDisplayName(rawName)) then
                rawName = DecorateDisplayName(rawName) -- we only differentiate between display name and character name via the @ symbol in the beginning
            end
            local indicator1, indicator2 = GetNameIndicators(rawName, currentChannel)
            local nextColor = GetNextPChatColor(currentChannel)
            if(nextColor) then
                link = string.format("%s%s", nextColor, link)
            end
            link = indicator1 .. indicator2 .. link
        end
        return link
    end

    InitializePlayerStatusMessageWorkaround()

    LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT, HandleDetailLink)
    LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, HandleDetailLink)

    CALLBACK_MANAGER:RegisterCallback("SocialIndicators_SHOW_INDICATORS_ON_ALL_LINKS_Changed", UnsetCurrentChatChannel)

    initialized = true
end

SocialIndicators.InitNameIndicators = InitNameIndicators
