-------------------------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------------------------

ExecuteNow = {}
 
-- This isn't strictly necessary, but we'll use this string later when registering events.
-- Better to define it in a single place rather than retyping the same string.
ExecuteNow.name = "ExecuteNow"
ExecuteNow.version = 0.2

-------------------------------------------------------------------------------------------------
-- Libraries
-------------------------------------------------------------------------------------------------
local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")

-------------------------------------------------------------------------------------------------
-- Help functions
-------------------------------------------------------------------------------------------------

function GetExecuteThreshold()
  local unitClassId = GetUnitClassId("player")
  if unitClassId == 1 then -- DK
    return(0)
  end
  if unitClassId == 2 then -- Sorc
    return(0.2)
  end
  if unitClassId == 3 then -- Nightblade
    return(0.25)
  end
  if unitClassId == 6 then -- Templar
    return(0.25)
  end
  return(0)
end

ExecuteNow.ThereIsABoss = false

function ExecuteNow.CheckIfThereIsABoss()
	for i = 1, MAX_BOSSES do
		if DoesUnitExist("boss"..i) then
			return true
		end
	end
	return false
end

function ExecuteNow.IsExecutableTarget()
  local isUnitAttackable = IsUnitAttackable("reticleover")
  --if ExecuteNow.VisualIndicator.Settings.OnlyShowExecuteOnBosses and not ExecuteNow.ThereIsABoss then
  --  return false
  --end
  --if ExecuteNow.VisualIndicator.Settings.MinimumHitpointsThreshold
  if isUnitAttackable ~= nil and isUnitAttackable then
	local targetCurrentPower, targetMaxPower = GetUnitPower("reticleover", POWERTYPE_HEALTH)
	if targetMaxPower < ExecuteNow.VisualIndicator.Settings.MinimumHitpointsThreshold then return false end
  	return true
  else
  	return false
  end
end

function ExecuteNow.GetUnitHealthPercentage()
  local targetCurrentPower, targetMaxPower = GetUnitPower("reticleover", POWERTYPE_HEALTH)
  return targetCurrentPower / targetMaxPower
end



-------------------------------------------------------------------------------------------------
-- UI Elements
-------------------------------------------------------------------------------------------------

ExecuteNow.VisualIndicator = {}

ExecuteNow.VisualIndicator.Show = false

ExecuteNow.VisualIndicator.Default = {
  left = 200,
  top = 25,
  MilliSecondsToShowIndicator = 1000,
  Scale = 2,
  Alpha = 0.8,
  ReShowExecuteWhenTargetChange = false,
  OnlyShowExecuteOnBosses = false,
  MinimumHitpointsThreshold = 3000000
}

ExecuteNow.VisualIndicator.variableVersion = 1

function ExecuteNow.OnIndicatorMoveStop()
  ExecuteNow.VisualIndicator.Settings.left = ExecuteNowVisualIndicator:GetLeft()
  ExecuteNow.VisualIndicator.Settings.top = ExecuteNowVisualIndicator:GetTop()
end

function ExecuteNow.RestorePosition()
  local left = ExecuteNow.VisualIndicator.Settings.left
  local top = ExecuteNow.VisualIndicator.Settings.top
  local scale = ExecuteNow.VisualIndicator.Settings.Scale
  local alpha = ExecuteNow.VisualIndicator.Settings.Alpha
  ExecuteNowVisualIndicator:ClearAnchors()
  ExecuteNowVisualIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
  ExecuteNowVisualIndicator:SetScale(scale)
  ExecuteNowVisualIndicator:SetAlpha(alpha)
end

local executeIndicatorIdentifier = "myReallyUniqueExecuteIdentifier13377"

function ExecuteNow.HideExectureIndicator()
    ExecuteNowVisualIndicator:SetHidden(true)
	EVENT_MANAGER:UnregisterForUpdate(executeIndicatorIdentifier)
end

function ExecuteNow.ShowExecuteIndicator()
  ExecuteNowVisualIndicator:SetHidden(false)
  EVENT_MANAGER:RegisterForUpdate(executeIndicatorIdentifier, ExecuteNow.VisualIndicator.Settings.MilliSecondsToShowIndicator, ExecuteNow.HideExectureIndicator)
end


-------------------------------------------------------------------------------------------------
-- Main Functions
-------------------------------------------------------------------------------------------------

function ExecuteNow.OnPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
  if ExecuteNow.IsExecutableTarget() then --  and unitTag == "reticleover" -- Don't need this as we filter the event on that tag
    if ExecuteNow.targetHealthPercentage ~= nil and ExecuteNow.targetHealthPercentage > ExecuteNow.executeThreshold and powerValue / powerMax <= ExecuteNow.executeThreshold and powerValue > 0 then
	  ExecuteNow.ShowExecuteIndicator()
	  --d("EXECUTE NOW!")
	end
	ExecuteNow.targetHealthPercentage = powerValue / powerMax
  end
end

function ExecuteNow.OnReticleTargetChange(eventCode)
  --GetExecuteThreshold() -- To get class ids
  ExecuteNow.targetHealthPercentage = nil
  if ExecuteNow.VisualIndicator.Settings.ReShowExecuteWhenTargetChange and ExecuteNow.IsExecutableTarget() and ExecuteNow.GetUnitHealthPercentage() <= ExecuteNow.executeThreshold then
	ExecuteNow.ShowExecuteIndicator()
  end
end

function ExecuteNow.OnPlayerCombatState(eventCode, inCombat)
  if inCombat ~= ExecuteNow.inCombat then
    ExecuteNow.inCombat = inCombat
	if inCombat then
	  --if ExecuteNow.VisualIndicator.Settings.OnlyShowExecuteOnBosses then
	  --  ExecuteNow.ThereIsABoss = ExecuteNow.CheckIfThereIsABoss()
	  --end
      EVENT_MANAGER:RegisterForEvent(ExecuteNow.name, EVENT_RETICLE_TARGET_CHANGED, ExecuteNow.OnReticleTargetChange)
      EVENT_MANAGER:RegisterForEvent(ExecuteNow.name, EVENT_POWER_UPDATE, ExecuteNow.OnPowerUpdate)
      EVENT_MANAGER:AddFilterForEvent(ExecuteNow.name, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, POWERTYPE_HEALTH)
	  EVENT_MANAGER:AddFilterForEvent(ExecuteNow.name, EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "reticleover")
	else
	  EVENT_MANAGER:UnregisterForUpdate(executeIndicatorIdentifier)
	  ExecuteNowVisualIndicator:SetHidden(true)
	  ExecuteNow.targetHealthPercentage = nil
	  EVENT_MANAGER:UnregisterForEvent(ExecuteNow.name, EVENT_RETICLE_TARGET_CHANGED)
	  EVENT_MANAGER:UnregisterForEvent(ExecuteNow.name, EVENT_POWER_UPDATE)
	end
  end
end


-------------------------------------------------------------------------------------------------
-- Settings
-------------------------------------------------------------------------------------------------

function ExecuteNow.CreateSettingsWindow()
  local panelData = {
	type = "panel",
	name = "ExecuteNow",
	displayName = "Execute Now",
	author = "mooNylo",
	version = ExecuteNow.version,
	slashCommand = "/executenow",
	registerForRefresh = true,
	registerForDefaults = true,
  }
  local cntrlOptionsPanel = LAM2:RegisterAddonPanel("ExecuteNowControl", panelData)
  local optionsData = {
	[1] = {
	  type = "button",
	  name = function() if ExecuteNow.VisualIndicator.Show then return "Hide" else return "Show" end end,
	  tooltip = "When ON the Execute Indicator will be shown. Use this to get a preview and change the position.",
	  func = function(control)
				ExecuteNow.VisualIndicator.Show = not ExecuteNow.VisualIndicator.Show
				ExecuteNowVisualIndicator:SetHidden(not ExecuteNow.VisualIndicator.Show)
			 end,
    },
    [2] = {
	  type = "header",
	  name = "Settings",
	  width = "full",
    },
	[3] = {
	  type = "slider",
	  name = "Indicator Time",
	  tooltip = "How long should the Execute Indicator be shown",
	  min = 500,
	  max = 4000,
	  step = 100,
	  default = 1500,
	  getFunc = function() return ExecuteNow.VisualIndicator.Settings.MilliSecondsToShowIndicator end,
	  setFunc = function(newValue)
				  ExecuteNow.VisualIndicator.Settings.MilliSecondsToShowIndicator = newValue
                end,
    },
    [4] = {
        type = "checkbox",
        name = "Show again on target change",
        tooltip = "If you want the Execute! to reappear after changing to an executable target, check this.",
        getFunc = function() return ExecuteNow.VisualIndicator.Settings.ReShowExecuteWhenTargetChange end,
        setFunc = function(newValue) ExecuteNow.VisualIndicator.Settings.ReShowExecuteWhenTargetChange = newValue end,
        width = "full",
    },
    [5] = {
	  type = "slider",
	  name = "Hitpoints Threshold",
	  tooltip = "How much Hitpoints (minimum) should a target have before Execute gets shown?",
	  min = 0,
	  max = 30000000,
	  step = 1000000,
	  default = 3000000,
	  getFunc = function() return ExecuteNow.VisualIndicator.Settings.MinimumHitpointsThreshold end,
	  setFunc = function(newValue)
				  ExecuteNow.VisualIndicator.Settings.MinimumHitpointsThreshold = newValue
                end,
    },
	[6] = {
        type = "header",
        name = "Style",
        width = "full",
    },
    [7] = {
	  type = "slider",
	  name = "Indicator Size",
	  tooltip = "Adjust the size of the Execute Indicator",
	  min = 1,
	  max = 5,
	  step = 1,
	  default = 2,
	  getFunc = function() return ExecuteNow.VisualIndicator.Settings.Scale end,
	  setFunc = function(newValue)
				  ExecuteNow.VisualIndicator.Settings.Scale = newValue
                  ExecuteNowVisualIndicator:SetScale(newValue)
                  end,
    },
    [8] = {
	  type = "slider",
	  name = "Indicator Opacity",
	  tooltip = "Adjust the opacity of the Execute Indicator",
	  min = 0,
	  max = 1,
	  step = 0.1,
	  default = 0.5,
	  getFunc = function() return ExecuteNow.VisualIndicator.Settings.Alpha end,
	  setFunc = function(newValue)
				  ExecuteNow.VisualIndicator.Settings.Alpha = newValue
                  ExecuteNowVisualIndicator:SetAlpha(newValue)
                  end,
    },
  }
  LAM2:RegisterOptionControls("ExecuteNowControl", optionsData)
end

-------------------------------------------------------------------------------------------------
-- Initialization
-------------------------------------------------------------------------------------------------

function ExecuteNow:Initialize()
  -- UI
  ExecuteNow.VisualIndicator.Settings = ZO_SavedVars:NewAccountWide("ExecuteNowSavedVariables", ExecuteNow.VisualIndicator.variableVersion, nil, ExecuteNow.VisualIndicator.Default)
  ExecuteNow.RestorePosition()
  -- Settings
  ExecuteNow.CreateSettingsWindow()
  -- Main
  ExecuteNow.inCombat = IsUnitInCombat("player")
  ExecuteNow.targetHealthPercentage = nil
  ExecuteNow.executeThreshold = GetExecuteThreshold()
  if ExecuteNow.executeThreshold > 0 then
    EVENT_MANAGER:RegisterForEvent(ExecuteNow.name, EVENT_PLAYER_COMBAT_STATE, ExecuteNow.OnPlayerCombatState)
  end
  EVENT_MANAGER:UnregisterForEvent(ExecuteNow.name, EVENT_ADD_ON_LOADED)
end

function ExecuteNow.OnAddOnLoaded(event, addonName)
  if addonName == ExecuteNow.name then
    ExecuteNow:Initialize()
  end
end

EVENT_MANAGER:RegisterForEvent(ExecuteNow.name, EVENT_ADD_ON_LOADED, ExecuteNow.OnAddOnLoaded)


