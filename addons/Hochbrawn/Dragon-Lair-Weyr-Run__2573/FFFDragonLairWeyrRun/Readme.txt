The DragonLair Weyr Run addon records the loot items and value for the enitre group, with a running Dragon Hoard total.

The seven bar graphs represent the value of items looted as follows:
From left to right
Blacksmithing	(Raw Materials and Armor Traits)
Clothing 		(Raw Materials)
Woodworking 	(Raw Materials, Furnishing Materials, Weapon Traits)
Jewelry			(Raw Materials, Jewelry Raw Trait, Jewelry Trait) 
Alchemy			(Reagents, Potion Base, Poison Base)
Enchanting		(Aspect, Essence, Potency runes)
Provisioning	(Ingredients, Fish, Insect parts)
Armor, Weapons, Motifs, Styles and Traits	(Ingredients, Fish, Insect parts)

Slash commands that are available are:
Preceed each of these commands with \weyr 
	showdetail	| shows the detail loot list 
	hidedetail	| hides the detail loot list
	run    		| starts the addon functions and ready to go
	halt  		| stops the addon functions
	showhoard 	| shows the Hoard Board totals
	hidehoard 	| hides the Hoard Board totals
	showleaders | show leaderboard
	hideleaders | hide leaderboard
	lootstart  	| restarts the looting events if stopped with lootstop (does not reset values)
	lootstop 	| stops the loot tracking, can be restarted with lootstart
	xbp 		| transfers items looted from craftbag to backpack
	deposit		| when at a guild bank, opens a separate window with looted items.  Double click to deposit to guildbank.
					when deposit is successful, a group chat message is formed and waiting for the user to send to the group.
					The message communicates the deposit information and others in the group with the addon will have thier records of deposit
					information updated.
					This does nothing when not at a guild bank, and only group chat messages are being scanned.
					Do not change the formatting of the message as that can mess up the information transfer.
					No the message is not audited for accuracy, and you could probably fake deposit amounts communicated to your friends but that is just dumb.
					This message only appears AFTER the successful guild bank deposit is complete.
	reset 		| resets all counters and lists to zero
	clearloot	| resets persistant data and clears all player tiles to zero
	quit		| Resets all counters and lists, halts all events and hides controls
	
ie.  \weyr run

If joining a group (ie you got an invite) do a '\weyr run' to build the groups if group members are not showing. 

As players leave or join the group their tile will be removed and the next new player will fill that tile.

Team frames will populate as members are added.  When all members of a team have left thier frame (should) disappear as well.

The values that are reported are local player dependent based on Master Merchant data.  So expect some descrepencies.  However, if on a guild run, identify one member as the offical results if necessary.

I adjusted the colors to match the Harvest Pins defaults with some exceptions.  Harvest pins have different colors for mushrooms, water and flowers. All of which are Alchemy items.
So you may want to customize your Harvest Pins colors to match the colors below.  The color for Provisioning noted, I have set for fishing as provisioning locations are not tagged in Harvest pins.

RGB Values for your information.

Blacksmithing	114	125	255
Clothing		150	252	255
Woodworking		255	177	126
Jewelry			221	237	247
Alchemy			115	145	108
Enchanting		255	116	122
Provisioning	255	103	0
Styles/Traits	160 52  252

The group detail list and group hoard total reduce when a player leaves the group, or if you leave a group it reduces to your looted amount.
A button has been added to the detail list to toggle between the groups items and your own items.

Guild Bank deposit has been added.  It is no longer necessary to transfer your craftbag loot items to the backpack prior to depositing to the guildbank.
When an item in the deposit window is double clicked, the item is looked for in the backpack, if not found it looks to the craftbag. If found the item is transfered to the backpack.
Once transfered to the backpack, it is passed to be deposited in the selected guildbank.

Note that if you have looted more than 200 items, only a single stack at a time will be deposited.  The list will update with modified totals and the process continues.
If you have transfered your items already to the backpack, they will be found there first and deposited.
If you have a stack of more than the looted quantity, the stack will be split so that only the looted quantity is deposited.

Guild bank deposits require a round trip to the server to be recorded succesful.  This can take a moment. When the CHAT message is prepared in the CHAT dialog the deposit is complete.
Pressing return for the CHAT message sends a group message to allow the other Weyr Run Addon users to update their totals with your deposits.

As you deposit your items, your list of 'farmed' items will be removed from the list and your bar total.
At the same time a deposit list is created of what you have deposited to the guildbank, and your items are added to the group deposit list.

The group 'farmed' list does not have its items removed. This allows a means of keeping track of what was collected and can be compared to the deposited list.

Any items that a player does not deposit, would be removed from the group 'farmed' list when they leave the group as before.

The Hoard Board loot total does not update, as this reflects the farmed value.  It does reduce when players leave with non-deposited items.

Added the ability to see what other group mates have looted.  Simply double click their name in their player tile and the detail list will update with their items.
To return to your own looted items double click your name on your tile.  You will also be able to toggle to their deposited items, so this will help guild leaders to track what has been deposited at a more detailed level.

Work to do:

Create a loot item selection list to allow each of the eight loot bars to be customized for different farming runs.
Create an option to save own loot results and allow to be loaded or added to for those that wish to track a total history of looting.


To install, unzip the archive and move the FFFDragonLairWeyrRun folder(with subfolders) into your \Documents\Elder Scrolls Online\live\AddOns folder.  Once there, you will need to load the game and activate the addon.  Once activated, you will need to /reloadui to load the addon.

This addon uses Master Merchant or Arkadius Trade Tools if available, it currently will use Master Merchant first if present.  If neither are available the vendor value will be used.
