ZDAT = ZDAT or {}
ZDAT.name = "ZoneDailiesAchievementTracker"
ZDAT.author = "@psi-pisi"

ZDAT.questStatuses = {}

function ZDAT.Initialize()
  ZDAT.Utils.SvInit()

  -- Register Keybinding Menu
  ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_ZDAT", "Toggle Tracker")

  SLASH_COMMANDS["/zdat"] = function(keyWord, argument) ZDAT.UI.Layout.toggleWindow() end

  ZDAT.Screens.Screen.initialize()

  ZDAT.UI.Layout.refresh()

  SCENE_MANAGER:RegisterTopLevel(ZDAT_GUI, locksUIMode)

  --Unregister Loaded Callback
  EVENT_MANAGER:UnregisterForEvent(ZDAT.name, EVENT_ADD_ON_LOADED);
end

function ZDAT.OnAddOnLoaded(addOnName)
  if (addOnName ~= ZDAT.name) then
    ZDAT.Initialize()
    
    EVENT_MANAGER:RegisterForEvent(ZDAT.name, EVENT_QUEST_COMPLETE, ZDAT.onQuestComplete)
    EVENT_MANAGER:RegisterForEvent(ZDAT.name, EVENT_QUEST_ADDED, ZDAT.onQuestAdded)
    EVENT_MANAGER:RegisterForEvent(ZDAT.name, EVENT_ACHIEVEMENTS_SEARCH_RESULTS_READY, ZDAT.achievementSearchCallback)
  end
end

function ZDAT.onQuestAdded(eventCode, journalIndex, questName, objectiveName)

  -- to check zone for the quests that share the same name 
  local zone = GetPlayerActiveZoneName()

	-- if this is one of the daily quests we track, then update the quest status
  local achievementId = ZDAT.Data.Quests.isDailyQuest(questName, zone)
	if achievementId ~= -1 then
    ZDAT.questStatuses = ZDAT.Utils.getForChar(GetCurrentCharacterId()).questStatuses

    ZDAT.questStatuses[achievementId] = {
      addedTime = ZDAT.Utils.getCurrentTime(),
      isCompleted = false
    }

    d(ZDAT.name .. " > [".. questName .. "] is added to the tracker.")
	end
  ZDAT.Utils.getForChar(GetCurrentCharacterId()).questStatuses = ZDAT.questStatuses
end


function ZDAT.onQuestComplete(eventCode, questName, level, previousExperience, currentExperience, championPoints, questType, instanceDisplayType)
  -- to check zone for the quests that share the same name 
  local zone = GetPlayerActiveZoneName()

  local achievementId = ZDAT.Data.Quests.isDailyQuest(questName, zone)
	if achievementId ~= -1 then
    ZDAT.questStatuses = ZDAT.Utils.getForChar(GetCurrentCharacterId()).questStatuses

    if ZDAT.questStatuses[achievementId] ~= nil then
      ZDAT.questStatuses[achievementId].isCompleted = true
      d(ZDAT.name .. " > [".. questName .. "] is marked as completed.")
    end
  end

  ZDAT.Utils.getForChar(GetCurrentCharacterId()).questStatuses = ZDAT.questStatuses
end

-- On Journal Search Result ----------------------
ZDAT.ACHIEVEMENTAID = 0
function ZDAT.achievementSearchCallback()
  -- limit to just searches trigged by addon
	if ACHIEVEMENTS.contentSearchEditBox:GetText() == GetAchievementName(ZDAT.ACHIEVEMENTAID) then
		-- navigate to category
		local categoryIndex, subCategoryIndex, achievementIndex = GetCategoryInfoFromAchievementId(ZDAT.ACHIEVEMENTAID)
		ACHIEVEMENTS:OpenCategory(categoryIndex, subCategoryIndex)
		-- expand achievement
		if ACHIEVEMENTS.achievementsById[ZDAT.ACHIEVEMENTAID] then
			ACHIEVEMENTS.achievementsById[ZDAT.ACHIEVEMENTAID]:Expand()
		end
	end
end

-- For future updates - to get the quest id
--[[
function ZDAT.onQuestRemoved(eventCode, isCompleted, journalIndex, questName, zoneIndex, poiIndex, questID)
  d("questName: " .. questName .. " - questId: " .. questID)
	-- if this is one of the daily quests we track, then update the quest status
end
EVENT_MANAGER:RegisterForEvent(ZDAT.name, EVENT_QUEST_REMOVED, ZDAT.onQuestRemoved)
]]

EVENT_MANAGER:RegisterForEvent(ZDAT.name, EVENT_ADD_ON_LOADED, ZDAT.OnAddOnLoaded);