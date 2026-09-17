# PB’s SuperStar

Puts your character's equipment, detailed statistics, Champion Points and skills on one screen,
in the gamepad UI of **The Elder Scrolls Online** on console (PS5 / Xbox Series X|S).

- **Author:** PinkBanther
- **Version:** 0.2.8 (API 101050)
- **Libraries:** none

Open it from **ステータス超詳細** in the gamepad main menu, between **Character** and **Skills**.

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
- **Statistics** — the three base attributes, attribute points, every detailed statistic
  category the API exposes, and the effects currently running on you (Mundus, food, and the
  rest).
- **Champion Points** — twelve slots, spent and unspent points per constellation, and per star
  the points invested, the cap and the description, distinguishing slotted, unslotted, passive
  and inactive.
- **Class Mastery** — the Class Mastery passives you have bought, with their ranks, and the
  class mastery points they are bought with. These are a separate currency from skill points,
  and the game reports their skill lines as undiscovered until a class line reaches max rank,
  so they are listed whatever the client says about discovery. Every class in the game has a
  Class Mastery line reporting its own pool of points, and none of them may be added up:
  Class Mastery is selectable only while all of your active class skill lines are your own
  class's, so the block counts nothing at all while you are subclassed.
- **Skills** — six slots on each bar, each icon with the skill's name written under it plus whatever special bar is in use, your active,
  ultimate and passive abilities, line rank, skill rank and unspent points. Scribing skills are
  listed too.

Nothing scrolls. A band across the top always shows the character, the three attribute
columns, both skill bars, the combat numbers, the skill and Champion Point totals and the Class
Mastery line. Everything below it belongs to the area you have selected with D-pad left and
right, and holds **all** of that area's entries at once.

Equipment and the detailed statistics share one page: the seventeen equipment slots keep the
left of the screen as narrow rows carrying the trait, enchantment and set count, and the
statistics fill the three columns beside them — 96 entries. D-pad left and right moves the
focus between the two without changing the page. Champion Points and skills each take the whole
width instead: a grid of seven columns by thirty-two rows, 224 entries, filled column by column.
The description of whatever is selected sits at the foot of the screen.

The one thing that does not fit is 全項目, which adds every unearned Champion Point star and
skill: past what a page holds the area pages, and its title says which range is on screen.

## Controls

| action | PS / Xbox |
| --- | --- |
| choose an area, then an entry | D-pad left/right, up/down |
| jump a whole column of entries | L1 / R1 — LB / RB |
| refresh now | the 再取得 button on the screen |
| show unearned CP and skills too | the 取得済み / 全項目 button |
| back to the menu | ○ / B (follows your back-button setting) |

D-pad left and right move between the four areas — equipment, detailed statistics, CP and
skills. Everything but equipment lists its entries bottom right, so the attributes, equipment
and CP summaries stay on screen while you read them. Long lists and descriptions scroll in
place, and a name that had to be truncated is spelled out in the detail pane below.

CP colours follow the constellation; item name colours follow quality. **クリ値 in the combat
numbers is the Critical rating, not a percentage.**

While the screen is open it re-reads everything every 1.5 seconds, and stops when you close it.
The numbers reflect the bar you have drawn and the buffs you have now. It does not estimate the
back bar or simulate hypothetical builds, and CP shows confirmed investment only. "Passive"
describes the kind of star, not whether its condition is currently met — read the effect text
for that. A skill's earned state and its line's active state are shown separately.

## Setup

On PC, put `PBsSuperStar.addon`, `Data.lua`, `UI.lua` and `PBsSuperStar.lua` in
`AddOns/PBsSuperStar/`. The manifest is the same `.addon` format as the other PB add-ons; do
not ship the old `PBsSuperStar.txt` alongside it, and keep it out of the zip. `/pbss` opens the
screen on PC, for testing.

**Creating the files locally does not install anything on a console.** Console distribution
goes through Bethesda's developer Uploader — build a candidate with `python3 tools/package.py`,
then follow the console development environment and the Uploader's instructions. Nothing here
has been uploaded or published. See the
[official console Uploader notes](https://help.elderscrollsonline.com/app/answers/detail/a_id/69621/).

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
| `PBsSuperStar.lua` | initialisation, the scene and the menu entry |
| `PBsSuperStar.addon` | the manifest |
| `tests/run.lua` | the offline test harness |
| `tools/package.py` | builds the upload candidate zip |
| `SuperStar/` | the original SuperStar, kept for reference only |

`SuperStar/` is reference material. None of that add-on's code or bundled libraries is loaded
or distributed here.

## Tests

```sh
luac -p Data.lua UI.lua PBsSuperStar.lua
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
