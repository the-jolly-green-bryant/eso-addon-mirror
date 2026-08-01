--[[	Auto Daily Rewards - Notifications
	by SDPhantom
	http://www.esoui.com/forums/member.php?u=483	]]
----------------------------------------------------------

local function NotifyReward(id)
	local rewardid,qty=GetDailyLoginRewardInfoForCurrentMonth(id);
	local reward=REWARDS_MANAGER:GetInfoForDailyLoginReward(rewardid,qty);
	local link; if GetRewardType(rewardid)==REWARD_ENTRY_TYPE_ITEM then link=GetItemRewardItemLink(rewardid,qty); end
	CHAT_SYSTEM:AddMessage(("%s - %s"):format(
		GetString(SI_DAILY_LOGIN_REWARDS_CLAIMED_ANNOUNCEMENT)
		,link
		and	zo_strformat(qty>1 and SI_REWARDS_FORMAT_REWARD_WITH_AMOUNT or SI_TOOLTIP_ITEM_NAME,link,qty>1 and ZO_SELECTED_TEXT:Colorize(qty) or nil)
		or	reward[qty>1 and "GetFormattedNameWithStack" or "GetFormattedName"](reward)
	));
end

local Loaded,ClaimedID;
EVENT_MANAGER:RegisterForEvent("AutoDailyRewards_Notifications",EVENT_PLAYER_ACTIVATED,function()
	EVENT_MANAGER:UnregisterForEvent("AutoDailyRewards_Notifications",EVENT_PLAYER_ACTIVATED);
	if ClaimedID then NotifyReward(ClaimedID); end--	ChatSystem messages don't show before EVENT_PLAYER_ACTIVATED
	Loaded=true;
end);

EVENT_MANAGER:RegisterForEvent("AutoDailyRewards_Notifications",EVENT_DAILY_LOGIN_REWARDS_CLAIMED,function()
	local id=GetDailyLoginNumRewardsClaimedInMonth();
	if Loaded then NotifyReward(id);
	else ClaimedID=id; end
end);
