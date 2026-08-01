
local function class(base)

	local c = {}
	
	if type(base) == "table" then 
		for k,v in pairs(base) do 
			c[k]=v
		end 
		c._base = base
		c.base = base
	end 
	
	c.__index = c
	
	setmetatable(c,{ __call=function(self,...)
		local obj = setmetatable({},c)
		if self.init then 
			self.init(obj,...)
		elseif base ~= nil and base.init ~= nil then 
			base.init(obj,...)
		end
		return obj
	end
	})
	return c
end 

FasterTravel.class = class