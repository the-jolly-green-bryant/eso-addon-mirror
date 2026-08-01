if not EHT then EHT = { } end
if not EHT.Util then EHT.Util = { } end

local RAD45, RAD90, RAD180, RAD270, RAD360 = math.rad( 45 ), math.rad( 90 ), math.rad( 180 ), math.rad( 270 ), math.rad( 360 )
local ceil, floor, min, max, cos, sin, rad, deg = math.ceil, math.floor, math.min, math.max, math.cos, math.sin, math.rad, math.deg
local round = function( n, d ) if nil == d then return zo_roundToZero( n ) else return zo_roundToNearest( n, 1 / ( 10 ^ d ) ) end end
local BASE_88_DIGITS, BASE_88_VALUES = { }, { }
for i = 0, 87 do
	table.insert( BASE_88_DIGITS, string.char( i + 36 ) )
	BASE_88_VALUES[ string.char( i + 36 ) ] = i
end

local SECONDS_PER_HOUR = 60 * 60
local SECONDS_PER_DAY = 24 * SECONDS_PER_HOUR
local SECONDS_PER_MONTH = 31 * SECONDS_PER_DAY
local SECONDS_PER_WEEK = 7 * SECONDS_PER_DAY
local SECONDS_PER_YEAR = 365 * SECONDS_PER_DAY

---[ Bitwise Flags ]---

local bit = { }
EHT.Bit = bit

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

---[ Serialization ]---

local MAX_SAVED_STRING_LEN = 1999

function EHT.Util.Deserialize(s)
	local data = nil
	local success = false

	if "string" == type(s) and #s > 2 and "{" == string.sub(s, 1, 1) and "}" == string.sub(s, -1, -1) then
		success, data = pcall(function() return zo_loadstring("return " .. s)() end)
	end

	if not success and EHT.IsDev then
		zo_callLater(function()
			d("WARNING: Invalid deserialization string:")
			d(s)
			d("[Stack]")
			d(debug.traceback())
		end, 5000)
	end

	return data or {}
end

function EHT.Util.Serialize( t )
	local tt = type( t )
	local s, tk, tv

	if "string" == tt then
		s = string.format( "%q", t )
	elseif "number" == tt then
		local _, f = math.modf( t )

		if 0 == f then
			s = string.format( "%d", t )
		else
			local decimals = 0

			repeat
				decimals = decimals + 1
				_, f = math.modf( t * 10 ^ decimals )
			until decimals >= 5 or 0 == f

			s = string.format( "%." .. tostring( decimals ) .. "f", t )
		end
	elseif "table" == tt then
		local b = { }

		table.insert( b, "{" )
		for k, v in pairs( t ) do
			tk = EHT.Util.Serialize( k )
			tv = EHT.Util.Serialize( v )

			if "" ~= tk and "" ~= tv then
				table.insert( b, string.format( "[%s]=%s,", tk, tv ) )
			end
		end
		table.insert( b, "}" )

		s = table.concat( b, "" )
	else
		s = ""
	end

	return s
end

local function estsizeof( t )
	local s = 0
	local tt = type( t )

	if "number" == tt then
		return 8 + 2
	elseif "string" == tt then
		return #t + 2
	elseif "table" == tt then
		for k, v in pairs( t ) do
			s = s + estsizeof( k ) + estsizeof( v ) + 6
		end
		s = s + 2
	end

	return s
end
EHT.Util.EstimateSizeOf = estsizeof

function EHT.Util.DeserializeSaved( t )
	if "string" == type( t ) then
		return EHT.Util.Deserialize( t )
	elseif "table" == type( t ) and t[0] then
		local st = EHT.Util.CloneTable( t )
		st[0] = nil
		return EHT.Util.Deserialize( table.concat( st, "" ) )
	else
		return t
	end
end

function EHT.Util.SerializeSaved( t )
	local s = EHT.Util.Serialize( t )

	if #s <= MAX_SAVED_STRING_LEN then
		return s
	end

	local st = { }
	local i = 1

	while i < #s do
		table.insert( st, string.sub( s, i, i - 1 + MAX_SAVED_STRING_LEN ) )
		i = i + MAX_SAVED_STRING_LEN
	end

	st[0] = #s
	return st
end
-- /sc s=EHT.Util.SerializeSaved( { "abc", "def", string.rep( "test ", 500 ) } ) t=EHT.Util.DeserializeSaved( s ) d( s ) d( t )

---[ Metrics ]---

EHT.Metric = ZO_Object:Subclass()
EHT.Metrics = ZO_Object.New( ZO_Object:Subclass() )
EHT.Metrics.List = { }

function EHT.Metrics:GetAll()
	return self.List
end

function EHT.Metrics:Add( ... )
	return EHT.Metric:New( ... )
end

function EHT.Metrics:Register( metric )
	self.List[ metric.Name ] = metric
end

function EHT.Metrics:SetValue( name, value )
	local metric = self:GetAll()[ name ]
	if metric then metric:SetValue( value ) end
end

function EHT.Metrics:GetAverage( name )
	local metric = self:GetAll()[ name ]
	if metric then return metric:GetAverage() end
end

function EHT.Metrics:Reset()
	for _, metric in pairs( self:GetAll() ) do
		metric:Reset()
	end

	d( "Metrics reset." )
end
SLASH_COMMANDS[ "/resetmetrics" ] = function() EHT.Metrics:Reset() end

function EHT.Metrics:Dump()
	local messages = { }

	for _, metric in pairs( self:GetAll() ) do
		table.insert( messages, metric:ToString() )
	end

	table.sort( messages )

	for index, message in ipairs( messages ) do
		d( message )
	end
end
SLASH_COMMANDS[ "/ehtmetrics" ] = function() EHT.Metrics:Dump() end

function EHT.Metric:New( name, units, dataSetSize, onUpdate )
	local o = ZO_Object.New( self )
	o.Name = name
	o.Units = units
	o.DataSetSize = dataSetSize or 10
	o.OnUpdate = onUpdate
	o:Reset()
	EHT.Metrics:Register( o )
	return o
end

function EHT.Metric:Reset()
	self.Value = nil
	self.Values = { }
	self.ValueIndex = 1
	self.ValueAvg = nil
	self.ValueMin = nil
	self.ValueMax = nil
end

function EHT.Metric:GetName()
	return self.Name
end

function EHT.Metric:GetUnits()
	return self.Units
end

function EHT.Metric:SetValue( value )
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

function EHT.Metric:Update()
	local numValues = #self.Values
	if 0 == numValues then return nil end

	local avg = 0
	for index = 1, numValues do
		avg = avg + self.Values[index]
	end

	self.ValueAvg = avg / numValues

	if self.OnUpdate then self.OnUpdate( self ) end
end

function EHT.Metric:GetValue()
	return self.Value
end

function EHT.Metric:GetMinMax()
	return self.ValueMin, self.ValueMax
end

function EHT.Metric:GetAverage()
	return self.ValueAvg
end

function EHT.Metric:ToString()
	local units = self:GetUnits() or ""
	local valueMin, valueMax = self:GetMinMax()

	return string.format( "%s: %d%s [%d%s - %d%s]", self:GetName(), self:GetAverage() or 0, units, valueMin or 0, units, valueMax or 0, units )
end

---[ Utilities : Math ]---

math.bit = function( index ) return 2 ^ ( index - 1 ) end
math.hasBit = function( flags, bit ) return flags % ( bit + bit ) >= bit end
math.setBit = function( flags, bit ) return math.hasBit( flags, bit ) and flags or flags + bit end
math.clearBit = function( flags, bit ) return math.hasBit( flags, bit ) and flags - bit or flags end

-- Add function that identifies a NaN value.
math.isnan = function( n ) return nil ~= n and ( n ~= n or -n ~= -n ) end

-- Add function that converts any NaN values into 0 or an optional Default Value.
math.unnan = function( n, defaultValue ) if nil ~= n and ( n ~= n or -n ~= -n ) then return defaultValue or 0 else return n end end

-- Add function that returns the polarity of a given number.
math.polarity = function( n, z ) if nil == n then return nil else return 0 < n and 1 or 0 > n and -1 or ( z or 0 ) end end

math.VecNormalize = function( x, y, z )
	local length = x + y + z
	return x / length, y / length, z / length
end

math.VecMagnitude = function( x, y, z )
	return math.sqrt( x * x + y * y + z * z )
end

math.VecDotProduct = function( ux, uy, uz, vx, vy, vz )
	return ux * vx + uy * vy + uz * vz
end

math.VecCrossProduct = function( ux, uy, uz, vx, vy, vz )
	return uy * vz - uz * vy, uz * vx - ux * vz, ux * vy - uy * vx
end

function EHT.Util.SnapToPercent( percent, previousP )
	percent = round( percent * 100 )
	local m = percent % 25
	local p
	if m < 4 then
		p = ( percent - m ) / 100
	elseif m > 21 then
		p = ( percent + 25 - m ) / 100
	else
		p = round( percent / 2 ) / 50
	end
	if previousP and math.abs( p - previousP ) <= 0.02 then
		return percent / 100
	else
		return p
	end
end

function EHT.Util.EaseOut( percent, exponent )
    return 1 - ( ( 1 - percent ) ^ exponent )
end

function EHT.Util.EaseOutIn( percent, exponent )
	if 0.5 > percent then
		return 0.5 * ( ( percent * 2 ) ^ exponent )
    else
		return 1 - 0.5 * ( ( ( 1 - percent ) * 2 ) ^ exponent )
	end
end

function EHT.Util.ConvertToRange( value, domainMin, domainMax, rangeMin, rangeMax )
	if nil ~= value and nil ~= domainMin and nil ~= domainMax and nil ~= rangeMin and nil ~= rangeMax then
		return zo_clamp( rangeMin + ( ( value - domainMin ) / ( domainMax - domainMin ) ) * ( rangeMax - rangeMin ), rangeMin, rangeMax )
	else
		return nil
	end
end

function EHT.Util.Round( n, decimals )
	if nil == decimals then decimals = 0 end
	return zo_roundToNearest( n, 1 / math.pow( 10, decimals ) )
end

function EHT.Util.ComputeCRC( block )
	local crc = 0
	local ceiling = 7640
	local offset = 100

	if "string" == type( block ) and "" ~= block then
		for index = 1, #block do
			crc = crc + string.byte( block, index )
		end
	end

	local crcEncoded = EHT.Util.IntToBase88( offset + ( crc % ceiling ) )

	if EHT.DEBUG_MODE then
		d( "EHT.Util.ComputeCRC" )
		d( "Block:" )
		d( block )
		df( "Full CRC: %d", crc )
		df( "Offset+Modulo: %d", offset + ( crc % ceiling ) )
		df( "Encoded: %s", crcEncoded )
	end

	return crcEncoded
end

function EHT.Util.IntToBase88( n )
	assert( nil ~= n, "Parameter 'n' must be non-null." )
	if type( n ) == "string" then n = tonumber( n ) end
	assert( type( n ) == "number", "Parameter 'n' must be numeric." )

	local s = ""
	local dec, sign = 0, 1

	n = math.floor( n )
	if 0 > n then
		n = n * -1
		sign = -1
	end

	repeat
		dec = n % 88
		s = BASE_88_DIGITS[ dec + 1 ] .. s
		n = math.floor( n / 88 )
	until 0 >= n or 32 < string.len( s )

	if 0 > sign then s = "#" .. s end

	return s
end

function EHT.Util.Base88ToInt( s )
	if "string" ~= type( s ) then return nil, "Base88 value must be of type 'string'" end
	if "" == s then return nil, "Base88 value cannot be empty" end

	local d, p, n, v = 0, 0, 0, 0
	local sign = 1

	if string.sub( s, 1, 1 ) == "#" then
		sign = -1
		s = string.sub( s, 2 )
	end

	for i = #s, 1, -1 do
		v = BASE_88_VALUES[ string.sub( s, i, i ) ]

		if nil == v then return nil, string.format( "Base88 value invalid: '%s'", tostring( s ) ) end
		if not v then break end

		d = math.pow( 88, p ) * v
		n = n + d
		p = p + 1
	end

	return sign * n
end
--[[
function EHT.Util.Base88ToInt( s, suppressErrors )
	if not suppressErrors then
		assert( "string" == type( s ), "Parameter 's' must be non-null." )
		assert( "" ~= s, "Parameter 's' must be non-empty." )
	else
		if "string" ~= type( s ) then return nil, "Base88 value must be of type 'string'" end
		if "" == s then return nil, "Base88 value cannot be empty" end
	end

	local d, p, n, v = 0, 0, 0, 0
	local sign = 1

	if string.sub( s, 1, 1 ) == "#" then
		sign = -1
		s = string.sub( s, 2 )
	end

	for i = string.len( s ), 1, -1 do
		v = BASE_88_VALUES[ string.sub( s, i, i ) ]

		if not suppressErrors then
			assert( nil ~= v, string.format( "Base88 value invalid: '%s'", tostring( s ) ) )
		else
			if nil == v then return nil, string.format( "Base88 value invalid: '%s'", tostring( s ) ) end
		end

		if not v then break end

		d = math.pow( 88, p ) * v
		n = n + d
		p = p + 1
	end

	return sign * n
end
]]
---[ Utilities : Compression ]---

-- Lossy [de]compression to single Integer for reduced storage and peer-to-peer transmission.
-- /script r, g, b = 0.24024, 0, 1 df( "%f, %f, %f", r,g,b )  i = EHT.Util.CompressColor( r, g, b ) d( i ) r,g,b = EHT.Util.DecompressColor( i ) df( "%f, %f, %f", r,g,b )

function EHT.Util.CompressColor( r, g, b )
	r, g, b = zo_clamp( r or 0, 0, 1 ), zo_clamp( g or 0, 0, 1 ), zo_clamp( b or 0, 0, 1 )
	r, g, b = math.max( 0, round( -1 + r * 100 ) ), math.max( 0, round( -1 + g * 100 ) ), math.max( 0, round( -1 + b * 100 ) )
	return r + 100 * g + 10000 * b
end

function EHT.Util.DecompressColor( i )
	if not i then
		return 1, 1, 1
	end
	i = i / 1000000
	local b = 1 + math.floor( i * 100 )
	local g = 1 + math.floor( ( ( i * 100 ) % 1 ) * 100 )
	local r = 1 + round( ( ( i * 10000 ) % 1 ) * 100 )
	r, g, b = math.min( 1, 1 == r and 0 or r / 100 ), math.min( 1, 1 == g and 0 or g / 100 ), math.min( 1, 1 == b and 0 or b / 100 )
	return r, g, b
end

function EHT.Util.CompressInteger( i1, digits1, i2, digits2, i3, digits3 )
	local s
	if i3 then s = string.format( "%-." .. tostring( digits1 ) .. "d%-." .. tostring( digits2 ) .. "d%-." .. tostring( digits3 ) .. "d", round( i1 ), round( i2 ), round( i3 ) )
	elseif i2 then s = string.format( "%-." .. tostring( digits1 ) .. "d%-." .. tostring( digits2 ) .. "d", round( i1 ), round( i2 ) )
	else s = string.format( "%-." .. tostring( digits1 ) .. "d", round( i1 ) ) end
	return "1" .. s
end

function EHT.Util.DecompressInteger( i, index1, index2 )
	index1, index2 = index1 + 1, index2 + 1
	local s = tostring( i )
	return tonumber( string.sub( s, index1, index2 ) )
end

---[ Utilities : Strings ]---

function string.serializeNumbers( t, precision )
	local s = ""
	precision = tostring( precision or 4 )

	for _, n in ipairs( t ) do
		s = string.format( "%s%." .. precision .. "f;", s, n )
	end

	if "" ~= s then
		s = string.sub( s, 1, -2 )
	end

	return s
end

function string.deserializeNumbers( s )
	local t = { }

	if not s then
		return t
	end

	for n in string.gmatch( s, "[%d\.\,]+" ) do
		table.insert( t, n )
	end

	return t
end

-- Add function that returns a non-NaN string return value from Id64ToString.
-- Returns a string form of any non-Furniture IDs (such as Effects).
-- Returns optional default value or empty string.
string.fromId64 = function( n, defaultValue )
	if "string" == type( n ) then return n end
	if "number" ~= type( n ) then return defaultValue or "" end

	local s = tostring( n )
	if "-nan" == s or 8 < #s then
		return Id64ToString( n )
	else
		return tostring( n )
	end
end

function EHT.Util.Trim( s )
	if nil ~= s then
		return s:gsub( "^%s*(.-)%s*$", "%1" )
	else
		return nil
	end
end

if nil == string.trim then string.trim = EHT.Util.Trim end

function EHT.Util.StringToNumber( s, defaultValue )
	local n = defaultValue

	if nil ~= s then
		n = tonumber( s )
		if nil == n then n = defaultValue end
	end

	return n
end

function EHT.Util.CompareText( s1, s2 )
	if nil == s1 and nil == s2 then return true end
	if nil == s1 or nil == s2 then return false end

	return string.lower( string.trim( s1 ) ) == string.lower( string.trim( s2 ) )
end

string.compare = function( s1, s2 )
	if "string" ~= type( s1 ) then
		return "string" ~= type( s2 ) and 0 or -1
	end

	if "string" ~= type( s2 ) then
		return 1
	end

	local l1, l2 = #s1, #s2
	local l = math.min( l1, l2 )
	local c1, c2

	for index = 1, l do
		c1, c2 = string.lower( string.sub( s1, index, index ) ), string.lower( string.sub( s2, index, index ) )

		if c1 < c2 then
			return -1
		elseif c2 < c1 then
			return 1
		end
	end

	if l1 < l2 then
		return -1
	elseif l2 < l1 then
		return 1
	end

	return 0
end

function EHT.Util.Split( s, separator )
	if nil == separator then separator = "%s" end

	local t = { }
	local i = 1

	for ss in string.gmatch( s, "([^" .. separator .. "]+)" ) do
		t[ i ] = ss
		i = i + 1
	end

	return t
end

function EHT.Util.FormatCurrency( value, abbreviate )
	value = tonumber( value )
	if value then
		local avalue = math.abs( value )
		if abbreviate then
			if avalue < 1000 then
				return tostring( value )
			elseif avalue < 999000 then
				return string.format( "%.1fk", value / 1000 )
			else
				return string.format( "%.1fm", value / 1000000 )
			end
		else
			local SEPARATOR = "eu" == EHT.Util.GetWorldCode() and "." or ","
			if avalue < 1000 then
				return string.format( "%d", value )
			elseif avalue < 1000000 then
				return string.format( "%d%s%0.3d", value / 1000, SEPARATOR, avalue % 1000 )
			else
				return string.format( "%d%s%0.3d%s%0.3d", value / 1000000, SEPARATOR, ( avalue % 1000000 ) / 1000, SEPARATOR, avalue % 1000 )
			end
		end
	end
end

function EHT.Util.HousingEditorModeToString( mode )
	if mode == HOUSING_EDITOR_MODE_BROWSE then return "Browse"
	elseif mode == HOUSING_EDITOR_MODE_DISABLED then return "Disabled"
	elseif mode == HOUSING_EDITOR_MODE_PLACEMENT then return "Placement"
	elseif mode == HOUSING_EDITOR_MODE_SELECTION then return "Selection"
	else return "" end
end

function EHT.Util.ParseEscapedString( text, startIndex )
	if not text then
		return nil
	end

	if "" == text then
		return ""
	end

	local textLen = #text
	local escaping = false
	local index = startIndex
	local c

	if "\"" == string.sub( text, index, index ) then
		index = index + 1
		startIndex = index
	end

	while index < textLen do
		c = string.sub( text, index, index )
		if "\"" == c and not escaping then
			break
		elseif "\\" == c then
			escaping = not escaping
		elseif escaping then
			escaping = false;
		end

		index = index + 1
	end

	return string.sub( text, startIndex, index - startIndex )
end

---[ Utilities : Repeater Button Behavior ]---

do
	local RepeaterButtonId = 0

	function EHT.Util.CreateRepeaterButton( pressedFunc, interval, initialInstant )
		if nil == pressedFunc then return nil end
		if nil == interval then interval = 120 end
		if nil == initialInstant then initialInstant = true end

		RepeaterButtonId = RepeaterButtonId + 1
		local callbackHandle = string.format( "EHTRepeaterButton%d", RepeaterButtonId )

		local repeater = {
			CallbackHandle = callbackHandle,
			InstantInitial = initialInstant,
			Interval = interval,
			PressedFunc = pressedFunc,
		}

		repeater.Press = function()
			EVENT_MANAGER:RegisterForUpdate( repeater.CallbackHandle, repeater.Interval, repeater.PressedFunc )

			if repeater.InstantInitial then
				repeater.PressedFunc()
			end
		end

		repeater.Release = function()
			EVENT_MANAGER:UnregisterForUpdate( repeater.CallbackHandle )
		end

		return repeater
	end

	function EHT.Util.CreateAndAssignRepeaterButton( control, pressedFunc, interval, initialInstant )
		if not control or not control.SetHandler then return nil end

		local repeater = EHT.Util.CreateRepeaterButton( pressedFunc, interval, initialInstant )
		if nil == repeater then return nil end

		control:SetHandler( "OnMouseDown", function() repeater.Press() end )
		control:SetHandler( "OnMouseUp", function() repeater.Release() end )

		return repeater
	end
end

---[ Utilities : Tables ]---

function table:isEmpty( t )
	if "table" ~= type( t ) then
		return true
	end
	for k, v in pairs( t ) do
		return false
	end
	return true
end

function EHT.Util.ShadowFunction( tbl, funcName, shadowFunc )
	if nil == shadowFunc or "function" ~= type( shadowFunc ) or nil == tbl or "table" ~= type( tbl ) then return false end

	local originalFunc = tbl[ funcName ]
	if nil == originalFunc or "function" ~= type( originalFunc ) then return false end

	local replacementFunc = function( ... )
		return shadowFunc( originalFunc, ... )
	end

	tbl[ funcName ] = replacementFunc

	return true
end

function EHT.Util.GetNextUnusedIndex( t, startIndex )
	local index = startIndex or 1

	while nil ~= t[index] do
		index = index + 1
	end

	return index
end

function EHT.Util.MergeTables( source, target )
	if nil == source then return target end
	if nil == target then return source end

	for key, value in pairs( source ) do
		target[ key ] = EHT.Util.CloneTable( value )
	end

	return target
end

function EHT.Util.UnionTables( t1, t2, keySerializer )
	local tables = { t1, t2 }
	local keys = { }
	local union = { }

	if keySerializer then
		for _, t in ipairs( tables ) do
			for _, v in pairs( t ) do
				local k = keySerializer( v, t )
				if not keys[ k ] then
					keys[ k ] = true
					table.insert( union, v )
				end
			end
		end
	else
		for _, t in ipairs( tables ) do
			for _, v in pairs( t ) do
				if not keys[ v ] then
					keys[ v ] = true
					table.insert( union, v )
				end
			end
		end
	end

	return union
end

function EHT.Util.CloneFurniture( o )
	if type( o ) ~= 'table' then return o end
	local i = { }
	i.Id, i.Icon, i.Link, i.X, i.Y, i.Z, i.Pitch, i.Yaw, i.Roll, i.EffectType, i.SizeX, i.SizeY, i.SizeZ, i.Color, i.Alpha = o.Id, o.Icon, o.Link, o.X, o.Y, o.Z, o.Pitch, o.Yaw, o.Roll, o.EffectType, o.SizeX, o.SizeY, o.SizeZ, o.Color, o.Alpha
	return i
end

function EHT.Util.CloneSceneFrameFurniture( o )
	if type( o ) ~= 'table' then return o end
	local i = { }
	i.Id, i.X, i.Y, i.Z, i.Pitch, i.Yaw, i.Roll, i.State, i.EffectType, i.SizeX, i.SizeY, i.SizeZ, i.Color, i.Alpha = o.Id, o.X, o.Y, o.Z, o.Pitch, o.Yaw, o.Roll, o.State, o.EffectType, o.SizeX, o.SizeY, o.SizeZ, o.Color, o.Alpha
	return i
end

function EHT.Util.IsListValue( list, value )
	for _, v in pairs( list ) do
		if value == v then return true end
	end

	return false
end

function EHT.Util.GetIndexOfListValue( list, value )
	for index, v in ipairs( list ) do
		if value == v then return index end
	end

	return nil
end

function EHT.Util.GetKeyOfListValue( list, value )
	for key, v in pairs( list ) do
		if value == v then return key end
	end

	return nil
end

function EHT.Util.TableCount( t )
	local count = 0
	if nil ~= t then for _, _ in pairs( t ) do count = count + 1 end end
	return count
end

---[ Settings ]---

function EHT.Util.GetCurrentSetting( settingType, settingId )
	if not settingType or not settingId then return end
	return GetSetting( settingType, settingId )
end

function EHT.Util.GetPreservedSetting( settingType, settingId )
	if not settingType or not settingId then return end

	local preservedSettings = EHT.SavedVars.PreservedSettings
	if not preservedSettings then
		preservedSettings = { }
		EHT.SavedVars.PreservedSettings = preservedSettings
	end

	local key = string.format( "%s__%s", tostring( settingType ), tostring( settingId ) )
	local setting = preservedSettings[ key ]

	if setting then
		return setting[3]
	else
		return nil
	end
end

function EHT.Util.PreserveSetting( settingType, settingId )
	if not settingType or not settingId then return end

	local preservedSettings = EHT.SavedVars.PreservedSettings
	if not preservedSettings then
		preservedSettings = { }
		EHT.SavedVars.PreservedSettings = preservedSettings
	end

	local key = string.format( "%s__%s", tostring( settingType ), tostring( settingId ) )
	local value = GetSetting( settingType, settingId )
	if not preservedSettings[ key ] then
		preservedSettings[ key ] = { settingType, settingId, value }
	end

	return value
end

function EHT.Util.ModifySetting( settingType, settingId, value )
	if not settingType or not settingId then return end

	EHT.Util.PreserveSetting( settingType, settingId )
	SetSetting( settingType, settingId, value )

	return value
end

function EHT.Util.RestoreSetting( settingType, settingId )
	if not settingType or not settingId then return end

	local preservedSettings = EHT.SavedVars.PreservedSettings
	if not preservedSettings then
		preservedSettings = { }
		EHT.SavedVars.PreservedSettings = preservedSettings
	end

	local key = string.format( "%s__%s", tostring( settingType ), tostring( settingId ) )
	local setting = preservedSettings[ key ]
	local value

	if setting and 3 <= #setting then
		value = setting[3]
		SetSetting( setting[1], setting[2], setting[3] )
	end

	EHT.SavedVars.PreservedSettings[ key ] = nil

	return value
end

function EHT.Util.RestoreAllSettings()
	local preservedSettings = EHT.SavedVars.PreservedSettings
	if not preservedSettings then
		preservedSettings = { }
		EHT.SavedVars.PreservedSettings = preservedSettings
	end

	for key, setting in pairs( preservedSettings ) do
		if 3 <= #setting then
			SetSetting( setting[1], setting[2], setting[3] )
		end
	end

	EHT.SavedVars.PreservedSettings = { }
end

---[ Utilities : Emotes ]---

do
	local EmoteSlashNameTable

	local function BuildEmoteSlashNameTable()
		if nil == EmoteSlashNameTable then
			EmoteSlashNameTable = { }
			local numEmotes = GetNumEmotes()
			for i = 1, numEmotes do
				EmoteSlashNameTable[ string.lower( GetEmoteSlashNameByIndex( i ) ) ] = i
			end
		end
	end

	function EHT.Util.GetEmoteSlashNames()
		BuildEmoteSlashNameTable()
		return EmoteSlashNameTable
	end

	function EHT.Util.GetEmoteIndexBySlashName( slashName )
		if nil == slashName then
			return nil
		else
			BuildEmoteSlashNameTable()
			return EmoteSlashNameTable[ string.lower( slashName ) ]
		end
	end

	function EHT.Util.PlayEmote( slashName )
		PlayEmoteByIndex( EHT.Util.GetEmoteIndexBySlashName( slashName ) )
	end
end

---[ Utilities : Miscellaneous ]---

function EHT.Util.GetCallstackFunctionName( stackDepth )
	stackDepth = stackDepth or 1

	local stack = debug.traceback()
	local matchedString, startPosition, endPosition = nil, 1, 1

	repeat
		startPosition, endPosition, matchedString = string.find( stack, "in function '([%w%.]+)'", endPosition )
		stackDepth = stackDepth - 1
	until 0 >= stackDepth or not startPosition

	return matchedString
end

function EHT.Util.GetCallstackFunctionNames( startingStackDepth )
	startingStackDepth = startingStackDepth or 2

	local stack = debug.traceback()
	local matchedString, startPosition, endPosition = nil, 1, 1
	local matches = { }
	local stackDepth = 0

	repeat
		startPosition, endPosition, matchedString = string.find( stack, "in function '([%w%.]+)'", endPosition )
		stackDepth = stackDepth + 1
		if matchedString and stackDepth >= startingStackDepth then
			table.insert( matches, matchedString )
		end
	until not startPosition

	return matches
end

function EHT.Util.GetCallerFunctionName()
	return EHT.Util.GetCallstackFunctionName( 4 )
end

function EHT.Util.GetCallstackFunctionNamesString()
	return table.concat( EHT.Util.GetCallstackFunctionNames( 3 ), "\n" )
end

local loopTracking = true
local loopTable = { }
local loopTableFrameTime = nil
local loopMaxCount = 10

function EHT.Util.LoopCounter( functionName )
	if not loopTracking then return end

	local frameTime = GetFrameTimeMilliseconds()
	if loopTableFrameTime ~= frameTime then loopTable = { } loopTableFrameTime = frameTime end

	local count = loopTable[ functionName ]
	if nil == count then count = 1 else count = count + 1 end
	loopTable[ functionName ] = count

	if EHT.DEBUG_MODE then df( "Called '%s' x%d", functionName, count ) end

	if count > loopMaxCount then return true else return false end
end

function EHT.Util.CheckForSharedFurnitureIds( startId, endId, bTest )
	local cName, fLink, fName

	startId = startId or 1
	endId = endId or 100000

	for id = startId, endId do
		cName = GetCollectibleName( id )

		fLink = EHT.Housing.GetFurnitureItemIdLink( id )
		if IsItemLinkPlaceableFurniture( fLink ) then
			fName = GetItemLinkName( fLink )

			if ( bTest or ( nil ~= cName and "" ~= cName ) ) and nil ~= fName and "" ~= fName then
				df( "Id %d : %s / %s", id, cName, fName )
			end
		end
	end
end

function EHT.Util.CustomReadyCheck( msg )
	return BeginGroupElection( GROUP_ELECTION_TYPE_GENERIC_UNANIMOUS, msg )
end

if not crc then crc = EHT.Util.CustomReadyCheck end

function loopEmote( slashName )
	if nil == slashName or "" == slashName then
		EVENT_MANAGER:UnregisterForUpdate( "EHTLoopEmote" )
		df( "All loops stopped." )
		return
	end

	local emoteIndex = EHT.Util.GetEmoteIndexBySlashName( slashName )
	if nil == emoteIndex or 0 >= emoteIndex then
		df( "Invalid slash name." )
		return
	end

	EVENT_MANAGER:RegisterForUpdate( "EHTLoopEmote", 150, function() PlayEmoteByIndex( emoteIndex ) end )
	df( "Looping emote index %d", emoteIndex )
	df( "Type /loopemote again to stop." )
end

SLASH_COMMANDS[ "/loopemote" ] = loopEmote

---[ Game Time ]---

local GAMETIME_OFFSET = 1394597000
local REALSECONDSPERGAMEDAY = 20955
local REALSECONDSPERGAMEHOUR = REALSECONDSPERGAMEDAY / 24
local REALSECONDSPERGAMEMINUTE = REALSECONDSPERGAMEHOUR / 60
local REALSECONDSPERGAMESECOND = REALSECONDSPERGAMEMINUTE / 60
local inGameTimeOverride
local previousInGameTime = {0, 0}
local previousInGameMinuteGameTimeS = 0

function EHT.Util.GetInGameTime()
	local h, m = 0, 0
	if inGameTimeOverride then
		h, m = inGameTimeOverride.hours, inGameTimeOverride.minutes
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

function EHT.Util.IsDayTime()
	local hours = EHT.Util.GetInGameTime()
	return hours >= 4 and hours <= 22
end

function EHT.Util.GetInGameTimeCommand()
	local h, m = EHT.Util.GetInGameTime()
	local half = "AM"

	if 0 == h then
		h = 12
	elseif 12 == h then
		half = "PM"
	elseif 12 < h then
		h = h - 12
		half = "PM"
	end

	df( "Tamriel time is %.2d:%.2d %s.", h, m, half )
end

function EHT.Util.SetInGameTimeCommand( timeLerp )
	timeLerp = tonumber( timeLerp )
	if timeLerp then
		inGameTimeOverride =
		{
			hours = math.floor( timeLerp * 24 ),
			minutes = math.floor( ( ( timeLerp * 24 ) % 1 ) * 59 ),
		}
		d("Time override set.")
	else
		inGameTimeOverride = nil
		d("Time override cleared.")
	end
	EHT.Util.GetInGameTimeCommand()
end

---[ Subtitles ]---

-- Singleton
EHT.Subtitles = ZO_Object.New( ZO_Object:Subclass() )
EHT.Subtitles.Queue = { }

local function Subtitles_OnUpdate()
	EHT.Subtitles:OnUpdate()
end

function EHT.Subtitles:RegisterForUpdate()
	EVENT_MANAGER:RegisterForUpdate( "Subtitles_OnUpdate", 100, Subtitles_OnUpdate )
end

function EHT.Subtitles:OnUpdate()
	local subtitle = self.Queue[1]

	if not subtitle then
		EVENT_MANAGER:UnregisterForUpdate( "Subtitles_OnUpdate" )
		return
	end

	local ft = GetFrameTimeSeconds()

	if not subtitle.Expires then
		ZO_SUBTITLE_MANAGER:OnShowSubtitle( "EHT_Subtitle", subtitle.Speaker, subtitle.Message )

		df( "|cffff00%s|r: |cffffff%s", subtitle.Speaker or "Essential Housing Tools", subtitle.Message or "" )

		local s = ZO_SUBTITLE_MANAGER.currentSubtitle
		s.displayLengthSeconds = s.displayLengthSeconds + 2
		subtitle.Expires = s.startTimeSeconds + s.displayLengthSeconds + 1.5

		local c = ZO_SUBTITLE_MANAGER.messageText
		c:GetOwningWindow():SetDrawLayer( DL_OVERLAY )
	elseif subtitle.Expires < ft then
		table.remove( self.Queue, 1 )

		local c = ZO_SUBTITLE_MANAGER.messageText
		c:GetOwningWindow():SetDrawLayer( DL_TEXT )

		if "function" == type( subtitle.Callback ) then
			subtitle.Callback()
		end
	end
end

function EHT.Subtitles:CreateSubtitle( speaker, message, callback )
	return { Speaker = speaker, Message = message, Callback = callback }
end

function EHT.Subtitles:QueueSubtitleMessage( subtitle )
	if not subtitle then return false end

	for index, queuedSubtitle in ipairs( self.Queue ) do
		if	subtitle.Speaker == queuedSubtitle.Speaker and
			subtitle.Message == queuedSubtitle.Message then
			return false
		end
	end

	table.insert( self.Queue, subtitle )
	return true
end

function EHT.Subtitles:QueueMessages( speaker, messages, callback )
	local subtitle

	if speaker and messages then
		if "string" == type( messages ) then
			subtitle = self:CreateSubtitle( speaker, messages, callback )
			self:QueueSubtitleMessage( subtitle )
		elseif "table" == type( messages ) then
			local numMessages = #messages
			local message

			for index = 1, numMessages do
				subtitle = self:CreateSubtitle( speaker, message, index == numMessages and callback or nil )
				self:QueueSubtitleMessage( subtitle )
			end
		end

		self:RegisterForUpdate()
	end
end

---[ Friends ]---

-- Singleton
EHT.Friends = ZO_Object.New( ZO_Object:Subclass() )

function EHT.Friends:GetAllDisplayNames()
	local numFriends = GetNumFriends()
	local list = { }
	local displayName

	for index = 1, numFriends do
		displayName = GetFriendInfo( index )
		list[displayName] = true
	end

	return list
end

---[ Guilds ]---

-- Singleton
EHT.Guilds = ZO_Object.New( ZO_Object:Subclass() )

EHT.Guilds.ProcessIntervalSeconds = 15
EHT.Guilds.ProcessTimeoutSeconds = 40
EHT.Guilds.ActionQueue = { }

function EHT.Guilds:GetNumQueuedActions()
	return self.ActionQueue and #self.ActionQueue or 0
end

function EHT.Guilds:FlushCache()
	self.GuildsCache = nil
	self.GuildMemberNamesCache = nil
	self.AllGuildMemberNamesCache = nil
end

function EHT.Guilds:OnGuildDataLoaded()
	EHT.Guilds:RestoreGuildMemberNotes()
	EHT.Guilds:CleanPreservedGuildMemberNotes()
end

function EHT.Guilds:LoadGuildData( guildIndex )
	local id = GetGuildId( guildIndex )

	if id and 0 ~= id then
		local canEditNotes, canReadNotes, description, motd, memberIndex, name, note, numMembers, rankIndex
		canEditNotes = DoesPlayerHaveGuildPermission( id, GUILD_PERMISSION_NOTE_EDIT )
		canReadNotes = DoesPlayerHaveGuildPermission( id, GUILD_PERMISSION_NOTE_READ )
		description = GetGuildDescription( id )
		memberIndex = GetPlayerGuildMemberIndex( id )
		motd = GetGuildMotD( id )
		name = GetGuildName( id )
		numMembers = GetNumGuildMembers( id )
		_, note, rankIndex = GetGuildMemberInfo( id, memberIndex )

		if name and "" ~= name then
			local guildhallOwner, guildhallHouseId

			if description and "" ~= description then
				-- Attempt to parse a guildhall tag in the form of:
				-- Guildhall: [HouseName] @OwnerName
				local _, hallTagEndIndex = string.find( string.lower( description ), "guildhall:", 1, true )
				if hallTagEndIndex then
					local houseNameStartIndex = hallTagEndIndex + 1
					local houseOwnerStartIndex = string.find( description, "@", houseNameStartIndex, true )
					if houseOwnerStartIndex then
						local descriptionLength = #description
						local houseOwnerEndIndex = houseOwnerStartIndex

						repeat
							houseOwnerEndIndex = houseOwnerEndIndex + 1
							local c = string.sub( description, houseOwnerEndIndex, houseOwnerEndIndex )
						until houseOwnerEndIndex >= descriptionLength or not c or "" == c or " " == c or "\n" == c

						if houseOwnerStartIndex < houseOwnerEndIndex then
							guildhallOwner = EHT.Util.Trim( string.sub( description, houseOwnerStartIndex, houseOwnerEndIndex ) )
							if guildhallOwner ~= "" and houseNameStartIndex < ( houseOwnerStartIndex - 2 ) then
								local houseName = EHT.Util.Trim( string.sub( description, houseNameStartIndex, houseOwnerStartIndex - 1 ) )
								if houseName ~= "" then
									local DO_NOT_USE_NICKNAMES = false
									local houses = EHT.Housing.FindHousesByName( houseName, DO_NOT_USE_NICKNAMES )

									if houses and houses[ 1 ] then
										guildhallHouseId = houses[ 1 ].Id
									end
								end
							end
						end
					end
				end
			end

			return {
				CanEditNotes = canEditNotes,
				CanReadNotes = canReadNotes,
				Description = description,
				GuildIndex = guildIndex,
				GuildhallOwner = guildhallOwner,
				GuildhallHouseId = guildhallHouseId,
				Id = id,
				MemberIndex = memberIndex,
				MotD = motd,
				Name = name,
				Note = note,
				NumMembers = numMembers,
				RankIndex = rankIndex,
			}
		end
	end
end

function EHT.Guilds:GetGuilds()
	if not self.GuildsCache then
		local list = { }

		for guildIndex = 1, GetNumGuilds() do
			list[ guildIndex ] = self:LoadGuildData( guildIndex )
		end

		self.GuildsCache = list
	end

	-- Always refresh local player's member index to avoid any desyncing issues.
	for _, guild in pairs( self.GuildsCache ) do
		guild.MemberIndex = GetPlayerGuildMemberIndex( guild.Id )
	end

	return self.GuildsCache
end

function EHT.Guilds:GetGuildByIndex( guildIndex )
	local guilds = self:GetGuilds()
	return guilds[guildIndex]
end

function EHT.Guilds:GetGuildById( guildId )
	local guilds = self:GetGuilds()

	for _, guild in ipairs( guilds ) do
		if guildId == guild.Id then
			return guild
		end
	end

	return nil
end

function EHT.Guilds:GetGuildByName( name, exactMatchOnly )
	name = EHT.Util.Trim( string.lower( name ) )
	if not name or "" == name then return nil end

	local guilds = self:GetGuilds()
	if not guilds then return nil end

	for index, guild in pairs( guilds ) do
		if ( exactMatchOnly and name == string.lower( guild.Name ) ) or ( not exactMatchOnly and string.sub( string.lower( guild.Name ), 1, #name ) == name ) then
			return guild
		end
	end

	return nil
end

function EHT.Guilds:GetGuildMemberIndex( guildId )
	local guild = self:GetGuildById( guildId )
	if not guild then return nil end

	return guild.MemberIndex
end

function EHT.Guilds:GetGuildMemberNames( guildIndex )
	if not self.GuildMemberNamesCache then
		self.GuildMemberNamesCache = { }

		for index = 1, GetNumGuilds() do
			local id = GetGuildId( index )

			if id and 0 ~= id then
				local list = { }
				self.GuildMemberNamesCache[ index ] = list

				local numMembers = GetNumGuildMembers( id )
				for memberIndex = 1, numMembers do
					local name = string.lower( EHT.Util.Trim( GetGuildMemberInfo( id, memberIndex ) or "" ) )
					if name ~= "" then
						table.insert( list, name )
					end
				end
			end
		end
	end

	return self.GuildMemberNamesCache[ guildIndex ]
end

function EHT.Guilds:GetAllGuildMemberNames()
	if not self.AllGuildMemberNamesCache then
		self.AllGuildMemberNamesCache = { }
		local list

		for index = 1, GetNumGuilds() do
			list = self:GetGuildMemberNames( index )
			if list then
				for _, name in pairs( list ) do
					self.AllGuildMemberNamesCache[ name ] = true
				end
			end
		end
	end

	return self.AllGuildMemberNamesCache
end

function EHT.Guilds:GetMatchingGuildMemberNames( partialName )
	if "string" ~= type( partialName ) then return end
	if #partialName < 2 then return end

	partialName = EHT.Util.Trim( string.lower( partialName ) )

	local names = self:GetAllGuildMemberNames()
	local partialLen = #partialName
	local matches

	for name in pairs( names ) do
		if string.sub( name, 1, partialLen ) == partialName then
			if not matches then matches = { } end
			matches[ name ] = true
		end
	end

	return matches
end

function EHT.Guilds:OnGuildMemberNoteChanged( guildId, note )
	local queue = self.ActionQueue
	local action = queue[1]

	if action then
		if guildId == action.GuildId and note == action.Note then
			table.remove( queue, 1 )
			return true
		end
	end

	return false
end

function EHT.Guilds.ProcessActionQueue()
	local self = EHT.Guilds
	local queue = self.ActionQueue
	local action = queue[1]
	local preservedNotes = EHT.SavedVars.PreservedGuildNotes

	if action then
		if not action.Processed then
			local note = action.Note
			local guildId = action.GuildId
			local guild = self:GetGuildById( guildId )

			if guildId and guild then
				local memberIndex = self:GetGuildMemberIndex( guildId )
				if memberIndex and 0 < memberIndex then
					action.Processed = GetGameTimeSeconds()
					SetGuildMemberNote( guildId, memberIndex, note )

					if action.Restored and preservedNotes then
						preservedNotes[guild.Name] = nil
					end

					return
				end
			end
		elseif ( GetGameTimeSeconds() - action.Processed ) < self.ProcessTimeoutSeconds then
			return
		end

		table.remove( queue, 1 )
	else
		EVENT_MANAGER:UnregisterForUpdate( "EHT.Guilds.ProcessActionQueue" )

		local count = EHT.Guilds:RestoreGuildMemberNotes()
		if not count or 0 == count then
			d( "|c00ffffFX data has been shared with the selected guilds." )
		end
	end
end

function EHT.Guilds:CleanPreservedGuildMemberNotes()
	local notes = EHT.SavedVars.PreservedGuildNotes

	if notes then
		self:FlushCache()

		local names = { }
		local guilds = self:GetGuilds()

		if guilds then
			for index, guild in pairs( guilds ) do
				if guild.Name then
					names[guild.Name] = true
				end
			end
		end

		for guildName, note in pairs( notes ) do
			if not names[guildName] then
				notes[guildName] = nil
			end
		end
	end
end

function EHT.Guilds:PreserveGuildMemberNotes()
	self:FlushCache()

	local guilds = self:GetGuilds()
	local notes = EHT.SavedVars.PreservedGuildNotes or { }
	EHT.SavedVars.PreservedGuildNotes = notes

	for index, guild in ipairs( guilds ) do
		if guild.Id and guild.Name then
			if not notes[guild.Name] or "" == notes[guild.Name] then
				if guild.Note and string.sub( guild.Note, 1, #EHT.CHATCAST_PREFIX ) ~= EHT.CHATCAST_PREFIX then
					notes[guild.Name] = guild.Note
				end
			end
		end
	end
end

function EHT.Guilds:RestoreGuildMemberNotes()
	local queue = self.ActionQueue

	if queue and 0 < #queue then
		return
	end

	self:FlushCache()

	local guilds = self:GetGuilds()
	local notes = EHT.SavedVars.PreservedGuildNotes
	local count, note = 0, nil

	if notes then
		for index, guild in ipairs( guilds ) do
			if guild.Id and guild.Name then
				note = notes[guild.Name]
				if note and guild.CanEditNotes then
					if guild.Note and note ~= guild.Note and string.sub( guild.Note, 1, #EHT.CHATCAST_PREFIX ) == EHT.CHATCAST_PREFIX then
						table.insert( queue, { GuildId = guild.Id, Note = note, Restored = true } )
						count = count + 1
					else
						notes[guild.Name] = nil
					end
				end
			end
		end
	end

	if 0 < count then
		EVENT_MANAGER:RegisterForUpdate( "EHT.Guilds.ProcessActionQueue", 1000 * self.ProcessIntervalSeconds, EHT.Guilds.ProcessActionQueue )
	end

	return count, count * EHT.Guilds.ProcessIntervalSeconds
end

function EHT.Guilds:SetGuildMemberNote( guildId, note )
	local queue = self.ActionQueue
	local guild = self:GetGuildById( guildId )

	if guild and guild.Id and guild.CanEditNotes then
		table.insert( queue, { GuildId = guild.Id, Note = note } )
		EVENT_MANAGER:RegisterForUpdate( "EHT.Guilds.ProcessActionQueue", 1000 * self.ProcessIntervalSeconds, EHT.Guilds.ProcessActionQueue )
	end
end

function EHT.Guilds:SetGuildMemberNotes( note, updateGuilds )
	updateGuilds = updateGuilds or EHT.SavedVars.EnabledGuildcastGuilds

	if not updateGuilds then
		return
	end

	local queue = self.ActionQueue
	local guilds = self:GetGuilds()
	local count = 0

	for index, guild in ipairs( guilds ) do
		if guild.Id and guild.CanEditNotes and updateGuilds[guild.Name] then
			table.insert( queue, { GuildId = guild.Id, Note = note } )
			count = count + 1
		end
	end

	if 0 ~= count then
		EVENT_MANAGER:RegisterForUpdate( "EHT.Guilds.ProcessActionQueue", 1000 * self.ProcessIntervalSeconds, EHT.Guilds.ProcessActionQueue )
	end

	return count * self.ProcessIntervalSeconds
end

function EHT.Guilds:GetGuildHeraldry( guildId )
	local bkgCategoryIndex, bkgStyleIndex, bkgColor1, bkgColor2, crestCategoryIndex, crestStyleIndex, crestColor = GetGuildHeraldryAttribute( guildId )
	return bkgCategoryIndex, bkgStyleIndex, bkgColor1, bkgColor2, crestCategoryIndex, crestStyleIndex, crestColor
end

function EHT.Guilds:GetHeraldryTextures( bkgCategoryIndex, bkgStyleIndex, bkgColor1, bkgColor2, crestCategoryIndex, crestStyleIndex, crestColor )
	local bkgCategoryTexture = GetHeraldryGuildFinderBackgroundCategoryIcon( bkgCategoryIndex )
	local bkgStyleTexture = GetHeraldryGuildFinderBackgroundStyleIcon( bkgCategoryIndex, bkgStyleIndex )
	local crestTexture = GetHeraldryGuildFinderCrestStyleIcon( crestCategoryIndex, crestStyleIndex )

	local _, dyeCategory, bkgColor1R, bkgColor1G, bkgColor1B, colorSortKey = GetHeraldryColorInfo( bkgColor1 )
	local _, dyeCategory, bkgColor2R, bkgColor2G, bkgColor2B, colorSortKey = GetHeraldryColorInfo( bkgColor2 )
	local _, dyeCategory, crestColorR, crestColorG, crestColorB, colorSortKey = GetHeraldryColorInfo( crestColor )

	local textures = { }

	table.insert( textures, { TextureFile = bkgCategoryTexture, ScaleX = 1, ScaleY = 1, Color = { R = bkgColor1R, G = bkgColor1G, B = bkgColor1B }, SampleRGB = 1, SampleAlpha = 0 } )
	table.insert( textures, { TextureFile = bkgStyleTexture, ScaleX = 0.99, ScaleY = 0.99, Color = { R = bkgColor2R, G = bkgColor2G, B = bkgColor2B }, SampleRGB = 1, SampleAlpha = 0.25, Add = true, } )
	table.insert( textures, { TextureFile = crestTexture, ScaleX = 1, ScaleY = 1, Color = { R = crestColorR, G = crestColorG, B = crestColorB }, SampleRGB = 1, SampleAlpha = 0.25 } )

	return textures
end

---[ Social ]---

-- Singleton
EHT.Social = ZO_Object.New( ZO_Object:Subclass() )

function EHT.Social:GetPlayerNames()
	return self.PlayerNames
end

function EHT.Social:GetSortedPlayers()
	return self.SortedPlayers
end

function EHT.Social:GetRecentlyVisitedPlayers()
	return self.RecentlyVisitedPlayerNames
end

function EHT.Social:GetFriendPlayers()
	return self.FriendPlayerNames
end

function EHT.Social:GetMatchingPlayerNames( partialName, excludeGuildMembers, excludeRecentlyVisited, excludeFriends )
	if "string" ~= type( partialName ) then return end
	partialName = EHT.Util.Trim( string.lower( partialName ) )
	local partialLen = #partialName
	if partialLen < 2 then return end
	local matches

	if not excludeGuildMembers then
		matches = EHT.Guilds:GetMatchingGuildMemberNames( partialName ) or { }
	else
		matches = { }
	end
	
	if not excludeRecentlyVisited then
		local recents = self:GetRecentlyVisitedPlayers()
		for name in pairs( recents ) do
			if string.sub( string.lower( name ), 1, partialLen ) == partialName then
				matches[ name ] = true
			end
		end
	end
	
	if not excludeFriends then
		local friends = self:GetFriendPlayers()
		for name in pairs( friends ) do
			if string.sub( string.lower( name ), 1, partialLen ) == partialName then
				matches[ name ] = true
			end
		end
	end

	local playerNames = self:GetPlayerNames()
	for name in pairs( playerNames ) do
		if string.sub( string.lower( name ), 1, partialLen ) == partialName then
			matches[ name ] = true
		end
	end

	return matches
end

function EHT.Social:IsKnownPlayer( name )
	return self.PlayerNames[ string.lower( name ) ] ~= nil
end

function EHT.Social:Refresh()
	local playerNames = { }
	self.PlayerNames = playerNames

	local sortedPlayers = { }
	self.SortedPlayers = sortedPlayers

	if not EHT.Data.IsHouseListEmpty() then
		for houseKey, house in pairs( EHT.Data.GetHouses() ) do
			if "string" == type( houseKey ) then
				local nameIndex = string.find( houseKey, "@" )
				if nameIndex and nameIndex > 0 then
					local name = string.lower( string.sub( houseKey, nameIndex ) )
					if #name > 1 then
						if not playerNames[ name ] then
							playerNames[ name ] = true
							table.insert( sortedPlayers, name )
						end
					end
				end
			end
		end
	end

	table.sort( sortedPlayers )

	playerNames = { }
	self.RecentlyVisitedPlayerNames = playerNames

	local recentPlayers = EHT.Data.GetRecentlyVisited()
	if "table" == type( recentPlayers ) then
		for index, recentPlayer in ipairs( recentPlayers ) do
			if "table" == type( recentPlayer ) and "string" == type( recentPlayer.Owner ) then
				local playerName = string.lower( EHT.Util.Trim( recentPlayer.Owner ) )
				if playerName ~= "" then
					playerNames[ playerName ] = true
				end
			end
		end
	end
	
	playerNames = { }
	self.FriendPlayerNames = playerNames

	local numFriends = GetNumFriends()
	for friendIndex = 1, numFriends do
		local playerName = string.lower( EHT.Util.Trim( GetFriendInfo( friendIndex ) ) )
		if playerName ~= "" then
			playerNames[ playerName ] = true
		end
	end
end

---[ Worlds ]---

function EHT.Util.IsValidWorldCode( code )
	code = string.lower( code )
	return "na" == code or "eu" == code or "pts" == code
end

do 
	local CurrentWorld

	function EHT.Util.GetWorldCode()
		if not CurrentWorld then
			local world = string.lower( GetWorldName() )

			if not world or "" == world then
				CurrentWorld  = ""
			elseif "na" == string.sub( world, 1, 2 ) then
				CurrentWorld = "na"
			elseif "eu" == string.sub( world, 1, 2 ) then
				CurrentWorld = "eu"
			else
				CurrentWorld = "pts"
			end
		end

		return CurrentWorld
	end
end

---[ Camera ]---

do
	local ZOOM_TICKS = 16
	local ZOOM_INTERVAL = 330
	local ticks = 0

	function EHT.Util.CameraZoom( mode )
		ticks = ZOOM_TICKS

		EVENT_MANAGER:UnregisterForUpdate( "EHT.CameraZoom" )
		EVENT_MANAGER:RegisterForUpdate( "EHT.CameraZoom", ZOOM_INTERVAL, function()
			ticks = ticks - 1

			if 1 == mode or 3 == mode then
				CameraZoomIn()
			elseif 2 == mode or 4 == mode then
				CameraZoomOut()
			end

			if 0 >= ticks then
				if 3 == mode then
					ticks = ZOOM_TICKS
					mode = 2
				elseif 4 == mode then
					ticks = ZOOM_TICKS
					mode = 1
				else
					EVENT_MANAGER:UnregisterForUpdate( "EHT.CameraZoom" )
				end
			end
		end )
	end

	function EHT.Util.CameraZoomIn()
		EHT.Util.CameraZoom( 1 )
	end

	function EHT.Util.CameraZoomOut()
		EHT.Util.CameraZoom( 2 )
	end

	function EHT.Util.CameraZoomInOut()
		EHT.Util.CameraZoom( 3 )
	end

	function EHT.Util.CameraZoomOutIn()
		EHT.Util.CameraZoom( 4 )
	end
end

---[ Text Search ]---

--[[
	-- Text Search usage:

	local search = EHT.TextSearch:New() search:SetFilter( "brown -cow" ) d( search:Match( "brown" ) )
	search:SetFilter( "brown -cow" )

	for _, text in pairs( list ) do
		if search:Match( text ) then
			-- ...
		end
	end
]]--

EHT.TextSearch = ZO_Object:Subclass()

function EHT.TextSearch:New()
	return ZO_Object.New( self )
end

function EHT.TextSearch:SetFilter( filter )
	if not filter then return false end

	filter = string.lower( string.trim( filter ) )
	if "" == filter then return false end

	filter = string.gsub( string.gsub( filter, "\+ +", "\+" ), "\- +", "\-" )

	local terms = { SplitString( " ", filter ) }
	if not terms then return false end

	local includeTerms, excludeTerms = { }, { }
	local term

	for index = 1, #terms do
		term = string.trim( terms[index] )

		if term and "" ~= term then
			if "-" == string.sub( term, 1, 1 ) then
				term = string.sub( term, 2 )
				table.insert( excludeTerms, term )
			elseif "+" == string.sub( 1, 1 ) then
				term = string.sub( term, 2 )
				table.insert( includeTerms, term )
			else
				table.insert( includeTerms, term )
			end
		end
	end

	self.FilterInclude = includeTerms
	self.FilterExclude = excludeTerms
end

function EHT.TextSearch:Match( expression )
	local include, exclude = self.FilterInclude, self.FilterExclude
	if not include or not exclude then return true end

	expression = string.lower( string.trim( expression or "" ) )

	for index = 1, #include do
		if not PlainStringFind( expression, include[index] ) then
			return false
		end
	end

	for index = 1, #exclude do
		if PlainStringFind( expression, exclude[index] ) then
			return false
		end
	end

	return true
end

---[ Date & Time ]---

function EHT.Util.GetDate( ts )
	return math.floor( ( ts or GetTimeStamp() ) / SECONDS_PER_DAY )
end

function EHT.Util.GetDateCalendarDateAndTime( ts )
	local tsDate, tsTime = FormatAchievementLinkTimestamp( ( ts or GetTimeStamp() ) * SECONDS_PER_DAY )
	return tsDate, tsTime
end

function EHT.Util.ConvertDaySpanToSeconds( days )
	return SECONDS_PER_DAY * days
end

function EHT.Util.ConvertHoursToSeconds( ts, hours )
	return ts + SECONDS_PER_HOUR * hours
end

function EHT.Util.ConvertDaysToSeconds( ts, days )
	return ts + SECONDS_PER_DAY * days
end

function EHT.Util.ConvertWeeksToSeconds( ts, weeks )
	return ts + SECONDS_PER_WEEK * weeks
end

function EHT.Util.ConvertYearsToSeconds( ts, years )
	return ts + SECONDS_PER_YEAR * years
end

function EHT.Util.GetTimeDeltaString( startTS, endTS, maxUnits, valueColor, unitColor )
	if not startTS then return "" end
	if not endTS then endTS = GetTimeStamp() end
	valueColor, unitColor = valueColor or "", unitColor or ""

	maxUnits = zo_clamp( maxUnits or 2, 1, 2 )

	local delta = endTS - startTS

	local years = math.floor( delta / SECONDS_PER_YEAR )
	delta = delta - years * SECONDS_PER_YEAR

	local months = math.floor( delta / SECONDS_PER_MONTH )
	delta = delta - months * SECONDS_PER_MONTH

	local weeks = math.floor( delta / SECONDS_PER_WEEK )
	delta = delta - weeks * SECONDS_PER_WEEK

	local days = math.floor( delta / SECONDS_PER_DAY )
	delta = delta - days * SECONDS_PER_DAY

	local hours = math.floor( delta / SECONDS_PER_HOUR )
	delta = delta - hours * SECONDS_PER_HOUR

	local mins = math.floor( delta / 60 )
	delta = delta - mins * 60

	local s1, s2, u1, u2

	if ( not s1 or 1 < maxUnits ) and 0 < years then
		if not s1 then
			s1 = string.format( "%s%d%s year%s", valueColor, years, unitColor, 1 == years and "" or "s" )
			u1 = "years"
		else
			s2 = string.format( "%s%d%s year%s", valueColor, years, unitColor, 1 == years and "" or "s" )
			u2 = "years"
		end
	end

	if ( not s1 or ( 1 < maxUnits and "years" == u1 ) ) and 0 < months then
		if not s1 then
			s1 = string.format( "%s%d%s month%s", valueColor, months, unitColor, 1 == months and "" or "s" )
			u1 = "months"
		else
			s2 = string.format( "%s%d%s month%s", valueColor, months, unitColor, 1 == months and "" or "s" )
			u2 = "months"
		end
	end

	if ( not s1 or ( 1 < maxUnits and "years" == u1 ) ) and 0 < weeks then
		if not s1 then
			s1 = string.format( "%s%d%s week%s", valueColor, weeks, unitColor, 1 == weeks and "" or "s" )
			u1 = "weeks"
		else
			s2 = string.format( "%s%d%s week%s", valueColor, weeks, unitColor, 1 == weeks and "" or "s" )
			u2 = "weeks"
		end
	end

	if ( not s1 or ( 1 < maxUnits and ( "months" == u1 or "weeks" == u1 ) ) ) and 0 < days then
		if not s1 then
			s1 = string.format( "%s%d%s day%s", valueColor, days, unitColor, 1 == days and "" or "s" )
			u1 = "days"
		else
			s2 = string.format( "%s%d%s day%s", valueColor, days, unitColor, 1 == days and "" or "s" )
			u2 = "days"
		end
	end

	if ( not s1 or ( 1 < maxUnits and "days" == u1 ) ) and 0 < hours then
		if not s1 then
			s1 = string.format( "%s%d%s hour%s", valueColor, hours, unitColor, 1 == hours and "" or "s" )
			u1 = "hours"
		else
			s2 = string.format( "%s%d%s hour%s", valueColor, hours, unitColor, 1 == hours and "" or "s" )
			u2 = "hours"
		end
	end

	if ( not s1 or ( 1 < maxUnits and "hours" == u1 ) ) and 0 < mins then
		if not s1 then
			s1 = string.format( "%s%d%s minute%s", valueColor, mins, unitColor, 1 == mins and "" or "s" )
			u1 = "minutes"
		else
			s2 = string.format( "%s%d%s minute%s", valueColor, mins, unitColor, 1 == mins and "" or "s" )
			u2 = "minutes"
		end
	end

	if s1 then
		if s2 then
			return string.format( "%s, %s", s1, s2 )
		else
			return s1
		end
	end

	return ""
end

function EHT.Util.GetRelativeTimeString( startTS, endTS, maxUnits, valueColor, unitColor )
	local s = EHT.Util.GetTimeDeltaString( startTS, endTS, maxUnits, valueColor, unitColor )
	if "" ~= s then
		return s .. " ago"
	else
		return "now"
	end
end

function EHT.Util.GetRelativeAgeString( startTS, endTS, maxUnits, valueColor, unitColor )
	local s = EHT.Util.GetTimeDeltaString( startTS, endTS, maxUnits, valueColor, unitColor )
	if "" ~= s then
		return s .. " old"
	else
		return "new"
	end
end

---[ Item Sets ]---

do
	local ITEM_DISCOVERY_INCREMENT = 100
	local MAX_BATCH_SIZE = 20
	local MAX_INVALID_ITEMS = 5000
	local ITEM_LINK_SUFFIX = string.rep( ":0", 20 )

	local discoveryComplete = false
	local discoverItemId = 1
	local invalidItemCounter = 0
	local itemSets = { }

	function EHT.Util.DiscoverItemSets()
		EVENT_MANAGER:UnregisterForEvent( "EHT.DiscoverItemSets", EVENT_PLAYER_ACTIVATED )
		EVENT_MANAGER:RegisterForUpdate( "EHT.DiscoverItemSetsProcess", 1, EHT.Util.DiscoverItemSetsProcess )
	end

	function EHT.Util.DiscoverItemSetsProcess()
		local batchSize = 0
		while batchSize < MAX_BATCH_SIZE and invalidItemCounter < MAX_INVALID_ITEMS do
			local link = string.format("|H1:item:%d%s", discoverItemId, ITEM_LINK_SUFFIX )
			local hasSet, setName, numBonuses, numEquipped, maxEquipped, setId = GetItemLinkSetInfo( link )

			if hasSet then
				setId = tonumber( setId )
				if setId then
					itemSets[setId] = setName
				end
				invalidItemCounter = 0
			else
				invalidItemCounter = invalidItemCounter + 1
			end

			discoverItemId = discoverItemId + ITEM_DISCOVERY_INCREMENT
			batchSize = batchSize + 1
		end

		if invalidItemCounter >= MAX_INVALID_ITEMS then
			discoveryComplete = true
			EVENT_MANAGER:UnregisterForUpdate( "EHT.DiscoverItemSetsProcess" )
		end
	end
	
	function EHT.Util.GetItemSets()
		return itemSets
	end
	
	function EHT.Util.GetItemSetName( setId )
		return itemSets[setId]
	end
	
	function EHT.Util.GetItemSetIdByName( setName )
		setName = string.lower( setName )
		for itemSetId, itemSetName in pairs( itemSets ) do
			if setName == string.lower( itemSetName ) then
				return itemSetId
			end
		end
		return nil
	end
	
	function EHT.Util.IsItemSetDiscoveryComplete()
		return discoveryComplete
	end

	EVENT_MANAGER:RegisterForEvent( "EHT.DiscoverItemSets", EVENT_PLAYER_ACTIVATED, EHT.Util.DiscoverItemSets )
end

function EHT.Util.DoesItemMeetMasterWritConditions( bag, slot, writInfo )
	-- Match level
	local itemLevel = GetItemLevel( bag, slot )
	if 80 <= itemLevel and 87 >= itemLevel then
		local link = GetItemLink( bag, slot )
		if link and "" ~= link then
			-- Match style
			local styleId = GetItemLinkItemStyle( link )
			if writInfo.styleId == styleId then
				-- Match quality
				local itemQuality = GetItemLinkQuality( link )
				if writInfo.quality == itemQuality then
					-- Match trait
					local traitType = GetItemLinkTraitType( link )
					if writInfo.craftTraitType == traitType then
						-- Match set
						local hasSet, _, _, _, _, setId = GetItemLinkSetInfo( link )
						if hasSet and writInfo.setId == setId then
							-- Match armor or weapon type
							local itemTemplate = EHT.CONST.ITEM_TEMPLATES[writInfo.craftItemTemplateId]
							if itemTemplate then
								local _, _, _, equipType = GetItemLinkInfo( link )
								local armorType = GetItemLinkArmorType( link )
								local weaponType = GetItemLinkWeaponType( link )
								if itemTemplate.weaponType == weaponType or ( itemTemplate.armorType == armorType and itemTemplate.equipType == equipType ) then
									-- Item meets Master Writ criteria
									return true
								end
							end
						end
					end
				end
			end
		end
	end
	-- Item does not meet Master Writ criteria
	return false
end

function EHT.Util.GetMasterWritLinkInfo( itemLink )
	local itemType, itemSpecializedType = GetItemLinkItemType( itemLink )
	if itemSpecializedType ~= SPECIALIZED_ITEMTYPE_MASTER_WRIT then
		return
	end

    local linkParts = { ZO_LinkHandler_ParseLink( itemLink ) }
	local itemId = tonumber( linkParts[4] )
	local craftMaterialId = tonumber( linkParts[11] )
	local craftType = 0
	local craftQuality = tonumber( linkParts[12] )
	local craftSetId = tonumber( linkParts[13] )
	local craftSetName = ""
	local craftTraitType = tonumber( linkParts[14] )
	local craftItemTemplateId = tonumber( linkParts[10] )
	local craftItemLink = ""
	local craftStyleId = tonumber( linkParts[15] )
	local craftStyleName = GetItemStyleName( craftStyleId )

	if 188 == craftMaterialId then
		craftType = CRAFTING_TYPE_BLACKSMITHING
	elseif 190 == craftMaterialId then
		craftType = CRAFTING_TYPE_CLOTHIER
	elseif 192 == craftMaterialId then
		craftType = CRAFTING_TYPE_WOODWORKING
	elseif 194 == craftMaterialId then
		craftType = CRAFTING_TYPE_CLOTHIER
	elseif 255 == craftMaterialId then
		craftType = CRAFTING_TYPE_JEWELRYCRAFTING
	end

	if 0 ~= craftSetId then
		craftSetName = EHT.Util.GetItemSetName( craftSetId ) or ""
	end

	local writInfo =
	{
		craftItemTemplateId = craftItemTemplateId,
		craftItemId = craftItemId,
		craftItemLink = craftItemLink,
		craftTraitType = craftTraitType,
		craftType = craftType,
		itemId = itemId,
		itemLink = itemLink,
		quality = craftQuality,
		setId = craftSetId,
		setName = craftSetName,
		styleId = craftStyleId,
	}
	return writInfo
end

if EHT.IsDev then
	SLASH_COMMANDS[ "/teststationlink" ] = function( link )
		if link and "" ~= link then
			link = EHT.Util.Trim( link )
			df("Testing station for writ: %s", link)
			EHT.TestWritStations = EHT.TestWritStations or { }
			table.insert( EHT.TestWritStations, link )
		end
		EHT.EffectUI.RefreshStationMarkers()
	end
end

function EHT.Util.GetMasterWritSetFilters()
	local setFilters
	local bag = BAG_BACKPACK
	local numSlots = GetBagSize( bag )
	local slotItemMatches = { }

	for slot = 0, numSlots - 1 do
		local link = GetItemLink( bag, slot )
		local writInfo = EHT.Util.GetMasterWritLinkInfo( link )

		if writInfo then
			local craftItemId, craftType, craftSetId, craftSetName = writInfo.craftItemId, writInfo.craftType, writInfo.setId, writInfo.setName
			if craftType and craftType ~= 0 and craftSetName and craftSetName ~= "" then
				local complete = false
				for itemSlot = 0, numSlots - 1 do
					if slot ~= itemSlot and not slotItemMatches[itemSlot] and EHT.Util.DoesItemMeetMasterWritConditions( bag, itemSlot, writInfo ) then
						-- An item has been crafted for this writ so we track the item (to prevent reuse for these checks) and skip this writ.
						slotItemMatches[itemSlot] = writInfo
						complete = true
						break
					end
				end

				if not complete then
					if not setFilters then
						setFilters = { }
					end

					local filter =
					{
						bag = bag,
						slot = slot,
						craftType = craftType,
						itemId = craftItemId,
						link = link,
						name = craftSetName,
						setId = craftSetId,
					}
					table.insert( setFilters, filter )
				end
			end
		end
	end
	
	return setFilters
end

function EHT.Util.GetCurrentQuickslotWheelItemLink()
	local quickslotWheel = INTERACTIVE_WHEEL_MANAGER:GetPreferredWheel(ZO_INTERACTIVE_WHEEL_TYPE_UTILITY)
	if not quickslotWheel then
		return nil
	end

	local hotbarCategory = quickslotWheel:GetHotbarCategory()
	local slot = GetCurrentQuickslot()
	if nil == slot then
		return nil
	end

	local link = GetSlotItemLink( slot, hotbarCategory )
	if link == "" then
		return nil
	end

	return link
end

---[ Camera ]---

function EHT.Util.IsFirstPersonCameraEnabled()
	--local playerX, playerY, playerZ = GetPlayerWorldPositionInHouse()
	--local cameraX, cameraY, cameraZ = EHT.World:GetCameraPosition()
	--return cameraX == playerX and cameraZ == playerZ
	return 0 == EHT.Util.GetCurrentSetting( SETTING_PANEL_CAMERA, CAMERA_SETTING_DISTANCE )
end

function EHT.Util.RestorePreferredCameraMode()
	EHT.Util.RestoreSetting( SETTING_PANEL_CAMERA, CAMERA_SETTING_DISTANCE )
end

function EHT.Util.SetCameraToFirstPerson()
	if not EHT.Util.IsFirstPersonCameraEnabled() then
		EHT.Util.ModifySetting( SETTING_PANEL_CAMERA, CAMERA_SETTING_DISTANCE, 0 )
	end
end

function EHT.Util.SetCameraToThirdPerson()
	EHT.Util.ModifySetting( SETTING_PANEL_CAMERA, CAMERA_SETTING_DISTANCE, 16 )
end

function EHT.Util.MatchUnsheathedCameraPerspectiveToCurrentPerspective()
	local currentSetting = GetSetting( SETTING_PANEL_CAMERA, CAMERA_SETTING_DISTANCE )
	SetSetting( SETTING_PANEL_CAMERA, CAMERA_SETTING_DISTANCE_UNSHEATHED, currentSetting )
end

---[ Item Set Collections ]---

function EHT.Util.PrintItemSetCollectionPieceCompletion()
	local total, unlocked = 0, 0
	for _, piece in ITEM_SET_COLLECTIONS_DATA_MANAGER:ItemSetCollectionPieceIterator() do
		total = total + 1
		if piece:IsUnlocked() then
			unlocked = unlocked + 1
		end
	end
	df( "You have unlocked |cffffff%d|r of |cffffff%d|r (|cffffff%.2f%%|r) total pieces.", unlocked, total, 100 * unlocked / total )
end

---[ Versions ]---

function EHT.Util.ParseVersionString( version )
	version = tostring( version )
	if not version or #version < 5 then
		return
	end

	local sepIndex1 = string.find( version, "[.]" )
	if not sepIndex1 then
		return
	end

	local sepIndex2 = string.find( version, "[.]", sepIndex1 + 1 )
	if not sepIndex2 then
		return
	end

	if sepIndex1 <= 1 or sepIndex1 >= ( sepIndex2 - 1 ) or sepIndex2 >= #version then
		return
	end

	local versionMajor = tonumber( string.sub( version, 1, sepIndex1 - 1 ) )
	local versionMinor = tonumber( string.sub( version, sepIndex1 + 1, sepIndex2 - 1 ) )
	local versionBuild = tonumber( string.sub( version, sepIndex2 + 1 ) )
	if not versionMajor or not versionMinor or not versionBuild then
		return
	end

	local compoundVersion = versionMajor * 1000000 + versionMinor * 1000 + versionBuild
	return compoundVersion, versionMajor, versionMinor, versionBuild
end

---[ Debug ]---

do
	local enabled = true

	function toggledebugf()
		enabled = not enabled
		df( "Function debugging %s.", enabled and "ON" or "OFF" )
	end

	SLASH_COMMANDS[ "/ehtdf" ] = toggledebugf

	function ehtdebug( ns, fName )
		local previousF = ns[fName]

		ns[fName] = function( ... )
			if enabled then
				df( "Debug: %s", fName )
				d( "Arguments:" )
				d( ... )
			end

			local results = { previousF( ... ) }

			if enabled then
				d( "Results:" )
				d( results )
			end

			return unpack( results )
		end
	end

	function ehtdebugs( ns, functions )
		for _, fName in ipairs( functions ) do
			ehtdebug( ns, fName )
		end
	end
end

EHT.Modules = ( EHT.Modules or { } ) EHT.Modules.Utilities = true
