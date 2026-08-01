
local function Within(from, to, timestamp)
	if timestamp < from then return false end
	if timestamp > to then return false end

	return true
end

local function GetAlliancesKillsBetween(from, to)
	local server = GetWorldName()
	local campaignId = GetCurrentCampaignId()

	local kills = {
		[ALLIANCE_ALDMERI_DOMINION] = 0,
		[ALLIANCE_EBONHEART_PACT] = 0,
		[ALLIANCE_DAGGERFALL_COVENANT] = 0
	}

	-- for _, killLocation in pairs(self.killLocationsSV[server][campaignId]) do
	-- 	if Within(from, to, killLocation.timestamp) then
	-- 		for alliance = ALLIANCE_ITERATION_BEGIN, ALLIANCE_ITERATION_END do
	-- 			kills[alliance] = kills[alliance] + killLocation.kills[alliance]
	-- 		end
	-- 	end
	-- end

	return kills
end

local function HandleSlashCommand(extra)
	local options = {}
	--extra = extra:lower()

	for word in extra:lower():gmatch('%w+') do table.insert(options, word) end

	local function GetKillsStringBetween(from, to)
		local totalKills = GetAlliancesKillsBetween(0, 9999999999)
		return GetAlliancesKillsFormattedString(totalKills)
	end

	if (options[1] == 'total') then
		SendMessageToChat(string.format('Total kills recorded: %s', GetKillsStringBetween(0, 9999999999)))
	elseif (options[1] == 'fromto') then
		local from = options[2] and tonumber(options[2]) or 0
		local to = options[3] and tonumber(options[3]) or GetTimeStamp()

		local formFrom = GetDateStringFromTimestamp(from)
		local formTo = GetDateStringFromTimestamp(to)

		SendMessageToChat(string.format('Kills recorded from %s to %s: %s', formFrom, formTo,
			GetKillsStringBetween(from, to)))
	elseif (options[1] == 'lastm') then
		local minutes = options[2] and tonumber(options[2]) or 0

		local from = GetTimeStamp()
		local to = from - 60 * minutes

		SendMessageToChat(string.format('Kills recorded per last %s min: %s', minutes, GetKillsStringBetween(from, to)))
	elseif (options[1] == 'since') then
		local to = GetTimeStamp()
		local year, month, day = GetDateElementsFromTimestamp(to)
		year = options[4] or year
		month = options[3] or month
		day = options[2] or day
		local from = GetTimestampForStartOfDate(year, month, day, true)

		local formFrom = GetDateStringFromTimestamp(from)

		SendMessageToChat(string.format('Kills recorded since %s: %s', formFrom, GetKillsStringBetween(from, to)))
	end
end
