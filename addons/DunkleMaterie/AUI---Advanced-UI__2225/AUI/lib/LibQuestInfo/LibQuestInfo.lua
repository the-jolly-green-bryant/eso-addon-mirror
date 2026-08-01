
--Register LAM with LibStub
local MAJOR, MINOR = "LibQuestInfo", 1
local lqi, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not lqi then return end	--the same or newer version of this lib is already loaded into memory 



--==========================================================--
--==========================================================--
--============== GET QUEST INFO ============================--
--==========================================================--
--==========================================================--

-- Get the current step information, not a hidden step, for the given quest
function lqi:GetCurrentQuestStepInfo(journalQuestIndex)
	local numSteps = GetJournalQuestNumSteps(journalQuestIndex)
	
	for stepIndex = 1, numSteps do
		if not isComplete then 
			local stepText, visibility, stepType, trackerOverrideText, numConditions  = GetJournalQuestStepInfo(journalQuestIndex, stepIndex)
			
			if visibility ~= QUEST_STEP_VISIBILITY_HIDDEN then
				local questData = {
					stepIndex			= stepIndex,
					stepText 			= stepText,
					visibility			= visibility,  	-- will never be hidden
					stepType 			= stepType,
					trackerOverrideText	= trackerOverrideText,
					numConditions		= numConditions,
				}
				
				return true, questData
			end
		end
	end
end

-- Get the current condition information, not failed & not completed, for the given step
function lqi:GetCurrentConditionInfo(journalQuestIndex, stepIndex)
	local conditions = {}
	
	local numConditions = GetJournalQuestNumConditions(journalQuestIndex, stepIndex)
	
	for conditionIndex = 1, numConditions do
		local conditionText, current, max, isFailCondition, isComplete, isCreditShared = GetJournalQuestConditionInfo(journalQuestIndex, stepIndex, conditionIndex) 
		
		if((not isFailCondition) and (conditionText ~= "") and not isComplete) then
			local conditionData = {
				conditionText	= conditionText,
				current			= current,
				max				= max,
				isFailCondition	= isFailCondition, 	-- will never be true, were only capturing current conditions
				isComplete		= isComplete, 		-- will never be true, were only capturing current conditions
				isCreditShared	= isCreditShared,
			}
			table.insert(conditions, conditionData)
		end
	end
	return conditions
end
	
-- Get the current information, (not hidden, failed, or completed) step & condition info, for the given quest
function lqi:GetCurrentQuestInfo(journalQuestIndex)
	local foundValidStep, stepData = self:GetCurrentQuestStepInfo(journalQuestIndex)
	
	if not foundValidStep then return end
	
	local questInfo = {}
	
	local questLevel = GetJournalQuestLevel(journalQuestIndex)
	
	questInfo.level 				= questLevel
	questInfo.stepIndex				= stepData.stepIndex
	questInfo.stepText				= stepData.stepText
	questInfo.visibility			= stepData.visibility
	questInfo.stepType				= stepData.stepType
	questInfo.trackerOverrideText 	= stepData.trackerOverrideText
	questInfo.numConditions 		= stepData.numConditions
	
	local conditions = self:GetCurrentConditionInfo(journalQuestIndex, questInfo.stepIndex)
	
	--[[ although this info is supposed to be used for text instead of conditions...let 
	-- the addon handle that part itself...just in case they need the other condition info for something
	if(trackerOverrideText and trackerOverrideText ~= "") then
		local fOverrideStepText = zo_strformat(SI_QUEST_HINT_STEP_FORMAT, trackerOverrideText)
		table.insert(conditions, {conditionIndex = (#conditions+1), conditionText = fOverrideStepText})
	end
	--]]
	questInfo.conditions = conditions
	
	return questInfo
end


--==========================================================--
--==========================================================--
--============== QUEST TOOLTIPS ============================--
--==========================================================--
--==========================================================--
-- Below code is used to build a quest tooltip for a given journalQuestIndex
--==========================================================--
--==========================================================--

-- Adds the given line to the tooltip, padUp determines if we
-- want to remove vertical padding before inserting the line
local function AddTooltipLine(tooltip, line, padUp)
	if padUp then
		tooltip:AddVerticalPadding(-10) 
	end
	tooltip:AddLine(line, "ZoFontGame", 1, 1, 1, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
end



-- Adds the condition texts for a given quest/step to the tooltip
local function AddStepConditionsToTooltip(tooltip, journalQuestIndex, stepIndex, numConditions, stepVisibility, conditionsAreOR, trackerOverrideText)
	--[[ This is when you have multiple choices but each have the same condition text. Use the override text to display it only once so it doesn't repeat the same condition text over & over.
	--]]
	if(trackerOverrideText and trackerOverrideText ~= "") then
		local fOverrideStepText = zo_strformat(SI_QUEST_HINT_STEP_FORMAT, trackerOverrideText)
		
		AddTooltipLine(tooltip, fOverrideStepText, false)
		return
	end
	
	-- Loop through the coditions & add their text to the tooltip
	for conditionIndex = 1, numConditions do
		local conditionText, current, max, isFailCondition, isComplete, isCreditShared = GetJournalQuestConditionInfo(journalQuestIndex, stepIndex, conditionIndex) 
		
		if((not isFailCondition) and (conditionText ~= "") and not isComplete) then
			if stepVisibility == QUEST_STEP_VISIBILITY_HINT then
				local fHintConditionText = zo_strformat(SI_QUEST_HINT_STEP_FORMAT, conditionText)
				AddTooltipLine(tooltip, fHintConditionText, true)
				
			elseif conditionsAreOR then
				local fOrConditionText = zo_strformat(SI_QUEST_OR_CONDITION_FORMAT, conditionText)
				AddTooltipLine(tooltip, fOrConditionText, true)
				
			-- No idea wtf This is for, couldn't figure it out so I'll just exclude it
			-- I'm guessing it has something to do with the quest being done & there are no more conditions.
			elseif conditionText ~= "TRACKER GOAL TEXT" then
				local fConditionText = conditionText
				AddTooltipLine(tooltip, fConditionText, true)
			end
		end
	end
end



-- Adds all step (and calls to add condition) text to the tooltip
local function AddStepsToTooltip(tooltip, journalQuestIndex, tStepsByVisibility, stepVisibility)
	local iQuestStepFormatSI 	= SI_QUEST_JOURNAL_TEXT
	local next 					= next
	local yellow				= "|cFFFF00"
	
	-- no steps to complete, return
	if next(tStepsByVisibility[stepVisibility]) == nil then return end
	
	-- Setup headers for Hints & optional steps:
	if stepVisibility == QUEST_STEP_VISIBILITY_HINT then
		local fStepHintHeader = zo_strformat("<<1>><<2>>|r", yellow, GetString(SI_QUEST_HINT_STEP_HEADER))
		AddTooltipLine(tooltip, fStepHintHeader, false)
		
		iQuestStepFormatSI = SI_QUEST_HINT_STEP_FORMAT
		
	elseif stepVisibility == QUEST_STEP_VISIBILITY_OPTIONAL then
		local fOptionalStepHeader = zo_strformat("<<1>><<2>>|r", yellow, GetString(SI_QUEST_OPTIONAL_STEPS_DESCRIPTION))
		AddTooltipLine(tooltip, fOptionalStepHeader, false)
	end
	
	for k, stepIndex in pairs(tStepsByVisibility[stepVisibility]) do
		local stepText, visibility, stepType, trackerOverrideText, numConditions = GetJournalQuestStepInfo(journalQuestIndex, stepIndex)
			
		if stepText and stepText ~= "" then
			local fStepText = zo_strformat(iQuestStepFormatSI, stepText)
			AddTooltipLine(tooltip, fStepText, false)
			
			ZO_Tooltip_AddDivider(tooltip)
			tooltip:AddVerticalPadding(10)
		end
		
		local conditionsAreOR = stepType == QUEST_STEP_TYPE_OR and numConditions > 1
		
		-- Sets up the header for the or condition when you have multiple condition choices and only have to complete one.
		if conditionsAreOR then
			--local fOrStepHeader = WAYPOINTIT.color.yellow..GetString(SI_QUEST_OR_DESCRIPTION).."|r"
			local fOrStepHeader = zo_strformat("<<1>><<2>>|r", yellow, GetString(SI_QUEST_OR_DESCRIPTION))
			AddTooltipLine(tooltip, fOrStepHeader, false)
		end
		
		-- Add all needed condition text for this step to the tooltip
		AddStepConditionsToTooltip(tooltip, journalQuestIndex, stepIndex, numConditions, stepVisibility, conditionsAreOR, trackerOverrideText)
		--[[
		-- If its the end of the quest nothing left, so display that.
		if stepType == QUEST_STEP_TYPE_END  then
			local fEndOfQuest = WAYPOINTIT.color.yellow.."End of quest|r"
			AddTooltipLine(tooltip, fEndOfQuest, true)
		end
		--]]
	end
end


--[[ returns a table of step indices organized by visibility so we can reorder how things are displayed in the tooltip. First required steps, then optional steps, then hints.
--]]
local function GetStepsByVisibility(journalQuestIndex)
	local numSteps = GetJournalQuestNumSteps(journalQuestIndex)
	
	local tStepIndices = {}
	tStepIndices[QUEST_STEP_VISIBILITY_HINT] = {}
	tStepIndices[QUEST_STEP_VISIBILITY_OPTIONAL] = {}
	tStepIndices[QUEST_STEP_VISIBILITY_HIDDEN] = {}
	
	for stepIndex=1, numSteps do
		local stepText, visibility, stepType, trackerOverrideText, numConditions = GetJournalQuestStepInfo(journalQuestIndex, stepIndex)
		
		if not visibility then visibility = QUEST_STEP_VISIBILITY_HIDDEN end
		
		table.insert(tStepIndices[visibility], stepIndex)
	end
	return tStepIndices
end


-- Gets the instance tooltip text for a quest
local function GetInstanceTooltipText(journalQuestIndex)
	local instanceDisplayType = GetJournalInstanceDisplayType(journalQuestIndex)
	
	local sText = QUEST_JOURNAL_KEYBOARD:GetTooltipText(instanceDisplayType)

	if sText and sText ~= "" then
		local red = "|cFF0000"
		
		return zo_strformat("<<1>><<2>>|r", red, sText)
	end
end



-- Grab the formatted repeatable text for a quest
local function GetRepeatableTooltipText(journalQuestIndex)
    local iRepeatType 	= GetJournalQuestRepeatType(journalQuestIndex)
	local green			= "|c00FF00"
	
    if iRepeatType == QUEST_REPEAT_DAILY then
		local repeatableText = zo_strformat(SI_QUEST_JOURNAL_REPEATABLE_QUEST_TYPE, GetString(SI_QUEST_JOURNAL_REPEATABLE_TEXT), GetString(SI_QUESTREPEATABLETYPE2))
		
		return zo_strformat("<<1>><<2>>|r", green, repeatableText)
		
    elseif iRepeatType == QUEST_REPEAT_REPEATABLE then
		return zo_strformat("<<1>><<2>>|r", green, GetString(SI_QUEST_JOURNAL_REPEATABLE_TEXT))
    end
end


-- Makes calls to add all of the information to the tooltip for the quest
function lqi:CreateQuestTooltip(journalQuestIndex, tooltip)
	local yellow 			= "|cFFFF00"
	local sQuestZoneName 	= GetJournalQuestLocationInfo(journalQuestIndex)
	local sQuestName, backgroundText, _, _, _, _, _, iLevel, _, _, _ = GetJournalQuestInfo(journalQuestIndex)
	
	-- Con Color Definition for formatting Questname & level
    local conColorDef = ZO_ColorDef:New(GetConColor(iLevel))
	
	
	-------------------------------------------------
	------- Basic Quest Info: Top section  ----------
	-------------------------------------------------
	local colorizedQuestName = conColorDef:Colorize(zo_strformat(SI_QUEST_JOURNAL_QUEST_NAME_FORMAT, sQuestName))
	local fQuestName = zo_strformat("<<1>><<2>>:|r <<3>>", yellow, "Quest Name", colorizedQuestName)
	
	
	AddTooltipLine(tooltip, fQuestName, false)
	
	local fZoneName = zo_strformat(SI_ZONE_NAME, sQuestZoneName)
	
	if not fZoneName or fZoneName == "" then
		fZoneName = zo_strformat("<<1>><<2>>|r", yellow, GetString(SI_WINDOW_TITLE_WORLD_MAP_NO_ZONE))
	else
		fZoneName = zo_strformat("<<1>><<2>>: <<3>>|r", yellow, GetString(SI_CHAT_CHANNEL_NAME_ZONE), fZoneName)
	end
	AddTooltipLine(tooltip, fZoneName, true)
	
	local fLevel = conColorDef:Colorize(zo_strformat(SI_QUEST_JOURNAL_QUEST_LEVEL, tostring(iLevel)))
	AddTooltipLine(tooltip, fLevel, true)
	
	local fRepeatText = GetRepeatableTooltipText(journalQuestIndex)
	if fRepeatText then
		AddTooltipLine(tooltip, fRepeatText, true)
	end
	
	local fInstanceText = GetInstanceTooltipText(journalQuestIndex)
	if fInstanceText then
		AddTooltipLine(tooltip, fInstanceText, true)
	end
	
	-------------------------------------------------
	-- Add a divider before background text	---------
	-------------------------------------------------
	ZO_Tooltip_AddDivider(tooltip)
	
	
	-------------------------------------------------
	------------- Background text	-----------------
	-------------------------------------------------
	local fBackgroundStory = zo_strformat(SI_QUEST_JOURNAL_MAIN_STORY_FORMAT, backgroundText)
	local fBackgroundText = zo_strformat("<<1>><<2>>:|r <<3>>", yellow, "Background", fBackgroundStory)
	AddTooltipLine(tooltip, fBackgroundText, false)
	
	-------------------------------------------------
	-- No divider between background & step text
	-------------------------------------------------
	
	-------------------------------------------------
	-------- Add step & condition text --------------
	-------------------------------------------------
	-- Grab an organized table of step indices. It organizes steps
	-- based on visibility, so I can print out required steps first,
	-- then optional steps, then hints
	local tStepsByVisibility = GetStepsByVisibility(journalQuestIndex)
	local next = next
	
	-- Each also make a call to add their own conditions
	-- if no steps to complete, return
	if next(tStepsByVisibility[QUEST_STEP_VISIBILITY_HIDDEN]) ~= nil then 
		ZO_Tooltip_AddDivider(tooltip)
		AddStepsToTooltip(tooltip, journalQuestIndex, tStepsByVisibility, QUEST_STEP_VISIBILITY_HIDDEN)
	end
	if next(tStepsByVisibility[QUEST_STEP_VISIBILITY_OPTIONAL]) ~= nil then 
		ZO_Tooltip_AddDivider(tooltip)
		AddStepsToTooltip(tooltip, journalQuestIndex, tStepsByVisibility, QUEST_STEP_VISIBILITY_OPTIONAL)
	end
	if next(tStepsByVisibility[QUEST_STEP_VISIBILITY_HINT]) ~= nil then 
		ZO_Tooltip_AddDivider(tooltip)
		AddStepsToTooltip(tooltip, journalQuestIndex, tStepsByVisibility, QUEST_STEP_VISIBILITY_HINT)
	end
end















