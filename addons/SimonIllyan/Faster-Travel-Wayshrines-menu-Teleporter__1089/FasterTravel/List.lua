

local List = FasterTravel.class()
FasterTravel.List = List

function List:init(items,key,size)
	local lookup = {}
	local items = items or {}
	
	for i=1,#items do
		if i <= size then 
			lookup[items[i][key]] = i 
		else
			table.remove(items)
		end
	end
	
	local function ReIndex(key)
		local count = #items
		for i=1,count do
			lookup[items[i][key]] = i 
		end
	end
	
	local function RemoveItem(idx, key,value)
		lookup[value[key]] = nil
		table.remove(items,idx)
	end 
	
	self.add = function(self,key,value)
		local idx = lookup[value[key]]
		local count = #items
		if idx ~= nil then 
			RemoveItem(idx,key,value)
			count = count-1
		end
		if count < size then 
			table.insert(items,value)
			ReIndex(key)
		end
	end
	
	self.remove = function(self,key,value)
		local idx = lookup[value[key]]
		if idx ~= nil then
			RemoveItem(idx,key,value)
			ReIndex(key)
		end
	end
	
	self.contains = function(self,value)
		return lookup[value] ~= nil
	end
	
	self.push = function(self,key,value)
		local vk = value[key]
		local idx = lookup[vk]
		local count = #items
		if idx ~= nil then 
			RemoveItem(idx,key,value)
			ReIndex(key)
			count = count-1
		end
		if count <= size then 
			for i = 1,count do
				lookup[items[i][key]]=i+1
			end
			if count == size then 
				local victim = items[count]
				lookup[victim[key]] = nil 
				table.remove(items)
			end
			table.insert(items,1,value)
			lookup[vk]=1
		end
		return self
	end

	self.items = function(self)
		local cur = 0
		local count = math.min(#items,size)
		return function()
			if cur < count then
				cur = cur + 1 
				return items[cur]
			end
			return nil
		end
	end
	
end