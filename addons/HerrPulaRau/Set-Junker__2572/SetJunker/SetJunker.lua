SetJunker.name = "SetJunker"
SetJunker.version = 1
SetJunker.config = { junkSets = {}, individualItemsOff = {}, junkIntricatesOff = 0, raritySettings = { glyphs = 4, standardItems = 4, jewels = 3 }, junkDuplicates = 0, preferredArmorTrait = ITEM_TRAIT_TYPE_ARMOR_DIVINES, preferredWeaponTrait = ITEM_TRAIT_TYPE_WEAPON_PRECISE}
SetJunker.currentItemLink = nil

function SetJunker.OnAddOnLoaded(eventCode, addonName)
    if (addonName ~= SetJunker.name) then return end

    EVENT_MANAGER:UnregisterForEvent(SetJunker.name, EVENT_ADD_ON_LOADED)
    SetJunker.config = ZO_SavedVars:NewAccountWide('config', SetJunker.version, nil, SetJunker.config)
    if (SetJunker.config.customConfig ~= 1) then
        SetJunker.config.junkSets = SetJunker.defaults.junkSets;
    end

    ZO_CreateStringId("SI_BINDING_NAME_SETJUNKER", GetString(SI_ITEMBROWSER_TITLE))

    local allianceStyles = {
        [ALLIANCE_NONE] = ITEMSTYLE_NONE,
        [ALLIANCE_ALDMERI_DOMINION] = ITEMSTYLE_ALLIANCE_ALDMERI,
        [ALLIANCE_EBONHEART_PACT] = ITEMSTYLE_ALLIANCE_EBONHEART,
        [ALLIANCE_DAGGERFALL_COVENANT] = ITEMSTYLE_ALLIANCE_DAGGERFALL,
    }

    ItemBrowser.allianceStyle = allianceStyles[GetUnitAlliance("player")]

    -- For multi-style items, such as crafted items, just pick a style matching the player's race.
    ItemBrowser.multiStyle = GetUnitRaceId("player")
    if (ItemBrowser.multiStyle == 10) then ItemBrowser.multiStyle = ITEMSTYLE_RACIAL_IMPERIAL end

    SLASH_COMMANDS["/setjunker"] = ItemBrowser.Toggle
end

function SetJunker.checkItems()
    SetJunker.checkBagItems(BAG_BACKPACK)
    SetJunker.checkBagItems(BAG_BANK)
    SetJunker.checkBagItems(BAG_SUBSCRIBER_BANK)
end

function SetJunker.checkForJunks()
    SetJunker.checkItems()
    SetJunker.checkForDuplicateItems()
end

function SetJunker.checkBagItems( bag )
    local nrSlots = GetBagSize(bag)

    for i = 1, nrSlots do
        local itemLink = GetItemLink(bag, i)

        local junkCondition = SetJunker.computeJunkCondition(itemLink)
        local setCondition = SetJunker.computeSetCondition(itemLink)
        if (junkCondition and setCondition) then
            SetItemIsJunk(bag, i, true)
        end
    end
end

function SetJunker.checkForDuplicateItems()
    if (SetJunker.config.junkDuplicates == 0) then
        return false
    end

    local items = {armors = {}, weapons = {}}
    local nrInventorySlots = GetBagSize(BAG_BACKPACK)
    local nrBankSlots = GetBagSize(BAG_BANK)
    local nrSubscriberBankSlots = GetBagSize(BAG_SUBSCRIBER_BANK)
    for i = 1, nrInventorySlots do
        items = SetJunker.addAndMarkItemToDuplicateCheckList(BAG_BACKPACK, i, items)
    end

    for i = 1, nrBankSlots do
        items = SetJunker.addAndMarkItemToDuplicateCheckList(BAG_BANK, i, items)
    end

    for i = 1, nrSubscriberBankSlots do
        items = SetJunker.addAndMarkItemToDuplicateCheckList(BAG_SUBSCRIBER_BANK, i, items)
    end

    return true
end

function SetJunker.addAndMarkItemToDuplicateCheckList( bagType, slotId, itemList )
    local itemLink = GetItemLink(bagType, slotId)
    local hasSet, setName, numBonuses, numEquipped, maxEquipped, setId = GetItemLinkSetInfo(itemLink)
    local itemType = GetItemLinkItemType(itemLink)
    local isArmor = (itemType == ITEMTYPE_ARMOR)
    local isWeapon = (itemType == ITEMTYPE_WEAPON)
    local baseType = ''
    local preciseItemType = ''

    if (isWeapon or isArmor) then
        if (isWeapon) then
            baseType = 'weapons'
            preciseItemType = GetItemLinkWeaponType(itemLink)
        end

        if (isArmor) then
            baseType = 'armors'
            preciseItemType = GetItemLinkEquipType(itemLink)
        end

        if (not itemList[baseType][setId] or not itemList[baseType][setId][preciseItemType]) then
            if (not itemList[baseType][setId]) then
                itemList[baseType][setId] = {}
            end
            if (not IsItemJunk(bagType, slotId)) then
                itemList[baseType][setId][preciseItemType] = { itemLink = itemLink, bagType = bagType, slotId = slotId, isLocked = IsItemPlayerLocked(bagType, slotId) }
            end
        else
            if (isArmor and preciseItemType == EQUIP_TYPE_RING) then
                if (not IsItemPlayerLocked(bagType, slotId)) then
                    d('Duplicate unlocked ring found, ' .. itemLink .. ', will not junk because two are required')
                end
            else
                local currentItemData = itemList[baseType][setId][preciseItemType]
                if (currentItemData.isLocked) then
                    if (not IsItemPlayerLocked(bagType, slotId)) then
                        if (SetJunker.computeJunkCondition(itemLink)) then
                            SetItemIsJunk(bagType, slotId, true)
                        end
                    end
                else
                    if (IsItemPlayerLocked(bagType, slotId)) then
                        if (SetJunker.computeJunkCondition(currentItemData.itemLink)) then
                            SetItemIsJunk(currentItemData.bagType, currentItemData.slotId, true)
                        end
                        itemList[baseType][setId][preciseItemType] = { itemLink = itemLink, bagType = bagType, slotId = slotId, isLocked = IsItemPlayerLocked(bagType, slotId) }
                    else
                        if (GetItemLinkRequiredChampionPoints(currentItemData.itemLink) < GetItemLinkRequiredChampionPoints(itemLink) or GetItemLinkRequiredLevel(currentItemData.itemLink) < GetItemLinkRequiredLevel(itemLink)) then
                            SetItemIsJunk(currentItemData.bagType, currentItemData.slotId, true)
                            itemList[baseType][setId][preciseItemType] = { itemLink = itemLink, bagType = bagType, slotId = slotId, isLocked = IsItemPlayerLocked(bagType, slotId) }
                        else
                            if (GetItemLinkRequiredChampionPoints(currentItemData.itemLink) > GetItemLinkRequiredChampionPoints(itemLink) or GetItemLinkRequiredLevel(currentItemData.itemLink) > GetItemLinkRequiredLevel(itemLink)) then
                                SetItemIsJunk(bagType, slotId, true)
                            else
                                if (GetItemLinkQuality(itemLink) > GetItemLinkQuality(currentItemData.itemLink)) then
                                    if (SetJunker.computeJunkCondition(currentItemData.itemLink)) then
                                        SetItemIsJunk(currentItemData.bagType, currentItemData.slotId, true)
                                    end
                                    itemList[baseType][setId][preciseItemType] = { itemLink = itemLink, bagType = bagType, slotId = slotId, isLocked = IsItemPlayerLocked(bagType, slotId) }
                                else
                                    if (GetItemLinkQuality(itemLink) < GetItemLinkQuality(currentItemData.itemLink)) then
                                        if (SetJunker.computeJunkCondition(itemLink)) then
                                            SetItemIsJunk(bagType, slotId, true)
                                        end
                                    else
                                        local traitType, traitDescription = GetItemLinkTraitInfo(itemLink)
                                        if (isArmor or (isWeapon and preciseItemType == WEAPONTYPE_SHIELD)) then
                                            if (traitType == SetJunker.config.preferredArmorTrait) then
                                                if (SetJunker.computeJunkCondition(currentItemData.itemLink)) then
                                                    SetItemIsJunk(currentItemData.bagType, currentItemData.slotId, true)
                                                end
                                                itemList[baseType][setId][preciseItemType] = { itemLink = itemLink, bagType = bagType, slotId = slotId, isLocked = IsItemPlayerLocked(bagType, slotId) }
                                            else
                                                if (SetJunker.computeJunkCondition(itemLink)) then
                                                    SetItemIsJunk(bagType, slotId, true)
                                                end
                                            end
                                        end
                                        if (isWeapon) then
                                            if (traitType == SetJunker.config.preferredWeaponTrait) then
                                                if (SetJunker.computeJunkCondition(currentItemData.itemLink)) then
                                                    SetItemIsJunk(currentItemData.bagType, currentItemData.slotId, true)
                                                end
                                                itemList[baseType][setId][preciseItemType] = { itemLink = itemLink, bagType = bagType, slotId = slotId, isLocked = IsItemPlayerLocked(bagType, slotId) }
                                            else
                                                if (SetJunker.computeJunkCondition(itemLink)) then
                                                    SetItemIsJunk(bagType, slotId, true)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return itemList
end

function SetJunker.computeSetCondition(itemLink)
    local hasSet, setName, numBonuses, numEquipped, maxEquipped, setId = GetItemLinkSetInfo(itemLink)
    local itemType = GetItemLinkItemType(itemLink)
    local setCondition = false

    if (hasSet and SetJunker.config.junkSets[setId]) then
        if (SetJunker.config.individualItemsOff[setId]) then
            setCondition = SetJunker.computeIndividualItemSetCondition(itemType, itemLink, setId)
        else
            setCondition = SetJunker.config.junkSets[setId]
        end
    end

    local isWeaponOrArmor = (itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_WEAPON)
    local isOtherTrashableItem = (itemType == ITEMTYPE_TRASH or itemType == ITEMTYPE_GLYPH_ARMOR or itemType == ITEMTYPE_GLYPH_JEWELRY or itemType == ITEMTYPE_GLYPH_WEAPON)

    return (hasSet and setCondition) or (not hasSet and isWeaponOrArmor) or isOtherTrashableItem
end

function SetJunker.computeIndividualItemSetCondition(itemType, itemLink, setId)
    if (itemType == ITEMTYPE_ARMOR) then
        local preciseItemType = GetItemLinkEquipType(itemLink)
        if (not SetJunker.config.individualItemsOff[setId].armors or not SetJunker.config.individualItemsOff[setId].armors[preciseItemType]) then
            return true
        end
    end

    if (itemType == ITEMTYPE_WEAPON) then
        local preciseItemType = GetItemLinkWeaponType(itemLink)
        if (not SetJunker.config.individualItemsOff[setId].weapons or not SetJunker.config.individualItemsOff[setId].weapons[preciseItemType]) then
            return true
        end
    end

    return false
end

function SetJunker.computeRarityCondition(itemLink)

    local itemRarity = GetItemLinkQuality(itemLink)
    local itemType = GetItemLinkItemType(itemLink)

    if (itemType == ITEMTYPE_TRASH) then
        return true
    end

    if (itemType == ITEMTYPE_GLYPH_ARMOR or itemType == ITEMTYPE_GLYPH_JEWELRY or itemType == ITEMTYPE_GLYPH_WEAPON) then
        return itemRarity <= SetJunker.config.raritySettings['glyphs']
    end

    if (itemType == ITEMTYPE_WEAPON) then
        return itemRarity <= SetJunker.config.raritySettings['standardItems']
    end

    if (itemType == ITEMTYPE_ARMOR) then
        local preciseItemType = GetItemLinkEquipType(itemLink)
        if (preciseItemType == EQUIP_TYPE_NECK or preciseItemType == EQUIP_TYPE_RING) then
            return itemRarity <= SetJunker.config.raritySettings['jewels']
        else
            return itemRarity <= SetJunker.config.raritySettings['standardItems']
        end
    end

    return false
end

function SetJunker.computeTraitCondition(itemLink)
    if (not (SetJunker.config.junkIntricatesOff == 1)) then
        return true
    end

    local itemType = GetItemLinkItemType(itemLink)
    local isArmor = (itemType == ITEMTYPE_ARMOR)
    local isWeapon = (itemType == ITEMTYPE_WEAPON)

    local traitType, traitDescription = GetItemLinkTraitInfo(itemLink)

    if (isWeapon and traitType == ITEM_TRAIT_TYPE_WEAPON_INTRICATE) then
        return false
    end

    local preciseItemType = GetItemLinkEquipType(itemLink)

    if (isArmor and (not (preciseItemType == EQUIP_TYPE_NECK or preciseItemType == EQUIP_TYPE_RING)) and traitType == ITEM_TRAIT_TYPE_ARMOR_INTRICATE) then
        return false
    end

    if (isArmor and (preciseItemType == EQUIP_TYPE_NECK or preciseItemType == EQUIP_TYPE_RING) and traitType == ITEM_TRAIT_TYPE_JEWELRY_INTRICATE) then
        return false
    end

    return true
end


function SetJunker.computeJunkCondition(itemLink)
    local rarityCondition = SetJunker.computeRarityCondition(itemLink)
    local traitCondition = SetJunker.computeTraitCondition(itemLink)

    if (rarityCondition and traitCondition) then
        return true
    end

    return false
end

EVENT_MANAGER:RegisterForEvent(SetJunker.name, EVENT_OPEN_STORE, SetJunker.checkForJunks);
EVENT_MANAGER:RegisterForEvent(SetJunker.name, EVENT_OPEN_BANK, SetJunker.checkForJunks);
EVENT_MANAGER:RegisterForEvent(ItemBrowser.name, EVENT_ADD_ON_LOADED, SetJunker.OnAddOnLoaded)
