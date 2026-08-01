local cbe     = CraftBagExtended
local class   = cbe.classes
class.Utility = ZO_Object:Subclass()
local util    = class.Utility
local debug   = false
function util:New(...)
    self.name = cbe.name .. "Utility"
    self.transferQueueCache = {}
    return ZO_Object.New(self)
end
cbe.utility = util:New()

local function CreateButtonData(menuBar, descriptor, tabIconCategory, callback)
    local iconTemplate = "EsoUI/Art/Inventory/inventory_tabIcon_<<1>>_<<2>>.dds"
    return {
        normal = zo_strformat(iconTemplate, tabIconCategory, "up"),
        pressed = zo_strformat(iconTemplate, tabIconCategory, "down"),
        highlight = zo_strformat(iconTemplate, tabIconCategory, "over"),
        descriptor = descriptor,
        categoryName = descriptor,
        callback = callback,
        menu = menuBar
    }
end

local function GetCraftBagStatusIcon()
    if SHARED_INVENTORY and SHARED_INVENTORY:AreAnyItemsNew(nil, nil, BAG_VIRTUAL) then
        return ZO_KEYBOARD_NEW_ICON
    end
    return nil
end

local function GetCraftBagTooltip(...)
    return ZO_InventoryMenuBar:LayoutCraftBagTooltip(...)
end

--[[ Adds a craft bag button to the given menu bar with callback as the click handler ]]
function util.AddCraftBagButton(menuBar, callback)
    local buttonData = CreateButtonData(menuBar, SI_INVENTORY_MODE_CRAFT_BAG, "Craftbag", callback)
    buttonData.CustomTooltipFunction = GetCraftBagTooltip
    buttonData.statusIcon = GetCraftBagStatusIcon
    local button = ZO_MenuBar_AddButton(menuBar, buttonData)
    return button
end

--[[ Adds an inventory items button to the given menu bar with callback as the click handler ]]
function util.AddItemsButton(menuBar, callback)
    local buttonData = CreateButtonData(menuBar, SI_INVENTORY_MODE_ITEMS, "items", callback)
    local button = ZO_MenuBar_AddButton(menuBar, buttonData)
    return button
end

function util.Contains(table, value)
    for _, existingValue in ipairs(table) do
        if existingValue == value then
            return true
        end
    end
end

--[[ Outputs formatted message to chat window if debugging is turned on ]]
function util.Debug(input, scopeDebug)
    if not cbe.debug and not scopeDebug then return end
    local output = zo_strformat("<<1>>|cFFFFFF: <<2>>|r", cbe.title, input)
    d(output)
end

--[[ Outputs a string without spaces describing the given inventory bag.  
     Used for naming instances related to certain bags. ]]
function util.GetBagName(bag)
    if not bag then
        return ""
    end
    util.Debug("util.GetBagName("..tostring(bag)..")", debug)
    if bag == BAG_WORN then
        return GetString(SI_CHARACTER_EQUIP_TITLE)
    elseif bag == BAG_BACKPACK then
        return GetString(SI_GAMEPAD_INVENTORY_CATEGORY_HEADER)
    elseif bag == BAG_BANK then 
        return GetString(SI_GAMEPAD_BANK_CATEGORY_HEADER)
    elseif bag >= BAG_HOUSE_BANK_ONE and bag <= BAG_HOUSE_BANK_TEN then
        local nickname = util.GetHouseBankNickname(bag)
        if nickname then
            return string.gsub(nickname, " ", "")
        end
        local houseBankIndex = bag - BAG_HOUSE_BANK_ONE + 1
        return string.gsub(GetString(SI_COLLECTIBLECATEGORYTYPE25), " ", "") .. zo_strformat("<<N:1>>", houseBankIndex)
    elseif bag == BAG_SUBSCRIBER_BANK then
        return string.gsub(GetString(SI_NOTIFICATIONTYPE18)..GetString(SI_GAMEPAD_BANK_CATEGORY_HEADER), " ", "")
    elseif bag == BAG_GUILDBANK then 
        return string.gsub(GetString(SI_GAMEPAD_GUILD_BANK_CATEGORY_HEADER), " ", "")
    elseif bag == BAG_BUYBACK then 
        return string.gsub(GetString(SI_STORE_MODE_BUY_BACK), " ", "")
    elseif bag == BAG_VIRTUAL then
        return string.gsub(GetString(SI_GAMEPAD_INVENTORY_CRAFT_BAG_HEADER), " ", "")
    else
        return ""
    end
end

function util.GetHouseBankNickname(bag)
    if bag < BAG_HOUSE_BANK_ONE or bag > BAG_HOUSE_BANK_TEN then
        return
    end
    local collectibleId = GetCollectibleForHouseBankBag(bag)
    if collectibleId == 0 then
        return
    end
    local collectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(collectibleId)
    if not collectibleData then
        return
    end
    local nickname = collectibleData:GetNickname()
    if nickname and nickname ~= "" then
        return nickname
    end
end

--[[ Gets the "inventory slot", which is to say the button control for a slot ]]
function util.GetInventorySlot(bag, slotIndex)
    local slot = SHARED_INVENTORY:GenerateSingleSlotData(bag, slotIndex)
    if slot and slot.slotControl then
        return slot.slotControl:GetNamedChild("Button")
    end
end

--[[ Gets the config table for the "Retrieve" from craft bag dialog. ]]
function util.GetRetrieveDialogInfo()
    local transferDialogInfoIndex
    if IsInGamepadPreferredMode() then
        transferDialogInfoIndex = "ITEM_TRANSFER_REMOVE_FROM_CRAFT_BAG_GAMEPAD"
    else
        transferDialogInfoIndex = "ITEM_TRANSFER_REMOVE_FROM_CRAFT_BAG_KEYBOARD"
    end
    return ESO_Dialogs[transferDialogInfoIndex]
end

function util.GetSingleton(class, ...)
    local name = class.GetName(...)
    local instance = cbe.singletons[name]
    if not instance then
        instance = class:New(...)
        instance.name = name
        cbe.singletons[name] = instance
    end
    return instance
end

function util.GetSlotsAvailable(inventoryType)
    
    local size
    
    if inventoryType == INVENTORY_BACKPACK then
        size = GetNumBagFreeSlots(BAG_BACKPACK) 
               - util.GetSingleton(class.EmptySlotTracker, BAG_BACKPACK):GetReservedSlotCount()
    
    elseif inventoryType == INVENTORY_GUILD_BANK then
        size = GetNumBagFreeSlots(BAG_GUILDBANK) 
               - util.GetTransferQueue( BAG_BACKPACK, BAG_GUILDBANK ).itemCount 
               - util.GetTransferQueue( BAG_VIRTUAL, BAG_BACKPACK ).itemCount
    
    elseif inventoryType == INVENTORY_BANK then
        size = GetNumBagFreeSlots(BAG_BANK) 
               - util.GetTransferQueue( BAG_BACKPACK, BAG_BANK ).itemCount
               - util.GetTransferQueue( BAG_VIRTUAL, BAG_BACKPACK ).itemCount
        if GetBagUseableSize(BAG_SUBSCRIBER_BANK) > 0 then
            size = size + GetNumBagFreeSlots(BAG_SUBSCRIBER_BANK) 
                   - util.GetTransferQueue( BAG_BACKPACK, BAG_SUBSCRIBER_BANK ).itemCount
        end
        
    elseif inventoryType == INVENTORY_HOUSE_BANK then
        local bankingBag = GetBankingBag()
        size = GetNumBagFreeSlots(bankingBag) 
               - util.GetTransferQueue( BAG_BACKPACK, bankingBag ).itemCount
               - util.GetTransferQueue( BAG_VIRTUAL, BAG_BACKPACK ).itemCount
    end
    
    if size then
        return math.max(0, size)
    end
end

--[[ Gets the config table for the "Stow" from craft bag dialog. ]]
function util.GetStowDialogInfo()
    local transferDialogInfoIndex
    if IsInGamepadPreferredMode() then
        transferDialogInfoIndex = "ITEM_TRANSFER_ADD_TO_CRAFT_BAG_GAMEPAD"
    else
        transferDialogInfoIndex = "ITEM_TRANSFER_ADD_TO_CRAFT_BAG_KEYBOARD"
    end
    return ESO_Dialogs[transferDialogInfoIndex]
end

--[[ Searches all available cached transfer queues for an item that is queued
     up for transfer to the given bag. If found, dequeues the transfer item and 
     returns it and the source bag it was transferred from. ]]
function util.GetTransferItem(bag, slotIndex, quantity)
    local self = cbe.utility
    if not self.transferQueueCache[bag] then return end
    for sourceBag, queue in pairs(self.transferQueueCache[bag]) do
        local transferItem = queue:Dequeue( bag, slotIndex, quantity )
        if transferItem then
            return transferItem, sourceBag
        end
    end
end

function util.GetTransferItemScope(sourceBag, targetBag)
    local scope
    if SCENE_MANAGER.currentScene then
        scope = SCENE_MANAGER.currentScene.name
    else
        scope = "default"
    end
    if targetBag == BAG_VIRTUAL then
        scope = scope .. "Stow"
    elseif sourceBag == BAG_BANK or sourceBag == BAG_SUBSCRIBER_BANK then
        scope = scope .. "Withdraw"
    else
        scope = scope .. "Retrieve"
    end
    return scope
end

--[[ Returns a lazy-loaded, cached transfer queue given a source 
     and a destination bag id. ]]
function util.GetTransferQueue(sourceBag, destinationBag)
    
    local self = cbe.utility
    if not self.transferQueueCache[destinationBag] then
        self.transferQueueCache[destinationBag] = {}
    end
    if not self.transferQueueCache[destinationBag][sourceBag] then
        local queueName = class.TransferQueue.GetName(sourceBag, destinationBag)
        self.transferQueueCache[destinationBag][sourceBag] = 
            class.TransferQueue:New(queueName, sourceBag, destinationBag)
    end
    return self.transferQueueCache[destinationBag][sourceBag]
end

function util.IndexOf(lookupTable, value)
    if not lookupTable then return end
    for i=1,#lookupTable do
        if lookupTable[i] == value then
            return i
        end
    end 
end

function util.IsFromCraftBag(bagId, slotIndex)
    local inventoryType = PLAYER_INVENTORY.bagToInventoryType[bagId]
    local slots = PLAYER_INVENTORY.inventories[inventoryType].slots[bagId]
    return slots[slotIndex].fromCraftBag
end

function util.IsModuleFragmentGroup(fragmentGroup)
    if not fragmentGroup then return end
    for i = 1, #fragmentGroup do
        if fragmentGroup[i] == INVENTORY_FRAGMENT then
            return true
        elseif fragmentGroup[i] == CRAFT_BAG_FRAGMENT then
            return true
        end
    end
end

--[[ Determines if an inventory slot should be protected against storing in the
     guild bank, selling or mailing. ]]
function util.IsSlotProtected(slot)
    return ( IsItemBound(slot.bagId, slot.slotIndex) 
             or slot.stolen 
             or slot.isPlayerLocked 
             or IsItemBoPAndTradeable(slot.bagId, slot.slotIndex) )
end

--[[ Handles inventory item slot update events where stackCountChange > 0. ]]
function util.OnStackArrived(bagId, slotIndex, stackSize, stackCountChange)
    
    if stackCountChange <= 0 then return end
    
    util.Debug(util.GetBagName(bagId).." slot index "..tostring(slotIndex).." quantity is now "..tostring(stackSize).." after stack count change of "..tostring(stackCountChange), debug)
    
    local transferredItem, sourceBagId = util.GetTransferItem(bagId, slotIndex, stackCountChange)
    
    -- Don't handle any update events in the craft bag. We want the backpack events.
    if not transferredItem then 
        util.Debug("No outstanding transfers found for bag "..tostring(bagId).." slot index "..tostring(slotIndex), debug)
        return 
    end
    
    -- This flag marks inventory and bank slots for return/stow actions
    if bagId ~= BAG_VIRTUAL and not transferredItem.noAutoReturn then
        SHARED_INVENTORY:GenerateSingleSlotData(bagId, slotIndex).fromCraftBag = true
    end
    
    -- Update tooltips
    util.RefreshMouseOverSlot()
    
    -- Perform any configured callbacks
    transferredItem:ExecuteCallback(slotIndex)
end

function util.OnStackChanged(bagId, slotIndex, stackSize, stackCountChange)
    if stackCountChange > 0 then
        util.OnStackArrived(bagId, slotIndex, stackSize, stackCountChange)
    else
        util.OnStackRemoved(bagId, slotIndex, stackSize, stackCountChange)
    end
end

--[[ Handles inventory item slot update events where stackCountChange < 0 ]]
function util.OnStackRemoved(bagId, slotIndex, stackSize, stackCountChange)
    
    if stackCountChange >= 0 then return end
    
    util.Debug(util.GetBagName(bagId).." slot index "..tostring(slotIndex).." quantity is now "..tostring(stackSize).." after stack count change of "..tostring(stackCountChange), debug)
    
    -- Try marking returned/stowed items as in-transit first
    if util.transferQueueCache[BAG_VIRTUAL] and util.transferQueueCache[BAG_VIRTUAL][bagId] then
        if util.transferQueueCache[BAG_VIRTUAL][bagId]:TryMarkInTransitItem(bagId, slotIndex, -stackCountChange) then
            return
        end
    end
    
    -- Next, try marking any items queued for transfer to any other bags
    for targetBagId, transferQueueList in pairs(util.transferQueueCache) do
        if targetBagId ~= BAG_VIRTUAL and transferQueueList[bagId] then
            if transferQueueList[bagId]:TryMarkInTransitItem(bagId, slotIndex, -stackCountChange) then
                return
            end
        end
    end
end

--[[ Similar to ZO_PreHook, but works with functions that return a value. 
     The original function will only be called if the hookFunction returns nil. ]]
function util.PreHookReturn(objectTable, existingFunctionName, hookFunction)
    if(type(objectTable) == "string") then
        hookFunction = existingFunctionName
        existingFunctionName = objectTable
        objectTable = _G
    end
     
    local existingFn = objectTable[existingFunctionName]
    if((existingFn ~= nil) and (type(existingFn) == "function"))
    then    
        local newFn =   function(...)
                            local hookReturn = hookFunction(...)
                            if(hookReturn ~= nil) then
                                return hookReturn
                            end
                            return existingFn(...)
                        end

        objectTable[existingFunctionName] = newFn
    end
end
    
--[[ Similar to ZO_PreHook, but works for callback functions, even if none
     is yet defined.  Since this is for callbacks, objectTable is required. ]]
function util.PreHookCallback(objectTable, existingFunctionName, hookFunction)
    local existingFn = objectTable[existingFunctionName]

    local newFn =   function(...)
                        if(not hookFunction(...) 
                           and existingFn ~= nil 
                           and type(existingFn) == "function") 
                        then
                            existingFn(...)
                        end
                    end
    objectTable[existingFunctionName] = newFn
    
end

--[[ Refreshes current item tooltip and keybind strip with latest bag / bank quantities and actions ]]
function util.RefreshMouseOverSlot()
    local mouseOverControl = WINDOW_MANAGER:GetMouseOverControl()
    if not mouseOverControl then return end
    local inventorySlot
    if type(mouseOverControl.slotType) == "number" then
        inventorySlot = mouseOverControl
    elseif mouseOverControl.slotControlType == "listSlot" then
        inventorySlot = mouseOverControl:GetNamedChild("Button")
    else
        return
    end
    util.Debug("Refreshing mouseover inventory slot", debug)
    ZO_InventorySlot_OnMouseExit(inventorySlot)
    ZO_InventorySlot_OnMouseEnter(inventorySlot)
end

local slotUpdateEventHandlers = { }
local function ExecuteSlotUpdateHandler(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, updateReason, stackCountChange) 
    if stackCountChange == 0 then
        return
    end
    local handler = slotUpdateEventHandlers[bagId]
    if not handler then 
        return
    end
    local stackSize = GetSlotStackSize(bagId, slotIndex)
    handler(bagId, slotIndex, stackSize, stackCountChange)
end
function util.RegisterSlotUpdateEventHandler(bagId, handler)
    util.Debug("Registering slot update event handler for "..util.GetBagName(bagId).." bag with "..tostring(handler), debug)
    if slotUpdateEventHandlers[bagId] then
        util.Debug(util.GetBagName(bagId).." already has a slot update handler. Skipping duplicate registration.", debug)
        return
    elseif type(handler) ~= "function" then
        util.Debug("Slot update event handler "..tostring(handler).." for "..util.GetBagName(bagId).." bag could not be registered because it is of type "..type(handler)..".", debug)
    else
        slotUpdateEventHandlers[bagId] = handler
    end
    local name = cbe.name .. util.GetBagName(bagId) .. "SlotUpdateEventHandler"
    -- Listen for bag slot update events so that we can tell when empty slots open up or fill up
    EVENT_MANAGER:RegisterForEvent(name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ExecuteSlotUpdateHandler)
    EVENT_MANAGER:AddFilterForEvent(name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, bagId)
    EVENT_MANAGER:AddFilterForEvent(name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
    EVENT_MANAGER:AddFilterForEvent(name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_IS_NEW_ITEM, false)
end

function util.RemoveValue(removeFromTable, value)
    local removeAtIndex = util.IndexOf(removeFromTable, value)
    if removeAtIndex then
        table.remove(removeFromTable, removeAtIndex)
        return removeAtIndex
    end
end

--[[ Moves a given quantity from the given craft bag inventory slot index into 
     the backpack without a dialog prompt.  
     If quantity is nil, then the max stack is moved. If a callback function 
     is specified, it will be called when the mats arrive in the backpack. ]]
function util.Retrieve(slotIndex, quantity, callback, ...)
    return util.TransferItemToBag(BAG_VIRTUAL, slotIndex, BAG_BACKPACK, quantity, callback, ...)
end

--[[ Moves a given quantity from the given backpack inventory slot index into 
     the craft bag without a dialog prompt.  
     If quantity is nil, then the whole stack is moved. If a callback function 
     is specified, it will be called when the mats arrive in the craft bag. ]]
function util.Stow(slotIndex, quantity, callback, ...)
    return util.TransferItemToBag(BAG_BACKPACK, slotIndex, BAG_VIRTUAL, quantity, callback, ...)
end

--[[ Opens the "Retrieve" or "Stow" transfer dialog with a custom action name for
     the transfer button.  Automatically runs a given callback once the transfer
     is complete, if specified. ]]
function util.TransferDialog(bag, slotIndex, targetBag, dialogTitle, buttonText, callback, ...)
    
    -- Validate that the transfer is legit
    local transferDialogInfo
    if targetBag == BAG_BACKPACK or targetBag == BAG_BANK then
        transferDialogInfo = util.GetRetrieveDialogInfo()
    elseif bag == BAG_BACKPACK and targetBag == BAG_VIRTUAL then
        transferDialogInfo = util.GetStowDialogInfo()
    else
        return false
    end
    
    local transferQueue = util.GetTransferQueue( bag, targetBag )
    local transferItem = 
        transferQueue:Enqueue(
            slotIndex, 
            cbe.constants.QUANTITY_UNSPECIFIED, 
            callback,
            ...
        )
    if not transferItem then 
        return false
    end
    
    -- Get the transfer dialog
    local transferDialog = SYSTEMS:GetObject("ItemTransferDialog")
    
    -- Create default checkbox for keyboard mode
    if transferDialog.dialogControl and not transferDialog.checkboxControl then
        local checkbox = WINDOW_MANAGER:CreateControlFromVirtual(
            transferDialog.dialogControl:GetName()..cbe.name.."CheckButton", 
            transferDialog.dialogControl, 
            "ZO_CheckButton")
        checkbox:SetAnchor(LEFT, transferDialog.spinner.control, RIGHT, 32, 0)
        ZO_CheckButton_SetLabelText(checkbox, GetString(SI_AUDIOSPEAKERCONFIGURATIONS0)) -- "Default"
        transferDialog.checkboxControl = checkbox
    end
    
    -- Do not remove. Used by the dialog finished hooks to properly set the
    -- stack quantity.
    cbe.transferDialogItem = transferItem
    
    -- Override the text of the transfer dialog's title and/or button
    if dialogTitle then
        transferDialogInfo.title.text = dialogTitle
    end
    if buttonText then
        transferDialogInfo.buttons[1].text = buttonText
    end
    
    -- Open the transfer dialog
    cbe.transferDialogCanceled = false
    transferDialog:StartTransfer(bag, slotIndex, transferItem.targetBag)
    
    return transferItem
end

--[[ Moves a given quantity from the given craft bag inventory slot index into 
     the given bag without a dialog prompt.  
     If quantity is nil, then the max stack is moved. If a callback function 
     is specified, it will be called when the mats arrive in the target bag. ]]
function util.TransferItemToBag(bag, slotIndex, targetBag, quantity, callback, ...)
    
    -- Queue up the transfer
    local transferQueue = util.GetTransferQueue(bag, targetBag)
    local transferItem = transferQueue:Enqueue(slotIndex, quantity, callback, ...)
    if not transferItem then
        return
    end
    if not quantity then
        quantity = transferItem.quantity
    end
    
    util.Debug("Moving "..tostring(quantity).."x "..transferItem.itemLink.." from "
               ..util.GetBagName(bag).." slotIndex "..tostring(slotIndex)
               .." to "..util.GetBagName(transferItem.targetBag)
               .." slotIndex "..tostring(transferItem.targetSlotIndex), debug)
    
    -- Initiate the stack move to the target bag
    if IsProtectedFunction("RequestMoveItem") then
        CallSecureProtected("RequestMoveItem", bag, slotIndex, 
                            transferItem.targetBag, transferItem.targetSlotIndex, quantity)
    else
        RequestMoveItem(bag, slotIndex, 
                        transferItem.targetBag, transferItem.targetSlotIndex, quantity)
    end
    
    return transferItem
end

function util.UnregisterSlotUpdateEventHandler(bagId)
    util.Debug("Unregistering slot update event handler for "..util.GetBagName(bagId).." bag", debug)
    if not slotUpdateEventHandlers[bagId] then
        util.Debug(util.GetBagName(bagId).." has no existing slot update handler.", debug)
        return
    else
        slotUpdateEventHandlers[bagId] = nil
    end
    local name = cbe.name .. util.GetBagName(bagId) .. "SlotUpdateEventHandler"
    -- Stop listening for bag slot update events
    EVENT_MANAGER:UnregisterForEvent(name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
end

--[[ Combines two functions into a single function, with type checking. ]]
function util.WrapFunctions(function1, function2)
    if type(function1) == "function" then
        if type(function2) == "function" then
            return function(...)
                       function1(...)
                       function2(...)
                   end
        else
            return function1
        end
    else
        return function2
    end
end