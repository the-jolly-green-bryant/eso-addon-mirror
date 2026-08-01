--------------------------------------------------------------------------------
--                   Zolan's Chat Notification (Util)                         --
--------------------------------------------------------------------------------
local ZCN  = Zolan_CN
local Util = ZCN.Util

-- ZO
local CHAT_SYSTEM = CHAT_SYSTEM

function Util.sendMessageToChat(formattedMessage)
    ZCN.debug("Util -> sendMessageToChat")

    CHAT_SYSTEM["containers"][1]["currentBuffer"]:AddMessage(formattedMessage)
end

function Util.getChannelNameFromChannelID(channelID)
    ZCN.debug("Util -> getChannelNameFromChannelID")
    return ZCN.Vars.channelIDToNameXref[channelID] or 'Unknown'
end
