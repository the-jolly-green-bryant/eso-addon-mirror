function VEQ.CheckEndeavors()

	local RVEQ = RengarusAlternativeEndeavorTrackingForVEQ

	if not IsPlayerActivated() then return end
	if not RVEQ.baselineGot then zo_callLater(function () VEQ.CheckEndeavors() end, 1000) return end

	-- create table if it doesn't exist
	VEQ.MiniQuestList = VEQ.MiniQuestList or {}

	if not VEQ.SavedVars.Endeavor then return end

	local numActivities = GetNumTimedActivities() or 0

	if numActivities > 0 then

		local allDailies = ""
		local allWeeklies = ""
		local dailyTimeLimit = 0
		local weeklyTimeLimit = 0

		local highValueDailies = 0

		for index = 1, numActivities do
			--manipulate string to reflect progression
			local counter = 0
			if GetTimedActivityMaxProgress(index) ~= 1 then counter = GetTimedActivityProgress(index) end			
			local adjustedActivity
			if GetTimedActivityName(index):find("%d") then
				adjustedActivity = GetTimedActivityName(index):gsub("%d",""):gsub("  "," "..tostring(GetTimedActivityName(index):gsub("%D","") - counter).." ")
			else
				adjustedActivity = GetTimedActivityName(index)
			end

			--grabing current reward
			local currency, amount = GetTimedActivityRewardInfo(index)
			local currency2, amount2 = GetTimedActivityRewardInfo(index,2)

			if GetTimedActivityType(index) == TIMED_ACTIVITY_TYPE_DAILY then -- is daily endeavor
				dailyTimeLimit = GetTimeStamp() + GetTimedActivityTimeRemainingSeconds(index)
				if GetTimedActivityProgress(index) ~= GetTimedActivityMaxProgress(index) then
					local rewardData = REWARDS_MANAGER:GetInfoForReward(currency, amount)
					local icon = "|t12:12:"..rewardData:GetKeyboardIcon().."|t"
					if amount2 > RVEQ.dailyReward2 then -- higher than usual daily reward 2
						local rewardData2 = REWARDS_MANAGER:GetInfoForReward(currency2, amount2)
						local icon2 = "|t12:12:"..rewardData2:GetKeyboardIcon().."|t"
						if amount2 >= 1000 then
							amount2 = (amount2/1000).."K"
						end
						allDailies = string.format("|c00FF00%s|r", "• ".."["..amount..icon.." "..amount2..icon2.."] "..adjustedActivity).."\n"..allDailies
						highValueDailies = highValueDailies + 1
					elseif amount > RVEQ.dailyReward then -- higher than usual daily reward
						allDailies = string.format("|c00FF00%s|r", "• ".."["..amount..icon.."] "..adjustedActivity).."\n"..allDailies
						highValueDailies = highValueDailies + 1
					else
						allDailies = allDailies.."• "..adjustedActivity.."\n"
					end
				end
			else -- is not daily endeavor
				weeklyTimeLimit = GetTimeStamp() + GetTimedActivityTimeRemainingSeconds(index)
				if GetTimedActivityProgress(index) ~= GetTimedActivityMaxProgress(index) then
					local rewardData = REWARDS_MANAGER:GetInfoForReward(currency, amount)
					local icon = "|t12:12:"..rewardData:GetKeyboardIcon().."|t"
					if amount2 > RVEQ.weeklyReward2 then -- higher than usual weekly reward 2
						local rewardData2 = REWARDS_MANAGER:GetInfoForReward(currency2, amount2)
						local icon2 = "|t12:12:"..rewardData2:GetKeyboardIcon().."|t"
						if amount2 >= 1000 then
							amount2 = (amount2/1000).."K"
						end
						allWeeklies = string.format("|c00FF00%s|r", "["..amount..icon.." "..amount2..icon2.."] "..adjustedActivity).."\n"..allWeeklies
					elseif amount > RVEQ.weeklyReward then -- higher than usual weekly reward
						allWeeklies = string.format("|c00FF00%s|r", "["..amount..icon.."] "..adjustedActivity).."\n"..allWeeklies
					else
						allWeeklies = allWeeklies.."• "..adjustedActivity.."\n"
					end
				end
			end
		end

		local ActivityType = VEQ.mylanguage.lang_endeavor_day 
		local dailiesDone = GetNumTimedActivitiesCompleted(TIMED_ACTIVITY_TYPE_DAILY)
		local weekliesDone = GetNumTimedActivitiesCompleted(TIMED_ACTIVITY_TYPE_WEEKLY)

		-- determine if weekly is urgent
		local weeklyUrgent = false
		if weeklyTimeLimit - GetTimeStamp() <= 172800 and weekliesDone < 1 and highValueDailies < 1 then
			weeklyUrgent = true
		end

		--detrmine full reward string
		local fullRewardDaily
		if RVEQ.dailyReward2 == 0 then
			fullRewardDaily = "["..RVEQ.dailyReward..RVEQ.dailyIcon.."] "
		else
			local dailyReward2 = RVEQ.dailyReward2
			if dailyReward2 >= 1000 then
				dailyReward2 = (dailyReward2/1000).."K"
			end
			fullRewardDaily = "["..RVEQ.dailyReward..RVEQ.dailyIcon.." "..dailyReward2..RVEQ.dailyIcon2.."] "
		end
		local fullRewardWeekly
		if RVEQ.weeklyReward2 == 0 then
			fullRewardWeekly = "["..RVEQ.weeklyReward..RVEQ.weeklyIcon.."] "
		else
			local weeklyReward2 = RVEQ.weeklyReward2
			if weeklyReward2 >= 1000 then
				weeklyReward2 = (weeklyReward2/1000).."K"
			end
			fullRewardWeekly = "["..RVEQ.weeklyReward..RVEQ.weeklyIcon.." "..weeklyReward2..RVEQ.weeklyIcon2.."] "
		end

		--send miniquests
		if dailiesDone < 3 and weeklyUrgent == false then
			local timeLeft = ZO_FormatTimeMilliseconds(((dailyTimeLimit-GetTimeStamp())*1000), TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_TWELVE_HOUR)
			VEQ.LoadMiniQuestsInfo(8, "DailyEndeavors", fullRewardDaily..ActivityType.." "..dailiesDone.."/3", allDailies, GetString(SI_ACTIVITY_FINDER_CATEGORY_TIMED_ACTIVITIES).." "..timeLeft, "esoui/art/currency/gamepad/gp_currency_seals_of_endeavor_64.dds", nil, nil, nil, nil, dailyTimeLimit)
		else
			if VEQ.MiniQuestList["DailyEndeavors"] then VEQ.MiniQuestList["DailyEndeavors"] = nil end
			if VEQ.MiniQuestList then VEQ.updateTableLength(VEQ.MiniQuestList) end
		end

		local ActivityType = VEQ.mylanguage.lang_endeavor_week

		if weekliesDone < 1 and (dailiesDone > 2 or weeklyUrgent == true) then
			local timeLeft = ZO_FormatTimeMilliseconds(((weeklyTimeLimit-GetTimeStamp())*1000), TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_TWELVE_HOUR)
			VEQ.LoadMiniQuestsInfo(8, "WeeklyEndeavors", fullRewardWeekly..ActivityType, allWeeklies, GetString(SI_ACTIVITY_FINDER_CATEGORY_TIMED_ACTIVITIES).." "..timeLeft, "esoui/art/currency/gamepad/gp_currency_seals_of_endeavor_64.dds", nil, nil, nil, nil, weeklyTimeLimit)
		else
			if VEQ.MiniQuestList["WeeklyEndeavors"] then VEQ.MiniQuestList["WeeklyEndeavors"] = nil end
			if VEQ.MiniQuestList then VEQ.updateTableLength(VEQ.MiniQuestList) end
		end
		VEQ.DisplayFocusedMiniQuest()
	end
end