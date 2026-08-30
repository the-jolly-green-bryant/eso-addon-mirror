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
        version = GB.ADDON_VERSION or "1.2",
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
        -- FOOTER
        ----------------------------------------------------

        {
            type = "description",
            text =
                "|c777777Gather Buddy v"
                .. (GB.ADDON_VERSION or "1.2")
                .. "\n© 2026 @everdeen|r",
            width = "full",
        },
    }

    LAM:RegisterOptionControls(
        panelName,
        optionsData
    )
end