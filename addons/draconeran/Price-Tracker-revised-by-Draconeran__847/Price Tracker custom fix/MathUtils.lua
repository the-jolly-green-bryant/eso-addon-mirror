if not PriceTracker then
	return
end

local MathUtils = {}
PriceTracker.mathUtils = MathUtils

function MathUtils:GetSortedPriceTable(itemTable)
	table.sort(itemTable, function(a, b) return (a.purchasePrice / a.stackCount) < (b.purchasePrice / b.stackCount) end)
	return itemTable
end

function MathUtils:WeightedAverage(itemTable)
	local sum = 0
	local weight = 0
	for i = 1, #itemTable do
		sum = sum + itemTable[i].purchasePrice
		weight = weight + itemTable[i].stackCount
	end
	item = {
		purchasePrice = math.floor(sum / weight),
		stackCount = 1
	}
	return item
end

function MathUtils:Median(itemTable)
	local itemTable = self:GetSortedPriceTable(itemTable)
	local index = math.floor((#itemTable + 1) / 2)
	if (index * 2 == #itemTable) then
		local item = {
			purchasePrice = math.floor((itemTable[index].purchasePrice / itemTable[index].stackCount) + (itemTable[index + 1].purchasePrice / itemTable[index + 1].stackCount)),
			stackCount = 1
		}
		return item
	else
		return itemTable[index]
	end
end

function MathUtils:Mode(itemTable)
	local itemTable = self:GetSortedPriceTable(itemTable)
	PriceTracker.itemTable = itemTable
	local number = itemTable[1]
	local mode = number
	local count = 1
	local countMode = 1

	for i = 2, #itemTable do
		if itemTable[i].price == number.price then
			count = count + 1
		else
			if count > countMode then
				countMode = count
				mode = number
			end
			count = 1
			number = prices[i]
		end
	end
	return mode
end

function MathUtils:Max(itemTable)
	local price = math.floor(itemTable[1].purchasePrice / itemTable[1].stackCount)
	local item = itemTable[1]
	for i = 2, #itemTable do
		local newPrice = math.floor(itemTable[i].purchasePrice / itemTable[i].stackCount)
		if newPrice > price then
			price = newPrice
			item = itemTable[i]
		end
	end
	return item
end

function MathUtils:Min(itemTable)
	local price = math.floor(itemTable[1].purchasePrice / itemTable[1].stackCount)
	local item = itemTable[1]
	for i = 2, #itemTable do
		local newPrice = math.floor(itemTable[i].purchasePrice / itemTable[i].stackCount)
		if newPrice < price then
			price = newPrice
			item = itemTable[i]
		end
	end
	return item
end
