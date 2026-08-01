-- ═══════════════════════════════════════════════════════════════
-- Triple Triad ESO — Card Database
-- 50 cards across 5 rarity tiers
-- All icons use confirmed ESO built-in texture paths
-- ═══════════════════════════════════════════════════════════════

local TT = TripleTriadESO

-- ESO texture base: /esoui/art/icons/
-- Pet icons:        pet_NNN.dds (confirmed via guild MOTD usage)
-- Ability icons:    ability_*.dds
-- Achievement icons: achievement_*.dds

TT.CardDatabase = {
    -- ═══════════════════════════════════════════
    -- ★1 CARDS (Common) - 12 cards
    -- ═══════════════════════════════════════════
    {
        id = 1, name = "Mudcrab", stars = 1,
        top = 2, right = 3, bottom = 1, left = 2,
        element = "water",
        desc = "A common crustacean found near every body of water in Tamriel.",
        icon = "/esoui/art/icons/pet_001.dds",  -- confirmed: mudcrab
    },
    {
        id = 2, name = "Scamp", stars = 1,
        top = 1, right = 2, bottom = 3, left = 2,
        element = "fire",
        desc = "A diminutive Daedric nuisance, more trouble than it's worth.",
        icon = "/esoui/art/icons/pet_014.dds",  -- confirmed: daedra scamp
    },
    {
        id = 3, name = "Nixad", stars = 1,
        top = 3, right = 1, bottom = 2, left = 2,
        element = "air",
        desc = "A mischievous fae creature that flits through Tamriel's wilds.",
        icon = "/esoui/art/icons/pet_057.dds",  -- confirmed: dark pixie/nixad
    },
    {
        id = 4, name = "Fennec Fox", stars = 1,
        top = 2, right = 2, bottom = 2, left = 3,
        element = nil,
        desc = "A tiny desert predator with oversized ears.",
        icon = "/esoui/art/icons/pet_027.dds",  -- confirmed: fennec fox
    },
    {
        id = 5, name = "Netch Calf", stars = 1,
        top = 3, right = 2, bottom = 2, left = 1,
        element = "air",
        desc = "A young netch, floating lazily through the Morrowind sky.",
        icon = "/esoui/art/icons/pet_037.dds",  -- confirmed: netch calf
    },
    {
        id = 6, name = "Guar", stars = 1,
        top = 2, right = 1, bottom = 4, left = 1,
        element = nil,
        desc = "A sturdy pack animal favored by the Dunmer.",
        icon = "/esoui/art/icons/pet_003.dds",  -- confirmed: guar
    },
    {
        id = 7, name = "Boar", stars = 1,
        top = 1, right = 4, bottom = 1, left = 2,
        element = nil,
        desc = "A stubborn tusked beast found throughout Tamriel's forests.",
        icon = "/esoui/art/icons/pet_028.dds",  -- confirmed: boar
    },
    {
        id = 8, name = "Bantam Guar", stars = 1,
        top = 2, right = 2, bottom = 1, left = 4,
        element = nil,
        desc = "An adorable miniature guar, popular as a pet.",
        icon = "/esoui/art/icons/pet_012.dds",  -- confirmed: bantam guar
    },
    {
        id = 9, name = "Clannfear Runt", stars = 1,
        top = 4, right = 1, bottom = 1, left = 2,
        element = "fire",
        desc = "A juvenile Daedric beast, barely tamed.",
        icon = "/esoui/art/icons/ability_sorcerer_unstable_clannfear.dds",
    },
    {
        id = 10, name = "Winged Serpent", stars = 1,
        top = 1, right = 3, bottom = 2, left = 3,
        element = "air",
        desc = "A flying snake from the tropical jungles of Black Marsh.",
        icon = "/esoui/art/icons/pet_077.dds",  -- confirmed: winged-snake
    },
    {
        id = 11, name = "Dwemer Spider", stars = 1,
        top = 3, right = 3, bottom = 1, left = 1,
        element = nil,
        desc = "An animated Dwemer construct that patrols ancient ruins.",
        icon = "/esoui/art/icons/pet_007.dds",  -- confirmed: dwemer spider
    },
    {
        id = 12, name = "Dragon Frog", stars = 1,
        top = 1, right = 1, bottom = 3, left = 4,
        element = "water",
        desc = "An amphibian with tiny vestigial wings, native to Black Marsh.",
        icon = "/esoui/art/icons/pet_055.dds",  -- confirmed: blue winged-frog
    },

    -- ═══════════════════════════════════════════
    -- ★2 CARDS (Uncommon) - 12 cards
    -- ═══════════════════════════════════════════
    {
        id = 13, name = "Wolf", stars = 2,
        top = 3, right = 4, bottom = 2, left = 3,
        element = nil,
        desc = "Cunning predators that hunt in packs across Tamriel.",
        icon = "/esoui/art/icons/pet_071.dds",  -- confirmed: wolf
    },
    {
        id = 14, name = "Ice Wraith", stars = 2,
        top = 4, right = 3, bottom = 3, left = 2,
        element = "ice",
        desc = "A spectral serpent of the frozen wastelands.",
        icon = "/esoui/art/icons/pet_018.dds",  -- confirmed: ice-wraith
    },
    {
        id = 15, name = "Panther", stars = 2,
        top = 2, right = 5, bottom = 3, left = 2,
        element = nil,
        desc = "A sleek black predator that stalks the jungle shadows.",
        icon = "/esoui/art/icons/pet_021.dds",  -- confirmed: dark grey panther
    },
    {
        id = 16, name = "Bear", stars = 2,
        top = 5, right = 2, bottom = 3, left = 3,
        element = nil,
        desc = "A powerful beast that roams the wilds of northern Tamriel.",
        icon = "/esoui/art/icons/pet_044.dds",  -- confirmed: black bear cub
    },
    {
        id = 17, name = "Kagouti", stars = 2,
        top = 3, right = 3, bottom = 5, left = 2,
        element = nil,
        desc = "A fierce reptilian predator native to Morrowind.",
        icon = "/esoui/art/icons/pet_024.dds",  -- confirmed: goat-skull/kagouti-like
    },
    {
        id = 18, name = "Spider", stars = 2,
        top = 2, right = 4, bottom = 4, left = 3,
        element = nil,
        desc = "Giant spiders spinning webs in Tamriel's dark places.",
        icon = "/esoui/art/icons/pet_004.dds",  -- confirmed: tan spider
    },
    {
        id = 19, name = "Senche-Tiger", stars = 2,
        top = 4, right = 4, bottom = 2, left = 3,
        element = nil,
        desc = "The great cats of Elsweyr, swift and deadly.",
        icon = "/esoui/art/icons/pet_049.dds",  -- confirmed: white tiger
    },
    {
        id = 20, name = "Mammoth", stars = 2,
        top = 3, right = 2, bottom = 5, left = 4,
        element = nil,
        desc = "A massive woolly beast that shakes the ground of Skyrim.",
        icon = "/esoui/art/icons/pet_052.dds",  -- confirmed: mammoth
    },
    {
        id = 21, name = "Honey Badger", stars = 2,
        top = 5, right = 3, bottom = 2, left = 3,
        element = nil,
        desc = "A ferocious little creature that fears absolutely nothing.",
        icon = "/esoui/art/icons/pet_062.dds",  -- confirmed: honey badger
    },
    {
        id = 22, name = "Imp", stars = 2,
        top = 3, right = 5, bottom = 2, left = 3,
        element = "fire",
        desc = "A mischievous lesser Daedra, more annoying than dangerous.",
        icon = "/esoui/art/icons/pet_006.dds",  -- confirmed: daedra imp
    },
    {
        id = 23, name = "War Hound", stars = 2,
        top = 4, right = 2, bottom = 4, left = 3,
        element = nil,
        desc = "A loyal beast bred for battle by Tamriel's armies.",
        icon = "/esoui/art/icons/pet_079.dds",  -- confirmed: curled-tail dog
    },
    {
        id = 24, name = "Lion", stars = 2,
        top = 3, right = 3, bottom = 3, left = 5,
        element = nil,
        desc = "The king of beasts, proud symbol of northern Elsweyr.",
        icon = "/esoui/art/icons/pet_056.dds",  -- confirmed: lion cub
    },

    -- ═══════════════════════════════════════════
    -- ★3 CARDS (Rare) - 12 cards
    -- ═══════════════════════════════════════════
    {
        id = 25, name = "Troll", stars = 3,
        top = 5, right = 4, bottom = 6, left = 3,
        element = nil,
        desc = "Regenerating brutes that fear only fire.",
        icon = "/esoui/art/icons/achievement_frostvaulttroll.dds",
    },
    {
        id = 26, name = "Clannfear", stars = 3,
        top = 6, right = 5, bottom = 3, left = 4,
        element = "fire",
        desc = "A vicious Daedric beast summoned from Oblivion.",
        icon = "/esoui/art/icons/ability_sorcerer_unstable_clannfear.dds",
    },
    {
        id = 27, name = "Ogrim", stars = 3,
        top = 7, right = 3, bottom = 5, left = 4,
        element = "fire",
        desc = "Massive Daedric enforcers of considerable strength.",
        icon = "/esoui/art/icons/achievement_wrothgar_029.dds",
    },
    {
        id = 28, name = "Senche-Leopard", stars = 3,
        top = 4, right = 6, bottom = 5, left = 4,
        element = nil,
        desc = "A fearsome spotted predator from the jungles of Elsweyr.",
        icon = "/esoui/art/icons/pet_094.dds",  -- confirmed: black panther cub
    },
    {
        id = 29, name = "Gargoyle", stars = 3,
        top = 5, right = 5, bottom = 5, left = 4,
        element = nil,
        desc = "Animated stone guardians found in ancient ruins.",
        icon = "/esoui/art/icons/achievement_gargoyle.dds",
    },
    {
        id = 30, name = "Werewolf", stars = 3,
        top = 6, right = 6, bottom = 3, left = 4,
        element = nil,
        desc = "Cursed by Hircine, deadly under the moons.",
        icon = "/esoui/art/icons/ability_werewolf_001.dds",
    },
    {
        id = 31, name = "Nereid", stars = 3,
        top = 4, right = 5, bottom = 4, left = 7,
        element = "water",
        desc = "Beautiful and deadly water spirits.",
        icon = "/esoui/art/icons/achievement_nereid.dds",
    },
    {
        id = 32, name = "Lurcher", stars = 3,
        top = 5, right = 4, bottom = 7, left = 3,
        element = nil,
        desc = "Nature spirits bound into wooden forms by the Wyrd.",
        icon = "/esoui/art/icons/achievement_lurcher.dds",
    },
    {
        id = 33, name = "Frost Atronach", stars = 3,
        top = 4, right = 7, bottom = 4, left = 5,
        element = "ice",
        desc = "Elemental Daedra of frozen fury.",
        icon = "/esoui/art/icons/achievement_frostatronach.dds",
    },
    {
        id = 34, name = "Flame Atronach", stars = 3,
        top = 5, right = 4, bottom = 4, left = 6,
        element = "fire",
        desc = "Graceful Daedric beings wreathed in flame.",
        icon = "/esoui/art/icons/achievement_flameatronach.dds",
    },
    {
        id = 35, name = "Minotaur", stars = 3,
        top = 6, right = 4, bottom = 6, left = 3,
        element = nil,
        desc = "Ancient bull-men, children of Morihaus.",
        icon = "/esoui/art/icons/achievement_minotaur.dds",
    },
    {
        id = 36, name = "Lamia", stars = 3,
        top = 3, right = 6, bottom = 5, left = 6,
        element = "water",
        desc = "Serpentine creatures with enchanting voices.",
        icon = "/esoui/art/icons/achievement_lamia.dds",
    },

    -- ═══════════════════════════════════════════
    -- ★4 CARDS (Epic) - 8 cards
    -- ═══════════════════════════════════════════
    {
        id = 37, name = "Dragon Priest", stars = 4,
        top = 8, right = 6, bottom = 5, left = 7,
        element = "fire",
        desc = "Undying servants of the Dragons, wielding terrible magic.",
        icon = "/esoui/art/icons/achievement_dragonpriest.dds",
    },
    {
        id = 38, name = "Watcher", stars = 4,
        top = 6, right = 8, bottom = 5, left = 7,
        element = nil,
        desc = "Daedric sentinels from the depths of Coldharbour.",
        icon = "/esoui/art/icons/achievement_watcher.dds",
    },
    {
        id = 39, name = "Bone Colossus", stars = 4,
        top = 7, right = 5, bottom = 8, left = 6,
        element = nil,
        desc = "A towering construct of fused bones and dark magic.",
        icon = "/esoui/art/icons/achievement_bonecolossus.dds",
    },
    {
        id = 40, name = "Storm Atronach", stars = 4,
        top = 5, right = 9, bottom = 6, left = 6,
        element = "lightning",
        desc = "Elemental fury given form, crackling with power.",
        icon = "/esoui/art/icons/ability_sorcerer_storm_atronach.dds",
    },
    {
        id = 41, name = "Mantikora", stars = 4,
        top = 8, right = 7, bottom = 6, left = 5,
        element = nil,
        desc = "Legendary predators said to be creations of Molag Bal.",
        icon = "/esoui/art/icons/achievement_mantikora.dds",
    },
    {
        id = 42, name = "Titan", stars = 4,
        top = 7, right = 6, bottom = 7, left = 7,
        element = "fire",
        desc = "Winged Daedric terrors that darken the skies.",
        icon = "/esoui/art/icons/achievement_update11_dungeons_002.dds",
    },
    {
        id = 43, name = "Iron Atronach", stars = 4,
        top = 9, right = 5, bottom = 7, left = 6,
        element = "fire",
        desc = "The most terrible of atronachs, forged of molten iron.",
        icon = "/esoui/art/icons/achievement_ironatronach.dds",
    },
    {
        id = 44, name = "Voriplasm", stars = 4,
        top = 6, right = 7, bottom = 9, left = 5,
        element = "water",
        desc = "A sentient ooze that dissolves everything it touches.",
        icon = "/esoui/art/icons/achievement_voriplasm.dds",
    },

    -- ═══════════════════════════════════════════
    -- ★5 CARDS (Legendary) - 6 cards
    -- ═══════════════════════════════════════════
    {
        id = 45, name = "Molag Bal", stars = 5,
        top = 10, right = 8, bottom = 7, left = 9,
        element = "fire",
        desc = "The Lord of Domination, Harvester of Souls.",
        icon = "/esoui/art/icons/achievement_ic_007.dds",
    },
    {
        id = 46, name = "Mehrunes Dagon", stars = 5,
        top = 9, right = 10, bottom = 8, left = 7,
        element = "fire",
        desc = "The Prince of Destruction, Lord of Revolution.",
        icon = "/esoui/art/icons/achievement_darkbrotherhood_018.dds",
    },
    {
        id = 47, name = "Mephala", stars = 5,
        top = 7, right = 9, bottom = 10, left = 8,
        element = nil,
        desc = "The Webspinner, Spinner of the Dark Tapestry.",
        icon = "/esoui/art/icons/achievement_summerset_boss_005.dds",
    },
    {
        id = 48, name = "Kaalgrontiid", stars = 5,
        top = 9, right = 8, bottom = 9, left = 8,
        element = "fire",
        desc = "A fearsome Dragon who sought to rival Akatosh himself.",
        icon = "/esoui/art/icons/achievement_elsweyr_dragon_001.dds",
    },
    {
        id = 49, name = "Nahviintaas", stars = 5,
        top = 8, right = 9, bottom = 8, left = 10,
        element = "fire",
        desc = "An ancient Dragon of unrivaled cunning and power.",
        icon = "/esoui/art/icons/achievement_elsweyr_dragon_002.dds",
    },
    {
        id = 50, name = "Daedric Titan", stars = 5,
        top = 10, right = 7, bottom = 9, left = 9,
        element = "fire",
        desc = "The ultimate weapon of Molag Bal, a corrupted dragon.",
        icon = "/esoui/art/icons/achievement_update11_dungeons_003.dds",
    },

    -- ═══════════════════════════════════════════
    -- EXTRA CARDS (51-57) — using remaining confirmed icons
    -- ═══════════════════════════════════════════
    {
        id = 51, name = "Hound", stars = 1,
        top = 2, right = 1, bottom = 3, left = 3,
        element = nil,
        desc = "A loyal companion, faithful to the end.",
        icon = "/esoui/art/icons/pet_009.dds",  -- confirmed: white dog
    },
    {
        id = 52, name = "Hoarvor", stars = 1,
        top = 4, right = 2, bottom = 2, left = 1,
        element = nil,
        desc = "A bloated tick-like parasite that drains the life from its prey.",
        icon = "/esoui/art/icons/pet_038.dds",  -- confirmed: tick/insect
    },
    {
        id = 53, name = "Torchbug", stars = 1,
        top = 1, right = 3, bottom = 1, left = 4,
        element = "fire",
        desc = "A luminous insect that lights the nights of Tamriel.",
        icon = "/esoui/art/icons/pet_093.dds",  -- confirmed: butterflies/glowing insects
    },
    {
        id = 54, name = "Mountain Goat", stars = 1,
        top = 3, right = 1, bottom = 3, left = 2,
        element = nil,
        desc = "A hardy beast that clings to Tamriel's highest peaks.",
        icon = "/esoui/art/icons/pet_035.dds",  -- confirmed: white goat
    },
    {
        id = 55, name = "Dwemer Sphere", stars = 2,
        top = 4, right = 5, bottom = 3, left = 2,
        element = nil,
        desc = "An ancient automaton that patrols Dwemer ruins on a single wheel.",
        icon = "/esoui/art/icons/pet_020.dds",  -- confirmed: dwemer ball sentry
    },
    {
        id = 56, name = "Shadow Fox", stars = 2,
        top = 3, right = 2, bottom = 4, left = 5,
        element = nil,
        desc = "A dark-furred fox that slinks through the night unseen.",
        icon = "/esoui/art/icons/pet_091.dds",  -- confirmed: black fox
    },
    {
        id = 57, name = "Breton Terrier", stars = 2,
        top = 5, right = 4, bottom = 2, left = 2,
        element = nil,
        desc = "A scrappy little war dog bred for the Daggerfall Covenant.",
        icon = "/esoui/art/icons/pet_089.dds",  -- confirmed: black pug/terrier
    },
}

-- Build lookup tables for quick access
TT.CardsByID = {}
TT.CardsByName = {}
for _, card in ipairs(TT.CardDatabase) do
    TT.CardsByID[card.id] = card
    TT.CardsByName[string.lower(card.name)] = card
end
