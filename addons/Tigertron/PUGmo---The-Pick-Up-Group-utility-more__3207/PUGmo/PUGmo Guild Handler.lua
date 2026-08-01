if not PUGmo then
    PUGmo = {}
end
local PUG = PUGmo
local WM = WINDOW_MANAGER
local EM = EVENT_MANAGER
local SM = SCENE_MANAGER
local CM = CALLBACK_MANAGER
local CS = CHAT_SYSTEM


-------------------------------------------------------------------------
--- Guild Handler
--CHAT_CHANNEL_GUILD_1 = 12
--CHAT_CHANNEL_GUILD_2 = 13
--CHAT_CHANNEL_GUILD_3 = 14
--CHAT_CHANNEL_GUILD_4 = 15
--CHAT_CHANNEL_GUILD_5 = 16
--CHAT_CHANNEL_OFFICER_1 = 17
--CHAT_CHANNEL_OFFICER_2 = 18
--CHAT_CHANNEL_OFFICER_3 = 19
--CHAT_CHANNEL_OFFICER_4 = 20
--CHAT_CHANNEL_OFFICER_5 = 21
-------------------------------------------------------------------------
function PUG:guildHandler(channel, fromName, msg, isCustomerService, name)

    local ch = channel
    channel = 0

    if ch >= 12 and ch <= 21 then
        ch = ch - 11
       if ch >= 6 and ch <= 10 then
            ch = ch - 5
        end
        channel = ch
    end
    PUG:zoneHandler(channel, fromName, msg, isCustomerService, name)
end

