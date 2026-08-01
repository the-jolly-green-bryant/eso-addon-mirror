--[[
-------------------------------------------------------------------------------
-- LoreBooks
-------------------------------------------------------------------------------
-- Original author: Ales Machat (Garkin), started 2014-04-18
--
-- Maintainers:
--    Ayantir (contributions starting 2015-11-07)
--    Kyoma (contributions starting 2018-05-30)
--    Sharlikran (current maintainer, contributions starting 2022-11-12)
--
-------------------------------------------------------------------------------
-- This addon includes contributions licensed under two Creative Commons licenses
-- and the original MIT license:
--
-- MIT License (Garkin, 2014–2015):
--   Permission is hereby granted, free of charge, to any person obtaining a copy
--   of this software and associated documentation files (the "Software"), to deal
--   in the Software without restriction, including without limitation the rights
--   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--   copies of the Software, and to permit persons to whom the Software is
--   furnished to do so, subject to the conditions in the LICENSE file.
--
-- Creative Commons BY-NC-SA 4.0 (Ayantir, 2015–2020 and Sharlikran, 2022–present):
--   You are free to share and adapt the material with attribution, but not for
--   commercial purposes. Derivatives must be licensed under the same terms.
--   Full terms at: https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode
--
-------------------------------------------------------------------------------
-- Maintainer Notice:
-- Redistribution of this addon outside of ESOUI.com or GitHub is discouraged
-- unless authorized by the current maintainer. While the original MIT license
-- permits wide redistribution, uncoordinated uploads may cause version
-- fragmentation or confusion. Please respect the intent of the maintainers and
-- the ESO addon ecosystem.
-- ----------------------------------------------------------------------------
-- Data Integrity and Attribution Notice:
-- While individual book positions are discoverable via the ESO API, the
-- comprehensive dataset included in LoreBooks is the result of years of
-- community effort and contributions from multiple players. Recreating this
-- dataset independently requires extensive time and dedication.
--
-- Direct reuse, extraction, or redistribution of the compiled data tables,
-- either in whole or substantial part, without permission from the current
-- maintainer, is prohibited. Claiming ownership or sole authorship over
-- derived works that include this dataset is considered a violation of the
-- contributors' efforts and the licenses under which this project is shared.
--
-- If you wish to use this data in your own addon or tool, please contact the
-- current maintainer for appropriate guidance and permission.
-- ----------------------------------------------------------------------------
]]
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


