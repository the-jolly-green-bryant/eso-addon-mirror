-------------------------------------------------------------------------------
-- CrownAndCruxHeadstone.lua · robust teardown on party changes/disband
-- Dead group members only (not self). Overland/PvP allowed, dungeons/trials blocked.
-- Caches corpse position at death; optimized property updates.
-------------------------------------------------------------------------------
CrownAndCruxHeadstone = CrownAndCruxHeadstone or {}
local M = CrownAndCruxHeadstone

local WM, EM = GetWindowManager(), GetEventManager()

-- ===== Config =====
local ICON_PATH     = "CrownAndCrux/art/headstone.dds"
local ICON_PX       = 48
local LIFT_UNITS    = 275        -- world units (~100 units = 1 meter)
local TICK_MS       = 33

-- Distance fade
local FADE_NEAR_M        = 2.5
local FADE_FAR_M         = 6.0
local SCALE_BY_DISTANCE  = true
local MIN_SCALE          = 0.75
local MAX_SCALE          = 1.25

-- Occlusion vs player HEAD
local PLAYER_HEAD_OFFSET_UNITS = 160
local OCCLUDE_RADIUS_PX        = 110
local OCCLUDE_MIN_ALPHA        = 0.15
local OCCLUDE_RADIUS_PX2       = OCCLUDE_RADIUS_PX * OCCLUDE_RADIUS_PX

-- Micro-optim epsilons
local ALPHA_EPS   = 0.02
local SCALE_EPS   = 0.02
local ANCHOR_EPS  = 0.5   -- px

-- ===== State =====
local S = {
  win       = nil,   -- HUD root window
  cam       = nil,   -- 3D render-space control
  frag      = nil,   -- HUD fade fragment
  fragAdded = false, -- fragment currently added to scenes?
  icons     = {},    -- unitTag -> CT_TEXTURE
  dead      = {},    -- unitTag -> true
  pos       = {},    -- unitTag -> {x,y,z} at death
  sv        = nil,
  inited    = false,
  ticking   = false,
}

-- Forward declare
local OnTick

-- ===== Helpers =====
local function InPvP() return IsPlayerInAvAWorld() or IsActiveWorldBattleground() end
local function InDungeonOrTrial() return IsUnitInDungeon("player") and not InPvP() end
local function Enabled() local sv = S.sv or (CrownAndCrux and CrownAndCrux.saved); return not (sv and sv.headstonesEnabled == false) end
local function FeatureActive() return Enabled() and not InDungeonOrTrial() end
local function HaveAnyMarkers() return next(S.dead) ~= nil end

local function HideAllIcons()
  for _, c in pairs(S.icons) do
    if not c:IsHidden() then c:SetHidden(true) end
    -- bury off-screen as belt-and-suspenders
    c:ClearAnchors()
    c:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, -10000, -10000)
    c._lastAlpha, c._lastScale = nil, nil
    c._lastSX, c._lastSY = math.huge, math.huge
  end
end

local function EnsureHud()
  if S.win then return end
  local w = WM:CreateTopLevelWindow("CCHS_Win")
  w:SetAnchorFill(GuiRoot)
  w:SetMouseEnabled(false); w:SetMovable(false); w:SetClampedToScreen(true)
  w:SetDrawLayer(DL_BACKGROUND); w:SetDrawTier(DT_LOW); w:SetDrawLevel(0)
  S.frag = ZO_HUDFadeSceneFragment:New(w)
  S.win  = w
end

local function EnsureCam()
  if S.cam then return end
  local c = WM:CreateControl("CCHS_Cam", GuiRoot, CT_CONTROL)
  c:Create3DRenderSpace(); c:SetHidden(true)
  S.cam = c
end

local function AddFragmentIfNeeded()
  if S.frag and not S.fragAdded then
    HUD_SCENE:AddFragment(S.frag)
    HUD_UI_SCENE:AddFragment(S.frag)
    S.fragAdded = true
  end
end

local function RemoveFragmentIfAdded()
  if S.frag and S.fragAdded then
    HUD_SCENE:RemoveFragment(S.frag)
    HUD_UI_SCENE:RemoveFragment(S.frag)
    S.fragAdded = false
  end
end

local function GetIcon(tag)
  local name = "CCHS_Icon_"..tag
  local ctl = S.icons[tag]
  if ctl then return ctl end
  -- If a control with this name already exists (e.g., after ClearAll), reuse it
  ctl = _G[name]
  if ctl then
    S.icons[tag] = ctl
    return ctl
  end
  -- Fresh create
  ctl = WM:CreateControl(name, S.win or GuiRoot, CT_TEXTURE)
  ctl:SetTexture(ICON_PATH)
  ctl:SetDimensions(ICON_PX, ICON_PX)
  ctl:SetDrawLayer(DL_OVERLAY)
  ctl:SetHidden(true)
  ctl:SetPixelRoundingEnabled(false)
  ctl._lastAlpha, ctl._lastScale = nil, nil
  ctl._lastSX, ctl._lastSY = math.huge, math.huge
  S.icons[tag] = ctl
  return ctl
end

-- ===== projection + fades/scale =====
local function Place(ctl, x, y, z, liftUnits,
                     camX,camY,camZ, fX,fY,fZ, rX,rY,rZ, uX,uY,uZ, uiW,uiH,
                     pWX,pWY,pWZ)
  local wX, wY, wZ = x, y + (liftUnits or 0), z

  local dXc, dYc, dZc = wX - camX, wY - camY, wZ - camZ
  local depth = dXc*fX + dYc*fY + dZc*fZ
  if depth <= 0 then
    if not ctl:IsHidden() then ctl:SetHidden(true) end
    return
  end

  local iX = dXc*rX + dYc*rY + dZc*rZ
  local iY = dXc*uX + dYc*uY + dZc*uZ
  local wW, wH = GetWorldDimensionsOfViewFrustumAtDepth(depth)
  local sX = iX * (uiW / wW)
  local sY = -iY * (uiH / wH)

  local hWX, hWY, hWZ = pWX, pWY + PLAYER_HEAD_OFFSET_UNITS, pWZ
  local dXp, dYp, dZp = wX - hWX, wY - hWY, wZ - hWZ
  local distM = math.sqrt(dXp*dXp + dYp*dYp + dZp*dZp) / 100

  local alphaDist
  if distM <= FADE_NEAR_M then alphaDist = 0
  elseif distM >= FADE_FAR_M then alphaDist = 1
  else alphaDist = (distM - FADE_NEAR_M) / (FADE_FAR_M - FADE_NEAR_M) end
  if alphaDist <= 0 then if not ctl:IsHidden() then ctl:SetHidden(true) end return end

  local occludeAlpha = 1
  local pDX, pDY, pDZ = hWX - camX, hWY - camY, hWZ - camZ
  local pDepth = pDX*fX + pDY*fY + pDZ*fZ
  if pDepth > 0 and pDepth < depth then
    local pXr = pDX*rX + pDY*rY + pDZ*rZ
    local pYr = pDX*uX + pDY*uY + pDZ*uZ
    local pWW, pWH = GetWorldDimensionsOfViewFrustumAtDepth(pDepth)
    local pSX = pXr * (uiW / pWW)
    local pSY = -pYr * (uiH / pWH)
    local dx, dy = sX - pSX, sY - pSY
    local distPx2 = dx*dx + dy*dy
    if distPx2 < OCCLUDE_RADIUS_PX2 then
      local distPx = math.sqrt(distPx2)
      local t = math.max(0, distPx / OCCLUDE_RADIUS_PX)
      occludeAlpha = OCCLUDE_MIN_ALPHA + (1 - OCCLUDE_MIN_ALPHA) * t
    end
  end

  local finalAlpha = (alphaDist < occludeAlpha) and alphaDist or occludeAlpha
  if not ctl._lastAlpha or math.abs(finalAlpha - ctl._lastAlpha) > ALPHA_EPS then
    ctl:SetAlpha(finalAlpha); ctl._lastAlpha = finalAlpha
  end

  local scale = 1
  if SCALE_BY_DISTANCE then
    local t = math.min(1, math.max(0, (distM - FADE_NEAR_M) / (FADE_FAR_M - FADE_NEAR_M)))
    scale = MIN_SCALE + (MAX_SCALE - MIN_SCALE) * t
    if (not ctl._lastScale) or math.abs(scale - ctl._lastScale) > SCALE_EPS then
      ctl:SetScale(scale); ctl._lastScale = scale
    end
  else
    if ctl._lastScale ~= 1 then ctl:SetScale(1); ctl._lastScale = 1 end
  end

  if math.abs(sX - ctl._lastSX) > ANCHOR_EPS or math.abs(sY - ctl._lastSY) > ANCHOR_EPS then
    ctl:ClearAnchors()
    ctl:SetAnchor(CENTER, S.win or GuiRoot, CENTER, sX, sY)
    ctl._lastSX, ctl._lastSY = sX, sY
  end

  if ctl:IsHidden() then ctl:SetHidden(false) end
end

-- ===== ticker control =====
local function StopTicking()
  if S.ticking then EM:UnregisterForUpdate("CCHS_Tick"); S.ticking = false end
end

local function StartTicking()
  if not S.ticking then
    AddFragmentIfNeeded()
    if S.win then S.win:SetHidden(false) end
    if S.cam then S.cam:SetHidden(false) end
    EM:RegisterForUpdate("CCHS_Tick", TICK_MS, OnTick)
    S.ticking = true
  end
end

local function ClearAll()
  StopTicking()
  HideAllIcons()
  if S.cam then S.cam:SetHidden(true) end
  if S.win then S.win:SetHidden(true) end
  RemoveFragmentIfAdded()
  -- IMPORTANT: do NOT reset S.icons here; we reuse existing controls
  ZO_ClearTable(S.dead)
  ZO_ClearTable(S.pos)
end

-- ===== group-state re-eval =====
local function ReevaluateGroupState()
  -- If solo / not grouped OR feature inactive → nuke
  if not IsUnitGrouped("player") or GetGroupSize() <= 1 or not FeatureActive() then
    ClearAll()
    return
  end

  -- Rebuild dead list from current party; clears if none
  ZO_ClearTable(S.dead); ZO_ClearTable(S.pos)
  for i = 1, GetGroupSize() do
    local tag = ("group%d"):format(i)
    if DoesUnitExist(tag) and not AreUnitsEqual("player", tag) and IsUnitDead(tag) then
      S.dead[tag] = true
      local _, x, y, z = GetUnitRawWorldPosition(tag)
      if (x ~= 0 or y ~= 0 or z ~= 0) then
        S.pos[tag] = { x = x, y = y, z = z }
      else
        S.pos[tag] = { x = 0, y = 0, z = 0 }
      end
    end
  end

  if HaveAnyMarkers() then StartTicking() else ClearAll() end
end

-- ===== events =====
local function OnDeath(_, unitTag, isDead)
  if not unitTag or not unitTag:match("^group%d+$") then return end
  if AreUnitsEqual("player", unitTag) then return end
  if not FeatureActive() then return end

  if isDead then
    local _, x, y, z = GetUnitRawWorldPosition(unitTag)
    if (x ~= 0 or y ~= 0 or z ~= 0) then S.pos[unitTag] = { x = x, y = y, z = z }
    else S.pos[unitTag] = S.pos[unitTag] or { x = 0, y = 0, z = 0 } end
    S.dead[unitTag] = true
    StartTicking()
  else
    S.dead[unitTag] = nil; S.pos[unitTag] = nil
    local ctl = GetIcon(unitTag)
    if ctl and not ctl:IsHidden() then ctl:SetHidden(true) end
    if not HaveAnyMarkers() then ClearAll() end
  end
end

local function OnGroupLeft(_, unitTag)
  -- If we’re no longer grouped (or now solo), nuke immediately
  if not IsUnitGrouped("player") or GetGroupSize() <= 1 then ClearAll(); return end

  if unitTag then
    local ctl = GetIcon(unitTag)
    if ctl and not ctl:IsHidden() then ctl:SetHidden(true) end
    S.dead[unitTag] = nil; S.pos[unitTag] = nil
  end

  -- Re-evaluate after a tiny delay to let tags settle
  zo_callLater(ReevaluateGroupState, 50)
end

local function OnGroupJoined(_, _displayName)
  zo_callLater(ReevaluateGroupState, 75)
end
local function OnGroupConnected(_, _unitTag)
  zo_callLater(ReevaluateGroupState, 75)
end
local function OnGroupUpdated(_, _)
  -- Fires on disband/you leave and general size transitions
  zo_callLater(ReevaluateGroupState, 25)
end

-- Also clear on player deactivation (loading screen / zone tear-down)
local function OnPlayerDeactivated()
  ClearAll()
end

-- ===== tick (local assignment) =====
OnTick = function()
  if not IsUnitGrouped("player") or GetGroupSize() <= 1 or not FeatureActive() then
    ClearAll(); return
  end
  if not HaveAnyMarkers() then
    ClearAll(); return
  end

  Set3DRenderSpaceToCurrentCamera(S.cam:GetName())
  local camX,camY,camZ = GuiRender3DPositionToWorldPosition(S.cam:Get3DRenderSpaceOrigin())
  local fX,fY,fZ = S.cam:Get3DRenderSpaceForward()
  local rX,rY,rZ = S.cam:Get3DRenderSpaceRight()
  local uX,uY,uZ = S.cam:Get3DRenderSpaceUp()
  local uiW, uiH = GuiRoot:GetDimensions()
  local _, pWX, pWY, pWZ = GetUnitRawWorldPosition("player")

  for tag in pairs(S.dead) do
    local anchor = S.pos[tag]
    if not anchor or (anchor.x == 0 and anchor.y == 0 and anchor.z == 0) then
      local _, cx, cy, cz = GetUnitRawWorldPosition(tag)
      if (cx ~= 0 or cy ~= 0 or cz ~= 0) then
        S.pos[tag] = { x = cx, y = cy, z = cz }
        anchor = S.pos[tag]
      end
    end

    if anchor and (anchor.x ~= 0 or anchor.y ~= 0 or anchor.z ~= 0) then
      local ctl = GetIcon(tag)
      Place(ctl, anchor.x, anchor.y, anchor.z, LIFT_UNITS,
            camX,camY,camZ, fX,fY,fZ, rX,rY,rZ, uX,uY,uZ, uiW,uiH,
            pWX,pWY,pWZ)
    else
      local ctl = GetIcon(tag)
      if ctl and not ctl:IsHidden() then ctl:SetHidden(true) end
    end
  end
end

-- ===== public API =====
function M.BindSaved(sv) S.sv = sv end
function M.SetEnabled(v)
  if S.sv then S.sv.headstonesEnabled = not not v end
  if v then ReevaluateGroupState() else ClearAll() end
end

-- ===== lifecycle =====
local function OnActivated()
  EM:UnregisterForEvent("CCHS_ACT", EVENT_PLAYER_ACTIVATED)
  EnsureHud(); EnsureCam()

  EM:RegisterForEvent("CCHS_Death", EVENT_UNIT_DEATH_STATE_CHANGED, OnDeath)
  EM:AddFilterForEvent("CCHS_Death", EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")

  -- IMPORTANT: do NOT filter LEFT by unit tag; we want disband/you leave too
  EM:RegisterForEvent("CCHS_Left", EVENT_GROUP_MEMBER_LEFT, OnGroupLeft)

  EM:RegisterForEvent("CCHS_Joined",    EVENT_GROUP_MEMBER_JOINED,           OnGroupJoined)
  EM:RegisterForEvent("CCHS_Connected",  EVENT_GROUP_MEMBER_CONNECTED_STATUS, OnGroupConnected)
  EM:RegisterForEvent("CCHS_GroupUpd",   EVENT_GROUP_UPDATE,                  OnGroupUpdated)

  EM:RegisterForEvent("CCHS_PlayerDeact", EVENT_PLAYER_DEACTIVATED, OnPlayerDeactivated)

  -- Initial state after load/zone
  zo_callLater(ReevaluateGroupState, 200)
end

local function OnLoaded(_, _)
  if S.inited then return end
  S.inited = true
  if CrownAndCrux and CrownAndCrux.saved then S.sv = CrownAndCrux.saved end
  EM:UnregisterForEvent("CCHS_LOAD", EVENT_ADD_ON_LOADED)
  EM:RegisterForEvent("CCHS_ACT", EVENT_PLAYER_ACTIVATED, OnActivated)
end

EM:RegisterForEvent("CCHS_LOAD", EVENT_ADD_ON_LOADED, OnLoaded)
