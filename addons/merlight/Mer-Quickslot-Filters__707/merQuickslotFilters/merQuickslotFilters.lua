local myNAME = "merQuickslotFilters"


local function qsCreateItemTypeFilterData(manager, filterName, itemTypes,
                                          normal, pressed, highlight)
    local itemTypeFilter = {}

    for _, itemType in ipairs(itemTypes) do
        itemTypeFilter[itemType] = true
        filterName = filterName or GetString("SI_ITEMTYPE", itemType)
    end

    filterName = zo_strformat("<<1>>", filterName)

    return {
        -- Mer custom data
        merQuickslotFiltersItemTypes = itemTypeFilter,

        -- Quickslot manager data
        activeTabText = filterName,
        tooltipText = filterName,
        sortKey = "name",
        sortOrder = ZO_SORT_ORDER_UP,

        -- Menu bar data
        descriptor = ITEMFILTERTYPE_QUICKSLOT,
        normal = normal,
        pressed = pressed,
        highlight = highlight,
        callback = function(tabData) manager:ChangeFilter(tabData) end,
    }
end


local function qsInsertItemTypeFilter(manager, ...)
    local data = qsCreateItemTypeFilterData(manager, ...)
    table.insert(manager.quickslotFilters, data)
    ZO_MenuBar_AddButton(manager.tabs, data)
end


local function onAddOnLoaded(event, addOnName)
    if addOnName ~= myNAME then return end
    EVENT_MANAGER:UnregisterForEvent(myNAME, EVENT_ADD_ON_LOADED)

    local zorgShouldAddItemToList = QUICKSLOT_WINDOW.ShouldAddItemToList
    local seenItems = {}

    local function preUpdateList(self)
        ZO_ClearTable(seenItems)
    end

    local function qsShouldAddItemToList(self, itemData)
        if not zorgShouldAddItemToList(self, itemData) then
            return false
        end

        local itemInstanceId = GetItemInstanceId(itemData.bagId, itemData.slotIndex)
        local seenData = seenItems[itemInstanceId]
        if seenData then
            -- Add this stack to the first one.
            seenData.stackCount = seenData.stackCount + itemData.stackCount
            return false
        end

        local itemTypeFilter = self.currentFilter.merQuickslotFiltersItemTypes
        if itemTypeFilter then
            local itemType = GetItemType(itemData.bagId, itemData.slotIndex)
            if not itemTypeFilter[itemType] then
                return false
            end
        end

        -- Remember this stack so we can pile matching items onto it.
        seenItems[itemInstanceId] = itemData
        return true
    end

    ZO_PreHook(QUICKSLOT_WINDOW, "UpdateList", preUpdateList)
    QUICKSLOT_WINDOW.ShouldAddItemToList = qsShouldAddItemToList

    -- Inventory filter tooltips on the Items tab appear ABOVE buttons,
    -- while on the Quickslots tab the tooltip's TOPRIGHT corner anchors
    -- to the button's CENTERLEFT. Which is inconsistent, and the latter
    -- doesn't look right (pun intended).
    function ZO_QuickSlot_FilterButtonOnMouseEnter(self)
        ZO_MenuBarButtonTemplate_OnMouseEnter(self)
        InitializeTooltip(InformationTooltip, self, BOTTOM, 0, -10)
        SetTooltipText(InformationTooltip, ZO_MenuBarButtonTemplate_GetData(self).tooltipText)
    end

    -- The All filter on the Quickslots tab is pretty useless, hide it.
    for _, data in ipairs(QUICKSLOT_WINDOW.quickslotFilters) do
        if data.descriptor == ITEMFILTERTYPE_ALL then
            data.hidden = true
            -- We can skip calling ZO_MenuBar_UpdateButtons to actually
            -- hide the button here, because ZO_MenuBar_AddButton will
            -- do that for us when we add more buttons.
            break
        end
    end

    qsInsertItemTypeFilter(QUICKSLOT_WINDOW, nil, {ITEMTYPE_TROPHY},
        "EsoUI/Art/Journal/journal_tabIcon_leaderboard_up.dds",
        "EsoUI/Art/Journal/journal_tabIcon_leaderboard_down.dds",
        "EsoUI/Art/Journal/journal_tabIcon_leaderboard_over.dds")

    qsInsertItemTypeFilter(QUICKSLOT_WINDOW, nil, {ITEMTYPE_SIEGE},
        "EsoUI/Art/Inventory/inventory_tabIcon_weapons_up.dds",
        "EsoUI/Art/Inventory/inventory_tabIcon_weapons_down.dds",
        "EsoUI/Art/Inventory/inventory_tabIcon_weapons_over.dds")

    qsInsertItemTypeFilter(QUICKSLOT_WINDOW, nil, {ITEMTYPE_AVA_REPAIR},
        "EsoUI/Art/Inventory/inventory_tabIcon_crafting_up.dds",
        "EsoUI/Art/Inventory/inventory_tabIcon_crafting_down.dds",
        "EsoUI/Art/Inventory/inventory_tabIcon_crafting_over.dds")

    qsInsertItemTypeFilter(QUICKSLOT_WINDOW,
        GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_CONSUMABLE),
        {ITEMTYPE_FOOD, ITEMTYPE_DRINK, ITEMTYPE_POTION},
        "EsoUI/Art/Inventory/inventory_tabIcon_consumables_up.dds",
        "EsoUI/Art/Inventory/inventory_tabIcon_consumables_down.dds",
        "EsoUI/Art/Inventory/inventory_tabIcon_consumables_over.dds")
end


EVENT_MANAGER:RegisterForEvent(myNAME, EVENT_ADD_ON_LOADED, onAddOnLoaded)
