GATHER BUDDY
Version 1.3
Author: @everdeen

Gather Buddy is a lightweight farming-session tracker for The Elder Scrolls Online.

It tracks gathered materials during your current session and displays them in a movable, resizable window.

FEATURES

* Tracks gathered materials during the current farming session
* Automatically combines quantities of the same item
* Alphabetically sorted material list
* ESO item quality colors
* Live session timer
* Total gathered count

SESSION STATS

* Session Stats window
* Session time
* Total gathered
* Unique item count
* Items per hour
* Most gathered item

SESSION HISTORY

* Stores the 10 most recent completed farming sessions
* History shows date/time, session length, total gathered, items per hour and most gathered item
* History sessions can be clicked to open a detailed session view
* Detailed session view shows the complete material list from that session
* Materials are automatically grouped into categories:
  - Blacksmithing
  - Clothing
  - Woodworking
  - Jewelry
  - Alchemy
  - Enchanting
  - Provisioning
  - Fishing
  - Furnishing
  - Other
* BACK button returns from Session Details to the normal History list
* Previous v1.2 History sessions remain compatible with the v1.3 detailed view

RARE MATERIAL ALERT

* Optional on-screen alert for Legendary / Gold quality tracked materials
* Shows up to the 3 most recent rare material alerts
* The newest rare material is displayed larger than previous alerts
* Repeated drops of the same visible material are combined
* New alerts restart the display timer
* Alert automatically fades away
* Adjustable alert duration from 2 to 10 seconds
* Default alert duration is 4 seconds
* Rare Material Alert can be enabled or disabled in Settings
* Preview / Position option makes the alert visible for positioning
* Rare Material Alert position is saved
* Rare Material Alert follows Window Lock and Background Transparency settings

WINDOWS AND UI

* Movable and resizable Main window
* Movable Stats window
* Movable History window
* Movable Rare Material Alert
* Saved window positions and Main window size
* Window Lock option
* Adjustable background transparency
* Independent font size settings for Main, Stats and History windows
* Reset UI Position / Size option
* Reset restores the Main window to its default size and position
* Reset restores Stats, History and Rare Material Alert to their default positions
* Settings panel under Settings -> Addons -> Gather Buddy
* Automatically hides Gather Buddy windows while ESO menus are open
* Continues tracking while the Main window is hidden

SESSION BEHAVIOR

* Session survives /reloadui
* Completed sessions are saved to History after logout/login or CLEAR
* CLEAR archives the current session before starting a new one
* Empty sessions are not added to History
* New session starts after a full logout/login
* Offline time is not counted as session time
* Separate SavedVariables for each ESO server

TRACKING

* Supports Blacksmithing materials
* Supports Clothing materials
* Supports Woodworking materials
* Supports Jewelry materials
* Supports Alchemy materials
* Supports Enchanting materials
* Supports Provisioning materials
* Supports Fishing materials
* Supports rare achievement fish
* Supports selected fishing furnishings
* Supports furnishing materials

COMMANDS

/gbuddy
Show or hide the Gather Buddy window.

/gbuddy lock
Lock the Gather Buddy windows in place.

/gbuddy unlock
Unlock the Gather Buddy windows.

/gbuddy reset
Reset Gather Buddy window positions and restore the Main window to its default size.

SETTINGS

Open:

Settings -> Addons -> Gather Buddy

Available settings include:

* Background Transparency
* Main Window Font Size
* Stats Window Font Size
* History Window Font Size
* Enable Rare Material Alert
* Alert Duration
* Preview / Position Alert
* Lock Window
* Reset UI Position / Size

Background Transparency uses a range from 0 to 255:

0   = solid black
255 = fully transparent

Font sizes can be adjusted independently for the Main, Stats and History windows.

Rare Material Alert duration can be adjusted from 2 to 10 seconds.

REQUIREMENTS

Gather Buddy requires:

LibAddonMenu-2.0

INSTALLATION

1. Extract the GatherBuddy folder into:

Documents\Elder Scrolls Online\live\AddOns\

2. Make sure LibAddonMenu-2.0 is installed and enabled.

3. Start ESO or use /reloadui.

4. Enable Gather Buddy from the Add-Ons menu if necessary.

VERSION 1.3

* Added clickable Session History entries
* Added detailed History session view
* Detailed History sessions now show the complete gathered material list
* Added automatic material categories to Session Details
* Added BACK navigation between Session Details and the normal History list
* Existing v1.2 History sessions remain compatible with the new detailed view
* Improved History session date formatting
* Added automatic History scroll reset when switching views
* Added Reset UI Position / Size option
* Added /gbuddy reset command
* Reset restores Main window position and size
* Reset restores Stats and History window positions
* Added Rare Material Alert
* Rare Material Alert triggers for tracked Legendary / Gold quality materials
* Rare Material Alert displays up to 3 recent rare drops
* Newest Rare Material Alert is displayed with a larger font
* Repeated visible rare materials are combined
* Rare Material Alert automatically fades away
* Added adjustable Rare Material Alert duration
* Added Enable Rare Material Alert setting
* Added Preview / Position Alert option
* Rare Material Alert position is saved between sessions
* Rare Material Alert follows Window Lock
* Rare Material Alert follows Background Transparency
* Reset UI now also restores the Rare Material Alert position

VERSION 1.2

* Added Session History window
* Stores the 10 most recent completed farming sessions
* History displays date/time, session length, total gathered, items per hour and most gathered item
* Completed sessions are automatically archived after a full logout/login
* CLEAR now archives the current session before starting a new one
* /reloadui continues the current session without creating a History entry
* Added independent font size settings for the Main window
* Added independent font size settings for the Stats window
* Added independent font size settings for the History window
* Font size changes are applied immediately
* Font size settings are saved between sessions
* Background transparency now also applies to the History window
* Window Lock now also applies to the History window
* History window follows ESO HUD/menu visibility behavior
* Added Gather Buddy version and copyright information to the Settings panel

VERSION 1.1

* Added resizable Main window
* Window size and position are now saved
* Material list dynamically adjusts to window size
* Added Window Lock
* Added Gather Buddy settings panel
* Added adjustable background transparency
* Background transparency now applies to both Main and Stats windows
* Lock Window now applies to both Main and Stats windows
* Added automatic HUD/menu visibility handling
* Gather Buddy and Stats now hide while ESO menus are open
* Added server-specific SavedVariables
* Updated addon initialization to use EVENT_ADD_ON_LOADED
* Improved gathering item type filtering
* Split addon code into separate modules for easier maintenance

VERSION 1.0

* Initial release
* Farming-session material tracking
* Session timer
* Session Stats
* Material quality colors
* Fishing and rare fish support
* Saved window positions
* /gbuddy show/hide command

Thank you for using Gather Buddy!