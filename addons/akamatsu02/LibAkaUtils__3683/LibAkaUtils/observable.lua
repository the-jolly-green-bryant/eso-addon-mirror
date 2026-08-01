Observable = Observable or {}

local function uuid()
	return string.gsub("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx", "[xy]", function (cur)
		local tmp = (cur == 'x') and math.random(0, 0xf) or math.random(8, 0xf)
		return string.format('%x', tmp)
	end)
end

local function __index(self, k)
	return rawget(self, "_storedValue")
end

local function __newindex(self, _, v)
	local cls = getmetatable(self)
	local set = rawget(cls, "set__storedValue")
	if set then
		set(self, "_storedValue", v)
	else
		rawset(self, "_storedValue", v)
	end
    for id, func in pairs(self.observers) do
		if func ~= nil and type(func) == "function" then
			func(id, v)
		end
	end
end

function Observable.new(self, initialValue)
    local new = {
	    id = uuid(),
        _storedValue = initialValue,
		observers = {},
		register = function(self, func)
			local id = uuid()
			self.observers[id] = func
			return id
		end,
		unregister = function(self, id)
			self.observers[id] = nil
			return self
		end
	}
    setmetatable(new, self)
    self.__index = __index
    self.__newindex = __newindex
    return new
end

--local observable = Observable:new(false)
--observable:register(function(id, value) d(id);d(value);end)
--observable.value = true