DetailEntry = ZO_Object:Subclass()

-- I only understand the use for ACTION_FARM.
-- Likely other actions would be for depositing.  Future.

function DetailEntry:New(item)
    local entry = ZO_Object.New(self)
    entry:Init(item)--, actionType)
    return entry
end

function DetailEntry:Init(item) --, actionType)
    self.texture = item.texture
    self.itemLink = item.itemLink
    self.itemId = item.itemId
    --if actionType == ACTION_FARM then
        self.quantityFarmed = item.quantity
        self.totalValueFarmed = item.totalValue
        self.quantityDeposited = 0
        self.totalValueDeposited = 0
    --else
	-- this to be updated when depositing, reducing values
        -- self.quantityDeposited = item.quantity
        -- self.totalValueDeposited = item.totalValue
        -- self.quantityFarmed = 0
        -- self.totalValueFarmed = 0
    --end
end

function DetailEntry:Add(item) --, actionType)
    --if actionType == ACTION_FARM then
        self.quantityFarmed = item.quantity
        self.totalValueFarmed = item.totalValue
    -- else
	-- -- this to be updated when depositing, reducing values
        -- self.quantityDeposited = item.quantity
        -- self.totalValueDeposited = item.totalValue
    -- end
end
