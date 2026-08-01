JournalCompanion = JournalCompanion or {}
JournalCompanion.name    = "Journal"
JournalCompanion.version = "0.6.0"

local SAVED_VARS_VERSION = 1

local defaults = {
  version       = SAVED_VARS_VERSION,
  sales         = {},   -- array of { t, link, qty, gold, buyer, guild }
  prices        = {},   -- array of { t, link, unitPrice, guild }
  characters    = {},   -- [displayName] = { knownRecipes = {}, knownMotifs = {} }
  salesLastScan = {},   -- [guildId string] = epoch seconds of newest stored event
  lastUpdated   = 0,
  lastNudged         = 0,
  uploadNudgeEnabled = true,
  writ_rewards     = {},   -- array of box or quest_gold records (see Writs.lua)
  postings = {
    scannedAt = 0,
    region    = nil,   -- "NA" | "EU" | nil before first scan
    guilds    = {},    -- [guildIdString] = { name, hasTrader, traderName, traderZone, scannedAt, listings }
  },
  chatLinkEnabled       = true,
  tooltipEnabled        = true,
  inventoryValueEnabled = true,
}

local function PrintStatus()
  local sv = JournalCompanion.sv
  local chars = 0
  local charsWithResearch = 0
  local charsWithAlchemy  = 0
  for _, cd in pairs(sv.characters) do
    chars = chars + 1
    if cd.research     then charsWithResearch = charsWithResearch + 1 end
    if cd.alchemyTraits then charsWithAlchemy  = charsWithAlchemy  + 1 end
  end

  d(string.format("|cC9A24AJournal|r v%s", JournalCompanion.version))
  d(string.format("  Sales: %d  |  Prices: %d  |  Characters: %d", #sv.sales, #sv.prices, chars))
  d(string.format("  Research tracked: %d char(s)  |  Alchemy traits: %d char(s)",
    charsWithResearch, charsWithAlchemy))
  if sv.referenceData and sv.referenceData.researchLines then
    d(string.format("  Reference: %d research lines  |  %d reagents",
      #sv.referenceData.researchLines,
      sv.referenceData.reagents and #sv.referenceData.reagents or 0))
  end
  if sv.lastUpdated > 0 then
    local elapsed = GetTimeStamp() - sv.lastUpdated
    local h = math.floor(elapsed / 3600)
    local m = math.floor((elapsed % 3600) / 60)
    d(string.format("  Last updated: %dh %dm ago", h, m))
  end
  local priceStatus = JournalCompanion.Pricing.GetStatus()
  d(string.format("  Prices: %s", priceStatus.message))
  d(string.format("  Postings: %s", JournalCompanion.Postings.StatusLine()))
end

local function MaybeNudge()
  local sv = JournalCompanion.sv
  if not sv.uploadNudgeEnabled then return end

  local now = GetTimeStamp()
  if (now - sv.lastNudged) < (3 * 86400) then return end

  local recordCount = #sv.sales + #sv.prices
  if recordCount == 0 then return end

  d(string.format("|cC9A24AJournal:|r %d records collected. Upload at journal.erros.gg/dashboard/import — or install the companion to sync automatically.", recordCount))
  sv.lastNudged = now
end

local function OnLoaded(_, addonName)
  if addonName ~= JournalCompanion.name then return end
  EVENT_MANAGER:UnregisterForEvent(JournalCompanion.name, EVENT_ADD_ON_LOADED)

  JournalCompanion.sv = ZO_SavedVars:NewAccountWide(
    "Journal",
    SAVED_VARS_VERSION,
    nil,
    defaults
  )

  JournalCompanion.Sales.Init()
  JournalCompanion.Prices.Init()
  JournalCompanion.Reference.Init()
  JournalCompanion.Knowledge.Init()
  JournalCompanion.Writs.Init()
  JournalCompanion.Pricing.Init()
  JournalCompanion.ChatLink.Init()
  JournalCompanion.Tooltip.Init()
  JournalCompanion.InventoryValue.Init()
  JournalCompanion.Scanner.Init()
  JournalCompanion.Postings.Init()

  EVENT_MANAGER:RegisterForEvent(JournalCompanion.name .. "_Nudge", EVENT_PLAYER_ACTIVATED, function()
    EVENT_MANAGER:UnregisterForEvent(JournalCompanion.name .. "_Nudge", EVENT_PLAYER_ACTIVATED)
    MaybeNudge()
  end)
end

SLASH_COMMANDS["/journal"] = function(args)
  args = args and args:lower():match("^%s*(.-)%s*$") or ""
  if args == "scan" then
    JournalCompanion.Knowledge.Scan()
    d("|cC9A24AJournal:|r Knowledge scan complete (recipes, motifs, research, alchemy traits).")
  elseif args == "debug on" then
    JournalCompanion.Writs.SetDebug(true)
  elseif args == "debug off" then
    JournalCompanion.Writs.SetDebug(false)
  elseif args == "chatlink debug on" then
    JournalCompanion.ChatLink.SetDebug(true)
  elseif args == "chatlink debug off" then
    JournalCompanion.ChatLink.SetDebug(false)
  elseif args == "writs" then
    JournalCompanion.Writs.Status()
  elseif args == "writs clear" then
    JournalCompanion.sv.writ_rewards = {}
    d("|cC9A24AJournal:|r Writ rewards cleared.")
  elseif args == "sales clear" then
    JournalCompanion.sv.sales = {}
    JournalCompanion.sv.salesLastScan = {}
    d("|cC9A24AJournal:|r Sales cleared.")
  elseif args == "prices clear" then
    JournalCompanion.sv.prices = {}
    d("|cC9A24AJournal:|r Prices cleared.")
  elseif args == "listings clear" then
    local removed = JournalCompanion.Prices.PruneAllListings()
    d(string.format("|cC9A24AJournal:|r Removed %d listing record(s).", removed))
  elseif args:sub(1, 16) == "listings clear " then
    local target = args:sub(17)
    local removed = JournalCompanion.Prices.PruneListingsForGuild(target)
    d(string.format("|cC9A24AJournal:|r Removed %d listing record(s) for '%s'.", removed, target))
  elseif args == "knowledge clear" then
    JournalCompanion.sv.characters = {}
    d("|cC9A24AJournal:|r Knowledge cleared.")
  elseif args == "postings scan" then
    JournalCompanion.Postings.ScanAll()
  elseif args == "postings debug" then
    JournalCompanion.Postings.Debug()
  elseif args == "postings" then
    JournalCompanion.Postings.PrintStatus()
  elseif args == "help" then
    d("|cC9A24AJournal|r commands:")
    d("  /journal                 — show status")
    d("  /journal scan            — rescan recipes and motifs")
    d("  /journal postings        — show postings status")
    d("  /journal postings scan   — scan all guild trader listings (trader must be open)")
    d("  /journal writs           — show writ reward record count")
    d("  /journal writs clear     — erase all writ reward records")
    d("  /journal sales clear     — erase all sales records")
    d("  /journal prices clear    — erase all price records")
    d("  /journal listings clear         — erase all guild_listing records")
    d("  /journal listings clear <guild> — erase guild_listing records for one guild")
    d("  /journal knowledge clear — erase all knowledge records")
    d("  /journal debug on        — enable writ event logging")
    d("  /journal debug off       — disable writ event logging")
  else
    PrintStatus()
  end
end



EVENT_MANAGER:RegisterForEvent(JournalCompanion.name, EVENT_ADD_ON_LOADED, OnLoaded)
