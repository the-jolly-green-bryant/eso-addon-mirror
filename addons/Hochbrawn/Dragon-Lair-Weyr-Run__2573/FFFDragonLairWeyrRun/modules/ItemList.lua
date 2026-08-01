ItemList = ZO_Object:Subclass()
--local wr = FFFDragonLairWeyrRun

-- Getvalue function edited for MM for now.  May add arkadius when menu added for selection.
local function GetValue(itemLink)
	--if wr.settings.db.useMM then
	if MasterMerchant ~= nil then
		local mmValue = MasterMerchant:itemStats(itemLink)["avgPrice"]
		if mmValue ~= nil then
			return math.floor(mmValue)
		end
	end
	
	if ArkadiusTradeTools ~= nil then
		local mmValue = ArkadiusTradeTools.Modules.Sales:GetAveragePricePerItem(itemLink)
		if mmValue ~= nil then
			return math.floor(mmValue)
		end
	end
	
	local _, vendorValue = GetItemLinkInfo(itemLink)
	if vendorValue ~= nil then 
		return math.floor(vendorValue)
	else 
		return 5
	end
	
	
end

function ItemList:New()
    local itemList = ZO_Object.New(self)
    itemList:Init()
    return itemList
end

function ItemList:Init()
	self.totalValue = 0
	self.items = {}

end
function ItemList:ItemList()
	return self.items
	
end
function ItemList:ItemListTotal()
	--returns the total value of items from the player
	return self.totalValue
end


function ItemList:Add(itemLink, quantity, bar)
	-- get itemId from the ItemLink
	local itemId = GetItemLinkItemId(itemLink)
	-- if the itemId is not in our list of items then create a new one.
    if self.items[itemId] == nil then
		-- our list of items are class items from Item.lua
        self.items[itemId] = Item:New(itemLink, bar)
    end

    local item = self.items[itemId] -- item is the specific item being added
	-- use the local function the MM or Vendor value for the itemLink
    local value = GetValue(itemLink)
	-- increment the quantity collected
	item.quantity = item.quantity + quantity
	-- store the per item value
	item.value = value
	-- incremental value of current looting
	item.incrementValue = value * quantity
	-- increment the total value collected of this item
    item.totalValue = item.totalValue + (value * quantity)
	-- increment the total value of the items in our itemlist for the player
	self.totalValue = self.totalValue + (value * quantity)
	return item
end

-- need subtract functions
function ItemList:Subtract(itemId, quantity)
	-- remove items from player 
	--d("self items..",self.items)
	-- check if still exists
	if self.items[itemId] == nil then return end
	--d("found it in the list")
	-- get item
	local Ritem = self.items[itemId]
	-- incremental value (negative for removal)
	Ritem.incrementValue = -1 * (Ritem.value * quantity)
	-- reduce item quantity
	Ritem.quantity = Ritem.quantity - quantity
	-- reduce total value of item by quantity removed and recorded value
	Ritem.totalValue = Ritem.totalValue - (Ritem.value * quantity)
	-- reduce player total value by item value removed
	self.totalValue = self.totalValue - (Ritem.value * quantity)
	return Ritem
end

	

function ItemList:Get(itemLink)
	local itemId = GetItemLinkItemId(itemLink)
	return self.items[itemId]
end



