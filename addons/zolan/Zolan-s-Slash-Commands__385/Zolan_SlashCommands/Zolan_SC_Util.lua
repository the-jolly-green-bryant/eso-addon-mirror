--------------------------------------------------------------------------------
--                   Zolan's Auto Repair (Util)
--------------------------------------------------------------------------------
local ZSC  = Zolan_SC
local Util = ZSC.Util

-- ZO
local CHAT_SYSTEM = CHAT_SYSTEM

function Util.sendMessageToChat(formattedMessage)
    ZSC.debug("Util -> sendMessageToChat")

    CHAT_SYSTEM["containers"][1]["currentBuffer"]:AddMessage(formattedMessage)
end
