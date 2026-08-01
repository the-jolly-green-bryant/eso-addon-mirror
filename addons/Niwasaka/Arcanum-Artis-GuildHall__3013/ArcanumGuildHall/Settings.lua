local ArcanumGuildHall = _G['ArcanumGuildHall']

local LAM2 = LibAddonMenu2
local LMP = LibMediaProvider
local res = ArcanumGuildHallMediaRes
local panelOpen = false

local outlineStyles = { 'none', 'outline', 'thin-outline', 'thick-outline', 'shadow', 'soft-shadow-thin', 'soft-shadow-thick' }

local leaveOption = { }
local leaveOptionLookup = { }
for i = 0, 2 do
    table.insert(leaveOption, i)
    table.insert(leaveOptionLookup, ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_NOGUILDLEAVE_CHOICE" .. i))
end

local tomeAlertLocation = { }
local tomeAlertLocationLookup = { }
for i = 0, 1 do
    table.insert(tomeAlertLocation, i)
    table.insert(tomeAlertLocationLookup, ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_TOME_CHOICE" .. i))
end

local showRankIcon = { }
local showRankIconLabels = { }
for i = 0, 2 do
    table.insert(showRankIcon, i)
    table.insert(showRankIconLabels, ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_SHOWRANKICON_CHOICE" .. i))
end

local repairOption = { }
local repairOptionLookup = { }
for i = 0, 2 do
    table.insert(repairOption, i)
    table.insert(repairOptionLookup, ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_REPAIR_STORES_CHOICE" .. i))
end

local rechargeOption = { }
local rechargeOptionLookup = { }
for i = 0, 2 do
    table.insert(rechargeOption, i)
    table.insert(rechargeOptionLookup, ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_RECHARGE_CHOICE" .. i))
end

local challengeDisplayModeValues = { "chat", "window" }
local challengeDisplayModeChoices = {
    ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_CHALLENGES_MODE_CHAT"),
    ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_CHALLENGES_MODE_WINDOW"),
}

local function QualityColoredName(quality)
    return GetItemQualityColor(quality):Colorize(GetString("SI_ITEMQUALITY", quality))
end

local selectReminderDay = { os.date("%A", 1633932000), os.date("%A", 1634018400), os.date("%A", 1634104800), os.date("%A", 1634191200), os.date("%A", 1634277600), os.date("%A", 1634364000), os.date("%A", 1634450400) }

function ArcanumGuildHall:InitializeMenu()
    local panelData = {
        type = "panel",
        name = self.addonName,
        displayName = self.displayName,
        author = self.author,
        version = self.version,
        slashCommand = self.slashCommand,
        website = self.website,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsTable = {
        {
            type = "header",
            name = GetString(SI_KEYBINDINGS_GENERIC_CATEGORY_NAME),
            width = "full",
        },
        {
            type = "checkbox",
            name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_CHAT_ICON"),
            getFunc = function()
                return self.db.showChatIcon
            end,
            setFunc = function(show)
                self.db.showChatIcon = show
                self:ShowChatIcon(show)
            end,
            default = self.defaults.showChatIcon,
        },
        {
            type = "checkbox",
            name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_MONOCHROME_ICON"),
            getFunc = function()
                return self.db.monochromeIcon
            end,
            setFunc = function(monochrome)
                self.db.monochromeIcon = monochrome
                self:SetChatIconTexture(monochrome)
            end,
            default = self.defaults.monochromeIcon,
            disabled = function()
                return not self.db.showChatIcon
            end
        },
        {
            type = "dropdown",
            name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_NOGUILDLEAVE"),
            tooltip = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_TOOLTIP_NOGUILDLEAVE"),
            choices = leaveOptionLookup,
            choicesValues = leaveOption,
            getFunc = function()
                return self.db.noGuildLeave
            end,
            setFunc = function(value)
                self.db.noGuildLeave = value
                self:CheckNoGuildLeave()
            end,
            default = self.defaults.noGuildLeave,
        },
        {
            type = "checkbox",
            name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_SHOW_CHANGELOG"),
            getFunc = function()
                return self.db.showChangelog
            end,
            setFunc = function(value)
                self.db.showChangelog = value
            end,
            default = self.defaults.showChangelog,
        },
        {
            type = "submenu",
            name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_HEADER_NAMES"),
            tooltip = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_TOOLTIP_MEMBER"),
            width = "full",
            controls = {
                {
                    type = "description",
                    title = nil,
                    text = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_HEADER_NAMES_DESCRIPTION"),
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_COLORIZE_GUILD_NAMES"),
                    getFunc = function()
                        return self.db.colorizeNames
                    end,
                    setFunc = function(colorize)
                        self.db.colorizeNames = colorize
                    end,
                    default = self.defaults.colorizeNames,
                },
            },
        },
        {
            type = "submenu",
            name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_HEADER_NOTIFICATION"),
            tooltip = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_TOOLTIP_NOTIFICATIONS"),
            width = "full",
            controls = {
                {
                    type = "checkbox",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_NOTIFICATION_ACTIVE"),
                    getFunc = function()
                        return self.db.enableReminder
                    end,
                    setFunc = function(use)
                        self.db.enableReminder = use
                        self.db.showReminder = use
                    end,
                    default = self.defaults.enableReminder,
                },
                {
                    type = "dropdown",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_NOTIFICATION_DAYS"),
                    choices = selectReminderDay,
                    getFunc = function()
                        return self.db.selectedReminderDay
                    end,
                    setFunc = function(value)
                        self.db.selectedReminderDay = value
                        self.db.showReminder = true
                        self:ShowNotification()
                    end,
                    default = self.defaults.selectedReminderDay,
                    width = "full",
                    disabled = function()
                        return not self.db.enableReminder
                    end
                },
                {
                    type = "checkbox",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_NOTIFICATION_CHANGE_ACTIVE"),
                    getFunc = function()
                        return self.db.enableNotChange
                    end,
                    setFunc = function(use)
                        self.db.enableNotChange = use
                    end,
                    default = self.defaults.enableNotChange,
                    disabled = function()
                        return not self.db.enableReminder
                    end
                },
                {
                    type = "editbox",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_NOTIFICATION_CHANGE_HEADER"),
                    tooltip = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_NOTIFICATION_HEADER_TOOLTIP"),
                    getFunc = function()
                        return self.db.defaultNotTitle
                    end,
                    setFunc = function(text)
                        self.db.defaultNotTitle = text
                    end,
                    isMultiline = false,
                    isExtraWide = false,
                    width = "full",
                    default = self.defaults.defaultNotTitle,
                    warning = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_NOTIFICATION_WARN_HEADER"),
                    disabled = function()
                        return not self.db.enableNotChange or not self.db.enableReminder
                    end
                },
                {
                    type = "button",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_NOTIFICATION_RESET"),
                    func = function()
                        self.db.defaultNotTitle = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_NOTIFICATION_TITLE")
                    end,
                    width = "full",
                    disabled = function()
                        return not self.db.enableNotChange or not self.db.enableReminder
                    end
                },
                {
                    type = "editbox",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_NOTIFICATION_CHANGE_MESSAGE"),
                    tooltip = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_NOTIFICATION_MESSAGE_TOOLTIP"),
                    getFunc = function()
                        return self.db.defaultNotMessage
                    end,
                    setFunc = function(text)
                        self.db.defaultNotMessage = text
                    end,
                    isMultiline = true,
                    isExtraWide = false,
                    width = "full",
                    default = self.defaults.defaultNotMessage,
                    warning = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_NOTIFICATION_WARN_MESSAGE"),
                    disabled = function()
                        return not self.db.enableNotChange or not self.db.enableReminder
                    end
                },
                {
                    type = "button",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_NOTIFICATION_RESET"),
                    func = function()
                        self.db.defaultNotMessage = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_NOTIFICATION_TEXT")
                    end,
                    width = "full",
                    disabled = function()
                        return not self.db.enableNotChange or not self.db.enableReminder
                    end
                },
            },
        },
        {
            type = "submenu",
            name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_TOME_TITLE"),
            tooltip = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_TOOLTIP_TOMES"),
            width = "full",
            controls = {
                {
                    type = "checkbox",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_TOME_CLAIM"),
                    getFunc = function()
                        return self.db.enableTomeAutoClaim
                    end,
                    setFunc = function(enable)
                        self.db.enableTomeAutoClaim = enable
                        self:RefreshTomeClaimAllButton()
                    end,
                    default = self.defaults.enableTomeAutoClaim,
                },
                {
                    type = "checkbox",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_TOME_AUTO_TRACK"),
                    tooltip = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_TOOLTIP_TOME_AUTO_TRACK"),
                    getFunc = function()
                        return self.db.autoTrackTomes
                    end,
                    setFunc = function(value)
                        self.db.autoTrackTomes = value
                    end,
                    default = self.defaults.autoTrackTomes,
                },
                {
                    type = "checkbox",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_TOME_PROGRESS_BAR"),
                    getFunc = function()
                        return self.db.showTomeProgressBar
                    end,
                    setFunc = function(value)
                        self.db.showTomeProgressBar = value
                        self:RefreshTomeWindowIfVisible()
                    end,
                    default = self.defaults.showTomeProgressBar,
                },
                {
                    type = "header",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_TOME_HEADER_CHAT"),
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_TOME_ENABLE"),
                    getFunc = function()
                        return self.db.enableTomeAlert
                    end,
                    setFunc = function(enable)
                        self.db.enableTomeAlert = enable
                    end,
                    default = self.defaults.enableTomeAlert,
                },
                {
                    type = "dropdown",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_TOME_LOCATION"),
                    choices = tomeAlertLocationLookup,
                    choicesValues = tomeAlertLocation,
                    getFunc = function()
                        return self.db.locationTomeAlert
                    end,
                    setFunc = function(value)
                        self.db.locationTomeAlert = value
                    end,
                    width = "full",
                    default = self.defaults.locationTomeAlert,
                    disabled = function()
                        return not self.db.enableTomeAlert
                    end
                },
                {
                    type = "checkbox",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_TOME_ICON"),
                    getFunc = function()
                        return self.db.showTomeIcon
                    end,
                    setFunc = function(enable)
                        self.db.showTomeIcon = enable
                    end,
                    default = self.defaults.showTomeIcon,
                    disabled = function()
                        return not self.db.enableTomeAlert
                    end
                },
                {
                    type = "colorpicker",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_TOME_COLOR_WEEKLY"),
                    getFunc = function()
                        return self:ConvHexToRGB(self.db.tomeColorWeekly)
                    end,
                    setFunc = function(r, g, b)
                        self.db.tomeColorWeekly = self:ConvRGBToHex(r, g, b)
                    end,
                    disabled = function()
                        return not self.db.enableTomeAlert
                    end
                },
                {
                    type = "colorpicker",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_TOME_COLOR_SEASONAL"),
                    getFunc = function()
                        return self:ConvHexToRGB(self.db.tomeColorSeasonal)
                    end,
                    setFunc = function(r, g, b)
                        self.db.tomeColorSeasonal = self:ConvRGBToHex(r, g, b)
                    end,
                    disabled = function()
                        return not self.db.enableTomeAlert
                    end
                },
                {
                    type = "checkbox",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_TOME_REWARD"),
                    getFunc = function()
                        return self.db.showTomeReward
                    end,
                    setFunc = function(enable)
                        self.db.showTomeReward = enable
                    end,
                    default = self.defaults.showTomeReward,
                    disabled = function()
                        return not self.db.enableTomeAlert
                    end
                },
                {
                    type = "checkbox",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_TOME_SEASONAL_PROGRESS"),
                    tooltip = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_TOOLTIP_TOME_SEASONAL_PROGRESS"),
                    getFunc = function()
                        return self.db.showSeasonalTomeProgress
                    end,
                    setFunc = function(enable)
                        self.db.showSeasonalTomeProgress = enable
                    end,
                    default = self.defaults.showSeasonalTomeProgress,
                    disabled = function()
                        return not self.db.enableTomeAlert
                    end
                },
                {
                    type = "header",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_TOME_HEADER_WINDOW"),
                    width = "full",
                },
                {
                    type = "description",
                    text = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_TOME_WINDOW_INFO"),
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_TOME_ICON_UI"),
                    getFunc = function()
                        return self.db.showTomeIconUI
                    end,
                    setFunc = function(enable)
                        self.db.showTomeIconUI = enable
                        self:SetTomeIconVisible(enable)
                    end,
                    default = self.defaults.showTomeIconUI,
                },
                {
                    type = "checkbox",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_TOME_COMPACT_MODE"),
                    getFunc = function()
                        return self.db.tomeWindowCompactMode
                    end,
                    setFunc = function(enable)
                        self.db.tomeWindowCompactMode = enable
                        self:ApplyTomeWindowLayout()
                        self:RefreshTomeWindowIfVisible()
                    end,
                    default = self.defaults.tomeWindowCompactMode,
                },
                {
                    type = "slider",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_TOME_BGTRANSPARENCY"),
                    min = 0,
                    max = 100,
                    getFunc = function()
                        return self.db.tomeWindowBackgroundAlpha
                    end,
                    setFunc = function(value)
                        self.db.tomeWindowBackgroundAlpha = value
                        self:ApplyTomeWindowLayout()
                        self:RefreshTomeWindowIfVisible()
                    end,
                    default = self.defaults.tomeWindowBackgroundAlpha,
                },
            },
        },
        {
            type = "submenu",
            name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_CLOCK_TITLE"),
            tooltip = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_TOOLTIP_CLOCK"),
            width = "full",
            controls = {
                {
                    type = "checkbox",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_CLOCK_SHOW"),
                    getFunc = function()
                        return self.db.showClock
                    end,
                    setFunc = function(value)
                        self.db.showClock = value
                        self:InitClock()
                        if value == true then
                            ArcanumGuildHall:UpdateAnchors(true)
                        end
                    end,
                    default = self.defaults.showClock,
                },
                {
                    type = "checkbox",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_CLOCK_DST"),
                    getFunc = function()
                        return self.db.clockDst
                    end,
                    setFunc = function(value)
                        self.db.clockDst = value
                        self:UpdateTime()
                    end,
                    default = self.defaults.clockDst,
                },
                {
                    type = "checkbox",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_CLOCK_COMBAT"),
                    getFunc = function()
                        return self.db.isInCombatClock
                    end,
                    setFunc = function(value)
                        self.db.isInCombatClock = value
                    end,
                    default = self.defaults.isInCombatClock,
                    disabled = function()
                        return not self.db.showClock
                    end
                },
                {
                    type = "colorpicker",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_CLOCK_COLOR"),
                    getFunc = function()
                        return self:ConvHexToRGB(self.db.clockFontColor)
                    end,
                    setFunc = function(r, g, b)
                        self.db.clockFontColor = self:ConvRGBToHex(r, g, b)
                        self:UpdateClockStyle()
                    end,
                    disabled = function()
                        return not self.db.showClock
                    end
                },
                {
                    type = "dropdown",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_CLOCK_FONT"),
                    choices = LMP:List("font"),
                    getFunc = function()
                        return self.db.clockTextFont
                    end,
                    setFunc = function(value)
                        self.db.clockTextFont = value
                        self:UpdateClockStyle()
                    end,
                    disabled = function()
                        return not self.db.showClock
                    end
                },
                {
                    type = "checkbox",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_CLOCK_SHOW_BG"),
                    getFunc = function()
                        return self.db.showClockBG
                    end,
                    setFunc = function(value)
                        self.db.showClockBG = value
                        self:UpdateClockStyle()
                    end,
                    default = self.defaults.showClockBG,
                },
                {
                    type = "dropdown",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_CLOCK_BG"),
                    choices = LMP:List("background"),
                    getFunc = function()
                        return self.db.clockBackground
                    end,
                    setFunc = function(value)
                        self.db.clockBackground = value
                        self:UpdateClockStyle()
                    end,
                    disabled = function()
                        return not self.db.showClock
                    end
                },
                {
                    type = "colorpicker",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_CLOCK_BGCOLOR"),
                    tooltip = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_TOOLTIP_BGCOLOR"),
                    getFunc = function()
                        return self:ConvHexToRGB(self.db.clockBackgroundColor)
                    end,
                    setFunc = function(r, g, b)
                        self.db.clockBackgroundColor = self:ConvRGBToHex(r, g, b)
                        self:UpdateClockStyle()
                    end,
                    disabled = function()
                        return not self.db.showClock
                    end
                },
                {
                    type = "slider",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_CLOCK_BGTRANSPARENCY"),
                    min = 0,
                    max = 100,
                    getFunc = function()
                        return self.db.clockBackgroundAlpha
                    end,
                    setFunc = function(value)
                        self.db.clockBackgroundAlpha = value
                        self:UpdateClockStyle()
                    end,
                    disabled = function()
                        return not self.db.showClock
                    end
                },
                {
                    type = "slider",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_CLOCK_FONTSIZE"),
                    min = 8,
                    max = 32,
                    getFunc = function()
                        return self.db.clockFontSize
                    end,
                    setFunc = function(value)
                        self.db.clockFontSize = value
                        self:UpdateClockStyle()
                    end,
                    disabled = function()
                        return not self.db.showClock
                    end
                },
                {
                    type = "dropdown",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_CLOCK_OUTLINE"),
                    choices = outlineStyles,
                    getFunc = function()
                        return self.db.clockFontOutline
                    end,
                    setFunc = function(value)
                        self.db.clockFontOutline = value
                        self:UpdateClockStyle()
                    end,
                    disabled = function()
                        return not self.db.showClock
                    end
                },
                {
                    type = "header",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_CLOCK_HEADER_INGAMETIME"),
                    width = "half"
                },
                {
                    type = "checkbox",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_CLOCK_SHOW_INGAMETIME"),
                    getFunc = function()
                        return self.db.showInGameTime
                    end,
                    setFunc = function(value)
                        self.db.showInGameTime = value
                        self:GetInGameTime()
                        self:UpdateTime()
                        self:UpdateClockStyle()
                    end,
                    default = self.defaults.showInGameTime,
                },
                {
                    type = "colorpicker",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_CLOCK_COLOR"),
                    getFunc = function()
                        return self:ConvHexToRGB(self.db.inGameTimeColor)
                    end,
                    setFunc = function(r, g, b)
                        self.db.inGameTimeColor = self:ConvRGBToHex(r, g, b)
                        self:UpdateClockStyle()
                    end,
                    disabled = function()
                        return not self.db.showInGameTime
                    end
                },
                {
                    type = "slider",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_CLOCK_INGAMETIME_FONTRATIO"),
                    min = 0,
                    max = 20,
                    getFunc = function()
                        return self.db.inGameTimeDelta
                    end,
                    setFunc = function(value)
                        self.db.inGameTimeDelta = value
                        self:UpdateClockStyle()
                    end,
                    disabled = function()
                        return not self.db.showInGameTime
                    end
                },
            },
        },
        {
            type = "submenu",
            name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_CHAT_TITLE"),
            tooltip = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_TOOLTIP_CHAT"),
            width = "full",
            controls = {
                {
                    type = "checkbox",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_CHAT_SHOW_TIMESTAMP"),
                    getFunc = function()
                        return self.db.showChatTimestamp
                    end,
                    setFunc = function(value)
                        self.db.showChatTimestamp = value
                    end,
                    default = self.defaults.showChatTimestamp,
                },
                {
                    type = "dropdown",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_CHAT_SHOW_RANKICONS"),
                    choices = showRankIconLabels,
                    choicesValues = showRankIcon,
                    getFunc = function()
                        return self.db.showChatGuildIcon
                    end,
                    setFunc = function(value)
                        self.db.showChatGuildIcon = value
                        ArcanumGuildHall:BuildGuildCache()
                    end,
                    default = self.defaults.showChatGuildIcon,
                },
                {
                    type = "checkbox",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_CHAT_SHOW_RANKICONSCOLOR"),
                    getFunc = function()
                        return self.db.showChatGuildIconColor
                    end,
                    setFunc = function(value)
                        self.db.showChatGuildIconColor = value
                        ArcanumGuildHall:BuildGuildCache()
                    end,
                    default = self.defaults.showChatGuildIconColor,
                },
            },
        },
        {
            type = "submenu",
            name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_ANNOUNCEMENTS_TITLE"),
            tooltip = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_TOOLTIP_ANNOUNCEMENTS"),
            width = "full",
            controls = {
                {
                    type = "checkbox",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_ANNOUNCEMENTS_SHOW_SCREEN"),
                    getFunc = function()
                        return self.db.showAnnouncements
                    end,
                    setFunc = function(value)
                        self.db.showAnnouncements = value
                    end,
                    default = self.defaults.showAnnouncements,
                },
                {
                    type = "checkbox",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_ANNOUNCEMENTS_SHOW_CHAT"),
                    getFunc = function()
                        return self.db.showChatAnnouncements
                    end,
                    setFunc = function(value)
                        self.db.showChatAnnouncements = value
                    end,
                    default = self.defaults.showChatAnnouncements,
                },
                {
                    type = "checkbox",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_ANNOUNCEMENTS_SHOW_NOTIF"),
                    getFunc = function()
                        return self.db.showNotifAnnouncements
                    end,
                    setFunc = function(value)
                        self.db.showNotifAnnouncements = value
                    end,
                    default = self.defaults.showNotifAnnouncements,
                },
            },
        },
        {
            type = "submenu",
            name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_REPAIR_TITLE"),
            tooltip = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_TOOLTIP_REPAIR"),
            width = "full",
            controls = {
                {
                    type = "header",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_REPAIR_STORES_HEADER"),
                },
                {
                    type = "dropdown",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_REPAIR_STORES"),
                    tooltip = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_TOOLTIP_REPAIR_STORES"),
                    choices = repairOptionLookup,
                    choicesValues = repairOption,
                    getFunc = function()
                        return self.db.storeRepairMode
                    end,
                    setFunc = function(value)
                        self.db.storeRepairMode = value
                    end,
                    default = self.defaults.storeRepairMode,
                },
                {
                    type = "checkbox",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_REPAIR_PRINT"),
                    getFunc = function()
                        return self.db.verboseStore
                    end,
                    setFunc = function(value)
                        self.db.verboseStore = value
                    end,
                    default = self.defaults.verboseStore,
                },
                {
                    type = "header",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_REPAIR_HEADER"),
                },
                {
                    type = "checkbox",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_REPAIR_KIT"),
                    getFunc = function()
                        return self.db.useAnyKit
                    end,
                    setFunc = function(value)
                        self.db.useAnyKit = value
                    end,
                    default = self.defaults.useAnyKit,
                },
                {
                    type = "slider",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_REPAIR_THRESHOLD"),
                    tooltip = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_TOOLTIP_REPAIR_THRESHOLD"),
                    min = 0, max = 100, step = 1,
                    getFunc = function()
                        return self.db.repairThreshold
                    end,
                    setFunc = function(value)
                        self.db.repairThreshold = value
                    end,
                    default = self.defaults.repairThreshold,
                },
                {
                    type = "checkbox",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_REPAIR_PRINT"),
                    getFunc = function()
                        return self.db.verboseKits
                    end,
                    setFunc = function(value)
                        self.db.verboseKits = value
                    end,
                    default = self.defaults.verboseKits,
                },
                {
                    type = "header",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_RECHARGE_HEADER"),
                },
                {
                    type = "dropdown",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_RECHARGE_AUTO"),
                    choices = rechargeOptionLookup,
                    choicesValues = rechargeOption,
                    getFunc = function()
                        return self.db.rechargeMode
                    end,
                    setFunc = function(value)
                        self.db.rechargeMode = value
                    end,
                    default = self.defaults.rechargeMode,
                },
                {
                    type = "checkbox",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_RECHARGE_GEM"),
                    getFunc = function()
                        return self.db.useAnyGem
                    end,
                    setFunc = function(value)
                        self.db.useAnyGem = value
                    end,
                    default = self.defaults.useAnyGem,
                },
                {
                    type = "slider",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_RECHARGE_THRESHOLD"),
                    tooltip = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_TOOLTIP_RECHARGE_THRESHOLD"),
                    min = 0, max = 100, step = 1,
                    getFunc = function()
                        return self.db.rechargeThreshold
                    end,
                    setFunc = function(value)
                        self.db.rechargeThreshold = value
                    end,
                    default = self.defaults.rechargeThreshold,
                },
                {
                    type = "checkbox",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_REPAIR_PRINT"),
                    getFunc = function()
                        return self.db.verboseGems
                    end,
                    setFunc = function(value)
                        self.db.verboseGems = value
                    end,
                    default = self.defaults.verboseGems,
                },
            }
        },
        {
            type = "submenu",
            name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_DECON_TITLE"),
            tooltip = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_TOOLTIP_DECON"),
            width = "full",
            controls = {
                {
                    type = "header",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_DECON_SELECT_TITLE"),
                },
                {
                    type = "checkbox",
                    name = QualityColoredName(1),
                    getFunc = function()
                        return self.db.deconQualityNormal
                    end,
                    setFunc = function(value)
                        self.db.deconQualityNormal = value
                        self:RefreshDeconSelectAll()
                    end,
                    default = self.defaults.deconQualityNormal,
                },
                {
                    type = "checkbox",
                    name = QualityColoredName(2),
                    getFunc = function()
                        return self.db.deconQualityFine
                    end,
                    setFunc = function(value)
                        self.db.deconQualityFine = value
                        self:RefreshDeconSelectAll()
                    end,
                    default = self.defaults.deconQualityFine,
                },
                {
                    type = "checkbox",
                    name = QualityColoredName(3),
                    getFunc = function()
                        return self.db.deconQualitySuperior
                    end,
                    setFunc = function(value)
                        self.db.deconQualitySuperior = value
                        self:RefreshDeconSelectAll()
                    end,
                    default = self.defaults.deconQualitySuperior,
                },
                {
                    type = "checkbox",
                    name = QualityColoredName(4),
                    getFunc = function()
                        return self.db.deconQualityEpic
                    end,
                    setFunc = function(value)
                        self.db.deconQualityEpic = value
                        self:RefreshDeconSelectAll()
                    end,
                    default = self.defaults.deconQualityEpic,
                },
                {
                    type = "checkbox",
                    name = QualityColoredName(5),
                    getFunc = function()
                        return self.db.deconQualityLegendary
                    end,
                    setFunc = function(value)
                        self.db.deconQualityLegendary = value
                        self:RefreshDeconSelectAll()
                    end,
                    default = self.defaults.deconQualityLegendary,
                },
                {
                    type = "divider",
                },
                {
                    type = "checkbox",
                    name = res.IconResearch .. " " .. ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_DECON_LABEL_RESEARCH"),
                    getFunc = function()
                        return self.db.deconResearchableItems
                    end,
                    setFunc = function(value)
                        self.db.deconResearchableItems = value
                        self:RefreshDeconSelectAll()
                    end,
                    default = self.defaults.deconResearchableItems,
                },
                {
                    type = "checkbox",
                    name = res.IconOrnate .. " " .. ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_DECON_LABEL_ORNATE"),
                    getFunc = function()
                        return self.db.deconOrnateItems
                    end,
                    setFunc = function(value)
                        self.db.deconOrnateItems = value
                        self:RefreshDeconSelectAll()
                    end,
                    default = self.defaults.deconOrnateItems,
                },
                {
                    type = "checkbox",
                    name = res.IconIntricate .. " " .. ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_DECON_LABEL_INTRICATE"),
                    getFunc = function()
                        return self.db.deconIntricateItems
                    end,
                    setFunc = function(value)
                        self.db.deconIntricateItems = value
                        self:RefreshDeconSelectAll()
                    end,
                    default = self.defaults.deconIntricateItems,
                },
            }
        },
        {
            type = "submenu",
            name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_CHALLENGES_TITLE"),
            tooltip = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_TOOLTIP_CHALLENGES"),
            width = "full",
            controls = {
                {
                    type = "dropdown",
                    name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_CHALLENGES_MODE"),
                    choices = challengeDisplayModeChoices,
                    choicesValues = challengeDisplayModeValues,
                    getFunc = function()
                        return self.db.challengeDisplayMode
                    end,
                    setFunc = function(value)
                        self.db.challengeDisplayMode = value
                    end,
                    default = self.defaults.challengeDisplayMode,
                },
            }
        },
        {
            type = "button",
            name = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_SHOW_CHANGELOGBUTTON"),
            func = function()
                ArcanumGuildHall_Changelog:SetHidden(false)
            end,
            width = "half",
        },
    }
    self.panel = LAM2:RegisterAddonPanel(self.name .. "Options", panelData)
    LAM2:RegisterOptionControls(self.name .. "Options", optionsTable)

    local function panelShown(currentPanel)
        if currentPanel == self.panel then
            panelOpen = true
            ArcanumGuildHall:UpdateAnchors(panelOpen)
        end
    end

    local function panelHidden()
        panelOpen = false
        ArcanumGuildHall:UpdateAnchors(panelOpen)
        ArcanumClock:SetHidden(true)
    end

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", panelShown)
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", panelHidden)
end