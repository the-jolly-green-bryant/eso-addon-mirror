FmItem = ZO_Object:Subclass()

function FmItem:New(itemLink)
    local item = ZO_Object.New(self)
    item:Init(itemLink)
    return item
end

function FmItem:Init(itemLink)
    self.texture = GetItemLinkInfo(itemLink)
    self.itemId = GetItemLinkItemId(itemLink)
    self.itemLink = itemLink
    self.quantity = 0
    self.totalValue = 0
    self.eventId = 0
    self.value = 0
end
