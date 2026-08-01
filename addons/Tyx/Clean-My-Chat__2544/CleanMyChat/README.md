# Clean My Chat
[![Build Status](https://travis-ci.org/Tyxz/Clean-My-Chat.svg?branch=master)](https://travis-ci.org/Tyxz/Clean-My-Chat)
[![codecov](https://codecov.io/gh/Tyxz/Clean-My-Chat/branch/master/graph/badge.svg)](https://codecov.io/gh/Tyxz/Clean-My-Chat)
![GitHub issues](https://img.shields.io/github/issues/Tyxz/Clean-My-Chat)
![GitHub last commit](https://img.shields.io/github/last-commit/Tyxz/Clean-My-Chat)
[![Run on Repl.it](https://repl.it/badge/github/Tyxz/Clean-My-Chat)](https://repl.it/github/Tyxz/Clean-My-Chat)

|   |   |   |
|---|---|---|
| Version: | 1.2.0 | [![Documentation](https://img.shields.io/website?label=%7C&up_color=important&up_message=documentation&url=https%3A%2F%2Ftyxz.github.io%2FClean-My-Chat%2F)](https://tyxz.github.io/Clean-My-Chat/) |  
| Build for game version: | 100030 | [![Download](https://img.shields.io/website?label=%7C&up_color=blue&up_message=download&url=http%3A%2F%2Fwww.esoui.com%2Fdownloads%2Finfo2544-CleanMyChat.html)](https://www.esoui.com/downloads/info2544-CleanMyChat.html) |

A small addon for Elder Scrolls Online (no affiliation), to reduce messages in unknown languages from the chat window.

It filters each message if it contains forbidden characters like Spanish ("ñ", "¿", "¡", etc.), Nordic ("ø", "å"), Slavic ("ę", "ł", "ż", etc.), French ("é", "à", "œ", etc.), German (ä, ö, ü, etc.) or cyrillic (б", "г", "ж", etc.).

You are also able to define your own filtered words or characters. For example, 
it could be also used to filter swear words not detected by ESO itself. 
## Settings
If you have the LibAddonMenu-2.0 installed, you will have access to the settings menu to define your own filters 
and set or unset the filter for predefined characters.
## Commands
- **/cmc** main command to open setting menu or show current settings
- **/cmc cyrillic** toggles the cyrillic character filter
- **/cmc german** toggles the German character filter
- **/cmc french** toggles the French character filter
- **/cmc slavic** toggles the Slavic character 
- **/cmc nordic** toggles the Nordic character filter
- **/cmc spanish** toggles the Spanish character filter
- **/cmc custom** toggles the custom character filter
- **/cmc filter** shows the defined custom characters

## Copyright
    Copyright (C) 2020 Arne Rantzen
    
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/gpl-3.0.html>