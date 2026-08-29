Curved Resource HUD 0.9.0 REMAINING CLASS TRACKERS TEST BUILD

Upload CurvedHUD as one folder with CurvedHUD.addon at its root.
The package contains exactly one .addon manifest, as required by the console uploader.

Settings libraries are optional by design:
- LibAddonMenu-2.0
- LibHarvensAddonSettings (listed as LibVotans in the Bethesda.net console store)

If neither library loads, the HUD still renders. Chat commands:
  /curvedhud preview  - toggle fixed test values
  /curvedhud debug    - toggle diagnostic logging
  /curvedhud          - show version/load status

0.7.0 includes ESO-style gradient fills for Health, Stamina, and Magicka. The
"Show default ESO resource bars" setting can hide the stock player resource
frame; while hidden, ESO's self-buff row moves down into the available space.

Expected startup chat line:
  [CurvedHUD] Loaded 0.9.0-test; HUD, shield, and trackers created

0.9.0 completes the initial class-tracker framework with dedicated expandable
Dragonknight, Nightblade, Templar, and Necromancer submenus. Each tracker is
off by default and remains per-character, with its own position and color.
The new families cover actionable damage-over-time effects, buffs, defenses,
ground effects, summons, and stack windows. Stone Giant, Seething Fury, Grim
Focus, and Nothing Wasted include stack-count support. All new class families
use the shared resilient icon chain: equipped skill, ability data, learned
skill, live event artwork, then the last successfully cached icon.
Settings are grouped beneath blue character-specific section headers: Global
Timers, Class Timers, Weapon Timers, and Guild/Vampire/Werewolf Timers. Every
expandable tracker submenu beneath these headings stores its choices per character.

0.7.0 tracker framework additions:
- selectable standardized Major buff in the lower-left outside slot
- independent Thin/Thick styles for inside and outside timer slots
- color presets for the current Major buff, Balance, and Bound Aegis timers
- reusable inside/outside timer positions in all four HUD corners
- stack-count labels prepared over every tracker icon
- separate font-size controls for resource values and percentages
- revised inside/outside thick curves that follow the Health radius more closely
- optional Balance tracker under Global Trackers, with selectable slot and color
- optional Bound Aegis tracker under Sorcerer Trackers, with selectable slot and color
- per-character Major-buff and individual tracker choices; shared HUD geometry remains account-wide
- flattened tracker titles for console-safe settings controls
- global inside/outside thickness controls moved into the shared layout settings
- clean semicircular timer ends and a small inward adjustment for Thick timers
- corrected console dropdown display/internal-value mapping for tracker positions
- automatic repair of invalid position values saved by 0.6.1/0.6.2
- separately tuned upper-outside and lower-outside Thin timer geometry
- canonical lower-left curves mirrored vertically for upper slots and horizontally for right slots
- approved lower-left Balance geometry reused for every inside Thin tracker
- wider, more curved outside Thin geometry and closer right-side Thick placement
- resource-value visibility settings moved above the optional tracker controls
- inner Thick positions shifted farther inward without changing their curves
- outer Thin radius reduced and shifted inward, especially at its far endpoint
- both lower-right Parallel slots moved closer to the resource bars
- Stacked right slots now select their parent by upper/lower quadrant before radial placement
- corrected the visually reversed upper/lower parent controls in Stacked mode
- reversed inner Thick offsets toward screen center on both sides
- retained the outer Thin midpoint while drawing its far endpoint toward the resource curve
- moved inner Thick three pixels back from its over-corrected center position
- tightened the inner Thick radius while preserving its mirrored geometry
- reshaped outer Thin so its center-side end moves outward and its far end hugs the resource arc
- moved upper-right outside icons farther outward and lower-right inside icons farther inward
- relaxed inner Thick and outer Thin to intermediate radii while preserving midpoint anchors
- replaced skill-specific icon offsets with consistent mirrored inside/outside icon placement
- upper-inner icons moved eight pixels closer to their tracker/stat bars
- upper-outer icons moved sixteen pixels farther horizontally from screen center
- toggleable Bound Armaments stack/duration tracker using any of the eight timer slots
- per-character Bound Armaments position and color settings
- toggleable Crystal Fragments proc-ready alert with Top/Right/Bottom/Left/Center presets
- dual Crystal Fragments detection through effect 46327 and proc action ID 114716
- reusable HUD-relative proc-alert positioning framework for future class proc skills
- Crystal Fragments proc-size slider; the alert inherits the HUD's combat and out-of-combat opacity
- rotating gold/white Bound Armaments ready highlight at four weapon stacks
- toggleable Critical Surge timer using its unique self-buff
- toggleable Vibrant Shroud, Encase, and Shattering Spines timer with a 10-second cast fallback
- Vibrant Shroud timer prefers the slotted/cast skill artwork over Minor Vitality artwork
- guaranteed overlay-layer gold/white Bound Armaments ready border at four stacks
- right-side inside and outside timer bars moved closer to their resource arcs
- per-character Soul Burst and Ulfsild's Contingency trackers in a dedicated Scribing Skills section
- configurable position, color, and script-dependent duration for both scribing timers
- current cast artwork is retained for each character's scribed variant
- bundled console-safe icons for Soul Burst and Ulfsild's Contingency
- bundled individual icons for Vibrant Shroud, Encase, and Shattering Spines
- automatic scribed duration lookup from the equipped crafted ability, with the
  per-character duration setting retained as a fallback for unsupported scripts
- optional global imminent-expiration alerts: positive timers turn red and gain
  a pulsing red icon border at three seconds; negative Balance is excluded
- toggleable trackers for all eleven duration-capable Scribing grimoires, each with a bundled
  console-safe icon, one of eight positions, a color, and automatic configured
  duration lookup with a per-character fallback (the persistent Banner Bearer
  toggle is intentionally excluded because it has no recast-duration window)
- new Warden section with Betty Netch/Blue Betty/Bull Netch, Swarm/Fetcher
  Infection/Growing Swarm, and Scorch/Deep Fissure/Subterranean Assault
- Shalk timing covers both eruptions: 9 seconds for Scorch/Deep Fissure and
  6 seconds for Subterranean Assault before the suggested recast
- added Impaling Shards/Gripping Shards/Winter's Revenge, Lotus Flower/Green
  Lotus/Lotus Blossom, Healing Seed/Budding Seeds/Corrupting Pollen, and
  Crystallized Shield/Shimmering Shield/Crystallized Slab tracker families
- new Warden families resolve the equipped or learned morph's ESO icon at run time
- expanded Sorcerer tracking for Daedric Curse/Prey/Haunting Curse, Lightning
  Splash/Flood/Liquid Lightning, Volatile Familiar and Twilight Tormentor
  activations, Conjured Ward, Lightning Form/Hurricane, Dark Exchange, and
  Daedric Mines families; ultimate abilities remain intentionally excluded
- all definition-driven trackers now share a defensive icon chain: bundled
  artwork, equipped-slot texture, ability-ID texture, learned-skill texture,
  live event artwork, and finally the last valid cached texture
- added optional duration tracking across all six standard weapon lines:
  Two Handed, One Hand and Shield, Dual Wield, Bow, Destruction Staff, and
  Restoration Staff
- added optional Fighters Guild, Mages Guild, Undaunted, Psijic Order,
  Assault, Support, armor, Soul Magic, Vampire, and Werewolf timers
- reorganized customization in the order Class Skills, Weapon Skill Lines,
  then Guild / Other Skill Lines; each scribing grimoire now appears beneath
  the weapon, guild, Alliance War, or Soul Magic line that grants it
- instant-only abilities, passive-only bonuses, permanent toggles, and all
  ultimate abilities are intentionally excluded from selectable timers
- corrected the preceding weapon/guild build's release designation to 0.8.3
- added a dedicated Arcanist section with per-character position, color, and
  enablement settings for ten duration-based skill families
- added a paired Crux tracker occupying one selectable quadrant: the outside arc
  and icon show 1-3 stacks while the matching inside arc counts down the live
  expiration time reported by ESO
- Crux is read defensively from the player's live buff stack and uses ESO's
  Crux artwork when available, with the shared equipped/learned/cached icon chain
- Arcanist duration trackers cover Abyssal Impact, Tome-Bearer's Inspiration,
  The Imperfect Ring, Runic Jolt, Runespite Ward, Fatewoven Armor, Runic
  Defense, Rune of Eldritch Horror, Chakram Shields, and Arcanist's Domain
- customization now prefers LibAddonMenu-2.0 when available so every Global,
  class, weapon, guild, Alliance War, armor, world, and Scribing subsection is
  a real collapsible submenu instead of an always-expanded wall of controls
- LibHarvens/LibVotans remains a functional fallback and uses its native section
  controls because that provider does not expose nested child containers
- Light, Medium, and Heavy Armor trackers are consolidated into one Armor section
- Wield Soul and its Scribing fallback controls now appear under Soul Magic

Diagnosis of the silent v0.2 result:
The prior ZIP was not recoverable from the referenced task, so exact line-level attribution
is impossible. A complete no-HUD/no-menu result most strongly indicates that its add-on-loaded
handler never completed, commonly due to a manifest folder/name mismatch, a hard missing
dependency, an initialization-time Lua error, or controls anchored/hidden before player activation.
This build removes those failure modes by using optional dependencies, exact add-on-name gating,
protected initialization, explicit top-level controls, player-activation refresh, periodic resource
refresh, and visible chat/error reporting.

Packaging note: upload the CurvedHUD folder itself. Do not add an extra directory around it.
