# PB's LuaMemoryMonitor

Shows how much memory each add-on uses, ranked in a window on the HUD, so the heavy ones can
be found — in The Elder Scrolls Online on console.

- **Author:** PinkBanther
- **Version:** 0.4.0
- **Optional:** `LibHarvensAddonSettings` >= 20106 (for the settings panel; the chat commands
  work without it)

## What it shows

The game keeps no per-add-on memory figure: every add-on runs in the one Lua state the UI
uses, and only totals can be read. So the figures are derived:

| Column | | |
| --- | --- | --- |
| **Held (est.)** | estimated | The tables and strings reachable from the add-on's globals, counted once each. Rescanned every minute while the window is up. |
| **Change** | estimated | Held now minus held at the first scan of the session — which add-on keeps growing. |
| **Saved vars** | measured | Heap growth while the game loaded the add-on's saved variables, just before its load event. |
| **Start-up** | measured | Heap growth during the add-on's own load event (its `OnAddOnLoaded`). |

The window's header shows the console add-on memory (what `/addonmem` shows) against its limit.

The ranking adds up to that add-on memory. Under the add-ons, three rows close the account:

| Row | |
| --- | --- |
| **File loading (not per add-on)** | The add-on memory when the first load event fired. The game runs every add-on's files — their code and what they build at file scope — before any event, so this cannot be split per add-on. Measured. |
| **Other** | The rest: the add-on memory now, less file loading and every add-on's held figure. Garbage not yet collected, data kept only in local variables, controls and textures, and the estimates' own error. A remainder, so it can go below zero if the estimates run high. |
| **Total** | The add-on memory now. |

**Not counted:** data an add-on keeps only in local variables, its code, and its controls.
A global is attributed to an add-on if it appeared at that add-on's load event, or else if its
name contains the add-on's name, so an add-on whose globals are named otherwise (LibLazyCrafting
uses `LLC_`) shows less than it holds.

## Settings

With LibHarvensAddonSettings installed, the add-on has a panel under the add-on settings:

| | |
| --- | --- |
| **Show the window** | Same as `/pbmem`. |
| **Sort by** | Held, Change, Saved vars or Start-up. |
| **Measure held memory again** | While the window is shown: off, every 30 s, every minute (default) or every 5 minutes. |
| **Message at login** | The chat line saying the add-on is loaded. |
| **Distance from the left / top** | Where the window sits; **Reset** puts it back at the left, centred. |
| **Background opacity** | 0–100 %. |
| **Free memory regularly** | Runs Lua's garbage collector in full: off (default), every minute, 5 or 10 minutes. Each run stalls the game for a moment (74 ms measured on a PS5). |
| **Also during combat** | Off (default): a run that falls in combat waits until combat ends. |
| **Free memory now** | Same as `/pbmem gc`; says in chat how much it gave back. |
| **Measure held memory now**, **Next page of the ranking** | Same as `/pbmem scan` and `/pbmem next`. |

The window is drawn on the HUD, not in menus, so changes show on returning to the game.

## Commands

| | |
| --- | --- |
| `/pbmem` | Show or hide the window. |
| `/pbmem scan` | Measure the held memory again now. |
| `/pbmem sort [held\|change\|sv\|init]` | Choose the order; with nothing after it, move to the next order. |
| `/pbmem next` | Next page (15 add-ons a page). |
| `/pbmem detail <name>` | In chat: which globals make up an add-on's figure, largest first. |
| `/pbmem gc` | Free memory now (a full garbage collection), and say how much it gave back. |

`/pbluamem` is the long form of `/pbmem`.

## Tests

```
lua test/run.lua
```
