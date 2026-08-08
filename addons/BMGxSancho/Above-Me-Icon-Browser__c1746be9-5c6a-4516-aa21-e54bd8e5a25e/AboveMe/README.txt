Above Me v0.0.02

A BMG ADDON
Created and maintained by @BMGXSANCHO

This development build focuses on renderer stability, per-character icon placement,
lightweight placement sharing, network lifecycle cleanup, and performance.

Key behavior:
- Each player chooses and owns their own icon.
- Above Me users automatically see one another's selected icons.
- Icon movement uses persistent controls and adaptive spring smoothing.
- World-position sampling now matches the 33 ms visual update interval for faster movement tracking.
- Camera-driven screen movement is now applied immediately, while the spring smooths only remote actor movement.
- Each character can calibrate icon height once in the settings menu.
- The calibrated height is shared as compact metadata, never as live position data.
- Icon rendering remains local and smooth on every viewer's screen.
