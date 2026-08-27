# Changelog

## 0.4.5
- Replaced ESO's global overwrite dialog with an addon-owned confirmation window so cursor mode remains active until Outfit Profiles is closed.

## 0.4.4
- Kept cursor mode active after closing an overwrite confirmation while the addon window remains open.

## 0.4.3
- Fixed overwrite confirmation prompts rendering behind the addon window.

## 0.4.1
- Fixed dropdown menus rendering behind the main window.
- Matched every dropdown popup to the width of its field.
- Fixed action-button and delay tooltips rendering behind the main window.
- Repositioned tooltips below their controls for cleaner screen placement.

## 0.4.0
- Rebuilt the window with a compact Flamechasers header, clearer profile status, refined category rows, and custom action buttons.
- Replaced **Keep Current** with the clearer **Not Tracked** option and renamed **Remove / None** to **Unequip / None**.
- Profiles now start only when the equipped outfit slot actually changes, including outfit changes made by Armory builds.
- Removed automatic full-profile checks after ordinary loading screens, combat, and same-slot Armory restores.
- Added a resumable apply task that pauses across loading screens and continues only when work remains unfinished.
- Preserved sequential cooldown-safe collectible actions and retries, with a final confirmation pass before the addon returns to idle.

## 0.3.11
- Registered the shared Flamechasers keybind category and action labels before
  ESO parses `Bindings.xml`, preventing the category from appearing as its raw string ID.
- Kept both binding action identifiers unchanged so existing assigned keys remain valid.

## 0.3.10
- Replaced dynamic global lookups with the documented API 101050 collectible category constants.
- Removed fallback values from collectible APIs whose return values are documented as non-nil; retained the explicit fallback for `GetEquippedOutfitIndex()`, whose return is documented as nilable.
- Pass the required player actor category to `IsCollectibleBlocked`, matching its current documented signature.
- Treat the Armory restore result and API-provided names according to their
  documented non-nil return contracts.
- Rechecked outfit, collectible, Armory, event, SavedVariables, keybind, cursor, and UI references against the current ESO UI source.
- No profile, collectible, Armory, keybind, cursor, or UI behavior was changed.

## 0.3.9
- Replaced compatibility-style existence checks with the documented ESO outfit APIs for equipped slot, unlocked slot count, and outfit names.
- Register the documented Armory restore event directly.
- Rechecked API 101050 compatibility, globals, SavedVariables, dependencies, lifecycle, and package structure.
- No profile, collectible, Armory, keybind, cursor, or UI behavior was removed.

## 0.3.8
- Confirmed initialization, SavedVariables, slash commands, and secondary events run from the verified `EVENT_ADD_ON_LOADED` flow.
- Confirmed character-ID SavedVariables already keep profiles separated safely between servers.
- Reduced singleton method ambiguity by using direct table functions instead of implicit `self` calls.
- Rechecked global namespace usage, manifest metadata, dependencies, and ESOUI release compliance.
- No profile, collectible, Armory, keybind, or UI behavior was removed.
