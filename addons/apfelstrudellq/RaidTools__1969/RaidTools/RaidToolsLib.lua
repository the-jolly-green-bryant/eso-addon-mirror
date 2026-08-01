function RaidTools.parse_game_version(s)
	local s = (s or GetESOVersionString())
	local is_pts, major, minor, release, build, version
	is_pts = string.match(s, "eso%.(.-)%.") == 'pts'
	major = string.match(s, "%a+%.(.)%.")
	minor = string.match(s, major.."%.(.-)%.")
	release = string.match(s, major..'%.'..minor.."%.(.-)%.")
	build = string.match(s, major..'%.'..minor..'%.'..release.."%.(%d+)")
	version = {
		is_pts = is_pts,
		major = major,
		minor = minor,
		release = release,
		build = build
	}
	return version
end

function RaidTools.is_game_up_to_date()
	current_version = RaidTools.parse_game_version()
	if current_version.is_pts then
		RaidTools.BrandedMessage('>>> PTS-MODE <<<')
		RaidTools.Message('Leaderboard information will not be resetted!')
		return
	end
	saved_version = RaidTools.parse_game_version(RaidTools.storage.game_version_string)

	if (current_version.major > saved_version.major) or (current_version.minor > saved_version.minor) then
		RaidTools.BrandedMessage('Version change detected. Assuming leaderboards were wiped, history will be cleared.')
		RaidTools.storage.raid_history = {}
	end
	RaidTools.storage.game_version_string = GetESOVersionString()
end

--
-- Functions:Override
--

RaidTools.BeginGroupElection = BeginGroupElection
function BeginGroupElection(electionType, electionDescriptor, targetUnitTag, not_funny)
	if not IsPlayerInGroup(GetUnitName('player')) then CHAT_SYSTEM:AddMessage('You are not in a group.') return end
	local message = 'Are you ready?'
	if not not_funny and (RaidTools.storage and RaidTools.storage.config.random_ready_checks) then
		message = RaidTools.ready_check_messages[math.random( 1, #RaidTools.ready_check_messages - 1 )] 
	elseif not_funny then
		message = electionDescriptor or message
	end
	message = RaidTools.Iconify(message, true)
	if (RaidTools.storage and RaidTools.storage.config.coloured_ready_checks) then
		RaidTools.BeginGroupElection(electionType, '|t32:32:esoui/art/icons/poi/poi_raiddungeon_complete.dds|t|c'.. CLR.cancer.hex ..' ' .. message .. '|r', targetUnitTag)
	else
		RaidTools.BeginGroupElection(electionType, '|t32:32:esoui/art/icons/poi/poi_raiddungeon_complete.dds|t' .. message, targetUnitTag)
	end
	RaidTools.SimpleMessage('ReadyCheck message: ' .. message)
end

--
-- Functions:General
--

function bool2yesno(b)
	if b then return 'Yes'
	else return 'No' end
end

function spairs(t, order)
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function HideMessageBox(message_box_id)
	ZO_Dialogs_ReleaseDialog(message_box_id, false)
end

function ShowMessageBox(message_box_id, title, message, button_text, callback)
	local dialog = 
	{
		title = { text = title },
		mainText = { text = message },
		buttons = 
		{
			{
				text = button_text, 
				callback = callback
			}
		}
   }

   ZO_Dialogs_RegisterCustomDialog(message_box_id, dialog)
   ZO_Dialogs_ShowDialog(message_box_id)
end

function SortAttacks(left, right) -- ingame/deathrecap/deathrecap.lua:209
    if(left.wasKillingBlow) then
        return false
    elseif(right.wasKillingBlow) then
        return true
    else
        return left.lastUpdateAgoMS > right.lastUpdateAgoMS
    end    
end

function FixName(name)
	name = string.gsub(name, '%^.+', '')
	return name
end
_T1 = 'Ne'
function has_value(table, _value)
    for index, value in ipairs(table) do
        if value == _value then
            return true
        end
    end

    return false
end

function ToggleLGSSending(enabled)
	local button = ZO_GroupMenu_Keyboard_LibGroupSocketToggle
	if not button then 
		zo_callLater(function() ToggleLibGroupSocket(enabled) end, 1000)
	else
		ZO_CheckButton_SetCheckState(button, enabled)
		button:toggleFunction(enabled)
	end
end

function LGSStatus()
	return ZO_CheckButton_IsChecked(ZO_GroupMenu_Keyboard_LibGroupSocketToggle)
end

--
-- Functions:From3rdParty
--

-- Took from: Thurisaz Guild Info
function postHook(funcName, callback, subtable)
	local tmp = _G[subtable][funcName]

	_G[subtable][funcName] = function(...)
		tmp(...)
		callback()
	end
end

--
-- Functions:Communication
--

function RaidTools.Announcement(message, sound)
	message = RaidTools.Iconify(message, true)
	if not sound then
		sound = SOUNDS.ACHIEVEMENT_AWARDED
	end
	local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_MAJOR_TEXT, sound)
	params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_RAID_TRIAL)
	params:SetText(message)
	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
end

function RaidTools.SimpleMessage(message)
	message = RaidTools.Iconify(message)
	CHAT_SYSTEM:AddMessage(message)
end

function RaidTools.BaseMessage(message)
	message = RaidTools.Iconify(message)
	CHAT_SYSTEM:AddMessage('|cffffff' .. message .. '|r')
end

function RaidTools.Message(message)
	message = RaidTools.Iconify(message)
	CHAT_SYSTEM:AddMessage('|cffffff<|r|c'.. CLR.cancer.hex ..'RT|r|cffffff>|r |cffffff' .. message .. '|r')
end

function RaidTools.BrandedMessage(message)
	message = RaidTools.Iconify(message)
	CHAT_SYSTEM:AddMessage('|t22:22:esoui/art/icons/poi/poi_raiddungeon_complete.dds|t|cffffff<|r|c'.. CLR.cancer.hex ..'RaidTools|r|cffffff>|r ' .. message)
end

function RaidTools.DebugMessage(message)
	message = RaidTools.Iconify(message)
	if RaidTools.storage and not RaidTools.storage.debug then return end
	CHAT_SYSTEM:AddMessage('|c'.. CLR.cancer.hex ..'<RaidTools-Debug> ' .. message .. '|r')
end

--
-- Functions:Module:DeathResCounter
--

function RaidTools.TotalDeaths()
	local count = 0
	for name, deaths in pairs(RaidTools.deaths) do
		count = count + deaths
	end
	return count
end

function RaidTools.ForceResetDeaths() 
	RaidTools.my_deaths = 0
	RaidTools.BrandedMessage('Force-resetted the death count')
	if not next(RaidTools.deaths) then return end
	for player, deaths in ipairs(RaidTools.deaths) do
		RaidTools.deaths[player] = 0
	end
end

function RaidTools.ForceResetResurrections() 
	RaidTools.my_rez = 0
	RaidTools.BrandedMessage('Force-resetted your resurrections')
	RaidTools.resurrections = {}
end

function RaidTools.AddPlayerDeath(player)
	if not RaidTools.deaths[player] then
		RaidTools.deaths[player] = 1
	else
		RaidTools.deaths[player] = RaidTools.deaths[player] + 1
	end
end


function RaidTools.AddPlayerResurrection(dead_player)
	if not RaidTools.resurrections[dead_player] then
		RaidTools.resurrections[dead_player] = 1
	else
		RaidTools.resurrections[dead_player] = RaidTools.resurrections[dead_player] + 1
	end
end

function RaidTools.AddMyDeaths()
	if not RaidTools.my_deaths then RaidTools.my_deaths = 0 end
	RaidTools.my_deaths = RaidTools.my_deaths + 1
end

function RaidTools.GetMyDeaths()
	if not RaidTools.my_deaths then RaidTools.my_deaths = 0 end
	return RaidTools.my_deaths
end

function RaidTools.AddMyRez()
	if not RaidTools.my_rez then RaidTools.my_rez = 0 end
	RaidTools.my_rez = RaidTools.my_rez + 1
end

function RaidTools.GetMyRez()
	if not RaidTools.my_rez then RaidTools.my_rez = 0 end
	return RaidTools.my_rez
end

_T2 = 'cro'
--
-- Functions:Trial
--

function RaidTools.IsTrialZone(zone_id)
	if RaidTools.GetTrialByZoneId(zone_id) == nil then
		return false
	else
		return true
	end
end

function RaidTools.GetTrialByZoneId(zone_id)
	for trial_id, zone in pairs(RaidTools.trial_zones) do
		if zone == zone_id then
			return trial_id
		end
	end
	return nil
end

function RaidTools.GetMyZone()
	return GetZoneId(GetUnitZoneIndex('player'))
end

function RaidTools.IsPlayerInVeteranTrial()
	if RaidTools.GetTrialId() == nil then return false end
	return IsGroupUsingVeteranDifficulty()
end

function RaidTools.GetTrialId(unit)
	local unit_tag = (unit or 'player')
	return RaidTools.GetTrialByZoneId(GetZoneId(GetUnitZoneIndex(unit_tag)))
end

function RaidTools.GetTrialName(raid_id)
	if raid_id then
		return GetRaidName(raid_id):gsub('%((.*)%)', '')
	else
		return GetRaidName(RaidTools.GetTrialByZoneId(GetZoneId(GetUnitZoneIndex('player')))):gsub('%((.*)%)', '')
	end
end
_T3 = 'n77'
function RaidTools.UpdateLeaderboardInfo()
	if GetTimeStamp() >= RaidTools.leaderboard_info_update + 300 then
		QueryRaidLeaderboardData()
	end
end

function RaidTools.IsLeaderboardDataAvailable(_threshold)
	local threshold = (_threshold or 0)
	return (RaidTools.leaderboard_info_update >= GetTimeStamp()-threshold)
end

function RaidTools.GetWeeklyTrial()
	RaidTools.UpdateLeaderboardInfo()
	local trial_name, trial_id = GetRaidOfTheWeekLeaderboardInfo(RAID_CATEGORY_TRIAL)
	return trial_id
end

function RaidTools.GetWeeklyChallenge()
	RaidTools.UpdateLeaderboardInfo()
	local trial_name, trial_id = GetRaidOfTheWeekLeaderboardInfo(RAID_CATEGORY_CHALLENGE)
	return trial_id
end

function RaidTools.GetWeeklyTime(until_end)
	RaidTools.UpdateLeaderboardInfo()
	local until_end, until_start = GetRaidOfTheWeekTimes()
	if start then
		return until_start
	else
		return until_end
	end
end

function RaidTools.CheckWeeklyOver()
	if GetTimeStamp() >= RaidTools.storage.weekly.end_date then
		return true
	else
		return false
	end
end

function RaidTools.SetWeeklyEndDate()
	local until_end = RaidTools.GetWeeklyTime(false)
	RaidTools.storage.weekly.end_date = GetTimeStamp() + until_end
end

function RaidTools.UpdateWeeklyInfo()
	local name, raid_id = GetRaidOfTheWeekLeaderboardInfo()
	RaidTools.storage.weekly.trial.raid_id = raid_id
	RaidTools.storage.weekly.challenge.raid_id = TRIAL_MAELSTROM_ARENA
end

function RaidTools.IsSmallGroupRaid(raid)
	local raid_id = (raid or GetCurrentParticipatingRaidId())
	if raid_id == TRIAL_MAELSTROM_ARENA or raid_id == TRIAL_DRAGONSTAR_ARENA or raid_id == TRIAL_BLACKROSE_PRISON then
		return true
	end
	return false
end

function RaidTools.IsNoTrashRaid(raid)
	local raid_id = (raid or GetCurrentParticipatingRaidId())
	if raid_id == TRIAL_ASYLUM_SANCTORIUM or raid_id == TRIAL_CLOUDREST then
		return true
	else
		return false
	end
end

function RaidTools.IsRaidAChallenge(raid)
	local raid_id = (raid or GetCurrentParticipatingRaidId())
	local challenges = {[TRIAL_MAELSTROM_ARENA] = true}
	if challenges[raid_id] then
		return true
	end
	return false
end

function RaidTools.RaidIdToChallengeId(raid_id)
	local challenges = {[TRIAL_MAELSTROM_ARENA] = 1}
	if challenges[raid_id] then
		return challenges[raid_id]
	end
	return nil
end

function RaidTools.RaidIdToRaidIndex(raid_id)
	local indexes = {
		[TRIAL_HEL_RA_CITADEL] = 1,
		[TRIAL_AETHERIAN_ARCHIVE] = 2,
		[TRIAL_SANCTUM_OPHIDIA] = 3,
		[TRIAL_DRAGONSTAR_ARENA] = 4,
		[TRIAL_MAW_OF_LORKHAJ] = 5,
		[TRIAL_HALLS_OF_FABRICATION] = 6,
		[TRIAL_ASYLUM_SANCTORIUM] = 7,
		[TRIAL_CLOUDREST]	= 8,
		[TRIAL_BLACKROSE_PRISON] = 9,
		[TRIAL_SUNSPIRE] = 10
	}

	return indexes[raid_id]
end

function RaidTools.ResetWeeklyData()
	RaidTools.storage.weekly.new_weekly_info_displayed = false
	RaidTools.storage.weekly.summary_displayed = false
	RaidTools.storage.weekly.trial.characters = {}
	RaidTools.storage.weekly.challenge.characters = {}

end

function RaidTools.ResetTrialInfo(only_params)
	if not only_params then
		RaidTools.trial.raid_id = 0
		RaidTools.trial.target_time = 0
	end
	RaidTools.trial.started = false
	RaidTools.trial.in_progress = false
	RaidTools.trial.hard_mode = false
	RaidTools.trial.hard_mode_param = 0
	RaidTools.trial.target_time_failed = false
	RaidTools.trial.speed_run_failed = false
end

--
-- Functions:LeaderboardParsing
--

function RaidTools.CountMyWeeklyEntries(challenge)
	local count = 0
	if challenge then
		for name, data in pairs(RaidTools.storage.weekly.challenge.characters) do
			count = count + 1
		end
	else
		for name, data in pairs(RaidTools.storage.weekly.trial.characters) do
			count = count + 1
		end
	end
	return count
end

function RaidTools.RetrieveChallengeLeaderboard(raid_id)
	RaidTools._leaderboards.alltime[raid_id] = {}
	RaidTools._leaderboards.weekly[raid_id] = {}
	RaidTools._leaderboards.class_conform_weekly[raid_id] = {}

	local challenge_id = RaidTools.RaidIdToChallengeId(raid_id)
	for class = 1, GetNumClasses() do
		local class = GetClassInfo(class)
		for i = 1, GetNumChallengeLeaderboardEntries(challenge_id, class) do
			local rank, char_name, score, class_id, alliance_id, account_name = GetChallengeLeaderboardEntryInfo(challenge_id, class, i)
			local is_me = (account_name == UID)

			table.insert(RaidTools._leaderboards.alltime[raid_id], {
				is_me = is_me,
				account_name = account_name,
				char_name = char_name,
				uname = char_name,--GetUniqueNameForCharacter(char_name),
				class = class_id,
				alliance = alliance_id,
				score = score,
				rank = rank,
				leaderboard_index = i
			})
		end
		RaidTools._leaderboards.class_conform_weekly[raid_id][class] = {}
		for i = 1, GetNumChallengeOfTheWeekLeaderboardEntries(class) do
			local rank, char_name, score, class_id, alliance_id, account_name = GetChallengeOfTheWeekLeaderboardEntryInfo(class, i)
			local is_me = (account_name == UID)

			table.insert(RaidTools._leaderboards.weekly[raid_id], {
				is_me = is_me,
				account_name = account_name,
				char_name = char_name,
				uname = char_name,--GetUniqueNameForCharacter(char_name),
				class = class_id,
				alliance = alliance_id,
				score = score,
				rank = rank,
				leaderboard_index = i
			})
			table.insert(RaidTools._leaderboards.class_conform_weekly[raid_id][class], {
				is_me = is_me,
				account_name = account_name,
				char_name = char_name,
				uname = char_name,--GetUniqueNameForCharacter(char_name),
				class = class_id,
				alliance = alliance_id,
				score = score,
				rank = rank,
				leaderboard_index = i
			})
		end
	end
end

function RaidTools.RetrieveRaidLeaderboard(raid_id)
	--if not RaidTools._leaderboards then
	--	RaidTools._leaderboards = {
	--		weekly = {}, 
	--		alltime = {}, 
	--		class_conform_weekly = {}
	--	}
	--end
	
	RaidTools._leaderboards.alltime[raid_id] = {}
	RaidTools._leaderboards.weekly[raid_id] = {}

	raid_index = RaidTools.RaidIdToRaidIndex(raid_id)

	for i = 1, GetNumTrialLeaderboardEntries(raid_index) do
		local rank, char_name, score, class_id, alliance_id, account_name = GetTrialLeaderboardEntryInfo(raid_index, i)
		local is_me = (account_name == UID)
		
		table.insert(RaidTools._leaderboards.alltime[raid_id], {
			is_me = is_me,
			account_name = account_name,
			char_name = char_name,
			uname = char_name,--GetUniqueNameForCharacter(char_name),
			class = class_id,
			alliance = alliance_id,
			score = score,
			rank = rank,
			leaderboard_index = i
		})
	end
	for i = 1, GetNumTrialOfTheWeekLeaderboardEntries() do
		local rank, char_name, score, class_id, alliance_id, account_name = GetTrialOfTheWeekLeaderboardEntryInfo(i)
		local is_me = (account_name == UID)

		table.insert(RaidTools._leaderboards.weekly[raid_id], {
			is_me = is_me,
			account_name = account_name,
			char_name = char_name,
			uname = char_name,--GetUniqueNameForCharacter(char_name),
			class = class_id,
			alliance = alliance_id,
			score = score,
			rank = rank,
			leaderboard_index = i
		})
	end
end

function RaidTools.RetrieveLeaderboard(raid_id)
	if RaidTools.IsRaidAChallenge(raid_id) then
		RaidTools.RetrieveChallengeLeaderboard(raid_id)
	else
		RaidTools.RetrieveRaidLeaderboard(raid_id)
	end
end


function RaidTools.PerformLeaderboardCheck()
	RaidTools.UpdateLeaderboardInfo()
	for raid_id, _ in pairs(RaidTools.trial_zones) do
		RaidTools.RetrieveLeaderboard(raid_id)
	end
	RaidTools.DebugMessage('RaidTools.PerformLeaderboardCheck()')
	for character_id, character in pairs(RaidTools.characters) do
		for raid_id, _ in pairs(RaidTools.trial_zones) do
			local raid_name = RaidTools.GetTrialName(raid_id)
			for _, data in pairs(RaidTools._leaderboards.alltime[raid_id]) do
				if data.is_me then
					if not RaidTools.storage.alltime[raid_id][data.uname] then
						RaidTools.DebugMessage(string.format('ADDED %s (%s) to %s ALLTIME with score of %s (rank: %s)', data.char_name, data.uname, raid_name, data.score, data.rank))
						RaidTools.storage.alltime[raid_id][data.uname] = {
							score = data.score,
							rank = data.rank
						}
					else
						if RaidTools.storage.alltime[raid_id][data.uname].score ~= data.score then
							RaidTools.DebugMessage(string.format('UPDATED %s (%s) %s ALLTIME SCORE TO %s', data.char_name, data.uname, raid_name, data.score))
							RaidTools.storage.alltime[raid_id][data.uname].score = data.score
						end
						if RaidTools.storage.alltime[raid_id][data.uname].rank ~= data.rank then
							if RaidTools.storage.alltime[raid_id][data.uname].rank > data.rank then
								RaidTools.DebugMessage(string.format('%s (%s) %s ALLTIME RANK IMPROVED!!!', data.char_name, data.uname, raid_name))
							else
								RaidTools.DebugMessage(string.format('%s (%s) %s ALLTIME RANK DECREASED!!!', data.char_name, data.uname, raid_name))
							end
							RaidTools.DebugMessage(string.format('UPDATED %s (%s) %s ALLTIME RANK TO %s', data.char_name, data.uname, raid_name, data.rank))
							RaidTools.storage.alltime[raid_id][data.uname].rank = data.rank
						end 
					end
				end
			end
		end
	end
end

function RaidTools.PerformWeeklyCheck()
	RaidTools.UpdateLeaderboardInfo()
	local weekly_trial, weekly_challenge = RaidTools.GetWeeklyTrial(), RaidTools.GetWeeklyChallenge()
	RaidTools.RetrieveLeaderboard(weekly_trial)
	RaidTools.RetrieveLeaderboard(weekly_challenge) -- TODO: Update if another challenge drops
	RaidTools.DebugMessage('RaidTools.PerformWeeklyCheck()')
	for character_id, character in pairs(RaidTools.characters) do
		local raid_id = weekly_trial
		local raid_name = RaidTools.GetTrialName(raid_id)
		for _, data in pairs(RaidTools._leaderboards.weekly[raid_id]) do
			if data.is_me then
				if not RaidTools.storage.weekly.trial.characters[data.uname] then
					RaidTools.DebugMessage(string.format('ADDED %s (%s) to %s WEEKLY with score of %s (rank: %s)', data.char_name, data.uname, raid_name, data.score, data.rank))
					RaidTools.storage.weekly.trial.characters[data.uname] = {
						score = data.score,
						rank = data.rank
					}
				else
					if RaidTools.storage.weekly.trial.characters[data.uname].score ~= data.score then
						RaidTools.DebugMessage(string.format('UPDATED %s (%s) %s WEEKLY SCORE TO %s', data.char_name, data.uname, raid_name, data.score))
						RaidTools.storage.weekly.trial.characters[data.uname].score = data.score
					end
					if RaidTools.storage.weekly.trial.characters[data.uname].rank ~= data.rank then
						if RaidTools.storage.weekly.trial.characters[data.uname].rank > data.rank then
							RaidTools.DebugMessage(string.format('%s (%s) %s WEEKLY RANK IMPROVED!!!', data.char_name, data.uname, raid_name))
						else
							RaidTools.DebugMessage(string.format('%s (%s) %s WEEKLY RANK DECREASED!!!', data.char_name, data.uname, raid_name))
						end
						RaidTools.DebugMessage(string.format('UPDATED %s (%s) %s WEEKLY RANK TO %s', data.char_name, data.uname, raid_name, data.rank))
						RaidTools.storage.weekly.trial.characters[data.uname].rank = data.rank
					end 
				end
			end
		end
		local raid_id = weekly_challenge
		local raid_name = RaidTools.GetTrialName(raid_id)
		for _, data in pairs(RaidTools._leaderboards.weekly[raid_id]) do
			if data.is_me then
				if not RaidTools.storage.weekly.challenge.characters[data.uname] then
					RaidTools.DebugMessage(string.format('ADDED %s (%s) to %s WEEKLY with score of %s (rank: %s)', data.char_name, data.uname, raid_name, data.score, data.rank))
					RaidTools.storage.weekly.challenge.characters[data.uname] = {
						score = data.score,
						rank = data.rank
					}
				else
					if RaidTools.storage.weekly.challenge.characters[data.uname].score ~= data.score then
						RaidTools.DebugMessage(string.format('UPDATED %s (%s) %s WEEKLY SCORE TO %s', data.char_name, data.uname, raid_name, data.score))
						RaidTools.storage.weekly.challenge.characters[data.uname].score = data.score
					end
					if RaidTools.storage.weekly.challenge.characters[data.uname].rank ~= data.rank then
						if RaidTools.storage.weekly.challenge.characters[data.uname].rank > data.rank then
							RaidTools.DebugMessage(string.format('%s (%s) %s WEEKLY RANK IMPROVED!!!', data.char_name, data.uname, raid_name))
						else
							RaidTools.DebugMessage(string.format('%s (%s) %s WEEKLY RANK DECREASED!!!', data.char_name, data.uname, raid_name))
						end
						RaidTools.DebugMessage(string.format('UPDATED %s (%s) %s WEEKLY RANK TO %s', data.char_name, data.uname, raid_name, data.rank))
						RaidTools.storage.weekly.challenge.characters[data.uname].rank = data.rank
					end 
				end
			end
		end
	end
end

function RaidTools.EstimatedLeaderboardRank(raid, raid_score)
	local raid_id = (raid or GetCurrentParticipatingRaidId())
	local score = (raid_score or GetCurrentRaidScore())
	if #RaidTools._leaderboards.alltime[raid_id] > 0 then
		for _, data in pairs(RaidTools._leaderboards.alltime[raid_id]) do
			if score > data.score then
				return data.rank
			end
		end

		local entry = RaidTools._leaderboards.alltime[raid_id][1]
		if score > entry.score then
			return 1
		end
	else
		return 1
	end
	return 0
end

--
-- MessageBoxCallbacks
--

function RaidTools.OnWeeklyNewsRead()
	HideMessageBox('rt_weekly_news')
	if next(RaidTools.notifications) then
		RaidTools.DebugMessage('notifications_message_box_after_weekly_news') -- currently unused
	end
end

function RaidTools.OnWeeklySummaryRead()
	HideMessageBox('rt_weekly_summary')
	local until_end = RaidTools.GetWeeklyTime(true)
	if until_end == 0 then
		RaidTools.storage.weekly.new_weekly_info_displayed = false
		message = 'Next weekly trial information is not available yet.'
	else
		RaidTools.storage.weekly.new_weekly_info_displayed = true
		message = 'Weekly trial: ' .. GetRaidName(RaidTools.storage.weekly.trial.raid_id) .. '\nWeekly challenge: ' .. GetRaidName(RaidTools.storage.weekly.challenge.raid_id)
	end
	ShowMessageBox('rt_weekly_news', 'RaidTools - Weekly report 2/2', message, 'Ok', RaidTools.OnWeeklyNewsRead)
end

--
-- Functions:Group
--

function RaidTools.IndexGroup()
	local unit_tag, player
	for i = 1, GetGroupSize() do
		unit_tag = 'group'..i
		player = RaidTools.GetGroupPlayer(GetUnitName(unit_tag))
	end
end

function RaidTools.RegisterGroupPlayer(character_name)
	local data = {}
	data.name = FixName(character_name)
	data.uname = GetUniqueNameForCharacter(data.name)
	data.data = false
	data.attributes = {is_magicka = false, is_stamina = false, is_health = false, ultimate = -1}
	data.dps = 0
	data.ultimate_cost = 255
	data.sets = {}
	data.vote = -1
	RaidTools.group[data.uname] = data
end

function RaidTools.DismemberGroupPlayer(character_name)
	RaidTools.group[GetUniqueNameForCharacter(character_name)] = nil
end

function RaidTools.GetGroupPlayer(character_name)
	if not RaidTools.group[GetUniqueNameForCharacter(character_name)] then RaidTools.RegisterGroupPlayer(character_name) end
	return RaidTools.group[GetUniqueNameForCharacter(character_name)]
end

function RaidTools.GetGroupDisplayNames()
	local unit_tag, players = '', {}
	for i = 1, GetGroupSize() do
		unit_tag = 'group'..i
		table.insert(players, GetUnitDisplayName(unit_tag))
	end
	return players
end

local REGROUP_DISPLAY_NAMES
function RaidTools.ProcessRegroup()
	if not IsUnitGrouped('player') then RaidTools.BrandedMessage('You are not in any group!') return end
	if not IsUnitGroupLeader('player') then RaidTools.BrandedMessage('You are not the group leader!') return end

	local display_name
	REGROUP_DISPLAY_NAMES = {}

	for i = 1, GetGroupSize() do
		unit_tag = 'group'..i
		display_name = GetUnitDisplayName(unit_tag)
		if display_name ~= UID then
			table.insert(REGROUP_DISPLAY_NAMES, display_name)
		end
	end

	RaidTools.BrandedMessage('Waiting for disbanding of the group...')
	GroupDisband()

	local function OnGroupMemberLeft(eventCode, memberName, reason, isLocalPlayer, isLeader, memberDisplayName, actionRequiredVote)
		if reason ~= GROUP_LEAVE_REASON_DISBAND then return end
		RaidTools.BrandedMessage('Regroup in process...')
		EVENT_MANAGER:UnregisterForEvent('RaidToolsSmartRegrouping', EVENT_GROUP_MEMBER_LEFT)
		for _, display_name in pairs(REGROUP_DISPLAY_NAMES) do
			RaidTools.BaseMessage('--> '..ZO_LinkHandler_CreateDisplayNameLink(display_name))
			GroupInviteByName(display_name)
		end
	end

	EVENT_MANAGER:RegisterForEvent('RaidToolsSmartRegrouping', EVENT_GROUP_MEMBER_LEFT, OnGroupMemberLeft)
end

--
-- Functions:ItemUtility
--

local equipment_slots = {
    EQUIP_SLOT_HEAD,
    EQUIP_SLOT_SHOULDERS,
    EQUIP_SLOT_CHEST,
    EQUIP_SLOT_HAND,
    EQUIP_SLOT_WAIST,
    EQUIP_SLOT_LEGS,
    EQUIP_SLOT_FEET,
    EQUIP_SLOT_NECK,
    EQUIP_SLOT_RING1,
    EQUIP_SLOT_RING2,
    EQUIP_SLOT_OFF_HAND,
    EQUIP_SLOT_BACKUP_OFF,
    EQUIP_SLOT_MAIN_HAND,
    EQUIP_SLOT_BACKUP_MAIN
}

-- Up-to-date for DragonBones
local group_buff_sets = { -- TODO: Update...
	-- STAM DD
	--[159] = {name = 'Sunderflame', item_id = 104708}, -- RIP Update 4.0 
	--[51]  = {name = 'NightMothersGaze', item_id = 48869}, -- RIP Update 4.0 
	[50]  = {name = 'MoragTong', item_id = 93392},
	[331] = {name = 'WarMachine', item_id = 124129},
	[180] = {name = 'PowerfulAssault', item_id = 68579},

	-- MAG DD
	[172] = {name = 'InfalliableMage', item_id = 80272},
	[332] = {name = 'MasterArchitect', item_id = 124312},

	-- TANK
	[232] = {name = 'Alkosh', item_id = 73051},
	[122] = {name = 'Ebony', item_id = 106182},
	[330] = {name = 'AutomatedDefense', item_id = 123947},

	-- HEALER
	[124] = {name = 'Wormcult', item_id = 110796},
	[185] = {name = 'SpellPowerCure', item_id = 111906},
	[141] = {name = 'Mending', item_id = 112479},
	[110] = {name = 'Sanctuary', item_id = 102471},
	[123] = {name = 'Hircine', item_id = 105072},
	[229] = {name = 'TwilightRemedy', item_id = 73034},

	-- HEAL/TANK
	[346] = {name = 'Jorvulds', item_id = 129145}
}

local function SoulGemItemSlot()
	for slot = 0, GetBagSize(BAG_BACKPACK) do
		if IsItemSoulGem(SOUL_GEM_TYPE_FILLED, BAG_BACKPACK, slot) then
			return slot
		end
	end
	return nil
end

local function RepairKitItemSlot()
	for slot = 0, GetBagSize(BAG_BACKPACK) do
		if IsItemNonCrownRepairKit(BAG_BACKPACK, slot) then
			return slot
		end
	end
	return nil
end
local weapon_threshold = 1
function RaidTools.ChargeWeapons(_threshold)
	local soul_gem_slot = false
	local threshold = (_threshold or weapon_threshold)
	local to_charge = {
		EQUIP_SLOT_OFF_HAND,
	    EQUIP_SLOT_BACKUP_OFF,
	    EQUIP_SLOT_MAIN_HAND,
	    EQUIP_SLOT_BACKUP_MAIN
	}
	for _, slot in ipairs(to_charge) do
		local charges, max_charges = GetChargeInfoForItem(BAG_WORN, slot)
		if ((charges/max_charges)*100) <= threshold then
			if soul_gem_slot == false then soul_gem_slot = SoulGemItemSlot() end
			if soul_gem_slot == nil then RaidTools.BrandedMessage('[Recharge] No soul gems available!') return true end
			ChargeItemWithSoulGem(BAG_WORN, slot, BAG_BACKPACK, soul_gem_slot)
			RaidTools.DebugMessage('[Recharge] Recharged: '..GetItemLink(BAG_WORN, slot, LINK_STYLE_BRACKETS))
		end
	end
	return false
end
local armour_threshold = 5
function RaidTools.RepairArmour(slot, silent)
	local repair_kit_slot = RepairKitItemSlot()
	local function do_repair(slot_id)
		if DoesItemHaveDurability(BAG_WORN, slot_id) and (IsArmorEffectivenessReduced(BAG_WORN, slot_id) or GetItemCondition(BAG_WORN, slot_id) <= armour_threshold) then
			if repair_kit_slot == nil then if silent then return true end RaidTools.BrandedMessage('[Repair] No repair kits available!') return true end
        	RepairItemWithRepairKit(BAG_WORN, slot_id, BAG_BACKPACK, repair_kit_slot)
			RaidTools.DebugMessage('[Repair] Repaired: '..GetItemLink(BAG_WORN, slot_id, LINK_STYLE_BRACKETS))
        end
	end
	if not slot then
		for _, slot_id in ipairs(equipment_slots) do
			do_repair(slot_id)
		end
	else
		do_repair(slot)
	end
	return false
end

function RaidTools.GetActive5PSets(full)
    local sets, result = {}, {}
    for _, slot in ipairs(equipment_slots) do
        local item_link = GetItemLink(BAG_WORN, slot, LINK_STYLE_DEFAULT)
        local hasSet, name, bonus_count, equiped_count, max_equiped, set_id = GetItemLinkSetInfo(item_link, true)
        if max_equiped == 5 then
            if not sets[set_id] then
                sets[set_id] = {
                    id = set_id,
                    name = name,
                    count = 1
                }   
            else
                sets[set_id].count = sets[set_id].count + 1
            end
        end
    end
    for set_id, data in pairs(sets) do
        if data.count == 5 then
            table.insert(result, set_id)
        end
    end
    if full then return sets end
    return result
end

function RaidTools.IsBuffSet(set_id)
	if group_buff_sets[set_id] then return true else return false end
end

function RaidTools.GetBuffSetName(set_id)
	if group_buff_sets[set_id] then return group_buff_sets[set_id].name else return 'n/a' end
end

function RaidTools.CreateItemLinkForBuffSet(set_id)
	return ZO_LinkHandler_CreateLink(RaidTools.GetBuffSetName(set_id), nil, ITEM_LINK_TYPE, group_buff_sets[set_id].item_id, 370, 50, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 10000, 0)
end

function RaidTools.ItemizationBrowserDataAvailable()
	if ItemBrowserData then 
		return true 
	else 
		return false 
	end
end

local _set_table = {}

local function BuildSetTable()
	for _, data in ipairs(ItemBrowserData.items) do
		local item_id = data[1]
		local _, set_name, _, _, _, set_id = GetItemLinkSetInfo(ZO_LinkHandler_CreateLink('', nil, ITEM_LINK_TYPE, item_id, 370, 50, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 10000, 0), false)
		_set_table[set_id] = set_name
	end
end

function RaidTools.GetSetName(set_id)
	if not RaidTools.ItemizationBrowserDataAvailable() then return 'no_data_available' end
	if not _set_table or #_set_table == 0 then
		BuildSetTable()
	end
	return (_set_table[set_id] or 'no_name_found')
end

local function GetPolyByName(name)
	local polymorph_shortcuts = {
		['skeleton'] = 34,
		['iamspecialfactotum'] = 1480
	}
	return polymorph_shortcuts[name]
end

function RaidTools.GetActivePolymorph()
	return GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_POLYMORPH)
end

function RaidTools.HasCollectible(id)
	return IsCollectibleOwnedByDefId(id)
end

function RaidTools.ToggleRaidPolymorph(activate_only)
	local collectible_id = GetPolyByName('skeleton')
	local activated = nil
	if RaidTools.HasCollectible(collectible_id) then
		if RaidTools.GetActivePolymorph() ~= collectible_id then if RaidTools.storage.config.jokes then RaidTools.RandomSkeletonJoke() end activated = true end
		if not activated and activate_only then return false end
		UseCollectible(collectible_id)
	end
	return activated
end

function RaidTools.DisableRaidPolymorph()
	local collectible_id = GetPolyByName('skeleton')
	if RaidTools.HasCollectible(collectible_id) then
		if RaidTools.GetActivePolymorph() == collectible_id then UseCollectible(collectible_id) end
	end
end

_T4 = 1391

local LFDB = LibStub('LibFoodDrinkBuff')
function RaidTools.IsBuffFoodActive()
	return LFDB:IsFoodBuffActive('player')
end

local raid_nodes = {
	[TRIAL_HEL_RA_CITADEL] = 230,
	[TRIAL_AETHERIAN_ARCHIVE] = 231,
	[TRIAL_SANCTUM_OPHIDIA] = 232,
	[TRIAL_DRAGONSTAR_ARENA] = 270,
	[TRIAL_MAW_OF_LORKHAJ] = 258,
	[TRIAL_MAELSTROM_ARENA] = 250,
	[TRIAL_HALLS_OF_FABRICATION] = 331,
	[TRIAL_ASYLUM_SANCTORIUM] = 346,
	[TRIAL_CLOUDREST] = 364,
	[TRIAL_BLACKROSE_PRISON] = 378,
	[TRIAL_SUNSPIRE] = 399
}

function RaidTools.PortToRaid(raid_id)
	-- Port in free...
	if IsUnitGrouped('player') then
		for i = 1, 12 do
			local unitTag = 'group'..i
			if DoesUnitExist(unitTag) and not AreUnitsEqual('player', unitTag) then
				local _raid_id = RaidTools.GetTrialId(unitTag)
				if _raid_id == raid_id then
					local can_jump =  CanJumpToGroupMember(unitTag)
					if can_jump then
						JumpToGroupMember(GetUnitDisplayName(unitTag))
						return
					end
				end
			end
		end
	end
	-- ...or pay
	FastTravelToNode(raid_nodes[raid_id])
end

local mundus_table = {
	[13940] = true,
	[13943] = true,
	[13974] = true,
	[13975] = true,
	[13976] = true,
	[13977] = true,
	[13978] = true,
	[13979] = true,
	[13980] = true,
	[13981] = true,
	[13982] = true,
	[13984] = true,
	[13985] = true,
	[98051] = true,
	[98055] = true,
}

local vamp_stages = {
    [35776] = 2,
    [35780] = 3,
    [35783] = 3,
    [35784] = 3,
    [35786] = 4,
    [38414] = 1,
    [38415] = 2,
    [38416] = 3,
    [38417] = 4,
    [92438] = 1,
    [39703] = 2,
    [92440] = 2,
    [92441] = 2,
    [39706] = 2,
    [92443] = 3,
    [92444] = 3,
    [39709] = 2,
    [39710] = 2,
    [39711] = 1,
    [39712] = 1,
    [39713] = 3,
    [39714] = 3,
    [92451] = 2,
    [39716] = 4,
    [39717] = 3,
    [39718] = 3,
    [39719] = 3,
    [92453] = 4,
    [39722] = 4,
    [39723] = 4,
    [39724] = 4,
    [39725] = 4,
    [92452] = 3,
    [92450] = 1,
    [92449] = 4,
    [92448] = 4,
    [92447] = 4,
    [92446] = 4,
    [92445] = 3,
    [92442] = 3,
    [92439] = 2,
    [35785] = 3,
    [35790] = 4,
    [35771] = 1,
    [35791] = 4,
    [35773] = 2,
    [35774] = 2,
    [35792] = 4,
}

function RaidTools.GetMundusStoneBuffs() -- Debug purposes only
	RaidTools.storage.debug = {}
	RaidTools.storage.debug.mundus = {}
	for ability_id = 1, 100000 do
		local name = GetAbilityName(ability_id)
		if string.match(name, 'Boon:') then
			d(string.format('%s (%s)', tostring(name), tostring(ability_id)))
			
			RaidTools.storage.debug.mundus[ability_id] = name
		end
	end
end

function RaidTools.GetVampStages() -- Debug purposes only
	RaidTools.storage.debug = {}
	RaidTools.storage.debug.vamp_stages = {}
	for ability_id = 1, 100000 do
		local name = GetAbilityName(ability_id)
		if string.match(name, 'Vampirism') then
			d(string.format('%s (%s)', tostring(name), tostring(ability_id)))
			
			RaidTools.storage.debug.vamp_stages[ability_id] = name
		end
	end
end

function RaidTools.GetESOPlusStatus(unit)
	local unit_tag = (unit or 'player')
	local buff_count = GetNumBuffs(unit_tag)
	if buff_count > 0 then
		for i = 1, buff_count do
			local name, _, _, _, _, _, _, _, _, _, ability_id = GetUnitBuffInfo(unit_tag, i)
			if ability_id == 63601 then
				return true
			end
		end
	end
	return nil
end

function RaidTools.GetActiveMundus(unit)
	local unit_tag = (unit or 'player')
	local buff_count = GetNumBuffs(unit_tag)
	if buff_count > 0 then
		for i = 1, buff_count do
			local _, _, _, _, _, _, _, _, _, _, ability_id = GetUnitBuffInfo(unit_tag, i)
			if mundus_table[ability_id] then
				return GetAbilityName(ability_id)
			end
		end
	end
	return nil
end

function RaidTools.GetVampStage(unit)
	local unit_tag = (unit or 'player')
	local buff_count = GetNumBuffs(unit_tag)
	if buff_count > 0 then
		for i = 1, buff_count do
			local _, _, _, _, _, _, _, _, _, _, ability_id = GetUnitBuffInfo(unit_tag, i)
			if vamp_stages[ability_id] then
				return vamp_stages[ability_id]
			end
		end
	end
	return nil
end

function RaidTools.GetAllDungeons() -- Debug purposes only
	local dungeon_poi = {}
	for i = 1, GetNumFastTravelNodes() do
		local known, name, normalizedX, normalizedY, icon, glowIcon, poiType, isShownInCurrentMap, linkedCollectibleIsLocked = GetFastTravelNodeInfo(i)
		if poiType == POI_TYPE_GROUP_DUNGEON then
			name = name:gsub('Dungeon: ', '')
			dungeon_poi[HashString(name)] = i
		end
	end
	d('-------')
	RaidTools.storage.debug = {}
	RaidTools.storage.debug.dungeons = {}
	GetZoneId(GetUnitZoneIndex('player'))
	for zone_index = 1, 900000 do
		local zone = GetZoneId(zone_index)
		local name = GetZoneNameById(zone)
		if zone ~= 0 then
			if dungeon_poi[HashString(name)] then
				RaidTools.storage.debug.dungeons[name] = {
					ft_node = dungeon_poi[HashString(name)],
					name = name,
					zone = zone
				}
			end
		end
	end
end

local skeleton_jokes = {
	'Why didn’t the skeleton dance at the Halloween party? He had no body to dance with!',
	'When does a skeleton laugh? When something tickles his funny bone.',
	'What do you do if you see a skeleton running across a road? Jump out of your skin and join him!',
	'Why did the skeleton run up a tree? Because a dog was after his bones!',
	'What happened to the pirate ship that sank in the sea full of sharks? It came back with a skeleton crew!',
	'How did the skeleton know it was going to rain? He could feel it in his bones!',
	'How did the skeleton know it was raining? He could feel it on his bones!',
	'What do you call a skeleton that does stunts? Bonehead!',
	'Why didn’t the skeleton want to play football, anymore? Because his heart wasn’t in it!',
	'How did skeletons send their letters in the old days? By bony express!',
	'What does a skeleton orders at a restaurant? Spare ribs!',
	'Where does the skeleton go to get a new rib! A spare rib restaurant!',
	'When does a skeleton smile? When something bumps into his funny bone!',
	'Why do skeletons hate winter? Beacuse the cold goes right through them!',
	'How do skeletons call their friends? On the telebone!',
	'What do you call a skeleton snake? A rattler!',
	'What did the skeleton say when another skeleton told a lie? You can’t fool me, I can see right through you!',
	'What did the skeleton say while riding his Harley Davidson motorcycle? I’m bone to be wild!',
	'Who was the most famous skeleton detective? Sherlock Bones!',
	'Why did the skeleton go to hospital? To have his ghoul stones removed!',
	'What do boney people use to get into their homes? Skeleton keys!',
	'Why did the skeleton stay out in the snow all night? He was a numbskull!',
	'Why did the skeleton have to goto church to play music? They don’t have any organs!',
	'What do you call a skeleton who won’t get up in the mornings? Lazy bones!',
	'What do you call a skeleton that is always telling lies? A boney phoney!',
	'Why wasn’t the naughty skeleton afraid of the police? Because he knew they couldn’t pin anything on him!',
	'What happened to the lazy skeleton? He was bone idle!',
	'What instrument do skeletons play? Trom-BONE!'
}

function RaidTools.RandomSkeletonJoke()
	local joke = skeleton_jokes[math.random( 0, #skeleton_jokes - 1 )] 
	RaidTools.SimpleMessage(joke)
end

function RaidTools.Iconify(text, big)
	for key, value in pairs(RT_TX) do
		if big then
			text = text:gsub(':'..key..':', string.format("|t%d:%d:%s|t", 32, 32, value))
		else
			text = text:gsub(':'..key..':', string.format("|t%d:%d:%s|t", 18, 18, value))
		end
	end
	return text
end