-- ESO Adventurer Suite
-- Curated live skill/build snapshot used by RESPEC + BUILD.
-- The addon cannot call the web in-game, so these priorities are stored locally.
-- Snapshot checked 2026-08-27 against current live ESO.

local EPC = ESOProgressionCoach
EPC.SkillMeta = EPC.SkillMeta or {}
local M = EPC.SkillMeta

M.SNAPSHOT = {
    checked = "2026-08-27",
        sourceNote = "Curated current PvE bars. Exact raid support assignments and encounter swaps can vary by group.",
}

M.CLASSES = {
    [1] = { key="DK", name="Dragonknight" },
    [2] = { key="SORC", name="Sorcerer" },
    [3] = { key="NB", name="Nightblade" },
    [4] = { key="WARDEN", name="Warden" },
    [5] = { key="NECRO", name="Necromancer" },
    [6] = { key="TEMPLAR", name="Templar" },
    [117] = { key="ARC", name="Arcanist" },
}

local function clone(value)
    if type(value) ~= "table" then return value end
    local out = {}
    for k,v in pairs(value) do out[k] = clone(v) end
    return out
end

local function merge(dst, src)
    if type(src) ~= "table" then return dst end
    for k,v in pairs(src) do
        if type(v) == "table" and type(dst[k]) == "table" then merge(dst[k],v)
        else dst[k] = clone(v) end
    end
    return dst
end

local function slot(...)
    return {...}
end

local FG_TRAP = slot("Barbed Trap","Lightweight Beast Trap","Trap Beast")
local FG_HUNTER = slot("Camouflaged Hunter","Expert Hunter")
local DAWNBREAKER = slot("Flawless Dawnbreaker","Dawnbreaker of Smiting","Dawnbreaker")
local WALL = slot("Unstable Wall of Elements","Elemental Blockade","Wall of Elements")
local STAMPEDE = slot("Stampede","Critical Rush","Critical Charge")
local CALTROPS = slot("Anti-Cavalry Caltrops","Razor Caltrops","Caltrops")
local HORN = slot("Aggressive Horn","Sturdy Horn","War Horn")
local BARRIER = slot("Reviving Barrier","Replenishing Barrier","Barrier")
local PUNCTURE = slot("Pierce Armor","Ransack","Puncture","Runic Sunder","Runic Jolt","Frost Clench","Destructive Clench","Inner Rage","Inner Fire")
local RANGE_TAUNT = slot("Inner Rage","Inner Fire","Frost Clench","Destructive Clench")
local ELE_SUS = slot("Elemental Susceptibility","Elemental Drain","Weakness to Elements")
local ORB = slot("Energy Orb","Mystic Orb","Necrotic Orb")
local ALTAR = slot("Overflowing Altar","Sanguine Altar","Blood Altar")
local COMBAT_PRAYER = slot("Combat Prayer","Blessing of Restoration","Blessing of Protection")
local ILLUSTRIOUS = slot("Illustrious Healing","Healing Springs","Grand Healing")
local REGEN = slot("Radiating Regeneration","Rapid Regeneration","Regeneration")
local VIGOR = slot("Echoing Vigor","Resolving Vigor","Vigor")
local HEROIC = slot("Heroic Slash","Deep Slash","Low Slash")
local DEF_STANCE = slot("Defensive Stance","Absorb Missile","Defensive Posture")

local COMMON_DPS_PASSIVES = {
    "Undaunted Mettle","Undaunted Command","Slayer","Banish the Wicked","Skilled Tracker",
    "Medicinal Use","Continuous Attack",
}
local COMMON_TANK_PASSIVES = {
    "Undaunted Mettle","Undaunted Command","Fortress","Sword and Board","Deflect Bolts","Battlefield Mobility",
    "Constitution","Juggernaut","Resolve","Medicinal Use","Continuous Attack",
}
local COMMON_HEAL_PASSIVES = {
    "Undaunted Mettle","Undaunted Command","Essence Drain","Restoration Expert","Cycle of Life","Absorb","Restoration Master",
    "Evocation","Recovery","Spell Warding","Prodigy","Concentration","Medicinal Use","Continuous Attack","Magicka Aid",
}

local function dpsProfile(label, front, back, frontUlt, backUlt, extra)
    local p = {
        label=label, confidence="CURATED", front=front, back=back,
        frontUlt=frontUlt or DAWNBREAKER, backUlt=backUlt or frontUlt or DAWNBREAKER,
        passivePriority=clone(COMMON_DPS_PASSIVES), variants={},
    }
    if extra then merge(p,extra) end
    return p
end

local function tankProfile(label, front, back, frontUlt, backUlt, extra)
    local p = {
        label=label, confidence="SUPPORT BASELINE", front=front, back=back,
        frontUlt=frontUlt or HORN, backUlt=backUlt or HORN,
        passivePriority=clone(COMMON_TANK_PASSIVES), variants={},
    }
    if extra then merge(p,extra) end
    return p
end

local function healerProfile(label, front, back, frontUlt, backUlt, extra)
    local p = {
        label=label, confidence="SUPPORT BASELINE", front=front, back=back,
        frontUlt=frontUlt or BARRIER, backUlt=backUlt or HORN,
        passivePriority=clone(COMMON_HEAL_PASSIVES), variants={},
    }
    if extra then merge(p,extra) end
    return p
end

M.PROFILES = {
    DK = {
        DAMAGE = {
            MAGICKA = dpsProfile("Dragonknight Magicka DPS", {
                slot("Flame Lash","Molten Whip","Lava Whip"),
                CALTROPS,
                slot("Engulfing Flames","Burning Embers","Venomous Claw","Fiery Breath"),
                slot("Quick Cloak","Deadly Cloak","Blade Cloak","Flames of Oblivion"),
                FG_TRAP,
            }, {
                slot("Igneous Weapons","Molten Armaments","Molten Weapons"),
                WALL,
                slot("Flames of Oblivion","Eruption","Burning Embers","Venomous Claw"),
                FG_TRAP,
                slot("Eruption","Engulfing Flames","Cinder Storm","Draw Essence"),
            }, DAWNBREAKER, slot("Shifting Standard","Standard of Might","Dragonknight Standard"), {
                passivePriority={"Combustion","Warmth","Searing Heat","World in Ruin","Iron Skin","Burning Heart","Mountain's Blessing","Battle Roar"},
                variants={
                    AOE_TRASH={front={[2]=CALTROPS,[5]=slot("Whirling Blades","Whirlwind","Flames of Oblivion")},back={[5]=slot("Eruption","Draw Essence","Deep Breath")}},
                    SOLO={front={[5]=slot("Burning Embers","Coagulating Blood","Green Dragon Blood")},back={[4]=slot("Hardened Armor","Volatile Armor","Spiked Armor")}},
                },
            }),
            STAMINA = dpsProfile("Dragonknight Stamina DPS", {
                slot("Molten Whip","Flame Lash","Lava Whip"),
                slot("Venomous Claw","Burning Embers","Searing Strike"),
                slot("Noxious Breath","Engulfing Flames","Fiery Breath"),
                slot("Quick Cloak","Deadly Cloak","Blade Cloak"),
                FG_TRAP,
            }, {
                STAMPEDE,
                slot("Carve","Brawler","Cleave", "Unstable Wall of Elements"),
                slot("Flames of Oblivion","Eruption"),
                CALTROPS,
                slot("Igneous Weapons","Molten Armaments","Molten Weapons"),
            }, DAWNBREAKER, slot("Shifting Standard","Standard of Might","Dragonknight Standard"), {
                passivePriority={"Combustion","Warmth","Searing Heat","World in Ruin","Iron Skin","Burning Heart","Mountain's Blessing","Battle Roar"},
                variants={SOLO={front={[5]=slot("Burning Embers","Resolving Vigor","Coagulating Blood")}}},
            }),
        },
        TANK = tankProfile("Dragonknight Tank", {
            PUNCTURE,
            slot("Choking Talons","Burning Talons","Dark Talons"),
            slot("Igneous Shield","Fragmented Shield","Obsidian Shield"),
            slot("Coagulating Blood","Green Dragon Blood","Dragon Blood"),
            slot("Hardened Armor","Volatile Armor","Spiked Armor", "Heroic Slash"),
        }, {
            WALL,
            RANGE_TAUNT,
            CALTROPS,
            slot("Unrelenting Grip","Chains of Devastation","Fiery Grip"),
            slot("Igneous Weapons","Molten Armaments","Molten Weapons"),
        }, slot("Magma Shell","Corrosive Armor","Magma Armor"), HORN, {
            confidence="CURATED",
            passivePriority={"Iron Skin","Burning Heart","Elder Dragon","Scaled Armor","Battle Roar","Mountain's Blessing","Helping Hands"},
        }),
        HEALER = healerProfile("Dragonknight Healer", {
            ILLUSTRIOUS,
            REGEN,
            COMBAT_PRAYER,
            ORB,
            slot("Cauterize","Obsidian Shard","Green Dragon Blood"),
        }, {
            WALL,
            slot("Igneous Weapons","Molten Armaments","Molten Weapons"),
            slot("Fragmented Shield","Igneous Shield","Obsidian Shield"),
            slot("Cinder Storm","Ash Cloud"),
            ALTAR,
        }, BARRIER, HORN, {passivePriority={"Battle Roar","Mountain's Blessing","Helping Hands","Burning Heart"}}),
    },

    SORC = {
        DAMAGE = {
            MAGICKA = dpsProfile("Sorcerer Magicka DPS", {
                slot("Force Pulse","Crushing Shock","Force Shock","Crystal Fragments"),
                slot("Crystal Fragments","Crystal Weapon","Crystal Shard"),
                slot("Daedric Prey","Haunting Curse","Daedric Curse"),
                slot("Bound Armaments","Bound Aegis","Bound Armor"),
                slot("Twilight Tormentor","Volatile Familiar","Camouflaged Hunter"),
            }, {
                slot("Hurricane","Boundless Storm","Lightning Form"),
                WALL,
                slot("Liquid Lightning","Lightning Flood","Lightning Splash"),
                FG_TRAP,
                slot("Critical Surge","Power Surge","Surge","Twilight Tormentor","Volatile Familiar"),
            }, DAWNBREAKER, slot("Power Overload","Greater Storm Atronach","Summon Charged Atronach","Overload"), {
                passivePriority={"Persistence","Exploitation","Rebate","Power Stone","Daedric Protection","Capacitor","Energized","Amplitude","Expert Mage"},
                variants={
                    AOE_TRASH={front={[1]=slot("Force Pulse","Crushing Shock","Mage's Wrath"),[5]=slot("Volatile Familiar","Bound Armaments")},back={[2]=WALL,[3]=slot("Lightning Flood","Liquid Lightning")}},
                    SOLO={front={[5]=slot("Hardened Ward","Regenerative Ward","Conjured Ward")},back={[5]=slot("Critical Surge","Dark Conversion","Dark Deal")}},
                },
            }),
            STAMINA = dpsProfile("Sorcerer Stamina DPS", {
                slot("Crystal Weapon","Crystal Fragments","Crystal Shard"),
                slot("Bound Armaments","Bound Aegis","Bound Armor"),
                slot("Daedric Prey","Haunting Curse","Daedric Curse"),
                FG_TRAP,
                slot("Camouflaged Hunter","Volatile Familiar","Twilight Tormentor"),
            }, {
                STAMPEDE,
                slot("Hurricane","Boundless Storm","Lightning Form"),
                slot("Carve","Brawler","Cleave", "Unstable Wall of Elements"),
                slot("Critical Surge","Surge"),
                slot("Volatile Familiar","Twilight Tormentor","Bound Armaments"),
            }, DAWNBREAKER, slot("Greater Storm Atronach","Summon Charged Atronach","Power Overload"), {
                passivePriority={"Persistence","Exploitation","Rebate","Power Stone","Daedric Protection","Capacitor","Energized","Amplitude","Expert Mage"},
                variants={SOLO={front={[5]=slot("Hardened Ward","Resolving Vigor","Critical Surge")}}},
            }),
        },
        TANK = tankProfile("Sorcerer Tank", {
            PUNCTURE,
            slot("Bound Aegis","Bound Armor"),
            slot("Dark Deal","Dark Conversion","Dark Exchange"),
            slot("Unstable Clannfear","Hardened Ward","Conjured Ward"),
            HEROIC,
        }, {
            WALL,
            RANGE_TAUNT,
            slot("Silver Leash","Unrelenting Grip"),
            slot("Hurricane","Boundless Storm","Lightning Form"),
            slot("Critical Surge","Dark Deal","Hardened Ward"),
        }, slot("Absorption Field","Suppression Field","Negate Magic"), HORN, {
            passivePriority={"Persistence","Blood Magic","Rebate","Daedric Protection","Power Stone","Capacitor"},
        }),
        HEALER = healerProfile("Sorcerer Healer", {
            REGEN,
            ILLUSTRIOUS,
            COMBAT_PRAYER,
            slot("Daedric Refuge","Hardened Ward","Regenerative Ward"),
            ORB,
        }, {
            slot("Power Surge","Critical Surge","Surge"),
            WALL,
            slot("Regenerative Ward","Hardened Ward","Conjured Ward"),
            ALTAR,
            VIGOR,
        }, BARRIER, slot("Summon Charged Atronach","Greater Storm Atronach","Aggressive Horn"), {
            confidence="CURATED",
            passivePriority={"Blood Magic","Persistence","Rebate","Daedric Protection","Power Stone","Capacitor"},
        }),
    },

    NB = {
        DAMAGE = {
            MAGICKA = dpsProfile("Nightblade Magicka DPS", {
                slot("Swallow Soul","Funnel Health","Strife","Concealed Weapon"),
                slot("Merciless Resolve","Relentless Focus","Grim Focus"),
                slot("Debilitate","Crippling Grasp","Cripple"),
                slot("Impale","Killer's Blade","Assassin's Blade"),
                FG_TRAP,
            }, {
                slot("Dark Shade","Shadow Image","Summon Shade"),
                WALL,
                slot("Twisting Path","Refreshing Path","Path of Darkness"),
                slot("Siphoning Attacks","Leeching Strikes","Siphoning Strikes"),
                slot("Power Extraction","Sap Essence","Drain Power"),
            }, slot("Soul Harvest","Incapacitating Strike","Death Stroke"), slot("Soul Harvest","Incapacitating Strike","Shooting Star"), {
                passivePriority={"Master Assassin","Executioner","Pressure Points","Hemorrhage","Refreshing Shadows","Catalyst","Magicka Flood","Soul Siphoner","Transfer"},
                variants={SOLO={front={[1]=slot("Swallow Soul","Funnel Health"),[5]=slot("Dark Cloak","Resolving Vigor")},back={[3]=slot("Refreshing Path","Twisting Path")}}},
            }),
            STAMINA = dpsProfile("Nightblade Stamina DPS", {
                slot("Shadowy Disguise","Surprise Attack","Concealed Weapon"),
                slot("Debilitate","Crippling Grasp","Cripple"),
                slot("Surprise Attack","Concealed Weapon","Veiled Strike"),
                slot("Killer's Blade","Impale","Assassin's Blade"),
                slot("Relentless Focus","Merciless Resolve","Grim Focus"),
            }, {
                slot("Dark Shade","Shadow Image","Summon Shade"),
                slot("Power Extraction","Sap Essence","Drain Power"),
                slot("Deadly Cloak","Quick Cloak","Blade Cloak", "Stampede"),
                FG_TRAP,
                slot("Leeching Strikes","Siphoning Attacks","Siphoning Strikes"),
            }, slot("Incapacitating Strike","Soul Harvest","Death Stroke"), slot("Incapacitating Strike","Soul Harvest","Death Stroke"), {
                confidence="CURATED",
                passivePriority={"Master Assassin","Executioner","Pressure Points","Hemorrhage","Refreshing Shadows","Catalyst","Magicka Flood","Soul Siphoner","Transfer"},
                variants={
                    AOE_TRASH={front={[1]=slot("Power Extraction","Whirling Blades","Surprise Attack"),[2]=slot("Killer's Blade","Surprise Attack")},back={[3]=slot("Deadly Cloak","Stampede"),[4]=CALTROPS}},
                    SOLO={front={[1]=slot("Surprise Attack","Swallow Soul"),[5]=slot("Dark Cloak","Resolving Vigor")},back={[3]=slot("Refreshing Path","Deadly Cloak")}},
                },
            }),
        },
        TANK = tankProfile("Nightblade Tank", {
            PUNCTURE,
            slot("Dark Cloak","Shadowy Disguise","Shadow Cloak"),
            slot("Mirage","Phantasmal Escape","Blur"),
            slot("Leeching Strikes","Siphoning Attacks","Siphoning Strikes"),
            HEROIC,
        }, {
            WALL,
            ELE_SUS,
            slot("Silver Leash","Inner Rage"),
            slot("Power Extraction","Sap Essence","Drain Power"),
            slot("Refreshing Path","Twisting Path","Path of Darkness"),
        }, slot("Bolstering Darkness","Veil of Blades","Consuming Darkness"), HORN, {
            passivePriority={"Refreshing Shadows","Shadow Barrier","Dark Veil","Catalyst","Soul Siphoner","Transfer"},
        }),
        HEALER = healerProfile("Nightblade Healer", {
            ILLUSTRIOUS,
            REGEN,
            COMBAT_PRAYER,
            ORB,
            slot("Healthy Offering","Shrewd Offering","Malevolent Offering"),
        }, {
            WALL,
            slot("Refreshing Path","Twisting Path","Path of Darkness"),
            slot("Siphoning Attacks","Leeching Strikes","Siphoning Strikes"),
            slot("Power Extraction","Sap Essence","Drain Power"),
            ALTAR,
        }, slot("Soul Siphon","Soul Tether","Soul Shred","Reviving Barrier"), HORN, {
            passivePriority={"Refreshing Shadows","Catalyst","Magicka Flood","Soul Siphoner","Transfer"},
        }),
    },

    WARDEN = {
        DAMAGE = {
            MAGICKA = dpsProfile("Warden Magicka DPS", {
                slot("Screaming Cliff Racer","Cutting Dive","Dive"),
                slot("Deep Fissure","Subterranean Assault","Scorch"),
                slot("Fetcher Infection","Growing Swarm","Swarm"),
                slot("Blue Betty","Bull Netch","Betty Netch"),
                slot("Inner Light","Bird of Prey","Lotus Blossom"),
            }, {
                WALL,
                slot("Winter's Revenge","Gripping Shards","Impaling Shards"),
                slot("Arctic Blast","Polar Wind","Arctic Wind"),
                slot("Lotus Blossom","Green Lotus","Lotus Flower"),
                FG_TRAP,
            }, slot("Eternal Guardian","Wild Guardian","Feral Guardian"), slot("Eternal Guardian","Wild Guardian","Feral Guardian"), {
                confidence="CURATED",
                passivePriority={"Bond With Nature","Savage Beast","Flourish","Advanced Species","Accelerated Growth","Maturation","Glacial Presence","Frozen Armor","Piercing Cold"},
                variants={SOLO={back={[3]=slot("Arctic Blast","Polar Wind"),[5]=slot("Harness Magicka","Ice Fortress")}}},
            }),
            STAMINA = dpsProfile("Warden Stamina DPS", {
                slot("Subterranean Assault","Deep Fissure","Scorch"),
                slot("Cutting Dive","Screaming Cliff Racer","Dive"),
                slot("Growing Swarm","Fetcher Infection","Swarm"),
                slot("Bird of Prey","Deceptive Predator","Falcon's Swiftness"),
                slot("Bull Netch","Blue Betty","Betty Netch"),
            }, {
                STAMPEDE,
                FG_TRAP,
                slot("Winter's Revenge","Gripping Shards","Impaling Shards"),
                slot("Growing Swarm","Fetcher Infection","Swarm"),
                slot("Camouflaged Hunter","Bird of Prey","Bull Netch"),
            }, slot("Wild Guardian","Eternal Guardian","Feral Guardian"), slot("Wild Guardian","Eternal Guardian","Feral Guardian"), {
                passivePriority={"Bond With Nature","Savage Beast","Flourish","Advanced Species","Accelerated Growth","Maturation","Glacial Presence","Frozen Armor","Piercing Cold"},
                variants={SOLO={front={[5]=slot("Resolving Vigor","Bull Netch")},back={[3]=slot("Arctic Blast","Polar Wind")}}},
            }),
        },
        TANK = tankProfile("Warden Tank", {
            PUNCTURE,
            RANGE_TAUNT,
            slot("Expansive Frost Cloak","Ice Fortress","Frost Cloak"),
            slot("Polar Wind","Arctic Blast","Arctic Wind"),
            slot("Deep Fissure","Subterranean Assault","Scorch"),
        }, {
            WALL,
            slot("Gripping Shards","Winter's Revenge","Impaling Shards"),
            ELE_SUS,
            slot("Blue Betty","Bull Netch","Betty Netch"),
            slot("Budding Seeds","Corrupting Pollen","Healing Seed"),
        }, slot("Permafrost","Northern Storm","Sleet Storm"), HORN, {
            confidence="CURATED",
            passivePriority={"Accelerated Growth","Nature's Gift","Emerald Moss","Maturation","Glacial Presence","Frozen Armor","Icy Aura","Piercing Cold"},
        }),
        HEALER = healerProfile("Warden Healer", {
            slot("Budding Seeds","Corrupting Pollen","Healing Seed"),
            COMBAT_PRAYER,
            ILLUSTRIOUS,
            VIGOR,
            REGEN,
        }, {
            WALL,
            ORB,
            slot("Winter's Revenge","Gripping Shards","Impaling Shards"),
            slot("Expansive Frost Cloak","Ice Fortress","Frost Cloak"),
            ALTAR,
        }, BARRIER, HORN, {
            confidence="CURATED",
            passivePriority={"Accelerated Growth","Nature's Gift","Emerald Moss","Maturation","Glacial Presence","Frozen Armor"},
        }),
    },

    NECRO = {
        DAMAGE = {
            MAGICKA = dpsProfile("Necromancer Magicka DPS", {
                slot("Ricochet Skull","Venom Skull","Flame Skull"),
                slot("Detonating Siphon","Mystic Siphon","Shocking Siphon"),
                slot("Blighted Blastbones","Stalking Blastbones","Blastbones"),
                slot("Unnerving Boneyard","Avid Boneyard","Boneyard"),
                FG_TRAP,
            }, {
                slot("Skeletal Arcanist","Skeletal Archer","Skeletal Mage"),
                WALL,
                slot("Mystic Siphon","Detonating Siphon","Shocking Siphon"),
                slot("Spirit Guardian","Intensive Mender","Spirit Mender"),
                slot("Summoner's Armor","Beckoning Armor","Bone Armor"),
            }, DAWNBREAKER, slot("Glacial Colossus","Pestilent Colossus","Frozen Colossus","Shooting Star"), {
                passivePriority={"Reusable Parts","Death Knell","Dismember","Rapid Rot","Death Gleaning","Disdain Harm","Undead Confederate","Corpse Consumption","Curative Curse"},
                variants={AOE_TRASH={back={[2]=WALL,[4]=CALTROPS,[5]=slot("Unnerving Boneyard","Detonating Siphon")},backUlt=slot("Glacial Colossus","Pestilent Colossus")},SOLO={front={[5]=slot("Hungry Scythe","Spirit Guardian")}}},
            }),
            STAMINA = dpsProfile("Necromancer Stamina DPS", {
                slot("Venom Skull","Ricochet Skull","Flame Skull"),
                slot("Detonating Siphon","Mystic Siphon","Shocking Siphon"),
                slot("Blighted Blastbones","Stalking Blastbones","Blastbones"),
                slot("Unnerving Boneyard","Avid Boneyard","Boneyard"),
                FG_TRAP,
            }, {
                slot("Skeletal Archer","Skeletal Arcanist","Skeletal Mage"),
                STAMPEDE,
                slot("Carve","Brawler","Cleave"),
                FG_TRAP,
                slot("Summoner's Armor","Beckoning Armor","Bone Armor"),
            }, DAWNBREAKER, slot("Glacial Colossus","Pestilent Colossus","Frozen Colossus","Shooting Star"), {
                confidence="CURATED",
                passivePriority={"Reusable Parts","Death Knell","Dismember","Rapid Rot","Death Gleaning","Disdain Harm","Undead Confederate","Corpse Consumption"},
                variants={AOE_TRASH={back={[2]=WALL,[3]=CALTROPS,[4]=FG_TRAP},backUlt=slot("Glacial Colossus","Pestilent Colossus")},SOLO={front={[5]=slot("Hungry Scythe","Resolving Vigor")}}},
            }),
        },
        TANK = tankProfile("Necromancer Tank", {
            PUNCTURE,
            slot("Beckoning Armor","Summoner's Armor","Bone Armor"),
            HEROIC,
            slot("Hungry Scythe","Ruinous Scythe","Death Scythe"),
            slot("Spirit Guardian","Intensive Mender","Spirit Mender"),
        }, {
            WALL,
            RANGE_TAUNT,
            slot("Unnerving Boneyard","Avid Boneyard","Boneyard"),
            slot("Necrotic Potency","Deaden Pain","Bitter Harvest"),
            slot("Agony Totem","Remote Totem","Bone Totem"),
        }, slot("Animate Blastbones","Renewing Animation","Reanimate"), HORN, {
            passivePriority={"Death Gleaning","Disdain Harm","Health Avarice","Last Gasp","Undead Confederate","Corpse Consumption"},
        }),
        HEALER = healerProfile("Necromancer Healer", {
            ILLUSTRIOUS,
            COMBAT_PRAYER,
            slot("Mortal Coil","Braided Tether","Restoring Tether"),
            REGEN,
            slot("Resistant Flesh","Blood Sacrifice","Render Flesh"),
        }, {
            ELE_SUS,
            slot("Empowering Grasp","Ghostly Embrace","Grave Grasp"),
            slot("Unnerving Boneyard","Avid Boneyard","Boneyard"),
            ORB,
            slot("Intensive Mender","Spirit Guardian","Spirit Mender"),
        }, slot("Renewing Animation","Animate Blastbones","Reanimate"), HORN, {
            confidence="CURATED",
            passivePriority={"Curative Curse","Near-Death Experience","Corpse Consumption","Undead Confederate"},
        }),
    },

    TEMPLAR = {
        DAMAGE = {
            MAGICKA = dpsProfile("Templar Magicka DPS", {
                slot("Puncturing Sweeps","Biting Jabs","Puncturing Strikes"),
                slot("Purifying Light","Power of the Light","Backlash"),
                slot("Radiant Oppression","Radiant Glory","Radiant Destruction"),
                slot("Vampire's Bane","Reflective Light","Sun Fire"),
                FG_TRAP,
            }, {
                WALL,
                slot("Solar Barrage","Dark Flare","Solar Flare"),
                slot("Blazing Spear","Luminous Shards","Spear Shards"),
                slot("Ritual of Retribution","Extended Ritual","Cleansing Ritual"),
                FG_HUNTER,
            }, DAWNBREAKER, slot("Elemental Rage","Solar Disturbance","Solar Prison","Nova"), {
                passivePriority={"Piercing Spear","Spear Wall","Burning Light","Balanced Warrior","Enduring Rays","Prism","Illuminate","Restoring Spirit"},
                variants={AOE_TRASH={front={[1]=slot("Puncturing Sweeps","Biting Jabs"),[5]=CALTROPS},back={[2]=slot("Solar Barrage","Blazing Spear"),[5]=slot("Ritual of Retribution","Blazing Spear")}},SOLO={front={[1]=slot("Puncturing Sweeps","Radiant Glory"),[5]=slot("Honor the Dead","Resolving Vigor")}}},
            }),
            STAMINA = dpsProfile("Templar Stamina DPS", {
                slot("Biting Jabs","Puncturing Sweeps","Puncturing Strikes"),
                slot("Power of the Light","Purifying Light","Backlash"),
                slot("Radiant Glory","Radiant Oppression","Radiant Destruction"),
                slot("Quick Cloak","Deadly Cloak","Blade Cloak"),
                CALTROPS,
            }, {
                slot("Vampire's Bane","Reflective Light","Sun Fire"),
                WALL,
                slot("Solar Barrage","Dark Flare","Solar Flare"),
                slot("Blazing Spear","Luminous Shards","Spear Shards"),
                slot("Ritual of Retribution","Extended Ritual","Cleansing Ritual"),
            }, DAWNBREAKER, slot("Elemental Rage","Onslaught","Solar Disturbance"), {
                confidence="CURATED",
                passivePriority={"Piercing Spear","Spear Wall","Burning Light","Balanced Warrior","Enduring Rays","Prism","Illuminate","Restoring Spirit"},
                variants={SOLO={front={[5]=slot("Resolving Vigor","Repentance","Honor the Dead")}}},
            }),
        },
        TANK = tankProfile("Templar Tank", {
            PUNCTURE,
            slot("Restoring Focus","Channeled Focus","Rune Focus"),
            slot("Radiant Ward","Blazing Shield","Sun Shield"),
            slot("Repentance","Radiant Aura","Restoring Aura"),
            slot("Living Dark","Honor the Dead","Breath of Life"),
        }, {
            WALL,
            RANGE_TAUNT,
            slot("Silver Leash","Inner Rage"),
            slot("Extended Ritual","Ritual of Retribution","Cleansing Ritual"),
            ELE_SUS,
        }, slot("Remembrance","Practiced Incantation","Rite of Passage"), HORN, {
            passivePriority={"Sacred Ground","Light Weaver","Master Ritualist","Restoring Spirit","Balanced Warrior"},
        }),
        HEALER = healerProfile("Templar Healer", {
            ILLUSTRIOUS,
            REGEN,
            COMBAT_PRAYER,
            ORB,
            slot("Luminous Shards","Blazing Spear","Spear Shards"),
        }, {
            WALL,
            slot("Extended Ritual","Ritual of Retribution","Cleansing Ritual"),
            slot("Radiant Aura","Repentance","Restoring Aura"),
            VIGOR,
            slot("Honor the Dead","Breath of Life","Rushed Ceremony"),
        }, BARRIER, HORN, {
            confidence="CURATED",
            passivePriority={"Sacred Ground","Light Weaver","Master Ritualist","Mending","Restoring Spirit","Illuminate"},
        }),
    },

    ARC = {
        DAMAGE = {
            MAGICKA = dpsProfile("Arcanist Magicka DPS", {
                slot("Cephaliarch's Flail","Tentacular Dread","Abyssal Impact"),
                slot("Pragmatic Fatecarver","Exhausting Fatecarver","Fatecarver"),
                slot("Escalating Runeblades","Runeblades"),
                slot("Camouflaged Hunter","Inspired Scholarship","Tome-Bearer's Inspiration"),
                FG_TRAP,
            }, {
                slot("Inspired Scholarship","Tome-Bearer's Inspiration"),
                WALL,
                slot("Fulminating Rune","The Imperfect Ring"),
                slot("Scalding Rune","Degeneration","Barbed Trap"),
                slot("Cruxweaver Armor","Fatewoven Armor"),
            }, DAWNBREAKER, slot("The Languid Eye","Glyphic of the Tides","Elemental Rage"), {
                passivePriority={"Fated Fortune","Harnessed Quintessence","Psychic Lesion","Splintered Secrets","Aegis of the Unseen","Wellspring of the Abyss","Circumvented Fate","Implacable Outcome"},
                variants={AOE_TRASH={back={[2]=WALL,[3]=CALTROPS,[4]=slot("Fulminating Rune","The Imperfect Ring")},backUlt=slot("Elemental Rage","The Languid Eye")},SOLO={front={[5]=slot("Chakram of Destiny","Evolving Runemend","Resolving Vigor")},back={[5]=slot("Cruxweaver Armor","Runeguard of Still Waters")}}},
            }),
            STAMINA = dpsProfile("Arcanist Stamina DPS", {
                slot("Cephaliarch's Flail","Tentacular Dread","Abyssal Impact"),
                slot("Pragmatic Fatecarver","Exhausting Fatecarver","Fatecarver"),
                slot("Quick Cloak","Deadly Cloak","Blade Cloak"),
                FG_HUNTER,
                FG_TRAP,
            }, {
                slot("Inspired Scholarship","Tome-Bearer's Inspiration"),
                STAMPEDE,
                slot("Fulminating Rune","The Imperfect Ring"),
                slot("Scalding Rune","Barbed Trap"),
                slot("Cruxweaver Armor","Fatewoven Armor"),
            }, DAWNBREAKER, slot("The Languid Eye","Glyphic of the Tides","Elemental Rage"), {
                confidence="CURATED",
                passivePriority={"Fated Fortune","Harnessed Quintessence","Psychic Lesion","Splintered Secrets","Aegis of the Unseen","Wellspring of the Abyss","Circumvented Fate","Implacable Outcome"},
                variants={AOE_TRASH={back={[2]=WALL,[3]=CALTROPS,[4]=slot("Fulminating Rune","The Imperfect Ring")},backUlt=slot("Elemental Rage","The Languid Eye")},SOLO={front={[5]=slot("Chakram of Destiny","Evolving Runemend","Resolving Vigor")}}},
            }),
        },
        TANK = tankProfile("Arcanist Tank", {
            slot("Runic Sunder","Runic Jolt","Pierce Armor"),
            slot("Cruxweaver Armor","Fatewoven Armor"),
            slot("Runeguard of Still Waters","Runeguard of Freedom"),
            HEROIC,
            DEF_STANCE,
        }, {
            slot("Chakram Shields","Chakram of Destiny"),
            slot("Audacious Runemend","Evolving Runemend","Runemend"),
            VIGOR,
            slot("Zenas' Empowering Disc","Reconstructive Domain","Arcanist's Domain"),
            ELE_SUS,
        }, slot("Sanctum of the Abyssal Sea","Gibbering Shelter"), slot("Glyphic of the Tides","Aggressive Horn"), {
            confidence="CURATED",
            passivePriority={"Aegis of the Unseen","Wellspring of the Abyss","Circumvented Fate","Implacable Outcome","Healing Tides","Hideous Clarity","Erudition","Intricate Runeforms"},
        }),
        HEALER = healerProfile("Arcanist Healer", {
            ILLUSTRIOUS,
            VIGOR,
            COMBAT_PRAYER,
            REGEN,
            slot("Chakram of Destiny","Chakram Shields"),
        }, {
            slot("Cruxweaver Armor","Fatewoven Armor"),
            slot("Rune of the Colorless Pool","Runic Defense"),
            ALTAR,
            ORB,
            WALL,
        }, slot("Gibbering Shelter","Reviving Barrier"), BARRIER, {
            confidence="CURATED",
            passivePriority={"Healing Tides","Hideous Clarity","Erudition","Intricate Runeforms","Aegis of the Unseen","Wellspring of the Abyss"},
        }),
    },
}

local function appendUnique(dst, src)
    local seen = {}
    for _,v in ipairs(dst or {}) do seen[tostring(v)] = true end
    for _,v in ipairs(src or {}) do
        if not seen[tostring(v)] then dst[#dst+1]=v; seen[tostring(v)]=true end
    end
end

function M:GetProfile(classId, role, magicka, presetKey)
    local class = self.CLASSES[tonumber(classId) or 0]
    if not class then return nil end
    role = string.upper(tostring(role or "DAMAGE"))
    local classRows = self.PROFILES[class.key]
    if not classRows then return nil end
    local base
    if role == "DAMAGE" then
        local resource = magicka == false and "STAMINA" or "MAGICKA"
        base = classRows.DAMAGE and classRows.DAMAGE[resource]
    else
        base = classRows[role]
    end
    if not base then return nil end
    local result = clone(base)
    local variant = result.variants and result.variants[tostring(presetKey or "TRIAL")]
    if variant then merge(result,variant) end
    result.classKey = class.key
    result.className = class.name
    result.role = role
    result.resource = role == "DAMAGE" and (magicka == false and "STAMINA" or "MAGICKA") or "SUPPORT"
    result.preset = tostring(presetKey or "TRIAL")
    result.snapshot = self.SNAPSHOT
    result.key = class.key..":"..role..":"..result.resource..":"..result.preset

    -- Preserve the common role priorities even when a class profile supplied
    -- additional high-value passives.
    local common = role=="TANK" and COMMON_TANK_PASSIVES or role=="HEALER" and COMMON_HEAL_PASSIVES or COMMON_DPS_PASSIVES
    result.passivePriority = result.passivePriority or {}
    appendUnique(result.passivePriority, common)
    return result
end

function M:NormalizeAbilityName(name)
    local s = string.lower(tostring(name or ""))
    s = string.gsub(s,"[’']","")
    s = string.gsub(s,"[^%w]+","")
    return s
end

function M:NameMatches(a,b)
    local na,nb=self:NormalizeAbilityName(a),self:NormalizeAbilityName(b)
    return na~="" and na==nb
end

function M:GetPassiveBonus(name, profile)
    if not profile then return 0 end
    for i,wanted in ipairs(profile.passivePriority or {}) do
        if self:NameMatches(name,wanted) then
            return 5000 - math.min(1000,(i-1)*20)
        end
    end
    return 0
end

function M:GetSummary(profile)
    if not profile then return "No curated skill profile available." end
    return string.format("%s | %s | %s",tostring(profile.label),tostring(profile.preset),tostring(profile.confidence))
end
