local ArcanumGuildHall = _G["ArcanumGuildHall"]
local UI = ArcanumGuildHallTeleportUI
local Teleport = ArcanumGuildHall.Teleport

local PLAYER_BUILD_DELAY_MS = 5
local PLAYER_BUILD_BUDGET_MS = 4

local beginPlayerBuild

Teleport.ZoneDatabase = Teleport.ZoneDatabase or {
    [1436] = { nodeIndex = 550, category = Teleport.CATEGORY.ARENA, name = "Infinite Archive" },
    [677] = { nodeIndex = 250, category = Teleport.CATEGORY.ARENA, name = "Maelstrom Arena" },
    [1227] = { nodeIndex = 457, category = Teleport.CATEGORY.ARENA, name = "Vateshran Hollows" },
    [635] = { nodeIndex = 270, category = Teleport.CATEGORY.ARENA, name = "Dragonstar Arena" },
    [1082] = { nodeIndex = 378, category = Teleport.CATEGORY.ARENA, name = "Blackrose Prison" },

    [636] = { nodeIndex = 230, category = Teleport.CATEGORY.TRIAL, name = "Hel Ra Citadel", abbreviation = "HRC" },
    [638] = { nodeIndex = 231, category = Teleport.CATEGORY.TRIAL, name = "Aetherian Archive", abbreviation = "AA" },
    [639] = { nodeIndex = 232, category = Teleport.CATEGORY.TRIAL, name = "Sanctum Ophidia", abbreviation = "SO" },
    [725] = { nodeIndex = 258, category = Teleport.CATEGORY.TRIAL, name = "Maw of Lorkhaj", abbreviation = "MoL" },
    [975] = { nodeIndex = 331, category = Teleport.CATEGORY.TRIAL, name = "Halls of Fabrication", abbreviation = "HoF" },
    [1000] = { nodeIndex = 346, category = Teleport.CATEGORY.TRIAL, name = "Asylum Sanctorium", abbreviation = "AS" },
    [1051] = { nodeIndex = 364, category = Teleport.CATEGORY.TRIAL, name = "Cloudrest", abbreviation = "CR" },
    [1121] = { nodeIndex = 399, category = Teleport.CATEGORY.TRIAL, name = "Sunspire", abbreviation = "SS" },
    [1196] = { nodeIndex = 434, category = Teleport.CATEGORY.TRIAL, name = "Kyne's Aegis", abbreviation = "KA" },
    [1263] = { nodeIndex = 468, category = Teleport.CATEGORY.TRIAL, name = "Rockgrove", abbreviation = "RG" },
    [1344] = { nodeIndex = 488, category = Teleport.CATEGORY.TRIAL, name = "Dreadsail Reef", abbreviation = "DSR" },
    [1427] = { nodeIndex = 534, category = Teleport.CATEGORY.TRIAL, name = "Sanity's Edge", abbreviation = "SE" },
    [1478] = { nodeIndex = 568, category = Teleport.CATEGORY.TRIAL, name = "Lucent Citadel", abbreviation = "LC" },
    [1548] = { nodeIndex = 589, category = Teleport.CATEGORY.TRIAL, name = "Ossein Cage", abbreviation = "OC" },

    [11] = { nodeIndex = 184, category = Teleport.CATEGORY.DUNGEON, name = "Vaults of Madness" },
    [22] = { nodeIndex = 196, category = Teleport.CATEGORY.DUNGEON, name = "Volenfell" },
    [31] = { nodeIndex = 185, category = Teleport.CATEGORY.DUNGEON, name = "Selene's Web" },
    [38] = { nodeIndex = 186, category = Teleport.CATEGORY.DUNGEON, name = "Blackheart Haven" },
    [63] = { nodeIndex = 198, category = Teleport.CATEGORY.DUNGEON, name = "Darkshade Caverns I" },
    [64] = { nodeIndex = 187, category = Teleport.CATEGORY.DUNGEON, name = "Blessed Crucible" },
    [126] = { nodeIndex = 191, category = Teleport.CATEGORY.DUNGEON, name = "Elden Hollow I" },
    [130] = { nodeIndex = 190, category = Teleport.CATEGORY.DUNGEON, name = "Crypt of Hearts I" },
    [131] = { nodeIndex = 188, category = Teleport.CATEGORY.DUNGEON, name = "Tempest Island" },
    [144] = { nodeIndex = 193, category = Teleport.CATEGORY.DUNGEON, name = "Spindleclutch I" },
    [146] = { nodeIndex = 189, category = Teleport.CATEGORY.DUNGEON, name = "Wayrest Sewers I" },
    [148] = { nodeIndex = 192, category = Teleport.CATEGORY.DUNGEON, name = "Arx Corinium" },
    [176] = { nodeIndex = 197, category = Teleport.CATEGORY.DUNGEON, name = "City of Ash I" },
    [283] = { nodeIndex = 98, category = Teleport.CATEGORY.DUNGEON, name = "Fungal Grotto I" },
    [380] = { nodeIndex = 194, category = Teleport.CATEGORY.DUNGEON, name = "The Banished Cells I" },
    [449] = { nodeIndex = 195, category = Teleport.CATEGORY.DUNGEON, name = "Direfrost Keep" },
    [930] = { nodeIndex = 264, category = Teleport.CATEGORY.DUNGEON, name = "Darkshade Caverns II" },
    [931] = { nodeIndex = 265, category = Teleport.CATEGORY.DUNGEON, name = "Elden Hollow II" },
    [932] = { nodeIndex = 269, category = Teleport.CATEGORY.DUNGEON, name = "Crypt of Hearts II" },
    [933] = { nodeIndex = 263, category = Teleport.CATEGORY.DUNGEON, name = "Wayrest Sewers II" },
    [934] = { nodeIndex = 266, category = Teleport.CATEGORY.DUNGEON, name = "Fungal Grotto II" },
    [935] = { nodeIndex = 262, category = Teleport.CATEGORY.DUNGEON, name = "The Banished Cells II" },
    [936] = { nodeIndex = 267, category = Teleport.CATEGORY.DUNGEON, name = "Spindleclutch II" },
    [681] = { nodeIndex = 268, category = Teleport.CATEGORY.DUNGEON, name = "City of Ash II" },

    [678] = { nodeIndex = 236, category = Teleport.CATEGORY.DUNGEON, name = "Imperial City Prison" },
    [688] = { nodeIndex = 247, category = Teleport.CATEGORY.DUNGEON, name = "White-Gold Tower" },
    [843] = { nodeIndex = 260, category = Teleport.CATEGORY.DUNGEON, name = "Ruins of Mazzatun" },
    [848] = { nodeIndex = 261, category = Teleport.CATEGORY.DUNGEON, name = "Cradle of Shadows" },
    [973] = { nodeIndex = 326, category = Teleport.CATEGORY.DUNGEON, name = "Bloodroot Forge" },
    [974] = { nodeIndex = 332, category = Teleport.CATEGORY.DUNGEON, name = "Falkreath Hold" },
    [1009] = { nodeIndex = 341, category = Teleport.CATEGORY.DUNGEON, name = "Fang Lair" },
    [1010] = { nodeIndex = 363, category = Teleport.CATEGORY.DUNGEON, name = "Scalecaller Peak" },
    [1052] = { nodeIndex = 371, category = Teleport.CATEGORY.DUNGEON, name = "Moon Hunter Keep" },
    [1055] = { nodeIndex = 370, category = Teleport.CATEGORY.DUNGEON, name = "March of Sacrifices" },
    [1080] = { nodeIndex = 389, category = Teleport.CATEGORY.DUNGEON, name = "Frostvault" },
    [1081] = { nodeIndex = 390, category = Teleport.CATEGORY.DUNGEON, name = "Depths of Malatar" },
    [1122] = { nodeIndex = 391, category = Teleport.CATEGORY.DUNGEON, name = "Moongrave Fane" },
    [1123] = { nodeIndex = 398, category = Teleport.CATEGORY.DUNGEON, name = "Lair of Maarselok" },
    [1152] = { nodeIndex = 424, category = Teleport.CATEGORY.DUNGEON, name = "Icereach" },
    [1153] = { nodeIndex = 425, category = Teleport.CATEGORY.DUNGEON, name = "Unhallowed Grave" },
    [1197] = { nodeIndex = 435, category = Teleport.CATEGORY.DUNGEON, name = "Stone Garden" },
    [1201] = { nodeIndex = 436, category = Teleport.CATEGORY.DUNGEON, name = "Castle Thorn" },
    [1228] = { nodeIndex = 437, category = Teleport.CATEGORY.DUNGEON, name = "Black Drake Villa" },
    [1229] = { nodeIndex = 454, category = Teleport.CATEGORY.DUNGEON, name = "The Cauldron" },
    [1267] = { nodeIndex = 470, category = Teleport.CATEGORY.DUNGEON, name = "Red Petal Bastion" },
    [1268] = { nodeIndex = 469, category = Teleport.CATEGORY.DUNGEON, name = "The Dread Cellar" },
    [1301] = { nodeIndex = 497, category = Teleport.CATEGORY.DUNGEON, name = "Coral Aerie" },
    [1302] = { nodeIndex = 498, category = Teleport.CATEGORY.DUNGEON, name = "Shipwright's Regret" },
    [1360] = { nodeIndex = 520, category = Teleport.CATEGORY.DUNGEON, name = "Earthen Root Enclave" },
    [1361] = { nodeIndex = 521, category = Teleport.CATEGORY.DUNGEON, name = "Graven Deep" },
    [1389] = { nodeIndex = 531, category = Teleport.CATEGORY.DUNGEON, name = "Bal Sunnar" },
    [1390] = { nodeIndex = 532, category = Teleport.CATEGORY.DUNGEON, name = "Scrivener's Hall" },
    [1470] = { nodeIndex = 556, category = Teleport.CATEGORY.DUNGEON, name = "Oathsworn Pit" },
    [1471] = { nodeIndex = 565, category = Teleport.CATEGORY.DUNGEON, name = "Bedlam Veil" },
    [1496] = { nodeIndex = 581, category = Teleport.CATEGORY.DUNGEON, name = "Exiled Redoubt" },
    [1497] = { nodeIndex = 582, category = Teleport.CATEGORY.DUNGEON, name = "Lep Seclusa" },
    [1551] = { nodeIndex = 606, category = Teleport.CATEGORY.DUNGEON, name = "Naj-Caldeesh" },
    [1552] = { nodeIndex = 605, category = Teleport.CATEGORY.DUNGEON, name = "Black Gem Foundry" },
}

Teleport.ZoneRegistry = Teleport.ZoneRegistry or {
    [181] = { hidden = true },
    [584] = { hidden = true },
    [551] = { hidden = true },
    [643] = { hidden = true },
    [509] = { hidden = true },
    [511] = { hidden = true },
    [510] = { hidden = true },
    [508] = { hidden = true },
    [513] = { hidden = true },
    [512] = { hidden = true },
    [514] = { hidden = true },
    [517] = { hidden = true },
    [518] = { hidden = true },
}

local function isWindowOpen()
    return ArcanumGuildHallTeleportWindow and not ArcanumGuildHallTeleportWindow:IsHidden()
end

local function isNetworkTab()
    return UI.activeTab == "network"
end

local function refreshDetails()
    if UI.initialized then
        UI.TeleportDetails.RefreshDetails(UI)
    end
end

local function showLoading(text)
    local label = ArcanumGuildHallTeleportWindow_LoadingLabel
    if not label then
        return
    end

    label:SetText(text or "")
    label:SetHidden(not isNetworkTab())
    refreshDetails()
end

local function hideLoading()
    local label = ArcanumGuildHallTeleportWindow_LoadingLabel
    if not label then
        return
    end

    label:SetHidden(true)
    refreshDetails()
end

local function addTrialAlias(targetTable, sourceName, abbreviation)
    if not abbreviation or abbreviation == "" then
        return
    end

    local cleanName = Teleport.CleanText(sourceName or "")
    if cleanName == "" then
        return
    end

    local aliases = {
        cleanName,
        Teleport.CleanTrialDisplayName(cleanName),
        Teleport.CleanDisplayNameByCategory(cleanName, Teleport.CATEGORY.TRIAL),
        Teleport.CleanWayshrineDisplayName(cleanName, Teleport.CATEGORY.TRIAL),
    }

    for i = 1, #aliases do
        local alias = aliases[i]
        if alias ~= "" then
            targetTable[Teleport.NormalizeKey(alias)] = abbreviation
            targetTable[Teleport.NormalizeZoneMatchKey(alias)] = abbreviation
        end
    end
end

local function initZoneLookups()
    if UI.cache.zoneEntryByZoneId
            and UI.cache.zoneRegistryByZoneId
            and UI.cache.zoneIdByZoneKey
            and UI.cache.localizedNameByZoneId
            and UI.cache.categoryByNodeIndex
            and UI.cache.trialByNameKey
            and UI.cache.trialByZoneKey
            and UI.cache.trialByNodeIndex then
        return
    end

    UI.cache.zoneEntryByZoneId = {}
    UI.cache.zoneRegistryByZoneId = {}
    UI.cache.zoneIdByZoneKey = {}
    UI.cache.localizedNameByZoneId = {}
    UI.cache.categoryByNodeIndex = {}
    UI.cache.trialByNameKey = {}
    UI.cache.trialByZoneKey = {}
    UI.cache.trialByNodeIndex = {}
    UI.cache.zoneCategoryLookup = UI.cache.zoneCategoryLookup or {}

    for zoneId, registryEntry in pairs(Teleport.ZoneRegistry) do
        UI.cache.zoneRegistryByZoneId[zoneId] = registryEntry

        local localizedName = Teleport.CleanText(GetZoneNameById(zoneId) or "")
        if localizedName ~= "" then
            UI.cache.localizedNameByZoneId[zoneId] = localizedName
            UI.cache.zoneIdByZoneKey[Teleport.NormalizeZoneMatchKey(localizedName)] = zoneId
        end
    end

    for zoneId, entry in pairs(Teleport.ZoneDatabase) do
        UI.cache.zoneEntryByZoneId[zoneId] = entry
        UI.cache.categoryByNodeIndex[entry.nodeIndex] = entry.category

        local localizedName = Teleport.CleanText(GetZoneNameById(zoneId) or "")
        local configName = Teleport.CleanText(entry.name or "")

        if localizedName ~= "" then
            UI.cache.localizedNameByZoneId[zoneId] = localizedName
            UI.cache.zoneIdByZoneKey[Teleport.NormalizeZoneMatchKey(localizedName)] = zoneId
        elseif configName ~= "" then
            UI.cache.localizedNameByZoneId[zoneId] = configName
        end

        if configName ~= "" then
            UI.cache.zoneIdByZoneKey[Teleport.NormalizeZoneMatchKey(configName)] = zoneId
        end

        if entry.category == Teleport.CATEGORY.TRIAL and entry.abbreviation and entry.abbreviation ~= "" then
            UI.cache.trialByNodeIndex[entry.nodeIndex] = entry.abbreviation
            addTrialAlias(UI.cache.trialByNameKey, localizedName, entry.abbreviation)
            addTrialAlias(UI.cache.trialByNameKey, configName, entry.abbreviation)
            addTrialAlias(UI.cache.trialByZoneKey, localizedName, entry.abbreviation)
            addTrialAlias(UI.cache.trialByZoneKey, configName, entry.abbreviation)
        end
    end
end

local function isHiddenZone(zoneId)
    initZoneLookups()

    if not zoneId then
        return false
    end

    local entry = UI.cache.zoneRegistryByZoneId[zoneId]
    return entry and entry.hidden
end

local function buildHouseNameLookup()
    local names = {}

    local function addHouseName(name)
        local cleanName = Teleport.CleanText(name or "")
        if cleanName == "" then
            return
        end

        local zoneKey = Teleport.NormalizeZoneMatchKey(cleanName)
        if zoneKey ~= "" then
            names[zoneKey] = cleanName
        end
    end

    if ZO_COLLECTIBLE_DATA_MANAGER
            and ZO_COLLECTIBLE_DATA_MANAGER.GetAllCollectibleDataObjects
            and ZO_CollectibleCategoryData
            and ZO_CollectibleCategoryData.IsHousingCategory then

        local housingData = ZO_COLLECTIBLE_DATA_MANAGER:GetAllCollectibleDataObjects({
            ZO_CollectibleCategoryData.IsHousingCategory,
        })

        if type(housingData) == "table" then
            for i = 1, #housingData do
                local collectibleData = housingData[i]
                if collectibleData and collectibleData.GetName then
                    addHouseName(collectibleData:GetName())
                end
            end
        end
    end

    if COLLECTIONS_BOOK_SINGLETON and COLLECTIONS_BOOK_SINGLETON.GetOwnedHouses then
        local ownedHouses = COLLECTIONS_BOOK_SINGLETON:GetOwnedHouses()

        if ownedHouses then
            for key, houseEntry in pairs(ownedHouses) do
                local houseId = 0

                if type(houseEntry) == "table" then
                    houseId = houseEntry.houseId or houseEntry.id or 0
                elseif type(houseEntry) == "number" then
                    houseId = houseEntry
                elseif type(key) == "number" then
                    houseId = key
                end

                if houseId > 0 and GetCollectibleIdForHouse and GetCollectibleName then
                    local collectibleId = GetCollectibleIdForHouse(houseId) or 0
                    if collectibleId > 0 then
                        addHouseName(GetCollectibleName(collectibleId))
                    end
                end
            end
        end
    end

    return names
end

local function initHouseNodes()
    if not UI.cache.houseNodeNameByKey then
        Teleport.GetFastTravelNodes()
    end

    if not UI.cache.houseNameByKey then
        UI.cache.houseNameByKey = buildHouseNameLookup()
    end
end

local function refreshNodesIfOpen()
    Teleport.MarkNodeCacheDirty()

    if UI.initialized and isWindowOpen() then
        ArcanumGuildHall:RefreshTeleportWindow()
    end
end

function Teleport.MarkNodeCacheDirty()
    UI.cache.dirtyNodes = true
    UI.cache.nodes = nil
    UI.cache.knownWayshrines = nil
    UI.cache.houseEntries = nil
    UI.cache.unknownWayshrines = nil
    UI.cache.houseNodeNameByKey = nil
    UI.cache.houseNameByKey = nil
    UI.cache.zoneCategoryLookup = {}
end

function Teleport.CancelPlayerBuild()
    local state = UI.cache.playerBuildState
    if not state then
        return
    end

    state.cancelled = true
    UI.cache.playerBuildState = nil
    hideLoading()
end

function Teleport.MarkPlayerCacheDirty()
    UI.cache.dirtyPlayers = true
    UI.cache.playerTargets = nil

    local state = UI.cache.playerBuildState
    if state then
        state.pendingRebuild = true
    end
end

function Teleport.IsPlayerBuildRunning()
    return UI.cache.playerBuildState ~= nil
end

function Teleport.RegisterInvalidationEvents()
    if Teleport.eventsRegistered then
        return
    end

    Teleport.eventsRegistered = true

    EVENT_MANAGER:RegisterForEvent(Teleport.EVENT_NAMESPACE .. "_PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED, function()
        Teleport.MarkPlayerCacheDirty()

        if Teleport.pendingNodeRefreshAfterTravel then
            Teleport.pendingNodeRefreshAfterTravel = false
            refreshNodesIfOpen()
        end
    end)

    if EVENT_FAST_TRAVEL_NETWORK_UPDATED then
        EVENT_MANAGER:RegisterForEvent(Teleport.EVENT_NAMESPACE .. "_FAST_TRAVEL_NETWORK_UPDATED", EVENT_FAST_TRAVEL_NETWORK_UPDATED, function()
            refreshNodesIfOpen()
        end)
    end

    EVENT_MANAGER:RegisterForEvent(Teleport.EVENT_NAMESPACE .. "_GROUP_JOIN", EVENT_GROUP_MEMBER_JOINED, function()
        Teleport.MarkPlayerCacheDirty()
    end)

    EVENT_MANAGER:RegisterForEvent(Teleport.EVENT_NAMESPACE .. "_GROUP_LEFT", EVENT_GROUP_MEMBER_LEFT, function()
        Teleport.MarkPlayerCacheDirty()
    end)

    EVENT_MANAGER:RegisterForEvent(Teleport.EVENT_NAMESPACE .. "_FRIEND_STATUS", EVENT_FRIEND_PLAYER_STATUS_CHANGED, function()
        Teleport.MarkPlayerCacheDirty()
    end)

    EVENT_MANAGER:RegisterForEvent(Teleport.EVENT_NAMESPACE .. "_FRIEND_ADDED", EVENT_FRIEND_ADDED, function()
        Teleport.MarkPlayerCacheDirty()
    end)

    EVENT_MANAGER:RegisterForEvent(Teleport.EVENT_NAMESPACE .. "_FRIEND_REMOVED", EVENT_FRIEND_REMOVED, function()
        Teleport.MarkPlayerCacheDirty()
    end)

    EVENT_MANAGER:RegisterForEvent(Teleport.EVENT_NAMESPACE .. "_GUILD_STATUS", EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED, function()
        Teleport.MarkPlayerCacheDirty()
    end)

    EVENT_MANAGER:RegisterForEvent(Teleport.EVENT_NAMESPACE .. "_GUILD_ADDED", EVENT_GUILD_MEMBER_ADDED, function()
        Teleport.MarkPlayerCacheDirty()
    end)

    EVENT_MANAGER:RegisterForEvent(Teleport.EVENT_NAMESPACE .. "_GUILD_REMOVED", EVENT_GUILD_MEMBER_REMOVED, function()
        Teleport.MarkPlayerCacheDirty()
    end)
end

function Teleport.GetFastTravelNodes()
    if not UI.cache.dirtyNodes and UI.cache.nodes then
        return UI.cache.nodes
    end

    initZoneLookups()

    local nodes = {}
    local houseNodeNames = {}
    local numNodes = GetNumFastTravelNodes()

    for nodeIndex = 1, numNodes do
        local known, nodeName, _, _, _, _, poiType = GetFastTravelNodeInfo(nodeIndex)
        local cleanName = Teleport.CleanText(nodeName)

        if cleanName ~= "" then
            local zoneKey = Teleport.NormalizeZoneMatchKey(cleanName)
            local category = UI.cache.categoryByNodeIndex[nodeIndex]
            local houseId = 0

            if poiType == POI_TYPE_HOUSE then
                category = Teleport.CATEGORY.HOUSE
                houseNodeNames[zoneKey] = cleanName

                houseId = GetFastTravelNodeHouseId(nodeIndex) or 0
            elseif not category then
                local zoneId = UI.cache.zoneIdByZoneKey[zoneKey]
                local zoneEntry = zoneId and UI.cache.zoneEntryByZoneId[zoneId]
                category = zoneEntry and zoneEntry.category or Teleport.CATEGORY.ZONE
            end

            nodes[#nodes + 1] = {
                id = nodeIndex,
                known = known == true,
                name = cleanName,
                category = category,
                poiType = poiType,
                cost = Teleport.GetCostText(nodeIndex),
                houseId = houseId,
            }
        end
    end

    UI.cache.nodes = nodes
    UI.cache.houseNodeNameByKey = houseNodeNames
    UI.cache.dirtyNodes = false

    return nodes
end

function Teleport.GetZoneIdByName(zoneName)
    initZoneLookups()

    local zoneKey = Teleport.NormalizeZoneMatchKey(zoneName)
    if zoneKey == "" then
        return nil
    end

    return UI.cache.zoneIdByZoneKey[zoneKey]
end

function Teleport.GetCategoryByZoneId(zoneId)
    initZoneLookups()

    if not zoneId or zoneId <= 0 or isHiddenZone(zoneId) then
        return nil
    end

    local entry = UI.cache.zoneEntryByZoneId[zoneId]
    return entry and entry.category or nil
end

function Teleport.GetZoneCategory(zoneName)
    initZoneLookups()
    initHouseNodes()

    local zoneKey = Teleport.NormalizeZoneMatchKey(zoneName)
    if zoneKey == "" then
        return Teleport.CATEGORY.ZONE
    end

    local cachedCategory = UI.cache.zoneCategoryLookup[zoneKey]
    if cachedCategory ~= nil then
        return cachedCategory or nil
    end

    local zoneId = Teleport.GetZoneIdByName(zoneName)
    if zoneId and isHiddenZone(zoneId) then
        UI.cache.zoneCategoryLookup[zoneKey] = false
        return nil
    end

    if UI.cache.houseNodeNameByKey[zoneKey] or UI.cache.houseNameByKey[zoneKey] then
        UI.cache.zoneCategoryLookup[zoneKey] = Teleport.CATEGORY.HOUSE
        return Teleport.CATEGORY.HOUSE
    end

    if zoneId then
        local entry = UI.cache.zoneEntryByZoneId[zoneId]
        if entry then
            UI.cache.zoneCategoryLookup[zoneKey] = entry.category
            return entry.category
        end
    end

    UI.cache.zoneCategoryLookup[zoneKey] = Teleport.CATEGORY.ZONE
    return Teleport.CATEGORY.ZONE
end

function Teleport.GetTargetName(zoneName, zoneId)
    initZoneLookups()
    initHouseNodes()

    local zoneKey = Teleport.NormalizeZoneMatchKey(zoneName)
    if zoneKey ~= "" and UI.cache.houseNodeNameByKey[zoneKey] then
        return UI.cache.houseNodeNameByKey[zoneKey]
    end

    if zoneId and not isHiddenZone(zoneId) then
        local localizedName = UI.cache.localizedNameByZoneId[zoneId]
        if localizedName and localizedName ~= "" then
            return localizedName
        end
    end

    local resolvedZoneId = Teleport.GetZoneIdByName(zoneName)
    if resolvedZoneId and not isHiddenZone(resolvedZoneId) then
        local localizedName = UI.cache.localizedNameByZoneId[resolvedZoneId]
        if localizedName and localizedName ~= "" then
            return localizedName
        end
    end

    return Teleport.CleanText(zoneName)
end

function Teleport.GetNodeByZoneId(zoneId)
    initZoneLookups()

    if not zoneId or zoneId <= 0 then
        return nil
    end

    local entry = UI.cache.zoneEntryByZoneId[zoneId]
    if entry and entry.nodeIndex and entry.nodeIndex > 0 then
        return entry.nodeIndex
    end

    return nil
end

local function buildTeleportCallback(displayName, sourceType, zoneId, fallbackName)
    local category = Teleport.GetCategoryByZoneId(zoneId)
    local nodeIndex = Teleport.GetNodeByZoneId(zoneId)
    local targetName = Teleport.GetTargetName(fallbackName or "", zoneId)

    local function tryGroupJump()
        local groupSize = GetGroupSize()
        if groupSize <= 0 then
            return false
        end

        for i = 1, groupSize do
            local unitTag = GetGroupUnitTagByIndex(i)
            if unitTag and IsUnitOnline(unitTag) then
                local unitDisplayName = GetUnitDisplayName(unitTag)
                if Teleport.SameDisplayName(unitDisplayName, displayName) and CanJumpToGroupMember(unitTag) then
                    JumpToGroupMember(GetUnitName(unitTag))
                    return true
                end
            end
        end

        return false
    end

    local function tryFriendJump()
        if displayName and displayName ~= "" then
            JumpToFriend(displayName)
            return true
        end

        return false
    end

    local function tryGuildJump()
        if displayName and displayName ~= "" then
            JumpToGuildMember(displayName)
            return true
        end

        return false
    end

    local function tryNodeTeleport()
        if nodeIndex and nodeIndex > 0 then
            ArcanumGuildHall:CityTeleport({
                id = nodeIndex,
                name = targetName,
                category = category,
                zoneId = zoneId,
            })
            return true
        end

        return false
    end

    return function()
        if Teleport.CheckAvARestriction() then
            return
        end

        local isInstance = category == Teleport.CATEGORY.DUNGEON
                or category == Teleport.CATEGORY.TRIAL
                or category == Teleport.CATEGORY.ARENA

        local isGrouped = GetGroupSize() > 0

        if sourceType == "group" then
            if isGrouped and tryGroupJump() then
                return
            end

            if isInstance and tryNodeTeleport() then
                return
            end

            tryGroupJump()
            return
        end

        if isInstance then
            if isGrouped and sourceType == "friend" and tryFriendJump() then
                return
            end

            if isGrouped and sourceType == "guild" and tryGuildJump() then
                return
            end

            if tryNodeTeleport() then
                return
            end
        end

        if sourceType == "friend" then
            if tryFriendJump() then
                return
            end
        elseif sourceType == "guild" then
            if tryGuildJump() then
                return
            end
        end

        if isInstance then
            tryNodeTeleport()
        end
    end
end

function Teleport.GetKnownWayshrines()
    if not UI.cache.dirtyNodes and UI.cache.knownWayshrines then
        return UI.cache.knownWayshrines
    end

    local entries = {}
    local nodes = Teleport.GetFastTravelNodes()

    for i = 1, #nodes do
        local node = nodes[i]

        if node.known and node.category ~= Teleport.CATEGORY.HOUSE then
            local zoneId = Teleport.GetZoneIdByName(node.name)
            local displayName = Teleport.FormatTargetDisplayName(node.name, node.category, zoneId, node.id)

            entries[#entries + 1] = Teleport.CreateSearchEntry(
                    displayName,
                    "",
                    function()
                        ArcanumGuildHall:CityTeleport({
                            id = node.id,
                            name = node.name,
                            displayName = displayName,
                            category = node.category,
                            zoneId = zoneId,
                        })
                    end,
                    {
                        target = displayName,
                        displayName = "",
                        source = "",
                        zone = "",
                        cost = Teleport.GetCostText(node.id),
                        nodeId = node.id,
                        zoneId = zoneId or 0,
                        category = node.category,
                        wayshrine = displayName,
                    }
            )
        end
    end

    table.sort(entries, function(a, b)
        return a.details.searchTarget < b.details.searchTarget
    end)

    if #entries == 0 then
        entries[1] = Teleport.CreateDividerEntry(ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_EMPTY_ENTRIES"))
    end

    UI.cache.knownWayshrines = entries
    return entries
end

local function getHouseName(houseId, collectibleId)
    local resolvedCollectibleId = collectibleId or 0

    if resolvedCollectibleId <= 0 and houseId and houseId > 0 and GetCollectibleIdForHouse then
        resolvedCollectibleId = GetCollectibleIdForHouse(houseId) or 0
    end

    if resolvedCollectibleId > 0 and GetCollectibleName then
        local collectibleName = Teleport.CleanText(GetCollectibleName(resolvedCollectibleId) or "")
        if collectibleName ~= "" then
            return collectibleName
        end
    end

    return zo_strformat(
            ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_FALLBACK_HOUSE_NAME"),
            tostring(houseId or 0)
    )
end

local function getHousingData()
    if not ZO_COLLECTIBLE_DATA_MANAGER
            or not ZO_COLLECTIBLE_DATA_MANAGER.GetAllCollectibleDataObjects
            or not ZO_CollectibleCategoryData
            or not ZO_CollectibleCategoryData.IsHousingCategory then
        return nil
    end

    local housingData = ZO_COLLECTIBLE_DATA_MANAGER:GetAllCollectibleDataObjects({
        ZO_CollectibleCategoryData.IsHousingCategory,
    })

    if type(housingData) ~= "table" or #housingData == 0 then
        return nil
    end

    return housingData
end

local function getOwnedHouseIds()
    local ownedLookup = {}

    if not COLLECTIONS_BOOK_SINGLETON or not COLLECTIONS_BOOK_SINGLETON.GetOwnedHouses then
        return ownedLookup
    end

    local ownedHouses = COLLECTIONS_BOOK_SINGLETON:GetOwnedHouses()
    if not ownedHouses then
        return ownedLookup
    end

    for key, houseEntry in pairs(ownedHouses) do
        local houseId = 0

        if type(houseEntry) == "table" then
            houseId = houseEntry.houseId or houseEntry.id or 0
        elseif type(houseEntry) == "number" then
            houseId = houseEntry
        elseif type(key) == "number" then
            houseId = key
        end

        if houseId > 0 then
            ownedLookup[houseId] = true
        end
    end

    return ownedLookup
end

function Teleport.GetHouseEntries()
    if not UI.cache.dirtyNodes and UI.cache.houseEntries then
        return UI.cache.houseEntries
    end

    local entries = {}
    local ownedEntries = {}
    local unownedEntries = {}
    local primaryEntry = nil
    local primaryHouseId = Teleport.GetPrimaryHouseId()
    local ownedLookup = getOwnedHouseIds()
    local seenHouseIds = {}

    local housingData = getHousingData()
    local hasHousingData = housingData ~= nil

    if housingData then
        for i = 1, #housingData do
            local collectibleData = housingData[i]

            if collectibleData
                    and collectibleData.GetReferenceId
                    and collectibleData.GetId
                    and collectibleData.IsUnlocked then

                local houseId = collectibleData:GetReferenceId() or 0
                local collectibleId = collectibleData:GetId() or 0

                if houseId > 0 and not seenHouseIds[houseId] then
                    seenHouseIds[houseId] = true

                    local isOwned = ownedLookup[houseId] or collectibleData:IsUnlocked()
                    local houseName = getHouseName(houseId, collectibleId)
                    local isPrimary = isOwned and primaryHouseId > 0 and houseId == primaryHouseId
                    local callback

                    if isOwned then
                        if isPrimary then
                            callback = function()
                                return Teleport.TravelToPrimaryHouse(false, houseName)
                            end
                        else
                            callback = function()
                                return Teleport.TravelToKnownHouse(houseId, false, houseName)
                            end
                        end
                    else
                        callback = function()
                            return Teleport.PreviewUnownedHouse(houseId, houseName)
                        end
                    end

                    local entry = Teleport.CreateSearchEntry(
                            houseName,
                            "",
                            callback,
                            {
                                target = houseName,
                                displayName = "",
                                source = "",
                                zone = "",
                                cost = "",
                                category = Teleport.CATEGORY.HOUSE,
                                wayshrine = houseName,
                                houseId = houseId,
                                collectibleId = collectibleId,
                                isPrimaryHouse = isPrimary,
                                isOwnedHouse = isOwned,
                                isLocked = not isOwned,
                                isDimmed = not isOwned,
                                isPreviewHouse = not isOwned,
                            }
                    )

                    if isOwned then
                        if isPrimary then
                            primaryEntry = entry
                        else
                            ownedEntries[#ownedEntries + 1] = entry
                        end
                    else
                        unownedEntries[#unownedEntries + 1] = entry
                    end
                end
            end
        end
    end

    if not hasHousingData or (#ownedEntries == 0 and #unownedEntries == 0 and not primaryEntry) then
        for houseId in pairs(ownedLookup) do
            if houseId > 0 and not seenHouseIds[houseId] then
                seenHouseIds[houseId] = true

                local houseName = getHouseName(houseId, 0)
                local isPrimary = primaryHouseId > 0 and houseId == primaryHouseId
                local callback

                if isPrimary then
                    callback = function()
                        return Teleport.TravelToPrimaryHouse(false, houseName)
                    end
                else
                    callback = function()
                        return Teleport.TravelToKnownHouse(houseId, false, houseName)
                    end
                end

                local entry = Teleport.CreateSearchEntry(
                        houseName,
                        "",
                        callback,
                        {
                            target = houseName,
                            displayName = "",
                            source = "",
                            zone = "",
                            cost = "",
                            category = Teleport.CATEGORY.HOUSE,
                            wayshrine = houseName,
                            houseId = houseId,
                            collectibleId = 0,
                            isPrimaryHouse = isPrimary,
                            isOwnedHouse = true,
                            isLocked = false,
                            isDimmed = false,
                            isPreviewHouse = false,
                        }
                )

                if isPrimary then
                    primaryEntry = entry
                else
                    ownedEntries[#ownedEntries + 1] = entry
                end
            end
        end
    end

    table.sort(ownedEntries, function(a, b)
        return a.details.searchTarget < b.details.searchTarget
    end)

    table.sort(unownedEntries, function(a, b)
        return a.details.searchTarget < b.details.searchTarget
    end)

    if primaryEntry then
        entries[#entries + 1] = Teleport.CreateDividerEntry(
                ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_DIVIDER_PRIMARY_HOUSE")
        )
        entries[#entries + 1] = primaryEntry
    end

    if #ownedEntries > 0 then
        entries[#entries + 1] = Teleport.CreateDividerEntry(
                ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_DIVIDER_OWNED_HOUSES")
        )

        for i = 1, #ownedEntries do
            entries[#entries + 1] = ownedEntries[i]
        end
    end

    if #unownedEntries > 0 then
        entries[#entries + 1] = Teleport.CreateDividerEntry(
                ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_DIVIDER_UNOWNED_HOUSES")
        )

        for i = 1, #unownedEntries do
            entries[#entries + 1] = unownedEntries[i]
        end
    end

    if #entries == 0 then
        entries[1] = Teleport.CreateDividerEntry(
                ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_EMPTY_ENTRIES")
        )
    end

    UI.cache.houseEntries = entries
    return entries
end

function Teleport.GetUnknownWayshrines()
    if not UI.cache.dirtyNodes and UI.cache.unknownWayshrines then
        return UI.cache.unknownWayshrines
    end

    local entries = {}
    local nodes = Teleport.GetFastTravelNodes()
    local knownKeys = {}
    local unknownNodes = {}

    for i = 1, #nodes do
        local node = nodes[i]

        if node.category == Teleport.CATEGORY.HOUSE then
        elseif node.known then
            local zoneId = Teleport.GetZoneIdByName(node.name)
            local displayName = Teleport.FormatTargetDisplayName(node.name, node.category, zoneId, node.id)
            local key = Teleport.NormalizeKey(displayName)
            if key ~= "" then
                knownKeys[key] = true
            end
        else
            unknownNodes[#unknownNodes + 1] = node
        end
    end

    local seenUnknown = {}
    for i = 1, #unknownNodes do
        local node = unknownNodes[i]
        local zoneId = Teleport.GetZoneIdByName(node.name)
        local displayName = Teleport.FormatTargetDisplayName(node.name, node.category, zoneId, node.id)
        local key = Teleport.NormalizeKey(displayName)

        if key ~= "" and not knownKeys[key] and not seenUnknown[key] then
            seenUnknown[key] = true

            entries[#entries + 1] = Teleport.CreateSearchEntry(
                    displayName,
                    "",
                    nil,
                    {
                        target = displayName,
                        displayName = "",
                        source = "",
                        zone = "",
                        cost = "",
                        nodeId = node.id,
                        zoneId = zoneId or 0,
                        category = node.category,
                        wayshrine = displayName,
                        isUnknown = true,
                    }
            )
        end
    end

    table.sort(entries, function(a, b)
        return a.details.searchTarget < b.details.searchTarget
    end)

    if #entries == 0 then
        entries[1] = Teleport.CreateDividerEntry(ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_EMPTY_ENTRIES"))
    end

    UI.cache.unknownWayshrines = entries
    return entries
end

local function newPlayerBuild()
    return {
        cancelled = false,
        entries = {},
        seenTargets = {},
        seenAccounts = {},
        playerDisplayName = Teleport.GetPlayerDisplayName(),
        headers = {
            group = false,
            friend = false,
            guild = false,
        },
        sourceClean = {
            group  = ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_SOURCE_GROUP"),
            friend = ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_SOURCE_FRIENDS"),
            guild  = ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_SOURCE_GUILD"),
        },
        guildIndex = 1,
        memberIndex = 1,
        pendingRebuild = false,
        lastUiRefreshMs = 0,
    }
end

local function addHeader(state, sourceType, label)
    if state.headers[sourceType] then
        return
    end

    state.entries[#state.entries + 1] = Teleport.CreateDividerEntry(label)
    state.headers[sourceType] = true
end

local function addPlayerEntry(state, sourceLabel, sourceType, displayName, zoneName, zoneId)
    if not displayName or displayName == "" or not zoneName or zoneName == "" then
        return
    end

    if Teleport.SameDisplayName(displayName, state.playerDisplayName) then
        return
    end

    local resolvedZoneId = zoneId or Teleport.GetZoneIdByName(zoneName)
    if resolvedZoneId and isHiddenZone(resolvedZoneId) then
        return
    end

    local category = Teleport.GetCategoryByZoneId(resolvedZoneId) or Teleport.GetZoneCategory(zoneName)
    if not category or category == Teleport.CATEGORY.HOUSE then
        return
    end

    local nodeIndex = Teleport.GetNodeByZoneId(resolvedZoneId)
    local targetName = Teleport.GetTargetName(zoneName, resolvedZoneId)
    targetName = Teleport.FormatTargetDisplayName(targetName, category, resolvedZoneId, nodeIndex)

    local targetKey = Teleport.NormalizeKey(targetName)
    if state.seenTargets[targetKey] then
        return
    end

    state.seenTargets[targetKey] = true
    addHeader(state, sourceType, sourceLabel)

    state.entries[#state.entries + 1] = Teleport.CreateSearchEntry(
            targetName,
            "",
            buildTeleportCallback(displayName, sourceType, resolvedZoneId, zoneName),
            {
                target = targetName,
                displayName = displayName or "-",
                source = state.sourceClean[sourceType] or sourceLabel:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", ""),
                zone = Teleport.CleanDisplayNameByCategory(zoneName, category),
                zoneId = resolvedZoneId or 0,
                cost = "",
                category = category,
                wayshrine = targetName,
            }
    )
end

local function addGroupEntries(state)
    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)

        if unitTag and IsUnitOnline(unitTag) then
            local displayName = GetUnitDisplayName(unitTag)
            local zoneName = Teleport.CleanText(GetUnitZone(unitTag))
            local zoneId = nil

            if GetUnitZoneIndex and GetZoneId then
                local zoneIndex = GetUnitZoneIndex(unitTag)
                if zoneIndex and zoneIndex > 0 then
                    zoneId = GetZoneId(zoneIndex)
                end
            end

            addPlayerEntry(
                    state,
                    "|c66CCFF" .. ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_SOURCE_GROUP") .. "|r",
                    "group",
                    displayName,
                    zoneName,
                    zoneId
            )
        end
    end
end

local function addFriendEntries(state)
    for friendIndex = 1, GetNumFriends() do
        local displayName, _, status = GetFriendInfo(friendIndex)
        local hasCharacter, _, zoneName = GetFriendCharacterInfo(friendIndex)
        zoneName = Teleport.CleanText(zoneName)

        local accountKey = zo_strlower(displayName or "")
        if accountKey ~= "" and not state.seenAccounts[accountKey] then
            state.seenAccounts[accountKey] = true

            if status ~= PLAYER_STATUS_OFFLINE and hasCharacter and zoneName ~= "" then
                addPlayerEntry(
                        state,
                        "|c99FF99" .. ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_SOURCE_FRIENDS") .. "|r",
                        "friend",
                        displayName,
                        zoneName,
                        nil
                )
            end
        end
    end
end

local function finishPlayerBuild(state)
    if state.cancelled then
        return
    end

    if #state.entries == 0 then
        state.entries[#state.entries + 1] = Teleport.CreateDividerEntry(
                ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_EMPTY_ENTRIES")
        )
    end

    UI.cache.playerTargets = state.entries
    UI.cache.dirtyPlayers = false
    UI.cache.playerBuildState = nil

    hideLoading()

    if isNetworkTab() and isWindowOpen() then
        ArcanumGuildHall:RefreshTeleportWindow()
    end

    if state.pendingRebuild and isNetworkTab() and isWindowOpen() then
        UI.cache.dirtyPlayers = true

        zo_callLater(function()
            if not UI.cache.playerBuildState then
                beginPlayerBuild()
            end
        end, PLAYER_BUILD_DELAY_MS)
    end
end

local function scanGuilds()
    local state = UI.cache.playerBuildState
    if not state or state.cancelled then
        return
    end

    local guildCount = GetNumGuilds()
    local startMs = GetGameTimeMilliseconds()

    while state.guildIndex <= guildCount do
        local guildId = GetGuildId(state.guildIndex)
        local memberCount = GetNumGuildMembers(guildId)

        showLoading(zo_strformat(
                ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_LOADING_GUILD_MEMBERS"),
                tostring(state.guildIndex),
                tostring(guildCount)
        ))

        while state.memberIndex <= memberCount do
            local displayName, _, _, status = GetGuildMemberInfo(guildId, state.memberIndex)
            local hasCharacter, _, zoneName = GetGuildMemberCharacterInfo(guildId, state.memberIndex)
            zoneName = Teleport.CleanText(zoneName)

            local accountKey = zo_strlower(displayName or "")
            if accountKey ~= "" and not state.seenAccounts[accountKey] then
                state.seenAccounts[accountKey] = true

                if status ~= PLAYER_STATUS_OFFLINE and hasCharacter and zoneName ~= "" then
                    addPlayerEntry(
                            state,
                            "|cFFCC66" .. ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_SOURCE_GUILD") .. "|r",
                            "guild",
                            displayName,
                            zoneName,
                            nil
                    )
                end
            end

            state.memberIndex = state.memberIndex + 1

            if GetGameTimeMilliseconds() - startMs >= PLAYER_BUILD_BUDGET_MS then
                local nowMs = GetGameTimeMilliseconds()

                if nowMs - state.lastUiRefreshMs >= 150 then
                    state.lastUiRefreshMs = nowMs
                    UI.cache.playerTargets = state.entries

                    if isNetworkTab() and isWindowOpen() then
                        ArcanumGuildHall:RefreshTeleportWindow()
                    end
                end

                zo_callLater(scanGuilds, PLAYER_BUILD_DELAY_MS)
                return
            end
        end

        state.guildIndex = state.guildIndex + 1
        state.memberIndex = 1
    end

    finishPlayerBuild(state)
end

beginPlayerBuild = function()
    if UI.cache.playerBuildState then
        return
    end

    local state = newPlayerBuild()
    UI.cache.playerBuildState = state

    showLoading(ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_LOADING_PLAYERS"))

    addGroupEntries(state)
    addFriendEntries(state)

    UI.cache.playerTargets = state.entries

    if isNetworkTab() and isWindowOpen() then
        ArcanumGuildHall:RefreshTeleportWindow()
    end

    zo_callLater(scanGuilds, PLAYER_BUILD_DELAY_MS)
end

function Teleport.GetPlayerTargets()
    if not UI.cache.dirtyPlayers and UI.cache.playerTargets then
        return UI.cache.playerTargets
    end

    if UI.cache.playerBuildState then
        return UI.cache.playerBuildState.entries
    end

    beginPlayerBuild()
    return UI.cache.playerTargets or {}
end

function Teleport.GetZoneEntry(zoneId)
    initZoneLookups()
    return UI.cache.zoneEntryByZoneId[zoneId]
end

function Teleport.GetTrialAbbreviationByNameKey(nameKey)
    initZoneLookups()
    return UI.cache.trialByNameKey[nameKey]
end

function Teleport.GetTrialAbbreviationByZoneKey(zoneKey)
    initZoneLookups()
    return UI.cache.trialByZoneKey[zoneKey]
end

function Teleport.GetTrialAbbreviationByNodeIndex(nodeIndex)
    initZoneLookups()
    return UI.cache.trialByNodeIndex[nodeIndex]
end