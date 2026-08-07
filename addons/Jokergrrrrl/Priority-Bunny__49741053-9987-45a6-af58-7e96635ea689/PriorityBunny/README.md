# Priority Bunny — 0.2.0-alpha (Console)

This build replaces the inaccessible custom-keybind setup from 0.1.

## Required console libraries

Install and enable these from ESO's Xbox Add-On browser before enabling Priority Bunny:

1. **LibAddonMenu-2.0**
2. **LibGamepad**

LibAddonMenu provides the standard addon settings definitions. LibGamepad exposes
those settings inside ESO's controller/gamepad settings UI.

## Configure Priority Bunny

After installing all three addons and reloading the UI:

1. Open ESO's in-game **Settings**.
2. Open **Addons**.
3. Select **Priority Bunny**.
4. Set a value from `None` through `5` for each front-bar slot.
5. Set the five back-bar slots separately.
6. Return to play. Numbers should appear over non-empty ability buttons.

This alpha saves numbers by **bar and slot**, not by ability ID. That is deliberate:
it makes the first console settings build simple and testable.

## Updating the published addon

Use the existing Priority Bunny entry in Bethesda's ESO AddOn Uploader. Choose its
update/new-version action and select the complete ZIP. Do not create a second listing.

## First test checklist

- Priority Bunny appears in Settings > Addons.
- All ten slot controls can be changed with the Xbox controller.
- Front and back assignments remain separate.
- The numbers update after leaving settings.
- Weapon swapping keeps each bar's assigned slot numbers.
- No Lua errors appear with Advanced UI Errors enabled.
