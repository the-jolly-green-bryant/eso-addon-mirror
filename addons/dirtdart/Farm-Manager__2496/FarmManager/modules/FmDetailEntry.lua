FmDetailEntry = ZO_Object:Subclass()

function FmDetailEntry:New(item, actionType)
    local entry = ZO_Object.New(self)
    entry:Init(item, actionType)
    return entry
end

function FmDetailEntry:Init(item, actionType)
    self.texture = item.texture
    self.itemLink = item.itemLink
    self.itemId = item.itemId
    if actionType == ACTION_FARM then
        self.quantityFarmed = item.quantity
        self.totalValueFarmed = item.totalValue
        self.quantityDeposited = 0
        self.totalValueDeposited = 0
    else
        self.quantityDeposited = item.quantity
        self.totalValueDeposited = item.totalValue
        self.quantityFarmed = 0
        self.totalValueFarmed = 0
    end
end

function FmDetailEntry:Add(item, actionType)
    if actionType == ACTION_FARM then
        self.quantityFarmed = item.quantity
        self.totalValueFarmed = item.totalValue
    else
        self.quantityDeposited = item.quantity
        self.totalValueDeposited = item.totalValue
    end
end
