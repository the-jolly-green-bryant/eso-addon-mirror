GOEA_STRINGS = {

    -- General
    ["SI_GOEA"]                       = "Gotta Open 'em all!",
    ["SI_GOEA_SHORT"]                 = "GOEA",
    ["SI_GOEA_COLORED"]               = "|cFFCC00Gotta Open|cFFEE77 'em all!|r",
    ["SI_GOEA_COLORED_SHORT"]         = "|cFFCC00GO|cFFEE77EA|r",

    -- Keybind / commands
    ["SI_GOEA_OPEN_ALL"]              = "Open All Surveys",
    ["SI_GOEA_CANCEL"]                = "Cancel",

    -- Chat messages
    ["SI_GOEA_OPENED"]                = "opened <<1>>",
    ["SI_GOEA_COMPLETE"]              = "Done! Opened <<1>> survey(s). Gotta Open 'em all!",
    ["SI_GOEA_NONE_FOUND"]            = "No unidentified surveys found in inventory.",
    ["SI_GOEA_FAILED"]                = "Failed to open <<1>>.",
    ["SI_GOEA_PAUSED"]                = "Paused. Will resume when ready.",
    ["SI_GOEA_NOT_ENOUGH_SPACE"]      = "Not enough inventory space!",

    -- Settings panel
    ["SI_GOEA_SETTINGS_HEADER"]       = "Settings",
    ["SI_GOEA_AUTOLOOT"]              = "Auto-open on pickup",
    ["SI_GOEA_AUTOLOOT_TOOLTIP"]      = "Automatically open unidentified surveys as soon as they arrive in your bag.",
    ["SI_GOEA_AUTOLOOT_DELAY"]        = "Auto-open delay (seconds)",
    ["SI_GOEA_AUTOLOOT_DELAY_TOOLTIP"]= "How long to wait before auto-opening new surveys.",
    ["SI_GOEA_RESERVED_SLOTS"]        = "Reserved bag slots",
    ["SI_GOEA_RESERVED_SLOTS_TOOLTIP"]= "Keep this many bag slots free when opening surveys.",
    ["SI_GOEA_CHAT_ENABLED"]          = "Show chat messages",
    ["SI_GOEA_CHAT_ENABLED_TOOLTIP"]  = "Print the name of each survey opened to the chat window.",
    ["SI_GOEA_CHAT_ICONS"]            = "Show icons in chat",
    ["SI_GOEA_CHAT_ICONS_TOOLTIP"]    = "Display item icons next to survey names in chat.",
    ["SI_GOEA_CHAT_SUMMARY"]          = "Show summary when done",
    ["SI_GOEA_CHAT_SUMMARY_TOOLTIP"]  = "Print a summary of how many surveys were opened.",
    ["SI_GOEA_SHORT_PREFIX"]          = "Use short chat prefix",
    ["SI_GOEA_SHORT_PREFIX_TOOLTIP"]  = "Use [GOEA] instead of [Gotta Open 'em all!] in chat messages.",
}

for stringId, value in pairs(GOEA_STRINGS) do
    ZO_CreateStringId(stringId, value)
end
