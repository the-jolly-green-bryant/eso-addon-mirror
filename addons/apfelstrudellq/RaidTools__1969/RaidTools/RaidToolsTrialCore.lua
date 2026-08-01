RaidToolsModule_TrialCore = {}

local last_annoying_announcement = 0
local function BuffFoodChecker()
	if not RaidTools.IsBuffFoodActive() then
		if GetTimeStamp() >= last_annoying_announcement + 15 then
			last_annoying_announcement = GetTimeStamp()
			RaidTools.Announcement('|c'..CLR.health.hex..'BUFF-FOOD!')
		end
	end
end

function RaidToolsModule_TrialCore.OnTrialEntered()
	ToggleLGSSending(true) -- make sure LibGroupSocket sending is enabled
	local is_weekly = false
	local raid_id = RaidTools.GetTrialId()
	local trial_name = RaidTools.GetTrialName(raid_id)
	RaidTools.RetrieveLeaderboard(raid_id)
	RaidTools.BrandedMessage('Entered ' .. trial_name)

	if raid_id ~= RaidTools.trial.raid_id or (raid_id == RaidTools.trial.raid_id and RaidTools.trial.in_progress and not IsRaidInProgress()) then
		RaidTools.ResetTrialInfo()
		RaidTools.trial.raid_id = raid_id
		RaidTools.trial.target_time = GetRaidTargetTime()
		if IsRaidInProgress() then
			RaidTools.trial.started = true
			RaidTools.trial.in_progress = true
		end
	end

	if IsGroupUsingVeteranDifficulty() or IsUnitUsingVeteranDifficulty('player') then
		RaidToolsStatusBar.Show()
		RaidToolsStatusBar.Start()
		if not RaidTools.CheckWeeklyOver() and (raid_id == RaidTools.GetWeeklyTrial() or raid_id == RaidTools.GetWeeklyChallenge()) then
			is_weekly = true
			RaidTools.Message('## Weekly info ##')
			if not RaidTools.IsRaidAChallenge(raid_id) then
				RaidTools.Message('Total entries: ' .. GetNumTrialOfTheWeekLeaderboardEntries() .. ' | Your entries: ' .. RaidTools.CountMyWeeklyEntries())
				if GetNumTrialOfTheWeekLeaderboardEntries() > 0 and RaidTools._leaderboards.weekly[raid_id] and #RaidTools._leaderboards.weekly[raid_id] > 0 then
					local entry = RaidTools._leaderboards.weekly[raid_id][#RaidTools._leaderboards.weekly[raid_id]]
					RaidTools.Message(string.format('Minimum score required: %s (rank: %s)', entry.score, entry.rank))
				end
			else
				
				local class_name = GetClassName(CHAR.gender, CHAR.class)
				RaidTools.Message('Total entries: ' .. GetNumChallengeOfTheWeekLeaderboardEntries(CHAR.class) .. ' | Your entries: ' .. RaidTools.CountMyWeeklyEntries(true) )
				if GetNumChallengeOfTheWeekLeaderboardEntries(CHAR.class) > 0 and RaidTools._leaderboards.class_conform_weekly[raid_id][CHAR.class] and #RaidTools._leaderboards.class_conform_weekly[raid_id][CHAR.class] > 0 then
					local entry = RaidTools._leaderboards.class_conform_weekly[raid_id][CHAR.class][#RaidTools._leaderboards.class_conform_weekly[raid_id][CHAR.class]]
					RaidTools.Message(string.format('[%s] Minimum score required: %s (rank: %s)', class_name, entry.score, entry.rank))
				end
			end
			RaidTools.Message(ZO_FormatCountdownTimer(RaidTools.GetWeeklyTime(true)) ..' left')
		end
		if RaidTools.trial.in_progress then
			RaidToolsModule_TrialCore.OnTrialStart(0, trial_name, is_weekly)
		elseif HasRaidEnded() and WasRaidSuccessful() then
			RaidToolsModule_TrialCore.OnTrialComplete(0, trial_name, GetCurrentRaidScore(), GetRaidDuration())
		end
	end
	if RaidTools.storage.modules.auto_polymorph then 
		if not RaidTools.IsSmallGroupRaid() then 
			RaidTools.ToggleRaidPolymorph(true) 
			if RaidTools.storage.config.jokes then
				RaidTools.RandomSkeletonJoke()
			end
		end
	end
	if RaidTools.storage.modules.buff_food_checker then EVENT_MANAGER:RegisterForUpdate('RaidToolsBuffFoodChecker', 5000, BuffFoodChecker) end
end

function RaidToolsModule_TrialCore.OnTrialExited()
	RaidToolsStatusBar.Hide()
	RaidToolsStatusBar.Stop()
	EVENT_MANAGER:UnregisterForUpdate('RaidToolsBuffFoodChecker')
	if RaidTools.storage.modules.auto_polymorph then 
		if not RaidTools.IsSmallGroupRaid() then RaidTools.DisableRaidPolymorph() end
	end
end

function RaidToolsModule_TrialCore.OnTrialStart(eventCode, trialName, weekly)
	local raid_id = RaidTools.trial.raid_id
	local raid_name = RaidTools.GetTrialName(raid_id)

	RaidTools.DebugMessage(string.format('OnTrialStart(%s, %s)', raid_name, tostring(weekly)))
	RaidTools.ForceResetResurrections()
	RaidTools.ForceResetDeaths()
	RaidTools.BrandedMessage('Started: ' .. raid_name)

	if RaidTools.trial.in_progress then
		RaidTools.ResetTrialInfo(true)
	end
	
	RaidTools.trial.target_time = GetRaidTargetTime()
	RaidTools.trial.started = true
	RaidTools.trial.in_progress = true
	if STATUS_BAR then STATUS_BAR:SetHidden(false) end
	RaidToolsStatusBar.Toggle(true)
	RaidToolsStatusBar.Start()
end

function RaidToolsModule_TrialCore.OnTrialFailed(eventCode, trialName, score)
	RaidTools.trial.in_progress = false
	RaidToolsStatusBar.Stop()
end

function RaidToolsModule_TrialCore.OnTrialComplete(eventCode, trialName, score, totalTime)
	local raid_id = RaidTools.trial.raid_id
	RaidTools.RetrieveLeaderboard(raid_id)
	RaidTools.trial.in_progress = false
	RaidToolsStatusBar.Stop()
	RaidToolsStatusBar.Update(true)
	RaidTools.BrandedMessage(RaidTools.GetTrialName().. ' completed with a score of '.. score ..' in '.. ZO_FormatTime(totalTime/1000))

	if RaidTools.storage.modules.raid_history and eventCode ~= 0 then
		local playerlist = {}--ZO_DeepTableCopy(RaidTools.deaths, playerlist)
		for _, name in pairs(RaidTools.GetGroupDisplayNames()) do
			if RaidTools.deaths[name] then
				playerlist[name] = RaidTools.deaths[name]
			else
				playerlist[name] = -1
			end
		end 

		table.insert(RaidTools.storage.raid_history, {
			raid_id = RaidTools.trial.raid_id,
			raid_name = trialName,
			char_name = NAME,
			time = totalTime,
			score = score,
			target_time_failed = RaidTools.trial.target_time_failed,
			speed_run_failed = RaidTools.trial.speed_run_failed,
			hard_mode = RaidTools.trial.hard_mode,
			hard_mode_param = RaidTools.trial.hard_mode_param,
			timestamp = GetTimeStamp(),
			deaths = RaidTools.TotalDeaths(),
			players = playerlist
			--players = RaidTools.GetGroupDisplayNames()
		})
		RaidTools.Message('Added to history.')
	end
	local highest_score = {score = 0, rank = 0, name = ''}
	for name, data in pairs(RaidTools.storage.alltime[raid_id]) do
		if data.score > highest_score.score then
			highest_score.score = data.score
			highest_score.rank = data.rank
			highest_score.name = name
		end
	end

	if highest_score.score > 0 and score > highest_score.score then
		RaidTools.BrandedMessage(string.format('You topped your current highest score (%s: %s) by %s (%s)', highest_score.name, highest_score.score, (score - highest_score.score), score))
	elseif highest_score.score == 0 then
		RaidTools.BrandedMessage(string.format('New high score for %s (%s)', trialName, score))
	end
	if RaidTools._leaderboards.alltime[raid_id] then
		if #RaidTools._leaderboards.alltime[raid_id] > 0 then
			for _, data in pairs(RaidTools._leaderboards.alltime[raid_id]) do
				if score > data.score then
					RaidTools.BrandedMessage(string.format('Your estimated position is ~%s', (data.rank)))
					break
				end
			end

			local entry = RaidTools._leaderboards.alltime[raid_id][1]
			if score > entry.score then
				RaidTools.BrandedMessage(string.format('You achieved the new high score in %s with a score of %s (Difference: +%s) (%s)', trialName, score, (score - entry.score) ,GetWorldName()))
			end
		else
			RaidTools.BrandedMessage(string.format('Your estimated leaderboard rank is 1'))
			RaidTools.BrandedMessage(string.format('You achieved the new high score in %s with a score of %s (%s)', trialName, score, GetWorldName()))
		end
	end
end

function RaidToolsModule_TrialCore.OnTrialVitalityUpdate(eventCode, current_bonus, delta)
	if not RaidTools.trial.in_progress then return end
	if ENABLED then
		local old = current_bonus + (delta * -1)
		RaidTools.BrandedMessage('|t22:22:/esoui/art/trials/vitalitydepletion.dds|t Vitality bonus decreased ('.. old .. '->'.. current_bonus ..')')
	end
end