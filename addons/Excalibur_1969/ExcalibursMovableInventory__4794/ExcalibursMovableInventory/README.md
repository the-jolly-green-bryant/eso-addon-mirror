## Excalibur's Movable Inventory v1.1

---

## ⚠️ AI DISCLOSURE (per ESOUI rules)

**This addon contains AI-generated code.** Per the ESOUI addon submission rules (https://www.esoui.com/forums/showthread.php?t=10790), this is disclosed clearly and at the beginning of this document.

- **What was AI-generated:** Parts of this addon's Lua code, including the UI positioning logic, event handling, drag handling, and the LibAddonMenu settings panel.
- **Human review:** The code has been manually reviewed and tested in-game before release.
- **Scope of use:** AI was used for code generation only. No game assets, art, sounds, or other external content were produced by AI.
- **Credit:** Code patterns and approaches informed by community addons and resources are credited in the Credits section below.

This disclosure is provided transparently in compliance with the ESOUI rules for addon uploads.

---

**Author:** _Excalibur_1969  
**Description:** Makes the default inventory window movable, draggable, and centered. Full vanilla inventory, just repositioned. No auto-junk — that lives in a separate addon now.

### Overview

Excalibur's Movable Inventory is a lightweight, vanilla-preserving addon that lets you reposition the default ESO inventory window. Instead of replacing the inventory with a custom UI, it simply moves the existing one to your preferred location on screen. The inventory stays fully functional with all default behavior intact — bags, equipment, items, currencies — nothing is hidden or replaced.

**Default position:** Center of the screen when enabled. You can then drag it to wherever you want, and the addon remembers your preference across sessions and characters.

### Commands

| Command | Description |
|---|---|
| `/reload` | Apply changes after installing or updating. The addon auto-initializes on player load. |
| *(No slash command needed)* | The addon activates automatically once enabled. If you need to reset position, use the settings panel (see below). |

### Settings Panel

Access via **Settings → AddOns → Excalibur's Movable Inventory** (also: **Settings → mods list → Excalibur's Movable Inventory**).

| Setting | Type | Default | Description |
|---|---|---|---|
| **Enable inventory repositioning** | Checkbox (MASTER SWITCH) | ON | ON = the addon moves and drags the vanilla inventory window. OFF = inventory fully reverts to its default vanilla position (right side of screen). |
| **Inventory Position** | Dropdown | Center | Quick position presets: Center (screen center), Left (left side of screen), Right (right side of screen, vanilla default). |
| **Horizontal Offset** | Slider (-800 to 800, step 5) | 0 | Fine-tune the horizontal position in pixels. Positive = right, negative = left. |
| **Vertical Offset** | Slider (-500 to 500, step 5) | 0 | Fine-tune the vertical position in pixels. Positive = down, negative = up. |
| **Show panel backdrop** | Checkbox | OFF | ON = keep the vanilla dark panel background art. OFF = hide it for a cleaner look. |
| **Show tab icons (Items / Craft Bag / Junk)** | Checkbox | OFF | ON = show the floating tab icon row above the inventory panel. OFF = hide it. |
| **Reset to Center** | Button | — | Instantly resets the inventory to the exact center of your screen (offsetX = 0, offsetY = 0). |

### How It Works

1. **On login / /reload:** The addon anchors the inventory to screen-center by default.
2. **Dragging:** Click and drag the empty space just above the inventory panel (the drag handle area) to reposition it freely. The panel will snap to your new position.
3. **Persistence:** Your position is saved account-wide via `ExcalibursMovableInventory_SavedVars` and restored on next login.
4. **Mouse transparency:** When the backdrop is hidden, the background panel becomes mouse-transparent so you can interact with world elements behind it.

### Notes

- **Scale-aware:** The addon correctly handles UI scaling — your drag calculations account for the current GuiRoot scale.
- **No external dependencies required beyond LibAddonMenu-2.0** (which you likely already have if you use other addons).
- **Vanilla-safe:** The master switch lets you completely disable repositioning at any time, instantly restoring the original inventory position.
- **Keybind strip:** When the inventory is moved, the bottom keybind strip is hidden (standard behavior for modded inventory positioning).

### Troubleshooting

- **Inventory not moving?** Make sure "Enable inventory repositioning" is checked in the settings panel.
- **Can't see the drag handle?** The drag handle is a transparent 560x40px area at the top-left of the inventory panel (just above the item slots). Click and drag in the empty space above the panel.
- **Stuck or off-screen?** Use the "Reset to Center" button in settings, or type `/reload` and click reset before the panel appears.
- **Settings panel not showing?** Ensure LibAddonMenu-2.0 version 43+ is installed and enabled.

### Credits

- **LibAddonMenu-2.0** by Seerah and the ESOUI community — settings panel framework.
- Positioning/dragging approach informed by community discussion around vanilla-inventory repositioning addons.
