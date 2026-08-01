# Conductor v4.6.1-dev1 In-Game Stabilization Test Plan

## Gate 1: Startup

- Install over the existing v4.6.0-dev3 SavedVariables.
- Confirm no Lua error on login or ReloadUI.
- Confirm diagnostics, diagnostic overlay, and research capture are off.
- Confirm Saved Teams still exist.
- Confirm prior live ultimate assignments are blank.

## Gate 2: Current raid preparation

1. Select a different trial.
2. Confirm all boss and trash assignments clear immediately.
3. Use PREPARE RAID PLAN.
4. Confirm the current 12-player roster auto-populates.
5. Confirm no absent account appears in any live assignment or callout.
6. Confirm unresolved responsibilities are blank or marked unassigned, never `UNKNOWN`.

## Gate 3: Two-client sharing

- Verify both clients appear in Network diagnostics.
- Share outside combat.
- Host message must say transfer started, not sent.
- Recipient must receive the native Accept/Decline dialog.
- Accept and verify the imported plan.
- Repeat with Decline.
- Open Plan Status and confirm accurate recipient state.
- If the LGB queue is temporarily busy, confirm the transfer retries and does not silently disappear.

## Gate 4: Dummy Timeline

- Preview the Timeline.
- Confirm only one current and one next instruction appear.
- Confirm there is no `SIMULTANEOUS`, collision summary, hidden text, or `UNKNOWN`.
- Confirm blank provider ownership still shows the responsibility itself.

## Gate 5: Short combat pull

- Run one boss pull with diagnostics off.
- Confirm no red legacy configuration error.
- Confirm no old player names.
- Confirm no duplicate support callouts from legacy modules.
- Confirm Timeline resets after the wipe.
- Confirm addon can remain enabled without noticeable ability delay or frame degradation.

## Gate 6: VAS2 full validation

- Olms, Llothis, and Felms identified correctly.
- Timeline survives jumps, protectors, and temporary boss unavailability.
- Major Vulnerability is logically represented once even if ESO reports it through multiple unit tags.
- Wipe clears all active instructions.
- New pull starts from a clean state.
- Complete the run without disabling Conductor.

## Public release rule

Any failure in performance, stale-player cleanup, Timeline readability, reset behavior, or two-client sharing blocks publication.
