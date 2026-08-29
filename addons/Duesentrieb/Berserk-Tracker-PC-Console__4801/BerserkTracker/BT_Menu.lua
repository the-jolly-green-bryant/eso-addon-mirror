local BT = BerserkTracker

---------------------------------------------------------------------------
-- CREATE SETTINGS (MENU)
---------------------------------------------------------------------------
function BT.CreateSettings()
    local LAM2 = LibAddonMenu2

    if not LAM2 then return end

    local panelName = "Berserk Tracker"
    if GetUnitDisplayName("player") == BT.AUTHOR then panelName = "[Dev] " .. panelName end

    local panelData = {
        type = "panel",
        name = panelName,
        displayName = "|cFF7F00Berserk|r |cFFFFFFTracker|r",
        author = "|cFF7F00" .. BT.AUTHOR .. "|r |cFFFFFF[EU]|r",
        version = string.format("%s-%04d", BT.VERSION, BT.ADDONVERSION),
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local function GetColorDefault(ColorArray)
        return { r = ColorArray[1], g = ColorArray[2], b = ColorArray[3], a = ColorArray[4] }
    end

    local function RefreshPreview()
        if BT.isPreview then
            BT.PARENT:SetHidden(false)
            BT.isActive = true
            BT.endTime = GetGameTimeMilliseconds() + 15000
            BT.uptimePercentage = 62
            BT.UpdateVisuals()
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
            getFunc = function() return BT.SV.enableAddon end,
            setFunc = function(value)
                BT.SV.enableAddon = value
                if value then BT.Enable() else BT.Disable() end
            end,
            default = BT.Default.enableAddon,
        },
        {
            type = "description",
            text = "Type |cFF7F00/berserktracker|r to |cFF0000LOCK|r or |c00FF00UNLOCK|r the tracker and reposition it.",
            width = "full"
        },
        {
            type = "button",
            name = "Toggle Preview",
            tooltip = "Forces tracker to show.",
            func = function()
                BT.isPreview = not BT.isPreview
                if BT.isPreview then
                    RefreshPreview()
                else
                    BT.CheckCurrentBuffs()
                    BT.UpdateVisibility()
                end
            end,
            disabled = function() return not BT.SV.enableAddon end,
            width = "half",
        },
        {
            type = "button",
            name = "Reset Position",
            tooltip = "Resets UI position to Default.",
            func = function() BT.SetDefaultPosition() end,
            disabled = function() return not BT.SV.enableAddon end,
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
                    getFunc = function() return BT.SV.visibilityMode end,
                    setFunc = function(value)
                        BT.SV.visibilityMode = value
                        BT.UpdateVisibility()
                    end,
                    default = BT.Default.visibilityMode,
                    disabled = function() return not BT.SV.enableAddon end,
                },
                { type = "header", name = "|cFFBF7FRole Filters|r" },
                {
                    type = "checkbox", name = "Enable as Tank " .. iconTank,
                    getFunc = function() return BT.SV.isEnabledTank end,
                    setFunc = function(value)
                        BT.SV.isEnabledTank = value
                        BT.UpdateVisibility()
                    end,
                    default = BT.Default.isEnabledTank,
                    disabled = function() return not BT.SV.enableAddon end,
                },
                {
                    type = "checkbox", name = "Enable as Healer " .. iconHealer,
                    getFunc = function() return BT.SV.isEnabledHeal end,
                    setFunc = function(value)
                        BT.SV.isEnabledHeal = value
                        BT.UpdateVisibility()
                    end,
                    default = BT.Default.isEnabledHeal,
                    disabled = function() return not BT.SV.enableAddon end,
                },
                {
                    type = "checkbox", name = "Enable as DPS " .. iconDPS,
                    getFunc = function() return BT.SV.isEnabledDPS end,
                    setFunc = function(value)
                        BT.SV.isEnabledDPS = value
                        BT.UpdateVisibility()
                    end,
                    default = BT.Default.isEnabledDPS,
                    disabled = function() return not BT.SV.enableAddon end,
                },
                {
                    type = "checkbox", name = "Enable as Solo " .. iconScroll,
                    getFunc = function() return BT.SV.isEnabledSolo end,
                    setFunc = function(value)
                        BT.SV.isEnabledSolo = value
                        BT.UpdateVisibility()
                    end,
                    default = BT.Default.isEnabledSolo,
                    disabled = function() return not BT.SV.enableAddon end,
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
                    getFunc = function() return BT.SV.isLocked end,
                    setFunc = function(value)
                        BT.SV.isLocked = value
                        BT.PARENT:SetMovable(not value)
                        BT.PARENT:SetMouseEnabled(not value)
                    end,
                    disabled = function() return not BT.SV.enableAddon end,
                    default = BT.Default.isLocked,
                },

                { type = "header", name = "|cFFBF7FGeneral Design|r" },
                {
                    type = "checkbox",
                    name = "Show Background & Border",
                    tooltip = "Disable this option to only see the remaining time.",
                    getFunc = function() return BT.SV.isShowBackground end,
                    setFunc = function(value)
                        BT.SV.isShowBackground = value
                        RefreshPreview()
                    end,
                    disabled = function() return not BT.SV.enableAddon end,
                    default = BT.Default.isShowBackground,
                },
                {
                    type = "checkbox", name = "Thick Outline Font",
                    getFunc = function() return BT.SV.isThickOutline end,
                    setFunc = function(value)
                        BT.SV.isThickOutline = value
                        BT.UpdateFonts(); RefreshPreview()
                    end,
                    default = BT.Default.isThickOutline,
                    disabled = function() return not BT.SV.enableAddon end,
                },
                {
                    type = "slider", name = "Icon Size",
                    min = 40, max = 100, step = 1,
                    getFunc = function() return BT.SV.iconSize end,
                    setFunc = function(value)
                        BT.SV.iconSize = value
                        BT.PARENT:SetDimensions(value, value)
                        BT.BG:SetDimensions(value, value)

                        local innerSize = math.max(1, value - (BT.SV.borderThickness * 2))
                        BT.ICON:SetDimensions(innerSize, innerSize)
                    end,
                    default = BT.Default.iconSize,
                    disabled = function() return not BT.SV.isShowBackground end
                },
                {
                    type = "slider", name = "Border Thickness",
                    min = 0, max = 10, step = 1,
                    getFunc = function() return BT.SV.borderThickness end,
                    setFunc = function(value)
                        BT.SV.borderThickness = value
                        local innerSize = math.max(1, BT.SV.iconSize - (value * 2))
                        BT.ICON:SetDimensions(innerSize, innerSize)
                    end,
                    default = BT.Default.borderThickness,
                    disabled = function() return not BT.SV.isShowBackground end
                },
                {
                    type = "slider", name = "Edge Thickness",
                    min = 0, max = 2, step = 1,
                    getFunc = function() return BT.SV.edgeThickness end,
                    setFunc = function(value)
                        BT.SV.edgeThickness = value
                        BT.BG:SetEdgeTexture("", 1, 1, BT.SV.edgeThickness, 0)
                        if BT.SV.edgeThickness == 0 then
                            BT.BG:SetEdgeColor(0, 0, 0, 0)
                        else
                            BT.BG:SetEdgeColor(0, 0, 0, 1)
                        end
                    end,
                    default = BT.Default.edgeThickness,
                    disabled = function() return not BT.SV.isShowBackground end
                },
                {
                    type = "slider", name = "Icon Desaturation (100 = B/W)",
                    min = 0, max = 100, step = 5,
                    getFunc = function() return BT.SV.iconDesaturation end,
                    setFunc = function(value)
                        BT.SV.iconDesaturation = value
                        BT.ICON:SetDesaturation(value / 100)
                    end,
                    default = BT.Default.iconDesaturation,
                    disabled = function() return not BT.SV.enableAddon end,
                },

                { type = "header", name = "|cFFBF7FColors (Border Gradient)|r" },
                {
                    type = "slider", name = "Gradient Threshold [sec]",
                    tooltip = "Time at which the gradient starts fading from Start to End.",
                    min = 0, max = 30, step = 1,
                    getFunc = function() return BT.SV.colorThreshold end,
                    setFunc = function(value)
                        BT.SV.colorThreshold = value
                        RefreshPreview()
                    end,
                    default = BT.Default.colorThreshold,
                    disabled = function() return not BT.SV.enableAddon end,
                },
                {
                    type = "colorpicker", name = "Gradient Start / 100%",
                    tooltip = "Gradient color when buff duration is above the threshold.",
                    getFunc = function() return unpack(BT.SV.ColorStart) end,
                    setFunc = function(r, g, b, a) 
                        BT.SV.ColorStart = {r, g, b, a}
                        RefreshPreview()
                    end,
                    default = GetColorDefault(BT.Default.ColorStart),
                    disabled = function() return not BT.SV.enableAddon or not BT.SV.isShowBackground end,
                },
                {
                    type = "colorpicker", name = "Gradient End / 0%",
                    tooltip = "Gradient color when buff duration approaches 0.",
                    getFunc = function() return unpack(BT.SV.ColorEnd) end,
                    setFunc = function(r, g, b, a) 
                        BT.SV.ColorEnd = {r, g, b, a}
                        RefreshPreview()
                    end,
                    default = GetColorDefault(BT.Default.ColorEnd),
                    disabled = function() return not BT.SV.enableAddon or not BT.SV.isShowBackground end,
                },
                {
                    type = "divider",
                },
                {
                    type = "colorpicker", name = "Idle / No Buff",
                    tooltip = "Color for the border (and timer) when out of combat.",
                    getFunc = function() return unpack(BT.SV.ColorIdle) end,
                    setFunc = function(r, g, b, a)
                        BT.SV.ColorIdle = {r, g, b, a}
                        RefreshPreview()
                    end,
                    default = GetColorDefault(BT.Default.ColorIdle),
                    disabled = function() return not BT.SV.enableAddon end,
                },

                { type = "header", name = "|cFFBF7FTimer Color Options|r" },
                {
                    type = "checkbox",
                    name = "Use Static Timer Color",
                    tooltip = "If enabled, the timer text will ignore the gradient and always use static color.",
                    getFunc = function() return BT.SV.isStaticTimer end,
                    setFunc = function(value)
                        BT.SV.isStaticTimer = value
                        RefreshPreview()
                    end,
                    default = BT.Default.isStaticTimer,
                    disabled = function() return not BT.SV.enableAddon end,
                },
                {
                    type = "colorpicker", name = "Static Timer Color",
                    getFunc = function() return unpack(BT.SV.ColorStaticTimer) end,
                    setFunc = function(r, g, b, a)
                        BT.SV.ColorStaticTimer = {r, g, b, a}
                        RefreshPreview()
                    end,
                    default = GetColorDefault(BT.Default.ColorStaticTimer),
                    disabled = function() return not BT.SV.enableAddon or not BT.SV.isStaticTimer end,
                },

                { type = "header", name = "|cFFBF7FTimer Font & Positioning|r" },
                {
                    type = "slider", name = "Timer Font Size",
                    min = 12, max = 124, step = 1,
                    getFunc = function() return BT.SV.fontSizeTimer end,
                    setFunc = function(value)
                        BT.SV.fontSizeTimer = value
                        BT.UpdateFonts(); RefreshPreview()
                    end,
                    default = BT.Default.fontSizeTimer,
                    disabled = function() return not BT.SV.enableAddon end,
                },
                {
                    type = "slider", name = "Timer Vertical Offset",
                    min = -24, max = 24, step = 1,
                    getFunc = function() return BT.SV.offsetYTimer end,
                    setFunc = function(value)
                        BT.SV.offsetYTimer = value
                        BT.UpdateTimerPosition()
                    end,
                    default = BT.Default.offsetYTimer,
                    disabled = function() return not BT.SV.enableAddon end,
                },
                {
                    type = "slider", name = "Decimal Threshold [sec]",
                    tooltip = "Shows decimal places when the timer falls below this value.",
                    min = 0, max = 10, step = 1,
                    getFunc = function() return BT.SV.thresholdDecimal end,
                    setFunc = function(value)
                        BT.SV.thresholdDecimal = value
                        RefreshPreview()
                    end,
                    default = BT.Default.thresholdDecimal,
                    disabled = function() return not BT.SV.enableAddon end,
                },

                -- UPTIME
                { type = "header", name = "|cFFBF7FUptime (Top Left)|r" },
                {
                    type = "checkbox", name = "Show Uptime %",
                    getFunc = function() return not BT.SV.isHideUptime end,
                    setFunc = function(value)
                        BT.SV.isHideUptime = not value
                        BT.UpdateTimerPosition()
                        RefreshPreview()
                    end,
                    default = not BT.Default.isHideUptime,
                    disabled = function() return not BT.SV.enableAddon end,
                },
                {
                    type = "colorpicker", name = "Uptime Color",
                    getFunc = function() return unpack(BT.SV.textColorUptime) end,
                    setFunc = function(r, g, b, a)
                        BT.SV.textColorUptime = {r, g, b, a}
                        RefreshPreview()
                    end,
                    default = GetColorDefault(BT.Default.textColorUptime),
                    disabled = function() return not BT.SV.enableAddon end,
                },
                {
                    type = "slider", name = "Uptime Font Size",
                    min = 12, max = 32, step = 1,
                    getFunc = function() return BT.SV.fontSizeUptime end,
                    setFunc = function(value)
                        BT.SV.fontSizeUptime = value
                        BT.UpdateFonts(); RefreshPreview()
                    end,
                    default = BT.Default.fontSizeUptime,
                    disabled = function() return not BT.SV.enableAddon end,
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
                    getFunc = function() return BT.SV.isEnabledChat end,
                    setFunc = function(value) BT.SV.isEnabledChat = value end,
                    default = BT.Default.isEnabledChat,
                    disabled = function() return not BT.SV.enableAddon end,
                },
                {
                    type = "slider",
                    name = "Min. Fight Time [sec]",
                    tooltip = "Only outputs a summary if the fight lasted longer than X seconds.",
                    min = 0, max = 120, step = 5,
                    getFunc = function() return BT.SV.minFightTime end,
                    setFunc = function(value) BT.SV.minFightTime = value end,
                    default = BT.Default.minFightTime,
                    disabled = function() return not BT.SV.enableAddon end,
                },
            },
        },
        {
            type = "description",
            text = "If you enjoy |cFF7F00Berserk Tracker|r, consider sharing your feedback or supporting its development. Your input and contributions are greatly appreciated!",
            width = "full"
        },
        {
            type = "button",
            name = "Feedback / Donate",
            tooltip = "Opens a mail to send feedback or donate to the author. <3",
            func = function()
                if BT.isConsole then
                    d(string.format("%s |cFFFFFFFeedback via Mail is currently only supported on PC.|r", BT.CHAT))
                    return
                end
                SCENE_MANAGER:Show('mailSend')
                zo_callLater(function()
                    ZO_MailSendToField:SetText(BT.AUTHOR)
                    ZO_MailSendSubjectField:SetText("Berserk Tracker")
                    ZO_MailSendBodyField:TakeFocus()
                end, 250)
            end,
            width = "half"
        },
    }

    local settingsPanel = LAM2:RegisterAddonPanel(BT.NAME .. "Menu", panelData)
    LAM2:RegisterOptionControls(BT.NAME .. "Menu", optionsData)

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
        if panel == settingsPanel then
            BT.isPreview = true
            RefreshPreview()
        end
    end)

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel)
        if panel == settingsPanel then
            BT.isPreview = false
            BT.CheckCurrentBuffs()
            BT.UpdateVisibility()
        end
    end)
end