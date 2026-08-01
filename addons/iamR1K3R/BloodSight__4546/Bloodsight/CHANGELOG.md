# Changelog

## 1.2.1

- Replaced Simple and Ornate textures with new artwork.
- Shortened "Reset arrow to screen center" button label to "Center arrow" so it stops getting truncated in the settings panel.

## 1.2.0

- **Arrow styles.** Three bundled arrow textures to pick from in the settings panel: Simple (default), Bloody, and Ornate. Swap between them with the dropdown.
- **Distance slider.** Replaces the fixed group-support-range check. Set the maximum range from 5m to 100m. Dead allies and those in a different zone are still always ignored.
- Removed the arrow texture path editbox (superseded by the style dropdown).
- Removed the rotation offset slider and the flip-rotation button. The bundled arrows all point up correctly so these are no longer needed.
- Removed the parallax checkbox. Parallax is always on since it's strictly better than the center-based approach.
- Your existing threshold, delay, arrow size, and arrow position are preserved on upgrade. Arrow style defaults to Simple.

## 1.1.1

- Fixed arrow flicker caused by the periodic reevaluation wiping in-flight debounce timestamps. Now reeval preserves existing state and only prunes entries for units that left the group or no longer qualify.
- Added a guard against redundant nameplate setting writes so we don't ping the game with the same value twice.

## 1.1.0

- **Parallax-aware arrow pointing.** The arrow now accounts for its own screen position when rotating. If you place it at the bottom or top of the screen, it still points correctly at where the ally would appear on screen, not just a direction as if the arrow were in the center. Toggle in settings.
- **Range filter.** New "Only nearby allies" option uses ESO's group support range check (~28 meters). Allies outside that range won't trigger the arrow or bar. On by default.
- **Dead filter.** Dead and reincarnating allies are ignored. If the only wounded ally dies, the arrow and bar immediately stop showing for them.
- **Periodic re-check.** A 500ms ticker re-evaluates group state so deaths, revives, and range transitions are picked up even when no power-update event fires.
- Author set to @R1K3R.

## 1.0.0 (initial release)

- Automatically hides overhead healthbars for group members on load.
- Shows overhead bars and an on-screen blood-arrow when a teammate drops below a configurable threshold for a configurable delay.
- Default threshold: 50%. Default delay: 250 ms.
- Arrow targets the lowest-HP group member when several are hurt.
- Drag-to-position arrow with lock/unlock mode.
- LibAddonMenu-2.0 settings panel with full tuning controls.
- Slash commands: `/bs`, `/bsmenu`.
- Bundled blood-arrow DDS texture at `Bloodsight/arrow.dds`.

