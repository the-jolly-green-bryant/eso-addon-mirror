-- Create namespace
DsRInventoryButton = {}
local DsRInventoryButton = DsRInventoryButton or {}

local DsRIcon = DsRglobals:HolidayIconLoad()

DsRInventoryButton.name = "DsRInventoryButton"

DsRInventoryButton.enableDsRInventoryTab  = true
DsRInventoryButton.enableSubFilterButtons = true
DsRInventoryButton.buttonOnRight          = true
DsRInventoryButton.originalTabNameAll     = "All"
DsRInventoryButton.tabNameDsRInventory    = GetString(DsRGuildcmd_MainButtonWindow)
DsRInventoryButton.subFilter              = ITEM_TYPE_DISPLAY_CATEGORY_ALL

-------------------------------------------------------------------------------------------------------------------------------------------------
local function AdjustAllFilterText(inventory)
    for k,filter in pairs(inventory.tabFilters) do
        if filter.filterType == ITEM_TYPE_DISPLAY_CATEGORY_ALL then
            if DsRInventoryButton.filterDsRInventoryItems then
                filter.activeTabText = GetString(SI_ITEMTYPEDISPLAYCATEGORY0)
            else
                filter.activeTabText = DsRInventoryButton.originalTabNameAll
            end
            break
        end
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function HandleTabSwitch(tabData)
    DsRInventoryButton.filterDsRInventoryItems = tabData.__isDsRInventoryItemsTab == true

    DsRInventoryButton.subFilter = ITEM_TYPE_DISPLAY_CATEGORY_ALL

    AdjustAllFilterText(PLAYER_INVENTORY.inventories[INVENTORY_BACKPACK])
   
    if tabData.activeTabText == GetString(DsRGuildcmd_MainButtonWindow) then
        DsRGuildPersonalJunkTable:ShowWindow()
    end

    PLAYER_INVENTORY:ChangeFilter(tabData)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function HandleTabSwitchSubFilter(tabData)
    DsRInventoryButton.subFilter = tabData.filterType
    PLAYER_INVENTORY:ChangeFilter(tabData)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function CreateSubFilter(filterCategory, inventoryType)
    local filterData = ZO_ItemFilterUtils.GetItemTypeDisplayCategoryFilterDisplayInfo(filterCategory)
    return {
        __isDsRInventoryItemsSubTab = true,
        
        -- Custom data
        filterType      = filterData.filterType,
        inventoryType   = inventoryType,
        isSubFilter     = true,
        hiddenColumns   = filterData.hideColumnTable,
        activeTabText   = filterData.filterString,
        tooltipText     = filterData.filterString,

        -- Menu bar data
        hidden              = filterData.hideTabFunction,
        ignoreVisibleCheck  = filterData.hideTabFunction == true,
        descriptor          = filterData.filterType,
        normal              = filterData.icons.up,
        pressed             = filterData.icons.down,
        highlight           = filterData.icons.over,
        callback            = HandleTabSwitchSubFilter,
    }
end
    
-------------------------------------------------------------------------------------------------------------------------------------------------
local function AddSubFilterButtonToInventory(typeInventory, subFilterCategory, menuBar, tableSubfilters)
    local filter = CreateSubFilter(subFilterCategory, typeInventory)
    filter.control = ZO_MenuBar_AddButton(menuBar, filter)
    table.insert(tableSubfilters, filter)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function AddSubfilterButtonsToInventory(typeInventory)
    local inventory         = PLAYER_INVENTORY.inventories[typeInventory]
    local tableSubfilters   = inventory.subFilters[ITEM_TYPE_DISPLAY_CATEGORY_ALL]

    if #tableSubfilters == 1 then
        local menuBar = inventory.subFilterBar

        table.remove(tableSubfilters)
        ZO_MenuBar_ClearButtons(menuBar)

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
        
        ZO_MenuBar_SelectDescriptor(menuBar, ITEM_TYPE_DISPLAY_CATEGORY_ALL)
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function RehookTabButtons(buttons)
    for k,v in pairs(buttons) do
        local buttonData = v[1].m_object.m_buttonData
        if not (buttonData.__isDsRInventoryItemsRehookedTab or buttonData.__isDsRInventoryItemsTab) then
            buttonData.__isDsRInventoryItemsRehookedTab = true
            buttonData.callback = HandleTabSwitch
        end
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function HasDsRInventoryTabButtonPlayerInventory()    
    local buttons = ZO_PlayerInventoryTabs.m_object.m_buttons
    for k,v in pairs(buttons) do
        if v[1].m_object.m_buttonData.__isDsRInventoryItemsTab then 
            return true
        end
    end
    return false
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function CreateFilterDsRInventory(inventoryType)
    local filterData = ZO_ItemFilterUtils.GetItemTypeDisplayCategoryFilterDisplayInfo(ITEM_TYPE_DISPLAY_CATEGORY_ALL)

    DsRInventoryButton.originalTabNameAll = filterData.filterString

    return {
        __isDsRInventoryItemsTab = true,
        
        -- Custom data
        filterType      = filterData.filterType,
        inventoryType   = inventoryType,
        isSubFilter     = false,
        hiddenColumns   = filterData.hideColumnTable,
        activeTabText   = DsRInventoryButton.tabNameDsRInventory,
        tooltipText     = DsRInventoryButton.tabNameDsRInventory,

        -- Menu bar data
        hidden              = filterData.hideTabFunction,
        ignoreVisibleCheck  = filterData.hideTabFunction == true,
        descriptor          = filterData.filterType,
        normal              = DsRIcon,
        pressed             = "/DsRGuildHall/misc/DsR_normal_activ.dds",
        highlight           = DsRIcon,
        callback            = HandleTabSwitch,
    }
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function MenuBarMoveButtonToRight(menuBar)
    local button = table.remove(menuBar.m_object.m_buttons)
    table.insert(menuBar.m_object.m_buttons, 1, button)
    menuBar.m_object:UpdateButtons()
end
    
-------------------------------------------------------------------------------------------------------------------------------------------------
local function AddDsRInventoryTabButton(menuBar, inventoryType)
    local buttonData = CreateFilterDsRInventory(inventoryType)
    local button = ZO_MenuBar_AddButton(menuBar, buttonData)
    if DsRInventoryButton.buttonOnRight then
        MenuBarMoveButtonToRight(menuBar)
    end
    return button
end
   
-------------------------------------------------------------------------------------------------------------------------------------------------     
if DsRInventoryButton.enableDsRInventoryTab then
    -- Setup bank and house storage tab controls here, as this needs to be done only once.
    RehookTabButtons(ZO_PlayerBankTabs.m_object.m_buttons)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function RemoveDsRInventoryTabButtonPlayerInventory()
    ZO_PlayerInventoryTabs.m_object:UpdateButtons()
end
local function InitializePlayerInventory()
    if DsRInventoryButton.DsRInventoryTabVisible then
        if not HasDsRInventoryTabButtonPlayerInventory() then
            RehookTabButtons(ZO_PlayerInventoryTabs.m_object.m_buttons)
            DsRInventoryButton.controlDsRInventoryButton = AddDsRInventoryTabButton(ZO_PlayerInventoryTabs, INVENTORY_BACKPACK)
        end
    else
        RemoveDsRInventoryTabButtonPlayerInventory()
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function fragmentChange(oldState, newState)

    if (newState == SCENE_FRAGMENT_SHOWN) then
        DsRInventoryButton.isInFragment     = SCENE_MANAGER:IsShowing("inventory")
        DsRInventoryButton.DsRInventoryTabVisible = DsRInventoryButton.enableDsRInventoryTab and DsRInventoryButton.isInFragment
    elseif (newState == SCENE_FRAGMENT_HIDDEN) then
        DsRInventoryButton.isInFragment     = false
        DsRInventoryButton.DsRInventoryTabVisible = false
        DsRInventoryButton.subFilter        = ITEM_TYPE_DISPLAY_CATEGORY_ALL
    end
    InitializePlayerInventory()
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- ON ADDON LAODED
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRInventoryButton.OnAddonLoaded(event, name)
    AddSubfilterButtonsToInventory(INVENTORY_BACKPACK)

    zo_callLater(function() 
        d("|c9fb6cd[DsR-Personal]|r |c00ff00" .. GetString(DsRGuildPrice_Loaded) .. "|r")
    end, 5000)
    
    INVENTORY_FRAGMENT:RegisterCallback("StateChange", fragmentChange)
 
    EVENT_MANAGER:UnregisterForEvent(DsRInventoryButton.name, EVENT_ADD_ON_LOADED)
end 