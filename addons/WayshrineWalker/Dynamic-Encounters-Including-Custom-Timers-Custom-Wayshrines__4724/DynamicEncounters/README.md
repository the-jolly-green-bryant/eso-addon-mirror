# Dynamic Encounters + (Including: Custom Timers & Custom Wayshrines)

A clean, friendly tracker for ESO's **Dynamic Encounters** (Update 50 / Season One):
**Flowervine Farm** (Auridon), **Bilsa's Delivery** (Stonefalls), and **Vampire Hunt** (Glenumbra).

Built and verified against the official ESOUI game source (12.0.6, API 101050).

## What it does

- **Live status panel** for all three encounters: LIVE NOW / next expected / just ended / no data.
- **Learned respawn timers.** The game exposes no official respawn clock, so Dynamic
  Encounters records every real activation and end it witnesses and predicts the next start
  from the *median of observed end-to-start gaps*, per zone, per server (seeded at 30:00).
  It always tells you how many cycles the estimate is based on.
- **Server-precise stage timers** while you're participating: current stage name, exact
  time remaining (from the server's own expiry timestamp), and stage progress %.
- **Custom countdown timers.** Press the bindable key (default T) to create floating
  countdown widgets. Link any timer to an encounter row's clock button for one-click
  respawn tracking. Each timer supports pause/restart, three sizes, per-timer lock,
  and a wayshrine button with map-open and fast-travel.
- **Header wayshrine button.** A persistent shortcut pinned to the HUD header.
  SHIFT+Left = assign nearest wayshrine. SHIFT+Right = searchable picker.
  Left-click = open map. Right-click = fast travel with gold confirmation.
  Persists through reloads.
- **Searchable wayshrine browser.** Shift+Right-click any wayshrine icon to open
  a scrollable list of every known wayshrine, sorted by zone, with type-to-filter
  fuzzy matching.
- **Alerts**: on-screen announcement, chat message, and a selectable sound when an
  encounter goes live — plus an optional early warning before an *estimated* start.
- **All the nice extras**: dark & light themes, per-encounter show/hide, compact mode,
  "only my current zone" mode, hide-in-combat, scale & opacity, movable/lockable panel,
  seconds on/off, a bindable toggle key, and full settings via LibAddonMenu-2.0
  (optional — everything also works through `/denc` commands).

## Honest limitations (by API design, not by choice)

- The client only receives world-event data **for the zone you are in**. No addon can see
  another zone's encounter state; we show your last observation and its age instead.
- Zone **shards** (instances) can run different clocks. Estimates apply to what *your*
  client has witnessed. The addon says so rather than pretending otherwise.
- Respawn predictions are calibrated estimates, clearly marked with `~` and sample count.
  While an encounter is running, stage timers are exact (server timestamps).

## Install

1. Copy the `DynamicEncounters` folder into:
   `Documents\Elder Scrolls Online\live\AddOns\`
2. (Recommended) Install **LibAddonMenu-2.0** via Minion for the settings panel.
3. `/reloadui` or relog.

## Commands

`/denc` — toggle panel · `lock` / `unlock` · `scan` · `status` · `log` · `reset`
`/dencsettings` — open settings (with LibAddonMenu)

## Compatibility

Designed to play well with others:
- One global (`DynamicEncounters`), namespaced event registrations, own top-level
  control only — **no hooks, no re-anchoring of any ZOS or third-party UI**.
- Scene-fragment integration (`hud`/`hudui`) so it fades exactly like stock HUD elements.
- Read-only use of the World Event API; coexists with map/minimap addons (Votan's,
  Fyrakin's, AUI), quest trackers, pChat, LUI, etc.

## For maintainers: verified API surface (ESOUI 12.0.6 / API 101050)

Events: `EVENT_WORLD_EVENTS_INITIALIZED`, `EVENT_WORLD_EVENT_ACTIVATED`,
`EVENT_WORLD_EVENT_DEACTIVATED`, `EVENT_WORLD_EVENT_PARTICIPATION_BEGIN/END`,
`EVENT_WORLD_EVENT_STEP_CHANGED`, `EVENT_WORLD_EVENT_STEP_PROGRESS_CHANGED`.

Functions: `GetNextWorldEventInstanceId`, `GetWorldEventLocationContext`,
`GetWorldEventPOIInfo`, `GetPOIInfo`, `GetParticipatingWorldEventStep`,
`GetWorldEventStepName`, `GetWorldEventCurrentStepExpireTimeS`,
`GetWorldEventCurrentStepProgress`.

Zone IDs: Auridon 381 · Stonefalls 41 · Glenumbra 3.

## In-game verification checklist (first run)

Paste-friendly checks:

1. API version — expect `101050`:
   `/script d(GetAPIVersion())`
2. Zone IDs — stand in each zone, expect 381 / 41 / 3:
   `/script d(GetZoneId(GetUnitZoneIndex("player")))`
3. World event enumeration — while an encounter icon is on your zone map:
   `/script for id in function(_,l) return GetNextWorldEventInstanceId(l) end do d(id, GetWorldEventLocationContext(id)) end`
   Expect at least one instance id.
4. With the addon on, wait through one spawn in-zone: you should see the on-screen
   announcement, the chat line, and the row flip to LIVE. After it ends, the row should
   show `next ~30:00` (first cycle), then tighten as real gaps are learned.
5. `/denc log` — confirm start/end observations are being recorded.

## Changelog

**1.0.1** — Packaging fix: added missing files to `.addon` manifest (Timers/, Predictor),
fixed zip structure with proper directory entries and forward-slash separators for
Minion compatibility. No code changes.

**1.0.0** — Initial release for Update 50 (API 101050). Tracks the three Season One
Dynamic Encounters with learned respawn estimation, precise stage timers, alerts,
themes, and LibAddonMenu settings.
