local cbe   = CraftBagExtended
local util  = cbe.utility
local class = cbe.classes
local name  = cbe.name .. "Bank"
local debug = false
class.Bank  = class.Module:Subclass()

function class.Bank:New(this, className, scene, bankFragment, ...)
    if this == nil then
        this = self
    end
    if className == nil then
        className = name
    end
    if scene == nil then
        scene = "bank"
    end
    if bankFragment == nil then
        bankFragment = BANK_FRAGMENT
    end
    local instance = class.Module.New(this, 
        className, scene, 
        ZO_SharedRightPanelBackground, BACKPACK_BANK_LAYOUT_FRAGMENT, true)
    instance:Setup(bankFragment)
    return instance
end
    
--[[ When listening for a player bank slot updated, handle any player bank 
     transfer errors that get raised by stopping the transfer. ]]
local function OnBankIsFull(eventCode)
    
    util.Debug("Bank is full!", debug)
    local bankingBag = (GetBankingBag and GetBankingBag()) or BAG_BANK
    local depositQueue = util.GetTransferQueue( BAG_BACKPACK, bankingBag )
    local transferItem = depositQueue:UnqueueSourceBag()
    if not transferItem and bankingBag == BAG_BANK then
        depositQueue = util.GetTransferQueue( BAG_BACKPACK, BAG_SUBSCRIBER_BANK )
        transferItem = depositQueue:UnqueueSourceBag()
    end
    if transferItem then
        util.Debug("Moving "..transferItem.itemLink.." from Inventory slot "..tostring(transferItem.slotIndex).." back to craft bag due to full bank error.", debug)
        cbe:Stow(transferItem.slotIndex)
    end
end
function class.Bank:Setup(bankFragment)
    
    self.menu:SetAnchor(TOPLEFT, ZO_SharedRightPanelBackground, TOPLEFT, 55, 0)
    
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_BANK_IS_FULL, OnBankIsFull)
    
    self.RegisterTabCallbacks(self.scene, bankFragment)
    
    if bankFragment ~= BANK_FRAGMENT then
        return
    end
    
    -- Move bank space purchase keybind to left to make space for withdraw quantity keybind on right
    self.buyBankSpaceButtonGroup =  { alignment = KEYBIND_STRIP_ALIGN_LEFT }
    local buttonGroup = PLAYER_INVENTORY.bankWithdrawTabKeybindButtonGroup
    for i=1,#buttonGroup do
        local button = buttonGroup[i]
        if button.callback == DisplayBankUpgrade then
            table.insert(self.buyBankSpaceButtonGroup, 1, button)
            table.remove(buttonGroup, i)
            PLAYER_INVENTORY.bankWithdrawTabKeybindButtonGroup = self.buyBankSpaceButtonGroup
            break
        end
    end
    bankFragment:RegisterCallback("StateChange", 
        function (oldState, newState)
            if newState == SCENE_FRAGMENT_SHOWN then
                KEYBIND_STRIP:AddKeybindButtonGroup(self.buyBankSpaceButtonGroup)
            elseif newState == SCENE_FRAGMENT_HIDDEN then
                KEYBIND_STRIP:RemoveKeybindButtonGroup(self.buyBankSpaceButtonGroup)
            end
        end)
end

local function OnBankFragmentStateChange(oldState, newState)
    if newState == SCENE_FRAGMENT_SHOWN then
        cbe.currentModule.menu:SetHidden(true)
        if not cbe.fragmentGroup then
            SCENE_MANAGER:RemoveFragment(CRAFT_BAG_FRAGMENT)
        end
    end
end

--[[ Called when the requested stack arrives in the backpack and is ready for
     deposit to the player bank.  Automatically deposits the stack. ]]
local function RetrieveCallback(transferItem)
    
    util.Debug("Transferring "..tostring(transferItem.targetBag)
               ..", "..tostring(transferItem.targetSlotIndex)..", x"
               ..tostring(transferItem.quantity).." to bank", debug)
               
    -- Perform the deposit
    util.TransferItemToBag( transferItem.targetBag, transferItem.targetSlotIndex, 
        BAG_BANK, transferItem.quantity, transferItem.callback)
end

--[[ Called when a previously deposited craft bag stack is withdrawn from the 
     bank and arrives in the backpack again.  Automatically stows the stack. ]]
local function WithdrawCallback(transferItem)
    
    util.Debug("Transferring "..tostring(transferItem.targetBag)
               ..", "..tostring(transferItem.targetSlotIndex)..", x"
               ..tostring(transferItem.quantity).." to craft bag", debug)
               
    -- Stow the withdrawn stack in the craft bag
    cbe:Stow(transferItem.targetSlotIndex, transferItem.quantity, transferItem.callback)
end

--[[ Checks to ensure that there is a free inventory slot available in both the
     backpack and in the player bank, and that there is a selected guild with
     a player bank and deposit permissions. If there is, returns true.  If not, an 
     alert is raised and returns false. ]]
local function ValidateCanDeposit(bag, slotIndex)
    if bag ~= BAG_VIRTUAL then return false end
    
    -- Don't transfer if you don't have enough free slots in the player or subscriber banks
    if util.GetSlotsAvailable(INVENTORY_BANK) < 1 then
        ZO_AlertEvent(EVENT_BANK_IS_FULL, 1, 0)
        return false
    end
    
    -- Don't transfer if you don't have a free proxy slot in your backpack
    if util.GetSlotsAvailable(INVENTORY_BACKPACK) < 1 then
        ZO_AlertEvent(EVENT_INVENTORY_IS_FULL, 1, 0)
        return false
    end

    -- Don't transfer stolen items.  Shouldn't come up from this addon, since
    -- the craft bag filters stolen items out when in the player bank. However,
    -- good to check anyways in case some other addon uses this class.
    if(IsItemStolen(bag, slotIndex)) then
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, SI_STOLEN_ITEM_CANNOT_DEPOSIT_MESSAGE)
        return false
    end
    
    return true
end

--[[ Adds guildbank-specific inventory slot crafting bag actions ]]
function class.Bank:AddSlotActions(slotInfo)

    -- Only add these actions when the player bank screen is open on the craft bag tab
    if not PLAYER_INVENTORY:IsBanking() or (GetBankingBag and GetBankingBag() ~= BAG_BANK) then return end
    
    if slotInfo.slotType == SLOT_TYPE_BANK_ITEM and CanItemBeVirtual(slotInfo.bag, slotInfo.slotIndex) then
    
        --[[ Withdraw ]]--
        table.insert(slotInfo.slotActions, {
            SI_ITEM_ACTION_BANK_WITHDRAW,  
            function() cbe:BankWithdraw(slotInfo.bag, slotInfo.slotIndex) end,
            "primary"
        })
        --[[ Withdraw Quantity ]]--
        table.insert(slotInfo.slotActions, {
            SI_CBE_CRAFTBAG_BANK_WITHDRAW,  
            function() cbe:BankWithdrawDialog(slotInfo.bag, slotInfo.slotIndex) end,
            "keybind4"
        })
    
    elseif slotInfo.slotType == SLOT_TYPE_CRAFT_BAG_ITEM then
    
        --[[ Deposit ]]--
        table.insert(slotInfo.slotActions, {
            SI_ITEM_ACTION_BANK_DEPOSIT,  
            function() cbe:BankDeposit(slotInfo.slotIndex) end,
            "primary" 
        })
        --[[ Deposit quantity ]]--
        table.insert(slotInfo.slotActions, {
            SI_CBE_CRAFTBAG_BANK_DEPOSIT,  
            function() cbe:BankDepositDialog(slotInfo.slotIndex) end,
            "keybind4"
        })
    end
end

--[[ Retrieves a given quantity of mats from a given craft bag slot index, 
     and then automatically deposits them in the player bank.
     If quantity is nil, then the max stack is deposited.
     If the bank or backpack don't each have at least one slot available, 
     an alert is raised and no mats leave the craft bag.
     An optional callback can be raised both when the mats arrive in the backpack
     and/or when they arrive in the player bank. ]]
function class.Bank:Deposit(slotIndex, quantity, backpackCallback, bankCallback)
    if not ValidateCanDeposit(BAG_VIRTUAL, slotIndex) then return false end
    local callback = { util.WrapFunctions(backpackCallback, RetrieveCallback) }
    table.insert(callback, bankCallback)
    return cbe:Retrieve(slotIndex, quantity, callback)
end

--[[ Opens a retrieve dialog for a given craft bag slot index, 
     and then automatically deposits the selected quantity into the player bank.
     If quantity is nil, then the max stack is deposited.
     If the bank or backpack don't each have at least one slot available, 
     an alert is raised and no dialog is shown.
     An optional callback can be raised both when the mats arrive in the backpack
     and/or when they arrive in the player bank. ]]
function class.Bank:DepositDialog(slotIndex, backpackCallback, bankCallback)
    if not ValidateCanDeposit(BAG_VIRTUAL, slotIndex) then return false end
    local callback = { util.WrapFunctions(backpackCallback, RetrieveCallback) }
    table.insert(callback, bankCallback)
    return cbe:RetrieveDialog(slotIndex, SI_CBE_CRAFTBAG_BANK_DEPOSIT, SI_ITEM_ACTION_BANK_DEPOSIT, callback)
end

function class.Bank:FilterSlot(inventoryManager, inventory, slot)
    if not PLAYER_INVENTORY:IsBanking() then
        return
    end
    
    -- Exclude protected slots
    if IsItemStolen(slot.bag, slot.slotIndex) then 
        return true 
    end
end

function class.Bank.RegisterTabCallbacks(scene, bankFragment)
    --[[ Handle scene open close events ]]
    scene:RegisterCallback("StateChange", 
        function (oldState, newState)
            if newState == SCENE_SHOWING then
                bankFragment:RegisterCallback("StateChange", OnBankFragmentStateChange)
            elseif newState == SCENE_HIDING then
                bankFragment:UnregisterCallback("StateChange", OnBankFragmentStateChange)
            end
        end)
end

function ValidateBagId(bagId)
    if bagId == BAG_SUBSCRIBER_BANK then
        return true
    elseif bagId == GetBankingBag() then
        return true
    end
end

--[[ Withdraws a given quantity of mats from the player or subscriber bank
     and then automatically stows them in the craft bag.
     If bagId is not specified, then BAG_BANK is assumed.
     If the backpack doesn't have at least one slot available, 
     an alert is raised and no mats are transferred.
     An optional callback can be raised both when the mats arrive in the backpack
     and/or when they arrive in the craft bag. ]]
function class.Bank:Withdraw(bagId, slotIndex, quantity, backpackCallback, craftbagCallback)
    if type(slotIndex) == "function" or slotIndex == nil then
         craftbagCallback = backpackCallback
         backpackCallback = quantity
         quantity = slotIndex
         slotIndex = bagId
         bagId = BAG_BANK
    end
    if not bagId then
        bagId = BAG_BANK
    end
    if not ValidateBagId(bagId) then
        return
    end
    if not CanItemBeVirtual(bagId, slotIndex) then
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, SI_CBE_CRAFTBAG_ITEM_INVALID)
        return
    end
    local callback = { util.WrapFunctions(backpackCallback, WithdrawCallback) }
    table.insert(callback, craftbagCallback)
    return util.TransferItemToBag(bagId, slotIndex, BAG_BACKPACK, quantity, callback)
end

--[[ Opens a retrieve dialog for a given slot index in the player or subscriber bank, 
     and then automatically withdraws and stows them in the craft bag.
     If bagId is not specified, then BAG_BANK is assumed.
     If the backpack doesn't have at least one slot available, 
     an alert is raised and no mats are transferred.
     An optional callback can be raised both when the mats arrive in the backpack
     and/or when they arrive in the craft bag. ]]
function class.Bank:WithdrawDialog(bagId, slotIndex, backpackCallback, craftbagCallback)
    if type(slotIndex) == "function" or slotIndex == nil then
         craftbagCallback = backpackCallback
         backpackCallback = slotIndex
         slotIndex = bagId
         bagId = BAG_BANK
    end
    if not bagId then
        bagId = BAG_BANK
    end
    if not ValidateBagId(bagId) then
        return
    end
    if not CanItemBeVirtual(bagId, slotIndex) then
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, SI_CBE_CRAFTBAG_ITEM_INVALID)
        return
    end
    local callback = { util.WrapFunctions(backpackCallback, WithdrawCallback) }
    table.insert(callback, craftbagCallback)
    return util.TransferDialog(bagId, slotIndex, BAG_BACKPACK, SI_CBE_CRAFTBAG_BANK_WITHDRAW, SI_ITEM_ACTION_BANK_WITHDRAW, callback)
end