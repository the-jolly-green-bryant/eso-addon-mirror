local cbe       = CraftBagExtended
local util      = cbe.utility
local class     = cbe.classes
local name      = cbe.name .. "GuildBank"
local debug     = false
class.GuildBank = class.Module:Subclass()

function class.GuildBank:New(...)        
    local instance = class.Module.New(self, 
        name, "guildBank", 
        ZO_SharedRightPanelBackground, BACKPACK_GUILD_BANK_LAYOUT_FRAGMENT, true)
    instance:Setup()
    return instance
end

local function StopListeningForGuildBankEvents()
    local guildBankQueue = util.GetTransferQueue( BAG_BACKPACK, BAG_GUILDBANK )
    if not cbe.listeningForGuildBankEvents or guildBankQueue:HasItems() then
        return
    end
    -- Stop listening for events after all queued transfers have arrived
    util.Debug("Unregistering Guild Bank item added and transfer error event handlers.", debug)
    EVENT_MANAGER:UnregisterForEvent(name, EVENT_GUILD_BANK_ITEM_ADDED)
    EVENT_MANAGER:UnregisterForEvent(name, EVENT_GUILD_BANK_TRANSFER_ERROR)
    cbe.listeningForGuildBankEvents = nil
end

--[[ Handles bank item slot update events thrown from a "Deposit" action. ]]
local function OnGuildBankItemAdded(eventCode, slotIndex)
    local stackSize = GetSlotStackSize(BAG_GUILDBANK, slotIndex)
    util.OnStackArrived(BAG_GUILDBANK, slotIndex, stackSize, stackSize)
    StopListeningForGuildBankEvents()
end

--[[ When listening for a guild bank slot updated, handle any guild bank 
     transfer errors that get raised by stopping the transfer. ]]
local function OnGuildBankTransferFailed(eventCode, reason)
    util.Debug("Bank transfer error "..tostring(reason), debug)
    local unqueueFrom = util.GetTransferQueue( BAG_BACKPACK, BAG_GUILDBANK )
    local transferItem = unqueueFrom:UnqueueSourceBag()
    if not transferItem then
        return
    end
        
    StopListeningForGuildBankEvents()
    
    util.Debug("Moving "..transferItem.itemLink.." from Inventory slot "..tostring(transferItem.slotIndex).." back to craft bag due to bank transfer error "..tostring(reason), debug)
    cbe:Stow(transferItem.slotIndex)
end

local function ListenForGuildBankEvents()
    if cbe.listeningForGuildBankEvents then
        return
    end
    util.Debug("Registering Guild Bank item added and transfer error event handlers.", debug)
    -- Listen for bank slot updates
    EVENT_MANAGER:RegisterForEvent(name, EVENT_GUILD_BANK_ITEM_ADDED, OnGuildBankItemAdded)
    -- Listen for deposit failures
    EVENT_MANAGER:RegisterForEvent(name, EVENT_GUILD_BANK_TRANSFER_ERROR, OnGuildBankTransferFailed)
    local guildBankQueue = util.GetTransferQueue( BAG_BACKPACK, BAG_GUILDBANK )
    cbe.listeningForGuildBankEvents = true
end

local function OnCloseGuildBank(eventCode)
    -- Guild bank events don't fire while the guild bank is closed or deselected, 
    -- and there's no way for us to know if the transfer succeeded or failed, so 
    -- just give up trying to raise callbacks when the items arrive in the guild bank.
    local guildBankQueue = util.GetTransferQueue( BAG_BACKPACK, BAG_GUILDBANK )
    guildBankQueue:Clear()
    StopListeningForGuildBankEvents()
end

function class.GuildBank:Setup()
    
    self.menu:SetAnchor(TOPLEFT, ZO_SharedRightPanelBackground, TOPLEFT, 55, 0)    
    class.Bank.RegisterTabCallbacks(self.scene, GUILD_BANK_FRAGMENT)
    EVENT_MANAGER:RegisterForEvent(name, EVENT_CLOSE_GUILD_BANK, OnCloseGuildBank)
    EVENT_MANAGER:RegisterForEvent(name, EVENT_GUILD_BANK_DESELECTED, OnCloseGuildBank)
    
end

--[[ Called when the requested stack arrives in the backpack and is ready for
     deposit to the guild bank.  Automatically deposits the stack. ]]
local function RetrieveCallback(transferItem)
    
    -- If multiple callbacks were specified, listen for guild bank slot updates
    local newTransferItem = transferItem:Requeue(BAG_GUILDBANK)
    
    util.Debug("Transferring "..tostring(transferItem.targetBag)
               ..", "..tostring(transferItem.targetSlotIndex)..", x"
               ..tostring(transferItem.quantity).." to guild bank slot "..tostring(newTransferItem and newTransferItem.targetSlotIndex), debug)
    
    -- Perform the deposit
    ListenForGuildBankEvents()
    TransferToGuildBank(transferItem.targetBag, transferItem.targetSlotIndex)
end

--[[ Checks to ensure that there is a free inventory slot available in both the
     backpack and in the guild bank, and that there is a selected guild with
     a guild bank and deposit permissions. If there is, returns true.  If not, an 
     alert is raised and returns false. ]]
local function ValidateCanDeposit(bag, slotIndex)
    if bag ~= BAG_VIRTUAL then return false end
        
    local guildId = GetSelectedGuildBankId()
    if not guildId then return false end
    
    -- Don't transfer if you don't have enough free slots in the guild bank
    if util.GetSlotsAvailable(INVENTORY_GUILDBANK) < 1 then
        ZO_AlertEvent(EVENT_GUILD_BANK_TRANSFER_ERROR, GUILD_BANK_NO_SPACE_LEFT)
        return false
    end
    
    -- Don't transfer if you don't have a free proxy slot in your backpack
    if util.GetSlotsAvailable(INVENTORY_BACKPACK) < 1 then
        ZO_AlertEvent(EVENT_INVENTORY_IS_FULL, 1, 0)
        return false
    end
    
    -- Don't transfer if the guild member doesn't have deposit permissions
    if not DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_BANK_DEPOSIT) then
        ZO_AlertEvent(EVENT_GUILD_BANK_TRANSFER_ERROR, GUILD_BANK_NO_DEPOSIT_PERMISSION)
        return false
    end

    -- Don't transfer if the guild doesn't have 10 members
    if not DoesGuildHavePrivilege(guildId, GUILD_PRIVILEGE_BANK_DEPOSIT) then
        ZO_AlertEvent(EVENT_GUILD_BANK_TRANSFER_ERROR, GUILD_BANK_GUILD_TOO_SMALL)
        return false
    end

    -- Don't transfer stolen items.  Shouldn't come up from this addon, since
    -- the craft bag filters stolen items out when in the guild bank. However,
    -- good to check anyways in case some other addon uses this class.
    if IsItemStolen(bag, slotIndex) then
        ZO_AlertEvent(EVENT_GUILD_BANK_TRANSFER_ERROR, GUILD_BANK_NO_DEPOSIT_STOLEN_ITEM)
        return false
    end
    
    return true
end           

--[[ Adds guildbank-specific inventory slot crafting bag actions ]]
function class.GuildBank:AddSlotActions(slotInfo)

    -- Only add these actions when the guild bank screen is open on the craft bag tab
    if GetInteractionType() ~= INTERACTION_GUILDBANK 
       or not GetSelectedGuildBankId() 
       or slotInfo.slotType ~= SLOT_TYPE_CRAFT_BAG_ITEM 
    then 
        return 
    end
    local slotIndex = slotInfo.slotIndex
    
    --[[ Deposit ]]--
    table.insert(slotInfo.slotActions, {
        SI_ITEM_ACTION_BANK_DEPOSIT,  
        function() cbe:GuildBankDeposit(slotIndex) end,
        "primary"
    })
    
    --[[ Deposit quantity ]]--
    table.insert(slotInfo.slotActions, {
        SI_CBE_CRAFTBAG_BANK_DEPOSIT,  
        function() cbe:GuildBankDepositDialog(slotIndex) end,
        "keybind4"
    })
end

--[[ Retrieves a given quantity of mats from a given craft bag slot index, 
     and then automatically deposits them in the currently-selected guild bank.
     If quantity is nil, then the max stack is deposited.
     If no guild bank is selected, or if the current guild or user doesn't have
     bank privileges, an alert is raised and no mats leave the craft bag.
     An optional callback can be raised both when the mats arrive in the backpack
     and/or when they arrive in the guild bank. ]]
function class.GuildBank:Deposit(slotIndex, quantity, backpackCallback, guildBankCallback)
    if not ValidateCanDeposit(BAG_VIRTUAL, slotIndex) then return false end
    local callback = { util.WrapFunctions(backpackCallback, RetrieveCallback) }
    table.insert(callback, guildBankCallback)
    return cbe:Retrieve(slotIndex, quantity, callback)
end

--[[ Opens a retrieve dialog for a given craft bag slot index, 
     and then automatically deposits the selected quantity into the 
     currently-selected guild bank.
     If quantity is nil, then the max stack is deposited.
     If no guild bank is selected, or if the current guild or user doesn't have
     bank privileges, an alert is raised and no dialog is shown.
     An optional callback can be raised both when the mats arrive in the backpack
     and/or when they arrive in the guild bank. ]]
function class.GuildBank:DepositDialog(slotIndex, backpackCallback, guildBankCallback)
    if not ValidateCanDeposit(BAG_VIRTUAL, slotIndex) then return false end
    local callback = { util.WrapFunctions(backpackCallback, RetrieveCallback) }
    table.insert(callback, guildBankCallback)
    return cbe:RetrieveDialog(slotIndex, SI_CBE_CRAFTBAG_BANK_DEPOSIT, SI_ITEM_ACTION_BANK_DEPOSIT, callback)
end

function class.GuildBank:FilterSlot(inventoryManager, inventory, slot)
    if GetInteractionType() ~= INTERACTION_GUILDBANK 
       or not GetSelectedGuildBankId() 
    then
        return
    end
    
    -- Exclude protected slots
    if util.IsSlotProtected(slot) then 
        return true 
    end
end