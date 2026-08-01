LibAkaUtils = LibAkaUtils or {}

function LibAkaUtils.forLoop(startIndex, endIndex, increment, func)
	for index = startIndex,endIndex,increment do 
		func(index)
	end
end

function LibAkaUtils.forLoopToEnd(endIndex, func)
	LibAkaUtils.forLoop(1, endIndex, 1, func)
end

function LibAkaUtils.forStartUntilNil(list, startIndex, func)
	if list == nil then return end
	if func == nil then return end
	if startIndex == nil then return end
	local data = list[startIndex]
	if data == nil then return end
	func(startIndex, data)
	LibAkaUtils.forStartUntilNil(list, startIndex + 1, func)
end

function table.forEachFilterNil(self, func)
	table.foreach(self, function(k,v)
		if v ~= nil then
			func(k,v)
		end
	end)
end

function table.getListSizeFilterNil(self)
	if self == nil then return 0 end
	local index = 0
	table.foreach(self, function(_,v)
		if v ~= nil then
			index = index + 1
		end
	end)
	return index
end

function table.getListSize(self)
	if self == nil then return end
	local index = 0
	table.foreachi(self, function()
		index = index + 1
	end)
	return index
end

function table.listContains(self, value)
	if self == nil then 
		return false, nil
	end
	local key = nil
	table.foreach(self, function(k,v)
		if v == value then 
			key = k
		end
	end)
	return key ~= nil, key
end

function table.listContainsKey(self, key)
	if self == nil then 
		return false 
	end
	return self[key] ~= nil
end

function table.getInListAtIndex(self, index)
	if self == nil then return nil end
	if index == nil then return nil end
	local out = nil
	local i = 1
	table.foreachi(self, function(_, value)
		if index == i then
			out = value
		end
		i = i + 1
	end)
	return out
end

function table.joinToString(self, valueBetween)
	if self == nil then return nil end
	if valueBetween == nil then valueBetween = "" end
	local out = table.concat(self, valueBetween)
	return out
end

function table.setStringList(self)
	if self == nil then return end
	table.foreach(self, function(k,v)
		ZO_CreateStringId(k, v)
	end)
end

function table.getFromListAndAddToStringIfNotNil(self, str, index, ifnil)
	if ifnil == nil then ifnil = "" end
	if str == nil then return "" end
	if self == nil then return str end
	if index == nil then return str end
	local item = table.getInListAtIndex(self, index)
	if item == nil then return str..ifnil end
	return str..item
end

function table.pack(...)
	return {...}
end

function table.unpack(self)
	return unpack(self)
end