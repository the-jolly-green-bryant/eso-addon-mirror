# PB's NamePlateChanger

Adjusts the font of the names above characters' heads in The Elder Scrolls Online on console.

- **Author:** PinkBanther
- **Version:** 1.1.0
- **Requires:** `LibHarvensAddonSettings` >= 20106

## What it does — and what it cannot do

The game engine draws the overhead nametag. Nothing in the client's own Lua builds or lays
out that text, so **the order of the title, character name and `<guild>` lines cannot be
changed by an add-on** — they cannot be split onto separate lines or re-centred either. The
full evidence is in [FINDINGS.md](FINDINGS.md).

What the game does expose is the nameplate font, and that works:

| | |
| --- | --- |
| **Text size** | 10–72. The font API has no size parameter, so the size rides inside the face string as an ESO font descriptor (`face\|size`). Measured working on PS5. |
| **Typeface** | The game's own faces, offered as aliases (`$(GAMEPAD_MEDIUM_FONT)` and friends) rather than resolved paths, so the client keeps picking a face that can draw the current language. On the Japanese client those aliases carry the CJK backup fonts; a raw Latin path would leave Japanese names unrenderable. |
| **Outline** | The `FONT_STYLE_*` values the client actually defines, read from the client rather than hardcoded. |

### Typefaces

Every face the client defines is offered, as an alias. What each resolves to depends on the
language — and in Japanese several of them collapse onto the same file, which is why the
list is not de-duplicated for one client:

Only the faces the console UI **already has loaded** are offered. Any other has to be built
when it is set, and that build is billed to the shared pool — measured on PS5, it crashes the
add-on.

| Setting | Alias | Western | Japanese |
| --- | --- | --- | --- |
| Console (medium) | `$(GAMEPAD_MEDIUM_FONT)` | FTN57 | FTN57 for Latin; Japanese falls back to the gothic |
| Console (bold) | `$(GAMEPAD_BOLD_FONT)` | FTN87 | FTN87 for Latin; Japanese falls back to the gothic |
| Console (light) | `$(GAMEPAD_LIGHT_FONT)` | FTN47 | ESO_FWNTLGUDC70-DB |
| Interface (medium) | `$(MEDIUM_FONT)` | Univers57 | ESO_FWNTLGUDC70-DB |
| Interface (bold) | `$(BOLD_FONT)` | Univers67 | ESO_FWNTLGUDC70-DB |

**Retired**, because they were measured to crash on PS5: `$(CHAT_FONT)`,
`$(ANTIQUE_FONT)`, `$(HANDWRITTEN_FONT)`, `$(STONE_TABLET_FONT)`. On a Japanese client the
last three are all `ESO_KafuPenji-M`, a brush face the UI never draws with, and the chat face
is not used by the gamepad UI either — so each of them means building a whole CJK face.

A saved setting pointing at a retired face is dropped back to Default on load, with a line in
chat: the list of offered faces is the authority, so removing one is always enough to stop it
being used.

**The text itself cannot be changed at all.** The one candidate was overriding
`SI_NAMEPLATE_SECOND_LINE_FORMAT`, the `<guild>` line's format string. Measured: the override
changes what `GetString` returns and nothing on screen — the engine formats that line from
its own string table, not the Lua one.

**Colour cannot be changed either.** Nameplate colours exist as
`INTERFACE_COLOR_TYPE_NAME_PLATE` and are decided by the engine per unit type, but the API
has only `GetInterfaceColor` — there is no `SetInterfaceColor` anywhere.

Whether the title line and the `<guild>` line appear at all is the game's own setting
(**Settings > Nameplates**, "Show Title" / "Show Guild"). `SetSetting` is private, so an
add-on can read those but never change them. The settings panel says so and points at them.

## Settings

Under **PB's NamePlateChanger** (LibHarvensAddonSettings).

| Setting | Purpose |
| --- | --- |
| Custom nametag font | Master on/off. Off hands the game's own font straight back. |
| Text size | Size of the text above characters' heads. |
| Typeface | Which of the game's faces to use. Default keeps the game's own. |
| Outline | How the text is separated from the scenery behind it. |
| Reset | Everything back to defaults. |

## Commands

| Command | Purpose |
| --- | --- |
| `/pbfont` | List the commands. |
| `/pbfont status` | Current font, current settings, and the game's own nameplate settings. |
| `/pbfont size <n>` | Set the size without opening the panel. |
| `/pbfont on` / `/pbfont off` | Apply or drop the custom font. |
| `/pbfont safe` | Keep the size, put the typeface and outline back to the game's own — the configuration that costs the client no font building. |
| `/pbfont reset` | Back to defaults. |

### Names

| Where | Comes from | Now |
| --- | --- | --- |
| Add-on browser / search on console | **the Bethesda.net uploader entry**, not the code | must be edited there |
| In-game add-on list | `## Title` in the manifest | `PB's NamePlateChanger` |
| Settings panel heading | `DISPLAY_NAME` in `Main.lua` + manifest version | `PB's NamePlateChanger` |

The add-on was called **PB's NameTag Optimizer**, then **PB's NamePlateFontChanger**, during
development. `/pbtag` still works as an alias for `/pbfont`.

Both previous saved-variable tables are still declared in the manifest and migrated on first
load, newest first. That is not about keeping the settings — it is about the **captured
original font**. Starting fresh under a new name captures whatever font is applied at that
moment, which for an existing user is a custom one, and records it as the value to go back to;
"reset" then never reaches stock again. That is not hypothetical: it happened on the first
rename. `HealOriginals()` and `/pbfont stock` are the backstop.

### Settings values are never `nil`

"Keep the client's own outline" is stored as a sentinel (`-1`), not as `nil`. A `nil` cannot be
told apart from "not set", cannot live in the defaults table, and reads back out of a dropdown
as *no selection* — which a combo box renders as its first item. The outline setting used
`nil` during development and was the only setting that appeared to forget its value; the
typeface setting expresses the same idea as `""` and never did.

## Safety

The nameplate font is a *client* setting, so a value written to it can outlive both the
session and the add-on. The untouched original is therefore captured **before the first
write** and stored account-wide, which means "off", "reset" and a later session can always
put the game back exactly as it was.

The font is applied on every `EVENT_PLAYER_ACTIVATED`, which means after every zone load.
That is not optional: the client does **not** carry this setting across a loading screen, so
without it the nameplate goes back to stock every time you change zone. (Applying once per
session was tried during development and that is exactly what happened.)

Three guards, in order:

1. Only the font for the mode actually in use is written — on console the keyboard font is
   never touched.
2. A write is skipped when the value already matches. This only holds if the client hands
   back the string it was given; whether it normalises the descriptor is **recorded, not
   assumed** (`/pbfont status`, the `diag:` lines).
3. A write budget — 10 writes per 60 seconds — that lives in saved variables rather than in
   the session, because a reload resets the session but flushes saved variables to disk. It
   is the only counter that can see a loop that spans reloads. Sized to allow one write per
   zone change during fast travel while still catching a loop. When it trips, the add-on says
   so in chat and stops writing.

### Outlines are expensive on a CJK client

The game's own font definitions carry this comment, in both the Japanese and the western file:

> Split out from GAMEPAD_MEDIUM_FONT so we don't have to generate outlines for large CJK
> fonts. This currently saves about 100 MB of memory […]

Console add-ons share a **100 MB** pool, and work that happens underneath an add-on's Lua
frame is billed to that pool. Asking for an outline style on a Japanese client is asking for
exactly the thing ZOS split a separate Latin-only face out to avoid. If the game becomes
unstable, leave **Outline** on *Default* and change only size and typeface.

`/pbfont status` resolves the style number to its `FONT_STYLE_*` name, so you can see whether
the selected style is an outline one.

### What each setting costs

| Setting | Cost | Why |
| --- | --- | --- |
| **Text size** | about nothing | ESO's fonts are `.slug` — GPU vector text, resolution independent, so there is no per-size atlas to build. Size changes have never reloaded the UI or destabilised anything. |
| **Typeface** | high | A face the client has not loaded has to be built. That is what the UI reload on a face change is. |
| **Outline** | very high on a CJK client | ZOS put it at about 100 MB themselves. |

The font is re-applied **one second after** a zone load rather than immediately. The delay was
five seconds back when every apply wrote a face and that build was killing the add-on — right
after a loading screen every add-on is re-initialising at once and the shared pool is at its
peak. Since the split above, only the first apply of a session writes a face, so the delay has
little left to protect and a short one keeps the text size from visibly lagging the loading
screen.

`/pbfont safe` is the configuration that asks the client to build nothing.

### Two kinds of apply

Measured on PS5: with `/pbfont safe` the add-on survives repeated zone changes indefinitely;
with a custom typeface re-applied after every loading screen it dies within a few. So the
apply is split by what it costs:

| | What is written | When |
| --- | --- | --- |
| full | size + typeface + outline | once per session |
| cheap | size only, on the client's own face and outline | every zone change after that |

The client drops the nameplate font at every loading screen, so **your text size survives**
because writing it back is free. Your **typeface lasts until the next loading screen**, then
the client's own face comes back with your size still applied. That keeps the font building
to once per session, which is survivable.

"Keep typeface after loading screens" turns that off and re-applies everything every time —
the behaviour that was measured to kill the add-on on console. Off by default.

**The stable core of this add-on is the text size.**

## Do not call private functions to test them

`SetSetting` is private, and `pcall` does **not** protect against calling it: the client
raises `Attempt to access a private function ... from insecure code`, puts up a UI error and
kills the running chunk. The first probe build died halfway through for exactly that reason. There
is no safe way to probe a suspected-private function — decide from the documentation and the
source instead.

## Layout rules that matter on console

- Folder name, manifest filename and `addon.name` must all match exactly (`PBsNamePlateChanger`).
- PlayStation is case-sensitive.
- Console builds are distributed through **Bethesda.net**, not ESOUI — use the ZOS Console
  AddOn Uploader. The name shown in the in-game browser comes from the uploader entry, not
  from `## Title`.

## Releasing

The displayed name is fixed in `Main.lua`; the version comes from the manifest. To cut a new
version, edit these two adjacent lines in `PBsNamePlateChanger.addon` and nothing else:

```
## Title: PB's NamePlateChanger 1.1.0
## Version: 1.1.0
```

---

This Add-On is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its
affiliates. The Elder Scrolls® and related logos are registered trademarks or trademarks of
ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.
