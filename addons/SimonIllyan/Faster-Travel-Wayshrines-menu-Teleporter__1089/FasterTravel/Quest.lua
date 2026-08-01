
local Quest = FasterTravel.Quest or {}


local function GetQuests()

	local count = MAX_JOURNAL_QUESTS
	
	local quests = {}
	
	local questName,backgroundText,activeStepText,activeStepType, activeStepTrackerOverrideText, completed, tracked, questLevel,pushed,questType,instanceDisplayType
	local zoneName, objectiveName, zoneIndex, poiIndex
	for i =1, count do
		if IsValidQuestIndex(i) == true then 
			questName,backgroundText,activeStepText,activeStepType, activeStepTrackerOverrideText, completed, tracked, questLevel,pushed,questType,instanceDisplayType=GetJournalQuestInfo(i)
			zoneName, objectiveName, zoneIndex, poiIndex = GetJournalQuestLocationInfo(i)
			table.insert(quests,{index=i,name=questName,zoneName = zoneName,objectiveName=objectiveName,zoneIndex=zoneIndex,poiIndex=poiIndex,questType=questType})
		end
	end
	
	return quests
end

local function TryAddJournalQuestConditionAssistanceTask(tasks,callback,questIndex, stepIndex, conditionIndex, assisted)
	local taskId = RequestJournalQuestConditionAssistance(questIndex, stepIndex, conditionIndex, assisted)
	if taskId ~= nil then
		tasks[taskId]={id=taskId,callback=callback,questIndex=questIndex,stepIndex=stepIndex,conditionIndex=conditionIndex,assisted=assisted}
		return true
	end
	return false
end

local _tasks = {}

local function GetQuestLocations(questIndex,callback)
	local assisted = GetTrackedIsAssisted(TRACK_TYPE_QUEST, questIndex)
	
	local added
	
	if(GetJournalQuestIsComplete(questIndex)) then
		added = TryAddJournalQuestConditionAssistanceTask(_tasks,callback,questIndex, QUEST_MAIN_STEP_INDEX, 1, assisted)
	else
		for stepIndex = QUEST_MAIN_STEP_INDEX, GetJournalQuestNumSteps(questIndex) do
			for conditionIndex = 1, GetJournalQuestNumConditions(questIndex, stepIndex) do
				local _, _, isFailCondition, isComplete = GetJournalQuestConditionValues(questIndex, stepIndex, conditionIndex)
				if(not (isFailCondition or isComplete)) then
					if TryAddJournalQuestConditionAssistanceTask(_tasks,callback,questIndex, stepIndex, conditionIndex, assisted) == true then
						added = true 
					end
				end
			end
		end
	end
	
	if added == false then
		callback({
					questIndex = questIndex,
					hasPosition = false
				})
	end
end




local function OnQuestPositionRequestComplete(eventCode, taskId, pinType, xLoc, zLoc, areaRadius, insideCurrentMapWorld, isBreadcrumb)
	local task = _tasks[taskId]
	if task == nil then return end 
	local insideBounds = (xLoc >= 0 and xLoc <= 1 and zLoc >= 0 and zLoc <= 1)
	local callback = task.callback
	if callback == nil then return end 
	callback({	
					questIndex = task.questIndex,
					stepIndex = task.stepIndex,
					conditionIndex=task.conditionIndex,
					assisted=task.assisted,
					hasPosition = true,
					pinType=pinType, 
					normalizedX=xLoc, 
					normalizedY=zLoc, 
					areaRadius=areaRadius, 
					insideCurrentMapWorld=insideCurrentMapWorld, 
					isBreadcrumb=isBreadcrumb, 
					insideBounds=insideBounds
				})
	_tasks[taskId] = nil 
end

FasterTravel.addEvent(EVENT_QUEST_POSITION_REQUEST_COMPLETE,OnQuestPositionRequestComplete)

Quest.GetQuestLocations = GetQuestLocations
Quest.GetQuests = GetQuests
Quest.GetQuestLocations = GetQuestLocations

FasterTravel.Quest = Quest