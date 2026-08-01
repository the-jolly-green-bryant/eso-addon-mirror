-- Local instances of Global tables --
local PA = PersonalAssistant
local PAC = PA.Constants

-- ---------------------------------------------------------------------------------------------------------------------

-- =================================================================================================================
-- == INTEGRATION FUNCTIONS == --
-- -----------------------------------------------------------------------------------------------------------------

local function IsBookKnown(itemLink)
    local PALCK = PA.Libs.CharacterKnowledge
    if PALCK.IsInstalled() and PALCK.IsEnabled() then
        return PALCK.IsKnown(itemLink)
    else
        if IsItemLinkBook(itemLink) then
            local isKnown = IsItemLinkBookKnown(itemLink)
            return isKnown == true
        else
            return false
        end
    end
end

local function IsRecipeKnown(itemLink)
    local PALCK = PA.Libs.CharacterKnowledge
    if PALCK.IsInstalled() and PALCK.IsEnabled() then
        return PALCK.IsKnown(itemLink)
    else
        return IsItemLinkRecipeKnown(itemLink)
    end
end

local function IsScribingScriptKnown(itemLink)
    local PALCK = PA.Libs.CharacterKnowledge
    if PALCK.IsInstalled() and PALCK.IsEnabled() then
        return PALCK.IsKnown(itemLink)
    else
        if not SCRIBING_DATA_MANAGER then return false end
        local craftedAbilityScriptId = GetItemLinkItemUseReferenceId(itemLink) or 0
        local craftedAbilityScriptData = SCRIBING_DATA_MANAGER:GetCraftedAbilityScriptData(craftedAbilityScriptId)
        if not craftedAbilityScriptData then
            return false
        else
            return craftedAbilityScriptData:IsUnlocked() == true
        end
    end
end

local function IsScribingGrimoireKnown(itemLink)
    local PALCK = PA.Libs.CharacterKnowledge
    if PALCK.IsInstalled() and PALCK.IsEnabled() then
        return PALCK.IsKnown(itemLink)
    else
        if not SCRIBING_DATA_MANAGER then return false end
        local craftedAbilityId = GetItemLinkItemUseReferenceId(itemLink) or 0
        local craftedAbilityData = SCRIBING_DATA_MANAGER:GetCraftedAbilityData(craftedAbilityId)
        if not craftedAbilityData then
            return false
        else
            return craftedAbilityData:IsUnlocked() == true
        end
    end
end

-- =================================================================================================================
-- == MATH / TABLE FUNCTIONS == --
-- -----------------------------------------------------------------------------------------------------------------

---@param num number the number to be rounded down
---@param numDecimalPlaces number the number of decimal places to be rounded down to (defualt = 0)
---@return number the rounded down number
local function round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

---@param num number the number to be rounded down (to 0 decimal places)
---@return number the rounded down number
local function roundDown(num)
    if num > 0 then
        return math.floor(num)
    elseif num < 0 then
        return math.ceil(num)
    else
        return num
    end
end

---@param table table any table
---@param value string|number the value that might be in the table
---@return boolean whether the value exists in the table
local function isValueInTable(table, value)
    for _, v in pairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

---@param table table any table
---@param key string|number the key that might in the table
---@return boolean whether the key exists in the table
local function isKeyInTable(table, key)
    return table[key] ~= nil
end


-- =================================================================================================================
-- == ITEM IDENTIFIERS == --
-- -----------------------------------------------------------------------------------------------------------------
-- All credits go to sirinsidiator for below ItemIdentifier code from AGS!

local _hasItemTypeDifferentQualities = {
    [ITEMTYPE_GLYPH_ARMOR] = true,
    [ITEMTYPE_GLYPH_JEWELRY] = true,
    [ITEMTYPE_GLYPH_WEAPON] = true,
    [ITEMTYPE_DRINK] = true,
    [ITEMTYPE_FOOD] = true,
}

--- itemId is basically what tells us that two items are the same thing,
--- but some types need additional data to determine if they are of the same strength (and value).
---@param itemLink string the itemLink of an ESO item
---@return string the paItemId of the provided item
local function getPAItemLinkIdentifier(itemLink)
    local itemType = GetItemLinkItemType(itemLink)
    local itemId = GetItemLinkItemId(itemLink)
    if not (itemType == ITEMTYPE_WEAPON or itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_POISON or itemType == ITEMTYPE_POTION or _hasItemTypeDifferentQualities[itemType]) then
        return tostring(itemId)
    end
    local data = {zo_strsplit(":", itemLink:match("|H(.-)|h.-|h"))}
    local level = GetItemLinkRequiredLevel(itemLink)
    local cp = GetItemLinkRequiredChampionPoints(itemLink)
    if(itemType == ITEMTYPE_WEAPON or itemType == ITEMTYPE_ARMOR) then
        local trait = GetItemLinkTraitInfo(itemLink)
        return string.format("%s,%s,%d,%d,%d", itemId, data[4], trait, level, cp)
    elseif(itemType == ITEMTYPE_POISON or itemType == ITEMTYPE_POTION) then
        return string.format("%s,%d,%d,%s", itemId, level, cp, data[23])
    else
        return string.format("%s,%s", itemId, data[4])
    end
end

---@param bagId number the id of the bag
---@param slotIndex number the id of slot within the bag
---@return string the paItemId of the provided item
local function getPAItemIdentifier(bagId, slotIndex)
    local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
    return getPAItemLinkIdentifier(itemLink)
end

local function isItemForCompanion(bagId, slotIndex)
    local actorCategory = GetItemActorCategory(bagId, slotIndex)
    return actorCategory == GAMEPLAY_ACTOR_CATEGORY_COMPANION -- ~= GAMEPLAY_ACTOR_CATEGORY_PLAYER
end

local function isItemLinkForCompanion(itemLink)
    local actorCategory = GetItemLinkActorCategory(itemLink)
    return actorCategory == GAMEPLAY_ACTOR_CATEGORY_COMPANION -- ~= GAMEPLAY_ACTOR_CATEGORY_PLAYER
end

--- workaround function since ZOS' "CanItemBeMarkedAsJunk" function does not check for companion items
---@param bagId number representation of the bag
---@param slotIndex number representation of the slot
---@return boolean whether the item can be marked as junk or not
local function CanItemBeMarkedAsJunkExt(bagId, slotIndex)
    if Roomba and Roomba.WorkInProgress and Roomba.WorkInProgress() then return false end
    return CanItemBeMarkedAsJunk(bagId, slotIndex) and not isItemForCompanion(bagId, slotIndex)
end

-- =================================================================================================================
-- == COMPARATORS == --
-- -----------------------------------------------------------------------------------------------------------------

---@param itemData table the itemData table of an ESO item
---@return boolean whether the item is characterBound or not
local function isItemCharacterBound(itemData)
    if itemData.isPACharacterBound == nil then
        local isBound = IsItemBound(itemData.bagId, itemData.slotIndex)
        local bindType = GetItemBindType(itemData.bagId, itemData.slotIndex)
        itemData.isPACharacterBound = isBound and (bindType == BIND_TYPE_ON_PICKUP_BACKPACK)
    end
    return itemData.isPACharacterBound
end

---@param combinedLists table a complex list of holidayWrits, itemTypes, surveyMaps, itemTraitTypes, masterWritCraftingTypes, specializedItemTypes, learnableKnowItemTypes, learnableUnknownItemTypes, learnableKnowSpecializedItemTypes and learnableUnknownSpecializedItemTypes
---@param excludeJunk boolean whether junk items should be excluded
---@param skipItemsWithCustomRule boolean whether items for which a custom rule exists should be skipped
---@param skipFcoisLocked boolean whether items that are 'Locked' by FCOIS should be skipped
---@param deposit boolean whether this is a deposit or withdraw comparison
---@return fun(itemData: table) a comparator function that only returns item that match the complex list and pass the junk-test
local function getCombinedItemTypeSpecializedComparator(combinedLists, excludeJunk, skipItemsWithCustomRule, skipFcoisLocked, deposit) --token419
     local function _isItemOfItemTypeAndKnowledge(itemType, specializedItemType, itemLink, expectedItemType, expectedSpecializedItemType, expectedIsKnown)
     
        if (itemType and itemType ~= ITEMTYPE_NONE and itemType == expectedItemType) or (specializedItemType and specializedItemType ~= SPECIALIZED_ITEMTYPE_NONE and specializedItemType == expectedSpecializedItemType) then
            if itemType == ITEMTYPE_RACIAL_STYLE_MOTIF then
                if PA.Libs.CharacterKnowledge.IsInstalled() and PA.Libs.CharacterKnowledge.IsEnabled() then
                     local known = IsBookKnown(itemLink)
                     if deposit == true then -- Deposit
                         if known == expectedIsKnown or known ~= expectedIsKnown and PA.Libs.CharacterKnowledge.DoesCharacterNeed(itemLink) ~= expectedIsKnown then
                             return true
                         end
                     else -- Withdraw
                         if known == expectedIsKnown and PA.Libs.CharacterKnowledge.DoesCharacterNeed(itemLink) ~= expectedIsKnown then
                             return true
                         end
                     end
                else -- Default Behavior
                     local isBook = IsItemLinkBook(itemLink)
                     if isBook then
                         local isKnown = IsBookKnown(itemLink)
                         if isKnown == expectedIsKnown then return true end
                     end
                end
            elseif itemType == ITEMTYPE_RECIPE then
                if PA.Libs.CharacterKnowledge.IsInstalled() and PA.Libs.CharacterKnowledge.IsEnabled() then
                     local known = IsRecipeKnown(itemLink)
                     if deposit == true then -- Deposit
                         if known == expectedIsKnown or known ~= expectedIsKnown and PA.Libs.CharacterKnowledge.DoesCharacterNeed(itemLink) ~= expectedIsKnown then
                             return true
                         end
                     else -- Withdraw
                         if known == expectedIsKnown and PA.Libs.CharacterKnowledge.DoesCharacterNeed(itemLink) ~= expectedIsKnown then
                             return true
                         end
                     end
                  else -- Default Behavior
                      local known = IsRecipeKnown(itemLink)
                      if known == expectedIsKnown then return true end
                  end
            elseif itemType == ITEMTYPE_CRAFTED_ABILITY then
                 if PA.Libs.CharacterKnowledge.IsInstalled() and PA.Libs.CharacterKnowledge.IsEnabled() then
                      local known = IsScribingGrimoireKnown(itemLink)
                      if deposit == true then -- Deposit
                          if known == expectedIsKnown or known ~= expectedIsKnown and PA.Libs.CharacterKnowledge.DoesCharacterNeed(itemLink) ~= expectedIsKnown then
                              return true
                          end
                      else -- Withdraw
                          if known == expectedIsKnown and PA.Libs.CharacterKnowledge.DoesCharacterNeed(itemLink) ~= expectedIsKnown then
                              return true
                          end
                      end
                  else -- Default Behavior
                      local known = IsScribingScriptKnown(itemLink)
                      if known == expectedIsKnown then return true end
                  end
             elseif itemType == ITEMTYPE_CRAFTED_ABILITY_SCRIPT and specializedItemType == SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY_SCRIPT_PRIMARY then
                 if PA.Libs.CharacterKnowledge.IsInstalled() and PA.Libs.CharacterKnowledge.IsEnabled() then
                      local known = IsScribingScriptKnown(itemLink)
                      if deposit == true then -- Deposit
                          if known == expectedIsKnown or known ~= expectedIsKnown and PA.Libs.CharacterKnowledge.DoesCharacterNeed(itemLink) ~= expectedIsKnown then
                              return true
                          end
                      else -- Withdraw
                          if known == expectedIsKnown and PA.Libs.CharacterKnowledge.DoesCharacterNeed(itemLink) ~= expectedIsKnown then
                              return true
                          end
                      end
                  else -- Default Behavior
                      local known = IsScribingScriptKnown(itemLink)
                      if known == expectedIsKnown then return true end
                  end
             elseif itemType == ITEMTYPE_CRAFTED_ABILITY_SCRIPT and specializedItemType == SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY_SCRIPT_SECONDARY then
                 if PA.Libs.CharacterKnowledge.IsInstalled() and PA.Libs.CharacterKnowledge.IsEnabled() then
                      local known = IsScribingScriptKnown(itemLink)
                      if deposit == true then -- Deposit
                          if known == expectedIsKnown or known ~= expectedIsKnown and PA.Libs.CharacterKnowledge.DoesCharacterNeed(itemLink) ~= expectedIsKnown then
                              return true
                          end
                      else -- Withdraw
                          if known == expectedIsKnown and PA.Libs.CharacterKnowledge.DoesCharacterNeed(itemLink) ~= expectedIsKnown then
                              return true
                          end
                      end
                  else -- Default Behavior
                      local known = IsScribingScriptKnown(itemLink)
                      if known == expectedIsKnown then return true end
                  end
             elseif itemType == ITEMTYPE_CRAFTED_ABILITY_SCRIPT and specializedItemType == SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY_SCRIPT_TERTIARY then
                 if PA.Libs.CharacterKnowledge.IsInstalled() and PA.Libs.CharacterKnowledge.IsEnabled() then
                      local known = IsScribingScriptKnown(itemLink)
                      if deposit == true then -- Deposit
                          if known == expectedIsKnown or known ~= expectedIsKnown and PA.Libs.CharacterKnowledge.DoesCharacterNeed(itemLink) ~= expectedIsKnown then
                              return true
                          end
                      else -- Withdraw
                          if known == expectedIsKnown and PA.Libs.CharacterKnowledge.DoesCharacterNeed(itemLink) ~= expectedIsKnown then
                              return true
                          end
                      end
                  else -- Default Behavior
                      local known = IsScribingScriptKnown(itemLink)
                      if known == expectedIsKnown then return true end
                  end
            end
        end
        return false
    end

    local _WRIT_ICON_TABLE_CRAFTING_TYPE = {
        ["/esoui/art/icons/master_writ_blacksmithing.dds"] = CRAFTING_TYPE_BLACKSMITHING,
        ["/esoui/art/icons/master_writ_clothier.dds"] = CRAFTING_TYPE_CLOTHIER,
        ["/esoui/art/icons/master_writ_woodworking.dds"] = CRAFTING_TYPE_WOODWORKING,
        ["/esoui/art/icons/master_writ_jewelry.dds"] = CRAFTING_TYPE_JEWELRYCRAFTING,
        ["/esoui/art/icons/master_writ_alchemy.dds"] = CRAFTING_TYPE_ALCHEMY,
        ["/esoui/art/icons/master_writ_enchanting.dds"] = CRAFTING_TYPE_ENCHANTING,
        ["/esoui/art/icons/master_writ_provisioning.dds"] = CRAFTING_TYPE_PROVISIONING,
    }

    local function _getCraftingTypeFromWritItemLink(itemType, specializedItemType, itemLink)
        if itemType == ITEMTYPE_MASTER_WRIT and specializedItemType == SPECIALIZED_ITEMTYPE_MASTER_WRIT then
            local icon = GetItemLinkInfo(itemLink)
            return _WRIT_ICON_TABLE_CRAFTING_TYPE[icon] or CRAFTING_TYPE_INVALID
        end
        return nil
    end

    local function toSet(list)
        if not list or #list == 0 then return list or {} end
        local set = {}
        for _, val in ipairs(list) do
            set[val] = true
        end
        return set
    end

    local holidayWritsSet = toSet(combinedLists.holidayWrits)
    local itemTypesSet = toSet(combinedLists.itemTypes)
    local unknownWritsSet = toSet(combinedLists.unknownWrits)
    local unidentifiedSurveysSet = toSet(combinedLists.unidentifiedSurveys)
    local unopenedTreasuremapsSet = toSet(combinedLists.unopenedTreasuremaps)
    local itemTraitTypesSet = toSet(combinedLists.itemTraitTypes)
    local masterWritCraftingTypesSet = toSet(combinedLists.masterWritCraftingTypes)
    local knownStylePagesSet = toSet(combinedLists.knownStylePages)
    local unknownStylePagesSet = toSet(combinedLists.unknownStylePages)
    local specializedItemTypesSet = toSet(combinedLists.specializedItemTypes)
    local learnableKnownItemTypesSet = toSet(combinedLists.learnableKnownItemTypes)
    local learnableUnknownItemTypesSet = toSet(combinedLists.learnableUnknownItemTypes)
    local learnableKnownSpecializedItemTypesSet = toSet(combinedLists.learnableKnownSpecializedItemTypes)
    local learnableUnknownSpecializedItemTypesSet = toSet(combinedLists.learnableUnknownSpecializedItemTypes)

    local allowedSurveyItemIdsSet = {}
    if combinedLists and combinedLists.surveyMaps then
        for _, itemFilterType in ipairs(combinedLists.surveyMaps) do
            local reports = PAC.BANKING_ADVANCED.SPECIALIZED.SURVEY_REPORTS[itemFilterType]
            if reports then
                for _, id in ipairs(reports) do
                    allowedSurveyItemIdsSet[id] = true
                end
            end
        end
    end

    return function(itemData)
        if IsItemJunk(itemData.bagId, itemData.slotIndex) and excludeJunk then return false end
        if IsItemStolen(itemData.bagId, itemData.slotIndex) then return false end
        if isItemCharacterBound(itemData) then return false end
        if skipItemsWithCustomRule and PA.Banking.hasItemActiveCustomRule(itemData.bagId, itemData.slotIndex) then return false end
        if skipFcoisLocked and PA.Libs.FCOItemSaver.isItemFCOISMoveLocked(itemData.bagId, itemData.slotIndex) then return false end
        local itemId = GetItemId(itemData.bagId, itemData.slotIndex)
        local itemType, specializedItemType = GetItemType(itemData.bagId, itemData.slotIndex)
        if specializedItemType == SPECIALIZED_ITEMTYPE_HOLIDAY_WRIT then
            if holidayWritsSet[specializedItemType] then return true end
        end
        if itemTypesSet[itemType] then return true end
        if unknownWritsSet[itemId] then return true end
        if unidentifiedSurveysSet[itemId] then return true end
        if unopenedTreasuremapsSet[itemId] then return true end
        if specializedItemType == SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT then
            if allowedSurveyItemIdsSet[itemId] then return true end
        end
        local itemTraitType = GetItemTrait(itemData.bagId, itemData.slotIndex)
        if itemTraitTypesSet[itemTraitType] then return true end
        -- calculating the ItemLink is very expensive - only do it at the end when everything else was already checked
        if not itemData.itemLink then itemData.itemLink = GetItemLink(itemData.bagId, itemData.slotIndex) end
        if specializedItemType == SPECIALIZED_ITEMTYPE_MASTER_WRIT then
            local craftingType = _getCraftingTypeFromWritItemLink(itemType, specializedItemType, itemData.itemLink)
            if masterWritCraftingTypesSet[craftingType] then return true end
        end
        if specializedItemType == SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE then 
            if knownStylePagesSet[specializedItemType] then 
                if PA.HelperFunctions.getItemLinkLearnableStatus(itemData.itemLink) == PAC.LEARNABLE.KNOWN then
                    return true
                end
            end
            if unknownStylePagesSet[specializedItemType] then
                if PA.HelperFunctions.getItemLinkLearnableStatus(itemData.itemLink) == PAC.LEARNABLE.UNKNOWN then
                    return true
                end
            end
        end
        if not IsItemLinkContainer(itemData.itemLink) then
            if specializedItemTypesSet[specializedItemType] then return true end
        end
        if learnableKnownItemTypesSet[itemType] then
           if _isItemOfItemTypeAndKnowledge(itemType, specializedItemType, itemData.itemLink, itemType, nil, true) then return true end
        end
        if learnableUnknownItemTypesSet[itemType] then
            if _isItemOfItemTypeAndKnowledge(itemType, specializedItemType, itemData.itemLink, itemType, nil, false) then return true end
        end
        if learnableKnownSpecializedItemTypesSet[specializedItemType] then
           if _isItemOfItemTypeAndKnowledge(itemType, specializedItemType, itemData.itemLink, nil, specializedItemType, true) then return true end
        end
        if learnableUnknownSpecializedItemTypesSet[specializedItemType] then
            if _isItemOfItemTypeAndKnowledge(itemType, specializedItemType, itemData.itemLink, nil, specializedItemType, false) then return true end
        end
        return false
    end
end

---@param itemTypeList table a list of itemTypes to be checked
---@param excludeJunk boolean whether junk items should be excluded
---@param skipItemsWithCustomRule boolean whether items for which a custom rule exists should be skipped
---@return fun(itemData: table) a comparator function that only returns item that match the itemTypes and pass the junk-test
---@param skipFcoisLocked boolean whether items that are 'Locked' by FCOIS should be skipped
local function getItemTypeComparator(itemTypeList, excludeJunk, skipItemsWithCustomRule, skipFcoisLocked)
    local itemTypeSet = {}
    if itemTypeList then
        for _, itemType in ipairs(itemTypeList) do
            itemTypeSet[itemType] = true
        end
    end
    return function(itemData)
        if IsItemStolen(itemData.bagId, itemData.slotIndex) then return false end
        if IsItemJunk(itemData.bagId, itemData.slotIndex) and excludeJunk then return false end
        if isItemCharacterBound(itemData) then return false end
        if skipItemsWithCustomRule and PA.Banking.hasItemActiveCustomRule(itemData.bagId, itemData.slotIndex) then return false end
        if skipFcoisLocked and PA.Libs.FCOItemSaver.isItemFCOISMoveLocked(itemData.bagId, itemData.slotIndex) then return false end
        if itemTypeSet[itemData.itemType] then return true end
        return false
    end
end

---@param itemIdList table a list of itemIds to be checked
---@param excludeJunk boolean whether junk items should be excluded
---@param skipFcoisLocked boolean whether items that are 'Locked' by FCOIS should be skipped
---@return fun(itemData: table) a comparator function that only returns item that match the itemIdList and pass the junk-test
local function getItemIdComparator(itemIdList, excludeJunk, skipFcoisLocked)
    return function(itemData)
        if IsItemStolen(itemData.bagId, itemData.slotIndex) then return false end
        if IsItemJunk(itemData.bagId, itemData.slotIndex) and excludeJunk then return false end
        if isItemCharacterBound(itemData) then return false end
        if skipFcoisLocked and PA.Libs.FCOItemSaver.isItemFCOISMoveLocked(itemData.bagId, itemData.slotIndex) then return false end
        local itemId = GetItemId(itemData.bagId, itemData.slotIndex)
        if itemIdList[itemId] then return true end
        return false
    end
end

---@param paItemIdList table a list of paItemIds to be checked
---@param excludeJunk boolean whether junk items should be excluded
---@param excludeCharacterBound boolean whether character bound items should be excluded
---@param excludeStolen boolean whether stolen items should be excluded
---@param skipFcoisLocked boolean whether items that are 'Locked' by FCOIS should be skipped

---@return fun(itemData: table) a comparator function that only returns item that match the paItemIdList and pass the junk-test
local function getPAItemIdComparator(paItemIdList, excludeJunk, excludeCharacterBound, excludeStolen, skipFcoisLocked)
    return function(itemData)
        if IsItemStolen(itemData.bagId, itemData.slotIndex) and excludeStolen then return false end
        if IsItemJunk(itemData.bagId, itemData.slotIndex) and excludeJunk then return false end
        if isItemCharacterBound(itemData) and excludeCharacterBound then return false end
        if skipFcoisLocked and PA.Libs.FCOItemSaver.isItemFCOISMoveLocked(itemData.bagId, itemData.slotIndex) then return false end
        local paItemId = getPAItemIdentifier(itemData.bagId, itemData.slotIndex)
        if paItemIdList[paItemId] then return true end
        return false
    end
end

---@param skipFcoisLocked boolean whether items that are 'Locked' by FCOIS should be skipped
---@return fun(itemData: table) a comparator function that only returns stolen junk items
local function getStolenJunkComparator(skipFcoisLocked)
    return function(itemData)
        if isItemCharacterBound(itemData) then return false end
        if skipFcoisLocked and PA.Libs.FCOItemSaver.isItemFCOISMoveLocked(itemData.bagId, itemData.slotIndex) then return false end
        local isStolen = IsItemStolen(itemData.bagId, itemData.slotIndex)
        local isJunk = IsItemJunk(itemData.bagId, itemData.slotIndex)
        return isStolen and isJunk
    end
end


-- =================================================================================================================
-- == PLAYER STATES == --
-- -----------------------------------------------------------------------------------------------------------------
---@return boolean whether the player is currently in combat
local function isPlayerInCombat()
    return IsUnitInCombat("player")
end

---@return boolean whether the player is currently dead
local function isPlayerDead()
    return IsUnitDead("player")
end

---@return boolean whether the player is currently dead or reincarnating
local function isPlayerDeadOrReincarnating()
   return IsUnitDeadOrReincarnating("player")
end

---@return string, string the applicable bank bags of the player based on the ESO Plus Subscriber situation
local function getBankBags()
    if IsESOPlusSubscriber() then
	    if PA.Banking.currentBankBag and PA.Banking.currentBankBag ~= BAG_BANK then
		    return PA.Banking.currentBankBag
        else
            return BAG_BANK, BAG_SUBSCRIBER_BANK
		end
    else
	    if PA.Banking.currentBankBag and PA.Banking.currentBankBag ~= BAG_BANK then
		    return PA.Banking.currentBankBag
        else
            return BAG_BANK
		end
    end
end

---@return string, string, string the applicable bags the player currently has access to (BAG_BACKPACK always, BAG_BANK and BAG_SUBSCRIBER_BANK only when bank open)
local function getAccessibleBags()
    if IsBankOpen() then
        return BAG_BACKPACK, getBankBags()
    end
    return BAG_BACKPACK
end


-- =================================================================================================================
-- == GAME STATES == --
-- -----------------------------------------------------------------------------------------------------------------

local function isAlwaysKeyboardMode()
    local gamepadModeSetting = GetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_INPUT_PREFERRED_MODE)
    return gamepadModeSetting == tostring(INPUT_PREFERRED_MODE_ALWAYS_KEYBOARD)
end

-- =================================================================================================================
-- == PROTECTED FUNCTIONS == --
-- -----------------------------------------------------------------------------------------------------------------

local function attemptToUseItem(bagId, slotIndex)
    local usable, onlyFromActionSlot = IsItemUsable(bagId, slotIndex)
    if usable and not onlyFromActionSlot and not isPlayerInCombat() then
        if IsProtectedFunction("UseItem") then
            CallSecureProtected("UseItem", bagId, slotIndex)
        else
            UseItem(bagId, slotIndex)
        end
        return true
    end
    return false
end

local function attemptToRequestMoveItem(sourceBag, sourceSlot,destBag, destSlot, stackCount)
    if IsProtectedFunction("RequestMoveItem") then
        CallSecureProtected("RequestMoveItem", sourceBag, sourceSlot, destBag, destSlot, stackCount)
    else
        RequestMoveItem(sourceBag, sourceSlot, destBag, destSlot, stackCount)
    end
end


-- =================================================================================================================
-- == TEXT / NUMBER TRANSFORMATIONS == --
-- -----------------------------------------------------------------------------------------------------------------
--- returns a noun for the bagId
---@param bagId number the id of the bag
---@return string the name of the bag
local function getBagName(bagId)
    if bagId == BAG_WORN then
        return GetString(SI_PA_NS_BAG_EQUIPMENT)
    elseif bagId == BAG_BACKPACK then
        return GetString(SI_PA_NS_BAG_BACKPACK)
    elseif bagId == BAG_BANK then
        return GetString(SI_PA_NS_BAG_BANK)
    elseif bagId == BAG_SUBSCRIBER_BANK then
        return GetString(SI_PA_NS_BAG_SUBSCRIBER_BANK)
    elseif bagId == BAG_VIRTUAL then
        return GetString(SI_PA_NS_BAG_VIRTUAL)
    elseif bagId == BAG_HOUSE_BANK_ONE or bagId == BAG_HOUSE_BANK_TWO or bagId == BAG_HOUSE_BANK_THREE or bagId == BAG_HOUSE_BANK_FOUR
        or bagId == BAG_HOUSE_BANK_FIVE or bagId == BAG_HOUSE_BANK_SIX or bagId == BAG_HOUSE_BANK_SEVEN or bagId == BAG_HOUSE_BANK_EIGHT
        or bagId == BAG_HOUSE_BANK_NINE or bagId == BAG_HOUSE_BANK_TEN then
		local name = GetCollectibleNickname(GetCollectibleForHouseBankBag(bagId))
	    if name == "" then
		   name = GetCollectibleName(GetCollectibleForHouseBankBag(bagId))
	    end
        return name
    elseif bagId == BAG_FURNITURE_VAULT then
        return GetString(SI_HOUSINGFURNITURELOCATIONFILTER32)
    else
        return GetString(SI_PA_NS_BAG_UNKNOWN)
    end
end


-- =================================================================================================================
-- == TEXT FORMATTING AND OUTPUT == --
-- -----------------------------------------------------------------------------------------------------------------

---- Formats the provided currency amount with an icon based on the type
---@param currencyAmount number the amount that should be formatted (can be negative)
---@param currencyType string the type of currency (default = CURT_MONEY)
---@param noColor boolean if set to true the amount-text will not be colored (default = false)
---@return string the formatted text with currency icon
local function getFormattedCurrency(currencyAmount, currencyType, noColor)
    local currencyType = currencyType or CURT_MONEY
    local noColor = noColor or false
    local formatType = ZO_CURRENCY_FORMAT_AMOUNT_ICON
    local extraOptions = {}
    if currencyAmount < 0 then
        -- negative amount
        if not noColor then formatType = ZO_CURRENCY_FORMAT_ERROR_AMOUNT_ICON end
        currencyAmount = currencyAmount * -1 -- need to make it a positive number again
    else
        -- positive amount
        if not noColor then extraOptions = { color = PAC.COLOR.GREEN } end
    end
    return zo_strformat(SI_NUMBER_FORMAT, ZO_Currency_FormatKeyboard(currencyType, currencyAmount, formatType, extraOptions))
end

--- Formats the provided currency amount without icon based on the type
---@param currencyAmount string the amount that should be formatted
---@param currencyType string the type of currency (default = CURT_MONEY)
---@return string the formatted text text without currency icon
---@return string the formatted currency (amount + type)
local function getFormattedCurrencySimple(currencyAmount, currencyType)
    local curType = currencyType or CURT_MONEY
    if currencyAmount < 0 then currencyAmount = currencyAmount * -1 end  -- need to make it a positive number again
    local currencyAmountFmt = zo_strformat(SI_NUMBER_FORMAT, ZO_LocalizeDecimalNumber(currencyAmount))
    local currencyColor = PAC.COLOR.CURRENCIES[curType]
    if currencyColor and currencyColor.Colorize then
        return currencyColor:Colorize(currencyAmountFmt)
    end
    return currencyAmountFmt
end

--- returns a fixed/formatted ItemLink
--- needed as the regular GetItemLink sometimes(?) returns lower-case only texts
---@param bagId number the id of the bag
---@param slotIndex number the id of the slot within the
---@return string the formatted itemLink
local function getFormattedItemLink(bagId, slotIndex)
    local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
    if itemLink == "" then return "[unknown]" end
    local itemName = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemName(bagId, slotIndex))
    local itemData = itemLink:match("|H.-:(.-)|h")
    return zo_strformat(SI_TOOLTIP_ITEM_NAME, (("|H%s:%s|h[%s]|h"):format(LINK_STYLE_BRACKETS, itemData, itemName)))
end

--- Formats a string with support for proper UTF-8 character handling
--- This function ensures that UTF-8 characters are properly counted when formatting strings
--- @param formatString string The format string with standard Lua formatting specifiers
--- @param ... any The values to format into the format string
--- @return string formatedString The formatted string with proper UTF-8 handling
local function utf8format(formatString, ...)
    -- Safety check for nil format string
    if not formatString then
        return ""
    end
    
    local args = { ... }
    local argCount = select("#", ...)
    
    -- Handle simple cases directly when no string formatting is needed
    if argCount == 0 then
        return formatString
    end
    
    -- First try standard string.format with pcall for safety
    local success, result = pcall(function()
        return string.format(formatString, unpack(args, 1, argCount))
    end)
    
    if success then
        return result
    end
    
    -- If standard formatting fails, try a more robust approach
    
    -- First, check if we have access to ustring library's format function
    -- This is the ideal case since ustring handles UTF-8 properly
    if ustring and ustring.format then
        local success, result = pcall(function()
            return ustring.format(formatString, unpack(args, 1, argCount))
        end)
        
        if success then
            return result
        end
    end
    
    -- Fallback with manual specifier processing if ustring.format failed or isn't available
    
    -- Step 1: Find all format specifiers and their positions
    local specifiers = {}
    local pattern = "%%([%d%.%-+# ]*)([cdeEfgGioupsqxX])"
    
    local pos = 1
    while pos <= #formatString do
        local start, finish, flags, specifier = formatString:find(pattern, pos)
        if not start then break end
        
        table.insert(specifiers, {
            start = start,
            finish = finish,
            flags = flags,
            specifier = specifier
        })
        
        pos = finish + 1
    end
    
    -- Step 2: Replace each specifier with its formatted value
    local result = formatString
    local offset = 0
    
    for i, spec in ipairs(specifiers) do
        local value = i <= argCount and args[i] or nil
        local formattedValue
        
        if spec.specifier == 's' and type(value) == "string" then
            -- For strings, preserve UTF-8
            if ustring and ustring.len and ustring.isutf8 and ustring.isutf8(value) then
                -- For valid UTF-8 strings, use directly
                formattedValue = value
            else
                -- For non-UTF-8 strings or when ustring isn't available
                formattedValue = tostring(value or "")
            end
        elseif spec.specifier == 'd' or spec.specifier == 'i' or spec.specifier == 'u' then
            -- Integer formatting
            formattedValue = tostring(math.floor(tonumber(value) or 0))
        elseif spec.specifier == 'f' or spec.specifier == 'g' or spec.specifier == 'e' or
               spec.specifier == 'E' or spec.specifier == 'G' then
            -- Float formatting (could add precision handling based on flags)
            formattedValue = tostring(tonumber(value) or 0.0)
        else
            -- Other format types, just convert to string
            formattedValue = tostring(value or "")
        end
        
        -- Calculate the replacement position accounting for previous replacements
        local startPos = spec.start + offset
        local endPos = spec.finish + offset
        
        -- Replace the format specifier with the value
        result = result:sub(1, startPos - 1) .. formattedValue .. result:sub(endPos + 1)
        
        -- Adjust offset for subsequent replacements
        offset = offset + #formattedValue - (endPos - startPos + 1)
    end
    
    return result
end

--- Formats text with placeholders, with special handling for UTF-8 in Chinese language
--- @param text string the text with placeholders to be filled by the varargs
--- @param ... any the values to be put in the placeholders of the text
--- @return string formattedText the formatted text
local function getFormattedText(text, ...)
    local args = { ... }
    local formattedText = ""
    
    -- Safety check for nil text
    if not text then
        return ""
    end
    
    -- Always use utf8format for Chinese language or when we detect UTF-8 characters
    if GetCVar("language.2") == "zh" or (ZoGetOfficialGameLanguage and ZoGetOfficialGameLanguage() == OFFICIAL_LANGUAGE_CHINESE_S) or
       (ustring and ustring.isutf8 and ustring.isutf8(text) and text:find("[\128-\255]")) then
        -- Use our utf8format function for proper UTF-8 handling
        formattedText = utf8format(text, unpack(args))
    else
        -- Try-catch for standard formatting to handle mismatched specifiers
        local success, result = pcall(function() 
            return string.format(text, unpack(args)) 
        end)
        
        if success then
            formattedText = result
        else
            -- If standard format fails, use our more robust utf8format
            formattedText = utf8format(text, unpack(args))
        end
    end
    
    -- Fall back to the original text if formatting produced an empty string
    if formattedText == "" then
        formattedText = text
    end
    
    return formattedText
end


---@param key string a label-key from the localization
---@vararg any the values to be put in the placeholders of the resolved key
---@return void
local function getFormattedKey(key, ...)
    local text = GetString(key)
    return getFormattedText(text, ...)
end

--- currently supports one text and n arguments
---@alias LibChatMessage
---@param lcmChat LibChatMessage the instance of LibChatMessage
---@param prefix string the prefix for the chat message
---@param text string the actual chat message
---@vararg any values to be put in the placeholders of the text
---@return void
local function println(lcmChat, prefix, text, ...)
    local textKey = GetString(text)
    local prefix = prefix or ""

    -- check if LibChatMessage is running and if a valid "chat" is provided
    if PA.LibChatMessage and lcmChat then
        if textKey ~= nil and textKey ~= "" then
            lcmChat:Print(getFormattedText(textKey, ...))
        else
            lcmChat:Print(getFormattedText(text, ...))
        end
    else
        -- otherwise stick to the old "debug solution"
        if textKey ~= nil and textKey ~= "" then
            CHAT_SYSTEM:AddMessage(table.concat({prefix, ": ", getFormattedText(textKey, ...)}))
        else
            CHAT_SYSTEM:AddMessage(table.concat({prefix, ": ", getFormattedText(text, ...)}))
        end
    end
end

--- write the provided key/text into the debug Output window (WHITE font)
---@param addonName string the name of the addon that sends the debug message
---@param prefix string the prefix for the debug message
---@param text string the actual debug message
---@vararg any values to be put in the placeholders of the debug-text
---@return void
local function debugln(addonName, prefix, text, ...)
    if PA.debug then
        local textKey = GetString(text)
        local addonName = addonName or ""
        local prefix = prefix or ""

        if textKey ~= nil and textKey ~= "" then
            PA.DebugWindow.printToDebugOutputWindow(addonName, table.concat({prefix, ": ", getFormattedText(textKey, ...)}))
        else
            PA.DebugWindow.printToDebugOutputWindow(addonName, table.concat({prefix, ": ", getFormattedText(text, ...)}))
        end
    end
end

--- the same like println, except that it is only printed for the addon author (i.e. charactername = Klingo)
---@param key string a label-key from the localization
---@vararg any values to be put in the placeholders of the debug-text
---@return void
local function debuglnAuthor(key, ...)
    if GetUnitName("player") == PAC.ADDON.AUTHOR then
        println(PA.chat, "", key, ...)
    end
end


-- =================================================================================================================
-- == PROFILES == --
-- -----------------------------------------------------------------------------------------------------------------

--- returns the default profile name of the provided profile number
---@param profileNo number the number/id of a profile
---@return string the name of the profile
local function getDefaultProfileName(profileNo)
    return table.concat({GetString(SI_PA_PROFILE), " ", profileNo})
end

--- Source: https://wiki.esoui.com/IsAddonRunning
---@param addonName string name of the addon
---@return boolean whether the addon is running
local _addonRunningCache = {}
local function isAddonRunning(addonName)
    if _addonRunningCache[addonName] ~= nil then
        return _addonRunningCache[addonName]
    end
    local manager = GetAddOnManager()
    for i = 1, manager:GetNumAddOns() do
        local name, _, _, _, _, state = manager:GetAddOnInfo(i)
        if name == addonName then
            local isRunning = (state == ADDON_STATE_ENABLED)
            _addonRunningCache[addonName] = isRunning
            return isRunning
        end
    end
    _addonRunningCache[addonName] = false
    return false
end


-- =================================================================================================================
-- == ITEM LINKS == --
-- -----------------------------------------------------------------------------------------------------------------

---@param itemLink string the itemLink to be checked
---@return boolean if the item is character boudn or not
local function isItemLinkCharacterBound(itemLink)
    local isBound = IsItemLinkBound(itemLink)
    if isBound then
        local bindType = GetItemLinkBindType(itemLink)
        return bindType == BIND_TYPE_ON_PICKUP_BACKPACK
    end
    return false
end


---@param itemLink string the itemLink to be checked
---@return boolean if the item has the Intricate trait
local function isItemLinkIntricateTraitType(itemLink)
    local itemTraitInformation = GetItemTraitInformationFromItemLink(itemLink)
    return itemTraitInformation == ITEM_TRAIT_INFORMATION_INTRICATE
end

---@param itemLink string the itemLink to be checked
---@return boolean if the item has the Ornate trait
local function isItemLinkOrnateTraitType(itemLink)
    local itemTraitInformation = GetItemTraitInformationFromItemLink(itemLink)
    return itemTraitInformation == ITEM_TRAIT_INFORMATION_ORNATE
end

---@param itemLink string the itemLink to be checked
---@return string the itemLink with the matching Intricate/Stolen icon added on the right side
local function getIconExtendedItemLink(itemLink)
    -- check if it is stolen or of type [Intricate]
    local itemStolen = IsItemLinkStolen(itemLink)
    local intricateTrait = isItemLinkIntricateTraitType(itemLink)

    -- prepare additional icons if needed
    local itemLinkExt = itemLink
    if intricateTrait then itemLinkExt = table.concat({itemLinkExt, " ", PAC.ICONS.ITEMS.TRAITS.INTRICATE.SMALL}) end
    if itemStolen then itemLinkExt = table.concat({itemLinkExt, " ", PAC.ICONS.ITEMS.STOLEN.SMALL}) end
    return itemLinkExt
end

--- Checks the itemLink if it is known (recipes and motifs), researched (item traits), or already added to collection (style pages and containers)
---@param itemLink string the itemLink to be checked
---@return string Constants.LEARNABLE.KNOWN, Constants.LEARNABLE.KNOWN or nil if there is no known/unknown status
local function getItemLinkLearnableStatus(itemLink) 
    local itemType, specializedItemType = GetItemLinkItemType(itemLink)
    local itemFilterType = GetItemLinkFilterTypeInfo(itemLink)
	local itemUseType = GetItemLinkItemUseType(itemLink)
	
    if isItemLinkForCompanion(itemLink) then return nil end
    if itemType == ITEMTYPE_RECIPE then
        if IsRecipeKnown(itemLink) then
             return PAC.LEARNABLE.KNOWN
        elseif PA.Libs.CharacterKnowledge.IsInstalled() and PA.Libs.CharacterKnowledge.IsEnabled() then
             if PA.Libs.CharacterKnowledge.DoesCharacterNeed(itemLink) then
                 return PAC.LEARNABLE.UNKNOWN
             else
                 return PAC.LEARNABLE.OTHERUNKNOWN
             end
        else
             return PAC.LEARNABLE.UNKNOWN
        end
    elseif itemType == ITEMTYPE_RACIAL_STYLE_MOTIF then
        if IsBookKnown(itemLink) then
             return PAC.LEARNABLE.KNOWN
        elseif PA.Libs.CharacterKnowledge.IsInstalled() and PA.Libs.CharacterKnowledge.IsEnabled() then
             if PA.Libs.CharacterKnowledge.DoesCharacterNeed(itemLink) then
                 return PAC.LEARNABLE.UNKNOWN
             else
                 return PAC.LEARNABLE.OTHERUNKNOWN
             end
        else
            return PAC.LEARNABLE.UNKNOWN
        end
    -- Scribing Grimoires
 	elseif itemType == ITEMTYPE_CRAFTED_ABILITY then
         if IsScribingGrimoireKnown(itemLink) then
              return PAC.LEARNABLE.KNOWN
         elseif PA.Libs.CharacterKnowledge.IsInstalled() and PA.Libs.CharacterKnowledge.IsEnabled() then
              if PA.Libs.CharacterKnowledge.DoesCharacterNeed(itemLink) then
                  return PAC.LEARNABLE.UNKNOWN
              else
                  return PAC.LEARNABLE.OTHERUNKNOWN
              end
         else
             return PAC.LEARNABLE.UNKNOWN
        end
	-- Scribing Focus Scripts
 	elseif itemType == ITEMTYPE_CRAFTED_ABILITY_SCRIPT and specializedItemType == SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY_SCRIPT_PRIMARY then
         if IsScribingScriptKnown(itemLink) then
              return PAC.LEARNABLE.KNOWN
         elseif PA.Libs.CharacterKnowledge.IsInstalled() and PA.Libs.CharacterKnowledge.IsEnabled() then
              if PA.Libs.CharacterKnowledge.DoesCharacterNeed(itemLink) then
                  return PAC.LEARNABLE.UNKNOWN
              else
                  return PAC.LEARNABLE.OTHERUNKNOWN
              end
         else
             return PAC.LEARNABLE.UNKNOWN
        end
    -- Scribing Signature Scripts
 	elseif itemType == ITEMTYPE_CRAFTED_ABILITY_SCRIPT and specializedItemType == SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY_SCRIPT_SECONDARY then
         if IsScribingScriptKnown(itemLink) then
              return PAC.LEARNABLE.KNOWN
         elseif PA.Libs.CharacterKnowledge.IsInstalled() and PA.Libs.CharacterKnowledge.IsEnabled() then
              if PA.Libs.CharacterKnowledge.DoesCharacterNeed(itemLink) then
                  return PAC.LEARNABLE.UNKNOWN
              else
                  return PAC.LEARNABLE.OTHERUNKNOWN
              end
         else
             return PAC.LEARNABLE.UNKNOWN
         end
		
    -- Scribing Affix Scripts
 	elseif itemType == ITEMTYPE_CRAFTED_ABILITY_SCRIPT and specializedItemType == SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY_SCRIPT_TERTIARY then
         if IsScribingScriptKnown(itemLink) then
              return PAC.LEARNABLE.KNOWN
         elseif PA.Libs.CharacterKnowledge.IsInstalled() and PA.Libs.CharacterKnowledge.IsEnabled() then
              if PA.Libs.CharacterKnowledge.DoesCharacterNeed(itemLink) then
                  return PAC.LEARNABLE.UNKNOWN
              else
                  return PAC.LEARNABLE.OTHERUNKNOWN
              end
         else
             return PAC.LEARNABLE.UNKNOWN
         end
  elseif itemFilterType == ITEMFILTERTYPE_ARMOR or itemFilterType == ITEMFILTERTYPE_WEAPONS or itemFilterType == ITEMFILTERTYPE_JEWELRY then
         local itemTraitType = GetItemLinkTraitType(itemLink)
         -- only check for the research status if it has a traitType and if it is not Ornate or Intricate
         if itemTraitType == ITEM_TRAIT_TYPE_NONE or
                 itemTraitType == ITEM_TRAIT_TYPE_ARMOR_ORNATE or itemTraitType == ITEM_TRAIT_TYPE_JEWELRY_ORNATE or itemTraitType == ITEM_TRAIT_TYPE_WEAPON_ORNATE or
                 itemTraitType == ITEM_TRAIT_TYPE_ARMOR_INTRICATE or itemTraitType == ITEM_TRAIT_TYPE_JEWELRY_INTRICATE or itemTraitType == ITEM_TRAIT_TYPE_WEAPON_INTRICATE then
             return nil
         end
         if CanItemLinkBeTraitResearched(itemLink) then return PAC.LEARNABLE.UNKNOWN end
         return PAC.LEARNABLE.KNOWN
  elseif specializedItemType == SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE or specializedItemType == SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE or specializedItemType == SPECIALIZED_ITEMTYPE_CONTAINER then
         local containerCollectibleId = GetItemLinkContainerCollectibleId(itemLink)
         local collectibleName = GetCollectibleName(containerCollectibleId)
         if collectibleName ~= nil and collectibleName ~= "" then
             local isValidForPlayer = IsCollectibleValidForPlayer(containerCollectibleId)
             if isValidForPlayer then
                 local isUnlocked = IsCollectibleUnlocked(containerCollectibleId)
                 if isUnlocked then return PAC.LEARNABLE.KNOWN end
                 return PAC.LEARNABLE.UNKNOWN
             end
         end	 
    end
    -- itemLink is neither known, nor unknown (not learnable or researchable)
    return nil
end

-- Export
PA.HelperFunctions = {
    IsBookKnown = IsBookKnown,
    IsRecipeKnown = IsRecipeKnown,
	  IsScribingScriptKnown = IsScribingScriptKnown,
	  IsScribingGrimoireKnown = IsScribingGrimoireKnown,
    round = round,
    roundDown = roundDown,
    isValueInTable = isValueInTable,
    isKeyInTable = isKeyInTable,
    getPAItemLinkIdentifier = getPAItemLinkIdentifier,
    getPAItemIdentifier = getPAItemIdentifier,
    isItemForCompanion = isItemForCompanion,
    isItemLinkForCompanion = isItemLinkForCompanion,
    CanItemBeMarkedAsJunkExt = CanItemBeMarkedAsJunkExt,
    isItemCharacterBound = isItemCharacterBound,
    getCombinedItemTypeSpecializedComparator = getCombinedItemTypeSpecializedComparator,
    getItemTypeComparator = getItemTypeComparator,
    getItemIdComparator = getItemIdComparator,
    getPAItemIdComparator = getPAItemIdComparator,
    getStolenJunkComparator = getStolenJunkComparator,
    isPlayerInCombat = isPlayerInCombat,
    isPlayerDead = isPlayerDead,
    isPlayerDeadOrReincarnating = isPlayerDeadOrReincarnating,
    getAccessibleBags = getAccessibleBags,
    isAlwaysKeyboardMode = isAlwaysKeyboardMode,
    attemptToUseItem = attemptToUseItem,
    attemptToRequestMoveItem = attemptToRequestMoveItem,
    getBankBags = getBankBags,
    getBagName = getBagName,
    getFormattedCurrency = getFormattedCurrency,
    getFormattedCurrencySimple = getFormattedCurrencySimple,
    getFormattedItemLink = getFormattedItemLink,
    getFormattedText = getFormattedText,
    getFormattedKey = getFormattedKey,
    println = println,
    debugln = debugln,
    debuglnAuthor = debuglnAuthor,
    getDefaultProfileName = getDefaultProfileName,
    isAddonRunning = isAddonRunning,
    isItemLinkCharacterBound = isItemLinkCharacterBound,
    isItemLinkIntricateTraitType = isItemLinkIntricateTraitType,
    isItemLinkOrnateTraitType = isItemLinkOrnateTraitType,	
    getIconExtendedItemLink = getIconExtendedItemLink,
    getItemLinkLearnableStatus = getItemLinkLearnableStatus
}