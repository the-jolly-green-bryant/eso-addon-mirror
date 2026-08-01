Mudballed = Mudballed or {}
local Mud = Mudballed

---------------------------------------------------------------------
-- lazy, copied from https://stackoverflow.com/questions/15706270/sort-a-table-in-lua
local function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys + 1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a, b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

---------------------------------------------------------------------
local typeToHeader = {
    mudball = "mudballed",
    snowball = "snowballed",
    pie = "pied",
    blossom = "blessed",
    crow = "pecked",
}

-- self chat output limit seems to be 350
local function FormatTally(tally, ballType)
    local result = {}
    for name, count in spairs(tally, function(t, a, b) return t[b] < t[a] end) do
        table.insert(result, string.format("%s: %d", name, count))
    end

    local resultString = table.concat(result, " || ")
    if (resultString == "") then return string.format("|cDDAAAANo tally yet, go %s some people! Or get %s.", ballType, typeToHeader[ballType]) end
    return resultString
end

---------------------------------------------------------------------
local function MakeHeader(isSource, ballType, isSession)
    local suffix = ":"
    if (isSession) then
        suffix = " in this session:"
    end

    if (isSource) then
        return "You've " .. typeToHeader[ballType] .. suffix
    else
        return "You've been " .. typeToHeader[ballType] .. " by" .. suffix
    end
end

local function OnCommand(argString, mainCmd, isSource, tally, sessionTally)
    local args = {}
    local length = 0
    for word in argString:gmatch("%S+") do
        table.insert(args, word)
        length = length + 1
    end

    if (length == 0) then
        if (isSource) then
            Mud.savedOptions.sourceDisplay.show = not Mud.savedOptions.sourceDisplay.show
            Mud.UpdateAllTallies()
        else
            Mud.savedOptions.targetDisplay.show = not Mud.savedOptions.targetDisplay.show
            Mud.UpdateAllTallies()
        end
    elseif (length == 1 or (length == 2 and args[2] == "session")) then
        local subTally = sessionTally[args[1]]
        if (subTally) then
            Mud.msg(MakeHeader(isSource, args[1], true))
            CHAT_SYSTEM:AddMessage("|cFFFFFF" .. FormatTally(subTally, args[1]) .. "|r")
        else
            Mud.msg("Must specify type: mudball||snowball||pie||blossom||crow")
        end
    elseif (length == 2 and args[2] == "all") then
        local subTally = tally[args[1]]
        if (subTally) then
            Mud.msg(MakeHeader(isSource, args[1], false))
            CHAT_SYSTEM:AddMessage("|cFFFFFF" .. FormatTally(subTally, args[1]) .. "|r")
        else
            Mud.msg("Must specify type: mudball||snowball||pie||blossom||crow")
        end
    else
        Mud.msg("Usage: " .. mainCmd .. " <mudball||snowball||pie||blossom||crow> [all||session]")
    end
end

---------------------------------------------------------------------
-- We are the source: display victims
local function OnMudballedCommand(argString)
    OnCommand(argString, "/mudballed", true, Mud.savedOptions.sourceTally, Mud.sessionSourceTally)
end

-- We are the target: display attackers
local function OnMudballCommand(argString)
    OnCommand(argString, "/mudball", false, Mud.savedOptions.targetTally, Mud.sessionTargetTally)
end

---------------------------------------------------------------------
SLASH_COMMANDS["/mudballed"] = OnMudballedCommand
SLASH_COMMANDS["/mudball"] = OnMudballCommand
