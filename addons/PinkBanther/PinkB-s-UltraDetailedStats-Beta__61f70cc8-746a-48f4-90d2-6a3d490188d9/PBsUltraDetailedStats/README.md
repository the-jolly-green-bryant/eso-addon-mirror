# PB’s UltraDetailedStats

Puts your character's equipment, detailed statistics, Champion Points and skills on one screen,
in the gamepad UI of **The Elder Scrolls Online** on console (PS5 / Xbox Series X|S).

- **Author:** PinkBanther
- **Version:** 0.3.1 (API 101050)
- **Libraries:** none

Open it from **ステータス超詳細** in the gamepad main menu, between **Character** and **Skills**.
The add-on's name is that menu entry in English: 超詳細ステータス, ultra-detailed stats.

> **The in-game text is Japanese.** The screen, the menu entry and every label are written in
> Japanese only; there is no English locale yet.

## Why this exists

The game already knows all of this — the quality of the ring you are wearing, how many points
sit unspent in Craft, what the second bar's passives are, what your Critical rating actually is.
It just never shows more than a slice of it at once, and on console there is no add-on window
you can leave open next to the one you are reading. Answering "is this set piece better than
that one" means walking between three menus and remembering numbers on the way.

This is those three menus on one screen, kept live while you look at it.

## What it shows

- **Header** — name, race, class, level, Champion Points, title.
- **Equipment** — armour, accessories, front and back bar weapons, poisons, costume. Select a
  piece and it shows quality, required level, trait, enchantment, durability, weapon power or
  armour value, charges, and its set with each bonus tier.
- **Header numbers** — maximum Magicka, Health and Stamina with attribute points and combat
  regeneration, and spell and weapon power, critical, penetration and resistance. Critical is
  the rating followed by the chance it gives in brackets, converted with
  `GetCriticalStrikeChance` as the game's own stats screen does. These are shown only here and
  are not repeated in any list.
- **Build** — what the Armory saves as a build: the twelve slotted Champion Points under their
  constellations, coloured blue, red and green, then the three class skill lines currently
  selected (subclassed ones marked サブ), Class Mastery, the Mundus stone and the curse (vampirism or lycanthropy, named with the game's own `SI_CURSETYPE` string).
- **Statistics** — every detailed statistic category the API exposes, from コアアビリティ on,
  and the effects currently running on you (Mundus, food, and the rest).
- **Champion Points** — twelve slots, spent and unspent points per constellation, and per star
  the points invested, the cap and the description, distinguishing slotted, unslotted, passive
  and inactive.
- **Class Mastery** (in the build) — the Class Mastery passives you have bought, with their ranks, and the
  class mastery points they are bought with. These are a separate currency from skill points,
  and the game reports their skill lines as undiscovered until a class line reaches max rank,
  so they are listed whatever the client says about discovery. Every class in the game has a
  Class Mastery line reporting its own pool of points, and none of them may be added up:
  Class Mastery is selectable only while all of your active class skill lines are your own
  class's, so the block counts nothing at all while you are subclassed.
- **Skills** — six slots on each bar, each icon with the skill's name written under it, plus
  whatever special bar is in use, your active, ultimate and passive abilities, line rank, skill
  rank and unspent points. Scribing skills are listed too.

No list scrolls. A band across the top always shows the character, the three attribute
columns, both skill bars, the combat numbers and the skill and Champion Point totals. Everything
below it belongs to the area you have selected with D-pad left and right — 装備, ビルド,
詳細ステータス, 星座・CPパッシブ, スキル — and holds **all** of that area's entries at once.

The first page is equipment and the build together: the seventeen equipment slots keep the left
of the screen as rows carrying the trait, enchantment and set count, and the build sits beside
them in two columns of large cells — slotted CP in the first, a blank row between constellations,
and Class Mastery, Mundus and curse in the second. The first page uses 20-point type or larger
throughout, since neither list is long. D-pad left and right moves the focus between the two without changing the page. The
detailed statistics, Champion Points and skills each take the whole width: a grid of seven
columns by thirty-two rows, 224 entries, filled column by column.

The description of whatever is selected sits at the foot of the screen, in a window of whole
lines. When it is longer than the window, its title says 説明 1/3 and L2/R2 turns it one window at
a time — never by part of a line.

The one thing that does not fit is 全項目, which adds every unearned Champion Point star and
skill: past what a page holds the area pages, and its title says which range is on screen.

## Controls

| action | PS / Xbox |
| --- | --- |
| choose an area, then an entry | D-pad left/right, up/down |
| next / previous column on screen | L1 / R1 — LB / RB |
| the rest of a long description | L2 / R2 — LT / RT |
| refresh now | the 再取得 button on the screen |
| show unearned CP and skills too | the 取得済み / 全項目 button |
| back to the menu | ○ / B (follows your back-button setting) |

A name that had to be truncated in the grid is spelled out in the description's title.

CP colours follow the constellation. Item name colours are the game's own quality colours
(`GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, quality)`), so Mythic items are
orange as they are everywhere else in the game.

While the screen is open it re-reads everything every 1.5 seconds, and stops when you close it.
The numbers reflect the bar you have drawn and the buffs you have now. It does not estimate the
back bar or simulate hypothetical builds, and CP shows confirmed investment only. "Passive"
describes the kind of star, not whether its condition is currently met — read the effect text
for that. A skill's earned state and its line's active state are shown separately.

## Setup

On PC, put `PBsUltraDetailedStats.addon`, `Data.lua`, `UI.lua` and `PBsUltraDetailedStats.lua` in
`AddOns/PBsUltraDetailedStats/`. The manifest is the same `.addon` format as the other PB add-ons; do
not ship the old `PBsUltraDetailedStats.txt` alongside it, and keep it out of the zip. `/pbuds` opens the
screen on PC, for testing.

**Creating the files locally does not install anything on a console.** Console distribution
goes through Bethesda's developer Uploader — build a candidate with `python3 tools/package.py`,
then follow the console development environment and the Uploader's instructions. Nothing here
has been uploaded or published. See the
[official console Uploader notes](https://help.elderscrollsonline.com/app/answers/detail/a_id/69621/).

## 0.3.1: L1/R1 crosses from equipment into the build

L1/R1 used to jump a column *within* the selected area, and equipment is a single column, so on
the first page it only sent the selection to the first or last slot and never reached the build
beside it. On the first page it now walks the three columns on screen — equipment, then the
build's two columns — and keeps the row, which all three share. A blank separator row lands on
the entry above it. On the grid pages it still jumps one grid column. D-pad left/right still
switches areas.

## 0.3.0: renamed to PB’s UltraDetailedStats

The add-on was PB’s SuperStar, after the original SuperStar it takes its layout from. It is now
**PB’s UltraDetailedStats**, the English for its menu entry, 超詳細ステータス. Everything that
carried the old name changed with it: the folder and manifest (`PBsUltraDetailedStats.addon`), the
global table, the scene, the window's controls, the title on screen
(`PB'S ULTRA DETAILED STATS`), the upload zip, and the PC test command, now `/pbuds`. Nothing was
ever published under the old name, so there is no installed copy or saved data to carry over.
The original SuperStar in `SuperStar/` is still kept, as reference only.

## 0.2.15: the whole item description

- **Why it was still cut off.** 0.2.14 fixed the description label's height to the value it
  measured, on every refresh. A label with a fixed height reports text no taller than itself, so
  a first measurement of one line — taken before the client had laid the text out — capped every
  later one, and the description stayed one window long with nothing for L2/R2 to turn to. The
  labels now keep a height of 0, which sizes a label to its text, and are only measured.
- Every control that is moved after it is created is now cleared first (`ClearAnchors`). A second
  `SetAnchor` adds an anchor rather than replacing the first, and two conflicting anchors distort
  the control. The test harness now fails on any re-anchor without a clear.
- The first page's rows are 30 points instead of 34, which gives its description pane 170 points
  — about eight lines — instead of 96. Under the grid pages it is unchanged.
- An item's description is two columns: the item on the left, its set on the right. The short
  facts share one line, each set apart — `伝説　／　CP 160　／　状態 99%　／　防御 1500　／　中装` —
  and the item name is not repeated, since it is the description's title.

## 0.2.14: set text, L2/R2, Class Mastery title

- **翻訳しない** in an item's description was the game's placeholder string for "no type":
  armour asked for its weapon type and jewellery for its armour type, and `GetString` on the
  `*_NONE` value returns a "do not translate" stub the game itself never displays. Types, trait,
  enchantment, armour and weapon power are now only listed when the item has them.
- The set block reads **セット効果：name（4/5）** like the game's tooltip. Each bonus is the
  game's own text, which already carries its item count — it had been doubled as
  `(2) (2 アイテム) …` — and a bonus not yet reached is dimmed.
- **L2/R2 did nothing.** The description's height was read straight after `SetText`, before the
  client had laid the text out, so every description measured one page long and there was
  nowhere to turn to. It is now measured when L2/R2 is pressed and on every refresh, and the text
  is moved by its own anchor inside the clipping window rather than through the scroll control's
  extents, which depended on that same height.
- Section titles in the build give their value 172 points instead of 92, so
  **取得 2 / 保有 2** is no longer cut to 取得2/….

## 0.2.13: the selected class skill lines

The build's second column now opens with クラススキルライン: the class skill lines currently
selected, each with its rank, and サブ in front of the rank for a line taken from another class.
They sit directly above Class Mastery because Class Mastery depends on them — it is available only
while all of them are your own class's. If a column ever has more entries than rows, its blank
separator rows are dropped before any entry is.

## 0.2.12: larger type in the header band

The band across the top had room to spare, so its type went up: the character line from 21 to
24, the Magicka / Health / Stamina rows from 19 to 23 on 36-point rows with larger icons, the
combat numbers from 18 to 21, the skill and Champion Point totals from 21 to 24, the tab titles
from 20 to 22. The skill bar icons went from 32 to 36 points and their names from 13 to 15. The
band is still the same height, so nothing below it moved.

## 0.2.11: the keybind strip moves out of the way

The game's keybind strip — 戻る, 再取得, 取得済み / 全項目 — sat over the last lines of the
description. While this screen is open the strip now uses a compact copy of its own style: labels
at `ZoFontGamepad27` instead of 34, anchored 30 points lower, with its background 30 points
shorter. `KEYBIND_STRIP:SetStyle` is the strip's own public way to restyle it. The previous style
and background height come back when the screen closes, and the style is only put back if
nothing else has changed it in the meantime.

## 0.2.10: larger type on the first page

The build no longer borrows the 14-point grid cells. It has 34 cells of its own, two columns of
seventeen 34-point rows, with 20-point names, section titles in bold, icons for Mundus and the
Class Mastery passives, and a blank row between sections. Seventeen rows is exactly what three
constellations of four slots need with a gap between each. The equipment rows went up too: the
item name from 18 to 21, the slot from 17 to 20, the trait line from 12 to 15.

## 0.2.9: the first page is the build

- The fourteen numbers the header band already shows — maximums, regeneration, power, critical,
  penetration, resistance — and the attribute points it also shows are no longer listed again.
- コアアビリティ and every category after it, with the active effects, moved to a page of their
  own, 詳細ステータス.
- The first page's right side is the build instead: slotted CP by constellation in blue, red and
  green again, Class Mastery, Mundus and curse. Class Mastery left the header band, since it is
  now on the page shown first.
- クリ値 is followed by the critical chance in brackets.
- The description pane turns with L2/R2 when the text is longer than it, a window of whole lines
  at a time.
- Mythic items are orange: item colours now come from the game rather than a table that stopped
  at Legendary.

## 0.2.8: equipment and the statistics on one page

The equipment rows gave up the right half of the screen — everything is narrower and pushed
left, ending at 1104 rather than 1950 — and the detailed statistics now sit in the three grid
columns beside them, so both are read without changing page. The statistics hold 96 entries
there; a character with more than that pages, as 全項目 already did.

## 0.2.7: the skill bars say what they are

Each of the twelve bar slots now has its skill's name under its icon, rather than the icon
alone. The header band grew to fit the names, which cost the grid five rows — 224 cells rather
than 259 — and equipment rows are a single line each, with the trait and enchantment beside the
item name instead of under it.

## 0.2.6: the whole of an area, with nothing to scroll

Paging through five entries at a time is gone. The selected area now uses the screen below the
header band and shows every one of its entries at once: equipment as seventeen full-width rows,
the other three areas as a 7 × 37 grid of 259 small cells. The font is smaller for it — 14 for a
grid cell — which is the trade the density needs. L1/R1 moves a whole column instead of a page,
and the description pane no longer scrolls: it draws as many whole lines as the space below it
holds, so a long set description is cut at the end rather than half-drawn.

The window is 2000 × 1040 rather than 1800 × 1040, which is closer to 16:9 and so uses the width
of the screen instead of leaving a margin at each side.

Only 全項目 can still overflow, and only that mode pages.

## 0.2.5: no Class Mastery while subclassed

Class Mastery cannot be selected at all once a skill line from another class is active, so the
block now reads サブクラス使用中は選択不可 and counts nothing. Before this it added up the
points of every class a character had an active line for — six, for a character subclassed into
two others.

## 0.2.4: Class Mastery points are per class

The Class Mastery header counted every class's points, so a character with two of their own
showed 14 — seven classes' pools added together. It now counts only the Class Mastery lines
whose class the character has an active class skill line for, which is the set the client's own
skills data manager keeps, and so follows subclassing.

## 0.2.3: nothing cut off at the bottom

The description pane at the foot of the screen is now sized to a whole number of text lines —
its height is `GetFontHeight() * 3` rather than a fixed 40 — so a description never ends in a
half-drawn line. The controls hint moved up onto the description's title row, off the window's
bottom edge, and the window itself sits higher with more room beneath it so the game's keybind
strip cannot cover the last row.

The Magicka, Health and Stamina rows are three right-aligned columns of their own instead of
one string padded with spaces, which could not line up in a proportional font once スタミナ was
wider than the other two labels. The Champion Point groups and the active effects were tightened
to make room for the Class Mastery block described above.

## 0.2.2: less work at load time

The screen is no longer built when the add-on loads. It is built the first time you open it, in
small pieces at 32 ms intervals: about a second of preparation on the first open, and the
already-built screen every time after. You can back out during preparation — closing pauses the
build, reopening resumes it.

The error in the reported screenshot is the per-frame add-on CPU limit (1000 ms) being reached.
Its stack is inside the game's own UI, so this add-on cannot be shown to be the sole cause.
This change removes this add-on's build-everything-at-load; **whether it clears the error on a
console has not been confirmed.**

## Files

| file | what is in it |
| --- | --- |
| `Data.lua` | reads the API |
| `UI.lua` | draws the screen and handles input |
| `PBsUltraDetailedStats.lua` | initialisation, the scene and the menu entry |
| `PBsUltraDetailedStats.addon` | the manifest |
| `tests/run.lua` | the offline test harness |
| `tools/package.py` | builds the upload candidate zip |
| `SuperStar/` | the original SuperStar, kept for reference only |

`SuperStar/` is reference material. None of that add-on's code or bundled libraries is loaded
or distributed here.

## Tests

```sh
luac -p Data.lua UI.lua PBsUltraDetailedStats.lua
lua tests/run.lua
python3 tools/package.py
```

The suite checks Lua syntax and, against API mocks, the data reads, the input handling, that
the menu entry is never added twice, and that polling stops when the screen closes.

**In-game rendering, behaviour on a real PS5 or Xbox, and conformance to the official Uploader
are untested.** A local test is not a substitute for the game client.

## What is verified, and what is not

Checked against the [public API definition](https://github.com/esoui/esoui/blob/f76cf16c4e5be7b234d15dc7f676febffa64c5bb/ESOUIDocumentation.txt)
and the [gamepad menu implementation](https://github.com/esoui/esoui/blob/f76cf16c4e5be7b234d15dc7f676febffa64c5bb/esoui/ingame/mainmenu/gamepad/zo_mainmenu_gamepad.lua)
for API 101050, at commit `f76cf16c4e5be7b234d15dc7f676febffa64c5bb`. The menu entry uses
`ZO_MENU_ENTRIES`, a data structure of the public UI implementation, so it needs re-checking
whenever the game updates.

On-device checklist, still to be completed:

- exactly one menu entry after a fresh login, a reload, and a character switch
- open, close, move between the four areas, page the 14 equipment rows and the 5 detail rows,
  and scroll a long set description — all on the controller alone
- 720p, 1080p and 4K, and changed UI scale: nothing clipped, keybind strip intact, Japanese
  legible
- the screen follows changes to equipment, weapon swap, food and Mundus, and confirmed skill
  and CP spending
- no errors with unearned CP, empty slots, unearned skills, Scribing, subclassing, or a
  transform bar
- equipment, attributes, CP, Class Mastery and skills match the game's own screens
- at 720p and with the largest UI scale, the description pane's last line and the controls hint are
  fully drawn and clear of the keybind strip
- the keybind strip is back to its usual size and position in the menus after closing the screen
- the 14-point grid cells are legible on a TV at a normal viewing distance, and skill names of
  ordinary length are not truncated in a 190-point cell
- the bar skill names fit their 138-point slot, or are cut short enough to still identify
- the first open still completes in about two seconds: the screen now builds roughly 700
  controls, 18 at a time
- back returns to the menu, and nothing keeps polling or capturing input after it closes

---

This Add-On is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its
affiliates. The Elder Scrolls® and related logos are registered trademarks or trademarks of
ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.
