# INTRODUCTION
ESO Grinder (EGR) has two components:

- EGR "ESO Grinder" is an Elder Scrolls Online addon that monitors loot and saves it to the user's ESO save file.
- ESFM "Elder Scrolls Save File Monitor" is Python code that monitors the ESO user save file if new loot is found then adds it to a user-specified database.

These two componenents must be run concurrently - there's really no need to run the addon without the Python.

EGR was inspired by https://forums.elderscrollsonline.com/en/discussion/comment/5259194/#Comment_5259194
<br>What's a good way to measure loot efficiency? I wanted to see how many worms could be harvested with this method vs any other method. At first I made a dreadful manually-maintained solution but knew that it was just the initial stepping stone in learning some basics of how ESO, Git, LUA, and some other things work.

This project is maintained at [https://github.com/marcjordan2112/egr](https://github.com/marcjordan2112/egr)

## COMPATIBILITY
EGR is compatible with

- Python 3.7.4 or greater
- Windows
- Mac (not tested)

# Usage

1. Install EGR (see below).
2. Run the ESFM Python script on a command line (CL), specifying the user's ESO @PlayerName, path to ESO save file, and path to the database file.
3. Play ESO. As you play, EGR will cache loot items and when ESO performs a save to the addon's save file EsoGrinderSaveFile the entire cache will be included. The ESFM will wake up if the EsoGrinderSaveFile changes and will save all new loot to the database.
4. The database may be connected to any process as read-only while ESFM is running. 

> NOTE There is currently no limit on how many loot items get stored. So, at some point, if something doesn't trigger a save, it will probably crash :0 I've been playing with this mod for a year or so now and the most I've seen is around 180 items saved in one shot. I've gotten in the habbit of running /reloadui frequently so I don't hit any limits.

Currently, it's up to the user to decide what to do with the database.

# IMPORTANT
- The Python code waits for the contents of the EsoGrinderSaveFile to change. Please ensure that you wait to exit the Python code for a few seconds after triggering a save file event. 

# VERSIONING

Version format major.minor.derp, or x.x.x:

- major: Change to the database design.
- minor: Change to API, add big features.
- derp: Bug fixes, change to dox.  

# EGR ESO GRINDER ADDON

## Installation

Copy this entire directory into 

    <?>\Elder Scrolls Online\live\AddOns\EsoGrinder

Please search the internet to find details on the AddOns directory location for your OS. 

## Usage

In-game console commands:

- /egrstart Start EGR.
- /egrstop Stop EGR.
- /egrdebug Toggle debug.
- /egrapiversion Show ESO API version. Debug must be enabled to see output.

todo:

- [x]  Pull in addon args, define usage in one place.

## Notes
- The database is created automatically if it does not exist.

## Limitations
###  When does ESO write user's save file?
I have noticed that the ESO save file is always written under these conditions:

- Run the /reloadui command
- Logout
- Exit
- Randomly

Teleports don't seem to reliably do it. If you notice other predictable conditions please let me know.

### Loot Item Logging
- Logged
    - Quest reward
    - Searched
    - Mined
    - Collected
    - Taken
    - Fished
- Not Logged:
    - Gold (currency, not item quality)
    - Mail
    - Creation
    - Traded

# ESFM ESO SAVE FILE MONITOR PYTHON

## Installation
Run the following to install 

    $pip install -r requirements.txt

## Usage

Run

    $python eso_save_file_monitor.py -h
    
todo:

- [x]  Pull in python args, define usage in one place.

## Database
The ESFM database is a standard SQLite database. It may be viewed by any standard SQLite tools.

If opening the database with a tool then open as read-only, otherwise there will be conflicts with the ESFM at run time.

# CHANGE LIST

- 2.1.0
    - ESFM: Add watchdog method of catching changes to the ESO save file as default. Add command line option to use the old poll method. This is a major performance update - thanks to [https://www.esoui.com/forums/showpost.php?p=43109&postcount=4](https://www.esoui.com/forums/showpost.php?p=43109&postcount=4)
    - ESFM: Add Ctrl-C to exit.
    - ESFM: Discard playground Utils.ThreadSafePrint in favor of the standard Python logging module.
    - ESFM: Update Utils.MyThread to fix async issues.
    - ESFM: Add support for database changes and updates - WIP and not supported.
    - ESFM: PEP8 update for method decorations.
    - ESFM: Add some horrible docstrings.

- 2.0.0
    - Change the name of the installation file/directory from "egr-x.x.x" to "EsoGrinder".
        - To preserve existing databases you can copy/paste them from an existing ".../Addons/egr-x.x.x" to the new 
        ".../Addons/EsoGrinder" directory.
    - Remove old temporary dev files.
    - Update README.md value of poll time from 5 to 3 seconds. It has always been 3 seconds.
    - Update EsoGrinder.txt to fix esoui/minion issues.

- 1.0.2
    - Remove dev debug prints.

- 1.0.1
    - Add .gitignore.
    - Update API version to 100033.
    - Add /egrapiversion utility command.
    
- 1.0.0
    - Initial release for ESO Api version .

