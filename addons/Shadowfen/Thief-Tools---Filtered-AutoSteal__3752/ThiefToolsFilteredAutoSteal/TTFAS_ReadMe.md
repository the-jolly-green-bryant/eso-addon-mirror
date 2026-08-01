ThiefTools - Filtered AutoSteal

Required Addons/Libraries:
* LibSFUtils
* LibAddonMenu-2.0
* LibDebugLogger

Optional Addon Dependencies/Integrations
* ThiefTools
* UnknownTracker
* TamrielTradeCentre

This is a departure from my policy of "take everything so the container respawns".
I've noticed with the newer zones (Necrom in particular) the respawn algorithm has
changed for general containers (not treasure chests and safeboxes of course).
So (with inspiration from Lykeion's Much Smarter AutoLoot) this is an experiment in 
assisting with filtered stealing from containers.
So far, with tests in the Necrom Underway it has not been a problem.

This addon:
* only deals with stealing, it does not handle legal (non-stolen) containers
* will NOT filter safeboxes, thieves troves, murdered bodies, or pickpocketing.

Stealing is mainly about 4 goals:
* Money - taking only the high-gold items since you have a limited number of sales 
	per day.
* Legerdemain - increasing your World:Legerdemain skill by fencing and laundering
	items. For this, the high-gold and the cheap trash give you exactly the
	same +1 point to your skill experience. Just hit your limits of both fencing
	and laundering per day to level more quickly.
* Companion Rapport - You only gain rapport when the companion is out and
	has less than 5500 rapport with you:
	o Ember will give pluses to your rapport with her just for entering the
	  Outlaw Refuge and for fencing purple items.
	o Azandar will give pluses to your rapport with him just for picking up
	  (or stealing) certain treasures that he finds interesting.
	So you might want to have Azandar out while stealing, and then get Ember
	out when you head towards the outlaw refuge to fence...
* Farming - whether it is recipes and motifs, or gear/jewelry to deconstruct for mats 
	or experience, or farming ingredients. Deconstructing gear for mats is nice 
	because you don't have to launder it first so it doesn't impact your laundering 
	per day limits.
	
Thief Tools Filtered AutoStealing (TTFAS) assists you in meeting the above four
goals. Simply, TTFAS allows you to pre-choose the things that you don't want to
steal because they are worth nothing to you and only clog up your inventory. This
is especially useful for the accounts that don't have ESO+ with the doubled 
inventory space and the craftbag!


Settings

We start off with the character settings of
* Enable TTFAS - turn the addon on or off
* Show banner in chat - display a brief "I am here" for the addon in chat when it first loads in.
* Active profile - allows you to select (by name) which profile (collection of 
	rules for looting) that you which to use for the character.
	
There is an additional section "Game Settings" here which is not actually specific
to (or saved with) the addon. They are the actual game settings that you find 
somewhere in Settings that can affect or enhance the operation of the addon - like 
to turn on loot history to see what you have looted or stolen. The Game Settings 
section is just a convenience to not have to look for the settings where they were 
originaly defined in the game.

	
Profiles

Profiles are named collections of rules about how to decide what items to steal from
a container. The profiles are available to all of the characters in your account and
multiple characters can use a particular profile at the same time. Changes made to 
a profile will be seen by all of the characters that use the profile.

There are two "special" profiles:
* the internal "Default" profile, which contains the default profile settings
	for the addon
* The "Account-Wide" profile, which is created the very first time that the addon
	starts up and is based on the values from the "Default" profile. 
	Characters without an Active Profile will be assigned to the 
	"Account-Wide" profile.
Neither of these profiles can be deleted, and the "Default" profile cannot be changed.

At the bottom of the TTFAS settings page is a section labeled "Profile Management".
Inside of this you can create new profiles and delete existing profiles. 
* All new profiles will be available to all of the characters on this account.
* Profile names must be unique. 
* When you delete a profile that another character is using, that character will
	get assigned the "Account-Wide" profile.


Inside a Profile
	
The "- General Settings" section
This contains:
* Auto-Close Loot Window - This can be OFF while you are training and testing
	your new profile and then turned to ON when you don't have to look at
	the loot window any more to be sure that your rules are working as you want.
	Note: The AutoClose Loot Window makes stealing go much more quickly. In an
	environment with lots of containers to steal from (Necrom Underway) it is
	possible to loot so quickly that you may freeze and then get kicked to the
	login window with a  "Error 318. You have been dropped from the server because
	you hit the message rate limit." While I have mitigated the problem as much
	as I can, it is rare but still possible to see this. The only remedy is to
	slow down some on your looting.
	
The next two settings should really not be changed, or else the addon is not
likely to work as you expect (if at all).
* Turn off Gameplay AutoSteal setting - This should be set to ON. This will 
	modify (turn OFF) the Settings:Gameplay:AutoLoot Stolen setting so that
	this addon will work. If the AutoLoot Stolen setting is turned on, you will
	always pick up everything in the container that is stolen - ignoring the
	settings here.
* Turn off Gameplay AutoLoot setting - This should be OFF. While turning it ON can
	allow you to filtered-asteal from containers without having to crouch down, it will also
	change the way that you loot from non-owned containers (not stealing). I found
	it quite annoying and so I just keep this setting OFF and always remember to 
	crouch while I am thieving.
These two settings are not in the "Game Settings" section, because they are addon
settings which remember the original game settings and then modify them for the
addon to work. When the addon is unloaded or disabled, the original settings are
restored to what they used to be.

The remaining profile sections are all of the rules that are used to select items
to steal, and they are run in the order that you see them. Once an item matches
a rule that has it getting taken, then the rest of the rules are skipped as unnecessary
for that item. If an item matches a rule and the outcome selected is "Never Take" then
that rule is finished, and we go to the next rule in the list to see if we want the
item for a different reason (rule).

Most of the rules have at least the choices "Never Take" and "Always Take".
Some rules will also add options to expect 
* a certain "Minium Value" that you set with the slider in that section
* a certain "Minimum Quality" with a dropdown in the section to allow
	you to select which quality value you want
* "Unknown to Me" - only take recipes, or motifs that the character
	does not know.
* "Unknown to Any" - (requires the addon Unknown Tracker) only take recipes, motifs, 
	or style pages that at least one character of the account is learning (see
	UnknownTracker character settings) and does not know.
* a certain "Minium TTC Value" - (requires the addon Tamriel Trade Centre) that you 
	set with the slider in that section. You will also want to see the settings for
	"- Addon Integrations" Tamriel Trade Centre to choose which TTC price to use
	("suggested" or "average") and whether to use the price directly or calculate
	the expected profit (price - launder price).
	
The "special" rule that does not have "Never Take" or "Always Take" is the 
"Take from Stolen containers within the inventory" in the "- Containers Options"
section. Refering to things like Hidden Bags or Research Portfolios, these are 
containers that you stole. This setting wants to know what to do with the container 
when you use it. The options are: 
* "Take All Items" - empty the container into your inventory,
* "Just Open" - normal ESO behaviour for opening a container,
* "Follow Rules" - this will run the Filtering rules on the contents of this container
	and so will pull out the items that one of the rules said to take and leave behind
	items that were not wanted (along with the container they were in).
	
The Addon Integrations section only appears if you have at least one of the
addons that TTFAS can integrate or coexist with:
* ThiefTools
* UnknownTracker
* TamrielTradeCentre
When one of these addons is found available, the Addon Integrations will list it
along with any additional information or settings you need to be aware of.
	

Lastly is the "Enable debug mode" option which is not stored in a profile,
it is stored per character. 
Recommended setting OFF. When you turn this ON, the addon will spew
loads of mostly jibberish to your chat window.


Acknowledgements:
This addon owes its inspiration to Lykeion's Much Smarter AutoLoot (MSAL)
addon - which heavily influenced my UI choices since I really liked 
the UI that it provided and thought it made sense. Unfortunately, MSAL is not yet
compatible with TTFAS as we both contend for stolen loot and MSAL always wins.
I hope that this will be addressed in time.
