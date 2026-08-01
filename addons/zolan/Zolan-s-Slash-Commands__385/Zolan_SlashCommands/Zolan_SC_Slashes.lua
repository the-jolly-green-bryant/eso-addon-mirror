--------------------------------------------------------------------------------
--                   Zolan's Auto Repair (Slashes)
--------------------------------------------------------------------------------

local ZSC     = Zolan_SC
local Slashes = ZSC.Slashes
local Util    = ZSC.Util

-- ZO
local SLASH_COMMANDS = SLASH_COMMANDS
local ReloadUI       = ReloadUI
local d              = d
-- Lua
local table          = table
local string         = string

function Slashes.loadSlashCommands()
    ZSC.debug("Slashes -> loadSlashCommands")

    if ZSC.savedVars.enabled then
        SLASH_COMMANDS["/d"]   = Slashes.handleDebug
        SLASH_COMMANDS["/rl"]  = Slashes.handleReloadUI
        SLASH_COMMANDS["/x"]   = Slashes.handleExecute
        SLASH_COMMANDS["/zsc"] = Slashes.handleZSC
		SLASH_COMMANDS["/gl"] = Slashes.handleGroupLeave
		SLASH_COMMANDS["/leave"] = Slashes.handleGroupLeave
    else
        SLASH_COMMANDS["/d"]   = nil
        SLASH_COMMANDS["/rl"]  = nil
        SLASH_COMMANDS["/x"]   = nil
        SLASH_COMMANDS["/zsc"] = nil
    end
end

function Slashes.handleDebug(objectToOutput)
    ZSC.debug("Slashes -> handleDebug")

    SLASH_COMMANDS["/script"]("d(" .. objectToOutput .. ")")
end

function Slashes.handleReloadUI(ignoredText)
    ZSC.debug("Slashes -> handleReloadUI")
    ReloadUI()
end

function Slashes.handleGroupLeave()
	ZSC.debug("Slashes -> handleGroupLeave")
	GroupLeave()
end

function Slashes.handleExecute(code)
    ZSC.debug("Slashes -> handleExecute")

    SLASH_COMMANDS["/script"](code)
end

function Slashes.handleZSC(trailingText)
    ZSC.debug("Slashes -> handleZSC")

    local outputText = {}
    table.insert(outputText, string.format(
        "%s%s List of Slash Commands",
        ZSC.Vars.outputHeader,
        ZSC.Vars.defaultColor
    ))

    table.insert(outputText, string.format(
        '%s/zsc%s - This Text',
        ZSC.Vars.currencyColor,
        ZSC.Vars.defaultColor
    ))
    table.insert(outputText, string.format(
        '%s/rl%s - Reload UI - Shortcut for /reloadui',
        ZSC.Vars.currencyColor,
        ZSC.Vars.defaultColor
    ))
    table.insert(outputText, string.format(
        '%s/d <OBJ>%s - Debug - Shortcut for /script d(<OBJ>)',
        ZSC.Vars.currencyColor,
        ZSC.Vars.defaultColor
    ))
    table.insert(outputText, string.format(
        '%s/x <CODE>%s - Debug - Shortcut for /script <CODE>',
        ZSC.Vars.currencyColor,
        ZSC.Vars.defaultColor
    ))

    Util.sendMessageToChat(table.concat(outputText, "\n"))
end
