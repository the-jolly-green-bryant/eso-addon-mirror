JournalCompanion.Scanner = {}

-- Per-session state. All fields are reset at the start of each scan.
local scanning   = false  -- true while a scan is in progress
local session    = 0      -- incremented each scan; stale zo_callLater callbacks check this
local page       = 0      -- next page index to request
local startCount = 0      -- sv.prices size before the scan started, for the completion delta

-- ESO enforces a server-side cooldown between trading house search requests.
-- GetTradingHouseCooldownRemaining() returns the exact remaining wait in ms.
-- We add a small buffer so the next request doesn't land before the window fully clears.
local COOLDOWN_BUFFER_MS = 1200
local MIN_DELAY_MS       = 5000

local function NextDelay()
  local remaining = GetTradingHouseCooldownRemaining and GetTradingHouseCooldownRemaining() or 0
  return math.max(remaining + COOLDOWN_BUFFER_MS, MIN_DELAY_MS)
end

-- The button descriptor is defined once. ESO re-evaluates any function fields
-- each time KEYBIND_STRIP:UpdateKeybindButton() is called, so name() reflects
-- the live scanning state without needing a new table.
local scanButton = {
  name      = function()
    if scanning then
      return string.format("Cancel Journal Scan (p.%d)", page)
    end
    return "Journal - Scan Listings"
  end,
  keybind   = "JOURNAL_SCAN_LISTINGS",
  callback  = function()
    if scanning then
      JournalCompanion.Scanner.Stop()
    else
      JournalCompanion.Scanner.Start()
    end
  end,
  enabled   = function() return true end,
  alignment = KEYBIND_STRIP_ALIGN_LEFT,
}

local function UpdateButton()
  KEYBIND_STRIP:UpdateKeybindButton(scanButton)
end

local function RequestPage(sid, pageNum)
  -- If the session changed since this callback was scheduled, the scan was
  -- cancelled; do nothing so the stale request doesn't consume a server cooldown.
  if not scanning or sid ~= session then return end
  ExecuteTradingHouseSearch(pageNum)
end

-- Fired on EVENT_TRADING_HOUSE_RESPONSE_RECEIVED while a scan is active.
-- Prices.lua independently handles data capture from the same event via its own
-- registered handler. Our sole responsibility here is pagination: advance to the
-- next page, or stop when the trader has no more listings to return.
local function OnSearchPage(_, responseType)
  if not scanning then return end

  -- Ignore responses that aren't search result pages (purchase confirmations,
  -- listing management ACKs, etc.). The constant may not exist on all API versions;
  -- if it's absent we fall through and let GetTradingHouseSearchResultsInfo() decide.
  if TRADING_HOUSE_RESULT_SEARCH_RESULTS_RECEIVED and
     responseType ~= TRADING_HOUSE_RESULT_SEARCH_RESULTS_RECEIVED then
    return
  end

  local numResults = GetTradingHouseSearchResultsInfo()
  if not numResults or numResults == 0 then
    -- Empty page means we've read past the last listing.
    scanning = false
    UpdateButton()
    local added = (JournalCompanion.sv and #JournalCompanion.sv.prices or 0) - startCount
    d(string.format("|cC9A24AJournal:|r Scan complete. %d new observations.", added))
    return
  end

  -- Schedule the next page after the server cooldown clears.
  local sid = session
  page = page + 1
  zo_callLater(function()
    RequestPage(sid, page)
  end, NextDelay())

  UpdateButton()
end

function JournalCompanion.Scanner.Start()
  if scanning then return end

  scanning   = true
  session    = session + 1
  page       = 0
  startCount = JournalCompanion.sv and #JournalCompanion.sv.prices or 0

  -- Clear any active search filters before starting. Without this, the scan
  -- would only page through whatever the player last searched for, not all listings.
  if TRADING_HOUSE_SEARCH and TRADING_HOUSE_SEARCH.ResetAllSearchData then
    TRADING_HOUSE_SEARCH:ResetAllSearchData()
  end

  d("|cC9A24AJournal:|r Scanning trader listings.")
  RequestPage(session, page)
  UpdateButton()
end

function JournalCompanion.Scanner.Stop()
  if not scanning then return end
  scanning = false
  UpdateButton()
  d("|cC9A24AJournal:|r Scan stopped.")
end

local function OnTradingHouseOpen()
  KEYBIND_STRIP:AddKeybindButton(scanButton)
end

local function OnTradingHouseClose()
  if scanning then
    -- The trader window closed mid-scan. Stop cleanly; the player can restart
    -- from page 0 next time they open a trader.
    scanning = false
    d("|cC9A24AJournal:|r Scan paused — trader closed.")
  end
  KEYBIND_STRIP:RemoveKeybindButton(scanButton)
end

function JournalCompanion.Scanner.Init()
  local ns = JournalCompanion.name .. "_Scanner"
  EVENT_MANAGER:RegisterForEvent(ns, EVENT_OPEN_TRADING_HOUSE,              OnTradingHouseOpen)
  EVENT_MANAGER:RegisterForEvent(ns, EVENT_CLOSE_TRADING_HOUSE,             OnTradingHouseClose)
  EVENT_MANAGER:RegisterForEvent(ns, EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, OnSearchPage)
end
