local L = CookeryWizLanguage.language

-- there should only ever be one of these!
local callbackRegistrations = nil
local events = nil

local questNames = {}

WRIT_ITEM_QUEST_UNKNOWN = 0
--WRIT_ITEM_QUEST_PROVISIONING = 1
--WRIT_ITEM_QUEST_ALCHEMY = 2
--WRIT_ITEM_QUEST_ENCHANTING = 3

CookeryWizWritQuest = {}
CookeryWizWritQuest.writItem = nil
CookeryWizWritQuest.currentCallbackIndex = 0
CookeryWizWritQuest.currentCallback = 0

CookeryWizWritQuest.traceEnabled = false

local function trace(msg)
    if CookeryWizWritQuest.traceEnabled then
      d(GetTimeString()..":"..msg)
    end
end

local function addQuestType(questName)
  for i = 1, #questNames do
    if questNames[i] == questName then
      return i
    end
  end
  questNames[#questNames + 1] = questName
  return #questNames
end

local function resolveQuestType(questName)
  for i = 1, #questNames do
    if questNames[i] == questName then
      return i
    end
  end
  return WRIT_ITEM_QUEST_UNKNOWN
end

function CookeryWizWritQuest:GetItemID(link)
    if not link then
      return
    end
    local id = select(4,ZO_LinkHandler_ParseLink(link))  
    return tonumber(id)
end


---------------------------------------------------------------------
-- Function: Register
--
-- This function is called when an object wants to register itself
-- for writ quests.
-- A unique key is passed (usually the addon name) and the quest name
-- it is interested in. (Dont forget translations!)
-- The callback object is stored and various events called on it when
-- the writ quest is added
---------------------------------------------------------------------
function CookeryWizWritQuest:Register(key, object, questName)
  trace("Register:Key["..key.."], questName["..questName.."]")
  local callback
  
  if not object then
    d("A callback object must be passed")
    return
  end
   
  if not callbackRegistrations then
    trace("Constructing new registrations object")
    callbackRegistrations = CookeryWizRegistrations:new()
  end
  
  local questType = addQuestType(questName)
  trace("questType["..questType.."]")
  callback = callbackRegistrations:Register(key, self, function(callback)
        return callback.questType == questType
        end)
  if callback then
    callback.questType = questType
    callback.parentObject = object
    callback.questName = questName    
  end
  
  return questType
end

---------------------------------------------------------------------
-- Function: OnRegister
--
-- This function is called via the registrations object when it has
-- become Registered
---------------------------------------------------------------------
function CookeryWizWritQuest:OnRegister(count, object, ...)
  trace("OnRegister:Count["..count.."]")
  if count == 1 then
    trace("Registering for quest events")
    if not events then
      trace("Creating new events object")
      events = CookeryWizEvents:new()
    end      
    events:RegisterEvent(EVENT_QUEST_COMPLETE, function(...)
      self:OnQuestComplete(...)
    end)
  
    events:RegisterEvent(EVENT_QUEST_ADDED, function(...)
      self:OnQuestAdded(...)
    end) 
  
    -- now enable them
    events:EnableAllEvents(true)
  end
end

---------------------------------------------------------------------
-- Function: Unregister
--
-- This function is called when an object wants to unregister itself
-- for writ quests.
---------------------------------------------------------------------
function CookeryWizWritQuest:Unregister(key, questType)
  trace("Unregister:Key["..key.."], questType["..questType.."]")  
  
  if callbackRegistrations then
    callbackRegistrations:Unregister(key, function(callback)
        return callback.questType == questType
        end)
  end
end

---------------------------------------------------------------------
-- Function: OnUnregister
--
-- This function is called via the registrations object when it has
-- become unregistered
---------------------------------------------------------------------
function CookeryWizWritQuest:OnUnregister(count, callback)
  trace("OnUnregister:Count["..count.."]")
  if count == 0 and events then
    trace("No more registrations, Unregistering Quest events")   
    -- remove registration
    events:UnregisterEvent(EVENT_QUEST_COMPLETE)
    events:UnregisterEvent(EVENT_QUEST_ADDED)
  end 
end


function CookeryWizWritQuest:DumpQuests()
  for i = 1, GetNumJournalQuests() do
    local questName = GetJournalQuestName(i)  
    d("["..i.."]-"..questName)
  end
end

---------------------------------------------------------------------
-- Function: Rescan
--
-- This function is called when we want to manually parse the journal
-- for writ item quests.
-- This may be called prior to opening the bank or guild bank etc
-- The callback object should keep a table of what has been found.
-- if the table variable is set to an empty table when Reset is called,
-- then if it is still nil when they want to do something they can call
-- this routine
---------------------------------------------------------------------
function CookeryWizWritQuest:Rescan()
  if not callbackRegistrations then
    trace("No callback registrations")
    return
  end
  

  local numQuests = GetNumJournalQuests()  
  trace("Rescan-numQuests["..numQuests.."]")
  
  callbackRegistrations:Enumerate(function(callback)
    if callback.parentObject.OnWritQuestsExtractionStart then 
      callback.parentObject:OnWritQuestsExtractionStart()
    end                 
  end)

  for i = 1, numQuests do
    local interested = false
    local questName = GetJournalQuestName(i)
    local questType = resolveQuestType(questName)
    trace("-["..i.."] "..questName..", questType["..questType.."]")
    
    -- let any interested objects know about this quest and
    -- tell them to reset any info they have on the items
    callbackRegistrations:Enumerate(function(callback)
        --trace("parentObject["..callback.parentObject.name.."]")
        --trace("questName["..callback.questName.."]")
        --trace("enumerate object: questType["..callback.questType.."]")
        if callback.questType == questType then
          interested = true
          trace("Found a callback object that wants this quest")
          if callback.parentObject.OnWritQuestReset then 
            callback.parentObject:OnWritQuestReset(questType)
          end                 
        end
    end)       
    if interested then
      trace("At least one Callback is interested")
      self:ParseWritQuest(i, questType, questName, false)
    end
  end  

  -- let them know we have parsed all quests
  callbackRegistrations:Enumerate(function(callback)
    if callback.parentObject.OnWritQuestsExtractionComplete then 
      callback.parentObject:OnWritQuestsExtractionComplete()
    end                 
  end)

end

---------------------------------------------------------------------
-- Function: ParseWritQuest
--
-- This function is called when we want to parse the journal quest
-- for writ items.
-- For each item found, we perform a callback on the objects that
-- are interested
---------------------------------------------------------------------
function CookeryWizWritQuest:ParseWritQuest(journalIndex, questType, questName, questAdded)
  trace("ParseWritQuest, journalIndex["..journalIndex.."], questType["..questType.."], questName["..questName.."]")
  if not callbackRegistrations then
    trace("ParseWritQuest:No callback registrations")
    return
  end
  
  local stepCount = GetJournalQuestNumSteps(journalIndex)
  local updatedCookCount = false
  local callback
  
  self.writItem = {}

  for stepIndex=1, stepCount do
    local qstep, visibility, stepType, trackerOverrideText, numConditions = GetJournalQuestStepInfo(journalIndex,stepIndex)
    if qstep and qstep ~= "" then
      for conditionIndex=1, numConditions do
        local conditionText, currentval, maxval, _, _, _ = GetJournalQuestConditionInfo(journalIndex, stepIndex, conditionIndex)
        -- now match item to be crafted
        local craftItem, craftEntry = self:ExtractQuestItems(questType, conditionText)
        if craftItem then
          -- if we have items to create
          local craftItemQuantity = maxval - currentval
          trace("Found Craft Item - '"..craftItem.."' quantity required "..craftItemQuantity)
          if craftItemQuantity > 0 then
            
            -- resolve item to craft
            callbackRegistrations:Enumerate(function(callback)
              if callback.questType == questType then
                if callback.parentObject.OnWritItemAdded then 
                  callback.parentObject:OnWritItemAdded(questType, craftItem, craftItemQuantity, questAdded, craftEntry)
                end                 
              end
            end)        
          end
        end
      end
    end
  end  
  
  -- let them know we have parsed all items
  callbackRegistrations:Enumerate(function(callback)
    if callback.questType == questType then
      if callback.parentObject.OnWritQuestExtractionComplete then 
        callback.parentObject:OnWritQuestExtractionComplete(questType)
      end                 
    end
  end)

  --[[
  -- resolve item to craft
  for i = 1, #callbackRegistrations do
    callback = callbackRegistrations[i]
    if questName == callback.questName and callback.object.OnWritQuestItemsComplete then
      callback.object:OnWritQuestItemsComplete(questName)
    end
  end 
  ]]--
end

---------------------------------------------------------------------
-- Function: ExtractQuesCleanUpTexttItems
--
-- This function is called to fix up problematic characters in the
-- writ quest text
---------------------------------------------------------------------
function CookeryWizWritQuest:CleanUpText(text)
  local lang = GetCVar("language.2")
  if lang == "en" then
    -- the text should be good to go
  elseif lang == "de" then
    -- the text should be good to go
  elseif lang == "fr" then
    -- get rid of non breaking space.. it occurs at end
    -- eg pommes fraîches et fromage?eidar^pf
    text = text:gsub("\194\160", " ")
    text = zo_strtrim(text)
  end 
    return text
end
---------------------------------------------------------------------
-- Function: ExtractQuestItems
--
-- This function is called when we want to parse the condition text
-- of a writ quest for the item to craft
-- NOTE: the idea is to extract the text of the item, and let the
-- code for each craft skill match it how it wants. Perhaps it
-- is better to have an 'OnExtractQuestItems' routine that is called that
-- is passed the entire line, each grabbing code then does a match
-- on the complete line with the item type it is looking for.
-- Might be simpler?
---------------------------------------------------------------------
function CookeryWizWritQuest:ExtractQuestItems(questType, conditionText)
    local startText = " "
    local craftItem = nil
    trace("ExtractQuestItems:conditionText:"..conditionText)
    
    conditionText = zo_strformat("<<1>>", conditionText):lower()
    --d(conditionText)
    local startIndex = conditionText:find(startText, 1, true)
    if startIndex then
      -- split off any end quantity (it has to have it, else it is not valid)
      local endIndex = conditionText:find(":", startIndex + 1, true)
      if endIndex then
        endIndex = endIndex - 1
        --craftItem = conditionText:sub(startIndex + 1 , endIndex)
        craftItem = conditionText:sub(1, endIndex)
        
        local lang = GetCVar("language.2")

        -- fix up problematic text
        craftItem = self:CleanUpText(craftItem)
        
        local resolvedItem = nil
        local resolvedEntry = nil
        local tempItem = nil
        -- new
        callbackRegistrations:Enumerate(function(callback)
          if callback.questType == questType then
            if callback.parentObject.OnExtractQuestItems then 
              tempItem, resolvedEntry = callback.parentObject:OnExtractQuestItems(questType, craftItem, lang)
              if tempItem then
                resolvedItem = tempItem
                return true
              end
            end                 
          end
        end)        
        
        -- no need to continue if it was resolved
        if resolvedItem then
          return resolvedItem, resolvedEntry
        end
        
        trace("Craft Item:"..craftItem)
        local spaceIndex
        if lang == "en" then
          -- the craftItem returned should be good to go
        elseif lang == "de" then
          -- we need to skip an 'eine'
          spaceIndex = craftItem:find(" ", 1, true)
          if spaceIndex then
            --trace("spaceIndex["..spaceIndex.."]")
            craftItem = craftItem:sub(spaceIndex + 1)
          end
          --trace("After spaceIndex["..craftItem.."]")
          -- look for her
          --d(text:find("%w+$"))
          local herIndex = craftItem:find("her$", 1)
          if herIndex then
            craftItem = craftItem:sub(1, herIndex-2)
          end
          --trace("After her["..craftItem.."]")
        elseif lang == "fr" then
          -- we need to skip an 'un'/'une'.
          -- NOTE We may  need to check for this like in 'de' as Lorkhans tears
          -- may not have it
          spaceIndex = craftItem:find(" ", 1, true)
          if spaceIndex then
            --trace("spaceIndex["..spaceIndex.."]")
            craftItem = craftItem:sub(spaceIndex + 1)
          end 
        end          
      end      
    end
    return craftItem
end

function CookeryWizWritQuest:ParseWritQuestOld(journalIndex, questType, questName, questAdded)
  trace("ParseWritQuest, journalIndex["..journalIndex.."], questType["..questType.."], questName["..questName.."]")
  if not callbackRegistrations then
    trace("ParseWritQuest:No callback registrations")
    return
  end
  
  local stepCount = GetJournalQuestNumSteps(journalIndex)
  local updatedCookCount = false
  local callback
  
  self.writItem = {}

  for stepIndex=1, stepCount do
    local qstep, visibility, stepType, trackerOverrideText, numConditions = GetJournalQuestStepInfo(journalIndex,stepIndex)
    if qstep and qstep ~= "" then
      for conditionIndex=1, numConditions do
        local conditionText, currentval, maxval, _, _, _ = GetJournalQuestConditionInfo(journalIndex, stepIndex, conditionIndex)
        -- now match item to be crafted
        local craftItem, craftEntry = self:ExtractQuestItems(questType, conditionText)
        if craftItem then
          -- if we have items to create
          local craftItemQuantity = maxval - currentval
          trace("Found Craft Item - '"..craftItem.."' quantity required "..craftItemQuantity)
          if craftItemQuantity > 0 then
            
            -- resolve item to craft
            callbackRegistrations:Enumerate(function(callback)
              if callback.questType == questType then
                if callback.parentObject.OnWritItemAdded then 
                  callback.parentObject:OnWritItemAdded(questType, craftItem, craftItemQuantity, questAdded, craftEntry)
                end                 
              end
            end)        
          end
        end
      end
    end
  end  
  
  -- let them know we have parsed all items
  callbackRegistrations:Enumerate(function(callback)
    if callback.questType == questType then
      if callback.parentObject.OnWritQuestExtractionComplete then 
        callback.parentObject:OnWritQuestExtractionComplete(questType)
      end                 
    end
  end)

  --[[
  -- resolve item to craft
  for i = 1, #callbackRegistrations do
    callback = callbackRegistrations[i]
    if questName == callback.questName and callback.object.OnWritQuestItemsComplete then
      callback.object:OnWritQuestItemsComplete(questName)
    end
  end 
  ]]--
end

function CookeryWizWritQuest:GetNextCallback()
  local callback
  if self.currentCallbackIndex == #callbackRegistrations then
    return nil
  end
  
  self.currentCallbackIndex = self.currentCallbackIndex + 1
  callback = callbackRegistrations[self.currentCallbackIndex]
  return callback  
end

---------------------------------------------------------------------
-- ESO Event Handlers
---------------------------------------------------------------------
  
---------------------------------------------------------------------
-- Function: OnQuestComplete
--
-- This function is called when a quest is complete. We check to see
-- if it is the writ food quest. If it is then we inform the user
-- that it is now complete
---------------------------------------------------------------------
function CookeryWizWritQuest:OnQuestComplete(eventCode, questName, level, previousExperience, currentExperience, rank, previousPoints, currentPoints)
  trace("OnQuestComplete")
  
  if not callbackRegistrations then
    trace("No callback registrations")
    return
  end
  
  local questType = resolveQuestType(questName)
  
  -- let them know we have completed the quest!
  callbackRegistrations:Enumerate(function(callback)
    if callback.questType == questType then
      if callback.parentObject.OnWritQuestComplete then 
        callback.parentObject:OnWritQuestComplete(questType)
      end                 
    end
  end)  
 
end

---------------------------------------------------------------------
-- Function: OnQuestAdded
--
-- This function is called when a quest is added. We check to see
-- if it is the writ quest. If it is then we parse the writ
-- to see what is required
---------------------------------------------------------------------
function CookeryWizWritQuest:OnQuestAdded(eventCode, journalIndex, questName, objectiveName)
  trace("OnQuestAdded: eventCode-"..eventCode..", journalIndex-"..journalIndex..", questName-"..questName..", objectiveName-"..objectiveName)
  
  if not callbackRegistrations then
    trace("No callback registrations")
    return
  end
  
  local questType = resolveQuestType(questName)
  trace("questType["..questType.."]")
  local interested = false
  
  -- let any interested objects know about this quest and
  -- tell them to reset any info they have on the items
  callbackRegistrations:Enumerate(function(callback)
    if callback.questType == questType then
      interested = true
      trace("About to call OnWritQuestReset")
      if callback.parentObject.OnWritQuestReset then 
        callback.parentObject:OnWritQuestReset(questType)
      end                 
    end
  end) 
 
  if interested then
    trace("Someone is interested, parse writ quest")
    self:ParseWritQuest(journalIndex, questType, questName, true)
  end 
end