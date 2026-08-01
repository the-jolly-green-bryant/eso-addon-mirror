LibUndauntedPledges = {
	-- Pledge givers
	BASE1 = 1,
	BASE2 = 2,
	DLC1 = 3,

	-- ID types
	TYPE_ZONE = 1,
	TYPE_QUEST = 2,
	TYPE_ACTIVITY = 3,
}
local LUP = LibUndauntedPledges

local SECONDS_PER_DAY = 86400
local NA_EU_DIFFERENCE = 25200 -- 7 hours

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

	function LUP.GetCurrentServer( )
		return name
	end
end
local SERVER = LUP.GetCurrentServer()

local function GetTimeToNextReset( server )
	local offset = 0
	if (SERVER == "EU" and (server == "NA" or server == "PTS")) then
		offset = NA_EU_DIFFERENCE
	elseif (server == "EU" and (SERVER == "NA" or SERVER == "PTS")) then
		offset = -NA_EU_DIFFERENCE
	end
	return (GetTimeUntilNextDailyLoginRewardClaimS() + offset) % SECONDS_PER_DAY
end

function LUP.GetCurrentServerDate( server )
	local date = os.date("!*t", GetTimeStamp() + GetTimeToNextReset(server) - SECONDS_PER_DAY)
	return date.year, date.month, date.day
end

function LUP.GetPledgeGiverName( pledgeGiverId )
	return LUP.NAMES[pledgeGiverId or 0] or ""
end

function LUP.GetPledgeCount( pledgeGiverId )
	local dungeons = LUP.IDS[pledgeGiverId or 0]
	return dungeons and #dungeons or 0
end

function LUP.LookupIds( suppliedId, suppliedIdType )
	suppliedId = tonumber(suppliedId)
	suppliedIdType = tonumber(suppliedIdType)

	if (suppliedId and suppliedIdType) then
		for _, dungeons in pairs(LUP.IDS) do
			for _, dungeon in ipairs(dungeons) do
				if (suppliedId == dungeon[suppliedIdType] or (suppliedId == dungeon[4] and suppliedIdType == LUP.TYPE_ACTIVITY)) then
					return unpack(dungeon)
				end
			end
		end
	end

	return 0, 0, 0, 0
end

function LUP.GetPledges( ... )
	local year, month, day = ...
	local offsetDays, server = ...

	local t = (type(year) == "number" and type(month) == "number" and type(day) == "number") and
		GetTimestampForStartOfDate(year, month, day, false) or
		GetTimestampForStartOfDate(LUP.GetCurrentServerDate(server)) + SECONDS_PER_DAY * (offsetDays or 0)
	local days = (t - LUP.CYCLE_START.timestamp) / SECONDS_PER_DAY
	local date = os.date("!*t", t)
	local wdayLong, wdayShort = zo_strsplit(";", os.date("!%A;%a", t))

	local results = {
		date = {
			year = date.year, month = date.month, day = date.day,
			wday = date.wday, wdayLong = wdayLong, wdayShort = wdayShort,
		},
	}

	for _, pgId in ipairs({ LUP.BASE1, LUP.BASE2, LUP.DLC1 }) do
		local dungeons = LUP.IDS[pgId]
		local dungeon = dungeons[1 + ((days + LUP.CYCLE_START[pgId]) % #dungeons)]
		results[pgId] = {
			pledgeGiverName = LUP.GetPledgeGiverName(pgId),
			name = zo_strformat(SI_ZONE_NAME, GetZoneNameById(dungeon[1])),
			zoneId = dungeon[1],
			questId = dungeon[2],
			activityIdN = dungeon[3],
			activityIdV = dungeon[4],
		}
	end

	return results
end

function LUP.IsPledge( id, ... )
	-- Translate id
	local zoneId, questId, activityId
	if (type(id) == "number") then
		zoneId = id
	elseif (type(id) == "table") then
		if (id[2] == LUP.TYPE_ZONE) then
			zoneId = tonumber(id[1])
		elseif (id[2] == LUP.TYPE_QUEST) then
			questId = tonumber(id[1])
		elseif (id[2] == LUP.TYPE_ACTIVITY) then
			activityId = tonumber(id[1])
		end
	end

	-- Match against pledges
	if (zoneId or questId or activityId) then
		local pledges = LUP.GetPledges(...)
		for _, key in ipairs({ LUP.BASE1, LUP.BASE2, LUP.DLC1 }) do
			local p = pledges[key]
			if (p.zoneId == zoneId or p.questId == questId or p.activityIdN == activityId or p.activityIdV == activityId) then
				return true
			end
		end
	end

	return false
end
