KC_Fn = {}
-- ========================================
-- Accessor values
local Kills = 1
local KillingBlows = 2
local Avenge_Kills = 3
local Revent_Kills = 4
local Alliance = 5
local vLevel = 6
local Name = 7
local Level = 8
local Class = 9
local KilledBy = 10
-- ========================================

-- Count the number of times a value occurs in a table
function KC_Fn.table_count(tt, item)
    local count
    count = 0
    for ii, xx in pairs(tt) do if item == xx then count = count + 1 end end
    return count
end

function KC_Fn.tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function KC_Fn.table_find(t, value)
    for k, v in pairs(t) do if v == value then return k end end
    return nil
end

function KC_Fn.table_shallow_copy(t)
    local t2 = {}
    for k, v in pairs(t) do t2[k] = v end
    return t2
end

function KC_Fn.table_randFrom(t)
    local choice = "F"
    local n = 0
    for i, o in pairs(t) do
        n = n + 1
        if math.random() < (1 / n) then choice = o end
    end
    return choice
end

-- Remove duplicates from a table array (doesn't currently work
-- on key-value tables)
function KC_Fn.table_unique(tt)
    local newtable
    newtable = {}
    for ii, xx in ipairs(tt) do
        if (table_count(newtable, xx) == 0) then
            newtable[#newtable + 1] = xx
        end
    end
    return newtable
end

function KC_Fn.Alliance_From_Id(id, color)
    color = color or false
    local alli = ""
    local colorcode = ""
    if id == ALLIANCE_EBONHEART_PACT then
        alli = "Ebonheart Pact"
        colorcode = "|C990000"
    elseif id == ALLIANCE_ALDMERI_DOMINION then
        alli = "Aldmeri Dominion"
        colorcode = "|CFFCC00"
    elseif id == ALLIANCE_DAGGERFALL_COVENANT then
        alli = "Daggerfall Covenant"
        colorcode = "|C0066ff"
    else
        return "|CA9A9A9Duel"
    end

    return colorcode .. alli .. "|r"
end

function KC_Fn.Colored_Alliance_From_Id(id)
    if id == ALLIANCE_EBONHEART_PACT or id == "Ebonheart Pact" then
        return "|C990000EP"
    elseif id == ALLIANCE_ALDMERI_DOMINION or id == "Aldmeri Dominion" then
        return "|CFFCC00AD"
    elseif id == ALLIANCE_DAGGERFALL_COVENANT or id == "Daggerfall Covenant" then
        return "|C0066ffDC"
    else
        return "|CA9A9A9Duel"
    end
end

function KC_Fn.Alliance_Color(id)
    if id == ALLIANCE_EBONHEART_PACT or id == "Ebonheart Pact" then
        return "|C990000"
    elseif id == ALLIANCE_ALDMERI_DOMINION or id == "Aldmeri Dominion" then
        return "|CFFCC00"
    elseif id == ALLIANCE_DAGGERFALL_COVENANT or id == "Daggerfall Covenant" then
        return "|C0066ff"
    else
        return "|Ccccccc"
    end
end

function KC_Fn.string_split(string, pattern)
    pattern = pattern or "%S+"
    local array = {}
    for i in string.gmatch(string, pattern) do table.insert(array, i) end
    return array
end

function KC_Fn.string_trim(s) return (s:gsub("^%s*(.-)%s*$", "%1")) end

function KC_Fn.string_join(array, delim)
    delim = delim or " "
    str = ""
    for i in array do str = str .. i .. delim end
    str = KC_Fn.string_trim(str)
    return str
end

function KC_Fn.Alliance_Texture_From_Id(id)
    if id == ALLIANCE_EBONHEART_PACT then
        return "/esoui/art/guild/banner_ebonheart.dds"
    elseif id == ALLIANCE_ALDMERI_DOMINION then
        return "/esoui/art/guild/banner_aldmeri.dds"
    elseif id == ALLIANCE_DAGGERFALL_COVENANT then
        return "/esoui/art/guild/banner_daggerfall.dds"
    else
        return "No One"
    end
end

function KC_Fn.round(num, idp)
    local mult = 10 ^ (idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

function KC_Fn.ToggleSetting(setting)

    if KC_G.savedVars.settings[setting] ~= nil then
        KC_G.savedVars.settings[setting] = not KC_G.savedVars.settings[setting]
        return KC_G.savedVars.settings[setting]
    end

    return false

end

function KC_Fn.CheckSetting(setting)
    if KC_G == nil or KC_G.savedVars == nil or KC_G.savedVars.settings == nil then
        return true
    end
    if KC_G.savedVars.settings[setting] ~= nil then
        return KC_G.savedVars.settings[setting]
    else
        return true
    end
end

function KC_Fn.spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys + 1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys
    if order then
        table.sort(keys, function(a, b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then return keys[i], t[keys[i]] end
    end
end

function KC_Fn.ThreatLevel(ratio)
    if ratio < .5 then
        return "|C850000"
    elseif ratio < 1 then
        return "|Cff0000"
    elseif ratio < 2 then
        return "|Cffff00"
    elseif ratio < 3 then
        return "|C9DFF00"
    elseif ratio < 5 then
        return "|C00FF00"
    else
        return "|C00FF80"
    end
end

function KC_Fn.ThreatLevelText(ratio)
    if ratio < .5 then
        return "Big Danger"
    elseif ratio < 1 then
        return "Threat"
    elseif ratio < 2 then
        return "Even Match"
    elseif ratio < 3 then
        return "Good Odds"
    elseif ratio < 5 then
        return "Easy Pickin's"
    else
        return "On Farm"
    end
end

function KC_Fn.KBLevel(ratio)
    if ratio < .05 then
        return "|C52FFBFHealer|r"
    elseif ratio < .2 then
        return "|C13A600Assistant|r"
    elseif ratio < .3 then
        return "|CD97025Killer|r"
    elseif ratio < .5 then
        return "|CFF0000Blood Drinker|r"
    elseif ratio < .8 then
        return "|C690000Reaper|r"
    else
        return "|C1F0000Angel of Death|r"
    end
end

-- ]]
-- returns an updated version of the saved data based on a previous save. No guarentees everything from before version 2.0.0 will work
-- but any saved vars after updated 2.0.0 should no longer need to be updated.
--[[
function KC_Fn.updateSaved(currentSaved, updatedFormat, innerFormats)
  ---create copy of updated format
  local t = KC_Fn.table_shallow_copy(updatedFormat)
  if updatedFormat.SC ~= nil then
    t.SC = KC_Fn.table_shallow_copy(updatedFormat.SC)
  end
  --local i = 0
  if currentSaved == nil or type(currentSaved) ~= "table" then return t end
  ---go through the updated format
  for key, value in pairs(updatedFormat) do
    --check if this key exists in old table
    if currentSaved[key] ~= nil and type(currentSaved[key]) ==  type(value) then
      --exists and same type. check if its a table
      if type(value) == "table" then
        --its a table. 
        if KC_Fn.tablelength(value) > 0 then
          --default empty table. Usually means theres an innerformat.  check innerFormats array
          if innerFormats[key] ~= nil then
            --we have one, use this format for each of the player kills in currentSaved
            for ikey, ival in pairs(currentSaved[key]) do
              t[key][ikey] = KC_Fn.updatedSaved(ival, innerFormats[key])
            end
          else
            --there isnt one. just use the default value
            t[key] = value
          end
        else
          --non empty default table. means stats like seige call this function recursively using value as format
          t[key] = KC_Fn.updateSaved(currentSaved[key], value)
        end
      else
        --not a table, just set the table key to the current saved one
        t[key] = currentSaved[key]
      end
    end
  end

  return t

end
--]]
