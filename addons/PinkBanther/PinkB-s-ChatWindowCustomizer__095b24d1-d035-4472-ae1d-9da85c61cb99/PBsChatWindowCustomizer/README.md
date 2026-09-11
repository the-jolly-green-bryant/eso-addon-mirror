# PB's ChatWindowCustomizer

Moves and resizes the chat window on the HUD, and changes the size of the text in it, in The
Elder Scrolls Online on console.

- **Author:** PinkBanther
- **Version:** 1.0.1
- **Optional:** `LibHarvensAddonSettings` >= 20106 (for the settings panel; the chat commands
  work without it)

## What it does

The game puts the console chat window in the bottom right of the screen at one fixed size —
490 × 280, 215 up from the bottom — and the only related option is the text size, which is
Small / Medium / Large. This add-on makes all of that adjustable:

| | |
| --- | --- |
| **Measured from** | Which corner of the screen the position is measured from: top left, top right, bottom left, bottom right. |
| **Distance from the side** | How far the window is from the left or right edge. |
| **Distance from the top or bottom** | How far the window is from the top or bottom edge. |
| **Width** | 200 up to the width of the screen. The game's own limit is 300–550. |
| **Height** | 100 up to the height of the screen. The game's own limit is 170–380. |
| **Message text size** | 10–48. |

Every setting starts at the game's own value, read off the real chat window rather than assumed,
and **nothing is changed until you move something**. Installed and left alone, the add-on is
indistinguishable from not having it.

### The corner decides which way the window grows

The window is held by the same corner of itself that its position is measured from. From the
bottom right — the game's own choice, and the default — a taller window grows **upwards** and
the input line stays exactly where it was; a wider one grows to the left. Anchored top left, it
grows down and to the right.

Changing the corner does **not** move the window: the current position is re-expressed from the
new corner, so the sliders change their numbers and the window stays put.

### Preview

The chat is only drawn on the HUD, so it cannot be seen from the settings menu. While this
add-on's panel is open, a **pink frame** is drawn where the window will be, with the input line
marked and a few lines of sample chat in the chosen text size. It follows every slider as you
move it, and goes away when you leave the panel. It can be switched off in the panel.

`/pbchatwin preview` shows the same frame anywhere — on the HUD it sits on top of the real chat,
which is the quickest way to check the two agree.

### Text size

The slider starts at the size the game draws the chat at for your Small / Medium / Large
setting. That is **measured**, not taken from the setting's number: the game writes the size as
`$(GP_20)`, and on the Japanese client `GP_20` is 15. Once you move the slider, its size is used
instead of the game's setting. Change the game's setting afterwards and the add-on puts your size
back the next time the HUD comes up.

Only the **messages** change size. The input line keeps the game's size, because its box is a
fixed 30 high and larger text would be cut off.

## Chat commands

```
/pbchatwin                     this list
/pbchatwin status              settings, and what the chat window really has on screen
/pbchatwin pos <x> <y>         distances from the corner
/pbchatwin corner tl|tr|bl|br  which corner (keeps the window where it is)
/pbchatwin size <w> <h>        width and height
/pbchatwin font <n>            message text size (10-48)
/pbchatwin on | off            switch every change on or off
/pbchatwin preview             show or hide the preview frame
/pbchatwin reset [pos|font]    back to the game's own
```

`/pbcw` is the same command.

## How it works

Nothing in the chat is hooked, wrapped or called. The add-on only **writes to controls and
fields**, and lets the chat carry on running its own code:

- **Position and size** are the anchor and dimensions of the chat's top-level control,
  `ZO_GamepadTextChat`. The message area is anchored to its top left and the input line to its
  bottom, so moving and resizing it moves and resizes the whole chat — the same call the game
  makes in `GamepadChatContainer:LoadSettings`.
- **The size limits** are four plain fields on `GAMEPAD_CHAT_SYSTEM` that the game turns into
  `SetDimensionConstraints` whenever it lays out its tabs. They are widened as data, and the
  constraints set to match.
- **The text** is the font on each chat tab's `TextBuffer`, in the same `face|size|style` form
  the game builds in `GetChatFontFormatString`, with a number where the game has `$(GP_n)`.

The chat is where every message the player sends goes through the client's own code, and an
add-on frame near that code is how private-function errors start — see FINDINGS.md.

The game's own anchor, size and limits are read off the control before the first write of each
session. Reset, the on/off switch, and a slider moved back to the default all put exactly those
back.

## What it does not touch

- **The input line's text size** — see above.
- **Whether the chat is shown on the HUD** — the game's setting under Settings > Social. The
  add-on can read it but `SetSetting` is private.
- **The keyboard chat** on PC, which already has its own move, resize and text size.
- **The chat menu, the channels, the messages themselves.**

## Tests

```
lua test/run.lua
```

from the add-on folder, with any Lua 5.1 or later. `test/harness.lua` stubs the gamepad chat —
its control, its tab buffers, and its own `LoadSettings`, `SetFontSize` and
`CalculateConstraints` — with a label that resolves `$(GP_n)` the way the Japanese client does,
so a build that wrote the setting's number back as a size would fail.

## Licence

This Add-On is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its
affiliates. The Elder Scrolls® and related logos are registered trademarks or trademarks of
ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.
