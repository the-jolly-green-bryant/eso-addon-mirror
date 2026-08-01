local SPH = SamisPotionHelperAddon

SPH.utils = {
  filteredItemTypes = {
    [ITEMTYPE_FOOD] = true,
    [ITEMTYPE_DRINK] = true,
    [ITEMTYPE_POTION] = true,
    [ITEMTYPE_POISON] = true,
    [ITEMTYPE_TRASH] = true,
  },
  sellAlliancePotions = true,
  customFilters = {},
}

function SPH.utils.syncSavedVarsToUtils()
  if not SPH.savedVariables then return end

  SPH.utils.filteredItemTypes[ITEMTYPE_FOOD] = SPH.savedVariables.filterFood
  SPH.utils.filteredItemTypes[ITEMTYPE_DRINK] = SPH.savedVariables.filterFood
  SPH.utils.filteredItemTypes[ITEMTYPE_POISON] = SPH.savedVariables.filterPoisons
  SPH.utils.filteredItemTypes[ITEMTYPE_TRASH] = SPH.savedVariables.filterMerchantItems
  SPH.utils.sellAlliancePotions = SPH.savedVariables.sellAlliancePotions

  -- Parse custom filter text
  SPH.utils.customFilters = {}
  if SPH.savedVariables.customFilterText and SPH.savedVariables.customFilterText ~= "" then
    for filterText in string.gmatch(SPH.savedVariables.customFilterText, "([^,\n]+)") do
      -- Skip the first space after a comma, but preserve spaces within the token
      local afterCommaSpace = string.gsub(filterText, "^ ", "", 1)
      -- Trim remaining leading and trailing spaces
      local trimmedFilter = string.match(afterCommaSpace, "^%s*(.-)%s*$")
      if trimmedFilter ~= "" then
        table.insert(SPH.utils.customFilters, string.lower(trimmedFilter))
      end
    end
  end
end

function SPH.utils.getItemTotalSellPrice(bagId, slotIndex)
  local icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyleId, quality = GetItemInfo(bagId,
    slotIndex)
  if locked then return 0 end
  return stack * sellPrice
end

function SPH.utils.isSellable(bagId, slotIndex)
  local icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyleId, quality = GetItemInfo(bagId,
    slotIndex)

  return sellPrice > 0 and not locked
end

function SPH.utils.isAlliancePotion(itemLink)
  if not itemLink then
    return false
  end

  local itemName = string.lower(zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(itemLink)))
  return string.find(itemName, "alliance") ~= nil
end

function SPH.utils.matchesCustomFilter(itemLink)
  if not itemLink or #SPH.utils.customFilters == 0 then
    return false
  end

  local itemName = string.lower(zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(itemLink)))

  for _, filterPattern in ipairs(SPH.utils.customFilters) do
    if string.find(itemName, filterPattern, 1, true) then
      return true
    end
  end

  return false
end

function SPH.utils.markItemAsTrash(bagId, slotIndex, itemLink)
  if not itemLink then
    itemLink = GetItemLink(bagId, slotIndex, 1)
  end

  if not itemLink then return end

  local itemName = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(itemLink))
  local lowerItemName = string.lower(itemName)

  -- Track if this is a new item
  if not SPH.savedVariables.markedTrashItems[lowerItemName] then
    SPH.savedVariables.markedTrashItems[lowerItemName] = true
    d(SPH.displayName .. ": Marked as trash - " .. itemLink)
  end

  -- Mark the item as junk
  SetItemIsJunk(bagId, slotIndex, true)
end

function SPH.utils.shouldFlagAsJunk(bagId, slotIndex)
  if not SPH.utils.isSellable(bagId, slotIndex) then
    return false
  end

  local shouldFlagStolenItems = SPH.savedVariables and SPH.savedVariables.flagStolenItemsAsTrash
  if shouldFlagStolenItems == false and IsItemStolen and IsItemStolen(bagId, slotIndex) then
    return false
  end

  local itemLink = GetItemLink(bagId, slotIndex, 1)
  if not itemLink then
    return false
  end

  -- Check custom filter first
  if SPH.utils.matchesCustomFilter(itemLink) then
    return false
  end

  local isCrafted = IsItemLinkCrafted(itemLink)

  if isCrafted then
    return false
  end

  local itemType = GetItemLinkItemType(itemLink)

  if itemType == ITEMTYPE_POTION and SPH.utils.isAlliancePotion(itemLink) then
    return SPH.utils.sellAlliancePotions
  end

  if SPH.utils.filteredItemTypes[itemType] then
    return true
  end

  local filterMerchantItems = SPH.savedVariables and SPH.savedVariables.filterMerchantItems
  if filterMerchantItems and IsItemLinkPrioritySell(itemLink) then
    return true
  end

  return false
end
