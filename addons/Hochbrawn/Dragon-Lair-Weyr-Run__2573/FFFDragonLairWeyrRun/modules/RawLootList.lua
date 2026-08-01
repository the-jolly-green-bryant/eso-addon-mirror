RawLootList = ZO_Object:Subclass()

function RawLootList:New()
    local rawlootList = ZO_Object.New(self)
    rawlootList:Init()
    return rawlootList
end

function RawLootList:Init()
	self.items = {}
end

function RawLootList:RawLootList()
	return self.items
end


function RawLootList:Add(itemLink, lootedquantity, depositedquantity)
	-- get itemId from the ItemLink
	local itemId = GetItemLinkItemId(itemLink)
	-- if the itemId is not in our list of items then create a new one.
	-- itemId is the key and the new RawLootItem is the value.
	-- so dont need to store itemId in RawLootItem
    if self.items[itemId] == nil then
		-- our list of items are class items from Item.lua
        self.items[itemId] = RawLootItem:New(itemLink)
    end

    local item = self.items[itemId] -- item is the specific item being added
   
	-- increment the quantity collected
	item.lootquantity = item.lootquantity + lootedquantity
	-- when restoring this will get set, in looting this will be sent as 0
	item.depositquantity = item.depositquantity + depositedquantity
	
	return item
end
-- maybe a deposit function instead of subtract. the changes to loot and deposit quantity can
-- happen in here

function RawLootList:Deposit(itemLink, quantity)
	-- get itemId from the ItemLink
	local itemId = GetItemLinkItemId(itemLink)
	-- if the itemId is not in our list of items then create a new one.
	-- itemId is the key and the new RawLootItem is the value.
	-- so dont need to store itemId in RawLootItem
    if self.items[itemId] == nil then
		-- our list of items are class items from Item.lua
        self.items[itemId] = RawLootItem:New(itemLink)
    end

    local item = self.items[itemId] -- item is the specific item being added
   
	-- decrement the quantity looted by amount deposited to a minimum of 0
	item.lootquantity = item.lootquantity - quantity
	if item.lootquantity < 0 then item.lootquantity = 0 end 
	-- increment the quantity deposited
	item.depositquantity = item.depositquantity + quantity
	
	return item
end
-- need subtract functions
function RawLootList:Subtract(itemId, quantity)
	-- remove items from player 
	--d("self items..",self.items)
	-- check if still exists
	if self.items[itemId] == nil then return end
	--d("found it in the list")
	-- get item
	local Ritem = self.items[itemId]
	-- reduce item quantity
	Ritem.lootquantity = Ritem.lootquantity - quantity

	return Ritem
end

	

function RawLootList:Get(itemLink)
	local itemId = GetItemLinkItemId(itemLink)
	return self.items[itemId]
end



