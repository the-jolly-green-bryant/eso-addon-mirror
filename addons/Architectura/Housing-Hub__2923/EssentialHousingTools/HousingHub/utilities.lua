if IsNewerEssentialHousingHubVersionAvailable() or not IsEssentialHousingHubRootPathValid() then
	return
end

local EHH = EssentialHousingHub
if not EHH then
	return
end

---[ Deferred Initialization ]---

function EHH:DeferredInitializeUtilities()
end

---[ Units ]---

function EHH:GetCharacterName()
	return GetUnitName("player")
end

function EHH:GetPlayerWorldPosition()
	local _, x, y, z = GetUnitRawWorldPosition("player")
	return x, y, z
end

---[ Chat Output ]---

function EHH:ShowChatMessage(message, ...)
	if 0 < select("count", ...) then
		df(message, ...)
	else
		d(message)
	end
end

---[ Event Bubbling ]---

do
	local function OnUpdateMouseState(control)
		if IsMenuVisible() then
			return
		end

		local mouseX, mouseY = GetUIMousePosition()
		local margin = control._MouseMargin
		local isMouseOver = control:IsPointInside(mouseX, mouseY, -margin, -margin, margin, margin)
		if isMouseOver and not control._IsMouseOver then
			control._IsMouseOver = true
			if control._OriginalOnMouseEnter then
				control._OriginalOnMouseEnter(control)
			end
		elseif not isMouseOver and control._IsMouseOver then
			control._IsMouseOver = false
			if control._OriginalOnMouseExit then
				control._OriginalOnMouseExit(control)
			end
		end
	end

	function EHH:EnableEnhancedMouseOverBehaviorForControlGraph(control, inclusive)
		if control then
			if inclusive and control:IsMouseEnabled() and not control._OriginalOnMouseEnter and not control._OriginalOnMouseExit then
				local enterHandler = control:GetHandler("OnMouseEnter")
				local exitHandler = control:GetHandler("OnMouseExit")
				if enterHandler or exitHandler then
					control._MouseMargin = 0
					control._OriginalOnMouseEnter = enterHandler
					control._OriginalOnMouseExit = exitHandler
					control:SetHandler("OnMouseEnter", nil)
					control:SetHandler("OnMouseExit", nil)
					control:SetHandler("OnUpdate", OnUpdateMouseState)
				end
			end

			local INCLUSIVE = true
			local numChildren = control:GetNumChildren()
			for childIndex = 1, numChildren do
				local child = control:GetChild(childIndex)
				self:EnableEnhancedMouseOverBehaviorForControlGraph(child, INCLUSIVE)
			end
		end
	end

	function EHH:SetEnhancedMouseOverMarginForControl(control, margin)
		if control then
			control._MouseMargin = tonumber(margin)
		end
	end
end

do
	local function BubbleControlEvent(control, eventName, ...)
		while control and control ~= GuiRoot do
			local handler = control:GetHandler(eventName)
			if handler then
				if handler(control, eventName, ...) then
					-- Bubble chain terminated.
					return true
				end
			end

			if control == control:GetOwningWindow() then
				return
			end

			control = control:GetParent()
		end
	end

	function EHH:EnableEventBubblingForControlGraph(control, eventName, inclusive)
		if control then
			if inclusive then
				control:SetHandler(eventName, function(control, ...)
					return BubbleControlEvent(control, eventName, ...)
				end, "BubbleControlEvent")
			end

			local numChildren = control:GetNumChildren()
			for childIndex = 1, numChildren do
				local childControl = control:GetChild(childIndex)
				local INCLUSIVE = true
				self:EnableEventBubblingForControlGraph(childControl, eventName, INCLUSIVE)
			end
		end
	end
end

---[ Control Graph Manipulation ]---

function EHH:ForEachControlInGraph(control, callback)
	if control then
		callback(control)

		local numChildren = control:GetNumChildren()
		for childIndex = 1, numChildren do
			local child = control:GetChild(childIndex)
			self:ForEachControlInGraph(child, callback)
		end
	end
end

---[ Serialization ]---

function EHH:Deserialize(s)
	local t

	if "string" == type(s) and #s > 2 and "{" == string.sub(s, 1, 1) and "}" == string.sub(s, -1, -1) then
		t = zo_loadstring("return " .. s)()
	elseif self.IsDev then
		self:ShowChatMessage("WARNING: Invalid deserialization string.")
	end

	return t or {}
end

function EHH:Serialize(t)
	local tt = type(t)
	local s, tk, tv

	if "string" == tt then
		s = string.format("%q", t)
	elseif "number" == tt then
		local _, f = math.modf(t)

		if 0 == f then
			s = string.format("%d", t)
		else
			local decimals = 0

			repeat
				decimals = decimals + 1
				_, f = math.modf(t * 10 ^ decimals)
			until decimals >= 5 or 0 == f

			s = string.format("%." .. tostring(decimals) .. "f", t)
		end
	elseif "table" == tt then
		local b = {}

		table.insert(b, "{")
		for k, v in pairs(t) do
			tk = self:Serialize(k)
			tv = self:Serialize(v)

			if "" ~= tk and "" ~= tv then
				table.insert(b, string.format("[%s]=%s,", tk, tv))
			end
		end
		table.insert(b, "}")

		s = table.concat(b, "")
	else
		s = ""
	end

	return s
end

function EHH:EstimateSizeOf(t)
	local s = 0
	local tt = type(t)

	if "number" == tt then
		return 8 + 2
	elseif "string" == tt then
		return #t + 2
	elseif "table" == tt then
		for k, v in pairs(t) do
			s = s + self:EstimateSizeOf(k) + self:EstimateSizeOf(v) + 6
		end
		s = s + 2
	end

	return s
end

function EHH:DeserializeSaved(t)
	if "string" == type(t) then
		return self:Deserialize(t)
	elseif "table" == type(t) and t[0] then
		local st = self:CloneTable(t)
		st[0] = nil
		return self:Deserialize(table.concat(st, ""))
	else
		return t
	end
end

function EHH:SerializeSaved(t)
	local s = self:Serialize(t)
	local maxLength = self.Defs.Limits.MaxSavedStringLength

	if #s <= maxLength then
		return s
	end

	local st = {}
	local i = 1

	while i < #s do
		table.insert(st, string.sub(s, i, i - 1 + maxLength))
		i = i + maxLength
	end

	st[0] = #s
	return st
end

---[ Bit Flags ]---

local bit = { }
EHH.Bit = bit

function bit.New( b )
	return 2 ^ ( b - 1 )
end

function bit.Has( x, b )
	return x % ( b + b ) >= b
end

function bit.Set( x, b )
	return bit.Has( x, b ) and x or x + b
end

function bit.Clear( x, b )
	return bit.Has( x, b ) and x - b or x
end

function bit.FirstBit( x )
	for b = 1, 64 do
		if bit.Has( x, bit.New( b ) ) then
			return b
		end
	end
end

---[ Math ]---

function EHH:VariableEaseIn(interval, scale)
	return interval ^ scale
end

function EHH:VariableEaseOut(interval, scale)
	return 1 - (interval ^ scale)
end

function EHH:VariableEase(interval, scale)
    if interval < 0.5 then
        return (2 * interval) ^ scale
    else
		return (2 - 2 * interval) ^ scale
	end
end

function EHH:InverseVariableEase(interval, scale)
    if interval < 0.5 then
        return 1 - ((2 * (0.5 - interval)) ^ scale)
    else
		return 1 - ((2 * (interval - 0.5)) ^ scale)
	end
end

function EHH:Round(number, decimals)
	if decimals >= 0 and decimals < 10 then
		return zo_roundToNearest(number, 1 / (10 ^ (decimals or 0)))
	else
		return zo_roundToNearest(number, decimals)
	end
end

function EHH:ComputeCRC(block)
	local crc, ceiling, offset = 0, 7640, 100

	if "string" == type(block) and "" ~= block then
		for index = 1, #block do
			crc = crc + string.byte(block, index)
		end
	end

	local crcEncoded = self:ToBase88(offset + (crc % ceiling))
	return crcEncoded
end

function EHH:ToBase88(number)
	number = tonumber(number)
	if "number" ~= type(number) then
		return nil, "ToBase88: Parameter 'number' must be type 'number'."
	end

	local s = ""
	local dec, sign = 0, 1

	number = math.floor(number)
	if 0 > number then
		number = number * -1
		sign = -1
	end

	local base88Digits = self.Defs.Base88.Digits
	repeat
		dec = number % 88
		s = base88Digits[dec + 1] .. s
		number = math.floor(number / 88)
	until 0 >= n or 32 < string.len(s)

	if 0 > sign then
		s = "#" .. s
	end

	return s
end

function EHH:FromBase88(base88String)
	if "string" ~= type(base88String) then
		return nil, "FromBase88: Parameter 'base88String' must be type 'string'."
	end

	local d, p, n, v = 0, 0, 0, 0
	local sign = 1

	if string.sub(base88String, 1, 1) == "#" then
		sign = -1
		base88String = string.sub(base88String, 2)
	end

	local base88Values = self.Defs.Base88.Values
	for i = #base88String, 1, -1 do
		v = base88Values[string.sub(base88String, i, i)]

		if nil == v then
			return nil, string.format("FromBase88: Invalid Base88 string: '%s'", tostring(base88String))
		end

		if not v then
			break
		end

		d = math.pow(88, p) * v
		n = n + d
		p = p + 1
	end

	return sign * n
end

---[ Compression ]---

function EHH:CompressColor( r, g, b )
	r, g, b = zo_clamp( r or 0, 0, 1 ), zo_clamp( g or 0, 0, 1 ), zo_clamp( b or 0, 0, 1 )
	r, g, b = math.max( 0, self:Round( -1 + r * 100, 0 ) ), math.max( 0, self:Round( -1 + g * 100, 0 ) ), math.max( 0, self:Round( -1 + b * 100, 0 ) )
	return r + 100 * g + 10000 * b
end

function EHH:DecompressColor( i )
	i = i / 1000000
	local b = 1 + math.floor( i * 100 )
	local g = 1 + math.floor( ( ( i * 100 ) % 1 ) * 100 )
	local r = 1 + self:Round( ( ( i * 10000 ) % 1 ) * 100, 0 )
	r, g, b = math.min( 1, 1 == r and 0 or r / 100 ), math.min( 1, 1 == g and 0 or g / 100 ), math.min( 1, 1 == b and 0 or b / 100 )
	return r, g, b
end

function EHH:CompressInteger( i1, digits1, i2, digits2, i3, digits3 )
	local num1 = tonumber( i1 )
	if num1 then
		local numDigits1 = tonumber( digits1 )
		if numDigits1 then
			i1 = zo_clamp( num1, 1, ( 10 ^ numDigits1 ) - 1 )
		end
	end

	local num2 = tonumber( i2 )
	if num2 then
		local numDigits2 = tonumber( digits2 )
		if numDigits2 then
			i2 = zo_clamp( num2, 1, ( 10 ^ numDigits2 ) - 1 )
		end
	end

	local num3 = tonumber( i3 )
	if num3 then
		local numDigits3 = tonumber( digits3 )
		if numDigits3 then
			i3 = zo_clamp( num3, 1, ( 10 ^ numDigits3 ) - 1 )
		end
	end

	local s
	if i3 then s = string.format( "%-." .. tostring( digits1 ) .. "d%-." .. tostring( digits2 ) .. "d%-." .. tostring( digits3 ) .. "d", self:Round( i1, 0 ), self:Round( i2, 0 ), self:Round( i3, 0 ) )
	elseif i2 then s = string.format( "%-." .. tostring( digits1 ) .. "d%-." .. tostring( digits2 ) .. "d", self:Round( i1, 0 ), self:Round( i2, 0 ) )
	else s = string.format( "%-." .. tostring( digits1 ) .. "d", self:Round( i1, 0 ) ) end
	return "1" .. s
end

function EHH:DecompressInteger( i, index1, index2 )
	index1, index2 = index1 + 1, index2 + 1
	local s = tostring( i )
	return tonumber( string.sub( s, index1, index2 ) )
end

---[ Strings ]---

function EHH:GetStringOccurrenceCount(text, pattern)
	return select(2, text:gsub(pattern, ""))
end

function EHH:SerializeNumbers(t, precision)
	local s = ""
	precision = tostring(precision or 4)

	for _, n in ipairs(t) do
		s = string.format("%s%." .. precision .. "f;", s, n)
	end

	if "" ~= s then
		s = string.sub(s, 1, -2)
	end

	return s
end

function EHH:DeserializeNumbers(s)
	local t = {}

	if not s then
		return t
	end

	for n in string.gmatch(s, "[%d\.\,]+") do
		table.insert(t, n)
	end

	return t
end

function EHH:FromId64(n, defaultValue)
	if "string" == type(n) then
		return n
	end

	if "number" ~= type(n) then
		return defaultValue or ""
	end

	local s = tostring(n)
	if "-nan" == s or 8 < #s then
		return Id64ToString(n)
	else
		return tostring(n)
	end
end

function EHH:Trim(s)
	if nil ~= s then
		return s:gsub("^%s*(.-)%s*$", "%1")
	else
		return nil
	end
end

function EHH:CompareStrings(s1, s2)
	if nil == s1 and nil == s2 then
		return true
	end

	if nil == s1 or nil == s2 then
		return false
	end

	return string.lower(self:Trim(s1)) == string.lower(self:Trim(s2))
end

function EHH:Split(s, separator)
	if nil == separator then
		separator = "%s"
	end

	local t = {}
	local i = 1

	for ss in string.gmatch(s, "([^" .. separator .. "]+)") do
		t[ i ] = ss
		i = i + 1
	end

	return t
end

function EHH:FormatCurrency(value, abbreviate)
	value = tonumber(value)

	if value then
		local avalue = math.abs(value)
		if abbreviate then
			if avalue < 1000 then
				return tostring(value)
			elseif avalue < 999000 then
				return string.format("%.1fk", value / 1000)
			else
				return string.format("%.1fm", value / 1000000)
			end
		else
			local SEPARATOR = "eu" == self.World and "." or ","
			if avalue < 1000 then
				return string.format("%d", value)
			elseif avalue < 1000000 then
				return string.format("%d%s%0.3d", value / 1000, SEPARATOR, avalue % 1000)
			else
				return string.format("%d%s%0.3d%s%0.3d", value / 1000000, SEPARATOR, (avalue % 1000000) / 1000, SEPARATOR, avalue % 1000)
			end
		end
	end
end

---[ Tables ]---

function EHH:ShadowFunction(tbl, functionName, shadowFunction)
	if nil == shadowFunction or "function" ~= type(shadowFunction) or nil == tbl or "table" ~= type(tbl) then
		return false
	end

	local originalFunc = tbl[functionName]
	if nil == originalFunc or "function" ~= type(originalFunc) then
		return false
	end

	local replacementFunc = function(...)
		return shadowFunction(originalFunc, ...)
	end

	tbl[functionName] = replacementFunc
	return true
end

function EHH:CloneTable(obj)
	if "table" ~= type(obj) then
		return obj
	end

	local tbl = {}

	for k, v in pairs(obj) do
		tbl["table" ~= type(k) and k or self:CloneTable(k)] = "table" ~= type(v) and v or self:CloneTable(v)
	end

	return tbl
end

function EHH:GetTableValueKey(t, value)
	if t then
		for key, v in pairs(t) do
			if value == v then
				return key
			end
		end
	end

	return nil
end

function EHH:IsTableValue(t, value)
	return self:GetTableValueKey(t, value) ~= nil
end

function EHH:GetNumTableValues(t)
	local count = 0

	if t then
		for _, _ in pairs(t) do
			count = count + 1
		end
	end

	return count
end

---[ Settings ]---

function EHH:GetCurrentGameSetting(settingType, settingId)
	if settingType and settingId then
		return GetSetting(settingType, settingId)
	end
end

function EHH:GetPreservedGameSettings()
	local preservedSettings = self:GetSetting("PreservedGameSettings")
	if not preservedSettings then
		preservedSettings = {}
		self:SetSetting("PreservedGameSettings", preservedSettings)
	end

	return preservedSettings
end

function EHH:GetPreservedGameSetting(settingType, settingId)
	if settingType and settingId then
		local preservedSettings = self:GetPreservedGameSettings()
		local key = string.format("%s__%s", tostring(settingType), tostring(settingId))
		local setting = preservedSettings[key]

		if setting then
			return setting[3]
		end
	end

	return nil
end

function EHH:PreserveGameSetting(settingType, settingId)
	local value = nil

	if settingType and settingId then
		value = GetSetting(settingType, settingId)

		local preservedSettings = self:GetPreservedGameSettings()
		local key = string.format("%s__%s", tostring(settingType), tostring(settingId))

		if not preservedSettings[key] then
			preservedSettings[key] = {settingType, settingId, value}
		end
	end

	return value
end

function EHH:ModifyGameSetting(settingType, settingId, value)
	if settingType and settingId then
		self:PreserveGameSetting(settingType, settingId)
		SetSetting(settingType, settingId, value)

		return value
	end

	return nil
end

function EHH:RestoreGameSetting(settingType, settingId)
	local value = nil

	if settingType and settingId then
		local preservedSettings = self:GetPreservedGameSettings()
		local key = string.format("%s__%s", tostring(settingType), tostring(settingId))
		local setting = preservedSettings[key]

		if setting and 3 <= #setting then
			value = setting[3]
			SetSetting(setting[1], setting[2], setting[3])
		end

		preservedSettings[key] = nil
	end

	return value
end

function EHH:RestoreAllGameSettings()
	local preservedSettings = self:GetPreservedGameSettings()

	for key, setting in pairs(preservedSettings) do
		if 3 <= #setting then
			SetSetting(setting[1], setting[2], setting[3])
		end
	end

	for key in pairs(preservedSettings) do
		preservedSettings[key] = nil
	end
end

---[ Debugging ]---

function EHH:GetCondensedStackTrace()
	local stack = debug.traceback()
	local openStartPosition, openEndPosition = 0, 0
	local closeStartPosition, closeEndPosition = 0, 0

	repeat
		openStartPosition, openEndPosition = string.find(stack, "<Locals>", closeEndPosition)
		if not openEndPosition then
			break
		end

		closeStartPosition, closeEndPosition = string.find(stack, "</Locals>", openEndPosition)
		if not closeEndPosition or closeEndPosition <= openEndPosition then
			break
		end

		local newStack = string.sub(stack, 1, openStartPosition - 1) .. string.sub(stack, closeEndPosition + 1, -1)
		stack = newStack

		closeEndPosition = openEndPosition + 1
	until closeEndPosition >= #stack

	return stack
end

function EHH:GetCallstackFunctionName(stackDepth)
	stackDepth = stackDepth or 1

	local stack = debug.traceback()
	local matchedString, startPosition, endPosition = nil, 1, 1

	repeat
		startPosition, endPosition, matchedString = string.find(stack, "in function '([%w%.]+)'", endPosition)
		stackDepth = stackDepth - 1
	until 0 >= stackDepth or not startPosition

	return matchedString
end

function EHH:GetCallstackFunctionNames(startingStackDepth)
	startingStackDepth = startingStackDepth or 2

	local stack = debug.traceback()
	local matchedString, startPosition, endPosition = nil, 1, 1
	local matches = {}
	local stackDepth = 0

	repeat
		startPosition, endPosition, matchedString = string.find(stack, "in function '([%w%.]+)'", endPosition)
		stackDepth = stackDepth + 1
		if matchedString and stackDepth >= startingStackDepth then
			table.insert(matches, matchedString)
		end
	until not startPosition

	return matches
end

function EHH:GetCallerFunctionName()
	return self:GetCallstackFunctionName(4)
end

function EHH:GetCallstackFunctionNamesString()
	return table.concat(self:GetCallstackFunctionNames(3), "\n")
end

---[ In-Game Time ]---

do
	local previousInGameTime = {0, 0}
	local previousInGameMinuteGameTimeS = 0

	function EHH:GetInGameTime()
		local h, m = 0, 0
		if self.InGameTimeOverride then
			h, m = self.InGameTimeOverride.hours, self.InGameTimeOverride.minutes
		else
			h, m = GetLocalTimeOfDay()
		end

		local gameTimeS = GetGameTimeSeconds()
		if previousInGameTime[1] ~= h or previousInGameTime[2] ~= m then
			previousInGameMinuteGameTimeS = gameTimeS
			previousInGameTime[1], previousInGameTime[2] = h, m
		end

		local s = ((gameTimeS - previousInGameMinuteGameTimeS) % 15.0) * 4.0
		return h, m, s
	end
end

function EHH:IsInGameDayTime()
	local hours = self:GetInGameTime()
	return hours >= 4 and hours <= 20
end

function EHH:GetInGameTimeString()
	local h, m = self:GetInGameTime()
	local half = "AM"

	if 0 == h then
		h = 12
	elseif 12 == h then
		half = "PM"
	elseif 12 < h then
		h = h - 12
		half = "PM"
	end

	return string.format("Tamriel time is %.2d:%.2d %s.", h, m, half)
end

function EHH:SlashCommandShowGuestbook()
	self.Effect:SummonGuestbook()
end

function EHH:SlashCommandShowInGameTime()
	self:ShowChatMessage(string.format("Tamriel time is %s", self:GetInGameTimeString()))
end

function EHH:SlashCommandSetInGameTime(timeLerp)
	timeLerp = tonumber(timeLerp)

	if timeLerp then
		self.InGameTimeOverride =
		{
			hours = math.floor(timeLerp * 24),
			minutes = math.floor(((timeLerp * 24) % 1) * 59),
		}
		self:ShowChatMessage("Time override set.")
	else
		self.InGameTimeOverride = nil
		self:ShowChatMessage("Time override cleared.")
	end

	self:ShowInGameTimeCommand()
end

---[ Subtitles ]---

-- Singleton
EHH.Subtitles = ZO_Object.New(ZO_Object:Subclass())
EHH.Subtitles.Queue = {}

local function Subtitles_OnUpdate()
	EHH.Subtitles:OnUpdate()
end

function EHH.Subtitles:RegisterForUpdate()
	HUB_EVENT_MANAGER:RegisterForUpdate("Subtitles_OnUpdate", 100, Subtitles_OnUpdate)
end

function EHH.Subtitles:OnUpdate()
	local subtitle = self.Queue[1]

	if not subtitle then
		HUB_EVENT_MANAGER:UnregisterForUpdate("Subtitles_OnUpdate")
		return
	end

	local ft = GetFrameTimeSeconds()

	if not subtitle.Expires then
		ZO_SUBTITLE_MANAGER:OnShowSubtitle("EHH_Subtitle", subtitle.Speaker, subtitle.Message)

		df("|cffff00%s|r: |cffffff%s", subtitle.Speaker or "Essential Housing Tools", subtitle.Message or "")

		local s = ZO_SUBTITLE_MANAGER.currentSubtitle
		s.displayLengthSeconds = s.displayLengthSeconds + 2
		subtitle.Expires = s.startTimeSeconds + s.displayLengthSeconds + 1.5

		local c = ZO_SUBTITLE_MANAGER.messageText
		c:GetOwningWindow():SetDrawLayer(DL_OVERLAY)
	elseif subtitle.Expires < ft then
		table.remove(self.Queue, 1)

		local c = ZO_SUBTITLE_MANAGER.messageText
		c:GetOwningWindow():SetDrawLayer(DL_TEXT)

		if "function" == type(subtitle.Callback) then
			subtitle.Callback()
		end
	end
end

function EHH.Subtitles:CreateSubtitle(speaker, message, callback)
	return { Speaker = speaker, Message = message, Callback = callback }
end

function EHH.Subtitles:QueueSubtitleMessage(subtitle)
	if not subtitle then return false end

	for index, queuedSubtitle in ipairs(self.Queue) do
		if	subtitle.Speaker == queuedSubtitle.Speaker and
			subtitle.Message == queuedSubtitle.Message then
			return false
		end
	end

	table.insert(self.Queue, subtitle)
	return true
end

function EHH.Subtitles:QueueMessages(speaker, messages, callback)
	local subtitle

	if speaker and messages then
		if "string" == type(messages) then
			subtitle = self:CreateSubtitle(speaker, messages, callback)
			self:QueueSubtitleMessage(subtitle)
		elseif "table" == type(messages) then
			local numMessages = #messages
			local message

			for index = 1, numMessages do
				subtitle = self:CreateSubtitle(speaker, message, index == numMessages and callback or nil)
				self:QueueSubtitleMessage(subtitle)
			end
		end

		self:RegisterForUpdate()
	end
end

---[ Worlds ]---

do
	local worldCodes =
	{
		["eu"] = true,
		["na"] = true,
		["pts"] = true,
	}

	function EHH:IsValidWorldCode(code)
		return worldCodes[code]
	end
	
	function EHH:GetAllWorldCodes()
		return self:CloneTable(worldCodes)
	end

	function EHH:GetWorldCode(code)
		if "string" == type(code) then
			code = string.lower(code)
			if self:IsValidWorldCode(code) then
				return code
			end
		end
		
		return self.World
	end
end

---[ Text Search ]---

--[[ USAGE

local search = self.TextSearch:New() search:SetFilter("brown -cow") d(search:Match("brown"))
search:SetFilter("brown -cow")

for _, text in pairs(list) do
	if search:Match(text) then
		-- ...
	end
end

]]--

EHH.TextSearch = ZO_Object:Subclass()

function EHH.TextSearch:New()
	return ZO_Object.New(self)
end

function EHH.TextSearch:SetFilter(filter)
	if not filter then return false end

	filter = string.lower(EHH:Trim(filter))
	if "" == filter then return false end

	filter = string.gsub(string.gsub(filter, "\+ +", "\+"), "\- +", "\-")

	local terms = { SplitString(" ,", filter) }
	if not terms then return false end

	local includeTerms, excludeTerms = {}, {}

	for index, term in ipairs(terms) do
		term = EHH:Trim(term)
		if "" ~= term then
			if "-" == string.sub(term, 1, 1) then
				term = string.sub(term, 2)
				table.insert(excludeTerms, term)
			elseif "+" == string.sub(1, 1) then
				term = string.sub(term, 2)
				table.insert(includeTerms, term)
			else
				table.insert(includeTerms, term)
			end
		end
	end
	
	if 0 == #includeTerms then
		includeTerms = nil
	end

	if 0 == #excludeTerms then
		excludeTerms = nil
	end

	self.FilterInclude = includeTerms
	self.FilterExclude = excludeTerms
end

function EHH.TextSearch:Match(expression)
	local include, exclude = self.FilterInclude, self.FilterExclude

	if include or exclude then
		expression = string.lower(EHH:Trim(expression or ""))

		if include then
			for index, term in ipairs(include) do
				if not PlainStringFind(expression, term) then
					return false
				end
			end
		end

		if exclude then
			for index, term in ipairs(exclude) do
				if PlainStringFind(expression, term) then
					return false
				end
			end
		end
	end

	return true
end

---[ Date & Time ]---

function EHH:GetDate(ts)
	return math.floor((ts or GetTimeStamp()) / self.Defs.Time.SecondsPerDay)
end

function EHH:GetDateCalendarDateAndTime(ts)
	local tsDate, tsTime = FormatAchievementLinkTimestamp(ts or GetTimeStamp())
	return tsDate, tsTime
end

function EHH:ConvertHoursToSeconds(hours)
	return hours * self.Defs.Time.SecondsPerHour
end

function EHH:ConvertDaysToSeconds(days)
	return days * self.Defs.Time.SecondsPerDay
end

function EHH:ConvertWeeksToSeconds(weeks)
	return weeks * self.Defs.Time.SecondsPerWeek
end

function EHH:ConvertYearsToSeconds(years)
	return years * self.Defs.Time.SecondsPerYear
end

function EHH:ConvertSecondsToDays(seconds)
	return seconds / self.Defs.Time.SecondsPerDay
end

function EHH:ConvertSecondsToWeeks(seconds)
	return seconds / self.Defs.Time.SecondsPerWeek
end

function EHH:ConvertSecondsToYears(seconds)
	return seconds / self.Defs.Time.SecondsPerYear
end

function EHH:GetTimeDeltaString(startTS, endTS, maxUnits, valueColor, unitColor)
	if not startTS then
		return ""
	end

	if not endTS then
		endTS = GetTimeStamp()
	end

	local timespanS = endTS - startTS
	return self:GetTimeSpanString(timespanS, maxUnits, valueColor, unitColor)
end

function EHH:GetTimeSpanString(timespanS, maxUnits, valueColor, unitColor)
	if not timespanS then return "" end
	valueColor, unitColor = valueColor or "", unitColor or ""
	maxUnits = zo_clamp(maxUnits or 2, 1, 2)

	local years = math.floor(timespanS / self.Defs.Time.SecondsPerYear)
	timespanS = timespanS - years * self.Defs.Time.SecondsPerYear

	local months = math.floor(timespanS / self.Defs.Time.SecondsPerMonth)
	timespanS = timespanS - months * self.Defs.Time.SecondsPerMonth

	local weeks = math.floor(timespanS / self.Defs.Time.SecondsPerWeek)
	timespanS = timespanS - weeks * self.Defs.Time.SecondsPerWeek

	local days = math.floor(timespanS / self.Defs.Time.SecondsPerDay)
	timespanS = timespanS - days * self.Defs.Time.SecondsPerDay

	local hours = math.floor(timespanS / self.Defs.Time.SecondsPerHour)
	timespanS = timespanS - hours * self.Defs.Time.SecondsPerHour

	local mins = math.floor(timespanS / 60)
	timespanS = timespanS - mins * 60

	local s1, s2, u1, u2

	if (not s1 or 1 < maxUnits) and 0 < years then
		if not s1 then
			s1 = string.format("%s%d%s year%s", valueColor, years, unitColor, 1 == years and "" or "s")
			u1 = "years"
		else
			s2 = string.format("%s%d%s year%s", valueColor, years, unitColor, 1 == years and "" or "s")
			u2 = "years"
		end
	end

	if (not s1 or (1 < maxUnits and "years" == u1)) and 0 < months then
		if not s1 then
			s1 = string.format("%s%d%s month%s", valueColor, months, unitColor, 1 == months and "" or "s")
			u1 = "months"
		else
			s2 = string.format("%s%d%s month%s", valueColor, months, unitColor, 1 == months and "" or "s")
			u2 = "months"
		end
	end

	if (not s1 or (1 < maxUnits and "years" == u1)) and 0 < weeks then
		if not s1 then
			s1 = string.format("%s%d%s week%s", valueColor, weeks, unitColor, 1 == weeks and "" or "s")
			u1 = "weeks"
		else
			s2 = string.format("%s%d%s week%s", valueColor, weeks, unitColor, 1 == weeks and "" or "s")
			u2 = "weeks"
		end
	end

	if (not s1 or (1 < maxUnits and ("months" == u1 or "weeks" == u1))) and 0 < days then
		if not s1 then
			s1 = string.format("%s%d%s day%s", valueColor, days, unitColor, 1 == days and "" or "s")
			u1 = "days"
		else
			s2 = string.format("%s%d%s day%s", valueColor, days, unitColor, 1 == days and "" or "s")
			u2 = "days"
		end
	end

	if (not s1 or (1 < maxUnits and "days" == u1)) and 0 < hours then
		if not s1 then
			s1 = string.format("%s%d%s hour%s", valueColor, hours, unitColor, 1 == hours and "" or "s")
			u1 = "hours"
		else
			s2 = string.format("%s%d%s hour%s", valueColor, hours, unitColor, 1 == hours and "" or "s")
			u2 = "hours"
		end
	end

	if (not s1 or (1 < maxUnits and "hours" == u1)) and 0 < mins then
		if not s1 then
			s1 = string.format("%s%d%s minute%s", valueColor, mins, unitColor, 1 == mins and "" or "s")
			u1 = "minutes"
		else
			s2 = string.format("%s%d%s minute%s", valueColor, mins, unitColor, 1 == mins and "" or "s")
			u2 = "minutes"
		end
	end

	if s1 then
		if s2 then
			return string.format("%s, %s", s1, s2)
		else
			return s1
		end
	end

	return ""
end

function EHH:GetRelativeTimeString(startTS, endTS, maxUnits, valueColor, unitColor)
	local s = self:GetTimeDeltaString(startTS, endTS, maxUnits, valueColor, unitColor)
	if "" ~= s then
		return s .. " ago"
	else
		return "just now"
	end
end

function EHH:GetRelativeAgeString(startTS, endTS, maxUnits, valueColor, unitColor)
	local s = self:GetTimeDeltaString(startTS, endTS, maxUnits, valueColor, unitColor)
	if "" ~= s then
		return s .. " old"
	else
		return "new"
	end
end

---[ Camera ]---

function EHH:IsFirstPersonCameraEnabled()
	--local playerX, playerY, playerZ = GetPlayerWorldPositionInHouse()
	--local cameraX, cameraY, cameraZ = EHH.Effect:GetCameraPosition()
	--return cameraX == playerX and cameraZ == playerZ
	return 0 == self:GetCurrentGameSetting(SETTING_PANEL_CAMERA, CAMERA_SETTING_DISTANCE)
end

function EHH:RestorePreferredCameraMode()
	self:RestoreGameSetting(SETTING_PANEL_CAMERA, CAMERA_SETTING_DISTANCE)
end

function EHH:SetCameraToFirstPerson()
	if not self:IsFirstPersonCameraEnabled() then
		self:ModifyGameSetting(SETTING_PANEL_CAMERA, CAMERA_SETTING_DISTANCE, 0)
	end
end

function EHH:SetCameraToThirdPerson()
	self:ModifyGameSetting(SETTING_PANEL_CAMERA, CAMERA_SETTING_DISTANCE, 16)
end

---[ Item Set Collections ]---

function EHH:PrintItemSetCollectionPieceCompletion()
	local total, unlocked = 0, 0

	for _, piece in ITEM_SET_COLLECTIONS_DATA_MANAGER:ItemSetCollectionPieceIterator() do
		total = total + 1
		if piece:IsUnlocked() then
			unlocked = unlocked + 1
		end
	end

	df("You have unlocked |cffffff%d|r of |cffffff%d|r (|cffffff%.2f%%|r) total pieces.", unlocked, total, 100 * unlocked / total)
end

---[ Metrics ]---

EHH.Metric = ZO_Object:Subclass()
EHH.Metrics = ZO_Object.New( ZO_Object:Subclass() )
EHH.Metrics.List = { }

function EHH.Metrics:GetAll()
	return self.List
end

function EHH.Metrics:Add( ... )
	return EHH.Metric:New( ... )
end

function EHH.Metrics:Register( metric )
	self.List[ metric.Name ] = metric
end

function EHH.Metrics:SetValue( name, value )
	local metric = self:GetAll()[ name ]
	if metric then metric:SetValue( value ) end
end

function EHH.Metrics:GetAverage( name )
	local metric = self:GetAll()[ name ]
	if metric then return metric:GetAverage() end
end

function EHH.Metrics:Reset()
	for _, metric in pairs( self:GetAll() ) do
		metric:Reset()
	end

	d( "Metrics reset." )
end
SLASH_COMMANDS[ "/resetmetrics" ] = function() EHH.Metrics:Reset() end

function EHH.Metrics:Dump()
	local messages = { }

	for _, metric in pairs( self:GetAll() ) do
		table.insert( messages, metric:ToString() )
	end

	table.sort( messages )

	for index, message in ipairs( messages ) do
		d( message )
	end
end
SLASH_COMMANDS[ "/EHHmetrics" ] = function() EHH.Metrics:Dump() end

function EHH.Metric:New( name, units, dataSetSize, onUpdate )
	local o = ZO_Object.New( self )
	o.Name = name
	o.Units = units
	o.DataSetSize = dataSetSize or 10
	o.OnUpdate = onUpdate
	o:Reset()
	EHH.Metrics:Register( o )
	return o
end

function EHH.Metric:Reset()
	self.Value = nil
	self.Values = { }
	self.ValueIndex = 1
	self.ValueAvg = nil
	self.ValueMin = nil
	self.ValueMax = nil
end

function EHH.Metric:GetName()
	return self.Name
end

function EHH.Metric:GetUnits()
	return self.Units
end

function EHH.Metric:SetValue( value )
	if not value then return end

	self.Value = value
	self.ValueMin = math.min( self.ValueMin or value, value )
	self.ValueMax = math.max( self.ValueMax or value, value )
	self.Values[ self.ValueIndex ] = value
	self.ValueIndex = self.ValueIndex + 1

	if self.ValueIndex > self.DataSetSize then
		self.ValueIndex = 1
		self:Update()
	end
end

function EHH.Metric:Update()
	local numValues = #self.Values
	if 0 == numValues then return nil end

	local avg = 0
	for index = 1, numValues do
		avg = avg + self.Values[index]
	end

	self.ValueAvg = avg / numValues

	if self.OnUpdate then self.OnUpdate( self ) end
end

function EHH.Metric:GetValue()
	return self.Value
end

function EHH.Metric:GetMinMax()
	return self.ValueMin, self.ValueMax
end

function EHH.Metric:GetAverage()
	return self.ValueAvg
end

function EHH.Metric:ToString()
	local units = self:GetUnits() or ""
	local valueMin, valueMax = self:GetMinMax()

	return string.format( "%s: %d%s [%d%s - %d%s]", self:GetName(), self:GetAverage() or 0, units, valueMin or 0, units, valueMax or 0, units )
end

---[ Rotations ]---

do
	local OrientationWin, OrientationTex

	local function SetupOrientation()
		if not OrientationWin then
			local w = WINDOW_MANAGER:CreateTopLevelWindow("EHHTransformWindow")
			OrientationWin = w
			w:SetHidden( false )
			w:SetDimensions( 1, 1 )
			w:SetMovable( true )
			w:SetMouseEnabled( false )
			w:SetClampedToScreen( false )
			w:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, -10, -10 )
			w:Create3DRenderSpace()
		end

		if not OrientationTex then
			local t = WINDOW_MANAGER:CreateControl(nil, OrientationWin, CT_TEXTURE)
			OrientationTex = t
			t:SetHidden( true )
			t:Create3DRenderSpace()
			t:Set3DRenderSpaceOrigin( 0, 0, 0 )
			t:Set3DRenderSpaceOrientation( 0, 0, 0 )
		end

		return OrientationTex, OrientationWin
	end

	function EHH:TransformOrientation( pitch, yaw, roll, oPitch, oYaw, oRoll )
		local t = OrientationTex or SetupOrientation()
		t:Set3DRenderSpaceOrientation( oPitch, oYaw, oRoll )
		return t:Convert3DLocalOrientationToWorldOrientation( pitch, yaw, roll )
	end

	function EHH:TransformVector( pitch, yaw, roll, x, y, z )
		local t = OrientationTex or SetupOrientation()
		t:Set3DRenderSpaceOrigin( 0, 0, 0 )
		t:Set3DRenderSpaceOrientation( pitch, yaw, roll )
		return t:Convert3DLocalPositionToWorldPosition( x, y, z )
	end

	function EHH:OnWorldChange()
		local t, w = SetupOrientation()

		w:Destroy3DRenderSpace()
		w:Create3DRenderSpace()

		t:Destroy3DRenderSpace()
		t:Create3DRenderSpace()
	end

	HUB_EVENT_MANAGER:RegisterForEvent("EHHTransformOnWorldChange", EVENT_PLAYER_ACTIVATED, function() EHH:OnWorldChange() end)
end

---[ Emotes ]---

do
	function EHH:BuildEmoteSlashNameTable()
		if not self.EmoteSlashNameTable then
			self.EmoteSlashNameTable = { }
			local numEmotes = GetNumEmotes()
			for i = 1, numEmotes do
				self.EmoteSlashNameTable[ string.lower( GetEmoteSlashNameByIndex( i ) ) ] = i
			end
		end
	end

	function EHH:GetEmoteSlashNames()
		self:BuildEmoteSlashNameTable()
		return self.EmoteSlashNameTable
	end

	function EHH:GetEmoteIndexBySlashName( slashName )
		if nil == slashName then
			return nil
		else
			self:BuildEmoteSlashNameTable()
			return self.EmoteSlashNameTable[ string.lower( slashName ) ]
		end
	end

	function EHH:PlayEmote( slashName )
		PlayEmoteByIndex( self:GetEmoteIndexBySlashName( slashName ) )
	end
end

---[ UMTD ]---

function EHH:InitUMTD()
	if not self.UMTD then
		local curDate = self:GetDateCalendarDateAndTime()
		local numHouses = self:GetNumHousesOwned()
		local ts = GetTimeStamp()

		self.UMTDDirty = true
		self.UMTD =
		{
			ver = self.AddOnVersion,
			dt = curDate,
			sv = self.World,
			ts = ts,

			m_hown = numHouses,
			m_fexc = "",
			m_lexc = "",

			n_bkrs = 0,
			n_bld = 0,
			n_exc = 0,
			n_fxp = 0,
			n_hop = 0,
			n_hvis = 0,
			n_gvis = 0,
			n_ohvis = 0,
			n_js = 0,
			n_ptl = 0,
			n_scc = 0,
			n_spas = 0,
			n_sres = 0,
			n_ssvd = 0,
			n_trg = 0,
			n_trgact = 0,
			n_scl = 0,
			n_scvis = 0,

			u_fxed = 0,
			u_fx = 0,
			u_h = 0,
			u_hh = 0,
			u_eht = 0,
		}

		self:SetComUMTD(self:SerialUMTD())
		
		EVENT_MANAGER:RegisterForUpdate("EHHUpdateUMTD", 10000, function()
			self:UpdateUMTD()
		end)

		EVENT_MANAGER:RegisterForUpdate("EHHProcessUMTD", 60000, function()
			self:ProcessUMTD()
		end)

		if self.IsDev then
			SLASH_COMMANDS["/umtd"] = function()
				d("[ UMTD ]")
				d(self.UMTD)
			end
		end
	end
end

function EHH:SerialUMTD()
	local umtd = self.UMTD
	if not umtd then
		return ""
	end

	local umtdVS = {}
	for p, v in pairs(umtd) do
		local umtdv = string.format("%s:%s;", tostring(p), tostring(v))
		table.insert(umtdVS, umtdv)
	end

	return table.concat(umtdVS, "")
end

function EHH:ProcessUMTD()
	if self.UMTDDirty then
		self.UMTDDirty = false
		self:SetComUMTD(self:SerialUMTD())
	end
end

function EHH:UpdateUMTD()
	local umtd = self.UMTD
	if umtd then
		if not self:IsHousingHubHidden() then
			self.UMTDDirty = true
			umtd.u_hh = umtd.u_hh + 10
		end

		if 0 ~= GetCurrentZoneHouseId() then
			self.UMTDDirty = true
			umtd.u_h = umtd.u_h + 10

			local u_fx = false

			if next(self.Effect:GetAll()) then
				umtd.u_fx = umtd.u_fx + 10
				u_fx = true
			end

			if EHT then
				local editor = EFFECT_EDITOR
				if editor and editor:IsEditing() then
					umtd.u_fxed = umtd.u_fxed + 10
				end

				if not u_fx and EHT.Effect and EHT.Effect.GetAll and next(EHT.Effect:GetAll()) then
					umtd.u_fx = umtd.u_fx + 10
				end

				if EHT.UI and EHT.UI.IsToolDialogHidden and not EHT.UI.IsToolDialogHidden() then
					umtd.u_eht = umtd.u_eht + 10
				end
			end
		end
	end
end

function EHH:IncUMTD(key, aval, instant)
	if not self.UMTD then
		if self.IsDev then df("%s\nIncUMTD called prior to init.", self:GetCondensedStackTrace()) end
		return false
	end

	if "string" ~= type(key) or "number" ~= type(aval) then
		if self.IsDev then df("Invalid UMTD '%s' : '%s'", tostring(key) or "(nil)", tostring(aval) or "(nil)") end
		return false
	end

	local oval = self.UMTD[key]
	if "number" ~= type(oval) then
		if self.IsDev then df("Invalid UMTD '%s' : '%s' (Current: '%s')", tostring(key) or "(nil)", tostring(aval) or "(nil)", tostring(oval) or "(nil)") end
		return false
	end

	local uval = oval + aval
	if uval == oval then
		return false
	end

	self.UMTD[key] = uval
	self.UMTDDirty = true
	
	if true == instant then
		self:ProcessUMTD()
	end

	return true
end

function EHH:SetUMTD(key, val)
	if not self.UMTD then
		if self.IsDev then df("%s\nSetUMTD called prior to init.", self:GetCondensedStackTrace()) end
		return false
	end

	if "string" ~= type(key) then
		if self.IsDev then df("Invalid UMTD '%s' : '%s'", tostring(key) or "(nil)", tostring(val) or "(nil)") end
		return false
	end

	local oval = self.UMTD[key]
	local otype = type(oval)
	if nil == oval or type(val) ~= otype then
		if self.IsDev then df("Invalid UMTD '%s' : '%s'", tostring(key) or "(nil)", tostring(val) or "(nil)") end
		return false
	end

	if "string" == otype then
		val = string.gsub(string.gsub(tostring(val), "[,:;]", " "), "\n", "\\n")
	end

	if val == oval then
		return false
	end

	self.UMTD[key] = val
	self.UMTDDirty = true
	return true
end

---[ To Do ]---

function EHH:AreGuidelinesEnabled()
	-- TODO
	return false
end

function EHH:RefreshPositionDialog()
	-- TODO
end

function EHH:SetToolDialogWindowTitle()
	-- TODO
end

function EHH:OnFurniturePlaced()
	-- TODO
end

function EHH:PlaySoundEffectCloned()
	-- TODO
end

function EHH:RefreshPlacedEffectsList()
	-- TODO
end

---[ Versions ]---

function EHH:ParseVersionString(version)
	version = tostring(version)
	if not version or #version < 5 then
		return
	end

	local sepIndex1 = string.find(version, "[.]")
	if not sepIndex1 then
		return
	end

	local sepIndex2 = string.find(version, "[.]", sepIndex1 + 1)
	if not sepIndex2 then
		return
	end

	if sepIndex1 <= 1 or sepIndex1 >= (sepIndex2 - 1) or sepIndex2 >= #version then
		return
	end

	local versionMajor = tonumber(string.sub(version, 1, sepIndex1 - 1))
	local versionMinor = tonumber(string.sub(version, sepIndex1 + 1, sepIndex2 - 1))
	local versionBuild = tonumber(string.sub(version, sepIndex2 + 1))
	if not versionMajor or not versionMinor or not versionBuild then
		return
	end

	local compoundVersion = versionMajor * 1000000 + versionMinor * 1000 + versionBuild
	return compoundVersion, versionMajor, versionMinor, versionBuild
end

---[ Module Registration ]---

EssentialHousingHub.Modules.Utilities = true