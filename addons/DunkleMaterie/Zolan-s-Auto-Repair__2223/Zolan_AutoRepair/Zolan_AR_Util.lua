--------------------------------------------------------------------------------
--                   Zolan's Auto Repair (Util)
--------------------------------------------------------------------------------
local ZAR  = Zolan_AR
local Util = ZAR.Util

-- ZO
local CHAT_SYSTEM          = CHAT_SYSTEM
local zo_strlower          = zo_strlower
local zo_strsplit          = zo_strsplit
local zo_strupper          = zo_strupper
-- Lua
local string               = string

function Util.sendMessageToChat(formattedMessage)
    ZAR.debug("Util -> sendMessageToChat")

    CHAT_SYSTEM["containers"][1]["currentBuffer"]:AddMessage(formattedMessage)
end

function Util.formatItemLink(itemLink)
    ZAR.debug("Util -> formatItemLink")

    return zo_strformat(SI_TOOLTIP_ITEM_NAME, itemLink)
end
