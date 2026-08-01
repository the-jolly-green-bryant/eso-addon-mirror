EasyFrameUtils = {}

local function trace(msg)
  if EasyFrameUtils.traceEnabled then
    d(GetTimeString()..":"..msg)
  end
end

function EasyFrameUtils.CreateClass(...)
  local parents = {...} -- create table that holds all pareants
  local class = setmetatable({}, {
      __index = function (t, k)
        for i, v in ipairs(parents) do
          local attr = v[k] -- try to get requested attribute first
          if attr ~= nil then
            return attr -- return is exists
          end
        end
      end
    })
  local instanceMetatable =  { __index = class } -- the metatable used by instances
  class.New = function (self) -- the default constructor
    return setmetatable({}, instanceMetatable)
  end
  return class
end



local function onPulseStop(animation, control)
  trace("onPulseStop")
  local controlParent = control:GetParent()
  
  if controlParent.oldStopHandler then
    controlParent.oldStopHandler(animation, control)
  end
  
  if controlParent.fnStop then
    controlParent.fnStop(animation, controlParent)
  end

end

---------------------------------------------------------------------
-- Function: ConstructHighlightAnimation
--
-- This function plays a pulse animation for the given control
---------------------------------------------------------------------
function EasyFrameUtils:ConstructHighlightAnimation(control, fnStop)
 
  if not control.pulseAnimation then
    local pulseTexture = CreateControlFromVirtual("$(parent)PulseTexture", control, "ZO_CraftingResultPulseTexture")
    control.pulseAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("CraftingResultPulse", pulseTexture)
    local animation = control.pulseAnimation:GetAnimation(3)
    control.oldStopHandler = animation:GetHandler("OnStop")
    control.fnStop = fnStop
    animation:SetHandler("OnStop", onPulseStop)
  end
end

---------------------------------------------------------------------
-- Function: PlayHighlightAnimation
--
-- This function plays a pulse animation for the given control
---------------------------------------------------------------------
function EasyFrameUtils:PlayHighlightAnimation(control, fnStop)
  EasyFrameUtils:ConstructHighlightAnimation(control, fnStop)
  if not control.pulseAnimation:IsPlaying() then
    control.pulseAnimation:PlayFromStart()
  end
end
