# Conductor v4.7.0-dev1 Test Plan

## Load and migration

1. Install and reload UI.
2. Confirm no Lua error.
3. Confirm combat role defaults to Damage Dealer for migrated Trial Lead profiles.
4. Confirm Trial Lead view remains enabled for migrated Trial Lead profiles.
5. Confirm the Personal Assignments window is not displayed.

## Window controls

1. Enable Unlock Conductor windows.
2. Move Timeline and Buffs & Debuffs.
3. Disable Unlock Conductor windows.
4. Reload UI.
5. Confirm both positions remain and both windows are locked.

## One-client local mode

1. Enter a supported trial.
2. Press Start Local Conductor.
3. Pull a supported encounter.
4. Confirm Timeline starts and Buffs & Debuffs continues tracking.
5. Wipe and confirm the Timeline clears and resets.
6. Stop Conductor Run.

## Two-client group mode

Host:
1. Press Start Group Run.
2. Confirm the success message.

Participant:
1. Wait for the run beacon.
2. Press Join Group Run.
3. Confirm joined state.

Both:
1. Pull one encounter.
2. Confirm both clients display the same encounter phase.
3. Confirm combat-role filtering differs correctly.
4. Enable Trial Lead view on the participant and confirm expanded command visibility without changing host authority.
5. Stop the run from the host and confirm both clients end.

## Role matrix

Test:
- Host DD, no Trial Lead view
- Host Healer, Trial Lead view
- Participant DD
- Participant Tank
- Participant Healer
- All users Trial Lead view
- No users Trial Lead view

## Regression

- Group roster still populates.
- Remote Conductor discovery still works.
- Buffs & Debuffs still tracks effects.
- Timeline preview works.
- No legacy Colossus/Warhorn/Barrier configuration errors appear.
- No full Raid Plan transfer dialog appears during normal start.
