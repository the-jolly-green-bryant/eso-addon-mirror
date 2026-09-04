# Trial Recorder v1.0.016

Trial Recorder automatically records veteran and Hard Mode trial clears from the date it is installed.

Each trial record displays:

- Current leaderboard score and rank
- Character associated with the leaderboard result
- Veteran, Hard Mode, and total clear counts
- Fastest completion times
- Highest recorded scores
- First and latest recorded clear dates
- The 10 most recent clears with character, date, clear type, time, score, and recorded vitality

Leaderboard results are requested from ESO when a trial is selected. Trial Recorder searches the returned leaderboard for the player's Online ID and stores the best-known result account-wide. Clear tracking begins when the addon is installed and cannot reconstruct previous clear counts, dates, or times.

Every clear counts.

A BMG Addon

Created and maintained by @BMGXSANCHO

## Vitality

Every newly recorded clear stores the remaining raid vitality and displays it in the trial window. Existing records that predate vitality tracking are not backfilled and show `Not recorded`.

## All Live Stats

The optional All Live Stats display uses ESO's active raid state and shows live raid time, current vitality, and current score in one inline HUD field. It updates once per second only while a scored raid is active and preserves the existing positioning and scale settings.


## Run Report API

Beginning with v1.0.015, every newly saved clear also produces a versioned Trial Recorder Run Report. The report is a lightweight snapshot designed for optional external consumers without changing the recorder engine.

The core report contains Trial Recorder's authoritative clear metadata, the local account/character identity, a completion-time group roster snapshot, current weekly-trial context when ESO exposes it, and field-level provenance. Optional compatible addons can contribute namespaced summaries through `TrialRecorder.RunReportAPI:RegisterProvider(...)`. Trial Recorder does not transport, upload, aggregate, or post the report itself.

The API currently exposes:

- `TrialRecorder.RunReportAPI:GetSchemaVersion()`
- `TrialRecorder.RunReportAPI:GetLatestReport()`
- `TrialRecorder.RunReportAPI:GetReport(reportId)`
- `TrialRecorder.RunReportAPI:RegisterProvider(providerId, provider)`
- `TrialRecorder.RunReportAPI:UnregisterProvider(providerId)`

Only the 50 most recent structured reports are retained locally. Existing clear history remains unchanged.
