-- ZAM_Stats © ZAM Network LLC
-- All Rights Reserved

local GetNumJournalQuests = GetNumJournalQuests

local module, text = ZAM_Stats:CreateModule("Quests")


CALLBACK_MANAGER:RegisterCallback("ZAM_Stats_Modules_Ready", function()
	local em = EVENT_MANAGER
	local function UpdateTextOnEvent(event)
			ZAM_Stats:SetModuleText(text, GetNumJournalQuests().."/25", " Quests")
		end

	em:RegisterForEvent(module:GetName(), EVENT_QUEST_ADDED, UpdateTextOnEvent)
	em:RegisterForEvent(module:GetName(), EVENT_QUEST_REMOVED, UpdateTextOnEvent)
	
	UpdateTextOnEvent()
	
	CALLBACK_MANAGER:RegisterCallback("ZAM_Stats_Force_Refresh", UpdateTextOnEvent)
end)

--EVENT_QUEST_LIST_UPDATED
--EVENT_QUEST_ADVANCED
