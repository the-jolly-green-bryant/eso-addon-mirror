
local Utils = FasterTravel.Utils or {}

local function stringIsEmpty(str)
	return str == nil or str == ""
end

local function stringStartsWith(str,value)
	return string.sub(str,1,string.len(value)) == value
end

local function stringTrim(str)
	if str == nil or str == "" then return str end 
	return (str:gsub("^%s*(.-)%s*$", "%1"))
end 

local function copy(source,target)
	target = target or {}
	if source ~= nil then
		for i,v in ipairs(source) do
			table.insert(target,v)
		end
	end
	return target
end

local function shuffle(source,target)
	target = target or {}
	if source ~= nil then
		while #source > 0 do
			item = table.remove(source, math.random(#source))
			if item ~= nil then
				table.insert(target,item)
			end
		end
	end
	return target
end

local function extend(source,target)
	target = target or {}
	if source ~= nil then
		for k,v in pairs(source) do 
			target[k] = v
		end 
	end
	return target
end

local function toTable(value)
	local t = type(value)
	
	if t == "table" then
		return copy(value)
	elseif t == "function" then
		local tbl = {}
		for i in value do
			table.insert(tbl,i)
		end
		
		return tbl
	end
end

local function where(iter,predicate)
	local t = type(iter)
	
	if t == "table" then
		local tbl = {}
		for i,v in ipairs(iter) do
			if predicate(v) == true then
				table.insert(tbl,v)
			end
		end
		return tbl
	elseif t == "function" then
		local cur
		return function()
			repeat
				cur = iter()
			until cur == nil or predicate(cur) == true
			return cur
		end
	end
end

local function map(iter,func)
	if iter ~= nil then
		local t = type(iter)
		if t == "table" then
			local tbl = {}
			for i,v in ipairs(iter) do
				tbl[i]=func(v)
			end
			return tbl
		elseif t == "function" then
			local cur
			return function()
				cur = iter()
				if cur == nil then return nil end
				return func(cur)
			end
		end
	end
	return ""
end

local function concatToString(...)
	local args = {...}
	return table.concat(map(args,function(a)
		return tostring(a)
	end))
end

local function reverseTable(tbl)
	local newtbl = {}
	for i,v in ipairs(tbl) do
		table.insert(newtbl,1,v)
	end 
	return newtbl
end 

local _lang

local function FormatStringLanguage(lang,str)
	if stringIsEmpty(str) then return str end
	lang = string.lower(lang)
	if lang == "en" then 
		return str
	else
		return zo_strformat("<<!AC:1>>", str)
	end 
end 

local function CurrentLanguage()
	if _lang == nil then 
		_lang = GetCVar("language.2")
		_lang = string.lower(_lang)
	end 
	return _lang
end

local function FormatStringCurrentLanguage(str)
	return FormatStringLanguage(CurrentLanguage(),str)
end

local function pairsByKeys(a_table, comparing_function)
	local aux_index = {}
	for n in pairs(a_table) do table.insert(aux_index, n) end
	table.sort(aux_index, comparing_function)
	local i = 0      -- iterator variable
	local iter = function ()   -- iterator function
		i = i + 1
		if aux_index[i] == nil then return nil
		else return aux_index[i], a_table[aux_index[i]]
		end
	end
	return iter
end

local function ShortName(name)
	local r = name
	if _lang == "fr" then
		r = r:gsub("^Oratoire ", "O. ", 1)
	elseif _lang == "de" then
		r = r:gsub("Wegschrein ", "WS ", 1)
	elseif _lang == "ru" then
		r = r:gsub("^Дорожное святилище ", "ДС ", 1)
	end
	return r
end

local function BareName(name) 
	local r = ShortName(name)
	if _lang == "en" then
		r = r:gsub("^Dungeon: ", "", 1):gsub("^Trial: ", "", 1):gsub("^The ", "", 1)
	elseif _lang == "fr" then
		r = r:gsub("^O. ", "", 1):gsub("^Donjon.-:.", "", 1):gsub("^Épreuve.-:.", "", 1)
		r = r:gsub("^d'", "", 1):gsub("^des ", "", 1):gsub("^de ", "", 1):gsub("^du ", "", 1)
		r = r:gsub("^la ", "", 1):gsub("^l' ", "", 1)
	elseif _lang == "de" then
		r = r:gsub("WS ", "", 1):gsub("^am ", "", 1):gsub("^bei ", "", 1)
		r = r:gsub("^von ", "", 1):gsub("^der ", "", 1):gsub("^des ", "", 1)
	elseif _lang == "ru" then
		r = r:gsub("ДС ", "", 1):gsub("^Подземелье: ", "", 1):gsub("^Испытание: ", "", 1)
	end
	return r
end

local function SortByBareName(x,y)
	return (x.barename or x.name) < (y.barename or y.name)
end


local function bold(arg)
	return string.format("|c%s%s|r", "ffaa00", arg or "(nil)")
end

local function Highlight(wayshrine_name)
	local prefix = ""
	if string.find(wayshrine_name, '|c') then
		prefix = string.sub(wayshrine_name, 1, 12)
		wayshrine_name = string.sub(wayshrine_name, 13, -1)
	end
	return string.format("%s|cf0f000%s|r", prefix, wayshrine_name)
end

local function chat(level, fmt, ...)
	local verbosity
	if FasterTravel and FasterTravel.settings then
		verbosity = FasterTravel.settings.verbosity
		if verbosity == nil then
			-- d(FasterTravel.prefix .. "Verbosity not set!")
			verbosity = 1
		end
		if level <= verbosity then
			local args = {...}
			-- find max key - some keys may be missing, 
			-- if corresponding arguments are nil!
			local last_k = 0
			for k, _ in pairs(args) do
				if k > last_k then
					last_k = k
				end
			end
			if last_k > 0 then
				local t = {}
				for k = 1, last_k do
					table.insert(t, tostring(args[k])) -- tostring handles nil just fine
				end
				df(FasterTravel.prefix .. fmt, unpack(t))
			else
				d(FasterTravel.prefix .. fmt)
			end
		end
	else
		d(FasterTravel.prefix .. "FasterTravel.settings missing!")
	end
end

local timeMeasurements = {}

local function MeasureTime(idString, start)
	if start then
		timeMeasurements[idString] = GetGameTimeMilliseconds()
	else
		local t = timeMeasurements[idString]
		if t ~= nil then
			t = GetGameTimeMilliseconds() - t
			timeMeasurements[idString] = t
			return t 
		end
	end
	return nil
end

local function MeasuredTimes()
	local s = {}
	for k, v in pairs(timeMeasurements) do
		table.insert(s, string.format("%s %d ms", k, v))
	end
	return table.concat(s, " ")
end

local function UniqueDialogName(dialogName)
	return string.format("%s_%s", FasterTravel.addon.name, dialogName) 
end


Utils.copy = copy
Utils.shuffle = shuffle
Utils.stringIsEmpty = stringIsEmpty
Utils.stringStartsWith = stringStartsWith
Utils.stringTrim = stringTrim
Utils.toTable = toTable
Utils.map = map
Utils.where = where 
Utils.extend = extend
Utils.CurrentLanguage = CurrentLanguage
Utils.FormatStringLanguage = FormatStringLanguage
Utils.FormatStringCurrentLanguage = FormatStringCurrentLanguage
Utils.concatToString = concatToString
Utils.reverseTable = reverseTable
Utils.pairsByKeys = pairsByKeys
Utils.BareName = BareName
Utils.ShortName = ShortName
Utils.SortByBareName = SortByBareName
Utils.bold = bold
Utils.chat = chat
Utils.MeasureTime = MeasureTime
Utils.MeasuredTimes = MeasuredTimes
Utils.UniqueDialogName = UniqueDialogName
FasterTravel.Utils = Utils