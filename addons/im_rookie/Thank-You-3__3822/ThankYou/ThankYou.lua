ThankYou = {}
ThankYou.name = "ThankYou"
ThankYou.version = "1.1"
ThankYou.variableVersion = 2

ThankYou.resurectors = {}
ThankYou.pending = ""
ThankYou.chatMessage = true
ThankYou.detail = false
ThankYou.beforeCombat = false
ThankYou.inCombatNow = false

ThankYou.Default = {
	MailSubject = "Thank you for reviving me!",
	SingularMailMessage = "It is with profound gratitude that I express my appreciation for the gift of life once again. Me, {me}, extend my sincerest thanks to you, {savior}, for be my savior and granting me another opportunity to fight. Your intervention has been invaluable, rescuing me one time. Please accept my heartfelt gratitude for your unwavering support and guidance.",
	PluralMailMessage = "It is with profound gratitude that I express my appreciation for the gift of life once again.Me, {me}, extend my sincerest thanks to you, {savior}, for be my savior and granting me another opportunity to fight. Your intervention has been invaluable, rescuing me one time. Please accept my heartfelt gratitude for your unwavering support and guidance.",
    chatMessage = true,
    beforeCombat = true,
    detail = false
}

local LAM = LibAddonMenu2

-- funcion del comando /ty
function command(extra)
    RequestOpenMailbox()
end

-- Inicio del addon (registro de eventos y comandos)
function ThankYou.Initialize()
    EVENT_MANAGER:RegisterForEvent(ThankYou.name, EVENT_MAIL_OPEN_MAILBOX, ThankYou.onMailOpen)

    EVENT_MANAGER:RegisterForEvent(ThankYou.name, EVENT_RESURRECT_REQUEST, ThankYou.OnResurrectRequest)
    EVENT_MANAGER:RegisterForEvent(ThankYou.name, EVENT_RESURRECT_REQUEST_REMOVED, ThankYou.OnResurrectRequestRemoved)
    EVENT_MANAGER:RegisterForEvent(ThankYou.name, EVENT_PLAYER_ACTIVATED, ThankYou.OnScreenLoaded)
    EVENT_MANAGER:RegisterForEvent(ThankYou.name, EVENT_PLAYER_COMBAT_STATE, ThankYou.OnCombatChanged)

    LAM:RegisterAddonPanel("ThanYou", ThankYou.panelData)
    LAM:RegisterOptionControls("ThanYou", ThankYou.optionsTable)
    ThankYou.chatMessage = ThankYou.savedVariables.chatMessage;
    ThankYou.detail = ThankYou.savedVariables.detail;
    
    SLASH_COMMANDS["/ty"] = command

end

-- load function... inicializa el addon
function ThankYou.OnAddOnLoaded(event, addonName)
    if addonName == ThankYou.name then
        ThankYou.savedVariables = ZO_SavedVars:NewAccountWide("ThankYouSavedVariables", ThankYou.variableVersion, nil, ThankYou.Default, GetWorldName())
        ThankYou.Initialize()
        EVENT_MANAGER:UnregisterForEvent(ThankYou.name, EVENT_ADD_ON_LOADED)
    end
end
--------------------------------------
-- Combat Manager
--------------------------------------

function ThankYou.OnCombatChanged(eventCode, isCombat)
    ThankYou.inCombatNow = isCombat
    if not ThankYou.inCombatNow  and ThankYou.beforeCombat then
        zo_callLater(callCombat, 4000)
    end
end

function callCombat()
    if not checkCombatStatus() then
        RequestOpenMailbox()
    end
end

function checkCombatStatus()
    local inCombat = IsUnitInCombat("player")
    return inCombat
end
--------------------------------------
-- Mail Manager
--------------------------------------

function generateMessage(message, count, savior)
    local player = GetUnitName("player") 
    local customMessage = message
    customMessage = string.gsub(customMessage, "{count}", tostring(count))
    customMessage = string.gsub(customMessage, "{savior}", savior)
    customMessage = string.gsub(customMessage, "{me}", player)
    return customMessage

end

-- Evento para abrir el Mail Box del usuario
function ThankYou.onMailOpen()
    local inDungeon = IsUnitInDungeon("player")
    if has_saviors() and not inDungeon then
        for player_name, count in pairs(ThankYou.resurectors) do
            subject_message = generateMessage(ThankYou.savedVariables.MailSubject, count, player_name)
            singular_mail_message = generateMessage(ThankYou.savedVariables.SingularMailMessage, count, player_name)
            plural_mail_message = generateMessage(ThankYou.savedVariables.PluralMailMessage, count, player_name)

            if count == 1 then
                SendMail(player_name, subject_message, singular_mail_message)
            else
                
            SendMail(player_name, subject_message, plural_mail_message)
            end
        end
        if ThankYou.chatMessage then d("you have been send " .. tablelength(ThankYou.resurectors) .. " mails of thanks.") end
        
        if ThankYou.detail then
            d("Saviors:")
            for player_name, count in pairs(ThankYou.resurectors) do
                if count == 1 then
                    d(" - The player " .. player_name .. " has resurrected you " .. count .. " time.")
                else
                    d(" - The player " .. player_name .. " has resurrected you " .. count .. " times.")
                end
            end
        end

        ThankYou.resurectors = {}
    end
end

function ThankYou.OnScreenLoaded()
    if has_saviors() then
        RequestOpenMailbox()
    end
end

--------------------------------------
-- Resurections Manager
--------------------------------------

function ThankYou.OnResurrectRequestRemoved()
    if ThankYou.getPending() ~= "" then
        if not IsUnitDead("player") then
            if ThankYou.chatMessage then d("¡You have been revived by " .. ThankYou.getPending() .. "!") end
            add_res(ThankYou.getPending())
        end
        ThankYou.setPending("")
    end
end

function ThankYou.OnResurrectRequest(_, _, _, revivingPlayerName)
    ThankYou.setPending(revivingPlayerName)
end

function add_res(player_name)
    if not ThankYou.resurectors[player_name] then
        ThankYou.resurectors[player_name] = 1
    else
        ThankYou.resurectors[player_name] = ThankYou.resurectors[player_name] + 1
    end
end
function has_saviors()
    return next(ThankYou.resurectors) ~= nil
end

function ThankYou.setPending(name) 
    ThankYou.pending = name
end

function ThankYou.getPending() 
    return ThankYou.pending
end

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end 

--------------------------------------
-- LibAddonMenu-2 Manager
--------------------------------------
ThankYou.panelData = {
    type = "panel",
    name = ThankYou.name,
    displayName = "ThankYou mail options ;D",
    author = "@im_rookie",
    version = ThankYou.version,
    registerForRefresh = false,
    registerForDefaults = true,
}

ThankYou.optionsTable = {
    [1] = {
        type = "editbox",
        name = "|ccc33ffMail Subject|r",
        getFunc = function() return ThankYou.savedVariables.MailSubject end,
        setFunc = function(value) ThankYou.savedVariables.MailSubject = value end,
        width = "full",
        maxChars = 50,
        isExtraWide= true,
        requiresReload = true,
        warning = "Maximum allowed characters: 40",
        default = ThankYou.Default.MailSubject,
    },
    [2] = {
        type = "divider",
        width = "full",
        alpha = 1,
    },
    [3]  = {
        type = "submenu",
        name = "Mail Mensages",
        tooltip = "Contains messages for mails with prural and singular resurrections.",
        controls = {
            [1] = {
                type = "editbox",
                name = "|cff66ccSingular Mail Message|r",
                getFunc = function() return ThankYou.savedVariables.SingularMailMessage end,
                setFunc = function(value)
                    if value ~= "" then
                        ThankYou.savedVariables.SingularMailMessage = value
                    else
                        ThankYou.savedVariables.SingularMailMessage = ThankYou.Default.SingularMailMessage
                    end
                end,
                width = "full",
                isExtraWide= true,
                isMultiline = true,
                maxChars = 500,
                requiresReload = true,
                warning = "Maximum allowed characters: 500",
                default = ThankYou.Default.SingularMailMessage,
            },
            [2] = {
                type = "editbox",
                name = "|cff66ccPlural Mail Message|r",
                getFunc = function() return ThankYou.savedVariables.PluralMailMessage end,
                setFunc = function(value)
                    if value ~= "" then
                        ThankYou.savedVariables.PluralMailMessage = value
                    else
                        ThankYou.savedVariables.PluralMailMessage = ThankYou.Default.PluralMailMessage
                    end
                end,
                width = "full",
                isExtraWide= true,
                isMultiline = true,
                maxChars = 500,
                requiresReload = true,
                warning = "Maximum allowed characters: 500",
                default = ThankYou.Default.PluralMailMessage,
            }
        },
    },
    [4] = {
        type = "description",
        text = "The variable |cdedb23{savior}|r will be replaced with the name of the player who resurected you, |cdedb23{count}|r with the number of times you have been resurected by that player and |cdedb23{me}|r with your name",
        width = "full",
    },
    [5] = {
        type = "divider",
        width = "full",
        alpha = 1,
    },
    [6] = {
        type = "checkbox",
        name = "Chat messages",
        width = "full",
        tooltip = "Do you want to receive a message when you send mails and when someone resurrects you?.",
        getFunc = function() return ThankYou.savedVariables.chatMessage end,
        setFunc = function(value)
            ThankYou.savedVariables.chatMessage = value
            ThankYou.chatMessage = value
        end,
    },
    [7] = {
        type = "checkbox",
        name = "Detail",
        width = "full",
        tooltip = "Do you want a detail to be displayed when you send emails with who resurected you and how many times they did it?.",
        getFunc = function() return ThankYou.savedVariables.detail end,
        setFunc = function(value)
            ThankYou.savedVariables.detail = value
            ThankYou.detail = value
        end,
    },
    [8] = {
        type = "checkbox",
        name = "Before Combat Message",
        width = "full",
        tooltip = "Do you want mail to be sent when a fight is over?.",
        getFunc = function() return ThankYou.savedVariables.beforeCombat end,
        setFunc = function(value)
            ThankYou.savedVariables.beforeCombat = value
            ThankYou.beforeCombat = value
        end,
    },
}

EVENT_MANAGER:RegisterForEvent(ThankYou.name, EVENT_ADD_ON_LOADED, ThankYou.OnAddOnLoaded)