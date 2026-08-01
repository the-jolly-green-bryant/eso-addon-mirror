--[[
    Traveller by Patrick Smyth

    Module to handle chat window interactions

--]]
Console = {
    saveCache = { }
}

-- ==========================================================================================
--
-- Local constants and data
--

local l_HouseDelim = "<"
local l_AliasTable = { }

-- ==========================================================================================
--
-- Local routines
--

local function l_CheckArgs(args, delim)
    local argstring1 = nil
    local argstring2 = nil

    if args ~= nil then
        local argstring = Utils:Trim(args)

        if argstring ~= "" then
            local delimpt = nil

            if delim ~= nil then
                -- delimiter divides arg 1 from arg 2
                delimpt = string.find(argstring, delim)
            end

            if delimpt ~= nil then
                local delimLen = string.len(delim)

                argstring1 = string.sub(argstring, 1, delimpt - 1)
                argstring1 = Utils:Trim2(argstring1)
                argstring2 = string.sub(argstring, delimpt + delimLen)
                argstring2 = Utils:Trim2(argstring2)
            else
                -- no delimiter - everything goes into arg1
                argstring1 = argstring
            end
        end
    end

    return argstring1, argstring2
end

local function l_ModifyAlias(aliasName, destination)

--    d("Alias" .. aliasName .. " Value " .. destination)

    l_AliasTable[aliasName] = destination
    if destination ~= nil then
        d(aliasName .. " set as alias for " .. destination)
    else
        d("Alias " .. aliasName .. " deleted")
    end
end

local function l_FindAlias(aliasName)
    local aliasTarget = nil
    local alias = ""
    local goodStr = Utils:IsString(aliasName)

    if goodStr then
        alias = Utils:Trim(aliasName)
        aliasTarget = l_AliasTable[alias]

        if aliasTarget == nil then
            -- no alias found - use trimmed version of input
            aliasTarget = alias
        else
            d("Using alias " .. aliasTarget)
        end
    end

    return aliasTarget
end

local function l_ListAliases()
    local workTab = Tab:Start()

    Tab:Title(workTab, "Alias List")
    Tab:ColumnHeaders(workTab, "Alias", "Value")

    for akey, avalue in pairs(l_AliasTable) do
        Tab:AddRow(workTab, akey, avalue)
    end

    Tab:PrintTab(workTab)
end

-- ==========================================================================================
--
--  External Interface
--

function Console:Initialise(saveCache)
    Console.saveCache = saveCache

    if Console.saveCache.aliasTable == nil then
        Console.saveCache.aliasTable = { }
    end

    l_AliasTable = Console.saveCache.aliasTable

    self:ConsoleCommands()
    -- Traveller:Diag("console started")
end

--[[
    Console commands
]]--
function Console:ConsoleCommands()
    local arg1 = ""
    local arg2 = ""

    -- Help screen - list all available commands
    SLASH_COMMANDS["/thelp"] = function ()
        local guildChar = ""
        d("-- Traveller Commands --")
        d("/tn   (One Arg)  Goto Node - may cost gold")
        d("/tn   (No Args)  List valid Nodes - with shortnames")
        d("/tna  (One Arg)  Goto Node (with Autocomplete) - may cost gold")
        d("/th   (No Args)  Goto Home (primary residence)")
        d("/th   (One Arg)  Goto House (House name preceded by '>')")
        d("/th   (One Arg)  Goto Player Home (primary residence)")
        d("                 Player must be in search order - see /tso")
        d("                 Can use player's account name or character name")
        d("/th   (Two Args) Goto Player House")
        d("                 The two arguments are: player>house")
        d("                 The '>' sign is mandatory")
        d("/tha  (One Arg)  Goto House (with Autocomplete)")
        d("/tha  (Two Args) Goto Player House (with Autocomplete for house)")
        d("/thl  (No Args)  List possible houses")
        d("/tp   (One Arg)  Goto Player (nearest node)")
        d("                 Player must be in search order - see /tso")
        d("                 Can use player's account name or character name")
        d("/tz   (One Arg)  Goto any player in Zone")
        d("/tz   (No Args)  List valid Zones - with shortnames")
        d("/tza  (One Arg)  Goto any player in Zone (with Autocomplete)")
        d("/tg   (No Args)  Goto group leader")
        d("/tx   (No Args)  Goto eXit - goto first available player")
        d("/tl   (No Args)  Goto exit - goto player in Local zone")
        d("/tc   (No Args)  Cancel goto")
        d("/ta   (No Args)  List Aliases")
        d("/ta   (Two Args) Create/Modify Alias")
        d("                 The two arguments are: alias value")
        d("                 The alias must be one word")
        d("/ta   (One Arg)  Delete Alias")
        d("/tso  (No Args)  Display search order used for /tp, /th, /tl, /tx, and /tz")
        d("/tso  (One Arg)  Set search Order - see below")
        d("/tro  (No Args)  Reset search order to default - 'gf12345'")
        -- d("/td   (One Arg)  Set diagnostic level (0-100) (0 = quiet)")
        d(" ")
        d("/tso search order strings use only the characters gf12345")
        d("g - search current group members")
        d("f - search friend list")
        for count = 1, MAX_GUILDS do
            guildChar = tostring(count)
            d(guildChar .. " - search the members of guild " .. guildChar)
        end
        d("The characters can be in any order but they must not repeat")
        d("There must be at least one character and no spaces")
        d("/tso (one arg) evaluates aliases")
        d("Examples:")
        d("/tso gf12345 - This is the default")
        d("/tso 54321fg - search everything backwards (guild 5 first)")
        d("/tso gf34    - omit guilds 1, 2 and 5")
        d("/tso 3       - search only guild 3")
    end

    --
    -- Nodes
    --

    -- Goto Node / List Nodes
    SLASH_COMMANDS["/tn"] = function (args)
        arg1 = l_CheckArgs(args)

        if arg1 == nil then
            Traveller:ListNodes()
        else
           arg1 = l_FindAlias(arg1)

            if arg1 ~= nil then
                Traveller:GotoNode(arg1)
            end
        end
    end

    -- Goto Node (with autocomplete)
    SLASH_COMMANDS["/tna"] = function (args)
        arg1 = l_CheckArgs(args)

        if arg1 ~= nil then
            Traveller:GotoNodeAC(arg1)
        end
    end

    --
    -- Players
    --

    -- Goto Player
    SLASH_COMMANDS["/tp"] = function (args)
        arg1 = l_CheckArgs(args)

        arg1 = l_FindAlias(arg1)

        if arg1 ~= nil then
            Traveller:GotoPlayer(arg1)
        end
    end

    -- Goto group leader
    SLASH_COMMANDS["/tg"] = function ()
        Traveller:GotoLeader()
    end

    -- Goto random player
    SLASH_COMMANDS["/tx"] = function ()
        Traveller:GotoRandom()
    end

    --
    -- Houses
    --

    -- List possible houses
    SLASH_COMMANDS["/thl"] = function ()
        Traveller:ListHouses()
    end

    -- Goto Home / House
    SLASH_COMMANDS["/th"] = function (args)
        
        -- find alias for whole argument string
        args = l_FindAlias(args)

        -- split into arg 1 & 2
        arg1, arg2 = l_CheckArgs(args, l_HouseDelim)

        -- find alias just for arg 1
        arg1 = l_FindAlias(arg1)

        -- find alias just for arg 2
        arg2 = l_FindAlias(arg2)

        if (arg1 == nil) and (arg2 == nil) then
            Traveller:GotoHome()
        elseif arg2 == nil then
            Traveller:GotoPlayerHome(arg1)
        elseif arg1 == nil then
            Traveller:GotoHouse(arg2)
        else
            Traveller:GotoPlayerHouse(arg1, arg2)
        end
    end

    -- Goto House (with autocomplete for house name)
    SLASH_COMMANDS["/tha"] = function (args)
        
        -- split into arg 1 & 2
        arg1, arg2 = l_CheckArgs(args, l_HouseDelim)

        if (arg1 == nil) and (arg2 == nil) then
            Traveller:GotoHome()
        elseif arg2 == nil then
            Traveller:GotoPlayerHome(arg1)
        elseif arg1 == nil then
            Traveller:GotoHouseAC(arg2)
        else
            Traveller:GotoPlayerHouseAC(arg1, arg2)
        end
    end

    --
    -- Zones (Player in Zone)
    --

    -- Goto Zone / List zones
    SLASH_COMMANDS["/tz"] = function (args)
        arg1 = l_CheckArgs(args)

        if arg1 == nil then
            Traveller:ListZones()
        else
           arg1 = l_FindAlias(arg1)

            if arg1 ~= nil then
                Traveller:GotoZone(arg1)
            end
        end
    end

    -- Goto Zone (with autocomplete)
    SLASH_COMMANDS["/tza"] = function (args)
        arg1 = l_CheckArgs(args)

        if arg1 ~= nil then
            Traveller:GotoZoneAC(arg1)
        end
    end

     -- Goto player in local zone
    SLASH_COMMANDS["/tl"] = function ()
        Traveller:GotoLocal()
    end

    --
    -- Search Order
    --

    -- Set / Display search order
    SLASH_COMMANDS["/tso"] = function (args)
        arg1 = l_CheckArgs(args)

        if arg1 == nil then
            Traveller:DisplayOrder()
        else
           arg1 = l_FindAlias(arg1)

            if arg1 ~= nil then
                Traveller:SetOrder(arg1)
            end
        end
    end

     -- Reset search order
    SLASH_COMMANDS["/tro"] = function ()
        Traveller:ResetOrder()
    end

    --
    -- Aliases
    --

    -- Create/Modify/Delete Alias
    SLASH_COMMANDS["/ta"] = function (args)
        arg1, arg2 = l_CheckArgs(args, " ")

        if arg1 ~= nil then
            arg1 = l_ModifyAlias(arg1, arg2)
        else
            l_ListAliases()
        end
    end

    --
    -- Miscellaneous
    --

    -- Cancel goto
    SLASH_COMMANDS["/tc"] = function ()
        Traveller:CancelGoto()
    end

    -- Set Diagnostic Level
    SLASH_COMMANDS["/td"] = function (args)
        arg1 = l_CheckArgs(args)
        Traveller:SetDiagLevel(arg1)
    end
--[[
    -- temporary - reloadui
    SLASH_COMMANDS["/rl"] = function ()
        ReloadUI()
    end
--]]
end