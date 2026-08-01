--[[--------------------------------------------
    Project:    Clock - Tamriel Standard Time
    Author:     Arne Rantzen (Tyx) & Phinix
    Created:    2020-02-16
    Updated:    2020-02-16
    License:    GPL-3.0
--------------------------------------------]]--

Clock_TST = Clock_TST or {}


--- Create the LibAddonMenu panel
function Clock_TST:SetupMenu()
    local const = self.CONSTANTS()
    local settings = self.settings
    local time = self.time
    local moon = self.moon
    local i18n = self.I18N().menu
    local lang = GetCVar("Language.2")
    local link = "https://" .. lang .. ".liberapay.com/Tyx/"
    local panel = {
        type = "panel",
        name = const.NAME,
        displayName = const.DISPLAY,
         author = "|c5175ea" .. const.AUTHOR .. "|r",
        version = const.VERSION,
        website = "https://rantzen.net/clock-tamriel-standard-time/",
        feedback = "https://github.com/Tyxz/Clock-Tamriel-Standard-Time/issues/new/choose",
        translation = "https://poeditor.com/join/project/NJq0ZZpySZ",
        donation = link,
        slashCommand = "/tstmenu",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    local LAM = LibAddonMenu2
    local options = setmetatable({}, { __index = table })

    -- ----------------
    -- Visibility
    -- ----------------

    --- Function to add fragment to game menu scene
    --- @param libPanel table  panel
    local function ShowFragment(libPanel)
        if libPanel == CLOCK_TST_MENU then
            GAME_MENU_SCENE:AddFragment(self.TIME_FRAGMENT)
            GAME_MENU_SCENE:AddFragment(self.MOON_FRAGMENT)
        end
    end

    --- Function to remove fragment from game menu scene
    --- @param libPanel table  panel
    local function HideFragment(libPanel)
        if libPanel == CLOCK_TST_MENU then
            GAME_MENU_SCENE:RemoveFragment(self.TIME_FRAGMENT)
            GAME_MENU_SCENE:RemoveFragment(self.MOON_FRAGMENT)
        end
    end

    --- Function to add callback to toggle visibility when panel is opened or closed
    local function RegisterCallback()
        CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", ShowFragment)
        CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", HideFragment)
    end

    --- Function to remove callback to toggle visibility when panel is opened or closed
    local function RemoveCallback()
        CALLBACK_MANAGER:UnregisterCallback("LAM-PanelOpened", ShowFragment)
        CALLBACK_MANAGER:UnregisterCallback("LAM-PanelClosed", HideFragment)
    end

    -- ----------------
    -- General
    -- ----------------
    --- Update the presets dropdown
    local function UpdatePresets()
        local choices = settings:GetPresets()
        CLOCK_TST_MENU_PRESETS:UpdateChoices(choices)
        CLOCK_TST_MENU_PRESETS:UpdateValue()
    end

    -- Create the general submenu
    local function AddGeneral()
        return {
            {
                type = "dropdown",
                choices = settings:GetPresets(),
                getFunc = function() return settings:GetCurrentPreset() end,
                setFunc = function(value)
                    LAM.util.ShowConfirmationDialog(i18n.presets.nPreset, i18n.presets.nWarning, function()
                        RemoveCallback()
                        settings:ApplyPreset(value)
                        self:SetupTime()
                        self:SetupMoon()
                        RegisterCallback()
                        ShowFragment(CLOCK_TST_MENU)
                        if value == "Default" then
                            settings:SetCurrentPreset(nil)
                        end
                        CLOCK_TST_MENU:RefreshPanel()
                    end)
                end,
                name = i18n.presets.nPreset,
                warning = i18n.presets.wPreset,
                width = "half",
                reference = "CLOCK_TST_MENU_PRESETS"
            },
            {
                type = "editbox",
                getFunc = function()
                    return settings:GetCurrentPreset()
                end,
                setFunc = function(value)
                    if string.find(value, "%S") then
                        settings:SetCurrentPreset(value)
                        CLOCK_TST_MENU_PRESET_SAVE:UpdateWarning()
                    end
                end,
                name = i18n.presets.nCurrent,
                width = "half",
            },
            {
                type = "button",
                name = i18n.presets.nSave,
                warning = i18n.presets.wSave,
                isDangerous = settings:CurrentPresetExists(),
                func = function()
                    settings:AddPreset(settings:GetCurrentPreset())
                    UpdatePresets()
                    CLOCK_TST_MENU:RefreshPanel()
                end,
                disabled = function() return not settings:GetCurrentPreset() end,
                width = "half",
                reference = "CLOCK_TST_MENU_PRESET_SAVE"
            },
            {
                type = "button",
                name = i18n.presets.nDelete,
                warning = i18n.presets.wDelete,
                isDangerous = true,
                func = function()
                    settings:RemovePreset(settings:GetCurrentPreset())
                    UpdatePresets()
                    CLOCK_TST_MENU:RefreshPanel()
                end,
                disabled = function() return not settings:GetCurrentPreset() or not settings:CurrentPresetExists() end,
                width = "half",
                reference = "CLOCK_TST_MENU_PRESET_DELETE"
            },
            {
                type = "header",
                name = i18n.booleans.nSub,
            },
            {
                type = "checkbox",
                getFunc = function()
                    return settings:GetSaveAccountWide()
                end,
                setFunc = function(value)
                    settings:SetSaveAccountWide(value)
                end,
                requiresReload = true,
                name = i18n.account.nAccount,
                tooltip = i18n.account.tAccount
            },
            {
                type = "divider"
            },
            {
                type = "checkbox",
                getFunc = function()
                    return settings:GetHideInGroup()
                end,
                setFunc = function(value)
                    settings:SetHideInGroup(value)
                    if value then
                        settings:SetOnlyShowOnMap(not value)
                    end

                    time:UpdateVisibility()
                    moon:UpdateVisibility()
                end,
                disabled = function()
                    return not (settings:GetTimeIsVisible() and settings:GetMoonIsVisible())
                end,
                name = i18n.booleans.nGroup,
            },
            {
                type = "checkbox",
                getFunc = function()
                    return settings:GetHideInFight()
                end,
                setFunc = function(value)
                    settings:SetHideInFight(value)
                    if value then
                        settings:SetOnlyShowOnMap(not value)
                    end

                    time:UpdateVisibility()
                    moon:UpdateVisibility()
                end,
                disabled = function()
                    return not (settings:GetTimeIsVisible() and settings:GetMoonIsVisible())
                end,
                name = i18n.booleans.nFight,
            },
            {
                type = "checkbox",
                getFunc = function()
                    return settings:GetOnlyShowOnMap()
                end,
                setFunc = function(value)
                    settings:SetOnlyShowOnMap(value)
                    if value then
                        settings:SetHideInFight(not value)
                        settings:SetHideInGroup(not value)
                    end

                    time:UpdateVisibility()
                    moon:UpdateVisibility()
                end,
                disabled = function()
                    return not (settings:GetTimeIsVisible() and settings:GetMoonIsVisible())
                end,
                name = i18n.booleans.nMap,
            },
            {
                type = "checkbox",
                getFunc = function()
                    return settings:GetTimeAndMoonAreLinked()
                end,
                setFunc = function(value)
                    settings:SetTimeAndMoonAreLinked(value)
                end,
                disabled = function()
                    return not (settings:GetTimeIsVisible() and settings:GetMoonIsVisible())
                end,
                name = i18n.booleans.nLink,
            },
            {
                type = "header",
                name = i18n.styles.nSub,
            },
            {
                type = "description",
                title = i18n.styles.nFormat,
                text = i18n.styles.tFormat,
            },
            {
                type = "description",
                text = i18n.styles.dFormat,
                width = "half",
            },
            {
                type = "editbox",
                disabled = function()
                    return not settings:GetTimeIsVisible()
                end,
                getFunc = function()
                    return settings:GetTimeFormat()
                end,
                setFunc = function(value)
                    settings:SetTimeFormat(value)
                    local _, count = string.gsub(value, "\n", "")
                    if count == 0 then
                        count = 1
                    end
                    settings:SetTimeLineCount(count)
                    local _, loreCount = string.gsub(value, "#", "")
                    settings:SetTimeHasLoreDate(loreCount ~= 0)
                    local _, realCount = string.gsub(value, "%%", "")
                    settings:SetTimeHasRealDate(realCount ~= 0)
                    local _, fakeCount = string.gsub(value, "$", "")
                    settings:SetTimeHasFakeLoreDate(fakeCount ~= 0)
                --  settings:SetTimeIsVisible(realCount ~= 0 or loreCount ~= 0)
                    time:ResetReplacement()
                end,
                isMultiline = true,
                width = "half",
            },
            {
                type = "slider",
                min = 1,
                max = 4,
                step = .1,
                getFunc = function()
                    return settings:GetScaleFactor()
                end,
                setFunc = function(value)
                    settings:SetScaleFactor(value)
                end,
                name = i18n.styles.nScaleFactor,
                tooltip = i18n.styles.tScaleFactor,
            },
        }
    end

    -- ----------------
    -- Time
    -- ----------------

    -- Create the time submenu
    local function AddTime()
        return {
            type = "submenu",
            name = i18n.core.nHeadTime,
            controls = {
                {
                    type = "header",
                    name = i18n.booleans.nSub,
                },
                {
                    type = "checkbox",
                    getFunc = function()
                        return settings:GetTimeIsVisible()
                    end,
                    setFunc = function(value)
                        settings:SetTimeIsVisible(value)
                        time:UpdateVisibility()
                        time:UpdateMouse()
                    end,
                    name = i18n.booleans.nTimeVisible,
                },
                {
                    type = "checkbox",
                    getFunc = function()
                        return settings:GetTimeIsMouseEnabled()
                    end,
                    setFunc = function(value)
                        settings:SetTimeIsMouseEnabled(value)
                        time:UpdateMouse()
                    end,
                    disabled = function()
                        return not settings:GetTimeIsVisible()
                    end,
                    name = i18n.booleans.nMouseEnabled,
                },
                {
                    type = "checkbox",
                    getFunc = function()
                        return settings:GetTimeIsMovable()
                    end,
                    setFunc = function(value)
                        settings:SetTimeIsMovable(value)
                        time:UpdateMouse()
                    end,
                    disabled = function()
                        return not (settings:GetTimeIsMouseEnabled() and settings:GetTimeIsVisible())
                    end,
                    name = i18n.booleans.nMovable,
                    tooltip = i18n.booleans.tMovable,

                },
                {
                    type = "checkbox",
                    getFunc = function()
                        return settings:GetTimeHasTooltip()
                    end,
                    setFunc = function(value)
                        settings:SetTimeHasTooltip(value)
                        time:UpdateTooltip()
                    end,
                    disabled = function()
                        return not (settings:GetTimeIsMouseEnabled() and settings:GetTimeIsVisible())
                    end,
                    name = i18n.booleans.nTooltip,
                },
                {
                    type = "checkbox",
                    getFunc = function()
                        return settings:GetTimeHasBackground()
                    end,
                    setFunc = function(value)
                        settings:SetTimeHasBackground(value)
                        time:UpdateVisibility()
                    end,
                    disabled = function()
                        return not settings:GetTimeIsVisible()
                    end,
                    name = i18n.booleans.nBackground,
                    tooltip = i18n.booleans.tTimeBackground,
                },
                {
                    type = "checkbox",
                    getFunc = function()
                        return settings:GetTimeAddZero("hour")
                    end,
                    setFunc = function(value)
                        settings:SetTimeAddZero(value, "hour")
                    end,
                    disabled = function()
                        return not settings:GetTimeIsVisible()
                    end,
                    name = i18n.booleans.nAddZeroHour,
                    tooltip = i18n.booleans.tAddZeroHour,
                    warning = i18n.booleans.wAffect,
                },
                {
                    type = "checkbox",
                    getFunc = function()
                        return settings:GetTimeAddZero("min")
                    end,
                    setFunc = function(value)
                        settings:SetTimeAddZero(value, "min")
                    end,
                    disabled = function()
                        return not settings:GetTimeIsVisible()
                    end,
                    name = i18n.booleans.nAddZeroMin,
                    tooltip = i18n.booleans.tAddZeroMin,
                    warning = i18n.booleans.wAffect,
                },
                {
                    type = "checkbox",
                    getFunc = function()
                        return settings:GetTimeAddZero("sec")
                    end,
                    setFunc = function(value)
                        settings:SetTimeAddZero(value, "sec")
                    end,
                    disabled = function()
                        return not settings:GetTimeIsVisible()
                    end,
                    name = i18n.booleans.nAddZeroSec,
                    tooltip = i18n.booleans.tAddZeroSec,
                    warning = i18n.booleans.wAffect,
                },
                {
                    type = "checkbox",
                    getFunc = function()
                        return settings:GetTimeAddZero("day")
                    end,
                    setFunc = function(value)
                        settings:SetTimeAddZero(value, "day")
                    end,
                    disabled = function()
                        return not settings:GetTimeIsVisible()
                    end,
                    name = i18n.booleans.nAddZeroDay,
                    tooltip = i18n.booleans.tAddZeroDay,
                    warning = i18n.booleans.wAffect,
                },
                {
                    type = "checkbox",
                    getFunc = function()
                        return settings:GetTimeAddZero("month")
                    end,
                    setFunc = function(value)
                        settings:SetTimeAddZero(value, "month")
                    end,
                    disabled = function()
                        return not settings:GetTimeIsVisible()
                    end,
                    name = i18n.booleans.nAddZeroMonth,
                    tooltip = i18n.booleans.tAddZeroMonth,
                    warning = i18n.booleans.wAffect,
                },
                {
                    type = "checkbox",
                    getFunc = function()
                        return settings:GetTimeHasUSFormat()
                    end,
                    setFunc = function(value)
                        settings:SetTimeHasUSFormat(value)
                    end,
                    disabled = function()
                        return not settings:GetTimeIsVisible()
                    end,
                    name = i18n.booleans.nUSFormat,
                },
                {
                    type = "checkbox",
                    getFunc = function()
                        return settings:GetMinimalAMPM()
                    end,
                    setFunc = function(value)
                        settings:SetMinimalAMPM(value)
                    end,
                    disabled = function()
                        return not settings:GetTimeIsVisible()
                    end,
                    name = i18n.booleans.nMinAMPM,
					tooltip = i18n.booleans.tMinAMPM,
                },
                {
                    type = "checkbox",
                    getFunc = function()
                        return settings:GetTimeHasJapFormat()
                    end,
                    setFunc = function(value)
                        settings:SetTimeHasJapFormat(value)
                    end,
                    disabled = function()
                        return not (settings:GetTimeHasUSFormat() and settings:GetTimeIsVisible())
                    end,
                    name = i18n.booleans.nJapanese,
                    warning = i18n.booleans.wAffect,
                },
                {
                    type = "checkbox",
                    getFunc = function()
                        return settings:GetTimeScaleWhenHover()
                    end,
                    setFunc = function(value)
                        settings:SetTimeScaleWhenHover(value)
                    end,
                    disabled = function()
                        return not settings:GetTimeIsVisible()
                    end,
                    name = i18n.booleans.nHoverScale,
                },
                {
                    type = "checkbox",
                    getFunc = function()
                        return settings:GetTimeHighlightWhenHover()
                    end,
                    setFunc = function(value)
                        settings:SetTimeHighlightWhenHover(value)
                    end,
                    disabled = function()
                        return not settings:GetTimeIsVisible()
                    end,
                    name = i18n.booleans.nHoverColour,
                },
                {
                    type = "header",
                    name = i18n.styles.nSub
                },
                {
                    type = "colorpicker",
                    disabled = function()
                        return not settings:GetTimeIsVisible()
                    end,
                    getFunc = function()
                        return settings:GetTimeColour()
                    end,
                    setFunc = function(r, g, b, a)
                        settings:SetTimeColour(r, g, b, a)
                        time:UpdateStyle()
                    end,
                    name = i18n.styles.nColor,
                    tooltip = i18n.styles.tColor,
                    width = "half",
                },
                {
                    type = "slider",
                    disabled = function()
                        return not settings:GetTimeIsVisible()
                    end,
                    min = 4,
                    max = 72,
                    step = 2,
                    getFunc = function()
                        return settings:GetTimeSize()
                    end,
                    setFunc = function(value)
                        settings:SetTimeSize(value)
                        time:UpdateStyle()
                        time:ResetReplacement()
                    end,
                    name = i18n.styles.nSize,
                    tooltip = i18n.styles.tSize,
                    width = "half",
                },
                {
                    type = "dropdown",
                    disabled = function()
                        return not settings:GetTimeIsVisible()
                    end,
                    choices = const.Menu.time.FONTS,
                    getFunc = function()
                        return settings:GetTimeFont()
                    end,
                    setFunc = function(value)
                        settings:SetTimeFont(value)
                        time:UpdateStyle()
                        time:ResetReplacement()
                    end,
                    name = i18n.styles.nFont,
                    tooltip = i18n.styles.tFont,
                    width = "half",
                },
                {
                    type = "dropdown",
                    disabled = function()
                        return not settings:GetTimeIsVisible()
                    end,
                    choices = const.Menu.time.STYLES,
                    getFunc = function()
                        return settings:GetTimeStyle()
                    end,
                    setFunc = function(value)
                        settings:SetTimeStyle(value)
                        time:UpdateStyle()
                    end,
                    name = i18n.styles.nStyle,
                    tooltip = i18n.styles.tStyle,
                    width = "half",
                },
                {
                    type = "dropdown",
                    disabled = function()
                        return not settings:GetTimeIsVisible()
                    end,
                    choices = const.Menu.time.BACKGROUND,
                    getFunc = function()
                        return settings:GetTimeBackground()
                    end,
                    setFunc = function(value)
                        settings:SetTimeBackground(value)
                        time:UpdateBackground()
                    end,
                    name = i18n.styles.nBackground,
                    width = "half",
                },
                {
                    type = "description",
                },
                {
                    type = "slider",
                    disabled = function()
                        return not settings:GetTimeIsVisible()
                    end,
                    min = -500,
                    max = 500,
                    step = 10,
                    getFunc = function()
                        return settings:GetTimeBackgroundOffset().x
                    end,
                    setFunc = function(value)
                        local y = settings:GetTimeBackgroundOffset().y
                        settings:SetTimeBackgroundOffset({
                            x = value,
                            y = y
                        })
                        time:ResetReplacement()
                    end,
                    name = i18n.styles.nBackgroundOffsetX,
                    tooltip = i18n.styles.tBackgroundOffsetX,
                    width = "half",
                },
                {
                    type = "slider",
                    disabled = function()
                        return not settings:GetTimeIsVisible()
                    end,
                    min = -500,
                    max = 500,
                    step = 10,
                    getFunc = function()
                        return settings:GetTimeBackgroundOffset().y
                    end,
                    setFunc = function(value)
                        local x = settings:GetTimeBackgroundOffset().x
                        settings:SetTimeBackgroundOffset({
                            x = x,
                            y = value,
                        })
                        time:ResetReplacement()
                    end,
                    name = i18n.styles.nBackgroundOffsetY,
                    tooltip = i18n.styles.tBackgroundOffsetY,
                    width = "half",
                },
                {
                    type = "colorpicker",
                    disabled = function()
                        return not settings:GetTimeIsVisible()
                    end,
                    getFunc = function()
                        return settings:GetTimeBackgroundColour()
                    end,
                    setFunc = function(r, g, b, a)
                        settings:SetTimeBackgroundColour(r, g, b, a)
                        time:UpdateBackground()
                    end,
                    name = i18n.styles.nBackgroundColour,
                    width = "half",
                },
                {
                    type = "colorpicker",
                    disabled = function()
                        return not settings:GetTimeIsVisible()
                    end,
                    getFunc = function()
                        return settings:GetTimeBackgroundHoverColour()
                    end,
                    setFunc = function(r, g, b, a)
                        settings:SetTimeBackgroundHoverColour(r, g, b, a)
                    end,
                    name = i18n.styles.nBackgroundHoverColour,
                    width = "half",
                },
            }
        }
    end

    -- ----------------
    -- Moon
    -- ----------------

    --- Create the Moon submenu
    local function AddMoon()
        return {
            type = "submenu",
            name = i18n.core.nHeadMoon,
            controls = {
                {
                    type = "header",
                    name = i18n.booleans.nSub,
                },
                {
                    type = "checkbox",
                    getFunc = function()
                        return settings:GetMoonIsVisible()
                    end,
                    setFunc = function(value)
                        settings:SetMoonIsVisible(value)
                        moon:UpdateVisibility()
                        moon:UpdateMouse()
                    end,
                    name = i18n.booleans.nMoonVisible,
                },
                {
                    type = "checkbox",
                    getFunc = function()
                        return settings:GetMoonIsMouseEnabled()
                    end,
                    setFunc = function(value)
                        settings:SetMoonIsMouseEnabled(value)
                        moon:UpdateMouse()
                    end,
                    disabled = function()
                        return not settings:GetMoonIsVisible()
                    end,
                    name = i18n.booleans.nMouseEnabled,
                },
                {
                    type = "checkbox",
                    getFunc = function()
                        return settings:GetMoonIsMovable()
                    end,
                    setFunc = function(value)
                        settings:SetMoonIsMovable(value)
                        moon:UpdateMouse()
                    end,
                    disabled = function()
                        return not (settings:GetMoonIsMouseEnabled() and settings:GetMoonIsVisible())
                    end,
                    name = i18n.booleans.nMovable,
                    tooltip = i18n.booleans.tMovable,

                },
                {
                    type = "checkbox",
                    getFunc = function()
                        return settings:GetMoonHasTooltip()
                    end,
                    setFunc = function(value)
                        settings:SetMoonHasTooltip(value)
                        moon:RegisterForUpdates()
                    end,
                    disabled = function()
                        return not (settings:GetMoonIsMouseEnabled() and settings:GetMoonIsVisible())
                    end,
                    name = i18n.booleans.nTooltip,
                },
                {
                    type = "checkbox",
                    getFunc = function()
                        return settings:GetMoonHasBackground()
                    end,
                    setFunc = function(value)
                        settings:SetMoonHasBackground(value)
                        moon:UpdateVisibility()
                    end,
                    disabled = function()
                        return not settings:GetMoonIsVisible()
                    end,
                    name = i18n.booleans.nBackground,
                },
                {
                    type = "checkbox",
                    getFunc = function()
                        return settings:GetMoonScaleWhenHover()
                    end,
                    setFunc = function(value)
                        settings:SetMoonScaleWhenHover(value)
                    end,
                    disabled = function()
                        return not settings:GetMoonIsVisible()
                    end,
                    name = i18n.booleans.nHoverScale,
                },
                {
                    type = "checkbox",
                    getFunc = function()
                        return settings:GetMoonHighlightWhenHover()
                    end,
                    setFunc = function(value)
                        settings:SetMoonHighlightWhenHover(value)
                    end,
                    disabled = function()
                        return not settings:GetMoonIsVisible()
                    end,
                    name = i18n.booleans.nHoverColour,
                },
                {
                    type = "header",
                    name = i18n.styles.nSub,
                },
                {
                    type = "slider",
                    disabled = function()
                        return not settings:GetMoonIsVisible()
                    end,
                    min = 0,
                    max = 200,
                    step = 1,
                    getFunc = function()
                        return settings:GetMoonScale() * 100
                    end,
                    setFunc = function(value)
                        settings:SetMoonScale(value * .01)
                        moon:SetupScale()
                    end,
                    name = i18n.styles.nScale,
                    width = "half",
                },
                {
                    type = "slider",
                    disabled = function()
                        return not settings:GetMoonIsVisible()
                    end,
                    min = 0,
                    max = 100,
                    step = 1,
                    getFunc = function()
                        return settings:GetMoonAlpha() * 100
                    end,
                    setFunc = function(value)
                        settings:SetMoonAlpha(value * .01)
                        moon:RegisterForUpdates()
                    end,
                    name = i18n.styles.nAlpha,
                    width = "half",
                },
                {
                    type = "dropdown",
                    disabled = function()
                        return not settings:GetMoonIsVisible()
                    end,
                    choices = const.Menu.moon.MASSER,
                    getFunc = function()
                        return settings:GetMoonTextureKeyMasser()
                    end,
                    setFunc = function(value)
                        settings:SetMoonTextureKeyMasser(value)
                        moon:RegisterForUpdates()
                    end,
                    name = i18n.styles.nMasser,
                    width = "half",
                },
                {
                    type = "dropdown",
                    disabled = function()
                        return not settings:GetMoonIsVisible()
                    end,
                    choices = const.Menu.moon.SECUNDA,
                    getFunc = function()
                        return settings:GetMoonTextureKeySecunda()
                    end,
                    setFunc = function(value)
                        settings:SetMoonTextureKeySecunda(value)
                        moon:RegisterForUpdates()
                    end,
                    name = i18n.styles.nSecunda,
                    width = "half",
                },
                {
                    type = "dropdown",
                    disabled = function()
                        return not settings:GetMoonIsVisible()
                    end,
                    choices = const.Menu.moon.BACKGROUND,
                    getFunc = function()
                        return settings:GetMoonBackground()
                    end,
                    setFunc = function(value)
                        settings:SetMoonBackground(value)
                        moon:RegisterForUpdates()
                    end,
                    name = i18n.styles.nBackground,
                    width = "half",
                },
                {
                    type = "description",
                },
                {
                    type = "slider",
                    disabled = function()
                        return not settings:GetMoonIsVisible()
                    end,
                    min = settings:GetMoonMasserAttributes().dimension.height,
                    max = settings:GetMoonMasserAttributes().dimension.height * 5,
                    step = 5,
                    getFunc = function()
                        return settings:GetMoonDimension().height
                    end,
                    setFunc = function(value)
                        local width = settings:GetMoonDimension().width
                        settings:SetMoonDimension({
                            width = width,
                            height = value
                        })
                        moon:UpdatePositions()
                    end,
                    name = i18n.styles.nMoonHeight,
                    width = "half",
                },
                {
                    type = "slider",
                    disabled = function()
                        return not settings:GetMoonIsVisible()
                    end,
                    min = settings:GetMoonMasserAttributes().dimension.width,
                    max = settings:GetMoonMasserAttributes().dimension.width * 5,
                    step = 5,
                    getFunc = function()
                        return settings:GetMoonDimension().width
                    end,
                    setFunc = function(value)
                        local height = settings:GetMoonDimension().height
                        settings:SetMoonDimension({
                            width = value,
                            height = height,
                        })
                        moon:UpdatePositions()
                    end,
                    name = i18n.styles.nMoonWidth,
                    width = "half",
                },
                {
                    type = "colorpicker",
                    disabled = function()
                        return not settings:GetMoonIsVisible()
                    end,
                    getFunc = function()
                        return settings:GetMoonBackgroundColour()
                    end,
                    setFunc = function(r, g, b, a)
                        settings:SetMoonBackgroundColour(r, g, b, a)
                        moon:UpdateBackground()
                    end,
                    name = i18n.styles.nBackgroundColour,
                    width = "half",
                },
                {
                    type = "colorpicker",
                    disabled = function()
                        return not settings:GetMoonIsVisible()
                    end,
                    getFunc = function()
                        return settings:GetMoonBackgroundHoverColour()
                    end,
                    setFunc = function(r, g, b, a)
                        settings:SetMoonBackgroundHoverColour(r, g, b, a)
                    end,
                    name = i18n.styles.nBackgroundHoverColour,
                    width = "half",
                },
            }
        }
    end

    -- ----------------
    -- Debug
    -- ----------------

    --- Create the Debug submenu
    local function AddDebug()
        return {
            type = "submenu",
            name = i18n.core.nHeadDebug,
            controls = {
                {
                    type = "checkbox",
                    getFunc = function()
                        return settings:GetDebug()
                    end,
                    setFunc = function(value)
                        settings:SetDebug(value)
                    end,
                    name = i18n.booleans.nDebug
                },
            }
        }
    end

    -- ----------------
    -- Feedback
    -- ----------------

    local function AddFeedback()
        if LibFeedback then
            local buttons =
            {
                { panel.feedback, i18n.feedback.nGitHub, false },
            }
            local worldName = GetWorldName()
            if worldName == "EU Megaserver" then
                table.insert(buttons, { 0, i18n.feedback.nMail, false })
                table.insert(buttons, { 5000, i18n.feedback.nLessGold, true })
                table.insert(buttons, { 50000, i18n.feedback.nMoreGold, true })
            end
            table.insert(buttons, { panel.donation, i18n.feedback.nRealGold, false })
            return LibFeedback:initializeFeedbackWindow(
                    self,
                    const.NAME,
                    CLOCK_TST_MENU,
                    const.AUTHOR,
                    {12 , CLOCK_TST_MENU, 12 , -20, 20}, -- Anchor
                    buttons,
                    i18n.feedback.tFeedback
            )
        end
    end

    -- ----------------
    -- Register
    -- ----------------
    panel.resetFunc = function()
        settings:Reset()
        self:SetupTime()
        self:SetupMoon()
        UpdatePresets()
    end
    CLOCK_TST_MENU = LAM:RegisterAddonPanel(const.NAME, panel)

    options = Clock_TST.MergeTable(options, AddGeneral())
    options:insert(AddTime())
    options:insert(AddMoon())
    options:insert(AddDebug())
    AddFeedback()

    LAM:RegisterOptionControls(const.NAME, options)

    RegisterCallback()
end
