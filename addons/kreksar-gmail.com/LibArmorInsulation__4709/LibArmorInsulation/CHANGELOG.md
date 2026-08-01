# LibArmorInsulation — Changelog

Full version history for LibArmorInsulation. See README.md for current features, installation, and usage.

---

### 2.7.11
- Manifest `## APIVersion` updated to `101050 101051`, covering the newly
  released 101051 alongside the previous 101050.

---

### 2.7.10
- **The Active Overrides list in the Settings panel now shows the resolved
  name next to each override key** — e.g. `style_10 (Nord) → tier 60 ...`
  instead of just `style_10 → tier 60 ...`. Names resolve the same way as
  the Current Insulation display: armor styles via the game's own
  `StyleNameById` map, outfit/costume/polymorph collectibles via
  `GetCollectibleName` — both independent of whether that ID has a curated
  entry in LibArmorInsulation's data tables. A key the game itself can't
  name (e.g. an ID from a since-removed collectible) just shows the key
  alone, as before.

---

### 2.7.9
- **Fixed malformed color codes in the Manual Overrides panel's Tier Ladder
  reference text.** Every row's `|c` color code was 8 hex digits instead of
  the 6 ESO's chat color format actually reads (e.g. `|cFF4FC3F7`); the
  game consumed the first 6 as the color and displayed the other 2 as
  stray literal text right before the tier number (e.g. "F7 -10", "FA 0",
  "C5 20"). All codes are now proper 6-digit hex, so that stray text is
  gone.
- **Recolored the Tier Ladder gradient** to run cold-blue → white → hot-orange
  across the eleven tiers, with tier 50 (the neutral tier) now exactly white:
  `-10` deep blue, fading through lighter blues to `40`, `50` white, then
  warming through oranges to `90` deep orange — replacing the previous
  ad hoc color choices.

---

### 2.7.8
- **The Current Insulation display (Settings panel and `/insulation`) now
  shows the actual armor style, outfit collectible, or costume/polymorph
  name for every slot** — even when it's not one of the entries
  LibArmorInsulation's own data tables recognize. Armor style names come
  from the game's own `GetItemStyleName`/`StyleNameById` map, and outfit
  and costume/polymorph names come from `GetCollectibleName` — both are
  resolved directly from the live game data regardless of whether the
  ID has a curated entry, so an unrecognized item still shows what it
  actually is instead of just an ID and a generic fallback material/tier.
  `GetInsulationBreakdown()`'s per-slot `name` field is now populated for
  outfit-collectible and costume/polymorph slots (armor slots' `styleName`
  was already populated this way); only a slot the game itself can't name
  at all still falls back to "?".

---

### 2.7.7
- **Removed debug-style flavor text from 11 promoted-outfit-style entries**
  in `OutfitStyles` (collectible IDs 4804, 4798, 4800, 9746, 7195, 8786,
  11819, 11818, 11820, 11851, 5309). Their `flavorNote` previously read
  "Unidentified outfit style; baseMaterial/coverage reconstructed only to
  reproduce a verified override tier of N" — internal authoring commentary
  that was leaking into the Settings panel's Current Insulation display via
  the per-slot flavor note. The tier values themselves are unchanged (they
  were, and remain, correct); only the note text was cleared. The reasoning
  is still documented in a code comment above the table for maintainers.

---

### 2.7.6
- **Consolidated to a single global.** Previously this addon defined four
  separate globals (`LibArmorInsulation`, `LibArmorInsulationData`,
  `LibArmorInsulationCalc`, `LibArmorInsulationSettings`). Only
  `LibArmorInsulation` remains global now; the other three are attached to
  it as `LibArmorInsulation.Data`, `LibArmorInsulation.Calc`, and
  `LibArmorInsulation.Settings`. All internal references across all four
  Lua files were updated accordingly.
- **SavedVariables are now server-dependent.** `ZO_SavedVars:NewAccountWide`
  previously passed `nil` for the namespace argument, so EU, NA, and PTS all
  read and wrote the *same* account-wide save table — logging into a
  different server would silently overwrite another server's overrides and
  caches. Now namespaced by `GetWorldName()` (`"EU Megaserver"` /
  `"NA Megaserver"` / `"PTS"`), so each server keeps its own data.
  **One-time effect of this fix:** overrides/caches set before this version
  will appear "reset" the first time you load each server after updating —
  they're still in the SavedVariables file under the old shared location,
  just no longer read from there.
- **Slash commands are now registered inside `EVENT_ADD_ON_LOADED`,
  after SavedVariables are loaded**, instead of at file-load time. Every
  slash command handler reads `Lib.sv`, so registering them any earlier
  risked a nil-index Lua error if a command were ever invoked before that
  event fired. The handler functions themselves are unchanged; only the
  timing of their `SLASH_COMMANDS[...]` registration moved.
- Manifest cleanup: `## APIVersion` trimmed to only the latest (101050).
- Split the changelog out of `README.md` into this file, and reformatted
  `README.md` into BBCode for the ESOUI addon description page.
- The `README.md` Dependencies section no longer lists minimum version
  numbers — it just tells users to install the newest version of each
  dependency.

---

### 2.7.5
- **Fixed the settings panel's author/version fields**, which were still
  the literal placeholder text `"YourName"` and a hardcoded `"1.0.0"` —
  never actually updated even after the `## Author` manifest field itself
  was corrected. The panel now reads `author = "@Kreksar5 and Claude.ai"`
  and `version = LibArmorInsulation.VERSION`, and the library's internal
  `ADDON_VERSION` constant (previously stale at `"2.7.0"`) is kept in sync
  with the manifest `## Version` going forward.

### 2.7.4
- **Promoted 4 costumes and 11 outfit styles from verified player overrides**
  into the hard-coded data tables (`CostumeInsulationById` and
  `OutfitStyles`), so these no longer rely on a per-account manual override
  or auto-rated cache guess:
  - `CostumeInsulationById` gained 4 entries (collectible IDs 12717, 1101,
    12719, 286) with their confirmed `totalInsulation` values, each
    superseding a previous auto-rated cache guess.
  - `OutfitStyles` gained 11 entries (collectible IDs 4804, 4798, 4800,
    9746, 7195, 8786, 11819, 11818, 11820, 11851, 5309). The final tier for
    each is confirmed correct (set manually by a player after observing the
    outfit in-game), but since this table stores `baseMaterial`/`coverage`/
    `flavorBonus` rather than a direct tier, those fields were chosen only
    as the minimal combination that reproduces the confirmed tier — they
    are **not** an independent material assessment, and the collectibles'
    actual names/appearances haven't been looked up yet. Flagged
    accordingly in each entry's `flavorNote`.

### 2.7.3
- **Standardized the author credit** to `@Kreksar5 and Claude.ai` in the
  `## Author` manifest field and this README's byline, and named Claude.ai
  specifically (rather than generic "AI assistance") in the manifest
  description and the AI-assistance disclosure above, matching the crediting
  convention used across this addon's companion libraries.

### 2.7.2
- **Corrected the `## Author` manifest field**, which was still the literal
  placeholder text "YourName" left over from the manifest template — never
  actually filled in. Fixed to the real author.

### 2.7.1
- **Full API audit against the official ESOUI API 101050 documentation.**
  Every function call, method call, and constant referenced across the
  library was cross-checked against the API doc and, where the doc didn't
  cover it (manager singletons, third-party libraries), against the live
  ESOUI source. No invalid or deprecated API usage found — `ZO_OUTFIT_MANAGER`
  and its `GetOutfitManipulator`/`GetSlotManipulator`/`GetCurrentCollectibleId`
  chain, and the `LibAddonMenu`/`LibSavedVars` calls, are all legitimate and
  correctly used. No code changes required.

### 2.7.0
- **Override editor redesigned around explicit Layer/Slot dropdowns.**
  Replaced the auto-detected "currently active item" list (and the 2.6.3
  background poll that tried to keep it in sync) with two small, permanently
  static dropdowns: **Layer** (Costume/Polymorph, Outfit, Armor) and **Slot**
  (Head/Shoulders/Chest/Hands/Waist/Legs/Feet, disabled for Costume/Polymorph
  since that's whole-body). Picking either does a FRESH live lookup at that
  exact moment via three new independent Calculator functions —
  `Calc.ResolveCostumeOrPolymorph()`, `Calc.ResolveOutfitSlot()`,
  `Calc.ResolveArmorSlot()` — each of which reads live game state directly
  and completely ignores ESO's usual visual precedence. This means you can
  now inspect (and override) your Armor style on a slot even while a costume
  is actively displayed instead, or check what your Outfit has set for a
  slot regardless of what's currently showing. If a layer/slot has nothing
  active (e.g. Costume picked while no costume is worn, or an empty armor
  slot), a placeholder tier and an explanatory note are shown instead of
  leaving the fields blank. A **Refresh Preview** button re-runs the same
  live lookup for whenever gear changes without touching either dropdown.
- **Root-cause bug fix: Settings panel re-registration was silently a no-op.**
  The options table powering the whole Settings panel was declared as
  `local optionsTable = { ..., func = function() ... optionsTable ... end, ... }`.
  In Lua, a local variable's scope begins only AFTER its declaration
  statement finishes, so any closure written INSIDE that table constructor
  which refers to `optionsTable` — which is exactly what the Refresh/Apply
  Override/Reset buttons did to push a rebuilt panel back to LibAddonMenu —
  actually resolved to a global of that name (`nil`), not the local table
  being built. Every one of those buttons had therefore been calling
  `LAM:RegisterOptionControls(Settings.panelId, nil)` this whole time. This
  is almost certainly the real reason the Settings panel never seemed to
  refresh, going back to before the tier-system rewrite. Fixed by
  forward-declaring `local optionsTable` on its own line before assigning the
  table to it, which is the standard Lua idiom for self-referencing
  structures; verified with a minimal isolated reproduction before and after
  the fix, and with an end-to-end test through the actual button handlers.

### 2.6.3
- **Background auto-refresh for the "currently active item" dropdown.**
  Previously the list only reflected equipped gear/costume/outfit at the
  moment the addon loaded, or whenever Refresh/Apply Override/Reset was
  pressed — changing costume or outfit mid-session left it stale until one
  of those was clicked. Added a lightweight poll (`EVENT_MANAGER:RegisterForUpdate`,
  every 2 seconds) that compares a cheap fingerprint of "what's currently
  resolving" (source + costume/polymorph ID + each slot's collectible/style
  ID) against the last-seen one, and only pushes a rebuilt options table back
  to LibAddonMenu when something actually changed. This deliberately avoids
  hooking any specific ESO gear/costume-changed event, since there's no single
  confirmed event that reliably fires for every costume/outfit/armor change
  alike and this addon's data tables hold to a no-unverified-API-constants
  standard — polling a signature built from data this file already computes
  gets the same result using only a bedrock-stable API. Updates land within
  ~2 seconds of a costume/outfit/armor change, whether or not the Settings
  panel happens to be open at the time.

### 2.6.2
- **Bug fix: costume/polymorph misclassification after applying an override.**
  Costumes and polymorphs share the same override key namespace
  (`costume_<id>`) and the same detection path (`GetActiveCollectibleByType`),
  since ESO has no separate `COLLECTIBLE_CATEGORY_TYPE_POLYMORPH`. A prior fix
  that let polymorph overrides win over the data table accidentally checked
  `if polymorphOverride or polymorphEntry then` — meaning applying an override
  to a *plain costume* made it get misclassified as a polymorph on the very
  next lookup (`result.source` flipped from `"costume"` to `"polymorph"`, and
  the breakdown slot key flipped from `"[Costume]"` to `"[Polymorph]"`). This
  is what caused the "Prefill from currently active item" dropdown in Settings
  to mislabel a costume as a "Polymorph" once you'd set an override on it.
  Classification now comes ONLY from table membership
  (`PolymorphInsulationById`/`PolymorphInsulation`), independent of whether an
  override exists; the override still applies to the resolved tier either way.
  The insulation *value* was never wrong — only the source/label — but the
  label feeds directly into the prefill dropdown and `/insulation`/`/costumeids`
  output, so this is worth updating for.

### 2.6.1
- **Override editor prefill.** Added a "Prefill from currently active item"
  dropdown above the Override Type/ID fields, listing whatever costume,
  polymorph, outfit piece, or armor style is *actually resolving right now* —
  using the exact same precedence `GetInsulationBreakdown()` uses (polymorph/
  costume beats outfit beats worn armor; an outfit slot with no style set
  falls back to the armor style showing through). Picking an entry auto-fills
  Override Type, the ID field, and the Insulation Tier dropdown with that
  item's current resolved values, and shows the game's own display name
  (`GetCollectibleName()` for outfits/costumes, the resolved English style
  name for armor) so there's no need to cross-reference `/styleids`,
  `/outfitids`, or `/costumeids` by hand. "(manual entry)" remains available
  as the first choice for typing an arbitrary ID. The list refreshes whenever
  the panel opens, when **Refresh** is pressed, when an override is applied,
  or when overrides are reset.

### 2.6.0
- **Staggered tier system.** Replaced the free-floating 0–100 continuous scale
  with eleven fixed tiers, staggered in increments of 10 from -10 to 90
  (Magically Cooled, No Insulation, Minimal, Light, Coarse Light,
  Layered/Leather, Full Leather/Light Metal, Heavy Leather/Fur, Full
  Fur/Metal, Heavy Fur/Metal, Magically Heated). Every style, outfit piece,
  costume, and polymorph now resolves to one of these tiers via
  `Calc.SnapToTier()`. `-10`/`90` are reserved for entries flagged
  `magical = true` (Flame Atronach, Ice Wraith); everything else is clamped
  to the mundane 0–80 range before snapping.
- **Per-slot percentage adjustment.** A style/outfit piece's tier is now a
  full-body reference value; individual slots contribute a *percentage* of
  that tier based on body coverage (`slot_contribution = round(tier ×
  slotPercentage)`). `SlotCoverage`/`OutfitSlotCoverage` were rebalanced from
  summing to 0.90 up to exactly 1.00, so a full matching set reproduces its
  tier exactly as the total. Costumes and polymorphs are **not** slot-adjusted
  — their snapped tier is the total, unadjusted, since they're whole-body.
- **Dropdown-based override editor.** The Settings panel's "Insulation value"
  free-text editbox was replaced with an "Insulation tier" dropdown listing
  the eleven tiers by name, so an override can never drift off-tier.
  Programmatic `SetOverride()` calls snap any value passed in to the nearest
  tier instead of clamping 0–100; `nil` (not `0`) now clears an override,
  since `0` is a legitimate tier ("No Insulation").
- **Saved-variable migration (v4 → v5).** Existing overrides from the old
  0–100 scale are snapped onto the nearest tier on first load rather than
  being discarded, preserving prior manual tuning as closely as the new scale
  allows.
- **Bug fix:** `NearestMaterialForTarget()` (used by `/scanoutfitstyles` to
  guess a base material for unrecognized outfit pieces) was missing the 0.90
  slot-weight-sum factor present in every other full-body reference
  calculation in this file, so its reference numbers (fur=100, leather=55.6,
  ...) didn't match the documented full-set reference table (fur=90,
  leather=50, ...). Fixed to multiply by 0.90 like everywhere else.
- `GetInsulationForStyle()` now simply delegates to the new
  `Calc.GetStyleTier()` instead of duplicating the formula.
- Version bumped to 2.6.0 (`AddOnVersion: 8`), `SAVED_VARS_VERSION` to 5.

### 2.5.3
- **Corrected `LibAddonMenu-2.0` dependency floor**: was mistakenly bumped to
  `>=45` in 2.5.1, but LibAddonMenu's own manifest documentation shows `43`
  as the latest available version, not `45`. Fixed to `>=43`. The 2.5.1 entry
  below has also been corrected to reflect the right number.

### 2.5.2
- **"What addons cannot do" compliance verified** against the actual ESOUI
  rules text (previously unverifiable due to a fetch issue with that specific
  thread — see 2.5.1's note). Checked all 24 prohibited-behavior items: this
  addon doesn't touch the character-select/crown-store/scrying/Tribute UI,
  doesn't read other players' or NPCs' positions, doesn't change any visual
  effect/texture/sound/nameplate/camera/tooltip, doesn't move/cast/interact
  with anything, doesn't touch quickslot items, doesn't write outside
  `SavedVariables`, doesn't talk to external web services, and doesn't share
  data between players. It's a pure read-only calculator using documented API
  functions (the explicitly sanctioned "what addons could do" item #7), plus a
  settings panel and slash commands. **No code changes were required.**
  - Specifically confirmed: `CHAT_SYSTEM:AddMessage()`, used throughout this
    addon's slash commands, is the standard local-only system-message print
    and is **not** the prohibited "send messages to chat directly" behavior
    (that rule targets auto-sending player-authored text into channels other
    players see, e.g. simulating Enter on `/say` or guild chat — this addon
    never does that).

### 2.5.1
- **ESOUI release-rules compliance pass**, checked against the ESOUI "Please
  read: Before you release a new/update your addons" guidelines:
  - **AI-code disclosure added.** Per the rule requiring AI involvement to be
    named at the top of the addon description when the AI-written code/data
    hasn't been independently validated, added a disclosure to both the
    manifest `## Description` and the top of this README. Most of this
    addon's commands and data tables were built with AI assistance and are
    not yet confirmed working/performant in actual gameplay.
  - **Added the missing `## AddOnVersion` manifest tag.** Libraries need this
    so dependent addons can use `DependsOn: LibArmorInsulation>=N` version
    checks (the same mechanism this addon already uses for its own
    `LibAddonMenu-2.0` dependency). Starting value: `6` (one per tracked
    release so far); increment by 1 on every future release regardless of the
    semantic `## Version` string.
  - **`## APIVersion` updated** from the stale `101040` to `101049 101050`
    (current Live and PTS as of this pass), so the addon no longer shows as
    "Outdated" in-game.
  - **`LibAddonMenu-2.0` dependency floor bumped** from `>=33` to `>=43`,
    matching the version explicitly cited as current in the ESOUI rules
    thread at time of this pass. `>=` (rather than no version check) is
    required so the addon doesn't silently load against a pre-Summerset
    LibStub-only build of LAM.
  - **Reviewed for global variable leaks** — none found. The codebase already
    follows the recommended single-global-table pattern (`LibArmorInsulation`,
    `LibArmorInsulationData`, `LibArmorInsulationCalc`,
    `LibArmorInsulationSettings`), with all other identifiers declared `local`.
  - **Not independently verified this pass:** the "What AddOns must not do"
    rules thread (linked from the same guidelines post) could not be fetched
    to confirm compliance line-by-line at the time. **Resolved in 2.5.2** once
    the actual rules text was provided directly — see that entry for the
    confirmed result.

### 2.5.0
- **152 manually-researched costume entries added to `CostumeInsulation`.**
  Sourced from UESP search-result snippets (direct page fetches are blocked by
  UESP's bot detection, so coverage is best-effort rather than exhaustive —
  roughly 134 of ~308 total ESO costumes were found with usable description
  text; the rest were left for `/scancostumes` to auto-rate). Each entry's
  `flavorNote` carries a `[confidence: high|medium|low]` tag:
  - **high** — the source text stated an explicit material (e.g. "studded
    leather doublet," "Scaly Cloth Scraps," "Fighters Guild Cool-Weather Gear").
  - **medium** — a strong contextual/regional inference (e.g. a scout outfit
    explicitly tied to a named cold-climate zone).
  - **low** — a thematic guess with no explicit material cue in the source;
    these are reasonable starting points but are good candidates for manual
    re-verification, and `/scancostumes` will not override them since
    `CostumeInsulation` now outranks the scanner cache (see below).
  - One entry (**Old Orsinium Sentry**) corrects an earlier same-session guess
    after better source text was found later in the research pass.
- **Costume resolver priority reordered.** `CostumeInsulation[name]` (this
  manually-curated table) now outranks `sv.costumeCache` (the `/scancostumes`
  runtime cache) in `GetInsulationBreakdown()`. New priority order: user
  override → `CostumeInsulationById` → `CostumeInsulation[name]` →
  `sv.costumeCache` → `DEFAULT_COSTUME`. Previously the scanner cache outranked
  this table, which meant a manually-verified entry could be silently shadowed
  by a coarser auto-rated guess.
- **`OutfitStyles` gains a `Styles[name]` fallback.** Most outfit-style
  collectibles are account-wide unlockable versions of existing crafting
  motifs, just reached through a different ID space. `GetOutfitStyleData()`
  now resolves an unrecognized collectible ID's name via `GetCollectibleName()`
  (stripping a trailing `" Style"` suffix) and checks `Styles[name]` before
  falling back to the `/scanoutfitstyles` cache — so a style whose name matches
  an existing motif entry needs no new per-ID data at all. `/scanoutfitstyles`
  reports these as `[motif-match]` in its output.
- **9 new motifs added to `Styles[]`** to close a coverage gap found while
  researching outfit styles: Swordthane, Dark Executioner, Necrom Armiger,
  Order of the Lamp, Ancient Mirrormoor, Companion Revelry, Fharun Moonlight,
  Chosen of Anu, Chosen of Padomay. These are Crown Crate/Collector's Edition
  unlocks rather than world-found motif books, so they postdate the original
  "Motifs 1–129" coverage. Material assignments are UESP-sourced where the
  style explicitly resembles an existing entry (e.g. Dark Executioner →
  resembles Dark Brotherhood armor); the rest are lower-confidence thematic
  inferences from cosmic-duality/regional lore with no explicit material
  description available.

### 2.4.0
- **`/scancostumes` now scans description text, not just name.** `AutoRate`
  checks the costume's name against the keyword list first (names are usually
  more deliberately worded), then falls back to `GetCollectibleDescription()`
  flavor text if the name has no hit. Each cache entry now records a
  `matchSource` (`"name"`, `"description"`, or `"none"`) so genuinely unmatched
  entries — sitting on the generic 50 fallback — can be identified.
- **New `/scanoutfitstyles` command.** Outfit style pages had no auto-detection
  path at all (`OutfitStyles` was a hand-only stub table). This walks every
  unlocked outfit's 7 slots (same enumeration as `/outfitids`) and, for any
  collectible ID not already in `OutfitStyles`, keyword-rates it via name +
  description and writes a guessed `{baseMaterial, coverage, flavorBonus}`
  into the new `sv.outfitStyleCache`. `GetOutfitStyleData()` now checks this
  cache as a fallback before `OutfitStyles["DEFAULT"]`.
- **New `/costumesneedreview` and `/outfitstylesneedreview` commands.** Filter
  each respective cache down to entries where the keyword scan found no match
  in either name or description — a short worklist for manual UESP-backed
  overrides instead of scrolling the full scan output.
- **Shared keyword table.** `KEYWORD_RATINGS` and `AutoRate` were hoisted out
  of `/scancostumes` to file scope so `/scanoutfitstyles` draws from the same
  list — a new pattern only needs adding once.
- **Removed an unused dynamic costume-discovery path.** An earlier in-progress
  approach (`BuildCostumeKeywordMap()`, brute-force probing every collectible
  ID 1→N) was removed before release — it would have silently outranked the
  better-designed `/scancostumes` + `sv.costumeCache` resolution order. Not
  shipped in any prior version; mentioned here for the record.
- **Saved variables bumped to version 4;** v2/v3 saves are migrated
  automatically, preserving existing overrides and caches.

### 2.3.0
- **Name-keyed style table.** `LibArmorInsulationData.Styles` is now keyed by the
  English name returned by `GetItemStyleName()` (e.g. `["Nord"]`, `["Telvanni"]`)
  instead of raw `StyleItemIndex` integers.  This mirrors the zone-ID lesson: style
  integers can be reassigned between ESO API updates, but the English name is stable.

- **Runtime ID maps built at login.** `LibArmorInsulationCalc.BuildStyleIdMaps()` is
  called during `EVENT_ADD_ON_LOADED`.  It iterates `GetItemStyleName(i)` for
  `i = 1, GetHighestItemStyleId()` and populates two tables:
  - `LibArmorInsulationData.StyleIdByName` — `{ ["Nord"] = 5, … }`
  - `LibArmorInsulationData.StyleNameById` — `{ [5] = "Nord", … }`

  These maps are rebuilt every login from live game data, so any future ZOS
  reassignment of integer IDs is handled automatically without a data-table update.

- **Lookup chain in Calculator.**  All style lookups now follow:
  `styleId → StyleNameById[id] → Styles[name] → DEFAULT`.
  The integer from `GetItemLinkItemStyle()` is still accepted everywhere in the
  public API; it is resolved to a name internally and never stored as a persistent
  key.

- **`styleName` added to breakdown results.**  Each slot entry in
  `GetInsulationBreakdown().slots` now includes a `styleName` field (string or nil)
  alongside the existing `styleId`, so callers can display a human-readable name
  without performing their own lookup.

- **Override keys unchanged.**  Saved-variable override keys remain `"style_N"`
  (integer-based) because the player set them against a specific integer at a known
  point in time.  They continue to work — the integer is used only as a unique
  token for the saved-variable key, not for a data-table lookup.

### 2.2.0
- **Full style coverage:** `LibArmorInsulationData.Styles` now contains entries for all
  crafting-motif style IDs known as of ESO Update 49 (motifs 1–129, IDs 1–129).
  Previously only ~67 IDs were populated; ~62 motifs from the Thieves Guild, Dark
  Brotherhood, Morrowind, Summerset, Elsweyr, Greymoor, Blackwood, High Isle, Necrom,
  and Gold Road chapters were missing entirely.
- **Corrected several ID-to-name mappings** that were shifted by one due to a
  miscount of the gap between the racial styles (1–10) and the first post-racial motifs:
  - Telvanni was `[34]`; corrected to `[50]` (Motif 50).
  - Dragonscale was `[36]`; ID 36 is Dark Brotherhood (Motif 36). Dragonscale is not a
    craftable motif — removed; dragon-scale aesthetics are covered by individual
    dungeon-set pieces with no motif ID.
  - Snowhawk `[56]` was an invention with no confirmed ITEM_STYLE_* counterpart;
    Snowhawk is an **outfit-style collectible only** (not a motif). Entry removed from
    `Styles`; use the `OutfitStyles` collectible table instead.
  - IDs 80–89 ancestral styles renumbered to match confirmed Motifs 87–95.
  - IDs 90–105 updated to match Greymoor / Blackwood / High Isle motif numbering.
- **Zone ID statement evaluated:** The claim that "ESO zone IDs are large non-sequential
  integers … the only stable identifier is the English zone name … `BuildZoneIdMaps()`
  inverts the name→ID mapping" does **not apply to style IDs** and has **no relevance
  to this library**. Style IDs (`StyleItemIndex` / `ITEM_STYLE_*`) are small sequential
  integers starting at 1 and are stable across API updates — the exact opposite of zone
  IDs. This library does not use `LibZone`, `BuildZoneIdMaps()`, or any zone-ID
  machinery. No changes were required.

### 2.1.0
- Outfit slots now look up insulation by **collectible ID** via `ZO_OUTFIT_MANAGER` rather than by `ITEM_STYLE_*` ID, matching how ESO actually stores outfit style data internally.
- Added `LibArmorInsulationData.OutfitStyles` table (keyed by collectible ID) separate from `Styles` (keyed by `ITEM_STYLE_*`).
- `SetOverride` now accepts an `idType` parameter (`"style"`, `"outfit"`, `"costume"`) to disambiguate the three ID spaces.
- Added `sv.costumeCache` — a persistent per-account cache populated by `/scancostumes`.
- New slash commands: `/costumeids`, `/scancostumes`, `/clearcostumecache`, `/outfitids`, `/outfitactive`, `/diagcollectibles`.
- Added `LibArmorInsulationData.CostumeInsulationById` (collectible ID keyed) alongside the existing name-keyed `CostumeInsulation` table.
- Saved variables bumped to version 3; v2 saves are migrated automatically.
- Detection of active outfit changed from `GetActiveOutfitIndex()` to `GetEquippedOutfitIndex()` (confirmed correct ESO API function).

### 1.0.0
- Initial release.
