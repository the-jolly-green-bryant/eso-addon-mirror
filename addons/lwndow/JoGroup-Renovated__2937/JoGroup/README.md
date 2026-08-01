# JoGroupRenovated
A modernization of the JoGroup unit-frame modification for The Elder Scrolls Online (ESO)

## Overview
JoGroup is an enhancement and replacement for group unit-frames, which is still in development.

### Credits
Based on JoyceKimberly's [original work](https://www.esoui.com/downloads/info1549-JoGroup.html) (2018)

Modified by [batrada](https://www.esoui.com/downloads/info2355-JoGroupUpdated.html) (2019)

Improved by [Deandra](https://www.esoui.com/downloads/info1719-JoGroupQuickUpdate.html) (2020)

This addon uses the following libraries:
* [LibAddonMenu2](http://www.esoui.com/downloads/info7-LibAddonMenu.html)

### Available Slash Commands
```
/jogroup unlock unlocks the frames to reposition them
/jogroup lock locks them again
/rl reloads the ui
/rc perform a ready check
/gl leave your group
/gd disband your group
```

### How To Manually Install:
Go to the "Elder Scrolls Online" folder in your Documents

  For Windows: C:\Users\<username>\Documents\Elder Scrolls Online\<version>\
  For Mac: ~/Documents/Elder Scrolls Online/<version>/

  (replace <version> with the client you're using - "live" or "liveeu")

* You should find an AddOns folder, if you don't, create one.
* Extract the addon from downloaded zip file to the AddOns folder
* Log into the game, and in the character creation screen, you'll find the Addons menu. Enable your addons from there.
* **NOTE**: This installs as `JoGroup` not `JoGroupRenovated` to persist from previous settings.

### Release History
#### 1.9.1 (lwndow)
* API bump for Blackwood
#### 1.9.0 (lwndow)
* API bump for Markarth and Flames of Ambition
* LibStub is banished
* Removal of LibGroupSocket support given the popularity of [Hodor Reflexes](https://www.esoui.com/downloads/info2311-HodorReflexes-DPSUltimateShare.html)
* Possible fix for [commentors](https://www.esoui.com/downloads/info1719-JoGroupQuickUpdate.html#comments) porting into vMoL and other trials having the default group frames be visible again 