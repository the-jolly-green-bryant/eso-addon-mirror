MultiClassAbilityTracker = MultiClassAbilityTracker or {}
local MCAT = MultiClassAbilityTracker
MCAT.Utils = {}
local Utils = MCAT.Utils

-- #region[pink] Logging
function Utils.Log(message, level)
  level = level or "INFO"
  local prefix = "|cFFFFFF[MCAT]|r"

  if level == "DEBUG" then
    prefix = "|cFF00FF[MCAT-DEBUG]|r"
  elseif level == "ERROR" then
    prefix = "|cFFFF00[MCAT-ERROR]|r"
  elseif level == "WARN" then
    prefix = "|cFFFFFF[MCAT-WARN]|r"
  end

  d(prefix .. " " .. tostring(message))
end

function Utils.LogError(message)
  Utils.Log(message, "ERROR")
end

function Utils.LogWarn(message)
  Utils.Log(message, "WARN")
end

function Utils.LogDebug(message)
  if not MCAT.Settings.IsDebugEnabled() then return end
  Utils.Log(message, "DEBUG")
end
--#endregion

-- #region[teal] Color
-- hex has no leading '#'; r/g/b are 0-1 floats, matching LibAddonMenu's colorpicker convention.
function Utils.HexToRGB(hex)
  local r = tonumber(hex:sub(1, 2), 16) / 255
  local g = tonumber(hex:sub(3, 4), 16) / 255
  local b = tonumber(hex:sub(5, 6), 16) / 255
  return r, g, b
end

function Utils.RGBToHex(r, g, b)
  return string.format("%02X%02X%02X", zo_round(r * 255), zo_round(g * 255), zo_round(b * 255))
end
--#endregion