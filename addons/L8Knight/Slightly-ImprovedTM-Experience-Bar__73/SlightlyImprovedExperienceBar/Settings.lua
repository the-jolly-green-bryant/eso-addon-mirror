-- Slightly Improved™ Experience Bar
-- The MIT License © 2019 Arthur Corenzan
-- FreeBSD License © 2014 Kevin Douglas

local NAMESPACE = "SlightlyImprovedExperienceBar"
local LAM = LibAddonMenu2

local settings = {}

local panel =
{
    type = "panel",
    name = "Slightly Improved™ Experience Bar",
    displayName = "Slightly Improved™ Experience Bar",
    author = "L8Knight, haggen, Sharlikran",
    version = "3.0.1",
}

local options =
{
    {
        type = "dropdown",
        name = "Visibility",
        tooltip = "Controls the visibility of the Experience Bar. When set to automatic the Experience Bar will only appear in useful situations like when you level up or in the inventory screen.",
        choices = {"Automatic", "Always Show"},
        getFunc = function() return settings.visibility end,
        setFunc = function(value) settings.visibility = value end,
        -- requiresReload = true,
    },
}

CALLBACK_MANAGER:RegisterCallback(NAMESPACE.."_OnAddOnLoaded", function(savedVars)
    settings = savedVars

    LAM:RegisterAddonPanel(NAMESPACE, panel)
    LAM:RegisterOptionControls(NAMESPACE, options)
end)
