# PB's ConsoleHudCustomizer

Moves and resizes the health, magicka, stamina and skill bars on the HUD, can draw the resource
bars as plain rectangles, shows the weapon set you are not on, and marks how long is left on each ability --
as a shade that clears down the icon, a countdown, and a target count -- in The Elder Scrolls
Online on console.

- **Author:** PinkBanther
- **Version:** 1.13.0
- **Optional:** `LibHarvensAddonSettings` >= 20106 (for the settings panel; the chat commands work
  without it)

## What it does

The game pins the three resource bars and the skill bar to the bottom of the screen at one fixed
size, and offers no setting for any of it. This add-on gives each of the four three of its own:

| | |
| --- | --- |
| **Sideways** | How far the middle of the bar is from the middle of the screen. 0 is dead centre, negative left, positive right. |
| **Height** | How far the middle of the bar is up from the bottom edge. The game's own bars sit 137 up. |
| **Size** | 50% to 200% of the game's own size. Frame, background, bar and numbers all together. |

The four are independent, so health can sit in the middle of the screen with magicka and stamina
low in the corners, the skill bar higher up, or the whole lot moved out of the way of a minimap.

Every setting starts at the game's own value, **measured off the real bars** rather than assumed,
and nothing is changed until you move something. Installed and left alone, the add-on is
indistinguishable from not having it.

### Size is one number, on purpose

The bar's width is not the add-on's to keep. The game stretches a bar to 323 wide, or shrinks it
to 141, every time a buff or debuff moves one of your maximums — food, Undaunted Mettle, a
debuff — and animates it there. A width written by an add-on would survive until your next meal.

So "size" is a scale: 100% is the game's own, and everything in the bar grows and shrinks in
proportion, which is also the only way the arrow-shaped frame ends stay the right shape. The bar
keeps the position of its **middle**, so it grows evenly both ways and stays where you put it —
including when the game stretches it for a buff.

### The small bars follow

The werewolf bar lives under magicka, mount stamina under stamina and siege health under health.
Each one is anchored to its partner in the game's own XML, so it moves with it, and this add-on
gives it the same size so the pair still lines up.

### A plain look for the resource bars

**Bar style** switches the three resource bars between:

- **Standard** — the game's own bars, untouched. Nothing is built and nothing runs.
- **Square** — each bar as a flat rectangle: a dark track, and a solid block in that power's own
  colour, with the game's own resource numbers lifted over it.
- **MURA-HIGE Style** — the same rectangle, drawn at a **width and a height in pixels**: the two
  extra sliders in each bar's section, live only in this style. Choosing it is enough — the bars
  are drawn at the game's own size until you change one. The percentage slider is greyed out here,
  and the pixel ones are greyed out in the other styles; the skill bar is scaled either way. The game's arrow-shaped frame and background are put away while this is chosen, and come
  straight back when it is not. **How solid** takes the rectangles from fully opaque down to
  letting the game's own fill show through, and **Draw an outline** puts a thin dark line round
  each bar — the game's arrow-shaped frame is always put away while one of these styles is on, so
  that line is the only frame on offer.

The bars themselves are left alone and still doing their work, so the damage shield overlay, the
armour and possession effects, the low-health warning and the out-of-combat fade all still happen
on top. Nothing is drawn from an art file — the rectangles are backdrops, which are a colour and
nothing else.

> The liquid style of 1.3.x is gone: it never drew anything on a console. If you had chosen it,
> you now have this one.

### A shade over a skill while its effect runs

While an ability's effect is running, its icon is shaded over, and the shade is **wiped away down
the icon** as the time runs out, so how much is left can be seen without reading the number. It
runs on both weapon sets.

The sweep is the game's own `Cooldown` control — the same machinery as an ability cooldown — given
the effect's real length, so it is always exactly as long as the effect and costs nothing per
frame. How dark it is, whether the moving edge is lit, and which way it clears are all settings.

### Leaving the skill bar alone

**Let this add-on touch the skill bar**, at the top of the skill bar's section, hands the whole
bar back to the game and to any other add-on that lays it out. Its position and size, the spacing
along it, the other weapon set's row, the countdown and target count on the icons and the shade
over a skill in use are all put back and stay off — including the watch that would otherwise put
them back. Your settings are kept for when you turn it on again, and the health, magicka and
stamina bars are not affected.

### Spacing along the skill bar

The game leaves a lot of room around the ultimate and the item. Three sliders close it up:

| | the game's |
| --- | --- |
| **Between the abilities** | 10 |
| **Before the ultimate** | 65 — what makes it sit out on its own |
| **Before the item** | the whole width of the weapon swap marker, plus 15 |

That last one is the big one. On console the weapon swap marker is never drawn, but it is still a
control sitting between the quickslot and the first ability, with the quickslot anchored to its
far side. This add-on anchors the item to the first ability directly, so the number you set is the
gap you see. While a companion is out, its ultimate joins that side of the row and takes the same
gap.

The first ability does not move — it is what the rest of the row hangs off — so the bar closes up
towards it. Re-centre it with the skill bar's own position slider if you want it dead centre.

### The weapon set you are not on

With **Show the other weapon set** on, a row of that set's abilities is drawn above the skill bar,
in the game's own back row frame. It follows the skill bar wherever you put it, swaps over when
you swap weapons, and has its own size and gap.

The game has a row of its own (Settings > Interface, *Action Bar Timers* and *Back Row*), but it
only appears for a slot whose effect is still running and disappears again when it ends. This one
is always there, so both sets can be read at a glance. If you want only this one, turn the game's
Back Row setting off.

**When there is no second set, the row hides itself.** The Oakensoul Ring and anything else that
locks you to one bar, or a character too low to have earned the weapon swap yet: the row goes on
its own and comes back when the lock does, without touching your setting.

### Countdown and target count

On **both** sets, each icon can carry:

| | |
| --- | --- |
| **Countdown** | How long is left on that ability's effect. Gold, at the bottom of the icon. A minute or more reads as `1m`, the last ten seconds as `9.4` (optional). |
| **Target count** | How many targets are under the effect. White, in the top corner. From one target, or from two if you would rather a single-target ability did not carry a 1. |

Each has its own text size, 12 to 48, **per bar**: the countdown and the target count on the bar
you are on, and the countdown and the target count on the other set's row. The row's icons are
smaller than the bar's, so a smaller number often reads better there.

Until you move one of the row's two sliders it **follows the bar's**, so one size for both stays
one slider. **Match the other set to this bar** puts it back to following.

The countdown starts the moment you cast, from the length the game gives the ability, and an
effect of that cast takes over from it — but only if that effect is about as long as the ability
is. One cast can put several effects on the world, and the longest, or the only one the client
reports, is often not the ability's own. If the same effect
lands on another target later, the countdown runs to whichever ends last.

The countdown is **the effect your cast produced**. When you press a slot, the effects that appear
in the moment after it are that slot's, and the one that is counted down is the one whose length
matches what the game says that ability lasts — so Power of the Light shows its 6 seconds rather
than the 20 of the Major Breach it also applies, and Blue Betty shows its 22-second buff all the
way out rather than handing over to the five-second thing the netch does. The same ability on both weapon sets shows the same number on both, because it is one effect: a
cast is on record against the ability, not just the slot it was made from. For a slot whose effect
this add-on has not seen cast at all, the game's own number is used instead.

The target count has no API behind it: it is counted from the effects you and anything of yours
apply -- a pet's count too, which matters for the netch, the familiars, the bear and the shade — the same effect
the countdown is for, when the cast was seen, and otherwise matched to the slot by the ability's
**name**, then its **id**, then its **icon**. The icon is what catches a
morph whose effect is called something else, which is most of them. `/pbhud slots` says which of
the three matched, or that nothing did. The countdown is unaffected either way, because that comes
from the client.

**Countdown on the bar you are on** decides what happens when the game is already writing its own
number there (Settings > Interface > Action Bar Timers). That number is drawn at a size no add-on
can change, so:

- **This add-on** (the default) — ours goes in the middle of the icon and the game's own number is
  faded out of the way, so the text size setting always does something and there is only ever one
  number.
- **Both** — ours as well as the game's; ours drops to the bottom of the icon so the two do not
  sit on top of each other.
- **The game** — the front bar is left exactly as it is. The other set still gets ours, because
  the game never writes a number there at all.

The set you are not on is always this add-on's, whichever of the three is chosen.

### Preview

The bars are only drawn on the HUD, so they cannot be seen from the settings menu. While this
add-on's panel is open, an **outline the size of each bar**, in that bar's colour, is drawn where
it will sit — the three resource bars, the skill bar, and the other set's row above it. It follows every slider as you move it, and goes away when you leave the panel. It
can be switched off in the panel.

`/pbhud preview` shows the same outlines anywhere — on the HUD they sit on top of the real bars,
which is the quickest way to check the two agree.

## Chat commands

```
/pbhud                             this list
/pbhud status                      settings, and where the bars really are on screen
/pbhud pos <bar> <x> <y>           x from the middle of the screen, y up from the bottom
/pbhud scale <bar> <n>             size in per cent (50-200)
/pbhud gap skill|ult|item <n>      the space along the skill bar (0-150)
/pbhud style standard|plain|mura    the look of the three resource bars
/pbhud size <bar> <w> <h>          bar size in pixels (MURA-HIGE Style)
/pbhud shade [on|off|up|down|<n>]  the shade over a skill while its effect runs
/pbhud text [back] timer|count <n> size of the text on the skill bar (12-48)
/pbhud timers addon|both|game      whose countdown goes on the front bar
/pbhud slots                       what is on each slot, and why
/pbhud backbar [on|off|empty|<n>]  the other weapon set's row
/pbhud skillbar on|off             whether the skill bar is this add-on's to touch
/pbhud on | off                    switch every change on or off
/pbhud preview                     show or hide the preview outlines
/pbhud reset [bar]                 back to the game's own
```

`<bar>` is `health`, `magicka`, `stamina` or `skillbar` (`hp`, `mag`, `stam`, `bar` also work).
`/pbhc` is the same command.

## How it works

Nothing in the attribute bars is hooked, wrapped or called. The add-on only **writes to
controls**, and lets the bars carry on running their own code:

- **Position** is the anchor of each control — `ZO_PlayerAttributeHealth`, `...Magicka`,
  `...Stamina` and `ZO_ActionBar1` — re-pointed to `GuiRoot`: `CENTER` of the bar on `BOTTOM` of
  the screen. The attribute bars stay children of `ZO_PlayerAttribute`, so the HUD fragment still
  fades and hides them, and the game's "fade out of combat" setting still works.
- **Size** is `SetScale` on that control, and on its small companion.
- **The shade** is a `Cooldown` control of the add-on's own over the button's icon, started with
  `CD_TYPE_VERTICAL_REVEAL` and the effect's real duration; the engine runs the sweep.
- **The plain look** is one control per attribute bar, a child of the container and anchored over
  the bar, holding two backdrops: the track and a block whose width comes from `GetUnitPower`.
- **The gaps** are the same anchors the client writes in `ApplyAnchor` (`LEFT` on the previous
  button's `RIGHT`), with the quickslot moved off the hidden weapon swap marker and onto the
  first ability.
- **The countdown** is read from the client: `GetActionSlotEffectTimeRemaining(slot, hotbar)`,
  which answers for either weapon set.
- **The other set's row and the text** are controls of this add-on's own, laid out in
  `Controls.xml` and parented to the `ActionButton` they belong to, so the action bar fades and
  hides them with itself.

These controls run combat code — power updates, the attribute visualiser, the warners — on every
frame of a fight, and an add-on frame near client code is how private-function errors start. See
FINDINGS.md.

The game's own anchors and scales are read off the controls before the first write of each
session. Reset, the on/off switch, and a slider moved back to the default all put exactly those
back.

## What it does not touch

- **The bar's own width** — the game's, see above.
- **The game's own back row** — its controls are left exactly as they are; turn it off under
  Settings > Interface if you want only this add-on's row.
- **The game's own countdown**, except for fading it out of the way when this add-on is drawing
  one on the same icon. Its text, its size and the setting behind it are the game's.
- **What is slotted, the abilities, the cooldowns and the ultimate meter.**
- **Whether the numbers are shown on the bars**, and **whether the bars fade out of combat** —
  the game's settings under Settings > Interface.
- **The order or the colours of the bars**, the werewolf / mount / siege bars' own positions, and
  anything else on the HUD.

### If the rectangles do not appear

```
/pbhud plain
```

prints what it is doing: whether the style is actually Plain, whether the loop is running, whether
each bar control was found and its rectangle built, how full the bar is, and the alpha the game
has the bar at. That last one is worth knowing — **the game fades the resource bars out while they
are full and you are out of combat**, and this is drawn on them, so look at a bar that is
part-empty or wait until a fight.

### If a bar will not move

Everything this add-on writes is checked once a second while the HUD is up and put back if it is
no longer there, so a bar that is moved by something else comes back on its own. `/pbhud status`
prints how many times it had to do that, along with each bar's position, whether it differs from
the game's, and whether it has been written.

## If something is not showing

`/pbhud slots` prints, for every slot on both sets: what is in it, how many milliseconds the
client says are left, what this add-on made of that, the target count it worked out, and whether
its label was ever built. Underneath it lists the effect names being tracked — a count is only
written when the ability's name is in that list.

`/pbhud status` adds the rest: how many controls were built, whether the game is drawing its own
numbers, and any write the client refused.

## Tests

```
lua test/run.lua
```

from the add-on folder, with any Lua 5.1 or later. `test/harness.lua` stubs the three attribute
bar containers with the game's own anchors, a layout resolver that turns an anchor into a
rectangle, the attribute visualiser's habit of writing 141 / 237 / 323 onto a bar's width, the
action bar with its buttons, the action slot API for both hotbars, and `EVENT_EFFECT_CHANGED` —
so a build that measured the game's position off a stretched bar, that fought the visualiser for
the width, that counted a group member's copy of a buff as another target, or that drew a second
countdown next to the game's own, would fail here rather than on a PS5.

## Licence

This Add-On is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its
affiliates. The Elder Scrolls® and related logos are registered trademarks or trademarks of
ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.
