local ArchQuestRefresh = {}
--ZO_Object:Subclass()

local LAM = LibStub:GetLibrary("LibAddonMenu-2.0")

function ArchQuestRefresh:New(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

function ArchQuestRefresh:SetupOptions()
	local addonDisplayName = "|c0066FFArch's|r Quest Refresh"
	
	local panelData = {
		type = "panel",
		name = addonDisplayName,
		displayName = addonDisplayName,
		author = "|c0066FFArchitecture|r",
		--version = self.version,
		registerForRefresh = true,
		registerForDefaults = false,
	}
	
	local optionsTable = {
		-- Undaunted Pledge Quests
		{
			type = "header",
			name = "Undaunted Pledge Quests",
			width = "full",
		},
		{
			type = "checkbox",
			name = "Allow Abandoning of Pledge Quest",
			tooltip = "Enables or disables the ability to abandon the currently accepted undaunted pledge quests using the custom keybind.",
			getFunc = function() return self.sv.enabled end,
			setFunc = function(value)
				self.sv.enabled = value
			end,
			width = "full",
		},
		{
			type = "checkbox",
			name = "Continue Abandoning All Pledge Quests",
			tooltip = "When enabled this will continue to prompt for abandoning any remaining quests until there are no more pledge quests or until canceled.",
			getFunc = function() return self.sv.continueAbandon end,
			setFunc = function(value)
				self.sv.continueAbandon = value
			end,
			width = "full",
		},
		{
			type = "checkbox",
			name = "Display Success Alert",
			tooltip = "Display alert message when all pledge quests are abandoned",
			getFunc = function() return self.sv.messageEnabled end,
			setFunc = function(value)
				self.sv.messageEnabled = value
			end,
			width = "full",
		},
	}
	
	LAM:RegisterAddonPanel(self.name, panelData)
	LAM:RegisterOptionControls(self.name, optionsTable)
end

local questLang = GetCVar("language.2") -- contains "en" or "de" or "fr" now
local languageToPledgeQuestName = {
	["en"] = "PLEDGE",
	["de"] = "GELÖBNIS",
	["fr"] = "SERMENT",
	["es"] = "PROMESA",
}
local pledgeQuestNameCheck = languageToPledgeQuestName[questLang] or "PLEDGE"

---
-- @param i Journal Index
-- @param questName Quest Name
--
local function isPledgeJournalQuestName(i, questName)
	if i == nil or i < 1 or MAX_JOURNAL_QUESTS < 1 or i > MAX_JOURNAL_QUESTS then return false end
	
	local questType = GetJournalQuestType(i)
	
	return questType == QUEST_TYPE_DUNGEON and string.find(string.upper(questName), pledgeQuestNameCheck)
end

---
-- @param i Journal Index
--
local function isPledgeJournalQuest(i)
	local questName = GetJournalQuestName(i)
	
	return isPledgeJournalQuestName(i, questName)
end

-- Callback function for removed quest
local function ArchQuestRefresh_OnRemoveQuest(eventCode, isCompleted, journalIndex, questName, zoneIndex, poiIndex, questID)
	if ARCH_QUEST_REFRESH == nil or ARCH_QUEST_REFRESH.AbandonQuestEventName == nil then return false end
	--d("[ArchQuestRefresh_OnRemoveQuest] isCompleted: " .. tostring(isCompleted) .. ", journalIndex: " .. tostring(journalIndex) .. ", questName: " .. tostring(questName) .. ", questID: " .. tostring(questID))
	--If pledges quest got abandoned we need to go on with the next possible pledges quest
	if not isCompleted and string.find(string.upper(questName), pledgeQuestNameCheck) then
		--UnRegister event callback function to realize if quest get's abandoned
		EVENT_MANAGER:UnregisterForEvent(ARCH_QUEST_REFRESH.AbandonQuestEventName, EVENT_QUEST_REMOVED)
		
		--ARCH_QUEST_REFRESH:Abandon()
		zo_callLater(function() ARCH_QUEST_REFRESH:Abandon() end, 200)
	end
end

function ArchQuestRefresh:Abandon()
	if self.sv ~= nil and self.sv.enabled then
		
		local foundAnyPledgeQuests = false
		for i = 1, MAX_JOURNAL_QUESTS do
			if isPledgeJournalQuest(i) then
				foundAnyPledgeQuests = true
				--Register event callback function to realize if quest gets abandoned
				if (self.sv.continueAbandon) then
					EVENT_MANAGER:RegisterForEvent(self.AbandonQuestEventName, EVENT_QUEST_REMOVED, ArchQuestRefresh_OnRemoveQuest)
				end
				
				QUEST_JOURNAL_MANAGER:ConfirmAbandonQuest(i)
				
				return
			end
		end
		
		if not foundAnyPledgeQuests and self.sv.messageEnabled then
			ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "All pledge quests are abandoned")
		end
		
		if (self.sv.continueAbandon) then
			--UnRegister event callback function to realize if quest get's abandoned
			EVENT_MANAGER:UnregisterForEvent(self.AbandonQuestEventName, EVENT_QUEST_REMOVED)
		end
	end
end

function ArchQuestRefresh:DefineColors()
	self.color = {}
	self.color.yellow = "|cFFFF00"
	self.color.lightYellow = "|cFFFFCC"
	self.color.green = "|c00FF00"
	self.color.magenta = "|cFF00FF"
	self.color.red = "|cFF0000"
	self.color.darkOrange = "|cFFA500"
	self.color.iconYellow = "|cFFFF33"
	self.color.iconOrange = "|cFF6600"
	self.color.grey = "|c626255"
	self.color.brightOrange = "|cE68A00"
end

--- Register Chat Slash Commands
--
function ArchQuestRefresh:RegisterSlashCommands()
	SLASH_COMMANDS["/questrefresh"] = function() ARCH_QUEST_REFRESH:Abandon() end
	SLASH_COMMANDS["/apq"] = function() ARCH_QUEST_REFRESH:Abandon() end
	SLASH_COMMANDS["/abandonpledgequests"] = function() ARCH_QUEST_REFRESH:Abandon() end
end

--- Initialize
-- @param addonName
--
function ArchQuestRefresh:Initialize(addonName)
	self.name = addonName
	
	self:DefineColors()
	
	self.AbandonQuestEventName = "ArchQuestRefreshRemoveQuest"

	ZO_CreateStringId("SI_BINDING_NAME_QUESTREFRESH_REM_PLEDGES", self.color.darkOrange .. "Abandon Pledges|r " .. self.color.magenta .. "- Set a hotkey to abandon undaunted pledge quests")
	
	self.sv = {}
	
	local defaults = {
		enabled = true,
		continueAbandon = true,
		messageEnabled = true,
	}
	
	self.sv = ZO_SavedVars:New(self.name .. "_SavedVariables", 2, nil, defaults)
	
	self:SetupOptions()
	
	self:RegisterSlashCommands()
end

ARCH_QUEST_REFRESH = ArchQuestRefresh:New()

-- Addon Initialization
local function ArchQuestRefresh_Init(eventType, addonName)
	if addonName ~= "ArchQuestRefresh" then
		return
	end
	
	ARCH_QUEST_REFRESH:Initialize(addonName)
end

EVENT_MANAGER:RegisterForEvent("ArchQuestRefreshInit", EVENT_ADD_ON_LOADED, ArchQuestRefresh_Init)
