# Trial Recorder v1.0.016

- Corrected All Live Stats vertical positioning so the visible text can reach the top and bottom screen edges.
- Replaced the fixed 64px top-level HUD height with bounds fitted to the actual rendered text line.
- Preserved ESO screen clamping with only a 2px-per-side safety pad around the rendered text.
- No changes to trial timing, score, vitality, clear recording, leaderboard logic, Run Report API, or SavedVariables schema.

# Trial Recorder v1.0.015

- Added Trial Recorder Run Report schema v1 as an isolated post-clear data layer.
- Every newly saved clear now produces a structured report containing trial identity, clear classification, score, duration, vitality, deaths when ESO exposes them, local account/character identity, and a completion-time group roster snapshot.
- Added field-level provenance so downstream consumers can distinguish ESO-native values from Trial Recorder classifications and optional provider data.
- Added current weekly-trial context to reports when ESO exposes the active weekly leaderboard.
- Added `TrialRecorder.RunReportAPI` with read-only report retrieval and optional provider registration for future Better Buffs / combat-stat summaries.
- Optional provider failures are isolated and cannot block a Trial Recorder clear from being saved.
- Structured reports are stored separately from clear history and capped at the 50 most recent reports to prevent unbounded SavedVariables growth.
- Existing clear detection, Hard Mode classification, leaderboard retrieval, All Live Stats, vitality recording, menus, and historical records remain unchanged.

# Trial Recorder v1.0.014

- Live Stats score now reads ESO's authoritative `GetCurrentRaidScore()` value directly instead of preferring the recorder's cached score-event value.
- Live Stats refreshes immediately when ESO fires `EVENT_RAID_TRIAL_SCORE_UPDATE`, while retaining the existing one-second refresh as a fallback.
- Replaced the oversized fixed 820-pixel Live Stats control width with a width fitted to the actual rendered text.
- Horizontal 0% and 100% now place the visible text line itself at the left and right screen edges instead of placing an invisible padded control box at those edges.
- Preserved vitality, raid time, clear recording, Hard Mode classification, leaderboard retrieval, SavedVariables, scale, and position settings.

# Trial Recorder v1.0.013

- All Live Stats positioning now spans the full visible screen.
- 0% places the visible control at the left/top edge and 100% at the right/bottom edge.
- Position calculations account for the current Live Stats scale.
- ESO screen clamping remains enabled as a final safety guard.
- No changes to recording, HM classification, vitality, score tracking, leaderboard retrieval, or stored history.

# Trial Recorder v1.0.012

- Limited the Recent Clears display to the 10 most recent clears for each trial while preserving the full stored run history.
- Renamed Active Timer to All Live Stats.
- Expanded the existing live display to show ESO raid time, current vitality, and current score inline.
- Reused the existing one-second timer update and existing raid score stream; no new tracker or polling system was added.
- Renamed Timer Position to Restore Default Position for clearer menu behavior.
- Preserved clear detection, Hard Mode classification, leaderboard retrieval, vitality recording, SavedVariables, and historical records.

# Trial Recorder v1.0.011

- Fixed a PlayStation startup error in the Active Timer caused by unsupported label shadow methods.
- Preserved the live timer, positioning, scale, preview, clear tracking, vitality, and leaderboard behavior.
