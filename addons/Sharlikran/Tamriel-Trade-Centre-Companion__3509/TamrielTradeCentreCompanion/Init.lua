TTCCompanion = { }
TTCCompanion.name = 'TTCCompanion'
TTCCompanion.addonName = 'TamrielTradeCentreCompanion'
TTCCompanion.version = '1.11'

TTCCompanion.tradingHouseBrowseMarkerHooked = false
TTCCompanion.inventoryMarkersHooked = false
TTCCompanion.tradingHouseOpened = false
TTCCompanion.wwDetected = false
TTCCompanion.mwimDetected = false
TTCCompanion.isInitialized = false
TTCCompanion.coinIcon = "|t16:16:EsoUI/Art/currency/currency_gold.dds|t"
TTCCompanion.removedItemIdTable = {}
TTCCompanion.dealInfoCache = {}
TTCCompanion.pricingNamespace = nil

TTCCompanion.USE_TTC_SUGGESTED = 1
TTCCompanion.USE_TTC_AVERAGE = 2
TTCCompanion.USE_TTC_SALES = 3
TTCCompanion.AGS_PERCENT_ASCENDING = 1
TTCCompanion.AGS_PERCENT_DESCENDING = 2
TTCCompanion.NA_PRICING_NAMESPACE = "pricingdatana"
TTCCompanion.EU_PRICING_NAMESPACE = "pricingdataeu"

-- Deal Value Ranges
TTCC_DEAL_VALUE_DONT_SHOW = -1
TTCC_DEAL_VALUE_OVERPRICED = 0
TTCC_DEAL_VALUE_OKAY = 1
TTCC_DEAL_VALUE_REASONABLE = 2
TTCC_DEAL_VALUE_GOOD = 3
TTCC_DEAL_VALUE_GREAT = 4
TTCC_DEAL_VALUE_BUYIT = 5

if AwesomeGuildStore then
  TTCCompanion.AwesomeGuildStoreDetected = true -- added 12-2
else
  TTCCompanion.AwesomeGuildStoreDetected = false -- added 12-2
end

TTCCompanion.show_log = false
if LibDebugLogger then
  TTCCompanion.logger = LibDebugLogger.Create(TTCCompanion.name)
end
local logger
local viewer
if DebugLogViewer then viewer = true else viewer = false end
if LibDebugLogger then logger = true else logger = false end

local function create_log(log_type, log_content)
  if not viewer and log_type == "Info" then
    CHAT_ROUTER:AddSystemMessage(log_content)
    return
  end
  if not TTCCompanion.show_log then return end
  if logger and log_type == "Debug" then
    TTCCompanion.logger:Debug(log_content)
  end
  if logger and log_type == "Info" then
    TTCCompanion.logger:Info(log_content)
  end
  if logger and log_type == "Verbose" then
    TTCCompanion.logger:Verbose(log_content)
  end
  if logger and log_type == "Warn" then
    TTCCompanion.logger:Warn(log_content)
  end
end

local function emit_message(log_type, text)
  if (text == "") then
    text = "[Empty String]"
  end
  create_log(log_type, text)
end

local function emit_table(log_type, t, indent, table_history)
  indent = indent or "."
  table_history = table_history or {}

  for k, v in pairs(t) do
    local vType = type(v)

    emit_message(log_type, indent .. "(" .. vType .. "): " .. tostring(k) .. " = " .. tostring(v))

    if (vType == "table") then
      if (table_history[v]) then
        emit_message(log_type, indent .. "Avoiding cycle on table...")
      else
        table_history[v] = true
        emit_table(log_type, v, indent .. "  ", table_history)
      end
    end
  end
end

function TTCCompanion:dm(log_type, ...)
  for i = 1, select("#", ...) do
    local value = select(i, ...)
    if (type(value) == "table") then
      emit_table(log_type, value)
    else
      emit_message(log_type, tostring(value))
    end
  end
end

TTCCompanion.potionVarientTable = {
  [0] = 0,
  [1] = 0,
  [3] = 1,
  [10] = 2,
  [19] = 2, -- level 19 pots I found
  [20] = 3,
  [24] = 3, -- level 24 pots I found
  [30] = 4,
  [39] = 4, -- level 39 pots I found
  [40] = 5,
  [44] = 5, -- level 44 pots I found
  [125] = 6,
  [129] = 7,
  [134] = 8,
  [307] = 9, -- health potion I commonly find
  [308] = 9,
}
