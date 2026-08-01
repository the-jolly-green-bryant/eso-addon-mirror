local ST = SlayerTracker

---------------------------------------------------------------------------
-- CREATE SETTINGS (MENU)
---------------------------------------------------------------------------
function ST.CreateSettings()
    local LAM2 = LibAddonMenu2

    if not LAM2 then return end

    local panelName = "Slayer Tracker"
    if GetUnitDisplayName("player") == ST.AUTHOR then panelName = "[Dev] " .. panelName end

    local panelData = {
        type = "panel",
        name = panelName,
        displayName = "|cFF7F00Slayer|r |cFFFFFFTracker|r",
        author = "|cFF7F00" .. ST.AUTHOR .. "|r |cFFFFFF[EU]|r",
        version = ST.VERSION,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local function GetColorDefault(ColorArray)
        return { r = ColorArray[1], g = ColorArray[2], b = ColorArray[3], a = ColorArray[4] }
    end

    local function RefreshPreview()
        if ST.isPreview then
            ST.PARENT:SetHidden(false)
            ST.isActive = true
            ST.endTime = GetGameTimeMilliseconds() + 15000
            ST.uptimePercentage = 62
            ST.expSec = 50
            ST.UpdateVisuals()
        end
    end

    local iconTank = "|t20:20:/esoui/art/lfg/lfg_icon_tank.dds|t"
    local iconHealer = "|t20:20:/esoui/art/lfg/lfg_icon_healer.dds|t"
    local iconDPS = "|t20:20:/esoui/art/lfg/lfg_icon_dps.dds|t"
    local iconScroll = "|t20:20:/esoui/art/journal/journal_tabicon_cadwell_up.dds|t"

    local optionsData = {
        {
            type = "checkbox",
            name = "|cFF7F00MASTERSWITCH|r (Turns the entire addon ON/OFF)",
            getFunc = function() return ST.SV.enableAddon end,
            setFunc = function(value)
                ST.SV.enableAddon = value
                if value then ST.Enable() else ST.Disable() end
            end,
            default = ST.Default.enableAddon,
        },
        {
			type = "description",
			text = "Type |cFF7F00/slayertracker|r to |cFF0000LOCK|r or |c00FF00UNLOCK|r the tracker and reposition it.",
			width = "full"
		},
        {
            type = "button",
            name = "Toggle Preview",
            tooltip = "Forces tracker to show.",
            func = function()
                ST.isPreview = not ST.isPreview
                if ST.isPreview then
                    RefreshPreview()
                else
                    ST.CheckCurrentBuffs()
                    ST.UpdateVisibility()
                end
            end,
            disabled = function() return not ST.SV.enableAddon end,
            width = "half",
        },
        {
            type = "button",
            name = "Reset Position",
            tooltip = "Resets UI position to Default.",
            func = function() ST.SetDefaultPosition() end,
            disabled = function() return not ST.SV.enableAddon end,
            width = "half",
        },

        -- SUBMENU: VISIBILITY & ROLE FILTERS
        {
            type = "submenu",
            name = "|cFF7F00VISIBILITY & ROLE FILTERS|r",
            controls = {
                {
                    type = "dropdown",
                    name = "Visibility Mode",
                    tooltip = "Choose when the tracker should be visible.",
                    choices = {"Always Show", "Smart In Combat", "Only Show Active Buff"},
                    choicesValues = {1, 2, 3},
                    getFunc = function() return ST.SV.visibilityMode end,
                    setFunc = function(value)
                        ST.SV.visibilityMode = value
                        ST.UpdateVisibility()
                    end,
                    default = ST.Default.visibilityMode,
                    disabled = function() return not ST.SV.enableAddon end,
                },
                { type = "header", name = "|cFFBF7FRole Filters|r" },
                {
                    type = "checkbox", name = "Enable as Tank " .. iconTank,
                    getFunc = function() return ST.SV.isEnabledTank end,
                    setFunc = function(value)
                        ST.SV.isEnabledTank = value
                        ST.UpdateVisibility()
                    end,
                    default = ST.Default.isEnabledTank,
                    disabled = function() return not ST.SV.enableAddon end,
                },
                {
                    type = "checkbox", name = "Enable as Healer " .. iconHealer,
                    getFunc = function() return ST.SV.isEnabledHeal end,
                    setFunc = function(value)
                        ST.SV.isEnabledHeal = value
                        ST.UpdateVisibility()
                    end,
                    default = ST.Default.isEnabledHeal,
                    disabled = function() return not ST.SV.enableAddon end,
                },
                {
                    type = "checkbox", name = "Enable as DPS " .. iconDPS,
                    getFunc = function() return ST.SV.isEnabledDPS end,
                    setFunc = function(value)
                        ST.SV.isEnabledDPS = value
                        ST.UpdateVisibility()
                    end,
                    default = ST.Default.isEnabledDPS,
                    disabled = function() return not ST.SV.enableAddon end,
                },
                {
                    type = "checkbox", name = "Enable as Solo " .. iconScroll,
                    getFunc = function() return ST.SV.isEnabledSolo end,
                    setFunc = function(value)
                        ST.SV.isEnabledSolo = value
                        ST.UpdateVisibility()
                    end,
                    default = ST.Default.isEnabledSolo,
                    disabled = function() return not ST.SV.enableAddon end,
                },
            },
        },

        -- SUBMENU: DESIGN & SCALING
        {
            type = "submenu",
            name = "|cFF7F00DESIGN & SCALING|r",
            controls = {
                {
                    type = "checkbox",
                    name = "|cFF0000Lock Position|r",
                    tooltip = "Locks position of the tracker.",
                    getFunc = function() return ST.SV.isLocked end,
                    setFunc = function(value)
                        ST.SV.isLocked = value
                        ST.PARENT:SetMovable(not value)
                        ST.PARENT:SetMouseEnabled(not value)
                    end,
                    disabled = function() return not ST.SV.enableAddon end,
                    default = ST.Default.isLocked,
                },

                { type = "header", name = "|cFFBF7FGeneral Design|r" },
                {
                    type = "checkbox",
                    name = "Show Background & Border",
                    tooltip = "Disable this option to only see the remaining time.",
                    getFunc = function() return ST.SV.isShowBackground end,
                    setFunc = function(value)
                        ST.SV.isShowBackground = value
                        RefreshPreview()
                    end,
                    disabled = function() return not ST.SV.enableAddon end,
                    default = ST.Default.isShowBackground,
                },
                {
                    type = "checkbox", name = "Thick Outline Font",
                    getFunc = function() return ST.SV.isThickOutline end,
                    setFunc = function(value)
                        ST.SV.isThickOutline = value
                        ST.UpdateFonts(); RefreshPreview()
                    end,
                    default = ST.Default.isThickOutline,
                    disabled = function() return not ST.SV.enableAddon end,
                },
                {
                    type = "slider", name = "Icon Size",
                    min = 40, max = 100, step = 1,
                    getFunc = function() return ST.SV.iconSize end,
                    setFunc = function(value)
                        ST.SV.iconSize = value
                        ST.PARENT:SetDimensions(value, value)
                        ST.BG:SetDimensions(value, value)

                        local innerSize = math.max(1, value - (ST.SV.borderThickness * 2))
                        ST.ICON:SetDimensions(innerSize, innerSize)
                    end,
                    default = ST.Default.iconSize,
                    disabled = function() return not ST.SV.isShowBackground end
                },
                {
                    type = "slider", name = "Border Thickness",
                    min = 0, max = 10, step = 1,
                    getFunc = function() return ST.SV.borderThickness end,
                    setFunc = function(value)
                        ST.SV.borderThickness = value
                        local innerSize = math.max(1, ST.SV.iconSize - (value * 2))
                        ST.ICON:SetDimensions(innerSize, innerSize)
                    end,
                    default = ST.Default.borderThickness,
                    disabled = function() return not ST.SV.isShowBackground end
                },
                {
                    type = "slider", name = "Edge Thickness",
                    min = 0, max = 2, step = 1,
                    getFunc = function() return ST.SV.edgeThickness end,
                    setFunc = function(value)
                        ST.SV.edgeThickness = value
                        ST.BG:SetEdgeTexture("", 1, 1, ST.SV.edgeThickness, 0)
                        if ST.SV.edgeThickness == 0 then
                            ST.BG:SetEdgeColor(0, 0, 0, 0)
                        else
                            ST.BG:SetEdgeColor(0, 0, 0, 1)
                        end
                    end,
                    default = ST.Default.edgeThickness,
                    disabled = function() return not ST.SV.isShowBackground end
                },
                {
                    type = "checkbox", name = "Use Alternative Icon",
                    tooltip = "Choose between the axe or the red buff icon.",
                    getFunc = function() return ST.SV.isAlternativeIcon end,
                    setFunc = function(value)
                        ST.SV.isAlternativeIcon = value
                        ST.SV.textureIcon = GetAbilityIcon((value and ST.MAJOR_SLAYER_ICON) or ST.MAJOR_SLAYER_ID)
                        ST.ICON:SetTexture(ST.SV.textureIcon)
                        RefreshPreview()
                    end,
                    default = ST.Default.isAlternativeIcon,
                    disabled = function() return not ST.SV.enableAddon end,
                },
                {
                    type = "slider", name = "Icon Desaturation (100 = B/W)",
                    min = 0, max = 100, step = 5,
                    getFunc = function() return ST.SV.iconDesaturation end,
                    setFunc = function(value)
                        ST.SV.iconDesaturation = value
                        ST.ICON:SetDesaturation(value / 100)
                    end,
                    default = ST.Default.iconDesaturation,
                    disabled = function() return not ST.SV.enableAddon end,
                },

                { type = "header", name = "|cFFBF7FColors (Border Gradient)|r" },
                {
                    type = "slider", name = "Gradient Threshold [sec]",
                    tooltip = "Time at which the gradient starts fading from Start to End.",
                    min = 0, max = 30, step = 1,
                    getFunc = function() return ST.SV.colorThreshold end,
                    setFunc = function(value)
                        ST.SV.colorThreshold = value
                        RefreshPreview()
                    end,
                    default = ST.Default.colorThreshold,
                    disabled = function() return not ST.SV.enableAddon end,
                },
                {
                    type = "colorpicker", name = "Gradient Start / 100%",
                    tooltip = "Gradient color when buff duration is above the threshold.",
                    getFunc = function() return unpack(ST.SV.ColorStart) end,
                    setFunc = function(r, g, b, a) 
                        ST.SV.ColorStart = {r, g, b, a}
                        RefreshPreview()
                    end,
                    default = GetColorDefault(ST.Default.ColorStart),
                    disabled = function() return not ST.SV.enableAddon or not ST.SV.isShowBackground end,
                },
                {
                    type = "colorpicker", name = "Gradient End / 0%",
                    tooltip = "Gradient color when buff duration approaches 0.",
                    getFunc = function() return unpack(ST.SV.ColorEnd) end,
                    setFunc = function(r, g, b, a) 
                        ST.SV.ColorEnd = {r, g, b, a}
                        RefreshPreview()
                    end,
                    default = GetColorDefault(ST.Default.ColorEnd),
                    disabled = function() return not ST.SV.enableAddon or not ST.SV.isShowBackground end,
                },
                {
                    type = "divider",
                },
                {
                    type = "colorpicker", name = "Idle / No Buff",
                    tooltip = "Color for the border (and timer) when out of combat.",
                    getFunc = function() return unpack(ST.SV.ColorIdle) end,
                    setFunc = function(r, g, b, a)
                        ST.SV.ColorIdle = {r, g, b, a}
                        RefreshPreview()
                    end,
                    default = GetColorDefault(ST.Default.ColorIdle),
                    disabled = function() return not ST.SV.enableAddon end,
                },

                { type = "header", name = "|cFFBF7FTimer Color Options|r" },
                {
                    type = "checkbox",
                    name = "Use Static Timer Color",
                    tooltip = "If enabled, the timer text will ignore the gradient and always use static color.",
                    getFunc = function() return ST.SV.isStaticTimer end,
                    setFunc = function(value)
                        ST.SV.isStaticTimer = value
                        RefreshPreview()
                    end,
                    default = ST.Default.isStaticTimer,
                    disabled = function() return not ST.SV.enableAddon end,
                },
                {
                    type = "colorpicker", name = "Static Timer Color",
                    getFunc = function() return unpack(ST.SV.ColorStaticTimer) end,
                    setFunc = function(r, g, b, a)
                        ST.SV.ColorStaticTimer = {r, g, b, a}
                        RefreshPreview()
                    end,
                    default = GetColorDefault(ST.Default.ColorStaticTimer),
                    disabled = function() return not ST.SV.enableAddon or not ST.SV.isStaticTimer end,
                },

                { type = "header", name = "|cFFBF7FTimer Font & Positioning|r" },
                {
                    type = "slider", name = "Timer Font Size",
                    min = 12, max = 124, step = 1,
                    getFunc = function() return ST.SV.fontSizeTimer end,
                    setFunc = function(value)
                        ST.SV.fontSizeTimer = value
                        ST.UpdateFonts(); RefreshPreview()
                    end,
                    default = ST.Default.fontSizeTimer,
                    disabled = function() return not ST.SV.enableAddon end,
                },
                {
                    type = "slider", name = "Timer Vertical Offset",
                    min = -24, max = 24, step = 1,
                    getFunc = function() return ST.SV.offsetYTimer end,
                    setFunc = function(value)
                        ST.SV.offsetYTimer = value
                        ST.UpdateTimerPosition()
                    end,
                    default = ST.Default.offsetYTimer,
                    disabled = function() return not ST.SV.enableAddon end,
                },
                {
                    type = "slider", name = "Decimal Threshold [sec]",
                    tooltip = "Shows decimal places when the timer falls below this value.",
                    min = 0, max = 20, step = 1,
                    getFunc = function() return ST.SV.thresholdDecimal end,
                    setFunc = function(value)
                        ST.SV.thresholdDecimal = value
                        RefreshPreview()
                    end,
                    default = ST.Default.thresholdDecimal,
                    disabled = function() return not ST.SV.enableAddon end,
                },

                -- UPTIME
                { type = "header", name = "|cFFBF7FUptime (Top Left)|r" },
                {
                    type = "checkbox", name = "Show Uptime %",
                    getFunc = function() return not ST.SV.isHideUptime end,
                    setFunc = function(value)
                        ST.SV.isHideUptime = not value
                        ST.UpdateTimerPosition()
                        RefreshPreview()
                    end,
                    default = not ST.Default.isHideUptime,
                    disabled = function() return not ST.SV.enableAddon end,
                },
                {
                    type = "colorpicker", name = "Uptime Color",
                    getFunc = function() return unpack(ST.SV.textColorUptime) end,
                    setFunc = function(r, g, b, a)
                        ST.SV.textColorUptime = {r, g, b, a}
                        RefreshPreview()
                    end,
                    default = GetColorDefault(ST.Default.textColorUptime),
                    disabled = function() return not ST.SV.enableAddon end,
                },
                {
                    type = "slider", name = "Uptime Font Size",
                    min = 12, max = 32, step = 1,
                    getFunc = function() return ST.SV.fontSizeUptime end,
                    setFunc = function(value)
                        ST.SV.fontSizeUptime = value
                        ST.UpdateFonts(); RefreshPreview()
                    end,
                    default = ST.Default.fontSizeUptime,
                    disabled = function() return not ST.SV.enableAddon end,
                },

                -- EXP SECONDS
                { type = "header", name = "|cFFBF7FExpected Seconds (Top Right)|r" },
                {
                    type = "checkbox", name = "Show Exp. Seconds (WM / MA Equipped)",
                    getFunc = function() return not ST.SV.isHideExpSec end,
                    setFunc = function(value)
                        ST.SV.isHideExpSec = not value
                        ST.UpdateTimerPosition()
                        RefreshPreview()
                    end,
                    default = not ST.Default.isHideExpSec,
                    disabled = function() return not ST.SV.enableAddon end,
                },
                {
                    type = "colorpicker", name = "Exp. Seconds Color (Active Bar)",
                    getFunc = function() return unpack(ST.SV.textColorExpSec) end,
                    setFunc = function(r, g, b, a)
                        ST.SV.textColorExpSec = {r, g, b, a}
                        RefreshPreview()
                    end,
                    default = GetColorDefault(ST.Default.textColorExpSec),
                    disabled = function() return not ST.SV.enableAddon end,
                },
                {
                    type = "slider", name = "Exp. Seconds Font Size",
                    min = 12, max = 32, step = 1,
                    getFunc = function() return ST.SV.fontSizeExpSec end,
                    setFunc = function(value)
                        ST.SV.fontSizeExpSec = value
                        ST.UpdateFonts(); RefreshPreview()
                    end,
                    default = ST.Default.fontSizeExpSec,
                    disabled = function() return not ST.SV.enableAddon end,
                },
            },
        },

        ---------------------------------------------------------------------------
        -- SUBMENU: CHAT SUMMARY
        ---------------------------------------------------------------------------
        {
            type = "submenu",
            name = "|cFF7F00CHAT SUMMARY|r",
            controls = {
                {
                    type = "checkbox",
                    name = "Enable Chat Summary",
                    tooltip = "Outputs uptime to the chat window after combat.",
                    getFunc = function() return ST.SV.isEnabledChat end,
                    setFunc = function(value) ST.SV.isEnabledChat = value end,
                    default = ST.Default.isEnabledChat,
                    disabled = function() return not ST.SV.enableAddon end,
                },
                {
                    type = "slider",
                    name = "Min. Fight Time [sec]",
                    tooltip = "Only outputs a summary if the fight lasted longer than X seconds.",
                    min = 0, max = 120, step = 5,
                    getFunc = function() return ST.SV.minFightTime end,
                    setFunc = function(value) ST.SV.minFightTime = value end,
                    default = ST.Default.minFightTime,
                    disabled = function() return not ST.SV.enableAddon end,
                },
            },
        },
        {
            type = "description",
            text = "If you enjoy |cFF7F00Slayer Tracker|r, consider sharing your feedback or supporting its development. Your input and contributions are greatly appreciated!",
            width = "full"
        },
        {
            type = "button",
            name = "Feedback / Donate",
            tooltip = "Opens a mail to send feedback or donate to the author. <3",
            func = function()
                if ST.isConsole then
                    d(string.format("%s |cFFFFFFFeedback via Mail is currently only supported on PC.|r", ST.CHAT))
                    return
                end
                SCENE_MANAGER:Show('mailSend')
                zo_callLater(function()
                    ZO_MailSendToField:SetText(ST.AUTHOR)
                    ZO_MailSendSubjectField:SetText("Slayer Tracker")
                    ZO_MailSendBodyField:TakeFocus()
                end, 250)
            end,
            width = "half"
        },
    }

    local settingsPanel = LAM2:RegisterAddonPanel(ST.NAME .. "Menu", panelData)
    LAM2:RegisterOptionControls(ST.NAME .. "Menu", optionsData)

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
        if panel == settingsPanel then
            ST.isPreview = true
            RefreshPreview()
        end
    end)

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel)
        if panel == settingsPanel then
            ST.isPreview = false
            ST.CheckCurrentBuffs()
            ST.UpdateVisibility()
        end
    end)
end