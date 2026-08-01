# Aldanga's Lazier Writ Precrafter

If you wanted to pre-craft daily writs, you've come to the right place. You can pre-craft daily writs of any level (or any combinatino of levels) and save yourself precious minutes while hopping between toons for dailies.

First up, this addon would not be possible without Dolgubon and [LibLazyCrafting](https://www.esoui.com/downloads/info1594-LibLazyCrafting.html). Many thanks to him for his help in getting this addon (particularly the multicrafting) off the ground.

## Commands
`/scq [multipler]` will craft items for selected daily writs for the desired number of rotations. A rotation is a 3-day cycle for a particular profession. With all supported professions enabled, `/scq` will craft 37 total items. Crafting a set of 3 rotations (via `/scq 3`) would queue up 111 items to be crafted, so keep that in mind when queuing up rotations.

NOTE: Calling `/scq` without passing a multiplier will craft the maximum number of daily rotations based upon available bag space.

`/clearqueue` will clear the current character's queue.

## Settings

You can enable (or disable) professions in the settings menu.

## Caveats
Queued items are NOT saved to variables, so if you crash or otherwise log out, your queue will be gone.

Thanks to Doglubon's work in LibLazyCrafting, items will be crafted in the style your character knows for which you have the most style stones.

If you enter a station without sufficient mats to craft the entirety of that station's queue, you will force-leave the station without crafting all of the items and without any obvious messaging from the addon. I intend to add messaging support (errors and warnings) in a future update, but I figured I might as well release this to the public since it's proved so useful to myself and my wonderful testers.

## Support
If you run into problems or have suggestions not covered here, please provide feedback and I will try to be as helpful as possible.