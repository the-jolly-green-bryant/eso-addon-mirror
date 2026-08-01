RawLootItem = ZO_Object:Subclass()
-- this is to be the raw loot transaction to store in saved variables
-- transaction would be updated per player and per loot item. ie quantities would increase not repeat entreies
-- when restoring these transactions would be reapplied restoring the state prior to reload or crash 
function RawLootItem:New(itemLink)
    local item = ZO_Object.New(self)
    item:Init(itemLink)
    return item
end

function RawLootItem:Init(itemLink)
    self.itemLink = itemLink
    self.lootquantity = 0
	self.depositquantity = 0
end
