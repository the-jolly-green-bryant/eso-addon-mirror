# Tetsu's Daily Writ Precrafter

Addon mostly for heavy crafters.

Two ways to use it:

1. **Together with Dolgubon's Lazy Writ Creator** (default)  
   Lazy Writ Creator does today's writ, accept, turn-in and reward boxes.  
   This addon only **pre-crafts future days** (R3), starting **tomorrow**.

2. **Stand-alone**  
   Turn OFF “Work together with Lazy Writ Creator” and disable Lazy Writ Creator itself (the UI reloads).  
   Then this addon can do today's writ and the extras (accept / turn-in / boxes).

Do not leave **both** addons on full auto. Changing the mode reloads the UI. Disable Lazy Writ Creator before switching to stand-alone.

---

## Modes

**With Lazy Writ Creator (default)**  
Open a station and press **R3**. Stock is crafted from **tomorrow** for the number of days on the slider (1 = tomorrow only, 3 = tomorrow + 2 more days).  
Today's writ is left to Lazy Writ Creator.

**Stand-alone, pre-craft OFF**  
The addon crafts **only** what the active daily writ asks for.  
No writ at that station → it does nothing.

**Stand-alone, pre-craft ON**  
R3 crafts **today + N days** (slider 1–10 → today + 1 to 10 extra days) using the official A/B/C rotation.  
You do not need to have taken the writ first.

The same day count applies to **all** stations: blacksmithing, clothing, woodworking, jewelry, enchanting, alchemy, and provisioning.

Alchemy Chemistry and Provisioning Chef/Brewer extras are counted: one craft can produce 2–4 items, so the addon does fewer clicks and still covers the days you chose.

---

## Features

- R3 keybind on every writ station
- Works from the station menu
- Per-character days slider
- Optional auto-accept / auto-turn-in / auto-open reward boxes (stand-alone only)
- Full material check and bag-space check before crafting; chat lists name, needed, have, missing
- Unknown provisioning recipes are skipped with a message (no substitute food)
- Repeated items in a batch are multi-crafted in one call
- Jewelry uses the correct ounces per rank (pewter through platinum CP150; not the CP160 10× row)
- Localized UI: English, Russian, German, Spanish, French, Japanese, Chinese
- No slash commands required
- Settings → **Info** for a short how-to

---

## How to use

**A. With Lazy Writ Creator**
1. Keep Lazy Writ Creator enabled.
2. Leave “Work together with Lazy Writ Creator” ON (default).
3. Set days ahead (1 = tomorrow only).
4. Open a station → **R3** to stock future days.
5. Let Lazy Writ Creator handle today's writ and turn-in.

**B. Stand-alone**
1. Disable Lazy Writ Creator.
2. Turn OFF “Work together…” (UI reloads).
3. Leave pre-craft off to only finish today's writ, or enable it and set days (1 = today + tomorrow).
4. Open a station → use it / press **R3**.

Equipment and glyphs must be made by the character who turns the writ in. That is why every character crafts for themselves.

---

## Requirements

- LibHarvensAddonSettings

---

## Notes

- If you only want **one day** of auto-craft and no future stock, you can keep using Dolgubon's Lazy Writ Creator **instead of** this addon.
- Potions and food can still be shared by hand; the addon does not touch the bank.
- If this addon helped you, a little in-game gold by mail to **@Tetsurion** is appreciated. Same mail for bugs and ideas.

---

## 2.5.2

Scribing (`CRAFTING_TYPE_SCRIBING`) is ignored: no R3, no “rotation phase unknown”. Enchanting glyphs are unchanged. 2.5.1 tab-filter revert.

## 2.5.0

Alchemy and enchanting daily writs now follow the real rank tables (UESP / Lazy Writ):

- Alchemy solvents use official item IDs. Writ rank 2 is Pristine Water (Dram), not Clear Water / Yeast. Ranks 6 and 7 both use Cloud Mist (Panacea). Distillate / Star Dew is never requested.
- Solvent Proficiency 8 crafts Essence on Lorkhan’s Tears **and** Poison IX on Alkahest (Drain / Damage). Quest mode matches the journal with potion *and* poison results.
- Alchemy rotation is 4 days (8 products at rank 8). Taking today’s writ once lets pre-craft follow your cycle; without a learned phase it stocks every product that exists at your rank.
- Enchanting rank 10 daily writs use **Rejera** (Superb CP150), not Repora (CP160).
