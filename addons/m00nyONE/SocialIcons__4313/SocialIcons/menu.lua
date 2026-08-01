-- SPDX-FileCopyrightText: 2025 m00nyONE
-- SPDX-License-Identifier: Artistic-2.0

local addon_name = "SocialIcons"
local addon = _G[addon_name]

local LAM = LibAddonMenu2

--- builds the addon configuration menu.
--- @return void
function addon.BuildMenu()
    local menuReference = addon_name .. "_menu"

    local panel = {
        type = "panel",
        name = addon.name,
        displayName = string.format('|cFFFACD%s|r', addon.name),
        author = addon.author,
        version = addon.version,
        website = "",
        registerForDefaults = true,
    }

    local options = {
        {
            type = "checkbox",
            name = "Enable Friends List Icons",
            tooltip = "Toggle the display of icons in the friends list.",
            getFunc = function() return addon.sw.enableFriendsListIcons end,
            setFunc = function(value) addon.sw.enableFriendsListIcons = value end,
            default = true,
            requiresReload = true,
        },
        {
            type = "checkbox",
            name = "Enable Guild Roster Icons",
            tooltip = "Toggle the display of icons in the guild roster.",
            getFunc = function() return addon.sw.enableGuildRosterIcons end,
            setFunc = function(value) addon.sw.enableGuildRosterIcons = value end,
            default = true,
            requiresReload = true,
        },
        {
            type = "checkbox",
            name = "Enable Animations",
            tooltip = "Toggle animations for the icons.",
            getFunc = function() return addon.sw.enableAnimations end,
            setFunc = function(value) addon.sw.enableAnimations = value end,
            default = true,
        }
    }

    LAM:RegisterAddonPanel(menuReference, panel)
    LAM:RegisterOptionControls(menuReference, options)

    addon.BuildMenu = nil  -- only run once
end