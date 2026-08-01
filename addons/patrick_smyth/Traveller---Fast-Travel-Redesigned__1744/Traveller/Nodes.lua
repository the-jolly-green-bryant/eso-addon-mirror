--[[
    Traveller by Patrick Smyth
    
    Module to handle fast travel to Nodes (wayshrines, owned houses, etc.)

--]]
Nodes = {
    saveCache = { }
}

-- ==========================================================================================
--
-- Local routines
--

local function l_NormaliseNodeName(nodeName)
    local normed = nodeName or ""

    normed = string.gsub(normed, "%c+", "")
  
    normed = Utils:Trim(normed)
    -- normed = LocaleAwareToLower(normed)
    normed = string.lower(normed)

    -- d("----------------")
    -- d(nodeName .. "<" .. normed .. ">")

    normed = Utils:RemoveFromStartStr(normed, "dungeon:")
    normed = Utils:RemoveFromStartStr(normed, "the ")
    normed = Utils:RemoveFromEndStr(normed, " wayshrine")

    -- normed = string.gsub(normed, "%s+", "")
    normed = string.gsub(normed, "[ '-,]", "")

    -- d(nodeName .. "<" .. normed .. ">")

    return normed
end

local function l_GetFullNodeName(shortName)
    local fullName = ""
    shortName = shortName or ""
    fullName = shortName

    -- harborage hack (pt. 4/4)
    if shortName == "" then
        -- nothing to do
    elseif shortName == "harboragead" then
        fullName = "Harborage (AD)"
    elseif shortName == "harboragedc" then
        fullName = "Harborage (DC)"
    elseif shortName == "harborageep" then
        fullName = "Harborage (EP)"
    elseif shortName == "harborage" then
        local alliance = GetUnitAlliance("player")
        if alliance == ALLIANCE_ALDMERI_DOMINION then
            fullName = "Harborage (AD)"
        elseif alliance == ALLIANCE_DAGGERFALL_COVENANT then
            fullName = "Harborage (DC)"
        elseif alliance == ALLIANCE_EBONHEART_PACT then
            fullName = "Harborage (EP)"
        else
            fullName = "Harborage"
        end
    else
        local nodeIndex = Nodes.saveCache.nodeTable[shortName]
        if nodeIndex ~= nil then
            _, fullName = GetFastTravelNodeInfo(nodeIndex)
            fullName = fullName or shortName
        end
    end

    return fullName
end

local function l_LoadNodeTable(saveCache)
    local maxNodes = GetNumFastTravelNodes()
    local newVer = true

    if saveCache.nodeTable == nil then
        saveCache.nodeTable = { }
    end

    if saveCache.nodeACL == nil then
        saveCache.nodeACL = { }
    end

    if saveCache.nodeInfo == nil then
        saveCache.nodeInfo = { }
    end

    newVer = Traveller:IsTableOld(saveCache.nodeInfo)
    -- *** Temporary fix to allow testing
    -- newVer = true

    -- node table changes with almost every version so if we detect a new version we reload the table
    if newVer then
        local nodeName = ""
        local normName = ""
        local hCode = ""
        local ACName = ""
        local count = 0
        local harborage = 0
        local poitype = 0
 
        -- Traveller:Diag("Starting Load Node Table - Entries " .. tostring(maxNodes))
        Traveller:MarkTableOld(saveCache.nodeInfo)
        ZO_ClearTable(saveCache.nodeTable)
        ZO_ClearTable(saveCache.nodeACL)

        for nodeIndex = 1, maxNodes do
            _, nodeName, _, _, _, _, poiType = GetFastTravelNodeInfo(nodeIndex)
            nodeName = nodeName or ""

            -- certain types of node we ignore as it makes no sense to fast travel there
--[[            if (poiType ~= POI_TYPE_ACHIEVEMENT) and 
                (poiType ~= POI_TYPE_ACHIEVEMENT_COMPONENT) and 
                (poiType ~= POI_TYPE_OBJECTIVE) and 
                (nodeName ~= "") then
--]]
            if nodeName ~= "" then
                normName = l_NormaliseNodeName(nodeName)
                if normName ~= "" then

                    -- hack for three different nodes called "harborage" (pt. 1/4)
                    -- should be OK until ZOS reorders things
                    if normName == "harborage" then
                        if harborage == 0 then
                            hCode = "DC"
                        elseif harborage == 1 then
                            hCode = "AD"
                        elseif harborage == 2 then
                            hCode = "EP"
                        else
                            -- at least make sure they are different
                            hCode = tostring(nodeIndex)
                        end

                        normName = normName .. string.lower(hCode)
                        nodeName = nodeName .. " (" .. hCode .. ")"
                        harborage = harborage + 1
                    end
 
                    -- Add node to node table
                    Traveller:TableUniqueAdd(saveCache.nodeTable, normName, nodeIndex)

                    -- Add node to autocomplete table
                    ACName = string.lower(nodeName)
                    Traveller:TableUniqueAdd(saveCache.nodeACL, ACName, normName)

                    -- increment entry count
                    count = count + 1
                end
            end
        end

        -- harborage hack (pt. 2/4) :-(
        -- saveCache.nodeTable["harborage"] = {index = 0, name = "Harborage"}
        saveCache.nodeTable["harborage"] = 0
        count = count + 1

        -- done
        Traveller:MarkTableUpdated(saveCache.nodeInfo)
        Traveller:Diag("Nodes added " .. tostring(count), 70)
        -- Traveller:Diag("Ended Load Node Table")
    end
end

-- ==========================================================================================
--
--  External Interface
--

function Nodes:Initialise(saveCache)
    Nodes.saveCache = saveCache

    l_LoadNodeTable(Nodes.saveCache)
end

function Nodes:Goto(targetName)
    local nodeIndex = 0
    local name = ""
    local nodeOk = true
    local known = false
    local linkedCollectibleIsLocked = false
    
    name = l_NormaliseNodeName(targetName)
    name = name or ""

    if name == "" then
        Traveller:Diag("Node name is empty - " .. targetName)
        nodeOk = false

    -- harborage hack (pt. 3/4)
    elseif name == "harborage" then
        local alliance = GetUnitAlliance("player")
        if alliance == ALLIANCE_ALDMERI_DOMINION then
            name = "harboragead"
        elseif alliance == ALLIANCE_DAGGERFALL_COVENANT then
            name = "harboragedc"
        elseif alliance == ALLIANCE_EBONHEART_PACT then
            name = "harborageep"
        end
    end

    if nodeOk then
        nodeIndex = Nodes.saveCache.nodeTable[name]
        nodeOk = (nodeIndex ~= nil)
        if not nodeOk then
            Traveller:Diag("Unknown Node - " .. targetName)
        end
    end

    if nodeOk then
        nodeOk = (nodeIndex > 0)
        if not nodeOk then
            Traveller:Diag("Node entry is invalid - " .. targetName)
        end
    end

    if nodeOk then
        known, _, _, _, _, _, _, _, linkedCollectibleIsLocked = GetFastTravelNodeInfo(nodeIndex)

        if (known == nil) or (linkedCollectibleIsLocked == nil) then
            Traveller:Diag("Node info is invalid - " .. targetName)
            nodeOk = false
        end
    end

    if nodeOk and linkedCollectibleIsLocked then
        local collectibleId = 0

        Traveller:Diag("Node requires collectible - " .. targetName)
        collectibleId = GetFastTravelNodeLinkedCollectibleId(nodeIndex)
        Traveller:CollectibleDesc(collectibleId)

        nodeOk = false
    end
 
    if nodeOk and not known then
        Traveller:Diag("This character has not discovered this node yet - " .. targetName)
        nodeOk = false
    end

    if nodeOk then
        local fullName = l_GetFullNodeName(name)
        Traveller:Diag("Travelling to " .. fullName, 30)
        Gotos:SingleJump(G_JUMP_NODE, nil, nil, nodeIndex)
    end
end

function Nodes:GotoAC(target)
    local normName = Utils:ACLookup(Nodes.saveCache.nodeACL, target)

    if normName ~= "" then
        self:Goto(normName)
    else
        Traveller:Diag("No autocompletion found for " .. target)
    end
end

function Nodes:List()
    local fullName = ""
    local workTab = Tab:Start()

    Tab:Title(workTab, "Node List")

    Tab:ColumnHeaders(workTab, "Full Name", "Short Name")

    for akey, avalue in pairs(Nodes.saveCache.nodeTable) do

        fullName = l_GetFullNodeName(akey)

        Tab:AddRow(workTab, fullName, akey)
    end

    Tab:PrintTab(workTab)
end