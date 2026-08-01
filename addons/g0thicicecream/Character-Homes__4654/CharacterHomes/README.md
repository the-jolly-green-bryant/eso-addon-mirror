# CharacterHomes

A standalone Elder Scrolls Online addon for managing and teleporting to your homes — across characters and account-wide — with an integrated friend housing bar.

No addon dependencies. Uses only native ESO APIs and textures.

---

## Overview

CharacterHomes gives you a single, searchable dialog to manage every home you want quick access to:

- Save homes **per character** (one primary + unlimited named) or **account-wide**
- Save a **friend's house** to your list for one-click access later
- **Search** across display labels, official ESO house names, geographic zones, and owner @accounts
- **Teleport** to any saved home from the dialog or directly via slash command

---

## Installation

1. Download and extract the `CharacterHomes` folder
2. Place it in `\Elder Scrolls Online\live\AddOns\CharacterHomes\`
3. Enable the addon in the ESO Addon Manager
4. A full game restart is recommended after first install

**No library or addon dependencies required.**

---

## Slash Commands

| Command | Description |
|---|---|
| `/setglobalhome <label>` | Save current house as an account-wide home with the given label |
| `/setmyhome` | Set current house as your character's primary home (unnamed) |
| `/setmyhome <label>` | Save current house as a named character home with the given label |
| `/resethome` | Clear your character's primary home |
| `/delhome <name>` | Remove an account-wide home by label (partial match supported; lists ambiguous matches) |
| `/delmyhome <name>` | Remove a character home; use `primary` to remove primary home |
| `/gohome` | Teleport to your character's primary home |
| `/gohome <query>` | Search homes by label and teleport; falls back to matching owned ESO house names |
| `/homes` | Open the Character Homes dialog |

> **Note on conflicts**: `/sethome` and `/home` are registered by Essential Housing Tools. CharacterHomes uses `/setglobalhome` and `/gohome` to avoid collisions.

---

## Dialog UI

Open with `/homes`.

### List area

Each row shows:

| Element | Description |
|---|---|
| **Teleport icon** | House icon for primary homes; wayshrine icon for all others. Click to teleport and close dialog. |
| **Owner** | @account name for a friend's house; blank for your own |
| **Display label** | Your arbitrary name for the entry (white text) |
| **Official ESO house name** | The game's name for the property (gray text) |
| **Edit pencil** | Opens inline edit mode — rename label and/or change house |
| **X button** | Removes the entry from your list |

### Friend housing bar (upper bar)

```
Friend: [▼]  [Type ▼]  House: [▼]  Name: [___________]  [✓]  [⌂]
```

| Control | Description |
|---|---|
| **Friend** | Dropdown of your current friends list |
| **Type** | Where to save: Primary (character), Named (character), or Account wide |
| **House** | All ESO houses (owned or unowned) |
| **Name** | Optional label for the saved entry |
| **✓** | Saves the friend's house to your homes list with the chosen type and label |
| **⌂** | Teleports immediately to the friend's house — does **not** save to list |

### Add bar (lower bar)

```
My homes:  [Type ▼]  House: [▼]  Name: [___________]  [✓]  [⌂]
```

| Control | Description |
|---|---|
| **Type** | Where to save: Primary (character), Named (character), or Account wide |
| **House** | Your owned houses only |
| **Name** | Optional label (defaults to official ESO house name if left blank) |
| **✓** | Saves to list; clears Name box on success |
| **⌂** | Teleports to selected house immediately |

---

## SavedVariables Structure

```lua
CharacterHomesSavedVars = {
    account = {
        -- key = official ESO house name (stable, never changes when you rename)
        ["Stone Eagle Aerie"] = {
            houseId     = 48,
            owner       = nil,           -- nil means your own house
            displayName = "My Retreat",  -- user's chosen label
            zone        = "Craglorn",    -- geographic parent zone
        },
        ["Amaya Lake Lodge"] = {
            houseId     = 14,
            owner       = "@FriendName", -- @account of the friend
            displayName = "the bug house",
            zone        = "Reaper's March",
        },
    },
    characters = {
        ["CharacterName"] = {
            primary = { houseId=62, owner=nil, displayName="Primary Residence", zone="Artaeum" },
            named   = {
                ["Elinhir Private Arena"] = {
                    houseId=66, owner=nil, displayName="My Arena", zone="Craglorn"
                },
            },
        },
    },
}
```

**Key points:**
- Keys are always the **official ESO house name** from `GetCollectibleName(GetCollectibleIdForHouse(houseId))`. These remain stable when you rename an entry.
- `displayName` is the user's arbitrary label.
- `owner` is the `@account` display name for a friend's house; `nil` for your own.
- `zone` is the **geographic parent zone** (e.g., `"Artaeum"`, not `"Grand Psijic Villa"`).
- A migration function runs on every load to recompute zones and re-key any legacy entries to official house names.

---

## Compatibility

| Addon | Status |
|---|---|
| Essential Housing Tools | Supported — command conflicts resolved (`/setglobalhome`, `/gohome`) |
| Port to Friend's House | Optional — a quick-open link appears in the dialog if the addon is loaded |

---

## For Developers / Maintenance Guide

### Architecture

| File | Responsibility |
|---|---|
| `CharacterHomes.xml` | All control definitions, dimensions, anchors, textures |
| `CharacterHomes.lua` | Logic, ZO_ComboBox creation, dynamic rows, event handlers |

**Rule:** Never position or size controls in Lua if they can be defined in XML. Lua is only used for controls that must be created dynamically at runtime (scroll rows, combo boxes populated from game data).

---

### Key ESO APIs used

```lua
GetCurrentZoneHouseId()                          -- are we inside a house?
GetCurrentHouseOwner()                           -- @account of house owner (nil = your own)
GetCollectibleIdForHouse(houseId)                -- collectible linked to house
GetCollectibleName(collectibleId)                -- official ESO house name
GetCollectibleUnlockStateById(collectibleId)     -- COLLECTIBLE_UNLOCK_STATE_UNLOCKED_OWNED
GetHouseZoneId(houseId)                          -- house's own sub-zone id
GetParentZoneId(zoneId)                          -- geographic parent zone id
GetZoneNameById(zoneId)                          -- zone name string
JumpToSpecificHouse(ownerAccount, houseId)       -- teleport to a friend's house
RequestJumpToHouse(houseId)                      -- teleport to YOUR OWN house only
CanJumpToHouseFromCurrentLocation()              -- guard before teleporting
GetNumFriends() / GetFriendInfo(i)               -- enumerate friends list
ZO_ComboBox_ObjectFromContainer(ctrl)            -- get combo object from a control reference
```

> **Critical:** `RequestJumpToHouse` only works for houses you own. For any friend's house always use `JumpToSpecificHouse(owner, houseId)`. Passing an owner argument to `RequestJumpToHouse` throws a type-check error.

---

### Getting the geographic zone for a house

`GetHouseZoneId` returns the house's own sub-zone (e.g., `"Grand Psijic Villa"`), not the geographic region. Always walk up to the parent:

```lua
local function getHouseZone(houseId)
    local zoneId = GetHouseZoneId(houseId)
    if zoneId and zoneId > 0 then
        local parentId = GetParentZoneId(zoneId)
        return GetZoneNameById((parentId and parentId > 0) and parentId or zoneId)
    end
    return nil
end
```

---

### XML anchor patterns

**Label left-of-editbox** (RIGHT→LEFT trick — auto vertically centers the label):
```xml
<Label name="$(parent)MyLabel">
    <Anchor point="RIGHT" relativePoint="LEFT" relativeTo="$(parent)MyEditBg" offsetX="-4" offsetY="0"/>
</Label>
```

**Invisible reference control** (used to Y-center Lua-created combo boxes in a bar):
```xml
<Backdrop name="$(parent)FHRefBg" centerColor="00000000" edgeColor="00000000">
    <Anchor point="BOTTOMLEFT" relativePoint="BOTTOMLEFT" relativeTo="$(parent)" offsetX="0" offsetY="-76"/>
    <Dimensions x="1" y="28"/>
</Backdrop>
```
Then in Lua:
```lua
comboCtrl:SetAnchor(LEFT, CharacterHomesDialogFHRefBg, LEFT, 78, 0)
```

---

### Dynamic rows (scroll list)

Rows are created in `addRow()` and parented to `contentWrap` inside the scroll child. To clear all rows without crashing:

```lua
contentWrap:SetParent(getTrashBin())  -- do NOT call :Destroy() — unreliable in ESO
contentWrap = nil
```

`zo_callLater(populateDialog, 0)` is used to defer rebuilds to the next frame so the UI is consistent.

---

### Forward declarations

Lua closures capture by reference at definition time. Any function called by another function defined earlier in the file must be forward-declared at the top:

```lua
local populateDialog   -- forward declare
local refreshIfOpen
local getOwnedHouses

-- ... later in the file ...
populateDialog = function()  -- NOT: local function populateDialog()
    ...
end
```

`getHouseZone` must be defined **before** `currentHouseInfo` — it is used as an upvalue and is not forward-declared.

---

### Tooltips

All interactive buttons use the `addTooltip` helper:

```lua
local function addTooltip(ctrl, text)
    ctrl:SetHandler("OnMouseEnter", function(self)
        InitializeTooltip(InformationTooltip, self, BOTTOM, 0, -4)
        InformationTooltip:AddLine(text, "ZoFontGame", 1, 1, 1)
    end)
    ctrl:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
    end)
end

addTooltip(myButton, "Description of what this does")
-- color codes work: "First line\n|c888888Muted hint|r"
```

---

### SavedVars versioning

Current version: **2**. Version is set in:

```lua
ZO_SavedVars:NewAccountWide("CharacterHomesSavedVars", 2, nil, defaults)
```

If the data structure changes in a breaking way, increment the version number and add a migration branch in `onAddonLoaded`. The migration function (`migrateTable`) runs on every load to recompute zones and re-key any legacy entries to official house names.

---

### House enumeration and caches

`ownedHouseCache` and `allHouseCache` are module-level locals populated once per session by scanning house IDs 1–1000. There is no ESO API to enumerate all houses directly. If a player purchases a new house mid-session the cache will not reflect it until `/reloadui`. This is intentional.

---

### Known slash command conflicts

When adding new slash commands, check against EHT, BeamMeUp, and Port to Friend's House first.

---

### Debugging

Set `CH_DEBUG = true` at the top of `CharacterHomes.lua` to enable verbose output from slash commands. Output goes to the ESO chat window via `d()`.

---

## Feedback and Contributions

Bug reports and suggestions welcome via GitHub Issues.
