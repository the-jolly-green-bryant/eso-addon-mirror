--[[
    Survey Map Teleport
    Right-click an opened survey or treasure map in inventory and choose "Call to Zone"
    to fast-travel via Beam Me Up (BMU.sc_porting / BMU.getDataMapInfo).
]]

local ADDON_NAME = "SurveyMapTeleport"

local string_lower = string.lower
local string_find = string.find
local string_sub = string.sub

ZO_CreateStringId("SI_SMT_CALL_TO_ZONE", "Call to Zone")
ZO_CreateStringId("SI_SMT_BMU_MISSING", "Survey Map Teleport requires Beam Me Up to be enabled.")
ZO_CreateStringId("SI_SMT_ZONE_UNKNOWN", "Survey Map Teleport: Could not determine the zone for this map.")
ZO_CreateStringId("SI_SMT_NO_TRAVEL", "Survey Map Teleport: No travel option for this zone (no players, no house there, or no wayshrine discovered).")

local surveyMarkerLower
local treasureMarkerLower

local function refreshLocalizedMarkers()
    if BMU and BMU.SI then
        surveyMarkerLower = string_lower(BMU.SI.get("SI_CONSTANT_SURVEY_MAP"))
        treasureMarkerLower = string_lower(BMU.SI.get("SI_CONSTANT_TREASURE_MAP"))
    else
        surveyMarkerLower = "survey:"
        treasureMarkerLower = "treasure map"
    end
end

local function formatItemName(itemName)
    if BMU and BMU.formatName then
        return BMU.formatName(itemName, false)
    end
    return ZO_CachedStrFormat("< >", itemName)
end

-- Opened maps are trophy survey/treasure items, not sealed stackable containers.
local function isOpenedSurveyOrTreasureMap(bagId, slotIndex)
    local _, specializedItemType = GetItemType(bagId, slotIndex)
    if specializedItemType == SPECIALIZED_ITEMTYPE_CONTAINER_STACKABLE then
        return false
    end
    if specializedItemType == SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT
        or specializedItemType == SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP then
        return true
    end

    refreshLocalizedMarkers()
    local itemNameLower = string_lower(GetItemName(bagId, slotIndex))
    if string_find(itemNameLower, surveyMarkerLower, 1, true) then
        return true
    end
    if string_find(itemNameLower, treasureMarkerLower, 1, true) then
        return true
    end
    return false
end

local function extractZoneNameFromMapItemName(itemName)
    local name = formatItemName(itemName)
    if not name or name == "" then
        return nil
    end

    local colonPos = string_find(name, ": ", 1, true)
    if colonPos then
        return zo_strtrim(string_sub(name, colonPos + 2))
    end

    local commaPos = string_find(name, ", ", 1, true)
    if commaPos then
        return zo_strtrim(string_sub(name, commaPos + 2))
    end

    return nil
end

local function resolveZoneId(bagId, slotIndex)
    if not BMU or not BMU.getDataMapInfo then
        return nil
    end

    local itemId = GetItemId(bagId, slotIndex)
    local _, zoneId, isContainer = BMU.getDataMapInfo(itemId)
    if isContainer then
        return nil
    end
    if zoneId then
        return zoneId
    end

    if not BMU.getZoneIdFromZoneName then
        return nil
    end

    local zoneName = extractZoneNameFromMapItemName(GetItemName(bagId, slotIndex))
    if zoneName then
        return BMU.getZoneIdFromZoneName(zoneName)
    end
    return nil
end

local function normalizeZoneId(zoneId)
    return tonumber(zoneId) or zoneId
end

local function zoneIdsMatch(zoneIdA, zoneIdB)
    zoneIdA = normalizeZoneId(zoneIdA)
    zoneIdB = normalizeZoneId(zoneIdB)
    if not zoneIdA or not zoneIdB then
        return false
    end
    if zoneIdA == zoneIdB then
        return true
    end
    if BMU.getParentZoneId then
        local parentA = normalizeZoneId(BMU.getParentZoneId(zoneIdA))
        local parentB = normalizeZoneId(BMU.getParentZoneId(zoneIdB))
        return parentA == zoneIdB or parentB == zoneIdA or (parentA and parentB and parentA == parentB)
    end
    return false
end

local function houseMatchesZone(record, zoneId, parentZoneId)
    if not record then
        return false
    end
    return zoneIdsMatch(record.zoneId, zoneId)
        or zoneIdsMatch(record.zoneId, parentZoneId)
        or zoneIdsMatch(record.parentZoneId, zoneId)
        or zoneIdsMatch(record.parentZoneId, parentZoneId)
end

local function getPreferredHouseIdForZone(zoneId, parentZoneId)
    if not BMU.getZoneSpecificHouse then
        return nil
    end
    local preferred = BMU.getZoneSpecificHouse(zoneId) or BMU.getZoneSpecificHouse(parentZoneId)
    if preferred and preferred > 0 then
        return preferred
    end
    local zoneHouses = BMU.savedVarsServ and BMU.savedVarsServ.zoneSpecificHouses
    if not zoneHouses then
        return nil
    end
    for mappedZoneId, houseId in pairs(zoneHouses) do
        if zoneIdsMatch(mappedZoneId, zoneId) or zoneIdsMatch(mappedZoneId, parentZoneId) then
            if houseId and houseId > 0 then
                return houseId
            end
        end
    end
    return nil
end

local function getOwnedHousesList()
    if BMU.IsNotKeyboard and BMU.IsNotKeyboard() then
        return ZO_COLLECTIBLE_DATA_MANAGER:GetAllCollectibleDataObjects(
            { ZO_CollectibleCategoryData.IsHousingCategory },
            { ZO_CollectibleData.IsUnlocked }
        )
    end
    if COLLECTIONS_BOOK_SINGLETON then
        return COLLECTIONS_BOOK_SINGLETON:GetOwnedHouses()
    end
    return {}
end

local function getHouseIdFromEntry(house, isGamepad)
    if isGamepad then
        return house:GetReferenceId()
    end
    return house.houseId
end

local function findOwnedHouseInZone(zoneId, parentZoneId)
    local parentZoneName = BMU.formatName(GetZoneNameById(parentZoneId), false)
    local preferredHouseId = getPreferredHouseIdForZone(zoneId, parentZoneId)
    local fallbackHouseId
    local isGamepad = BMU.IsNotKeyboard and BMU.IsNotKeyboard()

    for _, house in pairs(getOwnedHousesList()) do
        local houseId = getHouseIdFromEntry(house, isGamepad)
        if houseId and houseId > 0 then
            local houseZoneId = GetHouseZoneId(houseId)
            if zoneIdsMatch(houseZoneId, zoneId) or zoneIdsMatch(houseZoneId, parentZoneId) then
                if preferredHouseId and houseId == preferredHouseId then
                    return houseId, parentZoneName
                end
                if not fallbackHouseId then
                    fallbackHouseId = houseId
                end
            end
        end
    end

    if preferredHouseId and preferredHouseId > 0 then
        return preferredHouseId, parentZoneName
    end
    return fallbackHouseId, parentZoneName
end

local function resolveHouseForZone(zoneId, resultTable)
    local parentZoneId = normalizeZoneId(BMU.getParentZoneId(zoneId))
    zoneId = normalizeZoneId(zoneId)
    local parentZoneName = BMU.formatName(GetZoneNameById(parentZoneId), false)
    local preferredHouseId = getPreferredHouseIdForZone(zoneId, parentZoneId)

    if preferredHouseId and preferredHouseId > 0 then
        return preferredHouseId, parentZoneName
    end

    if resultTable then
        for _, record in pairs(resultTable) do
            if record and record.isOwnHouse and record.houseId and record.houseId > 0 then
                if houseMatchesZone(record, zoneId, parentZoneId) then
                    return record.houseId, record.parentZoneName or parentZoneName
                end
            end
        end
    end

    return findOwnedHouseInZone(zoneId, parentZoneId)
end

local function jumpToHouseOutside(houseId, zoneId)
    if BMU.portToOwnHouseWithZonePreference then
        -- Preferred house for zone first, then houseId as fallback (never primary residence).
        BMU.portToOwnHouseWithZonePreference(true, zoneId, true, houseId)
    elseif BMU.portToOwnHouse then
        local parentZoneId = BMU.getParentZoneId(zoneId)
        local parentZoneName = BMU.formatName(GetZoneNameById(parentZoneId), false)
        BMU.portToOwnHouse(false, houseId, true, parentZoneName)
    end
end

local function tryPortToHouseInZone(zoneId, resultTable)
    if not BMU.portToOwnHouse and not BMU.portToOwnHouseWithZonePreference then
        return false
    end
    if not CanLeaveCurrentLocationViaTeleport() then
        return false
    end

    local houseId = resolveHouseForZone(zoneId, resultTable)
    if not houseId or houseId == 0 then
        return false
    end

    -- Inventory context menus are insecure; defer like Beam Me Up does for UseItem.
    zo_callLater(function()
        if not CanLeaveCurrentLocationViaTeleport() then
            return
        end
        jumpToHouseOutside(houseId, zoneId)
    end, 250)

    return true
end

local function reportNoTravel()
    if BMU.printToChat and BMU.SI then
        BMU.printToChat(BMU.SI.get("SI_TELE_CHAT_NO_FAST_TRAVEL"))
    else
        CHAT_ROUTER:AddSystemMessage(GetString(SI_SMT_NO_TRAVEL))
    end
end

-- Player jump first; then own house in zone; then wayshrine recall for overland zones.
local function portToZone(zoneId)
    zoneId = normalizeZoneId(zoneId)
    local resultTable = BMU.createTable({
        index = BMU.indexListZoneHidden,
        fZoneId = zoneId,
        dontDisplay = true,
        noOwnHouses = false,
    })

    for _, entry in pairs(resultTable) do
        if entry and entry.displayName and entry.displayName ~= "" and not entry.zoneWithoutPlayer then
            BMU.PortalToPlayer(
                entry.displayName,
                entry.sourceIndexLeading,
                entry.zoneName,
                entry.zoneId,
                entry.category,
                true,
                true,
                true
            )
            return
        end
    end

    if tryPortToHouseInZone(zoneId, resultTable) then
        return
    end

    if BMU.isZoneOverlandZone and BMU.isZoneOverlandZone(zoneId) and BMU.PortalToZone then
        BMU.PortalToZone(zoneId)
        return
    end

    reportNoTravel()
end

local function callToZone(bagId, slotIndex)
    if not BMU or not BMU.createTable or not BMU.PortalToPlayer or not BMU.portToOwnHouse then
        CHAT_ROUTER:AddSystemMessage(GetString(SI_SMT_BMU_MISSING))
        return
    end

    local zoneId = resolveZoneId(bagId, slotIndex)
    if not zoneId then
        CHAT_ROUTER:AddSystemMessage(GetString(SI_SMT_ZONE_UNKNOWN))
        return
    end

    portToZone(zoneId)
end

local function onInventoryContextMenu(inventoryControl)
    if not BMU or not BMU.getDataMapInfo or not BMU.createTable then
        return
    end

    local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventoryControl)
    if not bagId or slotIndex == nil then
        return
    end

    if not isOpenedSurveyOrTreasureMap(bagId, slotIndex) then
        return
    end

    if not resolveZoneId(bagId, slotIndex) then
        return
    end

    AddMenuItem(
        GetString(SI_SMT_CALL_TO_ZONE),
        function()
            callToZone(bagId, slotIndex)
        end,
        "inventory-item"
    )
end

local function initialize()
    refreshLocalizedMarkers()

    local lib = LibCustomMenu
    if not lib or not lib.RegisterContextMenu then
        CHAT_ROUTER:AddSystemMessage("Survey Map Teleport requires LibCustomMenu.")
        return
    end

    lib:RegisterContextMenu(onInventoryContextMenu, lib.CATEGORY_INVENTORY_ITEM)
end

local function onAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    initialize()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, onAddOnLoaded)
