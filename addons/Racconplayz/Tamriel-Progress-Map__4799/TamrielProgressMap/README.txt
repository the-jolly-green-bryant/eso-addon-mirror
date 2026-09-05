Tamriel Progress Map 2.7.0

2.7.0 release
-------------
- Reorganized the Statistics journal around TPM's core purpose: progression.
- Main navigation now contains Progress, Economy and PvE / PvP.
- Progress now uses two pages:
  1 / 2 = Tamriel completion dashboard
  2 / 2 = Alliance progress / Alliance Planner
- PvE / PvP now uses two pages:
  1 / 2 = PvE / PvP combat dashboard
  2 / 2 = Character statistics
- Character and Alliance are no longer separate main tabs.
- Character page contains Level / Champion Point progress, active Companion progress, playtime, daily activity and session information.
- Economy remains focused on currencies, balances, received / spent totals and zone economy.
- Alliance Planner uses the stable Tamriel map implementation with zoom and left-drag behavior.
- Completion-category HUD gear keeps the established editor behavior for category HUDs such as Wayshrines and Skyshards.
- Clear Mode was rebuilt as a strict monochrome theme: white text / accents, black translucent surfaces and no warm or semantic UI tinting inside the journal.
- Clear Mode now also keeps hover states, page navigation and focus selectors monochrome.
- Improved Clear Mode restoration when returning to TPM Standard or Transparent TPM.
- Safer PvE death-event de-duplication when ESO does not provide a targetUnitId.
- Improved Character live refresh behavior and reduced unnecessary hidden-page refresh work.
- Fixed Alliance zone links so they return to Progress page 1 and open the requested zone progress.
- DE / EN / RU / FR / ES localization remains synchronized.
- Numerous UI, stability and refresh fixes.

Author: Raccoonplayz

Tamriel Progress Map is a completion and statistics addon for The Elder Scrolls Online.
Its main goal is to answer: what have I completed, and what is still missing?

Current structure
-----------------
Progress
  Page 1: Tamriel / zone completion, categories, collections and achievements
  Page 2: Alliance completion and Alliance Planner

Economy
  Currency balances, received / spent totals and zone economy

PvE / PvP
  Page 1: PvE / PvP combat statistics and recent activity
  Page 2: Character profile, Level / CP, Companion progression, playtime and daily history

Other highlights
----------------
- Completion-category in-game HUDs, including categories such as Wayshrines and Skyshards, with per-HUD position and size editing.
- Statistics themes: TPM Standard, Transparent TPM and Clear Mode.
- DE / EN / RU / FR / ES localization.

Notes
-----
Zone-specific Economy data is not retroactive and begins when a supporting TPM version records it.
Neutral DLC / Chapter maps do not change DC / AD / EP completion percentages.
The Alliance Progress / Planner area remains an Alpha-Test feature.

Dependencies
------------
- LibAddonMenu-2.0 r43 or newer
- LibZone 8.99 or newer

AI disclosure
-------------
Tamriel Progress Map was developed with AI assistance (OpenAI ChatGPT) for programming support,
debugging and code review. All feature decisions, testing, design direction and addon maintenance
are handled by the author.
