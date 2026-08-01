Thief Tools provides a variety of helpful tools to help you manage and profit from your thieving career:

* A configurable status bar to provide you with your current hot item counts and quotas.
* Smart auto-looting of stolen items
* Configurable auto-junking of stolen items - and an icon to display which mode you are in
* Unjunking of laundered items - you spent money to launder it, it must not be junk any more. (New)
* A convenient control of whether you are allowed to kill NPCs or not - and an icon to display at a glance which mode you are in.
* Convenient integration with the ThiefTools - Filtered AutoStealing (TTFAS) addon. (New)


The Thief Tools Status Bar
The status bar to help you keep track of your stealing at a glance! It can display the following:

* A red hand icon if you are in "Kill NPCs" mode (dynamic)
* A gold bag with coins around if you are in "Auto-Steal" mode (dynamic) or a blue bag with coins if you have enabled Thief Tools - Filtered AutoStealing (New)
* The total value of fence-able items you're carrying.
* The number of fence-able items you're carrying and the remainder of sells for the day.
* The number of launder-able items you're carrying and the remainder of launders for the day.
* The average value of the fence-able items (off by default).
* The estimated session's income you'll get if you fence items of like value up to your per-day limit.
* A graph of your fence-able items' quality.


Filtering

These counts can be configured according to your preferences by setting filters for certain categories of stolen items.

The categories, such as 
* gear, 
* furnishings, 
* provisioning recipes and furnishing recipes (formerly just "recipes"), 
* motifs, 
* style materials, 
* trait materials,
* raw and refined materials (clothing, woodworking, and blacksmithing), 
* alchemical solvents and reagents (new) and 
* lockpicks 

can be set for particular destinations: Fence, Launder, Ignore (does not count towards either), or Junk. 
Certain categories or sub-categories might have special handling that cannot be overridden at this time (to prevent them from being considered fenceable:
*Treasure maps (and other trophies) are automatically set for Launder

Any other items that don't belong to any of these categories are automatically considered for fencing.

Only items considered for fencing will be counted in the fence-able items, the total value of currently held items, the average value, and the quality displays.

Only items considered for laundering will be counted in the launder-able items.

Ignored items will not be counted by anything except the recipe, motif, or furnishing counts that you can see in the chat window.

You can also set it to ignore all stolen items that you have marked as junk in your inventory.

Finally, you have the option of saying that if an item would normally be considered for fencing, you can still have it ignored if the value of the item is less that a threshold value that you set. If the threshold value is zero, then none of the worthless fence-ables will be ignored by this.


Auto-Stealing

Thief Tools provides an auto-stealing "mode" which sets it so that you have auto-looting of stolen items turned on when you are sneaking and undetected. If you stop sneaking, auto-looting of stolen items is turned off. If you are sneaking and detected (in enough time for the addon to notice before ESO opens the container), auto-looting of stolen items is turned off. It is still possible to be caught stealing - because they saw you after the container started to open - but this does offer you just a little bit more protection. The protection against detection is less effective when you are pickpocketing - just be careful!

The gold coin bag icon in the status bar will appear if you have the auto-stealing capability turned on (and if you turned on the icon!).

How to enter/exit Auto-Stealing mode
It is on by default. There are two ways you can toggle it on or off:
* Use the /tt.as command in the chat window
* Bind a keyboard key to the "Toggle Auto-Steal" in Controls->Addon Keybinds->Thief Tools

Filtered AutoStealing (New)

(Requires ThiefTools - Filtered AutoStealing addon to be installed)
To enter/exit Filtered AutoStealing, you can use the /tt.fas command in the chat window.
With an additional addon (ThiefTools - Filtered AutoStealing), you can filter out which items you want to steal and which you want to leave behind. 
This will only filter for regular urns/containers/boxes/etc with stolen stuff in them. 
Thief troves, safeboxes, and murdered bodies will still have everything stolen out of them (to get them to respawn for your fellow thieves).
Picking up (stealing) individual items from vendor tables (or anywhere) will not be filtered. Why did you pick it up if you didn't want it?
It cannot filter pickpocketing.

Auto-Junking

In addition to simply ignoring junked items, Thief Tools can now automatically put items into Junk for you. 

Certain items are always auto-junked: 
* items that have been deprecated by Zenimax
* items that are defined by Zenimax as "trash"
* spoiled food (which, oddly enough is not considered trash)

Certain categories or sub-categories might have special handling that cannot be overridden at this time (to prevent them from being considered fenceable or junked:
*Rare ingredients and food additives such as flour and decorative wax will not be auto-junked even if you have set ingredients to "Junk"
*Any item at or above a certain (configurable) level of quality cannot be auto-junked no matter what you set the category that item belongs to - the default level is currently "Legendary".

The auto-junker only works on stolen items. Your other addons can handle junking of non-stolen items. Really, it makes sense to have separate rules for stolen verses non-stolen items anyway. You would not want to junk soul gems - unless they were stolen soul gems that are only worth 30 gold - one of your limited number of fence slots should be saved for something worth a lot more than that! And laundering them for 30 gold, when you might get them from guild traders for less - or in Cyrodiil for free (Rewards for the Worthy) - that doesn't really make sense either.

Although the auto-junker generally operates properly without help, it is possible to toggle auto-junking mode off or back on again when you need to. There are two ways you can toggle it on or off:
* Use the /tt.junk command in the chat window
* Bind a keyboard key to the "Toggle Auto-junk, stolen" in Controls->Addon Keybinds->Thief Tools

Also, auto-junking is temporarily turned off while you are looking at your inventory - that way you can unmark junked items before destroying or selling what's left without worrying about having the item automatically re-junked while you are working there. It is automatically turned back on when the inventory window closes. You will see messages about this in your chat window each time it occurs.

(Note: I will not add auto-deletion of items from your inventory ever. It is too dangerous, and I'm not about to test it on my own characters and valuable stuff or make you test it on yours. Besides, even if I did and got it working perfectly, Zenimax can update the game and break my addon.)



Prevent Killing of Innocents Mode Management

This very simple capability provides two ways of turning on or off the Prevent Kill mode provided by the game, and an optional icon on the status bar when you are in "Kill Everyone" mode.

There are two ways you can toggle it on or off:
* Use the /tt.tm or /tt.safe command in the chat window (they are identical commands - I wanted the /tt.tm because I was used to using the TroubleMaker addon).
* Bind a keyboard key to the "Toggle Kill Innocents" in Controls->Addon Keybinds->Thief Tools

If you prefer to use a different addon such as TroubleMaker, Thief Tools will happily co-exist with it. Thief Tools will still detect when the Kill Innocents game setting changes either by other addons or by game settings and display the red hand icon as appropriate.



Commands in Chat
(Most of these are also available as keybinds under Controls->Addon Keybinds->Thief Tools

/thieftools - Display all of the chat commands for ThiefTools with a brief description of what they do.

Of particular interest:

/tt.counts - Display all of the counts for what you have in your pack - the recipe, motif, and furnishings counts (these are counted in these special counts even if they are otherwise ignored due to other filter settings), and the fence and launder counts.

/tt.fencetime - Fence Reset Timer. According to Elmseeker (Thieves Knapsack Extended), it appears this is a fixed time (3am UTC).

/tt.as - Toggle auto-steal mode (mutually exclusive with /tt.fas)
/tt.fas - Toggle filtered autosteal mode (mutually exclusive with /tt.as. Requires TTFAS addon.)
/tt.tm or /tt.safe - Toggle kill innocents mode
/tt.junk - Toggle auto-junk mode




Acknowledgements:
This addon owes its inspiration to Elmseeker's Thieves Knapsack Extended addon - who heavily influenced my UI choices since I really liked the UI that it provided and wanted most of it back.

As this is my very first addon, I also wish to acknowledge the ESOUI Wiki, the tutorials there, the Thieves Knapsack Extended addon, and the Roam Home addon which I read to discover how some things worked.