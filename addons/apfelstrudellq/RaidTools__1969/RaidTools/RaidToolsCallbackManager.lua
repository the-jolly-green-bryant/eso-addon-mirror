RaidToolsCBM = {}
function RaidToolsCBM.Init()
	-- Player load
	EVENT_MANAGER:RegisterForEvent(RaidTools.name, EVENT_PLAYER_ACTIVATED, RaidToolsCBM.OnPlayerLoaded)

	-- Leaderboard data handling
	EVENT_MANAGER:RegisterForEvent(RaidTools.name, EVENT_RAID_LEADERBOARD_DATA_CHANGED, RaidToolsCBM.OnLeaderboardDataAvailable)

	-- Group events
	EVENT_MANAGER:RegisterForEvent(RaidTools.name, EVENT_GROUP_MEMBER_JOINED, RaidToolsCBM.OnGroupMemberJoined)
	EVENT_MANAGER:RegisterForEvent(RaidTools.name, EVENT_GROUP_MEMBER_LEFT, RaidToolsCBM.OnGroupMemberLeft)

	EVENT_MANAGER:RegisterForEvent(RaidTools.name, EVENT_GROUP_ELECTION_REQUESTED, 	RaidToolsCBM.OnGroupElectionRequested)
	EVENT_MANAGER:RegisterForEvent(RaidTools.name, EVENT_GROUP_ELECTION_RESULT, 	RaidToolsCBM.OnGroupElectionResult)
	EVENT_MANAGER:RegisterForEvent(RaidTools.name, EVENT_GROUP_ELECTION_FAILED, 	RaidToolsCBM.OnGroupElectionFailed)
	EVENT_MANAGER:RegisterForEvent(RaidTools.name, EVENT_GROUP_ELECTION_NOTIFICATION_ADDED, 	RaidToolsCBM.OnGroupElectionNotifAdded)
	EVENT_MANAGER:RegisterForEvent(RaidTools.name, EVENT_GROUP_ELECTION_NOTIFICATION_REMOVED, 	RaidToolsCBM.OnGroupElectionNotifRemoved)

	-- Death events
	EVENT_MANAGER:RegisterForEvent(RaidTools.name, EVENT_UNIT_DEATH_STATE_CHANGED, RaidToolsCBM.OnDeathStateChanged)
	EVENT_MANAGER:RegisterForEvent(RaidTools.name, EVENT_RESURRECT_RESULT, RaidToolsCBM.OnResurrectResult)

	-- Trial events
	EVENT_MANAGER:RegisterForEvent(RaidTools.name, EVENT_RAID_TRIAL_STARTED, RaidToolsCBM.OnTrialStart)
	EVENT_MANAGER:RegisterForEvent(RaidTools.name, EVENT_RAID_TRIAL_COMPLETE, RaidToolsCBM.OnTrialComplete)
	EVENT_MANAGER:RegisterForEvent(RaidTools.name, EVENT_RAID_TRIAL_FAILED, RaidToolsCBM.OnTrialFailed)
	EVENT_MANAGER:RegisterForEvent(RaidTools.name, EVENT_RAID_REVIVE_COUNTER_UPDATE, RaidToolsCBM.OnTrialVitalityUpdate)

	-- Items
	EVENT_MANAGER:RegisterForEvent(RaidTools.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, RaidToolsCBM.OnInventorySlotUpdate)
	EVENT_MANAGER:RegisterForEvent(RaidTools.name, EVENT_LOOT_RECEIVED, RaidToolsCBM.OnLootReceived)

	-- Combat
	EVENT_MANAGER:RegisterForEvent(RaidTools.name, EVENT_COMBAT_EVENT, RaidToolsCBM.OnCombatEvent)
	EVENT_MANAGER:RegisterForEvent(RaidTools.name, EVENT_EFFECT_CHANGED, RaidToolsCBM.OnEffectChanged)
	EVENT_MANAGER:RegisterForEvent(RaidTools.name, EVENT_BOSSES_CHANGED, RaidToolsCBM.OnBossesChanged)
	EVENT_MANAGER:RegisterForEvent(RaidTools.name, EVENT_POWER_UPDATE, RaidToolsCBM.OnPowerUpdate)
	EVENT_MANAGER:RegisterForEvent(RaidTools.name, EVENT_PLAYER_COMBAT_STATE, RaidToolsCBM.OnCombatStateChange)
	EVENT_MANAGER:RegisterForEvent(RaidTools.name, EVENT_PLAYER_ALIVE, RaidToolsCBM.OnPlayerAlive)
	EVENT_MANAGER:RegisterForEvent(RaidTools.name, EVENT_PLAYER_REINCARNATED, RaidToolsCBM.OnPlayerReincarnated)
	

	-- Merchent
	EVENT_MANAGER:RegisterForEvent(RaidTools.name, EVENT_OPEN_STORE, RaidToolsCBM.OnStoreOpened)
	
	CALLBACK_MANAGER:RegisterCallback('OnWorldMapChanged', RaidToolsCBM.OnWorldMapChanged)
end

function RaidToolsCBM.OnWorldMapChanged()
	local zone_id = RaidTools.GetMyZone()
	local is_trial = RaidTools.IsTrialZone(zone_id)
	RaidTools.DebugMessage(string.format('OnWorldMapChanged(%s, %s)',  GetUnitZone('player'), zone_id))
	if IsUnitInDungeon('player') then
		if not RaidTools.current_instance then
			RaidToolsCBM.OnDungeonEntered(zone_id, is_trial)
			RaidTools.current_instance = zone_id
		elseif RaidTools.current_instance ~= zone_id then
			RaidToolsCBM.OnDungeonExited(RaidTools.current_instance)
			RaidToolsCBM.OnDungeonEntered(zone_id, is_trial)
			RaidTools.current_instance = zone_id
		end
	else
		if RaidTools.current_instance then
			RaidToolsCBM.OnDungeonExited(RaidTools.current_instance)
			RaidTools.current_instance = nil
		end
	end
end

function RaidToolsCBM.OnDungeonEntered(zone_id, is_trial)
	RaidTools.DebugMessage(string.format('OnDungeonEntered(%s (%s), %s)', zone_id, GetZoneNameById(zone_id), tostring(is_trial)))
	if is_trial then
		if RaidToolsModule_TrialCore then
			RaidToolsModule_TrialCore.OnTrialEntered()
		end

		if RaidToolsModule_GroupOverlay then
			RaidToolsModule_GroupOverlay.OnTrialEntered()
			RaidToolsModule_GroupOverlay.UpdateHeaders()
		end
	end
end

function RaidToolsCBM.OnDungeonExited(zone_id)
	RaidTools.DebugMessage(string.format('OnDungeonExited(%s (%s))',  zone_id, GetZoneNameById(zone_id)))
	if RaidTools.IsTrialZone(zone_id) then
		if RaidToolsModule_TrialCore then
			RaidToolsModule_TrialCore.OnTrialExited()
		end

		if RaidToolsModule_GroupOverlay then
			RaidToolsModule_GroupOverlay.OnTrialExited()
			RaidToolsModule_GroupOverlay.UpdateHeaders()
		end
	end
end

local inital_parse = true
local initial = false

local function WeeklyInfo()
	if not inital_parse then return end
	local until_end = RaidTools.GetWeeklyTime(true)
	local message = ''

	inital_parse = false
	EVENT_MANAGER:UnregisterForEvent(RaidTools.name, EVENT_PLAYER_ACTIVATED)
	if RaidToolsModules_AutoRecharge then
		RaidToolsModules_AutoRecharge.Init()
	end

	if RaidTools.CheckWeeklyOver() then 
		if not RaidTools.storage.weekly.summary_displayed then 
			if until_end == 0 then
				RaidTools.PerformWeeklyCheck()
			end

			if next(RaidTools.storage.weekly.trial.characters) then
				message = message .. ' # ' .. RaidTools.GetTrialName(RaidTools.storage.weekly.trial.raid_id) .. '\n'
				for name, data in pairs(RaidTools.storage.weekly.trial.characters) do
					message = message .. ' - ' .. name .. ' ('.. data.score .. ' / Rank: '.. data.rank ..')\n'
				end
			end
			if next(RaidTools.storage.weekly.challenge.characters) then
				message = message .. '\n # ' .. RaidTools.GetTrialName(RaidTools.storage.weekly.challenge.raid_id) .. '\n'
				for name, data in pairs(RaidTools.storage.weekly.challenge.characters) do
					message = message .. ' - ' .. name .. ' ('.. data.score .. ' / Rank: '.. data.rank ..')\n'
				end
			end
			RaidTools.storage.weekly.summary_displayed = true
			RaidTools.storage.weekly.new_weekly_info_displayed = false
		end

		if until_end > 0 then
			RaidTools.SetWeeklyEndDate()
			RaidTools.UpdateWeeklyInfo()
			RaidTools.ResetWeeklyData()
		end
	else
		RaidTools.PerformWeeklyCheck()
	end

	RaidTools.PerformLeaderboardCheck()

	if not RaidTools.storage.modules.weekly_info then return end
	if message:len() > 0 then
		ShowMessageBox('rt_weekly_summary', 'RaidTools - Weekly report 1/2', message, 'Ok', RaidTools.OnWeeklySummaryRead)
	else
		if not RaidTools.storage.weekly.new_weekly_info_displayed and until_end > 0 then
			RaidTools.storage.weekly.new_weekly_info_displayed = true
			message = 'Weekly trial: ' .. RaidTools.GetTrialName(RaidTools.storage.weekly.trial.raid_id) .. '\nWeekly challenge: ' .. RaidTools.GetTrialName(RaidTools.storage.weekly.challenge.raid_id)
			RaidTools.DebugMessage(message)

			ShowMessageBox('rt_weekly_news', 'RaidTools - Weekly trial info', message, 'Ok', RaidTools.OnWeeklyNewsRead)
		elseif next(RaidTools.notifications) then
			RaidTools.DebugMessage('notifications_message_box') -- currently unused
		end
	end
end

function RaidToolsCBM.OnPlayerLoaded( ... )
	RaidTools.GetWeeklyTime()
	if not initial then
		zo_callLater(function ()
		local version = RaidTools.parse_game_version()
			RaidTools.is_game_up_to_date()
			RaidTools.BrandedMessage(string.format('Loaded. (RaidTools: %s / ESO: %s.%s.%s)', RaidTools.version, version.major, version.minor, version.release))
			if has_value(RaidTools._tester, UID) then
				--RaidTools.Announcement('|c'.. CLR.cancer.hex ..'semper fidelis')
			end
		end, 1000)
		initial = true
	end
end

function RaidToolsCBM.OnLeaderboardDataAvailable( ... )
	RaidTools.DebugMessage('Leaderboard data available...')
	RaidTools.leaderboard_info_update = GetTimeStamp()
	--RaidToolsCBM.OnPlayerLoaded() -- artificially trigger this, to make sure leaderboard info gets displayed directly when data is available
	zo_callLater(function ()
		WeeklyInfo()
	end, 500)
end

--
-- Forwarding...
--

function RaidToolsCBM.OnGroupMemberJoined( ... )
	if RaidToolsGroup then
		RaidToolsGroup.OnJoin(...)
	end
end

function RaidToolsCBM.OnGroupMemberLeft( ... )
	if RaidToolsGroup then
		RaidToolsGroup.OnLeave(...)
	end
end

function RaidToolsCBM.OnGroupElectionNotifAdded( ... )
	if RaidToolsModule_GroupOverlay then
		RaidToolsModule_GroupOverlay.OnGroupElectionStarted(...)
	end
end

function RaidToolsCBM.OnGroupElectionNotifRemoved( ... )
	if RaidToolsModule_GroupOverlay then
		RaidToolsModule_GroupOverlay.OnGroupElectionEnded(...)
	end
end

function RaidToolsCBM.OnGroupElectionRequested( ... )
	if RaidToolsModule_GroupOverlay then
		RaidToolsModule_GroupOverlay.OnGroupElectionRequested(...)
	end
end

function RaidToolsCBM.OnGroupElectionResult( ... )
	if RaidToolsModule_GroupOverlay then
		RaidToolsModule_GroupOverlay.OnGroupElectionResult(...)
	end
end

function RaidToolsCBM.OnGroupElectionFailed( ... )
	if RaidToolsModule_GroupOverlay then
		RaidToolsModule_GroupOverlay.OnGroupElectionFailed(...)
	end
end

function RaidToolsCBM.OnDeathStateChanged( ... )
	if RaidToolsModule_DeathCounter then
		RaidToolsModule_DeathCounter.OnDeathStateChange(...)
	end
	if RaidToolsModule_DeathRecap then
		RaidToolsModule_DeathRecap.OnDeathStateChange(...)
	end
	if RaidToolsModule_DeathAlert then
		RaidToolsModule_DeathAlert.OnDeathStateChange(...)
	end
end

function RaidToolsCBM.OnResurrectResult( ... )
	if RaidToolsModule_DeathCounter then
		RaidToolsModule_DeathCounter.OnResurrectResult(...)
	end
end

function RaidToolsCBM.OnTrialStart( ... )
	if RaidToolsModule_TrialCore then
		RaidToolsModule_TrialCore.OnTrialStart(...)
	end
	if RaidToolsStatusBar then
		RaidToolsStatusBar.OnTrialStart(...)
	end
end

function RaidToolsCBM.OnTrialComplete( ... )
	if RaidToolsModule_TrialCore then
		RaidToolsModule_TrialCore.OnTrialComplete(...)
	end
end

function RaidToolsCBM.OnTrialFailed( ... )
	if RaidToolsModule_TrialCore then
		RaidToolsModule_TrialCore.OnTrialFailed(...)
	end
end

function RaidToolsCBM.OnTrialVitalityUpdate( ... )
	if RaidToolsModule_TrialCore then
		RaidToolsModule_TrialCore.OnTrialVitalityUpdate(...)
	end
end

function RaidToolsCBM.OnInventorySlotUpdate( ... )
	if RaidToolsModules_AutoRecharge then
		RaidToolsModules_AutoRecharge.OnInventorySlotUpdate(...)
	end
end

function RaidToolsCBM.OnLootReceived( ... )
	if RaidToolsModules_GroupLootAnnounce then
		RaidToolsModules_GroupLootAnnounce.OnLootReceived(...)
	end
end

function RaidToolsCBM.OnEffectChanged( ... )
	if RaidToolsAsylum then
		RaidToolsAsylum.OnEffectChanged(...)
	end
	if RaidToolsGroupBuffs then
		RaidToolsGroupBuffs.OnEffectChanged(...)
	end
	if RaidToolsModule_GroupOverlay then
		RaidToolsModule_GroupOverlay.OnEffectChanged(...)
	end
	if RaidToolsSyCD then
		RaidToolsSyCD.OnEffectChanged(...)
	end
end

function RaidToolsCBM.OnCombatEvent( ... )
	if RaidToolsAsylum then
		RaidToolsAsylum.OnCombatEvent(...)
	end
	if RaidToolsModule_GroupOverlay then
		RaidToolsModule_GroupOverlay.OnCombatEvent(...)
	end
	if RaidToolsSyCD then
		RaidToolsSyCD.OnCombatEvent(...)
	end
end

function RaidToolsCBM.OnBossesChanged( ... )

end

function RaidToolsCBM.OnPowerUpdate(_, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffMax)

end

function RaidToolsCBM.OnCombatStateChange( ... )

end

function RaidToolsCBM.OnStoreOpened( ... )
	if RaidToolsModules_AutoRecharge then
		RaidToolsModules_AutoRecharge.OnStoreOpened(...)
	end
end

function RaidToolsCBM.OnPlayerAlive(...)

end

function RaidToolsCBM.OnPlayerReincarnated(...)
	if RaidToolsModules_AutoRecharge then
		RaidToolsModules_AutoRecharge.OnPlayerReincarnated(...)
	end
end