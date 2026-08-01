--[[	Auto Daily Rewards
	by SDPhantom
	http://www.esoui.com/forums/member.php?u=483	]]
----------------------------------------------------------

--------------------------
--[[	Main Function	]]
--------------------------
local ClaimedID;
local function CheckReward(silent)
	local id=GetDailyLoginClaimableRewardIndex();
	if id and id~=ClaimedID then--	Check if there's a claimable reward that hasn't been processed already
		if (silent and CheckInventorySpaceSilently or CheckInventorySpaceAndWarn)(GetNumInventorySlotsNeededForDailyLoginRewardInCurrentMonth(id)) then
			PlaySound(SOUNDS.DAILY_LOGIN_REWARDS_ACTION_CLAIM);
			ClaimCurrentDailyLoginReward();
			ClaimedID=id;--	Save ID
		end
	end
end

----------------------------------
--[[	Event/Callback Handlers	]]
----------------------------------
EVENT_MANAGER:RegisterForEvent("AutoDailyRewards",EVENT_PLAYER_ACTIVATED,function(_,init)
	EVENT_MANAGER:UnregisterForEvent("AutoDailyRewards",EVENT_PLAYER_ACTIVATED);
	if not init then CheckReward(false); end
end);

for _,event in ipairs({
	EVENT_DAILY_LOGIN_REWARDS_UPDATED;--	Fires on login and when rewards change (also fires every time there's a loading screen, as does EVENT_PLAYER_ACTIVATED)
	EVENT_NEW_DAILY_LOGIN_REWARD_AVAILABLE;--	Fires on reward available
	EVENT_DAILY_LOGIN_MONTH_CHANGED;--	Fires when month changes?
}) do EVENT_MANAGER:RegisterForEvent("AutoDailyRewards",event,function() return CheckReward(false); end); end

SCENE_MANAGER:RegisterCallback("SceneStateChanged",function(_,_,state)
	if state==SCENE_SHOWN then CheckReward(true); end
end);
