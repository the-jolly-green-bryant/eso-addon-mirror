-- NORAI.lua — Auto-invite module for NOR Guild Tools

local Addon = NORGuildTools
Addon.AI = Addon.AI or {}
local AI = Addon.AI

AI.enabled = false
AI.keyword = nil
AI.groupLimit = 12
AI.listening = false

------------------------------------------------------------
-- SavedVariables (stored inside NORGuildTools_Saved)
------------------------------------------------------------
local function LoadSettings()
    Addon.saved.AI = Addon.saved.AI or {
        enabled = false,
        keyword = "norx",
        groupLimit = 12,
    }

    AI.enabled = Addon.saved.AI.enabled
    AI.keyword = Addon.saved.AI.keyword
    AI.groupLimit = Addon.saved.AI.groupLimit
end

local function SaveSettings()
    Addon.saved.AI.enabled = AI.enabled
    Addon.saved.AI.keyword = AI.keyword
    Addon.saved.AI.groupLimit = AI.groupLimit
end

------------------------------------------------------------
-- Utility
------------------------------------------------------------
local function echo(msg)
    CHAT_ROUTER:AddSystemMessage("|cFFD700NORAI|r " .. msg)
end

------------------------------------------------------------
-- Tick: checks group size every second
------------------------------------------------------------
function AI.Tick()
    if AI.enabled and AI.listening then
        if GetGroupSize() >= AI.groupLimit then
            AI.StopListening()
            echo("Group has reached its limit (" .. GetGroupSize() .. "/" .. AI.groupLimit .. "). Auto-invite disabled.")
        end
    end
end

------------------------------------------------------------
-- Start listening for keyword
------------------------------------------------------------
function AI.StartListening()
    if not AI.enabled then return end
    if AI.listening then return end

    if GetGroupSize() >= AI.groupLimit then
        echo("Group is already full (" .. GetGroupSize() .. "/" .. AI.groupLimit .. "). Auto-invite disabled.")
        AI.enabled = false
        SaveSettings()
        return
    end

    EVENT_MANAGER:RegisterForEvent("NORAI_Chat", EVENT_CHAT_MESSAGE_CHANNEL, AI.OnChatMessage)
    EVENT_MANAGER:RegisterForUpdate("NORAI_Tick", 1000, AI.Tick)

    AI.listening = true
    echo("Listening for keyword: '" .. AI.keyword .. "' with group limit: " .. AI.groupLimit)
end

------------------------------------------------------------
-- Stop listening
------------------------------------------------------------
function AI.StopListening()
    EVENT_MANAGER:UnregisterForEvent("NORAI_Chat", EVENT_CHAT_MESSAGE_CHANNEL)
    EVENT_MANAGER:UnregisterForUpdate("NORAI_Tick")

    AI.listening = false
    AI.enabled = false
    SaveSettings()
end

------------------------------------------------------------
-- Chat message handler
------------------------------------------------------------
function AI.OnChatMessage(_, messageType, senderName, messageText)
    if not AI.enabled or not AI.listening then return end

    local isGuildChat =
        messageType == CHAT_CHANNEL_GUILD_1 or
        messageType == CHAT_CHANNEL_GUILD_2 or
        messageType == CHAT_CHANNEL_GUILD_3 or
        messageType == CHAT_CHANNEL_GUILD_4 or
        messageType == CHAT_CHANNEL_GUILD_5

    if messageType ~= CHAT_CHANNEL_WHISPER and not isGuildChat then return end

    senderName = zo_strformat("<<1>>", senderName)
    local msgLower = string.lower(messageText)
    local keywordLower = string.lower(AI.keyword or "norx")

    if string.match(msgLower, "^" .. keywordLower .. "$") then
        GroupInviteByName(senderName)
        echo("Summoning a loyal warrior to the battlefield!")
    end
end

------------------------------------------------------------
-- Slash command handler
------------------------------------------------------------
local function HandleSlashCommand(input)
    local args = {}
    for word in string.gmatch(input, "%S+") do
        table.insert(args, word)
    end

    local function isValidGroupSize(n)
        return n and n >= 2 and n <= 12
    end

    if #args == 0 then
        AI.enabled = not AI.enabled
        SaveSettings()

        if not AI.keyword then
            AI.keyword = "norx"
            SaveSettings()
        end

        if AI.enabled then
            AI.StartListening()
        else
            AI.StopListening()
            echo("Auto-invite is now |cFF0000INACTIVE|r.")
        end

    elseif #args == 1 then
        local num = tonumber(args[1])
        if isValidGroupSize(num) then
            AI.groupLimit = num
            SaveSettings()
            echo("Group size limit set to " .. num .. ".")
        else
            AI.keyword = args[1]
            AI.enabled = true
            SaveSettings()
            AI.StartListening()
        end

    elseif #args == 2 then
        local keyword = args[1]
        local num = tonumber(args[2])

        if isValidGroupSize(num) then
            AI.keyword = keyword
            AI.groupLimit = num
            AI.enabled = true
            SaveSettings()
            AI.StartListening()
        else
            echo("Invalid group limit. Use a number from 2 to 12.")
        end

    else
        echo("Invalid command format. Use `/norai`, `/norai keyword`, `/norai 8`, or `/norai keyword 8`.")
    end
end

------------------------------------------------------------
-- Restore settings on login
------------------------------------------------------------
local function OnPlayerActivated()
    LoadSettings()
    if AI.enabled then
        AI.StartListening()
    end
end

------------------------------------------------------------
-- Register slash command and events
------------------------------------------------------------
SLASH_COMMANDS["/norai"] = HandleSlashCommand
EVENT_MANAGER:RegisterForEvent("NORAI_PlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

echo("NORAI initialized. Ready to enlist reinforcements!")
