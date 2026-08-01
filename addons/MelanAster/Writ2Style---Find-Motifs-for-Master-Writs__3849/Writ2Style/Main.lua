WritToStyle = {}
local WTS = WritToStyle

WTS.name = "Writ2Style"
WTS.Deault = {
  ["Patch"] = {},
  ["LastId"] = 1,
}

-------------------
-- Tool function --
-------------------

--Is it a writ with style info?
local function IsWrit(itemName)
  return WTS.WritNames[itemName] or false
end

--Divide ItemLink string
local function ItemLinkParser(itemLink, parserIndex)
  --Itemlink format check
  if not string.gmatch(itemLink, "|H.*|h") then return nil end
  
  --Divide Itemlink
  local parsers = {}
  for word in string.gmatch(itemLink, "%d+") do
    table.insert(parsers, tonumber(word))
  end
  
  --Return parser(s)
  if not parserIndex then return parsers end
  return parsers[parserIndex]
end

--Query style page itemlink corresponding to writ itemlink
local itemType2ChapterIndex = {
  [17] = 1, [26] = 1, [35] = 1, [44] = 1,     --Helmets
  [20] = 2, [29] = 2, [38] = 2, [47] = 2,     --Shoulders
  [19] = 3, [28] = 3, [37] = 3, [46] = 3,     --Chests
  [25] = 4, [34] = 4, [43] = 4, [52] = 4,     --Gloves
  [21] = 5, [30] = 5, [39] = 5, [48] = 5,     --Belts
  [22] = 6, [31] = 6, [40] = 6, [49] = 6,     --Legs
  [23] = 7, [32] = 7, [41] = 7, [50] = 7,     --Boots
  
  [53] = 8, [68] = 8,                         --Axes
  [56] = 9, [69] = 9,                         --Maces
  [62] = 10,                                  --Daggers
  [59] = 11, [67] = 11,                       --Swords
  [65] = 12,                                  --Shields
  [70] = 13,                                  --Bows
  [71] = 14, [72] = 14, [73] = 14, [74] = 14, --Staves
}

local function WritItemLink2ChapterItemLink(itemLink)
  local itemType = ItemLinkParser(itemLink, 8)
  local styleId = ItemLinkParser(itemLink, 13)
  
  --Validity check
  if not itemType or itemType == 0 then return nil end
  if not styleId or styleId == 0 then return nil end
  
  --Extract from Data
  if not WTS.Data[styleId] then return nil end
  local chapterIndex = itemType2ChapterIndex[itemType]
  return WTS.Data[styleId][chapterIndex]
end

local function WritItemLink2BookItemLink(itemLink)
  local styleId = ItemLinkParser(itemLink, 13)
  if not styleId or styleId == 0 then return nil end
  if not WTS.Data[styleId] then return nil end
  return WTS.Data[styleId][15]
end

---------------
-- Menu Part --
---------------

--Output style itemlink to chat window
function WTS.ToChat(writItemLink)
  local styleItemLink = WritItemLink2ChapterItemLink(writItemLink)
  local styleItemName = GetItemLinkName(styleItemLink):gsub("%^.+", "")
  d(styleItemLink)
  StartChatInput(styleItemName)
end

--Output to TTC Website
local urlBase= "https://【1】.tamrieltradecentre.com/pc/Trade/SearchResult?ItemNamePattern=【2】&lang=【3】"
local urlLangs = {
  ["en"] = "en-US",
  ["zh"] = "zh-CN",
  ["de"] = "de-DE",
  ["fr"] = "fr-FR",
  ["ru"] = "ru-RU",
  ["es"] = "es-ES",
  ["jp"] = "ja-JP",
}

function WTS.ToTTC(writItemLink)
  local styleItemLink = WritItemLink2ChapterItemLink(writItemLink)
  local styleItemName = GetItemLinkName(styleItemLink):gsub("%^.+", "")
  
  local language = GetCVar("language.2")
  local urlLang = ""
  urlLang = urlLangs[language]
  
  local worldName = GetWorldName()
  local urlServer = ""
  if string.find(worldName, "EU ") then
    urlServer = "eu"
  else
    urlServer = "us"
  end
  
  local url = urlBase:gsub("【1】", urlServer):gsub("【2】", styleItemName):gsub("【3】", urlLang)
  RequestOpenUnsafeURL(url)
end

function WTS.BuildMenuItem()
  --Lib check
  if not LibCustomMenu then return end
  
  --Context Menu
  local MenuFun = function(inventory, _, itemLink)
    --Get itemlink from various scenes
    if not itemLink then
      local inventroySlotType = ZO_InventorySlot_GetType(inventory)
      --Trading house result item
      if inventroySlotType == SLOT_TYPE_TRADING_HOUSE_ITEM_RESULT then
        local slotIndex = ZO_Inventory_GetSlotIndex(inventory)
        itemLink = GetTradingHouseSearchResultItemLink(slotIndex)
      end
      --Trading house listing item
      if inventroySlotType == SLOT_TYPE_TRADING_HOUSE_ITEM_LISTING then
        local slotIndex = ZO_Inventory_GetSlotIndex(inventory)
        itemLink = GetTradingHouseListingItemLink(slotIndex)
      end
      --Bag item
      if inventroySlotType == SLOT_TYPE_ITEM then
        local bagIndex, slotIndex = ZO_Inventory_GetBagAndIndex(inventory)
        itemLink = GetItemLink(bagIndex, slotIndex)
      end
    end

    --Writ check
    local itemName = GetItemLinkName(itemLink)
    if not IsWrit(itemName) then return end
    
    --Add submenu for this item
    local submenuEntries = {
        {
          label = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES1301),
          callback = function() WTS.ToChat(itemLink) end,
        },
        {
          label = "TTC",
          callback = function() WTS.ToTTC(itemLink) end,
        },
      }
    AddCustomSubMenuItem("|t20:20:esoui/art/icons/master_writ_alchemy.dds|t -> |t20:20:esoui/art/icons/quest_letter_002.dds|t", submenuEntries)
    ShowMenu()
  end
  
  --Inventory registration
  LibCustomMenu:RegisterContextMenu(MenuFun)
  
  --Itemlink registration
  local OriginalFun = ZO_LinkHandler_OnLinkMouseUp
  ZO_LinkHandler_OnLinkMouseUp = function(itemLink, button, control)
    local originalResult = OriginalFun(itemLink, button, control)
    if button == MOUSE_BUTTON_INDEX_RIGHT then
      MenuFun(nil, nil, itemLink)
    end
    return originalResult
  end
end

-----------------
-- Public Part --
-----------------

function Writ2StyleByLink(itemLink, separation)
  local ChapterItemLink = WritItemLink2ChapterItemLink(itemLink)
  local BookItemLink = WritItemLink2BookItemLink(itemLink)
  if separation then
    return ChapterItemLink, BookItemLink
  else
    return ChapterItemLink or BookItemLink
  end
end

------------------
-- Start point ---
------------------
local templateWirtId = {
  "|H0:item:119563:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", -- Black
  "|H0:item:119694:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", -- Cloth
  "|H0:item:121530:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", -- Wood
}

local function OnAddOnLoaded(eventCode, addonName)
  --When loaded
  if addonName ~= WTS.name then return end
	EVENT_MANAGER:UnregisterForEvent(WTS.name, EVENT_ADD_ON_LOADED)
  WTS.SV = ZO_SavedVars:NewAccountWide("W2S_Vars", 1, nil, WTS.Deault)
  
  --Initialize
  WTS.WritNames = {}
  for i = 1, #templateWirtId do
    local writExactName = GetItemLinkName(templateWirtId[i])
    WTS.WritNames[writExactName] = true
  end
  
  --Build MenuItem
  WTS.BuildMenuItem()
end

EVENT_MANAGER:RegisterForEvent(WTS.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)