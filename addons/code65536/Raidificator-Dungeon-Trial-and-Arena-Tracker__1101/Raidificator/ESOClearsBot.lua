if (not LibQRCode) then return end

local RCR = Raidificator

RCR.ESOCB = { }
local ESOCB = RCR.ESOCB


--------------------------------------------------------------------------------
-- Stuff from Achievements.lua
--------------------------------------------------------------------------------

local CATEGORY_DUNGEONS = 1
local CATEGORY_TRIALS = 2
local CATEGORY_ARENAS = 3
local CATEGORY_SOLO_DUNGEONS = 4

local CheckFlag, IsAchComplete, GetSelectedServerAndAccount
function ESOCB.Initialize( ... )
	CheckFlag, IsAchComplete, GetSelectedServerAndAccount = ...
end


--------------------------------------------------------------------------------
-- GetAchievementBitmasks
-- The goal here is to recreate the achievement bitmasks used in PAT, using only
-- our own achievement data; a few manual fixes are needed and are marked by FIX
--------------------------------------------------------------------------------

local BITS_PER_BLOCK = 31 -- Looks like they're using signed instead of unsigned

local function SortSelection( a, b )
	if (a[2] ~= b[2]) then
		return a[2] < b[2] -- Primary: by explicit order
	else
		return a[1] < b[1] -- Secondary: by achievementId
	end
end

local function SwapOrder( tbl, i, j )
	local temp = tbl[i]
	tbl[i] = tbl[j]
	tbl[j] = temp
end

function ESOCB.GetAchievementBitmasks( categoryId )
	-- Abort if someone tries to call this without initialization
	if (not CheckFlag) then return end

	if (not ESOCB.bitmasks) then
		local contentLists = {
			[CATEGORY_DUNGEONS] = { },
			[CATEGORY_TRIALS] = { },
			[CATEGORY_ARENAS] = { },
			[CATEGORY_SOLO_DUNGEONS] = { },
		}

		local categoryPrefix = {
			[CATEGORY_DUNGEONS] = 0x64,
			[CATEGORY_TRIALS] = 0x74,
		}

		-- Select the relevant achievement IDs from our own data and put them into the correct order
		for _, entry in ipairs(RCR.GetAchievementData()) do
			if ((entry.category == CATEGORY_DUNGEONS and entry.year >= 2018) or (entry.category == CATEGORY_TRIALS) or (entry.zoneId == 1082)) then
				local selected = { }
				for _, ach in ipairs(entry.achs) do
					local id, flags = ach.id, ach.flags
					if (entry.zoneId == 1565) then
						-- Opulent Ordeal
						if (CheckFlag(flags, "C")) then
							table.insert(selected, { id, 1 })
						elseif (CheckFlag(flags, "N")) then
							table.insert(selected, { id, 2 })
						end
					elseif (CheckFlag(flags, "V")) then
						if (CheckFlag(flags, "C")) then
							-- Veteran clear
							table.insert(selected, { id, 1 })
						elseif (CheckFlag(flags, "F")) then
							-- Final boss hard mode
							table.insert(selected, { id, 3 })
						elseif (entry.category == CATEGORY_TRIALS and CheckFlag(flags, "H")) then
							-- Partial hard modes for trials, sorted before final boss hard mode
							table.insert(selected, { id, 2 })
						elseif (CheckFlag(flags, "T")) then
							-- Trifecta
							table.insert(selected, { id, 5 })
						elseif (CheckFlag(flags, "M")) then
							-- Challenger for dungeons, sorted before trifecta; or Meta for trials, sorted after trifecta
							table.insert(selected, { id, entry.category == CATEGORY_DUNGEONS and 4 or 6 })
						end
					end
				end
				table.sort(selected, SortSelection)
				table.insert(contentLists[entry.category], selected)
			end
		end

		-- FIX: Places where their expected order deviates from the pledge order that we use
		SwapOrder(contentLists[CATEGORY_DUNGEONS], 5, 6) -- Depths of Malatar / Frostvault
		SwapOrder(contentLists[CATEGORY_DUNGEONS], 7, 8) -- Moongrave Fane / Lair of Maarselok
		SwapOrder(contentLists[CATEGORY_DUNGEONS], 27, 28) -- Naj-Caldeesh / Black Gem Foundry

		-- Convert selected achievement IDs into bitmasks
		ESOCB.bitmasks = { }
		ESOCB.debugAchList = { }

		for category, list in pairs(contentLists) do
			if (categoryPrefix[category]) then
				local added = 0
				local results = { }
				local debugList = { }

				local add = function( content )
					for _, ach in ipairs(content) do
						results[ach[1]] = {
							bitmask = BitLShift(1, added % BITS_PER_BLOCK),
							prefix = string.char(categoryPrefix[category], 0x61 + zo_floor(added / BITS_PER_BLOCK)),
						}
						table.insert(debugList, ach[1])
						added = added + 1
					end
				end

				for i, content in ipairs(list) do
					if (category == CATEGORY_DUNGEONS and i == 27) then
						-- FIX: Inject Blackrose Prison into the dungeon list at the expected spot
						add(contentLists[CATEGORY_ARENAS][1])
					end
					add(content)
				end

				ESOCB.bitmasks[category] = results
				ESOCB.debugAchList[category] = debugList
			end
		end
	end

	return ESOCB.bitmasks[categoryId]
end


--------------------------------------------------------------------------------
-- GenerateQRString
--------------------------------------------------------------------------------

local PREAMBLE = "RAT,v5,gf_0"

local SERVER_CODE = {
	["NA"] = 1,
	["EU"] = 2,
	["PTS"] = 7,
}

local PLATFORM_OFFSET = {
	["XB1live"] = 2,
	["XB1live-eu"] = 2,
	["PS4live"] = 4,
	["PS4live-eu"] = 4,
}

-- From PAT
local function Checksum( str )
	local sum = str:byte(1)
	for i = 2, zo_strlen(str) do
		sum = (BitLShift(sum, 5) + str:byte(i)) % 0x80000000
	end
	return sum
end

function ESOCB.GenerateQRString( categoryId )
	local bitmaskData = ESOCB.GetAchievementBitmasks(categoryId)
	if (bitmaskData) then
		local server, account = GetSelectedServerAndAccount()
		local results = {
			PREAMBLE,
			account,
			os.date("%Y%m%d"),
			(SERVER_CODE[server] or -1) + (PLATFORM_OFFSET[GetWorldName()] or 0)
		}

		local chunks = { }
		for achievementId, params in pairs(bitmaskData) do
			if (IsAchComplete(achievementId)) then
				chunks[params.prefix] = BitOr(chunks[params.prefix] or 0, params.bitmask)
			end
		end
		for prefix, data in pairs(chunks) do
			table.insert(results, prefix .. data)
		end

		local joined = table.concat(results, ",")
		return string.format("%s,%s", joined, Checksum(joined))
	end
end


--------------------------------------------------------------------------------
-- DisplayQRCode
--------------------------------------------------------------------------------

function ESOCB.DisplayQRCode( categoryId, control )
	local qrString = ESOCB.GenerateQRString(categoryId)
	if (qrString) then
		LibQRCode.DrawQRCode(control, qrString)
		ESOCB.debugLastCode = qrString
		return true
	else
		return false
	end
end
