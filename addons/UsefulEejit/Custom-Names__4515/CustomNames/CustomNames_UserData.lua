-- CustomNames_UserData.lua
-- ============================================================
-- OFFLINE-EDITABLE name overrides for the CustomNames addon.
--
-- Edit this file while the game is CLOSED. On next login,
-- any entries here that don't already exist in your saved
-- settings will be imported automatically.
--
-- Entries already saved in-game (via the /cn settings panel)
-- are NOT overwritten by this file. This file is import-only.
--
-- HOW TO USE:
--   Add entries using: ["Original Name"] = "Custom Name",
--   Leave the custom name as "" to hide the label entirely.
--   Use /cnzone in-game to get the exact key string for zones.
--
-- TABLES:
--   zoneNames     — major zone names (world map, compass, wayshrines)
--   locationNames — POI pins, fast travel nodes, subzone alerts
--   npcNames      — nameplate text above NPCs
-- ============================================================

CustomNames_UserData = {

    zoneNames = {
        -- ["Grahtwood"]    = "Green Forest",
        -- ["Coldharbour"]  = "The Bad Place",
        -- Use <br> in the custom name to insert a line break on the map blob label:
        -- ["Reaper's March"] = "Reaper's<br>March",
    },

    -- Per-zone blob scale multipliers for the handwritten labels on the zoomed world map.
    -- Keys must match the ORIGINAL zone name (same key as in zoneNames above).
    -- 1.5 = 50% larger, 2.0 = double size, 0.75 = 25% smaller.
    -- Omit a zone entirely to leave it at its default size.
    zoneBlobScales = {
        -- ["Grahtwood"]   = 1.5,
        -- ["Coldharbour"] = 2.0,
    },

    locationNames = {
        -- ["Mournhold Plaza of the Gods"] = "Main Plaza",
        -- ["Reaper's March"] = "Cat Country",
    },

    npcNames = {
        -- ["Razum-dar"] = "Raz",
    },

    -- Quest-conditional NPC renames. Applied only after the quest is complete.
    -- Find quest IDs on UESP (https://en.uesp.net) or with addons like Destinations.
    npcQuestNames = {
        -- { original = "Guard", questId = 6250, custom = "Captain Rela" },
    },

}
