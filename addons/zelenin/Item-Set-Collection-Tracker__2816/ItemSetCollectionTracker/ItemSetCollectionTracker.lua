local addon = ZO_Object:Subclass()
local addonId = "ItemSetCollectionTracker"

local announcementsColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_ANNOUNCEMENTS)
local succeededColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SUCCEEDED)
local failedColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_FAILED)
local selectedColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED)
local hintColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_HINT)

function addon:New(...)
    local instance = ZO_Object.New(self)
    instance:initialize(...)
    return instance
end

local ownerDisplayNames = {
    ["@zelenin"] = true,
    ["@zelenin_av"] = true,
}

function addon:initialize(name)
    self.name = name
    self.addonData = self:getAddonData()

    self.settings = itemSetCollectionTrackerSettings:New(self)
    self.bind = itemSetCollectionTrackerBind:New(self)
    self.chatPoster = itemSetCollectionTrackerChatPoster:New(self)
    if ownerDisplayNames[GetDisplayName()] then
        self.cofferHelper = itemSetCollectionTrackerCofferHelper:New(self)
    end

    self.sets = {}

    self:notifications(self.settings.data.notifications, self.settings.data.notificationsOnlyMy, self.settings.data.notificationsSetInfo)
    self:chatHook(self.settings.data.chatIcon)

    self:hookInventory()
    self:hookTradeWindow()
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OPEN_TRADING_HOUSE, function(eventCode)
        self:hookTradingHouse()
    end)
    self:ui()

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ITEM_SET_COLLECTIONS_UPDATED, function(eventCode)
        self.refreshLists()
    end )
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ITEM_SET_COLLECTION_UPDATED, function(eventCode, itemSetId,slotsJustUnlockedMask)
        local itemSetCollectionData = ITEM_SET_COLLECTIONS_DATA_MANAGER:GetItemSetCollectionData(itemSetId)
        local itemSetCollectionCategoryData = ITEM_SET_COLLECTIONS_DATA_MANAGER:GetItemSetCollectionCategoryData(itemSetCollectionData:GetCategoryData():GetId())
        local numUnlockedPieces, numPieces = itemSetCollectionCategoryData:GetNumUnlockedAndTotalPieces()

        local categoryNameParts = {}
        if itemSetCollectionCategoryData:IsSubcategory() then
            table.insert(categoryNameParts, itemSetCollectionCategoryData:GetParentCategoryData():GetFormattedName())
        end
        table.insert(categoryNameParts, itemSetCollectionCategoryData:GetFormattedName())

        local categoryName = table.concat(categoryNameParts, " / ")

        local messageParts = {
            string.format("|c%sSet:|r |c%s%s|r (%d/%d).", hintColor:ToHex(), succeededColor:ToHex(), itemSetCollectionData:GetFormattedName(), itemSetCollectionData:GetNumUnlockedPieces(), itemSetCollectionData:GetNumPieces()),
            string.format("|c%sCategory:|r |c%s%s|r (%d/%d).", hintColor:ToHex(), succeededColor:ToHex(), categoryName, numUnlockedPieces, numPieces),
        }

        self:addMessage(table.concat(messageParts, " "))

        self.refreshLists()
    end )

    SLASH_COMMANDS["/item-set-collection-tracker"] = function(cmd)
        if cmd == "count" then
            local known = 0
            local unknown = 0

            local setId = GetNextItemSetCollectionId(nil)
            while setId ~= nil do
                for index = 1, GetNumItemSetCollectionPieces(setId) do
                    local pieceId, slot = GetItemSetCollectionPieceInfo(setId, index)
                    if IsItemSetCollectionPieceUnlocked(pieceId) == true then
                        known = known + 1
                    else
                        unknown = unknown + 1
                    end
                end

                setId = GetNextItemSetCollectionId(setId)
            end

            local all = known + unknown
            self:addMessage(string.format("All: %d, Known: %d / %0.1f%%, Unknown: %d / %0.1f%%.", all, known, 100 * known / all, unknown, 100 * unknown / all))
        end
        if cmd == "post" then
            self.chatPoster:Post()
        end
    end

    local isArmor = {
        [EQUIP_TYPE_HEAD] = true,
        [EQUIP_TYPE_SHOULDERS] = true,
        [EQUIP_TYPE_CHEST] = true,
        [EQUIP_TYPE_LEGS] = true,
        [EQUIP_TYPE_HAND] = true,
        [EQUIP_TYPE_WAIST] = true,
        [EQUIP_TYPE_FEET] = true,
    }

    local isWeapon = {
        [EQUIP_TYPE_ONE_HAND] = true,
        [EQUIP_TYPE_TWO_HAND] = true,
        [EQUIP_TYPE_MAIN_HAND] = true,
        [EQUIP_TYPE_OFF_HAND] = true,
    }

    local isJewelry = {
        [EQUIP_TYPE_NECK] = true,
        [EQUIP_TYPE_RING] = true,
    }

    local function postFilter(itemData)
        if isArmor[itemData.equipType] then
            local hasSet, setName, numBonuses, numEquipped, maxEquipped, setId = GetItemLinkSetInfo(itemData.itemLink, false)
            local itemSetType = GetItemSetType(setId)
            if itemSetType == ITEM_SET_TYPE_MONSTER then
                return self.settings.data.lootPosting.monsterSet
            else
                return self.settings.data.lootPosting.armor
            end
        end
        if isWeapon[itemData.equipType] then
            return self.settings.data.lootPosting.weapon
        end
        if isJewelry[itemData.equipType] then
            return self.settings.data.lootPosting.jewelry
        end
    end

    local postSlashCommands = { "/post-items", "/isct-post" }
    for _, slashCommand in ipairs(postSlashCommands) do
        SLASH_COMMANDS[slashCommand] = function(cmd)
            self.chatPoster:Post(postFilter)
        end
    end

    local postSlashCommands = { "/full-post-items", "/full-isct-post" }
    for _, slashCommand in ipairs(postSlashCommands) do
        SLASH_COMMANDS[slashCommand] = function(cmd)
            self.chatPoster:Post()
        end
    end
end

function addon.refreshLists()
    ZO_ScrollList_RefreshVisible(ZO_PlayerInventoryList)
    ZO_ScrollList_RefreshVisible(ZO_PlayerBankBackpack)
    ZO_ScrollList_RefreshVisible(ZO_HouseBankBackpack)
    ZO_ScrollList_RefreshVisible(ZO_GuildBankBackpack)
    ZO_ScrollList_RefreshVisible(ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack)
    ZO_ScrollList_RefreshVisible(ZO_SmithingTopLevelImprovementPanelInventoryBackpack)
end

function addon:notifications(notify, onlyMy, setInfo)
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_LOOT_RECEIVED)

    if notify then
        EVENT_MANAGER:RegisterForEvent(self.name, EVENT_LOOT_RECEIVED, function(eventCode, receivedBy, itemName, quantity, soundCategory, lootType, me, isPickpocketLoot, questItemIcon, itemId, isStolen)
            if onlyMy and not me then
                return
            end

            if lootType ~= LOOT_TYPE_ITEM then
                return
            end

            local itemData = self:getItemData(itemName)
            if itemData.isBound == true then
                return
            end

            if not IsItemLinkSetCollectionPiece(itemData.itemLink) or IsItemSetCollectionPieceUnlocked(itemData.id) then
                return
            end

            local setItems = self:getSetItems(itemData.setId)
            if setItems == nil then
                return
            end

            local isUnlocked = IsItemSetCollectionPieceUnlocked(itemData.id)
            if isUnlocked == true then
                return
            end

            local allItemsCount = 0
            local unlockedItemsCount = 0
            for _, setDataItemId in ipairs(setItems) do
                allItemsCount = allItemsCount + 1
                if IsItemSetCollectionPieceUnlocked(setDataItemId) == true then
                    unlockedItemsCount = unlockedItemsCount + 1
                end
            end

            local displayName = LibUnitTracker:GetDisplayNameByUnitName(receivedBy)
            local formattedDisplayName = ZO_LinkHandler_CreateDisplayNameLink(displayName)

            local formattedTrait = ""
            if itemData.trait ~= ITEM_TRAIT_TYPE_NONE then
                formattedTrait = string.format(" |cffffff(%s)|r", GetString("SI_ITEMTRAITTYPE", itemData.trait))
            end

            local messageParts = {
                string.format("|t%d:%d:%s|t", 24, 24, itemData.icon),
                itemName:gsub("^|H0", "|H1", 1),
                formattedTrait,
                "—",
                string.format("|c777777%s|r", formattedDisplayName)
            }

            if setInfo then
                table.insert(messageParts, string.format("(%d/%d)", unlockedItemsCount, allItemsCount))
            end

            self:addMessage(table.concat(messageParts, " "))
        end)
    end
end

function addon:getItemData(itemLink)
    local id = GetItemLinkItemId(itemLink)
    local name = GetItemLinkName(itemLink)
    local hasSet, setName, numBonuses, numEquipped, maxEquipped, setId = GetItemLinkSetInfo(itemLink, false)
    local isBound = IsItemLinkBound(itemLink)
    local isCrafted = IsItemLinkCrafted(itemLink)
    local equipType = GetItemLinkEquipType(itemLink)
    local armorType = GetItemLinkArmorType(itemLink)
    local weaponType = GetItemLinkWeaponType(itemLink)
    local quality = GetItemLinkFunctionalQuality(itemLink)
    local itemTraitType = GetItemLinkTraitType(itemLink)
    local requiredLevel = GetItemLinkRequiredLevel(itemLink)
    local requiredChampionPoints = GetItemLinkRequiredChampionPoints(itemLink)
    local icon = GetItemLinkInfo(itemLink)

    return {
        id = id,
        name = name,
        itemLink = itemLink,
        icon = icon,
        isBound = isBound,
        isCrafted = isCrafted,
        setId = setId,
        trait = itemTraitType,
        equipType = equipType,
        armorType = armorType,
        weaponType = weaponType,
        quality = quality,
        level = requiredLevel,
        championPoints = requiredChampionPoints,
    }
end

function addon:addIconToInventorySlot(control, itemLink)
    local iconName = "ItemSetCollectionTrackerIcon"

    local indicatorControl = control:GetNamedChild(iconName)
    if indicatorControl == nil then
        indicatorControl = WINDOW_MANAGER:CreateControl(control:GetName() .. iconName, control, CT_TEXTURE)

        indicatorControl:ClearAnchors()
        indicatorControl:SetDrawTier(DT_HIGH)
        indicatorControl:SetTexture("esoui/art/collections/collections_tabIcon_itemSets_down.dds")
        indicatorControl:SetDimensions(self.settings.data.iconSize, self.settings.data.iconSize)
        indicatorControl:SetAnchor(LEFT, control, LEFT, self.settings.data.iconXOffset, self.settings.data.iconYOffset)
        indicatorControl:SetColor(self.settings.data.color.r, self.settings.data.color.g, self.settings.data.color.b)
    end
    indicatorControl:SetHidden(true)

    local itemData = self:getItemData(itemLink)
    if IsItemLinkSetCollectionPiece(itemData.itemLink) == false or IsItemSetCollectionPieceUnlocked(itemData.id) == true then
        return
    end

    indicatorControl:SetHidden(false)
end

function addon:hookInventory()
    local inventoryLists = {
        [PLAYER_INVENTORY.inventories[INVENTORY_BACKPACK].listView] = function(slot)
            return GetItemLink(slot.bagId, slot.slotIndex)
        end,
        [PLAYER_INVENTORY.inventories[INVENTORY_BANK].listView] = function(slot)
            return GetItemLink(slot.bagId, slot.slotIndex)
        end,
        [PLAYER_INVENTORY.inventories[INVENTORY_HOUSE_BANK].listView] = function(slot)
            return GetItemLink(slot.bagId, slot.slotIndex)
        end,
        [PLAYER_INVENTORY.inventories[INVENTORY_GUILD_BANK].listView] = function(slot)
            return GetItemLink(slot.bagId, slot.slotIndex)
        end,
        [ZO_StoreWindowList] = function(slot)
            return GetStoreItemLink(slot.slotIndex)
        end,
        [ZO_BuyBackList] = function(slot)
            return GetBuybackItemLink(slot.slotIndex)
        end,
        [ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack] = function(slot)
            return GetItemLink(slot.bagId, slot.slotIndex)
        end
    }

    for inventoryList, itemLinkGetter in pairs(inventoryLists) do
        if inventoryList and inventoryList.dataTypes and inventoryList.dataTypes[1] then
            local hookedFunctions = inventoryList.dataTypes[1].setupCallback
            inventoryList.dataTypes[1].setupCallback = function(rowControl, slot)
                hookedFunctions(rowControl, slot)

                local itemLink = itemLinkGetter(slot)
                self:addIconToInventorySlot(rowControl, itemLink)
            end
        end
    end
end

function addon:hookTradingHouse()
    local inventoryLists = {
        [ZO_TradingHouseBrowseItemsRightPaneSearchResults] = function(slot)
            return GetTradingHouseSearchResultItemLink(slot.slotIndex)
        end,
    }

    for inventoryList, itemLinkGetter in pairs(inventoryLists) do
        if inventoryList and inventoryList.dataTypes and inventoryList.dataTypes[1] then
            local hookedFunctions = inventoryList.dataTypes[1].setupCallback
            inventoryList.dataTypes[1].setupCallback = function(rowControl, slot)
                hookedFunctions(rowControl, slot)

                local itemLink = itemLinkGetter(slot)
                self:addIconToInventorySlot(rowControl, itemLink)
            end
        end
    end
end

function addon:addIconToTradeWindowSlot(iconName, control, itemLink)
    local indicatorControl = control:GetNamedChild(iconName)
    if indicatorControl == nil then
        indicatorControl = WINDOW_MANAGER:CreateControl(control:GetName() .. iconName, control, CT_TEXTURE)

        indicatorControl:ClearAnchors()
        indicatorControl:SetDrawTier(DT_HIGH)
        indicatorControl:SetTexture("esoui/art/collections/collections_tabIcon_itemSets_down.dds")
        indicatorControl:SetDimensions(self.settings.data.iconSize, self.settings.data.iconSize)
        indicatorControl:SetAnchor(LEFT, control, LEFT, 0, 0)
        indicatorControl:SetColor(self.settings.data.color.r, self.settings.data.color.g, self.settings.data.color.b)
    end
    indicatorControl:SetHidden(true)

    local itemData = self:getItemData(itemLink)
    if IsItemLinkSetCollectionPiece(itemData.itemLink) == false or IsItemSetCollectionPieceUnlocked(itemData.id) == true then
        return
    end

    indicatorControl:SetHidden(false)
end

function addon:hookTradeWindow()
    if TRADE == nil then
        return
    end

    local iconName = "ItemSetCollectionTrackerIcon"

    local instance = self
    local hooked = TRADE.InitializeSlot
    TRADE.InitializeSlot = function(self, who, index, name, icon, quantity, displayQuality)
        hooked(self, who, index, name, icon, quantity, displayQuality)

        local itemLink = GetTradeItemLink(who, index, LINK_STYLE_DEFAULT)
        instance:addIconToTradeWindowSlot(iconName, self.Columns[who][index].Control, itemLink)
    end

    local hooked = TRADE.ResetSlot
    TRADE.ResetSlot = function(self, who, index)
        hooked(self, who, index)

        local control = self.Columns[who][index].Control:GetNamedChild(iconName)
        if control ~= nil then
            control:SetHidden(true)
        end
    end
end

function addon:getSetItems(setId)
    if self.sets[setId] == nil then
        self.sets[setId] = {}
        for index = 1, GetNumItemSetCollectionPieces(setId) do
            local pieceId, slot = GetItemSetCollectionPieceInfo(setId, index)
            table.insert(self.sets[setId], pieceId)
        end
    end

    return self.sets[setId]
end

function addon:ui()
    if self.settings.data.uiEnhancemements == false then
        return
    end

    ZO_PostHook(ZO_ItemSetsBook_Keyboard, "RefreshCategoryProgress", function(self)
        local itemSetCollectionCategoryData = self:GetSelectedCategory()
        if itemSetCollectionCategoryData then
            if self:IsReconstructing() == false then
                local numUnlockedPieces, numPieces = itemSetCollectionCategoryData:GetNumUnlockedAndTotalPieces()
                self.categoryProgressLabel:SetText(zo_strformat(SI_ITEM_SETS_BOOK_CATEGORY_PROGRESS, numUnlockedPieces, numPieces) .. "  (" .. tostring(math.floor((numUnlockedPieces / numPieces) * 100)) .. "%)")
            end
        end
    end)

    ZO_PostHook(ZO_ItemSetsBook_Keyboard, "SetupGridHeaderEntry", function(self, control, data, selected)
        local itemSetHeaderData = data.header

        local progressBarLabel = control.progressBar:GetNamedChild("Progress")
        local numUnlockedPieces = itemSetHeaderData:GetNumUnlockedPieces()
        local numPieces = itemSetHeaderData:GetNumPieces()

        progressBarLabel:SetText(zo_strformat(SI_ITEM_SETS_BOOK_CATEGORY_PROGRESS, numUnlockedPieces, numPieces) .. "  (" .. tostring(math.floor((numUnlockedPieces / numPieces) * 100)) .. "%)")
    end)
end

function addon:chatHook(hook)
    if hook then
        local chatMessageFormatters = {}

        chatMessageFormatters[EVENT_CHAT_MESSAGE_CHANNEL] = CHAT_ROUTER:GetRegisteredMessageFormatters()[EVENT_CHAT_MESSAGE_CHANNEL]
        CHAT_ROUTER:RegisterMessageFormatter(EVENT_CHAT_MESSAGE_CHANNEL, function(messageType, fromName, text, isFromCustomerService, fromDisplayName)
            return chatMessageFormatters[EVENT_CHAT_MESSAGE_CHANNEL](messageType, fromName, self:replaceItemLinks(text), isFromCustomerService, fromDisplayName)
        end)
    end
end

function addon:replaceItemLinks(message)
    local links = {}
    ZO_ExtractLinksFromText(message, { [ITEM_LINK_TYPE] = true }, links)

    local foundItemlinks = {}
    for _, originalItemLink in ipairs(links) do
        local messageParts = {}
        if IsItemLinkSetCollectionPiece(originalItemLink.link) and not IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(originalItemLink.link)) then
            table.insert(messageParts, string.format("|cff0000|t%d:%d:%s:inheritcolor|t|r", 24, 24, "esoui/art/collections/collections_tabIcon_itemSets_down.dds"))
        end
        local itemLink = originalItemLink.link:gsub("^|H0", "|H1", 1)
        table.insert(messageParts, itemLink)
        foundItemlinks[originalItemLink.link] = table.concat(messageParts, "")
    end

    for itemLink, itemLinkWithIcon in pairs(foundItemlinks) do
        message = string.gsub(message, itemLink, itemLinkWithIcon)
    end

    return message
end

function addon:addMessage(message)
    local messageParts = {
        string.format("|cff0000|t%d:%d:%s:inheritcolor|t|r", 24, 24, "esoui/art/collections/collections_tabIcon_itemSets_down.dds"),
        message
    }
    CHAT_ROUTER:AddSystemMessage(table.concat(messageParts, " "))
end

function addon:getAddonData()
    for index = 1, GetAddOnManager():GetNumAddOns() do
        local name, title, author, description, enabled, state, isOutOfDate, isLibrary = GetAddOnManager():GetAddOnInfo(index)
        if name == self.name then
            return {
                name = name,
                title = title,
                author = author,
                version = GetAddOnManager():GetAddOnVersion(index),
            }
        end
    end

    return nil
end

EVENT_MANAGER:RegisterForEvent(addonId, EVENT_ADD_ON_LOADED, function(event, addonName)
    if addonName ~= addonId then
        return
    end

    assert(not _G[addonId], string.format("'%s' has already been loaded", addonId))
    _G[addonId] = addon:New(addonId)
    EVENT_MANAGER:UnregisterForEvent(addonId, EVENT_ADD_ON_LOADED)
end)
