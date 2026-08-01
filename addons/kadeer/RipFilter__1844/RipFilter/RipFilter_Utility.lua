local RF = RipFilter or {}

function RF:millisecondsToTime(milliseconds)
  local seconds = math.floor(tonumber(milliseconds) / 1000)

  if seconds <= 0 then
    return "00:00:00";
  else
    hours = string.format("%02.f", math.floor(seconds/3600));
    mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
    secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
    return hours..":"..mins..":"..secs
  end
end

function RF:makeLink(type, text, colour, data, data2)
  -- |H1:ability:69|h[Test]|h
  local combineTable = {"|c", colour, "|H1:", tostring(type), ":", data, ":", data2, "|h", tostring(text), "|h", "|r"}
  return table.concat(combineTable)
end

function RF:isEmpty(s)
  return s == nil or s == ''
end

-- fucks up if u do table[0] ? need to check
function RF:isEmptyTable(s)
  local next = next
  return next(s) == nil or s == {}
end

function RF:Colorize(text, color)
  local combineTable = {"|c", color, tostring(text), "|r"}
  return table.concat(combineTable)
end

function RF:ConvertHexToRGBAPacked(colourString)
  local r, g, b, a = RF:ConvertHexToRGBA(colourString)
  return {r = r, g = g, b = b, a = a}
end

function RF:ConvertRGBToHex(r, g, b)
  return string.format("%.2x%.2x%.2x", zo_floor(r * 255), zo_floor(g * 255), zo_floor(b * 255))
end

function RF:ConvertHexToRGBA(colourString)
  local r=tonumber(string.sub(colourString, 1, 2), 16) or 255
  local g=tonumber(string.sub(colourString, 3, 4), 16) or 255
  local b=tonumber(string.sub(colourString, 5, 6), 16) or 255
  return r/255, g/255, b/255, 1
end

function RF:isValidPlayer(unitTag)
  -- IsUnitGrouped(unitTag) = true for group, player, reticleover etc = shit, just want group
  -- return string.sub(unitTag, 0, 1) == 'g' and IsUnitGrouped("player")

  if unitTag and string.sub(unitTag, 0, 5) == "group" then
    return true
  end
  return false
end

function RF:sort(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function RF:ticksToTime(ticks)
  local temp = os.date("*t", ticks)
  local HH = temp.hour < 10 and "0" .. temp.hour or temp.hour
  local MM = temp.min < 10 and "0" .. temp.min or temp.min
  local SS = temp.sec < 10 and "0" .. temp.sec or temp.sec
  return HH .. ":" .. MM .. ":" .. SS
end

--  ZO_CommaDelimitNumber
-- damageControl:SetText(zo_strformat(SI_NUMBER_FORMAT, ZO_CommaDelimitNumber(attackInfo.attackDamage)))
function RF:CommaNumber(number)

  local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')

  -- reverse the int-string and append a comma to all blocks of 3 digits
  int = int:reverse():gsub("(%d%d%d)", "%1,")

  -- reverse the int-string back remove an optional comma and put the
  -- optional minus and fractional part back
  return minus .. int:reverse():gsub("^,", "") .. fraction
end