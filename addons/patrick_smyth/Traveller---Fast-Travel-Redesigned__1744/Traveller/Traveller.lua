--[[
    Traveller by Patrick Smyth
    
    Main module

    Traveller is a mod for the Elder Scrolls Online. It makes fast travel more user friendly
    for players who prefer to use the chat window rather than a GUI.

    This module serves several purposes as it contains routines that do not have their own
    module.

    Disclaimer:
        This Add-on is not created by, affiliated with or sponsored by ZeniMax
        Media Inc. or its affiliates. The Elder Scrolls® and related logos are
        registered trademarks or trademarks of ZeniMax Media Inc. in the United
        States and/or other countries. All rights reserved.
        You can read the full terms at https://account.elderscrollsonline.com/add-on-terms

--]]

Traveller = {
name = "Traveller", -- Name of the Addon as a string
version = "1",
saveCache = { diagLevel = 50 }
}


-- ==========================================================================================
--
-- Global constants
--

-- Jump type used in several modules
G_JUMP_NODE    = "n"
G_JUMP_LEADER  = "l"
G_JUMP_GROUP   = "g"
G_JUMP_FRIEND  = "f"
G_JUMP_HOUSE   = "h"

-- ==========================================================================================
--
-- Diagnostic routines
--

local l_DIAG_LEVEL = 50
local l_DIAG_DEFAULT = 30

function Traveller:Diag(inString, level)
    local dLevel = level or l_DIAG_DEFAULT
    local maxLevel = Traveller.saveCache.diagLevel

    if maxLevel == nil then
        Traveller.saveCache.diagLevel = l_DIAG_LEVEL
        maxLevel = l_DIAG_LEVEL
    end

    if (Utils:IsString(inString)) and (dLevel <= maxLevel) then
        local outString = Traveller.name .. ": " .. inString
        d(outString)
    end
end

function Traveller:SetDiagLevel(level)

    if level == nil then
        local dLevel = Traveller.saveCache.diagLevel

        if dLevel == nil then
            Traveller.saveCache.diagLevel = l_DIAG_LEVEL
            dLevel = l_DIAG_LEVEL
        end

        self:Diag("Current diagnostic level: " .. tostring(dLevel), 0)
    else
        local nLevel = tonumber(level)
        nLevel = nLevel or l_DIAG_LEVEL

        if (nLevel >= 0) and (nLevel <= 100) then
            Traveller.saveCache.diagLevel = nLevel
            self:Diag("New diagnostic level: " .. tostring(nLevel), 10)
        else
            self:Diag("Level must be 0 to 100")
        end
    end
end

-- ==========================================================================================
--
-- Console support routines
--
local function l_CheckPlayer()
    local playerOK = false

    if CanLeaveCurrentLocationViaTeleport() then
        playerOK = true
    elseif IsInTutorialZone() then
        Traveller:Diag("Fast travel not allowed in tutorial zone", 20)
    elseif IsInOutlawZone() then
        Traveller:Diag("Fast travel not allowed in outlaw refuge", 20)
    else
        Traveller:Diag("Current location does not allow fast travel", 20)
    end

    if playerOK then
        if IsPlayerInAvAWorld() or IsActiveWorldBattleground() then
            Traveller:Diag("Traveller jumps disabled in PvP world", 20)
            playerOK = false
        end
    end

    return playerOK
end

function Traveller:GotoNode(targetName)
    local playerOK = l_CheckPlayer()

    if playerOK then
        Nodes:Goto(targetName)
    end
end

function Traveller:GotoNodeAC(targetAC)
    local playerOK = l_CheckPlayer()

    if playerOK then
        Nodes:GotoAC(targetAC)
    end
end

function Traveller:ListNodes()
    Nodes:List()
end

function Traveller:GotoLeader()
    local playerOK = l_CheckPlayer()

    if playerOK then
        Players:GotoLeader(targetName)
    end
end

function Traveller:GotoPlayer(targetName)
    local playerOK = l_CheckPlayer()

    if playerOK then
        Players:Goto(targetName)
    end
end

function Traveller:GotoZone(targetName)
    local playerOK = l_CheckPlayer()

    if playerOK then
        Zones:Goto(targetName)
    end
end

function Traveller:GotoZoneAC(targetAC)
    local playerOK = l_CheckPlayer()

    if playerOK then
        Zones:GotoAC(targetAC)
    end
end

function Traveller:ListZones()
    Zones:List()
end

function Traveller:GotoRandom()
    local playerOK = l_CheckPlayer()

    if playerOK then
        Zones:GotoRandom()
    end
end

function Traveller:GotoLocal()
    local playerOK = l_CheckPlayer()

    if playerOK then
        Zones:GotoLocal()
    end
end

function Traveller:GotoHome()
    local playerOK = l_CheckPlayer()

    if playerOK then
         Houses:MyHome()
    end
end

function Traveller:GotoHouse(targetName)
    local playerOK = l_CheckPlayer()

    if playerOK then
         Houses:MyHouse(targetName)
    end
end

function Traveller:GotoHouseAC(targetAC)
    local playerOK = l_CheckPlayer()

    if playerOK then
         Houses:MyHouseAC(targetAC)
    end
end

function Traveller:ListHouses()
    Houses:List()
end

function Traveller:GotoPlayerHome(targetPlayer)
    local playerOK = l_CheckPlayer()

    if playerOK then
         Houses:PlayerHome(targetPlayer)
    end
end

function Traveller:GotoPlayerHouse(targetPlayer, targetName)
    local playerOK = l_CheckPlayer()

    if playerOK then
         Houses:PlayerHouse(targetPlayer, targetName)
    end
end

function Traveller:GotoPlayerHouseAC(targetAC)
    local playerOK = l_CheckPlayer()

    if playerOK then
         Houses:PlayerHouseAC(targetPlayer, targetAC)
    end
end

function Traveller:CancelGoto()
    Gotos:CancelGoto()
end

function Traveller:DisplayOrder()
    Order:Display()
end

function Traveller:SetOrder(order)
    Order:Set(order)
end

function Traveller:ResetOrder()
    Order:Reset()
end

-- ==========================================================================================
--
-- Table validation routines
--
local function l_ESOVersion()
    local version = ""

    version = GetESOVersionString()
    version = version or "_INVALID_VERSION_"

    return version
end

function Traveller:IsTableOld(infoTable, entryCount)
    local oldTable = true
    local esoVersion = l_ESOVersion()
    self:Diag("*Is Table Old?*", 70)

    if infoTable == nil then return true end -- Abort - no table

    local tabEsoVersion = infoTable.esoVersion or ""
    local tabEntryCount = infoTable.entryCount or -32767

    self:Diag("Table ESO Version: " .. tabEsoVersion, 70)
    self:Diag("Table Entry Count: " .. tostring(tabEntryCount), 70)

    esoVersion = esoVersion or "XXXXXX"
    entryCount = entryCount or tabEntryCount

    self:Diag("Current ESO Version: " .. esoVersion, 70)
    self:Diag("Current Entry Count: " .. tostring(entryCount), 70)

    oldTable = (tabEsoVersion ~= esoVersion) or
                (tabEntryCount ~= entryCount)

    if oldTable then
        self:Diag("Table needs updating", 70)
    else
        self:Diag("Table is up-to-date", 70)
    end

    return oldTable
end

function Traveller:MarkTableOld(infoTable)

    if infoTable == nil then return end -- Abort - no table

    self:Diag("*Mark Table Old*", 70)
    infoTable.esoVersion = "*Old*"
    infoTable.entryCount = nil
    self:Diag("Table marked old", 70)
end

function Traveller:MarkTableUpdated(infoTable, entryCount)

    if infoTable == nil then return end -- Abort - no table

    infoTable.esoVersion = l_ESOVersion()
    infoTable.entryCount = entryCount -- if entry count not specified will delete

    self:Diag("*Mark Table Updated*", 70)
    self:Diag("Table ESO version: " .. infoTable.esoVersion, 70)
    if entryCount ~= nil then
        self:Diag("Entry Count: " .. tostring(entryCount), 70)
    end
end

function Traveller:TableUniqueAdd(baseTable, key, entry)
    local newKey = key
    local dupNum = 2

    -- Resolve duplicate entries - assumes string key
    while baseTable[newKey] ~= nil do
        Traveller:Diag("*** Duplicate Table Key - <" .. newKey .. ">", 70)

        newKey = key .. tostring(dupNum)
        dupNum = dupNum + 1

        Traveller:Diag("Renaming New Table Key - <" .. newKey .. ">", 70)
    end

    -- Add to table with unique key
    baseTable[newKey] = entry

end

-- ==========================================================================================
--
-- Collectible message routine
--
function Traveller:CollectibleDesc(collectibleId)

    if collectibleId ~= nil then
        local cName = ""
        local cDesc = ""

        cName, cDesc = GetCollectibleInfo(collectibleId)
        cName = cName or ""
        cDesc = cDesc or ""
        self:Diag("Collectible: " .. cName .. " - " .. cDesc)
    end
end

-- ==========================================================================================
--
-- Initialisation
--
function Traveller:Initialise()
    Gotos:Initialise()
    Console:Initialise(Traveller.saveCache)
    Order:Initialise(Traveller.saveCache)
    Nodes:Initialise(Traveller.saveCache)
    Zones:Initialise(Traveller.saveCache)
    Houses:Initialise(Traveller.saveCache)
end

function Traveller.OnAddOnLoaded(event, addonName)
    -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
    if addonName == Traveller.name then
        -- Make sure we only start once
        EVENT_MANAGER:UnregisterForEvent(Traveller.name, EVENT_ADD_ON_LOADED)

        -- Recover the contents of the saved variables file
        Traveller.saveCache = ZO_SavedVars:NewAccountWide("Traveller_SavedVariables", Traveller.version, "", { diagLevel = 50 }, nil)

        -- Initialise this module
        Traveller:Initialise()
        Traveller:Diag("Addon Started", 70)
    end
end

-- Register our event handler function to be called when the proper event occurs.
EVENT_MANAGER:RegisterForEvent(Traveller.name, EVENT_ADD_ON_LOADED, Traveller.OnAddOnLoaded)