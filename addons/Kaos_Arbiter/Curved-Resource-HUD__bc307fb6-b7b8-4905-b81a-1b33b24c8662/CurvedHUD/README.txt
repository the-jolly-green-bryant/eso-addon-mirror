Curved Resource HUD 0.8.0 SCRIBING TRACKERS TEST BUILD

Upload CurvedHUD as one folder with CurvedHUD.addon at its root.
The package contains exactly one .addon manifest, as required by the console uploader.

Settings libraries are optional by design:
- LibAddonMenu-2.0
- LibHarvensAddonSettings (listed as LibVotans in the Bethesda.net console store)

If neither library loads, the HUD still renders. Chat commands:
  /curvedhud preview  - toggle fixed test values
  /curvedhud debug    - toggle diagnostic logging
  /curvedhud          - show version/load status

0.7.0 includes ESO-style gradient fills for Health, Stamina, and Magicka. The
"Show default ESO resource bars" setting can hide the stock player resource
frame; while hidden, ESO's self-buff row moves down into the available space.

Expected startup chat line:
  [CurvedHUD] Loaded 0.8.0-test; HUD, shield, mount stamina, and trackers created

0.7.0 tracker framework additions:
- selectable standardized Major buff in the lower-left outside slot
- independent Thin/Thick styles for inside and outside timer slots
- color presets for the current Major buff, Balance, and Bound Aegis timers
- reusable inside/outside timer positions in all four HUD corners
- stack-count labels prepared over every tracker icon
- separate font-size controls for resource values and percentages
- revised inside/outside thick curves that follow the Health radius more closely
- optional Balance tracker under Global Trackers, with selectable slot and color
- optional Bound Aegis tracker under Sorcerer Trackers, with selectable slot and color
- per-character Major-buff and individual tracker choices; shared HUD geometry remains account-wide
- flattened tracker titles for console-safe settings controls
- global inside/outside thickness controls moved into the shared layout settings
- clean semicircular timer ends and a small inward adjustment for Thick timers
- corrected console dropdown display/internal-value mapping for tracker positions
- automatic repair of invalid position values saved by 0.6.1/0.6.2
- separately tuned upper-outside and lower-outside Thin timer geometry
- canonical lower-left curves mirrored vertically for upper slots and horizontally for right slots
- approved lower-left Balance geometry reused for every inside Thin tracker
- wider, more curved outside Thin geometry and closer right-side Thick placement
- resource-value visibility settings moved above the optional tracker controls
- inner Thick positions shifted farther inward without changing their curves
- outer Thin radius reduced and shifted inward, especially at its far endpoint
- both lower-right Parallel slots moved closer to the resource bars
- Stacked right slots now select their parent by upper/lower quadrant before radial placement
- corrected the visually reversed upper/lower parent controls in Stacked mode
- reversed inner Thick offsets toward screen center on both sides
- retained the outer Thin midpoint while drawing its far endpoint toward the resource curve
- moved inner Thick three pixels back from its over-corrected center position
- tightened the inner Thick radius while preserving its mirrored geometry
- reshaped outer Thin so its center-side end moves outward and its far end hugs the resource arc
- moved upper-right outside icons farther outward and lower-right inside icons farther inward
- relaxed inner Thick and outer Thin to intermediate radii while preserving midpoint anchors
- replaced skill-specific icon offsets with consistent mirrored inside/outside icon placement
- upper-inner icons moved eight pixels closer to their tracker/stat bars
- upper-outer icons moved sixteen pixels farther horizontally from screen center
- toggleable Bound Armaments stack/duration tracker using any of the eight timer slots
- per-character Bound Armaments position and color settings
- toggleable Crystal Fragments proc-ready alert with Top/Right/Bottom/Left/Center presets
- dual Crystal Fragments detection through effect 46327 and proc action ID 114716
- reusable HUD-relative proc-alert positioning framework for future class proc skills
- Crystal Fragments proc-size slider; the alert inherits the HUD's combat and out-of-combat opacity
- rotating gold/white Bound Armaments ready highlight at four weapon stacks
- toggleable Critical Surge timer using its unique self-buff
- toggleable Vibrant Shroud, Encase, and Shattering Spines timer with a 10-second cast fallback
- Vibrant Shroud timer prefers the slotted/cast skill artwork over Minor Vitality artwork
- guaranteed overlay-layer gold/white Bound Armaments ready border at four stacks
- right-side inside and outside timer bars moved closer to their resource arcs
- per-character Soul Burst and Ulfsild's Contingency trackers in a dedicated Scribing Skills section
- configurable position, color, and script-dependent duration for both scribing timers
- current cast artwork is retained for each character's scribed variant

Diagnosis of the silent v0.2 result:
The prior ZIP was not recoverable from the referenced task, so exact line-level attribution
is impossible. A complete no-HUD/no-menu result most strongly indicates that its add-on-loaded
handler never completed, commonly due to a manifest folder/name mismatch, a hard missing
dependency, an initialization-time Lua error, or controls anchored/hidden before player activation.
This build removes those failure modes by using optional dependencies, exact add-on-name gating,
protected initialization, explicit top-level controls, player-activation refresh, periodic resource
refresh, and visible chat/error reporting.

Packaging note: upload the CurvedHUD folder itself. Do not add an extra directory around it.
