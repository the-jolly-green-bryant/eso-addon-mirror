local LAM = LibAddonMenu2
local async = LibAsync

local INFAMY_LEVEL_DISREPUTABLE = 1
local INFAMY_LEVEL_NOTORIOUS = 2
local INFAMY_LEVEL_FUGITIVE = 3
local SHIELD_OPACITY_INCREMENT = 0.1
local GREEN_SHIELD_OPACITY = 0.5
local SHIELD_LARGE = 1.0
local SHIELD_NORMAL = 0.5

GuardWarner = {}

GuardWarner.savedVariables = nil
GuardWarner.name = "GuardWarner"
GuardWarner.icon = nil
GuardWarner.shieldOpacity = 0.5
GuardWarner.shieldPulseDirection = 1
GuardWarner.shieldPulseActive = true
GuardWarner.bountyTimeText = ""
GuardWarner.lastTime = 0
GuardWarner.notOnGuard = false

GuardWarner.defaults = {
  showBountyTimer = true,
  largeShield = false,
  showKosWarning = true,
  playKosAlertSound = true,
  showBountyWarning = true,
  playBountyAlertSound = false,
  showUpstandingWarning = true,
  playUpstandingAlertSound = false,
}

function GuardWarner.Initialize()
  GuardWarner.savedVariables = ZO_SavedVars:NewCharacterIdSettings("GuardWarnerSavedVariables", 1, GetWorldName(), GuardWarner.defaults)

  -- Register for events that interest us
  EVENT_MANAGER:RegisterForEvent(GuardWarner.name, EVENT_RETICLE_TARGET_CHANGED, GuardWarner.OnReticleTargetChanged)
  
  -- Pre-load a shield .dds icon centered just above the player's reticle and hide it.
  GuardWarner.inCombat = IsUnitInCombat("player")
  GuardWarner.icon = WINDOW_MANAGER:CreateControl("GUARD_WARNER_ICON", ZO_ReticleContainer, CT_TEXTURE)
  GuardWarner.icon:ClearAnchors()
  GuardWarner.icon:SetAnchor(CENTER, ZO_ReticleContainer, CENTER, 0, -100)
  GuardWarner.icon:SetTexture("GuardWarner\\Textures\\shield.dds")
  GuardWarner.icon:SetDimensions(128, 128)
  GuardWarner.icon:SetColor(255, 255, 255, GuardWarner.shieldOpacity)
  GuardWarner.icon:SetScale(SHIELD_NORMAL)
  GuardWarner.icon:SetHidden(true)

  -- Initialize the settings panel
  local panelData = {
    type = "panel",
    name = GetString(TITLE),
    displayName = "|cFFFFB0" .. GetString(TITLE) .. "|r",
    author = GetString(AUTHOR),
    version = GetString(VERSION),
    slashCommand = "/guardwarner",
    registerForRefresh = true,
    registerForDefaults = true,
    website = GetString(WEBSITE),
  }
  LAM:RegisterAddonPanel("GW", panelData)

  local optionsTable = {
    {
      type = "checkbox",
      name = GetString(SHOW_BOUNTY_TIMER_LABEL),
      tooltip = GetString(SHOW_BOUNTY_TIMER_LABEL),
      getFunc = function()
        return GuardWarner.savedVariables.showBountyTimer
      end,
      setFunc = function(state)
        GuardWarner.savedVariables.showBountyTimer = state
      end,
      default = true,
    },
    {
      type = "checkbox",
      name = GetString(LARGE_SHIELD_LABEL),
      tooltip = GetString(LARGE_SHIELD_LABEL),
      getFunc = function()
        return GuardWarner.savedVariables.showLargeShield
      end,
      setFunc = function(state)
        GuardWarner.savedVariables.showLargeShield = state
      end,
      default = true,
    },
      {
    type = "checkbox",
    name = GetString(KOS_WARNING_LABEL),
    tooltip = GetString(KOS_WARNING_LABEL),
    getFunc = function()
      return GuardWarner.savedVariables.showKosWarning
    end,
    setFunc = function(state)
      GuardWarner.savedVariables.showKosWarning = state
    end,
    default = true,
  },
  {
    type = "checkbox",
    name = GetString(KOS_ALERT_SOUND_LABEL),
    tooltip = GetString(KOS_ALERT_SOUND_LABEL),
    getFunc = function()
      return GuardWarner.savedVariables.playKosAlertSound
    end,
    setFunc = function(state)
      GuardWarner.savedVariables.playKosAlertSound = state
    end,
    default = true,
  },
  {
    type = "checkbox",
    name = GetString(BOUNTY_WARNING_LABEL),
    tooltip = GetString(BOUNTY_WARNING_LABEL),
    getFunc = function()
      return GuardWarner.savedVariables.showBountyWarning
    end,
    setFunc = function(state)
      GuardWarner.savedVariables.showBountyWarning = state
    end,
    default = true,
  },
  {
    type = "checkbox",
    name = GetString(BOUNTY_ALERT_SOUND_LABEL),
    tooltip = GetString(BOUNTY_ALERT_SOUND_LABEL),
    getFunc = function() return
      GuardWarner.savedVariables.playBountyAlertSound
    end,
    setFunc = function(state)
      GuardWarner.savedVariables.playBountyAlertSound = state
    end,
    default = false,
  },
  {
    type = "checkbox",
    name = GetString(UPSTANDING_WARNING_LABEL),
    tooltip = GetString(UPSTANDING_WARNING_LABEL),
    getFunc = function() return
      GuardWarner.savedVariables.showUpstandingWarning
    end,
    setFunc = function(state)
      GuardWarner.savedVariables.showUpstandingWarning = state
    end,
    default = true,
  },
  {
    type = "checkbox",
    name = GetString(UPSTANDING_ALERT_SOUND_LABEL),
    tooltip = GetString(UPSTANDING_ALERT_SOUND_LABEL),
    getFunc = function() return
      GuardWarner.savedVariables.playUpstandingAlertSound
    end,
    setFunc = function(state)
      GuardWarner.savedVariables.playUpstandingAlertSound = state
    end,
    default = false,
  },
}
  LAM:RegisterOptionControls("GW", optionsTable)
  GuardWarner.lastTime = GetSecondsUntilBountyDecaysToZero()
end

-- When the player moves their reticle over an invulnerable guard:
--   and the player has a bounty, we want a red shield to appear above the reticle and sound an alert.
--   and the player has no bounty, we want to optionally display a yellow shield above the reticle.
function GuardWarner.OnReticleTargetChanged(eventCode)
  if (IsUnitInvulnerableGuard("reticleover")) then
    GuardWarner.notOnGuard = false
    if (GuardWarner.savedVariables.showLargeShield) then
      GuardWarner.icon:SetScale(SHIELD_LARGE)
    else
      GuardWarner.icon:SetScale(SHIELD_NORMAL)
    end

    async:WaitUntil(function()
      if (GuardWarner.notOnGuard) then
        GuardWarner.icon:SetHidden(true)
        GuardWarnerGuiLabel:SetHidden(true)
      else
        GuardWarner.StepShieldOpacity()
        GuardWarner.DrawShield()
        GuardWarner.DrawBountyTimeText()
      end
      return GuardWarner.notOnGuard
    end
    )

    -- Play alert sound if required
    if (IsKillOnSight() and GuardWarner.savedVariables.playKosAlertSound) then
      PlaySound(SOUNDS.JUSTICE_STATE_CHANGED)
    elseif (GetBounty() > 0 and GuardWarner.savedVariables.playBountyAlertSound) then
      PlaySound(SOUNDS.JUSTICE_STATE_CHANGED)
    elseif (GetBounty() == 0 and GuardWarner.savedVariables.playUpstandingAlertSound) then
      PlaySound(SOUNDS.JUSTICE_STATE_CHANGED)
    end
  else
    GuardWarner.notOnGuard = true
  end
end

-- Draw the correct shield colour at opacity
function GuardWarner.DrawShield()
  infamyLevel = GetInfamyLevel(GetInfamy())
  if (infamyLevel >= INFAMY_LEVEL_NOTORIOUS and GuardWarner.savedVariables.showKosWarning) then
    GuardWarner.icon:SetColor(255, 0, 0, GuardWarner.shieldOpacity)
    GuardWarner.icon:SetHidden(false)
  elseif (GetBounty() > 0 and GuardWarner.savedVariables.showBountyWarning) then
    GuardWarner.icon:SetColor(255, 255, 0, GuardWarner.shieldOpacity)
    GuardWarner.icon:SetHidden(false)
  elseif (GetBounty() == 0 and GuardWarner.savedVariables.showUpstandingWarning) then
    GuardWarner.icon:SetColor(0, 255, 0, GREEN_SHIELD_OPACITY)
    GuardWarner.icon:SetHidden(false)
  elseif (not GuardWarner.savedVariables.showUpstandingWarning) then
    GuardWarner.icon:SetHidden(true)
  else
    GuardWarner.icon:SetHidden(true)
  end
end

-- Draw bounty time text
function GuardWarner.DrawBountyTimeText()
  infamyLevel = GetInfamyLevel(GetInfamy())
  GuardWarner.UpdateTimer()
  if (infamyLevel >= INFAMY_LEVEL_NOTORIOUS and GuardWarner.savedVariables.showKosWarning and GuardWarner.savedVariables.showBountyTimer) then
    GuardWarnerGuiLabel:SetHidden(false)
    GuardWarnerGuiLabel:SetColor(255, 0, 0)
  elseif (GetBounty() > 0 and GuardWarner.savedVariables.showBountyWarning and GuardWarner.savedVariables.showBountyTimer) then
    GuardWarnerGuiLabel:SetHidden(false)
    GuardWarnerGuiLabel:SetColor(255, 255, 0)
  elseif (GetBounty() == 0) then
    GuardWarnerGuiLabel:SetHidden(true)
  end
end

-- Change the shield opacity according to the shield pulse direction
-- chaning this direction which opacity reaches its limits
function GuardWarner.StepShieldOpacity()
    -- Still going up?
    if (GuardWarner.shieldOpacity >= 1.0) then
      GuardWarner.shieldPulseDirection = -1
    end

    -- Still going down?
    if (GuardWarner.shieldOpacity <= 0.0) then
      GuardWarner.shieldPulseDirection = 1
    end

    -- Step the opacity according to direction
  if (GuardWarner.shieldPulseDirection > 0) then
    GuardWarner.shieldOpacity = GuardWarner.shieldOpacity + SHIELD_OPACITY_INCREMENT
  else
    GuardWarner.shieldOpacity = GuardWarner.shieldOpacity - SHIELD_OPACITY_INCREMENT
  end
end

-- Checks if player has a bounty and updates the bounty gold and time for display
function GuardWarner.UpdateTimer()
  local bountyTime = GetSecondsUntilBountyDecaysToZero()

  if (bountyTime ~= GuardWarner.lastTime) then
    GuardWarner.lastTime = bountyTime
    local hours = math.floor(bountyTime / 3600)
    local minutes = math.floor(bountyTime / 60 - (hours * 60))
    local seconds = math.floor(bountyTime - hours * 3600 - minutes * 60)

    local timeString = ""
    if (hours > 0) then
      timeString = string.format("%02d:%02d:%02d",hours,minutes,seconds)
    elseif (minutes > 0) then
      timeString = string.format("%02d:%02d",minutes,seconds)
    else
      timeString = string.format("%02d",seconds)
    end
    GuardWarnerGuiLabel:SetText(timeString)
    else
      GuardWarner.bountyTimeText = ""
  end
end

-- Callback to load the GuardWarner add-on.
function GuardWarner.OnLoaded(event, addOnName)
  if addOnName == GuardWarner.name then
    GuardWarner.Initialize()
    EVENT_MANAGER:UnregisterForEvent(GuardWarner.name, EVENT_ADD_ON_LOADED) 
  end
end

-- Register for load
EVENT_MANAGER:RegisterForEvent(GuardWarner.name, EVENT_ADD_ON_LOADED, GuardWarner.OnLoaded)