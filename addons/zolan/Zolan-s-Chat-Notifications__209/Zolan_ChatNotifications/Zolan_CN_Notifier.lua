--------------------------------------------------------------------------------
--                   Zolan's Chat Notification (Notifier)                     --
--------------------------------------------------------------------------------
local ZCN        = Zolan_CN
local Notifier   = ZCN.Notifier
local AudioAlert = ZCN.AudioAlert
local Util       = ZCN.Util

-- ZO
local GetDisplayName = GetDisplayName
local GetUnitName    = GetUnitName
local IsFriend       = IsFriend
local zo_strsplit    = zo_strsplit
-- Lua
local ipairs         = ipairs
local pairs          = pairs
local string         = string

function Notifier.registerAlert(alertType, alert)
    ZCN.debug("Notifier -> registerAlert")
    Notifier.Alerts[alertType] = alert
end

function Notifier.shouldNotifyForOnChannel(channelName)
    ZCN.debug("+_ Notifier -> shouldNotifyForOnChannel")
    ZCN.debug("   +_ Notifier: Always")
    return true
end


function Notifier.shouldNotifyForOnFriend(fromPlayer)
    ZCN.debug("+_ Notifier -> shouldNotifyForOnFriend")

    return IsFriend(fromPlayer)
end

function Notifier.shouldNotifyForOnMyName(message)
    ZCN.debug("+_ Notifier -> shouldNotifyForOnMyName")

    local playerName = GetUnitName('player') or 'Unknown'
    local playerAcct = GetDisplayName()      or 'Unknown'

    local strippedPlayerAcct = string.gsub(playerAcct, '@', '')

    local shouldNotifyForOnMyName = false

    if string.match(string.lower(message), string.lower(playerName)) then
        ZCN.debug("   +_ Notifier: Was Character Name")
        shouldNotifyForOnMyName = true
    end

    -- Added because ZOS broke GetDisplayName() and it is returning empty string.
    if strippedPlayerAcct == '' then
        return shouldNotifyForOnMyName
    end

    if string.match(string.lower(message), string.lower(strippedPlayerAcct)) then
        ZCN.debug("   +_ Notifier: Was Character Account")
        shouldNotifyForOnMyName = true
    end

    return shouldNotifyForOnMyName
end

function Notifier.isSenderInBlacklist(fromPlayer)
    ZCN.debug("+_ Notifier -> isSenderInBlacklist")

    local playerBlacklist = { zo_strsplit("\n", ZCN.savedVars.playerBlacklist) }

    local isSenderInBlacklist = false

    for _,player in ipairs(playerBlacklist) do
        player     = string.gsub(player,     '%%', '')
        player     = string.gsub(player,     '@',  '')
        fromPlayer = string.gsub(fromPlayer, '@',  '')

        if string.match(string.lower(fromPlayer), string.lower(player)) then
            ZCN.debug("   +_ Notifier: Is Blacklisted Player -> " .. player)
            isSenderInBlacklist = true
        end
    end

    return isSenderInBlacklist
end

function Notifier.shouldNotifyForOnKeyWords(message)
    ZCN.debug("+_ Notifier -> shouldNotifyForOnKeyWords")

    local keyWordList = { zo_strsplit("\n", ZCN.savedVars.keyWords) }

    local shouldNotifyForOnKeyWords = false

    for _,keyWord in ipairs(keyWordList) do
        -- The following regex is hideous.  It effectively adds single brackets around and escapes
        -- %, [], (), {}, ^, $, +
        keyWord = string.gsub(keyWord, '([%[%]%%%(%)%{%}%$%^%+])', '[%%%1]')
        message = string.gsub(message, '([%[%]%%%(%)%{%}%$%^%+])', '[%%%1]')

        if string.match(string.lower(message), string.lower(keyWord)) then
            ZCN.debug("   +_ Notifier: Was Key Word -> " .. keyWord)
            shouldNotifyForOnKeyWords = true
        end
    end

    return shouldNotifyForOnKeyWords
end

function Notifier.shouldNotifyOnMyChat(channelName, fromPlayer)
    ZCN.debug("+_ Notifier -> shouldNotifyForOnMyChat")

    local playerName  = GetUnitName('player') or 'Unknown'
    local playerAcct  = GetDisplayName()      or 'Unknown'
    local whisperSent = false

    ZCN.debug("   +_ Notifier: My Name Is: " .. playerName)
    ZCN.debug("   +_ Notifier: My Acct Is: " .. playerAcct)

    if channelName == 'WhisperSent' then
        ZCN.debug("   +_ Notifier: Was a SENT whisper.")
        whisperSent = true
    end

    local shouldNotifyOnMyChat = false
    if fromPlayer == playerName or fromPlayer == playerAcct or whisperSent then
        ZCN.debug("   +_ Notifier: Was From Me")
        shouldNotifyOnMyChat = true
    end

    return shouldNotifyOnMyChat
end

function Notifier.triggerNotifications(channelID, fromPlayer, message)
    ZCN.debug("Notifier -> triggerNotifications")
    ZCN.debug("+_ Notifier: channelID  -> [" .. channelID  .. "]")
    ZCN.debug("+_ Notifier: fromPlayer -> [" .. fromPlayer .. "]")

    local channelName = Util.getChannelNameFromChannelID(channelID)

    local originalChannelName = channelName

    if channelName == 'WhisperSent' then
        ZCN.debug("+_ Changing WhisperSent to Whisper")
        channelName = 'Whisper'
    end

    for alertType,alert in pairs(Notifier.Alerts) do
        ZCN.debug("+_ Notifier: Triggering " .. alertType .. "Alerts")

        if channelName == 'Unknown' then
            break
        end

        if Notifier.isSenderInBlacklist(fromPlayer) then
            break
        end

        if Notifier.shouldNotifyOnMyChat(originalChannelName, fromPlayer) then
            alert.alertForConfKey('onMyChat')
            break
        end

        local notified = false


        if Notifier.shouldNotifyForOnChannel(channelName) then
            local confKey = 'on' .. channelName;
            alert.alertForConfKey(confKey)
            notified = true
        end

        if Notifier.shouldNotifyForOnFriend(fromPlayer) then
            alert.alertForConfKey('onFriend')
            notified = true
        end

        if Notifier.shouldNotifyForOnMyName(message) then
            alert.alertForConfKey('onMyName')
            notified = true
        end

        if Notifier.shouldNotifyForOnKeyWords(message) then
            alert.alertForConfKey('onKeyWords')
            notified = true
        end

        if not notified then
            ZCN.debug("+_ Notifier: Not Alerting")
        end
    end
end
