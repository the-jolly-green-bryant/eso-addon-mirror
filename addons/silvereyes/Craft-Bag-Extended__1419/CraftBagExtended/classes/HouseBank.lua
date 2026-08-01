local cbe   = CraftBagExtended
local util  = cbe.utility
local class = cbe.classes
local name  = cbe.name .. "HouseBank"
local debug = false
class.HouseBank  = class.Bank:Subclass()

function class.HouseBank:New(...)        
    local instance = class.Bank:New(self, name, "houseBank", HOUSE_BANK_FRAGMENT)
    return instance
end

--[[ Checks to ensure that there is a free inventory slot available in both the
     backpack and in the player bank, and that there is a selected guild with
     a player bank and deposit permissions. If there is, returns true.  If not, an 
     alert is raised and returns false. ]]
local function ValidateCanDeposit(bag, slotIndex, bankingBagId)
    if bag ~= BAG_VIRTUAL then return false end
    
    -- Don't transfer if you don't have enough free slots in the player or subscriber banks
    if util.GetSlotsAvailable(INVENTORY_HOUSE_BANK, bankingBagId) < 1 then
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

--[[ Called when the requested stack arrives in the backpack and is ready for
     deposit to the player bank.  Automatically deposits the stack. ]]
local function RetrieveCallback(transferItem, bankingBagId)
    
    util.Debug("Transferring "..tostring(transferItem.targetBag)
               ..", "..tostring(transferItem.targetSlotIndex)..", x"
               ..tostring(transferItem.quantity).." to "..util.GetBagName(bankingBagId), debug)
    
    util.TransferItemToBag( transferItem.targetBag, transferItem.targetSlotIndex, 
        bankingBagId, transferItem.quantity, transferItem.callback)
end

--[[ Adds house bank-specific inventory slot crafting bag actions ]]
function class.HouseBank:AddSlotActions(slotInfo)

    -- Only add these actions when the house bank screen is open on the craft bag tab
    if not PLAYER_INVENTORY:IsBanking() or GetBankingBag() == BAG_BANK then return end
    
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
            function() cbe:HouseBankDeposit(slotInfo.slotIndex) end,
            "primary" 
        })
        --[[ Deposit quantity ]]--
        table.insert(slotInfo.slotActions, {
            SI_CBE_CRAFTBAG_BANK_DEPOSIT,  
            function() cbe:HouseBankDepositDialog(slotInfo.slotIndex) end,
            "keybind4"
        })
    end
end

--[[ Retrieves a given quantity of mats from a given craft bag slot index, 
     and then automatically deposits them in the given housing container bank.
     If quantity is nil, then the max stack is deposited.
     If bankingBagId is nil, then the current banking bag is assumed.
     If the bank or backpack don't each have at least one slot available, 
     an alert is raised and no mats leave the craft bag.
     An optional callback can be raised both when the mats arrive in the backpack
     and/or when they arrive in the housing container bank. ]]
function class.HouseBank:Deposit(slotIndex, quantity, bankingBagId, backpackCallback, bankCallback)
    if not bankingBagId then
        bankingBagId = GetBankingBag()
        util.Debug("Banking Bag Id: "..tostring(bankingBagId), debug)
    end
    if not ValidateCanDeposit(BAG_VIRTUAL, slotIndex, bankingBagId) then return false end
    local callback = { util.WrapFunctions(backpackCallback, RetrieveCallback) }
    table.insert(callback, bankCallback)
    return cbe:Retrieve(slotIndex, quantity, callback, bankingBagId)
end

--[[ Opens a retrieve dialog for a given craft bag slot index, 
     and then automatically deposits the selected quantity into the housing container bank.
     If quantity is nil, then the max stack is deposited.
     If bankingBagId is nil, then the current banking bag is assumed.
     If the bank or backpack don't each have at least one slot available, 
     an alert is raised and no dialog is shown.
     An optional callback can be raised both when the mats arrive in the backpack
     and/or when they arrive in the player bank. ]]
function class.HouseBank:DepositDialog(slotIndex, bankingBagId, backpackCallback, bankCallback)
    if not bankingBagId then
        bankingBagId = GetBankingBag()
        util.Debug("Banking Bag Id: "..tostring(bankingBagId), debug)
    end
    if not ValidateCanDeposit(BAG_VIRTUAL, slotIndex, bankingBagId) then return false end
    local callback = { util.WrapFunctions(backpackCallback, RetrieveCallback) }
    table.insert(callback, bankCallback)
    bankingBagMap[slotIndex] = bankingBagId
    return cbe:RetrieveDialog(slotIndex, SI_CBE_CRAFTBAG_BANK_DEPOSIT, SI_ITEM_ACTION_BANK_DEPOSIT, callback, bankingBagId)
end