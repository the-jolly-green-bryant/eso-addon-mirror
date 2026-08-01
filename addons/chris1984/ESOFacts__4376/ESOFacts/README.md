<img width="1536" height="1024" alt="ChatGPT Image Feb 3, 2026, 09_21_51 PM" src="https://github.com/user-attachments/assets/d34618ee-4b49-4c72-a573-7dac0337d1b7" />

# ESOFacts

An Elder Scrolls Online addon that lets you share random lore facts with other players in chat.

## Features

- **56 lore facts** covering races, Daedric Princes, history, creatures, artifacts, and more
- **No-repeat system** - cycles through all facts before repeating
- **Cooldown** - 5-second cooldown prevents spam
- **Channel selection** - choose where to send facts
- **Auto mode** - automatically send facts on a timer (guild/group only)
- **Saved settings** - your channel preference and fact history persist between sessions
- **Keybind support** - bind a key to share facts (Settings > Keybindings > ESO Facts)
- **Statistics** - track how many facts you've shared
- **Settings menu** - configure options via LibAddonMenu (optional)
- **Custom facts** - add your own facts to the rotation

## Commands

| Command | Description |
|---------|-------------|
| `/facts` | Share a random fact (opens chat input ready to send) |
| `/factschannel` | Show current channel and available options |
| `/factschannel <channel>` | Set the output channel |
| `/factsauto <minutes>` | Start auto-sending facts at an interval |
| `/factstop` | Stop auto mode |
| `/factsstats` | Show statistics (facts shared, cycle progress) |
| `/factsettings` | Open settings menu (requires LibAddonMenu) |
| `/factsadd <fact>` | Add a custom fact |
| `/factslist` | List all custom facts |
| `/factsremove <number>` | Remove a custom fact by number |

### Channel Options

- `say` - Local /say chat (default)
- `yell` - /yell chat
- `zone` - Zone chat
- `group` or `party` - Group/party chat
- `guild1` through `guild5` - Guild chats

## Keybind

You can bind a key to share facts instead of typing `/facts`:

1. Open Settings > Keybindings
2. Scroll to "ESO Facts"
3. Set your preferred key for "Share Random Fact"

## Settings Menu

If you have [LibAddonMenu](https://www.esoui.com/downloads/info7-LibAddonMenu.html) installed, you can configure ESOFacts through the game's addon settings:

- **Cooldown** - Adjust the cooldown between facts (0-30 seconds)
- **Default Channel** - Set your preferred chat channel
- **Auto Mode Settings** - Configure minimum interval and max facts
- **Reset Cycle** - Clear shown facts to see them all again

Access via: Settings > Addon Settings > ESO Facts (or type `/factsettings`)

## Auto Mode

Automatically sends facts to chat at a set interval. Includes safeguards to prevent spam:

- **Minimum interval**: 5 minutes (configurable in settings)
- **Maximum facts**: 10 (configurable in settings, then auto-stops)
- **Restricted channels**: Only works with group and guild chat (not say, yell, or zone)

### Example Usage

```
/factschannel guild1
/factsauto 10
```

This sends a random fact to guild 1 every 10 minutes, stopping after 10 facts.

## Custom Facts

Add your own facts to the rotation:

```
/factsadd The Ebonheart Pact was formed after the Akaviri invasion.
/factslist
/factsremove 1
```

Custom facts are saved between sessions and included in the random rotation alongside built-in facts.

## Installation

1. Download and extract to your AddOns folder:
   - Windows: `Documents\Elder Scrolls Online\live\AddOns\ESOFacts`
2. Enable the addon in the game's addon menu
3. Type `/facts` in chat to get started

## License

MIT
