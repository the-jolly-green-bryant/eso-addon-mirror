# Chat Be Gone v1.1.4.3

**Created By:** xPricee  
**Guild:** The Eternal Gods  
**Discord:** xprice.

Chat Be Gone is a lightweight local chat cleanup add-on for The Elder Scrolls Online. It focuses on local chat visibility, guild/officer/zone chat muting, text filters, timestamps, colors, and add-on notifications.

It does **not** move, resize, or modify the actual ESO chat box layout. It does **not** save chat messages, open a saved-message panel, send chat, automate gameplay, control the character, or affect other players.

## Main Menu

1. Guild Chats
2. Zone Chat
3. Text Filters
4. Timestamps / Colors
5. Add-on Notifications
6. Reset All Settings

Removed from the main menu: Saved Messages, Command List, and Creator.

## Main Features

- Guild Chats section opens a guild list first.
- Selecting a guild opens that guild's guild/officer chat settings.
- Zone Chat stays on the main menu.
- Text Filters contains the master enable switch, Safe Mode, and spam filter toggles.
- Temporary mute timers: 10 minutes through 24 hours, plus Indefinite.
- Timer-based mutes still expire when the selected timer runs out.
- To type in a muted guild, officer, or zone chat, first unmute that chat from Chat Be Gone.
- No type-to-unmute behavior is advertised or used.
- Local add-on notifications can be enabled/disabled.
- Text filters for guild ads, +messages, and WTS/WTB/WTT.
- Optional timestamps and whisper/guild/officer colors.
- Reset All Settings uses a confirmation popup.
- Settings are saved account-wide through ESO SavedVariables and a Chat Be Gone recovery snapshot. Your guild mutes, zone mute, timers, filters, timestamps, colors, and notification choices should restore after `/reloadui`, logout/login, character switching, and reopening ESO.

## Slash Helpers

The visible Command List section was removed from the add-on menu. These slash helpers remain available for troubleshooting and quick access:

- `/cbg` - Show help.
- `/cbg status` - Show current status.
- `/cbg guilds` - Print detected guild slots.
- `/cbg hide g1` / `/cbg show g1` - Hide/show guild chat slot 1.
- `/cbg hide o1` / `/cbg show o1` - Hide/show officer chat slot 1.
- `/cbg zone on` / `/cbg zone off` - Toggle Zone Chat suppression.
- `/cbg ads on/off` - Toggle guild ad filter.
- `/cbg plus on/off` - Toggle +message filter.
- `/cbg trade on/off` - Toggle WTS/WTB/WTT filter.
- `/cbg timestamp on/off` - Toggle timestamps.
- `/cbg notify on/off` - Toggle add-on notifications.
- `/cbg reset` - Open reset confirmation popup.
- `/cbg reset confirm` - Reset settings without the popup.
- `/mute`, `/mute zone`, `/mute g1-g5`, `/mute o1-o5` - Open mute-related options/hints.

Removed old entries: saved-message panel, saved-message history, command-list panel, creator panel/button, saved-message keybind, and type-to-unmute behavior.

## ZOS / Bethesda Notice

This Add-on is player-created content and is not an official ZeniMax Online Studios, Bethesda, or ZeniMax Media product. ZOS is not responsible for this Add-on, does not provide customer support for this Add-on, and does not endorse this Add-on. Use of add-ons is at your own risk.

## Trademark Notice

This Add-on is not created by, affiliated with, or sponsored by ZeniMax Media Inc. or its affiliates. The Elder Scrolls® and related logos are trademarks or registered trademarks of ZeniMax Media Inc. All rights reserved.
