# lib/

**Nothing is bundled here today.** This folder is a placeholder.

## How the settings panel actually resolves

`src/Platform.lua` → `Platform.GetSettingsBackend()` looks up the **global**
`LibHarvensAddonSettings` at call time, and falls back to
`LibStub("LibAddonMenu-2.0")`. It does not care where that global came from.

That means the panel works whenever the library is present **by any route**:

* **LHAS installed as its own standalone add-on** — the common case, and what
  most testers will have. LHAS is published on ESOUI for PC and via the
  Bethesda.net add-on catalogue for console, so this works on Xbox and PS5 too.
* LHAS embedded here (see below).

If nothing provides the global, the add-on still loads and runs on defaults —
only the settings panel is suppressed (`ui/Settings.lua:Initialize`).

## Consequence for testers

A tester **without** LHAS gets no settings panel and, today, no explanation.
On console that also removes the only wipe/reset surface outside the gear
scene's keystrip. Either tell testers to install LHAS, or embed it.

## To embed (optional)

1. Download LibHarvensAddonSettings from
   <https://www.esoui.com/downloads/info1217-LibHarvensAddonSettings.html>.
2. Extract so the structure is
   `AccountHold/lib/LibHarvensAddonSettings/LibHarvensAddonSettings.lua`
   alongside any other files the library ships.
3. **Add the library's `.lua` files to the file list in `AccountHold.addon`,
   before `ui/Settings.lua`.** This step is mandatory and easy to miss: ESO only
   auto-loads add-on manifests at the top level of `AddOns/`, so a nested folder
   is NOT loaded on its own. Without manifest entries the embedded copy is inert
   and the panel stays missing — which looks identical to not embedding at all.
4. Re-test on console: embedding and a standalone install both define the same
   global, so verify you have not ended up loading it twice.

## Why embedding was originally planned

Per amendment A2.3 of the project brief, console players cannot install
libraries by hand from arbitrary sources. That concern is weaker in practice
because LHAS is in the console catalogue, but embedding still removes a
per-tester install step.
