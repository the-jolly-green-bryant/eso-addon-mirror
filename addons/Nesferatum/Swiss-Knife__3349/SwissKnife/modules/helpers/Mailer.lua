local SK = SwissKnife
local SKH = SK.HelperFunctions
local SKDI = SK.Data.itemsData

local function isSmartSend(itemLink)
    local itemType = GetItemLinkItemType(itemLink)
    local _, _, _, _, itemStyle = GetItemLinkInfo(itemLink)
    local traitType, _ = GetItemLinkTraitInfo(itemLink)
    if ((itemType == ITEMTYPE_ARMOR_TRAIT or itemType == ITEMTYPE_WEAPON_TRAIT)
            and SKH.isValueInList(SKDI.ITEM_WORTHLESS_TRAIT, traitType)) or
        (itemType == ITEMTYPE_STYLE_MATERIAL and SKH.isValueInList(SKDI.ITEM_WORTHLESS_RACIAL, itemStyle))
    then
        return false
    else
        return true
    end
end

local function isItemMustBeSendByEmail(itemLink)
    local isBound = IsItemLinkBound(itemLink)
    local isStolen = IsItemLinkStolen(itemLink)
    if isBound or isStolen then return false end
    local itemQuality = GetItemLinkFunctionalQuality(itemLink)
    local itemType = GetItemLinkItemType(itemLink)
    local traitType = GetItemLinkTraitInfo(itemLink)
    local itemTypesResources = SKDI.ITEM_TYPES[SK.ATTACHMENT_TYPES.RESOURCES]
    local itemTypesIntricate = SKDI.ITEM_TYPES[SK.ATTACHMENT_TYPES.INTRICATE]
    local itemTypesGlyphs = SKDI.ITEM_TYPES[SK.ATTACHMENT_TYPES.GLYPHS]
    local resourcesOptions = SK.savedVars.sendMailByTypeOptions[SK.ATTACHMENT_TYPES.RESOURCES]
    local intricateOptions = SK.savedVars.sendMailByTypeOptions[SK.ATTACHMENT_TYPES.INTRICATE]
    local glyphsOptions = SK.savedVars.sendMailByTypeOptions[SK.ATTACHMENT_TYPES.GLYPHS]
    local accName = SK.AccName
    if not SK.HasOneServer then
        accName = zo_strsplit(" ", accName)
    end
    if SKH.isValueInList(itemTypesResources, itemType) and resourcesOptions.recipient ~= "" and
            resourcesOptions.recipient ~= accName and itemQuality <= resourcesOptions.quality and
        ((resourcesOptions.isSmartSendEnabled and isSmartSend(itemLink)) or not resourcesOptions.isSmartSendEnabled)
    then
        return true, SK.ATTACHMENT_TYPES.RESOURCES
    elseif SKH.isValueInList(itemTypesIntricate, traitType) and intricateOptions.recipient ~= "" and
            intricateOptions.recipient ~= accName and traitType and ((intricateOptions.isJewelryExclude and
            traitType ~= ITEM_TRAIT_TYPE_JEWELRY_INTRICATE) or not intricateOptions.isJewelryExclude)
    then
        return true, SK.ATTACHMENT_TYPES.INTRICATE
    elseif SKH.isValueInList(itemTypesGlyphs, itemType) and glyphsOptions.recipient ~= "" and
            glyphsOptions.recipient ~= accName and itemQuality <= glyphsOptions.quality
    then
        return true, SK.ATTACHMENT_TYPES.GLYPHS
    end
    return false
end

local function getChoicesWhoMust()
    local choices = {
        GetString(SI_SK_AUT_MAILER_AUTO_LOOT_WHO_CAN_NO_ONE_NAME),
        GetString(SI_SK_AUT_MAILER_AUTO_LOOT_WHO_CAN_ANYONE_NAME)
    }
    local mapping = {
        [GetString(SI_SK_AUT_MAILER_AUTO_LOOT_WHO_CAN_NO_ONE_NAME)] = SK.WHO_MUST_RECEIPT_DATA.NO_ONE,
        [GetString(SI_SK_AUT_MAILER_AUTO_LOOT_WHO_CAN_ANYONE_NAME)] = SK.WHO_MUST_RECEIPT_DATA.ANYONE,
    }
    local reverseMapping = {
        [SK.WHO_MUST_RECEIPT_DATA.NO_ONE] = GetString(SI_SK_AUT_MAILER_AUTO_LOOT_WHO_CAN_NO_ONE_NAME),
        [SK.WHO_MUST_RECEIPT_DATA.ANYONE] = GetString(SI_SK_AUT_MAILER_AUTO_LOOT_WHO_CAN_ANYONE_NAME),
    }
    if SK.AccountsCharacters[SK.AccName] then
        for character, _ in pairs(SK.AccountsCharacters[SK.AccName]) do
            table.insert(choices, character)
            mapping[character] = character
            reverseMapping[character] = character
        end
    end
    return choices, mapping, reverseMapping
end

local function isReceiptMailAllow()
    if IsESOPlusSubscriber() then return true end
    if SK.savedVars.useAutomaticReceiptWhenESOPlusOnly then return false end
    local characterChoice = SK.savedVars.whoMustReceiptMailWithoutESOPlus[SK.AccName]
    if not characterChoice then return false end
    if characterChoice == SK.WHO_MUST_RECEIPT_DATA.NO_ONE then return false end
    if characterChoice == SK.WHO_MUST_RECEIPT_DATA.ANYONE then return true end
    return characterChoice == SK.PlayerName
end

local function filterAllBackpackAttachments()
    local attachments = {}
    if SK.savedVars.sendMailToAnotherAccount then
        local slotsCount = GetBagSize(BAG_BACKPACK)
        local itemLink, isItemMustBeSend, itemType
        for slotIndex = 0, slotsCount - 1 do
            if not IsItemPlayerLocked(BAG_BACKPACK, slotIndex) then
                itemLink = GetItemLink(BAG_BACKPACK, slotIndex)
                isItemMustBeSend, itemType = isItemMustBeSendByEmail(itemLink)
                if isItemMustBeSend then
                    if attachments[itemType] == nil then
                        attachments[itemType] = {}
                    end
                    table.insert(attachments[itemType], slotIndex)
                end
            end
        end
    end
    return attachments
end

-- Export helper functions
SK.HelperFunctions.isItemMustBeSendByEmail = isItemMustBeSendByEmail
SK.HelperFunctions.getChoicesWhoMust = getChoicesWhoMust
SK.HelperFunctions.isReceiptMailAllow = isReceiptMailAllow
SK.HelperFunctions.filterAllBackpackAttachments = filterAllBackpackAttachments
