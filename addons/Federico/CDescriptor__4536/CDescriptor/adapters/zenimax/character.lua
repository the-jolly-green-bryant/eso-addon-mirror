CDescriptor = CDescriptor or {}
local CDescriptor = CDescriptor

CDescriptor.Adapters = CDescriptor.Adapters or {}

local GetUnitName           = GetUnitName
local GetUnitClass          = GetUnitClass
local GetUnitRace           = GetUnitRace
local GetUnitLevel          = GetUnitLevel
local GetUnitChampionPoints = GetUnitChampionPoints

local M = {}

function M.get_info()
  return {
    name             = GetUnitName("player"),
    class            = GetUnitClass("player"),
    race             = GetUnitRace("player"),
    level            = GetUnitLevel("player"),
    champion_points  = GetUnitChampionPoints("player"),
  }
end

CDescriptor.Adapters.Character = M
