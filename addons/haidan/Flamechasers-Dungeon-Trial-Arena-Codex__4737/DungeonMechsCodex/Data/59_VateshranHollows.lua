-- Vateshran Hollows: complete Veteran main and secret-boss dataset.

local DMC = DungeonMechsCodex
local S, B, M = DMC.ArenaSummary, DMC.ArenaBoss, DMC.ArenaMechanic

DMC.RegisterArena({
    id = "vateshran_hollows",
    name = "Vateshran Hollows",
    aliases = {"VH", "vVH", "Veteran Vateshran Hollows"},
    dlc = "Markarth",
    status = "complete",
    zoneIds = {1227},
    capabilities = {
        difficulties = {"vet"},
        roles = {"all", "quick"},
    },
    source = {
        verifiedDate = "2026-09-03",
        primary = "UESP Vateshran Hollows encounter and achievement records",
        secondary = "Alcast, Xynode, and ESO-Hub Veteran Vateshran guides",
        notes = "All seven main and three optional secret bosses are included. This is solo content with no separately activated Hard Mode.",
    },
    summary = S("Four-area solo arena with three selectable wings and a final arena. Wing order changes enemy health and determines which cross-wing secret bosses are reachable. Collect Essences and Remnants for permanent run buffs, unlock Grapple, Wounding Portal, and Brimstone traversal, then manage every wing mechanic together against Maebroogha."),
    bosses = {
        B("shade_grove", "Shade of the Grove", {"Green 1"},
            "Attack only the active lurcher; all three share health. Interrupt Blessed Spriggans before they steal Blessing of the Grove, kill one if the buff is lost, and control wolves as more lurchers wake during execute.", {
                M("Possessed Lurchers", {"TARGET", "!"}, "The spirit moves between three lurchers that share one health bar. Damage only the awake, vulnerable body; later, several may move while only one remains damageable.", "Hit only the active vulnerable lurcher."),
                M("Blessing Theft", {"INT", "!"}, "A Blessed Spriggan channels a blue tether to steal Blessing of the Grove. Interrupt immediately; without the blessing, kill a Spriggan to regain it before attacking the boss.", "Interrupt the blue tether; kill a Spriggan if the buff is stolen."),
                M("Dire Wolves", {"ADD"}, "Pairs of wolves enter repeatedly. Cleave them down before the next pair arrives so their pressure does not hide the active lurcher's attacks.", "Kill each wolf pair before the next spawns."),
            }),
        B("leptfire_keeper", "Leptfire Keeper", {"Green Secret"},
            "Use Grapple to chase the Keeper across the six platforms, step back from its fire spin and cone, and avoid persistent flame. Favor direct and single-target damage because the boss relocates too quickly for long ground effects.", {
                M("Platform Leap / Grapple", {"GRAPPLE", "!"}, "The Keeper frequently jumps to another platform. Grapple after it promptly and orient before attacking so the immediate cone cannot knock you off rhythm.", "Grapple after every platform leap."),
                M("Fire Scream", {"MOVE", "BLOCK"}, "The Keeper often greets a landing with a frontal fire scream and stagger. Land off its facing, sidestep, or block rather than beginning a channel immediately.", "Avoid or block the landing fire cone."),
                M("Fire Spin / Ground Flame", {"MOVE"}, "Step back from the close fire spin and leave the lingering flame patches. Keep the next grapple line unobstructed.", "Back out of the spin and avoid lingering fire."),
            }),
        B("rahdgarak", "Rahdgarak", {"Green Final"},
            "Block or dodge Clobber and grapple after Rahdgarak's jumps. Below 80%, fight him on a platform opposite his current color. Interrupt at least one channeler on a red and one on a blue platform so both safe colors remain available.", {
                M("Clobber / Charge", {"BLOCK", "DODGE", "!"}, "Clobber can kill through a missed defense; block, dodge, or use Grapple to evade it. Break free quickly if the charge connects.", "Block, dodge, or grapple away from Clobber."),
                M("Color Invulnerability", {"POSITION", "!"}, "When Rahdgarak gains a red or blue aura, grapple to a platform of the opposite color to damage him. Be ready to move each time his color changes.", "Fight on the platform opposite Rahdgarak's color."),
                M("Reach Channelers", {"INT", "PRIORITY"}, "Channelers begin disabling platforms. Interrupt at least one on each color so a red and blue destination survive; kill extras while preserving movement.", "Interrupt one red-side and one blue-side channeler."),
            }),
        B("zakuryn_abomination", "Zakuryn & Flesh Abomination", {"Blue 1"},
            "Interrupt Zakuryn's Daedric Swell, dodge the Abomination's unblockable Pulverize, and use that slam to break Zakuryn's shield. Balance their health and kill them together because an early survivor heals and enrages.", {
                M("Daedric Swell", {"INT", "!"}, "Zakuryn raises his staff and channels incoming skulls. Interrupt the cast immediately while keeping sight of the Abomination's slam.", "Interrupt Daedric Swell."),
                M("Pulverize", {"MOVE", "ONE-SHOT", "!"}, "The Abomination's glowing slam cannot be safely blocked. Leave its area; when Zakuryn shields, position the slam over him to remove the immunity.", "Dodge Pulverize; aim it at shielded Zakuryn."),
                M("Paired Kill / Enrage", {"BALANCE", "!"}, "If either boss dies far ahead, the survivor heals for a large amount and enrages. Balance both health bars and finish them close together.", "Balance both bosses and finish together."),
                M("Banekin Portal", {"ADD"}, "Zakuryn opens a portal that releases Banekin. Cleave them for sustain and let Pulverize kill them when convenient without missing the shield setup.", "Cleave Banekin while setting up Pulverize."),
            }),
        B("xobutar", "Xobutar of His Deep Graces", {"Blue Secret"},
            "Ignore the endlessly respawning Mimic and survive until the Wounding Portal activates. Enter for a 20-second damage window on Xobutar, avoid his AOEs, and destroy vampiric totems before they heal him.", {
                M("Mimic / Waiting Room", {"KITE"}, "The Mimic respawns and does not advance the encounter. Kite it, avoid unnecessary damage, and wait for the portal instead of spending resources trying to finish it.", "Kite the Mimic; wait for the portal."),
                M("Wounding Portal Window", {"PORTAL", "BURN", "!"}, "Use the active portal to reach Xobutar and deal damage for roughly 20 seconds before returning. Reapply short effects each visit rather than committing long cooldowns at the end.", "Enter the portal and burst Xobutar during each window."),
                M("Vampiric Totems", {"ADD", "PRIORITY"}, "Destroy vampiric totems as soon as they appear or they restore Xobutar. Move from his ground AOEs while maintaining damage.", "Kill vampiric totems before they heal Xobutar."),
            }),
        B("iozuzzuneth", "Iozuzzuneth", {"Blue Final"},
            "Avoid the Titan's heavy claw and fast coldfire wave, kill Sentinels before their gaze debuffs take over, and handle Watchers and Wounding Portal enemies without losing safe positioning around the center.", {
                M("Claw / Coldfire Wave", {"DODGE", "MOVE", "!"}, "The heavy claw is dangerous at melee and the fast coldfire wave travels across the floor. Dodge the claw and sidestep the wave rather than outrunning it late.", "Dodge the claw and sidestep coldfire."),
                M("Sentinel Gaze", {"ADD", "PRIORITY"}, "Sentinels apply vulnerability, damage loss, health drain, or slow while they see you. Break line of sight or use the boss's coldfire to damage them, then finish them quickly.", "Break Sentinel gaze and kill the eye."),
                M("Watchers / Portals", {"ADD", "MOVE"}, "Watchers and portal pressure create crossing beams and ground hazards. Kill the active threat, keep the Titan centered in view, and preserve an escape lane for coldfire.", "Kill Watchers and keep a lane open for coldfire."),
            }),
        B("magma_queen", "Magma Queen", {"Red 1"},
            "Kill Iron Atronachs, pick up their Flaming Rocks, and throw them at active lava geysers. Clearing all geysers stuns the Queen and her adds. Cleave scamps, kill the portal's eventual Daedroth, and step through fire-wall gaps below 45%.", {
                M("Iron Atronach / Flaming Rock", {"ADD", "SYNERGY", "!"}, "Kill the Iron Atronach, take its Flaming Rock synergy, and throw the rock at an active geyser. Do not waste the projectile on ordinary adds.", "Kill the Iron Atronach; throw its rock at a geyser."),
                M("Lava Geysers", {"OBJECT", "BURN"}, "Each boss relocation opens another geyser. Remove them with Flaming Rocks; clearing every active geyser stuns all enemies for a strong damage window.", "Close every geyser to stun the arena."),
                M("Scamp Portal / Daedroth", {"ADD", "PRIORITY"}, "Cleave the portal's scamps before they accumulate. When the portal closes and releases a Daedroth, kill it while continuing the geyser cycle.", "Cleave scamps; kill the portal Daedroth."),
                M("Flame Walls", {"MOVE"}, "Below roughly 45%, paired fire walls cross the platform. Step through a clear gap and avoid being pinned against a geyser or lava edge.", "Use the gaps in the crossing flame walls."),
            }),
        B("mynar_metron", "Mynar Metron", {"Red Secret"},
            "Fight the Iron Atronach around the small island, leave its varied fire AOEs, and reposition when it moves around the edge. Use Brimstone Fortification to step into lava temporarily if the platform becomes too crowded.", {
                M("Fire AOEs", {"MOVE"}, "Mynar layers circles, lines, and other fire telegraphs over limited floor space. Move only far enough to clear each hit so later AOEs remain manageable.", "Step out of each fire telegraph."),
                M("Edge Reposition", {"POSITION"}, "The boss relocates around the island's edge. Follow with direct damage and recast ground effects only after it settles.", "Follow Mynar's edge movement before recasting AOEs."),
                M("Brimstone Fortification", {"RESOURCE", "MOVE"}, "If safe floor disappears, heavy attack the Brimstone Orb and use its shield to enter lava briefly. Return before the protection expires.", "Use Brimstone shield for emergency lava space."),
            }),
        B("pyrelord", "The Pyrelord", {"Red Final"},
            "Avoid fire breath and the rotating flame beams. When lava covers the platform, take Brimstone Fortification and absorb the newly ignited corner; letting all three corners burn triggers Fire Storm and empowers the boss. Kill the first Fire Colossus before the second threshold.", {
                M("Fire Breath / Flame Spin", {"MOVE", "!"}, "Sidestep the breath and rotate between the three flame beams during the spin. Stay outside the damaging bubble around the boss.", "Sidestep breath and rotate between flame beams."),
                M("Lava / Burning Corners", {"OBJECT", "!"}, "When lava spreads, heavy attack the available Brimstone Orb, then step on the newly burning corner to absorb its fire. Repeat before all three corners ignite.", "Take Brimstone and absorb each burning corner."),
                M("Fire Storm", {"HEAL", "ENRAGE"}, "If all three corners remain lit, the Pyrelord becomes invulnerable during a room-wide fire barrage and emerges empowered. Survive defensively, then prevent the next trigger by clearing corners.", "If Fire Storm triggers, survive it and clear future corners."),
                M("Fire Colossi", {"ADD", "PRIORITY"}, "Colossi enter around 70% and 35%. Stack the first near the boss and kill it before the second; during execute, decide whether to burn Pyrelord instead of chasing the late add.", "Kill the first Colossus before the second; burn late if safe."),
            }),
        B("maebroogha", "Maebroogha the Void Lich", {"Final"},
            "Break the closing shade chain by killing one shade, control Shade Colossi and adds, and escape Void Eruption through an unused portal at each 10% phase end. Clear all three portal champions quickly to limit Maebroogha's healing, then survive the combined mechanics in the fourth phase.", {
                M("Shade Chain", {"ADD", "PRIORITY", "ONE-SHOT", "!"}, "A ring of shades closes inward behind a lethal chain. Focus one shade and kill it within the timer to create an opening; never dodge through the chain.", "Kill one shade quickly and escape through its gap."),
                M("Shade Colossi", {"ADD", "PRIORITY"}, "Bound Colossi can wake from stray damage and Maebroogha periodically calls another. Keep area effects off dormant shades and kill the active Colossus before several overlap.", "Avoid waking bound Colossi; kill the active one."),
                M("Void Eruption / Grapple", {"PORTAL", "ONE-SHOT", "!"}, "At the end of each main phase, the expanding Void Eruption is lethal. Grapple to an unused outer island and activate its portal before the blast fills the arena.", "Grapple out and take an unused portal before eruption."),
                M("Portal Champions", {"PRIORITY", "BURN"}, "Kill the champion inside each colored portal quickly while Maebroogha heals. Interrupt Flameshapers and handle the wing-specific hazards without extending the phase.", "Burst each portal champion; interrupt Flameshapers."),
                M("Final Combined Phase", {"BURN", "HEAL"}, "After all three portals, lightning, fire, adds, chains, and Colossi can overlap. Keep a chain exit available, maintain self-healing, and commit damage without ignoring priority adds.", "Final phase combines every hazard; keep healing and chain exits ready."),
            }),
    },
})

