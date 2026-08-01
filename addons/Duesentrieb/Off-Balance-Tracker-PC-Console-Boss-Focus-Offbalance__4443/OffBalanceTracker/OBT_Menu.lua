local OBT = OffBalanceTracker

---------------------------------------------------------------------------
-- CREATE SETTINGS (MENU)
---------------------------------------------------------------------------
function OBT.CreateSettings()
    local LAM2 = LibAddonMenu2

    if not LAM2 then return end

    local iconTank = "|t20:20:/esoui/art/lfg/lfg_icon_tank.dds|t"
    local iconHealer = "|t20:20:/esoui/art/lfg/lfg_icon_healer.dds|t"
    local iconDPS = "|t20:20:/esoui/art/lfg/lfg_icon_dps.dds|t"
    local iconScroll = "|t20:20:/esoui/art/journal/journal_tabicon_cadwell_up.dds|t"

    local panelName = "Off Balance Tracker"
    if GetUnitDisplayName("player") == OBT.author then panelName = "[Dev] " .. panelName end

    local panelData = {
        type = "panel",
        name = panelName,
        displayName = "|cFF7F00Off Balance|r |cFFFFFFTracker|r",
        author = "|cFF7F00" .. OBT.author .. "|r",
        version = OBT.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    ---------------------------------------------------------------------------
    -- GET COLOR DEFAULT
    ---------------------------------------------------------------------------
    local function GetColorDefault(colorArray)
        return { r = colorArray[1], g = colorArray[2], b = colorArray[3], a = colorArray[4] }
    end

    ---------------------------------------------------------------------------
    -- REFRESH PREVIEW
    ---------------------------------------------------------------------------
    local function RefreshPreview()
        if OBT.isForceShow then
            OBT.UpdateVisuals(1, 4900, true)
        end
    end

    local optionsData = {
        {
            type = "checkbox",
            name = "|cFF7F00MASTERSWITCH|r (Turns the entire addon ON/OFF)",
            tooltip = "Enables or disables all tracker functionalities.",
            getFunc = function() return OBT.SV.enableAddon end,
            setFunc = function(value)
                OBT.SV.enableAddon = value
                if value then OBT.Enable() else OBT.Disable() end
            end,
            default = OBT.default.enableAddon,
        },
        {
            type = "button",
            name = "Toggle Preview",
            tooltip = "Forces the display to show for positioning.",
            func = function()
                OBT.isForceShow = not OBT.isForceShow
                OBT.UpdateVisibility()
                if OBT.isForceShow then
                    RefreshPreview()
                else
                    OBT.UpdateVisuals(0, 0, false)
                end
            end,
            disabled = function() return not OBT.SV.enableAddon end,
            width = "half",
        },
        {
            type = "button",
            name = "Reset Position",
            tooltip = "Resets the UI position to default.",
            func = function() OBT.SetDefaultPosition() end,
            disabled = function() return not OBT.SV.enableAddon end,
            width = "half",
        },

        -- SUBMENU: TRACKING & VISIBILITY
        {
            type = "submenu",
            name = "|cFF7F00TRACKING & VISIBILITY|r",
            controls = {
                {
                    type = "checkbox",
                    name = "Only Show In Combat",
                    tooltip = "If enabled, the tracker will be hidden when out of combat.",
                    getFunc = function() return OBT.SV.isOnlyCombat end,
                    setFunc = function(value)
                        OBT.SV.isOnlyCombat = value
                        OBT.UpdateVisibility()
                    end,
                    default = OBT.default.isOnlyCombat,
                    disabled = function() return not OBT.SV.enableAddon end,
                },
                {
                    type = "checkbox",
                    name = "Boss Focus (Target Lock)",
                    tooltip = "Locks onto a Boss if present. Reticle target overrides this if multiple bosses exist. Warning! Will not track adds besides the boss!",
                    getFunc = function() return OBT.SV.isBossFocus end,
                    setFunc = function(value) OBT.SV.isBossFocus = value end,
                    default = OBT.default.isBossFocus,
                    disabled = function() return not OBT.SV.enableAddon end,
                },
                {
                    type = "checkbox",
                    name = "Only Show on Bosses",
                    tooltip = "If enabled, the tracker will remain hidden unless a boss is actively tracked.",
                    getFunc = function() return OBT.SV.isOnlyBosses end,
                    setFunc = function(value)
                        OBT.SV.isOnlyBosses = value
                        OBT.UpdateVisibility()
                    end,
                    default = OBT.default.isOnlyBosses,
                    disabled = function() return not OBT.SV.enableAddon end,
                },
            },
        },

        -- SUBMENU: ROLE FILTERS
        {
            type = "submenu",
            name = "|cFF7F00ROLE FILTERS|r",
            controls = {
                {
                    type = "description",
                    text = "Select the roles you want this tracker to be active on.",
                    width = "full",
                },
                {
                    type = "checkbox", name = "Enable as Tank " .. iconTank,
                    getFunc = function() return OBT.SV.isEnabledTank end,
                    setFunc = function(value)
                        OBT.SV.isEnabledTank = value
                        OBT.UpdateVisibility()
                    end,
                    default = OBT.default.isEnabledTank,
                    disabled = function() return not OBT.SV.enableAddon end,
                },
                {
                    type = "checkbox", name = "Enable as Healer " .. iconHealer,
                    getFunc = function() return OBT.SV.isEnabledHeal end,
                    setFunc = function(value)
                        OBT.SV.isEnabledHeal = value
                        OBT.UpdateVisibility()
                    end,
                    default = OBT.default.isEnabledHeal,
                    disabled = function() return not OBT.SV.enableAddon end,
                },
                {
                    type = "checkbox", name = "Enable as DPS " .. iconDPS,
                    getFunc = function() return OBT.SV.isEnabledDPS end,
                    setFunc = function(value)
                        OBT.SV.isEnabledDPS = value
                        OBT.UpdateVisibility()
                    end,
                    default = OBT.default.isEnabledDPS,
                    disabled = function() return not OBT.SV.enableAddon end,
                },
                {
                    type = "checkbox", name = "Enable as Solo " .. iconScroll,
                    getFunc = function() return OBT.SV.isEnabledSolo end,
                    setFunc = function(value)
                        OBT.SV.isEnabledSolo = value
                        OBT.UpdateVisibility()
                    end,
                    default = OBT.default.isEnabledSolo,
                    disabled = function() return not OBT.SV.enableAddon end,
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
                    name = "Lock UI",
                    tooltip = "Locks the tracker icon so it cannot be accidentally moved.",
                    getFunc = function() return OBT.SV.isLocked end,
                    setFunc = function(value)
                        OBT.SV.isLocked = value
                        OBT.PARENT:SetMovable(not value)
                        OBT.PARENT:SetMouseEnabled(not value)
                    end,
                    disabled = function() return not OBT.SV.enableAddon end,
                    default = OBT.default.isLocked,
                },

                -- GLOBAL DESIGN
                { type = "header", name = "Global Design" },
                {
                    type = "checkbox",
                    name = "Show Background & Border",
                    tooltip = "Disable to hide the background and display only the remaining time.",
                    getFunc = function() return OBT.SV.isShowBackground end,
                    setFunc = function(value)
                        OBT.SV.isShowBackground = value
                        RefreshPreview()
                    end,
                    disabled = function() return not OBT.SV.enableAddon end,
                    default = OBT.default.isShowBackground,
                },
                {
                    type = "checkbox", name = "Show Boss Label",
                    getFunc = function() return not OBT.SV.isHideBossLabel end,
                    setFunc = function(value)
                        OBT.SV.isHideBossLabel = not value
                        RefreshPreview()
                    end,
                    default = not OBT.default.isHideBossLabel,
                    disabled = function() return not OBT.SV.enableAddon end,
                },
                {
                    type = "checkbox", name = "Thick Outline Font",
                    getFunc = function() return OBT.SV.isThickOutline end,
                    setFunc = function(value)
                        OBT.SV.isThickOutline = value
                        OBT.UpdateFonts(); RefreshPreview()
                    end,
                    default = OBT.default.isThickOutline,
                    disabled = function() return not OBT.SV.enableAddon end,
                },
                {
                    type = "divider",
                },
                {
                    type = "slider", name = "Icon Size",
                    min = 40, max = 100, step = 1,
                    getFunc = function() return OBT.SV.iconSize end,
                    setFunc = function(value)
                        OBT.SV.iconSize = value
                        OBT.PARENT:SetDimensions(value, value)
                        OBT.BG:SetDimensions(value, value)
                        local innerSize = math.max(1, value - (OBT.SV.borderThickness * 2))
                        OBT.ICON:SetDimensions(innerSize, innerSize)
                    end,
                    default = OBT.default.iconSize,
                    disabled = function() return not OBT.SV.isShowBackground end --not OBT.SV.enableAddon end,
                },
                {
                    type = "slider", name = "Border Thickness",
                    min = 0, max = 10, step = 1,
                    getFunc = function() return OBT.SV.borderThickness end,
                    setFunc = function(value)
                        OBT.SV.borderThickness = value
                        local innerSize = math.max(1, OBT.SV.iconSize - (value * 2))
                        OBT.ICON:SetDimensions(innerSize, innerSize)
                    end,
                    default = OBT.default.borderThickness,
                    disabled = function() return not OBT.SV.isShowBackground end --not OBT.SV.enableAddon end,
                },
                {
                    type = "slider", name = "Edge Thickness",
                    min = 0, max = 2, step = 1,
                    getFunc = function() return OBT.SV.edgeThickness end,
                    setFunc = function(value)
                        OBT.SV.edgeThickness = value
                        OBT.BG:SetEdgeTexture("", 1, 1, OBT.SV.edgeThickness, 0)
                        if OBT.SV.edgeThickness == 0 then
                            OBT.BG:SetEdgeColor(0, 0, 0, 0)
                        else
                            OBT.BG:SetEdgeColor(0, 0, 0, 1)
                        end
                    end,
                    default = OBT.default.edgeThickness,
                    disabled = function() return not OBT.SV.isShowBackground end --not OBT.SV.enableAddon end,
                },

                -- TIMER
                { type = "header", name = "Center Timer" },
                {
                    type = "checkbox", name = "Colored Timer (Matches Border)",
                    getFunc = function() return OBT.SV.isColoredTimer end,
                    setFunc = function(value)
                        OBT.SV.isColoredTimer = value
                        RefreshPreview()
                    end,
                    default = OBT.default.isColoredTimer,
                    disabled = function() return not OBT.SV.enableAddon end,
                },
                {
                    type = "colorpicker", name = "Timer Color",
                    getFunc = function() return unpack(OBT.SV.textColorTimer) end,
                    setFunc = function(r, g, b, a)
                        OBT.SV.textColorTimer = {r, g, b, a}
                        RefreshPreview()
                    end,
                    default = GetColorDefault(OBT.default.textColorTimer),
                    disabled = function() return not OBT.SV.enableAddon or OBT.SV.isColoredTimer end,
                },
                {
                    type = "slider", name = "Timer Font Size",
                    min = 12, max = 124, step = 1,
                    getFunc = function() return OBT.SV.fontSizeTimer end,
                    setFunc = function(value)
                        OBT.SV.fontSizeTimer = value
                        OBT.UpdateFonts(); RefreshPreview()
                    end,
                    default = OBT.default.fontSizeTimer,
                    disabled = function() return not OBT.SV.enableAddon end,
                },
                {
                    type = "slider", name = "Timer Vertical Offset",
                    min = -24, max = 24, step = 1,
                    getFunc = function() return OBT.SV.offsetYTimer end,
                    setFunc = function(value)
                        OBT.SV.offsetYTimer = value
                        OBT.UpdateTimerPosition()
                    end,
                    default = OBT.default.offsetYTimer,
                    disabled = function() return not OBT.SV.enableAddon end,
                },
                {
                    type = "slider", name = "Decimal Threshold (s)",
                    tooltip = "Shows decimal places when the timer falls below this value.",
                    min = 0, max = 15, step = 0.5,
                    getFunc = function() return OBT.SV.decimalThreshold end,
                    setFunc = function(value)
                        OBT.SV.decimalThreshold = value
                        RefreshPreview()
                    end,
                    default = OBT.default.decimalThreshold,
                    disabled = function() return not OBT.SV.enableAddon end,
                },

                -- BOSS LABEL
                { type = "header", name = "Boss Label" },
                {
                    type = "checkbox", name = "Colored Boss Label (Matches Border)",
                    getFunc = function() return OBT.SV.isColoredBossLabel end,
                    setFunc = function(value)
                        OBT.SV.isColoredBossLabel = value
                        RefreshPreview()
                    end,
                    default = OBT.default.isColoredBossLabel,
                    disabled = function() return not OBT.SV.enableAddon end,
                },
                {
                    type = "colorpicker", name = "Boss Label Color",
                    getFunc = function() return unpack(OBT.SV.textColorBoss) end,
                    setFunc = function(r, g, b, a)
                        OBT.SV.textColorBoss = {r, g, b, a}
                        RefreshPreview()
                    end,
                    default = GetColorDefault(OBT.default.textColorBoss),
                    disabled = function() return not OBT.SV.enableAddon or OBT.SV.isColoredBossLabel end, 
                },
                {
                    type = "slider", name = "Boss Font Size",
                    min = 12, max = 32, step = 1,
                    getFunc = function() return OBT.SV.fontSizeBoss end,
                    setFunc = function(value)
                        OBT.SV.fontSizeBoss = value
                        OBT.UpdateFonts(); RefreshPreview()
                    end,
                    default = OBT.default.fontSizeBoss,
                    disabled = function() return not OBT.SV.enableAddon end,
                },
                {
                    type = "slider", name = "Boss Vertical Offset",
                    min = -24, max = 24, step = 1,
                    getFunc = function() return OBT.SV.offsetYBoss end,
                    setFunc = function(value)
                        OBT.SV.offsetYBoss = value
                        OBT.UpdateBossPosition()
                    end,
                    default = OBT.default.offsetYBoss,
                    disabled = function() return not OBT.SV.enableAddon end,
                },
            },
        },

        -- SUBMENU: BORDER COLORS
        {
            type = "submenu",
            name = "|cFF7F00BORDER COLORS (STATES)|r",
            controls = {
                {
                    type = "colorpicker", name = "0 - Idle / No Target / No OB",
                    getFunc = function() return unpack(OBT.SV.colorIdle) end,
                    setFunc = function(r, g, b, a)
                        OBT.SV.colorIdle = {r, g, b, a}
                        if OBT.isForceShow then
                            RefreshPreview()
                        else
                            OBT.UpdateVisuals(0, 0, false)
                        end
                    end,
                    default = GetColorDefault(OBT.default.colorIdle),
                    disabled = function() return not OBT.SV.enableAddon end,
                },
                {
                    type = "colorpicker", name = "1 - Off Balance (Active)",
                    getFunc = function() return unpack(OBT.SV.colorActive) end,
                    setFunc = function(r, g, b, a) 
                        OBT.SV.colorActive = {r, g, b, a}
                        RefreshPreview()
                    end,
                    default = GetColorDefault(OBT.default.colorActive),
                    disabled = function() return not OBT.SV.enableAddon end,
                },
                {
                    type = "colorpicker", name = "2 - Immunity (Cooldown)",
                    getFunc = function() return unpack(OBT.SV.colorImmune) end,
                    setFunc = function(r, g, b, a)
                        OBT.SV.colorImmune = {r, g, b, a}
                        if OBT.isForceShow then OBT.UpdateVisuals(2, 14000, true) end
                    end,
                    default = GetColorDefault(OBT.default.colorImmune),
                    disabled = function() return not OBT.SV.enableAddon end,
                },
            },
        },

        -- FEEDBACK
        {
            type = "description",
            text = "If you enjoy |cFF7F00Off Balance Tracker|r, consider sharing your feedback or supporting its development. Your input and contributions are greatly appreciated!",
            width = "full"
        },
        {
            type = "button",
            name = "Feedback / Donate",
            tooltip = "Opens a mail to send feedback or donate to the author. <3",
            func = function()
                if OBT.isConsole then
                    d(string.format("%s |cFFFFFFFeedback via Mail is currently only supported on PC.|r", OBT.chat))
                    return
                end
                SCENE_MANAGER:Show('mailSend')
                zo_callLater(function()
                    ZO_MailSendToField:SetText(OBT.author)
                    ZO_MailSendSubjectField:SetText("Off Balance Tracker")
                    ZO_MailSendBodyField:TakeFocus()
                end, 250)
            end,
            width = "half"
        }
    }

    local settingsPanel = LAM2:RegisterAddonPanel(OBT.name .. "Menu", panelData)
    LAM2:RegisterOptionControls(OBT.name .. "Menu", optionsData)

    ---------------------------------------------------------------------------
    -- CALLBACK: ON PANEL OPENED
    ---------------------------------------------------------------------------
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
        if panel == settingsPanel then
            OBT.isForceShow = true
            OBT.UpdateVisibility()
            RefreshPreview()
        end
    end)

    ---------------------------------------------------------------------------
    -- CALLBACK: ON PANEL CLOSED
    ---------------------------------------------------------------------------
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel)
        if panel == settingsPanel then
            OBT.isForceShow = false
            OBT.UpdateVisibility()
            OBT.UpdateVisuals(0, 0, false)
        end
    end)
end