Verditer = Verditer or {}
Verditer.Visibility = {}
local M = Verditer.Visibility

local Scene = Verditer.zenimax.scene
local SCENE_SHOWN = Scene.SCENE_SHOWN
local log = Verditer.Log.for_module("visibility")
local in_hud = true
local user_visible = { graph = false }

local function apply()
  if VerditerGraphWindow then
    VerditerGraphWindow:SetHidden(not (in_hud and user_visible.graph))
  end
  if VerditerSettingsPanel and not in_hud then
    VerditerSettingsPanel:SetHidden(true)
  end
  if Verditer.Logo then
    Verditer.Logo.sync(in_hud and not user_visible.graph)
  end
end

local function persist()
  local sv = Verditer.SavedVars
  if not sv then return end
  sv.graph = sv.graph or {}
  sv.graph.visible = user_visible.graph
end

function M.set(key, visible)
  if user_visible[key] == visible then return end
  log:info("set", key, "->", visible and "visible" or "hidden")
  user_visible[key] = visible
  apply()
  persist()
end

function M.get(key) return user_visible[key] or false end

function M.master_toggle()
  M.set("graph", not user_visible.graph)
end

function M.init()
  local sv = Verditer.SavedVars
  if sv then
    user_visible.graph = (sv.graph and sv.graph.visible) or false
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
