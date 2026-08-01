[LIST]
[*] v. 6.1.6
[LIST]
[*] FIXED: Class masteries are now applied after changing skilllines to pure-class.
[*] FIXED: No "Change class line" button after class mastery skill lines.
[/LIST]
[*] v. 6.1.5
[LIST]
[*] QoL: Color-coded skill lines with locked scribed skills
[*] QoL: Tooltip for skilltype entries telling you which skills/skill lines need changes or have issues
[*] QoL: New setting to choose how to sort your profiles
[*] FIXED: Scribed skills would prevent apply skills to continue to applying hotbars or trigger other apply-all-functions if they were the only changes to be made
[*] FIXED: CSPS-format import function did ignore hotbars
[/LIST]
[*] v. 6.1.4
[LIST]
[*] NEW: outfits section now includes customized actions
[*] QoL: outfits section is now color-coded based on the currently applied items
[*] FIXED: "ignore empty outfit slots" now works for titles and monturs
[*] MINOR FIX: Fixed and updated some tooltips in the settings
[/LIST]
[*] v. 6.1.3
[LIST]
[*] NEW: Support for Class Mastery (Update 50)
[*] QoL: Gear-items are now marked when they are manually added and not linked to a specific item in your inventory/bank (instead of the other way around)
[*] QoL: The indicator icons at gear-items telling your if the correct item is equipped or in your inventory/bank now have tooltips with more details
[*] QoL: If no exact match for a gear item is found you can still equip similar items via context menu from inside the addon.
[*] QoL: Right-click on the "Apply all"- button now let's you choose categories directly in a context-menu instead of opening the settings
[*] QoL: Added a tooltip to the role icon.
[*] QoL: Tooltips for "apply hotbar" and "apply champion bar" are now labeled according to their specific targets instead of a simple "apply"
[*] QoL: If you open an ESO-HUB link without generating it first the addon will now automatically generate it first.
[*] FIXED: Rare issue with crafted abilities that would occur after user manually changed the game's language via script
[*] FIXED: Opening the addon inside a vengeance campaign won't break anything anymore (but the addon still will not work in vengeance mode - because why would it)
[*] FIXED: ESO-HUB export could be incomplete when no passive champion points were set
[*] FIXED: ESO-HUB export link is now longer sent to chat on opening it. 
[*] FIXED: Profile name is now display correctly when profiles are loaded via hotkey.
[*] FIXED: When connecting build profiles to hotkeys/triggers checkboxes leading to deactivated categories are now hidden.
[*] MINOR FIX: Expand/collapse button on the champion sidebar is now pointing in the right direction and has a dynamic tooltip.
[*] INTERNAL: vengeance class lines are now recognized by their rank-behaviour instead of hard-coded by skill line id
[/LIST]
[*] v. 6.1.2
[LIST]
[*] FIXED: issue that came with 6.1.0 that would prevent the addon from saving subclasses
[*] FIXED: issue that would let you slot inactive subclass skills on action bars when "show all class skills" is active
[*] QoL: clicking "apply skills" now also automatically applies hotbars (can be turned off in the right-click context-menu)
[/LIST]
[*] v. 6.1.0
[LIST]
[*] NEW: Craft/reconstruct gear items from your selected build. Items will be added to a crafting-queue from which you can craft them once you are on your main crafting character. LibLazyCrafting is needed to use this function!
[*] NEW: Import setups from Wizard's Wardrobe
[*] NEW: Option to let the addon auto-respec whenever needed on loading Wizard's Wardrobe setups
[*] QoL: Linking complete builds to triggers/hot keys is now available by default and does no longer need manual activation in the options menu.
[*] QoL: Right-click on 'Apply skills' to choose if you want to apply only new skills without respec.
[*] QoL: If you transfer builds with incompatible class line you can now still see them but have to change them before you can apply.
[*] FIXED: Skills on the hotbar could be at two positions at once if you moved them from one position to another.
[*] FIXED: Two mythic items could be chosen at the same time.
[*] FIXED: Applying a mythic with another mythic already equipped now unequips the other mythic first.
[*] FIXED: Some issues with the cooldown on free respec that happend cause of changes from PTS to live (and partwise because I sometimes am not as smart as I would like to be)
[*] 
[/LIST]
[*] v.6.0.0
[LIST]
[*] NEW: update 49 apply attributes and skills anytime
[*] NEW: quickslot indicators for items in inventory/bank
[*] NEW: export AND import from and to eso-hub.com (thanks to Woeler for all the work on his part!)
[*] NEW: Automatically unlock champion points via the fastest way
[*] QoL: Right-click on CP in the bar now also opens the context menu with an option to remove them instead of removing them instantly
[*] QoL: Apply buttons are now always visible to avoid situations where the addon could apply stuff but doesn't notice it...
[*] QoL: Inactive class skill lines are coloured orange
[*] QoL: Attribute points are color-coded depending on their current value
[*] QoL: Gear editor window has a new layout
[*] QoL: You can now change traits and enchantments for gear directly in the list
[*] QoL: When editing gear you can now directly apply items from your inventory/bank (or just the set they belong to)
[*] FIXED: the white space in front of some enchantmant names
[*] FIXED: an issue where applying cp hotbar profiles would send a server request even if no slots were changed
[*] FIXED: unused scribing skills were displayed as errors in the apply dialog
[*] FIXED: sub profiles without subclasses would reset current subclasses instead of ignoring them
[*] FIXED: some set names were not displayed inside the gear editor
[*] INTERNAL: changed the way hotbar profiles are handled
[*] INTERNAL: added functions to access profiles for other addons (incomplete)
[/LIST]
[*] v. 5.7.5
[LIST]
[*] changed the way skill line changes are applied. you will now be able to edit your changes ingame after applying them via addon
[*] available skill points are now counted correctly when in respec mode (at least in the dialogue)
[*] if subclassing is not yet available you can start the quest directly from the "change skill lines" menu inside the addon
[*] if you haven't finished "a study in discipline" CSPS will remind you to choose a skill line still in training when applying skill lines
[*] fixed an issue with quickslots that could occur when deleting/saving/loading profiles
[/LIST]
[*] v. 5.7.4
[LIST]
[*] fixed some issues that could occur on fresh installs without any saved data
[*] finally deleted some old compatbility routines only needed if you haven't used the addon since 2021 
[/LIST]
[*] v. 5.7.3
[LIST]
[*] fixed an issue with choosing keybinds directly from the subprofile list
[*] fixed an issue with comboboxes in the gear window
[*] fighter and mage guild vengeance skill lines are now hidden
[*] you can no longer choose scripts for crafted abilities that are incompatible with the other scripts
[*] fixed an issue with tooltips for ability style unlock hints
[*] new option: you can choose to hide some modules of the addon (gear, outfit, quickslots, role and mundus). if you encounter problems with deactivated modules, please let me know
[/LIST]
[*] v. 5.7.2
[LIST]
[*] fixed an error that could occur since v.5.7.0 when saving profiles with empty champion points
[/LIST]
[*] v. 5.7.1
[LIST]
[*] finally updated the champion point presets (as before the data for DD and Tank presets come from Skinny Cheeks and Tank Club, the healer presets now come from data provided by Duncan88 on Healer's Haven - thanks for giving me the permission to use them!)
[*] added an option to create dynamic champion point profiles. when saving dynamic profiles the last version won't be overwritten but changes will be appended to it. loading a dynamic profile will respect the order of changes and stop loading when the current cp maximum is reached.
[/LIST]
[*] v. 5.7.0
[LIST]
[*] internal change to the way profiles are saved. please backup your sv if you read this. in theory nothing should change for you.
[*] added the option to save backups of your profiles each time you save a build (history can be accessed by right-click on the load button)
[*] added the option to adjust transparency of the complete window and of the background
[*] group role is added to "apply all" and to the conditional profile auto-load options
[/LIST]
[*] v. 5.6.5
[LIST]
[*] changed the way profiles without subclass information are handled: general profiles will reset the subclasses while sub profiles for skills will keep the current subclasses
[*] fixed the text skill export (morphs, scribed skills and subclassing are now exported correctly)
[*] your role is now saved with your profile and will be shown in the upper corner of the addon. currently you can apply it by clicking on the symbol. it will later be included in the "apply all" section.
[*] fixed an entry in the context menu for choosing a title
[/LIST]
[*] v. 5.6.4
[LIST]
[*] fixed an issue with training new subclass lines (thanks to code)
[*] finally fixed the subtitle for the hotbar apply button
[*] added an option to show and edit all subclassing lines instead of just the active ones
[/LIST]
[*] v. 5.6.3
[LIST]
[*] added the option to save skill profiles with or without subclass information (skills for subclasses will still be saved)
[*] adjusted the height of the profile dropdown
[*] fixed an issue with saving gear profiles
[/LIST]
[*] v. 5.6.2
[LIST]
[*] fixed several bugs with subclassing, please let me know if you still encounter problems
[/LIST]
[*] v. 5.6.1
[LIST]
[*] update 46
[*] subclassing (you will need to interact with a shrine to change skill lines)
[*] added spanish translation
[/LIST]
[*] v. 5.5.4
[LIST]
[*] updated green cp presets
[*] added latest sets to eso-skillfactory import/export
[/LIST]
[*] v. 5.5.3
[LIST]
[*] fixed an issue with v.5.5.2
[/LIST]
[*] v. 5.5.2
[LIST]
[*] fixed some issues with update 45 (thanks to Kyzeragon for the fix)
[*] updated the set list for skillfactory-export
[*] added an option to exclude skill styles from "apply all"
[*] changed the way, outfit slots are handled
[LIST]
[*] "unequiped" outfit slots will be unequiped on applying
[*] "deleted" outfit slots will be ignored
[*] when reading the current outfit empty outfit slots will be read as "unequipped", which can be changed in the addon's options
[/LIST]
[/LIST]
[*] v. 5.5.1
[LIST]
[*] updated for update 43
[*] fixed an issue with update 43 (thanks to yachoor for the fix)
[*] updated the set list for skillfactory-export
[/LIST]
[*] v. 5.5.0
[LIST]
[*] updated for Gold Road (update 42)
[*] added support for crafted abilities (can only be applied at the scribing altar)
[*] added support for ability styles (will be applied together with general skills - you may need to update some of your profiles, otherwise it will unequip styles on loading)
[*] fixed some problems with the mundus dropdown on Update 42
[*] please note that the skillfactory-import/export does not yet support the new features. use csps-import/export if you want to transfer your builds between different accounts and include skill-styles and crafted abilities
[/LIST]
[*] v. 5.4.3
[LIST]
[*] added new sets to skillfactory-export/import
[*] added russian translation thanks to mychaelo
[/LIST]
[*] v. 5.4.2
[LIST]
[*] fixed an issue with the dropdowns for sub-profile bindings
[/LIST]
[*] v. 5.4.1
[LIST]
[*] adjusted to changes in the API for Update 41
[*] added new sets
[/LIST]
[*] v. 5.4.0
[LIST]
[*] fixed an issue that could occur when importing builds with too many attribute points
[*] applying more attribute points than you can have on your current character will no longer fail automatically - instead the addon will ask you wether as many points as possible should be applied
[*] new options for situations when to open the addon automatically (including level-up and earned champion points - addon will only open once out of combat)
[*] new option to save the current build as a temporary profile when closing the addon so you can continue where you left off the next time you start the game and open the addon
[/LIST]
[*] v. 5.3.3
[LIST]
[*] fixed an issue with retrieving and equipping gear if there were multiple instances in the bank
[*] quick-slot profiles will now also save which quick slot is active and change it when applied. you can also change that via left-click inside the addon
[*] the gear list now also shows numbers for active items of a set behind the item name (frontbar/backbar for sets including a weapon). can be deactivated in the settings.
[*] when editing gear in CSPS you have a new button to select sets that are either already in your build or in your inventory/bank
[/LIST]
[*] v. 5.3.2
[LIST]
[*] fixed an issue with the stam-dd fitness cp preset flagged as old
[*] added arcanist and current sets to eso-skillfactory-import/export
[/LIST]
[*] v. 5.3.1
[LIST]
[*] fixed an issue with account-wide cp bar profiles
[/LIST]
[*] v. 5.3.0
[LIST]
[*] added compability for update 30
[/LIST]
[*] v. 5.2.0
[LIST]
[*] added the arcanist to skillfactory-export/import
[*] added Sanity's Edge to the abbreviations for automatically created sub-profile names
[*] the context menu to quickly choose slottable champion points can now also be used in the base game UI
[*] added an apply button the the champion point hotbar to only apply the currently selected slottables
[*] fixed the tooltip for mundus boons and added tooltips to the dropdown menu
[*] added tooltips to the ability hotbars
[*] added ability stats (cost, duration, range, etc.) to the skill tooltips
[*] fixed an issue where some items wouldn't be applied to quick slots (e.g. alliance items)
[*] fixed an issue with binding groups to Wizards Wardrobe sets
[*] fixed an issue where some parts of the apply all options would be enabled even the button itself was disabled
[*] fixed some issues with custom icons not always being shown on the base game champion bar
[/LIST]
[*] v. 5.1.3
[LIST]
[*] fixed an issue that would prevent the addon from loading on the pts - happy testing!
[/LIST]
[*] v. 5.1.2
[LIST]
[*] fixed an issue that could occur on new characters or new installations of the addon
[/LIST]
[*] v. 5.1.1
[LIST]
[*] fixed a minor issue where the cp sidebar would be shown without a background 
[*] fixed a minor issue where clicking on a tree section name to open it wouldn't work for champion point disciplines and clusters
[/LIST]
[*] v. 5.1.0
[LIST]
[*] added appearances
[LIST]
[*] you can disable the appearence-section in the addon's settings (the appearance section won't be shown in the tree view and appearances won't be loaded/saved if deactivated)
[*] you can save your title, outfit and active collectibles and edit them inside the addon
[*] you can create account-wide and char-based sub profiles for your appearances
[/LIST]
[*] fixed an issue with the tooltip for adding quickslot sub profiles
[/LIST]
[*] v. 5.0.3
[LIST]
[*] fixed an issue with adding bindings to AlphaGear profiles (works fine for me with AlphaGear 2, but I'm not really using AG so let me know, if you encounter any more issues)
[*] fixed an issue with removing conflicting bindings
[*] added the sets from Scribes of Fate to eso-skillfactory import/export function
[/LIST]
[*] v. 5.0.2
[LIST]
[*] fixed an issue that could occur when applying empty champion bar slots
[*] fixed an issue that could prevent you from saving your champion bars
[*] when pressing 'apply all' and now champion point changes are necessary then that message is posted to chat instead of 'champion points successfully applied'
[/LIST]
[*] v. 5.0.1
[LIST]
[*] fixed an issue with the apply-all-function that came with v. 5.0.0
[/LIST]
[*] v. 5.0.0
[LIST]
[*] fixed a very old but never addressed issue with the tree view: you can now open/close sections by clicking on their titles
[*] the default setting for displaying the skill hotbar at the bottom of the addon is now 'active' and the setting moved to the addon's setting menu
[*] when right-clicking on the apply-labels or opening a sub-profile-section the tree view will now scroll to the corresponding category and open it
[LIST]
[*] note that their might be a small delay if that category is opened for the first time
[/LIST]
[*] added the option to choose which key should be used to jump 10 points when adjusting attribute/champion points and to connect sub-profiles to a build profile (shift, ctrl, alt)
[*] added tooltips for skill sub-profiles
[*] added the option to save hotbars together with skill sub-profiles (or hotbars only)
[*] added options to suppress messages on loading cp profiles, hiding the addon without applying changes etc.
[*] fixed an issue where shift-clicking on a sub-profile icon would load it instead of connecting it to the current build

[*] complete overhaul of the quickslot section
[LIST]
[*] quickslots are now part of the tree view
[*] all quickslot bars can be saved and loaded together or separately
[*] note: when applying more than one quickslot bar at once there is a little waiting time between categories so you won't get kicked for spamming
[LIST]
[*] when filling all quickslot bars on an empty character you might still get a spam warning
[/LIST]
[*] quickslot profiles can still be connected to build profiles (similar to cp profiles)
[/LIST]

[*] complete overhaul of the "manage-bars" feature (connecting groups of sub profiles to keybinds, places, etc.)
[LIST]
[*] now you can add quickslot profiles and even complete build profiles to your binding groups (the option to include complete build profiles must be activated in the addon's settings)
[*] now you can bind your binding groups to your Wizard's Wardrobe Sets (not needed for cp subprofiles of course, but who knows what you might want to use this for)
[*] binding groups now can be defined character-based or account-wide
[*] using keybinds will always prefer the character-based binding group if one exists, but you can setup a second keybind (shift/ctrl/alt) to force the addon to load the account-wide group instead.
[/LIST]

[*] changes to the champion point section 
[LIST]
[*] complete overhaul of the underlying code to save and handle champion points - please let me know if you encounter any problems
[*] new option to choose if the champion points should be sorted in clusters like the base game ui displays them or listed in alphabetical order (optionally grouped by slottable/passive)
[*] you can now apply slottable CPs to the first empty hotbar slot by right-clicking them in the list
[*] left-clicking champion point hotbar slots at the left of the window now opens a context menu to quickly apply new skills to the slot
[*] old champion point presets will not be shown in the preset list anymore unless you choose otherwise in the addon's settings (they are still included and will be loaded when connected to a profile)
[/LIST]
[*] changes to the import/export section 
[LIST]
[*] if you use the game in French, German oder Spanish you can now choose to use your own language for text-based champion point import/export
[*] fixed an issue that could occur on transferring profiles from one char to another
[*] transferring profiles is a little more convenient now, at least current server and account are pre-selected
[*] new option to import/export the complete build profile in an csps-specific format
[/LIST]
[/LIST]
[*] v. 4.2.9
[LIST]
[*] Fixed an issue that would prevent some cp presets from being shown in the preset list
[/LIST]
[*] v. 4.2.8
[LIST]
[*] Fixed an issue with creating new bindings for AlphaGear and DressingRoom profiles
[/LIST]
[*] v. 4.2.7
[LIST]
[*] Fixed an issue with generating links for eso-skillfactory
[*] The new buttons to quickly save cp profiles now have tooltips
[*] Made some alterations in the way the UI is handled (let me know if you encounter any issues). Changed quite a few controls so they will only be created once you need them the first time. This should benefit loading times and performance impact.
[/LIST]
[*] v. 4.2.6
[LIST]
[*] NEW DEPENDENCY: LibCustomMenu - please donwload before updating if you don't already have it
[*] Added new DPS presets based on the builds by Skinny Cheeks
[*] Updated the warfare tank preset
[*] Added the option to quickly save cp profiles from within the tree view (both create new profiles and save existing connected ones)
[*] Fixed an issue where the High Isle champion points would not be imported correctly
[*] Added a developer-function to quickly show you skill and cp data: left click + shift + ctrl on list entries now writes the list entry id and base data to chat
[/LIST]
[*] v. 4.2.5
[LIST]
[*] You can now change the size of the addon window (that took a while, I know) - please let me know if you encounter any issues with that
[*] Added the new sets for Firesong to the eso-skillfactory import/export
[/LIST]
[*] v. 4.2.4
[LIST]
[*] Fixed an issue that could occur on 'apply all' without ability hotbars
[*] Added the option to add gear items to a profile by dragging them from your inventory into the addon
[/LIST]
[*] v. 4.2.3
[LIST]
[*] Fixed an issue that could occur on login for chars without saved profiles
[*] Fixed an issue that could cause an ui error in the inventory (for items without an itemlink?)
[/LIST]
[*] v. 4.2.2
[LIST]
[*] Fixed two issues with the new apply-all button preventing hotbars and connected quickslots from being loaded at first try
[*] The addon now longer asks you to save changes if you select another profile without having made any changes
[*] Mundus display will now refresh and show the correct color when the mundus is changed in-game
[*] Added an option to mark items in the inventory that belong to the build (icon is a little red rhombus)
[LIST]
[*] FCOIS is not yet supported but support is planned for the future
[/LIST]
[*] Items that are saved by their unique ID and not by their properties and have been found in your inventory will be marked inside the addon with a small lock-icon
[/LIST]
[*] v. 4.2.1
[LIST]
[*] Fixed an issue with the new open-on-armory option
[*] Champion Point slottables that can be slotted but aren't now get a small grey circle around them
[/LIST]
[*] v. 4.2.0
[LIST]
[*] Moved most of the addons settings to LibAddonMenu (new dependency), added some new settings:
[LIST]
[*] Option to open the addon automatically when the armory is accessed
[*] Option to save specific gear items instead of just the items data
[*] Option to change the accepted level difference of gear that the addon should find and equip
[*] [COLOR="red"][size=1]Explanation: when you are saving your gear in most of the other addons (like DressingRoom, AlphaGear or WizzardsWardrobe), the addon will save specific items by their unique item id. This way when you reapply them the exact same item will be equipped again. Since CSPS is also used for theorycrafting, I went another way. Instead of saving the exact item you are wearing, the addon saves the items data, for example 'medium Legs, legendary, divine, max-magicka enchantment'. That way your builds can be imported/exported and the addon will still be able to find fitting gear. But of course if you have two identical items in your inventory it will be random which one the addon equips. Also the addon will try to find equipment fitting the current character's level. If you want to equip a specific item or an item not fitting your level you should use the option to save specific items via their UniqueID.[/COLOR][/size]
[*] Option to add a new 'equip all' button to the addon (and pre-select which parts of the current profile should be applied)
[*] Option to hide the last saved date in the profile list

[/LIST]
[*] Added the possibility to connect quickslot profiles to the current build (this only affects the new 'apply all' button)
[LIST]
[*] Use shift + left click to connect/disconnect a quickslot profile to the current build 
[/LIST]
[*] Fixed an issue that came with the werewolf implementation and would prevent hotbars with empty slots from loading correctly
[/LIST]
[*]v. 4.1.11
[LIST]
[*] Fixed an issue that could prevent you from saving your old builds after the new werewolf hotbar was implemented
[/LIST]
[*]v. 4.1.11
[LIST]
[*] Fixed an issue where right-clicking on linked cp profiles in the treeview wouldn't disconnect them
[*] Added the werewolf hotbar (open the werewolf skills in the treeview to show the hotbar)
[/LIST]
[*]v. 4.1.10
[LIST]
[*] Fixed an issue where profiles with dynamic cp presets linked to them would cause errors
[*] Fixed an issue where set items without a trait would have incorrect tooltips
[/LIST]
[*]v. 4.1.9
[LIST]
[*] Added the new sets for Lost Depths to the eso-skillfactory import/export
[/LIST]
[*]v. 4.1.8
[LIST]
[*] Added the new sets for Lost Depths
[*] Pushed the API version
[/LIST]
[*]v. 4.1.7
[LIST]
[*] Fixed an issue where the CSPS window would sometimes be hidden behind the champion point ui
[*] Fixed an issue where gear sometimes would not be found in the inventory if poison was part of the build
[*] Fixed an issue where builds with non-set items in the gear section would not load properly
[*] Fixed an issue where the tooltip for gear would not be hidden
[*] Added an API function to quickly load a complete build by name: CSPS.loadAndApplyByName(profileName, excludeSkills, excludeAttributes, excludeGreenCP, excludeBlueCP, excludeRedCP, excludeHotbar, excludeGear) - if none of the booleans is set to true the complete build will be loaded. No confirmation dialogs will be shown except for errors or gold costs.
[/LIST]
[*]v. 4.1.6
[LIST]
[*] Added High Isle item sets for eso-skillfactory build import/export
[*] Removed the chat output that could occur on skill point changes
[/LIST]
[*]v. 4.1.5
[LIST]
[*] Adjusted the quick slot manager to the changes made in High Isle (for now only the standard quick slot menu is supported)
[*] Fixed an issue that could occur when opening the cp-profile editor from within the bar manager
[*] Added icons for the new champion points
[*] Pushed the API version
[/LIST]
[*]v. 4.1.1-4.1.4
[LIST]
[*] Fixed some issues that came with v.4.1.0
[/LIST]
[*]v. 4.1.0
[LIST]
[*] Completeley rewrote the skill section of the addon and changed the way skills are handled codewise
[*] Also removed some old compability functions from the early days - please let me know in the comments if you encounter any problems
[*] The apply/retrieve buttons for gear are now shown only when the gear node is open/visible (better performance for the rest of the addon)
[*] Added the option to link champion point profiles to build profiles making them more dynamic (use right-click to link a champion point profile to the current build profile. every time that build profile is loaded the champion point profile will be applied to the build)
[*] Added the option to save skill profiles as separate profiles that can be loaded (adding the skills to the currently shown, so you can use them to quickly add sets of skills you need on more than one profile)

[*] Added the option to use shift while clicking on the plus button to set passive skills to their highest rank
[*] Added the option to add all passive skills to a skilltype or skillline and set them to their highest possible rank

[*] Added Ascending Tide item sets for eso-skillfactory build import/export
[*] Pushed the API version
[/LIST]
[*]v. 4.0.1
[LIST]
[*] Fixed some issues in the new gear selector (item type and trait dropdown)
[*] Added information on crafting knowledge and reconstruction options for missing set items
[*] Added armor type information to the item tooltip
[/LIST]
[*]v. 4.0.0
[LIST]
[*] Added gear information. The addon will save information about the items, not the unique item in your inventory. It's not intended to replace Wizards/AlphaGear/DressingRoom. You can import/export your full build including gear from eso-skillfactory. The addon will tell you if you have any fitting items in your inventory or bank and can retrieve/equip them. Items that only fit partwise will be listed but not equipped by the addon.
[*] Added mundus stone information (topright corner).
[*] Cleaned up some older parts of the code (still some work to do in that regard).
[/LIST]
[*]v. 3.4.0
[LIST]
[*] Added information to all profiles (cp and build) when they were saved last (is shown in the dropdown for builds and in the tooltip for cp profiles) - will only show for profiles saved after this update
[*] Added more information to the custom champion point profile tooltips
[*] Fixed an issue where existing quickslot profiles couldn't be changed
[/LIST]
[*]v. 3.3.0
[LIST]
[*] Added the option to save and load your quickslots (this function has a 5-second-cooldown)
[*] Fixed an issue that could occur when trying to transfer a profile from one char to another with different race/class
[*] Changed the way hotbars are applied (you no longer need a bar swap)
[/LIST]
[*]v. 3.2.0
[LIST]
[*] Added tooltips showing the full names for champion point profiles that get truncated
[*] Changed the options for the cp text-import. Instead of one checkbox for "reverse order" you now can select one of three possible name-value-slot-orders. 
[*] Removed a debugging function that would post champion skill ids to chat when clicking on them
[/LIST]
[*]v. 3.1.2
[LIST]
[*] Fixed an issue with profile-transfer for champion hotbars that could occur when transferring from a char without any hotkey groups
[/LIST]
[*]v. 3.1.1
[LIST]
[*] Added new set ids (deadlands) to the skillfactory export
[/LIST]
[*]v. 3.1.0
[LIST]
[*] Pushed the API version
[*] Added a routine to automatically switch to cursor mode and back when opening/closing the addon (and after you exit dialogs)
[*] Changed the way the 'apply'-menu is shown when you change something in the build so it doesn't move the whole list.
[/LIST]
[*]v. 3.0.3
[LIST]
[*] Added some options to the cp text import feature:
[LIST]
[*] Use rightclick when you click the import button to create a dynamic profile
[*] When holding Ctrl at the same time the created profile will be account-wide
[*] When holding Ctrl while doing a left-click code for a preset will be generated
[*] All of these options won't warn you when they encounter problems - so make sure the text you're importing is without typos etc. (e.g. by importing it the usual way first)
[*] If you are importing from a list where multiple entries for the same champion skill should be added up instead of replacing each other, hold Shift while clicking on the import button (works with any of the options above)
[/LIST]
[*] Added the missing namechanges from Waking Flame to the CP text import database
[*] Using rightclick to preview the skills contained in a CP preset now also works with custom profiles
[/LIST]
[*]v. 3.0.2
[LIST]
[*] Fixed an issue that could occur when trying to apply CP with an empty slot
[/LIST]
[*]v. 3.0.1
[LIST]
[*] Changed the api version to the correct number
[*] Fixed a small issue that could cause an UI error when opening the CP profile section
[*] Added a text messages when trying to apply a cp profile group that doesn't require any changes
[/LIST]
[*]v. 3.0.0
[LIST]
[*] Completely changed the way skills are saved in the addon - skills are now saved by ID rather then indices, which should be easier to maintain for future updates. All saved data for your account will be converted on your first login after updating.
[*] Added new sets to the skillfactory import/export (Waking Flame)
[*] Fixed an issue where an empty slot would sometimes prevent your cp hotbar from being applied
[*] Replaced the one apply button and the checkboxes with different apply buttons for skills, attributes and champion points
[/LIST]
[*]v. 2.3.0
[LIST]
[*] Added gear export for skillfactory. When generating a link for eso-skillfactory the currently worn gear will be included (won't be shown in the addon)
[*] Added cp icons for the new skills on pts (Waking Flame)
[*] Major changes in the way the skill/cp-list is handled codewise - should improve the performance when reading data for the first time
[*] Current skills and champion point allocations are now displayed by default whithout manually refreshing the data (you still have to refresh if changes are made outside the addon)
[*] Removed the cp reminder option (became kind of obsolete with cp 2.0)
[*] Removed the old CP from the treeview and from the export window
[/LIST]
[*]v. 2.2.0
[LIST]
[*]Updated the export/import function for eso-skillfactory.com to support the current version of the skill planner
[/LIST]
[*]v. 2.1.1
[LIST]
[*]Updated the blue and red champion point presets for dds
[/LIST]
[*]v. 2.1.0
[LIST]
[*]Added the new champion skills to the text import (Blackwood)
[*]Added custom icons for the new slottable champion skills (Blackwood)
[/LIST]
[*]v. 2.0.5
[LIST]
[*]Fixed an issue with cp profiles that came with 2.0.4
[/LIST]
[*]v. 2.0.4
[LIST]
[*]Fixed some issues with the tank presets > 1700 cp
[*]Fixed an issue that would occur on login on the current PTS (Blackwood)
[*]Fixed an issue that the addon would ignore the lower max points for some cp on the current PTS (Blackwood)
[/LIST]
[*]v. 2.0.3
[LIST]
[*]Fixed an issue that could occur when the custom icons are activated without the custom bar
[/LIST]
[*]v. 2.0.2
[LIST]
[*] Fixed an issue where the stamina dummy parse preset was listed as magicka
[/LIST]
[*]v. 2.0.1
[LIST]
[*] Fixed some issues with the dynamic presets
[LIST]
[*] Some incorrect/missing values in the DD presets (you might have to respec those to optimize your CP)
[*] Remaining points should now be distributed as intended to jumppoints and basestats to make as much use of them as possible
[/LIST]
[/LIST]
[*]v. 2.0.0
[LIST]
[*] Added new cp presets for healer and for the green cp tree (craft)
[LIST]
[*] Healer preset (blue/red) by ESO University
[*] Different green presets I'm using myself
[*] Presets by @Orejana that are optimized to use in combination with [URL="https://www.esoui.com/downloads/info2951-JackofallTrades.html"]'Jack of all Trades'[/URL] 
[/LIST]
[*] Added an option to filter cp presets by role
[*] Added the possibility to see a detailed list of skills in a cp preset before loading it by doing a rightclick on the list entry
[*] CP values are now color coded like the skills: green if the selected value is exactly the same as the currently applied and orange if the currently applied value is higher than the selected one
[*] Added a chat message when closing the addon with unapplied changes to CP
[*] The names of AlphaGear and DressingRoom bindings are now created dynamically and refreshed when you rename the linked sets/profiles/builds
[*] Added an option to apply dynamic presets in a strict order (thereby having more leftover points but probably saving 3000 gold when applying the preset again)
[/LIST]

[*]v.1.7.2
[LIST]
[*] fixed an issue where some messages would contain codes instead of skill names
[*] added cp tooltips and icons to the bar manager
[*] removed some of the older pre-update29 routines that are not needed anymore
[/LIST]

[*]v.1.7.1
[LIST]
[*] added a French translation (thanks to @jakez31)
[*] fixed an issue where incompability issues with some dressing room versions could cause an UI error (hopefully, couldn't replicate the errors myself)
[*] presets can now be sorted by source and role (both are now displayed in separate columns)
[/LIST]

[*]v.1.7.0
[LIST]
[*] added the option to display different icons for the slottable champion points (activate under options)
[*] added the option to display a separate champion bar as part of the in-game overlay (activate under options)
[*] if a new cp profile is created it is now positioned at the top of the list and colored yellow until you resort the list or switch to another view
[*] the auto-names for new cp profiles now also distinguish between mag- and stam-dd
[*] the tooltips for champion points now also appear while hovering over the progress-bars/values
[*] updated the cp presets by Skinny Cheeks and added the ones for dummy parsing
[/LIST]

[*]v.1.6.5
[LIST]
[*] added a new option under import/export called "transfer", allowing you to load profiles or copy cp bindings from another character (server and account wide)
[*] added a new binding option: location by category (group dungeon, trial, housing, battleground)
[*] fixed an issue where the location based hotbar binding wouldn't work
[/LIST]

[*]v.1.6.4
[LIST]
[*] fixed an issue where text-export would exclude skills from clusters (only affected warfare)
[*] the champion profiles and presets are now sorted by name (will add more sorting options soon)
[*] added a step-by-step tutorial for import from alcast or justlootit to the help section
[/LIST]

[*]v.1.6.3
[LIST]
[*] updated the tank club presets
[*] added a "secret" create-preset option: if you are in text-based import and hold ctrl+shift while clicking on the import-button, the text won't be imported but converted to a dynamic preset, which you can send to me (with a short explanation what you're doing and why it should be in the addon), or you can copy into the presets.lua in the addons data folder (replace X with the next number in line)
[*] fixed an issue where the champion bars from the main profiles wouldn't be saved correctly
[*] fixed an issue where the start-text in the import-export-section wouldn't always fit the selected method
[*] fixed an issue where the location based automization would only work if the cp reminder was on
[*] fixed an issue with the non-cp-profile-warning
[*] the dressing room role-icon now refreshes when you re-enter the cp bar manager
[/LIST]

[*]v.1.6.2
[LIST]
[*] fixed an issue where your champion bar profile groups wouldn't be saved
[*] added export-to-text for the new champion point system
[*] added support for profile-by-role in Dressing Room (you can save bindings to the current role)
[*] added a new feature: right-click on a locked champion skill in the list and the addon will tell you the cheapest path to unlock it
[*] changed the name on minion to make it easier to find
[/LIST]

[*]v.1.6.1
[LIST]
[*] fixed an issue where you couldn't recreate a binding to dressing room or alpha gear after you removed it
[/LIST]

[*]v.1.6.0
[LIST]
[*] added automization for champion bars
[LIST]
[*] bind your champion bars to dressing room, alpha gear or certain locations
[*] Attention! When binding CP to Alpha Gear make sure to load your AG build directly and NOT by toggling through all your AG builds one after the other - otherwise the addon will try to reslot your champion skills for every build it is bound to, causing the 30 second cooldown to prevent you from slotting the points you actually need!
[/LIST]
[*] extended the whole help section of the addon
[*] added an option to auto-load the addon when opening the cp window
[*] opening the cp profile section now toggles the cp-section in the treeview which lets you see your slotted cp skills
[*] fixed an issue where two skills from soul magic would be loaded incorrectly after the update (works only for chars on which you haven't logged in since the update)
[*] fixed an issue where the cp bar manager wouldn't refresh the dropdown menu after you created new champion bar profiles
[/LIST]

[*]v.1.5.6
[LIST]
[*] fixed an issue with loading presets and importing cp where skills close to the players current max points wouldn't be applied
[/LIST]

[*]v.1.5.5
[LIST]
[*] fixed an issue with saving cp without skills being loaded first
[/LIST]

[*]v.1.5.4
[LIST]
[*] integrated a remap function for the switched skills in provisioning and enchanting
[/LIST]

[*]v.1.5.3
[LIST]
[*] checked with the live server version of Flames of Oblivion
[LIST]
[*] changed the scyring skill line migation
[/LIST]
[*] added a "clean text" button to the cp text import (needd if importing from alcasthq)
[/LIST]

[*]v.1.5.2
[LIST]
[*] fixed a small issue with the loading process that would have caused an UI error tomorrow
[/LIST]

[*]v.1.5.1
[LIST]
[*] fixed an issue with text import for red and green champion points that came with v. 1.5.0
[*] fixed a small issue that could occur while editing skill profiles
[*] fixed an issue where the user could try to apply skills and attributes even if none had been loaded
[/LIST]

[*] v.1.5.0
[LIST]
[*] extended the keybinding option for champion hotbar profiles
[LIST]
[*] now up to 20 groups (each group contains one hotbar profile for each discipline)
[/LIST]
[*] included basic presets for warfare and fitness
[LIST]
[*] presets provided by The Tank Club and Skinny Cheeks (thank you!)
[*] these presets are dynamic and will automatically adjust to your level (up to 2100 CP)
[/LIST]
[*] changes to the text-based cp import:
[LIST]
[*] added the option to reverse the reading order (name before value)
[*] added the option to stop the import once the accounts available points are reached
[*] fixed an issue where slottables would be slotted twice if they appeared twice in the text
[*] The addon now searches for the word "slot" in the text - if found, this keyword will determine which champion points should be used on the champion bar. Otherwise the addon will try to slot all slottable imported skills starting at the beginning of the text.
[/LIST]
[/LIST]


[*] v.1.4.4
[LIST]
[*] added the option to save only the champion point hotbars to profiles and assign key binds
[*] some minor ui tweaks
[*] added a preset list for champion points (not yet filled)
[/LIST]

[*] v.1.4.3
[LIST]
[*] added a warning when trying to apply skills regarding the change of the major gallop buff
[LIST]
[*] if you select 'No' in the dialog, the addon will offer to switch the skills automatically
[/LIST]
[*] fixed an issue with a change in the skill order that came with one of the latest PTS patches
[*] fixed an issue that could prevent the migration of skill lines when changing the ingame language
[*] fixed an issue where the champion point hotbars wouldn't be read correctly
[/LIST]

[*] v.1.4.2
[LIST]
[*] fixed an issue that was caused by PTS patch v.6.3.4 (the reimplementation of the championstar animation)
[*] fixed an issue that could prevent the user from respeccing champion points (CP 2.0)
[*] small ui tweaks in the champion point purchase request dialog
[/LIST]

[*] v.1.4.1
[LIST]
[*] fixed an issue where the cp reminder for trials and arenas would be switched on by default and after a reload
[/LIST]

[*] v.1.4.0
[LIST]
[*] added text based import for champion points (2.0)
[*] added a trial cp reminder
[*] fixed an ui issue with the save profile dialog
[/LIST]


[*] v.1.3.3
[LIST]
[*] fixed an issue that came with v. 1.3.2
[/LIST]

[*] v. 1.3.2
[LIST]
[*] extended tooltips for skills in the treeview
[*] added support for the new champion system - only on pts of course
[LIST]
[*] you can save your cp into the general profile or in separate cp profiles for each discipline
[*] you can choose to save the cp profiles by char or account
[*] you can import cp profiles as comma separated lists (more info on that feature coming soon)
[/LIST]
[/LIST]

[*] v. 1.3.1
[LIST]
[*] added export as text
[LIST]
[*] list of skills is too long for the ingame textfield, so I split them up in three parts
[*] like the link to skillfactory you will have to copy the texts to save them outside of eso
[/LIST]
[/LIST]

[*] v. 1.3.0
[LIST]
[*] added support for multiple profiles for each character
[LIST]
[*] please note that champion points from the old cp system won't be saved for other profiles than the standard one since you don't want them to unnecessarily pollute your saved data after the update
[*] if you want to respec, just save the skills you want to change to save storage space
[*] you can go to a shrine and enter the morphs-only respec mode to apply your profile
[/LIST]
[*] added the options to remove a whole skill line from a build (useful to reduce the data for respec-profiles)
[*] added plus/minus-buttons to the attribute points
[*] fixed an issue, where empty slots in the hotbar wouldn't be saved/loaded correctly
[*]fixed an issue in import from eso-skillfactory, where a missing mundus would prevent the following data from loading
[*] started to change some code segments to get rid of the bad habit of German function names... :-)
[/LIST]

[*] v. 1.2.1
[LIST]
[*] fixed an issue for non-cp-accounts which prevented the addon to work properly
[*] fixed some minor ui issues
[/LIST]

[*] v. 1.2.0
[LIST]
[*] added hotbars (click on the options-button at the top to show/hide them)
[LIST]
[*] drag and drop skills from the list
[/LIST]
[*] added import/export to/from eso-skillfactory.com
[*] added color coding for the skill types/lines to help finding conflicts
[*] changed the name of the old cp-values to CP 1.0
[LIST]
[*] old CP will still be shown after update 29 but not applied or imported
[/LIST]
[*] adjusted the skill mapping for the new armor passives in update 29
[*] fixed an issue, where some skills would be wrongly identified as conflicting with existing ones
[*] fixed an issue, where the addon would try to apply skills from unavailable skill lines 
[/LIST]

[*] v. 1.1.1
[LIST]
[*] on special request: additional auto save for cp and attributes if one of them is missing at login
[/LIST]

[*] v. 1.1.0
[LIST]
[*] fixed an issue where attribute points were listed but not saved
[*] found and fixed an issue where the skills would be mapped wrong when saved in a different language
[*] added a plus button to the skill section
[LIST]
[*] only visible if not maxed out
[*] plus and minus also work to switch between morphs
[/LIST]
[*] the number of free skill points and the ones you need in order to apply your current data are now shown while you edit them
[*] your skills are now color-coded 
[LIST]
[*] red if you can't apply them
[*] green if they are already applied
[*] orange if they are already at a higher rank than intended
[/LIST]
[/LIST]

[*] v. 1.0.0
[LIST]
[*] changed the way the data is stored (after the first login a ui-reload is recommended)
[*] changed the way inactive skills are treated in the listing
[*] the first time you log in to a character without any previous saved data, the current data will be  saved automatically
[*] fixed an issue with incorrect order of cp (ui only, don't worry)
[*] added attribute points besides skills and cp (not important for the update 29 reset, but we never know)
[*] the checkboxes at the top now only affect the applying of saved data, not the loading/saving-process itself
[*] extended the information shown when trying to apply skills (now showing the actual needed skill points and potential conflicts with already applied skills)
[*] added a migration process if you load data that was saved in a different language (skill types that are ordered alphabetically like open world or guilds would otherwise be incorrect)
[*] some other minor bugfixes and changes
[/LIST]

[*] v. 0.9.3
[LIST]
[*] minor bugfix - error message if you try to load data that isn't there
[/LIST]

[*] v. 0.9.2
[LIST]
[*] some changes in the general UI
[*] warning if you have less skill points than you need to apply your saved skills
[*] possibility to change the skills
[*] new parameter in the saved data to later fix the problem below
[*] known issue: if you change the language of your game client, you can't read your old saved skills. 
[LIST]
[*] a solution is on it's way.
[/LIST]
[/LIST]
[/LIST]