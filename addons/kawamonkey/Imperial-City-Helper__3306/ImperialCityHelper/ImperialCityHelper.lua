local imperialCityZoneIndex = GetZoneIndex(584)
local keepIds = {143, 146, 148, 142, 141, 147}
local orgGetJournalQuestInfo = GetJournalQuestInfo

-- add locations to quest names
function GetJournalQuestInfo(journalQuestIndex)
	local questName, backgroundText, activeStepText, activeStepType, activeStepTrackerOverrideText, completed, tracked, questLevel, pushed, questType, instanceDisplayType = orgGetJournalQuestInfo(journalQuestIndex)

	for i = 1, 6 do
		if questName == GetString("SI_ICQUESTMAIN", i) or questName == GetString("SI_ICQUESTSIDE", i) then
			questName = zo_strformat(SI_ICZONEQUEST, questName, GetString("SI_ICQUESTDISTRICT", i))
			break
		end
	end

	return questName, backgroundText, activeStepText, activeStepType, activeStepTrackerOverrideText, completed, tracked, questLevel, pushed, questType, instanceDisplayType
end

-- mark alliance control
ZO_PostHook(
	RETICLE,
	"TryHandlingInteraction",
	function (self, interactionPossible)
		if interactionPossible then
			self.interactContext:SetColor(ZO_SELECTED_TEXT:UnpackRGBA())

			if IsInImperialCity() then
				local name = select(2, GetGameCameraInteractableActionInfo())
				local lcName = string.lower(name)

				for i = 1, 6 do
					if lcName == zo_strformat("<<1>>", GetString("SI_ICLADDERDISTRICT", i)) then
						local alliance = GetKeepAlliance(keepIds[i], BGQUERY_LOCAL)
						local allianceColor = GetAllianceColor(alliance)
						local allianceIcon = ZO_GetAllianceIcon(alliance)

						self.interactContext:SetColor(allianceColor:UnpackRGBA())
						self.interactContext:SetText(zo_iconTextFormat(ZO_GetAllianceIcon(alliance), 32, 64, name))

						return
					end
				end
			end
		end
	end
)

-- update quest tracker
local function OnPlayerActivated()
	local zoneIndex, poiIndex = GetCurrentSubZonePOIIndices()

	if zoneIndex == imperialCityZoneIndex then
		for i = 1, MAX_JOURNAL_QUESTS do
			local questName, _, _, _, _, completed = orgGetJournalQuestInfo(i)

			if completed == false and select(3, GetJournalQuestLocationInfo(i)) == imperialCityZoneIndex and questName == GetString("SI_ICQUESTMAIN", poiIndex - 24) then
				FOCUSED_QUEST_TRACKER:ForceAssist(i)
				return
			end
		end

		for i = 1, MAX_JOURNAL_QUESTS do
			local questName, _, _, _, _, completed = orgGetJournalQuestInfo(i)

			if completed == false and select(3, GetJournalQuestLocationInfo(i)) == imperialCityZoneIndex and questName == GetString("SI_ICQUESTSIDE", poiIndex - 24) then
				FOCUSED_QUEST_TRACKER:ForceAssist(i)
				return
			end
		end
	end
end

EVENT_MANAGER:RegisterForEvent("ImperialCityHelper", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)