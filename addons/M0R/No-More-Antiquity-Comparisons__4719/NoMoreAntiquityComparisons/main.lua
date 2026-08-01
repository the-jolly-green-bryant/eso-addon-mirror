SecurePostHook(ZO_AntiquityTileBase_Keyboard, "ShowTooltip", function(self)
	if self.tileData and self.rewardData and self.tileData:HasReward() and self.rewardData:GetRewardType() == REWARD_ENTRY_TYPE_ITEM then
		ItemTooltip:HideComparativeTooltips()
	end
end)