-- Create namespace
DsRGuildUnknownUtility = {}
local DsRGuildUnknownUtility = DsRGuildUnknownUtility  or {}

-------------------------------------------------------------------------------------------------------------------------------------------------
-- @Shadowfen - AutoCategory integration
-- Return only listA (all) characters that are not in listB (known)
function DsRGuildUnknownUtility:RemainsList(listA, listB)
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

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Removes any listA characters that are not in listB
function DsRGuildUnknownUtility:TrimList(listA, listB)
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

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildUnknownUtility:isEmpty(s)
  return s == nil or s == ''
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildUnknownUtility:isEmptyList(s)
  local next = next
  return next(s) == nil or s == {}
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildUnknownUtility:GetSize(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- only checks 1 level deep :S
function DsRGuildUnknownUtility:CheckDefaults(a, defaults)
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

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildUnknownUtility:ClearEmptyTables(t)
  for k,v in pairs(t) do
    if type(v) == 'table' then
      DsRGuildUnknownUtility:ClearEmptyTables( v )
      if next( v ) == nil then
        t[k] = nil
      end
    end
  end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildUnknownUtility:SetColour(text, colour)
  colour = string.sub(colour, 1, 6) -- removes alpha if its included
  local combineTable = {"|c", colour, tostring(text), "|r"}
  return table.concat(combineTable)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildUnknownUtility:ConvertRGBAToHex(r, g, b, a)
  return string.format("%.2x%.2x%.2x%.2x", zo_floor(r * 255), zo_floor(g * 255), zo_floor(b * 255), zo_floor(a * 255))
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildUnknownUtility:ConvertHexToRGBA(colourString)
  local r=tonumber(string.sub(colourString, 1, 2), 16) or 255
  local g=tonumber(string.sub(colourString, 3, 4), 16) or 255
  local b=tonumber(string.sub(colourString, 5, 6), 16) or 255

  local a = 255   -- returns max alpha (visible) if no alpha was specified

  if string.len(colourString) == 8 then
    a = tonumber(string.sub(colourString, 7, 8), 16) or 255
  end

  return r/255, g/255, b/255, a/255
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildUnknownUtility:ConvertHexToRGBAPacked(colourString)
  local r, g, b, a = DsRGuildUnknownUtility:ConvertHexToRGBA(colourString)
  return {r = r, g = g, b = b, a = a}
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildUnknownUtility:StringToColour(text)
  local colour = "E" .. string.sub(HashString(text), 2, 6)   -- skipping @, consistent shades of red
  local combineTable = {"|c", colour, tostring(text), "|r"}
  return table.concat(combineTable)  
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildUnknownUtility:Split(source, delimiters)
  local elements = {}
  local pattern = '([^'..delimiters..']+)'
  string.gsub(source, pattern, function(value) elements[#elements + 1] =     value;  end);
  return elements
end