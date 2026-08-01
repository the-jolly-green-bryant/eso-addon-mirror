local ProvTBQ = {
	name = "ProvisionsTheBestQuest"
}

local i2str = zo_strformat
local siAuto, siGiveUp = i2str(SI_QUICKCASTGROUNDABILITIESCHOICE2), i2str(SI_ABANDON_QUEST_CONFIRM)
local siTo = i2str(SI_GIFT_INVENTORY_KEYBOARD_HEADER_RECIPIENT):lower()
ZO_CreateStringId("SI_BINDING_NAME_THEBESTQUEST_GIVEUP", ("TBQuest - %s"):format(siGiveUp))
local siAll = i2str(SI_ITEMFILTERTYPE0):lower()
ZO_CreateStringId("SI_BINDING_NAME_THEBESTQUEST_TOGGLE", ("TBQuest - %s %s %s"):format(siAuto, siTo, siAll))
local siTarget = i2str(SI_BUFFS_OPTIONS_BUFFS_ENABLED_FOR_TARGET):lower()
ZO_CreateStringId("SI_BINDING_NAME_THEBESTQUEST_TARGET", ("TBQuest - %s %s %s"):format(siAuto, siTo, siTarget))

function ProvTBQ_GiveUp()
	ZO_QuestJournal_Manager:ConfirmAbandonQuest(QUEST_JOURNAL_MANAGER:GetFocusedQuestIndex())
end

local giveupList = {}

function ProvTBQ_Toggle()
	local state
	if not giveupList["all"] then
		state = SI_ADDONLOADSTATE2 --Activé
		giveupList["all"] = true
	else
		state = SI_ADDONLOADSTATE3 --Désactivé
		giveupList["all"] = false
	end
	d(("TBQuest - %s : %s %s %s"):format(siAuto, i2str(state), siTo, siAll))
end

function ProvTBQ_ToggleForTarget()
	local npcName = GetUnitName("reticleover") or GetUnitName("interact")

	if npcName == "" then
		return d("TBQuest - " .. zo_strformat(SI_DEATH_PROMPT_NO_SOUL_GEMS_PVP, siTarget))
	end

	local state
	if not giveupList[npcName] then
		state = SI_ADDONLOADSTATE2 --Activé
		giveupList[npcName] = true
	else
		state = SI_ADDONLOADSTATE3 --Désactivé
		giveupList[npcName] = false
	end

	d(("TBQuest - %s : %s %s %s"):format(siAuto, i2str(state), siTo, npcName))
end

local lastNpcName = ""
local function ProvTBQ_OnInteract(eventCode, journalIndex, questName, objectiveName)
	lastNpcName = GetUnitName("interact")

	local filter = ""
	if giveupList["all"] then
		filter = "all"
	elseif giveupList[lastNpcName] then
		filter = lastNpcName
	else
		return
	end

	d(("TBQuest - %s %s %s"):format(i2str(SI_ADDONLOADSTATE2), siTo, filter))
end

local function ProvTBQ_OnNewQuest(eventCode, journalIndex, questName, objectiveName)
	local npcName = lastNpcName or GetUnitName("interact") or GetUnitName("reticleover")

	if giveupList["all"] or giveupList[npcName] then
		ZO_QuestJournal_Manager:ConfirmAbandonQuest(journalIndex)
	end
end

local function ProvTBQ_OnAddOnLoad(eventCode, addOnName)
	if (ProvTBQ.name ~= addOnName) then return end

	EVENT_MANAGER:UnregisterForEvent(ProvTBQ.name, EVENT_ADD_ON_LOADED)

	SLASH_COMMANDS["/giveup"] = function()
		ProvTBQ_GiveUp()
	end
	SLASH_COMMANDS["/giveuplist"] = function()
		d(giveupList)
	end

	EVENT_MANAGER:RegisterForEvent(ProvTBQ.name, EVENT_CHATTER_BEGIN, ProvTBQ_OnInteract)
	EVENT_MANAGER:RegisterForEvent(ProvTBQ.name, EVENT_QUEST_ADDED, ProvTBQ_OnNewQuest)
end

EVENT_MANAGER:RegisterForEvent(ProvTBQ.name, EVENT_ADD_ON_LOADED, ProvTBQ_OnAddOnLoad)
