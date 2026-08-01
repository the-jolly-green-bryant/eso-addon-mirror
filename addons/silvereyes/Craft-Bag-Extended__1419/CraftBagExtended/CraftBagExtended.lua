local function Set (list)
    local set = {} for _, l in ipairs(list) do set[l] = true end return set
end

CraftBagExtended = {
    name       = "CraftBagExtended",
    title      = GetString(SI_CBE),
    author     = "silvereyes, akasha167",
    version    = "3.0.13",
    apiVersion = 1.0,
    debug      = false,
    classes    = {},
    constants  = {
        QUANTITY_UNSPECIFIED = -1,
        KEYBIND_QUANTITY     = "UI_SHORTCUT_QUICK_SLOTS",
        BAG_TYPES = Set {
            BAG_BACKPACK,
            BAG_BANK,
            BAG_GUILDBANK,
            BAG_SUBSCRIBER_BANK,
            BAG_VIRTUAL,
            BAG_HOUSE_BANK_ONE,
            BAG_HOUSE_BANK_TWO,
            BAG_HOUSE_BANK_THREE,
            BAG_HOUSE_BANK_FOUR,
            BAG_HOUSE_BANK_FIVE,
            BAG_HOUSE_BANK_SIX,
            BAG_HOUSE_BANK_SEVEN,
            BAG_HOUSE_BANK_EIGHT,
            BAG_HOUSE_BANK_NINE,
            BAG_HOUSE_BANK_TEN,
        },
        SLOT_TYPES = Set {
            SLOT_TYPE_BANK_ITEM,
            SLOT_TYPE_CRAFT_BAG_ITEM,
            SLOT_TYPE_ITEM,
            SLOT_TYPE_MAIL_QUEUED_ATTACHMENT,
            SLOT_TYPE_MY_TRADE,
        },
        LOCATION = {
            SOURCE_BAG = 1,
            IN_TRANSIT = 2,
            TARGET_BAG = 3,
        },
        UNQUEUE_TIMEOUT_MS = 1000,
    },
    singletons = {},
}

--[[ 
       PUBLIC API

     The following methods and signatures should be considered safe to use in
     your code without fear of breaking signature changes.
  ]]

--[[ Opens the "Retrieve" from craft bag dialog for depositing to the player 
     bank.  Automatically runs a given callback once the deposit is complete, 
     if specified. ]]
function CraftBagExtended:BankDeposit(slotIndex, quantity, callback)
    return self.modules.bank:Deposit(slotIndex, quantity, callback)
end

--[[ Opens the "Retrieve" from craft bag dialog for depositing to the player 
     bank.  Automatically runs a given callback once the deposit is complete, 
     if specified. ]]
function CraftBagExtended:BankDepositDialog(slotIndex, callback)
    return self.modules.bank:DepositDialog(slotIndex, callback)
end

--[[ Withdraws a given quantity of mats from the player or subscriber bank
     and then automatically stows them in the craft bag.
     If bagId is not specified, then BAG_BANK is assumed.
     If the backpack doesn't have at least one slot available, 
     an alert is raised and no mats are transferred.
     An optional callback can be raised both when the mats arrive in the backpack
     and/or when they arrive in the craft bag. ]]
function CraftBagExtended:BankWithdraw(bagId, slotIndex, quantity, backpackCallback, craftbagCallback)
    return self.modules.bank:Withdraw(bagId, slotIndex, quantity, backpackCallback, craftbagCallback)
end

--[[ Opens a retrieve dialog for a given slot index in the player or subscriber bank, 
     and then automatically withdraws and stows them in the craft bag.
     If bagId is not specified, then BAG_BANK is assumed.
     If the backpack doesn't have at least one slot available, 
     an alert is raised and no mats are transferred.
     An optional callback can be raised both when the mats arrive in the backpack
     and/or when they arrive in the craft bag. ]]
function CraftBagExtended:BankWithdrawDialog(bagId, slotIndex, backpackCallback, craftbagCallback)
    return self.modules.bank:WithdrawDialog(bagId, slotIndex, backpackCallback, craftbagCallback)
end

--[[ Retrieves a given quantity of mats from a given craft bag slot index, 
     and then automatically deposits them in the currently-selected guild bank.
     If quantity is nil, then the max stack is deposited.
     If no guild bank is selected, or if the current guild or user doesn't have
     bank privileges, an alert is raised and no mats leave the craft bag.
     An optional callback can be raised both when the mats arrive in the backpack
     and/or when they arrive in the guild bank. ]]
function CraftBagExtended:GuildBankDeposit(slotIndex, quantity, backpackCallback, guildBankCallback)
    return self.modules.guildBank:Deposit(slotIndex, quantity, backpackCallback, guildBankCallback)
end

--[[ Opens a retrieve dialog for a given craft bag slot index, 
     and then automatically deposits the selected quantity into the 
     currently-selected guild bank.
     If quantity is nil, then the max stack is deposited.
     If no guild bank is selected, or if the current guild or user doesn't have
     bank privileges, an alert is raised and no dialog is shown.
     An optional callback can be raised both when the mats arrive in the backpack
     and/or when they arrive in the guild bank. ]]
function CraftBagExtended:GuildBankDepositDialog(slotIndex, backpackCallback, guildBankCallback)
    return self.modules.guildBank:DepositDialog(slotIndex, backpackCallback, guildBankCallback)
end

if GetBankingBag then

--[[ Retrieves a given quantity of mats from the given craft bag slot index, 
     and then automatically deposits them in the given house bank.
     Automatically runs a given callback once the deposit is complete, 
     if specified. ]]
function CraftBagExtended:HouseBankDeposit(slotIndex, quantity, houseBankBagId, callback)
    return self.modules.houseBank:Deposit(slotIndex, quantity, houseBankBagId, callback)
end

--[[ Opens the "Retrieve" from craft bag dialog for depositing to the player 
     bank.  Automatically runs a given callback once the deposit is complete, 
     if specified. ]]
function CraftBagExtended:HouseBankDepositDialog(slotIndex, callback)
    return self.modules.bank:DepositDialog(slotIndex, callback)
end

end

--[[ Retrieves a given quantity of mats from a given craft bag slot index, 
     and then automatically attaches the stack onto the pending mail.
     If quantity is nil, then the max stack is deposited.
     If no attachment slots remain an alert is raised and no mats leave the craft bag.
     An optional callback can be raised both when the mats arrive in the backpack
     and/or when they have been attached. ]]
function CraftBagExtended:MailAttach(slotIndex, quantity, backpackCallback, attachedCallback)
    return self.modules.mail:Attach(slotIndex, quantity, backpackCallback, attachedCallback)
end

--[[ Opens a retrieve dialog for a given craft bag slot index, 
     and then automatically attaches the selected quantity onto pending mail.
     If no attachment slots remain an alert is raised and no dialog is shown.
     An optional callback can be raised both when the mats arrive in the backpack
     and/or when they have been attached. ]]
function CraftBagExtended:MailAttachDialog(slotIndex, backpackCallback, attachedCallback)
    return self.modules.mail:AttachDialog(slotIndex, backpackCallback, attachedCallback)
end

--[[ Detaches the stack at the given backpack slot index and returns it to the
     craft bag.  If the stack is not attached, returns false.  Optionally
     raises a callback after the stack is detached and/or after the stack is
     returned to the craft bag. ]]
function CraftBagExtended:MailDetach(slotIndex, detachedCallback, stowedCallback)
    return self.modules.mail:Detach(slotIndex, detachedCallback, stowedCallback)
end

--[[ Moves a given quantity from the given craft bag inventory slot index into 
     the backpack without a dialog prompt.  
     If quantity is nil, then the max stack is moved. If a callback function 
     is specified, it will be called when the mats arrive in the backpack. ]]
function CraftBagExtended:Retrieve(slotIndex, quantity, callback, ...)
    return self.utility.Retrieve(slotIndex, quantity, callback, ...)
end

--[[ Opens the "Retrieve" from craft bag dialog with a custom action name for
     the transfer button.  Automatically runs a given callback once the transfer
     is complete, if specified. ]]
function CraftBagExtended:RetrieveDialog(slotIndex, dialogTitle, buttonText, callback, ...)
    return self.utility.TransferDialog( 
        BAG_VIRTUAL, slotIndex, BAG_BACKPACK, 
        dialogTitle or GetString(SI_CBE_CRAFTBAG_RETRIEVE_QUANTITY), 
        buttonText or GetString(SI_ITEM_ACTION_REMOVE_ITEMS_FROM_CRAFT_BAG), 
        callback,
        ...)
end

--[[ Moves a given quantity from the given backpack inventory slot index into 
     the craft bag without a dialog prompt.  
     If quantity is nil, then the whole stack is moved. If a callback function 
     is specified, it will be called when the mats arrive in the craft bag. ]]
function CraftBagExtended:Stow(slotIndex, quantity, callback, ...)
    return self.utility.Stow(slotIndex, quantity, callback, ...)
end

--[[ Opens the "Stow" to craft bag dialog with a custom action name for
     the transfer button.  Automatically runs a given callback once the transfer
     is complete, if specified. ]]
function CraftBagExtended:StowDialog(slotIndex, dialogTitle, buttonText, callback, ...)
    return self.utility.TransferDialog( 
        BAG_BACKPACK, slotIndex, BAG_VIRTUAL, 
        dialogTitle or GetString(SI_CBE_CRAFTBAG_STOW_QUANTITY), 
        buttonText or GetString(SI_ITEM_ACTION_ADD_ITEMS_TO_CRAFT_BAG), 
        callback,
        ...)
end

--[[ Moves a given quantity of a craft bag slot to the backpack and then adds it
     to the current trade offer.
     If quantity is nil, then the max stack is moved.
     Optionally raises callbacks after the stack arrives in the backpack and/or
     after it is added to the trade offer.
     Returns true if the backpack and the trade offer both have slots available.
     Otherwise, returns false. ]]
function CraftBagExtended:TradeAddToOffer(slotIndex, quantity, backpackCallback, addedCallback)
    return self.modules.trade:AddToOffer(slotIndex, quantity, backpackCallback, addedCallback)
end

--[[ Opens a retrieve dialog for a given craft bag slot index, 
     and then automatically adds it to the current trade offer.
     Optionally raises callbacks after the stack arrives in the backpack and/or
     after it is added to the trade offer.
     Returns true if the backpack and the trade offer both have slots available.
     Otherwise, returns false. ]]
function CraftBagExtended:TradeAddToOfferDialog(slotIndex, backpackCallback, addedCallback)
    return self.modules.trade:AddToOfferDialog(slotIndex, backpackCallback, addedCallback)
end

--[[ Removes the stack at the given backpack index from the player's trade offer
     and returns the stack to the craft bag.  Optionally raise callbacks after
     the stack is removed from the offer and/or after it is returned to the craft
     bag. Returns true if the slot exists in the trade offer and can be moved
     to the craft bag. Otherwise, returns false. ]]
function CraftBagExtended:TradeRemoveFromOffer(slotIndex, removedCallback, stowedCallback)
    return self.modules.trade:RemoveFromOffer(slotIndex, removedCallback, stowedCallback)
end

--[[ If Awesome Guild Store is not running, retrieves a given quantity of mats 
     from a given craft bag slot index, and then automatically adds them to a 
     new pending guild store sale posting and displays the backpack tab with the
     moved stack. If quantity is nil, then the max stack is deposited.
     If the backpack doesn't have at least one slot available,
     an alert is raised and no mats leave the craft bag.
     An optional callback can be raised both when the mats arrive in the backpack
     and/or after they are added to the pending listing. ]]
function CraftBagExtended:TradingHouseAddToListing(slotIndex, quantity, backpackCallback, addedCallback)
    return self.modules.tradingHouse:AddToListing(slotIndex, quantity, backpackCallback, addedCallback)
end

--[[ If Awesome Guild Store is not running, opens a retrieve dialog for a given 
     craft bag slot index, and then automatically adds the selected quantity to 
     a new pending guild store sale posting and displays the backpack tab with
     the moved stack. If the backpack doesn't have at least one slot available, 
     an alert is raised and no dialog is shown.
     An optional callback can be raised both when the mats arrive in the backpack
     and/or after they are added to the pending listing. ]]
function CraftBagExtended:TradingHouseAddToListingDialog(slotIndex, backpackCallback, addedCallback)
    return self.modules.tradingHouse:AddToListingDialog(slotIndex, backpackCallback, addedCallback)
end

--[[ If Awesome Guild Store is not running, removes the currently-pending stack 
     of mats from the guild store sales listing and then automatically stows 
     them in the craft bag and displays the craft bag tab.
     An optional callback can be raised both when the mats are removed from the 
     listing and/or when they arrive in the craft bag. ]]
function CraftBagExtended:TradingHouseRemoveFromListing(slotIndex, removedCallback, craftbagCallback)
    return self.modules.tradingHouse:RemoveFromListing(slotIndex, removedCallback, craftbagCallback)
end

--[[ Searches the guild trader for the given craft bag item slot index. ]]
function CraftBagExtended:TradingHouseSearch(slotIndex)
    return self.modules.tradingHouse:Search(slotIndex)
end

--[[ Moves a given quantity of a craft bag slot to the backpack and then sells it.
     If quantity is nil, then the max stack is moved.
     Optionally raises callbacks after the stack arrives in the backpack and/or
     after it is sold.
     Returns true if the backpack has slots available.
     Otherwise, returns false. ]]
function CraftBagExtended:VendorSell(slotIndex, quantity, backpackCallback)
    return self.modules.vendor:Sell(slotIndex, quantity, backpackCallback)
end

--[[ Opens a retrieve dialog for a given craft bag slot index, 
     and then automatically sells it to the vendor.
     Optionally raises callbacks after the stack arrives in the backpack and/or
     after it is sold.
     Returns true if the backpack has slots available.
     Otherwise, returns false. ]]
function CraftBagExtended:VendorSellDialog(slotIndex, backpackCallback)
    return self.modules.vendor:SellDialog(slotIndex, backpackCallback)
end

--[[ 
       END PUBLIC API 
  ]]

local function OnAddonLoaded(event, name)
    local self = CraftBagExtended
    if name ~= self.name then return end
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
    
    local class = self.classes
    
    self.settings  = class.Settings:New()
    
    self.modules = {
        bank         = class.Bank:New(),
        guildBank    = class.GuildBank:New(),
        inventory    = class.Inventory:New(),
        mail         = class.Mail:New(),
        trade        = class.Trade:New(),
        tradingHouse = class.TradingHouse:New(),
        vendor       = class.Vendor:New(),
    }
    
    if GetBankingBag then
        self.modules.houseBank = class.HouseBank:New()
    end
    
    self.hasCraftBagAccess = HasCraftBagAccess()
    
    self:InitializeHooks()
    
end
EVENT_MANAGER:RegisterForEvent(CraftBagExtended.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)