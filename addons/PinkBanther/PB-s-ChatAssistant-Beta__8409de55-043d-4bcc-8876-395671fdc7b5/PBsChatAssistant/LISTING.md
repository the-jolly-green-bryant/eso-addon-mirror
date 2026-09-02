# Store listing copy — PB's ChatAssistant 1.0.3

Text for the ZOS Console AddOn Uploader. Plain text, no markup, so it survives whatever the
uploader does to it.

---

## Overview

Press Enter to start chatting. On console the chat window only opens from the controller, so
every message means letting go of the keyboard and reaching for the pad. This opens it from the
keyboard instead — and brings up the console's text input screen with it, which is what makes
Japanese input possible.

---

## Description

On console, a USB keyboard lets you type a message but not start one. The chat window opens only
from the controller (Options + touchpad on PlayStation), and opening it that way is also what
raises the console's own text input screen — the one that provides kana-to-kanji conversion.
Without it there is no Japanese, only romaji. So every single message costs you a round trip:
let go of the keyboard, pick up the controller, put it down again.

PB's ChatAssistant closes that gap.

WHAT IT DOES

- Press Enter and the chat window opens, with the console's text input screen up and ready.
- Open the chat window however you like — the controller combo included — and the input screen
  comes up for it anyway. That part works on its own, all the time, with nothing to arm.
- Type Japanese the way you would anywhere else on the console, and send.

ABOUT THE CONTROLLER

Listening for the Enter key requires the add-on to hold keyboard focus, and while it does, the
controller's buttons are paused. The analogue sticks keep working.

This is short-lived by design. Arming Enter is a deliberate act, and the add-on stands down the
moment the input screen appears — so the buttons are back before you have typed a word, and stay
back while you send the message and after.

  /pbchat enter   Arm Enter. Buttons pause until the input screen comes up.
  /pbchat safe    Stand down now. Buttons work; open chat from the controller as usual.

You can leave it in "safe" and never arm Enter at all. The input screen still appears every time
you open the chat window from the controller, which on its own removes most of the friction.

SETTINGS

  /pbchat              Show current state
  /pbchat delay <ms>   Pause before the window opens, 0-5000, default 100
  /pbchat enter        Arm the Enter key
  /pbchat safe         Stand down; controller buttons work
  /pbchat autosafe off Keep Enter armed instead of standing down automatically
  /pbchat watch off    Stop raising the input screen automatically
  /pbchat on | off     Master switch

ABOUT THE DELAY

The console raises its text input screen when the chat box takes keyboard focus fresh — not when
it is handed focus in the same instant something else gave it up. The add-on therefore pauses
briefly before opening the window. That pause is how the input screen is earned, not a safety
margin, and how long it needs to be depends on your console's frame timing. If the chat window
opens but the input screen does not follow, the pause is too short for your machine: raise it
with /pbchat delay 300, then 500.

NOTES

- Built and tested for console. On PC, bind a key to Controls -> PB's ChatAssistant -> Open Chat.
- No dependencies.
- /pbchat reports the running version and settings.

---

This Add-On is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its
affiliates. The Elder Scrolls and related logos are registered trademarks or trademarks of
ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.
