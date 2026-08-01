local DMT = DeadMansTally

---------------------------------------------------------------------
function DMT.msg(msg)
    if (not msg) then return end
    msg = "|c3bdb5e[DMT]|caaaaaa " .. tostring(msg) .. "|r"
    if (CHAT_ROUTER) then
        CHAT_ROUTER:AddSystemMessage(msg)
    end
end


---------------------------------------------------------------------
local function GetTally()
    local str = ""
    for _, entry in ipairs(DMT.GetSorted()) do
        local currString = string.format("%s: %d ", entry.name, entry.num)
        if (string.len(str) + string.len(currString) > ZO_ChatWindowTextEntryEditBox:GetMaxInputChars()) then
            return str
        end
        str = str .. currString
    end

    return str
end

local function PrintTally()
    if (KEYBOARD_CHAT_SYSTEM) then
        KEYBOARD_CHAT_SYSTEM:StartTextEntry(GetTally())
    end
end


---------------------------------------------------------------------
local function PrintUsage()
    DMT.msg([[Usage:
|cAAAAAA/dmt tally - toggles the UI
|cAAAAAA/dmt print - starts a chat message of the death tally with the current filters
|cAAAAAA/dmt lock
|cAAAAAA/dmt unlock
|cAAAAAA/dmt settings
|cAAAAAA/dmt reset]])
end

---------------------------------------------------------------------
SLASH_COMMANDS["/dmt"] = function(argString)
    local args = {}
    for word in string.gmatch(argString, "%S+") do
        table.insert(args, word)
    end

    if (#args == 0) then
        PrintUsage()
        return
    end
    local cmd = string.lower(args[1])

    local currSVs = DMT.packedSVs[GetWorldName()][GetUnitDisplayName("player")]

    ------------
    if (args[1] == "tally") then
        DMT.ToggleUI()

    elseif (args[1] == "print") then
        PrintTally()

    elseif (args[1] == "lock") then
        DMT.Lock()

    elseif (args[1] == "unlock") then
        DMT.Unlock()

    elseif (args[1] == "settings") then
        LibAddonMenu2:OpenToPanel(DeadMansTallyOptions)

    elseif (args[1] == "reset") then
        DMT.ClearSession()

    else
        PrintUsage()
    end
end

