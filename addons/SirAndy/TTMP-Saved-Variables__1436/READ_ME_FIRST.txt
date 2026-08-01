
Author:		SirAndy
Contact:	http://www.thesidekickorder.com/bbs2/index.php?showtopic=172


=========================================
IMPORTANT - ACHTUNG - ATTENTION - WICHTIG
=========================================
If you already have TTMP installed, do *NOT* simply overwrite your "SavedVariables" file with a newer versions!
DON'T DO IT! There really is no reason to ever replace the "SavedVariables/TamrielMapping.lua" file directly.
You will lose everything you have ever mapped yourself!

Only use the file in the "SavedVariables" folder if:

- This is your first install of TTMP and you want to start with my asset file instead of creating your own (empty) file.
- You already have TTMP and you want to merge my asset file with yours. If so, follow the TTMPMerge instructions!


=========================================
TTMP Chat Commands:
=========================================
For a full list of TTMP chat commands, scroll down to the "TTMP Usage" section.


=========================================
Currently tracked Assets:
=========================================
Blacksmithing Nodes - automatic
Woodworking Nodes - automatic
Clothing Nodes - automatic
Solvent Nodes - automatic
Enchanting Runes - automatic
Alchemy Nodes - automatic
Treasure Chests - automatic
Backpacks - automatic (unless they are empty)
Heavy Sacks/Crates - automatic
Treasure Maps - manual
Dark Fissures - manual
Fishing Holes - manual
Skyshards - manual
Lorebooks - manual
Quests - manual
Crafting Surveys - manual
Points of Interest - manual
Thieves Troves - automatic
Safeboxes - automatic

=========================================
Installation/Update:
=========================================
Simply unzip the download and copy the 'TamrielMapping' folder into your ESO "AddOns" folder and restart ESO.
If you're updating to a newer version, simply replace the whole folder.


=========================================
Using my Asset file:
=========================================
If you don't want to start fresh, you can use my latest "SavedVariables" file, which already has over 20,000 tracked assets.
Simply drop my "SavedVariables/TamrielMapping.lua" into your ESO "SavedVariables" folder, open it with a text editor and replace "@YourNameGoesHere" with your actual ESO account name.

NOTE:
Please make sure your text editor supports utf8, especially if you're playing in French or German!


=========================================
Updating your Asset file:
=========================================
If you have already used TTMP, you can use my "SavedVariables/TamrielMapping.lua" file and the TTMPMerge AddOn to merge my asset file with your existing one.
In fact, you can merge files from any other TTMP user as well.

USAGE:
To use TTMPMerge you need to:

- Get my (or someone else's) "SavedVariables/TamrielMapping.lua" file
- Rename it to "TTMPMerge.lua"
- Copy it into your "SavedVariables" folder
- Open it with a text editor (make sure your text editor supports utf8!) and replace "TamrielMapping_Vars" in the first line with "TTMPMerge_Vars".
Also replace their Account Name "@xxx" in line 5 with your actual ESO account name.
- Start ESO, enable TTMPMerge, load into a character and use the /ttmp merge command.

You can run a "test" by using "/ttmp merge test" which will process the new file but not make any changes to your local TTMP file.

NOTE:
Running a merge will freeze the game for several seconds, depending on how large the file is you're trying to import. This is OK!
It shouldn't take any longer than 5 - 10 seconds.

As always, please make sure you have a backup of your existing "SavedVariables" files before doing a merge!


=========================================
TTMP Usage:
=========================================
/ttmp cmd (comment)

TTMP Commands to add Assets:
ore wood cloth water rune reagent plant chest
backpack pack sack crate map fish fissure
shard book quest survey poi(nt) trove box

Commands can be followed by an optional comment, for example 'shard 6' or 'book Manual of Spellcraft'.

Other TTMP Commands:
save -> Saves all your newly found Assets to disk. Note that this will also reload the UI.
By default newly found Assets are only saved to disk when you logout to the character select screen!

del xxx -> Deletes Asset xxx at your current position where xxx is the type. For example 'del backpack'

pos -> Lists your current postion on the map.

list (all) -> List a count of all Assets in the current zone.
If you specify 'all', Assets are counted for all zones!

merge (test) (all) -> Merge new Assets from a merge file.
By default only Assets that don't already exist in your local file are imported.
If you specify 'test', info about the merger is displayed but nothing as actually imported.
If you specify 'all', everything is imported and your existing Assets may be overwritten!
Note: This requires the TTMPMerge AddOn to be installed.

TTMP Configuration:
/ttmpcfg -> Shows the TTMP Config menu.

NOTE:
By default certain nodes are *NOT* shown on your map!
Please go to your Map Filters (the funnel looking icon between the key and the pin) and select what icons you want to see on the map!


