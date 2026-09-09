# Findings

What was checked before writing the add-on, and where the answers came from. The source is the
client's own Lua, cloned from `esoui/esoui` (branch `live`) — the same repository that ships
`ESOUIDocumentation.txt`.

Anything marked **from source** is read out of the client's own Lua or its API dump and has not
been contradicted, but has not been seen on a PS5 either. Anything marked **to measure** is a
question this laptop cannot answer. The distinction matters: on console a wrong guess costs a
whole test round.

---

## 1. Recipes are the one craft with an exact, listable requirement

**From source.** `ESOUIDocumentation.txt` (lines ~17285–17325):

```
GetNumRecipeLists()                                   -> numRecipeLists
GetRecipeListInfo(recipeListIndex)                    -> name, numRecipes, ...
GetRecipeInfo(recipeListIndex, recipeIndex)           -> known, name, numIngredients,
                                                         provisionerLevelReq, qualityReq,
                                                         specialIngredientType,
                                                         requiredCraftingStationType,
                                                         resultItemId
GetRecipeIngredientItemInfo(list, recipe, i)          -> name, icon, requiredQuantity, ...
GetRecipeIngredientRequiredQuantity(list, recipe, i)  -> requiredQuantity
GetRecipeIngredientItemLink(list, recipe, i, style)   -> link
GetRecipeResultItemInfo(list, recipe)                 -> name, icon, stack, ...
GetRecipeResultQuantity(list, recipe, numIterations)  -> quantity
```

Four things fall out of that and shape the whole add-on:

- `known` is exactly the question "can this character make it", so the picker's default filter
  is a field the client already maintains rather than anything inferred.
- `resultItemId` is a stable identity for a recipe whose indices are not. See §4.
- `requiredQuantity` is per **craft**, and `GetRecipeResultQuantity` takes an iteration count —
  so "make it three times" and "get twelve drinks" are two different numbers, and the settings
  slider had to pick one and say which. It is crafts.
- Furnishing plans, blueprints, designs, diagrams, patterns, praxes, formulae and sketches are
  all in these same lists, which is what makes the catalogue thousands long and the search
  worth building.

## 2. Smithing is deliberately not here

**From source.** `ESOUIDocumentation.txt` (~17501–17537) and
`esoui/ingame/crafting/smithingcreation_shared.lua:918`:

```lua
local _, _, _, numMaterials = GetSmithingPatternInfo(patternIndex)
local name, icon, stack, ... = GetSmithingPatternMaterialItemInfo(patternIndex, materialIndex)
```

A smithed item is `CraftSmithingItem(patternIndex, materialIndex, materialQuantity, itemStyleId,
traitIndex, useUniversalStyleItem, numIterations)` — five choices before there is an item to
count materials for, and `materialQuantity` *is* the item level. That is not one row picked out
of a list, it is a form; it needs its own picker and its own settings section. Recipes.lua is
the only file that knows where a requirement came from, so it can be added without touching the
window, the panel or the arithmetic.

## 3. One call answers "how many do I have"

**From source.** `ESOUIDocumentation.txt:21838`:

```
GetItemLinkStacks(itemLink) -> stackCountBackpack, stackCountBank, stackCountCraftBag,
                               stackCountHouseBanks, stackCountFurnitureVault,
                               stackCountVengeanceBag
```

Six numbers already in the client, for one link. That is why the add-on never walks the bags:
scanning `BAG_BACKPACK` and `BAG_BANK` slot by slot for eight ingredients every time a single
item moves is work, and this is not.

The scope setting is a sum of a subset of those six. `GetItemLinkInventoryCount` +
`INVENTORY_COUNT_BAG_OPTION_*` (`ESOUIDocumentation.txt:5074`) is the fallback for a client
without the first; it has no house-bank option, so that scope degrades to the craft-bag one.
Degrading a count **downwards** is safe — a list that overstates what you have is not.

Both missing answers `nil`, which is drawn as `?`. A zero would be a claim.

## 4. Recipe indices move; result item ids do not

**From source, and the reason for the reconciliation in `Recipes.lua:ResolveTarget`.** A recipe
is addressed by `(recipeListIndex, recipeIndex)`, and a chapter that inserts furnishing plans
into a list pushes everything below them down. Saved variables outlive the catalogue they were
written against.

So the pick stores the name and `resultItemId` beside the indices, and at every
`EVENT_PLAYER_ACTIVATED`:

| state | what happens |
| --- | --- |
| indices still name the same recipe | nothing, one API call — the common case |
| they name a different one | one scan for the result item id, indices rewritten |
| it is not there at all | left alone; the window says the pick is gone |

The third row is the important one. Drawing somebody else's ingredients under the name you
chose would be worse than saying nothing.

Every call into the recipe API goes through a `pcall` wrapper for the same reason: an index out
of range must read as "not found", never as a Lua error in somebody's chat window. The test
harness makes its stubs `error()` on a bad index precisely to exercise that path.

## 5. Which events are worth listening to

**From source.** `EVENT_INVENTORY_SINGLE_SLOT_UPDATE` (27484), `EVENT_INVENTORY_FULL_UPDATE`
(27479), `EVENT_CRAFT_COMPLETED` (27221), `EVENT_RECIPE_LEARNED` (27676).

Inventory traffic is bursty — looting a container, emptying a bag into the bank and crafting
all fire the single-slot event many times in a row — so each one sets a flag and asks for one
redraw 400 ms later. A hundred events cost one pass over eight ingredients. The test checks
exactly that: twenty events, one queued redraw.

They are registered only while there is something to redraw: switched on, with a pick, and not
in the middle of browsing. An add-on that is not showing you anything should not be listening
to your bags.

## 6. What the picker may not depend on

**Reasoned, and the shape of the whole UI.** `LibHarvensAddonSettings` builds its rows once, at
`AddSetting` time: `items` for a dropdown are handed over then, and the labels are strings, not
functions. Whether a dropdown re-reads a table that is mutated afterwards is not something this
add-on can verify from here — and a picker that silently stops updating is a bad way to find
out.

So the candidates live in the add-on's own window, and every panel row that touches them has a
fixed label and a numeric value: a category dropdown built once from the client's own recipe
lists, a page slider, a candidate slider, and a button. Moving the candidate slider moves a
marker in the window, which makes the sliders a picker rather than number entry.

`ST_EDIT` is added **if** the library defines it, inside a `pcall`, because the shape such a
row wants cannot be checked from here either. `/pbcraft find` is the route that is known to
work on a console — it is the input route every other PB's add-on uses.

## 7. Fonts, and the memory pool

**Measured, in PB's QuestTrackerFontChanger and PB's CyrodiilAlert.** Only faces the console UI
already has loaded are offered. `ANTIQUE_FONT`, `HANDWRITTEN_FONT`, `STONE_TABLET_FONT` and
`CHAT_FONT` were measured crashing a PS5: a face nothing else is drawing with has to be built
on use, and that build comes out of the memory every add-on on the machine shares. Aliases are
stored, never resolved paths, so a Japanese client hands back a face that can draw Japanese
ingredient names.

Style tokens are the four the client's own fontdefs use. They are not the enum names lowercased
— `FONT_STYLE_OUTLINE_THICK` is written `thick-outline` — so anything else would be a guess
about what the engine's parser accepts.

## 8. Four labels, not one, and not forty

**Reasoned.** There is no monospaced face on the console UI, so padding a name out with spaces
lines nothing up: `20` and `300` are different widths in every face the client has loaded.

Each column is one label holding its whole column, rows separated by `\n`. Every label lays its
own lines out in the same font and therefore at the same line height, so row three of "Have"
sits beside row three of "Material" — and each number column is right-aligned inside its own
width, which is what makes a column of numbers readable. A control per cell would be forty
controls to create, anchor and re-lay-out every time a count changed.

`SetMaxLineCount` is the hard bound: too small a window drops the last rows rather than
spilling text over whatever is beside it.

---

# To measure on a PS5

One thing at a time, and what each outcome would prove.

### 1. `/pbcraft probe`

Prints `<lists> lists, <recipes> recipes, <known> of them learned — one full pass took <n> ms`.

- **A number of recipes near zero** — the recipe lists are not populated the way the API dump
  says, and the picker has nothing to show. Everything else is moot.
- **A pass in single-digit or low-tens ms** — the no-cache design is right and nothing needs
  doing.
- **A pass over ~100 ms** — a search is a visible hitch, and the answer is to scan
  incrementally (LibAsync, as PB's MiniMap does) rather than to build an index that would sit
  in the shared memory pool.

### 2. Does the window draw over the settings screen

Open the settings panel with **Show the candidate list** on. The candidates have to be readable
while the panel is open, because that is where the sliders are.

- **Visible** — the design works as intended; nothing to do.
- **Hidden behind the panel** — the picker has to move to the chat command (`find`, `pick`,
  `next`), and the sliders become a convenience rather than the main route.

### 3. Does this client accept the draw order

Change **Draw order**. If `SetDrawLayer` / `SetDrawTier` is refused, the add-on says so in chat
rather than leaving a dropdown that looks as though it did something. Worth knowing which it is:
the API dump's markers have been wrong in both directions before, and `SetSetting` was
private though unmarked.

### 4. Is there a Search row in the panel

It appears only if this copy of `LibHarvensAddonSettings` defines `ST_EDIT`.

- **Present and it takes text** — the search can move into the panel entirely.
- **Absent** — expected; `/pbcraft find` is the route.
- **Present but it cannot be typed into with a controller** — worth knowing, because then it is
  a row that should be removed rather than left as a trap.

### 5. Do the category names read properly

`/pbcraft list` prints the client's own recipe-list names. On a Japanese client they should come
back in Japanese, which is the check that nothing here is resolving names through anything but
the client.
