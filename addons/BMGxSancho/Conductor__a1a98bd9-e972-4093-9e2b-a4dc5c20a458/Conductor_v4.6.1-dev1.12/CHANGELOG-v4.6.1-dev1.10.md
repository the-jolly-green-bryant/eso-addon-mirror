# Conductor v4.6.1-dev1.10

## Network stabilization

- Added a dedicated, always-on LibGroupBroadcast discovery protocol.
- Discovery no longer depends on capability-profile completion.
- Discovery never pauses during Raid Plan transfers.
- Presence packets use replacement queue semantics so stale advertisements cannot accumulate.
- Group updates, player activation, startup, and a five-second heartbeat announce the client.
- Peer records now distinguish DISCOVERED from COMMITTED capability profiles.
- Raid Plan and capability traffic remain isolated from discovery.
