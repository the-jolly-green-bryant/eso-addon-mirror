# PB’s ChatAssistant

Opens the chat entry box on **The Elder Scrolls Online, console (PS5 / Xbox Series X|S)** from a
keyboard key instead of the controller.

- **Author:** PinkBanther

## Why this exists

With a USB keyboard plugged into the console you can type a message, but you cannot *start* one.
The chat entry box only opens from the controller (Options + touchpad on PS5), and opening it is
what makes the console put its own text input screen up -- the Japanese IME included. Every
message means letting go of the keyboard, reaching for the pad, and coming back.

Press Enter, the box opens, the console's input screen comes up.

## Status: blocked

The add-on ships **inert** -- `capture off`, so it loads and does nothing. What is known so far,
all measured on PS5:

| Question | Answer |
| --- | --- |
| Can a keyboard key reach add-on Lua? | **Yes**, via a shown key catcher. Enter arrives as key 3 |
| Can a keyboard key reach a *binding*? | **No**. `AreKeyboardBindingsSupportedInGamepadUI()` is false |
| Can the add-on open the chat entry box? | **Yes**. `entry open true, edit focus true` |
| Does the console's input screen come up? | **No**. `input screen false`, immediately and a second later |
| Is a shown catcher safe to leave up? | **No**. Every gamepad *button* dies; the sticks keep working |

The last two are what block the add-on, and they are independent of each other.

The catcher does not receive gamepad keys at all -- a probe saw only the keyboard's Enter -- so
the buttons are not being swallowed by the handler. Their events go to the UI instead of to the
gameplay bindings simply because a control is up and wants input. Sticks survive because
`DIRECTIONAL_INPUT` is a separate path.

### Why the input screen cannot just be asked for

There is no Lua call that summons it. `IsVirtualKeyboardOnScreen()` and
`DoesCurrentLanguageRequireIME()` are read-only queries, and `SetVirtualKeyboardType()` only
chooses a layout for an edit control that the platform has already decided to serve. The screen
is the platform's own response to the chat edit control taking focus, and with focus confirmed
true it still declined.

### Why the controller combo cannot be emulated

Nothing in the API synthesises input. The action and binding surface is read-only introspection
(`GetActionInfo`, `GetActionBindingInfo`, `GetActionNameFromKey`, ...) plus action-*layer*
push/pop, which changes which bindings are live rather than pressing one. There is no
Simulate/Press/Send/Inject anything.

And a synthesised press would not help by itself: Options + touchpad is bound to an action that
calls `StartChatInput`, which reaches the private `SetSetting`. A real press works only because
the engine runs it on its own trusted path -- the one place add-on code can never be.

## Measuring it

```
/pbchat test           -- open the box now, and report focus / input screen / last input device
/pbchat test 5         -- same, 5 s later, so the gamepad can be made the last input device
/pbchat trial high     -- 20 s with a live HIGH-tier catcher, then off by itself
/pbchat probe          -- 15 s, report what keys reach a tier without leaving it on
```

`/pbchat test <seconds>` exists to separate two explanations for the input screen not appearing:
the platform gating it on the last input device (a keyboard user has no need of an on-screen
keyboard), or gating it on who took the focus. Press a controller button during the countdown
and keep off the keyboard; if the screen appears that way and not otherwise, it is the former.

The probe reports keyboard and gamepad keys apart. Gamepad keys arriving at a tier is the
evidence for problem 1. It clears itself after 15 seconds either way, so a tier that swallows
input cannot strand the session.

If a tier turns out to take keyboard keys without taking gamepad ones, that is the tier to use:

```
/pbchat capture default
/pbchat capture high
```

On PC, where keyboard bindings work, none of this applies -- bind **Controls -> PB’s
ChatAssistant -> Open Chat** instead.

## Why there is no delay, and why the open is roundabout

The first cut waited before opening -- 100 ms, then 500 ms -- so the live key press could not
leak into the box that had just taken focus. Then the wait was dropped and the call made
synchronous from the key press. Neither works, and the reason is the same both times.

`StartChatInput("")` reaches `ZO_GamepadChatSystem:StartTextEntry()`, which calls the **private**
`SetSetting()` to persist the chat HUD setting. A *private* function cannot be called by add-on
code **at all**. The hardware-event rule that lets a keybind reach a *protected* function does
not extend to private ones, so calling it straight out of `OnKeyDown` fails exactly as calling it
from a timer did:

```
Attempt to access a private function 'SetSetting' from insecure code.
```

The private call sits behind `if not dontShowHUDWindow`, so passing that flag is the only way an
add-on can open the box on console at all. The flag also skips the work that puts the window on
screen, which the add-on then has to do itself:

| Skipped | Replacement |
| --- | --- |
| `SetSetting(UI_SETTING_GAMEPAD_CHAT_HUD_ENABLED)` | Dropped. `SetHUDEnabled(true)` still shows the chat for this session; only the saved setting is not rewritten, which is better behaviour from an add-on anyway |
| `Maximize()` / `FadeIn()` | Done here, same condition on `isMinimized` |
| `TakeFocus()` | Re-asserted after the window moves, as the game does |

Putting the window on screen is not cosmetic. A focused entry box with no window activates an
input eater (`DIRECTIONAL_INPUT:ConsumeAll`) and pushes the `GamepadChatSystem` action layer,
leaving nothing to dismiss and no working controller. `StartStuckWatchdog` notices that state --
entry open, window hidden, three seconds running -- and closes the entry to give the controller
back.

> There is no Lua call that summons the console's input screen. `IsVirtualKeyboardOnScreen()` is
> read-only, and the screen is the platform's own response to the chat edit control taking focus.
> That is the whole reason the focus has to be reached through the game's own path.

## Commands

| Command | Effect |
| --- | --- |
| `/pbchat` | Status, plus the platform flags that decide which route can work |
| `/pbchat probe [default\|high]` | Report every key that reaches that tier, for 15 seconds |
| `/pbchat trial [default\|high]` | Turn a catcher on for 20 seconds, then off again by itself |
| `/pbchat capture auto\|off\|default\|high` | Which tier catches Enter. `off` is the default |
| `/pbchat unstick` | Force the chat entry closed, giving the controller back |
| `/pbchat on` / `off` | Enable or disable without changing the capture tier |
| `/pbchat test` | Open the box now and report entry / focus / input-screen state |

`/pbchat test` reports whether the box opened. Nothing on that path is private or protected, so
it no longer matters where it is called from -- which is what makes it a fair test of the open on
its own.

## Getting the key press

Two routes exist for a key press to reach add-on Lua.

**Binding.** `Bindings.xml` declares `PBSCHATASSISTANT_START_CHAT` with
`preventAutomaticInputModeChange="true"` -- the attribute the game's own `START_CHAT_ENTER`
carries, without which a keyboard key press flips the UI out of gamepad-preferred mode and, on
console, swaps the entire interface. This is the sanctioned route and the only one on PC.

On console it is dead. `AreKeyboardBindingsSupportedInGamepadUI()` returns `false` there, which
means the client never routes keyboard keys into the binding system. Nothing an add-on does
changes that. The action is still declared, because it costs nothing and is the correct route
wherever it does work.

**Catcher.** A `TopLevelControl` with `keyboardEnabled="true"` and an `OnKeyDown` handler, kept
shown so the engine hands it key events. The game uses this pattern itself on a console-only
screen (`ZO_ControllerDisconnect`), and gamepad buttons and keyboard keys share one `KeyCode`
space, so the handler sees both. Whether a USB keyboard on console reaches such a control, and
at which tier, is an engine decision that is not readable from the UI source -- hence the probe.

**Measured on PS5:** the default tier receives keyboard keys. Enter arrives as key 3 with
`IsKeyCodeKeyboardKey()` true. The HIGH tier was never needed; it is kept as the thing to probe
if a client update ever moves this.

`capture auto` picks the catcher exactly when the binding route is dead, which is the condition
that makes a catcher necessary in the first place. That is why console gets one and PC does not,
without either being hardcoded.

Neither catcher pushes an action layer, so neither blocks gamepad actions. Both are 1x1,
untextured, and start hidden; a hidden control receives nothing.

## Layout rules that matter on console

- Folder name, manifest filename and `addon.name` must all match exactly (`PBsChatAssistant`).
- PlayStation is case-sensitive: `PBsChatassistant` != `PBsChatAssistant`.
- The display name carries a typographic apostrophe (U+2019): `PB’s ChatAssistant`. The
  identifier deliberately does not -- it is plain ASCII so the folder, the manifest filename and
  `addon.name` can match byte for byte.

## Releasing

Console builds are distributed through **Bethesda.net**, not ESOUI -- use the ZOS Console AddOn
Uploader. The name shown in the in-game browser comes from the uploader entry, not from
`## Title`. To cut a new version, edit these two adjacent lines in `PBsChatAssistant.addon` and
nothing else:

```
## Title: PB’s ChatAssistant 2.2.0
## Version: 2.2.0
```

---

This Add-On is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its
affiliates. The Elder Scrolls® and related logos are registered trademarks or trademarks of
ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.
