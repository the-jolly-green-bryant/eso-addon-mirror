local HST = HeatShockTracker

---------------------------------------------------------------------------
-- CREATE SETTINGS MENU
---------------------------------------------------------------------------
function HST.CreateSettings()
    local LAM2 = LibAddonMenu2

    -- RETURN IF LAM IS NOT INSTALLED (OR CONSOLE?)
    if not LAM2 then return end

    local panelName = "Heat Shock Tracker |t24:24:esoui/art/contacts/social_classicon_dragonknight.dds|t"
    if GetUnitDisplayName("player") == HST.AUTHOR then panelName = "[Dev] " .. panelName end

    local panelData = {
        type = "panel",
        name = panelName,
        displayName = "|cFF7F00Heat Shock|r |cFFFFFFTracker|r",
        author = "|cFF7F00" .. HST.AUTHOR .. "|r |cFFFFFF[EU]|r",
        version = HST.VERSION,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    ---------------------------------------------------------------------------
    -- HELPER: GET COLOR DEFAULT FOR LAM2
    ---------------------------------------------------------------------------
    local function GetColorDefault(colorArray)
        return {
            r = colorArray[1],
            g = colorArray[2],
            b = colorArray[3],
            a = colorArray[4]
        }
    end

    ---------------------------------------------------------------------------
    -- HELPER: GET TRACKING MODE CHOICES
    ---------------------------------------------------------------------------
    local function GetTrackingModeChoices()
        local Choices = {}
        local Values = {}
        for val, name in ipairs(HST.TRACKING_MODES) do
            table.insert(Choices, name)
            table.insert(Values, val)
        end
        return Choices, Values
    end

    local MODE_CHOICES, MODE_VALUES = GetTrackingModeChoices()

    local optionsData = {
        {
            type = "checkbox",
            name = "|cFF7F00MASTERSWITCH|r (Turns the entire addon ON/OFF)",
            tooltip = "Enables or disables all tracker functionalities.",
            getFunc = function() return HST.SV.enableAddon end,
            setFunc = function(value)
                HST.SV.enableAddon = value
                if value then HST.Enable() else HST.Disable() end
            end,
            default = HST.Default.enableAddon,
        },
        {
			type = "description",
			text = "Type |cFF7F00/heatshocktracker|r to |cFF0000LOCK|r or |c00FF00UNLOCK|r the tracker and reposition it.",
			width = "full"
		},
        {
            type = "button",
            name = "Toggle Preview",
            tooltip = "Forces the display to show for positioning.",
            func = function()
                local isCurrentlyShown = HST.isForceShow or HST.isMenuPreview
                if isCurrentlyShown then
                    HST.isForceShow = false
                    HST.isMenuPreview = false

                    HST.currentStacks = 0
                    HST.Percentages[3] = 0
                    HST.StackEndTimes[1] = 0
                    HST.isTrackedBoss = false
                else
                    HST.isForceShow = true
                    HST.isMenuPreview = true

                    HST.currentStacks = 3
                    HST.Percentages[3] = 62.0
                    HST.StackEndTimes[1] = GetGameTimeMilliseconds() + HST.DURATION_MS
                    HST.isTrackedBoss = true
                    HST.trackedBossLabel = "BOSS1"
                end
                HST.UpdateIsEquipped()
                HST.UpdateVisuals()
            end,
            disabled = function() return not HST.SV.enableAddon end,
            width = "half",
        },
        {
            type = "button",
            name = "Reset Position",
            tooltip = "Resets the UI position to default.",
            func = function() HST.SetDefaultPosition() end,
            disabled = function() return not HST.SV.enableAddon end,
            width = "half",
        },

        ---------------------------------------------------------------------------
        -- SUBMENU: DESIGN & SCALING
        ---------------------------------------------------------------------------
        {
            type = "submenu",
            name = "|cFF7F00TRACKING MODE|r",
            controls = {
                {
                    type = "description",
                    text = "|cFF7F001. Recent Target:|r Dynamically tracks the enemy you hit last.\n|cFF7F002. Highest Stacks:|r Always tracks the target with the most stacks.\n|cFF7F003. Boss Focus:|r Locks onto a Boss or Dummy until the debuff fades.\n|cFF7F004. Reticle Target:|r Tracks the enemy in your crosshair.",
                    width = "full",
                },
                {
                    type = "dropdown",
                    name = "Tracking Mode",
                    tooltip = "Select how the addon tracks debuffs across multiple targets.",
                    choices = MODE_CHOICES,
                    choicesValues = MODE_VALUES,
                    getFunc = function() return HST.SV.trackingMode end,
                    setFunc = function(value)
                        HST.SV.trackingMode = value
                        HST.RegisterReticleEvent()
                        HST.UpdateVisuals()
                    end,
                    default = HST.Default.trackingMode,
                    disabled = function() return not HST.SV.enableAddon end,
                },
                {
                    type = "checkbox",
                    name = "Only Track Your Own Debuffs",
                    tooltip = "Ignores Heat Shock stacks applied by other players.",
                    getFunc = function() return HST.SV.isOnlyTrackPlayer end,
                    setFunc = function(value) HST.SV.isOnlyTrackPlayer = value end,
                    default = HST.Default.isOnlyTrackPlayer,
                    disabled = function() return not HST.SV.enableAddon end,
                },
                {
                    type = "checkbox",
                    name = "Only Show In Combat",
                    tooltip = "If enabled, the tracker will be hidden when out of combat.",
                    getFunc = function() return HST.SV.isOnlyCombat end,
                    setFunc = function(value)
                        HST.SV.isOnlyCombat = value
                        HST.UpdateIsEquipped()
                    end,
                    default = HST.Default.isOnlyCombat,
                    disabled = function() return not HST.SV.enableAddon end,
                },
            },
        },

        ---------------------------------------------------------------------------
        -- SUBMENU: DESIGN & SCALING
        ---------------------------------------------------------------------------
        {
            type = "submenu",
            name = "|cFF7F00DESIGN & SCALING|r",
            controls = {
                {
                    type = "checkbox",
                    name = "|cFF0000Lock Position|r",
                    tooltip = "Locks the tracker icon so it cannot be accidentally moved.",
                    getFunc = function() return HST.SV.isLocked end,
                    setFunc = function(value)
                        HST.SV.isLocked = value
                        HST.PARENT:SetMovable(not value)
                        HST.PARENT:SetMouseEnabled(not value)
                    end,
                    disabled = function() return not HST.SV.enableAddon end,
                    default = HST.Default.isLocked,
                },
                { type = "header", name = "|cFFBF7FGeneral Design|r" },
                {
                    type = "slider", name = "Icon Size",
                    min = 40, max = 100, step = 1,
                    getFunc = function() return HST.SV.iconSize end,
                    setFunc = function(value)
                        HST.SV.iconSize = value
                        HST.PARENT:SetDimensions(value, value)
                        HST.BG:SetDimensions(value, value)
                        local innerSize = math.max(1, value - (HST.SV.borderThickness * 2))
                        HST.ICON:SetDimensions(innerSize, innerSize)
                    end,
                    default = HST.Default.iconSize,
                    disabled = function() return not HST.SV.enableAddon end,
                },
                {
                    type = "slider", name = "Border Thickness",
                    min = 0, max = 10, step = 1,
                    getFunc = function() return HST.SV.borderThickness end,
                    setFunc = function(value)
                        HST.SV.borderThickness = value
                        local innerSize = math.max(1, HST.SV.iconSize - (value * 2))
                        HST.ICON:SetDimensions(innerSize, innerSize)
                    end,
                    default = HST.Default.borderThickness,
                    disabled = function() return not HST.SV.enableAddon end,
                },
                {
                    type = "slider", name = "Edge Thickness",
                    tooltip = "Adjusts the thickness of the edge.",
                    min = 0, max = 2, step = 1,
                    getFunc = function() return HST.SV.edgeThickness end,
                    setFunc = function(value)
                        HST.SV.edgeThickness = value
                        HST.BG:SetEdgeTexture("", 1, 1, HST.SV.edgeThickness, 0)
                        if HST.SV.edgeThickness == 0 then
                            HST.BG:SetEdgeColor(0, 0, 0, 0)
                        else
                            HST.BG:SetEdgeColor(0, 0, 0, 1)
                        end
                    end,
                    default = HST.Default.edgeThickness,
                    disabled = function() return not HST.SV.enableAddon end,
                },
                {
                    type = "slider", name = "Icon Desaturation",
                    min = 0, max = 100, step = 5,
                    getFunc = function() return HST.SV.iconDesaturation end,
                    setFunc = function(value)
                        HST.SV.iconDesaturation = value
                        HST.ICON:SetDesaturation(value / 100)
                    end,
                    default = HST.Default.iconDesaturation,
                    disabled = function() return not HST.SV.enableAddon end,
                },
                {
                    type = "checkbox", name = "Thick Outline Font",
                    getFunc = function() return HST.SV.isThickOutline end,
                    setFunc = function(value)
                        HST.SV.isThickOutline = value
                        HST.UpdateFonts()
                    end,
                    default = HST.Default.isThickOutline,
                    disabled = function() return not HST.SV.enableAddon end,
                },

                -- TIMER
                { type = "header", name = "|cFFBF7FCenter Timer|r" },
                {
                    type = "checkbox", name = "Colored Timer (Green to Red)",
                    getFunc = function() return HST.SV.isColoredTimer end,
                    setFunc = function(value)
                        HST.SV.isColoredTimer = value
                        HST.UpdateVisuals()
                    end,
                    default = HST.Default.isColoredTimer,
                    disabled = function() return not HST.SV.enableAddon end,
                },
                {
                    type = "colorpicker", name = "Timer Color",
                    getFunc = function() return unpack(HST.SV.TextColorTimer) end,
                    setFunc = function(r, g, b, a)
                        HST.SV.TextColorTimer = {r, g, b, a}
                        HST.UpdateVisuals()
                    end,
                    default = GetColorDefault(HST.Default.TextColorTimer),
                    disabled = function() return not HST.SV.enableAddon or HST.SV.isColoredTimer end,
                },
                {
                    type = "slider", name = "Timer Font Size",
                    min = 26, max = 54, step = 1,
                    getFunc = function() return HST.SV.fontSizeTimer end,
                    setFunc = function(value)
                        HST.SV.fontSizeTimer = value
                        HST.UpdateFonts()
                    end,
                    default = HST.Default.fontSizeTimer,
                    disabled = function() return not HST.SV.enableAddon end,
                },
                {
                    type = "slider", name = "Timer Vertical Offset",
                    min = -24, max = 24, step = 1,
                    getFunc = function() return HST.SV.offsetYTimer end,
                    setFunc = function(value)
                        HST.SV.offsetYTimer = value
                        HST.DURATION:ClearAnchors()
                        HST.DURATION:SetAnchor(CENTER, HST.PARENT, CENTER, 0, value)
                    end,
                    default = HST.Default.offsetYTimer,
                    disabled = function() return not HST.SV.enableAddon end,
                },

                -- BOSS LABEL
                { type = "header", name = "|cFFBF7FBoss Label|r" },
                {
                    type = "checkbox", name = "Show Boss Label",
                    getFunc = function() return not HST.SV.isHideBossLabel end,
                    setFunc = function(value)
                        HST.SV.isHideBossLabel = not value
                        HST.UpdateVisuals()
                    end,
                    default = not HST.Default.isHideBossLabel,
                    disabled = function() return not HST.SV.enableAddon end,
                },
                {
                    type = "checkbox", name = "Colored Boss Label",
                    getFunc = function() return HST.SV.isColoredBossLabel end,
                    setFunc = function(value)
                        HST.SV.isColoredBossLabel = value
                        HST.UpdateVisuals()
                    end,
                    default = HST.Default.isColoredBossLabel,
                    disabled = function() return not HST.SV.enableAddon end,
                },
                {
                    type = "colorpicker", name = "Boss Label Color",
                    getFunc = function() return unpack(HST.SV.TextColorBoss) end,
                    setFunc = function(r, g, b, a)
                        HST.SV.TextColorBoss = {r, g, b, a}
                        HST.UpdateVisuals()
                    end,
                    default = GetColorDefault(HST.Default.TextColorBoss),
                    disabled = function() return not HST.SV.enableAddon or HST.SV.isColoredBossLabel end,
                },
                {
                    type = "slider", name = "Boss Font Size",
                    min = 12, max = 32, step = 1,
                    getFunc = function() return HST.SV.fontSizeBoss end,
                    setFunc = function(value)
                        HST.SV.fontSizeBoss = value
                        HST.UpdateFonts()
                    end,
                    default = HST.Default.fontSizeBoss,
                    disabled = function() return not HST.SV.enableAddon end,
                },
                {
                    type = "slider", name = "Boss Vertical Offset",
                    min = -24, max = 24, step = 1,
                    getFunc = function() return HST.SV.offsetYBoss end,
                    setFunc = function(value)
                        HST.SV.offsetYBoss = value
                        HST.UpdateBossPosition()
                    end,
                    default = HST.Default.offsetYBoss,
                    disabled = function() return not HST.SV.enableAddon end,
                },

                -- STACKS
                { type = "header", name = "|cFFBF7FStacks (Top Right)|r" },
                {
                    type = "checkbox", name = "Show Stacks",
                    getFunc = function() return not HST.SV.isHideStacks end,
                    setFunc = function(value)
                        HST.SV.isHideStacks = not value
                        HST.UpdateTimerPosition()
                        HST.UpdateVisuals()
                    end,
                    default = not HST.Default.isHideStacks,
                    disabled = function() return not HST.SV.enableAddon end,
                },
                {
                    type = "colorpicker", name = "Stacks Color",
                    getFunc = function() return unpack(HST.SV.TextColorStacks) end,
                    setFunc = function(r, g, b, a)
                        HST.SV.TextColorStacks = {r, g, b, a}
                        HST.UpdateVisuals()
                    end,
                    default = GetColorDefault(HST.Default.TextColorStacks),
                    disabled = function() return not HST.SV.enableAddon end,
                },
                {
                    type = "slider", name = "Stacks Font Size",
                    min = 12, max = 32, step = 1,
                    getFunc = function() return HST.SV.fontSizeStacks end,
                    setFunc = function(value)
                        HST.SV.fontSizeStacks = value
                        HST.UpdateFonts()
                    end,
                    default = HST.Default.fontSizeStacks,
                    disabled = function() return not HST.SV.enableAddon end,
                },

                -- UPTIME
                { type = "header", name = "|cFFBF7FUptime (Top Left)|r" },
                {
                    type = "checkbox", name = "Show Uptime (%)",
                    getFunc = function() return not HST.SV.isHideUptime end,
                    setFunc = function(value)
                        HST.SV.isHideUptime = not value
                        HST.UpdateTimerPosition()
                        HST.UpdateVisuals()
                    end,
                    default = not HST.Default.isHideUptime,
                    disabled = function() return not HST.SV.enableAddon end,
                },
                {
                    type = "colorpicker", name = "Uptime Color",
                    getFunc = function() return unpack(HST.SV.TextColorUptime) end,
                    setFunc = function(r, g, b, a)
                        HST.SV.TextColorUptime = {r, g, b, a}
                        HST.UpdateVisuals()
                    end,
                    default = GetColorDefault(HST.Default.TextColorUptime),
                    disabled = function() return not HST.SV.enableAddon end,
                },
                {
                    type = "slider", name = "Uptime Font Size",
                    min = 12, max = 32, step = 1,
                    getFunc = function() return HST.SV.fontSizeUptime end,
                    setFunc = function(value)
                        HST.SV.fontSizeUptime = value
                        HST.UpdateFonts()
                    end,
                    default = HST.Default.fontSizeUptime,
                    disabled = function() return not HST.SV.enableAddon end,
                },

                -- ANIMATION
                { type = "header", name = "|cFFBF7FAnimation|r" },
                {
                    type = "checkbox",
                    name = "Enable Timer Animation",
                    tooltip = "Plays a short pulse animation on the timer.",
                    getFunc = function() return HST.SV.isEnabledAnimation end,
                    setFunc = function(value) HST.SV.isEnabledAnimation = value end,
                    default = HST.Default.isEnabledAnimation,
                    disabled = function() return not HST.SV.enableAddon end,
                },
                {
                    type = "slider",
                    name = "Animation Scale (%)",
                    tooltip = "How large the text grows during the animation (100% = no change).",
                    min = 100, max = 200, step =  10,
                    getFunc = function() return HST.SV.animationScale end,
                    setFunc = function(value) HST.SV.animationScale = value end,
                    default = HST.Default.animationScale,
                    disabled = function() return not HST.SV.enableAddon or not HST.SV.isEnabledAnimation end,
                },
                {
                    type = "slider",
                    name = "Animation Duration (ms)",
                    tooltip = "Total duration of the pulse animation in milliseconds.",
                    min = 100, max = 500, step = 10,
                    getFunc = function() return HST.SV.animationDuration end,
                    setFunc = function(value) HST.SV.animationDuration = value end,
                    default = HST.Default.animationDuration,
                    disabled = function() return not HST.SV.enableAddon or not HST.SV.isEnabledAnimation end,
                },
                {
                    type = "button",
                    name = "Test Animation",
                    tooltip = "Plays the animation to preview your settings.",
                    func = function()
                        HST.isForceShow = true
                        HST.PlayAnimation()
                    end,
                    disabled = function() return not HST.SV.enableAddon or not HST.SV.isEnabledAnimation end,
                    width = "half",
                },
            },
        },

        ---------------------------------------------------------------------------
        -- SUBMENU: STACK COLORS (BORDER)
        ---------------------------------------------------------------------------
        {
            type = "submenu",
            name = "|cFF7F00STACK COLORS (BORDER)|r",
            controls = {
                {
                    type = "colorpicker",
                    name = "0 Stacks / Inactive",
                    getFunc = function() return unpack(HST.SV.ColorStack0) end,
                    setFunc = function(r, g, b, a)
                        HST.SV.ColorStack0 = {r, g, b, a}
                        HST.UpdateVisuals()
                    end,
                    default = GetColorDefault(HST.Default.ColorStack0),
                    disabled = function() return not HST.SV.enableAddon end,
                },
                {
                    type = "colorpicker",
                    name = "1 Stack",
                    getFunc = function() return unpack(HST.SV.ColorStack1) end,
                    setFunc = function(r, g, b, a)
                        HST.SV.ColorStack1 = {r, g, b, a}
                        HST.UpdateVisuals()
                    end,
                    default = GetColorDefault(HST.Default.ColorStack1),
                    disabled = function() return not HST.SV.enableAddon end,
                },
                {
                    type = "colorpicker",
                    name = "2 Stacks",
                    getFunc = function() return unpack(HST.SV.ColorStack2) end,
                    setFunc = function(r, g, b, a)
                        HST.SV.ColorStack2 = {r, g, b, a}
                        HST.UpdateVisuals()
                    end,
                    default = GetColorDefault(HST.Default.ColorStack2),
                    disabled = function() return not HST.SV.enableAddon end,
                },
                {
                    type = "colorpicker",
                    name = "3 Stacks (Max)",
                    getFunc = function() return unpack(HST.SV.ColorStack3) end,
                    setFunc = function(r, g, b, a)
                        HST.SV.ColorStack3 = {r, g, b, a}
                        HST.UpdateVisuals()
                    end,
                    default = GetColorDefault(HST.Default.ColorStack3),
                    disabled = function() return not HST.SV.enableAddon end,
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
                    tooltip = "Outputs a performance summary to the chat window after combat ends.",
                    getFunc = function() return HST.SV.isEnabledChat end,
                    setFunc = function(value) HST.SV.isEnabledChat = value end,
                    default = HST.Default.isEnabledChat,
                    disabled = function() return not HST.SV.enableAddon end,
                },
                {
                    type = "slider",
                    name = "Min. Fight Time (s)",
                    tooltip = "Only outputs a summary if the fight lasted longer than X seconds.",
                    min = 0, max = 120, step = 5,
                    getFunc = function() return HST.SV.minFightTime end,
                    setFunc = function(value) HST.SV.minFightTime = value end,
                    default = HST.Default.minFightTime,
                    disabled = function() return not HST.SV.enableAddon end,
                },
            },
        },
        {
            type = "description",
            text = "If you enjoy |cFF7F00Heat Shock Tracker|r, consider sharing your feedback or supporting its development. Your input and contributions are greatly appreciated!",
            width = "full"
        },
        {
            type = "button",
            name = "Feedback / Donate",
            tooltip = "Opens a mail to send feedback or donate to the author. <3",
            func = function()
                if HST.isConsole then
                    d(string.format("%s |cFFFFFFFeedback via Mail is currently only supported on PC.|r", HST.CHAT))
                    return
                end
                SCENE_MANAGER:Show('mailSend')
                zo_callLater(function()
                    ZO_MailSendToField:SetText(HST.AUTHOR)
                    ZO_MailSendSubjectField:SetText("Heat Shock Tracker")
                    ZO_MailSendBodyField:TakeFocus()
                end, 250)
            end,
            width = "half"
        }
    }

    -- REGISTER PANEL AND SAVE ITS REFERENCE
    local settingsPanel = LAM2:RegisterAddonPanel(HST.NAME .. "Menu", panelData)
    LAM2:RegisterOptionControls(HST.NAME .. "Menu", optionsData)

    ---------------------------------------------------------------------------
    -- PREVIEW WHEN MENU
    ---------------------------------------------------------------------------
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
        if panel == settingsPanel then
            HST.isMenuPreview = true

            HST.currentStacks = 3
            HST.Percentages[3] = 62.0
            HST.StackEndTimes[1] = GetGameTimeMilliseconds() + HST.DURATION_MS
            HST.isTrackedBoss = true
            HST.trackedBossLabel = "BOSS1"

            HST.UpdateIsEquipped()
            HST.UpdateVisuals()
        end
    end)

    ---------------------------------------------------------------------------
    -- CLEANUP WHEN CLOSED
    ---------------------------------------------------------------------------
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel)
        if panel == settingsPanel then
            HST.isMenuPreview = false

            if not HST.isForceShow then
                HST.currentStacks = 0
                HST.Percentages[3] = 0
                HST.StackEndTimes[1] = 0
                HST.isTrackedBoss = false
            end

            HST.UpdateIsEquipped()
            HST.UpdateVisuals()
        end
    end)
end