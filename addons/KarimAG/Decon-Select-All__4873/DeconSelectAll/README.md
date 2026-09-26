# Decon Select All

ESO add-on (keyboard UI) that adds a **"Select all"** button to the deconstruction panels, so you no longer slot items one by one:

* Blacksmithing / Clothing / Woodworking / Jewelry stations – **Deconstruction** and **Refinement** tabs
* **Universal Deconstruction** (Giladil the Ragpicker and other deconstruction assistants)
* Enchanting station – **Extraction** tab (glyphs)

The button appears in the keybind strip at the bottom of the screen, next to *Deconstruct* / *Clear selections*. It is mouse-clickable; a key can be bound under **Settings > Controls > Keybindings > Decon Select All**. A slash command does the same thing: `/dsa select`.

The add-on only *selects*. The game still shows its own confirmation dialog before a multi-item deconstruction, and *Clear selections* still empties the slot.

## What gets selected

Everything currently listed in the panel's inventory list — so the game's own tab (Armor / Weapons / Jewelry), the *Include banked items* checkbox and any filtering add-on (FCO CraftFilter, AdvancedFilters…) are respected — except:

| Rule | Default | Change with |
|---|---|---|
| Locked items (in-game padlock) | always skipped | – |
| Items protected by FCO ItemSaver (if installed) | always skipped | – |
| Set items | skipped | `/dsa sets` |
| Items with a trait you can still research | skipped | `/dsa research` |
| Ornate items (worth more sold) | skipped | `/dsa ornate` |
| Items used by an Armory build | skipped | `/dsa armory` |
| Quality above… | purple (gold skipped) | `/dsa quality 1-5` |
| Chat summary after each selection | on | `/dsa quiet` |

If **LibAddonMenu-2.0** is installed, the same options are available in *Settings > Add-Ons > Decon Select All* (`/dsaoptions`). It is optional.

`/dsa` alone prints the current settings.

## Game limits

The game allows at most `MAX_ITEM_SLOTS_PER_DECONSTRUCTION` (100) items per batch. If the list is longer, the add-on fills the batch, tells you so, and you simply deconstruct and click *Select all* again.

## Installation

1. Copy the `DeconSelectAll` folder into `Documents\Elder Scrolls Online\live\AddOns\`
   (`~/Documents/Elder Scrolls Online/live/AddOns/` on macOS). The folder must contain `DeconSelectAll.txt`.
2. Start the game (or `/reloadui`), open the Add-Ons menu at the character-select screen and make sure **Decon Select All** is enabled.
3. Interact with a crafting station, open the Deconstruction tab, click **Select all**.

After a game update the add-on may be flagged "out of date"; tick *Allow out of date add-ons* in the Add-Ons menu, or bump `## APIVersion` in `DeconSelectAll.txt`.

## Limitations

* Keyboard UI only. Gamepad-mode crafting screens use a completely different UI and are not supported.
* The Refinement tab support selects raw-material stacks (10 or more of the same material) up to the game's iteration limit.
* Tested against the ESO UI source 12.0.8 (API 101050 / Update 51 PTS 101051).

## Files

```
DeconSelectAll/
├── DeconSelectAll.txt   manifest (title, API version, files to load)
├── DeconSelectAll.lua   the add-on
├── Bindings.xml         the bindable "Select all" action
└── README.md
```

## Licence

MIT. Not affiliated with ZeniMax Online Studios.
