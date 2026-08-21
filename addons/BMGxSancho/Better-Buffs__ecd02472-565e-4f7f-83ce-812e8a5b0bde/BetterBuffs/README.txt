Better Buffs v0.3.14

Better Buffs is a lightweight ESO raid-effect intelligence addon built around one Combat Context, one Effect Runtime, and one canonical effect cache.

v0.3.13 adds and corrects:
- Off Balance active -> 15s target immunity/cooldown presentation remains registry-driven and target-owned.
- Roaring Opportunist dedicated Gear Sets tracker using normal/perfected cooldown IDs 135924 and 137985.
- RO AUTO / ALWAYS / HIDDEN visibility through the existing Gear Sets menu.
- RO per-recipient 22-second eligibility state, including READY / PARTIAL / COOLDOWN presentation.
- Separate Weapon & Spell Damage text HUD under Analytics.
- Separate Tank Resistance HUD under Analytics using the 33,100 PvE resistance target and +/-5% color tolerance.
- Restored main-menu header layout: credits first, then global Enable Better Buffs, then the existing menu sections.
- Preserves the v0.3.11 Stats Module, Feeding Frenzy, Sul-Xan, Gear Sets menu, character profiles, scene ownership, and canonical effect architecture.

The authoritative runtime remains event-driven. No second effect cache or recurring stats poller is added.
