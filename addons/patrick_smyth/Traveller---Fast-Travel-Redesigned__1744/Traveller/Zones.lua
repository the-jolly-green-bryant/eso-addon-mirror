--[[
    Traveller by Patrick Smyth
    
    Module to handle fast travel to players using zone names

--]]

Zones = {
    saveCache = { }
}

-- ==========================================================================================
--
--  Local constants
--

-- local l_MAX_ZONES = 562
local l_MAX_ZONES = 10000

-- ==========================================================================================
--
-- Local routines
--

local function l_NormaliseZoneName(zoneName)
    local normed = ""
    
    normed = Utils:Trim(zoneName)
    normed = string.lower(normed)

    -- d("----------------")
    -- d(zoneName .. "<" .. normed .. ">")

    normed = Utils:RemoveFromStartStr(normed, "the ")

    -- normed = string.gsub(normed, "%s+", "")
    normed = string.gsub(normed, "[ '-]", "")
    normed = string.gsub(normed, "[,]", "")

    -- d(zoneName .. "<" .. normed .. ">")

    return normed
end

local function l_CheckZoneName(zoneName)
    local checkedZone = zoneName or ""

    if checkedZone == "zTestBarbershop" then
        checkedZone = ""
    end

    if checkedZone == "Clean Test" then
        checkedZone = ""
    end

    if checkedZone ~= "" then
        local bandit = Utils:StartsWithStr(checkedZone, "Bandit ")

        if bandit then
           checkedZone = ""
        end
    end

    return checkedZone
end

local function l_LoadZoneTable(saveCache)
    -- local saveCache = Zones.saveCache
    local newVer = true
    
    if saveCache.zoneTable == nil then
        saveCache.zoneTable = { }
    end

    if saveCache.zoneACL == nil then
        saveCache.zoneACL = { }
    end

    if saveCache.zoneInfo == nil then
        saveCache.zoneInfo = { }
    end

    newVer = Traveller:IsTableOld(saveCache.zoneInfo)
    -- *** Temporary fix to allow testing
    -- newVer = true

    -- if we detect a new version we reload the table
    if newVer then
        local normName = ""
        local zoneIndex = 0
        local zoneId = 0
        local canJump = false
        local result = 0
        local count = 0
        local zoneName = ""

        Traveller:MarkTableOld(saveCache.zoneInfo)
        ZO_ClearTable(saveCache.zoneTable)
        ZO_ClearTable(saveCache.zoneACL)
 
        repeat
            zoneIndex = zoneIndex + 1
            canJump = false
            zoneName = GetZoneNameByIndex(zoneIndex)
            zoneName = l_CheckZoneName(zoneName)

            if zoneName ~= "" then
                zoneId = GetZoneId(zoneIndex)
                if zoneId ~= nil then
                    canJump, result = CanJumpToPlayerInZone(zoneId)
                    canJump = canJump or false
                    if not canJump then
                        -- reasons why we cannot jump "at the moment" but maybe later or with different char
                        canJump = ((result == JUMP_TO_PLAYER_RESULT_ZONE_COLLECTIBLE_LOCKED) or
                                    (result == JUMP_TO_PLAYER_RESULT_CROSS_ALLIANCE_LOCKED) or
                                    (result == JUMP_TO_PLAYER_RESULT_PLAYER_OFFLINE) or
                                    (result == JUMP_TO_PLAYER_RESULT_PLAYER_DIFFICULTY_LOCKED))
                    end
                end
            end

            if canJump then
                normName = l_NormaliseZoneName(zoneName)
                if normName ~= "" then
                    -- Add zone to zone table
                    Traveller:TableUniqueAdd(saveCache.zoneTable, normName, zoneIndex)

                    -- Add zone to autocomplete table
                    ACName = string.lower(zoneName)
                    Traveller:TableUniqueAdd(saveCache.zoneACL, ACName, normName)

                    -- increment entry count
                    count = count + 1
                end
            end
        until ((zoneName == nil) or (zoneIndex >= l_MAX_ZONES))

        Traveller:MarkTableUpdated(saveCache.zoneInfo, count)
        Traveller:Diag("Zones added " .. tostring(count), 70)
        -- Traveller:Diag("Ended Load Zone Table")
    end
end

local function l_ValidateZone(zoneName)
    local name = ""
    local zoneOk = true
    local zoneIndex = 0
    local zoneId = 0

    name = l_NormaliseZoneName(zoneName)

    if (name == nil) or (name == "") then
        Traveller:Diag("Zone name is empty - " .. zoneName)
        zoneOk = false
    end

    if zoneOk then
        zoneIndex = Zones.saveCache.zoneTable[name]
        zoneOk = (zoneIndex ~= nil)
        if not zoneOk then
            Traveller:Diag("Unknown zone - " .. zoneName)
        end
    end

    if zoneOk then
        zoneId = GetZoneId(zoneIndex)
        zoneOk = (zoneId ~= nil)
    end

    if zoneOk then
        local canJump = false
        local jumpStatus = 0

        canJump, jumpStatus = CanJumpToPlayerInZone(zoneId)
        canJump = canJump or false
        jumpStatus = jumpStatus or 32767

        if not canJump then
            if jumpStatus == JUMP_TO_PLAYER_RESULT_SOLO_ZONE then
                Traveller:Diag("Zone is solo zone - " .. zoneName)
            elseif jumpStatus == JUMP_TO_PLAYER_RESULT_CROSS_ALLIANCE_LOCKED then
                Traveller:Diag("Zone is not available (cross-alliance locked) - " .. zoneName)
            elseif jumpStatus == JUMP_TO_PLAYER_RESULT_PLAYER_DIFFICULTY_LOCKED then
                Traveller:Diag("Zone is not available (difficulty locked) - " .. zoneName)
            elseif jumpStatus == JUMP_TO_PLAYER_RESULT_ZONE_COLLECTIBLE_LOCKED then
                local collectibleId = 0
                Traveller:Diag("Zone requires collectible - " .. zoneName)

                collectibleId = GetCollectibleIdForZone(zoneIndex)
                Traveller:CollectibleDesc(collectibleId)
            else
                Traveller:Diag("Zone is not available - " .. zoneName)
            end

            zoneOk = false
        end
    end

    if zoneOk then
        return zoneId
    else
        return
    end
end

-- ==========================================================================================
--
-- Callback routines
--

local function c_ZoneCallback(playerDesc, param)

    if playerDesc.zoneId == param.zoneId then
        Gotos:AddToQueue(playerDesc.orderChar, playerDesc.displayName, playerDesc.characterName)
    end

    return false
end

local function c_RandCallback(playerDesc, param)

    Gotos:AddToQueue(playerDesc.orderChar, playerDesc.displayName, playerDesc.characterName)

    return false
end

-- ==========================================================================================
--
--  External Interface
--

function Zones:Initialise(saveCache)
    Zones.saveCache = saveCache

    l_LoadZoneTable(Zones.saveCache)
end

function Zones:Goto(zoneName)
    local uZoneId = nil
    
    ---
    --- First we check the zone request is reasonable
    ---
    uZoneId = l_ValidateZone(zoneName)

    ---
    --- Second stage is to find a player in that zone
    ---
    if uZoneId ~= nil then
        local playersFound = false
        local param = { zoneId = uZoneId }

        Order:Process(c_ZoneCallback, param)

        playersFound = not Gotos:IsQueueEmpty()

        if playersFound then
            Gotos:ActionQueue()
        else
            Traveller:Diag("No player found in zone - " .. zoneName)
        end
    end
end

function Zones:GotoAC(target)
    local normName = Utils:ACLookup(Zones.saveCache.zoneACL, target)

    if normName ~= "" then
        self:Goto(normName)
    else
        Traveller:Diag("No autocompletion found for " .. target)
    end
end

function Zones:List()
    local zoneName = ""
    local workTab = Tab:Start()

    Tab:Title(workTab, "Zone List")

    Tab:ColumnHeaders(workTab, "Full Name", "Short Name")

    for akey, avalue in pairs(Zones.saveCache.zoneTable) do

        zoneName = GetZoneNameByIndex(avalue)
        zoneName = zoneName or "Unknown"

        Tab:AddRow(workTab, zoneName, akey)
    end

    Tab:PrintTab(workTab)
end

function Zones:GotoRandom()
    local playersFound = false
    local param = { }

    Order:Process(c_RandCallback, param)

    playersFound = not Gotos:IsQueueEmpty()

    if playersFound then
        Gotos:ActionQueue()
    else
        Traveller:Diag("No players available")
    end
end

function Zones:GotoLocal()
    local zoneIndex = GetUnitZoneIndex("player")
    if zoneIndex ~= nil then
        local zoneName = GetZoneNameByIndex(zoneIndex)
        if zoneName ~= nil then
            Traveller:Diag("Current zone is " .. zoneName)
            self:Goto(zoneName)
        end
    end
end