Meterskull Console - original-code adaptation
Version: 1.5.7-console.1

Changes:
- Keeps the supplied Meterskull 1.5.7 calculation/module code.
- Keeps LibAddonMenu-2.0 and raises declared dependency to r43.
- Adds controller-friendly X/Y sliders for every meter window.
- Keeps the existing independent per-window scale sliders.
- UI lock now applies immediately when changed.
- Keeps PC mouse dragging as an additional positioning method.
- Updates the manifest API declaration to 101050 for the current adaptation target.

Testing note:
This package has been statically adapted but cannot be runtime-tested against ESO from this environment.
Test first with ESO's Gamepad UI / Force Console Flow before console upload.


Console package note:
- Console manifest is now MeterskullConsole.addon
- The Lua source files remain separate and are referenced by the .addon manifest.
- File and folder casing in the manifest exactly matches the packaged files for PlayStation compatibility.


console.3 fix:
- Accepts EVENT_ADD_ON_LOADED identity "MeterskullConsole" as well as original "Meterskull".
- This allows SavedVariables initialization and MS.BuildMenu() to run when loaded from MeterskullConsole.addon.
- Adds ConsoleBoot.lua as a minimal boot marker.
