[size=6][b]Frostfall — Temperature System for ESO[/b][/size]
[i]by @Kreksar5 and Claude.ai[/i] · Inspired by Frostfall (Skyrim)

Thematically inspired by [i]Frostfall[/i], the well-known Skyrim mod by [b]Chesko[/b] — name and concept used as an homage, [b]not a port, and not affiliated with or endorsed by Chesko or Frostfall's other contributors.[/b]

[color=orange][b]AI-ASSISTED ADDON.[/b][/color] Written with Claude.ai. Core mechanics have been iteratively refined and bug-fixed across many versions, but this should still be treated as not fully independently validated in-game until confirmed through extended play-testing.

For the full version history, see the Change Log tab, or CHANGELOG.md included in the download.

[size=5][b]Credits[/b][/size]

[list]
[*][b]Frostfall — Hypothermia Camping Survival[/b] (the Skyrim mod) by [b]Chesko[/b]: the name and the general hypothermia/insulation concept are used as a direct homage. This addon is an original implementation built for ESO's own API and mechanics — no code, assets, or data from the Skyrim mod were used or could be (different engine, different game).
[*][b]RolePlayNeeds — Tamriel Survival![/b] by [b]matheusbk2[/b]: two implementation details were confirmed by inspecting its actual published source (checked directly against the official v0.7 BETA release) — the EVENT_LOOT_RECEIVED argument signature (position 5, not 6, is the item-type integer), and the disease-overlay window construction pattern (CreateTopLevelWindow -> SetAnchorFill() -> SetMouseEnabled(false) -> child CT_TEXTURE with its own SetAnchorFill(), alpha controlled on the parent window) that this addon's hot/cold overlays follow. No code was copied; Frostfall is an original implementation.
[/list]

[size=4][b]Overlay art credit[/b][/size]
The hot/cold screen-overlay images (HOT_OVERLAY.dds, COLD_OVERLAY.dds) were generated using AI text-to-image tools — [url=https://perchance.org/ai-text-to-image-generator]Perchance AI Text-to-Image Generator[/url] and Google's Gemini Image Creator — and edited/converted to the game's .dds format using Paint.NET. They are not hand-drawn or sourced from ESO's own art assets.

[size=5][b]Overview[/b][/size]

Frostfall adds a fully-featured ambient temperature and survival system to Elder Scrolls Online. Every zone has an estimated ambient temperature based on its lore and biome. Your armor, costume, and outfit style all contribute [b]insulation[/b]. Swimming affects your effective temperature. At temperature extremes, screen overlays and emotes bring the experience to life.

[b]Insulation semantics:[/b] High insulation traps body heat — excellent in cold zones, but causes overheating in hot zones. Low insulation lets heat escape — comfortable in heat, but leaves you exposed to cold.

[size=5][b]Features[/b][/size]

[size=4][b]Zone Temperature System[/b][/size]
[list]
[*][b]1,000+ zones and sub-zones[/b] have carefully estimated base temperatures in °C
[*]Temperatures range from Icereach (-16°C) to City of Ash II (55°C) — see the reference table below for a curated selection of overland zones
[*]Zone temperature provided by [b]LibZoneTemp[/b]
[/list]

[size=4][b]Armor & Costume Insulation[/b][/size]
Priority order (first match wins):
[list=1]
[*][b]Costume[/b] — Crown Store cosmetics; insulation based on material and coverage
[*][b]Outfit Style[/b] — Outfit system style overrides; checks chest slot style
[*][b]Base Armor Style[/b] — Your equipped armor's crafting style
[/list]

[b]100+ styles[/b] have insulation values calculated from the [b]style[/b] alone (not the set name):
[list]
[*]Skin coverage (how much of the body is covered)
[*]Material (fur/hide > plate > leather > cloth > silks)
[*]Cultural origin climate — real computed tier order is Nord (80) > Breton (50) > Khajiit/Argonian/Orc (30, tied) > Imperial (20)
[*]Magical/special thermal properties (a small number of Daedric-aligned and undead-adjacent pieces are flavor-adjusted colder, not hotter — see below)
[/list]

Certain unique pieces have [b]flavor-adjusted[/b] insulation based on their in-game descriptions:
[list]
[*][b]Daedric / Ancient Daedric / Dremora / Xivkyn / Stalhrim Frostcaster[/b] — described in-code as radiating unnatural cold, not heat -> these land at or near the bottom of the mundane range (tier 0-10), not the top
[*][b]Waking Flame[/b] — despite the fire theming, its actual flavor bonus is a small negative one ("carries a mild chill") -> mid-range tier (50), not especially warm
[*][b]Flame Atronach (costume)[/b] — living flame -> clamped to the maximum tier (90)
[*][b]Frost Atronach (costume) / Ice Wraith (polymorph)[/b] — living ice/frost -> clamped to the minimum tier (-10), the coldest a mundane or magical source can register
[*][b]Apostle[/b] — despite the "regulated temperature design" flavor text, its actual tier (30) is below the 50 midpoint, not neutral
[/list]

[size=4][b]Swimming[/b][/size]
Swimming in open water equilibrates your body temperature toward the water temperature, partially bypassing insulation. Cold-zone water (below 15°C) is especially dangerous (2.5x drag rate). Thick armor provides some resistance but far less than on land.

[size=4][b]Environmental Temperature Mechanics[/b][/size]
[list]
[*][b]Water ingredient loot[/b] — Looting an alchemy water solvent cools you by 5°C (only if you are already above COMFORTABLE_HI).
[*][b]Crafting station interaction[/b] — Opening a provisioning or smithing station warms you by 5°C (only if below COMFORTABLE_LO). Rate-limited to once per minute.
[/list]

[size=4][b]Temperature Thresholds (all in °C)[/b][/size]
[list]
[*]FREEZE_DANGER: -10°C / 14°F — Hypothermia danger
[*]VERY_COLD: 0°C / 32°F — Very cold shiver emote
[*]COLD: 10°C / 50°F — Cold shiver emote
[*]COMFORTABLE_LO: 20°C / 68°F — Lower edge of comfort zone
[*]COMFORTABLE_HI: 24°C / 75°F — Upper edge of comfort zone
[*]WARM: 26°C / 79°F — Warm (no effect)
[*]HOT: 35°C / 95°F — Hot — wipe-brow emote, heat overlay begins
[*]HEAT_DANGER: 41°C / 105°F — Scorching — breathless emote, full heat overlay
[/list]

[size=4][b]HUD Display[/b][/size]
[list]
[*]Compact thermometer widget (draggable)
[*]Color-coded temperature bar and value
[*]Status label (COMFORTABLE, COLD, OVERHEATING, etc.)
[*]Insulation value and source displayed (e.g. "80 (armor)")
[*]Can be turned off entirely in settings, leaving only temperature emotes and top-of-screen alert notifications
[/list]

[size=4][b]Configuration Menu[/b][/size]
Accessible via [b]/ff config[/b] or the ESO addon settings panel (LibAddonMenu-2.0):
[list]
[*]Enable/disable the system entirely — immediately hides the HUD and any active overlay, and stops all temperature checking, until re-enabled
[*]Toggle the HUD (status window), overlay, and emotes independently
[*]Independently toggle native top-of-screen alert notifications and/or logging those same notifications to chat
[*]Scale and opacity controls for the HUD
[*]Emote dropdowns for each temperature band, populated live from your installed emotes
[*]Debug logging, status, force-update, and reset-to-default are available as [b]/ff debug[/b] slash commands (see Slash Commands below) rather than settings-panel controls
[/list]

[size=5][b]Installation[/b][/size]

[list=1]
[*]Download and extract the Frostfall folder
[*]Place it in: Documents\Elder Scrolls Online\live\AddOns\Frostfall\
[*]Install all required dependencies (see below) — always use the newest available version of each; Minion handles this automatically
[*]Launch ESO, enable the addon in the AddOns menu
[/list]

[size=5][b]Slash Commands[/b][/size]

[list]
[*][b]/ff[/b] or [b]/frostfall[/b] — Show help
[*][b]/ff status[/b] — Print current temperature state to chat
[*][b]/ff config[/b] — Open configuration menu
[*][b]/ff toggle[/b] — Enable/disable Frostfall (immediately hides/restores the HUD and overlay)
[*][b]/ff findEmote <name>[/b] — Search for an emote by name and print its stable emoteId
[*][b]/ff debug enable[/b] / [b]disable[/b] — Turn debug logging on/off
[*][b]/ff debug status[/b] — Same as /ff status
[*][b]/ff debug update[/b] — Force an immediate recalculation
[*][b]/ff debug reset[/b] — Reset all settings to default
[*][b]/ff debug resetStatus[/b] — Reset temperature to neutral and clear any active reagent buff
[/list]

[size=5][b]Zone Temperature Reference (Selected)[/b][/size]

[list]
[*]Western Skyrim: -10°C — Very cold, snowy Nordic holds
[*]Bleakrock Isle: -8°C — Icy island cliffs, sparse forests
[*]Coldharbour: -8°C — Bleak grey sky, cold and lifeless
[*]Wrothgar: -8°C — Orsinium highlands, bitterly cold winters
[*]Eastmarch: -2°C — Frozen wastes, volcanic tundra
[*]Rivenspire: 4°C — Bleak, windswept moors
[*]The Rift: 4°C — Relatively temperate, rich autumnal forests
[*]Cyrodiil: 17°C — Temperate central forests and plains
[*]Summerset: 18°C — Mild, pleasant Mediterranean climate
[*]Auridon: 20°C — Temperate Mediterranean gardens and architecture
[*]Gold Coast: 22°C — Pleasant climate, warmed by the Abecean Sea
[*]Murkmire: 34°C — Deep tropical marshland jungle
[*]Hew's Bane: 36°C — Barren, scorching desert peninsula
[*]Vvardenfell: 38°C — Volcanic island, arid ash wastes
[*]Northern Elsweyr: 40°C — Hot Anequine savanna and Scar desert
[*]Alik'r Desert: 46°C — Arid Hammerfell wasteland, scorching sandstorms
[*]The Deadlands: 54°C — Mehrunes Dagon's hellfire Oblivion realm
[/list]

[size=5][b]Armor Insulation Reference (Selected)[/b][/size]

[list]
[*]Flame Atronach (costume): 90 ★ — Body of living fire — extreme warmth
[*]Nord: 80 — Fur construction, capped at the mundane ceiling (raw score ~107)
[*]Werewolf (polymorph): 80 — Dense fur pelt and elevated body temperature
[*]Pyre Watch: 70 — Fire-tempered treatment provides insulating char layer
[*]Silver Dawn: 70 — Heavy-leather motif, no flavor bonus
[*]Waking Flame: 50 — Deadlands-tinged construction carries a mild chill (not heat, despite the fire theming)
[*]Mercenary: 50 — Practical layered construction for road travel
[*]Wood Elf: 30 — Light cloth racial armor, no flavor bonus
[*]Khajiit: 30 — Light hide racial armor, no flavor bonus
[*]Barbaric: 20 — Thin hide motif, low coverage
[*]Fang Lair: 20 — Dragon bones carry the cold of death
[*]Dremora: 10 — Emanates the consuming cold of Coldharbour
[*]Storm Atronach (costume): 10 — Elemental form provides no thermal protection
[*]Daedric: 0 — Radiates unnatural cold into the wearer's bones
[*]Stalhrim Frostcaster: 0 — Stalhrim plates actively radiate cold
[*]Frost Atronach (costume): -10 ★ — Body of living frost actively leeches warmth
[*]Ice Wraith (polymorph): -10 ★ — Body of living ice — aggressively cold
[/list]

★ = magical = true — clamped to the full -10..90 tier range instead of the mundane 0..80 range reserved for ordinary materials.

[size=5][b]Dependencies[/b][/size]

All are [b]required[/b]. Please install the newest available version of each — Minion (the standard ESO addon manager) will do this automatically.

[list]
[*][url=https://www.esoui.com/downloads/info7-LibAddonMenu.html][b]LibAddonMenu-2.0[/b][/url] — Settings panel UI
[*][b]LibZoneTemp[/b] (ESOUI) — Zone ambient temperature data
[*][b]LibArmorInsulation[/b] (ESOUI) — Armor insulation breakdown
[/list]

[size=5][b]Compatibility[/b][/size]

[list]
[*]ESO API Version: 101050
[*]Works with all ESO chapters and DLC
[*]Compatible with outfit system, costume system, and Crown Store collectibles
[/list]

[size=5][b]Notes on Temperature Calculations[/b][/size]

All zone temperatures and armor insulation values are [b]estimates[/b] based on lore descriptions, visual design, cultural origin, and material analysis. Insulation is calculated from the [b]visual style[/b] of the armor, not the set name. Unique pieces with flavor text describing thermal properties have been individually adjusted. Use the override system to tune anything that doesn't feel right for your playstyle.

The temperature system is [b]purely cosmetic[/b] — it does not affect actual gameplay stats, damage, or character mechanics. It is an immersion and roleplay tool.
