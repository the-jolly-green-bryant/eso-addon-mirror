# Chat Be Gone Changelog

## v1.1.4.3

- Built from the cleaned v1.1.4.2 line.
- Added a hardened settings persistence path so all user settings are restored after `/reloadui`, logout/login, character switching, and reopening ESO.
- Added a saved settings snapshot inside Chat Be Gone SavedVariables for recovery if the visible settings table is sanitized/rebuilt on load.
- Routed menu refresh/update paths through `PersistSettings()` so checkbox, dropdown, color, mute timer, notification, and slash-command changes are written to the SavedVariables table before the menu refreshes.
- Fixed Reset All Settings so it clears and repopulates the existing SavedVariables table instead of replacing the SavedVariables table reference.
- Added saved-version/status output to `/cbg status` for easier troubleshooting.
- Kept Saved Messages, Command List, Creator, and type-to-unmute removed.
- Kept the clean main menu: Guild Chats, Zone Chat, Text Filters, Timestamps / Colors, Add-on Notifications, Reset All Settings.
- Updated README, manifest version, internal version, AddOnVersion, and handoff notes to v1.1.4.3.

## v1.1.4.2

- Built from the cleaned v1.1.4.1 rollback line.
- Removed the Creator button from the main menu.
- Removed the Creator popup/panel code and creator slash route.
- Removed type-to-unmute behavior from the suppression path.
- Removed the Auto-Unmute notification category and clears the old saved notification key on load.
- Removed status/help wording that referenced auto-unmuted counts or `/cbg creator`.
- Updated Guild Chats and Zone Chat wording: to type in a muted chat, first unmute it from Chat Be Gone.
- Kept timer-based mute expiration intact.
- Kept Guild Chats, Zone Chat, Text Filters, Timestamps / Colors, Add-on Notifications, and Reset All Settings reachable.
- Updated README, manifest version, internal version, AddOnVersion, and package notes to v1.1.4.2.

## v1.1.4.1

- Built from the v1.1.4 rollback baseline only.
- Removed Saved Messages from the main menu.
- Removed the Show Saved Messages button and right-side saved-message panel.
- Removed saved-message history capture from the chat hook.
- Removed saved-message local storage defaults and clears old add-on message history on load.
- Removed saved-message notification category.
- Removed the saved-message keybind action from `Bindings.xml`.
- Removed the Command List / command section from the main menu.
- Removed the Command List popup/panel code and keybind cleanup paths.
- Kept Guild Chats on the main menu, with guild names inside Guild Chats only.
- Kept Zone Chat on the main menu.
- Kept Text Filters, Timestamps / Colors, Add-on Notifications, Creator, and Reset All Settings reachable.
- Moved Enable Chat Be Gone and Safe Mode into Text Filters so the root menu stays clean.
- Updated README, manifest version, internal version, AddOnVersion, and package notes to v1.1.4.1.

## v1.1.4 rollback baseline

- Guild Chats opens a guild list first, then each selected guild opens its guild/officer settings.
- Zone Chat stays on the main menu.
- Creator and Reset All Settings remain reachable.
- No chat-box movement, resize, background, layout, global scanning, protected UI-control hunting, chat sending, or gameplay automation.
