-- DungeonStrats boss strategy data.
-- ESO color codes: |cFFD700 = gold, |cFF4444 = red/danger, |c00FF00 = green, |r = reset

DungeonStrats = DungeonStrats or {}
local ds = DungeonStrats
ds.Data = {

dungeons = {

-- DungeonStrats: Base Game Dungeons Part 1 (Fungal Grotto I through Wayrest Sewers II)
-- This file contains dungeon entries to be inserted into the main data table.

    ["Fungal Grotto I"] = {
        order = 1,
        bosses = {
            {
                name = "Tazkad the Packmaster",
                strategy = "|cFFD700Blood Craze|r is a physical damage-over-time applied to the tank that cannot be avoided, so healers should be ready to top up. "
                    .. "His other dangerous ability is |cFFD700Agony|r, which deals high magic damage and stuns the target. "
                    .. "|cFF4444Interrupt Agony immediately|r or it will lock down a party member and potentially kill them.\n\n"
                    .. "|c00FF00This is a simple introductory fight with no special phases. "
                    .. "Just keep interrupts ready and heal through the DoT.|r",
            },
            {
                name = "War Chief Ozozai",
                strategy = "Ozozai fires a |cFFD700Daedric Blast|r, a red beam that targets a player and creates an exploding circle on the ground. "
                    .. "He also uses |cFFD700Haymaker|r, a devastating single-target hit that causes knockdown. "
                    .. "|cFF4444Tanks must block Haymaker|r or risk being one-shot. "
                    .. "At low health he begins using |cFFD700Staggering Roar|r, a physical AoE shout, and |cFFD700Shock Assault|r to leap at distant targets.\n\n"
                    .. "Two Murkwater War Guard adds accompany him and drop DK fire standards on the ground. "
                    .. "|c00FF00Kill the adds first to reduce incoming damage, then focus the boss. Move out of standard fields immediately.|r",
            },
            {
                name = "Bloodbirther",
                strategy = "Bloodbirther will randomly pull distant players into melee range, so ranged DPS should be aware they may be repositioned. "
                    .. "His primary attack is |cFFD700Shocking Rake|r, a channeled frontal cone of lightning damage that hits hard. "
                    .. "|cFF4444Do not stand in front of the boss during the channel|r or you will take massive damage.\n\n"
                    .. "|c00FF00Stay behind or to the side of the boss at all times. "
                    .. "If pulled in, immediately reposition to his flank. The tank should face him away from the group.|r",
            },
            {
                name = "Clatterclaw",
                strategy = "Clatterclaw periodically summons a large swarm of mudcrabs that can quickly overwhelm the party if ignored. "
                    .. "The boss itself does not have particularly dangerous mechanics beyond standard melee attacks.\n\n"
                    .. "|c00FF00Use AoE abilities to burn down the mudcrab waves as soon as they spawn. "
                    .. "Stack the group so AoE heals cover everyone while DPS cleave the adds. "
                    .. "Focus the boss between spawn phases.|r",
            },
            {
                name = "Kra'gh the Dreugh King",
                strategy = "Kra'gh uses a pull mechanic to drag players toward him, followed by |cFFD700Lightning Field|r, an expanding red circle that deals roughly 400 damage per tick. "
                    .. "|cFF4444If you remain in the Lightning Field it will stack up and one-shot you.|r "
                    .. "He also uses |cFFD700Lunging Strike|r for a knockdown and |cFFD700Storm Flurry|r, a channeled lightning barrage.\n\n"
                    .. "Mudcrabs are summoned periodically as additional distractions. "
                    .. "|c00FF00When pulled in, dodge roll out immediately before the Lightning Field expands. "
                    .. "Block the Lunging Strike to avoid knockdown and burn the boss between mechanics.|r",
            },
        },
    },
    ["Fungal Grotto II"] = {
        order = 2,
        bosses = {
            {
                name = "Mephala's Fang",
                strategy = "Mephala's Fang is accompanied by two healer adds that will keep the boss alive if left unchecked. "
                    .. "|cFF4444Kill both healers first|r before focusing damage on the boss. "
                    .. "The boss drops AoE poison circles around the tank and uses a poisonous frontal cone attack.\n\n"
                    .. "|c00FF00Tank should kite out of poison pools to keep the area clean. "
                    .. "DPS burn the healers quickly, then swap to the boss. Stay out of the frontal cone.|r",
            },
            {
                name = "Gamyne Bandu",
                strategy = "Gamyne Bandu connects two players with a |cFFD700Light Beam|r tether that deals increasing damage the longer it persists. "
                    .. "|cFF4444Run apart from the tethered player to break the beam quickly.|r "
                    .. "She also summons |cFFD700Shadow Tormentors|r that chain players in place. Focus fire one Tormentor at a time to free chained allies.\n\n"
                    .. "During |cFFD700Obsidian Aspects|r she transforms into four copies of herself. "
                    .. "|c00FF00Use AoE damage to hit all copies simultaneously. "
                    .. "Breaking beam tethers and freeing chained players are the top priorities in this fight.|r",
            },
            {
                name = "Ciirenas the Shepherd",
                strategy = "Ciirenas is accompanied by three spiders that grant her a significant damage reduction buff while alive. "
                    .. "Killing the spiders individually is a waste of time because they respawn.\n\n"
                    .. "|c00FF00Ignore the spiders entirely and focus all damage on the boss. "
                    .. "When Ciirenas dies, all three spiders die with her. "
                    .. "Healers should keep the group topped up through the extra spider damage while DPS burns the boss down.|r",
            },
            {
                name = "Spawn of Mephala",
                strategy = "A portal near the boss will teleport the nearest player to a spider chamber below, removing them from the fight. "
                    .. "|cFF4444Kite the boss to the far end of the bridge|r away from the portal to prevent accidental teleports. "
                    .. "When she glows, she is charging an expanding red explosion. Get as far away as possible when you see the glow.\n\n"
                    .. "She also creates |cFFD700Light Beam Circles|r on the ground that are fatal if you stand in multiple overlapping ones. "
                    .. "|c00FF00Keep the boss far from the portal, spread out to avoid stacking beam circles, "
                    .. "and run away immediately when she begins glowing for the explosion.|r",
            },
            {
                name = "Reggr Dark-Dawn",
                strategy = "Reggr uses a spinning melee attack and a magicka drain that starves healers and casters of resources. "
                    .. "His |cFFD700Devastating Heavy Attack|r hits so hard that |cFF4444only tanks can survive it, and they must block.|r "
                    .. "Non-tanks caught by this attack will almost certainly die.\n\n"
                    .. "He is accompanied by Obsidian Warriors and an Oblivion Husk. "
                    .. "|c00FF00Kill the Obsidian Warriors first, then the Oblivion Husk, and finally focus the boss. "
                    .. "Tanks must always be ready to block the heavy attack. Sustain resources carefully due to the magicka drain.|r",
            },
            {
                name = "Vila Theran",
                strategy = "Vila Theran teleports around the arena, leaving behind expanding black holes at each previous location that deal heavy damage. "
                    .. "She also applies a |cFFD700High DoT Attack|r that will rapidly kill players if not cleansed. "
                    .. "|cFF4444Run to the wayshrine forcefield to negate the DoT effect|r when it is applied to you.\n\n"
                    .. "|c00FF00Stay grouped together to minimize the area covered by black holes. "
                    .. "Spread positioning means more of the arena becomes dangerous. "
                    .. "Prioritize cleansing the DoT at the wayshrine over DPS uptime to survive this encounter.|r",
            },
        },
    },
    ["Spindleclutch I"] = {
        order = 3,
        bosses = {
            {
                name = "Spindlekin",
                strategy = "Spindlekin summons spider adds throughout the fight. When a spider dies nearby, the boss will |cFFD700Devour|r the corpse to regenerate health. "
                    .. "|cFF4444If you kill spiders slowly, the boss will outheal your damage by consuming them.|r\n\n"
                    .. "|c00FF00Burn the boss as fast as possible and ignore the spider adds. "
                    .. "The faster you kill Spindlekin, the fewer spiders spawn and the less healing the boss receives. "
                    .. "Save ultimates for this fight to push through quickly.|r",
            },
            {
                name = "The Swarm Mother",
                strategy = "The Swarm Mother spawns waves of spider adds during the fight and uses a powerful |cFFD700Heavy Attack|r that must be blocked to avoid knockback. "
                    .. "She also leaps at a random group member dealing significant damage on landing.\n\n"
                    .. "|c00FF00Stack the group around the boss so AoE abilities hit both the adds and the boss simultaneously. "
                    .. "Block the heavy attack telegraph to prevent knockback. "
                    .. "Healers should be prepared for the random leap target to take a spike of damage.|r",
            },
            {
                name = "Cerise the Widow-Maker",
                strategy = "Cerise buffs her own damage throughout the fight and uses an |cFFD700Immobilize|r ability to root players in place, followed by a heavy attack. "
                    .. "She is accompanied by trash adds including Healers, Casters, and Melee fighters.\n\n"
                    .. "|cFF4444Kill the adds before engaging the boss|r using the priority order: Healers first, then Casters, then Melee. "
                    .. "|c00FF00Once adds are down, focus the boss. Break free from immobilize quickly and block the incoming heavy attack. "
                    .. "The longer the fight goes, the more damage she deals due to her self-buff.|r",
            },
            {
                name = "Big Rabbu",
                strategy = "Big Rabbu uses an instant |cFFD700Pull|r ability to yank players to his location, and follows up with a |cFFD700Directional Charge|r shown as a red path on the ground. "
                    .. "|cFF4444The charge hits extremely hard and must be dodge-rolled.|r\n\n"
                    .. "|c00FF00Watch for the red line telegraph and dodge roll to the side immediately. "
                    .. "After being pulled in, be ready for the charge to follow. "
                    .. "Ranged DPS and healers should stay at medium range to have more reaction time when pulled.|r",
            },
            {
                name = "The Whisperer",
                strategy = "The Whisperer randomly |cFFD700Incapacitates|r a player with madness, dealing damage and stunning them. "
                    .. "She fires a poison projectile and has a knockback for players in melee range. "
                    .. "Her most dangerous ability is a |cFFD700Web Pull|r followed by a powerful AoE explosion. "
                    .. "|cFF4444Dodge roll out of the AoE immediately after being pulled|r or you will take fatal damage.\n\n"
                    .. "|c00FF00On veteran mode, the web pull AoE is strictly pass-or-fail: you either dodge out at full health or you die. "
                    .. "Keep stamina reserved for the dodge roll at all times. Healers should cleanse the madness debuff quickly.|r",
            },
        },
    },
    ["Spindleclutch II"] = {
        order = 4,
        bosses = {
            {
                name = "Mad Mortine",
                strategy = "Mad Mortine is accompanied by seven Blood Fiends with approximately 6621 HP each. "
                    .. "The fiends use charge attacks and air-jump heavy attacks that can overwhelm the group quickly. "
                    .. "|cFF4444Focus AoE damage on the Blood Fiend adds first|r before turning to the boss.\n\n"
                    .. "|c00FF00Stack the adds together for efficient AoE cleave. "
                    .. "The tank should pull the fiends into a tight group while DPS burns them down. "
                    .. "Once the adds are dead, Mortine herself is a straightforward fight.|r",
            },
            {
                name = "Blood Spawn",
                strategy = "Blood Spawn uses |cFFD700Ground Pound|r, an AoE attack in the center of the arena that hits three times for over 1500 damage each tick. "
                    .. "The outer edges of the arena are hit by |cFFD700Rockslides|r that deal |cFF4444instant death|r. "
                    .. "At the two-minute mark, Blood Spawn enrages and begins spamming Ground Pound continuously.\n\n"
                    .. "|c00FF00Stay at mid-range: not in the center where Ground Pound hits, and not on the edges where rockslides fall. "
                    .. "This is a DPS race. You must kill the boss before the two-minute enrage timer or the constant Ground Pounds will wipe the group.|r",
            },
            {
                name = "Praxin Douare",
                strategy = "Praxin Douare is immune to damage while summoning four progressive waves of adds that must be cleared. "
                    .. "He uses a |cFFD700Frontal Three-Beam|r attack and places a |cFFD700Kill Circle|r on a random player that kills anyone else who enters it. "
                    .. "He also drains magicka and stamina from the group.\n\n"
                    .. "|cFF4444The final wave includes healer adds that must be interrupted.|r "
                    .. "|c00FF00Clear each add wave efficiently. Stay out of other players' kill circles. "
                    .. "In the final wave, assign interrupts to the healer adds or they will outheal your damage. "
                    .. "Save resources for the final wave as the magicka and stamina drain makes sustain difficult.|r",
            },
            {
                name = "Flesh Atronach Trio",
                strategy = "Three Flesh Atronachs fight together with no special attack mechanics beyond a |cFFD700Charge-Up|r attack that should be blocked. "
                    .. "However, when one Atronach dies, the remaining ones heal for 10-30% of their health.\n\n"
                    .. "|c00FF00Focus all damage on one Atronach at a time to kill it quickly. "
                    .. "The healing from a death is less punishing than trying to split damage evenly. "
                    .. "Block the charge-up attacks and burn them down one by one.|r",
            },
            {
                name = "Urvan Veleth",
                strategy = "Urvan Veleth is accompanied by two Boneman Archers and two Warriors. The Warriors use an interruptible AoE that must be bashed. "
                    .. "During the fight, the boss transforms into a |cFFD700Red Circle|r that follows the tank dealing continuous damage.\n\n"
                    .. "|cFF4444The tank must kite the red circle|r to avoid taking lethal stacking damage. "
                    .. "|c00FF00Kill the adds first while the tank keeps the red circle moving. "
                    .. "Interrupt the Warrior AoE attacks whenever they begin channeling. "
                    .. "Once adds are dead, continue kiting until the boss becomes targetable again.|r",
            },
            {
                name = "Vorenor Winterbourne",
                strategy = "Vorenor Winterbourne drops a |cFFD700Red Circle|r dealing heavy damage and uses an unavoidable attack hitting the entire group for roughly 1000 HP per member. "
                    .. "|cFF4444This unavoidable attack is blockable but can critically strike and one-shot players who do not block.|r "
                    .. "He periodically siphons the crucified NPCs around the room to regenerate his health.\n\n"
                    .. "|c00FF00Kill the crucified NPCs to prevent the boss from healing. "
                    .. "Always block when you see the group-wide attack telegraph. "
                    .. "Move out of red circles quickly and keep the NPCs dead as your top priority.|r",
            },
        },
    },
    ["The Banished Cells I"] = {
        order = 5,
        bosses = {
            {
                name = "Cell Haunter",
                strategy = "Cell Haunter fires |cFFD700Health Leech|r, a green projectile that is unavoidable and drains health, along with |cFFD700Magic Missile|r attacks. "
                    .. "It also casts |cFFD700Ice Tornado|r dealing frost damage that can be dodge-rolled. "
                    .. "Adds accompany the boss and should be dealt with first.\n\n"
                    .. "|c00FF00Kill the adds before focusing the boss. "
                    .. "Dodge roll through Ice Tornados to avoid the frost damage. "
                    .. "Healers should keep the group topped up through the unavoidable Health Leech drain.|r",
            },
            {
                name = "Shadowrend",
                strategy = "Shadowrend uses |cFFD700Tail Swipe|r, a 360-degree AoE that knocks down anyone who fails to block. "
                    .. "It summons a |cFFD700Shadow Clone|r with high damage but low health that must be killed quickly. "
                    .. "Its most dangerous ability is |cFFD700Charge and Devour|r, where it charges a random player and drains their health. "
                    .. "|cFF4444Bash the boss during Devour to interrupt it|r or the target will die.\n\n"
                    .. "|c00FF00This boss causes the most wipes in the dungeon. "
                    .. "Block the Tail Swipe, kill the Shadow Clone immediately when it spawns, and always be ready to bash the Devour channel. "
                    .. "Assign interrupt duty if needed.|r",
            },
            {
                name = "Angata the Clannfear Handler",
                strategy = "Angata summons Clannfear adds approximately every ten seconds throughout the fight. "
                    .. "She is also accompanied by cryomancer adds that cast ice tornadoes and ice walls.\n\n"
                    .. "|cFF4444Kill the cryomancer adds first|r as their ice tornadoes and walls deal significant unavoidable damage. "
                    .. "|c00FF00Once the cryomancers are down, AoE the Clannfear as they spawn while focusing the boss. "
                    .. "The Clannfear alone are manageable but the cryomancers make the fight lethal if left alive.|r",
            },
            {
                name = "Skeletal Destroyer",
                strategy = "The Skeletal Destroyer summons three skeletons that will self-destruct if not killed in time, dealing heavy damage. "
                    .. "It uses |cFFD700Ground Stomp|r to create a persistent red circle DoT on the floor and |cFFD700Cleave|r, a frontal cone that should be blocked. "
                    .. "Scamp adds also spawn during the fight.\n\n"
                    .. "|c00FF00Focus the scamps first, then kill summoned skeletons before they self-destruct. "
                    .. "Move out of Ground Stomp red circles immediately. "
                    .. "Block the frontal Cleave attack. Tank should face the boss away from the group.|r",
            },
            {
                name = "High Kinlord Rilis",
                strategy = "Rilis summons |cFFD700Healing Orbs|r (called Feasts) from the altar that float toward him. "
                    .. "|cFF4444DPS must destroy these orbs before they reach the boss|r or he will heal to full. "
                    .. "He casts |cFFD700Ghost Fire|r, blue pools spawned at player locations that persist on the ground. "
                    .. "After Ghost Fire he follows up with |cFFD700Heavy Blow|r, telegraphed by yellow sparkles, which causes knockback.\n\n"
                    .. "|cFF4444Block the Heavy Blow when you see the yellow sparkle telegraph.|r "
                    .. "His |cFFD700Magic Bolt|r can one-shot low-health players but is blockable. "
                    .. "|c00FF00Destroying Healing Orbs is the absolute top priority. Evacuate from Ghost Fire pools and always block the Heavy Blow followup.|r",
            },
        },
    },
    ["The Banished Cells II"] = {
        order = 6,
        bosses = {
            {
                name = "Maw of the Infernal",
                strategy = "Maw of the Infernal drops a |cFFD700Fire Pool|r at the target's feet and uses |cFFD700Fire Breath|r, a conal attack aimed at a random player. "
                    .. "The fire pools persist and will cover the arena if the boss is moved too much.\n\n"
                    .. "|c00FF00Keep the boss stationary or slowly walk the perimeter to manage fire pool placement. "
                    .. "DPS and healers should always stand behind the boss to avoid the random Fire Breath cone. "
                    .. "Tank should face the boss toward a wall whenever possible.|r",
            },
            {
                name = "Keeper Imiril",
                strategy = "Keeper Imiril summons |cFFD700Draining Orbs|r from the braziers that drain magicka and stamina on contact. "
                    .. "She periodically flees and spawns waves of adds including banekin, matriarchs, and clannfear. "
                    .. "When she returns, she uses a |cFFD700Spinning Blade|r attack.\n\n"
                    .. "|c00FF00Avoid the draining orbs to maintain your resources. "
                    .. "Dump ultimates on the add waves to clear them quickly before the boss returns. "
                    .. "Be ready to block or dodge the Spinning Blade when she comes back into the fight.|r",
            },
            {
                name = "Sister Vera and Sister Sihna",
                strategy = "The twin Sisters use standard harvester attacks and an interruptible channel ability. "
                    .. "|cFF4444Bash them immediately when they begin channeling|r or they will heal significantly. "
                    .. "They alternate a |cFFD700Golden Shield|r that makes the shielded sister completely invulnerable.\n\n"
                    .. "|c00FF00Always attack the sister who does NOT have the golden shield. "
                    .. "When the shield swaps, immediately swap targets. "
                    .. "Assign interrupts so channels are always bashed. Keep both sisters in view so you can see which one has the shield.|r",
            },
            {
                name = "High Kinlord Rilis",
                strategy = "Rilis applies |cFFD700Curse Bubbles|r (blue and red) that debuff player movement speed. "
                    .. "|cFF4444Run to the Daedric rune circles around the room to cleanse curses|r before they stack. "
                    .. "He summons Healing Orbs, Daedroth adds that use conal fire breath and stomp fireballs, and casts |cFFD700Ghost Fire|r pools at player locations. "
                    .. "His |cFFD700Heavy Blow|r is telegraphed by yellow sparkles and must be blocked.\n\n"
                    .. "|c00FF00Priority order: Kill Healing Orbs first, then Daedroth adds, then DPS the boss. "
                    .. "Cleanse curses at the runes whenever debuffed. "
                    .. "Teleport phases and Ghost Fire make positioning critical. Block every Heavy Blow telegraph.|r",
            },
        },
    },
    ["Darkshade Caverns I"] = {
        order = 7,
        bosses = {
            {
                name = "Head Shepherd Neloren",
                strategy = "Neloren attacks with |cFFD700Flame Projectiles|r that deal moderate fire damage and periodically |cFFD700Self-Heals|r to recover health. "
                    .. "If the group is stacked, his projectiles can hit multiple people.\n\n"
                    .. "|c00FF00Spread out to avoid splash damage from the flame attacks. "
                    .. "Burn the boss quickly to outpace his self-healing. "
                    .. "This is a straightforward DPS check with no complex mechanics.|r",
            },
            {
                name = "Foreman Llothan",
                strategy = "Llothan repositions frequently and summons six kwama adds. His most dangerous ability is |cFFD700AoE Shock|r, a small red circle that deals massive damage and knockdown. "
                    .. "|cFF4444Dodge the red circle shock attack immediately|r as it can one-shot non-tanks. "
                    .. "He also drops |cFFD700Poison Pools|r on the ground.\n\n"
                    .. "|c00FF00AoE the kwama adds when they spawn. Move out of poison pools promptly. "
                    .. "The shock attack has a small radius so a quick dodge roll will get you clear. Stay mobile and aware of ground telegraphs.|r",
            },
            {
                name = "The Hive Lord",
                strategy = "The Hive Lord performs a |cFFD700Massive AoE Slam|r that creates a pulsing red circle around him dealing heavy damage per tick. "
                    .. "He summons kwama adds, uses |cFFD700Random Jumping Attacks|r to leap at distant players, and has a |cFFD700Frontal Cone Slam|r.\n\n"
                    .. "|cFF4444Vacate the red pulsing circles immediately|r as the stacking damage will kill you in seconds. "
                    .. "|c00FF00AoE the kwama adds when they appear. The tank should be prepared for the jumping attacks that temporarily redirect the boss. "
                    .. "Stay behind the boss to avoid the frontal cone.|r",
            },
            {
                name = "Cavern Patriarch",
                strategy = "The Cavern Patriarch drops a |cFFD700Poison Standard|r, a persistent ground AoE that deals poison damage to anyone standing in it. "
                    .. "Beyond this ability, the boss has minimal threat and uses basic melee attacks.\n\n"
                    .. "|c00FF00Simply move out of the Poison Standard when it is placed. "
                    .. "This is one of the easiest bosses in the dungeon and should go down quickly with any reasonable group composition.|r",
            },
            {
                name = "Cutting Sphere",
                strategy = "The Cutting Sphere channels a |cFFD700Whirlwind|r attack that deals continuous damage to anyone caught inside it. "
                    .. "Dwarven Spider adds spawn periodically and support the boss.\n\n"
                    .. "|c00FF00Kill the Dwarven Spiders as they spawn to reduce incoming damage. "
                    .. "Stay out of the Whirlwind channel area. "
                    .. "Ranged DPS can safely attack from outside the whirlwind while the tank holds position.|r",
            },
            {
                name = "Sentinel of Rkugamz",
                strategy = "The Sentinel uses |cFFD700Whirlwind Chase|r, spinning toward a player and dealing heavy damage on contact. "
                    .. "During the |cFFD700Healing Shield Phase|r, three to four spiders generate green healing bubbles that restore the boss's health. "
                    .. "It also has a frontal cone attack and |cFFD700Lightning Mortar|r that drops pools at player locations.\n\n"
                    .. "|cFF4444Kite the Whirlwind Chase away from the group|r and do not let it catch you. "
                    .. "|c00FF00If your group DPS is high enough, you can ignore the healing spiders and burn through the shield phase. "
                    .. "Otherwise, kill the spiders to stop the healing. Move out of Lightning Mortar pools as they appear.|r",
            },
        },
    },
    ["Darkshade Caverns II"] = {
        order = 8,
        bosses = {
            {
                name = "The Fallen Foreman",
                strategy = "The Fallen Foreman channels a |cFFD700Slow High-Damage Spell|r that can be interrupted with a bash. "
                    .. "|cFF4444Always interrupt this spell|r or it will deal devastating damage to the target. "
                    .. "He also uses a |cFFD700Fire Cone|r that slowly rotates clockwise around him.\n\n"
                    .. "|c00FF00Position ranged DPS on the stairs for a safe vantage point. "
                    .. "Assign someone to interrupt the channeled spell reliably. "
                    .. "Move with the Fire Cone rotation to stay behind it as it sweeps the room.|r",
            },
            {
                name = "Transmuted Hive Lord",
                strategy = "The Transmuted Hive Lord has |cFFD700Heavy Knockdown Hits|r that must be blocked by the tank. "
                    .. "Two adds accompany him: they knock players unconscious and drain stamina. "
                    .. "When the adds burrow underground, the boss gains a |cFFD700Damage Shield|r and begins a |cFFD700Ground Pound AoE|r.\n\n"
                    .. "|cFF4444Break the damage shield with sustained DPS|r to stop the Ground Pound phase. "
                    .. "|c00FF00Save burst damage for when the shield appears. "
                    .. "Keep stamina up so you can break free when knocked unconscious by the adds. "
                    .. "The tank must block through the heavy hits consistently.|r",
            },
            {
                name = "Grobull the Transmuted",
                strategy = "Grobull |cFFD700Teleports|r around the arena leaving AoE damage at each location. "
                    .. "He spawns adds that gain a protective shield and has a |cFFD700Vulnerable Phase|r where he drops to the ground and takes increased damage.\n\n"
                    .. "|c00FF00Move away from teleport AoE locations immediately. "
                    .. "When Grobull drops to the ground during his vulnerable phase, unleash all burst damage and ultimates. "
                    .. "Handle the shielded adds between vulnerable phases and stay mobile to avoid AoE stacking.|r",
            },
            {
                name = "The Engine Guardian",
                strategy = "The Engine Guardian cycles through three elemental phases. In |cFFD700Fire Phase|r, fireballs create persistent ground hazards. "
                    .. "In |cFFD700Poison Phase|r, continuous damage hits the whole group until all four levers are activated. "
                    .. "In |cFFD700Lightning Phase|r, being close to the boss deals massive damage. Dwarven Sphere adds spawn throughout.\n\n"
                    .. "|cFF4444During Poison Phase, all four players must pull the levers quickly|r or the group will die to sustained damage. "
                    .. "|c00FF00Stay at range during Fire Phase to avoid ground hazards. Use the levers immediately in Poison Phase. "
                    .. "Maintain distance during Lightning Phase. Kill Dwarven Sphere adds between phases.|r",
            },
        },
    },
    ["Elden Hollow I"] = {
        order = 9,
        bosses = {
            {
                name = "Akash gra-Mal",
                strategy = "Akash uses |cFFD700Reverse Uppercut|r, a heavy two-handed swing that knocks down anyone who fails to block. "
                    .. "She has an |cFFD700AoE Overhand Swing|r and a |cFFD700Forward Conal AoE|r that causes knockback.\n\n"
                    .. "|c00FF00Face the boss away from the group at all times so the conal attacks only hit the tank. "
                    .. "Block the Reverse Uppercut to prevent the knockdown. "
                    .. "DPS and healers should position behind her and watch for the AoE overhand swing.|r",
            },
            {
                name = "Chokethorn",
                strategy = "Chokethorn uses a |cFFD700Pull|r ability to yank players into melee range and summons |cFFD700Healing Stranglers|r that heal the boss if left alive. "
                    .. "His most dangerous attack is a |cFFD700Large Expanding AoE|r that deals approximately 90% of your health even through a block. "
                    .. "|cFF4444Dodge roll out of the expanding AoE immediately|r as blocking alone will not save you.\n\n"
                    .. "|c00FF00Kill the Healing Stranglers quickly or focus burn the boss if your DPS is high enough. "
                    .. "Save stamina for the dodge roll on the expanding AoE. "
                    .. "The pull into expanding AoE combo is the main kill mechanic.|r",
            },
            {
                name = "Nenesh gro-Mal",
                strategy = "Nenesh uses |cFFD700Lightning Form|r to buff himself, |cFFD700Two-Handed Uppercut|r for knockdown, and |cFFD700Mage Fury|r which can be interrupted with a bash. "
                    .. "He is accompanied by several adds.\n\n"
                    .. "|c00FF00Kill the adds first, then focus the boss. Interrupt Mage Fury whenever he casts it. "
                    .. "Block the Uppercut to avoid knockdown. "
                    .. "This is the easiest boss in Elden Hollow and should not pose any significant threat.|r",
            },
            {
                name = "Leafseether",
                strategy = "Leafseether uses |cFFD700Jump and Smack|r which can be avoided by strafing sideways, and a |cFFD700Conal AoE Suck-and-Chomp|r that pulls players in before biting. "
                    .. "Both attacks are avoidable by simply strafing. It also has a single target bite for the tank.\n\n"
                    .. "|c00FF00Kill the Alit add first, then focus the boss. "
                    .. "Strafe constantly to dodge both the jump and the conal suck attack. "
                    .. "This boss is very manageable as long as you keep moving laterally instead of standing still.|r",
            },
            {
                name = "Canonreeve Oraneth",
                strategy = "Oraneth drops a |cFFD700Frost Circle|r, fires a |cFFD700Poison Ball Projectile|r that should be dodge-rolled, and uses a |cFFD700Stun AoE|r that spawns four Darkfern Skeletons. "
                    .. "Her deadliest mechanic is a |cFFD700Growing AoE|r that expands from her feet. "
                    .. "|cFF4444The Growing AoE will one-shot anyone who does not block or dodge roll out of it.|r\n\n"
                    .. "|c00FF00The Growing AoE is the primary wipe mechanic. Watch for it and either block or dodge roll immediately. "
                    .. "Dodge roll the Poison Ball projectiles. Kill the Darkfern Skeletons when they spawn from the stun AoE. "
                    .. "Stay aware of ground effects and maintain stamina for emergency dodge rolls.|r",
            },
        },
    },
    ["Elden Hollow II"] = {
        order = 10,
        bosses = {
            {
                name = "Dubroze the Infestor",
                strategy = "Dubroze summons |cFFD700Frightener Adds|r that attack from range and uses a |cFFD700Frontal AoE Fire Cone|r that deals heavy fire damage. "
                    .. "The adds can overwhelm the healer if left unchecked.\n\n"
                    .. "|c00FF00Kill the Frightener adds as they spawn. "
                    .. "Face the boss away from the group so the fire cone only hits the tank. "
                    .. "DPS should stay behind the boss and switch to adds immediately when they appear.|r",
            },
            {
                name = "Dark Root",
                strategy = "Dark Root spawns bug adds that drain stamina and magicka from players. When killed, the bugs leave behind buff pools on the ground: "
                    .. "blue pools restore magicka and green pools restore stamina. "
                    .. "The boss uses a |cFFD700Radiance Attack|r beam that must be blocked.\n\n"
                    .. "|c00FF00Kill the bug adds in separate locations to spread out the buff pools across the arena. "
                    .. "Stand in the pools matching the resource you need. "
                    .. "Block the Radiance beam attack when it targets you. This fight rewards good add management and pool placement.|r",
            },
            {
                name = "Azura the Frightener",
                strategy = "Azura summons |cFFD700Mind-Control Adds|r that take control of your allies. "
                    .. "She uses an interruptible |cFFD700Shout|r that stuns nearby players. "
                    .. "|cFF4444Kill the mind-control adds to free your allies|r before they turn on the group.\n\n"
                    .. "|c00FF00Interrupt the Shout whenever she begins casting it. "
                    .. "Prioritize killing mind-control adds immediately to free dominated party members. "
                    .. "The fight becomes chaotic if adds are ignored and multiple allies are controlled simultaneously.|r",
            },
            {
                name = "Murklight",
                strategy = "Murklight uses a |cFFD700Frontal AoE|r and drops |cFFD700Red Circles|r on the ground. "
                    .. "As the fight progresses, some red circles turn white. |cFF4444Red circles deal damage|r, but white circles become safe zones that you will need later.\n\n"
                    .. "|c00FF00Face the boss away from the group. Avoid red circles but remember where the white safe zones form. "
                    .. "Later in the fight, the white zones may provide protection from arena-wide damage. "
                    .. "Keep track of which circles have transitioned to white.|r",
            },
            {
                name = "The Shadow Guard",
                strategy = "The Shadow Guard summons multiple waves of adds and creates a |cFFD700Large Ground AoE|r that covers significant portions of the arena. "
                    .. "|cFF4444Block through the ground AoE|r if you cannot escape it in time.\n\n"
                    .. "|c00FF00Ranged DPS have an advantage in this fight as they can attack from outside the ground AoE. "
                    .. "Kill the adds as they spawn to prevent being overwhelmed. "
                    .. "Stay mobile and use the full arena space to avoid the large AoE zones.|r",
            },
            {
                name = "Bogdan the Nightflame",
                strategy = "Bogdan summons four to six Shades throughout the fight. Black Shades should be ignored, but |cFF4444White Shades must be interrupted immediately|r or they will mind-control players. "
                    .. "|cFFD700Fire Breath|r deals approximately 20,000 damage and must be aimed away from the group. "
                    .. "Every twenty seconds, |cFFD700Tracking Fire Puddles|r spawn at player locations. "
                    .. "His |cFFD700Massive AoE Stomp|r clears all fire puddles but deals heavy damage to everyone.\n\n"
                    .. "|c00FF00Start the fight spread out in the corners to maximize fire puddle space. "
                    .. "Ignore black Shades entirely but interrupt white Shades on sight. "
                    .. "Block the Massive Stomp as it hits the whole arena. The stomp clears fire so it resets the arena, but you must survive it.|r",
            },
        },
    },
    ["Wayrest Sewers I"] = {
        order = 11,
        bosses = {
            {
                name = "Slimecraw",
                strategy = "Slimecraw uses a |cFFD700Frontal Cone Tailswipe|r that deals high physical damage and knocks back anyone caught in it. "
                    .. "The attack covers a wide arc in front of the boss.\n\n"
                    .. "|c00FF00Face the boss away from the group. DPS and healers stay behind at all times. "
                    .. "This is a simple tank-and-spank fight with no special phases or add spawns.|r",
            },
            {
                name = "Investigator Garron",
                strategy = "Garron teleports around the room and fires a |cFFD700Green Orb|r that chases a random player. "
                    .. "He summons Restless Soul ghosts with only 717 HP that attack at range, and uses a |cFFD700Ranged Knockback|r ability.\n\n"
                    .. "|cFF4444Do not drag the green orb through your group|r as it damages everything in its path. "
                    .. "|c00FF00Kite the orb away from allies. Kill the Restless Soul ghosts quickly since they have very low health. "
                    .. "Stay spread to minimize knockback disruption.|r",
            },
            {
                name = "Uulgarg the Hungry",
                strategy = "Uulgarg uses an |cFFD700AoE Fear|r that causes players to flee uncontrollably for several seconds. "
                    .. "He follows the fear with a |cFFD700Heavy Melee|r strike, creating the deadly Fear plus Heavy combo. "
                    .. "|cFF4444This combo is the main wipe mechanic|r because feared players cannot block the incoming heavy attack.\n\n"
                    .. "|c00FF00Break free from the fear immediately, then block the heavy attack that follows. "
                    .. "Keep your stamina high at all times so you can always break free. "
                    .. "He also uses a Whirlwind attack that deals moderate damage around him.|r",
            },
            {
                name = "The Rat Whisperer",
                strategy = "The Rat Whisperer places a |cFFD700Magic AoE|r red circle at the tank's location and summons waves of skeevers. "
                    .. "She also uses a |cFFD700Cold Damage Root|r that immobilizes players in place.\n\n"
                    .. "|c00FF00Move out of the red circles when they appear under you. "
                    .. "AoE the skeevers as they spawn to prevent being overwhelmed. "
                    .. "Break free from the cold root quickly and keep mobile throughout the fight.|r",
            },
            {
                name = "Varaine Pellingare",
                strategy = "Varaine uses a |cFFD700Heavy Melee|r attack that must be blocked, an |cFFD700Expanding AoE Spell|r that deals heavy damage plus a stun, "
                    .. "and a |cFFD700Frontal Cone|r that knocks down anyone in front of him.\n\n"
                    .. "|c00FF00Block the heavy melee attacks. Dodge roll out of the expanding AoE to avoid the stun. "
                    .. "Face the boss away from the group to prevent the frontal cone from hitting DPS and healers. "
                    .. "This is a mechanics check fight that punishes players who do not block or dodge.|r",
            },
            {
                name = "Allene Pellingare",
                strategy = "Allene uses a |cFFD700Heavy Melee|r attack and |cFFD700Teleport Strike|r which damages and snares the target. "
                    .. "At every 25% health threshold she spawns |cFFD700Bat Adds|r with only 562 HP each. "
                    .. "In her final phase she enters |cFFD700Ghost Form|r, increasing her damage significantly.\n\n"
                    .. "|c00FF00AoE the bat waves immediately when they spawn at each health threshold. "
                    .. "The bats have very low health and die to a single AoE pulse. "
                    .. "During the final Ghost Form phase, burn her down quickly as her increased damage makes a prolonged fight dangerous.|r",
            },
        },
    },
    ["Wayrest Sewers II"] = {
        order = 12,
        bosses = {
            {
                name = "Malubeth the Scourger",
                strategy = "Malubeth fires |cFFD700Blue Bolt|r attacks and drops |cFFD700Red Circles|r that later turn blue and become even more dangerous. "
                    .. "She uses a |cFFD700Lifting Attack|r that suspends players in the air. "
                    .. "|cFF4444Run to the Daedric Altars to break free|r from the lifting attack.\n\n"
                    .. "|c00FF00Exit red circles before they turn blue, as the blue version deals significantly more damage. "
                    .. "Keep mobile throughout the fight and know where the Daedric Altars are located for emergency cleansing. "
                    .. "This fight punishes stationary play.|r",
            },
            {
                name = "Uulgarg the Risen",
                strategy = "Uulgarg uses a |cFFD700Fear|r ability that causes players to flee, leaving a |cFFD700Fire Trail|r behind them as they run. "
                    .. "He also performs |cFFD700Heavy Sword Swings|r that deal massive damage.\n\n"
                    .. "|cFF4444Interrupt the Fear cast|r before it goes off to prevent the fire trails from covering the arena. "
                    .. "|c00FF00Do not run through existing fire trails as they deal continuous damage. "
                    .. "If feared, the fire trail you leave behind will make the arena increasingly hazardous for everyone.|r",
            },
            {
                name = "Skull Reaper",
                strategy = "The Skull Reaper is an optional boss accompanied by four Healer Skeleton adds with approximately 2500 HP each. "
                    .. "It uses a |cFFD700Frontal Cone|r attack that is |cFF4444fatal if not blocked|r.\n\n"
                    .. "|c00FF00Kill all four healer skeletons first to stop them from sustaining the boss. "
                    .. "Always block the frontal cone attack. "
                    .. "Tank should face the boss away from the group. This boss is optional but drops useful loot.|r",
            },
            {
                name = "Garron the Returned",
                strategy = "Garron drops |cFFD700AoE Circles|r and summons four ghost adds with 2500 HP that root players and deal damage. "
                    .. "His |cFFD700Heavy Beam Attack|r is his highest damage ability and can devastate unprepared targets.\n\n"
                    .. "|c00FF00Crowd control the ghosts immediately when they spawn to prevent the root. "
                    .. "Pre-cast heals before the Heavy Beam attack lands to keep the target alive. "
                    .. "Move out of AoE circles and burn the ghost adds quickly between beam attacks.|r",
            },
            {
                name = "The Lost One",
                strategy = "The Lost One summons multiple waves of adds and uses a |cFFD700Frontal Wave|r attack that can one-shot any non-tank player who fails to block. "
                    .. "|cFF4444Never stand in front of the boss unless you are the tank.|r\n\n"
                    .. "|c00FF00Kill the adds first to reduce incoming damage. "
                    .. "The tank must block the Frontal Wave and keep the boss faced away from the group at all times. "
                    .. "DPS and healers should stay strictly behind the boss. This mechanic kills more players than any other in this dungeon.|r",
            },
            {
                name = "Varaine and Allene Pellingare",
                strategy = "Both Pellingare siblings fight together. Varaine uses circle and cone attacks. "
                    .. "Periodically both bosses disappear and spawn bat adds with 3000-5000 HP. "
                    .. "The boss with lower health gains an |cFFD700Immunity Shield|r lasting up to 20 seconds, preventing all damage.\n\n"
                    .. "|cFF4444Balance your damage on both bosses and keep them at roughly equal health|r to minimize shield uptime. "
                    .. "|c00FF00Crowd control the bat adds when they spawn during disappearance phases. "
                    .. "If one boss shields, immediately swap to the other. "
                    .. "Coordinate DPS to keep health percentages close and burn both down evenly for a clean kill.|r",
            },
        },
    },

    ["Arx Corinium"] = {
        order = 13,
        bosses = {
            {
                name = "Fanged Menace",
                strategy = "|cFF4444Frontal Cone|r does knockback and severe damage, so the tank must face this boss away from the group at all times. "
                    .. "The boss periodically casts |cFFD700AoE Poison|r and |cFFD700Health Absorb|r which heals it, so burn through the healing by focusing DPS. "
                    .. "A |cFF4444Red Circle|r appears under the boss that deals heavy damage and heals it significantly — move the boss out of this zone immediately.\n\n"
                    .. "|c00FF00Kill all adds first|r before focusing on the boss, as they increase overall group damage taken. "
                    .. "The boss also has a |cFFD700Heavy Melee|r attack that the tank should block. "
                    .. "Keeping the boss away from red circles is the single most important mechanic to manage in this fight.",
            },
            {
                name = "Ganakton the Tempest",
                strategy = "|cFFD700Lightning Wave|r targets a random player, dealing shock damage and stunning them — spread out to avoid chaining this to allies. "
                    .. "A |cFFD700Lightning Bolt|r follows the wave along the same path, so move out of the trajectory immediately after the wave passes. "
                    .. "The boss casts |cFFD700Shock Pulse|r which is unavoidable medium damage to all players, so healers should keep the group topped off.\n\n"
                    .. "|cFF4444Frontal Cone Lightning Breath|r deals massive damage in a wide arc, so the tank must face the boss away from the group. "
                    .. "|c00FF00Spread out|r to minimize the impact of random targeting abilities. "
                    .. "Prioritize break-free stamina management since the stuns from Lightning Wave can be deadly if followed by other mechanics.",
            },
            {
                name = "Sliklenia the Songstress",
                strategy = "This boss has a |c00FF00friendly pet add|r that spawns during the fight — do NOT kill it until the boss is dead, as it provides a critical mechanic. "
                    .. "When the boss begins singing, she casts |cFF4444Sound Pulse|r which deals extremely high damage to the entire group and will quickly wipe you.\n\n"
                    .. "To survive the singing phase, |c00FF00follow the pet|r to the sonic shield it creates, which blocks the sound damage entirely. "
                    .. "Stay inside the shield until the singing stops, then resume DPS on the boss. "
                    .. "If the pet dies before the boss, there is no way to avoid the Sound Pulse and the group will wipe. "
                    .. "Communicate with your group to ensure no one accidentally kills the pet with AoE damage.",
            },
            {
                name = "Matron Ixniaa",
                strategy = "The primary mechanic is the |cFF4444Double Circle|r — two concentric circles that appear on a random player. "
                    .. "The |cFF4444inner circle is fatal|r and must be avoided at all costs; even tanky players will be one-shot by standing in it. "
                    .. "The outer circle deals moderate damage but is survivable with healing.\n\n"
                    .. "The boss also spawns |cFFD700adds|r throughout the fight that should be killed quickly to reduce group pressure. "
                    .. "|c00FF00When you see the double circle appear beneath you, dodge roll out immediately|r and do not return until both circles fade. "
                    .. "Healers should be ready to top off anyone clipped by the outer ring. "
                    .. "Keep the fight area clear of adds so players have room to maneuver away from the circles.",
            },
            {
                name = "Sellistrix the Lamia Queen",
                strategy = "The queen uses |cFFD700Charge|r to rush at random players, so stay spread out across the island platforms. "
                    .. "|cFF4444Lightning Strikes|r mark the islands and when the queen enters the water she electrifies it, dealing lethal damage to anyone standing in it. "
                    .. "|c00FF00Stay on the islands at all times|r and move between them only when necessary.\n\n"
                    .. "The boss has a |cFF4444Frontal Cone Scream|r that randomly targets players and ignores taunts entirely, making positioning unpredictable. "
                    .. "After the scream, the tank must |c00FF00taunt five times|r to re-establish aggro on the boss. "
                    .. "Avoid electrified water at all costs — if the queen moves into the water, get to high ground immediately and wait for the electricity to dissipate. "
                    .. "This is a movement-heavy fight where awareness of water and island positioning determines survival.",
            },
        },
    },
    ["City of Ash I"] = {
        order = 14,
        bosses = {
            {
                name = "Infernal Guardian",
                strategy = "The Infernal Guardian uses |cFFD700AoE Fire Attacks|r that cover large portions of the arena, requiring constant repositioning. "
                    .. "The boss selects targets at random for many of its abilities, so everyone must stay alert regardless of role.\n\n"
                    .. "|c00FF00Dodge fire zones immediately|r when they appear beneath you, as standing in them deals significant damage over time. "
                    .. "Healers should keep the entire group at maximum health since the random target selection means anyone can take a heavy hit at any moment. "
                    .. "This is a straightforward fight that tests basic awareness and fire avoidance. "
                    .. "Stay mobile and don't stack too tightly to avoid multiple players being caught in the same AoE.",
            },
            {
                name = "Warden of the Shrine",
                strategy = "The Warden's |cFF4444Power Attacks|r are the defining mechanic of this fight — the tank |cFF4444must block every single one|r without exception or face a devastating knockdown. "
                    .. "The boss drops |cFFD700Fire Zones|r on the ground that persist and shrink the safe area over time.\n\n"
                    .. "Random |cFFD700AoE attacks|r target group members, so healers need to keep everyone healthy through the constant pressure. "
                    .. "|c00FF00The tank should never drop block when the boss winds up a power attack|r — this is non-negotiable for survival. "
                    .. "DPS should avoid fire zones while maintaining uptime on the boss. "
                    .. "Keep stamina reserves high for blocking, and position the boss to minimize fire zone coverage of the arena.",
            },
            {
                name = "Razor Master Erthas",
                strategy = "Erthas uses |cFFD700AoE Fire|r around his position and a |cFF4444Cross-Shaped AoE Fire|r pattern that is significantly harder to avoid due to its wide coverage. "
                    .. "He |cFFD700teleports|r frequently, repositioning across the arena and forcing the group to constantly readjust.\n\n"
                    .. "A |cFFD700Flame Atronach|r add spawns during the fight and must be killed quickly to reduce overall damage. "
                    .. "|c00FF00Ranged DPS have a much easier time|r in this fight since they can maintain damage while staying clear of his melee-range fire. "
                    .. "|c00FF00Save stamina for dodge rolling the cross-shaped fire pattern|r, as it covers both axes and is the most lethal ability. "
                    .. "Kill the Flame Atronach as soon as it spawns, then return focus to the boss.",
            },
        },
    },
    ["City of Ash II"] = {
        order = 15,
        bosses = {
            {
                name = "Xivilai Rukhan",
                strategy = "Rukhan is accompanied by |cFFD700two Dremora|r — a Mage and an Archer — who teleport randomly around the arena, making them difficult to pin down. "
                    .. "|c00FF00Kill the Dremora first|r, as they deal significant combined damage and the boss becomes much more manageable alone.\n\n"
                    .. "When a companion dies, a |cFFD700Flame Atronach|r spawns in its place, so be ready for the transition. "
                    .. "The boss uses a |cFFD700Heavy Attack|r that must be blocked and drops |cFF4444Red Circles|r at close range. "
                    .. "|c00FF00Fight from 8+ meters away|r to avoid the red circle placement entirely. "
                    .. "Ranged DPS and healers should maintain distance while the tank holds the boss away from the group.",
            },
            {
                name = "Urata the Legion",
                strategy = "Urata spawns approximately |cFF444420 adds|r throughout the fight, making this an AoE-heavy encounter. "
                    .. "|cFF4444Red Circles|r constantly appear on players, so you must stay mobile at all times to avoid taking unnecessary damage.\n\n"
                    .. "|c00FF00Stack and AoE the adds down|r as quickly as possible while continuing to move out of red circles. "
                    .. "This fight is excellent for building ultimate, so use it as a resource-building opportunity for the harder bosses ahead. "
                    .. "Healers should use ground-based heals that the group can move through. "
                    .. "Don't try to stand still and burn — mobility is survival in this encounter.",
            },
            {
                name = "Xivilai Boltaic and Xivilai Fulminator",
                strategy = "This is a straightforward dual-boss encounter with no complex mechanics to worry about. "
                    .. "|c00FF00Focus one boss down completely, then switch to the other|r to simplify the fight.\n\n"
                    .. "The tank should try to stack both bosses for cleave damage when possible. "
                    .. "Both Xivilai use basic shock-themed attacks that are easily healed through. "
                    .. "This is a quick fight that serves as a breather between the harder encounters in City of Ash II.",
            },
            {
                name = "Horvantud the Fire Maw",
                strategy = "Horvantud spews |cFFD700Lava|r in a frontal cone that deals devastating damage, so the tank must |c00FF00face the boss away|r from the group at all times. "
                    .. "|cFFD700Earthquakes|r cause rocks to erupt from the floor in random locations, creating hazardous ground.\n\n"
                    .. "The boss also performs a |cFFD700Stomp|r that places |cFF4444red circles|r around the arena. "
                    .. "|c00FF00Roll out of frontal cleaves|r immediately when you see them telegraph. "
                    .. "Melee DPS should stay behind or to the side of the boss to avoid the lava spew. "
                    .. "Keep mobile during earthquake phases and avoid stacking in tight spaces where rocks can trap you.",
            },
            {
                name = "Ash Titan",
                strategy = "The Ash Titan drops |cFF4444Fire Circles|r at players' feet that persist on the ground, gradually reducing safe space. "
                    .. "It periodically |cFFD700jumps|r to a new location and sends out |cFFD700Fire Waves|r on landing that must be dodge rolled.\n\n"
                    .. "Weak adds spawn throughout the fight and should be cleaved down with AoE abilities. "
                    .. "|c00FF00Watch for double spawn waves|r where adds come from multiple directions simultaneously. "
                    .. "Avoid standing in fire circles and position yourself to keep the arena as clean as possible. "
                    .. "The tank should try to keep the boss in areas already covered by fire to preserve clean ground for the group.",
            },
            {
                name = "Valkyn Skoria",
                strategy = "|cFF4444Lava Pools|r are the defining mechanic — they persist permanently and steadily reduce the safe area of the arena, so the tank must position carefully to minimize coverage. "
                    .. "|cFFD700Flame Strike/Meteor|r targets a random player with a large AoE that deals massive damage, so spread out and dodge when targeted.\n\n"
                    .. "The boss uses a |cFFD700Conal Flame Breath|r that the tank must face away from the group. "
                    .. "During |cFF4444Shield Phase|r, Flame Atronach adds spawn and must be killed to break the boss's shield — focus them immediately. "
                    .. "At low health the boss |cFF4444enrages|r, dealing significantly increased damage. "
                    .. "|c00FF00Save ultimates for the enrage below 25% health|r and burn as fast as possible. "
                    .. "Kill atronachs during shield phases without hesitation, and coordinate defensive cooldowns for the final burn.",
            },
        },
    },
    ["Crypt of Hearts I"] = {
        order = 16,
        bosses = {
            {
                name = "The Mage Master",
                strategy = "The Mage Master summons |cFFD700Skeleton Mage adds|r that deal ranged damage and should be killed quickly to reduce group pressure. "
                    .. "The boss has a |cFFD700Heavy Melee|r attack that the tank must block to avoid knockdown.\n\n"
                    .. "A |cFFD700Blue Bubble Dispel Zone|r appears periodically — if you stand in it, your debuffs on the boss are cleansed, reducing group DPS. "
                    .. "|c00FF00Avoid the blue bubble|r and continue DPS from outside its radius. "
                    .. "Kill adds as they spawn, then return focus to the boss. "
                    .. "This is a relatively simple fight as long as the group avoids standing in the dispel zone.",
            },
            {
                name = "Archmaster Siniel",
                strategy = "Siniel casts an |cFF4444AoE Fear|r that stuns the entire group for several seconds, leaving everyone vulnerable to damage. "
                    .. "|c00FF00Break free from the fear immediately|r — this is the highest priority in the fight.\n\n"
                    .. "The boss summons |cFFD700Undead|r with only 110 HP each, making them perfect targets for any AoE ability. "
                    .. "|cFF4444Red Circles|r appear on the ground and must be avoided. "
                    .. "Use AoE abilities to sweep through the undead adds while maintaining DPS on the boss. "
                    .. "Keep stamina available for breaking free from fear, as being stunned during a red circle is often lethal.",
            },
            {
                name = "Death's Leviathan",
                strategy = "This boss has two phases, transitioning at approximately |cFF444450% health|r. In Phase 1, an |cFF4444Expanding Red Circle|r grows outward and is very hard to escape — it can one-shot players who don't dodge out in time.\n\n"
                    .. "In Phase 2, the boss performs a |cFFD700Straight-Line Charge|r that leaves a |cFF4444Fire Path|r behind it, and gains a |cFFD700Fire Buff|r that increases its damage. "
                    .. "|c00FF00Save ultimates and resources for Phase 2|r, as the fight becomes significantly harder after the transition. "
                    .. "Dodge the expanding circle by rolling outward as soon as you see it begin to grow. "
                    .. "Phase 2 requires constant movement to avoid fire paths while burning the boss down before the fire buff stacks too high.",
            },
            {
                name = "Uulkar Bonehand",
                strategy = "|cFF4444Red Ground Circles|r appear at player positions and erupt into spikes after a few seconds, stunning and damaging anyone still standing in them. "
                    .. "The boss also places |cFFD700Snare Runes|r that slow player movement, making it harder to escape the red circles.\n\n"
                    .. "|c00FF00Move out of red circles immediately|r when they appear — do not wait for the spike eruption. "
                    .. "Be especially careful when snared, as the reduced movement speed makes escaping circles much more difficult. "
                    .. "Cleanse snares when possible, and keep the fight moving to avoid overlapping circle and rune placements. "
                    .. "This fight is all about constant repositioning and awareness of the ground beneath you.",
            },
            {
                name = "Dogas the Berserker",
                strategy = "Dogas casts an |cFF4444AoE Stun|r that lasts 4-5 seconds, completely locking down the group and leaving everyone vulnerable. "
                    .. "He follows up with a |cFFD700Health Leeching Jump Attack|r that deals heavy damage and heals himself.\n\n"
                    .. "|c00FF00Using an Immovable ability completely trivializes this fight|r, as it prevents the stun from taking effect. "
                    .. "If you don't have Immovable, keep stamina reserved for break free. "
                    .. "The tank should separate from the group to isolate the jump attack and take it alone. "
                    .. "This is a short fight if the stun mechanic is handled properly with Immovable or quick break-free reactions.",
            },
            {
                name = "Ilambris-Zaven and Ilambris-Athor",
                strategy = "|cFFD700Ilambris-Zaven|r uses fire abilities including a |cFFD700Fire Spell Charge|r and an |cFF4444Expanding Flame Circle|r that deals heavy damage. "
                    .. "|cFFD700Ilambris-Athor|r focuses on lightning with a |cFFD700Lightning DoT|r, |cFFD700Lightning Runes|r on the ground, and a |cFFD700Heavy Melee|r attack.\n\n"
                    .. "|cFF4444When Zaven dies, Athor enrages|r and gains a devastating lightning rain attack that covers most of the arena. "
                    .. "|c00FF00Kill both bosses as simultaneously as possible|r — balance DPS between them to bring their health down evenly. "
                    .. "If Athor's enrage triggers, the lightning rain makes the fight nearly impossible for unprepared groups. "
                    .. "Assign DPS to each boss and communicate health percentages to ensure a clean double-kill.",
            },
        },
    },
    ["Crypt of Hearts II"] = {
        order = 17,
        bosses = {
            {
                name = "Ibelgast",
                strategy = "|cFF4444Red Circle AoE|r appears under random players and must be dodged immediately to avoid heavy damage. "
                    .. "The boss uses a |cFFD700Heavy Uppercut|r that must be blocked by the tank to prevent knockdown.\n\n"
                    .. "|cFFD700Negate Magic|r suppresses your ability to interrupt — use break free to escape this effect. "
                    .. "|cFFD700Healer Adds|r spawn during the fight and |c00FF00must be killed first|r, as they will keep the boss alive indefinitely. "
                    .. "Interrupt the healer adds as soon as they begin casting, then burn them down. "
                    .. "Avoid red circles while prioritizing add management over boss DPS.",
            },
            {
                name = "Ruzozuzalpamaz",
                strategy = "The boss channels |cFFD700Lightning on the tank|r, dealing steady damage that requires consistent healing. "
                    .. "|cFF4444Cobweb Strangle|r immobilizes a player and they cannot break free on their own — another player must use the |c00FF00synergy to free them|r immediately.\n\n"
                    .. "A |cFF4444Moving Red Circle|r — a giant shifting AoE — roams the arena and must be avoided at all times. "
                    .. "|cFFD700Spider Adds|r spawn and apply snares, making it harder to escape the moving circle. "
                    .. "|c00FF00Free allies from Cobweb Strangle immediately|r, as being immobilized while the moving circle approaches is lethal. "
                    .. "Kill spider adds quickly to prevent snare stacking, and always watch for the shifting AoE.",
            },
            {
                name = "Chamber Guardian",
                strategy = "The Chamber Guardian casts |cFF4444Spectre Wave|r which fears the entire group, causing loss of control for several seconds. "
                    .. "|c00FF00Break free from fear immediately|r to regain control and avoid being caught in other mechanics.\n\n"
                    .. "The boss uses |cFFD700Heavy Attacks|r that must be blocked by the tank. "
                    .. "|cFFD700Skeleton Adds|r spawn throughout the fight and should be AoE'd down quickly. "
                    .. "Keep stamina reserved for breaking fear, and don't let skeleton adds overwhelm the healer. "
                    .. "This is a straightforward fight once the group learns to break free from fear consistently.",
            },
            {
                name = "Ilambris Amalgam",
                strategy = "|cFFD700Blue Daedra|r uses lightning and melee AoE attacks and |c00FF00must be killed first|r. "
                    .. "|cFFD700Red Daedra|r uses fire abilities and leaves heat trails on the ground. "
                    .. "|cFFD700Bone Constructs|r have a frontal cone attack and a 360-degree stomp that hits everyone nearby.\n\n"
                    .. "After the adds die, |cFF4444Rain of Fire|r begins covering the arena. "
                    .. "The kill order is |c00FF00Blue Daedra > Red Daedra > Bone Constructs|r. "
                    .. "At |cFF444420% health|r the boss enrages and spawns more adds — at this point, ignore adds and |c00FF00burn the boss|r as fast as possible. "
                    .. "Save ultimates for the 20% burn phase to end the fight before the adds overwhelm the group.",
            },
            {
                name = "Mezeluth",
                strategy = "Mezeluth is |cFFD700stationary and cannot be moved|r, so the group must position around her carefully. "
                    .. "|cFFD700Fire Circles|r appear on the ground around the boss, limiting safe positioning.\n\n"
                    .. "|cFF4444Explosion Circles|r target specific players and cause knockdown on detonation. "
                    .. "|c00FF00Don't stand in more than one circle at a time|r, as overlapping explosions will kill you instantly. "
                    .. "Spread out around the boss and coordinate positioning so circles don't overlap. "
                    .. "Communication is key — call out your position and move predictably so the group can maintain spacing.",
            },
            {
                name = "Nerien'eth",
                strategy = "|cFF4444Skulls|r target random players dealing heavy damage with knockdown — |cFF4444BLOCK these|r every time you see one coming at you. "
                    .. "The boss fires |cFFD7004 Consecutive AoE Explosions|r, so spread out to avoid stacking damage. "
                    .. "He |cFFD700teleports|r and unleashes a |cFFD700360 Burst|r on arrival, hitting everyone nearby.\n\n"
                    .. "|cFFD700Wraith Summons|r appear and the tank must hold both the boss and wraiths. "
                    .. "At |cFF444435% health|r, the |cFFD700Sword Phase|r begins where the boss hits random players extremely hard. "
                    .. "The boss also uses |cFF4444Drain Attack|r — a stun + channel + damage shield combo. Use the |c00FF00Resist Necrosis synergy|r to counter it, and break the damage shield as a group. "
                    .. "For Hard Mode, delay killing the Wraiths until the 35% phase. "
                    .. "Save defensive cooldowns and ultimates for the chaotic final phase.",
            },
        },
    },
    ["Direfrost Keep"] = {
        order = 18,
        bosses = {
            {
                name = "Teethnasher the Frostbound",
                strategy = "Teethnasher |cFFD700charges|r at players and then pauses briefly before attacking, giving you a small window to react. "
                    .. "A |cFF4444Red Circle|r appears dealing heavy damage and applying a movement snare to anyone caught inside.\n\n"
                    .. "|c00FF00Keep moving at all times|r to avoid being caught in the red circle after the charge. "
                    .. "The snare from the red circle makes subsequent charges much harder to avoid, so prevention is critical. "
                    .. "Healers should cleanse the snare if possible, and DPS should maintain mobile rotations. "
                    .. "This is a simple fight that teaches the importance of constant movement.",
            },
            {
                name = "Guardian of the Flame",
                strategy = "The Guardian performs |cFFD700Random Charges|r at players that deal AoE splash damage on impact, so |c00FF00spread out|r to avoid chaining damage. "
                    .. "A |cFFD700Heavy Attack|r must be blocked by the tank to prevent knockdown.\n\n"
                    .. "|cFFD700Lightning Patches|r appear on the ground and persist, reducing safe space. "
                    .. "The boss has a |cFF4444Breath Attack|r frontal cone that deals devastating damage — the tank must face the boss away from the group. "
                    .. "Spread out for charges so only one player takes splash damage at a time. "
                    .. "Stay mobile to avoid lightning patches while maintaining DPS uptime.",
            },
            {
                name = "Drodda's Dreadlord",
                strategy = "The Dreadlord fights with a |cFFD700Melee Axe|r and uses a |cFFD700Heavy Attack|r that must be blocked by the tank. "
                    .. "|cFFD700Frigid Banekins|r spawn at the boss's original position and charge at random players.\n\n"
                    .. "|c00FF00Move the boss away from its spawn point|r so that banekins have to travel farther before reaching the group, giving you more time to kill them. "
                    .. "The banekins deal frost damage on contact and can overwhelm the healer if too many reach the group. "
                    .. "AoE them down as they approach while the tank keeps the boss positioned far from spawn. "
                    .. "This is a positioning fight where smart boss placement makes the add management trivial.",
            },
            {
                name = "Iceheart",
                strategy = "Iceheart uses a |cFF4444Frontal Cone|r attack that must be blocked by the tank — it deals heavy damage even through block. "
                    .. "|cFFD700Ground AoE circles|r appear around the arena and must be avoided.\n\n"
                    .. "The boss performs a |cFFD700Fist Smash|r that places a damaging circle at each player's location, so spread out to avoid overlapping. "
                    .. "|c00FF00Heavy healing is required|r throughout this fight due to the constant group-wide damage pressure. "
                    .. "Healers should use strong HoTs and burst heals to keep the group alive through Fist Smash phases. "
                    .. "Stay spread and avoid ground circles while the healer works overtime.",
            },
            {
                name = "Drodda of Icereach",
                strategy = "Drodda |cFFD700teleports|r to a new location and immediately begins casting a |cFF4444Frost AoE|r — |c00FF00move away from her before the cast completes|r to avoid massive damage. "
                    .. "She applies |cFFD700Periodic Stuns|r throughout the fight that must be broken free from immediately.\n\n"
                    .. "At |cFF444450% health|r, |cFFD700Ice Wraiths|r spawn and must be |c00FF00killed immediately|r as they deal heavy damage and can overwhelm the group. "
                    .. "Prioritize wraiths over the boss at 50% — failing to kill them quickly will likely cause a wipe. "
                    .. "Keep stamina reserved for break-free throughout the fight, and always be ready to move when she teleports. "
                    .. "After clearing wraiths, resume boss DPS and watch for continued teleport patterns.",
            },
        },
    },
    ["Tempest Island"] = {
        order = 19,
        bosses = {
            {
                name = "Sonolia the Matriarch",
                strategy = "Sonolia summons |cFFD700Lamia Adds|r that deal significant damage and should be killed before focusing the boss. "
                    .. "She uses a |cFF4444Disorienting Sound Cone|r that deals heavy damage in a wide frontal arc.\n\n"
                    .. "|c00FF00Kill adds first|r to reduce overall damage pressure on the healer. "
                    .. "The tank must |c00FF00face the boss away|r from the group to prevent the sound cone from hitting DPS and healers. "
                    .. "The sound cone can disorient players, causing temporary loss of control. "
                    .. "Stay behind the boss at all times and prioritize add management over boss damage.",
            },
            {
                name = "Valaran Stormcaller",
                strategy = "Valaran has a |cFFD700Lightning Defense|r that shocks anyone standing too close, making melee DPS risky during this phase. "
                    .. "A |cFF4444Moving Lightning Strike|r tracks across the ground and must be |cFF4444avoided at all costs|r — it deals lethal damage.\n\n"
                    .. "|cFFD700Random Stuns|r lasting 3-4 seconds hit players and must be broken free from immediately. "
                    .. "The boss uses |cFFD700Heavy Attacks|r that must be blocked by the tank. "
                    .. "|c00FF00Be aware that the boss may ignore taunts|r, so DPS and healers should be ready to dodge if the boss turns on them. "
                    .. "Keep stamina available for both break-free and dodge-rolling the lightning strike.",
            },
            {
                name = "Yalorasse the Speaker",
                strategy = "Yalorasse spawns |cFFD700adds that target the healer|r specifically, making healer protection the group's top priority. "
                    .. "The boss uses a |cFFD700Whirlwind AoE|r that deals damage in a radius around her.\n\n"
                    .. "|cFFD700Heavy Attacks|r must be blocked by the tank, and |cFFD700Lightning AoE|r is placed on the tank's position. "
                    .. "|c00FF00Kill adds immediately to protect the healer|r — if the healer goes down, the fight is over. "
                    .. "DPS should prioritize adds over the boss whenever they spawn. "
                    .. "The tank should move out of lightning AoE while maintaining boss positioning away from the group.",
            },
            {
                name = "Stormfist",
                strategy = "Stormfist creates an |cFF4444Expanding Red Circle|r that deals heavy damage and knockdown to anyone caught inside. "
                    .. "He uses a |cFFD700Ground Punch|r that sends shockwaves outward and spawns |cFFD700adds|r throughout the fight.\n\n"
                    .. "At low health, the boss triggers |cFF4444Room-Wide Lightning|r — unavoidable pulsing damage that hits the entire group repeatedly. "
                    .. "|c00FF00Burn the boss quickly|r to minimize time spent in the lightning phase, which becomes increasingly lethal the longer it lasts. "
                    .. "Save ultimates for the final phase and push through the lightning as fast as possible. "
                    .. "Healers should be ready for massive group healing during the room-wide lightning.",
            },
            {
                name = "Commodore Ohmamil",
                strategy = "The Commodore is accompanied by |cFF4444numerous adds|r that actually deal more damage than the boss himself. "
                    .. "He uses a |cFFD700Heavy Attack|r and occasionally |cFFD700levitates|r, though the levitation is purely cosmetic.\n\n"
                    .. "|c00FF00Kill all adds first|r before focusing on the boss — the adds are the real threat in this encounter. "
                    .. "AoE abilities are essential for clearing the waves of adds efficiently. "
                    .. "Once adds are dead, the boss himself is relatively straightforward to tank and burn. "
                    .. "Don't be distracted by the levitation animation — it doesn't change his abilities or threat level.",
            },
            {
                name = "Stormreeve Neidir",
                strategy = "Neidir has a |cFF4444Shock AoE around the boss|r that is lethal on veteran difficulty — |c00FF00maintain distance|r at all times. "
                    .. "She raises her hand before casting |cFFD700Random Lightning|r, giving you a brief telegraph to dodge.\n\n"
                    .. "Her |cFFD700Charge|r is blockable or dodgeable, so watch for the wind-up animation. "
                    .. "|cFFD700Mini Tornadoes|r roam the arena, staggering players and interrupting dodge rolls — |c00FF00weave between them, do NOT dodge through them|r. "
                    .. "Dodging through tornadoes will get your dodge roll cancelled and leave you in a worse position. "
                    .. "Maintain distance from the boss, watch for the hand-raise lightning telegraph, and carefully navigate between tornadoes. "
                    .. "This fight demands precise movement and patience over raw DPS.",
            },
        },
    },
    ["Volenfell"] = {
        order = 20,
        bosses = {
            {
                name = "Desert Lion",
                strategy = "The Desert Lion has |c00FF00no special mechanics|r to worry about. "
                    .. "The tank should hold aggro while DPS burns the boss down.\n\n"
                    .. "This is a straightforward tank-and-spank encounter with no AoE to avoid or adds to manage. "
                    .. "Use this fight to warm up the group and ensure everyone's builds are working properly. "
                    .. "A quick and easy fight that serves as an introduction to the dungeon.",
            },
            {
                name = "Quintus Verres",
                strategy = "|cFFD700Phase 1|r is melee-focused: the boss uses a |cFFD700Power Attack|r that must be blocked and a close-range AoE. "
                    .. "|c00FF00Avoid the close-range AoE in Phase 1|r by stepping out when you see the telegraph.\n\n"
                    .. "At approximately |cFF444450% health|r, |cFFD700Phase 2|r begins and the boss switches to ranged attacks with fire circles on the ground. "
                    .. "|c00FF00Dodge the fire circles in Phase 2|r by staying mobile. "
                    .. "In |cFFD700Phase 3|r, a |cFF4444Monstrous Gargoyle|r add spawns with a forward AoE, large radius AoE, and its own Power Attack. "
                    .. "Manage the gargoyle in Phase 3 by having the tank pick it up while DPS finishes the boss. "
                    .. "Each phase requires a different approach, so adapt your positioning accordingly.",
            },
            {
                name = "Boilbite",
                strategy = "Boilbite's signature ability is a |cFF4444Huge AoE Explosion|r that deals massive damage to everyone nearby. "
                    .. "Three |cFFD700adds|r accompany the boss and should be killed first to reduce damage pressure.\n\n"
                    .. "|c00FF00Kill adds first|r, then focus on the boss. "
                    .. "Ranged DPS should stay at maximum distance to reduce damage from the explosion. "
                    .. "Melee players need to watch for the explosion telegraph and dodge out when it begins. "
                    .. "Healers should be ready with burst heals after each explosion hits the group.",
            },
            {
                name = "Tremorscale",
                strategy = "Tremorscale's |cFFD700Tail Attack|r is telegraphed by a distinctive |cFFD700roar followed by a turn|r — watch for this animation to dodge in time. "
                    .. "The boss |cFFD700burrows underground|r and deals party-wide damage while submerged.\n\n"
                    .. "|c00FF00Watch the roar animation|r carefully — when the boss roars and turns, the tail swipe is coming and you need to move. "
                    .. "|c00FF00Spread out when the boss is burrowing|r to minimize overlapping damage on the group. "
                    .. "Healers should prepare group heals during the burrow phase. "
                    .. "Stay mobile and keep your camera focused on the boss to catch the tail attack telegraph.",
            },
            {
                name = "Guardian Constructs",
                strategy = "Three Guardian Constructs fight simultaneously: |cFFD700Spark|r rains magic projectiles and stays stationary, |cFFD700Strength|r uses close-range AoE and can be kited, and |cFFD700Soul|r splits damage among all three constructs. "
                    .. "The |c00FF00kill order is Soul first, then Spark, then Strength|r.\n\n"
                    .. "Soul must die first because its damage-splitting ability makes all three constructs harder to kill while it lives. "
                    .. "Spark is second because its stationary projectile rain deals consistent group damage. "
                    .. "The tank should hold |cFFD700Strength|r away from the group while DPS focuses the kill order. "
                    .. "Kite Strength if the tank is struggling, as its close-range AoE is its only threat.",
            },
        },
    },
    ["Blessed Crucible"] = {
        order = 21,
        bosses = {
            {
                name = "Grunt the Clever",
                strategy = "Grunt casts an |cFF4444AoE Fear|r that hits the entire group, causing everyone to lose control for several seconds. "
                    .. "|c00FF00Break free from fear immediately|r — this is the top priority in the fight.\n\n"
                    .. "He follows up with a |cFF4444Massive Frontal AoE|r that covers a huge area in front of him. "
                    .. "Dodge the frontal AoE by rolling to the side as soon as you see the telegraph. "
                    .. "Being feared into the frontal AoE is the most common cause of death, so keep stamina reserved for break-free. "
                    .. "The tank should face the boss away from the group to give DPS and healers more time to react to the frontal.",
            },
            {
                name = "The Pack",
                strategy = "Four bosses fight together: |cFFD700Snagg|r (whirlwind melee), |cFFD700Nusana|r (fire beam), |cFFD700Dynus Aralas|r (healer with fire and ice), and |cFFD700Kayd at-Sal|r (rogue with quick melee). "
                    .. "Each boss |cFF4444transforms into a werewolf at 30% health|r, hitting significantly harder in wolf form.\n\n"
                    .. "The |c00FF00kill order is Dynus (healer) first, then Kayd (rogue), then the others|r. "
                    .. "Dynus must die first because he heals the other bosses, making the fight take forever otherwise. "
                    .. "Kayd is second because his rogue attacks are fast and deadly, especially in werewolf form. "
                    .. "Health potions appear mid-fight on the ground — pick them up when needed. "
                    .. "Be prepared for a damage spike when each boss hits 30% and transforms.",
            },
            {
                name = "Teranya the Faceless",
                strategy = "Teranya uses a |cFFD700360 AoE|r that deals mild damage around her position — healers can heal through this easily. "
                    .. "Her |cFFD700Heavy Attack|r causes knockdown if not blocked, so the tank must stay alert.\n\n"
                    .. "|cFFD700Enraged Durzog adds|r spawn during the fight and deal significant melee damage. "
                    .. "|c00FF00Kill the Durzogs first|r before returning to the boss, as they hit harder than Teranya herself. "
                    .. "The tank should try to group Durzogs with the boss for cleave damage. "
                    .. "Block the heavy attacks and manage adds — this fight is straightforward with proper add control.",
            },
            {
                name = "The Stinger and The Troll King",
                strategy = "|cFFD700The Stinger|r drops |cFF4444poison clouds|r under the targeted player — |c00FF00keep moving|r to avoid standing in the clouds. "
                    .. "|cFFD700The Troll King|r deals heavy damage with random leaps to players and has a |cFFD700frontal Tremor|r attack that sends ground waves forward.\n\n"
                    .. "|c00FF00Block the Tremor attack|r to avoid being knocked down by the ground waves. "
                    .. "Focus one boss at a time to simplify the fight and reduce incoming damage. "
                    .. "The player targeted by Stinger must keep moving to drop poison clouds away from the group. "
                    .. "The Troll King's random leaps make healing unpredictable, so healers should keep everyone topped off.",
            },
            {
                name = "Captain Thoran",
                strategy = "Thoran places |cFFD700Fire Runes|r on the ground and creates |cFF4444Purple Clouds|r that must be avoided at all costs. "
                    .. "At low health, a |cFF4444Lava Atronach|r spawns and gives the boss a damage shield.\n\n"
                    .. "|c00FF00Kill the Lava Atronach immediately|r to destroy the boss's shield — the boss cannot be damaged while shielded. "
                    .. "Avoid purple clouds and fire runes while managing the atronach add. "
                    .. "Kill any other adds that spawn to keep the arena manageable. "
                    .. "The fight becomes a race when the atronach appears, so save some DPS cooldowns for the low-health phase.",
            },
            {
                name = "Lava Queen",
                strategy = "The Lava Queen summons |cFFD700Lava Atronachs|r that shield the boss — |c00FF00kill them immediately|r to remove the shield. "
                    .. "|cFF4444Lava Eruptions|r create red circles on the ground, and |cFFD700Sword Slam|r causes an eruption directly under the Queen.\n\n"
                    .. "She targets distant players with fire attacks, so |c00FF00stay at melee range|r to avoid triggering ranged fire. "
                    .. "The boss has a |cFFD700Heavy Melee|r attack that the tank must block. "
                    .. "Kill Atronachs as the highest priority whenever they spawn, then return to the boss. "
                    .. "This is a slow and steady fight — don't rush it. Manage atronachs, stay in melee range, and avoid red circles. "
                    .. "Patience and add control will win this encounter.",
            },
        },
    },
    ["Selene's Web"] = {
        order = 22,
        bosses = {
            {
                name = "Treethane Keminn",
                strategy = "Treethane Keminn casts a |cFFD700Raven AoE|r that pulls players in and pelts them with raven attacks, dealing sustained damage. "
                    .. "She also uses a |cFFD700Whirlwind|r attack, so |c00FF00stay at range|r to avoid the worst of it.\n\n"
                    .. "|c00FF00Kill adds first|r whenever they spawn to reduce overall group damage. "
                    .. "|c00FF00Break free from the pull|r immediately to escape the raven AoE. "
                    .. "Ranged DPS have an advantage in this fight since the whirlwind punishes melee range. "
                    .. "Keep stamina available for break-free, and maintain distance whenever possible.",
            },
            {
                name = "Longclaw",
                strategy = "Four |cFFD700Named Panther Spirits|r must be killed to activate the boss — this is the trigger to start the real fight. "
                    .. "When each panther dies, a |cFFD700Senche Tiger|r spawns — |cFF4444CC the tigers but do NOT kill them|r.\n\n"
                    .. "|cFFD700Arrow Volleys|r create red circles on the ground that must be dodged. "
                    .. "|cFF4444Poison Clouds|r surround the boss and deal damage to anyone standing in them. "
                    .. "|c00FF00Kill the panthers, CC the tigers, and avoid arrows and clouds|r — that's the core strategy. "
                    .. "If you kill the tigers, worse things spawn, so crowd control them with roots, snares, and stuns instead. "
                    .. "Stay mobile to handle arrow volleys while keeping tigers locked down.",
            },
            {
                name = "Queen Aklayah",
                strategy = "A |cFF4444Red Circle follows the tank|r throughout the fight, so the tank must |c00FF00separate from the group|r to avoid damaging allies. "
                    .. "The boss uses a |cFFD700Random Cone|r attack that hits in unpredictable directions.\n\n"
                    .. "This is a quick burn mini-boss that shouldn't take long with decent DPS. "
                    .. "The tank should pull the boss and the red circle away from the group. "
                    .. "DPS should burn her down quickly while staying behind the boss to avoid the cone. "
                    .. "Healers focus on the tank who will be taking consistent damage from the following red circle.",
            },
            {
                name = "Foulhide",
                strategy = "|cFF4444Frontal Stomp|r deals knockdown and heavy damage — |c00FF00stay behind or to the side of the boss|r at all times. "
                    .. "The boss summons |cFFD700Selene's Roses|r which are harmless and can be ignored.\n\n"
                    .. "|cFF4444Directional Charge|r shows red lines indicating the path — dodge roll out of the way. "
                    .. "|cFFD700Shout AoE|r stuns players and must be broken free from immediately. "
                    .. "The key to this fight is positioning — never stand in front of the boss. "
                    .. "Dodge the red charge lines and break free from shouts, and the fight becomes very manageable.",
            },
            {
                name = "Mennir Many-Legs",
                strategy = "Mennir spawns |cFFD700numerous Spider Adds|r with low HP that are perfect for AoE abilities. "
                    .. "The boss uses a |cFF4444large Shock AoE|r that covers a significant area around it.\n\n"
                    .. "|c00FF00AoE the spiders down|r as quickly as possible to prevent them from swarming the group. "
                    .. "Avoid the shock AoE by watching for the telegraph and moving out of range. "
                    .. "This fight is a DPS check on add management — if spiders pile up, the group gets overwhelmed. "
                    .. "Use ground-based AoE abilities to passively clear spiders while focusing the boss.",
            },
            {
                name = "Selene",
                strategy = "|cFFD700Phase 1|r is Selene in spider form — she uses |cFFD700Raven AoE|r that pulls and pelts players, similar to the first boss. "
                    .. "At |cFF444450% health|r, |cFFD700Phase 2|r begins as Selene shifts to humanoid form.\n\n"
                    .. "In Phase 2, humanoid mobs spawn including |cFF4444HEALERS that must be killed first|r or they will sustain the adds indefinitely. "
                    .. "A |cFFD700Foulhide Spirit|r appears dealing heavy melee damage, and a |cFFD700Senche Tiger|r uses unavoidable ranged attacks on distant players. "
                    .. "|c00FF00Stay close to the boss|r to avoid being punished by the Senche Tiger's ranged attacks. "
                    .. "Kill healers immediately in Phase 2, then manage the Foulhide Spirit while burning Selene. "
                    .. "The fight demands tight positioning and fast add prioritization in the second phase.",
            },
        },
    },
    ["Vaults of Madness"] = {
        order = 23,
        bosses = {
            {
                name = "Cursed One",
                strategy = "The Cursed One summons |cFFD700Skeleton Adds|r and uses |cFFD700Frozen Torrent|r for AoE ice damage. "
                    .. "The critical mechanic is |cFF4444Drain Life|r — it reflects all party damage back to the targeted player.\n\n"
                    .. "|cFF4444STOP ALL DPS immediately during Drain Life|r or you will kill the targeted player with your own damage. "
                    .. "The healer must focus on keeping the drain target alive through the reflected damage. "
                    .. "Once Drain Life ends, resume DPS on the boss. "
                    .. "This fight requires discipline and communication — calling out when Drain Life activates saves lives. "
                    .. "Kill skeleton adds between Drain Life phases to keep the arena clean.",
            },
            {
                name = "Ulguna Soul-Reaver",
                strategy = "Ulguna randomly |cFFD700levitates a player|r for 10 seconds — this is unbreakable and cannot be avoided. "
                    .. "She uses a |cFF4444Frontal Fire Cone|r, so the tank must |c00FF00face the boss away|r from the group.\n\n"
                    .. "|cFFD700Four Healing Orbs|r spawn and heal the boss — |c00FF00destroy them immediately|r as top priority. "
                    .. "If orbs are left alive, the boss will outheal your DPS and the fight becomes impossible. "
                    .. "Top off the levitated player when they drop back down, as they take fall damage. "
                    .. "Kill orbs > face away > heal levitated player — repeat this cycle until the boss falls.",
            },
            {
                name = "Death's Head",
                strategy = "Death's Head uses a |cFFD700Charge + Knockdown|r combo — |c00FF00position near walls|r to reduce the knockback distance. "
                    .. "A |cFFD700Frontal Cone Slam|r deals heavy damage in front of the boss.\n\n"
                    .. "|cFF4444Exploding Skeletons|r spawn and detonate at low HP — kill them before they get close enough to explode on the group. "
                    .. "|cFFD700Poison Runes|r leave DoT patches on the ground that must be avoided. "
                    .. "Wall-positioning is the key strategy — it prevents knockback from sending you across the arena. "
                    .. "Kill skeletons at range before they can reach the group and explode, and avoid poison runes while staying near walls.",
            },
            {
                name = "Grothdarr",
                strategy = "Grothdarr creates a |cFF4444Lava Trail|r in a snake pattern that covers the arena floor — |cFF4444avoid it at all costs|r as it deals devastating damage. "
                    .. "The boss uses an |cFFD700Overhead Knockdown|r attack that must be blocked.\n\n"
                    .. "|c00FF00Stay mobile and watch the lava pattern|r as it snakes across the ground. "
                    .. "The trail follows a predictable pattern, so learn it and position yourself in the gaps. "
                    .. "Block the overhead knockdown to avoid being stunned in the lava. "
                    .. "This is a movement-intensive fight where awareness of the floor is more important than DPS uptime.",
            },
            {
                name = "Achaeraizur",
                strategy = "|cFFD700Dremora Adds|r spawn throughout the fight and |c00FF00must be killed first|r to reduce damage pressure. "
                    .. "The boss uses a |cFFD700Conal Fire Breath|r, so the tank must face him away from the group.\n\n"
                    .. "|cFFD700Blue Fire Patches|r appear on the ground and should be avoided. "
                    .. "This is a standard add-management fight with no complex mechanics. "
                    .. "Kill Dremora, face boss away, avoid fire patches — repeat until dead. "
                    .. "A straightforward encounter that tests basic dungeon fundamentals.",
            },
            {
                name = "Ancient One",
                strategy = "The Ancient One attacks with a |cFFD700Watcher Beam|r that deals consistent damage to its target. "
                    .. "At low health, the boss unleashes |cFF4444High-Damage AoE|r that hits the entire group.\n\n"
                    .. "|c00FF00Keep the group at full HP|r at all times in preparation for the low-health AoE burst. "
                    .. "Burn the boss quickly once it reaches low health to minimize time spent in the AoE phase. "
                    .. "Healers should have burst healing ready for the transition to high-damage AoE. "
                    .. "Save ultimates for the final burn to push through the dangerous low-health phase quickly.",
            },
            {
                name = "Iskra the Omen",
                strategy = "Iskra uses |cFFD700Leap|r to jump at a random target, dealing damage on landing. "
                    .. "Her most dangerous attack is |cFF4444Wall of Flame|r — if she stops moving and stares at you, |c00FF00sidestep immediately|r.\n\n"
                    .. "The stare telegraph is brief, so you must be watching the boss at all times to catch it. "
                    .. "If you fail to sidestep the Wall of Flame, it deals lethal damage in a straight line. "
                    .. "Stay spread out to reduce the chance of the leap hitting multiple players. "
                    .. "Watch for the stare telegraph — it is the only mechanic that matters in this fight.",
            },
            {
                name = "Mad Architect",
                strategy = "The Mad Architect summons |cFFD700Undead|r and fires |cFFD700Grinning Bolt|r — a high single-target ranged attack. "
                    .. "|cFFD700Ground AoE|r snares and damages anyone standing in it.\n\n"
                    .. "The critical mechanic is the |cFF4444Sconce Telegraph System|r — sconces around the arena light up to indicate which lethal attack is coming. "
                    .. "For |cFF4444Lethal Spirit Attack|r (covers the entire platform), |c00FF00run ONTO the platform|r to survive. "
                    .. "For |cFF4444Lethal Telekinesis|r (near windows), |c00FF00run AWAY from windows|r immediately. "
                    .. "|c00FF00Position at the edge of melee range|r for quick repositioning when sconces light up. "
                    .. "Learning the sconce patterns is essential — watch which ones illuminate and react instantly. "
                    .. "This is the final boss and demands full attention to the environmental telegraphs.",
            },
        },
    },
    ["Blackheart Haven"] = {
        order = 24,
        bosses = {
            {
                name = "Iron-Heel",
                strategy = "Iron-Heel uses |cFFD700Heavy Attacks|r that cause knockdown if not blocked — the tank must block every one. "
                    .. "He creates |cFFD700AoE Whirlwinds|r that sweep across the arena.\n\n"
                    .. "|c00FF00Kill adds first|r whenever they spawn to reduce overall damage. "
                    .. "Block the heavy attacks consistently to avoid being knocked down and vulnerable. "
                    .. "The whirlwinds are avoidable with good positioning and awareness. "
                    .. "A straightforward opening fight that rewards basic blocking discipline.",
            },
            {
                name = "Atarus",
                strategy = "|cFF4444Poison Cone|r deals heavy damage in front of the boss — |c00FF00stay behind or to the side|r at all times. "
                    .. "A |cFFD700360 Stomp|r causes knockdown and must be blocked or dodge rolled.\n\n"
                    .. "|cFF4444Charge|r shows a red path on the ground — dodge out of the trajectory. "
                    .. "At |cFF444430% health|r, the boss |cFFD700self-heals back to 50%|r — this is unavoidable, so just push through it. "
                    .. "Avoid the cone by staying behind, dodge the charge, and block the stomp. "
                    .. "Don't panic when the boss heals — it only happens once and the group just needs to sustain DPS through it.",
            },
            {
                name = "First Mate Wavecutter",
                strategy = "Wavecutter is accompanied by |cFFD700Harpy Adds|r that deal ranged damage from distance. "
                    .. "She casts |cFF4444Shadow Volley|r — severe magic damage that can take up to 50% of a player's health in one hit.\n\n"
                    .. "The boss uses |cFFD700Heavy Knockdown|r attacks and creates |cFFD700Whirlwinds|r in the arena. "
                    .. "|c00FF00Either burn the boss quickly or kill the adds|r — both strategies work depending on group DPS. "
                    .. "Block heavy attacks to avoid knockdown. "
                    .. "The healer must watch for |cFF4444Shadow Volley|r and be ready with immediate burst healing on the target, as it can chunk half their health instantly.",
            },
            {
                name = "Roost Mother",
                strategy = "When bats surround the tank, a |cFF4444Fiery Tornado|r spawns at the tank's location — |c00FF00relocate immediately when you see the bat swarm|r. "
                    .. "|cFFD700Fireball Rain|r creates expanding circles on the ground that must be avoided.\n\n"
                    .. "The boss has a |cFFD700Frontal Cone Breath|r, so |c00FF00stay behind the boss|r. "
                    .. "She |cFFD700randomly teleports|r, forcing the group to reposition after each teleport. "
                    .. "Watch for the bat swarm animation on the tank — it always precedes the tornado. "
                    .. "After each teleport, quickly reestablish positioning behind the boss and resume DPS.",
            },
            {
                name = "Hollow Heart",
                strategy = "Hollow Heart fires |cFFD700Ice Projectiles|r forward that leave persistent |cFF4444ice patches|r on the ground. "
                    .. "The |c00FF00tank should face the boss at a wall|r so the ice patches stack in one area.\n\n"
                    .. "|c00FF00Stay behind the boss|r to avoid the ice projectiles entirely. "
                    .. "With proper tank positioning against a wall, this fight is extremely simple. "
                    .. "The ice patches persist, so poor positioning can cover the entire arena and leave no safe ground. "
                    .. "Face the boss into a corner and this becomes one of the easiest encounters in the dungeon.",
            },
            {
                name = "Captain Blackheart",
                strategy = "Blackheart summons |cFF44446 Skeleton Adds|r including archers that deal the majority of damage in this fight. "
                    .. "The boss uses a |cFFD700Quick 360 Slash|r that deals minimal damage and is not a major threat.\n\n"
                    .. "|c00FF00Kill the archers first|r — they deal far more damage than the boss himself. "
                    .. "The boss can |cFF4444convert the tank into a skeleton|r temporarily, causing them to lose all abilities for the duration. "
                    .. "Prepare for the tank conversion by having the group use defensive cooldowns when the tank is transformed. "
                    .. "Focus adds over boss, manage the tank conversion, and this fight becomes a clean victory. "
                    .. "The skeleton archers are the real boss of this encounter.",
            },
        },
    },

    ["Imperial City Prison"] = {
        order = 25,
        bosses = {
            {
                name = "Overfiend",
                strategy = "|cFF4444Circle of Corruption|r is a large AoE that stuns for 2 seconds and is interruptible when you see red sparks -- the tank should always be ready to bash.\n\n"
                    .. "|cFFD700Flurry|r is a devastating front-facing cone attack that deals massive damage, so all DPS and healers must stay behind the boss at all times.\n\n"
                    .. "Adds will spawn from cages and portals throughout the fight; cleave them down while maintaining pressure on the boss.\n\n"
                    .. "|c00FF00At 40% health, the Overfiend summons a Harvester ally -- burn the boss quickly or swap to kill the Harvester before it heals him.|r",
            },
            {
                name = "Ibomez the Flesh Sculptor",
                strategy = "Ibomez creates a |cFF4444Sludge Pool|r in the arena -- any adds that reach it will transform into powerful Flesh Atronachs, so DPS must prioritize killing adds before they get there.\n\n"
                    .. "The boss has a frontal conal DoT attack, so the tank should face him away from the group at all times.\n\n"
                    .. "|cFF4444Tenderize|r is the most dangerous mechanic: Ibomez rushes a random player, pins them down, and winds up a lethal heavy attack that |cFFD700must be interrupted immediately|r or the player dies.\n\n"
                    .. "|c00FF00Assign one player to watch for Tenderize at all times, and keep adds away from the Sludge Pool to prevent the fight from spiraling out of control.|r",
            },
            {
                name = "Gravelight Sentry",
                strategy = "The Sentry's most dangerous attack is its |cFF4444AoE Explosion|r -- it wraps its tentacles inward, lowers to the ground, and releases a massive blast that you |cFFD700must block|r or face near-certain death.\n\n"
                    .. "Necromancer adds will spawn periodically and should be cleaved down to prevent them from overwhelming the group.\n\n"
                    .. "|cFFD700Targeted Explosions|r place small circles under players that deal heavy damage -- keep moving to avoid standing in them.\n\n"
                    .. "|c00FF00Stay behind the boss to avoid its Frontal Conal Lasers, block the tentacle explosion, and focus DPS on the boss rather than getting distracted by adds.|r",
            },
            {
                name = "Flesh Abomination",
                strategy = "The boss channels |cFFD700Ground Impulse|r by slamming its arms into the ground, creating a sustained AoE on the group -- spread out to minimize overlap damage.\n\n"
                    .. "|cFF4444Necrotic Hoarvors|r deal proximity damage so avoid getting close to them as they wander the arena.\n\n"
                    .. "Every ~20 seconds the boss moves to the center and releases 4 |cFF4444Kamikaze Hoarvors|r that will one-shot any player on contact -- this is the deadliest phase of the fight.\n\n"
                    .. "|c00FF00Stay behind the boss during normal phases, and spread to the edges of the arena during the kamikaze phase to give yourself maximum reaction time to dodge the charging Hoarvors.|r",
            },
            {
                name = "Lord Warden Dusk",
                strategy = "|cFFD700Energy Spheres|r are blue orbs that float through the arena applying a DoT and draining your magicka -- avoid them or risk running out of resources.\n\n"
                    .. "|cFF4444Meteor Strike|r targets a random player and must be blocked to survive the impact.\n\n"
                    .. "Portals will appear that teleport you to the sky -- use the |cFFD700synergy on landing|r to deal damage and return safely.\n\n"
                    .. "At |cFF444460% and 30%|r health, Lord Warden splits into 4 images that must be destroyed in the correct order.\n\n"
                    .. "|c00FF00Enter portals immediately after a split phase, use the synergy upon landing, and quickly identify and target the correct image to end the split before the damage becomes overwhelming.|r",
            },
        },
    },
    ["White-Gold Tower"] = {
        order = 26,
        bosses = {
            {
                name = "The Adjudicator",
                strategy = "The Adjudicator has a |cFFD700frontal conal attack|r combined with a grab on the tank, so the tank must face the boss away and be ready to break free.\n\n"
                    .. "Zombies spawn throughout the fight and should be cleaved down before they overwhelm the group.\n\n"
                    .. "|cFF4444Cage Mechanic|r sends a random group member to a locked cage on a timer -- use charge abilities to escape the cells before time runs out.\n\n"
                    .. "|c00FF00Tower flames shoot fire from the sides of the arena periodically, so stay near the center. Self-healing is critical in this fight since the mechanics frequently isolate players from the healer.|r",
            },
            {
                name = "Micella Carlinus, Otho Numida, and Cordius Pontifio",
                strategy = "This is a three-boss encounter where each boss uses a different class kit: Micella uses DK skills like |cFFD700Standard of Might|r, Chains, and Flames; Otho is a caster with teleport, Standard, and |cFF4444healing that must be interrupted|r; Cordius is a Nightblade with Ambush, Steel Tornado, and Standard.\n\n"
                    .. "|cFF4444Kill Order: Otho first|r because his healing will sustain the other bosses indefinitely if left alive -- assign someone to interrupt his casts at all times.\n\n"
                    .. "After Otho, kill Cordius next to remove the burst damage threat from |cFFD700Ambush|r into |cFFD700Steel Tornado|r, then finish Micella last.\n\n"
                    .. "|c00FF00Block immediately after Cordius uses Ambush to mitigate the Steel Tornado follow-up, and keep interrupts ready for Otho throughout the fight.|r",
            },
            {
                name = "The Planar Inhibitor",
                strategy = "The Planar Inhibitor |cFF4444ignores taunts|r and instead focuses on the last player to use the pinion, which applies a stacking debuff -- alternate pinion duty between 2 or more players to manage the stacks.\n\n"
                    .. "Ground eruptions appear under players throughout the fight, so constant repositioning is necessary.\n\n"
                    .. "|cFF4444Blue flame aura|r creates a snare with extremely high damage -- when you see blue fire, |cFFD700run away immediately|r. Red fire phase is safe for melee and signals a DPS window.\n\n"
                    .. "|c00FF00Coordinate pinion rotation before the fight begins, run from blue fire, engage aggressively during red fire phases, and watch for portal spawns that can disrupt your positioning.|r",
            },
            {
                name = "Molag Kena",
                strategy = "|cFFD700Lightning orbs|r float through the arena dealing damage and stunning on contact, so keep your eyes open and sidestep them constantly.\n\n"
                    .. "|cFF4444Storm Atronachs|r are summoned targeting random players and will |cFF4444explode on contact for an instant kill|r -- run away immediately when targeted.\n\n"
                    .. "Spinning lightning walls cross the arena and must be blocked or dodge-rolled through, and the arena edges cause |cFF4444instant death|r if you fall off.\n\n"
                    .. "At |cFF444460% and 30%|r Molag Kena becomes invulnerable and summons 4 adds that must be killed while lightning waves sweep through.\n\n"
                    .. "|c00FF00Stay close to the boss during invulnerability phases to avoid the frontal cone knockback sending you off the edge, block through the lightning walls, and always prioritize running from Storm Atronachs over dealing damage.|r",
            },
        },
    },
    ["Ruins of Mazzatun"] = {
        order = 27,
        bosses = {
            {
                name = "Zatzu",
                strategy = "Zatzu is a straightforward encounter that serves as the dungeon's introductory boss fight.\n\n"
                    .. "He primarily uses |cFFD700rock-throwing attacks|r that deal moderate damage and can be easily telegraphed.\n\n"
                    .. "|c00FF00Block the incoming rocks, DPS during safe windows between throws, and this boss should go down quickly without much coordination needed.|r",
            },
            {
                name = "The Mighty Chudan",
                strategy = "Chudan has a |cFF4444distance attack|r that can one-shot players who stray too far, so maintain a moderate range at all times.\n\n"
                    .. "AoE indicators appear on the ground frequently and must be avoided to conserve healer resources.\n\n"
                    .. "The core mechanic is the |cFFD700Shield Mechanic|r: a shielded enemy appears and players must line up between the shielded target and Chudan, then wait for Chudan to charge through to break the shield.\n\n"
                    .. "|c00FF00Line up correctly with the shielded enemy or the group will wipe -- the tank is essential for positioning Chudan's charge angle properly.|r",
            },
            {
                name = "Xal-Nur",
                strategy = "Xal-Nur uses an |cFFD700interruptible charge|r that targets the furthest player, often combined with a simultaneous |cFF4444Fear|r -- you must interrupt the charge even while feared.\n\n"
                    .. "The |cFFD700Spice Mechanic|r requires a player to pick up spice and carry it to the furthest geyser to progress the fight.\n\n"
                    .. "Adds including archers and trolls spawn regularly; |cFF4444trolls must be killed quickly|r because they heal the boss if left alive.\n\n"
                    .. "The boss becomes immune every 25% health, triggering add phases that must be cleared before you can resume damaging him.\n\n"
                    .. "|c00FF00This is a DPS race -- interrupt the charge despite the fear, carry spice to the far geyser, and burn trolls before they undo your progress.|r",
            },
            {
                name = "Tree-Minder Na-Kesh",
                strategy = "Na-Kesh periodically summons a |cFFD700Totem|r that glows visibly for all players except one -- the player who cannot see the glow must locate and destroy it immediately.\n\n"
                    .. "Multiple add phases occur throughout the fight and must be managed to prevent being overwhelmed.\n\n"
                    .. "|cFF4444Duplicate bosses|r appear and must be killed methodically, as each duplicate mirrors some of Na-Kesh's abilities.\n\n"
                    .. "|c00FF00Communication is absolutely critical in this fight -- call out when the totem appears, identify who needs to destroy it, damage the boss between totem phases, and kill duplicates in a coordinated manner.|r",
            },
        },
    },
    ["Cradle of Shadows"] = {
        order = 28,
        bosses = {
            {
                name = "Sithera",
                strategy = "Sithera deals |cFF4444reduced damage to players standing in lit areas|r, making positioning in the light zones critical for survival.\n\n"
                    .. "She has a high-damage AoE attack that can punish stacked groups, so spread slightly while staying in the light.\n\n"
                    .. "Adds spawn periodically and should be cleaved down without pulling the boss out of lit zones.\n\n"
                    .. "|c00FF00Keep the boss in lit zones at all times to reduce her damage output, and manage adds quickly before they push you out of safe positions.|r",
            },
            {
                name = "Votary of Velidreth",
                strategy = "This giant spider uses |cFFD700Poison Attacks|r and summons smaller spiders that apply a slowing debuff on contact.\n\n"
                    .. "The Votary has a |cFF4444large AoE|r that can one-shot players who are too close -- maintain distance when you see it telegraphed.\n\n"
                    .. "If the boss stops taking damage for any period, it |cFF4444regenerates approximately 10% health|r, so constant pressure is essential.\n\n"
                    .. "|c00FF00Maintain safe distance to avoid the one-shot AoE, keep constant damage on the boss to prevent regeneration, and kill small spiders before they slow the entire group.|r",
            },
            {
                name = "Khephidaen the Spiderkith",
                strategy = "Khephidaen teleports frequently, making it difficult for melee to maintain uptime on the boss.\n\n"
                    .. "Watch for the |cFF4444swirly animation attack|r -- this must be interrupted or blocked immediately, as it will kill the target outright.\n\n"
                    .. "The boss extinguishes flames in the arena, which triggers enemy spawns from the darkened areas.\n\n"
                    .. "|c00FF00Force the boss into lit areas for bonus damage, interrupt the swirly attack without fail, and re-ignite flames whenever they go out to prevent add waves.|r",
            },
            {
                name = "Dranos Velador",
                strategy = "The central statue in the arena fires |cFF4444directional AoEs|r that rotate -- learn the pattern and position accordingly.\n\n"
                    .. "Dranos uses |cFFD700Teleport|r combined with ground AoEs, and has a grab mechanic that targets the last player who attacked him.\n\n"
                    .. "During add phases the boss becomes immune to damage, and the adds must be killed to remove his immunity.\n\n"
                    .. "|c00FF00Avoid the statue AoE by staying aware of its rotation, shield-bash adds to free any grabbed player, and burn adds quickly during immunity phases to resume boss damage.|r",
            },
            {
                name = "Velidreth",
                strategy = "|cFFD700Colored floor balls|r litter the arena -- each color applies a different stat debuff, so avoid stepping on them whenever possible.\n\n"
                    .. "Velidreth |cFF4444consumes player ultimate|r, so coordinate ultimate usage carefully rather than holding them indefinitely.\n\n"
                    .. "|cFFD700Flesh Atronach summons|r drop synergy pickups when killed that are essential for the group's survival.\n\n"
                    .. "At |cFF444466% and 33%|r health, a maze phase begins where you must navigate light sources and spike traps to reach braziers.\n\n"
                    .. "|c00FF00Avoid colored balls, kill Atronachs for synergy pickups, navigate the maze carefully to reach braziers, and time your dodge rolls precisely during the elevation mechanic.|r",
            },
        },
    },
    ["Bloodroot Forge"] = {
        order = 29,
        bosses = {
            {
                name = "Mathgamain",
                strategy = "Mathgamain is accompanied by |cFFD700Poisonous Strangler|r adds that deal sustained DoT damage to the group.\n\n"
                    .. "The tank should use ranged taunts to control the boss and redirect his frontal AoE attacks away from the group.\n\n"
                    .. "Stranglers should be prioritized and cleaved down quickly to reduce incoming poison damage.\n\n"
                    .. "|c00FF00Tank uses ranged taunts and faces the boss away while DPS burns Stranglers first, then focuses the boss during safe windows.|r",
            },
            {
                name = "Caillaoife",
                strategy = "At |cFF444475%, 50%, and 25%|r health, Caillaoife retreats into a warded grove that grants immunity and knocks back anyone who gets too close.\n\n"
                    .. "|cFFD700Nirnblooded Bears|r spawn with ~23k heavy attacks that can devastate even tanks, alongside Poisonous Stranglers applying DoTs.\n\n"
                    .. "|cFFD700Winter's Reach|r immobilizes, roots, and damages all players caught in its area of effect.\n\n"
                    .. "|c00FF00Kill order is Stranglers first, then Bear, then remaining adds. Have the tank call out health thresholds so the group can prepare for grove transitions.|r",
            },
            {
                name = "Stoneheart",
                strategy = "Stoneheart targets the tank with persistent |cFFD700Fire AoEs|r that force regular repositioning.\n\n"
                    .. "The boss teleports around the arena, making consistent DPS application challenging for melee players.\n\n"
                    .. "|cFF4444Stone Atronach adds|r spawn and place ground knockback AoEs under every player in the group, so awareness of your footing is critical.\n\n"
                    .. "|c00FF00Save ultimates for the execute phase when the boss is low health, and keep moving to avoid the overlapping ground AoEs from Atronach adds.|r",
            },
            {
                name = "Galchobhar",
                strategy = "The arena is covered in |cFF4444molten nirncrux lava|r with breakable rock islands serving as safe platforms.\n\n"
                    .. "|cFFD700Fire Shalks|r spawn and shoot Lava Balls -- guide them to the outer lava and then jump to safety. When a |cFF4444Fire Geyser or Volcano|r appears, the tank |cFFD700must stand on it|r or the entire party wipes.\n\n"
                    .. "|cFFD700Weapon Throw|r forces players to jump to rock islands to avoid the attack, while a Stone Enemy creates additional AoEs.\n\n"
                    .. "|c00FF00The tank must plug geysers immediately as top priority, use ranged taunts on Shalks, and the group should jump to rocks during weapon throw phases.|r",
            },
            {
                name = "Gherig Bullblood",
                strategy = "This is a three-enemy encounter: the |cFF4444Attendant of Fire|r (minotaur) uses chains, stuns, and can one-shot two allies if not interrupted; Gherig uses DK abilities with chains and AoE; and the |cFFD700Attendant of Blood|r is a healer with low HP.\n\n"
                    .. "|cFF4444Kill Order: Fire > Blood > Gherig|r -- the Attendant of Fire must die first because its chains and one-shot potential make it the most dangerous threat.\n\n"
                    .. "Interrupt the Attendant of Fire whenever it begins channeling to prevent lethal attacks on your allies.\n\n"
                    .. "|c00FF00Follow the kill order strictly, keep interrupts ready for the Fire attendant, and burn the Blood attendant second to remove healing before finishing Gherig.|r",
            },
            {
                name = "Earthgore Amalgam",
                strategy = "The boss creates expanding |cFF4444Lava AoE|r zones that spawn fireballs and stuns -- counter these by activating the |cFFD700Blood Pillar|r.\n\n"
                    .. "|cFFD700Stone Pounding|r grants the boss immunity while it performs a 360-degree ground pound with falling ceiling debris -- counter this by using the |cFFD700Flame Pillar|r to interrupt.\n\n"
                    .. "The boss spawns copies of itself that duplicate its mechanics, dramatically increasing the chaos.\n\n"
                    .. "|c00FF00Kill order is Third Copy first, then Second, then Main. Use Blood Rain DPS to target lava zones and Flame DPS to interrupt pounding phases.|r",
            },
        },
    },
    ["Falkreath Hold"] = {
        order = 30,
        bosses = {
            {
                name = "Morrigh Bullblood",
                strategy = "Morrigh is accompanied by humanoid and minotaur wallbreaker adds that must be managed throughout the fight.\n\n"
                    .. "She uses an |cFFD700AoE Stun|r that can lock down the entire group if players are too close together.\n\n"
                    .. "At |cFF444450% health|r she activates a protective shield -- all players must enter the shield or take massive damage from outside it.\n\n"
                    .. "|c00FF00Cleave adds while damaging the boss, spread to avoid group-wide stuns, and enter the protective shield immediately at 50% or face near-certain death.|r",
            },
            {
                name = "Siege Mammoth",
                strategy = "The Siege Mammoth has a |cFFD700Frontal AoE|r that covers a wide area in front of it, so the tank must face it away from the group.\n\n"
                    .. "Projectiles rain down throughout the fight requiring constant awareness and movement.\n\n"
                    .. "At approximately |cFF444450% health|r, the mammoth unleashes a massive AoE that must be dodge-rolled to survive.\n\n"
                    .. "|c00FF00Face the boss away from the group at all times, dodge the massive AoE at 50%, and keep mobile to avoid incoming projectiles.|r",
            },
            {
                name = "Cernunnon",
                strategy = "Before engaging Cernunnon, you must defeat three mini-bosses: |cFFD700Erbogan|r (interrupt his flames), Tuecille, and Mokveda in that order.\n\n"
                    .. "Souls drop from defeated enemies and must be placed into circles to progress the encounter. The boss re-summons adds periodically and a |cFF4444ghost fear|r affects anyone outside the protective circle.\n\n"
                    .. "Individual AoEs appear under each player, so spreading out while staying within circle boundaries is crucial.\n\n"
                    .. "|c00FF00Kill order is Erbogan first (interrupt flames), then Tuecille, then Mokveda. Tanks collect souls and place them in circles to maintain safe zones.|r",
            },
            {
                name = "Deathlord Bjarfrud Skjoralmor",
                strategy = "Continuous waves of |cFF4444Draugr|r attack the group throughout this encounter, creating an escalating pressure scenario.\n\n"
                    .. "An intensifying DoT builds from the accumulating corpses on the ground, steadily increasing damage on the group.\n\n"
                    .. "|cFF4444Red circles|r appear under players indicating they need cleansing -- use the glowing urns around the arena to remove the debuff.\n\n"
                    .. "|c00FF00When cleansing is needed, all players should interact with a glowing urn together, then return to the center to resume the fight. Timing the cleanse is critical to avoid being overwhelmed.|r",
            },
            {
                name = "Domihaus the Bloody-Horned",
                strategy = "|cFFD700Pounding|r sends 360-degree fireballs outward -- use the pillars in the arena for cover during this devastating attack.\n\n"
                    .. "Domihaus summons |cFF44444 Atronachs|r that make him invincible until they are destroyed, and uses a pull ability that drags all players inward while spawning fire pools.\n\n"
                    .. "At |cFF444470%, 50%, 30%, 10%, and 5%|r health he shouts |cFF4444\"GROVEL\"|r which is an |cFF4444instant kill|r if you are not hidden behind a pillar.\n\n"
                    .. "|c00FF00Hide behind pillars during GROVEL shouts without fail. Use cardinal direction positioning, kill Stone Atronachs first during invulnerable phases, and below 20% ignore adds entirely and burn the boss.|r",
            },
        },
    },
    ["Scalecaller Peak"] = {
        order = 31,
        bosses = {
            {
                name = "Orzun the Foul-Smelling and Rinaerus the Rancid",
                strategy = "This is a dual-boss fight where the bosses must be kept separated. Orzun sends targeted attacks that create yellow circles -- |cFFD700freeze in these circles|r to block incoming iceballs.\n\n"
                    .. "Rinaerus summons |cFF4444deadly storms|r that require hiding behind the ice pillars created by Orzun's attacks to survive.\n\n"
                    .. "Rinaerus also summons Skeevers that must be |cFFD700interrupted|r before they overwhelm the group.\n\n"
                    .. "|c00FF00Separate the bosses, use Orzun's ice pillars for storm cover, interrupt Skeever summons, and ensure both bosses die simultaneously or the surviving one will enrage.|r",
            },
            {
                name = "Doylemish Ironheart",
                strategy = "|cFF4444Floating Red Spheres|r drift through the arena and will petrify any player they contact, effectively removing them from the fight.\n\n"
                    .. "Ice Wraith adds spawn and must be dealt with quickly to prevent additional damage pressure on the group.\n\n"
                    .. "Doylemish uses heavy attacks that can be dodged to avoid significant damage spikes.\n\n"
                    .. "|c00FF00Tank the boss in a corner to limit sphere angles, focus red spheres immediately when they appear, and dodge the heavy attacks to reduce healing demand.|r",
            },
            {
                name = "Matriarch Aldis",
                strategy = "The water in the arena |cFF4444freezes periodically and kills|r any player standing in it when it solidifies -- get out of the water immediately when warned.\n\n"
                    .. "|cFFD700Nereid adds|r spawn with deadly geysers that the tank must block to survive their high burst damage.\n\n"
                    .. "Lure the boss to the edge of the arena to maximize safe ground for the group during freeze phases.\n\n"
                    .. "|c00FF00Nereids are the kill priority whenever they spawn -- their geysers can overwhelm even strong healers if left alive too long.|r",
            },
            {
                name = "Plague Concocter Mortieu",
                strategy = "Mortieu inflicts a |cFF4444three-tiered poison debuff|r: first increased stamina cost, then healing reduction, then increased magicka cost -- cleanse at the center when possible.\n\n"
                    .. "Adds must be killed in the specific order that |cFFD700Jorvuld calls out|r (Imps, Stranglers, or Beetles) to generate the correct antidote.\n\n"
                    .. "When the boss stumbles, a Guard enemy spawns that must be dealt with. The tank should stand on geysers to prevent them from empowering the boss.\n\n"
                    .. "|c00FF00Listen carefully to Jorvuld's callouts, kill adds in the specified order, tank stands on geysers, and cleanse poison stacks at the center before they reach tier three.|r",
            },
            {
                name = "Zaan the Scalecaller",
                strategy = "Three |cFF4444poison-breath statues|r in the arena fire one-hit-kill cones -- the safe zones are close to the statues between the breath lines.\n\n"
                    .. "Zaan's |cFFD700Fire Breath|r follows a targeted player and must be blocked using the arena pillars as cover. Her fire beam targets one player, and |cFFD700other group members should stack to share the damage|r.\n\n"
                    .. "Every 20% health, |cFF4444two Ice Giants|r spawn and channel an instant-kill storm that must be interrupted by killing them quickly. After the storm, the boss gains a shield.\n\n"
                    .. "|c00FF00Tank keeps the boss centered, save ultimates for Ice Giant phases, kill the Giants before their storm completes, and use pillars to block fire breath.|r",
            },
        },
    },
    ["Fang Lair"] = {
        order = 32,
        bosses = {
            {
                name = "Lizabet Charnis",
                strategy = "Lizabet sends waves of mob enemies that must be cleaved down while managing the encounter's other mechanics.\n\n"
                    .. "A |cFFD700Small Colossus|r spawns dealing heavy damage that must be taunted by the tank immediately to protect the group.\n\n"
                    .. "Ghost ice AoEs appear on the ground and random |cFF4444flying skulls|r deal damage plus knockdown on contact.\n\n"
                    .. "|c00FF00Taunt the Colossus as soon as it spawns, dodge the flying skulls to avoid being knocked down, and cleave through mob waves efficiently.|r",
            },
            {
                name = "Cadaverous Menagerie",
                strategy = "This encounter features three enemies: a |cFFD700Bear|r (main target), a Tiger, and a Guar, along with three exploding wolves that respawn after death.\n\n"
                    .. "The Tiger is untauntable and will chase random players, making kiting essential for survival.\n\n"
                    .. "The bomb wolves explode on contact and respawn, creating constant mobile hazards across the arena.\n\n"
                    .. "|c00FF00Tank the Bear boss near the Guar while the group kites the bomb wolves away. Focus DPS on the Bear while managing wolf explosions through positioning.|r",
            },
            {
                name = "Caluurion",
                strategy = "Caluurion is stationary on elevated terrain and constantly bombards the arena with |cFFD700multiple AoEs|r.\n\n"
                    .. "He activates relics at the edges of the arena that create Poison fields, Shock fields, or summon additional adds.\n\n"
                    .. "|cFF4444Red rings|r appear on players -- if these overlap with other players, the damage stacks and can become lethal.\n\n"
                    .. "|c00FF00Destroy relics as quickly as possible when they activate, avoid overlapping red rings with other players, and maintain constant movement to dodge the barrage of AoEs.|r",
            },
            {
                name = "Ulfnor and Sabina Cedus",
                strategy = "|cFF4444Sabina|r is a ghost who chains random players, completely preventing all actions until she is damaged enough to release them.\n\n"
                    .. "Ulfnor uses devastating |cFFD700heavy attacks|r that the tank must be prepared to block or the damage will be lethal.\n\n"
                    .. "When a player gets chained, the group must immediately swap to damaging Sabina to break the chains before Ulfnor kills the helpless target.\n\n"
                    .. "|c00FF00Damage Sabina whenever she chains a player to break them free, keep Ulfnor taunted and faced away, and maintain awareness of chain targets at all times.|r",
            },
            {
                name = "Thurvokun and Orryn the Black",
                strategy = "Only |cFFD700Thurvokun|r (the dragon) takes damage -- Orryn the Black is immune, but his interruptible skull attacks must be bashed.\n\n"
                    .. "Thurvokun creates expanding |cFF4444poison AoEs|r and crystals at the arena edges that must be destroyed to stop add spawns.\n\n"
                    .. "|cFF4444Ghost wave attacks|r sweep across the arena -- take cover behind the NPC's yellow barriers to survive. At certain health thresholds, a fear scream plus instant-kill poison bombs appear -- stand in |cFFD700yellow circles|r for safety.\n\n"
                    .. "Thurvokun resurrects at 50% health, so be prepared for an extended fight.\n\n"
                    .. "|c00FF00Interrupt the necromancer's skulls, destroy edge crystals, hide behind yellow barriers during ghost waves, and stand in yellow circles during poison bomb phases.|r",
            },
        },
    },
    ["Moon Hunter Keep"] = {
        order = 33,
        bosses = {
            {
                name = "Jailer Melitus",
                strategy = "Melitus unleashes |cFFD700numerous AoE attacks|r that demand constant movement from all group members.\n\n"
                    .. "He frequently stuns the tank and follows up with a |cFF4444heavy charge attack|r that must be interrupted to prevent massive damage.\n\n"
                    .. "Werewolf adds join the fight and should be cleaved down alongside the boss when possible.\n\n"
                    .. "|c00FF00Keep moving at all times, interrupt charges after stuns, and cleave werewolf adds while maintaining DPS on the boss.|r",
            },
            {
                name = "Hedge Maze Guardian",
                strategy = "The Guardian uses |cFF4444Roots|r that must be dodge-rolled immediately -- failure to escape means death.\n\n"
                    .. "At |cFF444480%, 55%, and 35%|r health, Spriggans spawn and will heal the boss back up to the threshold if not killed quickly.\n\n"
                    .. "The boss has heavy attacks with |cFF4444one-shot potential|r on non-tanks, so blocking is essential for survival.\n\n"
                    .. "|c00FF00Dodge roots immediately, keep the boss centered in the arena, block heavy attacks, and group up when hunting Spriggans to burn them down before they fully heal the boss.|r",
            },
            {
                name = "Mylenne Moon-Caller",
                strategy = "Mylenne |cFFD700Pounces|r on random players, stunning anyone nearby on impact -- spread out to limit collateral stuns.\n\n"
                    .. "Her |cFF4444Enrage|r is reduced by the number of Shock Wardens still alive, but their corpses create damaging ground areas.\n\n"
                    .. "Stunned targets from the pounce must be interrupted within approximately 3 seconds or they will die.\n\n"
                    .. "|c00FF00Interrupt stunned allies within 3 seconds, bring the boss through Warden corpse areas to remove her enrage buff, and kill Wardens strategically to reduce incoming damage.|r",
            },
            {
                name = "Archivist Ernarde",
                strategy = "Ernarde's |cFF4444Ground Slam AoE|r will one-shot any non-tank player, so only the tank should be in melee range.\n\n"
                    .. "The |cFFD700color symbol matching|r mechanic involves 12 rotating pads that players must step on in the correct pattern.\n\n"
                    .. "Ernarde traps players in bubbles that must be burst by allies, and |cFF4444Werewolf Behemoths|r spawn requiring the tank to taunt them away.\n\n"
                    .. "|c00FF00Tank at medium range and taunt Behemoths away from the group. DPS should position halfway up the stairs. Burst bubbles immediately when allies are trapped.|r",
            },
            {
                name = "Vykosa the Ascendant",
                strategy = "Vykosa has two chained pets, |cFFD700Zel and Ary|r -- pulling one forces the other against the wall, creating a positioning dynamic.\n\n"
                    .. "The pets retreat at 0 HP but return in later phases, so expect to deal with them multiple times.\n\n"
                    .. "Werewolf adds join in later phases and must be kited to prevent them from overwhelming the group.\n\n"
                    .. "|c00FF00Tank taunts one pet while melee focuses the taunted pet and ranged DPS targets the chained one. Kite werewolves during add phases and repeat the pet mechanic through each cycle.|r",
            },
        },
    },
    ["March of Sacrifices"] = {
        order = 34,
        bosses = {
            {
                name = "The Wyrd Sisters",
                strategy = "Three bosses with color-coded auras (green, yellow, blue) that must be |cFF4444kept separated|r or they empower each other.\n\n"
                    .. "|cFFD700Ursus|r (Sword and Board) has heavy attacks that one-shot non-tanks plus a charge with knockback. |cFFD700Rangifer|r (Healer) heals allies and is the primary DPS threat. |cFFD700Strigidae|r (NB Archer) applies a Silence debuff blocking magicka abilities, snipes, and teleport strikes.\n\n"
                    .. "|cFF4444Focus Rangifer first|r to remove the healing pressure, then Strigidae, then Ursus last.\n\n"
                    .. "|c00FF00Tank taunts Ursus away from the others, the healer stays centered for range, and DPS burns Rangifer before her healing becomes unmanageable.|r",
            },
            {
                name = "Aghaedh of the Solstice",
                strategy = "Four mini Spriggans surround the boss, each with a different |cFFD700colored AoE|r pattern.\n\n"
                    .. "Color-matched Lurchers spawn and must be taunted by the tank. Defeated Lurchers drop color-matched synergy orbs that players must pick up.\n\n"
                    .. "During the boss's channel phase, players must pick up the matching orbs and stand in the matching colored circles to counter the attack.\n\n"
                    .. "|c00FF00Tank taunts all Lurchers to control their positioning, pick up synergy orbs that match your assigned color, and stand in the correct circle during the channel phase.|r",
            },
            {
                name = "Dagrund the Bulky",
                strategy = "Dagrund cycles through |cFFD700elemental attacks|r including fire, ice, and lightning, each with distinct patterns.\n\n"
                    .. "When he raises his sword, it triggers elemental AoEs: fire bounces off walls, ice appears under players, and lightning hits periodically across the arena.\n\n"
                    .. "Every ~60 seconds he leaps and unleashes |cFF44444 elemental attacks per player|r that must be blocked or dodged or they are lethal.\n\n"
                    .. "|c00FF00Tank focuses the boss while DPS targets adds until 15% health, then everyone burns the boss. Block or dodge during the leap phase without exception.|r",
            },
            {
                name = "Tarcyr",
                strategy = "At |cFF444480%, 55%, and 20%|r health, Tarcyr triggers Hunting Phases with heavy fog -- being outside stealth means being teleported up and dropped, with the third drop being |cFF4444fatal|r.\n\n"
                    .. "During hunts, a Wisp appears with a green AoE that you must synergize 3 times to locate the boss.\n\n"
                    .. "Tarcyr uses |cFFD700Light Attack|r frontal cones, |cFFD700Stampede|r with ethereal Indriks (block or dodge), |cFFD700Fire Rampage|r (shield + charge + firewall), and |cFF4444Lightning Prance|r which is a group-wipe that must be |cFFD700interrupted immediately|r.\n\n"
                    .. "|c00FF00Stay stealthed during hunts, interrupt Lightning Prance without fail, do not attempt to resurrect allies during hunting phases, and synergize the Wisp to find the boss.|r",
            },
            {
                name = "Balorgh",
                strategy = "The arena consists of three islands with environmental hazards including |cFFD700poison spores|r and lightning.\n\n"
                    .. "|cFFD700Ground Slam|r creates a large AoE that must be dodged, and the |cFFD700Breath Attack|r is a conal that follows the tank's position.\n\n"
                    .. "During the |cFF4444Low Health Phase|r, darkness and fog fill the arena. The boss throws AoE on a player and chases them -- the targeted player must pull the boss through a |cFFD700blue light pillar|r, then all players converge at the pillar.\n\n"
                    .. "|c00FF00Dodge Ground Slams, face Breath away from the group, kite the boss through the blue pillar during the darkness phase, converge as a group, and kill wolves that spawn during the chaos.|r",
            },
        },
    },
    ["Frostvault"] = {
        order = 35,
        bosses = {
            {
                name = "Icestalker",
                strategy = "Icestalker has a |cFFD700conal frontal attack|r that the tank must aim away from the group at all times.\n\n"
                    .. "|cFF4444Uppercut|r stuns the target and is followed by a rapid attack -- |cFFD700interrupt immediately|r or the follow-up will kill. |cFF4444Stomp|r deals continuous damage and also must be interrupted.\n\n"
                    .. "If players move too far away, the boss uses |cFFD700Pounce|r to close the gap with heavy damage. Ice Wraith and Spider adds spawn throughout.\n\n"
                    .. "|c00FF00Face the boss away, interrupt Uppercut and Stomp without hesitation, stay at moderate range to prevent Pounce, and kill Ice Wraiths as priority adds.|r",
            },
            {
                name = "Warlord Tzogvin",
                strategy = "|cFFD700Tether|r links two players together -- they must run apart to break it before the damage ramps up. The Warlord's |cFFD700Charge|r and |cFFD700Jump-and-Land|r attacks must be blocked or dodged.\n\n"
                    .. "|cFF4444Flames|r place red circles under each player that deal heavy damage if overlapping, so spread out immediately when they appear.\n\n"
                    .. "A |cFFD700Tornado|r moves counterclockwise at the arena edge, and a |cFF4444Blizzard|r appears at center after his jump attack.\n\n"
                    .. "|c00FF00Break tethers by running apart, never overlap flame circles, avoid tornados by moving counterclockwise, and stay out of center during blizzard phases.|r",
            },
            {
                name = "Vault Protector",
                strategy = "|cFF4444Laser beams|r are the primary mechanic of this fight, increasing in number as the encounter progresses.\n\n"
                    .. "The boss projects a |cFFD700Barrier|r that blocks lasers -- position yourself next to the barrier to stay safe, or jump over low-angle beams.\n\n"
                    .. "Spider and Sphere adds spawn and should be killed quickly before they complicate laser avoidance.\n\n"
                    .. "|c00FF00Position next to the boss barrier to block lasers, jump over any beams you cannot avoid, and kill adds quickly to keep the arena manageable.|r",
            },
            {
                name = "Rizzuk Bonechill",
                strategy = "Rizzuk is accompanied by |cFFD700Avalanche|r -- the tank must stay near it at all times or its AoE damages the whole group.\n\n"
                    .. "Stepping away from Avalanche applies a |cFF4444Healing Debuff DoT|r, and a Storm mechanic will |cFF4444instantly kill|r players near the entrance if they don't move. Blue circles appear at arena edges and |cFFD700Chilling the Air|r creates unavoidable circles.\n\n"
                    .. "Rizzuk has an |cFFD700interruptible channel|r and fires an Ice Ball that follows a random player.\n\n"
                    .. "|c00FF00Tank stays near Avalanche, the group moves together to avoid isolation, interrupt channels immediately, and dodge the Ice Ball when targeted.|r",
            },
            {
                name = "The Stonekeeper",
                strategy = "This multi-phase fight begins with the |cFFD700Skeevatron Maze|r. Phase 1 features a |cFF4444Heavy Attack|r (raised hand, dodge at all costs), |cFFD700Blades Gauntlet|r (right arm, highest damage), Flames Gauntlet (left arm), Electrified Balls that explode and stun, and a spinning flame you must stay ahead of.\n\n"
                    .. "|cFF4444Centurion adds|r spawn and must be killed immediately before they overwhelm the group.\n\n"
                    .. "Phase 2 introduces |cFFD700Rotary Blades|r that move from edges inward applying bleeding stacks. Phase 3 adds a |cFF4444Conal Attack|r that pushes players over the edge for an instant death.\n\n"
                    .. "|c00FF00Kill Centurions immediately, stay ahead of the spinning flame, avoid the arena edges in Phase 3 to prevent being pushed off, and dodge the raised-hand heavy attack without fail.|r",
            },
        },
    },
    ["Depths of Malatar"] = {
        order = 36,
        bosses = {
            {
                name = "The Scavenging Maw",
                strategy = "The Maw has a |cFFD700conal AoE|r followed by a ground AoE that tracks players, requiring constant repositioning.\n\n"
                    .. "The boss |cFF4444disappears|r periodically -- the group must stick together to locate it quickly when it reappears.\n\n"
                    .. "Its |cFF4444Channeling Attack|r deals a massive DoT and must be |cFFD700interrupted immediately|r or the targeted player will die.\n\n"
                    .. "|c00FF00Face the boss away from the group, stay together when the boss vanishes to find it quickly, and interrupt the channel attack without hesitation.|r",
            },
            {
                name = "The Weeping Woman",
                strategy = "The Weeping Woman places |cFF4444multiple AoE circles|r across the arena that persist and shrink the available safe space.\n\n"
                    .. "A |cFFD700Two-Handed Add|r spawns dealing significant damage that can quickly overwhelm the healer if not addressed.\n\n"
                    .. "Stay outside the AoE circles at all times and prioritize positioning over DPS uptime.\n\n"
                    .. "|c00FF00Kill adds before focusing the boss, stay outside all AoE circles, and manage your arena space carefully as more circles accumulate.|r",
            },
            {
                name = "Dark Orb",
                strategy = "The Dark Orb |cFFD700constantly heals Auroran adds|r, making them extremely difficult to kill without addressing the source.\n\n"
                    .. "Periodically, the orb summons 4 empowering orbs with the callout |cFFD700\"An Orb is empowering Aurorans\"|r -- these must be destroyed to make the boss vulnerable to damage.\n\n"
                    .. "The tank should position Auroran adds for cleave damage to maximize efficiency during vulnerable windows.\n\n"
                    .. "|c00FF00Kill empowering orbs immediately when they spawn to create damage windows on the boss, and tank positions Aurorans together for AoE cleave.|r",
            },
            {
                name = "King Narilmor",
                strategy = "Narilmor |cFF4444splits into 4 clones|r that each possess some of his combat abilities, spreading threats across the arena.\n\n"
                    .. "The NPC Tharayya battles a ghost simultaneously -- if she loses her fight, all clones gain protective shields making them much harder to kill.\n\n"
                    .. "You can either AoE all clones simultaneously or focus them down one at a time depending on group composition.\n\n"
                    .. "|c00FF00The healer must keep Tharayya alive at all costs to prevent clones from gaining shields, while DPS burns through the clones as efficiently as possible.|r",
            },
            {
                name = "Symphony of Blades",
                strategy = "The Symphony spins and uses |cFFD700Heavy Attacks|r while summoning an |cFF4444Auroran Wall|r that causes instant death on contact.\n\n"
                    .. "Four swords are embedded in the ground applying a healing debuff, and 4 Aurorans spawn (Blazing, Radiant, Phosphorescent, and |cFF4444Scintillating|r with empowered abilities).\n\n"
                    .. "Kill Aurorans within the wall boundaries to create passage gaps. During the |cFF4444Execute Phase|r, multiple walls appear and the boss heals to 25% or 50%, requiring repeated burn phases.\n\n"
                    .. "|c00FF00Prioritize Scintillating Auroran first, kill Aurorans within walls to create gaps, and kite through wall openings during the execute phase.|r",
            },
        },
    },
    ["Moongrave Fane"] = {
        order = 37,
        bosses = {
            {
                name = "Risen Ruins",
                strategy = "This Stone Atronach uses |cFFD700Rock Toss|r and |cFFD700Ground Pound|r shockwaves that radiate outward from its position.\n\n"
                    .. "During |cFF4444Boulder Shield|r, the boss becomes invulnerable and throws knockdown boulders that must be blocked.\n\n"
                    .. "After the shield phase, a |cFF4444Dash|r attack deals heavy damage to anyone in its path.\n\n"
                    .. "|c00FF00Pre-activate Hemo Helot synergies before the fight, block boulders during the shield phase, and dodge the charge attack that follows immediately after.|r",
            },
            {
                name = "Dro'zakar",
                strategy = "Dro'zakar's |cFFD700Heavy Attack|r is a conal breath that must be blocked or dodged, so the tank must face him away from the group.\n\n"
                    .. "|cFF4444Blood Shield|r creates AoE blasts around all players -- form a cross formation to avoid overlapping damage. A |cFF4444Blood Pool|r follows the aggro target and heals the boss if he stands in it.\n\n"
                    .. "The boss will |cFFD700Siphon Hemo Helots|r to empower himself, making orb destruction a top priority.\n\n"
                    .. "|c00FF00Face the boss away, use cross formation during Blood Shield, destroy Hemo Helot orbs immediately when they spawn, and keep the boss out of Blood Pools.|r",
            },
            {
                name = "Kujo Kethba",
                strategy = "Kujo Kethba uses claw swipes and a |cFFD700Heavy Attack overhead smash|r that the tank must block.\n\n"
                    .. "|cFFD700Cleaving Fire|r involves wing beats creating two fire cones that cover wide areas on either side.\n\n"
                    .. "|cFF4444Lava Smash|r has the boss leap and pound the ground, spawning geysers with sliding stone blocks. |cFF4444Stop DPS during Lava Smash|r as the boss reflects damage.\n\n"
                    .. "|c00FF00Face the boss away from the group, manage sliding stones during Lava Smash, and cease all damage during the reflection phase to avoid killing yourself.|r",
            },
            {
                name = "Nisaazda",
                strategy = "Nisaazda fires blood missiles and has an |cFFD700interruptible Blood Barrage channel|r that must be bashed immediately.\n\n"
                    .. "She teleports frequently and summons |cFFD700Sangiin's Thirst|r, a channel that requires the assigned Hemo Helot player to interrupt.\n\n"
                    .. "|cFF4444Blood Vortex|r creates an empowering pool on the ground that must be removed immediately, and Hemonculus adds spawn to pressure the group.\n\n"
                    .. "|c00FF00Remove Blood Vortex as top priority, assign a dedicated Hemo Helot player for Sangiin's Thirst interrupts, and bash Blood Barrage whenever it is cast.|r",
            },
            {
                name = "Grundwulf Empowered",
                strategy = "Grundwulf uses sword swings with a wide |cFFD700Heavy Attack|r, and his |cFF4444Fus Ro Dah shout|r leaves blood circles that spawn Hemonculi adds.\n\n"
                    .. "|cFFD700Dragon Bombardment|r rains fireballs across the arena, and |cFF4444Dragon Fire|r has the dragon breathe when the boss positions behind stone cover -- heavy attack the stone to destroy it.\n\n"
                    .. "|cFFD700Reposition|r throws a block that causes |cFF4444instant death|r on contact. |cFF4444Blood Spikes|r apply a heal absorption debuff -- run to the spikes to cleanse it.\n\n"
                    .. "|c00FF00Position centrally, heavy attack stones during Dragon Fire, run to spikes to cleanse heal absorption, and on Hard Mode kite the Giant Bat while the Hemo Helot player kills it.|r",
            },
        },
    },
    ["Lair of Maarselok"] = {
        order = 38,
        bosses = {
            {
                name = "Selene",
                strategy = "Selene teleports frequently and uses |cFFD700Poison Barrage|r, an interruptible channel that must be bashed to prevent heavy group damage.\n\n"
                    .. "|cFFD700Poison Cone|r targets a random player with a wide toxic spray.\n\n"
                    .. "|cFFD700Selene's Claws|r summons a bear that performs ground smashes, while |cFFD700Selene's Fangs|r summons a spider that creates spiderling adds.\n\n"
                    .. "|c00FF00Face all summons away from the group, interrupt Poison Barrage every time it is cast, and manage spiderling adds before they stack up.|r",
            },
            {
                name = "Azureblight Lurcher",
                strategy = "The Lurcher's |cFFD700Heavy Attack|r is a backhand swipe that must be blocked. |cFF4444Azureblight|r fist attacks create resource-draining AoEs on the ground.\n\n"
                    .. "|cFF4444Dragon Fire|r from Maarselok targets the arena -- if it connects with the boss, it empowers the Lurcher significantly.\n\n"
                    .. "The boss has three health bars; each time one is depleted, Maarselok himself takes 10% damage.\n\n"
                    .. "|c00FF00Manage adds between health bar transitions, avoid standing in resource-drain AoEs, and position the boss away from Maarselok's fire breath.|r",
            },
            {
                name = "Azureblight Cancroid",
                strategy = "|cFFD700Roaming Infestors|r drop seeds throughout the arena that must be dealt with -- kill the Infestors and have Selene cleanse the seeds.\n\n"
                    .. "The Cancroid has a |cFFD700Heavy Attack|r overhead smash, a |cFF4444Stomp|r creating blight circles, and a cone attack firing an azureblight wave.\n\n"
                    .. "The boss is only damageable during ~20-second vulnerable phases, so maximize your burst during these windows. Stranglers spawn after the first vulnerable phase.\n\n"
                    .. "|c00FF00Kill Infestors and let Selene cleanse seeds, save burst cooldowns for vulnerable phases, and AoE Stranglers down when they appear.|r",
            },
            {
                name = "Maarselok Phase 1",
                strategy = "Maarselok fires |cFF4444Dragon Fire|r as blue flame orbs across the arena and uses |cFFD700Unrelenting Force|r (Fus Ro Dah) for a massive knockback.\n\n"
                    .. "Hoarvor, Strangler, and Lurcher adds spawn continuously and must be managed to protect Selene.\n\n"
                    .. "During the perched attack phase, the dragon becomes vulnerable only when spiders reach his perch position.\n\n"
                    .. "|c00FF00Protect Selene at all costs, kill Stranglers with AoE, block Unrelenting Force to avoid being knocked into hazards, and DPS the dragon during vulnerable perch phases.|r",
            },
            {
                name = "Maarselok Final",
                strategy = "|cFFD700Head Smash|r covers a wide arc with knockback, and |cFF4444Wing Smash|r punishes anyone too close to his sides.\n\n"
                    .. "|cFFD700Unrelenting Force|r returns alongside |cFF4444Sweeping Breath|r (side-to-side fire) and |cFF4444Meteor Shower|r (fireballs creating persistent AoEs followed by a charge through the impact zone).\n\n"
                    .. "|cFFD700Scourge Seed|r infects a player with Azureblight, requiring group coordination to manage.\n\n"
                    .. "|c00FF00Position at the dragon's sides to avoid Head Smash, dodge the sweeping breath, move away from meteor impact zones because a charge follows, and on Hard Mode use the synergy to identify infected players when Selene goes hostile.|r",
            },
        },
    },

    ["Icereach"] = {
        order = 39,
        bosses = {
            {
                name = "Kjarg the Tuskscraper",
                strategy = "|cFFD700Hammer Pound|r slams the ground and pops ice spikes in a frontal cone, so always position behind the boss. "
                    .. "He periodically summons an |cFFD700Ice Atronach|r that should be burned down quickly before it overwhelms the healer. "
                    .. "|cFF4444Ice Twister|r tracks a random player and deals heavy damage on contact, so kite it away from the group in a wide arc. "
                    .. "During his |cFFD700Enraged Phase|r he hits significantly harder and faster, so the tank should ensure solid mitigation.\n\n"
                    .. "|c00FF00Stay behind the boss at all times to avoid Hammer Pound spikes. Kill Ice Atronachs immediately and kite the Twister away from the group.|r",
            },
            {
                name = "Sister Skelga",
                strategy = "Sister Skelga casts a large |cFFD700Ice AoE|r in front of her, so the group should always stand behind the boss to avoid it. "
                    .. "|cFF4444Dark Tether|r connects to the tank and drains health rapidly, requiring strong heals to sustain through. "
                    .. "She summons |cFFD700Strangler|r adds that are protected by a magical shield which can only be dispelled by fire damage. "
                    .. "Once the shield drops, the Stranglers die quickly to focused damage.\n\n"
                    .. "|c00FF00Kill Stranglers with fire damage to break their shields. Always stand behind the boss to avoid Ice AoE.|r",
            },
            {
                name = "Vearogh the Shambler",
                strategy = "Vearogh drops persistent |cFFD700Fire AoE|r patches on the ground that force the group to reposition frequently. "
                    .. "|cFF4444Wraith|r spawns are the highest priority target and must be killed immediately before they deal catastrophic damage. "
                    .. "He also summons |cFFD700Skeleton|r adds that drain your resources over time, making sustained combat increasingly difficult. "
                    .. "The tank should keep the boss faced away from the group at all times.\n\n"
                    .. "|c00FF00Kill Wraiths the instant they spawn as they are the most dangerous mechanic. Stay behind the boss and burn Skeletons when possible.|r",
            },
            {
                name = "The Stormborn Revenant",
                strategy = "The Revenant has a devastating |cFFD700Heavy Attack|r that must be blocked by the tank. "
                    .. "He summons |cFF4444Storm Atronachs|r that buff the boss significantly while alive, so they must be killed immediately. "
                    .. "Multiple overlapping AoEs cover the arena, requiring constant repositioning to survive. "
                    .. "In the final phase he channels |cFF4444Ice Storm|r, a massive room-wide attack that deals escalating damage.\n\n"
                    .. "|c00FF00Kill Storm Atronachs the moment they spawn. Stay near the healer and save ultimate abilities for the Ice Storm channel in the final phase.|r",
            },
            {
                name = "Mother Ciannait and Icereach Coven",
                strategy = "This is a five-boss encounter where |cFF4444kill order is critical|r. "
                    .. "Start with |cFFD700Sister Gohlla|r who drops dangerous ice AoEs, then kill |cFFD700Sister Hiti|r whose fire AoE actually damages enemies too. "
                    .. "Next eliminate |cFFD700Sister Bani|r, then |cFFD700Sister Maefyn|r who channels deadly shock AoEs, and finally |cFFD700Mother Ciannait|r who fires dark orbs. "
                    .. "All sisters periodically channel abilities that must be interrupted or they will overwhelm the group.\n\n"
                    .. "|c00FF00Follow the kill order: Gohlla > Hiti > Bani > Maefyn > Ciannait. Interrupt every channel. Use Hiti's fire AoE against Ciannait for bonus damage.|r",
            },
        },
    },
    ["Unhallowed Grave"] = {
        order = 40,
        bosses = {
            {
                name = "Hakgrym the Howler",
                strategy = "Hakgrym opens with physical swings and summons |cFFD700Crystal Totems|r that create AoE explosions, plus |cFFD700Woeful Totems|r at the arena edges that fire projectiles. "
                    .. "At around 60-70% health he summons a |cFF4444Flesh Abomination|r with slow but devastating ground slams. "
                    .. "When he reaches 0% health he transforms into a |cFF4444Werewolf|r, regenerating 50% HP and summoning skeleton adds. "
                    .. "The werewolf phase is essentially a second fight with increased aggression.\n\n"
                    .. "|c00FF00Destroy totems as soon as they spawn. Save your cooldowns and ultimates for the werewolf phase that triggers at 0% health.|r",
            },
            {
                name = "Keeper of the Kiln",
                strategy = "The Keeper fights with a sword alongside archer and swordsman allies on the ground level. "
                    .. "When she activates her |cFFD700Red Shield|r it triggers a mini-puzzle mechanic that must be solved. "
                    .. "When you see |cFF4444flames rising in vents|r, use the grapple hook to reach the upper level and activate the |cFFD700Sigil of the Forgotten|r nodes in the correct 1-4 sequence. "
                    .. "Matching the nodes correctly disables the shield and allows damage to resume.\n\n"
                    .. "|c00FF00Tank maintains ground aggro while others grapple to the sigils. Match the nodes in the correct order to break the Red Shield.|r",
            },
            {
                name = "Eternal Aegis",
                strategy = "The Aegis performs a |cFFD700Heavy Cross-Arm|r attack that knocks players back significantly if not dodged. "
                    .. "Its |cFF4444Boomerang Sword|r travels outward and returns, requiring you to stand in the circular gaps between blade paths. "
                    .. "During the |cFF4444Blue Wave Hurricane|r phase, the boss blocks all incoming attacks except in a safe zone near its center. "
                    .. "Positioning is the key to this entire fight.\n\n"
                    .. "|c00FF00Dodge the heavy attacks, use the gaps in the boomerang pattern, and stay in the center safe zone during the hurricane phase.|r",
            },
            {
                name = "Ondagore the Mad",
                strategy = "Ondagore creates an expanding |cFFD700Poison Field|r that slowly covers the arena floor. "
                    .. "|cFFD700Skeletal Arcanists|r spawn in the outer section and must be dealt with using the grapple hook to reach them. "
                    .. "At 50% health he channels a |cFF4444White Pulse|r that will one-shot anyone not hiding behind the stone pillars. "
                    .. "A |cFFD700Green Field|r also traps players and requires pillar cover, and 4 |cFF4444Menders|r channel energy to heal the boss.\n\n"
                    .. "|c00FF00Grapple to the outer section for Arcanists. Hide behind pillars for the White Pulse. Kill all 4 Menders before they fully heal the boss.|r",
            },
            {
                name = "Kjalnar Tombskald",
                strategy = "Kjalnar attacks with double sword slashes and a |cFFD700Heavy Charged|r attack that stuns on impact. "
                    .. "He throws |cFF4444Bone Knives|r that create spinning AoEs on the ground which persist and eventually explode for massive damage. "
                    .. "|cFF4444Blue Flame Skeletons|r march toward sigils at the arena edges and if they reach them, the boss becomes empowered. "
                    .. "At 50% he summons a |cFF4444Giant Skeleton|r that launches fireballs and channels a devastating Frost Breath.\n\n"
                    .. "|c00FF00Kill skeletons before they reach the edge sigils. Avoid bone knife explosion zones. Block the Giant Skeleton's Frost Breath.|r",
            },
        },
    },
    ["Stone Garden"] = {
        order = 41,
        bosses = {
            {
                name = "Exarch Kraglen",
                strategy = "Kraglen attacks with claw swipes and |cFF4444Slaughter|r, a devastating double swipe that must be blocked or dodged. "
                    .. "|cFFD700Charge|r targets a random player with a massive hit that causes knockdown if it connects. "
                    .. "|cFF4444Blood Rage|r is a roar that drains Stamina and Magicka from all players and |cFF4444must be interrupted immediately|r. "
                    .. "His |cFFD700Ground Smash|r breaks into damaging patterns on the floor. Hard Mode doubles his health pool.\n\n"
                    .. "|c00FF00Keep moving to avoid charges. Interrupt Blood Rage the instant you see the roar cast. Block or dodge Slaughter without fail.|r",
            },
            {
                name = "Stone Behemoth",
                strategy = "The Behemoth's |cFF4444Core Release|r pulls out its core causing a circular explosion that can one-shot players caught in it. "
                    .. "|cFFD700Ground Punch|r followed by |cFFD700Bomb Toss|r creates sequential phase-dependent AoEs across the arena. "
                    .. "|cFF4444Fire Nova|r covers nearly the entire room while |cFFD700Ice Nova|r immobilizes all players in place. "
                    .. "Three |cFFD700Stone Husks|r channel resource-draining beams, and the combination of Ice Nova and Husk beams is lethal.\n\n"
                    .. "|c00FF00Position near Stone Husks to cleave them down with boss damage. Find Fire Nova safe zones. Destroy Husks before Ice Nova traps you in their beams.|r",
            },
            {
                name = "Arkasis the Mad Alchemist",
                strategy = "Phase 1 involves destroying |cFFD700Shock Emitters|r via the Werewolf Thunderous Stomp ability and managing 4 |cFFD700Pressure Valve|r pillars. "
                    .. "Phase 2 features dagger attacks, |cFF4444Flame Tornado|r when on fire, a heavy attack, |cFFD700Fiery Stab|r DoT, and |cFFD700Flame Bottle|r that bounces 5-6 times leaving fire AoEs. "
                    .. "At 60% and 20% he enters intermissions with |cFF4444Stone Husks|r that tether to players (each player must tank one), |cFFD700Acid Rain|r (interrupt it), and Shock Emitters firing through pillars. "
                    .. "Below 20% he uses |cFF4444Bottled Lightning|r (following AoE), |cFF4444Pinning Bolt|r (pins a player, teammate must free them), and a charging attack.\n\n"
                    .. "|c00FF00Pre-assign Husk positions so each player takes one. Save ultimates for intermissions. Coordinate kiting direction and free pinned players immediately.|r",
            },
        },
    },
    ["Castle Thorn"] = {
        order = 42,
        bosses = {
            {
                name = "Dread Tindulra",
                strategy = "Tindulra uses |cFFD700Ferocious Bite|r with flame damage and |cFFD700Flame Retch|r as a frontal breath cone that must be faced away from the group. "
                    .. "|cFF4444Fire Spit|r launches fireballs that leave persistent AoE patches on the ground. "
                    .. "Her |cFFD700Dash|r targets a random player with a knockdown, and |cFF4444Pin Down|r leaps onto and stun-locks a player, which must be interrupted immediately. "
                    .. "She also summons Broodling adds that should be stacked together for efficient AoE.\n\n"
                    .. "|c00FF00Face the boss away from the group at all times. Interrupt Pin Down immediately to save the trapped player. Stack Broodlings for cleave damage.|r",
            },
            {
                name = "Blood Twilight",
                strategy = "Blood Twilight uses |cFFD700Blood Slash|r and |cFFD700Shadow Strike|r, a teleporting heavy attack that catches players off guard. "
                    .. "|cFFD700Dark Barrage|r is a channeled darkness attack, and 4 |cFF4444Blood Channeler|r adds empower the boss if left alive. "
                    .. "Channelers drop |cFF4444Blood Mines|r that explode on contact, and the fight alternates between ground and Blood Pool phases. "
                    .. "|cFFD700Reanimated Vampires|r and |cFFD700Shades|r that push players with cone attacks into deadly ichor pools also appear.\n\n"
                    .. "|c00FF00Tank the upper area. Kill Blood Channelers before they empower the boss. Block the Shade cone pushes to avoid being knocked into ichor.|r",
            },
            {
                name = "Vaduroth",
                strategy = "Vaduroth swings his sickle with standard attacks and a |cFFD700Heavy Attack|r downward smash. "
                    .. "|cFFD700Underhand Swing|r applies a debuff that creates an AoE when it expires, and |cFF4444Storm of Crows|r sends a roaming storm across the arena. "
                    .. "At 75%, 50%, and 25% he performs |cFF4444Sickle Throw|r, pulling all players to the sickle's location. "
                    .. "After each throw he summons a |cFFD700Reanimated Vampire|r and a |cFFD700Virulent Viscera|r add.\n\n"
                    .. "|c00FF00Spread out during sickle throws to avoid stacking damage. Destroy the sickle's magical shield for an allied add. Face Vampires away from group.|r",
            },
            {
                name = "Talfyg",
                strategy = "Talfyg attacks with claw swipes and a |cFF4444Heavy Attack|r with a devastating double-claw strike that can kill under-prepared tanks. "
                    .. "|cFFD700Death Beam|r is either ground-channeled or fires dual random-moving beams across the arena. "
                    .. "|cFF4444Ground Smash|r is a channeled large blast that leaves a persistent AoE behind. "
                    .. "He summons |cFFD700Gargoyle|r adds in Frozen (slow) or Seething (fire) variants. Gwendis provides occasional stuns to help.\n\n"
                    .. "|c00FF00Watch for the heavy attack telegraph and block it. Move away from persistent AoEs quickly. Use Gwendis stuns on dangerous add spawns.|r",
            },
            {
                name = "Lady Thorn",
                strategy = "Lady Thorn's |cFF4444Heavy Attack|r is devastating and can one-shot if not blocked, and she fires 6 |cFFD700Dark Bombs|r in two patterns: airborne outward and grounded explosions. "
                    .. "During |cFFD700Bat Swarm Stationary|r, a pillar of light indicates the safe green circle where the group must stack. "
                    .. "Her |cFFD700Bat Transformation|r creates a roaming AoE zone with bats that reconverge for a heavy attack, and |cFFD700Teleport Strike|r is blockable. "
                    .. "At 60% and 20% she performs |cFF4444Moving Bat Swarm|r where the safe zone roams, and |cFFD700Blood Guardian|r adds must be interrupted while |cFFD700Blood Scavenger|r adds drop the Blood Corruption synergy (collect 4 to end the phase).\n\n"
                    .. "|c00FF00Tank the boss in the center. Always block Heavies and Teleport Strikes. During moving swarm, pull adds to the safe zone and collect all 4 synergies to end the phase. On HM, the boss is targetable during the final swarm but her Heavy and Teleport can one-shot if unblocked.|r",
            },
        },
    },
    ["Black Drake Villa"] = {
        order = 43,
        bosses = {
            {
                name = "Kinras Ironeye",
                strategy = "Kinras swings with standard attacks and a |cFF4444Heavy Attack|r that knocks players down. "
                    .. "|cFFD700Triple Fire|r sends three fire prongs sliding across the floor, and |cFFD700Fire Grates|r spawn flames that create |cFFD700Blazing Salamanders|r. "
                    .. "His |cFFD700Roar|r calls salamanders to him and is interruptible, while |cFFD700Fiery Totem|r fires projectiles at the group. "
                    .. "During |cFFD700Phase Shift|r he throws his mace and fights unarmed with |cFFD700Rock Spikes|r (ground pounds on 2 players) and |cFF4444Fiery Fissures|r. Hard Mode adds Volcanic Smash, Geyser Burst, and Fiery Chains.\n\n"
                    .. "|c00FF00Face the boss away from the group. Manage salamander spawns and destroy Fiery Totems. Use the Avatar Synergy plate when available.|r",
            },
            {
                name = "Captain Geminus",
                strategy = "Geminus alternates between arrows and daggers with a |cFFD700Heavy Attack|r infused with lightning. "
                    .. "She fires 3 |cFF4444Lightning Orbs|r that fork on impact and places |cFFD700Lightning Mines|r on the ground. "
                    .. "|cFF4444Teleport Stomp|r deals devastating damage with knockback, and she creates up to 4 invulnerable |cFFD700Shade|r copies that channel lightning. "
                    .. "During her |cFFD700Invulnerability Phase|r she sends flame waves and an Air Atronach, and |cFFD700Fillet|r is a cone knife fan attack. True-Sworn Flame Hound adds also appear.\n\n"
                    .. "|c00FF00Spread out for Teleport Stomp. Interrupt the Shade blasts and Fillet channel. Focus adds during invulnerability phase.|r",
            },
            {
                name = "Pyroturge Encratis",
                strategy = "In Phase 1 (above 70%) Encratis attacks with fiery punches, fireballs, and a |cFFD700Spinning Kick|r that must be blocked. "
                    .. "|cFF4444Flaming Vortex|r spawns fire and |cFFD700Burning Specters|r, while |cFFD700Salamander Flame|r is a breath that creates explosive salamanders. "
                    .. "|cFF4444Firestorm|r is room-wide with a safe center, and spawns a |cFFD700Fire Behemoth|r. "
                    .. "In Phase 2 (below 70%) he draws his |cFFD700Heartsfire Blade|r, gains |cFF4444Heartsfire Spear|r (flying sword cone, block it), |cFFD700Heartsfire Inferno|r (persistent patches), and modified Firestorm where he teleports before channeling.\n\n"
                    .. "|c00FF00Tank the boss in the center. Manage Burning Specters quickly. Move to center during Firestorm. In Phase 2, use geysers to escape the platform when needed.|r",
            },
        },
    },
    ["The Cauldron"] = {
        order = 44,
        bosses = {
            {
                name = "Oxblood the Depraved",
                strategy = "Oxblood uses backhanded swipes and a |cFFD700Heavy Attack|r charged smash that should be blocked to stagger him. "
                    .. "|cFF4444Toxic Flatulence|r drops 3 poison clouds in a triangle pattern around the boss. "
                    .. "|cFFD700Exploding Chains|r appear under players and detonate after a short delay. "
                    .. "|cFF4444Bile Globs|r heal the boss if he eats them while |cFFD700Gore Globs|r spit damaging projectiles, and |cFFD700Poison Cage|r traps a player with a DoT that teammates must break.\n\n"
                    .. "|c00FF00Tank in the center. Destroy Bile and Gore Globs before the boss consumes them. Free caged teammates immediately.|r",
            },
            {
                name = "Taskmaster Viccia",
                strategy = "Viccia swings her staff and has a |cFFD700Heavy Attack|r that should be dodge-rolled rather than blocked. "
                    .. "She places |cFF4444Lightning Mines|r that stun on proximity and |cFFD700Ground Lightning|r that spins and persists on the floor. "
                    .. "|cFF4444Channeled Lightning|r must be interrupted or it deals escalating damage to the group. "
                    .. "|cFFD700Dremora Torturer|r and |cFFD700Slaver|r adds spawn periodically and must be managed.\n\n"
                    .. "|c00FF00Reposition constantly to avoid mines and ground lightning. Interrupt Channeled Lightning every time. Manage adds between mechanics.|r",
            },
            {
                name = "Molten Guardian",
                strategy = "The Guardian attacks with lava splashes and fireballs, and its |cFFD700Heavy Attack|r is a ground punch that leaves a lava puddle. "
                    .. "|cFF4444Flame Volley|r launches a dozen projectiles that each leave persistent fire patches, rapidly covering the arena. "
                    .. "|cFF4444Channeled Blast|r must be interrupted or it deals massive group-wide damage. "
                    .. "It periodically relocates and uses |cFFD700Nova Smash|r which must be dodged, while 2 |cFFD700Molten Fiend|r adds assist it.\n\n"
                    .. "|c00FF00Avoid accumulating puddles by positioning carefully. Interrupt Channeled Blast. Cleave the Molten Fiends with the boss for efficiency.|r",
            },
            {
                name = "Baron Zaudrus",
                strategy = "|cFFD700Hammer Down|r is a spinning attack that summons |cFF4444Molten Pillars|r around the arena. "
                    .. "|cFF4444Galvanic Blow|r is a cleave combined with lightning AoE that hits hard in a frontal arc. "
                    .. "|cFFD700Ash Vent|r plunges into the ground and creates a rotating flame beam that sweeps the arena. "
                    .. "He also uses |cFFD700Fiery Geyser|r and |cFF4444Stalactite|r falling debris, while Hard Mode adds Hammer Throw leaving magma AoEs.\n\n"
                    .. "|c00FF00Use Lyranth's Cold-Flame Infusion synergy to destroy Molten Pillars. Avoid the rotating flame beam. Keep the cleave isolated from the party.|r",
            },
        },
    },
    ["Red Petal Bastion"] = {
        order = 45,
        bosses = {
            {
                name = "Rogerain the Sly",
                strategy = "Rogerain whirls his staff releasing |cFF4444electrified tornadoes|r that deal damage and stun any player they touch. "
                    .. "|cFFD700Negation Field|r places a void circle on a player which then erupts into 8 smaller AoE explosions around it. "
                    .. "He can also |cFF4444turn a player into a goat|r, which is especially problematic if it targets the healer. "
                    .. "This is the simplest boss in the dungeon but the tornadoes can catch players off guard.\n\n"
                    .. "|c00FF00Avoid the tornadoes at all costs. Spread apart when the void circle appears to minimize overlap from the 8 eruptions.|r",
            },
            {
                name = "Eliam Merick",
                strategy = "This is a multi-phase fight with sub-bosses |cFFD700Ihudir|r and |cFFD700Liramindel|r appearing at health thresholds. "
                    .. "When |cFFD700Liramindel|r spawns, Eliam gains a |cFF4444damage shield|r and fires energy balls that stun players on contact. "
                    .. "|cFF4444Aftershock|r creates electrically charged fields on the ground that deal heavy DoT to anyone standing in them. "
                    .. "Two hard-hitting adds also spawn during the Liramindel phase and must be focused immediately.\n\n"
                    .. "|c00FF00Kill Liramindel to remove Eliam's damage shield. Avoid Aftershock fields. Focus the two hard-hitting adds immediately when they appear.|r",
            },
            {
                name = "Prior Thierric Sarazen",
                strategy = "|cFFD700Heinous Highkick|r is a charged kick with a stun that combos into |cFFD700Wide Slice|r, a heavy frontal cleave. "
                    .. "|cFF4444Opalescent Impale|r is an interruptible channel that will kill a group member if not stopped; you must get inside the bubble and bash to interrupt it. "
                    .. "|cFF4444Rockslide Rush|r is a charge with AoE that requires a dodge-roll to avoid. "
                    .. "|cFFD700Aftershocks|r leave electric fields and |cFFD700Duplicate Wall|r sweeps across the room changing sides. This boss has massive HP and needs high sustained DPS.\n\n"
                    .. "|c00FF00Get inside the bubble and bash to stop Opalescent Impale. Block or dodge Heinous Highkick. Dodge-roll Rockslide Rush every time.|r",
            },
        },
    },
    ["The Dread Cellar"] = {
        order = 46,
        bosses = {
            {
                name = "Scorion Broodlord",
                strategy = "The Broodlord spawns adds every few percent of health lost, steadily increasing the chaos in the arena. "
                    .. "|cFF4444Agonymium Stones|r appear and must be killed immediately because the boss will consume them to heal a significant amount. "
                    .. "He has heavy attacks that must be blocked and applies a persistent DoT on the tank. "
                    .. "On Hard Mode the adds spawn more frequently, making DPS even more critical.\n\n"
                    .. "|c00FF00Stack adds near the boss for efficient AoE cleave. Kill Agonymium Stones above all other priorities. Block heavy attacks.|r",
            },
            {
                name = "Cyronin Artellian",
                strategy = "This fight is not melee-friendly due to constant AoE pressure. |cFFD700Storm Atronachs|r cast |cFF4444Heart of the Storm|r, a massive AoE that covers most of the melee area. "
                    .. "The |cFFD700Boltwyrm|r slows players and fires |cFFD700Arresting Bolt|r, while |cFF4444Soulstorm|r must be dodge-rolled because it cannot be blocked. "
                    .. "On Hard Mode, lightning orb debuffs land on 2 players who drop AoEs as they move. "
                    .. "Kill Storm Atronachs immediately to clear the melee zone.\n\n"
                    .. "|c00FF00Kill Storm Atronachs as the top priority. Dodge-roll Soulstorm every single time. On HM, debuffed players must kite carefully away from the group.|r",
            },
            {
                name = "Magma Incarnate",
                strategy = "|cFF4444Frenzy|r is a devastating heavy attack that will kill the tank if not blocked. "
                    .. "Every ~20% health the boss opens a portal phase where an |cFFD700Agonymium Stone|r must be destroyed before the Scorion absorbs it, and the boss is invincible during this time. "
                    .. "|cFF4444Incarnate Outburst|r creates a yellow circle that the tank MUST stand in and block or the entire group dies. "
                    .. "|cFF4444Tornado Wall|r rotates through the arena and is lethal on contact. On Hard Mode, |cFFD700Path of Fire|r drops flame pools wherever you stand.\n\n"
                    .. "|c00FF00The tank must block Frenzy and stand in Incarnate Outburst without fail. Rush to kill the Stone in portal phases. Avoid the rotating Tornado Wall. This is one of the hardest bosses in ESO.|r",
            },
        },
    },
    ["Coral Aerie"] = {
        order = 47,
        bosses = {
            {
                name = "Maligalig",
                strategy = "|cFFD700Barbed Lance|r is a heavy attack the tank must block. |cFFD700Stomp|r creates a pink cloud that summons |cFFD700Yaghra Larva|r which explode in a |cFF4444Toxic Burst|r on their target. "
                    .. "|cFF4444Storm Cell|r lands on one player and deals heavy AoE damage to anyone standing nearby. "
                    .. "At approximately 70% and 35% health, |cFF4444Surging Waters|r floods the arena and players must quickly interact with fountains to create platforms, then kill adds. "
                    .. "The flooding mechanic is lethal if fountains are not activated in time.\n\n"
                    .. "|c00FF00Block the Barbed Lance. Move Storm Cell away from the group. Interact with fountains quickly during Surging Waters. Kill Yaghra Larva before they explode.|r",
            },
            {
                name = "Sarydil",
                strategy = "Sarydil uses |cFFD700Teleport Strike|r followed by a heavy attack that catches players off guard. "
                    .. "She dashes across the arena leaving traps in her wake and throws |cFF4444Blast Powder|r that creates fire pools with delayed explosions. "
                    .. "At approximately 74% and 34% health she jumps to the upper area, becoming untargetable while summoning minions and archers. "
                    .. "The add phases require focused DPS to prevent being overwhelmed before she returns.\n\n"
                    .. "|c00FF00Avoid the fire pools and stay mobile throughout the fight. Kill minions quickly during the add phases when she jumps to the upper area.|r",
            },
            {
                name = "Varallion",
                strategy = "Varallion's |cFF4444Heavy Attack|r MUST be blocked because dodge-rolling it causes a blast that knocks the entire group down. "
                    .. "|cFF4444Lethal waves|r cross the floor in 3 sets and will instantly kill anyone they touch. "
                    .. "|cFFD700Sea Orbs|r rise from the lagoon and must be destroyed before they reach their target. "
                    .. "Two gryphons spawn periodically, and at ~30% |cFF4444Kargaeda|r, a huge gryphon, arrives while a water fountain splits the arena. On Hard Mode, 2 players are purple-tethered and breaking the tether means death for 30 seconds.\n\n"
                    .. "|c00FF00ALWAYS block the heavy attack, never dodge-roll it. Watch wave telegraphs carefully. DPS must focus Sea Orbs. On HM, tethered players must stay close together for 30 seconds.|r",
            },
        },
    },
    ["Shipwright's Regret"] = {
        order = 48,
        bosses = {
            {
                name = "Foreman Bradiggan",
                strategy = "|cFFD700Paralyzing Fear|r sends 4 large AoEs moving outward that stun any player they hit. "
                    .. "|cFF4444Soul Bash|r is a powerful heavy attack that must be blocked or dodge-rolled. "
                    .. "At approximately 60% and 30% health he enters |cFF4444Possession|r, vanishing and placing large AoEs under players which are extremely dangerous if the group is stacked. "
                    .. "He also summons a |cFFD700Flesh Colossus|r that performs heavy damage ground slams.\n\n"
                    .. "|c00FF00Spread out during Possession phases to avoid overlapping AoEs. Block Soul Bash. Focus the Flesh Colossus when it spawns.|r",
            },
            {
                name = "Nazaray",
                strategy = "Three |cFF4444Untamed Kindreds|r spawn with growing AoEs that explode for a group wipe if all three detonate simultaneously. "
                    .. "|cFFD700Locust Rain|r requires constant movement to avoid, and |cFF4444Liquidate|r creates blue pools that deal heavy damage. "
                    .. "At around 60% health a Blue/Purple Phase begins where the boss becomes invulnerable with empowering circles. "
                    .. "The key is to focus-kill at least one Kindred quickly to create a safe zone from the detonation mechanic.\n\n"
                    .. "|c00FF00Focus-kill at least one Kindred quickly for a safe zone. Keep moving during Locust Rain. Do not waste resources attacking during the invulnerable phase.|r",
            },
            {
                name = "Captain Numirril",
                strategy = "|cFF4444Drown|r lifts the tank with a water hand, causing the boss to lose aggro and turn on the group. "
                    .. "He also uses a conal slash, large AoE slam, and a grab-lift-drop attack. "
                    .. "At approximately 85% and 40% he leaves the arena and summons |cFFD700Drowned Corpses|r in waves with poison AoEs that must be interrupted. "
                    .. "At 40% two |cFF4444Drowned Hulks|r spawn simultaneously and hit extremely hard.\n\n"
                    .. "|c00FF00Interrupt Drowned Corpses immediately. DPS must survive without the tank during Drown. Kill Corpses before the boss returns to the arena.|r",
            },
        },
    },
    ["Earthen Root Enclave"] = {
        order = 49,
        bosses = {
            {
                name = "Corruption of Stone",
                strategy = "The boss creates ground AoEs and summons minions during the standard phase. "
                    .. "At 80%, 61%, and 30% health it levitates and charges a |cFF4444deadly AoE|r that covers the arena. "
                    .. "|cFFD700Stone Walls|r appear and provide cover from the blast. After the initial dive attack, a second AoE follows immediately so you must stay behind the wall for both blasts. "
                    .. "Kill minions between levitate phases to keep the arena manageable.\n\n"
                    .. "|c00FF00Hide behind Stone Walls during every levitate phase. Stay behind cover for both blasts, not just the first one. Clear minions between phases.|r",
            },
            {
                name = "Corruption of Root",
                strategy = "This boss covers the arena with |cFF4444Poison AoEs|r that force constant repositioning. "
                    .. "At 60% and 20% health, three |cFFD700Distributaries|r spawn and must be killed quickly before the poison overwhelms the group. "
                    .. "The poison stacks rapidly and healers will struggle to keep up if the Distributaries live too long. "
                    .. "Keep moving at all times and prioritize the Distributary spawns above all else.\n\n"
                    .. "|c00FF00Keep moving constantly to avoid poison stacking. Focus Distributaries immediately at 60% and 20% before the poison becomes unmanageable.|r",
            },
            {
                name = "Archdruid Devyric",
                strategy = "|cFFD700Stone Pillars|r explode and fire projectiles across the arena. |cFF4444Fire Wolves|r lock onto a player, charge, and explode on contact. "
                    .. "|cFFD700Lightning Pillar|r fires shock projectiles and should be destroyed quickly. "
                    .. "At approximately 62% and 20% health he enters |cFF4444Bear Transformation|r, healing ~20% of his health and gaining a Shock Conal attack, Ground AoE charge, and a targeted charge along a visible line on the floor. "
                    .. "The fight is long due to the 20% self-heal on each transformation, so sustained DPS is critical.\n\n"
                    .. "|c00FF00Destroy Lightning Pillars quickly. Dodge Fire Wolves before they reach you. In Bear form, face the Shock Conal away from the group and dodge the visible charge line.|r",
            },
        },
    },
    ["Graven Deep"] = {
        order = 50,
        bosses = {
            {
                name = "The Euphotic Gatekeeper",
                strategy = "The Gatekeeper fires |cFFD700poison projectiles|r and players must interact with holes to use a synergy that removes the toxin buildup. "
                    .. "It charges forward sending AoEs in multiple directions with knockback on hit. "
                    .. "|cFF4444Teleport|r is followed by an expanding AoE that explodes for massive damage if you are caught in it. "
                    .. "It summons |cFFD700Decoys|r that explode for poison damage and must be destroyed before detonation.\n\n"
                    .. "|c00FF00Close the Pangrit holes with synergies to remove toxin. Stay clear of charge paths. Destroy decoys before they explode.|r",
            },
            {
                name = "Varzunon",
                strategy = "Varzunon summons skeleton minions including |cFF4444Skeletal Sacrifices|r that glow blue and must be killed before the boss consumes them. "
                    .. "Each consumed Sacrifice makes the boss physically larger and significantly harder to defeat. "
                    .. "He performs a ground stomp AoE, fires |cFFD700blue fire meteors|r (unavoidable single-target), creates clouds with projectiles, and uses a skeletal arm grasp. "
                    .. "This fight is a DPS race that gets progressively harder the longer it lasts.\n\n"
                    .. "|c00FF00DPS Skeletal Sacrifices above all other targets. The fight becomes exponentially harder with each consumed Sacrifice. High DPS is absolutely critical.|r",
            },
            {
                name = "Zelvraak the Unbreathing",
                strategy = "Zelvraak has a |cFFD700charged ice cone|r and a |cFF4444mass fear|r that disorients the group. "
                    .. "|cFF4444Sea Orbs|r descend slowly from above and must be destroyed before they reach the ground. "
                    .. "A deadly DoT is placed on a selected player and a ghost appears nearby that must be caught to recover their soul. "
                    .. "At 50% he pulls the group into a |cFF4444void realm|r where ghosts must be collected quickly to return, and at 75% and 25% he splits into 4 |cFFD700Shades|r.\n\n"
                    .. "|c00FF00Destroy Sea Orbs as the first priority. Catch the ghost to save the DoT player. Move fast in the void realm. Focus Shades down quickly.|r",
            },
        },
    },
    ["Bal Sunnar"] = {
        order = 51,
        bosses = {
            {
                name = "Kovan Giryon",
                strategy = "Kovan teleports to the arena edge creating a |cFF4444room-wide rectangular AoE|r that covers most of the floor. "
                    .. "He drops |cFFD700Poison AoE|r around himself and creates |cFFD700self-duplicates|r that detonate after a short delay. "
                    .. "Persistent beams sweep the arena between mechanics. At 70%, 45%, and 20% he enters a |cFF4444Dark/Shadow Phase|r where he becomes immune and spawns adds. "
                    .. "On Hard Mode an unpurgeable poison lands on all players as following AoEs, and overlapping them doubles the damage.\n\n"
                    .. "|c00FF00Watch for the edge teleport telegraph and move to the safe zone. Stack adds during Shadow Phase for efficient AoE. On HM, do not overlap poison AoEs.|r",
            },
            {
                name = "Roksa the Warped",
                strategy = "Roksa throws her head creating |cFF4444Darklight Orbs|r on the arena edges that tether to players with a 6-second countdown and must be interrupted. "
                    .. "She fires |cFF4444Massive Beams|r at the tank (triple beams on Hard Mode) and uses a |cFFD700Charged Heavy|r that must be blocked. "
                    .. "At 85%, 70%, and 25% she triggers a |cFF4444Darkness Phase|r with the callout 'Get to the Light' where two light spheres appear and standing outside them deals heavy damage. "
                    .. "Coordinating interrupts on the orbs while managing beam damage is the core challenge.\n\n"
                    .. "|c00FF00Interrupt Darklight Orbs within the 6-second window. Stand inside the light spheres during every Darkness Phase. Block the Charged Heavy.|r",
            },
            {
                name = "Matriarch Lladi Telvanni",
                strategy = "The Matriarch channels a |cFF4444wide poison vomit cone|r that follows the tank and must be faced away from the group, ideally with the tank's back against a wall. "
                    .. "She drops |cFFD700Poison AoEs|r and periodically triggers |cFF4444Poison Storm|r that fills the entire room with unavoidable poison damage. "
                    .. "During Poison Storm, healers must sustain the group until a |cFFD700time-stop synergy|r appears on the ground which must be activated immediately to end the storm. "
                    .. "She summons |cFF4444Skeevers|r that apply a deadly debuff and other adds during storms, and |cFFD700Shards of Time|r can be activated to immobilize all minions.\n\n"
                    .. "|c00FF00Tank faces the vomit cone away with back to wall. During Poison Storm, healers sustain until the time-stop synergy appears on the ground, then activate it immediately. Use Shards of Time to freeze adds. Kill Skeevers fast.|r",
            },
        },
    },
    ["Scrivener's Hall"] = {
        order = 52,
        bosses = {
            {
                name = "Riftmaster Naqri",
                strategy = "Naqri uses a |cFFD700spinning strike|r that can be blocked and summons a |cFFD700cyclone of books|r that fires ice bolts and frost AoEs. "
                    .. "Large and small tornadoes sweep the arena. The colored book mechanic activates at specific health thresholds: |cFFD700White Book|r at 85% (heavy attack add), |c00FF00Green Book|r at 55% (ground AoE add), and |cFF4444Red Book|r at 35% (projectile add). "
                    .. "Find matching colored books on the library shelves to remove the floating books and their associated adds. "
                    .. "During the massive AoE phase, standing on Green AoEs provides safety from the blast.\n\n"
                    .. "|c00FF00Track the boss's health percentage for book phases. Find the matching shelf books quickly. Stand on green AoE circles during the massive arena-wide blast.|r",
            },
            {
                name = "Ozezan the Inferno",
                strategy = "When Ozezan burrows, his old position becomes |cFF4444permanent lava|r, steadily shrinking the usable arena. "
                    .. "He fires |cFFD700laser beams|r at 2 players who must kite them away, and has a large |cFF4444conal cleave|r that must be faced away from the group. "
                    .. "|cFFD700Suction|r pulls all players toward the lava center, requiring resistance at the edges. "
                    .. "|cFF4444Larvae|r appear on the ground and must be stepped on immediately to prevent them from spawning adds. Iron Atronachs spawn at 40% and 20%, and he also has a poison conal.\n\n"
                    .. "|c00FF00Step on larvae immediately to prevent add spawns. Face the cleave away from the group. Resist suction at the edges. The arena shrinks from permanent lava with each burrow.|r",
            },
            {
                name = "Valinna and Lamikhai",
                strategy = "|cFFD700Lamikhai|r periodically enrages and must be lured to a green AoE to remove the enrage buff. "
                    .. "Smaller spiders immobilize and pull players toward Lamikhai for lethal damage. |cFFD700Valinna|r marks players creating permanent ground AoEs where they stand. "
                    .. "Circles appear around players and you must stay inside your own circle. |cFF4444Meteors|r must be destroyed before impact. "
                    .. "Lamikhai joins the fight at 50% of Valinna's health, creating a hectic dual-boss phase.\n\n"
                    .. "|c00FF00Kill spiders quickly. Place marked AoEs at the arena edges. Destroy meteors before they land. Lure enraged Lamikhai to the green AoE to remove the buff.|r",
            },
        },
    },
    ["Oathsworn Pit"] = {
        order = 53,
        bosses = {
            {
                name = "Packmaster Rethelros and Malthil",
                strategy = "This is a dual boss fight. |cFFD700Rethelros|r (archer) fires a rain of arrows, places 6 bear traps, marks a player then teleports for a charged shot with ground AoE, fires a deadly straight-line shot, and uses vanishing powder. "
                    .. "|cFFD700Malthil|r (wolf) enrages and slowly chases a player with a massive bite attack. "
                    .. "The |cFF4444Protective Totem|r creates a blue beam that reduces damage taken by both bosses and must be destroyed immediately. "
                    .. "Keeping the bosses separated prevents them from buffing each other.\n\n"
                    .. "|c00FF00Keep the bosses separated. Destroy the Protective Totem immediately when it appears. Kite the enraged Malthil wolf. Block the straight-line shot.|r",
            },
            {
                name = "Anthelmir and Construct",
                strategy = "|cFF4444Cinder Shot|r creates a red line between the boss and 3 players; block when he shoots, then move from the |cFFD700Bonfire|r that appears under each targeted player. "
                    .. "|cFFD700Heat Blast|r shield activates when he teleports, granting a shield with |cFF4444Blasted Shards|r until destroyed or the Construct merges at 70%. "
                    .. "The |cFFD700Construct|r uses a fire cone and throws its axe which it then retrieves along the same path. "
                    .. "Spread out for Cinder Shot to avoid stacking Bonfires.\n\n"
                    .. "|c00FF00Spread for Cinder Shot and block when he fires. Destroy the Heat Blast shield quickly. Face the Construct's fire cone away from the group.|r",
            },
            {
                name = "Aradros the Awakened",
                strategy = "Aradros has a |cFFD700charged heavy|r attack and creates |cFF4444ground AoEs|r where floor tiles light up with fire. "
                    .. "He charges at a random player dealing fire damage followed by a frontal cone. |cFFD700Awakened Fire|r adds spawn throughout. "
                    .. "At approximately 65% health, lava begins filling increasing numbers of tiles. At 50% he becomes |cFF4444invulnerable behind a fire orb|r and the group must clear an adjacent room of enemies to continue. "
                    .. "The arena progressively fills with lava throughout the remainder of the fight.\n\n"
                    .. "|c00FF00Avoid the lit floor tiles. Block or dodge the charged heavy. Clear the adjacent room at 50% as fast as possible. Stay mobile as the arena fills with more lava.|r",
            },
        },
    },
    ["Bedlam Veil"] = {
        order = 54,
        bosses = {
            {
                name = "Shattered Champion",
                strategy = "|cFFD700Heavy Ground Stomp|r causes a knockdown if not blocked. |cFF4444Delayed AoEs|r appear at player locations and persist on the ground. "
                    .. "|cFFD700Glass Fragments|r are miniature copies that fire projectiles, and |cFF4444Blind Path Glaziers|r channel beams making the boss and Fragments invulnerable. "
                    .. "At 80%, 60%, and 40% health, 2 Glaziers spawn and must be killed immediately. |cFF4444Razor Glass|r rings appear at 70% (outer ring) and 50% (center, shrinking the usable arena). "
                    .. "Arena management becomes critical as the fight progresses.\n\n"
                    .. "|c00FF00Block the ground stomp. Kill Glaziers immediately when they appear. Place persistent AoEs at the arena edges. Manage the shrinking arena from Razor Glass rings.|r",
            },
            {
                name = "Darkshard",
                strategy = "Darkshard's |cFF4444Heavy Attack|r has a 3.1-second windup while a shadow simultaneously attacks the furthest player. "
                    .. "|cFFD700Scream|r is a cone with ramping damage and slow, and |cFFD700Projectiles|r stun and pull players if not broken free. "
                    .. "At 80%, 60%, and 40% he teleports and releases a mini-boss, and each mini-boss's adds continue spawning even after the mini-boss dies. "
                    .. "The fight escalates relentlessly as add waves compound from all released mini-bosses.\n\n"
                    .. "|c00FF00Block the heavy attack; the furthest player must also block the shadow's strike. Exit the scream cone quickly. Tank under the hanging mini-bosses. Kill mini-bosses fast before add waves overwhelm.|r",
            },
            {
                name = "The Blind",
                strategy = "|cFFD700Cleave|r is a frontal attack that must be faced away, and the boss floats up for a heavy AoE around the tank. "
                    .. "Persistent ground AoEs spawn at players' feet throughout. Every 20% health the mechanic count increases, escalating the fight's difficulty. "
                    .. "|cFF4444Razor Glass|r rings appear at ~70% (outer) and ~50% (inner), progressively shrinking the arena. |cFFD700Shadow Skeletons|r spawn throughout as well. "
                    .. "Three colored buffs are available: |c00FF00Green|r clears a lane of hazards, |cFFD700Purple|r grants immunity to moving shards, and |cFFD700Orange|r slams the Blind to the ground during its jump attack.\n\n"
                    .. "|c00FF00Face the boss away from the group. Use Orange buff for the jump attack, Purple for moving shards, and Green to clear space. This is an endurance test with escalating mechanics every 20% health.|r",
            },
        },
    },
    ["Exiled Redoubt"] = {
        order = 55,
        bosses = {
            {
                name = "Executioner Jerensi",
                strategy = "The arena is filled with |cFF4444Spike Traps|r that activate at 80%, 75%, 50%, and 30% health. "
                    .. "When triggered, Jerensi charges away and activates traps across the room, leaving a |cFFD700Bleed DoT|r on anyone hit. "
                    .. "She has a |cFFD700frontal conal knockdown|r and a |cFFD700Death Knell AoE|r at her position when charging. "
                    .. "At 80% health she summons a Jailer and Torturer add.\n\n"
                    .. "|c00FF00Always follow the boss to the safe area after she charges. Dodge roll through spike traps if caught out. Kill adds quickly when they spawn at 80%. Block or sidestep the frontal cone.|r",
            },
            {
                name = "Prime Sorcerer Vandorallen",
                strategy = "|cFFD700Storm Bolt|r is a lightning javelin thrown at the furthest player, creating a large shock AoE on impact. "
                    .. "|cFF4444If players touch the AoE it triggers chain lightning hitting everyone.|r Spread out to avoid this. "
                    .. "During |cFFD700Iron Charge|r, the boss mounts a flaming horse and charges around the room leaving |cFF4444fire trails|r while summoning Iron Atronach Spiders. He becomes immune during this phase. "
                    .. "After dismounting he casts |cFF4444Blackspine Curse|r, a devastating DoT on one player that requires heavy healing.\n\n"
                    .. "|c00FF00Stay spread to prevent chain lightning. Kill Iron Atronach Spiders during the charge phase. Healers must be ready for Blackspine Curse after the dismount.|r",
            },
            {
                name = "Squall of Retribution",
                strategy = "A multi-phase air atronach fight. |cFFD700Six Sword Assault|r throws all six swords outward then recalls them, indicated by red AoEs. "
                    .. "At 95% the |cFF4444Fire Phase|r begins: Fire Atronachs spawn and drop |cFFD700Fire Orbs|r on death that must be picked up via synergy immediately or they bombard the group. Picking up applies a 15-second |cFFD700Ignited|r DoT. "
                    .. "At 65% the |cFF4444Frost Phase|r begins: Frost Atronachs drop Frost Orbs with the same mechanic, applying |cFFD700Freezing Death|r DoT. Arena edges freeze at 55%, 35%, and 5%, shrinking the arena. "
                    .. "At 30% the |cFF4444Shock Phase|r begins with Storm Atronachs and Shock Orbs following the same pattern.\n\n"
                    .. "|c00FF00Pick up orbs immediately via synergy. Wait for one phase's DoT to expire before pushing into the next phase. Coordinate orb pickups among the group to avoid stacking debuffs.|r",
            },
        },
    },
    ["Lep Seclusa"] = {
        order = 56,
        bosses = {
            {
                name = "Garvin the Tracker",
                strategy = "|cFFD700Piercing Dervish|r is a charge forward and behind him that applies |cFF4444Wild Spores|r, a heavy 8-second DoT. Stand to his sides to avoid it. "
                    .. "|cFFD700Noxious Boulder|r stuns if unblocked and creates a toxic AoE on impact. It can be aimed at |cFFD700Monstrous Dunerippers|r to one-shot them. "
                    .. "|cFF4444Ricochet|r marks 2 players for 6 seconds; if they have line of sight to each other when it expires, they die. Break LoS immediately. "
                    .. "|cFFD700Whirlwind|r backflip applies |cFF4444Trauma|r (healing absorption debuff, needs ~25k healing to remove). "
                    .. "Dunerippers spawn at 80%, 50%, and 40% and |cFF4444enrage instantly if damaged directly|r. At 30% Garvin fears the group and enrages all remaining Dunerippers.\n\n"
                    .. "|c00FF00Stand to Garvin's sides for Dervish. Break LoS with your Ricochet partner immediately. Use Noxious Boulder to kill Dunerippers without damaging them directly. Heal through Trauma debuffs.|r",
            },
            {
                name = "Noriwen",
                strategy = "|cFFD700Alcunar|r, a massive gryphon on a ledge, slaps its wings creating |cFFD700Wing Gusts|r that deal shock damage with AoEs around hit players. "
                    .. "It also Snaps, Stomps, and Swipes at players near the ledge. "
                    .. "At |cFF444470% and 20%|r health, Noriwen moves in front of Alcunar, |cFF4444pulls all players to her and attempts to stun them|r while Alcunar unleashes a massive frontal AoE. "
                    .. "At |cFF444450%|r Noriwen leaves the arena and summons |cFFD700Flame Gryphons|r with conal attacks, charge attacks, and fiery cyclones aimed at the tank. Kill them to force her return. "
                    .. "|cFFD700Shock Tornadoes|r from wing attacks persist and sweep the arena throughout.\n\n"
                    .. "|c00FF00Avoid Wing Gust paths and shock tornadoes. Break free immediately during the pull at 70% and 20%. Kill Flame Gryphons quickly at 50% to resume the main fight. Face gryphon cone attacks away from group.|r",
            },
            {
                name = "Orpheon the Tactician",
                strategy = "|cFF4444Confine|r blocks most of the arena with a green Planemeld wall that progressively moves and |cFF4444shrinks the safe fighting area|r. This is the core mechanic of the entire fight. "
                    .. "|cFFD700Tentacles|r spawn at 2 players' locations dealing AoE damage and knockback. "
                    .. "|cFFD700Runeblades|r launches 11 blades at each group member; dodge roll to avoid them. "
                    .. "At |cFF444480%, 50%, and 30%|r health, Orpheon teleports through an Apocryphal Gate into the blocked area, becomes invulnerable, and summons 1 large add and 3 small adds that must be killed to continue. "
                    .. "Below |cFF444420%|r he continuously moves the green wall side to side, making the safe zone a moving target.\n\n"
                    .. "|c00FF00Always stay in the clear zone. Dodge the Runeblades. Kill adds quickly during immunity phases. In the execute phase below 20%, move with the shifting safe zone or die.|r",
            },
        },
    },
    ["Black Gem Foundry"] = {
        order = 57,
        bosses = {
            {
                name = "Quarrymaster Saldezaar",
                strategy = "|cFFD700Seismic Splinters|r creates red AoE circles under each player that spawn falling black gems, applying a |cFF4444Black Gem Splinters DoT|r. "
                    .. "This DoT is cleansed at 65% and 30% health when the boss casts |cFFD700Rupture|r. "
                    .. "|cFFD700Galvanic Charge|r targets the furthest player with a charge attack. "
                    .. "|cFFD700Galvanizing Imps|r spawn frequently and cast |cFF4444Charged Lightning|r which must be interrupted or stunned. "
                    .. "At 78% the center of the arena begins pulsing with |cFF4444room-wide AoE damage|r.\n\n"
                    .. "|c00FF00Move out of Splinter AoEs quickly. Interrupt Galvanizing Imps casting Charged Lightning. Move to the outer ring at 78% to avoid center pulses. Push to 65% and 30% thresholds to cleanse the DoT via Rupture.|r",
            },
            {
                name = "Black Gem Monstrosity",
                strategy = "The |cFF4444Heavy Attack|r spawns crystals across the arena that must be avoided. "
                    .. "|cFFD700Laser Beam|r is a single-target attack on whoever has aggro. "
                    .. "|cFFD700Marked Projectiles|r target a player and fire crystal shards that explode on contact. "
                    .. "Periodically the boss teleports and summons a |cFFD700Pyromancer|r add while |cFFD700Glass Atronachs|r spawn throughout the fight.\n\n"
                    .. "|c00FF00Block the heavy attack and avoid the spawned crystals. Kill Glass Atronachs during cleave. Focus the Pyromancer quickly when it spawns during teleport phases.|r",
            },
            {
                name = "High Soulbinder Vykand",
                strategy = "|cFFD700Soulbinding Slam|r is a heavy attack that creates small AoEs under each player. Move immediately. "
                    .. "|cFF4444Acute Enervation|r targets a player with a shrinking red circle; adds spawn inside it and must be killed before the circle fills or the player dies. "
                    .. "Color-coded |cFFD700Soul Essences|r appear throughout: |cFF4444Red|r tethers then fires a line (stay and block), |cFFD700Yellow|r charges at players (dodge), |c00FF00Green|r bombards the group if too many accumulate (kill quickly). "
                    .. "At 60% |cFF4444Ominous Vision|r shows each player a safe tile; move to your tile or die.\n\n"
                    .. "|c00FF00Move from Slam AoEs. Burn adds inside Enervation circles immediately. Block red essences, dodge yellow, kill green. At 60% get to your shown safe tile quickly.|r",
            },
        },
    },
    ["Naj-Caldeesh"] = {
        order = 58,
        bosses = {
            {
                name = "Poxito",
                strategy = "Poxito's basic attacks hit extremely hard: |cFF444432k+ unblocked, 8-20k blocked|r. "
                    .. "|cFFD700Flamethrower|r follows whoever has aggro and must be faced away from the group. "
                    .. "The |cFF4444Heavy Attack|r deals massive damage and must be blocked or dodge rolled. "
                    .. "He summons |cFFD700undead adds|r periodically. The room contains |cFF4444pressure plates|r that activate environmental traps if stepped on.\n\n"
                    .. "|c00FF00Tank must always block basic attacks and face the Flamethrower away from the group. Avoid stepping on pressure plates. Kill undead adds as they spawn.|r",
            },
            {
                name = "Voskrona",
                strategy = "Voskrona |cFFD700possesses statues|r multiple times during the fight, becoming a statue herself. "
                    .. "|cFFD700Voskrona Guardians|r and |cFFD700Flamerocks|r spawn as adds, and when killed they create a |cFF4444Fatal Pool|r that makes nearby enemies invulnerable and damages players standing in it. "
                    .. "The center of the room has a |cFF4444pulsating ring|r that deals escalating damage over time. "
                    .. "During the |cFF4444Skull Phase|r the boss stands as a skull in the center, becomes invulnerable, and unleashes room-wide AoEs.\n\n"
                    .. "|c00FF00Kill statue adds away from the boss to prevent Fatal Pool invulnerability. Stay mobile to avoid the center pulse damage. Survive the Skull Phase with healing and damage shields.|r",
            },
            {
                name = "Talen-Lah and Bar-Sakka",
                strategy = "This is a |cFFD700dual boss fight|r where both enemies act independently. "
                    .. "|cFFD700Bar-Sakka|r spins at the arena edges leaving |cFF4444AoE trails|r behind. Do not stand near the edges. "
                    .. "|cFFD700Talen-Lah|r has a |cFFD700Flamethrower|r that follows whoever has aggro and must be faced away. "
                    .. "On Veteran, Talen-Lah summons |cFF4444Shadow Clones|r that slam their staffs creating AoE damage zones. "
                    .. "When one boss is targeted, the other continues fighting independently, requiring constant awareness of both.\n\n"
                    .. "|c00FF00Tank faces Talen-Lah's Flamethrower away from the group. Stay away from arena edges during Bar-Sakka's spin. Move out of Shadow Clone slam zones. Manage positioning for both bosses simultaneously.|r",
            },
        },
    },

}, -- end dungeons

trials = {

-- DungeonStrats: Trials (Aetherian Archive through Lucent Citadel)
-- This file contains trial entries to be inserted into the main data table.

    ["Aetherian Archive"] = {
        order = 1,
        bosses = {
            {
                name = "Lightning Storm Atronach",
                strategy = "The Lightning Storm Atronach periodically channels |cFFD700Impending Storm|r, a massive expanding AoE centered on itself that will devastate anyone caught inside. "
                    .. "|cFF4444Move away from the boss immediately when you see the storm building|r, as the damage ramps quickly and can kill even tanks. "
                    .. "Throughout the fight, |cFFD700Lightning Fields|r appear on the ground as persistent electrified pools that deal heavy shock damage over time. "
                    .. "Smaller Atronach Adds spawn periodically and should be burned down by DPS before they overwhelm the healers.\n\n"
                    .. "|c00FF00Face the boss away from the group at all times to avoid cleave damage. "
                    .. "Stay out of the lightning pools and keep mobile between safe zones. "
                    .. "Assign a few DPS to prioritize adds so the raid does not get overrun.|r",
            },
            {
                name = "Foundation Stone Atronach",
                strategy = "The Foundation Stone Atronach's signature ability is |cFFD700Big Quake|r, a massive stomp that sends shockwaves across the arena dealing lethal AoE damage to anyone nearby. "
                    .. "|cFF4444Melee players must dodge roll or move out when the stomp winds up|r, as it will one-shot most non-tanks. "
                    .. "He also uses |cFFD700Boulder Toss|r, hurling rocks at random players that deal heavy damage and must be blocked. "
                    .. "Stone Atronach Adds spawn throughout the encounter and can quickly pile up if ignored.\n\n"
                    .. "At low health the boss enters an |cFF4444Enrage phase|r with faster attacks and increased damage. "
                    .. "|c00FF00Ranged DPS should handle the adds while melee focuses the boss. "
                    .. "Block Boulder Toss if targeted and save ultimates for the enrage burn phase.|r",
            },
            {
                name = "Varlariel",
                strategy = "Varlariel uses |cFFD700Teleport Strike|r to randomly blink to a player and deliver a devastating blow, making positioning unpredictable. "
                    .. "Her most dangerous mechanic is |cFFD700Conjured Reflections|r, which creates clones of herself that mirror her abilities and must be killed immediately. "
                    .. "|cFF4444If the Reflections are left alive, their combined damage output will rapidly overwhelm the healers.|r "
                    .. "She also channels |cFFD700Overcharge|r, applying a heavy debuff that reduces healing received and increases damage taken.\n\n"
                    .. "|c00FF00Kill Reflections the instant they appear before returning to the boss. "
                    .. "Interrupt any channeled abilities to prevent Overcharge from stacking. "
                    .. "Spread slightly so Teleport Strike does not cleave multiple players at once.|r",
            },
            {
                name = "The Celestial Mage",
                strategy = "The Mage conjures |cFFD700Conjure Axe|r, summoning spectral axes that chase players across the arena and must be kited away from the group. "
                    .. "She lays |cFFD700Mine Field|r, scattering exploding mines across the floor that detonate on contact for massive damage. "
                    .. "|cFFD700Chain Lightning|r bounces between players who are standing too close together, so |cFF4444the entire raid must SPREAD OUT|r to prevent chain damage. "
                    .. "Constellation Adds including The Axes and a Warrior construct spawn at health thresholds and must be burned down quickly.\n\n"
                    .. "|cFFD700Ice Comet|r drops large AoE circles on random players throughout the fight, requiring constant repositioning. "
                    .. "At low health, the Mage enters an |cFF4444Execute Enrage|r with dramatically increased damage output. "
                    .. "|c00FF00Assign specific players to clear mines, designate kiters for axes, and spread for Chain Lightning. "
                    .. "Burn Constellation Adds fast and save ultimates for the enrage phase.|r",
            },
        },
    },
    ["Hel Ra Citadel"] = {
        order = 2,
        bosses = {
            {
                name = "Ra Kotu",
                strategy = "Ra Kotu generates |cFFD700Gusts|r of random wind that push players around the arena and must be kited away from the group. "
                    .. "His |cFFD700Six Sword Assault|r throws four swords diagonally outward that return to the boss, so |cFF4444never stand in the diagonal lines from the boss|r or you will be hit twice. "
                    .. "At 35% health he begins a |cFFD700Spinning Attack|r, a massive whirlwind that shreds anyone in melee range.\n\n"
                    .. "War-Priest and Destroyer adds spawn regularly and must be removed immediately before they buff the boss. "
                    .. "|cFF4444Below 35%, all melee DPS must switch to ranged attacks|r as the spinning attack is nearly unsurvivable up close. "
                    .. "|c00FF00Face the boss away from the group and kill adds on spawn. "
                    .. "Maintain safe distance during the execute phase and burn with ranged ultimates.|r",
            },
            {
                name = "Yokeda Rok'dun",
                strategy = "Yokeda Rok'dun spits |cFFD700Flaming Circles|r in multiple directions, creating fire lines that deal heavy damage to anyone standing in them. "
                    .. "A Welwa companion continuously respawns throughout the fight and grows larger each time it is revived. "
                    .. "|cFF4444The off-tank must pull the enlarged Welwa away from the group|r to prevent its devastating AoE from hitting the raid.\n\n"
                    .. "Once the Welwa grows to full size, the group should stack on the boss and burn while the off-tank kites the beast at a distance. "
                    .. "|c00FF00Melee DPS should always position behind the Welwa to avoid its frontal attacks. "
                    .. "Avoid the fire lines and focus damage on the boss between Welwa phases.|r",
            },
            {
                name = "Yokeda Kai",
                strategy = "Yokeda Kai splits into |cFFD700Four Clones|r that appear in the corners of the room, each channeling dangerous abilities simultaneously. "
                    .. "Each clone channels |cFFD700Channeled Fire|r which |cFF4444must be interrupted immediately|r or it will deal lethal damage to the entire raid. "
                    .. "The boss also casts |cFFD700Meteor|r on random players that is fatal if not blocked.\n\n"
                    .. "|cFF4444Always block when you see the Meteor indicator on you|r, as an unblocked hit is almost certainly lethal. "
                    .. "|c00FF00Tank the boss away from center to give room for clone positioning. "
                    .. "Assign one DPS to each clone corner to ensure all four are interrupted simultaneously. "
                    .. "The entire raid must be ready to block Meteors at any time.|r",
            },
            {
                name = "The Warrior",
                strategy = "The Warrior hurls his |cFFD700Shield Toss|r in a narrow line that can |cFF4444one-shot any player caught in its path, so DODGE immediately|r when you see the telegraph. "
                    .. "His |cFFD700Leaping Attack|r targets the furthest player and is fatal on impact, so ranged players must be aware of their positioning. "
                    .. "The |cFFD700Heavy Combo|r is a four-strike chain that the tank |cFF4444must block every single hit|r or be killed outright. "
                    .. "Flame-Shaper adds must be interrupted and Destroyers drop red circles that must be avoided.\n\n"
                    .. "A yellow AoE provides a healing buff to the boss which is removed at 85% health, while a blue AoE provides a damage buff removed at 70%. "
                    .. "At 35% he enters the |cFFD700Shehai Phase|r, drawing a sword of light with massively increased damage and deadly frontal cleaves. "
                    .. "|cFFD700Star Fall|r bombardment rains from the sky and all players must spread to avoid overlapping damage. "
                    .. "|c00FF00Tank near the blue circle for the damage buff, block all combos, and manage adds throughout. "
                    .. "After 35% the raid must dodge frontal attacks and burn the boss as fast as possible.|r",
            },
        },
    },
    ["Sanctum Ophidia"] = {
        order = 3,
        bosses = {
            {
                name = "Possessed Mantikora",
                strategy = "The Possessed Mantikora is a deadly beast whose mechanics demand precise coordination from the entire raid. "
                    .. "|cFF4444Do NOT spam taunt on this boss|r — if overtaunted (more than once every 7-10 seconds), "
                    .. "the Mantikora will rampage uncontrollably across the arena killing anyone she reaches. "
                    .. "Her |cFFD700Heavy Attack|r is a devastating frontal slam that must be blocked by the tank, and her |cFFD700Cleave|r will one-shot any non-tank in front of her.\n\n"
                    .. "|cFFD700Popcorn (Quake)|r causes three consecutive AoE explosions that launch players into the air, hitting three players each wave for nine total. "
                    .. "|cFFD700Black Holes|r spawn randomly on players and teleport them to a side arena where they must kill a mini-boss within 100 seconds or the Mantikora enrages. "
                    .. "|cFFD700Poison Shards|r always target the furthest player from the boss with massive red circles dealing heavy poison damage.\n\n"
                    .. "|c00FF00Tank must face the boss away from the group and apply taunt passively without spamming. "
                    .. "Ranged players should stay loosely stacked at the back to kite Poison Shards away from melee. "
                    .. "Players sent to Black Holes must burn the mini-boss fast and return before the timer expires.|r",
            },
            {
                name = "Stonebreaker",
                strategy = "Stonebreaker releases |cFFD700Consuming Swarm|r, creating poison clouds that linger on the ground and force the group to reposition constantly. "
                    .. "Lamia Healer Adds are the top priority as |cFF4444they will outheal all DPS on the boss if not killed immediately|r. "
                    .. "|cFFD700Stone Fist|r is a devastating hit on the tank that must be blocked and healed through.\n\n"
                    .. "The boss enters an |cFF4444Enrage|r at low health, significantly increasing his damage output and attack speed. "
                    .. "|c00FF00Burn the Lamia Healers first every time they spawn before returning to the boss. "
                    .. "Face the boss away from the group and stay mobile to avoid poison clouds. "
                    .. "Save ultimates for the enrage phase to finish the fight quickly.|r",
            },
            {
                name = "Ozara",
                strategy = "Ozara's most critical mechanic is |cFFD700Serpent's Gaze|r, a frontal cone fear that |cFF4444ALL twelve players must turn their character away from to avoid being feared|r. "
                    .. "This requires precise coordination as even one feared player can cascade into a wipe. "
                    .. "|cFFD700Poison Rain|r covers the arena periodically, dealing sustained damage that healers must manage through. "
                    .. "Lamia and Troll Adds spawn in waves, with trolls entering an enrage if not killed quickly.\n\n"
                    .. "|cFFD700Enervating Bolt|r targets random players with heavy magic damage that must be healed immediately. "
                    .. "|c00FF00Coordinate the 'look away' call across all twelve players using voice comms. "
                    .. "Kill trolls before they enrage and interrupt the Lamia healers. "
                    .. "Maintain strong group heals during Poison Rain phases.|r",
            },
            {
                name = "The Serpent",
                strategy = "The Serpent submerges during the |cFFD700Poison Phase|r, filling the arena with lethal poison while designated players must stand on specific rocks and platforms in order to cleanse sections. "
                    .. "|cFFD700World Shaper|r is a massive slam followed by shockwaves that radiate outward, requiring the raid to dodge or block. "
                    .. "During the |cFFD700Magma Phase|r, sections of the arena become lava and standing in them is instantly lethal. "
                    .. "When the boss raises a |cFFD700Stone Shield|r, it reflects all ranged damage, so |cFF4444ranged DPS must immediately stop attacking|r.\n\n"
                    .. "|cFFD700Tail Swipe|r covers a large rear cone, so never stand behind the boss. "
                    .. "The arena physically shrinks at low health, forcing the raid into an increasingly tight space. "
                    .. "|c00FF00Designate specific players for rock cleansing duty in the correct order. "
                    .. "Two tanks are needed for swap mechanics. "
                    .. "Stop all ranged DPS during Stone Shield and move together as the arena shrinks in the final phase.|r",
            },
        },
    },
    ["Maw of Lorkhaj"] = {
        order = 4,
        bosses = {
            {
                name = "Zhaj'hassa the Forgotten",
                strategy = "Zhaj'hassa applies a stacking |cFFD700Shadow Debuff|r to players, and |cFF4444at maximum stacks the affected player becomes hostile to the raid|r, attacking their own allies. "
                    .. "Lunar and Shadow Pads around the arena allow players to cleanse by standing in the correct light or dark pad matching their debuff. "
                    .. "|cFFD700Shattering Strike|r is a devastating tank buster that must be blocked and immediately healed.\n\n"
                    .. "Dro-m'Athra Panther Adds spawn throughout the fight and the off-tank must grab them before they reach the healers. "
                    .. "|cFFD700Dark Barrage|r is a frontal cone that will shred anyone caught in its path. "
                    .. "|c00FF00Manage the cleansing rotation across all twelve players using voice communication. "
                    .. "Players must call out their debuff stacks and move to pads before reaching maximum. "
                    .. "Off-tank grabs panthers while the main tank faces the boss away from the group.|r",
            },
            {
                name = "S'kinrai and Vashai",
                strategy = "S'kinrai and Vashai are twin bosses with Lunar and Shadow aspects, requiring the raid to split into two groups of six. "
                    .. "|cFF4444Players must NEVER cross into the wrong twin's area|r or they will take rapidly escalating damage and likely die. "
                    .. "Both bosses use |cFFD700Threshing Wings|r, a large AoE that hits everyone on their respective side. "
                    .. "|cFFD700Prayer|r is a channeled heal that |cFF4444must be interrupted on BOTH sides simultaneously|r or the boss will recover massive health.\n\n"
                    .. "At health thresholds the bosses swap positions, requiring both groups to adjust. "
                    .. "Both twins must die within roughly 10% health of each other or the survivor will enrage and wipe the raid. "
                    .. "|c00FF00Split into balanced groups of six with a tank and healer each. "
                    .. "Coordinate interrupts across both sides and balance DPS to keep health percentages close.|r",
            },
            {
                name = "Rakkhat",
                strategy = "Rakkhat is one of ESO's most demanding encounters, centered around |cFFD700Lunar Bastion|r pad rotation as |cFFD700Darkness Falls|r meteors leave void zones that corrupt each pad. "
                    .. "|cFF4444A designated leader must call rotations to fresh pads, as running out of clean pads means a wipe.|r "
                    .. "|cFFD700Threshing Wings|r is a massive arena-wide attack requiring the group to stack on the active pad for protection. "
                    .. "|cFFD700Dark Barrage|r is a channeled beam aimed at the tank that deals enormous sustained damage.\n\n"
                    .. "During the |cFFD700Shadow Realm Phase|r, players are pulled into a dark dimension and must kill a miniboss quickly to return. "
                    .. "|cFFD700Backhand|r is a devastating melee hit requiring a |cFF4444tank swap mechanic|r where both tanks alternate the boss. "
                    .. "Below 15% health, |cFFD700Crushing Void|r fills the arena with darkness in the execute phase, demanding maximum healing output. "
                    .. "|c00FF00Pad rotation is the core of this fight: follow the caller, never waste pads. "
                    .. "Two tanks must swap for Backhand and the shadow realm team must kill their miniboss fast.|r",
            },
        },
    },
    ["Halls of Fabrication"] = {
        order = 5,
        bosses = {
            {
                name = "Hunter-Killer Fabricants",
                strategy = "The Hunter-Killer Fabricants are a pair of bosses that |cFF4444must die close together or the survivor will enrage|r and wipe the raid. "
                    .. "|cFFD700Pinion Sever|r is a frontal cleave from each fabricant that will shred anyone standing in front. "
                    .. "|cFFD700Venom Injection|r applies a stacking poison that must be purged before it overwhelms the healers. "
                    .. "|cFFD700Shock Volley|r rains AoE lightning on random players, requiring constant repositioning.\n\n"
                    .. "Spider Fabricant Adds spawn throughout and should be cleaved down with AoE. "
                    .. "|c00FF00Split DPS evenly between both fabricants to keep their health balanced. "
                    .. "Each tank takes one boss and faces them apart from each other. "
                    .. "Purge Venom Injection stacks promptly and organize into two balanced sub-groups of six.|r",
            },
            {
                name = "Pinnacle Factotum",
                strategy = "The Pinnacle Factotum fires |cFFD700Conduit Strike|r, a lightning chain that arcs between players who are too close together, so |cFF4444the raid must SPREAD OUT|r to prevent chain damage. "
                    .. "|cFFD700Shock Barrage|r hammers the tank with heavy shock damage that must be blocked through. "
                    .. "Centurion Adds hit extremely hard and must be focused down immediately when they spawn.\n\n"
                    .. "|cFFD700Static Field|r creates persistent AoE zones on the ground that deal continuous shock damage. "
                    .. "|cFFD700Overload Pulse|r periodically hits the entire arena, requiring healers to keep everyone topped off. "
                    .. "|c00FF00Spread to avoid Conduit Strike chains, focus Centurion adds on spawn, and healers must be ready for Overload Pulses.|r",
            },
            {
                name = "Archcustodian",
                strategy = "The Archcustodian uses |cFFD700Shock Reach|r, a long-range tank buster that must be blocked or it will stagger and likely kill the tank. "
                    .. "|cFFD700Positron Field|r is a large spinning AoE that sweeps across the arena, requiring the entire group to move together as a unit to avoid it. "
                    .. "Sphere Adds emit damaging beams across the room and |cFF4444must be killed quickly|r before the beam damage overwhelms the raid.\n\n"
                    .. "At health thresholds, |cFFD700Capacitor Overload|r hits the entire room with massive damage, requiring shields and burst healing from every healer. "
                    .. "|cFFD700Steam Vent|r is a frontal cone that the tank must face away from the group. "
                    .. "|c00FF00Move together as a group during Positron Field, kill spheres immediately, and pop shields before each Overload.|r",
            },
            {
                name = "Assembly General",
                strategy = "The Assembly General uses |cFFD700Titanic Smash|r, a massive frontal slam that will kill any non-tank caught in its path. "
                    .. "|cFFD700Shock Field|r electrifies sections of the ground, forcing repositioning throughout the fight. "
                    .. "Ruined Factotum Adds will |cFF4444self-destruct when they reach melee range|r, so they must be killed at distance before they reach the group.\n\n"
                    .. "The boss alternates between |cFFD700Calefaction|r and |cFFD700Frigid|r phases, switching between fire and ice mechanics that require different positioning strategies. "
                    .. "|cFFD700Overcharge Meltdown|r is the enrage timer that will wipe the raid if DPS is too slow. "
                    .. "|c00FF00Kill self-destruct adds at range, adapt positioning for fire and ice phases, block Titanic Smash, and have both tanks ready for phase swaps.|r",
            },
            {
                name = "The Refabricated",
                strategy = "The Refabricated consists of three simultaneous bosses: the Reducer, Reactor, and Reclaimer, which |cFF4444must all die within seconds of each other or survivors will enrage|r and wipe the raid. "
                    .. "|cFFD700Reclaim|r pulls a player into a beam and they must be freed immediately by allies or they will die. "
                    .. "|cFFD700Reduce|r applies stacking damage debuffs that make affected players increasingly fragile. "
                    .. "|cFFD700React|r creates explosive spheres that must be avoided at all costs.\n\n"
                    .. "At health thresholds, |cFFD700Fabrication Beams|r link the three bosses together, dealing heavy damage in between. "
                    .. "|cFFD700Overcharge|r triggers a wipe if the enrage timer is reached. "
                    .. "|c00FF00Three tanks is ideal, one per boss. Balance DPS across all three to keep health percentages even. "
                    .. "Free Reclaim targets immediately, avoid Reactor spheres, and communicate health percentages constantly. "
                    .. "This is one of ESO's most coordination-heavy encounters.|r",
            },
        },
    },
    ["Asylum Sanctorium"] = {
        order = 6,
        bosses = {
            {
                name = "Saint Llothis the Pious",
                strategy = "Saint Llothis teleports around the arena leaving |cFFD700Noxious Gas|r, a poison AoE that snares and damages anyone who steps in it. "
                    .. "|cFFD700Defiled Blast|r targets a random player with a large cone attack, indicated by the player glowing green; |cFF4444the targeted player must stay still and block|r to survive. "
                    .. "Llothis channels |cFFD700Oppressive Bolts|r and the |cFFD700Soul Stained Corruption|r cast |cFF4444must be interrupted|r or it will deal devastating group-wide damage.\n\n"
                    .. "Two Imperfect Attendant adds cycle between active and inactive states and will enrage if left alive for more than 30 seconds. "
                    .. "|c00FF00Position the group in a semi-circle behind the boss. "
                    .. "Interrupt Soul Stained Corruption immediately and keep the Attendant adds away from the main group. "
                    .. "Stay out of the Noxious Gas pools.|r",
            },
            {
                name = "Saint Felms the Bold",
                strategy = "Saint Felms uses |cFFD700Teleport Strike|r to leap to the furthest player, applying a bleed DoT and a |cFFD700Shrapnel Storm|r AoE that increases in frequency as his health drops: once above 75%, twice between 75-50%, and three times below 50%. "
                    .. "|cFFD700Manifest Wrath|r targets two players with crashing AoE impacts followed by three red wave patterns that spread outward. "
                    .. "|cFFD700Pneuma Projections|r spawn adds that use |cFFD700Cyclonic Carving|r to spin and |cFFD700Lead to Slaughter|r to pull players in.\n\n"
                    .. "The boss also applies |cFFD700Maim|r, reducing player damage output significantly. "
                    .. "|c00FF00Assign two kiters to the east and west edges to absorb Teleport Strikes. "
                    .. "The tank faces the boss south while the group stacks behind. "
                    .. "Kill Pneuma Projection adds before they enrage.|r",
            },
            {
                name = "Saint Olms the Just",
                strategy = "Saint Olms jumps with |cFFD700Gusts of Steam|r at 90%, 75%, 50%, and 25% health, creating huge AoE plus individual player AoEs that |cFF4444must NOT overlap|r or the combined damage will kill players instantly. "
                    .. "|cFFD700Exhaustive Charges|r sends lightning balls at the furthest player in the front 180-degree arc, draining magicka in an AoE. "
                    .. "During |cFFD700Storm the Heavens|r, the boss hovers and rains shock AoEs while each player receives five consecutive ground AoEs they must kite.\n\n"
                    .. "|cFFD700Scalding Roar|r is a massive frontal cone that will obliterate anyone caught in it. "
                    .. "At 25%, |cFFD700Trial by Fire|r adds three fire AoEs, flame waves, and a burning DoT to all existing mechanics. "
                    .. "|cFFD700Ordinated Protector Spheres|r shield the boss and must be killed to remove the protection. "
                    .. "Purifier Spiders self-destruct in fire AoEs. "
                    .. "|c00FF00Hard Mode adds one or both other Saints with full mechanics. Kill order is Felms first, then Llothis, then Olms. "
                    .. "Two tanks minimum, three for the hardest version.|r",
            },
        },
    },
    ["Cloudrest"] = {
        order = 7,
        bosses = {
            {
                name = "Shade of Galenwe",
                strategy = "The Shade of Galenwe is an ice-aspected Welkynar Knight who fights alongside his gryphon |cFFD700Falarielle|r. "
                    .. "|cFF4444The knight and gryphon must be kept separated at all times|r — when they are close together, both deal massively increased damage that will overwhelm the group. "
                    .. "Galenwe uses |cFFD700Frost Leap|r to target the furthest player and slam down with a frost AoE impact zone that must be dodged.\n\n"
                    .. "|cFFD700Hoarfrost|r is his signature mechanic: a random player begins glowing white and receives a slowing DoT that also damages nearby allies. "
                    .. "The affected player must kite away from the group until the effect fades. "
                    .. "When Falarielle takes flight and begins blinking white, the Hoarfrost mechanic activates. "
                    .. "|cFF4444Both the knight and gryphon must die at roughly the same time|r or the survivor will enrage.\n\n"
                    .. "|c00FF00Off-tank pulls Falarielle away from Galenwe. "
                    .. "When the gryphon lands, focus it down; when airborne, switch to the knight. "
                    .. "The Hoarfrost target must move away from the group immediately.|r",
            },
            {
                name = "Shade of Siroria",
                strategy = "The Shade of Siroria is a fire-aspected Welkynar Knight who fights alongside her gryphon |cFFD700Silaeda|r. "
                    .. "|cFF4444The knight and gryphon must be kept separated|r — proximity causes both to deal dramatically increased damage. "
                    .. "Siroria's signature mechanic is |cFFD700Roaring Flare|r, a growing fire AoE placed on a random player.\n\n"
                    .. "|cFF4444The entire group must stack on top of the targeted player to share the Roaring Flare damage|r — "
                    .. "if the player is left alone, the explosion will one-shot them. "
                    .. "Siroria also uses |cFFD700Fire Barrage|r, sending fireballs at random players that leave burning ground patches. "
                    .. "|cFF4444Both the knight and gryphon must die at roughly the same time|r or the survivor will enrage.\n\n"
                    .. "|c00FF00Off-tank separates Silaeda from Siroria. "
                    .. "When Roaring Flare targets someone, the group must stack immediately to share the damage. "
                    .. "Focus the gryphon when grounded and the knight when the gryphon is airborne.|r",
            },
            {
                name = "Shade of Relequen",
                strategy = "The Shade of Relequen is a lightning-aspected Welkynar Knight who fights alongside his gryphon |cFFD700Belanaril|r. "
                    .. "|cFF4444The knight and gryphon must be kept separated|r — proximity dramatically increases both their damage output. "
                    .. "Relequen's signature mechanic is |cFFD700Voltaic Overload|r, which overloads the currently selected weapons of targeted players.\n\n"
                    .. "|cFFD700Voltaic Overload|r forces affected players to weapon swap or suffer heavy shock damage. "
                    .. "Relequen also fires |cFFD700Lightning Bolts|r at random targets and creates |cFFD700Static Fields|r that persist on the ground. "
                    .. "|cFF4444Both the knight and gryphon must die at roughly the same time|r or the survivor will enrage.\n\n"
                    .. "|c00FF00Off-tank keeps Belanaril away from Relequen. "
                    .. "Players hit by Voltaic Overload should weapon swap immediately to avoid the shock damage. "
                    .. "Focus the gryphon when grounded, switch to the knight when airborne, and stay out of Static Fields.|r",
            },
            {
                name = "Z'Maja",
                strategy = "Z'Maja sends players into the |cFFD700Shadow Realm|r where they must defeat enemies to return to the main arena. "
                    .. "|cFFD700Creeping Darkness|r is a spreading shadow that must be kited away from the group or it will engulf the raid. "
                    .. "Her |cFFD700Heavy Attack|r is a devastating tank buster that requires block and immediate healing. "
                    .. "|cFFD700Baneful Barb|r applies a targeted DoT on random players, and |cFFD700Shade of Gryphon|r adds must be killed quickly.\n\n"
                    .. "|cFFD700Nocturnal's Favor|r creates a shadow clone of the boss that mirrors her attacks. "
                    .. "In Hard Mode, additional mini-bosses join: Siroria with |cFFD700Roaring Flare|r fire AoE that must be kited, Relequen with |cFFD700Voltaic Overload|r lightning tethers requiring players to spread, and Galenwe with |cFFD700Ice Tombs|r that must be broken immediately. "
                    .. "|cFF4444In +3 Hard Mode all three overlap with Z'Maja simultaneously|r, making it among ESO's hardest content. "
                    .. "|c00FF00Assign specific roles: fire kiter, ice tomb freer, and a dedicated shadow realm team. "
                    .. "Communication and role clarity are essential for survival.|r",
            },
        },
    },
    ["Sunspire"] = {
        order = 8,
        bosses = {
            {
                name = "Yolnahkriin",
                strategy = "Yolnahkriin's |cFFD700Breath Attack|r is a massive frontal cone that is |cFF4444instantly lethal to anyone except a blocking tank|r, so the boss must be faced away from the group at all times. "
                    .. "|cFFD700Cataclysm|r drops targeted circles on ranged players who must spread to avoid overlapping. "
                    .. "|cFFD700Iron Swords|r are conjured weapons that chase players and must be kited and killed before they reach their target.\n\n"
                    .. "|cFFD700Wing Thrash|r punishes anyone standing behind the boss, so only position at the sides. "
                    .. "|cFFD700Shout|r creates a knockback that can push players into hazards. "
                    .. "|cFFD700Inferno|r hits the entire arena periodically, requiring burst healing from all healers. "
                    .. "|c00FF00Stay to the sides of the boss, never in front or behind. "
                    .. "Two tanks swap the breath debuff and DPS must kill Iron Swords promptly.|r",
            },
            {
                name = "Lokkestiiz",
                strategy = "Lokkestiiz unleashes |cFFD700Frost Breath|r in a massive frontal cone that must be faced away from the group at all times. "
                    .. "|cFFD700Ice Tomb|r encases a player in ice and |cFF4444must be broken IMMEDIATELY or the trapped player will die|r. "
                    .. "|cFFD700Frozen Ground|r creates persistent ice patches that slow and damage anyone standing in them.\n\n"
                    .. "Frost Atronach Adds are high priority and must be killed before they reach the group. "
                    .. "|cFFD700Lightning Storm|r sends shock bolts from the sky that must be dodged. "
                    .. "|cFFD700Glacial Winds|r pushes players back and can force them into hazards or off platforms. "
                    .. "|c00FF00Break Ice Tombs immediately as your top priority. "
                    .. "Kill Frost Atronachs fast and position the group to avoid being pushed into frozen ground by Glacial Winds.|r",
            },
            {
                name = "Nahviintaas",
                strategy = "Nahviintaas breathes |cFFD700Fire Breath|r in a devastating frontal cone that applies a stacking debuff requiring |cFF4444two tanks to swap regularly|r. "
                    .. "|cFFD700Meteor Rain|r bombards the arena constantly, forcing the group into perpetual movement. "
                    .. "|cFFD700Focus Fire|r marks a player for a lethal beam attack that |cFF4444the entire group must stack together to share the damage|r or the target will die.\n\n"
                    .. "|cFFD700Wing Thrash|r and |cFFD700Tail Swipe|r punish poor positioning around the boss. "
                    .. "During the |cFFD700Cataclysm Phase|r, fire erupts across the arena and the group must move together to safe zones. "
                    .. "Flame Atronach and Sword Adds spawn throughout and must be handled. "
                    .. "|c00FF00Hard Mode has a tighter DPS check with faster overlapping mechanics. "
                    .. "Stack for Focus Fire, move together during Cataclysm, and maintain near-flawless execution from all twelve players.|r",
            },
        },
    },
    ["Kyne's Aegis"] = {
        order = 9,
        bosses = {
            {
                name = "Yandir the Butcher",
                strategy = "Yandir's |cFFD700Cleave|r is a devastating frontal attack that will kill any non-tank, so he must be faced away from the group at all times. "
                    .. "|cFFD700Totems|r are planted throughout the fight and |cFF4444must be DESTROYED IMMEDIATELY|r as they buff enemies and debuff players simultaneously. "
                    .. "|cFFD700Bloodlust|r triggers an enrage at low health, so the group should save ultimates for the burn phase.\n\n"
                    .. "Harpy Adds swarm in periodically and must be cleaved down with AoE. "
                    .. "|cFFD700Chop|r is a heavy chain attack on the tank that must be blocked. "
                    .. "|cFFD700Ground Slam|r creates a damaging AoE around the boss. "
                    .. "|c00FF00Destroy totems as your top priority, kill harpies with AoE, and block Ground Slams. "
                    .. "Save ultimates for the Bloodlust enrage burn.|r",
            },
            {
                name = "Captain Vrol",
                strategy = "Captain Vrol drops |cFFD700Anchor Drop|r, creating large hazard zones that restrict movement across the arena. "
                    .. "|cFFD700Boarding Party|r sends waves of Sea Giants that the off-tank should chain together for efficient cleave damage. "
                    .. "|cFFD700Tidal Wave|r is a line AoE that must be dodged or it will deal massive damage and knockdown.\n\n"
                    .. "|cFFD700Harpoon Pull|r yanks a random player to the boss, potentially into hazards. "
                    .. "During |cFFD700Storm Call|r, the boss enters a lightning phase with increased arena damage. "
                    .. "In the |cFFD700Shield Phase|r, the boss becomes invulnerable and adds must be killed to remove the protection. "
                    .. "|c00FF00Avoid anchor zones, chain the Boarding Party adds together for cleave, dodge Tidal Waves, and burn adds during Shield Phase.|r",
            },
            {
                name = "Lord Falgravn",
                strategy = "Lord Falgravn uses |cFFD700Blood Fountain|r, creating a damaging AoE around himself that melee must be aware of. "
                    .. "|cFFD700Hemophilia|r is a vampiric DoT that |cFF4444spreads between players who are too close together, so the group must SPREAD|r during this mechanic. "
                    .. "|cFFD700Sanguine Prison|r imprisons players in blood orbs that |cFF4444must be broken FREE IMMEDIATELY|r or the trapped player will die.\n\n"
                    .. "During |cFFD700Bat Swarm|r the boss transforms and deals massive arena-wide AoE, requiring the group to |cFF4444stack tightly for shields and burst healing|r. "
                    .. "|cFFD700Blood Geyser|r eruptions force repositioning and |cFFD700Vampiric Drain|r channels on random players. "
                    .. "|c00FF00Hard Mode adds a Colossus add requiring an off-tank and dedicated DPS. "
                    .. "Spread for Hemophilia, free prisons immediately, and stack for Bat Swarm.|r",
            },
        },
    },
    ["Rockgrove"] = {
        order = 10,
        bosses = {
            {
                name = "Oaxiltso",
                strategy = "Oaxiltso spreads |cFFD700Noxious Sludge|r across sections of the arena, forcing the raid to constantly reposition. "
                    .. "|cFFD700Stone Throw|r targets random players and |cFFD700Savage Swipe|r is a frontal cleave that the tank must face away. "
                    .. "|cFFD700Hist Trees|r around the arena must be interacted with at specific times to prevent the boss from becoming empowered.\n\n"
                    .. "Cultist and Crocodile Adds spawn in waves, with |cFF4444cultists healing the boss if not killed quickly|r. "
                    .. "|cFFD700Petrify|r stuns a player in stone and others must free them before the effect becomes lethal. "
                    .. "|c00FF00Assign specific players to tree interaction duty. "
                    .. "Kill cultists fast to prevent boss healing, free petrified allies, and keep moving to avoid poison.|r",
            },
            {
                name = "Flame-Herald Bahsei",
                strategy = "Flame-Herald Bahsei features a |cFF4444UNIQUE resource drain mechanic|r where player abilities become increasingly expensive as resources drain, making resource management THE central challenge. "
                    .. "|cFFD700Meteor|r drops massive AoE circles that must be avoided. "
                    .. "|cFFD700Magma Prison|r traps players and must be broken free quickly. "
                    .. "|cFFD700Rising Flames|r leaves persistent fire patches across the arena.\n\n"
                    .. "|cFFD700Brimstone Hail|r hits the entire arena and requires the group to stack with shields for survival. "
                    .. "|cFFD700Volcanic Fissure|r sends lines of fire across the floor that must be dodged. "
                    .. "|c00FF00Synergies and resource-return sets are critical for this fight. "
                    .. "Healers must manage resources across the group, not just health. "
                    .. "Stack for Brimstone Hail and adapt your build to sustain through the resource drain.|r",
            },
            {
                name = "Xalvakka",
                strategy = "Xalvakka uses |cFFD700Fire Breath|r in a devastating frontal cone requiring |cFF4444two tanks to swap the stacking debuff|r regularly. "
                    .. "|cFFD700Soul Remnants|r are ghostly adds that float toward players and explode on contact, so |cFF4444they must be killed before reaching the group|r. "
                    .. "|cFFD700Flame Tsunami|r sends a wall of fire across the arena and the group must find the safe lanes to survive.\n\n"
                    .. "|cFFD700Soul Bind|r tethers two players together and they |cFF4444must move together or the tether will snap lethally|r. "
                    .. "|cFFD700Annihilation|r is an arena-wide blast at health thresholds requiring burst heals and shields from every healer. "
                    .. "|cFFD700Corrupted Stone|r adds further ground hazards to navigate. "
                    .. "|c00FF00Kill Soul Remnants as top priority, tethered players move together, and find safe lanes during Flame Tsunami. "
                    .. "Two tanks swap for Fire Breath and healers prepare for Annihilation.|r",
            },
        },
    },
    ["Dreadsail Reef"] = {
        order = 11,
        bosses = {
            {
                name = "Lylanar and Turlassil",
                strategy = "Lylanar and Turlassil are twin bosses requiring two tanks, and |cFF4444they must die close together|r or the survivor will enrage and wipe the raid. "
                    .. "|cFFD700Broadside|r fires arena-splitting cannon volleys that create deadly zones the group must avoid. "
                    .. "|cFFD700Tidal Wave|r is a sweeping AoE that hits a large portion of the arena.\n\n"
                    .. "Ghostly Crew Adds spawn in waves and must be killed before they overwhelm the group. "
                    .. "Anchor hazards litter the arena restricting safe positioning. "
                    .. "|cFFD700Chain Swipe|r is a frontal cleave from each boss that tanks must face away. "
                    .. "|c00FF00Balance DPS between both bosses to keep health percentages close. "
                    .. "Avoid broadside zones, kill ghost adds, and split the twelve-player group into two halves.|r",
            },
            {
                name = "Reef Guardian",
                strategy = "The Reef Guardian triggers |cFFD700Crushing Tide|r, flooding the arena so that |cFF4444players must reach safe platforms or drown|r in the rising water. "
                    .. "|cFFD700Crashing Wave|r is a powerful knockback that can push players off platforms into the water. "
                    .. "|cFFD700Sea Orbs|r fly toward the group and must be soaked by assigned players to prevent massive group damage.\n\n"
                    .. "|cFFD700Whirlpool|r creates persistent vortexes that pull and damage anyone nearby. "
                    .. "Coral and Atronach Adds spawn on platforms and must be dealt with while managing movement. "
                    .. "|cFFD700Tidal Surge|r adds additional wave mechanics to dodge. "
                    .. "|c00FF00Assign platforms for each flooding phase, designate orb soakers, and avoid whirlpools. "
                    .. "This is a very movement-heavy encounter requiring constant awareness.|r",
            },
            {
                name = "Bow Breaker",
                strategy = "Bow Breaker is a massive Coral Haj Mota mini-boss encountered between the main bosses. "
                    .. "|cFFD700Bog Burst|r is a burrowing charge to one of four set locations that damages and knocks back anyone in its path, "
                    .. "spawning a Coral Drift Haj Mota add and roughly ten Coral Crabs on arrival. "
                    .. "|cFFD700Horn Strike|r is a large frontal cone AoE reaching about 15 meters that must be dodged.\n\n"
                    .. "|cFF4444Poison flower stacks are the primary wipe mechanic|r — once players reach five stacks, the damage becomes nearly unsurvivable even with healing. "
                    .. "Players must avoid the poison AoEs on the ground and keep their stacks low. "
                    .. "|c00FF00Tank faces the boss away from the group, and everyone stacks on the tail. "
                    .. "Off-tanks taunt all adds and bring them to the group for cleave. "
                    .. "Avoid poison flowers at all costs to prevent stack buildup.|r",
            },
            {
                name = "Sail Ripper",
                strategy = "Sail Ripper is a flying mini-boss that uses lightning-based mechanics. "
                    .. "|cFFD700Storm Cell|r places a lightning AoE on a random player that persists until they deposit it into one of the hollow circular 'donut' areas around the arena. "
                    .. "|cFF4444The targeted player must quickly move to a donut to cleanse the Storm Cell|r or the group takes escalating shock damage.\n\n"
                    .. "Sail Ripper periodically flies around the arena, and upon landing begins channeling a |cFFD700Lightning Attack|r. "
                    .. "|cFF4444This channel must be interrupted IMMEDIATELY|r before it deals devastating damage to the entire group. "
                    .. "|c00FF00Assign donut positions for Storm Cell deposits. "
                    .. "When the boss lands after flight, the closest player must interrupt the Lightning Attack channel as fast as possible.|r",
            },
            {
                name = "Tideborn Taleria",
                strategy = "Fleet Queen Taleria transforms into |cFFD700Tideborn Taleria|r, a massive coral monstrosity, for the final encounter of Dreadsail Reef. "
                    .. "|cFFD700Water Orbs|r are placed on DPS players and |cFF4444must be cleansed by walking into the water at the back of the arena|r before they explode. "
                    .. "The tank must manage heavy sustained damage including a stacking DoT that makes this one of the most demanding tank checks in the game.\n\n"
                    .. "|cFFD700Tornadoes|r complete two full rotations of the arena and |cFF4444must be avoided entirely|r — contact is nearly always lethal. "
                    .. "|cFFD700Broadside Bombardment|r covers the arena, forcing the group to find safe zones. "
                    .. "Spectral Crew Waves spawn ghost pirates that must be cleaved down, and |cFFD700Captain's Command|r buffs all remaining adds. "
                    .. "|c00FF00Cleanse water orbs immediately, dodge tornadoes, kill adds before Captain's Command fires, and healers must keep the tank alive through extreme sustained pressure.|r",
            },
        },
    },
    ["Sanity's Edge"] = {
        order = 12,
        bosses = {
            {
                name = "Spiral Descender",
                strategy = "The Spiral Descender is a massive spectral red scorpion that serves as a mini-boss encountered twice during trash pulls — once before the first boss and again before the second boss. "
                    .. "|cFFD700Frightening Grasp|r pulls everyone nearby, |cFF4444instantly draining 75% of all players' total Health|r and applying a heavy snare. "
                    .. "After the pull, a growing AoE appears around the boss that deals increasing damage and eventually explodes in |cFFD700Unbound Horror|r.\n\n"
                    .. "|cFFD700Ruin|r has two phases: first a rapid frontal cone AoE, then a burst of AoEs fired in all directions. "
                    .. "|cFFD700Lacerate|r and |cFFD700Raze|r are powerful single-target attacks aimed at the tank. "
                    .. "The Spiral Descender also summons |cFFD700Spiral Shalks|r as additional enemies during the fight.\n\n"
                    .. "|c00FF00When Frightening Grasp begins, healers must immediately burst heal the group back from 25% health. "
                    .. "Move out of the expanding AoE before Unbound Horror detonates. "
                    .. "Kill summoned Shalks quickly and avoid standing in the frontal cone during Ruin.|r",
            },
            {
                name = "Exarchanic Yaseyla",
                strategy = "Exarchanic Yaseyla is the leader of the Contramagis Militia, a fierce warrior wielding dual swords with knives, bombs, and chains at her disposal. "
                    .. "|cFFD700Chain Pull|r grabs three random targets, causing bleeding and dragging them toward her — players can break free but take damage either way. "
                    .. "|cFFD700Knife Blast|r releases a storm of blades at the group, dealing heavy damage in a wide arc.\n\n"
                    .. "At |cFF444460% and 35% health, Yaseyla summons Horrors|r — when this happens, |cFF4444stop damaging the boss immediately|r and deal with all remaining enemies first. "
                    .. "|cFFD700Wamasu|r are elite melee enemies that charge at random players, dealing massive damage and knockback to anyone in their path. "
                    .. "Contra Mage Archers also spawn at health thresholds and must be managed.\n\n"
                    .. "|c00FF00Face the boss away from the group to avoid cleave damage. "
                    .. "Stop DPS on the boss at 60% and 35% to handle Horror and Wamasu spawns. "
                    .. "Dodge sideways when targeted by a Wamasu charge and burn adds before returning to the boss.|r",
            },
            {
                name = "Archwizard Twelvane",
                strategy = "Archwizard Twelvane is a powerful mage who fights with fire, ice, and lightning magic in the first phase before transforming into the Chimera. "
                    .. "|cFFD700Core Skating Field|r summons two slow-moving AoEs that target random players and ramp up damage quickly — |cFF4444these must be kited away from the group|r or the stacking damage will kill everyone. "
                    .. "|cFFD700Blizzard|r creates icy waves that damage and slow players caught in them.\n\n"
                    .. "|cFFD700Circle of Immolation|r is a fiery ring around the boss that damages anyone nearby, forcing melee to reposition. "
                    .. "Twelvane also uses |cFFD700Lightning Bolts|r targeting random players and |cFFD700Frost Cage|r to root players in place. "
                    .. "At low health she begins her transformation into the Chimera.\n\n"
                    .. "|c00FF00Kite Core Skating Field AoEs away from the group immediately. "
                    .. "Melee must watch for Circle of Immolation and step out when it activates. "
                    .. "Avoid Blizzard waves and prepare for the transition into the Chimera phase.|r",
            },
            {
                name = "Chimera",
                strategy = "The Chimera is the transformed second phase of the Archwizard Twelvane encounter, a massive three-headed beast cycling through |cFFD700Triple Aspect|r of fire, ice, and shock. "
                    .. "Each element requires different positioning strategies from the raid. "
                    .. "|cFFD700Elemental Breath|r is a frontal cone matching the current element that the tank must face away from the group. "
                    .. "|cFFD700Convergence|r combines all three elements simultaneously for |cFF4444MAXIMUM damage requiring every shield and heal available|r.\n\n"
                    .. "|cFFD700Elemental Orbs|r must be soaked by players with the matching elemental debuff. "
                    .. "|cFFD700Beast Charge|r targets a random player and must be dodge rolled. "
                    .. "Each head has distinct attacks: Bite, Chomp, Peck, Quick Strike, and Stab, with |cFFD700Maul|r as the heavy attack. "
                    .. "Elemental Adds spawn during transitions between aspects and must be handled quickly.\n\n"
                    .. "|c00FF00Track which element is active and adjust positioning accordingly. "
                    .. "Soak matching orbs, shield for Convergence, and dodge Beast Charges. "
                    .. "The Gryphon, Lion, and Wamasu plaques in the corners indicate the current active head.|r",
            },
            {
                name = "Ansuul the Tormentor",
                strategy = "Ansuul uses |cFFD700Mind Prison|r to trap individual players, and |cFF4444EACH player must solve their own mechanic independently|r, making personal competence essential. "
                    .. "During |cFFD700Realm of Madness|r, the entire group is transported to a nightmare dimension and must follow a specific path to escape. "
                    .. "At |cFF444480%, 60%, and 40% health|r, a maze spawns that players must navigate, with a portal at the end requiring a tank and three DPS to enter and defeat a boss inside.\n\n"
                    .. "|cFFD700Shattering Scream|r sends arena-wide pulses that must be healed through. "
                    .. "|cFFD700Chains of Madness|r tethers players who must move apart to break free. "
                    .. "The |cFFD700Morphing Arena|r physically changes throughout the fight, requiring constant repositioning as platforms shift. "
                    .. "|cFFD700Nightmare Manifestations|r are adds that embody different fears and must be handled with specific strategies.\n\n"
                    .. "|c00FF00Hard Mode overlaps nightmare phases making it significantly more chaotic. "
                    .. "All twelve players must be individually mechanically competent for Mind Prison, as no one can carry another through it. "
                    .. "Assign a tank and three DPS for each maze portal phase.|r",
            },
        },
    },
    ["Lucent Citadel"] = {
        order = 13,
        bosses = {
            {
                name = "Cavot Agnan",
                strategy = "Cavot Agnan is a powerful necromancer and the first mini-boss of Lucent Citadel. "
                    .. "|cFFD700Radiance|r creates a glowing aura around the boss that |cFF4444makes Cavot Agnan and all enemies inside it IMMUNE to damage|r. "
                    .. "Players touching the aura take rapidly ramping damage, and while Radiance is active, |cFFD700Sunburst|r circles are launched in all directions continuously.\n\n"
                    .. "|cFFD700Smite|r is a heavy attack with a critical mechanic: the tank |cFF4444must BLOCK this attack, never dodge roll it|r. "
                    .. "If the tank dodge rolls Smite, every other player in the group must also dodge roll or be one-shot. "
                    .. "|cFFD700Bleakquake|r slams the staff on the ground, launching damaging circles across the arena.\n\n"
                    .. "|c00FF00Block Smite every time — never dodge it. "
                    .. "Stay outside the Radiance aura and wait for it to fade before DPSing. "
                    .. "Avoid Bleakquake circles and kill skeletal minion adds as they spawn.|r",
            },
            {
                name = "Count Ryelaz and Zilyesset",
                strategy = "Count Ryelaz and Zilyesset are a dual boss encounter where the room is divided by a transparent wall, with three pads on each side for swapping between bosses. "
                    .. "Count Ryelaz uses |cFFD700Shear|r, a heavy attack followed by |cFFD700Gloomy Impact|r meteors that players must spread to manage the staggered strikes. "
                    .. "Zilyesset uses |cFFD700Sting|r, |cFFD700Twin Jab|r, and a three-hit heavy combo (|cFFD700Heavy Slash|r, |cFFD700Heavy Smash|r, |cFFD700Heavy Strike|r).\n\n"
                    .. "The core mechanic is the |cFFD700Mirror Pad|r swap: every 60 seconds (and at 80% and 35% in Hard Mode), Count Ryelaz casts a mirror mechanic. "
                    .. "|cFF4444Players must look through the center mirror to see which pad is lit, then stand on the symmetrical pad on their side|r. "
                    .. "Standing on the correct pad teleports you to the other side with moderate frost damage; the wrong pad is an instant kill.\n\n"
                    .. "|c00FF00Split the group evenly between both sides with a tank and healer each. "
                    .. "Learn the mirror pad positions and react quickly during swap phases. "
                    .. "Spread for Gloomy Impact meteors and block Zilyesset's heavy combo.|r",
            },
            {
                name = "Dariel Lemonds",
                strategy = "Dariel Lemonds spawns after the second defense prism is destroyed and serves as a mini-boss between the main encounters. "
                    .. "His signature mechanic is |cFFD700Arcane Conveyance|r, a tether that connects the two players furthest from the boss. "
                    .. "|cFF4444Anyone who touches this tether will be INSTANTLY KILLED|r — there is no surviving contact with it.\n\n"
                    .. "The tethered players must be aware of their positioning and ensure no one crosses their connection line. "
                    .. "Dariel also uses standard melee attacks and summons adds periodically.\n\n"
                    .. "|c00FF00The two furthest players should position themselves carefully so the tether does not cross through the group. "
                    .. "All other players must stay aware of the tether position and never walk through it. "
                    .. "Stack tightly near the boss to minimize tether interference.|r",
            },
            {
                name = "Orphic Shattered Shard",
                strategy = "The Orphic Shattered Shard is a crystalline boss surrounded by |cFFD700Crystal Hollow Sentinels|r and |cFFD700Crystal Atronachs|r. "
                    .. "Four glowing yellow mirrors are placed around the room, and triggering a synergy on any mirror |cFF4444inflicts a potent bleed on the activating player|r. "
                    .. "The mirrors are central to the fight's mechanic and must be activated at the right times.\n\n"
                    .. "The boss fires |cFFD700Prismatic Beam|r, a devastating attack that |cFF4444MUST be shared by the group stacking together|r or it will kill the targeted player. "
                    .. "|cFFD700Crystal Adds|r reflect certain damage types, so |cFF4444do NOT attack crystals that are reflecting your damage type|r or you will kill yourself. "
                    .. "|cFFD700Radiant Burst|r hits the entire arena with light damage requiring sustained healing.\n\n"
                    .. "|c00FF00Coordinate mirror activations and be prepared for the bleed DoT. "
                    .. "Share Prismatic Beam by stacking, never attack reflective crystals, and kill sentinel adds promptly.|r",
            },
            {
                name = "Baron Rize",
                strategy = "Baron Rize is encountered in the Mirror of Opposition area and serves as a mini-boss between the main encounters. "
                    .. "The fight revolves around |cFFD700Mirror Mechanics|r where players must use the reflective surfaces in the room to deal with the boss's abilities. "
                    .. "|cFFD700Shadow Duplicate|r creates mirror copies of the boss that must be identified and dealt with correctly.\n\n"
                    .. "Baron Rize uses |cFFD700Dark Slash|r, a heavy cleave attack that the tank must face away from the group. "
                    .. "|cFFD700Mirrored Strike|r targets multiple players simultaneously from different angles. "
                    .. "|c00FF00Pay attention to the mirror mechanics and identify the real boss from the duplicates. "
                    .. "Tank faces the boss away from the group and kill adds quickly when they spawn.|r",
            },
            {
                name = "Jresazzel and Xynizata",
                strategy = "Jresazzel and Xynizata are a dual mini-boss encounter in the Faceted Gallery area of Lucent Citadel. "
                    .. "|cFF4444Both bosses must be managed simultaneously|r as they buff each other if one dies too far ahead of the other. "
                    .. "Each boss uses distinct elemental attacks that create overlapping hazard zones across the gallery.\n\n"
                    .. "|cFFD700Faceted Beam|r fires prismatic projectiles that split into multiple colors on impact, creating colored ground zones. "
                    .. "|cFFD700Gallery Shatter|r breaks sections of the crystalline floor, reducing safe standing areas. "
                    .. "Adds spawn from the gallery walls and must be cleaved down before they overwhelm the group.\n\n"
                    .. "|c00FF00Split DPS between both bosses to keep their health balanced. "
                    .. "Each tank takes one boss and keeps them separated. "
                    .. "Avoid colored ground zones and manage the shrinking safe space as Gallery Shatter progresses.|r",
            },
            {
                name = "Xoryn",
                strategy = "Xoryn alternates between |cFFD700Luminous and Shadow Phases|r, requiring the raid to swap strategies mid-fight as the boss shifts between light and dark aspects. "
                    .. "|cFFD700Prismatic Annihilation|r requires a |cFF4444SPECIFIC group formation or it will wipe the entire raid|r, demanding precise positioning from all twelve players. "
                    .. "|cFFD700Echo Mechanics|r bring back abilities from previous bosses, layering old mechanics on top of new ones.\n\n"
                    .. "|cFFD700Light/Dark Tethers|r connect players who must match polarity to avoid taking lethal damage. "
                    .. "The |cFFD700Arena Transformation|r causes platforms to appear and disappear, fundamentally changing the battlefield during combat. "
                    .. "|cFFD700Beacon Mechanic|r requires activating beacons in the correct order with precise timing or the group suffers massive damage.\n\n"
                    .. "|c00FF00Hard Mode adds additional echoes and tighter beacon timing. "
                    .. "This is one of ESO's most mechanically demanding encounters, requiring players to track multiple systems simultaneously. "
                    .. "Match tether polarity, navigate shifting platforms, and execute beacon activations with precise coordination.|r",
            },
        },
    },

    ["Ossein Cage"] = {
        order = 14,
        bosses = {
            {
                name = "Shapers of Flesh",
                strategy = "The Shapers of Flesh are six Voriplasm-like masses that serve as the first main boss encounter of Ossein Cage. "
                    .. "The fight revolves around |cFFD700Carrion Portals|r — group members must synergize on the portal pad to travel to another platform and defeat enemies there. "
                    .. "|cFF4444Players taking a portal are afflicted with Caustic Carrion|r, a damage-over-time effect that increases in severity with each stack.\n\n"
                    .. "|cFFD700Fleshspawn Adds|r must be managed carefully — |cFF4444if left alive, they merge into a Flesh Abomination|r, "
                    .. "a far more dangerous enemy that can overwhelm the group. "
                    .. "A channeler on the portal platform must be taunted and brought down, and it drops |cFFD700Buff Orbs|r that reset your Caustic Carrion stacks. "
                    .. "One tank and three DPS are needed for each portal rotation.\n\n"
                    .. "|c00FF00Establish a clear portal rotation so Caustic Carrion stacks do not become lethal. "
                    .. "Kill Fleshspawn immediately before they merge into Abominations. "
                    .. "Collect buff orbs from the channeler to reset your stacks. "
                    .. "DPS should stack on one side of the Shaper for efficient cleave damage.|r",
            },
            {
                name = "Red Witch Gedna Relvel",
                strategy = "Red Witch Gedna Relvel is a powerful lich found in the |cFFD700Inscrutable Lichyard|r, accessible through the first Dreadful Portal as an optional boss. "
                    .. "She commands an army of undead minions and uses devastating necromantic magic. "
                    .. "|cFFD700Necrotic Blast|r fires dark projectiles that apply stacking disease damage to their targets.\n\n"
                    .. "|cFFD700Summon Undead|r raises waves of skeletal warriors and mages that must be killed before they overwhelm the group. "
                    .. "|cFFD700Lich Crystal|r creates protective shields that must be destroyed before the boss can be damaged. "
                    .. "|cFF4444The Caustic Carrion passive effect from the portal continues to deal increasing damage|r during this fight, creating a soft enrage timer.\n\n"
                    .. "|c00FF00Burn the Lich Crystals quickly to remove her shield. "
                    .. "Cleave the undead adds while maintaining pressure on the boss. "
                    .. "Be mindful of your Caustic Carrion stacks from the portal — this fight has a built-in time pressure.|r",
            },
            {
                name = "Tortured Trio",
                strategy = "The Tortured Trio — |cFFD700Tortured Amkaos|r, |cFFD700Tortured Kathutet|r, and |cFFD700Tortured Ranyu|r — are an optional boss encounter "
                    .. "found in the |cFFD700Gaol of Transition|r, accessible through a Dreadful Portal. "
                    .. "All three bosses are active simultaneously and |cFF4444must be managed together|r as they buff each other when separated too far.\n\n"
                    .. "Each member of the Trio uses distinct combat styles: Amkaos favors heavy melee strikes, "
                    .. "Kathutet uses fire-based ranged attacks, and Ranyu employs crowd control abilities. "
                    .. "|cFFD700Tortured Rage|r triggers when any one of the trio drops below a health threshold, increasing the damage of all three.\n\n"
                    .. "|c00FF00Keep all three bosses relatively close for cleave damage but use tanks to face them away from the group. "
                    .. "Balance DPS across all three to avoid triggering Tortured Rage prematurely. "
                    .. "Focus down the most dangerous one first if the group cannot sustain triple boss pressure.|r",
            },
            {
                name = "Jynorah and Skorkhif",
                strategy = "Jynorah and Skorkhif are a dual boss encounter combining fire and frost elements. "
                    .. "|cFFD700Portal Management|r remains critical — establish a clear player rotation for Carrion Portals to prevent Caustic Carrion stacks from becoming lethal. "
                    .. "Tank positioning is key to |cFF4444separate the bosses and manage their overlapping cleave attacks|r.\n\n"
                    .. "|cFFD700Agonizer Bomb|r is placed on a random player and |cFF4444the targeted player must immediately move away from the group|r before it detonates. "
                    .. "During the |cFFD700Titanic Clash|r phase, both bosses become empowered with dramatically increased damage, and players must be aware of their debuffs and position accordingly. "
                    .. "Champion adds |cFFD700Sparkstorm Myrinax|r and |cFFD700Blazeforged Valneer|r spawn during the fight and must be prioritized.\n\n"
                    .. "|c00FF00Two tanks each take one boss and keep them separated. "
                    .. "Isolate yourself immediately when targeted by Agonizer Bomb. "
                    .. "Kill champion adds quickly and maintain the portal rotation for Caustic Carrion management. "
                    .. "Strong single-target and cleave DPS are both needed.|r",
            },
            {
                name = "Blood Drinker Thisa",
                strategy = "Blood Drinker Thisa is an optional boss found in the |cFFD700Sitient Lair|r, accessible through a Dreadful Portal. "
                    .. "She is a vampiric enemy who drains the life force of players to heal herself. "
                    .. "|cFFD700Sanguine Drain|r channels on a random player, |cFF4444healing the boss for a massive amount unless the channel is interrupted|r.\n\n"
                    .. "|cFFD700Blood Pool|r creates persistent ground hazards that heal the boss when she stands in them, so the tank must pull her away. "
                    .. "|cFFD700Vampiric Swarm|r summons bat adds that latch onto players and drain their resources. "
                    .. "The Caustic Carrion debuff from the portal adds additional time pressure to this encounter.\n\n"
                    .. "|c00FF00Interrupt Sanguine Drain immediately every time it is cast. "
                    .. "Tank must keep the boss out of Blood Pools to prevent healing. "
                    .. "Kill bat swarm adds quickly to prevent resource drain and burn the boss before Caustic Carrion stacks become overwhelming.|r",
            },
            {
                name = "Overfiend Kazpian",
                strategy = "Overfiend Kazpian is a Ruinach and the keeper of the Dolorous Cista, serving as the final boss of Ossein Cage. "
                    .. "|cFFD700Agonizer Bomb|r returns from the Jynorah fight — |cFF4444the targeted player must isolate from the group immediately|r and no one else should be caught in the explosion. "
                    .. "After |cFFD700Frenzy|r, a |cFF4444tank swap is required|r as the current tank receives a devastating debuff.\n\n"
                    .. "|cFFD700Torturous Chains|r tethers players together — tethered players must move apart to break free or take escalating damage. "
                    .. "During the fight, players are sent to a |cFFD700Side Island|r — every member of the group must visit the side island at least once. "
                    .. "Kazpian summons |cFFD700Molag Kena|r and |cFFD700Low Warden Dusk|r as familiar foes that add to the chaos of the encounter.\n\n"
                    .. "|c00FF00Clear communication is essential: call out Agonizer Bombs and side island assignments via voice chat. "
                    .. "Both tanks must be ready for the Frenzy swap mechanic. "
                    .. "Break Torturous Chains tethers quickly by moving apart. "
                    .. "Manage the summoned familiar foes while maintaining DPS on Kazpian.|r",
            },
        },
    },

}, -- end trials

} -- end ds.Data
