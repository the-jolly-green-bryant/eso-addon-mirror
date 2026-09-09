# PB's CraftMaterialAssistant

Shows what a batch of something costs in materials, what you are carrying, and what you are
short — in a window of its own — for **The Elder Scrolls Online on console** (PS5 / Xbox
Series X|S).

- **Author:** PinkBanther
- **Version:** 1.2.0
- **Requires:** nothing. `LibHarvensAddonSettings` >= 20106 is optional and adds the settings
  panel; without it everything is reachable from `/pbcraft`.

## What it does

Pick something you know how to make, say how many times you want to make it, and the window
lists every ingredient, how many you hold and how many are missing:

```
Fish Stew  x3   (12 made)
Short of 1     enough for 2

Material            Need   Have  Short
Fish                   6      4      2
Garlic                 3     40      -
```

The held column counts your backpack, your bank and your craft bag by default, and updates
itself as items come and go — loot a stack of flour and the shortfall column drops while you
are standing there.

## What "craftable item" means here

**Recipes**: everything in the client's recipe lists. Food, drink, and every furnishing plan,
blueprint, design, diagram, pattern, praxis, formula and sketch — they are all the same system
and all have an exact ingredient list.

**Not** smithing, alchemy or enchanting. A smithed item is a pattern crossed with a material,
a material quantity that *is* the item level, a style and a trait; alchemy and enchanting are
combinations rather than entries. None of them is a list you pick one row out of, so they need
a picker of their own. `Recipes.lua` is the only file that knows where a requirement came from,
so adding one later disturbs nothing else.

## Choosing something, on a controller

There are thousands of recipes, so the list has to be narrowed — and narrowing it means text,
which is the one thing a controller is worst at. So the add-on never asks the settings library
to draw a list that changes. **The candidates are drawn in the add-on's own window**, and the
panel only moves a marker around in it:

1. Narrow with **Category** (the client's own recipe categories), or search by name with
   `/pbcraft find <text>`.
2. The window switches to the candidate list. **Page** and **Candidate** are sliders; the
   marker moves in the window as you move them.
3. **Take** makes the marked candidate the thing being counted, and the material table comes
   back.

Every label in the panel is a fixed string. That is what makes the above safe: the library
builds its rows once, and a row whose text has to change afterwards is a row this add-on does
not ask for. If this copy of the library turns out to have a text field, a **Search** row is
added as well — but nothing depends on it.

## Settings

Under **PB's CraftMaterialAssistant** (LibHarvensAddonSettings).

| Setting | Purpose |
| --- | --- |
| **Show the window** | Master switch, first row and outside every section: the window is meant to be put up while a batch is planned and taken down again, so it never needs scrolling to. Off, the window goes away and the add-on stops listening to your bags entirely |
| Show the candidate list | Turns the window into the picker |
| Category | The client's own recipe categories; "All" is the default |
| Search | Only if this copy of the library has a text field |
| Search again | Re-runs the current search — worth pressing after learning recipes |
| Only what I have learned | Off also shows unlearned recipes, marked `*` |
| Page / Candidate | Which page, and which row the marker is on |
| Take the marked candidate | Confirms the pick |
| Nothing picked | Forgets the pick |
| Times to make it | 1–200. The number of **crafts**, not of items |
| Count what is in | Backpack / + bank / + craft bag / + house banks |
| Width / Height | Window size |
| Corner, Offset across / down | Where it sits |
| Text size, Typeface, Outline | How it reads |
| Background | Opacity of the panel behind the text; 0 is text only |
| Draw order | In front / normal / behind |
| Back to defaults | Everything on the panel, and the pick |

## Commands

```
/pbcraft                       what is picked, and what it is short of
/pbcraft find <text>           search names; the candidates appear in the window
/pbcraft pick <number>         take one of the candidates on this page
/pbcraft next | prev | page n  move through the candidates
/pbcraft qty <n>               how many times to make it
/pbcraft list                  the categories, with their numbers
/pbcraft cat <n>               narrow to one category, 0 for all
/pbcraft known on | off        only recipes this character has learned
/pbcraft scope backpack | bank | craftbag | all
/pbcraft browse [on | off]     the candidate list in the window
/pbcraft clear                 pick nothing
/pbcraft on | off              master switch
/pbcraft probe                 count the catalogue once and say how long it took
/pbcraft reset                 every setting back to default
```

`/pbcm` is the same command.

## Things worth knowing

**Nothing is written to chat unless you ask for it.** No login banner, nothing when a setting
is changed, nothing when the table updates. The add-on has a display surface of its own, and
the chat window is somebody's conversation. The only lines it produces are answers to a
`/pbcraft` command you typed — and the material table never goes to chat at all.

**"Times to make it" is crafts, not items.** A recipe that yields four drinks, made three
times, is three sets of ingredients and twelve drinks. The window says what the yield works
out at, in brackets after the name.

**House banks are off by default.** They are real storage, but not storage you can reach from
a crafting station, so counting them by default would answer the wrong question.

**A count the client will not give is drawn as `?`, never as `0`.** A zero is a claim.

**A pick survives a patch.** A recipe is addressed by two indices and indices move when a
chapter inserts new plans above them. The name and the result item id are stored beside the
indices, and at every login the three are reconciled: same recipe, nothing to do; a different
one, and the catalogue is searched once for the result item id and the indices rewritten. Only
when that fails too does the window say the pick is gone — it never quietly draws somebody
else's ingredients under the name you chose.

**Nothing is cached between searches.** A search is a full pass over the client's own data.
That is deliberate: a copy of the catalogue in add-on memory is a copy in the 100 MB pool every
add-on on a console shares. `/pbcraft probe` says what one pass actually costs on your machine.

**The window has no mouse.** It cannot be clicked, dragged or focused, so it can never take a
click away from the game underneath it. Position and size are settings for the same reason.

## Tests

```bash
lua test/run.lua
```

`test/harness.lua` stubs the part of the client the add-on touches — the recipe functions,
`GetItemLinkStacks`, a label that records the text put in it, saved variables and
LibHarvensAddonSettings — with a small catalogue of its own, including a longer-than-one-page
category and an ingredient the client refuses to count. Every check there is a PS5 session not
spent finding out the same thing.

## Releasing

The displayed name is fixed in `Main.lua`; the version comes from the manifest. To cut a new
version, edit these two adjacent lines in `PBsCraftMaterialAssistant.addon` and nothing else:

```
## Title: PB's CraftMaterialAssistant 1.2.0
## Version: 1.2.0
```

Console builds are distributed through **Bethesda.net**, not ESOUI — use the ZOS Console AddOn
Uploader. The name shown in the in-game browser comes from the uploader entry, not from
`## Title`.

## Layout rules that matter on console

- Folder name, manifest filename and `addon.name` must all match exactly
  (`PBsCraftMaterialAssistant`).
- PlayStation is case-sensitive: `PBsCraftmaterialassistant` != `PBsCraftMaterialAssistant`.

---

This Add-On is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its
affiliates. The Elder Scrolls® and related logos are registered trademarks or trademarks of
ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.
