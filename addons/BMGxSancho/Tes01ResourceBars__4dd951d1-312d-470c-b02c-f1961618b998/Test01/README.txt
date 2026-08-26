Test01 Resource Bars v0.0.06

Standalone validation harness for Better Buffs Resource Bars.

Key v0.0.06 changes:
- Corrected crescent leading-edge highlight anchoring so the glow cap cannot render below the bar.
- Preserves v0.0.05 absolute resource sizing, text centering, smoothing, native colors, and frame treatment.

Previous v0.0.05 changes:
- Shared absolute sizing standard: 30,000 max resource = configured Length.
- Health/Magicka/Stamina physical lengths are directly comparable.
- Damage Shield physical length uses peak shield capacity for the current application.
- Shield Crescent Depth no longer carries the explanatory tooltip.
- Crescent footer text receives mirrored visual-center correction so names/values align under the resource axis.
- Existing native palette, gradient/depth textures, glow, bevel, temporary smoothing, scene handling, and native bar restoration are preserved.

No Better Buffs Effect Runtime, Analytics, Combat Context, or permanent polling loop is included.
