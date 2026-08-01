-- TODO: research about this and make better version
local function class(base)
	local cls = {}

	if type(base) == 'table' then
		for k, v in pairs(base) do
			cls[k] = v
		end

        -- setmetatable(cls, {__index = base})

		cls.base = base  -- TODO: make use of it or remove
	end

	cls.__index = cls

	function cls.isInstance(obj)
        if type(obj) ~= 'table' then return false end

        local mt = getmetatable(obj)

        while mt do
            if mt == cls then return true end
            -- if mt.base then
            --     mt = mt.base
            -- else
            --     mt = nil
            -- end
        end

        return false
    end

	setmetatable(cls, {
        __call = function(self_, ...)
            local obj = setmetatable({}, cls)

            if self_.__init then
                self_.__init(obj, ...)
            elseif base ~= nil and base.__init ~= nil then
                base.__init(obj, ...)
            end

            return obj
        end
	})

	return cls
end

-- ----------------------------------------------------------------------------

LibImplex = LibImplex or {}
LibImplex.class = class