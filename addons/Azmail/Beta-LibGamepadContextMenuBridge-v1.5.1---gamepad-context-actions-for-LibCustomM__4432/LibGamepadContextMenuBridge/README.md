# LibGamepadContextMenuBridge

ESO library addon that mirrors inventory entries created via `LibCustomMenu:RegisterContextMenu(...)` into gamepad inventory action lists.

## Purpose
This library makes keyboard/mouse context actions available when playing in gamepad mode.
It is designed for addons that already register inventory context actions through `LibCustomMenu`.

## How it works
1. During load, the library wraps `LibCustomMenu:RegisterContextMenu(...)` and tracks registered callbacks.
2. When a gamepad item action list is refreshed, it asks the `LibCustomMenu` registries to build context entries for the current slot.
3. It converts supported context entries into gamepad `slotActions` entries.
4. Pressing an injected action runs the original callback from the context menu entry.

## What will be shown in gamepad actions
- Regular custom actions added with `AddCustomMenuItem(...)` that are actionable.
- Submenu parents added with `AddCustomSubMenuItem(...)`.
- Submenu children inside a dedicated gamepad submenu dialog.
- Entries in the same category execution order as `LibCustomMenu` (`EARLY` -> `NORMAL` -> `LATE`).

## What will NOT be shown
- Divider/header/non-action rows.
- Disabled entries (entries without an executable callback).
- Entries that are not produced for the current inventory slot by the originating addon callback.
- Duplicate entries already present in the current gamepad action list.

## Submenu behavior
- Submenu parent entries are injected as regular actions.
- Activating a parent opens a gamepad list dialog that contains submenu children.
- Selecting a child executes its original submenu callback.

## Usage
1. Install folder `LibGamepadContextMenuBridge` into `AddOns`.
2. Enable it in the addon list.
3. No code changes are required for addons that already use `LibCustomMenu:RegisterContextMenu`.

## Optional API
```lua
LibGamepadContextMenuBridge:SetEnabled(true)
LibGamepadContextMenuBridge:RegisterContextMenu(function(inventorySlot, slotActions)
    -- optional manual callback registration
end, LibCustomMenu.CATEGORY_LATE)
```

## Dependency requirements
- `LibCustomMenu>=730`
- Optional: `LibAddonMenu-2.0` (for settings panel)

## Settings and Debug
- Addon panel: `Settings -> Addon Settings -> LibGamepadContextMenuBridge` (requires `LibAddonMenu-2.0`).
- Available toggles: enable bridge, debug mode, verbose debug.
- Slash command: `/lgcmb`
  - `/lgcmb status`
  - `/lgcmb on` or `/lgcmb off`
  - `/lgcmb debug on` or `/lgcmb debug off`
  - `/lgcmb verbose on` or `/lgcmb verbose off`
  - `/lgcmb log 60`
  - `/lgcmb clearlog`
