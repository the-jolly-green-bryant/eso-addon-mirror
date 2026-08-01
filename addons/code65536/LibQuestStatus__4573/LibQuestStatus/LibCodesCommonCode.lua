local NAME = "LibCodesCommonCode"
local VERSION = 35

if (type(_G[NAME]) == "table" and type(_G[NAME].version) == "number" and _G[NAME].version >= VERSION) then return end

local Lib = { version = VERSION }
_G[NAME] = Lib


--------------------------------------------------------------------------------
-- Color conversions
--------------------------------------------------------------------------------

do
	local function i2c( n, pos )
		return BitAnd(BitRShift(n, pos), 0xFF) / 255
	end

	local function c2i( n, pos )
		return BitLShift(BitAnd(n * 255, 0xFF), pos)
	end

	function Lib.Int24ToRGB( rgb )
		return i2c(rgb, 16), i2c(rgb, 8), i2c(rgb, 0)
	end

	function Lib.Int24ToRGBA( rgb )
		return i2c(rgb, 16), i2c(rgb, 8), i2c(rgb, 0), 1
	end

	function Lib.Int32ToRGBA( rgba )
		return i2c(rgba, 24), i2c(rgba, 16), i2c(rgba, 8), i2c(rgba, 0)
	end

	function Lib.RGBToInt24( r, g, b )
		return c2i(r, 16) + c2i(g, 8) + c2i(b, 0)
	end

	function Lib.RGBAToInt32( r, g, b, a )
		return c2i(r, 24) + c2i(g, 16) + c2i(b, 8) + c2i(a, 0)
	end

	function Lib.Int24ToInt32( rgb, a )
		return BitOr(BitLShift(rgb, 8), a or 0xFF)
	end

	function Lib.Int32ToInt24( rgba )
		return BitRShift(rgba, 8)
	end

	local function h2c( p, q, t )
		t = t - zo_floor(t)
		if (t < 1/6) then return p + (q - p) * 6 * t end
		if (t < 1/2) then return q end
		if (t < 2/3) then return p + (q - p) * (2/3 - t) * 6 end
		return p
	end

	function Lib.HSLToRGB( h, s, l, a )
		if (s == 0) then
			return l, l, l, a
		else
			local q = (l < 0.5) and (l * (1 + s)) or (l + s - l * s)
			local p = 2 * l - q
			return h2c(p, q, h + 1/3), h2c(p, q, h), h2c(p, q, h - 1/3), a
		end
	end

	function Lib.Int24ToHSL( rgb )
		return ConvertRGBToHSL(Lib.Int24ToRGB(rgb))
	end

	function Lib.Int32ToHSLA( rgba )
		local r, g, b, a = Lib.Int32ToRGBA(rgba)
		local h, s, l = ConvertRGBToHSL(r, g, b)
		return h, s, l, a
	end
end


--------------------------------------------------------------------------------
-- 6-bit encode/decode
--------------------------------------------------------------------------------

do
	-- In benchmarks, lookup tables are about 25% faster
	local ENCODE = {0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x41,0x42,0x43,0x44,0x45,0x46,0x47,0x48,0x49,0x4A,0x4B,0x4C,0x4D,0x4E,0x4F,0x50,0x51,0x52,0x53,0x54,0x55,0x56,0x57,0x58,0x59,0x5A,0x61,0x62,0x63,0x64,0x65,0x66,0x67,0x68,0x69,0x6A,0x6B,0x6C,0x6D,0x6E,0x6F,0x70,0x71,0x72,0x73,0x74,0x75,0x76,0x77,0x78,0x79,0x7A,0x23,0x25}
	local DECODE = {[0x30]=0,[0x31]=1,[0x32]=2,[0x33]=3,[0x34]=4,[0x35]=5,[0x36]=6,[0x37]=7,[0x38]=8,[0x39]=9,[0x41]=10,[0x42]=11,[0x43]=12,[0x44]=13,[0x45]=14,[0x46]=15,[0x47]=16,[0x48]=17,[0x49]=18,[0x4A]=19,[0x4B]=20,[0x4C]=21,[0x4D]=22,[0x4E]=23,[0x4F]=24,[0x50]=25,[0x51]=26,[0x52]=27,[0x53]=28,[0x54]=29,[0x55]=30,[0x56]=31,[0x57]=32,[0x58]=33,[0x59]=34,[0x5A]=35,[0x61]=36,[0x62]=37,[0x63]=38,[0x64]=39,[0x65]=40,[0x66]=41,[0x67]=42,[0x68]=43,[0x69]=44,[0x6A]=45,[0x6B]=46,[0x6C]=47,[0x6D]=48,[0x6E]=49,[0x6F]=50,[0x70]=51,[0x71]=52,[0x72]=53,[0x73]=54,[0x74]=55,[0x75]=56,[0x76]=57,[0x77]=58,[0x78]=59,[0x79]=60,[0x7A]=61,[0x23]=62,[0x25]=63}

	-- Defined here to avoid repeated creation costs
	local buffer = { }

	function Lib.Encode( number, size )
		-- Values for size:
		-- 0: Pad result to an even number of bytes (the number 0 will encode to an empty string)
		-- n: Pad result to a minimum length of n bytes
		-- nil: Do not pad results (the number 0 will encode to an empty string)

		local i = 1

		while (number > 0) do
			i = i - 1
			buffer[i] = ENCODE[number % 0x40 + 1]
			number = zo_floor(number / 0x40)
		end

		-- Pad result as necessary
		if (size == 0) then
			if (-i % 2 == 0) then
				i = i - 1
				buffer[i] = 0x30
			end
		elseif (size and size > 1 - i) then
			local start = 1 - size
			for j = start, i - 1 do
				buffer[j] = 0x30
			end
			i = start
		end

		return string.char(unpack(buffer, i))
	end

	function Lib.Decode( code )
		local result = 0

		for i = 1, zo_strlen(code) do
			local n = DECODE[string.byte(code, i)]
			if (not n) then return 0 end
			result = result * 0x40 + n
		end

		return result
	end

	function Lib.ReadAndDecode( encoded, pos, bytes )
		if (bytes == 1) then
			return DECODE[string.byte(encoded, pos)] or 0, pos + 1
		else
			local newPos = pos + bytes
			return Lib.Decode(zo_strsub(encoded, pos, newPos - 1)), newPos
		end
	end

	function Lib.ReadBitFromEncodedData( data, pos, bitsPerLine )
		-- The byte position is little-endian (lower index is in the lower-order
		-- byte), but within each byte, it is big-endian (lower index is in the
		-- higher-order bit).

		if (pos > 0) then
			pos = pos - 1
			if (type(data) == "table") then
				data = data[zo_floor(pos / bitsPerLine) + 1]
				pos = pos % bitsPerLine
			end
			if (type(data) == "string") then
				return BitRShift(DECODE[string.byte(data, zo_floor(pos / 6) + 1)] or 0, 5 - pos % 6) % 2 == 1
			end
		end

		return false
	end
end


--------------------------------------------------------------------------------
-- Consolidator for 6-bit encoded data
--------------------------------------------------------------------------------

do
	-- 12th bit (0x800) is a flag
	-- Lower 11 bits encode the length, for a maximum of 0x7FF

	local function consolidate( str, char, flag )
		local result = string.gsub(str, string.format("(%s+)", string.rep(char, 4)), function( capture )
			local length = zo_strlen(capture)
			if (length <= 0x7FF) then
				return "~" .. Lib.Encode(0x800 * flag + length, 2)
			else
				local encoded = ""
				repeat
					local chunk = (length <= 0x7FF) and length or 0x7FF
					encoded = encoded .. "~" .. Lib.Encode(0x800 * flag + chunk, 2)
					length = length - chunk
				until length <= 0
				return encoded
			end
		end)
		return result
	end

	function Lib.Implode( str )
		return consolidate(consolidate(str, "0", 0), "%%", 1)
	end

	function Lib.Explode( str )
		local result = string.gsub(str, "~(..)", function( capture )
			local code = Lib.Decode(capture)
			return string.rep((BitRShift(code, 11) == 0) and "0" or "%", BitAnd(code, 0x7FF))
		end)
		return result
	end
end


--------------------------------------------------------------------------------
-- String chunk/unchunk
-- Accommodation for the 2000-byte limit for strings in saved variables
--------------------------------------------------------------------------------

do
	local DEFAULT_CHUNK_SIZE = 0x600

	function Lib.Chunk( str, chunkSize )
		if (type(chunkSize) ~= "number") then
			chunkSize = DEFAULT_CHUNK_SIZE
		end

		local length = zo_strlen(str)
		if (length <= chunkSize) then
			return str
		else
			local result = { }
			local i, j = 1
			while (i <= length) do
				j = i + chunkSize
				table.insert(result, zo_strsub(str, i, j - 1))
				i = j
			end
			return result
		end
	end

	function Lib.Unchunk( chunked )
		if (type(chunked) == "string") then
			return chunked
		elseif (type(chunked) == "table") then
			return table.concat(chunked, "")
		else
			return ""
		end
	end
end


--------------------------------------------------------------------------------
-- Concise server name
--------------------------------------------------------------------------------

do
	local SERVERS = {
		["NA Megaserver"] = "NA",
		["EU Megaserver"] = "EU",
		["XB1live"] = "NA",
		["XB1live-eu"] = "EU",
		["PS4live"] = "NA",
		["PS4live-eu"] = "EU",
	}

	local name = GetWorldName()
	name = SERVERS[name] or name

	function Lib.GetServerName( )
		return name
	end
end


--------------------------------------------------------------------------------
-- Wrapper for initial EVENT_PLAYER_ACTIVATED
--------------------------------------------------------------------------------

do
	local id = 0

	function Lib.RunAfterInitialLoadscreen( func )
		id = id + 1
		EVENT_MANAGER:RegisterForEvent(string.format("%s%d_%d", NAME, VERSION, id), EVENT_PLAYER_ACTIVATED, func, true)
	end
end


--------------------------------------------------------------------------------
-- Zone functions
--------------------------------------------------------------------------------

do
	local name = string.format("%s%d_ZoneChange", NAME, VERSION)
	local callbacks = { }
	local registered = false
	local zoneId, difficulty

	local function onPlayerActivated( )
		local previousZoneId = zoneId
		local currentZoneId = Lib.GetZoneId()
		local currentDifficulty = GetCurrentZoneDungeonDifficulty()

		if (zoneId ~= currentZoneId or difficulty ~= currentDifficulty) then
			zoneId = currentZoneId
			difficulty = currentDifficulty
			for _ , callback in pairs(callbacks) do
				callback(currentZoneId, previousZoneId or 0)
			end
		end
	end

	-- Omit the callback parameter to unregister
	function Lib.MonitorZoneChanges( id, callback )
		callbacks[id] = callback
		if (not registered and next(callbacks)) then
			registered = true
			EVENT_MANAGER:RegisterForEvent(name, EVENT_PLAYER_ACTIVATED, onPlayerActivated)
		end
	end

	function Lib.GetZoneId( )
		return GetZoneId(GetUnitZoneIndex("player"))
	end

	function Lib.GetZoneName( zoneId, useFallback )
		local name = GetZoneNameById(zoneId)
		if (useFallback and name == "") then
			return string.format("[#%d]", zoneId)
		else
			return zo_strformat(SI_ZONE_NAME, name)
		end
	end

	local DTA_WHITELIST = {
		[1562] = true, -- Gossamer Crypt
		[1563] = true, -- Mournful Catacomb
		[1564] = true, -- Timeless Wallow
		[1565] = true, -- Opulent Ordeal
	}

	function Lib.IsInDungeonTrialArena( )
		return GetCurrentZoneDungeonDifficulty() ~= DUNGEON_DIFFICULTY_NONE or DTA_WHITELIST[Lib.GetZoneId()] == true
	end
end


--------------------------------------------------------------------------------
-- Slash command helpers
--------------------------------------------------------------------------------

function Lib.RegisterSlashCommands( func, ... )
	for _, command in ipairs({ ... }) do
		SLASH_COMMANDS[command] = func
	end
	return func
end

function Lib.TokenizeSlashCommandParameters( params )
	local tokens = { }
	if (type(params) == "string") then
		for _, token in ipairs({ zo_strsplit(" ", zo_strlower(params)) }) do
			tokens[token] = true
		end
	end
	return tokens
end


--------------------------------------------------------------------------------
-- Compare character IDs
-- The built-in comparison overflows when converting numeric strings
--------------------------------------------------------------------------------

do
	local function split( charId )
		local length = zo_strlen(charId)
		return zo_strsub(charId, 1, length - 8) .. "_" .. zo_strsub(charId, length - 9, length)
	end

	function Lib.CompareCharIds( a, b )
		return split(a) < split(b)
	end
end


--------------------------------------------------------------------------------
-- Table functions
--------------------------------------------------------------------------------

function Lib.GetSortedKeys( tbl, first, compare )
	local keys = { }
	for key in pairs(tbl) do
		table.insert(keys, key)
	end
	table.sort(keys, function( a, b )
		if (a == first) then
			return true
		elseif (b == first) then
			return false
		elseif (compare) then
			return compare(a, b)
		else
			return a < b
		end
	end)
	return keys
end

function Lib.CountTable( tbl )
	local count = 0
	for _ in pairs(tbl) do
		count = count + 1
	end
	return count
end

function Lib.ProcessNumericTable( tbl, func, ... )
	local index = 0
	local prev = 0
	for _, i in ipairs(tbl) do
		local isNumber = type(i) == "number"
		if (isNumber and i < 0) then
			for j = prev + 1, -i do
				index = index + 1
				func(j, index, ...)
			end
		else
			index = index + 1
			func(i, index, ...)
			if (isNumber) then
				prev = i
			end
		end
	end
end

function Lib.MergeTables( dest, src, overwrite )
	if (type(dest) ~= "table") then
		dest = { }
	end
	for k, v in pairs(src) do
		if (overwrite == 2 or dest[k] == nil) then
			if (type(v) == "table") then
				dest[k] = Lib.MergeTables(dest[k], v, overwrite)
			else
				dest[k] = v
			end
		elseif (overwrite == 1 and type(dest[k]) == "table" and type(v) == "table") then
			Lib.MergeTables(dest[k], v, overwrite)
		end
	end
	return dest
end

function Lib.ConcatTables( dest, src )
	for _, v in ipairs(src) do
		table.insert(dest, v)
	end
	return dest
end


--------------------------------------------------------------------------------
-- Convert number-like strings to numbers
--------------------------------------------------------------------------------

function Lib.FixNumber( a )
	if (type(a) == "string" and string.find(a, "^[+-]?[%.%d]*%d$")) then
		return tonumber(a)
	else
		return a
	end
end


--------------------------------------------------------------------------------
-- Are two strings identical, ignoring case and formatting flags?
--------------------------------------------------------------------------------

function Lib.MatchStrings( a, b )
	return zo_strformat("<<z:1>>", a) == zo_strformat("<<z:1>>", b)
end


--------------------------------------------------------------------------------
-- Localization functions
--------------------------------------------------------------------------------

function Lib.RegisterString( id, text, version )
	if (_G[id]) then
		SafeAddString(_G[id], text, version or 1)
	else
		ZO_CreateStringId(id, text)
		if (version) then
			SafeAddVersion(_G[id], version)
		end
	end
end

do
	local LANG = GetCVar("Language.2")

	function Lib.GetLocalizedData( data )
		if (type(data) == "table") then
			return data[LANG] or data.default
		end
	end
end


--------------------------------------------------------------------------------
-- Get a list of group members that is sorted by role and name
--------------------------------------------------------------------------------

do
	local ROLE_ORDER = {
		[LFG_ROLE_TANK] = 1,
		[LFG_ROLE_HEAL] = 2,
		[LFG_ROLE_DPS] = 3,
		[LFG_ROLE_INVALID] = 4,
	}

	local function compare( a, b )
		local ra = ROLE_ORDER[a.role]
		local rb = ROLE_ORDER[b.role]
		if (ra == rb) then
			return a.account < b.account
		else
			return ra < rb
		end
	end

	function Lib.GetSortedGroupMembers( )
		local groupSize = GetGroupSize()

		if (groupSize > 0) then
			local units = { }

			for i = 1, groupSize do
				local unitTag = GetGroupUnitTagByIndex(i)
				if (unitTag) then
					table.insert(units, {
						unitTag = unitTag,
						account = GetUnitDisplayName(unitTag),
						name = GetUnitName(unitTag),
						role = GetGroupMemberSelectedRole(unitTag),
						class = GetUnitClassId(unitTag),
					})
				end
			end

			table.sort(units, compare)
			return units
		else
			-- Ungrouped
			return { {
				unitTag = "player",
				account = GetDisplayName(),
				name = GetUnitName("player"),
				role = GetSelectedLFGRole(),
				class = GetUnitClassId("player"),
			} }
		end
	end
end


--------------------------------------------------------------------------------
-- Versioning
--------------------------------------------------------------------------------

function Lib.GetAddOnVersion( name )
	local am = GetAddOnManager()
	for i = 1, am:GetNumAddOns() do
		if (am:GetAddOnInfo(i) == name) then
			return am:GetAddOnVersion(i)
		end
	end
	return nil
end

function Lib.FormatVersion( version )
	local fields = { }
	if (type(version) == "number") then
		for i, base in ipairs({ 10, 100, 100, 10000 }) do
			fields[5 - i] = version % base
			version = zo_floor(version / base)
		end
		if (fields[4] == 0) then
			fields[4] = nil
		end
	end
	return table.concat(fields, ".")
end


--------------------------------------------------------------------------------
-- Link handling
--------------------------------------------------------------------------------

do
	local callbacks = { }
	local registered = false

	local function linkClicked( _, _, _, _, tag, ... )
		if (type(tag) == "string" and callbacks[tag]) then
			callbacks[tag](...)
			return true
		end
	end

	-- Omit the callback parameter to unregister
	function Lib.RegisterLinkHandler( tag, callback )
		callbacks[tag] = callback
		if (not registered and next(callbacks)) then
			registered = true
			LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, linkClicked)
			LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT, linkClicked)
		end
	end
end


--------------------------------------------------------------------------------
-- LibAddonMenu wrapper
-- A safeguard to avoid old un-manifested copies
--------------------------------------------------------------------------------

function Lib.GetLibAddonMenu( )
	if (LibStub and not ZO_IsConsoleOrGameCoreUI()) then
		local version = select(2, LibStub("LibAddonMenu-2.0", true))
		if (version and version < 36) then
			return nil
		end
	end
	return LibAddonMenu2
end


--------------------------------------------------------------------------------
-- Deprecated
--------------------------------------------------------------------------------

Lib.Clamp = zo_clamp
