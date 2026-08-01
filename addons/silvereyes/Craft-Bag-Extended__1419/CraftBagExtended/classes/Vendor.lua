local cbe   = CraftBagExtended
local util  = cbe.utility
local class = cbe.classes
class.Vendor = class.Module:Subclass()

local name = cbe.name .. "Vendor"
local debug = false

local function HideWhenShown()
    return not IsStoreEmpty()
end
function class.Vendor:New(...)
    local instance = class.Module.New(self, 
        name, "store", ZO_StoreWindowMenu, BACKPACK_STORE_LAYOUT_FRAGMENT, HideWhenShown)
    instance:Setup(...)
    return instance
end

local function OnSellReceipt(eventCode, itemName, quantity, money)
    PLAYER_INVENTORY:UpdateList(INVENTORY_CRAFT_BAG)
end

function class.Vendor:Setup()
    self.menu:SetAnchor(TOPLEFT, ZO_SharedRightPanelBackground, TOPLEFT, 55, 0)
    
    class.Bank.RegisterTabCallbacks(self.scene, STORE_FRAGMENT)
    class.Bank.RegisterTabCallbacks(self.scene, BUY_BACK_FRAGMENT)
    class.Bank.RegisterTabCallbacks(self.scene, REPAIR_FRAGMENT)
    
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_SELL_RECEIPT, OnSellReceipt)
     
end

local function CanSellItem(bagId, slotIndex)
    
    return ZO_Store_IsShopping() and not SYSTEMS:GetObject("fence"):IsLaundering() and not IsItemStolen(bagId, slotIndex)
end

--[[ Called after a Sell operation successfully retrieves a craft bag item 
     to the backpack. Responsible for executing the "Sell" part of the operation. ]]
local function RetrieveCallback(transferItem)
    if CanSellItem(transferItem.targetBag, transferItem.targetSlotIndex) then
        SellInventoryItem(transferItem.targetBag, transferItem.targetSlotIndex, transferItem.quantity)
    end
end

--[[ Adds vendor-specific inventory slot crafting bag actions ]]
function class.Vendor:AddSlotActions(slotInfo)
    
    if slotInfo.slotType == SLOT_TYPE_CRAFT_BAG_ITEM
       and CanSellItem(slotInfo.bag, slotInfo.slotIndex)
    then
        --[[ Sell ]]
        table.insert(slotInfo.slotActions, {
            SI_ITEM_ACTION_SELL, 
            function() cbe:VendorSell(slotInfo.slotIndex) end, 
            "primary"
        })
        --[[ Sell Quantity ]]
        table.insert(slotInfo.slotActions, {
            SI_CBE_CRAFTBAG_SELL_QUANTITY, 
            function() cbe:VendorSellDialog(slotInfo.slotIndex) end, 
            "keybind4"
        })
    end
end

--[[ Moves a given quantity of a craft bag slot to the backpack and then sells it.
     If quantity is nil, then the max stack is moved.
     Optionally raises callbacks after the stack arrives in the backpack.
     Returns true if the backpack has slots available and the item can be sold.
     Otherwise, returns false. ]]
function class.Vendor:Sell(slotIndex, quantity, backpackCallback)
    if not CanSellItem(BAG_VIRTUAL, slotIndex) then return false end
    local callback = { util.WrapFunctions(backpackCallback, RetrieveCallback) }
    return cbe:Retrieve(slotIndex, quantity, callback)
end

--[[ Opens a retrieve dialog for a given craft bag slot index, 
     and then automatically sells it to the vendor.
     Optionally raises callbacks after the stack arrives in the backpack.
     Returns true if the backpack has slots available and the item can be sold.
     Otherwise, returns false. ]]
function class.Vendor:SellDialog(slotIndex, backpackCallback)
    if not CanSellItem(BAG_VIRTUAL, slotIndex) then return false end
    local callback = { util.WrapFunctions(backpackCallback, RetrieveCallback) }
    return cbe:RetrieveDialog(slotIndex, SI_CBE_CRAFTBAG_SELL_QUANTITY, 
        SI_ITEM_ACTION_SELL, callback) 
end