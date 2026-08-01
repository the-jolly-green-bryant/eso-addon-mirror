-------------------------------------------------------------------------------------------------
-- Title: Time To Heal
-- Description: Evade death by setting a reminder to "Heal Now!" based on your remaining health percentage.
-- Why: I often forget to keep an eye on my health when tired. I figure I can't be the only one.
-- Author: PlaceHolder
-- APIVersion: 101034
-- AddOnVersion:
-- Version: 1.0.8
-- DependsOn: LibAddonMenu-2.0
-- SavedVariables: TimeToHealSavedVariables
-------------------------------------------------------------------------------------------------

TimeToHeal = {}
 
-- Define things for later use
TimeToHeal.name = "TimeToHeal"
TimeToHeal.version = "1.0.8"
TimeToHeal.author = "PlaceHolder"
TimeToHeal.description = 'Add-on to notify when your health is low so you heal in time.'


-------------------------------------------------------------------------------------------------
-- Libraries
-------------------------------------------------------------------------------------------------
--local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")
local LAM2 = LibAddonMenu2
-------------------------------------------------------------------------------------------------
-- Help functions
-------------------------------------------------------------------------------------------------

-- Runs off percentage you define (Default is 25%)
function GetHealThreshold()
	return (TimeToHeal.VisualIndicator.Settings.DesiredHealthPercentage/100)
end

local unitTag = GetUnitName("player") -- You're the only target we care about <3

function TimeToHeal.GetUnitHealthPercentage() -- Calculate how much health you have
  local targetCurrentPower, targetMaxPower = GetUnitPower(unitTag, POWERTYPE_HEALTH)
  return targetCurrentPower / targetMaxPower
end

-------------------------------------------------------------------------------------------------
-- UI Elements
-------------------------------------------------------------------------------------------------

TimeToHeal.VisualIndicator = {}

-- Define some stuff
TimeToHeal.VisualIndicator.Default = {
  HPReminderShow = false,
  left = 200,
  top = 25,
  MilliSecondsToShowIndicator = 2000,
  Scale = 2,
  Alpha = 0.8,
  DesiredHealthPercentage = 25
}

TimeToHeal.VisualIndicator.variableVersion = 1

function TimeToHeal.OnIndicatorMoveStop()
  TimeToHeal.VisualIndicator.Settings.left = TimeToHealVisualIndicator:GetLeft()
  TimeToHeal.VisualIndicator.Settings.top = TimeToHealVisualIndicator:GetTop()
end

function TimeToHeal.RestorePosition()
  local left = TimeToHeal.VisualIndicator.Settings.left
  local top = TimeToHeal.VisualIndicator.Settings.top
  local scale = TimeToHeal.VisualIndicator.Settings.Scale
  local alpha = TimeToHeal.VisualIndicator.Settings.Alpha
  TimeToHealVisualIndicator:ClearAnchors()
  TimeToHealVisualIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
  TimeToHealVisualIndicator:SetScale(scale)
  TimeToHealVisualIndicator:SetAlpha(alpha)
end

local healIndicatorIdentifier = "timeToDoTheThingOMG"

-- Prompt Off
function TimeToHeal.HideHealingIndicator()
    TimeToHealVisualIndicator:SetHidden(true)
	EVENT_MANAGER:UnregisterForUpdate(healIndicatorIdentifier)
end

-- Prompt On
function TimeToHeal.ShowHealingIndicator()
  TimeToHealVisualIndicator:SetHidden(false)
  EVENT_MANAGER:RegisterForUpdate(healIndicatorIdentifier, TimeToHeal.VisualIndicator.Settings.MilliSecondsToShowIndicator, TimeToHeal.HideHealingIndicator)
end

-------------------------------------------------------------------------------------------------
-- Main Functions
-------------------------------------------------------------------------------------------------
function TimeToHeal.OnPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
  TimeToHeal.targetHealthPercentage = zo_round((powerValue / powerMax)*100) -- round to get a full number

-- Figure out when to show
  if TimeToHeal.targetHealthPercentage <= TimeToHeal.DesiredHealthPercentage and powerValue > 0 then
    TimeToHealVisualIndicator:SetHidden(false)
    EVENT_MANAGER:RegisterForUpdate(healIndicatorIdentifier, TimeToHeal.VisualIndicator.Settings.MilliSecondsToShowIndicator, TimeToHeal.HideHealingIndicator)
  else
    TimeToHealVisualIndicator:SetHidden(true)
    EVENT_MANAGER:RegisterForUpdate(healIndicatorIdentifier, TimeToHeal.VisualIndicator.Settings.MilliSecondsToShowIndicator, TimeToHeal.HideHealingIndicator)
  end
  TimeToHeal.targetHealthPercentage = powerValue / powerMax
end

-- Only care if you're in combat
function TimeToHeal.OnPlayerCombatState(eventCode, inCombat)
  if inCombat ~= TimeToHeal.inCombat then
    TimeToHeal.inCombat = inCombat
    if inCombat then
      EVENT_MANAGER:RegisterForEvent(TimeToHeal.name, EVENT_POWER_UPDATE, TimeToHeal.OnPowerUpdate)
      EVENT_MANAGER:AddFilterForEvent(TimeToHeal.name, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, POWERTYPE_HEALTH)
      EVENT_MANAGER:AddFilterForEvent(TimeToHeal.name, EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
    else
      EVENT_MANAGER:UnregisterForUpdate(healIndicatorIdentifier)
      TimeToHealVisualIndicator:SetHidden(true)
      TimeToHeal.targetHealthPercentage = nil
      EVENT_MANAGER:UnregisterForEvent(TimeToHeal.name, EVENT_POWER_UPDATE)
    end
  end
end

-------------------------------------------------------------------------------------------------
-- Settings
-------------------------------------------------------------------------------------------------

function TimeToHeal.CreateSettingsWindow()
  local panelData = {
	 type = "panel",
	 name = "Time To Heal",
	 displayName = "Time To Heal",
	 author = "PlaceHolder",
	 version = TimeToHeal.version,
   website = "https://www.esoui.com/forums/member.php?u=57145",
	 slashCommand = "/timetoheal",
	 registerForRefresh = true,
	 registerForDefaults = true,
  }
  local cntrlOptionsPanel = LAM2:RegisterAddonPanel("TimeToHealControl", panelData)
  local optionsData = {
    [1] = {
      type = "button",
      name = function() if TimeToHeal.VisualIndicator.HPReminderShow then return "Hide Prompt" else return "Test Prompt" end end,
      tooltip = "Show or hide the Heal Reminder to get a preview and change the position.",
      func = function(control)
        TimeToHeal.VisualIndicator.HPReminderShow = not TimeToHeal.VisualIndicator.HPReminderShow
        TimeToHealVisualIndicator:SetHidden(not TimeToHeal.VisualIndicator.HPReminderShow)
      end,
    },
    [2] = {
	   type = "header",
	   name = "Settings",
	   width = "full",
    },
    [3] = {
      type = "slider",
      name = "Size",
      tooltip = "Adjust the size of the Heal Reminder",
      min = 1,
      max = 5,
      step = 1,
      default = 2,
      getFunc = function() return TimeToHeal.VisualIndicator.Settings.Scale end,
      setFunc = function(newValue)
        TimeToHeal.VisualIndicator.Settings.Scale = newValue
        TimeToHealVisualIndicator:SetScale(newValue)
      end,
    },
    [4] = {
      type = "slider",
      name = "Opacity",
      tooltip = "Adjust the opacity of the Heal Reminder",
      min = 0,
      max = 1,
      step = 0.1,
      default = 0.5,
      getFunc = function() return TimeToHeal.VisualIndicator.Settings.Alpha end,
      setFunc = function(newValue)
        TimeToHeal.VisualIndicator.Settings.Alpha = newValue
        TimeToHealVisualIndicator:SetAlpha(newValue)
      end,
    },
    [5] = {
	   type = "slider",
	   name = "Duration",
	   tooltip = "How long the Heal Reminder should be visible",
	   min = 500,
	   max = 4000,
	   step = 100,
	   default = 1500,
	   getFunc = function() return TimeToHeal.VisualIndicator.Settings.MilliSecondsToShowIndicator end,
	   setFunc = function(newValue)
		  	TimeToHeal.VisualIndicator.Settings.MilliSecondsToShowIndicator = newValue
      end,
    },
    [6] = {
      type = "slider",
      name = "Health Percentage to remind at",
      tooltip = 'What percentage health should you have left for "Heal Now!" to display',
      min = 0,
      max = 100,
      step = 5,
      default = 25,
      getFunc = function() return TimeToHeal.VisualIndicator.Settings.DesiredHealthPercentage end,
      setFunc = function(newValue)
        TimeToHeal.VisualIndicator.Settings.DesiredHealthPercentage = newValue
      end,
      warning = "Will need to reload the UI.",
    },
    [7] = {
      type = "button",
      name = function() return "Confirm & ReloadUI" end,
      tooltip = "This will ReloadUI (needed for values to take effect).",
      func = function(control)
        ReloadUI()
      end,
    },
  }
LAM2:RegisterOptionControls("TimeToHealControl", optionsData)
end

-------------------------------------------------------------------------------------------------
-- Initialization
-------------------------------------------------------------------------------------------------

function TimeToHeal:Initialize()
  -- UI
  TimeToHeal.VisualIndicator.Settings = ZO_SavedVars:New("TimeToHealSavedVariables", TimeToHeal.VisualIndicator.variableVersion, nil, TimeToHeal.VisualIndicator.Default)
  TimeToHeal.RestorePosition()
  -- Settings
  TimeToHeal.CreateSettingsWindow()
  -- Main
  TimeToHeal.inCombat = IsUnitInCombat("player")
  TimeToHeal.targetHealthPercentage = nil
  TimeToHeal.DesiredHealthPercentage = zo_round(GetHealThreshold()*100)
  if TimeToHeal.DesiredHealthPercentage > 0 then
    EVENT_MANAGER:RegisterForEvent(TimeToHeal.name, EVENT_PLAYER_COMBAT_STATE, TimeToHeal.OnPlayerCombatState)
  end
  EVENT_MANAGER:UnregisterForEvent(TimeToHeal.name, EVENT_ADD_ON_LOADED)
end

function TimeToHeal.OnAddOnLoaded(event, addonName)
  if addonName == TimeToHeal.name then
    TimeToHeal:Initialize()
  end
end

EVENT_MANAGER:RegisterForEvent(TimeToHeal.name, EVENT_ADD_ON_LOADED, TimeToHeal.OnAddOnLoaded)


