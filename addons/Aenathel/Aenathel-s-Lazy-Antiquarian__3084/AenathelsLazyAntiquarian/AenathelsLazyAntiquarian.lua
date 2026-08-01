--[[
  This file is part of Aenathel's Lazy Antiquarian, licensed under The MIT
  License. See the LICENSE file of this project for more information.
--]]

AenathelsLazyAntiquarian = {}

-- AenathelsLazyAntiquarian is a bit of a mouthful, so shorten it
local AELA = AenathelsLazyAntiquarian

AELA.id = "AELA"
AELA.name = "AenathelsLazyAntiquarian"
AELA.author = "Aenathel (PC-EU)"
AELA.title = "Aenathel's Lazy Antiquarian"

-- ESO UI API constants
local ANTIQUITY_DATA_MANAGER = ANTIQUITY_DATA_MANAGER
local CENTER_SCREEN_ANNOUNCE = CENTER_SCREEN_ANNOUNCE
local CENTER_SCREEN_ANNOUNCE_TYPE_COLLECTIBLES_UPDATED = CENTER_SCREEN_ANNOUNCE_TYPE_COLLECTIBLES_UPDATED
local ZO_Antiquity = ZO_Antiquity
local ZO_ERROR_COLOR = ZO_ERROR_COLOR

-- ESO UI API functions
local CanScryForAntiquity = CanScryForAntiquity
local GetAntiquityQualityColor = GetAntiquityQualityColor
local GetString = GetString
local ScryForAntiquity = ScryForAntiquity
local zo_strformat = zo_strformat

-- Lua API
local string = string

-- Antiquities
AELA.antiquityDifficulties = {
  1,
  2,
  3,
  4,
  5,
}

AELA.antiquityDifficultyChoices = {}

-- Saved variables
local savedVars = {}

AELA.defaults = {
  maxAutoscryDifficulty = 3,
  onlyAutoscryRepeatableAntiquities = true,
}

-- Register add-on menu
local function RegisterAddonMenu()
  -- Populate antiquity difficulties for settings panel
  for i = 1, #AELA.antiquityDifficulties do
    local difficulty = AELA.antiquityDifficulties[i]
    local stringId = string.format("SI_ANTIQUITYDIFFICULTY%s", difficulty)
    local colorDef = GetAntiquityQualityColor(i)

    -- Have to access the global here to get the translation
    AELA.antiquityDifficultyChoices[i] = colorDef:Colorize(GetString(_G[stringId]))
  end

  local panelName = string.format("%sSettingsPanel", AELA.name)

  local LAM = LibAddonMenu2

  LAM:RegisterAddonPanel(panelName, {
    type = "panel",
    name = AELA.title,
    author = AELA.author,
    version = GetString(AELA_ADDON_VERSION),
    website = GetString(AELA_ADDON_WEBSITE),
  })

  LAM:RegisterOptionControls(panelName, {
    {
      type = "description",
      text = GetString(AELA_SETTINGS_DESCRIPTION),
    },
    {
      type = "dropdown",
      name = GetString(AELA_SETTINGS_MAX_AUTOSCRY_DIFFICULTY),
      choices = AELA.antiquityDifficultyChoices,
      choicesValues = AELA.antiquityDifficulties,
      getFunc = function() return savedVars.maxAutoscryDifficulty end,
      setFunc = function(value) savedVars.maxAutoscryDifficulty = value end,
    },
    {
      type = "checkbox",
      name = GetString(AELA_SETTINGS_ONLY_AUTOSCRY_REPEATABLE_ANTIQUITIES),
      getFunc = function() return savedVars.onlyAutoscryRepeatableAntiquities end,
      setFunc = function(value) savedVars.onlyAutoscryRepeatableAntiquities = value end,
    }
  })
end

local function ShowAnnouncement(title, text, icon)
  local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
  messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_COLLECTIBLES_UPDATED)
  messageParams:SetText(title, text)

  if icon then
    messageParams:SetIconData(icon, "EsoUI/Art/Achievements/achievements_iconBG.dds")
  else
    messageParams:MarkSuppressIconFrame()
  end

  CENTER_SCREEN_ANNOUNCE:DisplayMessage(messageParams)
end

function AenathelsLazyAntiquarian.Autoscry()
  local antiquity

  -- Iterate through scryable antiquities and pick the last
  for _, value in ANTIQUITY_DATA_MANAGER:AntiquityIterator({ZO_Antiquity.MeetsAllScryingRequirements}) do
    if value.difficulty <= savedVars.maxAutoscryDifficulty and (not savedVars.onlyAutoscryRepeatableAntiquities or value.isRepeatable) then
      antiquity = value
    end
  end

  if antiquity ~= nil then
    -- Only show announcement if antiquity can be scried. The game will show an
    -- error message if scrying is not possible when ScryForAntiquity is called.
    if CanScryForAntiquity(antiquity.id) then
      local colorDef = GetAntiquityQualityColor(antiquity.quality)
      ShowAnnouncement(GetString(AELA_SCRYING), colorDef:Colorize(zo_strformat("<<1>>", antiquity.name)), antiquity.icon)
    end

    ScryForAntiquity(antiquity.antiquityId)
  else
    ShowAnnouncement(ZO_ERROR_COLOR:Colorize(GetString(AELA_NO_AUTOSCRYABLE_ANTIQUITIES_IN_ZONE)))
  end
end

-- Called when the add-on is being loaded
function AELA.Initialize()
  -- Create character-specific saved variables
  savedVars = ZO_SavedVars:New("AenathelsLazyAntiquarian_SavedVariables", 1, nil, AELA.defaults)

  RegisterAddonMenu()
end

-- Called when the add-on is loaded so we can initialize
function AELA.OnAddOnLoaded(_, addonName)
  if addonName == AELA.name then
    EVENT_MANAGER:UnregisterForEvent(AELA.name, EVENT_ADD_ON_LOADED)

    AELA.Initialize()
  end
end

-- Register event handlers
EVENT_MANAGER:RegisterForEvent(AELA.name, EVENT_ADD_ON_LOADED, AELA.OnAddOnLoaded)
