# Character Zone Tracker

Elder Scrolls Online addon that tracks zone completion for delves, world bosses and world events per-character.



## FEATURES

- Tracks character zone completion for delves, world bosses and world events.
- Shows completion popup announcements for delves, world bosses and world events on individual characters.
- Adds tools to reset delves, world bosses or world events for a given character and zone. (Keyboard only)
- Adds tools to set a character to load delve, world boss and world event completion from the account for a given character and zone (Keyboard only)
- If run before account-wide achievements were released, backed up zone completion for delves, world bosses and world events.
- If not run before account-wide achievements were released, the zone completion for delves, world bosses and world events will be reset.



## DEPENDENCIES

- [LibSavedVars](https://www.esoui.com/downloads/info2161-LibSavedVars.html)



## ACKNOWLEDGEMENTS

- A very special thanks to the administrators and editors of https://en.uesp.net/. Without them, this addon would not have been practical to write.



## KNOWN ISSUES / PLANNED FIXES

- Compass shows account-wide icons. This is not intended, and will be fixed in a future update.
- No user interface text localization for non-English languages, yet.



## LIMITATIONS

- A game client crash will wipe your progress. To ensure your progress is saved, either relog, or do a /reloadui periodically.
- Progress is tracked in the local SavedVariables folder. Back up your files, preferably to the cloud, to prevent data loss if your storage device fails.
- If your group kills a boss or completes a world event while you are stuck on a load screen, you will not get credit.



## RELEASE NOTES

### Version 1.3.0
- Added tracking support for Craglorn group delves
- Added tracking support for multi-boss delves in all zones, the vast majority being in Craglorn and Cyrodiil
- Added acknowledgements to https://en.uesp.net/ for providing boss names and difficulty data for delves. Thank you!
- Full tracking support added for FR, JP and RU language clients
- Bugfix: Killing side quest bosses in a delve will no longer cause the delve to complete, unless the quest boss just happens to also be the delve completion boss.
- Bugfix: Fix delve or world bosses that have no large boss bar (mostly in older content) not being marked as complete when you don't get the killing blow.
- Bugfix: Fix map pins showing up with account-wide status until an objective is cleared
- Bugfix: Fix map POI menus not appearing for zones your character is not in.
- Bugfix: Fix reset map button not working (regression bug from 1.2.0)
- Bugfix: Multi-boss delve boss kill tracking data will no longer persist in saved vars once the delve is cleared
- Bugfix: Cleaned up old saved vars values that are no longer needed.
- Removed addon description text about backing up Update 32 data, to avoid confusion.
- Moved all localization text to the localization folder
- Small code optimizations

### Version 1.2.1
- Bugfix: Fix error thrown when a world event ends and you are not in range
- Bugfix: Fix errors thrown when hovering over map pins in gamepad mode

### Version 1.2.0
- Replace achievement tooltips in zone guide / map completion with character-specific zone guide tooltips
- Remove code for Update 32 support
- Performance optimizations
- Compatibility patch for addons that mute center screen announcements
- Moved API overrides to EVENT_ADD_ON_LOADED for compatibility with other addons.
- Bugfix: Fix dolmens being marked complete just for being in range of the compass pin when it they are defeated by someone else.
- Bugfix: Fix Traitor's Vault delve in Artaeum not being marked complete
- Bugfix: Fix map POI menus not appearing
- Bugfix: Fix the Murkmire Echoing Hollow world boss not being marked complete when Walks-Like-Thunder is killed.

### Version 1.1.0
- Added support for backing up Craglorn group delve progress. Note: you will need to log in to each character again to add this to your Update 32 backup. Sorry for missing this initially. :(
- Bugfix: Killing a non-boss dangerous monster in a delve with German as the selected language no longer marks the delve complete prematurely.
- Bugfix: Fixes exception thrown when killing a Patrolling Horror in Imperial City
- Bugfix: Fixes exception thrown when killing a dangerous monster in a delve while playing with a language other than English

### Version 1.0.0
- Initial release
- Backs up zone completion for delves, world bosses and world events (dolmens, geysers, etc.) on live (Update 32).
- Tracks character zone completion for delves, world bosses and world events once Update 33 is released.
- Shows completion popup announcements for delves, world bosses and world events on individual characters once Update 33 is released.
- Adds tools to reset delves, world bosses or world events. (Keyboard only)
- Adds tools to set a character to load delve, world boss and world event completion from the account (Keyboard only)
