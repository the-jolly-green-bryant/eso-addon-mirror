-- Veteran (non-Hard-Mode) dataset overlay.
--
-- The original dungeon modules remain the authoritative Hard Mode dataset.
-- This file classifies every dungeon, boss, and mechanic for Veteran mode,
-- supplies Veteran summaries for all dungeons, and overrides or suppresses
-- mechanics whose behavior changes when a Hard Mode banner/tome is activated.

local DMC = DungeonMechsCodex

local dungeonSummaries = {
    imperial_city_prison = [[6 required encounters. Core checks: Ibomez prisoners and atronachs, Gravelight knockbacks, Flesh Abomination poison, Council ghosts, and Lord Warden portal timing. Save portals for Darklight Burst, block meteors, body-block Shadow Barrage, and control shades.]],
    white_gold_tower = [[6 required encounters. Core checks: Adjudicator cages and flame waves, Elite Guard banners and heals, Scion interrupts, Planar Inhibitor pinion and portals, and Molag Kena's Aspects, lightning wall, atronachs, knockbacks, and shield phases.]],
    cradle_of_shadows = [[5 required encounters. Manage light and braziers, interrupt Khephidaen, control Votary burst and feeding, free Dranos pins, and prepare torches before Velidreth's catacomb splits. Obey Shadow Sense, avoid spores, and interrupt Gout of Bile during revives.]],
    ruins_of_mazzatun = [[4 required bosses. Prioritize Stone Shapers, steer Chudan's Bog Rush, coordinate Xal-Nur's Swamp Spice and geysers, and kill Na-Kesh's Siphoning Totems. Use the normal Reveal help for hallucinations and guide the cursed player to the correct statue.]],
    bloodroot_forge = [[6 bosses. Face bosses away, interrupt chains and channels, kill Stranglers, Fire Shalks, and Stone Atronachs, respect Molten Nirncrux, and manage Earthgore clones and lava. The Stonefire Crucible and Flameslake Cauldron remain available as recovery tools.]],
    falkreath_hold = [[5 bosses. Avoid siege fire, block Mammoth Stomp and comets, handle Cernunnon's soul phase, cleanse Deathlord corpses, and agree on a Domihaus pillar rotation. Hide together for Grovel, kill atronachs and adds, and keep Domihaus taunted.]],
    fang_lair = [[5 boss encounters. Prioritize Menagerie adds, interrupt lethal grabs, control Caluurion relics, and rescue Sabina's chained target. At Thurvokun, place poison safely, interrupt Orryn, destroy Animus Crystals, control Colossi and shalks, and use Life Ward barriers for ghost walls.]],
    scalecaller_peak = [[5 boss encounters. Freeze for Tremor, use pillars for Vicious Shard, free petrified players, plug Mortieu's geysers, and interrupt dangerous channels. At Zaan, intercept Fire Cage, dodge Fire Waves and statue cones, kill the two frost adds at thresholds, then shelter in Spellbreaker for the poison wave.]],
    march_of_sacrifices = [[5 boss encounters. Separate dangerous auras, kill priority adds, dodge Dagrund's Upheaval, and survive Tarcyr's stealth hunt. At Balorgh, manage island poison, electrified water, Fire Remnant, charges, frontals, and the single-shadow hunts at 80/60/40/20%.]],
    moon_hunter_keep = [[5 boss encounters. Avoid overburning health thresholds into overlapping add waves. Learn blood geysers, Stranglers, Shock Wardens, werewolf control, and Symbols of Xarxes before Vykosa; pace damage, kill each add wave, interrupt Pounce, and keep the restrained wolves controlled.]],
    frostvault = [[5 boss encounters. Laser positioning, spread discipline, interrupts, and add priority become critical from Vault Protector onward. At Stonekeeper, destroy the arms and Centurions in order, rotate through flame lanes, use the simpler Veteran skeevaton route at 50%, and control Arquebuses and late adds.]],
    depths_of_malatar = [[5 encounters. Learn the color system: yellow healing pressure, red Sunburst meteors, blue ice, and purple lightning. At Symphony of Blades, block stuns, avoid the blade spin, interrupt sword throws, kill a ghost for wall gaps, stop Aurorans, and stay spread in the colored rooms.]],
    moongrave_fane = [[5 boss encounters. Use Sangiin Sacrifice to create a Hemo Helot, heavy-attack blood orbs, and push Sliding Stones with attacks. At Grundwulf, keep him faced away, strip Hemonculi protections with the Hemo Helot orb, handle shackles, and move the stone only for Dying Breath.]],
    lair_of_maarselok = [[5 boss encounters. Interrupt dangerous channels, control adds and Stranglers, place Lurchers carefully, and complete objectives cleanly. At Maarselok, free Selene from Wicked Bonds, cleanse the selected Azureblight host at the indicated ward, avoid breath and blaze, kill adds, and control charges.]],
    icereach = [[5 boss encounters. Earlier fights teach giant enrage control, Flame Swirl and frozen Stranglers, undead beams, and lightning movement. At Mother Ciannait, rotate through the four sisters, interrupt Storm Surge, then stack and burn during Sundered Sky.]],
    unhallowed_grave = [[5 main bosses plus 3 optional secrets. Use the grapple bow for traversal and combat, solve Keeper sigils, and react quickly to Ondagore hide phases. At Kjalnar, face him away, avoid hands and runes, kill Imbued Skeletons, and handle Tzirzhalir after Awakening.]],
    stone_garden = [[3 main bosses plus optional alchemy rooms. Exarch is an interrupt and block check, Stone Behemoth is add and resource-drain management, and Arkasis cycles fire, poison, werewolf-behemoth husks, then lightning and pin mechanics. Optional alchemy buffs can make the run safer.]],
    castle_thorn = [[5 bosses. Control adds and positioning through the keep. At Lady Thorn, stay close enough to manage charges, enter the moving safe light during bat phases, kill Blood Scavengers, use their synergies to end the phase, and remain inside the moving light during execute.]],
    the_cauldron = [[5 required encounters. Avoid Oxblood poison and globs, escape Viccia traps and pulls, interrupt the Molten Guardian, prioritize Lyranth's prison adds, and keep Zaudrus faced away. Use Cold-Flame Infusion on pillars and rocks, and move with the single Ash Vent wall.]],
    red_petal_bastion = [[3 main bosses plus 3 optional secret bosses. Secrets grant Crystal Animus buffs. Kill Rogerain's portals and adds, use the goat form intelligently, control Artifact Bearer traps and both lieutenants, and prioritize Prior Thierric's Realmshapers, Relic Fiends, and impale interrupt.]],
    the_dread_cellar = [[3 main bosses plus 3 secret bosses. Secret Accession buffs and Guardian Stones can assist. Prioritize Scorion adds and Agonymium Stones, dodge Cyronin's Dread Surge and Soulstorm while killing Boltwyrms and atronachs, then manage Magma portals, fire paths, tornado walls, and Scorions.]],
    coral_aerie = [[3 main bosses plus 3 covenant guardians and optional Z'Baza. Covenant bosses grant strong buffs. Handle Maligalig Storm Cell and platform Ripples, Sarydil mines and add interrupts, then Varallion Sea Orbs, waves, tethers, gryphons, trap pools, and Kargaeda.]],
    shipwrights_regret = [[3 main bosses plus 3 tormented-spirit secrets. Spirit buffs help throughout the run. Pair correctly for Bradiggan Soul Bombs, create safe space by killing Nazaray's Kindred, and control Numirril's corpses, bile pools, crossing waves, and single-Hulk threshold phases.]],
    earthen_root_enclave = [[3 main bosses plus 3 optional elemental bosses whose orbs grant run buffs. Hide for Corruption of Stone slams and control Atronachs, kill Corruption of Root Fauns and Distributaries, then manage Devyric's totems, lightning pillars, three-wolf waves, bear breath, and charges.]],
    graven_deep = [[3 main bosses plus 3 Dwemer secrets. Close Gatekeeper burrows with poison, stop Varzunon's skeletal sacrifices, and avoid line slams. At Zelvraak, catch the smaller Veteran Sea Orb set, turn from fear, interrupt reflections, recover one Sundered Soul, and manage the realm phase and summoned colossus.]],
    scriveners_hall = [[3 main bosses plus the Vault and Cartoqueen secret. On Veteran, Cartoklepts drop Large Vault Keys. At Naqri, destroy Codices and assign one Unstable Literature soak; at Ozezan, place lava, separate beams, and control bugs; at Valinna, manage fire, traps, spiders, meteors, and rolling stones.]],
    bal_sunnar = [[3 main bosses plus 3 optional secrets. At Kovan, avoid clone beams and control summons without player-bound poison circles. At Roksa, interrupt Darklight Orbs, stay in the light, control Nix-Ox adds, and stabilize for one tank beam. At Lladi, survive poison storms and control Peryite's Glory.]],
    oathsworn_pit = [[3 main bosses plus 3 optional Trial bosses and buffs. Separate Rethelros and Malthil, spread for single-target Cinder Shot, kill Protective Totems, manage Anthelmir's axes, barrels, and moths, then place Aradros fire carefully and defeat two side-room lieutenants at 50%.]],
    bedlam_veil = [[3 main bosses plus 3 optional Skyvault charms. Control Shattered Champion fragments and Glaziers, then handle Darkshard's staged Maelstrom summons. At The Blind, block Condemn, place glass safely, kill Remnants, avoid Deluge waves and temporary Piercing Beam lanes, and use charms when helpful.]],
    exiled_redoubt = [[3 main bosses plus 3 optional buff bosses. At Jerensi, place Darkblades away, avoid spikes, kill adds, and pair on Execute. At Vandorallen, bait Storm Bolt, use the Icy Dome for spiders, and handle the curse. Pace Squall through atronach phases.]],
    lep_seclusa = [[3 main bosses plus 3 non-banner mini-bosses. Aim Garvin's Noxious Boulder through each Duneripper, use rocks for Venom Eruption and Ricochet, and interrupt adds. Follow Noriwen through charges and gryphon phases. Keep Orpheon out of Planemeld and move with the Veteran safe area.]],
    black_gem_foundry = [[3 main bosses plus 3 optional secret bosses that improve wrist-cuff buffs. Keep Saldezaar's Rupture lanes clear, use boss attacks to remove gem clusters, destroy Monstrosity shards with Soul Focus, and solve Vykand's color refractions while controlling Refracted Souls.]],
    naj_caldeesh = [[3 main bosses plus 3 optional Vossa-Saxtl puzzle buffs. Avoid Poxito's pressure-plate traps, destroy Bone Effigies, and control skeletons. Manage Stonehulk Fatal Pools, Death Essence, and tethers, then handle Bar-Sakka rolls, Seeping Viscera, boulders, and skeletal adds.]],
    black_drake_villa = [[3 main bosses plus 3 secret Avatars and the optional Sentinel. Secrets grant run buffs and fragments improve them. Control Kinras banners and salamanders, manage Captain Geminus adds and charges, and use the Avatars' abilities to stabilize difficult mechanics.]],
}

local explicitBossSummaries = {
    ["imperial_city_prison/lord_warden_dusk"] = [[Final boss. Assign two portal pairs and never enter early; use portals only for Darklight Burst. Block meteors, have the tank body-block Shadow Barrage, and taunt and kill the solid shades at 66% and 33%.]],
    ["white_gold_tower/molag_kena"] = [[Final boss. Keep Kena near center, kill Lightning Aspects without standing in their explosions, dodge or block Windtoss, move with the regular-speed lightning wall, kill Storm Atronachs, and stay near center for shield-phase jumps and waves.]],
    ["cradle_of_shadows/velidreth"] = [[Final boss. Kill Flesh Atronachs and collect torches before 60% and 30%, survive the split catacomb routes, obey Shadow Sense, avoid resource-draining spores, and interrupt Gout of Bile when someone is being revived.]],
    ["ruins_of_mazzatun/tree_minder_na_kesh"] = [[Final boss. Kill Siphoning Totems immediately, control Stone Shapers and other adds, step on thrown Amber Plasm before it empowers enemies, use Reveal to identify the correct hallucination statue, and stabilize before the 30% execute.]],
    ["bloodroot_forge/earthgore_amalgam"] = [[Final boss. Place lava safely and kill clones from smallest to largest while the tank controls the Amalgams. Use the Stonefire Crucible to stun enemies and the Flameslake Cauldron to cool lava when needed; move calmly during Groundshaker and Falling Debris.]],
    ["falkreath_hold/domihaus_the_bloody_horned"] = [[Final boss. Agree on a pillar rotation, place fire drops cleanly, hide together behind the same pillar for Grovel, kill atronachs during stone phases, and handle the execute shield and adds without losing taunt. Use the larger Veteran pillar set deliberately rather than splitting the group.]],
    ["fang_lair/orryn_thurvokun"] = [[Final boss. Place poison at the edge, interrupt Orryn, control shalks, and destroy Animus Crystals and Bone Colossi at thresholds. For ghost walls, move behind the friendly Life Ward barrier and preserve clean paths to it.]],
    ["scalecaller_peak/zaan_the_scalecaller"] = [[Final boss. Keep Zaan faced away, intercept Fire Cage, avoid Fire Waves, and kill the two frost adds at each threshold. After they die, group inside Spellbreaker for the poison wave, then leave before Zaan reclaims the shield and watch the statue poison cones.]],
    ["march_of_sacrifices/balorgh"] = [[Final boss. Keep Balorgh faced away, avoid poison plants on islands, leave electrified water, dodge Fire Remnant, and avoid charges and frontals. At 80/60/40/20%, stay together, kite the single shadow into each Tharas's Trap, and control Dire Wolves. Veteran has no Stranglers or persistent charge fire trail.]],
    ["moon_hunter_keep/vykosa_the_ascendant"] = [[Final boss. Pace damage through the smaller Veteran werewolf waves, control restrained wolves, interrupt Pounce, kill Shock Wardens and Stranglers, and complete Archivist Ernarde's Symbols of Xarxes. Clean add waves before pushing the next threshold.]],
    ["frostvault/the_stonekeeper"] = [[Final boss. Destroy each arm and its Centurion before burning Stonekeeper. At 50%, enter the Veteran skeevaton route together, avoid the tunnel hazards, and return to the arena. Afterward, repeat the arm phase and prioritize Arquebuses, spiders, spheres, and Centurions.]],
    ["depths_of_malatar/symphony_of_blades"] = [[Final boss. Hold Symphony near center, block the stun, avoid the blade spin, interrupt sword throws, and kill one ghost to create a wall gap. Stop Aurorans before they empower the boss and stay spread for colored-room mechanics; colored orbs and Purification are not active.]],
    ["moongrave_fane/grundwulf"] = [[Final boss. Keep Grundwulf central and faced away. Create a Hemo Helot and use its blood orb to remove protection from Hemonculi, handle shackles and absorption, kill Dire-Maws and other adds, and move the Sliding Stone only when it must block Dying Breath.]],
    ["lair_of_maarselok/maarselok_roost"] = [[Final boss. When Azureblight chooses a host, free Selene from Wicked Bonds and follow the encounter's ward cue to cleanse that player. Avoid Sweeping Breath and Azure Blaze, kill Wyrms and Stranglers, interrupt poison channels, and keep Maarselok's charge path controlled.]],
    ["icereach/mother_ciannait"] = [[Final boss. Damage only the unshielded sister, keep her taunted, avoid overlapping signature spells, and interrupt Storm Surge after shield transitions. Veteran does not add the previous bosses' giant, Strangler, undead, or Stormborn packages. At 20%, stack and burn Mother during Sundered Sky.]],
    ["unhallowed_grave/kjalnar_tombskald"] = [[Final boss. Keep Kjalnar faced away, block heavy attacks, move from Grasping Bomb hands and Runic Spin, and prioritize Imbued Skeletons before their fields empower or explode. At 50%, handle Tzirzhalir's frost and fire attacks; player cages are not active.]],
    ["castle_thorn/lady_thorn"] = [[Final boss. Stay close enough to manage charges and enter the moving safe light during bat phases. Kill Blood Scavengers and use their synergies to end the phase. Veteran has no Blood Guardian; in execute, keep moving with the light while damaging Lady Thorn.]],
    ["the_cauldron/baron_zaudrus"] = [[Final boss. Spread, keep Zaudrus faced away, block Hammer Down, avoid Quake and fire geysers, and move with the single rotating Ash Vent wall. Use Lyranth's Cold-Flame Infusion to destroy pillars and rocks and turn trapped adds into friendly flame atronachs.]],
    ["red_petal_bastion/artifact_bearers"] = [[Second main boss. Eliam is the main target; Liramindrel and Ihudir enter at thresholds. Avoid archer traps, interrupt Ihudir, and kill or incapacitate each lieutenant. In Veteran they remain killable when both return near execute.]],
    ["red_petal_bastion/prior_thierric_sarazen"] = [[Final boss. Keep Prior stable and avoid the kick, cleave, lightning fields, charges, and duplicate attacks. Run in to interrupt Opalescent Impale, kill Realmshapers and Relic Fiends first, and use clean footwork through the smaller Veteran duplicate wall.]],
    ["the_dread_cellar/cyronin_artellian"] = [[Second main boss. Dodge Dread Surge waves and Soulstorm, kill Storm Atronachs and Boltwyrms, and block the heavy attack. Move with Martus's shield wall when required; no separate two-player lightning-drop assignment is needed.]],
    ["the_dread_cellar/magma_incarnate"] = [[Final boss. Keep the arena usable, block Incarnate Outburst, avoid Path of Fire and Dancing Flames, enter portals quickly, kill Agonymium Stones and Scorions, and pass through tornado-wall gaps. Fire paths clear after resolving, and Scorion pressure is lighter.]],
    ["coral_aerie/maligalig"] = [[First main boss. Maintain a loose formation, cleanse Storm Cell by crossing the Storm Front, kill or dodge exploding larvae, and use Surging Waters between platforms. Tank enters first, group kills each Ripple, and no Building Static reset lap is needed.]],
    ["coral_aerie/sarydil"] = [[Second main boss. Chase teleports, avoid daggers, bombs, and mines, interrupt dangerous shadow channels, and control add waves. One player is marked for mine placement, and no Ascendant Stormshapers spawn.]],
    ["coral_aerie/varallion"] = [[Final main boss. Find gaps in single Crashing Waves, destroy Sea Orbs, place targeted shadow pools at the edge, keep Mind Link tethers from crossing, and kill each gryphon. At 30%, kill Kargaeda while controlling the remaining cyclone pressure.]],
    ["shipwrights_regret/foreman_bradiggan"] = [[First main boss. Aim charges into walls, control Haunters and Flame Shapers, spread for Possession, and pair correctly for each Soul Bomb. One two-player Soul Bomb resolves at a time, including execute.]],
    ["shipwrights_regret/captain_numirril"] = [[Final boss. Manage charges, crossing waves, Drowned Corpses, and bile pools. Taunt and kill the single Drowned Hulk at threshold phases before returning to Numirril; do not push into overlapping corpses, waves, and adds.]],
    ["graven_deep/zelvraak_the_unbreathing"] = [[Final boss. Catch the Veteran Sea Orbs before they land, stack cone shades in one direction, turn away for fear, and interrupt reflections. The one Sundered Soul player chases their golden ghost. Collect healing ghosts in the realm, then control the summoned colossus and tombstones.]],
    ["scriveners_hall/riftmaster_naqri"] = [[First main boss. Avoid Booknado and ice bolts, destroy Hidden Codices at thresholds, follow the colored Codex prompts, and assign one durable player to soak the single Unstable Literature circle.]],
    ["scriveners_hall/ozezan_the_inferno"] = [[Second main boss. Place permanent lava near walls, separate and kite Blood Boil beams, move to the edge for Firestorm, face the poison cone away, squash or cleave green bugs, interrupt Broodlings, and taunt Iron Atronachs.]],
    ["scriveners_hall/valinna_lamikhai"] = [[Final boss. Freeze Lamikhai's enrage in Mazandi's ice, leave each room before Fiery Eruption, place fire at the edges, stay inside Immolation Traps, kill Ensnaring Spiders, destroy or block meteors, and block the simpler Veteran rolling-stone lanes.]],
    ["bal_sunnar/kovan_giryon"] = [[First main boss. Avoid Chaotic Ray rectangles from Kovan and his clones, kill shadow-phase summons at thresholds, interrupt dangerous add channels, and prepare for Kovan's return. No player-bound poison-circle assignments occur.]],
    ["bal_sunnar/roksa_the_warped"] = [[Second main boss. Interrupt Darklight Orbs, stay in Saresea's or Roksa's light during darkness, control Nix-Ox adds, avoid Frenzy and fire fields, then stabilize for the single tank beam after portal phases.]],
    ["bal_sunnar/matriarch_lladi_telvanni"] = [[Final boss. Face Infectious Vomit away, survive Pestilence and Toxic Storm, control ordinary Peryite's Blessed adds, taunt Peryite's Glory, and avoid poison eruptions. Skeevers and the Freeze Time stun requirement are not active.]],
    ["oathsworn_pit/packmaster_rethelros_malthil"] = [[First main boss. Keep Malthil away from Rethelros, spread and block the single-target Cinder Shot, kill Protective Totems, avoid Bear Traps and Directed Volley, and kite Malthil's chase without dragging her into the Packmaster.]],
    ["oathsworn_pit/aradros_the_awakened"] = [[Final boss. Place temporary fire tiles carefully, move deliberately for Wildfire, avoid Meteor and Brimstone crosses, and control Awakened Fires. At 50%, enter the side room and defeat the center lieutenant plus either the left or right lieutenant before returning.]],
    ["bedlam_veil/the_blind"] = [[Final boss. Keep The Blind faced away, block Condemn, place Splintered Glass safely, cleave Mirrorplasms, kill Glass Remnants, and avoid Gleaming Deluge and Piercing Beam lanes. Beams are temporary at 60%, then persist after the 40% intermission until 20%.]],
    ["exiled_redoubt/executioner_jerensi"] = [[First main boss. Place Swirling Darkblades away, avoid persistent Spike Traps, purge or outheal Death Knell, and kill Jailer and Torturer adds. When Execute marks a player, that target stacks with one partner; it repeats after 30%.]],
    ["exiled_redoubt/prime_sorcerer_vandorallen"] = [[Second main boss. Assign a distant Storm Bolt bait, outheal Blackspine Curse, run to the Icy Dome during Iron Charge, and pull Iron Atronach Spiders inside. Simulacrums and Coruscating Orbs are not active.]],
    ["lep_seclusa/garvin_the_tracker"] = [[First main boss. Dunerippers spawn at 70% and 40%; aim Noxious Boulder through each before the next spawns. Use rocks to survive Venom Eruption and break Ricochet line of sight, interrupt dangerous Deserter adds, and slow damage if a Duneripper still needs its boulder.]],
    ["lep_seclusa/noriwen"] = [[Second main boss. Tank follows Noriwen's charges, block Brand, purge or outheal Chain Pull, avoid Wing Gust lines, kill Flame Gryphons at 50% and 40%, and respect Alcunar's ledge attacks at 70% and 20%. Wing Gust does not splash around clipped players.]],
    ["lep_seclusa/orpheon_the_tactician"] = [[Final boss. Keep Orpheon out of Arcane Planemeld, move with the Veteran-sized safe zone at 80%, 50%, 30%, and execute, kill each Hulk or Wraith add phase, avoid Arcane Void and tentacles, dodge Forbidden Knowledge, and keep non-tanks away from front cleaves.]],
    ["naj_caldeesh/poxito"] = [[First main boss. Avoid pressure-plate traps, destroy Bone Effigies before Soul Storm grows dangerous, break free from Haunting Specter pulls, control Skeletal Berserkers and Archers, and keep Poxito faced away. Bone Armor and its saw-blade break are not active.]],
    ["black_gem_foundry/high_soulbinder_vykand"] = [[Final boss. Move from Soulbinding Slam, control Enervating Souls, and reveal purple Soul Refractions by running through them. When Vykand shows two colors, each player takes a separate refraction of the third color. Kill Refracted Soul variants before they metastasize and overwhelm the room.]],
    ["shipwrights_regret/nazaray"] = [[Second main boss. Keep Nazaray out of Liquidate puddles, dodge poison rain and twisters, control wasps, Stranglers, and Lurchers, and kill the planned Untamed Kindred spirits to create safe ground before the room-wide explosion.]],
    ["earthen_root_enclave/corruption_of_stone"] = [[First main boss. Spread for Earthquakes, leave Stomp, hide behind stone pillars for both Ground Slams, then taunt, interrupt, and kill Stone Atronachs. Tank normally blocks rather than dodge-rolling boss attacks.]],
    ["earthen_root_enclave/corruption_of_root"] = [[Second main boss. Kill Fauns before they empower trees, destroy glowing Root Nodes when needed, and kill Distributary copies during split phases. Spread their deaths so Root Infection projectiles do not stack.]],
    ["earthen_root_enclave/archdruid_devyric"] = [[Final boss. Spread for Earthquakes, avoid exploding rock totems, interrupt and kill lightning pillars, block or dodge fire wolves, and stay out of ground lightning. Tank faces bear breath away and keeps charge lanes clear.]],
    ["graven_deep/euphotic_gatekeeper"] = [[First main boss. Hold edge-side control, close Pangrit burrows with the poison synergy, kill Pangrit adds and the low-health clone, and avoid teleport and charge areas. Let the boss return instead of chasing every leap.]],
    ["graven_deep/varzunon"] = [[Second main boss. Kill glowing skeletal sacrifices before they feed and grow Varzunon, stack and cleave ordinary skeletons, leave Stomp, stack for blue meteors, dodge line slams and bone traps, and use the dungeon laser to shrink him if available.]],
    ["oathsworn_pit/anthelmirs_construct"] = [[Second main boss. Keep the Construct central, stay out of Retrieve and Hurl Axe lanes, control Cindermoths, preserve space around explosive barrels, break Blast Furnace if needed, and face Angry Inferno away.]],
    ["bedlam_veil/shattered_champion"] = [[First main boss. Avoid Shard and Razor Glass, heal Gaping Wound, place player circles away from the center, chain and kill Glass Fragments, and kill Blind Path Glaziers first when they make the boss and fragments invulnerable.]],
    ["bedlam_veil/darkshard"] = [[Second main boss. Darkshard summons Maxus at 80%, Champion of Atrocity at 60%, and Argonian Behemoth at 40%. After each, handle the retained explosive adds, obelisk and spider mechanics, then Poison Bloom while reacting to shade heavies, cones, and Grasping Scream.]],
    ["exiled_redoubt/squall_of_retribution"] = [[Final boss. Pace damage through Fire, Ice, and Lightning infusions; kill atronachs before pushing more thresholds and pick up each dropped elemental orb with the synergy. Avoid Fire Storm tornadoes, leave Vortex, dodge returning swords, block Icy Flash, and spread or block for Thunderstrike.]],
    ["naj_caldeesh/voskrona_stonehulk_poxito"] = [[Second main boss. Manage Fatal Pools from statue adds, avoid Sentinel Tethers, block or shield Death Essence pulses, move from Standard, fire cone, and talons, and control execute so Fatal Pools do not make the boss invulnerable.]],
    ["naj_caldeesh/talen_lah_and_bar_sakka"] = [[Final boss. Avoid Bar-Sakka's edge rolls, drop Seeping Viscera at the edge, dodge Boulder Rolls, control skeletal adds and Executioners, avoid Vortex pools and charge lanes, and stabilize the tank through Bar-Sakka heavies and Focused Smash.]],
    ["red_petal_bastion/rogerain_the_sly"] = [[First main boss. Kill Chaos Gates first, adds second, and Rogerain last. A random player becomes a goat; eat sweetrolls for buffs and charge the portals for heavy damage while the group prevents portal and add pressure from stacking.]],
    ["the_dread_cellar/scorion_broodlord"] = [[First main boss. Use Purgator's Guardian Stone if unlocked, keep the Scorion faced away, control the smaller Xivilai waves, interrupt Shockslayers, and destroy Agonymium Stones before returning to the boss.]],
    ["coral_aerie/zbaza"] = [[Optional final secret boss after Varallion, unlocked by completing the three covenant guardians. Tank faces Z'Baza away; group avoids Mind Blast and frontals, handles marked orbs and large bombs, kills tentacles, and uses portals or waterholes to follow after teleports.]],
    ["bal_sunnar/laser_puzzle"] = [[Third secret after Roksa. Reposition the small obsidian reflectors so every laser reaches the central totem; the larger rocks block beams and are not reflectors. Completing it grants Ancestral Resolve, increasing Max Health and damage reduction.]],
    ["bedlam_veil/fa_nuit_hen_charms"] = [[Optional Skyvault puzzles before The Blind. Puzzle 1 grants Zephyrus Obscuris for temporary lane protection, Puzzle 2 grants Ocular Disperser for wave protection, and Puzzle 3 grants Catatonic Disruptor to interrupt Condemn.]],
    ["black_gem_foundry/quarrymaster_saldezaar"] = [[First main boss. Keep Rupture lanes clear, use Galvanizing Blow and Charge to remove Black Gem Splinters and clear clusters, and kill Galvanizing Imps quickly. For Wrathful Rupture, stand in the yellow safe ring before the fling and ensure the opposite path is unobstructed.]],
    ["black_gem_foundry/black_gem_monstrosity"] = [[Second main boss. Tank near the edge so Lapidating Bash T-lines leave the middle clear. At 80%, 50%, and 35%, kill the Soulbinder Pyromancer during the lava phase. Stack for shard spawns, then aim Soul Focus through Black Gem Shards to destroy them.]],
    ["black_drake_villa/kinras_ironeye"] = [[First main boss. Tank places shot areas tightly, kill or freeze fire banners and salamanders, keep the salamander aura away from Kinras, interrupt chains quickly, and use Ice Avatar when pressure snowballs.]],
    ["black_drake_villa/captain_geminus"] = [[Second main boss. Spread, maintain taunt, interrupt and kill shades first, control flame hounds, handle the shield-phase Air Atronach, avoid traps and tremors, and never stand in the cleave or bleed lane.]],
    ["black_drake_villa/pyroturge_encratis"] = [[Third main boss. Fight outside, then in the inner library. Leave Flaming Vortex, enter the Fire Storm safe zone, kill ghosts and the Fire Behemoth, use geysers and Ice Avatar intelligently, avoid dragon-head fire, and block spear and frontal pressure.]],
    ["black_drake_villa/sentinel_aksalaz"] = [[Optional final secret boss. Defeat all three main bosses and three Avatars, then have each player deposit the required Avatar Fragments. Only five attempts are available. Kill Frostkins first, the summoned Avatar second, and Sentinel last; avoid pushing multiple thresholds together.]],
}

local mechanicOverrides = {
    {"imperial_city_prison", "lord_warden_dusk", "Coldharbour Meteor / Meteor", {all=[[Block each Coldharbour Meteor rather than panic-rolling. A meteor stun immediately before portal movement, Darklight Burst, or shade control can still wipe the group.]], quick=[[Block Coldharbour Meteors and avoid a stun before portal or shade mechanics.]]}},
    {"imperial_city_prison", "lord_warden_dusk", "Summon Portal / Rift / Portal Feedback", {casts={"Summon Portal", "Rift"}, all=[[Save portals for Darklight Burst. Each portal supports two players, so assign two pairs and never enter early; using one at the wrong time can leave the group without enough portals for the blast.]], quick=[[Save portals for Darklight Burst only. Assign two players per portal and never enter early.]]}},
    {"white_gold_tower", "molag_kena", "Lightning Wall / Lightning Spin / Rotating Lightning", {all=[[Stay near center and move with the regular-speed rotating lightning wall; roll through only as an emergency. Being clipped still causes dangerous follow-up damage.]]}},
    {"cradle_of_shadows", "velidreth", "Corpulence / Expose Morsel / Flurry / Lunging Slash", {healer=[[Keep HoTs on the tank and burst after Expose Morsel or heavy frontal overlap.]]}},
    {"cradle_of_shadows", "velidreth", "Marrow Fiends / Shadow Warriors / Summon Shadow Weavers", false},
    {"cradle_of_shadows", "velidreth", "Orb of Spite", false},
    {"ruins_of_mazzatun", "tree_minder_na_kesh", "Stone Shaper / Root-Mason / Flying Rocks / Amber Projection", {all=[[[ADD] Kill Stone Shapers first, then Root-Masons and casters. Interrupt or block their rock channels, and stack them near the boss or Siphoning Totem when safe.]], quick=[[[ADD] Kill Stone Shapers first, then Root-Masons and casters; interrupt or block rock channels.]]}},
    {"fang_lair", "orryn_thurvokun", "Ghost Waves / Wraith Thralls", {all=[[[!] Ghost walls can one-shot. Move behind the friendly Life Ward barrier before the wall reaches the group; keep poison paths clear so everyone can reach it.]], quick=[[[!] Move behind the friendly Life Ward barrier for every ghost wall.]]}},
    {"fang_lair", "orryn_thurvokun", "Plague Breath / Yisareh's Life Ward / Life Ward", false},
    {"fang_lair", "orryn_thurvokun", "Bone Colossus / Execute Phase", false},
    {"scalecaller_peak", "zaan_the_scalecaller", "Frost Atronach / Corrupted Leimenid / Laserball", false},
    {"scalecaller_peak", "zaan_the_scalecaller", "Winter's Purge / Ice Adds / Frost Atronachs", {all=[[[ADD] At 80%, 60%, 40%, and 20%, Zaan becomes protected and two frost adds spawn. Kill both quickly or the group is frozen and killed; then group inside Spellbreaker for the poison wave.]], quick=[[[ADD] At 80/60/40/20, kill both frost adds fast, then group in Spellbreaker.]]}},
    {"scalecaller_peak", "zaan_the_scalecaller", "Pestilent Breath / Poison Wave / Four Spots / Spellbreaker", {casts={"Pestilent Breath", "Poison Wave", "Spellbreaker"}, all=[[[!] After the frost adds die, Zaan casts a full-room poison wave. The entire group shelters inside Spellbreaker's shield circle; move in promptly and stay until the wave resolves.]], quick=[[[!] After frost adds die, everyone groups inside Spellbreaker for the poison wave.]], tank=[[Move into Spellbreaker with the group after the frost adds die, then re-establish control when the wave ends.]], healer=[[Top the group, enter Spellbreaker, and keep healing until the poison wave resolves.]], dps=[[Kill both frost adds, then move into Spellbreaker with the group; do not remain outside for damage.]]}},
    {"march_of_sacrifices", "balorgh", "Tharas' Trap / Shadow Hunt", {all=[[[!] At 80/60/40/20%, Balorgh becomes immune and one shadow hunts the group. Stay together, kite it behind each Tharas's Trap, and trap it before moving to the next safe route.]], quick=[[[!] At 80/60/40/20, stay together and kite the single shadow into Tharas's Trap.]]}},
    {"march_of_sacrifices", "balorgh", "Stranglers / Dire Wolves", {all=[[[ADD] Dire Wolves join hunt phases and the final burn. Tank controls them without turning Balorgh; kill loose wolves before they overwhelm the group. Stranglers do not spawn in regular Veteran.]], quick=[[[ADD] Control and kill Dire Wolves; regular Veteran has no Stranglers.]]}},
    {"march_of_sacrifices", "balorgh", "Charge / Fire Trail", {all=[[[!] Balorgh charges the aggro target. Sidestep the lane and let the tank restore facing; regular Veteran does not leave a persistent fire trail.]], quick=[[[!] Sidestep Balorgh's charge; regular Veteran leaves no fire trail.]]}},
    {"moon_hunter_keep", "vykosa_the_ascendant", "The Pack / Werewolf Waves", {all=[[[ADD] Smaller werewolf waves spawn at health thresholds. Stop boss damage, taunt and stack the wave, kill it cleanly, then push the next threshold.]], quick=[[[ADD] Stop boss damage at werewolf waves, stack and kill them, then continue.]]}},
    {"frostvault", "the_stonekeeper", "Extermination Protocol / Absorb Energy / Discharge Energy", {casts={"Extermination Protocol", "Skeevatons"}, all=[[[!] At 50%, everyone enters a skeevaton for the simpler Veteran route. Stay together, follow the safe path through the lower tunnels, avoid fire and blades, and use the skeevaton abilities to survive until the group returns to the arena.]], quick=[[[!] Veteran skeevaton phase: stay together, follow the safe tunnel path, avoid fire and blades, and return to the arena.]], tank=[[Stay with the group through the Veteran skeevaton route and do not rush teammates into active traps.]], healer=[[Use the skeevaton support tools while the group stays together and crosses the tunnels.]], dps=[[Stay with the group, avoid the tunnel traps, and clear blocking spider adds when needed.]]}},
    {"frostvault", "the_stonekeeper", "Enfeebling Effluvium / High-Pressure Blast", false},
    {"frostvault", "the_stonekeeper", "Haywire Missiles / Scattered Embers", false},
    {"depths_of_malatar", "symphony_of_blades", "Colored Orbs / Radiant Orb / Blazing Orb / Phosphorescent Orb / Scintillating Orb", false},
    {"depths_of_malatar", "symphony_of_blades", "Decrepify / Purification", false},
    {"moongrave_fane", "grundwulf", "Giant Bat", false},
    {"moongrave_fane", "grundwulf", "Blooded Unrelenting Force / Unrelenting Force / Summon Hemonculi", {all=[[[ADD] Grundwulf's shout summons protected Hemonculi. Group them, create a Sangiin Hemo Helot, and use its blood orb to strip their protection before killing them.]], quick=[[[ADD] Group Hemonculi and use the Hemo Helot blood orb to remove their protection.]]}},
    {"lair_of_maarselok", "maarselok_roost", "Scourge Seed / Azureblight Carrier / The Azure Blight is claiming a host!", {all=[[[!] Azureblight selects one host. Watch the encounter cue, free Selene from Wicked Bonds, and move that player to the indicated cleansing ward. No majority-call puzzle is active.]], quick=[[[!] Free Selene, identify the Azureblight host, and cleanse that player at the indicated ward.]]}},
    {"lair_of_maarselok", "maarselok_roost", "Wicked Bonds / Selene's Cleansing Wards", {all=[[[!] Break Selene's Wicked Bonds promptly so her cleansing wards become available, then use the encounter's indicated ward to cleanse the selected Azureblight host.]], quick=[[[!] Break Selene's bonds, then cleanse the selected host at the indicated ward.]]}},
    {"icereach", "mother_ciannait", "Gohlla's Giant / Enrage / Frost Slam", false},
    {"icereach", "mother_ciannait", "Flame Swirl / Summon Stranglers / Strangler Ice Spit", false},
    {"icereach", "mother_ciannait", "Summon Undead / Enervating Thrall / Rift Wraith / Rift Zombie", false},
    {"icereach", "mother_ciannait", "Stormborn Revenant / Thunderous Pursuit / Frostborn Archer / Avalanche Strike", false},
    {"unhallowed_grave", "kjalnar_tombskald", "Grasping Bomb / Grasping Void / Ghost Hand", {all=[[[!] Grasping Bomb creates a ghost hand beneath a player. Move out immediately; if caught, break free and reposition before the next rune or skeleton field.]], quick=[[[!] Move out of Grasping Bomb hands immediately; break free if caught.]]}},
    {"castle_thorn", "lady_thorn", "Blood Guardian / Channeled Attack", false},
    {"the_cauldron", "baron_zaudrus", "Ash Vent / Fire Walls / Ash Vent Disintegration", {all=[[[!] Ash Vents create a rotating wall of fire. Veteran normally sends one wall at a time; find the gap and move with it while keeping Zaudrus controlled.]], quick=[[[!] Find the gap in the single Ash Vent wall and move with it.]]}},
    {"the_cauldron", "baron_zaudrus", "Rocks / Molten Pillar / Cold-Flame Infusion / Flame Atronach", {all=[[Zaudrus raises rocks/pillars that can trap enemy adds. If they break normally or in fire walls, enemies can spawn. Use Lyranth's Cold-Flame Infusion and light/heavy attack the rocks to release friendly blue flame atronachs instead.]], quick=[[Use Cold-Flame Infusion on rocks/pillars to release friendly blue atronachs instead of enemies.]]}},
    {"red_petal_bastion", "artifact_bearers", "Opal Charm Shield / Arrow Traps / Trap Volley", {all=[[Liramindrel enters with archer attacks and ground traps. Swap to her, avoid the traps, and incapacitate or kill her before returning to Eliam; she does not shield Eliam in Veteran.]]}},
    {"red_petal_bastion", "artifact_bearers", "Execute Add Return / Liramindrel / Ihudir", {all=[[[ADD] Near execute, Liramindrel and Ihudir return and remain killable in Veteran. Control both, interrupt Ihudir, eliminate the safer priority target, then finish Eliam.]], quick=[[[ADD] Execute: both lieutenants return and remain killable; control and kill them before finishing Eliam.]]}},
    {"red_petal_bastion", "prior_thierric_sarazen", "Shadow's Ire", false},
    {"the_dread_cellar", "scorion_broodlord", "Summon / Xivilai Ravager / Xivilai Shockslayer", {all=[[[ADD] The smaller Veteran add waves still take priority. Stack them by Agonymium Stones when safe, interrupt Shockslayers, and kill dangerous Xivilai before pushing more boss health.]], quick=[[[ADD] Stack adds by Agonymium Stones, interrupt Shockslayers, and clear them before pushing.]]}},
    {"the_dread_cellar", "cyronin_artellian", "Lightning Orb / Ground Debuff", false},
    {"the_dread_cellar", "magma_incarnate", "Path of Fire / Fire Beams", {all=[[Magma Incarnate projects fire paths toward players. Spread their lanes, block or dodge the impact, and move out; the paths clear after resolving.]]}},
    {"the_dread_cellar", "magma_incarnate", "Unstable Blitz / Blitz Bonfires", {all=[[Unstable Blitz chains through the arena and can create dangerous fire impacts. Keep moving, avoid the lightning paths and resulting fire, and do not drag them through the group.]]}},
    {"coral_aerie", "maligalig", "Yaghra Larva / Toxic Burst / Summon Larvae", {all=[[Marked Yaghra Larvae chase players and explode with Toxic Burst. Kill them when possible; if one reaches you, time a dodge roll as it explodes and avoid dragging it through the group.]]}},
    {"coral_aerie", "maligalig", "Whirlpool / Surging Waters / Ripple of Maligalig / Building Static", {casts={"Whirlpool", "Surging Waters", "Ripple of Maligalig"}, all=[[[ADD] Whirlpool moves the group between three platforms. Tank uses Surging Waters first and controls the platform; everyone kills the Ripple, avoids platform hazards, and takes the next current together.]], quick=[[[ADD] Tank moves first between platforms; kill each Ripple and take the next current together.]]}},
    {"coral_aerie", "sarydil", "Target Mark / Marked / Coalescing Mines", {all=[[Target Mark makes one player drop repeated mines. That player walks toward unused outer space, places mines away from the group and travel paths, then returns.]], quick=[[Marked player places mines along an unused outer edge, then returns.]]}},
    {"coral_aerie", "sarydil", "Ascendant Stormshaper / Lightning AoE", false},
    {"coral_aerie", "varallion", "Crashing Waves", {all=[[[!] Crashing Waves cross the floor. Veteran sends a simpler single-wave pattern; find the gap early and step through it instead of trying to block the wave.]], quick=[[[!] Find the gap early and step through the single Crashing Wave.]]}},
    {"coral_aerie", "varallion", "Coalescing Shadows / Traps", {all=[[Coalescing Shadows marks a player to drop damaging pools. Move to unused outer space, place the pools away from paths, then return without crossing Mind Link tethers or incoming waves.]]}},
    {"shipwrights_regret", "foreman_bradiggan", "Soul Bomb", {all=[[[!] Soul Bomb needs two players in the circle to split the hit. Pair up immediately and hold position until it resolves; Veteran does not add the double-bomb execute pattern.]], quick=[[[!] Two players stack in each Soul Bomb. Pair quickly and stay until it resolves.]]}},
    {"shipwrights_regret", "captain_numirril", "Drowned Hulk / Punt / Crush / Pursue / Smash", {all=[[[ADD] A Drowned Hulk joins threshold phases. Taunt it immediately, keep its charge and cleave away from the group, and kill the single Hulk before returning to Numirril.]], quick=[[[ADD] Taunt and kill the single Drowned Hulk before returning to Numirril.]]}},
    {"earthen_root_enclave", "corruption_of_stone", "Stone Atronach / Petrify / Petrify Beam / Fire Rocks", {tank=[[Taunt every active Atronach, interrupt Petrify beams when close, and stack them for cleave. Keep loose adds off the group while preserving the boss's facing.]]}},
    {"earthen_root_enclave", "archdruid_devyric", "Fire Wolves / Wolves / Exploding Wolves", {all=[[[ADD] Devyric sends three fire wolves across the arena. Find the gaps, block or dodge if needed, and avoid their explosions; keep the bear and totems controlled while the wave passes.]], quick=[[[ADD] Find gaps in the three-wolf wave and avoid their explosions.]]}},
    {"graven_deep", "euphotic_gatekeeper", "Heavy Attack / Crushing Strike / Hadolid Heavy", {all=[[The Gatekeeper's heavy attack is a real tank check even on Veteran. Tank blocks it; non-tanks should avoid aggro and dodge or block if it turns toward them.]]}},
    {"graven_deep", "zelvraak_the_unbreathing", "Drowning Waters / Sea Orb / Sea Orbs / Bubble", {all=[[[!] A smaller set of Sea Orbs falls toward the arena and must be touched before landing. Spread assignments, tag every orb, then regroup.]], quick=[[[!] Spread and tag every falling Sea Orb before it lands; Veteran sends the smaller set.]]}},
    {"graven_deep", "zelvraak_the_unbreathing", "Sundered Soul / Soul Fragmentation / Siphon Soul / Golden Ghost", {all=[[[!] One player is separated from their soul. The affected player follows the golden ghost and touches it before time expires while the group maintains boss and add control.]], quick=[[[!] Sundered Soul player chases and touches the golden ghost before time expires.]]}},
    {"scriveners_hall", "riftmaster_naqri", "Unstable Literature / Exploding Book / Book Soak", {all=[[[!] One green Unstable Literature circle appears in Veteran. Assign one durable player, usually the tank, to stand inside and block until it resolves; never leave the circle empty.]], quick=[[[!] Veteran has one green book soak. Assign one player and never leave it empty.]]}},
    {"scriveners_hall", "ozezan_the_inferno", "Blood Boil / Fire Beams / Lasers / Beam", {all=[[[!] Blood Boil targets one player. The target spreads away, kites or dodge-rolls as planned, and never drags the beam through another player.]], quick=[[[!] Blood Boil target spreads and keeps the beam away from everyone else.]]}},
    {"scriveners_hall", "ozezan_the_inferno", "Green Bugs / Larvae / Evolved Broodlings / Broodling Channel", {all=[[[ADD] Green bugs can hatch into Evolved Broodlings. Squash nearby bugs or cleave them before they evolve, interrupt Broodling channels, and do not let adds free-cast during Firestorm or beam phases.]]}},
    {"scriveners_hall", "valinna_lamikhai", "Rain of Fire / Fire Meteors / Cookies / Fire Rune", {healer=[[Keep the group in heal range while each target places fire near the edge. Pre-HoT before movement and stabilize anyone clipped by a meteor.]]}},
    {"scriveners_hall", "valinna_lamikhai", "Fire Beam / Flamethrower / Burning Dot / Inferno", {healer=[[Pre-HoT and burst-heal the Fire Beam target while the group keeps the beam path clear.]]}},
    {"scriveners_hall", "valinna_lamikhai", "Rolling Stones / Stone Lines / Rolling Boulders", {all=[[Rolling stones form simpler lanes in the final room. Read the gaps early, block if a stone reaches you, and avoid being knocked into fire, meteors, or an Immolation Trap.]], quick=[[Read the rolling-stone lanes early; use gaps or block to avoid knockback into fire.]]}},
    {"bal_sunnar", "kovan_giryon", "Mind Manipulation / Poison Phase / Poison Circles / Lingering Toxins", false},
    {"bal_sunnar", "roksa_the_warped", "Portal Rush / Annihilation Beam / Tank Beam", {all=[[[ADD] During portal phases, Roksa leaves while Nix-Ox adds spawn, then fires Annihilation Beam. Control adds, stay protected by Saresea's light, and stabilize before the single Veteran tank beam.]], quick=[[[ADD] Control Nix-Ox adds, stay in Saresea's light, then stabilize for one tank beam.]], tank=[[Grab Nix-Ox adds quickly, then block and use a defensive for the single tank beam.]], healer=[[Keep HoTs on the group, then focus the tank through the single beam after the portal phase.]]}},
    {"bal_sunnar", "matriarch_lladi_telvanni", "Choking Pestilence / Toxic Storm / Freeze Time / Time Stop / Shards of Time", {casts={"Choking Pestilence", "Toxic Storm"}, all=[[[!] During threshold phases, the room fills with poison and Peryite's Blessed adds spawn. Stack and control the adds, heal through the storm, and kill them normally before returning to Lladi.]], quick=[[[ADD] During poison storms, stack and kill Peryite's Blessed adds while healing through the room damage.]]}},
    {"bal_sunnar", "matriarch_lladi_telvanni", "Skeevers / Red Rune / Skeever Debuff", false},
    {"bal_sunnar", "matriarch_lladi_telvanni", "Toxic Eruption / Plague Bomb / Plague Dash / Plague of Insects", {dps=[[Move out of poison before finishing casts. Clean movement and add control make the execute safer than greed.]]}},
    {"oathsworn_pit", "packmaster_rethelros_malthil", "Cinder Shot / Bonfire", {all=[[[!] Cinder Shot targets one player in Veteran. The target separates the long fire line from allies, blocks or dodges the shot, then moves out of the Bonfire left behind.]], quick=[[[!] Cinder Shot target separates, blocks or dodges, then leaves the Bonfire.]]}},
    {"oathsworn_pit", "aradros_the_awakened", "Emblazoned Strike / Molten Tile / Magma Eruption / Fracturing Strike", {all=[[[!] Aradros erupts fire onto floor tiles. Veteran scorch zones expire instead of remaining for the whole phase, but place them carefully and never stand on a glowing tile.]], quick=[[[!] Place temporary scorched tiles cleanly and move off glowing floor.]]}},
    {"oathsworn_pit", "aradros_the_awakened", "Wildfire / Fire DoT / Tile Ignite", {all=[[The Wildfire target moves deliberately across unused tiles, stays away from allies, and preserves safe paths for the group.]], quick=[[Wildfire target moves tile-by-tile through unused space and stays away from allies.]]}},
    {"oathsworn_pit", "aradros_the_awakened", "Firestep / Fiery Cowardice / Faenalir / Maerolor / Nilborwen", {all=[[[!] At 50%, the side room opens. Veteran activates the center lieutenant and either the left or right lieutenant. Move in together, focus one target at a time, and leave promptly after both die.]], quick=[[[ADD] At 50%, kill the center lieutenant plus one side lieutenant, then leave together.]], dps=[[Focus the called lieutenant and do not split damage; kill both active targets before leaving.]]}},
    {"oathsworn_pit", "aradros_the_awakened", "Shield Throw / Vicious Strikes / Molten Pillar / Stalactite", {all=[[Faenalir uses shield throws, a dangerous frontal, and falling stalactites. Avoid the frontal, block or dodge the shield, and keep the group clear of falling debris.]]}},
    {"bedlam_veil", "the_blind", "Piercing Beam / Blind Shards / Zephyrus Obscuris", {all=[[[!] Piercing Beam covers full arena lanes and ramps damage. It is temporary during the 60% intermission, then persists after the 40% intermission until the 20% transition. Leave the lane; it cannot be dodge-rolled.]], quick=[[[!] Leave Piercing Beam lanes. It is temporary at 60%, then persists from the 40% intermission until 20%.]]}},
    {"bedlam_veil", "darkshard", "Maelstrom Summon / Maxus the Many / Champion of Atrocity / Argonian Behemoth", {all=[[[ADD] At 80/60/40, Darkshard leaves and summons Maxus, Champion of Atrocity, then Argonian Behemoth. Afterward, explosive adds, obelisk/spider mechanics, and Poison Bloom respectively remain active.]], quick=[[[ADD] At 80/60/40 kill the summoned mini-boss, then handle the mechanic it leaves behind.]]}},
    {"bedlam_veil", "darkshard", "Argonian Behemoth / Poison Bloom / Argonian Venomcaller / Volatile Plants", {all=[[[ADD] During the Behemoth phase, avoid Poison Bloom flowers and kill Venomcallers. After the Behemoth dies, Poison Bloom persists but Venomcallers do not. Cleanse poison in clean water if needed.]], quick=[[[ADD] Avoid Poison Bloom, kill Venomcallers during Behemoth, and use clean water to cleanse poison.]]}},
    {"exiled_redoubt", "executioner_jerensi", "Execute / Oblivion Damage", {all=[[[!] Execute marks a player with a yellow circle after add phases and repeats after 30%. In Veteran, the marked player stacks with one other player to split the Oblivion hit.]], quick=[[[!] Yellow Execute target stacks with one partner. It repeats after 30%.]], dps=[[When Execute appears, stack with the yellow target if assigned; one partner is enough in Veteran.]]}},
    {"exiled_redoubt", "prime_sorcerer_vandorallen", "Simulacrums / Inferno", false},
    {"exiled_redoubt", "prime_sorcerer_vandorallen", "Coruscating Orb", false},
    {"lep_seclusa", "garvin_the_tracker", "Noxious Boulder / Monstrous Duneripper / Scream", {all=[[[!] Dunerippers spawn at 70% and 40% in Veteran. Do not burn or aggro them normally; aim Garvin's Noxious Boulder through each one to kill it before the next spawn. At 30%, Garvin's scream enrages any left alive.]], quick=[[[!] Dunerippers spawn at 70/40. Aim Noxious Boulder through each; kill it before the 30% enrage.]]}},
    {"lep_seclusa", "garvin_the_tracker", "Venom Eruption / Venomous Clouds", {quick=[[[!] Hide behind a rock until Venom Eruption clouds end, then return.]]}},
    {"lep_seclusa", "garvin_the_tracker", "Ricochet / Tracked", {all=[[[!] Ricochet links two players. Before the timer ends, use a rock to break line of sight from the other linked player and hold the break until it resolves.]], quick=[[[!] Linked players break line of sight from each other using a rock.]]}},
    {"lep_seclusa", "noriwen", "Wing Gust / Alcunar / Conduit / Snap / Stomp / Swipe", {all=[[Alcunar sends moving Wing Gust lines through the arena. Avoid them and block or dodge Alcunar's ledge swipes if you are nearby; the Veteran DoT does not splash around the clipped player.]], quick=[[Avoid Wing Gust lines and block or dodge Alcunar's ledge swipes.]]}},
    {"lep_seclusa", "orpheon_the_tactician", "Quick Strike / Slow Descent / Light Attack", {all=[[Orpheon's front attacks cleave and unblocked hits drain resources on Veteran. Tank blocks and faces him away; DPS and healer never stand in front.]]}},
    {"lep_seclusa", "orpheon_the_tactician", "Alcunar / Wing Gust / Snap / Stomp / Swipe", {all=[[Alcunar adds pressure during add phases and below 20%. Block or dodge his ledge hits and avoid Wing Gust lines; the Veteran DoT does not splash around clipped players.]]}},
    {"naj_caldeesh", "poxito", "Pressure Plates / Saw Blades / Fireball Traps", {all=[[Floor plates trigger fireballs, moving saw blades, and other traps. Avoid stepping on plates and keep combat paths clear; Veteran does not require saw blades to strip Bone Armor.]], quick=[[Avoid pressure plates and their saw-blade and fireball traps.]]}},
    {"naj_caldeesh", "poxito", "Bone Armor / Skeletal Armor", false},
    {"black_gem_foundry", "high_soulbinder_vykand", "Ominous Vision / Annihilation", false},
    {"black_drake_villa", "sentinel_aksalaz", "Heavy Attack / Ice Gash / Ice Swing", {all=[[Sentinel's heavy and ice frontals hit hard. Tank faces him away and blocks or dodges as resources allow; everyone else stays out of the front at all times.]], quick=[[[!] Tank blocks or dodges heavy ice hits and faces Sentinel away; everyone else stays out of front.]]}},
    {"black_drake_villa", "sentinel_aksalaz", "Ice Spikes / Icicles", {all=[[Icicles chase beneath players in repeated waves. Keep moving until the entire sequence ends while preserving the boss's facing and enough space for upcoming comets.]], quick=[[Keep moving until every icicle wave finishes; do not stop early.]]}},
    {"black_drake_villa", "sentinel_aksalaz", "Frostkins / Banekins", {all=[[[ADD] One Frostkin appears at a time. Kill it before Avatar or Sentinel damage so add pressure cannot stack with comets and movement.]], quick=[[[ADD] Kill each Frostkin before returning to the Avatar or Sentinel.]]}},
    {"black_drake_villa", "sentinel_aksalaz", "Ice Comets / Meteors", {all=[[[!] Large comet circles target players as the fight progresses. Spread to separate spots, never overlap circles, and block each impact; preserve enough room for Frost Nova movement.]], quick=[[[!] Spread comet circles, never overlap, and block each impact.]]}},
    {"black_drake_villa", "sentinel_aksalaz", "Summoned Avatars", {all=[[[ADD] The Avatars of Zeal, Vigor, and Fortitude join at 75%, 55%, and 30%. Do not push into multiple Avatars. Kill the current Frostkin first, then the active Avatar, then return to Sentinel.]], quick=[[[ADD] Avatars join at 75/55/30. Kill Frostkin, then Avatar, then Sentinel.]]}},
}

local textFields = {"summary", "ui", "all", "quick", "tank", "healer", "dps", "general"}

local function cleanModeLabels(text)
    if type(text) ~= "string" then return text end
    text = text:gsub("First main challenge%-banner boss", "First main boss")
    text = text:gsub("Second main challenge%-banner boss", "Second main boss")
    text = text:gsub("Third main challenge%-banner boss", "Third main boss")
    text = text:gsub("Final challenge%-banner boss", "Final boss")
    text = text:gsub("Main banner 1%.", "First main boss.")
    text = text:gsub("Main banner 2%.", "Second main boss.")
    text = text:gsub("Main banner 3%.", "Third main boss.")
    text = text:gsub("Final banner%.", "Final boss.")
    text = text:gsub("Main banner%.", "Main boss.")
    text = text:gsub(" HM:", ":")
    text = text:gsub("[Hh]ard%-[Mm]ode", "Veteran")
    text = text:gsub("[Hh]ard [Mm]ode", "Veteran")
    text = text:gsub("[Cc]hallenge%-[Bb]anner", "Veteran")
    text = text:gsub("[Cc]hallenge [Bb]anner", "Veteran")
    text = text:gsub("[Cc]hallenge [Mm]ode", "Veteran")
    text = text:gsub("[Cc]hallenge clear", "Veteran clear")
    text = text:gsub("[Cc]hallenge run", "Veteran run")
    text = text:gsub("[Cc]hallenge pressure", "fight pressure")
    text = text:gsub("[Cc]hallenge%-run", "Veteran")
    text = text:gsub("Final HM", "Final Veteran")
    text = text:gsub("Main HM", "Main Veteran")
    text = text:gsub(" HM ", " Veteran ")
    text = text:gsub(" HM%.", " Veteran.")
    text = text:gsub(" HM,", " Veteran,")
    return text
end

local function cloneArray(value)
    if type(value) ~= "table" then return value end
    local out = {}
    for index, item in ipairs(value) do out[index] = cleanModeLabels(item) end
    return out
end

local function classifyShared(value)
    if value.vet == nil then value.vet = {} end
    if value.vet == false then return end
    value.vet.classification = value.vet.classification or "shared"
    for _, field in ipairs(textFields) do
        if value.vet[field] == nil and value[field] ~= nil then
            value.vet[field] = cleanModeLabels(value[field])
        end
    end
    for _, field in ipairs({"chat", "quickChat"}) do
        if value.vet[field] == nil and value[field] ~= nil then
            value.vet[field] = cloneArray(value[field])
        end
    end
end

local function requireDungeon(id)
    local dungeon = DMC.GetDungeonById(id)
    assert(dungeon, "Veteran dataset: missing dungeon " .. tostring(id))
    return dungeon
end

local function requireBoss(dungeon, id)
    local boss = DMC.GetBossById(dungeon, id)
    assert(boss, "Veteran dataset: missing boss " .. dungeon.id .. "/" .. tostring(id))
    return boss
end

local function requireMechanic(boss, label)
    local found
    for _, mechanic in ipairs(boss.mechanics or {}) do
        if DMC.GetMechanicLabel(mechanic, "hm") == label then
            assert(not found, "Veteran dataset: duplicate mechanic label " .. boss.id .. "/" .. label)
            found = mechanic
        end
    end
    assert(found, "Veteran dataset: missing mechanic " .. boss.id .. "/" .. tostring(label))
    return found
end

-- First classify every object. This makes inheritance intentional and auditable.
local counts = {dungeons=0, bosses=0, mechanics=0, overridden=0, hidden=0}
for _, dungeon in ipairs(DMC.data.dungeons) do
    counts.dungeons = counts.dungeons + 1
    dungeon.vet = dungeon.vet or {classification="shared"}
    dungeon.summary = dungeon.summary or {}
    classifyShared(dungeon.summary)
    for _, boss in ipairs(dungeon.bosses or {}) do
        counts.bosses = counts.bosses + 1
        classifyShared(boss)
        for _, mechanic in ipairs(boss.mechanics or {}) do
            counts.mechanics = counts.mechanics + 1
            classifyShared(mechanic)
        end
    end
end

for dungeonId, summary in pairs(dungeonSummaries) do
    local dungeon = requireDungeon(dungeonId)
    dungeon.summary.vet = {classification="veteran", ui=summary, full=summary, chat={summary}}
end

for path, summary in pairs(explicitBossSummaries) do
    local slash = assert(path:find("/", 1, true))
    local dungeon = requireDungeon(path:sub(1, slash - 1))
    local boss = requireBoss(dungeon, path:sub(slash + 1))
    boss.vet = {classification="veteran", ui=summary, summary=summary, chat={summary}}
end

for _, override in ipairs(mechanicOverrides) do
    local dungeon = requireDungeon(override[1])
    local boss = requireBoss(dungeon, override[2])
    local mechanic = requireMechanic(boss, override[3])
    if override[4] == false then
        mechanic.vet = false
        counts.hidden = counts.hidden + 1
    else
        local existing = mechanic.vet or {}
        override[4].classification = "veteran"
        for field, value in pairs(existing) do
            if override[4][field] == nil then override[4][field] = value end
        end
        mechanic.vet = override[4]
        counts.overridden = counts.overridden + 1
    end
end

DMC.veteranDataset = {
    version = 2,
    difficulty = "Veteran without Hard Mode",
    verifiedDate = "2026-09-03",
    counts = counts,
}
