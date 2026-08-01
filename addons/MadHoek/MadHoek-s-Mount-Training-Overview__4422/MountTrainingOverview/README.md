# 🐎 Mount Training Overview

## Account-Wide Riding Timer & Status Tracker

Mount Training Overview (MHMTO) provides a clean, fully synchronized overview of mount training progress across all your characters.

No more logging through every alt just to check riding timers.
Everything is visible at a glance — accurate, consistent, and account-wide.

## ✨ Features

* Account-wide overview of all characters
* Fully synchronized riding cooldown timer
* Accurate global cooldown tracking (event-driven, no drift)
* Clear lifecycle states:

  * Never Trained
  * Ready
  * On Cooldown
  * Fully Maxed
  * Trained Before Records Began
* Displays Speed, Stamina, and Carry Capacity
* Advanced tooltip system:

  * Exact local training date
  * Exact local training time
  * Pre-addon training detection
  * Dedicated “Never Trained” handling
* Selectable time format (24h or 12h AM/PM)
* Selectable date format (Client / DD.MM.YYYY / MM/DD/YYYY / ISO)
* Automatic character name synchronization (rename-token safe)
* Adjustable font size
* Fully customizable color themes
* Automatically hides with the compass
* Lightweight, stable, and fully event-driven
* Full localization support (7 official ESO languages)

## 💡 How It Works

When any character trains their mount:

* The cooldown is stored account-wide
* The latest cooldown becomes the global reference
* All characters display a synchronized countdown
* The exact local training timestamp is recorded

This guarantees consistent tracking without timer drift, desync, or inconsistencies.

## ⚠ Important – Character Detection

To populate the character list, each character must be logged in at least once while the addon is installed.

After first installation, only the currently logged-in character will appear.
Simply log in once with your other characters to build the complete overview.

If you delete a character, you may optionally clean up its entry in the saved variables file — the addon will safely rebuild remaining character data.

## 🌍 Localization

Fully localized for all official ESO client languages:

* English
* German
* French
* Spanish
* Russian
* Japanese
* Simplified Chinese

## 🎛 Settings

You can configure:

* Window visibility
* Background transparency
* Font size
* Show/hide alliance
* Show/hide stats
* Filter trainable or maxed characters
* Time format
* Date format
* Custom color themes

## 🎛 Keybinds & Commands
-------------------
Keybinds (configurable in Controls → Addons):
- Toggle MHMTO window
- Toggle window lock

Slash Commands:
- /mhmtov   Toggle window visibility
- /mhmtom   Toggle window lock/movable


## 🔧 Dependency

* LibAddonMenu-2.0

## 📖 How This Addon Came to Life

Mount Training Overview originally began as a small personal project — a simple tool I created as a “thank you” for the first guild that welcomed me when I started playing ESO years ago.

The early versions were shared exclusively within that guild’s Discord server and remained guild-internal for a long time.

Although the guild no longer exists, the addon never disappeared.
I continued using it, refining it, improving it — quietly evolving it over the years.

Version 3.x represents the most polished and stable iteration so far.

What once started as a small gesture of appreciation is now available to the entire community.

## 📜 Disclaimer

This Add-on is not created by, affiliated with, or sponsored by ZeniMax Media Inc.
The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc.
All rights reserved.
