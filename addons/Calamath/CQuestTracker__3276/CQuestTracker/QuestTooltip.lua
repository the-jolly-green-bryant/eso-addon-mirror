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
local L = GetString

-- ---------------------------------------------------------------------------------------
-- Template
-- ---------------------------------------------------------------------------------------
-- NOTE : This function is based on ZO_Tooltip_AddDivider by ZOS, with its own size adjustments for the UI design of the CQuestTracker add-on.
local function CQT_QuestTooltip_AddDivider(tooltip)
	if not tooltip.dividerPool then
		tooltip.dividerPool = ZO_ControlPool:New("CQT_QuestTooltipDivider", tooltip, "Divider")
		tooltip.dividerPool:SetCustomResetBehavior(function(divider)
			-- It is not necessary to reset the texture, but we still have a failsafe in case the texture is changed.
			divider:SetTexture("EsoUI/Art/Miscellaneous/horizontalDivider.dds")
		end)
	end

	local divider = tooltip.dividerPool:AcquireObject()
	if divider then
		tooltip:AddControl(divider)
		divider:SetAnchor(CENTER)
	end
end

-- ---------------------------------------------------------------------------------------
-- Quest Tooltip Controller Class
-- ---------------------------------------------------------------------------------------
local CQT_QuestTooltip_Controller = ZO_InitializingObject:MultiSubclass(CT_AdjustableInitializingObject, CT_TooltipController)
function CQT_QuestTooltip_Controller:Initialize(tooltip, overriddenAttrib)
	CT_AdjustableInitializingObject.Initialize(self, overriddenAttrib)
	CT_TooltipController.Initialize(self, tooltip)
	self.bg = self.tooltip:GetNamedChild("Background")
end

function CQT_QuestTooltip_Controller:AddDivider()
	return CQT_QuestTooltip_AddDivider(self.tooltip)
end


function CQT_QuestTooltip_Controller:GetNumVisibleQuestConditions(journalIndex, stepIndex)
	local visibleConditionCount = 0
	for conditionIndex = 1, GetJournalQuestNumConditions(journalIndex, stepIndex) do
		local _, _, _, _, _, isVisible = GetJournalQuestConditionValues(journalIndex, stepIndex, conditionIndex)
		if isVisible then
			visibleConditionCount = visibleConditionCount + 1
		end
	end
	return visibleConditionCount
end

function CQT_QuestTooltip_Controller:GetNumVisibleQuestHintSteps(journalIndex)
	local visibleHintCount = 0
	for stepIndex = QUEST_MAIN_STEP_INDEX + 1, GetJournalQuestNumSteps(journalIndex) do
		local _, stepVisibility, stepType = GetJournalQuestStepInfo(journalIndex, stepIndex)
		if stepType ~= QUEST_STEP_TYPE_END and stepVisibility == QUEST_STEP_VISIBILITY_HINT then
			visibleHintCount = visibleHintCount + self:GetNumVisibleQuestConditions(journalIndex, stepIndex)
		end
	end
	return visibleHintCount
end

function CQT_QuestTooltip_Controller:IsOrDescription(journalIndex, stepIndex)
	local _, _, stepType, overrideText = GetJournalQuestStepInfo(journalIndex, stepIndex)
	return (not overrideText or overrideText == "") and stepType == QUEST_STEP_TYPE_OR and self:GetNumVisibleQuestConditions(journalIndex, stepIndex) > 2
end

function CQT_QuestTooltip_Controller:IsMultipleDescriptions(journalIndex, stepIndex)
	local _, _, stepType, overrideText = GetJournalQuestStepInfo(journalIndex, stepIndex)
	return (not overrideText or overrideText == "") and (stepType == QUEST_STEP_TYPE_OR  or stepType == QUEST_STEP_TYPE_AND) and self:GetNumVisibleQuestConditions(journalIndex, stepIndex) > 2
end

function CQT_QuestTooltip_Controller:AddPrologueQuestDetails(journalIndex)
	local questId = GetQuestId(journalIndex)
	local questLinkedCollectibleId = GetQuestLinkedCollectibleId(questId)
	if questLinkedCollectibleId then
		self:AddLine(zo_strformat(SI_CQT_QUEST_DLC_PROLOGUE, GetCollectibleName(questLinkedCollectibleId)), "ZoFontGameMedium", 0, 1, 0, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
	else
		self:AddLine(zo_strformat(SI_CQT_QUEST_DLC_PROLOGUE, L(SI_INPUT_LANGUAGE_UNKNOWN)), "ZoFontGameMedium", 0, 1, 0, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
	end
end

function CQT_QuestTooltip_Controller:AddRepeatableQuestDetails(journalIndex)
	local repeatType = GetJournalQuestRepeatType(journalIndex)
	if repeatType ~= QUEST_REPEAT_NOT_REPEATABLE then
		if HasCompletedQuestByIndex(journalIndex) then
			self:AddLine(L(SI_CQT_QUEST_REPEATABLE_PREVIOUSLY_COMPLETED), "ZoFontGameMedium", 0, 1, 1, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
		else
			self:AddLine(L(SI_CQT_QUEST_REPEATABLE_NEVER_COMPLETED), "ZoFontGameMedium", 0, 1, 0, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
		end
	end
end

function CQT_QuestTooltip_Controller:AddQuestConditions(journalIndex, stepIndex)
	local _, stepVisibility, stepType, overrideText, conditionCount = GetJournalQuestStepInfo(journalIndex, stepIndex)
	if overrideText and overrideText ~= "" then
		local checked = stepType == QUEST_STEP_TYPE_AND
		if stepType ~= QUEST_STEP_TYPE_END then
			for conditionIndex = 1, conditionCount do
				local _, _, isFailCondition, isComplete = GetJournalQuestConditionValues(journalIndex, stepIndex, conditionIndex)
				if (not isFailCondition) and isComplete then
					if stepType ~= QUEST_STEP_TYPE_AND then
						checked = true
						break
					end
				else
					if stepType == QUEST_STEP_TYPE_AND then
						checked = false
						break
					end
				end
			end
		end
		if checked then
			self:AddLine(zo_strformat(SI_CQT_QUEST_LIST_CHECKED_FORMATTER, overrideText), "ZoFontGameMedium", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
		else
			self:AddLine(zo_strformat(SI_CQT_QUEST_LIST_NORMAL_FORMATTER, overrideText), "ZoFontGameMedium", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
		end
	else
		for conditionIndex = 1, conditionCount do
			local conditionText, curCount, maxCount, isFailCondition, isComplete, isGroupCreditShared, isVisible, conditionType = GetJournalQuestConditionInfo(journalIndex, stepIndex, conditionIndex)
			if (not isFailCondition) and (conditionText ~= "") and isVisible then
				if isComplete or (curCount == maxCount) then
					self:AddLine(zo_strformat(SI_CQT_QUEST_LIST_CHECKED_FORMATTER, conditionText), "ZoFontGameMedium", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
				else
					self:AddLine(zo_strformat(SI_CQT_QUEST_LIST_NORMAL_FORMATTER, conditionText), "ZoFontGameMedium", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
				end
			end
		end
	end
end

function CQT_QuestTooltip_Controller:SetupBackground(journalIndex)
	local questId = GetQuestId(journalIndex)
	local bgTexture = GetQuestBackgroundTexture(questId)
	if bgTexture then
		self.bg:SetTexture(bgTexture)
		if self.bg:GetTextureFileDimensions() > 1024 then
			-- load screen texture
			self.bg:SetTextureCoords(0.12083333, 0.87916666, 0, 1)
			self.bg:SetHeight(389.7806)
		else
			-- gp store texture
			self.bg:SetTextureCoords(0, 0.79492187, 0, 0.52929687)
			self.bg:SetHeight(314.6667)
		end
		self.bg:SetHidden(false)
	else
		bgTexture = GetZoneStoryKeyboardBackground(GetZoneStoryZoneIdForZoneId(GetParentZoneId(GetQuestZoneId(questId))))
		self.bg:SetTexture(bgTexture)
		self.bg:SetTextureCoords(0, 0.60546875, 0, 1)
		self.bg:SetHeight(389.7806)
		self.bg:SetHidden(bgTexture == GetZoneStoryKeyboardBackground(0))
	end
end

function CQT_QuestTooltip_Controller:LayoutQuestTooltip(journalIndex)
	local titleR, titleG, titleB = ZO_SELECTED_TEXT:UnpackRGB()
	local questName, backgroundText, activeStepText, activeStepType, activeStepTrackerOverrideText, completed, tracked, questLevel, pushed, questType, zoneDisplayType = GetJournalQuestInfo(journalIndex)
	local zoneName, _, pz = GetJournalQuestLocationInfo(journalIndex)
	local repeatType = GetJournalQuestRepeatType(journalIndex)
	local questIcon = GetZoneDisplayTypeIcon(zoneDisplayType)
	local bgTexture = GetZoneStoryKeyboardBackground(GetZoneId(pz))
	if self.bg then
		self:SetupBackground(journalIndex)
	end
	if questIcon then
		ZO_ItemIconTooltip_OnAddGameData(self.tooltip, TOOLTIP_GAME_DATA_ITEM_ICON, questIcon)
	end
	local questTypeName
	if questType == QUEST_TYPE_NONE and zoneName ~= "" then
		if zoneDisplayType == ZONE_DISPLAY_TYPE_ZONE_STORY then
			questTypeName = L(SI_CQT_QUESTTYPE_ZONE_STORY_QUEST)
		else
			questTypeName = L(SI_CQT_QUESTTYPE_SIDE_QUEST)
		end
	else
		questTypeName = L("SI_QUESTTYPE", questType)
	end
	self:AddHeaderLine(questTypeName, "ZoFontWinH5", 1, TOOLTIP_HEADER_SIDE_LEFT, ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
	self:AddHeaderLine(zo_strformat(SI_QUEST_JOURNAL_ZONE_FORMAT, zoneName), "ZoFontWinH5", 2, TOOLTIP_HEADER_SIDE_LEFT, ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
	if repeatType ~= QUEST_REPEAT_NOT_REPEATABLE then
		self:AddHeaderLine(L(SI_CQT_QUEST_REPEATABLE_TEXT), "ZoFontWinH5", 1, TOOLTIP_HEADER_SIDE_RIGHT, ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
	end
	self:AddLine(zo_strformat(SI_QUEST_JOURNAL_QUEST_NAME_FORMAT, questName), "ZoFontWinH2", titleR, titleG, titleB, TOPLEFT, MODIFY_TEXT_TYPE_UPPERCASE, TEXT_ALIGN_CENTER, true)
	self:AddVerticalPadding(18)
	self:AddDivider()
	if completed then
		local goalCondition, _, _, _, goalBackgroundText, goalStepText = GetJournalQuestEnding(journalIndex)
		self:AddLine(L(SI_CQT_QUEST_BACKGROUND_HEADER), "ZoFontGameMedium", titleR, titleG, titleB, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
		self:AddLine(goalBackgroundText, "ZoFontGameMedium", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
		self:AddLine(zo_strformat(L(SI_CQT_QUEST_OBJECTIVES_HEADER), 1), "ZoFontGameMedium", titleR, titleG, titleB, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
		self:AddLine(goalStepText, "ZoFontGameMedium", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
		self:AddDivider()
		self:AddLine(goalCondition, "ZoFontGameMedium", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
	else
		local objectivesHeader
		self:AddLine(L(SI_CQT_QUEST_BACKGROUND_HEADER), "ZoFontGameMedium", titleR, titleG, titleB, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
		self:AddLine(backgroundText, "ZoFontGameMedium", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
		if self:IsOrDescription(journalIndex, QUEST_MAIN_STEP_INDEX) then
			objectivesHeader = L(SI_CQT_QUEST_OBJECTIVES_OR_HEADER)
		else
			objectivesHeader = L(SI_CQT_QUEST_OBJECTIVES_HEADER)
		end
		self:AddLine(zo_strformat(objectivesHeader, self:IsMultipleDescriptions(journalIndex, QUEST_MAIN_STEP_INDEX) and 2 or 1), "ZoFontGameMedium", titleR, titleG, titleB, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
		self:AddLine(activeStepText, "ZoFontGameMedium", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
		self:AddDivider()
		self:AddQuestConditions(journalIndex, QUEST_MAIN_STEP_INDEX)
	end
	for stepIndex = QUEST_MAIN_STEP_INDEX + 1, GetJournalQuestNumSteps(journalIndex) do
		local optionalStepText, stepVisibility, stepType = GetJournalQuestStepInfo(journalIndex, stepIndex)
		if stepType ~= QUEST_STEP_TYPE_END and stepVisibility == QUEST_STEP_VISIBILITY_OPTIONAL then
			if self:IsOrDescription(journalIndex, stepIndex) then
				self:AddLine(L(SI_CQT_QUEST_OPTIONAL_STEPS_OR_DESCRIPTION), "ZoFontGameMedium", titleR, titleG, titleB, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
			else
				self:AddLine(L(SI_CQT_QUEST_OPTIONAL_STEPS_DESCRIPTION), "ZoFontGameMedium", titleR, titleG, titleB, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
			end
			if optionalStepText ~= "" then
				self:AddLine(optionalStepText, "ZoFontGameMedium", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
				self:AddDivider()
			end
			self:AddQuestConditions(journalIndex, stepIndex)
		end
	end
	local hintHeaderDisplayed = false
	local visibleHintCount = self:GetNumVisibleQuestHintSteps(journalIndex)
	if visibleHintCount > 0 then
		for stepIndex = QUEST_MAIN_STEP_INDEX + 1, GetJournalQuestNumSteps(journalIndex) do
			local _, stepVisibility, stepType = GetJournalQuestStepInfo(journalIndex, stepIndex)
			if stepType ~= QUEST_STEP_TYPE_END and stepVisibility == QUEST_STEP_VISIBILITY_HINT then
				if not hintHeaderDisplayed then
					self:AddDivider()
					self:AddLine(zo_strformat(L(SI_CQT_QUEST_HINT_STEPS_HEADER), visibleHintCount), "ZoFontGameMedium", titleR, titleG, titleB, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
					hintHeaderDisplayed = true
				end
				self:AddQuestConditions(journalIndex, stepIndex)
			end
		end
	end
	if questType == QUEST_TYPE_PROLOGUE then
		self:AddDivider()
		self:AddPrologueQuestDetails(journalIndex)
	end
	if repeatType ~= QUEST_REPEAT_NOT_REPEATABLE then
		self:AddDivider()
		self:AddRepeatableQuestDetails(journalIndex, repeatType)
	end
end

function CQT_QuestTooltip_Controller:HideQuestTooltip()
	self:ClearTooltip()
end

function CQT_QuestTooltip_Controller:ShowQuestTooltip(journalIndex, owner, point, offsetX, offsetY, relativePoint)
	self:InitializeTooltip(owner, point, offsetX, offsetY, relativePoint)
	self:LayoutQuestTooltip(journalIndex)
end

function CQT_QuestTooltip_Controller:ShowQuestTooltipNextToControl(journalIndex, owner, offsetX)
	local PADDING = offsetX or 10
	journalIndex = journalIndex or owner.journalIndex
	if journalIndex then
		local relativePoint = LEFT	-- or user preference
		if (owner:GetRight() + PADDING + self.tooltip:GetWidth()) > GuiRoot:GetRight() then
			relativePoint = LEFT
		elseif (owner:GetLeft() - PADDING - self.tooltip:GetWidth()) < GuiRoot:GetLeft() then
			relativePoint = RIGHT
		end
		if relativePoint == LEFT then
			self:InitializeTooltip(owner, RIGHT, 0 - PADDING, 0, LEFT)
		else
			self:InitializeTooltip(owner, LEFT, PADDING, 0, RIGHT)
		end
		self:LayoutQuestTooltip(journalIndex)
	end
end

-- Obsolete method
function CQT_QuestTooltip_Controller:ShowQuestTooltipNextToOwner(control, journalIndex)
	self:ShowQuestTooltipNextToControl(journalIndex or control.journalIndex, control:GetOwningWindow(), 10)		-- for compatibility
end

CQuestTracker:RegisterClassObject("CQT_QuestTooltip_Controller", CQT_QuestTooltip_Controller)

-- ---------------------------------------------------------------------------------------

local CQT_QUEST_TOOLTIP_MANAGER = CQT_QuestTooltip_Controller:New(CQT_QuestTooltip)

-- global API --
local function GetQuestTooltipManager() return CQT_QUEST_TOOLTIP_MANAGER end
CQT:RegisterSharedObject("GetQuestTooltipManager", GetQuestTooltipManager)

