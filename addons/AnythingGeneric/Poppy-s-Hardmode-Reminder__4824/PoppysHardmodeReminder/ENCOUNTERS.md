# Encounter coverage - v0.4.0

18 base-game dungeon encounters: 3 confirmed by the user; 15 researched additions awaiting in-game validation. DLC additions are listed in DLC_ENCOUNTERS.md. Trials are excluded. English names only.

| Zone | Dungeon | Matched names | Activation | Validation |
|---|---|---|---|---|
| 283 | [Fungal Grotto I](https://eso-hub.com/en/zones/fungal-grotto-i) | Kra'gh the Dreugh King | Scroll | Confirmed by user |
| 144 | [Spindleclutch I](https://xynodegaming.com/eso-guides/allaboutmechanics/dungeons/base-game-dungeons/spindleclutch-i/) | The Whisperer | Scroll | Confirmed by user |
| 380 | [The Banished Cells I](https://xynodegaming.com/eso-guides/allaboutmechanics/dungeons/base-game-dungeons/the-banished-cells-i/) | High Kinlord Rilis | Scroll | Confirmed by user |
| 148 | [Arx Corinium](https://eso-hub.com/en/zones/arx-corinium) | Sellistrix the Lamia Queen | Scroll | Awaiting game test |
| 38 | [Blackheart Haven](https://xynodegaming.com/eso-guides/allaboutmechanics/dungeons/base-game-dungeons/blackheart-haven/) | Captain Blackheart | Scroll | Awaiting game test |
| 64 | [Blessed Crucible](https://eso-hub.com/en/zones/blessed-crucible) | The Lava Queen, Lava Queen | Scroll | Awaiting game test |
| 176 | [City of Ash I](https://xynodegaming.com/eso-guides/allaboutmechanics/dungeons/base-game-dungeons/city-of-ash-i/razor-master-erthas/) | Razor Master Erthas | Scroll | Awaiting game test |
| 681 | [City of Ash II](https://esoaz.com/2019/07/16/cite-de-cendres-1-et-2/) | Valkyn Skoria | Frigid Tome | Awaiting game test |
| 130 | [Crypt of Hearts I](https://eso-hub.com/en/zones/crypt-of-hearts-i) | Ilambris-Athor, Ilambris-Zaven | Scroll | Awaiting game test |
| 63 | [Darkshade Caverns I](https://eso-hub.com/en/zones/darkshade-caverns-i) | Sentinel of Rkugamz, The Sentinel of Rkugamz | Scroll | Awaiting game test |
| 449 | [Direfrost Keep](https://eso-hub.com/en/zones/direfrost-keep) | Drodda of Icereach | Scroll | Awaiting game test |
| 126 | [Elden Hollow I](https://eso-hub.com/en/zones/elden-hollow-i) | Canonreeve Oraneth | Scroll | Awaiting game test |
| 931 | [Elden Hollow II](https://eso-hub.com/en/zones/elden-hollow-ii) | Bogdan the Nightflame | Opus of Torment | Awaiting game test |
| 31 | [Selene's Web](https://xynodegaming.com/eso-guides/allaboutmechanics/dungeons/base-game-dungeons/selenes-web/) | Selene | Scroll | Awaiting game test |
| 131 | [Tempest Island](https://eso-hub.com/en/zones/tempest-island) | Stormreeve Neidir | Scroll | Awaiting game test |
| 11 | [Vaults of Madness](https://eso-hub.com/en/zones/vaults-of-madness) | The Mad Architect, Mad Architect | Scroll | Awaiting game test |
| 22 | [Volenfell](https://eso-hub.com/en/zones/volenfell) | The Guardian's Strength, The Guardian's Spark, The Guardian's Soul, Guardian's Strength, Guardian's Spark, Guardian's Soul | Scroll | Awaiting game test |
| 146 | [Wayrest Sewers I](https://eso-hub.com/en/zones/wayrest-sewers-i) | Allene Pellingare | Scroll | Awaiting game test |

## Sources and interpretation

Zone IDs were checked against [LibZone data](https://raw.githubusercontent.com/Baertram/LibZone/master/LibZone/LibZone_Data.lua). Dungeon links above support the boss identities and activation requirements. The first three entries also have user test reports in this task. Existing source material may describe achievement names rather than exact API name strings: new names and pre-pull timing still need game validation.

Multi-boss names: [Ilambris Twins](https://xynodegaming.com/eso-guides/allaboutmechanics/dungeons/base-game-dungeons/crypt-of-hearts-i/); [Guardian Constructs](https://forums.elderscrollsonline.com/en/discussion/298941/the-volenfell-group). Explicit leading-The aliases are included for the Lava Queen, Sentinel, Mad Architect and Guardians; these are defensive matching variants within the same specific dungeon, not additional encounters.

## Deliberate exclusions

Banished Cells II, Fungal Grotto II, Spindleclutch II, Darkshade Caverns II, Wayrest Sewers II and Crypt of Hearts II are omitted because their hardmodes use fight conditions rather than the activation interaction this addon is intended to remind about. Source: [base-game hardmode discussion](https://forums.elderscrollsonline.com/en/discussion/374290/list-of-hardmode-dungeons). Its broad statement about all II dungeons is not reliable: Elden Hollow II has [Opus of Torment activation](https://eso-hub.com/en/zones/elden-hollow-ii) and is included, as is City of Ash II.

## Testing

No need to repeat the three confirmed encounters. During other runs, enable /hmdebug; on Normal also enable /hmnormaltest. Check the named final encounter warns, ordinary bosses stay silent, duplicates stay suppressed, and returning after the boss list has cleared for at least two seconds triggers again. Report any missed/late reminder with the logged zone, boss name and combat state. Some bosses may not become visible to the API until combat; the shared fallback does not guarantee a warning early enough to activate hardmode.

The shared v0.2 logic is unchanged. Reminders may appear when hardmode is already active, as requested. Wipe/reset recovery is confirmed for the user's Kra'gh run only; continuously visible boss tags may require /hmrearm.

