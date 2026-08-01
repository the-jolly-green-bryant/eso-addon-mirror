local SFT = SamisFishTrackerAddon

SFT.utils = {}

local inventoryItemLinkCache = {
  [BAG_BACKPACK] = {
    fish = {},
  },
  [BAG_SUBSCRIBER_BANK] = {
    perfectRoe = {},
  },
}

function SFT.utils.cacheItemLink(bagId, slotIndex, itemLink)
  if bagId == BAG_BACKPACK then
    local itemType = GetItemLinkItemType(itemLink)

    if itemType == ITEMTYPE_FISH then
      inventoryItemLinkCache[BAG_BACKPACK].fish[slotIndex] = itemLink
    end
  elseif bagId == BAG_SUBSCRIBER_BANK then
    local itemId = GetItemLinkItemId(itemLink)

    if itemId == SFT.constants.perfectRoeItemId then
      inventoryItemLinkCache[BAG_SUBSCRIBER_BANK].perfectRoe[slotIndex] = itemLink
    end
  end
end

function SFT.utils.cacheFish(fish)
  inventoryItemLinkCache[BAG_BACKPACK].fish = fish
end

-- Function to get fish item link from cache based on slotIndex
function SFT.utils.getCachedFishItemLink(slotIndex)
  return inventoryItemLinkCache[BAG_BACKPACK].fish[slotIndex]
end

-- Function to get perfect roe item link from cache based on slotIndex
function SFT.utils.getCachedPerfectRoeItemLink(slotIndex)
  return inventoryItemLinkCache[BAG_SUBSCRIBER_BANK].perfectRoe[slotIndex]
end
