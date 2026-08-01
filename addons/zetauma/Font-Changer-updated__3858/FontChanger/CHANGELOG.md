# Changelog

## 1.6 (zetauma)
* bumped API version to 101049
* major refactor: data-driven settings menu, proper defaults, live-apply on all settings
* added UI Font Style dropdown (bold, shadow, outline, etc.)
* fixed book/letter/tablet fonts by hooking LoreReader:ApplyMedium
* rewrote PerfectPixel compatibility layer (handles PP loading before FC)
* added Linux font conversion script (`fonts/slug.sh`) using Wine
* fixed SCT and nameplate font application

## 1.5 (zetauma)
* improved support for gamepad mode
* improved support for PerfectPixel (some compatibility refactored from 1.3)
	* override PerfectPixel's fonts with a `ZO_PreHook`
	* apply FontChanger's scaling to PerfectPixel

## 1.4 (zetauma)
* Fixed SCT resetting on zone change
* Moved .ttf and .slug files into their own folders
* Added a batch script to automatically generate .slug files and add them to `CustomFontOptions.lua`
* Added all fonts as dropdown options to the addon settings, including vanilla game fonts
	* UI Font
	* Nameplate Font
	* SCT Font
	* Chat Font
	* Book Font
	* Letter Font
	* Stone Tablet Font

## 1.3.1 (Antisenil)
- reworked PostHook into a PreHook + added some extra stuff for PerfectPixel

## 1.3 (Antisenil)
- added a PostHook for PerfectPixel

## 1.2 (Antisenil)
* changed the names of fonts to not overwrite old ones
* updated Readme file
* reworked Nameplate and SCT function in two seperat functions and their own fontpaths, currently they both use the 'FontChanger_RegularFont' font

## 1.1 (Antisenil)
* re-added the old fontpaths to keep compatible with non updated addons

## 1.0 (Antisenil)
* api bump
* standard included fonts converted from .ttf to .slug format
* added options to change the style of nameplates, scrolling combat text(sct) and chat(not all options work the way they should, need to wait for ZOS to make changes)
* added new ZOS constants for fontpaths to ensure compatibility with future updates

## 0.9
* Added options to scale UI fonts individually

## 0.8
* Fixed an issue causing SCT to reset font during zone changes

## 0.7
* Fixed an issue causing an error on startup if you haven't set your own font scale

## 0.6
* Added Options Menu

## 0.5
* Adjusted font size in game pad mode

## 0.4
* Adjusted size of Fonts in game pad mode

## 0.3
* Added support for game pad mode

## 0.2
* Tidyed Code & General Optimization

