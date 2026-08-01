local function GetQuestPins()
  local Elements = {}
  if Provinatus.SavedVars.Quest.Enabled and not DisableLayer then
    local pins = ZO_WorldMap_GetPinManager():GetActiveObjects()
    for pinKey, pin in pairs(pins) do
      if pin:IsQuest() and (pin:IsAssisted() or Provinatus.SavedVars.Quest.ShowInactive) then
        local Size
        if pin:IsAssisted() then
          Size = Provinatus.SavedVars.Quest.Size
        else
          Size = Provinatus.SavedVars.Quest.InactiveSize
        end
        local Element = {
          X = pin.normalizedX,
          Y = pin.normalizedY,
          Texture = pin:GetQuestIcon(),
          Alpha = 1,
          Height = Size,
          Width = Size,
          Pin = pin
        }

        table.insert(Elements, Element)
      end
    end
  end

  return Elements
end

local PinTypes = {
  MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION,
  MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION,
  MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_CONDITION,
  MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_OPTIONAL_CONDITION,
  MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_CONDITION,
  MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_OPTIONAL_CONDITION,
  MAP_PIN_TYPE_TRACKED_QUEST_CONDITION,
  MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION,
  MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_CONDITION,
  MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_OPTIONAL_CONDITION,
  MAP_PIN_TYPE_TRACKED_QUEST_ZONE_STORY_CONDITION,
  MAP_PIN_TYPE_TRACKED_QUEST_ZONE_STORY_OPTIONAL_CONDITION,
  MAP_PIN_TYPE_QUEST_CONDITION,
  MAP_PIN_TYPE_QUEST_OPTIONAL_CONDITION,
  MAP_PIN_TYPE_QUEST_REPEATABLE_CONDITION,
  MAP_PIN_TYPE_QUEST_REPEATABLE_OPTIONAL_CONDITION,
  MAP_PIN_TYPE_QUEST_ZONE_STORY_CONDITION,
  MAP_PIN_TYPE_QUEST_ZONE_STORY_OPTIONAL_CONDITION
}

-- Copied from esoui source code compass.lua https://esodata.uesp.net/100018/src/ingame/compass/compass.lua.html#35
local function IsPlayerInsideJournalQuestConditionGoalArea(journalIndex, stepIndex, conditionIndex)
  journalIndex = journalIndex - 1
  stepIndex = stepIndex - 1
  conditionIndex = conditionIndex - 1
  for _, pinType in ipairs(PinTypes) do
    if IsPlayerInsidePinArea(pinType, journalIndex, stepIndex, conditionIndex) then
      return true
    end
  end
  return false
end

local function IsQuestVisible(journalIndex)
  local visibilitySetting = tonumber(GetSetting(SETTING_TYPE_UI, UI_SETTING_COMPASS_ACTIVE_QUESTS))
  if visibilitySetting == COMPASS_ACTIVE_QUESTS_CHOICE_ON then
    return true
  elseif visibilitySetting == COMPASS_ACTIVE_QUESTS_CHOICE_OFF then
    return false
  else
    return GetTrackedIsAssisted(TRACK_TYPE_QUEST, journalIndex)
  end
end

local function ShouldShowQuestArea(journalIndex, stepIndex, conditionIndex)
  if IsPlayerInsideJournalQuestConditionGoalArea(journalIndex, stepIndex, conditionIndex) then
    return IsQuestVisible(journalIndex)
  else
    return false
  end
end

ProvinatusQuests = ZO_Object:Subclass()

function ProvinatusQuests:New(...)
  self.QuestZones = {}
  return ZO_Object.New(self)
end

function ProvinatusQuests:Initialize()
  for JournalIndex = 1, MAX_JOURNAL_QUESTS do
    if IsValidQuestIndex(JournalIndex) then
      for StepIndex = QUEST_MAIN_STEP_INDEX, GetJournalQuestNumSteps(JournalIndex) do
        for ConditionIndex = 1, GetJournalQuestNumConditions(JournalIndex, StepIndex) do
          if ShouldShowQuestArea(JournalIndex, StepIndex, ConditionIndex) then
            self:UpdateQuestZone(JournalIndex, StepIndex, ConditionIndex, true)
          end
        end
      end
    end
  end

  EVENT_MANAGER:RegisterForEvent(
    "ProvinatusPinAreaChanged",
    EVENT_PLAYER_IN_PIN_AREA_CHANGED,
    function(eventCode, pinType, JournalIndex, StepIndex, ConditionIndex, PlayerIsInside)
      self:UpdateQuestZone(JournalIndex + 1, StepIndex + 1, ConditionIndex + 1, PlayerIsInside)
    end
  )
end

function ProvinatusQuests:UpdateQuestZone(JournalIndex, StepIndex, ConditionIndex, PlayerIsInside)
  if not self.QuestZones[JournalIndex] then
    self.QuestZones[JournalIndex] = {}
  end

  if not self.QuestZones[JournalIndex][StepIndex] then
    self.QuestZones[JournalIndex][StepIndex] = {}
  end

  self.QuestZones[JournalIndex][StepIndex][ConditionIndex] = PlayerIsInside
end

function ProvinatusQuests:Update()
  if Provinatus.SavedVars.Quest.Enabled then
    for Element, Icon in pairs(Provinatus:DrawElements(self, GetQuestPins())) do
      if Element.Pin:IsAreaPin() then
        local QuestIndex, StepIndex, ConditionIndex = Element.Pin:GetQuestData()
        local Texture
        if
          self.QuestZones[QUEST_JOURNAL_MANAGER:GetFocusedQuestIndex()] and
            self.QuestZones[QUEST_JOURNAL_MANAGER:GetFocusedQuestIndex()][StepIndex] and
            self.QuestZones[QUEST_JOURNAL_MANAGER:GetFocusedQuestIndex()][StepIndex][ConditionIndex]
         then
          Texture = "esoui/art/mappins/map_assistedareapin.dds"
        else
          Texture = "esoui/art/mappins/map_areapin.dds"
        end

        if Icon.AreaIcon == nil then
          Icon.AreaIcon = WINDOW_MANAGER:CreateControl(nil, Icon, CT_TEXTURE)
          Icon.AreaIcon:SetAnchor(CENTER, Icon, CENTER, 0, 0)
        end

        Icon.AreaIcon:SetTexture(Texture)
        local Size, Alpha
        if Element.Pin:IsAssisted() then
          Size = Provinatus.SavedVars.Quest.Size
          Alpha = Provinatus.SavedVars.Quest.Alpha
        else
          Size = Provinatus.SavedVars.Quest.InactiveSize
          Alpha = Provinatus.SavedVars.Quest.InactiveAlpha
        end
        Icon.AreaIcon:SetDimensions(
          Size + Size,
          Size + Size
        )
        Icon.AreaIcon:SetAlpha(Alpha)
      elseif Icon.AreaIcon and Icon.AreaIcon:GetAlpha() ~= 0 then
        Icon.AreaIcon:SetAlpha(0)
      end
    end
  else
    Provinatus:DrawElements(self, {})
  end
end

function ProvinatusQuests:GetMenu()
  return {
    type = "submenu",
    name = PROVINATUS_ACTIVE_QUEST,
    reference = "ProvinatusQuestMenu",
    icon = "/esoui/art/floatingmarkers/quest_icon_assisted.dds",
    controls = {
      {
        type = "checkbox",
        name = PROVINATUS_QUEST_ENABLE,
        getFunc = function()
          return Provinatus.SavedVars.Quest.Enabled
        end,
        setFunc = function(value)
          Provinatus.SavedVars.Quest.Enabled = value
        end,
        tooltip = PROVINATUS_QUEST_ENABLE_TT,
        width = "full",
        default = ProvinatusConfig.Quest.Enabled
      },
      {
        type = "checkbox",
        name = "Show inactive quest markers",
        getFunc = function()
          return Provinatus.SavedVars.Quest.ShowInactive
        end,
        setFunc = function(value)
          Provinatus.SavedVars.Quest.ShowInactive = value
        end,
        tooltip = PROVINATUS_QUEST_ENABLE_TT,
        width = "full",
        default = ProvinatusConfig.Quest.ShowInactive
      },
      {
        type = "submenu",
        name = PROVINATUS_QUEST_SHOWACTIVE,
        controls = ProvinatusMenu.GetIconSettingsMenu(
          "",
          function()
            return Provinatus.SavedVars.Quest.Size
          end,
          function(value)
            Provinatus.SavedVars.Quest.Size = value
          end,
          function()
            return Provinatus.SavedVars.Quest.Alpha * 100
          end,
          function(value)
            Provinatus.SavedVars.Quest.Alpha = value / 100
          end,
          ProvinatusConfig.Quest.Size,
          ProvinatusConfig.Quest.Alpha * 100,
          function()
            return not Provinatus.SavedVars.Quest.Enabled
          end
        )
      },
      {
        type = "submenu",
        name = PROVINATUS_QUEST_SHOWINACTIVE,
        controls = ProvinatusMenu.GetIconSettingsMenu(
          "",
          function()
            return Provinatus.SavedVars.Quest.InactiveSize
          end,
          function(value)
            Provinatus.SavedVars.Quest.InactiveSize = value
          end,
          function()
            return Provinatus.SavedVars.Quest.InactiveAlpha * 100
          end,
          function(value)
            Provinatus.SavedVars.Quest.InactiveAlpha = value / 100
          end,
          ProvinatusConfig.Quest.InactiveSize,
          ProvinatusConfig.Quest.InactiveAlpha * 100,
          function()
            return not Provinatus.SavedVars.Quest.Enabled
          end
        )
      }
    }
  }
end
