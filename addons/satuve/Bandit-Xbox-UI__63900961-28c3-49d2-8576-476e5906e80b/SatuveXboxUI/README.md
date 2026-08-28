# Satuve Xbox UI

Satuve Xbox UI is a modified fork of **Bandits User Interface**, adapted and maintained by **Satuve** for the ESO client on PC that connects to Xbox servers and is used with mouse and keyboard.

## Controller settings requirements

The controller settings libraries are installed and enabled separately:

- **Required and shown by ESO under Required Add-Ons:** LibGamepad AddOnVersion 107 (1.0.7) or newer
- **Recommended for the classic settings path and fallback:** LibAddonMenu-2.0 r41 or newer

Open the controller settings through ESO's **Extensions / Manage My Extensions** area and select **Bandit UI**. The Side Panel settings button also opens this controller panel directly. LibGamepad is a required manifest dependency for this console-focused package. LibAddonMenu remains optional because it is used only for the classic settings path and fallback.

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
