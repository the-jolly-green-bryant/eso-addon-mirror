# Tetsu's Combat Healer Helper 1.3.0

Console (PS5 / Xbox) healer helper for The Elder Scrolls Online.

## What it does

- Head icons = heal holes. Circle / diamond / square sit on a person who is missing Illustrious Healing, Combat Prayer, and one extra you pick. The icon vanishes when the effect lands.
- HUD = buff coverage. Up to 5 columns. Filled green dot = the player has that buff.
- No ground puddle. Standing in Illustrious is detected by the HoT on the unit.

## 1.3.0 fixes

- Head markers no longer mix three coordinate systems on the same control (that is what put icons under the floor / off the map).
- Effects on you arriving as groupN instead of player are stored under a stable key.
- Combat Prayer on allies is covered when the skill is present or both Minor Berserk + Minor Resolve.
- HUD is restyled and can be moved / scaled from LibHarvens settings.
- Extra trackable columns: Major Force, Major Slayer, Minor Magickasteal, orb synergy lockout.

## Requirements

- LibHarvensAddonSettings
- API 101050 / 101051
