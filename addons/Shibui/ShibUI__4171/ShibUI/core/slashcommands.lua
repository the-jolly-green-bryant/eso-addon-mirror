-------------------------------------------------------
-- Slash Commands.lua
-- Handles all slash commands for SUI
-------------------------------------------------------
local SUI = SUI

SUI.SlashCommands = {}

function SUI:RegisterSlashCommand(name, callback, description)
    self.SlashCommands[name:lower()] = { callback = callback, description = description or "" }
end

function SUI:HandleSlashCommand(msg)
    local sub, args = msg:match("^(%S*)%s*(.-)$")
    sub = string.lower(sub or "")

    if sub == "" or sub == "help" then
        d("|cFF9900[SUI] [Available commands]:|r")
        for name, cmd in pairs(self.SlashCommands) do
            d(string.format("|cCECECE/sui %s - %s|r", name, cmd.description))
        end
        return
    end

    local command = self.SlashCommands[sub]
    if command then
        command.callback(args)
    else
        d("|cFF9900[SUI] [Unknown command]:|r " .. sub)
        d("|cCECECETry /sui help|r")
    end
end

-- Register base /sui command
SLASH_COMMANDS["/sui"] = function(msg)
    SUI:HandleSlashCommand(msg)
end

-------------------------------------------------------
-- Register all commands here
-------------------------------------------------------

SUI:RegisterSlashCommand("reload", function()
    SUI.ReloadUI:PerformReload()
end, "Reloads the UI")

SUI:RegisterSlashCommand("targetbarhostile", function()
    SUI.TargetBar:Toggle()
end, "Toggle show only hostile targets")


SUI:RegisterSlashCommand("progressbar", function()
    SUI.PlayerProgressBar:Toggle()
end, "Toggle the progressbar always visible")