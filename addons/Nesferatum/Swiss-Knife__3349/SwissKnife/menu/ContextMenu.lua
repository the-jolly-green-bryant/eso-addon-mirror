local SK = SwissKnife
local SKH = SK.HelperFunctions
local SKA = SK.Automation
local SKDC = SK.Data.common
local SKDE = SK.Data.equipmentData
local WM = WINDOW_MANAGER

local _hooksOnInventoryContextMenuInitialized = false
local _hooksOnCollectionsContextMenuInitialized = false
local _hooksOnLinkContextMenuInitialized = false
local _hooksOnAbilitySlotMenuInitialized = false
local _hooksOnItemBrowserContextMenuInitialized = false

local function _addItemDynamicContextMenuEntries(itemLink, isInventory)
    local label = ""
    local itemId = GetItemLinkItemId(itemLink)
    local hasSet, setId, setName, isCompanionEquipment = SKH.getItemLinkSetInfo(itemLink)
    if SK.savedVars.showCollectablesSetItemExtraTooltip and not isInventory then
    	local isCollectables, _, _ = SKH.isItemLinkCollectables(itemLink)
        local control = WM:GetControlByName("GuiRoot")
	    if isCollectables and control ~= nil then
		    local isCollectionsFull, _, _ = SKH.isItemSetCollectionsFull(setId)
            if not isCollectionsFull then
                AddCustomMenuItem(
                    table.concat({
                        SK.COLORED_PREFIXES.SKW,
                        SKH.getFormattedText(GetString(SI_SK_INFO_SUBMENU_SHOW_COLLECTABLES_INFO_HEADER))
                    }),
                    function() SKH.showCollectablesTooltip(control, nil, nil, itemLink) end
                )
            end
        end
    end
    if SK.savedVars.trackSetsItems then
        if SKH.isTrackedSetPartsItem(itemLink) then
            AddCustomMenuItem(
                table.concat({
                    SK.COLORED_PREFIXES.SKW,
                    SKH.getFormattedText(GetString(SI_SK_INFO_SUBMENU_SHOW_WHERE_HEADER))
                }),
                function() SKMD:Open(SKDC.MAIN_DIALOGUE_TRACKED_SET_ITEMS_MODE, setName) end
            )
        end
    end
    local entries = {}
    if not hasSet then
        local isItemRuleExisting = SKH.isKeyInTable(SK.globalSV.permanentUnwantedItemIds, itemId)
        if not isItemRuleExisting then
            if isInventory then
                label = "|t24:24:SwissKnife/textures/dialogues/nav/broken_pottery_tabicon_down.dds|t"..GetString(SI_SK_AUT_SUBMENU_MARK)
            else
                label = table.concat({
                    SK.COLORED_PREFIXES.SKA,
                    SKH.getFormattedText(GetString(SI_SK_AUT_SUBMENU_MARK_PERM_UNW))
                })
            end
            if SK.savedVars.filterUnwantedItemAfterLoot then
                table.insert(
                    entries,
                    {
                        label = label..' - '..SK.COLOR.ORANGE:Colorize(SKDC.UNWANTED_ACTIONS_NAMES[SK.junkAction]),
                        callback = function()
                            SKA.addItemToPermanentUnwanted(itemLink, SK.junkAction)
                        end,
                    }
                )
                table.insert(
                    entries,
                    {
                        label = label..' - '..SK.COLOR.ORANGE:Colorize(SKDC.UNWANTED_ACTIONS_NAMES[SK.destroyAction]),
                        callback = function()
                            SKA.addItemToPermanentUnwanted(itemLink, SK.destroyAction)
                        end,
                    }
                )
            end
        else
            if isInventory then
                label = "|t24:24:SwissKnife/textures/dialogues/icons/disable_down.dds|t"..GetString(SI_SK_AUT_SUBMENU_UNMARK)
            else
                label = table.concat({
                    SK.COLORED_PREFIXES.SKA,
                    SKH.getFormattedText(GetString(SI_SK_AUT_SUBMENU_UNMARK_PERM_UNW))
                })
            end
            table.insert(
                entries,
                {
                    label = label,
                    callback = function()
                        SKA.removeItemFromPermanentUnwanted(itemLink)
                    end,
                    disabled = function() return not isItemRuleExisting end,
                }
            )
        end
    end
    if SK.savedVars.junkUnwantedSetsAfterLoot and hasSet and not isCompanionEquipment then
        local isSetRuleExisting = SKH.isKeyInTable(SK.globalSV.permanentUnwantedSetIds, setId)
        if not isSetRuleExisting then
            if isInventory then
                label = "|t24:24:SwissKnife/textures/loot/sets_tabicon_down.dds|t"..GetString(SI_SK_AUT_SUBMENU_MARK_PERM_UNW_SETS)
            else
                label = table.concat({
                    SK.COLORED_PREFIXES.SKA,
                    SKH.getFormattedText(GetString(SI_SK_AUT_SUBMENU_MARK_PERM_UNW_SETS))
                })
            end
            table.insert(
                entries,
                {
                    label = label,
                    callback = function()
                        SKA.addSetToPermanentUnwanted(itemLink)
                    end,
                }
            )
        else
            if isInventory then
                label = "|t24:24:SwissKnife/textures/dialogues/icons/disable_down.dds|t"..GetString(SI_SK_AUT_SUBMENU_UNMARK_PERM_UNW_SETS)
            else
                label = table.concat({
                    SK.COLORED_PREFIXES.SKA,
                    SKH.getFormattedText(GetString(SI_SK_AUT_SUBMENU_UNMARK_PERM_UNW_SETS))
                })
            end
            table.insert(
                entries,
                {
                    label = label,
                    callback = function()
                        SKA.removeSetFromPermanentUnwanted(itemLink)
                    end,
                }
            )
            if isInventory then
                label = "|t24:24:SwissKnife/textures/dialogues/icons/edit_down.dds|t"..SK.COLOR.GREEN:Colorize(GetString(SI_SK_AUT_SUBMENU_EDIT_SET))
            else
                label = table.concat({
                    SK.COLORED_PREFIXES.SKA,
                    SKH.getFormattedText(SK.COLOR.GREEN:Colorize(GetString(SI_SK_AUT_SUBMENU_EDIT_SET)))
                })
            end
            table.insert(
                entries,
                {
                    label = label,
                    callback = function() SKEUS:Open(itemLink) end,
                }
            )
        end
    end
    if SK.savedVars.filterUnwantedItemAfterLoot or SK.savedVars.junkUnwantedSetsAfterLoot then
        local mode = SKDC.MAIN_DIALOGUE_UNWANTED_ITEMS_MODE
        if hasSet then mode = SKDC.MAIN_DIALOGUE_UNWANTED_SETS_MODE end
        if isInventory and not SKMD.isVisible then
            table.insert(
                entries,
                {
                    label = "|t24:24:SwissKnife/textures/gui/checklist.dds|t"..SK.COLOR.ORANGE:Colorize(GetString(SI_SK_AUT_SUBMENU_SHOW_FILTERS)),
                    callback = function() SKMD:Open(mode) end
                }
            )
        end
        if isInventory then
            table.insert(
                entries,
                {
                    label = "|t24:24:SwissKnife/textures/gui/cycle.dds|t"..SK.COLOR.ORANGE_RED:Colorize(GetString(SI_SK_AUT_SUBMENU_FILTER_BACKPACK)),
                    callback = function()
                        SKA.filterAllBackpackItemsByRules(SK.savedVars.junkDeconstructedToo)
                    end
                }
            )
        end
    end
    if SK.savedVars.junkUnwantedSetsAfterLoot and not SK.savedVars.junkDeconstructedToo and isInventory then
        table.insert(
            entries,
            {
                label = "|t24:24:SwissKnife/textures/gui/hazard.dds|t"..SK.COLOR.RED:Colorize(GetString(SI_SK_AUT_SUBMENU_FILTER_DECONSTRUCT_BACKPACK)),
                callback = function()
                    SKA.filterAllBackpackItemsByRules(true)
                end
            }
        )
    end
    if isInventory then
        AddCustomSubMenuItem(
            table.concat({
                SK.COLORED_PREFIXES.SKA,
                SKH.getFormattedText(GetString(SI_SK_AUT_SUBMENU_UNWANTED))
            }),
            entries
        )
    else
        for _, entryData in ipairs(entries) do
            AddCustomMenuItem(entryData.label, function() entryData.callback() end)
        end
    end
    if SK.savedVars.isAutoLaunderEnabled and (not hasSet or (hasSet and isInventory and IsItemLinkStolen(itemLink))) then
        if SKH.isKeyInTable(SK.globalSV.launderItems, itemId) then
            AddCustomMenuItem(
                table.concat({
                    SK.COLORED_PREFIXES.SKA,
                    SKH.getFormattedText(GetString(SI_SK_AUT_SUBMENU_UNMARK_LAUNDERED))
                }),
                function()
                    SK.globalSV.launderItems[itemId] = nil
                end
            )
        elseif not SKH.isItemForLaunder(nil, nil, itemLink) then
            AddCustomMenuItem(
                table.concat({
                    SK.COLORED_PREFIXES.SKA,
                    SKH.getFormattedText(GetString(SI_SK_AUT_SUBMENU_MARK_LAUNDERED))
                }),
                function() SK.globalSV.launderItems[itemId] = 1 end
            )
        end
    end
    if SK.savedVars.bindUnknownCollectablesSetItems and hasSet then
        local isCollectables, setIdCollectables, itemSlot = SKH.isItemLinkCollectables(itemLink)
        if isCollectables then
            if SKH.isKeyInTable(SK.globalSV.notBindItems, itemId) then
                AddCustomMenuItem(
                    table.concat({
                        SK.COLORED_PREFIXES.SKA,
                        SKH.getFormattedText(GetString(SI_SK_AUT_SUBMENU_ENABLE_LOOT_BIND))
                    }),
                    function() SKA.removeItemFromNotBind(itemLink, itemId) end
                )
            elseif not IsItemSetCollectionSlotUnlocked(setIdCollectables, itemSlot) then
                AddCustomMenuItem(
                    table.concat({
                        SK.COLORED_PREFIXES.SKA,
                        SKH.getFormattedText(GetString(SI_SK_AUT_SUBMENU_DISABLE_LOOT_BIND))
                    }),
                    function() SKA.addItemToNotBind(itemLink, itemId) end
                )
            end
        end
    end
    if SK.savedVars.sendMailToAnotherAccount and not SK.savedVars.isAutomaticModeSendMail and isInventory then
        AddCustomMenuItem(
            table.concat({
                SK.COLORED_PREFIXES.SKM,
                SKH.getFormattedText(GetString(SI_SK_AUT_SENDING_MENU_HEADER))
            }),
            function() SKA.sendMailAllFilteredItems() end
        )
    end
end

local function _addLinkDynamicContextMenuEntries(link)
    local _, _, data, _ = link:match("|H(.-):(.-):(.-)|h(.-)|h")
    local linkType = zo_strsplit(";", data)
    if linkType == SK.LINK_TYPES.ABILITIES_PRESET then
        AddCustomMenuItem(
            table.concat({
                SK.COLORED_PREFIXES.SKW,
                SKH.getFormattedText(GetString(SI_SK_AUT_ABILITY_LIST_IMPORT_HOTBAR_BUTTON))
            }),
            function() SKH.importAbilityPreset(link, false) end
        )
        AddCustomMenuItem(
            table.concat({
                SK.COLORED_PREFIXES.SKW,
                SKH.getFormattedText(GetString(SI_SK_AUT_ABILITY_LIST_SET_HOTBAR_BUTTON))
            }),
            function() SKH.importAbilityPreset(link, true) end
        )
    end
end


local function delayedAppendEntry(itemLink, isInventory)
    zo_callLater(function()
        _addItemDynamicContextMenuEntries(itemLink, isInventory)
        ShowMenu()
    end)
end

local function initHooksOnInventoryContextMenu()
    if not _hooksOnInventoryContextMenuInitialized then
        _hooksOnInventoryContextMenuInitialized = true
        ZO_PreHook("ZO_InventorySlot_ShowContextMenu",
            function(inventorySlot)
                local slotType = ZO_InventorySlot_GetType(inventorySlot)
                if SKH.isValueInList(SKDE.CONTEXT_MENU_SLOTS, slotType) then
                    if SK.savedVars.filterUnwantedItemAfterLoot or SK.savedVars.junkUnwantedSetsAfterLoot or
                        SK.savedVars.trackSetsItems
                    then
                        local isInventory = slotType == SLOT_TYPE_ITEM
                        local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
                        local itemLink = GetItemLink(bagId, slotIndex)
                        delayedAppendEntry(itemLink, isInventory)
                    end
                elseif slotType == SLOT_TYPE_STORE_BUY then
                    local itemLink = GetStoreItemLink(inventorySlot.index)
                    delayedAppendEntry(itemLink, false)
                elseif slotType == SLOT_TYPE_TRADING_HOUSE_ITEM_RESULT then
                    local itemLink = GetTradingHouseSearchResultItemLink(ZO_Inventory_GetSlotIndex(inventorySlot))
                    delayedAppendEntry(itemLink, false)
                end
            end
        )
    end
end

local function initHooksOnCollectionsContextMenu()
    if not _hooksOnCollectionsContextMenuInitialized then
        _hooksOnCollectionsContextMenuInitialized = true
        ZO_PreHook(ZO_ItemSetCollectionPieceTile_Keyboard, "ShowMenu",
            function(self)
                local itemSetCollectionPieceData = self.itemSetCollectionPieceData
                if itemSetCollectionPieceData then
                    local itemLink = itemSetCollectionPieceData:GetItemLink()
                    delayedAppendEntry(itemLink, false)
                end
            end
        )
    end
end

local function initHooksOnItemBrowserContextMenu()
    if not _hooksOnItemBrowserContextMenuInitialized then
        _hooksOnItemBrowserContextMenuInitialized = true
        if ExtendedJournalSortFilterList then
            ZO_PreHook(ExtendedJournalSortFilterList, "Row_OnMouseUp",
                function(self, control, button, upInside)
                    local data = ZO_ScrollList_GetData(control)
                    if data then delayedAppendEntry(data.itemLink, false) end
                end
            )
        end
    end
end

function SK_HandleLinkClickEvent(link, button, control, eventType, linkType, ...)
    if button == MOUSE_BUTTON_INDEX_RIGHT and type(link) == "string" and #link > 0 and link ~= "" then
        if linkType == ITEM_LINK_TYPE then
            zo_callLater(function()
                _addItemDynamicContextMenuEntries(link, false)
                ShowMenu(control)
            end)
        elseif linkType == "unknown" then
            zo_callLater(function()
                _addLinkDynamicContextMenuEntries(link)
                ShowMenu(control)
            end)
	    end
	end
end

local function initHooksOnLinkContextMenu()
    if not _hooksOnLinkContextMenuInitialized then
        _hooksOnLinkContextMenuInitialized = true
        LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, SK_HandleLinkClickEvent)
    end
end

local function initHooksOnAbilitySlotContextMenu()
    if not _hooksOnAbilitySlotMenuInitialized then
        _hooksOnAbilitySlotMenuInitialized = true
        ZO_PreHook("ZO_AbilitySlot_OnSlotClicked",
            function(abilitySlot, buttonId)
                SKH.addAbilityMenuItems(abilitySlot, buttonId)
            end
        )
        ZO_PreHook("ZO_KeyboardAssignableActionBarButton_OnMouseClicked",
            function(abilitySlot, buttonId)
                SKH.addAbilityMenuItems(abilitySlot, buttonId)
            end
        )
    end
end

-- Export
SK.ContextMenu = {
    initHooksOnInventoryContextMenu = initHooksOnInventoryContextMenu,
    initHooksOnCollectionsContextMenu = initHooksOnCollectionsContextMenu,
    initHooksOnItemBrowserContextMenu = initHooksOnItemBrowserContextMenu,
    initHooksOnLinkContextMenu = initHooksOnLinkContextMenu,
    initHooksOnAbilitySlotContextMenu = initHooksOnAbilitySlotContextMenu
}