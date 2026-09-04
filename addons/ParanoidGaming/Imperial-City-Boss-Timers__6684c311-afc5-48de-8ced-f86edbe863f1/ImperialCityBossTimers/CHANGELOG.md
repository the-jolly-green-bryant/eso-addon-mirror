# Changelog

## 1.4.0 — 2026-09-04

- Replaced the 30-second positioning button with an on/off `Preview HUD position` toggle that defaults to off.
- Updated `/icbt preview` to enable that toggle and open settings instead of starting a timed preview.
- Raised the preview HUD above add-on menus while the toggle is enabled.
- Replaced the custom bar texture with ESO's native solid backdrop fill for reliable rendering.
- Assigned explicit draw levels so countdown bars remain above the black window background and below all text.
- Fixed countdown-bar color and opacity changes so they apply immediately to the visible settings preview.

## 1.3.0 — 2026-09-04

- Replaced the dark built-in backdrop fill with a bundled white DDS texture so countdown bars tint true red.
- Restricted the HUD to the normal gameplay scene so it hides in menus and on the world map.
- Added a temporary settings positioning preview that activates from the preview button or X/Y sliders.
- Changed the default position to X 1700 and Y 1000.
- Extended the full countdown bar closer to the countdown and ready-text column without drawing behind it.
- Added a one-time migration that applies the new position and red-bar defaults to existing installations.

## 1.2.0 — 2026-09-04

- Changed the default HUD position to X 100 and Y 100 pixel offsets.
- Reduced the window width, changed the default scale to 65%, and lowered the minimum scale to 40%.
- Turned the window border off by default while retaining an option to enable it.
- Changed district names to white, countdown text to red, and ready text to green by default.
- Changed the completed-timer default from `00:00` to `READY`.
- Made countdown bars solid red with no outline and limited them to the district-name column.
- Added default-on sorting that places active timers first with the shortest remaining time at the top.
- Added a one-time settings migration so existing installations receive the revised layout defaults.

## 1.1.0 — 2026-09-04

- Added a solid background bar for every active district timer.
- Bars shrink smoothly from full to empty as the boss respawn approaches.
- Added an Enable countdown bars option, enabled by default.
- Added countdown-bar color and opacity controls with live settings preview.

## 1.0.0 — 2026-09-03

- Initial release.
- Added all twelve Imperial City Patrolling Horrors across six districts.
- Added automatic combat-death detection, unit-death and recent-reticle fallbacks, plus six-second event de-duplication.
- Added 15-minute default and 7-minute special-event modes.
- Added persistent district timers and automatic ready notifications.
- Added scalable gamepad-friendly HUD with position, color, opacity, and display controls.
- Added automatic settings preview and manual controller-friendly timer controls.
- Added universal `.addon` manifest for PC and console workflows.
