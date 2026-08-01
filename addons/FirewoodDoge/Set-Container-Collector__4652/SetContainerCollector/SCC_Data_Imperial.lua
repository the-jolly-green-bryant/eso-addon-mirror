SetContainerCollector = SetContainerCollector or {}
local SCC = SetContainerCollector
SCC.Data = SCC.Data or {}

local R = SCC.Data.RegisterSet
local SHOULDER = EQUIP_TYPE_SHOULDERS

-- Source: https://en.uesp.net/wiki/Online:Tel_Var_Grand_Armorers
local TELVAR_GEAR = {
  { 212380, 117643, "Black Rose", 179 },
  { 212381, 117644, "Meritorious Service", 181 },
  { 212382, 117645, "Phoenix", 200 },
  { 212383, 117646, "Powerful Assault", 180 },
  { 212384, 117647, "Reactive Armor", 201 },
  { 212385, 117648, "Shield Breaker", 199 },
  { 212386, 117649, "Galerion's Revenge", 246 },
  { 212387, 117650, "Imperial Physique", 253 },
  { 212388, 117651, "Thews of the Harbinger", 248 },
  { 212389, 117652, "Vicecanon of Venom", 247 },
}

for _, entry in ipairs(TELVAR_GEAR) do
  local unidentifiedId, curatedId, setName, setId = entry[1], entry[2], entry[3], entry[4]
  R(unidentifiedId, "Unidentified " .. setName .. " Item", setId)
  R(curatedId, "Curated " .. setName .. " Item", setId)
end

local TELVAR_MONSTER_COFFERS = {
  { 175803, "Curated Glorgoloch the Destroyer Coffer", 600 },
  { 175804, "Curated Immolator Charr Coffer", 599 },
  { 175913, "Curated Zoal the Ever-Wakeful Coffer", 598 },
  { 184116, "Curated Nunatak Coffer", 634 },
  { 184117, "Curated Lady Malygda Coffer", 635 },
  { 184118, "Curated Baron Thirsk Coffer", 636 },
}

for _, entry in ipairs(TELVAR_MONSTER_COFFERS) do
  R(entry[1], entry[2], entry[3], SHOULDER)
end
