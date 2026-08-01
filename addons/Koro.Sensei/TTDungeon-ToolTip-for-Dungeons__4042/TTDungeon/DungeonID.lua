TTDungeon = TTDungeon or {}

-------------------------------------------------------------------------------
-- BASE DUNGEONS (NON-DLC)
-------------------------------------------------------------------------------
TTDungeon.BaseDungeonInfo_en = {

----------------------------------------------------------------------------
-- 1) The Banished Cells I (zoneId=380)
----------------------------------------------------------------------------
[380] = {
    normalId = 4,
    vetId    = 20,
    zoneId   = 380,
    sets     = {265,197,110,295,170},
    questID  = 4107,
    HM       = 1554,
    SR       = 1552,
    ND       = 1553,
    TR       = nil,
    name     = "The Banished Cells I",
    bosses = {
        {
            name = "Cell Haunter",
            mechanics = {
                "Every 15-20 seconds the boss channels a green beam to siphon a player's health (cannot be blocked or interrupted) (|c00FF00HEAL|r) :contentReference[oaicite:0]{index=0}",
                "Fires a basic magic projectile at a player for minor damage (cannot be avoided) (|cFFFFFFNO ACTION|r) :contentReference[oaicite:1]{index=1}",
                "Summons a moving tornado of frost that leaves a damaging frozen trail (|cFF0000DODGE|r) :contentReference[oaicite:2]{index=2}",
            },
        },
        {
            name = "Shadowrend",
            mechanics = {
                "Swings its tail in a 360-degree AoE, dealing high damage and a brief stun (|cFF0000DODGE or BLOCK|r) :contentReference[oaicite:3]{index=3}",
                "Summons a shadowy clone with low health that attacks the group (|cFFD700KILL|r quickly) :contentReference[oaicite:4]{index=4}",
                "Leaps onto a distant player, pinning and draining their health to heal itself (|cFF7F00INTERRUPT|r or |c00FFFFBREAK FREE|r) :contentReference[oaicite:5]{index=5}",
            },
        },
        {
            name = "Angata the Clannfear Handler",
            mechanics = {
                "Begins with many skeleton adds (including cryomancers) surrounding her (|cFFD700KILL adds first|r) :contentReference[oaicite:6]{index=6}",
                "Hurls a basic fireball at a player for moderate damage (|cFFFFFFNO ACTION|r if tanked) :contentReference[oaicite:7]{index=7}",
                "Channels a wave of fire forward that deals high damage in a line (|cFF7F00INTERRUPT|r or |cFF0000DODGE|r) :contentReference[oaicite:8]{index=8}",
                "Conjures two fiery rune circles on the ground dealing damage over time (|cFFA500AVOID|r) :contentReference[oaicite:9]{index=9}",
                "Summons a Clannfear every ~10s to aid her (|cFFD700KILL|r it quickly) :contentReference[oaicite:10]{index=10}",
            },
        },
        {
            name = "Skeletal Destroyer",
            mechanics = {
                "Starts the encounter with four scamp adds that immediately attack (|cFFD700KILL adds first|r) :contentReference[oaicite:11]{index=11}",
                "Periodically summons three skeletons that self-destruct if not killed fast (|cFFD700KILL|r them ASAP) :contentReference[oaicite:12]{index=12}",
                "Slams the ground, creating a small red circle AoE with continuous damage (|cFF0000DODGE|r) :contentReference[oaicite:13]{index=13}",
                "Winds up a frontal cleave indicated by a red telegraph (|cFF0000BLOCK|r or stay behind) :contentReference[oaicite:14]{index=14}",
            },
        },
        {
            name = "High Kinlord Rilis",
            mechanics = {
                "Delivers a heavy melee strike dealing high damage and knockdown (|cFF0000BLOCK|r) :contentReference[oaicite:15]{index=15}",
                "Fires a magic projectile at a random player causing high damage and knockback (|cFF0000BLOCK|r or |cFF0000DODGE|r) :contentReference[oaicite:16]{index=16}",
                "Summons pools of blue ghost fire under each player, dealing heavy DoT (|cFFA500MOVE|r) :contentReference[oaicite:17]{index=17}",
                "Periodically spawns two orbs that float toward him and heal on contact (|cFF00FFDESTROY|r) :contentReference[oaicite:18]{index=18}",
            },
        },
    },
},




    ----------------------------------------------------------------------------
    -- 2) The Banished Cells II (zoneId=935)
    ----------------------------------------------------------------------------
    [935] = {
        normalId = 300,
        vetId    = 301,
        zoneId   = 935,
        sets     = {265,197,110,295,170},
        questID  = 4597,
        HM       = 451,
        SR       = 449,
        ND       = 1564,
        TR       = nil,
        name     = "The Banished Cells II",
        bosses = {
            {
                name = "Keeper Areldur",
                mechanics = {
                    "Arrives with two Flame Atronachs that explode on death (|cFFD700KILL adds quickly|r; do not stand near them at 0%—|cFF0000AVOID|r the explosion) :contentReference[oaicite:0]{index=0}",
                    "Every ~10 seconds, lifts staff to fire a mortar-like Flame AoE, leaving a small burning patch (cannot be blocked) (|cFF0000DODGE|r) :contentReference[oaicite:1]{index=1}",
                    "Channels a rotating 'Flame Wheel' expanding outward; stepping in its path deals lethal damage (cannot be interrupted) (|cFF0000MOVE or ROLL|r) :contentReference[oaicite:2]{index=2}",
                },
            },
            {
                name = "Maw of the Infernal",
                mechanics = {
                    "Randomly unleashes a Flame Breath in a wide cone, dealing major damage (|cFF0000BLOCK|r or |cFF0000DODGE|r). Cannot be interrupted. :contentReference[oaicite:3]{index=3}",
                    "Immolating Bite stuns the current target, causing a DoT dropping permanent fire patches every 2s (cannot be cleansed) (|c00FF00HEAL|r & remain as still as possible) :contentReference[oaicite:4]{index=4}",
                    "A basic swipe follows the bite—block to reduce damage, may knock down if unblocked (|cFF0000BLOCK|r) :contentReference[oaicite:5]{index=5}",
                    "Environmental Fire Trap near the entrance can heavily damage the boss if you lure him onto it (|cFFD700USE environment|r) :contentReference[oaicite:6]{index=6}",
                },
            },
            {
                name = "Keeper Voranil",
                mechanics = {
                    "Begins with two Daedra adds—focus them first to prevent overwhelm (|cFFD700KILL adds|r) :contentReference[oaicite:7]{index=7}",
                    "Heavy Attack that must be blocked or it can one-shot (|cFF0000BLOCK|r) :contentReference[oaicite:8]{index=8}",
                    "Performs a Whirlwind AoE around himself—cannot be interrupted (|cFF0000DODGE|r or back away) :contentReference[oaicite:9]{index=9}",
                },
            },
            {
                name = "Keeper Imiril",
                mechanics = {
                    "Every ~25s she teleports into a blue orb, summoning add waves (Banekin, Twilights, Clannfears in rotation). (|cFFD700KILL adds quickly|r before she returns) :contentReference[oaicite:10]{index=10}",
                    "When reappearing, she emits a large AoE burst—cannot be interrupted (|cFF0000BLOCK|r or |cFF0000DODGE|r) :contentReference[oaicite:11]{index=11}",
                    "Blue illusions/orbs bounce around the arena, dealing damage on contact (cannot be blocked) (|cFFA500AVOID|r) :contentReference[oaicite:12]{index=12}",
                    "Tank: Keep her in the center to limit chaos; coordinate quick AoE to clear each add phase. :contentReference[oaicite:13]{index=13}",
                },
            },
            {
                name = "Sister Vera & Sister Sihna",
                mechanics = {
                    "Both are ranged Harvesters; spawn 'Feasts' (healing orbs) that move toward them—kill these orbs fast (|cFFD700DESTROY orbs|r) :contentReference[oaicite:14]{index=14}",
                    "Occasionally shield each other with a strong Damage Shield (cannot be purged)—focus the unshielded sister (|cFFD700SWAP target|r) :contentReference[oaicite:15]{index=15}",
                    "They channel a frontal AoE knockback; it can be interrupted (|cFF7F00BASH|r) or you must move away to avoid heavy damage :contentReference[oaicite:16]{index=16}",
                    "Tank: Use line-of-sight (e.g. behind pillars) to stack them together for group AoE damage. :contentReference[oaicite:17]{index=17}",
                },
            },
            {
                name = "High Kinlord Rilis",
                mechanics = {
                    "Primarily ranged, summons Daedroths and 'Feast' orbs that heal him if not destroyed (|cFFD700KILL orbs quickly|r) :contentReference[oaicite:18]{index=18}",
                    "Levitation Bubble curses a random player red/blue (cannot be blocked/interrupted). Match the color rune to cleanse (|c00FFFFMATCH color|r) :contentReference[oaicite:19]{index=19}",
                    "Repeated lightning staff hits target if taunted; can kill non-tanks in ~2 hits (|cFF0000BLOCK|r recommended) :contentReference[oaicite:20]{index=20}",
                    "Drops large flame AoEs where players stand; these linger and stack (|cFF0000MOVE|r). Daedroths can also pin players—break free or block. :contentReference[oaicite:21]{index=21}",
                    "Hard Mode: Defeat Rilis with three Daedroths still alive. Stop DPS at low boss HP until the third Daedroth spawns (|cFFD700HARDMODE condition|r) :contentReference[oaicite:22]{index=22}",
                },
            },
        },
    },



    ----------------------------------------------------------------------------
    -- 3) Fungal Grotto I (zoneId=283)
    ----------------------------------------------------------------------------
    [283] = {
        normalId = 2,
        vetId    = 299,
        zoneId   = 283,
        sets     = {266,162,33,61,297},
        questID  = 3993,
        HM       = 1561,
        SR       = 1559,
        ND       = 1560,
        TR       = nil,
        name     = "Fungal Grotto I",
        bosses = {
            {
                name = "Tazkad the Packmaster",
                mechanics = {
                    "Arrives with multiple goblins and Durzogs (|cFFD700KILL adds first|r if possible) :contentReference[oaicite:0]{index=0}",
                    "Casts |cFF0000Agony|r (similar to Nightblade ability) on the tank, briefly stunning them (can be |cFF7F00INTERRUPT|r or |c00FFFFBREAK FREE|r) :contentReference[oaicite:1]{index=1}",
                    "Uses |cFF0000Blood Craze|r, a low-damage DoT on whoever has aggro (cannot be avoided). Healer should watch for it on squishy targets. :contentReference[oaicite:2]{index=2}",
                    "Frenzy of Blows: a cone attack hitting the tank several times—block or stay behind boss (|cFF0000BLOCK|r recommended if targeted) :contentReference[oaicite:3]{index=3}",
                },
            },
            {
                name = "Warchief Ozazai",
                mechanics = {
                    "Starts with two Murkwater War Guards who drop a DK standard and use shield charge (|cFFD700KILL adds first|r). :contentReference[oaicite:4]{index=4}",
                    "Opens with |cFF0000Shock Assault|r by leaping onto a target and causing AoE damage on impact (cannot be interrupted). :contentReference[oaicite:5]{index=5}",
                    "Heavy Attack (|cFF0000Haymaker|r): must be blocked or it knocks down the target (|cFF0000BLOCK|r). :contentReference[oaicite:6]{index=6}",
                    "Periodically casts |cFF0000Daedric Blast|r (red beam on a player), creating a growing red AoE that explodes—move away from the group or group steps away (|cFF0000DODGE|r) :contentReference[oaicite:7]{index=7}",
                    "Below ~30% HP, uses |cFF0000Staggering Roar|r, dealing moderate physical AoE. Ranged can outrange it; melee should block or step out (|cFF0000BLOCK or MOVE|r). :contentReference[oaicite:8]{index=8}",
                },
            },
            {
                name = "Broodbirther",
                mechanics = {
                    "Comes with two Dreugh adds; focus them first or use AoE to handle all at once (|cFFD700KILL adds|r). :contentReference[oaicite:9]{index=9}",
                    "Randomly pulls a player to the boss (cannot be blocked) (|c00FFFFBREAK FREE|r if stunned). :contentReference[oaicite:10]{index=10}",
                    "Channels |cFF0000Shocking Rake|r, a frontal cone lightning attack—tank should face boss away; group stands behind (|cFF0000BLOCK|r if tank, or |cFF0000AVOID|r). :contentReference[oaicite:11]{index=11}",
                },
            },
            {
                name = "Clatterclaw",
                mechanics = {
                    "A giant mudcrab that summons ~8-10 smaller mudcrabs every ~10s (|cFFD700KILL them quickly|r with AoE). :contentReference[oaicite:12]{index=12}",
                    "Mostly uses basic heavy attacks; block or dodge if targeted. :contentReference[oaicite:13]{index=13}",
                    "Avoid running around if adds chase you—stay in healing range and let AoE / tank handle them. :contentReference[oaicite:14]{index=14}",
                },
            },
            {
                name = "Kra’gh the Dreugh King",
                mechanics = {
                    "Delivers a strong Heavy Attack (|cFF0000Lunge|r) that must be blocked or it knocks you flying (|cFF0000BLOCK|r). :contentReference[oaicite:15]{index=15}",
                    "Uses |cFF0000Storm Flurry|r—a rapid lightning combo on the tank (cannot be interrupted). Blocking is recommended; lethal for non-tanks. :contentReference[oaicite:16]{index=16}",
                    "Occasionally spawns a few mudcrabs—easy to kill with AoE, but don't run away. :contentReference[oaicite:17]{index=17}",
                    "Channels a large |cFF0000Lightning Field|r expanding outward—explodes at max size (can one-shot non-tanks). (|cFF0000MOVE out|r) :contentReference[oaicite:18]{index=18}",
                    "Hard Mode simply increases health/damage with no extra mechanics. Watch the lightning field and keep blocks up. :contentReference[oaicite:19]{index=19}",
                },
            },
        },
    },


    ----------------------------------------------------------------------------
    -- 4) Fungal Grotto II (zoneId=934)
    ----------------------------------------------------------------------------
    [934] = {
        normalId = 18,
        vetId    = 312,
        zoneId   = 934,
        sets     = {266,162,33,61,297},
        questID  = 4303,
        HM       = 342,
        SR       = 340,
        ND       = 1563,
        TR       = nil,
        name     = "Fungal Grotto II",
        bosses = {
            {
                name = "Mephala’s Fang",
                mechanics = {
                    "Begins with two healer adds—focus them first or they’ll heal the boss (|cFFD700KILL adds|r) :contentReference[oaicite:0]{index=0}",
                    "Heavy Attack: Must be blocked or it knocks the target down (|cFF0000BLOCK|r) :contentReference[oaicite:1]{index=1}",
                    "Sprays poison in a frontal cone (|cFF7F00INTERRUPT|r if possible, or |cFF0000DODGE|r) :contentReference[oaicite:2]{index=2}",
                    "Poisons a random player’s feet, leaving a DoT circle that lingers—quickly move out & stack these together to avoid covering the arena (|cFF0000MOVE|r) :contentReference[oaicite:3]{index=3}",
                },
            },
            {
                name = "Gamyne Bandu",
                mechanics = {
                    "Heavy Attack (|cFF0000Ripper|r) that deals high damage—block or get knocked back (|cFF0000BLOCK|r) :contentReference[oaicite:4]{index=4}",
                    "Randomly chains two players together with a dark tether—run in opposite directions to break it (|cFF0000SPREAD OUT|r) :contentReference[oaicite:5]{index=5}",
                    "Summons four shades capturing a single player with a spike. Killing ANY ONE shade breaks the chain & saves them (|cFFD700FOCUS one shade|r) :contentReference[oaicite:6]{index=6}",
                    "Splits into four Obsidian Aspects—kill them all to force her return. She may open with a heavy hit after reappearing (|cFF0000BLOCK|r) :contentReference[oaicite:7]{index=7}",
                },
            },
            {
                name = "Ciirenas the Shepherd",
                mechanics = {
                    "Three spiders accompany her—do NOT kill them or the boss gains massive damage reduction. :contentReference[oaicite:8]{index=8}",
                    "Marks a random player with pheromones, causing spiders to chase them—kite them away from the group (|cFFA500AVOID killing them|r) :contentReference[oaicite:9]{index=9}",
                    "Casts repeated Dark Bolt or Shadow Bolt, typically on random group members (|cFF7F00INTERRUPT|r to reduce incoming damage) :contentReference[oaicite:10]{index=10}",
                    "If forced near a cliff edge or pillar, she can reset—tank should keep a ranged taunt to hold her in place. :contentReference[oaicite:11]{index=11}",
                },
            },
            {
                name = "Spawn of Mephala",
                mechanics = {
                    "Summons a portal near the cave wall—closest player gets pulled in to fight extra spiders. They exit automatically ~10% boss HP or by killing the spiders. :contentReference[oaicite:12]{index=12}",
                    "Large red AoE expands from boss—detonates with high damage and knockdown (|cFF0000MOVE|r). :contentReference[oaicite:13]{index=13}",
                    "Creates a slow-moving beam from altars that follows a player—can be outrun or let the tank soak it (|cFF0000DODGE|r). :contentReference[oaicite:14]{index=14}",
                    "Random Shadow Bolt knocks players backward on impact—roll dodge or block if possible (|cFF0000BLOCK|r recommended). :contentReference[oaicite:15]{index=15}",
                },
            },
            {
                name = "Reggr Dark-Dawn",
                mechanics = {
                    "Uses |cFF0000Orb of Enervation|r draining magicka from the group—delay using potions until after it finishes. :contentReference[oaicite:16]{index=16}",
                    "Heavy Attack that must be blocked or it can kill a non-tank instantly (|cFF0000BLOCK|r). :contentReference[oaicite:17]{index=17}",
                    "Frenzy AoE: whirls weapon in a small circle—step out or block (|cFF0000DODGE|r or |cFF0000BLOCK|r). :contentReference[oaicite:18]{index=18}",
                    "Numerous adds around the room (Obsidian Warriors). Clear them safely or snipe the boss from above. :contentReference[oaicite:19]{index=19}",
                },
            },
            {
                name = "Vila Theran",
                mechanics = {
                    "Casts Shadow Bolt from range—she won’t move unless forced out of casting range. (Tank can reposition her with distance) :contentReference[oaicite:20]{index=20}",
                    "Growing Corruption: Teleports to multiple players, dropping expanding black AoEs—group stacks together, then moves as one (|cFF0000MOVE|r) :contentReference[oaicite:21]{index=21}",
                    "Channels a high-damage Shadow AoE (Channeled Shadow or Laser). Healer can mitigate or group can use protective shield spots if available. :contentReference[oaicite:22]{index=22}",
                    "Hard Mode typically increases damage/health but no new mechanics—be mindful of high DoT and AoE overlap. :contentReference[oaicite:23]{index=23}",
                },
            },
        },
    },


    ----------------------------------------------------------------------------
    -- 5) Spindleclutch I (zoneId=144)
    ----------------------------------------------------------------------------
    [144] = {
        normalId = 3,
        vetId    = 315,
        zoneId   = 144,
        sets     = {163,267,296,55,35},
        questID  = 4054,
        HM       = 1570,
        SR       = 1568,
        ND       = 1569,
        TR       = nil,
        name     = "Spindleclutch I",
        bosses = {
            {
                name = "Spindlekin",
                mechanics = {
                    "Periodically summons small spider adds that spit poison or lay webs (|cFFD700KILL them quickly|r) :contentReference[oaicite:0]{index=0}",
                    "Devours dead spiders to heal herself if not interrupted—watch for eating animation (|cFF7F00INTERRUPT|r) :contentReference[oaicite:1]{index=1}",
                    "Basic poison spit & light attacks can be blocked or out-healed (|cFF0000BLOCK|r when targeted) :contentReference[oaicite:2]{index=2}",
                    "Tank: Hold boss in place, gather spider adds close for AoE. DPS stand behind boss. :contentReference[oaicite:3]{index=3}",
                },
            },
            {
                name = "Swarm Mother",
                mechanics = {
                    "Summons additional spiders—keep them taunted or kill quickly with AoE (|cFFD700CLEAR adds|r) :contentReference[oaicite:4]{index=4}",
                    "Heavy Attack: Rears up and slams the target—must be blocked or it knocks you back (|cFF0000BLOCK|r) :contentReference[oaicite:5]{index=5}",
                    "Occasionally leaps onto a distant player, dealing high damage on impact (|cFF0000DODGE|r or |cFF0000BLOCK|r if targeted) :contentReference[oaicite:6]{index=6}",
                    "Tank: Keep boss facing away; party should stack near boss to limit leaps. :contentReference[oaicite:7]{index=7}",
                },
            },
            {
                name = "Cerise the Widow-Maker",
                mechanics = {
                    "Surrounded by multiple corrupted Fighters Guild adds (|cFFD700KILL adds|r first or AoE them down) :contentReference[oaicite:8]{index=8}",
                    "Heavy Attack that can one-shot a non-tank if not blocked (|cFF0000BLOCK|r) :contentReference[oaicite:9]{index=9}",
                    "Channels an Immobilize/Stun—can be interrupted (|cFF7F00INTERRUPT|r) or break free if hit (|c00FFFFBREAK FREE|r) :contentReference[oaicite:10]{index=10}",
                    "Flurry-like quick strikes on the tank—block to reduce incoming damage (|cFF0000BLOCK|r recommended). :contentReference[oaicite:11]{index=11}",
                },
            },
            {
                name = "Big Rabbu",
                mechanics = {
                    "Accompanied by multiple corrupted Fighters Guild adds—focus them first if needed (|cFFD700KILL adds|r) :contentReference[oaicite:12]{index=12}",
                    "Performs a noticeable |cFF0000Charge|r indicated by a red strip on the floor—|cFF0000DODGE|r or block to avoid knockdown :contentReference[oaicite:13]{index=13}",
                    "Occasionally chains a random player in—block immediately to avoid big hits (|cFF0000BLOCK|r) :contentReference[oaicite:14]{index=14}",
                    "Tank: Keep Rabbu turned away, gather adds near him for efficient AoE. :contentReference[oaicite:15]{index=15}",
                },
            },
            {
                name = "The Whisperer",
                mechanics = {
                    "A massive spider Daedra—pull & kill surrounding adds before engaging. :contentReference[oaicite:16]{index=16}",
                    "Web Pull: Drags players to her, often followed by a Daedric Explosion AoE—move out fast (|cFF0000MOVE|r) :contentReference[oaicite:17]{index=17}",
                    "Arachnophobia: Fires a deadly projectile at a random player—must be dodge-rolled or it can stun/kill (|cFF0000DODGE|r) :contentReference[oaicite:18]{index=18}",
                    "Impale: Basic heavy melee hit on the tank—blockable (|cFF0000BLOCK|r) :contentReference[oaicite:19]{index=19}",
                    "Hard Mode: Increases her health and damage; same mechanics, so avoid AoEs & projectiles. :contentReference[oaicite:20]{index=20}",
                },
            },
        },
    },


    ----------------------------------------------------------------------------
    -- 6) Spindleclutch II (zoneId=936)
    ----------------------------------------------------------------------------
    [936] = {
        normalId = 316,
        vetId    = 19,
        zoneId   = 936,
        sets     = {163,267,296,55,35},
        questID  = 4555,
        HM       = 448,
        SR       = 446,
        ND       = 1572, 
        TR       = nil, 
        name     = "Spindleclutch II",
        bosses = {

            
            {
                name = "Mad Mortine",
                mechanics = {
                    "Arrives with many bloodfiend adds—|cFFD700KILL adds first|r or group them for AoE. Don't run around. :contentReference[oaicite:0]{index=0}",
                    "Flurry: Rapid melee hits on the tank over ~2s—block throughout or suffer high damage (|cFF0000BLOCK|r). :contentReference[oaicite:1]{index=1}",
                    "Jump Attack: Boss leaps upward at point-blank range, slamming down hard—(|cFF0000BLOCK|r if you have aggro). :contentReference[oaicite:2]{index=2}",
                },
            },

            
            {
                name = "Bloodspawn",
                mechanics = {
                    "Heavy Attack (Smash): Must be blocked or you'll be knocked back (|cFF0000BLOCK|r). :contentReference[oaicite:3]{index=3}",
                    "Cave-In: Periodically slams the ground—inner area is bombarded in 3 ticks, block/heal through it if you remain. :contentReference[oaicite:4]{index=4}",
                    "Crushing Rocks: Outer edges fill with falling rocks—avoid them or it's instant death (|cFF0000MOVE|r from edges). :contentReference[oaicite:5]{index=5}",
                    "Enrage ~2 minutes in: Spam AoE + unstoppable damage (very deadly). Burn boss to near ~10% before enrage. :contentReference[oaicite:6]{index=6}",
                    "Note: This boss |cFFD700can be skipped|r by running along the right edge of room if desired. :contentReference[oaicite:7]{index=7}",
                },
            },

            
            {
                name = "Praxin Douare",
                mechanics = {
                    "Waves: 4 add phases (spiders, Swarm Mother, Rabbu + Cerise, Whisperer). Boss is invulnerable until waves are cleared or time passes. :contentReference[oaicite:8]{index=8}",
                    "Harrowing Ring: Random player gets a red ring around them—|cFF0000DO NOT CROSS the ring boundary|r or it's instant death. In stay in, out stay out. :contentReference[oaicite:9]{index=9}",
                    "Frontal Trident Strike: Boss channels slow 3-line AoE forward—face him away from group (|cFF0000BLOCK|r or sidestep). :contentReference[oaicite:10]{index=10}",
                    "Drain: Random player gets resources drained if not dodged. Keep potions or heavy attacks ready. :contentReference[oaicite:11]{index=11}",
                },
            },

            
            {
                name = "Flesh Atronach Trio",
                mechanics = {
                    "Three flesh atronachs at once; each can Heavy Attack—|cFF0000BLOCK|r if tanking. :contentReference[oaicite:12]{index=12}",
                    "Killing one re-heals & enrages the others—try to DPS them evenly and kill all 3 around the same time (|cFFD700SIMULTANEOUS kills|r). :contentReference[oaicite:13]{index=13}",
                    "Stand behind them if you're DPS—each has a conal swipe. :contentReference[oaicite:14]{index=14}",
                },
            },

           
            {
                name = "Urvan Veleth",
                mechanics = {
                    "Starts with four ghost adds (archers/warriors) that drop DK standards—|cFFD700KILL adds quickly|r or you'll be overwhelmed. :contentReference[oaicite:15]{index=15}",
                    "Heavy Attack (shield slam) after boss blocks—if tank tries a heavy attack during the boss's block, the tank gets stunned. Watch for that. (|cFF0000BLOCK|r). :contentReference[oaicite:16]{index=16}",
                    "Blood Puddle: Boss submerges into blood and chases tank, draining health (heals him). Move slowly/block to minimize heals. :contentReference[oaicite:17]{index=17}",
                },
            },

            
            {
                name = "Vorenor Winterbourne",
                mechanics = {
                    "No conventional adds—only 3 'sacrifices' around the room. If not killed, boss can siphon them for minor healing. :contentReference[oaicite:18]{index=18}",
                    "Blood Circle: Targets a random player—leaves a damaging red AoE on the floor. Move out quickly (|cFF0000MOVE|r). :contentReference[oaicite:19]{index=19}",
                    "Teleport Strike: Boss raises hand & teleports to each player in turn—everyone should block or risk high damage (|cFF0000BLOCK|r). :contentReference[oaicite:20]{index=20}",
                    "Hard Mode: Do not kill any sacrifices. Vorenor has more HP/damage. Burn him despite his healing. :contentReference[oaicite:21]{index=21}",
                },
            },

        },
    },


    ----------------------------------------------------------------------------
    -- 7) Darkshade Caverns I (zoneId=63)
    ----------------------------------------------------------------------------
    [63] = {
        normalId = 5,
        vetId    = 309,
        zoneId   = 63,
        sets     = {166,268,301,300,96},
        questID  = 4145,
        HM       = 1586,
        SR       = 1584,
        ND       = 1585,
        TR       = nil,
        name     = "Darkshade Caverns I",
        bosses = {

            {
                name = "Head Shepherd Neloren",
                mechanics = {
                    "Primarily casts |cFF0000Fire|r-based projectiles, landing small splash AoEs (|cFFFFFFNO ACTION|r if tanked) :contentReference[oaicite:0]{index=0}",
                    "Heals herself or allies frequently with powerful restore spells (|cFF7F00INTERRUPT|r) :contentReference[oaicite:1]{index=1}",
                    "Sometimes channels a short-duration healing prayer (very large heal if not interrupted) :contentReference[oaicite:2]{index=2}",
                },
            },

            {
                name = "Foreman Llothan",
                mechanics = {
                    "Stays at range but relocates ~every 10s (|cFFA500WATCH|r for a shock AoE as he moves) :contentReference[oaicite:3]{index=3}",
                    "Throws poison vials onto the floor, creating DoT zones (|cFF0000MOVE|r out quickly) :contentReference[oaicite:4]{index=4}",
                    "Summons small kwama adds at ~75/50/25% HP. Kill them swiftly or use AoE (|cFFD700KILL adds|r). :contentReference[oaicite:5]{index=5}",
                    "Occasional shock explosion around him if you stay too close—knocks you down if caught. :contentReference[oaicite:6]{index=6}",
                },
            },

            {
                name = "The Hive Lord",
                mechanics = {
                    "Randomly jumps onto distant players if they run away—stay close to avoid leaps (|cFF0000NO RUNNING|r) :contentReference[oaicite:7]{index=7}",
                    "Overhead or conal smash—block or avoid if you have aggro (|cFF0000BLOCK|r recommended). :contentReference[oaicite:8]{index=8}",
                    "Summons 3 kwama scrib adds by digging into the ground (small AoE snare). AoE them down. :contentReference[oaicite:9]{index=9}",
                    "Ground Pound: Repeated AoE pulses. Bash/interrupt him to stop or endure heavy hits (|cFF7F00INTERRUPT|r). :contentReference[oaicite:10]{index=10}",
                    "Note: This boss can be |cFFD700skipped|r by jumping down to Netch area if desired. :contentReference[oaicite:11]{index=11}",
                },
            },

            {
                name = "Cavern Patriarch",
                mechanics = {
                    "Large netch with a basic heavy attack—tank should block or risk knockdown (|cFF0000BLOCK|r). :contentReference[oaicite:12]{index=12}",
                    "Casts a big poison cloud, usually beneath itself—move the boss or step out (|cFF0000MOVE|r). :contentReference[oaicite:13]{index=13}",
                    "Otherwise minimal mechanics—keep boss faced away for safer DPS. :contentReference[oaicite:14]{index=14}",
                },
            },

            {
                name = "Cutting Sphere",
                mechanics = {
                    "Has dwarven spider adds—pull them in or kill them first (|cFFD700CLEAR adds|r). :contentReference[oaicite:15]{index=15}",
                    "Darts a heavy steam projectile at range—must be blocked or it can knock you down (|cFF0000BLOCK|r). :contentReference[oaicite:16]{index=16}",
                    "Jumps up and slams down, causing AoE damage on impact (|cFF0000DODGE|r). :contentReference[oaicite:17]{index=17}",
                    "Spins in a frenzy, chasing aggro target—tank should block and stand still if possible. (|cFF0000BLOCK|r) :contentReference[oaicite:18]{index=18}",
                    "Note: This boss is optional; can be skipped if not needed for quest or achievements. :contentReference[oaicite:19]{index=19}",
                },
            },

            {
                name = "Sentinel of Rkugamz",
                mechanics = {
                    "Color-coded phases:\n    • |c00FF00Green|r = Standard/Heavy Attack, summoning Dwemer spiders that spawn green healing fields (keep him away from them or kill spiders)\n    • |cFF0000Red|r = Spin chase—random player targeted, boss spins in AoE. Kite in a wide circle (|cFF0000MOVE|r, no taunt possible)\n    • |c00FFFFBlue|r = Lightning barrage from above—keep moving to avoid falling shock orbs :contentReference[oaicite:20]{index=20}",
                    "When green, delivers a strong frontal cleave (Decapitation) that can knock back—(|cFF0000BLOCK|r if tank). :contentReference[oaicite:21]{index=21}",
                    "At ~25% HP, summons extra Dwemer spiders with green circles—touching them heals him further. :contentReference[oaicite:22]{index=22}",
                    "Stand behind him except in red spin phase. If you get chased in red, coordinate and keep him in your AoE while you kite. :contentReference[oaicite:23]{index=23}",
                    "Hard Mode: Higher HP/damage, same mechanics. :contentReference[oaicite:24]{index=24}",
                },
            },

        },
    },


    ----------------------------------------------------------------------------
    -- 8) Darkshade Caverns II (zoneId=930)
    ----------------------------------------------------------------------------
    [930] = {
        normalId = 308,
        vetId    = 21,
        zoneId   = 930,
        sets     = {166,268,301,300,96},
        questID  = 4641,
        HM       = 467,
        SR       = 465,
        ND       = 1588,
        TR       = nil,
        name     = "Darkshade Caverns II",
        bosses = {

            
            {
                name = "The Fallen Foreman",
                mechanics = {
                    "Starts with multiple Pit Rat adds—|cFFD700KILL adds first|r or group them for AoE. :contentReference[oaicite:0]{index=0}",
                    "Casts basic fireball at tank (moderate damage) (|cFFFFFFNO ACTION|r if tanked). :contentReference[oaicite:1]{index=1}",
                    "Spinning Flames: Slowly rotates a 360-degree flame beam—|cFF0000DODGE or MOVE|r around boss; it can wipe groups if caught. :contentReference[oaicite:2]{index=2}",
                },
            },

            
            {
                name = "Transmuted Hive Lord",
                mechanics = {
                    "Two small Scrib adds stay with boss. They can channel a stun & resource drain (|cFF7F00INTERRUPT|r if possible). :contentReference[oaicite:3]{index=3}",
                    "Heavy Slam: Occasional ground slam—block if tanking or |cFF0000DODGE|r if DPS/healer. :contentReference[oaicite:4]{index=4}",
                    "Enraged Slam (low HP): Gains damage shield & repeatedly slams the floor; keep healing & break the shield with DPS. :contentReference[oaicite:5]{index=5}",
                },
            },

            
            {
                name = "Transmuted Alit",
                mechanics = {
                    "Encounter with 3 Alits at once; each can Heavy Attack—|cFF0000BLOCK|r if tank. :contentReference[oaicite:6]{index=6}",
                    "When one dies, it can revive if the others aren’t killed quickly—DPS them evenly (|cFFD700SIMULTANEOUS kills|r). :contentReference[oaicite:7]{index=7}",
                    "Breath attacks in a frontal cone—tank faces them away; group stays behind or flanks. :contentReference[oaicite:8]{index=8}",
                    "Optional boss for speed runs—can be skipped if desired. :contentReference[oaicite:9]{index=9}",
                },
            },

            
            {
                name = "Grobull the Transmuted",
                mechanics = {
                    "Boss is surrounded by a lightning shield that reflects projectiles—avoid direct hits until shield drops. :contentReference[oaicite:10]{index=10}",
                    "Summons small & large Netch adds that must be killed to charge the boss’s downfall. Tank taunts large ones. (|cFFD700KILL adds|r) :contentReference[oaicite:11]{index=11}",
                    "After enough adds die, Grobull drops to ground for ~10s, removing shield—burn him fast (|cFFD700ALL-OUT DPS|r). :contentReference[oaicite:12]{index=12}",
                    "He repeats phases with more add waves until defeated. :contentReference[oaicite:13]{index=13}",
                },
            },

            
            {
                name = "Engine Garrison",
                mechanics = {
                    "Massive wave of Dwemer constructs (Spheres, Spiders, Centurions). Tank must carefully pull group by group. :contentReference[oaicite:14]{index=14}",
                    "If pulled too quickly, multiple Centurions can overwhelm the party. (|cFF0000PACE the pulls|r) :contentReference[oaicite:15]{index=15}",
                    "Dwarven Spheres cast ranged darts & ground AoEs—focus them or pull them in. :contentReference[oaicite:16]{index=16}",
                    "Dwarven Spiders can empower others with lightning if left alone—kill them quickly or interrupt. :contentReference[oaicite:17]{index=17}",
                    "Centurions have heavy hits—|cFF0000BLOCK|r if targeted or let tank hold them away from group. :contentReference[oaicite:18]{index=18}",
                },
            },

            
            {
                name = "The Engine Guardian",
                mechanics = {
                    "Randomly cycles 3 phases: |cFF0000Fire|r, |c00FF00Poison|r, |c00FFFFLightning|r. Each demands different spacing. Cannot be permanently taunted but keep taunt up for debuff. :contentReference[oaicite:19]{index=19}",
                    "|cFF0000Fire|r: Boss rotates flames in 360°, dropping fire AoEs. Stay ranged or sidestep. Leaves small mortar blasts on ground. :contentReference[oaicite:20]{index=20}",
                    "|c00FF00Poison|r: Group-wide DoT ticks. Heal or shield through it. Avoid boss if spinning poison jets. Four middle levers can stop poison but disables Hard Mode. :contentReference[oaicite:21]{index=21}",
                    "|c00FFFFLightning|r: Being close to boss is lethal. Summons dwarven spheres—|cFFD700KILL them quickly|r or they accumulate. :contentReference[oaicite:22]{index=22}",
                    "Hard Mode: Don’t use the levers to remove poison. Survive all 3 phases with heavier hits. :contentReference[oaicite:23]{index=23}",
                },
            },
        },
    },


    ----------------------------------------------------------------------------
    -- 9) Elden Hollow I (zoneId=126)
    ----------------------------------------------------------------------------
    [126] = {
        normalId = 7,
        vetId    = 23,
        zoneId   = 126,
        sets     = {269,167,298,155,28},
        questID  = 4336,
        HM       = 1578,
        SR       = 1576,
        ND       = 1577,
        TR       = nil,
        name     = "Elden Hollow I",
        bosses = {

            {
                name = "Akash gra-Mal",
                mechanics = {
                    "Basic frontal cleave (cone-shaped), knocks back if not blocked. Tank: keep her faced away (|cFF0000BLOCK|r recommended) :contentReference[oaicite:0]{index=0}",
                    "Occasionally performs an overhead swing or 'whirlwind' around her—step out of the small red circle (|cFF0000DODGE|r) :contentReference[oaicite:1]{index=1}",
                    "If players run far, she leaps onto them, dealing a short stun/damage (stay close to prevent leap) (|cFF0000NO RUNNING|r) :contentReference[oaicite:2]{index=2}",
                },
            },

            {
                name = "Ancient Spriggan",
                mechanics = {
                    "Arrives with three smaller spriggans that can heal each other (|cFFD700KILL adds|r quickly or interrupt heals) :contentReference[oaicite:3]{index=3}",
                    "Channels a self-heal or ally-heal that can be interrupted (|cFF7F00INTERRUPT|r) :contentReference[oaicite:4]{index=4}",
                    "Uses weak basic attacks—Tank faces the boss away, group can stand behind, AoE down the adds. :contentReference[oaicite:5]{index=5}",
                },
            },

            {
                name = "Chokethorn",
                mechanics = {
                    "Randomly pulls a distant player with vines, dealing minimal damage (|cFF0000MOVE back in position|r) :contentReference[oaicite:6]{index=6}",
                    "Summons small stranglers around the room that heal Chokethorn if left alive (|cFFD700KILL stranglers|r) :contentReference[oaicite:7]{index=7}",
                    "Spreads a large AoE from center, dealing heavy damage (~90% HP) if caught—|cFF0000DODGE or get out|r asap :contentReference[oaicite:8]{index=8}",
                },
            },

            {
                name = "Nenesh gro-Mal",
                mechanics = {
                    "Accompanied by multiple orc adds—clear them first or chain them together for AoE (|cFFD700KILL adds|r) :contentReference[oaicite:9]{index=9}",
                    "Channels a 2H uppercut that must be blocked (or it knocks you down) (|cFF0000BLOCK|r) :contentReference[oaicite:10]{index=10}",
                    "Casts weak 'Mage's Fury'-like lightning that can be interrupted (|cFF7F00INTERRUPT|r) :contentReference[oaicite:11]{index=11}",
                },
            },

            {
                name = "Leafseether",
                mechanics = {
                    "Comes with a basic Alit add—taunt/kill quickly so it doesn't disrupt the fight. :contentReference[oaicite:12]{index=12}",
                    "Heavy Attack Jump: leaps at the tank or target if not blocked, dealing knockdown (|cFF0000BLOCK|r) :contentReference[oaicite:13]{index=13}",
                    "Cone bite or 'breathing' animation—step aside or block (|cFF0000DODGE|r / |cFF0000BLOCK|r). :contentReference[oaicite:14]{index=14}",
                },
            },

            {
                name = "Canonreeve Oraneth",
                mechanics = {
                    "Spawns a small frost aura around herself, deals minor DoT if close (|cFF0000AVOID standing in front|r) :contentReference[oaicite:15]{index=15}",
                    "Hurls a poison bolt at a random player—roll dodge to negate or block if in danger (|cFF0000DODGE|r) :contentReference[oaicite:16]{index=16}",
                    "Casts small AoE snares on the floor, pulls players in briefly—break free (|c00FFFFBREAK FREE|r). Then spawns four skeletons. (|cFFD700KILL adds|r) :contentReference[oaicite:17]{index=17}",
                    "Channels a large expanding AoE from center—can one-shot if not avoided (|cFF0000MOVE|r out quickly). :contentReference[oaicite:18]{index=18}",
                },
            },

        },
    },


    ----------------------------------------------------------------------------
    -- 10) Elden Hollow II (zoneId=931)
    ----------------------------------------------------------------------------
    [931] = {
        normalId = 303,
        vetId    = 302,
        zoneId   = 931,
        sets     = {269,167,298,155,28},
        questID  = 4675,
        HM       = 463,
        SR       = 461,
        ND       = 1580,
        TR       = nil,
        name     = "Elden Hollow II",
        bosses   = {

            -- 1) Dubroze the Infestor
            {
                name = "Dubroze the Infestor",
                mechanics = {
                    "Starts with several ranged caster adds—|cFFD700KILL adds first|r or they overwhelm. Tank can group them in. :contentReference[oaicite:0]{index=0}",
                    "Classic Daedroth mechanics—turn away from group, block Flame Breath or break free from stun (|cFF0000BLOCK|r). :contentReference[oaicite:1]{index=1}",
                    "Healer/dps must avoid frontal cone & any sweeping tail or ground AoE. :contentReference[oaicite:2]{index=2}",
                },
            },

            -- 2) Dark Root
            {
                name = "Dark Root",
                mechanics = {
                    "Periodically spawns two Hoarvor adds: Blue (magicka buff) & Green (stamina buff). Kill them and stand in matching circle to gain large resource bonus. :contentReference[oaicite:3]{index=3}",
                    "Casts Radiant Beam from above on a random player, dealing high AoE splash—stand apart so multiple players aren’t hit together (|cFF0000SPREAD OUT|r). :contentReference[oaicite:4]{index=4}",
                    "Tank: Keep her still and maintain taunt; no need to spin boss. :contentReference[oaicite:5]{index=5}",
                },
            },

            -- 3) Azara the Frightener
            {
                name = "Azara the Frightener",
                mechanics = {
                    "Arrives with caster adds—interrupt or kill them quickly (|cFFD700KILL adds|r). :contentReference[oaicite:6]{index=6}",
                    "Heavy Attack that should be blocked or it knocks you back (|cFF0000BLOCK|r). :contentReference[oaicite:7]{index=7}",
                    "Summons mind-controlling 'shadow' adds that fear players if left alive—|cFFD700PRIORITIZE killing shadows|r. :contentReference[oaicite:8]{index=8}",
                },
            },

            -- 4) Murklight
            {
                name = "Murklight",
                mechanics = {
                    "Cast small red AoEs on ground—avoid them initially (|cFF0000MOVE out|r). :contentReference[oaicite:9]{index=9}",
                    "Phase Shift: The same red circles turn white, now providing shelter—|cFF0000STAND INSIDE|r them to avoid big damage. :contentReference[oaicite:10]{index=10}",
                    "Tank: Keep boss faced away to avoid frontal AoE swipes. Everyone else watch for color changes. :contentReference[oaicite:11]{index=11}",
                },
            },

            -- 5) The Shadow Guard
            {
                name = "The Shadow Guard",
                mechanics = {
                    "Starts with multiple adds—tank can gather them for AoE. :contentReference[oaicite:12]{index=12}",
                    "Heavy Attack that must be blocked or it can knock you down (|cFF0000BLOCK|r). :contentReference[oaicite:13]{index=13}",
                    "Places large ground AoEs—poison or shadow; step out quickly, no need to sprint around. :contentReference[oaicite:14]{index=14}",
                },
            },

            -- 6) Bogdan the Nightflame (Endboss)
            {
                name = "Bogdan the Nightflame",
                mechanics = {
                    "Spawns black 'shadows' that mind-control/fear players, and white 'shadows' that heal him—|cFFD700KILL them quickly|r or interrupt the heal. :contentReference[oaicite:15]{index=15}",
                    "Heavy Attack Flame Breath aimed at tank—block or break free if stunned (|cFF0000BLOCK|r). :contentReference[oaicite:16]{index=16}",
                    "Drops 'flame puddles' on players that persist—spread out so the arena doesn’t fill. :contentReference[oaicite:17]{index=17}",
                    "At thresholds (75%, 50%, 25%), he leaps into the air & does massive AoE stomp, clearing all fires/shadows—block to survive (|cFF0000BLOCK|r). :contentReference[oaicite:18]{index=18}",
                    "Hard Mode: Boss & add damage increased, more frequent spawns—same tactics, kill healing shades. :contentReference[oaicite:19]{index=19}",
                },
            },
        },
    },


    ----------------------------------------------------------------------------
    -- 11) Wayrest Sewers I (zoneId=146)
    ----------------------------------------------------------------------------
    [146] = {
        normalId = 6,
        vetId    = 306,
        zoneId   = 146,
        sets     = {165,270,29,194,299},
        questID  = 4246,
        HM       = 1594,
        SR       = 1592,
        ND       = 1593,
        TR       = nil,
        name     = "Wayrest Sewers I",
        bosses = {

            {
                name = "Slimecraw",
                mechanics = {
                    "Basic 'Bite' hits whoever has aggro—keep a solid taunt (|cFFFFFFNO ACTION|r if tanked) :contentReference[oaicite:0]{index=0}",
                    "Tail Swipe (heavy attack cone) that knocks back if unblocked—(|cFF0000BLOCK|r) or |cFF0000DODGE|r out :contentReference[oaicite:1]{index=1}",
                    "Tank: Face Slimecraw away, stand still for consistent AoE from group. :contentReference[oaicite:2]{index=2}",
                },
            },

            {
                name = "Investigator Garron",
                mechanics = {
                    "Channels a green Mist Orb that chases a random player—keep moving in small circles so it doesn't catch you (|cFFA500KITE orb|r) :contentReference[oaicite:3]{index=3}",
                    "Summons Restless Souls (ghosts) at intervals. They cast ranged ice orbs—|cFFD700KILL or INTERRUPT|r them quickly. :contentReference[oaicite:4]{index=4}",
                    "Occasionally fires a strong magic projectile that can knock back (|cFF0000BLOCK|r or |cFF0000DODGE|r if aimed at you). :contentReference[oaicite:5]{index=5}",
                    "Tank: Reposition quickly if boss teleports, chain the ghosts close for AoE. :contentReference[oaicite:6]{index=6}",
                },
            },

            {
                name = "The Rat Whisperer",
                mechanics = {
                    "Periodically summons a swarm of skeevers—burn them down fast (|cFFD700AOE adds|r). :contentReference[oaicite:7]{index=7}",
                    "Channels a 'magic bomb' or 'slam' effect aimed at the tank—both can be |cFF7F00INTERRUPT|r or avoided. :contentReference[oaicite:8]{index=8}",
                    "Sometimes casts swirling frost at target, immobilizing them—also interruptible (|cFF7F00BASH|r). :contentReference[oaicite:9]{index=9}",
                },
            },

            {
                name = "Uulgarg the Hungry",
                mechanics = {
                    "AOE Fear: Shouts and fears everyone—|c00FFFFBREAK FREE|r quickly or risk big follow-up hits. :contentReference[oaicite:10]{index=10}",
                    "Heavy Attack after fear can one-shot if unblocked (|cFF0000BLOCK|r). :contentReference[oaicite:11]{index=11}",
                    "Whirlwind: spins weapon around dealing moderate AoE—step out or block. :contentReference[oaicite:12]{index=12}",
                    "Tank: Keep him centered so the group can reposition easily after fear. :contentReference[oaicite:13]{index=13}",
                },
            },

            {
                name = "Varaine Pellingare",
                mechanics = {
                    "Heavy Attack that must be blocked or knocks you down (|cFF0000BLOCK|r). :contentReference[oaicite:14]{index=14}",
                    "Fast-growing red AoE around boss—get out quickly or be stunned/knocked (|cFF0000MOVE|r). :contentReference[oaicite:15]{index=15}",
                    "Occasionally jumps/spins, firing a narrow cone shock wave at a random player—(|cFF0000DODGE|r or |cFF0000BLOCK|r if quick). :contentReference[oaicite:16]{index=16}",
                },
            },

            {
                name = "Allene Pellingare",
                mechanics = {
                    "Massive Heavy Attack—will one-shot if not blocked (|cFF0000BLOCK|r is mandatory). :contentReference[oaicite:17]{index=17}",
                    "Immediately follows heavy attack with a Spin AoE that also requires block—very high damage (|cFF0000BLOCK|r). :contentReference[oaicite:18]{index=18}",
                    "Ambush/Teleport Strike on a random player—again, block or risk big damage (|cFF0000BLOCK|r). :contentReference[oaicite:19]{index=19}",
                    "Summons waves of Fiendish Hallucination bats (~every 25% HP) with low HP—|cFFD700KILL quickly|r. Allene reappears with a heavy attack lined up. :contentReference[oaicite:20]{index=20}",
                    "Enrage at ~25% after final bat wave, dealing more damage. May stun group (Soul Tether style). Break free fast to avoid spin/ heavy combo. :contentReference[oaicite:21]{index=21}",
                },
            },

        },
    },


    ----------------------------------------------------------------------------
    -- 12) Wayrest Sewers II (zoneId=933)
    ----------------------------------------------------------------------------
    [933] = {
        normalId = 22,
        vetId    = 307,
        zoneId   = 933,
        sets     = {165,270,29,194,299},
        questID  = 4813,
        HM       = 681,
        SR       = 679,
        ND       = 1596,
        TR       = nil,
        name     = "Wayrest Sewers II",
        bosses = {

            {
                name = "Garron the Returned",
                mechanics = {
                    "Frequently places large AoEs on the ground; step aside or block if needed (|cFF0000MOVE|r). :contentReference[oaicite:0]{index=0}",
                    "Summons four ghostly crystals ~every 30s—each spawns a ghost add that can cast high-damage frost orbs (|cFFD700KILL or INTERRUPT|r ghosts quickly). :contentReference[oaicite:1]{index=1}",
                    "Teleports to center and channels a draining beam on all players, dealing massive DoT. Healer must keep group topped—everyone move toward Garron to resume focus. :contentReference[oaicite:2]{index=2}",
                },
            },

            {
                name = "Malubeth the Scourger",
                mechanics = {
                    "Casts red ground AoEs—easy to see, keep out of them (|cFF0000MOVE|r). :contentReference[oaicite:3]{index=3}",
                    "Lifts a random player in mid-air, dealing ticking damage. She becomes intangible—two players must activate the side altars to free ally (|c00FFFFACTIVATE altars|r). :contentReference[oaicite:4]{index=4}",
                    "Tank: Keep her faced away; watch out for stray projectiles or small AoEs. :contentReference[oaicite:5]{index=5}",
                },
            },

            {
                name = "Skull Reaper",
                mechanics = {
                    "Typical Bone Colossus with adds: Summons skeletons from the ground—burn them in AoE before they explode. :contentReference[oaicite:6]{index=6}",
                    "Cone slam frontal AoE—tank faces away from group, block if targeted (|cFF0000BLOCK|r). :contentReference[oaicite:7]{index=7}",
                },
            },

            {
                name = "The Forgotten One",
                mechanics = {
                    "Large Flesh Atronach-like boss with minor adds around. Tank gather adds first (|cFFD700KILL adds|r) :contentReference[oaicite:8]{index=8}",
                    "Emits a wave or outward slash that can one-shot squishy players if not blocked or avoided (|cFF0000BLOCK|r or step aside). :contentReference[oaicite:9]{index=9}",
                    "Keep boss centered so AoE can handle any new add spawns. :contentReference[oaicite:10]{index=10}",
                },
            },

            {
                name = "Uulgarg the Risen",
                mechanics = {
                    "Moves similarly to Uulgarg in Wayrest Sewers I, with a big AoE swirl—step out or block. :contentReference[oaicite:11]{index=11}",
                    "Heavy Attack that can kill if not blocked (|cFF0000BLOCK|r early; animation ends just before impact). :contentReference[oaicite:12]{index=12}",
                    "Fear & Flame Trails: Periodically fears the group, forcing them outward and dropping flames where they break free (|cFF0000BREAK FREE + MOVE|r). :contentReference[oaicite:13]{index=13}",
                },
            },

            {
                name = "Varaine & Allene Pellingare",
                mechanics = {
                    "Two-boss fight—tank must taunt both and stack them together for AoE. :contentReference[oaicite:14]{index=14}",
                    "Allene: Sometimes leaps away or does small AoE slash; block or dodge as needed. :contentReference[oaicite:15]{index=15}",
                    "Varaine: Occasionally heavy attacks or narrow cone—|cFF0000BLOCK|r or sidestep. May place a swirling AoE on himself. :contentReference[oaicite:16]{index=16}",
                    "They vanish to spawn small vampire bat adds—kill them quickly, then bosses reappear. :contentReference[oaicite:17]{index=17}",
                    "Damage Shield: Sometimes one boss gains a shield for ~20s—focus the other boss in that time. :contentReference[oaicite:18]{index=18}",
                    "Hard Mode: Summon & kill 15 zombies during the fight (start pull first, then gather zombies). :contentReference[oaicite:19]{index=19}",
                },
            },

        },
    },


    ----------------------------------------------------------------------------
    -- 13) Arx Corinium (zoneId=148)
    ----------------------------------------------------------------------------
    [148] = {
        normalId = 8,
        vetId    = 305,
        zoneId   = 148,
        sets     = {156,304,303,271},
        questID  = 4202,
        HM       = 1609,
        SR       = 1607,
        ND       = 1608,
        TR       = nil,
        name     = "Arx Corinium",
        bosses = {
            {
                name = "Fanged Menace",
                mechanics = {
                    "Arrives with multiple lamia adds—either control them or kill them quickly with AoE (|cFFD700KILL adds|r) :contentReference[oaicite:0]{index=0}",
                    "Large poison coil on the ground—standing inside heals the boss rapidly and deals a DoT (|cFF0000MOVE out|r) :contentReference[oaicite:1]{index=1}",
                    "Heavy Attack (tail whip) in a frontal cone—tank face away and |cFF0000BLOCK|r or sidestep to avoid knockback :contentReference[oaicite:2]{index=2}",
                },
            },
            {
                name = "Ganakton the Tempest",
                mechanics = {
                    "Lightning-based wamasu boss—tank keep a taunt; no adds :contentReference[oaicite:3]{index=3}",
                    "Wide cone Lightning Breath—avoid or block if targeted (|cFF0000DODGE/BLOCK|r) :contentReference[oaicite:4]{index=4}",
                    "Shock Pulse periodically stuns entire group—unavoidable, so healer maintain health :contentReference[oaicite:5]{index=5}",
                    "Trapping Bolt pins a random player—break free or block to mitigate (|c00FFFFBREAK FREE|r) :contentReference[oaicite:6]{index=6}",
                },
            },
            {
                name = "Sliklenia the Songstress",
                mechanics = {
                    "Comes with a snake pet—do NOT kill the snake; it protects you from her scream :contentReference[oaicite:7]{index=7}",
                    "Heavy Attack: must be blocked or you get knocked back (|cFF0000BLOCK|r) :contentReference[oaicite:8]{index=8}",
                    "Cacophony: She runs to a spot and screams, dealing heavy AoE DoT. Her snake spawns a protective bubble—stack inside it (|cFFD700HIDE in bubble|r) :contentReference[oaicite:9]{index=9}",
                },
            },
            {
                name = "Matron Ixniaa",
                mechanics = {
                    "Accompanied by lamia adds—focus them first so you don’t get overwhelmed (|cFFD700KILL adds|r) :contentReference[oaicite:10]{index=10}",
                    "Double Bolt Circles: spawns two circles under a player—inner circle deals massive damage and stun (|cFF0000MOVE out|r) outer circle smaller DoT :contentReference[oaicite:11]{index=11}",
                    "Standard lamia heavy attack—tank watch for big hits, block if needed :contentReference[oaicite:12]{index=12}",
                },
            },
            {
                name = "Ancient Lurcher",
                mechanics = {
                    "Has lamia adds—control or kill them quickly before focusing boss :contentReference[oaicite:13]{index=13}",
                    "Heavy Attack (shove) must be blocked or you get staggered (|cFF0000BLOCK|r) :contentReference[oaicite:14]{index=14}",
                    "Channels a green beam on random player for high DoT—cannot be interrupted, must be healed :contentReference[oaicite:15]{index=15}",
                    "Below 50%: enrages with lightning-charged AoE. Interrupt ground-pound if possible (|cFF7F00INTERRUPT|r) :contentReference[oaicite:16]{index=16}",
                },
            },
            {
                name = "Sellistrix the Lamia Queen",
                mechanics = {
                    "On land has a strong damage shield; in water she removes shield but electrifies water. Choose method carefully :contentReference[oaicite:17]{index=17}",
                    "Piercing Shriek: devastating frontal scream with knockback—ignore taunt sometimes, watch for it (|cFF0000BLOCK or DODGE|r) :contentReference[oaicite:18]{index=18}",
                    "Casts lightning on random islands with falling debris—group can mitigate on land or stand in electrified water with big healing :contentReference[oaicite:19]{index=19}",
                    "Occasionally charges a random player—simply block or dodge. :contentReference[oaicite:20]{index=20}",
                    "Hard Mode increases HP/damage but no new mechanics (|cFFD700HARDMODE|r). :contentReference[oaicite:21]{index=21}",
                },
            },
        },
    },


    ----------------------------------------------------------------------------
    -- 14) City of Ash I (zoneId=176)
    ----------------------------------------------------------------------------
    [176] = {
        normalId = 10,
        vetId    = 310,
        zoneId   = 176,
        sets     = {160,272,158,159,169},
        questID  = 4778,
        HM       = 1602,
        SR       = 1600,
        ND       = 1601,
        TR       = nil,
        name     = "City of Ash I",
        bosses = {
            {
                name = "Infernal Guardian",
                mechanics = {
                    "Double Slam – Basic physical strikes; tank: block to mitigate damage. (|cFF0000BLOCK|r) :contentReference[oaicite:0]{index=0}",
                    "Thorny Backhand – Heavy swing applying bleed if not blocked. (|cFF0000BLOCK|r recommended) :contentReference[oaicite:1]{index=1}",
                    "Ground Slam – Creates a large circle AoE knocking back players; avoid or |cFF0000BLOCK|r. :contentReference[oaicite:2]{index=2}",
                    "Fiery Explosion – Hurls multiple fireballs across area. Watch your feet; stepping aside is key. :contentReference[oaicite:3]{index=3}",
                    "Tunneling Roots – Strikes distant targets with roots. Dodge or sidestep to avoid a root & DoT. :contentReference[oaicite:4]{index=4}",
                },
            },
            {
                name = "Golor the Banekin Handler",
                mechanics = {
                    "Begins with & summons banekins/scamps in waves—|cFFD700KILL adds quickly|r. :contentReference[oaicite:5]{index=5}",
                    "Crushing Blow – Heavy melee attack. Must be blocked or it knocks you back (|cFF0000BLOCK|r). :contentReference[oaicite:6]{index=6}",
                    "Cleave – 360° spin causing physical damage; step out or block if needed (|cFF0000MOVE|r). :contentReference[oaicite:7]{index=7}",
                },
            },
            {
                name = "Warden of the Shrine",
                mechanics = {
                    "Measured Uppercut – Heavy Attack that knocks target off platform if unblocked (|cFF0000BLOCK|r). :contentReference[oaicite:8]{index=8}",
                    "Blazing Fire – Spawns fiery circles around boss; tank can reposition boss or stand outside them. :contentReference[oaicite:9]{index=9}",
                    "Teleport Strike – Targets distant players; break free/block if you see it coming (|cFF0000DON’T run|r). :contentReference[oaicite:10]{index=10}",
                },
            },
            {
                name = "Dark Ember",
                mechanics = {
                    "Primarily a larger flame atronach. Generic fireball attacks to block/dodge. :contentReference[oaicite:11]{index=11}",
                    "Lava Geyser – Places ground AoE beneath each player. Step aside quickly (|cFF0000MOVE|r). :contentReference[oaicite:12]{index=12}",
                    "Combustion – Explodes on death with a final AoE. Wait before looting or you’ll get one-shot! :contentReference[oaicite:13]{index=13}",
                },
            },
            {
                name = "Rothariel Flameheart",
                mechanics = {
                    "Crushing Blow – Heavy Attack that knocks you back if not blocked (|cFF0000BLOCK|r). :contentReference[oaicite:14]{index=14}",
                    "Berserker Frenzy – 360° spin with moderate damage; step out or block (|cFF0000MOVE|r). :contentReference[oaicite:15]{index=15}",
                    "Burning Field – Drops small flame pools; watch your feet. :contentReference[oaicite:16]{index=16}",
                    "Summon Clones – Splits into 3 clones. Kill them quickly; AoE or splash hits can help burn her faster. :contentReference[oaicite:17]{index=17}",
                },
            },
            {
                name = "Razor Master Erthas",
                mechanics = {
                    "Throws cross-shaped AoE flame lines on the ground—step aside or jump over them. :contentReference[oaicite:18]{index=18}",
                    "Blazing Arrow – A long-duration flame DoT on random player. Extinguish by stepping in water (|cFF0000PURGE in water|r). :contentReference[oaicite:19]{index=19}",
                    "Summons Flame Atronachs – Usually 1 at a time, but 3 at ~25% HP. Burn them quickly or get overwhelmed. :contentReference[oaicite:20]{index=20}",
                    "Teleport – Moves to a new location often; re-engage quickly. Drop ultimates AFTER he teleports. :contentReference[oaicite:21]{index=21}",
                },
            },
        },
    },


    ----------------------------------------------------------------------------
    -- 15) City of Ash II (zoneId=681)
    ----------------------------------------------------------------------------
    [681] = {
        normalId = 322,
        vetId    = 267,
        zoneId   = 681,
        sets     = {160,272,158,159,169},
        questID  = 5120,
        HM       = 1114,
        SR       = 1108,
        ND       = 1107,
        TR       = nil,
        name     = "City of Ash II",
        bosses = {
            {
                name = "Xivilai Rukhan, Akezel & Marruz",
                mechanics = {
                    "Pyrocasm – Rukhan channels a LARGE AoE you cannot interrupt. Step or dodge out FAST to avoid knockdown & big fire damage (|cFF0000MOVE|r) :contentReference[oaicite:0]{index=0}",
                    "Fire Chain – Drags a distant target in, often preceding Pyrocasm. (|cFF0000BLOCK or DODGE|r if threatened) :contentReference[oaicite:1]{index=1}",
                    "Flame Atronachs – Periodically summons atronachs with moderate HP. Kill quickly if group dps is low, or ignore if you can burn the boss. :contentReference[oaicite:2]{index=2}",
                    "Heavy Attack (Uppercut) – Must be blocked or you’ll be flung back. (|cFF0000BLOCK|r) :contentReference[oaicite:3]{index=3}",
                    "Akezel (Healer) – Teleports & casts heals on others, can be interrupted or focus-fired if needed. :contentReference[oaicite:4]{index=4}",
                    "Marruz (Archer) – Fires flame traps & teleports around. Step out of ground-based flame. :contentReference[oaicite:5]{index=5}",
                },
            },
            {
                name = "Urata the Legion",
                mechanics = {
                    "Fire Circles – Multiple small flame ground AoEs spawn under players. Move quickly out of them (|cFF0000MOVE|r). :contentReference[oaicite:6]{index=6}",
                    "Summons 2 Dremora adds: If not killed fast, they can fuse back & heal Urata. (|cFFD700KILL adds|r asap) :contentReference[oaicite:7]{index=7}",
                    "Basic melee hits & mid-range fire attacks: tank should keep her faced away from group. :contentReference[oaicite:8]{index=8}",
                },
            },
            {
                name = "Horvantud the Fire Maw",
                mechanics = {
                    "Fire Breath – Large conal attack in front. DO NOT stand in front unless tanking—block if tank. (|cFF0000BLOCK|r) :contentReference[oaicite:9]{index=9}",
                    "Stomp (Ground Quake) – Slams the ground, summoning red circles. Step out or take big damage. (|cFF0000MOVE|r) :contentReference[oaicite:10]{index=10}",
                    "Waves of Dremora – At health thresholds (75%, 50%, 25%) multiple Dremora spawn. If group dps is not high, kill them or risk overwhelm. :contentReference[oaicite:11]{index=11}",
                    "Basic Deadroth melee/claw hits – Tank faces boss away from group, watch moderate hits. :contentReference[oaicite:12]{index=12}",
                },
            },
            {
                name = "Ash Titan",
                mechanics = {
                    "Heavy Attack – Conal telegraph in front, tank must block or be knocked far back. (|cFF0000BLOCK|r) :contentReference[oaicite:13]{index=13}",
                    "Flame Wall – Boss slams ground, sends arcs of fire outward. Dodge sideways. (|cFF0000MOVE|r) :contentReference[oaicite:14]{index=14}",
                    "Fire Rains – Rains meteors or circular AoEs onto each player. Step aside—cannot outrun entirely but move frequently. :contentReference[oaicite:15]{index=15}",
                    "Air Atronach Summons – At ~65% & ~35% boss health, conjures an air atronach (2 total). Tank must kite them & keep the boss taunted as well. :contentReference[oaicite:16]{index=16}",
                    "Slam + Fire Wave – periodically knocks players away, then channel waves of fire or lava. Ranged recommended for dps/healer. :contentReference[oaicite:17]{index=17}",
                },
            },
            {
                name = "Xivilai Boltaic & Xivilai Fulminator",
                mechanics = {
                    "Lightning Onslaught – Frontal channel dealing heavy shock damage. Can be interrupted or sidestepped (|cFF7F00INTERRUPT|r). :contentReference[oaicite:18]{index=18}",
                    "Shock Aura – Boss crouches, then bursts with shock AoE. Move out or interrupt. :contentReference[oaicite:19]{index=19}",
                    "Heavy Attack – Must be blocked or you’ll take huge damage. (|cFF0000BLOCK|r) :contentReference[oaicite:20]{index=20}",
                    "Storm Atronachs – Summons up to 4 at once. They can overwhelm if not killed quickly. :contentReference[oaicite:21]{index=21}",
                },
            },
            {
                name = "Valkyn Skoria",
                mechanics = {
                    "5 Platforms (3 on HM) – Each platform eventually breaks. Avoid the lava. Must dps quickly or run out of platforms. :contentReference[oaicite:22]{index=22}",
                    "Heavy Attack – Must be blocked or you’ll be knocked into lava. (|cFF0000BLOCK|r) :contentReference[oaicite:23]{index=23}",
                    "Fireball – Targets a random player. Dodge roll or block to avoid knockback. (|cFF0000DODGE|r or |cFF0000BLOCK|r) :contentReference[oaicite:24]{index=24}",
                    "Fossilize – Randomly turns a player to stone. Break free fast or dodge if you see it being cast. :contentReference[oaicite:25]{index=25}",
                    "Flame Wheel – Repeated circular flame lines radiating outward. Step between them. (|cFF0000MOVE carefully|r) :contentReference[oaicite:26]{index=26}",
                    "Smash Platform – He stabs the ground, destroying that platform. Move to the next one. :contentReference[oaicite:27]{index=27}",
                    "Atronachs & Damage Shield – Each platform shift spawns flame atronachs & a shielded Skoria. Burn the shield, kill atronachs, then dps him again. :contentReference[oaicite:28]{index=28}",
                    "Hard Mode: Only 3 platforms. Minimal mistakes allowed—time your damage & moves well. :contentReference[oaicite:29]{index=29}",
                },
            },
        },
    },


    ----------------------------------------------------------------------------
    -- 16) Crypt of Hearts I (zoneId=130)
    ----------------------------------------------------------------------------
    [130] = {
        normalId = 9,
        vetId    = 261,
        zoneId   = 130,
        sets     = {273,122,134,302,168},
        questID  = 4379,
        HM       = 1615,
        SR       = 1613,
        ND       = 1614,
        TR       = nil,
        name     = "Crypt of Hearts I",
        bosses = {
            {
                name = "The Mage Master",
                mechanics = {
                    "Arrives with four skeleton mage adds—kill or interrupt them quickly (|cFFD700KILL adds|r) :contentReference[oaicite:0]{index=0}",
                    "Swings with a heavy melee blow—must be blocked or you’ll be knocked back (|cFF0000BLOCK|r) :contentReference[oaicite:1]{index=1}",
                    "Casts a donut-shaped AoE on ground—center and outer ring are safe, edges do damage (|cFF0000MOVE|r) :contentReference[oaicite:2]{index=2}",
                    "Drops a 'Negate-like' bubble that disrupts Magicka usage—step out or rely on Stamina & |cFF0000BLOCK|r :contentReference[oaicite:3]{index=3}",
                },
            },
            {
                name = "Archmaster Siniel",
                mechanics = {
                    "Periodically fears all players for ~2s (|c00FFFFBREAK FREE|r) :contentReference[oaicite:4]{index=4}",
                    "Summons waves of undead skeletons (very low HP)—kill with AoE (|cFFD700KILL adds|r) :contentReference[oaicite:5]{index=5}",
                    "Channels a dark circle AoE on the ground—do NOT stand in it (|cFF0000MOVE|r) :contentReference[oaicite:6]{index=6}",
                    "Near low health, may apply a damage shield—burn through it quickly :contentReference[oaicite:7]{index=7}",
                },
            },
            {
                name = "Death’s Leviathan",
                mechanics = {
                    "Starts fight unlit, gains a flame buff mid-fight (~50% HP). Fire form greatly increases damage (|cFF0000INCREASED caution|r). :contentReference[oaicite:8]{index=8}",
                    "Expanding red circle from center—get out instantly or it can kill (|cFF0000MOVE|r). Lethal if you’re close in phase two. :contentReference[oaicite:9]{index=9}",
                    "Charges in a straight line—easy to sidestep. In flame phase it leaves a trailing fire. :contentReference[oaicite:10]{index=10}",
                    "Tank: Keep boss from running wild—position near walls if possible to control charges. :contentReference[oaicite:11]{index=11}",
                },
            },
            {
                name = "Uulkar Bonehand",
                mechanics = {
                    "Summons red circles or runes that erupt as spikes, briefly stunning players (|cFF0000MOVE|r or |c00FFFFBREAK FREE|r). :contentReference[oaicite:12]{index=12}",
                    "Heavy Attack overhead swing—absolute must-block or expect a one-shot (|cFF0000BLOCK|r) :contentReference[oaicite:13]{index=13}",
                    "Swings in small AoEs—tank hold him still, dps avoid swirling telegraphs. :contentReference[oaicite:14]{index=14}",
                },
            },
            {
                name = "Dogas the Berserker",
                mechanics = {
                    "Begins the fight with multiple skeleton adds—control or kill them first. :contentReference[oaicite:15]{index=15}",
                    "Casts a large AoE stun draining HP (similar to Soul Tether)—|c00FFFFBREAK FREE|r or use Immovable :contentReference[oaicite:16]{index=16}",
                    "Performs a heavy melee or overhead smash—block if targeted (|cFF0000BLOCK|r). :contentReference[oaicite:17]{index=17}",
                    "Spreads out to avoid group-wide stun or focus him quickly—He can life-steal multiple players. :contentReference[oaicite:18]{index=18}",
                },
            },
            {
                name = "Ilambris-Athor & Ilambris-Zaven",
                mechanics = {
                    "Twin bosses: Zaven (fire mage) usually remains center; Athor (lightning) roams. :contentReference[oaicite:19]{index=19}",
                    "Zaven: Channels large flame arcs & spawns a big expanding AoE—run out or get knocked down (|cFF0000MOVE|r). :contentReference[oaicite:20]{index=20}",
                    "Athor: Wields big melee hits—block heavy overhead or you’ll be launched (|cFF0000BLOCK|r). He places lightning runes on ground—avoid. :contentReference[oaicite:21]{index=21}",
                    "Kill order often Fire first -> Lightning enrages with a lightning rain. Or balance their HP for simultaneous kill to reduce enrage time. :contentReference[oaicite:22]{index=22}",
                    "When one dies, the other gains an enhanced AoE and damage. Keep calm, keep blocking or avoiding big hits, finish quickly. :contentReference[oaicite:23]{index=23}",
                },
            },
        },
    },


    ----------------------------------------------------------------------------
    -- 17) Crypt of Hearts II (zoneId=932)
    ----------------------------------------------------------------------------
    [932] = {
        normalId = 317,
        vetId    = 318,
        zoneId   = 932,
        sets     = {273,122,134,302,168},
        questID  = 5113,
        HM       = 1084,
        SR       = 941,
        ND       = 942,
        TR       = nil,
        name     = "Crypt of Hearts II",
        bosses = {
            {
                name = "Ibelgast",
                mechanics = {
                    "Arrives with multiple necromancer/healer adds—focus them (|cFFD700KILL adds|r) or interrupt to prevent long fight :contentReference[oaicite:0]{index=0}",
                    "Randomly places a large red AoE circle under a player—step out quickly (|cFF0000MOVE|r) :contentReference[oaicite:1]{index=1}",
                    "Heavy Attack overhead slash—must be blocked or expect a knockback (|cFF0000BLOCK|r) :contentReference[oaicite:2]{index=2}",
                    "At low health, summons a Flesh Atronach with moderate HP—tank hold aggro, kill it fast (|cFFD700KILL add|r) :contentReference[oaicite:3]{index=3}",
                },
            },
            {
                name = "Ruzozuzalpamaz",
                mechanics = {
                    "Casts lightning on tank—low DoT, but tank keep taunt. :contentReference[oaicite:4]{index=4}",
                    "Summons spider swarms throughout fight—do not panic or run. Tank gather them, use AoE. :contentReference[oaicite:5]{index=5}",
                    "Channels a chasing AoE targeting one player—kite in wide circle away from group (|cFF0000MOVE out|r). :contentReference[oaicite:6]{index=6}",
                    "Cocoons a random player in a web—others must use synergy on them to free (|cFFD700RELEASE ally|r). :contentReference[oaicite:7]{index=7}",
                    "Heavy Attack overhead swing—block to avoid knockback (|cFF0000BLOCK|r). :contentReference[oaicite:8]{index=8}",
                },
            },
            {
                name = "Chamber Guardian",
                mechanics = {
                    "Heavy Attack overhead blow—block or suffer huge damage (|cFF0000BLOCK|r). :contentReference[oaicite:9]{index=9}",
                    "Periodically fears all players—immediately |c00FFFFBREAK FREE|r to stop running away. :contentReference[oaicite:10]{index=10}",
                    "Summons skeleton adds over time—kill quickly with AoE or they overwhelm you (|cFFD700KILL adds|r). :contentReference[oaicite:11]{index=11}",
                    "Tank: Keep boss mid-room, break fear quickly to prevent boss from wandering out of group AoE. :contentReference[oaicite:12]{index=12}",
                },
            },
            {
                name = "Ilambris Amalgam",
                mechanics = {
                    "Fight starts with 2 smaller Ilambris(blue & red). Killing one spawns the actual Bone Colossus boss from the pile. :contentReference[oaicite:13]{index=13}",
                    "Summons skeleton adds in waves—tank group them, kill with AoE (|cFFD700CLEAR adds|r). :contentReference[oaicite:14]{index=14}",
                    "Stomps ground with a wide AoE—step out or block. (|cFF0000BLOCK or MOVE|r). :contentReference[oaicite:15]{index=15}",
                    "At low HP, enrages with constant fire rains—keep mobile, watch feet and finish boss quickly. :contentReference[oaicite:16]{index=16}",
                },
            },
            {
                name = "Mezeluth",
                mechanics = {
                    "Rooted in place—she does NOT move. Group must approach her on the platform. :contentReference[oaicite:17]{index=17}",
                    "Channels a fiery ground AoE—interrupt her to reduce hazards (|cFF7F00INTERRUPT|r). :contentReference[oaicite:18]{index=18}",
                    "Periodically sucks players in and places overlapping red circles at each player’s feet—|cFFD700SPREAD out|r so they don’t stack and wipe group. :contentReference[oaicite:19]{index=19}",
                    "Dodge roll or move back to your 'quarter' to avoid overlapping AoEs. Everyone must find a unique safe spot. :contentReference[oaicite:20]{index=20}",
                },
            },
            {
                name = "Nerien’eth",
                mechanics = {
                    "Flies/Skulls: random player targeted with a large skull projectile—|cFF0000DODGE or BLOCK|r or risk huge damage/knockdown. :contentReference[oaicite:21]{index=21}",
                    "Teleports on a random player—releases a huge ring AoE. If targeted, get distance or block (|cFF0000MOVE or BLOCK|r). :contentReference[oaicite:22]{index=22}",
                    "Summons ghosts at 3 wells—killing them lowers difficulty; ignoring them triggers Hard Mode if 4 remain by 35% HP. :contentReference[oaicite:23]{index=23}",
                    "35% Phase: Grabs sword, group is stunned. Drains a random player—others must destroy shield quickly to free them (|cFFD700DPS shield|r). :contentReference[oaicite:24]{index=24}",
                    "Post-sword, boss does heavier melee with random charges—block or step aside. :contentReference[oaicite:25]{index=25}",
                },
            },
        },
    },


    ----------------------------------------------------------------------------
    -- 18) Direfrost Keep (zoneId=449)
    ----------------------------------------------------------------------------
    [449] = {
        normalId = 11,
        vetId    = 319,
        zoneId   = 449,
        sets     = {274,307,53,103},
        questID  = 4346,
        HM       = 1628,
        SR       = 1626,
        ND       = 1627,
        TR       = nil,
        name     = "Direfrost Keep",
        bosses = {
            {
                name = "Teethnasher the Frostbound",
                mechanics = {
                    "Charge – Boss charges the tank, dealing moderate damage. (|cFF0000BLOCK|r). :contentReference[oaicite:0]{index=0}",
                    "Ice Wind – Ongoing frost AoE around boss, applying snare and DoT. Healer can out-heal or step out briefly. :contentReference[oaicite:1]{index=1}",
                    "Light Attacks – Frequent light hits on whoever has aggro. Do not run around; block if needed. :contentReference[oaicite:2]{index=2}",
                    "Stand Ground – Keeping boss still is best. Excess movement complicates healing/AoE. :contentReference[oaicite:3]{index=3}",
                },
            },
            {
                name = "Guardian of the Flame",
                mechanics = {
                    "Heavy Attack – Must be blocked or you’ll be knocked down (|cFF0000BLOCK|r). :contentReference[oaicite:4]{index=4}",
                    "Charge – Targets distant players. Stay in position, block if charged. :contentReference[oaicite:5]{index=5}",
                    "Breath – Frontal cone flame aimed at tank (|cFF0000BLOCK|r). Others avoid standing in front. :contentReference[oaicite:6]{index=6}",
                    "Lightning Splash – Random AoE under a player. Move out quickly, then return to avoid triggering more charges. :contentReference[oaicite:7]{index=7}",
                    "Minimize Movement – Reduces random charge occurrences and chaos. :contentReference[oaicite:8]{index=8}",
                },
            },
            {
                name = "Drodda’s Dreadlord",
                mechanics = {
                    "Heavy Attack – Overhead strike; block or get knocked down (|cFF0000BLOCK|r). :contentReference[oaicite:9]{index=9}",
                    "Cleave Spin – Small AoE spin around boss. Tank can soak; others step out. :contentReference[oaicite:10]{index=10}",
                    "Exploding Banekins – Periodically spawns banekins that detonate near players. (|cFFD700KILL adds|r). :contentReference[oaicite:11]{index=11}",
                    "Post-fight Switch – Activate room mechanism to lower drawbridge. :contentReference[oaicite:12]{index=12}",
                },
            },
            {
                name = "Drodda’s Apprentice",
                mechanics = {
                    "Initial Adds – Tank gather them on boss for AoE. :contentReference[oaicite:13]{index=13}",
                    "Heavy Attack – Must be blocked (|cFF0000BLOCK|r) or risk knockdown. :contentReference[oaicite:14]{index=14}",
                    "Ice Blast – Expanding AoE from under boss. (|cFF0000MOVE|r) or suffer heavy damage/knockdown. :contentReference[oaicite:15]{index=15}",
                    "Drain (Beam) – Lifts a random player, healing boss. (|c00FFFFBREAK FREE|r) fast. :contentReference[oaicite:16]{index=16}",
                    "Interruptable Blast – Boss channels a cast that can be interrupted (|cFF7F00INTERRUPT|r). :contentReference[oaicite:17]{index=17}",
                },
            },
            {
                name = "Iceheart",
                mechanics = {
                    "Cone Attack – Frost cone aimed at tank; (|cFF0000BLOCK|r) or sidestep. Others stay behind boss. :contentReference[oaicite:18]{index=18}",
                    "Ice Blast – Large AoE expanding from boss center. Move out or get knocked down. :contentReference[oaicite:19]{index=19}",
                    "Slam – Red circles under each player; spawns Draugr adds. Tank gather them, avoid running. :contentReference[oaicite:20]{index=20}",
                    "Positioning – Tank face boss away, group behind. Keep calm unless forced to move. :contentReference[oaicite:21]{index=21}",
                },
            },
            {
                name = "Ancient Lurcher",
                mechanics = {
                    "Poison Beam – Randomly targets a player with heavy DoT. Healer or block/dodge. :contentReference[oaicite:22]{index=22}",
                    "Red Circles – Step out quickly. Overlapping circles deal high damage. :contentReference[oaicite:23]{index=23}",
                    "Enrage (~50%) – Gains lightning buff, intensifying damage. Burn fast. :contentReference[oaicite:24]{index=24}",
                    "Additional Adds – Kill or control them first if possible. :contentReference[oaicite:25]{index=25}",
                },
            },
            {
                name = "Drodda of Icereach",
                mechanics = {
                    "Untauntable – She chooses targets for frost bolts. Everyone must be ready to block/heal. :contentReference[oaicite:26]{index=26}",
                    "Teleport + Ice Blast – On teleport, a large AoE forms under her. (|cFF0000MOVE|r) or get one-shot. :contentReference[oaicite:27]{index=27}",
                    "Ice Wraiths (~50%) – Two wraiths spawn, can knock down. Tank can gather, group AoE. :contentReference[oaicite:28]{index=28}",
                    "Ice Atronachs (~25%) – Two spawn with frontal attacks. Stack them for AoE. :contentReference[oaicite:29]{index=29}",
                    "Drain (Beam) – Random player is lifted, healing Drodda rapidly. (|c00FFFFBREAK FREE|r) to prevent a wipe. :contentReference[oaicite:30]{index=30}",
                    "Keep Formation – Avoid stacking so you can see who is targeted. Don’t panic-run. :contentReference[oaicite:31]{index=31}",
                },
            },
        },
    },


    ----------------------------------------------------------------------------
    -- 19) Tempest Island (zoneId=131)
    ----------------------------------------------------------------------------
    [131] = {
        normalId = 13,
        vetId    = 311,
        zoneId   = 131,
        sets     = {188,193,186,275},
        questID  = 4538,
        HM       = 1622,
        SR       = 1620,
        ND       = 1621,
        TR       = nil,    
        name     = "Tempest Island",
        bosses = {

            {
                name = "Sonolia the Matriarch",
                mechanics = {
                    "Add Wave – Accompanied by lamias/Sea Vipers. Either kill them first or stack on boss (|cFFD700KILL adds|r). :contentReference[oaicite:0]{index=0}",
                    "Heavy Attack – Must be blocked or you’ll be knocked down (|cFF0000BLOCK|r). :contentReference[oaicite:1]{index=1}",
                    "Scream (Resonate) – Cone AoE that disorients target. (|cFF0000BLOCK|r or step aside). If disoriented, |c00FFFFBREAK FREE|r. :contentReference[oaicite:2]{index=2}",
                    "Positioning – Tank faces her away, group stands behind to avoid the scream. :contentReference[oaicite:3]{index=3}",
                },
            },

            {
                name = "Valaran Stormcaller",
                mechanics = {
                    "Lightning Storm – Large AoE in the area; move aside to avoid prolonged damage (|cFF0000MOVE|r). :contentReference[oaicite:4]{index=4}",
                    "Chain Lightning – Light shock to the group; also buffs the boss’s resist. Minor threat if healed through. :contentReference[oaicite:5]{index=5}",
                    "Crushing Blow (Heavy Attack) – Must be blocked or you’ll be knocked down (|cFF0000BLOCK|r). :contentReference[oaicite:6]{index=6}",
                    "Lightning Avatar – Summons a low-HP reflection. Tank taunt it; AoE handles it quickly. :contentReference[oaicite:7]{index=7}",
                    "Random Stun – Boss may stun a player (|c00FFFFBREAK FREE|r). Don’t let your health drop too low. :contentReference[oaicite:8]{index=8}",
                    "Lightning Field – Wide wave-like AoE sweeps the room. Step aside and let it pass before returning. :contentReference[oaicite:9]{index=9}",
                },
            },

            {
                name = "Yalorasse the Speaker",
                mechanics = {
                    "Multiple Adds – Archer/healer enemies join her. (|cFFD700KILL adds|r first) or stack them on the boss. :contentReference[oaicite:10]{index=10}",
                    "Heavy Attack – Must be blocked or you’ll be knocked back (|cFF0000BLOCK|r). :contentReference[oaicite:11]{index=11}",
                    "Whirlwind – Small melee spin AoE. Tank can soak; DPS/healer back away or block. :contentReference[oaicite:12]{index=12}",
                    "Lightning Splash – Periodically casts a small ground AoE, move out quickly. :contentReference[oaicite:13]{index=13}",
                },
            },

            {
                name = "Stormfist",
                mechanics = {
                    "Ground Fist – A large fist emerges, stunning/knocking up anyone caught. Avoid or |c00FFFFBREAK FREE|r. :contentReference[oaicite:14]{index=14}",
                    "Minions – Summons smaller copies. Tank must grab them; they die fast to AoE. :contentReference[oaicite:15]{index=15}",
                    "Stomp – Rapidly expanding red circle; if inside, you get launched into the air with heavy damage (|cFF0000MOVE|r). :contentReference[oaicite:16]{index=16}",
                    "Enrage (~25%) – Boss channels continuous lightning pulses. Healer keep group alive, burn boss fast. :contentReference[oaicite:17]{index=17}",
                    "Positioning – Fight him in center, minimal running. Too much movement causes chaos. :contentReference[oaicite:18]{index=18}",
                },
            },

            {
                name = "Commodore Ohmanil",
                mechanics = {
                    "Many Adds – Can overwhelm if left alive. (|cFFD700KILL adds|r) or stack them on boss for AoE. :contentReference[oaicite:19]{index=19}",
                    "Heavy Attack – Must be blocked or you’ll be knocked down (|cFF0000BLOCK|r). :contentReference[oaicite:20]{index=20}",
                    "Levitate – Random player is suspended in a purple orb. Allies can interrupt boss or victim (|c00FFFFBREAK FREE|r). :contentReference[oaicite:21]{index=21}",
                },
            },

            {
                name = "Stormreeve Neidir",
                mechanics = {
                    "Sparking Strike – Large expanding AoE from under boss. (|cFF0000MOVE out|r) or be one-shot. :contentReference[oaicite:22]{index=22}",
                    "Charge – Targets anyone too far away, often lethal. Stay close to avoid it. :contentReference[oaicite:23]{index=23}",
                    "Mini Tornadoes – Drift around the arena, causing stagger on contact. Avoid or risk being knocked into AoE. :contentReference[oaicite:24]{index=24}",
                    "Lightning Strike – She raises her hand, zapping a random player for heavy damage (|cFF0000BLOCK|r recommended). :contentReference[oaicite:25]{index=25}",
                    "Light Attacks – Ignores taunt randomly, firing multiple hits at someone. Healer watch for sudden HP drops. :contentReference[oaicite:26]{index=26}",
                    "Hard Mode – Increased HP/damage, faster tornadoes. Same mechanics, more punishing if not handled well. :contentReference[oaicite:27]{index=27}",
                },
            },

        },
    },


    ----------------------------------------------------------------------------
    -- 20) Volenfell (zoneId=22)
    ----------------------------------------------------------------------------
    [22] = {
        normalId = 12,
        vetId    = 304,
        zoneId   = 22,
        sets     = {276,77,102,305},
        questID  = 4432,
        HM       = 1634,
        SR       = 1632,
        ND       = 1633,
        TR       = nil,
        name     = "Volenfell",
        bosses = {

            {
                name = "Desert Lion",
                mechanics = {
                    "Lioness Adds – Four lioness adds spawn; tank stack them together for AoE (|cFFD700KILL adds|r). :contentReference[oaicite:0]{index=0}",
                    "Heavy Attack – Must be blocked or you’ll be knocked down (|cFF0000BLOCK|r). :contentReference[oaicite:1]{index=1}",
                    "Roar – Fears the group; |c00FFFFBREAK FREE|r quickly or risk a follow-up pounce. :contentReference[oaicite:2]{index=2}",
                },
            },

            {
                name = "Quintus Verres",
                mechanics = {
                    "Phase 1 (Warrior) – Uses a 2H weapon with heavy overhead strikes; block or be knocked down (|cFF0000BLOCK|r). Occasionally performs a whirlwind AoE—step out. :contentReference[oaicite:3]{index=3}",
                    "Phase 2 (Mage) – Switches to flame staff, drops fire circles. Avoid standing in them. Watch for random flame bolts. :contentReference[oaicite:4]{index=4}",
                    "Phase 3 (Gargoyle) – Summons a Monstrous Gargoyle with frontal cone & heavy smash. If you’re turned to stone, |c00FFFFBREAK FREE|r. Move out of big slam AoE. :contentReference[oaicite:5]{index=5}",
                },
            },

            {
                name = "Boilbite",
                mechanics = {
                    "Adds – Several weak adds accompany the boss; (|cFFD700KILL adds|r) first to simplify fight. :contentReference[oaicite:6]{index=6}",
                    "Fire Blast – A large spreading AoE dealing heavy damage each tick. Tank can soak, DPS/healers must exit quickly. :contentReference[oaicite:7]{index=7}",
                    "Teleport – Boss may teleport and follow up with next attack. Be ready to block or move. :contentReference[oaicite:8]{index=8}",
                },
            },

            {
                name = "Tremorscale",
                mechanics = {
                    "Tail Whip – Boss roars, then whips tail in a cone. (|cFF0000BLOCK|r or sidestep). :contentReference[oaicite:9]{index=9}",
                    "Burrow – Disappears underground and erupts under a random player. (|cFF0000MOVE|r) to avoid knockup. :contentReference[oaicite:10]{index=10}",
                    "Maintain Positions – Tank front, DPS/healer behind. Too much running causes confusion. :contentReference[oaicite:11]{index=11}",
                },
            },

            {
                name = "Unstable Construct",
                mechanics = {
                    "Lightning Shot – A small circular telegraph. (|cFF0000MOVE|r or block) to avoid damage. :contentReference[oaicite:12]{index=12}",
                    "Spin – Spins in place, dealing AoE physical damage. Stay 3–5m away or block. :contentReference[oaicite:13]{index=13}",
                    "Slam – Boss curls into a ball, jumps, and slams. Small AoE under feet—dodge or step out. :contentReference[oaicite:14]{index=14}",
                    "Bomb – Large AoE under a random player. Step away from allies to avoid group damage. :contentReference[oaicite:15]{index=15}",
                },
            },

            {
                name = "Guardian Council",
                mechanics = {
                    "Three Guardians (Strength, Spark, Soul) – All share HP. Damaging any also affects others. :contentReference[oaicite:16]{index=16}",
                    "Strength (Red) – Un-tauntable spin chases a player for high physical damage. Kite away; do not drag through group. :contentReference[oaicite:17]{index=17}",
                    "Spark (Blue) – Stays mostly in place, rains lightning orbs from above. Avoid or move slightly each time. :contentReference[oaicite:18]{index=18}",
                    "Soul (Yellow) – Cone heavy attack (Decapitate). Block or dodge. Sometimes splits damage or 'heals' by redistributing damage among guardians. :contentReference[oaicite:19]{index=19}",
                    "Coordinate – Some teams kill Soul first to limit healing. Others stack them for balanced DPS. Just watch AoEs and don’t run wild. :contentReference[oaicite:20]{index=20}",
                },
            },

        },
    },


    ----------------------------------------------------------------------------
    -- 21) Blackheart Haven (zoneId=38)
    ----------------------------------------------------------------------------
    [38] = {
        normalId = 15,
        vetId    = 321,
        zoneId   = 38,
        sets     = {308,277,157,309},
        questID  = 4589,
        HM       = 1652,
        SR       = 1650,
        ND       = 1651,
        TR       = nil,
        name     = "Blackheart Haven",
        bosses = {

            {
                name = "Iron-Heel",
                mechanics = {
                    "Heavy Attack – Must be blocked or you'll be knocked down (|cFF0000BLOCK|r). :contentReference[oaicite:0]{index=0}",
                    "Whirlwind – Spins weapon in a small AoE. DPS/healer step out briefly. :contentReference[oaicite:1]{index=1}",
                    "Spin Kick – Launches a random player backward. Keep your back to a wall or risk being kicked off the platform. :contentReference[oaicite:2]{index=2}",
                    "Adds – Gather outside adds into the room for AoE. Avoid fighting near edges. :contentReference[oaicite:3]{index=3}",
                },
            },

            {
                name = "Atarus",
                mechanics = {
                    "Acid Puke – Cone AoE in front. Tank block or sidestep; others avoid the cone. :contentReference[oaicite:4]{index=4}",
                    "Charge – Boss charges in a long straight line; red strip telegraph. (|cFF0000MOVE|r). :contentReference[oaicite:5]{index=5}",
                    "Stomp – Circular AoE knockdown. Step out, then re-engage. :contentReference[oaicite:6]{index=6}",
                    "Enrage (~30%) – Grows bigger, restoring health to ~50%. Same mechanics, more damage. :contentReference[oaicite:7]{index=7}",
                },
            },

            {
                name = "First Mate Wavecutter",
                mechanics = {
                    "Harpies (Adds) – Ranged attackers. Tank can chain them in. AoE them down. :contentReference[oaicite:8]{index=8}",
                    "Heavy Attack – Must be blocked or you'll be knocked down (|cFF0000BLOCK|r). :contentReference[oaicite:9]{index=9}",
                    "Whirlwind – Small steel tornado AoE. Step back briefly, then return. :contentReference[oaicite:10]{index=10}",
                    "Shadow Volley – Fast channeled projectile hitting all players hard. (|cFF7F00INTERRUPT|r) or risk wipes. :contentReference[oaicite:11]{index=11}",
                },
            },

            {
                name = "Roost Mother",
                mechanics = {
                    "Fire Tornado – A heavy-hitting vortex aimed at the tank. DPS/healer avoid the boss's frontal area. :contentReference[oaicite:12]{index=12}",
                    "Random Teleport – She moves constantly. Re-form around her each time. :contentReference[oaicite:13]{index=13}",
                    "Flame Breath – Large frontal cone. (|cFF0000BLOCK|r or dodge if tanked). Others stay behind boss. :contentReference[oaicite:14]{index=14}",
                    "Raining Fire – She screams, then fireballs land where players stood. Hold position until they fall, then step away. :contentReference[oaicite:15]{index=15}",
                },
            },

            {
                name = "Hollow Heart",
                mechanics = {
                    "Ice Projectiles – Fired at tank, leaving DoT patches. Stand behind boss to avoid. :contentReference[oaicite:16]{index=16}",
                    "Minimal Threat – Very low HP. Stay out of her frontal line, quickly burn her down. :contentReference[oaicite:17]{index=17}",
                },
            },

            {
                name = "Captain Blackheart",
                mechanics = {
                    "Skeleton Adds – Spawn frequently, including archers. Tank chain them in for AoE. :contentReference[oaicite:18]{index=18}",
                    "Spin – 360° slash dealing moderate physical damage. Step out or block. :contentReference[oaicite:19]{index=19}",
                    "Skeleton Curse – Random player is slammed down and turned into a skeleton for ~30s, losing normal abilities. Use light/heavy attacks. :contentReference[oaicite:20]{index=20}",
                    "Tank as Skeleton – If tank is cursed, there's no taunt. Group must block or focus boss until tank returns. :contentReference[oaicite:21]{index=21}",
                },
            },

        },
    },


    ----------------------------------------------------------------------------
    -- 22) Blessed Crucible (zoneId=64)
    ----------------------------------------------------------------------------
    [64] = {
        normalId = 14,
        vetId    = 320,
        zoneId   = 64,
        sets     = {72,310,46,278},
        questID  = 4469,
        HM       = 1646,
        SR       = 1644,
        ND       = 1645,
        TR       = nil,
        name     = "Blessed Crucible",
        bosses = {

            {
                name = "Grunt the Clever",
                mechanics = {
                    "AOE Fear – Periodically roars, fearing everyone. (|c00FFFFBREAK FREE|r) quickly. :contentReference[oaicite:0]{index=0}",
                    "Massive Frontal Slam – Large cone attack that can fling you off the platform. Step or roll-dodge aside. :contentReference[oaicite:1]{index=1}",
                    "Positioning – Tank keeps boss faced away; group stands behind to avoid heavy hits. :contentReference[oaicite:2]{index=2}",
                },
            },

            {
                name = "The Pack",
                mechanics = {
                    "Waves – Fight multiple waves of weaker enemies first. Stay central, tank chain in ranged adds. :contentReference[oaicite:3]{index=3}",
                    "Four Bosses – Snagg (2H orc with whirlwind), Nusana (fire mage line attack), Dynus (fire/ice caster), Kayd (rogue). :contentReference[oaicite:4]{index=4}",
                    "Werewolf Transform (~30%) – Each boss shifts into werewolf form, gaining pounce/heavy/flurry. :contentReference[oaicite:5]{index=5}",
                    "Focus Healer/Rogue – Killing Dynus (healer) & Kayd (rogue) first often helps. Tank try to hold all together. :contentReference[oaicite:6]{index=6}",
                },
            },

            {
                name = "Teranya the Faceless",
                mechanics = {
                    "Initial Durzogs – Two enraged durzogs spawn with her. Tank taunt them so group can AoE all together. :contentReference[oaicite:7]{index=7}",
                    "Heavy Attack – Must be blocked (|cFF0000BLOCK|r) or you’re knocked down. :contentReference[oaicite:8]{index=8}",
                    "Whirlwind – Small spin AoE. Step back quickly, then re-engage. :contentReference[oaicite:9]{index=9}",
                    "Exploding Banekins – Run at players and detonate. AoE can kill squishies if unchecked. Avoid or block if they reach you. :contentReference[oaicite:10]{index=10}",
                },
            },

            {
                name = "The Beast Master",
                mechanics = {
                    "Wave 1 (Incineration Beetles) – Four flaming beetles with pulsing fire AoE & ground flames. Kill quickly with AoE; do not stand in fire. :contentReference[oaicite:11]{index=11}",
                    "Wave 2 (Stinger) – Giant scorpion that drops poison under a player. (|cFF0000MOVE|r) out of the green poison circle. :contentReference[oaicite:12]{index=12}",
                    "Wave 3 (Troll King) – Large troll. Stay close or he leaps. Watch for ground slam AoE. Block or sidestep if he telegraphs a heavy. :contentReference[oaicite:13]{index=13}",
                    "General – Tank face each wave away; group doesn’t run around. Focus each threat with controlled movement. :contentReference[oaicite:14]{index=14}",
                },
            },

            {
                name = "Captain Thoran",
                mechanics = {
                    "Fire Runes – Thrown onto ground, dealing high damage if stepped on. :contentReference[oaicite:15]{index=15}",
                    "Purple Clouds – Random spots around the arena with heavy DoT. Avoid them. :contentReference[oaicite:16]{index=16}",
                    "Lava Atronach (low HP) – Summoned at ~25%. Gives Thoran a damage shield. Kill the atronach to remove shield (it explodes). :contentReference[oaicite:17]{index=17}",
                    "Adds – Various mobs in the area. Clear them or stack them on boss for AoE. :contentReference[oaicite:18]{index=18}",
                },
            },

            {
                name = "The Lava Queen",
                mechanics = {
                    "Lava Atronachs – She becomes invulnerable while they beam her. Kill them first to break shield. :contentReference[oaicite:19]{index=19}",
                    "Heavy Attack – A delayed swing dealing massive knockback. (|cFF0000BLOCK|r immediately upon wind-up). :contentReference[oaicite:20]{index=20}",
                    "Eruptions – Random small red circles that deal severe damage. Watch your feet. :contentReference[oaicite:21]{index=21}",
                    "Wheel of Fire – She stabs her sword down, sending lines of flame outward like spokes. Quickly back away, sidestep the lines, then return. :contentReference[oaicite:22]{index=22}",
                    "Ranged Flame Shots – Often targets distant players. Keep a shield or block if you see it cast. :contentReference[oaicite:23]{index=23}",
                },
            },

        },
    },


    ----------------------------------------------------------------------------
    -- 23) Selene’s Web (zoneId=31)
    ----------------------------------------------------------------------------
    [31] = {
        normalId = 16,
        vetId    = 313,
        zoneId   = 31,
        sets     = {279,123,71,19},
        questID  = 4733,
        HM       = 1640,
        SR       = 1638,
        ND       = 1639,
        TR       = nil,
        name     = "Selene’s Web",
        bosses = {

            {
                name = "Treethane Kerninn",
                mechanics = {
                    "Initial Adds – Many enemies accompany Kerninn. Tank gather them in the center for AoE. :contentReference[oaicite:0]{index=0}",
                    "Cleave – Occasionally performs a small AoE cleave; step out or block if you’re the tank. :contentReference[oaicite:1]{index=1}",
                    "Ravens (Pull-in) – Kerninn raises arms, yanks group inward, dealing moderate AoE (ravens). (|c00FFFFBREAK FREE|r if stunned). :contentReference[oaicite:2]{index=2}",
                    "Stay Organized – After the pull, re-form your positions quickly to avoid chaos. :contentReference[oaicite:3]{index=3}",
                },
            },

            {
                name = "Longclaw",
                mechanics = {
                    "Pre-Fight Cats – Four named panthers must be killed or at least engaged so Longclaw descends. :contentReference[oaicite:4]{index=4}",
                    "Additional Senche – During the fight, panther spirits respawn infinitely. Tank hold them; best not to kill or they reappear. :contentReference[oaicite:5]{index=5}",
                    "Volley – Dropped arrow AoE. Step aside to avoid heavy damage. :contentReference[oaicite:6]{index=6}",
                    "Poison Clouds – Appear under or around him, dealing high DoT. Move out. :contentReference[oaicite:7]{index=7}",
                    "Agility – Boss leaps around. Reposition quickly; keep him taunted. :contentReference[oaicite:8]{index=8}",
                },
            },

            {
                name = "Queen Aklayah",
                mechanics = {
                    "Heavy Attack – Must be blocked or it knocks you down (|cFF0000BLOCK|r). :contentReference[oaicite:9]{index=9}",
                    "Negative AoE – Clings to whoever has aggro (usually the tank). Other players stay clear; tank shouldn’t run around. :contentReference[oaicite:10]{index=10}",
                    "Hoarvors – Small insects spawn repeatedly, easy to kill with light AoE. Don’t scatter. :contentReference[oaicite:11]{index=11}",
                },
            },

            {
                name = "Foulhide",
                mechanics = {
                    "Stomp – Frontal AoE with knockdown. (|cFF0000BLOCK|r if tank, or step away) :contentReference[oaicite:12]{index=12}",
                    "Stranglers – Spawn around the arena after stomps. Harmless if ignored. :contentReference[oaicite:13]{index=13}",
                    "Charge – Huge linear red telegraph. He rushes forward, knockdown if hit. Sidestep or block. :contentReference[oaicite:14]{index=14}",
                    "Roar – Fears everyone in range, ~2–3s. (|c00FFFFBREAK FREE|r) to avoid random knockdowns. :contentReference[oaicite:15]{index=15}",
                },
            },

            {
                name = "Mennir Many-Legs",
                mechanics = {
                    "Swarm of Spiders – Constant small spider adds with low HP. AoE them quickly. :contentReference[oaicite:16]{index=16}",
                    "Shock AoE – She channels damaging lightning. (|cFF7F00INTERRUPT|r) whenever possible to prevent big hits. :contentReference[oaicite:17]{index=17}",
                    "Curse/Debuff – She sometimes targets a player for a DoT or stun—again, can be interrupted. :contentReference[oaicite:18]{index=18}",
                },
            },

            {
                name = "Selene",
                mechanics = {
                    "Phase 1 (Spider Form) – Tank keep her faced away; she hits with heavy spider attacks. At ~50%, group falls into lower area. :contentReference[oaicite:19]{index=19}",
                    "Phase 2 (Humanoid) – Gains new mechanics, summons adds (healers/archers). Tank chain them in or keep them taunted. :contentReference[oaicite:20]{index=20}",
                    "Pull-in Webs – Similar to Treethane’s raven pull, but more intense. Move out of the center AoE quickly. :contentReference[oaicite:21]{index=21}",
                    "Foulhide Spirit – A large spectral bear emerges. Remains in front of Selene, dealing massive cone damage. Tank must not spin boss or the group risks one-shot. :contentReference[oaicite:22]{index=22}",
                    "Panther Spirit – Targets distant players. If it’s coming at you, |cFF0000BLOCK|r or you take big damage. :contentReference[oaicite:23]{index=23}",
                },
            },

        },
    },


    ----------------------------------------------------------------------------
    -- 24) Vaults of Madness (zoneId=11)
    ----------------------------------------------------------------------------
    [11] = {
        normalId = 17,
        vetId    = 314,
        zoneId   = 11,
        sets     = {280,91,124,311},
        questID  = 4822,
        HM       = 1658,
        SR       = 1656,
        ND       = 1657,
        TR       = nil,
        name     = "Vaults of Madness",
        bosses = {

            {
                name = "The Cursed One",
                mechanics = {
                    "Skeleton Adds – Several basic undead accompany him; kill them before focusing boss. :contentReference[oaicite:0]{index=0}",
                    "Frozen Torrent – Similar to wraiths, an ice AoE channel; can be interrupted (|cFF7F00INTERRUPT|r). :contentReference[oaicite:1]{index=1}",
                    "Drain Life – Reflects party damage onto the beam target. Stop attacking while beam is active to avoid killing your ally. :contentReference[oaicite:2]{index=2}",
                },
            },

            {
                name = "Ulguna Soul-Reaver",
                mechanics = {
                    "Frontal Flame Wave – Cone AoE that knocks back. Tank keep her faced away from group. :contentReference[oaicite:3]{index=3}",
                    "Levitation/Stifle – Random player is lifted & helpless for ~10s; 4 healing orbs float toward boss. Kill orbs quickly to free ally. :contentReference[oaicite:4]{index=4}",
                    "Maintain Taunt – She can rapidly target squishies if the tank drops aggro. :contentReference[oaicite:5]{index=5}",
                },
            },

            {
                name = "Death’s Head",
                mechanics = {
                    "Initial Adds – Ranged enemies fill the room. Tank group them mid-room for AoE. :contentReference[oaicite:6]{index=6}",
                    "Frontal Slam – Must be blocked if tanking. Knocks back if you fail to block. :contentReference[oaicite:7]{index=7}",
                    "Skeleton Spawns – Three at a time from boss’s feet; kill fast to prevent explosive self-destruct. :contentReference[oaicite:8]{index=8}",
                    "Charge – Boss runs in a straight line dropping AoE mines. Face him near a wall to shorten his run. :contentReference[oaicite:9]{index=9}",
                },
            },

            {
                name = "Grothdarr",
                mechanics = {
                    "Heavy Slam – Large overhead hit. (|cFF0000BLOCK|r) recommended if you have aggro. :contentReference[oaicite:10]{index=10}",
                    "Overheat/Frontal AoE – Boss charges up & blasts forward. Tank face away from group. :contentReference[oaicite:11]{index=11}",
                    "Lava Trails – Two lava snakes wander the arena. Watch your feet & keep behind boss. :contentReference[oaicite:12]{index=12}",
                },
            },

            {
                name = "Achaeraizur",
                mechanics = {
                    "Many Adds – Numerous dremora in the area. If possible, avoid aggroing all at once. :contentReference[oaicite:13]{index=13}",
                    "Deadroth Fire Breath – Cone flame aimed at tank. (|cFF0000BLOCK or MOVE|r). :contentReference[oaicite:14]{index=14}",
                    "Fire Spit AoEs – Projectiles that knock down if unblocked. Break free, exit the flame quickly. :contentReference[oaicite:15]{index=15}",
                },
            },

            {
                name = "The Ancient One",
                mechanics = {
                    "Watcher Beam – Green triple laser. High damage & knockdown. Tank face boss away so DPS/healer aren’t hit. :contentReference[oaicite:16]{index=16}",
                    "Spin – Typical watcher spin with AoE damage. Watch HP or step out briefly. :contentReference[oaicite:17]{index=17}",
                    "Enrage (low HP) – Damage intensifies. Finish it quickly with high DPS & solid healing. :contentReference[oaicite:18]{index=18}",
                },
            },

            {
                name = "Iskra the Omen",
                mechanics = {
                    "Flame Wall – Targets a random player & breathes fire in a line. Step aside if it aims at you. :contentReference[oaicite:19]{index=19}",
                    "Jump Slam – Boss leaps up or to a distant target, slamming down with a large AoE. (|cFF0000MOVE|r) out quickly. :contentReference[oaicite:20]{index=20}",
                    "Stay Close – If you’re too far, he leaps long distances, wasting group time. Keep him near center. :contentReference[oaicite:21]{index=21}",
                },
            },

            {
                name = "The Mad Architect",
                mechanics = {
                    "Add Waves – Summons undead minions. Tank gather them close, AoE as needed. :contentReference[oaicite:22]{index=22}",
                    "Grinning Bolt – High single-target ranged attack. Tank keep taunt or risk squishy being one-shot. :contentReference[oaicite:23]{index=23}",
                    "Ground Runes – Purple telegraphs that snare & damage. Step aside gently, don’t run amok. :contentReference[oaicite:24]{index=24}",
                    "Spirit Floor – Sconces light up, he channels pink swirling ground. (|cFF0000MOVE out|r) away from the dais or die. :contentReference[oaicite:25]{index=25}",
                    "Telekinesis (Shelter) – Opposite scenario. Move into his protective dome or outside hazards kill you. :contentReference[oaicite:26]{index=26}",
                    "Hard Mode – Scroll of Glorious Battle raises his HP & damage. Extra reward upon success. :contentReference[oaicite:27]{index=27}",
                },
            },

        },
    },

}
-------------------------------------------------------------------------------
-- DLC DUNGEONS
-------------------------------------------------------------------------------
TTDungeon.DLCDungeonInfo_en = {

    ----------------------------------------------------------------------------
    -- 1) White-Gold Tower (zoneId=688)
    ----------------------------------------------------------------------------
    [688] = {
        normalId = 288,
        vetId    = 287,
        zoneId   = 688,
        sets     = {184,185,198,183},
        questID  = 5342,
        HM       = 1279,
        SR       = 1275,
        ND       = 1276,
        TR       = nil,
        name     = "White-Gold Tower",
        bosses = {

            {
                name = "The Adjudicator",
                mechanics = {
                    "Imprison (Cages) – Random player gets thrown into a flaming cage on the edges. Must lockpick or get freed by an ally. :contentReference[oaicite:0]{index=0}",
                    "Zombies – Spawn throughout fight; kill them promptly so they don’t overwhelm. :contentReference[oaicite:1]{index=1}",
                    "Flame Waves – Narrow cone attack repeating thrice. Deals heavy knockback/damage. Spread out to see who she’s aiming at, then move to boss’s sides. :contentReference[oaicite:2]{index=2}",
                    "Fire Towers – Left/right pillars throw ground AoEs. Avoid standing in them (|cFF0000MOVE|r). :contentReference[oaicite:3]{index=3}",
                },
            },

            {
                name = "Elite Guard (Micella, Otho, Cordius)",
                mechanics = {
                    "3-Boss Encounter – Each has unique skillset; tank gather all 3, but kill order helps. :contentReference[oaicite:4]{index=4}",
                    "Micella Carlinus (Tank role) – Uses DK abilities; drops banner, stuns. Focus her first to remove buffs/debuffs quickly. :contentReference[oaicite:5]{index=5}",
                    "Cordius Pontifio (DPS role) – Mix of Nightblade + DK. Teleport strike, Dragonknight Standard, spinning AoE. Usually second kill target. :contentReference[oaicite:6]{index=6}",
                    "Otho Numida (Healer role) – Light staff attacks, HoT spells, can cast a 'fire wheel' (spokes). Keep him interrupted or kill last if controlled well. :contentReference[oaicite:7]{index=7}",
                    "Watch for overlapping banners & AoEs. Spread out or block if targeted. :contentReference[oaicite:8]{index=8}",
                },
            },

            {
                name = "The Planar Inhibitor",
                mechanics = {
                    "Pinion Mechanic – Boss can only be 'taunted' by picking up the pinion in center. Person with pinion receives stacking fire DoT. :contentReference[oaicite:9]{index=9}",
                    "Portals – Two players see grayscale screens. They alone can destroy these rifts; kill them fast or adds spawn. :contentReference[oaicite:10]{index=10}",
                    "Dive Variation:\n    • Red Phase – She moves slowly, no meltdown aura. Tank can hold or approach.\n    • Blue Phase – She’s engulfed in blue flames, lethal close-range snare aura. Kite her around or 'piggy in the middle' with pinion passing. :contentReference[oaicite:11]{index=11}",
                    "Flame Circles – Appear under players (especially in red phase). Just step aside. :contentReference[oaicite:12]{index=12}",
                    "Coordination – Rotate who has pinion to avoid lethal DoT stacks. Keep boss moving in blue phase so she doesn’t kill you instantly. :contentReference[oaicite:13]{index=13}",
                },
            },

            {
                name = "Molag Kena",
                mechanics = {
                    "Lightning Aspects x4 (Startup + 60%, 30%) – Kena is shielded, kill 4 aspects around the arena. They explode upon death; don’t stand in AoE. :contentReference[oaicite:14]{index=14}",
                    "Knockback Waves – During shield phase, she jumps & slams with lightning arcs, pushing players to lethal fire ring. Dodge or block in the gaps. :contentReference[oaicite:15]{index=15}",
                    "Lightning Walls – Rotating lines crossing the arena. Move with them or |cFF0000BLOCK|r/dodge roll through. On Hard Mode they move faster. :contentReference[oaicite:16]{index=16}",
                    "Storm Atronach – Spawns occasionally, targets a random player. Explodes if it touches them. Kill ASAP or kite away. :contentReference[oaicite:17]{index=17}",
                    "Wind Cone – Kena conjures a large frontal knockback. Tank face her away from group, block to avoid losing position. :contentReference[oaicite:18]{index=18}",
                    "Execute Stage (~25%) – All mechanics combine. Two lightning walls at once, 2 Storm Atronachs, no more shield phases. Finish quickly. :contentReference[oaicite:19]{index=19}",
                    "Hard Mode Scroll – Increases her damage/HP, speeds up lightning walls. Additional rewards upon success. :contentReference[oaicite:20]{index=20}",
                },
            },

        },
    },


    ----------------------------------------------------------------------------
    -- 2) Imperial City Prison (zoneId=678)
    ----------------------------------------------------------------------------
    [678] = {
        normalId = 289,
        vetId    = 268,
        zoneId   = 678,
        sets     = {195,196,190,164},
        questID  = 5136,
        HM       = 1303,
        SR       = 1128,
        ND       = 1129,
        TR       = nil,
        name     = "Imperial City Prison",
        bosses = {

            {
                name = "Overfiend",
                mechanics = {
                    "Flurry (Cone AoE) – Rapid-hitting forward cone. Tank must block and not spin the boss. Anyone else caught likely dies. :contentReference[oaicite:0]{index=0}",
                    "Jump Slam – Leaps onto the tank (or aggro target). (|cFF0000BLOCK|r or be knocked down). :contentReference[oaicite:1]{index=1}",
                    "Circle of Corruption (Interruptible) – Red sparks animation. If not interrupted, a large AoE forms under you, stunning and damaging. :contentReference[oaicite:2]{index=2}",
                    "Adds – Spawn steadily from cages/portal. Must be killed quickly or group is overwhelmed. :contentReference[oaicite:3]{index=3}",
                    "Harvester at ~50% – Boss summons a harvester from a portal. Prioritize it; it uses lethal AoEs. :contentReference[oaicite:4]{index=4}",
                },
            },

            {
                name = "Ibomez the Flesh Sculptor",
                mechanics = {
                    "Heavy Attack (Uppercut) – Must be blocked or it knocks target high (|cFF0000BLOCK|r). Usually on tank if taunt is maintained. :contentReference[oaicite:5]{index=5}",
                    "Cone Poison Wave – Tank face boss away from group; avoid standing in front. :contentReference[oaicite:6]{index=6}",
                    "Tenderize (Stun) – Boss pins a random player, charging a fatal blow. (|cFF7F00INTERRUPT|r quickly to save them). :contentReference[oaicite:7]{index=7}",
                    "Sludge Pool Ritual (75/50/25%) – He runs to the pool in center, spawning many Inmates from side doors. Use 'flesh bombs' on them before they reach the pool. Or they form multiple Flesh Atronachs. :contentReference[oaicite:8]{index=8}",
                    "Flesh Atronachs – Must be focused if formed. They eventually enrage, dealing massive damage. :contentReference[oaicite:9]{index=9}",
                },
            },

            {
                name = "Gravelight Sentry",
                mechanics = {
                    "5 Necromancers – Positioned around the island. They summon skeletons if not interrupted/killed. Focus them or they’ll spawn adds. :contentReference[oaicite:10]{index=10}",
                    "Knockback Spin – Boss hunkers down, releases a large AoE that knocks players away (possibly into poison water). (|cFF0000BLOCK|r or step out). :contentReference[oaicite:11]{index=11}",
                    "Laser Beams – Triple green lines aimed at tank’s front. Either block or move sideways. :contentReference[oaicite:12]{index=12}",
                    "Poison Bombs – Projectiles from the surrounding toxic water. If about to land on you, |cFF0000BLOCK|r to avoid stun. :contentReference[oaicite:13]{index=13}",
                    "Avoid Poison – Falling off or knocked into the water deals lethal poison DoT. :contentReference[oaicite:14]{index=14}",
                },
            },

            {
                name = "Flesh Abomination",
                mechanics = {
                    "Hoarvors – Constantly spawn. Their poison AoEs are deadly if stacked. Kill them ASAP. :contentReference[oaicite:15]{index=15}",
                    "Hoarvor Splat (~every 25%) – Boss moves center, summoning 4 kamikaze hoarvors that explode upon smash. Spread out, block or avoid them. :contentReference[oaicite:16]{index=16}",
                    "Poison Circles – Each player gets a small circle. One unlucky player is enclosed in a ring—stay inside it. Others cannot cross the ring edge or they die. Zombies spawn during this. :contentReference[oaicite:17]{index=17}",
                    "Heavy Attacks – Even with block, can knock tank around. Face boss to a wall or fence to avoid excessive repositioning. :contentReference[oaicite:18]{index=18}",
                },
            },

            {
                name = "Lord Warden’s Council",
                mechanics = {
                    "4 Dremora (Necromancer, Knight, Berserker, Healer) – Each has unique synergy. Kill them in best order so final ghosts are manageable. :contentReference[oaicite:19]{index=19}",
                    "Necromancer – Summons a totem that drastically reduces damage to them. Must kill or totem to break. Usually first kill target. :contentReference[oaicite:20]{index=20}",
                    "Knight – Has a charge AoE, cannot be blocked when in ghost form. Step aside. :contentReference[oaicite:21]{index=21}",
                    "Berserker – Dual Wield, uses steel tornado. Block or get away. As a ghost, you must avoid, as it can’t be blocked. :contentReference[oaicite:22]{index=22}",
                    "Healer – Basic heals. Easy to interrupt while alive, unstoppable in ghost form. Often kill last so others remain controlled. :contentReference[oaicite:23]{index=23}",
                    "Ghost Revival – Once a boss is killed, it revives as an untauntable ghost. It keeps using some abilities. You can’t damage or interrupt them. :contentReference[oaicite:24]{index=24}",
                },
            },

            {
                name = "Lord Warden Dusk",
                mechanics = {
                    "Teleport & Slam – He vanishes, stuns the tank, then overhead hits. Tank: break free + block or you get smashed. :contentReference[oaicite:25]{index=25}",
                    "Shadow Orbs – Blue spheres drain HP & snare if you stand near them. Spread out. :contentReference[oaicite:26]{index=26}",
                    "Meteor (Small) – Random meteor targets a player. |cFF0000BLOCK|r to avoid stun/damage. :contentReference[oaicite:27]{index=27}",
                    "Machine Gun – Rapid blasts at a chosen player. That player stands behind tank, who blocks the shots. :contentReference[oaicite:28]{index=28}",
                    "Portals – Appear in pairs. Stepping in takes you to the ceiling. Press synergy to safely land. You only have 2 uses per portal. :contentReference[oaicite:29]{index=29}",
                    "Darklight Blast – Lord Warden flies up. Everyone on the floor is instantly killed. Two players must enter each portal quickly, then synergy. :contentReference[oaicite:30]{index=30}",
                    "Shades (65% & 35%) – He disappears, 4 shadow clones appear. Only 1 is solid at a time. Tank taunts them all. DPS kill the solid shade. Meteors also fall more frequently. :contentReference[oaicite:31]{index=31}",
                    "Fight ends once final 0% is reached. Survive multiple Darklight phases & shade phases. :contentReference[oaicite:32]{index=32}",
                },
            },

        },
    },


    ----------------------------------------------------------------------------
    -- 3) Ruins of Mazzatun (zoneId=843)
    ----------------------------------------------------------------------------
    [843] = {
        normalId = 293,
        vetId    = 294,
        zoneId   = 843,
        sets     = {256,258,259,260},
        questID  = 5403,
        HM       = 1506,
        SR       = 1507,
        ND       = 1508,
        TR       = nil,
        name     = "Ruins of Mazzatun",
        bosses   = {

            {
                name = "Zatzu",
                mechanics = {
                    "Uppercut Heavy Attack – Must be blocked or it knocks you down (|cFF0000BLOCK|r). Typically aimed at tank. :contentReference[oaicite:0]{index=0}",
                    "Teleport Slam – Leaps upward and slams onto aggro target, large AoE splash. Avoid or block on landing. Stones scatter outward—block or dodge. :contentReference[oaicite:1]{index=1}",
                    "Raining Rocks – Boss channels a swirl overhead, hurling rocks randomly (similar to Aetherian Archive second boss). Block or risk knockdown. :contentReference[oaicite:2]{index=2}",
                    "Hold Position – Constantly running around invites extra AoE from slams. Tank keeps him still, dps move aside only when needed. :contentReference[oaicite:3]{index=3}",
                },
            },

            {
                name = "Mighty Chudan",
                mechanics = {
                    "Spit Barrage – A multi-hit heavy 'spit' attack aimed at tank. (|cFF0000BLOCK|r recommended) Each hit also places ground AoE. Do NOT turn boss. :contentReference[oaicite:4]{index=4}",
                    "Haj-Mota Adds – Two spawn periodically. Kill them or be overrun. Tank gather & AoE. :contentReference[oaicite:5]{index=5}",
                    "Archers – Also spawn around the arena; chain them in or kill quickly. :contentReference[oaicite:6]{index=6}",
                    "Shielded Argonian – Protected by a lightning bubble. Only breakable by Chudan's charge. :contentReference[oaicite:7]{index=7}",
                    "Charge Mechanic – A red AoE follows a random player. Lure it to the shielded Argonian. Just before impact, dodge roll to let Chudan smash the shield. :contentReference[oaicite:8]{index=8}",
                },
            },

            {
                name = "Xal-Nur the Slaver",
                mechanics = {
                    "Roar – A wide-radius AoE that knocks back or interrupts. Tank soaks, others stand out of range. :contentReference[oaicite:9]{index=9}",
                    "Charge – Boss charges a distant player (heavy attack). If group can interrupt after he starts moving, do so. Otherwise, block if targeted. :contentReference[oaicite:10]{index=10}",
                    "Archers & Trolls – Summoned adds at intervals. Trolls must be taunted/killed. Archers can be let loose with wamasu trick or killed manually. :contentReference[oaicite:11]{index=11}",
                    "Burrow/Stomp – Similar to vMA behemoth. He stomps, launching rocks across floor. Sidestep or block. :contentReference[oaicite:12]{index=12}",
                    "Spit “Spice” & Geysers (Phase) – At certain HP thresholds, Xal-Nur becomes immune. He spits goo. Player(s) with the goo must deliver it to the active geyser. Movement is slowed, watch out for mudcrabs & boss charges. :contentReference[oaicite:13]{index=13}",
                    "Release Wamasu – A troll tamer spawns each immune phase. Kill one tamer to free a wamasu that helps kill archers. :contentReference[oaicite:14]{index=14}",
                    "Repeat – This cycle happens ~3 times. Focus trolls, handle goo quickly, keep boss center for easier management. :contentReference[oaicite:15]{index=15}",
                },
            },

            {
                name = "Tree-Minder Na-Kesh",
                mechanics = {
                    "Totems – She spawns draining totems frequently. Must be destroyed ASAP or group resources go to zero. :contentReference[oaicite:16]{index=16}",
                    "Add Waves – Argonian archers, Stone-Shapers, etc. kill them or the room gets overwhelmed. Tank must gather them & hold. :contentReference[oaicite:17]{index=17}",
                    "Spirit Phases @70% & 50% – She retreats to a cage, summoning either Chudan or Xal-Nur's spirit. You can kill it quickly or build ultimate. :contentReference[oaicite:18]{index=18}",
                    "Curses @70%, 50%, 30% – A player gets disco color screen, losing normal skills. Allies see which statue is lit. Move to it together so cursed player can break it. :contentReference[oaicite:19]{index=19}",
                    "Execute Phase (~30%) – She gains swirling root AoEs, dealing high DoT. Don’t panic-run. Keep mechanics tight. :contentReference[oaicite:20]{index=20}",
                    "Focus – Always kill totems. Control adds. Cleanse curses. Each stage can overlap. Composure is key. :contentReference[oaicite:21]{index=21}",
                },
            },

        },
    },


    ----------------------------------------------------------------------------
    -- 4) Cradle of Shadows (zoneId=848)
    ----------------------------------------------------------------------------
    [848] = {
        normalId = 295,
        vetId    = 296,
        zoneId   = 848,
        sets     = {257,261,262,263},
        questID  = 5702,
        HM       = 1524,
        SR       = 1525,
        ND       = 1526,
        TR       = nil,
        name     = "Cradle of Shadows",
        bosses = {

            {
                name = "Sithera",
                mechanics = {
                    "In darkness, boss takes only ~10% damage—keep her within a lit brazier’s circle for full damage (|cFF0000ALWAYS fight in light|r) :contentReference[oaicite:0]{index=0}",
                    "Random poison spit at whoever has aggro (|cFF0000BLOCK|r if tank, or quickly step aside) :contentReference[oaicite:1]{index=1}",
                    "Spawns smaller spider adds—quick AoE helps. They also do minimal poison but can overwhelm if ignored. :contentReference[oaicite:2]{index=2}",
                    "Brazier Phases: At ~50%, current brazier goes dark—move to the next. (|cFFD700RE-LIGHT braziers|r) and bring Sithera over. :contentReference[oaicite:3]{index=3}",
                },
            },

            {
                name = "Khephidaen the Spiderkith",
                mechanics = {
                    "Heavy Attack overhead—lethal if unblocked (|cFF0000BLOCK|r). Also watch small telegraphs around boss. :contentReference[oaicite:4]{index=4}",
                    "Large AoE 'burst' expansions—step out before it explodes or block if tank. :contentReference[oaicite:5]{index=5}",
                    "Boss teleports to braziers & extinguishes them. Darkness spawns shadowy adds—quickly re-light them. :contentReference[oaicite:6]{index=6}",
                    "Watch for a swirling cast—interrupting it prevents big damage. (|cFF7F00INTERRUPT|r recommended). :contentReference[oaicite:7]{index=7}",
                },
            },

            {
                name = "Votary of Velidreth",
                mechanics = {
                    "A giant spider with multiple poison AoEs—some can one-shot squishies. (|cFF0000AVOID circles|r) :contentReference[oaicite:8]{index=8}",
                    "Small spiders frequently join. Kill them quickly so they don’t accumulate. :contentReference[oaicite:9]{index=9}",
                    "Boss can attempt self-heal by devouring dead spider corpses—|cFF7F00INTERRUPT|r if you see it feeding. :contentReference[oaicite:10]{index=10}",
                    "Occasional wide AoE explosion at maximum range (|cFF0000MOVE|r). Do not stand in it or guaranteed one-shot. :contentReference[oaicite:11]{index=11}",
                },
            },

            {
                name = "Dranos Velador",
                mechanics = {
                    "Boss stands mid-room; statue sends red energy waves across the floor—move or jump over them. :contentReference[oaicite:12]{index=12}",
                    "Immunity Phase: Dranos teleports, spawns 3 'shadows'. Killing them drops red orbs—picking all 3 ends boss immunity, stuns Dranos briefly for DPS window. :contentReference[oaicite:13]{index=13}",
                    "Pin Mechanic: Two small adds pin (stun) a random target; boss charges heavy attack for a one-shot. Allies must kill or bash the pinning adds FAST. The pinned victim must block right after release. :contentReference[oaicite:14]{index=14}",
                    "Teleport Strike AoEs: He leaps to each player, leaving a red circle under them. Spread out, block each strike, then step out of the circles. :contentReference[oaicite:15]{index=15}",
                    "Mortar Shots: He lobs flame orbs that land in a large AoE. Step aside—lingering effect can knock you down. :contentReference[oaicite:16]{index=16}",
                },
            },

            {
                name = "Velidreth",
                mechanics = {
                    "Resources-Drain Orbs: Multicolored orbs drift around—|cFF0000AVOID|r or they drain health/stamina/magicka. :contentReference[oaicite:17]{index=17}",
                    "Devour Ultimate: She randomly channels on a player, consuming their built-up ultimate. Use ults promptly. :contentReference[oaicite:18]{index=18}",
                    "Flesh Atronachs (@~81% & 51%) – Kill them. Each drops synergy orbs that 2 players must pick up to hold lights for catacombs. :contentReference[oaicite:19]{index=19}",
                    "Catacombs (@66% & 33%) – Banished in pairs, each group has 1 light. Navigate a mini-maze, avoiding traps & adds. Don’t split or the unlit player dies. Rejoin boss area once you find exit. :contentReference[oaicite:20]{index=20}",
                    "Ceiling Attack: “Don’t move a muscle!” – If you do, one-shot impale. Wait for color shift & rumble, then dodge roll last-second. :contentReference[oaicite:21]{index=21}",
                    "Final Phase ~30% – No more catacombs, but orbs, devour, & overhead leaps persist. Burn quickly. :contentReference[oaicite:22]{index=22}",
                    "Res Trick: She interrupts rez attempts with a fast cast. Tank/dps can dummy-res, then interrupt her, then finish rez safely. :contentReference[oaicite:23]{index=23}",
                },
            },

        },
    },


    ----------------------------------------------------------------------------
    -- 5) Bloodroot Forge (zoneId=973)
    ----------------------------------------------------------------------------
    [973] = {
        normalId = 324,
        vetId    = 325,
        zoneId   = 973,
        sets     = {340,341,338,339},
        questID  = 5889,
        HM       = 1696,
        SR       = 1694,
        ND       = 1695,
        TR       = nil,
        name     = "Bloodroot Forge",
        bosses   = {

            {
                name = "Mathgamain",
                mechanics = {
                    "Boss has a conal heavy attack—must be blocked or it one-shots. (|cFF0000BLOCK|r) :contentReference[oaicite:0]{index=0}",
                    "Adds spawn in waves at ~75%, 50%, and 25%. Tank gather them up; dps kill them quickly. :contentReference[oaicite:1]{index=1}",
                    "Possible stranglers may appear—focus them fast to avoid heavy poison DoT. :contentReference[oaicite:2]{index=2}",
                },
            },

            {
                name = "Caillaoife",
                mechanics = {
                    "At ~75/50/25% HP, boss becomes immune, forming a ‘forest’ barrier. Adds spawn (bears, stranglers, etc.)—kill them to remove shield. :contentReference[oaicite:3]{index=3}",
                    "Boss channels a large frontal AoE rock blast—tank must face away from group. (|cFF0000BLOCK|r or dodge) :contentReference[oaicite:4]{index=4}",
                    "Periodically a random player is singled out with an ice swirl aura—boss fires ice attacks at them. Move carefully, maintain heals. :contentReference[oaicite:5]{index=5}",
                },
            },

            {
                name = "Stoneheart",
                mechanics = {
                    "“Space Invaders” – Boss channels many small fiery projectiles traveling across the floor. Wiggle left/right to avoid them. :contentReference[oaicite:6]{index=6}",
                    "Summons Stone Atronachs—if not killed quickly, they enrage and place red AoEs under players. (|cFFD700KILL quickly|r) :contentReference[oaicite:7]{index=7}",
                    "Spreads random persistent flame circles—dodge them, they stack up fast. :contentReference[oaicite:8]{index=8}",
                    "At ~25% HP, roots players occasionally—dodge roll to break free or suffer heavy burst damage. :contentReference[oaicite:9]{index=9}",
                },
            },

            {
                name = "Galchobhar",
                mechanics = {
                    "Heavy Attack forms a mini-volcano—tank must stand on it and block, or party gets hit by lethal fireballs. :contentReference[oaicite:10]{index=10}",
                    "Fire Shalk spawns—if it targets you with a flame ball, jump onto the outer molten rock to dissipate it. :contentReference[oaicite:11]{index=11}",
                    "At ~50% boss summons Stone Atronachs; kill them quickly or they spawn multiple ground AoEs. :contentReference[oaicite:12]{index=12}",
                    "Boss throws weapon mid-fight—everyone must jump to a separate platform around the arena to avoid a giant floor explosion. Don’t share pads or they sink faster. :contentReference[oaicite:13]{index=13}",
                },
            },

            {
                name = "Gherig Bullblood (Trio)",
                mechanics = {
                    "3 Bosses: Gherig (main), Firehide add (chains 2 players, must interrupt), and a Healer add. :contentReference[oaicite:14]{index=14}",
                    "Kill order typically: Firehide Minotaur (one-shot chain mechanic) > Healer add > Gherig. :contentReference[oaicite:15]{index=15}",
                    "Tank gather all 3, keep them from spinning AoEs onto group. Watch out for ground AoE after chain break. :contentReference[oaicite:16]{index=16}",
                },
            },

            {
                name = "Earthgore Amalgam",
                mechanics = {
                    "Boss hurls Lava Pools that grow & spew fire orbs at players—stay away from them. :contentReference[oaicite:17]{index=17}",
                    "Periodically becomes immune & rains rocks from above—dodge the falling stones. (|cFF0000MOVE|r) :contentReference[oaicite:18]{index=18}",
                    "At ~80% & ~50%, boss splits into 2, then 3 copies total. Each has same mechanics—multiple heavy attacks & more lava pools. :contentReference[oaicite:19]{index=19}",
                    "Best tactic: push phases quickly & kill smaller copies first to reduce overlapping lava pools. :contentReference[oaicite:20]{index=20}",
                    "Hard Mode: Braziers disabled, boss hits harder/has more HP. No stuns or lava cleanses from environment. :contentReference[oaicite:21]{index=21}",
                },
            },

        },
    },


    ----------------------------------------------------------------------------
    -- 6) Falkreath Hold (zoneId=974)
    ----------------------------------------------------------------------------
    [974] = {
        normalId = 368,
        vetId    = 369,
        zoneId   = 974,
        sets     = {336,337,342,335},
        questID  = 5891,
        HM       = 1704,
        SR       = 1702,
        ND       = 1703,
        TR       = nil,
        name     = "Falkreath Hold",
        bosses   = {

            {
                name = "Morrigh Bullblood",
                mechanics = {
                    "Has one Minotaur ally—focus the Minotaur first, then burn her. :contentReference[oaicite:0]{index=0}",
                    "At ~50% HP, she raises a protective dome. Everyone must stand inside to avoid heavy area bombardment. :contentReference[oaicite:1]{index=1}",
                    "She lays small ground AoEs—step out quickly. No need to panic-run. :contentReference[oaicite:2]{index=2}",
                },
            },

            {
                name = "Siege Mammoth",
                mechanics = {
                    "Tank: keep the mammoth faced away from the party—heavy frontal attacks. :contentReference[oaicite:3]{index=3}",
                    "Projectile Fire: archers lob flaming AoEs onto the battlefield—keep moving to dodge. :contentReference[oaicite:4]{index=4}",
                    "Stomp – Under ~50% HP, mammoth rears up. Everyone must BLOCK or be one-shot. :contentReference[oaicite:5]{index=5}",
                },
            },

            {
                name = "Cernunnon",
                mechanics = {
                    "Three bosses (Mage, Archer, Melee) appear in turn. Each must be killed, then their soul is carried to an altar. (|cFF0000MOVE|r while carrying or you'll get pinned by enemies). :contentReference[oaicite:6]{index=6}",
                    "If you fail to altar their souls, they revive. This repeats until all souls are placed. :contentReference[oaicite:7]{index=7}",
                    "Main boss emerges after placing 3 souls. Summons skeleton adds; kill them quickly. :contentReference[oaicite:8]{index=8}",
                    "During fight with main boss, each player gets an overhead AoE Comet—spread out and |cFF0000BLOCK|r to avoid lethal damage. :contentReference[oaicite:9]{index=9}",
                    "A swirling boundary traps you—stepping outside kills you. Avoid swirling ghosts (fear effect). :contentReference[oaicite:10]{index=10}",
                },
            },

            {
                name = "Deathlord Bjarfrud Skjoralmor",
                mechanics = {
                    "Constant waves of undead—kill them close to the boss so their corpses cluster. :contentReference[oaicite:11]{index=11}",
                    "Cleanse! – Each dead add leaves a ‘corrupt body’ that must be cleansed using nearby urn synergy. If too many remain, a big explosion can wipe the group. :contentReference[oaicite:12]{index=12}",
                    "Boss channels a direct frontal breath—tank keep it faced away from the group. :contentReference[oaicite:13]{index=13}",
                },
            },

            {
                name = "Domihaus the Bloody-Horned",
                mechanics = {
                    "Maintains a stationary center position—tank must keep taunt, or he hadokens random players, one-shotting them. :contentReference[oaicite:14]{index=14}",
                    "Shout at 70/50/30/10/5% HP—one-shot if you’re not behind a pillar. Pillars break after each shout, so group must coordinate. :contentReference[oaicite:15]{index=15}",
                    "Pull & Fire Trails – He drags players in, then each drops multiple fire AoEs behind them—|cFF0000DON’T stack up|r and walk backwards (or sideways) to avoid overlapping. :contentReference[oaicite:16]{index=16}",
                    "Stone Phase – Summons 4 Flame Atronachs, becomes untargetable—kill them quickly. :contentReference[oaicite:17]{index=17}",
                    "Ground Slam – Fireballs cross the room from the boss’s center. Hide behind a chosen pillar to avoid lethal hits. :contentReference[oaicite:18]{index=18}",
                    "Execute (~25% HP) – Gains a shield, spams add summons. Burn them with AoE or they overwhelm you. :contentReference[oaicite:19]{index=19}",
                },
            },

        },
    },


    ----------------------------------------------------------------------------
    -- 7) Scalecaller Peak (zoneId=1010)
    ----------------------------------------------------------------------------
    [1010] = {
        normalId = 418,
        vetId    = 419,
        zoneId   = 1010,
        sets     = {348,350,346,347},
        questID  = 6065,
        HM       = 1981,
        SR       = 1979,
        ND       = 1980,
        TR       = 1983,
        name     = "Scalecaller Peak",
        bosses = {

            {
                name = "Orzun the Foul-Smelling & Rinaerus the Rancid",
                mechanics = {
                    "Separate the two bosses so their circles don’t overlap or they’ll enrage—tank holds the melee Ogre (Orzun) away from the ranged Ogre (Rinaerus). :contentReference[oaicite:0]{index=0}",
                    "Rinaerus channels to summon skeevers—|cFF7F00INTERRUPT|r him or kill the skeevers quickly. :contentReference[oaicite:1]{index=1}",
                    "Snowstorm (from Rinaerus) places moving ice spikes on ground—touching them stuns you. At the end, Orzun casts Snow Tremor that one-shots you unless you are 'frozen' by standing in the spike circle (|cFF0000MOVE in intentionally|r!). :contentReference[oaicite:2]{index=2}",
                    "Rinaerus can channel a large ice attack: hide behind ice pillars if needed else it can kill you (|cFF0000BLOCK line of sight|r). :contentReference[oaicite:3]{index=3}",
                    "Kill them near-simultaneously—killing one too early enrages the other. :contentReference[oaicite:4]{index=4}",
                },
            },

            {
                name = "Doylemish Ironheart",
                mechanics = {
                    "Heavy Attack / Bleed on tank—must keep up strong heals or blocks. :contentReference[oaicite:5]{index=5}",
                    "At intervals, floating red spheres spawn, targeting players. If caught, they turn you to stone—ally must break you free or boss channels a lethal beam (can be interrupted). :contentReference[oaicite:6]{index=6}",
                    "Ice Wraith adds appear—kill them quickly with AoE. :contentReference[oaicite:7]{index=7}",
                    "Spread out to handle spheres better; do not run far if petrified or else you’re out of synergy reach. :contentReference[oaicite:8]{index=8}",
                },
            },

            {
                name = "Matriarch Aldis",
                mechanics = {
                    "Arena has ice water that deals lethal damage—|cFF0000STAY on safe platforms|r. :contentReference[oaicite:9]{index=9}",
                    "She stomps the ground in a wide AoE—|cFF0000MOVE out or BLOCK|r. :contentReference[oaicite:10]{index=10}",
                    "Corrupt Leimenids spawn every 10% HP—kill them quickly to avoid poison geysers & big AoE trouble. :contentReference[oaicite:11]{index=11}",
                    "A rotating 'hole' spawns under boss’s feet with swirling ice spikes—tank stands on it to 'plug' the damage, else the group gets hit hard. :contentReference[oaicite:12]{index=12}",
                    "Occasional fear shout—|c00FFFFBREAK FREE|r quickly or risk being knocked into the ice water. :contentReference[oaicite:13]{index=13}",
                },
            },

            {
                name = "Plague Concocter Mortieu",
                mechanics = {
                    "Toxic Buildup – Group accumulates plague stacks, dealing ramping DoT & debuffs. :contentReference[oaicite:14]{index=14}",
                    "Kill specified adds (imps, stranglers, beetles) per Jorvuld’s call—he tosses a potion once they’re dead, cleansing your plague. :contentReference[oaicite:15]{index=15}",
                    "Tank: Must stand on poison grills that fire out green jets—BLOCK them or group gets massive poison damage. :contentReference[oaicite:16]{index=16}",
                    "Mortieu uses bow-like shots—|cFF0000DODGE or BLOCK|r. Also “take aim” snipe can be interrupted. :contentReference[oaicite:17]{index=17}",
                    "When cleansed, group gains big damage buff—burn boss & watch for the summoned guard add. :contentReference[oaicite:18]{index=18}",
                },
            },

            {
                name = "Zaan the Scalecaller",
                mechanics = {
                    "Adds at the start (Ice Atronach & Corrupt Leimenid) – avoid standing in their death aoes (ice spikes & geyser). You need them for final synergy to survive an incoming poison wave. :contentReference[oaicite:19]{index=19}",
                    "Every 20% HP: Two or three big ice adds spawn—kill fast or group is frozen to death. Then 3 statues appear—after killing them, entire floor floods with poison. Everyone must stand in separate mechanics (ice, geyser, laser, or shield) to survive. :contentReference[oaicite:20]{index=20}",
                    "Poison Breath from dragon statues—random conal oneshots from the edges. Group stands in a set formation & sidesteps. :contentReference[oaicite:21]{index=21}",
                    "Fire Breath at random player—smallish wave pattern, just keep calmly stepping sideways out of each wave. :contentReference[oaicite:22]{index=22}",
                    "Fire Beam – She grabs a target in midair—others can block the beam to share damage. If left alone, the victim dies quickly. :contentReference[oaicite:23]{index=23}",
                    "Shield phases—Zaan picks up her shield again, summoning the earlier adds. Rinse and repeat each 20%. Hard Mode adds extra steps for the synergy and timing. :contentReference[oaicite:24]{index=24}",
                },
            },

        },
    },

    -------------------------------------------------------------------------------
    -- 8 Fang Lair (zoneId=1009)
    -------------------------------------------------------------------------------
    [1009] = {
        normalId = 420,
        vetId    = 421,
        zoneId   = 1009,
        sets     = {344,345,349,343},
        questID  = 6064,
        HM       = 1965,
        SR       = 1963,
        ND       = 1964,
        TR       = 2102,
        name     = "Fang Lair",
        bosses = {

            {
                name = "Lizabeth Charnis",
                mechanics = {
                    "Fight proceeds in WAVE PHASES as Lizabeth summons undead (|cFFD700Adds|r).",
                    "Each wave includes bone colossi, skeletons, and ghostly wraiths (|cFFD700Clear quickly|r).",
                    "Watch for large Flying Skulls swirling across the room (|cFF0000DODGE/BLOCK|r).",
                    "Staying fairly central helps manage wave spawns."
                },
            },

            {
                name = "Cadaverous Menagerie",
                mechanics = {
                    "Encounter has |cFFD7003 main bosses|r (Bear, Guar, Senche-Tiger) + 3 Exploding Wolves.",
                    "|cFF0000Senche-Tiger|r: Interrupt leap-and-pin or it kills pinned player!",
                    "|cFF0000Guar|r: Ranged poison spits, easy to kill but respawns later.",
                    "|cFF0000Wolves|r: Chase players and explode; tank can block or group can burst them.",
                    "|cFF0000Bear|r: Frontal heavy & a damage shield. Revives if not finished quickly."
                },
            },

            {
                name = "Caluurion",
                mechanics = {
                    "Lich boss in center, casting expanding AoEs & ground splashes (|cFF0000MOVE|r).",
                    "Summons totems (poison, shock, or adds). |cFFD700Destroy|r them or boss gains immunity later.",
                    "Skeleton minions appear from totems; do quick AoE to avoid root/stun spam.",
                    "At ~25% HP, ignoring a totem triggers boss immunity. So handle totems throughout!"
                },
            },

            {
                name = "Ulfnor and Sabina Cedus",
                mechanics = {
                    "|cFFD700Duo fight|r: Ulfnor (heavy fire attacks), Sabina’s spirit (chains random player).",
                    "Sabina’s chain must be |cFF7F00BASH|r quickly or Ulfnor one-shots the pinned target!",
                    "He also sends conal or bouncing flame arcs—|cFF0000DODGE/BLOCK|r or cleanse burn DoT.",
                    "At low HP, Ulfnor uppercuts the tank across the room. Kill him fast before he impales them!"
                },
            },

            {
                name = "Thurvokun & Orryn the Black",
                mechanics = {
                    "|cFF7F00Orryn|r teleports around and channels fast skull barrage—|cFF7F00INTERRUPT|r ASAP or group melts!",
                    "|cFF0000Poison Pools|r: Thurvokun drops them on tank—place them carefully around center. Don’t run wild.",
                    "Each heavy attack spawns 2 Shalks under tank—|cFFD700Kill or root|r them quickly so tank isn’t overwhelmed.",
                    "|cFFD700Crystals (85/75/65/55%)|r: Each spawns a Bone Colossus & adds—destroy the crystal & kill colossus to stop repeats.",
                    "|cFFA500Ghost Phase (~45%)|r: Orryn summons unstoppable ghost lines. A golden ally spawns a wall—|cFF0000HIDE behind it|r or die on contact!",
                    "|cFF0000Final Phase (50%->0%)|r: Orryn reanimates Thurvokun. Ghost lines return with no help—spot the |cFF0000gap|r and move through fast. Colossi add spawns keep coming at 10% intervals! If he climbs wall & roars, break fear & grab gold circles before the poison breath!"
                },
            },

        },
    },

   



    -------------------------------------------------------------------------------
    -- 9 Moon Hunter Keep (zoneId=1052)
    -------------------------------------------------------------------------------
    [1052] = {
        normalId = 426,
        vetId    = 427,
        zoneId   = 1052,
        sets     = {404,398,402,403},
        questID  = 6186,
        HM       = 2154,
        SR       = 2155,
        ND       = 2156,
        TR       = 2159,
        name     = "Moon Hunter Keep",
        bosses   = {

            {
                name = "Jailer Melitus",
                mechanics = {
                    "Large AoE grows & bursts into several fast red circles—stay |cFF0000SPREAD|r out and |cFF0000MOVE|r to avoid them.",
                    "Blood Fountains spawn under each player—|cFF0000DON’T STACK|r, keep distance to avoid overlapping.",
                    "Werewolf Adds (~80%, ~51%, ~31%)—(|cFFD700KILL adds|r). Their leaping heavy attacks can one-shot if not dodged.",
                    "Interrupt or Die: Boss charges a big overhead blow—(|cFF7F00INTERRUPT|r) fast or it kills the tank instantly."
                },
            },

            {
                name = "Hedge Maze Guardian",
                mechanics = {
                    "Root: Boss roots everyone—(|c00FFFFBREAK FREE|r or |cFF0000DODGE|r) before big damage hits.",
                    "Heavy Attack & Cleave—(|cFF0000BLOCK|r if tank) or dodge aside. Keep boss in the center, away from Stranglers.",
                    "Stranglers around edges can pin players—two DPS roam in pairs to kill Spriggans & Stranglers in the maze.",
                    "Spriggans heal the boss—(|cFFD700KILL them|r) so Guardian’s HP can drop."
                },
            },

            {
                name = "Mylenne Moon-Caller",
                mechanics = {
                    "Pounce pins a player—(|cFF7F00INTERRUPT|r) quickly or pinned target dies.",
                    "Heavy Attack on tank—(|cFF0000BLOCK|r). If aimed at DPS/healer, |cFF0000DODGE|r or be one-shot.",
                    "Wolves spawn in waves—(|cFFD700KILL|r them) before returning focus to the boss.",
                    "Wardens cast lightning AoEs—spread out, keep moving. Don’t stack or you’ll overlap damage."
                },
            },

            {
                name = "Archivist Ernarde",
                mechanics = {
                    "Add Waves (~76%, ~56%, ~36%)—werewolves can one-shot. (|cFFD700FOCUS adds|r) quickly in a corner.",
                    "Lightning AoE under a random player—move away from group until it explodes.",
                    "Shield Bubble traps one player—(|cFFD700DPS break|r) the shield or that player dies.",
                    "Rune Roulette: Boss picks a symbol overhead. Each player must stand in a matching rune circle or face a one-shot."
                },
            },

            {
                name = "Vykosa the Ascendant",
                mechanics = {
                    "Two Wolf Pets share a chain—taunt & kill the red wolf first, then the grey. Dodge their leaps or die.",
                    "Boss heavy attack—(|cFF0000BLOCK|r). Tank suffers strong bleeds—healer use heavy heals.",
                    "Fear Totem—medium AoE. (|c00FFFFBREAK FREE|r) if feared. Avoid standing in it.",
                    "Multiple waves of Werewolves & Wardens at set HP—(|cFFD700KILL adds|r). Wardens cast lightning fields—spread out.",
                    "Archivist Ghost @30%: Rune Roulette returns—each player must find a matching rune again.",
                    "At ~20% both wolves unchained—kill them anew, then finish boss carefully."
                },
            },

        },
    },




    -------------------------------------------------------------------------------
    -- 10 March of Sacrifices (zoneId=1055)
    -------------------------------------------------------------------------------
    [1055] = {
        normalId = 428,
        vetId    = 429,
        zoneId   = 1055,
        sets     = {400,397,401,399},
        questID  = 6188,
        HM       = 2164,
        SR       = 2165,
        ND       = 2166,
        TR       = 2168,
        name     = "March of Sacrifices",
        bosses   = {

            {
                name = "The Wyrd Sisters",
                mechanics = {
                    "Three sisters: Ursus (S&B), Rangifer (Healer), Strigidae (Archer). |cFFD700Kill Order|r often Ursus → Rangifer → Strigidae.",
                    "Ursus: heavy attack can one-shot non-tanks—(|cFF0000BLOCK|r if tank) or dodge if aimed at you. She may also 'Charge' a distant target (|cFF0000BLOCK or DODGE|r).",
                    "Rangifer: tries to heal others—(|cFF7F00INTERRUPT|r her). Keep boss turned away from group and stack her with Ursus if possible.",
                    "Strigidae: has a blue silence aura. Standing inside it blocks magicka skills/ultimates. She uses |cFF0000Arrow Spray|r & Teleport Strike—move out quickly.",
                },
            },

            {
                name = "Aghaedh of the Solstice",
                mechanics = {
                    "Stranglers around the arena shoot players—can be killed or outhealed. Heal must be steady if you ignore them.",
                    "Lurchers spawn at ~70%, 55%, 25% HP—(|cFFD700Focus Lurchers|r). When they die, each drops synergy orbs. Pick them up or risk a fatal AoE later.",
                    "Boss channels a big explosion if you lack the synergy buff—one-shot. So ensure you pick up Lurcher synergy!",
                    "Tank: keep boss faced away and gather any adds. DPS burn Lurchers fast and watch your feet for random AoEs.",
                },
            },

            {
                name = "Dagrund the Bulky",
                mechanics = {
                    "Uses |cFF0000Elemental arcs|r (fire, ice, lightning) at certain HP—dodge or block these wide/bouncing projectiles or suffer massive damage.",
                    "Heavy Attack on tank—(|cFF0000BLOCK|r). Aimed at non-tanks, must be dodged or it's lethal.",
                    "Jump Attack: leaps, lands, shooting four fast AoEs at each player—|cFF0000DODGE ROLL|r or be killed.",
                    "Archers spawn every ~10% HP—(|cFFD700KILL adds first|r). They drop elemental AoEs under players. Don’t get overwhelmed; focus them quickly.",
                },
            },

            {
                name = "Tarcyr",
                mechanics = {
                    "Adds that pin players with a channel—(|cFFD700INTERRUPT & focus|r them). If not freed, pinned player is one-shot.",
                    "Fire Trail: Tarcyr sprints, leaving flames on the floor. Tank re-taunt & keep boss away from group afterward.",
                    "Stampede: sends ghost stags to each player—(|cFF0000BLOCK|r or dodge) or you’ll get knocked down.",
                    "Lightning Stomp: Tarcyr repeatedly stomps lightning pulses—(|cFF7F00INTERRUPT|r) or the group can wipe.",
                    "Hunt Phase (@80%, 55%, 20%): everyone must sneak/stealth to avoid forced knock-up. 3 synergy activations from the wandering wisp to end the phase. Breaking stealth 3 times kills you.",
                },
            },

            {
                name = "Balorgh",
                mechanics = {
                    "Cycles water (shock), flowers on islands, and overhead stomp with fireballs. Watch which element is active—avoid or block accordingly.",
                    "Heavy Attack & Breath: always turned away from group. Tank must |cFF0000BLOCK|r or risk a one-shot. Team stay behind boss.",
                    "Fireballs after stomp: boss shouts “Burn you…” or “Feel my flames” then fires 4 homing fireballs—|cFF0000DODGE ROLL|r or you’ll get a lethal DoT.",
                    "Hunt Phase (~80%, 60%, 40%, 20%): boss splits into 4 shadows. Lure each shadow into an NPC trap. Avoid water if electrified or islands if they’re covered by explosive flowers.",
                    "Wolves spawn each hunt phase—(|cFFD700Kill them quickly|r). Final ~20% push includes 2 wolves + boss simultaneously; keep calm & handle adds before finishing Balorgh.",
                },
            },

        },
    },


    -------------------------------------------------------------------------------
    -- Frostvault (zoneId=1080)
    -------------------------------------------------------------------------------
    [1080] = {
        normalId = 433,
        vetId    = 434,
        zoneId   = 1080,
        sets     = {432,429,430,431},
        questID  = 6249,
        HM       = 2262,
        SR       = 2263,
        ND       = 2264,
        TR       = 2267,
        name     = "Frostvault",
        bosses   = {

            {
                name = "Icestalker",
                mechanics = {
                    "Boss faces tank: conal AoE attacks—|cFF0000BLOCK|r if tank, do not spin boss onto group.",
                    "Uppercut pins a random player—(|cFF7F00INTERRUPT|r boss quickly) or pinned target is pummeled to death.",
                    "Summons waves of Ice Wraiths & Spiders at ~90%/75%/50%/30%—(|cFFD700KILL adds|r ASAP). Wraiths do heavy hits/stuns.",
                    "Troll picks up a boulder & hurls it at a player—|cFF0000DODGE ROLL|r or block to mitigate knockdown. Don’t run away or boss leaps on you.",
                },
            },

            {
                name = "Warlord Tzogvin",
                mechanics = {
                    "Tethered: Two players link up—move apart to break link or both explode (|cFF0000SPREAD OUT|r).",
                    "Heavy Attack/Wrecking Blow on random—(|cFF0000BLOCK or DODGE|r). Tanks can take it, DPS/healers must dodge or be one-shot.",
                    "Flame Phase @~70%: Tzogvin leaps up, landing with a knockback. Each player gets a red circle with DoT—|cFF0000DO NOT overlap|r or it’s lethal. Focus damage on his protective shield to cancel the phase.",
                    "Whirlwinds @~30%: Tornadoes circle the room’s edge, one may chase a player—kite carefully; boss sometimes channels a blizzard. |cFF0000MOVE constantly|r to avoid big AoEs.",
                    "Adds: Goblin archers can spawn. (|cFFD700Interrupt or kill|r them quickly). Tank chain them in if possible.",
                },
            },

            {
                name = "Vault Protector",
                mechanics = {
                    "Hides in a protective dome at thresholds (~75%, ~40%, ~20%). Laser beams cross the room—|cFF0000STAY behind boss’s dome|r to block lasers or you’ll be one-shot.",
                    "Boss has typical Dwemer Centurion moves: conal steam breath (tank block) and lightning barrage (step aside).",
                    "Dwemer Spheres & Spiders spawn frequently—(|cFFD700KILL adds|r). Spiders can 'charge' spheres, making them more deadly. Keep them under control or you’ll be overwhelmed.",
                    "Blue rolling orbs also roam—avoid them or they stun/explode.",
                },
            },

            {
                name = "Rizzuk Bonechill (with Avalanche)",
                mechanics = {
                    "Fight has 2 bosses: Rizzuk (focus kill) & Avalanche (massive frost atronach). Tank must keep Avalanche’s heavy hits away from group.",
                    "Rizzuk teleports & channels a lethal frost beam—(|cFF7F00INTERRUPT|r) quickly or group dies.",
                    "Frozen Blast: Rizzuk moves center, each player gets a red circle that explodes after a short stun—(|cFF0000SPREAD OUT|r) or you overlap & die.",
                    "Avalanche performs ground AoE phases—tank must stand in/near the partial ‘safe zone’ or block heavy snow blasts. Don’t run away or you’ll take massive DoT.",
                    "Ice Orbs / Tornadoes around edges: avoid big blue swirling AoEs. At low HP, Rizzuk spawns more ice hazards—|cFF0000DODGE|r them.",
                },
            },

            {
                name = "The Stonekeeper",
                mechanics = {
                    "Phase 1: Destroy both arms before damaging boss. Each arm spawns a Dwemer Centurion on death—(|cFFD700FOCUS & kill|r quickly). Rolling orbs roam floor—avoid or get stunned.",
                    "Spinning Flame Attack: once arms are gone, Stonekeeper spins flame jets—group must keep rotating to avoid instant-kill fire cones.",
                    "Rat Maze (Skeevaton Phase) at ~55% (and again ~30%): each player uses a portal & transforms into a skeevaton. Charge ultimate at central node, split up to disable 4 shock conveyors. Avoid traps, kill/CC Dwemer spawns.",
                    "Phase 2 & 3: same arm-killing routine repeats, but more hazards: spinning blade adds, random meteors, heavier steam DoT (Vet) & possibly a push attack.",
                    "Boss has a close-range lightning aura—|cFF0000DO NOT hug boss|r. Tank: watch for high-damage beam & random heavy slam.",
                },
            },

        },
    },



    -------------------------------------------------------------------------------
    -- Depths of Malatar (zoneId=1081)
    -------------------------------------------------------------------------------
    [1081] = {
        normalId = 435,
        vetId    = 436,
        zoneId   = 1081,
        sets     = {436,433,434,435},
        questID  = 6251,
        HM       = 2272,
        SR       = 2273,
        ND       = 2274,
        TR       = 2276,
        name     = "Depths of Malatar",
        bosses   = {

            {
                name = "Scavenging Maw",
                mechanics = {
                    "Boss faces tank with a frontal cone poison spit—|cFF0000BLOCK|r or sidestep as tank, avoid as DPS/healer.",
                    "When poison AoEs land, step out immediately. Overlapping these is deadly for the tank.",
                    "Boss vanishes at set HP triggers (80%, 50%, 25%). Team must STICK TOGETHER to find it or pinned player dies. Adds & AoE circles spawn—kill adds & |cFF7F00INTERRUPT|r boss once found!",
                    "Stay calm & group up; searching alone guarantees a quick death."
                },
            },

            {
                name = "The Weeping Woman",
                mechanics = {
                    "Conal AoEs form around boss—large ice fields at outside or inside. Watch which region is ‘safe’ each time (|cFF0000MOVE|r).",
                    "Spreading ice: small, fast AoEs or ice spikes chase you—|cFF0000AVOID|r stepping into them or get rooted/immobilized.",
                    "Rotten Geysers: under each player, charge up & burst upward if you remain in them (|cFFA500KEEP FEET MOVING|r).",
                    "Dangerous adds spawn (esp. watchers at 75/55/35%). |cFFD700KILL watchers|r first—heavy attacks can one-shot unblocked."
                },
            },

            {
                name = "Dark Orb",
                mechanics = {
                    "Central dark orb constantly spawns |cFFD700Auroran adds|r. They carry color-coded attacks (|cFFFF00Radiant|r, |cFF0000Blazing|r, |c00FFFFScintillating|r, |cFF7F00Phosphorescent|r).",
                    "Focus an add’s color orb: kills their buff or synergy to orb. Then damage the main orb in the middle. Rinse & repeat.",
                    "|cFFD700KILL orbs|r that appear along room edges—these empower the Aurorans, making them lethal. Destroy them quickly!",
                    "Tank must manage multiple spawns—group should concentrate on clearing all adds before burning the central orb again."
                },
            },

            {
                name = "King Narilmor",
                mechanics = {
                    "Splits into 4 copies. Only |cFFD700one is real|r. Either AoE them down in a corner or single-target them one by one.",
                    "Each copy can have random color-coded abilities (ice, lightning, meteor, etc.). All can channel big hits—|cFF7F00INTERRUPT|r frequently or face heavy damage.",
                    "Heal the NPC Tharayya near the corner vs. a ghost—if she dies, illusions gain huge shields & become near-invincible!",
                    "Maintain situational awareness for color-based AoEs from each clone—(|cFF0000MOVE|r from meteors, ice fields, etc.)."
                },
            },

            {
                name = "Symphony of Blades",
                mechanics = {
                    "Base attacks: heavy slash (|cFF0000BLOCK|r), spinning blades (|cFF0000DODGE|r).",
                    "Ghost Wall: lines of Aurorans cross the arena—kill 1 or 2 to make a gap or you’re one-shot if touched. Watch boss AoE while moving.",
                    "Periodically 4 aurorans spawn around edges—if they reach boss, he gains color-based attacks: |cFF0000Meteors|r, |cFFFF00Radiant beam|r, |c00FFFFLightning|r, or |c7F7FFFIce pillars|r. Kill 1–2 to reduce difficulty.",
                    "Orbs from the Dark Orb fight also appear. |cFFD700Destroy the orbs|r first or face lethal combos of AoE. Then refocus boss.",
                    "Final phase (~11%): Teleports you to a new realm; boss HP jumps to ~50% on HM (~25% normal). Walls appear from multiple directions. Avoid them while dealing with all 4 elemental attacks—|cFF0000SPREAD OUT|r, kill orbs, no panic. Survive until boss is dead!"
                },
            },

        },
    },


    -------------------------------------------------------------------------------
    -- Moongrave Fane (zoneId=1122)
    -------------------------------------------------------------------------------
    [1122] = {
        normalId = 494,
        vetId    = 495,
        zoneId   = 1122,
        sets     = {458,452,453,454},
        questID  = 6349,
        HM       = 2417,
        SR       = 2418,
        ND       = 2419,
        TR       = 2422,
        name     = "Moongrave Fane",
        bosses = {

            {
                name = "Risen Ruins",
                mechanics = {
                    "Rock Throw & Immunity: Boss curls up glowing gold, throwing boulders that knock you down. |cFF0000BLOCK|r if pelted. Two synergy plates can spawn Hemo Helot orbs—|cFF7F00HEAVY ATTACK|r the orbs to break immunity.",
                    "Ground Pound: A repeated AoE damage around the boss—healer watch group health. Avoid center for less damage.",
                    "Dash Across Room: After shield breaks, boss charges straight ahead—|cFF0000AVOID its path|r or be one-shot.",
                    "Adds: Hollowfang vampires & others join mid-fight—(|cFFD700Kill adds|r quickly to avoid overlap).",
                },
            },

            {
                name = "Dro’zakar",
                mechanics = {
                    "Blood Shield: Dro’zakar becomes immune & pulses AoE under each player. Focus the shield & spread out or the stacked AoEs can wipe the group. |cFFD700DPS shield|r fast!",
                    "Blood Pool: Boss sinks into a pool, chasing the tank—|cFF0000BLOCK|r as it drains HP & heals itself. Minimizing movement limits healing.",
                    "Siphon Orbs: Sacrificial helots summon red Hemo Helot orbs in corners—boss tries to drain them for massive empower. |cFF7F00HEAVY ATTACK orbs|r to destroy.",
                    "Adds: Continuous spawns. Tank gather them for AoE. Dro’zakar may also conal-swipe tank—face away from group.",
                },
            },

            {
                name = "Kujo Kethba",
                mechanics = {
                    "Eruptions Phase: Boss smashes floor, becoming immune. Lava geysers appear—must push |cFFA500Sliding Stones|r onto them to stop molten rock. Reflect kills group if you try to dps here!",
                    "Heavy Attack: Boss overhead claw smash—(|cFF0000BLOCK|r) or be knocked down. Also flaps wings for double cone fire wave—avoid front.",
                    "Adds: Many spawn each Eruption—tank gather, kill them quickly to prevent chaos.",
                    "After ~20s Eruption ends—|cFF0000STOP attacking boss|r during reflect & focus the stones to seal geysers. Then resume DPS.",
                },
            },

            {
                name = "Nisaazda & Grundwulf",
                mechanics = {
                    "Nisaazda Teleports: Ranged blood mage using channels that MUST be |cFF7F00INTERRUPT|r. Summons large blood vortex—move bosses out or they get huge damage buff!",
                    "Gargoyle Summon: She attempts a major cast requiring Hemo Helot to interrupt—heavy attack a red orb at her. Failing spawns a big gargoyle add!",
                    "Grundwulf: Basic heavy swings & a linear shout (|cFF0000Fus Ro Dah|r). Dodge or block or be knocked back. Usually tanked in melee while pulling him near Nisaazda to AoE both.",
                    "Ghostly Adds: Immune until hit with Hemo Helot splash. Watch for synergy usage if multiple ghosts + gargoyle are up—coordinate well.",
                },
            },

            {
                name = "Grundwulf (Dragon Ritual)",
                mechanics = {
                    "Block Mechanic: Dragon tries to fire at Grundwulf. He hides behind a |cFFA500Sliding Stone|r. |cFF7F00HEAVY ATTACK|r the stone away so the flames hit him! Failing spreads fire in the arena.",
                    "Fus Ro Dah: A wide line. After it passes, it leaves circles that spawn ghosts—|cFFD700Bash orb or synergy|r if you want them vulnerable via Hemo Helot. They’re otherwise invincible.",
                    "Blood Spikes: Red spike shackles a random player & applies a heal absorb. Must stand inside the spike’s circle until it disappears—coagulant add spawns. At lower boss HP, multiple spikes can appear at once!",
                    "Dire-Maw Adds: Large panther beasts at certain HP or timed intervals—taunt quickly. AoE them down before new waves overlap.",
                    "Hard Mode Extras: Boss HP ~15M, Gains giant bat add chasing a random player—instakill if touched, can only be killed by a Hemo Helot splash. The stone punish if moved incorrectly, & more frequent wall-of-fire from the dragon. Survive all while systematically controlling ghosts + bat + spikes!"
                },
            },

        },
    },


    -------------------------------------------------------------------------------
    -- Lair of Maarselok (zoneId=1123)
    -------------------------------------------------------------------------------
    [1123] = {
        normalId = 496,
        vetId    = 497,
        zoneId   = 1123,
        sets     = {456,457,459,455},
        questID  = 6351,
        HM       = 2427,
        SR       = 2428,
        ND       = 2429,
        TR       = 2431,
        name     = "Lair of Maarselok",
        bosses = {

            {
                name = "Selene’s Claws & Selene’s Fangs",
                mechanics = {
                    "|cFFA500Selene’s Claws (Bear)|r: Tank must face away from group. Heavy Attacks must be |cFF0000BLOCKED|r or it can knockdown/kill. Avoid ground smash that spawns spikes under each player.",
                    "|cFFA500Selene’s Fangs (Spider)|r: Spawns after Bear dies. Again, tank must taunt quickly or it may one-shot non-tanks. Occasionally summons smaller spiders, kill them before they overrun you.",
                    "|cFF00FFSelene|r: Teleports & channels poison blasts that require an |cFF7F00INTERRUPT|r. She also throws a poison cone at a random player—dodge or block the initial hit. Spreads AoEs under each player: step out or block+break free when popped."
                },
            },

            {
                name = "Azureblight Lurcher",
                mechanics = {
                    "Triple Encounter: You must deplete the Lurcher’s health 3 times to damage Maarselok (above). Each depletion triggers an add phase & the Lurcher ‘recharges’ until ~70%.",
                    "|cFF0000Heavy Attack|r: Must be blocked or you risk a one-shot. The Lurcher also does conal ground attacks—tank face away from group.",
                    "Resource-Drain AoEs: The boss slams arms, spawning small blue circles around the area. Stepping in them drains Stamina & deals moderate damage. Move out!",
                    "Maarselok Fire: Occasional big line/breath from above—easy to avoid but do not let Lurcher stand in it or it enrages. Watch for add waves (Spriggans, Imps, Wolves) in between transitions."
                },
            },

            {
                name = "Azureblight Cancroid",
                mechanics = {
                    "Cancroid in middle is initially immune. Focus the |cFFA500Infestor Lurcher|r on the perimeter. Kill it, pick up synergy seed, deliver to Cancroid to break shield—use that burst window to dps Cancroid!",
                    "|cFF0000Stomp|r: Lurcher slams ground leaving a large untelegraphed circle that deals lethal DoT. Tank drag Lurcher away from it. Don’t stand in these circles!",
                    "Stranglers spawn after first vulnerable phase—(|cFFD700Kill them ASAP|r) or you get overwhelmed. Cancroid shield re-forms after ~20s, repeat mechanics until it’s dead."
                },
            },

            {
                name = "Maarselok",
                mechanics = {
                    "At 3 waves of spider-lings from Selene, each wave enough spiders to knock Maarselok down (80%->65%->50%). Essentially, you fight huge add waves while protecting Selene’s spider-lings from Stranglers & Hoarvors.",
                    "|cFFD700Stranglers|r: Appear in large numbers near walls—focus them with AoEs or they kill the spider-lings & prolong the fight indefinitely!",
                    "|cFF0000Hoarvors|r: Slowly crawl toward Selene, exploding if they reach her, stunning her & halting spider-lings. A player can stand near them to detonate harmlessly.",
                    "Adds: Lurchers, bears, archers, etc. keep tank busy. Once enough spiders reach the top, boss lands for ~20s. Burn him down each time. Repeats until 50% HP, then flees."
                },
            },

            {
                name = "Maarselok (Final Battle)",
                mechanics = {
                    "Fight starts at 50% HP (~12.5M). Hardmode reverts him to ~17.5M HP. Many wide AoEs & special mechanics.",
                    "|cFF0000Fus Ro Dah|r: Big knockback shout aimed at tank (block!) or whoever has aggro. Wing slaps & heavy conal breath can also devastate. Avoid wings, watch breath sweep, or dodge roll the hits.",
                    "Meteor Shower: Random flame orbs hitting arena. Then boss |cFF0000CHARGES|r from one side to the other, typically aimed at the tank’s position. Everyone else step aside. Tank should block the charge.",
                    "|cFFA500Seed Mechanic (non-HM)|r: A random player is cursed. They synergy on the lit pad to cleanse. Failure spawns a Lurcher.",
                    "|cFFA500Hard Mode|r: Selene is hostile, requires interrupting her poison barrages. She can be attacked to break her shield, then group synergy with the seed. 2 or 3 see the same pad, 1 sees a fake. The ‘odd man out’ must join the majority’s pad or they die. Tank or 3 vs 1 scenario. A lurcher spawns if you fail. Death roots must be destroyed before a res can occur."
                },
            },

        },
    },


    -------------------------------------------------------------------------------
    -- Icereach (zoneId=1152)
    -------------------------------------------------------------------------------
    [1152] = {
        normalId = 503,
        vetId    = 504,
        zoneId   = 1152,
        sets     = {472,473,478,471},
        questID  = 6414,
        HM       = 2541,
        SR       = 2542,
        ND       = 2543,
        TR       = 2546,
        name     = "Icereach",
        bosses = {

            {
                name = "Kjarg the Tuskscraper",
                mechanics = {
                    "Basic attacks: Simple frontal swings. Tank keep him turned away from group.",
                    "|cFF0000Enrage|r: Boss glows red, dealing massive damage. Tank should kite him to avoid hits—don’t try to face-tank!",
                    "Hammer Smash: heavy overhead slam with ice spikes in front—|cFF0000BLOCK/dodge|r or die.",
                    "Ice Tornado: slowly follows a random player. Kite it away, do not overlap on tank or group.",
                    "Ice Atronachs spawn at edge: |cFFD700Focus & kill|r them. If left alive too long, they root & bombard group with ice bolts.",
                },
            },

            {
                name = "Sister Skelga",
                mechanics = {
                    "Moves around, casts ice attacks. Tank keep her taunted & turned away.",
                    "Dark Tether on tank can’t be cleansed—just heal through it (cleansing triggers damage).",
                    "Fire Aura: placed under 1 random player—do NOT overlap or it kills group. If you want to use it offensively, stand near boss but watch your hp.",
                    "Stranglers: shielded by ice until ‘melted’ by the Fire Aura. Then kill quickly—these shoot high-damage ice bolts.",
                    "Cone/AoE attacks: typically small, avoid by standing behind her. She also uses lesser AoE under feet.",
                },
            },

            {
                name = "Vearogh the Shambler",
                mechanics = {
                    "A big Flesh Atronach covered by witches’ magic. Tank stand in front, group behind.",
                    "Heavy Attack & frontal swings—|cFF0000BLOCK|r or get one-shot. Fire waves also travel across arena—avoid/dodge them.",
                    "Summoning Circles spawn Wraiths, Skeletons or Zombies—(|cFFD700KILL quickly|r) or group gets overrun. Some Skele’s drain player resources with a tether.",
                    "Later in fight: rotating flame gusts swirl in arena—try to sidestep them or out-heal if your group is strong enough.",
                },
            },

            {
                name = "Stormborn Revenant",
                mechanics = {
                    "Many lightning & ice AoEs appear beneath players—keep moving, don’t stack. If you stand in them, you’ll likely die in Hard Mode especially.",
                    "Heavy Attack (long charge) can instantly kill a tank if unblocked or dps if not dodged. Keep watch on boss animation.",
                    "Jump Slam: boss leaps into air & lands, dealing huge damage in a small area—|cFF0000BLOCK or MOVE|r.",
                    "Storm Atronachs appear ~55% & ~40%—(|cFFD700Focus these|r) or they empower boss. Low HP but big group damage if ignored.",
                    "At ~35–40%, boss channels a big ice storm in the center—group up, pop heals/defensives or burn boss fast."
                },
            },

            {
                name = "Mother Ciannait (Icereach Coven)",
                mechanics = {
                    "4 witches + final 20% boss phase. Each witch gets vulnerable in turn, then random after first rotation. Each has sub-mechanics from previous fights!",
                    "|cFF7F00Witch 1: Gohlla|r spawns the Giant (Kjarg). If enraged, tank must kite. |cFFD700Kill giant first|r.",
                    "|cFF7F00Witch 2: Hiti|r spawns frozen Stranglers that require Fire Aura to melt—like Sister Skelga fight. Then kill them.",
                    "|cFF7F00Witch 3: Bani|r spawns wraiths, zombies, skeletons as in Vearogh fight. Eliminate them quickly.",
                    "|cFF7F00Witch 4: Maefyn|r spawns Icereach Warrior with Storm AoEs as in the ‘4th boss.’ Must kill warrior first.",
                    "Meanwhile, group has swirling wind (bear’s tornado), burning aura, lightning field, etc. from earlier bosses. Avoid or manage!",
                    "After 4 witches, |cFF0000Mother Ciannait|r channels a final phase with massive AoE in center. Burn her fast or she escalates DoT pulses. Survive with big heals if low dps!"
                },
            },

        },
    },


    -------------------------------------------------------------------------------
    -- Unhallowed Grave (zoneId=1153)
    -------------------------------------------------------------------------------
    [1153] = {
        normalId = 505,
        vetId    = 506,
        zoneId   = 1153,
        sets     = {476,479,474,475},
        questID  = 6416,
        HM       = 2551,
        SR       = 2552,
        ND       = 2553,
        TR       = 2555, 
        name     = "Unhallowed Grave",
        bosses = {

            {
                name = "Nabor the Forgotten (Secret Boss #1)",
                mechanics = {
                    "Boss stands in center platform; do not fall off the edges!",
                    "Big BOOM: Boss channels, unsafe platforms glow. Grapple to a safe spot or be killed by explosion.",
                    "Archers spawn around arena—|cFF7F00INTERRUPT|r or they 'Take Aim' and knock you off. They can be killed or controlled quickly.",
                    "Repeat each time boss channels. Watch your feet, and grapple carefully!",
                },
            },

            {
                name = "Hakgrym the Howler",
                mechanics = {
                    "|cFF0000Heavy Attack|r: Tank must BLOCK or be one-shot. Others must dodge roll if aimed at them.",
                    "Lich Crystals: AoE spikes from ground—move out before they explode.",
                    "Woeful Totem: Spawns at edge, shoots projectiles—(|cFFD700Kill quickly|r).",
                    "Flesh Abomination (~60% & 30%): Focus it; watch its large AoE slam and persistent ground effect.",
                    "|cFFA500Werewolf Transform|r at 0%: Gains 50% HP back, does line charges with skeleton spawns—kill adds and keep kiting or blocking boss slams.",
                },
            },

            {
                name = "Keeper of the Kiln",
                mechanics = {
                    "Sword arcs & cleaves—keep boss turned away. Tank block heavy attacks or dodge roll.",
                    "Adds spawn quickly if DPS is high—use AoEs or focus them so you don’t get overwhelmed.",
                    "|cFF0000Flames rising in vents!|r: Boss shields & big fire kills group if not solved. 3 group members grapple up to 3 vantage points. The synergy reveals correct floor sigil to lead boss onto. Once boss stabs sword on correct sigil, flames subside.",
                    "Archers overhead can pepper group with arrows—optional to kill if they’re causing trouble.",
                },
            },

            {
                name = "Eternal Aegis",
                mechanics = {
                    "Cone or line attacks with blade throws—dodge or block. They can knock back or do strong damage.",
                    "Blue “hurricane” AoE around boss—safe zone in middle. Or stay far out until it ends. Healer watch group HP if they stand outside the hurricane.",
                    "At health thresholds (90%,70%,50%,30%), boss summons 4 reflections spinning large AoEs around them. Avoid or quickly block—OR stack under boss with big heals/mitigation to burn them together.",
                    "Careful overlap with the boss’s spin AoE—stay behind or inside the 'safe ring' if you stack-burn.",
                },
            },

            {
                name = "Ondagore the Mad",
                mechanics = {
                    "Boss fairly low damage but spawns big Bone Colossus & wraith adds—(|cFFD700Focus Colossus|r). It has a lethal heavy if not blocking/dodged.",
                    "|cFF0000Inner Poison|r (~80% & ~35%): Boss channels poison in center—|cFFD700Grapple out|r to kill ghosts in outer ring. Then he reverts poison outward so you can come back in.",
                    "|cFF7F00Explosion Phase (~50% & ~15%)|r: Hide behind pillars or die to unstoppable blasts. Meanwhile kill 4 Menders powering him to end phase—group must be careful with each wave of blasts.  Boss eventually returns to normal.",
                    "Skeleton adds remain—finish them off between phases to reduce chaos!",
                },
            },

            {
                name = "Voria the Heart-Thief (Secret Boss #2)",
                mechanics = {
                    "Must have the 'Forgotten Strength' buff from Nabor’s Urn to see hidden grapple hooks leading to her.",
                    "Voria teleports away at ~75% & ~40%. Grapple quickly to chase her, break her shield, then |cFF7F00INTERRUPT|r or she escapes and you lose the fight.",
                    "Voria can become a Bone Goliath briefly. Keep dps on her. Watch out for basic AoE slams, but she’s not very threatening if tank has aggro.",
                    "|cFFD700If successful, get 'Voria’s Authority' from her urn to break next sealed door.|r",
                },
            },

            {
                name = "Voria’s Masterpiece (Secret Boss #3)",
                mechanics = {
                    "Access 'Voria’s Sanctum' door after defeating Voria. Grapple around the swampy arena—water is lethal poison or high DoT.",
                    "Boss remains center, occasionally stomps large AoEs that persist. Keep them stacked if possible to save space. Avoid standing in them!",
                    "Skeleton Adds: A 2H skeleton spawns after each stomp—tank or kill it quickly, or you’ll get overwhelmed. It can do huge heavy hits.",
                    "Ooze enemies spawn. You can kill them normally but if they are large (millions of HP) use Grapple to 'split' them until small enough to kill quickly.",
                    "Balance AoE + movement, kill adds, watch stomps, you’ll succeed. Loot final urn to get 'Abominable Bulwark' buff.",
                },
            },

            {
                name = "Kjalnar Tombskald (Final Boss)",
                mechanics = {
                    "|cFF0000Massive Attack|r: Very powerful heavy—tank MUST block or die. He also has ghosty hand stun on tank or random players.",
                    "Grave Dust: Kjalnar flings multiple arcs from the ground—magic damage unstoppable if not blocking. High resists or block recommended.",
                    "Cages (Hardmode): Summons bone cages under each player—|cFF0000GET OUT quickly|r before big explosion kills you.",
                    "Bone Mines: Spreads horns on ground as land mines—avoid stepping on them or big damage.",
                    "Summoning Fields: He spawns skeletons from each corner. If they reach center or a sigil, they power boss or explode. Kill them or cc them asap. A large 2H skeleton also tries to re-heal if it hits a center rune—must kill quickly or he regains full HP.",
                    "|cFF0000At 50% HP|r: Summons giant undead from edge: launching fire AoEs & frost breath. You cannot kill it—block or shield through the breath. Keep burning Kjalnar to end fight!"
                },
            },

        },
    },

    -------------------------------------------------------------------------------
    -- Stone Garden (zoneId=1197)
    -------------------------------------------------------------------------------
    [1197] = {
        normalId = 507,
        vetId    = 508,
        zoneId   = 1197,
        sets     = {516,517,518,534},
        questID  = 6505,
        HM       = 2755,
        SR       = 2697,
        ND       = 2698,
        TR       = 2701,
        name     = "Stone Garden",
        bosses = {

            {
                name = "Exarch Kraglen",
                mechanics = {
                    "|cFF0000Heavy Attack|r – Must be BLOCKED or it can one-shot a tank; DPS/Healer must DODGE roll if aimed at them.",
                    "|cFF7F00Swipe (Frontal)|r – Quick succession frontal slashes; tank keep him faced away from group and block as needed.",
                    "|cFF0000Fear + Interrupt|r – He knocks everyone back, then channels a big AoE. BREAK FREE and quickly INTERRUPT to prevent lethal damage.",
                    "|cFF0000Stomp AoE|r – After interrupting, he stomps the ground with a wide circle. Step out and then move back in.",
                    "|cFFFF00Charging Mechanic|r – If group stands too far away, boss charges at them, dealing huge damage. Stay near him after the stomp to avoid it."
                },
            },

            {
                name = "Stone Behemoth",
                mechanics = {
                    "|cFF0000Heavy Attack|r – Boss slowly winds up a punch. TANK must BLOCK; others DODGE if targeted.",
                    "|cFF00FFLightning Phase|r – Everyone gets expanding AoEs under their feet. Spread out or BLOCK to reduce damage.",
                    "|cFF0000Fire Phase|r – Hurls fireballs, then channels a huge fire ring across the floor—MOVE out or die.",
                    "|c00FFFFIce Phase|r – Group is snared. DODGE ROLL or BREAK FREE. You drop small ice circles—place them carefully. Boss stuns again—don’t stand in leftover ice.",
                    "|cFF7F00Mini Behemoths|r – Up to three small husks appear, draining resources. KILL them or they’ll stack up, especially at low health."
                },
            },

            {
                name = "Arkasis the Mad Alchemist",
                mechanics = {

                    "|cFF0000PHASE 1 – Fire (100%→60%)|r: Three fire AoEs under tank every ~10s—step away each pop. Adds spawn at 90/80/70…%—|cFFD700Kill quickly|r to prevent magma shell.",

                    "|cFFA500WEREWOLF PHASE 1 (60%)|r: Everyone transforms. Four Stone Husks appear—TAUNT & #3 INTERRUPT them. Use #4 STOMP for lightning mines & #2 GAP-CLOSER as needed. Kill orbs fast.",

                    "|cFF0000PHASE 2 – Poison (60%→20%)|r: Now throws poison flasks that spin. BLOCK or DODGE. Adds again every 10%. Move minimally to avoid overlapping AoEs if you’re too close.",

                    "|cFFA500WEREWOLF PHASE 2 (20%)|r: Same mechanics, but some Husks mark you (screen grey). Swap with another Husks or be one-shot. #2 Gap-close to partner, re-taunt. Also kill hoarvors/orbs if they spawn.",

                    "|cFF00FFPHASE 3 – Lightning (20%→0%)|r: In Hard Mode, boss might regain HP (~50%). Group gets big lightning AoEs chasing them—run together to free pinned players via synergy. Kill Dire-Maw/adds first. Repeat until dead!",

                    "|cFF0000Hard Mode|r: Boss ~18M HP, spawns a giant Bat in Werewolf phases—instant kill if it touches you. Must use Hemoglobin synergy to remove Bat’s shield. More dangerous bombs/flasks, shorter phases. Survive with coordinated kills!"
                },
            },

        },
    },

    


    -------------------------------------------------------------------------------
    -- Castle Thorn (zoneId=1201)
    -------------------------------------------------------------------------------
    [1201] = {
        normalId = 509,
        vetId    = 510,
        zoneId   = 1201,
        sets     = {535,513,514,515},
        questID  = 6507,
        HM       = 2706,
        SR       = 2707,
        ND       = 2708,
        TR       = 2710,
        name     = "Castle Thorn",
        bosses = {

            {
                name = "Dread Tindulra",
                mechanics = {
                    "|cFF0000Fire Breath|r – Cone AoE on the tank, block or step aside. Everyone else stay behind boss.",
                    "|cFFA500Fire Puddles|r – Spat onto floor, don’t stand in them. They explode if boss stomps!",
                    "|cFF7F00Pin/Jump|r – She jumps at a random player and stuns them. |cFF7F00INTERRUPT|r boss or pinned ally dies!",
                    "|cFF0000Spawn Adds|r – Death Hound Broodlings appear after ~75%. Kill them quickly or risk overwhelm."
                },
            },

            {
                name = "Blood Twilight",
                mechanics = {
                    "|cFF0000Heavy Attack|r – Large swipe or teleport smash. Tank block; if aimed at DPS, dodge roll.",
                    "|cFFA500Blood Channelers|r – Four small adds empower the boss. Kill them to remove buff.",
                    "|cFF0000Blood Pool Phase|r – Boss hovers mid-room with lethal AoE below. Move out. Reanimated Vampire spawns—focus it! Also watch for spirit illusions that can knock you into the pool.",
                },
            },

            {
                name = "Vaduroth",
                mechanics = {
                    "|cFF0000Heavy Attack|r – Block or die. Big scythe swing on tank or unlucky target.",
                    "|cFF7F00Scythe Throw|r – At 75/50/25%, boss hurls scythe out. Everyone’s pulled in. You each get an AoE—spread out or wipe!",
                    "|cFFA500Reanimated Vampire|r – Spawns after each scythe throw. Must be killed ASAP or it hits too hard.",
                    "|cFFA500Virulent Viscera|r – Summoned purple glob add. Ranged projectile; kill or it becomes annoying.",
                    "|cFF0000Mini Batswarm|r – Floats around. Don’t get caught; it deals high DoT if it touches you.",
                },
            },

            {
                name = "Talfyg",
                mechanics = {
                    "|cFF0000Heavy Attack|r – Devastating double-swipe. Tank must block or dodge roll. Others can’t survive it.",
                    "|cFFA500Ground Smash|r – Places large blood AoE on floor. Step out; it deals massive damage over time.",
                    "|cFFD700Gargoyles|r – They awaken in waves. Kill them quickly or risk major trouble (fire or ice). Don’t overburn boss ignoring these.",
                    "|cFF0000Deadly Beam|r – At low HP, boss raises hand & fires a beam. Move or block. Repeats until boss dies. Spread out!",
                },
            },

            {
                name = "Lady Thorn",
                mechanics = {
                    "|cFF0000Heavy Attack|r – Must be BLOCKED or you die. She can also vanish & charge a random target.",
                    "|cFF7F00Bombs|r – Summons multiple bombs in lines or random spots. Step away or you’ll blow up.",
                    "|cFFA500Bat Swarm (Stationary)|r – Fills the room with bats, leaving a green safe zone. Must get inside quickly or die. She continues normal attacks here!",
                    "|cFF0000Bat Swarm (Moving)|r – At 60% & 20%. The safe zone moves around, follow it. Adds spawn: kill the Guardian & scamps dropping synergy. Throw 4 corruptions at boss to end the phase.",
                    "|cFF0000Teleport Punch|r – She disappears & reappears on a random player with a lethal blow. BLOCK or DODGE or die.",
                    "|cFF7F00Execute (Hard Mode)|r – After 20% swarm, it remains. Fight boss inside the moving circle, plus bombs, heavy attacks, & charges. No final change if not Hard Mode, but more HP/damage. Survive until kill!"
                },
            },

        },
    },


    -------------------------------------------------------------------------------
    -- 19) Black Drake Villa (zoneId=1228)
    -------------------------------------------------------------------------------
    [1228] = {
        normalId = 591,
        vetId    = 592,
        zoneId   = 1228,
        sets     = {569,570,571,577},
        questID  = 6576,
        HM       = 2833,
        SR       = 2834,
        ND       = 2835,
        TR       = 2838,
        name     = "Black Drake Villa",
        bosses = {

            {
                name = "Avatar of Zeal",
                mechanics = {
                    "|cFF0000Mind Blast|r – Rears up and channels a frontal frost beam. Tank: face boss away so group isn’t hit.",
                    "|cFF7F00Spectral Indriks|r – Summons 3 ghostly indriks that stun if not blocked/dodged.",
                    "|cFFA500Teleport|r – Moves around the room; tank re-taunt quickly to keep it turned away.",
                    "|cFF0000Freezing Vortex|r – Places a small AoE on a random player. Spread out to avoid overlap.",
                },
            },

            {
                name = "Avatar of Vigor",
                mechanics = {
                    "|cFF0000Heavy Attack|r – Winds up a crystal overhead; must be blocked or it can one-shot a non-tank.",
                    "|cFF7F00Geysers|r – Three small AoEs form under players; move away before they erupt.",
                    "|cFFFFFFSimple fight|r – Keep the boss turned away, watch for adds if any spawn from prior events.",
                },
            },

            {
                name = "Avatar of Fortitude",
                mechanics = {
                    "|cFF0000Heavy/Light Attacks|r – Block the overhead smash or risk high damage.",
                    "|c00FFFFIce Channel|r – A dangerous, uninterruptible beam. Healer must out-heal or shield the group.",
                    "|cFF0000Rare Ground Ice|r – Occasional ice patches appear under players; simply move out.",
                },
            },

            {
                name = "Kinras Ironeye",
                mechanics = {
                    "|cFF0000Triple Fire|r – Boss faces tank and launches 3 ground flames in a row. Tank keep him away from group.",
                    "|cFF0000Heavy Attack|r – Mace swing or large fireball (unarmed). Tank must BLOCK or DPS/healer DODGE roll.",
                    "|cFFD700Fiery Totem|r – Spawns a totem throwing fireballs at the group. (|cFFD700KILL|r quickly or taunt it.)",
                    "|cFF7F00Roar/Salamanders|r – Salamanders spawn with a flame aura buffing the boss. Interrupt the roar or they empower him.",
                    "|cFFA500Phase Shift|r – Throws weapon aside, shifting to unarmed. New attacks: rock spikes, fiery fissures. Keep moving.",
                    "|cFF0000Volcanic Smash (HM)|r – Creates a mini-volcano. Tank stands on it BLOCKING to protect group.",
                    "|cFF7F00Chains (HM)|r – Boss locks 2 players with growing AoEs. |cFF7F00INTERRUPT|r boss & move out fast after release!",
                    "|c00FFFFIce Avatar Synergy|r – Use it to freeze salamanders or debuff boss. Time your whiteout synergy for stuns/heals.",
                },
            },

            {
                name = "Captain Geminus",
                mechanics = {
                    "|cFF0000Heavy Attack|r – Charged jump-stab or shot; block or dodge or die.",
                    "|cFFA500Lightning Mines|r – Scattered around the arena; dodge roll through or avoid stepping on them.",
                    "|cFF7F00Shade of Geminus|r – Up to four archers appear, channeling massive AoE on a player. |cFF7F00INTERRUPT|r them ASAP!",
                    "|cFF0000Invulnerability Phase|r – At ~70% & 30%, boss goes center, spamming fire lines. An Air Atronach spawns—kill it, break shield!",
                    "|cFF0000Teleport Stomp|r – Leaps to a player and slams the ground in a large AoE. Spread out & dodge or block!",
                    "|cFFD700Fire Hounds|r – Spawn after first shield. Tank taunt them, DPS focus them (2+ can overwhelm).",
                    "|cFF0000Double Cleave & Bleed|r – Large frontal swings at the tank. Don’t spin boss around or group will get 1-shot.",
                    "|c00FFFFIce Plate|r – Use synergy to freeze Shades or boss. Whiteout can interrupt key attacks like the stomp.",
                },
            },

            {
                name = "Pyroturge Encratis",
                mechanics = {
                    "|cFF0000Heavy Attack|r – Spinning kick or sword slash. Must be blocked or it knocks you flat.",
                    "|cFFA500Flaming Vortex|r – Boss channels a fiery ring at his feet—get out or die! Summons flame ghosts.",
                    "|cFF7F00Salamander Flame|r – Flame breath transforms into salamanders that chase random players & explode.",
                    "|cFF0000Firestorm|r – Room-wide flames except boss center. Summons a Fire Behemoth—tank it away & kill quickly!",
                    "|cFF0000Phase 2 (60%→~75%)|r – Boss flees to second arena, gains a flaming sword & teleports more frequently. Watch new AoEs.",
                    "|cFF0000Heartsfire Spear|r – Throws sword at tank or random target, bursting into a cone behind them. BLOCK or else massive damage.",
                    "|cFFD700Use Geysers|r – Second arena: jump down to avoid the inferno, or use geyser to rejoin the safe zone around boss.",
                    "|cFF0000Salamander Pit|r – Middle pit spawns salamanders repeatedly—ignore or kill if they harass you below.",
                    "|cFF0000Flurry/Cleave|r – Frontal combos that can kill DPS/healers instantly. Tank keep boss faced away.",
                    "|c00FFFFIce Synergy|r – Cancels Firestorm or vortex if timed well. Stuns boss & resurrects allies. Huge advantage on HM.",
                },
            },

            {
                name = "Sentinel Aksalaz",
                mechanics = {
                    "|cFFD700Requires all secrets + 30 fragments each (5 attempts)|r – Stand prepared, no sloppy wipes.",
                    "|cFF0000Heavy Attack|r – Giant axe swing, block or die instantly.",
                    "|cFF7F00Ground Icicles|r – Axe slam triggers 3 chasing ice spikes per player. Keep moving.",
                    "|cFFA500Frost Nova|r – Center cast with whirling outer tornados. Hide in safe spots or be one-shot.",
                    "|cFFD700Avatars Summoned|r – At 85/60/35% HP, Avatars of Zeal/Vigor/Fortitude appear. Full mechanics, kill them in turn.",
                    "|cFF7F00Frostkin Adds|r – Low HP but can swarm you. Focus them if too many stack up.",
                    "|cFF0000Execute ~25%|r – Arena shrinks with constant ice storm. Projectiles from grates fill gaps, watch your feet.",
                    "|cFF0000Hard Mode|r – Gains Ice Meteor & Frostbite DoTs on certain moves. Spread out meteor hits. High healing needed.",
                },
            },

        },
    },


    -------------------------------------------------------------------------------
    -- 20) The Cauldron (zoneId=1229)
    -------------------------------------------------------------------------------
    [1229] = {
        normalId = 593,
        vetId    = 594,
        zoneId   = 1229,
        sets     = {572,573,574,578},
        questID  = 6578,
        HM       = 2843,
        SR       = 2844,
        ND       = 2845,
        TR       = 2847,
        name     = "The Cauldron",
        bosses = {

            {
                name = "Oxblood the Depraved",
                mechanics = {
                    "|cFF0000Heavy Attack|r – Winds up both arms for a slam; tank must BLOCK or DPS/healer DODGE roll.",
                    "|cFF7F00Toxic Flatulence|r – Turns around and releases 3 poison gas clouds that slowly expand outward in a triangle.",
                    "|cFFA500Summon Globs|r – Spawns red (Gore) and green (Bile) globs. Red globs shoot, green ones crawl to boss. Kill them or boss either enrages or heals.",
                    "|cFF0000Poison Cage|r – Traps a random player in a cage. Other members must DPS it quickly or victim dies.",
                    "|cFF7F00Charge|r – When enraged from red globs, boss charges a random player, dealing massive damage if not blocked/dodged.",
                    "|cFF0000Exploding Chains|r – Chains under each player explode in succession thrice. Keep moving to avoid big hits.",
                },
            },

            {
                name = "Taskmaster Viccia",
                mechanics = {
                    "|cFF0000Heavy Attack|r – An upward strike or staff swipe; BLOCK or die. If off-tank target, DODGE roll!",
                    "|cFFA500Lightning Mines|r – Several shock mines appear. They stun on contact; you can dodge roll through or let Drathas negate some.",
                    "|cFF7F00Channeled Lightning|r – Targets a random player with a lethal beam; must be |cFF7F00INTERRUPT|r quickly.",
                    "|cFF0000Large AoE Circle|r – Boss channels a big ground-smash circle. Move out & tank relocate boss slightly.",
                    "|cFFD700Add Waves|r – Spawn at ~75%, ~50%, ~25%. Dremora archers, casters. Kill them or get overwhelmed.",
                    "|cFF0000Chain Pull|r – Randomly drags a distant player in. If a lightning mine is in the path, you may be dragged through it. Stay mindful of positions.",
                },
            },

            {
                name = "Molten Guardian",
                mechanics = {
                    "|cFF0000Heavy Attack|r – Slams ground, leaving a lava pool AoE. Tank block & step aside after impact.",
                    "|cFFA500Flame Volley|r – Rains fireballs around the arena, leaving small burn patches. Keep moving.",
                    "|cFF7F00Channeled Blast|r – Boss channels a heavy group-wide DoT. Must |cFF7F00INTERRUPT|r or your party suffers extreme damage.",
                    "|cFF0000Teleport|r – Boss disappears under lava & reappears on another edge, spawning two molten fiend adds. Always kill these adds first.",
                    "|cFF0000Nova Smash|r – Big explosion with large radius. Get out or block/dodge at the last moment.",
                    "|cFFD700Stacking Fire Debuff|r – Each fireball hit adds a stacking debuff increasing fire damage taken. Avoid or block these projectiles.",
                },
            },

            {
                name = "Rescue Lyranth (Daedric Encounter)",
                mechanics = {
                    "|cFF7F00Destroy Power Modules|r – Use synergy with the oil to connect modules to Lyranth’s barrier. Lyranth ignites them. Each destroyed module spawns a wave of Daedra.",
                    "|cFFD700Multiple Waves|r – Bone Colossus, Daedroth, Titan, Ogrims, Archers. Deal with priority adds first: Xyvkin Archers & large Daedra.",
                    "|cFF0000Xyvkin Archers|r – Very lethal single-target hits. Tank must taunt them fast & DPS kill them first.",
                    "|cFFA500Storm Atronachs|r – Explode on death. Stay clear as they self-destruct.",
                    "|cFF0000All Modules Down|r – Final wave includes a Flame Titan. Survive all to free Lyranth & complete this section.",
                },
            },

            {
                name = "Baron Zaudrus",
                mechanics = {
                    "|cFF0000Heavy Attack|r – Massive hammer slam. Tank must BLOCK or get one-shot. Summons molten pillars on impact.",
                    "|cFFA500Molten Pillars|r – Environmental obstructions. If |cFF7F00Ash Vent|r beam destroys them, Daedroth adds spawn. If |c00FFFFCold-Flame synergy|r destroys them, friendly atronachs spawn instead!",
                    "|cFF7F00Galvanic Blow|r – Wide frontal cone. Anyone hit gets a lightning DoT circle—|cFF0000DON’T stack|r or do big group damage.",
                    "|cFF0000Ash Vent|r – Walls of flame orbit the arena. Avoid or be instantly killed. Also can break pillars, summoning Daedroths if not cautious.",
                    "|cFFA500Fire Geysers|r – Random flame circles on the ground, keep moving. Stalactites may also drop from ceiling.",
                    "|cFFD700Cold-Flame Infusion|r – Lyranth synergy buff to kill pillars or quickly burn boss/adds. Summons ally atronachs if pillars are destroyed by it.",
                    "|cFF0000Hard Mode|r – Boss HP/damage greatly increased. Additional hammer throw lava patches & more frequent add spawns. Avoid stacked AoEs!",
                },
            },

        },
    },


    -------------------------------------------------------------------------------
    -- 21) Red Petal Bastion (zoneId=1267)
    -------------------------------------------------------------------------------
    [1267] = {
        normalId = 595,
        vetId    = 596,
        zoneId   = 1267,
        sets     = {608,605,606,607},
        questID  = 6683,
        HM       = 3018,
        SR       = 3019,
        ND       = 3020,
        TR       = 3023,
        name     = "Red Petal Bastion",
        bosses = {

            {
                name = "Wraith of Crows (secret boss #1)",
                mechanics = {
                    "|cFFD700Add Waves|r – Before the boss spawns, two waves of ~3–6 Daedra appear. Tank gather them; DPS kill quickly.",
                    "|cFF0000Crow Storm|r – Targets a random player with a crow-infested AoE. Kite away from group or you risk heavy damage.",
                    "|cFF7F00Dark Bolts|r – Fires bolts under each player. They pop quickly, so step aside or block to reduce harm.",
                },
            },

            {
                name = "Rogerain the Sly",
                mechanics = {
                    "|cFF0000Heavy Attack|r – Winds up staff, unleashes swirling or electric attacks. Tank block or DPS/healer dodge roll.",
                    "|cFFA500Unspeakable Void|r – Large ground circle at a player’s location. Move out fast or take lethal damage.",
                    "|cFF0000Belly Buster|r – Within the void, 8 smaller AoEs radiate out. Keep sidestepping to avoid stuns/damage.",
                    "|cFF7F00Chaos Gate|r – Spawns a portal summoning small Daedra (Spiders, Hoppers, Watchers). Kill the portal first to stop adds.",
                    "|cFF0000Goatification|r – Random player becomes a goat, able to eat |cFFD700Sweetrolls|r (for buffs & group heal) or charge the Chaos Gate for high damage. Use your form wisely!",
                    "|cFFA500Poison Splats|r – Drops small AoEs or bigger on players. Spread out & block if you’re about to explode them.",
                    "|cFFD700Frogs & Daedric Adds|r – Summoned regularly; kill them to avoid chaos. Don’t let them accumulate.",
                    "|cFF0000Hard Mode|r – Same mechanics, boss has higher HP/damage. Control the adds & coordinate goat synergy for success.",
                },
            },

            {
                name = "Spider Daedra (secret boss #2)",
                mechanics = {
                    "|cFFD700Add Waves|r – Two sets of ~3–6 mobs before the boss appears. Tank hold them, DPS focus down adds quickly.",
                    "|cFF0000Heavy Attack|r – A direct smash at the tank, block recommended. Non-tanks must dodge or die.",
                    "|cFF7F00Lightning Shots|r – Two players get lightning arcs overhead. Either block or move to avoid the impact.",
                    "|cFFA500Spit|r – Boss spits at a random target. If aimed at you, dodge roll or step aside in time.",
                },
            },

            {
                name = "Artifact Bearers: Eliam Merick, Ihudir, Liramindrel",
                mechanics = {
                    "|cFF0000Heavy Attacks|r – Basic hits for the tank to block. Non-tanks dodgeroll or die if taunt is lost.",
                    "|cFF7F00Sparta Kick|r – Boss tries to kick the tank with a follow-up AoE. Even if blocked, you get knocked back slightly. Brace for next move!",
                    "|cFF0000Lightning Fields|r – Large shock AoEs appear on ground. Don’t stack and move out quickly.",
                    "|cFFA500Charge|r – Boss rushes at the tank. BLOCK or roll; dps/healers will likely be 1-shot if caught.",
                    "|cFFD700Miniboss Adds|r – At ~80% Archer spawns, at ~50% the 2H fighter spawns. Interrupt him or he’ll enrage enemies. Kill them each time or they’ll complicate the fight.",
                    "|cFF0000At 30%|r – Both adds return together. Normal vet: you can kill them again or burn the boss. |cFF0000Hard Mode|r: They become unkillable at execute. Tank must manage them; DPS focus on boss (no partial kills).",
                },
            },

            {
                name = "Grevious Twilight (secret boss #3)",
                mechanics = {
                    "|cFFD700Add Waves|r – Two pre-fight waves of ~3–6 daedra. Same approach: tank gather, DPS burn them quickly.",
                    "|cFF0000Heavy Attack|r – Big strike at tank, block or risk lethal damage. Others must dodge if targeted.",
                    "|cFF7F00Machine Gun Bolts|r – Rapid orbs directed at a player (similar to Lord Warden in ICP). Tank stand in line to block them safely if aimed at a DPS/healer.",
                    "|cFF0000Meteors|r – Each player gets a meteor overhead. Spread out & block or dodge the impact. Don’t overlap or the group dies fast.",
                },
            },

            {
                name = "Prior Thierric Sarazen",
                mechanics = {
                    "|cFF0000Sparta Kick|r – Kicks tank with a small ground AoE. Even if blocked, knocks you slightly. Be ready for immediate follow-up.",
                    "|cFF7F00Heavy Attack/Cleave|r – Large frontal swing. Tank must block; DPS/healers behind boss or get destroyed.",
                    "|cFF0000Ground Spikes|r – Boss channels: each player sees 4 small AoEs underfoot. Move carefully so they don’t overlap. Avoid or block each pop.",
                    "|cFF7F00Teleport Spike|r – Boss warps away, a random player is marked. Must be |cFF7F00INTERRUPT|r quickly or that player is one-shot by a spike from below (~300k+).",
                    "|cFFD700Add Waves|r – A steady flow of Daedra & Nords: kill them first! They can heal or stun. No DPS check on boss, so clear adds or be overwhelmed.",
                    "|cFFA500Healing Circles|r – He drops large runic circles healing him & hurting you. Don’t let boss stand in them, and don’t stand in them yourself.",
                    "|cFF0000Stun Walls|r – Walls of AoEs slide across the arena in sets of ~3–4. Find the gap and move through, or you’ll be knocked/stunned + big damage.",
                    "|cFF7F00Blade Tempest (low HP)|r – Summons slow whirlwinds. Simply watch your feet and avoid them.",
                    "|cFF0000Hard Mode|r – More HP/damage. Teleport Spike gains a shield, forcing you to run inside the bubble to interrupt. Additional stun orbs from prior bosses’ mechanics. Keep calm, kill adds, and block everything!",
                },
            },

        },
    },


    -------------------------------------------------------------------------------
    -- 22) The Dread Cellar (zoneId=1268)
    -------------------------------------------------------------------------------
    [1268] = {
        normalId = 597,
        vetId    = 598,
        zoneId   = 1268,
        sets     = {604,609,602,603},
        questID  = 6685,
        HM       = 3028,
        SR       = 3029,
        ND       = 3030,
        TR       = 3032,
        name     = "The Dread Cellar",
        bosses = {

            {
                name = "Purgator (secret boss #1)",
                mechanics = {
                    "|cFF0000Heavy Attack|r – Boss charges hammer overhead; tank BLOCK or other roles dodge or die.",
                    "|cFFD700Flame Atronachs|r – Spawn repeatedly. They drop fire AoEs on the ground. Kill or tank them away from group if damage is high.",
                    "|cFF7F00Meteors|r – Each player gets a meteor on them—spread out & block/dodge. Do NOT stack or instant wipe.",
                },
            },

            {
                name = "Scorion Broodlord",
                mechanics = {
                    "|cFF0000Heavy Attack|r – Big overhead slam. Tank must block or be knocked down/killed.",
                    "|cFFA500Agonymium Stones|r – Need to be destroyed or boss absorbs them, healing or buffing. Stack adds near stones to cleave them together.",
                    "|cFF7F00Totem / Pillar|r – Teleports to siphon a pillar. Kill it quickly to stop groupwide damage. Watch for Xivkyn or other add spawns.",
                    "|cFF0000Cone AoE (Turmoil)|r – Turn boss away from group. If you get caught, high damage is likely lethal.",
                    "|cFFD700Multiple Adds|r – Xivkyn Berserkers/Mages & others spawn in waves. Priority them before focusing boss further.",
                    "|cFF0000Pull + Explosion|r – If boss consumes a stone, pulls group in and slows them. Dodge out before big blast.",
                    "|cFF0000Curse & DoTs|r – Watch health bars; Healer keep big heals going. The boss can’t be purged off. Survive with synergy.",
                    "|cFF0000Hard Mode|r – Extra Bone Colossus & Daedroth spawns; focus them first or they’ll wipe the team. Pillar priority remains the same.",
                },
            },

            {
                name = "Undertaker (secret boss #2)",
                mechanics = {
                    "|cFF0000Heavy Attack|r – Overhead staff slam; must be blocked or tank gets flattened.",
                    "|cFFA500Add Spawns|r – Skeletal archers & other undead appear throughout. Kill them if they stack up dangerously.",
                    "|cFF7F00Lich Crystals|r – Many explosive crystal bombs on ground—avoid or they’ll do big DoT. They vanish after a short time.",
                    "|cFF0000Large AOE Burst|r – Undertaker channels a spreading circle. Step out quickly or block if you’re in trouble.",
                },
            },

            {
                name = "Cyronin Artellian",
                mechanics = {
                    "|cFF0000Heavy Attack|r – Staff wind-up. Tank blocks or DPS/healers must dodge or die instantly.",
                    "|cFF7F00Lightning Winds|r – Boss spins staff, sending out swirling shock lines. Move or block to mitigate hits.",
                    "|cFFD700Storm Atronachs|r – Summoned adds. Must kill or keep them interrupted. Boss can revive them if the fight drags on.",
                    "|cFFA500Boltwyrm|r – Slows players, channels Arresting Bolt. If aimed at you, do extra damage to it, or kill quickly.",
                    "|cFF0000Skull Projectiles|r – Boss channels red ghost skulls. Dodge roll or block if aimed at you or it’s lethal.",
                    "|cFF0000Red Waves (Dread Surge)|r – Large sweeping waves from the edges. Find the gaps or be killed. On Hard Mode, they one-shot!",
                    "|cFF7F00HM: Extra Debuffs|r – Two players get thunder lines leaving shock AoEs behind. Spread out to place them safely.",
                },
            },

            {
                name = "Grim Warden (secret boss #3)",
                mechanics = {
                    "|cFF0000Heavy Attack|r – Must be blocked by tank. Others dodge if you pull aggro by accident.",
                    "|cFF7F00Spinner Attack|r – Boss spins scythe 360°, lethal if you stand in it. Tank must keep taunt & slowly back away or side-step while spinning.",
                    "|cFFA500Add Spawns|r – Twilight or lesser adds appear. If too many build up, boss becomes immune; kill a couple to remove immunity.",
                    "|cFFFF00Wind Auras|r – One or two swirling wind orbs chase random players—kite away from group or risk big AoE damage.",
                },
            },

            {
                name = "Magma Incarnate",
                mechanics = {
                    "|cFF0000Heavy Attack (Frenzy)|r – Multiple strikes. Tank block to survive. Very lethal if you fail.",
                    "|cFFA500Channel Circle|r – Incarnate stabs swords down, forming a large orange circle. Tank must stand in & BLOCK to protect group from pulsing damage.",
                    "|cFF7F003-Beam Mechanic|r – Three players get beams. After 3s, each gets a big fire DoT. Spread so they don’t stack up or it’s double damage!",
                    "|cFF0000BIG BOOM|r – Room-wide AoE. Block/dodge or run out. Tank can soak it with block. DPS/healer can step away safely.",
                    "|cFFD700Scamps|r – Spawn in waves of ~4. Must kill them quickly or they stack lethal fire damage. Tank gather; DPS burn them ASAP.",
                    "|cFF0000Portal Phases|r – At ~60% & 30%, boss shields & becomes immune. Enter portal to destroy a totem in a mini arena with unique hazards. Succeed to avoid boss enrage buffs!",
                    "|cFFA500Post-Portal Winds|r – Additional swirling or traveling flame walls appear. Watch for the single gap if they circle the arena. Don’t panic!",
                    "|cFF0000Hard Mode|r – Each time you exit a portal, a large spider add spawns with ~2.5M HP. Tank must taunt & group kills it first. Also beam lines drop flame AoEs on the floor. Spread them carefully!",
                },
            },

        },
    },


    -------------------------------------------------------------------------------
    -- 23) Coral Aerie (zoneId=1301)
    -------------------------------------------------------------------------------
    [1301] = {
        normalId = 599,
        vetId    = 600,
        zoneId   = 1301,
        sets     = {632,619,620,621},
        questID  = 6740,
        HM       = 3153,
        SR       = 3107,
        ND       = 3108,
        TR       = 3111,
        name     = "Coral Aerie",
        bosses = {

            
            {
                name = "Sword Guardian",
                mechanics = {
                    "|cFF0000Cleave Shock|r – Boss winds up a cleave, hitting the tank. Group members each gain a lightning AoE circle—spread out to avoid overlapping damage.",
                    "|cFF7F00Heavy Swings/Stomp|r – Multiple heavy attacks & slams. Tank BLOCK them, minimal movement needed if formation is stable.",
                },
            },

            
            {
                name = "Maligalig",
                mechanics = {
                    "|cFF0000Heavy Attack|r – Double-arm stab. Tank must BLOCK or get knocked down/one-shot. DPS/healers must dodge if targeted.",
                    "|cFF7F00Storm Cell|r – Negative AoE on a player. Move it into the 'Donut' storm swirling around the arena to disperse it. Failing so = lethal!",
                    "|cFFA500Yaghra Larva|r – Exploding bugs chase marked players; dodge roll or kill them quickly before detonation.",
                    "|cFFD700Surging Waters (70% & 35%)|r – Room floods, flushing everyone around. Use synergy to jump onto mini-islands & kill 'Ripples' + adds. Tank first, then group follows. Kill each platform’s ripple to resume fight.",
                    "|cFF0000Hard Mode Addition|r – 'Building Static' in water phases. Prolonged platform time = heavier dot. Jump into water to clear static stacks, but water also does damage. Manage heals & repeated jumps to handle each platform safely.",
                },
            },

            
            {
                name = "Staff Guardian",
                mechanics = {
                    "|cFF0000Heavy Attacks|r – Channeled staff hits. Tank blocks or dodge as DPS if targeted. Leaves a minor DoT sometimes.",
                    "|cFFA500Large Ground AoEs|r – Periodically places big traps on the floor—easily avoidable by staying mobile or stacked near boss.",
                    "|cFF0000Meteor Teleport|r – Boss teleports to corners, removing old traps but placing new ones. Shift position accordingly.",
                },
            },

            
            {
                name = "S’zarzo the Bulwark",
                mechanics = {
                    "|cFF0000Heavy Attack|r – Shield strike. Tank block to avoid knockdown. Non-tank must dodge or face lethal damage.",
                    "|cFFA500Banner|r – DK-like standard placed. Move boss out, don’t let it stand in the banner or it gains damage.",
                    "|cFF7F00Add Waves|r – ~4 archers or warriors spawn. Pull them in, kill them fast before returning to boss.",
                    "|cFF0000Popcorn AoEs|r – S’zarzo channels multiple fast AoE pops under each player (3 times). Don’t run around; simply BLOCK all 3 hits or step aside carefully.",
                },
            },

            
            {
                name = "Sarydil",
                mechanics = {
                    "|cFF0000Assault/Brand|r – Quick teleport strike + heavy follow-up. Tank keep taunt, block or DPS/healers must dodge roll if targeted.",
                    "|cFFA500Dash Mines|r – Boss leaps across room leaving mines. Watch your feet & shift to new location. Don’t step on them!",
                    "|cFF7F00Throwing Daggers|r – After dashing, channels dagger barrage. |cFF7F00INTERRUPT|r ASAP or lethal to group.",
                    "|cFF0000BIG BOOM|r – Expanding AoE after backflip. Either block or dodge at last moment. Remaining placed mines also explode then!",
                    "|cFFD700Marked (Traps)|r – A random player drops multiple ground traps for several seconds. Run to empty space to safely place them away from the group.",
                    "|cFF7F00Add Phases (70%/40%)|r – Boss vanishes, spawns ~4 adds (archers, Summoner, etc.). Last wave adds a 'Bulwark' mini-boss. Kill them or get overwhelmed. Then Sarydil reappears.",
                    "|cFF0000Shadows/Illusions|r – She duplicates around the edges. Find & interrupt the real one or face devastating hits if not stopped quickly.",
                    "|cFF0000Hard Mode|r – Additional Ascendant Stormshapers spawn, must be |cFF7F00INTERRUPT|r constantly if not killed. Marked mechanic affects all players each add phase. Clear quickly to limit mine chaos. Survive or wipe!",
                },
            },

            
            {
                name = "Shield Guardian",
                mechanics = {
                    "|cFF0000Heavy Attacks|r – Strong shield slams. Tank block to avoid big hits. Others must not take aggro or be crushed.",
                    "|cFFA500Shield Phase (~65%, 25%)|r – Guardian crouches, becoming invulnerable. 3 adds channel energy into shield—kill them to break it. Repeat if it occurs again. Then resume fight as normal.",
                },
            },

            
            {
                name = "Varallion",
                mechanics = {
                    "|cFF0000Heavy Attack (Obliterate)|r – Not extremely strong, but recommended block for safety. If DPS/healer targeted, block/dodge just to be safe.",
                    "|cFF7F00Sea Orb + Waves|r – Frequent huge water waves cross the arena—avoid them. Marked players see a floating orb approach them. Block at close range or kill from distance. Explodes if unaddressed.",
                    "|cFFA500Trap Fields|r – Purple circles on ground. Move away & drop them in corners. Standing in them is lethal over time.",
                    "|cFFD700Multiple Gryphons|r – At ~90%, ~80%, ~50%, smaller gryphons spawn (in random order) with unique mechanics:\n • Bleed Gryphon: Basic heavy bleeds.\n • Wind Gryphon: Summons 2 tornadoes.\n • Lightning Gryphon: Large static field chasing a random player.\nKill them or you’ll run out of safe space quickly!",
                    "|cFF0000Hard Mode|r – At 30% an enormous 4th Gryphon (Kargaeda) arrives, plus more wave combos forming a T shape. Group must keep boss taunted, kill Kargaeda or remain stuck. Meanwhile, Tether mechanics (two players linked) take more damage if far apart. Overlap final phases with massive tornado walls. Survive, coordinate, no DPS check—patience is key!",
                },
            },

            
            {
                name = "Z’Baza (Final Secret Boss)",
                mechanics = {
                    "|cFF0000Tentacles|r – Appear around the arena, sending swipes & summoning smaller AoEs. Killing them reduces room hazards.",
                    "|cFF7F00Mind Blast|r – If boss sees players in front, blasts them with strong illusions. Tank turn the boss AWAY; group stands behind.",
                    "|cFFA500Orb Explosions|r – Orbs chase marked players. Kill or intercept them by blocking/dodging the explosion at safe HP. Don’t pop them in the group.",
                    "|cFF0000Teleport + Portal|r – Z’Baza might jump far away; a synergy waterhole can whisk you to her location quickly—useful for tank re-taunt.",
                    "|cFFD700Shielded Phase (~55%, ~25%)|r – Boss is immune while tentacle or smaller add channels. You’re stuck in a bubble taking damage. Kill the channeling add quickly to resume boss damage.",
                    "|cFF0000Hard Mode|r – More HP/damage, faster orb spawns, bigger AoEs from tentacles, but the approach is identical. Fight methodically, kill tentacles, keep boss faced away, watch your feet, and you’ll succeed!",
                },
            },

        },
    },


    -------------------------------------------------------------------------------
    -- 24) Shipwright's Regret (zoneId=1302)
    -------------------------------------------------------------------------------
    [1302] = {
        normalId = 601,
        vetId    = 602,
        zoneId   = 1302,
        sets     = {624,633,622,623},
        questID  = 6742,
        HM       = 3154,
        SR       = 3117,
        ND       = 3118,
        TR       = 3120,
        name     = "Shipwright's Regret",
        bosses = {

            {
                name = "Lost Maiden (secret boss #1)",
                mechanics = {
                    "|cFF0000Shout AoE|r – Frontal ice-based shout (|cFF0000BLOCK|r or sidestep). Avoid being in front.",
                    "|cFFA500Ice Pillars|r – Several small pillars that slow & deal DoT. |cFFD700KILL|r or circle around them.",
                    "|cFF7F00Shade Split (~54%)|r – Boss goes immune, spawns 3 illusions. Destroy them quickly or boss remains untouchable.",
                },
            },

            {
                name = "Foreman Bradiggan",
                mechanics = {
                    "|cFF0000Heavy Attack|r – Extremely high damage—(|cFF0000BLOCK or DODGE|r). Failing = one-shot.",
                    "|cFF7F00BIG BOOM|r – AoE spreads outward from center; you can’t soak it or you chain-explode. Step out quickly.",
                    "|cFFA500Charge + Ghosts|r – After each charge, 4 untauntable ghosts appear & tether players. |cFFD700KILL them fast|r to remove debuffs.",
                    "|cFFD700Flesh Colossus|r at ~60% / ~30% – Boss leaves; kill colossus or it’s chaos. Boss returns after colossus dies.",
                    "|cFF0000Hard Mode Bombs|r – At ~30% two bombs appear on two players; each must share with exactly one ally, no more!",
                },
            },

            {
                name = "Shrouded Axeman (secret boss #2)",
                mechanics = {
                    "|cFF0000Heavy Attack|r – Deadly overhead swing; ideally |cFF0000DODGE|r or block if tanking.",
                    "|cFF7F00Exploding Hounds|r – Mark a random player & explode. Time your dodge or block to survive.",
                    "|cFFA500Ghost Phase|r – Boss disappears; 4 red ghosts to |cFF7F00INTERRUPT|r. They leave AoEs that detonate soon after. Then boss reappears.",
                    "|cFFD700Small Adds|r – Some skeletal allies spawn. Kill them or risk heavy hits stacking up.",
                },
            },

            {
                name = "Nazaray",
                mechanics = {
                    "|cFF0000Heavy Attack/Bludgeon|r – Must be blocked or dodge rolled. Lethal hit if not mitigated.",
                    "|cFF7F00Locust Rain|r – Falling AoEs from above. Keep |cFF0000MOVING|r or block if pinned in place.",
                    "|cFFA500Poison Patches|r – On the ground, can snare. Avoid or you’ll take heavy DoT.",
                    "|cFFD700Giant Wasps|r – Summoned frequently. Kill quickly to reduce chaos. Under 30%, swirling poison winds appear.",
                    "|cFF0000Hard Mode Untamed Kindred|r – Summons 3 big adds that channel exploding AoEs. |cFFD700FOCUS one|r to make a safe zone; others explode away from group.",
                },
            },

            {
                name = "Storm-Cursed Sailor (secret boss #3)",
                mechanics = {
                    "|cFF0000Heavy Attack|r – Powerful slash. Tank or target block/roll. Summons lightning arcs on random players.",
                    "|cFF7F00Overcharger Aura|r – A chosen player receives chain lightning. Do not run around; stand & out-heal/block.",
                    "|cFFA500Multi-Teleport|r – Boss leaps around. Simply |cFF0000BLOCK|r each landing or be knocked down.",
                },
            },

            {
                name = "Captain Numirril",
                mechanics = {
                    "|cFF0000Heavy Attack|r – Must be blocked. Also has frontal cleave & random dash charges—avoid or block.",
                    "|cFF7F00Waves (~80% & ~40%)|r – Cross the arena in pairs; |cFF0000MOVE|r or get knocked down & DoT’d.",
                    "|cFFA500Summons Drowned|r – Corpses or Hulks. They flood the area with vile pools. Kill them to keep safe spaces open.",
                    "|cFFD700Flesh Abomination|r ~85% & 40% – Boss leaves, kill or kite 'Malcolm'. Then boss returns. On HM, 2 spawn under 40%. Group synergy is crucial!",
                    "|cFF0000No DPS Check|r – Survive mechanics, always re-taunt adds & boss. Patience ensures victory.",
                },
            },

        },
    },



    -------------------------------------------------------------------------------
    -- 25) Earthen Root Enclave (zoneId=1360)
    -------------------------------------------------------------------------------
    [1360] = {
        normalId = 608,
        vetId    = 609,
        zoneId   = 1360,
        sets     = {660,661,662,666},
        questID  = 6835,
        HM       = 3377,
        SR       = 3378,
        ND       = 3379,
        TR       = 3381,
        name     = "Earthen Root Enclave",
        bosses = {

            {
                name = "Scaled Roots (secret boss #1)",
                mechanics = {
                    "Heavy Attack – Must be blocked by the tank or dodge rolled if aimed at a dps/healer (|cFF0000BLOCK|r) :contentReference[oaicite:0]{index=0}",
                    "Meteors – Each player is targeted; spread out and either block or dodge to avoid overlap (|cFF0000BLOCK or DODGE|r) :contentReference[oaicite:1]{index=1}",
                    "Fire Wolves – Spawn repeatedly and pounce on players; kill them quickly (|cFFD700KILL adds|r) :contentReference[oaicite:2]{index=2}",
                    "Burning Ground – The boss hurls fire at whoever has aggro, leaving flame patches on the floor (|cFFA500MOVE out|r) :contentReference[oaicite:3]{index=3}",
                },
            },

            {
                name = "Corruption of Stone",
                mechanics = {
                    "Earthquakes – Appear under each player; move so they don’t stack up (|cFFA500SPREAD OUT|r) :contentReference[oaicite:4]{index=4}",
                    "Stomp – The boss channels a big AoE from center, knocking down if not avoided (|cFF0000MOVE|r) :contentReference[oaicite:5]{index=5}",
                    "Hide Phases (~75%, 50%, 25%) – Run behind a stone pillar or die to the boss’s slam (|cFF0000ONE-SHOT|r) :contentReference[oaicite:6]{index=6}",
                    "Stone Atronachs – Summoned after each hide phase; kill or interrupt them quickly (|cFFD700FOCUS adds|r) :contentReference[oaicite:7]{index=7}",
                    "Over-Dodging – Excessive dodge rolling enrage the boss, increasing damage (|cFF0000LIMIT dodge|r) :contentReference[oaicite:8]{index=8}",
                    "Hard Mode – More health/damage, more Atronachs. Don’t skip adds or you’ll be overwhelmed (|cFFD700KILL them|r) :contentReference[oaicite:9]{index=9}",
                },
            },

            {
                name = "Lutea (secret boss #2)",
                mechanics = {
                    "Watery Ring (Donut) – Traps the group inside a ring; stand in the center to avoid lethal damage (|cFF0000STAY middle|r) :contentReference[oaicite:10]{index=10}",
                    "Water Splashes – Boss hurls water forward in a line; block or sidestep if tank (|cFF0000BLOCK|r) :contentReference[oaicite:11]{index=11}",
                    "Geyser (Interruptible) – Large channel dealing high damage; quickly interrupt or block (|cFF7F00INTERRUPT|r) :contentReference[oaicite:12]{index=12}",
                    "Teleport – She leaps around the room, resetting trap placements. Follow and re-taunt swiftly :contentReference[oaicite:13]{index=13}",
                },
            },

            {
                name = "Corruption of Root",
                mechanics = {
                    "Green AoEs – Fast-moving streams across the floor; don’t stack with others (|cFFA500STAY mobile|r) :contentReference[oaicite:14]{index=14}",
                    "Fauns & Spriggans – Summoned in waves, plus root trees protecting them. Destroy the trees to force fauns out (|cFFD700KILL adds|r) :contentReference[oaicite:15]{index=15}",
                    "Distributors (Illusions) – Boss splits into several copies; kill them all or boss remains immune (|cFFD700FOCUS illusions|r) :contentReference[oaicite:16]{index=16}",
                    "Hard Mode – Larger waves, extra trees, triple spawns. No direct enrage but can overwhelm if ignored (|cFF0000CONTROL adds first|r) :contentReference[oaicite:17]{index=17}",
                },
            },

            {
                name = "Jodoro (secret boss #3)",
                mechanics = {
                    "Mind Blast – Frontal channel. Must be interrupted or it devastates the group (|cFF7F00INTERRUPT|r) :contentReference[oaicite:18]{index=18}",
                    "Spectral Indrik – A smaller spirit charges at the group. Usually aims the tank. Dodge or block as needed :contentReference[oaicite:19]{index=19}",
                    "Laser Lines – Red arcs under each player, dealing severe damage if overlapped. Spread out (|cFF0000AVOID stacking|r) :contentReference[oaicite:20]{index=20}",
                    "Teleport + Channel – Boss vanishes, reappears far away. Maintain taunt, interrupt quickly if he starts mind-blasting again :contentReference[oaicite:21]{index=21}",
                },
            },

            {
                name = "Archdruid Devyric",
                mechanics = {
                    "Earthquakes – Like Corruption of Stone’s quakes, spread out so they don’t overlap (|cFFA500SPREAD|r) :contentReference[oaicite:22]{index=22}",
                    "Totems – Appear in corners, explode with AoE & final projectile. Step away, then block or dodge (|cFF0000BLOCK final hit|r) :contentReference[oaicite:23]{index=23}",
                    "Lightning Pillar – Summoned with ~370k HP. Must kill or it bombards the group with lightning (|cFFD700PRIORITY add|r) :contentReference[oaicite:24]{index=24}",
                    "Flame Wolves – Marked player is chased. Time your block or dodge to survive pounce (|cFF0000BLOCK or ROLL|r) :contentReference[oaicite:25]{index=25}",
                    "Bear Form (~70% / 20%) – Boss transforms, regenerating HP. Gains huge lightning breath & random dash. Let him smash totems clearing them. Possibly reverts later, or stays. (|cFF0000Kite or block breath|r) :contentReference[oaicite:26]{index=26}",
                    "Execute Phase – Multiple lightning rains. Everyone must block or risk instant death. (Healer keep big HoTs) :contentReference[oaicite:27]{index=27}",
                    "Hard Mode – More totems, heavier hits, added spawns of wolves. Keep synergy on lightning pillar kills & coordinate carefully. No direct DPS check, just survive & handle mechanics :contentReference[oaicite:28]{index=28}",
                },
            },

        },
    },




    -------------------------------------------------------------------------------
    -- 26) Graven Deep (zoneId=1361)
    -------------------------------------------------------------------------------
    [1361] = {
        normalId = 610,
        vetId    = 611,
        zoneId   = 1361,
        sets     = {664,665,667,663},
        questID  = 6837,
        HM       = 3396,
        SR       = 3397,
        ND       = 3398,
        TR       = 3400,
        name     = "Graven Deep",
        bosses = {

            {
                name = "Mzugru (secret boss #1)",
                mechanics = {
                    "Lightning Bolts – The boss fires arcs upward, causing lightning AoEs on the floor. Step away (|cFF0000MOVE|r) :contentReference[oaicite:0]{index=0}",
                    "Shield Phase – Boss heals behind a barrier. Destroy the Pylons to remove immunity (|cFFD700KILL pylons|r) :contentReference[oaicite:1]{index=1}",
                    "Spin Attack – Boss rotates in place, dealing heavy melee AoE. Tank can block; others keep distance (|cFF0000BLOCK or BACK OFF|r) :contentReference[oaicite:2]{index=2}",
                },
            },

            {
                name = "The Euphotic Gatekeeper",
                mechanics = {
                    "Charge & Flip-Out – Boss dashes in a zigzag, dropping AoEs. Don’t chase it; let it return to you (|cFFA500STAY put|r) :contentReference[oaicite:3]{index=3}",
                    "Burrows & Adds – Small holes spawn pangrits. Players with poison synergy must plug them or more adds appear (|cFF0000USE synergy|r) :contentReference[oaicite:4]{index=4}",
                    "Teleport Boom – Teleports away, leaving an expanding AoE. Step back quickly (|cFF0000MOVE out|r) :contentReference[oaicite:5]{index=5}",
                    "Twin Illusion – Boss creates a low-health mirror. If not killed fast it explodes. Watch heavy attacks, too (|cFFD700KILL quickly|r) :contentReference[oaicite:6]{index=6}",
                    "Hard Mode – Faster AoEs, more damage, and more frequent add spawns. Survive with careful synergy use :contentReference[oaicite:7]{index=7}",
                },
            },

            {
                name = "Xzyviian, Defense Crawler (secret boss #2)",
                mechanics = {
                    "Heavy Attack – Tank must block or dps/healer must dodge. Lethal if unmitigated (|cFF0000BLOCK|r) :contentReference[oaicite:8]{index=8}",
                    "Fire Bombs – Random ground circles that burn. Don’t stack or linger (|cFF0000MOVE|r) :contentReference[oaicite:9]{index=9}",
                    "Leap AoE – Boss occasionally jumps, slamming the ground. Step back or block (|cFF0000AVOID landing|r) :contentReference[oaicite:10]{index=10}",
                },
            },

            {
                name = "Varzunon",
                mechanics = {
                    "Skeleton Adds – Summons skeletons nonstop. Tank gather them; dps must kill quickly (|cFFD700PRIORITY adds|r) :contentReference[oaicite:11]{index=11}",
                    "Feed on Sacrifices – Glowing skeletons crawl to the boss, making him grow. Kill them to prevent enrage (|cFFD700KILL quickly|r) :contentReference[oaicite:12]{index=12}",
                    "Stomp – Expanding AoE knockdown. Watch for bigger radius if boss is large (|cFF0000MOVE|r) :contentReference[oaicite:13]{index=13}",
                    "Meteors – Multiple single-target hits from above. Healer be ready with group heals (|cFF0000KEEP HP up|r) :contentReference[oaicite:14]{index=14}",
                    "Hard Mode – Additional overhead AoEs and stronger adds. Manage boss growth or keep healing strong :contentReference[oaicite:15]{index=15}",
                },
            },

            {
                name = "Chralzak, Sphere 9402-A (secret boss #3)",
                mechanics = {
                    "Spin Attack – A whirling attack in melee range. Tank can block, others step out (|cFF0000AVOID spin|r) :contentReference[oaicite:16]{index=16}",
                    "Bomb Shots – Fires big shock bombs at random players. Watch for impact circles (|cFF0000MOVE|r) :contentReference[oaicite:17]{index=17}",
                    "Immunity Shield – Periodically gains invulnerability. Destroy the active pylon or conduit to break it (|cFFD700KILL conduit|r) :contentReference[oaicite:18]{index=18}",
                },
            },

            {
                name = "Zelvraak the Unbreathing",
                mechanics = {
                    "Sea Orb – A large bubble slowly descends. Attack it to push it back. If it touches ground, party wipes (|cFF0000HIGH PRIORITY|r) :contentReference[oaicite:19]{index=19}",
                    "Fears – Boss channels black smoke. Turn away physically or be feared (no break free) (|cFF0000LOOK AWAY|r) :contentReference[oaicite:20]{index=20}",
                    "Shades (~75% & 25%) – Four illusions appear, each must be interrupted or they blast the group (|cFF7F00INTERRUPT & KILL|r) :contentReference[oaicite:21]{index=21}",
                    "Sundered Soul – Marks a player, pulling out their soul. Run to your ghost to survive. (|cFF0000COLLECT your soul|r) :contentReference[oaicite:22]{index=22}",
                    "Realm Shift @50% – Everyone is ported solo. Kill white ghosts for healing, avoid black ghosts or kill them. Returning spawns a flesh abomination or smaller atronach (depends on your kills) (|cFFD700FOCUS add|r) :contentReference[oaicite:23]{index=23}",
                    "Cone Attack – Boss plus any illusions or splits replicate the same frontal cone. Tank keep them all aimed away (|cFF0000DON’T spin boss|r) :contentReference[oaicite:24]{index=24}",
                    "Hard Mode – More intense soul sunder mechanics, 2 players at once, resurrection spawns skeleton adds, and Boss can ignite flames overhead dealing groupwide damage. Don’t miss a single Sea Orb or you all die! :contentReference[oaicite:25]{index=25}",
                },
            },

        },
    },


    -------------------------------------------------------------------------------
    -- 27) Bal Sunnar (zoneId=1389)
    -------------------------------------------------------------------------------
    [1389] = {
        normalId = 613,
        vetId    = 614,
        zoneId   = 1389,
        sets     = {680,681,682,683},
        questID  = 6896,
        HM       = 3470,
        SR       = 3471,
        ND       = 3472,
        TR       = 3474,
        name     = "Bal Sunnar",
        bosses = {

            
            {
                name = "Secret #1 - Totems Puzzle",
                mechanics = {
                    "Randomized puzzle with a central totem (four blocks) and three smaller totems around the edges.",
                    "Use the four levers to rotate each block on the central totem. Blocks 1 & 2 match the right totem, 2 & 3 match center, 3 & 4 match left.",
                    "When solved, cages unlock, and you gain the 'Strength of the Ancestors' buff (+300 Weapon/Spell Damage).",
                },
            },

            {
                name = "Kovan Giryon (Boss #1)",
                mechanics = {
                    "Teleport Mechanic – The boss teleports around the room, forming wide rectangular AoEs crossing it. Step aside or block. (|cFF0000MOVE|r)",
                    "Shadow Phase (~65%, 45%, 20%) – Boss goes immune, summoning adds. Tank gather them, dps kill quickly. Then normal fight resumes. (|cFFD700KILL adds|r)",
                    "Poison Blast – Explosive poison AoE around boss. If you see it charging, get out or block. (|cFF0000MOVE / BLOCK|r)",
                    "Hard Mode Extra – Poison AoEs attach to all players. Spread out to avoid overlapping the ticking DoT. Healer keep group alive. (|cFF0000DON’T overlap|r)",
                },
            },

            
            {
                name = "Secret #2 - Urvel Drath (Mini-Boss)",
                mechanics = {
                    "Beexilko the Behemoth – Starts caged with low HP, regenerates. Occasionally stuns Urvel, helping you briefly. Then Urvel zaps it again. (|cFF0000WATCH boss’s reaction|r)",
                    "Lava Pillars – Summons pillars that expand outward. Just step aside. (|cFF0000MOVE|r)",
                    "Seeking Flame – Red rune overhead. A flame AoE slowly chases you. Kite it carefully; it explodes on contact. (|cFF7F00DON’T overlap with others|r)",
                    "Defeating Urvel Drath grants 'Ancestral Vitality' buff (+30% Magicka & Stamina Recovery).",
                },
            },

            {
                name = "Roksa the Warped (Boss #2)",
                mechanics = {
                    "Darklight Orbs – Spawns orbs tethering a player. Quickly interrupt or damage them. If not done, tethered player dies. (|cFF7F00INTERRUPT or KILL orbs|r)",
                    "Darkness Phase (~70% & 40%) – Room goes dark. Only 2 safe light zones remain. Boss throws AoEs near you—move to the second light to dodge them. Adds spawn; kill them. (|cFFA500STAND in light|r)",
                    "Tank Beam – After darkness, boss hits tank with a lethal beam for ~10s. Healer focus tank; tank block or shield. (|cFF0000HEAL tank|r)",
                    "Hard Mode – Three beams simultaneously on tank, plus stronger illusions. Longer fight due to 12.9M HP. (|cFF0000HEAVY healing needed|r)",
                },
            },

            
            {
                name = "Secret #3 - Laser Beam Puzzle",
                mechanics = {
                    "Four lasers on edges, aiming at a central totem. Move small reflective rocks so each laser strikes the totem. (|cFFA500Trial & Error|r)",
                    "Larger blocks can’t reflect, only the smaller ones can. Watch their line of sight. (|cFF0000ALIGN beams|r)",
                    "Completing grants 'Ancestral Resolve' buff (+3000 Max Health, +10% Damage Resist).",
                },
            },

            {
                name = "Matriarch Lladi Telvanni (Boss #3 / Endboss)",
                mechanics = {
                    "Vomit Cone – Very wide & long poison cone at the tank. (|cFF0000BLOCK as tank or STAY behind boss|r).",
                    "Poison Storm (~70% & 35%) – Entire arena floods with poison, heavy DoT. After a few seconds, synergy appears to cleanse & stun adds. Kill them for a damage window. (|cFFD700BURN adds|r)",
                    "Peryite’s Glory – Green blob adds with moderate HP. Tank gather them; kill in cleave if your AoE is high. (|cFFD700FOCUS if lacking AoE|r)",
                    "Heavier AoE – She places swirling or large ground-based poison circles. Keep your feet moving. (|cFF0000MOVE|r)",
                    "Hard Mode Extra – Adds become fully invulnerable except while stunned by synergy. Also spawns Skeevers chasing a marked player. If caught, big debuff. (|cFF7F00KITE skeevers; DPS kill quickly|r)",
                },
            },

        },
    },


    -------------------------------------------------------------------------------
    -- 28) Scrivener’s Hall (zoneId=1390)
    -------------------------------------------------------------------------------
    [1390] = {
        normalId = 615,
        vetId    = 616,
        zoneId   = 1390,
        sets     = {684,685,686,687},
        questID  = 7027,
        HM       = 3531,
        SR       = 3532,
        ND       = 3533,
        TR       = 3535,
        name     = "Scrivener's Hall",
        bosses = {

            {
                name = "Ritemaster Naqri",
                mechanics = {
                    "|cFF0000Hidden Codex (80%, 55%, 35%)|r: A large floating book spawns, applying color-coded attacks (|cFF0000Red|r = |cFF7F00INTERRUPT|r needed, |c00FF00Green|r = small |cFF0000BLOCK|r AoEs, |cFFFFFFWhite|r = heavy hits must be |cFF0000BLOCK|r). Find & destroy 2 hidden books on shelves to remove it!",
                    "|cFF0000Unstable Literature|r: A small green AoE forms. One player must stand in it and |cFF0000BLOCK|r or the group takes huge damage. (On Hard Mode, spawns 2 simultaneously.)",
                    "|cFF0000Ice Book Storm|r: Multiple ice projectiles swirl outward—spread or keep moving. Healer must use strong (|c00FF00HEAL|r) over time, as burst damage can spike.",
                    "|cFF0000Heavy Staff Attack|r: Must be |cFF0000BLOCK|r or it knocks down / kills squishies.",
                },
            },

            {
                name = "Ozezan the Inferno",
                mechanics = {
                    "|cFF0000Lava Pools|r: Boss burrows & reappears, leaving large lava AoEs that persist. Tank position near edges to overlap and save space.",
                    "|cFF0000Conal Flame|r: A large frontal cleave at the tank—(|cFF0000BLOCK|r or |cFF0000DODGE|r) if targeted. Always face boss away from group.",
                    "|cFF0000Evolved Broodlings|r: Small flying adds—(|cFFD700KILL|r quickly or they overwhelm). They channel lethal DoTs—(|cFF7F00INTERRUPT|r) them!",
                    "|cFFA500Suction (mid-fight)|r: Boss moves center; a giant AoE expands covering most of floor—(|cFFA500MOVE|r to outer edge) or be pulled in and die.",
                    "|cFF0000Hard Mode|r: Lasers now target all 4 players instead of 2. At 40% & 20%, boss summons Iron Atronachs—tank must taunt or group must (|cFFD700KILL|r) them. Also green bugs on floor—step on them or they become extra adds!",
                },
            },

            {
                name = "Valinna (Multi-Phase w/ Lamikhai)",
                mechanics = {

                    
                    "|cFFA500Enraged Spider|r: Lamikhai glows red. Drag it into the ice circle to remove enrage. Also, drop Fire Meteors at room edges to keep middle clear.",
                    "|cFF0000Room Eruption|r: At ~15–20% Lamikhai HP, the room becomes lethal. (|cFFA500MOVE|r through the web door fast) or be one-shot.",

                    
                    "|cFF0000Trip Wire|r: Two players get overlapping AoEs. Each must remain inside their own or both die. Never cross the line between them!",
                    "|cFF0000Valinna’s Fire Rage|r: She teleports & channels a massive flame cone at the tank. (|cFF0000BLOCK|r or die). Keep it from hitting group.",
                    "|cFFA500Lamikhai returns at 55% HP|r: Spiders spawn hooking players. (|cFFD700KILL|r them fast!) Then exit room again when it erupts!",

                    
                    "|cFF0000Exploding Meteors|r: Large glowing orbs land—(|cFFD700KILL|r them fast) or they explode, knockback, and likely fling you off the arena!",
                    "Previous mechanics overlap: watch Trip Wires, Fire Meteors, big flame cones, + no spider now but minimal space. ",
                    "|cFF0000Hard Mode|r: Fire Meteor pools remain forever, watch careful placement. Higher health/damage—team must coordinate meticulously.",
                },
            },

            {
                name = "Cartoklept Scamps & Vault Mechanic",
                mechanics = {
                    "|cFF0000Vault Chests|r: At dungeon start, a locked vault with multiple chests. Need keys from 2 cartoklept scamps each run (one after first boss, one after second).",
                    "Defeat each scamp before it flees to earn a small (Normal) or large (Veteran) key. Accumulate & open enough vault chests to spawn secret boss 'Cartoqueen'.",
                    "|cFF0000Cartoqueen|r: A scamp-like boss with flame waves, explosive mortar blasts, rotating pillars that give her immunity if standing—(|cFFD700KILL|r pillars first!). Watch spin attacks & block big hits. Manage totems or bombs quickly!",
                },
            },

        },
    },



    -------------------------------------------------------------------------------
    -- 29) Oathsworn Pit (zoneId=1470)
    -------------------------------------------------------------------------------
    [1470] = {
        normalId = 638,
        vetId    = 639,
        zoneId   = 1470,
        sets     = {732,734,730,731},
        questID  = 7105,
        HM       = 3812,
        SR       = 3813,
        ND       = 3814,
        TR       = 3816,
        name     = "Oathsworn Pit",
        bosses = {

            {
                name = "Packmaster Rethelros & Malthil",
                mechanics = {
                    "|cFF0000Enrage|r: Rethelros (ranged) & Malthil (wolf) will enrage if they get too close, increasing Malthil’s damage drastically. Keep them separated!",
                    "|cFF0000Bear Traps|r: Rethelros throws traps on the ground—stepping on them roots you. Avoid or break free fast!",
                    "|cFF7F00Protective Totem|r: Summoned periodically, granting both boss & wolf immunity. (|cFFD700KILL|r the totem to remove shield).",
                    "|cFF0000Cinder Shot|r: Rethelros lines up a fiery shot at 1–3 players. Spread out & BLOCK or quickly move aside after impact (leaves small bonfire).",
                    "|cFFA500Wolf Aggro|r: Malthil loses aggro, chasing random players. If enraged, can one-shot with heavy bite—avoid or keep them parted from Rethelros.",
                    "|cFF7F00Hard Mode|r: Both bosses have more HP/damage. |cFF0000Cinder Shot|r targets all 4 players. Protective Totem has increased HP."
                },
            },

            {
                name = "Anthelmir’s Construct",
                mechanics = {
                    "|cFF0000Cindermoths|r: Small flying creatures target a random player & detonate on contact. Lure them near barrels to create lingering fire AOEs or kill them quickly.",
                    "|cFF0000Explosive Barrels|r: Scattered around arena—detonate if touched by fire, leaving permanent lava patches. Avoid standing near them when Cindermoths approach.",
                    "|cFFA500Grab/Throw Axe|r: The construct grabs an axe from a corner (long linear AoE). Don’t stand in path. Then throws it at a player—dodge or block last-second to survive.",
                    "|cFF0000Heat Blast|r: Anthelmir teleports & channels a fire shield. Must break it (|cFFD700KILL|r ~132k HP shield) or kill construct to 70% so it merges & cancels her.",
                    "|cFFA500Flamethrower|r: Once merged (~70%), boss unleashes a frontal flame attack. Tank face away from group & block heavy hits.",
                    "|cFF7F00Hard Mode|r: Construct HP doubled. |cFF0000Cindermoths|r spawn more frequently (123k HP). Heat Blast shield stronger. Everything deals higher damage."
                },
            },

            {
                name = "Aradros the Awakened",
                mechanics = {
                    "|cFF0000Heavy Attack|r: A charged slam. Tank must BLOCK or it’s lethal. Also does small ring AoEs if you stand near landing spot.",
                    "|cFF0000Emblazoned Strike|r: Slams ground, igniting floor tiles in a pattern. Avoid or get big fire DoT.",
                    "|cFFA500Wildfire|r: After slam, 2–4 players get fire DoT, lighting tiles underfoot. Keep moving & don’t overlap each other.",
                    "|cFF7F00Molten Tile|r: Some tiles become lava arcs. You can momentarily dodge through but avoid standing in them. High DoT if stepped on.",
                    "|cFF0000Side Bosses at 50%|r: Aradros ignites entire floor—run to side rooms. Number of sub-bosses depends on difficulty:\n• Normal: 1 side boss\n• Veteran: 2 side bosses\n• Hard Mode: 3 side bosses\nAfter defeating them, return to face Aradros again with more intense tile patterns.",
                    "|cFF0000The Smelter|r: Summon your own friendly Iron Atronach by collecting flames from the 3 forges & using them on the partial atronach in middle room. Helps you fight sub-bosses!",
                    "|cFF7F00Hard Mode|r: More tile ignitions, heavier fire DoTs & 3 side bosses simultaneously if group is on Vet HM. Aradros has significantly higher health/damage. Watch overlapping mechanics & keep up big heals!"
                },
            },

            {
                name = "Sluthrug the Bloodied (secret boss #1)",
                mechanics = {
                    "|cFFA500Trial of Blood|r: Found via hidden path before first boss. Summon by activating Totem of Blood.",
                    "|cFF0000Heavy Swipes|r: Tank must maintain aggro—slashing & cone hits can kill squishies quickly.",
                    "|cFF7F00Blood Globs|r: Moves around merging. Keep an eye or they’ll form larger damaging puddles. Basic movement avoids them.",
                    "|cFFA500Ice Spikes|r: Overlapping frost AoEs on ground—dodge or step out to avoid sustained damage.",
                    "|cFF0000Blooded Vitality Buff|r: +10% healing done & -10% damage taken. The Totem of Blood synergy grants +50% max health & deals retal strikes when hit—stacks damage with Totemic Coagulation."
                },
            },

            {
                name = "Bolg of Wicked Barbs (secret boss #2)",
                mechanics = {
                    "|cFFA500Trial of Conquest|r: Unlock by lighting 2 braziers after first boss. Then enter the side area & activate Totem of Conquest.",
                    "|cFF0000Spectral Archers|r: Summoned adds—chain them in or kill fast. They do arrow storms dealing moderate damage.",
                    "|cFF7F00Spirits of Conquest|r: Ghosts that claim braziers. If they succeed, they buff boss. (|cFFD700Interrupt or kill|r them quickly, or recapture braziers yourself!)",
                    "|cFFA500Volley AoEs|r: Bolg fires arrow storms following players. Simply keep moving.",
                    "|cFF0000Conqueror’s Vim Buff|r: +30% Magicka & Stamina recovery. The Totem synergy grants 16 ult to you/8 ult to allies every 2 seconds—great for burst phases!"
                },
            },

            {
                name = "Grubduthag Many-Fates (secret boss #3)",
                mechanics = {
                    "|cFFA500Trial of War|r: Found on path before final boss. Activate Totem of War to summon him.",
                    "|cFF0000Heavy Attack|r: Must be blocked or it one-shots you. He can also do a meteor AoE which you can block or sidestep.",
                    "|cFF7F00Forge Summons|r: He uses forges to summon Flame Atronachs. Summon your own Cold-Flame Atronachs from the forges to help fight or kill the new spawns quickly!",
                    "|cFF0000Warrior’s Visage Buff|r: +10% Weapon/Spell Damage. The Totem synergy triggers a Flame DoT on each Light/Medium/Heavy Attack. Stacks War Weary for higher damage on repeated hits!"
                },
            },

        },
    },


    ----------------------------------------------------------------------------
    -- 30) Bedlam Veil (zoneId=1471)
    ----------------------------------------------------------------------------
    [1471] = {
        normalId = 640,
        vetId    = 641,
        zoneId   = 1471,
        sets     = {736,737,738,735},
        questID  = 7155,
        HM       = 3853,
        SR       = 3854,
        ND       = 3855,
        TR       = 3857,
        name     = "Bedlam Veil",
        bosses = {

            {
                name = "Shattered Champion",
                mechanics = {
                    "|cFF0000Heavy Attack / Hindered|r – Boss slams the ground, applying a healing absorption debuff (|cFFFFFFHindered|r) to whoever is hit. Tank must |cFF0000BLOCK|r or dodge. Afflicted players need ~24k healing to remove it.",
                    "|cFFA500Sharp Glass|r – Delayed circles under each player. After a short time, leaves persistent AoEs. Step away or |cFF0000DODGE|r the final impact to avoid clustering in the center.",
                    "|cFF7F00Glazier Adds|r – Occasionally channel a shield beam making boss/adds immune. Kill or chain them quickly. Normal interrupts don’t work, but pulling them cancels the channel.",
                    "|cFF0000Gaping Wound|r – Almost every boss hit applies an unshieldable Oblivion DoT. Keep consistent heals/HoTs to survive overlapping damage.",
                    "|cFF7F00Ring of Glass (70%, 50%)|r – Two circular barriers appear from outer edge to inner. Avoid crossing them. Fight within or between safe zones while space shrinks.",
                    "|cFF0000Glass Fragments|r – Spawn around, firing Blinding Salvo. Burn them swiftly or chain them in for AoE kills.",
                    "|cFFD700Hard Mode|r – Boss has higher HP (~8.12M), heavier damage, more frequent AoEs/adds. Mechanics remain the same, just more punishing."
                },
            },

            {
                name = "Darkshard",
                mechanics = {
                    "|cFF0000Shriek + Stun|r – Boss howls, pushing you back & placing a large AoE at its feet. Break free & step aside. Follow-up heavy or cone can kill if not blocked.",
                    "|cFF7F00Summon Mini-Bosses|r – At 80%/60%/40% HP, boss vanishes, spawning:\n   • Maxus the Many (duplicates: Militants & Elementalists)\n   • Champion of Atrocity (Maelstrom Stage 6 mechanics: unweb obelisks, handle spiderlings, stun enrage)\n   • Argonian Behemoth (Maelstrom Stage 7: poison flowers, cleansing pools)\nDefeat each to make Darkshard return. Adds keep respawning afterward, complicating the fight.",
                    "|cFF0000Heavy Attack|r – Lethal overhead if aimed at you. Tank should |cFF0000BLOCK|r or be ready for random shade hits. DPS/healer must also watch for it.",
                    "|cFFA500Grasping Scream|r – Purple bolts stun players. Break free. Leaves an AoE near boss. The shade might similarly target someone else.",
                    "|cFF0000Poison Flowers / Water Pools|r – Argonian Behemoth phase covers ground in lethal blossoms. Step into a pool to cleanse poison if you touch them. Tank must handle Minders/enrage or kill them quickly.",
                    "|cFFD700Hard Mode|r – ~5.07M HP. Faster spawns from each mini-boss, heavier hits. Keeping obelisks/spider-ling phases under control is crucial."
                },
            },

            {
                name = "The Blind (Endboss)",
                mechanics = {
                    "|cFF0000Malediction|r – Each player gets a delayed AoE. Move out or block/dodge the final pop. Leaves a damaging ground effect.",
                    "|cFF0000Levitation Slam|r – Boss floats & channels a large AoE. Anyone caught takes huge damage plus a healing absorption. Break free or get out quickly.",
                    "|cFFA500Mirrorplasm Adds|r – Appear sporadically, dropping small ground AoEs. Kill them so they don’t stack up.",
                    "|cFF7F00Shadow Skeletons|r – At 80/60/40/20% HP, The Blind moves to arena edge; skeletons spawn, firing linear waves (|cFF0000Gleaming Deluge|r) or beams blocking lanes. Frequency of waves/beams grows each phase!",
                    "|cFFA500Glass Remnants|r – Smaller ‘Shattered Champion’ adds at 60% & 40%. Must be killed for The Blind to return. They cast Blinding Salvo—avoid or block.",
                    "|cFFD700Puzzle Synergies|r – If all 3 puzzles are solved, use charms:\n   • Zephyrus Obscuris (parry beams/waves)\n   • Ocular Disperser (part waves)\n   • Catatonic Disruptor (interrupt big channels/knock down)\nThey help manage wave/beam pressure in final phases."
                },
            },

            {
                name = "Puzzle Synergies & Buffs",
                mechanics = {
                    "|cFFA500First Puzzle|r – Remove 2 lines, leave 3 squares. Rewards |cFF7F00Zephyrus Obscuris|r synergy: 'Briefly repel wave/beams at a barrier.'",
                    "|cFF0000Second Puzzle|r – Remove 2 lines, leave 2 squares (big + small). Rewards |cFF7F00Ocular Disperser|r synergy: 'Part wave hazards on use.'",
                    "|cFF0000Third Puzzle|r – Remove 3 lines, leave 4 squares. Rewards |cFF7F00Catatonic Disruptor|r synergy: 'Force attackers/major channels to the ground briefly.'",
                    "Completing each puzzle also grants extra loot from a Trinket Chest. Only one synergy can be used at a time (shared cooldown)—coordinate them in the final fight!"
                },
            },

        },
    },

    -------------------------------------------------------------------------------
    -- Exiled Redoubt (zoneId: 1496)
    -------------------------------------------------------------------------------
    [1496] = {
        normalId = 642,
        vetId    = 643,
        zoneId   = 1496,
        sets     = {797, 795, 796, 794},
        questID  = 7235,
        HM       = 4111,
        SR       = 4112,
        ND       = 4113,
        TR       = 4115,
        name     = "Exiled Redoubt",
        bosses   = {
            {
                name = "Guard Captain Paratius (Secret)",
                mechanics = {
                    "Summons Skeletal Protectors at 50% and 30% HP, causing the boss to become |cFFD700IMMUNE|r.",
                    "Uses |cFF0000SHIELD CHARGE|r on distant targets.",
                    "Throws his shield twice – players must |cFF0000DODGE|r, |cFF0000ROLL|r, or |cFF0000BLOCK|r to avoid the attack.",
                    "Occasionally summons Skeletal Archers and Sorcerers (|cFFD700KILL adds|r).",
                },
            },
            {
                name = "Executioner Jerensi",
                mechanics = {
                    "Becomes |cFFD700IMMUNE|r at 75%, 50%, and 30% HP while summoning Jailer/Torturer adds.",
                    "Throws |cFF0000SPIKE TRAPS|r on the ground – players should |cFF0000MOVE|r to avoid them.",
                    "Places |cFF0000DEATH KNELL|r AoEs on players; quick movement is required to avoid them (|cFF0000MOVE|r).",
                    "An Execute jump is indicated (|cFFFF00EXECUTE|r); players should group together to share the damage.",
                    "Uses |cFF0000LACERATION|r and |cFF0000SHADOW CLEAVE|r in a frontal attack (|cFF0000BLOCK|r is required).",
                },
            },
            {
                name = "Docent Domitius (Secret)",
                mechanics = {
                    "Casts |cFF0000SOUL SHATTER|r, a moderately strong dark AoE centered on the tank's position.",
                    "Summons flying, ghostly objects that stun or knock players to the ground (|cFF7F00INTERRUPT|r is required).",
                    "Casts a small |c00FFFFICE BOLT|r on the tank.",
                    "Periodically summons small Skeletal adds (|cFFD700KILL adds|r).",
                },
            },
            {
                name = "Prime Sorcerer Vandorallen",
                mechanics = {
                    "Hurls a |cFF0000STORM BOLT|r at the farthest player, leaving behind a lightning AoE field.",
                    "Chain lightning spreads if players remain in the field (|cFF0000SPREAD|r).",
                    "Mounts a flaming horse and performs an |cFF0000IRON CHARGE|r that leaves fire AoEs in its wake.",
                    "Summons |cFFD700IRON ATRONACH SPIDERS|r – use |c00FFFFFROZEN DOME|r to slow them down.",
                    "Grants a random player the |cFF00FFBLACKSPINE CURSE|r (DoT).",
                    "Sends out |cFF7F00RACING FLAMES|r that shoot Salamanders outward.",
                    "Executes a |cFF0000LIGHTNING ROD SLAM|r, causing mini lightning AoEs to appear beneath each player (|cFF0000BLOCK|r is required).",
                    "A |cFF0000CORUSCATING ORB|r traverses the arena, stunning anyone caught within it.",
                    "Simulacrum adds appear below 40% HP and cast |cFFD700FIRESTORM|r from a distance (|cFFD700KILL adds|r).",
                },
            },
            {
                name = "Eliana Albus (Secret)",
                mechanics = {
                    "Leaves behind a |cFF0000POOL OF GRIEF|r, dark AoEs on the ground.",
                    "Channels |cFF7F00OVERWHELMING SORROW|r bolts for several seconds.",
                    "Casts |cFF0000VICIOUS DENIAL|r orbs that bounce off walls.",
                    "Creates a |cFFD700SHADOWY DUPLICATE|r with moderate health.",
                    "Unleashes an |cFF0000ECHOING PAIN|r cone that targets the tank (|cFF0000BLOCK|r is required).",
                },
            },
            {
                name = "Squall of Retribution",
                mechanics = {
                    "Performs a |cFF0000SIX SWORD ASSAULT|r, where swords are thrown outward and then back (|cFF0000DODGE|r is required).",
                    "Spins in a |cFF0000VORTEX AoE|r around himself (|cFF0000AVOID|r).",
                    "Coordinated Slash: A heavy attack on the tank that applies |cFF0000HINDERED|r and |cFF0000RATTLED|r (|cFF0000BLOCK|r is required).",
                    "Fire Phase: Fire Atronachs drop |cFF0000FIRE ORBS|r with an Ignited DoT, while |cFF0000FIRE STORM|r vortices persist.",
                    "Frost Phase: Frost Atronachs drop |c00FFFFFROST ORBS|r with a Freezing Death DoT, and the |c00FFFFFROZEN GROUND|r shrinks.",
                    "Storm Phase: Storm Atronachs drop |cFF0000SHOCK ORBS|r with a Storm DoT, accompanied by |cFF0000THUNDERSTRIKE|r, which hits all players.",
                },
            },
        },
    },



    

    -------------------------------------------------------------------------------
    -- Lep Seclusa (zoneId = 1497)
    -------------------------------------------------------------------------------
    [1497] = {
        normalId = 644,
        vetId    = 645,
        zoneId   = 1497,
        sets     = {801, 799, 798, 800},
        questID  = 7237,
        HM       = 4130,
        SR       = 4131,
        ND       = 4132,
        TR       = 4134,
        name     = "Lep Seclusa",
        bosses   = {
            {
                name = "Lewin Frey(Skippable)",
                mechanics = {
                    "Charged Strike – Lewin channels a powerful lightning attack on a random player, applying a Conduit damage-over-time effect. (|c00FF00HEAL|r immediately!)",
                    "Sparks – Delivers a cone-shaped area attack toward the tank; block the attack to reduce damage. (|cFF0000BLOCK|r)",
                    "Thunderstorm – Summons crashing lightning strikes that explode on impact – dodge them! (|cFF0000DODGE|r)",
                    "Thunder Thrall – Jumps to a random position, dealing shock damage and causing knockback; quickly move out of the explosion zone. (|cFF0000MOVE|r)",
                },
            },
            {
                name = "Garvin the Tracker",
                mechanics = {
                    "Slice – Performs a basic attack that inflicts a bleeding effect on the tank; block if possible. (|cFF0000BLOCK|r)",
                    "Whirlwind – Spins 360° to deliver a sweeping area attack; dodge or block to avoid damage. (|cFF0000DODGE|r)",
                    "Noxious Boulder – Charges forward with a boulder that creates a toxic area on impact – break line of sight to reduce its effect. (|cFF7F00BREAK LOS|r)",
                    "Vanishing Powder – Disappears and reappears behind a large rock; reposition quickly to avoid subsequent hazards. (|cFF0000MOVE|r)",
                    "Piercing Dervish – Unleashes a two-sided flurry of strikes; stand to the side of the boss to evade the attack. (|cFF0000DODGE|r)",
                    "Ricochet – Links two players with a poisonous tether; break line of sight between them to clear the effect. (|c00FFFFBREAK FREE|r)",
                    "Venom Eruption – Fills the area with toxic clouds; take cover until they dissipate. (|cFF0000HIDE|r)",
                    "Interrupt Adds – Interrupt the casts of Deserter Infuser, Storm Mage, and Flame Archer to prevent buffing and additional area effects. (|cFF7F00INTERRUPT|r)",
                },
            },
            {
                name = "Siege Master Malthoras(Skippable)",
                mechanics = {
                    "Ballista Mechanic – Remains on station until you repair and man the ballista; use them to weaken his defenses. (|cFF7F00USE BALLISTA|r)",
                    "Piercing Shot – Fires rapid arrow volleys; block or dodge to mitigate damage. (|cFF0000BLOCK or DODGE|r)",
                    "Fire Bombs – Throws fire bombs that leave burning patches on the ground; move out of the flames. (|cFF0000MOVE|r)",
                    "Directed Volley – Launches a focused barrage of arrows at a target; block if you are targeted. (|cFF0000BLOCK|r)",
                    "Shattering Stomp – Slams the ground, causing knockback; dodge the stomp to avoid damage. (|cFF0000DODGE|r)",
                    "Quakeshot – Fires bouncing projectiles that can hit behind the initial target; reposition to avoid additional damage. (|cFF0000MOVE|r)",
                },
            },
            {
                name = "Noriwen",
                mechanics = {
                    "Slash – Executes a swift melee attack; avoid it by positioning to the side. (|cFF0000DODGE|r)",
                    "Brand – A heavy, charged strike that must be blocked by the tank; if dodged, the boss becomes enraged. (|cFF0000BLOCK|r)",
                    "Chain Pull – After charging away, Noriwen will pull the tank if too far away; chase her or use cleansing abilities to remove the effect. (|c00FFFFBREAK FREE|r)",
                    "Blast Powder – Throws explosive powder that creates dangerous area effects; move out of the blast zone. (|cFF0000MOVE|r)",
                    "Gryphon Bombers – Summons flying adds that drop bombs; avoid their flight paths. (|cFF0000DODGE|r)",
                    "Flame Gryphons – Occasionally summons flame gryphons that cast fire-based attacks; interrupt their spells to reduce damage. (|cFF7F00INTERRUPT|r)",
                    "Alcunar – The massive gryphon on the ledge that produces shock damage with its wing gusts; be mindful of his attacks. (|cFF0000DODGE|r)",
                },
            },
            {
                name = "Flamedancer Ajim-Rei",
                mechanics = {
                    "Flare – Performs a basic fire attack that deals minimal damage if avoided. (|cFFFFFFNO ACTION|r)",
                    "Incinerating Prance – A heavy, channelled attack that must be interrupted or dodged to prevent high damage. (|cFF7F00INTERRUPT|r or |cFF0000DODGE|r)",
                    "Imminent Eruption – Casts fire zones under each player that erupt after a short delay, dealing damage equal to 50% of your health; never stand in the same spot as others. (|cFF0000AVOID|r)",
                    "Heat Wave – Targets a player with a series of heat waves that apply a burning effect; move away or interrupt to reduce damage. (|cFF0000DODGE or INTERRUPT|r)",
                    "Flame Aspect – Summons a flame aspect that fires fireballs or channels intense heat at a target; interrupt its cast to mitigate damage. (|cFF7F00INTERRUPT|r)",
                    "Blazing Shalk – Charges at players and leaves a trail of flames; quickly reposition to avoid sustained burn damage. (|cFF0000MOVE|r)",
                },
            },
            {
                name = "Orpheon the Tactician",
                mechanics = {
                    "Quick Strike – A rapid, area-of-effect melee attack; block or dodge to reduce damage. (|cFF0000BLOCK or DODGE|r)",
                    "Reality Fracture – A heavy, telegraphed area attack targeting the tank; avoid standing near the tank during its execution. (|cFF0000AVOID|r)",
                    "Abyssal Reach – Summons massive tendrils from the ground; reposition to avoid their low-damage hits. (|cFF0000MOVE|r)",
                    "Confine – Creates constricting walls that shrink the fighting area; stay within the safe zone to avoid damage. (|cFF0000STAY in safe zone|r)",
                    "Arcane Planemeld – At specific health thresholds, Orpheon becomes invulnerable and summons adds; quickly clear the adds before he re-engages. (|cFFD700KILL adds|r)",
                    "Forbidden Knowledge – While invulnerable, Orpheon fires damaging spheres at all players; dodge or roll to mitigate the impact. (|cFF0000DODGE|r)",
                    "Arcane Void – Larger adds like the Arcane Hulk and Wraith cast devastating area attacks; avoid their damage zones. (|cFF0000MOVE away|r)",
                    "Alcunar – Also participates by inflicting additional damage with wing gusts; remain alert to his attacks. (|cFF0000DODGE|r)",
                },
            },
        },
    },

}

    ----------------------------------------------------------------------------
    -- Future dungeons can be added as follows: Placeholder U45
    ----------------------------------------------------------------------------
    -- [ZONE_ID] = {
    --     normalId = <Normal_ID>,
    --     vetId    = <Veteran_ID>,
    --     zoneId   = [ZONE_ID],
    --     sets     = { <Set_ID1>, <Set_ID2>, <Set_ID3>, ... },
    --     HM       = <HardMode_ID>,
    --     SR       = <SR_ID>,
    --     ND       = <ND_ID>,
    --     TR       = <TR_ID> or nil,
    --     name     = "[Dungeon Name]",
    --     bosses = {
    --         {
    --             name = "[Boss Name]",
    --             mechanics = {
    --                 "[Mechanic Description 1]",
    --                 "[Mechanic Description 2]",
    --                 -- etc.
    --             },
    --         },
    --         -- Additional boss entries…
    --     },
    -- },
    ----------------------------------------------------------------------------
