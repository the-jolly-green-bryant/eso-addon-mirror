CDescriptor = CDescriptor or {}
local CDescriptor = CDescriptor

local EVENT_MANAGER       = EVENT_MANAGER
local ZO_CreateStringId   = ZO_CreateStringId

ZO_CreateStringId("SI_BINDING_NAME_CDESCRIPTOR_TOGGLE", "Toggle CDescriptor")

local function on_addon_loaded()
  local K = CDescriptor.Constants

  CDescriptor.name    = K.ADDON_NAME
  CDescriptor.version = K.VERSION

  CDescriptor.Settings.load()
  CDescriptor.UI.init()

  local x = CDescriptor.Settings.get(K.SAVED_VARS.WINDOW_X)
  local y = CDescriptor.Settings.get(K.SAVED_VARS.WINDOW_Y)
  if x and y then
    local window = _G[K.CONTROLS.WINDOW]
    window:ClearAnchors()
    window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
  end

  SLASH_COMMANDS[K.SLASH_COMMAND] = function()
    CDescriptor.UI.toggle()
  end

  CDescriptor.log("Loaded v" .. K.VERSION .. " — " .. K.SLASH_COMMAND .. " to open")
end

-- Debug helper: disabled automatically when Constants.DEBUG = false.
function CDescriptor.log(msg)
  if CDescriptor.Constants and CDescriptor.Constants.DEBUG then
    d("[CDescriptor] " .. tostring(msg))
  end
end

CDescriptor.Events.register_addon_loaded(CDescriptor.Constants.ADDON_NAME, on_addon_loaded)
