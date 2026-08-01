local Classes = MyCollection.Internals.Classes
local Constants = MyCollection.Internals.Constants
local Functions = MyCollection.Internals.Functions
local Data = MyCollection.Internals.Data
local Saved = MyCollection.Internals.Saved
local Defaults = MyCollection.Internals.Saved.Defaults
local Dependencies = MyCollection.Internals.Dependencies
local EventManager = MyCollection.Internals.Dependencies.Officials.EventManager
local SharedInventory = MyCollection.Internals.Dependencies.Officials.SharedInventory
local Logger = MyCollection.Internals.Dependencies.Logger
local UI = MyCollection.UI

-- Functions
function MyCollection.ResetInventory(event)
  Data.Inventory:Refresh()
end

-- Initialite
function MyCollection:Initialize()
  -- Saved variable load
  Saved.Inventory = Dependencies.LibSavedVars:NewAccountWide(MyCollection.Internals.SavedVariables.Inventory.Name, nil, Defaults.Inventory ):Version(MyCollection.Internals.SavedVariables.Inventory.Version, function(table) end)
  Saved.Collection = Dependencies.LibSavedVars:NewAccountWide(MyCollection.Internals.SavedVariables.Collection.Name, nil, Defaults.Collection ):Version(MyCollection.Internals.SavedVariables.Collection.Version, function(table) end)
  Saved.Settings = Dependencies.LibSavedVars:NewAccountWide(MyCollection.Internals.SavedVariables.Settings.Name, nil, Defaults.Settings ):Version(MyCollection.Internals.SavedVariables.Settings.Version, function(table) end)
  
  Saved.Settings.Logging = false
  Logger:SetEnabled(Saved.Settings.Logging)

  Data.Inventory = Classes.Inventory.New(Saved.Inventory)  
  Data.Collection = Classes.Collection.New(Saved.Collection)

  -- Register Callbacks
  --SharedInventory:RegisterCallback("SingleSlotInventoryUpdate", MyCollection.Internals.Functions.Callbacks.WUT)
  SharedInventory:RegisterCallback("SlotRemoved", Functions.Callbacks.Removed)
  SharedInventory:RegisterCallback("SlotAdded", Functions.Callbacks.Added)
  SharedInventory:RegisterCallback("SlotUpdated", Functions.Callbacks.Updated)

  -- Refresh the current caracters and banks data
  Data.Inventory:Refresh()

  --  Initialize UI
  UI.Frame.Initialize()
end

function MyCollection.OnAddOnLoaded(event, addonName)
  if MyCollection.Name ~= addonName then return end
  
  while not LibSets.AreSetsLoaded() do end

  EventManager:UnregisterForEvent(MyCollection.Name, EVENT_ADD_ON_LOADED)    
  MyCollection:Initialize() 
end

EventManager:RegisterForEvent(MyCollection.Name, EVENT_ADD_ON_LOADED, MyCollection.OnAddOnLoaded)

---- Possible usefull events
-- Logout
--EVENT_PLAYER_DEACTIVATED

-- Change inventory item
--EVENT_INVENTORY_SINGLE_SLOT_UPDATE
---- EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT

-- Open Bank
--EVENT_OPEN_BANK

-- Open Guild Bank, add/remove item
--EVENT_GUILD_BANK_ITEMS_READY
--EVENT_GUILD_BANK_ITEM_ADDED
--EVENT_GUILD_BANK_ITEM_REMOVED
--EVENT_GUILD_SELF_JOINED_GUILD
--EVENT_GUILD_SELF_LEFT_GUILD

-- Entered House
--EVENT_PLAYER_ACTIVATED
--EVENT_HOUSING_EDITOR_MODE_CHANGEDw