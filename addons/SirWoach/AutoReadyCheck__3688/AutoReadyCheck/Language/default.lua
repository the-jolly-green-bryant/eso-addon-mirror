-- Default English Lang
local strings = {

    --- Activity Finder
    ARC_NORMAL_DUNGEON = GetString(SI_LFGACTIVITY2) .. " " .. GetString(SI_QUESTTYPE5),
    ARC_VETERAN_DUNGEON = GetString(SI_LFGACTIVITY3) .. " " .. GetString(SI_QUESTTYPE5),
    ARC_TRIBUTE_CASUAL = GetString(SI_QUESTTYPE17) .. " (" .. GetString(SI_LFGACTIVITY10) .. ")",
    ARC_TRIBUTE_COMP = GetString(SI_QUESTTYPE17) .. " (" .. GetString(SI_LFGACTIVITY9) .. ")",

    ARC_READY_CHECK_ENABLED = "<<1>> auto accept enabled.",
    ARC_READY_CHECK_DISABLED = "<<1>> auto accept disabled.",

    -- Menu Settings
    ARC_MENU_MESSAGE_TOGGLE = "Toggle Messages",
    ARC_MENU_TITLE = "Auto Ready Check",
}

for id, val in pairs(strings) do
    ZO_CreateStringId(id, val)
    SafeAddVersion(id, 1)
end
