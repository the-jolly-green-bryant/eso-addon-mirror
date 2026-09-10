# PB's DiceExtension

Gives the chat window's random roll the dice you actually want — for **The Elder Scrolls
Online on console** (PS5 / Xbox Series X|S).

- **Author:** PinkBanther
- **Version:** 1.4.1
- **Requires:** nothing. `LibHarvensAddonSettings` >= 20106 is optional and adds the settings
  panel; without it everything is reachable from `/pbdice`.

## What it does

The chat screen already has a Random Roll on its third keybind. It is `/roll` with nothing
after it, which means one number out of 1 to 100, every time.

The command itself can do more than that — `/roll 3d20` is a real thing the client
understands — but typing `3d20` on a controller keyboard every time you want to roll is not a
feature anybody uses twice.

So this remembers the dice instead. How many, and how many sides. Set them once, and roll them
with **R3** in the chat screen, with `/pbdice`, or from the settings panel:

```
/pbdice count 3
/pbdice sides 20
/pbdice

  🎲 Bosmer Bunbun rolls 34 with 3 x 20-sided dice. (only you)
     17 + 3 + 14 = 34
```

**1 to 10 dice, 2 to 1000 sides.** The second line is the one the game's own roll cannot show
you: it reports the total and nothing else.

## R3 in the chat screen

The chat screen's text input area has four buttons on it — back, focus, send, and the game's
Random Roll on the third one. This adds a fifth, on the **right stick click**, sitting to the
right of the game's roll button, labelled `PB's Dice: roll (only you / hold: everyone)`. The
game's Random Roll is left exactly as the game wrote it and still does what it always did.

One label for two actions, because the strip gives a keybind exactly one button: a second row
on the same key trips an assert and deletes the first
(`ZO_KeybindStrip:HandleDuplicateAddKeybind`), and the strip does not take `showAsHold` from a
descriptor either. The client's own screens write a press-or-hold button the same way.

**Press it** and it rolls your dice in your own chat. **Hold it for half a second** and it puts
`/roll 3d20` in the chat box instead — press Send and the game rolls them where the group can
see it. That is two presses for a roll everybody sees, without turning on the setting that
occupies the box every time you open chat. The two have to be told apart on the way up, so the
row asks for key ups (`handlesKeyUp`) and the roll happens on release rather than on press —
which is a thing an add-on may only do to a row it owns: setting it on the game's Random Roll
row would call the game's callback a second time and roll twice per press.

Writing to the box while the text area has focus makes the client's `OnTextChanged` run
`UpdateKeybinds` underneath an add-on frame, so that path was checked before being taken: it
goes through `ZO_KeybindStrip`'s `updateOnly` branch, which reuses the existing button controls
rather than acquiring from the pool and skips the re-registration entirely when nothing about
the button changed (`suppressUpdate`). The one callback it would register,
`OnKeybindLabelChanged`, is a file-scope local created at client load, not a closure born
during the call. Nothing of the client's is created while we are on the stack.

The row has to be added at a particular moment, and it is not the obvious one. The chat screen
does not build `textInputAreaKeybindDescriptor` in its `Initialize` — it builds it in
`InitializeFocusKeybinds`, which the base class calls from `OnDeferredInitialize`, which runs
**the first time the screen is shown**. At `EVENT_PLAYER_ACTIVATED` there is no table to add a
row to, and 1.1.0 looked then, found nothing, and correctly concluded there was no chat screen:
the button never appeared. The window is the scene's `SHOWING` state, where
`ZO_Gamepad_ParametricList_Screen:OnStateChanged` runs `PerformDeferredInitialize()` first and
the focal area does not push its keybinds to the strip until `SHOWN`, one state later. So the
row goes in after the table exists and before anybody has read it. `/pbdice status` says
`pending` until the screen has been opened once, rather than claiming the screen is missing.

It is a spare button rather than a long press on the roll button, and that is not a preference:

- the keybind strip fires a descriptor's callback the instant the key goes **down**
  (`ZO_KeybindStrip:TryHandlingKeybindDown`), so by the time a hold could be measured the game
  has already rolled;
- measuring the hold instead would mean owning that callback, and an add-on that owns it can no
  longer reach `RandomDiceRoll` — see below;
- and the hold cannot be timed from outside the keybind system either, because `IsKeyDown` is
  private as well.

So the game's button is untouched and the dice get one of their own. Nothing of the client's is
wrapped, replaced or called: a table it reads later gets one more row in it. Turn the row off
in the settings and it disappears from the strip — the strip asks the row whether it is visible
every time it draws it, and a hidden row's keybind does nothing. If anything else has already
claimed R3 there, this leaves it alone and `/pbdice status` says so.

## Who sees it

This is the part worth reading before you use it at a table.

The client's roll API — `RandomDiceRoll` and `RandomRangeRoll` — is marked **private**, and
private means unreachable from an add-on: one add-on frame anywhere on the callstack taints the
call, whatever is underneath it. There is no calling context that gets around it, and replacing
`ZO_RandomRollCommand` to catch the chat screen's keybind would only move our frame one step
further down the same stack. **No add-on can make the game roll.** This one included.

So there are two ways to roll here, and only one of them is a roll other people can see.

**The add-on's own dice** (what `/pbdice` and the panel's Roll button do). Rolled in this Lua
state, printed in your chat, in the client's own wording so it reads exactly like a real roll.
Nobody else sees it — which is why every line carries a quiet `(only you)` marker. A dice roll
you think your group saw and they did not is worse than no dice roll at all.

**The game's own roll** (the last setting on the panel, off by default). Turn it on and the
chat box is already filled in with `/roll 3d20` when you open the chat screen. You press Send.
From that keybind down it is the client calling itself with nothing of ours in the way, so the
roll is the real one: server-side, in the group's chat, seen by everybody.

The box is only ever filled when it is **empty**, so nothing you left half-typed is replaced.
When you opened chat to say something instead, clear it and type. That is the whole cost of the
setting, and it is why it ships off.

## Commands

| | |
|---|---|
| `/pbdice` | roll the dice you set (`/dice` too, if no other add-on took it) |
| `/pbdice 3d20` | roll that, just this once, without changing the setting |
| `/pbdice count 3` | how many dice, 1 to 10 |
| `/pbdice sides 20` | how many sides, 2 to 1000 |
| `/pbdice each on\|off` | show what each die rolled |
| `/pbdice tag on\|off` | mark rolls only you can see |
| `/pbdice keybind on\|off` | R3 in the chat screen: press to roll, hold to stage `/roll` |
| `/pbdice prefill on\|off` | have the chat box ready with `/roll` |
| `/pbdice status` | what the settings are, and what to send for a roll the group sees |
| `/pbdice reset` | every setting back to default |

Specs are read the way the game reads them, minus the modifier: `3d20`, `d20` (one d20, as it
means everywhere), `3d` (three of yours — the client would have made them d6, but it already
knows how many sides you like), and a bare number (`20` is one d20, agreeing with `/roll 20`).
Anything out of range is refused rather than quietly clamped: somebody who typed `3d2000` asked
for something this does not do, and rolling `3d1000` without saying so would look like it
worked.

## Settings

Shipped as **one die of 100 sides** on purpose — that is exactly what the chat screen's Random
Roll does today, so an add-on freshly installed and never configured changes nothing about what
a roll means. Everything else is a decision you made.

The panel is the two sliders, the R3 checkbox, a checkbox for the breakdown line, a checkbox
for the `(only you)` marker, the chat-box setting above, and a Roll button.

## The limits

1 to 10 dice and 2 to 1000 sides are this add-on's limits. The client has its own for the real
command — `RANDOM_ROLL_MAX_NUM_ROLLS` and `RANDOM_ROLL_MAX_RESULT` — and if ours are the wider
ones, the text written into the chat box is clamped to the client's and `/pbdice status` says
so, because a `/roll` the client rejects prints an error where a roll should have been. The
local dice are not clamped: they are ours, and 10d1000 is a perfectly good thing to want.

`/pbdice probe` prints both of those constants and tries the private call once. It exists so
that the day somebody wants to know whether any of the paragraph above is still true, it costs
one command and not a theory.

## Files

| | |
|---|---|
| `Main.lua` | settings, commands, and load |
| `Dice.lua` | reading a spec, rolling it, and saying what it rolled |
| `Keybind.lua` | the R3 row in the chat screen, and why it is a spare button |
| `Prefill.lua` | the other file that touches the client's UI, and why it touches so little |
| `Settings.lua` | the `LibHarvensAddonSettings` panel |
| `lang/` | English base, Japanese overrides |
| `test/` | the harness and the checks |

## Tests

```
lua test/run.lua
```

138 checks, no game required: how a spec is read, that ten dice of a thousand sides is the
edge and eleven is not, that 2000 rolls of 3d6 never leave 1..6 and always add up, that one die
is a die and three are dice in the client's own sentence, what goes in the chat box, that the keybind table does not exist until the chat
screen is first shown and that R3 is added when it does, that the button's one label names both of its
actions, that turning R3 off makes it unpressable, that a short press rolls and a long one stages while a half-typed message survives
both — and the two that would otherwise cost a console session: that what goes
in the chat box never replaces something you typed, and that the game's Random Roll still holds
the game's own callback after all of it — and that the Japanese table has a line for every English one, taking
the same arguments in the same order.

What a laptop cannot check is the one thing this add-on is careful about: whether the client
refuses a private call from add-on code. That is what `/pbdice probe` is for.
