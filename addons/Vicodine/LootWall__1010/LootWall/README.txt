================================================================================
LootWall by @Vicodine
================================================================================
DISCLAIMER:
This Add-on is not created by, affiliated with or sponsored by 
ZeniMax Media Inc. or its affiliates. The Elder Scrolls® and related logos are 
registered trademarks or trademarks of ZeniMax Media Inc. in the United States 
and/or other countries. All rights reserved.
You can read the full terms at 
https://account.elderscrollsonline.com/add-on-terms
================================================================================
INDEX:
  1. About
  2. Installation
  3. Changelog
  4. Thanks
================================================================================
1. About
================================================================================
  LootWall is a highly-interactive, configurable, firewall-like loot filter.
It allows you to predefine some basic rules for:
  Keep items at-and-above quality (default: artifact)
  Ornate-Trait Items (default: Prompt)
  Intricate-Trait Items (default: Prompt)
  Nirnhoned-Trait Items (default: Keep)
  Craft-type related materials (default: all Prompt)
  Racial style materials (default: Prompt)
  Trash Quality Items (default: Prompt)
  Fishing Bait Items (default: Prompt)
  Craft needed for research traits / woodwork, cloth and blacksmith (default: Prompt)

These presets (except for Quality) have all 4 options:
  * Prompt  : Prompts you for action first time you loot an item of given type
  * Destroy : Destroys the item of given type upon looting
  * Junk    : Marks the item of given type as junk upon looting
  * Keep    : Keeps the item of given type upon looting

You can also set to track loot you receive by other means. As of now, these sources are:
  * Merchants (default: Ignore)
  * Fences/Launder (default: Ignore)
  * Mail attachments (default: Ignore)
  * Craft / Refine / Deconstruction result items (default: Ignore)

The Add-On *should* not be able to track items withdrawn from Bank or Guild Bank.
As a precaution, these items will be ALWAYS ignored by the addon.

Above all this, once you loot an item (and are out of combat) it will display a
popup asking action for any item that doesn't match above rules. Choices are:
  Destroy (Now/Always): Destroys the looted item (and possibly the entire stack)
  Junk (Now/Always): Marks the looted item as Junk in your inventory
  Keep (Now/Always): Does nothing, it just keeps the item as it was looted
  
The Now/Always means one simple thing: responding with (Now) action will prompt
you again next time you loot the same item.
Responding with (Always) action will remember the action you chose, and never 
will prompt you again, for the same item.

  This addon takes the other-way-around from similar ones. You predefine "keep"
actions but "Junk" and "Destroy" decisions are all up to you. Give it an hour or
so and You will never be prompted again. This approach may change with public
opinion but it's the direction I originally took, and play-tested it for the
entirety of development. It never got really annoying. I just turned it off when
I went on trials, but that way day 2 of development. Now I would trust it all the
time :)
================================================================================
2. Installation
================================================================================
Use minion! :) Get it at http://minion.mmoui.com

For manual install:
  1. Unzip the file you have downloaded
  2. Locate the addon directory:
    - <Documents>\Elder Scrolls Online\(liveeu/liveus/pts)\AddOns\
    - if the AddOns folder does not exist, create one
    - ex.1 C:\Users\Me\Documents\Elder Scrolls Online\liveeu\AddOns\ (Windows Vista +)
    - ex.2 C:\Documents and Settins\Me\Documents\Elder Scrolls Online\liveeu\AddOns\ (Windows XP)
    - ex.3 /Users/Me/Documents/Elder\ Scrolls\ Online/liveeu/AddOns (OS X)
      - note: the \ in Elder\ Scrolls\ Online is for terminal only. You will see
        the directory in Finder as Elder Scrolls Online
    - linux users should be able to figure out their wrapper's document dir on
      their own, because I HAVE NO IDEA /and it's not supported/  
  3. Copy the unzipped LootWall directory to the AddOns Directory
  4. Don't forget to enable it ingame (Add-Ons menu on Character Screen or In-Game)
================================================================================
3. Changelog
================================================================================
v0.7
      + added circonian's LibNeed4Research
      + Prompt/Destroy/Junk/Keep researchable trait items
v0.6.1 - hotfix release
      + Removed some debug messages unintentionally left in release
      + Added preset options for Trash and Bait items
v0.6  
      + Added Loot Sources ignore options, all default to on
      + Locale/default.lua
      + Preparation for translations
      + On/Off for "Keep x" replaced with choices of Prompt/Destroy/Junk/Keep
      + Versioning of savedVariablesVersion
      + Update to SavedVars version 2 to migrate checkboxes to dropdowns
      ++ defaults changed accorgingly. Previous "Off" now equals "Prompt", "On" equals "Keep"
      ++ Migration occurs the same way. All "On" will be turned to "Keep", "Off" will be "Prompt"
      + better starting window position (200,200 instead of 0,0)
        * still looking for a perfect spot
      + Checked and clarified the way that rules apply
        The order is as follows: 
          Preset > Stored Rule > Prompt
        For presets, the order goes like this:
          Quality > Traits > Tradeskill Materials
        Tradeskill materials also include trait stones:
          WoodWorking: Weapon traits
          Clothing: Armor traits
          Blacksmithing: Weapon and Armor traits
      known bug: cursor dissapears by moving window after being toggled on by the add-on
      known bug: if you junk a stolen item, it will always try to sell and fail at vendor until you get rid of the stolen item at fence or by hand
v0.5 is the first public release. Here you will find changes after that.
================================================================================
4. Thanks
================================================================================
  This AddOn was made possible by the extensive wiki esoui.com has on AddOn
development. So THANKS! You can check the wiki out at http://wiki.esoui.com
  
  Special thanks to Seerah and the community contributors for LibAddonMenu-2 and
LibStub. 
It made creating a configuration menu easy! Check it out here: 
- "LibStub" http://www.esoui.com/downloads/info44-LibStub.html
- "LibAddonMenu-2.0" http://www.esoui.com/downloads/info7-LibAddonMenu.html

  Thanks to ingeniousclown for the original work and Randactyl for continuing
with AdvancedFilters addon. It kinda helped me put together which ITEMTYPE is
which crafting material. And I use it since it was released :)
- "Advanced Filters" http://www.esoui.com/downloads/info245-AdvancedFilters.html
  
  Thanks to Pawkette for the original and Flagrick for the continuation of 
LootDrop. I learned (probably badly) how to work with received loot. Altough i 
gave up on OnItemLooted, the SINGLE_SLOT_UPDATED works (probably) just fine :)
I didn't do all the fancy-pantsy stuff that LootDrop does. Nope. Not much of a
safe code but it works for me, it "should" work for you too :)
- "LootDrop" http://www.esoui.com/downloads/info35-LootdropContinuedAllinOne.html

  The rest and most thanks goes to you guys that willingly install my first-ever
add-on. Sweetrolls all around :) Don't forget to report problems and post feedback,
comments section at esoui.com for now, next release will see a dedicated forum post.