# Satuve Xbox UI

Satuve Xbox UI is a modified fork of **Bandits User Interface**, adapted and maintained by **Satuve** for the ESO client on PC that connects to Xbox servers and is used with mouse and keyboard.

## Controller settings requirements

The controller settings libraries are installed and enabled separately:

- **Required and shown by ESO under Required Add-Ons:** LibGamepad AddOnVersion 107 (1.0.7) or newer
- **Required:** LibAddonMenu-2.0 r41 or newer

Open the controller settings through ESO's **Extensions / Manage My Extensions** area and select **Bandit UI**. The Side Panel settings button also opens this controller panel directly. Both libraries are required manifest dependencies for this console-focused package. Install the newest Xbox versions available; the manifest accepts LibGamepad AddOnVersion 107+ and LibAddonMenu-2.0 AddOnVersion 41+.

## Credits

- Xbox adaptation, packaging and maintenance: **Satuve**
- Original Bandits User Interface: **secretrob**, **Hoft**, and contributors
- Portions of the original project were based on Foundry Tactical Combat by **Atropos**

Thank you to the Bandits UI authors and contributors for the original foundation.

## Changes in 1.0.0-xbox

- New add-on identity, folder and `.addon` manifest
- Separate SavedVariables to avoid collisions with the original add-on
- All runtime texture paths changed to `SatuveXboxUI`
- Xbox-server PC compatibility fixes from the prior test build
- Added `/sxui` and `/satuveui` diagnostic commands
- Keyboard/mouse mode detection retained for this client configuration
- Quickslot, regrouping, localization and custom-bar fixes included

## Installation

Extract the folder `SatuveXboxUI` into the add-on directory used by your ESO Xbox-server PC client. Do not install it alongside an enabled copy of the original Bandits User Interface because both still use parts of the internal `BUI` Lua namespace.

## Xbox memory and add-on compatibility

- **SatuveXboxUI replaces Bandits User Interface. Never enable both together.** Both add-ons still use the global `BUI` namespace, `BUI_*` controls, event/update names, slash commands, and keybinding actions. Load order cannot make that combination safe.
- `LibGamepad` 1.0.7 or newer must be installed and enabled. `LibGamepadContextMenuBridge` is a different library and does not satisfy this dependency.
- Avoid enabling overlapping unit-frame, action-bar, reticle, or minimap modules from AUI, LUI Extended, or another full UI add-on at the same time. Disable the overlapping module in one add-on before testing the other.
- The runtime now keeps at most 12 completed unsaved combat reports. Reports explicitly saved by the player remain available.
- The packaged textures occupy about 8 MiB when decoded to RGBA if every texture were resident at once. The largest curved-frame textures are only referenced when the curved-frame option is enabled, so leave that option off on memory-constrained systems unless it is needed.

## Version 1.7.9

- Frame Edit Mode now explicitly activates ESO's User Interface Shortcuts action layer when the launching console menu did not keep it active, so D-Pad/A/B reach the exclusive editor keybind state.
- The left stick can also select frames with release-to-repeat debouncing; both sticks continue to move the selected frame after A is pressed.
- Minimap numeric settings use finite controller value lists on Xbox instead of unreliable native slider rows. The original numeric steps and setFunc callbacks are preserved.
- LibGamepad 1.0.7+ and LibAddonMenu-2.0 r41+ are required. Install their newest Xbox versions; LibGamepadContextMenuBridge is not a replacement.

## Version 1.7.8

- Replaced the Frame Edit Mode `DIRECTIONAL_INPUT:GetXY()` path that caused ESO to reject the private `IsKeyDown` call from add-on code.
- D-Pad Up, Down, Left and Right now use ESO's modal keybind strip and select frames without invoking protected input APIs.
- The underlying ESO/Bandit settings list stays deactivated while editing; A, B and D-Pad input remain exclusive to the Frame Editor and normal focus is restored on exit.
- Kept left/right-stick frame movement, frame-positioning calculations, Minimap slider behavior, SavedVariables and localization unchanged.
## Version 1.7.7

- Frame Edit Mode now receives D-Pad selection through ESO's native `DIRECTIONAL_INPUT` and `ZO_MovementController` path. This fixes frame selection on Xbox where raw `OnKeyDown` events were not delivered reliably.
- The editor consumes controller directions while open and releases its directional-input owner before restoring the settings list, so no menu behind it can react.
- Minimap controller options use the bridge's native gamepad slider rows again. Size, opacity, pin scale and zoom values change by their configured steps and apply immediately.
- Verified group-frame selection and movement, repeated entry/exit, modal input isolation, A/B behavior, minimap slider setters, and Lua syntax.

## Version 1.7.6

- Fixed Xbox A-button activation in Frame Edit Mode. The focused editor now passes physical A/B buttons to its exclusive ESO keybind state instead of consuming A before UI_SHORTCUT_PRIMARY can run.
- A now grabs a selected frame and confirms/releases it after movement. B cancels the current movement and restores that frame's grab-start position.
- Added the native Skills / Action Bar frame to controller editing.
- Added opt-in editor tracing with BUI.FrameEditor:SetDebug(true).
- Verified Minimap and Skills selection, A grab, left/right-stick movement, A placement, save, close, reopen persistence, modal input isolation, and repeated open/close cleanup.

## Version 1.1.65

- Frame Edit Mode now owns controller input while open. D-Pad and A cannot navigate or activate the settings list behind it, and B restores normal settings focus when the editor closes.
- The minimap uses ESO's native map mode and fragment with recovery for login, travel, map scenes, gamepad changes, and temporarily missing map controls.
- Reduced Xbox memory and CPU pressure by reusing player-resource state, skipping unchanged redraws, lowering the fallback refresh rate, and limiting unsaved session combat history to 12 completed reports.
- Reduced add-on conflicts with Satuve-specific delayed callback names and a template guard scoped to native controls whose positions are owned by Satuve.
- Added compatibility documentation and an expanded Xbox acceptance checklist.

## Version 1.1.63

- The gathering-navigation feature was extracted into the independent `SatuveResourceNavigator` add-on.
- SatuveXboxUI no longer owns its settings, HUD controls, events, routes, node data or optional HarvestMap integration.
- The minimap, normal map handling, combat UI and other Bandits UI systems are unchanged.

## License

The original package includes an MIT-style permission notice. This fork keeps the original attribution and permission notice in the manifest. No affiliation with ZeniMax Media Inc. or Microsoft is claimed.


## Version 1.0.2
- Fixed startup crash in BUI_Events.lua when CHAT_SYSTEM is not initialized yet on Xbox-PC.
- Startup messages are now queued until chat is available.


## Version 1.0.3 Xbox fix
- Added a safe fallback for clients where the legacy `MAX_BOSSES` constant is unavailable.
- Boss frame loops now use a validated numeric boss count.


## Version 1.0.4 Xbox compatibility
- Uses the effective maximum resource value returned by GetUnitPower so Health, Magicka and Stamina match the ESO character display.
- Adds a safe GetClassIcon compatibility helper for Xbox-PC clients.


## 1.0.5 Xbox compatibility fix
- Added a fallback for clients without `IsWerewolf()`.
- Protected mount, werewolf, and siege alternate-resource bars from missing or zero maximum values.


## 1.0.10 Xbox fixes
- Safe side-panel placement when the keyboard chat controls are unavailable.
- Player resource frame position is restored after death and HUD rebuilds.
- Added a 35-pixel gap between the player resource frame and the action bar.


## 1.0.28-xbox
- Keep the native ESO top boss-health fill texture so the red fill stays inside the boss-bar frame/brackets.


## v1.0.34-xbox
- Restored the top boss-bar adjustment from v1.0.29.
- Kept the syntax/loading safety correction from v1.0.30.
- Removed the later boss-frame/background shifting experiments.

## Version 1.1.28

- Documented the libraries and location required for controller settings.
- The Side Panel settings button opens Bandit UI's LibGamepad panel directly.
- Side Panel mouse tooltips use a readable gamepad font in controller mode.
- Restored page 21, Meters, in the controller menu.

## Version 1.1.29

- LibGamepad is now declared as a required dependency so ESO displays it under Required Add-Ons.
- LibAddonMenu-2.0 remains listed as an optional/recommended dependency.
- Minimap size values are normalized, saved and applied directly to every existing Minimap control.
- Minimap resizing no longer rebuilds event and scene callbacks.

## Controller layout and native minimap

The Misc page has Frame Edit Mode for D-Pad selection, two-stick positioning, preview, save, and cancel. The Bandit minimap settings drive a native ESO map-mode adapter instead of the old shared-scroll viewport. Existing settings and SavedVariables are retained. See `XBOX_TEST_CHECKLIST.md` and `RELEASE_NOTES_1.7.7.md`. Real Xbox acceptance testing remains recommended.

The map behavior was researched against Votan's Minimap 2.2.2, but its release package provides no code-reuse license. This adapter was written independently; standalone Votan should not be enabled alongside this Bandit minimap because both use ESO's world map.
