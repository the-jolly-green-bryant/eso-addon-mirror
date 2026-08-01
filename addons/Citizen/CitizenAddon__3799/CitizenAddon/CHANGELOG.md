# 1.1.04 (10/12/2025) (ESOUI UPDATE)
## Notifier
- Apperantly I have made Banner and Alert UI not movable and the show button useless somewhen somehow... Fixed
## PVE Content
### RG
#### Bahsei
- Removed the unregistor of MTT refresh function upon death, who cares, let it count to 0, its more efficient than adding code to reset it
- Fixed the Mouldering Taint Tracker timer and made it a little bigger
- Mouldering Taint Tracker is out of BETA

---

# 1.1.03 (12/11/2025) (ESOUI UPDATE)
- Fixed the issue that was caused by saved vars migration function for people who didnt had my addon before
- Fixed API and LAM2.0 version

---

# 1.1.02 (12/11/2025) (ESOUI UPDATE)
- Just removed some folders, removed some codes and etc to clean up for ESOUI release

---

# 1.1.01 (23/5/2025)
## Notifier
- Fixed issue for OSI that would even cause mid-fight loading screen if one person get an Stackable OSI than a non-Stackable one
## PVE Content
### RG
#### Bahsei
- Fixes and changes in Mouldering Taint Tracker

---

# 1.1.00 (19/9/2025)
## General
- Moved varibles that were not in sub table, to sub tables, well... this made savedVariables from old versions useless;
    There for savedVaariables are now Version 2;
    Added a saved vars migration funcion to sync v1 to v2
## Menu
- Removed Refresh group lists button
## Ability options
- Created
## Set options
- Created
## PVE Content
- Created
### SWR
#### Foreman Bradiggan
- Removed Soul Bomb tracker;
    Honestly too lazy to finish, and it was not that good of a idea anyway
### RG
#### Bahsei
- Added Mouldering Taint Tracker

---

# 1.0.05 (3/4/2025) (ESOUI Update)
## General
- Changed most of the XML code to LUA API, and this allowed me to make some other changes in them too, all leaded to better performance
- Added "stackable" option for OSI floating icons
## CR
- Fixed the issue that arrow icon wont disappear when carries dies not drop it

---

# 1.0.04b (22/3/2025)
## General
- Well, yes, last change broke entire addon, so Events are back to manual

---

# 1.0.04a (22/3/2025)
## General
- Changed all of the manual Event Registors and Unregistors to automatic tables;
    Possibly Fxxked entire addon, let see
- Changed Floating Icons with timer, now they can show timer inside of the icon, and stay after if needed untill they get removed
## CR
- Removed timer for Galenwe Hoarfrost OSI, it will despear when carrier drops it

---

# 1.0.04 (20/3/2025)
## General
- Fixed publication date recorded in CHANGELOG.md for update 1.0.03c, was written 13/8/2024, but should have been 13/6/2024
## CR
- Added OSI for Galenwe Hoarfrost
## SE
### Archwizard and Chimera
- Added floating icon number for portal crystals (Synced with SanitysEdgeHelper)

---

# 1.0.03c (13/6/2024) (ESOUI Update)
## General
- Removed Commands Global Functions and moved them inside the CommandHandler
## General options
### Marker
- Changed CitizenMarker.reverseIconData from a hand written table to a automatic reverse version of CitizenMarker.iconData with a "for" loop
- Added alphabet icons from Bitrock's Elm's Markers, version 3.1.0
## Combat options
### Nearby Members
- Removed isUnitInSupportRange() checker;
    Becasue apperantly "Support Range" is only 30m?!
    Added IsGroupMemberInSameLayerAsPlayer() instead to avoid unnecessary calculations
- Moved DD Only option checker to before distance calculations, this will add more repeated code lines but it will avoid unnecessary calculations

---

# 1.0.03b (14/5/2024)
## General
- Changed the positions of addon's options initializations to before the lines about Group managers options;
    This will fix the issue caused by the new changed on fragments, because it was trying to add a fragment that was not initialized yet;
    Strangely it was only happening after a reload UI while player is in group, but not on game start up while is in group;
## Blackrose Prison
- Added Stage 2 spawn points to OSI spawn locations
- Changed OSI spawn locations to Beta3
- Changed time difference requested between waves portal spawns to be counted as a new wave to 700ms from 2000ms;
    Because there is a skip in Round 2 than can cause 2 waves to be spawn at same time, hopfuly 700ms is low enough, might need adjusment later
- Added OSI spawn locations option to normal difficulty options too

---

# 1.0.03a (9/5/2024)
## General
- Changed that instead of having a fragments table and than add all with AddFragmentGroup to HUD_SCENE and HUD_UI_SCENE, it will add each fragments individually;
    with this change I have more control to add/remove or hide fragments from main screen
- Added ESOUI release marks to CHANGELOG
## Combat options
### Nearby Members
- Added live show of chosen range
- Added a DD only mode;
    Added an UI for it
- Changed the color theme from white to black
- Moved the range UI checker out of the Refresh function, added it inside the Menu slider function;
    So it will not keep getting unnecessary refreshes and only get refreshed when there is a change in requested range;
    Added another range UI checker inside the main Initialize function to fix the disappearance on game startup or after a reload UI
- Fix the problem that number was stuck at 12 if range was set to 36m
- Changed it to exclude dead members;
    Added a notificion about it in the menu tooltip
- Changed refresh rate to 350 from 300
- Changed it to be deactive if Player is not in the group

---

# 1.0.03 (3/4/2024)
## General
- Fixed some spelling problems in the Menu
- Made an ESOUI.txt file for ESOUI.com Add-on Info page
## Combat options
- Added Nearby Members option
## RG
### Bahsei
- Fix the problem that Bleed tracker was active even when it was Off in settings if you had Bleed OSI active

---

# 1.0.02c (3/2/2024) (ESOUI release)
## General
- Apperanly AddOnVersion in .txt file have to be ONLY integer, so changed the last alphabet latter to number (a=1, b=2, c=3 and ...) from now on
- Added release dates to CHANGELOG
- Some Trims in Menu
- Changed all the options to be deactive by default, except: BRP.waveIcons and CA.varallion.mindLinkOsi
- Removed CitizenNotifier.OSI.icons to use CitizenMaker.iconData instead
- Removed CitizenAddon.playerDisplayName and CitizenAddon.playerGroupUnitTag and made an CitizenAddon.player table with displayName and groupUnitTag in it
- Edited CitizenAddon.group.unitDisplayName to make indexs be match with group unit tag indexs;
    Moved inside of "If IsUnitPlayer" statement
## DSR
### Trash Fight
- Decreased Brew Master Potion OSI duration from 15000 to 10000, because majority of fights take ~10s anyway
## SS
### Nahvi
- Fixed some issues for timers when you are in portal

---

# 1.0.02b (29/1/2024)
## General
- Moved all the options and EVENTs behind If statements and added Request Reload UI warning to all the options;
    This means if you enter a zone with at least one active option related to the zone, you do not need reload UI for activing
    or deactiving other options related to that zone, but if enter the zone with no active option related to the zone, you will need
    reload UI for activing or deactiving options;
    due to complex of the scenario, added Request Reload UI warning to all the options to avoid any inconveniency
## General Options
### Real Time Clock
- Changed Real Time Clock tick rate from 2500 to 750;
    added a switch to change to 60000 tick rate at exact beginning of a minute;
    added another switch to go back to 750 tick rate in case of getting desynced for more then 2s to make it sync again
### Marker
- Added some icons that was in OSI but not in my list or Elm'sMarker list
- Incrased the size of visibleRows in menu to 6 from 5
## Sunspire
- HOPE-FXXKING-FULLY SXXTS WORK FINE NOW
- Removed all the SS options out of BETA
- Changed Fly Tracker to show from 15% instead of 12%;
    so Nahvi Portal Spawn Tracker (New feature) will be shown 5% before hand instead of 2%;
    with this change there is no need for additinal EVENTs and Code Lines for Nahvi Portal Spwan tracker
### Nahvi
- Trimed Eternal Servent interrupt
- Added portal spawn tracker with-in Boss Fly Tracker for this boss
## RG
### Bahsei
- Separated Bleed OSI and Bleed tracker of each other

---

# 1.0.02a (13/1/2024)
## General
- Lots of changed in death tracker and group tracker
- Added a CitizenAddon.playerGroupUnitTag for player's group unit tag
## Sunspire
- Fixed Flying tracker (1.0.02b update; apperantly not fixed yet)
### Lokke
- Added Laser beam timer (1.0.02b update; apperantly not working)
- Added Laser beam OSI locations (1.0.02b update; apperantly not working)
### Nahvi
- Fixed Portal Wipre timer
## Blackrose Prison
- Changed OSI spawn locations to Beta2
- Changed OSI spawn locations to be pre-spawn rather then on-spawn
- Chnaged big adds OSI size from +48 to +24, added small adds icon size a -24
- Chnaged spawn locations icon duration defualt to start counting after wave spawns, changed defualt value from 7s to 3s

---

# 1.0.02 (23/12/2023)
## General
- Added missing Unregistors for SS and BRP event listers
- Added a general death tracker
## BRP
- Added adds spawn locations OSI Beta1 version
- Changed defualt OSI spawn location duration to 7s

---

# 1.0.01a (23/12/2023)
## General
- Some trims in menu texts
- Commented GroupMemeberCleaner function
- Removed CitizenNotifier.sound to use ingame sound play with no table
- Removed CitizenNotifier.OSI.color to not using table
## General options
### Real Time Clock
- Added Real Time Clock cretids in .txt
- Chaned Real Time Clock update rate from 2000 to 2500
## DSR
### Taleria
- Added Behemoth Crush attack CombatAlert progress bar and Sound alert
- Added Sirens Lure Of The Sea CombatAlert progress bar
## BRP
- Added adds spawn locations OSI Alpha1 version

---

# 1.0.01 (23/12/2023)
## General
- Changed the credits one time popup to a key inside the menu
- Moved general functions from CitizenAddon to CitizenFunctions
- Moved Marker saved positions table from CitizenAddon to CitizenMarker
## General options
- Added Real time clock options
## Menu
- Added icons to menu
- Added information footer
- Changed headers colors from cdfffd to bfffff
## Sunspire
### Nahvi
- Added statue StoneFist CombatAlert progress bar
- Added portal Wipe Timer
- Added portal Entrance Timer
- Added portal Eternal servent Interrupt CombatAlert progress bar
## DSR
### Reef
- Added acid reflux CombatAlert progress bar
### Taleria
- Added clock Numbers on map OSI
- Added Behemoth Hack attack CombatAlert progress bar and Sound alert

---

# 1.0.00 (19/10/2023)
- Released