-------------------------------------------------------------------------------
-- Inventory Module
-- Coordinates inventory-related features: Armory display, Currency tracker.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Localized Globals
-------------------------------------------------------------------------------
local EVENT_MANAGER = EVENT_MANAGER
local ZO_PreHookHandler = ZO_PreHookHandler

local GAFE = GroupActivityFinderExtensions

-------------------------------------------------------------------------------
-- Module Declaration
-------------------------------------------------------------------------------
local Inventory = {}

-------------------------------------------------------------------------------
-- Public Functions
-------------------------------------------------------------------------------

--- Initializes the inventory module.
--- Sets up event handlers that delegate to sub-modules.
function Inventory.Init()
  -- Initialize currency tracker (hooks wallet UI)
  GAFE.CurrencyTracker.Init()

  -- Initialize TTC price display (registers inventory slot callback)
  GAFE.TTCPrice.Init()

  -- Initialize crafted icon display (registers inventory slot callback)
  GAFE.CraftedIcon.Init()

  -- Initialize inventory slot hooks (must be called after all callbacks are registered)
  GAFE.InventorySlotHooks.Init()

  -- Armory: Hook character panel show
  ZO_PreHookHandler(ZO_Character, 'OnEffectivelyShown', function()
    GAFE.Armory.OnShown()
  end)

  -- Armory: Build restore event
  EVENT_MANAGER:RegisterForEvent(
    GAFE.name .. "_Inventory_ArmoryRestore",
    EVENT_ARMORY_BUILD_RESTORE_RESPONSE,
    function(_, result, buildIndex)
      GAFE.Armory.OnBuildRestored(result, buildIndex)
    end
  )

  -- Armory: Build save event
  EVENT_MANAGER:RegisterForEvent(
    GAFE.name .. "_Inventory_ArmorySave",
    EVENT_ARMORY_BUILD_SAVE_RESPONSE,
    function(_, result, buildIndex)
      GAFE.Armory.OnBuildSaved(result, buildIndex)
    end
  )

  -- Armory: Build update event
  EVENT_MANAGER:RegisterForEvent(
    GAFE.name .. "_Inventory_ArmoryUpdate",
    EVENT_ARMORY_BUILD_UPDATED,
    function(_, buildIndex)
      GAFE.Armory.OnBuildUpdated(buildIndex)
    end
  )

  -- Currency Tracker: Currency update event
  EVENT_MANAGER:RegisterForEvent(
    GAFE.name .. "_Inventory_CurrencyTracker",
    EVENT_CURRENCY_UPDATE,
    function(_, currencyType, _, newAmount, oldAmount, reason)
      GAFE.CurrencyTracker.OnCurrencyUpdate(
        currencyType,
        newAmount,
        oldAmount,
        reason
      )
    end
  )
end

-------------------------------------------------------------------------------
-- Module Registration
-------------------------------------------------------------------------------
GAFE.Inventory = Inventory
