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
