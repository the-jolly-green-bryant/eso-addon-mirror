# ESO FontChanger

This is a fork of the [FontChanger](https://www.esoui.com/downloads/fileinfo.php?id=3728) addon by Ferrety (and later modifications by Antisenil)

Primarily, this fork aims to simplify the process of adding new fonts to the addon by providing conversion scripts (Windows batch and Linux shell) to generate the .slug files for you. See detailed instructions below.

It also adds some new options to the addon settings to more easily change the fonts in game.

<p align="center">
	<img src="assets/settings_1.png" width=80% />
	<img src="assets/settings_2.png" width=80% />
</p>



## How to add additional fonts
1. Download your desired font in TTF format
2. Copy & Paste into the FontChanger/fonts/ttfs folder
3. Locate `slugfont.exe` in your ESO installation and copy it to FontChanger/fonts
4. Run the conversion script for your platform (see below)
	- This will automatically generate .slug files for all the fonts in the ttfs folder and update `CustomFontOptions.lua`
5. Load up the game or run `/reloadui` to see the new fonts in the options menu

### Windows
`slugfont.exe` can be found in your ESO installation directory:
- C:\Program Files\Zenimax Online\The Elder Scrolls Online\game\client\slugfont.exe
- C:\Program Files (x86)\Zenimax Online\The Elder Scrolls Online\game\client\slugfont.exe
- C:\Steam\steamapps\common\Zenimax Online\The Elder Scrolls Online\game\client\slugfont.exe

Run `FontChanger/fonts/slug.bat` to convert fonts.

### Linux
Requires [Wine](https://www.winehq.org/) to run `slugfont.exe`. `slugfont.exe` can be found inside your Wine/Proton prefix:
- ~/.steam/steam/steamapps/common/Zenimax Online/The Elder Scrolls Online/game/client/slugfont.exe
- Lutris users: check the Wine prefix under ~/.local/share/lutris/runners/wine/ or your game's own prefix

If you use Steam/Proton and don't have Wine installed separately, you can symlink Proton's wine binary:
```
ln -s ~/.steam/steam/compatibilitytools.d/GE-ProtonX-XX/files/bin/wine ~/.local/bin/wine
```

Run `FontChanger/fonts/slug.sh` to convert fonts.
