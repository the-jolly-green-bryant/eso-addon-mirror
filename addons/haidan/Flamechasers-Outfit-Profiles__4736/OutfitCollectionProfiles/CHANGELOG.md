# Changelog

## 0.3.8
- Confirmed initialization, SavedVariables, slash commands, and secondary events run from the verified `EVENT_ADD_ON_LOADED` flow.
- Confirmed character-ID SavedVariables already keep profiles separated safely between servers.
- Reduced singleton method ambiguity by using direct table functions instead of implicit `self` calls.
- Rechecked global namespace usage, manifest metadata, dependencies, and ESOUI release compliance.
- No profile, collectible, Armory, keybind, or UI behavior was removed.
