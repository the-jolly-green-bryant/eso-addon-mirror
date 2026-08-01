# Under Pressure

A passive HUD overlay for The Elder Scrolls Online aimed at tanks. It displays a single shape-based icon estimating how much incoming pressure you are under, plus a counter showing how many distinct mobs are currently being tanked by you or your group. Useful for spotting loose adds and gauging when an add pull is getting too heavy to hold.

**Version:** 0.2.6 (Phase 1: self-pressure + attacker counter)
**Target platform:** ESO console (Xbox Series X|S, PlayStation 5) via the Update 46 add-on framework. Compatible with PC/Mac for testing on PTS.
**Author:** Th3rtythr33

---

## What it does

The indicator answers one question continuously during combat: *"If no healing or mitigation were applied from this moment forward, how quickly would I die under current pressure?"*

It does this passively. It reads incoming combat events, harmful debuffs, and player health — it never takes any in-game action.

### Visual states

| Shape | Meaning | Trigger |
|---|---|---|
| 🟩 Green square | Safe | No damage or hostile state in the last 10 seconds |
| ⭕ Yellow ring (empty) | Recent pressure, not lethal | Damage or debuff within 10s, TTD ≥ 6s |
| 🟡 Yellow filled circle | Moderate pressure | TTD between 3 and 6 seconds |
| 🔺 One red triangle | High pressure | TTD between 2 and 3 seconds |
| 🔺🔺 Two red triangles | Extreme pressure | TTD between 1 and 2 seconds |
| 🔺🔺🔺 Three red triangles | Immediate lethal pressure | TTD under 1 second |

Shapes are distinguishable by silhouette alone for readability in peripheral vision and under color-vision constraints.

### Attacker counter (new in 0.2.0)

A small `P | N` label sits directly under the indicator shape. **P** is the number of distinct **Players** seen attacking in the recent window; **N** is the number of **NPCs**. The label hides itself when both counts are zero so it never adds noise out of combat.

Two modes, toggled in Settings:

| Mode | What it counts |
|---|---|
| **Not Tank** (default) | Distinct attackers targeting **you** in the last *N* seconds |
| **Tank** | Distinct attackers targeting **any groupmate the client observes being hit** (best-effort — see Known Limitations) |

Window length is configurable 1–5 seconds; default 3.

---

## Installation

### Console (Xbox Series X|S, PlayStation 5)

1. Once published, find **Under Pressure** in the in-game Add-Ons menu (Options → Add-Ons).
2. Install. LibAddonMenu-2.0 will be auto-installed as a dependency.
3. Restart the game to load.
4. The indicator appears centered above the reticle by default.

### PC / Mac (PTS testing)

1. Copy the `UnderPressure/` folder to:
   - Windows: `Documents\Elder Scrolls Online\live\AddOns\` (or `pts\AddOns\` for the test server)
   - Mac: `~/Documents/Elder Scrolls Online/live/AddOns/`
2. Install LibAddonMenu-2.0 to the same folder if not already present.
3. Launch ESO. Enable "Under Pressure" in the Add-Ons menu at the character-select screen.

---

## Configuration

In-game: **Settings → Add-Ons → Under Pressure** or `/up`

All thresholds, window weights, the burst multiplier, the pressure floor, indicator position/scale, and the debug toggle are exposed. **The defaults are starting points — tuning is expected for your character and content** (see "Tuning" below).

### Slash commands

- `/up` — open the settings panel
- `/updebug` — toggle the debug overlay

---

## Tuning workflow

This add-on is a model, not a measurement. The right values for `burst_multiplier`, the per-window weights, the pressure floor, and the risk bonuses depend on your character's max health, your gear, and the type of content you run (overland adds, dungeon trash, trial pulls, etc.).

Recommended approach:

1. Enable the debug overlay (`/updebug`).
2. Go to a low-stakes setting (overland adds, an easy public dungeon, a normal dungeon trash pull, etc.).
3. Watch the overlay during fights:
   - `TTD` should drop into red-triangle range during real burst windows.
   - `pressureDPS` should track your perceived incoming threat.
   - `dmgEvts` rising rapidly indicates the rolling window is populated.
   - Active debuff count tells you whether the classifier is recognizing harmful effects.
4. If the indicator flickers, raise `State persistence (ms)` in settings (default 200ms).
5. If burst doesn't escalate fast enough, raise the `1s window weight` or `Burst multiplier`.
6. If the indicator sits red too long after a fight ends, lower the per-window weights or raise `Pressure DPS floor`.

### Ability classification

The starter ability-ID table in `Engine/AbilityClassifier.lua` covers common Cyrodiil debuffs (Major Defile, Major Vulnerability, common stuns, Lingering Torment) but is **not exhaustive**. Use the debug overlay to identify ability IDs of effects you experience and either:

- Edit the table directly in `Engine/AbilityClassifier.lua` (PC/Mac only)
- Or extend via saved variables: open `UnderPressureSavedVars.lua` (PC/Mac in the SavedVariables folder) and add entries to the `abilityOverrides` table.

**Note for console:** Saved-variables file editing isn't available on console. The console version benefits from updates to the in-code classifier; consider publishing follow-up versions as you identify additional IDs.

---

## What is verified, what is inferred, what is unknown

The add-on was built against the ESO console add-on framework introduced with Update 46 (June 2025). The framework is documented to be UI-only, with combat-event, debuff-tracking, and unit-power APIs confirmed working through existing console add-ons (Personal DPS Tracker, CrutchAlerts, Fancy Action Bar+, AK's Attribute Bars). However, certain API details could not be verified without direct console testing. Those uncertainties are handled by `Engine/FeatureDetect.lua`, which probes at runtime and stores feature-availability flags.

### Verified through public sources (existing console add-ons demonstrate these work)
- `EVENT_COMBAT_EVENT` for incoming damage on the local player
- `EVENT_EFFECT_CHANGED` for player debuffs with abilityId
- `GetUnitPower` for player health
- `EVENT_POWER_UPDATE` for live health changes
- `CT_TEXTURE` and `CT_CONTROL` UI primitives
- `LibAddonMenu-2.0` (confirmed available on console as a separately-listed library)
- `SavedVariables` persistence

### Inferred but not directly confirmed
- The exact field population of `EVENT_COMBAT_EVENT` on console (all 18 fields). The add-on uses `hitValue`, `abilityId`, `damageType`, `result`, `targetType` — all expected to be populated.
- `EVENT_PLAYER_COMBAT_STATE` firing on console.
- `AddFilterForEvent` working on console. `FeatureDetect` probes for this; if absent, filtering is done in the callback instead.

### Unknown — graceful fallback in place
- **Damage shield value reads** via `GetUnitPower(COMBAT_MECHANIC_FLAGS_DAMAGE_SHIELD)`. If unavailable, `effectiveHealth` falls back to health only. This makes pressure slightly more conservative (under-estimates survivability briefly) but does not break the model.
- **`EVENT_UNIT_ATTRIBUTE_VISUAL_*` events** for live shield deltas. If unavailable, shield is read by polling each tick.
- **`statusEffectType` field on `EVENT_EFFECT_CHANGED`** for type-based debuff categorization. If unavailable, the classifier falls back to the static ability-ID table.
- **Group unit tags (`group1`–`group24`)** for Phase 2 group-pressure. Not used in Phase 1.

A complete reference of what is verified vs. unknown lives in `eso-console-api-surface.md` (one directory up, included with this package).

---

## Submission notes (for the uploader)

### Before upload

- Confirm `## APIVersion` in `UnderPressure.addon` matches the **current** console live API version. The manifest currently lists `101048 101049`. Adjust if a newer patch is live.
- Ensure LibAddonMenu-2.0 is listed on the Bethesda.net portal so the `DependsOn` reference resolves. As of research time it was confirmed available; verify it's still listed before upload.
- The submission is reviewed by ZOS before public listing. Review focuses on the "UI-only" policy.

### Policy alignment

This add-on:
- Reads combat data and renders a single icon (✓ explicitly allowed — ZOS lists "combat tracking overlays" and "buff tracking overlays" as supported)
- Does not auto-cast, auto-consume, auto-swap, or trigger any game action
- Does not communicate with external servers
- Does not modify player settings or camera
- Does not display opponent information to other players

The nearest precedent on the console portal is **CrutchAlerts** (incoming-attack indicator), which is approved and widely used.

---

## Known limitations

- **Tuning required.** The model's default thresholds and bonuses are starting points. Tuning will adjust them based on your build's max HP and the content you run. The debug overlay is the primary tuning tool.
- **Ability-ID classification is partial.** The starter table covers common high-impact debuffs; many lesser threats are unclassified and contribute only via their damage events. Extend the table as you encounter new threats.
- **Pre-mitigation reconstruction is not attempted.** The add-on uses observed (post-mitigation) damage values as the lower bound on hostile contribution, per the spec's guidance to prefer conservative approximation over fake exact reversal.
- **No group-pressure display (Phase 2).** Phase 1 is self-only. Phase 2 will follow once Phase 1 is stable and tuned.
- **Tank-mode counter is best-effort.** The ESO client does not guarantee delivery of every combat event happening to your groupmates. Tank mode counts attackers on groupmates the client actually receives events for — typically those near you and engaged with overlapping enemies. In tight dungeon and trial pulls this approximates well; spread out it will undercount. The pressure shape (color/state) itself is unaffected; only the counter has this caveat. ZOS deliberately limits cross-player combat telemetry.

---

## File layout

```
UnderPressure/
├── UnderPressure.addon        manifest
├── UnderPressure.lua          main entry / lifecycle
├── Settings.lua                       LibAddonMenu-2.0 settings panel
├── README.md                          this file
├── Engine/
│   ├── FeatureDetect.lua              runtime API capability probes
│   ├── AbilityClassifier.lua          debuff ID → risk-category mapping
│   ├── AttackerTracker.lua            rolling unique-attacker count by source
│   ├── EventIngest.lua                combat/effect/power event listeners
│   └── PressureEngine.lua             rolling windows, TTD, state machine
└── UI/
    ├── Indicator.xml                  indicator control definition
    ├── Indicator.lua                  state → texture, animation
    ├── Debug.xml                      debug overlay control definition
    ├── Debug.lua                      debug overlay logic
    └── Textures/
        ├── green_square.png
        ├── yellow_empty.png
        ├── yellow_filled.png
        ├── red_one.png
        ├── red_two.png
        └── red_three.png
```

---

## Version history

- **0.1.0** — Initial release. Phase 1 (self-pressure) only. Debug overlay included.
- **0.2.0** — Renamed to **Under Pressure**. Added attacker counter (`P | N`) beneath the indicator with **Tank** and **Not Tank** modes, configurable 1–5 second window. New settings: counter mode dropdown, window slider, show-counter toggle. Debug overlay now shows attacker mode + counts and `srcType` feature probe.
- **0.2.1** — Fixed `Indicator.xml` `<Color>` parse error. Colors now applied in Lua via `SetColor()`.
- **0.2.2** — Fixed settings panel not appearing under LibAddonMenu-2.0 r36+ (LibStub removed). `Settings.lua` now uses the `LibAddonMenu2` global, resolved at `EVENT_ADD_ON_LOADED`. Manifest dependency bumped to `LibAddonMenu-2.0>=32`.
- **0.2.3** — Counter text enlarged (`ZoFontWinH3`) and moved to the **right** of the indicator. All three red triangles now render at uniform size; the indicator column grows vertically (1, 2, or 3 triangles tall) instead of resizing a single shape. Author set to **Th3rtythr33**.
- **0.2.4** — Indicator now grows **upward** (bottom edge stays fixed) instead of expanding from the center. Counter split into two columns: **NPC** on the left and **PLR** on the right, each with a sublabel underneath. New "Counter text size" slider in settings (14–36px) lets the user scale the number font; sublabels scale proportionally.
- **0.2.5** — Added **Source type checking (Beta)** toggle (off by default). When off, a single combined attacker count is drawn centered on the bottom indicator shape with no NPC/PLR split — the safe display until ZOS exposes attacker source type on live console. When on, the counter splits into NPC / `?` / PLR columns; an `IsUnitPlayer` heuristic resolves unknown sources where possible. Description rewritten to reflect the add-on's tanking focus.
- **0.2.6** — Removed code paths that depended on console APIs that are not exposed in practice: `srcType`-based source classification (player/NPC/unknown split) and `shieldPower`-based shield tracking have been physically stripped from the engine, event ingest, attacker tracker, and debug overlay. The attacker counter is now a single combined count permanently. New visibility behavior: the indicator auto-hides when the player is **out of combat** or **dead**, with an **"Always show indicator"** override in settings. Debug overlay window enlarged (760x460) with larger fonts (`ZoFontWinH4` header, `ZoFontGameLarge` body) for console readability. Settings panel cleaned up: "Source weighting" section removed; "Source type checking (Beta)" toggle removed; per-source-type effect weights collapsed to a single "Debuff risk-bonus weight" slider.
