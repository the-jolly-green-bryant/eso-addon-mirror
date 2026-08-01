--[[
    Traveller by Patrick Smyth
    
    Module to handle fast travel to houses. Both the player's own houses and those of other
    players are covered.

--]]
Houses = { }

-- ==========================================================================================
--
-- Local routines
--

local function l_NormaliseHouseName(houseName)
    local normed = houseName or ""

    normed = string.gsub(normed, "%c+", "")
  
    normed = Utils:Trim(normed)
    -- normed = LocaleAwareToLower(normed)
    normed = string.lower(normed)

    -- d("----------------")
    -- d(houseName .. "<" .. normed .. ">")

    normed = Utils:RemoveFromStartStr(normed, "the ")

    -- normed = string.gsub(normed, "%s+", "")
    normed = string.gsub(normed, "[ '-,]", "")

    -- d(houseName .. "<" .. normed .. ">")

    return normed
end

local function l_GetFullHouseName(shortName)
    local fullName = ""
    local nodeIndex = Houses.saveCache.houseTable[shortName]
    shortName = shortName or ""

    if nodeIndex ~= nil then
        _, fullName = GetFastTravelNodeInfo(nodeIndex)
        fullName = fullName or shortName
    else
        fullName = shortName
    end

    return fullName
end

local function l_LoadHouseTable(saveCache)
    local maxNodes = GetNumFastTravelNodes()
    local newVer = true

    if saveCache.houseTable == nil then
        saveCache.houseTable = { }
    end

    if saveCache.houseACL == nil then
        saveCache.houseACL = { }
    end

    if saveCache.houseIds == nil then
        saveCache.houseIds = { }
    end

    if saveCache.houseInfo == nil then
        saveCache.houseInfo = { }
    end

    newVer = Traveller:IsTableOld(saveCache.houseInfo)
    -- *** Temporary fix to allow testing
    -- newVer = true

    -- house table changes with almost every version so if we detect a new version we reload the table
    if newVer then
        local houseName = ""
        local normName = ""
        local ACName = ""
        local count = 0
        local dupNum = 1
        local poitype = 0
        local houseOk = true
        local houseId = 0
 
        -- Traveller:Diag("Starting Load House Table - Entries " .. tostring(maxNodes))
        Traveller:MarkTableOld(saveCache.houseInfo)
        ZO_ClearTable(saveCache.houseTable)
        ZO_ClearTable(saveCache.houseACL)
        ZO_ClearTable(saveCache.houseIds)

        for nodeIndex = 1, maxNodes do
            _, houseName, _, _, _, _, poiType = GetFastTravelNodeInfo(nodeIndex)
            houseName = houseName or ""
            poiType = poiType or 0

            houseOk = ((houseName ~= "") and (poiType == POI_TYPE_HOUSE))

            if houseOk then
                -- we have a house

                normName = l_NormaliseHouseName(houseName)
                houseOk = (normName ~= "")
            end

            if houseOk then
                houseId = GetFastTravelNodeHouseId(nodeIndex)
                houseOk = (houseId ~= nil)
            end

            if houseOk then
                -- Add house to house table
                Traveller:TableUniqueAdd(saveCache.houseTable, normName, nodeIndex)

                -- Add house to autocomplete table
                ACName = string.lower(houseName)
                Traveller:TableUniqueAdd(saveCache.houseACL, ACName, normName)

                -- Add ID to node index table
                saveCache.houseIds[houseId] = nodeIndex

                -- increment entry count
                count = count + 1
            end
        end

        -- done
        Traveller:MarkTableUpdated(saveCache.houseInfo)
        Traveller:Diag("Houses added " .. tostring(count), 70)
        -- Traveller:Diag("Ended Load House Table")
    end
end

local function l_ValidateHouseName(houseName)
    local nodeIndex = 0
    local name = houseName or ""
    local houseOk = true
    local known = false
    local linkedCollectibleIsLocked = false
    
    if name ~= "" then
        name = l_NormaliseHouseName(name)
        name = name or ""
    end

    if name == "" then
        Traveller:Diag("House name is empty - " .. houseName)
        houseOk = false
    end

    if houseOk then
        nodeIndex = Houses.saveCache.houseTable[name]
        houseOk = (nodeIndex ~= nil)
        if not houseOk then
            Traveller:Diag("Unknown House - " .. houseName)
        end
    end

    if houseOk then
        houseOk = (nodeIndex > 0)
        if not houseOk then
            Traveller:Diag("House entry is invalid - " .. houseName)
        end
    end

    if houseOk then
        known, _, _, _, _, _, _, _, linkedCollectibleIsLocked = GetFastTravelNodeInfo(nodeIndex)

        if (known == nil) or (linkedCollectibleIsLocked == nil) then
            Traveller:Diag("House info is invalid - " .. houseName)
            houseOk = false
        end
    end

    if houseOk and linkedCollectibleIsLocked then
        local collectibleId = 0

        Traveller:Diag("House requires collectible - " .. houseName)
        collectibleId = GetFastTravelNodeLinkedCollectibleId(nodeIndex)
        Traveller:CollectibleDesc(collectibleId)

        houseOk = false
    end
 
    if houseOk and not known then
        Traveller:Diag("This character has not discovered this house yet - " .. houseName)
        houseOk = false
    end

    if houseOk then
        return name, nodeIndex
    else
        return
    end
end

-- ==========================================================================================
--
-- Callback routines
--

local function c_PlayerCallback(playerDesc, param)
    local gotName = false

    if playerDesc.characterName ~= nil then
        gotName = Players:AreNamesEqual(param.name, playerDesc.characterName)
    end

    if (not gotName) and (playerDesc.displayName ~= nil) then
        gotName = Players:AreNamesEqual(param.name, playerDesc.displayName)
    end

    if gotName then
        Gotos:SingleJump(G_JUMP_HOUSE, playerDesc.displayName, playerDesc.characterName, param.nodeIndex)
        param.gotplayer = true
    end

    return gotName
end

-- ==========================================================================================
--
--  External Interface
--

function Houses:Initialise(saveCache)
    Houses.saveCache = saveCache

    l_LoadHouseTable(Houses.saveCache)
end

function Houses:MyHome()
    local nodeIndex = 0
    local houseId = GetHousingPrimaryHouse()

    if houseId ~= nil then
        nodeIndex = Houses.saveCache.houseIds[houseId]
        if nodeIndex ~= nil then
            Traveller:Diag("Travelling to Primary Home", 30)
            Gotos:SingleJump(G_JUMP_HOUSE, nil, nil, nodeIndex)
        else
            Traveller:Diag("Primary Home is invalid", 30)
        end
    else
        Traveller:Diag("Primary Home not available", 30)
    end
end

function Houses:MyHouse(houseName)
    local nodeIndex = 0
    local name = ""

    name, nodeIndex = l_ValidateHouseName(houseName)

    if name ~= nil then
        local fullName = l_GetFullHouseName(name)
        Traveller:Diag("Travelling to " .. fullName, 30)
        Gotos:SingleJump(G_JUMP_HOUSE, nil, nil, nodeIndex)
    end
end

function Houses:MyHouseAC(target)
    local normName = Utils:ACLookup(Houses.saveCache.houseACL, target)

    if normName ~= "" then
        self:MyHouse(normName)
    else
        Traveller:Diag("No autocompletion found for " .. target)
    end
end

function Houses:PlayerHome(playerName)
    local badName = false
    local pName = Players:ValidateName(playerName)

    badname = (pName == nil)

    if not badName then
        badName = Players:IsNameSelf(pName)

        if badName then
            -- goto own home
            self:MyHome()
        end
    end

    if not badName then
        local param = { name = pName,
                        gotplayer = false }

        Order:Process(c_PlayerCallback, param)

        if not param.gotplayer then
            Traveller:Diag("Player not found - " .. playerName)
        end
    end
end

function Houses:PlayerHouse(playerName, houseName)
    local badName = false
    local name = ""
    local nodeIndex = 0
    local pName = Players:ValidateName(playerName)

    badname = (pName == nil)

    if not badName then
        badName = Players:IsNameSelf(pName)

        if badName then
            -- goto own house
            self:MyHouse(houseName)
        end
    end

    if not badName then
        name, nodeIndex = l_ValidateHouseName(houseName)
        badName = (nodeIndex == nil)
    end

    if not badName then
        local param = { name = pName,
                        gotplayer = false,
                        nodeIndex = nodeIndex }

        Order:Process(c_PlayerCallback, param)

        if not param.gotplayer then
            Traveller:Diag("Player not found - " .. playerName)
        end
    end
end

function Houses:PlayerHouseAC(playerName, target)
    local normName = Utils:ACLookup(Houses.saveCache.houseACL, target)

    if normName ~= "" then
        self:PlayerHouse(playerName, normName)
    else
        Traveller:Diag("No autocompletion found for " .. target)
    end
end

function Houses:List()
    local fullName = ""
    local workTab = Tab:Start()

    Tab:Title(workTab, "House List")

    Tab:ColumnHeaders(workTab, "Full Name", "Short Name")

    for akey, avalue in pairs(Houses.saveCache.houseTable) do

        fullName = l_GetFullHouseName(akey)

        Tab:AddRow(workTab, fullName, akey)
    end

    Tab:PrintTab(workTab)
end