# Xbox manual acceptance checklist

Use a character with existing Bandit SavedVariables. Record the initial frame layout and minimap preference, position, size, and zoom.

## Controller editor

- [ ] Open Bandit Xbox UI → Misc → Frame Edit Mode using only the controller.
- [ ] Navigate every available frame with D-Pad Up/Down/Left/Right; verify spatial selection and fallback.
- [ ] Press A on each frame; verify MOVE mode's stronger highlight.
- [ ] Move with the left stick; verify small smooth movement and no drift on release.
- [ ] Move with the right stick; verify roughly 5–10× faster movement and no drift.
- [ ] Move toward every screen edge; verify frames remain visible in the TV-safe area.
- [ ] Press A again to place, then select and move another frame. Press B while moving and verify that frame returns to its grab-start position.
- [ ] Press Menu to preview; inspect player, target, boss, group, buffs, timers, notifications, and minimap for overlap.
- [ ] Press B from preview; verify pending positions remain and repositioning works.
- [ ] Press View/Back to cancel; verify every frame returns to its prior position and visibility without changing SavedVariables.
- [ ] Reopen, move, preview, then press A to save.
- [ ] Run /reloadui; verify saved positions, including the horizontal player frame and minimap.
- [ ] Restart ESO; verify positions again.
- [ ] If mouse is available, verify the older Move Frames flow still works.

## Minimap

- [ ] Login; verify the enabled preference, size, anchor, title, alpha, pin settings, and zoom.
- [ ] Run /reloadui repeatedly; verify the minimap appears each time.
- [ ] Use a wayshrine, teleport between zones, and cross zone/subzone boundaries.
- [ ] Enter and leave a building.
- [ ] Enter and leave a house; verify current house and prior outdoor maps.
- [ ] Enter and leave a dungeon; verify map identity and dungeon zoom.
- [ ] Open and close the full world map repeatedly in Gamepad UI; verify both map sizes remain usable.
- [ ] Test Cyrodiil, Imperial City, or other PvP maps if available.
- [ ] Die and respawn if feasible; verify recovery.
- [ ] Mount and dismount; verify the saved mounted zoom ratio.
- [ ] Switch Gamepad UI state and test Accessibility Mode if supported.
- [ ] Disable the minimap in Bandit settings, open/close the world map, and re-enable it; verify preference isolation.
- [ ] Restart ESO; verify minimap preference, position, size, and zoom remain correct.
- [ ] Check for Lua errors, blank tiles, missing player pins, hidden controls, or chrome outside the minimap boundary.

## Memory and long-session stability

- [ ] Leave the character logged in for at least 60 minutes while changing zones and entering combat; verify memory use does not continually accelerate while idle.
- [ ] Complete more than 12 fights lasting at least 10 seconds; verify the oldest unsaved reports are discarded and the newest 12 remain navigable.
- [ ] Save one combat report, complete more than 12 later fights, and verify the saved report remains available.
- [ ] Enable the curved frame, reload once, inspect it, then disable it again; verify no Lua errors and normal frames return.

## Add-on compatibility

- [ ] Disable the original Bandits User Interface before enabling SatuveXboxUI; verify only one of the two is active.
- [ ] Verify `LibGamepad` 1.0.7 or newer is enabled. Do not confuse it with `LibGamepadContextMenuBridge`.
- [ ] Open and close the native gamepad main menu, Frame Edit Mode, world map, inventory, and settings repeatedly; verify LB/RB, D-Pad, A, and B never affect a hidden screen.
- [ ] If AUI or LUI Extended is installed, disable its overlapping unit-frame, action-bar, reticle, and minimap modules before testing SatuveXboxUI.
- [ ] If another map/minimap add-on is installed, test zone travel, full-map open/close, pin sizes, pin colors, and map restoration. Keep only one minimap implementation enabled if behavior conflicts.
