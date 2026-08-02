# Changelog

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
