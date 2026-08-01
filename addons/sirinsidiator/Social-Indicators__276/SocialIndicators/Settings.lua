local CONTROL_NAME_PREFIX = "SocialIndicators_"
local PANEL_NAME = CONTROL_NAME_PREFIX .. "SettingsMenu"
local L = SocialIndicators.Localization

local IsPositionRight = SocialIndicators.IsPositionRight

local initialized = false
local LAM = nil

local defaultSettings = {
    version = 6,
    showSocialListFilterForIngameLists = true,
    targetIndicators = {
        ignoreIconActive = true,
        friendIconActive = true,
        friendIconPosition = L["POSITION_LEFT"],
        guildIndicatorActive = true,
        guildRankIconActive = true,
        guildRankIconPosition = L["POSITION_LEFT"],
    },
    groupIndicators = {
        ignoreIconActive = true,
        friendIconActive = true,
        guildIconActive = true,
        showGuildRankIcon = true
    },
    nameIndicators = {
        showFriendIndicator = true,
        showIgnoreIndicator = true,
        showGroupIndicators = true,
        showGroupLeaderInGroupChat = true,
        showGuildIndicators = true,
        showGuildIndicatorsOutsideGuildChannels = true,
        showGuildRankOutsideGuildChannels = true,
        showGuildRankInGuildChannels = true,
        showIndicatorsInChat = true,
        showIndicatorsOnAllLinks = true,
    }
}

local function SanitizeBooleanValue(value)
    if(value == false) then
        return false
    else
        return true
    end
end

local function SanitizePositionValue(value)
    if(IsPositionRight(value)) then
        return L["POSITION_RIGHT"]
    else
        return L["POSITION_LEFT"]
    end
end

local function AddSubmenu(optionsData, labelPrefix)
    local controls = {}
    table.insert(optionsData, {
        type = "submenu",
        name = L[labelPrefix .. "_LABEL"],
        tooltip = L[labelPrefix .. "_DESCRIPTION"],
        controls = controls,
    })
    return controls
end

local function AddHeader(optionsData, labelID)
    table.insert(optionsData, {
        type = "header",
        name = L[labelID]
    })
end

local function AddCheckbox(optionsData, settingsObject, settingName, labelPrefix, disabled)
    local function GetValue()
        return SanitizeBooleanValue(settingsObject[settingName])
    end

    local function SetValue(value)
        settingsObject[settingName] = value
        CALLBACK_MANAGER:FireCallbacks(CONTROL_NAME_PREFIX .. labelPrefix .. "_Changed", value)
    end

    table.insert(optionsData, {
        type = "checkbox",
        name = L[labelPrefix .. "_LABEL"],
        tooltip = L[labelPrefix .. "_DESCRIPTION"],
        warning = L[labelPrefix .. "_WARNING"],
        disabled = disabled,
        getFunc = GetValue,
        setFunc = SetValue,
        default = SanitizePositionValue(defaultSettings[settingName])
    })
end

local function AddPositionDropdown(optionsData, settingsObject, settingName, labelPrefix, disabled)
    local function GetValue()
        return SanitizePositionValue(settingsObject[settingName])
    end

    local function SetValue(value)
        settingsObject[settingName] = value
        CALLBACK_MANAGER:FireCallbacks(CONTROL_NAME_PREFIX .. labelPrefix .. "_Changed", value)
    end

    table.insert(optionsData, {
        type = "dropdown",
        name = L[labelPrefix .. "_LABEL"],
        tooltip = L[labelPrefix .. "_DESCRIPTION"],
        choices = {L["POSITION_LEFT"], L["POSITION_RIGHT"]},
        warning = L[labelPrefix .. "_WARNING"],
        disabled = disabled,
        getFunc = GetValue,
        setFunc = SetValue,
        default = SanitizePositionValue(defaultSettings[settingName])
    })
end

local function UpgradeSettings()
    local settings = SocialIndicators_Settings
    if(not settings.version or settings.version < 2) then
        settings.targetIndicators.ignoreIconActive = defaultSettings.targetIndicators.ignoreIconActive
        settings.groupIndicators.ignoreIconActive = defaultSettings.groupIndicators.ignoreIconActive
        settings.version = 2
    end
    if(settings.version < 5) then
        settings.targetIndicators.fixTargetFrameColorBug = nil
        settings.chatIndicators = nil
        settings.nameIndicators = ZO_ShallowTableCopy(defaultSettings.nameIndicators)
        settings.version = 5
    end
    if(settings.version < 6) then
        settings.showSocialListFilterForIngameLists = defaultSettings.showSocialListFilterForIngameLists
        settings.version = 6
    end
end

function SocialIndicators.InitSettings()
    if(initialized) then return end
    if(not SocialIndicators_Settings) then SocialIndicators_Settings = ZO_DeepTableCopy(defaultSettings) end
    UpgradeSettings()

    LAM = LibStub:GetLibrary("LibAddonMenu-2.0")

    LAM:RegisterAddonPanel(PANEL_NAME, {
        type = "panel",
        name = "Social Indicators",
        author = "sirinsidiator",
        version = "1.11",
        registerForDefaults = true,
        registerForRefresh = true
    })
    local optionsData = {}
    
    AddCheckbox(optionsData, SocialIndicators_Settings, "showSocialListFilterForIngameLists", "SHOW_INGAME_SOCIAL_LIST_FILTERS")

    local targetIndicators = SocialIndicators_Settings.targetIndicators
    local controls = AddSubmenu(optionsData, "TARGET_INDICATOR")
    AddCheckbox(controls, targetIndicators, "ignoreIconActive", "TARGET_IGNORE_ICON_ACTIVE")
    AddCheckbox(controls, targetIndicators, "friendIconActive", "TARGET_FRIEND_ICON_ACTIVE")
    AddPositionDropdown(controls, targetIndicators, "friendIconPosition", "TARGET_FRIEND_ICON_POSITION")
    AddCheckbox(controls, targetIndicators, "guildIndicatorActive", "TARGET_GUILD_INDICATOR_ACTIVE")
    local function TargetGuildIndicatorDisabled() return not targetIndicators.guildIndicatorActive end
    AddCheckbox(controls, targetIndicators, "guildRankIconActive", "TARGET_GUILD_RANK_ICON_ACTIVE", TargetGuildIndicatorDisabled)
    AddPositionDropdown(controls, targetIndicators, "guildRankIconPosition", "TARGET_GUILD_RANK_ICON_POSITION", TargetGuildIndicatorDisabled)

    local groupIndicators = SocialIndicators_Settings.groupIndicators
    controls = AddSubmenu(optionsData, "GROUP_INDICATOR")
    AddCheckbox(controls, groupIndicators, "ignoreIconActive", "GROUP_IGNORE_ICON_ACTIVE")
    AddCheckbox(controls, groupIndicators, "friendIconActive", "GROUP_FRIEND_ICON_ACTIVE")
    AddCheckbox(controls, groupIndicators, "guildIconActive", "GROUP_GUILD_ICON_ACTIVE")
    AddCheckbox(controls, groupIndicators, "showGuildRankIcon", "GROUP_SHOW_GUILD_RANK_ICON")

    local nameIndicators = SocialIndicators_Settings.nameIndicators
    controls = AddSubmenu(optionsData, "NAME_INDICATOR")
    AddCheckbox(controls, nameIndicators, "showFriendIndicator", "NAME_SHOW_FRIEND_ICON")
    AddCheckbox(controls, nameIndicators, "showIgnoreIndicator", "NAME_SHOW_IGNORE_ICON")
    AddCheckbox(controls, nameIndicators, "showGroupIndicators", "NAME_SHOW_GROUP_ICON")
    local function GroupIndicatorsDisabled() return not nameIndicators.showGroupIndicators end
    AddCheckbox(controls, nameIndicators, "showGroupLeaderInGroupChat", "NAME_SHOW_GROUP_LEADER_IN_CHAT", GroupIndicatorsDisabled)
    AddCheckbox(controls, nameIndicators, "showGuildIndicators", "NAME_SHOW_GUILD_ICON")
    local function GuildIndicatorsDisabled() return not nameIndicators.showGuildIndicators end
    AddCheckbox(controls, nameIndicators, "showGuildIndicatorsOutsideGuildChannels", "NAME_SHOW_GUILD_OUTSIDE_GUILD_CHANNEL", GuildIndicatorsDisabled)
    local function GuildIndicatorsOOCDisabled() return not nameIndicators.showGuildIndicatorsOutsideGuildChannels end
    AddCheckbox(controls, nameIndicators, "showGuildRankOutsideGuildChannels", "NAME_SHOW_GUILD_RANK_OUTSIDE_GUILD_CHANNEL", GuildIndicatorsOOCDisabled)
    AddCheckbox(controls, nameIndicators, "showGuildRankInGuildChannels", "NAME_SHOW_GUILD_RANK_IN_GUILD_CHANNEL", GuildIndicatorsDisabled)
    AddCheckbox(controls, nameIndicators, "showIndicatorsInChat", "SHOW_INDICATORS_IN_CHAT")
    AddCheckbox(controls, nameIndicators, "showIndicatorsOnAllLinks", "SHOW_INDICATORS_ON_ALL_LINKS")

    LAM:RegisterOptionControls(PANEL_NAME, optionsData)

    initialized = true
end
