
function ConfirmMasterWrit:ClearItemList()
    self:Debug("[ClearItemList]", self.disabledColor)
    self.masterWritItemList = {}
    self.smithingItemList = nil
    self.enchantItemList = nil
    self.alchemyItemList = nil
    self.provisioningItemList = nil
    self.confirmList = {}
    self.isBindButtonVisible = nil
end




function ConfirmMasterWrit:GetAlchemyResult(itemLink, key1, key2, key3, key4)

    local elements = {
        tonumber(key1),
        tonumber(key2),
        tonumber(key3),
        tonumber(key4),
    }
    table.sort(elements)
    local key = table.concat(elements, ":")
    self:Debug("　　[GetAlchemyResult(" .. tostring(key) .. ")]")

    local result = self.alchemyResultList[key]
    if result == nil then
        if DailyAlchemy then
            local txt = GenerateMasterWritBaseText(itemLink)
            txt = DailyAlchemy:ConvertedJournalCondition(txt)

            local parameterList = DailyAlchemy:Advice(txt, 0, 1, true)
            for _, parameter in ipairs(parameterList) do
                if parameter.resultLink then
                    local solvent = parameter.solvent
                    solvent.bagId, solvent.slotIndex = DailyAlchemy:GetFirstStack(solvent.itemId)

                    local reagent1 = parameter.reagent1
                    reagent1.bagId, reagent1.slotIndex = DailyAlchemy:GetFirstStack(reagent1.itemId)

                    local reagent2 = parameter.reagent2
                    reagent2.bagId, reagent2.slotIndex = DailyAlchemy:GetFirstStack(reagent2.itemId)

                    local reagent3 = parameter.reagent3
                    reagent3.bagId, reagent3.slotIndex = DailyAlchemy:GetFirstStack(reagent3.itemId)

                    local resultTest = GetAlchemyResultingItemLink(solvent.bagId,  solvent.slotIndex,
                                                                   reagent1.bagId, reagent1.slotIndex,
                                                                   reagent2.bagId, reagent2.slotIndex,
                                                                   reagent3.bagId, reagent3.slotIndex,
                                                                   LINK_STYLE_DEFAULT)
                    if resultTest and resultTest ~= "" then
                        result = resultTest
                        self.alchemyResultList[key] = resultTest
                        self.savedVariables.alchemyResultList[key] = resultTest
                    end
                    self:DebugIfMarify("　　　　resultTest=" .. tostring(resultTest))
                    break
                end
            end
        end
        if result == nil then
            self:DebugIfMarify("　　　　not found " .. key)
            return nil
        end
    end
    local itemKey1, itemKey2 = string.match(result, "|H%d:item:(%d+:%d+:%d+:).*:(%d+)|h|h")
    local itemKey = itemKey1 .. itemKey2
    self:Debug("　　　　itemKey=" .. tostring(itemKey))


    local item
    if self.alchemyItemList == nil then
        self.alchemyItemList = {}
        local creator
        local itemType
        local itemLink
        local id1, id2
        local id
        local stack
        local slotIndex = ZO_GetNextBagSlotIndex(BAG_BACKPACK, nil)
        while slotIndex do
            itemType = GetItemType(BAG_BACKPACK, slotIndex)
            if self:ContainsNumber(itemType, ITEMTYPE_POTION, ITEMTYPE_POISON) then

                creator = GetItemCreatorName(BAG_BACKPACK, slotIndex)
                itemLink = GetItemLink(BAG_BACKPACK, slotIndex)
                if creator and creator == GetUnitName("player") then

                    id1, id2 = string.match(itemLink, "|H%d:item:(%d+:%d+:%d+:).*:(%d+)|h|h")
                    id = id1 .. id2
                    item = self.alchemyItemList[id] or { link=itemLink, stack=0, used=0 }
                    _, stack = GetItemInfo(BAG_BACKPACK, slotIndex)
                    item.itemLink = itemLink
                    item.stack    = item.stack + stack
                    self.alchemyItemList[id] = item
                    self:Debug("　　　　　　" .. tostring(id)
                                              .. " " .. tostring(itemLink)
                                              .. " stack=" .. tostring(item.stack)
                                              .. " used=" .. tostring(item.used)
                                              )
                end
            end
            slotIndex = ZO_GetNextBagSlotIndex(BAG_BACKPACK, slotIndex)
        end
    end
    item = self.alchemyItemList[itemKey]
    if item == nil then
        self:Debug("　　　　item=nil")
        return nil, itemKey
    end

    self:Debug("　　　　item=" .. tostring(item.itemLink)
                    .. " stack=" .. tostring(item.stack)
                    .. " used=" .. tostring(item.used))
    return item, itemKey
end




function ConfirmMasterWrit:GetEnchantResult(keyEssence, keyPotency, keyQuality)

    self:Debug("　　[GetEnchantResult]")
    self:Debug("　　　　keyPotency=" .. tostring(keyPotency))
    local requiredCPList = {
        [207] = 150,    -- Rejera
        [225] = 160,    -- Repora
    }
    local keyRequiredCP = requiredCPList[tonumber(keyPotency)]
    local elements = {
        tostring(keyEssence),       -- itemId
        tostring(keyRequiredCP),    -- championPoints
        tostring(keyQuality),       -- quality
    }
    local key = table.concat(elements, ":")
    self:Debug("　　　　key=" .. tostring(key))


    local item
    if self.enchantItemList == nil then
        self.enchantItemList = {}
        local creator
        local itemType
        local itemLink
        local requiredCP
        local elements
        local id
        local slotIndex = ZO_GetNextBagSlotIndex(BAG_BACKPACK, nil)
        while slotIndex do
            itemType = GetItemType(BAG_BACKPACK, slotIndex)
            if self:ContainsNumber(itemType, ITEMTYPE_GLYPH_ARMOR,
                                             ITEMTYPE_GLYPH_WEAPON,
                                             ITEMTYPE_GLYPH_JEWELRY) then

                creator = GetItemCreatorName(BAG_BACKPACK, slotIndex)
                itemLink = GetItemLink(BAG_BACKPACK, slotIndex)
                requiredCP = GetItemLinkRequiredChampionPoints(itemLink)
                if creator and creator == GetUnitName("player") and requiredCP >= 150 then

                    elements = {
                        tostring(GetItemLinkItemId(itemLink)),  -- itemId
                        tostring(requiredCP),                   -- championPoints
                        tostring(GetItemLinkQuality(itemLink)), -- quality
                    }
                    id = table.concat(elements, ":")
                    item = self.enchantItemList[id] or { link=itemLink, stack=0, used=0 }
                    _, stack = GetItemInfo(BAG_BACKPACK, slotIndex)
                    item.itemLink = itemLink
                    item.stack    = item.stack + stack
                    self.enchantItemList[id] = item
                    self:Debug("　　　　　　" .. tostring(id)
                                              .. " " .. tostring(itemLink)
                                              .. " stack=" .. tostring(item.stack)
                                              .. " used=" .. tostring(item.used)
                                              )
                end
            end
            slotIndex = ZO_GetNextBagSlotIndex(BAG_BACKPACK, slotIndex)
        end
    end
    item = self.enchantItemList[key]
    if item == nil then
        self:Debug("　　　　　　item=nil")
        return nil
    end

    self:Debug("　　　　　　item=" .. tostring(item.itemLink)
                       .. " stack=" .. tostring(item.stack)
                       .. " used=" .. tostring(item.used))
    return item
end




function ConfirmMasterWrit:GetProvisioningResult(keyItemId)

    self:Debug("　　[GetProvisioningResult(" .. tostring(keyItemId) .. ")]")
    local item
    if self.provisioningItemList == nil then
        self.provisioningItemList = {}
        local creator
        local itemType
        local itemLink
        local id
        local stack
        local slotIndex = ZO_GetNextBagSlotIndex(BAG_BACKPACK, nil)
        while slotIndex do
            itemType = GetItemType(BAG_BACKPACK, slotIndex)
            if self:ContainsNumber(itemType, ITEMTYPE_DRINK, ITEMTYPE_FOOD) then

                creator = GetItemCreatorName(BAG_BACKPACK, slotIndex)
                itemLink = GetItemLink(BAG_BACKPACK, slotIndex)
                if creator and creator == GetUnitName("player") then

                    id = GetItemId(BAG_BACKPACK, slotIndex)
                    item = self.provisioningItemList[id] or { link=itemLink, stack=0, used=0 }
                    _, stack = GetItemInfo(BAG_BACKPACK, slotIndex)
                    item.itemLink = itemLink
                    item.stack    = item.stack + stack
                    self.provisioningItemList[id] = item
                    self:Debug("　　　　　　" .. tostring(id)
                                              .. " " .. tostring(itemLink)
                                              .. " stack=" .. tostring(item.stack)
                                              .. " used=" .. tostring(item.used)
                                              )
                end
            end
            slotIndex = ZO_GetNextBagSlotIndex(BAG_BACKPACK, slotIndex)
        end
    end
    item = self.provisioningItemList[tonumber(keyItemId)]
    if item == nil then
        self:Debug("　　　　　　item=nil")
        return nil
    end

    self:Debug("　　　　　　item=" .. tostring(item.itemLink)
                       .. " stack=" .. tostring(item.stack)
                       .. " used=" .. tostring(item.used))
    return item
end




function ConfirmMasterWrit:GetSmithingInfo(key)

    --self:Debug("　　　　[GetSmithingInfo]")
    local smithingInfoList = {
        -- BLACKSMITHING(Rubedite)
        [53] = {ARMORTYPE_NONE,    EQUIP_TYPE_ONE_HAND,   WEAPONTYPE_AXE},                  -- Axe
        [56] = {ARMORTYPE_NONE,    EQUIP_TYPE_ONE_HAND,   WEAPONTYPE_HAMMER},               -- Mace
        [59] = {ARMORTYPE_NONE,    EQUIP_TYPE_ONE_HAND,   WEAPONTYPE_SWORD},                -- Sword
        [68] = {ARMORTYPE_NONE,    EQUIP_TYPE_TWO_HAND,   WEAPONTYPE_TWO_HANDED_AXE},       -- Battle Axe
        [69] = {ARMORTYPE_NONE,    EQUIP_TYPE_TWO_HAND,   WEAPONTYPE_TWO_HANDED_HAMMER},    -- Maul
        [67] = {ARMORTYPE_NONE,    EQUIP_TYPE_TWO_HAND,   WEAPONTYPE_TWO_HANDED_SWORD},     -- Greatsword
        [62] = {ARMORTYPE_NONE,    EQUIP_TYPE_ONE_HAND,   WEAPONTYPE_DAGGER},               -- Dagger

        -- BLACKSMITHING(Rubedite)
        [46] = {ARMORTYPE_HEAVY,   EQUIP_TYPE_CHEST,      WEAPONTYPE_NONE},                 -- Cuirass
        [50] = {ARMORTYPE_HEAVY,   EQUIP_TYPE_FEET,       WEAPONTYPE_NONE},                 -- Sabatons
        [52] = {ARMORTYPE_HEAVY,   EQUIP_TYPE_HAND,       WEAPONTYPE_NONE},                 -- Gauntlets
        [44] = {ARMORTYPE_HEAVY,   EQUIP_TYPE_HEAD,       WEAPONTYPE_NONE},                 -- Helm
        [49] = {ARMORTYPE_HEAVY,   EQUIP_TYPE_LEGS,       WEAPONTYPE_NONE},                 -- Greaves
        [47] = {ARMORTYPE_HEAVY,   EQUIP_TYPE_SHOULDERS,  WEAPONTYPE_NONE},                 -- Pauldron
        [48] = {ARMORTYPE_HEAVY,   EQUIP_TYPE_WAIST,      WEAPONTYPE_NONE},                 -- Girdle

        -- CLOTHIER(Ancestor Silk)
        [28] = {ARMORTYPE_LIGHT,   EQUIP_TYPE_CHEST,      WEAPONTYPE_NONE},                 -- Robe
--      [  ] = {ARMORTYPE_LIGHT,   EQUIP_TYPE_CHEST,      WEAPONTYPE_NONE},                 -- Shirt
        [32] = {ARMORTYPE_LIGHT,   EQUIP_TYPE_FEET,       WEAPONTYPE_NONE},                 -- Shoes
        [34] = {ARMORTYPE_LIGHT,   EQUIP_TYPE_HAND,       WEAPONTYPE_NONE},                 -- Gloves
        [26] = {ARMORTYPE_LIGHT,   EQUIP_TYPE_HEAD,       WEAPONTYPE_NONE},                 -- Hat
        [31] = {ARMORTYPE_LIGHT,   EQUIP_TYPE_LEGS,       WEAPONTYPE_NONE},                 -- Breeches
        [29] = {ARMORTYPE_LIGHT,   EQUIP_TYPE_SHOULDERS,  WEAPONTYPE_NONE},                 -- Epaulets
        [30] = {ARMORTYPE_LIGHT,   EQUIP_TYPE_WAIST,      WEAPONTYPE_NONE},                 -- Sash

        -- CLOTHIER(Rubedo Leather)
        [37] = {ARMORTYPE_MEDIUM,  EQUIP_TYPE_CHEST,      WEAPONTYPE_NONE},                 -- Jack
        [41] = {ARMORTYPE_MEDIUM,  EQUIP_TYPE_FEET,       WEAPONTYPE_NONE},                 -- Boots
        [43] = {ARMORTYPE_MEDIUM,  EQUIP_TYPE_HAND,       WEAPONTYPE_NONE},                 -- Bracers
        [35] = {ARMORTYPE_MEDIUM,  EQUIP_TYPE_HEAD,       WEAPONTYPE_NONE},                 -- Helmet
        [40] = {ARMORTYPE_MEDIUM,  EQUIP_TYPE_LEGS,       WEAPONTYPE_NONE},                 -- Guards
        [38] = {ARMORTYPE_MEDIUM,  EQUIP_TYPE_SHOULDERS,  WEAPONTYPE_NONE},                 -- Arm Cap
        [39] = {ARMORTYPE_MEDIUM,  EQUIP_TYPE_WAIST,      WEAPONTYPE_NONE},                 -- Belt

        -- WOODWORKING(Sanded Ruby Ash)
        [70] = {ARMORTYPE_NONE,    EQUIP_TYPE_TWO_HAND,   WEAPONTYPE_BOW},                  -- Bow
        [72] = {ARMORTYPE_NONE,    EQUIP_TYPE_TWO_HAND,   WEAPONTYPE_FIRE_STAFF},           -- Inferno Staff
        [73] = {ARMORTYPE_NONE,    EQUIP_TYPE_TWO_HAND,   WEAPONTYPE_FROST_STAFF},          -- Ice Staff
        [74] = {ARMORTYPE_NONE,    EQUIP_TYPE_TWO_HAND,   WEAPONTYPE_LIGHTNING_STAFF},      -- Lightning Staff
        [71] = {ARMORTYPE_NONE,    EQUIP_TYPE_TWO_HAND,   WEAPONTYPE_HEALING_STAFF},        -- Restoration Staff
        [65] = {ARMORTYPE_NONE,    EQUIP_TYPE_OFF_HAND,   WEAPONTYPE_SHIELD},               -- Shield

        -- JEWELRY(Platinum)
        [18] = {ARMORTYPE_NONE,    EQUIP_TYPE_NECK,       WEAPONTYPE_NONE},                 -- Necklace
        [24] = {ARMORTYPE_NONE,    EQUIP_TYPE_RING,       WEAPONTYPE_NONE},                 -- Ring
    }
    local smithingInfo = smithingInfoList[tonumber(key)]
    if smithingInfo == nil then
        return nil, nil, nil
    end
    return unpack(smithingInfo)
end




function ConfirmMasterWrit:UpdateInventory(control)

    if control == nil then
        return
    end

    local craftMark = control:GetNamedChild("CMW_CraftMark")
    if craftMark then
        craftMark:SetHidden(true)
    end
    local floorMark = control:GetNamedChild("CMW_FloortMark")
    if floorMark then
        floorMark:SetHidden(true)
    end

    local slot = control.dataEntry.data
    if slot == nil then
        return
    end
    if slot.bagId ~= BAG_BACKPACK then
        return
    end

    local itemLink = GetItemLink(slot.bagId, slot.slotIndex)
    if itemLink == nil then
        return
    end

    local itemType, specializedItemType = GetItemLinkItemType(itemLink)
    if itemType ~= ITEMTYPE_MASTER_WRIT then
        return
    end

    self:Debug("[UpdateInventory] " .. tostring(itemLink))
    local craftingType, max = self:GetCraftingTypeByLink(itemLink)
    if craftingType == nil then
        return
    end

    self:UpdateFloorMark(control, itemLink)

    local uniqueId = Id64ToString(GetItemUniqueId(slot.bagId, slot.slotIndex))
    if DailyAlchemy then
        local reservation = DailyAlchemy.savedVariables.reservations[uniqueId]
        if reservation and reservation.current < reservation.max then
            if craftMark == nil then
                craftMark = WINDOW_MANAGER:CreateControl(control:GetName() .. "CMW_CraftMark", control, CT_TEXTURE)
                craftMark:SetDrawLayer(3)
                craftMark:SetDimensions(20, 20)
                craftMark:ClearAnchors()
                craftMark:SetAnchor(LEFT, control:GetNamedChild('Bg'), LEFT, 80, 10)
                craftMark:SetTexture("esoui/art/journal/journal_quest_selected.dds")
            end
            craftMark:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, ITEM_QUALITY_LEGENDARY))
            craftMark:SetHidden(false)
        elseif reservation then
            DailyAlchemy.savedVariables.reservations[uniqueId] = nil
        end
    end
    if DailyProvisioning then
        local reservation = DailyProvisioning.savedVariables.reservations[uniqueId]
        if reservation and reservation.current < reservation.max then
            if craftMark == nil then
                craftMark = WINDOW_MANAGER:CreateControl(control:GetName() .. "CMW_CraftMark", control, CT_TEXTURE)
                craftMark:SetDrawLayer(3)
                craftMark:SetDimensions(20, 20)
                craftMark:ClearAnchors()
                craftMark:SetAnchor(LEFT, control:GetNamedChild('Bg'), LEFT, 80, 10)
                craftMark:SetTexture("esoui/art/journal/journal_quest_selected.dds")
            end
            craftMark:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, ITEM_QUALITY_LEGENDARY))
            craftMark:SetHidden(false)
        elseif reservation then
            DailyProvisioning.savedVariables.reservations[uniqueId] = nil
        end
    end

    local key1, key2, key3, key4, key5, key6
        = string.match(itemLink, "|H%d:item:%d+:%d+:%d+:%d+:%d+:%d+:(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):.*")
    local result = self.masterWritItemList[uniqueId]
    if result == false then
        self:Debug("　　return false1")
        return

    elseif result == nil then

        if craftingType == CRAFTING_TYPE_ALCHEMY then
            result = self:GetAlchemyResult(itemLink, key1, key2, key3, key4)

        elseif craftingType == CRAFTING_TYPE_PROVISIONING then
            result = self:GetProvisioningResult(key1)

        elseif craftingType == CRAFTING_TYPE_ENCHANTING then
            result = self:GetEnchantResult(key1, key2, key3)

        else
            result = self:GetSmithingResult(key1, key3, key4, key5, key6)
        end

        if result and (result.stack - result.used) >= max  then
            result.used = result.used + max
            if DailyAlchemy then
                DailyAlchemy.savedVariables.reservations[uniqueId] = nil
            end
            if DailyProvisioning then
                DailyProvisioning.savedVariables.reservations[uniqueId] = nil
            end
        else
            self:Debug("　　return false2")
            self.masterWritItemList[uniqueId] = false
            return
        end
    end


    self.masterWritItemList[uniqueId] = result
    craftMark = control:GetNamedChild("CMW_CraftMark")
    if craftMark == nil then
        craftMark = WINDOW_MANAGER:CreateControl(control:GetName() .. "CMW_CraftMark", control, CT_TEXTURE)
        craftMark:SetDrawLayer(3)
        craftMark:SetDimensions(20, 20)
        craftMark:ClearAnchors()
        craftMark:SetAnchor(LEFT, control:GetNamedChild('Bg'), LEFT, 80, 10)
        craftMark:SetTexture("esoui/art/journal/journal_quest_selected.dds")
    end
    craftMark:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_DISABLED))
    craftMark:SetHidden(false)

    local floorMark = control:GetNamedChild("CMW_FloortMark")
    if floorMark then
        floorMark:SetHidden(true)
    end
end




function ConfirmMasterWrit:GetSmithingResult(key1, keyQuality, keySetId, keyTraitType, keyStyleId)

    self:Debug("　　[GetSmithingResult(<<1>>, <<2>>, <<3>>, <<4>>, <<5>>)]", tostring(key1),
                                                                             tostring(keyQuality),
                                                                             tostring(keySetId),
                                                                             tostring(keyTraitType),
                                                                             tostring(keyStyleId))
    local keyArmorType, keyEquipType, keyWeaponType = self:GetSmithingInfo(key1)
    --self:Debug("　　　　keyArmorType="  .. tostring(keyArmorType))
    --self:Debug("　　　　keyEquipType="  .. tostring(keyEquipType))
    --self:Debug("　　　　keyWeaponType=" .. tostring(keyWeaponType))
    --self:Debug("　　　　keyQuality="    .. tostring(keyQuality))
    --self:Debug("　　　　keySetId="      .. tostring(keySetId))
    --self:Debug("　　　　keyTraitType="  .. tostring(keyTraitType))
    --self:Debug("　　　　keyStyleId="    .. tostring(keyStyleId))
    local elements = {
        tostring(keyArmorType),     -- armorType
        tostring(keyEquipType),     -- equipType
        tostring(keyWeaponType),    -- weaponType
        tostring(keyQuality),       -- quality
        tostring(keySetId),         -- setId
        tostring(keyTraitType),     -- traitType
        tostring(keyStyleId),       -- styleId
    }
    local smithingItemKey = table.concat(elements, ":")
    --self:Debug("　　　　smithingItemKey=" .. tostring(smithingItemKey))


    local item
    if self.smithingItemList == nil then
        self.smithingItemList = {}
        local creator
        local itemType
        local itemLink
        local hasSet, setId
        local requiredCP
        local id
        local stack
        local slotIndex = ZO_GetNextBagSlotIndex(BAG_BACKPACK, nil)
        while slotIndex do
            itemType = GetItemType(BAG_BACKPACK, slotIndex)
            if self:ContainsNumber(itemType, ITEMTYPE_WEAPON, ITEMTYPE_ARMOR) then

                creator = GetItemCreatorName(BAG_BACKPACK, slotIndex)
                itemLink = GetItemLink(BAG_BACKPACK, slotIndex)
                hasSet, _, _, _, _, setId = GetItemLinkSetInfo(itemLink, false)
                requiredCP = GetItemLinkRequiredChampionPoints(itemLink)
                if creator and creator == GetUnitName("player") and requiredCP >= 150 then

                    elements = {
                        tostring(GetItemLinkArmorType(itemLink)),   -- armorType
                        tostring(GetItemLinkEquipType(itemLink)),   -- equipType
                        tostring(GetItemLinkWeaponType(itemLink)),  -- weaponType
                        tostring(GetItemLinkQuality(itemLink)),     -- quality
                        tostring(setId),                            -- setId
                        tostring(GetItemLinkTraitInfo(itemLink)),   -- traitType
                        tostring(GetItemLinkItemStyle(itemLink)),   -- styleId
                    }
                    id = table.concat(elements, ":")
                    item = self.smithingItemList[id] or { link=itemLink, stack=0, used=0 }
                    _, stack = GetItemInfo(BAG_BACKPACK, slotIndex)
                    item.itemLink = itemLink
                    item.stack    = item.stack + stack
                    self.smithingItemList[id] = item
                    self:Debug("　　　　<<1>> <<2>> stack=<<3>> used=<<4>>", tostring(id),
                                                                             tostring(itemLink),
                                                                             tostring(item.stack),
                                                                             tostring(item.used))
                end
            end
            slotIndex = ZO_GetNextBagSlotIndex(BAG_BACKPACK, slotIndex)
        end
    end
    item = self.smithingItemList[smithingItemKey]
    if item == nil then
        self:Debug("　　　　>Not created")
        return nil
    end

    self:Debug("　　　　>result=<<1>> stack=<<2>> used=<<3>>", tostring(item.itemLink),
                                                               tostring(item.stack),
                                                               tostring(item.used))
    return item
end

