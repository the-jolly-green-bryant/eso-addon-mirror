CyroQuestManager = CyroQuestManager or {}
local CQM = CyroQuestManager
CQM.name = "CyroQuestManager"
CQM.author = "Scobster007"
CQM.svChar = {}
CQM.svCharDef = {
	Leader1 = "",
	Leader2 = "",
	AutoInv1 = "",
	AutoInv2 = "",
	AutoShare = true,
	x = 20,
	y = 20,
	r = 200,
	b = 300,
	bShowQuestMenu = true,
	bAutoDrop150 = false,
	bAutoDropTowns = false,
	bAutoDropClasses = false,
}

--Add '@' to the start of Username if not present.
function CQM.checkUsername(username)
	if string.sub(username, 1, 1) ~= "@" then
		return "@" .. username
	end
	return username
end

function CQM.SharePvPQuests(genericOnly)
	if CQM.isInCyrodiil() then
		for questIndex = 1, GetNumJournalQuests() do
			local questZone = GetJournalQuestType(questIndex)
			if questZone == QUEST_TYPE_AVA then
				if genericOnly then
					if CQM.isQuestGeneric(GetJournalQuestName(questIndex)) then
						CQM.shareQuest(questIndex)
					end
				else
					CQM.shareQuest(questIndex)
				end

			end
		end
	end
end

--Check to see if player is currently in a trial.
function CQM.inTrial()
	if IsPlayerInRaid(GetUnitName("player")) or IsPlayerInRaidStagingArea(GetUnitName("player")) then
		return true
	else
		return false
	end
end

 --Check to see if player is in Cyrodiil
function CQM.isInCyrodiil()
	if IsPlayerInAvAWorld() and not IsInImperialCity() and not IsActiveWorldBattleground() then
		return true
	else
		return false
	end
end

function CQM_ShareGenericCyrodiilQuests()
	CQM.SharePvPQuests(true)
end

function CQM_ShareAllCyrodiilQuests()
	CQM.SharePvPQuests(false)
end

function CQM.addonLoaded(event, addonName)
	if addonName ~= CQM.name then return end

	EVENT_MANAGER:UnregisterForEvent(CQM.name, EVENT_ADD_ON_LOADED)

	CQM.svChar = ZO_SavedVars:NewAccountWide("CyroQuestManagerVars", 1, nil, CQM.svCharDef, GetWorldName())
	CQM.initMenu()

	if CQM.svChar.AutoShare then
		EVENT_MANAGER:RegisterForEvent(CQM.name, EVENT_GROUP_MEMBER_JOINED, CQM.GroupMemberJoined)
	end



	--Make Window
	if CQM.svChar.bShowQuestMenu then
		CQM.makeQuestMenu()
	end

	EVENT_MANAGER:RegisterForEvent(CQM.name, EVENT_QUEST_ADDED, CQM.checkQuests)
	EVENT_MANAGER:RegisterForEvent(CQM.name, EVENT_QUEST_ADVANCED, CQM.checkQuests)
	EVENT_MANAGER:RegisterForEvent(CQM.name, EVENT_QUEST_COMPLETE, CQM.checkQuests)
	EVENT_MANAGER:RegisterForEvent(CQM.name, EVENT_QUEST_REMOVED, CQM.checkQuests)
	EVENT_MANAGER:RegisterForEvent(CQM.name, EVENT_QUEST_LIST_UPDATE, CQM.checkQuests)
	EVENT_MANAGER:RegisterForEvent(CQM.name, EVENT_PLAYER_ACTIVATED, CQM.zoneChange)
	

	EVENT_MANAGER:RegisterForEvent(CQM.name, EVENT_CHAT_MESSAGE_CHANNEL, CQM.receivedChatMessage)





	ZO_CreateStringId("SI_BINDING_NAME_CQM01", "Jump to Group 1")
	ZO_CreateStringId("SI_BINDING_NAME_CQM02", "Jump to Group 2")
	ZO_CreateStringId("SI_BINDING_NAME_CQM03", "Share Generic Cyrodiil Quests")
	ZO_CreateStringId("SI_BINDING_NAME_CQM04", "Share All Cyrodiil Quests")
end

EVENT_MANAGER:RegisterForEvent(CQM.name, EVENT_ADD_ON_LOADED, CQM.addonLoaded)
ZO_CreateStringId("SI_KEYBINDINGS_CATEGORY_CQM", "Cyro Quest Manager")