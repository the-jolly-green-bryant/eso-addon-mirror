# Conductor v4.6.1-dev1.12 Performance Audit

## Confirmed burst sources

1. `EVENT_PLAYER_ACTIVATED` was handled independently by Core, Profiles, Session Lifecycle, Live Session, Player Scanner, and Network.
2. Group events caused overlapping roster scans in Roster, Live Session, Player Scanner, and Network.
3. Player Scanner's 15-second safety scan rebuilt local gear, skills, Scribing, ultimates, responsibilities, and the group roster even when nothing changed.
4. Network separately scheduled capability profiles on group and zone events, duplicating the scanner's change publication.
5. Coverage and effect systems maintained high-frequency safety refreshes in addition to event-driven effect processing.
6. Approximately twenty recurring callbacks remain in the development build. Most are now gated while inactive, but further removal requires live behavioral proof.

## Changes made in this build

- One coalesced group scan path in Player Scanner.
- Roster-only periodic safety scan every 30 seconds.
- Full local capability scans only on relevant debounced loadout/skill/Scribing events or initial startup.
- One settled post-zone refresh rather than an immediate duplicate scan from Core.
- Network no longer creates an additional profile snapshot for the same group/zone events.
- Empty effect caches no longer receive full expiration iteration.
- Coverage timer interpolation reduced to 1 Hz; effect gains and fades remain immediate.
- Combat Context avoids idle ungrouped rescans.

## Deliberately not removed

The Encounter State, Encounter Observation, Timeline, Session Transfer, discovery heartbeat, Major Slayer, Pillager, and legacy context callbacks remain because static analysis alone cannot prove their runtime behavior is superseded. Removing them before controlled testing could break Timeline advancement, effect expiration, sharing, or encounter recovery.

## Validation required

- Zone entry and fast travel with Conductor enabled and disabled.
- Armory/setup swap and individual gear/skill swaps.
- Two-client discovery and capability updates.
- Raid Plan share.
- Buff/Debuff timers and fades.
- Timeline start, progression, wipe reset, and encounter completion.
- A full trial session for input delay, frame pacing, and loading indicator frequency.
