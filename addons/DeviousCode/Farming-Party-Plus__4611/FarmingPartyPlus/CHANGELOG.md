# Changelog

All notable changes to `FarmingPartyPlus` are documented in this file.

## [3.0.8] - 2026-07-21
### Added

- Added requested stolen-only tracking mode for thief runs. When enabled, `FarmingPartyPlus` counts stolen loot while bypassing whitelist, quality, gear, and motif filters. The local-player path also checks recent backpack updates because ESO's loot-event stolen flag can be false even when the received item is stolen. Group-member stolen loot uses an honor system because ESO hides group stolen status from other clients.
- Reworked compact scoreboard mode into a small movable `FPP Total:` group-total window. Clicking the total text opens the full scoreboard.

### Fixed

- Stolen-only group tracking now counts remote group-loot events during thief runs, since ESO does not expose another player's backpack stolen state to the receiving client.

## [3.0.7] - 2026-06-07
### Added

- `FarmingPartyPlus` can now handle local fishing and gutting sync directly when `LibGroupBroadcast` is installed. This means the main addon can send sync updates on its own without needing the separate helper addon.
- Added a preferred market price source setting. You can now choose `Auto`, `TTC`, `MM`, or `ATT`, with vendor value always used as the final fallback.
- Added an optional loot-history setting that shows the active price source after gold values in chat and loot window lines, such as `TTC`, `MM`, `ATT`, or `Vendor`.

### Changed

- The recommended setup is now the normal one-addon install: `FarmingPartyPlus` handles both sending and receiving fishing/gutting sync when `LibGroupBroadcast` is available.
- Fishing and gutting sync now uses a shared lookup-table payload for tracked fishing items instead of sending full item links through `LibGroupBroadcast`.
- `LibGroupBroadcast>=95` is now listed as an optional dependency in the main addon manifest, since the built-in sync path now lives inside `FarmingPartyPlus`.
- Account-wide settings and saved member data are now separated by server using `GetWorldName()`, so NA, EU, and other server families no longer share the same saved addon data.
- Removed the old `/fpp sync` command, since sync is now part of the normal built-in FPP flow.
- Consolidated sync into a single `LibGroupBroadcast` protocol now that the old helper-addon split is no longer part of the active install path.
- Cleaned up the addon’s public Lua surface by routing module constructors and window actions through the main `FarmingPartyPlus` table instead of using several standalone global class names.
- Centralized tracking status in `Startup.lua`, so the main addon controls whether tracking is enabled while member and loot modules focus on their own event handling.
- Pricing now uses one shared helper across loot tracking, sync, recipe filtering, and stack tracking. This keeps value calculations consistent no matter where the price is being used.

### Fixed

- The `Logs` whitelist category now uses the raw wood node-drop names, such as `Rough Maple` and `Rough Ruby Ash`, so it matches what players actually loot from wood nodes.
- Synced fishing and gutting updates now resolve more reliably on other `FarmingPartyPlus` clients, including stack replay, processed fish subtraction, `Fish`, and `Perfect Roe`.
- Solo host rows no longer appear grayed out like the player is offline when you are not in a group.
- Best-item hover tooltips now ignore plain-text fallback names instead of trying to treat them like ESO item links.
- Removed redundant slash-command registration during startup.
- Missing market-pricing addons no longer risk breaking value lookups when a preferred source is selected. Unavailable sources are now skipped automatically at runtime.
- Loot history now ignores zero-quantity no-op entries instead of printing bad lines like `x0 - 0.00g`.
- Remote gutting outputs for `Fish` and `Perfect Roe` now resolve through stable local item links, so whitelist checks, pricing, and price-source labels stay consistent on receiving clients.

## [3.0.6] - 2026-06-04
### Changed
- Sync receiver handling now derives item names locally from `itemLink` and keeps only the display-name identity field on the wire, reducing redundant helper payload data without changing the tested fishing and gutting flow.

### Fixed
- Restored helper recognition after the sync payload cleanup by continuing to accept sender display-name identity for helper markers, gutting updates, and duplicate handling.

## [3.0.5] - 2026-06-03
### Added
- A `Stack Found` loot-history entry so stack-backed fishing corrections are visible in chat and the loot window instead of appearing as a silent scoreboard jump.
- Clearer member-row status markers with a green `H` for the local `FarmingPartyPlus` host and retained helper `*` indicators for synced members.
- A dedicated keybind to toggle loot tracking on and off, plus a matching `/fpp toggle` command.

### Changed
- Cleaned up member lookup and sync duplicate handling internals to rely on clearer helper functions and cached lookups without changing the tested fishing and gutting behavior.
- Refined member presence rendering so active, helper-active, and offline rows are easier to distinguish during multi-character or multi-client event testing.
- Sync receiver handling now derives sender identity and synced item names from local API data, keeping the on-wire `FarmingPartyPlusSync` payload leaner and more addon-friendly.

### Fixed
- Fixed several object constructors so initialization happens on the created instance instead of the shared class table.
- Fixed member total rebuilds so zero-count item cleanup no longer mutates the same table while iterating it.
- Fixed the loot-history window move handlers so dragging and releasing the window no longer throws nil-setting errors.
- Fixed local and synced fish-stack tracking so pre-existing stack catches, stack replay, and processed-fish subtraction continue to reconcile correctly after the internal cleanup pass.
- Fixed offline character rows so they gray correctly when another character from the same account joins the group.

## [3.0.4] - 2026-06-02
### Added
- A craft-bag auto-add warning dialog for fishing sessions so hosts can disable the setting before `Fish` or `Perfect Roe` start bypassing tracked inventory flow.
- A compact scoreboard mode with a settings toggle, slash command support, and a dedicated keybind.

### Changed
- Extended the synced loot payload handling so helper-provided `itemLink` data now drives proper item naming, tooltip links, and rarity colors on the host.
- Host-side synced pricing now prefers the host's own item-link valuation instead of trusting helper fallback values.
- Synced gutting history now logs consumed fish as `Processed` entries while preserving normal `Received` lines for `Fish` and `Perfect Roe`.
- Synced loot dedupe now tracks native-vs-helper counts so repeated gutting results do not collapse into missing or duplicated history lines.
- Fishing-session craft-bag warnings and gutting output handling now mirror the host's local behavior more closely.
- Scoreboard display and sync identity handling now align more closely around ESO display names / `@UserID` instead of character-name-first behavior.
- The member scoreboard can now collapse into a tighter two-column layout by hiding the `Best Item` column.
- Same-client `FarmingPartyPlus` + `FarmingPartyPlusSync` installs can now share fishing and gutting mesh sync outward to other `FarmingPartyPlus` clients without self-echo.
- Keybinding action labels now use the shorter `FPP` prefix while keeping the main Controls category title unchanged.
- Main `FarmingPartyPlus` settings now use an account-wide saved-variable store, with one-time migration from the old character-scoped settings profile.

### Fixed
- Restored loot-event handling for gutting outputs with duplicate guards so `Fish` and `Perfect Roe` count and log reliably again.
- Fixed synced item-link decoding and host-side value resolution so helper items keep correct casing, tooltip links, rarity colors, and prices.
- Fixed helper-slot reuse and tracked fish state so backpack slot changes stop producing stale-count sync corruption during gutting.
- Fixed the host sync protocol declaration so it matches the helper's `itemLink`-aware payload shape.
- Fixed malformed tooltip/link behavior for synced gutting entries that had previously been stored as plain text names.
- Fixed repeated helper gutting updates so native and synced group-loot copies no longer overcount, undercount, or race each other in loot history.
- Fixed sync self-ignore, duplicate suppression, and helper-active matching to prefer display-name identity before character-name fallback.
- Fixed receiver-reset fishing gaps by replaying touched fish-stack claim state on later catches, so another `FarmingPartyPlus` client can rebuild `1 -> 5` style stack-backed totals correctly.
- Fixed processed loot history entries so the gold value text is colored red when value is being removed.
- Fixed whitelist-mode settings confusion by disabling the `Minimum Item Quality` control whenever whitelist mode is enabled.

## [3.0.3] - 2026-06-01
### Added
- A `Recipes` whitelist category with a shared recipe tracking rule for valuable node recipes.
- A recipe minimum-value threshold, defaulting to `3000g` and bounded from `100g` to `50000g`.
- Account-wide whitelist profile save/load/delete support with per-profile names.
- A whitelist profile load confirmation dialog that reloads the UI on acceptance.

### Changed
- Reworked the top of the whitelist window to separate profile naming/saving from saved profile selection.
- Added live validation for whitelist profile names so they accept letters only, with no spaces.
- Refined the whitelist window layout and row widths to better fit longer rule labels.

### Fixed
- Fixed the recipe threshold UI by replacing the broken native slider behavior with a custom bar control.
- Fixed recipe slider endpoint behavior so clicking the min/max labels snaps to exact `100g` and `50000g`.
- Fixed recipe slider row overlap and improved the visible slider track, fill, and thumb state.
- Fixed the profile name field so it takes focus and accepts typed input correctly.

## [3.0.2] - 2026-06-01
### Added
- Helper-presence indicators in the members window, driven by observed sync traffic from `FarmingPartyPlusSync`.
- A dedicated loot-history toggle keybind plus `/fpp loot`, `/fpp log`, and `/fpploot` commands.
- A delayed ready message after `/reloadui` so the addon reports when tracking is actually ready.

### Changed
- Tightened the members window layout by reducing the spacing between columns and removing the visible `Items` label.
- Updated the loot history window toggle path so keybind and settings changes use the same visibility state.
- Extended the whitelist catalog to include `Fish` by default for fishing-session gutting output.

### Fixed
- Added local backpack fish-slot tracking so host-side gutting can subtract consumed fish and add `Fish` or `Perfect Roe` correctly.
- Added reset handling for local loot and sync session caches so `/fpp reset` clears active gutting/sync state.
- Fixed loot history window layout drift after show/hide by reapplying saved dimensions and anchoring the text buffer correctly.
- Reduced sync protocol ID size and enabled signed synced quantities so helper deltas can add and subtract tracked items safely.

## [3.0.1] - 2026-06-01
### Fixed
- Removed the circular optional dependency between `FarmingPartyPlus` and `FarmingPartyPlusSync`.
- Updated the `LibGroupBroadcast` integration to match the current handler registration and field option APIs.
- Fixed sync host object initialization so the receiver module initializes on the created instance.

## [3.0.0] - 2026-06-01
### Project Note

`FarmingPartyPlus` began as a fork of the original `Farming Party` addon, which was previously versioned as `2.15.0`.

This release marks the beginning of the `FarmingPartyPlus` version line. Changes listed here reflect work done specifically for `FarmingPartyPlus`.

### Added
- New `FarmingPartyPlus` addon identity, folder, saved variables, slash commands, and bindings so it can coexist with the original `Farming Party`.
- Material whitelist mode designed for organized farming groups that want to count only selected items.
- Dedicated whitelist window with grouped categories, individual item toggles, per-category `All On` and `All Off`, and global whitelist controls.
- Expanded whitelist coverage for ore, logs, cloth and leather, jewelry dust, alchemy reagents, enchanting materials, provisioning, furnishing materials, bait, and fishing drops.
- Optional helper companion addon, `FarmingPartyPlusSync`, in its own folder for future sync-based accuracy improvements.
- Legacy slash command aliases for players used to the original addon, including `/fp` and `/fpc`.
- Ranked chat score output using ESO user IDs.

### Changed
- Reworked tracking flow to support whitelist-first farming runs without relying only on item quality.
- Updated the settings panel with clearer section ordering, colored headers, and a reload reminder without forcing `/reloadui`.
- Refreshed the whitelist window visuals with clearer toggle states and more noticeable action buttons.
- Clicking a member name in the scoreboard now opens that member's item breakdown directly.
- Updated addon metadata and API compatibility for current ESO live versions.

### Fixed
- Resolved loot tracking failures caused by self and group looter name resolution.
- Fixed whitelist matching so enabled materials count reliably and unrelated items no longer slip through.
- Enforced gear and motif exclusions correctly while whitelist mode is active.
- Fixed `Minimum Item Quality` comparisons so changing the setting no longer throws number-versus-string errors.
- Corrected several UI and data-persistence issues discovered during the `FarmingPartyPlus` fork.
