-- DarkConvergenceTimer.lua (API 101046)
-- Tracks Dark Convergence via YOUR damage events (robust vs bar swaps).
-- Persists cooldown end time across /reloadui & zoning using wall-clock timestamps.
-- UI: In Combat / Standby / Not Ready + optional sound. LHAS settings: enable, sound toggle, position sliders, reset.

DarkConvergenceTimer = DarkConvergenceTimer or {}
local EM = GetEventManager()

-- ======================= SavedVars =======================
local SV_NAME         = "DarkConvergenceTimerSV"
local SV_VERSION_ROOT = 1
local defaults = {
  enabled       = true,
  soundEnabled  = true,
  pos           = { x = -400, y = -220 },
  lastEndUtc    = 0,   -- wall-clock (GetTimeStamp) when cooldown ends; 0 = none
}
local SV = nil

-- ======================= Tuning ==========================
local UI_SCALE              = 1.0
local DEFAULT_COOLDOWN_SEC  = 22.0
local UPDATE_MS             = 66

-- If I later learn exact ability IDs, add them here to skip name matching.
local TRACKED_IDS = {
  -- [damageAbilityId] = true,
}

-- ======================= UI colors/sounds =================
local COL_COMBAT = {0.00, 1.00, 0.00, 1.0}
local COL_STANDBY= {1.00, 0.90, 0.10, 1.0}
local COL_NOTRDY = {1.00, 0.00, 0.00, 1.0}
local READY_SOUND = SOUNDS and (SOUNDS.ABILITY_COMPANION_ULTIMATE_READY or SOUNDS.SKILL_POINT_GAINED)

-- ======================= State ===========================
local S = {
  readyAtSec            = 0,               -- session time (GetFrameTimeSeconds); 0 = ready
  ticking               = false,
  procGuardUntilSec     = 0,
  lastShownText         = nil,
  lastStatusText        = nil,
  lastStatusColor       = nil,
  readySoundGuardUntil  = 0,
  frag                  = nil,             -- HUD fragment handle
}

local function nowSec() return GetFrameTimeSeconds() end
local function nowUtc() return GetTimeStamp() end

-- ======================= Helpers =========================
local function ApplyPosition()
  if DCT_UI then
    DCT_UI:ClearAnchors()
    DCT_UI:SetAnchor(CENTER, GuiRoot, CENTER, SV.pos.x or 0, SV.pos.y or 0)
  end
end

local function isTracked(abilityId, abilityName)
  if abilityId and TRACKED_IDS[abilityId] then return true end
  if abilityName and abilityName ~= "" then
    return zo_strlower(abilityName):find("dark convergence", 1, true) ~= nil
  end
  return false
end

local function PlayReadyPing()
  local t = nowSec()
  if t >= (S.readySoundGuardUntil or 0) then
    if READY_SOUND and (SV.soundEnabled ~= false) then
      PlaySound(READY_SOUND)
    end
    S.readySoundGuardUntil = t + 0.75
  end
end

local function setTimerTextOnce(text)
  if not DCT_UITimer then return end
  if S.lastShownText ~= text then
    DCT_UITimer:SetText(text)
    S.lastShownText = text
  end
end

local function setStatus(text, col)
  if not DCT_UIStatus then return end
  if S.lastStatusText ~= text then
    DCT_UIStatus:SetText(text)
    S.lastStatusText = text
  end
  local c = S.lastStatusColor
  if not c or c[1] ~= col[1] or c[2] ~= col[2] or c[3] ~= col[3] or (c[4] or 1) ~= (col[4] or 1) then
    DCT_UIStatus:SetColor(col[1], col[2], col[3], col[4] or 1)
    S.lastStatusColor = { col[1], col[2], col[3], col[4] or 1 }
  end
end

local function refreshStatusLine()
  if not SV.enabled then return end
  if S.readyAtSec > 0 then
    setStatus("Not Ready", COL_NOTRDY)
  else
    if IsUnitInCombat("player") then
      setStatus("In Combat", COL_COMBAT)
    else
      setStatus("Standby", COL_STANDBY)
    end
  end
end

local function Sleep()
  if S.ticking then
    EM:UnregisterForUpdate("DCT_Tick")
    S.ticking = false
  end
end

local function Wake()
  if S.ticking or not SV.enabled then return end
  EM:RegisterForUpdate("DCT_Tick", UPDATE_MS, function()
    if not SV.enabled then Sleep(); return end
    refreshStatusLine()

    if S.readyAtSec <= 0 then
      setTimerTextOnce("0.0")
      Sleep()
      return
    end

    local remain = S.readyAtSec - nowSec()
    if remain <= 0.05 then
      S.readyAtSec = 0
      SV.lastEndUtc = 0
      local inCombat = IsUnitInCombat("player")
      refreshStatusLine()
      if inCombat then PlayReadyPing() end
      setTimerTextOnce("0.0")
      Sleep()
      return
    end

    -- Visual nicety: round up while >= 10s so it doesn't "start at 21".
    if remain >= 10 then
      setTimerTextOnce(string.format("%d", zo_ceil(remain)))
    else
      setTimerTextOnce(string.format("%.1f", remain))
    end
  end)
  S.ticking = true
end

local function SetEnabled(v)
  SV.enabled = not not v
  if S.frag then
    S.frag:SetHiddenForReason("DCT_DISABLED", not SV.enabled)
  end
  if not SV.enabled then
    Sleep()
  else
    if S.readyAtSec <= 0 and DCT_UIStatus and DCT_UITimer then
      if IsUnitInCombat("player") then
        DCT_UIStatus:SetText("In Combat");   DCT_UIStatus:SetColor(unpack(COL_COMBAT))
      else
        DCT_UIStatus:SetText("Standby");     DCT_UIStatus:SetColor(unpack(COL_STANDBY))
      end
      DCT_UITimer:SetText("0.0"); S.lastShownText = "0.0"
    end
  end
end

-- Always start a fresh cooldown at the default length.
local function StartCooldownNow()
  local cd = DEFAULT_COOLDOWN_SEC
  local t  = nowSec()
  S.readyAtSec = t + cd
  SV.lastEndUtc = nowUtc() + cd
  refreshStatusLine()
  Wake()
end

-- Seed from wall-clock WITHOUT modifying any stored "cooldown length".
local function SeedFromWallClock()
  if not SV.lastEndUtc or SV.lastEndUtc <= 0 then return false end
  local remain = SV.lastEndUtc - nowUtc()
  if remain > 0 and remain <= 120 then
    S.readyAtSec = nowSec() + remain
    refreshStatusLine()
    Wake()
    return true
  end
  SV.lastEndUtc = 0
  return false
end

local function HandleProc()
  if not SV.enabled then return end
  local t = nowSec()
  if t < S.procGuardUntilSec then return end
  S.procGuardUntilSec = t + 1.0  -- guard against multi-target spam
  StartCooldownNow()
end

-- ======================= Events ==========================
-- Trigger only when YOU deal positive damage with a DC-named ability.
local function OnCombatEvent(_, _result, _isErr, abilityName, _graphic, _slotType,
                             _sourceName, sourceType, _targetName, targetType, hitValue, _powerType,
                             _damageType, _log, _sourceUnitId, _targetUnitId, abilityId, _overflow)
  if not SV.enabled then return end
  if sourceType ~= COMBAT_UNIT_TYPE_PLAYER then return end
  if not isTracked(abilityId, abilityName) then return end
  if (hitValue or 0) <= 0 then return end
  if targetType == COMBAT_UNIT_TYPE_PLAYER then return end
  HandleProc()
end

local function OnCombatState(_, inCombat)
  if not SV.enabled then return end
  refreshStatusLine()
  if inCombat and S.readyAtSec <= 0 then
    PlayReadyPing()
  end
end

-- ======================= UI init =========================
local function SetupUI()
  if not (DCT_UI and DCT_UIHeader and DCT_UIStatus and DCT_UITimer) then
    d("[DCT] ERROR: XML controls missing (DCT_UI / Header / Status / Timer).")
    return
  end
  DCT_UI:SetScale(UI_SCALE)
  DCT_UIHeader:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
  DCT_UIStatus:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
  DCT_UITimer:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
  ApplyPosition()

  if not S.frag then
    S.frag = ZO_HUDFadeSceneFragment:New(DCT_UI)
    HUD_SCENE:AddFragment(S.frag)
    HUD_UI_SCENE:AddFragment(S.frag)
  end
  S.frag:SetHiddenForReason("DCT_DISABLED", not SV.enabled)
end

-- ======================= LHAS Settings ===================
local function CreateSettings()
  local LHAS = LibHarvensAddonSettings
  if not LHAS then
    d("[DCT] LibHarvensAddonSettings not found. Settings panel disabled.")
    return
  end

  local opts = {
    allowDefaults    = true,
    allowRefresh     = true,
    defaultsFunction = function()
      SV.enabled      = defaults.enabled
      SV.soundEnabled = defaults.soundEnabled
      SV.pos.x        = defaults.pos.x
      SV.pos.y        = defaults.pos.y
      SV.lastEndUtc   = 0
      ApplyPosition()
      SetEnabled(SV.enabled)
    end,
  }

  local panel = LHAS:AddAddon("Dark Convergence Timer", opts)
  if not panel then return end

  -- Header note
  panel:AddSetting({
    type  = LHAS.ST_SECTION,
    label = "These settings are per-character",
  })

  panel:AddSetting({
    type        = LHAS.ST_CHECKBOX,
    label       = "Enable timer",
    tooltip     = "Show or hide the Dark Convergence cooldown timer UI.",
    default     = defaults.enabled,
    setFunction = function(state) SetEnabled(state) end,
    getFunction = function() return SV.enabled end,
  })

  panel:AddSetting({
    type  = LHAS.ST_SECTION,
    label = "Audio",
  })
  panel:AddSetting({
    type        = LHAS.ST_CHECKBOX,
    label       = "Play ready sound",
    tooltip     = "If enabled, a sound plays when the display switches to In Combat while no cooldown is active.",
    default     = defaults.soundEnabled,
    setFunction = function(state) SV.soundEnabled = not not state end,
    getFunction = function() return SV.soundEnabled end,
  })

  panel:AddSetting({
    type  = LHAS.ST_SECTION,
    label = "Position",
  })
  panel:AddSetting({
    type        = LHAS.ST_SLIDER,
    label       = "Horizontal offset",
    tooltip     = "Move the timer left/right on the screen.",
    default     = defaults.pos.x,
    min         = -960, max = 960, step = 10,
    format      = "%d",
    setFunction = function(val) SV.pos.x = val; ApplyPosition() end,
    getFunction = function() return SV.pos.x end,
  })
  panel:AddSetting({
    type        = LHAS.ST_SLIDER,
    label       = "Vertical offset",
    tooltip     = "Move the timer up/down on the screen.",
    default     = defaults.pos.y,
    min         = -540, max = 540, step = 10,
    format      = "%d",
    setFunction = function(val) SV.pos.y = val; ApplyPosition() end,
    getFunction = function() return SV.pos.y end,
  })
  panel:AddSetting({
    type         = LHAS.ST_BUTTON,
    label        = "Reset position",
    buttonText   = "Reset to default",
    tooltip      = "Return the timer to its default location.",
    clickHandler = function(_control)
      SV.pos.x = defaults.pos.x
      SV.pos.y = defaults.pos.y
      ApplyPosition()
    end,
  })
end

-- ======================= Lifecycle =======================
local function OnActivated()
  EM:UnregisterForEvent("DCT_Activated", EVENT_PLAYER_ACTIVATED)

  SetupUI()

  -- Your DC damage events only (robust to bar swaps)
  EM:RegisterForEvent("DCT_Combat", EVENT_COMBAT_EVENT, OnCombatEvent)
  EM:AddFilterForEvent("DCT_Combat", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

  EM:RegisterForEvent("DCT_CombatState", EVENT_PLAYER_COMBAT_STATE, OnCombatState)

  -- Seed FIRST; if not cooling, paint initial state
  local seeded = false
  if SV.enabled then
    seeded = SeedFromWallClock()
  end

  if SV.enabled and not seeded then
    if IsUnitInCombat("player") then
      setStatus("In Combat", COL_COMBAT)
    else
      setStatus("Standby", COL_STANDBY)
    end
    setTimerTextOnce("0.0")
  end
end

local function OnLoaded(_, addonName)
  if addonName ~= "DarkConvergenceTimer" then return end
  SV = ZO_SavedVars:NewCharacterIdSettings(SV_NAME, SV_VERSION_ROOT, nil, defaults)
  CreateSettings()
  EM:UnregisterForEvent("DCT_Loaded", EVENT_ADD_ON_LOADED)
  EM:RegisterForEvent("DCT_Activated", EVENT_PLAYER_ACTIVATED, OnActivated)
end

EM:RegisterForEvent("DCT_Loaded", EVENT_ADD_ON_LOADED, OnLoaded)
