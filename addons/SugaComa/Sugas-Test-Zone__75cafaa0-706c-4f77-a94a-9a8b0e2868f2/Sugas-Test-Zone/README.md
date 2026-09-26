# Suga's Test Zone

Suga's Test Zone (STZ) is a private development and QA container for ESO add-ons.
It lets an existing standalone build remain installed and usable while a new or
experimental version is tested under the separate `Sugas-Test-Zone` add-on.

The clean, reusable STZ base build is version `1.0`. Projects hosted inside STZ
have their own independent iteration versions. A project's version must not be
used as the STZ host version.

`Do_Not_Alter/` is protected STZ material. It is part of the reusable host and
must not be edited, renamed internally, used as a workspace or listed as the
active experiment.

All experimental source belongs directly in `Projects/`.
`Projects/STZ_ProjectSlot.lua` is the experiment's main Lua file and bootstrap.
It is renamed to the project's final main filename when the experiment migrates
into its own standalone add-on container.

## The important rule

ESO only loads files explicitly listed in `Sugas-Test-Zone.addon`.

Copying helper Lua files into `Projects/` does **not** make them active by
itself. List each helper in `Sugas-Test-Zone.addon`, in dependency order, before
`Projects/STZ_ProjectSlot.lua`. The slot remains the main file and owns project
startup.

## Folder layout

```text
Sugas-Test-Zone/
|-- Sugas-Test-Zone.addon       ESO manifest and load order
|-- Bindings.xml                Keybind declarations
|-- STZ_Core/                   Permanent test-container code
|   |-- STZ_Config.lua          Version, owner, access and release settings
|   |-- STZ_Access.lua          Private/guild/public authorization
|   |-- STZ_Notice.lua          Access-denied notice
|   |-- STZ_SelfTest.lua        Access diagnostics
|   |-- STZ_AbilityTools.lua    Ability lookup, tracing and export
|   |-- STZ_Menu.lua            LibHarvensAddonSettings controls
|   `-- STZ_Main.lua            Host startup and saved variables
|-- Do_Not_Alter/               Protected STZ material; never edit
`-- Projects/
    |-- project helper files    Active experiment implementation
    `-- STZ_ProjectSlot.lua     Active experiment main file and bootstrap
```

`STZ_Core/` and `Do_Not_Alter/` should stay stable. Project-specific gameplay,
UI, documentation and saved data belong only in `Projects/` so they can later
be moved into their own add-on container.

## Version and lifecycle model

STZ follows a reusable-container lifecycle:

1. Start from the clean STZ base build, version `1.0`.
2. Build one experimental project directly under `Projects/`.
3. Give that project its own iteration version, such as `0.1-test1`,
   `0.1-test2` or `0.2-rc1`.
4. Deploy the experiment into `Projects/` and activate it through the manifest
   and project slot.
5. Iterate the project version without changing the STZ base version.
6. When testing is complete, migrate the project into its own standalone add-on
   container.
7. Reinstall or restore the clean STZ 1.0 base before starting the next
   experiment.

The host version identifies the reusable testing framework. The project version
identifies the code currently under test.

## The three working areas

Use this simple rule every time:

- `back_up/` is the rollback area. It contains the last known good working
  version and is not used for development.
- `Development/` is the editable working area. All building and changes happen
  here.
- `Testing/` is the PS5 handover area. Each handover is placed in one parent
  folder named for the build being tested.

A testing handover uses this structure:

```text
Testing/
`-- Build-Name_Version/
    |-- Sugas-Test-Zone/    Complete ESO add-on container
    |-- CHANGELOG.txt       Changes for the project under test
    `-- UAT_SCRIPT.txt      PS5 test instructions and result record
```

The testing changelog covers the experimental application in `Projects/`, not
routine STZ container packaging. Do not edit a handed-over build in `Testing/`;
return failed work to `Development/` and create a newly versioned handover.

## How STZ starts

1. ESO loads the files in manifest order.
2. `STZ_Main.lua` waits for `EVENT_ADD_ON_LOADED`.
3. The host creates the account-wide `SugasTestZone_SV` saved variables.
4. It restores the configured access mode and approved guild IDs.
5. It registers slash commands, ability tools and the settings menu.
6. When populated, `Projects/STZ_ProjectSlot.lua` waits for the host
   add-on-loaded event and starts the active project after host setup completes.
7. The project's initializer asks `SUGAS_TEST_ZONE:CanLoadProject(...)` for
   access before registering or starting project features.

The project initializer must run **after** step 3. Calling it while the manifest
is still being parsed is too early because the host saved variables and access
configuration have not yet been initialized.

## Deploy a project into the test zone

### 1. Work only in `Projects/`

Place the experiment's helper files directly in `Projects/`. Use project-specific
prefixes so they are easy to identify and migrate. Keep
`Projects/STZ_ProjectSlot.lua` as the experiment's main file.

Use a project namespace, saved-variable name, event names and external module ID
that do not collide with either STZ or the existing live add-on.

Never place experimental files in `Do_Not_Alter/` or `STZ_Core/`.

### 2. Add the files to the manifest

In `Sugas-Test-Zone.addon`, place the active project helper files after the host
files and before `Projects/STZ_ProjectSlot.lua`.

For example, the BackBarTimer + CadenceCoach test build uses:

```text
Projects/BBTC_Config.lua
Projects/BBTC_State.lua
Projects/BBTC_HUD.lua
Projects/BBTC_Tracker.lua
Projects/BBTC_Menu.lua
Projects/STZ_ProjectSlot.lua
```

Why order matters:

- configuration and state must exist before runtime modules use them;
- HUD and tracking definitions load before startup;
- the menu loads after the runtime modules it calls;
- the slot is last because it is the main file and starts the project only after
  every helper definition exists.

Also update the manifest metadata when the project needs it:

- add the project's saved-variable name to `## SavedVariables`;
- add required libraries to `## DependsOn` or `## OptionalDependsOn`;
- verify the current ESO `## APIVersion` values;
- keep the STZ host at version `1.0` and identify the experiment through its
  own project version.

That example declares `SugasTestZoneBBTCadence_SV`. Its only optional settings
dependency is LibHarvensAddonSettings.

### 3. Make the project slot initialize the active project

`Projects/STZ_ProjectSlot.lua` owns initialization. It registers for the STZ
add-on-loaded event and defers the project initializer until the current event
dispatch has completed. This allows `STZ_Main.lua` to finish restoring access
settings without adding project hooks to permanent host code.

When migrating, rename `STZ_ProjectSlot.lua` to the final project's main Lua
filename and replace the STZ access gate with the standalone add-on's normal
startup.

### 4. Declare and verify dependencies

Before packaging, check every global library used by the project. A missing
optional UI library may allow graceful degradation; a missing required library
may make the project invisible or unusable.

For Winter's Harvest:

- `LibSTARSConnect` is needed to register the game in STARS;
- `LibHarvensAddonSettings` is optional for the host settings screen;
- `LibCombatSkills` is optional for richer ability lookup results.

### 5. Test access before transferring

The owner account is always allowed. Available access modes are:

- `private` - `@SugaComa` only;
- `guild` - owner plus members of any approved numeric guild ID;
- `public` - everyone.

For a distributed test build, edit the deployment values in
`STZ_Core/STZ_Config.lua`. Owner-only settings changes are local saved-variable
overrides and do not alter the packaged deployment rules for other accounts.

Useful checks:

```text
/stzaccount   Confirm the owner account check
/stzguild     Check approved-guild membership
/stzguilds    Print all guild names and numeric IDs
/stzfull      Run the complete access self-test
```

### 6. Package and smoke-test

Before putting the test build on PS5:

1. Confirm every path in the manifest matches the packaged folder exactly.
2. Confirm the project saved-variable name is declared.
3. Confirm required libraries are installed and enabled.
4. Load/reload ESO and run `/stzfull`.
5. Confirm the project appears in its intended UI.
6. Start, cancel and restart one test run.
7. Trigger the project's main events and confirm saved records survive reload.
8. Confirm the existing standalone/live add-on still behaves normally.
9. Confirm STZ and the live add-on do not share globals, event-registration
   names, saved variables or external module IDs.

During project iteration, bump the project's version in its own configuration.
Leave the STZ host at version `1.0` unless the permanent host framework itself
has changed.

## Winter's Harvest example behaviour

Winter's Harvest is a gathering survival-game example built around three
clocks:

- **HARVEST** starts at 10 minutes and is capped at 20 minutes.
- **GATHER** gives the player 45 real-time seconds to harvest another resource
  node. Missing it removes 30 seconds from HARVEST.
- **SURVIVED** records real elapsed time and is never affected by game effects.

Every successfully detected resource node resets GATHER and rolls exactly one
roulette effect:

- 20% add time;
- 18% remove time;
- 14% freeze HARVEST;
- 14% slow HARVEST;
- 14% accelerate HARVEST;
- 20% do nothing.

The detector correlates harvest interactions, loot events and inventory events.
It supports backpack and Craft Bag delivery and uses short deduplication windows
so a node that yields several materials still produces one roulette roll.

The run ends when HARVEST reaches zero. Travel/loading cancels an active run.
Games played, best survival time, total nodes, missed-gather penalties and the
last result are stored account-wide.

## Ability research tools

The permanent STZ host also includes tools for researching ESO ability IDs:

```text
/stzability ID          Look up an ability ID
/stzabilitymonitor on   Start monitoring
/stzabilitymonitor off  Stop monitoring
/stzabilitymode focused Direct action-slot activations only
/stzabilitymode raw     Broad player combat-event feed
/stzabilityexport       Export captured results
/stzabilityclear        Clear captured results
```

The monitor retains up to 40 results in memory and suppresses duplicates within
500 ms. Export is user-triggered and restricted to supported Google Apps Script
or Google Forms endpoints.

`Bindings.xml` currently references `STZ_ABILITY_LOOKUP()`, but that global
function is not defined in the current Lua files. The keybind should be repaired
or removed before relying on it; the slash command and settings button remain
the documented lookup methods.

## Move a tested project into its own add-on container

When the experimental build is ready to become standalone:

1. Copy only the project code into a new add-on folder.
2. Create its standalone `.addon` manifest.
3. Replace the STZ access-gated startup with the project's normal
   `EVENT_ADD_ON_LOADED` bootstrap.
4. Give it final, unique global namespaces and event-registration names.
5. Rename its saved variables and declare them in the new manifest.
6. Give any STARS or other external integration a final unique module ID.
7. Declare all required and optional libraries.
8. Remove STZ-only diagnostics, test access controls and temporary export code
   that the release does not need.
9. Test migration with clean saved variables and with any data intended to be
   preserved from the test version.
10. Only after the standalone build works should its copy be removed from the
    STZ manifest and project slot.

## Restore the clean base after migration

After a project has been migrated and installed in its own container:

1. Reinstall the known-clean STZ 1.0 base, or restore its files from the clean
   source copy.
2. Confirm `Projects/STZ_ProjectSlot.lua` is empty.
3. Remove all project-specific file entries from `Sugas-Test-Zone.addon`.
4. Restore the manifest's saved-variable and dependency declarations to the
   base set only.
5. Remove the project-specific helper and documentation files from `Projects/`
   after confirming the standalone copy is safe.
6. Confirm `Do_Not_Alter/` and `STZ_Core/` were not changed during the project.
7. Confirm both the manifest and `STZ_Core/STZ_Config.lua` report STZ version
   `1.0`.
8. Load the clean container and run `/stzfull`.
9. Confirm no project UI, events or saved-data writes occur.

Restoring the base prevents old experimental modules, dependencies, saved
variables or activation code from leaking into the next test cycle.

## Returning after a long break

Use this quick checklist:

1. Read `Sugas-Test-Zone.addon` first; it is the truth about what ESO loads.
2. Inspect `Projects/STZ_ProjectSlot.lua` to see which project is activated.
3. Treat `Do_Not_Alter/` as protected host material and never edit it.
4. Keep all active experiment work directly in `Projects/`.
5. Check namespace, saved-variable and external-module IDs for collisions.
6. Check access mode and approved guild IDs in `STZ_Config.lua`.
7. Check ESO API versions and library availability.
8. Run `/stzfull`, then perform a clean smoke test.

## Current repository state

At the time this README was written:

- the reusable STZ base is version `1.0`;
- the permanent STZ host and ability tools are listed in the manifest;
- `Projects/STZ_ProjectSlot.lua` activates the BackBarTimer + CadenceCoach
  experiment;
- the active experiment is iteration `0.1.0-test9` and has separate saved
  variables;
- its helper files live directly in `Projects/` and load before the project
  slot/main file;
- the test9 HUD uses fixed positions with 100% button images raised by four UI
  pixels from ten to two seconds and unchanged skill images for the final two
  seconds;
- Dual-Bar HUD users can show the full tracked skill countdown or choose a
  custom prompt start time from 3 to 60 seconds (10 seconds by default);
- `STZ_Core/` contains no project-specific startup hook;
- the Winter's Harvest files under `Do_Not_Alter/` are not listed in the manifest;
- Winter's Harvest therefore remains an inactive reference example;
- the old `Do_Not_Alter/EXPORT_NOTES.txt` refers to obsolete `Current_Project` and
  underscore-style filenames and should not be treated as the current procedure.
