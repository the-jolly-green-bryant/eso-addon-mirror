-------------------------------------------------------------------------------
-- TTC Price Module
-- Replaces inventory prices with TTC market prices and adds profit margin
-- display in guild store search results.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Localized Globals
-------------------------------------------------------------------------------
local AwesomeGuildStore = AwesomeGuildStore
local CURT_MONEY = CURT_MONEY
local GetItemLink = GetItemLink
local MasterMerchant = MasterMerchant
local TamrielTradeCentre = TamrielTradeCentre
local TamrielTradeCentrePrice = TamrielTradeCentrePrice
local ZO_CurrencyControl_SetSimpleCurrency = ZO_CurrencyControl_SetSimpleCurrency

local GAFE = GroupActivityFinderExtensions

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------
-- Use nil for currency options to let ESO use its defaults
-- Custom options require complete fields including color functions

-- Profit margin thresholds and colors
local MARGIN_THRESHOLDS = {
  { threshold = 0.65, color = "|cFFD700" }, -- Gold: > 65%
  { threshold = 0.50, color = "|c9e2df4" }, -- Purple: 50-65%
  { threshold = 0.35, color = "|c398df7" }, -- Blue: 35-50%
  { threshold = 0.20, color = "|c32CD32" }, -- Green: 20-35%
}
local MIN_PROFIT_AMOUNT = 3000
local COLOR_END = "|r"
local PRICE_THRESHOLDS = {
  { threshold = 100000, color = ZO_ColorDef:New(1, 0.843, 0) },         -- Gold: > 100k
  { threshold = 20000,  color = ZO_ColorDef:New(0.620, 0.176, 0.957) }, -- Purple: 20k-100k
  { threshold = 5000,   color = ZO_ColorDef:New(0.224, 0.553, 0.969) }, -- Blue: 5k-20k
  { threshold = 0,      color = ZO_ColorDef:New(0.196, 0.804, 0.196) }, -- Green: < 5k
}
local SELL_PRICE_LABEL_OFFSET_X = -5
local SELL_PRICE_LABEL_OFFSET_Y = -8
local SELL_UNIT_PRICE_LABEL_OFFSET_X = 0
local SELL_UNIT_PRICE_LABEL_OFFSET_Y = 0
local PER_UNIT_LABEL_SUFFIX = "PerUnit"
local COIN_ICON = "|t16:16:EsoUI/Art/currency/currency_gold.dds|t"

-------------------------------------------------------------------------------
-- Module Declaration
-------------------------------------------------------------------------------
local TTCPrice = {}

local originalAgsInitializeResultList

-------------------------------------------------------------------------------
-- Private Functions
-------------------------------------------------------------------------------

--- Gets the color for a given margin value.
--- @param price number The item price
--- @return any color The color code, or nil if below threshold
local function GetPriceColor(price)
  for _, entry in ipairs(PRICE_THRESHOLDS) do
    if price > entry.threshold then
      return entry.color
    end
  end

  return PRICE_THRESHOLDS[#PRICE_THRESHOLDS].color
end

--- Gets the TTC price for an item link.
--- @param itemLink string The item link to look up
--- @return number|nil price The TTC suggested price, or nil if not available
local function GetTTCPrice(itemLink)
  local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(itemLink)

  if not priceInfo then
    return nil
  end

  local ttcPriceSaleAvg = priceInfo.SaleAvg or priceInfo.Avg
  local ttcPriceSuggestedPrice = priceInfo.SuggestedPrice or priceInfo.Avg

  local ttcUnitItemPrice = ttcPriceSuggestedPrice
  if ttcPriceSaleAvg < ttcPriceSuggestedPrice then
    ttcUnitItemPrice = ttcPriceSaleAvg
  end

  if not ttcUnitItemPrice then
    return nil
  end

  return ttcUnitItemPrice
end

local function FitStackLabel(sellPriceControl, stackCount)
  sellPriceControl:ClearAnchors()
  local parent = sellPriceControl:GetParent()

  if stackCount > 1 then
    sellPriceControl:SetAnchor(
      RIGHT,
      parent,
      RIGHT,
      SELL_PRICE_LABEL_OFFSET_X,
      SELL_PRICE_LABEL_OFFSET_Y
    )
  else
    sellPriceControl:SetAnchor(RIGHT,
      parent,
      RIGHT,
      SELL_PRICE_LABEL_OFFSET_X,
      0
    )
  end
end

--- Updates the per-unit price label visibility and content.
--- @param sellPriceControl any The sell price control
--- @param price number The TTC price per unit, or nil to hide
--- @param color any The color to use for the price
local function UpdatePerUnitLabel(sellPriceControl, stackCount, price, color)
  local hidden = stackCount <= 1
  local formattedPrice = ZO_CurrencyControl_FormatCurrency(
    price,
    true
  )
  -- TODO: use ZO_CurrencyTemplate instead of label?
  LibPanicida.Controls.Label(
    sellPriceControl:GetName() .. PER_UNIT_LABEL_SUFFIX,
    sellPriceControl,
    { 87 },
    {
      TOPRIGHT,
      sellPriceControl,
      BOTTOMRIGHT,
      SELL_UNIT_PRICE_LABEL_OFFSET_X,
      SELL_UNIT_PRICE_LABEL_OFFSET_Y
    },
    "ZoFontGameSmall",
    color,
    { TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER },
    "@" .. formattedPrice,
    hidden
  )
end

--- Sets the price control to display TTC price instead of vendor price.
--- @param control any The inventory row control
--- @param slot table The slot data containing bag and slot info
local function SetTTCPrice(control, slot)
  local sellPriceControl = control:GetNamedChild("SellPriceText")
  if not sellPriceControl then
    return
  end

  if MasterMerchant and MasterMerchant.systemSavedVariables and MasterMerchant.systemSavedVariables.replaceInventoryValues then
    -- MasterMerchant has Price override enabled. Restore control to default.

    FitStackLabel(sellPriceControl, 1)
    UpdatePerUnitLabel(sellPriceControl, 1, slot.sellPrice)
    return
  end

  local itemLink = GetItemLink(slot.bagId, slot.slotIndex)
  if not itemLink or not TamrielTradeCentre:IsItemLink(itemLink) then
    FitStackLabel(sellPriceControl, slot.stackCount)
    UpdatePerUnitLabel(sellPriceControl, slot.stackCount, slot.sellPrice)
    return
  end

  local isBound = IsItemLinkBound(itemLink)
  if isBound then
    FitStackLabel(sellPriceControl, slot.stackCount)
    UpdatePerUnitLabel(sellPriceControl, slot.stackCount, slot.sellPrice)
    return
  end

  local ttcPrice = GetTTCPrice(itemLink)
  if not ttcPrice then
    FitStackLabel(sellPriceControl, slot.stackCount)
    UpdatePerUnitLabel(sellPriceControl, slot.stackCount, slot.sellPrice)
    return
  end

  local color = GetPriceColor(ttcPrice)
  ZO_CurrencyControl_SetSimpleCurrency(
    sellPriceControl,
    CURT_MONEY,
    ttcPrice * slot.stackCount,
    {
      showTooltips = false,
      font = ZO_KEYBOARD_CURRENCY_OPTIONS.font,
      iconSide = ZO_KEYBOARD_CURRENCY_OPTIONS.iconSide,
      color = color
    },
    CURRENCY_SHOW_ALL
  )

  FitStackLabel(sellPriceControl, slot.stackCount)
  UpdatePerUnitLabel(sellPriceControl, slot.stackCount, ttcPrice,
    { color.r, color.g, color.b, color.a })
end

--- Gets margin data for an item based on TTC price vs listing price.
--- @param ttcPrice number The TTC price
--- @param listingStackPrice number The current listing price
--- @param listingStackCount number Listing stack count
--- @return number margin The profit margin percentage (0-1)
--- @return number profit The absolute profit amount
local function GetMarginData(ttcPrice, listingStackPrice, listingStackCount)
  local listingPrice = listingStackPrice / listingStackCount
  local profit = ttcPrice - listingPrice
  local margin = profit / ttcPrice

  return margin, profit
end

--- Gets the color for a given margin value.
--- @param margin number The profit margin (0-1)
--- @param profit number The absolute profit amount
--- @return string|nil color The color code, or nil if below threshold
local function GetMarginColor(margin, profit)
  if margin <= 0.20 or profit < MIN_PROFIT_AMOUNT then
    return nil
  end

  for _, entry in ipairs(MARGIN_THRESHOLDS) do
    if margin > entry.threshold then
      return entry.color
    end
  end

  return MARGIN_THRESHOLDS[#MARGIN_THRESHOLDS].color
end

--- Sets up the search result price control with margin indicator.
--- @param rowControl any The search result row control
--- @param slot table The search result data
local function SetTTCMargin(rowControl, slot)
  local priceControl = rowControl:GetNamedChild("Price")
  if not priceControl then
    return
  end

  LibPanicida.Debug.LogLater("SetTTCMargin2")
  local inventorySlot = ZO_InventorySlot_GetInventorySlotComponents(control)
  local slotType = ZO_InventorySlot_GetType(inventorySlot)
  if slotType ~= SLOT_TYPE_TRADING_HOUSE_ITEM_RESULT then
    return
  end

  LibPanicida.Debug.LogLater("SetTTCMargin3")


  local tradingHouseIndex = ZO_Inventory_GetSlotIndex(inventorySlot)
  local itemLink = GetTradingHouseSearchResultItemLink(tradingHouseIndex)
  if not itemLink or not TTC:IsItemLink(link) then
    return
  end
  LibPanicida.Debug.LogLater("SetTTCMargin4")

  local ttcPrice = GetTTCPrice(itemLink)
  if not ttcPrice then
    return
  end
  LibPanicida.Debug.LogLater("SetTTCMargin5")

  local listingStackPrice = slot.purchasePrice
  local stackCount = slot:GetStackCount()
  local margin, profit = GetMarginData(ttcPrice, listingStackPrice, stackCount)


  local color = GetMarginColor(margin, profit)
  if not color then
    return
  end
  LibPanicida.Debug.LogLater("SetTTCMargin5")

  LibPanicida.Debug.LogLater("WORKS")
  local formattedProfit = ZO_CurrencyControl_FormatAndLocalizeCurrency(
    zo_roundToNearest(profit, 0.01),
    profit >= 100000
  )
  local sellPriceText = sellPriceControl:GetText():gsub("|t.-:.-:", "|t14:14:")
  sellPriceControl:SetText(
    color .. "+" .. formattedProfit .. COLOR_END .. " - " .. sellPriceText
  )
end

--- Registers the TTC price callback with the inventory slot hooks.
local function RegisterInventoryCallback()
  GAFE.InventorySlotHooks.RegisterCallback(SetTTCPrice)
end

local function AgsInitializeResulList(self, tradingHouseWrapper, searchManager)
  originalAgsInitializeResultList(self, tradingHouseWrapper, searchManager)
  local dataType = ZO_ScrollList_GetDataTypeTable(self.list.list, 1)
  if dataType then
    ZO_PostHook(
      dataType,
      "setupCallback",
      function(control, slot)
        SetTTCMargin(control, slot)
      end
    )
    -- local baseSetupCallback = dataType.setupCallback
    -- dataType.setupCallback = function(control, data)
    --   baseSetupCallback()
    --   SetTTCMargin(control, data)
    -- end
  end
end

local function InitAGSPriceControl()
  if GAFE.SavedVars.beta then
    originalAgsInitializeResultList = AwesomeGuildStore
        .class
        .SearchResultListWrapper
        .InitializeResultList
    AwesomeGuildStore.class.SearchResultListWrapper.InitializeResultList =
        AgsInitializeResulList
  end
end

--- Initializes AwesomeGuildStore integration if available.
local function InitAGSIntegration()
  if not AwesomeGuildStore then
    return
  end

  InitAGSPriceControl()
  -- -- Register a custom filter after AGS initializes
  -- local function RegisterDealFinderFilter()
  --   local filterClass = AGS.class.ValueRangeFilterBase

  --   if not filterClass then
  --     return
  --   end

  --   local DealFinderFilter = filterClass:Subclass()

  --   function DealFinderFilter:New(...)
  --     return filterClass.New(self, ...)
  --   end

  --   function DealFinderFilter:Initialize()
  --     filterClass.Initialize(
  --       self,
  --       1001, -- Custom local filter ID
  --       "DealFinder",
  --       { TRADING_HOUSE_FILTER_TYPE_PRICE },
  --       { 0, 100 },
  --       GAFE.Loc("TTCPrice_DealFinder"),
  --       GAFE.Loc("TTCPrice_DealFinder_Tooltip")
  --     )
  --     self:SetMinMax(0, 100)
  --   end

  --   function DealFinderFilter:FilterLocalResult(result)
  --     local minMargin = self:GetCurrentMin() / 100
  --     local maxMargin = self:GetCurrentMax() / 100

  --     if minMargin <= 0 and maxMargin >= 1 then
  --       return true
  --     end

  --     local margin, profit = GetMarginData(result.purchasePrice, result.itemLink)
  --     if not margin then
  --       return minMargin <= 0
  --     end

  --     return margin >= minMargin and margin <= maxMargin
  --   end

  --   -- Create and register the filter
  --   local filter = DealFinderFilter:New()
  --   AGS:RegisterFilter(filter)
  -- end

  -- -- Wait for AGS to be ready
  -- if AGS.RegisterCallback then
  --   AGS:RegisterCallback(AGS.callback.INITIALIZED, RegisterDealFinderFilter)
  -- end
end

-------------------------------------------------------------------------------
-- Public Functions
-------------------------------------------------------------------------------

--- Initializes the TTC Price module.
function TTCPrice.Init()
  -- Check if TamrielTradeCentre is available
  if not TamrielTradeCentre or not TamrielTradeCentrePrice then
    return
  end

  -- Check if feature is enabled
  if not GAFE.SavedVars.ttcPrice or not GAFE.SavedVars.ttcPrice.enabled then
    return
  end

  RegisterInventoryCallback()
  InitAGSIntegration()
end

-------------------------------------------------------------------------------
-- Module Registration
-------------------------------------------------------------------------------
GAFE.TTCPrice = TTCPrice
