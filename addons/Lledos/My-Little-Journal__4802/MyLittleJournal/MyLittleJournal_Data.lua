-- My Little Journal — shipped catalog of instances and bosses.
-- Boss lists are best-effort; every instance also gets an automatic
-- "Overview & Trash" entry, and users can add custom bosses (right page)
-- or whole custom instances (bottom of the instance list).

MyLittleJournal = MyLittleJournal or {}
local TJ = MyLittleJournal

TJ.Data = {}
local Data = TJ.Data

Data.CATEGORIES = {
    { key = "dungeon", name = "Dungeons" },
    { key = "trial",   name = "Trials" },
    { key = "arena",   name = "Arenas" },
}

Data.OVERVIEW_KEY = "__overview"
Data.OVERVIEW_NAME = "Overview & Trash"

-- =========================
-- Catalog
-- =========================
Data.INSTANCES = {
    -- ===== Base game dungeons =====
    { id = "fungal_grotto_1", category = "dungeon", name = "Fungal Grotto I",
      bosses = { "War Chief Ozozai", "Broodbirther", "Mad Mortine", "Clannfear Handler", "Kra'gh the Dreugh King" } },
    { id = "fungal_grotto_2", category = "dungeon", name = "Fungal Grotto II",
      bosses = { "Mephala's Fang", "Gamyne Bandu", "Spawn of Mephala", "Vila Theran" } },
    { id = "spindleclutch_1", category = "dungeon", name = "Spindleclutch I",
      bosses = { "Spindlekin", "Swarm Mother", "Cerise the Widow-Maker", "Big Rabbu", "The Whisperer" } },
    { id = "spindleclutch_2", category = "dungeon", name = "Spindleclutch II",
      bosses = { "Blood Spawn", "Praxin Douare", "Urvan Veleth", "Vorenor Winterbourne" } },
    { id = "banished_cells_1", category = "dungeon", name = "The Banished Cells I",
      bosses = { "Cell Haven Atronach", "Shadowrend", "Angata the Clannfear Handler", "Skeletal Destroyer", "High Kinlord Rilis" } },
    { id = "banished_cells_2", category = "dungeon", name = "The Banished Cells II",
      bosses = { "Keeper Areldur", "Maw of the Infernal", "Keeper Voranil", "Keeper Imiril", "High Kinlord Rilis" } },
    { id = "elden_hollow_1", category = "dungeon", name = "Elden Hollow I",
      bosses = { "Akash gra-Mal", "Chokethorn", "Canonreeve Oraneth" } },
    { id = "elden_hollow_2", category = "dungeon", name = "Elden Hollow II",
      bosses = { "Dubroze the Infestor", "Murklight", "The Shadow Guard", "Bogdan the Nightflame" } },
    { id = "darkshade_caverns_1", category = "dungeon", name = "Darkshade Caverns I",
      bosses = { "Head Shepherd Neloren", "Foreman Llothan", "The Hive Lord" } },
    { id = "darkshade_caverns_2", category = "dungeon", name = "Darkshade Caverns II",
      bosses = { "Transmuted Hive Lord", "Grobull the Transmuted", "The Engine Guardian" } },
    { id = "wayrest_sewers_1", category = "dungeon", name = "Wayrest Sewers I",
      bosses = { "Slimecraw", "Investigator Garron", "Uulgarg the Hungry", "Allene & Varaine Pellingare" } },
    { id = "wayrest_sewers_2", category = "dungeon", name = "Wayrest Sewers II",
      bosses = { "Malubeth the Scourger", "Uulgarg the Risen", "Garron the Returned", "The Forgotten One", "Allene & Varaine Pellingare" } },
    { id = "crypt_of_hearts_1", category = "dungeon", name = "Crypt of Hearts I",
      bosses = { "The Mage Master", "Archmaster Siniel", "Death's Leviathan", "Dogas the Berserker", "Ilambris-Athor & Ilambris-Zaven" } },
    { id = "crypt_of_hearts_2", category = "dungeon", name = "Crypt of Hearts II",
      bosses = { "Ibelgast", "Ruzozuzalpamaz", "Ilambris Amalgam", "Mezeluth", "Nerien'eth" } },
    { id = "city_of_ash_1", category = "dungeon", name = "City of Ash I",
      bosses = { "Golor the Banekin Handler", "Warden of the Shrine", "Infernal Guardian", "Dark Ember", "Rothariel Flameheart", "Razor Master Erthas" } },
    { id = "city_of_ash_2", category = "dungeon", name = "City of Ash II",
      bosses = { "Rukhan", "Marruz", "Urata the Legion", "Horvantud the Fire Maw", "Ash Titan", "Valkyn Skoria" } },
    { id = "arx_corinium", category = "dungeon", name = "Arx Corinium",
      bosses = { "Ganakton the Tempest", "Sliklenia the Songstress", "Matron Ixniaa", "Sellistrix the Lamia Queen" } },
    { id = "direfrost_keep", category = "dungeon", name = "Direfrost Keep",
      bosses = { "Guardian of the Flame", "Drodda of Icereach" } },
    { id = "volenfell", category = "dungeon", name = "Volenfell",
      bosses = { "Quintus Verres", "Boilbite", "Unstable Construct", "The Guardian Council" } },
    { id = "tempest_island", category = "dungeon", name = "Tempest Island",
      bosses = { "Sonolia the Matriarch", "Valaran Stormcaller", "Yalorasse the Speaker", "Stormfist" } },
    { id = "selenes_web", category = "dungeon", name = "Selene's Web",
      bosses = { "Treethane Kerninn", "Longclaw", "Foulhide", "Mennir Many-Legs", "Selene" } },
    { id = "vaults_of_madness", category = "dungeon", name = "Vaults of Madness",
      bosses = { "Ulguna Soul-Reaver", "The Cursed One", "Grothdarr" } },
    { id = "blackheart_haven", category = "dungeon", name = "Blackheart Haven",
      bosses = { "Atarus", "Roost Mother", "Captain Blackheart" } },
    { id = "blessed_crucible", category = "dungeon", name = "Blessed Crucible",
      bosses = { "Teranya the Faceless", "The Troll King", "The Lava Queen" } },

    -- ===== DLC dungeons =====
    { id = "imperial_city_prison", category = "dungeon", name = "Imperial City Prison",
      bosses = { "Overfiend", "Ibomez the Flesh Sculptor", "Flesh Abomination", "Lord Warden Dusk" } },
    { id = "white_gold_tower", category = "dungeon", name = "White-Gold Tower",
      bosses = { "The Adjudicator", "The Planar Inhibitor", "Molag Kena" } },
    { id = "ruins_of_mazzatun", category = "dungeon", name = "Ruins of Mazzatun",
      bosses = { "Mighty Chudan", "Xal-Nur the Slaver", "Tree-Minder Na-Kesh" } },
    { id = "cradle_of_shadows", category = "dungeon", name = "Cradle of Shadows",
      bosses = { "Khephidaen the Spiderkith", "Dranos Velador", "Velidreth" } },
    { id = "falkreath_hold", category = "dungeon", name = "Falkreath Hold",
      bosses = { "Morrigh Bullblood", "Siege Mammoth", "Cernunnon", "Deathlord Bjarfrud Skjoralmor", "Domihaus the Bloody-Horned" } },
    { id = "bloodroot_forge", category = "dungeon", name = "Bloodroot Forge",
      bosses = { "Mathgamain", "Caillaoife", "Galchobhar", "Gherig Bullblood", "Earthgore Amalgam" } },
    { id = "fang_lair", category = "dungeon", name = "Fang Lair",
      bosses = { "Lizabet Charnis", "Cadaverous Menagerie", "Caluurion", "Ulfnor & Sabina Cedus", "Orryn the Black & Thurvokun" } },
    { id = "scalecaller_peak", category = "dungeon", name = "Scalecaller Peak",
      bosses = { "Rinaerus the Rancid & Orzun the Foul-Smelling", "Doylemish Ironheart", "Matriarch Aldis", "Plague Concocter Mortieu", "Zaan the Scalecaller" } },
    { id = "moon_hunter_keep", category = "dungeon", name = "Moon Hunter Keep",
      bosses = { "Jailer Melitus", "Hedge Maze Guardian", "Mylenne Moon-Caller", "Archivist Ernarde", "Vykosa the Ascendant" } },
    { id = "march_of_sacrifices", category = "dungeon", name = "March of Sacrifices",
      bosses = { "Aghaedh of the Solstice", "Dagrund the Bulky", "Tarcyr", "Balorgh" } },
    { id = "frostvault", category = "dungeon", name = "Frostvault",
      bosses = { "Icestalker", "Warlord Tzogvin", "Vault Protector", "The Stonekeeper" } },
    { id = "depths_of_malatar", category = "dungeon", name = "Depths of Malatar",
      bosses = { "The Scavenging Maw", "The Weeping Woman", "King Narilmor", "Symphony of Blades" } },
    { id = "moongrave_fane", category = "dungeon", name = "Moongrave Fane",
      bosses = { "The Risen Ruins", "Dro'zakar", "Kujo Kethba", "Grundwulf" } },
    { id = "lair_of_maarselok", category = "dungeon", name = "Lair of Maarselok",
      bosses = { "Azureblight Cancroid", "Azureblight Lurcher", "Selene", "Maarselok" } },
    { id = "icereach", category = "dungeon", name = "Icereach",
      bosses = { "Kjarg the Tuskscraper", "Sister Skelga", "Vearogh the Shambler", "Stormborn Revenant", "Mother Ciannait" } },
    { id = "unhallowed_grave", category = "dungeon", name = "Unhallowed Grave",
      bosses = { "Hakgrym the Howler", "Keeper of the Kiln", "Voria the Heart-Thief", "Kjalnar Tombskald" } },
    { id = "stone_garden", category = "dungeon", name = "Stone Garden",
      bosses = { "Stone Husk", "Exarch Kraglen", "Arkasis the Mad Alchemist" } },
    { id = "castle_thorn", category = "dungeon", name = "Castle Thorn",
      bosses = { "Dread Tindulra", "Blood Twilight", "Vaduroth", "Talfyg", "Lady Thorn" } },
    { id = "black_drake_villa", category = "dungeon", name = "Black Drake Villa",
      bosses = { "Sentinel Aksalaz", "Encratis's Behemoth", "Kinras Ironeye" } },
    { id = "the_cauldron", category = "dungeon", name = "The Cauldron",
      bosses = { "Oaxiltso", "Molten Guardian", "Baron Zaudrus" } },
    { id = "red_petal_bastion", category = "dungeon", name = "Red Petal Bastion",
      bosses = { "Eliam Merick", "Prior Thierric", "Magma Incarnate" } },
    { id = "the_dread_cellar", category = "dungeon", name = "The Dread Cellar",
      bosses = { "Cyronin Artellian", "Broodmother Arkanessa", "Magistrix Vox" } },
    { id = "coral_aerie", category = "dungeon", name = "Coral Aerie",
      bosses = { "Z'Baza", "Maligalig", "Varallion" } },
    { id = "shipwrights_regret", category = "dungeon", name = "Shipwright's Regret",
      bosses = { "Foreman Bradiggan", "Storm-Cursed Sailors", "Nazaray" } },
    { id = "earthen_root_enclave", category = "dungeon", name = "Earthen Root Enclave",
      bosses = { "Corruption of Stone", "Corruption of Root", "Archdruid Devyric" } },
    { id = "graven_deep", category = "dungeon", name = "Graven Deep",
      bosses = { "The Euphotic Gatekeeper", "Dreadful Drudge", "Zelvraak the Unbreathing" } },
    { id = "bal_sunnar", category = "dungeon", name = "Bal Sunnar",
      bosses = { "Kovan Giryon", "Roksa the Warped", "Matriarch Lladi Telvanni" } },
    { id = "scriveners_hall", category = "dungeon", name = "Scrivener's Hall",
      bosses = { "Riftmaster Naqri", "Ozezan the Inferno", "Valinna" } },
    { id = "oathsworn_pit", category = "dungeon", name = "Oathsworn Pit",
      bosses = { "Anthelmir", "Anthelmir's Construct", "Aradros" } },
    { id = "bedlam_veil", category = "dungeon", name = "Bedlam Veil",
      bosses = { "Shattered Champion", "Darkshard", "The Blind" } },
    { id = "lep_seclusa", category = "dungeon", name = "Lep Seclusa",
      bosses = { "Lewin Frey", "Garvin the Tracker", "Siege Master Malthoras", "Noriwen", "Flamedancer Ajim-Rei", "Orpheon the Tactician" } },
    { id = "exiled_redoubt", category = "dungeon", name = "Exiled Redoubt",
      bosses = { "Executioner Jerensi", "Prime Sorcerer Vandorallen", "Squall of Retribution" } },
    { id = "black_gem_foundry", category = "dungeon", name = "Black Gem Foundry",
      bosses = { "Quarrymaster Saldezaar", "Black Gem Monstrosity", "High Soulbinder Vykand" } },

    -- ===== Trials =====
    { id = "hel_ra_citadel", category = "trial", name = "Hel Ra Citadel",
      bosses = { "Ra Kotu", "Yokeda Rok'dun", "Yokeda Kai", "The Warrior" } },
    { id = "aetherian_archive", category = "trial", name = "Aetherian Archive",
      bosses = { "Lightning Storm Atronach", "Foundation Stone Atronach", "Varlariel", "The Mage" } },
    { id = "sanctum_ophidia", category = "trial", name = "Sanctum Ophidia",
      bosses = { "Possessed Mantikora", "Stonebreaker", "Ozara", "The Serpent" } },
    { id = "maw_of_lorkhaj", category = "trial", name = "Maw of Lorkhaj",
      bosses = { "Zhaj'hassa the Forgotten", "The Twins (Vashai & S'kinrai)", "Rakkhat" } },
    { id = "halls_of_fabrication", category = "trial", name = "Halls of Fabrication",
      bosses = { "Hunter-Killer Fabricants", "Pinnacle Factotum", "Archcustodian", "Refabrication Committee", "Assembly General" } },
    { id = "asylum_sanctorium", category = "trial", name = "Asylum Sanctorium",
      bosses = { "Saint Llothis the Pious", "Saint Felms the Bold", "Saint Olms the Just" } },
    { id = "cloudrest", category = "trial", name = "Cloudrest",
      bosses = { "Shade of Galenwe", "Shade of Relequen", "Shade of Siroria", "Z'Maja" } },
    { id = "sunspire", category = "trial", name = "Sunspire",
      bosses = { "Lokkestiiz", "Yolnahkriin", "Nahviintaas" } },
    { id = "kynes_aegis", category = "trial", name = "Kyne's Aegis",
      bosses = { "Yandir the Butcher", "Captain Vrol", "Lord Falgravn" } },
    { id = "rockgrove", category = "trial", name = "Rockgrove",
      bosses = { "Oaxiltso", "Flame-Herald Bahsei", "Xalvakka" } },
    { id = "dreadsail_reef", category = "trial", name = "Dreadsail Reef",
      bosses = { "Lylanar & Turlassil", "Reef Guardian", "Tideborn Taleria" } },
    { id = "sanitys_edge", category = "trial", name = "Sanity's Edge",
      bosses = { "Exarchanic Yaseyla", "Archwizard Twelvane", "Ansuul the Tormentor" } },
    { id = "lucent_citadel", category = "trial", name = "Lucent Citadel",
      bosses = { "Count Ryelaz & Zilyesset", "Orphic Shattered Shard", "Xoryn" } },
    { id = "ossein_cage", category = "trial", name = "Ossein Cage",
      bosses = { "Shapers of Flesh", "Jynorah & Skorkhif", "Overfiend Kazpian" } },
    { id = "opulent_ordeal", category = "trial", name = "Opulent Ordeal",
      bosses = { "Essence Delivery (Phase 1)", "Opulent Trio (Web Eater, Arid Varlet, Knightshade)" } },

    -- ===== Arenas =====
    { id = "dragonstar_arena", category = "arena", name = "Dragonstar Arena (group)",
      bosses = {
        "Stage 1 — Champion Marcauld",
        "Stage 2 — Yavni Frost-Skin",
        "Stage 3 — Shilia",
        "Stage 4 — Nak'tah",
        "Stage 5 — Earthen Heart Knight",
        "Stage 6 — Anal'a Tu'wha",
        "Stage 7 — Pishna Longshot",
        "Stage 8 — Shadow Knight & Dark Mage",
        "Stage 9 — Mavus Talnarith",
        "Stage 10 — Hiath the Battlemaster",
      } },
    { id = "maelstrom_arena", category = "arena", name = "Maelstrom Arena (solo)",
      bosses = {
        "Round 1 — Vale of the Surreal",
        "Round 2 — Seht's Balcony",
        "Round 3 — Drome of Toxic Shock",
        "Round 4 — Seht's Flywheel",
        "Round 5 — Rink of Frozen Blood",
        "Round 6 — Spiral Shadows",
        "Round 7 — Vault of Umbrage",
        "Round 8 — Igneous Cistern",
        "Round 9 — Theater of Despair (Voriak Solkyn)",
      } },
    { id = "blackrose_prison", category = "arena", name = "Blackrose Prison (group)",
      bosses = {
        "Arena 1",
        "Arena 2",
        "Arena 3",
        "Arena 4",
        "Arena 5 — Drakeeh the Unchained",
      } },
    { id = "vateshran_hollows", category = "arena", name = "Vateshran Hollows (solo)",
      bosses = {
        "The Wounding",
        "The Brimstone Den",
        "The Hunter's Grotto",
        "Maebroogha the Void Lich",
      } },
    { id = "infinite_archive", category = "arena", name = "Infinite Archive",
      bosses = { "Cycle Bosses", "Marauders", "Tho'at Replicanum" } },
}

-- =========================
-- Lookup helpers
-- =========================
local instanceById = {}
for _, inst in ipairs(Data.INSTANCES) do
    instanceById[inst.id] = inst
end

-- Stable key from a boss display name (catalog bosses only; custom bosses
-- get generated keys so renames in future versions can't orphan notes).
function Data.BossKeyFromName(name)
    local key = zo_strlower(tostring(name or ""))
    key = key:gsub("[^%w]+", "_"):gsub("^_+", ""):gsub("_+$", "")
    return key
end

function Data.GetCategoryName(categoryKey)
    for _, cat in ipairs(Data.CATEGORIES) do
        if cat.key == categoryKey then return cat.name end
    end
    return categoryKey
end

-- savedVars is the addon SV table; may hold customInstances / customBosses.
function Data.GetInstance(savedVars, instanceId)
    local inst = instanceById[instanceId]
    if inst then return inst end
    if savedVars and savedVars.customInstances then
        for _, custom in ipairs(savedVars.customInstances) do
            if custom.id == instanceId then return custom end
        end
    end
    return nil
end

function Data.IsCustomInstance(instanceId)
    return instanceById[instanceId] == nil
end

-- Returns a sorted array of { id, name, category, custom } for one category.
function Data.GetInstanceList(savedVars, categoryKey)
    local list = {}
    for _, inst in ipairs(Data.INSTANCES) do
        if inst.category == categoryKey then
            list[#list + 1] = { id = inst.id, name = inst.name, category = inst.category, custom = false }
        end
    end
    if savedVars and savedVars.customInstances then
        for _, custom in ipairs(savedVars.customInstances) do
            if custom.category == categoryKey then
                list[#list + 1] = { id = custom.id, name = custom.name, category = custom.category, custom = true, auto = custom.auto == true }
            end
        end
    end
    table.sort(list, function(a, b) return zo_strlower(a.name) < zo_strlower(b.name) end)
    return list
end

-- Returns an array of { key, name, custom } — Overview first, then catalog
-- bosses in encounter order, then the user's custom bosses. When the user
-- has drag-reordered bosses (savedVars.bossOrder[instanceId] = array of
-- keys), that order wins; keys not in the array keep their default position
-- after the ordered ones.
function Data.GetBossEntries(savedVars, instanceId)
    local entries = {
        { key = Data.OVERVIEW_KEY, name = Data.OVERVIEW_NAME, custom = false },
    }

    local inst = instanceById[instanceId]
    if inst and inst.bosses then
        for _, bossName in ipairs(inst.bosses) do
            entries[#entries + 1] = { key = Data.BossKeyFromName(bossName), name = bossName, custom = false }
        end
    end

    if savedVars and savedVars.customBosses and savedVars.customBosses[instanceId] then
        for _, custom in ipairs(savedVars.customBosses[instanceId]) do
            entries[#entries + 1] = { key = custom.key, name = custom.name, custom = true, auto = custom.auto == true }
        end
    end

    local order = savedVars and savedVars.bossOrder and savedVars.bossOrder[instanceId]
    if order then
        local posByKey = {}
        for i, key in ipairs(order) do posByKey[key] = i end
        for i, entry in ipairs(entries) do entry.defaultPos = i end
        table.sort(entries, function(a, b)
            if a.key == Data.OVERVIEW_KEY then return true end
            if b.key == Data.OVERVIEW_KEY then return false end
            local pa, pb = posByKey[a.key], posByKey[b.key]
            if pa and pb then return pa < pb end
            if pa or pb then return pa ~= nil end
            return a.defaultPos < b.defaultPos
        end)
        for _, entry in ipairs(entries) do entry.defaultPos = nil end
    end

    return entries
end
