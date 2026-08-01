-- Shissu Framework: Chat functions
-- --------------------------------
-- 
-- Desc:        allgemeine Funktionen zur Formatierung des Datum und der Uhrzeit
-- Filename:    functions/date.lua
-- Last Update: 05.12.2020
--
-- Written by Christian Flory (@Shissu, EU) - esoui@flory.one
-- Distribution without license is prohibited!

local _date = {}
local _lDate = {}

-- base informations: esoui/libraries/globals/time.lua
local ONE_MINUTE_IN_SECONDS = 60
local ONE_HOUR_IN_MINUTES   = 60
local ONE_DAY_IN_HOURS      = 24
local ONE_HOUR_IN_SECONDS   = ONE_MINUTE_IN_SECONDS * 60               -- = 3600
local ONE_DAY_IN_SECONDS    = ONE_DAY_IN_HOURS * ONE_HOUR_IN_SECONDS   -- = 86400
local ONE_DAY_IN_MINUTES    = ONE_DAY_IN_HOURS * ONE_HOUR_IN_MINUTES

-- Alternative zu ZO_FormatTimeAsDecimalWhenBelowThreshold(seconds, secondsThreshold)
-- Sekunden in die Form: XXX Tage XX Stunden umrechnen
local function secsToTime(time, complete)
  local day = math.floor(time / ONE_DAY_IN_SECONDS)
  local hours = math.floor(time / ONE_HOUR_IN_SECONDS) - (day * ONE_DAY_IN_HOURS)
  local minutes = math.floor(time / ONE_MINUTE_IN_SECONDS) - (day * ONE_DAY_IN_MINUTES) - (hours * ONE_MINUTE_IN_SECONDS)
  local seconds = time % ONE_MINUTE_IN_SECONDS

  if complete then return ("%dd %dh %dmin %ds"):format(day, hours, minutes, seconds) end
  
  -- mehr als 1 Tag
  if(day >= 1) then return ("%dd %dh"):format(day, hours) end
  
  -- Spieler sind weniger als 1d Offline
  if(hours >= 1) then return ("%dh %dmin"):format(hours, minutes) end
  
  -- Spieler sind weniger als 1h Offline
  if(minutes >= 1) then return ("%dmin %ds"):format(minutes, seconds) end
  
  -- Spieler sind weniger als 1m Offline
  return ("%ds"):format(seconds)
end

-- Ersetzt die alte Funktion: getKioskTime vom ShissuHome-Modul
-- /script d(ShissuFramework["functions"]["date"].getRestKioskTime())
function _date.getRestKioskTime(formatted)
  local nextKiosk, lastBid, replacementKiosk = GetGuildKioskCycleTimes()
  local currentTime = GetTimeStamp()

  nextKiosk        = (nextKiosk-currentTime)
  lastBid          = (lastBid-currentTime)
  replacementKiosk = (replacementKiosk-currentTime)

  if (formatted == true) then
    nextKiosk        = secsToTime(nextKiosk, 1)
    lastBid          = secsToTime(lastBid, 1)
    replacementKiosk = secsToTime(replacementKiosk, 1)
  end
  
  return nextKiosk, lastBid, replacementKiosk
end

-- Uhrzeit formatieren
function _date.formattedTime(time, format, color)
  local time = time or GetTimeString()
  local color = color or ""

  local hours, minutes, seconds = time:match("([^%:]+):([^%:]+):([^%:]+)")
  
  local hours12	
  local hours_0 = tonumber(hours)
  local hours12_0 = (hours_0 - 1)%12 + 1
  
  if (hours12_0 < 10) then
		hours12 = "0" .. hours12_0
	else
		hours12 = hours12_0
	end        
  
  -- AM-PM-System
	local englishUP  = "AM"
	local englishLOW = "am"
  
	if (hours_0 >= 12) then
		englishUP = "PM"
		englishLOW = "pm"
	end
  
  local minutes_0 = minutes
  local seconds_0 = seconds
  
  if (string.len(minutes) < 2) then
    minutes_0 = "0" .. minutes     
  end

  if (string.len(seconds) < 2) then
    seconds_0 = "0" .. seconds
  end

  time = format or "HH:mm:ss"
	time = time:gsub("HH", hours)
	time = time:gsub("H",  hours_0)
  time = time:gsub("hh", hours12)
	time = time:gsub("h",  hours12_0)  
  time = time:gsub("mm", minutes_0)  
	time = time:gsub("m",  minutes)
  time = time:gsub("ss", seconds_0)    
	time = time:gsub("s",  seconds)  
	time = time:gsub("A",  englishUP)
  time = time:gsub("a",  englishLOW)
  
  time = string.format("%s" .. time, color) 

  return time
end

function _date.formattedDate(date, format, color)
  local date = date or GetDateStringFromTimestamp(GetTimeStamp())
  local color = color or ""

  local days, month, year = date:match("(%d+).(%d+).(%d+)")
  local days_0 = tonumber(days)
  local month_0 = tonumber(days)

  date = format or "DD.MM.Y"
  date = date:gsub("DD", days)
  date = date:gsub("D",  days_0)
  date = date:gsub("MM", month)
  date = date:gsub("M",  month_0)  
  date = date:gsub("Y",  year)
  
  date = string.format("%s" .. date, color) 

  return date
end

--/script d(ShissuFramework["functions"]["date"].getFormattedDate())
function _date.getFormattedDate(dateColor, timeColor)
  local date = _date.formattedDate(nil, nil, dateColor) .. " " .. _date.formattedTime(nil, nil, timeColor)

	return date .. "|r"
end

ShissuFramework["functions"]["date"] = _date