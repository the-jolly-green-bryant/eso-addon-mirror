# Changelog

## 0.7.8
- Added a verified `EVENT_ADD_ON_LOADED` initialization flow.
- Moved SavedVariables, slash commands, keybind labels, and gameplay event registration into addon initialization.
- Separated settings by megaserver and added migration of the existing window position.
- Confirmed pledge matching uses localized quest and Activity Finder names supplied by ESO.
- Reduced singleton method ambiguity by using direct table functions instead of implicit `self` calls.
- No queue, role, pledge detection, or automatic quest-tracking behavior was removed.
