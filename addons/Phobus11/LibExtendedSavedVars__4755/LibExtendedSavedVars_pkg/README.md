# LibExtendedSavedVars

A library to manage addon settings across three scopes — per character, per account, and per megaserver — with runtime switching between them and simple, non-destructive versioned migrations.

[TOC]

## Should I Use LibExtendedSavedVars?

Neither the built-in `ZO_SavedVars` nor [`LibSavedVars`](https://www.esoui.com/downloads/info1636-LibSavedVars.html) can share data across different `@AccountName` logins on the same PC — both always partition saved vars by account, even in their "account-wide" modes. `LibExtendedSavedVars` adds a genuine third scope that isn't partitioned by account at all:

- **Character** — this specific character only.
- **Account** — shared by every character on the current `@account`.
- **MegaServer** — shared by *every* account and character that has used the addon on this world/PC.

If you just need the first two scopes and don't need the third, `LibSavedVars` is more mature and has more features (renaming/removing settings during migration, defaults trimming, `pairs()`/`ipairs()` looping support). `LibExtendedSavedVars` is a smaller, focused library for the specific case where a MegaServer-wide scope is the point.

## How Easy Is LibExtendedSavedVars to Use?

Just as easy as `ZO_SavedVars` — one constructor call, then read and write settings as plain table fields.

## Installation

Add [`## DependsOn: LibExtendedSavedVars`](https://wiki.esoui.com/Addon_manifest_(.txt)_format#DependsOn) to your addon manifest. No need to bundle the library with your addon.

## Setup

Create a `## SavedVariables` entry in your addon manifest if you don't already have one:

###### MyAddon/MyAddon.addon (manifest file example)

```ini
## Title: My Cool Addon
## Author: YourName
## Version: 1.0.0
## APIVersion: 101050
## DependsOn: LibExtendedSavedVars LibAddonMenu-2.0
## SavedVariables: MyAddon_Data
```

Inside an [event handler](https://wiki.esoui.com/Events#Introduction) for `EVENT_ADD_ON_LOADED`, create the tiered settings object:

```lua
MyAddon.settings = LibExtendedSavedVars.NewTieredSavedVars(
    "MyAddon_Data",                     -- savedVariableTable: matches the ## SavedVariables: entry above
    1,                                  -- version: reserved for future use, pass 1
    "Settings",                         -- namespace: separates this instance from others sharing the same table
    MyAddon.Defaults,                   -- defaults: table of default values
    LIBEXTENDEDSAVEDVARS_SCOPE_CHARACTER -- defaultScope: which scope a first-time player starts on
)
```

That's it — `MyAddon.settings` now behaves like a normal settings table, backed by whichever scope is currently active.

## Scope Constants

```lua
LIBEXTENDEDSAVEDVARS_SCOPE_CHARACTER  = 1
LIBEXTENDEDSAVEDVARS_SCOPE_ACCOUNT    = 2
LIBEXTENDEDSAVEDVARS_SCOPE_MEGASERVER = 3
```

## Saved Variable Reading and Writing

Reading and writing values works just like a normal `ZO_SavedVars` instance. The following examples assume your saved vars data object is accessible via `addon.settings`.

### Reading a saved var value

```lua
local setting1 = addon.settings.setting1
-- OR --
local setting1 = addon.settings["setting1"]
```

### Writing a saved var value

```lua
addon.settings.setting1 = value
-- OR --
addon.settings["setting1"] = value
```

Nested tables (e.g. `addon.settings.myList[3]`) are returned by reference from whichever scope is active, so mutating them in place works exactly as it would with plain `ZO_SavedVars`.

## Switching Scopes

### `:GetScope()`

Returns the currently active scope constant for the logged-in character.

### `:SetScope(scope)`

Switches the active scope for the logged-in character. Any setting still at its default value in the *new* scope is filled in from whatever the *previous* scope currently held, so switching scopes doesn't silently discard values the player already configured. Returns `self`, so it's chainable.

```lua
addon.settings:SetScope(LIBEXTENDEDSAVEDVARS_SCOPE_ACCOUNT)
```

The active scope choice itself is always stored per-character — each character independently decides which scope it looks at, the same way you might want one alt following the account defaults while another stays fully customized.

## Versioning / Upgrading

### `:Version()`

Chainable. Runs `onVersionUpdate(rawDataTable)` once against each of the three scopes' raw tables when that table's own recorded version is below the given number. Has no effect on a table already at or above that version.

- *version* `number`: the table is only upgraded if its recorded version is below this number.
- *onVersionUpdate* `function`: transform function with the signature `function(rawDataTable) end`.

```lua
local version2, version4

addon.settings = LibExtendedSavedVars.NewTieredSavedVars("MyAddon_Data", 1, "Settings", MyAddon.Defaults)
                                     :Version(2, version2)
                                     :Version(4, version4)

function version2(rawDataTable)
    -- v2 transformation logic goes here
end

function version4(rawDataTable)
    -- v4 transformation logic goes here
end
```

## LibAddonMenu-2 Integration

`LibExtendedSavedVars` has a helper method to create the "Settings Scope" dropdown in your LibAddonMenu-2 panel, localized for English, French, German, Japanese and Russian, mirroring `LibSavedVars:GetLibAddonMenuAccountCheckbox()`.

The following example assumes your saved vars data object is accessible via `addon.settings`:

```lua
local optionsTable = {

    -- Settings scope dropdown
    addon.settings:GetLibAddonMenuScopeDropdown(),

    -- other LAM2 setting options....
}

LibAddonMenu2:RegisterOptionControls(addon.name .. "Options", optionsTable)
```

If you'd rather build your own control (a different widget type, custom wording, etc.), `:GetScope()`/`:SetScope()` are the only two calls the built-in dropdown itself relies on:

```lua
{
    type    = "dropdown",
    width   = "full",
    choices = { "Character-Specific", "Account-Wide", "MegaServer-Wide" },
    choicesValues = { LIBEXTENDEDSAVEDVARS_SCOPE_CHARACTER, LIBEXTENDEDSAVEDVARS_SCOPE_ACCOUNT, LIBEXTENDEDSAVEDVARS_SCOPE_MEGASERVER },
    name    = "Settings Scope",
    getFunc = function() return addon.settings:GetScope() end,
    setFunc = function(value) addon.settings:SetScope(value) end,
}
```

For a complete working example, see `_P11_MasterResearcher`'s `UI\SettingsUI.lua`, the first addon built on this library.

## Localization

String IDs used by `:GetLibAddonMenuScopeDropdown()`:

- `SI_LEV_SETTINGS_SCOPE` / `SI_LEV_SETTINGS_SCOPE_TT` — the dropdown's name and tooltip.
- `SI_LEV_SCOPE_CHARACTER`, `SI_LEV_SCOPE_ACCOUNT`, `SI_LEV_SCOPE_MEGASERVER` — the three choice labels.

English, French, German, Japanese and Russian are included under `localization\`, following the same `en.lua` + `$(language).lua` override pattern as `LibSavedVars`. The non-English strings are best-effort translations, not reviewed by native speakers — corrections are welcome.

## Differences from LibSavedVars

`LibExtendedSavedVars` is intentionally a smaller library, focused on the MegaServer-wide scope gap. It does not (yet) provide:

- `:RemoveSettings()` / `:RenameSettings()` / `:RenameSettingsAndInvert()` migration helpers — only `:Version()`.
- `:MigrateFrom***()` helpers for importing existing `ZO_SavedVars`/`LibSavedVars` data — switching a settings table to this library starts fresh.
- `:EnableDefaultsTrimming()` — default values are always written to disk.
- `pairs()` / `ipairs()` / `:GetLength()` looping support over the settings object itself.

These may be added later if a consuming addon needs them.
