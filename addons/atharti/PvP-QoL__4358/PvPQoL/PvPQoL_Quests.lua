local PQ = PvPQoL

local ICON_SUCCESS = "PvPQoL/Textures/yes.dds"

-- =========================
-- Daily Quest Auto-Abandon
-- =========================
local IC_QUESTS_TO_ABANDON = {
	[5226] = true, --AD DK
	[6392] = true, --AD necro
	[5229] = true, --AD NB
	[5232] = true, --AD sorc
	[7066] = true, --AD arc
	[6010] = true, --AD warden
	[5220] = true, --AD templar

	[5221] = true, --DC templar
	[5233] = true, --DC sorc
	[5230] = true, --DC NB
	[7067] = true, --DC arc
	[5227] = true, --DC DK
	[6012] = true, --DC warden
	[6390] = true, --DC necro

	[5231] = true, --EP NB
	[5222] = true, --EP templar
	[5228] = true, --EP DK
	[6391] = true, --EP necro
	[7068] = true, --EP arc
	[5234] = true, --EP sorc
	[6011] = true, --EP warden
}

local IC_GOOD_QUESTS = {
	[4349] = true, --AD 20
	[2759] = true, --DC 20
	[3157] = true, --EP 20
}

local BG_QUESTS_TO_ABANDON = {
	[5954] = true, --1000 score
	[5953] = true, --5 matches
}

local BG_GOOD_QUEST_ID = 5952 --win a match

local CYRO_QUESTS_TO_ABANDON = {
	[6213] = true, --AD 150
	[6210] = true, --AD KEEPS
	[6212] = true, --AD TOWNS

	[6214] = true, --DC KEEPS
	[6216] = true, --DC TOWNS
	[6217] = true, --DC 150

	[6209] = true, --EP 150
	[3431] = true, --EP KEEPS
	[6207] = true, --EP TOWNS
}

local CYRO_GOOD_QUESTS = {
	[6211] = true, -- AD res
	[6215] = true, -- DC res
	[6208] = true, -- EP res
}

function PQ.OnQuestAdded(eventCode, journalQuestIndex)

	if PQ.suppressQuestHelpers then return end

	local questId = GetJournalQuestId(journalQuestIndex)
	if not questId then return end

	--/script d("Quest ID: " .. GetJournalQuestId(GetNumJournalQuests() - 0))

   -- ===================
	-- IC Quests
	-- ===================
	if PQ.SV.helpIC and not PQ.SV.todayIC then
		if IC_GOOD_QUESTS[questId] then
			PQ.SV.todayIC = true
			d(string.format("|cFFFFFF[AvA]|r |t20:20:%s|t", ICON_SUCCESS))
			return
		elseif IC_QUESTS_TO_ABANDON[questId] then
			if CanAbandonJournalQuest(journalQuestIndex) then
				AbandonQuest(journalQuestIndex)
			end
			return
		end
	end

	-- ===================
	-- BG Quests
	-- ===================
	if PQ.SV.helpBG and not PQ.SV.todayBG then
		if questId == BG_GOOD_QUEST_ID then
			PQ.SV.todayBG = true
			d(string.format("|cFFFFFF[BG]|r |t20:20:%s|t", ICON_SUCCESS))

			 -- zo_callLater(function()
				-- SCENE_MANAGER:ShowBaseScene()
			-- end, 50)
			EndInteraction(GetInteractionType())

			return
		elseif BG_QUESTS_TO_ABANDON[questId] then
			if CanAbandonJournalQuest(journalQuestIndex) then
				AbandonQuest(journalQuestIndex)

				 -- zo_callLater(function()
					-- SCENE_MANAGER:ShowBaseScene()
				-- end, 50)
				EndInteraction(GetInteractionType())

			end
			return
		end
	end
	-- ===================
	-- Cyrodiil Quests
	-- ===================
	if PQ.SV.helpCYRO and not PQ.SV.todayCYRO then
		if CYRO_GOOD_QUESTS[questId] then
			PQ.SV.todayCYRO = true
			d(string.format("|cFFFFFF[AvA]|r |t20:20:%s|t", ICON_SUCCESS))
			EndInteraction(GetInteractionType())
			return
		elseif CYRO_QUESTS_TO_ABANDON[questId] then
			if CanAbandonJournalQuest(journalQuestIndex) then
				AbandonQuest(journalQuestIndex)
				EndInteraction(GetInteractionType())
			end
			return
		end
	end
end