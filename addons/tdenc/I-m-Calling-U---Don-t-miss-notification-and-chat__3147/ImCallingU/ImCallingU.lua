ICU = ICU or {}
local ICU = ICU
local EM = EVENT_MANAGER

----------------------
--INITIATE VARIABLES--
----------------------
ICU.name = "ImCallingU"
ICU.version = "0.6.0"
ICU.variableVersion = 1
ICU.chatChannels = {
}
ICU.defaultSettings = {
    ["se"] = 2,
    ["volume"] = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME)),
    ["infinity"] = true,
    ["duration"] = 300,
    ["vibration"] = 80,
    ["activity"] = true,
    ["campaign"] = true,
    ["ready"] = true,
    ["share"] = true,
    ["event"] = true,
    ["friend"] = true,
    ["guild"] = true,
    ["group"] = true,
    ["duel"] = true,
    ["trade"] = true,
    ["chat"] = {
        [CHAT_CHANNEL_WHISPER] = true,
        [CHAT_CHANNEL_YELL] = false,
        [CHAT_CHANNEL_SAY] = false,
        [CHAT_CHANNEL_PARTY] = false,
        [CHAT_CHANNEL_GUILD_1] = false,
        [CHAT_CHANNEL_GUILD_2] = false,
        [CHAT_CHANNEL_GUILD_3] = false,
        [CHAT_CHANNEL_GUILD_4] = false,
        [CHAT_CHANNEL_GUILD_5] = false,
        [CHAT_CHANNEL_OFFICER_1] = false,
        [CHAT_CHANNEL_OFFICER_2] = false,
        [CHAT_CHANNEL_OFFICER_3] = false,
        [CHAT_CHANNEL_OFFICER_4] = false,
        [CHAT_CHANNEL_OFFICER_5] = false,
        [CHAT_CHANNEL_ZONE] = false,
        [CHAT_CHANNEL_ZONE_LANGUAGE_1] = false,
        [CHAT_CHANNEL_ZONE_LANGUAGE_2] = false,
        [CHAT_CHANNEL_ZONE_LANGUAGE_3] = false,
        [CHAT_CHANNEL_ZONE_LANGUAGE_4] = false,
        [CHAT_CHANNEL_ZONE_LANGUAGE_5] = false,
        [CHAT_CHANNEL_SYSTEM] = false,
    },
    ["combat"] = false,
    ["pvp"] = false,
}
ICU.soundEffects = {
    [1] = "NONE",
    [2] = "GROUP_ELECTION_REQUESTED",
    [3] = "INVENTORY_ITEM_APPLY_CHARGE",
    [4] = "BATTLEGROUND_CAPTURE_FLAG_TAKEN_OWN_TEAM",
    [5] = "BATTLEGROUND_COUNTDOWN_FINISH",
    [6] = "NEW_TIMED_NOTIFICATION",
    [7] = "QUEST_ABANDONED",
    [8] = "RAID_TRIAL_COUNTER_UPDATE",
    [9] = "ABILITY_COMPANION_ULTIMATE_READY",
    [10] = "AVA_GATE_CLOSED",
    [11] = "CHAMPION_POINTS_COMMITTED",
    [12] = "CODE_REDEMPTION_SUCCESS",
    [13] = "DAILY_LOGIN_REWARDS_CLAIM_FANFARE",
    [14] = "DUEL_ACCEPTED",
    [15] = "ELDER_SCROLL_CAPTURED_BY_ALDMERI",
    [16] = "GIFT_INVENTORY_VIEW_FANFARE_SPARKS",
    [17] = "GUILD_ROSTER_REMOVED",
    [18] = "LEVEL_UP_REWARD_FANFARE",
}

---------------------
--WRAPPER FUNCTIONS--
---------------------
local function setVolume(volume)
    SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME, tostring(volume))
end

function ICU.IsCallingDisabled()
    -- Do not use IsInGamepadPreferredMode() / IsConsoleUI()
    return ICU.savedVariables.se == 1 and (GetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_VIBRATION) == "0" or ICU.savedVariables.vibration == 0)
end

function ICU.PlaySound(eventCode)
    if (not ICU.savedVariables.infinity and (ICU.duration[eventCode] >= ICU.savedVariables.duration)) then
        ICU.UnregisterUpdate(eventCode)
        return
    else
        ICU.duration[eventCode] = ICU.duration[eventCode] + 2
    end

    if ICU.userVibration then
        SetGamepadVibration(1000, ICU.vibrationIntensity, ICU.vibrationIntensity / 2, 0, 0, ICU.name)
    end
    PlaySound(ICU.seString)
end

function ICU.RegisterUpdate(eventCode)
    if ICU.isCalling then return end
    if ((IsPlayerInAvAWorld() or IsActiveWorldBattleground()) and ICU.savedVariables.pvp) then return end
    if (IsUnitInCombat("player") and ICU.savedVariables.combat) then return end

    EM:UnregisterForUpdate(string.format("%s_%i", ICU.name, eventCode))
    ICU.isCalling = true
    ICU.duration[eventCode] = 0
    setVolume(ICU.savedVariables.volume)
    ApplySettings()
    ICU.PlaySound(eventCode)
    EM:RegisterForUpdate(string.format("%s_%i", ICU.name, eventCode), 2000, function() ICU.PlaySound(eventCode) end)
end

function ICU.UnregisterUpdate(eventCode)
    ICU.isCalling = false
    ICU.duration[eventCode] = 0
    setVolume(ICU.userVolume)
    ApplySettings()
    EM:UnregisterForUpdate(string.format("%s_%i", ICU.name, eventCode))
end

-------------------
--EVENT FUNCTIONS--
-------------------
function ICU.OnEventTriggered(eventCode, ...)
    if ICU.IsCallingDisabled() then return end

    local sV = ICU.savedVariables
    -- Activity finder
    if (eventCode == EVENT_ACTIVITY_FINDER_STATUS_UPDATE) then
        if sV.activity then
            local result = ...
            if (result == ACTIVITY_FINDER_STATUS_READY_CHECK and HasLFGReadyCheckNotification()) then
                ICU.RegisterUpdate(EVENT_ACTIVITY_FINDER_STATUS_UPDATE)
            else
                ICU.UnregisterUpdate(EVENT_ACTIVITY_FINDER_STATUS_UPDATE)
            end
        end
    -- Campaign
    elseif (eventCode == EVENT_CAMPAIGN_QUEUE_STATE_CHANGED) then
        if sV.campaign then
            local campaignId, isGroup, state = ...
            if (state == CAMPAIGN_QUEUE_REQUEST_STATE_CONFIRMING) then
                ICU.RegisterUpdate(EVENT_CAMPAIGN_QUEUE_STATE_CHANGED)
            else
                ICU.UnregisterUpdate(EVENT_CAMPAIGN_QUEUE_STATE_CHANGED)
            end
        end
    elseif (eventCode == EVENT_CAMPAIGN_QUEUE_LEFT) then
        ICU.UnregisterUpdate(EVENT_CAMPAIGN_QUEUE_STATE_CHANGED)
    -- Ready check
    elseif (eventCode == EVENT_GROUP_ELECTION_NOTIFICATION_ADDED) then
        if sV.ready then ICU.RegisterUpdate(EVENT_GROUP_ELECTION_NOTIFICATION_ADDED) end
    elseif (eventCode == EVENT_GROUP_ELECTION_NOTIFICATION_REMOVED) then
        if sV.ready then ICU.UnregisterUpdate(EVENT_GROUP_ELECTION_NOTIFICATION_ADDED) end
    -- Quest share
    elseif (eventCode == EVENT_QUEST_SHARED) then
        if sV.share then ICU.RegisterUpdate(EVENT_QUEST_SHARED) end
    elseif (eventCode == EVENT_QUEST_SHARE_REMOVED) then
        if sV.share then ICU.UnregisterUpdate(EVENT_QUEST_SHARED) end
    -- World event
    elseif (eventCode == EVENT_SCRIPTED_WORLD_EVENT_INVITE) then
        if sV.event then ICU.RegisterUpdate(EVENT_SCRIPTED_WORLD_EVENT_INVITE) end
    elseif (eventCode == EVENT_SCRIPTED_WORLD_EVENT_INVITE_REMOVED) then
        if sV.event then ICU.UnregisterUpdate(EVENT_SCRIPTED_WORLD_EVENT_INVITE) end
    -- Friend invite
    elseif (eventCode == EVENT_INCOMING_FRIEND_INVITE_ADDED) then
        if sV.friend then ICU.RegisterUpdate(EVENT_INCOMING_FRIEND_INVITE_ADDED) end
    elseif (eventCode == EVENT_INCOMING_FRIEND_INVITE_REMOVED) then
        if sV.friend then ICU.UnregisterUpdate(EVENT_INCOMING_FRIEND_INVITE_ADDED) end
    -- Guild invite
    elseif (eventCode == EVENT_GUILD_INVITE_ADDED) then
        if sV.guild then ICU.RegisterUpdate(EVENT_GUILD_INVITE_ADDED) end
    elseif (eventCode == EVENT_GUILD_INVITE_REMOVED) then
        if sV.guild then ICU.UnregisterUpdate(EVENT_GUILD_INVITE_ADDED) end
    -- Group invite
    elseif (eventCode == EVENT_GROUP_INVITE_RECEIVED) then
        if sV.group then ICU.RegisterUpdate(EVENT_GROUP_INVITE_RECEIVED) end
    elseif (eventCode == EVENT_GROUP_INVITE_REMOVED) then
        if sV.group then ICU.UnregisterUpdate(EVENT_GROUP_INVITE_RECEIVED) end
    -- Duel invite
    elseif (eventCode == EVENT_DUEL_INVITE_RECEIVED) then
        if sV.duel then ICU.RegisterUpdate(EVENT_DUEL_INVITE_RECEIVED) end
    elseif (eventCode == EVENT_DUEL_INVITE_REMOVED) then
        if sV.duel then ICU.UnregisterUpdate(EVENT_DUEL_INVITE_RECEIVED) end
    -- Trade invite
    elseif (eventCode == EVENT_TRADE_INVITE_CONSIDERING) then
        if sV.trade then ICU.RegisterUpdate(EVENT_TRADE_INVITE_CONSIDERING) end
    elseif (eventCode == EVENT_TRADE_INVITE_REMOVED) then
        if sV.trade then ICU.UnregisterUpdate(EVENT_TRADE_INVITE_CONSIDERING) end
    -- Whisper
    elseif (eventCode == EVENT_CHAT_MESSAGE_CHANNEL) then
        local channelType, _, _, _, fromDisplayName = ...
        if (sV.chat[channelType] and fromDisplayName ~= GetUnitDisplayName("player") and not ICU.isInChat) then
            ICU.RegisterUpdate(EVENT_CHAT_MESSAGE_CHANNEL)
        end
    end

end

--------------------
--INITIALIZE ADDON--
--------------------
-- Register event
function ICU:RegisterEvents()
    local eventList = {
        EVENT_ACTIVITY_FINDER_STATUS_UPDATE,
        EVENT_CAMPAIGN_QUEUE_STATE_CHANGED, EVENT_CAMPAIGN_QUEUE_LEFT,
        EVENT_GROUP_ELECTION_NOTIFICATION_ADDED, EVENT_GROUP_ELECTION_NOTIFICATION_REMOVED,
        EVENT_QUEST_SHARED, EVENT_QUEST_SHARE_REMOVED,
        EVENT_SCRIPTED_WORLD_EVENT_INVITE, EVENT_SCRIPTED_WORLD_EVENT_INVITE_REMOVED,
        EVENT_INCOMING_FRIEND_INVITE_ADDED, EVENT_INCOMING_FRIEND_INVITE_REMOVED,
        EVENT_GUILD_INVITE_ADDED, EVENT_GUILD_INVITE_REMOVED,
        EVENT_GROUP_INVITE_RECEIVED, EVENT_GROUP_INVITE_REMOVED,
        EVENT_DUEL_INVITE_RECEIVED, EVENT_DUEL_INVITE_REMOVED,
        EVENT_TRADE_INVITE_CONSIDERING, EVENT_TRADE_INVITE_REMOVED,
        EVENT_CHAT_MESSAGE_CHANNEL,
    }
    for _, key in ipairs(eventList) do
        EM:RegisterForEvent(ICU.name, key, ICU.OnEventTriggered)
    end
    SLASH_COMMANDS["/icu"] = function()
        for _, key in ipairs(eventList) do
            ICU.UnregisterUpdate(key)
        end
    end
    -- PreHooks
    ZO_PreHook("AcceptLFGReadyCheckNotification", function() ICU.UnregisterUpdate(EVENT_ACTIVITY_FINDER_STATUS_UPDATE) end)
    ZO_PreHook("DeclineLFGReadyCheckNotification", function() ICU.UnregisterUpdate(EVENT_ACTIVITY_FINDER_STATUS_UPDATE) end)
    ZO_PreHook(SCENE_MANAGER, "OnChatInputStart", function()
        ICU.isInChat = true
        ICU.UnregisterUpdate(EVENT_CHAT_MESSAGE_CHANNEL)
    end)
    ZO_PreHook(SCENE_MANAGER, "OnChatInputEnd", function()
        ICU.isInChat = false
        ICU.UnregisterUpdate(EVENT_CHAT_MESSAGE_CHANNEL)
    end)

end

-- Load savedVars
function ICU:Initialize()
    ICU.savedVariables = ZO_SavedVars:NewAccountWide("ICUSavedVars", ICU.variableVersion, nil, ICU.defaultSettings)
    ICU.isCalling = false
    ICU.isInChat = false
    ICU.duration = {}
    ICU.userVolume = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME))
    ICU.userVibration = GetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_VIBRATION) == "1"
    ICU.vibrationIntensity = ICU.savedVariables.vibration / 100
    ICU.seString = SOUNDS[ICU.soundEffects[ICU.savedVariables.se]]

    ICU.CreateSettingsWindow()
    ICU:RegisterEvents()

    EM:UnregisterForEvent(ICU.name, EVENT_ADD_ON_LOADED)
end

-- Addon loaded
function ICU.OnAddOnLoaded(event, addonName)
    if (addonName == ICU.name) then
        ICU:Initialize()
    end
end

EM:RegisterForEvent(ICU.name, EVENT_ADD_ON_LOADED, ICU.OnAddOnLoaded)