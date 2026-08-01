DynamicFPS = {
  name = "DynamicFPS",           -- Matches folder and Manifest file names.
  version = "0.1.2",                -- A nuisance to match to the Manifest.
  author = "SirNightstorm",
  color = "DDFFEE",             -- Used in menu titles and so on.
  menuName = "Dynamic FPS",          -- A UNIQUE identifier for menu object.
  svName = "DynamicFPS_SavedVariables",

  isInCombat = false,
  isInDialog = false,
  isScrying = false,
  hasFocus = true,
  paused = false,
  -- originalMinFrameTime = 0.01,
  callbacksRegistered =false,
  hooksRegistered = false,
}

-- Default settings.
local defaultSavedVars = {
  -- firstLoad = true,                   -- First time the addon is loaded ever.
  activeFPS = 60,
  combatFPS = 165,
  idleFPS = 30,
  afkFPS = 10,

  idleDelay = 30,
  afkDelay = 180,

  showAlerts = false,
  logging = false,
  enabled = true,
  fixedFPS = nil
}
DynamicFPS.savedVars = defaultSavedVars

if LibDebugLogger then
  DynamicFPS.logger = LibDebugLogger(DynamicFPS.name)
end

local ACTIVE_CHECK_DELAY_MS = 1000
local IDLE_CHECK_DELAY_MS = 200

-- local currentFPS = 0
local currentState = nil

---@type number
local lastActiveTime = 0

local activeLabelColour = ZO_TOOLTIP_DEFAULT_COLOR
local idleLabelColour = ZO_ColorDef:New("c0ffa6")
local afkLabelColour = ZO_ColorDef:New("66aaff")
local combatLabelColour = ZO_ColorDef:New("ff9966")

local function ucFirst(str)
  return (str:gsub("^%l", string.upper))
end

function DynamicFPS.LogDebug(message)
  if DynamicFPS.savedVars.logging and DynamicFPS.logger then
    DynamicFPS.logger:Debug(message)
  end
end

function DynamicFPS.LogInfo(message)
  if DynamicFPS.savedVars.logging and DynamicFPS.logger then
    DynamicFPS.logger:Info(message)
  end
end

function DynamicFPS.SetActive()
  lastActiveTime = GetGameTimeSeconds()
  DynamicFPS.UpdateState()
end

function DynamicFPS.UpdateState()
  local state
  local inactiveTime = GetGameTimeSeconds() - lastActiveTime

  if DynamicFPS.isInCombat then
    state = "combat"
  elseif inactiveTime >= DynamicFPS.savedVars.afkDelay and not DynamicFPS.isScrying then
    state = "afk"
  elseif inactiveTime >= DynamicFPS.savedVars.idleDelay and not DynamicFPS.isInDialog and not DynamicFPS.isScrying then
    state = "idle"
  else
    state = "active"
  end

  DynamicFPS.SetState(state)
end

---Update DynamicFPS.currentState, and make any necessary game setting changes
---@param state string The state to update to
function DynamicFPS.SetState(state)
  if DynamicFPS.paused or not DynamicFPS.savedVars.enabled then return end

  if state ~= currentState then
    local newFPS
    local newDelayMS
    local colour = activeLabelColour
  
    if state == "combat" then
      newFPS = DynamicFPS.savedVars.combatFPS
      newDelayMS = 0
      colour = combatLabelColour
    elseif state == "active" then
      newFPS = DynamicFPS.savedVars.activeFPS
      newDelayMS = ACTIVE_CHECK_DELAY_MS
      colour = activeLabelColour
    elseif state == "idle" then
      newFPS = DynamicFPS.savedVars.idleFPS
      newDelayMS = IDLE_CHECK_DELAY_MS
      colour = idleLabelColour
    elseif state == "afk" then
      newFPS = DynamicFPS.savedVars.afkFPS
      newDelayMS = IDLE_CHECK_DELAY_MS
      colour = afkLabelColour
    end
  
    EVENT_MANAGER:UnregisterForUpdate(DynamicFPS.name.."_Update")
    SetCVar("MinFrameTime.2", ""..(1 / newFPS))
    ZO_PerformanceMetersFramerateMeterLabel:SetColor(colour:UnpackRGB())
    if newDelayMS > 0 then
      DynamicFPS.LogDebug("Setting FPS to "..state..": "..newFPS.."fps, idle check every "..newDelayMS.."ms")
      EVENT_MANAGER:RegisterForUpdate(DynamicFPS.name.."_Update", newDelayMS, DynamicFPS.Update)
    else
      DynamicFPS.LogDebug("Setting FPS to "..state..": "..newFPS.."fps")
    end

    if DynamicFPS.savedVars.showAlerts then
      ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, ucFirst(state))
    end
    -- currentFPS = newFPS
    currentState = state
  end
end

local x_old, y_old, h_old = GetMapPlayerPosition("player")
local heading_old = GetPlayerCameraHeading()
function DynamicFPS.Update()
  if DynamicFPS.paused or not DynamicFPS.savedVars.enabled then return end
  -- DynamicFPS.LogDebug("Update")

  local function isPlayerIdle()
      -- Check if in combat
      if IsUnitInCombat("player") then return false end

      if not DynamicFPS.hasFocus then return true end

      -- Comparing current position and heading with data of last run
      local x_new, y_new, h_new = GetMapPlayerPosition("player")
      local heading_new = GetPlayerCameraHeading()

      if x_old == x_new and y_old == y_new and h_old == h_new and heading_new == heading_old then
          return true
      else
          x_old, y_old, h_old, heading_old = x_new, y_new, h_new, heading_new
          return false
      end
  end

  local gameTime = GetGameTimeSeconds()
  if not isPlayerIdle() then
    --DynamicFPS.LogDebug("Not idle")
    lastActiveTime = gameTime
  else
    --DynamicFPS.LogDebug("Idle "..(gameTime - lastActiveTime).."s")
  end
  DynamicFPS.UpdateState()
end

function DynamicFPS.OnEnabledChanged(enabled)
  if enabled then
    DynamicFPS.LogInfo("Enabling")
    DynamicFPS.SetActive()
    DynamicFPS.RegisterCallbacks()
  else
    DynamicFPS.LogInfo("Disabling")
    DynamicFPS.UnregisterCallbacks()
    EVENT_MANAGER:UnregisterForUpdate(DynamicFPS.name.."_CheckIdle")
    SetCVar("MinFrameTime.2", ""..(1 / DynamicFPS.savedVars.fixedFPS))
  end
end

local function onSlashCommand(extra)
  if extra == "on" or extra == "enable" then
    DynamicFPS.savedVars.enabled = true
    DynamicFPS.OnEnabledChanged(true)
  elseif extra == "off" or extra == "disable" then
    DynamicFPS.savedVars.enabled = false
    DynamicFPS.OnEnabledChanged(false)
  elseif extra == "logging on" then
    DynamicFPS.savedVars.logging = true
  elseif extra == "logging off" then
    DynamicFPS.savedVars.logging = false
  elseif extra == "" or extra == nil then
    LibAddonMenu2:OpenToPanel(DynamicFPS.settingsPanel)
  else
    d("DynamicFPS: Unknown sub-command '"..extra.."'")
  end
end

local function initialise()
  DynamicFPS.savedVars = ZO_SavedVars:NewAccountWide(DynamicFPS.svName, 1, nil, defaultSavedVars)

  local originalMinFrameTime = GetCVar("MinFrameTime.2")
  if DynamicFPS.savedVars.enabled then
    DynamicFPS.LogInfo("Initialising")
  else
    DynamicFPS.LogInfo("Disabled - setting fixed "..DynamicFPS.savedVars.fixedFPS.."fps")
  end

  if DynamicFPS.savedVars.fixedFPS == nil then
    DynamicFPS.savedVars.fixedFPS = math.floor(1 / originalMinFrameTime + 0.5)
  end

  DynamicFPS.LoadSettings()

  DynamicFPS.OnEnabledChanged(DynamicFPS.savedVars.enabled)

  SLASH_COMMANDS["/dfps"] = onSlashCommand
end

local function onAddOnLoaded(_, addonName)
  -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
  if addonName ~= DynamicFPS.name then return end

  initialise()

  --unregister the event again as our addon was loaded now and we do not need it anymore to be run for each other addon that will load
  EVENT_MANAGER:UnregisterForEvent(DynamicFPS.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(DynamicFPS.name, EVENT_ADD_ON_LOADED, onAddOnLoaded)
