local UT = UnknownTracker or {}

------------------------------------------------------------------------------
-- @Shadowfen - AutoCategory integration
-- Return only listA (all) characters that are not in listB (known)
function UT:RemainsList(listA, listB)
  local newList = {}

  if listA ~= nil then
    for k, v in pairs(listA) do
      if not listB[v] then
        newList[v] = 1
      end
    end
  end

  return newList
end
------------------------------------------------------------------------------

-- Removes any listA characters that are not in listB
function UT:TrimList(listA, listB)
  local newList = {}

  if listA ~= nil then
    for k, v in pairs(listB) do
      if listA[v] then
        newList[v] = 1
      end
    end
  end

  return newList  --newList[name] = 1
end

function UT:isEmpty(s)
  return s == nil or s == ''
end

function UT:isEmptyList(s)
  local next = next
  return next(s) == nil or s == {}
end

function UT:GetSize(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

-- only checks 1 level deep :S
function UT:CheckDefaults(a, defaults)
  if a == nil then
    a = defaults
  else
    -- insert missing defaults values
  	for k, v in pairs(defaults) do
  		if a[k] == nil then
        a[k] = v
      end
  	end

    -- remove non defaults values
    for k, v in pairs(a) do
      if defaults[k] == nil then
        a[k] = nil
      end
    end
  end

  return a
end

function UT:ClearEmptyTables(t)
  for k,v in pairs(t) do
    if type(v) == 'table' then
      self:ClearEmptyTables( v )
      if next( v ) == nil then
        t[k] = nil
      end
    end
  end
end

function UT:SetColour(text, colour)
  colour = string.sub(colour, 1, 6) -- removes alpha if its included
  local combineTable = {"|c", colour, tostring(text), "|r"}
  return table.concat(combineTable)
end

function UT:ConvertRGBAToHex(r, g, b, a)
  return string.format("%.2x%.2x%.2x%.2x", zo_floor(r * 255), zo_floor(g * 255), zo_floor(b * 255), zo_floor(a * 255))
end

-- use ZO_ColorDef:New("RRGGBBAA") or ZO_ColorDef:New("RRGGBB") instead
-- works with and without alpha specified
function UT:ConvertHexToRGBA(colourString)
  local r=tonumber(string.sub(colourString, 1, 2), 16) or 255
  local g=tonumber(string.sub(colourString, 3, 4), 16) or 255
  local b=tonumber(string.sub(colourString, 5, 6), 16) or 255

  local a = 255   -- returns max alpha (visible) if no alpha was specified

  if string.len(colourString) == 8 then
    a = tonumber(string.sub(colourString, 7, 8), 16) or 255
  end

  return r/255, g/255, b/255, a/255
end

function UT:ConvertHexToRGBAPacked(colourString)
  local r, g, b, a = self:ConvertHexToRGBA(colourString)
  return {r = r, g = g, b = b, a = a}
end

function UT:StringToColour(text)
  local colour = "E" .. string.sub(HashString(text), 2, 6)   -- skipping @, consistent shades of red
  local combineTable = {"|c", colour, tostring(text), "|r"}
  return table.concat(combineTable)  
end

function UT:Split(source, delimiters)
  local elements = {}
  local pattern = '([^'..delimiters..']+)'
  string.gsub(source, pattern, function(value) elements[#elements + 1] =     value;  end);
  return elements
end