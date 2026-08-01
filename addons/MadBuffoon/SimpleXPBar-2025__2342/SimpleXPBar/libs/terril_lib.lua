--just some helper functions pooled together for all my addons
local version = 8

--load only the latest
if Terril_lib and Terril_lib.version > version then return end

Terril_lib = {
	name = "Terril_lib",
	version = version,
	author = "Terrillyn",
}

function Terril_lib.DeepCopy(src, def, dst)
	assert(type(src) == 'table', 'invalid param "src"')

	dst = dst or {}
	def = def or src
	for k,v in pairs(def) do
		if type(v) == "table" then
			dst[k] = {}
			Terril_lib.DeepCopy(src[k], def[k], dst[k])
		else
			dst[k] = rawget(src, k)
		end
	end
	return dst
end

function Terril_lib.IsAddonOutOfDate(self, warn)
	return false
end

function Terril_lib.GENERIC_EVENT_DUMP(eventName, ...)
	assert(eventName ~= nil and eventName ~= '' and type(eventName) == 'string', 'invalid param "eventName"')
	local val_ToString = function(val)
		if type(val) == "string" then return val
		elseif type(val) == "number" then return tostring(val)
		elseif type(val) == "boolean" then return tostring(val)
		else return type(val) end
	end
	local args_str = ""

	for i,v in ipairs{...} do
		if args_str ~= "" then args_str = args_str .. ", " end
		args_str = args_str .. val_ToString(v)
	end

	d(string.format("%s( %s )", eventName, args_str))
end
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
function Terril_lib.startsWith(string, start)
	assert(string ~= nil and string ~= '' and type(string) == 'string', 'invalid param "string"')
	assert(start ~= nil and start ~= '' and type(start) == 'string', 'invalid param "start"')

	return string.sub(string, 1, string.len(start)) == start
end

function Terril_lib.firstLetters(str)
	assert(str ~= nil and str ~= '' and type(str) == 'string', 'invalid param "str"')

	local result = string.sub(str, 1, 1)

	for l in string.gmatch(str, "%s(%a)%a*") do
		result = result .. l
	end

	return result
end

function Terril_lib.keys(t)
	assert(type(t) == 'table', 'invalid param "t"')

	local keys = {}
	for k,v in pairs(t) do
		keys[#keys+1] = k
	end
	return keys
end

function Terril_lib.values(t)
	assert(type(t) == 'table', 'invalid param "t"')

	local values = {}
	for k,v in pairs(t) do
		values[#values+1] = v
	end
	return values
end

function Terril_lib.join(t, delimiter)
	assert(type(t) == 'table', 'invalid param "t"')

	delimiter = delimiter or ' '
	local result = ""
	for i,v in ipairs(t) do
		if result ~= "" then result = result .. delimiter end
		result = result .. v
	end
	return result
end

function Terril_lib.concatTable(t1, t2)
	assert(type(t1) == 'table', 'invalid param "t1"')
	assert(type(t2) == 'table', 'invalid param "t2"')

	for i = 1, #t2 do
		t1[#t1+1] = t2[i]
	end
	return t1
end

function Terril_lib.range(min, max, step)
	assert(type(min) == 'number', 'invalid param "min"')
	assert(type(max) == 'number', 'invalid param "max"')
	assert(min < max, 'invalid param "min" or "max"')

	step = step or 1
	local range = {}
	for i = min, max, step do
		table.insert(range, i)
	end
	table.sort(range)
	return range
end