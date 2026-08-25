CurvedHUD 0.5.3 RELEASE BUILD

Upload CurvedHUD as one folder with CurvedHUD.addon at its root.
The package contains exactly one .addon manifest, as required by the console uploader.

Settings libraries are optional by design:
- LibAddonMenu-2.0
- LibHarvensAddonSettings (listed as LibVotans in the Bethesda.net console store)

If neither library loads, the HUD still renders. Chat commands:
  /curvedhud preview  - toggle fixed test values
  /curvedhud debug    - toggle diagnostic logging
  /curvedhud          - show version/load status

0.5.3 includes ESO-style gradient fills for Health, Stamina, and Magicka. The
"Show default ESO resource bars" setting can hide the stock player resource
frame; while hidden, ESO's self-buff row moves down into the available space.

Expected startup chat line:
  [CurvedHUD] Loaded 0.5.3; HUD, shield, mount stamina, and trackers created

Diagnosis of the silent v0.2 result:
The prior ZIP was not recoverable from the referenced task, so exact line-level attribution
is impossible. A complete no-HUD/no-menu result most strongly indicates that its add-on-loaded
handler never completed, commonly due to a manifest folder/name mismatch, a hard missing
dependency, an initialization-time Lua error, or controls anchored/hidden before player activation.
This build removes those failure modes by using optional dependencies, exact add-on-name gating,
protected initialization, explicit top-level controls, player-activation refresh, periodic resource
refresh, and visible chat/error reporting.

Packaging note: upload the CurvedHUD folder itself. Do not add an extra directory around it.
