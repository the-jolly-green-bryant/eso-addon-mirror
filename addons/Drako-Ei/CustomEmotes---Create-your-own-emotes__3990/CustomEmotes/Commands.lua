local CE = CustomEmotes
local LAM = LibAddonMenu2
local internal = CE.internal

commands = {}
internal.commands = commands

-- Add shortcut for menu command using CE.savedVars.command
function internal.registerCommands()
    SLASH_COMMANDS[CE.savedVars.command] = function(arg)
        if arg == nil or arg == "" then
            DoCommand(CE.menuCommand)
        else
            -- Play emote command
            local emote = CE.savedVars.emotes[string.lower(arg)]
            if emote then
                CE.internal.interpreter.playEmote(emote)
            else
                d("[CustomEmotes] Emote not found.")
            end

        end
    end
end

-- Inserts a new emote into the commands
function internal.registerEmoteCommand(emoteName)

    if not CE.savedVars.overrideCommands then
        return
    end

    if SLASH_COMMANDS['/' .. emoteName] then
        return
    end
    if commands[emoteName] then
        return
    end
    commands[emoteName] = true
    SLASH_COMMANDS['/' .. emoteName] = function(arg)
        DoCommand(CE.savedVars.command .. " " .. emoteName)
    end
end

-- Removes an emote from the commands
function internal.unregisterEmoteCommand(emoteName)
    if not commands[emoteName] then
        return
    end
    commands[emoteName] = nil
    SLASH_COMMANDS[emoteName] = nil
end