-- div. Funktionen, die andere Add-ons/Module nutzen.
local _func = {}

-- einzelne i18n-Textausgaben
function _func._L(addonName, localizationName)
  return function(localizationName)
    local _L = ShissuLocalization[addonName]
    
    if _L[localizationName] == nil then 
      return "" 
    end
    
    return _L[localizationName]
  end
end

-- String an String teilen, und die einzelnen Teile wieder in ein Array packen
function _func.splitToArray (search, text)
  if (text=='') then return false end
  
  local pos,arr = 0,{}
  
  for st,sp in function() return string.find(search,text,pos,true) end do
    table.insert(arr, string.sub(search,pos,st-1))
    pos = sp + 1
  end
  
  table.insert(arr,string.sub(search,pos))
  
  return arr
end   

-- RGB zu Hex
function _func.RGBtoHex(r,g,b, list)
  local rgb = {255, 255, 255}

  if ( list ~= nil ) then
    rgb = { list[1]*255, list[2]*255, list[3]*255 }
  else
    rgb = {r*255, g*255, b*255}
  end

  local hexstring = ""

  for key, value in pairs(rgb) do
    local hex = ""

    while (value > 0)do
      local index = math.fmod(value, 16) + 1
      value = math.floor(value / 16)
      hex = string.sub("0123456789ABCDEF", index, index) .. hex     
    end

    if(string.len(hex) == 0) then
      hex = "00"
    elseif(string.len(hex) == 1) then
      hex = "0" .. hex
    end

    hexstring = hexstring .. hex
  end

  return "|c" .. hexstring
end

-- String an String teilen, und die einzelnen Teile wieder in ein Array packen
function _func.splitToArray (search, text)
  if (text=='') then return false end
  
  local pos,arr = 0,{}
  
  for st,sp in function() return string.find(search,text,pos,true) end do
    table.insert(arr, string.sub(search,pos,st-1))
    pos = sp + 1
  end
  
  table.insert(arr,string.sub(search,pos))
  
  return arr
end   

-- Unerwünschte Zeichen abschneiden
function _func.cutStringAtLetter(text, letter)
  if text ~= nil then
    local pos = string.find(text, letter, nil, true)
      
    if pos then text = string.sub (text, 1, pos-1) end
  end
  
  return text;
end

-- Auf- und Abrunden
function _func.round(number)
  local dec = number - math.floor(number)

   if dec > 0.5 then return math.ceil(number) 
   else return math.floor(number) end
end

-- String leer / oder nicht existent
function _func.isStringEmpty(text)
  return text == nil or text == ''
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
  local firstWeek = 1 + (3 * daySeconds) + (19 * hourSeconds)

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