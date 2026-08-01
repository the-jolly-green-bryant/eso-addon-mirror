-- ChatAlert.lua
-- Copyright (C) 2021 c0r73x <c0r73x@gmail.com>
--
-- Distributed under terms of the MIT license.
--

ChatAlert = {}
ChatAlert.name = "ChatAlert"
ChatAlert.short_name = "CA"

local AllChannels = {
    [CHAT_CHANNEL_GUILD_1        ] = true,
    [CHAT_CHANNEL_GUILD_2        ] = true,
    [CHAT_CHANNEL_GUILD_3        ] = true,
    [CHAT_CHANNEL_GUILD_4        ] = true,
    [CHAT_CHANNEL_GUILD_5        ] = true,
    [CHAT_CHANNEL_OFFICER_1      ] = true,
    [CHAT_CHANNEL_OFFICER_2      ] = true,
    [CHAT_CHANNEL_OFFICER_3      ] = true,
    [CHAT_CHANNEL_OFFICER_4      ] = true,
    [CHAT_CHANNEL_OFFICER_5      ] = true,
    [CHAT_CHANNEL_PARTY          ] = true,
    [CHAT_CHANNEL_SAY            ] = true,
    [CHAT_CHANNEL_YELL           ] = true,
    [CHAT_CHANNEL_ZONE           ] = true,
    [CHAT_CHANNEL_ZONE_LANGUAGE_1] = true,
    [CHAT_CHANNEL_ZONE_LANGUAGE_2] = true,
    [CHAT_CHANNEL_ZONE_LANGUAGE_3] = true,
    [CHAT_CHANNEL_ZONE_LANGUAGE_4] = true,
}

local GuildOfficerChannels = {
    [CHAT_CHANNEL_GUILD_1  ] = true,
    [CHAT_CHANNEL_GUILD_2  ] = true,
    [CHAT_CHANNEL_GUILD_3  ] = true,
    [CHAT_CHANNEL_GUILD_4  ] = true,
    [CHAT_CHANNEL_GUILD_5  ] = true,
    [CHAT_CHANNEL_OFFICER_1] = true,
    [CHAT_CHANNEL_OFFICER_2] = true,
    [CHAT_CHANNEL_OFFICER_3] = true,
    [CHAT_CHANNEL_OFFICER_4] = true,
    [CHAT_CHANNEL_OFFICER_5] = true,
}

local GuildChannels = {
    [CHAT_CHANNEL_GUILD_1] = true,
    [CHAT_CHANNEL_GUILD_2] = true,
    [CHAT_CHANNEL_GUILD_3] = true,
    [CHAT_CHANNEL_GUILD_4] = true,
    [CHAT_CHANNEL_GUILD_5] = true,
}

local function isWordFoundInString(word, str, start)
    local w = word:gsub("([^%w])", "%%%1"):lower()
    local s = str:lower()

    local a, b = s:find('^' .. w .. '%W+') if a then return a, b end
    a, b = s:find('%W+' .. w .. '%W+') if a then return a, b end
    a, b = s:find('%W+' .. w .. '$') if a then return a, b end
    a, b = s:find('^' .. w .. '$') if a then return a, b end

    return nil
end

local function strsplit(s, delimiter)
    local result = {}

    for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end

    return result
end

local function insert(str1, str2, pos)
    return str1:sub(1,pos)..str2..str1:sub(pos+1)
end

function join(delimiter, list)
  local len = #list
  if len == 0 then return "" end

  local str = list[1]
  for i = 2, len do
    str = str .. delimiter .. list[i]
  end
  return str
end

function contains(list, x)
    if string.len(x) == 0 then
        return true
    end

    for _, v in pairs(list) do
        if string.len(v) > 0 then
            if v == x then return true end
        end
    end
    return false
end

local function CreateChannelLink(channelInfo, overrideName)
    local channelName = overrideName or ChatAlert.GetChannelName(channelInfo.id)
    return ("|H1:channel:%s|h[%s]:|h"):format(
        channelInfo.id,
        channelName
    )
end

function ChatAlert:Initialize()
    self.ChannelInfo = ZO_ChatSystem_GetChannelInfo()
    self.currentPlayer = GetDisplayName()

    self.saveData = self.LoadSettings()

    EVENT_MANAGER:RegisterForEvent(
        self.name,
        EVENT_CHAT_MESSAGE_CHANNEL,
        self.OnNewChatMessage
    )
end

function ChatAlert.GetChannelName(channelId)
    local channelInfo = ChatAlert.ChannelInfo[channelId]
    if channelInfo then
        local dynName = nil

        if channelInfo.dynamicName then
            dynName = GetDynamicChatChannelName(channelInfo.id)
            if dynName then return dynName end
        end

        if channelInfo.name then return channelInfo.name end
    end

    return "Unknown"
end

function ChatAlert.OnNewChatMessage(
    event,
    channelType,
    fromName,
    text,
    isCustomerService,
    fromDisplayName)

    if not AllChannels[channelType] then
        return
    end

    if fromDisplayName == ChatAlert.currentPlayer then
        -- d("Why are you talking to yourself " .. fromDisplayName .. "?")
        return
    end

    local found = false

    for _, alert in ipairs(ChatAlert.saveData.alerts) do
        local continue = true

        if string.len(alert.whitelist) > 0 then
            local wl = strsplit(alert.whitelist, "\n")
            continue = contains(wl, fromDisplayName)
        end

        if string.len(alert.blacklist) > 0 then
            local bl = strsplit(alert.blacklist, "\n")
            continue = contains(bl, fromDisplayName) == false
        end

        if continue then
            if alert.channels ~= 999 then
                if alert.channels == 998 then
                    if not GuildOfficerChannels[channelType] then return end
                elseif alert.channels == 997 and not GuildChannels[channelType] then
                    if not GuildChannels[channelType] then return end
                elseif alert.channels ~= channelType then
                    return
                end
            end

            if alert.type == 'Word' then
                local words = strsplit(alert.filter, " ")
                for _, word in pairs(words) do
                    if word then
                        found = isWordFoundInString(word, text, 1)
                    end

                    if found then
                        text = insert(text, "|rx", found + string.len(word))
                        text = insert(text, ("|c%s"):format(alert.color), found)
                        break
                    end
                end
            end
        end

        if found then break end
    end

    if not found then return end

    local channelInfo = ChatAlert.ChannelInfo[channelType]
    if channelInfo and channelInfo.format and channelInfo.channelLinkable then
        local r, g, b = ZO_ChatSystem_GetCategoryColorFromChannel(channelType)
        local color = ("|c%02x%02x%02x"):format(
            r * 255, g * 255, b * 255
        )

        local msg = ("%s%s %s|r"):format(
            color,
            CreateChannelLink(channelInfo),
            text:gsub('|rx', color)
        )

        CHAT_ROUTER:FormatAndAddChatMessage(
            EVENT_CHAT_MESSAGE_CHANNEL,
            CHAT_CHANNEL_WHISPER,
            fromName,
            msg,
            false,
            fromDisplayName
        )
    end
end

function ChatAlert.OnAddOnLoaded(event, addonName)
    if addonName == ChatAlert.name then
        ChatAlert:Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent(
    ChatAlert.name,
    EVENT_ADD_ON_LOADED,
    ChatAlert.OnAddOnLoaded
)
