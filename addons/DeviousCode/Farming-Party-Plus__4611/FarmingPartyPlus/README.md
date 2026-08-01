<p align="center">
  <img src="https://i.imgur.com/r4HXQaC.png" alt="Farming Party Plus Banner">
</p>

<h1 align="center">Farming Party Plus</h1>

<p align="center">
  Cleaner farming, fishing, and loot tracking for <strong>Elder Scrolls Online</strong>
</p>

<p align="center">
  <a href="https://github.com/DeviousCode/FarmingPartyPlus"><strong>GitHub Repository</strong></a>
</p>

---

## About

**Farming Party Plus** is an ESO addon made for organized farming groups, guild events, fishing runs, and money-making sessions where you want a clean scoreboard instead of a wall of random drops.

The goal is simple: track the loot your group actually cares about.

Instead of relying only on item quality, **Farming Party Plus** lets you choose what counts for the run, save those setups, and reuse them later.

---

## Required Libraries

* [LibAddonMenu-2.0](https://www.esoui.com/downloads/info7-LibAddonMenu-2.0.html)
* [LibAsync](https://www.esoui.com/downloads/info2125-LibAsync.html)
* [LibPrice](https://www.esoui.com/downloads/info2204-LibPrice.html)

---

## Optional Library

* [LibGroupBroadcast](https://www.esoui.com/downloads/info1337-LibGroupBroadcast.html)

**LibGroupBroadcast** is only needed for fishing and gutting sync.

For sync to work, the other players also need:

* **Farming Party Plus**
* [LibGroupBroadcast](https://www.esoui.com/downloads/info1337-LibGroupBroadcast.html)

Without LibGroupBroadcast, **Farming Party Plus** still works normally for standard loot tracking.

---

## Main Features

* Tracks your own loot and group loot
* Shows a live farming scoreboard
* Shows a compact movable group-total scoreboard
* Shows per-player item breakdowns
* Logs loot to chat and the loot history window
* Supports whitelist mode for focused farming events
* Supports stolen-only tracking for thief runs
* Supports saved whitelist profiles across characters
* Supports recipe value filtering
* Supports market pricing through LibPrice
* Supports fishing and gutting tracking
* Can sync fishing and gutting state between clients when the other players also have Farming Party Plus and LibGroupBroadcast installed

---

## Whitelist Mode

Whitelist mode is the main feature for organized farming groups.

Instead of counting every item above a certain quality, you decide exactly which items count.

This is useful for:

* Ore runs
* Wood runs
* Cloth and leather runs
* Jewelry dust runs
* Alchemy routes
* Provisioning routes
* Furnishing material runs
* Fishing events
* Recipe farming

> When whitelist mode is enabled, only enabled items are counted.

## Stolen-Only Mode

Stolen-only mode is for thief runs where the group wants to compare who steals the most.

When stolen-only mode is enabled, Farming Party Plus counts stolen loot. Whitelist mode, minimum quality, gear, and motif filters are ignored while this mode is active.

For your own loot, Farming Party Plus checks recent backpack updates as a fallback because ESO can report a looted item without setting the loot event's stolen flag.

---

## Whitelist Categories

The whitelist window includes:

* Ore
* Logs
* Cloth & Leather
* Jewelry Dust
* Alchemy
* Enchanting
* Provisioning
* Fishing
* Furnishing Mats
* Recipes

Each category supports individual item toggles, plus quick **All On** and **All Off** options.

The **Logs** category uses the actual raw wood node drops, such as **Rough Maple** and **Rough Ruby Ash**, so it matches what players actually loot.

---

## Saved Whitelist Profiles

Whitelist setups can be saved and reused across characters.

This is helpful if your group swaps between different event types, such as fishing one night, ore farming another night, and furnishing material farming later.

Profiles can be:

* Saved
* Loaded
* Updated
* Deleted

If you are updating from an older version, it is a good idea to review your saved whitelist profiles and re-save them if anything looks outdated.

---

## Pricing Support

**Farming Party Plus** can use market data through **LibPrice**.

Supported market sources include:

* **Tamriel Trade Centre** by cyxui — **TTC**
* **Master Merchant** by Khaibit, Philgo68, and Sharlikran — **MM**
* **Arkadius' Trade Tools** by Arkadius, Verbalinkontinenz, and Aldanga — **ATT**

You can choose a preferred price source:

* Auto
* TTC
* MM
* ATT

When set to **Auto**, Farming Party Plus checks available sources in this order:

```text
TTC -> MM -> ATT -> Vendor
```

If your chosen price source is not available, Farming Party Plus will use the next source it can find, with vendor value as the backup.

Loot history can also show where a price came from, using labels like **TTC**, **MM**, **ATT**, or **Vendor**.

This only affects how prices are shown in chat and loot history.

---

## Fishing And Gutting

**Farming Party Plus** includes extra support for fishing and gutting sessions.

It can:

* Track caught fish
* Show stack-found history
* Subtract processed fish from totals
* Count Fish
* Count Perfect Roe
* Warn when ESO’s Auto-Add to Craft Bag may interfere with tracked fishing outputs

---

## Fishing And Gutting Sync

Fishing and gutting sync requires **Farming Party Plus** and **LibGroupBroadcast** on the players taking part in the sync.

Other players catching fish can still appear through normal group loot.

The sync feature is for the extra fishing-session details that happen after the catch, especially when fish are processed or gutted.

Sync can help with:

* Processed fish subtraction
* Fish
* Perfect Roe
* Stack replay after reset or late join
* Keeping fishing totals better aligned between clients

Remote Fish and Perfect Roe outputs are resolved locally on each receiving client, so pricing, whitelist checks, and loot-history lines stay consistent.

If another player is not running **Farming Party Plus** with **LibGroupBroadcast**, you can still see their caught fish, but their processing results will not sync. That means you will not see what they received from gutting, such as **Fish** or **Perfect Roe**, through Farming Party Plus sync.

---

## Commands

| Command              | Description                             |
| -------------------- | --------------------------------------- |
| `/fpp`               | Toggle the main scoreboard window       |
| `/fpp start`         | Start tracking                          |
| `/fpp stop`          | Stop tracking                           |
| `/fpp toggle`        | Toggle tracking on or off               |
| `/fpp status`        | Show current tracking state             |
| `/fpp reset`         | Reset all tracked loot data             |
| `/fpp update`        | Refresh party members                   |
| `/fpp filters`       | Open the whitelist window               |
| `/fpp loot`          | Toggle the loot history window          |
| `/fpp log`           | Toggle the loot history window          |
| `/fpploot`           | Toggle the loot history window          |
| `/fpp compact`       | Toggle compact scoreboard mode          |
| `/fpp whitelist on`  | Enable whitelist mode                   |
| `/fpp whitelist off` | Disable whitelist mode                  |
| `/fppc`              | Output current scores to the chat input |
| `/fpphelp`           | Print command help                      |
| `/fp`                | Legacy alias for `/fpp`                 |
| `/fpc`               | Legacy alias for `/fppc`                |

---

## Installation

Install the addon folder here:

```text
Documents\Elder Scrolls Online\live\AddOns\FarmingPartyPlus
```

The folder should be named:

```text
FarmingPartyPlus
```

---

## Updating From Older Versions

If you are updating from an older build:

* Reload the UI after updating
* Review older saved whitelist profiles
* Re-save profiles if old entries do not match what you expect

You should only need to delete SavedVariables as a last resort.

---

## Notes

* Minimum Item Quality is only used when whitelist mode is off
* Whitelist mode ignores the minimum item quality setting
* Stolen-only mode ignores whitelist and legacy quality/category filters
* Compact scoreboard mode shows a small movable group total; click the total text to open the full scoreboard
* Fishing outputs can be affected by ESO’s Auto-Add to Craft Bag setting
* The addon warns about Auto-Add to Craft Bag during fishing and gutting sessions
* Loot history can be shown separately from chat logging
* Group loot tracking depends on what the ESO API exposes to the host client

---

## Credits

Originally based on [Farming Party](https://www.esoui.com/downloads/info1822-FarmingParty.html), which was originally based on [Group Loot](https://www.esoui.com/downloads/info1027-GroupLoot.html) by Temeez.

Pricing support is intended to work with the ESO trading libraries commonly used by market addons.
