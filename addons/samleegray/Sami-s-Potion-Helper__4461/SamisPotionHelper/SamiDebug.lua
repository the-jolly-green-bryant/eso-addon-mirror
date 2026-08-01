SamisAddonsDebugHelpers = SamisAddonsDebugHelpers or {}

local SAMID = SamisAddonsDebugHelpers
local SPH = SamisPotionHelperAddon

function SAMID:Print(...)
  if not SPH.savedVariables or not SPH.savedVariables.enableDebug then return end

  local message = string.format(...)
  d("[SAMI DEBUG]: " .. message)
end
