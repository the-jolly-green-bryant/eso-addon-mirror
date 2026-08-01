-------------------------------------------------------------------------------
----------------------[ SkillBlocker Data  by Ness_Jess ]----------------------
-------------------------------------------------------------------------------

SkillBlocker_NJ = SkillBlocker_NJ or {}
local SB_NJ = SkillBlocker_NJ

SB_NJ.Data = {}
local Data = SB_NJ.Data

Data.Banners = {
    [217699] = true,
    [230289] = true,
}

Data.BuffCombat = {
    [132141] = 172418, -- Blood Frenzy|Кровавое безумие
    [134160] = 134166, -- Simmering Frenzy|Тлеющее безумие
    [135841] = 172648, -- Sated Fury|Утоленная ярость
}

Data.CombatOnly = {
    [78338] = true, -- Guard|Защитник
    [81420] = true, -- Stalwart Guard|Верный защитник
    [81415] = true, -- Mystic Guard|Мистический защитник
}

Data.CriminalAbilities = {
    -- Necromancer
    [122174] = true, -- Frozen Colossus
    [122395] = true, -- Pestilent Colossus
    [122388] = true, -- Glacial Colossus

    [114860] = true, -- Sacrificial Bones
    [117690] = true, -- Blighted Blastbones
    [117749] = true, -- Grave Lord's Sacrifice

    [114317] = true, -- Skeletal Mage
    [118680] = true, -- Skeletal Archer
    [118726] = true, -- Skeletal Arcanist

    [115001] = true, -- Bone Goliath Transformation
    [118664] = true, -- Pummeling Goliath
    [118279] = true, -- Ravenous Goliath

    [115710] = true, -- Spirit Mender
    [118912] = true, -- Spirit Guardian
    [118840] = true, -- Intensive Mender

    -- Vampire
    [32624] = true, -- Blood Scion
    [38932] = true, -- Swarming Scion
    [38931] = true, -- Perfect Scion

    [132141] = true, -- Blood Frenzy
    [134160] = true, -- Simmering Frenzy
    [135841] = true, -- Sated Fury

    [134583] = true, -- Vampiric Drain
    [135905] = true, -- Drain Vigor
    [137259] = true, -- Exhilarating Drain

    [32986] = true, -- Mist Form
    [38963] = true, -- Elusive Mist
    [38965] = true, -- Blood Mist
    
    -- Werewolf
    [32455] = true, -- Werewolf Transformation
    [39075] = true, -- Pack Leader
    [39076] = true, -- Werewolf Berserker

    --[32632] = true, -- Pounce
    --[39105] = true, -- Brutal Pounce
    --[39104] = true, -- Feral Pounce

    --[58310] = true, -- Hircine's Bounty
    --[58317] = true, -- Hircine's Rage
    --[58325] = true, -- Hircine's Fortitude

    --[32633] = true, -- Roar
    --[39113] = true, -- Ferocious Roar
    --[39114] = true, -- Deafening Roar

    --[58405] = true, -- Piercing Howl
    --[58742] = true, -- Howl of Despair
    --[58798] = true, -- Howl of Agony

    --[58855] = true, -- Infectious Claws
    --[58864] = true, -- Claws of Anguish
    --[58879] = true, -- Claws of Life
}

Data.WerewolfUltimate = {
    [32455] = true, -- Werewolf Transformation
    [39075] = true, -- Pack Leader
    [39076] = true, -- Werewolf Berserker
}

Data.DotHot = {
    -- Dragonknight
    [20657] = { maxDuration = 20 }, -- Searing Strike
    [20668] = { maxDuration = 20 }, -- Venomous Claw
    [20660] = { maxDuration = 20 }, -- Burning Embers

    [20917] = { maxDuration = 20 }, -- Fiery Breath
    [20944] = { maxDuration = 20 }, -- Noxious Breath
    [20930] = { maxDuration = 20 }, -- Engulfing Flames

    [28967] = { maxDuration = 15 }, -- Inferno
    [32853] = { maxDuration = 15 }, -- Flames of Oblivion
    [32881] = { maxDuration = 15 }, -- Cauterize

    [20319] = { durations = { 17, 18, 19, 20 } }, -- Spiked Armor
    [20328] = { maxDuration = 20 }, -- Hardened Armor
    [20323] = { maxDuration = 20 }, -- Volatile Armor

    [20245] = { maxDuration = 4 }, -- Dark Talons
    [20252] = { maxDuration = 5 }, -- Burning Talons
    [20251] = { durations = { 7, 8, 9, 10 } }, -- Choking Talons
    
    [29004] = { maxDuration = 20 }, -- Dragon Blood
    [32744] = { maxDuration = 20 }, -- Green Dragon Blood
    [32722] = { maxDuration = 20 }, -- Coagulating Blood

    [21007] = { maxDuration = 6 }, -- Protective Scale
    [21014] = { maxDuration = 6 }, -- Protective Plate
    [21017] = { maxDuration = 6 }, -- Dragon Fire Scale

    [29032] = { maxDuration = 10 }, -- Stonefist
    [31816] = { maxDuration = 10 }, -- Stone Giant

    [29043] = { durations = { 27, 28, 29, 30 } }, -- Molten Weapons
    [31874] = { durations = { 57, 58, 59, 60 } }, -- Igneous Weapons
    [31888] = { maxDuration = 30 }, -- Molten Armaments

    [29071] = { maxDuration = 6.6 }, -- Obsidian Shield
    [29224] = { maxDuration = 6.6 }, -- Igneous Shield
    [32673] = { maxDuration = 6.6 }, -- Fragmented Shield

    [29059] = { maxDuration = 15 }, -- Ash Cloud
    [20779] = { maxDuration = 15 }, -- Cinder Storm
    [32710] = { maxDuration = 15 }, -- Eruption

    -- Sorcerer
    [28025] = { maxDuration = 10 }, -- Encase
    [28308] = { maxDuration = 10 }, -- Shattering Spines
    [28311] = { maxDuration = 10 }, -- Vibrant Shroud

    [24574] = { durations = { 60, 80, 100, 120 } }, -- Defensive Rune

    [24584] = { maxDuration = 20 }, -- Dark Exchange
    [24595] = { maxDuration = 10 }, -- Dark Deal
    [24589] = { maxDuration = 20 }, -- Dark Conversion

    [24828] = { maxDuration = 15 }, -- Daedric Mines
    [24842] = { maxDuration = 15 }, -- Daedric Tomb
    [24834] = { maxDuration = 15 }, -- Daedric Refuge

    [108840] = { maxDuration = 20 }, -- Summon Unstable Familiar - 23304
    [77182] = { maxDuration = 20 }, -- Summon Volatile Familiar - 23316

    [77140] = { maxDuration = 10 }, -- Summon Twilight Tormentor - 24636

    [28418] = { maxDuration = 6 }, -- Conjured Ward
    [29489] = { maxDuration = 6 }, -- Hardened Ward
    [29482] = { maxDuration = 10 }, -- Regenerative Ward

    [23210] = { maxDuration = 20 }, -- Lightning Form
    [23231] = { maxDuration = 20 }, -- Hurricane
    [23213] = { durations = { 27, 28, 29, 30 } }, -- Boundless Storm

    [23182] = { maxDuration = 10 }, -- Lightning Splash
    [23200] = { durations = { 12, 13, 14, 15 } }, -- Liquid Lightning
    [23205] = { maxDuration = 10 }, -- Lightning Flood

    [23670] = { durations = { 30, 31, 32, 33 } }, -- Surge
    [23674] = { maxDuration = 33 }, -- Power Surge
    [23678] = { maxDuration = 33 }, -- Critical Surge

    -- Nightblade
    [18342] = { maxDuration = 10 }, -- Teleport Strike
    [25493] = { maxDuration = 10 }, -- Lotus Fan
    [25484] = { maxDuration = 10 }, -- Ambush

    [33357] = { durations = { 17, 18, 19, 20 } }, -- Mark Target
    [36968] = { durations = { 57, 58, 59, 60 } }, -- Piercing Mark
    [36967] = { maxDuration = 20 }, -- Reaper's Mark

    [33375] = { durations = { 17, 18, 19, 20 } }, -- Blur
    [35414] = { maxDuration = 20 }, -- Mirage
    [35419] = { maxDuration = 20 }, -- Phantasmal Escape

    [25375] = { maxDuration = 10 }, -- Shadow Cloak
    [25380] = { maxDuration = 10 }, -- Shadowy Disguise
    [25377] = { maxDuration = 10 }, -- Dark Cloak

    [33195] = { maxDuration = 10 }, -- Path of Darkness
    [36049] = { maxDuration = 10 }, -- Twisting Path
    [36028] = { maxDuration = 10 }, -- Refreshing Path

    [37475] = { maxDuration = 20 }, -- Manifestation of Terror

    [33211] = { maxDuration = 20 }, -- Summon Shade
    [35434] = { maxDuration = 20 }, -- Dark Shade
    [35441] = { maxDuration = 20 }, -- Shadow Image

    [33291] = { maxDuration = 10 }, -- Strife
    [34838] = { maxDuration = 10 }, -- Funnel Health
    [34835] = { maxDuration = 10 }, -- Swallow Soul

    [33326] = { maxDuration = 20 }, -- Cripple
    [36943] = { maxDuration = 20 }, -- Debilitate
    [36957] = { maxDuration = 20 }, -- Crippling Grasp

    [33316] = { maxDuration = 30 }, -- Drain Power
    [36901] = { maxDuration = 30 }, -- Power Extraction
    [36891] = { maxDuration = 30 }, -- Sap Essence

    -- Warden
    [85999] = { maxDuration = 10 }, -- Cutting Dive
    [86003] = { maxDuration = 10 }, -- Screaming Cliff Racer

    [86023] = { maxDuration = 20 }, -- Swarm
    [86027] = { maxDuration = 20 }, -- Fetcher Infection
    [86031] = { maxDuration = 20 }, -- Growing Swarm

    [86037] = { maxDuration = 6 }, -- Falcon's Swiftness
    [86041] = { maxDuration = 6 }, -- Deceptive Predator
    [86045] = { maxDuration = 6 }, -- Bird of Prey

    [85578] = { maxDuration = 6 }, -- Healing Seed
    [85840] = { maxDuration = 6 }, -- Budding Seeds
    [85845] = { maxDuration = 6 }, -- Corrupting Pollen

    [85552] = { maxDuration = 10 }, -- Living Vines
    [85850] = { maxDuration = 10 }, -- Leeching Vines
    [85851] = { maxDuration = 10 }, -- Living Trellis

    [85539] = { durations = { 17, 18, 19, 20 } }, -- Lotus Flower
    [85854] = { maxDuration = 20 }, -- Green Lotus
    [85855] = { durations = { 57, 58, 59, 60 } }, -- Lotus Blossom

    [85564] = { maxDuration = 10 }, -- Nature's Grasp
    [85858] = { maxDuration = 10 }, -- Nature's Embrace

    [86122] = { durations = { 17, 18, 19, 20 } }, -- Frost Cloak
    [86126] = { maxDuration = 20 }, -- Expansive Frost Cloak
    [86130] = { durations = { 27, 28, 29, 30 } }, -- Ice Fortress

    [86161] = { maxDuration = 12 }, -- Impaling Shards
    [86165] = { maxDuration = 12 }, -- Gripping Shards
    [86169] = { maxDuration = 12 }, -- Winter's Revenge

    [86148] = { maxDuration = 10 }, -- Arctic Wind
    [86152] = { maxDuration = 10 }, -- Polar Wind
    [86156] = { maxDuration = 18 }, -- Arctic Blast

    [86135] = { maxDuration = 6 }, -- Crystallized Shield
    [86139] = { maxDuration = 6 }, -- Crystallized Slab
    [86143] = { maxDuration = 6 }, -- Shimmering Shield

    -- Necromancer
    [114860] = { durations = { 7, 8, 9, 10 } }, -- Sacrificial Bones
    [117749] = { durations = { 17, 18, 19, 20 } }, -- Grave Lord's Sacrifice

    [115252] = { maxDuration = 10 }, -- Boneyard
    [117805] = { maxDuration = 10 }, -- Unnerving Boneyard
    [117850] = { maxDuration = 10 }, -- Avid Boneyard

    [114317] = { maxDuration = 20 }, -- Skeletal Mage
    [118680] = { maxDuration = 20 }, -- Skeletal Archer
    [118726] = { maxDuration = 20 }, -- Skeletal Arcanist

    [115924] = { maxDuration = 20 }, -- Shocking Siphon
    [118763] = { maxDuration = 20 }, -- Detonating Siphon
    [118008] = { maxDuration = 20 }, -- Mystic Siphon

    [115206] = { durations = { 17, 18, 19, 20 } }, -- Bone Armor
    [118237] = { maxDuration = 20 }, -- Beckoning Armor
    [118244] = { maxDuration = 30 }, -- Summoner's Armor

    [115093] = { maxDuration = 11 }, -- Bone Totem
    [118380] = { maxDuration = 11 }, -- Remote Totem
    [118404] = { durations = { 11, 11.6, 12.3, 13 } }, -- Agony Totem

    [115710] = { maxDuration = 16 }, -- Spirit Mender
    [118912] = { maxDuration = 16 }, -- Spirit Guardian
    [118840] = { maxDuration = 8 }, -- Intensive Mender

    [115926] = { maxDuration = 12 }, -- Restoring Tether
    [118070] = { maxDuration = 12 }, -- Braided Tether
    [118122] = { maxDuration = 12 }, -- Mortal Coil

    -- Templar
    [26188] = { maxDuration = 10 }, -- Spear Shards
    [26858] = { maxDuration = 10 }, -- Luminous Shards
    [26869] = { maxDuration = 10 }, -- Blazing Spear

    [22178] = { maxDuration = 6 }, -- Sun Shield
    [22182] = { maxDuration = 6 }, -- Radiant Ward
    [22180] = { maxDuration = 6 }, -- Blazing Shield

    [21726] = { maxDuration = 20 }, -- Sun Fire
    [21729] = { maxDuration = 30 }, -- Vampire's Bane
    [21732] = { maxDuration = 20 }, -- Reflective Light

    [22057] = { maxDuration = 10 }, -- Solar Flare
    [22110] = { maxDuration = 10 }, -- Dark Flare
    [22095] = { maxDuration = 20 }, -- Solar Barrage

    [21761] = { maxDuration = 6 }, -- Backlash
    [21765] = { maxDuration = 6 }, -- Purifying Light
    [21763] = { maxDuration = 6 }, -- Power of the Light

    [22006] = { maxDuration = 10 }, -- Living Dark

    [26209] = { durations = { 17, 18, 19, 20 } }, -- Restoring Aura
    [26807] = { maxDuration = 60 }, -- Radiant Aura

    [22265] = { maxDuration = 20 }, -- Cleansing Ritual
    [22259] = { maxDuration = 20 }, -- Ritual of Retribution
    [22262] = { durations = { 24, 26, 28, 30 } }, -- Extended Ritual

    [22234] = { durations = { 17, 18, 19, 20 } }, -- Rune Focus
    [22240] = { durations = { 22, 23, 24, 25 } }, -- Channeled Focus
    [22237] = { maxDuration = 20 }, -- Restoring Focus

    -- Arcanist
    [185817] = { durations = { 17, 18, 19, 20 } }, -- Abyssal Impact
    [183006] = { maxDuration = 20 }, -- Cephaliarch's Flail
    [185823] = { maxDuration = 20 }, -- Tentacular Dread

    [186452] = { maxDuration = 30 }, -- Tome-Bearer's Inspiration
    [185842] = { maxDuration = 30 }, -- Inspired Scholarship
    [183047] = { maxDuration = 30 }, -- Recuperative Treatise

    [185836] = { maxDuration = 20 }, -- The Imperfect Ring
    [185839] = { maxDuration = 18 }, -- Rune of Displacement
    [182988] = { maxDuration = 20 }, -- Fulminating Rune

    [183165] = { maxDuration = 15 }, -- Runic Jolt
    [183430] = { maxDuration = 15 }, -- Runic Sunder
    [186531] = { maxDuration = 15 }, -- Runic Embrace

    [185894] = { maxDuration = 6 }, -- Runespite Ward
    [185901] = { maxDuration = 6 }, -- Spiteward of the Lucid Mind
    [183241] = { maxDuration = 6 }, -- Impervious Runeward

    [183648] = { durations = { 17, 18, 19, 20 } }, -- Fatewoven Armor
    [185908] = { durations = { 27, 28, 29, 30 } }, -- Cruxweaver Armor
    [186477] = { maxDuration = 20 }, -- Unbreakable Fate

    [185912] = { durations = { 17, 18, 19, 20 } }, -- Runic Defense
    [183401] = { maxDuration = 20 }, -- Runeguard of Still Waters
    [186489] = { maxDuration = 20 }, -- Runeguard of Freedom

    [185918] = { durations = { 7, 8, 9, 10 } }, -- Rune of Eldritch Horror
    [185921] = { maxDuration = 10 }, -- Rune of Uncanny Adoration
    [183267] = { durations = { 14, 16, 18, 20 } }, -- Rune of the Colorless Pool

    [186189] = { maxDuration = 6 }, -- Evolving Runemend
    [198288] = { maxDuration = 6 }, -- Evolving Runemend\Subclass
    [186191] = { maxDuration = 6 }, -- Audacious Runemend
    [198292] = { maxDuration = 6 }, -- Audacious Runemend\Subclass

    [183447] = { maxDuration = 6 }, -- Chakram Shields
    [186207] = { maxDuration = 6 }, -- Chakram of Destiny
    [186209] = { maxDuration = 6 }, -- Tidal Chakram

    [183555] = { durations = { 17, 18, 19, 20 } }, -- Arcanist's Domain
    [186229] = { maxDuration = 20 }, -- Zenas' Empowering Disc
    [186234] = { maxDuration = 20 }, -- Reconstructive Domain

    -- Two Handed
    [38788] = { maxDuration = 15 }, -- Stampede

    [38745] = { maxDuration = 12 }, -- { durations = { 12, 22, 32 } }, -- Carve

    [28297] = { durations = { 17, 18, 19, 20 } }, -- Momentum
    [38794] = { maxDuration = 40 }, -- Forward Momentum
    [38802] = { maxDuration = 20 }, -- Rally

    -- Dual Wield
    [28379] = { maxDuration = 20 }, -- Twin Slashes
    [38839] = { maxDuration = 20 }, -- Rending Slashes
    [38845] = { maxDuration = 20 }, -- Blood Craze

    [28613] = { maxDuration = 20 }, -- Blade Cloak
    [38901] = { durations = { 24, 26, 28, 30 } }, -- Quick Cloak
    [38906] = { maxDuration = 20 }, -- Deadly Cloak

    -- Bow
    [28876] = { maxDuration = 10 }, -- Volley
    [38689] = { durations = { 12, 13, 14, 15 } }, -- Endless Hail
    [38695] = { maxDuration = 10 }, -- Arrow Barrage

    [28869] = { maxDuration = 20 }, -- Poison Arrow
    [38645] = { maxDuration = 20 }, -- Venom Arrow
    [38660] = { maxDuration = 20 }, -- Poison Injection

    -- Destruction Staff
    [28807] = { maxDuration = 10 }, -- Wall of Elements (Flame)
    [28849] = { maxDuration = 10 }, -- Wall of Elements (Frost)
    [28854] = { maxDuration = 10 }, -- Wall of Elements (Shock)

    [39053] = { maxDuration = 10 }, -- Unstable Wall of Elements (Flame)
    [39067] = { maxDuration = 10 }, -- Unstable Wall of Elements (Frost)
    [39073] = { maxDuration = 10 }, -- Unstable Wall of Elements (Shock)

    [39012] = { durations = { 12, 13, 14, 15 } }, -- Elemental Blockade (Flame)
    [39028] = { durations = { 12, 13, 14, 15 } }, -- Elemental Blockade (Frost)
    [39018] = { durations = { 12, 13, 14, 15 } }, -- Elemental Blockade (Shock)

    [29073] = { maxDuration = 20 }, -- Destructive Touch (Flame)
    [29078] = { maxDuration = 20 }, -- Destructive Touch (Frost)
    [29089] = { maxDuration = 20 }, -- Destructive Touch (Shock)

    [38944] = { maxDuration = 20 }, -- Destructive Reach (Flame)
    [38970] = { maxDuration = 20 }, -- Destructive Reach (Frost)
    [38978] = { maxDuration = 20 }, -- Destructive Reach (Shock)

    -- Restoration Staff
    [28385] = { maxDuration = 10 }, -- Grand Healing
    [40058] = { durations = { 12, 13, 14, 15 } }, -- Illustrious Healing
    [40060] = { maxDuration = 10 }, -- Healing Springs

    [28536] = { maxDuration = 10 }, -- Regeneration
    [40076] = { maxDuration = 5 }, -- Rapid Regeneration
    [40079] = { maxDuration = 10 }, -- Radiating Regeneration

    [37243] = { maxDuration = 10 }, -- Radiating Regeneration
    [40103] = { maxDuration = 20 }, -- Blessing of Restoration
    [40094] = { maxDuration = 10 }, -- Combat Prayer

    [37232] = { maxDuration = 6 }, -- Steadfast Ward
    [40130] = { maxDuration = 6 }, -- Ward Ally
    [40126] = { maxDuration = 6 }, -- Healing Ward

    [31531] = { durations = { 18, 20, 22, 24 } }, -- Force Siphon
    [40109] = { durations = { 24, 26, 28, 30 } }, -- Siphon Spirit
    [40116] = { durations = { 24, 26, 28, 30 } }, -- Quick Siphon

    -- Werewolf
    [32632] = { maxDuration = 10 }, -- Pounce
    [39105] = { maxDuration = 10 }, -- Brutal Pounce
    [39104] = { maxDuration = 10 }, -- Feral Pounce

    [32633] = { maxDuration = 10 }, -- Roar
    [39113] = { maxDuration = 10 }, -- Ferocious Roar
    [39114] = { durations = { 7, 8, 9, 10 } }, -- Deafening Roar

    [58742] = { maxDuration = 20 }, -- Howl of Despair

    [58855] = { maxDuration = 20 }, -- Infectious Claws
    [58864] = { maxDuration = 20 }, -- Claws of Anguish
    [58879] = { maxDuration = 20 }, -- Claws of Life

    -- Fighters Guild
    [35737] = { durations = { 17, 18, 19, 20 } }, -- Circle of Protection
    [40181] = { maxDuration = 20 }, -- Turn Evil
    [40169] = { maxDuration = 10 }, -- Ring of Preservation

    [35750] = { maxDuration = 20 }, -- Trap Beast
    [40382] = { maxDuration = 20 }, -- Barbed Trap
    [40372] = { maxDuration = 20 }, -- Lightweight Beast Trap

    -- Mages Guild
    [28567] = { maxDuration = 20 }, -- Entropy
    [40457] = { maxDuration = 20 }, -- Degeneration
    [40452] = { maxDuration = 20 }, -- Structured Entropy

    [31632] = { maxDuration = 20 }, -- Fire Rune
    [40470] = { maxDuration = 20 }, -- Volcanic Rune
    [40465] = { maxDuration = 20 }, -- Scalding Rune

    -- Psijic Order
    [103503] = { maxDuration = 20 }, -- Accelerate
    [103706] = { maxDuration = 60 }, -- Channeled Acceleration
    [103710] = { maxDuration = 20 }, -- Race Against Time

    -- Undaunted
    [39489] = { durations = { 27, 28, 29, 30 } }, -- Blood Altar
    [41967] = { durations = { 34, 36, 38, 40 } }, -- Sanguine Altar
    [41958] = { maxDuration = 30 }, -- Overflowing Altar

    [39425] = { maxDuration = 10 }, -- Trapping Webs
    [41990] = { maxDuration = 10 }, -- Shadow Silk
    [42012] = { maxDuration = 10 }, -- Tangling Webs

    [39298] = { maxDuration = 10 }, -- Necrotic Orb
    [42028] = { maxDuration = 10 }, -- Mystic Orb
    [42038] = { maxDuration = 10 }, -- Energy Orb

    -- Assault
    [33376] = { maxDuration = 10 }, -- Caltrops
    [40255] = { durations = { 12, 13, 14, 15 } }, -- Anti-Cavalry Caltrops
    [40242] = { maxDuration = 10 }, -- Razor Caltrops

    -- Support
    [38570] = { durations = { 17, 18, 19, 20 } }, -- Siege Shield
    [40229] = { maxDuration = 20 }, -- Siege Weapon Shield
    [40226] = { maxDuration = 20 }, -- Propelling Shield
}

Data.IsCrux = {
    [185805] = true, [193331] = true, [183122] = true, [193397] = true,
    [186366] = true, [193398] = true, [185823] = true, [185794] = true,
    [188658] = true, [185803] = true, [188787] = true, [182977] = true,
    [188780] = true, [183006] = true, [183165] = true, [183430] = true,
    [186531] = true, [185894] = true, [185901] = true, [183241] = true,
    [186477] = true, [183261] = true, [198282] = true, [186189] = true,
    [198288] = true, [186191] = true, [198292] = true, [183537] = true,
    [198309] = true, [186193] = true, [198330] = true, [186200] = true,
    [198537] = true, [186207] = true, [198564] = true, [186209] = true,
    [198567] = true, [183542] = true, [186211] = true, [186220] = true,
    --[186452] = true, [185842] = true, [183047] = true, [185908] = true,
}

Data.StackConfig = {
    -- Sorcerer
    [24165]  = { buffId = 203447, minThreshold = 1, maxStack = 8 },  -- Bound Armaments|Призванный арсенал

    -- Dragonknight
    [20805]  = { buffId = 122658, minThreshold = 1, maxStack = 3 },  -- Molten Whip|Лавовый хлыст

    -- Necromancer
    [117624] = { buffId = 117625, minThreshold = 1, maxStack = 3 },  -- Venom Skull|Ядовитый череп

    -- Warden
    [86009] = { buffId = 86009, buffId2 = 178020, minThreshold = 1, maxStack = 2, mode = "stage" }, -- Scorch|Выжигание
    [86019] = { buffId = 86019, buffId2 = 146919, minThreshold = 1, maxStack = 2, mode = "stage" }, -- Subterranean Assault|Нападение из-под земли
    [86015] = { buffId = 86015, buffId2 = 178028, minThreshold = 1, maxStack = 2, mode = "stage" }, -- Deep Fissure|Глубокий разлом

    -- Nightblade
    [61902]  = { buffId = 122585, minThreshold = 5, maxStack = 10 }, -- Grim Focus|Мрачная сосредоточенность
    [61919]  = { buffId = 122586, minThreshold = 5, maxStack = 10 }, -- Merciless Resolve|Безжалостная решимость
    [61927]  = { buffId = 122587, minThreshold = 4, maxStack = 10 }, -- Relentless Focus|Непреклонная сосредоточенность

    -- Arcanist
    -- Herald of the Tome
    [185794] = { buffId = 184220, minThreshold = 1, maxStack = 3, mode = "reverse" }, -- Runeblades|Рунные клинки
    [188658] = { buffId = 184220, minThreshold = 1, maxStack = 3, mode = "reverse" }, -- Runeblades|Рунные клинки\Сабкласс
    [185803] = { buffId = 184220, minThreshold = 1, maxStack = 3, mode = "reverse" }, -- Writhing Runeblades|Извивающиеся рунные клинки
    [188787] = { buffId = 184220, minThreshold = 1, maxStack = 3, mode = "reverse" }, -- Writhing Runeblades|Извивающиеся рунные клинки\Сабкласс
    [182977] = { buffId = 184220, minThreshold = 1, maxStack = 3, mode = "reverse" }, -- Escalating Runeblades|Усиленные рунные клинки
    [188780] = { buffId = 184220, minThreshold = 1, maxStack = 3, mode = "reverse" }, -- Escalating Runeblades|Усиленные рунные клинки\Сабкласс

    [185805] = { buffId = 184220, minThreshold = 1, maxStack = 3 }, -- Fatecarver|Резчик судеб
    [193331] = { buffId = 184220, minThreshold = 1, maxStack = 3 }, -- Fatecarver\Subclass|Резчик судеб\Сабкласс
    [183122] = { buffId = 184220, minThreshold = 1, maxStack = 3 }, -- Exhausting Fatecarver|Ослабляющий резчик судеб
    [193397] = { buffId = 184220, minThreshold = 1, maxStack = 3 }, -- Exhausting Fatecarver\Subclass|Ослабляющий резчик судеб\Сабкласс
    [186366] = { buffId = 184220, minThreshold = 1, maxStack = 3 }, -- Pragmatic Fatecarver|Прагматичный резчик судеб
    [193398] = { buffId = 184220, minThreshold = 1, maxStack = 3 }, -- Pragmatic Fatecarver\Subclass|Прагматичный резчик судеб\Сабкласс

    [183006] = { buffId = 184220, minThreshold = 1, maxStack = 3, mode = "reverse" }, -- Cephaliarch's Flail|Бич цефалиарха
    [185823] = { buffId = 184220, minThreshold = 1, maxStack = 3 }, -- Tentacular Dread|Ужасное щупальце

    --[186452] = { buffId = 184220, minThreshold = 1, maxStack = 3, mode = "reverse" }, -- Tome-Bearer's Inspiration|Вдохновение книгоносца
    --[185842] = { buffId = 184220, minThreshold = 1, maxStack = 3, mode = "reverse" }, -- Inspired Scholarship|Вдохновенные познания
    --[183047] = { buffId = 184220, minThreshold = 1, maxStack = 3, mode = "reverse" }, -- Recuperative Treatise|Укрепляющий трактат

    -- Soldier of Apocrypha
    [183165] = { buffId = 184220, minThreshold = 1, maxStack = 3, mode = "reverse" }, -- Runic Jolt|Рунный удар
    [183430] = { buffId = 184220, minThreshold = 1, maxStack = 3, mode = "reverse" }, -- Runic Sunder|Рунное вспарывание
    [186531] = { buffId = 184220, minThreshold = 1, maxStack = 3, mode = "reverse" }, -- Runic Embrace|Рунные объятия

    [185894] = { buffId = 184220, minThreshold = 1, maxStack = 3 }, -- Runespite Ward|Щит рунной злобы
    [185901] = { buffId = 184220, minThreshold = 1, maxStack = 3 }, -- Spiteward of the Lucid Mind|Оберег ясного ума
    [183241] = { buffId = 184220, minThreshold = 1, maxStack = 3 }, -- Impervious Runeward|Непроницаемый рунный щит

    --[185908] = { buffId = 184220, minThreshold = 1, maxStack = 3, mode = "reverse" }, -- Cruxweaver Armor|Доспех создателя знаков
    [186477] = { buffId = 184220, minThreshold = 1, maxStack = 3 }, -- Unbreakable Fate|Нерушимая судьба

    -- Curative Runeforms
    [183261] = { buffId = 184220, minThreshold = 1, maxStack = 3, mode = "reverse" }, -- Runemend|Рунная подмога
    [198282] = { buffId = 184220, minThreshold = 1, maxStack = 3, mode = "reverse" }, -- Runemend\Subclass|Рунная подмога\Сабкласс
    [186189] = { buffId = 184220, minThreshold = 1, maxStack = 3, mode = "reverse" }, -- Evolving Runemend|Растущая рунная подмога
    [198288] = { buffId = 184220, minThreshold = 1, maxStack = 3, mode = "reverse" }, -- Evolving Runemend\Subclass|Растущая рунная подмога\Сабкласс
    [186191] = { buffId = 184220, minThreshold = 1, maxStack = 3, mode = "reverse" }, -- Audacious Runemend|Дерзкая рунная подмога
    [198292] = { buffId = 184220, minThreshold = 1, maxStack = 3, mode = "reverse" }, -- Audacious Runemend\Subclass|Дерзкая рунная подмога\Сабкласс

    [183537] = { buffId = 184220, minThreshold = 1, maxStack = 3 }, -- Remedy Cascade|Животворный каскад
    [198309] = { buffId = 184220, minThreshold = 1, maxStack = 3 }, -- Remedy Cascade\Subclass|Животворный каскад\Сабкласс
    [186193] = { buffId = 184220, minThreshold = 1, maxStack = 3 }, -- Cascading Fortune|Неумолимая судьба
    [198330] = { buffId = 184220, minThreshold = 1, maxStack = 3 }, -- Cascading Fortune\Subclass|Неумолимая судьба\Сабкласс
    [186200] = { buffId = 184220, minThreshold = 1, maxStack = 3 }, -- Curative Surge|Лечебный прилив
    [198537] = { buffId = 184220, minThreshold = 1, maxStack = 3 }, -- Curative Surge\Subclass|Лечебный прилив\Сабкласс

    [186207] = { buffId = 184220, minThreshold = 1, maxStack = 3, mode = "reverse" }, -- Chakram of Destiny|Чакры судьбы
    [198564] = { buffId = 184220, minThreshold = 1, maxStack = 3, mode = "reverse" }, -- Chakram of Destiny\Subclass|Чакры судьбы\Сабкласс
    [186209] = { buffId = 184220, minThreshold = 1, maxStack = 3 }, -- Tidal Chakram|Чакры приливов
    [198567] = { buffId = 184220, minThreshold = 1, maxStack = 3 }, -- Tidal Chakram\Subclass|Чакры приливов\Сабкласс

    [183542] = { buffId = 184220, minThreshold = 1, maxStack = 3, mode = "reverse" }, -- Apocryphal Gate|Врата Апокрифа
    [186211] = { buffId = 184220, minThreshold = 1, maxStack = 3, mode = "reverse" }, -- Fleet-Footed Gate|Врата стремительности
    [186220] = { buffId = 184220, minThreshold = 1, maxStack = 3, mode = "reverse" }, -- Passage Between Worlds|Проход между мирами
}

Data.DebuffAbilityConfig = {
    [24326] = { debuffIds = { [24326] = 1 }, maxStages = 1 }, -- Daedric Curse
    [24328] = { debuffIds = { [24328] = 1 }, maxStages = 1 }, -- Daedric Prey
    [24330] = { debuffIds = { [24330] = 1, [89491] = 2 }, maxStages = 2 }, -- Haunting Curse
}

Data.TargetHpConfig = {
    -- Nightblade
    [33386] = {}, -- Assassin's Blade|Кинжал убийцы
    [34851] = {}, -- Impale|Пронзание
    [34843] = {}, -- Killer's Blade|Клинок убийцы

    -- Sorcerer
    [18718] = {}, -- Mages' Fury|Ярость магов
    [19123] = {}, -- Mages' Wrath|Гнев магов
    [19109] = {}, -- Endless Fury|Безграничная ярость

    -- Templar
    [63029] = {}, -- Radiant Destruction|Блистательное разрушение
    [63044] = {}, -- Radiant Glory|Блистательная слава
    [63046] = {}, -- Radiant Oppression|Блистательное подавление

    -- Dual Wield
    [28591] = {}, -- Whirlwind|Вихрь
    [38891] = {}, -- Whirling Blades|Вихрь клинков
    [38861] = {}, -- Steel Tornado|Стальной торнадо

    -- Two Handed
    [28302] = {}, -- Reverse Slash|Круговой удар
    [38823] = {}, -- Reverse Slice|Круговой разрез
    [38819] = {}, -- Executioner|Палач
}

Data.TargetHpDefaults = {
    [33386] = 25, [34851] = 25, [34843] = 50,
    [18718] = 20, [19123] = 20, [19109] = 20,
    [63029] = 33, [63044] = 33, [63046] = 40,
    [28591] = 50, [38891] = 50, [38861] = 50,
    [28302] = 50, [38823] = 50, [38819] = 50,
}

Data.ToggleUltimates = {
    [24785] = true, -- Overload
    [24806] = true, -- Power Overload
    [24804] = true  -- Energy Overload
}

Data.BannerBuffRanges = {
    --{ min = 217704, max = 217706 },
    --{ min = 227000, max = 228000 },
    -- Banner Bearer
    [217699] = true, -- Banner Bearer
    [227085] = true, -- Banner Bearer
    [227600] = true, -- Banner Bearer
    [230289] = true, -- Banner Bearer
    [217704] = true, -- Sundering Banner
    [217705] = true, -- Magical Banner
    [217706] = true, -- Shocking Banner
    [227003] = true, -- Fiery Banner
    [227004] = true, -- Shattering Banner
    [227007] = true, -- Restorative Banner
    [227008] = true, -- Fortifying Banner
    [227009] = true, -- Binding Banner
    [227029] = true, -- Binding Banner
    [227030] = true, -- Bannerman
    [227066] = true, -- Remedying Banner
    [227067] = true, -- Resurgent Banner
    [227069] = true, -- Defensive Banner
    [227070] = true, -- Defensive Banner
    [227071] = true, -- Swift Banner
    [227073] = true, -- Defiant Banner
    [227082] = true, -- Charging Banner
    [227086] = true, -- Dragonknight's Banner
    [227087] = true, -- Dragonknight's Banner
    [227088] = true, -- Dragonknight's Banner
    [227089] = true, -- Dragonknight's Banner
    [227091] = true, -- Templar's Banner
    [227092] = true, -- Templar's Banner
    [227093] = true, -- Sorcerer's Banner
    [227094] = true, -- Warden's Banner
    [227095] = true, -- Sorcerer's Banner
    [227096] = true, -- Sorcerer's Banner
    [227101] = true, -- Nightblade's Banner
    [227102] = true, -- Nightblade's Banner
    [227103] = true, -- Nightblade's Banner
    [227104] = true, -- Nightblade's Banner
    [227106] = true, -- Warden's Banner
    [227107] = true, -- Warden's Banner
    [227108] = true, -- Warden's Banner
    [227109] = true, -- Warden's Banner
    [227110] = true, -- Necromancer's Banner
    [227111] = true, -- Necromancer's Banner
    [227112] = true, -- Necromancer's Banner
    [227113] = true, -- Necromancer's Banner
    [227115] = true, -- Necromancer's Banner
    [227116] = true, -- Arcanist's Banner
    [227120] = true, -- Bannerman
    [230293] = true, -- Charging Banner
    [231753] = true, -- Sorcerer's Banner
}

Data.ScribingLogic = {
    primaryScript = 15,
    triggers = {
        [34] = { ignoreClass = nil },
        [31] = { ignoreClass = 6 },
    }
}

Data.ScribingDotHot = {}
local ScribingData = Data.ScribingDotHot

local function AddScribingData(ids, fixedDuration, s1, s2, s3)
    for _, id in ipairs(ids) do
        ScribingData[id] = {
            fixed = fixedDuration,
            script1 = s1,
            script2 = s2,
            script3 = s3
        }
    end
end

-- Smash (Двуручное)
AddScribingData(
    {217184, 217178, 217820, 219972, 217179, 227609},
    nil,
    { [12] = 15, [20] = 6 }, 
    { [24] = 20, [32] = 10, [34] = 10 }, 
    { [46] = 10, [47] = 20, [50] = 20, [51] = 20, [52] = 10, [58] = 20, [60] = 20, [63] = 20, [64] = 20 } 
)

-- Shield Throw (Щит и меч)
AddScribingData(
    {217061, 217808, 216973, 221999, 222966},
    nil,
    { [12] = 15, [14] = 15 },
    { [24] = 10, [34] = 10 },
    { [44] = 7, [46] = 10, [48] = 10, [49] = 10, [50] = 10, [52] = 10, [60] = 10, [61] = 10, [62] = 20 }
)

-- Traveling Knife (Парники)
AddScribingData(
    {217872, 217473, 217340, 232112},
    nil,
    nil,
    { [24] = 20, [29] = 10, [33] = 6, [40] = 6, [41] = 5 },
    { [44] = 7, [46] = 10, [47] = 20, [51] = 20, [52] = 10, [58] = 20, [59] = 20, [60] = 20, [65] = 20, [68] = 20 }
)

-- Vault (Лук)
AddScribingData(
    {214960, 214978, 217777, 214974, 216674},
    nil,
    { [12] = 15 },
    { [24] = 20, [25] = 5, [32] = 10, [34] = 10, [35] = 20 },
    { [44] = 7, [46] = 10, [47] = 20, [49] = 10, [51] = 20, [52] = 10, [57] = 20, [58] = 20, [59] = 20, [60] = 20, [65] = 20 }
)

-- Elemental Explosion (Посох разрушения)
AddScribingData(
    {217228, 229857, 222313},
    nil,
    { [16] = 5 },
    { [24] = 20, [25] = 6, [33] = 6 },
    { [44] = 7, [46] = 10, [52] = 10, [61] = 20, [62] = 20, [65] = 20, [66] = 20, [67] = 20, [69] = 20 }
)

-- Mender's Bond (Посох восстановления)
AddScribingData(
    {220549, 243686, 217257, 220747},
    12,
    nil, nil, nil
)

-- Soul Burst (Магия душ)
AddScribingData(
    {217462, 217465, 217460, 217459, 217978, 217979},
    nil,
    { [20] = 6 },
    { [24] = 20, [25] = 6, [30] = 10, [32] = 10, [39] = 5 },
    { [46] = 10, [47] = 20, [48] = 20, [52] = 10, [55] = 20, [57] = 20, [60] = 20, [64] = 20, [69] = 20 }
)

-- Wield Soul (Магия душ)
AddScribingData(
    {215731, 219780, 216802, 216813, 217784, 221930},
    nil,
    { [20] = 6 },
    { [24] = 10, [30] = 5, [32] = 10, [39] = 5 },
    { [46] = 10, [48] = 10, [50] = 10, [52] = 10, [53] = 10, [57] = 10, [60] = 10, [61] = 10, [64] = 10, [66] = 10 }
)

-- Torchbearer (Гильдия бойцов)
AddScribingData(
    {217630, 217637, 223292, 217607, 217633},
    nil,
    nil,
    { [24] = 20, [25] = 6, [41] = 6 },
    { [46] = 10, [48] = 20, [49] = 20, [50] = 20, [52] = 10, [56] = 20, [61] = 20, [63] = 20, [64] = 20, [68] = 20 }
)

-- Ulfsild's Contingency (Гильдия магов)
AddScribingData(
    {222678, 240150, 240149, 240148},
    nil,
    { [20] = 6 },
    { [24] = 20, [25] = 6, [32] = 10, [38] = 6, [41] = 5, [70] = 8 },
    { [46] = 10, [48] = 20, [52] = 10, [54] = 20, [57] = 20, [58] = 20, [59] = 20, [62] = 20, [64] = 20, [69] = 20 }
)

-- Trample (Штурм)
AddScribingData(
    {220541, 217663, 220542, 220545},
    nil,
    nil,
    { [24] = 20, [25] = 10, [35] = 10 },
    { [44] = 7, [46] = 10, [47] = 10, [52] = 10, [54] = 10, [56] = 10, [59] = 20, [61] = 20, [63] = 20, [66] = 20 }
)