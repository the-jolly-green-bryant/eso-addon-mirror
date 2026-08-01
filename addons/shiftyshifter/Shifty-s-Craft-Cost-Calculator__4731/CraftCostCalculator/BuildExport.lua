--[[
	BuildExport
	Decode / validate versioned CCC build export strings.

	Wire format: CCC<version>:<base64url(json)>
	v1 payload keys are short (n, g, sl, …) — see web exporter.

	This module knows nothing about UI or craft cost.
]]

CraftCostCalculator = CraftCostCalculator or {}
local CCC = CraftCostCalculator

CCC.BuildExport = CCC.BuildExport or {}
local BE = CCC.BuildExport

local B64_ALPHABET =
	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local b64Lookup

local function ensureB64Lookup()
	if b64Lookup then
		return
	end
	b64Lookup = {}
	for i = 1, #B64_ALPHABET do
		b64Lookup[B64_ALPHABET:sub(i, i)] = i - 1
	end
	-- URL-safe variants
	b64Lookup["-"] = b64Lookup["+"]
	b64Lookup["_"] = b64Lookup["/"]
end

--- Decode standard or URL-safe Base64 into a binary string.
-- Processes 4 characters at a time so Lua doubles never lose integer precision
-- on long CCC exports (unbounded accumulators break after ~a few dozen chars).
function BE:DecodeBase64(input)
	if not input or input == "" then
		return nil, "Empty Base64 payload."
	end
	ensureB64Lookup()

	local cleaned = input:gsub("%s+", ""):gsub("-", "+"):gsub("_", "/")
	local pad = (4 - (#cleaned % 4)) % 4
	if pad > 0 then
		cleaned = cleaned .. string.rep("=", pad)
	end

	if (#cleaned % 4) ~= 0 then
		return nil, "Invalid Base64 length in CCC export."
	end

	local out = {}
	for i = 1, #cleaned, 4 do
		local c1 = cleaned:sub(i, i)
		local c2 = cleaned:sub(i + 1, i + 1)
		local c3 = cleaned:sub(i + 2, i + 2)
		local c4 = cleaned:sub(i + 3, i + 3)

		local v1 = b64Lookup[c1]
		local v2 = b64Lookup[c2]
		if not v1 or not v2 then
			return nil, "Invalid Base64 character in CCC export."
		end

		local v3 = 0
		local v4 = 0
		if c3 ~= "=" then
			v3 = b64Lookup[c3]
			if not v3 then
				return nil, "Invalid Base64 character in CCC export."
			end
		end
		if c4 ~= "=" then
			v4 = b64Lookup[c4]
			if not v4 then
				return nil, "Invalid Base64 character in CCC export."
			end
		end

		local n = v1 * 262144 + v2 * 4096 + v3 * 64 + v4 -- 2^18, 2^12, 2^6
		out[#out + 1] = string.char(math.floor(n / 65536) % 256)
		if c3 ~= "=" then
			out[#out + 1] = string.char(math.floor(n / 256) % 256)
		end
		if c4 ~= "=" then
			out[#out + 1] = string.char(n % 256)
		end
	end

	return table.concat(out)
end

---------------------------------------------------------------------------
-- Minimal JSON decoder (objects / arrays / strings / numbers / bool / null)
---------------------------------------------------------------------------

local function skipWs(str, i)
	local _, j = str:find("^[ \t\r\n]*", i)
	return (j or i - 1) + 1
end

local function parseString(str, i)
	if str:sub(i, i) ~= '"' then
		return nil, i, "Expected string."
	end
	i = i + 1
	local parts = {}
	while i <= #str do
		local ch = str:sub(i, i)
		if ch == '"' then
			return table.concat(parts), i + 1
		elseif ch == "\\" then
			local esc = str:sub(i + 1, i + 1)
			local map = {
				['"'] = '"',
				["\\"] = "\\",
				["/"] = "/",
				b = "\b",
				f = "\f",
				n = "\n",
				r = "\r",
				t = "\t",
			}
			if esc == "u" then
				local hex = str:sub(i + 2, i + 5)
				if not hex:match("^[0-9a-fA-F]+$") or #hex < 4 then
					return nil, i, "Invalid unicode escape."
				end
				local code = tonumber(hex, 16)
				-- BMP only (good enough for set / trait names)
				if code < 128 then
					parts[#parts + 1] = string.char(code)
				elseif code < 2048 then
					parts[#parts + 1] = string.char(0xC0 + math.floor(code / 64), 0x80 + (code % 64))
				else
					parts[#parts + 1] = string.char(
						0xE0 + math.floor(code / 4096),
						0x80 + (math.floor(code / 64) % 64),
						0x80 + (code % 64)
					)
				end
				i = i + 6
			elseif map[esc] then
				parts[#parts + 1] = map[esc]
				i = i + 2
			else
				return nil, i, "Invalid escape sequence."
			end
		else
			parts[#parts + 1] = ch
			i = i + 1
		end
	end
	return nil, i, "Unterminated string."
end

local parseValue

local function parseNumber(str, i)
	local s, e = str:find("^-?%d+%.?%d*[eE]?[+-]?%d*", i)
	if not s then
		return nil, i, "Invalid number."
	end
	local num = tonumber(str:sub(s, e))
	if not num then
		return nil, i, "Invalid number."
	end
	return num, e + 1
end

local function parseArray(str, i)
	i = i + 1 -- skip [
	local arr = {}
	i = skipWs(str, i)
	if str:sub(i, i) == "]" then
		return arr, i + 1
	end
	while true do
		local val, ni, err = parseValue(str, i)
		if err then
			return nil, ni, err
		end
		arr[#arr + 1] = val
		i = skipWs(str, ni)
		local ch = str:sub(i, i)
		if ch == "]" then
			return arr, i + 1
		elseif ch == "," then
			i = skipWs(str, i + 1)
		else
			return nil, i, "Expected ',' or ']' in array."
		end
	end
end

local function parseObject(str, i)
	i = i + 1 -- skip {
	local obj = {}
	i = skipWs(str, i)
	if str:sub(i, i) == "}" then
		return obj, i + 1
	end
	while true do
		local key, ni, err = parseString(str, i)
		if err then
			return nil, ni, err
		end
		i = skipWs(str, ni)
		if str:sub(i, i) ~= ":" then
			return nil, i, "Expected ':' after object key."
		end
		i = skipWs(str, i + 1)
		local val
		val, ni, err = parseValue(str, i)
		if err then
			return nil, ni, err
		end
		obj[key] = val
		i = skipWs(str, ni)
		local ch = str:sub(i, i)
		if ch == "}" then
			return obj, i + 1
		elseif ch == "," then
			i = skipWs(str, i + 1)
		else
			return nil, i, "Expected ',' or '}' in object."
		end
	end
end

parseValue = function(str, i)
	i = skipWs(str, i)
	local ch = str:sub(i, i)
	if ch == '"' then
		return parseString(str, i)
	elseif ch == "{" then
		return parseObject(str, i)
	elseif ch == "[" then
		return parseArray(str, i)
	elseif ch == "t" and str:sub(i, i + 3) == "true" then
		return true, i + 4
	elseif ch == "f" and str:sub(i, i + 4) == "false" then
		return false, i + 5
	elseif ch == "n" and str:sub(i, i + 3) == "null" then
		return nil, i + 4
	elseif ch == "-" or ch:match("%d") then
		return parseNumber(str, i)
	end
	return nil, i, "Unexpected JSON token."
end

function BE:DecodeJson(json)
	if not json or json == "" then
		return nil, "Empty JSON payload."
	end
	local value, i, err = parseValue(json, 1)
	if err then
		return nil, err
	end
	i = skipWs(json, i)
	if i <= #json then
		return nil, "Trailing data after JSON payload."
	end
	return value
end

---------------------------------------------------------------------------
-- Versioned payload validation
---------------------------------------------------------------------------

local VALID_SLOTS = {
	head = true,
	shoulders = true,
	chest = true,
	hands = true,
	belt = true,
	legs = true,
	feet = true,
	neck = true,
	ring1 = true,
	ring2 = true,
	mainHand = true,
	offHand = true,
	backupMainHand = true,
	backupOffHand = true,
}

local function validatePieceV1(piece, index)
	if type(piece) ~= "table" then
		return nil, string.format("Gear piece #%d is invalid.", index)
	end
	if type(piece.sl) ~= "string" or piece.sl == "" then
		return nil, string.format("Gear piece #%d is missing a slot.", index)
	end
	if not VALID_SLOTS[piece.sl] then
		return nil, string.format("Gear piece #%d has an unknown slot '%s'.", index, tostring(piece.sl))
	end
	return true
end

local function normalizePayloadV1(payload)
	if type(payload.g) ~= "table" or #payload.g == 0 then
		return nil, "Export contains no gear pieces."
	end

	local pieces = {}
	for i = 1, #payload.g do
		local ok, err = validatePieceV1(payload.g[i], i)
		if not ok then
			return nil, err
		end
		local raw = payload.g[i]
		pieces[#pieces + 1] = {
			slot = raw.sl,
			setName = type(raw.set) == "string" and raw.set or nil,
			armorWeight = type(raw.w) == "string" and raw.w or nil,
			weaponType = type(raw.wt) == "string" and raw.wt or nil,
			isJewelry = raw.j == 1 or raw.j == true,
			trait = type(raw.t) == "string" and raw.t or nil,
			enchantment = type(raw.e) == "string" and raw.e or nil,
			quality = type(raw.q) == "number" and raw.q or nil,
			style = type(raw.st) == "string" and raw.st or nil,
			level = type(raw.lv) == "number" and raw.lv or nil,
			isChampionPoint = raw.cp == 1 or raw.cp == true,
		}
	end

	return {
		version = 1,
		name = (type(payload.n) == "string" and payload.n ~= "" and payload.n) or "Imported Build",
		providerId = type(payload.p) == "string" and payload.p or nil,
		url = type(payload.u) == "string" and payload.u or nil,
		setupName = type(payload.sn) == "string" and payload.sn or nil,
		pieces = pieces,
	}
end

--- Parse a full CCC export string into a normalized build table.
-- @return build|nil, errorMessage|nil
function BE:Decode(exportString)
	if type(exportString) ~= "string" then
		return nil, "Paste a CCC Build Export string first."
	end

	local trimmed = zo_strtrim(exportString)
	if trimmed == "" then
		return nil, "Paste a CCC Build Export string first."
	end

	local versionStr, payloadEncoded = trimmed:match("^CCC(%d+):(.+)$")
	if not versionStr or not payloadEncoded then
		return nil, "Invalid format. Expected CCC1:… export string."
	end

	local version = tonumber(versionStr)
	if not version then
		return nil, "Invalid CCC export version."
	end

	local binary, b64Err = BE:DecodeBase64(payloadEncoded)
	if not binary then
		return nil, b64Err or "Could not decode Base64 payload."
	end

	local payload, jsonErr = BE:DecodeJson(binary)
	if not payload then
		return nil, jsonErr or "Could not parse export JSON."
	end

	if type(payload) ~= "table" then
		return nil, "Export payload must be a JSON object."
	end

	local declared = payload.v or version
	if declared == 1 or version == 1 then
		return normalizePayloadV1(payload)
	end

	-- Forward-compatible: unknown future versions fail clearly for now.
	return nil, string.format(
		"CCC export version %d is not supported by this addon yet. Update Shifty's Craft Cost Calculator.",
		declared
	)
end

function BE:Init(addon)
	BE.addon = addon
end
