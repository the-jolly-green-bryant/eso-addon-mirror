STARS MODULE TEMPLATE
=====================

PURPOSE
-------
This template creates an independent ESO addon that can publish its own data,
records and controls inside the STARS Journal through LibSTARSConnect.

The connected addon remains responsible for its own SavedVariables and game
logic. STARS is only the presentation host. Removing or disabling the module in
STARS must never delete the addon's records.


WHAT WAS STANDARDISED
---------------------
All reusable bridge files live inside STARSConnect. They contain no addon name,
module ID, global namespace or project-specific gameplay calls.

The root config.lua is loaded first and supplies every identity and registration
value used by STARSConnect. This means a new project does not require search-and-
replace work inside the STARSConnect folder.

Project-specific behaviour belongs in Project.lua or additional root/project
files loaded before Project.lua. Main.lua is a fixed startup file.


CREATE A NEW MODULE
-------------------
1. Copy the complete STARS_MODULE_TEMPLATE folder.
2. Rename the copied addon folder to the final addon name.
3. Rename project-manifest.txt to the same addon name with the .addon extension.
4. Edit the PROJECT SETTINGS section at the top of config.lua.
5. Edit the manifest header. The manifest SavedVariables value must exactly match
   config.lua savedVariablesName. The addonName must match the name ESO reports
   for the addon, normally the addon folder/manifest name.
6. Replace the example presentation and hooks in Project.lua with project logic.
7. Do not edit STARSConnect for ordinary project work. Update that folder only
   when deliberately rolling a shared template/framework improvement forward.
8. Delete the final instructional comments from the finished manifest.


ROOT CONFIGURATION
------------------
addonName
    The ESO addon identifier used by EVENT_ADD_ON_LOADED and event prefixes.

namespace
    The unique Lua global table used by the addon. It must be a valid Lua
    identifier, for example TamrielRaces or WintersHarvest.

version
    The addon/module version shown to LibSTARSConnect and diagnostics.

savedVariablesName / savedVariablesVersion
    Must match the manifest SavedVariables declaration and migration plan.

module.id
    A permanent unique LibSTARSConnect ID. Do not change it after public release
    unless the module is intentionally being treated as a different product.

module.presentationType
    game            -> STARS > Adventures
    correspondence  -> STARS > Correspondence
    library         -> STARS > Library

module.apiVersion
    The LibSTARSConnect contract version. The current template uses API 1.

records.historyLimit
    Maximum generic records retained by STARSConnect/Records/Records.lua.

hud.enabled
    False by default. When enabled, Project.lua may provide CreateHUD,
    RefreshHUD and ShutdownHUD methods.


PROJECT.LUA CONTRACT
--------------------
The template supplies these optional extension points:

Initialize()
    Called once after SavedVariables and reusable services are ready.

OnPlayerActivated()
    Called from EVENT_PLAYER_ACTIVATED.

GetPresentationData()
    Return the data table currently shown by STARS.

GetEntryCount() and ChangeEntry(delta)
    Optional internal L2/R2 navigation between records, letters, books or views.

GetActions()
    Optional Journal controls:
      primary   -> X
      secondary -> Square
      tertiary  -> Triangle
      utility   -> L3
    Circle remains reserved for Back/Exit and must not be used by a module.

Shutdown()
    Optional cleanup hook.

Call Project:NotifyChanged() after changing data currently shown in STARS.
The generic Records:Add() and Records:Clear() helpers already do this.


PRESENTATION DATA
-----------------
Game / Adventure example:

    return {
        title = "MY ADVENTURE",
        subtitle = "OPTIONAL SUBTITLE",
        lines = { "Line one", "Line two" },
    }

Correspondence example:

    return {
        collectionTitle = "Hireling Mail",
        senderName = "Sender",
        subject = "Subject",
        entryIndex = 3,
        entryCount = 20,
        body = "Scrollable correspondence body...",
    }

Library example:

    return {
        collectionTitle = "Collected Books",
        title = "Book Title",
        author = "Author",
        entryIndex = 4,
        entryCount = 30,
        body = "Readable book body...",
    }


FOLDER RULES
------------
config.lua and Project.lua are intentionally outside STARSConnect.

Do not hard-code a project namespace, addon name, module ID or gameplay feature
inside STARSConnect. Reusable files must access the project through the local
Project reference captured from config.lua during loading.

Do not store connected-addon data in STARS SavedVariables. The addon remains the
authoritative owner of its own data.


RELEASE PACKAGING STANDARD
--------------------------
Every test and release zip should contain a full addon folder plus a completed
changelog at the zip root:

    AddonName_version.zip
    |-- CHANGELOG_version.txt
    `-- AddonName/
        |-- AddonName.addon
        |-- config.lua
        |-- Main.lua
        |-- Project.lua
        `-- STARSConnect/...

Use CHANGELOG-TEMPLATE.txt for all addons going forward. Never ship only the
changed files: a complete package makes testing, rollback and archive comparison
safer.
