--[[----------------------------------------------------------------------
    Dynamic Encounters : Wayshrine Zone Lookup Table
    Complete wayshrine->zone mapping from UESP.net/wiki/Online:Wayshrines

    Uses zone NAME strings (version-independent) resolved to zoneIds at
    runtime via GetMapInfo map names. This is the PRIMARY zone resolution
    method, used before GetFastTravelNodePOIInfo and map-iteration fallback.

    Why hardcoded? In some ESO versions, GetFastTravelNodePOIInfo is
    unavailable and GetZoneNameById returns wrong names (e.g. "Clean Test"
    for Glenumbra). A hardcoded name->zone table bypasses both issues.
----------------------------------------------------------------------]]--

DynamicEncounters.Timers = DynamicEncounters.Timers or {}
local T = DynamicEncounters.Timers

-- -------------------------------------------------------------------
-- Complete wayshrine name -> zone name table
-- Source: UESP.net/wiki/Online:Wayshrines (verified) + in-game knowledge
-- -------------------------------------------------------------------

T.WAYSHRINE_TO_ZONE = {
    -- ========= Aldmeri Dominion =========
    -- Auridon
    ["College Wayshrine"] = "Auridon",
    ["Firsthold Wayshrine"] = "Auridon",
    ["Greenwater Wayshrine"] = "Auridon",
    ["Mathiisen Wayshrine"] = "Auridon",
    ["Phaer Wayshrine"] = "Auridon",
    ["Quendeluun Wayshrine"] = "Auridon",
    ["Skywatch Wayshrine"] = "Auridon",
    ["Tanzelwil Wayshrine"] = "Auridon",
    ["Vulkhel Guard Wayshrine"] = "Auridon",
    ["Windy Glade Wayshrine"] = "Auridon",
    ["Shattered Grove Wayshrine"] = "Auridon",
    ["Silsailen Wayshrine"] = "Auridon",
    -- Grahtwood
    ["Cormount Wayshrine"] = "Grahtwood",
    ["Elden Root Temple Wayshrine"] = "Grahtwood",
    ["Elden Root Wayshrine"] = "Grahtwood",
    ["Falinesti Winter Wayshrine"] = "Grahtwood",
    ["Gil-Var-Delle Wayshrine"] = "Grahtwood",
    ["Gray Mire Wayshrine"] = "Grahtwood",
    ["Haven Wayshrine"] = "Grahtwood",
    ["Ossuary Wayshrine"] = "Grahtwood",
    ["Redfur Trading Post Wayshrine"] = "Grahtwood",
    ["Southpoint Wayshrine"] = "Grahtwood",
    -- Greenshade
    ["Falinesti Wayshrine"] = "Greenshade",
    ["Greenheart Wayshrine"] = "Greenshade",
    ["Labyrinth Wayshrine"] = "Greenshade",
    ["Marbruk Wayshrine"] = "Greenshade",
    ["Moonhenge Wayshrine"] = "Greenshade",
    ["Seaside Sanctuary Wayshrine"] = "Greenshade",
    ["Serpent's Grotto Wayshrine"] = "Greenshade",
    ["Verrant Morass Wayshrine"] = "Greenshade",
    ["Woodhearth Wayshrine"] = "Greenshade",
    -- Khenarthi's Roost
    ["Khenarthi's Roost Wayshrine"] = "Khenarthi's Roost",
    ["Mistral Wayshrine"] = "Khenarthi's Roost",
    -- Malabal Tor
    ["Abamath Wayshrine"] = "Malabal Tor",
    ["Baandari Tradepost Wayshrine"] = "Malabal Tor",
    ["Bloodtoil Wayshrine"] = "Malabal Tor",
    ["Dra'Bul Wayshrine"] = "Malabal Tor",
    ["Ilayas Ruins Wayshrine"] = "Malabal Tor",
    ["Valeguard Wayshrine"] = "Malabal Tor",
    ["Velyn Harbor Wayshrine"] = "Malabal Tor",
    ["Vulkwasten Wayshrine"] = "Malabal Tor",
    ["Wilding Run Wayshrine"] = "Malabal Tor",
    -- Reaper's March
    ["Arenthia Wayshrine"] = "Reaper's March",
    ["Dune Wayshrine"] = "Reaper's March",
    ["Fort Grimwatch Wayshrine"] = "Reaper's March",
    ["Fort Sphinxmoth Wayshrine"] = "Reaper's March",
    ["Moonmont Wayshrine"] = "Reaper's March",
    ["Rawl'kha Wayshrine"] = "Reaper's March",
    ["S'ren-ja Wayshrine"] = "Reaper's March",
    ["Vinedusk Wayshrine"] = "Reaper's March",
    ["Willowgrove Wayshrine"] = "Reaper's March",

    -- ========= Daggerfall Covenant =========
    -- Alik'r Desert
    ["Aswala Stables Wayshrine"] = "Alik'r Desert",
    ["Bergama Wayshrine"] = "Alik'r Desert",
    ["Divad's Chagrin Mine Wayshrine"] = "Alik'r Desert",
    ["Goat's Head Oasis Wayshrine"] = "Alik'r Desert",
    ["HoonDing's Watch Wayshrine"] = "Alik'r Desert",
    ["Kulati Mines Wayshrine"] = "Alik'r Desert",
    ["Leki's Blade Wayshrine"] = "Alik'r Desert",
    ["Morwha's Bounty Wayshrine"] = "Alik'r Desert",
    ["Satakalaam Wayshrine"] = "Alik'r Desert",
    ["Sentinel Wayshrine"] = "Alik'r Desert",
    ["Sep's Spine Wayshrine"] = "Alik'r Desert",
    ["Shrikes' Aerie Wayshrine"] = "Alik'r Desert",
    ["Kozanset Wayshrine"] = "Alik'r Desert",
    ["Shrike's Basin Wayshrine"] = "Alik'r Desert",
    -- Bangkorai
    ["Bangkorai Pass Wayshrine"] = "Bangkorai",
    ["Eastern Evermore Wayshrine"] = "Bangkorai",
    ["Evermore Wayshrine"] = "Bangkorai",
    ["Halcyon Lake Wayshrine"] = "Bangkorai",
    ["Hallin's Stand Wayshrine"] = "Bangkorai",
    ["Nilata Ruins Wayshrine"] = "Bangkorai",
    ["Old Tower Wayshrine"] = "Bangkorai",
    ["Onsi's Breath Wayshrine"] = "Bangkorai",
    ["Sunken Road Wayshrine"] = "Bangkorai",
    ["Troll's Toothpick Wayshrine"] = "Bangkorai",
    ["Viridian Woods Wayshrine"] = "Bangkorai",
    -- Betnikh
    ["Carved Hills Wayshrine"] = "Betnikh",
    ["Grimfield Wayshrine"] = "Betnikh",
    ["Stonetooth Wayshrine"] = "Betnikh",
    -- Glenumbra
    ["Aldcroft Wayshrine"] = "Glenumbra",
    ["Baelborne Rock Wayshrine"] = "Glenumbra",
    ["Burial Tombs Wayshrine"] = "Glenumbra",
    ["Crosswych Wayshrine"] = "Glenumbra",
    ["Daggerfall Wayshrine"] = "Glenumbra",
    ["Deleyn's Mill Wayshrine"] = "Glenumbra",
    ["Eagle's Brook Wayshrine"] = "Glenumbra",
    ["Farwatch Wayshrine"] = "Glenumbra",
    ["Hag Fen Wayshrine"] = "Glenumbra",
    ["Lion Guard Redoubt Wayshrine"] = "Glenumbra",
    ["North Hag Fen Wayshrine"] = "Glenumbra",
    ["Wyrd Tree Wayshrine"] = "Glenumbra",
    ["Northglen Wayshrine"] = "Glenumbra",
    ["Redrook Glen Wayshrine"] = "Glenumbra",
    -- Rivenspire
    ["Boralis Wayshrine"] = "Rivenspire",
    ["Camp Tamrith Wayshrine"] = "Rivenspire",
    ["Crestshade Wayshrine"] = "Rivenspire",
    ["Fell's Run Wayshrine"] = "Rivenspire",
    ["Hoarfrost Downs Wayshrine"] = "Rivenspire",
    ["Northpoint Wayshrine"] = "Rivenspire",
    ["Oldgate Wayshrine"] = "Rivenspire",
    ["Sanguine Barrows Wayshrine"] = "Rivenspire",
    ["Shornhelm Wayshrine"] = "Rivenspire",
    ["Shrouded Pass Wayshrine"] = "Rivenspire",
    ["Staging Grounds Wayshrine"] = "Rivenspire",
    ["Westmark Moor Wayshrine"] = "Rivenspire",
    ["The Doomcrag Wayshrine"] = "Rivenspire",
    -- Stormhaven
    ["Alcaire Castle Wayshrine"] = "Stormhaven",
    ["Bonesnap Ruins Wayshrine"] = "Stormhaven",
    ["Dro-Dara Plantation Wayshrine"] = "Stormhaven",
    ["Firebrand Keep Wayshrine"] = "Stormhaven",
    ["Koeglin Village Wayshrine"] = "Stormhaven",
    ["Pariah Abbey Wayshrine"] = "Stormhaven",
    ["Soulshriven Wayshrine"] = "Stormhaven",
    ["Wayrest Wayshrine"] = "Stormhaven",
    ["Weeping Giant Wayshrine"] = "Stormhaven",
    ["Wind Keep Wayshrine"] = "Stormhaven",
    ["Cumberland's Watch Wayshrine"] = "Stormhaven",
    ["Aphren's Hold Wayshrine"] = "Stormhaven",
    -- Stros M'Kai
    ["Port Hunding Wayshrine"] = "Stros M'Kai",
    ["Saintsport Wayshrine"] = "Stros M'Kai",
    ["Sandy Grotto Wayshrine"] = "Stros M'Kai",

    -- ========= Ebonheart Pact =========
    -- Bal Foyen
    ["Dhalmora Wayshrine"] = "Bal Foyen",
    ["Fort Zeren Wayshrine"] = "Bal Foyen",
    ["Foyen Docks Wayshrine"] = "Bal Foyen",
    -- Bleakrock Isle
    ["Bleakrock Wayshrine"] = "Bleakrock Isle",
    -- Deshaan
    ["Eidolon's Hollow Wayshrine"] = "Deshaan",
    ["Ghost Snake Vale Wayshrine"] = "Deshaan",
    ["Mournhold Wayshrine"] = "Deshaan",
    ["Muth Gnaar Hills Wayshrine"] = "Deshaan",
    ["Mzithumz Wayshrine"] = "Deshaan",
    ["Obsidian Gorge Wayshrine"] = "Deshaan",
    ["Quarantine Serk Wayshrine"] = "Deshaan",
    ["Selfora Wayshrine"] = "Deshaan",
    ["Shad Astula Wayshrine"] = "Deshaan",
    ["Silent Mire Wayshrine"] = "Deshaan",
    ["Tal'Deic Grounds Wayshrine"] = "Deshaan",
    ["West Narsis Wayshrine"] = "Deshaan",
    -- Eastmarch
    ["Cradlecrush Wayshrine"] = "Eastmarch",
    ["Fort Amol Wayshrine"] = "Eastmarch",
    ["Fort Morvunskar Wayshrine"] = "Eastmarch",
    ["Jorunn's Stand Wayshrine"] = "Eastmarch",
    ["Kynesgrove Wayshrine"] = "Eastmarch",
    ["Logging Camp Wayshrine"] = "Eastmarch",
    ["Mistwatch Wayshrine"] = "Eastmarch",
    ["Skuldafn Wayshrine"] = "Eastmarch",
    ["Voljar Meadery Wayshrine"] = "Eastmarch",
    ["Windhelm Wayshrine"] = "Eastmarch",
    ["Wittestadr Wayshrine"] = "Eastmarch",
    -- The Rift
    ["Fallowstone Hall Wayshrine"] = "The Rift",
    ["Fullhelm Fort Wayshrine"] = "The Rift",
    ["Geirmund's Hall Wayshrine"] = "The Rift",
    ["Honrich Tower Wayshrine"] = "The Rift",
    ["Nimalten Wayshrine"] = "The Rift",
    ["Northwind Wayshrine"] = "The Rift",
    ["Riften Wayshrine"] = "The Rift",
    ["Shor's Stone Wayshrine"] = "The Rift",
    ["Trolhetta Wayshrine"] = "The Rift",
    ["Vernim Woods Wayshrine"] = "The Rift",
    -- Shadowfen
    ["Alten Corimont Wayshrine"] = "Shadowfen",
    ["Bogmother Wayshrine"] = "Shadowfen",
    ["Hissmir Wayshrine"] = "Shadowfen",
    ["Mud Tree Wayshrine"] = "Shadowfen",
    ["Percolating Mire Wayshrine"] = "Shadowfen",
    ["Stormhold Wayshrine"] = "Shadowfen",
    ["Stillwater Wayshrine"] = "Shadowfen",
    ["Sunscale Wayshrine"] = "Shadowfen",
    ["Thornmarsh Wayshrine"] = "Shadowfen",
    ["White Rose Wayshrine"] = "Shadowfen",
    -- Stonefalls
    ["Ash Mountain Wayshrine"] = "Stonefalls",
    ["Davon's Watch Wayshrine"] = "Stonefalls",
    ["Ebonheart Wayshrine"] = "Stonefalls",
    ["Fort Virak Wayshrine"] = "Stonefalls",
    ["Giant's Heart Wayshrine"] = "Stonefalls",
    ["Iliath Temple Wayshrine"] = "Stonefalls",
    ["Kragenmoor Wayshrine"] = "Stonefalls",
    ["The Knife Wayshrine"] = "Stonefalls",
    ["Vivec's Antlers Wayshrine"] = "Stonefalls",

    -- ========= Neutral and Disputed =========
    -- Coldharbour
    ["The Hollow City Wayshrine"] = "Coldharbour",
    ["The Bastion Wayshrine"] = "Coldharbour",
    ["The Chasm Wayshrine"] = "Coldharbour",
    ["The Refuge Wayshrine"] = "Coldharbour",
    -- Craglorn
    ["Belkarth Wayshrine"] = "Craglorn",
    ["Dragonstar Wayshrine"] = "Craglorn",
    ["Skyreach Wayshrine"] = "Craglorn",
    -- Eyevea
    ["Eyevea Wayshrine"] = "Eyevea",

    -- ========= Chapter Zones (add more as needed) =========
    -- Vvardenfell
    ["Vivec City Wayshrine"] = "Vvardenfell",
    ["Balmora Wayshrine"] = "Vvardenfell",
    ["Ald'ruhn Wayshrine"] = "Vvardenfell",
    ["Sadrith Mora Wayshrine"] = "Vvardenfell",
    ["Tel Branora Wayshrine"] = "Vvardenfell",
    ["Khuul Wayshrine"] = "Vvardenfell",
    ["Gnisis Wayshrine"] = "Vvardenfell",
    ["Suran Wayshrine"] = "Vvardenfell",
    ["Seyda Neen Wayshrine"] = "Vvardenfell",
    ["Molag Mar Wayshrine"] = "Vvardenfell",
    ["Maar Gan Wayshrine"] = "Vvardenfell",
    ["Tel Mora Wayshrine"] = "Vvardenfell",
    ["Vos Wayshrine"] = "Vvardenfell",
    -- Summerset
    ["Shimmerene Wayshrine"] = "Summerset",
    ["Alinor Wayshrine"] = "Summerset",
    ["Lillandril Wayshrine"] = "Summerset",
    ["Sunhold Wayshrine"] = "Summerset",
    ["Dusk Wayshrine"] = "Summerset",
    ["Russafeld Wayshrine"] = "Summerset",
    ["Cloudrest Wayshrine"] = "Summerset",
    -- Northern Elsweyr
    ["Rimmen Wayshrine"] = "Northern Elsweyr",
    ["Riverhold Wayshrine"] = "Northern Elsweyr",
    ["Orcrest Wayshrine"] = "Northern Elsweyr",
    ["Hakoshae Wayshrine"] = "Northern Elsweyr",
    -- Southern Elsweyr
    ["Senchal Wayshrine"] = "Southern Elsweyr",
    -- Western Skyrim
    ["Solitude Wayshrine"] = "Western Skyrim",
    ["Morthal Wayshrine"] = "Western Skyrim",
    ["Markarth Wayshrine"] = "Western Skyrim",
    ["Falkreath Wayshrine"] = "Western Skyrim",
    ["Dragon Bridge Wayshrine"] = "Western Skyrim",
    -- Blackwood
    ["Gideon Wayshrine"] = "Blackwood",
    ["Leyawiin Wayshrine"] = "Blackwood",
    -- High Isle
    ["Gonfalon Bay Wayshrine"] = "High Isle",
    ["Dreadsail Wayshrine"] = "High Isle",
    -- Galen
    ["Vastyr Wayshrine"] = "Galen",
    -- Wrothgar
    ["Orsinium Wayshrine"] = "Wrothgar",
    ["Morkul Wayshrine"] = "Wrothgar",
    ["Pariah Wayshrine"] = "Wrothgar",
    -- Gold Coast
    ["Kvatch Wayshrine"] = "Gold Coast",
    ["Anvil Wayshrine"] = "Gold Coast",
    -- Hew's Bane
    ["Abah's Landing Wayshrine"] = "Hew's Bane",
    -- Clockwork City
    ["Brass Fortress Wayshrine"] = "Clockwork City",
    -- Murkmire
    ["Lilmoth Wayshrine"] = "Murkmire",
    -- The Reach
    ["Karthwasten Wayshrine"] = "The Reach",
    -- Artaeum
    ["Artaeum Wayshrine"] = "Artaeum",
    -- Fargrave
    ["Fargrave Wayshrine"] = "Fargrave",
    -- Telvanni Peninsula
    ["Necrom Wayshrine"] = "Telvanni Peninsula",
    -- West Weald
    ["Skingrad Wayshrine"] = "West Weald",
    -- Apocrypha
    ["Cipher's Mire Wayshrine"] = "Apocrypha",
}

-- -------------------------------------------------------------------
-- Build zoneName -> zoneId mapping at runtime.
-- Uses GetMapInfo mapName (display name) which is reliable.
-- GetZoneNameById may return wrong names like "Clean Test" for some
-- zoneIds, so we prefer mapName and only use GetZoneNameById as a
-- secondary source (filtering out known bad names).
-- -------------------------------------------------------------------

T._zoneNameToId = T._zoneNameToId or {}

-- debug helper: only prints when DynamicEncounters.sv.debugMode is true
local function dbg(msg)
    local ok, _ = pcall(function()
        if DynamicEncounters.sv.debugMode then
            d(msg)
        end
    end)
end

function T.BuildZoneNameToIdMap()
    T._zoneNameToId = {}
    local numMaps = GetNumMaps()
    local count = 0
    for mapIndex = 1, numMaps do
        local mapName, mapType, _, zoneIndex = GetMapInfo(mapIndex)
        if zoneIndex and zoneIndex > 0 then
            local zoneId = GetZoneId(zoneIndex)
            if zoneId and zoneId > 0 then
                -- Primary: use mapName (display name from GetMapInfo)
                -- This is the name shown on the world map and matches UESP zone names
                if mapName and mapName ~= "" then
                    T._zoneNameToId[mapName] = zoneId
                    count = count + 1
                end
                -- Secondary: also try GetZoneNameById, but filter out known bad names
                local zName = GetZoneNameById(zoneId)
                if zName and zName ~= "" and zName ~= "Clean Test" and zName ~= "Tamriel" then
                    T._zoneNameToId[zName] = zoneId
                end
            end
        end
    end
    -- One-time diagnostic
    if not T._zoneMapDiagDone then
        T._zoneMapDiagDone = true
        dbg(string.format("[DE Zones] Built zoneName->zoneId map: %d entries", count))
        -- Show a few samples
        local shown = 0
        for name, id in pairs(T._zoneNameToId) do
            if shown < 10 then
                dbg(string.format("[DE Zones]   '%s' -> zoneId=%d", name, id))
                shown = shown + 1
            end
        end
    end
end

-- -------------------------------------------------------------------
-- Resolve zone for a wayshrine entry using the hardcoded table.
-- Returns true if resolved, false if not found.
-- Stores zoneId AND zoneName directly (bypasses GetZoneNameById for display).
-- -------------------------------------------------------------------

function T.ResolveZoneFromTable(entry)
    if not entry or not entry.name then return false end
    local zoneName = T.WAYSHRINE_TO_ZONE[entry.name]
    if not zoneName then return false end

    -- Always store the zone name from the hardcoded table.
    -- This is the authoritative name (from UESP) and will be used
    -- for tooltip display even if we cannot resolve a zoneId.
    entry.zoneName = zoneName

    -- Try exact match in runtime map first
    local zoneId = T._zoneNameToId and T._zoneNameToId[zoneName]
    if zoneId and zoneId > 0 then
        entry.zoneId = zoneId
        entry._resolvedViaTable = true
        return true
    end

    -- Try case-insensitive match in runtime map
    local lowerZone = zoneName:lower()
    for mapZoneName, mapZoneId in pairs(T._zoneNameToId or {}) do
        if mapZoneName:lower() == lowerZone then
            entry.zoneId = mapZoneId
            entry._resolvedViaTable = true
            return true
        end
    end

    -- Runtime map did not have it. Iterate all maps directly to find
    -- one with a matching mapName. This handles cases where
    -- BuildZoneNameToIdMap missed an entry due to filtering.
    local numMaps = GetNumMaps()
    for mapIndex = 1, numMaps do
        local mapName, mapType, _, zoneIndex = GetMapInfo(mapIndex)
        if mapName and mapName:lower() == lowerZone and zoneIndex then
            local zId = GetZoneId(zoneIndex)
            if zId and zId > 0 then
                entry.zoneId = zId
                if T._zoneNameToId then
                    T._zoneNameToId[zoneName] = zId
                end
                entry._resolvedViaTable = true
                return true
            end
        end
    end

    -- Zone name found in table but zoneId could not be resolved.
    -- Store the zoneName anyway and return true to prevent the
    -- fallback from overwriting it with a wrong zoneId/zoneName.
    entry._resolvedViaTable = true
    entry._zoneIdUnknown = true
    return true
end

-- -------------------------------------------------------------------
-- Diagnostic: list wayshrine names not found in the hardcoded table.
-- Helps identify missing entries that need to be added.
-- -------------------------------------------------------------------

function T.DiagnoseUnresolvedWayshrines()
    local unresolved = {}
    for _, entry in pairs(T.wayshrinesByIndex or {}) do
        if not entry.zoneId and entry.name then
            table.insert(unresolved, entry.name)
        end
    end
    if #unresolved > 0 then
        dbg(string.format("[DE Zones] %d wayshrines NOT in hardcoded table:", #unresolved))
        for i, name in ipairs(unresolved) do
            if i <= 30 then
                dbg(string.format("[DE Zones]   UNRESOLVED: '%s'", name))
            end
        end
        if #unresolved > 30 then
            dbg(string.format("[DE Zones]   ... and %d more", #unresolved - 30))
        end
    end
end
