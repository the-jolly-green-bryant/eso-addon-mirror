---
--- Created by YeOldeDragon.
--- DateTime: 2021-03-24 08:53
---
YeOldeQuest = {}

--- Short name for YeOldeInfos.CraftingQuestStatus
local STATUS = YeOldeInfos.CraftingQuestStatus

YeOldeQuest.SV = {}

local DEFAULT_TOOLTIP_WIDTH = 400
local RESET_TIME_UTC = 6
local HOURS_IN_DAY = 24
local SECONDS_IN_HOUR = 60 * 60
local SECONDS_IN_DAY = 60 * 60 * 24

local DEFAULT_UPDATE_TIME = 60000 -- update every minute
local EVENT_NAMESPACE = YeOldeInfos.AddonName .. "CraftingQuests"

--- Tooltip header colors used
local HEADER_COLORS = {
	[STATUS.UNAVAILABLE] = YeOldeInfos.Colors.DISABLED,
	[STATUS.AVAILABLE] = YeOldeInfos.Colors.GREEN,
	[STATUS.ACTIVE] = YeOldeInfos.Colors.GREEN,
	[STATUS.READY_TO_DELIVER] = YeOldeInfos.Colors.GREEN,
	[STATUS.COMPLETED] = YeOldeInfos.Colors.BLUE,
	[STATUS.UNKNOWN] = YeOldeInfos.Colors.DISABLED,
}

--- Crafting types array
local CRAFTING_TYPE = {
	CRAFTING_TYPE_BLACKSMITHING,
	CRAFTING_TYPE_CLOTHIER,
	CRAFTING_TYPE_ENCHANTING,
	CRAFTING_TYPE_ALCHEMY,
	CRAFTING_TYPE_PROVISIONING,
	CRAFTING_TYPE_WOODWORKING,
	CRAFTING_TYPE_JEWELRYCRAFTING,
}

--- Crafting Certification ids and criterion index for daily writ crafting
local WRIT_CERTIFICATION = {
	[CRAFTING_TYPE_BLACKSMITHING] = { Id = 1145, CritId = 2 },
	[CRAFTING_TYPE_CLOTHIER] = { Id = 1145, CritId = 3 },
	[CRAFTING_TYPE_ENCHANTING] = { Id = 1145, CritId = 4 },
	[CRAFTING_TYPE_ALCHEMY] = { Id = 1145, CritId = 1 },
	[CRAFTING_TYPE_PROVISIONING] = { Id = 1145, CritId = 5 },
	[CRAFTING_TYPE_WOODWORKING] = { Id = 1145, CritId = 6 },
	[CRAFTING_TYPE_JEWELRYCRAFTING] = { Id = 2225, CritId = 1 },
}

--- Current Quest journal index.  0 if not active.
local WritQuestJournalIndex = {}

--- Current quest status for each crafting writ
local WritQuestStatus = {}

local WritQuestResetHour = 0

local function YeOldeQuest_FireEvent(craftingType)
	CALLBACK_MANAGER:FireCallbacks("YeOldeQuestStateChanged", craftingType, WritQuestStatus[craftingType])
end

local function YeOldeQuest_GetRemainingTime()
	local timeRemaining = TIMED_ACTIVITIES_MANAGER:GetTimedActivityTypeTimeRemainingSeconds(TIMED_ACTIVITY_TYPE_DAILY)
	return ZO_FormatTime(
		timeRemaining,
		TIME_FORMAT_STYLE_SHOW_LARGEST_TWO_UNITS,
		TIME_FORMAT_PRECISION_SECONDS,
		TIME_FORMAT_DIRECTION_DESCENDING
	)
end

local function YeOldeQuest_SetWritQuestResetHour()
	local hoursRemaining = math.ceil(
		TIMED_ACTIVITIES_MANAGER:GetTimedActivityTypeTimeRemainingSeconds(TIMED_ACTIVITY_TYPE_DAILY) / SECONDS_IN_HOUR
	)
	local currentTime = math.floor(GetSecondsSinceMidnight() / SECONDS_IN_HOUR)

	WritQuestResetHour = hoursRemaining + currentTime
	-- d("tWritQuestResetHour:"..WritQuestResetHour..", hoursRemaining:"..hoursRemaining..", currentTime:"..currentTime)

	if WritQuestResetHour > HOURS_IN_DAY then
		WritQuestResetHour = WritQuestResetHour - HOURS_IN_DAY
	end
end

function YeOldeQuest.ShowTooltip(control, craftingType)
	local questStatus = WritQuestStatus[craftingType]
	local header = YeOldeInfos.QUEST_NAME[craftingType] or "?"
	local status = (questStatus and YeOldeInfos.STATES[questStatus]) or "..."
	local statusColor = (questStatus and HEADER_COLORS[questStatus]) or YeOldeInfos.Colors.DISABLED
	local handler = InformationTooltip

	InitializeTooltip(handler)
	ZO_Tooltips_SetupDynamicTooltipAnchors(handler, control)
	handler:SetDimensionConstraints(DEFAULT_TOOLTIP_WIDTH, 0, 0, 0)

	handler:AddHeaderLine(
		header,
		"ZoFontTooltipTitle",
		1,
		TOOLTIP_HEADER_SIDE_LEFT,
		ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB()
	)
	handler:AddHeaderLine(status, "ZoFontTooltipTitle", 2, TOOLTIP_HEADER_SIDE_RIGHT, statusColor:UnpackRGB())

	local timeRemaining = YeOldeQuest_GetRemainingTime()
	handler:AddLine(
		zo_strformat(SI_TIMED_ACTIVITIES_ACTIVITY_EXPIRATION_HEADER, ZO_SELECTED_TEXT:Colorize(timeRemaining)),
		"ZoFontGame",
		ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB()
	)

	local journalIndex = WritQuestJournalIndex[craftingType]
	if journalIndex > 0 then
		local maxLength = 0
		for condition = 1, GetJournalQuestNumConditions(journalIndex, 1) do
			local conditionText, _, _, _, _ = GetJournalQuestConditionInfo(journalIndex, 1, condition)
			if conditionText ~= nil and conditionText ~= "" then
				if #conditionText > maxLength then
					maxLength = #conditionText
				end
				local color = ZO_WHITE:UnpackRGB()
				local numColor = YeOldeInfos.Colors.WHITE:ToHex()

				local numDone = conditionText:match("(%d)/")
				local numTodo = conditionText:match("/(%d)")
				if numDone ~= nil and numTodo ~= nil then
					if numDone == numTodo then
						numColor = YeOldeInfos.Colors.GREEN:ToHex()
					else
						numColor = YeOldeInfos.Colors.GOLD:ToHex()
					end
					conditionText = conditionText:gsub("(%d/%d)", "|c" .. numColor .. "%1|r")
				end
				handler:AddLine(conditionText, "ZoFontGame", color)
			end
		end
	end

	ZO_Tooltip_AddDivider(handler)
	handler:AddLine("|cDA8A00" .. GetString(SI_YEOLDEINFOS_MATERIALS) .. "|r", "ZoFontGameMedium", 1, 1, 1)
	local lines = YeOldeCraftingInventory:GetTooltipLines(craftingType)
	for i = 1, #lines do
		handler:AddLine(lines[i])
	end
end

local function YeOldeQuest_CheckIfReadyToDeliver(cond_text)
	if cond_text ~= nil and zo_strfind(cond_text, YeOldeInfos.COND_DELIVER) then
		return true
	end
	return false
end

local function YeOldeQuest_CheckCertification(type)
	local _, completed, _ = GetAchievementCriterion(WRIT_CERTIFICATION[type].Id, WRIT_CERTIFICATION[type].CritId)
	return completed
end

local function YeOldeQuest_CheckIfCompleted(type)
	local lastCompletedDate = tonumber(YeOldeQuest.SV.LastCompletedDate[type])
	local lastCompletedHour = tonumber(YeOldeQuest.SV.LastCompletedHour[type])
	local now = GetDate()
	local todayHour = math.floor(GetSecondsSinceMidnight() / SECONDS_IN_HOUR)
	local dayDiff = now - lastCompletedDate

	-- d("type:"..YeOldeInfos.QUEST_NAME[type]..", todayHour:"..todayHour..", lastCompleteHour:"..lastCompletedHour..", daydiff:"..dayDiff..", resetHour:"..WritQuestResetHour)
	if dayDiff == 0 and (lastCompletedHour >= WritQuestResetHour or todayHour < WritQuestResetHour) then
		return true
	end
	if dayDiff == 1 and (lastCompletedHour >= WritQuestResetHour and todayHour < WritQuestResetHour) then
		return true
	end

	return false
end

function YeOldeQuest.QuestCompleted(type)
	return YeOldeQuest_CheckIfCompleted(type)
end

local function YeOldeQuest_UpdateQuestState(type)
	local journalIndex = WritQuestJournalIndex[type]

	if journalIndex == 0 then
		if tonumber(YeOldeQuest.SV.LastCompletedDate[type]) == 0 then
			WritQuestStatus[type] = STATUS.UNKNOWN
		elseif YeOldeQuest_CheckIfCompleted(type) then
			WritQuestStatus[type] = STATUS.COMPLETED
		elseif YeOldeQuest_CheckCertification(type) then
			WritQuestStatus[type] = STATUS.AVAILABLE
		else
			WritQuestStatus[type] = STATUS.UNAVAILABLE
		end
	else
		WritQuestStatus[type] = STATUS.ACTIVE
		for condition = 1, GetJournalQuestNumConditions(journalIndex, 1) do
			local conditionText, _, _, _, _ = GetJournalQuestConditionInfo(journalIndex, 1, condition)
			if YeOldeQuest_CheckIfReadyToDeliver(conditionText) then
				WritQuestStatus[type] = STATUS.READY_TO_DELIVER
			end
		end
	end

	-- If the state changed, we fire the event
	YeOldeQuest_FireEvent(type)
end

local function YeOldeQuest_LoadActiveWritQuests()
	for journalIndex = 1, MAX_JOURNAL_QUESTS do
		local questName = GetJournalQuestName(journalIndex)
		local type = YeOldeInfos.QUEST_NAME[questName]
		if type ~= nil then
			WritQuestJournalIndex[type] = journalIndex
			YeOldeQuest_UpdateQuestState(type)
		end
	end
end

local function YeOldeQuest_QuestAdded(_, journalIndex, questName, _)
	local type = YeOldeInfos.QUEST_NAME[questName]
	if type ~= nil then
		WritQuestJournalIndex[type] = journalIndex
		YeOldeQuest_UpdateQuestState(type)
	end
end

local function YeOldeQuest_QuestCompleted(_, questName, _, _, _, _, _, _)
	local type = YeOldeInfos.QUEST_NAME[questName]
	if type ~= nil then
		WritQuestJournalIndex[type] = 0
		WritQuestStatus[type] = STATUS.COMPLETED
		YeOldeQuest.SV.LastCompletedDate[type] = GetDate()
		YeOldeQuest.SV.LastCompletedHour[type] = math.floor(GetSecondsSinceMidnight() / SECONDS_IN_HOUR)
		YeOldeQuest_FireEvent(type)
	end
end

local function YeOldeQuest_QuestRemoved(_, isCompleted, _, questName, _, _, _)
	local type = YeOldeInfos.QUEST_NAME[questName]
	if type == nil or isCompleted then
		return
	end

	WritQuestJournalIndex[type] = 0
	WritQuestStatus[type] = STATUS.AVAILABLE
	YeOldeQuest_FireEvent(type)
end

local function YeOldeQuest_QuestCondition_Changed(_, _, questName)
	local type = YeOldeInfos.QUEST_NAME[questName]
	if type ~= nil then
		YeOldeQuest_UpdateQuestState(type)
	end
end

local function YeOldeQuest_Update()
	for type = 1, #CRAFTING_TYPE do
		YeOldeQuest_UpdateQuestState(CRAFTING_TYPE[type])
	end
end

function YeOldeQuest.MonitorWritQuests(doMonitoring)
	if doMonitoring then
		YeOldeQuest_SetWritQuestResetHour()

		for type = 1, #CRAFTING_TYPE do
			WritQuestStatus[type] = STATUS.UNKNOWN
			WritQuestJournalIndex[type] = 0
			YeOldeQuest_UpdateQuestState(CRAFTING_TYPE[type])
		end

		EVENT_MANAGER:RegisterForEvent(YeOldeInfos.AddonName, EVENT_QUEST_ADDED, YeOldeQuest_QuestAdded)
		EVENT_MANAGER:RegisterForEvent(YeOldeInfos.AddonName, EVENT_QUEST_COMPLETE, YeOldeQuest_QuestCompleted)
		EVENT_MANAGER:RegisterForEvent(
			YeOldeInfos.AddonName,
			EVENT_QUEST_CONDITION_COUNTER_CHANGED,
			YeOldeQuest_QuestCondition_Changed
		)
		EVENT_MANAGER:RegisterForEvent(YeOldeInfos.AddonName, EVENT_QUEST_REMOVED, YeOldeQuest_QuestRemoved)

		YeOldeQuest_LoadActiveWritQuests()

		EVENT_MANAGER:RegisterForUpdate(EVENT_NAMESPACE, DEFAULT_UPDATE_TIME, YeOldeQuest_Update)
	else
		EVENT_MANAGER:UnregisterForUpdate(EVENT_NAMESPACE)
		EVENT_MANAGER:UnregisterForEvent(YeOldeInfos.AddonName, EVENT_QUEST_ADDED)
		EVENT_MANAGER:UnregisterForEvent(YeOldeInfos.AddonName, EVENT_QUEST_COMPLETE)
		EVENT_MANAGER:UnregisterForEvent(YeOldeInfos.AddonName, EVENT_QUEST_CONDITION_COUNTER_CHANGED)
		EVENT_MANAGER:UnregisterForEvent(YeOldeInfos.AddonName, EVENT_QUEST_REMOVED)
		EVENT_MANAGER:UnregisterForEvent(YeOldeInfos.AddonName, EVENT_PLAYER_COMBAT_STATE)
	end
end

--- Update table with reverse lookup infos.
---@param tbl table
local function BuildReverseLookupTables(tbl)
	for key, val in pairs(tbl) do
		if not tbl[val] then
			tbl[val] = key
		end
	end
end

function YeOldeQuest.Initialize()
	BuildReverseLookupTables(YeOldeInfos.QUEST_NAME)
	if YeOldeInfos.SV.Writs == nil then
		YeOldeInfos.SV.Writs = {}
	end

	-- Save vars updates
	if YeOldeInfos.SV.Writs.LastCompletedHour ~= nil then
		YeOldeInfos.SV.Writs.LastCompletedHour = nil
	end
	if YeOldeInfos.SV.Writs.LastCompletedDate ~= nil then
		YeOldeInfos.SV.Writs.LastCompletedDate = nil
	end
	if YeOldeInfos.SV.Writs.Characters == nil then
		YeOldeInfos.SV.Writs.Characters = {}
	end

	local charId = GetCurrentCharacterId()
	if YeOldeInfos.SV.Writs.Characters[charId] == nil then
		YeOldeInfos.SV.Writs.Characters[charId] = {}
		YeOldeInfos.SV.Writs.Characters[charId].LastCompletedDate = {}
		YeOldeInfos.SV.Writs.Characters[charId].LastCompletedHour = {}

		for _, type in pairs(CRAFTING_TYPE) do
			YeOldeInfos.SV.Writs.Characters[charId].LastCompletedDate[type] = 0
			YeOldeInfos.SV.Writs.Characters[charId].LastCompletedHour[type] = 12
		end
	end
	YeOldeQuest.SV = YeOldeInfos.SV.Writs.Characters[charId]
end
