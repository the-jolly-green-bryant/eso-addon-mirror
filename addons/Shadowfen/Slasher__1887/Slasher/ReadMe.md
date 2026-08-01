Slasher is a simple utility to add slash commands and key bindings for some useful actions:
* /b - bring out/dismiss banker, 
* /f - bring out/dismiss fence, 
* /m - bring out/dismiss merchant
* /kb - bring out/dismiss khajiit banker, 
* /km - bring out/dismiss khajiit merchant

Additional slash commands:   (slash command only, no keybind)
* /home - port you to your primary residence
* /rl - reload ui,
* /leave - leave group
* /grow	- turn on grass display
* /mow 	- turn off grass display
* /grass - toggle display of grass to on or off

For the Holiday-specific (XP-enhancing) collectibles, it defines the following slash commands and keybinds for:
* /cake - Jubilee Cake (Anniversary Event)
* /mead - Breda's Bottomless Mead Cup (New Life Festival)
* /pie - The Pie of Misrule (Jester's Festival)
* /witch - Witchmother's Whistle (The Witches Festival)

To bind these to a particular key, you go to the ESC menu and choose Controls (if Controls has an Addons menu option, go there too). Then scroll down the list of Addons that can bind to keys until you get to Slasher and choose your keys for particular collectibles.

For addon developers it adds:
* /run <lua code> - executes the <lua code> if possible
* /d <value> - displays the <value> (which might be the output of code) in chat

* /apiversion - displays the ESO API version # in chat
* /collectibles <start number> - start displaying a list of ESO collectible names with their associated id numbers starting from the specified start number.
* /getassistant - displays ESO assistant (banker, merchant, etc) names and id numbers.
* /getcompanion - displays ESO companion names and id numbers.
* /getstyle -  displays ESO styles and id numbers
* /getmemento -  displays ESO mementos and id numbers

