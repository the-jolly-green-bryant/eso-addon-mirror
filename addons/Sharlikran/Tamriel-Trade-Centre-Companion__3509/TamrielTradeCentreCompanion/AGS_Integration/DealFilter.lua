function TTCCompanion.InitDealFilterClass()

  local AGS = AwesomeGuildStore

  local FilterBase = AGS.class.FilterBase
  local ValueRangeFilterBase = AGS.class.ValueRangeFilterBase

  local FILTER_ID = AGS:GetFilterIds()

  local DealFilter = ValueRangeFilterBase:Subclass()
  TTCCompanion.DealFilter = DealFilter

  function DealFilter:New(...)
    return ValueRangeFilterBase.New(self, ...)
  end

  function DealFilter:Initialize()
    ValueRangeFilterBase.Initialize(self, FILTER_ID.MASTER_MERCHANT_DEAL_FILTER, FilterBase.GROUP_SERVER, {
      -- TRANSLATORS: label of the deal filter
      label = GetString(AGS_DEAL_RANGE_LABEL),
      min = 1,
      max = 6,
      steps = {
        {
          id = 1,
          label = GetString(AGS_OVERPRICED_LABEL),
          icon = "TamrielTradeCentreCompanion/img/overpriced_%s.dds",
        },
        {
          id = 2,
          label = GetString(AGS_OKAY_LABEL),
          icon = "TamrielTradeCentreCompanion/img/normal_%s.dds",
        },
        {
          id = 3,
          label = GetString(AGS_REASONABLE_LABEL),
          icon = "TamrielTradeCentreCompanion/img/magic_%s.dds",
        },
        {
          id = 4,
          label = GetString(AGS_GOOD_LABEL),
          icon = "TamrielTradeCentreCompanion/img/arcane_%s.dds",
        },
        {
          id = 5,
          label = GetString(AGS_GREAT_LABEL),
          icon = "TamrielTradeCentreCompanion/img/artifact_%s.dds",
        },
        {
          id = 6,
          label = GetString(AGS_BUYIT_LABEL),
          icon = "TamrielTradeCentreCompanion/img/legendary_%s.dds",
        }
      }
    })

    function DealFilter:CanFilter(subcategory)
      return true
    end

    local dealById = {}
    for i = 1, #self.config.steps do
      local step = self.config.steps[i]
      dealById[step.id] = step
    end
    self.dealById = dealById
  end

  function DealFilter:FilterLocalResult(result)
    local index = result.itemUniqueId
    local itemLink = GetTradingHouseSearchResultItemLink(index)
    local dealValue, margin, profit = TTCCompanion.GetDealInformation(itemLink, result.purchasePrice, result.stackCount)
    return not ((dealValue or -5) + 1 < self.localMin or (dealValue or 5) + 1 > self.localMax)
  end

  function DealFilter:GetTooltipText(min, max)
    if (min ~= self.config.min or max ~= self.config.max) then
      local out = {}
      for id = min, max do
        local step = self.dealById[id]
        out[#out + 1] = step.label
      end
      return table.concat(out, ", ")
    end
    return ""
  end

  return DealFilter
end

function TTCCompanion.InitProfitFilterClass()

  local AGS = AwesomeGuildStore

  local FilterBase = AGS.class.FilterBase
  local ValueRangeFilterBase = AGS.class.ValueRangeFilterBase

  local FILTER_ID = AGS:GetFilterIds()

  local MIN_PROFIT = 1
  local MAX_PROFIT = 2100000000

  local ProfitFilter = ValueRangeFilterBase:Subclass()
  TTCCompanion.ProfitFilter = ProfitFilter

  function ProfitFilter:New(...)
    return ValueRangeFilterBase.New(self, ...)
  end

  function ProfitFilter:Initialize()
    ValueRangeFilterBase.Initialize(self, FILTER_ID.MASTER_MERCHANT_DEAL_SELECTOR, FilterBase.GROUP_SERVER, {
      -- TRANSLATORS: label of the profit filter
      label = GetString(AGS_PROFIT_RANGE_LABEL),
      currency = CURT_MONEY,
      min = MIN_PROFIT,
      max = MAX_PROFIT,
      precision = 0,
      steps = { MIN_PROFIT, 10, 50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000, 50000, 100000, MAX_PROFIT },
    })

    function ProfitFilter:CanFilter(subcategory)
      return true
    end
  end

  function ProfitFilter:FilterLocalResult(result)
    local index = result.itemUniqueId
    local itemLink = GetTradingHouseSearchResultItemLink(index)
    local dealValue, margin, profit = TTCCompanion.GetDealInformation(itemLink, result.purchasePrice, result.stackCount)

    if not profit or (profit < (self.localMin or MIN_PROFIT)) or (profit > (self.localMax or MAX_PROFIT)) then
      return false
    end
    return true
  end

  return ProfitFilter
end

function TTCCompanion.CustomDealCalc(setPrice, salesCount, purchasePrice, stackCount)
  local deal = TTCC_DEAL_VALUE_DONT_SHOW
  local margin = 0
  local profit = -1
  if (setPrice) then
    local unitPrice = purchasePrice / stackCount
    profit = (setPrice - unitPrice) * stackCount
    margin = tonumber(string.format('%.2f', ((setPrice - unitPrice) / setPrice) * 100))

    if (margin >= TTCCompanion.savedVariables.customDealBuyIt) then
      deal = TTCC_DEAL_VALUE_BUYIT
    elseif (margin >= TTCCompanion.savedVariables.customDealSeventyFive) then
      deal = TTCC_DEAL_VALUE_GREAT
    elseif (margin >= TTCCompanion.savedVariables.customDealFifty) then
      deal = TTCC_DEAL_VALUE_GOOD
    elseif (margin >= TTCCompanion.savedVariables.customDealTwentyFive) then
      deal = TTCC_DEAL_VALUE_REASONABLE
    elseif (margin >= TTCCompanion.savedVariables.customDealZero) then
      deal = TTCC_DEAL_VALUE_OKAY
    else
      deal = TTCC_DEAL_VALUE_OVERPRICED
    end
  else
    -- No sales seen
    margin = nil
  end
  return deal, margin, profit
end

function TTCCompanion.DealCalculator(setPrice, salesCount, purchasePrice, stackCount)
  if TTCCompanion.savedVariables.customDealCalc then
    return TTCCompanion.CustomDealCalc(setPrice, salesCount, purchasePrice, stackCount)
  end

  local deal = TTCC_DEAL_VALUE_DONT_SHOW
  local margin = 0
  local profit = -1
  if (setPrice) then
    local unitPrice = purchasePrice / stackCount
    profit = (setPrice - unitPrice) * stackCount
    margin = tonumber(string.format('%.2f', ((setPrice - unitPrice) / setPrice) * 100))

    margin = (margin or 0)
    profit = (profit or 0)
    unitPrice = (unitPrice or 0)

    if (salesCount > 15) then
      -- high volume margins
      if (margin >= 85) then
        deal = TTCC_DEAL_VALUE_BUYIT
      elseif (margin >= 65 and profit >= 1000) then
        deal = TTCC_DEAL_VALUE_BUYIT
      elseif (margin >= 50 and profit >= 3000) then
        deal = TTCC_DEAL_VALUE_BUYIT
      elseif (margin >= 50 and profit >= 500) then
        deal = TTCC_DEAL_VALUE_GREAT
      elseif (margin >= 35 and profit >= 3000) then
        deal = TTCC_DEAL_VALUE_GREAT
      elseif (margin >= 35 and profit >= 100) then
        deal = TTCC_DEAL_VALUE_GOOD
      elseif (margin >= 20) then
        deal = TTCC_DEAL_VALUE_REASONABLE
      elseif (margin >= -2.5) then
        deal = TTCC_DEAL_VALUE_OKAY
      else
        deal = TTCC_DEAL_VALUE_OVERPRICED
      end
    elseif (salesCount > 5) then
      -- mid volume margins
      if (margin >= 85) then
        deal = TTCC_DEAL_VALUE_BUYIT
      elseif (margin >= 80 and profit >= 1000) then
        deal = TTCC_DEAL_VALUE_BUYIT
      elseif (margin >= 65 and profit >= 3000) then
        deal = TTCC_DEAL_VALUE_BUYIT
      elseif (margin >= 65 and profit >= 500) then
        deal = TTCC_DEAL_VALUE_GREAT
      elseif (margin >= 50 and profit >= 3000) then
        deal = TTCC_DEAL_VALUE_GREAT
      elseif (margin >= 50 and profit >= 100) then
        deal = TTCC_DEAL_VALUE_GOOD
      elseif (margin >= 30) then
        deal = TTCC_DEAL_VALUE_REASONABLE
      elseif (margin >= -5.0) then
        deal = TTCC_DEAL_VALUE_OKAY
      else
        deal = TTCC_DEAL_VALUE_OVERPRICED
      end
    else
      -- low volume margins
      if (margin >= 90 and profit >= 1000) then
        deal = TTCC_DEAL_VALUE_BUYIT
      elseif (margin >= 75 and profit >= 500) then
        deal = TTCC_DEAL_VALUE_GREAT
      elseif (margin >= 60 and profit >= 100) then
        deal = TTCC_DEAL_VALUE_GOOD
      elseif (margin >= 30) then
        deal = TTCC_DEAL_VALUE_REASONABLE
      elseif (margin >= -7.5) then
        deal = TTCC_DEAL_VALUE_OKAY
      else
        deal = TTCC_DEAL_VALUE_OVERPRICED
      end
    end
  else
    -- No sales seen
    margin = nil
  end

  return deal, margin, profit
end

-- /script d(TTCCompanion.GetDealInformation("|H1:item:182625:4:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", 10000, 2))
-- /script d(TTCCompanion.GetDealInformation("|H1:item:191220:362:50:0:0:0:0:0:0:0:0:0:0:0:0:8:0:0:0:300:0|h|h", 1111, 1))
TTCCompanion.GetDealInformation = function(itemLink, purchasePrice, stackCount)

  local key = string.format("%s_%d_%d", itemLink, purchasePrice, stackCount)
  if (not TTCCompanion.dealInfoCache[key]) then
    local setPrice = nil
    local salesCount = 0
    local priceStats = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
    if TTCCompanion.savedVariables.dealCalcToUse == TTCCompanion.USE_TTC_AVERAGE and priceStats and priceStats.Avg then setPrice = priceStats.Avg end
    if TTCCompanion.savedVariables.dealCalcToUse == TTCCompanion.USE_TTC_SUGGESTED and priceStats and priceStats.SuggestedPrice then setPrice = priceStats.SuggestedPrice end
    if TTCCompanion.savedVariables.dealCalcToUse == TTCCompanion.USE_TTC_SALES and priceStats and priceStats.SaleAvg then setPrice = priceStats.SaleAvg end

    if TTCCompanion.savedVariables.dealCalcToUse == TTCCompanion.USE_TTC_SALES and setPrice and priceStats and priceStats.SaleAvg and priceStats.SaleEntryCount then
      salesCount = priceStats.SaleEntryCount
    elseif setPrice and priceStats and priceStats.EntryCount then
      salesCount = priceStats.EntryCount
    end

    if TTCCompanion.savedVariables.modifiedSuggestedPriceDealCalc and setPrice then setPrice = setPrice * 1.25 end
    TTCCompanion.dealInfoCache[key] = { TTCCompanion.DealCalculator(setPrice, salesCount, purchasePrice, stackCount) }
  end
  return unpack(TTCCompanion.dealInfoCache[key])
end


