# ContainerVisitHide

Companion add-on for **HarvestMap** (ESO).

## What it fixes

HarvestMap’s **spawn filter** (“only show currently spawned resources”) works for ore, wood, herbs, etc.  
It **does not** work for containers:

- Chests  
- Heavy sacks / crates  
- Thieves troves  
- Safeboxes (justice)  
- Stashes (loose panels / tiles / stones)

That limitation is intentional in HarvestMap (containers are not exposed the same way as harvest nodes). HarvestMap also removed its old “hide visited nodes” timer for performance, so looted containers stay visible.

**ContainerVisitHide** restores hide-after-loot behavior **for containers only**:

1. You loot a container  
2. HarvestMap records the node  
3. This add-on hides that pin (map, compass, 3D) for N minutes  
4. When the timer ends, the pin comes back (assumes it may have respawned)

## Requirements

- **HarvestMap** (required)  
- **LibAddonMenu-2.0** (optional — settings panel; slash commands work without it)

## Install — PC

1. Copy the `ContainerVisitHide` folder to:

   ```
   Documents\Elder Scrolls Online\live\AddOns\ContainerVisitHide\
   ```

2. Folder must contain at least:
   - `ContainerVisitHide.txt`
   - `ContainerVisitHide.lua`

3. In-game: enable **ContainerVisitHide** in the Add-Ons list (and HarvestMap).

4. `/reloadui` if you installed while logged in.

## Install — Xbox / PlayStation

Console only loads add-ons from the **in-game Bethesda.net browser**, not from a USB stick or PC copy.

To publish this for console (Xbox Series X|S / PS5):

1. Create / log into a [Bethesda.net](https://bethesda.net) account  
2. Use the official **ESO Console Add-Ons Developer Uploader Tool**  
3. Upload this folder (includes `ContainerVisitHide.addon`)  
4. After approval, install it from the in-game add-on browser on your console  

See: [ESO Console Add-ons – Developer Uploader Tool](https://help.bethesda.net/app/answers/detail/a_id/69621)

**Note:** Do not re-upload HarvestMap itself. This is an original companion that *depends on* HarvestMap.

## Settings

**ESC → Settings → Add-Ons → Container Visit Hide** (if LibAddonMenu is installed)

| Setting | Default | Meaning |
|--------|---------|---------|
| Enable | On | Master switch |
| Hide duration | 10 min | How long pins stay hidden after loot |
| Hide chests / sacks / troves / safeboxes / stashes | On | Per type |
| Debug chat | Off | Log hide events to chat |

### Slash commands (PC & console chat)

| Command | Effect |
|---------|--------|
| `/cvh help` | Show commands |
| `/cvh on` / `/cvh off` | Enable / disable |
| `/cvh time 15` | Set hide duration to 15 minutes |
| `/cvh clear` | Immediately show all currently hidden pins |
| `/cvh status` | Print settings + number of hidden pins |
| `/cvh debug` | Toggle debug chat |

## How to use with HarvestMap

1. Keep HarvestMap **spawn filter** on for ore/wood/herbs as you like.  
2. Leave container pin filters **on** in HarvestMap (so pins exist).  
3. Enable this add-on — looted containers will disappear for the hide timer.  
4. Tune **hide duration** to taste (5–15 min is a good start for sacks; chests may feel better at 10–20).

## Technical notes

- Hooks HarvestMap’s `NODE_HARVESTED` callback (fires when HM saves a harvest).  
- Pre-hooks map pin creation and compass/3D pin updates so hidden nodes are not redrawn.  
- Hide keys use map + pin type + rounded world coordinates so they survive map-cache rebuilds.  
- Does **not** modify HarvestMap files or redistribute HarvestMap data.

## Limitations

- Chests are often registered when lockpicking **starts** (HarvestMap behavior), not only on success.  
- Cannot know if another player already looted a container across the zone (same limitation as old visited timer).  
- Only hides pins **you** trigger while the add-on is enabled.  
- Console UI for LibAddonMenu varies; use `/cvh` if the settings panel is awkward on controller.

## License / credit

Original idea and HarvestMap integration based on public HarvestMap APIs by **Shinni**.  
This companion is original code and does not copy HarvestMap sources.
