-- FurnitureFinderData.lua
--
-- Lookup table keyed by itemId (from GetItemLinkItemId on a furnishing link).
-- This file is meant to be GENERATED, not hand-written -- see build_data.py
-- for a CSV -> Lua converter. The entries below are placeholders only, to
-- document the schema and let you test the addon before you have real data.
--
-- Schema per entry:
--   source     (string) e.g. "Crafted: Woodworking", "Luxury Furnisher",
--              "Achievement Furnisher", "Crown Store", "Zone Guide Reward",
--              "Event: Witches Festival", "Antiquities", "Master Writ"
--   collection (string, optional) which furnishing collection / meta
--              achievement it counts toward, if any
--   notes      (string, optional) anything else worth surfacing

FurnitureFinder = FurnitureFinder or {}

FurnitureFinder.Data = {
    -- [itemId] = { source = "...", collection = "...", notes = "..." },

    -- PLACEHOLDER EXAMPLES -- replace via build_data.py, do not ship as-is
    [1] = {
        source = "Example: Crafted (Woodworking)",
        collection = "Example Collection Name",
        notes = "Placeholder entry -- confirm real itemId in-game with /script d(GetItemLinkItemId(...))",
    },
}

-- Simple accessor so the main addon file doesn't touch table internals directly
function FurnitureFinder.GetFurnitureData(itemId)
    if not itemId then return nil end
    return FurnitureFinder.Data[itemId]
end
