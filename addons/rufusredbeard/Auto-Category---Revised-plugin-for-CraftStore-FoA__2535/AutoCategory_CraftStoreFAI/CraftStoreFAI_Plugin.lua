-- A very simple plugin for AutoCategory - Revised that adds a function to lookup if items
-- are saved for research by CraftStoreFixedAndImproved.

AutoCategory_CraftStoreFAI = {
  RuleFunc = {},
}

local AC = AutoCategory
local CS = CraftStoreFixedAndImprovedLongClassName

--Initialize plugin for Auto Category - CraftStoreFixedAndImproved
function AutoCategory_CraftStoreFAI.Initialize()
  if not CS then
    AC.AddRuleFunc("issavedforcraftstore", AC.dummyRuleFunc)
  else
    AC.AddRuleFunc("issavedforcraftstore", AutoCategory_CraftStoreFAI.RuleFunc.IsSavedForCraftStore)
  end
end

-- Implement issavedforcraftstore() check function for CraftStore Fixed and Improved
function AutoCategory_CraftStoreFAI.RuleFunc.IsSavedForCraftStore( ... )
  if CS == nil then
    return false
  end
  local itemID = Id64ToString(GetItemUniqueId(AC.checkingItemBagId, AC.checkingItemSlotIndex))
  local isStored = CS.IsItemStoredForCraftStore(itemID)
  -- if isStored then
  --   local itemLink = GetItemLink(AC.checkingItemBagId, AC.checkingItemSlotIndex)
  --   df("Item Stored for CraftStore : %s ID : %s", itemLink, itemID)
  --   d(CS.IsResearchable(itemLink, false))
  -- end
  return isStored
end

-- Register this plugin with AutoCategory to be initialized and used when AutoCategory loads.
AC.RegisterPlugin("CraftStoreFAI", AutoCategory_CraftStoreFAI.Initialize)