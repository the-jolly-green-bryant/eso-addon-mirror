# Experimental Dummy PvP

An experimental addon for The Elder Scrolls Online. It observes damage dealt to an NPC target and displays an estimate of its value against a configurable PvP target.

Developed by **Bièz**.

## Installation

1. Copy the `ExperimentalDummyPvp` folder into `Documents/Elder Scrolls Online/live/AddOns/`.
2. Install and enable `LibAddonMenu-2.0`.
3. Enable **Experimental Dummy PvP** in the Add-Ons list.
4. Configure the simulation under `Settings > Addons > Experimental Dummy PvP`.

## Summary

A movable window displays duration, actual and simulated DPS, total damage, critical hits, and the twelve abilities that produced the most simulated PvP damage. Its position is saved. The window never opens automatically.

DPS uses the full combat duration with a minimum duration of one second.
The first attack is retained even when ESO sends its damage event before the player's combat status becomes active.

- `/pdc`: open the latest summary.
- `/pdc log`: open the event-by-event combat log.
- `/pdc reset`: clear the current session.

The Event Log records each hit with its timestamp, target, ability icon and name, critical status, actual dummy damage, and simulated PvP damage. Long encounters are split into pages.

## Formula

The addon first estimates pre-resistance damage from the observed damage:

`base = dummy damage / (1 - dummy mitigation)`

It then applies the simulated target settings:

`PvP = base × (1 - target mitigation) × (1 - Battle Spirit) × (1 - additional mitigation)`

Resistance mitigation uses `effective resistance / 66000`, capped by the selected setting. Effective resistance is resistance minus penetration.

For critical hits, the addon also replaces the attacker's full critical multiplier with the multiplier remaining after the simulated target's Critical Resistance. Every 66 points of Critical Resistance remove one percentage point from the attacker's critical damage bonus. This reduction cannot lower a critical hit below its normal-hit component.

## Known limitations

- These numbers are local estimates; no server-side damage is changed.
- ESO does not always reliably distinguish training dummies from all other NPCs. The default mode excludes players and player pets, but may also react to a regular NPC.
- Buffs, debuffs, ability-specific multipliers and balance changes must be represented in the settings.
- Shielded, blocked and certain combat results may require in-game calibration.
