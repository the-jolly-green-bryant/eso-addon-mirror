-- Dragonstar Arena: complete Veteran stage dataset.

local DMC = DungeonMechsCodex
local S, B, M = DMC.ArenaSummary, DMC.ArenaBoss, DMC.ArenaMechanic
local GROUP = {"tank", "healer", "dps"}
local ALL = {"all", "tank", "healer", "dps"}

DMC.RegisterArena({
    id = "dragonstar_arena",
    name = "Dragonstar Arena",
    aliases = {"DSA", "vDSA", "Veteran Dragonstar Arena"},
    dlc = "Craglorn",
    status = "complete",
    zoneIds = {635},
    capabilities = {
        difficulties = {"vet"},
        roles = {"all", "quick", "tank", "healer", "dps"},
    },
    source = {
        verifiedDate = "2026-09-03",
        primary = "UESP Dragonstar Arena stage and achievement records",
        secondary = "Xynode and Alcast Veteran Dragonstar Arena guides",
        notes = "All ten Veteran stages are included. Dragonstar has no separately activated Hard Mode.",
    },
    summary = S("Ten-stage four-player arena. Each stage ends with a named boss and keeps its wave hazards active. Preserve resources, kill priority casters and environmental threats before they snowball, and save defensive ultimates for the later overlap-heavy stages."),
    bosses = {
        B("champion_marculd", "Champion Marculd", {"Stage 1"},
            "Face Marculd away, block his heavy attacks, leave Dawnbreaker and frontal damage, and pull Fighters Guild adds into controlled cleave. Move him out of Circle of Protection so he cannot benefit from it.", {
                M("Dawnbreaker / Frontal Cleave", {"MOVE", "BLOCK"}, "Marculd's wide frontal attacks punish anyone standing with the tank. Keep him faced away and step behind him whenever he turns.", "Stay behind Marculd; block or leave his frontal cone.", ALL),
                M("Circle of Protection", {"MOVE", "!"}, "Marculd places a protective circle that improves his position. The tank moves him clear immediately while the group keeps damage and healing outside it.", "Pull Marculd out of Circle of Protection.", GROUP),
                M("Gladiator Adds", {"ADD"}, "Adds enter at health thresholds. Stack them behind Marculd for cleave, interrupt dangerous casts, and do not let archers pressure the healer.", "Stack and cleave the threshold adds.", GROUP),
            }),
        B("yavni_katti", "Yavni Frost-Skin & Katti Ice-Turner", {"Stage 2"},
            "Keep a bonfire lit to prevent lethal cold, stack both bosses when possible, and focus Katti first. Interrupt Ice Root, avoid Ice Wall and storms, and control threshold adds without abandoning the fire.", {
                M("Bonfires / Freezing", {"POSITION", "!"}, "At least one bonfire must remain burning. Fight around a lit fire and rotate deliberately if it goes out; lingering in the cold rapidly becomes lethal.", "Stay near a lit bonfire; rotate before the cold stacks.", ALL),
                M("Ice Root / Ice Wall", {"INT", "MOVE"}, "Interrupt Katti's rooting channel and move out of Ice Wall and frost storms. A rooted player in overlapping frost damage needs immediate support.", "Interrupt Ice Root and leave Ice Wall.", ALL),
                M("Boss Focus / Adds", {"ADD", "PRIORITY"}, "Focus Katti while the tank keeps Yavni controlled. Stack the bosses when safe and kill adds that arrive around the midpoint and execute.", "Focus Katti; stack and cleave the adds.", GROUP),
            }),
        B("naktah_shilia", "Nak'tah & Shilia", {"Stage 3"},
            "Keep the fight in the clear part of the arena, avoid poison and strangler pulls, and prepare for the Wamasu late in the fight. Interrupt Shilia's Cripple and respect Nak'tah's lightning cone and ground effects.", {
                M("Poison Field / Stranglers", {"MOVE", "!"}, "Poison progressively denies the arena while stranglers pull players out of position. Keep a clean fighting pocket, kill obstructive stranglers, and do not chase through poison.", "Hold the clear pocket; avoid poison and strangler pulls.", ALL),
                M("Cripple / Lightning", {"INT", "MOVE"}, "Interrupt Shilia's Cripple channel. Move from Nak'tah's lightning cone, streak path, and Liquid Lightning instead of stacking multiple effects.", "Interrupt Cripple; leave lightning telegraphs.", ALL),
                M("Wamasu", {"ADD", "PRIORITY"}, "A Wamasu joins late. The tank collects it facing away and the group burns it or finishes the bosses according to damage, without standing in its frontal lightning.", "Control the late Wamasu and avoid its frontal.", GROUP),
            }),
        B("earthen_heart_knight", "Earthen Heart Knight", {"Stage 4"},
            "Send Enslaver beams safely to the arena edge, kill the Enslavers, and avoid the spinning shadows they release. Interrupt or move from fire and earth casts while the tank keeps the Knight and adds stacked away from the group.", {
                M("Enslaver Beam", {"ADD", "POSITION", "!"}, "Dremora Enslavers tether players with beams. Carry each beam toward the edge, kill its caster, and leave space for the shadow that appears when the tether ends.", "Take Enslaver beams outward, then kill the caster.", ALL),
                M("Spinning Shadows", {"MOVE"}, "Released shadows spin through the arena and are not priority kill targets. Track their routes and sidestep instead of dragging the boss through them.", "Do not chase shadows; avoid their spin paths.", ALL),
                M("Knight and Threshold Adds", {"ADD", "INT"}, "Adds arrive in later health bands. Stack controllable targets, interrupt dangerous earth/fire channels, and keep frontal attacks away from the group.", "Stack adds and interrupt dangerous casts.", GROUP),
            }),
        B("anala_tuwha", "Anal'a Tu'wha", {"Stage 5"},
            "Kill every Shadowcaster before its sacrifice completes; if one succeeds, each player must use a cleansing plate. Control gargoyles and pyromancers, block the boss's heavy attacks, and leave Standard and flame breath.", {
                M("Shadowcasters / Sacrifice", {"ADD", "PRIORITY", "!"}, "Shadowcasters channel a group curse. Focus and interrupt or kill each immediately; if a cast completes, every player must cleanse on an available plate.", "Kill Shadowcasters immediately; cleanse individually if one succeeds.", ALL),
                M("Cleansing Plates", {"POSITION"}, "A completed curse follows each player until that player steps on a cleansing plate. Call used plates and cleanse promptly without crossing the boss's frontal.", "Use a free plate if personally cursed.", ALL),
                M("Gargoyles / Fire Adds", {"ADD", "MOVE"}, "The tank controls gargoyles while DPS kills pyromancers and other ranged threats. Leave fire breath and Standard ground damage before returning to the stack.", "Control gargoyles; kill fire adds and leave Standard.", GROUP),
            }),
        B("pishna_longshot", "Pishna Longshot", {"Stage 6"},
            "Hold a loose formation, dodge Draining Shot so it cannot empty resources, and avoid Arrow Spray. Stack threshold adds for cleave and leave the green stamina-drain circles immediately.", {
                M("Draining Shot", {"DODGE", "RESOURCE", "!"}, "Pishna telegraphs a punishing shot that drains resources if it lands. Dodge the projectile rather than trying to heal through the sustain loss.", "Dodge Draining Shot; it drains resources.", ALL),
                M("Arrow Spray / Spread", {"SPREAD", "MOVE"}, "Her cone and targeted pressure reward a loose triangle around the boss. Do not overlap players or stand in the frontal Arrow Spray.", "Loose spread; leave Arrow Spray.", ALL),
                M("Adds / Stamina Circles", {"ADD", "MOVE"}, "Adds enter around major health thresholds and green circles drain stamina while dealing damage. Stack adds, move out of circles, and protect block resources.", "Stack threshold adds and leave green circles.", GROUP),
            }),
        B("dark_mage_shadow_knight", "Dark Mage & Shadow Knight", {"Stage 7"},
            "Stop every sacrifice before it reaches a shrine, interrupt the Dark Mage's dangerous casts, and keep both bosses controlled. Avoid Nova and ground damage while killing add waves before the next sacrifice window.", {
                M("Sacrifices", {"ADD", "PRIORITY", "!"}, "Sacrificial enemies run toward shrines at the start and through multiple boss-health thresholds. Mark their paths and kill them before any reaches its destination.", "Kill every sacrifice before it reaches a shrine.", ALL),
                M("Dark Mage Channels", {"INT", "!"}, "Interrupt Negate, crystal, magic-bomb, and burst channels immediately. Assign ranged backup interrupts while sacrifices or adds pull melee away.", "Interrupt the Dark Mage's highlighted casts.", ALL),
                M("Shadow Knight / Add Waves", {"ADD", "BLOCK", "MOVE"}, "Block the Shadow Knight's heavy attack, leave Nova and persistent damage, and stack add waves without turning boss frontals into the group.", "Block the Knight; leave Nova and clear adds.", GROUP),
            }),
        B("mavus_talnarith", "Mavus Talnarith", {"Stage 8"},
            "Spread for meteors, block their impact, then move out. Interrupt Fire Trail, avoid Volcanic Rune, and handle the paired centurions: interrupt their blue channel or pair the marked fire and ice players to cancel it.", {
                M("Meteor / Volcanic Rune", {"SPREAD", "BLOCK", "MOVE"}, "Targeted meteors require separation and a block, followed by movement out of the impact area. Watch for Volcanic Rune beneath players during repositioning.", "Spread, block meteor, then move out.", ALL),
                M("Fire Trail", {"INT", "MOVE", "!"}, "Interrupt Mavus when he begins Fire Trail. If it starts, keep moving out of the flame path and do not drag it through the stack.", "Interrupt Fire Trail or kite it away.", ALL),
                M("Centurion Pair / Element Marks", {"ADD", "INT", "PAIR"}, "Centurions arrive in two waves. Interrupt the blue channel; when players receive fire and ice marks, meet safely to cancel them before the elemental damage ramps.", "Interrupt centurions; pair fire and ice marks.", GROUP),
            }),
        B("vampire_lord_thisa", "Vampire Lord Thisa", {"Stage 9"},
            "Keep Thisa taunted and faced away, move out of Bat Swarm because it heals him, and handle his heavy, Standard, mist, and armor effects. Use the pits to send assigned damage dealers below and unlock Jonnicent adds.", {
                M("Bat Swarm", {"MOVE", "HEAL", "!"}, "Thisa's Bat Swarm damages nearby players and restores his health. Move the boss and group out immediately rather than feeding the heal.", "Leave Bat Swarm; it heals Thisa.", ALL),
                M("Jonnicent / Lower Realm", {"PORTAL", "ADD", "!"}, "Jonnicent enemies upstairs are protected. Assigned damage dealers enter the pits, kill their linked spirits below, and return so the group can finish the now-vulnerable adds.", "Assigned DPS kill linked spirits below to unlock Jonnicents.", ALL),
                M("Heavy / Standard / Mist", {"BLOCK", "MOVE"}, "Block the heavy attack and move from Standard. Track Thisa through mist form, re-establish facing, and avoid stacking extra damage into Bat Swarm.", "Block heavy; leave Standard and reacquire after mist.", GROUP),
            }),
        B("hiath_battlemaster", "Hiath the Battlemaster", {"Stage 10", "Final"},
            "Drop flame circles around the arena edge, kill the resulting atronachs, and keep Hiath faced away. Break free from Soul Shred, interrupt Cripple, block his pull explosion near 50% and 25%, and control the three entourage waves without standing in Circle of Protection.", {
                M("Flame Circle / Atronach", {"POSITION", "ADD", "!"}, "Each player periodically drops a flame circle that spawns an atronach. Place circles around the outer edge, then stack and kill the adds before the next overlap.", "Drop flame circles at the edge; kill atronachs.", ALL),
                M("Soul Shred / Cripple", {"BREAK", "INT"}, "Break free promptly from Soul Shred and interrupt Cripple. Preserve stamina so control effects do not overlap the boss's threshold attacks.", "Break Soul Shred; interrupt Cripple.", ALL),
                M("Pull Explosion", {"BLOCK", "!"}, "Around the major midfight thresholds Hiath pulls the group inward and detonates. Block through the blast, then leave any ground effects before resuming position.", "Block the pull-and-detonate thresholds.", ALL),
                M("Entourage / Circle of Protection", {"ADD", "MOVE"}, "Entourage waves arrive around 75%, 50%, and 25%. The tank gathers them, DPS kills priority targets, and Hiath is moved out of protective circles.", "Stack entourage waves and pull Hiath out of protection.", GROUP),
            }),
    },
})

