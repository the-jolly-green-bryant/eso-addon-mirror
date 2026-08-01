ICU = ICU or {}
local ICU = ICU

function ICU.CreateSettingsWindow()
    local LAM2 = LibAddonMenu2
    local panelData = {
        type = "panel",
        name = "I'm Calling U",
        displayName = "I'm Calling U",
        author = "@tdenc",
        version = ICU.version,
        slashCommand = "/icusetting",
        registerForRefresh = true,
        registerForDefaults = true,
        website = "https://www.esoui.com/downloads/info3147-ImCallingU-Dontmissnotification.html",
    }
    local cntrlOptionsPanel = LAM2:RegisterAddonPanel("ICU_Settings", panelData)

    local choices = {[1] = GetString(SI_CHECK_BUTTON_OFF)}
    for i = 2, #ICU.soundEffects do
        choices[i] = string.format("%i", i - 1)
    end
    local choicesValues = {}
    for i = 1, #ICU.soundEffects do
        choicesValues[i] = i
    end

    local function trialListening()
        ICU.RegisterUpdate(-1)
        zo_callLater(function()
            ICU.UnregisterUpdate(-1)
        end, 3000)
    end
    local dS = ICU.defaultSettings
    local sV = ICU.savedVariables
    local guildNames = {
        [1] = GetGuildName(GetGuildId(1)),
        [2] = GetGuildName(GetGuildId(2)),
        [3] = GetGuildName(GetGuildId(3)),
        [4] = GetGuildName(GetGuildId(4)),
        [5] = GetGuildName(GetGuildId(5)),
    }
    local optionsData = {
        {
            ["type"] = "header",
            ["name"] = GetString(SI_SETTINGSYSTEMPANEL0),
        },
        {
            ["type"] = "dropdown",
            ["name"] = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES103),
            ["choices"] = choices,
            ["choicesValues"] = choicesValues,
            ["default"] = dS.se,
            ["getFunc"] = function() return sV.se end,
            ["setFunc"] = function(newValue)
                sV.se = newValue
                ICU.seString = SOUNDS[ICU.soundEffects[newValue]]
                trialListening()
            end,
            ["width"] = "half",
        },
        {
            ["type"] = "slider",
            ["min"] = 0,
            ["max"] = 100,
            ["default"] = dS.volume,
            ["getFunc"] = function() return sV.volume end,
            ["setFunc"] = function(newValue)
                sV.volume = newValue
                trialListening()
            end,
            ["disabled"] = function() return sV.se == 1 end,
            ["width"] = "half",
        },
        {
            ["type"] = "header",
            ["name"] = GetString(SI_GAMEPAD_SECTION_HEADER),
        },
        {
            ["type"] = "checkbox",
            ["name"] = GetString(SI_OPTIONS_VIBRATION_GAMEPAD),
            ["default"] = GetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_VIBRATION) == "1",
            ["getFunc"] = function() return GetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_VIBRATION) == "1" end,
            ["setFunc"] = function(newValue)
                ICU.userVibration = newValue
                if newValue then
                    SetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_VIBRATION, "1")
                else
                    SetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_VIBRATION, "0")
                end
            end,
            ["width"] = "half",
        },
        {
            ["type"] = "slider",
            ["min"] = 0,
            ["max"] = 100,
            ["default"] = dS.vibration,
            ["getFunc"] = function() return sV.vibration end,
            ["setFunc"] = function(newValue)
                sV.vibration = newValue
                ICU.vibrationIntensity = newValue / 100
                trialListening()
            end,
            ["disabled"] = function() return GetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_VIBRATION) == "0" end,
            ["width"] = "half",
        },
        {
            ["type"] = "header",
            ["name"] = GetString(SI_PATHFOLLOWTYPE1),
        },
        {
            ["type"] = "checkbox",
            ["name"] = "∞",
            ["default"] = dS.infinity,
            ["getFunc"] = function() return sV.infinity end,
            ["setFunc"] = function(newValue) sV.infinity = newValue end,
            ["disabled"] = function() return ICU.IsCallingDisabled() end,
            ["width"] = "half",
        },
        {
            ["type"] = "slider",
            ["name"] = string.format("%s (%s)", GetString(SI_ABILITY_TOOLTIP_DURATION_LABEL), zo_strformat(GetString(SI_STR_TIME_DESC_SECONDS_ONLY_SHORT))),
            ["min"] = 2,
            ["max"] = 600,
            ["step"] = 2,
            ["default"] = dS.duration,
            ["getFunc"] = function() return sV.duration end,
            ["setFunc"] = function(newValue) sV.duration = newValue end,
            ["disabled"] = function() return ICU.IsCallingDisabled() or sV.infinity end,
            ["width"] = "half",
        },
        {
            ["type"] = "header",
            ["name"] = GetString(SI_GAMEPAD_CONTACTS_STATUS_DO_NOT_DISTURB),
        },
        {
            ["type"] = "checkbox",
            ["name"] = GetString(SI_AUDIO_OPTIONS_COMBAT),
            ["default"] = dS.combat,
            ["getFunc"] = function() return sV.combat end,
            ["setFunc"] = function(newValue) sV.combat = newValue end,
            ["disabled"] = function() return ICU.IsCallingDisabled() end,
            ["width"] = "half",
        },
        {
            ["type"] = "checkbox",
            ["name"] = GetString(SI_GUILDFOCUSATTRIBUTEVALUE5),
            ["default"] = dS.pvp,
            ["getFunc"] = function() return sV.pvp end,
            ["setFunc"] = function(newValue) sV.pvp = newValue end,
            ["disabled"] = function() return ICU.IsCallingDisabled() end,
            ["width"] = "half",
        },
        {
            type = "submenu", name = GetString(SI_SOCIAL_OPTIONS_NOTIFICATIONS), controls = {
                {
                    ["type"] = "checkbox",
                    ["name"] = GetString(SI_MAIN_MENU_ACTIVITY_FINDER),
                    ["default"] = dS.activity,
                    ["getFunc"] = function() return sV.activity end,
                    ["setFunc"] = function(newValue) sV.activity = newValue end,
                    ["disabled"] = function() return ICU.IsCallingDisabled() end,
                },
                {
                    ["type"] = "checkbox",
                    ["name"] = string.format("%s / %s", GetString(SI_ACTIVITYFINDERSTATUS4), GetString(SI_NOTIFICATIONTYPE16)),
                    ["default"] = dS.ready,
                    ["getFunc"] = function() return sV.ready end,
                    ["setFunc"] = function(newValue) sV.ready = newValue end,
                    ["disabled"] = function() return ICU.IsCallingDisabled() end,
                },
                {
                    ["type"] = "checkbox",
                    ["name"] = string.format("%s (%s / %s)", GetString(SI_PLAYER_MENU_CAMPAIGNS), GetString(SI_CAMPAIGNRULESETTYPE1), GetString(SI_CAMPAIGNRULESETTYPE4)),
                    ["default"] = dS.campaign,
                    ["getFunc"] = function() return sV.campaign end,
                    ["setFunc"] = function(newValue) sV.campaign = newValue end,
                    ["disabled"] = function() return ICU.IsCallingDisabled() end,
                },
                {
                    ["type"] = "checkbox",
                    ["name"] = GetString(SI_PROMPT_TITLE_SHARE_QUEST),
                    ["default"] = dS.share,
                    ["getFunc"] = function() return sV.share end,
                    ["setFunc"] = function(newValue) sV.share = newValue end,
                    ["disabled"] = function() return ICU.IsCallingDisabled() end,
                },
                {
                    ["type"] = "checkbox",
                    ["name"] = GetString(SI_ZONECOMPLETIONTYPE8),
                    ["default"] = dS.event,
                    ["getFunc"] = function() return sV.event end,
                    ["setFunc"] = function(newValue) sV.event = newValue end,
                    ["disabled"] = function() return ICU.IsCallingDisabled() end,
                },
                {
                    ["type"] = "checkbox",
                    ["name"] = GetString(SI_NOTIFICATION_FRIEND_INVITE),
                    ["default"] = dS.friend,
                    ["getFunc"] = function() return sV.friend end,
                    ["setFunc"] = function(newValue) sV.friend = newValue end,
                    ["disabled"] = function() return ICU.IsCallingDisabled() end,
                },
                {
                    ["type"] = "checkbox",
                    ["name"] = GetString(SI_NOTIFICATION_GUILD_INVITE),
                    ["default"] = dS.guild,
                    ["getFunc"] = function() return sV.guild end,
                    ["setFunc"] = function(newValue) sV.guild = newValue end,
                    ["disabled"] = function() return ICU.IsCallingDisabled() end,
                },
                {
                    ["type"] = "checkbox",
                    ["name"] = GetString(SI_NOTIFICATION_GROUP_INVITE),
                    ["default"] = dS.group,
                    ["getFunc"] = function() return sV.group end,
                    ["setFunc"] = function(newValue) sV.group = newValue end,
                    ["disabled"] = function() return ICU.IsCallingDisabled() end,
                },
                {
                    ["type"] = "checkbox",
                    ["name"] = GetString(SI_NOTIFICATION_DUEL_INVITE),
                    ["default"] = dS.duel,
                    ["getFunc"] = function() return sV.duel end,
                    ["setFunc"] = function(newValue) sV.duel = newValue end,
                    ["disabled"] = function() return ICU.IsCallingDisabled() end,
                },
                {
                    ["type"] = "checkbox",
                    ["name"] = GetString(SI_PROMPT_TITLE_TRADE_INVITE_PROMPT),
                    ["default"] = dS.trade,
                    ["getFunc"] = function() return sV.trade end,
                    ["setFunc"] = function(newValue) sV.trade = newValue end,
                    ["disabled"] = function() return ICU.IsCallingDisabled() end,
                },
            },
        },
        {
            type = "submenu", name = GetString(SI_CHAT_TAB_GENERAL), controls = {
                {
                    ["type"] = "checkbox",
                    ["name"] = GetString(SI_CHATCHANNELCATEGORIES3),
                    ["default"] = dS.chat[CHAT_CHANNEL_WHISPER],
                    ["getFunc"] = function() return sV.chat[CHAT_CHANNEL_WHISPER] end,
                    ["setFunc"] = function(newValue) sV.chat[CHAT_CHANNEL_WHISPER] = newValue end,
                    ["disabled"] = function() return ICU.IsCallingDisabled() end,
                },
                {
                    ["type"] = "checkbox",
                    ["name"] = GetString(SI_CHATCHANNELCATEGORIES2),
                    ["default"] = dS.chat[CHAT_CHANNEL_YELL],
                    ["getFunc"] = function() return sV.chat[CHAT_CHANNEL_YELL] end,
                    ["setFunc"] = function(newValue) sV.chat[CHAT_CHANNEL_YELL] = newValue end,
                    ["disabled"] = function() return ICU.IsCallingDisabled() end,
                },
                {
                    ["type"] = "checkbox",
                    ["name"] = GetString(SI_CHATCHANNELCATEGORIES1),
                    ["default"] = dS.chat[CHAT_CHANNEL_SAY],
                    ["getFunc"] = function() return sV.chat[CHAT_CHANNEL_SAY] end,
                    ["setFunc"] = function(newValue) sV.chat[CHAT_CHANNEL_SAY] = newValue end,
                    ["disabled"] = function() return ICU.IsCallingDisabled() end,
                },
                {
                    ["type"] = "checkbox",
                    ["name"] = GetString(SI_CHATCHANNELCATEGORIES7),
                    ["default"] = dS.chat[CHAT_CHANNEL_PARTY],
                    ["getFunc"] = function() return sV.chat[CHAT_CHANNEL_PARTY] end,
                    ["setFunc"] = function(newValue) sV.chat[CHAT_CHANNEL_PARTY] = newValue end,
                    ["disabled"] = function() return ICU.IsCallingDisabled() end,
                },
                {
                    ["type"] = "checkbox",
                    ["name"] = string.format("%s (%s)", GetString(SI_CHATCHANNELCATEGORIES10), guildNames[1]),
                    ["default"] = dS.chat[CHAT_CHANNEL_GUILD_1],
                    ["getFunc"] = function() return sV.chat[CHAT_CHANNEL_GUILD_1] end,
                    ["setFunc"] = function(newValue) sV.chat[CHAT_CHANNEL_GUILD_1] = newValue end,
                    ["disabled"] = function() return ICU.IsCallingDisabled() or guildNames[1] == "" end,
                },
                {
                    ["type"] = "checkbox",
                    ["name"] = string.format("%s (%s)", GetString(SI_CHATCHANNELCATEGORIES11), guildNames[2]),
                    ["default"] = dS.chat[CHAT_CHANNEL_GUILD_2],
                    ["getFunc"] = function() return sV.chat[CHAT_CHANNEL_GUILD_2] end,
                    ["setFunc"] = function(newValue) sV.chat[CHAT_CHANNEL_GUILD_2] = newValue end,
                    ["disabled"] = function() return ICU.IsCallingDisabled() or guildNames[2] == "" end,
                },
                {
                    ["type"] = "checkbox",
                    ["name"] = string.format("%s (%s)", GetString(SI_CHATCHANNELCATEGORIES12), guildNames[3]),
                    ["default"] = dS.chat[CHAT_CHANNEL_GUILD_3],
                    ["getFunc"] = function() return sV.chat[CHAT_CHANNEL_GUILD_3] end,
                    ["setFunc"] = function(newValue) sV.chat[CHAT_CHANNEL_GUILD_3] = newValue end,
                    ["disabled"] = function() return ICU.IsCallingDisabled() or guildNames[3] == "" end,
                },
                {
                    ["type"] = "checkbox",
                    ["name"] = string.format("%s (%s)", GetString(SI_CHATCHANNELCATEGORIES13), guildNames[4]),
                    ["default"] = dS.chat[CHAT_CHANNEL_GUILD_4],
                    ["getFunc"] = function() return sV.chat[CHAT_CHANNEL_GUILD_4] end,
                    ["setFunc"] = function(newValue) sV.chat[CHAT_CHANNEL_GUILD_4] = newValue end,
                    ["disabled"] = function() return ICU.IsCallingDisabled() or guildNames[4] == "" end,
                },
                {
                    ["type"] = "checkbox",
                    ["name"] = string.format("%s (%s)", GetString(SI_CHATCHANNELCATEGORIES14), guildNames[5]),
                    ["default"] = dS.chat[CHAT_CHANNEL_GUILD_5],
                    ["getFunc"] = function() return sV.chat[CHAT_CHANNEL_GUILD_5] end,
                    ["setFunc"] = function(newValue) sV.chat[CHAT_CHANNEL_GUILD_5] = newValue end,
                    ["disabled"] = function() return ICU.IsCallingDisabled() or guildNames[5] == "" end,
                },
                {
                    ["type"] = "checkbox",
                    ["name"] = string.format("%s (%s)", GetString(SI_CHATCHANNELCATEGORIES15), guildNames[1]),
                    ["default"] = dS.chat[CHAT_CHANNEL_OFFICER_1],
                    ["getFunc"] = function() return sV.chat[CHAT_CHANNEL_OFFICER_1] end,
                    ["setFunc"] = function(newValue) sV.chat[CHAT_CHANNEL_OFFICER_1] = newValue end,
                    ["disabled"] = function() return ICU.IsCallingDisabled() or guildNames[1] == "" end,
                },
                {
                    ["type"] = "checkbox",
                    ["name"] = string.format("%s (%s)", GetString(SI_CHATCHANNELCATEGORIES16), guildNames[2]),
                    ["default"] = dS.chat[CHAT_CHANNEL_OFFICER_2],
                    ["getFunc"] = function() return sV.chat[CHAT_CHANNEL_OFFICER_2] end,
                    ["setFunc"] = function(newValue) sV.chat[CHAT_CHANNEL_OFFICER_2] = newValue end,
                    ["disabled"] = function() return ICU.IsCallingDisabled() or guildNames[2] == "" end,
                },
                {
                    ["type"] = "checkbox",
                    ["name"] = string.format("%s (%s)", GetString(SI_CHATCHANNELCATEGORIES17), guildNames[3]),
                    ["default"] = dS.chat[CHAT_CHANNEL_OFFICER_3],
                    ["getFunc"] = function() return sV.chat[CHAT_CHANNEL_OFFICER_3] end,
                    ["setFunc"] = function(newValue) sV.chat[CHAT_CHANNEL_OFFICER_3] = newValue end,
                    ["disabled"] = function() return ICU.IsCallingDisabled() or guildNames[3] == "" end,
                },
                {
                    ["type"] = "checkbox",
                    ["name"] = string.format("%s (%s)", GetString(SI_CHATCHANNELCATEGORIES18), guildNames[4]),
                    ["default"] = dS.chat[CHAT_CHANNEL_OFFICER_4],
                    ["getFunc"] = function() return sV.chat[CHAT_CHANNEL_OFFICER_4] end,
                    ["setFunc"] = function(newValue) sV.chat[CHAT_CHANNEL_OFFICER_4] = newValue end,
                    ["disabled"] = function() return ICU.IsCallingDisabled() or guildNames[4] == "" end,
                },
                {
                    ["type"] = "checkbox",
                    ["name"] = string.format("%s (%s)", GetString(SI_CHATCHANNELCATEGORIES19), guildNames[5]),
                    ["default"] = dS.chat[CHAT_CHANNEL_OFFICER_5],
                    ["getFunc"] = function() return sV.chat[CHAT_CHANNEL_OFFICER_5] end,
                    ["setFunc"] = function(newValue) sV.chat[CHAT_CHANNEL_OFFICER_5] = newValue end,
                    ["disabled"] = function() return ICU.IsCallingDisabled() or guildNames[5] == "" end,
                },
                {
                    ["type"] = "checkbox",
                    ["name"] = GetString(SI_CHATCHANNELCATEGORIES6),
                    ["default"] = dS.chat[CHAT_CHANNEL_ZONE],
                    ["getFunc"] = function() return sV.chat[CHAT_CHANNEL_ZONE] end,
                    ["setFunc"] = function(newValue) sV.chat[CHAT_CHANNEL_ZONE] = newValue end,
                    ["disabled"] = function() return ICU.IsCallingDisabled() end,
                },
                {
                    ["type"] = "checkbox",
                    ["name"] = GetString(SI_CHATCHANNELCATEGORIES20),
                    ["default"] = dS.chat[CHAT_CHANNEL_ZONE_LANGUAGE_1],
                    ["getFunc"] = function() return sV.chat[CHAT_CHANNEL_ZONE_LANGUAGE_1] end,
                    ["setFunc"] = function(newValue) sV.chat[CHAT_CHANNEL_ZONE_LANGUAGE_1] = newValue end,
                    ["disabled"] = function() return ICU.IsCallingDisabled() end,
                },
                {
                    ["type"] = "checkbox",
                    ["name"] = GetString(SI_CHATCHANNELCATEGORIES21),
                    ["default"] = dS.chat[CHAT_CHANNEL_ZONE_LANGUAGE_2],
                    ["getFunc"] = function() return sV.chat[CHAT_CHANNEL_ZONE_LANGUAGE_2] end,
                    ["setFunc"] = function(newValue) sV.chat[CHAT_CHANNEL_ZONE_LANGUAGE_2] = newValue end,
                    ["disabled"] = function() return ICU.IsCallingDisabled() end,
                },
                {
                    ["type"] = "checkbox",
                    ["name"] = GetString(SI_CHATCHANNELCATEGORIES22),
                    ["default"] = dS.chat[CHAT_CHANNEL_ZONE_LANGUAGE_3],
                    ["getFunc"] = function() return sV.chat[CHAT_CHANNEL_ZONE_LANGUAGE_3] end,
                    ["setFunc"] = function(newValue) sV.chat[CHAT_CHANNEL_ZONE_LANGUAGE_3] = newValue end,
                    ["disabled"] = function() return ICU.IsCallingDisabled() end,
                },
                {
                    ["type"] = "checkbox",
                    ["name"] = GetString(SI_CHATCHANNELCATEGORIES23),
                    ["default"] = dS.chat[CHAT_CHANNEL_ZONE_LANGUAGE_4],
                    ["getFunc"] = function() return sV.chat[CHAT_CHANNEL_ZONE_LANGUAGE_4] end,
                    ["setFunc"] = function(newValue) sV.chat[CHAT_CHANNEL_ZONE_LANGUAGE_4] = newValue end,
                    ["disabled"] = function() return ICU.IsCallingDisabled() end,
                },
                {
                    ["type"] = "checkbox",
                    ["name"] = GetString(SI_CHATCHANNELCATEGORIES24),
                    ["default"] = dS.chat[CHAT_CHANNEL_ZONE_LANGUAGE_5],
                    ["getFunc"] = function() return sV.chat[CHAT_CHANNEL_ZONE_LANGUAGE_5] end,
                    ["setFunc"] = function(newValue) sV.chat[CHAT_CHANNEL_ZONE_LANGUAGE_5] = newValue end,
                    ["disabled"] = function() return ICU.IsCallingDisabled() end,
                },
                {
                    ["type"] = "checkbox",
                    ["name"] = GetString(SI_CHATCHANNELCATEGORIES9),
                    ["default"] = dS.chat[CHAT_CHANNEL_SYSTEM],
                    ["getFunc"] = function() return sV.chat[CHAT_CHANNEL_SYSTEM] end,
                    ["setFunc"] = function(newValue) sV.chat[CHAT_CHANNEL_SYSTEM] = newValue end,
                    ["disabled"] = function() return ICU.IsCallingDisabled() end,
                },
            },
        },

    }
    LAM2:RegisterOptionControls("ICU_Settings", optionsData)
end
