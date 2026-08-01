local CombatTracker = CombatTracker
local savedVars
local frame, label, fragment

local strformat = string.format
local strgsub = string.gsub
local rep = string.rep
local floor = math.floor
local EM = EVENT_MANAGER
local GetGameTimeMilliseconds = GetGameTimeMilliseconds

local startTime = 0
local endTime = nil


local function formatTime(ms, precision)
  local s = floor(ms / 1000)
  local h = floor(s / 3600)
  local m = floor((s % 3600) / 60)
  s = s % 60

  local result
  if h > 0 then
    result = strformat("%d:%02d:%02d", h, m, s)
  else
    result = strformat("%d:%02d", m, s)
  end

  if precision == 0 then
    return result
  end

  local frac = floor(ms % 1000 / 10 ^ (3 - precision))
  local fill = rep("0", precision - #tostring(frac))
  return strformat("%s.%s%s", result, fill, frac)
end

function CombatTracker.applyFont()
  local fontString = strformat("%s|%s|%s", savedVars.fontFace, savedVars.fontSize, savedVars.fontStyle)
  label:SetFont(fontString)
end

function CombatTracker.applyColor(inCombat)
  if inCombat == nil then
    inCombat = CombatTracker.inCombat
  end
  if inCombat then
    label:SetColor(unpack(savedVars.inCombatColor))
  else
    label:SetColor(unpack(savedVars.outOfCombatColor))
  end
end

function CombatTracker.updateTimer(format, start, finish)
  local duration = (finish or GetGameTimeMilliseconds()) - start
  local timeString = formatTime(duration, savedVars.timePrecision)
  label:SetText(strgsub(format, "%%s", timeString))
end

function CombatTracker.refreshState()
  if not savedVars.enabled then return end

  if CombatTracker.inMenu then
    EM:UnregisterForUpdate("CombatTrackerUpdate")
    label:SetText("Combat Tracker")
    return
  end

  if savedVars.stopOnBossDeath and CombatTracker.isBossDead then -- savedVars.showTime
    EM:UnregisterForUpdate("CombatTrackerUpdate")
  end

  if CombatTracker.inCombat then
    if savedVars.showTime and startTime ~= 0 then
      if not CombatTracker.isBossDead then
        EM:RegisterForUpdate("CombatTrackerUpdate", savedVars.updateInterval, function() CombatTracker.updateTimer(savedVars.inCombatFormat, startTime, endTime) end)
      end
      CombatTracker.updateTimer(savedVars.inCombatFormat, startTime, endTime)
    else
      label:SetText(savedVars.inCombatText)
    end
  else
    EM:UnregisterForUpdate("CombatTrackerUpdate")
    if savedVars.showTime and startTime ~= 0 then
      CombatTracker.updateTimer(savedVars.outOfCombatFormat, startTime, endTime)
    elseif not savedVars.showTime then
      label:SetText(savedVars.outOfCombatText)
    else
      CombatTracker.updateTimer(savedVars.outOfCombatFormat, 0, 0)
    end
  end
end

local function onPlayerCombatState(_, inCombat)
  CombatTracker.inCombat = inCombat
  if inCombat then
    CombatTracker.isBossDead = false
    startTime = GetGameTimeMilliseconds()
    endTime = nil
  else
    if not endTime then
      endTime = GetGameTimeMilliseconds()
    end
  end
  fragment:Refresh()
  CombatTracker.applyColor()
  CombatTracker.refreshState()
end

local function onUnitDeathStateChanged(_, unitTag, isDead)
  if string.sub(unitTag, 1, 4) == "boss" and isDead then
    if not savedVars.stopOnBossDeath or CombatTracker.isBossDead then
      return
    end

    local numBosses = 0
    local numDead = 0
    for i = 1, MAX_BOSSES do
      if DoesUnitExist("boss" .. i) then
        numBosses = numBosses + 1
        if IsUnitDead("boss" .. i) then
          numDead = numDead + 1
        end
      end
    end

    if numBosses == numDead then -- numBosses > 0
      CombatTracker.isBossDead = true
      endTime = GetGameTimeMilliseconds()
      CombatTracker.refreshState()
    end
    return
  end
  -- if unitTag == "player" then
end

local anchorPoint = {
  [TEXT_ALIGN_LEFT] = {
    [TEXT_ALIGN_TOP] = TOPLEFT,
    [TEXT_ALIGN_CENTER] = LEFT,
    [TEXT_ALIGN_BOTTOM] = BOTTOMLEFT,
  },
  [TEXT_ALIGN_CENTER] = {
    [TEXT_ALIGN_TOP] = TOP,
    [TEXT_ALIGN_CENTER] = CENTER,
    [TEXT_ALIGN_BOTTOM] = BOTTOM,
  },
  [TEXT_ALIGN_RIGHT] = {
    [TEXT_ALIGN_TOP] = TOPRIGHT,
    [TEXT_ALIGN_CENTER] = RIGHT,
    [TEXT_ALIGN_BOTTOM] = BOTTOMRIGHT,
  },
}

function CombatTracker.restorePosition()
  local h = savedVars.horizontalAlignment
  local v = savedVars.verticalAlignment
  local x, y = frame:GetCenter()

  if h == TEXT_ALIGN_LEFT then x = frame:GetLeft()
  elseif h == TEXT_ALIGN_RIGHT then x = frame:GetRight() end
  if v == TEXT_ALIGN_TOP then y = frame:GetTop()
  elseif v == TEXT_ALIGN_BOTTOM then y = frame:GetBottom() end

  savedVars.x = x
  savedVars.y = y
  frame:ClearAnchors()
  frame:SetAnchor(anchorPoint[h][v], GuiRoot, TOPLEFT, x, y)
end

function CombatTracker.setupUI()
  savedVars = CombatTracker.savedVars
  CombatTracker.inMenu = false
  CombatTracker.inCombat = IsUnitInCombat("player")
  CombatTracker.isBossDead = false

  frame = CombatTrackerFrame
  frame:ClearAnchors()
  frame:SetAnchor(anchorPoint[savedVars.horizontalAlignment][savedVars.verticalAlignment], GuiRoot, TOPLEFT, savedVars.x, savedVars.y)
  frame:SetMovable(not savedVars.locked)
  frame:SetMouseEnabled(not savedVars.locked)
  frame:SetHandler("OnMoveStop", CombatTracker.restorePosition)

  label = CombatTrackerFrameLabel
  label:SetHorizontalAlignment(savedVars.horizontalAlignment)
  label:SetVerticalAlignment(savedVars.verticalAlignment)

  fragment = ZO_SimpleSceneFragment:New(frame)
  fragment:SetConditional(function()
    return savedVars.enabled and (IsUnitInCombat("player") or savedVars.keep)
  end)
  HUD_SCENE:AddFragment(fragment)
  HUD_UI_SCENE:AddFragment(fragment)

  CombatTracker.applyFont()
  CombatTracker.applyColor()
  CombatTracker.refreshState()

  EM:RegisterForEvent(CombatTracker.name, EVENT_PLAYER_COMBAT_STATE, onPlayerCombatState)
  EM:RegisterForEvent(CombatTracker.name, EVENT_UNIT_DEATH_STATE_CHANGED, onUnitDeathStateChanged)
end