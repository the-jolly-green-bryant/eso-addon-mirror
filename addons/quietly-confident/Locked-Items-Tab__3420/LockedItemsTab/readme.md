# Locked Items Tab Add-on for Elder Scrolls Online
 Author: quietly-confident
 Version: 1.2
 
# Description
Tired of scrolling through locked items that you need for swapping builds but don't really need to see every time you are in your inventory?
This add-on adds a new tab to the player inventory that displays only locked items, whereas locked items are no longer shown in the normal tabs.

# Installation
 - Install the library LibFilters-3.0 by Baertram.
 - Unpack LockedItemsTab.zip to your Users\ ... \Documents\Elder Scrolls Online\live\AddOns folder (this will create the sub-folder 'LockedItemsTab')

# Notes and known issues
 - There are no settings for this Add-on.
 - This Add-on may or may not work with other Add-ons that change player inventory management.
 - Completely untested in gamepad mode.

 # Version history
 - 1.3
     - Fixed an issue where the inventory filter resets after certain actions.
     - Note: the filter may still reset after changing zones when inventory is on the 'Locked' tab.
 - 1.2 
     - Locked button is now the right-most button in the inventory bar (for now, the old position can be enabled by editing LockedItemsTab.lua and changing the buttonOnRight value)
     - Changed order of the sufilters so that the All subfilter is the left-most button, as in the other tabs.
     - Fixed Quest items and crafting bag items sometimes not showing.
     - Added buttons now have an identifier which should make it easier to integrate other Add-Ons.
     - Fixed manifest file to actually have a new internal version number.
 - 1.1 
     - Locked button is now hidden in scenes where locked items are not usable (e.g. sell to vendor.)
     - Replaced scroll icon with padlock icon.
 - 1.0 Initial release


# Disclaimer
This Add-on is not created by, affiliated with, or sponsored by, ZeniMax Media Inc. or its affiliates.
The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States
and/or other countries. All rights reserved.