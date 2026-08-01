local cbe  = CraftBagExtended
local util = cbe.utility
local debug = false

 --[[ Handle craft bag open/close events ]]
local function OnCraftBagFragmentStateChange(oldState, newState)
    -- On craft bag showing event, move the info bar to the craft bag
    if newState == SCENE_FRAGMENT_SHOWING then
        ZO_PlayerInventoryInfoBar:SetParent(ZO_CraftBag)
        if TweakIt and ExtendedInfoBar then
            ExtendedInfoBar:SetParent(ZO_CraftBag)
        end
    end
end

--[[ Handle player inventory open events ]]
local function OnInventoryFragmentStateChange(oldState, newState)
    -- On enter, move the info bar back to the backpack, if not there already
    if newState == SCENE_FRAGMENT_SHOWING then
        ZO_PlayerInventoryInfoBar:SetParent(ZO_PlayerInventory)
        if TweakIt and ExtendedInfoBar then
            ExtendedInfoBar:SetParent(ZO_PlayerInventory)
        end
    end
end

--[[ Runs whenever a new inventory slot action is added. Used to ammend the
     available keybinds, as well as suppress existing slot actions names that 
     would conflict with ours. ]]
local function PreAddSlotAction(slotActions, actionStringId, actionCallback, actionType, visibilityFunction, options)
   
    -- Add a keybind4 handler for the Q key
    if cbe.addingSlotActions then
        
        if actionType == "keybind4" then
            local actionName = GetString(actionStringId)
            slotActions.m_keybindActions[4] = { 
                actionName, actionCallback, "keybind", 
                visibilityFunction, options 
            }
        end
    
    -- Suppress existing slot actions that would conflict with ours.
    elseif cbe.customSlotActionDescriptors then
        for _, moduleSlotAction in ipairs(cbe.customSlotActionDescriptors) do
            if moduleSlotAction[1] == actionStringId then
                return true
            end
        end
    end
end

local function PreInventorySlotActionsGetAction(slotActions)
    if not cbe.customSlotActionDescriptors 
       or not slotActions 
       or not slotActions.m_inventorySlot 
       or slotActions.craftBagExtendedPostHooked
    then 
        return 
    end
    cbe.addingSlotActions = true
    for _, moduleSlotAction in ipairs(cbe.customSlotActionDescriptors) do
        if moduleSlotAction[3] == "secondary" then
            slotActions:AddCustomSlotAction(unpack(moduleSlotAction))
        end
    end
    cbe.addingSlotActions = nil
    slotActions.craftBagExtendedPostHooked = true
end

local function PreInventorySlotActionsClear(slotActions)
    slotActions.craftBagExtendedPostHooked = false
end

--[[ Insert our custom craft bag actions into the keybind buttons and 
     context menu whenever an item is hovered. ]]
local function PreDiscoverSlotActions(inventorySlot, slotActions) 

    if not inventorySlot then return end
    
    local slotType = ZO_InventorySlot_GetType(inventorySlot)

    local bag, slotIndex
    if slotType == SLOT_TYPE_MY_TRADE then
        local tradeIndex = ZO_Inventory_GetSlotIndex(inventorySlot)
        bag, slotIndex = GetTradeItemBagAndSlot(TRADE_ME, tradeIndex)
    else
        bag, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
    end
    
    -- We don't have any slot actions for bags other than those in BAG_TYPES
    if not cbe.constants.BAG_TYPES[bag] then
        return
    end
    
    -- fromCraftBag flag marks backpack slots for return/stow actions
    local slotData = SHARED_INVENTORY:GenerateSingleSlotData(bag, slotIndex)
    
    if not slotData then return end
    
    local fromCraftBag = slotData.fromCraftBag
    
    if fromCraftBag or cbe.constants.SLOT_TYPES[slotType] then
        
        if not slotActions.craftBagExtendedHooked then
            ZO_PreHook(slotActions, "Clear", PreInventorySlotActionsClear)
            ZO_PreHook(slotActions, "GetAction", PreInventorySlotActionsGetAction)
            ZO_PreHook(slotActions, "Show", PreInventorySlotActionsGetAction)
            slotActions.craftBagExtendedHooked = true
        end
        cbe.customSlotActionDescriptors = {}
        local slotInfo = { 
            inventorySlot = inventorySlot,
            slotType      = slotType, 
            bag           = bag,
            slotIndex     = slotIndex,
            slotData      = slotData,
            fromCraftBag  = fromCraftBag, 
            slotActions   = cbe.customSlotActionDescriptors,
        }
        for moduleName,module in pairs(cbe.modules) do
            if type(module.AddSlotActions) == "function" then
                module:AddSlotActions(slotInfo)
            end
        end
        cbe.addingSlotActions = true
        for _, moduleSlotAction in ipairs(cbe.customSlotActionDescriptors) do
            if moduleSlotAction[3] ~= "secondary" then
                slotActions:AddCustomSlotAction(unpack(moduleSlotAction))
            end
        end
        cbe.addingSlotActions = nil
        cbe.slotActions = slotActions
    else
        cbe.customSlotActionDescriptors = nil
    end
end

--[[ Pre-hook for PLAYER_INVENTORY:ShouldAddSlotToList. Used to apply additional
     filters to the craft bag to remove items that don't make sense in the 
     current context. ]]
local function PreInventoryShouldAddSlotToList(inventoryManager, inventory, slot)
    if not slot or slot.stackCount <= 0
       or inventory ~= inventoryManager.inventories[INVENTORY_CRAFT_BAG]
    then
        return 
    end
    for moduleName, module in pairs(cbe.modules) do
        if type(module.FilterSlot) == "function" 
           and module:FilterSlot( inventoryManager, inventory, slot )
        then
            return true
        end
    end
end

--[[ Workaround for IsItemBound() not working on craft bag slots ]]
local function PreIsItemBound(bagId, slotIndex)
    if bagId == BAG_VIRTUAL then
        local itemLink = GetItemLink(bagId, slotIndex)
        local bindType = GetItemLinkBindType(itemLink)
        if bindType == BIND_TYPE_ON_PICKUP or bindType == BIND_TYPE_ON_PICKUP_BACKPACK then
            return true
        end
    end
end

--[[ Add quantity keybind option for the custom "keybind4" action type ]]
local quantityKeybind = {
    name     = function()
                   return cbe.slotActions and cbe.slotActions:GetKeybindActionName(4)
               end,
    keybind  = cbe.constants.KEYBIND_QUANTITY,
    callback = function()
                   if cbe.slotActions then 
                       cbe.slotActions:DoKeybindAction(4)
                   end
               end,
    visible  = function()
                   return cbe.slotActions and cbe.slotActions:CheckKeybindActionVisibility(4)
               end,
    hasBind  = function()
                   return cbe.slotActions and cbe.slotActions:GetKeybindActionName(4) ~= nil
               end,
}

local function PreItemSlotActionsControllerSetInventorySlot(slotActionsController, inventorySlot)
    if not inventorySlot or slotActionsController.cbeKeybind4Created then return end
    
    local command
    local commandIndex
    for i, existingCommand in ipairs(slotActionsController) do
        if existingCommand[1] and existingCommand[1].keybind == "UI_SHORTCUT_TERTIARY" then
            command = existingCommand[1]
            commandIndex = i
            break
        end
    end
    if not command then
        util.Debug("Tertiary keybind not found", debug)
        return
    end
    
    -- Create a quickslot keybind whenever the tertiary keybind is created
    quantityKeybind.alignment = command.alignment
    table.insert(slotActionsController, commandIndex + 1, 
        { quantityKeybind, hasBind = quantityKeybind.hasBind, activateCallback = nil })
    
    slotActionsController.cbeKeybind4Created = true
end

local function PreSceneManagerAddFragmentGroup(sceneManager, fragmentGroup)
    if cbe.currentModule and cbe.currentModule:IsSceneShown() and util.IsModuleFragmentGroup(fragmentGroup) then
        cbe.fragmentGroup = fragmentGroup
    else
        cbe.fragmentGroup = nil
    end
end
    
local function PreTransferDialogCanceled(dialog)
    -- If canceled, remove the transfer item from the queue
    cbe.transferDialogCanceled = true
    local transferItem = cbe.transferDialogItem
    CALLBACK_MANAGER:FireCallbacks(cbe.name.."TransferDialogCanceled", dialog, transferItem)
    if not transferItem then return end
    transferItem.queue:Dequeue(transferItem.targetSlotIndex)
    if transferItem.queue.emptySlotTracker then
        transferItem.queue.emptySlotTracker:UnreserveSlot(transferItem.targetSlotIndex)
    end
    util.Debug("Setting cbe.transferDialogItem to nil...", debug)
    cbe.transferDialogItem = nil
end

local function PreTransferDialogFinished(dialog)
    util.Debug("PreTransferDialogFinished.", debug)
    if cbe.transferDialogCanceled then
        return
    end
    
    -- Record the quantity entered from the dialog
    local transferItem = cbe.transferDialogItem
    local quantity
    if IsInGamepadPreferredMode() then
        quantity = ZO_GamepadDialogItemSliderItemSliderSlider:GetValue()
    else
        local transferDialog = SYSTEMS:GetKeyboardObject("ItemTransferDialog")
        quantity = transferDialog:GetSpinnerValue()
        
        -- Save or clear default quantity
        local scope = util.GetTransferItemScope(transferDialog.bag, transferDialog.targetBag)
        local default = transferDialog.checkboxControl and ZO_CheckButton_IsChecked(transferDialog.checkboxControl) and quantity or nil
        local itemId = GetItemId(transferDialog.bag, transferDialog.slotIndex)
        cbe.settings:SetTransferDefault(scope, itemId, default)
    end
    if transferItem then
        util.Debug("Setting transferItem quantity to "..tostring(quantity).."...", debug)
        transferItem:UpdateQuantity(quantity)
    end
    cbe.transferDialogItem = nil
    util.Debug("Setting cbe.transferDialogItem to nil...", debug)
end

local function PreTransferDialogRefresh(transferDialog)

    local self = transferDialog
    
    local scope = util.GetTransferItemScope(transferDialog.bag, transferDialog.targetBag)
    local itemId = GetItemId(transferDialog.bag, transferDialog.slotIndex)
    local default = cbe.settings:GetTransferDefault(scope, itemId, true)
    if transferDialog.checkboxControl then
        ZO_CheckButton_SetCheckState(transferDialog.checkboxControl, default ~= nil)
    end
    if type(default) == "number" then
        util.Debug("Setting transfer dialog quantity default to "..tostring(default).."...", debug)
        self.spinner:SetValue(default, true)
    end
end
ZO_ItemTransferDialog_Base.Transfer = function(self, quantity)
    if quantity > 0 and cbe.transferDialogItem then
        
        local transferItem = cbe.transferDialogItem
        util.Debug("Transfering "..tostring(quantity).." from "
               ..util.GetBagName(transferItem.bag).." slotIndex "..tostring(transferItem.slotIndex)
               .." to "..util.GetBagName(transferItem.targetBag)
               .." slotIndex "..tostring(transferItem.targetSlotIndex), debug)
    
        -- Initiate the stack move to the target bag
        if IsProtectedFunction("RequestMoveItem") then
            CallSecureProtected("RequestMoveItem", transferItem.bag, transferItem.slotIndex, 
                                transferItem.targetBag, transferItem.targetSlotIndex, quantity)
        else
            RequestMoveItem(transferItem.bag, transferItem.slotIndex, 
                            transferItem.targetBag, transferItem.targetSlotIndex, quantity)
        end
    end
end

SYSTEMS:GetGamepadObject("ItemTransferDialog").Transfer = ZO_ItemTransferDialog_Base.Transfer
SYSTEMS:GetKeyboardObject("ItemTransferDialog").Transfer = ZO_ItemTransferDialog_Base.Transfer

function CraftBagExtended:InitializeHooks()

    -- Fix for craft bag tabs not adjusting correctly to backpack layout
    local _, _, _, _, tabsOffsetX = ZO_CraftBagTabs:GetAnchor(0)
    ZO_CraftBagTabs:ClearAnchors()
    ZO_CraftBagTabs:SetAnchor(BOTTOMRIGHT, ZO_CraftBagFilterDivider, TOPRIGHT, tabsOffsetX, -14, 0)
    
    -- Disallow duplicates with same names
    ZO_PreHook(ZO_InventorySlotActions, "AddSlotAction", PreAddSlotAction)
    
    ZO_PreHook("ZO_InventorySlot_DiscoverSlotActionsFromActionList", PreDiscoverSlotActions)
    ZO_PreHook(ZO_ItemSlotActionsController, "SetInventorySlot", PreItemSlotActionsControllerSetInventorySlot)
    
    util.PreHookReturn("IsItemBound", PreIsItemBound)
    
    ZO_PreHook(PLAYER_INVENTORY, "ShouldAddSlotToList", PreInventoryShouldAddSlotToList)
    ZO_PreHook(SCENE_MANAGER, "AddFragmentGroup", PreSceneManagerAddFragmentGroup)
    
    -- Get transfer dialog configuration object
    local transferDialogKeys = { 
        "ITEM_TRANSFER_REMOVE_FROM_CRAFT_BAG_GAMEPAD", 
        "ITEM_TRANSFER_REMOVE_FROM_CRAFT_BAG_KEYBOARD", 
        "ITEM_TRANSFER_ADD_TO_CRAFT_BAG_GAMEPAD", 
        "ITEM_TRANSFER_ADD_TO_CRAFT_BAG_KEYBOARD" 
    }
    for i, transferDialogKey in ipairs(transferDialogKeys) do
    
        local transferDialogInfo = ESO_Dialogs[transferDialogKey]
        
        --[[ Dequeue the transfer if the transfer dialog is canceled via button click. ]]
        local transferCancelButton = transferDialogInfo.buttons[2]
        util.PreHookCallback(transferCancelButton, "callback", PreTransferDialogCanceled)
        
        --[[ Dequeue the transfer if the transfer dialog is canceled with no 
             selection (i.e. ESC keypress) ]]
        util.PreHookCallback(transferDialogInfo, "noChoiceCallback", PreTransferDialogCanceled)
        
        --[[ Whenever the transfer dialog is finished, set the quantity in the queue ]]
        util.PreHookCallback(transferDialogInfo, "finishedCallback", PreTransferDialogFinished)
    end
    
    --[[ Load any default values for the transfer dialog ]]
    ZO_PreHook(SYSTEMS:GetKeyboardObject("ItemTransferDialog"), "Refresh", PreTransferDialogRefresh)
    
    --[[ Handle craft bag open/close events ]]
    CRAFT_BAG_FRAGMENT:RegisterCallback("StateChange",  OnCraftBagFragmentStateChange)
    
    --[[ Handle player inventory open events ]]
    INVENTORY_FRAGMENT:RegisterCallback("StateChange",  OnInventoryFragmentStateChange)
    
end