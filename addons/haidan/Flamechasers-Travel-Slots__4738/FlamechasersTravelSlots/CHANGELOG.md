# Changelog

## 0.8.6
- Replaced the font-rendered close glyph with a centered texture.
- Gave the help and close icons identical control geometry for consistent alignment at every UI scale.

## 0.8.5
- Visually aligned the circled help icon with ESO's rendered close glyph.

## 0.8.4
- Replaced the header's text-based help marker with a circled help icon.
- Aligned the help icon precisely with the close button and added a matching hover tint.

## 0.8.3
- Moved all permanent mouse and resizing guidance into the window-help tooltip.
- Reserved the footer's status area for actual addon feedback.
- Added compact status messages that remain readable at minimum window width.

## 0.8.2
- Shortened the footer guidance so it remains fully readable at minimum width.
- Added a window-help tooltip explaining resizing and the `/fts reset` command.

## 0.8.1
- Kept the Quick Destinations divider aligned with its heading at compact window widths.
- Hides the divider gracefully when the resized header has no safe horizontal space left.

## 0.8.0
- Added native resizing from every window edge and corner.
- Made the sixteen travel cards automatically resize and reflow between two and six columns.
- Added vertical scrolling when the chosen window size cannot display every slot at once.
- Made headers, dividers, footer text, slot labels, costs, and secondary windows adapt to the resized layout.
- Saved the selected window dimensions alongside its existing server-specific position.
- Added `/fts reset` to restore the default window size.

## 0.7.17
- Reduced the Travel Command Center outer border thickness from two pixels to one pixel while keeping it aligned to the visible window edge.

## 0.7.16
- Moved the outer frame onto the visible window edge, removing the transparent gap.
- Increased the signature-blue frame thickness from one pixel to two pixels.

## 0.7.15
- Added a thin signature-blue frame around the complete main window.
- Added live recall prices to every slot whose current travel action costs currency.
- Refreshes visible recall prices twice per second while the window is open.
- Keeps recall prices hidden for wayshrine-origin travel and free destinations
  such as player houses and the group leader.
- Marks unaffordable recall prices in red without changing ESO's confirmation flow.

## 0.7.14
- Travel Slots now closes automatically when its associated full-map scene closes.
- Pressing ESC while using Travel Slots over the map now dismisses both the map
  and the addon window.
- Used map-scene state detection instead of intercepting ESC, preserving normal
  wayshrine interactions and standalone keybind behavior.
- Included picker, editor, and icon-selection windows in the same map-close flow.

## 0.7.13
- Added an optional Auto-open with Map checkbox in the main-window footer.
- Travel Slots can now open automatically with ESO's full map, whether opened
  with M or through a wayshrine.
- Completing travel from an ordinary M-opened map now closes both Travel Slots
  and the world map.
- Preserved the wayshrine map during wayshrine travel so the existing free-travel
  interaction remains intact.
- Kept automatic opening exclusive to ESO's full world-map scenes, preventing
  minimap addons from triggering it.

## 0.7.12
- Rebuilt the main header into a compact Potion Maker-style layout.
- Replaced the CLOSE label with a standard X button.
- Added a stronger dark opacity layer so the world map is less distracting behind the window.

## 0.7.11
- Reduced and compacted the main-window branding so destinations remain the visual focus.
- Slightly increased the main-window background opacity for better readability over the world map.

## 0.7.10
- Focused Quest travel now enters matching dungeons, trials, arenas, and Infinite Archive directly when ESO exposes a reachable activity travel node.
- Retained nearest-wayshrine routing for quest steps without a direct instance destination.

## 0.7.9
- Fixed the Focused Quest slot retaining the previous quest destination until `/reloadui`.
- The slot now resolves the currently assisted quest whenever it is used and refreshes when the window opens or quest tracking changes.

## 0.7.8
- Registered the shared Flamechasers keybind category and action labels before
  ESO parses `Bindings.xml`, removing the load-order-dependent category split.
- Kept every binding action identifier unchanged so existing assigned keys remain valid.

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
