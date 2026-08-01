if CombatTracker == nil then CombatTracker = {} end
local CombatTracker = CombatTracker

local EM = EVENT_MANAGER


CombatTracker.name = "CombatTracker"
CombatTracker.version = "0.7"
CombatTracker.defaults = {
  enabled = true,
  locked = false,
  x = GuiRoot:GetWidth() / 2,
  y = GuiRoot:GetHeight() / 2,

  showTime = true,
  timePrecision = 2,
  updateInterval = 50,
  keep = true,
  stopOnBossDeath = false,

  inCombatText = "In Combat",
  outOfCombatText = "Out of Combat",
  inCombatFormat = "%s",
  outOfCombatFormat = "%s",

  fontFace = "$(GAMEPAD_BOLD_FONT)",
  fontSize = "30",
  fontStyle = "outline",
  horizontalAlignment = TEXT_ALIGN_LEFT,
  verticalAlignment = TEXT_ALIGN_TOP,

  inCombatColor = {1, 0.2, 0.2, 1},
  outOfCombatColor = {0.12, 0.82, 0.17, 1},
}

local function onAddOnLoaded(_, name)
  if name ~= CombatTracker.name then return end
  EM:UnregisterForEvent(CombatTracker.name, EVENT_ADD_ON_LOADED)

  CombatTracker.savedVars = ZO_SavedVars:NewAccountWide("CombatTrackerSavedVars", 0, nil, CombatTracker.defaults)
  CombatTracker.setupUI()
  CombatTracker.setupAddonMenu()
end

EM:RegisterForEvent(CombatTracker.name, EVENT_ADD_ON_LOADED, onAddOnLoaded)