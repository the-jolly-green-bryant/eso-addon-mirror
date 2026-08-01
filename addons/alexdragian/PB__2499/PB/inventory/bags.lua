local EM = GetEventManager()
local LF = LibFilters3

function PB.SetTrackerBagHook()
  
  LF:InitializeLibFilters()

  local storeFilterCallback = function(slot)
    local creator = GetItemCreatorName( slot.bagId, slot.slotIndex )
    local itemSellInfo =  GetItemSellInformation( slot.bagId, slot.slotIndex )
    local itemTraitInfo = GetItemTraitInformation( slot.bagId, slot.slotIndex )
    if PB.db.default.options.vendor.hideCrafted and creator ~= nil and creator ~= "" then
      return false
    elseif PB.db.default.options.vendor.hideUnsellable and itemSellInfo == ITEM_SELL_INFORMATION_CANNOT_SELL then
      return false
    elseif PB.db.default.options.vendor.hideReconstruction and itemTraitInfo == ITEM_TRAIT_INFORMATION_RECONSTRUCTED then
      return false
    elseif PB.db.default.options.vendor.hideTransmutation and itemTraitInfo == ITEM_TRAIT_INFORMATION_RETRAITED then
      return false
    else
      return true
    end
  end

  local deconstructFilterCallback = function(bagId, slotIndex)
    local creator = GetItemCreatorName( bagId, slotIndex )
    local itemTraitInfo = GetItemTraitInformation( bagId, slotIndex )
    if PB.db.default.options.deconstruct.hideCrafted and creator ~= nil and creator ~= "" then
      return false
    elseif PB.db.default.options.deconstruct.hideReconstruction and itemTraitInfo == ITEM_TRAIT_INFORMATION_RECONSTRUCTED then
      return false
    elseif PB.db.default.options.deconstruct.hideTransmutation and itemTraitInfo == ITEM_TRAIT_INFORMATION_RETRAITED then
      return false
    else
      return true
    end
  end

  local extractionFilterCallback = function(bagId, slotIndex)
    local creator = GetItemCreatorName( bagId, slotIndex )
    if PB.db.default.options.deconstruct.hideCrafted and creator ~= nil and creator ~= "" then
      return false
    else
      return true
    end
  end

  LF:RegisterFilter(PB.addon, LF_VENDOR_SELL, storeFilterCallback)
  LF:RegisterFilter(PB.addon, LF_SMITHING_DECONSTRUCT, deconstructFilterCallback)
  LF:RegisterFilter(PB.addon, LF_JEWELRY_DECONSTRUCT, deconstructFilterCallback)
  LF:RegisterFilter(PB.addon, LF_ENCHANTING_EXTRACTION , extractionFilterCallback)
  LF:RequestUpdate(LF_VENDOR_SELL)
  LF:RequestUpdate(LF_SMITHING_DECONSTRUCT)
  LF:RequestUpdate(LF_JEWELRY_DECONSTRUCT)
  LF:RequestUpdate(LF_ENCHANTING_EXTRACTION )

end