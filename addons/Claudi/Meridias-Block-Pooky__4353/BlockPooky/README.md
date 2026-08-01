# BlockPooky - ESO Addon


[![ESO API Version](https://img.shields.io/badge/ESO%20API-101046-blue)](https://www.esoui.com/)
[![Version](https://img.shields.io/badge/Version-2.11-green)](https://github.com/your-repo/BlockPooky)

> **Warns the Pooky if blocking is necessary** - A comprehensive PvP awareness addon for Elder Scrolls Online

## Overview

BlockPooky is an Elder Scrolls Online addon that provides critical combat awareness for PvP scenarios. Originally inspired by rumors about ballgroup "BLOCK" warning addons, it has evolved into a comprehensive tool that helps players react to incoming threats and optimize their defensive gameplay.

## Features

### 🛡️ Block Warnings
- **Visual Alerts**: Large, customizable UI frame with "BLOCK Pooky!" message
- **Audio Notifications**: Configurable sound alerts (Duel Start sound)
- **Center Screen Announcements (CSA)**: BA-style messages for critical awareness
- **Chat Integration**: Optional chat warnings with addon tags
- **Group Messaging**: Cross-addon compatibility with Agony Warning

### 🎯 Smart Detection
- **Ability Recognition**: Detects incoming pull abilities (Dark Convergence, Rush of Agony, chains, etc.)
- **Group Awareness**: Ignores abilities from group members and companions
- **Custom Triggers**: Add your own ability IDs for personalized detection
- **Language Support**: Works across different ESO client languages

### 📊 Combat Awareness
- **Block Detection**: Shows when you're actively blocking (solves "Am I Blocking?" uncertainty)
- **CC Immunity Tracking**: Visual bar showing immunity duration from dodge rolls/potions/poisons
- **Negate Warnings**: Alerts when standing in enemy Negate Magic fields
- **Ready Hints**: Notifications when DC/ROA abilities are off cooldown
- **Threat Alerts**: Full-screen overlay warnings for dangerous threat abilities with customizable textures, opacity, and timing
- **Stamina Low Warning**: ⚠️ **Critical** - Alerts when stamina drops below breakfree threshold (prevents getting CC-locked)

### ⚡ Performance Tools
- **Vigor Timing**: Optimal recasting reminders (8s intervals for group play)
- **Custom Cooldown Bars**: Track any ability or effect with personalized bars
- **Mount Notifications**: Reminds you when it's safe to mount in Cyrodiil


### 🎨 Customization & Combat Visuals
- **Movable UI**: Drag and position all elements anywhere on screen
- **Color Themes**: Customize colors for all UI components
- **Font Sizing**: Adjustable font sizes for visibility
- **Duration Controls**: Configure how long messages stay visible
- **Customizable Messages**: Personalize all in-game messages and UI labels
- **Combat Visuals UI**: Adjust maximum AOE brightness, outline thickness, and target outline intensity from the settings menu
- **RGB AOE Cycling**: Enable color cycling for AOE indicators (with speed and turbo controls)

## Installation

1. Download and install the required dependencies:
   - [LibChatMessage](https://www.esoui.com/downloads/info2382-LibChatMessage.html)
   - [LibAddonMenu-2.0](https://www.esoui.com/downloads/info7-LibAddonMenu.html)
   - [LibMapPing](https://www.esoui.com/downloads/info1302-LibMapPing.html)
   - [LibGPS](https://www.esoui.com/downloads/info1037-LibGps.html)

2. Extract BlockPooky to your ESO AddOns folder:
   ```
   Documents\Elder Scrolls Online\live\AddOns\BlockPooky\
   ```

3. Launch ESO and enable the addon in the Add-ons menu

## Quick Start

1. **Open Settings**: Type `/blockpooky` in chat or access via ESO Settings > Add-ons
2. **Configure Triggers**: Select which abilities should trigger block warnings
3. **Customize UI**: Set colors, positions, and notification preferences
4. **Test Setup**: Use `/blockpookytest` to verify everything works

## Configuration

### Basic Settings
- **Show CSA**: Enable Center Screen Announcements
- **Play Sound**: Audio alerts for block warnings
- **Show UI Frame**: Large visual warning message
- **Chat Warnings**: Text notifications in chat
- **Group Messaging**: Send "They pulled me!" messages to group ⚠️
  - Uses LibMapPing (flagged by ZOS as backdoor API - use at your own risk)


### Advanced Features
- **Custom Triggers**: Add ability IDs for personalized detection
- **Customizable Messages**: Edit messages(block warnings, hints, labels)
- **Cooldown Bars**: Create bars for any ability or effect
- **Combat Visuals**: UI controls for AOE brightness, outline thickness, target outline intensity, and RGB AOE cycling
- **Debug Tools**: Investigate ability/effect IDs in real-time
- **UI Positioning**: Lock/unlock mode for moving interface elements

## Usage Tips

### Finding Ability IDs
1. Enable "Investigate Abilities" or "Investigate Effects" in Debug Tools
2. Trigger the ability/effect in-game
3. Check chat for the ID (format: `Effect? Name: <name> | ID: <id>`)
4. Disable investigation to prevent chat spam

### Optimal Vigor Usage
- Enable Vigor hints for group play optimization
- "Vigor!" appears after 8 seconds
- Starts blinking at 16 seconds if not recast
- Essential for maintaining group healing efficiency

### Group Coordination
- Works with Agony Warning addon for cross-addon communication
- Uses encoded map pings for group messaging
- Filters pulls to send only ROA/DC warnings (configurable)

## Development

### Project Structure
```
BlockPooky/
├── BlockPooky.lua                # Main initialization and event handling
├── BlockPooky_blocking.lua       # Block detection system
├── BlockPooky_ccbar.lua          # CC immunity tracking
├── BlockPooky_cooldowns.lua      # Custom cooldown bars
├── BlockPooky_hints.lua          # Timing hints and notifications
├── BlockPooky_negate.lua         # Negate field detection
├── BlockPooky_threatalert.lua    # Threat alert overlay system
├── BlockPooky_combatvisuals.lua  # Combat visuals and AOE cycling
├── BlockPooky_menue.lua          # Settings UI integration
├── BlockPooky.xml                # UI control definitions
├── BlockPooky.txt                # Addon manifest
├── README.md                     # Documentation
└── textures/                     # Overlay texture files
    ├── gold.dds
    ├── Indigo.dds
    ├── lemon.dds
    ├── red.dds
    ├── explosion.dds
    └── reddot.dds
```

### Dependencies Location
All libraries should be installed as separate addons:
```
AddOns/
├── BlockPooky/
├── LibChatMessage/
├── LibAddonMenu-2.0/
├── LibMapPing/
└── LibGPS/
```

### Key Patterns
- Module pattern: `BlockPooky = BlockPooky or {}`
- Event registration with proper filtering
- UI controls with position persistence
- Account-wide and character-specific settings

## Commands

- `/blockpooky` - Open addon settings menu
- `/blockpookytest` - Trigger test warning

## Compatibility

- **ESO API Version**: 101046
- **Compatible Addons**: Agony Warning (cross-addon messaging)
- **Languages**: All ESO client languages supported
- **Platforms**: PC/Mac

## Support

For issues, feature requests, or questions:
- Check the [wiki documentation](https://wiki.claudiapps.de/wiki:blockpooky)
- Review the `.github/copilot-instructions.md` for development guidance

## License

This addon is released under standard ESO addon terms. See individual library licenses for dependencies.


## Changelog

### Version 2.15 - HoT Bar Enhancements
- **Fixed HoT Bar Position Persistence**: Position now correctly saves and restores when moved
  - Bar previously reset to default position on each load due to LoadHoTBarPosition() ignoring saved coordinates
  - Now uses TOPLEFT anchor with saved left/top coordinates
- **Over-Cap HoT Display**: Bar now shows counts above the 8-cap limit with dynamic max scaling
  - Displays "10/8" format when overcapped to show actual HoT count
  - Status bar max value dynamically adjusts to accommodate values above 8
  - Red color persists for all values >= 8 (at cap or overcapped)
  - Useful for investigating HoT stacking mechanics during Update 49 testing

### Version 2.14
- **HoT Counter - Update 49 Compliance Tool**:
  - **Real-time HoT Tracking**: Monitors all active Healing-over-Time effects on player toward the 8-cap limit
  - **Dual Detection Methods**: 
    - Skill-based HoTs via EVENT_COMBAT_EVENT (standard healing abilities)
    - Effect-based HoTs via EVENT_EFFECT_CHANGED (scribing skills like Genesender spells)
  - **Smart Stacking Logic**:
    - Non-stackable HoTs: Count as 1 regardless of caster (standard HoTs)
    - Stackable HoTs: Sum all stacks (Vigor/Echoing Vigor can stack multiple times from same caster)
    - Per-caster refreshing: Same ability from same caster refreshes rather than stacking
  - **Visual Counter Bar**: Shows current count (e.g., "5/8") with color indicators:
    - Green (0-5): Safe zone
    - Yellow (6-7): Warning - approaching cap
    - Red (8+): At cap or overcapped
  - **Auto-Hide on Expiration**: Bar automatically disappears via OnUpdate handler when all HoTs expire
  - **Movable UI**: Drag to reposition anywhere on screen with persistence
  - **Database**: 390+ verified HoT ability IDs including all rank variants
  - **Configurable**: Enable/disable from settings menu (default: OFF)
  - **Testing**: Manual test command `/run BlockPooky.TestAddHoT(abilityId, duration)` for debugging 

### Version 2.13 - bugfix
- Fix variable name inconsistency

### Version 2.12 - Stamina Low Warning System
- **Full-Screen Stamina Warning**: Critical visual overlay alerts when stamina drops below configured threshold
- **⚠️ Break Free Awareness**: Alerts when stamina is too low to break free from CC (stuns, knockdowns, etc.)
  - **Default threshold: 5000** - Below this, you cannot break free and will be locked down
  - Helps prevent getting locked in place during combat (lethal in PvP)
- **Configurable Threshold**: Set any stamina value as trigger point based on your needs
- **Fade Opacity Control**: Separate min/max opacity sliders for smooth fade effect
  - Minimum opacity at threshold (default: 30%)
  - Maximum opacity at 0 stamina (default: 72%)
  - Creates gradual visual intensity as stamina depletes
- **Texture Support**: Uses staminawarn.dds texture with blue border design
- **Dynamic Initialization**: Auto-detects and fixes overlay dimensions after `/reloadui` for reliability
- **Menu Integration**: Full settings submenu with enable/disable toggle and customizable sliders
- **Survival Tool**: Helps maintain stamina buffer to stay free from crowd control in PvP

### Version 2.11 - Critical OOP Syntax Fixes
- **Fixed Complete OOP Syntax Misuse**: Corrected critical bug where colon syntax (`:`) was incorrectly used for non-OOP functions
  - All function calls now consistently use dot syntax (`.`) matching their definitions
  - Fixed 35+ function calls across all modules (BlockPooky.lua, BlockPooky_menue.lua, BlockPooky_ccbar.lua, BlockPooky_combatvisuals.lua)
  - Affected functions: `SetUiLock`, `InitGroupMessaging`, `StopGroupMessaging`, `LoadGroupMembers`, `SetUseBlocking`, `RegisterNegateWarning`, `UnRegisterNegateWarning`, `CCEventRegisterUpdate`, `RegisterThreatAlert`, `UnRegisterThreatAlert`, `UpdateThreatAlertAlpha`, `AddThreatAbility`, `RebuildThreatAbilityList`, `ResetPosition`, `setBlockPookyFont`, `SetColor`, `SetBlockingColor`, `SetVigorHintColor`, `SetCCBarColor`, `SetNegateWarningColor`, `SetMaxAOEBrightness`, `SetMaxOutlineThickness`, `SetMaxTargetOutlineIntensity`, `ResetMaxAOEBrightness`, `ResetMaxOutlineThickness`, `ResetMaxTargetOutlineIntensity`, `SetAOERGBState`, `UpdateUILabels`, `DecodeMessage`, `WarnThePooky`, `SendWarning`, `ToggleAOERGB`, `showCCbar`
  - This bug was causing saved variables corruption where entire objects were being stored instead of boolean values
  - Resolves Lock UI toggle failures and prevents future configuration data corruption
- **Fixed All Menu Description Controls**: Verified all LibAddonMenu-2.0 description controls now have proper titles
  - Eliminates "[LAM2] Could not create description 'unnamed'" errors
  - Prevents menu initialization failures

### Version 2.10 - Code Refactoring & Documentation Update
- **Fixed OOP Notation Inconsistency**: Refactored entire codebase to eliminate misleading `:` (colon) and `self` notation
  - All function definitions converted from `function BlockPooky:Method()` to `function BlockPooky.Method()`
  - All method calls converted from `self:Method()` to `BlockPooky.Method()`
  - All property accesses converted from `self.property` to `BlockPooky.property`
  - Affected 113+ function definitions, 148+ method calls, and 200+ property accesses across 9 modules
  - Improves code clarity by accurately reflecting simple table pattern (non-OOP/non-class)
- **Fixed SavedVars Initialization**: Corrected escaped quotes in configuration initialization
- **Fixed Menu JSON Structure**: Corrected corrupted table definitions in cooldown bar settings menu
- **Verified Functionality**: All features tested in ESO and confirmed working correctly
  - Block warnings, CC immunity tracking, hints, cooldown bars, negate detection, threat alerts all operational

### Version 2.9 - LibCombat Integration for Threat Alerts
- **LibCombat Integration**: Threat alert system now uses LibCombat's LIBCOMBAT_EVENT_DAMAGE_IN callback for improved reliability
  - More efficient event handling compared to EVENT_COMBAT_EVENT
  - Automatic filtering of player's own damage reduces processing overhead
  - Callback-based registration enables dynamic enable/disable from menu
- **Threat Alert Register/Unregister Pattern**: Implemented register/unregister methods following the negate warning pattern
  - Ability to toggle threat alerts on/off from settings menu without addon reload
  - Proper cleanup with pcall() error handling during unregistration
- **Added LibCombat>=2 Dependency**: Manifest updated to require LibCombat version 84 or higher
  - Ensures threat alert feature is only available when LibCombat is properly installed
  - Addon gracefully handles missing dependency (threat alerts disabled, other features work)

### Version 2.8 - bugfixes
- fixed the is in group check

### Version 2.7 - Threat Alert Awareness System
- **Full-Screen Threat Alert**: Visual alert overlay that covers your entire screen when dangerous threat abilities are cast
- **Configurable Abilities**: Detect Dark Convergence, Rush of Agony, and any custom ability IDs you add
- **Texture Selection**: Choose from 7 different overlay textures (red, gold, indigo, lemon, blood tint, stamina tint, redstar)
- **Opacity Control**: Adjustable overlay transparency (10%-80%) for visibility without full screen blocking
- **Timing Control**: Configure overlay duration (1-30 seconds) and cooldown (0.5-10 seconds) between alerts
- **PvP-Only Mode**: Option to only trigger alerts in Cyrodiil PvP zones (on by default)
- **Removable Abilities**: All threat abilities including defaults (DC/ROA) can be removed or customized
- **Full Menu Integration**: Complete settings submenu with enable/disable toggle, texture dropdown, sliders, and ability management
- **Enemy Source Filtering**: Ignores alerts from allies, companions, and group members

### Version 2.6 - Customizable Messages
- **Message Customization**: All UI frames, CSA messages, and labels are now customizable through the settings menu
- **New Submenu**: "Customize Messages" allows personalization of 8 different messages
- **Default Reset**: One-click reset button to restore all messages to defaults
- **Dynamic Updates**: UI labels update immediately when messages are changed

### Version 2.5 - ESOUI Compliance & Performance
- **Added dependency version checks** in manifest (LibChatMessage>=1, LibAddonMenu-2.0>=2.0, LibMapPing>=100, LibGPS>=1)
  - Prevents addon from loading with outdated/broken libraries
- **Optimized EVENT_COMBAT_EVENT handling** with C-level event filters
  - Filters `ACTION_RESULT_EFFECT_GAINED` and non-errors at C level before Lua processing
  - Significant performance improvement during combat (reduced memory usage and CPU cycles)
- **Group Messaging Warning**: Added warning about LibMapPing backdoor API
  - ZOS flagged MapPing as a backdoor for data sharing (2024-12)
  - Feature remains available but marked as potentially violating ESOUI rules
  - Menu option highlighted in red with `!` indicator

### Version 2.4
- Added Combat Visuals submenu: UI controls for AOE brightness, outline thickness, and target outline intensity
- Added RGB AOE cycling: Enable/disable, speed, turbo, and default color controls
- Improved settings persistence and menu integration
- Updated CC immunity bar logic for new ESO API (Escapist's Poison supported)
- Compatible with latest ESO API (101046)

### Version 2.2
- Full feature set as documented
- Compatible with latest ESO API

---

**Remember**: In PvP, awareness is survival. BlockPooky helps you stay one step ahead! 🛡️