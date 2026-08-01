-- DungeonGear build knowledge base.
--
-- Hand-authored build descriptions shown in the Details window when you
-- click the "Details" button on a build row. Keyed by the build's `name`
-- field in DungeonGear_Builds (see DungeonGearData.lua).
--
-- ESO addons cannot make HTTP requests at runtime, and the major build
-- sites (Alcast, Hack The Minotaur, The Tank Club) render their content
-- via JavaScript so they can't be reliably scraped either. This file is
-- the practical alternative: static build guides you can ship inside the
-- addon. Edit freely - each value is just a Lua multi-line string.

DungeonGear_BuildText = {

["Stamina DragonKnight DPS"] = [[
STAMINA DRAGONKNIGHT DPS

Role: DPS  |  Class: DragonKnight  |  Damage type: Stamina

WHAT THIS BUILD DOES
Classic stam DK trial/dungeon parse build focused on bleed DoTs and
Molten Whip burst. Heavy reliance on Deadly Strike to amplify your
channelled Venomous Claw and Molten Whip, and Coral Riptide to scale
your weapon damage hard as your stamina dips.

GEAR
  5pc body      Coral Riptide          (Dreadsail Reef, stam)
  5pc jewelry   Deadly Strike          (Imperial City Tel Var, hybrid)
  2pc monster   Slimecraw              (Wayrest Sewers I)

BARS
  Front bar: Dual Wield (Daggers)
    Traits: Nirnhoned + Charged / Infused
    Enchants: Weapon Damage + Poison
  Back bar: 2H Greatsword
    Trait: Infused
    Enchant: Weapon Damage or Berserk

TRAITS / ENCHANTS
  Armor: Divines x6, Infused on 1 big piece (chest) with Weapon Damage glyph
  Jewelry: Bloodthirsty x2 + Infused x1, Weapon Damage glyphs

ROTATION OUTLINE
  Prebuff: Igneous Weapons, Molten Armaments, Major Brutality
  Front bar: Poison Injection -> Rending Slashes -> Venomous Claw ->
             Noxious Breath -> Molten Whip (spam between DoTs)
  Back bar: Stampede -> Carve (DoT) -> Trap Beast
  Keep bleed DoTs + ground DoTs up at all times; Molten Whip is the
  hardest-hitting spammable once stacked up.

STRENGTHS
  - Strong sustained AoE from DoT stacking
  - Forgiving: bleeds tick through blocks and cc
  - Great trial pick with Major Courage from group

SWAPS / ALTERNATIVES
  - If Deadly Strike is hard to farm: use Advancing Yokeda (Black Drake Villa)
  - For cleave-heavy content, sub Whorl of the Depths (Shipwright's Regret)
  - For faster burst, swap to Perfected Relequen from vCloudrest

FULL GUIDE
  Search "stamina dragonknight build" on alcasthq.com for Alcast's
  full writeup with skills trees, CP allocation, food and mundus.
]],

["Magicka Arcanist DPS"] = [[
MAGICKA ARCANIST DPS

Role: DPS  |  Class: Arcanist  |  Damage type: Magicka

WHAT THIS BUILD DOES
Top-tier trial parse for mag Arcanist, stacking Fatecarver burst with
Minor Vulnerability uptime. Slivers of the Null Arca dumps huge damage
during burst windows; Ansuul's keeps enemies brittle.

GEAR
  5pc body      Slivers of the Null Arca  (Lucent Citadel, mag)
  5pc jewelry   Ansuul's Torment          (Sanity's Edge, mag)
  2pc monster   Slimecraw                  (Wayrest Sewers I)

BARS
  Front bar: Inferno Staff (Infused, Flame enchant)
  Back bar:  Lightning Staff (Infused, Weapon/Spell Damage or Berserk)

TRAITS / ENCHANTS
  Armor: Divines x6, Infused on chest w/ Magicka glyph
  Jewelry: Infused/Bloodthirsty, Spell Damage glyphs

ROTATION OUTLINE
  Prebuff: Crux-generators (Tentacular Dread, Runemend)
  Frontbar combo: Runic Jolt -> Cephaliarch's Flail -> Fatecarver (burst)
  Backbar DoTs: Unstable Wall of Elements, Tentacular Dread
  Fatecarver cast window is your big damage - sync with group buffs.

STRENGTHS
  - Very high parse ceiling (top in raid teams in Update 49)
  - Crux system is forgiving to muscle memory
  - Strong burst windows synergise with Major Slayer/Courage

SWAPS / ALTERNATIVES
  - vs trash: sub Medusa for Minor Force
  - Solo / dungeon: Deadly Strike jewelry works well (channel focus)
  - Budget body: Mother's Sorrow (Deshaan overland) as a stepping stone

FULL GUIDE
  Search "magicka arcanist build" on alcasthq.com for the full guide
  with parse videos, CP stars, skill morph explanations.
]],

["Stamina Warden DPS"] = [[
STAMINA WARDEN DPS

Role: DPS  |  Class: Warden  |  Damage type: Stamina

WHAT THIS BUILD DOES
Shalks + bleed build leveraging Warden's fast-hitting Subterranean
Assault and Deep Fissure. Whorl of the Depths adds Minor Brittle to
every enemy you hit for group-wide crit damage.

GEAR
  5pc body      Coral Riptide       (Dreadsail Reef, stam)
  5pc jewelry   Whorl of the Depths (Shipwright's Regret, stam)
  2pc monster   Slimecraw            (Wayrest Sewers I)

BARS
  Front bar: Dual Wield (Daggers)  Nirn + Charged, Poison + Weapon Damage
  Back bar:  Bow                    Infused, Berserk or Weapon Damage

TRAITS
  Armor: Divines + 1 Infused (chest)
  Jewelry: 2 Bloodthirsty + 1 Infused, Weapon Damage glyphs

ROTATION OUTLINE
  Prebuff: Major Brutality, Minor Berserk
  Backbar: Subterranean Assault -> Deep Fissure -> Poison Injection ->
           Endless Hail -> bar swap
  Frontbar: Rending Slashes -> Blade Cloak -> Razor Caltrops -> spam Bite
  Shalks cooldown (Subterranean) is the timer to chase; every other cast.

STRENGTHS
  - Excellent cleave and AoE
  - Strong solo / dungeon performance (built-in healing from Wild Guardian)
  - Minor Brittle debuff buffs your whole group

SWAPS / ALTERNATIVES
  - Trial version: swap Whorl for Ansuul's if you're the brittle applier elsewhere
  - Budget: Briarheart (Wrothgar overland) is a cheap stam body alternative

FULL GUIDE
  Search "stamina warden build" on alcasthq.com or hacktheminotaur.com.
]],

["Magicka Sorcerer DPS"] = [[
MAGICKA SORCERER DPS

Role: DPS  |  Class: Sorcerer  |  Damage type: Magicka

WHAT THIS BUILD DOES
Pet sorcerer burst build. Slivers on body for the burst window, Medusa
on jewelry/weapons for Minor Force to amplify your crit damage. High
DPS with comparatively forgiving rotation thanks to pets holding aggro.

GEAR
  5pc body      Slivers of the Null Arca  (Lucent Citadel, mag)
  5pc jewelry   Medusa                     (Arx Corinium, mag)
  2pc monster   Slimecraw                   (Wayrest Sewers I)

BARS
  Front bar: Inferno Staff (Infused, Flame enchant)
  Back bar:  Inferno Staff (Infused, Berserk or Weapon/Spell Damage)

ROTATION OUTLINE
  Prebuff: Volatile Familiar, Twilight Tormentor (pets)
  Front: Crystal Fragments (proc) -> Force Pulse spam ->
         Mage's Wrath (execute sub-25%)
  Back: Liquid Lightning -> Unstable Wall -> Haunting Curse
  Fragments proc is free big damage; cast it on proc, always.

STRENGTHS
  - High sustained DPS with pets doing chip damage
  - Pet aggro soaks solo mobs nicely
  - Fragments proc gives burst windows

SWAPS / ALTERNATIVES
  - No pet option: sub Twilight with Boundless Storm, DPS drops ~5%
  - Trial: Ansuul's Torment can replace Medusa if group already has Minor Force
  - Beginner: Mother's Sorrow body + Law of Julianos jewelry (both cheap)

FULL GUIDE
  Search "magicka sorcerer build" on alcasthq.com.
]],

["Stamina Nightblade DPS"] = [[
STAMINA NIGHTBLADE DPS

Role: DPS  |  Class: Nightblade  |  Damage type: Stamina

WHAT THIS BUILD DOES
Light-attack-weaving parse build. NB's Merciless Resolve + Surprise
Attack combo benefits massively from Relequen's stacking light-attack
damage. Coral Riptide scales with your stam dropping below half.

GEAR
  5pc body      Coral Riptide   (Dreadsail Reef, stam)
  5pc jewelry   Relequen        (Cloudrest, stam)
  2pc monster   Slimecraw        (Wayrest Sewers I)

BARS
  Front: Dual Wield (Daggers) - Nirn+Charged, Poison+Weapon Damage
  Back:  Bow - Infused, Berserk

ROTATION OUTLINE
  Prebuff: Major Brutality (Momentum or potions), Leeching Strikes
  Frontbar combo: Surprise Attack -> Rending Slashes -> Killer's Blade ->
                  Relentless Focus (Merciless proc) -> cast when ready
  Backbar DoTs: Poison Injection, Caltrops, Endless Hail, Trap Beast
  Weave a LA between every ability - Relequen demands it.

STRENGTHS
  - Top-5 parse ceiling in the game
  - Huge execute phase with Killer's Blade under 25%
  - Strong burst window from Merciless + Incap

SWAPS / ALTERNATIVES
  - Non-trial: Pillar of Nirn (Falkreath Hold) on jewelry instead of Relequen
  - Budget: Hunding's Rage (crafted) as a starter stam body set

FULL GUIDE
  Search "stamina nightblade build" on alcasthq.com.
]],

["Stamina Templar DPS (Jabs)"] = [[
STAMINA TEMPLAR DPS (JABS)

Role: DPS  |  Class: Templar  |  Damage type: Stamina

WHAT THIS BUILD DOES
Biting Jabs spam build. Deadly Strike's +16% damage to channels makes
Jabs hit hard; Coral Riptide scales your weapon damage as stam dips.

GEAR
  5pc body      Coral Riptide  (Dreadsail Reef, stam)
  5pc jewelry   Deadly Strike  (Imperial City Tel Var, hybrid)
  2pc monster   Slimecraw       (Wayrest Sewers I)

BARS
  Front: 2H Greatsword - Nirn, Weapon Damage
  Back:  Bow - Infused, Berserk / Weapon Damage

ROTATION OUTLINE
  Prebuff: Power of the Light, Repentance (for sustain)
  Frontbar: Biting Jabs (spammable) -> Power of the Light -> Solar Barrage
  Backbar: Poison Injection -> Caltrops -> Endless Hail -> trap -> Barrage
  Jabs is your main damage - every other GCD should be Jabs between DoTs.

STRENGTHS
  - Cheapest rotation to learn in the game
  - Repentance makes sustain trivial when mobs die
  - Strong execute via Power of the Light explosion

SWAPS / ALTERNATIVES
  - Magplar version: swap to Julianos + Mother's Sorrow, keep Jabs
  - Trial: Ansuul's instead of Deadly Strike if your group already applies brittle

FULL GUIDE
  Search "stamina templar build jabs" on alcasthq.com.
]],

["Any DragonKnight Tank"] = [[
DRAGONKNIGHT TANK (ULT-GEN)

Role: Tank  |  Class: DragonKnight

WHAT THIS BUILD DOES
Standard DK tank with strong ultimate generation. Turning Tide on
body applies Major Vulnerability (huge group DPS debuff); Drake's
Rush feeds your group Ultimate; Bloodspawn is the monster BiS for
any tank thanks to its resist + ult-gen passive.

GEAR
  5pc body      Turning Tide    (Shipwright's Regret)
  5pc jewelry   Drake's Rush    (Scrivener's Hall, pairs best with DK)
  2pc monster   Bloodspawn      (Spindleclutch II)

BARS
  Front: One Hand + Shield  (Sword/Mace, Reinforced shield)
    Enchants: Crusher (weapon), Health (shield)
  Back: Ice Staff
    Enchant: Weakening or Crusher
    Trait: Infused (double Crusher uptime)

CHAMPION POINTS (summary)
  Warfare: Ironclad, Boundless Vitality, Duelist's Rebuff, Rejuvenation
  Fitness: Siphoning Spells, Bastion, Fortified

ROTATION OUTLINE
  Prebuff: Igneous Shield, Molten Armaments, Green Dragon Blood
  Front: taunt with Pierce Armor, block-cancel Heavy Attacks
  Back: Unrelenting Grip, Engulfing Flames, Wall of Elements
  Aggressive Horn ult when your group needs the damage boost.

STRENGTHS
  - Best ultimate generation of any tank class
  - Major Vulnerability from Turning Tide is group-DPS gold
  - Bloodspawn procs frequently with DK's ult gain

SWAPS / ALTERNATIVES
  - Trial version: Drake's Rush -> Lucent Echoes for trial-scale uptime
  - Budget: Plague Doctor body (overland) + Torug's Pact jewelry (crafted)

FULL GUIDE
  Search "dragonknight tank build" on alcasthq.com or thetankclub.com.
]],

["Any Class Tank (meta)"] = [[
UNIVERSAL META TANK

Role: Tank  |  Class: Any

WHAT THIS BUILD DOES
The universal trial/dungeon tank loadout. Works on every class.
Turning Tide + Lucent Echoes stack two group buffs (Major Vulnerability
and Lucent Echoes' group damage aura). Bloodspawn rounds out survival
and ult gen.

GEAR
  5pc body      Turning Tide    (Shipwright's Regret)
  5pc jewelry   Lucent Echoes   (Lucent Citadel trial)
  2pc monster   Bloodspawn      (Spindleclutch II)

BARS
  Front: 1H + Shield
  Back: Ice Staff (Infused, Crusher enchant)

WHY THIS IS "THE ANSWER" IF YOU DON'T KNOW WHAT TO PICK
  - Turning Tide applies Major Vulnerability (the single biggest group
    damage buff in the game) - no class required, just damage the boss.
  - Lucent Echoes stacks another trial-scale damage buff on top.
  - Bloodspawn monster is great on every tank and easy to farm.
  - Works from dungeons all the way up to veteran trials.

WHEN NOT TO RUN THIS
  - Solo tanking content where you need self-heal / damage mitigation
    more than group buff (swap to Meridia's Blessed Armor + Ironblood).
  - Budget tank (no Lucent Citadel access): run Ebon Armory + Torug's
    Pact + Lord Warden from the Budget Beginner Tank loadout.

FULL GUIDE
  Search "tank build" on alcasthq.com/category/pve-group-builds/
]],

["Budget Beginner Tank"] = [[
BUDGET BEGINNER TANK

Role: Tank  |  Class: Any

WHAT THIS BUILD DOES
No dungeon grinds required. Plague Doctor is an overland farm in
Deshaan, Torug's Pact is a 3-trait crafted set available immediately
after finishing Deshaan's main quest, and Lord Warden drops from
normal Imperial City Prison. Gets you raid-ready for dungeon groups
without grinding veteran dungeons for weeks.

GEAR
  5pc body      Plague Doctor   (Deshaan overland)
  5pc jewelry   Torug's Pact    (crafted, 3 traits)
  2pc monster   Lord Warden     (Imperial City Prison, normal)

BARS
  Front: 1H + Shield
    Crusher enchant on weapon
  Back: Ice Staff
    Crusher enchant (for double uptime with Infused)

WHY THESE SETS
  - Plague Doctor: +4227 max health. Huge stat stick that makes you
    unkillable in early dungeons while you learn the tank role.
  - Torug's Pact: Boosts the duration of your Crusher enchant by 50%,
    effectively giving your group 100% Major Breach uptime from one
    tank weapon. Enormous value for a crafted set.
  - Lord Warden: AoE resistances for allies near you. Normal IC Prison
    is farmable in ~30 minutes with any group.

TRANSITION PATH
  Once you're comfortable tanking, upgrade in this order:
  1. Swap Torug's Pact -> Drake's Rush (Scrivener's Hall) if DK,
     or Powerful Assault / Lucent Echoes if trial-capable
  2. Swap Plague Doctor -> Turning Tide (Shipwright's Regret)
  3. Swap Lord Warden -> Bloodspawn (Spindleclutch II)

FULL GUIDE
  Search "beginner tank build" on alcasthq.com or thetankclub.com.
]],

["Any Class Healer (meta)"] = [[
UNIVERSAL META HEALER

Role: Healer  |  Class: Any

WHAT THIS BUILD DOES
Current meta trial healer. Pillager's Profit returns 5% of ultimate
cost to your whole raid every time they ult - massive cycle boost.
Spell Power Cure via overheal gives Major Courage (the strongest
group damage buff). Earthgore is a safety-net burst heal on its proc.

GEAR
  5pc body      Pillager's Profit   (Dreadsail Reef trial)
  5pc jewelry   Spell Power Cure    (White-Gold Tower)
  2pc monster   Earthgore           (Bloodroot Forge)

BARS
  Front: Restoration Staff  (Infused, Absorb Magicka)
  Back: Inferno or Lightning Staff  (Infused, Weapon/Spell Damage)

ROTATION OUTLINE
  Prebuff: Blockade of Storms/Fire (back), Combat Prayer (front)
  Heal cycle: Combat Prayer -> Illustrious Healing -> Mutagen ->
              Elemental Drain -> bar swap
  Keep at least one HoT on the tank at all times.
  Over-heal allies to proc Major Courage constantly.

STRENGTHS
  - Highest ult-cycle uptime in the game (Pillager's Profit)
  - Major Courage from SPC is the cleanest source in any healer build
  - Earthgore saves wipes on heavy AoE mechanics

SWAPS / ALTERNATIVES
  - No Dreadsail Reef access: swap Pillager's -> Jorvuld's Guidance
  - For trash / dungeon spam: swap SPC -> Olorime (ground AoE Courage)

FULL GUIDE
  Search "healer build" on alcasthq.com.
]],

["Alternate Healer (no trial)"] = [[
DUNGEON-ONLY HEALER (NO TRIAL GEAR)

Role: Healer  |  Class: Any

WHAT THIS BUILD DOES
A complete healer loadout farmable entirely from 4-player content.
Jorvuld's Guidance extends your major buffs 30% for the whole group
(so every Major Courage/Force lasts longer), Spell Power Cure procs
Major Courage, and Sentinel of Rkugamz summons a dwemer spider pet
that passively AoE heals and restores stamina.

GEAR
  5pc body      Jorvuld's Guidance    (Scalecaller Peak, veteran)
  5pc jewelry   Spell Power Cure      (White-Gold Tower)
  2pc monster   Sentinel of Rkugamz   (Darkshade Caverns I)

BARS
  Front: Restoration Staff (Infused, Absorb Magicka)
  Back: Inferno or Lightning Staff (Infused, Spell Damage)

WHY THIS WORKS
  You get Major Courage from SPC, extended buff durations for the
  whole group from Jorvuld's, and a passive healing pet from Sentinel.
  Zero trial gear needed and the dungeons are all farmable through
  veteran daily pledges.

ROTATION OUTLINE
  Heal cycle same as meta: Combat Prayer + Illustrious Healing +
  Mutagen rotation with Elemental Drain on back bar for sustain.

PROGRESSION
  When you unlock trial groups, upgrade body piece to Pillager's Profit
  from Dreadsail Reef; everything else in this loadout stays relevant.

FULL GUIDE
  Search "dungeon healer build" on alcasthq.com.
]],

["Beginner DPS (overland only)"] = [[
BEGINNER DPS (OVERLAND ONLY)

Role: DPS  |  Class: Any  |  Damage type: Hybrid

WHAT THIS BUILD DOES
Every piece farmable solo from overland zones. Gets a new character
to gold-viable DPS without ever setting foot in a dungeon. Order's
Wrath is one of the best DPS sets in the game regardless of level.

GEAR
  5pc body      Order's Wrath    (High Isle overland)
  5pc jewelry   Mother's Sorrow  (Deshaan overland)
  2pc monster   Slimecraw        (Wayrest Sewers I, normal)

BARS
  Front: Dual Wield or Destro (whichever your class prefers)
  Back:  Bow, Destro, or Resto (class-dependent)

WHY THESE SETS
  - Order's Wrath: +8% crit damage AND +8% critical healing. Hybrid.
    Farmable from High Isle world bosses, delve bosses, and chests.
  - Mother's Sorrow: +1924 critical chance. Deshaan overland farm,
    reliable as the classic magicka starter set.
  - Slimecraw: 1pc normal Wayrest Sewers I drop (normal dungeon is
    beginner-friendly). Minor Berserk = +8% damage to you.

CLASS NOTES
  - Stam classes: pair with dual wield daggers (Nirn+Charged traits)
  - Mag classes: inferno staff front + inferno/lightning back
  - Run Law of Julianos or Hunding's Rage as a crafted filler until
    you've farmed Order's Wrath completely.

PROGRESSION PATH
  1. Start: Order's Wrath + Hunding's/Julianos + Slimecraw (or Kra'gh)
  2. Intermediate: swap Julianos -> Mother's Sorrow jewelry
  3. Dungeon gear: swap body -> Pillar of Nirn (stam) or Medusa (mag)
  4. Trial: transition into your class's meta build

FULL GUIDE
  Search "beginner dps build eso" on alcasthq.com or hacktheminotaur.com.
]],

}
