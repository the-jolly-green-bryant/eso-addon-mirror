UniversalTracker = UniversalTracker or {}

local equips = {
    EQUIP_SLOT_HEAD,
    EQUIP_SLOT_CHEST,
    EQUIP_SLOT_SHOULDERS,
    EQUIP_SLOT_HAND,
    EQUIP_SLOT_WAIST,
    EQUIP_SLOT_LEGS,
    EQUIP_SLOT_FEET,
    EQUIP_SLOT_MAIN_HAND,
    EQUIP_SLOT_OFF_HAND,
    EQUIP_SLOT_BACKUP_MAIN,
    EQUIP_SLOT_BACKUP_OFF,
    EQUIP_SLOT_NECK,
    EQUIP_SLOT_RING1,
    EQUIP_SLOT_RING2,
}

local weaponTypes = {
    [WEAPONTYPE_AXE] = 1,
    [WEAPONTYPE_BOW] = 2,
    [WEAPONTYPE_DAGGER] = 1,
    [WEAPONTYPE_FIRE_STAFF] = 2,
    [WEAPONTYPE_FROST_STAFF] = 2,
    [WEAPONTYPE_HAMMER] = 1,
    [WEAPONTYPE_NONE] = 1, --armor
    [WEAPONTYPE_SHIELD] = 1,
    [WEAPONTYPE_SWORD] = 1,
    [WEAPONTYPE_HEALING_STAFF] = 2,
    [WEAPONTYPE_LIGHTNING_STAFF] = 2,
    [WEAPONTYPE_TWO_HANDED_AXE] = 2,
    [WEAPONTYPE_TWO_HANDED_HAMMER] = 2,
    [WEAPONTYPE_TWO_HANDED_SWORD] = 2,
}

function UniversalTracker.isWearingFullSet(queriedSetID)
    if not queriedSetID then return false end

    local count = 0
    local maxRequired = -1

    for k, equip in pairs(equips) do

        local itemLink = GetItemLink(BAG_WORN, equip)
        local _, _, _, _, maxEquipped, setID, _ = GetItemLinkSetInfo(itemLink)

        if setID == queriedSetID then
            if maxRequired == -1 then maxRequired = maxEquipped end
            count = count + weaponTypes[GetItemLinkWeaponType(itemLink)]
        end
    end

    if count == maxRequired then return true end
    return false
end

function UniversalTracker.printEquips()
    local trackedSets = {[0] = true}
    for k, equip in pairs(equips) do
        local itemLink = GetItemLink(BAG_WORN, equip)
        local _, setName, _, _, _, setID, _ = GetItemLinkSetInfo(itemLink)

        if not trackedSets[setID] then
            trackedSets[setID] = true
            UniversalTracker.chat:Print(zo_strformat(SI_ITEM_SET_NAME_FORMATTER, setName).." has ID "..setID)
        end
    end
end

local function UpdateSetTrackers()
    for k, v in pairs(UniversalTracker.savedVariables.trackerList) do
        if tonumber(v.requiredSetID) then
            if UniversalTracker.isWearingFullSet(tonumber(v.requiredSetID)) then 
                UniversalTracker.InitSingleDisplay(v)
            else
                UniversalTracker.ReleaseSingleDisplay(v)
            end
        end
    end
    
    for k, v in pairs(UniversalTracker.characterSavedVariables.trackerList) do
        if tonumber(v.requiredSetID) then
            if UniversalTracker.isWearingFullSet(tonumber(v.requiredSetID)) then 
                UniversalTracker.InitSingleDisplay(v)
            else
                UniversalTracker.ReleaseSingleDisplay(v)
            end
        end
    end
end


EVENT_MANAGER:RegisterForEvent(UniversalTracker.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, UpdateSetTrackers)
EVENT_MANAGER:AddFilterForEvent(UniversalTracker.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
EVENT_MANAGER:AddFilterForEvent(UniversalTracker.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
EVENT_MANAGER:RegisterForEvent(UniversalTracker.name, EVENT_ARMORY_BUILD_RESTORE_RESPONSE, UpdateSetTrackers)
