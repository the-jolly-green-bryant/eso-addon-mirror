command for finding house id

/script d(GetCurrentZoneHouseId() or GetCurrentHouseId() or "Not in a house")

command for get house collectible id

/script for i=1,GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_HOUSE) do local id=GetCollectibleIdForHouse(i); local name=GetCollectibleName(id); d(i.." "..name.." ("..id..")") end

/script for i=1,GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_HOUSE) do local id=GetCollectibleIdForHouse(can put the house id here); local name=GetCollectibleName(id); d(i.." "..name.." ("..id..")") end


# Orgeborn — Quick README

A tiny ESO addon that teleports you when you do specific things (read a book, pet an NPC, pick a chat option). You can add triggers entirely in-game with chat commands, or seed them in `Orgeborn_Config.lua`.

---

## Install & Files

**Folder:**
```
Documents\Elder Scrolls Online\live\AddOns\Orgeborn\
```

**Manifest (`Orgeborn.txt`)** must list files in this order:
```
Orgeborn_Config.lua
Orgeborn.lua
```

> Tip: If ESO marks it “out of date,” update `## APIVersion:` in the manifest.

---

## What counts as a “trigger”?

- **BOOK** — a lore book by `bookId` (fires when you open it).
- **INTERACT** — a single “Press E to …” prompt (e.g., Pet, Read) for a specific target label.
- **CHATTER** — an option text in an NPC dialog menu (e.g., Pet).

Each trigger can have its **own destination** (per-trigger `dest`) or fall back to a **default destination**.

**Destinations**:
- `SELF` — your own house (pass **collectibleId**; inside/outside supported)
- `ACCOUNT` — someone’s **primary** residence by `@name`
- `SPECIFIC` — someone’s **specific** house by **houseId** (not collectibleId)

---

## Everyday workflows (no Lua editing)

### A) Add a **book** trigger → teleport somewhere
1. Open the book once (so Orgeborn caches it), then:
   ```
   /og add book
   ```
2. Set where it should send you:
   - To **someone’s primary**:
     ```
     /og dest account @TheirName
     ```
   - To **your own house** (inside/outside):
     ```
     /og dest self <yourCollectibleId> inside
     ```
   - To **someone’s specific house** (see “Capturing a houseId” below):
     ```
     /og dest specific @TheirName <houseId or collectibleId>
     ```
3. Check:
   ```
   /og list
   ```

### B) Add a **simple interact** trigger (e.g., Pet the cat)
1. Look at the target so the reticle shows the action (e.g., “Pet”), then:
   ```
   /og add interact Pet
   ```
   (It records the target label under your crosshair + action text.)
2. Give it a destination (either set a **default**, or set **per-trigger**; see below).

### C) Add a **chat menu** trigger (dialog option)
1. Start talking to the NPC (the options list shows).
2. Add by option text:
   ```
   /og add chatter Pet
   ```

---

## Per-trigger destinations (book goes here, cat goes there)

You can set a **different destination** per trigger:

### 1) Quickest method — “bind to the house I’m standing in”
1. **Port into** the house you want this trigger to use.
2. Find the trigger’s index:
   ```
   /og list
   ```
3. Bind that trigger to “here” (captures the correct **houseId** automatically):
   ```
   /og setdest <index> here <@owner>
   ```
   Example:
   ```
   /og setdest 1 here @SublimeCaver
   ```

### 2) Use a global default (applies to triggers that don’t have their own `dest`)
- Your house:
  ```
  /og dest self <collectibleId> [inside|outside]
  ```
- Someone’s primary:
  ```
  /og dest account @TheirName
  ```
- Someone’s specific (if you know the real **houseId**):
  ```
  /og dest specific @TheirName <houseId>
  ```

> **Tip:** `/og houses` will list your **collectibleIds**.  
> For SPECIFIC jumps to *someone else’s* house, you must use a **houseId** (not a collectibleId). Use `setdest ... here` to capture it easily while you’re inside that house.

---

## Seeding via `Orgeborn_Config.lua` (optional)

You can predefine a default destination and triggers. On load, Orgeborn can **auto-import** or you can do it manually.

**Example `Orgeborn_Config.lua`:**
```lua
Orgeborn_Config = {
  ConfigVersion = 1,            -- bump this number when you edit config
  ImportMode = "replace",       -- "merge" or "replace"
  defaultDestination = {
    mode = "ACCOUNT",
    owner = "@SublimeCaver",
    houseId = nil,
    travelOutside = false,
  },
  triggers = {
    -- Book trigger (per-trigger dest)
    {
      type = "BOOK",
      id = 6532,  -- Tribes of Blackwood: Riverbacks
      dest = { mode="SPECIFIC", owner="@SublimeCaver", houseId=1076 }, -- collectibleId OK; you can later bind to true houseId via /og setdest
    },
    -- Example interact trigger (cat “Pet”):
    -- { type="INTERACT", unit="Eater of Knowledge", actionMatch="Pet", dest={ mode="SELF", houseId=47 } },
  },
}
```

**Import in-game:**
```
/og import          -- merge
/og resetconfig     -- replace everything with config
```

**Auto import at load:**
- It’s already on by default. To control it:
```
/og autoconfig on|off
/og importmode merge|replace
```
If you edit the config, **bump `ConfigVersion`** and `/reloadui`.

---

## Capturing the correct **houseId** (SPECIFIC jumps)

- SPECIFIC jumps need a **houseId** (small integer), not a collectibleId.
- Easiest way: **stand in the target house**, then:
  ```
  /og setdest <index> here @OwnerName
  ```
- Or set the **default** to “here”:
  ```
  /og dest here @OwnerName
  ```
Both commands record the real `houseId` automatically.

---

## Useful commands (cheat sheet)

```
/og on | /og off                 Enable/disable the addon
/og list                         List triggers (shows destinations)
/og houses                       List your house collectible IDs
/og peek                          Print your current reticle target/action
/og add book                      Add the last opened book as a trigger
/og add interact <text>           Add a simple interact trigger (e.g., Pet, Read)
/og add chatter <option text>     Add a chat menu trigger for the current NPC
/og del <index>                   Delete a trigger by index

/og dest self <collectibleId> [inside|outside]
/og dest account <@name>
/og dest specific <@name> <houseId_or_collectibleId>
/og dest here <@owner>           (while standing in a house)

/og setdest <index> here <@owner> Bind that trigger to the house you’re in (captures real houseId)

/og import                       Merge from Orgeborn_Config.lua
/og resetconfig                   Replace with Orgeborn_Config.lua
/og autoconfig on|off             Auto-import on load
/og importmode merge|replace      Default import behavior
/og configversion <n>             Override last imported ConfigVersion

/og debug books on|off
/og debug chatter on|off
/og debug reticle on|off
/og debug interacthooks on|off
```

---

## Troubleshooting

- **Reading a book prints the id but no teleport**
  - Run `/og list` — make sure the book trigger shows `dest:` info.
  - If `dest` looks right, the Lore Reader might block jumps: Orgeborn closes it and ports after ~250ms (already handled).
- **JumpToSpecificHouse does nothing**
  - You probably passed a **collectibleId** instead of **houseId**. Use `/og setdest <index> here @Owner` inside the house to capture the true id.
- **`/og import` says 0 added / 0 updated**
  - Ensure `Orgeborn_Config.lua` is listed **before** `Orgeborn.lua` in the manifest, and starts with a **global**:
    ```lua
    Orgeborn_Config = { ... }
    ```
- **Trigger didn’t add**
  - For books: open the book *first*, then `/og add book`.
  - For interact: aim at the thing (reticle shows e.g., “Pet”), then `/og add interact Pet`.
  - For chatter: start the conversation, then `/og add chatter <option>`.

---

## Examples

**Book 6532 → @SublimeCaver Ravenhurst**
```
/og resetconfig     (after placing it in config)
(or)
/og add book        (after opening the book)
 /og setdest 1 here @SublimeCaver  (while inside Ravenhurst)
```

**Cat “Pet” → your own house (collectible 47)**
```
/og add interact Pet
/og setdest 2 here @SublimeCaver   (or set a different dest)
/og list
```

---

If you ever forget the commands, just type:
```
/og help
```
and it’ll print the quick guide in chat.
