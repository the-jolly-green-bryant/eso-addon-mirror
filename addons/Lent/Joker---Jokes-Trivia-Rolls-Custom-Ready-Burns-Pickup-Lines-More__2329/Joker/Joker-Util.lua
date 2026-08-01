-- * _JOKER_VERSION: 8.0.0 ** Please do not modify this line.
--[[----------------------------------------------------------
  Utility Functions
  - Frequent needs not specific to Joker (isEmpty, setContains, etc)
  - Imported from Joker.lua

  CONTENTS:
  - isEmpty()
  - trim()
  - addToSet()
  - setContains()
  - difference()
  - formatNumber()
  - startsWith()
  - split()
  - colorize()
  ----------------------------------------------------------
]]--

local Util = JokerUtilityFn or {}

-- isEmpty()
-- Utility; Checks if given string is empty/nil
function Util.isEmpty(s)
  return s == nil or s == ""
end

-- isSetEmpty()
-- Utility; Checks if given string is empty/nil
function Util.isSetEmpty(t)
  return next (t) == nil
end

-- trim()
-- Utility; Trims extraneous whitespace from string
function Util.trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- addToSet()
-- Utility; Add given key to set with int 1
function Util.addToSet(set, key)
  set[key] = 1
end

-- Util.setContains()
-- Utility; Determines if a set contains a key. Best used for ipair-able things
function Util.setContains(set, key)
  return set[key] ~= nil
end

-- Util.setContains()
-- Utility; Determines if a set and key contain a value
function Util.setContainsValue(set, value)
  local foundValue = false

  for i,v in pairs(set) do
    if v == value then
      foundValue = true
    end
  end

  return foundValue
end

-- Util.countSet()
-- Utility; Counts number of entries in a set
function Util.countSet(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

-- Util.sortSet
-- Utility; Sorts table alphabetically
function Util.sortSet(set)
  return table.sort(set, function(a,b) return a < b end)
end

-- difference()
-- Utility; Returns table of differences between two given tables
function Util.difference(a, b)
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
function Util.formatNumber(amount)
  return zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(amount))
end

function Util.startsWith(String,Start)
  return string.sub(String,1,string.len(Start))==Start
end

-- split()
-- Utility; split string based on given string & delimiter
function Util.split(inputstr, sep)
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
function Util.colorize(text, color)
  -- Default to addon's .color.
  if not color then color = Joker.color end
  text = "|c" .. color .. text .. "|r"
  return text
end

-- roundNumber
-- Util: Round number [num] to given decimal places [numDecimalPlaces]
function Util.roundNumber(num, numDecimalPlaces)
  return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

JokerUtilityFn = Util or {}
