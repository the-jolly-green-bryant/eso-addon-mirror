# Reward Popups Reworked

Reward Popups Reworked is a quality-of-life addon for **The Elder Scrolls Online** that replaces intrusive reward notifications with a single customizable **Action Widget**.

Instead of interrupting gameplay with multiple reward popups, the addon quietly monitors supported reward systems, automatically claims supported rewards when enabled, and only displays a small, source-aware widget when your attention is actually required.

---

# Features

## Unified Action Widget

- Replaces multiple reward popups with one compact Action Widget.
- Automatically changes its icon, frame, and glow based on the active reward source.
- Handles multiple pending reward sources without overlapping notifications.
- Displays all pending reward sources in the tooltip.
- Double-click to open the primary reward page.
- Right-click for quick access to available reward sources and widget options.
- Movable and lockable.
- Automatically hides whenever ESO hides its own reward notifications (Map, Inventory, Collections, Crafting, etc.).

---

## Supported Reward Systems

### Tamriel Tomes

- Suppresses Seasonal and Weekly reward prompts.
- Opens the Timed Activities interface directly.
- Optional automatic claiming.
- Blue Action Widget theme.

### Golden Pursuits

- Suppresses Promotional Event reward prompts.
- Optional prevention of automatic activity pinning.
- Automatically claims only verified safe rewards.
- Unknown or choice rewards always require manual review.
- Gold Action Widget theme.

### Veterancy Rewards

- Detects Veterancy rank rewards.
- Optional automatic claiming.
- Uses ESO's Veterancy reward APIs.

---

# Automatic Claiming

Automatic claiming is **disabled by default**.

When enabled:

- Tamriel Tomes rewards can be claimed automatically.
- Veterancy Rewards can be claimed automatically.
- Golden Pursuits claims **only** rewards verified as safe.

Choice rewards and unknown reward types are **never** claimed automatically.

---

# Settings

Reward Popups Reworked supports two operating modes:

### Manual Mode

- Suppresses supported reward popups.
- Displays the Action Widget when player interaction is required.
- No automatic claiming.

### Automatic Mode

- Suppresses supported reward popups.
- Automatically claims supported rewards.
- Manual review is still required for unknown or choice-based Golden Pursuits rewards.

Additional options include:

- Widget Preview
- Widget Lock
- Glow Animation
- Pulse Animation
- Tooltips
- Notification Messages
- Individual settings for each supported reward source

---

# Installation

Copy the **RewardPopupsReworked** folder into:

```text
Documents\Elder Scrolls Online\live\AddOns\
```

Restart ESO or run:

```text
/reloadui
```

---

# Optional Dependency

**LibAddonMenu-2.0** is optional.

When installed, it provides the graphical settings panel.

Without LibAddonMenu-2.0, the addon continues to function normally and can be configured using slash commands.

---

# Slash Commands

```text
/rpr settings
```

Open the settings panel (requires LibAddonMenu-2.0).

```text
/rpr manual
```

Enable Manual Mode.

```text
/rpr automatic
```

Enable Automatic Mode.

```text
/rpr claim
```

Attempt to claim all eligible rewards.

```text
/rpr tomes
```

Open Tamriel Tomes.

```text
/rpr golden
```

Open Golden Pursuits.

```text
/rpr widget
```

Preview the Action Widget.

```text
/rpr hidewidget
```

Hide the widget preview.

```text
/rpr resetwidget
```

Reset the widget position.

```text
/rpr lock
```

Lock the widget position.

```text
/rpr unlock
```

Unlock the widget position.

```text
/rpr welcome
```

Resets the first-run welcome dialog and reloads the UI.

---

# Supported Systems

| System | Popup Replacement | Auto Claim | Action Widget |
|---------|:----------------:|:----------:|:-------------:|
| Tamriel Tomes | ✔ | ✔ | ✔ |
| Golden Pursuits | ✔ | Safe Rewards Only | ✔ |
| Veterancy Rewards | ✔ | ✔ | Not Required |

---

# Technical Notes

Reward Popups Reworked uses official ESO APIs wherever available and safely handles unavailable or changing game functions.

Design goals include:

- Graceful handling of missing API functions.
- Automatic refresh when supported ESO events occur.
- Safe reward claiming with explicit player opt-in.
- Manual review for unknown or choice-based rewards.
- A single unified Action Widget instead of multiple intrusive popups.

---

# AI Assistance Disclosure

AI-assisted tools were used during development for code review, debugging suggestions, documentation drafting, and promotional image generation.

All addon code, functionality, testing, final edits, and released assets were reviewed, refined, and approved by the author.

---

# Credits

Created by **SlickStyles**

Special thanks to the ESO addon community for documenting ESOUI behavior and APIs.