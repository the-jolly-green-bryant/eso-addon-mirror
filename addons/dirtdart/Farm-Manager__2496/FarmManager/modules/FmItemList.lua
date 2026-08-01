FmItemList = ZO_Object:Subclass()
local fm = FarmManager

local function GetValue(itemLink)
	if fm.settings.db.useMM then
		if MasterMerchant ~= nil then
			local mmValue = MasterMerchant:itemStats(itemLink)["avgPrice"]
			if mmValue ~= nil then
				return mmValue
			end
		end
	else
		if ArkadiusTradeTools ~= nil then
			local mmValue = ArkadiusTradeTools.Modules.Sales:GetAveragePricePerItem(itemLink)
			if mmValue ~= nil then
				return mmValue
			end
		end
	end

	local _, vendorValue = GetItemLinkInfo(itemLink)

	return vendorValue
end

function FmItemList:New()
    local itemList = ZO_Object.New(self)
    itemList:Init()
    return itemList
end

function FmItemList:Init()
	self.totalValue = 0
	self.items = {}
end

function FmItemList:Add(itemLink, quantity)
	local itemId = GetItemLinkItemId(itemLink)
    if self.items[itemId] == nil then
        self.items[itemId] = FmItem:New(itemLink)
    end

    item = self.items[itemId]

    local value = LibPrice.ItemLinkToPriceGold(itemLink)
	item.quantity = item.quantity + quantity
	item.value = value
    item.totalValue = item.totalValue + (value * quantity)
	self.totalValue = self.totalValue + (value * quantity)
	return item
end

function FmItemList:Get(itemLink)
	local itemId = GetItemLinkItemId(itemLink)
	return self.items[itemId]
end