# Tamriel Auction House — Desktop Client

Sync your in-game listings with the Tamriel Auction House server. This app runs in the background while you play ESO.

## Installation

### Step 1: Install the ESO Addon

1. Download the latest addon files from the [Releases](https://github.com/krautchanpro/TamrielAuctionHouse/releases) page
2. Extract the `AuctionHouse` folder to your ESO AddOns directory:
   - **Windows:** `Documents\Elder Scrolls Online\live\AddOns\`
   - **Mac:** `Documents/Elder Scrolls Online/live/AddOns/`
   - **Linux (Steam):** `~/.steam/steam/steamapps/compatdata/306130/pfx/drive_c/users/steamuser/Documents/Elder Scrolls Online/live/AddOns/`
3. Log into ESO and make sure the addon is enabled in the Add-Ons menu

### Step 2: Install the Desktop Client

1. Go to the [Releases](https://github.com/krautchanpro/TamrielAuctionHouse/releases) page
2. Download the file for your operating system:
   - **Windows:** `TamrielAuctionHouse-Windows.exe`
   - **Mac:** `TamrielAuctionHouse-macOS`
   - **Linux:** `TamrielAuctionHouse-Linux`
3. Put it anywhere you like (Desktop, Downloads, etc.)

### Step 3: Run It

1. **Log into ESO first** (the client needs your SavedVariables to detect your account)
2. Double-click `TamrielAuctionHouse-Windows.exe` (or the Mac/Linux version)
3. That's it — the app auto-detects everything and starts syncing

You should see a small window with a green dot and "Connected — syncing". Minimize it and play.

## FAQ

**Do I need to keep the app running?**
Yes. Keep it running while you play so your listings stay in sync. Minimize it to your taskbar.

**Windows says "Windows protected your PC" when I run it.**
Click "More info" then "Run anyway". This happens because the app isn't signed with a Microsoft certificate. It's safe.

**Mac says the app is from an unidentified developer.**
Right-click the app → Open → Open. You only have to do this once.

**Linux says permission denied.**
Run `chmod +x TamrielAuctionHouse-Linux` first, then `./TamrielAuctionHouse-Linux`.

**The app says "ESO not found".**
It will ask you to browse to your ESO folder. Navigate to the `Elder Scrolls Online/live` folder that contains your `SavedVariables` directory.

**The app says "Log into ESO first".**
The client reads your player name from ESO's SavedVariables files. Log into the game at least once so these files exist, then restart the app.

**The app says "Server offline".**
The server may be down for maintenance. The app will automatically retry every 30 seconds.

**Can I run the client on a different PC than I play on?**
No. The client needs to be on the same PC as ESO because it reads and writes to your SavedVariables files.

## In-Game Usage

- `/ah` — Open the Tamriel Auction House window
- Right-click items in your inventory → **"List on Tamriel Auction House"** to sell
- Browse, buy, and manage listings through the UI
- The status bar at the bottom shows "Desktop Client: Connected" when syncing is active

## Support

Having issues? Open an [issue on GitHub](https://github.com/krautchanpro/TamrielAuctionHouse/issues).
