function Chess:split(s, delimiter)
	result = {};
	for match in (s..delimiter):gmatch("(.-)"..delimiter) do
		table.insert(result, match);
	end
	return result;
end

function Chess:isListNotEmpty(list)
	for _,_ in pairs(list) do
		return true
	end
	return false
end

function Chess:isListEmpty(list)
	return Chess:isListNotEmpty(list) ~= true
end

function Chess:listContainsElement(list, element)
	for k, v in pairs(list) do
		if (v == element) then
			return true
		end
	end
	return false
end

function Chess:closestInt(x)
	return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end