local COMMANDS = {
    ["glead"] = JumpToGroupLeader,
    ["craft"] = function() Volette.travel.GoToHouse(Volette.hq.SavedVariables.CraftHqUserId) end,
    ["parse"] = function() Volette.travel.GoToHouse(Volette.hq.SavedVariables.ParseHqUserId) end,
    ["home"] = function() Volette.travel.GoToHouse(GetDisplayName()) end,
    ["wayshrine"] = Volette.travel.GoToOratory,
}

function Volette.LoadSlashCommands()
    for shortcut, func in pairs(COMMANDS) do
        SLASH_COMMANDS["/v-" .. shortcut] = func
    end
end
