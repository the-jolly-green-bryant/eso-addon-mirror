local _G = _G
local SCENE_MANAGER = _G.SCENE_MANAGER
local EVENT_MANAGER = _G.GetEventManager()

if SCENE_MANAGER == nil then
  return
end

if EVENT_MANAGER == nil then
  return
end

local BAG_BACKPACK = 1
local LINK_STYLE_DEFAULT = 0

local ZO_MailSendBodyField = _G.ZO_MailSendBodyField
local SLASH_COMMANDS = _G.SLASH_COMMANDS
local GetItemLinkValue = _G.GetItemLinkValue
local GetItemSellValueWithBonuses = _G.GetItemSellValueWithBonuses
local GetItemInfo = _G.GetItemInfo
local GetItemLink = _G.GetItemLink
local GetBagSize = _G.GetBagSize
local zround = _G.zo_round
local ZO_LocalizeDecimalNumber = _G.ZO_LocalizeDecimalNumber
local zo_roundToNearest = _G.zo_roundToNearest
local EVENT_ADD_ON_LOADED = _G.EVENT_ADD_ON_LOADED
local zo_callLater = _G.zo_callLater
local tinsert, tconcat = _G.table.insert, _G.table.concat

local MailItemsSummaryLP = {
  AddonName = "MailItemsSummaryLP",
  major = "1",
  minor = "0",
  patch = "3",
  build = "3",
  current_api = 101038,
  future_api = 101039,
}

local LibPrice = _G.LibPrice

local function GetItemPrice(itemLink, considerCondition, bagId, slotIndex)
  local defaultPrice = GetItemLinkValue(itemLink, considerCondition) or GetItemSellValueWithBonuses(bagId, slotIndex)
  local libPriceValue = LibPrice.ItemLinkToPriceGold(itemLink, "mm", "att", "ttc")
  local price
  if libPriceValue then
    price = zround(libPriceValue)
  end
  return price or defaultPrice
end

local function MISLP()
  if not SCENE_MANAGER:IsShowing("mailSend") then
    return
  end
  local ptable = {}
  local bagId = BAG_BACKPACK
  local totalprice = zo_roundToNearest(0, 0)
  local linkStyle = LINK_STYLE_DEFAULT
  for slotIndex = 0, GetBagSize(bagId) - 1 do
    local itemLink = GetItemLink(bagId, slotIndex, linkStyle)
    local _, stack, _, _, locked, _ = GetItemInfo(bagId, slotIndex)
    if locked then
      local price = GetItemPrice(itemLink) or 0
      price = zround(price)
      tinsert(
        ptable,
        itemLink
          .. "x"
          .. stack
          .. " "
          .. ZO_LocalizeDecimalNumber(price)
          .. "="
          .. ZO_LocalizeDecimalNumber(stack * price)
      )
      totalprice = totalprice + price * stack
    end
  end
  tinsert(ptable, "")
  tinsert(ptable, "Total Attached Value = " .. ZO_LocalizeDecimalNumber(totalprice))
  ZO_MailSendBodyField:SetText(tconcat(ptable, "\n"))
end

local WAIT_TO_SLASH = 2000

local function OnAddOnLoaded(_, addonName)
  if addonName ~= MailItemsSummaryLP.AddonName then
    return
  end
  EVENT_MANAGER:UnregisterForEvent(MailItemsSummaryLP.AddonName, EVENT_ADD_ON_LOADED)
  zo_callLater(function()
    SLASH_COMMANDS["/mislp"] = MISLP
  end, WAIT_TO_SLASH)
end
EVENT_MANAGER:RegisterForEvent(MailItemsSummaryLP.AddonName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
