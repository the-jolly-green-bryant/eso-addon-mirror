Companion Rapport
Author: Bankroll
Version: 2.0.2

INSTALL
Extract the CompanionRapport folder into:
Documents\Elder Scrolls Online\live\AddOns

Requires LibAddonMenu-2.0 to be installed and enabled.

WHAT THIS BUILD CHANGES
- Overlay no longer auto-scales based on companion text.
- Overlay uses a fixed box size for every companion.
- Added AddOn Settings sliders for Overlay width / X size and Overlay height / Y size.
- Text font size stays unchanged when the overlay box is resized.
- Overflow text remains locked inside the overlay and scrolls within the box.
- X/Y position sliders still move the overlay and preview it while adjusting.

COMMANDS
/crapport          Refresh/show if allowed by the current settings
/crapportoverlay   Toggle anchored overlay
/crapportreset     Reset overlay offsets
/crapportdebug     Print debug info

NOTES
ESO's companion menu control names can differ between keyboard/gamepad and game versions. The add-on uses guarded checks and fallbacks so it does not break if a specific ZOS control name is unavailable.

2.0.0: Fixed-size overlay with width/height sliders. Resizing the overlay does not change text size.

Defaults in this build:
- Overlay width: 540
- Overlay height: 900
- Overlay X position: 80
- Overlay Y position: -70
- Right Analog Stick scrolling remains enabled, with no AddOn Settings toggle.


2.0.3
- Shows current active companion rapport next to the companion name in green as current / 5500 Max Rapport.


2.0.4: Added /crmenu settings shortcut, relationship rank display, and companion summoned relationship message.


2.1.0: Added rapport change system messages: +1 to +24 lime green, +25 and above gold-yellow, negative changes red, followed by current rapport progress and next rank.
