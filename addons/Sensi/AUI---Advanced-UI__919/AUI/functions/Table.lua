AUI.Table = {}

function AUI.Table.GetChoiceList(t, mode)
	local nt = {}

	for ik, iv in pairs(t) do
		for k, v in pairs(t[ik]) do	
			if mode == "key" then
				table.insert(nt, k)
			elseif mode == "value" then
				table.insert(nt, v)
			end
		end
	end
	
	return nt
end

function AUI.Table.GetKey(t, value)
	if t and type(t) == "table" then	
		for k, v in pairs(t) do	
			if k and v then
				if v == value then
					return k
				end	
				
				if t[k]then	
					local result = AUI.Table.GetKey(t[k], value)
					
					if result then
						return result				
					end			
				end
			end
		end
	end
	
	return nil
end

function AUI.Table.GetValue(t, key)
	if t and type(t) == "table" then	
		for k, v in pairs(t) do	
			if k and v then
				if k == key then		
					return v
				end
				
				if t[k] then	
					local result = AUI.Table.GetValue(t[k], key)
					
					if result then
						return result		
					end			
				end
			end
		end
	end
	
	return nil
end

function AUI.Table.Copy(obj)
	if type(obj) ~= 'table' then 
		return obj 
	end
	
	local s = {}
	local res = setmetatable({}, getmetatable(obj))
	s[obj] = res
	
	for k, v in pairs(obj) do 
		res[AUI.Table.Copy(k, s)] = AUI.Table.Copy(v, s) 
	end
	
	return res
end

function AUI.Table.GetLength(t)
	local length = 0
	for _, _ in pairs(t) do	
		length = length + 1
	end

	return length
end

function AUI.Table.HasContent(t)
	for _, _ in pairs(t) do	
		return true
	end

	return false
end

function AUI.Table.GetKeysSortedByValue(tbl, sortFunction, param)
	local keys = {}
	for key in pairs(tbl) do
		table.insert(keys, key)
	end

	table.sort(keys, function(a, b)
	return sortFunction(tbl[a], tbl[b], param)
	end)

	return keys
end