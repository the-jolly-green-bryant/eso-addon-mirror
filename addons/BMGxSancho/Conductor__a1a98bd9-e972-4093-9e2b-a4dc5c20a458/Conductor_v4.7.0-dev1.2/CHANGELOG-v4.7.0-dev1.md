# Conductor v4.7.0-dev1

## Runtime Simplification and Start Conductor Foundation

- Separated combat role, Trial Lead view, and Run Host authority.
- Added combat roles: Tank, Healer, and Damage Dealer.
- Added independent Trial Lead view toggle.
- Added one authoritative RunContext with HOSTING, JOINED, LOCAL, ACTIVE, PAUSED, and ENDED states.
- Added lightweight Start Group Run, Join Group Run, Start Local Conductor, and Stop Run actions.
- Added compact LibGroupBroadcast run beacons, join records, checkpoints, and stop messages.
- Removed full Raid Plan transfer from the normal run-start path.
- Disabled legacy Colossus, Warhorn, Barrier, Pillager, Nazaray, and Major Slayer sequencing ownership.
- Disabled Recommendation Engine, Post-Pull Analytics, and Research Capture runtime initialization for this stabilization branch.
- Retained encounter observers, effect tracking, capability scanning, Raid Setup, and Timeline infrastructure.
- Timeline role filtering now consumes RunContext identity rather than treating the legacy display role as authority.
- Retired the Personal Assignments window setting. Personal responsibilities are intended to appear on the Timeline.
- Added one shared window lock controller for Timeline and Buffs & Debuffs.
- Window positions continue to save automatically when movement stops.

## Important test status

This build is statically validated and packaged for in-game testing. It has not yet been validated in a live ESO group. Protocol ID 237 is development-only and must be formally reserved before public release.
