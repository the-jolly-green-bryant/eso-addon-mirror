-- ============================================================================
-- AetherChat : Settings & LibAddonMenu-2.0 Data Manager (Clean & Streamlined)
-- ============================================================================
AetherChat = AetherChat or {}
local AetherChat = AetherChat

AetherChat.Settings = {}
local Settings = AetherChat.Settings

local DEFAULTS = {
    version = 2,
    language = 'auto',
    enableFloatingIcon = true,
    hideOfficialChat = false,
    backdropAlpha = 95,
    sidebarCollapsed = false,
    autoHideOnGameMenu = true,
    chatFontSize = 16,
    soundOnWhisper = true,
    whisperSound = 'champion',
    persistHistory = true,
    historyRetention = 604800, -- 1 week in seconds
    maxHistory = 150,
    activeTheme = 'skyrim_nordic',
    needTemplate = 'LF <<item>> please :)',
    showBadgeMessages = true,
    showBadgeFriends = true,
    showBadgeMail = true,
    notifyWhispers = true,
    notifyGuilds = true,
    notifyParty = true,
    notifyFriendStatus = true,
    notifyGuildStatus = false,
    notifyGuild_1 = true,
    notifyGuild_2 = true,
    notifyGuild_3 = true,
    notifyGuild_4 = true,
    notifyGuild_5 = true,
    notifySales = true,
    guildsExpanded = false,
    -- Keywords & Mentions
    keywordEnable = true,
    keywordList = '',
    keywordSound = 'champion',
    keywordColor = 'FFD700',
    floatingIconPos = nil,
    windowPos = nil,
    windowDimensions = { width = 940, height = 520 },
    history = {},
    channelOrder = {},
    processedSalesMails = {},  -- persisted across sessions to avoid double-fire
}

function AetherChat.SendInGameDonation()
    if SCENE_MANAGER then
        SCENE_MANAGER:Show('mailSend')
    elseif MAIN_MENU_KEYBOARD then
        MAIN_MENU_KEYBOARD:ShowSceneGroup('mailSceneGroup', 'mailSend')
    end

    zo_callLater(function()
        if ZO_MailSendToField then
            ZO_MailSendToField:SetText('@AlexQuiet')
        end
        if ZO_MailSendSubjectField then
            ZO_MailSendSubjectField:SetText('Don AetherChat')
        end
        if ZO_MailSendBodyField then
            ZO_MailSendBodyField:SetText('')
        end
    end, 200)
end

function Settings.Initialize()
    local worldName = GetWorldName()
    AetherChat.savedVars = ZO_SavedVars:NewAccountWide('AetherChat_SavedVariables', 2, nil, DEFAULTS, worldName)
    Settings.data = AetherChat.savedVars

    -- Guarantee all missing keys from DEFAULTS are migrated into existing savedVars profile
    for k, v in pairs(DEFAULTS) do
        if Settings.data[k] == nil and v ~= nil then
            if type(v) == "table" then
                Settings.data[k] = ZO_DeepTableCopy(v)
            else
                Settings.data[k] = v
            end
        end
    end

    if not Settings.data.history then
        Settings.data.history = {}
    end

    if not Settings.data.channelOrder then
        Settings.data.channelOrder = {}
    end

    if not Settings.data.windowDimensions then
        Settings.data.windowDimensions = { width = 940, height = 520 }
    end

    -- Prune expired history messages on startup
    if AetherChat.History and AetherChat.History.PruneExpiredMessages then
        AetherChat.History.PruneExpiredMessages()
    end

    Settings.RegisterLAM()
end

function Settings.Get(key, default)
    if Settings.data and Settings.data[key] ~= nil then
        return Settings.data[key]
    end
    return default
end

function Settings.Set(key, value)
    if Settings.data then
        Settings.data[key] = value
    end
    if AetherChat.savedVars then
        AetherChat.savedVars[key] = value
    end
end

function Settings.GetChannelOrder()
    return Settings.data and Settings.data.channelOrder or {}
end

function Settings.SetChannelOrder(order)
    if Settings.data then
        Settings.data.channelOrder = order
    end
end

function Settings.OpenSettingsPanel()
    if LibAddonMenu2 and Settings.panel then
        LibAddonMenu2:OpenToPanel(Settings.panel)
    end
end

function Settings.RegisterLAM()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local L = AetherChat.L

    local panelData = {
        type = "panel",
        name = "AetherChat",
        displayName = "|cE5B558AETHER|r|cFFFFFFCHAT|r",
        author = "|cE5B558@AlexQuiet|r",
        version = "1.2.4",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    Settings.panel = LAM:RegisterAddonPanel("AetherChat_LAM_Panel", panelData)

    local langChoices = {
        'Automatique (Selon ESO / Auto-detect)',
        'Français',
        'English',
    }

    local langKeys = {
        'auto',
        'fr',
        'en',
    }

    local themeChoices = {
        'Skyrim Dragonborn (Givre & Souffle de Dragon)',
        'Dwemer Gold (Machines & Bronze Antique)',
        'Nordic Emerald (Forêts de Bordeciel & Jade)',
        'Crimson Brotherhood (Confrérie Noire & Sanctuaire)',
        'Dark Glass (Moderne Épuré)',
    }

    local themeKeys = {
        'skyrim_nordic',
        'gold_dwemer',
        'emerald_nordic',
        'ruby_crimson',
        'dark_glass',
    }

    local soundChoices = {
        'Carillon Céleste (Point Champion - Fort & Cristallin)',
        'Notification Nette (Ding Moderne & Clair)',
        'Fanfare Dorée (Succès / Triomphe)',
        'Résonance Magique (Cloche Mystique)',
        'Gong de Combat (Cloche de Défi)',
        'Harmonie de Quête (Cors & Cloches)',
        'Chuchotement Discret (Son d\'origine ESO)',
    }

    local soundKeys = {
        'champion',
        'notification_ding',
        'achievement',
        'magic_bell',
        'gong',
        'quest',
        'default_whisper',
    }

    local retentionChoices = {
        '1 jour (24h) / 1 day',
        '3 jours (72h) / 3 days',
        '1 semaine (7 jours) / 1 week',
        '1 mois (30 jours) / 1 month',
        'Illimité (Jamais) / Unlimited',
    }

    local retentionValues = {
        86400,
        259200,
        604800,
        2592000,
        0,
    }

    local keywordColorChoices = {
        L('COLOR_GOLD'),
        L('COLOR_PINK'),
        L('COLOR_CYAN'),
        L('COLOR_GREEN'),
        L('COLOR_ORANGE'),
        L('COLOR_PURPLE'),
        L('COLOR_YELLOW'),
    }

    local keywordColorValues = {
        'FFD700',
        'F43F5E',
        '38BDF8',
        '10B981',
        'FB923C',
        'A855F7',
        'FACC15',
    }

    local optionsData = {
        {
            type = "description",
            text = L('SET_INTRO_DESC'),
        },
        {
            type = "header",
            name = L('SET_LANG_HEADER'),
        },
        {
            type = "dropdown",
            name = L('SET_LANG_LABEL'),
            tooltip = L('SET_LANG_TT'),
            choices = langChoices,
            choicesValues = langKeys,
            getFunc = function() return Settings.Get('language', 'auto') end,
            setFunc = function(value)
                Settings.Set('language', value)
                if AetherChat.Messenger and AetherChat.Messenger.RefreshChannelList then
                    AetherChat.Messenger.RefreshChannelList()
                end
                if AetherChat.Theme and AetherChat.Theme.ApplyTheme then
                    AetherChat.Theme.ApplyTheme(Settings.Get('activeTheme', 'skyrim_nordic'))
                end
            end,
            default = 'auto',
        },
        {
            type = "button",
            name = "|c38BDF8" .. L('SET_LANG_RELOAD_BTN') .. "|r",
            tooltip = L('SET_LANG_RELOAD_TT'),
            func = function()
                ReloadUI()
            end,
            width = "full",
        },
        {
            type = "header",
            name = L('SET_THEME_HEADER'),
        },
        {
            type = "dropdown",
            name = L('SET_THEME_LABEL'),
            tooltip = L('SET_THEME_TT'),
            choices = themeChoices,
            choicesValues = themeKeys,
            getFunc = function() return Settings.Get('activeTheme', 'skyrim_nordic') end,
            setFunc = function(value)
                Settings.Set('activeTheme', value)
                if AetherChat.Theme and AetherChat.Theme.ApplyTheme then
                    AetherChat.Theme.ApplyTheme(value)
                end
            end,
            default = 'skyrim_nordic',
        },
        {
            type = "header",
            name = L('SET_SOUND_HEADER'),
        },
        {
            type = "checkbox",
            name = L('SET_SOUND_ENABLE'),
            tooltip = L('SET_SOUND_ENABLE_TT'),
            getFunc = function() return Settings.Get('soundOnWhisper', true) end,
            setFunc = function(value) Settings.Set('soundOnWhisper', value) end,
            default = true,
        },
        {
            type = "dropdown",
            name = L('SET_SOUND_SELECT'),
            tooltip = L('SET_SOUND_SELECT_TT'),
            choices = soundChoices,
            choicesValues = soundKeys,
            getFunc = function() return Settings.Get('whisperSound', 'champion') end,
            setFunc = function(value)
                Settings.Set('whisperSound', value)
                if AetherChat.SoundManager and AetherChat.SoundManager.PlaySoundPreview then
                    AetherChat.SoundManager.PlaySoundPreview(value)
                end
            end,
            default = 'champion',
        },
        {
            type = "button",
            name = L('SET_SOUND_TEST_BTN'),
            tooltip = L('SET_SOUND_TEST_TT'),
            func = function()
                if AetherChat.SoundManager and AetherChat.SoundManager.PlaySoundPreview then
                    AetherChat.SoundManager.PlaySoundPreview(Settings.Get('whisperSound', 'champion'))
                end
            end,
            width = "half",
        },
        {
            type = "header",
            name = L('SET_BADGE_HEADER'),
        },
        {
            type = "checkbox",
            name = L('SET_BADGE_MESSAGES'),
            tooltip = L('SET_BADGE_MESSAGES_TT'),
            getFunc = function() return Settings.Get('showBadgeMessages', true) end,
            setFunc = function(value)
                Settings.Set('showBadgeMessages', value)
                if AetherChat.Messenger and AetherChat.Messenger.UpdateTotalBadge then
                    AetherChat.Messenger.UpdateTotalBadge()
                end
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = L('SET_BADGE_FRIENDS'),
            tooltip = L('SET_BADGE_FRIENDS_TT'),
            getFunc = function() return Settings.Get('showBadgeFriends', true) end,
            setFunc = function(value)
                Settings.Set('showBadgeFriends', value)
                if AetherChat.Messenger and AetherChat.Messenger.UpdateFriendsBadge then
                    AetherChat.Messenger.UpdateFriendsBadge()
                end
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = L('SET_BADGE_MAIL'),
            tooltip = L('SET_BADGE_MAIL_TT'),
            getFunc = function() return Settings.Get('showBadgeMail', true) end,
            setFunc = function(value)
                Settings.Set('showBadgeMail', value)
                if AetherChat.Messenger and AetherChat.Messenger.UpdateMailBadge then
                    AetherChat.Messenger.UpdateMailBadge()
                end
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = L('SET_BADGE_WHISPER'),
            tooltip = L('SET_BADGE_WHISPER_TT'),
            getFunc = function() return Settings.Get('notifyWhispers', true) end,
            setFunc = function(value)
                Settings.Set('notifyWhispers', value)
                if AetherChat.Messenger and AetherChat.Messenger.UpdateTotalBadge then
                    AetherChat.Messenger.UpdateTotalBadge()
                end
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = L('SET_BADGE_GUILD'),
            tooltip = L('SET_BADGE_GUILD_TT'),
            getFunc = function() return Settings.Get('notifyGuilds', true) end,
            setFunc = function(value)
                Settings.Set('notifyGuilds', value)
                if AetherChat.Messenger and AetherChat.Messenger.UpdateTotalBadge then
                    AetherChat.Messenger.UpdateTotalBadge()
                end
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = L('SET_BADGE_PARTY'),
            tooltip = L('SET_BADGE_PARTY_TT'),
            getFunc = function() return Settings.Get('notifyParty', true) end,
            setFunc = function(value)
                Settings.Set('notifyParty', value)
                if AetherChat.Messenger and AetherChat.Messenger.UpdateTotalBadge then
                    AetherChat.Messenger.UpdateTotalBadge()
                end
            end,
            default = true,
        },
        {
            type = "header",
            name = L('SET_STATUS_HEADER'),
        },
        {
            type = "checkbox",
            name = L('SET_NOTIF_FRIENDS_STATUS'),
            tooltip = L('SET_NOTIF_FRIENDS_STATUS_TT'),
            getFunc = function() return Settings.Get('notifyFriendStatus', true) end,
            setFunc = function(value) Settings.Set('notifyFriendStatus', value) end,
            default = true,
        },
        {
            type = "checkbox",
            name = L('SET_NOTIF_GUILD_STATUS'),
            tooltip = L('SET_NOTIF_GUILD_STATUS_TT'),
            getFunc = function() return Settings.Get('notifyGuildStatus', false) end,
            setFunc = function(value) Settings.Set('notifyGuildStatus', value) end,
            default = false,
        },
        {
            type = "checkbox",
            name = function()
                local gId = GetGuildId(1)
                return (gId and gId > 0 and GetGuildName(gId)) or (L('CH_GUILD_PREFIX') .. ' 1')
            end,
            tooltip = L('SET_NOTIF_GUILD_X_TT'),
            getFunc = function() return Settings.Get('notifyGuild_1', true) end,
            setFunc = function(value) Settings.Set('notifyGuild_1', value) end,
            disabled = function()
                local gId = GetGuildId(1)
                return not Settings.Get('notifyGuildStatus', false) or (not gId or gId == 0)
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = function()
                local gId = GetGuildId(2)
                return (gId and gId > 0 and GetGuildName(gId)) or (L('CH_GUILD_PREFIX') .. ' 2')
            end,
            tooltip = L('SET_NOTIF_GUILD_X_TT'),
            getFunc = function() return Settings.Get('notifyGuild_2', true) end,
            setFunc = function(value) Settings.Set('notifyGuild_2', value) end,
            disabled = function()
                local gId = GetGuildId(2)
                return not Settings.Get('notifyGuildStatus', false) or (not gId or gId == 0)
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = function()
                local gId = GetGuildId(3)
                return (gId and gId > 0 and GetGuildName(gId)) or (L('CH_GUILD_PREFIX') .. ' 3')
            end,
            tooltip = L('SET_NOTIF_GUILD_X_TT'),
            getFunc = function() return Settings.Get('notifyGuild_3', true) end,
            setFunc = function(value) Settings.Set('notifyGuild_3', value) end,
            disabled = function()
                local gId = GetGuildId(3)
                return not Settings.Get('notifyGuildStatus', false) or (not gId or gId == 0)
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = function()
                local gId = GetGuildId(4)
                return (gId and gId > 0 and GetGuildName(gId)) or (L('CH_GUILD_PREFIX') .. ' 4')
            end,
            tooltip = L('SET_NOTIF_GUILD_X_TT'),
            getFunc = function() return Settings.Get('notifyGuild_4', true) end,
            setFunc = function(value) Settings.Set('notifyGuild_4', value) end,
            disabled = function()
                local gId = GetGuildId(4)
                return not Settings.Get('notifyGuildStatus', false) or (not gId or gId == 0)
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = function()
                local gId = GetGuildId(5)
                return (gId and gId > 0 and GetGuildName(gId)) or (L('CH_GUILD_PREFIX') .. ' 5')
            end,
            tooltip = L('SET_NOTIF_GUILD_X_TT'),
            getFunc = function() return Settings.Get('notifyGuild_5', true) end,
            setFunc = function(value) Settings.Set('notifyGuild_5', value) end,
            disabled = function()
                local gId = GetGuildId(5)
                return not Settings.Get('notifyGuildStatus', false) or (not gId or gId == 0)
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = L('SET_NOTIF_SALES'),
            tooltip = L('SET_NOTIF_SALES_TT'),
            getFunc = function() return Settings.Get('notifySales', true) end,
            setFunc = function(value) Settings.Set('notifySales', value) end,
            default = true,
        },

        -- ===================== KEYWORDS & MENTIONS =====================
        {
            type = "header",
            name = L('SET_KEYWORD_HEADER'),
        },
        {
            type = "checkbox",
            name = L('SET_KEYWORD_ENABLE'),
            tooltip = L('SET_KEYWORD_ENABLE_TT'),
            getFunc = function() return Settings.Get('keywordEnable', true) end,
            setFunc = function(value)
                Settings.Set('keywordEnable', value)
                if AetherChat.Messenger and AetherChat.Messenger.RefreshActiveChannel then
                    AetherChat.Messenger.RefreshActiveChannel()
                end
            end,
            default = true,
        },
        {
            type = "editbox",
            name = L('SET_KEYWORD_LIST'),
            tooltip = L('SET_KEYWORD_LIST_TT'),
            getFunc = function() return Settings.Get('keywordList', '') end,
            setFunc = function(value)
                Settings.Set('keywordList', value or '')
                -- Rebuild keyword table immediately after save
                if AetherChat.ChatEngine and AetherChat.ChatEngine.RebuildKeywordTable then
                    AetherChat.ChatEngine.RebuildKeywordTable()
                end
                if AetherChat.Messenger and AetherChat.Messenger.RefreshActiveChannel then
                    AetherChat.Messenger.RefreshActiveChannel()
                end
            end,
            isMultiline = false,
            isExtraWide = true,
            default = '',
        },
        {
            type = "dropdown",
            name = L('SET_KEYWORD_SOUND'),
            tooltip = L('SET_KEYWORD_SOUND_TT'),
            choices = soundChoices,
            choicesValues = soundKeys,
            getFunc = function() return Settings.Get('keywordSound', 'champion') end,
            setFunc = function(value) Settings.Set('keywordSound', value) end,
            default = 'champion',
        },
        {
            type = "dropdown",
            name = L('SET_KEYWORD_COLOR'),
            tooltip = L('SET_KEYWORD_COLOR_TT'),
            choices = keywordColorChoices,
            choicesValues = keywordColorValues,
            getFunc = function() return Settings.Get('keywordColor', 'FFD700') end,
            setFunc = function(value)
                Settings.Set('keywordColor', value)
                if AetherChat.Messenger and AetherChat.Messenger.RefreshActiveChannel then
                    AetherChat.Messenger.RefreshActiveChannel()
                end
            end,
            default = 'FFD700',
        },

        -- ===================== TYPOGRAPHY & FONT SIZE =====================
        {
            type = "header",
            name = L('SET_FONT_HEADER'),
        },
        {
            type = "slider",
            name = L('SET_FONT_SIZE'),
            tooltip = L('SET_FONT_SIZE_TT'),
            min = 12,
            max = 24,
            step = 1,
            getFunc = function() return Settings.Get('chatFontSize', 16) end,
            setFunc = function(value)
                Settings.Set('chatFontSize', value)
                if AetherChat.Messenger and AetherChat.Messenger.ApplyChatFontSize then
                    AetherChat.Messenger.ApplyChatFontSize(value)
                end
            end,
            default = 16,
        },

        -- ===================== LOOT HEADER =====================
        {
            type = "header",
            name = L('SET_LOOT_HEADER'),
        },
        {
            type = "editbox",
            name = L('SET_LOOT_TEMPLATE'),
            tooltip = L('SET_LOOT_TEMPLATE_TT'),
            getFunc = function() return Settings.Get('needTemplate', 'LF <<item>> please :)') end,
            setFunc = function(value) Settings.Set('needTemplate', value) end,
            default = 'LF <<item>> please :)',
        },
        {
            type = "header",
            name = L('SET_HISTORY_HEADER'),
        },
        {
            type = "dropdown",
            name = L('SET_HISTORY_DUR'),
            tooltip = L('SET_HISTORY_DUR_TT'),
            choices = retentionChoices,
            choicesValues = retentionValues,
            getFunc = function() return Settings.Get('historyRetention', 604800) end,
            setFunc = function(value)
                Settings.Set('historyRetention', value)
                if AetherChat.History and AetherChat.History.PruneExpiredMessages then
                    AetherChat.History.PruneExpiredMessages()
                end
            end,
            default = 604800,
        },
        {
            type = "checkbox",
            name = L('SET_HISTORY_SAVE'),
            tooltip = L('SET_HISTORY_SAVE_TT'),
            getFunc = function() return Settings.Get('persistHistory', true) end,
            setFunc = function(value) Settings.Set('persistHistory', value) end,
            default = true,
        },
        {
            type = "header",
            name = L('SET_GEN_HEADER'),
        },
        {
            type = "slider",
            name = L('SET_WINDOW_ALPHA'),
            tooltip = L('SET_WINDOW_ALPHA_TT'),
            min = 20,
            max = 100,
            step = 5,
            getFunc = function() return Settings.Get('backdropAlpha', 95) end,
            setFunc = function(value)
                Settings.Set('backdropAlpha', value)
                if AetherChat.Messenger and AetherChat.Messenger.ApplyBackdropAlpha then
                    AetherChat.Messenger.ApplyBackdropAlpha(value)
                end
            end,
            default = 95,
        },
        {
            type = "checkbox",
            name = L('SET_AUTO_HIDE_GAME_MENU'),
            tooltip = L('SET_AUTO_HIDE_GAME_MENU_TT'),
            getFunc = function() return Settings.Get('autoHideOnGameMenu', true) end,
            setFunc = function(value)
                Settings.Set('autoHideOnGameMenu', value)
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = L('SET_GEN_HIDE_ESO'),
            tooltip = L('SET_GEN_HIDE_ESO_TT'),
            getFunc = function() return Settings.Get('hideOfficialChat', false) end,
            setFunc = function(value)
                Settings.Set('hideOfficialChat', value)
                if AetherChat.Messenger and AetherChat.Messenger.SetHideOfficialChat then
                    AetherChat.Messenger.SetHideOfficialChat(value)
                end
            end,
            default = false,
        },
        {
            type = "header",
            name = L('SET_ACTIONS_HEADER'),
        },
        {
            type = "button",
            name = "|c38BDF8" .. L('SET_RELOADUI_BTN') .. "|r",
            tooltip = L('SET_RELOADUI_TT'),
            func = function()
                ReloadUI()
            end,
            width = "full",
        },
        {
            type = "button",
            name = L('SET_TEST_WHISPER_BTN'),
            tooltip = L('SET_TEST_WHISPER_TT'),
            func = function()
                if AetherChat.Messenger and AetherChat.Messenger.TestWhisper then
                    AetherChat.Messenger.TestWhisper()
                end
            end,
            width = "half",
        },
        {
            type = "button",
            name = L('SET_RESET_BTN'),
            tooltip = L('SET_RESET_TT'),
            func = function()
                Settings.Set('channelOrder', {})
                Settings.Set('floatingIconPos', { x = 60, y = 60 })
                Settings.Set('windowPos', nil)
                Settings.Set('windowDimensions', { width = 940, height = 520 })
                Settings.Set('sidebarCollapsed', false)
                Settings.Set('backdropAlpha', 95)
                if AetherChat_MinBar then
                    AetherChat_MinBar:ClearAnchors()
                    AetherChat_MinBar:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 60, 60)
                end
                if AetherChat_MessengerWindow then
                    AetherChat_MessengerWindow:ClearAnchors()
                    AetherChat_MessengerWindow:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
                    AetherChat_MessengerWindow:SetDimensions(940, 520)
                end
                if AetherChat.Messenger then
                    if AetherChat.Messenger.ApplyBackdropAlpha then
                        AetherChat.Messenger.ApplyBackdropAlpha(95)
                    end
                    if AetherChat.Messenger.SetSidebarCollapsed then
                        AetherChat.Messenger.SetSidebarCollapsed(false)
                    end
                    if AetherChat.Messenger.RefreshChannelList then
                        AetherChat.Messenger.RefreshChannelList()
                    end
                end
            end,
            width = "half",
        },
    }

    LAM:RegisterOptionControls("AetherChat_LAM_Panel", optionsData)
end
