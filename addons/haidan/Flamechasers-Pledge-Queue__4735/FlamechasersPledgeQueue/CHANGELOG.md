# Changelog

## 0.7.13
- Added verification of ESO's active group role immediately after selection and
  again before every queue starts.
- Prevented queueing when ESO's active role differs from the role selected in
  the addon window.
- Synchronized verified role changes with ESO's original preferred-role UI and
  its role-change listeners.
- Role cards now dim and disable whenever ESO prevents role changes.
- Added a live queue-role summary and a clearer selected-role indicator.
- Rebuilt the header into a compact layout and replaced `CLOSE` with `X`.
- Refined pledge-card borders, numbering, background contrast, and visual hierarchy.

## 0.7.12
- Fixed detection of the Banished Cells I and Banished Cells II pledge quests.
- Restricted detection to ESO's dedicated Undaunted pledge quest type before
  matching localized dungeon names.
- Added a conservative locale-neutral fallback for Activity Finder names whose
  leading word is omitted from the corresponding localized pledge title.

## 0.7.11
- Registered the shared Flamechasers keybind category and action label before
  ESO parses `Bindings.xml`, preventing the category from appearing as its raw string ID.
- Kept the binding action identifier unchanged so the existing assigned key remains valid.

## 0.7.10
- Removed the remaining unnecessary existence guard around ESO's current Activity Finder root manager and call its verified update method directly.
- Removed redundant nil checks from activity and quest names whose API results
  are documented as non-nil.
- Rechecked every queue, role, quest, cursor, event, SavedVariables, keybind, and UI reference against API 101050 and the current ESO UI source.
- No pledge detection, difficulty selection, queue mode, role, keybind, cursor, or UI behavior was changed.

## 0.7.9
- Removed unnecessary API-existence guards after checking the queue, role, quest, cursor, and SavedVariables calls against ESO API 101050 documentation and the current ESO UI source.
- Use `GetWorldName()` and `GetDisplayName()` directly, as guaranteed by ESO.
- Simplified automatic pledge assistance to ESO's current focused-quest tracker flow.
- No pledge detection, difficulty selection, queue mode, role, keybind, cursor, or UI behavior was removed.

## 0.7.8
- Added a verified `EVENT_ADD_ON_LOADED` initialization flow.
- Moved SavedVariables, slash commands, keybind labels, and gameplay event registration into addon initialization.
- Separated settings by megaserver and added migration of the existing window position.
- Confirmed pledge matching uses localized quest and Activity Finder names supplied by ESO.
- Reduced singleton method ambiguity by using direct table functions instead of implicit `self` calls.
- No queue, role, pledge detection, or automatic quest-tracking behavior was removed.
