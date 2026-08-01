Depends on the following (separately installed) libraries: LibSFUtils, LibAddonMenu

Automatically add Rapid Maneuvers to your skill bar and remove it again. === WHILE YOU ARE NOT IN COMBAT ===

More accurately, this addon allows you to enter and leave "Rapids-mode" in a variety of ways - some of them automatic. "Rapids-mode" is simply when the Rapid Manuever skill (or whatever morph you have) is placed on your active bar in the slot that you specify in the settings. When you are not in "Rapids-mode", your bar is returned to its original assignments. There is also a visual indicator (icon) displayed on screen to tell you if you are or are not in rapids mode
* Gold horse - You are in rapids mode. Rapids is currently on your bar.
* Dark horse - You are not in rapids mode. Your original bar is current.
* Purple (and pink) horse - You were in rapids mode when you entered combat and tried to leave rapids mode in combat (too late). You will have rapids on your bar until you get out of combat. Once you leave combat, rapids will be removed from the bar and you will have your original skills back.

Why the purple/pink horse? It is bright and very distinct from the (also bright) gold horse (both of which tells you that your bar currently has rapids on it).

You control which slot is used to temporarily house the Rapids skill when you are in Rapids-mode with a settings option. When you change active bars while in Rapids-mode, the Rapid Maneuvers skill will be added to the second bar as well. When you leave Rapids-mode, the skill will be removed from the active bar and replaced with whichever skill you originally had there. Likewise, when you swap bars, the original skill will be replaced on the new active bar as well. Since only the active bar can be changed by an addon, if you changed bars while in Rapids-mode then you must change bars again while you are out of Rapids-mode to restore your bars to original settings.

You control when you are automatically put into or removed from "Rapids-mode" through the addon settings. 

Things that can put you into Rapids-mode:
* Mounting your horse or other creature (controlled by setting)
* Pressing the key bound to the Toggle Rapids control binding
* Having the currently active Rapids effect within a certain number of seconds of expiring while you are mounted (controlled by setting)
* Typing /fastride.key in chat

Exiting from Rapids-mode:
* Dismounting from your horse or other creature
* Pressing the key bound to the Toggle Rapids control binding
* Executing the Rapid Maneuvers skill from your bar
* Typing /fastride.key in chat

Any of the techniques for exiting mode can be used after any of the techniques for entering Rapids-mode. So for instance, you can mount your horse, and use the keybind to leave mode instead of dismounting.

In order to use the key binding on your toons, you must set up the key binding for each of your characters that you want it to be setup for. ESO does not provide a way to set a key binding that is remembered account-wide.

Be aware that you do not want to be in Rapids-mode when you go into combat. Due to the limitations of the game, you (and this addon) are not allowed to make changes to the weapon bars while you are in combat. This means that if you are in Rapids-mode (i.e. have Rapid Maneuvers slotted) and someone attacks you, you are stuck with Rapids in that slot until you leave combat again. Therefore, it is in your best interests to be in Rapids-mode for as little time as possible.

Also, if you swap weapons while you are in Rapids-mode, then Rapids will be added to the second bar as well - but will not be removed from the first bar until the first time that you swap back while you are no longer in Rapids-mode. This is because from an addon, you can only change the active belt and the addon is only notified of the new active belt after the former is not active anymore. This can become a problem if you go into Rapids-mode, swap weapons to set 2, go out of Rapids-mode, and then go into combat; your first bar will still have Rapids on it and cannot be changed back until you leave combat. My recommendation is to avoid swapping weapons bars while in Rapids-mode - especially when you are in Cyrodiil and prone to being attacked unpredictably.

Note: If a character has not yet earned the Rapid Maneuvers skill, this addon will do nothing for that character.


For those familiar with the addon "Assist Rapid Riding", while similar in concept this addon was implemented quite differently. What that means for you is that this addon can seamlessly replace and restore the skill when you use either the keybind or autoswapping on mounting or unmounting and can also handle weapons bar swapping.

