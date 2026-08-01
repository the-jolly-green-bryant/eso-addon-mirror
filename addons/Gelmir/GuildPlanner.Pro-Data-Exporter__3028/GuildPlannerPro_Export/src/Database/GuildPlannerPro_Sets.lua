GuildPlannerPro_Sets = {}

function GuildPlannerPro_Sets:CheckGivenBag(bagId, sets)
    local bagSize = GetBagSize(bagId)
    for bagSlotIndex = 1, bagSize do
        local itemLink = GetItemLink(bagId, bagSlotIndex, LINK_STYLE_BRACKETS)
        local itemId = GetItemLinkItemId(itemLink)
        local hasSet, _, _, _, _, setId = GetItemLinkSetInfo(itemLink, false)
        if hasSet then
            if not sets[setId] then
                sets[setId] = {}
                sets[setId]["SetId"] = setId
                sets[setId]["Items"] = {}
            end
            if not sets[setId]["Items"][itemId] then
                sets[setId]["Items"][itemId] = {}
            end
            local item = GuildPlannerPro_Sets:GetItemInfoForGivenBagAndSlot(bagId, bagSlotIndex, itemId, itemLink)
            table.insert(sets[setId]["Items"][itemId], item)
        end
    end
end

function GuildPlannerPro_Sets:GetItemInfoForGivenBagAndSlot(bagId, bagSlotIndex, itemId, itemLink)
    local traitType, traitDescription = GetItemLinkTraitInfo(itemLink)
    local _, enchantHeader, enchantDescription = GetItemLinkEnchantInfo(itemLink)

    return {
        Id = itemId,
        Name = zo_strformat(GetString(SI_TOOLTIP_ITEM_NAME), GetItemName(bagId, bagSlotIndex)),
        Link = itemLink,
        Icon = GetItemLinkIcon(itemLink),
        EquipType = GetItemLinkEquipType(itemLink),
        ArmorType = GetItemLinkArmorType(itemLink),
        WeaponType = GetItemLinkWeaponType(itemLink),
        ItemLevel = GetItemLevel(bagId, bagSlotIndex),
        ItemRequiredLevel = GetItemLinkRequiredLevel(itemLink),
        ItemRequiredCp = GetItemLinkRequiredChampionPoints(itemLink),
        ArmorRating = GetItemLinkArmorRating(itemLink, false),
        WeaponPower = GetItemLinkWeaponPower(itemLink),
        DisplayQuality = GetItemDisplayQuality(bagId, bagSlotIndex),
        ItemTrait = traitType,
        ItemTraitDescription = traitDescription,
        ItemTraitInformation = GetItemTraitInformation(bagId, bagSlotIndex),
        ItemTraitCategory = GetItemLinkTraitCategory(itemLink),
        ItemEnchantType = GetEnchantSearchCategoryType(GetItemLinkFinalEnchantId(itemLink)),
        ItemEnchantHeader = enchantHeader,
        ItemEnchantDescription = enchantDescription,
        BindType = GetItemLinkBindType(itemLink),
        IsBound = IsItemBound(bagId, bagSlotIndex),
        WillBeBoundInSecs = GetItemBoPTimeRemainingSeconds(bagId, bagSlotIndex),
        FlavorText = GetItemLinkFlavorText(itemLink),
        TimeStamp = GetTimeStamp(),
    }
end

function GuildPlannerPro_Sets:ExportItemSetCollectionSet(setId)
    local data = {}

    local set = ITEM_SET_COLLECTIONS_DATA_MANAGER.itemSetCollections[setId]
    if set:HasAnyUnlockedPieces() then
        local unlockedPieces = {}
        for _, piece in ipairs(set.pieces) do
            if piece:IsUnlocked() then
                table.insert(unlockedPieces, piece:GetId())
            end
        end
        table.insert(data, {
            SetId = setId,
            NumUnlocked = set:GetNumUnlockedPieces(),
            UnlockedPieces = unlockedPieces,
            ReconstructionCost = set:GetReconstructionCurrencyOptionCost(CURT_TRANSMUTE_CRYSTALS),
            ReconstructionCurrency = CURT_TRANSMUTE_CRYSTALS,
        })
    end

    return data
end

function GuildPlannerPro_Sets:ExportItemSetCollectionSets()
    local data = {}
    for _, set in pairs(ITEM_SET_COLLECTIONS_DATA_MANAGER.itemSetCollections) do
        if set:HasAnyUnlockedPieces() then
            local unlockedPieces = {}
            for _, piece in ipairs(set.pieces) do
                if piece:IsUnlocked() then
                    table.insert(unlockedPieces, piece:GetId())
                end
            end
            local setId = set:GetId()
            table.insert(data, {
                SetId = setId,
                NumUnlocked = set:GetNumUnlockedPieces(),
                UnlockedPieces = unlockedPieces,
                ReconstructionCost = set:GetReconstructionCurrencyOptionCost(CURT_TRANSMUTE_CRYSTALS),
                ReconstructionCurrency = CURT_TRANSMUTE_CRYSTALS,
            })
        end
    end

    return data
end

function GuildPlannerPro_Sets:MapItemSetCollectionSets()
    local data = {}
    for setId, _ in pairs(ItemSets) do
        local set = ITEM_SET_COLLECTIONS_DATA_MANAGER:GetItemSetCollectionData(setId)
        local _, setName, numBonuses, _, _, maxEquipped = GetItemSetInfo(setId)
        -- If set doesn't exist (craftable or otherwise), setName will be 'nil'.
        if setName ~= '' then
            local _, _, allowedNamesString = GetItemSetClassRestrictions(setId)
            local bonuses = {}
            for bonusIndex = 1, numBonuses do
                local numRequired, bonusDescription = GetItemSetBonusInfo(setId, bonusIndex)
                bonuses[bonusIndex] = {
                    NumRequired = numRequired,
                    BonusDescription = bonusDescription,
                }
            end
            if set then -- Non-craftable set
                local setCategory = set:GetCategoryData()
                local setParentCategory = setCategory:GetParentCategoryData()
                local pieces = {}
                for _, setPiece in pairs(set.pieces) do
                    local link = setPiece.itemLink
                    local _, enchantHeader, enchantDescription = GetItemLinkEnchantInfo(link)
                    table.insert(pieces, {
                        Id = setPiece:GetId(),
                        SetId = setId,
                        Name = setPiece:GetFormattedName(),
                        Link = link,
                        Icon = GetItemLinkIcon(link),
                        ItemRequiredLevel = GetItemLinkRequiredLevel(link),
                        ItemRequiredCp = GetItemLinkRequiredChampionPoints(link),
                        ArmorRating = GetItemLinkArmorRating(link, false),
                        WeaponPower = GetItemLinkWeaponPower(link),
                        BindType = GetItemLinkBindType(link),
                        EquipType = GetItemLinkEquipType(link),
                        ArmorType = GetItemLinkArmorType(link),
                        WeaponType = GetItemLinkWeaponType(link),
                        DisplayQuality = GetItemLinkDisplayQuality(link),
                        TradeskillType = GetItemLinkCraftingSkillType(link),
                        ItemEnchantType = GetEnchantSearchCategoryType(GetItemLinkFinalEnchantId(link)),
                        ItemEnchantHeader = enchantHeader,
                        ItemEnchantDescription = enchantDescription,
                    })
                end
                local datum = {
                    Id = setId,
                    Name = set:GetFormattedName(),
                    Type = set:GetSetType(),
                    NumBonuses = numBonuses,
                    MaxEquipped = maxEquipped,
                    CategoryId = setCategory:GetId(),
                    CategoryName = setCategory:GetFormattedName(),
                    Bonuses = bonuses,
                    Class = allowedNamesString,
                    NumPieces = set:GetNumPieces(),
                    Pieces = pieces,
                }
                if setParentCategory then
                    datum["ParentCategoryId"] = setParentCategory:GetId()
                    datum["ParentCategoryName"] = setParentCategory:GetFormattedName()
                end
                table.insert(data, datum)
            else -- Craftable set
                table.insert(data, {
                    Id = setId,
                    Name = setName,
                    Type = ITEM_SET_TYPE_CRAFTED,
                    NumBonuses = numBonuses,
                    MaxEquipped = maxEquipped,
                    Bonuses = bonuses,
                    Class = allowedNamesString,
                })
            end
        end
    end

    return data
end
