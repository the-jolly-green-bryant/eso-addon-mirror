JournalCompanion = JournalCompanion or {}
JournalCompanion.InventoryValue = {}

local GOLD_COLOR  = "|cC9A24A"
local COLOR_RESET = "|r"

local INVENTORY_TYPES = {
  INVENTORY_BACKPACK,
  INVENTORY_BANK,
  INVENTORY_CRAFT_BAG,
  INVENTORY_HOUSE_BANK,
  INVENTORY_GUILD_BANK,
}

local function FormatGoldWithCommas(amount)
  local formatted = tostring(math.floor(amount + 0.5))
  while true do
    local result, count = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
    formatted = result
    if count == 0 then break end
  end
  return formatted
end

local function HandleInventoryRow(control)
  if not JournalCompanion.sv.inventoryValueEnabled then return end

  local dataEntry = control.dataEntry
  if not dataEntry or not dataEntry.data then return end
  local slotData = dataEntry.data

  local bagId    = slotData.bagId
  local slotIndex = slotData.slotIndex
  if not bagId or not slotIndex then return end

  local itemLink = GetItemLink(bagId, slotIndex)
  if not itemLink or itemLink == "" then return end

  local ok, price = pcall(JournalCompanion.Pricing.LookupPrice, itemLink)
  if not ok or not price then return end

  local sellPriceControl = control:GetNamedChild("SellPriceText")
  if not sellPriceControl then return end

  local stackCount = slotData.stackCount or 1
  sellPriceControl:SetText(GOLD_COLOR .. FormatGoldWithCommas(price * stackCount) .. "g" .. COLOR_RESET)
end

local function HookInventoryType(inventoryType)
  local inv = PLAYER_INVENTORY.inventories[inventoryType]
  if not inv or not inv.listView or not inv.listView.dataTypes then return end
  for _, dataType in pairs(inv.listView.dataTypes) do
    if dataType.setupCallback then
      SecurePostHook(dataType, "setupCallback", HandleInventoryRow)
    end
  end
end

-- Called by the settings toggle so the display updates without /reloadui.
function JournalCompanion.InventoryValue.Refresh()
  for _, invType in ipairs(INVENTORY_TYPES) do
    if PLAYER_INVENTORY.inventories[invType] then
      PLAYER_INVENTORY:UpdateList(invType)
    end
  end
end

function JournalCompanion.InventoryValue.Init()
  if JournalCompanion.sv.inventoryValueEnabled == nil then
    JournalCompanion.sv.inventoryValueEnabled = true
  end

  for _, invType in ipairs(INVENTORY_TYPES) do
    HookInventoryType(invType)
  end
end
