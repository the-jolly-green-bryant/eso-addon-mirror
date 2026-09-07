# Platform findings — ESO on console (PS5)

What was measured on the way to this add-on, and what each measurement rules in or out. Almost
none of it is written down anywhere else, and several entries contradict `ESOUIDocumentation.txt`.

Kept as a separate file so the README can stay short. Where a conclusion was later overturned,
the overturning is recorded too, because the wrong turn is usually the useful part.

---

## The console's text input screen (IME)

**It cannot be summoned.** `IsVirtualKeyboardOnScreen()` and `DoesCurrentLanguageRequireIME()` are
read-only, and `SetVirtualKeyboardType()` only picks a layout for a control the platform has
already decided to serve.

**It appears when the chat edit control loses focus and takes it again**, a frame or more later.
Opening the box in the same frame as the key press gives the platform no loss to react to, and the
screen stays down. Measured: opened immediately, `edit focus true` with `input screen false`, still
false a second later; opened after a wait, the screen comes up.

**It is not gated on the input device.** The same measurement was repeated without touching the
controller at all and the screen still came up. `delayMs` is therefore a real mechanism, and how
long it needs to be is a property of the machine.

**It takes the keyboard entirely while it is up.** With a key catcher confirmed shown in the log,
not one key arrived. This rules out anything that depends on reading keys during composition.

## Restricted functions

**Add-on Lua is insecure code by its nature.** One add-on frame taints the callstack, so a
restricted function is unreachable from every calling context — timer, game event, slash command,
XML `OnKeyDown`. There is no clever caller to find.

Proven with `BindKeyToAction`, called from a slash command whose traceback bottoms out in
`ZO_GamepadTextChatTextEntryEditBox_Enter` — a real key press. It still failed, naming the add-on's
own two frames as what made the callstack untrusted.

**The documentation's markers are unreliable.**

| Function | Documented | Actual |
| --- | --- | --- |
| `SetSetting` | unmarked | private |
| `BindKeyToAction` | *protected* | private |
| `IsKeyDown` | *private* | private |

**The workaround, when there is one, is to find the flag that skips the restricted call.**
`ZO_GamepadChatSystem:StartTextEntry` calls the private `SetSetting` only when `dontShowHUDWindow`
is false, so passing it skips the call — and the add-on then does the window work that flag also
skipped. That is how the chat box is opened at all.

## Keyboard input

**Keyboard keys never reach the binding system on console.**
`AreKeyboardBindingsSupportedInGamepadUI()` returns false, so `Bindings.xml` cannot fire from a
keyboard key however it is bound.

**A `TopLevelControl` with `keyboardEnabled="true"` does receive them.** Enter arrives as key 3
with `IsKeyCodeKeyboardKey()` true. The game uses this pattern itself on a console-only screen,
`ZO_ControllerDisconnect`.

**While one is shown it pauses every gamepad button**, on all four tiers tried (`default`, `high`,
`medium`, `low`), leaving the sticks alive. It receives no gamepad keys at all, so nothing is being
swallowed by the handler: the buttons go to the UI instead of to the gameplay bindings simply
because a control is up and wants input. Sticks survive because `DIRECTIONAL_INPUT` is a separate
path.

**While one is shown the input screen will not appear.** With a catcher up, even the open that had
worked minutes earlier with nothing shown stopped producing the screen. It evidently holds the
engine's keyboard focus, so the chat edit control taking focus is not what the platform sees. Hence
the catcher stands down at the *start* of the wait and stays down across the open.

## Gamepad input

**`WasLastInputGamepad()` is useless on console.** It answers "gamepad" immediately after a whole
slash command has been typed on the keyboard.

**`EVENT_INPUT_TYPE_CHANGED` fires, but only on a change.** A run of key presses produces one event
and then silence, so it cannot drive anything that needs to see every press.

**PS5 has no keybinding screen.** There is no Controls entry under Options, so actions declared in
`Bindings.xml` have nowhere to be bound by hand. They do register: `/pbchat binds` finds them at
1/7/1..3.

**An add-on cannot bind anything.** `CreateDefaultActionBind` does nothing, tried from
`EVENT_ADD_ON_LOADED` and again at file scope from a file loaded straight after `Bindings.xml`.
`BindKeyToAction` is refused as private, from everywhere.

**The D-pad cannot be read.** `DIRECTIONAL_INPUT`'s D-pad reader is built out of the private
`IsKeyDown`, so asking for `ZO_DI_DPAD` throws — once per frame, which is far worse than not
working. The stick readers go through `GetGamepadOrKeyboardLeftStickX`, which is unmarked and was
never tried.

**Gamepad chords are a fixed list of twenty `KEY_GAMEPAD_BOTH_*` codes.** They are not
key-plus-modifier the way keyboard chords are — binding modifiers are ctrl, alt, shift and command
only, so a gamepad button can never stand in as one. **L2 + L3 is not in the list.**
`KEY_GAMEPAD_BOTH_SHOULDERS` (L1 + R1) is key 147. `KEY_GAMEPAD_BOTH_TOUCHPAD_START` is the
touchpad-plus-Options chord that opens chat on console.

### …and how all of that was got round anyway, in 1.8.0

Everything above was true and the conclusion drawn from it — "no gamepad route exists on PS5" —
was **wrong**. Two assumptions were doing the damage, and neither was ever tested.

**That an action needs somewhere to be bound.** It does not, if it inherits a bind that already
exists. `inheritsBindFrom="UI_SHORTCUT_LEFT_STICK"` and `"UI_SHORTCUT_LEFT_TRIGGER"` give actions
that arrive already bound to L3 and L2, so the missing keybinding screen stops mattering. The game
does this itself: `UI_ERROR_PAGE_LEFT` is `hideAction` plus `inheritsBindFrom` on the same trigger.
The attribute was in Votan's Minimap's `Bindings.xml`, read on the first day of this project.

**That a chord has to be a key code.** It does not, if it is never treated as one. Two actions
observe L2 and L3 separately and the combination is composed in Lua, latched so it fires once per
press. The twenty-code list stops mattering too.

Scoping keeps it from disturbing anything: a custom layer carried by a `ZO_ActionLayerFragment` on
the `hud` scene, `allowFallthrough="true"`, handlers returning false, so L2 and L3 keep their own
jobs. Analog triggers do not report Up reliably, so `GetGamepadLeftTriggerMagnitude()` is polled to
clear the latch.

A third assumption was made and corrected the same way in 1.8.1: that the HUD loop could be slowed
from 10ms to 100ms because nothing in it needs a frame. The interval is what decides how long the
chord stays latched after the trigger is released, so at 100ms a second chord arriving sooner than
that is swallowed — which is exactly how fast someone walks through channels. Reported from play,
and settled at 50ms. The per-tick cost that prompted the change was real and was fixed where it
actually lived: the label is built only when the channel changes, and the trigger is read only
while a press is outstanding.

### …and why it was withdrawn again, in 1.9.0

It shadowed **L2 on the HUD**, so blocking stopped working. `allowFallthrough="true"` with handlers
returning `false` keeps a layer from *consuming* the input, and that was assumed to mean the game's
own L2 would still fire underneath. It does not: an inherited bind in a pushed layer takes
precedence over the gameplay action on the same button, fallthrough or not.

Which leaves the technique sound and the choice of buttons wrong. Reviving it means finding buttons
the HUD does not need — and note that anything reachable through `inheritsBindFrom` is, by
definition, a button the game already uses somewhere.

**The lesson worth keeping:** every entry above is a measurement, and measurements are sound. The
sentence that was wrong was the one that generalised from them without being measured itself.

## Add-on mechanics

- A `Print()` at `EVENT_ADD_ON_LOADED` is discarded — the chat system is not up yet. Anything that
  must be seen at startup belongs on `EVENT_PLAYER_ACTIVATED`.
- `ESOUIDocumentation.txt` and the client's own Lua are at `github.com/esoui/esoui`, branch `live`.
  The uesp mirrors return 403 to scripted fetches.
- Folder name, manifest filename and `addon.name` must match exactly, and PlayStation is
  case-sensitive.
