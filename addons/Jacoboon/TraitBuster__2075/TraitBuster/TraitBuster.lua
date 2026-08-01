-----------------------------------------
-- TraitBuster --
-- Simple addon that helps keep your bank tidy by identifying similar
-- pieces of gear with the same unresearched traits.
-----------------------------------------

--default namespace
TraitBuster = {}
TraitBuster.name = "TraitBuster"
--owned items info
TraitBuster.itemGraph = {}
TraitBuster.itemGraph.name = "TraitBuster.itemGraph"
--Stored settings - see Init()
TraitBuster.settings = {}
TraitBuster.settings_defaults = {
  tbOn = true,
  tbLong = true,
  tbGreet = true
}

--Adds my sweet gradient tag then prints the tostring of each parameter
function TraitBuster:Print(...)
  local str = "|c42DC07T|r|c4DDD13r|r|c5ADE21a|r|c69E031i|r|c7DE145t|r|c93E35CB|r|cA6E472u|r|cBCE688s|r|cCAE898t|r|cDBE9A9e|r|cEBEBB9r|r:"
  local tbl = {...}
  for i = 1, #tbl do
    str = str .. tostring(tbl[i]) .. " "
  end
  d(str)
end

--debug
function TraitBuster:PrintTable(tbl)
  TraitBuster:Print("Table: " .. (tbl.name or ""))
  d("----------------------------------------------")
  d(tbl)
end

--run once
function TraitBuster:Init()
  EVENT_MANAGER:UnregisterForEvent(TraitBuster.name, EVENT_ADD_ON_LOADED)
  TraitBuster.settings = ZO_SavedVars:New("TraitBuster_settings", 1, nil, TraitBuster.settings_defaults)
  TraitBuster:GraphTraits()
end

function TraitBuster:Activate()
  if TraitBuster.settings.tbGreet == true then
    TraitBuster:Print(string.format(GetString(TBUST_ACTIVATED), GetString(TBUST_SLASH_TBUST)))
  end
end

---------------------------------------
--Local functions--
---------------------------------------
--I kept these variables outside of the function to reduce repeated initializations.
--ESO globals for the different bag indexes
local tbBags = {
  BAG_BACKPACK, 
  BAG_BANK,
  BAG_HOUSE_BANK_EIGHT,
  BAG_HOUSE_BANK_FIVE,
  BAG_HOUSE_BANK_FOUR,
  BAG_HOUSE_BANK_NINE,
  BAG_HOUSE_BANK_ONE,
  BAG_HOUSE_BANK_SEVEN,
  BAG_HOUSE_BANK_SIX,
  BAG_HOUSE_BANK_TEN,
  BAG_HOUSE_BANK_THREE,
  BAG_HOUSE_BANK_TWO,
  BAG_SUBSCRIBER_BANK,
  BAG_WORN
}
local tbNumSlots = 0
local tbItemLink = ""
local tbCanBeResearched = false
local tbTraitType, tbTraitDescription
local equipType, armorType, weaponType
--either armor, weapon, or neither
local tbTypeToUse
--iterates the player's bags and graphs out the necessary info
function TraitBuster:GraphTraits()
--a link indexed array of item info. I store this to minimize api calls.
  TraitBuster.itemGraph = { name = "TraitBuster.itemGraph"}
--item / trait type indexed table that groups similar items. For faster lookups.
  TraitBuster.traitGraph = { name = "TraitBuster.traitGraph"}
  for iBag, bag in ipairs(tbBags) do
    TraitBuster.itemGraph[bag] = {}
    tbNumSlots = GetBagSize(bag)
    for i = 0, tbNumSlots do
      tbItemLink = GetItemLink(bag, i, LINK_STYLE_DEFAULT)
      if tbItemLink ~= "" then
        tbCanBeResearched = CanItemLinkBeTraitResearched(tbItemLink)
        TraitBuster.itemGraph[tbItemLink] = {
          canBeResearched = tbCanBeResearched,
          equipType = -1,
          armorType = -1,
          weaponType = -1,
          traitType = -1
        }
        if tbCanBeResearched == true then
          equipType = GetItemLinkEquipType(tbItemLink)
          armorType = GetItemLinkArmorType(tbItemLink)
          weaponType = GetItemLinkWeaponType(tbItemLink)
          tbTraitType, tbTraitDescription = GetItemLinkTraitInfo(tbItemLink)
          TraitBuster.itemGraph[tbItemLink].equipType = equipType
          TraitBuster.itemGraph[tbItemLink].armorType = armorType
          TraitBuster.itemGraph[tbItemLink].weaponType = weaponType
          TraitBuster.itemGraph[tbItemLink].traitType = tbTraitType
          if not TraitBuster.traitGraph[tbTraitType] then TraitBuster.traitGraph[tbTraitType] = {} end
          if not TraitBuster.traitGraph[tbTraitType][equipType] then TraitBuster.traitGraph[tbTraitType][equipType] = {} end
--jewelery weapon/armor type will both be 0, so it doesn't matter :D
          if weaponType == 0 then
            if not TraitBuster.traitGraph[tbTraitType][equipType][armorType] then TraitBuster.traitGraph[tbTraitType][equipType][armorType] = {} end
            tbTypeToUse = armorType
          end
          if armorType == 0 then
            if not TraitBuster.traitGraph[tbTraitType][equipType][weaponType] then TraitBuster.traitGraph[tbTraitType][equipType][weaponType] = {} end
            tbTypeToUse = weaponType
          end
--I store the bag and slot ids for future reference, although it isn't used yet
          table.insert(TraitBuster.traitGraph[tbTraitType][equipType][tbTypeToUse], {link = tbItemLink, bag = bag, slot = i})
        end
      end
    end
  end
end

local tbGPStyle = {
  fontSize = 32,
  fontColorType = INTERFACE_COLOR_TYPE_GAMEPAD_TOOLTIP,
  fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1,
  fontStyle = "soft-shadow-thick",
  customSpacing = 15
}
local numTraitDupes = 0
--the tooltip text
local strDupe = ""
--this is where I do my tooltip work
local function DisplayItemLinkTooltip(control, itemLink, gpMode)
  if TraitBuster.settings.tbOn == false then return end
  if not TraitBuster.itemGraph[itemLink] then return end
  tbCanBeResearched = TraitBuster.itemGraph[itemLink].canBeResearched
  if tbCanBeResearched == true then
    equipType = TraitBuster.itemGraph[itemLink].equipType
    armorType = TraitBuster.itemGraph[itemLink].armorType
    weaponType = TraitBuster.itemGraph[itemLink].weaponType
    tbTraitType = TraitBuster.itemGraph[itemLink].traitType
    if armorType == 0 then tbTypeToUse = weaponType end
    if weaponType == 0 then tbTypeToUse = armorType end
    numTraitDupes = #(TraitBuster.traitGraph[tbTraitType][equipType][tbTypeToUse]) - 1
    if numTraitDupes > 0 then
      if TraitBuster.settings.tbLong == true then
        if numTraitDupes == 1 then strDupe = GetString(TBUST_LONG_SINGULAR)
        else strDupe = string.format(GetString(TBUST_LONG_PLURAL), numTraitDupes) end
      else
        if numTraitDupes == 1 then strDupe = GetString(TBUST_SHORT_SINGULAR)
        else strDupe = string.format(GetString(TBUST_SHORT_PLURAL), numTraitDupes) end
      end
--these lines modify the tooltip
      if gpMode == true then
        control:AddLine(strDupe, tbGPStyle, control:GetStyle("bodySection"))
      else
        control:AddVerticalPadding(5)
        ZO_Tooltip_AddDivider(control)
        control:AddLine(strDupe, "ZoFontGameShadow", 99, 242, 108, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
      end
    end
  end
end

-----------------------------------------------------------------------
--Hooks for tooltips
-----------------------------------------------------------------------
--Bag items--
--The ESO method to hook, stored to execute after i'm done hijacking it
local tbBagItemTooltip = ItemTooltip.SetBagItem
--Commence hijack...
ItemTooltip.SetBagItem = function(control, bagId, slotIndex, ...)
--Ok, ok. You first. Then me.
  tbBagItemTooltip(control, bagId, slotIndex, ...)
--I pass the tooltip control and the item link to play with
  DisplayItemLinkTooltip(control, GetItemLink(bagId, slotIndex))
end
--Gamepad compatability
local tbGP_LEFT = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP)
local tbGP_LEFT_LayoutBagItem = tbGP_LEFT.LayoutBagItem
tbGP_LEFT.LayoutBagItem = function(control, bagId, slotIndex, ...)
  local ret = tbGP_LEFT_LayoutBagItem(control, bagId, slotIndex, ...)
  DisplayItemLinkTooltip(control, GetItemLink(bagId, slotIndex), true)
  return ret
end
local tbGP_RIGHT = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_RIGHT_TOOLTIP)
local tbGP_RIGHT_LayoutBagItem = tbGP_RIGHT.LayoutBagItem
tbGP_RIGHT.LayoutBagItem = function(control, bagId, slotIndex, ...)
  local ret = tbGP_RIGHT_LayoutBagItem(control, bagId, slotIndex, ...)
  DisplayItemLinkTooltip(control, GetItemLink(bagId, slotIndex), true)
  return ret
end

--Chat links--
local tbChatLinkTooltip = PopupTooltip.SetLink
PopupTooltip.SetLink = function(control, link, ...)
  tbChatLinkTooltip(control, link, ...)
  DisplayItemLinkTooltip(control, link)
end

--Worn items--
local tbWornItemTooltip = ItemTooltip.SetWornItem
ItemTooltip.SetWornItem = function(control, slotIndex, ...)
  tbWornItemTooltip(control, slotIndex, ...)
  DisplayItemLinkTooltip(control, GetItemLink(BAG_WORN, slotIndex))
end


--Guild items--
local tbGuildItemTooltip = ItemTooltip.SetGuildSpecificItem
ItemTooltip.SetGuildSpecificItem = function(control, guildSpecificItemIndex, ...)
  tbGuildItemTooltip(control, guildSpecificItemIndex, ...)
  DisplayItemLinkTooltip(control, GetGuildSpecificItemLink(guildSpecificItemIndex))
end


--Loot items--
local tbLootItemTooltip = ItemTooltip.SetLootItem
ItemTooltip.SetLootItem = function(control, lootId, ...)
  tbLootItemTooltip(control, lootId, ...)
  DisplayItemLinkTooltip(control, GetLootItemLink(lootId))
end
--gamepad
local tbGP_LayoutItemWithStackCount = tbGP_RIGHT.LayoutItemWithStackCount
tbGP_RIGHT.LayoutItemWithStackCount = function(control, itemLink, ...)
  local ret = tbGP_LayoutItemWithStackCount(control, itemLink, ...)
  if SCENE_MANAGER:IsShowing("lootGamepad") then
    DisplayItemLinkTooltip(control, itemLink, true)
  end
  return ret
end

--Quest rewards--
local tbQuestRewardTooltip = ItemTooltip.SetQuestReward
ItemTooltip.SetQuestReward = function(control, rewardIndex, ...)
  tbQuestRewardTooltip(control, rewardIndex, ...)
  DisplayItemLinkTooltip(control, GetQuestRewardItemLink(rewardIndex))
end

--Crafting results--
local tbResultTooltip = ZO_SmithingTopLevelCreationPanelResultTooltip
local tbPendingSmithingItemTooltip = tbResultTooltip.SetPendingSmithingItem
tbResultTooltip.SetPendingSmithingItem = function(control, patternIndex, materialIndex, materialQuantity, itemStyleId, traitIndex, ...)
  tbPendingSmithingItemTooltip(control, patternIndex, materialIndex, materialQuantity, itemStyleId, traitIndex, ...)
  DisplayItemLinkTooltip(control, GetSmithingPatternResultLink(patternIndex, materialIndex, materialQuantity, itemStyleId, traitIndex))
end
--gamepad
local tbGP_ResultTooltip = ZO_GamepadSmithingTopLevelCreationResultTooltip.tip
local tbGP_LayoutPendingSmithingItem = tbGP_ResultTooltip.LayoutPendingSmithingItem
tbGP_ResultTooltip.LayoutPendingSmithingItem = function(control, patternIndex, materialIndex, materialQuantity, itemStyleId, traitIndex, ...)
  tbGP_LayoutPendingSmithingItem(control, patternIndex, materialIndex, materialQuantity, itemStyleId, traitIndex, ...)
  DisplayItemLinkTooltip(control, GetSmithingPatternResultLink(patternIndex, materialIndex, materialQuantity, itemStyleId, traitIndex), true)
end

--Buyback items--
local tbBuybackItemTooltip = ItemTooltip.SetBuybackItem
ItemTooltip.SetBuybackItem = function(control, index, ...)
  tbBuybackItemTooltip(control, index, ...)
  DisplayItemLinkTooltip(control, GetBuybackItemLink(index))
end
--gamepad
local tbGP_LayoutBuyBackItem = tbGP_LEFT.LayoutBuyBackItem
tbGP_LEFT.LayoutBuyBackItem = function(control, index, ...)
  tbGP_LayoutBuyBackItem(control, index, ...)
  DisplayItemLinkTooltip(control, GetBuybackItemLink(index), true)
end

--Trade items--
local tbTradeItemTooltip = ItemTooltip.SetTradeItem
ItemTooltip.SetTradeItem = function(control, tradeWho, slotIndex, ...)
  tbTradeItemTooltip(control, tradeWho, slotIndex, ...)
  DisplayItemLinkTooltip(control, GetTradeItemLink(tradeWho, slotIndex))
end
--gamepad
local tbGP_LEFT_LayoutTradeItem = tbGP_LEFT.LayoutTradeItem
tbGP_LEFT.LayoutTradeItem = function(control, tradeWho, slotIndex, ...)
  local ret = tbGP_LEFT_LayoutTradeItem(control, tradeWho, slotIndex, ...)
  DisplayItemLinkTooltip(control, GetTradeItemLink(tradeWho, slotIndex), true)
  return ret
end
local tbGP_QUAD3 = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_QUAD3_TOOLTIP)
local tbGP_QUAD3_LayoutTradeItem = tbGP_QUAD3.LayoutTradeItem
tbGP_QUAD3.LayoutTradeItem = function(control, tradeWho, slotIndex, ...)
  local ret = tbGP_QUAD3_LayoutTradeItem(control, tradeWho, slotIndex, ...)
  DisplayItemLinkTooltip(control, GetTradeItemLink(tradeWho, slotIndex), true)
  return ret
end


--Trading Houses--
local tbTradingHouseItemTooltip = ItemTooltip.SetTradingHouseItem
ItemTooltip.SetTradingHouseItem = function(control, tradingHouseIndex, ...)
  tbTradingHouseItemTooltip(control, tradingHouseIndex, ...)
  DisplayItemLinkTooltip(control, GetTradingHouseSearchResultItemLink(tradingHouseIndex))
end
local tbTradingHouseListingTooltip = ItemTooltip.SetTradingHouseListing
ItemTooltip.SetTradingHouseListing = function(control, tradingHouseListingIndex, ...)
  tbTradingHouseListingTooltip(control, tradingHouseListingIndex, ...)
  DisplayItemLinkTooltip(control, GetTradingHouseListingItemLink(tradingHouseListingIndex))
end
--gamepad
local tbGP_LEFT_LayoutItemWithStackCountSimple = tbGP_LEFT.LayoutItemWithStackCountSimple
tbGP_LEFT.LayoutItemWithStackCountSimple = function(control, itemLink, ...)
  local ret = tbGP_LEFT_LayoutItemWithStackCountSimple(control, itemLink, ...)
  DisplayItemLinkTooltip(control, itemLink, true)
  return ret
end


--Mail--
local tbAttachedMailItemTooltip = ItemTooltip.SetAttachedMailItem
ItemTooltip.SetAttachedMailItem = function(control, openMailId, attachmentIndex, ...)
  tbAttachedMailItemTooltip(control, openMailId, attachmentIndex, ...)
  DisplayItemLinkTooltip(control, GetAttachedItemLink(openMailId, attachmentIndex))
end
--gamepad
local tbGP_LayoutGenericItem = tbGP_LEFT.LayoutGenericItem
tbGP_LEFT.LayoutGenericItem = function(control, itemLink, ...)
  local ret = tbGP_LayoutGenericItem(control, itemLink, ...)
  if GAMEPAD_MAIL_INBOX_FRAGMENT:IsShowing() then
    DisplayItemLinkTooltip(control, itemLink, true)
  end
  return ret
end

--------------------------------------
--Slash Commands
--------------------------------------
function TraitBuster.SlashMenu(extra)
  local splits = {}
  local extras = { string.match(extra, "^(%S*)%s*(.-)$") }
  for i, v in pairs(extras) do
    if (v ~= nil and v ~= "") then
      splits[i] = string.lower(v)
    end
  end
  if #splits == 0 then
    TraitBuster:Print(GetString(TBUST_MENU_TITLE))
    TraitBuster:Print(GetString(TBUST_SLASH_TBUST), GetString(TBUST_SLASH_ON), GetString(TBUST_MENU_ON))
    TraitBuster:Print(GetString(TBUST_SLASH_TBUST), GetString(TBUST_SLASH_OFF), GetString(TBUST_MENU_OFF))
    TraitBuster:Print(GetString(TBUST_SLASH_TBUST), GetString(TBUST_SLASH_LONG), GetString(TBUST_MENU_LONG))
    TraitBuster:Print(GetString(TBUST_SLASH_TBUST), GetString(TBUST_SLASH_SHORT), GetString(TBUST_MENU_SHORT))
    TraitBuster:Print(GetString(TBUST_SLASH_TBUST), string.format("%s %s", GetString(TBUST_SLASH_GREET), GetString(TBUST_SLASH_ON)), GetString(TBUST_MENU_GREET_ON))
    TraitBuster:Print(GetString(TBUST_SLASH_TBUST), string.format("%s %s", GetString(TBUST_SLASH_GREET), GetString(TBUST_SLASH_OFF)), GetString(TBUST_MENU_GREET_OFF))
    TraitBuster:Print(GetString(TBUST_SLASH_TBUST), GetString(TBUST_SLASH_DEFAULT), GetString(TBUST_MENU_DEFAULT))
    TraitBuster:Print("-=-=-=-=-=-=-=-=-=-=-=-=-")
  else
    if splits[1] == GetString(TBUST_SLASH_ON) then
      TraitBuster.settings.tbOn = true
      TraitBuster:Print(GetString(TBUST_MENU_SELECT_ON))
    elseif splits[1] == GetString(TBUST_SLASH_OFF) then
      TraitBuster.settings.tbOn = false
      TraitBuster:Print(GetString(TBUST_MENU_SELECT_OFF))
    elseif splits[1] == GetString(TBUST_SLASH_LONG) then
      TraitBuster.settings.tbLong = true
      TraitBuster:Print(GetString(TBUST_MENU_SELECT_LONG))
    elseif splits[1] == GetString(TBUST_SLASH_SHORT) then
      TraitBuster.settings.tbLong = false
      TraitBuster:Print(GetString(TBUST_MENU_SELECT_SHORT))
    elseif splits[1] == GetString(TBUST_SLASH_GREET) then
      if splits[2] == GetString(TBUST_SLASH_ON) then
        TraitBuster.settings.tbGreet = true
        TraitBuster:Print(GetString(TBUST_MENU_SELECT_GREET_ON))
      elseif splits[2] == GetString(TBUST_SLASH_OFF) then
        TraitBuster.settings.tbGreet = false
        TraitBuster:Print(GetString(TBUST_MENU_SELECT_GREET_OFF))
      end
    elseif splits[1] == GetString(TBUST_SLASH_DEFAULT) then
      TraitBuster.settings.tbOn = true
      TraitBuster.settings.tbLong = true
      TraitBuster.settings.tbGreet = true
      TraitBuster:Print(GetString(TBUST_MENU_SELECT_DEFAULT))
    end
  end
end
SLASH_COMMANDS[GetString(TBUST_SLASH_TBUST)] = TraitBuster.SlashMenu
--------------------------------------
--Event Handlers
--------------------------------------
function TraitBuster.OnAddOnLoaded(event, addonName)
  if (addonName == TraitBuster.name) then
    TraitBuster:Init()
  end
end

function TraitBuster.OnPlayerActivated(event, initial)
  if (initial == true) then
    TraitBuster:Activate()
  end
end

function TraitBuster.OnInventorySingleSlotUpdate(event, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
--weapons, armor, and jewelery never stack, so...
  if stackCountChange == 1 then
    tbItemLink = GetItemLink(bagId, slotId, LINK_STYLE_DEFAULT)
    if tbItemLink ~= "" then
      tbCanBeResearched = CanItemLinkBeTraitResearched(tbItemLink)
      if tbCanBeResearched == true then
        TraitBuster:GraphTraits()
      end
    end
--Possible overkill here. Many possiblities of losing 1(one) item. This covers an item being sold, destroyed, or somehow consumed.
  elseif stackCountChange == -1 then
    TraitBuster:GraphTraits()
  end
end

--guaranteeing tooltips are updated between creation / destruction
function TraitBuster.OnCraftCompleted(event, craftSkill)
  TraitBuster:GraphTraits()
end

function TraitBuster.OnCraftingStationInteract(event, craftSkill, sameStation)
  TraitBuster:GraphTraits()
--i mute this event so it doesn't double fire on item destruction / consumption due to crafting. It's covered in the crafting finished event.
  EVENT_MANAGER:UnregisterForEvent(TraitBuster.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
end

function TraitBuster.OnEndCraftingStationInteract(event, craftSkill)
--unmute
  EVENT_MANAGER:RegisterForEvent(TraitBuster.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, TraitBuster.OnInventorySingleSlotUpdate)
end

----------------------------------------
--Events
----------------------------------------
EVENT_MANAGER:RegisterForEvent(TraitBuster.name, EVENT_ADD_ON_LOADED, TraitBuster.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(TraitBuster.name, EVENT_PLAYER_ACTIVATED, TraitBuster.OnPlayerActivated)
EVENT_MANAGER:RegisterForEvent(TraitBuster.name, EVENT_CRAFT_COMPLETED, TraitBuster.OnCraftCompleted)
EVENT_MANAGER:RegisterForEvent(TraitBuster.name, EVENT_CRAFTING_STATION_INTERACT, TraitBuster.OnCraftingStationInteract)
EVENT_MANAGER:RegisterForEvent(TraitBuster.name, EVENT_END_CRAFTING_STATION_INTERACT, TraitBuster.OnEndCraftingStationInteract)
EVENT_MANAGER:RegisterForEvent(TraitBuster.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, TraitBuster.OnInventorySingleSlotUpdate)
