SamisTrialAddonsDebugHelpers = SamisTrialAddonsDebugHelpers or {}

local SAMID = SamisTrialAddonsDebugHelpers
local STH = SamisTrialHelperAddon

function SAMID:Print(...)
  if not STH.settings or not STH.settings.enableDebug then return end

  local message = string.format(...)
  d("[SAMI DEBUG]: " .. message)
end
