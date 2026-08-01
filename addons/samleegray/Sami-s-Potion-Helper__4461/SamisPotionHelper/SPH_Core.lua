SamisPotionHelperAddon = SamisPotionHelperAddon or {}

local SPH = SamisPotionHelperAddon

SPH.name = "SamisPotionHelper"
SPH.displayName = "Sami's Potion Helper"
SPH.version = "1.3.0"
SPH.author = "samihaize"

SPH.savedVariableDefaults = {
  enableDebug = false,
  filterFood = true,
  filterPoisons = true,
  filterMerchantItems = true,
  flagStolenItemsAsTrash = false,
  sellAlliancePotions = false,
  autoSellTrash = false,
  customFilterText = "",
  markedTrashItems = {},
}
