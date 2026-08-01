--
-- Calamath's Quest Tracker [CQT]
--
-- Copyright (c) 2022 Calamath
--
-- This software is released under the Artistic License 2.0
-- https://opensource.org/licenses/Artistic-2.0
--

if not CQuestTracker then return end
local CQT = CQuestTracker:SetSharedEnvironment()

-- ---------------------------------------------------------------------------------------
-- Quest Cache Manager Class
-- ---------------------------------------------------------------------------------------
local CQT_QuestCache_Singleton = ZO_InitializingObject:Subclass()

function CQT_QuestCache_Singleton:Initialize()
	self.name = "CQT-QuestCacheSingleton"
	self.questIdBreadcrumbs = {}
	self.journalQuestCache = {}
	self.journalQuestIdCache = {}
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ADD_ON_LOADED, function(_, addonName)
		if addonName ~= CQT.name then return end
		EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
		self:RebuildQuestIdBreadcrumbs()
		self:RebuildJournalQuestCache()
		self:RebuildJournalQuestIdCache()
	end)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_QUEST_ADDED, function(_, journalIndex, questName)
		self:UpdateJournalQuestCache(journalIndex, questName)
		self:UpdateJournalQuestIdCache(journalIndex, questName)
--		CQT.LDL:Debug("QuestCache/EVENT_QUEST_ADDED :")
	end)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_QUEST_LIST_UPDATED, function()
		self:RebuildJournalQuestCache()
		self:RebuildJournalQuestIdCache()
--		CQT.LDL:Debug("QuestCache/EVENT_QUEST_LIST_UPDATED :")
	end)
end

function CQT_QuestCache_Singleton:RebuildQuestIdBreadcrumbs()
	local name, zId
	ZO_ClearTable(self.questIdBreadcrumbs)
	for i = 1, UPPER_LIMIT_OF_ASSUMED_QUEST_ID do
		name = GetQuestName(i)
		if name ~= "" then
			zId = GetQuestZoneId(i)
			if not self.questIdBreadcrumbs[zId] then
				self.questIdBreadcrumbs[zId] = {}
			end
			if not self.questIdBreadcrumbs[zId][name] then
				self.questIdBreadcrumbs[zId][name] = { i }
			else
				table.insert(self.questIdBreadcrumbs[zId][name], i)
			end
		end
	end
end

function CQT_QuestCache_Singleton:GetNumQuestIdBreadcrumbs()
	local num = 0
	for z, v in pairs(self.questIdBreadcrumbs) do
		for n, ids in pairs(v) do
			if #ids > 1 then
--				CQT.LDL:Debug("zoneId=%d, num=%d, name=%s", z, #ids, n)
			end
			num = num + 1
		end
	end
--	CQT.LDL:Debug("numQuests: ", num)
	return num
end

function CQT_QuestCache_Singleton:GetQuestIds(journalIndex)
	local name, zId = self:GetJournalQuestCache(journalIndex)
	return self.questIdBreadcrumbs[zId] and self.questIdBreadcrumbs[zId][name] or { 0 }
end

function CQT_QuestCache_Singleton:GetQuestMainId(journalIndex)
-- This method returns the smallest ID number as a representative number when there are multiple with the same quest name.
	local t = self:GetQuestIds(journalIndex)
	return t and t[1] or 0
end

function CQT_QuestCache_Singleton:GetQuestId(journalIndex)
	return self:GetJournalQuestIdCache(journalIndex)
end

function CQT_QuestCache_Singleton:HasCompletedQuest(journalIndex)
	local hasCompleted = false
	for _, qId in pairs(self:GetQuestIds(journalIndex)) do
		hasCompleted = hasCompleted or HasCompletedQuest(qId)
	end
	return hasCompleted
end

function CQT_QuestCache_Singleton:RebuildJournalQuestCache()
	ZO_ClearNumericallyIndexedTable(self.journalQuestCache)
	for i = 1, MAX_JOURNAL_QUESTS do
		local name = GetJournalQuestName(i)
		local zoneName, _, zoneIndex = GetJournalQuestLocationInfo(i)
		table.insert(self.journalQuestCache, {
			index = i, 
			name = name, 
			zoneId = zoneName ~= "" and GetZoneId(GetJournalQuestStartingZone(i)) or 0, 
			zoneIndex = zoneIndex, 
		})
	end
end

function CQT_QuestCache_Singleton:UpdateJournalQuestCache(journalIndex, name)
	local zoneName, _, zoneIndex = GetJournalQuestLocationInfo(journalIndex)
	self.journalQuestCache[journalIndex].index = journalIndex
	self.journalQuestCache[journalIndex].name = name
	self.journalQuestCache[journalIndex].zoneId = zoneName ~= "" and GetZoneId(GetJournalQuestStartingZone(journalIndex)) or 0
	self.journalQuestCache[journalIndex].zoneIndex = zoneIndex
end

function CQT_QuestCache_Singleton:GetJournalQuestCache(journalIndex)
	return self.journalQuestCache[journalIndex].name, self.journalQuestCache[journalIndex].zoneId
end

function CQT_QuestCache_Singleton:RebuildJournalQuestIdCache()
	ZO_ClearNumericallyIndexedTable(self.journalQuestIdCache)
	for i = 1, MAX_JOURNAL_QUESTS do
		self:UpdateJournalQuestIdCache(i)
	end
end

function CQT_QuestCache_Singleton:UpdateJournalQuestIdCache(journalIndex)
	local questId = 0
	for _, qId in pairs(self:GetQuestIds(journalIndex)) do
		if HasQuest(qId) then
			questId = qId
			break
		end
	end
	self.journalQuestIdCache[journalIndex] = questId
end

function CQT_QuestCache_Singleton:GetJournalQuestIdCache(journalIndex)
	return self.journalQuestIdCache[journalIndex] or 0
end

-- ---------------------------------------------------------------------------------------

local CQT_QUEST_CACHE_MANAGER = CQT_QuestCache_Singleton:New()	-- Never do this more than once!

-- global API --
local function GetQuestCacheManager() return CQT_QUEST_CACHE_MANAGER end
CQT:RegisterSharedObject("GetQuestCacheManager", GetQuestCacheManager)

local function GetQuestMainId(journalIndex) return CQT_QUEST_CACHE_MANAGER:GetQuestMainId(journalIndex) end
CQT:RegisterSharedObject("GetQuestMainId", GetQuestMainId)

local function GetQuestId(journalIndex) return CQT_QUEST_CACHE_MANAGER:GetQuestId(journalIndex) end
CQT:RegisterSharedObject("GetQuestId", GetQuestId)

local function HasCompletedQuestByIndex(journalIndex) return CQT_QUEST_CACHE_MANAGER:HasCompletedQuest(journalIndex) end
CQT:RegisterSharedObject("HasCompletedQuestByIndex", HasCompletedQuestByIndex)

