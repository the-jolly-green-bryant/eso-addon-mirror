local SK = SwissKnife
local SDM = SKILLS_DATA_MANAGER
local SKH = SK.HelperFunctions
local SKDI = SK.Data.itemsData
local SKDE = SK.Data.equipmentData
local TRUE = SK.TRUE

local function markForDeconstruct(bagId, slotIndex)
    if FCOIS and FCOIS.MarkItem ~= nil then
        local itemLink = GetItemLink(bagId, slotIndex)
        FCOIS.MarkItem(bagId, slotIndex, FCOIS_CON_ICON_DECONSTRUCTION, true, true)
        if SK.savedVars.enableMarkForDeconstructNotification then
            SKH.sendMessageToChat(
                SK.COLORED_PREFIXES.SKA,
                SI_SK_AUT_LOOT_UNWANTED_DECONSTRUCT_MESSAGE,
                itemLink:gsub("%|H0", "|H1")
            )
        end
    end
end

local function markAsJunk(bagId, slotIndex)
    if CanItemBeMarkedAsJunk(bagId, slotIndex) then
        if not IsItemJunk(bagId, slotIndex) then
            local itemLink = GetItemLink(bagId, slotIndex)
            SetItemIsJunk(bagId, slotIndex, true)
            if SK.savedVars.enableMarkAsJunkNotification then
                SKH.sendMessageToChat(
                    SK.COLORED_PREFIXES.SKA,
                    SI_SK_AUT_LOOT_UNWANTED_JUNK_MESSAGE,
                    itemLink:gsub("%|H0", "|H1")
                )
            end
        end
    end
    return false
end

local function isSetPartsExists(data, itemLink)
    local equipType = GetItemLinkEquipType(itemLink)
    local itemType = GetItemLinkItemType(itemLink)
    if itemType ~= ITEMTYPE_NONE and equipType ~= EQUIP_TYPE_INVALID then
        local weaponType = GetItemLinkWeaponType(itemLink)
        if itemType == ITEMTYPE_ARMOR and weaponType == WEAPONTYPE_NONE then
            return data.setParts[itemType][equipType] == TRUE
        elseif weaponType ~= WEAPONTYPE_NONE then
            return data.setParts[itemType][weaponType] == TRUE
        end
    end
    return false
end

local function checkSetJunkConditions(data, itemLink)
    local itemQuality = GetItemLinkFunctionalQuality(itemLink)
    local itemType = GetItemLinkItemType(itemLink)
    local equipType = GetItemLinkEquipType(itemLink)
    local jewelryPreset = SKDE.ITEM_PRESETS[1]
    local isJewelry = itemType == jewelryPreset.itemType and SKH.isValueInList(jewelryPreset.equipTypes, equipType)
    local canBeResearched = CanItemLinkBeTraitResearched(itemLink)
    if SK.savedVars.junkKnownTraitOnly and canBeResearched then return false end
    if isJewelry then
        if data.qualityJewelry ~= nil and itemQuality > data.qualityJewelry then return false end
    else
        if data.quality ~= nil and itemQuality > data.quality then return false end
    end
    return isSetPartsExists(data, itemLink)
end

local function checkSetDeconstructConditions(data, itemLink)
	local itemQuality = GetItemLinkFunctionalQuality(itemLink)
    local itemType = GetItemLinkItemType(itemLink)
    local equipType = GetItemLinkEquipType(itemLink)
    local jewelryPreset = SKDE.ITEM_PRESETS[1]
    local isJewelry = itemType == jewelryPreset.itemType and SKH.isValueInList(jewelryPreset.equipTypes, equipType)
    local canBeResearched = CanItemLinkBeTraitResearched(itemLink)
    if SK.savedVars.junkKnownTraitOnly and canBeResearched then return false end
    if (data.quality ~= nil and data.deconstructQuality ~= nil and data.deconstructQuality ~= data.quality and
        itemQuality > data.quality and itemQuality <= data.deconstructQuality and not isJewelry) or (isJewelry and
        data.qualityJewelry ~= nil and data.deconstructQualityJewelry ~= nil and itemQuality > data.qualityJewelry and
        data.deconstructQualityJewelry ~= data.qualityJewelry and itemQuality <= data.deconstructQualityJewelry)
    then
        return isSetPartsExists(data, itemLink)
    end
    return false
end

local function checkSingleSlotBackpackDeconstructSetsPart(slotIndex)
    local permanentUnwantedSetIds = SK.globalSV.permanentUnwantedSetIds
    local itemLink = GetItemLink(BAG_BACKPACK, slotIndex)
    local hasSet, _, _, _, _, setId = GetItemLinkSetInfo(itemLink)
    return hasSet and SKH.isKeyInTable(permanentUnwantedSetIds, setId) and
        checkSetDeconstructConditions(permanentUnwantedSetIds[setId], itemLink)
end

local function checkUnwantedConditions(itemLink)
    local isJunk, isDeconstruct, isTreasure, isDestroy = false, false, false, false
    local itemType = GetItemLinkItemType(itemLink)
    local traitType = GetItemLinkTraitInfo(itemLink)
    local itemQuality = GetItemLinkFunctionalQuality(itemLink)
    local hasSet = GetItemLinkSetInfo(itemLink)
    local itemId = GetItemLinkItemId(itemLink)
    local sellInformation = GetItemLinkSellInformation(itemLink)
    if SK.savedVars.junkTreasures and SKH.isValueInList(SKDI.ITEM_TRAIT_ORNATE, traitType) then
        if SK.savedVars.debugMode then d("ITEM_TRAIT_ORNATE") end
        isJunk = true
    elseif SK.savedVars.junkTreasures and (SKH.isValueInList(SKDI.ITEM_JUNK_TYPES, itemType) or
            sellInformation == ITEM_SELL_INFORMATION_PRIORITY_SELL)
    then
        if SK.savedVars.debugMode then d("ITEM_JUNK_TYPES "..itemLink) end
        if itemQuality < ITEM_FUNCTIONAL_QUALITY_LEGENDARY then
            if SK.savedVars.debugMode then d("junkTreasures and isTreasure "..itemLink) end
            isTreasure = true
            isJunk = true
        end
    elseif SK.savedVars.filterUnwantedItemAfterLoot and SKH.isKeyInTable(SK.globalSV.permanentUnwantedItemIds, itemId) and
            not IsItemLinkCrafted(itemLink) then
        if SK.savedVars.debugMode then d("junkPermanentUnwanted "..itemLink) end
        local action = SK.globalSV.permanentUnwantedItemIds[itemId].action
        if action == nil then action = SK.destroyAction end
        if action == SK.destroyAction then
            isDestroy = true
        elseif action == SK.junkAction then
            isJunk = true
        end
    elseif SK.savedVars.junkNonSetEquipments and not hasSet then
        if GetItemLinkActorCategory(itemLink) == GAMEPLAY_ACTOR_CATEGORY_COMPANION then return end
        local equipType = GetItemLinkEquipType(itemLink)
        if itemType ~= ITEMTYPE_NONE and equipType ~= EQUIP_TYPE_INVALID then
            if SK.savedVars.debugMode then d("junkNonSetEquipments "..itemLink) end
            local canBeResearched = CanItemLinkBeTraitResearched(itemLink)
            if SK.savedVars.junkKnownTraitOnly and canBeResearched then
                if SK.savedVars.debugMode then d("canBeResearched") end
                return isJunk, isDeconstruct, isTreasure, isDestroy
            end
            if SKH.isValueInList(SKDI.ITEM_TRAIT_INTRICATE, traitType) then
                if SK.savedVars.debugMode then d("ITEM_TRAIT_INTRICATE "..itemLink) end
                return isJunk, isDeconstruct, isTreasure, isDestroy
            end
            local weaponType = GetItemLinkWeaponType(itemLink)
            if itemType == ITEMTYPE_ARMOR and weaponType == WEAPONTYPE_NONE then
                if SKH.isValueInList(SKDE.ITEM_PRESETS[0].equipTypes, equipType) then
                    if SK.savedVars.debugMode then d("is equipment "..itemLink) end
                    if itemQuality > SK.savedVars.junkNonSetEquipmentQuality then
                        if SK.savedVars.debugMode then d("deconstruct by quality") end
                        isDeconstruct = SK.savedVars.deconstructNonSetArmorWeapon
                    else
                        if SK.savedVars.debugMode then d("junk by quality") end
                        isJunk = true
                    end
                elseif SK.savedVars.deconstructNonSetJewelry and
                    SKH.isValueInList(SKDE.ITEM_PRESETS[1].equipTypes, equipType)
                then
                    if SK.savedVars.debugMode then d("is jewelry "..itemLink) end
                    isDeconstruct = true
                end
            elseif weaponType ~= WEAPONTYPE_NONE then
                if SK.savedVars.debugMode then d("is weapon "..itemLink) end
                if itemQuality > SK.savedVars.junkNonSetEquipmentQuality then
                    if SK.savedVars.debugMode then d("deconstruct by quality") end
                    isDeconstruct = SK.savedVars.deconstructNonSetArmorWeapon
                else
                    if SK.savedVars.debugMode then d("junk by quality") end
                    isJunk = true
                end
            end
        end
    end
    return isJunk, isDeconstruct, isTreasure, isDestroy
end

local function getJunkMismatchConditionName(data, itemLink)
    if isSetPartsExists(data, itemLink) then
        local itemQuality = GetItemLinkFunctionalQuality(itemLink)
        local canBeResearched = CanItemLinkBeTraitResearched(itemLink)
        if SK.savedVars.junkKnownTraitOnly and canBeResearched then
            return GetString(SI_SK_AUT_JUNK_MISMATCH_CONDITION_CAUSE_RESEARCH_NAME), SK.COLOR.CYAN
        else
            local notNeedJunk = data.quality ~= nil and itemQuality > data.quality
            local notNeedDeconstruct = data.quality ~= nil and data.deconstructQuality ~= nil and
                data.deconstructQuality ~= data.quality and itemQuality > data.quality and
                itemQuality <= data.deconstructQuality
            if notNeedJunk or notNeedDeconstruct then
                return GetString(SI_SK_AUT_JUNK_MISMATCH_CONDITION_CAUSE_QUALITY_NAME), SK.COLOR.DARK_OLIVE_GREEN
            end
        end
    else
        return GetString(SI_SK_AUT_JUNK_MISMATCH_CONDITION_CAUSE_SET_PARTS_NAME), SK.COLOR.GREEN
    end
end

local function filterSingleSlotBackpackJunkSetsPart(permanentUnwantedSetIds, slotIndex, isDeconstructToo)
    if not SK.savedVars.junkUnwantedSetsAfterLoot then return end
    if SKH.isItemProtected(BAG_BACKPACK, slotIndex) then return end
    local itemLink = GetItemLink(BAG_BACKPACK, slotIndex)
    local hasSet, _, _, _, _, setId = GetItemLinkSetInfo(itemLink)
    if hasSet and SKH.isKeyInTable(permanentUnwantedSetIds, setId) then
        local isSetJunkConditions = checkSetJunkConditions(permanentUnwantedSetIds[setId], itemLink)
        local isSetDeconstructConditions = checkSetDeconstructConditions(permanentUnwantedSetIds[setId], itemLink)
        if isSetJunkConditions then markAsJunk(BAG_BACKPACK, slotIndex) end
        if isSetDeconstructConditions then
            if SK.savedVars.markDeconstructUnwantedWithFCOIS then markForDeconstruct(BAG_BACKPACK, slotIndex) end
            if isDeconstructToo then markAsJunk(BAG_BACKPACK, slotIndex) end
        end
        return isSetJunkConditions or isSetDeconstructConditions
    end
end

local function filterAllBackpackJunkSetsParts(permanentUnwantedSetIds, isDeconstructToo)
    local slotsCount = GetBagSize(BAG_BACKPACK)
    for i = 0, slotsCount - 1 do
        filterSingleSlotBackpackJunkSetsPart(permanentUnwantedSetIds, i, isDeconstructToo)
    end
end

local function filterSingleSlotBackpackJunk(slotIndex)
    local itemLink = GetItemLink(BAG_BACKPACK, slotIndex)
    local hasSet = GetItemLinkSetInfo(itemLink)
    if SKH.isItemProtected(BAG_BACKPACK, slotIndex) or IsItemLinkCrafted(itemLink) or hasSet then return end
    local isJunkConditions, isDeconstructConditions, _, _ = checkUnwantedConditions(itemLink)
    if isJunkConditions then
        markAsJunk(BAG_BACKPACK, slotIndex)
    elseif isDeconstructConditions then
        if SK.savedVars.junkDeconstructedToo then markAsJunk(BAG_BACKPACK, slotIndex) end
        markForDeconstruct(BAG_BACKPACK, slotIndex)
    end
    return isJunkConditions or isDeconstructConditions
end

local function filterAllBackpackJunk()
    local slotsCount = GetBagSize(BAG_BACKPACK)
    for i = 0, slotsCount - 1 do
        filterSingleSlotBackpackJunk(i)
    end
end

local function filterSingleSlotBackpackPermanentUnwantedItem(permanentUnwantedItemIds, slotIndex, isNewItem)
    if not SK.savedVars.filterUnwantedItemAfterLoot then return end
    if SK.savedVars.filterNewOnlyUnwantedItem and not isNewItem then return end
    local itemLink = GetItemLink(BAG_BACKPACK, slotIndex)
    local itemId = GetItemLinkItemId(itemLink)
    if not SKH.isKeyInTable(permanentUnwantedItemIds, itemId) then return end
    local action = permanentUnwantedItemIds[itemId].action
    if not action or action == SK.destroyAction then
        if SKH.isItemDestroyProtected(BAG_BACKPACK, slotIndex) and not SK.savedVars.destroyProtectedUnwantedItem then return end
        if IsItemLinkCrafted(itemLink) and not SK.savedVars.destroyCraftedUnwantedItem then return end
        if not SK.savedVars.debugMode then DestroyItem(BAG_BACKPACK, slotIndex) end
        return true
    elseif action == SK.junkAction then
        if SKH.isItemProtected(BAG_BACKPACK, slotIndex) or IsItemLinkCrafted(itemLink) then return end
        markAsJunk(BAG_BACKPACK, slotIndex)
    end
end

local function filterAllBackpackPermanentUnwantedItems(permanentUnwantedItemIds)
    local slotsCount = GetBagSize(BAG_BACKPACK)
    for i = 0, slotsCount - 1 do
        if filterSingleSlotBackpackPermanentUnwantedItem(permanentUnwantedItemIds, i, false) and
            SK.savedVars.enableDestroyedNotification
        then
            local itemLink = GetItemLink(BAG_BACKPACK, i)
            SKH.sendMessageToChat(
                SK.COLORED_PREFIXES.SKA,
                SI_SK_AUT_LOOT_UNWANTED_DESTROY_MESSAGE,
                itemLink:gsub("%|H0", "|H1")
            )
        end
    end
end

local function canBeUseForCraftTraining(bagId, slotIndex)
    for _, craftingType in ipairs(SKDI.ITEM_TRAIT_INTRICATE_CRAFTING_SKILLS) do
        if CanItemBeDeconstructed(bagId, slotIndex, craftingType) then
            local craftingSkillLineData = SDM:GetCraftingSkillLineData(craftingType)
            if craftingSkillLineData then
                local t, i = craftingSkillLineData:GetIndices()
                local _, rank = SKH.getSkillLineInfo(t, i)
                if rank < 50 then return true end
            end
        end
    end
    return false
end

local function filterSingleSlotBackpackIntricateAndGlyphs(slotIndex)
    if not FCOIS then return end
    local itemLink = GetItemLink(BAG_BACKPACK, slotIndex)
    local hasSet = GetItemLinkSetInfo(itemLink)
    if SKH.isItemDeconstructionProtected(BAG_BACKPACK, slotIndex) or IsItemLinkCrafted(itemLink) or hasSet then return end
    local itemType = GetItemLinkItemType(itemLink)
    local traitType = GetItemLinkTraitInfo(itemLink)
    local isIntricate, isGlyph = SKH.isValueInList(SKDI.ITEM_TRAIT_INTRICATE, traitType), SKH.isValueInList(SKDI.ITEM_GLYPH_TYPES, itemType)
    if isGlyph and not (SK.savedVars.useGlyphsForCraftTraining and SK.savedVars.markGlyphsForCraftTraining) then return end
    if isIntricate and not (SK.savedVars.useIntricateForCraftTraining and SK.savedVars.markIntricateForCraftTraining) then return end
    if isIntricate or isGlyph then
        if canBeUseForCraftTraining(BAG_BACKPACK, slotIndex) then
            if isGlyph then
                local itemQuality = GetItemLinkFunctionalQuality(itemLink)
                if itemQuality <= SK.savedVars.useGlyphsForCraftTrainingQuality then
                    markForDeconstruct(BAG_BACKPACK, slotIndex)
                    return true
                end
            else
                FCOIS.MarkItem(BAG_BACKPACK, slotIndex, FCOIS_CON_ICON_INTRICATE, false, true)
                markForDeconstruct(BAG_BACKPACK, slotIndex)
                return true
            end
        else
            if isGlyph then
                local itemQuality = GetItemLinkFunctionalQuality(itemLink)
                if itemQuality <= SK.savedVars.useGlyphsForCraftTrainingQuality and
                    SK.savedVars.junkGlyphsIfCraftMaximize
                then
                    FCOIS.MarkItem(BAG_BACKPACK, slotIndex, FCOIS_CON_ICON_DECONSTRUCTION, false, true)
                    markAsJunk(BAG_BACKPACK, slotIndex)
                    return true
                end
            else
                if SK.savedVars.junkIntricateIfCraftMaximize then
                    FCOIS.MarkItem(BAG_BACKPACK, slotIndex, FCOIS_CON_ICON_DECONSTRUCTION, false, true)
                    FCOIS.MarkItem(BAG_BACKPACK, slotIndex, FCOIS_CON_ICON_INTRICATE, false, true)
                    markAsJunk(BAG_BACKPACK, slotIndex)
                    return true
                end
            end
        end
    end
end

local function filterAllBackpackIntricateAndGlyphs()
    local slotsCount = GetBagSize(BAG_BACKPACK)
    for i = 0, slotsCount - 1 do
        filterSingleSlotBackpackIntricateAndGlyphs(i)
    end
end

local function checkStolenUnwantedSetPart(itemLink)
    local isJunk, isDeconstruct, isWanted = false, false, false
    local hasSet, _, _, _, _, setId = GetItemLinkSetInfo(itemLink)
    local permanentUnwantedSetIds = SK.globalSV.permanentUnwantedSetIds
    if hasSet and SKH.isKeyInTable(permanentUnwantedSetIds, setId) then
        isJunk = checkSetJunkConditions(permanentUnwantedSetIds[setId], itemLink)
        isDeconstruct = checkSetDeconstructConditions(permanentUnwantedSetIds[setId], itemLink)
        if not isJunk and not isDeconstruct then isWanted = true end
    end
    return isJunk, isDeconstruct, isWanted
end

local function isStolenItemForSell(bagId, slotIndex, itemLink)
    if not SK.savedVars.isSmartSaleEnabled then return end
    if bagId and slotIndex and not itemLink then itemLink = GetItemLink(bagId, slotIndex) end
    local itemType = GetItemType(bagId, slotIndex)
    local itemQuality = GetItemLinkFunctionalQuality(itemLink)
    local sellCost = GetItemSellValueWithBonuses(bagId, slotIndex)
    if sellCost == 0 or itemType == ITEMTYPE_CONTAINER or itemQuality > 4 or itemQuality == 0 or
        SKH.isItemProtected(bagId, slotIndex) or SKH.isItemForLaunder(bagId, slotIndex, itemLink) or
        SKH.isStolenItemForDestroy(bagId, slotIndex, itemLink)
    then
        return
    end
    local _, isDeconstruct, isWanted = checkStolenUnwantedSetPart(itemLink)
    return not (isWanted or isDeconstruct)
end

local function filterSingleSlotBackpackStolen(slotIndex)
    if not SK.savedVars.isPickyThiefEnabled then return end
    if not IsItemStolen(BAG_BACKPACK, slotIndex) then return end
    local itemLink = GetItemLink(BAG_BACKPACK, slotIndex)
    if not SKH.isItemForLaunder(nil, nil, itemLink) then
        if SKH.isStolenItemForDestroy(BAG_BACKPACK, slotIndex, itemLink) then
            if not SK.savedVars.debugMode then DestroyItem(BAG_BACKPACK, slotIndex) end
            SKH.sendMessageToChat(
                SK.COLORED_PREFIXES.SKA,
                SI_SK_AUT_LOOT_UNWANTED_DESTROY_MESSAGE,
                itemLink:gsub("%|H0", "|H1")
            )
            return true
        else
            local isJunk, isDeconstruct, isWanted = checkStolenUnwantedSetPart(itemLink)
            if not isWanted then
                if isJunk then
                    markAsJunk(BAG_BACKPACK, slotIndex)
                    return true
                elseif isDeconstruct then
                    if SK.savedVars.markDeconstructUnwantedWithFCOIS then markForDeconstruct(BAG_BACKPACK, slotIndex) end
                    if SK.savedVars.junkDeconstructedToo then markAsJunk(BAG_BACKPACK, slotIndex) end
                    return true
                else
                    local itemType = GetItemType(BAG_BACKPACK, slotIndex)
                    if itemType ~= ITEMTYPE_CONTAINER then
                        markAsJunk(BAG_BACKPACK, slotIndex)
                        return true
                    end
                end
            end
        end
    end
end

local function filterAllBackpackStolenJunk()
    if not SK.savedVars.isPickyThiefEnabled then return end
    local slotsCount = GetBagSize(BAG_BACKPACK)
    for slotIndex = 0, slotsCount - 1 do filterSingleSlotBackpackStolen(slotIndex) end
end

local function unwantedTooltip(control)
    local text, checkedParts, uncheckedParts, partName = "", "", "", ""
    local _, setName, _, _, _, setId = GetItemLinkSetInfo(control.itemLink)
    local setParts = SK.globalSV.permanentUnwantedSetIds[setId].setParts
    local SET_TO_FULL_SIZE = true
    local r, g, b = SK.QUALITY_MAP[control.setQuality]:UnpackRGB()
	if SK.savedVars.showEnSetNameToo then
		setName = SKH.getSetName(control.itemLink, false, true)
	end
    InitializeTooltip(InformationTooltip, control, TOPRIGHT, 0, 0, TOPLEFT)
    InformationTooltip:AddLine(
        setName, "ZoFontAnnounceMedium", r, g, b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, SET_TO_FULL_SIZE
    )
    r, g, b = ZO_HIGHLIGHT_TEXT:UnpackRGB()
    if (control.setQuality and control.setQuality > 0) or
        (control.junkQualityJewelry and control.junkQualityJewelry > 0)
    then
        text = SK.COLOR.LIGHT_YELLOW:Colorize(GetString(SI_SK_AUT_UNWANTED_EDIT_SET_JUNK_QUALITY_LABEL))
        InformationTooltip:AddLine(
            text, "ZoFontWinT1", r, g, b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, SET_TO_FULL_SIZE
        )
        text = ""
        if control.setQuality and control.setQuality > 0 then
            text = GetString(SI_SK_AUT_UNWANTED_EDIT_SET_JUNK_EQUIPMENT_LABEL)..": "..SK.QUALITY_MAP[control.setQuality]:Colorize(GetString("SI_ITEMQUALITY", control.setQuality))
        end
        if control.junkQualityJewelry and control.junkQualityJewelry > 0 then
            local text1 = GetString(SI_SK_AUT_UNWANTED_EDIT_SET_JUNK_JEWELRY_LABEL)..": "..SK.QUALITY_MAP[control.junkQualityJewelry]:Colorize(GetString("SI_ITEMQUALITY", control.junkQualityJewelry))
            if text ~= "" then
                text = text .. "\n" .. text1
            else
                text = text1
            end
        end
        InformationTooltip:AddLine(
            text, "ZoFontWinT2", r, g, b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, SET_TO_FULL_SIZE
        )
    end

    if (control.deconstructQuality and control.deconstructQuality > 0) or
        (control.deconstructQualityJewelry and control.deconstructQualityJewelry > 0)
    then
        text = SK.COLOR.LIGHT_YELLOW:Colorize(GetString(SI_SK_AUT_UNWANTED_EDIT_SET_DECONSTRUCT_QUALITY_LABEL))
        InformationTooltip:AddLine(
            text, "ZoFontWinT1", r, g, b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, SET_TO_FULL_SIZE
        )
        text = ""
        if control.setQuality and control.deconstructQuality and control.deconstructQuality > control.setQuality then
            text = GetString(SI_SK_AUT_UNWANTED_EDIT_SET_JUNK_EQUIPMENT_LABEL)..": "..SK.QUALITY_MAP[control.deconstructQuality]:Colorize(GetString("SI_ITEMQUALITY", control.deconstructQuality))
        end
        if control.junkQualityJewelry and control.deconstructQualityJewelry and control.deconstructQualityJewelry > control.junkQualityJewelry then
            local text1 = GetString(SI_SK_AUT_UNWANTED_EDIT_SET_JUNK_JEWELRY_LABEL)..": "..SK.QUALITY_MAP[control.deconstructQualityJewelry]:Colorize(GetString("SI_ITEMQUALITY", control.deconstructQualityJewelry))
            if text ~= "" then
                text = text .. "\n" .. text1
            else
                text = text1
            end
        end
        InformationTooltip:AddLine(
            text, "ZoFontWinT2", r, g, b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, SET_TO_FULL_SIZE
        )
    end

    for preset = 0, 4 do
        for _, equipType in ipairs(SKDE.ITEM_PRESETS[preset].equipTypes) do
            local itemType = SKDE.ITEM_PRESETS[preset].itemType
            if itemType == ITEMTYPE_ARMOR then
                partName = GetString("SI_EQUIPTYPE", equipType)
            else
                partName = GetString("SI_WEAPONTYPE", equipType)
                if SKH.isValueInList(SKDE.TWO_HANDED, equipType) then
                    partName = partName.." "..GetString(SI_SK_INFO_WEAPON_TWO_HANDED)
                end
            end
            if setParts[itemType][equipType] == TRUE then
                if checkedParts ~= "" then
                    checkedParts = checkedParts..", "
                end
                checkedParts = checkedParts..partName
            else
                if uncheckedParts ~= "" then
                    uncheckedParts = uncheckedParts..", "
                end
                uncheckedParts = uncheckedParts..partName
            end
        end
    end

    if checkedParts ~= "" then
        r, g, b = ZO_HIGHLIGHT_TEXT:UnpackRGB()
        InformationTooltip:AddLine(checkedParts, "ZoFontChat", r, g, b, LEFT, MODIFY_TEXT_TYPE_NONE,
                TEXT_ALIGN_LEFT, SET_TO_FULL_SIZE)
	end
    if uncheckedParts ~= "" then
        r, g, b = ZO_DISABLED_TEXT:UnpackRGB()
        InformationTooltip:AddLine(uncheckedParts, "ZoFontChat", r, g, b, LEFT, MODIFY_TEXT_TYPE_NONE,
                TEXT_ALIGN_LEFT, SET_TO_FULL_SIZE)
    end
end

-- Export helper functions
SK.HelperFunctions.checkSetJunkConditions = checkSetJunkConditions
SK.HelperFunctions.checkSetDeconstructConditions = checkSetDeconstructConditions
SK.HelperFunctions.checkSingleSlotBackpackDeconstructSetsPart = checkSingleSlotBackpackDeconstructSetsPart
SK.HelperFunctions.checkUnwantedConditions = checkUnwantedConditions
SK.HelperFunctions.checkStolenUnwantedSetPart = checkStolenUnwantedSetPart
SK.HelperFunctions.isStolenItemForSell = isStolenItemForSell
SK.HelperFunctions.getJunkMismatchConditionName = getJunkMismatchConditionName
SK.HelperFunctions.filterSingleSlotBackpackJunkSetsPart = filterSingleSlotBackpackJunkSetsPart
SK.HelperFunctions.filterAllBackpackJunkSetsParts = filterAllBackpackJunkSetsParts
SK.HelperFunctions.filterSingleSlotBackpackJunk = filterSingleSlotBackpackJunk
SK.HelperFunctions.filterAllBackpackJunk = filterAllBackpackJunk
SK.HelperFunctions.filterSingleSlotBackpackPermanentUnwantedItem = filterSingleSlotBackpackPermanentUnwantedItem
SK.HelperFunctions.filterAllBackpackPermanentUnwantedItems = filterAllBackpackPermanentUnwantedItems
SK.HelperFunctions.canBeUseForCraftTraining = canBeUseForCraftTraining
SK.HelperFunctions.filterSingleSlotBackpackIntricateAndGlyphs = filterSingleSlotBackpackIntricateAndGlyphs
SK.HelperFunctions.filterAllBackpackIntricateAndGlyphs = filterAllBackpackIntricateAndGlyphs
SK.HelperFunctions.filterSingleSlotBackpackStolen = filterSingleSlotBackpackStolen
SK.HelperFunctions.filterAllBackpackStolenJunk = filterAllBackpackStolenJunk
SK.HelperFunctions.unwantedTooltip = unwantedTooltip
