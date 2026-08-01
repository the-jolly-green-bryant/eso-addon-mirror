local function OnPlayerActivated()
	if IsUnitInDungeon("player") then
		local zoneIndex = GetUnitZoneIndex("player")
		local zoneName = GetZoneNameByIndex(zoneIndex)

		for i = 1, MAX_JOURNAL_QUESTS do
			local questName, _, _, _, _, _, tracked, _, _, questType = GetJournalQuestInfo(i)

			if questType == QUEST_TYPE_UNDAUNTED_PLEDGE and (GetJournalQuestStartingZone(i) == zoneIndex or string.match(questName, zoneName)) then
				if not tracked then
					FOCUSED_QUEST_TRACKER:ForceAssist(i)
				end

				break
			end
		end
	end
end

EVENT_MANAGER:RegisterForEvent("TrulyUndaunted", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)