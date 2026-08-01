local libName, libVersion = "LibGuildStore", 105
local lib = {}
local internal = {}
local mm_sales_data = {}
local att_sales_data = {}
local sales_data = {}
local sr_index = {}
local purchases_data = {}
local pr_index = {}
local listings_data = {}
local lr_index = {}
local posted_items_data = {}
local pir_index = {}
local cancelled_items_data = {}
local cr_index = {}
local sr_index_test = {}
_G["LibGuildStore"] = lib
_G["LibGuildStore_Internal"] = internal
_G["LibGuildStore_MM_SalesData"] = mm_sales_data
_G["LibGuildStore_ATT_SalesData"] = att_sales_data
_G["LibGuildStore_SalesData"] = sales_data
_G["LibGuildStore_SalesIndex"] = sr_index
_G["LibGuildStore_PurchaseData"] = purchases_data
_G["LibGuildStore_PurchaseIndex"] = pr_index
_G["LibGuildStore_ListingsData"] = listings_data
_G["LibGuildStore_ListingsIndex"] = lr_index
_G["LibGuildStore_PostedItemsData"] = posted_items_data
_G["LibGuildStore_PostedItemsIndex"] = pir_index
_G["LibGuildStore_CancelledItemsData"] = cancelled_items_data
_G["LibGuildStore_CancelledItemsIndex"] = cr_index
_G["LibGuildStore_SalesIndex_Test"] = sr_index_test

internal.sr_index_count = 0
internal.pr_index_count = 0
internal.lr_index_count = 0
internal.pir_index_count = 0
internal.cr_index_count = 0

lib.libName = libName
lib.libVersion = libVersion

------------------------------
--- Debugging              ---
------------------------------
internal.show_log = true
internal.loggerName = "LibGuildStore"

local hasViewer = DebugLogViewer ~= nil
local hasLogger = LibDebugLogger ~= nil

if hasLogger then
  internal.logger = LibDebugLogger.Create(internal.loggerName)
end

local function create_log(log_type, log_content)
  if not hasViewer and log_type == "Info" then
    CHAT_ROUTER:AddSystemMessage(log_content)
    return
  end

  if not hasLogger or not internal.logger then return end

  if log_type == "Info" then
    internal.logger:Info(log_content)
    return
  end

  if not internal.show_log then return end

  if log_type == "Debug" then
    internal.logger:Debug(log_content)
  elseif log_type == "Verbose" then
    internal.logger:Verbose(log_content)
  elseif log_type == "Warn" then
    internal.logger:Warn(log_content)
  end
end

local function emit_message(log_type, text)
  if text == "" then
    text = "[Empty String]"
  end
  create_log(log_type, text)
end

local function emit_userdata(log_type, udata)
  local function_limit = 10
  local total_limit = 20
  local function_count = 0
  local entry_count = 0

  local function emit(msg)
    emit_message(log_type, msg)
  end

  local function try(label, obj, fn)
    local ok, res = pcall(fn, obj)
    if ok and res ~= nil then
      emit("  " .. label .. ": " .. tostring(res))
    end
  end

  emit("Userdata: " .. tostring(udata))

  if type(udata) == "userdata" then
    if udata.GetName then try("GetName", udata, udata.GetName) end
    if udata.GetParent then
      try("Parent", udata, function(o)
        local p = o:GetParent()
        return p and p:GetName()
      end)
    end
    if udata.GetOwningWindow then
      try("Owner", udata, function(o)
        local w = o:GetOwningWindow()
        return w and w:GetName()
      end)
    end
    if udata.GetType then try("Type", udata, udata.GetType) end
  end

  local meta = getmetatable(udata)
  if not meta then
    emit("  (No metatable)")
    return
  end

  emit("  (metatable present)")

  local idx = meta.__index
  if type(idx) ~= "table" then
    emit("  __index is " .. type(idx))
    return
  end

  for k, v in pairs(idx) do
    if type(v) == "function" then
      if function_count < function_limit and entry_count < total_limit then
        emit("  Function: " .. tostring(k))
        function_count = function_count + 1
        entry_count = entry_count + 1
      end
    else
      if entry_count < total_limit then
        emit("  " .. tostring(k) .. ": " .. tostring(v))
        entry_count = entry_count + 1
      end
    end

    if entry_count >= total_limit then
      emit("  ... (output truncated due to limit)")
      break
    end
  end
end

local function emit_table(log_type, t, indent, table_history)
  indent = indent or "."
  table_history = table_history or {}

  if t == nil then
    emit_message(log_type, indent .. "[Nil Table]")
    return
  end

  if next(t) == nil then
    emit_message(log_type, indent .. "[Empty Table]")
    return
  end

  if table_history[t] then
    emit_message(log_type, indent .. "[Cycle Detected]")
    return
  end

  table_history[t] = true

  for k, v in pairs(t) do
    local valueType = type(v)

    if valueType == "table" then
      emit_message(log_type, indent .. "(table): " .. tostring(k) .. " = {")
      emit_table(log_type, v, indent .. "  ", table_history)
      emit_message(log_type, indent .. "}")
    elseif valueType == "userdata" then
      emit_message(log_type, indent .. "(userdata): " .. tostring(k) .. " = " .. tostring(v))
      emit_userdata(log_type, v)
    else
      emit_message(log_type, indent .. "(" .. valueType .. "): " .. tostring(k) .. " = " .. tostring(v))
    end
  end
end

local function contains_placeholders(str)
  return type(str) == "string" and str:find("<<%d+>>")
end

local function emit_placeholder_message(log_type, message, ...)
  local formatted_value = ZO_CachedStrFormat(message, ...)
  emit_message(log_type, formatted_value)
end

function internal:dm(log_type, ...)
  if not internal.show_log and log_type ~= "Info" then
    return
  end

  local num_args = select("#", ...)
  if num_args == 0 then return end

  local first_arg = select(1, ...)

  if contains_placeholders(first_arg) then
    emit_placeholder_message(log_type, first_arg, select(2, ...))
    return
  end

  for i = 1, num_args do
    local value = select(i, ...)
    if type(value) == "userdata" then
      emit_userdata(log_type, value)
    elseif type(value) == "table" then
      emit_table(log_type, value)
    else
      emit_message(log_type, tostring(value))
    end
  end
end

-------------------------------------------------
----- early helper                          -----
-------------------------------------------------

function internal:is_in(search_value, search_table)
  for _, v in pairs(search_table) do
    if search_value == v then return true end
    if type(search_value) == "string" then
      if zo_strfind(zo_strlower(v), zo_strlower(search_value)) then return true end
    end
  end
  return false
end

-------------------------------------------------
----- lang setup                            -----
-------------------------------------------------

internal.client_lang = GetCVar("Language.2")
internal.effective_lang = nil
local supported_languages = { "de", "en", "fr", "it", "ru", "tr", }
if internal:is_in(internal.client_lang, supported_languages) then
  internal.effective_lang = internal.client_lang
else
  internal.effective_lang = "en"
end
internal.supported_lang = internal.client_lang == internal.effective_lang

function internal:is_empty_or_nil(t)
  if t == nil or t == MM_STRING_EMPTY then return true end
  return type(t) == "table" and ZO_IsTableEmpty(t) or false
end

-- for main LGS saved vars
internal.saveVarsDefaults = {
  lastReceivedEventID = {},
}
-- These defaults are used with the Lam menu not the startup routine
internal.defaults = {
  -- ["firstRun"] = true not needed when reset
  updateAdditionalText = false,
  historyDepth = 90,
  minItemCount = 20,
  maxItemCount = 5000,
  showGuildInitSummary = false,
  showIndexingSummary = false,
  showTruncateSummary = false,
  minimalIndexing = false,
  useSalesHistory = false,
  overrideMMImport = false,
  historyDepthSL = 60, -- History Depth Shopping List
  historyDepthPI = 180, -- History Depth Posted Items
  historyDepthCI = 180, -- History Depth Canceled Items
  libHistoireScanByTimestamp = false,
}

if not LibGuildStore_SavedVariables then LibGuildStore_SavedVariables = internal.saveVarsDefaults end
internal.LibHistoireListener = { } -- added for debug on 10-31
internal.LibHistoireListenerReady = { } -- added 6-19-22
internal.alertQueue = { }
internal.guildMemberInfo = { }
internal.accountNameByIdLookup = { }
internal.traderIdByNameLookup = { }
internal.itemLinkNameByIdLookup = { }
internal.guildNameByIdLookup = { }
internal.guildStoreSearchResults = { }
internal.guildStoreSales = { } -- holds all sales
internal.guildStoreListings = { } -- holds all listings
internal.verboseLevel = 4
internal.eventsNeedProcessing = {}
internal.timeEstimated = {}
internal.isDatabaseBusy = false
internal.currentGuilds = {}
internal.guildList = ""
internal.newestTime = {}

internal.totalSales = 0
internal.totalPurchases = 0
internal.totalListings = 0
internal.totalPosted = 0
internal.totalCanceled = 0

internal.accountNamesCount = 0
internal.itemLinksCount = 0
internal.guildNamesCount = 0

internal.purchasedItems = nil
internal.purchasedBuyer = nil
internal.listedItems = nil
internal.listedSellers = nil

internal.cancelledItems = nil
internal.cancelledSellers = nil
internal.postedItems = nil
internal.postedSellers = nil

internal.GS_NA_NAMESPACE = "datana"
internal.GS_EU_NAMESPACE = "dataeu"
internal.GS_NA_LIBHISTOIRE_NAMESPACE = "libhistoirena"
internal.GS_EU_LIBHISTOIRE_NAMESPACE = "libhistoireeu"
internal.GS_NA_LISTING_NAMESPACE = "listingsna"
internal.GS_EU_LISTING_NAMESPACE = "listingseu"
internal.GS_NA_PURCHASE_NAMESPACE = "purchasena"
internal.GS_EU_PURCHASE_NAMESPACE = "purchaseeu"
internal.GS_NA_NAME_FILTER_NAMESPACE = "namefilterna"
internal.GS_EU_NAME_FILTER_NAMESPACE = "namefiltereu"
internal.GS_NA_FIRST_RUN_NAMESPACE = "firstRunNa"
internal.GS_EU_FIRST_RUN_NAMESPACE = "firstRunEu"

internal.GS_NA_POSTED_NAMESPACE = "posteditemsna"
internal.GS_EU_POSTED_NAMESPACE = "posteditemseu"
internal.GS_NA_CANCELLED_NAMESPACE = "cancelleditemsna"
internal.GS_EU_CANCELLED_NAMESPACE = "cancelleditemseu"

internal.GS_NA_VISIT_TRADERS_NAMESPACE = "visitedNATraders"
internal.GS_EU_VISIT_TRADERS_NAMESPACE = "visitedEUTraders"

internal.GS_NA_PRICING_NAMESPACE = "pricingdatana"
internal.GS_EU_PRICING_NAMESPACE = "pricingdataeu"
internal.GS_ALL_PRICING_NAMESPACE = "pricingdataall"

internal.GS_NA_GUILD_LIST_NAMESPACE = "currentNAGuilds"
internal.GS_EU_GUILD_LIST_NAMESPACE = "currentEUGuilds"

internal.NON_GUILD_MEMBER_PURCHASE = 0
internal.GUILD_MEMBER_PURCHASE = 1
internal.IMPORTED_PURCHASE = 2

internal.GS_CHECK_ACCOUNTNAME = "accountNames"
internal.GS_CHECK_ITEMLINK = "itemLink"
internal.GS_CHECK_GUILDNAME = "guildNames"
internal.PlayerSpecialText = 'hfdkkdfunlajjamdhsiwsuwj'

internal.dataNamespace = ""
internal.libHistoireNamespace = ""
internal.listingsNamespace = ""
internal.purchasesNamespace = ""
internal.firstrunNamespace = ""
internal.postedNamespace = ""
internal.cancelledNamespace = ""
internal.visitedNamespace = ""
internal.pricingNamespace = ""
internal.nameFilterNamespace = ""
internal.guildListNamespace = ""

lib.guildStoreReady = false -- when no more events are pending

--[[TODO
local currencyFormatDealOptions = {
    [0] = { color = ZO_ColorDef:New(0.98, 0.01, 0.01) },
    [ITEM_DISPLAY_QUALITY_NORMAL] = { color = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, ITEM_DISPLAY_QUALITY_NORMAL)) },
--- the other qualities
}
]]--
internal.potionVarientTable = {
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
