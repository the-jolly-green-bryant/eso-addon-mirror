# XP Bonus Tracker

A comprehensive ESO addon that displays your total experience bonus percentage in real-time.

## Features

### Complete XP Tracking
Tracks ALL experience bonus sources:
- **Training Gear**: Weapons and armor with Training trait (automatically skips broken items)
- **Consumables**: All Ambrosia types and Experience Scrolls
- **Set Bonuses**: Heartland Conqueror (+12% with bow)
- **Racial Passives**: Altmer Highborn (+1%)
- **ESO Plus**: (+10%)
- **Ring of Mara**: (+10% when grouped with spouse)
- **Archive Vision Learned**: (up to +12% stackable)
- **Mora's Whisper**: (up to +15%)

### Smart Weapon Bar Detection
- Only counts Training bonuses from your ACTIVE weapon bar
- Automatically updates when you swap weapons
- Skips backbar weapons to prevent double-counting

### Accurate Calculations
- Correct percentages for all quality levels
- 1H weapons: 2.5% (Normal) to 4.5% (Legendary)
- 2H weapons: 5% (Normal) to 9% (Legendary)
- Armor: 7% (Normal) to 11% (Legendary)

### Customizable HUD Widget
- Compact 170x40 pixel display
- Draggable and lockable position
- Saves position between sessions
- Clean black background with gold/green text

## Commands

- `/xpbonus` - Toggle widget visibility
- `/xpbonus show` - Show widget
- `/xpbonus hide` - Hide widget
- `/xpbonus lock` - Lock position
- `/xpbonus unlock` - Unlock to move
- `/xpbonus reset` - Reset to default position
- `/xpbonus save` - Manually save position
- `/xpbonus refresh` - Force update
- `/xpbonus test` - Show detailed Training gear breakdown
- `/xpbonus debug` - Show all tracked sources

## Installation

1. Extract to `Documents/Elder Scrolls Online/live/AddOns/`
2. Enable in game Settings > Add-Ons
3. Widget appears at top center by default
4. Use `/xpbonus unlock` to reposition

## Changelog

### v6.0.0
- Added Heartland Conqueror set bonus detection (+12%)
- Added Altmer racial passive Highborn (+1%)
- Added Archive Vision Learned stackable bonus (up to +12%)
- Added Mora's Whisper detection (up to +15%)
- Added broken item detection (broken items don't give Training bonuses)
- Improved buff detection to catch all XP sources

### v5.6.0
- Removed debug message spam
- Clean, silent operation

### v5.5.0
- Fixed weapon bar detection for all weapon slots
- Fixed armor pieces being incorrectly skipped

### v5.0.0
- Accurate scroll/ambrosia percentages for all types
- Proper consumable detection ordering

## Credits

Thanks to the ESO community for feedback on missing XP sources!
