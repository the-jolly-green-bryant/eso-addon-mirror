local TP = ToxicPlayers

ToxicPlayers.settings = {}
local settings = {}

function settings.__index(self, key)
    local sets = TP.getSettings()
    return sets[key]
end

function settings.__newindex(self, key, value)
    local sets = TP.getSettings()
    sets[key] = value
end

setmetatable(TP.settings, settings)

local function draftMail(gold)
    local isDonation = gold and gold > 0
    local headerString = GetString(isDonation and MOUTON_AUTHOR_DONATE_GOLD_HEADER or MOUTON_AUTHOR_FEEDBACK_MAIL_HEADER)

    ZO_MailSendToField:SetText(TP.options.recipient:sub(1, 1) == "@" and TP.options.recipient or "@" .. TP.options.recipient)
    ZO_MailSendSubjectField:SetText(zo_strformat(headerString, TP.options.name, TP.options.version))
    ZO_MailSendBodyField:TakeFocus()

    if isDonation then
        QueueMoneyAttachment(gold)
        ZO_MailSendSendCurrency:OnBeginInput()
    else
        ZO_MailSendBodyField:TakeFocus()
    end
end

local function showMail(gold)
    SCENE_MANAGER:Show('mailSend')
    zo_callLater(function()
        draftMail(gold)
    end, 250)
end

function TP.options.feedback()
    ClearMenu()
    local isEUServer = GetWorldName() == "EU Megaserver"
    if isEUServer then
        AddCustomMenuItem(GetString(MOUTON_AUTHOR_FEEDBACK_MAIL), function()
            showMail()
        end)
    end
    AddCustomMenuItem(GetString(MOUTON_AUTHOR_FEEDBACK_ESOUI), function()
        RequestOpenUnsafeURL(TP.options.website .. "#comments")
    end)
    ShowMenu()
end

function TP.options.donation()
    ClearMenu()
    local isEUServer = GetWorldName() == "EU Megaserver"
    if isEUServer then
        AddCustomMenuItem(GetString(MOUTON_AUTHOR_DONATE_GOLD), function()
            showMail(5000)
        end)
    end
    if isEUServer then
        AddCustomMenuItem(GetString(MOUTON_AUTHOR_DONATE_CROWNS), function()
            SCENE_MANAGER:Show("show_market")
        end)
    end
    AddCustomMenuItem(GetString(MOUTON_AUTHOR_DONATE_ESOUI), function()
        RequestOpenUnsafeURL(TP.options.website .. "#donate")
    end)
    ShowMenu()
end

function TP.getSettings()
    if (TP.accountSettings.accountWide) then
        return TP.accountSettings
    else
        return TP.localSettings
    end
end

function ToxicPlayers:CreateAddonMenu()
    local LAM = LibAddonMenu2

    LAM:RegisterAddonPanel(TP.name .. "Options", TP.options)

    local optionsData = {{
        type = "description",
        title = nil,
        text = GetString(TOXICPLAYERS_OPTION_DESCRITPION),
        width = "full"
    }, {
        type = "header",
        name = "",
        width = "full"
    }, {
        type = "checkbox",
        name = GetString(TOXICPLAYERS_OPTION_RETICLE_TEXT_DESCRIPTION),
        tooltip = GetString(TOXICPLAYERS_OPTION_RETICLE_TEXT_TOOLTIP),
        getFunc = function()
            return TP.settings.displayText
        end,
        setFunc = function(value)
            TP.settings.displayText = value
        end,
        width = "full"
    }, {
        type = "checkbox",
        name = GetString(TOXICPLAYERS_OPTION_RETICLE_ICON_DESCRIPTION),
        tooltip = GetString(TOXICPLAYERS_OPTION_RETICLE_ICON_TOOLTIP),
        getFunc = function()
            return TP.settings.displayIcon
        end,
        setFunc = function(value)
            TP.settings.displayIcon = value
        end,
        width = "full"
    }, {
        type = "checkbox",
        name = GetString(TOXICPLAYERS_OPTION_RETICLE_FOE_MARKER_DESCRIPTION),
        tooltip = GetString(TOXICPLAYERS_OPTION_RETICLE_FOE_MARKER_TOOLTIP),
        getFunc = function()
            return TP.settings.displayFoeMarker
        end,
        setFunc = function(value)
            TP.settings.displayFoeMarker = value
        end,
        width = "full"
    }, {
        type = "checkbox",
        name = GetString(TOXICPLAYERS_OPTION_RETICLE_FRIEND_MARKER_DESCRIPTION),
        tooltip = GetString(TOXICPLAYERS_OPTION_RETICLE_FRIEND_MARKER_TOOLTIP),
        getFunc = function()
            return TP.settings.displayFriendMarker
        end,
        setFunc = function(value)
            TP.settings.displayFriendMarker = value
        end,
        width = "full"
    }, {
        type = "checkbox",
        name = GetString(TOXICPLAYERS_OPTION_DISPLAY_IN_GROUP_DESCRIPTION),
        tooltip = GetString(TOXICPLAYERS_OPTION_RETICLE_IN_GROUP_MARKER_TOOLTIP),
        getFunc = function()
            return TP.settings.displayInGroups
        end,
        setFunc = function(value)
            TP.settings.displayInGroups = value
        end,
        width = "full"
    }, {
        type = "checkbox",
        name = GetString(TOXICPLAYERS_OPTION_DISPLAY_FRIENDS_DESCRIPTION),
        tooltip = GetString(TOXICPLAYERS_OPTION_DISPLAY_FRIENDS_TOOLTIP),
        getFunc = function()
            return TP.settings.displayOnFriends
        end,
        setFunc = function(value)
            TP.settings.displayOnFriends = value
        end,
        width = "full"
    }, {
        type = "checkbox",
        name = GetString(TOXICPLAYERS_OPTION_AUTOMATIC_PLAYER_INFO_DESCRIPTION),
        tooltip = GetString(TOXICPLAYERS_OPTION_AUTOMATIC_PLAYER_INFO_TOOLTIP),
        getFunc = function()
            return TP.settings.automaticPlayerInfo
        end,
        setFunc = function(value)
            TP.settings.automaticPlayerInfo = value
        end,
        width = "full"
    }, {
        type = "checkbox",
        name = GetString(TOXICPLAYERS_OPTION_DISPLAY_GUILD_DESCRIPTION),
        tooltip = GetString(TOXICPLAYERS_OPTION_DISPLAY_GUILD_TOOLTIP),
        getFunc = function()
            return TP.settings.displayOnGuild
        end,
        setFunc = function(value)
            TP.settings.displayOnGuild = value
        end,
        width = "full"
    }, {
        type = "checkbox",
        name = GetString(TOXICPLAYERS_OPTION_DISPLAY_GUILDBLACKLIST_DESCRIPTION),
        tooltip = GetString(TOXICPLAYERS_OPTION_DISPLAY_GUILDBLACKLIST_TOOLTIP),
        getFunc = function()
            return TP.settings.displayOnGuildBlacklist
        end,
        setFunc = function(value)
            TP.settings.displayOnGuildBlacklist = value
        end,
        width = "full"
    }, {
        type = "checkbox",
        name = GetString(TOXICPLAYERS_OPTION_DISPLAY_IGNORED_DESCRIPTION),
        tooltip = GetString(TOXICPLAYERS_OPTION_DISPLAY_IGNORED_TOOLTIP),
        getFunc = function()
            return TP.settings.displayOnIgnored
        end,
        setFunc = function(value)
            TP.settings.displayOnIgnored = value
        end,
        width = "full"
    }, {
        type = "checkbox",
        name = GetString(TOXICPLAYERS_OPTION_DISPLAY_UNKNOWN_DESCRIPTION),
        tooltip = GetString(TOXICPLAYERS_OPTION_DISPLAY_UNKNOWN_TOOLTIP),
        getFunc = function()
            return TP.settings.displayOnUnknown
        end,
        setFunc = function(value)
            TP.settings.displayOnUnknown = value
        end,
        width = "full"
    }, {
        type = "dropdown",
        name = GetString(TOXICPLAYERS_OPTION_DISPLAY_NAME),
        tooltip = GetString(TOXICPLAYERS_OPTION_DISPLAY_NAME_TOOLTIP),
        getFunc = function()
            return TP.settings.displayName
        end,
        setFunc = function(value)
            TP.settings.displayName = value
        end,
        choices = {GetString(TOXICPLAYERS_SI_DISPLAY_NAME_ID), GetString(TOXICPLAYERS_SI_DISPLAY_BOTH)},
        choicesValues = {TP_DISPLAY_NAME_ID, TP_DISPLAY_NAME_BOTH},
        width = "full"
    }, {
        type = "dropdown",
        name = GetString(TOXICPLAYERS_OPTION_DISPLAY_POSITION_TEXT_DESCRIPTION),
        tooltip = GetString(TOXICPLAYERS_OPTION_DISPLAY_POSITION_TEXT_TOOLTIP),
        getFunc = function()
            return TP.settings.positionName
        end,
        setFunc = function(value)
            TP.settings.positionName = value
            TP.FixPositions()
        end,
        choices = {GetString(TOXICPLAYERS_POSITION_TOP), GetString(TOXICPLAYERS_POSITION_BOTTOM), GetString(TOXICPLAYERS_POSITION_LEFT), GetString(TOXICPLAYERS_POSITION_RIGHT)},
        choicesValues = {TOP, BOTTOM, LEFT, RIGHT},
        width = "full"
    }, {
        type = "dropdown",
        name = GetString(TOXICPLAYERS_OPTION_DISPLAY_POSITION_ICON_DESCRIPTION),
        tooltip = GetString(TOXICPLAYERS_OPTION_DISPLAY_POSITION_ICON_TOOLTIP),
        getFunc = function()
            return TP.settings.positionIcon
        end,
        setFunc = function(value)
            TP.settings.positionIcon = value
            TP.FixPositions()
        end,
        choices = {GetString(TOXICPLAYERS_POSITION_TOP), GetString(TOXICPLAYERS_POSITION_BOTTOM), GetString(TOXICPLAYERS_POSITION_LEFT), GetString(TOXICPLAYERS_POSITION_RIGHT)},
        choicesValues = {TOP, BOTTOM, LEFT, RIGHT},
        width = "full"
    }, {
        type = "checkbox",
        name = GetString(TOXICPLAYERS_OPTION_ACCOUNT_WIDE),
        warning = GetString(TOXICPLAYERS_OPTION_ACCOUNT_WIDE_TOOLTIP),
        getFunc = function()
            return TP.accountSettings.accountWide
        end,
        setFunc = function(value)
            TP.accountSettings.accountWide, TP.localSettings.accountWide = value, value
            if (TP.accountSettings.accountWide) then
                for k, v in pairs(TP.defaultSettings) do
                    TP.accountSettings[k] = TP.localSettings[k]
                end
            else
                for k, v in pairs(TP.defaultSettings) do
                    TP.localSettings[k] = TP.accountSettings[k]
                end
            end
            ReloadUI()
        end,
        width = "full"
    }}

    LAM:RegisterOptionControls(TP.name .. "Options", optionsData)
end
