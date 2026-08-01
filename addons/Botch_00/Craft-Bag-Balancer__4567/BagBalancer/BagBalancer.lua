BagBalancer = {}
BagBalancer.name = "BagBalancer"
BagBalancer.default = {
    trackedItems = {},
    hiddenItems = {},  -- Items hidden from the main list
    itemPrices = {},   -- Price tracking data
    itemStates = {},   -- Store whether items are currently over threshold
    lastCheck = 0      -- Last time we checked thresholds
}

-- Constants
local DEBOUNCE_DELAY_MS = 5000  -- 5 seconds
local pendingCheck = false

-- UI state
BagBalancer.showHiddenItems = false
BagBalancer.currentSearch = ""

local function CapitalizeWords(str)
    return str:gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
end

local function SetupScrollRow(control, data)
    -- Store itemId for reference
    control.itemId = data.itemId
    
    -- Check if item is hidden and modify display accordingly
    local isHidden = BagBalancer.savedVars.hiddenItems[data.itemId] ~= nil
    local displayName = data.name
    if isHidden and not BagBalancer.showHiddenItems then
        displayName = displayName .. " (Hidden)"
    end
    
    control:GetNamedChild("Name"):SetText(displayName)
    control:GetNamedChild("Quantity"):SetText(tostring(data.quantity))
    
    local container = control:GetNamedChild("ThresholdContainer")
    local thresholdBox = container:GetNamedChild("ThresholdBox")
    local statusLabel = control:GetNamedChild("Status")
    local sellIndicator = control:GetNamedChild("SellIndicator")
    
    -- Set the current threshold if item is tracked
    local currentThreshold = BagBalancer.savedVars.trackedItems[data.itemId]
    thresholdBox:SetText(currentThreshold or "")
    
    -- Update status label and sell indicator
    if currentThreshold then
        statusLabel:SetText("Tracked")
        statusLabel:SetColor(0, 1, 0, 1)  -- Green color
        
        -- Check if significantly over threshold (200+ over)
        if data.quantity >= (currentThreshold + 200) then
            sellIndicator:SetText("Sell")
            sellIndicator:SetColor(1, 0, 0, 1)  -- Red color
        else
            sellIndicator:SetText("")
        end
    else
        statusLabel:SetText("")
        sellIndicator:SetText("")
    end
    
    -- Store itemId for reference
    thresholdBox.itemId = data.itemId
    
    -- Set up price and change information
    local priceLabel = control:GetNamedChild("Price")
    local changeLabel = control:GetNamedChild("Change")
    
    local priceData = BagBalancer.savedVars.itemPrices[data.itemId]
    if priceData and priceData.currentPrice then
        -- Format price with commas and gold icon
        local formattedPrice = ZO_Currency_FormatPlatform(CURT_MONEY, priceData.currentPrice, ZO_CURRENCY_FORMAT_AMOUNT_ICON)
        priceLabel:SetText(formattedPrice)
        
        -- Calculate and display price change
        local changePercent, direction = BagBalancer.GetPriceChange(data.itemId)
        if changePercent then
            local changeText = ""
            local color = {1, 1, 1, 1} -- Default white
            
            if direction == "up" then
                changeText = string.format("↑%.0f%%", changePercent)
                color = {0, 1, 0, 1} -- Green for increase
            elseif direction == "down" then
                changeText = string.format("↓%.0f%%", math.abs(changePercent))
                color = {1, 0, 0, 1} -- Red for decrease
            else
                changeText = "→0%"
                color = {1, 1, 0, 1} -- Yellow for no change
            end
            
            changeLabel:SetText(changeText)
            changeLabel:SetColor(unpack(color))
        else
            changeLabel:SetText("")
        end
    else
        priceLabel:SetText("--")
        changeLabel:SetText("")
    end
    
    -- Configure the hide/unhide button based on current mode
    local hideButton = control:GetNamedChild("HideButton")
    if hideButton then
        if BagBalancer.showHiddenItems then
            -- In show hidden mode, use + button to unhide
            hideButton:SetNormalTexture("/esoui/art/buttons/plus_up.dds")
            hideButton:SetPressedTexture("/esoui/art/buttons/plus_down.dds")
            hideButton:SetMouseOverTexture("/esoui/art/buttons/plus_over.dds")
            hideButton.tooltipText = "Show this item in the main list"
        else
            -- In normal mode, use X button to hide
            hideButton:SetNormalTexture("/esoui/art/buttons/decline_up.dds")
            hideButton:SetPressedTexture("/esoui/art/buttons/decline_down.dds")
            hideButton:SetMouseOverTexture("/esoui/art/buttons/decline_over.dds")
            hideButton.tooltipText = "Hide this item from the list"
        end
    end
end

local scrollInitialized = false

local function InitializeScrollList()
    if not scrollInitialized then
        local list = BagBalancerUIScrollList
        if not list then return end
        
        ZO_ScrollList_Initialize(list)
        ZO_ScrollList_AddDataType(list, 1, "BagBalancerRow", 30, SetupScrollRow)
        ZO_ScrollList_SetTypeSelectable(list, 1, false)
        scrollInitialized = true
    end
end

local function InitializeUI()
    -- Create scene
    BagBalancer.scene = ZO_Scene:New("BagBalancerScene", SCENE_MANAGER)
    
    -- Add our UI fragment
    local fragment = ZO_FadeSceneFragment:New(BagBalancerUI)
    BagBalancer.scene:AddFragment(fragment)
    
    -- Initialize the scroll list
    InitializeScrollList()
    
    -- Initial refresh
    RefreshScrollList()
    
    -- Register scene callbacks
    BagBalancer.scene:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWING then
            RefreshScrollList()
        end
    end)

    -- Set up the scene
    BagBalancer.scene:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
    BagBalancer.scene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
end

local function GetTrackedItemQuantity(itemId)
    local quantity = 0
    local craftBag = SHARED_INVENTORY:GetOrCreateBagCache(BAG_VIRTUAL)

    for _, itemData in pairs(craftBag) do
        local slotItemId = GetItemId(BAG_VIRTUAL, itemData.slotIndex)
        if slotItemId == itemId then
            quantity = quantity + itemData.stackCount
        end
    end

    return quantity
end

function BagBalancer.UpdateThreshold(control)
    local threshold = tonumber(control:GetText())
    local itemId = control.itemId
    
    if threshold and itemId then
        if threshold > 0 then
            BagBalancer.savedVars.trackedItems[itemId] = threshold
        else
            BagBalancer.savedVars.trackedItems[itemId] = nil
        end
        RefreshScrollList()
    end
end

function BagBalancer.ToggleTracking(button)
    local itemId = button.itemId
    if button.isTracked then
        -- Untrack the item
        BagBalancer.savedVars.trackedItems[itemId] = nil
    else
        -- Get threshold from edit box
        local thresholdBox = button:GetParent():GetNamedChild("ThresholdBox")
        local threshold = tonumber(thresholdBox:GetText())
        
        if not threshold then
            d("[BagBalancer] Please enter a threshold value before tracking.")
            return
        end
        
        -- Track the item with the specified threshold
        BagBalancer.savedVars.trackedItems[itemId] = threshold
    end
    RefreshScrollList()
end

function BagBalancer.OnSearchChanged(editBox)
    BagBalancer.currentSearch = string.lower(editBox:GetText())
    RefreshScrollList()
end

local function CleanItemName(str)
    -- Remove markup tags (like ^ns)
    str = str:gsub("%^%w+", "")
    -- Capitalize words
    str = str:gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
    -- Trim any extra spaces
    return str:match("^%s*(.-)%s*$")
end

local function GetAllCraftBagItems()
    local items = {}
    local craftBag = SHARED_INVENTORY:GetOrCreateBagCache(BAG_VIRTUAL)
    
    for _, itemData in pairs(craftBag) do
        local itemId = GetItemId(BAG_VIRTUAL, itemData.slotIndex)
        local name = GetItemName(BAG_VIRTUAL, itemData.slotIndex)
        local quantity = itemData.stackCount or 0
        
        if itemId and itemId ~= 0 then
            -- Filter based on showHiddenItems mode
            local isHidden = BagBalancer.savedVars.hiddenItems[itemId] ~= nil
            local shouldShow = false
            
            if BagBalancer.showHiddenItems then
                -- In show hidden mode, only show hidden items
                shouldShow = isHidden
            else
                -- In normal mode, show all non-hidden items
                shouldShow = not isHidden
            end
            
            if shouldShow then
                -- Clean and format the item name
                name = CleanItemName(name)
                
                -- Filter by search text if exists
                if not BagBalancer.currentSearch or string.find(string.lower(name), BagBalancer.currentSearch) then
                    table.insert(items, {
                        itemId = itemId,
                        name = name,
                        quantity = quantity
                    })
                end
            end
        end
    end
    
    -- Sort by name
    table.sort(items, function(a, b) return a.name < b.name end)
    
    return items
end

function RefreshScrollList()
    InitializeScrollList()
    local scrollData = ZO_ScrollList_GetDataList(BagBalancerUIScrollList)
    ZO_ScrollList_Clear(BagBalancerUIScrollList)

    local items = GetAllCraftBagItems()
    
    for _, item in ipairs(items) do
        table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, {
            itemId = item.itemId,
            name = item.name,
            quantity = item.quantity,
        }))
    end

    ZO_ScrollList_Commit(BagBalancerUIScrollList)
end

-- Function to reset the data
function BagBalancer:ResetData()
    self.savedVars.trackedItems = {}
    self.savedVars.hiddenItems = {}
    self.savedVars.itemPrices = {}

    d("[BagBalancer] Data has been reset.")
end


function BagBalancer.ToggleUI()
    if not BagBalancer.scene or not BagBalancerUI then return end
    
    if BagBalancerUI:IsHidden() then
        RefreshScrollList()
        BagBalancerUI:SetHidden(false)
    else
        BagBalancerUI:SetHidden(true)
    end
end

function BagBalancer.ToggleHiddenItems()
    BagBalancer.showHiddenItems = not BagBalancer.showHiddenItems
    RefreshScrollList()
    
    -- Update button label
    local button = BagBalancerUI:GetNamedChild("ToggleHiddenButton")
    if button then
        local label = button:GetNamedChild("Label")
        if label then
            if BagBalancer.showHiddenItems then
                label:SetText("Back to Main")
            else
                label:SetText("Show Hidden")
            end
        end
    end
    
    d(string.format("[BagBalancer] %s hidden items", BagBalancer.showHiddenItems and "Showing" or "Hiding"))
end

function BagBalancer.ToggleItemVisibility(button)
    -- Get the row control and extract itemId from it
    local row = button:GetParent()
    local itemId = row.itemId
    
    if not itemId then
        d("[BagBalancer] Error: Could not find item ID for visibility toggle")
        return
    end
    
    -- Get item name for feedback
    local itemLink = string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)
    local itemName = CleanItemName(GetItemLinkName(itemLink))
    
    -- Toggle visibility
    if BagBalancer.savedVars.hiddenItems[itemId] then
        -- Item is currently hidden, show it
        BagBalancer.savedVars.hiddenItems[itemId] = nil
        -- Update price immediately when unhiding
        BagBalancer.UpdateItemPrice(itemId)
        d(("[BagBalancer] Now showing %s in the list"):format(itemName))
    else
        -- Item is currently visible, hide it
        BagBalancer.savedVars.hiddenItems[itemId] = true
        d(("[BagBalancer] Hidden %s from the list"):format(itemName))
    end
    
    RefreshScrollList()
end

-- Price tracking functions
function BagBalancer.GetItemPrice(itemId)
    if not LibPrice or type(LibPrice.ItemLinkToPriceGold) ~= "function" then
        return nil
    end

    -- Create an item link from the itemId so LibPrice can resolve prices
    local itemLink = string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)

    local priceInfo = nil
    local ok, result = pcall(LibPrice.ItemLinkToPriceGold, LibPrice, itemLink)
    if ok then
        priceInfo = result
    end

    if priceInfo and priceInfo > 0 then
        return priceInfo
    end

    return nil
end

function BagBalancer.UpdateItemPrice(itemId)
    local currentPrice = BagBalancer.GetItemPrice(itemId)
    if currentPrice then
        if not BagBalancer.savedVars.itemPrices[itemId] then
            BagBalancer.savedVars.itemPrices[itemId] = {}
        end
        
        -- For initial implementation, set lastPrice to 0 if not exists
        if BagBalancer.savedVars.itemPrices[itemId].lastPrice == nil then
            BagBalancer.savedVars.itemPrices[itemId].lastPrice = 0
        end
        
        BagBalancer.savedVars.itemPrices[itemId].currentPrice = currentPrice
        BagBalancer.savedVars.itemPrices[itemId].lastUpdate = GetTimeStamp()
        
        return currentPrice
    end
    return nil
end

function BagBalancer.GetPriceChange(itemId)
    local priceData = BagBalancer.savedVars.itemPrices[itemId]
    if not priceData or not priceData.currentPrice then
        return nil, nil
    end
    
    local lastPrice = priceData.lastPrice or 0
    local currentPrice = priceData.currentPrice
    
    if lastPrice == 0 then
        return 100, "up"  -- Initial case: appears as 100% increase
    end
    
    local changePercent = ((currentPrice - lastPrice) / lastPrice) * 100
    local direction = changePercent > 0 and "up" or (changePercent < 0 and "down" or "same")
    
    return changePercent, direction
end

function BagBalancer.UpdateAllPrices()
    if not LibPrice or type(LibPrice.ItemLinkToPriceGold) ~= "function" then
        d("[BagBalancer] LibPrice not found or unsupported - price tracking disabled")
        return
    end
    
    local craftBag = SHARED_INVENTORY:GetOrCreateBagCache(BAG_VIRTUAL)
    local updatedCount = 0
    
    for _, itemData in pairs(craftBag) do
        local itemId = GetItemId(BAG_VIRTUAL, itemData.slotIndex)
        
        if itemId and itemId ~= 0 then
            -- Only update prices for non-hidden items
            if not BagBalancer.savedVars.hiddenItems[itemId] then
                if BagBalancer.UpdateItemPrice(itemId) then
                    updatedCount = updatedCount + 1
                end
            end
        end
    end
    
    if updatedCount > 0 then
        d(string.format("[BagBalancer] Updated prices for %d items", updatedCount))
    end
end

function PrintCraftBagItems()
    local craftBag = SHARED_INVENTORY:GetOrCreateBagCache(BAG_VIRTUAL)
    local output = "Craft Bag Contents:\n"
    
    -- Loop through the items in the craft bag
    for _, itemData in pairs(craftBag) do
        local itemId = GetItemId(BAG_VIRTUAL, itemData.slotIndex)
        local itemName = GetItemName(BAG_VIRTUAL, itemData.slotIndex)
        local quantity = itemData.stackCount or 0

        -- Ensure the itemId is valid
        if itemId and itemId ~= 0 then
            output = output .. string.format("ID: %d, Name: %s, Quantity: %d\n", itemId, itemName, quantity)
        else
            output = output .. "Warning: Failed to get item ID for one item in craft bag.\n"
        end
    end

    -- Print the output to the chat
    d(output)
end

function BagBalancer.OnAddOnLoaded(event, addonName)
    if addonName ~= BagBalancer.name then return end

    -- Initialize saved variables first
    BagBalancer.savedVars = ZO_SavedVars:New("BagBalancerSaved", 1, nil, BagBalancer.default)

    -- Register for inventory updates
    EVENT_MANAGER:RegisterForEvent(BagBalancer.name .. "InventoryUpdate", 
        EVENT_INVENTORY_SINGLE_SLOT_UPDATE, 
        OnInventorySlotUpdate)

    local function InitializeWhenReady()
        -- Check if UI system is ready
        if not SCENE_MANAGER or not SCENE_MANAGER.scenes or not ZO_ScrollList_Initialize then
            -- Try again in a moment if not ready
            zo_callLater(InitializeWhenReady, 500)
            return
        end

        -- Wrap UI initialization in pcall to catch any errors
        local success, error = pcall(function()
            if not BagBalancer.uiInitialized then
                if not BagBalancerUI or not BagBalancerUIScrollList then
                    zo_callLater(InitializeWhenReady, 500)
                    return
                end

                InitializeUI()
                BagBalancer.uiInitialized = true
                
                -- Register slash command only after UI is initialized
                if SLASH_COMMANDS then
                    SLASH_COMMANDS["/bb"] = function(input)
                        if not BagBalancer.uiInitialized then
                            d("[BagBalancer] UI is still initializing. Please wait a moment and try again.")
                            return
                        end
                        if not SCENE_MANAGER or not SCENE_MANAGER.scenes then
                            d("[BagBalancer] Game UI is not fully loaded. Please wait a moment and try again.")
                            return
                        end
                        BagBalancer.ToggleUI()
                    end
                    d("[BagBalancer] Initialization complete. Use /bb to open the window.")
                    
                    -- Update prices for all non-hidden items
                    BagBalancer.UpdateAllPrices()
                else
                    d("[BagBalancer] Warning: Could not register slash command.")
                end
            end
        end)
        
        if not success then
            d("[BagBalancer] Error during UI initialization: " .. tostring(error))
            -- Try again once more if failed
            zo_callLater(InitializeWhenReady, 1000)
        end
    end

    -- Wait for player activation first
    EVENT_MANAGER:RegisterForEvent(BagBalancer.name, EVENT_PLAYER_ACTIVATED, function()
        -- Unregister immediately to prevent multiple initializations
        EVENT_MANAGER:UnregisterForEvent(BagBalancer.name, EVENT_PLAYER_ACTIVATED)
        -- Start the initialization process
        zo_callLater(InitializeWhenReady, 500)
    end)

    -- Register dialogs
    ZO_Dialogs_RegisterCustomDialog("BB_OVER_THRESHOLD", {
        title = { text = "BagBalancer Alert" },
        mainText = { text = function(dialog) return dialog.data.message end },
        buttons = {
            {
                text = SI_OK,
                callback = function() end
            }
        }
    })

    ZO_Dialogs_RegisterCustomDialog("BB_EDIT_THRESHOLD", {
        title = { text = "Edit Threshold" },
    
        mainText = {
            text = function(dialog)
                local name = dialog.data.itemName or "Unknown Material"
                local current = dialog.data.current or 0
                return string.format("Material: %s\nCurrent Threshold: %d\nEnter new threshold:", name, current)
            end,
        },
    
        -- Define the edit box
        editBox = {
            defaultText = "",
            maxInputChars = 4,
        },
    
        setup = function(dialog)
            -- Try to directly access the edit control by name
            local edit = dialog:GetNamedChild("EditBox")  -- Make sure this matches the ID of the edit box
            if edit then
                edit:SetText(tostring(dialog.data.current or 0))
                edit:SelectAll()
                d("[BagBalancer] Edit control setup successfully")
            else
                d("[BagBalancer] Error: Edit control not found in setup.")
            end
        end,
    
        buttons = {
            {
                text = SI_DIALOG_ACCEPT,
                callback = function(dialog)
                    -- Test if this callback is being called
                    d("[BagBalancer] Accept button clicked!")
                    if not dialog then
                        d("[BagBalancer] Error: Dialog object is nil!")
                        return
                    end
    
                    local edit = dialog:GetNamedChild("EditBox")  -- Access the edit control directly
                    if not edit then
                        d("[BagBalancer] Error: Edit control not found!")
                        return
                    end
    
                    local thresholdText = edit:GetText()
                    if not thresholdText or thresholdText == "" then
                        d("[BagBalancer] Error: Threshold text is empty!")
                        return
                    end
    
                    d("[BagBalancer] Threshold Text: " .. tostring(thresholdText))
    
                    local threshold = tonumber(thresholdText)
                    if not threshold then
                        d("[BagBalancer] Error: Invalid threshold value!")
                        return
                    end
    
                    d("[BagBalancer] Parsed Threshold: " .. tostring(threshold))
    
                    local itemId = dialog.data.itemId
                    local itemName = dialog.data.itemName
    
                    if itemId and threshold then
                        BagBalancer.savedVars.trackedItems[itemId] = threshold
                        RefreshScrollList()
                        d(string.format("[BagBalancer] Updated threshold for %s to %d", itemName or "item", threshold))
                    else
                        d("[BagBalancer] Invalid input.")
                    end
                end
            },
            {
                text = SI_DIALOG_CANCEL,
                callback = function() 
                    -- Cancel button debug
                    d("[BagBalancer] Cancel button pressed")
                end
            }
        }
    })

    -- Function to search craft bag items by name
    function BagBalancer.SearchCraftBag(searchText)
        local results = {}
        local craftBag = SHARED_INVENTORY:GetOrCreateBagCache(BAG_VIRTUAL)
        searchText = string.lower(searchText)
        
        for _, itemData in pairs(craftBag) do
            local itemId = GetItemId(BAG_VIRTUAL, itemData.slotIndex)
            local itemName = GetItemName(BAG_VIRTUAL, itemData.slotIndex)
            local quantity = itemData.stackCount or 0
            
            if itemId and itemId ~= 0 and string.find(string.lower(itemName), searchText) then
                table.insert(results, {
                    id = itemId,
                    name = itemName,
                    quantity = quantity
                })
            end
        end
        return results
    end

    -- Show all items in craft bag for selection
    function BagBalancer.ShowItemList()
        local results = BagBalancer.SearchCraftBag("")  -- Get all items
        local items = {}
        for _, item in ipairs(results) do
            table.insert(items, string.format("%s (Current: %d)", item.name, item.quantity))
        end
        
        ZO_Dialogs_ShowDialog("BB_SELECT_ITEM", {items = items, results = results})
    end

    ZO_Dialogs_RegisterCustomDialog("BB_SELECT_ITEM", {
        title = { text = "Select Item to Track" },
        mainText = { text = "Choose an item from your craft bag:" },
        
        listEntries = function(dialog)
            return dialog.data.items
        end,
        
        setupFunc = function(dialog)
            dialog.selectedIndex = nil
        end,
        
        buttons = {
            {
                text = SI_DIALOG_ACCEPT,
                callback = function(dialog)
                    if not dialog.selectedIndex then
                        d("[BagBalancer] Please select an item first.")
                        return
                    end
                    
                    local selectedItem = dialog.data.results[dialog.selectedIndex]
                    ZO_Dialogs_ShowDialog("BB_SET_THRESHOLD", {
                        itemId = selectedItem.id,
                        itemName = selectedItem.name,
                        quantity = selectedItem.quantity
                    })
                end
            },
            {
                text = SI_DIALOG_CANCEL,
            }
        },
    })

    ZO_Dialogs_RegisterCustomDialog("BB_SET_THRESHOLD", {
        title = { text = "Set Threshold" },
        mainText = {
            text = function(dialog)
                return string.format("Set threshold for %s (Current: %d):", dialog.data.itemName, dialog.data.quantity)
            end,
        },
        editBox = {
            defaultText = "3000",
            maxInputChars = 6,
        },
        buttons = {
            {
                text = SI_DIALOG_ACCEPT,
                callback = function(dialog)
                    local thresholdText = dialog:GetEditControl():GetText()
                    local threshold = tonumber(thresholdText)
                    
                    if not threshold then
                        d("[BagBalancer] Please enter a valid number for the threshold.")
                        return
                    end
                    
                    BagBalancer.savedVars.trackedItems[dialog.data.itemId] = threshold
                    RefreshScrollList()
                    d(string.format("[BagBalancer] Now tracking %s with threshold of %d", dialog.data.itemName, threshold))
                end
            },
            {
                text = SI_DIALOG_CANCEL,
            }
        },
    })

    function BagBalancer.ShowAddItemDialog()
        BagBalancer.ShowItemList()
    end

    ZO_Dialogs_RegisterCustomDialog("BB_CONFIRM_RESET", {
        title = { text = "Reset BagBalancer" },
        mainText = { text = "Are you sure you want to clear all tracked items?" },
        buttons = {
            {
                text = SI_DIALOG_ACCEPT,
                callback = function()
                    BagBalancer.savedVars.trackedItems = {}
                    RefreshScrollList()
                    d("[BagBalancer] All tracked items have been cleared.")
                end
            },
            {
                text = SI_DIALOG_CANCEL,
            }
        }
    })
    

    function BagBalancer.IsUIVisible()
        return BagBalancerUI and not BagBalancerUI:IsHidden()
    end

    ZO_PostHook("ZO_InventorySlot_ShowContextMenu", function(inventorySlot)
        local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
    
        -- Only show BagBalancer options for craft bag materials
        if bagId == BAG_VIRTUAL and slotIndex then
            local itemLink = GetItemLink(bagId, slotIndex)
            if itemLink and itemLink ~= "" then
                local itemId = GetItemLinkItemId(itemLink)
                local itemName = GetItemLinkName(itemLink)
                local isTracked = BagBalancer.savedVars.trackedItems[itemId] ~= nil
    
                -- Add BagBalancer options directly to the right-click menu

                -- Only show if there are any tracked items
                local hasTrackedItems = next(BagBalancer.savedVars.trackedItems) ~= nil
                if hasTrackedItems then
                    -- Show All Tracked Items
                    AddCustomMenuItem("Show All Tracked Items", function()
                        BagBalancer.ShowTrackedItems(false)
                    end, MENU_ADD_OPTION_LABEL)

                    -- Check if any tracked item is over its threshold
                    local craftBag = SHARED_INVENTORY:GetOrCreateBagCache(BAG_VIRTUAL)
                    local hasOverThreshold = false
                    for itemId, threshold in pairs(BagBalancer.savedVars.trackedItems) do
                        for _, itemData in pairs(craftBag) do
                            if itemData and GetItemId(BAG_VIRTUAL, itemData.slotIndex) == itemId then
                                if itemData.stackCount > threshold then
                                    hasOverThreshold = true
                                    break
                                end
                            end
                        end
                        if hasOverThreshold then break end
                    end

                    if hasOverThreshold then
                        AddCustomMenuItem("Show Over Threshold Items", function()
                            BagBalancer.ShowTrackedItems(true)
                        end, MENU_ADD_OPTION_LABEL)
                    end

                    -- Add Dismiss UI option only if the UI is currently showing
                    if not BagBalancerUI:IsHidden() then
                        AddCustomMenuItem("Dismiss UI", function()
                            -- This will hide the UI when selected
                            BagBalancerUI:SetHidden(true)
                            d("[BagBalancer] UI dismissed.")
                        end, MENU_ADD_OPTION_LABEL)
                    end
                end

                if not isTracked then
                    AddCustomMenuItem("Track with BagBalancer", function()
                        if not itemId or itemId == 0 then
                            d("[BagBalancer] Error: Cannot track item with invalid itemId.")
                            return
                        end
                
                        -- Set default threshold and open edit dialog
                        BagBalancer.savedVars.trackedItems[itemId] = 0
                        ZO_Dialogs_ShowDialog("BB_EDIT_THRESHOLD", {
                            itemId = itemId,
                            itemName = itemName,
                            current = 0,
                        })
                        d(("[BagBalancer] Now tracking %s. Set a threshold."):format(itemName))
                    end, MENU_ADD_OPTION_LABEL)
                
                else
                    AddCustomMenuItem("Edit BagBalancer Threshold", function()
                        ZO_Dialogs_ShowDialog("BB_EDIT_THRESHOLD", {
                            itemId = itemId,
                            itemName = itemName,
                            current = BagBalancer.savedVars.trackedItems[itemId],
                        })
                    end, MENU_ADD_OPTION_LABEL)
    
                    AddCustomMenuItem("Remove from BagBalancer", function()
                        BagBalancer.savedVars.trackedItems[itemId] = nil
                        RefreshScrollList()
                        d(("[BagBalancer] Stopped tracking %s"):format(itemName))
                    end, MENU_ADD_OPTION_LABEL)

                    -- Only show the "Reset BagBalancer" option if at least one item is tracked
                    local hasTrackedItems = next(BagBalancer.savedVars.trackedItems) ~= nil
                    if hasTrackedItems then
                        AddCustomMenuItem("Reset BagBalancer", function()
                            ZO_Dialogs_ShowDialog("BB_CONFIRM_RESET")
                        end, MENU_ADD_OPTION_LABEL)
                    end
                end
    
                -- Show the menu
                ShowMenu(inventorySlot)
            end
        end
    end)

    -- Add hide/unhide options for all craft bag items
    ZO_PostHook("ZO_InventorySlot_ShowContextMenu", function(inventorySlot)
        local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
        
        -- Only show BagBalancer hide/unhide options for craft bag materials
        if bagId == BAG_VIRTUAL and slotIndex then
            local itemLink = GetItemLink(bagId, slotIndex)
            if itemLink and itemLink ~= "" then
                local itemId = GetItemLinkItemId(itemLink)
                local itemName = GetItemLinkName(itemLink)
                local isHidden = BagBalancer.savedVars.hiddenItems[itemId] ~= nil
                
                if not isHidden then
                    AddCustomMenuItem("Hide from BagBalancer", function()
                        BagBalancer.savedVars.hiddenItems[itemId] = true
                        RefreshScrollList()
                        d(("[BagBalancer] Hidden %s from the list"):format(itemName))
                    end, MENU_ADD_OPTION_LABEL)
                else
                    AddCustomMenuItem("Show in BagBalancer", function()
                        BagBalancer.savedVars.hiddenItems[itemId] = nil
                        RefreshScrollList()
                        d(("[BagBalancer] Now showing %s in the list"):format(itemName))
                    end, MENU_ADD_OPTION_LABEL)
                end
                
                ShowMenu(inventorySlot)
            end
        end
    end)
end

function BagBalancer.ShowTrackedItems(onlyOverThreshold)
    if not BagBalancerUIScrollList then
        d("[BagBalancer] Error: UIScrollList is not initialized.")
        return
    end
    InitializeScrollList()

    local scrollData = ZO_ScrollList_GetDataList(BagBalancerUIScrollList)
    ZO_ScrollList_Clear(BagBalancerUIScrollList)

    local foundAny = false

    for itemId, threshold in pairs(BagBalancer.savedVars.trackedItems) do
        local quantity = GetTrackedItemQuantity(itemId)
        if (not onlyOverThreshold) or (quantity > threshold) then
            local itemLink = string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)
            local name = CleanItemName(GetItemLinkName(itemLink))

            table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, {
                itemId = itemId,
                name = name,
                threshold = threshold,
                quantity = quantity,
            }))

            foundAny = true
        end
    end

    ZO_ScrollList_Commit(BagBalancerUIScrollList)

    if foundAny then
        BagBalancerUI:SetHidden(false)
    else
        local msg = onlyOverThreshold and "No items over threshold." or "No tracked items."
        d("[BagBalancer] " .. msg)
        BagBalancerUI:SetHidden(true)
    end
end

function BagBalancer.AdjustThreshold(button, amount)
    local container = button:GetParent()
    local thresholdBox = container:GetNamedChild("ThresholdBox")
    local currentValue = tonumber(thresholdBox:GetText()) or 0
    local newValue = math.max(0, currentValue + amount)
    thresholdBox:SetText(tostring(newValue))
    BagBalancer.UpdateThreshold(thresholdBox)
end

function CheckTrackedItems()
    -- Clear the pending check flag
    pendingCheck = false
    
    local currentTime = GetGameTimeMilliseconds()
    -- If not enough time has passed since last check, schedule another check
    if (currentTime - BagBalancer.savedVars.lastCheck) < DEBOUNCE_DELAY_MS then
        return
    end
    
    local itemsNowOverThreshold = {}
    
    -- Check all tracked items
    for itemId, threshold in pairs(BagBalancer.savedVars.trackedItems) do
        local currentQty = GetTrackedItemQuantity(itemId)
        local wasOverThreshold = BagBalancer.savedVars.itemStates[itemId] or false
        local isOverThreshold = currentQty > threshold
        
        -- Alert only on transition from under to over threshold
        if isOverThreshold and not wasOverThreshold then
            -- Get item name for the alert
            local itemLink = string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)
            local name = CleanItemName(GetItemLinkName(itemLink))
            table.insert(itemsNowOverThreshold, {
                name = name,
                quantity = currentQty,
                threshold = threshold
            })
        end
        
        -- Update the state
        BagBalancer.savedVars.itemStates[itemId] = isOverThreshold
    end
    
    -- If any items newly exceeded their threshold, show alert
    if #itemsNowOverThreshold > 0 then
        local message = "The following items have exceeded their thresholds:\n"
        for _, item in ipairs(itemsNowOverThreshold) do
            message = message .. string.format("- %s: %d/%d\n", 
                item.name, item.quantity, item.threshold)
        end
        
        -- Show the alert dialog
        ZO_Dialogs_ShowDialog("BB_OVER_THRESHOLD", {message = message})
    end
    
    -- Update last check time
    BagBalancer.savedVars.lastCheck = currentTime
end

function OnInventorySlotUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
    if bagId ~= BAG_VIRTUAL then return end
    
    -- If we already have a check pending, don't schedule another
    if pendingCheck then return end
    
    -- Schedule a check
    pendingCheck = true
    zo_callLater(function()
        CheckTrackedItems()
    end, DEBOUNCE_DELAY_MS)
end

EVENT_MANAGER:RegisterForEvent(BagBalancer.name, EVENT_ADD_ON_LOADED, BagBalancer.OnAddOnLoaded)