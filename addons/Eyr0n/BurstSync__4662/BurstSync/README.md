# BurstSync

An ESO addon that lines up your burst: you tick your spells, the addon knows each spell's cast→impact delay, works out the order, and tells you **when to press** so everything lands at the same instant.

Built for group burst, where damage syncing makes or breaks the kill.

---

## How it works

Every spell has an **impact delay**: the time between your press and the moment it actually hits. For a burst to be synced, all spells must land together at a common instant **T**.

The addon does the math for you:

1. The ticked spell with the **longest impact** becomes the **trigger**. It sets T.
2. You cast it → the countdown starts.
3. Every other spell is scheduled at **T − its impact**, so they all land together.
4. A shrinking bar shows the timing, coloured by the **next spell to cast**.
5. Golden **BURST** flash at the moment of impact.

You never set any ordering delay: you tick, that's it. (For spells whose impact depends on your build, see "Variant spells".)

### Example (T = 9 s, 1 s GCD guard)

```
BURST at T = 9s (GCD guard applied)
   press 0.0s -> Deep Fissure              (trigger, 9 s variant)
   press 1.0s -> Proximity Detonation
   press 4.0s -> Incinerate                 (5 s variant)
   press 5.0s -> Soul of Flame              (+1 GCD: 4.0+1)
   press 6.0s -> Blast Bones                (slider at 4 s, +1 GCD)
   press 7.0s -> Detonating Attraction
   press 8.0s -> Ulfsild's Contingency
   BURST at 9.0s
```

---

## Installation

1. **Required dependency**: [LibAddonMenu-2.0](https://www.esoui.com/downloads/info7-LibAddonMenu.html) (it powers the whole settings menu).
2. Drop the `BurstSync` folder into:
   `Documents/Elder Scrolls Online/live/AddOns/`
   The folder must contain `BurstSync.txt` and `BurstSync.lua`.
3. Enable the addon in the in-game menu, then `/reloadui`.

Language (EN / FR) auto-detects from your client. Settings are saved **per account** (same settings on all your characters).

---

## Configuration

Everything lives in **Settings → Add-Ons → BurstSync**.

### Display

| Setting | Effect |
|---|---|
| Enabled | Turns the addon on / off |
| Show spell name | Shows the name on the bar |
| BURST marker at impact | Golden "BURST" flash at T |
| Hide bar | Hides the bar but keeps the timer running |
| Lock position | Untick to move the bar, re-tick to freeze |
| Width / Height | Bar size |

### My spells

Spells are grouped into **collapsible submenus by class** (Dragonknight, Sorcerer, Templar, Warden, Necromancer, Arcanist, Scribing, Misc). Expand a class and tick the spells you want in **your** burst — independent of what's on your bar: you decide what counts for the sync.

Under each ticked spell:

- its **impact setting** when it has one (see "Variant spells");
- a **colour picker**: the bar colour when this spell is the next to cast. By default the colour **identifies the class** (see "Colour code"); the **name shown on the bar** tells you which exact spell to press. You can change any colour freely.

### Colour code

By default the bar colour shows the **class** of the next spell; the name written on it says which one. When a class has several spells, each gets a **distinct shade** of the same tone (lighter / darker) so you can tell them apart at a glance while keeping the class-family colour.

| Class | Colour |
|---|---|
| Dragonknight | orange |
| Templar | yellow |
| Arcanist | bright green |
| Warden | dark green |
| Necromancer | violet |
| Sorcerer | blue-purple |
| Nightblade | red *(no built-in spell yet)* |
| Scribing | silver / pale *(off-class)* |
| Misc | cyan *(off-class)* |

### Variant spells

Some spells don't have a fixed impact — it depends on the morph, the build, or a stack count. For those, once the box is ticked, a setting appears:

- **Dropdown** (discrete variants): e.g. Deep Fissure 3 / 9 s, Incinerate 5 / 10 / 15 s, Haunting Curse 3.5 / 12 s, Bound Armaments 0.3 / 0.6 / 0.9 / 1.2 s.
- **Slider** (continuous range): e.g. Blast Bones 2–8 s, Crystal Weapon 1–6 s.

Pick the value that matches your case; the addon uses it to compute the order.

---

## Commands

`/burstsync` (or `/bsync`)

| Command | Action |
|---|---|
| `/burstsync test` | Visual demo (no combat) |
| `/burstsync list` | Show the computed order and timings |
| `/burstsync scan` | Print the `abilityId` and name of each slotted skill |
| `/burstsync unlock` | Unlock the bar to move it |
| `/burstsync lock` | Lock the bar |
| `/burstsync reset` | Re-center the bar |
| `/burstsync on` / `off` | Enable / disable |

---

## In-game use

1. Tick your spells in the settings (set variants if needed).
2. In combat, cast your **trigger spell** (the longest ticked impact): the bar starts on its own.
3. Follow the bar: each time it empties, cast the spell shown.
4. On the BURST flash, everything lands together.

**Re-pressing the trigger restarts the sequence** from zero (handy if you miss the start or want to re-sync). Presses on the other spells aren't listened to: the bar is a visual cue, it doesn't wait for your inputs.

---

## Built-in spells

| Spell | abilityId | Impact | Class | Colour |
|---|---|---|---|---|
| Deep Fissure | 86015 | 3 / 9 s (dropdown) | Warden | dark green |
| Subterranean Assault | 86019 | 3 / 6 s (dropdown) | Warden | dark green |
| Proximity Detonation | 61500 | 8 s | Misc | cyan |
| Inevitable Detonation | 61491 | 4 s | Misc | cyan |
| Power of the Light / Purifying Light | 21763 / 21765 | 6 s | Templar | yellow |
| Fulminating Rune | 182988 | 6 s | Arcanist | bright green |
| Incinerate | 32853 | 5 / 10 / 15 s (dropdown) | Dragonknight | orange |
| Soul of Flame / Heart of Flame | 32792 / 32785 | 4.5 s | Dragonknight | orange |
| Blast Bones | 117960 | 2–8 s (slider) | Necromancer | violet |
| Haunting Curse | 24330 | 3.5 / 12 s (dropdown) | Sorcerer | blue-purple |
| Daedric Prey | 24328 | 6 s | Sorcerer | blue-purple |
| Detonating Attraction | 217979 | 2 s | Scribing | silver |
| Elemental Explosion | 217228 | 2 s | Scribing | silver |
| Bound Armaments | 24165 | 0.3 / 0.6 / 0.9 / 1.2 s (dropdown) | Sorcerer | blue-purple |
| Crystal Weapon | 46331 | 1–6 s (slider) | Sorcerer | blue-purple |
| Mage's / Endless Fury | 19123 / 19109 | 2 s | Sorcerer | blue-purple |
| Ulfsild's Contingency | 222678 | 1 s | Scribing | silver |
| Rune of the Colorless Pool | 183267 | 1 s | Arcanist | bright green |

Impact values are **deliberate choices** (the moment the effect becomes relevant in the rotation), not durations read from the API.

> **Sibling morphs**: some logical spells accept **two morphs** as a trigger, either via the `ids` field (same impact: Power / Purifying Light, Soul of Flame / Heart of Flame, Mage's / Endless Fury), or on a **separate line** when the morphs have different timings (Deep Fissure / Subterranean Assault, Proximity / Inevitable Detonation, Haunting Curse / Daedric Prey).

---

## Getting / adding an abilityId

1. Slot the spell, then in-game: `/burstsync scan` → prints the id and name of each slot.
   (Manual variant: `/script local i=GetSlotBoundId(N,GetActiveHotbarCategory()) d(i) d(GetAbilityName(i))`, `N` = 3 to 8.)
2. Open `BurstSync.lua`, find the spell's line in the `MASTER` table, and set / fix its `id`.

To add a brand-new spell, add a line to `MASTER`:

```lua
-- fixed impact:
{ id = 12345, name = "Spell name", class = "Class", impact = 4, color = { 0.5, 0.5, 0.5 } },

-- variants (dropdown):
{ id = 12345, name = "Spell name", class = "Class", variants = { 3, 9 }, default = 9, color = { 0.5, 0.5, 0.5 } },

-- range (slider):
{ id = 12345, name = "Spell name", class = "Class", slider = { min = 1, max = 6, step = 1 }, default = 3, color = { 0.5, 0.5, 0.5 } },

-- several morphs accepted as trigger (id = settings key, ids = all accepted):
{ id = 12345, name = "Spell name", class = "Class", ids = { 12345, 12346 }, impact = 4, color = { 0.5, 0.5, 0.5 } },
```

Colour is RGB from 0 to 1. To stay consistent, reuse the spell's class colour (see "Colour code"). The `name` is only a fallback: in-game the real name is read via `GetAbilityName`.

---

## Notes and limits

- **APIVersion**: if the addon shows as "out of date", type `/script d(GetAPIVersion())` in-game and put the number in `BurstSync.txt`, or tick "allow out of date addons".

- **Morphs**: every morph of a skill has a different `abilityId`. Two ways to cover multiple morphs of one logical spell: (1) if they share the **same impact**, list them in `ids` on a single line (the `id` field stays the settings key) — e.g. Power / Purifying Light; (2) if they have **different timings**, put them on **separate lines** with their own variants — e.g. Deep Fissure / Subterranean Assault. A morph that isn't covered won't have anything to tick until its id is added.

- **Scribing**: for grimoire skills, only the **Focus** script changes the base id; the Signature and Affix scripts don't touch it. Two players with the same Focus therefore share the same id.

- **GCD guard**: if two ticked spells would fall on the same cue (identical impacts), the addon pushes the second one out by 1 second.

---

## Credits

Author: **Eyr0n**
Development help (ideas, testing): **Tsnek0oni**, **Selegnar**
