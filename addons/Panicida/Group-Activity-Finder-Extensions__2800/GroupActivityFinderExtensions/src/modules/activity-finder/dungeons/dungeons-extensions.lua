-- =============================================================================
-- Localized Globals
-- =============================================================================
local EVENT_MANAGER = EVENT_MANAGER
local pairs = pairs

local GAFE = GroupActivityFinderExtensions
local DungeonCommands = GAFE.DungeonCommands
local RewardTracker = GAFE.RewardTracker
local PledgeTracker = GAFE.PledgeTracker
local dungeonData = GAFE.DUNGEONS_ACTIVITY_DATA

-- =============================================================================
-- Module Declaration
-- =============================================================================
local DungeonsExtensions = {
  extender = GAFE.ActivityFinderExtender:New()
}
local extender = DungeonsExtensions.extender


-- =============================================================================
-- Private Functions - Dungeon Difficulty
-- =============================================================================
local dungeonActivityType = nil

--- Refreshes the dungeon difficulty based on settings and group difficulty.
local function refreshDungeonActivityType()
  dungeonActivityType = DungeonCommands.GetCurrentDungeonActivityType()
end

--- Collapses dungeon difficulty sections based on settings.
local function collapse()
  local function doCollapse()
    refreshDungeonActivityType()
    for c = 2, 3 do
      local header = _G[
      extender.root ..
      "Finder_KeyboardListSectionScrollChildZO_ActivityFinderTemplateNavigationHeader_Keyboard" ..
      c - 1]
      if header then
        local state = header.text:GetColor()
        if ((dungeonActivityType ~= c) == (state == 1)) then
          header:OnMouseUp(true)
        end
      end
    end
  end

  LibPanicida.Utils.CallLater(GAFE.name .. extender.root .. "_Extensions", 200,
    doCollapse)
end

-- =============================================================================
-- Private Functions - Queue Operations
-- =============================================================================

--- Queues dungeons for incomplete pledges at the current difficulty.
local function queueForPledges()
  DungeonCommands.Pledges()
end

--- Queues dungeons with incomplete quests at the current difficulty.
local function queueForMissingQuests()
  DungeonCommands.Quests()
end

--- Queues dungeons with incomplete item sets at the current difficulty.
local function queueForMissingSets()
  DungeonCommands.Sets()
end

--- Queues a random dungeon at the current effective difficulty.
local function queueForRandomDungeon()
  DungeonCommands.Dungeon()
end

-- =============================================================================
-- Private Functions - Event Handlers
-- =============================================================================

--- Event handler for when a quest is added to the journal.
local function onQuestAdded(_, _journalIndex_, _questName_, _objectiveName_)
  PledgeTracker.UpdateTodayPledges()
  PledgeTracker.UpdatePledgesInJournal()
  DUNGEON_FINDER_KEYBOARD.navigationTree:Reset()
end

--- Event handler for when a quest is removed from the journal.
local function onQuestRemoved(_, _isCompleted_, _journalIndex_, _questName_,
                              _zoneIndex_, _poiIndex_, _questID_)
  local isCompleted, questName = _isCompleted_, _questName_
  local pledgeId = PledgeTracker.QuestNameToPledgeId(questName)

  if isCompleted and pledgeId then
    PledgeTracker.MarkPledgeDone(pledgeId)
  end

  PledgeTracker.UpdateTodayPledges()
  PledgeTracker.UpdatePledgesInJournal()
  DUNGEON_FINDER_KEYBOARD.navigationTree:Reset()
end

-- =============================================================================
-- Public Functions
-- =============================================================================

--- Initializes the dungeon extensions module.
function DungeonsExtensions.Init()
  local treeEntry = DUNGEON_FINDER_KEYBOARD.navigationTree.templateInfo
      .ZO_ActivityFinderTemplateNavigationEntry_Keyboard

  local characterId = GetCurrentCharacterId()
  local todayPledges = PledgeTracker.GetTodayPledges()

  local keybindStripGroup = {
    -- Active pledges
    {
      alignment = KEYBIND_STRIP_ALIGN_CENTER,
      name = GAFE.Loc("CheckActivePledges"),
      keybind = "UI_SHORTCUT_PRIMARY",
      callback = queueForPledges,
      visible = function()
        if IsCurrentlySearchingForGroup() then
          return false
        end

        local donePledges = GAFE.SavedVars.dungeons.donePledges[characterId]
        for _, pledgeId in ipairs(todayPledges) do
          if not LibPanicida.Utils.TableContainsKey(donePledges, pledgeId) then
            return false
          end
        end

        return true
      end
    },
    -- Missing quests
    {
      alignment = KEYBIND_STRIP_ALIGN_CENTER,
      name = GAFE.Loc("CheckMissingQuests"),
      keybind = "UI_SHORTCUT_SECONDARY",
      callback = queueForMissingQuests,
      enabled = true,
      visible = function() return not IsCurrentlySearchingForGroup() end
    },
    -- Missing sets
    {
      alignment = KEYBIND_STRIP_ALIGN_CENTER,
      name = GAFE.Loc("CheckMissingSets"),
      keybind = "UI_SHORTCUT_TERTIARY",
      callback = queueForMissingSets,
      visible = function()
        if IsCurrentlySearchingForGroup() then
          return false
        end

        local hasAllSets = true
        for _, activityData in pairs(extender.data) do
          for _, setId in pairs(activityData.sets) do
            local setCollectionData = ITEM_SET_COLLECTIONS_DATA_MANAGER
                :GetItemSetCollectionData(setId)
            local numUnlockedPieces, numPieces =
                setCollectionData:GetNumUnlockedPieces(),
                setCollectionData:GetNumPieces()
            if numUnlockedPieces ~= numPieces then
              hasAllSets = false
              break
            end
          end
          if not hasAllSets then break end
        end
        return not hasAllSets
      end,
    },
    -- Random dungeon
    {
      alignment = KEYBIND_STRIP_ALIGN_CENTER,
      name = GAFE.Loc("CheckRandomDungeon"),
      keybind = "UI_SHORTCUT_QUINARY",
      callback = queueForRandomDungeon,
      visible = function() return not IsCurrentlySearchingForGroup() end,
    },
  }

  local function customExtensions(node, control, data, open)
    local activityId = data.id
    local activityData = dungeonData[activityId]
    if activityData then
      PledgeTracker.AddPledge(activityData.p, control)
    end
  end

  local onActivityFinderStatusUpdate = RewardTracker.CreateCompletionHandler({
    activityType = LFG_ACTIVITY_DUNGEON,
    extender = extender,
    delayMs = 1000,
  })

  extender:Initialize({
    customExtensions = customExtensions,
    data = dungeonData,
    keybindStripGroup = keybindStripGroup,
    rewardsVars = GAFE.SavedVars.dungeons,
    root = "ZO_Dungeon",
    treeEntry = treeEntry,
  })

  -- Set collapse callback after initialization
  extender.onCollapse = collapse

  EVENT_MANAGER:RegisterForEvent(
    GAFE.name .. "_DungeonExtension_PlayerReady",
    EVENT_PLAYER_ACTIVATED,
    function()
      PledgeTracker.UpdateTodayPledges()
      PledgeTracker.UpdatePledgesInJournal()
    end
  )
  EVENT_MANAGER:RegisterForEvent(
    GAFE.name .. "_DungeonExtension_QuestAdded",
    EVENT_QUEST_ADDED,
    onQuestAdded
  )
  EVENT_MANAGER:RegisterForEvent(
    GAFE.name .. "_DungeonExtension_QuestRemoved",
    EVENT_QUEST_REMOVED,
    onQuestRemoved
  )
  EVENT_MANAGER:RegisterForEvent(
    GAFE.name .. extender.root .. "Activity_Update",
    EVENT_ACTIVITY_FINDER_STATUS_UPDATE,
    onActivityFinderStatusUpdate
  )
end

--- Gets pledges currently in journal with completion status.
--- @return table pledgesInJournal Map of pledgeId -> isCompleted
function DungeonsExtensions.GetPledgesInJournal()
  return PledgeTracker.GetPledgesInJournal()
end

-- ============================================================================
-- Module Registration
-- ============================================================================
GAFE.DungeonsExtensions = DungeonsExtensions
