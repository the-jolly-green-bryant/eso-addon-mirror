
## 3.5.1
- Fixed debug messages that were always showing
    Thanks to @Mix for reporting the issue!

## 3.5.0
- Updated to API Version 100035
- Thanks to @dlrgames for sharing their SavedVariables file, it has been merged into this release!

## 3.4.0
- Updated to API Version 100034
- Thanks to @Jannish458 for sharing their SavedVariables file, it has been merged into this release!
- Added missing default icons for the latest assets

## 3.3.1
- Added Antiquity Dig Sites to the tracked assets

## 3.3.0
- Updated to API Version 100033
- Thanks to @Drio and @DramaKing for sharing their SavedVariables files, they have been merged into this release!

## 3.2.0
- Updated to API Version 100032
- Fixed bug with the new OnWorldMapChanged callback behavior that prevented correct map updates
- Fixed bug where Cloth nodes could be saved as Reagent nodes if they contained alchemical resin
- Added Crimson Nirnroot to the reagent loot table

## 2.8.0
- Updated to API Version 100028
- Fixed bug where TTMP would crash if you switched the game to an unsupported language

## 2.7.1
- Fixed issue where the LibAddonMenu could cause errors with other AddOns that also implement it

## 2.7.0
- Updated to API Version 100027
- Merged over 1300 Elsweyr assets from the PTS

## 2.6.0
- Updated to API Version 100026

## 2.5.0
- Updated to API Version 100025
- Reworked loot display and options

## 2.4.1
- Fixed an issue with the HarvestMap import, updated to support their latest save format
- Added support for new HarvestMap asset types during import
- Fixed the missing "Psijic Portal" assets, they are now correctly added as rune nodes
    NOTE: Psijic Portals share their spawn locations with regular rune nodes!
- Fixed issue with missing custom map pin icons, still need to find better images for two of them but at least they are there now

## 2.4.0
- Updated to API Version 100024
- Updated to the latest version of LibAddonMenu
- Added support for new "ore" types used for Jewelry Crafting
    NOTE: Jewelry crafting nodes share their spawn locations with regular ore nodes!
- Added "Giant Clam" to the tracked assets and map filters
- Thanks to @alembiq for sharing their SavedVariables file, it has been merged into this release!
- Thanks to @darkwolf727 for additional map locations!
- Added menu option to turn on/off asset deletion on the map
    NOTE: Switching this will automatically reload your UI to enable/disable the right-click delete

## 2.1.1
- Added manual delete option that allows for removal of assets by right-clicking on them on the map

## 2.1.0
- Updated to API Version 100021
- Updated to the latest version of LibAddonMenu
- Fixed a bug that didn't clear the last used interaction type when interacting with backpacks that had no items in them
    This resulted in backpacks being added to the map erroneously, for example when opening writ reward boxes
- Added basic russian language support
    Thanks to: @KiriX for the russian translations!

## 2.0.0
- Updated to API Version 100020
- Updated to the latest version of LibMapPins, LibAddonMenu

## 1.8.1
- Added a HarvestMap node importer
    Thanks to: @Moosetrax for the idea and supplying me with his HM saved files!

## 1.8.0
- Updated to API Version 100018
- Added a minor tweak to how asset are handeled during a merge
- Updated the tracked assets, merged several user files, the total number of assets tracked is now over 30,000!
    Thanks to: @Augestflex, @Drio, @Trippet

## 1.7.1
- Fixed crash when used in conjunction with the pChat AddOn.
    pChat will crash and burn if one writes nested colorized strings to the chat window!
    TTMP now detects if pChat is loaded and then omits some of the chat info coloring to prevent ESO from freezing.
      Thanks to: @zasy99 and @msan for helping identifying the offending AddOn!
- Several minor bug fixes

## 1.7.0
- Updated to API Version 100017
- Removed the account based restriction on the SavedVariables file
    This will also make merging SavedVariables files from other users easier
- Added code to automatically convert SavedVariables to the new format on load
- Added "Hello World" message to the AddOn loaded function

## 1.6.0
- Updated to API Version 100016

## 1.5.2
- Added function overload for FISHING_MANAGER.StartInteraction to get info about the last object we interacted with
- Fixed auto-loot bug, everything now works correctly with or without auto-loot turned on/off
- Streamlined some of the code and removed several redundant/unneeded calls

## 1.5.1
- Changed versioning numbers to be more in line with the ESO API version number
- (Partially) fixed bug where nodes were not added to the map when auto-loot was enabled.
    Resource nodes like wood, ore, reagents etc. are now added correctly as are locked chests.
    However, containers like backpacks, heavy sacks etc do not yet work with auto loot.
    Neither OnLootUpdate() nor GetInteractionType() nor GetGameCameraInteractableActionInfo()
    work with auto loot. :(

## 1.0.5
- Added basic support for localization. TTMP now works correctly in "en", "de" and "fr".
    However, any display (menu, lables etc.) is still english only as are chat commands.
- Updated to the latest version of LibStub, LibMapPins, LibAddonMenu
- Adjusted some of the default settings
- Simplified the available /ttmp chat commands
- Changed the way the 'list' command counts Assets and added an 'all' option
- Added 'all' and 'test' options to the 'merge' command
- Fixed icon offsets in Hews Bane since ZOS decided to stealth change the map dimensions :(

## 1.0.4
- Added support for new resource types introduced with the DB patch (Dark Brotherhood)

## 1.0.3
- Added support for the Thieves Guild patch
- Added "Thieves Trove" tracking

## 1.0.2
- Added additional color settings for chat text output to the settings menu
- Added a 'merge' command that allows for merging of SavedVariables files from other users that contain additional map assets.
    This requires the TTMPMerge AddOn to be installed. TTMPMerge is a simple stub that loads the new asset file into memory.
    Once loaded, TTMP can access the new data and loop through it and add/update any new assets from the file.
- Fixed a bug that sometimes prevented Heavy Sacks/Crates from being added to the map
- Fixed a bug that sometimes prevented Cloth nodes from being added to the map
- Fixed a bug that prevented backpacks that had no items in them after opening them from being added to the map
- Fixed a bug in the duplicate asset detection function that could result in assets being moved instead of being ignored

## 1.0.1
- Updated to the latest version of LibMapPins
- Fixed a bug in the code that prevented recognizing map changes when other AddOns are installed that
    also look for map changes, like AUI's minimap for example
- Adjusted the distance for detecting duplicate entries in dungeons to better deal with smaller dungeons

## 1.0.0
- Added option to individually tint the map icons by type
- Added support for new resource types introduced with the Orsinium patch
- Updated to the latest version of LibMapPins, LibAddonMenu

## 0.1.1
- Added support for new resource types introduced with the IC patch (Imperial City)

## 0.1.0
- Added "Options" menu
- Added /ttmpcfg slash command for the options menu
- Added icon offset values for maps with incorrect icon placement (most notably Craglorn)
- Added second "Built-In" icon set using ESO native icons for map markers
- Added option to tint the map icons with a custom color
- Added map filters to allow custom filtering of the map icons

## 0.0.9
- Consolidated settings and added them to the SavedVariables

## 0.0.8
- Added ability to delete assets

## 0.0.7
- Added ability to list zone assets

## 0.0.6
- Added optional description field to all assets.
    This allows the user to add custom comments when adding an asset through the chat window.
- Added labels to map icons that show custom comments on mouse over.

## 0.0.5
- Changed the current map detection to be event based.
    The map name is now only updated whenever a zone/map changes.

## 0.0.4
- Added custom "Points of Interest"
- Added "loot" display functions, displaying received loot and gold in the chat window

## 0.0.3
- Added automated tracking for several assets:
    ore nodes, wood nodes, cloth nodes, reagent nodes, runes,
    water (both water sacks and pure water springs), locked chests,
    backpacks, heavy sacks

## 0.0.2
- Added more assets to the tracking list

## 0.0.1
- Initial code

