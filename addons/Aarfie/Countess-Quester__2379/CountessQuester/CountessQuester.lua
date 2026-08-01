local LastItemClicked
ZO_PreHook(RETICLE, "TryHandlingInteraction", function()
	local _, name = GetGameCameraInteractableActionInfo()
	LastItemClicked = name
end)


local function FindCountessQuest(interaction)

	if GetZoneId(GetUnitZoneIndex("player")) ~= 821 then
		return
	end

	if LastItemClicked == "Tip Board" or LastItemClicked == "Brett für Aufträge" then

	local offeredText = string.sub(GetOfferedQuestInfo(), 2, 17)
	
	local matchFound = false
	local textBlocks = { "Esteemed thieves", "„Hochgeschätzt", "Some new faces a", "„Es gibt ein pa" }
	
	for text = 1, 4 do
		if string.find(textBlocks[text], offeredText) then
			matchFound = true
			break
		end
	end
	
	if not matchFound then
		interaction:CloseChatter()
	end
		
		LastItemClicked = nil
		
	end
	
end

EVENT_MANAGER:RegisterForEvent( name, EVENT_QUEST_OFFERED, function() FindCountessQuest(INTERACTION) end )




