--------------------------------------------------------------------------------
--                   Zolan's Chat Notification (Handler)                      --
--------------------------------------------------------------------------------
local ZCN      = Zolan_CN
local Handler  = ZCN.Handler
local Notifier = ZCN.Notifier
local Util     = ZCN.Util

-- ZO
local EVENT_MANAGER              = EVENT_MANAGER
local EVENT_ADD_ON_LOADED        = EVENT_ADD_ON_LOADED
local EVENT_CHAT_MESSAGE_CHANNEL = EVENT_CHAT_MESSAGE_CHANNEL
local EVENT_PLAYER_ACTIVATED     = EVENT_PLAYER_ACTIVATED
-- Lua
local string                     = string

function Handler.handleAddOnLoaded(event, addonName)
    if not ZCN.loaded then ZCN.loadVariables() end

    ZCN.debug("Handler -> handleAddOnLoaded Addon Name:" .. addonName)

    if addonName ~= ZCN.addonName then return end
    ZCN.debug("+_ Handler: Zolan's Chat Notifications: Loaded")

    EVENT_MANAGER:UnregisterForEvent("ZCN_OnLoad", EVENT_ADD_ON_LOADED)

    ZCN.AddonMenu.initializeControlPanel()
    Notifier.registerAlert('Audio', ZCN.AudioAlert)

    -- ZCN.VisualAlert.initializeWindow()

    Handler.loadEventHandlers()
end

function Handler.handleIncomingChat(self, channelID, fromPlayer, message)
    if not ZCN.loaded then ZCN.loadVariables() end

    ZCN.debug("Handler -> handleIncomingChat")

    Notifier.triggerNotifications(channelID, fromPlayer, message)
end

function Handler.handlePlayerActivated()
    if not ZCN.loaded then ZCN.loadVariables() end

    ZCN.debug("Handler -> handlePlayerActivated")

    Util.sendMessageToChat(string.format(
        "%s%s Version %s%s%s Loaded.",
        ZCN.Vars.outputHeader,
        ZCN.Vars.defaultColor,
        ZCN.Vars.currencyColor,
        ZCN.appVersion,
        ZCN.Vars.defaultColor
    ))

    EVENT_MANAGER:UnregisterForEvent("ZCN_PlayerActivated", EVENT_PLAYER_ACTIVATED)
end

function Handler.loadEventHandlers()
    ZCN.debug("+_ Handler -> loadEventHandlers")

    EVENT_MANAGER:RegisterForEvent("ZCN_IncomingChat",    EVENT_CHAT_MESSAGE_CHANNEL, Handler.handleIncomingChat)
    EVENT_MANAGER:RegisterForEvent("ZCN_PlayerActivated", EVENT_PLAYER_ACTIVATED,     Handler.handlePlayerActivated)
end

EVENT_MANAGER:RegisterForEvent("ZCN_OnLoad", EVENT_ADD_ON_LOADED, Handler.handleAddOnLoaded)
