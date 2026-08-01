-- Shissu Framework: Datatypes functions
-- -------------------------------------
-- 
-- Desc:        Funktionen zur Bearbeitung/Ausgabe/Veränderung div. Datentypen
-- Filename:    functions/datatypes.lua
-- Last Update: 14.12.2020
--
-- Written by Christian Flory (@Shissu, EU) - esoui@flory.one
-- Distribution without license is prohibited!

local _datatypes = {}

-- String an String teilen, und die einzelnen Teile wieder in ein Array packen
function _datatypes.splitToArray (search, text)
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
function _datatypes.cutStringAtLetter(text, letter)
  if text ~= nil then
    local pos = string.find(text, letter, nil, true)
      
    if pos then text = string.sub (text, 1, pos-1) end
  end
  
  return text;
end

-- Auf- und Abrunden
function _datatypes.round(number)
  local dec = number - math.floor(number)

   if dec > 0.5 then return math.ceil(number) 
   else return math.floor(number) end
end

-- String leer / oder nicht existent
function _datatypes.isStringEmpty(text)
  return text == nil or text == ''
end

-- Einzelnes Element aus einer Table entfernen, mit "Key"
function _datatypes.removeKey(t, k)
	local i = 0
	local keys, values = {},{}
	for k,v in pairs(t) do
		i = i + 1
		keys[i] = k
		values[i] = v
	end

	while i>0 do
		if keys[i] == k then
			table.remove(keys, i)
			table.remove(values, i)
			break
		end
		i = i - 1
	end

	local a = {}
	for i = 1,#keys do
		a[keys[i]] = values[i]
	end

	return a
end

-- RGB zu Hex
function _datatypes.RGBtoHex(colors)
  local rgb = {255, 255, 255}

  if ( colors ~= nil ) then
    rgb = { colors[1]*255, colors[2]*255, colors[3]*255 }
  end

  local hexstring = ""

  for key, value in pairs(rgb) do
    local hex = ""

    while (value > 0) do
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

ShissuFramework["functions"]["datatypes"] = _datatypes