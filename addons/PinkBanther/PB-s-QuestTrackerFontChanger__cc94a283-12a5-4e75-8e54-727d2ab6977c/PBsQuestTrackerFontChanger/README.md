# PB's QuestTrackerFontChanger

Adjusts the fonts of the two HUD trackers in the top right of the screen in The Elder Scrolls
Online on console.

- **Author:** PinkBanther
- **Version:** 1.0.0
- **Requires:** `LibHarvensAddonSettings` >= 20106

## What it does

Two trackers, kept separate everywhere — settings, saved variables, chat commands — because
they are different pieces of UI that happen to sit one above the other, and somebody who wants
a bigger house name usually does not want a bigger quest tracker.

### Quest tracker

The tracked quest in the top right. Three kinds of text, three sizes, because the game gives
them three different fonts:

| | |
| --- | --- |
| **Quest name size** | 10–72. The name at the top of the tracker. |
| **Step description size** | 10–72. The line under the name saying what this stage is about. Not every quest step has one. |
| **Objective size** | 10–72. What you actually have to do, and any counters. |

In gamepad mode the game's own sizes are 27 for the quest name, 22 for the step description
and **34 for the objective lines** — the objectives are drawn *larger* than the quest name.
That is the game's design, not a mistake, and one slider for all three would flatten it. Set
all three to the same number if you want them uniform. In keyboard mode all three are 18.

### House tracker

The panel under the quest tracker while you are in a house — yours, or someone else's on a
home tour. It carries the house name, its nickname and owner, how many people are inside, and
the House Tours tags.

| | |
| --- | --- |
| **House name size** | 10–72. The name at the top of the panel. |
| **House details size** | 10–72. Everything under it: nickname and owner, visitor count, tags. |

Two sliders rather than four, because the game gives the house name one font and all three
lines under it the same second font — three identical sliders would only be three ways to make
them disagree.

### In both sections

| | |
| --- | --- |
| **Typeface** | The game's own faces, offered as aliases (`$(GAMEPAD_MEDIUM_FONT)` and friends) rather than resolved paths, so the client keeps picking a face that can draw the current language. |
| **Outline** | The descriptor style tokens the client's own font definitions use. |

Each slider **starts at the size the game itself draws that part at**, measured off a real
label rather than assumed — see [Sizes are measured, not assumed](#sizes-are-measured-not-assumed).
So an install that has not been touched looks exactly like no add-on at all, and it is not
just that it looks that way: while every setting in a section still matches the game's own,
the add-on never calls `SetFont` there and the client never builds a font.

Sizes are stored **per mode**. Gamepad and keyboard start from different numbers, so one
shared value would be wrong in whichever mode it was not chosen in. On console only the
gamepad set is ever used.

### Typefaces

The same list as PB's NamePlateChanger, for the same reasons. Only faces the console UI
**already has loaded** are offered: any other has to be built when it is set, and that build
is billed to the 100 MB pool every console add-on shares — measured on PS5, it crashes the
add-on.

| Setting | Alias | Western | Japanese |
| --- | --- | --- | --- |
| Console (medium) | `$(GAMEPAD_MEDIUM_FONT)` | FTN57 | FTN57 for Latin; Japanese falls back to the gothic |
| Console (bold) | `$(GAMEPAD_BOLD_FONT)` | FTN87 | FTN87 for Latin; Japanese falls back to the gothic |
| Console (light) | `$(GAMEPAD_LIGHT_FONT)` | FTN47 | ESO_FWNTLGUDC70-DB |
| Interface (medium) | `$(MEDIUM_FONT)` | Univers57 | ESO_FWNTLGUDC70-DB |
| Interface (bold) | `$(BOLD_FONT)` | Univers67 | ESO_FWNTLGUDC70-DB |

**Default** is not one face: it keeps whatever the game picked for each part separately, which
in gamepad mode means a bold name over medium text under it. Picking a face here deliberately
collapses that distinction onto one face.

**Not offered**, because they were measured to crash on PS5: `$(CHAT_FONT)`,
`$(ANTIQUE_FONT)`, `$(HANDWRITTEN_FONT)`, `$(STONE_TABLET_FONT)`. A saved setting pointing at
one of them is dropped back to Default on load, in both sections — the list of offered faces
is the authority, so removing one is always enough to stop it being used.

### Outlines

A `LabelControl`'s `SetFont` parses the style out of the descriptor string as a **token**, not
as a `FONT_STYLE_*` number the way the nameplate API did — and the tokens are not the enum
names lowercased either (`FONT_STYLE_OUTLINE_THICK` is written `thick-outline`). Only the four
tokens the client's own font definitions use are offered: `shadow`, `soft-shadow-thin`,
`soft-shadow-thick`, `thick-outline`. `FONT_STYLE_OUTLINE` and `FONT_STYLE_OUTLINE_SHADOW`
exist as enum values with no token anywhere in the client source, so they are left out until
one is measured — a font that fails to build is not a good surprise on console.

**Outline styles are the expensive setting.** The client has to generate outline glyphs, and
the game's own source puts that at about 100 MB for a CJK font — the same size as the whole
pool console add-ons share. If the game becomes unstable, put this back to Default.

## Why this can do more than PB's NamePlateChanger

The overhead nametag is drawn by the engine: an add-on can only hand the client a font
descriptor through a client setting, that setting outlives the session, and changing the face
reloads the UI.

Both trackers here are the opposite. They are ordinary Lua UI —
`esoui/ingame/zo_quest/questtracker.lua` and
`esoui/ingame/housingeditor/houseinformationtracker.lua` build them out of `LabelControl`s,
and a `LabelControl` takes `SetFont(descriptor)` directly. So:

- **no interface reload**, whatever the face is changed to,
- **nothing outlives the session**: uninstalling the add-on is enough to undo it, and there is
  no captured "original" to keep safe,
- **no write budget and no reload loop** to defend against, because nothing here is a client
  setting that could be written back at us.

The full evidence is in [FINDINGS.md](FINDINGS.md).

## How it hooks in

The two trackers are built differently, so they need different hooks.

**Quest tracker — the pools.** `ApplyPlatformStyleToHeader` / `...ToCondition` /
`...ToStepDescription` are file-local in `questtracker.lua` and cannot be hooked — but they are
installed on the label pools with `SetCustomAcquireBehavior`, and `pool.customAcquireBehavior`
is a plain field. Reading it, calling it first and styling on top of it means every label is
ours from the moment it is acquired, including the ones the tracker rebuilds by itself when a
quest step advances. No polling, and the tracker's own `UpdateTreeView` still runs afterwards
and lays out the new text heights.

**House tracker — the method.** Nothing there is pooled: it is a singleton with four fixed
labels, and `ZO_HouseInformationTracker:ApplyPlatformStyle` is the only thing that ever sets
their fonts. It is a public method, so it is wrapped on the instance — and because it is the
only writer, our font stays put until the next time it is called. Calling it is also how the
game's own font is put back, so "off" and a *smaller* setting both go through the same path.

### Sizes are measured, not assumed

The game names its fonts `ZoFontGamepadBold27`, and `esoui/fontdefs/` defines that as
`$(GAMEPAD_BOLD_FONT)|$(GP_27)|soft-shadow-thick`. `$(GP_27)` is 27 **after the client's own
resolution scaling**, which an add-on cannot compute. Writing 27 back would therefore not be
"the same size", it would be a size change nobody asked for.

Both hooks run immediately after the game's own styling, which hands us a label nothing else
has touched, so `control:GetFontSize()` there is the client's real number for that part. That
is what the sliders start from, and it is stored in saved variables so the panel knows it
before you are anywhere near a quest or a house.

It is read once per part per session, and the label is checked before it is believed: the game
always styles with a *named* font (`ZoFontGamepadBold27`) and this add-on always writes a
descriptor, which by construction contains a `|`. A label carrying a pipe is one of ours and is
refused. Reading one of our own fonts back would make it the new "default" and the client's
real number would be gone for good — that is the mistake PB's NamePlateChanger had to grow a
repair path for, and here it is a string test rather than a load-order assumption.

Until a label has been seen, the sliders fall back to the numbers in the font names (27 / 22 /
34 for the quest tracker, 27 / 34 for the house panel, and 18 for everything in keyboard mode).

### The quest name box

The gamepad quest name is the one control in either tracker that is given a fixed height
(`QUEST_HEADER_BASE_HEIGHT = 28`); every other label — the whole house panel included — is left
unconstrained and sizes itself to its text. Since the quest tree stacks nodes by anchoring each
control's top to the previous one's bottom, a larger quest name would be clipped and the step
description would be drawn over it. The box is grown in the same proportion as the font. Only
grown — the game's own box has headroom, and shrinking it would pull the rest of the tracker up
into it.

## What it does not touch

- **The quest timer** (the countdown above the tracker on timed quests) has its own controls
  and its own fonts, and is left alone.
- **The order and wording of the lines** in either tracker, which are built from journal and
  housing data.
- **Whether either tracker is shown at all**, which is the game's own setting under
  Settings > Interface.

## Settings

Settings → Add-On Settings → PB's QuestTrackerFontChanger. The panel is split into a
**Quest tracker** section and a **House tracker** section, each with its own switch, sliders,
typeface and outline, and a single Reset at the bottom for both.

Chat commands:

```
/pbquest                        this list
/pbquest status                 settings, and the font actually on screen
/pbquest quest <n>              all three quest tracker sizes
/pbquest quest <part> <n>       one part: name | step | goal
/pbquest house <n>              both house tracker sizes
/pbquest house <part> <n>       one part: name | detail
/pbquest size <n>               every size in both
/pbquest on | off               both sections
/pbquest quest on | off         the quest tracker only
/pbquest house on | off         the house tracker only
/pbquest reset                  back to the game's own fonts
```

`/pbqt` is the same command.

`status` prints what is on screen read back off a live label, so it says what the client is
really drawing rather than what the add-on believes it asked for. The quest lines need a quest
to be tracked to have a label to read; the house lines are readable anywhere, but only show on
screen inside a house.

## Tests

The add-on runs on a console, where one real test costs a session: build, upload, boot the
PS5, log in. `test/harness.lua` stubs the part of the client the add-on actually touches — the
quest tracker's three control pools, the house tracker's four labels and its
`ApplyPlatformStyle`, a `LabelControl` that parses `face|size|style`, saved variables and
LibHarvensAddonSettings — so the logic can be exercised on a desktop first.

```
lua test/run.lua
```

The stub scales gamepad font sizes by 0.75, the way the client scales `$(GP_27)`. A build that
wrote the raw font-definition number back instead of the measured size passes against a 1:1
stub and changes the text on a real client, so the stub refuses to be 1:1.

## Licence

This Add-On is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its
affiliates. The Elder Scrolls© and related logos are registered trademarks or trademarks of
ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.
