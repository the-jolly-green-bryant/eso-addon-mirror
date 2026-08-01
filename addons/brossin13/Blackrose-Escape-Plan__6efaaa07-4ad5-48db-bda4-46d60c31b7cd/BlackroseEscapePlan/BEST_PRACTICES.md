# 📘 Project Best Practices

## 1. Project Purpose
Blackrose Escape Plan is an Elder Scrolls Online (ESO) add-on focused on supporting the Blackrose Prison arena. Its goals are:
- Prevent accidental Sigil interactions near defined locations in Blackrose Prison.
- Provide groundwork for marking/identifying priority enemies.
- Offer configurable options (via an addon settings panel) and persistent settings.

Domain: ESO UI add-on (Lua + ZOS API) scoped to PvE arena content (Blackrose Prison).

## 2. Project Structure
- BlackroseEscapePlan.addon
  - Add-on manifest containing metadata (Title, Author, Version, APIVersion), dependencies, saved variables, and the file load order.
- BlackroseEscapePlan.lua
  - Main implementation: initialization, event handlers, utility functions, saved variable loading, and options menu setup.

Conventions:
- Single-file add-on implementation; keep concerns grouped logically via sections and local functions.
- All module state is namespaced under the global `BlackroseEscapePlan` table and its local alias `BEP`.

Recommended structure as project evolves:
- src/BlackroseEscapePlan.lua (core logic)
- src/options.lua (LAM panel definitions)
- src/constants.lua (enemy lists, positions, IDs)
- src/events.lua (event registration, handlers)
- BlackroseEscapePlan.addon (manifest)

## 3. Test Strategy
There is no automated test harness for ESO add-ons by default. Use the following strategy:
- Manual in-game testing:
  - Use `/reloadui` frequently.
  - Test only inside Blackrose Prison (zoneId 1082) to validate zone-gated logic.
  - Verify Sigil suppression by approaching known sigil coordinates.
  - Use combat spawn scenarios to validate any enemy marking logic.
- Instrumentation:
  - Prefer `d("[BEP] ...")` prefixed debug messages.
  - Gate verbose logging behind a saved variable (e.g., `debugEnabled`) to reduce chat spam.
- Event-scoped testing:
  - Register event handlers only when needed and unregister when leaving scope to minimize noise and side effects.
- Regression checklist:
  - UI loads without errors.
  - Options panel renders when dependencies are present.
  - Saved variables read/write across sessions.
  - No interference with other add-ons (especially global hooks like SYNERGY).

## 4. Code Style
- Language: Lua (ESO API).
- Namespacing:
  - Single global: `BlackroseEscapePlan`; alias with `local BEP = BlackroseEscapePlan`.
  - All functions/fields hang off `BEP` or are local to the file.
- Files and Symbols:
  - Constants in UPPER_SNAKE_CASE or clearly labeled fields on `BEP` (e.g., `BEP.zoneIdBlackrosePrison`).
  - Functions in lowerCamelCase (e.g., `IsInBlackrosePrison`, `IsNearSigil`).
- Locals:
  - Prefer `local` for helpers to limit scope and reduce global pollution.
- Defensive checks:
  - Validate external references (e.g., `if LibAddonMenu2 then ...`).
  - Check for zone, unit existence, and nils before invoking API calls.
- Saved variables:
  - Use `ZO_SavedVars:NewAccountWide` or `New` with a version number; keep the saved variable table name consistent with the manifest.
  - Provide a `GetDefaults()` function and version migration when schema changes.
- Events:
  - Use unique names when registering: `EVENT_MANAGER:RegisterForEvent(BEP.name .. "_Something", ...)`.
  - Unregister or gate with conditions to avoid global overhead.
- UI/Options:
  - Centralize option keys and default values to avoid naming drift.
- Logging:
  - Prefix with `[BEP]` and throttle in hot paths.
- Error handling:
  - ESO API is synchronous; guard optional libs/APIs and fail gracefully (e.g., warn via `d()` and disable features).

## 5. Common Patterns
- Zone gating:
  - Compute once or check early: `if not BEP.IsInBlackrosePrison() then return end`.
- Distance checks:
  - Use squared distance to avoid expensive `sqrt` on every frame/event.
- Feature toggles:
  - Gate expensive/event-heavy features by saved vars (e.g., `sigilBlockingEnabled`, `markAssignmentEnabled`).
- Options Panel (LibAddonMenu2):
  - Define panel data + options array, register once in `Initialize` after saved vars are loaded.
- Enemy lists:
  - Precompute a lookup set (table of `true`) for O(1) membership checks.

## 6. Do's and Don'ts
- Do
  - Keep manifest, saved variable names, and code in sync.
  - Validate library availability before use; align declared dependencies with actual code.
  - Register events with unique names; unregister when not needed.
  - Hide functionality behind zone/feature toggles to reduce interference.
  - Use local helpers and avoid global functions.
  - Precompute lookup tables for frequent membership checks (e.g., enemy names).
- Don't
  - Don’t hook or replace global systems (e.g., `SYNERGY.OnSynergyAbilityChanged`) without an opt-in toggle and fallbacks; avoid permanent overrides.
  - Don’t depend on libraries not declared in the manifest (or declare but never use a library).
  - Don’t spam the chat; throttle logs and add a debug flag.
  - Don’t assume specific unit tags exist (e.g., `boss1..boss6`) without nil checks.
  - Don’t leave stray debug prints referencing undefined variables.

## 7. Tools & Dependencies
- ESO/ZOS APIs used:
  - `EVENT_MANAGER`, `ZO_SavedVars`, `GetUnitWorldPosition`, `GetZoneId`, `GetUnitZoneIndex`, `SendChatMessage`, etc.
- Libraries:
  - Options menu in code uses `LibAddonMenu2`.
  - Manifest currently declares `LibHarvensAddonSettings` instead. Align these (use one library consistently).
- Setup:
  - Ensure required libraries are installed under live/AddOns as separate folders.
  - Place this add-on under `AddOns/BlackroseEscapePlan` alongside the manifest and Lua file.
  - Load in-game and `/reloadui`.

## 8. Other Notes
Practical refactors and fixes to consider (based on current code):
- Manifest/code consistency:
  - SavedVars: Manifest uses `BEP_SavedVariables`; code uses `BlackroseEscapePlanVars`. Choose one and update both places.
  - Dependencies: Code references `LibAddonMenu2`; manifest lists `LibHarvensAddonSettings`. Pick one (recommended: LibAddonMenu2) and update the manifest.
  - Versioning: Manifest shows 1.2.0; code sets `BEP.version = "1.0.0"`. Keep versions consistent.
- Missing/undefined references:
  - `BEP.allEnemiesLookup` is used but never defined; create a lookup table when populating enemies.
  - `OnCombatAny` is registered but not implemented.
  - `BEP.markAssignmentEnabled` and `BEP.sigilBlockingEnabled` are used but not part of defaults; add them to saved vars and defaults.
  - Stray debug line referencing undefined variables near top-level should be removed.
- Event safety:
  - Only register event handlers when the feature is enabled and the player is in the correct zone.
  - Consider unregistering on zone change or when disabling a feature.
- SYNERGY hook:
  - Avoid overriding `SYNERGY.OnSynergyAbilityChanged` globally. Prefer a safer pattern: intercept usage via input blockers or conditionally return early with a feature flag.
- Performance:
  - Cache enemy name lookups using a set; avoid scanning arrays during events.
  - Keep distance thresholds configurable via settings (with sane defaults).
- Extensibility:
  - Move constants (enemy names, sigil positions) into a constants module/table; document coordinate sources and units.
  - Add a slash command (e.g., `/bep`) that opens the options panel and toggles debug.

Guidance for LLM-generated changes:
- Maintain the `BEP` namespace and initialization pattern.
- Keep API calls guarded and cancellable by feature toggles.
- Always reflect changes across manifest, saved vars defaults, and code.
- Prefer additive changes over destructive overrides to core UI systems.
