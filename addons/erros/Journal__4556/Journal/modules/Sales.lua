JournalCompanion.Sales = {}

local CATEGORY   = GUILD_HISTORY_EVENT_CATEGORY_TRADER
local SALE_TYPE  = GUILD_HISTORY_TRADER_EVENT_ITEM_SOLD
local PRUNE_DAYS = 90

local function EnsureAt(name)
  if name and name:sub(1, 1) ~= "@" then return "@" .. name end
  return name
end

local function ScanGuild(guildId, guildName, since, me)
  local sales  = {}
  local prices = {}
  -- Look up the guild's own kiosk location so guild_sale records are not contaminated
  -- by whatever trading house the player currently has open (currentKiosk in Prices.lua
  -- reflects the open trader, which may be in a different city than this guild's trader).
  local kiosk  = GetGuildOwnedKioskInfo and GetGuildOwnedKioskInfo(guildId) or nil
  local numEvents = GetNumGuildHistoryEvents(guildId, CATEGORY)
  for i = 1, numEvents do
    local eventId, timestampS, _, eventType, seller, buyer, itemLink, quantity, price =
      GetGuildHistoryTraderEventInfo(guildId, i)
    if eventType == SALE_TYPE and timestampS > since then
      local sellerAt = EnsureAt(seller)
      local unitPrice = quantity > 0 and math.floor(price / quantity) or price
      if zo_strlower(sellerAt) == me then
        sales[#sales + 1] = {
          t      = timestampS,
          link   = itemLink,
          name   = GetItemLinkName(itemLink),
          qty    = quantity,
          gold   = price,
          buyer  = EnsureAt(buyer),
          guild  = guildName,
          id     = Id64ToString(eventId),
        }
      end
      -- All completed sales (self and others) are recorded as price observations.
      -- guild_sale outweighs guild_listing in market price calculations.
      prices[#prices + 1] = {
        t       = timestampS,
        link    = itemLink,
        qty     = quantity,
        gold    = price,
        guild   = guildName,
        source  = "guild_sale",
        eventId = Id64ToString(eventId),
        kiosk   = kiosk,
      }
    end
  end
  return sales, prices
end

local function Prune(me)
  local cutoff = GetTimeStamp() - (PRUNE_DAYS * 86400)
  local sv     = JournalCompanion.sv
  local kept   = {}
  for _, sale in ipairs(sv.sales) do
    -- Strip any non-self sales that were stored before the seller filter was added
    local seller = sale.seller and zo_strlower(sale.seller) or ""
    if sale.t >= cutoff and (seller == me or seller == "") then
      kept[#kept + 1] = sale
    end
  end
  sv.sales = kept
end

function JournalCompanion.Sales.Scan()
  local sv        = JournalCompanion.sv
  local me        = zo_strlower(EnsureAt(GetDisplayName()))
  local numGuilds = GetNumGuilds()
  for i = 1, numGuilds do
    local guildId   = GetGuildId(i)
    local guildName = GetGuildName(guildId)
    local key       = tostring(guildId)
    local since     = sv.salesLastScan[key] or 0

    local newSales, newPrices = ScanGuild(guildId, guildName, since, me)
    for _, sale in ipairs(newSales) do
      sv.sales[#sv.sales + 1] = sale
      if sale.t > (sv.salesLastScan[key] or 0) then
        sv.salesLastScan[key] = sale.t
      end
    end
    for _, obs in ipairs(newPrices) do
      JournalCompanion.Prices.Record(obs.link, obs.qty, obs.gold, obs.t, obs.guild, obs.source, obs.eventId, obs.kiosk)
    end
  end

  sv.lastUpdated = GetTimeStamp()
  Prune(me)
end

function JournalCompanion.Sales.Init()
  JournalCompanion.Sales.Scan()

  EVENT_MANAGER:RegisterForEvent(
    JournalCompanion.name .. "_Sales",
    EVENT_GUILD_HISTORY_CATEGORY_UPDATED,
    function(_, guildId, category)
      if category and category ~= CATEGORY then return end
      JournalCompanion.Sales.Scan()
    end
  )
end
