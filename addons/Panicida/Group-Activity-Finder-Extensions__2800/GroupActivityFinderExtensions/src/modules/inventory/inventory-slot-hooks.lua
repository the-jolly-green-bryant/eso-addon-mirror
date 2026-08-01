-------------------------------------------------------------------------------
-- Inventory Slot Hooks Module
-- Provides a single hook point for inventory slot setup callbacks.
-- Features register their callbacks to avoid multiple overrides.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Localized Globals
-------------------------------------------------------------------------------
local pairs = pairs
local ipairs = ipairs

local GAFE = GroupActivityFinderExtensions

-------------------------------------------------------------------------------
-- Module Declaration
-------------------------------------------------------------------------------
local InventorySlotHooks = {}

-------------------------------------------------------------------------------
-- Private Variables
-------------------------------------------------------------------------------
local registeredCallbacks = {}
local initialized = false

-------------------------------------------------------------------------------
-- Private Functions
-------------------------------------------------------------------------------

--- Executes all registered callbacks for an inventory slot.
--- @param control any The inventory row control
--- @param data table The slot data containing bag and slot info
local function ExecuteCallbacks(control, data)
  for _, callback in ipairs(registeredCallbacks) do
    callback(control, data)
  end
end

--- Hooks the inventory list data types to run registered callbacks.
local function HookInventoryDataTypes()
  local inventoryDataTypes = {
    ZO_PlayerInventoryList.dataTypes[1],
    ZO_PlayerBankBackpack.dataTypes[1],
    ZO_CraftBagList.dataTypes[1],
  }

  for _, dataType in pairs(inventoryDataTypes) do
    if dataType then
      local baseSetupCallback = dataType.setupCallback
      dataType.setupCallback = function(control, data, ...)
        baseSetupCallback(control, data, ...)
        ExecuteCallbacks(control, data)
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Public Functions
-------------------------------------------------------------------------------

--- Registers a callback to be executed on inventory slot setup.
--- @param callback function The callback function(control, data)
function InventorySlotHooks.RegisterCallback(callback)
  registeredCallbacks[#registeredCallbacks + 1] = callback
end

--- Initializes the inventory slot hooks.
--- Must be called after all callbacks are registered.
function InventorySlotHooks.Init()
  if initialized then
    return
  end

  if #registeredCallbacks > 0 then
    HookInventoryDataTypes()
  end

  initialized = true
end

-------------------------------------------------------------------------------
-- Module Registration
-------------------------------------------------------------------------------
GAFE.InventorySlotHooks = InventorySlotHooks
