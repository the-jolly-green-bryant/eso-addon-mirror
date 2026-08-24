Verdant = Verdant or {}
Verdant.Visibility = {}
local M = Verdant.Visibility

local Scene = Verdant.zenimax.scene
local SCENE_SHOWN = Scene.SCENE_SHOWN
local log = Verdant.Log.for_module("visibility")
local in_hud = true
local user_visible = { bar = false, graph = false }
local bar_enabled = true
local restore = {}
local AUX_WINDOWS = { "VerdantSettingsPanel", "VerdantLibrary", "VerdantAssignPanel" }


local function apply()
  if VerdantBarWindow then
    VerdantBarWindow:SetHidden(not (in_hud and user_visible.bar and bar_enabled))
  end
  if VerdantGraphWindow then
    VerdantGraphWindow:SetHidden(not (in_hud and user_visible.graph))
  end
  if VerdantGraphWindowBarBtn then
    VerdantGraphWindowBarBtn:SetHidden(not bar_enabled)
  end
  for _, name in ipairs(AUX_WINDOWS) do
    local win = _G[name]
    if win then
      if in_hud then
        if restore[name] then
          win:SetHidden(false)
          restore[name] = nil
        end
      elseif not win:IsHidden() then
        restore[name] = true
        win:SetHidden(true)
      end
    end
  end
  if Verdant.Logo then
    Verdant.Logo.sync(in_hud and not user_visible.graph)
  end
end

local function persist()
  local sv = Verdant.SavedVars
  if not sv then return end
  sv.bar      = sv.bar      or {} ; sv.bar.visible      = user_visible.bar
  sv.bar.enabled = bar_enabled
  sv.temporal = sv.temporal or {} ; sv.temporal.visible = user_visible.graph
end

function M.set(key, visible)
  if key == "bar" and visible and not bar_enabled then return end
  if user_visible[key] == visible then return end
  log:info("set", key, "->", visible and "visible" or "hidden")
  user_visible[key] = visible
  apply()
  persist()
end

function M.get(key) return user_visible[key] or false end

function M.master_toggle()
  if user_visible.bar or user_visible.graph then
    log:info("master_toggle: hiding all")
    user_visible.bar    = false
    user_visible.graph  = false
  else
    if bar_enabled then
      log:info("master_toggle: showing bar")
      user_visible.bar = true
    else
      log:info("master_toggle: bars disabled, showing graph")
      user_visible.graph = true
    end
  end
  apply()
  persist()
end

function M.set_bar_enabled(enabled)
  if bar_enabled == enabled then return end
  log:info("bar_enabled ->", enabled and "on" or "off")
  bar_enabled = enabled
  if enabled then user_visible.bar = true end
  apply()
  persist()
end

function M.is_bar_enabled() return bar_enabled end

function M.init()
  local sv = Verdant.SavedVars
  if sv then
    user_visible.bar   = (sv.bar      and sv.bar.visible)      or false
    user_visible.graph = (sv.temporal and sv.temporal.visible) or false
    if sv.bar and sv.bar.enabled ~= nil then bar_enabled = sv.bar.enabled end
  end

  Scene.register_callback("SceneStateChanged",
    function(scene, oldState, newState)
      if newState ~= SCENE_SHOWN then return end
      local now = Scene.is_hud_scene(scene:GetName())
      if now == in_hud then return end
      in_hud = now
      apply()
    end)

  apply()
end
