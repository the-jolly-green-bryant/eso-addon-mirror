-- OwoSpeak for ESO
-- Pwease owo wesponsibwy

local owos =
{
    "OwO",
    "owo",
    "UwU",
    "uwu",
    "^w^",
    ">w<",
    "(´•w•`)",
}

local defaults =
{
    enabled = true,
    say = true,
    yell = true,
    zone = true,
    party = true,
    guild = true,
    officer = true,
    whisper = true,
    emote = true,
}

local blockedChannelsDefaults = {}

local db
local blockedChannels
local hyperlinks = {}

-- Helper: Check if channelId is a zone channel (including language-specific ones)
---
--- @param channelId ChannelType
local function IsZoneChannel(channelId)
    return channelId == CHAT_CHANNEL_ZONE or (channelId >= CHAT_CHANNEL_ZONE_LANGUAGE_1 and channelId <= CHAT_CHANNEL_ZONE_LANGUAGE_7)
end

-- Helper: Check if channelId is a guild channel
---
--- @param channelId ChannelType
local function IsGuildChannel(channelId)
    return channelId >= CHAT_CHANNEL_GUILD_1 and channelId <= CHAT_CHANNEL_GUILD_5
end

-- Helper: Check if channelId is an officer channel
---
--- @param channelId ChannelType
local function IsOfficerChannel(channelId)
    return channelId >= CHAT_CHANNEL_OFFICER_1 and channelId <= CHAT_CHANNEL_OFFICER_5
end

-- Helper: Get channel name for blocked-channel comparison
---
--- @param channelId ChannelType
--- @return string|nil
local function GetChannelDisplayName(channelId)
    local channelInfo = ZO_ChatSystem_GetChannelInfo()
    if channelInfo and channelInfo[channelId] then
        local info = channelInfo[channelId]
        if info.dynamicName then
            return GetDynamicChatChannelName(channelId) or info.name
        else
            return info.name
        end
    end
    return nil
end

-- owo1, owo2, etc pwacehowdews
---
--- @param s string
--- @return string
local function ReplaceLink(s)
    table.insert(hyperlinks, s)
    return "owo" .. #hyperlinks
end

---
--- @param s string
local function RestoreLink(s)
    local n = tonumber(s:match("%d+"))
    return hyperlinks[n]
end

---
--- @param channelId ChannelType
--- @return boolean
local function ShouldOwo(channelId)
    if db.enabled then
        if channelId == CHAT_CHANNEL_SAY then
            return db.say
        elseif channelId == CHAT_CHANNEL_YELL then
            return db.yell
        elseif IsZoneChannel(channelId) then
            return db.zone
        elseif channelId == CHAT_CHANNEL_PARTY then
            return db.party
        elseif IsGuildChannel(channelId) then
            return db.guild
        elseif IsOfficerChannel(channelId) then
            return db.officer
        elseif channelId == CHAT_CHANNEL_WHISPER or channelId == CHAT_CHANNEL_WHISPER_SENT then
            return db.whisper
        elseif channelId == CHAT_CHANNEL_EMOTE then
            return db.emote
        else
            return true
        end
    end
    return false
end

---
--- @param channelId ChannelType
--- @return boolean
local function ShouldOwoTwo(channelId)
    local channelName = GetChannelDisplayName(channelId)
    if channelName then
        for key, value in pairs(blockedChannels) do
            if channelName == value then
                return false
            end
        end
    end
    return true
end

---
--- @param message string
local function TransformOwo(message)
    ZO_ClearNumericallyIndexedTable(hyperlinks)
    local owoEmote = owos[zo_random(#owos)]
    local whatsthis = zo_random(10)
    -- tempowawiwy wepwace winks wif owos (preserve ESO links AND color codes)
    -- ESO link format: |H[style]:[type]:[data]|h[text]|h (pattern from ZO_LinkHandler.lua)
    local s = message:gsub("|H.-|h.-|h", ReplaceLink) -- Preserve ESO links first
    s = s:gsub("|c.-|r", ReplaceLink)                 -- Then preserve standalone color codes

    -- Transform l/L -> w/W and r/R -> w/W, but preserve "rs" combinations
    -- First, protect "rs"/"Rs"/"RS" by temporarily replacing them
    s = s:gsub("([rR])([sS])", "OWORS%1%2OWORS")
    -- Transform all l -> w and L -> W
    s = s:gsub("l", "w")
    s = s:gsub("L", "W")
    -- Transform all r -> w and R -> W (the protected rs/Rs/RS won't match)
    s = s:gsub("r", "w")
    s = s:gsub("R", "W")
    -- Restore protected "rs"/"Rs"/"RS" combinations
    s = s:gsub("OWOWSw([sS])OWOWS", "r%1")
    s = s:gsub("OWOWSW([sS])OWOWS", "R%1")
    if whatsthis <= 5 then
        s = s:gsub("U([^VW])", "UW%1")
        s = s:gsub("u([^vw])", "uw%1")
    end
    s = s:gsub("ith ", "if ")
    s = s:gsub("([fps])([aeio]%w+)", "%1w%2") or s
    s = s:gsub("n([aeiou]%w)", "ny%1") or s
    s = s:gsub(" th", " d") or s
    s = string.format(" %s ", s)
    for k in zo_strgmatch(s, "%a+") do
        if zo_random(12) == 1 then
            local firstChar = k:sub(1, 1)
            s = s:gsub(string.format(" %s ", k), string.format(" %s-%s ", firstChar, k))
        end
    end
    s = zo_strtrim(s)
    s = whatsthis == 1 and s .. " " .. owoEmote or s:gsub("!$", " " .. owoEmote)
    -- pwease owo wesponsibwy
    s = #s <= 255 and s:gsub("owo%d+", RestoreLink) or message
    return s
end

local EnabledMsg =
{
    [true] = "|c2dc50eEnabwed|r",
    [false] = "|cff2424Disabwed|r",
}

---
--- @param msg string
local function PrintMessage(msg)
    CHAT_ROUTER:AddSystemMessage("OwoSpeak: " .. msg)
end

local function tablefind(tab, el)
    for index, value in pairs(tab) do
        if value == el then
            return index
        end
    end
end

---
--- @param text string
local function SlashCommandHandler(text)
    text = zo_strtrim(text)
    if text == "say" then
        db.say = not db.say
        PrintMessage("Say - " .. EnabledMsg[db.say])
    elseif text == "yell" then
        db.yell = not db.yell
        PrintMessage("Yell - " .. EnabledMsg[db.yell])
    elseif text == "zone" then
        db.zone = not db.zone
        PrintMessage("Zone - " .. EnabledMsg[db.zone])
    elseif text == "party" or text == "group" then
        db.party = not db.party
        PrintMessage("Party/Group - " .. EnabledMsg[db.party])
    elseif text == "guild" then
        db.guild = not db.guild
        PrintMessage("Guild - " .. EnabledMsg[db.guild])
    elseif text == "officer" then
        db.officer = not db.officer
        PrintMessage("Officer - " .. EnabledMsg[db.officer])
    elseif text == "whisper" or text == "tell" then
        db.whisper = not db.whisper
        PrintMessage("Whisper - " .. EnabledMsg[db.whisper])
    elseif text == "emote" then
        db.emote = not db.emote
        PrintMessage("Emote - " .. EnabledMsg[db.emote])
    elseif string.find(text, "add") then
        local exploded = {}
        for substring in zo_strgmatch(text, "[^%s]+") do
            table.insert(exploded, substring)
        end
        if exploded[2] then
            table.insert(blockedChannels, exploded[2])
            PrintMessage("Added " .. exploded[2] .. " to the blocked channel list.")
        else
            PrintMessage("You must provide a channel name to block.")
        end
    elseif string.find(text, "remove") then
        local exploded = {}
        local foundAndRemoved = false
        for substring in zo_strgmatch(text, "[^%s]+") do
            table.insert(exploded, substring)
        end
        if exploded[2] then
            for key, value in pairs(blockedChannels) do
                if value == exploded[2] then
                    PrintMessage("Removed " .. exploded[2] .. " from the blocked channels list.")
                    table.remove(blockedChannels, tablefind(blockedChannels, exploded[2]))
                    foundAndRemoved = true
                end
            end
            if foundAndRemoved == false then
                PrintMessage("Could not find the specified channel in the blocked channels list.")
            end
        else
            PrintMessage("You must provide a channel name to unblock.")
        end
    elseif text == "blocked" then
        PrintMessage("Currently blocked channels:")
        for key, value in pairs(blockedChannels) do
            CHAT_ROUTER:AddSystemMessage(value)
        end
    elseif text == "help" then
        PrintMessage("Available commands:")
        CHAT_ROUTER:AddSystemMessage("/owo - toggle owospeak on/off")
        CHAT_ROUTER:AddSystemMessage("/owo say - toggle say chat")
        CHAT_ROUTER:AddSystemMessage("/owo yell - toggle yell chat")
        CHAT_ROUTER:AddSystemMessage("/owo zone - toggle zone chat")
        CHAT_ROUTER:AddSystemMessage("/owo party (or group) - toggle party/group chat")
        CHAT_ROUTER:AddSystemMessage("/owo guild - toggle guild chat")
        CHAT_ROUTER:AddSystemMessage("/owo officer - toggle officer chat")
        CHAT_ROUTER:AddSystemMessage("/owo whisper (or tell) - toggle whispers")
        CHAT_ROUTER:AddSystemMessage("/owo emote - toggle emotes")
        CHAT_ROUTER:AddSystemMessage("/owo add <channel name> - block owospeak in a specific channel")
        CHAT_ROUTER:AddSystemMessage("/owo remove <channel name> - unblock a channel")
        CHAT_ROUTER:AddSystemMessage("/owo blocked - list blocked channels")
    else
        db.enabled = not db.enabled
        PrintMessage(EnabledMsg[db.enabled])
    end
end


--- @class OwoSpeakControl : Control
local control = GetWindowManager():CreateControl("OwoSpeakControl", GuiRoot, CT_CONTROL)

control:RegisterForEvent(EVENT_ADD_ON_LOADED, function (eventId, addonName)
    if addonName == "OwoSpeak" then
        -- Initialize saved variables with defaults
        OwoSpeakDB = OwoSpeakDB or ZO_ShallowTableCopy(defaults)
        OwoSpeakDBBlockedChannels = OwoSpeakDBBlockedChannels or ZO_ShallowNumericallyIndexedTableCopy(blockedChannelsDefaults)

        blockedChannels = OwoSpeakDBBlockedChannels
        db = OwoSpeakDB

        -- Merge any new defaults
        for k, v in pairs(defaults) do
            if db[k] == nil then
                db[k] = v
            end
        end

        -- Hook SharedChatSystem:SubmitTextEntry using ZO_PreHook to avoid tainting
        local chatSystem = ZO_GetChatSystem()
        ZO_PreHook(chatSystem, "SubmitTextEntry", function (self)
            local text = self.textEntry:GetText()
            -- Don't transform slash commands (anything starting with "/")
            if text and #text > 0 and text:sub(1, 1) ~= "/" then
                -- Check if we should owo-ify this message
                if ShouldOwo(self.currentChannel) and ShouldOwoTwo(self.currentChannel) then
                    -- Transform the text
                    local owoText = TransformOwo(text)
                    -- Set the transformed text back BEFORE SubmitTextEntry reads it
                    self.textEntry.editControl:SetText(owoText)
                end
            end
            -- Return false to allow original SubmitTextEntry to run
            return false
        end)

        -- Register slash commands
        SLASH_COMMANDS["/owo"] = SlashCommandHandler
        SLASH_COMMANDS["/owospeak"] = SlashCommandHandler

        -- Unregister event
        control:UnregisterForEvent(eventId)
    end
end)
