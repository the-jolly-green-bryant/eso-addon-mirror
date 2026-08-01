local kname = "J2E"
local data = {}
--ItemLinkからID取得
local function GetItemID(itemLink)
  local itemId = itemLink:match("|H[^:]+:item:([^:]+):")
  -- d("itemLink:"..itemLink)
  return tonumber(itemId)
end
--Tooltipに文字列追加
local function AddItemInfo(tooltip,id,isGamepadMpde)
  tooltip:AddVerticalPadding(0)
  if id == nil then return end
  if itemTable[id] == nil then return end
  tooltip:AddLine("英語名 : "..itemTable[id], "", 0.8, 0.8, 0.8, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
  -- tooltip:AddHeaderLine("英語名 : "..itemTable[id], "", 1, TOOLTIP_HEADER_SIDE_RIGHT, 1, 1, 1)
end
local function AddItemInfoGamepad(tooltip,id)
  --tooltip:AddVerticalPadding(0)
  if id == nil then return end
  if itemTable[id] == nil then return end
  tooltip:AddLine("英語名 : "..itemTable[id], GAMEPAD_STYLE_1, tooltip:GetStyle("bodySection"))
end
--ItemTooltop関数のオーバーライド
local function itemTooltopHook(tooltipControl, method, linkFunc)
  local origMethod = tooltipControl[method]
  tooltipControl[method] = function(self, ...)
    origMethod(self, ...)
    AddItemInfo(self, GetItemID(linkFunc(...)))
  end
end
local function popupTooltopHook(tooltipControl, method, linkFunc)
  local origMethod = tooltipControl[method]
  tooltipControl[method] = function(self, link)
    origMethod(self, link)
    AddItemInfo(self, GetItemID(link))
  end
end
local function wornTooltopHook(tooltipControl, method, linkFunc)
  local origMethod = tooltipControl[method]
  tooltipControl[method] = function(self, ...)
    origMethod(self, ...)
    AddItemInfo(self, GetItemID(linkFunc(BAG_WORN,...)))
  end
end
local function gamepadTooltopHook(tooltipControl, method, linkFunc)
  local origMethod = tooltipControl[method]
  tooltipControl[method] = function(self, ...)
    origMethod(self, ...)
    AddItemInfo(self, GetItemID(linkFunc(BAG_WORN,...)))
  end
end
--ItemTooltipのクリア
local function itemTooltopClearLinesHook(tooltipControl, method)
  local origMethod = tooltipControl[method]
  tooltipControl[method] = function(self, ...)
    origMethod(self, ...)
  end
end
--AbilityTooltipのクリア
local function abilityTooltopClearLinesHook(tooltipControl, method)
  local origMethod = tooltipControl[method]
  tooltipControl[method] = function(self, ...)
    origMethod(self, ...)
  end
end
--AbilityTooltop関数のオーバーライド
local function abilityTooltipSkillLineHook(tooltipControl, method,func)
  local origMethod = tooltipControl[method]
  tooltipControl[method] = function(self, ...)
    origMethod(self, ...)
    local name , rank = func(...)
    -- d("スキルライン:"..name)
  end
end
local function abilityTooltipHook(tooltipControl, method,func)
  local origMethod = tooltipControl[method]
  tooltipControl[method] = function(self, ...)
    origMethod(self, ...)
    local id = func(...)
    -- d(method.." スキルID:"..id.."")
    if abilityTable[id] == nil then return end
    -- d(method.." スキルID:"..id.." 名:"..abilityTable[id])
    -- self:AddHeaderLine(" "..abilityTable[id], "", 1, TOOLTIP_HEADER_SIDE_RIGHT, 1, 1, 1)
    self:AddLine("英語名: "..abilityTable[id], "", 0.8, 0.8, 0.8, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
  end
end
local function ReturnItemLink(itemLink)
  return itemLink
end
local function OnAddOnLoaded(event, addonName)
  if addonName ~= kname then return end
  EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)
  
  popupTooltopHook(PopupTooltip, "SetLink", GetItemLink)
  wornTooltopHook(ItemTooltip, "SetWornItem", GetItemLink)
  
  itemTooltopHook(ItemTooltip, "SetBagItem", GetItemLink)
  itemTooltopHook(ItemTooltip, "SetBuybackItem", GetBuybackItemLink)
  itemTooltopHook(ItemTooltip, "SetTradeItem", GetTradeItemLink)
  itemTooltopHook(ItemTooltip, "SetStoreItem", GetStoreItemLink)
  itemTooltopHook(ItemTooltip, "SetAttachedMailItem", GetAttachedItemLink)
  itemTooltopHook(ItemTooltip, "SetLootItem", GetLootItemLink)
  itemTooltopHook(ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink)
  itemTooltopHook(ItemTooltip, "SetTradingHouseListing", GetTradingHouseListingItemLink)
  itemTooltopHook(ItemTooltip, "SetLink", ReturnItemLink)
  itemTooltopClearLinesHook(ItemTooltip, "ClearLines")
  --]]
  abilityTooltipSkillLineHook(SkillTooltip, "SetSkillLine",GetSkillLineInfo)
  abilityTooltipHook(SkillTooltip, "SetSkillAbility",GetSkillAbilityId)
  -- abilityTooltipHook(SkillTooltip, "SetAbility",GetSkillAbilityId)
  -- abilityTooltipHook(SkillTooltip, "SetSkillUpgradeAbility")
  
  --abilityTooltopClearLinesHook(AbilityTooltip, "ClearLines")
  --abilityTooltopClearLinesHook(SkillTooltip, "ClearLines")
		local GP_LEFT = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP)
		local GP_LEFT_LayoutBagItem = GP_LEFT.LayoutBagItem
		GP_LEFT.LayoutBagItem = function(control, bagId, slotIndex, ...)
			local ret = GP_LEFT_LayoutBagItem(control, bagId, slotIndex, ...)
			AddItemInfoGamepad(control,GetItemID(GetItemLink(bagId, slotIndex)))
			return ret
		end
  
end

EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

