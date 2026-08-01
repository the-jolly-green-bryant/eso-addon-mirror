JournalCompanion.Pricing = {}

local STALE_THRESHOLD_SECS = 24 * 60 * 60  -- 24 hours

-- Internal state populated by Init(). Nil until Init() runs.
local priceData   = nil   -- raw prices table from JournalPrices SavedVars
local generatedAt = nil   -- epoch seconds from JournalPrices.generatedAt
local isStale     = false -- data exists but is older than STALE_THRESHOLD_SECS
local isAvailable = false -- data is loaded, fresh, and safe to query

-- ── Helpers ──────────────────────────────────────────────────────────────────

local function CountTableKeys(t)
  local n = 0
  for _ in pairs(t) do n = n + 1 end
  return n
end

-- ── Settings panel ────────────────────────────────────────────────────────────

local function RegisterSettings()
  local LAM = LibAddonMenu2
  if not LAM then return end

  LAM:RegisterAddonPanel("JournalCompanionSettings", {
    type         = "panel",
    name         = "Journal",
    displayName  = "|cC9A24AJournal|r",
    author       = "erros.gg",
    version      = JournalCompanion.version,
    registerForRefresh = true,
  })

  LAM:RegisterOptionControls("JournalCompanionSettings", {
    {
      type = "header",
      name = "Reminders",
    },
    {
      type    = "checkbox",
      name    = "Remind me to upload",
      tooltip = "Shows a reminder in chat every 3 days when you have records on file.",
      getFunc = function() return JournalCompanion.sv.uploadNudgeEnabled end,
      setFunc = function(value) JournalCompanion.sv.uploadNudgeEnabled = value end,
      default = true,
    },
    {
      type = "header",
      name = "In-Game Prices",
    },
    {
      type    = "checkbox",
      name    = "Show Journal price on chat links",
      tooltip = "Right-click context menus include 'Link with Journal price', inserting the item link with current market price and weekly sales count.",
      getFunc = function() return JournalCompanion.sv.chatLinkEnabled end,
      setFunc = function(value) JournalCompanion.sv.chatLinkEnabled = value end,
      default = true,
    },
    {
      type    = "checkbox",
      name    = "Show Journal price on tooltips",
      tooltip = "When enabled, item tooltips display the median price and weekly sales count from Journal.",
      getFunc = function() return JournalCompanion.sv.tooltipEnabled end,
      setFunc = function(value) JournalCompanion.sv.tooltipEnabled = value end,
      default = true,
    },
    {
      type    = "checkbox",
      name    = "Use Journal prices in inventory value column",
      tooltip = "When enabled, the inventory value column shows Journal market prices. Changes take effect immediately.",
      getFunc = function() return JournalCompanion.sv.inventoryValueEnabled end,
      setFunc = function(value)
        JournalCompanion.sv.inventoryValueEnabled = value
        JournalCompanion.InventoryValue.Refresh()
      end,
      default = true,
    },
  })
end

-- ── Public API ────────────────────────────────────────────────────────────────

function JournalCompanion.Pricing.Init()
  RegisterSettings()

  -- JournalPrices is a plain global set by ESO loading JournalPrices.lua from
  -- the SavedVariables directory. It is written by the Journal Companion app,
  -- not by this addon. If the companion was never run the global will be nil.
  local sv = JournalPrices

  if type(sv) ~= "table" or type(sv.prices) ~= "table" then
    return  -- missing or corrupted; leave all state at defaults (nil/false)
  end

  local age = GetTimeStamp() - (sv.generatedAt or 0)

  priceData   = sv.prices
  generatedAt = sv.generatedAt

  if age > STALE_THRESHOLD_SECS then
    isStale     = true
    isAvailable = false
  else
    isStale     = false
    isAvailable = true
  end
end

-- LookupPrice(idOrLink) → (price, sales) or nil
--
-- Accepts either a numeric item ID or an ESO item link string. Returns data
-- even when the price file is stale so callers can still display a price and
-- separately warn about staleness via DataIsStale() / DataAgeHours().
function JournalCompanion.Pricing.LookupPrice(idOrLink)
  if not priceData then return nil end

  local itemId
  local t = type(idOrLink)
  if t == "number" then
    itemId = idOrLink
  elseif t == "string" then
    itemId = GetItemLinkItemId(idOrLink)
    if not itemId or itemId == 0 then return nil end
  else
    return nil
  end

  local entry = priceData[itemId]
  if not entry then return nil end

  return entry.price, entry.sales
end

-- HasPriceFile() → bool  (true when JournalPrices was loaded; false means companion has never run)
function JournalCompanion.Pricing.HasPriceFile()
  return priceData ~= nil
end

-- DataIsStale() → bool  (true when data is loaded but older than STALE_THRESHOLD_SECS)
function JournalCompanion.Pricing.DataIsStale()
  return isStale
end

-- DataAgeHours() → number or nil  (whole hours since generatedAt; nil if no data)
function JournalCompanion.Pricing.DataAgeHours()
  if not generatedAt or generatedAt == 0 then return nil end
  return math.floor((GetTimeStamp() - generatedAt) / 3600)
end

-- GetStatus() → table  (consumed by /journal slash command)
--
-- Returns a structured status table so the caller can format the line
-- consistently with other status output. Never raises — safe to call at any
-- point after Init().
function JournalCompanion.Pricing.GetStatus()
  if not priceData then
    return {
      state   = "missing",
      message = "not available — install Journal Companion",
    }
  end

  local itemCount = CountTableKeys(priceData)

  if isStale then
    local hoursAgo = math.floor((GetTimeStamp() - generatedAt) / 3600)
    return {
      state      = "stale",
      message    = string.format("stale, last updated %dh ago (%d items)", hoursAgo, itemCount),
      generatedAt = generatedAt,
      itemCount  = itemCount,
    }
  end

  local minutesAgo = math.floor((GetTimeStamp() - generatedAt) / 60)
  return {
    state      = "fresh",
    message    = string.format("current as of %dm ago (%d items)", minutesAgo, itemCount),
    generatedAt = generatedAt,
    itemCount  = itemCount,
  }
end
