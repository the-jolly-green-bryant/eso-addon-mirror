local LAM = LibAddonMenu2

local savedVars = {
    notifOff = false
}

-- Add menu with options.
local panelData = {
    type = "panel",
    name = "BestFriends 2018",
    displayName = "BestFriends Settings",
    registerForRefresh = true,
    registerForDefaults = true,
}

local optionsTable = {
    [1] = {
        type = "checkbox",
        name = "No Notifications",
        tooltip = "Do not display any notifications, at all.",
        getFunc = function()
                return savedVars.notifOff
            end,
        setFunc = function(v)
                savedVars.notifOff = v
            end,
        width = "full", --or "half",
    },
    [2] = {
        type = "button",
        name = "Test ",
        tooltip = "Click this button to test the login and logoff notifications.",
        func = function()
            d('|cFFFFFFBestFriends 2018:|r Testing player login and then logoff messages.')

            local formatters = CHAT_ROUTER:GetRegisteredMessageFormatters()
            local onChatEventCallback = formatters[EVENT_FRIEND_PLAYER_STATUS_CHANGED]

            onChatEventCallback('@playerAccount', 'CharacterName', PLAYER_STATUS_OFFLINE, PLAYER_STATUS_ONLINE)

            zo_callLater(function ()
                onChatEventCallback('@playerAccount', '', PLAYER_STATUS_ONLINE, PLAYER_STATUS_OFFLINE)
            end, 2000)
        end,
        width = "full", --or "half",
    },
}

local function LoadMenu()
    LAM:RegisterAddonPanel("BestFriends 2018", panelData)
    LAM:RegisterOptionControls("BestFriends 2018", optionsTable)
end

local function statusChanged(displayName, characterName, oldStatus, newStatus)
    -- d('statusChanged', displayName, characterName, oldStatus, newStatus)
    -- No notifications.
    if savedVars.notifOff then return end

    local wasOnline = oldStatus ~= PLAYER_STATUS_OFFLINE
    local isOnline = newStatus ~= PLAYER_STATUS_OFFLINE

    if wasOnline ~= isOnline then
        local text
        local displayNameLink = ZO_LinkHandler_CreateDisplayNameLink(displayName)
        local characterNameLink = ZO_LinkHandler_CreateCharacterLink(characterName)

        if isOnline then
            if characterName ~= "" then
                text = zo_strformat(SI_FRIENDS_LIST_FRIEND_CHARACTER_LOGGED_ON, displayNameLink, characterNameLink)
                ZO_AlertNoSuppression(UI_ALERT_CATEGORY_ALERT, nil, text)
            else
                text = zo_strformat(SI_FRIENDS_LIST_FRIEND_LOGGED_ON, displayNameLink)
                ZO_AlertNoSuppression(UI_ALERT_CATEGORY_ALERT, nil, text)
            end
        else
            if characterName ~= "" then
                text = zo_strformat(SI_FRIENDS_LIST_FRIEND_CHARACTER_LOGGED_OFF, displayNameLink, characterNameLink)
                ZO_AlertNoSuppression(UI_ALERT_CATEGORY_ALERT, nil, text)
            else
                text = zo_strformat(SI_FRIENDS_LIST_FRIEND_LOGGED_OFF, displayNameLink)
                ZO_AlertNoSuppression(UI_ALERT_CATEGORY_ALERT, nil, text)
            end
        end
        -- return text, nil, displayName
    end
end

-- Copied and edited from source:
-- https://esoapi.uesp.net/100022/src/ingame/chatsystem/chathandlers.lua.html
-- Original irrelevant code commented out, for reference.
local function initialize(event, addonName)
    if addonName ~= "BestFriends2018" then return end

    -- Load saved variables.
    savedVars = ZO_SavedVars:New("BestfriendsAddonSavedVars", 1, nil, savedVars)

    -- Settings menu.
    LoadMenu()

    -- Override. Should be compatible with other overrides, such as LibChatMessage.
    ZO_ChatSystem_GetEventHandlers()[EVENT_FRIEND_PLAYER_STATUS_CHANGED] = statusChanged
    CHAT_ROUTER.registeredMessageFormatters[EVENT_FRIEND_PLAYER_STATUS_CHANGED] = statusChanged

    EVENT_MANAGER:UnregisterForEvent("ChatRouter", EVENT_FRIEND_PLAYER_STATUS_CHANGED)
    EVENT_MANAGER:RegisterForEvent("ChatRouter", EVENT_FRIEND_PLAYER_STATUS_CHANGED,
        function (eventCode, ...)
            statusChanged(...)
        end)

    -- CHAT_ROUTER = ZO_ChatRouter:New()
    -- ZO_ChatSystem_AddEventHandler(EVENT_FRIEND_PLAYER_STATUS_CHANGED, statusChanged)
end
EVENT_MANAGER:RegisterForEvent("BestFriends2018", EVENT_ADD_ON_LOADED, initialize)
