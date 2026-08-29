# PB’s ChatAssistant

Opens the chat entry box, and with it the console's Japanese input screen, from the keyboard's
**Enter** key on **The Elder Scrolls Online, console (PS5 / Xbox Series X|S)**.

- **Author:** PinkBanther

## Why this exists

With a USB keyboard plugged into the console you can type a message, but you cannot *start* one.
The chat entry box only opens from the controller (Options + touchpad on PS5), and opening it is
what makes the console raise its own input screen -- the IME, without which there is no
kana-to-kanji conversion and so no Japanese at all. Every message means letting go of the
keyboard, reaching for the pad, and coming back.

Press Enter, the box opens, the input screen comes up.

## Setup

None. Install it, reload the UI. The controller behaves exactly as it always did; only the input
screen is new. `/pbchat enter` is opt-in, and pauses the gamepad buttons while it is armed -- see
Opening from Enter.

Nothing is armed at install. Confirm the build with the line it prints on login:

```
PB’s ChatAssistant: 1.0.2 loaded -- capture off, delay 100 ms, follow false, log false
```

## How it works

A **focus watcher** polls four pieces of state every 200 ms, and acts when they line up:

```
entry open  AND  edit control focused  AND  no input screen  AND  the box is empty
    -> close the entry, wait delayMs, open it again  -> input screen
```

Nothing in Lua summons that screen. `IsVirtualKeyboardOnScreen()` and
`DoesCurrentLanguageRequireIME()` only report, and `SetVirtualKeyboardType()` picks a layout for a
control the platform has already decided to serve. The screen is the platform's own response to
the chat edit control **losing focus and taking it again** a frame or more later. So the watcher
does not show anything: it spots the state that means the screen is owed and has not come, and
performs the focus cycle that earns it.

The reason to do it this way is that **it does not care what opened the box**. The controller
combo, an Enter caught by the key catcher, another add-on -- all of them land in the same state
and all of them get the input screen. The first key press of a session stops being a special
case, because there is no longer a case.

Two safeguards: it never touches a box that already has text in it, since a box with text was not
opened a moment ago and re-cycling it would throw the message away; and it acts once per open,
re-arming only when the box closes, so it cannot loop.

`/pbchat watch off` turns it off.

## The wait

`/pbchat delay <ms>`, 0-5000, default 100.

The wait is the mechanism, not a safety margin. Closing and reopening in the same frame gives the
platform no lost-and-regained focus to react to. Measured on PS5: opened immediately,
`edit focus true` but `input screen false`, still false a second later; opened after a wait, the
screen appears. How long is a property of the machine, so it is tunable: if the box opens but the
input screen does not follow, the wait is too short. Raise it -- 300, then 500 -- rather than
looking anywhere else.

It is **not** gated on which input device was last used. The same measurement was repeated
without touching the controller at all and the screen still came up.

## Opening from Enter, and what it costs

The watcher gives the input screen to a box opened any way at all, including the controller
combo, so the key catcher is now only about **Enter**: it is what makes Enter open the box in the
first place. It costs the gamepad buttons for as long as it is up -- see Limitations.

It does not stay up. **The moment the input screen appears, the catcher comes down by itself**
and the buttons come back, because the one key press it existed to hear has already happened.
`captureMode` is a saved setting, so this persists: a session starts with the controller working.

So the cycle is:

```
/pbchat enter     ->  Enter opens the box, input screen comes up, catcher drops itself
                      buttons work again while the message is typed and after it is sent
                      the next chat opens from the controller combo, and still gets the screen
/pbchat enter     ->  arm Enter again for the next stretch of typing
```

`/pbchat autosafe off` keeps the catcher up instead, for a long typing session where the
controller is not wanted anyway.

## Two things that look like the same bug

Both cost several releases, and both are the catcher getting in the way.

**A shown catcher stops the input screen appearing.** With one up, even `/pbchat open` -- which
had worked minutes earlier with nothing shown -- stopped producing the screen. The catcher holds
the engine's keyboard focus, so the chat edit control taking focus is not what the platform sees.
The catcher therefore hears one key press and immediately gets out of the way: it stands down at
the *start* of the wait and stays down across the open, coming back when the box closes. This is
also why the watcher's re-focus works -- by then the catcher is already down.

**A shown catcher stops the gamepad buttons working**, on every tier tried (`default`, `high`,
`medium`, `low`), while leaving the sticks alive. It receives no gamepad keys at all -- a probe
saw only the keyboard's Enter -- so nothing is being swallowed by the handler. The buttons go to
the UI instead of to the gameplay bindings simply because a control is up and wants input; the
sticks survive because `DIRECTIONAL_INPUT` is a separate path.

That second one is **not solved**. See Limitations.

## Commands

| Command | Effect |
| --- | --- |
| `/pbchat` | Status and the platform flags |
| `/pbchat delay <ms>` | The wait before opening, 0-5000, default 100 |
| `/pbchat watch on\|off` | The focus watcher |
| `/pbchat autosafe on\|off` | Drop the catcher once the input screen is up |
| `/pbchat open [s]` | Open the box after N seconds, no key catching involved |
| `/pbchat enter` | Catcher on -- catches every Enter, costs the buttons, expires in 60 s |
| `/pbchat safe` | Catcher off -- buttons back |
| `/pbchat log on\|off` | Trace key presses, opens and catcher changes |
| `/pbchat probe [tier]` | 15 s: report what keys reach a tier, keyboard and gamepad apart |
| `/pbchat trial [tier]` | 20 s with a live catcher, then off by itself |
| `/pbchat capture off\|default\|high\|medium\|low` | Which tier catches Enter |
| `/pbchat unstick` | Force the chat entry closed, giving the controller back |
| `/pbchat on` / `off` | Master switch |

## Limitations

**Gamepad buttons do not work while the catcher is up.** It is up whenever you are not chatting,
which is to say whenever you are playing. This was never solved.

It matters much less than it did, for two reasons. The catcher is only needed to open the box
from **Enter** -- the input screen itself comes from the watcher, which serves a box opened by the
controller combo just as well. And the catcher now drops itself as soon as the input screen
appears, so it is up for the moment between arming Enter and pressing it, rather than for the
whole session.

`/pbchat safe` is therefore a complete configuration and not a degraded one: it trades Enter for a
controller that always works.

What was tried and did not work:

- **All four display tiers.** Every one kills the buttons.
- **`EVENT_INPUT_TYPE_CHANGED`, to raise the catcher only while the keyboard is in use.** It
  fires only on a *change*, so a run of key presses produces one event and then silence, and
  gating the catcher on it left nothing listening for the second message onward.
- **`WasLastInputGamepad()`, for the same gating.** Useless on console: it answers "gamepad"
  immediately after a whole slash command has been typed on the keyboard.

## Why the trigger cannot be a keybind

`Bindings.xml` declares `PBSCHATASSISTANT_START_CHAT`, which is the correct route and the only
one on PC. On console it is dead: `AreKeyboardBindingsSupportedInGamepadUI()` returns `false`,
meaning the client never routes keyboard keys into the binding system. A `TopLevelControl` with
`keyboardEnabled="true"` and an `OnKeyDown` handler is the only other way Lua is handed a key,
and the game uses that pattern itself on a console-only screen (`ZO_ControllerDisconnect`).

Synthesising the controller combo instead is not possible either. Nothing in the API generates
input: the action and binding surface is read-only introspection plus action-*layer* push/pop.
And a synthesised press would not help, because the combo's action calls `StartChatInput`, which
is closed to add-ons -- see below.

## Why the open is roundabout

`StartChatInput("")` is what the game's own Start Chat binding calls, and add-ons cannot use it.
It reaches `ZO_GamepadChatSystem:StartTextEntry()`, which calls the **private** `SetSetting()` to
persist the chat HUD setting, and a *private* function cannot be called by add-on code at all --
not from a timer, and not from `OnKeyDown` either. The hardware-event rule that lets a keybind
reach a *protected* function does not extend to private ones.

The private call sits behind `if not dontShowHUDWindow`, so passing that flag is the only way in.
The flag also skips the work that puts the window on screen, which the add-on does itself:

| Skipped | Replacement |
| --- | --- |
| `SetSetting(UI_SETTING_GAMEPAD_CHAT_HUD_ENABLED)` | Dropped. `SetHUDEnabled(true)` still shows the chat for this session; only the saved setting is not rewritten |
| `Maximize()` / `FadeIn()` | Done here, same condition on `isMinimized` |
| `TakeFocus()` | Re-asserted after the window moves, as the game does |

Putting the window on screen is not cosmetic. A focused entry box with no window activates an
input eater (`DIRECTIONAL_INPUT:ConsumeAll`) and pushes the `GamepadChatSystem` action layer,
leaving nothing to dismiss and no working controller. `StartStuckWatchdog` notices that state --
entry open, window hidden, three seconds running -- and closes the entry to give the controller
back.

> `ESOUIDocumentation.txt` does not mark `SetSetting` private. The live client does. Where the
> two disagree, the client wins.

## Layout rules that matter on console

- Folder name, manifest filename and `addon.name` must all match exactly (`PBsChatAssistant`).
- PlayStation is case-sensitive: `PBsChatassistant` != `PBsChatAssistant`.
- The display name carries a typographic apostrophe (U+2019): `PB’s ChatAssistant`. The
  identifier deliberately does not -- it is plain ASCII so the folder, the manifest filename and
  `addon.name` can match byte for byte.

## Releasing

Console builds go through **Bethesda.net**, not ESOUI -- use the ZOS Console AddOn Uploader. The
name shown in the in-game browser comes from the uploader entry, not from `## Title`. To cut a
version, edit these two adjacent lines in `PBsChatAssistant.addon`, and `VERSION` in `Main.lua`,
which is what the login banner prints:

```
## Title: PB’s ChatAssistant 1.0.2
## Version: 1.0.2
```

---

This Add-On is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its
affiliates. The Elder Scrolls® and related logos are registered trademarks or trademarks of
ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.
