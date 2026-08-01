local internal = _G["LoreBooks_Internal"]
-- uses mapId for key, ZoneId for z to get texture
local bookshelfData = {
  [1940] = { -- u30_leyawiincity_base
    { ["x"] = 0.402493, ["y"] = 0.456695, ["z"] = 1261 },
    { ["x"] = 0.255003, ["y"] = 0.453110, ["z"] = 1261 },
    { ["x"] = 0.163941, ["y"] = 0.579486, ["z"] = 1261 },
  },
  [1887] = { -- blackwood_base
    { ["x"] = 0.213265, ["y"] = 0.545964, ["z"] = 1261 }, -- Nine Commands of the Eight Divines
  },
  [10] = { -- rivenspire_base
    { ["x"] = 0.715786, ["y"] = 0.488517, ["z"] = 20 },
  },
  [8] = { -- Bleakrock Village
    { ["x"] = 0.7958272099, ["y"] = 0.4694717824, ["z"] = 280, },
    { ["x"] = 0.7136975527, ["y"] = 0.2590188980, ["z"] = 280, },
  },
  [1288] = { -- Sadrith Mora
    { ["x"] = 0.6968059540, ["y"] = 0.6332955956, ["z"] = 849, },
    { ["x"] = 0.3771406114, ["y"] = 0.2950019538, ["z"] = 849, },
  },
  [605] = { -- Hazak's Lair
    { ["x"] = 0.6917211413, ["y"] = 0.8503540158, ["z"] = 537, },
  },
}

--Global API
function LoreBooks_GetBookshelfDataFromMapId(mapId)
  -- internal:dm("Info", "LoreBooks_GetBookshelfDataFromMapId")
  -- internal:dm("Info", mapId)
  if not bookshelfData or not bookshelfData[mapId] then
    return nil
  end
  -- internal:dm("Info", "Data Exists")
  return bookshelfData[mapId]
end


