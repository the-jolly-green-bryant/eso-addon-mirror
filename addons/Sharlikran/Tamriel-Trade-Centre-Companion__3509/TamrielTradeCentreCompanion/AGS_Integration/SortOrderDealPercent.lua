local AGS = AwesomeGuildStore

local SortOrderBase = nil
local SortOrderDealPercentSubclass = nil
TTCCompanion.SortOrderDealPercent = {}

if AwesomeGuildStore then
  SortOrderBase = AGS.class.SortOrderBase
  SortOrderDealPercentSubclass = SortOrderBase:Subclass()
  TTCCompanion.SortOrderDealPercent = SortOrderDealPercentSubclass
  local DEAL_PERCENT_ORDER = 100
  local DEAL_PERCENT_ORDER_LABEL = GetString(AGS_PERCENT_ORDER_LABEL)

  function TTCCompanion.SortOrderDealPercent:New(...)
    return SortOrderBase.New(self, ...)
  end

  function TTCCompanion.SortOrderDealPercent:Initialize()
    SortOrderBase.Initialize(self, DEAL_PERCENT_ORDER, DEAL_PERCENT_ORDER_LABEL, function(a, b)
      local index = a.itemUniqueId
      local itemLink_a = GetTradingHouseSearchResultItemLink(index)
      index = b.itemUniqueId
      local itemLink_b = GetTradingHouseSearchResultItemLink(index)

      local x, margin_a, x = TTCCompanion.GetDealInformation(itemLink_a, a.purchasePrice, a.stackCount)
      local x, margin_b, x = TTCCompanion.GetDealInformation(itemLink_b, b.purchasePrice, b.stackCount)

      margin_a = margin_a or 0.0001
      margin_b = margin_b or 0.0001
      if (margin_a == margin_b) then return 0 end

      if TTCCompanion.savedVariables.agsPercentSortOrderToUse == TTCCompanion.AGS_PERCENT_ASCENDING then
        return margin_a < margin_b and 1 or -1
      else
        return margin_a > margin_b and 1 or -1
      end
    end)

    self.useLocalDirection = true
  end
end
