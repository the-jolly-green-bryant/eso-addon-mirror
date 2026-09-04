-- Blackrose Prison: complete Veteran stage dataset.

local DMC = DungeonMechsCodex
local S, B, M = DMC.ArenaSummary, DMC.ArenaBoss, DMC.ArenaMechanic
local GROUP = {"tank", "healer", "dps"}
local ALL = {"all", "tank", "healer", "dps"}

DMC.RegisterArena({
    id = "blackrose_prison_arena",
    name = "Blackrose Prison",
    aliases = {"BRP", "vBRP", "Veteran Blackrose Prison"},
    dlc = "Murkmire",
    status = "complete",
    zoneIds = {1082},
    capabilities = {
        difficulties = {"vet"},
        roles = {"all", "quick", "tank", "healer", "dps"},
    },
    source = {
        verifiedDate = "2026-09-03",
        primary = "UESP Blackrose Prison stages and official achievement conditions",
        secondary = "Alcast, Xynode, and ESO community Veteran Blackrose guides",
        notes = "All five Veteran stages are included. Blackrose has no separately activated Hard Mode.",
    },
    summary = S("Five-stage four-player gauntlet. Waves matter as much as bosses: chain enemies into safe cleave, interrupt Infusers and dangerous casters, use sigils deliberately, and prioritize arena-specific threats before damage overlaps. The fourth stage reprises the first three bosses; Drakeeh closes the arena with a coordinated spirit phase."),
    bosses = {
        B("battlemage_ennodius", "Battlemage Ennodius", {"Stage 1"},
            "Spread targeted meteors, use their impacts to stun flame atronachs when safe, and keep moving with the rotating Flame Spouts. Interrupt fire casts, control atronachs, and avoid overlapping meteor circles on the group.", {
                M("Meteor", {"SPREAD", "BLOCK", "!"}, "Targeted players separate and block the meteor impact. Its impact can stun flame atronachs, but never drag the circle through teammates to force the setup.", "Spread and block meteors; stun atronachs when safe.", ALL),
                M("Flame Spouts", {"MOVE", "!"}, "Lines of fire sweep or rotate across the arena. Read their direction early and move with the safe gap instead of crossing multiple flames at once.", "Move with the Flame Spout gap.", ALL),
                M("Flame Atronachs", {"ADD", "PRIORITY"}, "The tank groups flame atronachs without aiming their pressure at the party. Stun them with a meteor when convenient, then burn them before another wave compounds the fire damage.", "Group and kill flame atronachs.", GROUP),
            }),
        B("tames_the_beast", "Tames-the-Beast", {"Stage 2"},
            "Stack Bug Swarm with teammates to split its damage, interrupt Snipe, and avoid Crushing Roots. Control the Troll, Wamasu, and Haj Mota threshold adds in sequence, keeping every large frontal away from the group.", {
                M("Bug Swarm", {"STACK", "HEAL", "!"}, "The marked player takes severe insect damage that is divided among nearby allies. Form a small stack around the target and sustain healing until the swarm ends.", "Stack on Bug Swarm to split its damage.", ALL),
                M("Crushing Roots / Snipe", {"DODGE", "INT"}, "Dodge the root telegraph before it traps a player and interrupt Snipe. Free a rooted ally immediately if the avoidance fails.", "Dodge Crushing Roots and interrupt Snipe.", ALL),
                M("Troll / Wamasu / Haj Mota", {"ADD", "PRIORITY"}, "Large beasts enter at boss thresholds. Kill one before forcing the next, keep Wamasu lightning and Haj Mota charges faced away, and interrupt the Troll.", "Control health; kill each large beast before the next.", GROUP),
            }),
        B("lady_minara", "Lady Minara", {"Stage 3"},
            "Kill skeletal adds before they transform into Bone Colossi, keep Minara and elite adds controlled, and leave blood and shadow ground effects. Interrupt Infusers and priority casters before focusing the boss.", {
                M("Skeletal Transformation", {"ADD", "PRIORITY", "!"}, "Skeletal enemies can transform into Bone Colossi if left alive. Stack and burn them immediately; do not allow several colossi to accumulate.", "Kill skeletons before they become Bone Colossi.", ALL),
                M("Bone Colossus", {"ADD", "BLOCK"}, "If a Colossus forms, the tank turns it away and blocks its heavy attacks while DPS kills it. Avoid pushing Minara through more add triggers until control is restored.", "Tank and burn any Bone Colossus immediately.", GROUP),
                M("Infusers / Bloodfiends", {"ADD", "INT"}, "Infusers and other support enemies are priority targets. Interrupt their channels and pull them into cleave before resuming boss damage.", "Interrupt and kill Infusers first.", GROUP),
                M("Blood and Shadow AOEs", {"MOVE"}, "Minara layers persistent ground damage around the arena. Keep a stable fighting pocket and reposition as a group so the healer and tank are not isolated.", "Move the group out of persistent AOEs.", ALL),
            }),
        B("hall_of_misery", "The Three Champions", {"Stage 4"},
            "The first three champions return with their supporting hazards. Focus Ennodius, then control Tames-the-Beast's Wamasu and Haj Mota thresholds, then finish Minara. Avoid pushing the active boss into the next overlap before the previous target and priority adds are dead.", {
                M("Staggered Boss Spawns", {"PRIORITY", "!"}, "Ennodius enters first; Tames-the-Beast and then Minara join as health thresholds are crossed. Stop damage when necessary so the previous boss and its priority add die before another champion overlaps.", "Do not overpush; finish each champion before the next overlap.", ALL),
                M("Ennodius / Flame Pressure", {"MOVE", "ADD"}, "Focus Ennodius while avoiding Flame Spouts, meteors, and atronachs. Kill her quickly, but keep meteor circles separated and the arena safe.", "Kill Ennodius first while avoiding flame mechanics.", GROUP),
                M("Tames / Beast Thresholds", {"ADD", "PRIORITY"}, "After Ennodius, kill the Wamasu, then damage Tames deliberately. Avoid forcing the Haj Mota while another boss or large beast is still active.", "Kill Wamasu; control Tames before spawning Haj Mota.", GROUP),
                M("Minara / Skeletons", {"ADD", "INT"}, "Taunt Minara when she enters but finish the planned target. Kill skeletons before they transform and interrupt Infusers while keeping boss frontals separated.", "Control Minara; kill skeletons and Infusers.", GROUP),
            }),
        B("drakeeh_unchained", "Drakeeh the Unchained", {"Stage 5", "Final"},
            "Keep Drakeeh faced away, prioritize totems and rocks, and coordinate Spirit Ignition: three non-tanks claim separate pads, absorb a safe number of yellow spirits, then cleanse. Reduce remaining spirits before Spirit Scream, interrupt magic attacks, and control proxy shades during execute.", {
                M("Spirit Ignition / Pads", {"ASSIGN", "POSITION", "!"}, "Three assigned non-tanks take separate pads. Each absorbs nearby yellow spirits without exceeding a safe load, then returns to and cleanses at the matching pad before the phase ends.", "Three players take pads, absorb spirits, then cleanse.", ALL),
                M("Spirit Scream", {"HEAL", "BLOCK", "!"}, "Unabsorbed spirits empower Drakeeh's Spirit Scream. Finish cleanses, block the blast, and layer healing and mitigation according to how many spirits remain.", "Cleanse, then block and heal Spirit Scream.", ALL),
                M("Totems / Falling Rocks", {"ADD", "PRIORITY"}, "Destroy active totems immediately. Use solid terrain and movement to avoid rock pressure while the tank holds Drakeeh steady and away from pad assignments.", "Kill totems first and use cover from rocks.", GROUP),
                M("Magic Bomb / Proxy Shades", {"INT", "ADD"}, "Interrupt Drakeeh's dangerous magic channel. Proxy shades join later; group and burn them without allowing their attacks to overlap Spirit Ignition positions.", "Interrupt magic bomb; stack and kill proxy shades.", GROUP),
                M("Dragon Leap / Frontal", {"BLOCK", "MOVE"}, "Block the heavy frontal and move out of the narrow leap line. The tank immediately re-establishes facing after Drakeeh relocates.", "Block frontal attacks and leave the leap line.", GROUP),
            }),
    },
})

