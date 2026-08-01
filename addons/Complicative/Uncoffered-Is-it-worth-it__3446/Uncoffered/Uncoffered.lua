Uncoffered = {
  name = "Uncoffered",
  version = "2.1.2",
  author = "@Complicative",
}

Uncoffered.Settings = {
  --Saved Settings
  --None for now
}

--------------------------------------

local debug = false

--Local Utility Functions
local function cStart(hex) return "|c" .. hex end --returns colour start for a string

local function cEnd() return "|r" end             --return colour end string

local function colorText(text, hex)
  return cStart(hex) .. text .. cEnd()
end

local function getTimeStamp() return cStart("888888") .. "[" .. os.date('%H:%M:%S') .. "] " .. cEnd() end --returns a timestamp in gray

local pColoredStr = function(num1, num2, c1, c2)                                                          --returns a percantage of num1 in colour c1 if num1 > num2. c2 if num1 < num2
  local color = function() if num1 > num2 then return c1 else return c2 end end
  return string.format("%s%.2f%s%s", cStart(color()), num1 * 100, "%", cEnd())
end

------------------------------------

local UNDAUNTED_MYSTERY, UNDAUNTED_NORMAL = 1, 2
local IMPERIAL_CITY_MYSTERY, IMPERIAL_CITY_NORMAL = 3, 4
local CYRODIIL_SHOULDERS, CYRODIIL_MASK = 5, 6
local INFINITE_ARCHIVE_CURATED, INFINITE_ARCHIVE_NORMAL = 7, 8
local CYRODIIL_SETTLEMENT = 9

Uncoffered.functions = {
  [0] = function() return end,
  [UNDAUNTED_MYSTERY] = UCUndaunted.GetMysteryText,
  [UNDAUNTED_NORMAL] = UCUndaunted.GetNormalText,
  [IMPERIAL_CITY_MYSTERY] = UCIC.GetMysteryText,
  [IMPERIAL_CITY_NORMAL] = UCIC.GetNormalText,
  [CYRODIIL_SHOULDERS] = UCCyrodiil.GetShoulderText,
  [CYRODIIL_MASK] = UCCyrodiil.GetMaskText,
  [INFINITE_ARCHIVE_CURATED] = UCIA.GetCuratedText,
  [INFINITE_ARCHIVE_NORMAL] = UCIA.GetNormalText,
  [CYRODIIL_SETTLEMENT] = UCCyrodiilSettlement.GetText,
}


function Uncoffered.IsCollectedFromSetId(setId, i)
  --returns if item is collected
  local _, slot = GetItemSetCollectionPieceInfo(setId, i)
  return IsItemSetCollectionSlotUnlocked(setId, slot)
end

function Uncoffered.GetItemLinkFromId(id)
  local cofferId = id
  --returns an ItemLink from id
  return "|H1:item:" ..
      cofferId .. ":0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
end

function Uncoffered.GetTotalPiecesFromSetId(id)
  for i = 1, 100 do
    if GetItemSetCollectionPieceInfo(id, i) == 0 then return i - 1 end
  end
  return 0
end

--[[ function Uncoffered.GetIdFromItemLink(itemLink) return GetItemLinkItemId(itemLink) end --returns Id from ItemLink ]]

function Uncoffered.GetMysteryFromNormal(itemLink)
  --returns ItemLink of the Mystery Coffer, that the Normal Coffer is related to
  local cofferId = Uncoffered.GetIdFromItemLink(itemLink)
  --Finds the cofferId in Database and returns the cofferid it is saved in. Hardcoded Database!
  for k, v in pairs(UncofferedData.CofferDB) do
    if k == "Cyrodiil" or k == "IA" then break end
    for i = 1, #v do
      if cofferId == v[i] then
        return Uncoffered.GetItemLinkFromId(k)
      end
    end
  end
  return nil
end

function Uncoffered.GetCofferType(cofferId)
  for k, v in pairs(UncofferedData.Undaunted) do
    if k == cofferId then
      return UNDAUNTED_MYSTERY
    else
      for _, i in ipairs(v) do
        if i == cofferId then return UNDAUNTED_NORMAL end
      end
    end
  end

  for k, v in pairs(UncofferedData.IC) do
    if k == cofferId then
      return IMPERIAL_CITY_MYSTERY
    else
      for _, i in ipairs(v) do
        if i == cofferId then return IMPERIAL_CITY_NORMAL end
      end
    end
  end

  if UncofferedData.Cyrodiil[cofferId] then return UncofferedData.Cyrodiil[cofferId] end

  if UncofferedData.IA[cofferId] then return UncofferedData.IA[cofferId] end

  for _, v in ipairs(UncofferedData.CyrodiilSettlement) do
    if v == cofferId then
      return CYRODIIL_SETTLEMENT
    end
  end

  return 0
end

local function GetInfoText(itemLink)
  --returns final tooltip text. Whatever string is returned here, will end up in the tooltip

  local cofferId = GetItemLinkItemId(itemLink)
  local type = Uncoffered.GetCofferType(cofferId)

  return Uncoffered.functions[type](itemLink)
end

local function AddInfo(tooltip, item)
  --don't mess with this. Mostly stolen, cause tooltips are hard
  if item then
    tooltip:AddVerticalPadding(8)
    ZO_Tooltip_AddDivider(tooltip)
    tooltip:AddLine(item, "", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
  end
end

local function GetItemID(itemLink)
  if not debug then return end
  return "\n" .. GetItemLinkItemId(itemLink)
end

local function TooltipHook(tooltipControl, method, linkFunc)
  --don't mess with this. Stolen, cause tooltips are hard
  local origMethod = tooltipControl[method]

  tooltipControl[method] = function(self, ...)
    origMethod(self, ...)
    AddInfo(self, GetInfoText(linkFunc(...)))
    AddInfo(self, GetItemID(linkFunc(...)))
  end
end

local function ReturnItemLink(itemLink)
  --don't mess with this. Stolen, cause tooltips are hard
  return itemLink
end

---------------------------------------------
-- OnAddOnLoaded --
---------------------------------------------

function Uncoffered.OnAddOnLoaded(event, addonName) --initialize the addon
  if addonName ~= Uncoffered.name then return end

  --don't mess with this. Stolen, cause tooltips are hard
  TooltipHook(ItemTooltip, "SetStoreItem", GetStoreItemLink)
  TooltipHook(ItemTooltip, "SetBagItem", GetItemLink)
  TooltipHook(ItemTooltip, "SetTradeItem", GetTradeItemLink)
  TooltipHook(ItemTooltip, "SetBuybackItem", GetBuybackItemLink)
  TooltipHook(ItemTooltip, "SetAttachedMailItem", GetAttachedItemLink)
  TooltipHook(ItemTooltip, "SetLootItem", GetLootItemLink)
  TooltipHook(ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink)
  TooltipHook(ItemTooltip, "SetTradingHouseListing", GetTradingHouseListingItemLink)
  TooltipHook(ItemTooltip, "SetLink", ReturnItemLink)

  TooltipHook(PopupTooltip, "SetLink", ReturnItemLink)



  --Saved Settings (None currently)
end

----------------------------------------------
-- Events Setup --
----------------------------------------------
EVENT_MANAGER:RegisterForEvent(Uncoffered.name, EVENT_ADD_ON_LOADED, Uncoffered.OnAddOnLoaded)

----------------------------------------------
-- Slash Commands --
----------------------------------------------

local function printCoffers(db, id)
  for i = 1, #db[id] do
    d(getTimeStamp() .. Uncoffered.GetItemLinkFromId(db[id][i]))
  end
end

SLASH_COMMANDS["/uncoffered"] = function(args)
  if args == "debug" then
    debug = not debug
    d(getTimeStamp() .. "debug has been set to " .. tostring(debug))
    return
  end
  if args == "print" then
    d(getTimeStamp() .. "---------------------------")
    d(
      "This is a debug function. I left it in, with debug off, since I think, it could be usefull in non-debug mode as well.")
    d(getTimeStamp() .. "Base Game 1----------------")
    d(getTimeStamp() .. Uncoffered.GetItemLinkFromId(153513))
    printCoffers(UncofferedData.Undaunted, 153513)
    d(getTimeStamp() .. "Base Game 2----------------")
    d(getTimeStamp() .. Uncoffered.GetItemLinkFromId(153514))
    printCoffers(UncofferedData.Undaunted, 153514)
    d(getTimeStamp() .. "DLC Dungeons---------------")
    d(getTimeStamp() .. Uncoffered.GetItemLinkFromId(153515))
    printCoffers(UncofferedData.Undaunted, 153515)
    d(getTimeStamp() .. "Imperial City--------------")
    d(getTimeStamp() .. Uncoffered.GetItemLinkFromId(184208))
    printCoffers(UncofferedData.IC, 184208)
    d(getTimeStamp() .. "Cyrodiil-------------------")
    d(getTimeStamp() .. Uncoffered.GetItemLinkFromId(199140))
    d(getTimeStamp() .. Uncoffered.GetItemLinkFromId(198854))
    d(getTimeStamp() .. Uncoffered.GetItemLinkFromId(199141))
    d(getTimeStamp() .. Uncoffered.GetItemLinkFromId(198798))
    d(getTimeStamp() .. Uncoffered.GetItemLinkFromId(199142))
    d(getTimeStamp() .. Uncoffered.GetItemLinkFromId(198713))
    d(getTimeStamp() .. "IA-------------------")
    d(getTimeStamp() .. Uncoffered.GetItemLinkFromId(203097))
    d(getTimeStamp() .. Uncoffered.GetItemLinkFromId(203107))
    d(getTimeStamp() .. Uncoffered.GetItemLinkFromId(203103))
    d(getTimeStamp() .. Uncoffered.GetItemLinkFromId(203099))
    d(getTimeStamp() .. Uncoffered.GetItemLinkFromId(203095))
    d(getTimeStamp() .. Uncoffered.GetItemLinkFromId(203101))
    d(getTimeStamp() .. Uncoffered.GetItemLinkFromId(203105))
    d(getTimeStamp() .. Uncoffered.GetItemLinkFromId(203098))
    d(getTimeStamp() .. Uncoffered.GetItemLinkFromId(203108))
    d(getTimeStamp() .. Uncoffered.GetItemLinkFromId(203104))
    d(getTimeStamp() .. Uncoffered.GetItemLinkFromId(203100))
    d(getTimeStamp() .. Uncoffered.GetItemLinkFromId(203096))
    d(getTimeStamp() .. Uncoffered.GetItemLinkFromId(203102))
    d(getTimeStamp() .. Uncoffered.GetItemLinkFromId(203106))
    return
  end

  CHAT_SYSTEM:AddMessage(string.format("%s by %s, Version: %s", Uncoffered.name, Uncoffered.author, Uncoffered.version))
end
