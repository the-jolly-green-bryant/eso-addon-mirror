-- Maelstrom Arena: complete Veteran stage dataset.

local DMC = DungeonMechsCodex
local S, B, M = DMC.ArenaSummary, DMC.ArenaBoss, DMC.ArenaMechanic

DMC.RegisterArena({
    id = "maelstrom_arena",
    name = "Maelstrom Arena",
    aliases = {"MA", "MSA", "vMA", "vMSA", "Veteran Maelstrom Arena"},
    dlc = "Orsinium",
    status = "complete",
    zoneIds = {677},
    capabilities = {
        difficulties = {"vet"},
        roles = {"all", "quick"},
    },
    source = {
        verifiedDate = "2026-09-03",
        primary = "UESP Maelstrom Arena stages and official ESO arena information",
        secondary = "Alcast, Xynode, and ArzyeL Veteran Maelstrom guides",
        notes = "All nine Veteran stages are included. This is solo content with no separately activated Hard Mode.",
    },
    summary = S("Nine-stage solo arena. Survival depends on spawn knowledge and priority targets more than raw damage. Use arena sigils when needed, bring a reliable self-heal, interrupt ranged threats, and solve each stage's environmental mechanic before committing to boss damage."),
    bosses = {
        B("maxus_many", "Maxus the Many", {"Stage 1"},
            "Keep moving out of dark ground effects, break the pentagram root, and kill Maxus's copies before they merge back and restore him. Control adds rather than letting the easy opening stage become crowded.", {
                M("Dark Ground / Whirlwind", {"MOVE"}, "Leave black ground effects and keep distance from the snaring whirlwind. Preserve a clear route instead of circling through fresh hazards.", "Leave dark ground and keep moving."),
                M("Pentagram Root", {"BREAK", "MOVE"}, "Break free from the pentagram root promptly and move out before another attack lands. Keep stamina available for the control effect.", "Break the pentagram root immediately."),
                M("Illusions / Merge", {"ADD", "PRIORITY", "!"}, "Maxus creates copies that move back toward him. Kill each illusion before it reaches the boss or it restores health and extends the fight.", "Kill illusions before they merge into Maxus."),
            }),
        B("centurion_champion", "Centurion Champion", {"Stage 2"},
            "Avoid the moving blade traps and do not let their stacking bleed build. Use the levers to stop the blades if pressured, move out of lightning and steam, and kill the centurions cleanly rather than fighting in trap lanes.", {
                M("Spinning Blades", {"MOVE", "BLEED", "!"}, "The rotating blades apply a stacking bleed that persists after contact. Move with safe lanes and never roll along a blade's path.", "Avoid blades; their bleed stacks."),
                M("Control Levers", {"SYNERGY", "POSITION"}, "Levers at the arena edge temporarily halt the blades. Use one proactively when boss pressure and traps overlap, then reposition before they restart.", "Use a lever when blade pressure becomes unsafe."),
                M("Lightning / Steam", {"MOVE"}, "Centurion shock fields and steam attacks punish standing still. Fight in a clear quadrant and relocate early when a trap or ground effect enters it.", "Leave shock and steam telegraphs."),
                M("Centurion Sequence", {"PRIORITY", "BLOCK"}, "Each construct has heavy attacks and its own elemental pressure. Block telegraphed hits, finish the active target, and avoid carrying damage into the next activation.", "Block heavies and finish each centurion cleanly."),
            }),
        B("lamia_queen", "Lamia Queen", {"Stage 3"},
            "Stay out of electrified water, use dry islands and healing pools carefully, and kill priority adds before the arena fills. Interrupt or block the Lamia's scream and avoid strangler pulls while handling her threshold waves.", {
                M("Electrified Water", {"POSITION", "!"}, "Water becomes lethal when electrified. Fight on dry ground and cross only when the hazard is inactive or absolutely necessary.", "Stay on dry ground during electrification."),
                M("Lamia Scream", {"INT", "BLOCK"}, "Interrupt the Lamia's dangerous scream when possible; otherwise block and heal through it. Do not take it while stranded in electrified water.", "Interrupt or block the scream."),
                M("Stranglers / Adds", {"ADD", "PRIORITY"}, "Kill ranged and control adds before another wave arrives. Avoid strangler pull lines and use area damage to keep threshold waves from accumulating.", "Kill priority adds and avoid strangler pulls."),
                M("Healing Pools", {"RESOURCE"}, "Green pools restore health but should be used deliberately. Save a nearby pool for a dangerous overlap instead of consuming every one immediately.", "Reserve healing pools for dangerous overlaps."),
            }),
        B("control_guardian", "Control Guardian", {"Stage 4"},
            "Destroy sentries and remain under the Guardian's green safety field during its lightning phase. Move away during the fire phase, avoid spinning machinery, and maintain damage because add pressure grows as the fight continues.", {
                M("Lightning Phase / Safe Field", {"STACK", "!"}, "When lightning fills the arena, stay beneath the green field projected by the Guardian. Follow it closely without standing in the boss's body or machinery.", "Stay under the green field during lightning."),
                M("Fire Phase", {"MOVE"}, "The Guardian becomes a close-range fire hazard. Move away until the phase ends, then close back in before the next lightning shelter check.", "Move away during the fire phase."),
                M("Clockwork Sentries", {"ADD", "PRIORITY"}, "Sentries add shielding and ranged pressure. Kill them promptly, especially before a phase transition, so their attacks do not force you out of the safe field.", "Kill sentries before they crowd the shelter."),
                M("Time Pressure", {"BURN"}, "The encounter adds more enemies over time. Keep steady boss damage while meeting mechanics; excessive kiting eventually makes the arena harder.", "Maintain damage; add pressure scales with time."),
            }),
        B("matriarch_runa", "Matriarch Runa", {"Stage 5"},
            "Never stand in the freezing water. Interrupt trolls before they smash an island, kill Runa's add waves, and move to the next intact platform when she begins breaking the current one. On the final island, commit to the burn before it collapses.", {
                M("Freezing Water", {"POSITION", "!"}, "The water deals extreme escalating cold damage. Cross quickly only between islands and never fight from it.", "Stay out of the freezing water."),
                M("Troll Island Smash", {"ADD", "INT", "!"}, "Trolls run to an island and channel its destruction. Interrupt and kill each immediately; losing spare islands removes your safety margin for the boss phases.", "Interrupt and kill island-smashing trolls."),
                M("Platform Break", {"MOVE", "!"}, "Runa destroys platforms at major health thresholds. Stop attacking if needed, identify the next intact island, then cross before the break completes.", "Move to an intact island when Runa breaks yours."),
                M("Final-Island Burn", {"BURN", "HEAL"}, "Once only one island remains, its destruction is on a timer. Use sigils, ultimates, healing, and execute damage to finish Runa before the floor is lost.", "On the last island, commit every resource to the burn."),
            }),
        B("champion_atrocity", "Champion of Atrocity", {"Stage 6"},
            "Unweb the five obelisks with hoarvors or venom grenades, kill every Webspinner before it rewebs them, and use a glowing pillar to survive the spider swarm. Unwebbing all five stuns the boss and clears its enrage.", {
                M("Webbed Obelisks", {"OBJECT", "!"}, "Lure a hoarvor to an obelisk and kill it there, or use the venom grenade it drops, to remove the web. Work toward five clear pillars while maintaining safe space.", "Kill hoarvors by pillars or throw venom to unweb them."),
                M("Webspinners", {"ADD", "PRIORITY", "!"}, "Webspinners rush toward cleared obelisks and cover them again. Kill or interrupt them before any progress is lost.", "Kill Webspinners before they reweb pillars."),
                M("Spider Swarm / Golden Pillar", {"POSITION", "!"}, "When the swarm fills the arena, one cleared obelisk glows gold. Stand beside that pillar until the swarm passes.", "Use the glowing golden pillar during the swarm."),
                M("Five-Pillar Stun", {"BURN"}, "Clearing all five obelisks stuns the Champion and removes its growing pressure. Use the window for burst damage, then rebuild the mechanic if necessary.", "Clear all five pillars to stun and burn the boss."),
            }),
        B("argonian_behemoth", "Argonian Behemoth", {"Stage 7"},
            "Kill every Venomcaller before it detonates poison flowers, cleanse volatile poison at a pool, and handle the Minder phase correctly: kill one Minder, leave the other alive, and stand inside its shield during the Behemoth's scream.", {
                M("Poison Flowers / Cleanse", {"MOVE", "CLEANSE", "!"}, "Triggered flowers apply volatile poison. Reach one of the cleansing pools immediately; each use consumes that pool, so avoid unnecessary detonations.", "If poisoned, cleanse immediately at a pool."),
                M("Venomcallers", {"ADD", "PRIORITY", "!"}, "Venomcallers appear around the edge and trigger poison plants across the arena. Kill them before continuing boss damage.", "Kill every Venomcaller immediately."),
                M("Argonian Minders", {"ADD", "POSITION", "!"}, "Two Minders arrive before the boss's scream. Kill one, leave the other alive, and stand inside the surviving Minder's protective field until the scream ends.", "Kill one Minder; shelter with the surviving Minder."),
                M("Behemoth Scream", {"BLOCK", "HEAL"}, "The scream is lethal outside the Minder's shield. Remain inside the protective field, block if needed, and resume damage only after the channel fully ends.", "Stay in the Minder shield through the scream."),
            }),
        B("valkyn_tephra", "Valkyn Tephra", {"Stage 8"},
            "Destroy all three warding stones to stun Tephra, then use the opening for boss damage. Kill flame casters, avoid lava and fire waves, and repeat the stone cycle before add pressure overwhelms the arena.", {
                M("Warding Stones", {"OBJECT", "PRIORITY", "!"}, "Destroy the three warding stones around the arena. The third break stuns Tephra and creates the main safe damage window.", "Break all three stones to stun Tephra."),
                M("Flame Casters", {"ADD", "INT"}, "Fire mages spawn repeatedly and add dangerous ranged pressure. Interrupt and kill them while rotating between warding stones.", "Interrupt and kill flame casters."),
                M("Lava / Fire Waves", {"MOVE"}, "Leave lava patches and cross fire waves through clear gaps. Avoid cornering yourself while moving to the next stone.", "Move through fire gaps and stay out of lava."),
                M("Stun Window", {"BURN"}, "When all stones break, Tephra is vulnerable and disabled briefly. Drop ultimates and burst damage, then prepare to repeat the full cycle.", "Burst Tephra during the three-stone stun."),
            }),
        B("voriak_solkyn", "Voriak Solkyn", {"Stage 9", "Final"},
            "Block or dodge Voriak's skull and interrupt Necrotic Swarm. At the upper platform, destroy all three crystals while using the moving wall against the blast. Below, stop summoners, collect three golden ghosts for Spectral Explosion, and control Crematorial Guards.", {
                M("Skull / Necrotic Swarm", {"BLOCK", "INT", "!"}, "Block or dodge the thrown skull and interrupt Necrotic Swarm immediately. A missed interrupt usually overlaps adds or forces excessive healing.", "Block the skull; interrupt Necrotic Swarm."),
                M("Clannfear Portal", {"ADD", "POSITION"}, "After the knockdown, kill the summoned clannfear on the glowing plate to open the portal to the upper platform. Do not waste time fighting it away from the plate.", "Kill the clannfear on the glowing plate."),
                M("Upper Crystals / Moving Wall", {"OBJECT", "MOVE", "!"}, "Destroy all three crystals while Soul Churn ramps. When the arena blast begins, stay behind the moving defensive wall; never cross through it at the last moment.", "Break three crystals and hide behind the moving wall."),
                M("Golden Ghosts / Spectral Explosion", {"COLLECT", "SYNERGY", "!"}, "Collect three golden ghosts before enemies reach them to gain Spectral Explosion. Use it to stun Voriak and dangerous adds, then execute the priority target.", "Collect three gold ghosts and use Spectral Explosion."),
                M("Summoners / Crematorial Guards", {"ADD", "PRIORITY"}, "Kill summoners before they complete a Bone Colossus. Circle close around Crematorial Guards to avoid their sweeping fire breath and burn them before another joins.", "Kill summoners; circle and burn Crematorial Guards."),
            }),
    },
})

