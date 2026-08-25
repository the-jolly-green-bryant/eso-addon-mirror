GATHER BUDDY
Version 1.1
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
* Session Stats window
* Items per hour
* Unique item count
* Most gathered item
* Movable and resizable main window
* Saved window position and size
* Window lock option
* Adjustable background transparency
* Settings panel under Settings -> Addons -> Gather Buddy
* Automatically hides while ESO menus are open
* Continues tracking while the window is hidden
* Session survives /reloadui
* New session starts after a full logout/login
* Separate SavedVariables for each ESO server
* Supports gathering materials, fishing, rare fish and selected fishing furnishings

COMMANDS

/gbuddy
Show or hide the Gather Buddy window.

/gbuddy lock
Lock the Gather Buddy windows in place.

/gbuddy unlock
Unlock the Gather Buddy windows.

SETTINGS

Open:

Settings -> Addons -> Gather Buddy

Available settings include:

* Background Transparency
* Lock Window

Background Transparency uses a range from 0 to 255:

0   = solid black
255 = fully transparent

REQUIREMENTS

Gather Buddy requires:

LibAddonMenu-2.0

INSTALLATION

1. Extract the GatherBuddy folder into:

Documents\Elder Scrolls Online\live\AddOns\

2. Make sure LibAddonMenu-2.0 is installed and enabled.

3. Start ESO or use /reloadui.

4. Enable Gather Buddy from the Add-Ons menu if necessary.

VERSION 1.1

* Added resizable main window
* Window size and position are now saved
* Material list dynamically adjusts to window size
* Added Window Lock
* Added Gather Buddy settings panel
* Added adjustable background transparency
* Background transparency now applies to both main and Stats windows
* Lock Window now applies to both main and Stats windows
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
