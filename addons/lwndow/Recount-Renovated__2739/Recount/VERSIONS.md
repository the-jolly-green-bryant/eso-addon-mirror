#### 0.6.5 (lwndow)
* added option for account-wide settings vs per-character

#### 0.6.4 (lwndow)
* updated to API 100031 (Greymoor) & 100032 (Stonethorn)
* removed libstub dependency
* added hard dependencies, removed embedded libs (you need to grab them from ESOUI/Minion)
* added request from forum to ignore values below a certain threshold in the log

#### v0.6.3 (Shadow-Fighter)
* updated to API 100024

#### v0.6.2 (Shadow-Fighter)
* updated LibAddonMenu-2.0 r24 to LibAddonMenu-2.0 r26

#### v0.6.1 (Shadow-Fighter)
* updated to API 100023

#### v0.6.0 (Shadow-Fighter)
* updated to API 100021

#### v0.5.9 (Shadow-Fighter)
* able to change font face, size, color from settings menu

#### v0.5.8 (Shadow-Fighter)
* updated LibAddonMenu-2.0 r17 to LibAddonMenu-2.0 r24

#### v0.5.7 (Shadow-Fighter)
* updated to API 100020

#### v0.5.6 (Shadow-Fighter)
* updated to API 100019

#### v0.5.5 (Garkin)
* updated from LibAddonMenu-1.0 to LibAddonMenu-2.0
* added LibMediaProvider-1.0 support
* minor changes

#### v0.5.4 (Shadow-Fighter)
* updated to API 100011 (Update 6)
* minor changes

#### v0.5.3 (Shadow-Fighter)
* Added "COPYRIGHT" file
* Removed Zos disclaimer from Recount.txt and added into COPYRIGHT file
* Added credits to Seerah's LibStub and LibAddonMenu into COPYRIGHT file

#### v0.5.2 (Shadow-Fighter)
* Added "ReadMe.rtf" file (this document)
* Updated LibAddonMenu-1.0
* Enabled the settings menu again

#### v0.5.1 (Shadow-Fighter)
* Settings menu is temporary disabled to work with the Update 5
* Addon menu revised to Update 5
* API Version updated to 100010 (Update 5)

#### v0.5.0 (McGuffin)
* Updated api version
* Added an option to disable auto show/hide switches. If enabled, the RecountUI can only be toggled through command shortcuts
* Added Zos disclaimer in Recount.txt

#### v0.4.9 (McGuffin)
* using a self damage skill (like equilibrium) doesnt start a new combat session anymore

#### v0.4.8 (McGuffin)
* Added a shortcut to switch modes backward. The existing one still switches modes forward.
* The dps is now calculated with a minimum 1 second timeframe, to avoid crazy unrealistic spikes.
* Added a player death detection to fix a ZOS bug, when sometimes, the end of combat event never triggers as it should when the player dies 
* The out of combat trigger is now slightly postponed, in order to avoid an issue when the combatlog_events are not perfectly synchronized with other combat_events
* The actual combat session also starts when a player enters the game in a middle of a fight (or if the user triggers a reloadUI during combat.)

#### v0.4.7 (McGuffin)
* Fixed a (badly declared) local var that had a bad side effect.

#### v0.4.6 (McGuffin)
* added an option to set critical/tick tag in the combatlog
* the Recount UI should not popup again after a gameUI close if it was hidden before.

#### v0.4.5 (McGuffin)
* Total dps/hps are now computed throught active combat duration.
* Added a timestamp in the combatLog section
* small cleanup

#### v0.4.4 (McGuffin)
* added keybinding for "toggleShow", "reset", and "toggle mode"
* You can scroll over both combat log and skill stats
* fixed scroll limit for skill stats

#### v0.4.3 (McGuffin)
* Recount now hides itself while the player is in game UI (map, inventory etc.)
* You can scroll the statistics bars with the mousewheel on mouseOver (This doesnt work with the combatlog yet, only bars)
* Small code fixes

#### v0.4.2 (McGuffin)
* Recount should now correctly shows/hides itself while in/out combat with the "hide in combat" setting.
* Dps calculation is now more strict and datas are only collected during combat
* Skill Bar refresh is frequency has been reduced and streamlined

#### v0.4.1 (McGuffin)
* added an option in option menu that allows to not show each skill crit/hit statistic
* Self damages (like equilibrium) are now excluded from dps calculation

#### v0.4.0 (McGuffin)
* added critical strikes statistic. Values are separated in each skill for periodic and direct damage/heal.
* default fonts has been reevaluated
* max % of bars now fits the skill that has max value
* fixed some nil errors
* updated last libs

#### v0.3.2 and previous versions (Fayn)