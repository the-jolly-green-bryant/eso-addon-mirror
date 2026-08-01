local function HookChatter(chatterData)
	local gold = chatterData.gold
	local itemCount, totalItemCount, itemValue, totalItemValue = 0, 0, 0, 0
	local kickbackPurchased = select(6, GetSkillAbilityInfo(SKILL_TYPE_WORLD, 2, 5))

	if kickbackPurchased then
		gold = ZO_SUCCEEDED_TEXT:Colorize(gold)
	end

	for slotIndex in ZO_IterateBagSlots(BAG_BACKPACK) do
		if IsItemStolen(BAG_BACKPACK, slotIndex) then
			itemCount = GetSlotStackSize(BAG_BACKPACK, slotIndex)
			itemValue = GetItemSellValueWithBonuses(BAG_BACKPACK, slotIndex) * itemCount

			totalItemCount = totalItemCount + itemCount
			totalItemValue = totalItemValue + itemValue
		end
	end

    chatterData.optionText = zo_strformat(
		SI_INTERACT_OPTION_PAY_BOUNTY_FORFEIT_ITEMS_COST,
		gold,
		totalItemCount,
		totalItemValue
	)

	return chatterData
end

local orgGetChatterOptionData = ZO_SharedInteraction.GetChatterOptionData
function ZO_SharedInteraction.GetChatterOptionData(...)
	local chatterData = orgGetChatterOptionData(...)

	return chatterData.optionText == "SI_INTERACT_OPTION_PAY_BOUNTY_FORFEIT_ITEMS" and HookChatter(chatterData) or chatterData
end

-- replace the forfeit string with a placeholder
EsoStrings[SI_INTERACT_OPTION_PAY_BOUNTY_FORFEIT_ITEMS] = "SI_INTERACT_OPTION_PAY_BOUNTY_FORFEIT_ITEMS"