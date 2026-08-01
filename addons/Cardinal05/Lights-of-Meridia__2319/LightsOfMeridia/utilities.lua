local LOM = LightsOfMeridia

---[ Math ]---

function LOM.Round( n, d )

	if nil == d then
		return zo_roundToZero( n )
	else
		return zo_roundToNearest( n, 1 / ( 10 ^ d ) )
	end

end

function LOM.Random( minVal, maxVal )

	if maxVal and not minVal then
		return 0 < maxVal and math.random( 0, maxVal ) or 0 > maxVal and math.random( maxVal, 0 ) or 0
	elseif maxVal and minVal then
		return maxVal > minVal and math.random( minVal, maxVal ) or maxVal < minVal and math.random( maxVal, minVal ) or minVal
	elseif not maxVal and minVal then
		return 0 < minVal and math.random( 0, minVal ) or 0 > minVal and math.random( minVal, 0 ) or 0
	else
		return math.random()
	end

end

---[ Strings ]---

function LOM.Trim( s )

	if nil ~= s then
		return s:gsub( "^%s*(.-)%s*$", "%1" )
	else
		return nil
	end

end

---[ Tables ]---

function LOM.ShadowFunction( tbl, funcName, shadowFunc )

	if nil == shadowFunc or "function" ~= type( shadowFunc ) or nil == tbl or "table" ~= type( tbl ) then return false end

	local originalFunc = tbl[ funcName ]
	if nil == originalFunc or "function" ~= type( originalFunc ) then return false end

	local replacementFunc = function( ... )
		return shadowFunc( originalFunc, ... )
	end

	tbl[ funcName ] = replacementFunc

	return true

end

function LOM.CloneTable( obj )

	if type( obj ) ~= 'table' then return obj end

	local tbl = { }
	for k, v in pairs( obj ) do
		tbl[ LOM.CloneTable( k ) ] = LOM.CloneTable( v )
	end

	return tbl

end

function LOM.IsListValue( list, value )

	for _, v in pairs( list ) do
		if value == v then return true end
	end

	return false

end

---[ Units ]---

function LOM.GetUnitPosition( unitTag )

	unitTag = unitTag or "player"
	local _, x, y, z = GetUnitRawWorldPosition( unitTag )
	return x, y, z

end