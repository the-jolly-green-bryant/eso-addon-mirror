PullCard 0.2.0

CONTROLLER-FIRST CHANGES
- No slash commands required.
- Automatic boss detection.
- Persistent PullCard button to reopen the UI.
- Previous / Next buttons for manual boss browsing.
- Visible debug information for zone ID and detected boss names.
- Chat prefill isolated into one function for later console/gamepad adaptation.

INSTALL
Extract the PullCard folder into:
Documents\Elder Scrolls Online\live\AddOns\

Then enable PullCard in the ESO Add-Ons menu and reload the UI or relog.

TEST FLOW
1. Enter a dungeon.
2. Approach/start a boss encounter.
3. PullCard should appear automatically if ESO exposes boss unit tags.
4. If the boss isn't in Data.lua, the detected boss name appears in DEBUG.
5. Use Previous / Next to browse known entries.
6. Explain to Group attempts to prefill party chat. You still press Enter to send.

IMPORTANT
The included mechanics are demo data only. The intended dataset is concise, vetted
first-timer instructions authored from real encounter knowledge.
