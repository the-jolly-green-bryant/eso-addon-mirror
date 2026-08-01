qcLockedItemsTab = {}
qcLockedItemsTab.name = "LockedItemsTab"

-----------------------------------------------------------------------------------------------------------------------------------
-- Configuration
-----------------------------------------------------------------------------------------------------------------------------------

-- Specifies if the button for the Locked Tab should be present.
qcLockedItemsTab.enableLockedTab = true

-- Specifies if additional subfilter buttons should be present.
qcLockedItemsTab.enableSubFilterButtons = true

-- Specifies if the 'Locked' button should be on the right side.
-- Change this to false to keep the Locked button on the left side.
qcLockedItemsTab.buttonOnRight = true

-----------------------------------------------------------------------------------------------------------------------------------
-- Variables
-----------------------------------------------------------------------------------------------------------------------------------

-- The original (localized) text of the 'All' button will be stored here (will be replaced by the localized text.)
qcLockedItemsTab.originalTabNameAll = "All"

-- Get the localized string for 'Locked'
qcLockedItemsTab.tabNameLocked = GetString(SI_ITEM_FORMAT_STR_LOCKED)

-- Stored tags for the custom filters added in LibFilters3
qcLockedItemsTab.filterTags = {}

-- Specifies if one of the fragments is showing where items should be filtered
qcLockedItemsTab.isInFragment = false

-- Specifies if the button for the Locked Tab should be visible
qcLockedItemsTab.lockedTabVisible = false

-- Specifies if the filter should only show locked items or only unlocked items.
qcLockedItemsTab.filterLockedItems = false

-- Specifies which category of items to filter
qcLockedItemsTab.subFilter = ITEM_TYPE_DISPLAY_CATEGORY_ALL

-----------------------------------------------------------------------------------------------------------------------------------
-- Callback for tab buttons
-- Handles both the 'Locked' button and all existing tab buttons
-----------------------------------------------------------------------------------------------------------------------------------

local function AdjustAllFilterText(inventory)
    -- Change the predefined filter text so that 'Locked:...' or 'All:...' is displayed
    for k,filter in pairs(inventory.tabFilters) do
        if filter.filterType == ITEM_TYPE_DISPLAY_CATEGORY_ALL then
            if qcLockedItemsTab.filterLockedItems then
                filter.activeTabText = qcLockedItemsTab.tabNameLocked
            else
                filter.activeTabText = qcLockedItemsTab.originalTabNameAll
            end
            break
        end
    end
end

local function HandleTabSwitch(tabData)
    -- Handles both the 'Locked' button and all existing tab buttons

    -- Set variable to true if the 'Locked' button was pressed
    -- A much cleaner solution, thanks Baertram!
    qcLockedItemsTab.filterLockedItems = tabData.__isLockedItemsTab == true

    -- Reset subfilter type for the filter function
    -- Because not all sub filters have been rehooked to the local HandleTabSwitchSubFilter function,
    -- this lets ESO UI handle filtering for the other tabs.
    qcLockedItemsTab.subFilter = ITEM_TYPE_DISPLAY_CATEGORY_ALL

    -- Unfortunately ESOUI does not use the text that is passed in tabData, instead it uses the text that is stored in its presets.
    -- For this reason it is manually set to 'All' or 'Locked' here
    AdjustAllFilterText(PLAYER_INVENTORY.inventories[INVENTORY_BACKPACK])
    AdjustAllFilterText(PLAYER_INVENTORY.inventories[INVENTORY_BANK])
    AdjustAllFilterText(PLAYER_INVENTORY.inventories[INVENTORY_HOUSE_BANK])

    -- Pass to ESO UI
    PLAYER_INVENTORY:ChangeFilter(tabData)
end

-----------------------------------------------------------------------------------------------------------------------------------
-- Create/remove/rehook tab buttons
-----------------------------------------------------------------------------------------------------------------------------------

local function HasLockedTabButtonPlayerInventory()    
    -- Returns true if the button for the 'Locked' tab is already present
    local buttons = ZO_PlayerInventoryTabs.m_object.m_buttons
    for k,v in pairs(buttons) do
        if v[1].m_object.m_buttonData.__isLockedItemsTab then 
            return true
        end
    end
    return false
end

local function RehookTabButtons(buttons)
    -- Change the callback to use the local HandleTabSwitch function.
    -- This is required to set the filterLockedItems variable correctly.
    for k,v in pairs(buttons) do
        local buttonData = v[1].m_object.m_buttonData
        if not (buttonData.__isLockedItemsRehookedTab or buttonData.__isLockedItemsTab) then

            -- Identifier for other addons which are able to check the descriptor of the filterTab
            buttonData.__isLockedItemsRehookedTab = true

            buttonData.callback = HandleTabSwitch
        end
    end
end

local function CreateFilterLocked(inventoryType)
    -- Use the 'All' filter type as template
    local filterData = ZO_ItemFilterUtils.GetItemTypeDisplayCategoryFilterDisplayInfo(ITEM_TYPE_DISPLAY_CATEGORY_ALL)

    -- Store the original text for the 'All' category
    qcLockedItemsTab.originalTabNameAll = filterData.filterString

    return {
        -- Identifier for other addons which are able to check the descriptor of the filterTab
        __isLockedItemsTab = true,
        
        -- Custom data
        filterType = filterData.filterType,
        inventoryType = inventoryType,
        isSubFilter = false,
        hiddenColumns = filterData.hideColumnTable,
        activeTabText = qcLockedItemsTab.tabNameLocked,
        tooltipText = qcLockedItemsTab.tabNameLocked,

        -- Menu bar data
        hidden = filterData.hideTabFunction,
        ignoreVisibleCheck = filterData.hideTabFunction == true,
        descriptor = filterData.filterType,
        normal = "EsoUI/Art/Progression/Progression_Crafting_Locked_Up.dds",
        pressed = "EsoUI/Art/Progression/Progression_Crafting_Locked_Down.dds",
        highlight = "EsoUI/Art/Progression/Progression_Crafting_Locked_Over.dds",
        callback = HandleTabSwitch,
    }
end

local function MenuBarMoveButtonToRight(menuBar)

    -- ZO_MenuBar_AddButton does not support specifying the button index, so new buttons always get added to the end of the list (left-most in the menu bar.)
    -- This function moves it to the beginning of the list (right-most) and causes the buttons to be redrawn.
    local button = table.remove(menuBar.m_object.m_buttons)
    table.insert(menuBar.m_object.m_buttons, 1, button)
    menuBar.m_object:UpdateButtons()
end

local function AddLockedTabButton(menuBar, inventoryType)
    local buttonData = CreateFilterLocked(inventoryType)
    local button = ZO_MenuBar_AddButton(menuBar, buttonData)
    if qcLockedItemsTab.buttonOnRight then
        MenuBarMoveButtonToRight(menuBar)
    end
    return button
end

local function RemoveLockedTabButtonPlayerInventory()
    ZO_PlayerInventoryTabs.m_object:UpdateButtons()
end

local function InitializePlayerInventory()
    if qcLockedItemsTab.lockedTabVisible then
        if not HasLockedTabButtonPlayerInventory() then
            RehookTabButtons(ZO_PlayerInventoryTabs.m_object.m_buttons)
            qcLockedItemsTab.controlLockedButton = AddLockedTabButton(ZO_PlayerInventoryTabs, INVENTORY_BACKPACK)
        end
    else
        RemoveLockedTabButtonPlayerInventory()
    end
end

-----------------------------------------------------------------------------------------------------------------------------------
-- Callback for fragment state change
-----------------------------------------------------------------------------------------------------------------------------------

local function fragmentChange(oldState, newState)
    
    if (newState == SCENE_FRAGMENT_SHOWN) then

        -- d("Fragment shown " .. SCENE_MANAGER:GetCurrentSceneName())

        qcLockedItemsTab.isInFragment = SCENE_MANAGER:IsShowing("inventory") or SCENE_MANAGER:IsShowing("bank") or SCENE_MANAGER:IsShowing("houseBank")
        qcLockedItemsTab.lockedTabVisible = qcLockedItemsTab.enableLockedTab and qcLockedItemsTab.isInFragment

    elseif (newState == SCENE_FRAGMENT_HIDDEN) then

        -- d("Fragment hidden " .. SCENE_MANAGER:GetCurrentSceneName())

        qcLockedItemsTab.isInFragment = false
        qcLockedItemsTab.lockedTabVisible = false
        qcLockedItemsTab.subFilter = ITEM_TYPE_DISPLAY_CATEGORY_ALL

    end
    
    InitializePlayerInventory()
end

INVENTORY_FRAGMENT:RegisterCallback("StateChange", fragmentChange)
BANK_FRAGMENT:RegisterCallback("StateChange", fragmentChange)
HOUSE_BANK_FRAGMENT:RegisterCallback("StateChange", fragmentChange)

-----------------------------------------------------------------------------------------------------------------------------------
-- The filter function that will be registered in LibFilters3
-----------------------------------------------------------------------------------------------------------------------------------

local function FilterFuncForPlayerInv(inventorySlot)
    if not qcLockedItemsTab.isInFragment and inventorySlot.isPlayerLocked then
        -- In all other fragments filter out locked items, as they will not be shown anyway and this fixes a problem
        -- with the inventory showing locked items initially (because the list is generated before the fragment is shown)
        return false
    end

    if qcLockedItemsTab.lockedTabVisible and qcLockedItemsTab.filterLockedItems ~= inventorySlot.isPlayerLocked then
        return false
    end

    if qcLockedItemsTab.subFilter == ITEM_TYPE_DISPLAY_CATEGORY_ALL then
        return true
    end
    
    return ZO_ItemFilterUtils.IsSlotInItemTypeDisplayCategoryAndSubcategory(inventorySlot, qcLockedItemsTab.subFilter, ITEM_TYPE_DISPLAY_CATEGORY_ALL)
end

-----------------------------------------------------------------------------------------------------------------------------------
-- Subfilters
-----------------------------------------------------------------------------------------------------------------------------------

-- The callback that is attached to the sub filter buttons
local function HandleTabSwitchSubFilter(tabData)

    -- Save subfilter type
    -- In the 'All' tab (or the 'Locked' tab which is a copy of that) the ESO UI default filter ignores any sub filters, so the filter type is stored here
    -- and the actual filtering is done in the LibFilters3 filter function.
    qcLockedItemsTab.subFilter = tabData.filterType

    -- Pass to ESO UI
    PLAYER_INVENTORY:ChangeFilter(tabData)
end

local function CreateSubFilter(filterCategory, inventoryType)
    local filterData = ZO_ItemFilterUtils.GetItemTypeDisplayCategoryFilterDisplayInfo(filterCategory)
    return {
        -- Identifier for other addons which are able to check the descriptor of the filterTab.
        -- Note: the subfilters that are added here are used for the 'Locked' tab as well as the 'All' tab.
        __isLockedItemsSubTab = true,
        
        -- Custom data
        filterType = filterData.filterType,
        inventoryType = inventoryType,
        isSubFilter = true,
        hiddenColumns = filterData.hideColumnTable,
        activeTabText = filterData.filterString,
        tooltipText = filterData.filterString,

        -- Menu bar data
        hidden = filterData.hideTabFunction,
        ignoreVisibleCheck = filterData.hideTabFunction == true,
        descriptor = filterData.filterType,
        normal = filterData.icons.up,
        pressed = filterData.icons.down,
        highlight = filterData.icons.over,
        callback = HandleTabSwitchSubFilter,
    }
end

local function AddSubFilterButtonToInventory(typeInventory, subFilterCategory, menuBar, tableSubfilters)
    local filter = CreateSubFilter(subFilterCategory, typeInventory)
    filter.control = ZO_MenuBar_AddButton(menuBar, filter)
    table.insert(tableSubfilters, filter)
end

local function AddSubfilterButtonsToInventory(typeInventory)
    -- Add sub filter buttons for the 'Locked' and 'All' tabs (because the ESO UI cannot distinguish between them, buttons will always be added for both.)
    local inventory = PLAYER_INVENTORY.inventories[typeInventory]
    local tableSubfilters = inventory.subFilters[ITEM_TYPE_DISPLAY_CATEGORY_ALL]
    if #tableSubfilters == 1 then
        local menuBar = inventory.subFilterBar

        -- Remove existing 'All' subfilter button
        table.remove(tableSubfilters)
        ZO_MenuBar_ClearButtons(menuBar)

        -- Add sub filters
        local subfilters = {
            ITEM_TYPE_DISPLAY_CATEGORY_CONSUMABLE,
            ITEM_TYPE_DISPLAY_CATEGORY_JEWELRY,
            ITEM_TYPE_DISPLAY_CATEGORY_ARMOR,
            ITEM_TYPE_DISPLAY_CATEGORY_WEAPONS,
            ITEM_TYPE_DISPLAY_CATEGORY_ALL,
        }
        for _, typeSubfilter in ipairs(subfilters) do
            AddSubFilterButtonToInventory(typeInventory, typeSubfilter, menuBar, tableSubfilters)
        end
        
        -- Make the new 'All' button the active button
        ZO_MenuBar_SelectDescriptor(menuBar, ITEM_TYPE_DISPLAY_CATEGORY_ALL)
    end
end

-----------------------------------------------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------------------------------------------

local function Initialize()
    -- required to use LibFilters3
    LibFilters3:InitializeLibFilters()

    -- Generate unique tags for filter functions
    local typesLF = {
        LF_INVENTORY,
        LF_BANK_DEPOSIT,
        LF_BANK_WITHDRAW,
        LF_GUILDBANK_DEPOSIT,
        LF_GUILDBANK_WITHDRAW,
        LF_HOUSE_BANK_DEPOSIT,
        LF_HOUSE_BANK_WITHDRAW,
        LF_VENDOR_SELL,
        LF_GUILDSTORE_SELL,
        LF_MAIL_SEND,
        LF_TRADE,
    }
    for _, keyLF in ipairs(typesLF) do
        qcLockedItemsTab.filterTags[keyLF] = qcLockedItemsTab.name .. "_CustomFilterTag_" .. keyLF
    end

    -- Adds the inventory filters in LibFilters3
    for keyLF, nameLF in pairs(qcLockedItemsTab.filterTags) do
        if not LibFilters3:IsFilterRegistered(nameLF, keyLF) then
            LibFilters3:RegisterFilter(nameLF, keyLF, FilterFuncForPlayerInv)
        end
    end

    if qcLockedItemsTab.enableLockedTab then
        -- Setup bank and house storage tab controls here, as this needs to be done only once.
        RehookTabButtons(ZO_PlayerBankTabs.m_object.m_buttons)
        AddLockedTabButton(ZO_PlayerBankTabs, INVENTORY_BANK)

        RehookTabButtons(ZO_HouseBankTabs.m_object.m_buttons)
        AddLockedTabButton(ZO_HouseBankTabs, INVENTORY_HOUSE_BANK)
    end

    -- Add sub filter buttons
    if qcLockedItemsTab.enableSubFilterButtons then
        AddSubfilterButtonsToInventory(INVENTORY_BACKPACK)
        AddSubfilterButtonsToInventory(INVENTORY_BANK)
        AddSubfilterButtonsToInventory(INVENTORY_HOUSE_BANK)
    end
end

local function OnAddOnLoaded(event, addonName)
    if addonName == qcLockedItemsTab.name then
        
        --unregister the event again as our addon was loaded now and we do not need it anymore to be run for each other addon that will load
        EVENT_MANAGER:UnregisterForEvent(qcLockedItemsTab.name, EVENT_ADD_ON_LOADED) 

        Initialize()
    end
end
   
EVENT_MANAGER:RegisterForEvent(qcLockedItemsTab.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
