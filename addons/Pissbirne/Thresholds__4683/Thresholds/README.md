# Thresholds

Customizable boss HP threshold alerts for Elder Scrolls Online, configured per zone (area ID).

When a boss's health crosses one of your configured percent thresholds (e.g. 90 / 70 / 50 / 25), the addon can:

- show a movable **prominent text alert** ("Boss Name  70%", or a custom text you configured for that threshold),
- play a configurable **sound cue**,
- display a movable **tracker frame** with live boss HP% and the next armed threshold (one row per boss, up to 6).

All three alert channels can be toggled individually, and **every single alert can be styled individually**: custom text, text color, font size, display duration, sound, sound repeat (1-3 plays), and per-alert text/sound toggles.

## Configuration

Settings are found under **Settings → Addons → Thresholds** (requires LibAddonMenu-2.0; the addon itself runs without it).

The alerts for a boss are the **merge of all config levels** — each level contributes its alerts:

1. **Per-boss override** for the current zone (configured by boss name),
2. **Zone thresholds** for the current zone,
3. **Shipped per-boss defaults** (trials, see below),
4. **Global default thresholds**.

When several levels define the **same percent**, the most specific one wins (a boss 90% suppresses a global 90%, but a global 25% still fires alongside boss alerts).

### Quick entry

Thresholds are entered as space/comma separated percent values, e.g. `90 70 50 25`. Leaving the zone editbox empty removes the zone default again; leaving the global editbox empty disables default alerts entirely (only explicitly configured zones/bosses alert). Saving a quick-entry list over customized alerts keeps the styling of every percent that stays in the list.

Per-boss overrides are managed in the "Per-boss overrides (this zone)" submenu: pick a boss that is currently present from the dropdown (or type a name manually), enter its thresholds and press *Add / Update*.

### Alert editor

Each level (global, zone, per-boss) has a **"Customize alerts"** editor: pick an alert from the dropdown (or `<New alert>`), then configure

- trigger **percent**,
- **alert text** (empty = default "Boss Name  70%"),
- **text color** and **font size**,
- **display duration**,
- **sound** and **sound repeat** (1-3 quick plays),
- **screen position** ("Custom position" + *Move alert*: drag the text where you want it, then Save),
- **show text / play sound** toggles (e.g. a sound-only ping).

Up to **4 alerts show simultaneously**: alerts with a custom position appear at their own spot (a new alert at the same spot replaces the one showing there), alerts without one stack vertically at the shared position (newest on top). When more fire, the oldest disappears early.

Everything not explicitly customized inherits the default alert settings at the top of the panel, live — change the default font size and all non-customized alerts follow. *Preview alert* fires the alert exactly as configured; *Save alert* applies the changes. In the summaries and dropdowns, `*` marks alerts that carry custom styling.

### Sharing and copying

The **"Import / Export"** submenu turns configurations into shareable text strings (`THR1:` format): pick a scope (current zone, selected boss, global defaults, or the full profile), press *Generate export string* and copy the text with Ctrl+C. To import, paste a received string and press *Import* — a dialog shows what the string contains and where it will land, with two choices: **Replace** (overwrite the listed configuration) or **Merge** (combine by percent, the imported alert wins on equal percents). ESC cancels. Notes: imported strings apply to the zone they were exported from, not necessarily your current zone; boss names are language-specific, so strings from another client language will not match your bosses; truncated pastes are detected and rejected.

The **"Copy zone thresholds from"** dropdown (Current zone section) copies another zone's zone-wide alert list — styling and positions included — into the current zone. Per-boss overrides are not copied.

## Shipped trial boss data

`THR_BossData.lua` ships a generated table of all trial bosses (14 trials), keyed by zone ID and English boss name. It powers two things:

- the per-boss dropdown also lists all known bosses of the current trial, so overrides can be configured without standing in front of the boss,
- bosses can carry shipped default thresholds, used when neither a per-boss override nor zone thresholds are configured.

Boss names are English client names; on other client languages the shipped names are ignored (they can never match `GetUnitName()`), and everything else keeps working.

## Slash commands

- `/thr` or `/thresholds` — lock/unlock the tracker frame and the alert text for repositioning.

## Behavior notes

- Alerts only fire while **you are in combat**. Threshold crossings observed out of combat (e.g. released after a wipe while the group keeps fighting) are silent, but still count as fired for that combat.
- A threshold fires **once per combat**; heals or shields do not re-arm it. Everything re-arms when combat ends (wipe & retry works as expected).
- Joining a fight in progress does not replay thresholds the boss has already passed.
- If a burst crosses several thresholds in one hit, only the lowest one is announced.
- Same-named bosses with shared health (twins) announce each threshold only once.
- Boss death does not cascade the remaining thresholds.

## Installation

Copy the `Thresholds` folder into `Documents/Elder Scrolls Online/live/AddOns/`.

## Dependencies

- [LibAddonMenu-2.0](https://www.esoui.com/downloads/info7-LibAddonMenu.html) — needed for the settings panel. The addon still loads and fires the default alerts without it, but all configuration lives in the LAM panel.

## License

MIT — see [LICENSE](LICENSE).
