-- Runtime Arabic/English switches for names that live in ar.lang.
--
-- ar.lang is read once at start-up and cannot be swapped at runtime, so the
-- API functions that return these names are wrapped: when a switch is OFF
-- (English) and the returned shaped-Arabic name is known, the English original
-- is returned instead. Tables: sets_en.lua (SETS_EN, SET_ITEMS_EN) and
-- zones_en.lua (ZONES_EN). Covers everything drawn from Lua (gamepad
-- tooltips, lists, map, compass text); engine-drawn keyboard tooltips keep
-- the Arabic name.

local installed = false

local function lookup(tbl, name)
  if type(name) ~= "string" or not tbl then return nil end
  local base = name:match("^(.-)%^") or name
  return tbl[base]
end

local function mapSet(name)
  if not EsoAR.savedVars.englishSets then return name end
  return lookup(EsoAR.SETS_EN, name) or lookup(EsoAR.SET_ITEMS_EN, name) or name
end

local function mapZone(name)
  if not EsoAR.savedVars.englishZones then return name end
  return lookup(EsoAR.ZONES_EN, name) or name
end

local function wrap(globalName, index, mapper)
  local orig = _G[globalName]
  if type(orig) ~= "function" then return end
  if index == 1 then
    _G[globalName] = function(...) return mapper(orig(...)) end
  else
    _G[globalName] = function(...)
      local r = { orig(...) }
      r[index] = mapper(r[index])
      return unpack(r, 1, math.max(#r, index))
    end
  end
end

function EsoAR:InstallNameHooks()
  if installed then return end
  installed = true
  -- item sets / set pieces
  wrap("GetItemLinkSetInfo", 2, mapSet)            -- hasSet, setName, ...
  wrap("GetItemSetName", 1, mapSet)
  wrap("GetItemLinkName", 1, mapSet)
  wrap("GetItemName", 1, mapSet)
  wrap("GetItemLinkTradingHouseItemSearchName", 1, mapSet)
  -- zones / maps / locations
  wrap("GetZoneNameById", 1, mapZone)
  wrap("GetZoneNameByIndex", 1, mapZone)
  wrap("GetUnitZone", 1, mapZone)
  wrap("GetPlayerActiveZoneName", 1, mapZone)
  wrap("GetPlayerActiveSubzoneName", 1, mapZone)
  wrap("GetPlayerLocationName", 1, mapZone)
  wrap("GetMapName", 1, mapZone)
  wrap("GetMapNameById", 1, mapZone)
  wrap("GetMapInfoByIndex", 1, mapZone)            -- name, mapType, ...
  wrap("GetMapInfoById", 1, mapZone)
  wrap("GetPOIInfo", 1, mapZone)                   -- objectiveName, ...
  wrap("GetJournalQuestLocationInfo", 1, mapZone)  -- zoneName, ...
  wrap("GetFastTravelNodeInfo", 2, mapZone)        -- known, name, ...
end
