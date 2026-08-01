if not HeistMuteSavedata then
   HeistMuteSavedata = {
      options = {
         muteHeists = true,
      }
   }
end
HeistMute = {}

local _timerWidget = nil
local function _hideTimerForQuest(journalIndex)
   if not journalIndex then
      return
   end
   if not _timerWidget then
      local t = ZO_FocusedQuestTrackerPanelTimerAnchor:GetChild(1)
      if not t then
         return
      end
      _timerWidget = t.owner
   end
   local control = _timerWidget.timers[journalIndex]
   if control then
      control:SetHidden(true)
   end
end

local Quest = {}
do
   Quest.__index = Quest
   function Quest:new(name:string)
      local result = setmetatable({}, self)
      result.name = name -- case-sensitive
      result.announcements  = {} -- case-insensitive
      result.objectiveFails = {} -- case-insensitive
      return result
   end
   function Quest:addAnnouncement(header:string, body:string)
      self.announcements[#self.announcements + 1] = { head = header:lower(), body = body:lower() }
   end
   function Quest:addObjectiveFailure(text:string)
      self.objectiveFails[#self.objectiveFails + 1] = text
   end
   function Quest:find()
      for i = 1, GetNumJournalQuests() do
         local n = GetJournalQuestName(i)
         if self:testQuestName(n) then
            return i
         end
      end
   end
   function Quest:testAnnouncement(h:string, b:string)
      h = h:lower()
      b = b:lower()
      for _, v in ipairs(self.announcements) do
         if h == v.head and b == v.body then
            return true
         end
      end
      return false
   end
   function Quest:testQuestName(name:string)
      return not not string.find(name, self.name)
   end
   function Quest:testObjectiveFailure(text:string)
      text = text:lower()
      for _, v in ipairs(self.objectiveFails) do
         if text == v then
            return true
         end
      end
      return false
   end
   function Quest:tryHideTimer()
      _hideTimerForQuest(self:find())
   end
end

local HEIST_QUEST = Quest:new(GetString(HEISTMUTE_HEIST_QUEST_NAME_REGEX))
HeistMute.HEIST_QUEST = HEIST_QUEST
HEIST_QUEST:addAnnouncement(GetString(HEISTMUTE_HEIST_QUEST_ANNOUNCE_DETECTED_HEAD), GetString(HEISTMUTE_HEIST_QUEST_ANNOUNCE_DETECTED_BODY))
HEIST_QUEST:addAnnouncement(GetString(HEISTMUTE_HEIST_QUEST_ANNOUNCE_NO_TIME_HEAD),  GetString(HEISTMUTE_HEIST_QUEST_ANNOUNCE_NO_TIME_BODY))
HEIST_QUEST:addObjectiveFailure(GetString(HEISTMUTE_HEIST_QUEST_OBJECTIVEFAIL_TIME_01))
HEIST_QUEST:addObjectiveFailure(GetString(HEISTMUTE_HEIST_QUEST_OBJECTIVEFAIL_TIME_02))

local function _hookCenterAnnounce()
   do -- Hook the event listener for EVENT_DISPLAY_ANNOUNCEMENT
      local original = ZO_CenterScreenAnnounce_GetEventHandlers()[EVENT_DISPLAY_ANNOUNCEMENT]
      ZO_CenterScreenAnnounce_GetEventHandlers()[EVENT_DISPLAY_ANNOUNCEMENT] =
         function(primaryText, secondaryText, icon, soundId, lifespanMS, category)
            local header = primaryText:lower()
            local body   = secondaryText:lower()
            if HeistMuteSavedata.options.muteHeists then
               if HEIST_QUEST:testAnnouncement(header, body) then
                  return
               end
            end
            return original(primaryText, secondaryText, icon, soundId, lifespanMS, category)
         end
   end
   do -- Hook the add-message code so we can grab failed objectives
      local original = CENTER_SCREEN_ANNOUNCE.AddMessageWithParams
      CENTER_SCREEN_ANNOUNCE.AddMessageWithParams = function(self, messageParams)
         if not messageParams then
            return
         end
         -- messageParams instanceof ZO_CenterScreenMessageParams
         local condition = (messageParams:GetMainText() or ""):lower()
         if HeistMuteSavedata.options.muteHeists then
            if HEIST_QUEST:testObjectiveFailure(condition) then
               return
            end
         end
         return original(self, messageParams)
      end
   end
end
local function _hookQuestTimer()
   EVENT_MANAGER:RegisterForEvent("HeistMute", EVENT_QUEST_TIMER_UPDATED, function(eventCode, index)
      zo_callLater(function()
         local visible = select(3, GetJournalQuestTimerInfo(index))
         if not visible then
            return
         end
         local name = GetJournalQuestName(index)
         if HeistMuteSavedata.options.muteHeists then
            if HEIST_QUEST:testQuestName(name) then
               _hideTimerForQuest(index)
               return
            end
         end
      end, 1)
   end)
   HEIST_QUEST:tryHideTimer()
end
local function _hookQuestTracker()
   --[[
   local original = FOCUSED_QUEST_TRACKER.PopulateStepQuestConditions
   FOCUSED_QUEST_TRACKER.PopulateStepQuestConditions = function(self, questIndex, stepIndex, questHeader, treeNode, desiredVisibility, entryType)
      local _, visibility, stepType, stepOverrideText, conditionCount = GetJournalQuestStepInfo(questIndex, stepIndex)
      local name = GetJournalQuestName(questIndex)
      if HeistMuteSavedata.options.muteHeists then
         if HEIST_QUEST:testQuestName(name) then
            local isOptionalStep = (stepIndex > 1)
            if isOptionalStep and visibility == QUEST_STEP_VISIBILITY_OPTIONAL then
               return
            end
         end
      end
      return original(self, questIndex, stepIndex, questHeader, treeNode, desiredVisibility, entryType)
   end
   ]]--
   local original = FOCUSED_QUEST_TRACKER.PopulateOptionalStepQuestConditionsForVisibility
   FOCUSED_QUEST_TRACKER.PopulateOptionalStepQuestConditionsForVisibility = function(self, questIndex, questHeader, treeNode, desiredVisibility, entryType)
      local name = GetJournalQuestName(questIndex)
      if HeistMuteSavedata.options.muteHeists then
         if HEIST_QUEST:testQuestName(name) and desiredVisibility == QUEST_STEP_VISIBILITY_OPTIONAL then
            return
         end
      end
      return original(self, questIndex, questHeader, treeNode, desiredVisibility, entryType)
   end
end

local function OnAddonLoaded(eventCode, addon)
   if addon ~= "HeistMute" then
      return
   end
   local LAM = LibStub("LibAddonMenu-2.0")
   local panelData = {
      type    = "panel",
      name    = "HeistMute",
      displayName = "HeistMute",
      author  = "DavidJCobb",
      registerForRefresh  = true,
   }
   local options = {
      {
         type = "checkbox",
         name = "Mute Heists",
         getFunc = function() return HeistMuteSavedata.options.muteHeists end,
         setFunc =
            function(v)
               HeistMuteSavedata.options.muteHeists = v
               if v then
                  HEIST_QUEST:tryHideTimer()
               -- TODO: else unhide timer, somehow
               end
            end,
      },
   }
   panel = LAM:RegisterAddonPanel("HeistMuteOptionsMenu", panelData)
   LAM:RegisterOptionControls("HeistMuteOptionsMenu", options)
   --
   _hookCenterAnnounce()
   _hookQuestTimer()
   _hookQuestTracker()
   if HEIST_QUEST:find() then
      FOCUSED_QUEST_TRACKER:InitialTrackingUpdate()
   end
end
EVENT_MANAGER:RegisterForEvent("HeistMute", EVENT_ADD_ON_LOADED, OnAddonLoaded)