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
-- Quest Timer Manager Class
-- ---------------------------------------------------------------------------------------
local CQT_QuestTimer_Singleton = CT_AdjustableInitializingObject:Subclass()
function CQT_QuestTimer_Singleton:Initialize(template, overriddenAttrib)
	self.name = "CQT-QuestTimerSingleton"
	self.template = template or "CQT_QuestTimerTemplate"
	self._attrib = {
		timerFont = "$(BOLD_FONT)|$(KB_18)|soft-shadow-thick", 
		timerColor = { GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL) }, 
		timerIcon = "Esoui/Art/Miscellaneous/timer_64.dds", 
	}
	CT_AdjustableInitializingObject.Initialize(self, overriddenAttrib)
	self.timers = {}
	self.control = WINDOW_MANAGER:CreateControl("CQT_UI_QuestTimerRoot", GuiRoot, CT_CONTROL)
	self.timerPool = ZO_ControlPool:New(self.template, self.control)
	self.timerPool:SetCustomFactoryBehavior(function(control)
		control.time = control:GetNamedChild("Time")
		control.icon = control:GetNamedChild("Icon")
		control:SetHandler("OnUpdate", function(control, time)
			self:UpdateTimer(control, time)
		end)
	end)
	self.timerPool:SetCustomAcquireBehavior(function(control, key)
		control.time:SetFont(self:GetAttribute("timerFont"))
		control.time:SetColor(unpack(self:GetAttribute("timerColor")))
		local icon = self:GetAttribute("timerIcon")
		control.icon:SetTexture(icon)
		if icon ~= "" then
			local iconSize = control.time:GetFontHeight()
			control.icon:SetDimensions(iconSize, iconSize)
		else
			control.icon:SetDimensions(0, 0)
		end
	end)
	self.timerPool:SetCustomResetBehavior(function(control)
		control:SetParent(self.control)
		control:ClearAnchors()
		control.time:SetText("")
		control.time:SetHidden(false)
	end)
	self.control:RegisterForEvent(EVENT_QUEST_TIMER_UPDATED, function(event, journalIndex)
		local timerStart, timerEnd, isVisible, isPaused = GetJournalQuestTimerInfo(journalIndex)
		if isVisible then
			self:CreateTimer(journalIndex)
		else
			self:RemoveTimer(journalIndex)
		end
	end)
	self.control:RegisterForEvent(EVENT_QUEST_TIMER_PAUSED, function(event, journalIndex, isPaused)
		if self.timers[journalIndex] then
			local timerStart, timerEnd, isVisible, isPaused = GetJournalQuestTimerInfo(journalIndex)
			self.timers[journalIndex].isPaused = isPaused
			if not isPaused then
				self.timers[journalIndex].timerStart = timerStart
				self.timers[journalIndex].timerEnd = timerEnd
			end
		end
	end)
	self.control:RegisterForEvent(EVENT_QUEST_REMOVED, function(event, _, journalIndex)
		self:RemoveTimer(journalIndex)
	end)

	for i = 1, MAX_JOURNAL_QUESTS do
		if IsValidQuestIndex(i) then
			self:CreateTimer(i)
		end
	end	
end

function CQT_QuestTimer_Singleton:AcquireTimer(journalIndex)
	if self.timers[journalIndex] then
		return self.timers[journalIndex]
	end
	local timer, key = self.timerPool:AcquireObject()
	timer.key = key
	timer:SetHidden(false)
	self.timers[journalIndex] = timer
	return timer
end

function CQT_QuestTimer_Singleton:RemoveTimer(journalIndex)
	if self.timers[journalIndex] then
		self.timerPool:ReleaseObject(self.timers[journalIndex].key)
		self.timers[journalIndex] = nil
	end
end

function CQT_QuestTimer_Singleton:UpdateTimer(timer, now)
	if not timer.isPaused and timer.nextUpdate <= now then
		local remainingTime = timer.timerEnd - now
		if remainingTime > 0 then
			local timeText, nextUpdateDelta = ZO_FormatTime(remainingTime, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)
			timer.time:SetText(timeText)
			timer.nextUpdate = now + nextUpdateDelta
		else
			self:RemoveTimer(timer.journalIndex)
		end
	end
end

function CQT_QuestTimer_Singleton:CreateTimer(journalIndex)
	local timerStart, timerEnd, isVisible, isPaused = GetJournalQuestTimerInfo(journalIndex)
	if isVisible then
		local timer = self:AcquireTimer(journalIndex)
		timer.journalIndex = journalIndex
		timer.timerStart = timerStart
		timer.timerEnd = timerEnd
		timer.isVisible = isVisible
		timer.isPaused = isPaused

		local now =  GetFrameTimeSeconds()
		timer.nextUpdate = now

		self:UpdateTimer(timer, now)
	end
end

--
-- ---- API section ----------------------------------------------------------------------
--
function CQT_QuestTimer_Singleton:GetTimer(journalIndex)
	return self.timers[journalIndex]
end

function CQT_QuestTimer_Singleton:RegisterOverriddenAttributeTable(overriddenAttrib)
	-- If the external attribute table not be specified in the constructor, it could be registered with this method only once.
	if self._hasOverriddenAttrib or type(overriddenAttrib) ~= "table" then
		return false
	else
		self._overriddenAttrib = overriddenAttrib
		self._hasOverriddenAttrib = true
		return true
	end
end

function CQT_QuestTimer_Singleton:DiscardAllTimerLayouts()
	for _, timer in pairs(self.timers) do
		timer:SetParent(self.control)
		timer:ClearAnchors()
	end
end

-- ---------------------------------------------------------------------------------------

local CQT_QUEST_TIMER_MANAGER = CQT_QuestTimer_Singleton:New()	-- Never do this more than once!

-- global API --
local function GetQuestTimerManager() return CQT_QUEST_TIMER_MANAGER end
CQT:RegisterSharedObject("GetQuestTimerManager", GetQuestTimerManager)

--
-- ---- CQT_QUEST_TIMER_MANAGER API Reference ----
--
-- * GetQuestTimerManager():GetTimer(*luaindex* _journalQuestIndex_)
-- ** _Returns:_ *object:nilable* _questTimerControl_
-- It is necessary to tie it to a container with SetParent() and lay it out with SetAnchor(), to display the acquired timer control.

-- * GetQuestTimerManager():RegisterOverriddenAttributeTable(*table* _overriddenAttrib_)
-- Specify if you want to use a user-defined attribute table

-- * GetQuestTimerManager():DiscardAllTimerLayouts()
-- Utility function to release all laid out timer controls at once

