local function ItemHook(functionName, itemLinkFunction, exception, tableOfOrder)
  local old = _G[functionName]
  _G[ATT_Variables.name][functionName] = old
  _G[functionName] = function(...)
    local link = itemLinkFunction(...)
    if GetItemLinkItemType(link) == ITEMTYPE_POISON or GetItemLinkItemType(link) == ITEMTYPE_POTION then
      local newText, qualityNumber, iconTexture = ATT_Functions:processItemLink(link)
      if exception == "Quality" then
        if ATT_savedVars.useCustomQualities then
          return qualityNumber
        end
      elseif exception == "Name" then
        if ATT_savedVars.useCustomNames then
          return newText
        end
      else
        local data = { old(...) } --{icon,name,quality}
        if iconTexture ~= 0 and ATT_savedVars.useCustomIcons then
          data[tableOfOrder[1]] = iconTexture
        end
        if ATT_savedVars.useCustomNames then
          data[tableOfOrder[2]] = newText
        end
        if qualityNumber ~= 0 and ATT_savedVars.useCustomQualities then
          data[tableOfOrder[3]] = qualityNumber
        end
        return unpack(data)
      end
    end
    return old(...)
  end
end

local function ItemHookIcon()
  local old = _G["GetSlotTexture"]
  _G[ATT_Variables.name]["GetSlotTexture"] = old
  _G["GetSlotTexture"] = function(...)
    local link = GetSlotItemLink(...)
    if GetItemLinkItemType(link) == ITEMTYPE_POISON or GetItemLinkItemType(link) == ITEMTYPE_POTION then
      local iconTexture = ATT_Functions:GetCustomIconFromItemLink(link)
      if iconTexture and ATT_savedVars.useCustomIcons then
        return iconTexture
      end
    end
    return old(...)
  end
end

local function ItemHookQuality()
  local old = _G["GetSlotItemDisplayQuality"]
  _G[ATT_Variables.name]["GetSlotItemDisplayQuality"] = old
  _G["GetSlotItemDisplayQuality"] = function(...)
    local link = GetSlotItemLink(...)
    if GetItemLinkItemType(link) == ITEMTYPE_POISON or GetItemLinkItemType(link) == ITEMTYPE_POTION then
      local quality = ATT_Functions:GetCustomQualityFromItemLink(link)
      if quality and ATT_savedVars.useCustomQualities then
        return quality
      end
    end
    return old(...)
  end
end

local function ItemHookAttachedIcon()
  local old = _G["GetQueuedItemAttachmentInfo"]
  _G[ATT_Variables.name]["GetQueuedItemAttachmentInfo"] = old
  _G["GetQueuedItemAttachmentInfo"] = function(...)
    local data = { old(...) } -- bagId, slotIndex, icon, stack
    local link = GetItemLink(data[1], data[2])
    if GetItemLinkItemType(link) == ITEMTYPE_POISON or GetItemLinkItemType(link) == ITEMTYPE_POTION then
      local iconTexture = ATT_Functions:GetCustomIconFromItemLink(link)
      if iconTexture and ATT_savedVars.useCustomIcons then
        data[3] = iconTexture
        return unpack(data)
      end
    end
    return old(...)
  end
end

function ATT_HookItems()
  ItemHook("GetTradingHouseListingItemInfo", GetTradingHouseListingItemLink, nil, { 1, 2, 3 }) -- guild trader
  ItemHook("GetTradingHouseSearchResultItemInfo", GetTradingHouseSearchResultItemLink, nil, { 1, 2, 3 })

  ItemHookQuality() -- quick slots
  ItemHookIcon()
  ItemHook("GetSlotName", GetSlotItemLink, "Name")

  ItemHook("GetItemInfo", GetItemLink, nil, { 1, 0, 9 }) -- bags
  ItemHook("GetItemName", GetItemLink, nil, { 0, 1, 0 })

  ItemHook("GetTradeItemInfo", GetTradeItemLink, nil, { 2, 1, 4 }) -- trade between players

  ItemHook("GetBuybackItemInfo", GetBuybackItemLink, nil, { 1, 2, 7 }) -- buyback

  ItemHook("GetAttachedItemInfo", GetAttachedItemLink, nil, { 1, 0, 0 }) -- mail
  ItemHookAttachedIcon()

  --overrideZosFunction("GetLootItemInfo", GetLootItemLink, nil,{3,2,5}) -- loot, not needed for now and also bugged
end