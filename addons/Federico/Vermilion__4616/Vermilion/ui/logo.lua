Vermilion = Vermilion or {}
Vermilion.Logo = {}
local M = Vermilion.Logo

local api = Vermilion.zenimax.api
local zc  = Vermilion.zenimax.constants
local GetUIMousePosition = api.GetUIMousePosition
local math_abs           = math.abs
local TOPLEFT = zc.TOPLEFT
local CENTER  = zc.CENTER
local GuiRoot = zc.GuiRoot

local ANIMATION_MANAGER          = ANIMATION_MANAGER
local ANIMATION_ALPHA            = ANIMATION_ALPHA
local ANIMATION_PLAYBACK_PING_PONG = ANIMATION_PLAYBACK_PING_PONG
local LOOP_INDEFINITELY          = LOOP_INDEFINITELY
local TEX_BLEND_MODE_ADD         = TEX_BLEND_MODE_ADD

local log = Vermilion.Log.for_module("logo")

local IDLE_ALPHA     = 0.40
local HOVER_ALPHA    = 1.00
local HOVER_SCALE    = 1.06
local DRAG_THRESHOLD = 5
local GLOW_MIN       = 0.45
local GLOW_MAX       = 1.00
local GLOW_PERIOD_MS = 650

local controls = {}
local enabled  = true
local allowed  = false
local down_x, down_y = 0, 0

local function reset_hover()
  if controls.glow_timeline then controls.glow_timeline:Stop() end
  if controls.glow then controls.glow:SetHidden(true) end
  controls.icon:SetScale(1.0)
  controls.icon:SetAlpha(IDLE_ALPHA)
end

local function refresh()
  local show = enabled and allowed
  controls.window:SetHidden(not show)
  if not show then reset_hover() end
end

function M.sync(is_allowed)
  allowed = is_allowed
  if enabled and allowed then controls.icon:SetAlpha(IDLE_ALPHA) end
  refresh()
end

function M.is_enabled() return enabled end

function M.set_enabled(e)
  enabled = e
  local sv = Vermilion.SavedVars
  if sv then sv.logo = sv.logo or {}; sv.logo.enabled = e end
  log:info("enabled ->", e)
  refresh()
end

function M.on_enter()
  controls.icon:SetAlpha(HOVER_ALPHA)
  controls.icon:SetScale(HOVER_SCALE)
  controls.glow:SetHidden(false)
  controls.glow_timeline:PlayFromStart()
end

function M.on_exit()
  controls.icon:SetAlpha(IDLE_ALPHA)
  controls.icon:SetScale(1.0)
  controls.glow_timeline:Stop()
  controls.glow:SetHidden(true)
end

function M.on_mouse_down()
  down_x, down_y = GetUIMousePosition()
end

function M.on_mouse_up(up_inside)
  if not up_inside then return end
  local x, y = GetUIMousePosition()
  if (math_abs(x - down_x) + math_abs(y - down_y)) > DRAG_THRESHOLD then
    return
  end
  Vermilion.Graph.toggle()
end

function M.on_move_stop()
  local sv = Vermilion.SavedVars
  if not sv or not controls.window then return end
  sv.logo = sv.logo or {}
  sv.logo.x = controls.window:GetLeft()
  sv.logo.y = controls.window:GetTop()
end

function M.init()
  controls.window = VermilionLogo
  controls.icon   = VermilionLogoIcon
  controls.glow   = VermilionLogoGlow
  controls.glow:SetBlendMode(TEX_BLEND_MODE_ADD)

  local tl = ANIMATION_MANAGER:CreateTimeline()
  local a  = tl:InsertAnimation(ANIMATION_ALPHA, controls.glow)
  a:SetAlphaValues(GLOW_MIN, GLOW_MAX)
  a:SetDuration(GLOW_PERIOD_MS)
  tl:SetPlaybackType(ANIMATION_PLAYBACK_PING_PONG, LOOP_INDEFINITELY)
  controls.glow_timeline = tl

  local sv = Vermilion.SavedVars
  sv.logo = sv.logo or {}
  if sv.logo.enabled == nil then sv.logo.enabled = true end
  enabled = sv.logo.enabled

  controls.window:ClearAnchors()
  if sv.logo.x and sv.logo.y then
    controls.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.logo.x, sv.logo.y)
  else
    controls.window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
  end

  controls.icon:SetAlpha(IDLE_ALPHA)
  controls.window:SetHidden(true)

  log:info("init: enabled=", enabled)
end
