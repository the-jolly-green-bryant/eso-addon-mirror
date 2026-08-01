Wings of Wind Guildhall
==========================

Copyright © Viralissa 2021-2025. All rights reserved.

This addon is created for members of the guild "Wings of Wind", to make travelling between guildhall and personal houses easier.

Dependencies:
- [LibCustomMenu](https://www.esoui.com/downloads/info1146-LibCustomMenu.html) (for nice divider between menu entries, it seems)

Optional dependencies:
- [LibAddonMenu-2.0](https://www.esoui.com/downloads/info7-LibAddonMenu.html) (yes, it's optional! without this library you'll not be able to configure this addon though)

Features
- Add button in chat to travel to the guildhall with one click
- Choose 5 personal favorite houses to add them in context menu of this button for travelling inside or outside
- Assign hotkeys for travelling to the guildhall or your favorite houses even easier

Troubleshooting
---------------

If you're experiencing UI errors related to this addon, you can try to disable related UI elements in addon settings.

In case it's not possible to do it by some reason, you can try to disable features by entering special chat commands:

Disable integration with guild leader menu:
```
/script WingsOfWindGuildhall.userSettings.showInGuildLeaderMenu = false
```

Disable all that related to chat button icon:
```
/script WingsOfWindGuildhall.userSettings.showChatIcon = false
/script WingsOfWindGuildhall.userSettings.showMinifiedChatIcon = false
/script WingsOfWindGuildhall.userSettings.showTooltip = false
```

Disable LibAddonMenu usage (requires reloading UI to take effect):
```
/script WingsOfWindGuildhall.userSettings.useLibAddonMenu = false
```

Enable LibAddonMenu back (requires reloading UI to take effect):
```
/script WingsOfWindGuildhall.userSettings.useLibAddonMenu = true
```
