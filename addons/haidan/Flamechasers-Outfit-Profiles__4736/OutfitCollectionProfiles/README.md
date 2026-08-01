# Flamechasers Outfit Profiles

Development disclosure: This addon was developed with AI assistance, then reviewed and tested in game.

Links ESO Collection appearance choices, mounts, and non-combat pets to each character outfit slot.

## Supported categories

- Hats
- Hair Styles
- Head Markings
- Facial Hair
- Major Adornments
- Minor Adornments
- Costumes
- Body Markings
- Skins
- Personalities
- Mounts
- Non-Combat Pets

Polymorphs are intentionally excluded for the first release.

## Use

1. Install the `OutfitCollectionProfiles` folder under `Documents/Elder Scrolls Online/live/AddOns/`.
2. Log in or run `/reloadui`.
3. Enter `/fop`, `/ocp`, or `/outfitprofiles`, or assign **Open Flamechasers Outfit Profiles** in Controls > Keybindings. Each method toggles the window open/closed.
4. Select an outfit slot and configure every category.
5. Choose **Keep Current**, **Remove / None**, or a specific unlocked collectible.

**Capture Current Appearance** copies all currently active supported collectibles into the window as an unsaved draft. **Save Profile** commits that draft. **Apply Draft** previews the displayed choices without saving them.

Assign **Save Collections for Current Outfit** under Controls > Keybindings to capture everything currently active without opening the window. If that outfit already has a saved setup, the addon asks for confirmation before overwriting it.

## Armory support

The addon monitors the outfit slot actually equipped on the character. If an Armory build restores another outfit, its profile is applied after the restoration settles. A periodic state check and delayed Armory passes are both used so this does not depend on the Collections window remaining open.

## Notes

- ESO can temporarily block collectible use during combat, movement, transformations, or other animations. The addon retries and applies the profile again after combat and player activation.
- Collectible changes are queued 2.5 seconds apart to respect ESO's shared appearance cooldown.
- The **Delay** field changes that pause per character. It defaults to 2.5 seconds and accepts values from 0.5 to 10.0 seconds.
- Mount selection changes, but the addon does not mount the character.
- Settings are stored separately for each character because outfit slots are character-specific.
- Profiles are saved by outfit slot index, never by the editable outfit name. Renaming an outfit in ESO preserves its setup, and open addon windows refresh to show the new name.
- Opening the addon automatically enters cursor/UI mode. Closing it returns to gameplay mode only when the addon was responsible for activating the cursor.

## Privacy and dependencies

- No external libraries are required.
- The addon has no network access, telemetry, advertising, or external executable.
- Outfit profiles and settings are stored only in ESO SavedVariables on the user's computer.

## Language support

- The interface text is currently English.
- Collectibles and outfit profiles use ESO IDs rather than English collectible names.
