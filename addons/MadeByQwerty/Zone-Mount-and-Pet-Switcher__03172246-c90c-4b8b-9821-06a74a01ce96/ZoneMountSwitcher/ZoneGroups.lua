-- ZoneGroups.lua
ZMS = ZMS or {}

-- Clés canoniques des groupes
ZMS.GROUP_KEYS = {
  "NORDIC","TEMPERATE","COASTAL","FOREST","ARID","MARSH","VOLCANIC","OBLIVION"
}

-- Noms localisés pour l'affichage
local function GroupDisplayName(key)
  local map = {
    NORDIC    = "ZMS_GROUP_NORDIC",
    TEMPERATE = "ZMS_GROUP_TEMPERATE",
    COASTAL   = "ZMS_GROUP_COASTAL",
    FOREST    = "ZMS_GROUP_FOREST",
    ARID      = "ZMS_GROUP_ARID",
    MARSH     = "ZMS_GROUP_MARSH",
    VOLCANIC  = "ZMS_GROUP_VOLCANIC",
    OBLIVION  = "ZMS_GROUP_OBLIVION",
  }
  local id = map[key]
  if id then return GetString(_G[id]) end
  return key
end
ZMS.GroupDisplayName = GroupDisplayName

-- === Defaults pack ===
ZMS.DEFAULTS_VERSION = 1

ZMS.DEFAULT_ZONE_GROUPS = {
  NORDIC    = { 684, 1207, 1160, 103, 101, 280},
  TEMPERATE = { 3, 20, 19, 92, 1443, 823, 181, 643, 584},
  COASTAL   = { 1133, 1383, 1318, 1011, 537, 1502, 267, 1027},
  FOREST    = { 58, 108, 383, 535, 381},
  ARID      = { 104, 816, 888, 382, 1086, 534, 980},
  MARSH     = { 1261, 726, 117, 57},
  VOLCANIC  = { 1208, 1161, 1191, 1414, 281, 41, 849},
  OBLIVION  = { 1413, 347, 1282, 1283, 1286 },
}
