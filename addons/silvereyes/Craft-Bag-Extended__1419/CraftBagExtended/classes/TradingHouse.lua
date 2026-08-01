local cbe       = CraftBagExtended
local util      = cbe.utility
local class     = cbe.classes
local name      = cbe.name .. "TradingHouse"
local debug     = false
class.TradingHouse = class.Module:Subclass()

function class.TradingHouse:New(...)

    -- Do not initialize GUI or wire up any hooks if AGS is running
    if AwesomeGuildStore then
        return class.Module.New(self, name, "tradinghouse")
    end

    -- Make sure that the trading house UI is initialized so that we can hook
    -- its tab buttons.
    if TRADING_HOUSE.control then -- Update 21+
        if not TRADING_HOUSE.initialized then
            TRADING_HOUSE:RunInitialSetup(TRADING_HOUSE.control)
            TRADING_HOUSE.initialized = true
        end
    elseif TRADING_HOUSE.m_control then -- Update 20-
        if not TRADING_HOUSE.m_initialized then
            TRADING_HOUSE:RunInitialSetup(TRADING_HOUSE.m_control)
            TRADING_HOUSE.m_initialized = true
        end
    end

    local instance = class.Module.New(self, 
        name, "tradinghouse", 
        ZO_TradingHouse, BACKPACK_TRADING_HOUSE_LAYOUT_FRAGMENT, true)
    instance:Setup()
    
    return instance
end

--[[ Whenever a new item is added to the pending sale, check to see if it is 
     replacing an item transferred by CBE from the craft bag.  If it is, 
     return the existing item back to the craft bag. ]]
local function OnPendingItemUpdate(eventCode, slotIndex, isPending)

    -- If a new pending item was just added
    if isPending then

        -- Check to see if there was an existing pending item from the craft bag
        if cbe.pendingItemFromCraftBag and slotIndex ~= cbe.pendingItemFromCraftBag then
            -- If so, return it to the craft bag
            cbe:Stow(cbe.pendingItemFromCraftBag)
        end
        
        -- If the new pending item is from the craft bag, track it
        local slotData = SHARED_INVENTORY:GenerateSingleSlotData(BAG_BACKPACK, slotIndex)
        if slotData.fromCraftBag then
            cbe.pendingItemFromCraftBag = slotIndex
            
        -- Or just forget the previous pending craft bag item, if any
        else
            cbe.pendingItemFromCraftBag = nil
        end
        
        local transferQueue = util.GetTransferQueue(BAG_VIRTUAL, BAG_BACKPACK)
        local transferItem = transferQueue:Dequeue(slotIndex)
        if transferItem then
            transferItem:ExecuteCallback(slotIndex)
        end
    
    -- The pending item was just removed
    elseif cbe.pendingItemFromCraftBag then
        local slotIndex = cbe.pendingItemFromCraftBag
        cbe.pendingItemFromCraftBag = nil
        
        -- Get the new transfer queue and queued item details
        local transferQueue = util.GetTransferQueue(BAG_BACKPACK, BAG_VIRTUAL)        
        local quantity = GetSlotStackSize(BAG_BACKPACK, slotIndex)
        local transferItem = transferQueue:Dequeue(BAG_BACKPACK, slotIndex, quantity)
        
        -- Run any callbacks
        local callback
        if transferItem then
            transferItem:ExecuteCallback(slotIndex)
            callback = transferItem.callback
        end
        
        -- Transfer mats back to craft bag
        cbe:Stow(slotIndex, quantity, callback)
    end
end

local function OnSetCurrentMode(tradingHouseManager, mode)
    local self = tradingHouseManager.craftBagExtendedModule
    if not self then return end
    if self.originalSetCurrentMode and type(self.originalSetCurrentMode) == "function" then
        self.originalSetCurrentMode(tradingHouseManager, mode)
    end
    
    if tradingHouseManager:IsInSellMode() then
        self.menu:SetHidden(false)
    else
        self.menu:SetHidden(true)
        if not self.fragmentGroup then
            SCENE_MANAGER:RemoveFragment(CRAFT_BAG_FRAGMENT)
        end
    end
end


function class.TradingHouse:Setup()
    
    -- Anchor the craft bag tab switch menu just above and to the left of the
    -- inventory listings.
    self.menu:SetAnchor(TOPRIGHT, ZO_TradingHouse, TOPLEFT, 
        ZO_TradingHouse:GetWidth() - ZO_PlayerInventory:GetWidth() - 31, 19)
    
    -- Listen for pending slot updates so that we can return any crafting
    -- mats that were previously pending back to the craft bag.
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_TRADING_HOUSE_PENDING_ITEM_UPDATE, OnPendingItemUpdate)
    
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, util.RefreshMouseOverSlot)
    
    TRADING_HOUSE.craftBagExtendedModule = self
    
    -- Move guild switcher keybind to leftmost keybind strip to allow room for the new
    -- Search for Item keybind.
    if TRADING_HOUSE_SEARCH then
        TRADING_HOUSE.sellKeybindStripDescriptor.alignment = KEYBIND_STRIP_ALIGN_LEFT
    end
    
    -- Listen for mode changes / tab changes to know when to show/hide our craft bag toggle menu
    self.originalSetCurrentMode = TRADING_HOUSE.SetCurrentMode
    TRADING_HOUSE.SetCurrentMode = OnSetCurrentMode
end

local function IsItemAlreadyBeingPosted(inventorySlot)
    local postedBag, postedSlot, postedQuantity = GetPendingItemPost()
    if ZO_InventorySlot_GetType(inventorySlot) == SLOT_TYPE_TRADING_HOUSE_POST_ITEM then
        return postedQuantity > 0
    end

    local bag, slot = ZO_Inventory_GetBagAndIndex(inventorySlot)
    return postedQuantity > 0 and bag == postedBag and slot == postedSlot
end

local function TryInitiatingItemPost(slotIndex)
    local _, stackCount = GetItemInfo(BAG_BACKPACK, slotIndex)
    if(stackCount <= 0) then return end
    
    if (IsItemStolen(BAG_BACKPACK, slotIndex)) then
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, GetString(SI_STOLEN_ITEM_CANNOT_LIST_MESSAGE))
        return
    end
    SetPendingItemPost(BAG_BACKPACK, slotIndex, stackCount)
end

--[[ Called when the requested stack arrives in the backpack and is ready for
     to be attached. ]]
local function RetrieveCallback(transferItem)
    
    util.Debug("Initiating item post for "..tostring(transferItem.itemLink))
    
    -- Requeue the transfer data so that it is available for the pending
    -- item update event.
    transferItem:Requeue()
    
    -- Perform the deposit
    TryInitiatingItemPost(transferItem.targetSlotIndex)
end

--[[ Checks to ensure that there is a free inventory slot available in the
     backpack. If there is, returns true.  If not, an 
     alert is raised and returns false. ]]
local function ValidateCanList(bag, slotIndex)
    if bag ~= BAG_VIRTUAL or AwesomeGuildStore then return false end
    
    -- Don't transfer if you don't have a free proxy slot in your backpack
    if util.GetSlotsAvailable(INVENTORY_BACKPACK) < 1 then
        ZO_AlertEvent(EVENT_INVENTORY_IS_FULL, 1, 0)
        return false
    end
    
    if (IsItemStolen(bag, slotIndex)) then
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, GetString(SI_STOLEN_ITEM_CANNOT_LIST_MESSAGE))
        return false
    end
    
    return true
end       

--[[ Adds guild store sell tab-specific inventory slot crafting bag actions ]]
function class.TradingHouse:AddSlotActions(slotInfo)

    -- Don't add keybinds if AGS is enabled or if the trade house is closed.
    if AwesomeGuildStore or GetInteractionType() ~= INTERACTION_TRADINGHOUSE then
        return
    end
    
    local slotIndex = slotInfo.slotIndex
    if IsItemAlreadyBeingPosted(slotInfo.inventorySlot) then
        if slotInfo.bag == BAG_BACKPACK then
          
            if slotInfo.fromCraftBag then
            
                --[[ Remove from Listing ]]
                table.insert(slotInfo.slotActions, {
                    SI_TRADING_HOUSE_REMOVE_PENDING_POST, 
                    function() cbe:TradingHouseRemoveFromListing(slotIndex) end, 
                    "primary"
                })
              
            end
          
            --[[ Nil stow action ]]
            table.insert(slotInfo.slotActions, {
                SI_ITEM_ACTION_ADD_ITEMS_TO_CRAFT_BAG, 
                function() end, 
                "hidden",
                nil,
                "silent"
            })
        end
    elseif slotInfo.bag == BAG_VIRTUAL then
        --[[ Add to Listing ]]
        table.insert(slotInfo.slotActions, {
            SI_TRADING_HOUSE_ADD_ITEM_TO_LISTING, 
            function() cbe:TradingHouseAddToListing(slotIndex) end, 
            "primary"
        })
        --[[ Add Quantity ]]
        table.insert(slotInfo.slotActions, {
            SI_CBE_CRAFTBAG_TRADE_ADD, 
            function() cbe:TradingHouseAddToListingDialog(slotIndex) end, 
            "keybind4"
        })
        --[[ Search in Store ]]
        if TRADING_HOUSE_SEARCH then
          table.insert(slotInfo.slotActions, {
              SI_TRADING_HOUSE_SEARCH_FROM_ITEM, 
              function() cbe:TradingHouseSearch(slotIndex) end, 
              "keybind3"
          })
        end
    end    
end

--[[ If Awesome Guild Store is not running, retrieves a given quantity of mats 
     from a given craft bag slot index, and then automatically adds them to a 
     new pending guild store sale posting and displays the backpack tab with the
     moved stack. If quantity is nil, then the max stack is deposited.
     If the backpack doesn't have at least one slot available,
     an alert is raised and no mats leave the craft bag.
     An optional callback can be raised both when the mats arrive in the backpack
     and/or after they are added to the pending listing. ]]
function class.TradingHouse:AddToListing(slotIndex, quantity, backpackCallback, addedCallback)
    if not ValidateCanList(BAG_VIRTUAL, slotIndex) then return false end
    local callback = { util.WrapFunctions(backpackCallback, RetrieveCallback) }
    table.insert(callback, addedCallback)
    return util.Retrieve(slotIndex, quantity, callback, self)
end

--[[ If Awesome Guild Store is not running, opens a retrieve dialog for a given 
     craft bag slot index, and then automatically adds the selected quantity to 
     a new pending guild store sale posting and displays the backpack tab with
     the moved stack. If the backpack doesn't have at least one slot available, 
     an alert is raised and no dialog is shown.
     An optional callback can be raised both when the mats arrive in the backpack
     and/or after they are added to the pending listing. ]]
function class.TradingHouse:AddToListingDialog(slotIndex, backpackCallback, addedCallback)
    if not ValidateCanList(BAG_VIRTUAL, slotIndex) then return false end
    local callback = { util.WrapFunctions(backpackCallback, RetrieveCallback) }
    table.insert(callback, addedCallback)
    return util.TransferDialog( 
        BAG_VIRTUAL, slotIndex, BAG_BACKPACK, SI_CBE_CRAFTBAG_TRADE_ADD,
        SI_TRADING_HOUSE_ADD_ITEM_TO_LISTING, callback, self)
end  

function class.TradingHouse:FilterSlot(inventoryManager, inventory, slot)
    if AwesomeGuildStore or self.menu:IsHidden() then return end
    
    -- Exclude protected slots
    if util.IsSlotProtected(slot) then 
        return true 
    end
end

function class.TradingHouse.PreTabButtonClicked(buttonData, playerDriven)
    if AwesomeGuildStore then return false end
    local self = buttonData.craftBagExtendedModule
    class.Module.PreTabButtonClicked(buttonData, playerDriven)
    if not self.menu:IsHidden() then
        ZO_MenuBar_SelectFirstVisibleButton(self.menu, true)
    end
end

--[[ If Awesome Guild Store is not running, removes the currently-pending stack 
     of mats from the guild store sales listing and then automatically stows 
     them in the craft bag and displays the craft bag tab.
     An optional callback can be raised both when the mats are removed from the 
     listing and/or when they arrive in the craft bag. ]]
function class.TradingHouse:RemoveFromListing(slotIndex, removedCallback, craftbagCallback)
    if AwesomeGuildStore then return false end
    local callback = { removedCallback or 1, craftbagCallback }
    local transferQueue = util.GetTransferQueue(BAG_BACKPACK, BAG_VIRTUAL)
    transferQueue:Enqueue(slotIndex, nil, callback)
    SetPendingItemPost(BAG_BACKPACK, 0, 0)
end

function class.TradingHouse:Search(slotIndex)
    if TRADING_HOUSE_SEARCH:IsAtTradingHouse() then
        local itemLink = GetItemLink(BAG_VIRTUAL, slotIndex)
        TRADING_HOUSE:SearchForItemLink(itemLink)
    end
end