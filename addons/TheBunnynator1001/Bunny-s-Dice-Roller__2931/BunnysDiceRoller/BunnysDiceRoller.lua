--Bunny's Dice Roller
--
-- Version 1.0.1.1
--
-- Written by TheBunnynator1001
--
-- For requests or suggestions:
--
-- @TheBunnynator1001 in game
-- TheBunnynator1001#2728 in Discord
-- esthebunnynator1001@gmail.com
--   
-- This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates. 
-- The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. 
-- in the United States and/or other countries.
-- All rights reserved.
--
-- Thanks for using my addon and for your support!


BunnysDiceRoller = {}

BunnysDiceRoller.name = 'BunnysDiceRoller'
BunnysDiceRoller.version = "1.0.1.1"

local function Initialize()
    
    d("|ceeeeeeBunny's Dice Roller by |r TheBunnynator1001 |ceeeeee v"..BunnysDiceRoller.version.."|r")

end

local function OnAddOnLoaded(event, addonName)
    if addonName ~= "BunnysDiceRoller" then return end
    if addonName == "BunnysDiceRoller" then 
        zo_callLater(Initialize, 1000)
    end
end

local function cleverness()
    clever = {"RNGeezus has chosen ", "The Dice Have Chosen ","DiceLord says ", "The fates have chosen ", "Your fate has been decided, your number is ",
            "The Universe has chosen the nubmer "}
--    for k in pairs(clever) do
--        table.insert(keyset, k)
--    end
--    r = clever[keyset[math.random(#keyset)]]
    r = clever[math.random(#clever)]
    return r
end

EVENT_MANAGER:RegisterForEvent("BunnysDiceRoller", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
SLASH_COMMANDS['/roll'] = function(...)
    -- To grab user input from chat, implement "..."
        StartChatInput(cleverness()..math.random(1, ...).."!" , CHAT_CHANNEL_ACTIVE)
end
