Better Buffs v0.3.10
Created by BMGxSancho

Better Buffs is a lightweight raid-effect intelligence addon for ESO console.
It provides Detailed and Compact buff/debuff displays, target-aware debuffs, group coverage, proc intelligence, stacks, encounter analytics, and character-specific HUD profiles.

CHARACTER PROFILES
Each character remembers its own tracked effects, display style, Compact layout, position, scale, opacity, tile settings, crescent settings, and sort order. General addon enablement, analytics, and advanced preferences remain account-wide.
Existing v0.2.x account-wide HUD settings are copied into each character profile once, the first time that character logs in after the update.

HUD SCENE BEHAVIOR
Better Buffs and Better Debuffs are registered as ESO HUD scene fragments so gameplay information yields naturally to game menus instead of relying on draw-tier hacks or menu-by-menu checks. Preview Display temporarily shows the existing HUD fragment in the active settings scene for configuration.

COMPACT LAYOUTS
- Crescent
- Grid
- Column

MYTHIC EFFECT INTELLIGENCE INCLUDED FOR TESTING
- Huntsman's Warmask / Mark of Hircine (verified target effect ID 252048)
- Harpooner's Wading Kilt / Hunter's Focus
- Death Dealer's Fete / Escalating Fete
- Belharza's Band / Belharza's Temper
- Dov-Rha Sabatons / Draconic Scales
- Thrassian Stranglers / Sload's Call (verified ID 136123)
- Rourken Steamguards / Steam Guardian
- The Saint and the Seducer through its normalized Major/Minor effects
- Spaulder of Ruin through Aura of Pride
- Pearls of Ehlnofey through Major Heroism

RESEARCH-GATED
Prowler's Talisman and Mad God's Dancing Shoes are not assigned speculative dedicated runtime entries because their current live event IDs/state names remain unverified. Rourken's dynamic cooldown reduction is also not guessed. Better Buffs only claims states that ESO exposes reliably enough for the canonical runtime.

ARCHITECTURE
ESO events -> Combat Context -> one Effect Runtime -> one canonical cache -> Analytics + UI.
No separate Mythic tracker or new polling loop is used.

V0.3.02 FINAL CORRECTION PASS
- Personal Slayer miss callout is hidden at creation, is opt-in, requires combat, and is cancelled immediately when disabled.
- Huntsman's Warmask accepts verified Mark of Hircine effect 252048 through ESO's Reticle Target path while retaining the existing target lifecycle and 10-second reapplication lockout.
- Opening Buff Display or Debuff Display positioning controls on console attaches that existing HUD fragment to the settings scene so the corresponding interface is visible while it is being configured.

- Automatically displays Huntsman's Warmask while the Mythic is equipped, without changing the user's saved manual tracking preference.
