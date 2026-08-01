# Right-side HUD tracker column

Research notes for move/scale work. Not loaded by the addon.

These are separate `TopLevelControl`s. They stack via **anchors** (layout links), not parent/child. Scaling one does not scale the others; `SetInheritScale` only affects children inside a control's own tree.

Source: `esoui-live` (verified Jul 2026). Re-check after major patches.

## Column order (top → bottom)

Each row anchors under the one above unless noted.

| # | Player-facing name | Top-level control |
|---|--------------------|-------------------|
| 1 | Endless Archive | `ZO_EndDunHUDTracker` |
| 2 | Adventure Zone | `ZO_AdvZoneHUDTracker` |
| 3 | Dynamic / world events | `ZO_DynamicEventsTracker_TL` |
| 4 | Focused quest | `ZO_FocusedQuestTrackerPanel` |
| 5 | Zone Guide / Zone Story | `ZO_ZoneStoryTracker` |
| 6 | Golden Pursuits (or Tomes) | `ZO_PromotionalEventTracker_TL` |
| 7 | House information | `ZO_HouseInformationTrackerTopLevel` |
| 8 | Activity Finder status | `ZO_ActivityTracker` |
| 9a | Ready check | `ZO_ReadyCheckTrackerTopLevel` |
| 9b | Battleground HUD | `ZO_BattlegroundHUDFragmentTopLevel` |

9a and 9b both attach to `ZO_ActivityTracker` (siblings). Situational; 9b is not a `ZO_HUDTracker_Base`.

## Anchor chain (simplified)

```
GuiRoot
  → ZO_EndDunHUDTracker
    → ZO_AdvZoneHUDTracker
      → ZO_DynamicEventsTracker_TL
        → ZO_FocusedQuestTrackerPanel
          → (Zone Story anchors to …PanelContainerQuestContainer)
            → ZO_ZoneStoryTracker
              → ZO_PromotionalEventTracker_TL
                → ZO_HouseInformationTrackerTopLevel
                  → ZO_ActivityTracker
                    → ZO_ReadyCheckTrackerTopLevel
                    → ZO_BattlegroundHUDFragmentTopLevel
```

### Quest panel nesting

```
ZO_FocusedQuestTrackerPanel
  ZO_FocusedQuestTrackerPanelContainer
    ZO_FocusedQuestTrackerPanelContainerQuestContainer
```

### Stock root offsets (`ZO_EndDunHUDTracker`)

Quest has no fixed GuiRoot Y. It hangs under Dynamic Events. When 1–3 are inactive, quest sits roughly where the column root is.

| Platform | Notable offsets |
|----------|-----------------|
| Keyboard | Top to GuiRoot at **Y = 90** (X = -230 on primary) |
| Gamepad | Primary Y = **0**; secondary TOPRIGHT Y = **100** |

## Visibility / collapse (vanilla)

`ZO_HUDTracker_Base` fragments hide the inner **`Container`**, not the top-level. The next tracker still anchors to the top-level.

In **vanilla**, inactive trackers **do collapse**: top-levels with `resizeToFitDescendents` shrink when their container is hidden, so visible neighbors hug each other. Example: Endless Archive appears neatly above the quest while inside the mode; outside it, the quest takes that place. Activity Finder hugs the quest when middle slots are empty.

Large persistent gaps between quest and Activity Finder (or Archive and quest) are **not** normal stock behavior. In practice those were observed with a quest-mover addon breaking collapse / anchors. Test without movers before assuming ZOS left empty space.

Other visibility notes:

- Focused quest vs Zone Story: mutually exclusive via `HUDTracker_Manager` (`IsZoneStoryAssisted`). Same HUD “slot” content-wise; separate controls.
- Promotional panel also shows Tamriel Tomes when no Golden Pursuit is tracked (same control, different header/icon).
- Quest timers live inside the focused quest panel, not as another column entry.

## Move / scale implications

- **Position:** move a control and everything that anchors under it follows, if stock anchors are left intact. Prefer not to break the chain if you want vanilla collapse.
- Relocating Endless Archive still shifts the hang-offs (quest included). It is the column root.
- To move Archive alone: reposition it, then re-anchor Adventure Zone (or the next piece that should stay) to GuiRoot / another fixed point so the rest of the column does not follow. Re-apply after ZOS `RefreshAnchors` / platform style.
- Trackers *above* the quest (1–3) do not follow a quest-only move; the quest panel anchors under Dynamic Events, not the reverse.
- **Scale:** apply the same scale to each top-level (or its Container) you care about. No shared parent. `SetTransformScale` is common for HUD movers; force `SetInheritScale(true)` on descendants if any child opts out.
- Custom movers that `ClearAnchors` / parent / scale incorrectly can introduce fake gaps. Preserve or restore the collapse path when possible.

## Gilded UI (Layout / Tracker Column)

Stable approach (0.2.15):

- Move only the column root (`ZO_EndDunHUDTracker`) with stock-like gamepad dual anchors at Position Y.
- Leave tracker **top-levels** on ZOS anchors (collapse + stacking).
- Scale each **top-level** with `SetScale`. Do **not** re-anchor or `SetScale` the `Container` — HUD trackers use a −15 content inset, and quest’s `QuestContainer` is anchored to `TimerAnchor` (sibling of `Container`); touching Container breaks that and shoves quest off-screen.
- Flush **Promotional** + **House** `RIGHT → GuiRoot` to offset **0** (stock is −15). Gamepad Activity only hangs under House, so that inset made Activity’s scale gap wider than Archive/Quest. Vertical primary anchors stay intact.
- After that flush, apply a **−15 content inset** on Promotional / House / Activity containers. Activity gamepad stock has no container right inset — flushing the TL alone made Activity hug the screen while Archive still has ZOS’s −15 container inset.
- On apply, restore stock **container** anchors only (HUD: `CONTAINER_*` via `RefreshAnchorSetOnControl`; quest: refill + `ApplyPlatformStyle`) so earlier experiments do not leave Archive flush at scale 1. Do not call full `RefreshAnchors` (that would undo the root move).
- `SetScale` shrinks from top-left, so non-1.0 scale leaves a right-edge gap ≈ `width × (1 − scale)`. Different tracker widths → slightly different gaps. Equalizing that without breaking quest/collapse is still unsolved.
- Re-apply root position + scale/flush after EndDun `RefreshAnchors`; re-apply scale/flush after `ZO_HUDTracker_Base.RefreshAnchors` (House restores −15 otherwise).
