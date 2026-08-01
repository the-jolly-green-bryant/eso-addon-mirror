RengarusAlternativeEndeavorTrackingForVEQ = {}
RengarusAlternativeEndeavorTrackingForVEQ.name = "RengarusAlternativeEndeavorTrack" -- name too long RIP

local RVEQ = RengarusAlternativeEndeavorTrackingForVEQ

RVEQ.baselineGot = false

local function GetBaselineRewards()
	RVEQ.dailyReward = 100000
	RVEQ.dailyReward2 = 100000
	RVEQ.weeklyReward = 1000000
	RVEQ.weeklyReward2 = 1000000
	local numActivities = GetNumTimedActivities() or 0
	for index = 1, numActivities do
		local currency, amount = GetTimedActivityRewardInfo(index)
		local currency2, amount2 = GetTimedActivityRewardInfo(index,2)
		if GetTimedActivityType(index) == TIMED_ACTIVITY_TYPE_DAILY then
			--1
			RVEQ.dailyReward = math.min(RVEQ.dailyReward,amount)
			local dailyRewardData = REWARDS_MANAGER:GetInfoForReward(currency, amount)
			RVEQ.dailyIcon = "|t12:12:"..dailyRewardData:GetKeyboardIcon().."|t"
			--2
			RVEQ.dailyReward2 = math.min(RVEQ.dailyReward2,amount2)
			if RVEQ.dailyReward2 ~= 0 then
				local dailyRewardData2 = REWARDS_MANAGER:GetInfoForReward(currency2, amount2)
				RVEQ.dailyIcon2 = "|t12:12:"..dailyRewardData2:GetKeyboardIcon().."|t"
			end
		else
			--1
			RVEQ.weeklyReward = math.min(RVEQ.weeklyReward,amount)
			local weeklyRewardData = REWARDS_MANAGER:GetInfoForReward(currency, amount)
			RVEQ.weeklyIcon = "|t12:12:"..weeklyRewardData:GetKeyboardIcon().."|t"
			--2
			RVEQ.weeklyReward2 = math.min(RVEQ.weeklyReward2,amount2)
			if RVEQ.weeklyReward2 ~= 0 then
				local weeklyRewardData2 = REWARDS_MANAGER:GetInfoForReward(currency2, amount2)
				RVEQ.weeklyIcon2 = "|t12:12:"..weeklyRewardData2:GetKeyboardIcon().."|t"
			end
		end
	end
	RVEQ.baselineGot = true
end

local function OnAddOnLoaded(event, addonName)
	if addonName == RVEQ.name then
		EVENT_MANAGER:UnregisterForEvent(RVEQ.name, EVENT_ADD_ON_LOADED)
		EVENT_MANAGER:RegisterForEvent(RVEQ.name, EVENT_PLAYER_ACTIVATED, GetBaselineRewards)
	end
end

EVENT_MANAGER:RegisterForEvent(RVEQ.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)