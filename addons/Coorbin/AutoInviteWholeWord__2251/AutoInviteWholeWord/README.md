Overview

This is an updated (2019) version of AutoInvite that supports "whole word" matching if you set the input string to begin with an "!".

For example, if you set the input to "!d", it will send an invite if someone says "I would like a DDD!!" but it won't match if someone says "hello dear".

To literally match (only) the string "!d", please set your input string to "\!d" (no quotes).

To match multiple separate strings, put a "|" between each pattern. If you intend to support whole word matching, you must put an "!" in front of EACH PATTERN. 

For example, "/ai !A|B" will match "aaa!", "b", but not "bbb!" because "B" does not have an "!". To match "bbb!", use "/ai !A|!B".

Version 2.6.4 fixes the /aichan command.

Version 2.6.2 adds new chat commands with extended functionality! 

/aichan [channel-list] -- This command allows you to "whitelist" only a specific set of channels to listen for invite requests. The default is to listen on all channels. To restrict the channels to listen on, put a comma-separated list of channel numbers as the parameter. Valid chat channels: 0 = Say, 1 = Yell, 2 = Whisper, 3 = Group, 4 = Outgoing Whisper, 5 = Unused 1, 6 = Emote, 7 = NPC Say, 8 = NPC Yell, 9 = NPC Whisper, 10 = NPC Emote, 11 = System, 12 = Guild 1, 13 = Guild 2, 14 = Guild 3, 15 = Guild 4, 16 = Guild 5, 17 = Officer 1, 18 = Officer 2, 19 = Officer 3, 20 = Officer 4, 21 = Officer 5, 22 = Custom 1, 23 = Custom 2, 24 = Custom 3, 25 = Custom 4, 26 = Custom 5, 27 = Custom 6, 28 = Custom 7, 29 = Custom 8, 30 = Custom 9, 31 = Zone, 32 = Zone Intl 1, 33 = Zone Intl 2, 34 = Zone Intl 3, 35 = Zone Intl 4

/aignadd [name] -- The command stands for "AutoInvite Ignore List Add". Adds a name to your AutoInvite Ignore List. When someone's name is on your AutoInvite ignore list, and they type a string matching your /ai match string, they will NOT be invited to your group. You may have to add both their @handle (with or without the "@") AND their character name, because the addon gets their character name or their @handle variously depending on the channel where the message was sent. Messages sent in guild chat always come with an @handle; messages sent in group chat come with the character name. If in doubt, add both. NOTE: The regular ESO Ignore List is SEPARATE from the AutoInvite ignore list. Putting someone on your AutoInvite ignore list does not prevent you from seeing their messages, and adding someone to your ESO Ignore List will not add them to your AutoInvite Ignore List. However, because your client never sees messages from people on your ESO Ignore List, you cannot auto-invite someone who is on your ignore list, whether or not they are on the AutoInvite Ignore List.

/aignrem [name] -- The command stands for "AutoInvite Ignore List Remove". Removes a name to your AutoInvite Ignore List.

/aignclear -- The command stands for "AutoInvite Ignore List Clear". Removes ALL names from your AutoInvite Ignore List.


This version is based on AutoInvite 2.5.0 and is otherwise equivalent to it besides the new features.

Simple auto-invite addon - intended for use in Cyrodiil to quickly setup a group invite string without diving into menus. Since expanded to be a part of the group tab, but original slash commands still exist for quickly turning on and off.

Features

Slash commands to quickly enable or disable inviting, and regrouping
Stop sending invites when reach group limit
Change the group limit (when to stop invites)
Options panel as separate tab in group menu
Settings (except for actually running) are saved between loads
Option to only invite players in Cyrodiil (for guild invites)
Option to restart invite after someone leaves group
Option to auto-kick members after set amount of time offline
Button to re-form the group
Keybindings to reinvite or regroup the group


Localization
Translations have been provided by the following people

French - Provision
German - silentgecko
Japanese - Lionas
Russian - ForgottenLight


Usage
Open the group menu and there is a tab (far right) for AutoInvite settings. Set the invite string and any other settings then check enable. Now anyone who types that message (exactly) in chat will have an invite sent.

Alternatively you can use the slash commands to quickly start/stop and for when you want to start/stop without opening any menus.

Known Issues/Limitations

The regroup function doesn't work well through group leader bug.
Queue display is not in-order for position in queue.
No right click on the mini-group (for kick, travel to, etc).
Sometimes the mini-group list on the AutoInvite tab doesn't update properly. There is a button included to force an update if that's the case.


Slash commands
These are for very quick access or for debugging purposes.

/ai - Turn off AutoInvite. Emergency stop button of sorts
/ai foo - Set string to 'foo' and start inviting. If you put a ! at the beginning of the string, match any whole word containing that string.
/aidebug - Turn on debug logging to chat window. Note: this can be rather verbose.


Example
You're a raid leader and have some spots to fill.

Type /ai xx in chat message to start listening for 'xx' message in chat
Advertise yourself in chat ("Type xx for Bleakers raid group")
Sit back and let the addon manage sending invites