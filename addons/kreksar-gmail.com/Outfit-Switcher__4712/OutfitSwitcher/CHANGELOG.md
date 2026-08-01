# Outfit Switcher — Changelog

Full version history for Outfit Switcher. See README.md for current features, usage, and requirements.

---

### 1.2.6

- Manifest `## APIVersion` updated to `101050 101051`, covering the newly
  released 101051 alongside the previous 101050.

---

### 1.2.5

- **Corrected `## APIVersion`** from `101051` back to `101050`. 101051 isn't
  a released API version yet — 101050 is the current one.

### 1.2.4

- Manifest cleanup: `## APIVersion` trimmed to a single value. (Corrected
  in 1.2.5 below — this entry originally trimmed to 101051, but 101051
  hadn't actually been released yet at the time; 101050 was the correct
  current value.)
- Updated the AI-assistance notice in the manifest description and README
  to state the addon has been reviewed and tested in-game by the author,
  rather than "has not yet been independently validated."
- Split the changelog out of README.md into this file, and reformatted
  README.md into BBCode for the ESOUI addon description page.

### 1.2.3

- **Standardized the author credit** to `@Kreksar5 and Claude.ai` in the
  `## Author` manifest field and this README's byline, and named Claude.ai
  specifically (rather than generic "AI assistance") in the manifest
  description and the AI-assistance disclosure above, matching the crediting
  convention used across this addon's companion libraries.

### 1.2.2

- **Added the required AI-assistance disclosure** to the manifest description
  and this README, per ESOUI's addon release rules.

### 1.2.1

- **Full API audit against the official ESOUI API 101050 documentation.**
  Every function call, method call, and constant referenced in the addon
  was cross-checked against the API doc and, where the doc didn't cover it
  (manager singletons, `ZO_` helpers), against the live ESOUI source. No
  invalid or deprecated API usage found — `EVENT_OUTFIT_EQUIP_RESPONSE`,
  `ZO_Alert`, `zo_strtrim`, and `SOUNDS.POSITIVE_CLICK`/`NEGATIVE_CLICK` are
  all legitimate and correctly used. No code changes required.

### 1.2.0

- Hooked `EVENT_OUTFIT_EQUIP_RESPONSE` so feedback now reflects the game's
  actual confirmed result instead of assuming `EquipOutfit` succeeded.
  Distinct messages are shown for success, already-equipped, invalid slot,
  locked slot, and outfit-switching-unavailable.
- Merged the changelog into this README.

### 1.1.0

- Added gamepad support: feedback messages now also raise a `ZO_Alert`
  on-screen notification (via `UI_ALERT_CATEGORY_ALERT` / `_ERROR` and
  `SOUNDS.POSITIVE_CLICK` / `NEGATIVE_CLICK`) alongside the existing chat
  print, so the addon is fully usable when playing in gamepad mode with
  the chat window closed. No separate gamepad/keyboard code path was
  needed — `ZO_Alert` handles that routing internally.
- Hardened `/outfit` argument parsing:
  - Input is trimmed with `zo_strtrim` before validation.
  - Only plain, optionally-signed integers are accepted
    (`^[+%-]?%d+$`); decimals, hex, exponents, and stray characters are
    rejected with an explicit message instead of being silently floored
    or misparsed.
  - `0` and negative numbers are rejected with a dedicated message
    ("Slot number must be 1 or higher") rather than falling through to
    the generic "not enough slots" message.
  - Empty input (`/outfit` with no argument) now shows a usage message.
- Added README and changelog (changelog later merged into this file in 1.2.0).

### 1.0.0

- Initial release.
- `/outfit <number>` slash command switches to the given outfit slot via
  `EquipOutfit(GAMEPLAY_ACTOR_CATEGORY_PLAYER, outfitIndex)`.
- Checks unlocked slot count via `GetNumUnlockedOutfits()` and refuses to
  switch to a slot beyond what's unlocked.
- Basic non-numeric input handling (via `tonumber`).
