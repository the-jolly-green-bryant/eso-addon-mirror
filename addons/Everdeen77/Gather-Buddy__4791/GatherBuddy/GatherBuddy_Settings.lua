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
        version = GB.ADDON_VERSION or "1.1",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM:RegisterAddonPanel(
        panelName,
        panelData
    )

    local optionsData = {
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
            end,

            default = 64,
            width = "full",
        },
        {
            type = "header",
            name = "Window",
        },
        {
            type = "checkbox",
            name = "Lock Window",
            tooltip =
                "Prevent the main Gather Buddy "
                .. "window from being moved "
                .. "or resized.",

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
    }

    LAM:RegisterOptionControls(
        panelName,
        optionsData
    )
end