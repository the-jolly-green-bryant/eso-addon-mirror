# Conductor v4.7.0-dev1 Engineering Report

## Objective

Create the first implementation of the simplified Conductor operating model:

- one Run Host
- independent combat role
- independent Trial Lead view
- one Run Context
- lightweight run synchronization
- one Timeline output path

## New authoritative services

### RunContext

Owns run identity, host authority, local combat role, Trial Lead view, assignment revision, encounter checkpoint, and run lifecycle.

### RunSync

Uses a compact LibGroupBroadcast protocol for:

- run header
- participant join
- encounter checkpoint
- run stop

It does not send the complete Raid Setup or saved team.

### WindowController

Owns the lock state for public combat windows. Timeline and Buffs & Debuffs can be unlocked, moved, and locked. Their positions save automatically.

## Runtime ownership changes

The following legacy systems are no longer initialized as independent sequencers:

- Colossus Rotation
- Warhorn Rotation
- Barrier Rotation
- Nazaray Module
- Pillager Module
- Major Slayer Module

Their files remain in the development source for compatibility and future observer extraction, but they no longer receive initialization in this branch.

The following nonessential runtime systems are also disabled during stabilization:

- Recommendation Engine
- Post-Pull Analytics
- Research Capture
- full Raid Session sharing startup

## Known limitations

- Compact assignment delta broadcasting is not yet implemented.
- Host takeover is not automatic.
- Late join uses the most recent run header but full checkpoint recovery still requires live testing.
- Trial-instance gating remains a separate optimization pass.
- Existing encounter profiles still require live validation.
- Development protocol ID 237 must be reserved before public release.
