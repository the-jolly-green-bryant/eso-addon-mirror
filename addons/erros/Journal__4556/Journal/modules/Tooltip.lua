JournalCompanion = JournalCompanion or {}
JournalCompanion.Tooltip = {}

local function FormatGoldWithCommas(amount)
  local formatted = tostring(math.floor(amount + 0.5))
  while true do
    local result, count = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
    formatted = result
    if count == 0 then break end
  end
  return formatted
end

local function AppendPriceLine(tooltip, itemLink)
  if not JournalCompanion.sv.tooltipEnabled then return end
  if not itemLink or itemLink == "" then return end

  if not JournalCompanion.Pricing.HasPriceFile() then
    tooltip:AddLine("|cC9A24AJournal:|r No price data — install the companion")
    tooltip:AddLine("|c909090journal.erros.gg/start|r")
    return
  end

  local ok, price, sales = pcall(JournalCompanion.Pricing.LookupPrice, itemLink)
  if not ok or not price then return end

  local salesPart = sales and (" · " .. sales .. " sold/wk") or ""
  tooltip:AddLine("|cC9A24AJournal:|r " .. FormatGoldWithCommas(price) .. "g" .. salesPart)

  if JournalCompanion.Pricing.DataIsStale() then
    local hours = JournalCompanion.Pricing.DataAgeHours()
    if hours then
      local age = hours >= 48 and (math.floor(hours / 24) .. "d") or (hours .. "h")
      tooltip:AddLine("|c909090Journal price data is " .. age .. " old|r")
    end
  end
end

-- Wraps a tooltip SetXXX method so that after ESO renders the tooltip,
-- we append our price line.  getLinkFunc receives the same varargs as
-- SetXXX (minus the control self) and must return an ESO item link string.
local function HookTooltipFunction(tooltipControl, functionName, getLinkFunc)
  if not tooltipControl or not tooltipControl[functionName] then return end
  if not getLinkFunc then return end
  local base = tooltipControl[functionName]
  tooltipControl[functionName] = function(control, ...)
    base(control, ...)
    AppendPriceLine(control, getLinkFunc(...))
  end
end

function JournalCompanion.Tooltip.Init()
  if JournalCompanion.sv.tooltipEnabled == nil then
    JournalCompanion.sv.tooltipEnabled = true
  end

  -- Inventory bags and bank
  HookTooltipFunction(ItemTooltip, "SetBagItem",             GetItemLink)
  -- Vendor / store
  HookTooltipFunction(ItemTooltip, "SetStoreItem",           GetStoreItemLink)
  HookTooltipFunction(ItemTooltip, "SetBuybackItem",         GetBuybackItemLink)
  -- Guild trader listings
  HookTooltipFunction(ItemTooltip, "SetTradingHouseListing", GetTradingHouseListingItemLink)
  -- Loot, mail, and trade window
  HookTooltipFunction(ItemTooltip, "SetLootItem",            GetLootItemLink)
  HookTooltipFunction(ItemTooltip, "SetAttachedMailItem",    GetAttachedItemLink)
  HookTooltipFunction(ItemTooltip, "SetTradeItem",           GetTradeItemLink)
  -- Worn (equipped) items and quest rewards
  HookTooltipFunction(ItemTooltip, "SetWornItem",            function(equipSlot) return GetItemLink(BAG_WORN, equipSlot) end)
  HookTooltipFunction(ItemTooltip, "SetQuestReward",         GetQuestRewardItemLink)
  -- Popup tooltip (link right-clicks, crafting confirmation, etc.)
  HookTooltipFunction(PopupTooltip, "SetLink", function(link) return link end)
end
