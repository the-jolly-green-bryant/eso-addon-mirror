JournalCompanion.Prices = {}

local PRUNE_DAYS  = 30
local MAX_PRICES  = 25000
local DAY_SECONDS = 86400
local currentGuildName = ""
local currentKiosk     = nil

-- Dedup index: "itemId|dayBucket|source|unitPrice|guild" = true. Rebuilt on load from sv.prices.
local seen = {}

local QUALITY_DB = {
  [ITEM_QUALITY_NORMAL]    = "normal",
  [ITEM_QUALITY_MAGIC]     = "fine",
  [ITEM_QUALITY_ARCANE]    = "superior",
  [ITEM_QUALITY_ARTIFACT]  = "epic",
  [ITEM_QUALITY_LEGENDARY] = "legendary",
}

local TRAIT_DB = {
  -- Armor
  [ITEM_TRAIT_TYPE_ARMOR_STURDY]         = "sturdy",
  [ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED]    = "well_fitted",
  [ITEM_TRAIT_TYPE_ARMOR_TRAINING]       = "training",
  [ITEM_TRAIT_TYPE_ARMOR_INFUSED]        = "infused",
  [ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE]   = "impenetrable",
  [ITEM_TRAIT_TYPE_ARMOR_REINFORCED]     = "reinforced",
  [ITEM_TRAIT_TYPE_ARMOR_DIVINES]        = "divines",
  [ITEM_TRAIT_TYPE_ARMOR_NIRNHONED]      = "nirnhoned",
  [ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS]     = "prosperous",
  [ITEM_TRAIT_TYPE_ARMOR_INTRICATE]      = "intricate",
  [ITEM_TRAIT_TYPE_ARMOR_ORNATE]         = "ornate",
  -- Weapons
  [ITEM_TRAIT_TYPE_WEAPON_POWERED]       = "powered",
  [ITEM_TRAIT_TYPE_WEAPON_CHARGED]       = "charged",
  [ITEM_TRAIT_TYPE_WEAPON_PRECISE]       = "precise",
  [ITEM_TRAIT_TYPE_WEAPON_INFUSED]       = "infused",
  [ITEM_TRAIT_TYPE_WEAPON_DEFENDING]     = "defending",
  [ITEM_TRAIT_TYPE_WEAPON_TRAINING]      = "training",
  [ITEM_TRAIT_TYPE_WEAPON_SHARPENED]     = "sharpened",
  [ITEM_TRAIT_TYPE_WEAPON_DECISIVE]      = "decisive",
  [ITEM_TRAIT_TYPE_WEAPON_NIRNHONED]     = "nirnhoned",
  [ITEM_TRAIT_TYPE_WEAPON_INTRICATE]     = "intricate",
  [ITEM_TRAIT_TYPE_WEAPON_ORNATE]        = "ornate",
  -- Jewelry
  [ITEM_TRAIT_TYPE_JEWELRY_ARCANE]       = "arcane",
  [ITEM_TRAIT_TYPE_JEWELRY_HEALTHY]      = "healthy",
  [ITEM_TRAIT_TYPE_JEWELRY_ROBUST]       = "robust",
  [ITEM_TRAIT_TYPE_JEWELRY_TRIUNE]       = "triune",
  [ITEM_TRAIT_TYPE_JEWELRY_INFUSED]      = "infused",
  [ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE]   = "protective",
  [ITEM_TRAIT_TYPE_JEWELRY_SWIFT]        = "swift",
  [ITEM_TRAIT_TYPE_JEWELRY_HARMONY]      = "harmony",
  [ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY] = "bloodthirsty",
  [ITEM_TRAIT_TYPE_JEWELRY_INTRICATE]    = "intricate",
  [ITEM_TRAIT_TYPE_JEWELRY_ORNATE]       = "ornate",
}

local function DayBucket(t)
  return math.floor(t / DAY_SECONDS)
end

local function ItemIdFromLink(link)
  return tonumber(link:match("|H%d+:item:(%d+):"))
end

local function SeenKey(itemId, t, source, eventId, unitPrice, guild)
  if source == "guild_sale" and eventId then
    return "event:" .. eventId
  end
  return tostring(itemId) .. "|" .. DayBucket(t) .. "|" .. (source or "")
      .. "|" .. tostring(unitPrice or 0) .. "|" .. (guild or "")
end


local function Prune()
  local cutoff = GetTimeStamp() - (PRUNE_DAYS * DAY_SECONDS)
  local sv     = JournalCompanion.sv
  local kept   = {}
  local dedup  = {}
  for _, obs in ipairs(sv.prices) do
    if obs.t >= cutoff then
      local key = SeenKey(obs.itemId, obs.t, obs.source, obs.eventId, obs.unitPrice, obs.guild)
      if not dedup[key] then
        dedup[key] = true
        kept[#kept + 1] = obs
      end
    end
  end
  -- Hard cap: keep only the most recent MAX_PRICES entries after date filter.
  if #kept > MAX_PRICES then
    local trimmed = {}
    local offset  = #kept - MAX_PRICES
    for i = offset + 1, #kept do
      trimmed[#trimmed + 1] = kept[i]
    end
    kept  = trimmed
    dedup = {}
    for _, obs in ipairs(kept) do
      dedup[SeenKey(obs.itemId, obs.t, obs.source, obs.eventId, obs.unitPrice, obs.guild)] = true
    end
  end

  sv.prices = kept
  seen = dedup
end

-- source: "guild_sale" for completed transactions, "guild_listing" for active listings.
-- Completed sales carry more weight in price calculations.
-- kioskOverride: when provided by Sales.Scan, uses the guild's own kiosk instead of currentKiosk.
local function RecordPrice(itemLink, stackCount, stackSellPrice, t, guildName, source, eventId, kioskOverride)
  local itemId = ItemIdFromLink(itemLink)
  if not itemId or not stackCount or stackCount <= 0
     or not stackSellPrice or stackSellPrice <= 0 then
    return
  end
  local src       = source or "guild_listing"
  local unitPrice = math.floor(stackSellPrice / stackCount)
  local key       = SeenKey(itemId, t, src, eventId, unitPrice, guildName)
  if seen[key] then return end
  seen[key] = true

  local quality  = GetItemLinkDisplayQuality and QUALITY_DB[GetItemLinkDisplayQuality(itemLink)]
                or GetItemLinkQuality         and QUALITY_DB[GetItemLinkQuality(itemLink)]
  local trait    = GetItemLinkTraitInfo and TRAIT_DB[GetItemLinkTraitInfo(itemLink)]
                or GetItemLinkItemTrait and TRAIT_DB[GetItemLinkItemTrait(itemLink)]
  local level    = GetItemLinkRequiredLevel and GetItemLinkRequiredLevel(itemLink) or 0
  local cpLevel  = GetItemLinkRequiredChampionPoints and GetItemLinkRequiredChampionPoints(itemLink) or 0

  local sv = JournalCompanion.sv
  sv.prices[#sv.prices + 1] = {
    t         = t,
    itemId    = itemId,
    qty       = stackCount,
    unitPrice = unitPrice,
    quality   = quality,
    trait     = trait,
    level     = level    > 0 and level   or nil,
    cpLevel   = cpLevel  > 0 and cpLevel or nil,
    guild     = guildName,
    kiosk     = kioskOverride ~= nil and kioskOverride or currentKiosk,
    source    = src,
    eventId   = eventId,
  }
end

local function RecordSearchResults()
  local numResults = GetTradingHouseSearchResultsInfo()
  if not numResults or numResults == 0 then return end

  local now = GetTimeStamp()
  for i = 1, numResults do
    -- VERIFY: field order for GetTradingHouseSearchResultItemInfo on wiki.esoui.com/Function_Index
    -- Expected: icon, name, displayName, stackCount, sellerName, timeRemaining, stackSellPrice, currencyType
    local _, _, _, stackCount, _, _, stackSellPrice = GetTradingHouseSearchResultItemInfo(i)
    local itemLink = GetTradingHouseSearchResultItemLink(i, LINK_STYLE_BRACKETS)
    RecordPrice(itemLink, stackCount, stackSellPrice, now, currentGuildName)
  end

  JournalCompanion.sv.lastUpdated = now
end

local function OnTradingHouseResponse(_, responseType)
  -- Filter to search results only; ignore listing management responses.
  -- VERIFY: TRADING_HOUSE_RESULT_SEARCH_RESULTS_RECEIVED constant on wiki.esoui.com
  -- If the constant is unavailable, remove this guard — RecordSearchResults() is a no-op
  -- when GetNumTradingHouseSearchResults() returns 0.
  if TRADING_HOUSE_RESULT_SEARCH_RESULTS_RECEIVED and
     responseType ~= TRADING_HOUSE_RESULT_SEARCH_RESULTS_RECEIVED then
    return
  end
  RecordSearchResults() -- source defaults to "guild_listing"
end

local function OnOpenTradingHouse()
  local guildId, guildName = GetCurrentTradingHouseGuildDetails()
  currentGuildName = guildName or GetUnitName("interact") or ""

  -- Primary: works for member guilds even when opened from a banker.
  currentKiosk = (guildId and guildId ~= 0) and GetGuildOwnedKioskInfo(guildId) or nil

  -- Fallback for non-member guilds: only reliable when physically standing at the kiosk.
  -- Player zone is correct in that case (unlike the banker scenario this whole fix targets).
  if not currentKiosk and IsUnitGuildKiosk and IsUnitGuildKiosk("interact") then
    local npc      = zo_strformat(SI_UNIT_NAME, GetRawUnitName("interact"))
    local subzone  = GetPlayerActiveSubzoneName and GetPlayerActiveSubzoneName() or ""
    local zone     = GetPlayerActiveZoneName and GetPlayerActiveZoneName() or ""
    local location = subzone ~= "" and subzone or zone
    if npc ~= "" and location ~= "" then
      currentKiosk = npc .. " in " .. location
    end
  end
end

local function OnCloseTradingHouse()
  currentGuildName = ""
  currentKiosk     = nil
end

function JournalCompanion.Prices.Record(itemLink, quantity, totalPrice, t, guildName, source, eventId, kiosk)
  RecordPrice(itemLink, quantity, totalPrice, t, guildName, source, eventId, kiosk)
end

local function RemoveListings(guildTarget)
  local sv      = JournalCompanion.sv
  local kept    = {}
  local removed = 0
  for _, obs in ipairs(sv.prices) do
    if obs.source == "guild_listing"
       and (guildTarget == nil or (obs.guild and zo_strlower(obs.guild) == guildTarget)) then
      removed = removed + 1
    else
      kept[#kept + 1] = obs
    end
  end
  sv.prices = kept
  seen = {}
  for _, obs in ipairs(sv.prices) do
    seen[SeenKey(obs.itemId, obs.t, obs.source, obs.eventId, obs.unitPrice, obs.guild)] = true
  end
  return removed
end

-- Removes all guild_listing records and rebuilds the dedup index.
function JournalCompanion.Prices.PruneAllListings()
  return RemoveListings(nil)
end

-- Removes guild_listing records for a specific guild and rebuilds the dedup index.
function JournalCompanion.Prices.PruneListingsForGuild(guildName)
  return RemoveListings(zo_strlower(guildName))
end

function JournalCompanion.Prices.Init()
  local ns = JournalCompanion.name .. "_Prices"
  EVENT_MANAGER:RegisterForEvent(ns, EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, OnTradingHouseResponse)
  EVENT_MANAGER:RegisterForEvent(ns, EVENT_OPEN_TRADING_HOUSE,              OnOpenTradingHouse)
  EVENT_MANAGER:RegisterForEvent(ns, EVENT_CLOSE_TRADING_HOUSE,             OnCloseTradingHouse)
  Prune()
end
