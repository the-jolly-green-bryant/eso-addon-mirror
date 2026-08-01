local Addon = FarmingPartyPlus

local Price = {
  SOURCE_AUTO = 'auto',
  SOURCE_TTC = 'ttc',
  SOURCE_MM = 'mm',
  SOURCE_ATT = 'att'
}

Addon.Price = Price

local SOURCE_CONFIG = {
  [Price.SOURCE_TTC] = {
    label = 'TTC',
    isAvailable = function()
      return LibPrice ~= nil and LibPrice.CanTTCPrice ~= nil and LibPrice.CanTTCPrice() == true
    end
  },
  [Price.SOURCE_MM] = {
    label = 'MM',
    isAvailable = function()
      return LibPrice ~= nil and LibPrice.CanMMPrice ~= nil and LibPrice.CanMMPrice() == true
    end
  },
  [Price.SOURCE_ATT] = {
    label = 'ATT',
    isAvailable = function()
      return LibPrice ~= nil and LibPrice.CanATTPrice ~= nil and LibPrice.CanATTPrice() == true
    end
  }
}

local AUTO_MARKET_ORDER = {
  Price.SOURCE_TTC,
  Price.SOURCE_MM,
  Price.SOURCE_ATT
}

local CHOICE_ORDER = {
  Price.SOURCE_AUTO,
  Price.SOURCE_TTC,
  Price.SOURCE_MM,
  Price.SOURCE_ATT
}

function Price.GetSourceConfig(sourceKey)
  return SOURCE_CONFIG[sourceKey]
end

function Price.GetSourceLabel(sourceKey)
  if sourceKey == Price.SOURCE_AUTO then
    return 'Auto (TTC -> MM -> ATT -> Vendor)'
  end

  local config = SOURCE_CONFIG[sourceKey]
  if config == nil then
    return tostring(sourceKey or '')
  end

  if config.isAvailable() then
    return config.label
  end

  return string.format('%s (not installed)', config.label)
end

function Price.GetHistorySourceLabel(sourceKey)
  if sourceKey == nil or sourceKey == '' or sourceKey == 'npc' then
    return 'Vendor'
  end

  local config = SOURCE_CONFIG[sourceKey]
  if config ~= nil then
    return config.label
  end

  return tostring(sourceKey)
end

function Price.GetSourceChoiceValues()
  return CHOICE_ORDER
end

function Price.GetSourceChoiceLabels()
  local labels = {}
  for _, sourceKey in ipairs(CHOICE_ORDER) do
    labels[#labels + 1] = Price.GetSourceLabel(sourceKey)
  end
  return labels
end

function Price.GetConfiguredMarketPriority()
  local preferredSource = Price.SOURCE_AUTO
  if Addon.Settings ~= nil and Addon.Settings.GetPreferredPriceSource ~= nil then
    preferredSource = Addon.Settings:GetPreferredPriceSource()
  end

  local priority = {}
  local seen = {}

  local function addSource(sourceKey)
    if sourceKey == nil or seen[sourceKey] then
      return
    end
    seen[sourceKey] = true
    priority[#priority + 1] = sourceKey
  end

  if preferredSource ~= Price.SOURCE_AUTO then
    addSource(preferredSource)
  end

  for _, sourceKey in ipairs(AUTO_MARKET_ORDER) do
    addSource(sourceKey)
  end

  return priority
end

function Price.GetActiveMarketPriority()
  local active = {}
  for _, sourceKey in ipairs(Price.GetConfiguredMarketPriority()) do
    local config = SOURCE_CONFIG[sourceKey]
    if config ~= nil and config.isAvailable() then
      active[#active + 1] = sourceKey
    end
  end
  return active
end

function Price.GetItemPrice(itemLink)
  if itemLink == nil or itemLink == '' then
    return 0, 'npc'
  end

  if LibPrice ~= nil and LibPrice.ItemLinkToPriceGold ~= nil then
    local activePriority = Price.GetActiveMarketPriority()
    local price, sourceKey = LibPrice.ItemLinkToPriceGold(itemLink, unpack(activePriority))
    if price ~= nil and price > 0 then
      return price, sourceKey
    end
  end

  return GetItemLinkValue(itemLink, true) or 0, 'npc'
end
