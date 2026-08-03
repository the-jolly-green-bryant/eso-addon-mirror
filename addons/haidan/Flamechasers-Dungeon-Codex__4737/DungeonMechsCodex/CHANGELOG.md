# Changelog

## 0.2.58
- Registered the shared Flamechasers keybind category and action labels before
  ESO parses `Bindings.xml`, removing the remaining load-order dependency.
- Kept both binding action identifiers unchanged so existing assigned keys remain valid.

## 0.2.57
- Corrected the README's language-support note so it accurately describes the
  current zone-name matching behavior.
- Removed an unreachable scrollbar-drag branch and its guarded reference to an undocumented mouse helper; mechanics scrolling remains mouse-wheel based as designed.
- Removed two pass-through cursor wrappers and now call ESO's documented cursor APIs directly.
- Removed redundant nil checks from non-nil zone API results while preserving
  the documented nilable `GetUnitZoneIndex()` check.
- Rechecked every remaining API, ESO UI source reference, event, SavedVariables call, keybind, global, and package entry.
- No dungeon data, mechanic wording, view mode, paste, keybind, cursor, or visible UI behavior was changed.

## 0.2.56
- Removed obsolete API-existence checks and protected-call wrappers after verifying the referenced chat, zone, cursor, mouse, SavedVariables, and control APIs against ESO API 101050 documentation and the current ESO UI source.
- Simplified zone-ID lookup to ESO's documented `GetUnitZoneIndex()` to `GetZoneId()` flow.
- Rechecked dataset loading, globals, keybinds, slash commands, lifecycle, SavedVariables, and package structure.
- No dungeon data, mechanic wording, view mode, paste, keybind, cursor, or UI behavior was removed.

## 0.2.55
- Registered keybind string IDs from the addon's verified `EVENT_ADD_ON_LOADED` callback.
- Confirmed the SavedVariables contain only server-independent UI preferences.
- Documented the current English mechanics dataset and language behavior.
- Rechecked global namespace usage, manifest metadata, dependencies, and ESOUI release compliance.
- No dungeon dataset, mechanic wording, or paste behavior changes.

## 0.2.50
- Added auto cursor/UI mode when opening the addon window.
- Closing the addon restores camera mode only if Flamechasers Dungeon Codex enabled cursor mode itself.
- No dataset or paste-text changes.

## 0.2.49
- Adjusted Mechanics card line layout so long Full-mode paste chunks get more vertical room when a card has only 1-2 paste lines.
- This fixes long mechanic text clipping in the UI without changing pasted chat text or dataset wording.

## 0.2.48
- Added subtle visual-only mechanic card numbers to the Mechanics panel so users can track which mechanic snippet they are viewing/pasting after scrolling.
- Mechanic numbers are UI-only and are not included in pasted chat text.
- No dataset text changes.

## 0.2.47
- Added session-only UI memory for selected dungeon, selected boss, and selected mode tab.
- Closing/reopening the window now keeps the current lookup target during the same UI session.
- Selection memory is not written to SavedVariables, so it resets after game close/reload.
- Fixed Core.lua version metadata to match the addon manifest.

## 0.2.46
- Renamed the visible mechanics tab from **All** to **Full** to avoid implying that every role tab is shown together.
- Added/shortened the tab label to **Mode:** before the Full/Quick/Tank/Healer/DPS buttons.
- Updated the empty Quick notice to point users to **Full** for complete explanations.
- No dataset changes; DLC-only scope preserved.

## 0.2.45
- Added manually-written Quick callouts for Depths of Malatar, Moongrave Fane, Lair of Maarselok, Icereach, and Unhallowed Grave.
- Completed the first full Quick callout pass across all DLC dungeon modules currently in the addon.
- Left detailed All/Tank/Healer/DPS mechanics unchanged.
- Preserved DLC-only scope.

## 0.2.44
- Added manually-written Quick callouts for Fang Lair, Scalecaller Peak, Moon Hunter Keep, March of Sacrifices, and Frostvault.
- Left detailed All/Tank/Healer/DPS mechanics unchanged.
- Preserved DLC-only scope.

## 0.2.43
- Added manually-written Quick callouts for Black Drake Villa, Black Gem Foundry, Bloodroot Forge, and Falkreath Hold.
- Left detailed All/Tank/Healer/DPS mechanics unchanged.
- Preserved DLC-only scope.

## 0.2.42
- Added manually-written Quick callouts for Imperial City Prison, White-Gold Tower, Cradle of Shadows, and Ruins of Mazzatun.
- Left detailed All/Tank/Healer/DPS mechanics unchanged.
- Preserved DLC-only scope.

## 0.2.41
- Added manually-written Quick callouts for Stone Garden, Castle Thorn, The Cauldron, and Red Petal Bastion.
- Left detailed All/Tank/Healer/DPS mechanics unchanged.
- Preserved DLC-only scope.

## 0.2.40
- Added manually-written Quick callouts for Coral Aerie, Exiled Redoubt, and Lep Seclusa.
- Kept detailed All/Tank/Healer/DPS text unchanged.
- No dataset scope changes; DLC-only scope preserved.

## 0.2.39
- Added manually-written Quick callouts for Shipwright's Regret, Earthen Root Enclave, Bal Sunnar, Scrivener's Hall, and Naj-Caldeesh.
- Kept detailed All/Tank/Healer/DPS text unchanged.
- No dataset scope changes; DLC-only scope preserved.

## 0.2.38

- Added a new **Quick** mechanics tab between All and Tank.
- Quick mode is group-facing: it uses the normal [!]/[INT]/[ADD] priority tag logic, not role tags.
- Added manually written Quick callouts for The Dread Cellar, Graven Deep, Oathsworn Pit, and Bedlam Veil.
- Quick snippets are shorter than All text but keep key conditions, target priority, timing, and failure cases when needed.
- Unconverted bosses now show a clear “No Quick callouts yet” notice instead of pretending the detailed All text is short.
- No dungeon scope changes; DLC-only hard-mode focus preserved.

## 0.2.37

- Reworked the summary and mechanics scrollbar visuals into flat dark tracks with neutral visible thumbs.
- Removed the ornate tooltip-border styling from narrow scrollbar controls because it rendered as oversized teal bracket lines.
- No dataset changes; DLC-only scope preserved.

## 0.2.36

- Slightly reduced the boss-list button font and tightened row spacing so four-boss columns stay inside the Bosses panel without clipping.
- No dataset changes; DLC-only scope preserved.

## 0.2.35

- Added mouse-wheel paged summary panes for dungeon summaries and boss summaries so long text no longer gets visually clipped.
- Added mini visual scrollbars/page counters to the dungeon and boss summary areas when more than one summary page exists.
- Reworked boss-summary paste buttons so long boss summaries split into Paste 1 / 2 / 3 / 4 buttons using the same chat splitting path as dungeon/mechanic paste.
- Cleared stale selected mechanic text when changing dungeon, boss, or role filter so the keybind does not paste an old mechanic after navigation.

## v0.2.34

- Rebranded visible addon/UI name to Flamechasers Dungeon Codex while keeping the internal folder/namespace stable for compatibility.
- Added/finished ESO Controls keybind support with string IDs for opening/closing the addon window and pasting the selected mechanic.
- Added `/flamecodex` as an extra slash command. Existing `/dmc`, `/dmech`, and `/dungeonmechs` still work.
- Sanity-checked DLC-only scope, manifest load order, Bindings.xml presence, version metadata, and package structure.

## v0.2.33

- Corrected scope: removed the accidental non-DLC module.
- Restored the addon to DLC-only hard-mode/challenge-banner coverage.
- No non-DLC dungeon modules are loaded in this build.

## v0.2.32

- Added full hard-mode-focused Ruins of Mazzatun dataset.
- Included all four required encounters: Zatzu the Spine-Breaker, The Mighty Chudan, Xal-Nur the Slaver, and Tree-Minder Na-Kesh.
- Added final-boss HM notes for alchemical notes activation, Siphoning Totem priority, Stone Shaper/add control, Amber Plasm soaks, Hist Hallucination/statue guidance, Chudan/Xal-Nur spirit phases, and execute pressure.
- Added path-boss mechanics for Zatzu flying rocks, Chudan Bog Rush/Lightning Shield, Xal-Nur Swamp Spice/geyser runs, Wamasu Slavers, trolls/archers, and phase pacing.
- Kept final-boss hard-mode activation and optional achievement routing in summaries, with boss-fight-only behavior in mechanic sections.

## v0.2.31

- Added full hard-mode-focused Cradle of Shadows dataset.
- Included all five required encounters: Sithera, Khephidaen the Spiderkith, Votary of Velidreth, Dranos Velador, and Velidreth the Lady of Lace.
- Added final-boss HM notes for Mephala statue activation, Shadow Sense / Shadow Spine, Atronach's Light torches, split catacombs, HM adds, Orb of Spite, Gout of Bile, and resource-draining spores.
- Added path-boss mechanics for light/brazier control, Khephidaen Extinguish/interrupts, Votary broodlings/Consume/Webspinner's Wrath, and Dranos Fangs of Mephala/shades/statue pressure.
- Kept final-boss hard-mode activation and optional achievement routing in summaries, with boss-fight-only behavior in mechanic sections.

## v0.2.30

- Added full hard-mode-focused White-Gold Tower dataset.
- Included all six required encounters: The Iron-Swathed Glutton, The Adjudicator, Elite Guard, The Scion of Wroth, The Planar Inhibitor, and Molag Kena.
- Added Obelisk Tome final-boss HM context plus path mechanics for cages/flame waves, Elite Guard kill order/heal interrupts, Scion interrupt punishment, Planar Inhibitor Pinion/Heat Stroke/portals/blue flames, and Molag Kena Lightning Aspects, Windtoss, Lightning Wall, Storm Atronach, jump/wave shield phases, and execute wall pressure.
- Kept hard-mode route/unlock notes in summaries and boss-fight-only behavior in mechanic sections.

## v0.2.29

- Added full hard-mode-focused Imperial City Prison dataset.
- Included Overfiend, Ibomez the Flesh Sculptor, Gravelight Sentry, Flesh Abomination, Lord-Warden's Council, and Lord Warden Dusk.
- Added final-boss HM notes for Warden's Tome activation, constant meteors, Portal Feedback, portal teams, Darklight Burst, Shadow Barrage body-blocking, and shade phases.
- Backfilled the earliest Imperial City DLC dungeon while keeping final-boss hard mode context separate from route/unlock info.

## v0.2.28

- Added full hard-mode-focused Naj-Caldeesh dataset.
- Included Vossa-Saxtl Puzzles, Poxito, Voskrona Stonehulk Poxito, and Talen-Lah with Bar-Sakka.
- Added move/cast labels and role-specific notes for Poxito Bone Armor/saw blades/Soul Storm, Stonehulk Fatal Pools/Death Essence/Sentinel Tethers, and final-boss Seeping Viscera/Boulder Roll/Vortex/add phases.
- Kept Vossa-Saxtl puzzle access and buff context in summaries only; mechanics sections remain boss-fight-only.

## v0.2.27

Added complete challenge-focused dataset for Lep Seclusa.

## v0.2.26

Added complete challenge-focused dataset for Exiled Redoubt.
- Included Guard Captain Paratius, Executioner Jerensi, Docent Domitius, Prime Sorcerer Vandorallen, Eliana Albus, and Squall of Retribution.
- Added move/cast labels for Jerensi Execute/Shadow Ward/Death Knell, Vandorallen Iron Charge/Icy Dome/Coruscating Orb, and Squall elemental infusions/atronach orbs/Thunderstrike.
- Kept optional secret-boss buff and route context in summaries while keeping mechanics fight-only.

## v0.2.25

- Added full hard-mode-focused Bedlam Veil dataset.
- Included Fa-Nuit-Hen puzzle charms, Shattered Champion, Darkshard, and The Blind.
- Added move/cast labels for Shattered Champion glass/Glaziers, Darkshard Maelstrom summons, Champion obelisks/spiderlings, Argonian Behemoth poison/Minders, and The Blind Condemn/Gleaming Deluge/Piercing Beam/Glass Remnants.
- Kept optional puzzle solution/route context in summaries while using charm synergies only where they directly affect The Blind mechanics.

## v0.2.24

Added complete challenge-focused dataset for Oathsworn Pit.
- Covered Sluthrug the Bloodied, Packmaster Rethelros & Malthil, Bolg of Wicked Barbs, Anthelmir & Anthelmir's Construct, Grubduthag Many-Fates, and Aradros the Awakened.
- Added move/cast labels, role-specific notes, and paste-ready snippets for Blood Ties, Cinder Shot, Protective Totem, Conquest braziers, Retrieve/Hurl Axe, Heat Blast, Kindlepitch Barrels, Wildfire, Meteor Call, Firestep side room, lieutenants, and optional Smelter setup.
- Kept Trial unlock/path and Blood/Conquest/War buff/totem details in summaries only; mechanics sections remain fight-only.

## v0.2.23

Added complete challenge-focused dataset for Scrivener's Hall.
- Covered Cartoklepts/Vault Keys, Cartoqueen, Riftmaster Naqri, Ozezan the Inferno, and Valinna & Lamikhai.
- Added move/cast labels, role-specific notes, and paste-ready snippets for Hidden Codex, Unstable Literature double soaks, Ozezan lava/Blood Boil/Firestorm/adds, Lamikhai freeze, Immolation Trap, Ensnaring Spider, meteors, and rolling stones.
- Kept Vault/key unlock routing in summaries only; mechanics sections remain fight-only.

## 0.2.22

- Added complete challenge-focused dataset for Bal Sunnar.
- Included Totem-Wheel Puzzle, Kovan Giryon, Urvel Drath, Roksa the Warped, Laser Puzzle, and Matriarch Lladi Telvanni.
- Added HM-focused callouts for Kovan poison circles and clone beams, Roksa Darklight Orb interrupts and triple tank beam, and Lladi Telvanni Choking Pestilence, Freeze Time add burn, skeevers, Infectious Vomit, and Peryite's Glory.
- Kept puzzle unlock/path/buff information in summaries only, with no non-fight puzzle mechanics in the mechanics section.

## 0.2.21

- Added full challenge-focused Graven Deep dataset.
- Covered Mzugru, Security Drone; The Euphotic Gatekeeper; Xzyviian, Defense Crawler; Varzunon; Chralzak, Sphere 9402-A; and Zelvraak the Unbreathing.
- Kept Dwemer secret-boss puzzle/path/buff notes in summaries only, with fight-only mechanics under mechanics.
- Added move/cast labels for Lightning Strikes, Immunity Shield/Pylons, Pangrit Burrows/Poison Synergy, Mirror Image, Fire Cone, Mortar Barrage, Skeletal Sacrifices, Stomp, Pound/Line AOEs, Drowning Waters/Sea Orbs, Terrified, Split/Illusory Specters, Sundered Soul, The Afterlife/Banished, Flesh Abomination, Inferno, and Tombstone skeletons.

## 0.2.20

- Added full challenge-focused Earthen Root Enclave dataset.
- Covered Scalded Roots, Corruption of Stone, Lutea, Corruption of Root, Jodoro, and Archdruid Devyric.
- Kept optional-boss activation and elemental-orb buff notes in summaries only, with fight-only mechanics under mechanics.
- Added move/cast labels for Fireball, Meteors, Ground Slam, Stone Atronachs, Water Jet, Ice Ring, Root Nodes, Summon Distributaries, Root Infection, Mind Blast, Laser Beams, Lightning Pillars, Rock Totems, Fire Wolves, Lightning Breath, and Malicious Mauling.

## 0.2.19

- Added full challenge-focused Shipwright's Regret dataset.
- Covered Lost Maiden, Foreman Bradiggan, Shrouded Axeman, Nazaray, Storm-Cursed Sailor, and Captain Numirril.
- Kept tormented-spirit find/buff notes in summaries only, with fight-only mechanics under mechanics.
- Added move/cast labels for Chilling Howl, Pillar Burst, Outburst, Soul Bash, Paralyzing Fear, Haunting Charge, Inferno, Possession, Soul Bomb, Vanish, Bludgeon, Liquidate, Kindred Spirit, Terrorizing Timber, Overcharge, Thunderstorm, Drown, Spout, Waves, Retch, Bile Pool, and Drowned Hulk.

## 0.2.18

- Added full challenge-focused Coral Aerie dataset.
- Covered Sword Guardian, Maligalig, Staff Guardian, Sarydil, Shield Guardian, Varallion, and Z'Baza.
- Kept covenant/portal/unlock notes in summaries only, with fight-only mechanics under mechanics.
- Added move/cast labels for Cleave Shock, Barbed Lance/Double Strike, Storm Cell, Surging Waters/Building Static, Dagger Throw, Clone Split, Ascendant Stormshapers, Coalescing Shadows, Mind Link, Gryphon Summon, Lightning Storm, Kargaeda, Mind Blast, Mark Orbs, and Tentacles.

## 0.2.17

- Added full challenge-focused The Dread Cellar dataset.
- Covered Purgator, Scorion Broodlord, Undertaker, Cyronin Artellian, Grim Warden, and Magma Incarnate.
- Kept Daedric Flame/brazier/trapdoor/crystal unlock info and Accession buff details in summaries only; mechanics remain boss-fight-only.
- Added move/cast labels such as Agonymium Stone, Excruciating Expectoration, Dread Surge, Soulstorm, Arresting Bolt, Incarnate Outburst, Path of Fire, Tornado Wall, Unstable Blitz, and Dancing Flames.

## 0.2.16

- Added full HM-focused Red Petal Bastion dataset.
- Covered Wraith of Crows, Rogerain the Sly, Spider Daedra / Anya, Artifact Bearers, Grievous Twilight / Nagaia, and Prior Thierric Sarazen.
- Kept secret-boss rune/buff/path notes in summaries; mechanics remain fight-only.
- Added move/cast labels such as Crow Storm, Unspeakable Void, Belly Buster, Chaos Gate, Aftershock, Rockslide Rush, Leki's Backslash, Opalescent Impale, Duplicate Wall, Blade Tempest, and Shadow's Ire.


## 0.2.14

- Added full challenge-run Castle Thorn dataset.
- Covers Dread Tindulra, Blood Twilight, Vaduroth, Talfyg, and Lady Thorn.
- Kept optional achievement context such as Hound Pound, Four by Four, Let Sleeping Gargoyles Lie, Taking Turns, and Guardian Preserved in summaries only.
- Added fight-only mechanics with All/Tank/Healer/DPS text and cast labels such as Fire Breath, Stomp, Stun Jump/Pin, Dark Barrage, Ichor/Blood Pool, The Reaping/Sickle Toss, Virulent Viscera, Annihilate, Blood Guardian, Blood Scavenger, and Moving-Light Execute.


## 0.2.13

- Added full challenge-banner Stone Garden dataset.
- Covers Exarch Kraglen, Stone Behemoth, and Arkasis the Mad Alchemist.
- Includes fight-only mechanics, role-specific notes, paste-ready All/Tank/Healer/DPS text, and cast labels for Blood Rage, Fault Line, Essence Explosion, Fire/Ice Smash, Magicka Drain, Caustic Cannonade, Volatile Gloomspores, Shock Emitters, Murderous Mark/Husk Swap, Lightning AoE/Pin, Conal Lightning, Mage's Wrath, Whirlwind, and Charge.
- Kept alchemy buff/vitalizer/achievement context in summaries only.


## 0.2.12
- Added full challenge-focused Unhallowed Grave dataset.
- Included all main bosses and optional secret bosses: Nabor the Forgotten, Hakgrym the Howler, Keeper of the Kiln, Voria the Heart-Thief, Eternal Aegis, Ondagore the Mad, Voria's Masterpiece, and Kjalnar Tombskald.
- Kept secret unlock/path information in summaries only; mechanics remain boss-fight-only.
- Added cast/move labels such as Chilling Comet, Bone Sunder, Blazing Kiln, Ring of Blades, Escape, Oozing Slam, Grasping Bomb, Runic Spin, Summon Skeletons, and Awakening/Tzirzhalir.

## 0.2.11

- Added complete challenge-focused Icereach dataset.
- Covered Kjarg the Tuskscraper, Sister Skelga, Vearogh the Shambler, Stormborn Revenant, and Mother Ciannait / Icereach Coven.
- Added final challenge notes for wicker totem, active sister/shield rotation, Storm Surge interrupts, sister-specific add packages, and Sundered Sky execute.
- Added UESP-style cast labels such as Frost Slam, Frost Scrape, Flame Swirl, Summon Stranglers, Summon Undead, Thunderous Pursuit, Avalanche Strike, Unending Storm, Storm Surge, and Sundered Sky.

## 0.2.10

- Added complete HM-focused Lair of Maarselok dataset.
- Covered Selene's Claws/Fangs, Azureblight Lurcher, Azureblight Cancroid, Maarselok on the Perch, and Maarselok in the Roost.
- Added final Scourge Seed / Majority Wins, Wicked Bonds, Sweeping Breath / Azure Blaze, Charge / Lunge, Putrid Stalk, and objective-fight notes.

## 0.2.9

- Added full Moongrave Fane challenge-focused dataset.
- Added all 5 Moongrave Fane boss encounters: Risen Ruins, Dro'zakar, Kujo Kethba, Nisaazda + Grundwulf, and Grundwulf.
- Included dungeon-wide Hemo Helot and Sliding Stone/cube guidance in summaries, with fight-only mechanics under each boss.
- Added All/Tank/Healer/DPS text and cast labels such as Boulder Storm, Consume Hemo Helot, Sangiin Shield, Fanning the Flames, Volcanic Geyser, Corpuscle Cannonade, Summon Sangiin's Thirst, Blooded Unrelenting Force, Giant Bat, Summon Shackle, Dying Breath, and Ghastly Wound.

## 0.2.8

- Added complete hard-mode-focused Depths of Malatar dataset.
- Covered The Scavenging Maw, The Weeping Woman, The Dark Orb, King Narilmor, and Symphony of Blades.
- Included Dictate of the Lady of Light challenge context, Dark Orb color-system training, King Narilmor reflection/Tharayya handling, and Symphony colored-orb/Auroran/Colored Rooms mechanics.
- Added move/cast labels such as Hunting Proboscis, Glaciation, Gelid Globe, Aegis of Meridia, Sunburst, Ice Pillar, Purifying Light, Dawnbreaker, Auroran Phalanx, Meridia's Light, Decrepify, and Purification.

## 0.2.7

- Added complete hard-mode-focused Frostvault dataset.
- Covered Icestalker, Warlord Tzogvin, the Vault Protector, Rizzuk Bonechill + Avalanche, and the Stonekeeper.
- Included challenge-run Stonekeeper Veracity Verifier notes, skeevaton role assignments, Searing Rays positioning, Deep Freeze/Shatter spread, and move/cast labels from UESP/guide sources.

## 0.2.6

- Added complete hard-mode-focused March of Sacrifices dataset.
- Covered The Wyrd Sisters, Aghaedh of the Solstice, Dagrund the Bulky, Tarcyr, and Balorgh.
- Added move/cast labels, role-specific notes, and paste-ready snippets matching the UI text.

## 0.2.5

- Added full hard-mode-focused Moon Hunter Keep dataset.
- Added all five encounters: Jailer Melitus, Hedge Maze Guardian, Mylenne Moon-Caller, Archivist Ernarde, and Vykosa the Ascendant.
- Included move/cast labels such as Bloodmoon's Mercy, Moonlit Rage, Bloody Geyser, Bloody Execution, Lurcher Roots, Strangler Snare, Prodding Shock, Resonating Pools, Shock Blast, Symbols of Xarxes, Fear Totem, Pounce, and The Pack.
- Kept unlock/context in summaries and fight-only mechanics in mechanic sections.

## 0.2.4
- Added full hard-mode-focused Scalecaller Peak dataset.
- Included Orzun + Rinaerus, Doylemish Ironheart, Matriarch Aldis, Plague Concocter Mortieu, and Zaan the Scalecaller.
- Added combat-log/guide-style cast labels such as Terrorizing Tremor, Vicious Shard, Stony Gaze, Death's Gaze, Plague Well, Taking Aim, Fire Cage, Winter's Purge, Pestilent Breath, and Spellbreaker.

## 0.2.3

- Added full Fang Lair hard-mode-focused dataset.
- Added all 5 Fang Lair boss encounters: Lizabet Charnis, Cadaverous Menagerie, Caluurion, Ulfnor + Sabina Cedus, and Orryn the Black + Thurvokun.
- Included challenge-banner final-boss flow: Orryn interrupts, poison placement, scarab/shalk control, Animus Crystals, Bone Colossus spawns, ghost walls, Life Ward / Plague Breath, and execute pacing.
- Included move/cast labels such as Death Grip, Belch of Bile, Soul Cage, Soul Rupture, Nature's Clutches, Spectral Chains, Haunting Spectre, Degenerative Acid, Animus Crystal, Wraith Thralls, and Plague Breath.

## 0.2.2

- Added full Falkreath Hold hard-mode-focused dataset.
- Added all 5 Falkreath Hold boss entries: Morrigh Bullblood, Siege Mammoth, Cernunnon, Deathlord Bjarfrud Skjoralmor, and Domihaus the Bloody-Horned.
- Included Domihaus challenge-banner pillar coordination, atronach waves, execute shield/add pressure, and role-specific notes.
- Added cast/ability labels such as Basilisk Powder, Catapult, Charge, Sweeping Tusks, Stomp, Pull of the Underworld, Aspect of Winter, Deathlord's Fury, Fiery Blast, Ring of Fire, Grovel, and Pillars of Nirn.

## 0.2.1

- Added full Bloodroot Forge hard-mode-focused dataset.
- Added all 6 Bloodroot Forge boss entries: Mathgamain, Caillaoife, Stoneheart, Galchobhar, Gherig Bullblood + Attendants, and Earthgore Amalgam.
- Included dungeon-level warnings for Firehide chains, Earthgorer volcano holes, Fire Shalk Lava Balls, Strangler poison, Molten Nirncrux, and final-boss side-synergy limitations.
- Used cast/ability labels such as Lunge, Nature's Preservation, Wave of Earth, Fire Bloom, Mantle Breaker, Scorched Earth, Burnt Offering, Anvil Cracker, Drown in Flame, Groundshaker, Falling Debris, and Summon Clones.

## 0.2.0

- Added full Black Gem Foundry hard-mode-focused dataset.
- Added all 6 Black Gem Foundry bosses: Prospector Lyrakta, Quarrymaster Saldezaar, Gemcarver Hynax, Black Gem Monstrosity, Misura, and High Soulbinder Vykand.
- Included dungeon/boss summaries for optional Superior Daedric Essence and wrist-cuff buff system.
- Added role-specific All/Tank/Healer/DPS text and cast labels for major mechanics such as Rupture, Seismic Splinters, Soul Focus, Soulbinding Slam, Refraction Color Puzzle, and Ominous Vision / Annihilation.

## 0.1.10

- Added `Docs/DATASET_STYLE_GUIDE.md` with the standardized rules for future dungeon/trial/arena datasets.
- Added `Docs/DUNGEON_MODULE_TEMPLATE.lua` as a non-loaded Lua template for new mechanic modules.
- Documented source rules, HM-only mode policy, summary/mechanic separation, tag usage, move-name priority, role text standards, paste-splitting rules, and QA checklist.

## 0.1.9

- Added explicit boss attack / move labels to Black Drake Villa mechanics where the mechanic is tied to a named cast or death-recap-style attack.
- Mechanic titles and paste prefixes now use the same move/cast label helper, so the name you see in the UI is the name pasted to chat.
- Increased mechanic label length support so combined names like Mind Blast / Spectral Indriks are not aggressively truncated.
- Added a reusable `casts` data field for future dungeon modules.

## 0.1.8

- Moved Black Drake Villa secret-boss unlock/path instructions out of the mechanics list and into the relevant boss summaries.
- Removed Secret Unlock mechanics from Avatar of Zeal, Avatar of Vigor, Avatar of Fortitude, and Sentinel Aksalaz.
- Mechanics sections now contain boss-fight behavior only; route/unlock/buff notes stay in dungeon or boss summaries.
- Expanded secret-boss and Sentinel summaries so the removed unlock information is still visible and pasteable from the summary area.

## 0.1.7

- Rebuilt Black Drake Villa as the first polished data module.
- Removed player-chat color codes permanently; paste lines are plain text.
- Changed role wording from Heal to Healer and paste tag from [HEAL] to [HEALER].
- Increased snippet budget so text only splits when it actually needs to.
- When a mechanic splits, only the first line gets the mechanic prefix/tag; continuation lines stay clean.
- Mechanic UI now displays the exact same paste-ready lines used by the paste buttons.
- Mechanics rows are taller with larger text boxes to prevent overlap.
- Scrollbar is now a clean visual indicator; mechanics scrolling is mouse-wheel based.
- Black Drake Villa text now avoids mixed mode wording and is written as a dedicated challenge-banner dataset.

## v0.2.15

- Added complete challenge-focused dataset for The Cauldron.
- Included Oxblood the Depraved, Taskmaster Viccia, Molten Guardian, Lyranth's Prison, and Baron Zaudrus.
- Added move/cast labels for Oxblood globs/cage, Viccia traps/chains/Execute, Molten Guardian channels/fiends, Lyranth catalyst/add waves, and Zaudrus Ash Vents/Cold-Flame rock control.
