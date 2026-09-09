This is a shameless rip-off of talce's Collectibles, which itself borrowed from other addons before it. I continue in this tradition, 
although my changes are a little less impressive than tralce's (but this is my first published addon, so be gentle).
I preserve the readme of the previous addon, and note that it hasn't been updated in a few years, so I feel somewhat justified in this update. 

Two major 'improvements' to the previous one:
1. Added support for the new fence - Cammio 
2. I have had a particular annoyance with the way dismissing an assistant resummons your companion. 
When you dismiss one, it takes a few seconds for your companion to arrive, during which time you cannot change your mind and summon a different assistant instead.
Many a time I have been intending to swap from my merchant to my banker, and dismiss the merchant instead of summoning the banker. I then have to wait for 
the companion to appear before I can carry on and summon the banker which was very annoying. I have fixed this with the follwing behaviour
	* When you press the hotkey for an assistant, it will summon the assistant *if they are not already active* - it will NOT dismiss them if they are active
	* When you long press (0.5 secs) the hotkey for an assistant, it will still summon them if inactive, but will dismiss them as before if they are active
	
This means that it is impossible to dismiss the current assistant by accident - you have to hold their key for a long press to do that, which solves the problem.


feel free to send stuff to me now.... @tim-P pc/eu (I also like tresure maps - unopened ones)

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Tired of wasting a quickslot on things like Assistants, the Antiquarian's Eye, or certain often-used mementos? Assign them to a keybind instead!

Questions? Comments? Donations? Hit me up in-game! @tralce, PC/NA. Hint: I really like treasure maps.

[COLOR="Red"][B]When you unlock a collectible, you must /reloadui or re-log before a bind will appear![/B][/COLOR]

Now includes an inoffensive chat notification when a collectible is on cooldown and preventing it from being used, and when switching to a Random or Random Favorite mount.

Mount tools
[LIST]
[*]Set Random Mount active
[*]Set Random Favorite Mount active
[*]Ride a group member's Multi-Rider Mount (Code borrowed from [URL="https://www.esoui.com/downloads/info3560-RidinDirty.html"]RidinDirty[/URL])
[/LIST]

Tools
[LIST]
[*]Almalexia's Enchanted Lantern
[*]Antiquarian's Eye
[*]Cartoklept Map
[*]Eye of the Infinite
[*]Relic of the Sentinel
[*]Finvir's Trinket
[/LIST]

Allies
[LIST]
[*]Aderene, Fargrave Dregs Dealer
[*]Azandar Al-Cybiades
[*]Baron Jangleplume
[*]Bastian Hallix
[*]Drinweth, Valenwood Armorer
[*]Ember
[*]Eri, Barking Banker
[*]Ezabi the Banker
[*]Factotum Commerce Delegate
[*]Factotum Property Steward
[*]Fezez the Merchant
[*]Ghrasharog, Armory Assistant
[*]Giladil the Ragpicker
[*]Hoarfrost
[*]Isobel Veloise
[*]Mirri Elendis
[*]Nuzhimeh the Merchant
[*]Peddler of Prizes
[*]Pirharri the Smuggler
[*]Pyroclast
[*]Sharp-As-Night
[*]Siluruz, Realm Craftsmaster
[*]Tanlorin
[*]Tythis Andromo the Banker
[*]Tzozabrar, Dwarven Deconstructor
[*]Xyn, Planar Purveyor
[*]Zerith-var
[*]Zuqoth, Armory Advisor
[/LIST]

Mementos
[LIST]
[*]Prismatic Banner Ribbon
[/LIST]

Throwables
[LIST]
[*]Cherry Blossom Branch
[*]Everlasting Snowball
[*]Mud Ball Pouch
[*]Murderous Strike
[/LIST]

If you prefer using slash commands, check out [URL="https://esoui.com/downloads/info2469-SlashShopFenceandBank.html"]Slash Shop, Fence, and Bank (and More)[/URL]

Grab my other addon, [URL="https://www.esoui.com/downloads/info3233-tralcesVanityKeybinds.html"]tralce's Vanity Keybinds[/URL] while you're at it, for more mementos, personalities, and more! (Update 2023-11-20 - added 9 Multi-Rider Mounts to tralceVantiy!)

Feel free to recommend more in the comments! Ideally also with the Collectible ID, which you can get by linking your collectible in chat, and copying and pasting the link into your comment. Better yet, submit a PR on GitHub!

Now includes some code that allows multi-key keybinds (AKA Chording).

This is a fork of code65536's [URL="https://www.esoui.com/downloads/info2309-KeybindingMiscellaneousMementos.html"]Keybinding: Miscellaneous Mementos[/URL] addon.

[URL="https://github.com/tralce/tralceCollectibles"]GitHub[/URL]
