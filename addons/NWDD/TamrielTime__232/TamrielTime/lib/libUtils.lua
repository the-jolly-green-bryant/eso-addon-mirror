-- Copyright (c) 2014 [NWDD]Gindar

if lu then return end

lu = {}

function lu.c (chainable)
	return setmetatable({}, {
		__index = function (_,call)
			return function (__,...)
				chainable[call](chainable, ...)
				return _
			end
		end,
		__call = function ()
			return chainable
		end})
end

function lu.fmt(fmt, data)
	local prev = nil
	for k,v in pairs(data) do
		fmt = fmt:gsub("$h12",data.h12):gsub("$"..k, (type(v)=="function" and v(data,prev) or v))
		prev = v
	end
	return fmt
end

function lu.HookInherit( element, parents, p, properties, defaults, refresh )
	refresh = refresh or 25
	local s = false
	local h = setmetatable({}, { __call = function (_, np)
		if s then s = false return end
		s = np and parents[p]
		p = np or p
		local parent = parents[p]
		if parent then
			for k,v in pairs(properties) do
				element[k](element, parent[v](parent))
			end
			zo_callLater(_,refresh)
		else
			for k,v in pairs(defaults) do
				element[k](element, v)
			end
		end
	end})
	h()
	return h
end