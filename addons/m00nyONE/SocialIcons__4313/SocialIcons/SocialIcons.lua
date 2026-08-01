-- SPDX-FileCopyrightText: 2025 m00nyONE
-- SPDX-License-Identifier: Artistic-2.0

--[[ doc.lua begin ]]
local addon = {
    name = "SocialIcons",
    version = "2025-12-01",
    author = "@m00nyONE",
    sw = nil, -- saved variables
}
local addon_name = addon.name
_G[addon_name] = addon

local EM = GetEventManager()
local svName = "SocialIcons_SavedVariables"
local svVersion = 1
local svDefault = {
    enableAnimations = true,
    enableFriendsListIcons = true,
    enableGuildRosterIcons = true,
}
--[[ doc.lua end ]]

--- initializes the addon.
--- @return void
local function initialize()
    addon.sw = ZO_SavedVars:NewAccountWide(svName, svVersion, nil, svDefault)

    if addon.sw.enableFriendsListIcons then addon.createHook(FRIENDS_LIST_MANAGER) end
    if addon.sw.enableGuildRosterIcons then addon.createHook(GUILD_ROSTER_MANAGER) end

    addon.BuildMenu()
end

EM:RegisterForEvent(addon_name, EVENT_ADD_ON_LOADED, function(_, name)
    if name ~= addon_name then return end

    EM:UnregisterForEvent(addon_name, EVENT_ADD_ON_LOADED)
    initialize()
end)