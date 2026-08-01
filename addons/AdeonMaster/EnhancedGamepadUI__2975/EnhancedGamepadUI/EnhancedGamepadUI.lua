EnhancedGamepadUI = {}

EnhancedGamepadUI.name = "EnhancedGamepadUI"

function EnhancedGamepadUI:Initialize()
end

function EnhancedGamepadUI.OnAddOnLoaded(event, addonName)
  if addonName == EnhancedGamepadUI.name then
    EnhancedGamepadUI:Initialize()
  end
end

-- esoui/ingame/lockpick/lockpick.lua
local STARTING_NORMALIZED_LOCKPICK_X = .53
local GAMEPAD_SPEED_FACTOR = 3.5

function ZO_Lockpick:UpdateVirtualMousePosition()
  if not self.virtualMouseX then
    self.virtualMouseX = zo_lerp(self.lockpickLowerBound, self.lockpickUpperBound, STARTING_NORMALIZED_LOCKPICK_X)
    self.virtualNormalizedMouseX = STARTING_NORMALIZED_LOCKPICK_X
    self:OnVirtualLockpickPositionChanged()
  else
    -- custom code start
    local uiMouseDelta = GetUIMouseDeltas()
    local gamepadDelta = (ZO_Gamepad_GetLeftStickEasedX() * GAMEPAD_SPEED_FACTOR)
    local deltaX

    if uiMouseDelta ~= 0 then
      deltaX = uiMouseDelta
    else
      deltaX = gamepadDelta
    end
    -- custom code end
    deltaX = deltaX * GetFrameDeltaNormalizedForTargetFramerate()

    if deltaX ~= 0 then
      local newX = self.virtualMouseX + deltaX

      local clampedX = zo_clamp(newX, self.lockpickLowerBound, self.lockpickUpperBound)
      if clampedX ~= self.virtualMouseX then
        self.virtualMouseX = clampedX
        self.virtualNormalizedMouseX = (clampedX - self.lockpickLowerBound) / (self.lockpickUpperBound - self.lockpickLowerBound)

        self:OnVirtualLockpickPositionChanged()
      end
    end
  end
end

-- libraries/zo_radialmenu/zo_radialmenu.lua
function ZO_RadialMenu:UpdateVirtualMousePositionFromGamepad()
  -- custom code start
  if self:UpdateVirtualMousePosition() then
    return true
  end
  -- custom code end

  local outerRadius = zo_max(self.control:GetDimensions()) * .5
  local x, y = DIRECTIONAL_INPUT:GetXY(unpack(self.directionInputs))
  if (not self.selectIfCentered) or (x ~= 0) or (y ~= 0) then
    self.virtualMouseX = x * outerRadius
    self.virtualMouseY = -y * outerRadius
      
    return self:ShouldUpdateSelection()
  end

  return false
end
