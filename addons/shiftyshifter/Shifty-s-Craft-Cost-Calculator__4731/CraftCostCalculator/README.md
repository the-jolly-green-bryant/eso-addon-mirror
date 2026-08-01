# Shifty's Craft Cost Calculator

ESO addon that calculates the **crafting material requirements** and **TTC market cost** for weapons, armor, jewelry, and **Master Writs**.

Depends on **Tamriel Trade Centre** for prices. Does **not** modify TTC.

Saved settings and shopping lists are **per server** (`GetWorldName()`), so NA / EU / PTS data do not overwrite each other.

## Usage

1. Install into `Documents/Elder Scrolls Online/live/AddOns/CraftCostCalculator`
2. Ensure Tamriel Trade Centre is installed and its Client has generated price tables
3. In-game:
   - `/ccc <item link>` — calculate cost (gear or Master Writ)
   - `/craftcost <item link>` — same
   - `/ccc last` — recalculate last item
   - `/ccc window` — toggle results window
   - `/ccc upgrade` — toggle upgrade cost window
   - `/ccc calculatebuild` — open Build Cost Calculator (paste CCC1 export from the web app)
   - `/ccc shoppinglist` — open shopping list
   - Right-click inventory gear → **Calculate Craft Cost**
   - Right-click a Master Writ → **Calculate Master Writ Cost**
   - On the results window → **Calculate Upgrade Cost** (gear only)

## Example

CP160 Gold Nirnhoned Greatsword →

| Material | Qty |
|----------|-----|
| Rubedite Ingot | 140 |
| Style material (e.g. Molybdenum) | 1 |
| Potent Nirncrux | 1 |
| Improvement boosters (Honing Stone → Tempering Alloy) | per expertise |

Each line is priced via `TamrielTradeCentrePrice:GetPriceInfo`, then summed.

### Master Writ example

A sealed Blacksmithing Master Writ (Epic Training Mace, set + style) →

- Reads Writ1–Writ6 from the item link (item type, quality, set, trait, style)
- Uses **CP150** quantities (cheapest Rubedite-tier craft that still completes the writ; CP160 costs 10× base mats)
- Shows Need / Own / Miss, unit price, subtotals
- Totals: full craft cost + cost of missing materials only
- Compares craft cost to the **writ’s** TTC market price

## Architecture

| Module | Role |
|--------|------|
| `WritResolver` | Master Writ link → craftInfo (gear + provisioning writs) |
| `CraftResolver` | Finished gear link → craftInfo (dispatches writs to WritResolver) |
| `GlyphData` / `GlyphResolver` | Enchantment → potency/essence/aspect runes (isolated static maps; LLC soft-use) |
| `MaterialResolver` | Craft params → material list + quantities (smithing mats, glyphs, or provisioning ingredients) |
| `OwnedMaterials` | Counts owned mats (bag / bank / craft bag); event-driven |
| `KnowledgeChecker` | Motif / trait / recipe / blueprint known? (modular) |
| `CraftData` | Compact formulas / tier item IDs (not a recipe DB) |
| `TTCIntegration` | Calls TTC public price API |
| `PriceProvider` | Picks Suggested / Avg / SaleAvg / Min |
| `CalculationEngine` | Cost = unit price × max(0, required − owned) |
| `UpgradeCostCalculator` | Improvement-only path from current quality → Legendary |
| `BuildExport` | Decode / validate CCC1 build export strings |
| `BuildPieceResolver` | Export gear piece → craftInfo (no item link required) |
| `BuildCostCalculator` | Orchestrates per-piece costs via existing services |
| `BuildCostUI` | Build Cost Calculator window |
| `UpgradeCostUI` | Dedicated upgrade-step window + quality selector |
| `UI` / `Settings` | Window, chat, context menu, LAM panel |

### Upgrade Cost Calculator

- Opens from the craft results window via **Calculate Upgrade Cost**
- Shows each remaining improvement step (e.g. Blue → Purple, Purple → Gold)
- Current quality is selectable (White / Green / Blue / Purple); completed stages are skipped
- Reuses improvement material resolution, owned-material counts, and TTC pricing
- Supports Blacksmithing, Clothing, Woodworking, and Jewelry Crafting

### Owned materials

- Sources: backpack, bank, subscriber bank, craft bag (`BAG_VIRTUAL` when available)
- UI columns: **Need / Own / Miss**
- Total prices only **Miss**; fully owned lines cost **0g**
- Refreshes on inventory/craft/bank events (debounced) — no polling
- Toggle in Settings: **Subtract owned materials**

## Dynamic vs static (important)

### Resolved dynamically (preferred)

- Master Writ requirements from item-link fields (Writ1–Writ6) + `GenerateMasterWritBaseText`
- Provisioning writ ingredients from recipe APIs (`GetRecipeInfoFromItemId` / recipe-list scan, `GetRecipeIngredientItemLink`, `GetItemLinkRecipeIngredientItemLink` for unknown recipes via Recipe item)
- Level / CP from `GetItemLinkRequiredLevel` / `GetItemLinkRequiredChampionPoints` (finished gear)
- Style → style material via `GetItemStyleMaterialLink`
- Trait → trait material via `GetSmithingTraitItemLink`
- Improvement mats via `GetSmithingImprovementItemLink`
- Station / pattern from weapon type, armor weight, equip slot (gear) or Writ1 map (writs)
- Set / style / trait **names** via `GetItemSetName` / `GetItemStyleName` / `SI_ITEMTRAITTYPE*`
- Prices from TTC

### Why a small static table still exists

`GetSmithingPatternMaterialItemInfo` / `GetSmithingPatternInfo` only return valid data **while interacting with a crafting station**. They cannot be used as a general off-station recipe API.

Therefore material **quantities** and refined **tier item IDs** use the same compact formulas employed by LibLazyCrafting / the game’s own curves:

- ~40 refined material item IDs (ingot/cloth/leather/wood/jewelry tiers)
- Pattern quantity curve + a few documented exceptions
- Improvement booster counts by expertise rank
- Master Writ **Writ1 → pattern** map (writ codes do not match `WEAPONTYPE_*` / `EQUIP_TYPE_*`)

This is **not** a hardcoded database of every craftable item. One formula covers all levels and patterns.

### Master Writ support

| Profession | Status |
|------------|--------|
| Blacksmithing | Supported (cost + knowledge) |
| Clothing (light + medium) | Supported (cost + knowledge) |
| Woodworking | Supported (cost + knowledge) |
| Jewelry Crafting | Supported (cost + knowledge; no motif) |
| Alchemy | Not supported — reagents/solvents need an effect→reagent database not present in CCC |
| Enchanting | Not supported — glyph rune combos are not encoded as material lists in the writ link |
| Provisioning | Supported — ingredients from game recipe APIs (`GetRecipeInfo` / `GetRecipeIngredient*` / `GetItemLinkRecipe*`); knowledge check included. Falls back to knowledge-only with a warning if ingredients cannot be read (e.g. unknown recipe without LibCharacterKnowledge) |
| Holiday writs without Writ1–Writ6 | Not supported — no requirement fields to read |

### Writ knowledge checks

For Master Writs, CCC reports whether the **current character** can complete the writ:

| Requirement | Source |
|-------------|--------|
| Motif / style chapter | LibCharacterKnowledge when installed; else `IsSmithingStyleKnown` |
| Trait research | `GetSmithingResearchLineTraitInfo` |
| Provisioning recipe | LCK recipe map / native recipe lists |
| Furnishing blueprint | LCK plan knowledge (when craftInfo provides a plan id) |

UI shows a **Requirements** section with ✅ Known / ❌ Unknown per requirement, plus an overall **Ready to Craft** or **Missing Knowledge** status. Missing motifs/recipes can show a TTC estimate and be added to the shopping list (those prices are **not** included in the craft total).

### Not in v1 for finished gear (extensible later)

- Set vs non-set does not change material counts for creation (only which station can craft the set)

## Settings

Settings → Shifty's Craft Cost Calculator:

- Price mode (Suggested / Avg / SaleAvg / Min)
- Assume max improvement expertise (default on)
- Print to chat / show window / context menu
- Highlight missing TTC prices
- Check writ knowledge (default on)
- Include glyph costs (default on) — adds potency/essence/aspect runes for enchanted gear

## Optional libraries

- **LibCustomMenu** — cleaner inventory context menu (falls back to a hook if absent)
- **LibLazyCrafting** — optional; used softly for smithing compile and glyph rune helpers when present; local resolvers remain primary
- **LibCharacterKnowledge** — recommended for accurate motif/recipe knowledge and purchasable motif chapter / recipe item links

## Public API

```lua
local result, err = CraftCostCalculator:CalculateCraftCost(itemLink)
-- result.lines[i] = { name, quantity, unitPrice, subtotal, missing, itemLink, category }
-- result.total, result.complete, result.craftInfo, result.resultMarketPrice
-- result.craftInfo.isMasterWrit, .setName, .vouchers, … when input is a Master Writ
-- result.knowledge = { ready, requirements[], missing[], missingReasons[] } for Master Writs
```
