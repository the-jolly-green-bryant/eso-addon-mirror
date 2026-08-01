local function class()
	local cls = {}
	cls.__index = cls

	setmetatable(cls, {
        __call = function(self, ...)
            local obj = setmetatable({}, cls)
            if self.__init then self.__init(obj, ...) end
            return obj
        end
	})

	return cls
end

IMP_LibSurfaceTools__class = class
