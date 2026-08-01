LibAkaUtils = LibAkaUtils or {}

function string.replace(self, repl, to)
	if self == nil then return "" end
	if repl == nil then return self end
	self = string.gsub(self, repl, LibAkaUtils.getOrInit(to, ""))
	return self
end

function string.startsWith(self, prefix)
	return self:sub(1, #prefix) == prefix
end

function string.substring(self, startIndex, endIndex)
	if self == nil then return "" end
	if startIndex > endIndex then return "" end
	if startIndex > string.length(self) then return "" end
	if endIndex > string.length(self) then 
		return string.sub(self, startIndex, string.length(self))
	end
	self = string.sub(self, startIndex, endIndex)
	return self
end

function string.setFirstLetterUppercase(self)
	if self == nil then return "" end
	local first = string.toUppercase(string.substring(self, 1, 1))
	local rest = string.substring(self, 2, #self)
	self = first..rest
	return self
end

function string.length(self)
	if self == nil then return 0 end
	return string.len(self)
end

function string.indexOf(self, value)
	if self == nil then return 0 end
	if value == nil then return nil end
	return string.find(self, value, 1, true)
end

function string.getAtIndex(self, index)
	if self == nil then return nil end
	if index == nil then return nil end
	return string.substring(self, index, index)
end

function string.stringForEach(self, func)
	if self == nil then return 0 end
	LibAkaUtils.forLoopToEnd(string.length(self), function(index)
		func(string.getAtIndex(self, index))
	end)
end

function string.contains(self, value)
	return self:find(value, 1, true) ~= nil
end

function string.containsIgnoreCase(self, value)
	return string.toLowercase(self):find(string.toLowercase(value), 1, true) ~= nil
end

function string.getLast(self, value)
	if self == nil then return "" end
	if value == nil then return "" end
	local out = ""
	string.replace(self, value, function (rp)
		out = rp
		return ""
	end)
	return out
end

function string.isLastIndex(self, value)
	local _,tmp = self:find(value, 1, true)
	if tmp == nil then
		return false 
	end
	return tmp == string.length(self)
end

function string.toLowercase(self)
	if self == nil then return "" end
	return self:lower()
end

function string.toUppercase(self)
	if self == nil then return "" end
	return self:upper()
end

function string.isEmpty(self)
	if self == nil then return true end
	return self == ""
end

function string.splitParts(self, regex)
    local out = {}
	string.replace(self, regex, function(st)
		table.insert(out, st)
		return ""
	end)
	return out
end

function string.split(self, regex)
	if self == nil then return {} end
	if regex == nil then
        regex = "%s"
    end
    local out = {}
    for str in string.gmatch(self, "([^"..regex.."]+)") do
		if str ~= nil and str ~= "" then
			table.insert(out, str)
		end
    end
	return out
end