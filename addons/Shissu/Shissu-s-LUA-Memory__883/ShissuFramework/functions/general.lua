-- Shissu Framework: General functions
-- -----------------------------------
-- 
-- Filename:    functions/fileintegrity.lua
-- Last Update: 18.11.2020
--
-- Written by Christian Flory (@Shissu, EU) - esoui@flory.one
-- Distribution without license is prohibited!

-- div. Funktionen, die andere Add-ons/Module nutzen.
local _func = {}

-- einzelne i18n-Textausgaben
function _func._L(addonName, localizationName, alternateName)
  return function(localizationName, alternateName)
    local _L = ShissuLocalization[addonName]

    if alternateName ~= nil then
      _L = ShissuLocalization[alternateName]
    end
    
    if _L[localizationName] == nil then 
      return "" 
    end
    
    return _L[localizationName]
  end
end

-- Aktuelle Uhrzeit... Korrektur +
function _func.currentTime()
  local correction = GetSecondsSinceMidnight() - (GetTimeStamp() % 86400)
  if correction < -12*60*60 then correction = correction + 86400 end

  return GetTimeStamp() + correction
end

-- Zeit bis zum nächsten Gildenhändler???
function _func.getKioskTime(which, additional, day)     
  local hourSeconds = 60 * 60
  local daySeconds = 60 * 60 *24
  local weekSeconds = 7 * daySeconds
  local additional = additional or 0
  
  -- Erste Woche 1970 beginnt Donnerstag -> Verschiebung auf Gebotsende
  local firstWeek = 1 + (5 * daySeconds) + (13 * hourSeconds)

  local currentTime =  _func.currentTime()                               

  -- Anzahl der Wochen seit 01.01.1970
  local week = math.floor(currentTime / weekSeconds) + additional
  local beginnKiosk = firstWeek + (weekSeconds * week) + 60 * 60
  
  -- Gebots Ende 
  if (which == 1) then
    beginnKiosk = beginnKiosk - 300
  -- Ersatzhändler
  elseif (which == 2) then
    beginnKiosk = beginnKiosk + 300                                                     
  end
  
  -- Restliche Zeit in der Woche
  local restWeekTime = beginnKiosk - currentTime                            
  
  if (day) then
    restWeekTime = beginnKiosk
  end
  
  if restWeekTime < 0 then
    restWeekTime = restWeekTime + weekSeconds
  end

  return restWeekTime
end

ShissuFramework["func"] = _func