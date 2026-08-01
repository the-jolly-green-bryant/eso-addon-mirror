--------------------------------------------------------------------------------
--                   Zolan's Chat Notification (Main)                         --
--------------------------------------------------------------------------------
-- Create main table.
if Zolan_CN == nil then Zolan_CN = {} end

local ZCN = Zolan_CN
-- Create all sub tables.
if ZCN.AddonMenu       == nil then ZCN.AddonMenu       = {} end
if ZCN.AddonMenu.Vars  == nil then ZCN.AddonMenu.Vars  = {} end
if ZCN.Chat            == nil then ZCN.Chat            = {} end
if ZCN.Handler         == nil then ZCN.Handler         = {} end
if ZCN.Notifier        == nil then ZCN.Notifier        = {} end
if ZCN.Notifier.Alerts == nil then ZCN.Notifier.Alerts = {} end
if ZCN.AudioAlert      == nil then ZCN.AudioAlert      = {} end
if ZCN.Util            == nil then ZCN.Util            = {} end
if ZCN.Vars            == nil then ZCN.Vars            = {} end
if ZCN.VisualAlert     == nil then ZCN.VisualAlert     = {} end
if ZCN.VisualAlert.UI  == nil then ZCN.VisualAlert.UI  = {} end

-- ZO
local CHAT_CHANNEL_GUILD_1         = CHAT_CHANNEL_GUILD_1
local CHAT_CHANNEL_GUILD_2         = CHAT_CHANNEL_GUILD_2
local CHAT_CHANNEL_GUILD_3         = CHAT_CHANNEL_GUILD_3
local CHAT_CHANNEL_GUILD_4         = CHAT_CHANNEL_GUILD_4
local CHAT_CHANNEL_GUILD_5         = CHAT_CHANNEL_GUILD_5
local CHAT_CHANNEL_OFFICER_1       = CHAT_CHANNEL_OFFICER_1
local CHAT_CHANNEL_OFFICER_2       = CHAT_CHANNEL_OFFICER_2
local CHAT_CHANNEL_OFFICER_3       = CHAT_CHANNEL_OFFICER_3
local CHAT_CHANNEL_OFFICER_4       = CHAT_CHANNEL_OFFICER_4
local CHAT_CHANNEL_OFFICER_5       = CHAT_CHANNEL_OFFICER_5
local CHAT_CHANNEL_PARTY           = CHAT_CHANNEL_PARTY
local CHAT_CHANNEL_SAY             = CHAT_CHANNEL_SAY
local CHAT_CHANNEL_WHISPER         = CHAT_CHANNEL_WHISPER
local CHAT_CHANNEL_WHISPER_SENT    = CHAT_CHANNEL_WHISPER_SENT
local CHAT_CHANNEL_YELL            = CHAT_CHANNEL_YELL
local CHAT_CHANNEL_ZONE            = CHAT_CHANNEL_ZONE
local CHAT_CHANNEL_ZONE_LANGUAGE_1 = CHAT_CHANNEL_ZONE_LANGUAGE_1
local CHAT_CHANNEL_ZONE_LANGUAGE_2 = CHAT_CHANNEL_ZONE_LANGUAGE_2
local CHAT_CHANNEL_ZONE_LANGUAGE_3 = CHAT_CHANNEL_ZONE_LANGUAGE_3
local SOUNDS                       = SOUNDS
local d                            = d
-- Lua
local pairs                        = pairs

function ZCN.loadVariables()
    ---------------------------------------------------
    ---------------------------------------------------
    ----  APP VERSION DO NOT FORGET TO CHANGE!!!!!!! --
    ---------------------------------------------------
    ---------------------------------------------------
    ZCN.appVersion         = '2.12'
    ZCN.addonName          = 'Zolan_ChatNotifications'

    ZCN.Vars.headerColor        = "|c88DDFF" -- Light Blue
    ZCN.Vars.defaultColor       = "|cFFFFFF" -- White
    ZCN.Vars.currencyColor      = "|cFFD700" -- Gold

    ZCN.Vars.outputHeader       = ZCN.Vars.headerColor .. "Zolan's Chat Notifications:"

    ZCN.Vars.savedVariablesName = 'Zolan_CN_SavedVariables'
    ZCN.Vars.configVersion      = 5
    ZCN.Vars.configNamespace    = 'CN'

    ZCN.Vars.configDefaults = {
        ["configVersion"]     = ZCN.configVersion,
        ["debug"]             = false,
        ["keyWords"]          = '',
        ["playerBlacklist"]   = '',
        -- Intend to add a visual notification at some point.
        ["audio"] = {
            ["enabled"]    = true,
            --
            ["onMyChat"]   = { ["enabled"] = true,  ["sound"] = SOUNDS.BOOK_ACQUIRED },
            ["onMyName"]   = { ["enabled"] = true,  ["sound"] = SOUNDS.BOOK_ACQUIRED },
            ["onKeyWords"] = { ["enabled"] = true,  ["sound"] = SOUNDS.BOOK_ACQUIRED },
            --
            ["onWhisper"]  = { ["enabled"] = true,  ["sound"] = SOUNDS.BOOK_ACQUIRED },
            ["onParty"]    = { ["enabled"] = true,  ["sound"] = SOUNDS.BOOK_ACQUIRED },
            ["onFriend"]   = { ["enabled"] = true,  ["sound"] = SOUNDS.BOOK_ACQUIRED },
            ["onGuild1"]   = { ["enabled"] = true,  ["sound"] = SOUNDS.BOOK_ACQUIRED },
            ["onGuild2"]   = { ["enabled"] = true,  ["sound"] = SOUNDS.BOOK_ACQUIRED },
            ["onGuild3"]   = { ["enabled"] = true,  ["sound"] = SOUNDS.BOOK_ACQUIRED },
            ["onGuild4"]   = { ["enabled"] = true,  ["sound"] = SOUNDS.BOOK_ACQUIRED },
            ["onGuild5"]   = { ["enabled"] = true,  ["sound"] = SOUNDS.BOOK_ACQUIRED },
            ["onSay"]      = { ["enabled"] = false, ["sound"] = SOUNDS.NONE          },
            ["onZone"]     = { ["enabled"] = false, ["sound"] = SOUNDS.NONE          },
            ["onYell"]     = { ["enabled"] = false, ["sound"] = SOUNDS.NONE          }
        }
        -- ["visual"] = {
        --     ["enabled"]    = true,
        --     --
        --     ["onMyChat"]   = { ["enabled"] = true,  ["sound"] = SOUNDS.BOOK_ACQUIRED },
        --     ["onMyName"]   = { ["enabled"] = true,  ["sound"] = SOUNDS.BOOK_ACQUIRED },
        --     ["onKeyWords"] = { ["enabled"] = true,  ["sound"] = SOUNDS.BOOK_ACQUIRED },
        --     --
        --     ["onWhisper"]  = { ["enabled"] = true,  ["sound"] = SOUNDS.BOOK_ACQUIRED },
        --     ["onParty"]    = { ["enabled"] = true,  ["sound"] = SOUNDS.BOOK_ACQUIRED },
        --     ["onFriend"]   = { ["enabled"] = true,  ["sound"] = SOUNDS.BOOK_ACQUIRED },
        --     ["onGuild1"]   = { ["enabled"] = true,  ["sound"] = SOUNDS.BOOK_ACQUIRED },
        --     ["onGuild2"]   = { ["enabled"] = true,  ["sound"] = SOUNDS.BOOK_ACQUIRED },
        --     ["onGuild3"]   = { ["enabled"] = true,  ["sound"] = SOUNDS.BOOK_ACQUIRED },
        --     ["onGuild4"]   = { ["enabled"] = true,  ["sound"] = SOUNDS.BOOK_ACQUIRED },
        --     ["onGuild5"]   = { ["enabled"] = true,  ["sound"] = SOUNDS.BOOK_ACQUIRED },
        --     ["onSay"]      = { ["enabled"] = false, ["sound"] = SOUNDS.NONE          },
        --     ["onZone"]     = { ["enabled"] = false, ["sound"] = SOUNDS.NONE          },
        --     ["onYell"]     = { ["enabled"] = false, ["sound"] = SOUNDS.NONE          }
        -- }
    }

    ZCN.Vars.channelIDToNameXref = {
        [CHAT_CHANNEL_GUILD_1]         = 'Guild1',
        [CHAT_CHANNEL_GUILD_2]         = 'Guild2',
        [CHAT_CHANNEL_GUILD_3]         = 'Guild3',
        [CHAT_CHANNEL_GUILD_4]         = 'Guild4',
        [CHAT_CHANNEL_GUILD_5]         = 'Guild5',
        [CHAT_CHANNEL_OFFICER_1]       = 'Guild1',
        [CHAT_CHANNEL_OFFICER_2]       = 'Guild2',
        [CHAT_CHANNEL_OFFICER_3]       = 'Guild3',
        [CHAT_CHANNEL_OFFICER_4]       = 'Guild4',
        [CHAT_CHANNEL_OFFICER_5]       = 'Guild5',
        [CHAT_CHANNEL_PARTY]           = 'Party',
        [CHAT_CHANNEL_SAY]             = 'Say',
        [CHAT_CHANNEL_WHISPER]         = 'Whisper',
        [CHAT_CHANNEL_WHISPER_SENT]    = 'WhisperSent',
        [CHAT_CHANNEL_YELL]            = 'Yell',
        [CHAT_CHANNEL_ZONE]            = 'Zone',
        [CHAT_CHANNEL_ZONE_LANGUAGE_1] = 'Zone',
        [CHAT_CHANNEL_ZONE_LANGUAGE_2] = 'Zone',
        [CHAT_CHANNEL_ZONE_LANGUAGE_3] = 'Zone'
    }

    local profile = nil
    ZCN.savedVars = ZO_SavedVars:New(
        ZCN.Vars.savedVariablesName,
        ZCN.Vars.configVersion,
        ZCN.Vars.configNamespace,
        ZCN.Vars.configDefaults,
        profile
    )

    ZCN.migrateSettings()
    ZCN.defaultMissingSettings()
    ZCN.removeVestigialSettings()

    ZCN.loaded = true
end

function ZCN.migrateSettings()
    -- Nothing for now.
end

function ZCN.defaultMissingSettings()
    for key, value in pairs(ZCN.Vars.configDefaults) do
        if ZCN.savedVars[key] == nil then
            ZCN.savedVars[key] = value
        end
    end
end

function ZCN.removeVestigialSettings()
    for key, value in pairs(ZCN.savedVars) do
        if ZCN.Vars.configDefaults[key] == nil then
            ZCN.savedVars[key] = nil
        end
    end
end

function ZCN.debug(message, isRaw)
    if ZCN.savedVars.debug ~= nil and ZCN.savedVars.debug then
        if isRaw then
            d(message)
        else
            d("ZCN: " .. message)
        end
    end
end
