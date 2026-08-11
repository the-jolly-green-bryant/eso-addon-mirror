GroupMementos = GroupMementos or {}
local GroupMementos = GroupMementos

local function OnCommand(argString)
    local arg = argString:match("%S+")

    if (arg == "reset") then
        GroupMementos.ResetSession()
        GroupMementos.msg("Session tally reset.")
    elseif (arg == "chat") then
        -- Reads/writes the same saved variable as the "Show chat message"
        -- checkbox in the settings menu, so the two always agree - the
        -- settings panel re-reads it (via registerForRefresh) whenever it's
        -- opened, no extra syncing needed.
        GroupMementos.savedOptions.chat = not GroupMementos.savedOptions.chat
        GroupMementos.msg(GroupMementos.savedOptions.chat and "Chat announcements enabled." or "Chat announcements disabled.")
    elseif (arg == "leader") then
        GroupMementos.AnnounceLeaderboard()
    elseif (arg == "settings") then
        GroupMementos.OpenSettingsMenu()
    elseif (arg == "help") then
        GroupMementos.msg("Commands:")
        GroupMementos.msg("/gm - toggle the tally panel")
        GroupMementos.msg("/gm reset - reset the session tally")
        GroupMementos.msg("/gm chat - toggle chat announcements")
        GroupMementos.msg("/gm leader - post a leaderboard to chat")
        GroupMementos.msg("/gm settings - open the settings menu")
        GroupMementos.msg("/gm help - show this list")
    else
        GroupMementos.savedOptions.showPanel = not GroupMementos.savedOptions.showPanel
        GroupMementos.UpdateDisplay()
    end
end

SLASH_COMMANDS["/gm"] = OnCommand
