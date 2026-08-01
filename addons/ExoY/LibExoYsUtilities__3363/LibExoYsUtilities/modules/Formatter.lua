LibExoYsUtilities = LibExoYsUtilities or {}
local LibExoY = LibExoYsUtilities


--[[ --------------------------- ]]
--[[ -- Formatted Zos Strings -- ]]
--[[ --------------------------- ]]

function LibExoY.GetFormattedAbilityName( abilityId )
  return zo_strformat( SI_ABILITY_NAME, GetAbilityName(abilityId) )
end 

--[[ ------------------------ ]]
--[[ -- Add Icon to String -- ]]
--[[ ------------------------ ]]

-- used in: 
--    + LibExoYsUtilities/MenuEntrties.lua
-- /SavedVariables/GetSubmenuTitle()

function LibExoY.AddIconToString(str, icon, size, location)
  if LibExoY.IsNumber(icon) then
    icon = GetAbilityIcon(icon)
  end
  local iconStr = zo_strformat("|t<<2>>:<<2>>:<<1>>|t", icon, size)
  if location == "front" then 
    return zo_strformat("<<1>> <<2>>", iconStr, str)
  elseif location == "back" then 
    return zo_strformat("<<1>> <<2>>", str, iconStr)
  end
end

--[[ ------------------ ]]
--[[ -- Color String -- ]]
--[[ ------------------ ]]

--used in: 
--    + LibExoYsUtilities/Debug.lua
--    + ExoYsUserInterface/Chat.lua

-- color can be provided as: 
--    + hexadecimal (string)
--    + rgb (table)

function LibExoY.ColorString(str, color)
  return string.format( "|c%s%s|r", LibExoY.ColorHex(color), str)
end

--[[ ---------------------- ]]
--[[ -- Formatted Number -- ]]
--[[ ---------------------- ]]

--used in: 
--    + LibExoYsUtilities/StringFormatter.lua

-- format (table):
--    + factor, (number)  -- multiply value with factor (default = 1)
--    + decimal (number)  -- number of decimal digits (default = 0)
--    + prefix (string)   -- string appended in front without space
--    + suffix (string)   -- string appended at end without space

function LibExoY.GetFormattedNumber( value, format )
  format = format or {}
  format.factor = format.factor or 1
  local formatStr = zo_strformat("%s%.<<1>>f%s", format.decimal or 0)
  return string.format(formatStr, format.prefix or "", value*format.factor, format.suffix or "")
end



--[[ ---------------------- ]]
--[[ -- Countdown String -- ]]
--[[ ---------------------- ]]

-- used in: 
--    + TributesEnhancement.lua

function LibExoY.GetCountdownString( value, unit, decimal, notMilliseconds )
  local format = {
    suffix = unit and "s" or nil,
    factor = notMilliseconds and 1 or 1/1000
  }
  local seconds = value*format.factor
  if seconds < 10 and decimal then
    format.decimal = 1
  else
    format.decimal = 0
  end
  return LibExoY.GetFormattedNumber( value, format )
end


--[[ --------------------------- ]]
--[[ -- Complement with Zeros -- ]]
--[[ --------------------------- ]]

-- used in: 
--    + LibExoYsUtilities/StringFormatter.lua

function LibExoY.ComplementWithZeros( value, digits )
  digits = digits or 0
  local formatStr = zo_strformat("%0<<1>>d", digits)
  return string.format(formatStr, value)
end



--[[ ------------------------ ]]
--[[ -- Formatted Currency -- ]]
--[[ ------------------------ ]]

function LibExoY.GetFormattedCurrency( amount )
  local suffixList = {[3] = "k", [6] = "m"}
  local format = {}
  for i=3,6,3 do
    if amount >= 10^i then
      format.factor = 10^(-i)
      format.suffix = suffixList[i]
      format.decimal = math.floor(i/6)
    end
  end
  return LibExoY.GetFormattedNumber( amount, format )
end



--[[ ----------------- ]]
--[[ -- Time String -- ]]
--[[ ----------------- ]]

function LibExoY.GetTimeString( hideSeconds )
  local timeString = GetTimeString()
  if not hideSeconds then
    return timeString
  else
    local hours, minutes, seconds = timeString:match("([^%:]+):([^%:]+):([^%:]+)")
    return zo_strformat("<<1>>:<<2>>", hours, minutes)
  end
end



--[[ ---------------------- ]]
--[[ -- Convert Duration -- ]]
--[[ ---------------------- ]]

-- used in: 
--    + LibExoYsUtilities/StringFormatter.lua

-- duration (input) in milliseconds

-- durationTable ( output )
--    + each Unit     --> value for respective unit
--    + raw  (table)  --> total value for respective units

function LibExoY.ConvertDuration( duration )
  local factor = 1000
  local durationTable = { raw = {} }
  local limits = { 60, 60, 24, 7, 52 }
  local units = {"second", "minute", "hour", "day", "week" }

  durationTable.milliseconds = duration%1000
  durationTable.raw.milliseconds = duration

  for i, unit in ipairs( units ) do
    local limit = limits[i]
    local rawValue = math.floor( duration/factor )
    durationTable.raw[unit] = rawValue
    durationTable[unit] = rawValue >= limit and rawValue%limit or rawValue
    if unit == "week" then
      durationTable.year = math.floor( rawValue/limit )
    end
    factor = factor * limit
  end

  return durationTable
end



--[[ ------------------------ ]]
--[[ -- Formatted Duration -- ]]
--[[ ------------------------ ]]

-- Used by: 
-- TributesEnhancement.lua

-- duration: 
--      + duration in milliseconds O
--  or  + durationTable from "Lib.ConvertDuration"

-- mode: (option string):
--      + 'acronym'        --> 1y 2w 3d 4h 5m 6s
--      + 'word'           --> 1year 2weeks 3days 1hour 2minutes
--      + 'compact'        --> 00:00:00

-- specification (option string for compact mode):
-- output only created for
--      + default           --> hours:minutes:seconds
--      + 'minute'          --> minutes:seconds
--      + 'second'          --> seconds

function LibExoY.GetFormattedDuration( duration, mode, specification )
  local function Pluralize(word)
    return word.."s"
  end
  local durationTable = LibExoY.IsTable(duration) and duration or LibExoY.ConvertDuration( duration )
  local units = {"year", "week", "day", "hour", "minute", "second"}
  local acros = {"y", "w", "d", "h", "m", "s"}
  local output = ""
  local createString = false

  local firstUnitForCompact = 4
  if mode == "compact" and specification then
    if specification == "minute" then
      firstUnitForCompact = 5
    elseif
      specification == "second" then
        firstUnitForCompact = 6
      end
  end

  for i, unit in ipairs( units ) do
    local value = durationTable[unit]
    if value ~= 0 then createString = true end

    if mode == "compact" and i>3 and i >= firstUnitForCompact then createString = true end

    if createString then
      if mode == "acronym" then
        output = zo_strformat("<<1>> <<2>><<3>>", output, value, acros[i]  )

      elseif mode == "word" then
        local word = value > 1 and Pluralize(unit) or unit
        output = zo_strformat("<<1>> <<2>> <<3>>", output, value, word)

      elseif mode == "compact" then
        local entry = LibExoY.ComplementWithZeros(value, 2)
        if output ~= "" then entry = ":"..entry end
        output = zo_strformat("<<1>><<2>>", output, entry)
      end
    end

  end
  return output
end


--[[ ---------------------------- ]]
--[[ -- Remaining Milliseconds -- ]]
--[[ ---------------------------- ]]

function LibExoY.GetRemainingMilliseconds(endTime)
    return zo_max(endTime - GetGameTimeMilliseconds(), 0)
  end
  
  
function LibExoY.GetTimeRemaining( endTime, decimal, final )
  local timeRemaining = LibExoY.GetRemainingMilliseconds( endTime )/1000
  if not decimal then timeRemaining = math.floor(timeRemaining) end
  if timeRemaining == 0 then return final and final or "0" end
  if timeRemaining < 10 and decimal then
    return string.format( "%.1f", timeRemaining)
  else
    return string.format( "%.0f", timeRemaining)
  end
end
