-----------------------------------------------------------------------------
-- ESO Addon for displaying writ crafting requirements within the crafting
-- screen. Each station shows it's respective writ quest items.
--
-- Author:    Wheels
-- Version:   1.0.1
-----------------------------------------------------------------------------

WritHelper = {}
local isCraft = false

WritHelper.name = "WritHelper"
WritHelper.smithing = ""
WritHelper.clothing = ""
WritHelper.enchanting = ""
WritHelper.alchemy = ""
WritHelper.provisioning = ""
WritHelper.woodworking = ""
WritHelper.hasSmithing = false
WritHelper.hasClothing = false
WritHelper.hasEnchanting = false
WritHelper.hasAlchemy = false
WritHelper.hasProvisioning = false
WritHelper.hasWoodworking = false
WritHelper.objective = ''

-----------------------------------------------------------------------------
-- When user stops moving UI in game, save the location of it to the 
-- savedVariables file. Every crafting station will have the UI in the same
-- location.
-----------------------------------------------------------------------------
function WritHelper.OnIndicatorMoveStop()
  WritHelper.savedVariables.left = WritHelperCrafting:GetLeft()
  WritHelper.savedVariables.top = WritHelperCrafting:GetTop()
end

-----------------------------------------------------------------------------
-- Restores the past position of the UI that was saved in the savedVariables
-- file. This will restore upon loading the addon, and applies to all
-- crafting stations.
-----------------------------------------------------------------------------
function WritHelper:RestorePosition()
  local left = self.savedVariables.left
  local top = self.savedVariables.top
 
  WritHelperCrafting:ClearAnchors()
  WritHelperCrafting:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

-----------------------------------------------------------------------------
-- Called when the addon is loaded, and designates which events future
-- functions will be waiting for. Additionally, it will get the saved
-- variables that were stored in the last session and use them to restore
-- the UI position.
-----------------------------------------------------------------------------
function WritHelper:Initialize()
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CRAFTING_STATION_INTERACT, self.crafting)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_END_CRAFTING_STATION_INTERACT, self.endCraft)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_QUEST_ADDED, self.getWritQuest)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_QUEST_COMPLETE, self.endWrit)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_QUEST_REMOVED, self.delWrit)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_QUEST_CONDITION_COUNTER_CHANGED, self.updateWrit)
  
  self.savedVariables = ZO_SavedVars:New("WritHelperSavedVariables", 1, nil, {})
  self:RestorePosition()
end

-----------------------------------------------------------------------------
-- Executes when a quest is added to the journal. Checks if the new quest is
-- a writ quest, and if so it will then get the conditions for the writ, and
-- save them for future use. It also sets a boolean saying if the user has
-- a writ of given type to true.
--
-- @param index          The index in the journal where the new quest was 
--                       added.
-- @param name           The name of the new quest.
-----------------------------------------------------------------------------
function WritHelper:getWritQuest(index, name)
  local type = GetJournalQuestType(index)
  if type == 4 then
    local p1, p2, p3, p4 = ''
    p1 = GetJournalQuestConditionInfo(index, 1, 1)
    p2 = GetJournalQuestConditionInfo(index, 1, 2)
    p3 = GetJournalQuestConditionInfo(index, 1, 3)
    p4 = GetJournalQuestConditionInfo(index, 1, 4)
    if p1 ~= '' then
      WritHelper.objective = WritHelper.objective .. p1 .. '\n'
    end
    if p2 ~= '' then
      WritHelper.objective = WritHelper.objective .. p2 .. '\n'
    end
    if p3 ~= '' then
      WritHelper.objective = WritHelper.objective .. p3 .. '\n'
    end
    if p4 ~= '' then
      WritHelper.objective = WritHelper.objective .. p4
    end
    if name == 'Blacksmith Writ' then 
      WritHelper.smithing = WritHelper.objective
      WritHelper.hasSmithing = true
    elseif name == 'Clothier Writ' then
      WritHelper.clothing = WritHelper.objective
      WritHelper.hasClothing = true
    elseif name == 'Enchanter Writ' then
      WritHelper.enchanting = WritHelper.objective
      WritHelper.hasEnchanting = true
    elseif name == 'Alchemist Writ' then
      WritHelper.alchemy = WritHelper.objective
      WritHelper.hasAlchemy = true
    elseif name == 'Provisioner Writ' then
      WritHelper.provisioning = WritHelper.objective
      WritHelper.hasProvisioning = true
    elseif name == 'Woodworker Writ' then
      WritHelper.woodworking = WritHelper.objective
      WritHelper.hasWoodworking = true
    end
      WritHelper.objective = ''
  end
end

-----------------------------------------------------------------------------
-- Executes when the conditions of a quest change. Updates what the current
-- conditions to complete the writ are in real time as items are crafted.
--
-- @param index          The index in the journal where the quest with the
--                       updated conditions is located.
-- @param name           The name of the quest with the updated conditions
-----------------------------------------------------------------------------
function WritHelper:updateWrit(index, name)
  WritHelper:getWritQuest(index, name)
  WritHelper:updateCraft(GetCraftingInteractionType())
end

-----------------------------------------------------------------------------
-- Executes when a writ is removed from the quest journal by the user, OR
-- when the quest is completed by the user (called by endWrit()). If the
-- removed quest matches the name of a writ quest, all data about that quest
-- is removed and the boolean of whether the user has that crafting quest or
-- not is set to false.
--
-- @param code           The code of the quest removed - unused.
-- @param complete       Boolean if quest is completed - unused.
-- @param index          Index in journal where removed quest was - unused.
-- @param name           Name of the removed quest - used.
-----------------------------------------------------------------------------
function WritHelper.delWrit(code, completed, index, name)
  if name == 'Blacksmith Writ' then 
    WritHelperCraftingTitle:SetText(string.format(''))
    WritHelperCraftingObjective:SetText(string.format(''))
    WritHelper.smithing = ''
    WritHelper.hasSmithing = false
  elseif name == 'Clothier Writ' then
    WritHelperCraftingTitle:SetText(string.format(''))
    WritHelperCraftingObjective:SetText(string.format(''))
    WritHelper.clothing = ''
    WritHelper.hasClothing = false
  elseif name == 'Enchanter Writ' then
    WritHelperCraftingTitle:SetText(string.format(''))
    WritHelperCraftingObjective:SetText(string.format(''))
    WritHelper.enchanting = ''
    WritHelper.hasEnchanting = false
  elseif name == 'Alchemist Writ' then
    WritHelperCraftingTitle:SetText(string.format(''))
    WritHelperCraftingObjective:SetText(string.format(''))
    WritHelper.alchemy = ''
    WritHelper.hasAlchemy = false
  elseif name == 'Provisioner Writ' then
    WritHelperCraftingTitle:SetText(string.format(''))
    WritHelperCraftingObjective:SetText(string.format(''))
    WritHelper.provisioning = ''
    WritHelper.hasProvisioning = false
  elseif name == 'Woodworker Writ' then
    WritHelperCraftingTitle:SetText(string.format(''))
    WritHelperCraftingObjective:SetText(string.format(''))
    WritHelper.woodworking = ''
    WritHelper.hasWoodworking = false
  end
end

-----------------------------------------------------------------------------
-- Executed when a writ is completed by turning in crafted items. Calls
-- delWrit() with all params but name being nil as they are not used.
--
-- @param code           Code of the quest that was turned in - unused.
-- @param name           Name of the quest that was completed - used.  
-----------------------------------------------------------------------------
function WritHelper.endWrit(code, name)
  WritHelper.delWrit(nil, nil, nil, name)
end

-----------------------------------------------------------------------------
-- Executed by crating(). Updates text on UI with appropriate text for
-- matching crafting station using data previously gathered about writ
-- quests as they were picked up.
--
-- @param craftSkill     Code corresponding to the type of crafting station
--                       that the user is interacting with.
-----------------------------------------------------------------------------
function WritHelper:updateCraft(craftSkill)
  if craftSkill == 1 and WritHelper.hasSmithing then
    WritHelperCraftingTitle:SetText(string.format('Blacksmith Writ'))
    WritHelperCraftingObjective:SetText(string.format(WritHelper.smithing))
  elseif craftSkill == 2 and WritHelper.hasClothing then
    WritHelperCraftingTitle:SetText(string.format('Clothier Writ'))
    WritHelperCraftingObjective:SetText(string.format(WritHelper.clothing))
  elseif craftSkill == 3 and WritHelper.hasEnchanting then
    WritHelperCraftingTitle:SetText(string.format('Enchanter Writ'))
    WritHelperCraftingObjective:SetText(string.format(WritHelper.enchanting))
  elseif craftSkill == 4 and WritHelper.hasAlchemy then
    WritHelperCraftingTitle:SetText(string.format('Alchemist Writ'))
    WritHelperCraftingObjective:SetText(string.format(WritHelper.alchemy))
  elseif craftSkill == 5 and WritHelper.hasProvisioning then
    WritHelperCraftingTitle:SetText(string.format('Provisioner Writ'))
    WritHelperCraftingObjective:SetText(string.format(WritHelper.provisioning))
  elseif craftSkill == 6 and WritHelper.hasWoodworking then
    WritHelperCraftingTitle:SetText(string.format('Woodworker Writ'))
    WritHelperCraftingObjective:SetText(string.format(WritHelper.woodworking))
  end
end

-----------------------------------------------------------------------------
-- Executed when the user interacts with a crafting station.
-- Updates the UI with the appropriate writ information for that crafting
-- station, as well as displaying the UI.
--
-- @param craftSkill     Code corresponding to the type of crafting station
--                       that the user is interacting with.
-----------------------------------------------------------------------------
function WritHelper:crafting(craftSkill)
  WritHelper:updateCraft(craftSkill)
  isCraft = true
  WritHelperCrafting:SetHidden(false)
end

-----------------------------------------------------------------------------
-- Executed when the userleaves a crafting station.
-- Clears and hides the UI.
--
-----------------------------------------------------------------------------
function WritHelper:endCraft()
  WritHelperCraftingTitle:SetText(string.format(''))
  WritHelperCraftingObjective:SetText(string.format(''))
  isCraft = false
  WritHelperCrafting:SetHidden(true)
end

-----------------------------------------------------------------------------
-- development code for loading quests on startup - IGNORE
-----------------------------------------------------------------------------
-- function WritHelper:initQuests()
	-- d(GetNumJournalQuests())
	-- for i = 1, GetNumJournalQuests(), 1 do
		-- d(GetJournalQuestType(i))
	-- end
-- end

-----------------------------------------------------------------------------
-- Executes when an addon is loaded. Determines if the addon that was loaded
-- was this addon, and if so it then executes the initialization function.
--
-- @param event          ??
-- @param addonName      Name of the addon that was loaded.
-----------------------------------------------------------------------------
function WritHelper.OnAddOnLoaded(event, addonName)
  if addonName == WritHelper.name then
    WritHelper:Initialize()
    -- zo_callLater(function()WritHelper:initQuests()end, 5000) --IGNORE
  end
end
 
-- Starts addon
EVENT_MANAGER:RegisterForEvent(WritHelper.name, EVENT_ADD_ON_LOADED, WritHelper.OnAddOnLoaded)
