-- Every variable must start with this addon's unique ID, as each is a global.
local localization_strings = {
    SI_LOOTALERT_MESSAGE = " is active!",
    SI_LOOTALERT_ENABLED = "Enabled!",
    SI_LOOTALERT_DISABLED = "disabled.",
    SI_LOOTALERT_VERB = "looted",
    SI_LOOTALERT_SECOND_SINGULAR = "You",
    SI_LOOTALERT_ALERTS = "Alerts", -- top-right notifications
    SI_LOOTALERT_ANNOUNCEMENTS = "Announcements", -- center screen notifications
    SI_LOOTALERT_CHAT = "Chat Output", -- chat notificaitons
    SI_LOOTALERT_OVERRIDE_ON = "Override On! All Notifications Active!",
    SI_LOOTALERT_OVERRIDE_OFF = "Override Off. User Settings Applied.",
    SI_LOOTALERT_CONTEXT_MENU_ADD = "Add |c7FD47FLoot|r|cF5F5F5Alert!|r",
    SI_LOOTALERT_CONTEXT_MENU_REMOVE = "Remove |c7FD47FLoot|r|cF5F5F5Alert!|r",


    -- Keybindings.
    SI_BINDING_NAME_LOOTALERT_ENABLE = "On/Off",
    SI_BINDING_NAME_LOOTALERT_OVERRIDE_ALL = "Toggle Carpe Diem",
    SI_BINDING_NAME_LOOTALERT_TOGGLE_WINDOW = "Toggle Watchlist Window",
}

for stringId, stringValue in pairs(localization_strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end