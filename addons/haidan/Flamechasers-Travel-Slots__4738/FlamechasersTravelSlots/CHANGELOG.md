# Changelog

## 0.7.7
- Replaced dynamic probes for nonexistent POI constants with the documented API 101050 POI type constants used by the addon, and use the current ESO keyboard/gamepad color-picker objects directly.
- Removed redundant nil checks from API results documented as non-nil, while
  preserving checks for genuinely nilable results such as quest-position tasks.
- Removed unreachable house-filter helpers left behind when that UI was intentionally removed.
- Rechecked all remaining API calls, migration code, globals, keybinds, and package contents against the current ESO UI source and ESOUI release guidance.
- No destination, slot, quest-routing, map-button, keybind, customization, or UI behavior was changed.

## 0.7.6
- Removed obsolete API-existence guards and fallbacks after checking every referenced function against ESO API 101050 documentation and the current ESO UI source.
- Use `GetWorldName()` and `GetDisplayName()` directly for server-aware SavedVariables and migration, as guaranteed by ESO.
- Removed the unreachable legacy house-list fallback and retained the current Collections-backed house database.
- No destination, slot, quest-routing, map-button, keybind, customization, or UI behavior was removed.

## 0.7.5
- Added a verified `EVENT_ADD_ON_LOADED` initialization flow.
- Moved SavedVariables, slash commands, keybind labels, and secondary event registration into addon initialization.
- Separated saved travel slots by megaserver to prevent NA, EU, and PTS data from overwriting one another.
- Added automatic migration of existing v0.7.4 slots and window position into the current server profile.
- Replaced English filename/name classification fallbacks with ESO POI type identifiers.
- Reduced singleton method ambiguity by using direct table functions instead of implicit `self` calls.
- No travel slot, destination, keybind, or UI feature was removed.
