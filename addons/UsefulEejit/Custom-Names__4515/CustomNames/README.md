# CustomNames

Renames zone names, location names, and NPC nameplates in ESO's UI.
All changes are UI-only — dialogue subtitles and voiced lines are unaffected.

## Setup

1. Install the addon folder as normal.
2. Launch the game once. On first run, ESO will create:
   `...\Elder Scrolls Online\live\SavedVariables\CustomNames_UserData.lua`
3. **Close the game.**
4. Open `CustomNames_UserData.lua` in any text editor and add your overrides.
5. Launch the game. On load, a chat message will confirm how many entries loaded.

## Editing CustomNames_UserData.lua

The file looks like this:

```lua
CustomNames_UserData = {

    zoneNames = {
        ["Grahtwood"]   = "Green Forest",
        ["Coldharbour"] = "The Bad Place",
    },

    locationNames = {
        ["Reaper's March"] = "Cat Country",
    },

    npcNames = {
        ["Razum-dar"] = "Raz",
    },

}
```

- Keys are **case-sensitive**. Use `/cnzone` in-game to get the exact string for your current zone.
- Set the value to `""` (empty string) to **hide** the label entirely.
- Always edit this file while the game is **closed**. ESO reads it on startup only.
- `enabled = false` at the top level disables all overrides without removing them.

## What gets renamed

| Setting | Where it appears |
|---|---|
| `zoneNames` | World map title, map blobs, wayshrine tooltips, compass zone text |
| `locationNames` | Map POI pins, fast travel node names, mouseover labels |
| `npcNames` | NPC nameplates above characters' heads |

## What does NOT get renamed

- Loading screen zone name (inaccessible from addon code — runs in a separate engine layer)
- Voiced dialogue and subtitles

## No in-game settings panel

There is no in-game settings UI. Everything is configured by editing the file directly.
This is intentional — it's simpler, more reliable, and gives you full control.
