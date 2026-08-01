-- =============================================================================
-- Motifs Tracker — Data Scanning v2.0.8
-- Scans the ESO API for motif styles (via achievements + style cross-ref)
-- with per-chapter completion status.
-- =============================================================================

KT_Data = {}
KT_Data._undauntedCache = nil
KT_Data._undauntedCacheAtMs = 0
KT_Data._undauntedCacheTtlMs = 300000
KT_Data._undauntedScanRunning = false
KT_Data._undauntedScanListeners = {}

-- ---------------------------------------------------------------------------
-- Constants
-- ---------------------------------------------------------------------------
KT_Data.CAT_MOTIF = 1

-- ═══════════════════════════════════════════════════════════════════════════
-- MOTIF NUMBER / SOURCE TABLES
-- ═══════════════════════════════════════════════════════════════════════════
-- Maps ESO internal style IDs (from the ITEMSTYLE enum, IDs 1-59) to the
-- player-facing Crafting Motif number and the zone/DLC where it drops.

local STYLE_TO_MOTIF = {
    -- Racial (Motifs 1-9)
    [7]  = { number = 1,  source = "Base Game" },         -- High Elf
    [4]  = { number = 2,  source = "Base Game" },         -- Dark Elf
    [8]  = { number = 3,  source = "Base Game" },         -- Wood Elf
    [5]  = { number = 4,  source = "Base Game" },         -- Nord
    [1]  = { number = 5,  source = "Base Game" },         -- Breton
    [2]  = { number = 6,  source = "Base Game" },         -- Redguard
    [9]  = { number = 7,  source = "Base Game" },         -- Khajiit
    [3]  = { number = 8,  source = "Base Game" },         -- Orc
    [6]  = { number = 9,  source = "Base Game" },         -- Argonian
    -- Classic rare (10-16)
    [34] = { number = 10, source = "Base Game" },         -- Imperial
    [15] = { number = 11, source = "Various" },           -- Ancient Elf
    [17] = { number = 12, source = "Various" },           -- Barbaric
    [19] = { number = 13, source = "Various" },           -- Primal
    [20] = { number = 14, source = "Various" },           -- Daedric
    [14] = { number = 15, source = "Dwemer Ruins" },      -- Dwemer
    [28] = { number = 16, source = "Various" },           -- Glass
    -- Cyrodiil / Imperial City
    [29] = { number = 17, source = "Imperial City" },     -- Xivkyn
    [33] = { number = 18, source = "Cyrodiil" },          -- Akaviri
    [26] = { number = 19, source = "Undaunted" },         -- Mercenary
    [35] = { number = 20, source = "Craglorn" },          -- Yokudan
    -- Wrothgar
    [22] = { number = 21, source = "Wrothgar" },          -- Ancient Orc
    [21] = { number = 22, source = "Wrothgar" },          -- Trinimac
    [13] = { number = 23, source = "Wrothgar" },          -- Malacath
    -- Thieves Guild / Dark Brotherhood era
    [47] = { number = 24, source = "Outlaws Refuge" },    -- Outlaw
    [25] = { number = 25, source = "Cyrodiil" },          -- Aldmeri Dominion
    [23] = { number = 26, source = "Cyrodiil" },          -- Daggerfall Covenant
    [24] = { number = 27, source = "Cyrodiil" },          -- Ebonheart Pact
    [44] = { number = 28, source = "Craglorn" },          -- Ra Gada
    [30] = { number = 29, source = "Coldharbour" },       -- Soul Shriven
    [43] = { number = 30, source = "Vvardenfell" },       -- Morag Tong
    [42] = { number = 31, source = "New Life Festival" }, -- Skinchanger
    [41] = { number = 32, source = "Hew's Bane" },       -- Abah's Watch
    [11] = { number = 33, source = "Thieves Guild" },     -- Thieves Guild
    [46] = { number = 34, source = "Gold Coast" },        -- Assassins League
    [45] = { number = 35, source = "Maw of Lorkhaj" },   -- Dro-m'Athra
    [12] = { number = 36, source = "Gold Coast" },        -- Dark Brotherhood
    [40] = { number = 37, source = "Writ Vouchers" },    -- Ebony
    [31] = { number = 38, source = "Guild Dailies" },    -- Draugr
    [39] = { number = 39, source = "Gold Coast" },        -- Minotaur
    [16] = { number = 40, source = "Gold Coast" },        -- Order of the Hour
    [27] = { number = 41, source = "Craglorn Trials" },  -- Celestial
    [59] = { number = 42, source = "Witches Festival" }, -- Hollowjack
    [58] = { number = 43, source = "Crown Store" },      -- Grim Harlequin
    [56] = { number = 44, source = "Cradle of Shadows" },-- Silken Ring
    [57] = { number = 45, source = "Ruins of Mazzatun" },-- Mazzatun
    [53] = { number = 46, source = "Crown Store" },      -- Frostcaster
    [52] = { number = 47, source = "Vvardenfell" },      -- Buoyant Armiger
    [54] = { number = 48, source = "Vvardenfell" },      -- Ashlander
    [55] = { number = 60, source = "White-Gold Tower" }, -- Worm Cult
    [50] = { number = 49, source = "Vvardenfell" },      -- Militant Ordinator
    [51] = { number = 50, source = "Vvardenfell" },      -- Telvanni
    [49] = { number = 51, source = "Vvardenfell" },      -- Hlaalu
    [48] = { number = 52, source = "Vvardenfell" },      -- Redoran
    [38] = { number = 53, source = "Crown Store" },      -- Tsaesci
    [32] = { number = 64, source = "Summerset" },        -- Pyandonean
}

-- Secondary English name-based lookup for styles whose internal IDs
-- are assigned dynamically (post-enum styles, ID >= 60).
-- Works only when the client language is English.
local NAME_TO_MOTIF = {
    ["bloodforge"]          = { number = 54, source = "Bloodroot Forge" },
    ["dreadhorn"]           = { number = 55, source = "Falkreath Hold" },
    ["apostle"]             = { number = 56, source = "Clockwork City" },
    ["ebonshadow"]          = { number = 57, source = "Clockwork City" },
    ["fang lair"]           = { number = 58, source = "Fang Lair" },
    ["scalecaller"]         = { number = 59, source = "Scalecaller Peak" },
    ["worm cult"]           = { number = 60, source = "White-Gold Tower" },
    ["psijic"]              = { number = 61, source = "Summerset" },
    ["sapiarch"]            = { number = 62, source = "Summerset" },
    ["dremora"]             = { number = 63, source = "Crown Store" },
    ["pyandonean"]          = { number = 64, source = "Summerset" },
    ["huntsman"]            = { number = 65, source = "March of Sacrifices" },
    ["silver dawn"]         = { number = 66, source = "Moon Hunter Keep" },
    ["welkynar"]            = { number = 67, source = "Cloudrest" },
    ["honor guard"]         = { number = 68, source = "Cyrodiil" },
    ["dead-water"]          = { number = 69, source = "Murkmire" },
    ["elder argonian"]      = { number = 70, source = "Murkmire" },
    ["coldsnap"]            = { number = 71, source = "Frostvault" },
    ["meridian"]            = { number = 72, source = "Depths of Malatar" },
    ["anequina"]            = { number = 73, source = "Northern Elsweyr" },
    ["pellitine"]           = { number = 74, source = "Northern Elsweyr" },
    ["sunspire"]            = { number = 75, source = "Sunspire" },
    ["dragonguard"]         = { number = 76, source = "Southern Elsweyr" },
    ["stags of z'en"]       = { number = 77, source = "Lair of Maarselok" },
    ["moongrave fane"]      = { number = 78, source = "Moongrave Fane" },
    ["moongrave"]           = { number = 78, source = "Moongrave Fane" },
    ["refabricated"]        = { number = 79, source = "Halls of Fabrication" },
    ["shield of senchal"]   = { number = 80, source = "Southern Elsweyr" },
    ["new moon priest"]     = { number = 81, source = "Southern Elsweyr" },
    ["icereach coven"]      = { number = 82, source = "Icereach" },
    ["pyre watch"]          = { number = 83, source = "Unhallowed Grave" },
    ["blackreach vanguard"] = { number = 84, source = "Western Skyrim" },
    ["greymoor"]            = { number = 85, source = "Castle Thorn" },
    ["sea giant"]           = { number = 86, source = "Kyne's Aegis" },
    ["ancestral nord"]      = { number = 87, source = "Antiquities" },
    ["ancestral orc"]       = { number = 88, source = "Antiquities" },
    ["ancestral high elf"]  = { number = 89, source = "Antiquities" },
    ["thorn legion"]        = { number = 90, source = "Castle Thorn" },
    ["hazardous alchemy"]   = { number = 91, source = "Stone Garden" },
    ["ancestral akaviri"]   = { number = 92, source = "Antiquities" },
    ["ancestral breton"]    = { number = 93, source = "Antiquities" },
    ["ancestral reach"]     = { number = 94, source = "Antiquities" },
    ["nighthollow"]         = { number = 95, source = "Greymoor Caverns" },
    ["arkthzand armory"]    = { number = 96, source = "Stone Garden" },
    ["wayward guardian"]    = { number = 97, source = "The Reach" },
    ["house hexos"]         = { number = 98, source = "Blackwood" },
    ["waking flame"]        = { number = 99, source = "The Waking Flame" },
    ["true-sworn"]          = { number = 100, source = "Deadlands" },
    ["ivory brigade"]       = { number = 101, source = "Blackwood" },
    ["sul-xan"]             = { number = 102, source = "Rockgrove" },
    ["black fin legion"]    = { number = 103, source = "Blackwood" },
    ["ancient daedric"]     = { number = 104, source = "Deadlands" },
    ["crimson oath"]        = { number = 105, source = "The Dread Cellar" },
    ["silver rose"]         = { number = 106, source = "The Cauldron" },
    ["annihilarch's chosen"]= { number = 107, source = "Deadlands" },
    ["annihilarch"]         = { number = 107, source = "Deadlands" },
    ["fargrave guardian"]   = { number = 108, source = "Deadlands" },
    ["dreadsails"]          = { number = 110, source = "High Isle" },
    ["ascendant order"]     = { number = 111, source = "High Isle" },
    ["syrabanic marine"]    = { number = 112, source = "High Isle" },
    ["steadfast society"]   = { number = 113, source = "High Isle" },
    ["systres guardian"]    = { number = 114, source = "High Isle" },
    ["y ffre s will"]       = { number = 115, source = "Galen" },
    ["y ffres will"]        = { number = 115, source = "Galen" },
    ["drowned mariner"]     = { number = 116, source = "Graven Deep" },
    ["firesong"]            = { number = 117, source = "Galen" },
    ["house mornard"]       = { number = 118, source = "Galen" },
    ["blessed inheritor"]   = { number = 119, source = "Telvanni Peninsula" },
    ["scribes of mora"]     = { number = 120, source = "Scrivener's Hall" },
    ["clan dreamcarver"]    = { number = 121, source = "Sanity's Edge" },
    ["dead keeper"]         = { number = 122, source = "Telvanni Peninsula" },
    ["kindred s concord"]   = { number = 123, source = "Bastion Nymic" },
    ["kindreds concord"]    = { number = 123, source = "Bastion Nymic" },
    ["the recollection"]    = { number = 124, source = "Gold Road" },
    ["recollection"]        = { number = 124, source = "Gold Road" },
    ["blind path cultist"]  = { number = 125, source = "Gold Road" },
    ["shardborn"]           = { number = 126, source = "Gold Road" },
    ["west weald legion"]   = { number = 127, source = "West Weald" },
    ["lucent sentinel"]     = { number = 128, source = "Lucent Citadel" },
    ["hircine bloodhunter"] = { number = 129, source = "Gold Road" },
    ["exile s revenge"]     = { number = 130, source = "Exiled Redoubt" },
    ["exiles revenge"]      = { number = 130, source = "Exiled Redoubt" },
    ["militant monk"]       = { number = 131, source = "Lep Seclusa" },
    ["stirk fellowship"]    = { number = 132, source = "Solstice" },
    ["coldharbour dominator"] = { number = 133, source = "Solstice" },
    ["coldharbour dom"]       = { number = 133, source = "Solstice" },
    ["tide born"]           = { number = 134, source = "Sunport" },
    ["black soul gem"]      = { number = 135, source = "Solstice" },
    ["voskrona guardian"]   = { number = 136, source = "Solstice" },
}

local MOTIF_NUMBER_TO_SOURCE = {}
for _, info in pairs(STYLE_TO_MOTIF) do
    if info and info.number and info.source and not MOTIF_NUMBER_TO_SOURCE[info.number] then
        MOTIF_NUMBER_TO_SOURCE[info.number] = info.source
    end
end
for _, info in pairs(NAME_TO_MOTIF) do
    if info and info.number and info.source and not MOTIF_NUMBER_TO_SOURCE[info.number] then
        MOTIF_NUMBER_TO_SOURCE[info.number] = info.source
    end
end

-- Normalize for fuzzy matching: lowercase, replace hyphens with spaces
local function NormalizeName(str)
    if not str then return "" end
    return str:lower():gsub("[-_']", " "):gsub("%s+", " "):match("^%s*(.-)%s*$") or ""
end

-- ESO fixed order for motif chapters (1-14)
local STYLE_CHAPTERS = {
    ITEM_STYLE_CHAPTER_AXES or 1,
    ITEM_STYLE_CHAPTER_BELTS or 2,
    ITEM_STYLE_CHAPTER_BOOTS or 3,
    ITEM_STYLE_CHAPTER_BOWS or 4,
    ITEM_STYLE_CHAPTER_CHESTS or 5,
    ITEM_STYLE_CHAPTER_DAGGERS or 6,
    ITEM_STYLE_CHAPTER_GLOVES or 7,
    ITEM_STYLE_CHAPTER_HELMETS or 8,
    ITEM_STYLE_CHAPTER_LEGS or 9,
    ITEM_STYLE_CHAPTER_MACES or 10,
    ITEM_STYLE_CHAPTER_SHIELDS or 11,
    ITEM_STYLE_CHAPTER_SHOULDERS or 12,
    ITEM_STYLE_CHAPTER_STAVES or 13,
    ITEM_STYLE_CHAPTER_SWORDS or 14,
}

-- Monster set fallback list (Undaunted head/shoulders)
local HARDCODED_MONSTER_SETS = {
    -- Base game dungeons
    { name = "Bloodspawn", source = "Spindleclutch II" },
    { name = "Chokethorn", source = "Elden Hollow I" },
    { name = "Engine Guardian", source = "Darkshade Caverns II" },
    { name = "Grothdarr", source = "Vaults of Madness" },
    { name = "Iceheart", source = "Direfrost Keep" },
    { name = "Ilambris", source = "Crypt of Hearts I" },
    { name = "Infernal Guardian", source = "City of Ash I" },
    { name = "Kra'gh", source = "Fungal Grotto I" },
    { name = "Maw of the Infernal", source = "Banished Cells II" },
    { name = "Nerien'eth", source = "Crypt of Hearts II" },
    { name = "Nightflame", source = "Elden Hollow II", aliases = { "bogdan the nightflame" } },
    { name = "Pirate Skeleton", source = "Blackheart Haven" },
    { name = "Scourge Harvester", source = "Wayrest Sewers II" },
    { name = "Selene", source = "Selene's Web" },
    { name = "Sellistrix", source = "Arx Corinium" },
    { name = "Sentinel of Rkugamz", source = "Darkshade Caverns I", aliases = { "rkugamz sentinel" } },
    { name = "Shadowrend", source = "Banished Cells I" },
    { name = "Slimecraw", source = "Wayrest Sewers I" },
    { name = "Spawn of Mephala", source = "Fungal Grotto II" },
    { name = "Stormfist", source = "Tempest Island" },
    { name = "Swarm Mother", source = "Spindleclutch I" },
    { name = "Tremorscale", source = "Volenfell" },
    { name = "Troll King", source = "Blessed Crucible" },
    { name = "Valkyn Skoria", source = "City of Ash II" },

    -- DLC dungeons (UESP Undaunted styles table)
    { name = "Lord Warden", source = "Imperial City Prison" },
    { name = "Molag Kena", source = "White-Gold Tower" },
    { name = "Mighty Chudan", source = "Ruins of Mazzatun" },
    { name = "Velidreth", source = "Cradle of Shadows" },
    { name = "Domihaus", source = "Falkreath Hold" },
    { name = "Earthgore", source = "Bloodroot Forge" },
    { name = "Balorgh", source = "March of Sacrifices" },
    { name = "Thurvokun", source = "Fang Lair" },
    { name = "Vykosa", source = "Moon Hunter Keep" },
    { name = "Zaan", source = "Scalecaller Peak" },
    { name = "Grundwulf", source = "Moongrave Fane" },
    { name = "Maarselok", source = "Lair of Maarselok" },
    { name = "Stonekeeper", source = "Frostvault" },
    { name = "Symphony of Blades", source = "Depths of Malatar" },
    { name = "Kjalnar's Nightmare", source = "Unhallowed Grave" },
    { name = "Lady Thorn", source = "Castle Thorn" },
    { name = "Mother Ciannait", source = "Icereach" },
    { name = "Stone Husk", source = "Stone Garden" },
    { name = "Baron Zaudrus", source = "The Cauldron" },
    { name = "Encratis's Behemoth", source = "Black Drake Villa" },
    { name = "Magma Incarnate", source = "The Dread Cellar" },
    { name = "Prior Thierric", source = "Red Petal Bastion" },
    { name = "Archdruid Devyric", source = "Earthen Root Enclave" },
    { name = "Euphotic Gatekeeper", source = "Graven Deep" },
    { name = "Kargaeda", source = "Coral Aerie" },
    { name = "Nazaray", source = "Shipwright's Regret" },
    { name = "Ozezan the Inferno", source = "Scrivener's Hall" },
    { name = "Roksa the Warped", source = "Bal Sunnar" },
    { name = "Anthelmir's Construct", source = "Oathsworn Pit" },
    { name = "The Blind", source = "Bedlam Veil" },
    { name = "Orpheon the Tactician", source = "Lep Seclusa" },
    { name = "Squall of Retribution", source = "Exiled Redoubt" },
}

local OPAL_MONSTER_SETS = {
    { name = "Opal Bloodspawn", source = "Undaunted Celebration / Spindleclutch II" },
    { name = "Opal Chokethorn", source = "Undaunted Celebration / Elden Hollow I" },
    { name = "Opal Earthgore", source = "Undaunted Celebration / Bloodroot Forge" },
    { name = "Opal Engine Guardian", source = "Undaunted Celebration / Darkshade Caverns II" },
    { name = "Opal Iceheart", source = "Undaunted Celebration / Direfrost Keep" },
    { name = "Opal Ilambris", source = "Undaunted Celebration / Crypt of Hearts I" },
    { name = "Opal Lord Warden", source = "Undaunted Celebration / Imperial City Prison" },
    { name = "Opal Nightflame", source = "Undaunted Celebration / Elden Hollow II" },
    { name = "Opal Sentinel of Rkugamz", source = "Undaunted Celebration / Darkshade Caverns I", aliases = { "opal rkugamz sentinel" } },
    { name = "Opal Swarm Mother", source = "Undaunted Celebration / Spindleclutch I" },
    { name = "Opal Troll King", source = "Undaunted Celebration / Blessed Crucible" },
    { name = "Opal Velidreth", source = "Undaunted Celebration / Cradle of Shadows" },
    { name = "Opal Scourge Harvester", source = "Undaunted Celebration / Wayrest Sewers II" },
}

local function IsHeadKeyword(lower)
    return lower:find("head", 1, true) or lower:find("helm", 1, true) or lower:find("mask", 1, true)
end

local function IsShoulderKeyword(lower)
    return lower:find("shoulder", 1, true) or lower:find("pauldron", 1, true)
end

function KT_Data:GetCharacterContext()
    local LCK = _G["LibCharacterKnowledge"]
    if type(LCK) ~= "table"
        or type(LCK.GetServerList) ~= "function"
        or type(LCK.GetCharacterList) ~= "function" then
        return nil, {}
    end
    local okServers, servers = pcall(LCK.GetServerList)
    if not okServers or type(servers) ~= "table" then
        return nil, {}
    end
    local server = servers[1]
    if not server then
        return nil, {}
    end
    local okChars, chars = pcall(LCK.GetCharacterList, server)
    if not okChars or type(chars) ~= "table" then
        return server, {}
    end
    return server, chars
end

local function BuildPinnedIdList(pinnedMap)
    local ids = {}
    if type(pinnedMap) ~= "table" then
        return ids
    end
    for id, enabled in pairs(pinnedMap) do
        if enabled == true then
            table.insert(ids, id)
        end
    end
    table.sort(ids, function(a, b) return tostring(a) < tostring(b) end)
    return ids
end

local function TryScanMotifsWithLCK(options)
    local LCK = _G["LibCharacterKnowledge"]
    if type(LCK) ~= "table" then
        return nil
    end
    if type(LCK.GetMotifStyles) ~= "function"
        or type(LCK.GetMotifItemsFromStyle) ~= "function"
        or type(LCK.GetItemKnowledgeForCharacter) ~= "function"
        or type(LCK.GetItemKnowledgeList) ~= "function" then
        return nil
    end

    local function SafeCall(fn, ...)
        if type(fn) ~= "function" then
            return false, nil
        end
        return pcall(fn, ...)
    end

    local server, chars = KT_Data:GetCharacterContext()
    local charNameById = {}
    for _, ch in ipairs(chars) do
        charNameById[ch.id] = ch.name
    end

    local motifs = {}
    local okStyles, styles = SafeCall(LCK.GetMotifStyles)
    styles = (okStyles and type(styles) == "table") and styles or {}
    local knownConst = LCK.KNOWLEDGE_KNOWN
    local viewedCharId = options and options.viewedCharId or nil
    local pinnedIds = BuildPinnedIdList(options and options.pinnedCharIds or nil)

    for _, styleId in ipairs(styles) do
        local okItems, items = SafeCall(LCK.GetMotifItemsFromStyle, styleId)
        items = (okItems and type(items) == "table") and items or nil
        if type(items) == "table" then
            local motifName = zo_strformat("<<1>>", GetItemStyleName(styleId))
            if motifName == "" then
                motifName = string.format("Style %d", tonumber(styleId or 0))
            end
            local chapters = {}
            local chaptersKnown = 0
            local totalChapters = 0
            local charKnownCount = 0
            local charTotal = 0
            local okList, styleKnowledge = SafeCall(LCK.GetItemKnowledgeList, { styleId = styleId }, server)
            styleKnowledge = (okList and type(styleKnowledge) == "table") and styleKnowledge or {}
            for _, row in ipairs(styleKnowledge or {}) do
                charTotal = charTotal + 1
                if row.knowledge == knownConst then
                    charKnownCount = charKnownCount + 1
                end
            end

            if type(items.chapters) == "table" and next(items.chapters) ~= nil then
                for i, chapterType in ipairs(STYLE_CHAPTERS) do
                    local chapterItemId = items.chapters[chapterType]
                    if chapterItemId then
                        totalChapters = totalChapters + 1
                        local knowledge
                        if viewedCharId then
                            local okK, k = SafeCall(LCK.GetItemKnowledgeForCharacter, chapterItemId, server, viewedCharId)
                            knowledge = okK and k or nil
                        else
                            local okK, k = SafeCall(LCK.GetItemKnowledgeForCharacter, chapterItemId)
                            knowledge = okK and k or nil
                        end
                        local known = (knowledge == knownConst)
                        if known then
                            chaptersKnown = chaptersKnown + 1
                        end
                        chapters[i] = { name = "Slot" .. tostring(i), abbr = "", known = known }
                    else
                        chapters[i] = nil
                    end
                end
            else
                totalChapters = 1
                local bookItemId = type(items.books) == "table" and items.books[1] or nil
                local bookKnown = false
                if bookItemId then
                    local knowledge
                    if viewedCharId then
                            local okK, k = SafeCall(LCK.GetItemKnowledgeForCharacter, bookItemId, server, viewedCharId)
                            knowledge = okK and k or nil
                    else
                            local okK, k = SafeCall(LCK.GetItemKnowledgeForCharacter, bookItemId)
                            knowledge = okK and k or nil
                    end
                    bookKnown = (knowledge == knownConst)
                end
                if bookKnown then
                    chaptersKnown = 1
                end
                chapters[1] = { name = "Book", abbr = "", known = bookKnown }
            end

            local pinnedSummary = {}
            for _, pinId in ipairs(pinnedIds) do
                local okK, k = SafeCall(LCK.GetItemKnowledgeForCharacter, { styleId = styleId }, server, pinId)
                k = okK and k or nil
                local mark = (k == knownConst) and "K" or "U"
                local pinName = charNameById[pinId] or tostring(pinId)
                table.insert(pinnedSummary, string.format("%s:%s", pinName, mark))
            end

            local motifNumber = tonumber(items.number)
            local motifSource = nil
            if motifNumber then
                motifSource = MOTIF_NUMBER_TO_SOURCE[motifNumber]
            end
            if (not motifSource or motifSource == "") then
                local normName = NormalizeName(motifName)
                for key, info in pairs(NAME_TO_MOTIF) do
                    local keyNorm = NormalizeName(key)
                    if (normName ~= "" and keyNorm ~= "")
                        and (normName:find(keyNorm, 1, true) or keyNorm:find(normName, 1, true)) then
                        motifSource = info.source
                        break
                    end
                end
            end

            table.insert(motifs, {
                motifNumber = items.number,
                source = motifSource,
                name = motifName .. " Style",
                chaptersKnown = chaptersKnown,
                totalChapters = totalChapters,
                chapters = chapters,
                complete = (chaptersKnown >= totalChapters and totalChapters > 0),
                styleId = styleId,
                crown = items.crown == true,
                charKnownCount = charKnownCount,
                charTotal = charTotal,
                pinnedSummary = pinnedSummary,
            })
        end
    end

    table.sort(motifs, function(a, b)
        local aNum = tonumber(a.motifNumber) or 99999
        local bNum = tonumber(b.motifNumber) or 99999
        if aNum ~= bNum then
            return aNum < bNum
        end
        return tostring(a.name or "") < tostring(b.name or "")
    end)

    return motifs
end

local function BuildSetMatchers(setList)
    local matchers = {}
    for _, set in ipairs(setList or {}) do
        local key = NormalizeName(set.name)
        local aliases = { key }
        if type(set.aliases) == "table" then
            for _, alias in ipairs(set.aliases) do
                local aliasNorm = NormalizeName(alias)
                if aliasNorm ~= "" then
                    table.insert(aliases, aliasNorm)
                end
            end
        end
        table.insert(matchers, { key = key, matchers = aliases })
    end
    return matchers
end

local function ApplyCollectibleToStatus(clean, unlocked, setMatchers, status)
    local isHead = IsHeadKeyword(clean)
    local isShoulder = (not isHead) and IsShoulderKeyword(clean)
    if not (isHead or isShoulder) then
        return
    end
    for i = 1, #setMatchers do
        local entry = setMatchers[i]
        local matched = false
        for j = 1, #entry.matchers do
            if clean:find(entry.matchers[j], 1, true) then
                matched = true
                break
            end
        end
        if matched then
            status[entry.key] = status[entry.key] or {}
            if isHead then
                status[entry.key].head = unlocked
            else
                status[entry.key].shoulder = unlocked
            end
            return
        end
    end
end

local function BuildUndauntedList(normalStatus, opalStatus)
    local undaunted = {}
    for _, set in ipairs(HARDCODED_MONSTER_SETS) do
        local key = NormalizeName(set.name)
        local s = normalStatus[key] or {}
        local headKnown = s.head == true
        local shoulderKnown = s.shoulder == true
        table.insert(undaunted, {
            name = set.name,
            source = set.source or "Undaunted",
            chaptersKnown = (headKnown and 1 or 0) + (shoulderKnown and 1 or 0),
            totalChapters = 2,
            chapters = {
                { name = "Head", abbr = "", known = headKnown },
                { name = "Shoulders", abbr = "", known = shoulderKnown },
            },
            complete = headKnown and shoulderKnown,
            isUndaunted = true,
        })
    end
    for _, set in ipairs(OPAL_MONSTER_SETS) do
        local key = NormalizeName(set.name)
        local s = opalStatus[key] or {}
        local headKnown = s.head == true
        local shoulderKnown = s.shoulder == true
        table.insert(undaunted, {
            name = set.name,
            source = set.source or "Undaunted Celebration",
            chaptersKnown = (headKnown and 1 or 0) + (shoulderKnown and 1 or 0),
            totalChapters = 2,
            chapters = {
                { name = "Head", abbr = "", known = headKnown },
                { name = "Shoulders", abbr = "", known = shoulderKnown },
            },
            complete = headKnown and shoulderKnown,
            isUndaunted = true,
            isOpal = true,
        })
    end
    table.sort(undaunted, function(a, b) return a.name < b.name end)
    return undaunted
end

local function ScanCollectiblesForStatus(setList, mode)
    setList = setList or HARDCODED_MONSTER_SETS
    mode = mode or "any"
    local status = {}
    local setMatchers = BuildSetMatchers(setList)

    pcall(function()
        local numCats = GetNumCollectibleCategories()
        for catIdx = 1, numCats do
            local _, numSubCats, numTop = GetCollectibleCategoryInfo(catIdx)
            for colIdx = 1, numTop do
                local cId = GetCollectibleId(catIdx, nil, colIdx)
                local cName, _, _, _, unlocked = GetCollectibleInfo(cId)
                if cName and cName ~= "" then
                    local clean = NormalizeName(zo_strformat("<<1>>", cName))
                    local hasOpal = clean:find("opal", 1, true) ~= nil
                    local modeOk = not ((mode == "opal" and not hasOpal) or (mode == "normal" and hasOpal))
                    if modeOk then
                        local isHead = IsHeadKeyword(clean)
                        local isShoulder = (not isHead) and IsShoulderKeyword(clean)
                        if isHead or isShoulder then
                            for i = 1, #setMatchers do
                                local entry = setMatchers[i]
                                local matched = false
                                for j = 1, #entry.matchers do
                                    if clean:find(entry.matchers[j], 1, true) then
                                        matched = true
                                        break
                                    end
                                end
                                if matched then
                                    status[entry.key] = status[entry.key] or {}
                                    if isHead then
                                        status[entry.key].head = unlocked
                                    else
                                        status[entry.key].shoulder = unlocked
                                    end
                                    break
                                end
                            end
                        end
                    end
                end
            end
            for subIdx = 1, numSubCats do
                local _, numColl = GetCollectibleSubCategoryInfo(catIdx, subIdx)
                for colIdx = 1, numColl do
                    local cId = GetCollectibleId(catIdx, subIdx, colIdx)
                    local cName, _, _, _, unlocked = GetCollectibleInfo(cId)
                    if cName and cName ~= "" then
                        local clean = NormalizeName(zo_strformat("<<1>>", cName))
                        local hasOpal = clean:find("opal", 1, true) ~= nil
                        local modeOk = not ((mode == "opal" and not hasOpal) or (mode == "normal" and hasOpal))
                        if modeOk then
                            local isHead = IsHeadKeyword(clean)
                            local isShoulder = (not isHead) and IsShoulderKeyword(clean)
                            if isHead or isShoulder then
                                for i = 1, #setMatchers do
                                    local entry = setMatchers[i]
                                    local matched = false
                                    for j = 1, #entry.matchers do
                                        if clean:find(entry.matchers[j], 1, true) then
                                            matched = true
                                            break
                                        end
                                    end
                                    if matched then
                                        status[entry.key] = status[entry.key] or {}
                                        if isHead then
                                            status[entry.key].head = unlocked
                                        else
                                            status[entry.key].shoulder = unlocked
                                        end
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    return status
end

-- ═══════════════════════════════════════════════════════════════════════════
-- MOTIF SCANNING  (achievement-based + style cross-reference)
-- ═══════════════════════════════════════════════════════════════════════════

local function TryMotifAchievement(achId, results)
    local name, _, points, icon, completed = GetAchievementInfo(achId)
    if not name or name == "" then return end

    local numCrit = GetAchievementNumCriteria(achId)
    if numCrit ~= 14 then return end

    local chaptersKnown = 0
    local chapters = {}
    for critIdx = 1, numCrit do
        local critDesc, numCompleted, numRequired = GetAchievementCriterion(achId, critIdx)
        if numRequired ~= 1 then return end
        local known = numCompleted >= numRequired
        if known then chaptersKnown = chaptersKnown + 1 end
        local slotName = zo_strformat("<<1>>", critDesc or ("Slot" .. critIdx))
        local abbr = slotName:sub(1, 2)
        chapters[critIdx] = { name = slotName, abbr = abbr, known = known }
    end

    table.insert(results, {
        achievementId = achId,
        name          = zo_strformat("<<1>>", name),
        chaptersKnown = chaptersKnown,
        totalChapters = numCrit,
        chapters      = chapters,
        complete      = completed,
        icon          = icon,
        points        = points,
    })
end

function KT_Data:ScanMotifs(options)
    local lckMotifs = TryScanMotifsWithLCK(options)
    if lckMotifs and #lckMotifs > 0 then
        return lckMotifs
    end

    -- Build style lookup
    local styleEntries = {}
    local styleById = {}
    local highestId = (GetHighestItemStyleId and GetHighestItemStyleId()) or 300
    for styleId = 1, highestId do
        local rawName = GetItemStyleName(styleId)
        if rawName and rawName ~= "" then
            local cleanName = zo_strformat("<<1>>", rawName)
            local normName  = NormalizeName(cleanName)
            if normName ~= "" and normName ~= "none" then
                local entry = { normName = normName, styleId = styleId, rawName = cleanName }
                table.insert(styleEntries, entry)
                styleById[styleId] = entry
            end
        end
    end
    table.sort(styleEntries, function(a, b) return #a.normName > #b.normName end)

    -- 1) Seed motifs from authoritative motif-number tables (restores 1-14 reliably)
    local byNumber = {}

    local function EnsureMotif(number, source)
        local m = byNumber[number]
        if not m then
            m = {
                motifNumber = number,
                source = source,
                name = "Motif " .. tostring(number),
                chaptersKnown = 0,
                totalChapters = #STYLE_CHAPTERS,
                chapters = {},
                complete = false,
            }
            byNumber[number] = m
        elseif source and not m.source then
            m.source = source
        end
        return m
    end

    for styleId, info in pairs(STYLE_TO_MOTIF) do
        local m = EnsureMotif(info.number, info.source)
        m.styleId = styleId
        local styleEntry = styleById[styleId]
        if styleEntry and styleEntry.rawName and styleEntry.rawName ~= "" then
            m.name = styleEntry.rawName .. " Style"
        end
    end

    -- 2) Resolve dynamic motifs by style name matching
    for nameKey, info in pairs(NAME_TO_MOTIF) do
        local m = EnsureMotif(info.number, info.source)
        local keyNorm = NormalizeName(nameKey)
        for _, entry in ipairs(styleEntries) do
            if entry.normName:find(keyNorm, 1, true) or keyNorm:find(entry.normName, 1, true) then
                if not m.styleId then
                    m.styleId = entry.styleId
                    m.name = entry.rawName .. " Style"
                end
                break
            end
        end
    end

    -- 3) Optional achievement fallback (name/source polish + chapter fallback)
    local numCats = GetNumAchievementCategories()
    for catIdx = 1, numCats do
        local catName, numSubCats, numTopAch = GetAchievementCategoryInfo(catIdx)
        catName = NormalizeName(zo_strformat("<<1>>", catName or ""))

        local function ProcessAchievement(achId, subNameNorm)
            local name, _, _, icon = GetAchievementInfo(achId)
            if not name or name == "" then return end
            local displayName = zo_strformat("<<1>>", name)
            local normAchName = NormalizeName(displayName)
            local numCrit = GetAchievementNumCriteria(achId)

            if numCrit == 14 then
                local matchedNumber = nil
                local achKnown = 0
                local achChapters = {}
                local achValid = true
                for i = 1, 14 do
                    local critDesc, numCompleted, numRequired = GetAchievementCriterion(achId, i)
                    if numRequired ~= 1 then
                        achValid = false
                        break
                    end
                    local known = numCompleted >= numRequired
                    if known then achKnown = achKnown + 1 end
                    achChapters[i] = { name = zo_strformat("<<1>>", critDesc or ("Slot" .. i)), abbr = "", known = known }
                end
                if not achValid then return end

                for _, entry in ipairs(styleEntries) do
                    if normAchName:find(entry.normName, 1, true) then
                        local info = STYLE_TO_MOTIF[entry.styleId]
                        if info then
                            matchedNumber = info.number
                        end
                        break
                    end
                end
                if not matchedNumber then
                    for nameKey, info in pairs(NAME_TO_MOTIF) do
                        if normAchName:find(NormalizeName(nameKey), 1, true) then
                            matchedNumber = info.number
                            break
                        end
                    end
                end
                if matchedNumber then
                    local m = EnsureMotif(matchedNumber, nil)
                    if (not m.name) or m.name:find("^Motif%s+") then
                        m.name = displayName:gsub("%s+[Ss]tyle%s+[Mm]aster$", " Style")
                    end
                    if not m.icon and icon then m.icon = icon end
                    -- Keep achievement match only for name/number/source discovery.
                    -- Per-character chapter status must come from IsSmithingStyleKnown.
                end
                return
            end

        end

        for achIdx = 1, numTopAch do
            local achId = GetAchievementId(catIdx, nil, achIdx)
            ProcessAchievement(achId, "")
        end
        for subIdx = 1, numSubCats do
            local subName, numAch = GetAchievementSubCategoryInfo(catIdx, subIdx)
            local subNameNorm = NormalizeName(zo_strformat("<<1>>", subName or ""))
            for achIdx = 1, numAch do
                local achId = GetAchievementId(catIdx, subIdx, achIdx)
                ProcessAchievement(achId, subNameNorm)
            end
        end
    end

    -- 4) Fill chapter status from smithing style knowledge only (per-character)
    local motifs = {}
    for _, m in pairs(byNumber) do
        local chaptersKnown = 0
        local chapters = {}
        if m.styleId and IsSmithingStyleKnown then
            for i, chapterType in ipairs(STYLE_CHAPTERS) do
                local known = IsSmithingStyleKnown(m.styleId, chapterType) == true
                if known then chaptersKnown = chaptersKnown + 1 end
                chapters[i] = { name = "Slot" .. i, abbr = "", known = known }
            end
        else
            for i = 1, #STYLE_CHAPTERS do
                chapters[i] = { name = "Slot" .. i, abbr = "", known = false }
            end
        end
        m.chapters = chapters
        m.chaptersKnown = chaptersKnown
        m.totalChapters = #STYLE_CHAPTERS
        m.complete = (chaptersKnown >= #STYLE_CHAPTERS)
        table.insert(motifs, m)
    end

    table.sort(motifs, function(a, b)
        if a.motifNumber ~= b.motifNumber then return a.motifNumber < b.motifNumber end
        return a.name < b.name
    end)

    return motifs
end

function KT_Data:ScanUndaunted()
    local collectibleStatus = ScanCollectiblesForStatus(HARDCODED_MONSTER_SETS, "normal")
    local opalStatus = ScanCollectiblesForStatus(OPAL_MONSTER_SETS, "opal")
    return BuildUndauntedList(collectibleStatus, opalStatus)
end

function KT_Data:InvalidateUndauntedCache()
    self._undauntedCache = nil
    self._undauntedCacheAtMs = 0
end

function KT_Data:IsUndauntedScanRunning()
    return self._undauntedScanRunning == true
end

function KT_Data:StartUndauntedScanAsync(onDone, forceRefresh)
    local now = (GetFrameTimeMilliseconds and GetFrameTimeMilliseconds()) or 0
    local cacheValid = (type(self._undauntedCache) == "table")
        and (not forceRefresh)
        and (now > 0)
        and ((now - (self._undauntedCacheAtMs or 0)) < (self._undauntedCacheTtlMs or 0))

    if type(onDone) == "function" then
        table.insert(self._undauntedScanListeners, onDone)
    end

    if cacheValid then
        local listeners = self._undauntedScanListeners
        self._undauntedScanListeners = {}
        for i = 1, #listeners do
            pcall(listeners[i], self._undauntedCache)
        end
        return
    end

    if self._undauntedScanRunning then
        return
    end
    self._undauntedScanRunning = true

    local refs = {}
    local okRefs = pcall(function()
        local numCats = GetNumCollectibleCategories()
        for catIdx = 1, numCats do
            local _, numSubCats, numTop = GetCollectibleCategoryInfo(catIdx)
            for colIdx = 1, numTop do
                refs[#refs + 1] = { catIdx = catIdx, subIdx = nil, colIdx = colIdx }
            end
            for subIdx = 1, numSubCats do
                local _, numColl = GetCollectibleSubCategoryInfo(catIdx, subIdx)
                for colIdx = 1, numColl do
                    refs[#refs + 1] = { catIdx = catIdx, subIdx = subIdx, colIdx = colIdx }
                end
            end
        end
    end)
    if not okRefs then
        refs = {}
    end

    local normalStatus = {}
    local opalStatus = {}
    local normalMatchers = BuildSetMatchers(HARDCODED_MONSTER_SETS)
    local opalMatchers = BuildSetMatchers(OPAL_MONSTER_SETS)
    local index = 1
    local batchSize = 140

    local function finalize()
        self._undauntedCache = BuildUndauntedList(normalStatus, opalStatus)
        self._undauntedCacheAtMs = (GetFrameTimeMilliseconds and GetFrameTimeMilliseconds()) or now
        self._undauntedScanRunning = false

        local listeners = self._undauntedScanListeners
        self._undauntedScanListeners = {}
        for i = 1, #listeners do
            pcall(listeners[i], self._undauntedCache)
        end
    end

    local function step()
        local processed = 0
        while index <= #refs and processed < batchSize do
            local ref = refs[index]
            index = index + 1
            processed = processed + 1

            local cId = GetCollectibleId(ref.catIdx, ref.subIdx, ref.colIdx)
            if cId and cId > 0 then
                local cName, _, _, _, unlocked = GetCollectibleInfo(cId)
                if cName and cName ~= "" then
                    local clean = NormalizeName(zo_strformat("<<1>>", cName))
                    local hasOpal = clean:find("opal", 1, true) ~= nil
                    if hasOpal then
                        ApplyCollectibleToStatus(clean, unlocked, opalMatchers, opalStatus)
                    else
                        ApplyCollectibleToStatus(clean, unlocked, normalMatchers, normalStatus)
                    end
                end
            end
        end

        if index <= #refs then
            zo_callLater(step, 1)
        else
            finalize()
        end
    end

    zo_callLater(step, 1)
end

function KT_Data:GetUndauntedCached(forceRefresh)
    local now = (GetFrameTimeMilliseconds and GetFrameTimeMilliseconds()) or 0
    local cacheValid = (type(self._undauntedCache) == "table")
        and (not forceRefresh)
        and (now > 0)
        and ((now - (self._undauntedCacheAtMs or 0)) < (self._undauntedCacheTtlMs or 0))
    if cacheValid then
        return self._undauntedCache
    end
    return nil
end

function KT_Data:ScanAll(options)
    return {
        motifs = self:ScanMotifs(options),
        -- Heavy collectible scan is lazy-loaded on tab open.
        undaunted = self._undauntedCache or {},
    }
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SUMMARY HELPERS
-- ═══════════════════════════════════════════════════════════════════════════

function KT_Data:CountMotifs(motifs)
    local complete, total = 0, 0
    local chapKnown, chapTotal = 0, 0
    for _, m in ipairs(motifs) do
        total = total + 1
        chapTotal = chapTotal + m.totalChapters
        chapKnown = chapKnown + m.chaptersKnown
        if m.complete then complete = complete + 1 end
    end
    return complete, total, chapKnown, chapTotal
end
