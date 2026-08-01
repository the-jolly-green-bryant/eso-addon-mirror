
local Require, Export, Event = LibAddon('ItemScripting')

local LibBag  = Require('LibBag')
local Pickup  = Require('Pickup')
local Banking = Require('Banking')

local Bag      = LibBag.Bag
local Backpack = Bag(BAG_BACKPACK)

Event.On (EVENT_INVENTORY_SINGLE_SLOT_UPDATE, 
  function (code, bagId, slot) 
    local Item = Backpack:Item(slot)
    if Item:IsLocked() then return end
    Pickup(Item)
  end)

Event.On (EVENT_OPEN_BANK, 
  function (code, bankId) 
    local Bank = Bag(bankId)
    Bank:StackAll()
    Backpack:StackAll()
    if bankId == BAG_BANK 
    then Banking(Bank, Backpack) end
  end)

Event.Filter (EVENT_INVENTORY_SINGLE_SLOT_UPDATE, 
  REGISTER_FILTER_BAG_ID, 
  BAG_BACKPACK)

Event.Filter (EVENT_INVENTORY_SINGLE_SLOT_UPDATE, 
  REGISTER_FILTER_INVENTORY_UPDATE_REASON, 
  INVENTORY_UPDATE_REASON_DEFAULT)

Event.Filter (EVENT_INVENTORY_SINGLE_SLOT_UPDATE, 
  REGISTER_FILTER_IS_NEW_ITEM, true)

SLASH_COMMANDS["/filterall"] = function () 
  for Item in Backpack:Items() do Pickup(Item) end
end