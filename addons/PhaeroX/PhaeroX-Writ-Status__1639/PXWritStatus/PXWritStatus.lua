PXWritStatusAddon = {
  Name = "PXWritStatus",
  Version = "1.0.5",
  WritStatusText = '',

  DefaultSettings = {
    allWritsDoneNotified = false,
    debug = true,
    fontColor = ZO_ColorDef:New("FFFFFF"),
    fontScale = 1,
    left = 100,
    showing = true,
    showWritStatus = true,
    showWritStatusCondensed = true,
    top = 100,
    transparency = 0,
  },

  ColorGold   = '|cd8b620',
  ColorGreen  = '|c28b712',
  ColorOrange = '|cf7952c',
  ColorRed    = '|cd61b1b',
  ColorWhite  = '|cffffff',
  ColorBlue   = '|c2d64bc',
}

PXWritStatusAddon.WritStatus = {
  BlackSmithing = false,
  BlackSmithingColor = PXWritStatusAddon.ColorRed,
  BlackSmithingPickedUp = false,
  Clothing = false,
  ClothingColor = PXWritStatusAddon.ColorRed,
  ClothingPickedUp = false,
  Woodworking = false,
  WoodworkingColor = PXWritStatusAddon.ColorRed,
  WoodworkingPickedUp = false,
  Alchemy = false,
  AlchemyColor = PXWritStatusAddon.ColorRed,
  AlchemyPickedUp = false,
  Enchanting = false,
  EnchantingColor = PXWritStatusAddon.ColorRed,
  AlchemyPickedUp = false,
  Provisioning = false,
  ProvisioningColor = PXWritStatusAddon.ColorRed,
  ProvisioningPickedUp = false,
}

PXWritStatusAddon.savedVariables = PXWritStatusAddon.DefaultSettings

---------------------------------------------------------------------------------------------------------
-- E V E N T S
---------------------------------------------------------------------------------------------------------
function PXWritStatusAddon:Initialize()

  EVENT_MANAGER:RegisterForEvent(PXWritStatusAddon.Name, EVENT_CRAFT_COMPLETED,
    function(eventCode, craftSkill)
      PXWritStatusAddon:UpdateWritStatus()
    end
  )

  EVENT_MANAGER:RegisterForEvent(PXWritStatusAddon.Name, EVENT_CLOSE_BANK,                      function() PXWritStatusAddon:UpdateWritStatus() end)
  EVENT_MANAGER:RegisterForEvent(PXWritStatusAddon.Name, EVENT_END_CRAFTING_STATION_INTERACT,   function() PXWritStatusAddon:UpdateWritStatus() end)
  EVENT_MANAGER:RegisterForEvent(PXWritStatusAddon.Name, EVENT_INVENTORY_FULL_UPDATE,           function() PXWritStatusAddon:UpdateWritStatus() end)
  EVENT_MANAGER:RegisterForEvent(PXWritStatusAddon.Name, EVENT_ITEM_SLOT_CHANGED,               function() PXWritStatusAddon:UpdateWritStatus() end)

  EVENT_MANAGER:RegisterForEvent(PXWritStatusAddon.Name, EVENT_QUEST_ADDED,                     function() PXWritStatusAddon:UpdateWritStatus() end)
  EVENT_MANAGER:RegisterForEvent(PXWritStatusAddon.Name, EVENT_QUEST_COMPLETE,                  function() PXWritStatusAddon:UpdateWritStatus() end)
  EVENT_MANAGER:RegisterForEvent(PXWritStatusAddon.Name, EVENT_SKILL_XP_UPDATE,                 function() PXWritStatusAddon:UpdateWritStatus() end)
  EVENT_MANAGER:RegisterForEvent(PXWritStatusAddon.Name, EVENT_SMITHING_TRAIT_RESEARCH_STARTED, function() PXWritStatusAddon:UpdateWritStatus() end)

  self.savedVariables = ZO_SavedVars:New("PXWritStatusSavedVariables", 4, nil, {})
  self:RestorePosition()

  if self.savedVariables.showing == false then
    PXWritStatusAddonIndicator:SetHidden(true)
  else
    PXWritStatusAddonIndicator:SetHidden(false)
  end

  self.savedVariables.allWritsDoneNotified = false
  self:CheckDefaultSettingsAreApplied()
  self:CreateSettingsWindow()
  self:RestorePosition()
  self:UpdateWritStatus()
end

function PXWritStatusAddon.OnAddOnLoaded(event, addonName)
  if addonName == PXWritStatusAddon.Name then
    PXWritStatusAddon:Initialize()
  end
end

function PXWritStatusAddon.OnIndicatorMoveStop()
  PXWritStatusAddon.savedVariables.left = PXWritStatusAddonIndicator:GetLeft()
  PXWritStatusAddon.savedVariables.top = PXWritStatusAddonIndicator:GetTop()
end

EVENT_MANAGER:RegisterForEvent(PXWritStatusAddon.Name, EVENT_ADD_ON_LOADED, PXWritStatusAddon.OnAddOnLoaded)

---------------------------------------------------------------------------------------------------------
-- H E L P E R    F U N C T I O N S
---------------------------------------------------------------------------------------------------------
function PXWritStatusAddon:UpdateWritStatus()
  local journal = {}
  local journalInfo = {}
  local text = ""
  local completedText = ""
  local conditionText = ""

  PXWritStatusAddon.WritStatus.BlackSmithing = false
  PXWritStatusAddon.WritStatus.BlackSmithingColor = PXWritStatusAddon.ColorRed 
  PXWritStatusAddon.WritStatus.BlackSmithingPickedUp = false
  PXWritStatusAddon.WritStatus.Clothing = false
  PXWritStatusAddon.WritStatus.ClothingColor = PXWritStatusAddon.ColorRed 
  PXWritStatusAddon.WritStatus.ClothingPickedUp = false
  PXWritStatusAddon.WritStatus.Woodworking = false
  PXWritStatusAddon.WritStatus.WoodworkingColor = PXWritStatusAddon.ColorRed 
  PXWritStatusAddon.WritStatus.WoodworkingPickedUp = false
  PXWritStatusAddon.WritStatus.Alchemy = false
  PXWritStatusAddon.WritStatus.AlchemyColor = PXWritStatusAddon.ColorRed 
  PXWritStatusAddon.WritStatus.AlchemyickedUp = false
  PXWritStatusAddon.WritStatus.Enchanting = false
  PXWritStatusAddon.WritStatus.EnchantingColor = PXWritStatusAddon.ColorRed 
  PXWritStatusAddon.WritStatus.EnchantingPickedUp = false
  PXWritStatusAddon.WritStatus.Provisioning = false
  PXWritStatusAddon.WritStatus.ProvisioningColor = PXWritStatusAddon.ColorRed 
  PXWritStatusAddon.WritStatus.ProvisioningPickedUp = false

  for questIndex = 1, MAX_JOURNAL_QUESTS do
    journalInfo = {}
    if IsValidQuestIndex(questIndex) then
      journalInfo.RepeatType = GetJournalQuestRepeatType(questIndex)
      journalInfo.QuestName, journalInfo.BackgroundText, journalInfo.ActiveStepText, journalInfo.ActiveStepType,
      journalInfo.ActiveStepTrackerOverrideText, journalInfo.Completed, journalInfo.Tracked, journalInfo.QuestLevel,
      journalInfo.Pushed, journalInfo.QuestType, journalInfo.InstanceDisplayType = GetJournalQuestInfo(questIndex)

      local questComplete = GetJournalQuestIsComplete(questIndex)
      if journalInfo.QuestType == QUEST_TYPE_CRAFTING and
         journalInfo.RepeatType == QUEST_REPEAT_DAILY then

        local steps = GetJournalQuestNumSteps(questIndex)
        local writCompleted = false
        for z = 0, steps + 1 do
          local stepText, stepVisibility, stepType, stepTrackerOverrideText, conditions = GetJournalQuestStepInfo(questIndex, z)
          for zz = 0, conditions + 1 do
            conditionText, current, max, isFailCondition, isComplete, isCreditShared, isVisible = GetJournalQuestConditionInfo(questIndex, z, zz)
            local subText = string.sub(conditionText, 1, 7)
            if subText == GetString(PXWS_WRITS_DELIVER) then
              writCompleted = true
            end
          end
        end

        if writCompleted == true then
          completedText = GetString(PXWS_WRITS_COMPLETED)

          if (string.match(journalInfo.QuestName, GetString(PXWS_WRITS_BLACKSMITHING_SUBSTRING))) then
            PXWritStatusAddon.WritStatus.BlackSmithing = true
            PXWritStatusAddon.WritStatus.BlackSmithingColor = PXWritStatusAddon.ColorGreen
            PXWritStatusAddon.WritStatus.BlackSmithingPickedUp = true
          elseif (string.match(journalInfo.QuestName, GetString(PXWS_WRITS_CLOTHING_SUBSTRING))) then
            PXWritStatusAddon.WritStatus.Clothing = true
            PXWritStatusAddon.WritStatus.ClothingColor = PXWritStatusAddon.ColorGreen
            PXWritStatusAddon.WritStatus.ClothingPickedUp = true
          elseif (string.match(journalInfo.QuestName, GetString(PXWS_WRITS_WOODWORKING_SUBSTRING))) then
            PXWritStatusAddon.WritStatus.Woodworking = true
            PXWritStatusAddon.WritStatus.WoodworkingColor = PXWritStatusAddon.ColorGreen
            PXWritStatusAddon.WritStatus.WoodworkingPickedUp = true
          elseif (string.match(journalInfo.QuestName, GetString(PXWS_WRITS_ALCHEMY_SUBSTRING))) then
            PXWritStatusAddon.WritStatus.Alchemy = true
            PXWritStatusAddon.WritStatus.AlchemyColor = PXWritStatusAddon.ColorGreen
            PXWritStatusAddon.WritStatus.AlchemyPickedUp = true
          elseif (string.match(journalInfo.QuestName, GetString(PXWS_WRITS_ENCHANTING_SUBSTRING))) then
            PXWritStatusAddon.WritStatus.Enchanting = true
            PXWritStatusAddon.WritStatus.EnchantingColor = PXWritStatusAddon.ColorGreen
            PXWritStatusAddon.WritStatus.EnchantingPickedUp = true
          elseif(string.match(journalInfo.QuestName, GetString(PXWS_WRITS_PROVISIONING_SUBSTRING))) then
            PXWritStatusAddon.WritStatus.Provisioning = true
            PXWritStatusAddon.WritStatus.ProvisioningColor = PXWritStatusAddon.ColorGreen
            PXWritStatusAddon.WritStatus.ProvisioningPickedUp = true
          end
        else
          if (string.match(journalInfo.QuestName, GetString(PXWS_WRITS_BLACKSMITHING_SUBSTRING))) then
            PXWritStatusAddon.WritStatus.BlackSmithingPickedUp = true
          elseif (string.match(journalInfo.QuestName, GetString(PXWS_WRITS_CLOTHING_SUBSTRING))) then
            PXWritStatusAddon.WritStatus.ClothingPickedUp = true
          elseif (string.match(journalInfo.QuestName, GetString(PXWS_WRITS_WOODWORKING_SUBSTRING))) then
            PXWritStatusAddon.WritStatus.WoodworkingPickedUp = true
          elseif (string.match(journalInfo.QuestName, GetString(PXWS_WRITS_ALCHEMY_SUBSTRING))) then
            PXWritStatusAddon.WritStatus.AlchemyPickedUp = true
          elseif (string.match(journalInfo.QuestName, GetString(PXWS_WRITS_ENCHANTING_SUBSTRING))) then
            PXWritStatusAddon.WritStatus.EnchantingPickedUp = true
          elseif(string.match(journalInfo.QuestName, GetString(PXWS_WRITS_PROVISIONING_SUBSTRING))) then
            PXWritStatusAddon.WritStatus.ProvisioningPickedUp = true
          end
        end
        text = text .. journalInfo.QuestName .. " -- " .. completedText .. "\n"
        completedText = ""
      end
    end
  end

  PXWritStatusAddon.WritStatusText = text
  PXWritStatusAddon:WriteLog(text)
end

function PXWritStatusAddon:RestorePosition()
  local left = self.savedVariables.left
  local top = self.savedVariables.top
  if left == 0 and top == 0 then
    left = 100
    top = 100
  end
 
  PXWritStatusAddonIndicator:ClearAnchors()
  PXWritStatusAddonIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function PXWritStatusAddon:Round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function PXWritStatusAddon:WriteLog(textLog)
  if self.savedVariables.fontScale ~= nil then
    PXWritStatusAddonIndicatorLabel:SetScale(self.savedVariables.fontScale)
  end
  if self.savedVariables.fontColor ~= nil then
    PXWritStatusAddonIndicatorLabel:SetColor(self.savedVariables.fontColor.r, self.savedVariables.fontColor.g, self.savedVariables.fontColor.b)
  end
  PXWritStatusAddonIndicatorBG:SetAlpha(self.savedVariables.transparency)

  local x = PXWritStatusAddonIndicatorLabel:GetWidth()
  local y = PXWritStatusAddonIndicatorLabel:GetHeight()
  PXWritStatusAddonIndicator:SetDimensions(x + 15, y + 15)

  if textLog == "" then
    PXWritStatusAddonIndicatorLabel:SetText("")
  else
    PXWritStatusAddonIndicatorLabel:SetText(textLog)
  end
end