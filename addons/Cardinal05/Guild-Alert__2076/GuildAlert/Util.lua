local GA = GuildAlert
local EH = GA.EventHandlers
local UI = GA.UI
local Util = GA.Util
local Setup = GA.Setup


local BASE_88 = {
	DIGITS = { },
	VALUES = { },
}

for i = 0, 87 do
	table.insert( BASE_88.DIGITS, string.char( i + 36 ) )
	BASE_88.VALUES[ string.char( i + 36 ) ] = i
end


------[[ Utilities : Math ]]------


-- Add function that identifies a NaN value.
if not math.isnan then
	math.isnan = function( n ) return n ~= n end
end


-- Add function that converts any NaN values into 0 or an optional Default Value.
if not math.unnan then
	math.unnan = function( n, defaultValue ) if n ~= n then return defaultValue or 0 else return n end end
end


if not math.intToBase88 then
	math.intToBase88 = function( n )
		assert( nil ~= n, "Parameter 'n' must be non-null." )
		if type( n ) == "string" then n = tonumber( n ) end
		assert( type( n ) == "number", "Parameter 'n' must be numeric." )

		local s = ""
		local d, sign = 0, 1

		n = math.floor( n )
		if 0 > n then

			n = n * -1
			sign = -1

		end

		repeat

			d = n % 88
			s = BASE_88.DIGITS[ d + 1 ] .. s
			n = math.floor( n / 88 )

		until 0 >= n or 32 < string.len( s )

		if 0 > sign then s = "#" .. s end

		return s
	end
end


if not math.base88ToInt then
	math.base88ToInt = function( s )
		assert( nil ~= s, "Parameter 's' must be non-null." )
		assert( "" ~= s, "Parameter 's' must be non-empty." )

		local d, p, n, v = 0, 0, 0, 0
		local sign = 1

		if string.sub( s, 1, 1 ) == "#" then

			sign = -1
			s = string.sub( s, 2 )

		end

		for i = string.len( s ), 1, -1 do

			v = BASE_88.VALUES[ string.sub( s, i, i ) ]
			assert( nil ~= v, string.format( "Parameter 's' is an invalid Base88 value: '%s'", s ) )
			d = math.pow( 88, p ) * v
			n = n + d
			p = p + 1

		end

		return sign * n
	end
end


------[[ Utilities : Strings ]]------


-- Add function that returns a non-NaN string return value from Id64ToString.
-- Returns optional default value or empty string.
if not string.fromId64 then
	string.fromId64 = function( n, defaultValue )
		if math.isnan( n ) then return defaultValue or "" end
		local s = Id64ToString( n )
		if nil == string.find( s, "nan" ) then return s else return defaultValue or "" end
	end
end


if not string.trim then
	string.trim = function( s ) if nil ~= s then return s:gsub( "^%s*(.-)%s*$", "%1" ) else return nil end end
end


if not string.fromNumber then
	string.fromNumber = function( s, defaultValue )
		local n = defaultValue

		if nil ~= s then
			n = tonumber( s )
			if nil == n then n = defaultValue end
		end

		return n
	end
end
