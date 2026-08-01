-----------------------------------------------------------
-- Author: SpringPeace2575 | Version: 0.9.0
-- ItemInfo library (SpringPeace Framework)
-----------------------------------------------------------

SPFLibItemInfo = SPFLibItemInfo or {}

function SPFLibItemInfo.BuildDerivedItemInfo(itemLink)
    local info = {}

    if not itemLink or itemLink == "" then
        return info
    end

    -- info.name = GetItemLinkName(itemLink)
    info.itemId = GetItemLinkItemId(itemLink)

    local itemType, specializedItemType = GetItemLinkItemType(itemLink)
    info.itemType = itemType
    info.specializedItemType = specializedItemType

    if GetItemLinkTraitInfo then
        local traitType = GetItemLinkTraitInfo(itemLink)
        info.traitType = traitType
        if traitType and traitType ~= ITEM_TRAIT_TYPE_NONE and GetString then
            info.traitName = GetString("SI_ITEMTRAITTYPE", traitType)
        end
    end

    if GetItemLinkWeaponType then
        local weaponType = GetItemLinkWeaponType(itemLink)
        info.weaponType = weaponType
        if weaponType and weaponType ~= WEAPONTYPE_NONE and GetString then
            info.weaponTypeName = GetString("SI_WEAPONTYPE", weaponType)
        end
    end

    if GetItemLinkArmorType then
        local armorType = GetItemLinkArmorType(itemLink)
        info.armorType = armorType
        if armorType and armorType ~= ARMORTYPE_NONE and GetString then
            info.armorTypeName = GetString("SI_ARMORTYPE", armorType)
        end
    end

    if GetItemLinkEquipType then
        local equipType = GetItemLinkEquipType(itemLink)
        info.equipType = equipType
        if equipType and equipType ~= EQUIP_TYPE_INVALID and GetString then
            info.equipTypeName = GetString("SI_EQUIPTYPE", equipType)
        end
    end

    if GetItemLinkRequiredLevel then
        info.requiredLevel = GetItemLinkRequiredLevel(itemLink)
    end

    if GetItemLinkRequiredChampionPoints then
        info.requiredChampionPoints = GetItemLinkRequiredChampionPoints(itemLink)
    end

    if GetItemLinkDisplayQuality then
        info.displayQuality = GetItemLinkDisplayQuality(itemLink)
    end

    info.enchantId = GetItemLinkFinalEnchantId(itemLink)
    info.enchantCategory = GetEnchantSearchCategoryType(info.enchantId)

    if GetItemLinkEnchantInfo then
        local _, enchantHeader, enchantDescription = GetItemLinkEnchantInfo(itemLink)
        info.enchantHeader = enchantHeader
        info.enchantDescription = enchantDescription
        -- info.enchantingRuneClassification = GetItemLinkEnchantingRuneClassification(itemLink)
    end

    return info
end

function SPFLibItemInfo.BuildExtraItemDataLines(itemData)
    local lines = {}
    if type(itemData) ~= "table" then
        return lines
    end

    local excluded = {
        --itemLink = true,
        --name = true, -- this is with possile formatting markup, ZO_TradingHouse_GetItemDataFormattedName(itemData) needed to get formattedName
        --sellerName = true,
        --purchasePrice = true,
        --purchasePricePerUnit = true,
        --stackCount = true,
        iconFile = true,
        icon = true,
        -- displayQuality = true,
        -- quality = true,
        currencyType = true,
        -- formattedName = true,
        --itemUniqueId = true, -- this I could use for better management (checking, cleaning, etc.)
        slotIndex = true,
        timeRemaining = true,
    }

    local keys = {}
    for key, value in pairs(itemData) do
        if not excluded[key] and type(value) ~= "table" and type(value) ~= "function" and type(value) ~= "userdata" then
            keys[#keys + 1] = key
        end
    end
    table.sort(keys, function(a, b)
        return tostring(a) < tostring(b)
    end)

    for _, key in ipairs(keys) do
        lines[#lines + 1] = string.format("itemData.%s: %s", SPFLibUtils.SafeText(key), SPFLibUtils.SafeText(itemData[key]))
    end

    
    local seen = {}
    local derived = SPFLibItemInfo.BuildDerivedItemInfo(itemData.itemLink)
    for k, v in pairs(derived) do
        if type(v) ~= "table" and not seen[k] then
            lines[#lines + 1] = tostring(k) .. ": " .. tostring(v)
        end
    end


    return lines
end

function SPFLibItemInfo.BuildExtendedDebugLines(itemData)
    local lines = {}
    local seen = {}

    --[[ if itemData then
        for k, v in pairs(itemData) do
            if type(v) ~= "table" then
                lines[#lines + 1] = tostring(k) .. ": " .. tostring(v)
                seen[k] = true
            end
        end
    end ]]

    local derived = SPFLibItemInfo.BuildDerivedItemInfo(itemData.itemLink)
    for k, v in pairs(derived) do
        if type(v) ~= "table" and not seen[k] then
            lines[#lines + 1] = tostring(k) .. ": " .. tostring(v)
        end
    end

    table.sort(lines)
    return lines
end

function SPFLibItemInfo.FilterItemData(itemData)
    -- TODO: currently unused
    local excluded = {
        --itemLink = true,
        name = true, -- this is with possile formatting markup, ZO_TradingHouse_GetItemDataFormattedName(itemData) needed to get formattedName
        --sellerName = true,
        --purchasePrice = true,
        --purchasePricePerUnit = true,
        --stackCount = true,
        iconFile = true,
        --icon = true,
        displayQuality = true,
        quality = true,
        currencyType = true,
        formattedName = true,
        --itemUniqueId = true, -- this I could use for better management (checking, cleaning, etc.)
        slotIndex = true,
        timeRemaining = true,
    }

    local itemDataFiltered = {}

--[[     for key, value in pairs(itemData) do
        if not excluded[key] and type(value) ~= "table" and type(value) ~= "function" and type(value) ~= "userdata" then
            itemDataFiltered[key] = value
        end
    end ]]
    for key, value in pairs(itemData) do
        if not excluded[key] then
            if type(value) ~= "table" and type(value) ~= "function" and type(value) ~= "userdata" then
                itemDataFiltered[key] = value
            else
                d("GSW ItemData unknown key: "..key)
            end
        end
    end
    return itemDataFiltered
end

function SPFLibItemInfo.IsLearnableCategory(itemLink)
    -- TODO: currently unused
    local itemType, specializedItemType = GetItemLinkItemType(itemLink)

    if itemType == ITEMTYPE_RECIPE then
        return true
    end

    if itemType == ITEMTYPE_RACIAL_STYLE_MOTIF then
        return true
    end

    -- lore/book-like collectables
    if IsItemLinkBookPartOfCollection and IsItemLinkBookPartOfCollection(itemLink) then
        return true
    end

    -- set collection piece
    if IsItemLinkSetCollectionPiece and IsItemLinkSetCollectionPiece(itemLink) then
        return true
    end

    return false
end
