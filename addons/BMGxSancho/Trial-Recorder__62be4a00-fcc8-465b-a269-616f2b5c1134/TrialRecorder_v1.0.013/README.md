# Trial Recorder v1.0.013

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
