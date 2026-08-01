AllianceBuddy.Changelog =
    [[AllianceBuddy Version |c2680743.0|r

This is an (almost) complete rewrite of the addon, now we have a dependency to LibAddonMenu2.0, which lets us choose different options for AllianceBuddy.
These options include:

    -   Show or Hide the UI
    -   Show an additional statusbar for the progress toward Grand Overlord 
        (this is under the main statusbar, if you have progressed more in your current 
        level you will not see it)
    -   As hommage to the earlier version, an option to show the previous UI design 
        (done my Minceraft) changed the statusbar to work with DarkUI.
    -   Change colors of the statusbar, you can either use the default: 
        AllianceColors and PVP color gradient or choose your own 2 colors for the 
        gradient!
        (If the Alliance Colors option is enabled, you will not be able to change 
        the colors of the gradients until you disable it)


Overhauled the design

Added an icon to show if the underdog bonus is enabled or not.

Added a screen announcement once the underdog bonus is enabled / disabled.

Fixed the value of the Statusbar once Grand Overlord Grade 2 has been achieved (it was at 0 therefore no statusbar, now its at 100%)

Changed the rank name to not include the Alliance anymore (kinda redundant with an allianceicon and optional colors)

"Grade 1" and "Grade 2" have been replaced with "I" and "II" respectively to get a tidier look.

Updated the API Version.

Added a percentage counter.

]]
AllianceBuddy.ChangelogOld =
    [[
    (Version 2.7) Updated for Stonethorn
    (Version 2.5) Updated for Harrowstorm.
    (Version 2.3) Updated for Dragonhold.
    (Version 2.2) Removed some Folders who werent necessary for the Add-On!
    (Version 2.1) Edit Scalebreaker 
    Changed the appearance, to work with DarkUI and Added Thousand Seperators.
    Works without DarkUI aswell, only the Frame will changes without DarkUI.

    |ca4a4a4Below are the changes the previous author (Minceraft) made.

    Updated for 1.7! At last, it's here!!!
    Updated for 1.6!
    Version 1.2 -- Fixed a painful bug with the top level window blocking the selecting of core aspects of the UI by the mouse.
    Version 1.1 -- Updated with handlers to hide on menus and inventory being open!!
]]
