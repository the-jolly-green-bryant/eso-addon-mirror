# Quartermaster

Account-wide inventory index for The Elder Scrolls Online with per-item and
per-set "hold" reservations. Reserve an item from any character; the addon
auto-routes it through whichever shared container (account bank, guild bank,
or house storage) the holder character opens next.

## Status

Implementation per `c:\Users\nickwhite\.claude\agents\AccountHold.brief.md`,
including the Phase 2 amendments. Awaiting in-game verification.

## Target platforms

* PC / Mac
* Xbox Series X/S
* PlayStation 5

PS5 requires case-sensitive filenames; everything in this folder ships
case-correct as written. Do not lowercase anything.

## Before you ship

1. **Update `## APIVersion:` in `AccountHold.addon`** to the current live
   (and PTS, if dual-targeting) values from
   <https://wiki.esoui.com/APIVersion>.
2. **(Optional) Install or embed LibHarvensAddonSettings.** The addon runs
   without it; only the in-game settings panel is suppressed. It is resolved
   as a global at call time, so LHAS installed as its own standalone add-on
   satisfies it — including on Xbox and PS5, where it is available from the
   Bethesda.net add-on catalogue. See `lib/README.md` to embed a copy instead.
3. **PC test pass first.** PC has Lua errors in a window and the chat
   `/script d(...)` debug path; console has neither. Test on PC, then port.

## Install / distribute

| Platform | Path / Process |
| --- | --- |
| Windows | `%USERPROFILE%\Documents\Elder Scrolls Online\live\AddOns\AccountHold\` |
| Mac | `~/Documents/Elder Scrolls Online/live/AddOns/AccountHold/` |
| Xbox Series X/S | Upload via [ESOAddOnUploader](https://esosslfiles-a.akamaihd.net/addon/ESOAddOnUploader.zip), publish to Bethesda.net, install in-game from the Add-Ons menu. |
| PlayStation 5 | Same as Xbox. ZOS does not QA addons; you own all support. See <https://help.elderscrollsonline.com/#en/answer/69621>. |

## File map

```
AccountHold/
  AccountHold.addon              -- manifest (replaces deprecated .txt)
  AccountHold.lua                -- namespace, lifecycle, SV wiring, WipeData
  config/
    FeatureAccess.lua            -- maintainer-edited access data (see below)
  src/
    Platform.lua                 -- IsConsoleUI / settings backend chooser
    Features.lua                 -- per-feature access gates (Epic 0001)
    Scanner.lua                  -- container scans + slot diffs
    Index.lua                    -- account index, gear-only query, change cb
    Holds.lua                    -- hold state machine + retention + CancelAll
    Mover.lua                    -- RequestMoveItem + safety guards
    Notify.lua                   -- chat + center-screen notifications
    Input.lua                    -- keystrip descriptors (no Bindings.xml)
  ui/
    AccountHold.xml              -- AccountGearPanel + BankPanel templates
    InventoryTab_Keyboard.lua    -- 3rd inventory tab "Account Gear" (PC)
    InventoryTab_Gamepad.lua     -- equivalent gamepad scene + keystrip
    HoldDialog.lua               -- place-hold dialog (item + set holds)
    BankActionPanel.lua          -- in-bank deposit/withdraw panel
    Settings.lua                 -- LHAS panel + 3 wipe-data buttons
  localization/
    en.lua                       -- string table
  lib/
    LibHarvensAddonSettings/     -- (optional, NOT bundled) embed here, or let
                                 --   a standalone LHAS install satisfy it
```

The addon adds a third tab — "Account Gear" — to the keyboard inventory
window alongside Inventory and Craft Bag. On gamepad, the **Inventory**
header gains a third **Quartermaster** tab (after Items and Craft Bag) that
opens a dedicated blade. There is no PC keybind and no Bindings.xml;
everything is reachable from inside the standard game UI.

## Access gates: adding testers / rolling out features

All access is controlled from **one file**: `config/FeatureAccess.lua`. It is
plain Lua (ESO loads Lua natively — no JSON parser is added). Edit it, save,
and `/reloadui` on PC.

To start a private beta, add tester handles to the whole-add-on allowlist:

```lua
addon = {
    mode  = "allowlist",
    allow = {
        "@noobuddy",
        "@Gamer Tag",   -- Xbox gamertag with an internal space, kept exactly
    },
},
```

Matching rules (whole-add-on and per-feature alike):

* The leading `@` is **optional** (`@noobuddy` == `noobuddy`).
* Matching is **case-insensitive**.
* Surrounding whitespace is **trimmed**; **internal spaces are preserved**, so
  an Xbox gamertag `Gamer Tag` (ESO decorates it as `@Gamer Tag`) must be
  written with its space intact.
* ⚠ The gamertag/handle **is** the key: if a tester renames their Xbox
  gamertag, update their entry — there is no stable numeric id for an add-on.

Semantics you must know:

* **Whole-add-on gate** — an empty (or absent/malformed) allowlist is **open**
  so you are never locked out; add names to enforce. `mode="off"` disables the
  whole add-on for everyone (a deliberate kill-switch).
* **Per-feature gate** — an empty allowlist **denies everyone** (safe rollout).
  Features only appear once their module is implemented in code
  (`src/Features.lua` registry `available=true`); the three planned features
  ship off.

> These allowlists are a **rollout/UX control, not security**. This file ships
> as readable source with the add-on; anyone can read or edit it. Never treat a
> client-side gate as an entitlement or license check.

## Xbox / PS5 quick reference

On console the entry point is a **third tab in the gamepad Inventory
header** — it appears after Items and Craft Bag. (Earlier builds attached
the entry to the inventory scene's tertiary/Y keybind slot, which
collided with a keybind that scene already owned and crashed the game.
The tab approach adds no keybind at all: it wraps
`ZO_GamepadInventory:GetTabBarEntries` and appends a header tab whose
callback shows our blade when the player scrolls onto it. The append is
error-hardened so it can never break the inventory header.) To use the
addon on Xbox / PS5:

1. Press **Start** and open **Inventory**.
2. Scroll the top header tabs (RB) to the **Quartermaster** tab — it is the
   last tab, after Items and Craft Bag.
3. The blade shows every item the addon has scanned across all
   characters / banks / guild banks / house storage.
4. Use the per-row keybinds to reserve / cancel a hold: **A** reserves the
   highlighted item, **X** reserves the whole set (when the row carries one),
   **Y** cancels the matching hold, and **B** backs out. Use **Show recent
   diagnostics** to print init / scene / dialog history to chat — this
   is the console equivalent of `/script d(...)` for diagnosing why
   something didn't show up.
5. Use **Wipe All** (with confirm dialog) to reset corrupt scan data.
   This is the only console-reachable wipe surface when LHAS is not
   installed.

A first-load chat banner reminds the player how to reach the tab.

### What if nothing shows up after install?

1. Open Inventory once. The diagnostics ring buffer records "AccountHold
   v… initialized" plus a line for each module. Look for any line
   tagged `[error]` or `[warn]` — these are printed in red / yellow.
2. From the gear scene's keystrip, choose **Show recent diagnostics**
   to dump the full history to chat.
3. If the banner says the gamepad inventory root scene was not found,
   the addon is loaded but the gamepad inventory module is unavailable
   on this build — `/reloadui` and try again.

## Console testing on PC

Set `ForceConsoleFlow.2 = 1` in
`Documents/Elder Scrolls Online/live/UserSettings.txt` to exercise the
gamepad flow on PC.

## Out of scope (v1)

* Armory loadout integration ("hold all of slot 3 of <character>")
* Cross-account or guild-trader integration
* Snapshot diff history
* Item value / gold-cost awareness

## Out of scope (always)

* Last-gen consoles (Xbox One, PS4) — ZOS does not support addons there.
* Any non-UI game change.
* Hand-edited SavedVariables recovery flows. Console players cannot edit
  SV files; all migrations must be automatic and live in
  `AccountHold:UpgradeSavedVars()`.
