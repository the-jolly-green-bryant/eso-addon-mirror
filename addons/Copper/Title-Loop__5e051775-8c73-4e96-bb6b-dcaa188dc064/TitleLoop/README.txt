Title Loop
Version 1.0.8
PS5 / ESO Update 50


VIRTUAL TITLE UPDATE IN 1.0.8

- Adds two virtual entries at the top of Character > Titles:
  - Random Favorite Title
  - Cycle Favorite Title
- Selecting Random Favorite Title immediately equips a random favorite and
  continues rotating randomly.
- Selecting Cycle Favorite Title immediately equips the next favorite and
  continues rotating through favorites in ESO's displayed title order.
- Selecting No Title or any normal title stops automatic rotation.
- Removes the separate automatic rotation On / Off control.
- Removes the separate Cycle / Random mode control.
- Press Triangle still cycles the timer value.
- Hold Triangle now switches the timer between seconds and minutes.
- Existing characters migrate to minutes by default.

OVERVIEW

Title Loop adds a lightweight favorite system to the existing
Character > Titles dropdown and can automatically rotate through each
character's favorite titles.

FEATURES

- Favorites are stored separately for every character.
- Two ESO-style virtual title choices control automatic rotation.
- Random mode never selects the currently equipped title again when two or
  more favorites are available.
- Timer values: 1, 5, 10, 15, 30, and 60.
- Timer unit: seconds or minutes.
- The timer defaults to 15 minutes for new and existing characters.
- No Title and the two virtual rotation entries cannot be favorited.
- With one favorite, selecting a rotation entry equips it and leaves rotation
  enabled but idle.
- With zero favorites, selecting a rotation entry safely leaves rotation off.
- Selecting No Title or a normal title stops rotation.
- No permanent frame-by-frame update loop.
- No external libraries.

CONTROLS

Open Character > Titles, then activate the title dropdown.

- Press Square: Favorite / Unfavorite the highlighted normal title
- Press Triangle: Change the timer value
- Hold Triangle: Switch the timer unit between seconds and minutes

Hold Triangle uses ESO's native Quinary shortcut and native HOLD icon.
Favorite titles are marked with ESO's built-in gold Collections star.

VIRTUAL TITLE ENTRIES

Random Favorite Title
Immediately equips a random favorite title and starts or continues random
rotation. The currently equipped favorite is excluded when another favorite
is available.

Cycle Favorite Title
Immediately equips the next favorite title and starts or continues ordered
rotation. Titles follow ESO's displayed title order and wrap at the end.

STOPPING ROTATION

Select No Title or any normal title in the title dropdown. There is no longer
a separate On / Off button.

TIMER

Press Triangle to cycle:
1, 5, 10, 15, 30, 60

Hold Triangle to switch the same value between seconds and minutes. Examples:
15m becomes 15s, and 60s becomes 60m.

SAVED DATA

The following are stored per character:

- Favorite titles
- Active rotation entry: Random, Cycle, or Off
- Timer value
- Timer unit

COMMAND

/titleloop
Displays the current character's rotation mode, timer, favorite count, and
UI-hook readiness in chat.

INSTALLATION / TESTING

1. Install the TitleLoop folder.
2. Use /reloadui.
3. Open Character > Titles.
4. Mark at least two normal titles as favorites with Square.
5. Select Random Favorite Title or Cycle Favorite Title.
6. Set the timer value with Triangle and unit with Hold Triangle.
7. Select any normal title or No Title to stop rotation.

This add-on is designed for PS5 gamepad UI and requires live console testing
because the console UI cannot be fully reproduced outside ESO.
