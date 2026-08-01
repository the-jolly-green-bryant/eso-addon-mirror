WishList = WishList or {}
local WL = WishList

--[[
-- ==================Changelog===================

-- ==================Error messages===================
]]

--Local speedup variables for lua functions
local tos = tostring

--Local WishList name etc.
local addonVars = WL.addonVars
local wlName = addonVars.addonName

--LibSets
local libSets = WL.LibSets
local isCraftedSet = libSets.IsCraftedSet --needs to be updated as LibSets was loaded properly
local libSetsCraftedUpdated = false

--> Taken from addon DolgubonLazyWritCretaor to speed up the loot messages!
--The flavour text of a writ reward box
local writRewardContainerFlavText = GetItemLinkFlavorText("|H1:item:121302:175:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h")
--The flavour text of a writ reward box's content with materials (another box)
local writRewardContainerContentContainerFlavText = GetItemLinkFlavorText("|H1:item:99256:3:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h")
local allowedItemTypes = WL.checkItemTypes
WL.comingFromSortScrollListSetupFunction = false

--Start data of addon
WL.CurrentState = WISHLIST_TAB_STATE_NO_SETS 	    --1=NoSets, 2=Loading, 3=SetsLoaded
WL.CurrentTab   = WISHLIST_TAB_SEARCH               --1=Search, 2=WishList
WL.CurrentCharData = {}
WL.LoggedInCharData = {}
WL.sortType = 1
WL.firstWishListCall = false

WL.fallbackSetLang = "en" -- the fallback language for the setNames if the clientLanguage is not supported within LibSets

WL.invSingleSlotUpdateData = {}
WL.debug = false

--SavedVars
WL.data = {}
WL.accData = {}
WL.initDone = false

--Other addons
WL.otherAddons = {}
WL.otherAddons.LazyWritCreatorActive = false

--Preventing variables
WL.preventerVars = {}
WL.preventerVars.addonMenuBuild = false
WL.preventerVars.writCreatorAutoLootBoxesActive = false
WL.preventerVars.runSetNameLanguageChecks = false
WL.maxNameColumnWidth = nil

--Local speed-up function pointer
local getSavedVarsServer = WL.getSavedVarsServer
local getSetItemSlotKey = WL.getSetItemSlotKey
local WL_getGearMarkerTexture = WL.getGearMarkerTexture

------------------------------------------------
--- Event Handlers
------------------------------------------------
local function checkAntiLootDisableTime(disable)
    --Checked in EVENT_SINGLE_SLOT_UPDATE: If the addon DolgubonsLazyWritCreator is active and should autoloot the writ reward containers:
    --This funciton will reset the anti-loot-check variable after 3 seconds, or increase the timer by 3 seconds
    --so the looted containers are not checked against set items and the unneeded scans stress the client this way
    disable = disable or false
    local antiLootUpdaterName = wlName .. "_DisableAntiLootTimer"
    EVENT_MANAGER:UnregisterForUpdate(antiLootUpdaterName)
    if disable then return false end
    --If anti loot flag is not enabled, abort now
    if not WL.preventerVars.writCreatorAutoLootBoxesActive then return false end

    --Remove anti loot flag after 3 seconds again
    EVENT_MANAGER:RegisterForUpdate(antiLootUpdaterName, 3000, function()
--d(">Disabling the anti loot again now!")
        WL.preventerVars.writCreatorAutoLootBoxesActive = false
        checkAntiLootDisableTime(true)
    end)
end

--EVENT_INVENTORY_SINGLE_SLOT_UPDATE (number eventCode, Bag bagId, number slotId, boolean isNewItem, ItemUISoundCategory itemSoundCategory, number inventoryUpdateReason, number stackCountChange)
function WL.Inv_Single_Slot_Update(_, bagId, slotId, isNewItem, _, inventoryUpdateReason, _, debug)
    debug = debug or false
    if inventoryUpdateReason ~= INVENTORY_UPDATE_REASON_DEFAULT then return false end
    if debug then d("[WL.Inv_Single_Slot_Update] " .. GetItemLink(bagId, slotId) .. ", isNew: " .. tos(isNewItem)) end
    if not isNewItem then return false end
    --Abort here if we are arrested by a guard (thief system) as it will scan our inventory for stolen items and destroy them.
    --We don't need to scan it with our functions too at this case
    if IsUnderArrest() then return end
    --Do not execute if horse is changed
    if SCENE_MANAGER:GetCurrentScene() == STABLES_SCENE then return end
    --Check if item in slot is still there
    if GetItemType(bagId, slotId) == ITEMTYPE_NONE then return end
    --Save the current bagId and slotIndex with the itemLink to internal WishList temp data so the LootReceived event can use it
    if ((not debug and bagId == BAG_BACKPACK) or debug) then
        local itemLink = GetItemLink(bagId, slotId)
        if itemLink then
            WL.invSingleSlotUpdateData = WL.invSingleSlotUpdateData or {}
            WL.invSingleSlotUpdateData[itemLink] = slotId
            if debug then d("[WishList]" .. itemLink .. " - Inv_Single_Slot_Update: Set the slotId " ..tos(slotId) .. " to the WL internal variables!") end
        end
    end
    --Are we in simulation mode or is DolgubonsLazyWritCreatorAddon not active? Abort here then
    if debug or not WL.otherAddons.LazyWritCreatorActive then return false end
    --Is the automatic opening of the writ container rewards active?
    if WritCreater and WritCreater.savedVars and WritCreater.savedVars.lootContainerOnReceipt then
        --d(">Writ creator active and settings = auto loot container")
        --Is the setting within the addon active to auto loot the boxes?
        local autoLoot
        if WritCreater.savedVars.ignoreAuto then
            autoLoot = WritCreater.savedVars.autoLoot
        else
            autoLoot = GetSetting(SETTING_TYPE_LOOT,LOOT_SETTING_AUTO_LOOT) == "1"
        end
        --Is this a new looted writ reward box or the box form a writ reward box?
        local itemLink = GetItemLink(bagId, slotId)
        local itemFlavText = GetItemLinkFlavorText(itemLink)
        if itemFlavText == writRewardContainerFlavText then
            --d(">Item is a autolooted writ container: " .. itemLink)
            --Set the preventer functions so the loot event cllback function of Wishlist is not called for the autoloot of the boxes
            WL.preventerVars.writCreatorAutoLootBoxesActive = true
        elseif itemFlavText == writRewardContainerContentContainerFlavText then
            if not autoLoot then
                return false
            end
            --d(">Item is a autolooted writ container content container: " .. itemLink)
            --Set the preventer functions so the loot event callback function of Wishlist is not called for the autoloot of the boxes
            WL.preventerVars.writCreatorAutoLootBoxesActive = true
        end
        --Disable the anti-loot flag after 3 seconds again
        if WL.preventerVars.writCreatorAutoLootBoxesActive then
            checkAntiLootDisableTime()
        end
    else
        if WL.preventerVars.writCreatorAutoLootBoxesActive then checkAntiLootDisableTime(true) end
        WL.preventerVars.writCreatorAutoLootBoxesActive = false
    end
end
local inv_Single_Slot_Update = WL.Inv_Single_Slot_Update

local isItemAlreadyOnWishlist = WL.isItemAlreadyOnWishlist
local IfItemIsOnWishlist = WL.IfItemIsOnWishlist

local function lootReceivedWishListCheck(itemId, itemLink, isLootedByPlayer, receivedByCharName, whereWasItLootedData, debug, bagId, slotIndex)
    debug = debug or false
    --Get the settings
    local settings = WL.data
    local isOnWishList, item, itemIdOfSetPart
    local charData = {}
    local receivedBy = {}

    if itemLink == nil or itemId == nil then return nil end

    --Check if not in dungeon and setting to be in a ddngeon upon notify is enabled
    if settings.notifyOnFoundItemsOnlyInDungeons == true then
        if not IsUnitInDungeon("player") then
            if debug then d("<<<should be in dungeon but is not!") end
            return
        end
    end

    --Compare some data like the itemType, weaponOrArmorType, slot, traut of itemLink of the looted item with your wishList
    local itemType = GetItemLinkItemType(itemLink)
    if debug then
        d(">itemType: " ..tos(itemType))
    end
    if not allowedItemTypes[itemType] then return false end

    --Check if the item is a set part
    local isSet, setName, _, _, _, setId = GetItemLinkSetInfo(itemLink, false)
    if debug then
        d(">isSet: " ..tos(isSet) .. ", setName: " .. tos(setName) .. ", setId: " ..tos(setId))
    end
    if not isSet then return false end

    --Check the item's level and if the setting to only notify if the level is the currently max CP level is enabled
    local doGoOn = true
    if settings.notifyOnFoundItemsOnlyMaxCP == true then
        doGoOn = false
        local maxLevel = GetMaxLevel()
        local requiredLevel = GetItemLinkRequiredLevel(itemLink)
        local itemReqCPLevel = GetItemLinkRequiredChampionPoints(itemLink)
        if requiredLevel >= maxLevel then doGoOn = true end
        if doGoOn == true then
            local maxCP = GetChampionPointsPlayerProgressionCap()
            if itemReqCPLevel <= 0 or itemReqCPLevel < maxCP then
                doGoOn = false
            end
        end
        if doGoOn == false then
            if debug then d("<<<item level should be max CP but is only " ..tos(requiredLevel) .. " and " .. tos(itemReqCPLevel) .. " CP)") end
            return
        end
    end


    --2022-03-07
    --Check if the item's key is on a WishList
    -->Only for non craftable set items which belong to setItemCollections!
    -->Check via the slot the item is defined for, e.g. rings could drop for a slot "ring" and thus the slot type should be
    -->enough to apply a valid dropped item which is with the same other data on your wishlist, but the itemId does not match in detail
    -->e.g. a named ring from a boss dungeon of set A vs. the normal non-named ring of the same set A
    -->itemSetCollectionKey will be setId:id64OfItemSetCollectionSlot
    if not libSetsCraftedUpdated and libSets.fullyLoaded == true then
        isCraftedSet = libSets.IsCraftedSet --Updated here once after LibSets was loaded
        libSetsCraftedUpdated = true
    end
    local itemSetCollectionKey
    local isCraftedSetItem = isCraftedSet(setId)
    if not isCraftedSetItem then
        itemSetCollectionKey = getSetItemSlotKey(itemLink)
        if debug then
            d("[WL]No crafted set! setId: " .. itemLink .. ", slotKey: " .. tos(itemSetCollectionKey))
        end
    end


    --Get the armor or weapon type for comparison
    local armorOrWeaponType
    if itemType == ITEMTYPE_ARMOR then
        armorOrWeaponType = GetItemLinkArmorType(itemLink)
    elseif itemType == ITEMTYPE_WEAPON then
        armorOrWeaponType = GetItemLinkWeaponType(itemLink)
    end
    if debug then
        d(">armorOrWeaponType: " ..tos(armorOrWeaponType))
    end
    --Get the slot type
    local slotType = GetItemLinkEquipType(itemLink)
    if debug then
        d(">slotType: " ..tos(slotType))
    end
    --Get the trait
    local traitType = GetItemLinkTraitInfo(itemLink)
    if debug then
        d(">traitType: " ..tos(traitType))
    end
    --Get the quality
    local quality = GetItemLinkDisplayQuality(itemLink)
    if debug then
        d(">quality: " ..tos(quality))
    end

    --Scan all characters or only the currently logged in?
    if settings.scanAllChars then
        if debug then
            d(">Scanning all chars' wishlists")
        end
        local charsOfAcc = WL.accData.chars
        for charId, charInfo in pairs(charsOfAcc) do
            charData = {}
            charData.id = charId
            charData.name = charInfo.name
            if debug then
                d(">>scanning char: " .. tos(charData.name))
            end
            charData.class = charInfo.class
            if charData ~= nil and charData.id ~= nil then
                --Check if the item is on the wishlist
                isOnWishList, itemIdOfSetPart, item = isItemAlreadyOnWishlist(itemLink, itemId, charData, true, setId, itemType, armorOrWeaponType, slotType, traitType, quality, itemSetCollectionKey)
                if debug then
                    d(">>isOnWishList: " .. tos(isOnWishList))
                end
                --Is the item on the wishlist?
                if isOnWishList then
                    --Simulate the EVENT_INVENTORY_SINGLE_SLOT_UPDATE now to fill the needed variables for the automatic icon marking
                    if debug and bagId and slotIndex then WL.Inv_Single_Slot_Update(wlName, bagId, slotIndex, true, _, INVENTORY_UPDATE_REASON_DEFAULT, _, debug) end
                    --Add the current date & time to the item
                    item = WL.addTimeStampToItem(item)
                    --Remove the gender stuff from the setname
                    setName = zo_strformat("<<C:1>>", setName)
                    --Is the setting disable to use the char name and not the account name? But not for our own as this will be handled within function IfItemIsOnWishlist.
                    if not isLootedByPlayer then
                        --Check if we can determine the charName of the grouped accountName which looted the item
                        local receivedByAccountName = WL.mapGroupedCharNameToAccountName(receivedByCharName)
                        receivedBy.accountName = receivedByAccountName
                    end
                    receivedBy.charName = receivedByCharName
                    --Is the item on the WishList?
                    IfItemIsOnWishlist(item, itemId, itemLink, setName, isLootedByPlayer, receivedBy, charData, whereWasItLootedData, debug)
                end
            end
        end
    else
        if debug then
            d(">Scan only this char's wishlist")
        end
        charData = WL.LoggedInCharData
        if charData == nil or charData.id == nil then return false end
        --Check if the item is on the wishlist
        isOnWishList, itemIdOfSetPart, item = isItemAlreadyOnWishlist(itemLink, itemId, charData, true, setId, itemType, armorOrWeaponType, slotType, traitType, quality, itemSetCollectionKey)
        if debug then
            d(">>isOnWishList: " .. tos(isOnWishList))
        end
        if not isOnWishList then return false end
        --Simulate the EVENT_INVENTORY_SINGLE_SLOT_UPDATE now to fill the needed variables for the automatic icon marking
        if debug and bagId and slotIndex then WL.Inv_Single_Slot_Update(wlName, bagId, slotIndex, true, _, INVENTORY_UPDATE_REASON_DEFAULT, _, debug) end
        --Add the current date & time to the item
        item = WL.addTimeStampToItem(item)
        --Remove the gender stuff from the setname
        setName = zo_strformat("<<C:1>>", setName)
        --Is the setting disable to use the char name and not the account name? But not for our own as this will be handled within function IfItemIsOnWishlist.
        if not isLootedByPlayer then
            --Check if we can determine the charName of the grouped accountName which looted the item
            local receivedByAccountName = WL.mapGroupedCharNameToAccountName(receivedByCharName)
            receivedBy.accountName = receivedByAccountName
        end
        receivedBy.charName = receivedByCharName
        --Is the item on the wishlist?
        IfItemIsOnWishlist(item, itemId, itemLink, setName, isLootedByPlayer, receivedBy, charData, whereWasItLootedData, debug)
    end
    --Reset the INVENTORY_SINGLE_SLOT_UPDATE variable for the automatic icon mark again now
    WL.invSingleSlotUpdateData[itemLink] = nil
end

function WL.simulateLootReceived(bagId, slotIndex, receivedBy, isLootedByPlayer)
    if isLootedByPlayer == nil then isLootedByPlayer = true end
    receivedBy = receivedBy or GetUnitName("player")
    local itemLink = GetItemLink(bagId, slotIndex)
    if itemLink == nil then return nil end
    local itemId = GetItemLinkItemId(itemLink)
    --isInPVP, isInDelve, isInPublicDungeon, isInGroupDungeon, isInRaid, isInGroup, groupSize
    local whereWasItLootedData = { WL.getCurrentZoneAndGroupStatus() }
    --------------------------------------------------------------------------------------------------------------------
    --------------------------------------------------------------------------------------------------------------------
    --------------------------------------------------------------------------------------------------------------------
    d(">===================================>")
    d("WL.SimulateLootReceived: " .. tos(itemLink) .. ", itemId: " ..tos(itemId) .. ", receivedBy: " ..tos(receivedBy) .. ", isLootedByPlayer: " .. tos(isLootedByPlayer))
    --------------------------------------------------------------------------------------------------------------------
    --------------------------------------------------------------------------------------------------------------------
    --------------------------------------------------------------------------------------------------------------------
    lootReceivedWishListCheck(itemId, itemLink, isLootedByPlayer, receivedBy, whereWasItLootedData, true, bagId, slotIndex)
    d("<===================================<")
end

--EVENT_LOOT_RECEIVED (number eventCode, string receivedBy, string itemName, number quantity, ItemUISoundCategory soundCategory, LootItemType lootType, boolean self, boolean isPickpocketLoot, string questItemIcon, number itemId, boolean isStolen)
function WL.LootReceived(_, receivedBy, itemLink, _, _, lootType, isLootedByPlayer, _, _, itemId, _)
--d("WL.LootReceived: " .. tos(itemLink) .. ", receivedBy: " .. tos(receivedBy) .. ", isLootedByPlayer: " .. tos(isLootedByPlayer))
    --Only check if an item was looted
    if not lootType == LOOT_TYPE_ITEM then return false end
    --Are we looting writ reward containers, and cotainers in there? No set items will be looted so abort here until everything is looted
    --As we cannot detect when it ends to loot all writ containers we can only assume it's ended after ~3 seconds and will be
    --increased each time the next writ container get's looted by 3 seconds
    if WL.preventerVars.writCreatorAutoLootBoxesActive then
        --d(">Auto loot of writ container active -> ABORTING")
        return false
    end
    --Check where the item was looted
    --isInPVP, isInDelve, isInPublicDungeon, isInGroupDungeon, isInRaid, isInGroup, groupSize
    local whereWasItLootedData = { WL.getCurrentZoneAndGroupStatus() }

    --Check if the item is on a wishlist
    lootReceivedWishListCheck(itemId, itemLink, isLootedByPlayer, receivedBy, whereWasItLootedData, WL.debug, nil, nil)
end
local lootReceived = WL.LootReceived

------------------------------------------------
--- Wishlist - ZO_SortFilterList entry creation
------------------------------------------------

--Check which language should be added first to the set name column (client language or standard language EN)
-->This function should only be run once after reloadui, and once after the settings were changed (See variable WL.preventerVars.runSetNameLanguageChecks)
local function checkLanguageToAddFirst()
    --d("[WishList]checkLanguageToAddFirst, WL.langToAddFirst: " ..tos(WL.langToAddFirst))
    if not WL.preventerVars.runSetNameLanguageChecks then return WL.langToAddFirst end
    --Checks which language should be added first to the setName output
    local clientLang = WL.clientLang or WL.fallbackSetLang
    local setNameOutputSettings = WL.data.useLanguageForSetNames
    local clientLangIsSupportedInLibSets = libSets.supportedLanguages[clientLang]
    local langToAddFirst = "en"
    --Check if the client language is disabled in the settings for the setName
    local clientLangIsEnabledInSetNameSettings = setNameOutputSettings[clientLang] or false
    --Check if all languages are disabled in the settings for the setNames
    local fallbackLangEnabledInSetNameSettings = false
    local otherNonFallbackLangEnabledInSetNameSettings = false
    local allLanguagesDisabledInSetNameSettings = true
    local doNotAddFirstLanguage = false
    for langToCheck, isEnabledCheck in pairs(setNameOutputSettings) do
        --Language is enabled?
        if isEnabledCheck then
            allLanguagesDisabledInSetNameSettings = false
            --English language is enabled in the settings?
            if langToCheck == langToAddFirst then
                fallbackLangEnabledInSetNameSettings = true
            elseif langToCheck ~= clientLang then
                otherNonFallbackLangEnabledInSetNameSettings = true
            end
        end
    end
    --All languages are disabled in the settings of the setName
    if allLanguagesDisabledInSetNameSettings then
        --Client language is not supported within LibSets. Then use the default language "en"
        --Client language is supported within LibSets? Then add it as first language
        if clientLangIsSupportedInLibSets then
            langToAddFirst = clientLang
        --else --Client language is not supported, so use the fallback language
        end
    --Not all languages are disabled in the settings of the setName
    else
        --The client language is supported within LibSets and the client language is enabled in the settings for the setName output:
        --Then add it as first language
        if clientLangIsSupportedInLibSets and clientLangIsEnabledInSetNameSettings then
            langToAddFirst = clientLang
        --The client language is not supported within LibSets or the client language is not enabled in the settings for the setName output,
        --and the fallback language is not enabled in the settings of the setName, but another language is enabled
        --Then add it as first language
        elseif (not clientLangIsSupportedInLibSets or not clientLangIsEnabledInSetNameSettings) and
                (not fallbackLangEnabledInSetNameSettings and otherNonFallbackLangEnabledInSetNameSettings) then
            --Check if the fallback language "en" is not enabled in the settings of the setName, but another language is enabled.
            --Then do not add the fallback language "en" but only the enabled language
            doNotAddFirstLanguage = true
        end
    end
    --d(">doNotAddFirstLanguage: " .. tos(doNotAddFirstLanguage) .. ", langToAddFirst: " .. tos(langToAddFirst) .. "-> clientLang: " ..tos(clientLang)..", supported: " ..tos(clientLangIsSupportedInLibSets)..", enabled: " ..tos(clientLangIsEnabledInSetNameSettings) .. ", allDisabled: " ..tos(allLanguagesDisabledInSetNameSettings))
    if doNotAddFirstLanguage then langToAddFirst = nil end
    WL.preventerVars.runSetNameLanguageChecks = false
    WL.langToAddFirst = langToAddFirst
    return langToAddFirst
end

--Helper function to get the zoneName for a zoneId
local zoneIdsAdded = {}
local wayshrinesAdded = {}
local zoneIdNames = {}
local wayshrineNames = {}
local function checkAndGetZoneName(p_zoneId, p_setId, p_dropLocationsText, p_dropLocationsZoneIds)
    if p_zoneId > 0 and not zoneIdsAdded[p_zoneId] then
        local zoneNameLocalized = nil
        if p_zoneId ~= WISHLIST_ZONEID_BATTLEGROUNDS and p_zoneId ~= WISHLIST_ZONEID_SPECIAL then
            zoneNameLocalized = libSets.GetZoneName(p_zoneId, WL.clientLang)
        end
        if zoneNameLocalized == nil or zoneNameLocalized == "" then
            --Get the setType and check if it's from a battleground (there is no zoneId for them so we need to use a fixed String)
            local isBGSetType = libSets.IsBattlegroundSet(p_setId)
            if isBGSetType then
                zoneNameLocalized = GetString(WISHLIST_DROPLOCATION_BG)
                if p_dropLocationsZoneIds == nil then
                    p_dropLocationsZoneIds = {}
                    p_dropLocationsZoneIds = {[1] = WISHLIST_ZONEID_BATTLEGROUNDS}
                end
            else
                --Get the setType and check if it's from a battleground (there is no zoneId for them so we need to use a fixed String)
                local isSpecialSetType = libSets.IsSpecialSet(p_setId)
                if isSpecialSetType then
                    zoneNameLocalized = GetString(WISHLIST_DROPLOCATION_SPECIAL)
                    if p_dropLocationsZoneIds == nil then
                        p_dropLocationsZoneIds = {[1] = WISHLIST_ZONEID_SPECIAL}
                    end
                end
            end
        end
        if zoneNameLocalized and zoneNameLocalized ~= "" then
            if p_dropLocationsText == "" then
                p_dropLocationsText = zoneNameLocalized
            else
                p_dropLocationsText = p_dropLocationsText .. ", " .. zoneNameLocalized
            end
            zoneIdsAdded[p_zoneId] = true
            zoneIdNames[p_zoneId] = zoneNameLocalized
        end
    end
    return p_dropLocationsText, p_dropLocationsZoneIds
end

local function checkAndGetWayshrineName(p_wayShrines)
    if p_wayShrines and type(p_wayShrines) == "table" then
        for _, wsIndex in ipairs(p_wayShrines) do
            if wsIndex > 0 and not wayshrinesAdded[wsIndex] then
                local wsNameLocalized = nil
                --@return known bool,name string,normalizedX number,normalizedY number,icon textureName,glowIcon textureName:nilable,poiType [PointOfInterestType|#PointOfInterestType],isShownInCurrentMap bool,linkedCollectibleIsLocked bool
                --function GetFastTravelNodeInfo(nodeIndex) end
                local _, wsName = GetFastTravelNodeInfo(wsIndex)
                if wsName and wsName ~= "" then
                    wsNameLocalized = ZO_CachedStrFormat("<<C:1>>", wsName)
                    if wsNameLocalized and wsNameLocalized ~= "" then
                        wayshrinesAdded[wsIndex] = true
                        wayshrineNames[wsIndex] = wsNameLocalized
                    end
                end
            end
        end
    end
end

--ZO_SortScrollList - Item for the sets tab's list
function WL.CreateEntryForSet( setId, setData )
	--Item data format: {id=number, itemType=ITEM_TYPE, trait=ITEM_TRAIT_TYPE, type=ARMOR_TYPE/WEAPON_TYPE, slot=EQUIP_TYPE}
    --local setsData = WL.accData.sets
	local itemId = WL.GetFirstSetItem(setId)
    if itemId == nil then return nil end
	--local bonuses = setsData[setId][1].bonuses
    local itemLink = WL.buildItemLink(itemId, WISHLIST_QUALITY_LEGENDARY) -- Always use the legendary quality for the sets list
    local _, _, numBonuses = GetItemLinkSetInfo(itemLink, false)
    --Remove the gender stuff from the setname
    local clientLang = WL.clientLang or WL.fallbackSetLang
    local nameColumnValue = ""
    --Get the settings for the setName output
    local clientLangSetName = setData.names[clientLang] or setData.names[WL.fallbackSetLang]
    local langsAdded = 0
    local setNameOutputSettings = WL.data.useLanguageForSetNames
    if not libSets or setNameOutputSettings == nil then
        nameColumnValue = clientLangSetName
        langsAdded = langsAdded +1
    else
        local langsAlreadyAdded = {}
        --Which language should be added first to the setName column?
        local langToAddFirst = checkLanguageToAddFirst()
        if langToAddFirst ~= nil then
            nameColumnValue = setData.names[langToAddFirst]
            langsAlreadyAdded[langToAddFirst] = true
            langsAdded = langsAdded +1
        end
        --For each enabled language in the WishList "LibSets setName output" settings (which is not the already added
        --client language or English)
        for languageToAddToSetName, isEnabled in pairs(setNameOutputSettings) do
            if isEnabled and not langsAlreadyAdded[languageToAddToSetName] then
                local setNameInLanguageToAdd = setData.names[languageToAddToSetName]
                --Is the setName missing in the language it should be added for?
                --Then set the name to "n/a"
                if not setNameInLanguageToAdd or setNameInLanguageToAdd == "" then
                    setNameInLanguageToAdd = "n/a"
                end
                if langsAdded == 0 then
                    if nameColumnValue and nameColumnValue ~= "" then
                        --Add the set name in this language without a seperator character
                        nameColumnValue = nameColumnValue .. setNameInLanguageToAdd
                    else
                        nameColumnValue = setNameInLanguageToAdd
                    end
                else
                    if nameColumnValue and nameColumnValue ~= "" then
                        --Add the set name in this language with a seperator character /
                        nameColumnValue = nameColumnValue .. " / " .. setNameInLanguageToAdd
                    else
                        nameColumnValue = setNameInLanguageToAdd
                    end
                end
                --Increase the counter
                langsAdded = langsAdded +1
            end
        end
    end
    --Set the width of the label column depending on the languages added
    local columnWidthAdd = 0
    if langsAdded > 1 then
        columnWidthAdd = langsAdded * 125
    end
    --Get the drop location(s) of the set via LibSets
    local dropLocationsText = ""
    local dropLocationsZoneIds = libSets.GetZoneIds(setId)
    zoneIdsAdded = {}
    zoneIdNames = {}
    wayshrinesAdded = {}
    wayshrineNames = {}
    --Get the zoneIds' text now
    if dropLocationsZoneIds ~= nil then
        if type(dropLocationsZoneIds) == "table" then
            --Get each zoneId, get the zoneName localized via LibZone (via LiBSets) or from LibSets data
            for _, zoneId in ipairs(dropLocationsZoneIds) do
                dropLocationsText = checkAndGetZoneName(zoneId, setId, dropLocationsText, nil)
            end
        end
    else
        --For battleground sets there is no zoneId. Use the constant here
        dropLocationsText, dropLocationsZoneIds = checkAndGetZoneName(WISHLIST_ZONEID_BATTLEGROUNDS, setId, dropLocationsText, dropLocationsZoneIds)
    end
    --Get the drop location wayshrines
    local setWayshrines = libSets.GetWayshrineIds(setId)
    checkAndGetWayshrineName(setWayshrines)
    --Get the DLC id
    local dlcId = libSets.GetDLCId(setId)
    local dlcName = libSets.GetDLCName(dlcId)
    --Get set type
    local setType = libSets.GetSetType(setId)
    local setTypeName = libSets.GetSetTypeName(setType)
    --Get traits needed for craftable sets
    local traitsNeeded = libSets.GetTraitsNeeded(setId)

    local maxNameColumnWidth = 200 + columnWidthAdd
    if WL.maxNameColumnWidth == nil or maxNameColumnWidth > WL.maxNameColumnWidth then
--d(">WL.maxNameColumnWidth changed to: " ..tos(WL.maxNameColumnWidth))
        WL.maxNameColumnWidth = maxNameColumnWidth
    end

    local setsData = WL.accData.sets[setId]
    --Table entry for the ZO_ScrollList data
	return({
        type        = WL.sortType,
		setId       = setId,
		name        = nameColumnValue,
        names       = setData.names,
        columnWidth = maxNameColumnWidth,
		itemLink    = itemLink,
		bonuses     = numBonuses,
        --LibSets data
        setType     = setType,
        traitsNeeded= traitsNeeded,
        dlcId       = dlcId,
        locality    = dropLocationsText,
        zoneIds     = dropLocationsZoneIds,
        wayshrines  = setWayshrines,
        zoneIdNames = zoneIdNames,
        wayshrineNames = wayshrineNames,
        dlcName     = dlcName,
        setTypeName = setTypeName,
        armorTypes  = setsData.armorTypes,
        weaponTypes  = setsData.weaponTypes,
        dropMechanics = setsData.dropMechanics,
	})
end

--ZO_SortFilterList - Item for the WishList tab's list (called within BuildMasterList)
function WL.CreateWishListEntryForItem(item)
    local itemLink = WL.buildItemLink(item.id, item.quality)
    --d("[WL.CreateEntryForItem] " .. itemLink)
    local setId = item.setId
    local setName = item.setName
    local bonuses = item.bonuses
    --local name = GetItemLinkName(itemLink)
    if setId == nil or setName == nil or bonuses == nil then
--df(">setId, name or bonuses not found. Trying to determine it via the itemid: %s of item %s", tos(item.id), itemLink)
        local _, setLocName, numBonuses, _, _, setLocId = GetItemLinkSetInfo(itemLink, false)
        --Remove the gender stuff from the setname
        if setLocId ~= nil and setLocId > 0 then
            setName = zo_strformat("<<C:1>>", setLocName)
            setId = setLocId
            bonuses = numBonuses
        end
    end
    if setId == nil or setId == 0 then
        df("[WISHLIST - ERROR]CreateWishListEntryForItem - setId: %s: Missing setId for set \'%s\'!", tos(setId), tos(setName))
        return
    end

    --If the quality is not set, set it with no matter which quality now
    if item.quality == nil then
        item.quality = WISHLIST_QUALITY_ALL
    end
    --Get the names of the types (for search and order functions)
    local itemTypeName, itemArmorOrWeaponTypeName, itemSlotName, itemTraitName, itemQualityName = WL.getItemTypeNamesForSortListEntry(item.itemType, item.armorOrWeaponType, item.slot, item.trait, item.quality)

    zoneIdsAdded = {}
    zoneIdNames = {}
    wayshrinesAdded = {}
    wayshrineNames = {}
    --Get the drop location(s) of the set via LibSets
    local dropLocationsZoneIds = libSets.GetZoneIds(setId)
    --Get the drop location wayshrines
    local setWayshrines = libSets.GetWayshrineIds(setId)
    checkAndGetWayshrineName(setWayshrines)
    --Get the DLC id
    local dlcId = libSets.GetDLCId(setId)
    local dlcName = libSets.GetDLCName(dlcId)
    --Get set type
    local setType = libSets.GetSetType(setId)
    local setTypeName = libSets.GetSetTypeName(setType)
    --Get traits needed for craftable sets
    local traitsNeeded = libSets.GetTraitsNeeded(setId)
    --The return table of the item on the WishList
    local setsData = WL.accData.sets[setId]

    if not setsData then
        df("[WISHLIST - ERROR]CreateWishListEntryForItem - setId: %s: Missing sets data!", tos(setId))
        return
    end
        if not setsData.armorTypes then
        df("[WISHLIST - ERROR]CreateWishListEntryForItem - setId: %s: Missing armor types!", tos(setId))
    end

    item.gearId = item.gearId or 0 --for sorting

    local wlEntryTable = {
        type                    = 1, -- for the search method to work -> Find the processor in zo_stringsearch:Process()
        setId                   = setId,
        id                      = item.id,
        itemType                = item.itemType,
        itemTypeName            = itemTypeName,
        trait                   = item.trait,
        traitName               = itemTraitName,
        armorOrWeaponType       = item.armorOrWeaponType,
        armorOrWeaponTypeName   = itemArmorOrWeaponTypeName,
        slot                    = item.slot,
        slotName                = itemSlotName,
        name                    = setName,
        itemLink                = itemLink,
        timestamp               = item.timestamp,
        quality                 = item.quality,
        qualityName             = itemQualityName,
        bonuses                 = bonuses,
        knownInSetItemCollectionBook = (item.knownInSetItemCollectionBook and 1) or 0,
        gearId     = item.gearId,
        --LibSets data
        setType     = setType,
        traitsNeeded= traitsNeeded,
        dlcId       = dlcId,
        zoneIds     = dropLocationsZoneIds,
        wayshrines  = setWayshrines,
        zoneIdNames = zoneIdNames,
        wayshrineNames = wayshrineNames,
        dlcName     = dlcName,
        setTypeName = setTypeName,
        armorTypes  = setsData.armorTypes,
        dropMechanics = setsData.dropMechanics,
    }
    --Build the data entry for the ZO_SortScrollList row (for searching and sorting with the names AND the ids!)
    return wlEntryTable
end

--ZO_SortFilterList - Item for the History tab's list (called within BuildMasterList)
function WL.CreateHistoryEntryForItem(item)
    local itemLink = WL.buildItemLink(item.id, item.quality)
--d("[WL.CreateHistoryEntryForItem] " .. itemLink .. ", timestamp: " .. tos(item.timestamp))
    local setId = item.setId
    local setName = item.setName
    local bonuses = item.bonuses
    --local name = GetItemLinkName(itemLink)
	if setId == nil or setName == nil or bonuses == nil then
        local _, setLocName, numBonuses, _, _, setLocId = GetItemLinkSetInfo(itemLink, false)
        --Remove the gender stuff from the setname
        setName = zo_strformat("<<C:1>>", setLocName)
        setId = setLocId
        bonuses = numBonuses
    end
    --If the quality is not set, set it with no matter which quality now
    if item.quality == nil then
        item.quality = WISHLIST_QUALITY_ALL
    end
    --Get the names of the types (for search and order functions)
    local itemTypeName, itemArmorOrWeaponTypeName, itemSlotName, itemTraitName, itemQualityName = WL.getItemTypeNamesForSortListEntry(item.itemType, item.armorOrWeaponType, item.slot, item.trait, item.quality)

    zoneIdsAdded = {}
    zoneIdNames = {}
    wayshrinesAdded = {}
    wayshrineNames = {}
    --Get the drop location(s) of the set via LibSets
    local dropLocationsZoneIds = libSets.GetZoneIds(setId)
    --Get the drop location wayshrines
    local setWayshrines = libSets.GetWayshrineIds(setId)
    checkAndGetWayshrineName(setWayshrines)
    --Get the DLC id
    local dlcId = libSets.GetDLCId(setId)
    local dlcName = libSets.GetDLCName(dlcId)
    --Get set type
    local setType = libSets.GetSetType(setId)
    local setTypeName = libSets.GetSetTypeName(setType)
    --Get traits needed for craftable sets
    local traitsNeeded = libSets.GetTraitsNeeded(setId)
    --d(">>>>itemType: " .. tos(itemTypeName) .. ", armorOrWeaponType: " .. tos(itemArmorOrWeaponTypeName) .. ", slot: " ..tos(itemSlotName) .. ", trait: " .. tos(itemTraitName))
    --Build the data entry for the ZO_SortScrollList row (for searching and sorting with the names AND the ids!)
    local setsData = WL.accData.sets[setId]
    local function getDisplayNameOfItem()
        if item.displayName ~= nil then return item.displayName else return "" end
    end
    return({
        type                    = 1, -- for the search method to work -> Find the processor in zo_stringsearch:Process()
        setId                   = setId,
        id                      = item.id,
        itemType                = item.itemType,
        itemTypeName            = itemTypeName,
        trait                   = item.trait,
        traitName               = itemTraitName,
        armorOrWeaponType       = item.armorOrWeaponType,
        armorOrWeaponTypeName   = itemArmorOrWeaponTypeName,
        slot                    = item.slot,
        slotName                = itemSlotName,
        name                    = setName,
        date                    = item.date,
        itemLink                = itemLink,
        timestamp               = item.timestamp,
        username                = item.username,
        displayName             = getDisplayNameOfItem(),
        locality                = item.locality,
        quality                 = item.quality,
        qualityName             = itemQualityName,
        bonuses                 = bonuses,
        --LibSets data
        setType     = setType,
        traitsNeeded= traitsNeeded,
        dlcId       = dlcId,
        zoneIds     = dropLocationsZoneIds,
        wayshrines  = setWayshrines,
        zoneIdNames = zoneIdNames,
        wayshrineNames = wayshrineNames,
        dlcName     = dlcName,
        setTypeName = setTypeName,
        armorTypes  = setsData.armorTypes,
        dropMechanics = setsData.dropMechanics,
    })
end

------------------------------------------------
--- Wishlist / History - Add items
------------------------------------------------
--Add item to the WishList SavedVariables
function WishList:AddItem(items, charData, alreadyOnWishlistCheckDone, noAddedChatOutput)
    alreadyOnWishlistCheckDone = alreadyOnWishlistCheckDone or false
    noAddedChatOutput = noAddedChatOutput or false
    local count = 0
    local wishList = WL.getWishListSaveVars(charData, "WishList:AddItem")
    if wishList == nil then return true end
    --local charNameChat = WL.buildCharNameChatText(charData, nil)
--d("[WL]AddItem, SV found for charName " .. tos(charData.name) .. ", CharId: " .. tos(charData.id))
    local charNameChat = charData.name
    local displayName = GetDisplayName()
    local savedVarsServer = getSavedVarsServer()
    addonVars = WL.addonVars
    for i = 1, #items do
		local item = items[i]
        --Is the item already on the WishList?
        local itemLink
        if item.itemLink ~= nil then
            itemLink = item.itemLink
        else
            itemLink = WL.buildItemLink(item.id, item.quality)
        end
        local alreadyOnWishList = false
        if not alreadyOnWishlistCheckDone then
            alreadyOnWishList = WL.isItemAlreadyOnWishlist(itemLink, item.id, charData) or false
        end
        if not alreadyOnWishList then
            local isKnown = WL.IsItemKnownInSetItemCollectionBook(item)
            if isKnown == true then item.knownInSetItemCollectionBook = true end
            --Add the date & time as the item got added
            if item.timestamp == nil then
                item = WL.addTimeStampToItem(item)
            end
            --Insert the item to the character dependent WishList SavedVars global table WishList_Data[savedVarsServer][GetDisplayName()][charId]["Data"]["wishList"]
            --table.insert(wishList, item)
            --d("[WishList]AddItem, item quality: " ..tos(item.quality))
            table.insert(WishList_Data[savedVarsServer][displayName][charData.id][addonVars.addonSavedVarsDataTab][addonVars.addonSavedVarsWishListTab], item)
            count = count + 1
            local traitId = item.trait
            local traitText = ""
            if traitId ~= nil then
                traitText = WL.TraitTypes[traitId]
                traitText = WL.buildItemTraitIconText(traitText, traitId)
                traitText = traitText or ""
            end
            if not noAddedChatOutput then
                d(tos(itemLink)..GetString(WISHLIST_ADDED) .. ", " .. traitText .. charNameChat)
            end
        end
	end
    d(zo_strformat(GetString(WISHLIST_ITEMS_ADDED) .. charNameChat .. " (" .. WL.getWishListItemCount(charData) .. ")", count)) -- count.." item(s) added to Wish List"
    WL.updateRemoveAllButon()

    WishList:ReloadItems()
end

--Special ADD items function called from the item add dialog to add e.g. only monster helm and shoulders, or other special
-- addTypes -> See constants WISHLIST_ADD_TYPE_*
function WL.AddSetItems(addType)
    --d("[WL.AddSetItems] addType: " .. tos(addType))
    --Close the add item dialog at first!
    WishListAddItemDialogCancel:callback()

    local charsComboBox = WishListAddItemDialogContentCharsCombo.m_comboBox
    local itemTypeComboBox = WishListAddItemDialogContentItemTypeCombo.m_comboBox
    local armorOrWeaponComboBox = WishListAddItemDialogContentArmorOrWeaponTypeCombo.m_comboBox
    local slotComboBox = WishListAddItemDialogContentSlotCombo.m_comboBox
    local traitComboBox = WishListAddItemDialogContentTraitCombo.m_comboBox
    local qualityComboBox = WishListAddItemDialogContentQualityCombo.m_comboBox

    local addType2ChatMsg = {
        [WISHLIST_ADD_TYPE_WHOLE_SET]                         = WL.buildTooltip(GetString(WISHLIST_DIALOG_ADD_WHOLE_SET_TT)),
        [WISHLIST_ADD_TYPE_BY_ITEMTYPE]                       = WL.buildTooltip(GetString(WISHLIST_DIALOG_ADD_ALL_TYPE_OF_SET_TT), itemTypeComboBox.m_selectedItemText:GetText()),
        [WISHLIST_ADD_TYPE_BY_ITEMTYPE_AND_ARMOR_WEAPON_TYPE] = WL.buildTooltip(GetString(WISHLIST_DIALOG_ADD_ALL_TYPE_TYPE_OF_SET_TT), itemTypeComboBox.m_selectedItemText:GetText(), armorOrWeaponComboBox.m_selectedItemText:GetText()),
        [WISHLIST_ADD_BODY_PARTS_ARMOR]                       = WL.buildTooltip(GetString(WISHLIST_DIALOG_ADD_BODY_PARTS_ARMOR_OF_SET_TT)),
        [WISHLIST_ADD_ONE_HANDED_WEAPONS]                     = WL.buildTooltip(GetString(WISHLIST_DIALOG_ADD_ONE_HANDED_WEAPONS_OF_SET_TT)),
        [WISHLIST_ADD_TWO_HANDED_WEAPONS]                     = WL.buildTooltip(GetString(WISHLIST_DIALOG_ADD_TWO_HANDED_WEAPONS_OF_SET_TT)),
        [WISHLIST_ADD_MONSTER_SET_PARTS_ARMOR]                = WL.buildTooltip(GetString(WISHLIST_DIALOG_ADD_MONSTER_SET_PARTS_ARMOR_OF_SET_TT)),
    }
    local chatMsg = addType2ChatMsg[addType] or ""
    if chatMsg == nil or chatMsg == "" then return false end
    d(chatMsg)

    --Get the character data where the set parts should be added to the wishlist
    local selectedCharData = charsComboBox.m_selectedItemData
    if selectedCharData == nil or selectedCharData.id == nil then return false end
    --Get the selected itemType
    local selectedItemTypeData = itemTypeComboBox.m_selectedItemData
    if selectedItemTypeData == nil or selectedItemTypeData.id == nil then return false end
    --Get the selected weapon or armor type
    local selectedItemArmorOrWeaponTypeData = armorOrWeaponComboBox.m_selectedItemData
    if selectedItemArmorOrWeaponTypeData == nil or selectedItemArmorOrWeaponTypeData.id == nil then return false end
    --Get the selected slot type
    local selectedSlotData = slotComboBox.m_selectedItemData
    if selectedSlotData == nil or selectedSlotData.id == nil then return false end
    --get the selected item trait
    local selectedItemTraitData = traitComboBox.m_selectedItemData
    if selectedItemTraitData == nil or selectedItemTraitData.id == nil then return false end
    --get the selected quality
    local selectedItemQualityData = qualityComboBox.m_selectedItemData
    if selectedItemQualityData == nil or selectedItemQualityData.id == nil then return false end

--d(">selectedItemType: " ..tos(selectedItemTypeData.id) .. ", selectedItemArmorOrWeaponTypeData: " .. tos(selectedItemArmorOrWeaponTypeData.id) .. ", selectedSlotData: " ..tos(selectedSlotData.id) .. ", selectedItemTrait: " ..tos(selectedItemTraitData.id) .. ", selectedItemQuality: " ..tos(selectedItemQualityData.id))
    --The items to add table
    local items = {}
    --Get the set parts to add
    items = WL.getSetItemsByData(WL.currentSetId, selectedItemTypeData, selectedItemArmorOrWeaponTypeData, selectedSlotData, selectedItemTraitData, selectedItemQualityData, addType)
    --Add the items now, if some were found
    if #items > 0 then
        --Add the currently selected values to the "Last added" history data of the SavedVariables and use the special add type
        WL.addLastAddedHistoryFromAddItemDialog(WL.currentSetId, itemTypeComboBox, armorOrWeaponComboBox, traitComboBox, slotComboBox, charsComboBox, qualityComboBox, addType)
        --Add the found set items to the WishList of the selected user now
        WishList:AddItem(items, selectedCharData)
    else
        d("!!! " .. GetString(WISHLIST_NO_ITEMS_ADDED_WITH_SELECTED_DATA))
    end
end

--Add item to the history SavedVariables
function WishList:AddHistoryItem(items, charData)
--d("[WishList:AddHistoryItem]")
    local count = 0
    local history = WL.getHistorySaveVars(charData)
    if history == nil then return true end
    --local charNameChat = WL.buildCharNameChatText(charData, nil)
    local charNameChat = charData.name
    local displayName = GetDisplayName()
    local savedVarsServer = getSavedVarsServer()
    addonVars = WL.addonVars
    local showItemFoundHistoryChatOutput = WL.data.showItemFoundHistoryChatOutput
    for i = 1, #items do
        local item = items[i]
        --Is the item already on the WishList?
        local itemLink
        if item.itemLink ~= nil then
            itemLink = item.itemLink
        else
            itemLink = WL.buildItemLink(item.id, item.quality)
        end
--d(">item added to history: " .. itemLink)
        if item.timestamp == nil then
            item = WL.addTimeStampToItem(item)
        end
        --table.insert(history, item)
        table.insert(WishList_Data[savedVarsServer][displayName][charData.id][addonVars.addonSavedVarsDataTab][addonVars.addonSavedVarsHistoryTab], item)
        count = count + 1
        local traitId = item.trait
        local traitText = ""
        if traitId ~= nil then
            traitText = WL.TraitTypes[traitId]
            traitText = WL.buildItemTraitIconText(traitText, traitId)
            traitText = traitText or ""
        end
        if showItemFoundHistoryChatOutput then
            d(tos(itemLink)..GetString(WISHLIST_HISTORY_ADDED) .. ", " .. traitText .. charNameChat)
        end
    end
    if showItemFoundHistoryChatOutput then
        d(zo_strformat(GetString(WISHLIST_HISTORY_ITEMS_ADDED) .. charNameChat .. " (" .. WL.getHistoryItemCount(charData) .. ")", count)) -- count.." item(s) added to Wish List"
    end
    WL.updateRemoveAllButon()

    WishList:ReloadItems()
end

------------------------------------------------
--- Wishlist / History - Remove items
------------------------------------------------
function WishList:RemoveItem(item, charData)
    local index = -1
    local wishList = WL.getWishListSaveVars(charData, "WishList:RemoveItem")
    if wishList == nil then return true end
    --local charNameChat = WL.buildCharNameChatText(charData, nil)
    local displayName = GetDisplayName()
    local savedVarsServer = getSavedVarsServer()
    addonVars = WL.addonVars
    local charNameChat = charData.name
	for i = 1, #wishList do
		local itm = wishList[i]
		if itm.id == item.id then
			index = i
			break
		end
	end
	if index ~= -1 then
		--table.remove(wishList, index)
        table.remove(WishList_Data[savedVarsServer][displayName][charData.id][addonVars.addonSavedVarsDataTab][addonVars.addonSavedVarsWishListTab], index)
        local itemLink
        if item.itemLink ~= nil then
            itemLink = item.itemLink
        else
            itemLink = WL.buildItemLink(item.id, item.quality)
        end
        local traitId = item.trait
        local itemTraitText = WL.TraitTypes[traitId]
        itemTraitText = WL.buildItemTraitIconText(itemTraitText, traitId)
        itemTraitText = itemTraitText or ""
		d(tos(itemLink)..GetString(WISHLIST_REMOVED) .. ", " .. itemTraitText .. charNameChat .. " (" .. WL.getWishListItemCount(charData) .. ")")
	end

    WL.updateRemoveAllButon()
    WishList:ReloadItems()
end

function WishList:RemoveHistoryItem(item, charData)
    local index = -1
    local history = WL.getHistorySaveVars(charData)
    if history == nil then return true end
    local displayName = GetDisplayName()
    local savedVarsServer = getSavedVarsServer()
    addonVars = WL.addonVars
    --local charNameChat = WL.buildCharNameChatText(charData, nil)
    local charNameChat = charData.name
    for i = 1, #history do
        local itm = history[i]
        if itm.id == item.id then
            index = i
            break
        end
    end
    if index ~= -1 then
        --table.remove(history, index)
        table.remove(WishList_Data[savedVarsServer][displayName][charData.id][addonVars.addonSavedVarsDataTab][addonVars.addonSavedVarsHistoryTab], index)
        local itemLink
        if item.itemLink ~= nil then
            itemLink = item.itemLink
        else
            itemLink = WL.buildItemLink(item.id, item.quality)
        end
        local traitId = item.trait
        local itemTraitText = WL.TraitTypes[traitId]
        itemTraitText = WL.buildItemTraitIconText(itemTraitText, traitId)
        itemTraitText = itemTraitText or ""
        d(tos(itemLink)..GetString(WISHLIST_HISTORY_REMOVED) .. ", " .. itemTraitText .. charNameChat.. " (" .. WL.getHistoryItemCount(charData) .. ")")
    end

    WL.updateRemoveAllButon()
    WishList:ReloadItems()
end

function WishList:RemoveAllItemsWithCriteria(criteria, charData, removeFromWishListsInLoop)
--d("[WL]RemoveAllItemsWithCriteria")
    removeFromWishListsInLoop = removeFromWishListsInLoop or false
    if criteria == nil then return false end
    local wishList = WL.getWishListSaveVars(charData, "WishList:RemoveAllItemsWithCriteria")
    if wishList == nil then return true end
    --local charNameChat = WL.buildCharNameChatText(charData, nil)
    local displayName = GetDisplayName()
    local savedVarsServer = getSavedVarsServer()
    addonVars = WL.addonVars
    local charNameChat = charData.name
    local allTraitsId = WISHLIST_TRAIT_TYPE_ALL --All traits
    local checkSetId = false
    local removeKnownSetItemCollection
    if criteria.setId ~= nil then
        checkSetId = true
    end
    if criteria.knownInSetItemCollectionBook ~= nil then
        removeKnownSetItemCollection = criteria.knownInSetItemCollectionBook
    end
--d(">checkSetId: " ..tos(checkSetId))
    local cnt = 0
    for i = #wishList, 1, -1 do
        local itm = wishList[i]
        --Check the criteria now, which is specified, and combine them for a check against the WishList items
        local removeItemNow = false
        local setIdGiven = (checkSetId == true and itm.setId and itm.setId == criteria.setId) or false
        --setId must match or wasn't given as criteria
        if removeKnownSetItemCollection ~= nil then
--d(">removeKnownSetItemCollection: " ..tos(criteria.knownInSetItemCollectionBook) .. "/" .. tos(itm.knownInSetItemCollectionBook) ..", setIdGiven: " ..tos(setIdGiven))
            if checkSetId == false or setIdGiven then
                if (itm.knownInSetItemCollectionBook ~= nil and itm.knownInSetItemCollectionBook == removeKnownSetItemCollection) then
                    removeItemNow = true
                end
            end
        else
            if checkSetId == false or setIdGiven == true then
                if removeItemNow == false and criteria.timestamp ~= nil then
                    --d(">timestamp: " ..tos(criteria.timestamp) .. "/" .. tos(itm.timestamp))
                    if itm.timestamp == criteria.timestamp then
                        removeItemNow = true
                    else
                        removeItemNow = false
                    end
                end
                if removeItemNow == false and criteria.itemType ~= nil then
--d(">itemType: " ..tos(criteria.itemType) .. "/" .. tos(itm.itemType))
                    if itm.itemType == criteria.itemType then
                        if criteria.armorOrWeaponType == nil and criteria.slot ~= nil then
                            removeItemNow = true
                        else
                            if criteria.armorOrWeaponType ~= nil then
--d(">>armorOrWeaponType: " ..tos(criteria.armorOrWeaponType) .. "/" .. tos(itm.armorOrWeaponType))
                                if itm.armorOrWeaponType == criteria.armorOrWeaponType then
                                    if criteria.slot ~= nil then
--d(">>>slot: " ..tos(criteria.slot) .. "/" .. tos(itm.slot))
                                        if itm.slot == criteria.slot then
                                            removeItemNow = true
                                        else
                                            removeItemNow = false
                                        end
                                    else
                                        removeItemNow = false
                                    end
                                else
                                    removeItemNow = false
                                end
                            else
                                if criteria.slot ~= nil then
--d(">>slot: " ..tos(criteria.slot) .. "/" .. tos(itm.slot))
                                    if itm.slot == criteria.slot then
                                        removeItemNow = true
                                    else
                                        removeItemNow = false
                                    end
                                else
                                    removeItemNow = false
                                end
                            end
                        end
                    else
                        removeItemNow = false
                    end
                end
                if removeItemNow == false and criteria.armorOrWeaponType ~= nil and criteria.itemType == nil and criteria.slot == nil then
                    --d(">armorOrWeaponType: " ..tos(criteria.armorOrWeaponType) .. "/" .. tos(itm.armorOrWeaponType))
                    if itm.armorOrWeaponType == criteria.armorOrWeaponType then
                        removeItemNow = true
                    else
                        removeItemNow = false
                    end
                end
                if removeItemNow == false and criteria.slot ~= nil and criteria.itemType == nil and criteria.armorOrWeaponType == nil then
                    --d(">slot: " ..tos(criteria.slot) .. "/" .. tos(itm.slot))
                    if itm.slot == criteria.slot then
                        removeItemNow = true
                    else
                        removeItemNow = false
                    end
                end
                if removeItemNow == false and criteria.trait ~= nil then
                    --d(">trait: " ..tos(criteria.trait) .. "/" .. tos(itm.trait))
                    if criteria.trait == allTraitsId or itm.trait == criteria.trait then
                        removeItemNow = true
                    else
                        removeItemNow = false
                    end
                end
            end
        end
        if removeItemNow then
--d(">>>remove item now!")
            local itemLink
            if itm.itemLink ~= nil then
                itemLink = itm.itemLink
            else
                itemLink = WL.buildItemLink(itm.id, itm.quality)
            end
            local traitId = itm.trait
            local itemTraitText = WL.TraitTypes[traitId]
            itemTraitText = WL.buildItemTraitIconText(itemTraitText, traitId)
            itemTraitText = itemTraitText or ""
            --Remove the WishList entry of the current, or the selected char
            table.remove(WishList_Data[savedVarsServer][displayName][charData.id][addonVars.addonSavedVarsDataTab][addonVars.addonSavedVarsWishListTab], i)
            d(tos(itemLink)..GetString(WISHLIST_REMOVED) .. ", " .. itemTraitText .. charNameChat)
            cnt = cnt +1
        end
    end
    d(zo_strformat(GetString(WISHLIST_ITEMS_REMOVED) .. " " .. charNameChat .. " (" .. WL.getWishListItemCount(charData) .. ")", cnt)) -- count.." item(s) removed from Wish List"

    local updateNow = false
    if removeFromWishListsInLoop == true then
        if WL.CurrentCharData ~= nil and WL.CurrentCharData.id ~= nil and charData.id == WL.CurrentCharData.id then
            updateNow = true
        end
    else
        updateNow = true
    end
    if updateNow then
        WL.updateRemoveAllButon()
        WishList:ReloadItems()
    end
end


function WishList:RemoveAllItemsOfSet(setId, charData)
--d("[WhishList]RemoveAllItemsOfSet, setId: " ..tos(setId))
    if setId == nil then return false end
    local wishList = WL.getWishListSaveVars(charData, "WishList:RemoveAllItemsOfSet")
    if wishList == nil then return true end
    --local charNameChat = WL.buildCharNameChatText(charData, nil)
    local displayName = GetDisplayName()
    local savedVarsServer = getSavedVarsServer()
    addonVars = WL.addonVars
    local charNameChat = charData.name
    local setName = ""
    local cnt = 0
    for i = #wishList, 1, -1 do
        local itm = wishList[i]
        if itm.setId == setId then
            local itemLink = WL.buildItemLink(itm.id, itm.quality)
            if setName == "" then
                local _, setLocName, _, _, _, _ = GetItemLinkSetInfo(itemLink, false)
                --Remove the gender stuff from the setname
                setName = zo_strformat("<<C:1>>", setLocName)
            end
            local traitId = itm.trait
            local itemTraitText = WL.TraitTypes[traitId]
            itemTraitText = WL.buildItemTraitIconText(itemTraitText, traitId)
            itemTraitText = itemTraitText or ""
            --Remove the WishList entry of the current, or the selected char
            --table.remove(wishList, i)
            table.remove(WishList_Data[savedVarsServer][displayName][charData.id][addonVars.addonSavedVarsDataTab][addonVars.addonSavedVarsWishListTab], i)
            d(tos(itemLink)..GetString(WISHLIST_REMOVED) .. ", " .. itemTraitText .. charNameChat)
            cnt = cnt +1
        end
    end
    d(zo_strformat(GetString(WISHLIST_ITEMS_REMOVED) .. ", Set: \"" .. setName .. "\" " .. charNameChat .. " (" .. WL.getWishListItemCount(charData) .. ")", cnt)) -- count.." item(s) removed from Wish List"

    WL.updateRemoveAllButon()
    WishList:ReloadItems()
end

function WishList:ChangeQualityOfItem(item, charData, newQuality)
    local index = -1
    local wishList = WL.getWishListSaveVars(charData, "WishList:ChangeQualityOfItem")
    if wishList == nil then return true end
    --local charNameChat = WL.buildCharNameChatText(charData, nil)
    local displayName = GetDisplayName()
    local savedVarsServer = getSavedVarsServer()
    addonVars = WL.addonVars
    local charNameChat = charData.name
    for i = 1, #wishList do
        local itm = wishList[i]
        if itm.id == item.id then
            index = i
            break
        end
    end
    if index ~= -1 then
        local currentWishListSVEntry = WishList_Data[savedVarsServer][displayName][charData.id][addonVars.addonSavedVarsDataTab][addonVars.addonSavedVarsWishListTab][index]
        if currentWishListSVEntry ~= nil then
            currentWishListSVEntry["quality"] = newQuality
        end
        local itemLink
        if item.itemLink ~= nil then
            itemLink = item.itemLink
        else
            itemLink = WL.buildItemLink(item.id, item.quality)
        end
        local traitId = item.trait
        local itemTraitText = WL.TraitTypes[traitId]
        itemTraitText = WL.buildItemTraitIconText(itemTraitText, traitId)
        itemTraitText = itemTraitText or ""
        d(tos(itemLink).. zo_strformat(GetString(WISHLIST_UPDATED), GetString(WISHLIST_HEADER_QUALITY)) .. ", " .. itemTraitText .. charNameChat .. " (" .. WL.getWishListItemCount(charData) .. ")")
    end

    WishList:ReloadItems()
end

function WishList:ChangeQualityOfItemsOfSet(setId, charData, newQuality)
    if setId == nil then return false end
    local wishList = WL.getWishListSaveVars(charData, "WishList:ChangeQualityOfItemsOfSet")
    if wishList == nil then return true end
    --local charNameChat = WL.buildCharNameChatText(charData, nil)
    local displayName = GetDisplayName()
    local savedVarsServer = getSavedVarsServer()
    addonVars = WL.addonVars
    local charNameChat = charData.name
    local setName = ""
    local cnt = 0
    for i = #wishList, 1, -1 do
        local itm = wishList[i]
        if itm.setId == setId then
            local itemLink = WL.buildItemLink(itm.id, itm.quality)
            if setName == "" then
                local _, setLocName, _, _, _, setLocId = GetItemLinkSetInfo(itemLink, false)
                --Remove the gender stuff from the setname
                setName = zo_strformat("<<C:1>>", setLocName)
            end
            local traitId = itm.trait
            local itemTraitText = WL.TraitTypes[traitId]
            itemTraitText = WL.buildItemTraitIconText(itemTraitText, traitId)
            itemTraitText = itemTraitText or ""
            --Update the WishList entry of the current, or the selected char
            local currentWishListEntryOfSetItem = WishList_Data[savedVarsServer][displayName][charData.id][addonVars.addonSavedVarsDataTab][addonVars.addonSavedVarsWishListTab][i]
            if currentWishListEntryOfSetItem ~= nil then
                currentWishListEntryOfSetItem["quality"] = newQuality
                d(tos(itemLink)..zo_strformat(GetString(WISHLIST_UPDATED), GetString(WISHLIST_HEADER_QUALITY)) .. ", " .. itemTraitText .. charNameChat)
                cnt = cnt +1
            end
        end
    end
    d(zo_strformat(GetString(WISHLIST_ITEMS_UPDATED) .. ", Set: \"" .. setName .. "\" " .. charNameChat .. " (" .. WL.getWishListItemCount(charData) .. ")", cnt)) -- count.." item(s) updated in Wish List"

    WishList:ReloadItems()
end

function WishList:RemoveAllHistoryItemsWithCriteria(criteria, charData)
    --d("[WL]RemoveAllItemsWithCriteria")
    if criteria == nil then return false end
    local history = WL.getHistorySaveVars(charData)
    if history == nil then return true end
    --local charNameChat = WL.buildCharNameChatText(charData, nil)
    local displayName = GetDisplayName()
    local savedVarsServer = getSavedVarsServer()
    addonVars = WL.addonVars
    local charNameChat = charData.name
    local setName = ""
    local cnt = 0
    for i = #history, 1, -1 do
        local itm = history[i]
        --Check the criteria now, which is specified, and combine them for a check against the WishList items
        local removeItemNow = false
        if criteria.timestamp ~= nil then
            --d(">timestamp: " ..tos(criteria.timestamp) .. "/" .. tos(itm.timestamp))
            if itm.timestamp == criteria.timestamp then
                removeItemNow = true
            else
                removeItemNow = false
            end
        end
        if criteria.itemType ~= nil then
            --d(">itemType: " ..tos(criteria.itemType) .. "/" .. tos(itm.itemType))
            if itm.itemType == criteria.itemType then
                removeItemNow = true
            else
                removeItemNow = false
            end
        end
        if criteria.armorOrWeaponType ~= nil then
            --d(">armorOrWeaponType: " ..tos(criteria.armorOrWeaponType) .. "/" .. tos(itm.armorOrWeaponType))
            if itm.armorOrWeaponType == criteria.armorOrWeaponType then
                removeItemNow = true
            else
                removeItemNow = false
            end
        end
        if criteria.slot ~= nil then
            --d(">slot: " ..tos(criteria.slot) .. "/" .. tos(itm.slot))
            if itm.slot == criteria.slot then
                removeItemNow = true
            else
                removeItemNow = false
            end
        end
        if criteria.trait ~= nil then
            --d(">trait: " ..tos(criteria.trait) .. "/" .. tos(itm.trait))
            if itm.trait == criteria.trait then
                removeItemNow = true
            else
                removeItemNow = false
            end
        end
        if removeItemNow then
            --d(">>>remove item now!")
            local itemLink
            if itm.itemLink ~= nil then
                itemLink = itm.itemLink
            else
                itemLink = WL.buildItemLink(itm.id, itm.quality)
            end
            local traitId = itm.trait
            local itemTraitText = WL.TraitTypes[traitId]
            itemTraitText = WL.buildItemTraitIconText(itemTraitText, traitId)
            itemTraitText = itemTraitText or ""
            --Remove the history entry of the current, or the selected char
            table.remove(WishList_Data[savedVarsServer][displayName][charData.id][addonVars.addonSavedVarsDataTab][addonVars.addonSavedVarsHistoryTab], i)
            d(tos(itemLink)..GetString(WISHLIST_HISTORY_REMOVED) .. ", " .. itemTraitText .. charNameChat)
            cnt = cnt +1
        end
    end
    d(zo_strformat(GetString(WISHLIST_HISTORY_ITEMS_REMOVED) .. " " .. charNameChat .. " (" .. WL.getHistoryItemCount(charData) .. ")", cnt)) -- count.." item(s) removed from history"

    WL.updateRemoveAllButon()
    WishList:ReloadItems()
end

function WishList:RemoveAllHistoryItemsOfSet(setId, charData)
    if setId == nil then return false end
    local history = WL.getHistorySaveVars(charData)
    if history == nil then return true end
    --local charNameChat = WL.buildCharNameChatText(charData, nil)
    local displayName = GetDisplayName()
    local savedVarsServer = getSavedVarsServer()
    addonVars = WL.addonVars
    local charNameChat = charData.name
    local setName = ""
    local cnt = 0
    for i = #history, 1, -1 do
        local itm = history[i]
        if itm.setId == setId then
            local itemLink = WL.buildItemLink(itm.id, itm.quality)
            if setName == "" then
                local _, setLocName, _, _, _, setLocId = GetItemLinkSetInfo(itemLink, false)
                --Remove the gender stuff from the setname
                setName = zo_strformat("<<C:1>>", setLocName)
            end
            local traitId = itm.trait
            local itemTraitText = WL.TraitTypes[traitId]
            itemTraitText = WL.buildItemTraitIconText(itemTraitText, traitId)
            itemTraitText = itemTraitText or ""
            --Remove the WishList entry of the current, or the selected char
            --table.remove(history, i)
            table.remove(WishList_Data[savedVarsServer][displayName][charData.id][addonVars.addonSavedVarsDataTab][addonVars.addonSavedVarsHistoryTab], i)
            d(tos(itemLink)..GetString(WISHLIST_HISTORY_REMOVED) .. ", " .. itemTraitText .. charNameChat)
            cnt = cnt + 1
        end
    end
    d(zo_strformat(GetString(WISHLIST_HISTORY_ITEMS_REMOVED) .. ", Set: \"" .. setName .. "\" " .. charNameChat .. " (" .. WL.getHistoryItemCount(charData) .. ")", cnt)) -- count.." item(s) removed from history"

    WL.updateRemoveAllButon()
    WishList:ReloadItems()
end

function WishList:RemoveAllItems(charData)
    local wishList = WL.getWishListSaveVars(charData, "WishList:RemoveAllItems")
    if wishList == nil then return true end
    --local charNameChat = WL.buildCharNameChatText(charData, nil)
    local displayName = GetDisplayName()
    local savedVarsServer = getSavedVarsServer()
    addonVars = WL.addonVars
    local charNameChat = charData.name
    local cnt = 0
    for i = #wishList, 1, -1 do
        local itm = wishList[i]
        local itemLink = WL.buildItemLink(itm.id, itm.quality)
        local traitId = itm.trait
        local itemTraitText = WL.TraitTypes[traitId]
        itemTraitText = WL.buildItemTraitIconText(itemTraitText, traitId)
        itemTraitText = itemTraitText or ""
        --Remove the WishList entry of the current, or the selected char
        --wishList[i] = nil
        WishList_Data[savedVarsServer][displayName][charData.id][addonVars.addonSavedVarsDataTab][addonVars.addonSavedVarsWishListTab][i] = nil
        d(tos(itemLink)..GetString(WISHLIST_REMOVED) .. ", " .. itemTraitText .. charNameChat)
        cnt = cnt + 1
    end
    --Clear the wishlist of the current, or the selected char
    --wishList = {}
    WishList_Data[savedVarsServer][displayName][charData.id][addonVars.addonSavedVarsDataTab][addonVars.addonSavedVarsWishListTab] = nil
    d(zo_strformat(GetString(WISHLIST_ITEMS_REMOVED) .. charNameChat .. " (" .. WL.getWishListItemCount(charData) .. ")", cnt)) -- count.." item(s) removed from Wish List"

    WL.updateRemoveAllButon()
    WishList:ReloadItems()
end

function WishList:ClearHistory(charData)
    local history = WL.getHistorySaveVars(charData)
    if history == nil then return true end
    --local charNameChat = WL.buildCharNameChatText(charData, nil)
    local displayName = GetDisplayName()
    local savedVarsServer = getSavedVarsServer()
    addonVars = WL.addonVars
    local charNameChat = charData.name
    local cnt = 0
--d("[WishList:ClearHistory]char: " .. tos(charNameChat))
    for i = #history, 1, -1 do
        local itm = history[i]
        local itemLink = WL.buildItemLink(itm.id, itm.quality)
        local traitId = itm.trait
        local itemTraitText = WL.TraitTypes[traitId]
        itemTraitText = WL.buildItemTraitIconText(itemTraitText, traitId)
        itemTraitText = itemTraitText or ""
        --Remove the History entry of the current, or the selected char
        --history[i] = nil
        WishList_Data[savedVarsServer][displayName][charData.id][addonVars.addonSavedVarsDataTab][addonVars.addonSavedVarsHistoryTab][i] = nil
        d(tos(itemLink)..GetString(WISHLIST_HISTORY_REMOVED) .. ", " .. itemTraitText .. charNameChat)
        cnt = cnt + 1
    end
    --Clear the wishlist of the current, or the selected char
    --history = {}
    WishList_Data[savedVarsServer][displayName][charData.id][addonVars.addonSavedVarsDataTab][addonVars.addonSavedVarsHistoryTab] = nil
    d(zo_strformat(GetString(WISHLIST_HISTORY_ITEMS_REMOVED) .. charNameChat .. " (" .. WL.getHistoryItemCount(charData) .. ")", cnt)) -- count.." item(s) removed from history"

    WL.updateRemoveAllButon()
    WishList:ReloadItems()
end

function WishList:ReloadItems()
    if not WL.window or not WL.windowShown then return false end
    WL.window:RefreshData()
end

--Add a last added setItems history (added via the "Add item dialog")
function WishList:AddLastAddedHistory(newAddedData)
    if not newAddedData then return end
    newAddedData.dateTime = newAddedData.dateTime or GetTimeStamp()
    --local lastAddedHistoryData = WL.accData.lastAddedViaDialog
    WL.accData.lastAddedViaDialog = WL.accData.lastAddedViaDialog or {}
    WL.accData.lastAddedViaDialog[newAddedData.dateTime] = newAddedData
end

--Get the last added setItems history (added via the "Add item dialog")
function WishList:GetLastAddedHistory()
    local lastAddedHistoryData = WL.accData.lastAddedViaDialog
    if not lastAddedHistoryData then return end
    return lastAddedHistoryData
end


--Gear
local function removeGearDataFromWishListEntry(wishListItem, gearData)
--d("[WL.removeGearDataFromWishListEntry]")
    if wishListItem ~= nil and gearData ~= nil then
        wishListItem.gearId = nil
        wishListItem.gearMarkerTextureId = nil
        wishListItem.gearMarkerTextureColor = nil
        wishListItem.copiedFromFCOIS = nil
        wishListItem.copiedFromFCOISTimestamp = nil
        return WL_getGearMarkerTexture(gearData, true, 28, 28)
    end
    return
end

local function assignGearDataToWishListEntry(wishListItem, gearData)
--d("[WL.assignGearDataToWishListEntry]")
    if wishListItem ~= nil and gearData ~= nil and gearData.gearId ~= nil and gearData.gearId > 0 then
        removeGearDataFromWishListEntry(wishListItem)
        wishListItem.gearId = gearData.gearId
        return WL_getGearMarkerTexture(gearData, true, 28, 28)
    end
    return
end


function WishList:AddGearMarker(item, charData, gearData)
--d("WishList:AddGearMarker-item.id: " ..tos(item.id))
    if gearData == nil or gearData.gearId == nil or gearData.gearId == 0 then return end
    local index = -1
    local wishList = WL.getWishListSaveVars(charData, "WishList:AddGearMarker")
    if wishList == nil then return true end
    --local charNameChat = WL.buildCharNameChatText(charData, nil)
    local displayName = GetDisplayName()
    local savedVarsServer = getSavedVarsServer()
    addonVars = WL.addonVars
    local charNameChat = charData.name
--d(">charNameChat: " ..tos(charNameChat))
	for i = 1, #wishList do
		local itm = wishList[i]
		if itm.id == item.id then
			index = i
			break
		end
	end
--d(">>index: " ..tos(index))
	if index ~= -1 then
        local itemAtWishList = WishList_Data[savedVarsServer][displayName][charData.id][addonVars.addonSavedVarsDataTab][addonVars.addonSavedVarsWishListTab][index]
        if itemAtWishList ~= nil then
            local gearMarkerTextureOld = assignGearDataToWishListEntry(WishList_Data[savedVarsServer][displayName][charData.id][addonVars.addonSavedVarsDataTab][addonVars.addonSavedVarsWishListTab][index], gearData)
            if gearMarkerTextureOld ~= nil then
                local itemLink
                if item.itemLink ~= nil then
                    itemLink = item.itemLink
                else
                    itemLink = WL.buildItemLink(item.id, item.quality)
                end
                local traitId = item.trait
                local itemTraitText = WL.TraitTypes[traitId]
                itemTraitText = WL.buildItemTraitIconText(itemTraitText, traitId)
                itemTraitText = itemTraitText or ""
                d(zo_strformat(GetString(WISHLIST_GEAR_MARKER_ADDED), gearMarkerTextureOld, tos(itemLink) .. ", " .. itemTraitText .. charNameChat .. " (" .. WL.getWishListItemCount(charData) .. ")"))
            end
        end
	end
    WishList:ReloadItems()
end

function WishList:AddGearMarkerToSet(setId, charData, gearData, addAll)
    addAll = addAll or false
--d("WishList:AddGearMarkerToSet-setId: " ..tos(setId) .. ", addAll: " ..tos(addAll))
    if setId == nil then return false end
    local wishList = WL.getWishListSaveVars(charData, "WishList:AddGearMarkerToSet")
    if wishList == nil then return true end
    --local charNameChat = WL.buildCharNameChatText(charData, nil)
    local displayName = GetDisplayName()
    local savedVarsServer = getSavedVarsServer()
    addonVars = WL.addonVars
    local charNameChat = charData.name
    local setName = ""
    local cnt = 0
    for i = #wishList, 1, -1 do
        local itm = wishList[i]
        if itm.setId == setId then
            local itemLink = WL.buildItemLink(itm.id, itm.quality)
            if setName == "" then
                local _, setLocName, _, _, _, _ = GetItemLinkSetInfo(itemLink, false)
                --Remove the gender stuff from the setname
                setName = zo_strformat("<<C:1>>", setLocName)
            end
                local itemAtWishList = WishList_Data[savedVarsServer][displayName][charData.id][addonVars.addonSavedVarsDataTab][addonVars.addonSavedVarsWishListTab][i]
                if itemAtWishList ~= nil then
                    local gearMarkerTextureOld = assignGearDataToWishListEntry(WishList_Data[savedVarsServer][displayName][charData.id][addonVars.addonSavedVarsDataTab][addonVars.addonSavedVarsWishListTab][i], gearData)
                    if gearMarkerTextureOld ~= nil then
                        local traitId = itm.trait
                        local itemTraitText = WL.TraitTypes[traitId]
                        itemTraitText = WL.buildItemTraitIconText(itemTraitText, traitId)
                        itemTraitText = itemTraitText or ""
                        d(zo_strformat(GetString(WISHLIST_GEAR_MARKER_ADDED), gearMarkerTextureOld, tos(itemLink) .. ", " .. itemTraitText))
                        cnt = cnt +1
                    end
                end
            end
    end
    d(zo_strformat(GetString(WISHLIST_GEAR_MARKERS_ADDED) .. ", Set: \"" .. setName .. "\" " .. charNameChat .. " (" .. WL.getWishListItemCount(charData) .. ")", cnt))

    WishList:ReloadItems()
end

function WishList:AddAllGearMarkersWithCriteria(criteria, charData, addToWishListsInLoop, gearData, addGearMarkersToAllItensOnWishList)
    addToWishListsInLoop = addToWishListsInLoop or false
    addGearMarkersToAllItensOnWishList = addGearMarkersToAllItensOnWishList or false
--d("[WL]AddAllGearMarkersWithCriteria-addToWishListsInLoop: " ..tos(addToWishListsInLoop) .. ", addGearMarkersToAllItensOnWishList: " ..tos(addGearMarkersToAllItensOnWishList))
    if criteria == nil then return false end
    if gearData == nil or gearData.gearId == nil or gearData.gearId == 0 then return end
    --local gearId = gearData.gearId
    local wishList = WL.getWishListSaveVars(charData, "WishList:AddAllGearMarkersWithCriteria")
    if wishList == nil then return true end
    --local charNameChat = WL.buildCharNameChatText(charData, nil)
    local displayName = GetDisplayName()
    local savedVarsServer = getSavedVarsServer()
    addonVars = WL.addonVars
    local charNameChat = charData.name
    local allTraitsId = WISHLIST_TRAIT_TYPE_ALL --All traits
    local checkSetId = false
    if criteria.setId ~= nil then
        checkSetId = true
    end
    --d(">checkSetId: " ..tos(checkSetId))
    local cnt = 0
    for i = #wishList, 1, -1 do
        local itm = wishList[i]
        --Check the criteria now, which is specified, and combine them for a check against the WishList items
        local addItemNow = false
        if addItemNow == false and addGearMarkersToAllItensOnWishList == true then
            addItemNow = true
        end
        if addItemNow == false then
            local setIdGiven = (checkSetId == true and itm.setId and itm.setId == criteria.setId) or false
            --setId must match or wasn't given as criteria
            if checkSetId == false or setIdGiven == true then
                if addItemNow == false and criteria.timestamp ~= nil then
                    --d(">timestamp: " ..tos(criteria.timestamp) .. "/" .. tos(itm.timestamp))
                    if itm.timestamp == criteria.timestamp then
                        addItemNow = true
                    else
                        addItemNow = false
                    end
                end
                if addItemNow == false and criteria.itemType ~= nil then
                    --d(">itemType: " ..tos(criteria.itemType) .. "/" .. tos(itm.itemType))
                    if itm.itemType == criteria.itemType then
                        if criteria.armorOrWeaponType == nil and criteria.slot ~= nil then
                            addItemNow = true
                        else
                            if criteria.armorOrWeaponType ~= nil then
                                --d(">>armorOrWeaponType: " ..tos(criteria.armorOrWeaponType) .. "/" .. tos(itm.armorOrWeaponType))
                                if itm.armorOrWeaponType == criteria.armorOrWeaponType then
                                    if criteria.slot ~= nil then
                                        --d(">>>slot: " ..tos(criteria.slot) .. "/" .. tos(itm.slot))
                                        if itm.slot == criteria.slot then
                                            addItemNow = true
                                        else
                                            addItemNow = false
                                        end
                                    else
                                        addItemNow = false
                                    end
                                else
                                    addItemNow = false
                                end
                            else
                                if criteria.slot ~= nil then
                                    --d(">>slot: " ..tos(criteria.slot) .. "/" .. tos(itm.slot))
                                    if itm.slot == criteria.slot then
                                        addItemNow = true
                                    else
                                        addItemNow = false
                                    end
                                else
                                    addItemNow = false
                                end
                            end
                        end
                    else
                        addItemNow = false
                    end
                end
                if addItemNow == false and criteria.armorOrWeaponType ~= nil and criteria.itemType == nil and criteria.slot == nil then
                    --d(">armorOrWeaponType: " ..tos(criteria.armorOrWeaponType) .. "/" .. tos(itm.armorOrWeaponType))
                    if itm.armorOrWeaponType == criteria.armorOrWeaponType then
                        addItemNow = true
                    else
                        addItemNow = false
                    end
                end
                if addItemNow == false and criteria.slot ~= nil and criteria.itemType == nil and criteria.armorOrWeaponType == nil then
                    --d(">slot: " ..tos(criteria.slot) .. "/" .. tos(itm.slot))
                    if itm.slot == criteria.slot then
                        addItemNow = true
                    else
                        addItemNow = false
                    end
                end
                if addItemNow == false and criteria.trait ~= nil then
                    --d(">trait: " ..tos(criteria.trait) .. "/" .. tos(itm.trait))
                    if criteria.trait == allTraitsId or itm.trait == criteria.trait then
                        addItemNow = true
                    else
                        addItemNow = false
                    end
                end
            end
        end
        if addItemNow then
            --d(">>>remove item now!")
            local itemLink
            if itm.itemLink ~= nil then
                itemLink = itm.itemLink
            else
                itemLink = WL.buildItemLink(itm.id, itm.quality)
            end
            local traitId = itm.trait
            local itemTraitText = WL.TraitTypes[traitId]
            itemTraitText = WL.buildItemTraitIconText(itemTraitText, traitId)
            itemTraitText = itemTraitText or ""
            --Remove the gear marker
            --table.remove(WishList_Data[savedVarsServer][displayName][charData.id][addonVars.addonSavedVarsDataTab][addonVars.addonSavedVarsWishListTab], i)
            --d(tos(itemLink)..GetString(WISHLIST_REMOVED) .. ", " .. itemTraitText .. charNameChat)
            local itemAtWishList = WishList_Data[savedVarsServer][displayName][charData.id][addonVars.addonSavedVarsDataTab][addonVars.addonSavedVarsWishListTab][i]
            if itemAtWishList ~= nil then
                local gearMarkerTextureOld = assignGearDataToWishListEntry(WishList_Data[savedVarsServer][displayName][charData.id][addonVars.addonSavedVarsDataTab][addonVars.addonSavedVarsWishListTab][i], gearData)
                if gearMarkerTextureOld ~= nil then
                    d(zo_strformat(GetString(WISHLIST_GEAR_MARKER_ADDED), gearMarkerTextureOld, tos(itemLink) .. ", " .. itemTraitText .. charNameChat))
                    cnt = cnt +1
                end
            end
        end
    end
    d(zo_strformat(GetString(WISHLIST_GEAR_MARKERS_ADDED) .. " " .. charNameChat .. " (" .. WL.getWishListItemCount(charData) .. ")", cnt))

    local updateNow = false
    if addToWishListsInLoop == true then
        if WL.CurrentCharData ~= nil and WL.CurrentCharData.id ~= nil and charData.id == WL.CurrentCharData.id then
            updateNow = true
        end
    else
        updateNow = true
    end
    if updateNow then
        WishList:ReloadItems()
    end
end


function WishList:RemoveGearMarker(item, charData, gearData)
--d("WishList:RemoveGearMarker")
    if gearData == nil or gearData.gearId == nil or gearData.gearId == 0 then return end
    local gearId = gearData.gearId
    local index = -1
    local wishList = WL.getWishListSaveVars(charData, "WishList:RemoveGearMarker")
    if wishList == nil then return true end
    --local charNameChat = WL.buildCharNameChatText(charData, nil)
    local displayName = GetDisplayName()
    local savedVarsServer = getSavedVarsServer()
    addonVars = WL.addonVars
    local charNameChat = charData.name
	for i = 1, #wishList do
		local itm = wishList[i]
		if itm.id == item.id then
			index = i
			break
		end
	end
	if index ~= -1 then
        local itemAtWishList = WishList_Data[savedVarsServer][displayName][charData.id][addonVars.addonSavedVarsDataTab][addonVars.addonSavedVarsWishListTab][index]
        if itemAtWishList ~= nil and itemAtWishList.gearId ~= nil and itemAtWishList.gearId > 0 and itemAtWishList.gearId == gearId then
            local gearMarkerTextureOld = removeGearDataFromWishListEntry(WishList_Data[savedVarsServer][displayName][charData.id][addonVars.addonSavedVarsDataTab][addonVars.addonSavedVarsWishListTab][index], gearData)
            if gearMarkerTextureOld ~= nil then
                local itemLink
                if item.itemLink ~= nil then
                    itemLink = item.itemLink
                else
                    itemLink = WL.buildItemLink(item.id, item.quality)
                end
                local traitId = item.trait
                local itemTraitText = WL.TraitTypes[traitId]
                itemTraitText = WL.buildItemTraitIconText(itemTraitText, traitId)
                itemTraitText = itemTraitText or ""
                d(zo_strformat(GetString(WISHLIST_GEAR_MARKER_REMOVED), gearMarkerTextureOld, tos(itemLink) .. ", " .. itemTraitText .. charNameChat .. " (" .. WL.getWishListItemCount(charData) .. ")"))
            end
        end
	end
    WishList:ReloadItems()
end

function WishList:RemoveAllGearMarkersWithCriteria(criteria, charData, removeFromWishListsInLoop, gearData, removeAll)
    removeFromWishListsInLoop = removeFromWishListsInLoop or false
    removeAll = removeAll or false
--d("[WL]RemoveAllGearMarkersWithCriteria-removeFromWishListsInLoop: " ..tos(removeFromWishListsInLoop) .. ", removeAll: " ..tos(removeAll))
    if criteria == nil then return false end
    if gearData == nil or gearData.gearId == nil or gearData.gearId == 0 then return end
    local gearId = gearData.gearId
    local wishList = WL.getWishListSaveVars(charData, "WishList:RemoveAllGearMarkersWithCriteria")
    if wishList == nil then return true end
    --local charNameChat = WL.buildCharNameChatText(charData, nil)
    local displayName = GetDisplayName()
    local savedVarsServer = getSavedVarsServer()
    addonVars = WL.addonVars
    local charNameChat = charData.name
    local allTraitsId = WISHLIST_TRAIT_TYPE_ALL --All traits
    local checkSetId = false
    if criteria.setId ~= nil then
        checkSetId = true
    end
--d(">checkSetId: " ..tos(checkSetId))
    local cnt = 0
    for i = #wishList, 1, -1 do
        local itm = wishList[i]
        --Check the criteria now, which is specified, and combine them for a check against the WishList items
        local removeItemNow = false
        if removeItemNow == false and removeAll == true then
            removeItemNow = true
        else
            local setIdGiven = (checkSetId == true and itm.setId and itm.setId == criteria.setId) or false
            --setId must match or wasn't given as criteria
            if checkSetId == false or setIdGiven == true then
                if removeItemNow == false and criteria.removeFromAllWishLists == true then
                    removeItemNow = true
                end
                if removeItemNow == false and criteria.timestamp ~= nil then
                    --d(">timestamp: " ..tos(criteria.timestamp) .. "/" .. tos(itm.timestamp))
                    if itm.timestamp == criteria.timestamp then
                        removeItemNow = true
                    else
                        removeItemNow = false
                    end
                end
                if removeItemNow == false and criteria.itemType ~= nil then
                    --d(">itemType: " ..tos(criteria.itemType) .. "/" .. tos(itm.itemType))
                    if itm.itemType == criteria.itemType then
                        if criteria.armorOrWeaponType == nil and criteria.slot ~= nil then
                            removeItemNow = true
                        else
                            if criteria.armorOrWeaponType ~= nil then
                                --d(">>armorOrWeaponType: " ..tos(criteria.armorOrWeaponType) .. "/" .. tos(itm.armorOrWeaponType))
                                if itm.armorOrWeaponType == criteria.armorOrWeaponType then
                                    if criteria.slot ~= nil then
                                        --d(">>>slot: " ..tos(criteria.slot) .. "/" .. tos(itm.slot))
                                        if itm.slot == criteria.slot then
                                            removeItemNow = true
                                        else
                                            removeItemNow = false
                                        end
                                    else
                                        removeItemNow = false
                                    end
                                else
                                    removeItemNow = false
                                end
                            else
                                if criteria.slot ~= nil then
                                    --d(">>slot: " ..tos(criteria.slot) .. "/" .. tos(itm.slot))
                                    if itm.slot == criteria.slot then
                                        removeItemNow = true
                                    else
                                        removeItemNow = false
                                    end
                                else
                                    removeItemNow = false
                                end
                            end
                        end
                    else
                        removeItemNow = false
                    end
                end
                if removeItemNow == false and criteria.armorOrWeaponType ~= nil and criteria.itemType == nil and criteria.slot == nil then
                    --d(">armorOrWeaponType: " ..tos(criteria.armorOrWeaponType) .. "/" .. tos(itm.armorOrWeaponType))
                    if itm.armorOrWeaponType == criteria.armorOrWeaponType then
                        removeItemNow = true
                    else
                        removeItemNow = false
                    end
                end
                if removeItemNow == false and criteria.slot ~= nil and criteria.itemType == nil and criteria.armorOrWeaponType == nil then
                    --d(">slot: " ..tos(criteria.slot) .. "/" .. tos(itm.slot))
                    if itm.slot == criteria.slot then
                        removeItemNow = true
                    else
                        removeItemNow = false
                    end
                end
                if removeItemNow == false and criteria.trait ~= nil then
                    --d(">trait: " ..tos(criteria.trait) .. "/" .. tos(itm.trait))
                    if criteria.trait == allTraitsId or itm.trait == criteria.trait then
                        removeItemNow = true
                    else
                        removeItemNow = false
                    end
                end
            end
        end
        if removeItemNow == true then
            local itemLink
            if itm.itemLink ~= nil then
                itemLink = itm.itemLink
            else
                itemLink = WL.buildItemLink(itm.id, itm.quality)
            end
--d(">>>remove item now! " ..itemLink)
            local traitId = itm.trait
            local itemTraitText = WL.TraitTypes[traitId]
            itemTraitText = WL.buildItemTraitIconText(itemTraitText, traitId)
            itemTraitText = itemTraitText or ""
            --Remove the gear marker
            --table.remove(WishList_Data[savedVarsServer][displayName][charData.id][addonVars.addonSavedVarsDataTab][addonVars.addonSavedVarsWishListTab], i)
            --d(tos(itemLink)..GetString(WISHLIST_REMOVED) .. ", " .. itemTraitText .. charNameChat)
            local itemAtWishList = WishList_Data[savedVarsServer][displayName][charData.id][addonVars.addonSavedVarsDataTab][addonVars.addonSavedVarsWishListTab][i]
            if itemAtWishList ~= nil and itemAtWishList.gearId ~= nil and itemAtWishList.gearId > 0 and itemAtWishList.gearId == gearId then
                local gearMarkerTextureOld = removeGearDataFromWishListEntry(WishList_Data[savedVarsServer][displayName][charData.id][addonVars.addonSavedVarsDataTab][addonVars.addonSavedVarsWishListTab][i], gearData)
--d(">>>>gearMarkerTextureOld: " ..tostring(gearMarkerTextureOld))
                if gearMarkerTextureOld ~= nil then
                    d(zo_strformat(GetString(WISHLIST_GEAR_MARKER_REMOVED), gearMarkerTextureOld, tos(itemLink) .. ", " .. itemTraitText .. charNameChat))
                    cnt = cnt +1
                end
            end

        end
    end
    d(zo_strformat(GetString(WISHLIST_GEAR_MARKERS_REMOVED) .. " " .. charNameChat .. " (" .. WL.getWishListItemCount(charData) .. ")", cnt))

    local updateNow = false
    if removeFromWishListsInLoop == true then
        if WL.CurrentCharData ~= nil and WL.CurrentCharData.id ~= nil and charData.id == WL.CurrentCharData.id then
            updateNow = true
        end
    else
        updateNow = true
    end
    if updateNow then
        WishList:ReloadItems()
    end
end


function WishList:RemoveGearMarkerOfSet(setId, charData, gearData, removeAll)
    --d("[WhishList]RemoveAllGearMarkersOfSet, setId: " ..tos(setId) .. ", removeAll: " ..tos(removeAll))
    if setId == nil then return false end
    if gearData == nil or gearData.gearId == nil or gearData.gearId == 0 then return end
    local gearId = gearData.gearId
    removeAll = removeAll or false
    local wishList = WL.getWishListSaveVars(charData, "WishList:RemoveAllGearMarkersOfSet")
    if wishList == nil then return true end
    --local charNameChat = WL.buildCharNameChatText(charData, nil)
    local displayName = GetDisplayName()
    local savedVarsServer = getSavedVarsServer()
    addonVars = WL.addonVars
    local charNameChat = charData.name
    local setName = ""
    local cnt = 0
    for i = #wishList, 1, -1 do
        local itm = wishList[i]
        if itm.setId == setId then
            local itemLink = WL.buildItemLink(itm.id, itm.quality)
            if setName == "" then
                local _, setLocName, _, _, _, _ = GetItemLinkSetInfo(itemLink, false)
                --Remove the gender stuff from the setname
                setName = zo_strformat("<<C:1>>", setLocName)
            end
            local traitId = itm.trait
            local itemTraitText = WL.TraitTypes[traitId]
            itemTraitText = WL.buildItemTraitIconText(itemTraitText, traitId)
            itemTraitText = itemTraitText or ""
            --Remove the gear marker of the current, or the selected char
            local itemAtWishList = WishList_Data[savedVarsServer][displayName][charData.id][addonVars.addonSavedVarsDataTab][addonVars.addonSavedVarsWishListTab][i]
            if itemAtWishList ~= nil and itemAtWishList.gearId ~= nil and itemAtWishList.gearId > 0 and (removeAll == true or (removeAll == false and itemAtWishList.gearId == gearId)) then
                local gearMarkerTextureOld = removeGearDataFromWishListEntry(WishList_Data[savedVarsServer][displayName][charData.id][addonVars.addonSavedVarsDataTab][addonVars.addonSavedVarsWishListTab][i], gearData)
                if gearMarkerTextureOld ~= nil then
                    d(zo_strformat(GetString(WISHLIST_GEAR_MARKER_REMOVED), gearMarkerTextureOld, tos(itemLink) .. ", " .. itemTraitText .. charNameChat))
                    cnt = cnt +1
                end
            end
        end
    end
    d(zo_strformat(GetString(WISHLIST_GEAR_MARKERS_REMOVED) .. ", Set: \"" .. setName .. "\" " .. charNameChat .. " (" .. WL.getWishListItemCount(charData) .. ")", cnt))
    WishList:ReloadItems()
end


--SetItemCollection stuff
function WL.addItemSetCollectionSinglePieceItemLinkToWishList(itemLink, addOneSingleTraitItem)
    if not itemLink or itemLink == "" then return end
--d("[WishList]Add all traits to WishList, by SetItemCollection item: " ..itemLink)
    local hasSet, _, _, _, _, setId = GetItemLinkSetInfo(itemLink, false)
    if not hasSet or not setId then return end

    local itemType = GetItemLinkItemType(itemLink)
    local armorOrWeaponType
    if itemType == ITEMTYPE_ARMOR then
        armorOrWeaponType = GetItemLinkArmorType(itemLink)
    elseif itemType == ITEMTYPE_WEAPON then
        armorOrWeaponType = GetItemLinkWeaponType(itemLink)
    end
    local equipType = GetItemLinkEquipType(itemLink)
    local allTraitsTraitId = WISHLIST_TRAIT_TYPE_ALL --All traits

    --[[
    WL.checkCurrentCharData(false, true)
    local settings = WL.data
    local charData
    if settings.preSelectLoggedinCharAtItemAddDialog == true then
        charData = WL.LoggedInCharData
    else
        charData = WL.CurrentCharData
        if charData == nil or charData.id == nil then
            charData = WL.LoggedInCharData
        end
    end
    ]]
    local items = {}
    --Get the set parts to add for this setId
    items = WL.getSetItemsByCriteria(setId, itemType, armorOrWeaponType, allTraitsTraitId, equipType, WISHLIST_QUALITY_ALL, addOneSingleTraitItem) --only 1 item with all traits?

    --Add the items now, if some were found
    if #items > 0 then
        --Add the found set items to the WishList of the selected user now
        --WishList:AddItem(items, charData)
        --WL.ShowChooseChar(doAWishListCopy, addItemForCharData, comingFromWishListWindow)
        WL.ShowChooseChar(false, items, false, true)
    end
end

function WL.removeItemSetCollectionSinglePieceItemLinkFromWishList(itemLink, removeType)
    if not itemLink or itemLink == "" then return end
--d("[WishList]Remove all traits from WishList, by SetItemCollection item: " ..itemLink)

    local hasSet, _, _, _, _, setId = GetItemLinkSetInfo(itemLink, false)
    if not hasSet or not setId then return end

    local itemType = GetItemLinkItemType(itemLink)
    local armorOrWeaponType
    if itemType == ITEMTYPE_ARMOR then
        armorOrWeaponType = GetItemLinkArmorType(itemLink)
    elseif itemType == ITEMTYPE_WEAPON then
        armorOrWeaponType = GetItemLinkWeaponType(itemLink)
    end
    local equipType = GetItemLinkEquipType(itemLink)
    local allTraitsTraitId = WISHLIST_TRAIT_TYPE_ALL --All traits

--d(">SetId: " ..tos(setId) .. ", removeType: " ..tos(removeType))
--d(">>itemType: " ..tos(itemType) .. ", armorOrWeaponType: " ..tos(armorOrWeaponType) .. ", slotType: " ..tos(equipType))

    local criteriaToIdentifyItemsToRemove = {}
    if removeType == WISHLIST_REMOVE_ITEM_TYPE_ARMORANDWEAPONTYPE_SLOT then
        criteriaToIdentifyItemsToRemove.setId = setId
        criteriaToIdentifyItemsToRemove.itemType = itemType
        criteriaToIdentifyItemsToRemove.armorOrWeaponType = armorOrWeaponType
        criteriaToIdentifyItemsToRemove.slot = equipType
    elseif removeType == WISHLIST_REMOVE_ITEM_TYPE_ARMORANDWEAPONTYPE then
        criteriaToIdentifyItemsToRemove.setId = setId
        criteriaToIdentifyItemsToRemove.itemType = itemType
        criteriaToIdentifyItemsToRemove.armorOrWeaponType = armorOrWeaponType
    elseif removeType == WISHLIST_REMOVE_ITEM_TYPE_SLOT then
        criteriaToIdentifyItemsToRemove.setId = setId
        criteriaToIdentifyItemsToRemove.slot = equipType
    elseif removeType == WISHLIST_REMOVE_ITEM_TYPE then
        criteriaToIdentifyItemsToRemove.setId = setId
        criteriaToIdentifyItemsToRemove.itemType = itemType
    elseif removeType == WISHLIST_REMOVE_ITEM_TYPE_TRAIT then
        criteriaToIdentifyItemsToRemove.setId = setId
        criteriaToIdentifyItemsToRemove.trait = allTraitsTraitId
    end

    WL.checkCurrentCharData(false, true)
    local settings = WL.data
    local charData
    if settings.preSelectLoggedinCharAtItemAddDialog == true then
        charData = WL.LoggedInCharData
    else
        charData = WL.CurrentCharData
        if charData == nil or charData.id == nil then
            charData = WL.LoggedInCharData
        end
    end
    if criteriaToIdentifyItemsToRemove ~= nil and criteriaToIdentifyItemsToRemove.setId ~= nil then
        WishList:RemoveAllItemsWithCriteria(criteriaToIdentifyItemsToRemove, charData, false)
    end
end

------------------------------------------------
--- Settings / SavedVariables
------------------------------------------------
local function fixSVData()
    --Fix the entries with ["traitId"] = 34 or 35 to 999 --all traits
    local atLeastOneEntryFixed = false
    local traitIdsToReplace = {
        [34] = true,
        [35] = true,
    }
    local traitIdToReplaceWith = WISHLIST_TRAIT_TYPE_ALL
    local traitIdsFixedCount = 0

    --Per character data
    WL.charsData = WL.buildCharsDropEntries()
    if WL.charsData and #WL.charsData > 0 then
        for _, charData in ipairs(WL.charsData) do
            local wishList = WL.getWishListSaveVars(charData, "WishList:fixSVData", nil)
            if wishList ~= nil then
                for wlIndex, wlEntryData in pairs(wishList) do
                    if wlEntryData and wlEntryData["trait"] ~= nil and traitIdsToReplace[tonumber(wlEntryData["trait"])] then
                        wishList[wlIndex]["trait"] = traitIdToReplaceWith
                        atLeastOneEntryFixed = true
                        traitIdsFixedCount = traitIdsFixedCount + 1
                    end
                end
            end
            local history = WL.getHistorySaveVars(charData, "WishList:fixSVData", nil)
            if history ~= nil then
                for histIndex, hisEntryData in pairs(history) do
                    if hisEntryData and hisEntryData["trait"] ~= nil and traitIdsToReplace[tonumber(hisEntryData["trait"])] then
                        history[histIndex]["trait"] = traitIdToReplaceWith
                        atLeastOneEntryFixed  = true
                        traitIdsFixedCount = traitIdsFixedCount + 1
                    end
                end
            end
        end
    end
    --Account wide data
    for addedIndex, addedData in pairs(WL.accData.lastAddedViaDialog) do
        if addedData and addedData["trait"] and traitIdsToReplace[tonumber(addedData["trait"])] then
            WL.accData.lastAddedViaDialog[addedIndex]["trait"] = traitIdToReplaceWith
            atLeastOneEntryFixed = true
            traitIdsFixedCount = traitIdsFixedCount + 1
        end
    end

    if atLeastOneEntryFixed == true then
        d("[WishList]Fixed " ..tos(traitIdsFixedCount) .. " traitIds in the SavedVariables to the new ALL constant!")
        ReloadUI("ingame")
    end
end

local function afterSettings()
    --==================================================================================================================
    --UPDATES TO THE SETTINGS AFTER THEY HAVE BEEN LOADED
    --==================================================================================================================
    local settings = WL.data

    --WishList version 2.8: TRansfer old obsolete setting useSortTiebrakerName (if set) to new dropdown box setting useSortTiebraker
    if settings.useSortTiebrakerName ~= nil then
        if settings.useSortTiebrakerName == true then
            WL.data.useSortTiebraker = 1
        end
        WL.data.useSortTiebrakerName = nil
    end

    --WishList version 2.96: Added "Add dialog" history of last added data
    --Build characterId entries in the accountWide SavedVariables
    --settings.dialogAddHistory

    --WishList version 3.03 - Gear data - Check for empty subtables in SV .gears table and fill them with default values
    local gears = WL.data.gears
    if gears ~= nil then
        for gearId, gearData in pairs(gears) do
            if gearData == nil or (gearData ~= nil and gearData.name == nil or gearData.gearMarkerTextureId == nil
                or gearData.gearMarkerTextureColor == nil or gearData.gearId == nil) then

                --TODO check if the gearId is still used at any marker icon at the WishLists and if not remove it in total

                --Else if still used: "Fix" the gear with missing data = default data
                if gearData == nil then
                    WL.data.gears[gearId] = {
                        gearId = gearId,
                        name =                  "Gear # " ..tos(gearId),
                        comment =               "",
                        gearMarkerTextureId =   1,
                        gearMarkerTextureColor= {["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1},
                    }
                else
                    local oldGearData = ZO_ShallowTableCopy(gearData)
                    WL.data.gears[gearId] = {
                        gearId = gearId,
                        name =                  (oldGearData.name ~= nil and oldGearData.name) or "Gear # " ..tos(gearId),
                        comment =               (oldGearData.comment ~= nil and oldGearData.comment) or "",
                        gearMarkerTextureId =   (oldGearData.gearMarkerTextureId ~= nil and oldGearData.gearMarkerTextureId) or 1,
                        gearMarkerTextureColor= (oldGearData.gearMarkerTextureColor ~= nil and oldGearData.gearMarkerTextureColor) or {["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1},
                    }
                end
            end
        end
    end
end

--Migrate the SavedVariables from server non-dependent to server dependent ones
local function migrateSavedVarsToServerDependent()
    local worldName = GetWorldName()
    d(GetString(WISHLIST_SV_MIGRATION_TO_SERVER_START))
    local accountName = GetDisplayName()
    if not accountName then return end
    addonVars = WL.addonVars
    --local accountWideSaved = addonVars.addonSavedVarsAccountWide
    --[[
         ["Default"] =
        {
            ["@Baertram"] =
            {
                ["$AccountWide"] =
                {
                },
                ["8798292065306120"] =
                {
                },
                ...
            },
        }
    ]]
    --We got all character data in this table (but it was saved account wide!)
    local svDataOFAllAccounts = WishList_Data[addonVars.addonSavedVarsDefault]
    if svDataOFAllAccounts ~= nil then
        local copyOfNonServerDependentSV = ZO_ShallowTableCopy(svDataOFAllAccounts)
        if copyOfNonServerDependentSV ~= nil then
            --d(">>Created copy of all accounts and characters, and moved them to the server dependent SV.")
            --Create ServerDependent SavedVariable subtables at top (= "profile" parameter of ZO_SavedVars:New(..., profile, ...))
            WishList_Data[worldName] = copyOfNonServerDependentSV
            return true
        end
    end
    return false
end

function WL.loadSettings()
    WL.SVrelated_doReloadUINow = false
    addonVars = WL.addonVars
    local lang = GetCVar("language.2")
    if lang == "de" then
        WL.defaultAccSettings.use24hFormat = true
    end

    local worldName = nil
    --Get non-server dependent general settings
    local accDataServerIndependent = ZO_SavedVars:NewAccountWide(addonVars.addonSavedVarsAllServers, 999, addonVars.addonSavedVarsAccountWideServerIndependent, {}, nil, nil)
    if accDataServerIndependent.savedVarsWereMigratedToServerDependent == true then
        --SV were migrated to the table containing the worldname e.g. "EU Megaserver"
        worldName = GetWorldName()
        if WishList_Data[worldName] ~= nil then
            --Invalidate the old non-server dependent SavedVariables
            if WishList_Data[addonVars.addonSavedVarsDefault] ~= nil then
                d(GetString(WISHLIST_SV_MIGRATION_STILL_OLD_DATA_FOUND))
                WishList_Data[addonVars.addonSavedVarsDefault] = nil
                WL.SVrelated_doReloadUINow = true
            end
        end
    end

    --Load the account wide settings (Sets, save mode of SavedVars, etc.)
    --worldName will be nil before migration so the data wil be read from the old $AccountWide table.
    --After migration the $AccountWide table (without server!) contains the boolean entry "savedVarsWereMigratedToServerDependent=true", and thus the variable
    --worldName will be e.g. "EU Megaserver"
    --ZO_SavedVars:NewAccountWide(savedVariableTable, version, namespace, defaults, profile, displayName)
    WL.accData = ZO_SavedVars:NewAccountWide(addonVars.addonSavedVars, 999, addonVars.addonSavedVarsAccountWideDataTab, WL.defaultAccSettings, worldName, nil)

    --Check, by help of basic version 999 settings, if the settings should be loaded for each character or account wide
    --Use the current addon version to read the settings now
    if WL.accData.saveMode == 1 then
        --Load the character user settings
        WL.data = ZO_SavedVars:NewCharacterIdSettings(addonVars.addonSavedVars, addonVars.addonSavedVarsVersion, addonVars.addonSavedVarsDataTab, WL.defaultSettings, worldName)
        --------------------------------------------------------------------------------------------------------------------
    else
        --Load the account wide user settings
        WL.data = ZO_SavedVars:NewAccountWide(addonVars.addonSavedVars, addonVars.addonSavedVarsVersion, addonVars.addonSavedVarsDataTab, WL.defaultSettings, worldName, nil)
    end

    --Apply some fixes/add subtables and data, after the settings were loaded
    afterSettings()

    --Migrate the SavedVariables to ServerDependent ones
    if not accDataServerIndependent.savedVarsWereMigratedToServerDependent then
        if migrateSavedVarsToServerDependent() == true then
            accDataServerIndependent.savedVarsWereMigratedToServerDependent = true
            accDataServerIndependent.savedVarsWereMigratedToServerDependentTimeStamp = os.date("%c")
            d(string.format(GetString(WISHLIST_SV_MIGRATION_TO_SERVER_SUCCESSFULL), tos(accDataServerIndependent.savedVarsWereMigratedToServerDependentTimeStamp)))
            WL.SVrelated_doReloadUINow = true
        else
            d(GetString(WISHLIST_SV_MIGRATION_TO_SERVER_FAILED))
        end
    end
    WL.accDataServerIndependent = accDataServerIndependent
end

------------------------------------------------
--- MainMenu button
------------------------------------------------
local function WL_addMainMenuButton()
    local settings = WL.data
    --Create the libMainMenu 2.0 object
    if WL.LMM2 == nil then return end
    WL.LMM2:Init()

    --The name of the button, descriptor
    local descriptor = wlName
    -- Add to main menu
    local categoryLayoutInfo =
    {
        binding         = "WISHLIST_SHOW",
        categoryName    = SI_BINDING_NAME_WISHLIST_SHOW,
        callback        = function() WishList:Show() end,
        visible         = function(buttonData)
                return settings.showMainMenuButton
        end,
        normal          = "esoui/art/tradinghouse/tradinghouse_listings_tabicon_up.dds",
        pressed         = "esoui/art/tradinghouse/tradinghouse_listings_tabicon_down.dds",
        highlight       = "esoui/art/tradinghouse/tradinghouse_listings_tabicon_over.dds",
        disabled        = "esoui/art/tradinghouse/tradinghouse_listings_tabicon_disabled.dds",
    }
    WL.LMM2:AddMenuItem(descriptor, categoryLayoutInfo)
end

------------------------------------------------
--- WishList button
------------------------------------------------
local function W_addWLButton(myAnchorPoint, relativeTo, relativePoint, offsetX, offsetY, buttonData)
    if not buttonData or not buttonData.parentControl or not buttonData.buttonName or not buttonData.callback then return end
    local button
    --Does the button already exist?
    local btnName = buttonData.parentControl:GetName() .. "WishListButton" .. buttonData.buttonName
    button = WINDOW_MANAGER:GetControlByName(btnName, "")
    if button == nil then
    --Create the button control at the parent
    button = WINDOW_MANAGER:CreateControl(btnName, buttonData.parentControl, CT_BUTTON)
    end
    --Button was created?
    if button ~= nil then
    --Set the button's size
    button:SetDimensions(buttonData.width or 32, buttonData.height or 32)

    --SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
    button:SetAnchor(myAnchorPoint, relativeTo, relativePoint, offsetX, offsetY)

    --Texture
    local texture

    --Check if texture exists
    texture = WINDOW_MANAGER:GetControlByName(btnName, "Texture")
    if texture == nil then
    --Create the texture for the button to hold the image
    texture = WINDOW_MANAGER:CreateControl(btnName .. "Texture", button, CT_TEXTURE)
    end
    texture:SetAnchorFill()

    --Set the texture for normale state now
    texture:SetTexture(buttonData.normal)

    --Do we have seperate textures for the button states?
    button.upTexture 	  = buttonData.normal
    button.mouseOver 	  = buttonData.highlight
    button.clickedTexture = buttonData.pressed

    button.tooltipText	= GetString(buttonData.tooltip)
    button.tooltipAlign = TOP
    button:SetHandler("OnMouseEnter", function(self)
    self:GetChild(1):SetTexture(self.mouseOver)
    ZO_Tooltips_ShowTextTooltip(self, self.tooltipAlign, self.tooltipText)
    end)
    button:SetHandler("OnMouseExit", function(self)
    self:GetChild(1):SetTexture(self.upTexture)
    ZO_Tooltips_HideTextTooltip()
    end)
    --Set the callback function of the button
    button:SetHandler("OnClicked", function(...)
    buttonData.callback(...)
    end)
    button:SetHandler("OnMouseUp", function(butn, mouseButton, upInside)
    if upInside then
    butn:GetChild(1):SetTexture(butn.upTexture)
    end
    end)
    button:SetHandler("OnMouseDown", function(butn)
    butn:GetChild(1):SetTexture(butn.clickedTexture)
    end)

    --Show the button and make it react on mouse input
    button:SetHidden(false)
    button:SetMouseEnabled(true)

    --Return the button control
    return button
    end
end


------------------------------------------------
--- Slash commands
------------------------------------------------
local function WL_RegisterSlashCommands()
    local function showWishList()
        WishList:Show()
    end
    -- Register slash commands
    SLASH_COMMANDS["/wl"]       = showWishList
    SLASH_COMMANDS["/wishlist"] = showWishList
end

------------------------------------------------
--- Initialization
------------------------------------------------

local function WL_Hooks()
    --SORT HEADER
    --Sort header OnMouseUp callback function for SHIFT key checks
    local function WL_SortHeaderOnMouseUp(sortHeaderCtrl, upInside)
        --Was the mouse released above the ctrl ?
        if upInside == true and sortHeaderCtrl ~= nil
                and sortHeaderCtrl.GetParent ~= nil and sortHeaderCtrl:GetParent() == WishListFrameHeaders then
            --Was the shift key pressed?
            if IsShiftKeyDown() then
                WL._clickedSortHeader = sortHeaderCtrl
                --Get the key of the sortHeader
                local sortHeaderKey = sortHeaderCtrl.key
                if sortHeaderKey == nil then return end
                local sortTiebrakerChoicesWithSortHeaderKeys = WL.sortTiebrakerChoicesWithSortHeaderKeys
                if sortTiebrakerChoicesWithSortHeaderKeys == nil then return end
                local newTiebrakerValue = 0
                for newTiebrakerIndex, tiebrakerName in ipairs(sortTiebrakerChoicesWithSortHeaderKeys) do
                    if tiebrakerName == sortHeaderKey then
                        local nameOfSortHeader = ""
                        local nameOfSortHeaderCtrl = WINDOW_MANAGER:GetControlByName(sortHeaderCtrl:GetName(), "Name")
                        if nameOfSortHeaderCtrl ~= nil and nameOfSortHeaderCtrl.GetText then
                            nameOfSortHeader = nameOfSortHeaderCtrl:GetText()
                        end
                        d(string.format(GetString(WISHLIST_SORTHEADER_GROUP_CHANGED), tos(nameOfSortHeader)))
                        newTiebrakerValue = newTiebrakerIndex
                        break
                    end
                end
                --Get the settingsm for the selected key and change it accordingly
                if newTiebrakerValue and newTiebrakerValue > 0 then
                    WL.data.useSortTiebraker = newTiebrakerValue
                    --Rebuild the sortKeys now
                    WL.sortKeys =  WL.getSortKeysWithTiebrakerFromSettings()
                end
                --Do not run the normal sort header group OnMouseDown event now!
                return true
            end
        end
    end
    ZO_PreHook("ZO_SortHeader_OnMouseUp", WL_SortHeaderOnMouseUp)



    --INVENTORY CONTEXT MENU
    --Player inventories etc.
    local function addOrRemoveByInv(bagId, slotIndex, alreadyOnWishListCheckData)
        WishList:AddOrRemoveFromWishList(bagId, slotIndex, alreadyOnWishListCheckData, false, true)
    end

    --Set collection item book: Determine unknown items of setId by help of the collectionCategoryIndex and the parent'S category data
    local function getUnknownSetItemsInCollection(setId)
        --d("[WishList]getUnknownSetItemsInCollection - setId: " ..tos(setId))
        if setId == nil then return end
        local collectionCategoryIdCheck = GetItemSetCollectionCategoryId(setId)
        local parentCategoryId = GetItemSetCollectionCategoryParentId(setId)
        if collectionCategoryIdCheck == nil or parentCategoryId == nil then return end
        local numItemsInSet = GetNumItemSetCollectionPieces(setId)
        if not numItemsInSet or numItemsInSet <= 0 then return end
        local unlockedSlots = GetNumItemSetCollectionSlotsUnlocked(setId)
        if not unlockedSlots or unlockedSlots >= numItemsInSet then return end

        local items = {}

        local allTraitsId = WISHLIST_TRAIT_TYPE_ALL --All traits
        local anyQualityId = WISHLIST_QUALITY_ALL

        for i=1, numItemsInSet, 1 do
            local pieceId, slot = GetItemSetCollectionPieceInfo(setId, i)
            if pieceId and pieceId ~= 0 and slot then
                local pieceData= ITEM_SET_COLLECTIONS_DATA_MANAGER:GetOrCreateItemSetCollectionPieceData(pieceId, slot)
                if pieceData and pieceData:IsLocked() then
                    local itemLink = pieceData:GetItemLink()
                    --Check if already on Wishlist
                    local data, isAlreadyOnWL = WL.getItemDataByItemLink(itemLink, nil, allTraitsId, anyQualityId)
                    if not isAlreadyOnWL and data ~= nil then
                        table.insert(items, data)
                    end
                end
            end
        end
        return items
    end

    -->Add "Add to WishList" or "Remove from WishList" to the inventory context menu of items
    local function WishList_OnInventory_ContextMenu(inventorySlot, slotActions)
        local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
        if not bagId or not slotIndex then return end
        --Is item a set?
        local isSet = GetItemLinkSetInfo(GetItemLink(bagId, slotIndex))
        if not isSet then return end
        --Check if already on Wishlist
        local isAlreadyOnWL, setItemId, setId, setName, bonuses, itemType, armorOrWeaponType, equipType, traitType, itemQuality, charData, item = WL.checkIfAlreadyOnWishList(bagId, slotIndex, nil, nil)
        local alreadyOnWishListCheckData = {
            isAlreadyOnWL = isAlreadyOnWL,
            setItemId = setItemId,
            setId = setId,
            setName = setName,
            bonuses = bonuses,
            itemType = itemType,
            armorOrWeaponType = armorOrWeaponType,
            equipType = equipType,
            traitType = traitType,
            itemQuality = itemQuality,
            charData = charData,
            item = item,
        }
        if not isAlreadyOnWL then
            AddCustomMenuItem(GetString(WISHLIST_CONTEXTMENU_ADD), function() addOrRemoveByInv(bagId, slotIndex, alreadyOnWishListCheckData) end)
        else
            AddCustomMenuItem(GetString(WISHLIST_CONTEXTMENU_REMOVE), function() addOrRemoveByInv(bagId, slotIndex, alreadyOnWishListCheckData) end)
        end
        ShowMenu()
    end
    LibCustomMenu:RegisterContextMenu(WishList_OnInventory_ContextMenu, LibCustomMenu.CATEGORY_LATE)

    --SET ITEM COLLECTIONS - SET HEADER CONTEXT MENU
    --Item Set Collection set collapsable header context menu hook
    SecurePostHook("ZO_ItemSetsBook_Entry_Header_Keyboard_OnMouseUp", function(control, button, upInside)
        if upInside and button == MOUSE_BUTTON_INDEX_RIGHT then
            local controlDataSource = control.dataEntry.data.header.dataSource
            local setId = controlDataSource.itemSetId
            local unlockedSlots = GetNumItemSetCollectionSlotsUnlocked(setId)
            local numItemsInSet = GetNumItemSetCollectionPieces(setId)
            local allUnlocked = (unlockedSlots == numItemsInSet) or false
            local nameCtrl = GetControl(control, "Name")
            local setName = ""
            if nameCtrl ~= nil and nameCtrl.GetText then
                setName = nameCtrl:GetText()
            end
            local data = {
                setId = setId,
                name = setName,
            }

            if not allUnlocked then
                AddCustomMenuItem("-", function() end)
                AddCustomMenuItem(zo_strformat(GetString(WISHLIST_CONTEXTMENU_ADD_ITEM_UNKNOWN_SETITEMCOLLECTION_OF_SET), setName),
                        function()
                            local unknownItems = getUnknownSetItemsInCollection(setId)
                            if unknownItems and #unknownItems > 0 then
                                WL.ShowChooseChar(false, unknownItems, false, true)
                            end
                        end)  -- Add all sets items of the setId not known yet in Set Item Collection book
            end
            AddCustomMenuItem("-", function() end)
            if unlockedSlots and unlockedSlots > 0 then
                AddCustomMenuItem(zo_strformat(GetString(WISHLIST_CONTEXTMENU_REMOVE_ITEM_KNOWN_SETITEMCOLLECTION_OF_SET), setName),
                        function()
                            WL.CurrentCharData = WL.LoggedInCharData
                            WL.showRemoveItem(data, false, false, false, WISHLIST_REMOVE_ITEM_TYPE_KNOWN_SETITEMCOLLECTION_OF_SET)
                        end)  -- Remove all sets items of the setId already known in Set Item Collection book
            end
            AddCustomMenuItem(GetString(WISHLIST_CONTEXTMENU_REMOVE_ITEM_KNOWN_SETITEMCOLLECTION),
                    function()
                        WL.CurrentCharData = WL.LoggedInCharData
                        WL.showRemoveItem(nil, false, false, false, WISHLIST_REMOVE_ITEM_TYPE_KNOWN_SETITEMCOLLECTION)
                    end)  -- Remove all sets items already known in Set Item Collection book
            AddCustomMenuItem("-", function() end)
            if unlockedSlots and unlockedSlots > 0 then
                AddCustomMenuItem(zo_strformat(GetString(WISHLIST_CONTEXTMENU_REMOVE_ITEM_KNOWN_SETITEMCOLLECTION_OF_SET_ALL_WISHLISTS), setName),
                        function()
                            WL.CurrentCharData = WL.LoggedInCharData
                            WL.showRemoveItem(data, false, false, false, WISHLIST_REMOVE_ITEM_TYPE_KNOWN_SETITEMCOLLECTION_OF_SET_ALL_WISHLISTS)
                        end)  -- Remove all sets items of the setId already known in Set Item Collection book from ALL WishLists
            end
            AddCustomMenuItem(GetString(WISHLIST_CONTEXTMENU_REMOVE_ITEM_KNOWN_SETITEMCOLLECTION_ALL_WISHLISTS),
                    function()
                        WL.CurrentCharData = WL.LoggedInCharData
                        WL.showRemoveItem(nil, false, false, false, WISHLIST_REMOVE_ITEM_TYPE_KNOWN_SETITEMCOLLECTION_ALL_WISHLISTS)
                    end)  -- Remove all sets items already known in Set Item Collection book from ALL WishLists
            ShowMenu()
        end
    end)

    --SET ITEM COLLECTIONS - SINGLE PIECE CONTEXT MENU
    --ItemSetCollection single piece tile - OnMouseContextMenu Show
    -->Add "Add all traits to WishList" context menu entry, and "Remove all traits"
    local function getItemSetCollectionSinglePieceItemLink(p_ZO_ItemSetCollectionPieceTile_Keyboard)
        local itemLink
        local itemSetCollectionPieceData = p_ZO_ItemSetCollectionPieceTile_Keyboard.itemSetCollectionPieceData
        if itemSetCollectionPieceData then
            itemLink = itemSetCollectionPieceData:GetItemLink()
        end
        return itemLink
    end
    --Item Set Collection single setitem tile context menu hook
    SecurePostHook(ZO_ItemSetCollectionPieceTile_Keyboard, "ShowMenu", function(self)
        local itemLink = getItemSetCollectionSinglePieceItemLink(self)
        if not itemLink or itemLink == "" then return end
        AddCustomMenuItem("-", function() end)
        AddCustomMenuItem(GetString(WISHLIST_CONTEXTMENU_SETITEMCOLLECTION_ADD),
                function()
                    WL.addItemSetCollectionSinglePieceItemLinkToWishList(itemLink, false)
                end
        )
        AddCustomMenuItem(GetString(WISHLIST_CONTEXTMENU_SETITEMCOLLECTION_ADD_1_ITEM),
                function()
                    WL.addItemSetCollectionSinglePieceItemLinkToWishList(itemLink, true)
                end
        )
        AddCustomMenuItem("-", function() end)
        AddCustomMenuItem(GetString(WISHLIST_CONTEXTMENU_SETITEMCOLLECTION_REMOVE),
                function()
                    WL.removeItemSetCollectionSinglePieceItemLinkFromWishList(itemLink, WISHLIST_REMOVE_ITEM_TYPE_ARMORANDWEAPONTYPE_SLOT)
                end
        )
        AddCustomMenuItem(GetString(WISHLIST_CONTEXTMENU_SETITEMCOLLECTION_REMOVE_SLOT),
                function()
                    WL.removeItemSetCollectionSinglePieceItemLinkFromWishList(itemLink, WISHLIST_REMOVE_ITEM_TYPE_SLOT)
                end
        )
        ShowMenu()
    end)


    --LibSets - Add "Add to WishList" to the set search UI's result list context menu
    local function getSubmenuOwnerControlData(menu)
        -->Get the menu's owner which should be the rowControl, and read the data of the owner then to get the setId
        local owner = GetMenuOwner(menu)
        if owner == nil then return end
WL._debugOwnerSubmenu = owner
        local ownerData = owner.data
        if ownerData == nil then return end
        return ownerData
    end

    local function visibleFunc(rowControl, setId)
        return true
    end

    local submenuEntriesWishList = {
        --Add item dialog via WishList
        {
            label = function()
                local setData = getSubmenuOwnerControlData()
                if setData == nil or setData.setId == nil then return end
                local setName = setData.name or setData["setNames"][WL.clientLang] or libSets.GetSetName(setData.setId)
                return GetString(WISHLIST_DIALOG_ADD_ITEM) .. ": " ..tostring(setName)
            end,
            callback = function()
                local setData = getSubmenuOwnerControlData()
                if setData == nil or setData.setId == nil then return end

                WL.CurrentCharData = WL.LoggedInCharData
                if WL:IsHidden() then
                    WL.Show()
                end
                WL.SetTab(WISHLIST_TAB_SEARCH)
                --Change the selected user at the WL dropdownbox to the currently logged in one
                WL.showAddItem(setData, true, true) --pass in doNotUpdateCurrentCharData = true (3rd param) so the characterData will not be reset again at the dialog!
            end,
        },
        --Remove set from WishList
        {
            label = function()
                local setData = getSubmenuOwnerControlData()
                if setData == nil or setData.setId == nil then return zo_strformat(WISHLIST_DIALOG_REMOVE_WHOLE_SET, "n/a") end
                local setName = setData.name or setData["setNames"][WL.clientLang] or libSets.GetSetName(setData.setId)
                return zo_strformat(WISHLIST_DIALOG_REMOVE_WHOLE_SET, setName)
            end,
            callback = function()
                local setData = getSubmenuOwnerControlData()
                if setData == nil or setData.setId == nil then return end
                local setId = setData.setId
                local setName = setData.name or setData["setNames"][WL.clientLang] or libSets.GetSetName(setId)

                WL.CurrentCharData = WL.LoggedInCharData
                if WL:IsHidden() then
                    WL.Show()
                end
                WL.SetTab(WISHLIST_TAB_WISHLIST)
                --Delete the whole set from the WishList
                local data = {
                    --setId is needed and the setName for the dialog title
                    setId = setId,
                    name = setName,
                }
                WL.showRemoveItem(data, true, false, false, WISHLIST_REMOVE_ITEM_TYPE_NORMAL)
            end,
            visible = function(menu)
                --Only passes in ZO_Menu as param -> See LibCustomMenu
                --Check if this setId got any entry on the WishList of the currently logged in Character
                local setData = getSubmenuOwnerControlData()
                if setData == nil or setData.setId == nil then return end
                --Check if any item of this setId is on the WishList of the currently logged in char
                WL.LoggedInCharData = WL.LoggedInCharData or WL.checkCurrentCharData(true)
                WL.CurrentCharData = WL.LoggedInCharData
                return WL.isSetIdOnWishlist(WL.LoggedInCharData, setData.setId)
            end,
        },
    }
    libSets.RegisterCustomSetSearchResultsListContextMenu(wlName, wlName, GetString(WISHLIST_TITLE), submenuEntriesWishList, visibleFunc)
end

local function WL_AddButtons()
    --[[
    --Integrated directly into LibSets now!
    --Add "show current parent zone" button to item set collection UI top right corner
    local buttonDataOpenCurrentParentZone =
    {
        buttonName      = "MoreOptions",
        parentControl   = ZO_ItemSetsBook_Keyboard_TopLevelFilters,
        tooltip         = WISHLIST_SHOW_ITEM_SET_COLLECTION_MORE_OPTIONS,
        callback        = function()
            ClearMenu()
            AddCustomMenuItem(GetString(SI_BINDING_NAME_WISHLIST_SHOW_ITEM_SET_COLLECTION_CURRENT_PARENT_ZONE), function()
                WL.openSetItemCollectionBrowserForCurrentZone(true)
            end)
            AddCustomMenuItem(GetString(SI_BINDING_NAME_WISHLIST_SHOW_ITEM_SET_COLLECTION_CURRENT_ZONE), function()
                if not WL.openSetItemCollectionBrowserForCurrentZone(false) then
                    WL.openSetItemCollectionBrowserForCurrentZone(true)
                end
            end)
            ShowMenu(WL.itemSetCollectionBookMoreOptionsButton)
        end,
        width           = 20,
        height          = 20,
        normal          = "/esoui/art/buttons/dropbox_arrow_normal.dds",
        pressed         = "/esoui/art/buttons/dropbox_arrow_mousedown.dds",
        highlight       = "/esoui/art/buttons/dropbox_arrow_mouseover.dds",
        disabled        = "/esoui/art/buttons/dropbox_arrow_disabled.dds",
    }
    WL.itemSetCollectionBookMoreOptionsButton = W_addWLButton(LEFT, ZO_ItemSetsBook_Keyboard_TopLevelFilters, RIGHT, (buttonDataOpenCurrentParentZone.width+4)*-1, 10, buttonDataOpenCurrentParentZone)
    ]]

    WL.itemSetCollectionBookMoreOptionsButton = libSets.itemSetCollectionBookMoreOptionsButton

    --Add WishList button to item set collection UI top right corner
    local buttonDataShowWLUI =
    {
        buttonName      = "ShowWishListUI",
        parentControl   = ZO_ItemSetsBook_Keyboard_TopLevelFilters,
        tooltip         = SI_BINDING_NAME_WISHLIST_SHOW,
        callback        = function()
                            WishList:Show()
                            WishList.SetTab(WISHLIST_TAB_WISHLIST)
        end,
        width           = 32,
        height          = 32,
        normal          = "esoui/art/tradinghouse/tradinghouse_listings_tabicon_up.dds",
        pressed         = "esoui/art/tradinghouse/tradinghouse_listings_tabicon_down.dds",
        highlight       = "esoui/art/tradinghouse/tradinghouse_listings_tabicon_over.dds",
        disabled        = "esoui/art/tradinghouse/tradinghouse_listings_tabicon_disabled.dds",
    }
    WL.itemSetCollectionBookOpenWishListUIButton = W_addWLButton(RIGHT, WL.itemSetCollectionBookMoreOptionsButton, LEFT, -4, 0, buttonDataShowWLUI)

end

function WL.init(_, addonName)
    addonVars = WL.addonVars
    if addonName ~= wlName then
        --Check if addon "LazyWritCreator" is active
        if(addonName == "DolgubonsLazyWritCreator" or WritCreater ~= nil) then
            WL.otherAddons.LazyWritCreatorActive = true
        end
        return
    end
    if WL.initDone then return end

    --Unregister for on loaded event
    EVENT_MANAGER:UnregisterForEvent(wlName, EVENT_ADD_ON_LOADED)

    --The client language
    WL.clientLang = GetCVar("language.2")
    WL.clientLangIsEN = WL.clientLang == "en" or false
    WL.preventerVars.runSetNameLanguageChecks = true

    --Load the settings
    WL.loadSettings()
    --Build the list sortkeys depending on the selected dropdown entry from LAM settings
    WL.sortKeys =  WL.getSortKeysWithTiebrakerFromSettings()

    --Check if the last scan of the sets was done with an older LibSets version
    local scanSetsNowSilently = false
    local lastLibSetsVersionScanDone = WL.accData.setsLastScannedLibSetsVersion
    if lastLibSetsVersionScanDone == nil or lastLibSetsVersionScanDone < libSets.version then
        scanSetsNowSilently = true
    end
    if not scanSetsNowSilently then
        --Check if the sets are updated with LibSets v0.06 (or higher) data
        --Does the "setsLastScanned" entry exist or does the "names" subtable exist?
        --If not we did not scan the sets new and got old setData. Therefore we need to update it now once via LibSets, but silently
        local setsData = WL.accData.sets
        if setsData then
            for _, setData in pairs(setsData) do
                if WL.accData.setsLastScanned == nil or setData.names == nil then
                    scanSetsNowSilently = true
                    break -- Get out of the lop now
                end
            end
        end
    end
    --Scan the sets now silently?
    if scanSetsNowSilently == true then
        WL.GetAllSetData(true)
    end
    --Get the characters of the currently logged in account and list all available ones in a list (for the char selection dropdown at the WishList tab e.g.)
    WL.getCharsOfAccount()

    --Get the currently logged in char data
    WL.checkCurrentCharData(true)

    --Scan the items on your WishList (logged in char) for set item collection markers
    WL.scanWishListForAlreadyKnownSetItemCollectionEntries(WL.LoggedInCharData, true)

    --Build the LAM addon menu
    if not WL.preventerVars.addonMenuBuild then
        WL.buildAddonMenu()
    end

    --EVENTs
    EVENT_MANAGER:RegisterForEvent(wlName, EVENT_LOOT_RECEIVED, lootReceived)
    --Register for player inventory slot update
    EVENT_MANAGER:RegisterForEvent(wlName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, inv_Single_Slot_Update)
    --Add a filter to the event to speed up item checks only on default items not a weapon charge etc.
    EVENT_MANAGER:AddFilterForEvent(wlName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT, REGISTER_FILTER_IS_NEW_ITEM, true)

    local registerTooltipHookDone = false
    EVENT_MANAGER:RegisterForEvent(wlName.. "_PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED, function()
        if registerTooltipHookDone == false then
            --API function in LibSets is missing? Simulate everything done
            if libSets.RegisterCustomTooltipHook == nil then
                registerTooltipHookDone = true
            else
                --Regisetr the LibSets tooltip hook for WishList tooltips now
                if libSets.RegisterCustomTooltipHook("WishListTooltip", wlName) == true then
                    registerTooltipHookDone = true
                end
            end

        end

        if WL.SVrelated_doReloadUINow == true then
            zo_callLater(function()
                d(GetString(WISHLIST_SV_MIGRATION_RELOADUI))
                if (WL.accDataServerIndependent and WL.accDataServerIndependent.savedVarsWereMigratedFinished ~= true) and WishList_Data[addonVars.addonSavedVarsDefault] == nil then
                    WL.accDataServerIndependent.savedVarsWereMigratedFinished = true
                end
                ReloadUI("ingame")
            end, 50)
        else
            --Check if WishList SVs were migrated and finished the reloaduis
            if WishList_Data[addonVars.addonSavedVarsDefault] == nil and WL.accDataServerIndependent ~= nil then
                local accDataServerIndependent = WL.accDataServerIndependent
                if accDataServerIndependent.savedVarsWereMigratedToServerDependent == true and accDataServerIndependent.savedVarsWereMigratedFinished == true then
                    WL.accDataServerIndependent.savedVarsWereMigratedFinished = nil
                    --Show an onscreen message + chat message
                    d(string.format(GetString(WISHLIST_SV_MIGRATION_TO_SERVER_FINISHED), tos(GetDisplayName()), tos(GetWorldName())))
                    WL.CSA(GetString(WISHLIST_SV_MIGRATED_TO_SERVER))
                end
            end
            if WL.accDataServerIndependent ~= nil and WL.accDataServerIndependent.savedVarsWereMigratedToServerDependent == true then
                --WishList version 3.02 - Fix some trait related entries in the SV, gotting corrupted due to new companin trait Ids added by ZOs
                fixSVData()
            end
        end
    end)

    --HANDLERs
    --Link handler (for right clicking an item in chat, etc.)
    LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, WL.linkContextMenu)

    --Add the main menu button
    WL_addMainMenuButton()

    --Register the slash commands
    WL_RegisterSlashCommands()

    --Hooks
    WL_Hooks()

    --Buttons
    WL_AddButtons()

    WL.firstWishListCall = true
    WL.initDone = true
end

------------------------------------------------
--- Addon Start Event
------------------------------------------------
EVENT_MANAGER:RegisterForEvent(wlName, EVENT_ADD_ON_LOADED, WL.init)