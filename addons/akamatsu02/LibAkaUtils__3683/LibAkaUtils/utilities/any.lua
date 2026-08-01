LibAkaUtils = LibAkaUtils or {}

function LibAkaUtils.getOrInit(value, default)
	if value == nil then 
		return default
	end
	return value
end

function LibAkaUtils.getIfEqual(value, compare)
	if value == nil then 
		return compare
	end
	if compare == nil then 
		return value
	end
	if value == compare then 
		return value
	end
	return compare
end

function LibAkaUtils.uuid(template)
	return string.replace(LibAkaUtils.getOrInit(template, 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'), "[xy]", function (cur)
		local tmp = (cur == 'x') and math.random(0, 0xf) or math.random(8, 0xf)
		return string.format('%x', tmp)
	end)
end

function LibAkaUtils.getLanguage()
	return GetCVar("language.2")
end

function LibAkaUtils.invertBool(value)
	return value == false
end

function LibAkaUtils.executeStringCode(value)
	if value == nil then return end
	local f = assert(zo_loadstring(value))
	f()
end

LibAkaUtils.Exception = {}

function LibAkaUtils.Exception.new(self, successful, result, error)
	local new = {
		successful = successful,
		result = result,
		error = error
	}
    setmetatable(new, self)
    self.__index = self
    return new
end

function LibAkaUtils.Exception.thenRun(self, func)
	if self.successful == false then return self end
	if func == nil then return self end
	if type(func) ~= "function" then return self end
    func(self.result)
	return self
end

function LibAkaUtils.Exception.catch(self, func)
	if self.successful == true then return self end
	if func == nil then return self end
	if type(func) ~= "function" then return self end
    func(self.error)
	return self
end

function LibAkaUtils.Exception.finally(self, func)
	if func == nil then return self end
	if type(func) ~= "function" then return self end
    func(self.result)
	return self
end

function LibAkaUtils.try(func, varTable, unpackIn, unpackOut)
	local results = nil
	local successful, error = pcall(function()
		if unpackIn == true  then
			results = table.pack(func(table.unpack(varTable)))
		else
			results = table.pack(func(varTable))
		end
		if #results == 0 then 
			results = nil
		end
		if #results == 1 then 
			results = results[1] 
		end
	end)
	if successful == true then
		if unpackOut == false or results == nil then
			return LibAkaUtils.Exception:new(true, results)
		else
			return LibAkaUtils.Exception:new(true, table.unpack(results))
		end
	else
		return LibAkaUtils.Exception:new(false, nil, error)
	end
end