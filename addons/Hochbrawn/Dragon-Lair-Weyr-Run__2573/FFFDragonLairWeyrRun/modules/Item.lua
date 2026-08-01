Item = ZO_Object:Subclass()

function Item:New(itemLink, bar)
    local item = ZO_Object.New(self)
    item:Init(itemLink, bar)
    return item
end

function Item:Init(itemLink, bar)
    self.texture = GetItemLinkInfo(itemLink)
    self.itemId = GetItemLinkItemId(itemLink)
	self.itemType = GetItemLinkItemType(itemLink)
    self.itemLink = itemLink
	self.bar = bar
    self.quantity = 0
	self.incrementValue = 0
    self.totalValue = 0
    self.eventId = 0
    self.value = 0
end
