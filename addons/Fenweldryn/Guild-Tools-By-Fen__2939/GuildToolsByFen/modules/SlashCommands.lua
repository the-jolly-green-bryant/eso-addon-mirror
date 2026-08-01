GuildToolsByFenInternals.SlashCommands = {}
local SlashCommands = GuildToolsByFenInternals.SlashCommands
local ChatEditControl = CHAT_SYSTEM.textEntry.editControl

function SlashCommands.pasteInviteMessage()  
    if (not ChatEditControl:HasFocus()) then StartChatInput() end
    ChatEditControl:InsertText(GuildToolsByFenSettings.inviteMessage)
end

LibSlashCommander:Register("/gtfinvite", SlashCommands.pasteInviteMessage, "Pastes the invite message")
