local Addon = FarmingPartyPlus
local MemberItem = {}

Addon.MemberItem = MemberItem

function MemberItem:New(itemLink)
  return {
    itemLink = itemLink,
    count = 0,
    value = 0,
    totalValue = 0
  }
end

function MemberItem:UpdateItemCount(item, value, count)
  item.count = item.count + count
  item.value = value
  item.totalValue = item.count * item.value
  return item
end
