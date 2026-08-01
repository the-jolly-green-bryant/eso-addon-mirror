--[[
  This file is part of Aenathel's Lazy Riding Skill Trainer, licensed under
  The MIT License. See the LICENSE file of this project for more information.
--]]

AenathelsLazyRidingSkillTrainer = {}

-- AenathelsLazyRidingSkillTrainer is a bit of a mouthful, so shorten it
local AELRST = AenathelsLazyRidingSkillTrainer

AELRST.id = "AELRST"
AELRST.name = "AenathelsLazyRidingSkillTrainer"
AELRST.author = "Aenathel (PC-EU)"
AELRST.title = "Aenathel's Lazy Riding Skill Trainer"

-- Lua API
local string = string

-- ESO UI API constants
local CHATTER_START_STABLE = CHATTER_START_STABLE
local CURRENCY_LOCATION_CHARACTER = CURRENCY_LOCATION_CHARACTER
local CURT_MONEY = CURT_MONEY
local EVENT_MANAGER = EVENT_MANAGER
local SCENE_MANAGER = SCENE_MANAGER
local STABLE_MANAGER = STABLE_MANAGER

-- ESO UI API functions
local zo_strformat = zo_strformat
local GetChatterOption = GetChatterOption
local GetControl = GetControl
local GetCurrencyAmount = GetCurrencyAmount
local GetString = GetString
local GetTimeUntilCanBeTrained = GetTimeUntilCanBeTrained
local GetTrainingCost = GetTrainingCost
local SelectChatterOption = SelectChatterOption
local ZO_Stable_TrainButtonClicked = ZO_Stable_TrainButtonClicked

-- Riding skills
local CARRY = "Carry"
local SPEED = "Speed"
local STAMINA = "Stamina"

local CARRY_SPEED_STAMINA = "CARRY_SPEED_STAMINA"
local CARRY_STAMINA_SPEED = "CARRY_STAMINA_SPEED"
local SPEED_CARRY_STAMINA = "SPEED_CARRY_STAMINA"
local SPEED_STAMINA_CARRY = "SPEED_STAMINA_CARRY"
local STAMINA_CARRY_SPEED = "STAMINA_CARRY_SPEED"
local STAMINA_SPEED_CARRY = "STAMINA_SPEED_CARRY"

AELRST.ridingSkillNameIds = {
  [CARRY] = SI_RIDINGTRAINTYPE2,
  [SPEED] = SI_RIDINGTRAINTYPE1,
  [STAMINA] = SI_RIDINGTRAINTYPE3,
}

AELRST.ridingSkillPriorities = {
  CARRY_SPEED_STAMINA,
  CARRY_STAMINA_SPEED,
  SPEED_CARRY_STAMINA,
  SPEED_STAMINA_CARRY,
  STAMINA_CARRY_SPEED,
  STAMINA_SPEED_CARRY,
}

AELRST.ridingSkillPriorityChoices = {}

AELRST.ridingSkillPriorityOrder = {
  [CARRY_SPEED_STAMINA] = { CARRY, SPEED, STAMINA },
  [CARRY_STAMINA_SPEED] = { CARRY, STAMINA, SPEED },
  [SPEED_CARRY_STAMINA] = { SPEED, CARRY, STAMINA },
  [SPEED_STAMINA_CARRY] = { SPEED, STAMINA, CARRY },
  [STAMINA_CARRY_SPEED] = { STAMINA, CARRY, SPEED },
  [STAMINA_SPEED_CARRY] = { STAMINA, SPEED, CARRY },
}

-- Chat output
local chat = LibChatMessage(AELRST.title, AELRST.id)

-- Saved variables
local savedVars = {}

AELRST.defaults = {
  -- Automatically disabled on characters that have riding skill maxed out
  enabled = not STABLE_MANAGER:IsRidingSkillMaxedOut(),
  logOutAfterTraining = false,
  printStartupMessage = true,
}

-- Register add-on menu
local function RegisterAddonMenu()
  -- Populate riding skill priorities for settings panel
  for i = 1, #AELRST.ridingSkillPriorities do
    local priority = AELRST.ridingSkillPriorities[i]
    local stringId = string.format("AELRST_RIDING_SKILL_PRIORITY_%s", priority)

    -- Have to access the global here to get the translation
    AELRST.ridingSkillPriorityChoices[i] = GetString(_G[stringId])
  end

  local panelName = string.format("%sSettingsPanel", AELRST.name)

  local LAM = LibAddonMenu2

  LAM:RegisterAddonPanel(panelName, {
    type = "panel",
    name = AELRST.title,
    author = AELRST.author,
    version = GetString(AELRST_ADDON_VERSION),
    website = GetString(AELRST_ADDON_WEBSITE),
    slashCommand = "/lrst",
  })

  LAM:RegisterOptionControls(panelName, {
    {
      type = "checkbox",
      name = GetString(AELRST_SETTINGS_ENABLED),
      getFunc = function() return savedVars.enabled end,
      setFunc = function(value) savedVars.enabled = value end,
    },
    {
      type = "checkbox",
      name = GetString(AELRST_SETTINGS_LOG_OUT_AFTER_TRAINING),
      warning = GetString(AELRST_SETTINGS_LOG_OUT_AFTER_TRAINING_WARNING),
      getFunc = function() return savedVars.logOutAfterTraining end,
      setFunc = function(value) savedVars.logOutAfterTraining = value end,
    },
    {
      type = "checkbox",
      name = GetString(AELRST_SETTINGS_PRINT_STARTUP_MESSAGE),
      getFunc = function() return savedVars.printStartupMessage end,
      setFunc = function(value) savedVars.printStartupMessage = value end,
    },
    {
      type = "dropdown",
      name = GetString(AELRST_SETTINGS_RIDING_SKILL_PRIORITY),
      choices = AELRST.ridingSkillPriorityChoices,
      choicesValues = AELRST.ridingSkillPriorities,
      getFunc = function() return savedVars.ridingSkillPriority end,
      setFunc = function(value) savedVars.ridingSkillPriority = value end,
    },
  })
end

-- Called when the add-on is being loaded
function AELRST.Initialize()
  -- Create character-specific saved variables
  savedVars = ZO_SavedVars:New("AenathelsLazyRidingSkillTrainer_SavedVariables", 1, nil, AELRST.defaults)

  RegisterAddonMenu()
end

-- Get riding skill stats indexed by riding skill
function AELRST.GetIndexedStats()
  local speed, maxSpeed, stamina, maxStamina, carry, maxCarry = STABLE_MANAGER:GetStats()

  return {
    [CARRY] = {
      current = carry,
      max = maxCarry,
    },
    [SPEED] = {
      current = speed,
      max = maxSpeed,
    },
    [STAMINA] = {
      current = stamina,
      max = maxStamina,
    },
  }
end

-- Try to train a riding skill if it's not already maxed
function AELRST.TryTrainRidingSkill(skill, stat)
  if stat.current < stat.max then
    local control = GetControl(string.format("ZO_StablePanel%sTrainRowTrainButton", skill))
    ZO_Stable_TrainButtonClicked(control)

    return true
  end

  return false
end

-- Called when riding skill is trained
function AELRST.TrainedRidingSkill(skill, value)
  local skillName = GetString(AELRST.ridingSkillNameIds[skill])
  local coloredValue = string.format("|cFFFFFF%s|r", value)
  chat:Print(zo_strformat(GetString(AELRST_CHAT_TRAINED_RIDING_SKILL), skillName, coloredValue))
end

-- Train the next riding skill according to priority
function AELRST.TrainNextRidingSkill()
  if not savedVars.ridingSkillPriority then
    chat:Print(GetString(AELRST_CHAT_RIDING_SKILL_PRIORITY_NOT_CONFIGURED))
    return
  end

  if GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER) < GetTrainingCost() then
    chat:Print(GetString(AELRST_CHAT_NOT_ENOUGH_GOLD_TO_TRAIN))
    return false
  end

  local order = AELRST.ridingSkillPriorityOrder[savedVars.ridingSkillPriority]
  local indexedStats = AELRST.GetIndexedStats();

  for i = 1, #order do
    local skill = order[i]
    local stat = indexedStats[skill]

    if AELRST.TryTrainRidingSkill(skill, stat) then
      AELRST.TrainedRidingSkill(skill, stat.current + 1)
      return true
    end
  end

  return false
end

-- Called when the add-on is loaded so we can initialize
function AELRST.OnAddOnLoaded(_, addonName)
  if addonName == AELRST.name then
    EVENT_MANAGER:UnregisterForEvent(AELRST.name, EVENT_ADD_ON_LOADED)

    AELRST.Initialize()
  end
end

-- Called when chatter (talking to an NPC) begins
function AELRST.OnChatterBegin(_, optionCount)
  -- Skip if not enabled on this character
  if not savedVars.enabled then return end

  -- We need options to do anything
  if optionCount == 0 then return end

  for i = 1, optionCount do
    local _, optionType = GetChatterOption(i)

    -- If we're talking to a stablemaster...
    if optionType == CHATTER_START_STABLE then
      -- ...then select the first option to open stables
      SelectChatterOption(i)
      return
    end
  end
end

-- Called when stable is opened
function AELRST.OnStableInteractStart()
  -- Skip if not enabled on this character
  if not savedVars.enabled then return end

  -- If no more skills to train, then we're done
  if STABLE_MANAGER:IsRidingSkillMaxedOut() then return end

  -- Check time until next skill can be trained
  local timeUntilCanBeTrained = GetTimeUntilCanBeTrained()

  if timeUntilCanBeTrained == 0 then
    -- Time to train the next riding skill
    local success = AELRST.TrainNextRidingSkill()
    if success then
      -- Dismiss stables after training successfully
      SCENE_MANAGER:ShowBaseScene()

      if savedVars.logOutAfterTraining then
        Logout()
      end
    end
  end
end

-- Called when player is loaded and everything is ready
function AELRST.PlayerLoaded(_, initial)
  -- Prevent executing this more than once per login
  EVENT_MANAGER:UnregisterForEvent(AELRST.name, EVENT_PLAYER_ACTIVATED)

  if initial and savedVars.printStartupMessage then
    chat:Print(zo_strformat(GetString(AELRST_CHAT_STARTUP_MESSAGE), GetString(AELRST_ADDON_VERSION)))
  end
end

-- Register event handlers
EVENT_MANAGER:RegisterForEvent(AELRST.name, EVENT_ADD_ON_LOADED, AELRST.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(AELRST.name, EVENT_CHATTER_BEGIN, AELRST.OnChatterBegin)
EVENT_MANAGER:RegisterForEvent(AELRST.name, EVENT_STABLE_INTERACT_START, AELRST.OnStableInteractStart)
EVENT_MANAGER:RegisterForEvent(AELRST.name, EVENT_PLAYER_ACTIVATED, AELRST.PlayerLoaded)
