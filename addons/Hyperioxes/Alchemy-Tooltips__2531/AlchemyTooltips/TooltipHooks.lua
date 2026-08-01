local function ReturnItemLink(itemLink)
  return itemLink
end

local function TooltipHook(tooltipControl, method, linkFunc)
  local origMethod = tooltipControl[method]

  tooltipControl[method] = function(self, ...)
    local link = linkFunc(...)
    local text, quality, icon
    if GetItemLinkItemType(link) == ITEMTYPE_POISON or GetItemLinkItemType(link) == ITEMTYPE_POTION then
      text, quality, icon = ATT_Functions:processItemLink(link)
    else
      quality, icon = 0, 0
    end

    local orgText = GetString(SI_TOOLTIP_ITEM_NAME)
    if quality ~= 0 then
      local color = GetItemQualityColor(quality)
      SafeAddString(SI_TOOLTIP_ITEM_NAME, color:Colorize(GetString(SI_TOOLTIP_ITEM_NAME)), 1)
    end

    origMethod(self, ...)
    SafeAddString(SI_TOOLTIP_ITEM_NAME, orgText, 1)

    if icon ~= 0 then
      ZO_ItemIconTooltip_OnAddGameData(tooltipControl, TOOLTIP_GAME_DATA_ITEM_ICON, icon)
    end

    ATT_Functions:AddPotionInfo(self, ATT_Functions:checkPotion(link))

  end
end

local function TooltipHook_Gamepad(tooltipControl, method, linkFunc)
  local origMethod = tooltipControl[method]

  tooltipControl[method] = function(self, ...)
    local result = origMethod(self, ...)
    local link = linkFunc(...)
    local text, quality, icon
    if GetItemLinkItemType(link) == ITEMTYPE_POISON or GetItemLinkItemType(link) == ITEMTYPE_POTION then
      text, quality, icon = ATT_Functions:processItemLink(link)
    else
      quality, icon = 0, 0
    end

    local orgText = GetString(SI_TOOLTIP_ITEM_NAME)
    if quality ~= 0 then
      local color = GetItemQualityColor(quality)
      SafeAddString(SI_TOOLTIP_ITEM_NAME, color:Colorize(GetString(SI_TOOLTIP_ITEM_NAME)), 1)
    end

    SafeAddString(SI_TOOLTIP_ITEM_NAME, orgText, 1)

    if icon ~= 0 then
      ZO_ItemIconTooltip_OnAddGameData(tooltipControl, TOOLTIP_GAME_DATA_ITEM_ICON, icon)
    end
    ATT_Functions:AddPotionInfo(self, ATT_Functions:checkPotion(link))

    return result
  end
end

function ATT_HookBagTips()
  TooltipHook(ItemTooltip, "SetBagItem", GetItemLink)
  TooltipHook(ItemTooltip, "SetTradeItem", GetTradeItemLink)
  TooltipHook(ItemTooltip, "SetBuybackItem", GetBuybackItemLink)
  TooltipHook(ItemTooltip, "SetStoreItem", GetStoreItemLink)
  TooltipHook(ItemTooltip, "SetAttachedMailItem", GetAttachedItemLink)
  TooltipHook(ItemTooltip, "SetLootItem", GetLootItemLink)
  TooltipHook(ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink)
  TooltipHook(ItemTooltip, "SetTradingHouseListing", GetTradingHouseListingItemLink)
  TooltipHook(ItemTooltip, "SetLink", ReturnItemLink)
  TooltipHook(PopupTooltip, "SetLink", ReturnItemLink)

  TooltipHook_Gamepad(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP), "LayoutItem", ReturnItemLink)
  TooltipHook_Gamepad(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_RIGHT_TOOLTIP), "LayoutItem", ReturnItemLink)
  TooltipHook_Gamepad(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_MOVABLE_TOOLTIP), "LayoutItem", ReturnItemLink)
end