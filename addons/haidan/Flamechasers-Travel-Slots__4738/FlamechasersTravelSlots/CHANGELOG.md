# Changelog

## 0.7.5
- Added a verified `EVENT_ADD_ON_LOADED` initialization flow.
- Moved SavedVariables, slash commands, keybind labels, and secondary event registration into addon initialization.
- Separated saved travel slots by megaserver to prevent NA, EU, and PTS data from overwriting one another.
- Added automatic migration of existing v0.7.4 slots and window position into the current server profile.
- Replaced English filename/name classification fallbacks with ESO POI type identifiers.
- Reduced singleton method ambiguity by using direct table functions instead of implicit `self` calls.
- No travel slot, destination, keybind, or UI feature was removed.
