# Changelog

## Unreleased

- Added a preview of border-based selection states to the top-level ANALYTICS and DUELING module selectors; internal tabs retain their existing treatment pending visual approval.
- Restored resizing from the Analytics window's outer edges by preventing its full-size content layer from intercepting the shared window resize handles.
- Added a context-aware GO TO ANALYTICS action to Duel Summary, opening the exact selected duel report when session or saved Analytics data exists.
- Added a separate top-level Analytics module beside Dueling, with an initial Dueling scope.
- Added Damage Done, Damage Taken, Healing Done, Healing Received, Combat Log, and Fight Stats views.
- Added ability-ID-based source summaries with skill icons, critical-hit counts, minimum/average/maximum values, and full-value totals and rates.
- Expanded Combat Log into independent multi-select filters for All, damage, healing, incoming/outgoing buffs and debuffs, resources, used skills, stat changes, fight information, and performance samples.
- Added narrative timestamp rows for events without a meaningful source/target pair, including resource changes, skill use, weapon swaps, stat changes, and FPS/ping samples.
- Added sampled low/average/high offensive and defensive build statistics for newly recorded duels; critical and resistance ratings now show their percentage before the exact raw value.
- Analytics listeners, effect capture, and stat sampling exist only during active duel tracking.
- Analytics reports are now session-only by default and disappear on logout or `/reloadui`; SAVE DUEL permanently retains the selected complete report, while DELETE DUEL removes only its Analytics data and leaves the Dueling result and rating intact.
- Replaced the standalone Buff/Debuff view with a consolidated Uptime view. Repeated effects are summarized with applications, maximum observed stacks, duration, uptime percentage, source, and target; individual effect events remain available in Combat Log.
- Fixed SAVE DUEL and DELETE DUEL clicks by routing them through reliable mouse-enabled controls, and added clear chat confirmation for both actions.
- Timestamped combat logs remain bounded to 6,000 events per duel and buff/debuff applications to 3,000 events per duel; neither is written to SavedVariables unless the report is explicitly saved.
- Fixed the Analytics module rendering over Dueling tabs, summary cards, history rows, search controls, and pagination by making the two content views explicitly exclusive.
- Added a Select Opponent menu with concise account, class, date/time, and duration metadata for choosing the analyzed duel.
- Ability rows can now open Combat Log filtered to that exact damage or healing source, with a visible removable skill filter.
- Rebalanced Analytics value columns, added bordered Total and DPS/HPS summary cards, and color-coded Fight Stats by resource and stat family.
- Analytics now retains fully blocked zero-damage attacks in hit counts and the timestamped combat log while keeping them out of authoritative health-damage and rating totals.
- Shield-absorption events are logged separately with their API-reported absorbed value; shield wards are not misidentified as outgoing attack sources.
- Added CMX-style active DPS/HPS calculations and separate Duel DPS/HPS values. Active damage rates include reliably observed blocked or absorbed pressure exactly once, while Duel rates continue to use the full duel duration.
- Expanded Analytics summary cards to three equally spaced columns for Total, active DPS/HPS, and Duel DPS/HPS.
- Compacted the Analytics source summary card, separated its title with a horizontal divider, and retained room for full eight-digit combat values.
- Added a general Analytics Help view covering damage, healing, logs, skill filtering, Fight Stats, fight selection, filter clearing, and data availability.

## 1.0.7 — Current working build

- Detailed duel summaries now display full comma-separated combat values for totals, DPS/HPS, damage, minimum, average, and maximum hits instead of abbreviated `k`/`m` values.
- Fixed shield-absorption events such as `Calculated Defense` appearing as outgoing Damage Done sources.
- Widened detailed combat-report numeric columns so full values remain readable and aligned.
- Raised the three-second burst guard from 40% to 60% of total outgoing damage for eligible upset victories.
