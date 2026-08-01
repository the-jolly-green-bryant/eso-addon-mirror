-- * _ANDY_VERSION: 1.0.0 ** Please do not modify this line.
--[[----------------------------------------------------------
	AddonAnalyzer (ANDY)
  ----------------------------------------------------------
  *
	* Authors:
	* - Lent (IGN @CallMeLent, Github @adefee)
  *
  * Contents (utility functions used by Andy):
  * - isEmpty()
  *
]]--

AndyUtil = AndyUtil or {}

-- isEmpty()
-- Utility; Checks if given string is empty/nil
function AndyUtil.isEmpty(s)
  return s == nil or s == ""
end

-- trim()
-- Utility; Trims extraneous whitespace from string
function AndyUtil.trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- addToSet()
-- Utility; Add given key to set with int 1
function AndyUtil.addToSet(set, key)
  set[key] = 1
end

-- AndyUtil.setContains()
-- Utility; Determines if a set contains a key. Best used for ipair-able things
function AndyUtil.setContains(set, key)
  return set[key] ~= nil
end

-- AndyUtil.setContains()
-- Utility; Determines if a set and key contain a value
function AndyUtil.setContainsValue(set, value)
  local foundValue = false

  for i,v in pairs(set) do
    if v == value then
      foundValue = true
    end
  end

  return foundValue
end

-- AndyUtil.countSet()
-- Utility; Counts number of entries in a set
function AndyUtil.countSet(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

-- AndyUtil.sortSet
-- Utility; Sorts table alphabetically
function AndyUtil.sortSet(set)
  return table.sort(set, function(a,b) return a < b end)
end

-- difference()
-- Utility; Returns table of differences between two given tables
function AndyUtil.difference(a, b)
  local aa = {}
  for k,v in pairs(a) do aa[v]=true end
  for k,v in pairs(b) do aa[v]=nil end
  local ret = {}
  local n = 0
  for k,v in pairs(a) do
      if aa[v] then n=n+1 ret[n]=v end
  end
  return ret
end

-- formatNumber()
-- Utility; Returns a localized (comma thousands, period decimals) number
function AndyUtil.formatNumber(amount)
  return zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(amount))
end

function AndyUtil.startsWith(String,Start)
  return string.sub(String,1,string.len(Start))==Start
end

-- split()
-- Utility; split string based on given string & delimiter
function AndyUtil.split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

-- colorize()
-- Display; Wraps text with a color. Credit: @Phuein
function AndyUtil.colorize(text, color)
  -- Default to addon's .color.
  if not color then color = Joker.color end
  text = "|c" .. color .. text .. "|r"
  return text
end

-- roundNumber
-- Util: Round number [num] to given decimal places [numDecimalPlaces]
function AndyUtil.roundNumber(num, numDecimalPlaces)
  return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

-- normalizeAddonName
-- Util: Attempts to normalize addon names for comparison
function AndyUtil.normalizeAddonName(name)
  if not name then return "" end
  return string.lower(string.gsub(name, "^%s*(.-)%s*$", "%1"))
end

-- normalizeAuthorName
-- Util: Attempts to normalize author names for comparison
function AndyUtil.normalizeAuthorName(author)
  if not author then return "" end
  return string.lower(string.gsub(author, "^%s*(.-)%s*$", "%1"))
end

-- getPlatform
-- Util: Returns the current platform ("pc" or "console")
function AndyUtil.getPlatform()
  return IsConsoleUI() and "console" or "pc"
end

-- isPlatformMatch
-- Util: Checks if a watchlist entry's platform matches the current platform
-- Accepts: "pc", "console", "both", or nil (defaults to "both")
function AndyUtil.isPlatformMatch(watchlistPlatform)
  if not watchlistPlatform or watchlistPlatform == "both" then
    return true
  end
  
  local currentPlatform = AndyUtil.getPlatform()
  return watchlistPlatform == currentPlatform
end

-- runPeriodicEvents()
-- Data; Determines if a specific periodic event is due to occur
function AndyUtil.runPeriodicEvents(target, callbacks, skipIncrement)
  if target == 'scan' then -- Periodically show a joke to the user
    zo_callLater(function() return callbacks['scan']() end, 3000)
  end

  return false
end

-- PlayAlertSound()
-- Util: Plays the alert sound
function AndyUtil.PlayAlertSound()
  PlaySound(SOUNDS.DEATH_RECAP_ATTACK_SHOWN)
  zo_callLater(function() return PlaySound(SOUNDS.DEATH_RECAP_ATTACK_SHOWN) end, 150)
  zo_callLater(function() return PlaySound(SOUNDS.DEATH_RECAP_ATTACK_SHOWN) end, 300)
end

-- PlayAlertBanner()
-- Util: Shows large banner message on center screen
function AndyUtil.PlayAlertBanner(message)
  zo_callLater(function() return CENTER_SCREEN_ANNOUNCE:AddMessage(0, CSA_CATEGORY_LARGE_TEXT, SOUNDS.INTERACT_WINDOW_OPEN, message) end, 1500)
end

AndyUtil = AndyUtil or {}
