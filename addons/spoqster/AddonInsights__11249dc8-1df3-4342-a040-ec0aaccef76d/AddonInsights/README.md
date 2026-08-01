# Addon Insights

An Elder Scrolls Online UI add-on that helps you review your add-on setup. There are two interfaces:

The **main UI** is the add-on's **Add-ons settings panel** (powered by LibAddonMenu-2.0), which renders as the native gamepad two-column settings screen. The left column lists four tabs; highlighting one shows its contents in the right pane:

1. **Addons** — every installed add-on, with `[LIB]` (library) and `[OUT]` (out of date) tags, plus its **size on disk**. Note: ESO's sandbox can't read an add-on's code/asset files, so the size shown is the add-on's **SavedVariables** (settings + stored data) footprint via `GetUserAddOnSavedVariablesDiskUsageMB` — the same figure consoles use for storage management. Add-ons with no saved data show `0 MB`; the header line shows the combined total.
2. **Orphaned Libraries** — enabled libraries that nothing depends on, i.e. removal candidates.
3. **Startup CPU** — load time each add-on took during startup (slowest first), charging each add-on the gap since the previous one loaded, plus the overall "to world" time and the measured total.
4. **Parallel Load Times** — an alternative accounting where each add-on's "load time" is the elapsed time from when Addon Insights *started measuring* to that add-on's load event, rather than only the gap since the previous one. This treats every add-on as if it began loading at the same instant (a **parallel-load model**), and shows the **sum** of those elapsed values so you can compare it against the console **1000 ms** add-on budget. Caveat: ESO actually loads add-ons sequentially, so this sum is a heuristic for spotting whether cumulative load pressure approaches the limit, not a literal CPU figure.

Below a divider, an **Open legacy window** button launches the **legacy UI** — a self-contained gamepad overlay (left tab list moved with the D-pad, right pane line-scrolled with the right stick). The legacy window is also launched with the **`/triage`** chat command.

The add-on does **not** declare a dependency on LibAddonMenu-2.0. That's deliberate: an `OptionalDependsOn` would delay our load until after LAM, but we want to begin timing add-on loads as early as possible, so we instead detect LAM at runtime and register the panel as soon as it's available (immediately if it loaded first, otherwise when its own load event fires).

Built to ZOS's console requirements (PS5 / Xbox Series X|S). Both interfaces are designed for gamepad / controller UI mode.

## Folder contents

```
AddonInsights/
  AddonInsights.addon   <- manifest (console reads this)
  AddonInsights.lua     <- all logic + the in-code UI + the menu entry
  Bindings.xml          <- keybind actions
  README.md
```

The folder and manifest name (`AddonInsights`) is plain alphanumeric — no spaces, no leading special character — which the console uploader expects. The display name lives in the manifest's `## Title` ("Addon Insights").

## Opening the interfaces

Main UI (the tabbed settings panel — requires **LibAddonMenu-2.0**, a free library in the console add-on browser):

- **Add-ons menu:** Settings > Add-ons > "Addon Insights".
- **Chat command:** open chat and type **`/addoninsights`**.
- **Keybind:** Settings > Controls > Keybindings > "Addon Insights" — assign a button to *Open Addon Insights menu*.

Inside the panel, highlight a tab to see its contents on the right.

Legacy UI (the standalone overlay) — two ways:

- The **Open legacy window** button at the bottom of the settings panel.
- The **`/triage`** chat command.

In the legacy window: move the **left list** up/down with the left stick to switch tabs, scroll the **right pane** with the **right stick**, **Square / X** to refresh, **B / Circle** (Back) to close. It remembers the last tab you viewed.

## Console install

Console add-ons are distributed through ZeniMax's Developer Uploader Tool (linked from `elderscrollsonline.com/community`), not by copying files. Upload this `AddonInsights` folder, then on your PS5 / Xbox Series X|S download + enable it from Settings > Add-ons and restart the game so it appears in your managed list. Add-ons only work on next-gen consoles, ZOS doesn't review or support them, and all add-ons share a 100 MB / ~1s-per-frame budget — this one is deliberately tiny.

## Startup-time caveat

Load times come from timestamping the game's "add-on loaded" signal, which fires once per add-on at startup. Addon Insights can only time add-ons that load after it; any that load earlier show under *"Not measured (loaded before us)"*. The numbers are best for spotting *relatively* heavy add-ons.

## Updating the API version

If it shows as out of date after a patch, update the first number on the `## APIVersion` line in `AddonInsights.addon`. On PC: `/script d(GetAPIVersion())`; on console, check the current value on esoui.com before re-uploading.

## Testing note

This follows ZOS's documented console requirements and the gamepad-UI / LibAddonMenu patterns, but the rendering, menu entry, and keybinds should be confirmed on a real device. On PC you can simulate console mode by setting `ForceConsoleFlow.2` to `1` in `UserSettings.txt`. A few gamepad APIs used here can only be exercised in-game and may need light tuning: the right-stick scroll speed (`RIGHT_STICK_SCROLL_SPEED` in `AddonInsights.lua`), the panel layout fractions, and the `GAMEPAD_NAV_QUADRANT_*_BACKGROUND_FRAGMENT` fragment names (guarded, so a missing name falls back to a plain backdrop rather than erroring).
