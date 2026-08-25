# PB's MiniMap

A lightweight minimap add-on for **The Elder Scrolls Online on console** (PS5 / Xbox Series X|S).

Instead of drawing a second map, it parks the game's own World Map on the HUD at a size and
position you choose, and hands it straight back when you open the full map.

- **Author:** PinkBanther
- **Based on:** [Votan's Minimap](https://www.esoui.com/downloads/info1399-VotansMinimap.html)
  by **votan**, with thanks. The core idea — reuse the built-in world map rather than draw a
  new one — is votan's, and much of the map handling here still comes from that add-on.

## Why this exists

Console add-ons share a **100 MB memory pool**. Votan's Minimap exhausts it as soon as the
standard map is zoomed out to the full Tamriel view: the game loads every fast-travel node in
the world (and the housing/collectible data behind them) before culling them down to the
priority wayshrines, and any work that happens underneath an add-on's Lua frame is billed to
that pool. The add-on gets force-unloaded.

Bisecting the original narrowed the trigger to its `InitMiniMap` layer. This version skips that
layer entirely (`initLevel = 2`, the default) and keeps only what is needed to hold the map on
the HUD, so the full Tamriel view stays within the limit.

## What it does

- Keeps the game's own map visible on the HUD at a chosen size (down to 20x20) and position.
- Keeps the player centred, panning the map as you travel, and follows you across zones.
- Restores the game's default size and position the moment the full map is opened, and
  re-applies yours when it is closed.
- Live preview while adjusting size and position in the settings panel.
- Self-healing layout: if anything moves or resizes the window, it is put back within 200 ms.

## Settings

Settings live under **PB's MiniMap** (LibHarvensAddonSettings).

| Setting | Purpose |
| --- | --- |
| Mini Map | Master on/off |
| Width / Height | Minimap size (min 20) |
| Offset X / Offset Y | Position relative to screen centre |
| Follow player | Keep the player centred and pan the map as you move |
| Zoom: outdoors | Zoom in the open world. Centring needs this above 0 |
| Zoom: buildings & cities | Zoom on subzone maps, which are much smaller |
| Zoom: dungeons | Zoom in dungeons and trials |
| Zoom: battlegrounds | Zoom in battlegrounds |
| Show mini map now | Live preview inside the settings screen |
| Re-apply layout | Force the layout to be re-asserted |
| Debug: init level | Diagnostic. **2 is the working configuration**; 3+ reproduces the memory crash |
| Debug: minimap part | Diagnostic, only meaningful at init level 3+ |
| Debug: log to chat | Print the memory / map-state trail to chat (off by default) |

> The `Debug:` entries are kept deliberately: they are how the crash was isolated, and they
> make it possible to re-bisect quickly if a future game update changes the picture.

## Requirements

- `LibHarvensAddonSettings` >= 20106
- `LibAsync` >= 30001

## Releasing

The displayed name is fixed in `Main.lua`; the version comes from the manifest. To cut a new
version, edit these two adjacent lines in `PBsMiniMap.addon` and nothing else:

```
## Title: PB's MiniMap 1.0.5
## Version: 1.0.5
```

Console builds are distributed through **Bethesda.net**, not ESOUI — use the ZOS Console
AddOn Uploader. The name shown in the in-game browser comes from the uploader entry, not from
`## Title`.

## Layout rules that matter on console

- Folder name, manifest filename and `addon.name` must all match exactly (`PBsMiniMap`).
- PlayStation is case-sensitive: `PBsMinimap` != `PBsMiniMap`.

## Licence / attribution

This is a derivative of votan's work, redistributed with credit. If you intend to publish it
anywhere public, please contact votan first — the ESOUI community asks that derivatives of an
existing add-on are cleared with the original author.

---

This Add-On is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its
affiliates. The Elder Scrolls® and related logos are registered trademarks or trademarks of
ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.
