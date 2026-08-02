# Conductor v4.6.1-dev1.7

## Master Enable State Correction

- `Enable Conductor` is now the authoritative gate for every live Conductor HUD surface.
- Disabling Conductor hides Timeline, personal assignments, Buffs & Debuffs, lead callouts, DD callouts, and retired dashboard surfaces immediately.
- Disabling Conductor clears active Timeline and sequence runtime state.
- High-frequency runtime callbacks return immediately while Conductor is disabled.
- Re-enabling Conductor refreshes the roster and reapplies the user's dashboard visibility settings.
- Explicit settings previews may still display temporarily while the addon is disabled.

## Baseline

Built from v4.6.1-dev1.1 to avoid carrying forward the unvalidated dashboard changes introduced in dev1.2 through dev1.5.
