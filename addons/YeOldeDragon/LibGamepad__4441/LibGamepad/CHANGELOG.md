# Changelog

All notable changes to this project will be documented in this file.

## [1.0.7] - 2026-03-17

🔸Introduced `LibGamepadComponentFactory.lua`: centralized utility module for creating panels, options, submenu entries, and section header markers.
🔸Refactored `LibGamepadOptions.lua` and `LibGamepadLAM.lua` to delegate all structural component creation to the factory, eliminating code duplication.
🔸Fixed dynamic `RegisterOption` injection not consistently applying the default section header.
🔸Fixed setting ID counter in nested LAM submenus now being properly isolated per submenu.
🔸Fixed LAM label resolution: all text fields now go through `GetLAMString`.
🔸Added nil guard on labels.
🔸Sorted LAM extension entries alphabetically in the Gamepad Extensions menu for deterministic display order.
🔸Stripped ESO color markup (`|cXXXXXX...|r`) from addon names before adding them to the menu (and for sorting), so displayed titles remain clean.

## [1.0.6] - 2026-03-16

🔸Fixed a regression where native ESO Gamepad sliders (notably Video → UI scale) could stop applying settings when LibGamepad was active.
🔸Restricted LibGamepad slider template overrides to LibGamepad-owned settings only (`CONST_SYSTEM_EXTENSIONS`).
🔸Added defensive fallback to the native ESO slider handler to prevent future cross-panel template leakage from breaking `SetSetting` flows.

## [1.0.5] - 2026-03-15

🔸Removed an unintended test file that affected some of Dolgubon’s mods. My apologies for that.

## [1.0.4] - 2026-03-15

🔸Fixed a gamepad input lock issue in options navigation that could cause left/right inputs to remain stuck after editing sliders and exiting nested menus.

## [1.0.3] - 2026-03-12

🔸Properly defined the add-on version and dependances in accordance with ESOUI best practices.

## [1.0.2] - 2026-03-12

(Unpublished)

## [1.0.1c] - 2026-03-12

🔸New function to manage ESO main menu content

## [1.0.1b] - 2026-03-12

🔸New UI template for option sliders, showing the minimum, maximum, and current values.
🔸New UI template for descriptions, featuring a smaller font and improved visual presentation.
🔸New UI template for submenu buttons, including a > arrow to indicate that clicking opens a submenu.
🔸Fixed 2 issues while using custom UI elements.

## [1.0.0] - 2026-03-10

🔸Initial release for Xbox/PS4/PS5
