local poukav = LibMarcusModules['Poukav']
local consts = poukav.constants

local function pack(...)
	local t = {...}
	return t
end

local qualityColors = {
	[ITEM_FUNCTIONAL_QUALITY_TRASH] = pack(GetItemQualityColor(ITEM_FUNCTIONAL_QUALITY_TRASH):UnpackRGBA()),
    [ITEM_FUNCTIONAL_QUALITY_NORMAL] = pack(GetItemQualityColor(ITEM_FUNCTIONAL_QUALITY_NORMAL):UnpackRGBA()),
    [ITEM_FUNCTIONAL_QUALITY_MAGIC] = pack(GetItemQualityColor(ITEM_FUNCTIONAL_QUALITY_MAGIC):UnpackRGBA()),
    [ITEM_FUNCTIONAL_QUALITY_ARCANE] = pack(GetItemQualityColor(ITEM_FUNCTIONAL_QUALITY_ARCANE):UnpackRGBA()),
    [ITEM_FUNCTIONAL_QUALITY_ARTIFACT] = pack(GetItemQualityColor(ITEM_FUNCTIONAL_QUALITY_ARTIFACT):UnpackRGBA()),
    [ITEM_FUNCTIONAL_QUALITY_LEGENDARY] = pack(GetItemQualityColor(ITEM_FUNCTIONAL_QUALITY_LEGENDARY):UnpackRGBA())
}

local function sformat(format, ...)
	local strformat = string.format
	local args = {...}
	local match_no = 1
	for pos, type in string.gmatch(format, "()%%.-(%a)") do
		if type == 't' then
			args[match_no] = tostring(args[match_no])
		end
		match_no = match_no + 1
	end
	return strformat(
		string.gsub(format, '%%t', '%%s'),
		unpack(args,1,select('#',...))
	)
end



local function output(str, ...)
	local args = {...}
	local localState = poukav.state
	local color = '|c' .. poukav.utils.toColorString(localState.data.textColor)
	for _, v in ipairs(args) do
		if type(v) == 'string' and (v == '\n' or v:sub(-2) == '|r') then
			args[_] = v .. color
		end
	end
	str = string.gsub(str, '\n', '\n' .. color)
	d(color .. sformat(str, unpack(args)) .. '|r')
end

local function compareNames(n1, n2)
	if n1 == nil then
		return n2 == nil
	end
	if n1 == '*' then
		return true
	end
	if string.sub(n1, 1, 1) == '@' then
		return n1 == n2
	end
	local norm1 = string.lower(string.gsub(n1, '[^%w]', ''))
	local norm2 = string.lower(string.gsub(n2, '[^%w]', ''))
	return string.find(norm2, norm1, 1, true)
end

math.randomseed(os.time(), 667*13)
local cypher = {}
for i = 1, 20 do
	cypher[i] = math.random(0,20)
end
local chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ$*_-'
local function applyAnonymize(str, doIt)
	if not doIt or not str then return str end
	if type(str) ~= 'string' then
		str = tostring(str)
	end
	local cyl = #cypher
	local chl = #chars
	local output = ''
	for i = 1, #str do
		local oldChar = string.sub(str, i, i)
		local isNumber = not not string.find(oldChar, '[0-9]')
		local cypherIdex = (i % cyl) + 1
		local n = cypher[cypherIdex]
		if isNumber then
			local oldNumber = tonumber(oldChar)
			local newNumber = ((oldNumber + n) % 10)
			output = output .. tostring(newNumber)
		elseif oldChar == '@' or oldChar == ' ' or oldChar == "'" or oldChar == "(" or oldChar == ")" then
			output = output .. oldChar
		else
			local oldIndex = string.find(chars, oldChar, 1, true) or 1
			local newIndex = ((oldIndex + n) % chl) + 1
			output = output .. string.sub(chars, newIndex, newIndex)
		end
		
	end
	return output
end

local function split(str, pattern)
	pattern = pattern or '%s'
	local output = {}
	for item in string.gmatch(str, "[^" .. pattern .. "]+") do
		table.insert(output, item)
	end
	return output
end

local function toColorTable(color)
	-- d(sformat('toColorTable(%s)', tostring(color)))
	if not color or color == '' then
		return { 0, 0, 0, 1}
	end
	if (type(color) == 'table' and #color >= 4) then
		return color
	end
		
	local r = 0
	local g = 0
	local b = 0
	if string.len(color) == 3 then
		-- d('len 3')
		r = (tonumber(string.sub(color, 1, 1), 16) * 16) / 255
		g = (tonumber(string.sub(color, 2, 2), 16) * 16) / 255
		b = (tonumber(string.sub(color, 3, 3), 16) * 16) / 255
	elseif string.len(color) == 6 then
		-- d('len 6')
		r = tonumber(string.sub(color, 1, 2), 16) / 255
		g = tonumber(string.sub(color, 3, 4), 16) / 255
		b = tonumber(string.sub(color, 5, 6), 16) / 255
	end
	-- d(sformat('returning %s, %s, %s, %s', r, g, b, 1))
	return { r, g, b, 1}
end

local function getProgressColor(current, goal, startColor, endColor, neutralColor)
	current = math.max(current or 0, 0);
	goal = math.max(goal or 0, 0);
	startColor = startColor or toColorTable('c32148')
	endColor = endColor or toColorTable('66FF00')
	neutralColor = neutralColor or toColorTable('a4a4a2')
	if goal == 0 then
		-- light grey
		return neutralColor
	else
		local ratio = math.min(goal, current) / goal
		local r = math.max(math.min(startColor[1] + ((endColor[1] - startColor[1]) * ratio), 1), 0)
		local g = math.max(math.min(startColor[2] + ((endColor[2] - startColor[2]) * ratio), 1), 0)
		local b = math.max(math.min(startColor[3] + ((endColor[3] - startColor[3]) * ratio), 1), 0)

		return {r, g, b, 1}
	end
end

local function formatThousands(v, sep)
    if (math.abs(v) >= 10000000) then
		return formatThousands(math.floor(v / 10000) / 100, sep) .. 'M'
	end
	if (math.abs(v) >= 10000) then
		return formatThousands(math.floor(v / 100) / 10, sep) .. 'K'
	end

	return ZO_LocalizeDecimalNumber(math.floor(v*100)/100)
end

--- given colorStruct, returns the corresponding hexadecimal color code
local function toColorString(colorStruct)
	if (type(colorStruct) == 'table' and #colorStruct >= 3) then
		return sformat('%02x%02x%02x', math.floor(colorStruct[1] * 255), math.floor(colorStruct[2] * 255), math.floor(colorStruct[3] * 255))
	end
	return colorStruct
end

--- return a string containing given text formatted with the given color (string or struct) if any
local function cFormat(text, color)
	if (type(color) == 'table' and #color >= 3) then
		return cFormat(text, toColorString(color))
	end 
	if not color or color == '' then
		return text
	end
	return sformat("|c%s%s|r", color, text)
end


local function secondsToTime(seconds)
	local timeObj = {}
	if seconds <= 0 then
		timeObj.d = 0
		timeObj.h = 0
		timeObj.m = 0
		timeObj.s = 0
		timeObj.milli = 0
	else
		-- extract milliseconds
		local days = math.floor(seconds / consts.ONE_DAY_IN_SEC)
		local secs = math.floor(seconds)
		local milli = math.floor((seconds - secs) * 1000)
	
		-- extract hours
		local hours = math.floor(secs / 3600) % 24
		
		--extract minutes
		local minutes = math.floor((secs / 60) % 60)
	 
		-- extract seconds
		local seconds = math.floor(secs % 60)
	 
		--create the final array
		timeObj.d = days
		timeObj.h = hours
		timeObj.m = minutes
		timeObj.s = seconds
		timeObj.milli = milli
	end
	
	return timeObj
end

local function formatTimeObj(timeObj)
	if (timeObj.d == 0) then
		if (timeObj.h == 0) then
			return sformat('%dm', timeObj.m or 0)
		end
		return sformat('%dh %dm', timeObj.h or 0, timeObj.m or 0)
	end
	return sformat('%dd %dh %dm', timeObj.d or 0, timeObj.h or 0, timeObj.m or 0)
end

local function startOfDay(timestamp, startHour)
	startHour = startHour or 0
	local currentTime = os.time()
	local date = timestamp
	local dateTable = os.date("*t", timestamp)
	local shouldRemoveADay = dateTable.hour < startHour
	dateTable.hour = startHour
	dateTable.min = 0
	dateTable.sec = 0
	date = os.time(dateTable)
	if (shouldRemoveADay) then
		date = date - consts.ONE_DAY_IN_SEC
	end
	return date
end

local function startOfWeek(timestamp, startDay, startHour)
	timestamp = startOfDay(timestamp, startHour)
	startDay = startDay or 1
	local date = timestamp
	local dateTable = os.date("*t", timestamp)
	local shouldRemoveAWeek = dateTable.wday < startDay

	date = os.time(dateTable)
	if (shouldRemoveAWeek) then
		date = date - (consts.ONE_DAY_IN_SEC * (7 - startDay + dateTable.wday))
    else
        date = date - (consts.ONE_DAY_IN_SEC * (0 - startDay + dateTable.wday))
	end
	return date
end

local function startOfMonth(timestamp)
	local currentTime = os.time()
	
	local date = timestamp
	local dateTable = os.date("*t", timestamp)
	dateTable.hour = 0
	dateTable.min = 0
	dateTable.sec = 0
	dateTable.day = 1
	date = os.time(dateTable)

	return date
end

local function sign(v)
	if v < 0 then
		return '-'
	end
	return '+'
end

local function formatIcon(icon, width, height)
	if not icon then return '' end
	width = width or 16
	height = height or width
	return sformat('|t%d:%d:%s|t', width, height, icon)
end

local function formatGold(v, signed)
	if signed then
		return sign(v) .. formatThousands(math.abs(v)) .. formatIcon(consts.GOLD_ICON)
	end
	return formatThousands(v) .. formatIcon(consts.GOLD_ICON)
end

local function daysInMonth(month, year)
	local days_in_month = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }   
	local d = days_in_month[month]
	 
	-- check for leap year
	if (month == 2) then
		if (math.mod(year, 4) == 0) then
			if (math.mod(year, 100) == 0)then                
				if (math.mod(year, 400) == 0) then                    
					d = 29
				end
			else                
				d = 29
			end
		end
	end
	return d  
end

local function indexOf(t, predicate)
	for index, u in ipairs(t) do
		if predicate(u) then
			return index
		end
	end
	return nil
end

--- func desc
---@param periodStr string
local function getInterval(periodStr)
	if not periodStr or type(periodStr) ~= 'string' or periodStr == '' then
		return nil, nil
	end
	periodStr = periodStr:upper()
	local localState = poukav.state
    local startHour = localState.data.accountingDayStartHour
    local startDay = localState.data.accountingWeekStartDay
	--[[
		M[-n]: current month, M-1 is last month
		W[-n]: current week, W-1 is last week
		D[-n]: current day, D-1 is yesterday
		[D-5=>D-3): from start of D-5 to start of D-3
		(D-5=>D-3]: from end of D-5 to end of D-3
	]]
	local _, _,
	startModifier, startParam, startDelta,
	endParam, endDelta, endModifier = string.find(periodStr, "([%(%[]?)([YMWD])-?(%d*)%s*=?>?%s*([YMWD]?)-?(%d*)([%)%]]?)")

	local now = os.time()
	local startTime
	if (startParam == 'D') then
		local t = startOfDay(now, startHour)

		if startModifier == '(' then
			-- start exclusive is end of day
			t = t + consts.ONE_DAY_IN_SEC
		end
		if startDelta ~= '' then
			t = t - tonumber(startDelta) * consts.ONE_DAY_IN_SEC
		end
		startTime = t
	elseif (startParam == 'W') then
		
		local t = startOfWeek(now, startDay, startHour)

		if startModifier == '(' then
			-- start exclusive is end of week
			t = t + consts.ONE_DAY_IN_SEC * 7
		end
		if startDelta ~= '' then
			t = t - tonumber(startDelta) * consts.ONE_DAY_IN_SEC * 7
		end
		startTime = t
	elseif (startParam == 'M') then
		
		local t = startOfMonth(now)

		if startModifier == '(' then
			-- start exclusive is end of month
			local dt = os.date('*t', t)
			t = t + consts.ONE_DAY_IN_SEC * daysInMonth(dt.month, dt.year)
		end
		if startDelta ~= '' then
			local d = tonumber(startDelta)
			for i = 1, d do
				t = t - consts.ONE_DAY_IN_SEC
				t = startOfMonth(t)
			end
		end
		startTime = t
	end
	local endTime
	if endParam == '' then
		if (startParam == 'D') then
			endTime = startTime + consts.ONE_DAY_IN_SEC
		elseif (startParam == 'W') then
			endTime = startTime + consts.ONE_DAY_IN_SEC * 7
        elseif (startParam == 'M') then
            local tt = os.date('*t', startTime)
			local numDays = daysInMonth(tt.month, tt.year)
			endTime = startTime + consts.ONE_DAY_IN_SEC * numDays
		end
	elseif endParam == 'D' then
		local t = startOfDay(now, startHour)

		if endModifier ~= ')' then
			-- end not exclusive is end of day
			t = t + consts.ONE_DAY_IN_SEC
		end
		if endDelta ~= '' then
			t = t - tonumber(endDelta) * consts.ONE_DAY_IN_SEC
		end
		endTime = t
	elseif endParam == 'W' then
		endTime = startOfWeek(now, startDay, startHour)

		if endModifier ~= ')' then
			-- end not exclusive is end of week
			endTime = endTime + consts.ONE_DAY_IN_SEC * 7
		end
		if endDelta ~= '' then
			endTime = endTime - tonumber(endDelta) * consts.ONE_DAY_IN_SEC * 7
		end
	elseif endParam == 'M' then
		local t = startOfMonth(now)

		if endModifier ~= ')' then
			--  end not exclusive is end of month
			local dt = os.date('*t', t)
			t = t + consts.ONE_DAY_IN_SEC * daysInMonth(dt.month, dt.year)
		end
		if endDelta ~= '' then
			local d = tonumber(endDelta)
			for i = 1, d do
				t = t - consts.ONE_DAY_IN_SEC
				t = startOfMonth(t)
			end
		end
		endTime = t
	end

	-- fixes daylight savings issues
	local st = os.date('*t', startTime)
	local et = os.date('*t', endTime)
	st.hour = startHour
	et.hour = startHour
	startTime = os.time(st)
	endTime = os.time(et)
	return startTime, endTime
end

local priceCache = {}
local function getAveragePrice(link) 
 
    local price = priceCache[link]
    if price == nil or (not price) or price == 0 then
        if TamrielTradeCentre then
            local ttcPriceInfo = TamrielTradeCentrePrice:GetPriceInfo(link)
            if (ttcPriceInfo and ttcPriceInfo.SuggestedPrice ~= 0) then
                price = ttcPriceInfo.SuggestedPrice
            else
                price = MasterMerchant:itemStats(link, false).avgPrice
            end
        else
            price = MasterMerchant:itemStats(link, false).avgPrice
        end
        priceCache[link] = price
    end
    
    return price or 0
end

local function clearTable(t)
    local l = #t
    while l > 0 do
        table.remove(t, l)
        l = l - 1
    end
end

local function chainOp(t, op, batchSize, delay, callback, index, context)
    context = context or {}
    index = index or 1
    local l = (type(t) == 'number' and t) or #t
    if (index > l) then
        if callback then
            callback(context)
        end
        return
    end
    local endIndex = math.min(l, index + batchSize - 1)
    op(t, index, endIndex, context, batchSize)
    if ((index + batchSize) > l) then
        chainOp(t, op, batchSize, delay, callback, index + batchSize, context)
        return
    end
    zo_callLater(function()
        chainOp(t, op, batchSize, delay, callback, index + batchSize, context)
    end, delay)
end

local function trim(s)
	if (not s) or (type(s) ~= 'string') then
		return s
	end
	return (s:match('^()%s*$') and '') or s:match('^%s*(.*%S)')
end

local function capitalize(str)
	if not str or type(str) ~= 'string' or #str == 0 then
		return str
	end
	if #str == 0 then
		return str:upper()
	end
	return string.sub(str, 1, 1):upper() .. string.sub(str, 2)
end

local function move(source, startIndex, endIndex, destIndex, destination)
	local s = destination and source or move(source, 1, #source, 1, {})
	local d = destination or source
	startIndex = startIndex or 1
	endIndex = endIndex or #source
	destIndex = destIndex or #d + 1

	for i = startIndex, endIndex do
		d[destIndex] = s[i]
		destIndex = destIndex + 1
	end
end

local function getLinkFields(link)
	-- |H0:item:44262:360:50:0:0:0:0:0:0:0:0:0:0:0:0:20:0:0:0:0:0|h|h
	local pattern = '|H[01]:item:(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d)|h|h'
	local allFields = pack(string.find(link, pattern))
	local id = allFields[3]
	local quality = allFields[4]
	local level = allFields[5]
	local otherFields = move(allFields, 6, #allFields, 1, {})
	return id, quality, level, otherFields
end

local function compareLinks(link1, link2)
	local id1, q1, l1 = getLinkFields(link1)
	local id2, q2, l2 = getLinkFields(link2)
	return id1 == id2 and q1 == q2 and l1 == l2
end

local bufferedOutput = {}
local function flushBufferedOutput()
	for _, values in ipairs(bufferedOutput) do
		output(unpack(values))
	end
	clearTable(bufferedOutput)
end

local function outputLater(...)
	if poukav.state.initialized then
		output(...)
	else
		table.insert(bufferedOutput, pack(...))
	end
end

poukav.utils = {
    cFormat = cFormat,
    toColorString = toColorString,
    formatThousands = formatThousands,
    getProgressColor = getProgressColor,
    secondsToTime = secondsToTime,
    formatIcon = formatIcon,
    sign = sign,
    startOfMonth = startOfMonth,
    startOfWeek = startOfWeek,
    startOfDay = startOfDay,
    formatTimeObj = formatTimeObj,
    getInterval = getInterval,
    indexOf = indexOf,
    daysInMonth = daysInMonth,
    getAveragePrice = getAveragePrice,
    clearTable = clearTable,
    split = split,
    pack = pack,
    chainOp = chainOp,
	trim = trim,
	applyAnonymize = applyAnonymize,
	output = output,
	outputLater = outputLater,
	flushBufferedOutput = flushBufferedOutput,
	compareNames = compareNames,
	capitalize = capitalize,
	compareLinks = compareLinks,
	getLinkFields = getLinkFields,
	move = move,
	sformat = sformat,
	formatGold = formatGold
}