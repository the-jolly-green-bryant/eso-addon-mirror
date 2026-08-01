Rotation Helper - ESO Addon Files
===================================

This folder contains all the files needed for the Rotation Helper addon.

INSTALLATION INSTRUCTIONS
=========================

For PC:
-------
1. Copy this entire "RotationHelper" folder to:
   Documents/Elder Scrolls Online/live/AddOns/

2. Launch ESO and enable the addon in Settings > Add-ons

3. Type /rh in-game for commands


For Console (Xbox Series X/S, PlayStation 5):
----------------------------------------------
See the main CONSOLE_INSTALL.md in the parent directory for detailed instructions
on uploading to Bethesda.net using the Developer Uploader Tool.


FILES IN THIS FOLDER
====================
- RotationHelper.addon    (Manifest file - defines addon metadata and load order)
- RotationHelper.lua       (Main addon logic - 1000+ lines)
- RotationHelper.xml       (Main UI window - DDR display)
- RotationBuilder.xml      (Rotation builder UI window)
- SkillDatabase.lua        (Database of 50+ skills from all classes)
- ExampleRotation.lua      (Example rotation templates for reference)
- README.txt               (This file)


REQUIRED DEPENDENCIES
=====================
None! The addon works standalone.

OPTIONAL DEPENDENCIES
=====================
- LibAddonMenu-2.0 (for in-game settings menu)
  Without it, you can still use all features via /rh slash commands


QUICK START
===========
1. Install the addon
2. Type: /rh rotation
3. Click "Load Example"
4. Click "Save Rotation"
5. Enter combat and practice!


DOCUMENTATION
=============
Full documentation is available in the parent directory:
- ../README.md              (Main documentation)
- ../ROTATION_BUILDER.md    (Rotation builder guide)
- ../CONSOLE_INSTALL.md     (Console installation)
- ../QUICKSTART.md          (Quick start guide)
- ../MULTICLASS_GUIDE.md    (Multi-class usage)
- ../COMBAT_SUMMARY.md      (Combat summary feature)
- ../CONSOLE_UI_SCALE.md    (UI scaling for console)
- ../SETTINGS_MENU.md       (Settings menu guide)
- ../FEATURES.md            (Complete feature list)


SUPPORT
=======
For issues, questions, or feedback, please check the documentation files
in the parent directory.


VERSION
=======
v1.0.0 - Initial release with full rotation builder UI
