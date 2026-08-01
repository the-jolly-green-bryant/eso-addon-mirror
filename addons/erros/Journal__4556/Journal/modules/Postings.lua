JournalCompanion.Postings = {}

-- ESO listings have a 30-day TTL. The API exposes time-remaining, not posted-at.
local LISTING_TTL = 30 * 86400

-- Session state (mirrors Scanner.lua pattern — incrementing session invalidates stale callbacks).
local traderOpen = false
local session    = 0
local AUTO_DELAY = 800  -- ms; fallback delay if listings are available synchronously on open

-- Context captured the instant the trader window opens (or the guild selection changes).
-- Only accurate for the physical trader the player is at.
local openTraderGuildKey = nil
local openTraderName     = nil
local openTraderZone     = nil

-- Returns "NA" or "EU" based on the active megaserver.
-- GetWorldName() returns the internal server identifier; EU megaserver names contain "eu".
local function GetRegion()
  local world = GetWorldName and GetWorldName() or ""
  if world:lower():find("eu") then return "EU" end
  return "NA"
end

-- Aggregates listing counts, guild count, and total gold across all saved postings.
local function ComputeStats()
  local sv            = JournalCompanion.sv
  local totalListings = 0
  local guildCount    = 0
  local totalGold     = 0
  for _, g in pairs(sv.postings.guilds) do
    guildCount = guildCount + 1
    for _, listing in ipairs(g.listings) do
      totalListings = totalListings + 1
      totalGold     = totalGold + (listing.price or 0)
    end
  end
  return totalListings, guildCount, totalGold
end

-- Refreshes the open-trader context (guild key, trader NPC, zone).
-- Called on open and again whenever the guild selection changes mid-session.
local function RefreshTraderContext()
  local guildId, _   = GetCurrentTradingHouseGuildDetails()
  openTraderGuildKey = guildId and tostring(guildId) or nil
  openTraderName     = GetUnitName and GetUnitName("interact") or nil
  openTraderZone     = GetPlayerActiveZoneName and GetPlayerActiveZoneName() or nil
end

-- Reads all active sell-listings for the currently selected trading-house guild.
-- Confirmed return order from GetTradingHouseListingItemInfo (verified in-game):
--   icon, itemName, displayQuality, stackCount, accountName, price, timeRemaining, currencyType
-- GetTradingHouseListingTimeRemaining does not exist; position 7 carries timeRemaining.
local function ReadListings()
  local now      = GetTimeStamp()
  local count    = GetNumTradingHouseListings and GetNumTradingHouseListings() or 0
  local listings = {}
  for i = 1, count do
    local _, _, _, stackCount, _, timeRemaining, price, _ = GetTradingHouseListingItemInfo(i)
    local link = GetTradingHouseListingItemLink(i, LINK_STYLE_BRACKETS)
    -- ESO returns some fields as C integer userdata; tostring() first makes tonumber() reliable.
    stackCount    = tonumber(tostring(stackCount))
    price         = tonumber(tostring(price))
    timeRemaining = tonumber(tostring(timeRemaining))
    if link and stackCount and stackCount > 0 and price and price > 0 then
      -- ESO exposes time-remaining, not posted-at.
      -- Back-compute: posted = now − TTL + secondsRemaining (not a real server timestamp).
      local secs   = timeRemaining or 0
      local posted = now - LISTING_TTL + secs
      listings[#listings + 1] = {
        t                = posted,
        link             = link,
        qty              = stackCount,
        price            = price,
        unitPrice        = math.floor(price / stackCount),
        secondsRemaining = secs,
      }
    end
  end
  return listings
end

local function IsPlayerGuild(guildId)
  for i = 1, GetNumGuilds() do
    if GetGuildId(i) == guildId then return true end
  end
  return false
end

-- Scans the currently selected trading-house guild only.
-- Updates just that guild's entry in sv.postings.guilds without touching scannedAt.
local function ScanSingleGuild()
  -- VERIFY: GetCurrentTradingHouseGuildDetails return order (guildId, guildName) at wiki.esoui.com
  local guildId, guildName = GetCurrentTradingHouseGuildDetails()
  if not guildId then return end
  if not IsPlayerGuild(guildId) then return end

  local key    = tostring(guildId)
  local region = GetRegion()
  local sv     = JournalCompanion.sv

  -- Region consistency guard: mixing NA and EU data in one table is a bug, not a feature.
  if sv.postings.region and sv.postings.region ~= region then
    d("|cC9A24AJournal:|r Region mismatch in postings data. Run /journal postings scan to reset.")
    return
  end

  local now = GetTimeStamp()
  sv.postings.guilds[key] = {
    name       = guildName or "",
    hasTrader  = true,
    traderName = openTraderName,
    traderZone = openTraderZone,
    scannedAt  = now,
    listings   = ReadListings(),
  }
  sv.postings.scannedAt = now

  if not sv.postings.region then
    sv.postings.region = region
  end
end

-- Full scan: iterate every guild with a hired trader this week.
-- Wholesale-replaces sv.postings.guilds and updates the top-level scannedAt.
-- Called by /journal postings scan; requires the trader window to be open.
function JournalCompanion.Postings.ScanAll()
  if not traderOpen then
    d("|cC9A24AJournal:|r Open a guild trader first.")
    return
  end

  -- VERIFY: GetNumTradingHouseGuilds at wiki.esoui.com
  local numGuilds = GetNumTradingHouseGuilds and GetNumTradingHouseGuilds() or 0
  if numGuilds == 0 then
    d("|cC9A24AJournal:|r No guilds with a hired trader found.")
    return
  end

  local region     = GetRegion()
  local newGuilds  = {}
  local totalCount = 0

  for i = 1, numGuilds do
    -- VERIFY: SelectTradingHouseGuildId takes a 1-based index at wiki.esoui.com
    SelectTradingHouseGuildId(i)
    local guildId, guildName = GetCurrentTradingHouseGuildDetails()
    if guildId then
      local key      = tostring(guildId)
      local listings = ReadListings()
      totalCount     = totalCount + #listings
      -- traderName/traderZone are only reliable for the physical trader the player opened.
      -- Other guilds' trader locations are unknown from this scan context (no third-party lib).
      -- TODO v2: capture per-guild trader location via LibGuildStore or similar.
      newGuilds[key] = {
        name       = guildName or "",
        hasTrader  = true,
        traderName = (key == openTraderGuildKey) and openTraderName or nil,
        traderZone = (key == openTraderGuildKey) and openTraderZone or nil,
        scannedAt  = GetTimeStamp(),
        listings   = listings,
      }
    end
  end

  local sv              = JournalCompanion.sv
  sv.postings.guilds    = newGuilds
  sv.postings.scannedAt = GetTimeStamp()
  sv.postings.region    = region

  d(string.format("|cC9A24AJournal:|r Postings scanned. %d listing(s) across %d guild(s).",
    totalCount, numGuilds))
end

-- Returns a compact one-line status string for use in the main /journal status block.
function JournalCompanion.Postings.StatusLine()
  local sv = JournalCompanion.sv
  if sv.postings.scannedAt == 0 then
    return "never scanned"
  end
  local totalListings, guildCount, _ = ComputeStats()
  local elapsed = GetTimeStamp() - sv.postings.scannedAt
  local h = math.floor(elapsed / 3600)
  local m = math.floor((elapsed % 3600) / 60)
  if totalListings == 0 then
    return string.format("0 active · last scanned %dh %dm ago", h, m)
  end
  return string.format("%d listing(s) · %d guild(s) · last scanned %dh %dm ago",
    totalListings, guildCount, h, m)
end

-- Prints a verbose postings summary to chat. Called by /journal postings.
function JournalCompanion.Postings.PrintStatus()
  local sv = JournalCompanion.sv
  if sv.postings.scannedAt == 0 then
    d("|cC9A24AJournal:|r Postings: never scanned")
    return
  end
  local totalListings, guildCount, totalGold = ComputeStats()
  local elapsed = GetTimeStamp() - sv.postings.scannedAt
  local h = math.floor(elapsed / 3600)
  local m = math.floor((elapsed % 3600) / 60)
  d(string.format("|cC9A24AJournal:|r Postings: %d listing(s) · %d guild(s) · %dg · last scanned %dh %dm ago",
    totalListings, guildCount, totalGold, h, m))
end

-- Prints raw API return values to chat. Run this while a trader is open to diagnose
-- whether GetNumTradingHouseListings exists and what GetTradingHouseListingItemInfo returns.
function JournalCompanion.Postings.Debug()
  d("|cC9A24AJournal:|r Postings debug:")
  d(string.format("  traderOpen = %s", tostring(traderOpen)))
  d(string.format("  openTraderGuildKey = %s", tostring(openTraderGuildKey)))

  local fnExists = GetNumTradingHouseListings ~= nil
  d(string.format("  GetNumTradingHouseListings exists = %s", tostring(fnExists)))

  local count = GetNumTradingHouseListings and GetNumTradingHouseListings() or "nil"
  d(string.format("  GetNumTradingHouseListings() = %s", tostring(count)))

  if type(count) == "number" and count > 0 then
    local a, b, c, e, f, g, h_, i_ = GetTradingHouseListingItemInfo(1)
    d(string.format("  listing[1] raw = %s | %s | %s | %s | %s | %s | %s | %s",
      tostring(a), tostring(b), tostring(c), tostring(e),
      tostring(f), tostring(g), tostring(h_), tostring(i_)))
    local link = GetTradingHouseListingItemLink(1, LINK_STYLE_BRACKETS)
    d(string.format("  listing[1] link = %s", tostring(link)))
    local tr = GetTradingHouseListingTimeRemaining and GetTradingHouseListingTimeRemaining(1)
    d(string.format("  GetTradingHouseListingTimeRemaining(1) = %s", tostring(tr)))
  end

  local guildId, guildName = GetCurrentTradingHouseGuildDetails()
  d(string.format("  GetCurrentTradingHouseGuildDetails() = %s | %s",
    tostring(guildId), tostring(guildName)))
end

local function OnTradingHouseOpen()
  traderOpen = true
  RefreshTraderContext()

  -- Ask the server for our sell listings immediately so scanning works regardless of
  -- which tab the user visits. The response fires EVENT_TRADING_HOUSE_RESPONSE_RECEIVED,
  -- which OnTradingHouseResponse handles.
  -- VERIFY: RequestTradingHouseListings at wiki.esoui.com before shipping.
  if RequestTradingHouseListings then
    RequestTradingHouseListings()
  end

  -- Fallback: scan after a short delay in case listings are available synchronously
  -- (already cached from a prior open). Only fires if count > 0 — if the server
  -- response hasn't arrived yet we skip rather than overwriting stored data with
  -- an empty array.
  session = session + 1
  local sid = session
  zo_callLater(function()
    if sid ~= session or not traderOpen then return end
    local count = GetNumTradingHouseListings and GetNumTradingHouseListings() or 0
    if count > 0 then
      ScanSingleGuild()
    end
  end, AUTO_DELAY)
end

-- Fires when the trading house returns any server response: search results, listing updates,
-- guild selection changes, etc. This is the reliable trigger for listing data availability —
-- both on initial open (if listings load async) and when the player switches guilds.
local function OnTradingHouseResponse(_, responseType)
  if not traderOpen then return end

  -- Search result pages belong to Scanner.lua. Skip them here so we don't re-scan on every
  -- page of a price scan (which would be noisy and wasteful).
  if TRADING_HOUSE_RESULT_SEARCH_RESULTS_RECEIVED and
     responseType == TRADING_HOUSE_RESULT_SEARCH_RESULTS_RECEIVED then
    return
  end

  -- Guild context may have changed (player switched guilds in the trader window).
  RefreshTraderContext()
  -- Invalidate any pending zo_callLater callback — this response supersedes it.
  session = session + 1
  ScanSingleGuild()
end

local function OnTradingHouseClose()
  traderOpen = false
  session    = session + 1  -- invalidates any pending auto-scan callback
  openTraderGuildKey = nil
  openTraderName     = nil
  openTraderZone     = nil
end

function JournalCompanion.Postings.Init()
  local ns = JournalCompanion.name .. "_Postings"
  EVENT_MANAGER:RegisterForEvent(ns, EVENT_OPEN_TRADING_HOUSE,              OnTradingHouseOpen)
  EVENT_MANAGER:RegisterForEvent(ns, EVENT_CLOSE_TRADING_HOUSE,             OnTradingHouseClose)
  EVENT_MANAGER:RegisterForEvent(ns, EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, OnTradingHouseResponse)
end
