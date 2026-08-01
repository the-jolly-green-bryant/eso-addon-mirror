BuddysWritStatusAddon = {
	Name = "BuddysWritStatus",
	Version = "1.3.0",
	WritStatusText = '',

	DefaultSettings = {
		debug = true,
		fontColor = ZO_ColorDef:New("FF0000"),
		doneColor = ZO_ColorDef:New("00FF00"),
		fontScale = 0.5,
		left = 100,
		showing = true,
		showWritStatus = true,
		showWritStatusCondensed = true,
		top = 100,
		transparency = 0
		
	},
}

BuddysWritStatusAddon.savedVariables = BuddysWritStatusAddon.DefaultSettings

-- The addon gets inizialised
-- All SavedVariables getting loaded and Setting are set to default if not set yet
function BuddysWritStatusAddon:Initialize()
	self.savedVariables = ZO_SavedVars:New("BuddysWritStatusSavedVariables", 4, nil, {})
	self:RestorePosition()
	self:CheckDefaultSettingsAreApplied()
	self:CreateSettingsWindow()
	self:RestorePosition()
	self:UpdateWritStatus()
end

-- This function is called, when the event EVENT_ADD_ON_LOADED occurs
function BuddysWritStatusAddon.OnAddOnLoaded(event, addonName)
	if addonName == BuddysWritStatusAddon.Name then
		BuddysWritStatusAddon:Initialize()
	end
end

-- 
function BuddysWritStatusAddon.OnIndicatorMoveStop()
	BuddysWritStatusAddon.savedVariables.left = BuddysWritStatusAddonIndicator:GetLeft()
	BuddysWritStatusAddon.savedVariables.top = BuddysWritStatusAddonIndicator:GetTop()
end

-- This function gets triggered anytime a listed event occurs
function BuddysWritStatusAddon:UpdateWritStatus()
	local alch, black, ench, jewel, prov, tailor, wood = false

	for questIndex = 1, MAX_JOURNAL_QUESTS do
		journalInfo = {}
		
		local writCompleted = false
		local masterWritCompleted = false
		if IsValidQuestIndex(questIndex) then
			journalInfo.RepeatType = GetJournalQuestRepeatType(questIndex)
			journalInfo.QuestName, journalInfo.BackgroundText, journalInfo.ActiveStepText, journalInfo.ActiveStepType,
			journalInfo.ActiveStepTrackerOverrideText, journalInfo.Completed, journalInfo.Tracked, journalInfo.QuestLevel,
			journalInfo.Pushed, journalInfo.QuestType, journalInfo.InstanceDisplayType = GetJournalQuestInfo(questIndex)

			local questComplete = GetJournalQuestIsComplete(questIndex)
			if journalInfo.QuestType == QUEST_TYPE_CRAFTING and
				journalInfo.RepeatType == QUEST_REPEAT_DAILY then

				local steps = GetJournalQuestNumSteps(questIndex)
				for i = 0, steps + 1 do
					local stepText, stepVisibility, stepType, stepTrackerOverrideText, conditions = GetJournalQuestStepInfo(questIndex, i)
					for j = 0, conditions + 1 do
						conditionText, current, max, isFailCondition, isComplete, isCreditShared, isVisible = GetJournalQuestConditionInfo(questIndex, i, j)
						if string.find(conditionText, "Beliefert") then
							writCompleted = true
						end
						if string.find(conditionText, "") then
							masterWritCompleted = true
						end
					end
				end

				if (string.find(journalInfo.QuestName, "Schmied")) then
					black = true
					BuddysWritStatusAddon:WriteBlacksmithing(writCompleted)
				elseif (string.find(journalInfo.QuestName, "Schneider")) then
					tailor = true
					BuddysWritStatusAddon:WriteTailoring(writCompleted)
				elseif (string.find(journalInfo.QuestName, "Schreiner")) then
					wood = true
					BuddysWritStatusAddon:WriteWoodworking(writCompleted)
				elseif (string.find(journalInfo.QuestName, "Alchemist")) then
					alch = true
					BuddysWritStatusAddon:WriteAlchemy(writCompleted)
				elseif (string.find(journalInfo.QuestName, "Verzauber")) then
					ench = true
					BuddysWritStatusAddon:WriteEnchanting(writCompleted)
				elseif (string.find(journalInfo.QuestName, "Versorger")) then
					prov = true
					BuddysWritStatusAddon:WriteProvisioning(writCompleted)
				elseif(string.find(journalInfo.QuestName, "Schmuck")) then
					jewel = true
					BuddysWritStatusAddon:WriteJewelry(writCompleted)
				end
			end
		end
	end	
	if not alch then BuddysWritStatusAddonIndicatorAlchemyLabel:SetText("") end
	if not black then BuddysWritStatusAddonIndicatorBlacksmithingLabel:SetText("") end
	if not ench then BuddysWritStatusAddonIndicatorEnchantingLabel:SetText("") end
	if not jewel then BuddysWritStatusAddonIndicatorJewelryLabel:SetText("") end
	if not prov then BuddysWritStatusAddonIndicatorProvisioningLabel:SetText("") end
	if not tailor then BuddysWritStatusAddonIndicatorTailoringLabel:SetText("") end
	if not wood then BuddysWritStatusAddonIndicatorWoodworkingLabel:SetText("") end	
	
	if not self.savedVariables.showing then
		BuddysWritStatusAddonIndicator:SetHidden(true)
	else
		BuddysWritStatusAddonIndicator:SetHidden(false)
	end

	local x = BuddysWritStatusAddonIndicatorAlchemyLabel:GetWidth()
	local y = BuddysWritStatusAddonIndicatorAlchemyLabel:GetHeight()
	BuddysWritStatusAddonIndicator:SetDimensions(x + 15, y + 15)
	BuddysWritStatusAddonIndicator:SetScale(self.savedVariables.fontScale)
	BuddysWritStatusAddonIndicatorBG:SetAlpha(self.savedVariables.transparency)	
end

function BuddysWritStatusAddon:RestorePosition()
	local left = self.savedVariables.left
	local top = self.savedVariables.top
	if left == 0 and top == 0 then
		left = 100
		top = 100
	end
	BuddysWritStatusAddonIndicator:ClearAnchors()
	BuddysWritStatusAddonIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function BuddysWritStatusAddon:Round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function BuddysWritStatusAddon:WriteAlchemy(writCompleted)
	BuddysWritStatusAddonIndicatorAlchemyLabel:SetText("Alchemieschrieb")
	if  writCompleted then
		BuddysWritStatusAddonIndicatorAlchemyLabel:SetColor(self.savedVariables.doneColor.r, self.savedVariables.doneColor.g, self.savedVariables.doneColor.b)
	else
		BuddysWritStatusAddonIndicatorAlchemyLabel:SetColor(self.savedVariables.fontColor.r, self.savedVariables.fontColor.g, self.savedVariables.fontColor.b)
	end
end
function BuddysWritStatusAddon:WriteBlacksmithing(writCompleted)
	BuddysWritStatusAddonIndicatorBlacksmithingLabel:SetText("Schmiedeschrieb")
	if writCompleted then
		BuddysWritStatusAddonIndicatorBlacksmithingLabel:SetColor(self.savedVariables.doneColor.r, self.savedVariables.doneColor.g, self.savedVariables.doneColor.b)
	else
		BuddysWritStatusAddonIndicatorBlacksmithingLabel:SetColor(self.savedVariables.fontColor.r, self.savedVariables.fontColor.g, self.savedVariables.fontColor.b)
	end
end
function BuddysWritStatusAddon:WriteEnchanting(writCompleted)
	BuddysWritStatusAddonIndicatorEnchantingLabel:SetText("Verzauberschrieb")
	if writCompleted then
		BuddysWritStatusAddonIndicatorEnchantingLabel:SetColor(self.savedVariables.doneColor.r, self.savedVariables.doneColor.g, self.savedVariables.doneColor.b)
	else
		BuddysWritStatusAddonIndicatorEnchantingLabel:SetColor(self.savedVariables.fontColor.r, self.savedVariables.fontColor.g, self.savedVariables.fontColor.b)
	end
end
function BuddysWritStatusAddon:WriteJewelry(writCompleted)
	BuddysWritStatusAddonIndicatorJewelryLabel:SetText("Schmuckschrieb")
	if writCompleted then
		BuddysWritStatusAddonIndicatorJewelryLabel:SetColor(self.savedVariables.doneColor.r, self.savedVariables.doneColor.g, self.savedVariables.doneColor.b)
	else
		BuddysWritStatusAddonIndicatorJewelryLabel:SetColor(self.savedVariables.fontColor.r, self.savedVariables.fontColor.g, self.savedVariables.fontColor.b)
	end
end
function BuddysWritStatusAddon:WriteProvisioning(writCompleted)
	BuddysWritStatusAddonIndicatorProvisioningLabel:SetText("Versorgerschrieb")
	if writCompleted then
		BuddysWritStatusAddonIndicatorProvisioningLabel:SetColor(self.savedVariables.doneColor.r, self.savedVariables.doneColor.g, self.savedVariables.doneColor.b)
	else
		BuddysWritStatusAddonIndicatorProvisioningLabel:SetColor(self.savedVariables.fontColor.r, self.savedVariables.fontColor.g, self.savedVariables.fontColor.b)
	end
end
function BuddysWritStatusAddon:WriteTailoring(writCompleted)
	BuddysWritStatusAddonIndicatorTailoringLabel:SetText("Schneiderschrieb")
	if writCompleted then
		BuddysWritStatusAddonIndicatorTailoringLabel:SetColor(self.savedVariables.doneColor.r, self.savedVariables.doneColor.g, self.savedVariables.doneColor.b)
	else
		BuddysWritStatusAddonIndicatorTailoringLabel:SetColor(self.savedVariables.fontColor.r, self.savedVariables.fontColor.g, self.savedVariables.fontColor.b)
	end
end
function BuddysWritStatusAddon:WriteWoodworking(writCompleted)
	BuddysWritStatusAddonIndicatorWoodworkingLabel:SetText("Schreinerschrieb")
	if writCompleted then
		BuddysWritStatusAddonIndicatorWoodworkingLabel:SetColor(self.savedVariables.doneColor.r, self.savedVariables.doneColor.g, self.savedVariables.doneColor.b)
	else
		BuddysWritStatusAddonIndicatorWoodworkingLabel:SetColor(self.savedVariables.fontColor.r, self.savedVariables.fontColor.g, self.savedVariables.fontColor.b)
	end
end

---------------------------------------------------------------------------------------------------------
-- E V E N T S
---------------------------------------------------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent(BuddysWritStatusAddon.Name, EVENT_ADD_ON_LOADED, BuddysWritStatusAddon.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(BuddysWritStatusAddon.Name, EVENT_CRAFT_COMPLETED,                 function(eventCode, craftSkill)BuddysWritStatusAddon:UpdateWritStatus() end)
EVENT_MANAGER:RegisterForEvent(BuddysWritStatusAddon.Name, EVENT_CLOSE_BANK,                      function() BuddysWritStatusAddon:UpdateWritStatus() end)
EVENT_MANAGER:RegisterForEvent(BuddysWritStatusAddon.Name, EVENT_END_CRAFTING_STATION_INTERACT,   function() BuddysWritStatusAddon:UpdateWritStatus() end)
EVENT_MANAGER:RegisterForEvent(BuddysWritStatusAddon.Name, EVENT_INVENTORY_FULL_UPDATE,           function() BuddysWritStatusAddon:UpdateWritStatus() end)
EVENT_MANAGER:RegisterForEvent(BuddysWritStatusAddon.Name, EVENT_ITEM_SLOT_CHANGED,               function() BuddysWritStatusAddon:UpdateWritStatus() end)
EVENT_MANAGER:RegisterForEvent(BuddysWritStatusAddon.Name, EVENT_QUEST_ADDED,                     function() BuddysWritStatusAddon:UpdateWritStatus() end)
EVENT_MANAGER:RegisterForEvent(BuddysWritStatusAddon.Name, EVENT_QUEST_COMPLETE,                  function() BuddysWritStatusAddon:UpdateWritStatus() end)
EVENT_MANAGER:RegisterForEvent(BuddysWritStatusAddon.Name, EVENT_SKILL_XP_UPDATE,                 function() BuddysWritStatusAddon:UpdateWritStatus() end)
EVENT_MANAGER:RegisterForEvent(BuddysWritStatusAddon.Name, EVENT_SMITHING_TRAIT_RESEARCH_STARTED, function() BuddysWritStatusAddon:UpdateWritStatus() end)