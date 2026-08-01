local SPH = SamisPotionHelperAddon
local LAM2 = LibAddonMenu2
local SPHUtils = SPH.utils

function SPH.InitializeSettings()
  local panelData = {
    type = "panel",
    name = SPH.name,
    displayName = SPH.displayName,
    author = SPH.author,
    version = SPH.version,
    registerForRefresh = true,
    registerForDefaults = true,
  }

  local optionsPanel = LAM2:RegisterAddonPanel(SPH.name .. "Options", panelData)

  local optionsData = {
    {
      type = "description",
      text = "Configure the settings for Samis Potion Helper.",
    },
    {
      type = "checkbox",
      name = "Enable Debug",
      tooltip = "Toggle debug messages.",
      getFunc = function() return SPH.savedVariables.enableDebug end,
      setFunc = function(value) SPH.savedVariables.enableDebug = value end,
      default = false,
    },
    {
      type = "checkbox",
      name = "Filter Food & Drink",
      tooltip = "Also filter crafted food and junk non-crafted food and drink.",
      getFunc = function() return SPH.savedVariables.filterFood end,
      setFunc = function(value)
        SPH.savedVariables.filterFood = value
        SPHUtils.syncSavedVarsToUtils()
      end,
      default = true,
    },
    {
      type = "checkbox",
      name = "Filter Poisons",
      tooltip = "Also junk non-crafted poison items.",
      getFunc = function() return SPH.savedVariables.filterPoisons end,
      setFunc = function(value)
        SPH.savedVariables.filterPoisons = value
        SPHUtils.syncSavedVarsToUtils()
      end,
      default = true,
    },
    {
      type = "checkbox",
      name = "Sell Alliance Potions",
      tooltip = "If enabled, non-crafted Alliance War potions can be junked/sold.",
      getFunc = function() return SPH.savedVariables.sellAlliancePotions end,
      setFunc = function(value)
        SPH.savedVariables.sellAlliancePotions = value
        SPHUtils.syncSavedVarsToUtils()
      end,
      default = true,
    },
    {
      type = "checkbox",
      name = "Filter Merchant Items",
      tooltip = "Also junk non-crafted sellable merchant trash items.",
      getFunc = function() return SPH.savedVariables.filterMerchantItems end,
      setFunc = function(value)
        SPH.savedVariables.filterMerchantItems = value
        SPHUtils.syncSavedVarsToUtils()
      end,
      default = true,
    },
    {
      type = "checkbox",
      name = "Flag Stolen Items As Trash",
      tooltip = "If disabled, stolen items will never be marked as junk.",
      getFunc = function() return SPH.savedVariables.flagStolenItemsAsTrash end,
      setFunc = function(value)
        SPH.savedVariables.flagStolenItemsAsTrash = value
      end,
      default = false,
    },
    {
      type = "checkbox",
      name = "Auto Sell Trash Items",
      tooltip = "Automatically sell junk items when opening a merchant store.",
      getFunc = function() return SPH.savedVariables.autoSellTrash end,
      setFunc = function(value)
        SPH.savedVariables.autoSellTrash = value
        SPH.RegisterEvents()
      end,
      default = false,
    },
    {
      type = "editbox",
      name = "Custom Filter",
      tooltip =
      "Enter item names to filter (separated by commas). Items containing any of these texts will *NOT* be marked as junk. Example: 'grand, draught, health' will protect items with 'grand', 'draught', or 'health' in their name.",
      getFunc = function() return SPH.savedVariables.customFilterText end,
      setFunc = function(value)
        SPH.savedVariables.customFilterText = value
        SPHUtils.syncSavedVarsToUtils()
      end,
      multiline = true,
      width = "full",
      isExtraWide = true,
      default = "",
    },
  }

  LAM2:RegisterOptionControls(SPH.name .. "Options", optionsData)
end
