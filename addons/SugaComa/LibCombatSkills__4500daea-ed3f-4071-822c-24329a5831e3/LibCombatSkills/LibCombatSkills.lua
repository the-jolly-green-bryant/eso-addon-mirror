--------------------------------------------------------------
-- LibCombatSkills.lua
-- Magplar Skill Definition File
-- Tracks all timed Templar skills + morphs with durations
--------------------------------------------------------------

LibCombatSkills = LibCombatSkills or {}
local LCS = LibCombatSkills


-- duration = seconds skill buff or DOT typically lasts
-- 0 = instant, not tracked

LibCombatSkills.list = {
-- CombatSkills.lua
-- Comprehensive list of all ESO skills with timed durations
-- Grouped by category (Classes, Weapons, Guilds, etc.)
-- Durations are in seconds; 0 for instant/no timer
-- IDs are approximate based on UESP data; "ID not listed" where unavailable
-- Only includes active skills (placeable on bar) with duration > 0
-- Durations factor max-rank passives (e.g., Enduring Rays +4s for Templar Dawn's Wrath DoTs/Ultimates)
-- Console-friendly: No UI mods, uses d() for output where applicable


    ----------------------------------------------------------
    -- Templar Skills
    ----------------------------------------------------------
    -- Aedric Spear
    [26188] = { name = "Spear Shards", duration = 10.0 },
    [26858] = { name = "Luminous Shards", duration = 10.0 },
    [26869] = { name = "Blazing Spear", duration = 10.0 },
    [26792] = { name = "Biting Jabs", duration = 1.0 },
    [26797] = { name = "Puncturing Sweep", duration = 1.0 },
    [22138] = { name = "Radial Sweep", duration = 6.0 },
    [22139] = { name = "Crescent Sweep", duration = 6.0 },
    [22144] = { name = "Empowering Sweep", duration = 6.0 },
    [22178] = { name = "Sun Shield", duration = 10.0 },
    [22180] = { name = "Blazing Shield", duration = 10.0 },
    [22182] = { name = "Radiant Ward", duration = 10.0 },
    [22223] = { name = "Piercing Javelin", duration = 0.5 },  -- Instant, ignore
    [22226] = { name = "Aurora Javelin", duration = 0.5 },   -- Instant, ignore
    [22227] = { name = "Binding Javelin", duration = 4.0 },
    [22235] = { name = "Focused Charge", duration = 15.0 },
    [22237] = { name = "Explosive Charge", duration = 15.0 },
    [22238] = { name = "Toppling Charge", duration = 15.0 },

    -- Dawn’s Wrath (Enduring Rays: +4s to Sun Fire, Eclipse, Solar Flare, Nova, and morphs)
    [21726] = { name = "Sun Fire", duration = 16.0 },  -- Base 12s +4s
    [21732] = { name = "Reflective Light", duration = 24.0 },  -- Base 20s +4s? UESP lists 24s base, but adjusted
    [21729] = { name = "Vampire’s Bane", duration = 32.0 },  -- Base 30s +4s
    [22057] = { name = "Solar Flare", duration = 14.0 },  -- Base 10s +4s
    [22095] = { name = "Solar Barrage", duration = 22.0 },  -- Base 20s +4s
    [22110] = { name = "Dark Flare", duration = 14.0 },  -- Base 10s +4s
    [21752] = { name = "Nova", duration = 12.0 },  -- Base 8s +4s
    [21755] = { name = "Solar Prison", duration = 12.0 },
    [21758] = { name = "Solar Disturbance", duration = 12.0 },
    [21776] = { name = "Eclipse", duration = 8.0 },  -- Base 4s +4s
    [21780] = { name = "Total Dark", duration = 8.0 },
    [21783] = { name = "Living Dark", duration = 14.0 },  -- Base 10s +4s
    [21794] = { name = "Backlash", duration = 6.0 },  -- No adjustment
    [21796] = { name = "Purifying Light", duration = 6.0 },
    [21799] = { name = "Power of the Light", duration = 6.0 },
    [63029] = { name = "Radiant Destruction", duration = 3.8 },  -- Channel, no adjustment
    [63044] = { name = "Radiant Glory", duration = 3.8 },
    [63046] = { name = "Radiant Oppression", duration = 3.8 },

    -- Restoring Light (Sacred Ground: Minor Mending 4s post-area, but core durations unchanged)
    [22253] = { name = "Honor the Dead", duration = 0.5 },  -- Instant
    [22217] = { name = "Rushed Ceremony", duration = 0.5 },  -- Instant
    [22314] = { name = "Hasty Prayer", duration = 10.0 },  -- Minor Expedition 10s on morph
    [22256] = { name = "Breath of Life", duration = 0.5 },  -- Instant
    [22234] = { name = "Restoring Aura", duration = 20.0 },
    [26807] = { name = "Radiant Aura", duration = 60.0 },  -- Minor Endurance 60s on morph
    [26809] = { name = "Repentance", duration = 0.5 },  -- Instant
    [22263] = { name = "Cleansing Ritual", duration = 20.0 },  -- Heal every 2s for 20s
    [22262] = { name = "Extended Ritual", duration = 30.0 },   -- 10 second increase
    [22259] = { name = "Ritual of Retribution", duration = 20.0 }, -- AoE Damage 
    [22268] = { name = "Rune Focus", duration = 20.0 },
    [22240] = { name = "Channeled Focus", duration = 25.0 },
    [22271] = { name = "Restoring Focus", duration = 20.0 },
    [22302] = { name = "Remembrance", duration = 4.0 },
    [22305] = { name = "Practiced Incantation", duration = 8.0 },
    [22306] = { name = "Rite of Passage", duration = 4.0 },

    ----------------------------------------------------------
    -- Dragonknight Skills
    ----------------------------------------------------------
    -- Ardent Flame (Combustion: +4s to DoTs where applicable)
    [23806] = { name = "Lava Whip", duration = 0.5 },  -- Instant
    [23811] = { name = "Molten Whip", duration = 0.5 },
    [23813] = { name = "Flame Lash", duration = 0.5 },
    [20917] = { name = "Searing Strike", duration = 24.0 },  -- Base 20s +4s
    [20930] = { name = "Venomous Claw", duration = 24.0 },
    [20944] = { name = "Burning Embers", duration = 24.0 },
    [20917] = { name = "Fiery Breath", duration = 24.0 },
    [20944] = { name = "Noxious Breath", duration = 24.0 },
    [20930] = { name = "Engulfing Flames", duration = 24.0 },
    [20492] = { name = "Fiery Grip", duration = 0.5 },  -- Instant
    [20499] = { name = "Chains of Devastation", duration = 0.5 },
    [20496] = { name = "Unrelenting Grip", duration = 0.5 },
    [31816] = { name = "Inferno", duration = 0.5 },  -- Toggle
    [31874] = { name = "Flames of Oblivion", duration = 0.5 },
    [31888] = { name = "Cauterize", duration = 0.5 },
    [32715] = { name = "Dragonknight Standard", duration = 16.0 },
    [32719] = { name = "Shifting Standard", duration = 25.0 },
    [32722] = { name = "Standard of Might", duration = 16.0 },

    -- Draconic Power (Elder Dragon: +4s to DoTs)
    [20319] = { name = "Spiked Armor", duration = 20.0 },
    [20328] = { name = "Hardened Armor", duration = 20.0 },
    [20326] = { name = "Volatile Armor", duration = 20.0 },
    [20243] = { name = "Dark Talons", duration = 4.0 },  -- Root 4s
    [20252] = { name = "Burning Talons", duration = 4.0 },  -- DoT 4s
    [20251] = { name = "Choking Talons", duration = 4.0 },
    [29004] = { name = "Dragon Blood", duration = 20.0 },
    [32744] = { name = "Green Dragon Blood", duration = 20.0 },
    [32722] = { name = "Coagulating Blood", duration = 20.0 },
    [32632] = { name = "Protective Scale", duration = 6.0 },
    [32636] = { name = "Protective Plate", duration = 6.0 },
    [32637] = { name = "Dragon Fire Scale", duration = 6.0 },
    [31837] = { name = "Inhale", duration = 0.5 },  -- Instant
    [32792] = { name = "Deep Breath", duration = 0.5 },
    [32785] = { name = "Draw Essence", duration = 0.5 },
    [32715] = { name = "Dragon Leap", duration = 0.5 },
    [32719] = { name = "Take Flight", duration = 0.5 },
    [32722] = { name = "Ferocious Leap", duration = 6.0 },  -- Stun 6s

    -- Earthen Heart (Battle Roar: no direct duration impact)
    [29032] = { name = "Stonefist", duration = 10.0 },
    [31816] = { name = "Obsidian Shard", duration = 0.5 },
    [133027] = { name = "Stone Giant", duration = 10.0 },
    [29043] = { name = "Molten Weapons", duration = 30.0 },
    [31874] = { name = "Igneous Weapons", duration = 60.0 },
    [31888] = { name = "Molten Armaments", duration = 30.0 },
    [29224] = { name = "Obsidian Shield", duration = 6.7 },
    [32673] = { name = "Igneous Shield", duration = 6.7 },
    [32678] = { name = "Fragmented Shield", duration = 6.7 },
    [29037] = { name = "Petrify", duration = 2.5 },
    [32685] = { name = "Fossilize", duration = 2.5 },
    [32678] = { name = "Shattering Rocks", duration = 2.5 },
    [28858] = { name = "Ash Cloud", duration = 15.0 },
    [39052] = { name = "Cinder Storm", duration = 15.0 },
    [39011] = { name = "Eruption", duration = 15.0 },
    [31708] = { name = "Magma Armor", duration = 10.0 },
    [31721] = { name = "Magma Shell", duration = 10.0 },
    [31722] = { name = "Corrosive Armor", duration = 10.0 },

    ----------------------------------------------------------
    -- Sorcerer Skills
    ----------------------------------------------------------
    -- Dark Magic
    [46331] = { name = "Crystal Weapon", duration = 6.0 },
    [24584] = { name = "Dark Exchange", duration = 20.0 },
    [24595] = { name = "Dark Deal", duration = 10.0 },
    [24589] = { name = "Dark Conversion", duration = 20.0 },
    [24828] = { name = "Daedric Mines", duration = 15.0 },
    [24842] = { name = "Daedric Tomb", duration = 15.0 },
    [24834] = { name = "Daedric Refuge", duration = 15.0 },
    [24371] = { name = "Rune Prison", duration = 3.0 },
    [24578] = { name = "Rune Cage", duration = 3.0 },
    [28025] = { name = "Encase", duration = 4.0 },
    -- Note: Suppression Field etc. are ultimates, durations listed below in ultimate section if needed

    -- Daedric Summoning
    [23304] = { name = "Summon Unstable Familiar", duration = 0.5 },  -- Pet
    [108840] = { name = "Summon Volatile Familiar", duration = 0.5 },
    [24636] = { name = "Summon Twilight Tormentor", duration = 0.5 },
    [24158] = { name = "Bound Armaments", duration = 10.0 },  -- Stacks 10s
    [24163] = { name = "Bound Aegis", duration = 3.0 },
    [24165] = { name = "Bound Armor", duration = 3.0 },
    [24326] = { name = "Daedric Curse", duration = 6.0 },
    [24328] = { name = "Daedric Prey", duration = 6.0 },
    [24330] = { name = "Haunting Curse", duration = 12.0 },
    [23634] = { name = "Summon Storm Atronach", duration = 15.0 },
    [23492] = { name = "Greater Storm Atronach", duration = 15.0 },
    [23495] = { name = "Summon Charged Atronach", duration = 15.0 },
    [24176] = { name = "Conjured Ward", duration = 6.0 },
    [24184] = { name = "Hardened Ward", duration = 6.0 },
    [24187] = { name = "Regenerative Ward", duration = 10.0 },

    -- Storm Calling (Expert Mage: +2s to durations where applicable? But not explicit)
    [18718] = { name = "Mages' Fury", duration = 2.0 },
    [19123] = { name = "Mages' Wrath", duration = 2.0 },
    [19109] = { name = "Endless Fury", duration = 4.0 },
    [23182] = { name = "Lightning Splash", duration = 10.0 },
    [23205] = { name = "Lightning Flood", duration = 10.0 },
    [23200] = { name = "Liquid Lightning", duration = 15.0 },
    [23234] = { name = "Bolt Escape", duration = 0.5 },
    [23236] = { name = "Streak", duration = 0.5 },
    [23277] = { name = "Ball of Lightning", duration = 0.5 },
    [24785] = { name = "Overload", duration = 0.5 },  -- Toggle
    [24806] = { name = "Energy Overload", duration = 0.5 },
    [24804] = { name = "Power Overload", duration = 0.5 },
    [23674] = { name = "Surge", duration = 33.0 },
    [23680] = { name = "Power Surge", duration = 33.0 },
    [23678] = { name = "Critical Surge", duration = 33.0 },
    [23600] = { name = "Lightning Form", duration = 20.0 },
    [23605] = { name = "Hurricane", duration = 20.0 },
    [23213] = { name = "Boundless Storm", duration = 30.0 },

    ----------------------------------------------------------
    -- Nightblade Skills
    ----------------------------------------------------------
    -- Assassination (Master Assassin: +4s to durations? Not explicit for most)
    [33398] = { name = "Death Stroke", duration = 8.0 },
    [36508] = { name = "Incapacitating Strike", duration = 12.0 },
    [36514] = { name = "Soul Harvest", duration = 8.0 },
    [25255] = { name = "Veiled Strike", duration = 0.5 },
    [25260] = { name = "Surprise Attack", duration = 0.5 },
    [25267] = { name = "Concealed Weapon", duration = 15.0 },  -- Buff 15s
    [18342] = { name = "Teleport Strike", duration = 10.0 },
    [25493] = { name = "Lotus Fan", duration = 10.0 },
    [25484] = { name = "Ambush", duration = 10.0 },
    [33386] = { name = "Assassin's Blade", duration = 0.5 },
    [34843] = { name = "Killer's Blade", duration = 0.5 },
    [34851] = { name = "Impale", duration = 0.5 },
    [33357] = { name = "Mark Target", duration = 20.0 },
    [36968] = { name = "Piercing Mark", duration = 60.0 },
    [36967] = { name = "Reaper's Mark", duration = 10.0 },
    [61902] = { name = "Grim Focus", duration = 0.5 },  -- Toggle-like
    [61919] = { name = "Relentless Focus", duration = 0.5 },
    [61927] = { name = "Merciless Resolve", duration = 0.5 },

    -- Shadow
    [25352] = { name = "Aspect of Terror", duration = 2.0 },
    [37470] = { name = "Mass Hysteria", duration = 3.0 },
    [37475] = { name = "Manifestation of Terror", duration = 20.0 },
    [33211] = { name = "Summon Shade", duration = 20.0 },
    [35434] = { name = "Dark Shade", duration = 20.0 },
    [35441] = { name = "Shadow Image", duration = 20.0 },
    [33375] = { name = "Blur", duration = 20.0 },
    [35414] = { name = "Mirage", duration = 20.0 },
    [35419] = { name = "Phantasmal Escape", duration = 20.0 },
    [25375] = { name = "Shadow Cloak", duration = 0.5 },  -- Toggle
    [25380] = { name = "Shadowy Disguise", duration = 0.5 },
    [25377] = { name = "Dark Cloak", duration = 3.0 },
    [37475] = { name = "Path of Darkness", duration = 10.0 },
    [37481] = { name = "Twisting Path", duration = 10.0 },
    [37485] = { name = "Refreshing Path", duration = 10.0 },
    [37481] = { name = "Consuming Darkness", duration = 13.0 },
    [37487] = { name = "Bolstering Darkness", duration = 10.0 },
    [37491] = { name = "Veil of Blades", duration = 13.0 },

    -- Siphoning
    [33308] = { name = "Strife", duration = 10.0 },
    [34838] = { name = "Funnel Health", duration = 10.0 },
    [34835] = { name = "Swallow Soul", duration = 10.0 },
    [33326] = { name = "Cripple", duration = 20.0 },
    [36943] = { name = "Debilitate", duration = 20.0 },
    [36957] = { name = "Crippling Grasp", duration = 20.0 },
    [36908] = { name = "Siphoning Strikes", duration = 0.5 },  -- Toggle
    [36919] = { name = "Leeching Strikes", duration = 0.5 },
    [36901] = { name = "Siphoning Attacks", duration = 0.5 },
    [33316] = { name = "Drain Power", duration = 30.0 },
    [36901] = { name = "Power Extraction", duration = 10.0 },
    [36891] = { name = "Sap Essence", duration = 30.0 },
    [33326] = { name = "Malevolent Offering", duration = 3.0 },
    [34721] = { name = "Shrewd Offering", duration = 2.0 },
    [34727] = { name = "Healthy Offering", duration = 10.0 },
    [25091] = { name = "Soul Shred", duration = 4.0 },
    [35460] = { name = "Soul Siphon", duration = 4.0 },
    [35462] = { name = "Soul Tether", duration = 8.0 },

    ----------------------------------------------------------
    -- Warden Skills
    ----------------------------------------------------------
    -- Animal Companions (Flourish: +4s to durations where applicable? Not explicit)
    [85982] = { name = "Feral Guardian", duration = 0.5 },  -- Pet
    [85986] = { name = "Eternal Guardian", duration = 0.5 },
    [85990] = { name = "Wild Guardian", duration = 0.5 },
    [85995] = { name = "Dive", duration = 0.5 },
    [85999] = { name = "Cutting Dive", duration = 10.0 },
    [86003] = { name = "Screaming Cliff Racer", duration = 10.0 },
    [86009] = { name = "Scorch", duration = 9.0 },
    [86019] = { name = "Subterranean Assault", duration = 6.0 },
    [86015] = { name = "Deep Fissure", duration = 10.0 },
    [86023] = { name = "Swarm", duration = 20.0 },
    [86027] = { name = "Fetcher Infection", duration = 20.0 },
    [86031] = { name = "Growing Swarm", duration = 20.0 },
    [86050] = { name = "Betty Netch", duration = 22.0 },
    [86054] = { name = "Blue Betty", duration = 25.0 },
    [86058] = { name = "Bull Netch", duration = 25.0 },
    [86037] = { name = "Falcon's Swiftness", duration = 6.0 },
    [86041] = { name = "Deceptive Predator", duration = 6.0 },
    [86045] = { name = "Bird of Prey", duration = 6.0 },

    -- Green Balance (Maturation: +4s to heals? Not direct to durations)
    [85840] = { name = "Fungal Growth", duration = 0.5 },  -- Instant
    [85862] = { name = "Enchanted Growth", duration = 20.0 },  -- Minor Endurance/Intellect 20s
    [85858] = { name = "Soothing Spores", duration = 0.5 },
    [85552] = { name = "Healing Seed", duration = 6.0 },
    [85578] = { name = "Budding Seeds", duration = 6.0 },
    [85564] = { name = "Corrupting Pollen", duration = 6.0 },
    [85862] = { name = "Living Vines", duration = 10.0 },
    [85863] = { name = "Leeching Vines", duration = 10.0 },
    [85864] = { name = "Living Trellis", duration = 10.0 },
    [85539] = { name = "Lotus Flower", duration = 20.0 },
    [85840] = { name = "Green Lotus", duration = 20.0 },
    [85845] = { name = "Lotus Blossom", duration = 60.0 },
    [85564] = { name = "Nature's Grasp", duration = 10.0 },
    [85568] = { name = "Bursting Vines", duration = 0.5 },
    [85858] = { name = "Nature's Embrace", duration = 10.0 },
    [85804] = { name = "Secluded Grove", duration = 6.0 },
    [85807] = { name = "Enchanted Forest", duration = 6.0 },
    [85811] = { name = "Healing Thicket", duration = 6.0 },

    -- Winter's Embrace
    [86109] = { name = "Sleet Storm", duration = 8.0 },
    [86113] = { name = "Northern Storm", duration = 8.0 },
    [86122] = { name = "Permafrost", duration = 13.0 },
    [86122] = { name = "Frost Cloak", duration = 20.0 },
    [86126] = { name = "Expansive Frost Cloak", duration = 20.0 },
    [86130] = { name = "Ice Fortress", duration = 30.0 },
    [86131] = { name = "Impaling Shards", duration = 12.0 },
    [86135] = { name = "Gripping Shards", duration = 12.0 },
    [86139] = { name = "Winter's Revenge", duration = 12.0 },
    [86148] = { name = "Arctic Wind", duration = 10.0 },
    [86152] = { name = "Polar Wind", duration = 10.0 },
    [86156] = { name = "Arctic Blast", duration = 20.0 },
    [86135] = { name = "Crystallized Shield", duration = 6.0 },
    [86139] = { name = "Crystallized Slab", duration = 6.0 },
    [86143] = { name = "Shimmering Shield", duration = 6.0 },
    [86175] = { name = "Frozen Gate", duration = 15.0 },
    [86179] = { name = "Frozen Device", duration = 15.0 },
    [86183] = { name = "Frozen Retreat", duration = 15.0 },

    ----------------------------------------------------------
    -- Necromancer Skills
    ----------------------------------------------------------
    -- Grave Lord (Undead Confederate: +4s to minion durations? But not direct)
    [114860] = { name = "Sacrificial Bones", duration = 10.0 },
    [117690] = { name = "Blighted Blastbones", duration = 8.0 },
    [117749] = { name = "Grave Lord's Sacrifice", duration = 20.0 },
    [115252] = { name = "Boneyard", duration = 10.0 },
    [117805] = { name = "Unnerving Boneyard", duration = 10.0 },
    [117801] = { name = "Avid Boneyard", duration = 10.0 },
    [115001] = { name = "Skeletal Mage", duration = 20.0 },
    [117749] = { name = "Skeletal Archer", duration = 20.0 },
    [118680] = { name = "Skeletal Arcanist", duration = 20.0 },
    [115924] = { name = "Shocking Siphon", duration = 20.0 },
    [118763] = { name = "Detonating Siphon", duration = 20.0 },
    [118008] = { name = "Mystic Siphon", duration = 20.0 },
    [122174] = { name = "Frozen Colossus", duration = 3.0 },
    [122391] = { name = "Pestilent Colossus", duration = 3.0 },
    [122388] = { name = "Glacial Colossus", duration = 3.0 },

    -- Bone Tyrant
    [115001] = { name = "Bone Goliath Transformation", duration = 20.0 },
    [115003] = { name = "Pummeling Goliath", duration = 20.0 },
    [115006] = { name = "Ravenous Goliath", duration = 20.0 },
    [115115] = { name = "Death Scythe", duration = 0.5 },
    [115238] = { name = "Ruinous Scythe", duration = 7.0 },
    [115219] = { name = "Hungry Scythe", duration = 10.0 },
    [115307] = { name = "Bone Armor", duration = 20.0 },
    [115315] = { name = "Beckoning Armor", duration = 20.0 },
    [115324] = { name = "Summoner's Armor", duration = 30.0 },
    [115410] = { name = "Bitter Harvest", duration = 2.0 },
    [115521] = { name = "Deaden Pain", duration = 4.0 },
    [115567] = { name = "Necrotic Potency", duration = 2.0 },
    [115557] = { name = "Bone Totem", duration = 11.0 },
    [115591] = { name = "Remote Totem", duration = 11.0 },
    [115602] = { name = "Agony Totem", duration = 13.0 },
    [115177] = { name = "Grave Grasp", duration = 5.0 },
    [115308] = { name = "Ghostly Embrace", duration = 5.0 },
    [115352] = { name = "Empowering Grasp", duration = 10.0 },

    -- Living Death
    [115410] = { name = "Reanimate", duration = 0.5 },
    [118367] = { name = "Renewing Animation", duration = 0.5 },
    [118379] = { name = "Animate Blastbones", duration = 0.5 },
    [114196] = { name = "Render Flesh", duration = 4.0 },
    [117883] = { name = "Resistant Flesh", duration = 3.0 },
    [117888] = { name = "Blood Sacrifice", duration = 4.0 },
    [115307] = { name = "Expunge", duration = 0.5 },
    [117940] = { name = "Expunge and Modify", duration = 0.5 },
    [117919] = { name = "Hexproof", duration = 0.5 },
    [115315] = { name = "Life amid Death", duration = 5.0 },
    [118017] = { name = "Renewing Undeath", duration = 5.0 },
    [118809] = { name = "Enduring Undeath", duration = 5.0 },
    [115926] = { name = "Spirit Mender", duration = 16.0 },
    [117883] = { name = "Spirit Guardian", duration = 16.0 },
    [117888] = { name = "Intensive Mender", duration = 8.0 },
    [115926] = { name = "Restoring Tether", duration = 12.0 },
    [118070] = { name = "Braided Tether", duration = 12.0 },
    [118122] = { name = "Mortal Coil", duration = 12.0 },

    ----------------------------------------------------------
    -- Arcanist Skills
    ----------------------------------------------------------
    -- Herald of the Tome (Tome-Bearer's Inspiration: +4s to durations? Not explicit)
    [189791] = { name = "The Unblinking Eye", duration = 6.0 },
    [189837] = { name = "The Tide King's Gaze", duration = 8.0 },
    [189794] = { name = "The Languid Eye", duration = 6.0 },
    [185794] = { name = "Runeblades", duration = 0.5 },
    [185803] = { name = "Writhing Runeblades", duration = 0.5 },
    [182977] = { name = "Escalating Runeblades", duration = 0.5 },
    [185805] = { name = "Fatecarver", duration = 4.0 },
    [183122] = { name = "Exhausting Fatecarver", duration = 4.0 },
    [186366] = { name = "Pragmatic Fatecarver", duration = 4.0 },
    [185817] = { name = "Abyssal Impact", duration = 20.0 },
    [183006] = { name = "Cephaliarch's Flail", duration = 20.0 },
    [185823] = { name = "Tentacular Dread", duration = 20.0 },
    [183261] = { name = "Tome-Bearer's Inspiration", duration = 30.0 },
    [183401] = { name = "Inspired Scholarship", duration = 30.0 },
    [183430] = { name = "Recuperative Treatise", duration = 30.0 },
    [185836] = { name = "The Imperfect Ring", duration = 20.0 },
    [185839] = { name = "Rune of Displacement", duration = 18.0 },
    [182988] = { name = "Fulminating Rune", duration = 20.0 },

    -- Soldier of Apocrypha
    [183241] = { name = "Runespite Ward", duration = 6.0 },
    [183401] = { name = "Spiteward of the Lucid Mind", duration = 6.0 },
    [185912] = { name = "Impervious Runeward", duration = 6.0 },
    [183648] = { name = "Fatewoven Armor", duration = 20.0 },
    [185908] = { name = "Cruxweaver Armor", duration = 30.0 },
    [186477] = { name = "Unbreakable Fate", duration = 20.0 },
    [185912] = { name = "Runic Defense", duration = 20.0 },
    [183401] = { name = "Runeguard of Still Waters", duration = 20.0 },
    [186489] = { name = "Runeguard of Freedom", duration = 20.0 },
    [185918] = { name = "Rune of Eldritch Horror", duration = 4.0 },
    [185921] = { name = "Rune of Uncanny Adoration", duration = 4.0 },
    [183267] = { name = "Rune of the Colorless Pool", duration = 4.0 },
    [183165] = { name = "Runic Jolt", duration = 15.0 },
    [183430] = { name = "Runic Sunder", duration = 15.0 },
    [186531] = { name = "Runic Embrace", duration = 15.0 },
    [183542] = { name = "Gibbering Shield", duration = 10.0 },
    [183709] = { name = "Sanctum of the Abyssal Sea", duration = 10.0 },
    [183261] = { name = "Gibbering Shelter", duration = 10.0 },

    -- Curative Runeforms
    [183542] = { name = "Vitalizing Glyphic", duration = 15.0 },
    [183709] = { name = "Glyphic of the Tides", duration = 15.0 },
    [183261] = { name = "Resonating Glyphic", duration = 15.0 },
    [183261] = { name = "Runemend", duration = 0.5 },
    [186189] = { name = "Evolving Runemend", duration = 6.0 },
    [186191] = { name = "Audacious Runemend", duration = 6.0 },
    [183537] = { name = "Remedy Cascade", duration = 4.5 },
    [186193] = { name = "Cascading Fortune", duration = 4.5 },
    [186200] = { name = "Curative Surge", duration = 4.5 },
    [183447] = { name = "Chakram Shields", duration = 6.0 },
    [186207] = { name = "Chakram of Destiny", duration = 6.0 },
    [186209] = { name = "Tidal Chakram", duration = 6.0 },
    [183442] = { name = "Arcanist's Domain", duration = 20.0 },
    [183537] = { name = "Zenas' Empowering Disc", duration = 20.0 },
    [183542] = { name = "Reconstructive Domain", duration = 20.0 },
    [183542] = { name = "Apocryphal Gate", duration = 7.0 },
    [186211] = { name = "Fleet-Footed Gate", duration = 7.0 },
    [186220] = { name = "Passage Between Worlds", duration = 7.0 },

    ----------------------------------------------------------
    -- Weapon Skills
    ----------------------------------------------------------
    -- Two Handed (Follow Up: +5s to durations on some? But not explicit; durations as per UESP)
    [83216] = { name = "Berserker Strike", duration = 8.0 },
    [83229] = { name = "Onslaught", duration = 5.0 },
    [83238] = { name = "Berserker Rage", duration = 8.0 },
    [38814] = { name = "Dizzying Swing", duration = 7.0 },  -- Off-balance 7s
    [38807] = { name = "Wrecking Blow", duration = 3.0 },  -- Major Berserk 3s? UESP says 10s for morphs
    [38788] = { name = "Stampede", duration = 15.0 },  -- DoT 15s
    [38745] = { name = "Carve", duration = 6.0 },  -- Bleed 6s up to 32 stacks
    [38794] = { name = "Brawler", duration = 6.0 },
    [83223] = { name = "Reverse Slash", duration = 0.5 },
    [83226] = { name = "Reverse Slice", duration = 0.5 },
    [83238] = { name = "Executioner", duration = 0.5 },
    [28297] = { name = "Momentum", duration = 20.0 },
    [38794] = { name = "Forward Momentum", duration = 40.0 },
    [38802] = { name = "Rally", duration = 20.0 },

    -- One Hand and Shield (Fortress: no direct duration; durations as per UESP)
    [28304] = { name = "Puncture", duration = 15.0 },
    [28306] = { name = "Ransack", duration = 15.0 },
    [38250] = { name = "Pierce Armor", duration = 15.0 },
    [28304] = { name = "Low Slash", duration = 15.0 },
    [38268] = { name = "Deep Slash", duration = 15.0 },
    [38264] = { name = "Heroic Slash", duration = 15.0 },
    [28727] = { name = "Defensive Posture", duration = 6.0 },
    [38312] = { name = "Defensive Stance", duration = 6.0 },
    [38317] = { name = "Absorb Missile", duration = 6.0 },
    [28719] = { name = "Shield Charge", duration = 0.5 },
    [38401] = { name = "Shielded Assault", duration = 6.0 },
    [38405] = { name = "Invasion", duration = 0.5 },
    [38452] = { name = "Power Bash", duration = 0.5 },
    [38455] = { name = "Reverberating Bash", duration = 0.5 },
    [38458] = { name = "Power Slam", duration = 0.5 },

    -- Dual Wield (Twin Blade and Blunt: +4s to DoTs on some morphs)
    [83600] = { name = "Lacerate", duration = 8.0 },
    [85187] = { name = "Rend", duration = 16.0 },
    [85179] = { name = "Thrive in Chaos", duration = 8.0 },
    [28607] = { name = "Flurry", duration = 0.5 },
    [38857] = { name = "Rapid Strikes", duration = 0.5 },
    [38846] = { name = "Bloodthirst", duration = 0.5 },
    [28379] = { name = "Twin Slashes", duration = 20.0 },
    [38839] = { name = "Rending Slashes", duration = 20.0 },
    [38845] = { name = "Blood Craze", duration = 20.0 },
    [28591] = { name = "Whirlwind", duration = 0.5 },
    [38891] = { name = "Whirling Blades", duration = 0.5 },
    [38861] = { name = "Steel Tornado", duration = 0.5 },
    [21156] = { name = "Blade Cloak", duration = 20.0 },
    [21157] = { name = "Quick Cloak", duration = 30.0 },
    [21158] = { name = "Deadly Cloak", duration = 20.0 },
    [21157] = { name = "Hidden Blade", duration = 20.0 },
    [38914] = { name = "Shrouded Daggers", duration = 20.0 },
    [38910] = { name = "Flying Blade", duration = 40.0 },

    -- Bow (Ranger: +5s to durations on some morphs like Endless Hail +5s =15s)
    [83465] = { name = "Rapid Fire", duration = 4.0 },
    [85257] = { name = "Toxic Barrage", duration = 4.0 + 8.0 },
    [85451] = { name = "Ballista", duration = 5.0 },
    [38685] = { name = "Snipe", duration = 0.5 },
    [38687] = { name = "Lethal Arrow", duration = 4.0 },  -- Minor Defile 4s
    [38689] = { name = "Focused Aim", duration = 0.5 },
    [28876] = { name = "Volley", duration = 10.0 },
    [38695] = { name = "Endless Hail", duration = 15.0 },  -- Base 10s +5s Ranger
    [38692] = { name = "Arrow Barrage", duration = 8.0 },
    [28879] = { name = "Scatter Shot", duration = 0.5 },
    [38672] = { name = "Magnum Shot", duration = 0.5 },
    [38669] = { name = "Draining Shot", duration = 3.0 },
    [38701] = { name = "Arrow Spray", duration = 0.5 },
    [38705] = { name = "Bombard", duration = 4.0 },
    [38701] = { name = "Acid Spray", duration = 4.0 + 5.0 },
    [28869] = { name = "Poison Arrow", duration = 20.0 },
    [38645] = { name = "Venom Arrow", duration = 20.0 },
    [38660] = { name = "Poison Injection", duration = 20.0 },

    -- Destruction Staff (Tri Focus: no direct duration; elemental variants noted, durations with Ancient Knowledge if applicable)
    [83619] = { name = "Elemental Storm", duration = 7.0 },
    [84434] = { name = "Elemental Rage", duration = 7.0 },  -- Lightning +2s =9s
    [83642] = { name = "Eye of the Storm", duration = 7.0 },
    [46340] = { name = "Force Shock", duration = 0.5 },
    [46348] = { name = "Crushing Shock", duration = 0.5 },
    [46356] = { name = "Force Pulse", duration = 0.5 },
    [28858] = { name = "Wall of Elements", duration = 10.0 },  -- Variants: Fire/Frost/Lightning specific effects
    [39052] = { name = "Unstable Wall of Elements", duration = 10.0 },
    [39011] = { name = "Elemental Blockade", duration = 15.0 },
    [29091] = { name = "Destructive Touch", duration = 20.0 },
    [38984] = { name = "Destructive Clench", duration = 0.5 },
    [38937] = { name = "Destructive Reach", duration = 20.0 },
    [29173] = { name = "Weakness to Elements", duration = 30.0 },
    [39089] = { name = "Elemental Susceptibility", duration = 30.0 },
    [39095] = { name = "Elemental Drain", duration = 60.0 },
    [28800] = { name = "Impulse", duration = 0.5 },
    [39143] = { name = "Elemental Ring", duration = 0.5 },
    [39161] = { name = "Pulsar", duration = 10.0 },

    -- Restoration Staff (Essence Drain: +4s to HoTs on some morphs)
    [38552] = { name = "Panacea", duration = 5.0 },
    [83850] = { name = "Life Giver", duration = 5.0 },
    [85132] = { name = "Light's Champion", duration = 5.0 },
    [28385] = { name = "Grand Healing", duration = 10.0 },
    [40058] = { name = "Illustrious Healing", duration = 15.0 },
    [40060] = { name = "Healing Springs", duration = 10.0 },
    [28536] = { name = "Regeneration", duration = 10.0 },
    [40076] = { name = "Rapid Regeneration", duration = 5.0 },
    [40079] = { name = "Radiating Regeneration", duration = 10.0 },
    [37243] = { name = "Blessing of Protection", duration = 10.0 },
    [40103] = { name = "Blessing of Restoration", duration = 20.0 },
    [40094] = { name = "Combat Prayer", duration = 10.0 },
    [37232] = { name = "Steadfast Ward", duration = 6.0 },
    [40130] = { name = "Ward Ally", duration = 6.0 },
    [40126] = { name = "Healing Ward", duration = 6.0 },
    [31531] = { name = "Force Siphon", duration = 24.0 },
    [40109] = { name = "Siphon Spirit", duration = 30.0 },
    [40116] = { name = "Quick Siphon", duration = 30.0 },

    ----------------------------------------------------------
    -- Guild Skills
    ----------------------------------------------------------
    -- Fighters Guild
    [35713] = { name = "Dawnbreaker", duration = 6.0 },
    [40161] = { name = "Flawless Dawnbreaker", duration = 6.0 + 20.0 },
    [40158] = { name = "Dawnbreaker of Smiting", duration = 6.0 + 2.0 },
    [40300] = { name = "Silver Bolts", duration = 0.5 },
    [40167] = { name = "Silver Shards", duration = 0.5 },
    [40336] = { name = "Silver Leash", duration = 4.0 },
    [35721] = { name = "Circle of Protection", duration = 20.0 },
    [35737] = { name = "Turn Evil", duration = 20.0 + 4.0 },
    [35738] = { name = "Ring of Preservation", duration = 10.0 },
    [35750] = { name = "Expert Hunter", duration = 5.0 },
    [40181] = { name = "Evil Hunter", duration = 5.0 },
    [40195] = { name = "Camouflaged Hunter", duration = 5.0 },
    [35750] = { name = "Trap Beast", duration = 20.0 },
    [40382] = { name = "Barbed Trap", duration = 20.0 },
    [40372] = { name = "Lightweight Beast Trap", duration = 20.0 },

    -- Mages Guild (Everlasting Magic: +4s to durations)
    [16536] = { name = "Meteor", duration = 11.0 },
    [40489] = { name = "Ice Comet", duration = 11.0 },
    [40493] = { name = "Shooting Star", duration = 11.0 },
    [28567] = { name = "Magelight", duration = 9.0 },
    [40478] = { name = "Inner Light", duration = 9.0 },
    [40483] = { name = "Radiant Magelight", duration = 9.0 },
    [28567] = { name = "Entropy", duration = 24.0 },
    [40457] = { name = "Degeneration", duration = 24.0 },
    [40452] = { name = "Structured Entropy", duration = 24.0 },
    [31632] = { name = "Fire Rune", duration = 24.0 },
    [40470] = { name = "Volcanic Rune", duration = 24.0 },
    [40465] = { name = "Scalding Rune", duration = 24.0 },
    [31642] = { name = "Equilibrium", duration = 4.0 },
    [40441] = { name = "Balance", duration = 34.0 },  -- Base 30s +4s
    [40445] = { name = "Spell Symmetry", duration = 9.0 },

    -- Psijic Order
    [103488] = { name = "Undo", duration = 4.0 },
    [103492] = { name = "Precognition", duration = 4.0 },
    [103503] = { name = "Temporal Guard", duration = 4.0 },
    [103488] = { name = "Time Stop", duration = 3.0 },
    [104059] = { name = "Borrowed Time", duration = 3.0 },
    [103483] = { name = "Time Freeze", duration = 7.0 },
    [103483] = { name = "Imbue Weapon", duration = 2.0 },
    [103571] = { name = "Elemental Weapon", duration = 2.0 },
    [103623] = { name = "Crushing Weapon", duration = 2.0 },
    [103503] = { name = "Accelerate", duration = 20.0 },
    [103706] = { name = "Channeled Acceleration", duration = 60.0 },
    [103710] = { name = "Race Against Time", duration = 20.0 },
    [103543] = { name = "Mend Wounds", duration = 0.5 },
    [103747] = { name = "Mend Spirit", duration = 0.5 },
    [103755] = { name = "Symbiosis", duration = 0.5 },
    [103492] = { name = "Meditate", duration = 0.5 },  -- Channel
    [103652] = { name = "Deep Thoughts", duration = 0.5 },
    [103665] = { name = "Introspection", duration = 0.5 },

    -- Undaunted
    [38528] = { name = "Blood Altar", duration = 30.0 },
    [39367] = { name = "Sanguine Altar", duration = 40.0 },
    [39369] = { name = "Overflowing Altar", duration = 30.0 },
    [38566] = { name = "Trapping Webs", duration = 10.0 },
    [39425] = { name = "Shadow Silk", duration = 10.0 },
    [39429] = { name = "Tangling Webs", duration = 10.0 },
    [39475] = { name = "Inner Fire", duration = 15.0 },
    [42056] = { name = "Inner Rage", duration = 15.0 },
    [42060] = { name = "Inner Beast", duration = 15.0 },
    [38584] = { name = "Bone Shield", duration = 6.0 },
    [39293] = { name = "Spiked Bone Shield", duration = 6.0 },
    [39297] = { name = "Bone Surge", duration = 6.0 },
    [38595] = { name = "Necrotic Orb", duration = 10.0 },
    [39331] = { name = "Mystic Orb", duration = 10.0 },
    [39344] = { name = "Energy Orb", duration = 10.0 },

    ----------------------------------------------------------
    -- Alliance War Skills
    ----------------------------------------------------------
    -- Assault
    [38563] = { name = "War Horn", duration = 30.0 },
    [40223] = { name = "Aggressive Horn", duration = 30.0 },
    [40220] = { name = "Sturdy Horn", duration = 30.0 },
    [61503] = { name = "Vigor", duration = 10.0 },
    [61505] = { name = "Echoing Vigor", duration = 16.0 },
    [61507] = { name = "Resolving Vigor", duration = 5.0 },
    [38566] = { name = "Rapid Maneuver", duration = 8.0 },
    [40211] = { name = "Retreating Maneuver", duration = 8.0 },
    [40215] = { name = "Charging Maneuver", duration = 8.0 },
    [33376] = { name = "Caltrops", duration = 10.0 },
    [40255] = { name = "Anti-Cavalry Caltrops", duration = 15.0 },
    [40242] = { name = "Razor Caltrops", duration = 10.0 },
    [61487] = { name = "Magicka Detonation", duration = 4.0 },
    [61491] = { name = "Inevitable Detonation", duration = 4.0 },
    [61500] = { name = "Proximity Detonation", duration = 8.0 },

    -- Support
    [38570] = { name = "Barrier", duration = 30.0 },
    [40226] = { name = "Reviving Barrier", duration = 30.0 },
    [40224] = { name = "Replenishing Barrier", duration = 30.0 },
    [38573] = { name = "Siege Shield", duration = 20.0 },
    [40229] = { name = "Siege Weapon Shield", duration = 20.0 },
    [40232] = { name = "Propelling Shield", duration = 20.0 },
    [38574] = { name = "Purge", duration = 0.5 },
    [40239] = { name = "Efficient Purge", duration = 0.5 },
    [40237] = { name = "Cleanse", duration = 0.5 },
    [61511] = { name = "Guard", duration = 0.5 },  -- Toggle
    [61536] = { name = "Mystic Guard", duration = 0.5 },
    [61529] = { name = "Stalwart Guard", duration = 0.5 },
    [61489] = { name = "Revealing Flare", duration = 5.0 },
    [61519] = { name = "Lingering Flare", duration = 10.0 },
    [61524] = { name = "Blinding Flare", duration = 5.0 },

    ----------------------------------------------------------
    -- World Skills
    ----------------------------------------------------------
    -- Soul Magic
    [26768] = { name = "Soul Trap", duration = 20.0 },
    [40328] = { name = "Soul Splitting Trap", duration = 10.0 },
    [40317] = { name = "Consuming Trap", duration = 20.0 },
    [25091] = { name = "Soul Strike", duration = 5.0 },
    [35460] = { name = "Soul Assault", duration = 6.0 },
    [35462] = { name = "Shatter Soul", duration = 5.0 },

    -- Vampire
    [132141] = { name = "Blood Frenzy", duration = 0.5 },  -- Toggle
    [134160] = { name = "Simmering Frenzy", duration = 0.5 },
    [135841] = { name = "Sated Fury", duration = 0.5 },
    [38931] = { name = "Vampiric Drain", duration = 3.0 },
    [38932] = { name = "Drain Vigor", duration = 3.0 },
    [38949] = { name = "Exhilarating Drain", duration = 3.0 },
    [128709] = { name = "Mesmerize", duration = 5.0 },
    [137861] = { name = "Hypnosis", duration = 5.0 },
    [138097] = { name = "Stupefy", duration = 5.0 },
    [32986] = { name = "Mist Form", duration = 1.0 },
    [38963] = { name = "Elusive Mist", duration = 1.0 + 4.0 },
    [38965] = { name = "Blood Mist", duration = 1.0 + 20.0 },
    [33152] = { name = "Blood Scion", duration = 20.0 },
    [33182] = { name = "Swarming Scion", duration = 20.0 },
    [33195] = { name = "Perfect Scion", duration = 20.0 },

    -- Werewolf
    [32455] = { name = "Werewolf Transformation", duration = 30.0 },
    [39075] = { name = "Pack Leader", duration = 30.0 },
    [39076] = { name = "Werewolf Berserker", duration = 30.0 },
    [32632] = { name = "Pounce", duration = 10.0 },  -- Bleed 10s
    [39105] = { name = "Brutal Pounce", duration = 10.0 },
    [39104] = { name = "Feral Pounce", duration = 10.0 },
    [58317] = { name = "Hircine's Bounty", duration = 0.5 },
    [58317] = { name = "Hircine's Rage", duration = 10.0 },
    [58325] = { name = "Hircine's Fortitude", duration = 20.0 },
    [32633] = { name = "Roar", duration = 4.0 },
    [39113] = { name = "Ferocious Roar", duration = 4.0 },
    [39114] = { name = "Deafening Roar", duration = 4.0 },
    [58855] = { name = "Piercing Howl", duration = 0.5 },
    [58855] = { name = "Howl of Despair", duration = 20.0 },
    [58855] = { name = "Howl of Agony", duration = 0.5 },
    [58855] = { name = "Infectious Claws", duration = 20.0 },
    [58864] = { name = "Claws of Anguish", duration = 20.0 },
    [58879] = { name = "Claws of Life", duration = 20.0 },


----------------------------------------------------------
    -- Scribed Skills
----------------------------------------------------------    

    [9] = { name = "Warding Contingency", duration = 22.0 },
    [8] = { name = "Warding Burst", duration = 9.0 },
    [2] = { name = "Dazing Soul", duration = 9.0 },



     -- Add other categories if any missed (e.g., Racial skills are passives, ignored)
}

--------------------------------------------------------------
-- API
--------------------------------------------------------------
function LibCombatSkills:IsTracked(id)
    return self.list[id] ~= nil and self.list[id].duration > 0
end

function LibCombatSkills:GetName(id)
    return self.list[id] and self.list[id].name or "Unknown"
end

function LibCombatSkills:GetDuration(id)
    return self.list[id] and self.list[id].duration or 0
end

--------------------------------------------------------------
-- Export
--------------------------------------------------------------
_G["LibCombatSkills"] = LibCombatSkills
