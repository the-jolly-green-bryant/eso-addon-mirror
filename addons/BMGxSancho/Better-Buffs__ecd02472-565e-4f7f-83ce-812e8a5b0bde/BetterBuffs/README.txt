BETTER BUFFS v0.2.01

Better Buffs is a focused organized-PvE effect intelligence addon for ESO.

Display styles:
- Detailed: timers, group coverage, active/missing player diagnostics, and target names.
- Compact: icon-first awareness with Crescent, Grid, or Column layouts.

Compact visual language:
- Green / yellow / red perimeter: active duration remaining.
- Dim icon + number: cooldown / unavailable state.
- Gold READY: effect or proc is available where the registry can prove readiness.
- Bottom-right badge: group coverage.
- Top-right badge: stacks where ESO exposes them reliably.

Architecture:
ESO events -> Combat Context -> one Effect Runtime -> one canonical cache -> Analytics + UI.
