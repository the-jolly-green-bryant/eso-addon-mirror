function FPXI.poisonAlertLoop()
	local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.CHAMPION_POINTS_COMMITTED)
	params:SetText("|t50:50:/esoui/art/icons/crafting_poison_001_red_005.dds|tPOISONS ARE EMPTY")
	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
end