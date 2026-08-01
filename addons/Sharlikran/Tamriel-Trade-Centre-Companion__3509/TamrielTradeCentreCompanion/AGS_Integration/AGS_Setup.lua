function TTCCompanion:initAGSIntegration()
  if AwesomeGuildStore.GetAPIVersion == nil then return end
  if AwesomeGuildStore.GetAPIVersion() ~= 4 then return end

  local FILTER_ID = AwesomeGuildStore:GetFilterIds()

  local DealFilter = TTCCompanion.InitDealFilterClass()
  local DealFilterFragment = TTCCompanion.InitDealFilterFragmentClass()

  local ProfitFilter = TTCCompanion.InitProfitFilterClass()

  AwesomeGuildStore:RegisterCallback(AwesomeGuildStore.callback.AFTER_FILTER_SETUP,
    function(...)
      AwesomeGuildStore:RegisterSortOrder(TTCCompanion.SortOrderDealPercent:New())
      AwesomeGuildStore:RegisterFilter(DealFilter:New())
      AwesomeGuildStore:RegisterFilterFragment(DealFilterFragment:New(FILTER_ID.MASTER_MERCHANT_DEAL_FILTER))
      AwesomeGuildStore:RegisterFilter(ProfitFilter:New())
      AwesomeGuildStore:RegisterFilterFragment(AwesomeGuildStore.class.PriceRangeFilterFragment:New(FILTER_ID.MASTER_MERCHANT_DEAL_SELECTOR))
    end
  )
end

