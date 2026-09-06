GatherBuddy = GatherBuddy or {}

local GB = GatherBuddy

------------------------------------------------------------
-- ADDON SETTINGS
------------------------------------------------------------

function GB.CreateSettingsPanel()
    local LAM = LibAddonMenu2

    if LAM == nil then
        return
    end

    local panelName =
        "GatherBuddySettingsPanel"

    local panelData = {
        type = "panel",
        name = "Gather Buddy",
        displayName = "|c66CCFFGather Buddy|r",
        author = "@everdeen",
        version = GB.ADDON_VERSION or "1.3",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM:RegisterAddonPanel(
        panelName,
        panelData
    )

    local optionsData = {
        ----------------------------------------------------
        -- APPEARANCE
        ----------------------------------------------------

        {
            type = "header",
            name = "Appearance",
        },
        {
            type = "slider",
            name = "Background Transparency",
            tooltip =
                "Adjust the Gather Buddy window backgrounds. "
                .. "0 = solid black, "
                .. "255 = fully transparent.",
            min = 0,
            max = 255,
            step = 1,

            getFunc = function()
                return
                    GB.savedVariables.backgroundTransparency
            end,

            setFunc = function(value)
                GB.savedVariables.backgroundTransparency =
                    math.floor(value + 0.5)

                if GB.ApplyBackgroundTransparency then
                    GB.ApplyBackgroundTransparency()
                end

                if GB.ApplyStatsBackgroundTransparency then
                    GB.ApplyStatsBackgroundTransparency()
                end

                if GB.ApplyHistoryBackgroundTransparency then
                    GB.ApplyHistoryBackgroundTransparency()
                end

                if GB.ApplyRareAlertBackgroundTransparency then
                    GB.ApplyRareAlertBackgroundTransparency()
                end
            end,

            default = 64,
            width = "full",
        },

        ----------------------------------------------------
        -- FONT SIZES
        ----------------------------------------------------

        {
            type = "header",
            name = "Font Sizes",
        },

        ----------------------------------------------------
        -- MAIN WINDOW FONT SIZE
        ----------------------------------------------------

        {
            type = "slider",
            name = "Main Window Font Size",
            tooltip =
                "Adjust the font size used in the "
                .. "main Gather Buddy window.",
            min = 10,
            max = 20,
            step = 1,

            getFunc = function()
                return
                    GB.savedVariables.mainFontSize
                    or 13
            end,

            setFunc = function(value)
                GB.savedVariables.mainFontSize =
                    math.floor(value + 0.5)

                if GB.ApplyMainFontSize then
                    GB.ApplyMainFontSize()
                end
            end,

            default = 13,
            width = "full",
        },

        ----------------------------------------------------
        -- STATS WINDOW FONT SIZE
        ----------------------------------------------------

        {
            type = "slider",
            name = "Stats Window Font Size",
            tooltip =
                "Adjust the font size used in the "
                .. "Session Stats window.",
            min = 10,
            max = 20,
            step = 1,

            getFunc = function()
                return
                    GB.savedVariables.statsFontSize
                    or 13
            end,

            setFunc = function(value)
                GB.savedVariables.statsFontSize =
                    math.floor(value + 0.5)

                if GB.ApplyStatsFontSize then
                    GB.ApplyStatsFontSize()
                end
            end,

            default = 13,
            width = "full",
        },

        ----------------------------------------------------
        -- HISTORY WINDOW FONT SIZE
        ----------------------------------------------------

        {
            type = "slider",
            name = "History Window Font Size",
            tooltip =
                "Adjust the font size used in the "
                .. "Session History window.",
            min = 10,
            max = 20,
            step = 1,

            getFunc = function()
                return
                    GB.savedVariables.historyFontSize
                    or 13
            end,

            setFunc = function(value)
                GB.savedVariables.historyFontSize =
                    math.floor(value + 0.5)

                if GB.ApplyHistoryFontSize then
                    GB.ApplyHistoryFontSize()
                end
            end,

            default = 13,
            width = "full",
        },

        ----------------------------------------------------
        -- RARE MATERIAL ALERT
        ----------------------------------------------------

        {
            type = "header",
            name = "Rare Material Alert",
        },

        ----------------------------------------------------
        -- ENABLE RARE MATERIAL ALERT
        ----------------------------------------------------

        {
            type = "checkbox",
            name = "Enable Rare Material Alert",
            tooltip =
                "Show a temporary on-screen alert when "
                .. "Gather Buddy tracks a Legendary / Gold "
                .. "quality material.",

            getFunc = function()
                return
                    GB.savedVariables.rareAlertEnabled
                    == true
            end,

            setFunc = function(value)
                GB.savedVariables.rareAlertEnabled =
                    value == true

                if value ~= true
                    and GB.ClearRareAlertFeed then

                    GB.ClearRareAlertFeed()
                end
            end,

            default = true,
            width = "full",
        },

        ----------------------------------------------------
        -- ALERT DURATION
        ----------------------------------------------------

        {
            type = "slider",
            name = "Alert Duration",
            tooltip =
                "Choose how many seconds the Rare Material "
                .. "Alert remains visible before fading out.",
            min = 2,
            max = 10,
            step = 1,

            getFunc = function()
                return
                    GB.savedVariables.rareAlertDuration
                    or 4
            end,

            setFunc = function(value)
                GB.savedVariables.rareAlertDuration =
                    math.floor(value + 0.5)
            end,

            default = 4,
            width = "full",
        },

        ----------------------------------------------------
        -- PREVIEW / POSITION ALERT
        ----------------------------------------------------

        {
            type = "button",
            name = "Preview / Position Alert",
            tooltip =
                "Show a preview of the Rare Material Alert "
                .. "for 10 seconds so it can be positioned.",

            func = function()
                if GB.PreviewRareAlert then
                    GB.PreviewRareAlert()
                end
            end,

            width = "full",
        },

        ----------------------------------------------------
        -- WINDOW
        ----------------------------------------------------

        {
            type = "header",
            name = "Window",
        },
        {
            type = "checkbox",
            name = "Lock Window",
            tooltip =
                "Prevent the Gather Buddy windows "
                .. "from being moved or resized.",

            getFunc = function()
                return
                    GB.savedVariables.isLocked == true
            end,

            setFunc = function(value)
                GB.savedVariables.isLocked =
                    value == true

                if GB.ApplyWindowLockState then
                    GB.ApplyWindowLockState()
                end
            end,

            default = false,
            width = "full",
        },

        ----------------------------------------------------
        -- RESET UI POSITION / SIZE
        ----------------------------------------------------

        {
            type = "button",
            name = "Reset UI Position / Size",
            tooltip =
                "Reset the Main, Session Stats, Session History, "
                .. "and Rare Material Alert window positions. "
                .. "The Main Window size is also restored to "
                .. "300 x 300. Session data, History, and other "
                .. "settings are not affected.",

            func = function()
                if GB.ResetWindowPositionsAndSize then
                    GB.ResetWindowPositionsAndSize()
                end
            end,

            width = "full",
        },

        ----------------------------------------------------
        -- FOOTER
        ----------------------------------------------------

        {
            type = "description",
            text =
                "|c777777Gather Buddy v"
                .. (GB.ADDON_VERSION or "1.3")
                .. "\n© 2026 @everdeen|r",
            width = "full",
        },
    }

    LAM:RegisterOptionControls(
        panelName,
        optionsData
    )
end