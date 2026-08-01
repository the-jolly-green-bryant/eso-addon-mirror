# RecountRenovated
A modernization of the Recount combat modification for The Elder Scrolls Online (ESO) 

## Overview
Recount is a damage meter and combat log addon which is still in development.

### Credits
Based on Fayn's work (original Copywright by him)

Updated and maintained by McGuffin since 0.4.0

Updated by Shadow-Fighter since 0.5.1

Updated by Ferather since 0.6.4

Updated by lwndow since 0.6.4

Ferather branch (https://www.esoui.com/downloads/info2754-RecountUpdate.html) merged to 0.7.x series


This addon uses the following libraries:
- "LibAddonMenu-2.0" (http://www.esoui.com/downloads/info7-LibAddonMenu.html)
- "LibMediaProvider-1.0" (http://www.esoui.com/downloads/info56-LibMediaProvider.html)

### Available Slash Commands
```
/recount
/recount hide
/recount show
/recount min
/recount restore
/recount mode
/recount reset
```

### How To Manually Install:
Go to the "Elder Scrolls Online" folder in your Documents

  For Windows: C:\Users\<username>\Documents\Elder Scrolls Online\<version>\
  For Mac: ~/Documents/Elder Scrolls Online/<version>/

  (replace <version> with the client you're using - "live" or "liveeu")

* You should find an AddOns folder, if you don't, create one.
* Extract the addon from downloaded zip file to the AddOns folder
* Log into the game, and in the character creation screen, you'll find the Addons menu. Enable your addons from there.
* **NOTE**: This installs as `Recount` not `RecountRenovated` to persist from previous settings. 

### Release History
#### 0.7.6 (lwndow)
* API bump for Waking Flame (101031)
#### 0.7.5 (lwndow)
* API bump for Blackwood (100035)
#### 0.7.4 (lwndow)
* add crit markers to incoming values (thanks Tyranok)
* update combat event values to current API spec
* ignore healing done to self to avoid a double log line, only show the inbound heal in that case

#### 0.7.3 (lwndow)
* API bump for Flames of Ambition (100034)

#### 0.7.2 (lwndow)
* API bump for Markarth (100033)

#### 0.7.1 (Ferather)
* Fixed an issue with when text was entered and not a number
* Added damage filters

#### 0.7 (Ferather + lwndow)
* sync'd in Ferather's changes from their 0.6.5 (with permission)
  * The first ability used to enter combat is now tracked correctly.
  * Polished the UI, and updated some UI code.
  * Added damage ignore options to the addon settings menu.
  * **NOTE** (lwndow): My version differs slightly from his as it ignores printing to the log but still tallies for total DPS/HPS 
* fixed auto toggle to damage done, but default this to false in agreeance with Ferather's stance
